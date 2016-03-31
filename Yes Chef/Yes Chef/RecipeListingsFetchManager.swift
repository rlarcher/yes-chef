//
//  RecipeListingsFetchManager.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/31/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeListingsFetchManager: NSObject
{
    let maxAttempts = 3
    let listingsCountGoal = 10
    let apiManager: BigOvenAPIManager
    let apiFetcher: BigOvenAPIFetcher
    var completion: (SearchResponse -> Void)!
    
    var validListings = [RecipeListing]()
    var currentAttempt = 0
    
    init(apiManager: BigOvenAPIManager, apiFetcher: BigOvenAPIFetcher)
    {
        self.apiManager = apiManager
        self.apiFetcher = apiFetcher
        super.init()
    }
    
    // Start a new round of finding valid listings.
    func fetchValidListings(parameters: SearchParameters, pageNumber: Int, completion: SearchResponse -> Void)
    {
        currentAttempt = 0
        validListings = [RecipeListing]()
        self.completion = completion
        
        fetchMoreValidListings(parameters, pageNumber: pageNumber)
    }
    
    // Recursively fetch more listings until we gather enough valid ones, or until we reach our max number of attempts, or we get an error.
    private func fetchMoreValidListings(parameters: SearchParameters, pageNumber: Int)
    {
        currentAttempt += 1
        print("Fetching more valid listings. Attempt number \(currentAttempt)")
        apiFetcher.searchForRecipeWithParameters(parameters, pageNumber: pageNumber) { (response) in
            switch response {
            case .Success(let unvalidatedListings):
                self.validateListings(unvalidatedListings) { validationResponse in
                    self.handleValidationResponse(validationResponse, parameters: parameters, pageNumber: pageNumber)
                }
            case .ConnectionError(let error):
                let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while searching for recipes. Please try again later."
                self.completion(.Failure(message: errorMessage, error: error))
            case .UnexpectedBodyFormat(let error):
                let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while searching for recipes."
                self.completion(.Failure(message: errorMessage, error: error))
            }
        }
    }
    
    // Collect the latest validListings, if validation was successful. If we've gathered enough, call the completion block with the valid listings, otherwise fetch even more.
    private func handleValidationResponse(validationResponse: SearchResponse, parameters: SearchParameters, pageNumber: Int)
    {
        switch validationResponse {
        case .Success(let validListings):
            print("Validated some listings. Valid count: \(self.validListings.count)")
            self.validListings.appendContentsOf(validListings)
            if self.finishedGatheringValidListings() {
                print("Finished gathering valid listings. Valid cout: \(self.validListings.count)")
                self.completion(.Success(recipeListings: self.validListings))
            }
            else {
                // Start it all over again, moving to the next page of results
                self.fetchMoreValidListings(parameters, pageNumber: pageNumber + 1)
            }
        default:
            self.completion(validationResponse)
        }
    }
    
    // Check if a listing's recipe has usable preparation steps. We don't want to display recipes that just link to an external website.
    private func validateListings(listings: [RecipeListing], completion: (SearchResponse -> Void))
    {
        var newlyValidatedListings = [RecipeListing]()
        var operations = [NSBlockOperation]()
        
        // After all listings have been validated, call the given completion block with the validated listings.
        let finalOp = NSBlockOperation(block: {
            print("finalOp firing")
            dispatch_async(dispatch_get_main_queue()) {
                self.completion(.Success(recipeListings: newlyValidatedListings))
            }
        })
        
        // Fetch each listing's corresponding Recipe. If that recipe is usable, add the listing to the validatedListings array.
        for listing in listings {
            let recipeOp = NSBlockOperation(block: {
                self.apiManager.fetchRecipe(listing.recipeId, completion: { response in
                    switch response {
                    case .Success(let recipe):
                        if recipe.isUsable {
                            dispatch_async(self.listingValidationThread, {
                                print("Adding newly validated listings")
                                newlyValidatedListings.append(listing)
                            })
                        }
                        else {
                            print("Listing is invalid! [\(listing.name)]")
                        }
                    case .Failure(let errorMessage, let error):
                        completion(.Failure(message: errorMessage, error: error))
                    }
                })
            })
            operations.append(recipeOp)
            finalOp.addDependency(recipeOp)
        }
        
        operations.append(finalOp)
        
        // Start the operation queue
        let operationQueue = NSOperationQueue()
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func finishedGatheringValidListings() -> Bool
    {
        if validListings.count > listingsCountGoal || currentAttempt > maxAttempts {
            return true
        }
        else {
            return false
        }
    }
    
    private let listingValidationThread = dispatch_queue_create("com.conversantlabs.yeschef.RecipeListingsFetchManager.listingValidationThread", DISPATCH_QUEUE_SERIAL)
}
