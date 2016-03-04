//
//  SearchOptionsController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/4/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchOptionsController: UITabBarController
{
    var cuisineSelectionBlock: (Cuisine -> ())? {
        didSet {
            cuisineViewController.selectionBlock = cuisineSelectionBlock
        }
    }
    
    var courseSelectionBlock: (Category -> ())? {
        didSet {
            courseViewController.selectionBlock = courseSelectionBlock
        }
    }
    
    init(searchParameters: SearchParameters)
    {
        self.initialSearchParameters = searchParameters
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        cuisineViewController = CuisineSelectorViewController()
        cuisineViewController.tabBarItem.title = "Cuisine"
        cuisineViewController.selectedRow = Cuisine.orderedValues.indexOf(initialSearchParameters.cuisine)
        
        courseViewController = CategorySelectorViewController()
        courseViewController.tabBarItem.title = "Course"
        courseViewController.selectedRow = Category.orderedValues.indexOf(initialSearchParameters.course)
        
        setViewControllers([cuisineViewController, courseViewController], animated: false)
    }
    
    private var courseViewController: CategorySelectorViewController!
    private var cuisineViewController: CuisineSelectorViewController!
    private var initialSearchParameters: SearchParameters!
}
