//
//  CategoryCuisinePresenter.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/20/2.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class CategoryCuisinePresenter
{
    var eventHandler: CategoryCuisineSelectorEventHandler
    var presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController, eventHandler: CategoryCuisineSelectorEventHandler)
    {
        self.presentingViewController = presentingViewController
        self.eventHandler = eventHandler
    }
    
    func presentCategorySelector(initialCategory initialCategory: Category) {
        let categories = Category.orderedValues
        
        let selectorVC = CategorySelectorViewController()
        selectorVC.categories = categories
        selectorVC.selectedRow = categories.indexOf(initialCategory)
        
        selectorVC.selectionBlock = { selectedCategory in
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
            self.eventHandler.selectedNewCategory(selectedCategory)
        }
        
        // embed in a nav controller and add cancel button
        let navVC = UINavigationController(rootViewController: selectorVC)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "presentedViewControllerCancelButtonTapped")
        selectorVC.navigationItem.leftBarButtonItem = cancelButton
        
        self.presentingViewController.presentViewController(navVC, animated: true, completion: nil)
    }
    
    func presentCuisineSelector(initialCuisine initialCuisine: Cuisine) {
        let cuisines = Cuisine.orderedValues
        
        let selectorVC = CuisineSelectorViewController()
        selectorVC.cuisines = cuisines
        selectorVC.selectedRow = cuisines.indexOf(initialCuisine)
        
        selectorVC.selectionBlock = { selectedCuisine in
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
            self.eventHandler.selectedNewCuisine(selectedCuisine)
        }
        
        // embed in a nav controller and add cancel button
        let navVC = UINavigationController(rootViewController: selectorVC)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "presentedViewControllerCancelButtonTapped")
        selectorVC.navigationItem.leftBarButtonItem = cancelButton
        
        presentingViewController.presentViewController(navVC, animated: true, completion: nil)
    }

    func presentedViewControllerCancelButtonTapped()
    {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol CategoryCuisineSelectorEventHandler
{
    func selectedNewCategory(category: Category)
    func selectedNewCuisine(cuisine: Cuisine)
}
