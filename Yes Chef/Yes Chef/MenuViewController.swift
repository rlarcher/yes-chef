//
//  MenuViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/3/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController
{
    var selectionDelegate: MenuViewControllerDelegate?
    
    @IBAction func favoriteRecipesButtonTapped(sender: AnyObject)
    {
        presentingViewController?.dismissViewControllerAnimated(true) {
            self.selectionDelegate?.requestedPresentSavedRecipes()
        }
    }
    
    @IBAction func groceryListButtonTapped(sender: AnyObject)
    {
        // TODO
        print("MenuViewController groceryListButtonTapped")
    }
    
    @IBAction func helpButtonTapped(sender: AnyObject)
    {
        // TODO
        print("MenuViewController helpButtonTapped")
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject)
    {
        // TODO
        print("MenuViewController settingsButtonTapped")
    }
}

protocol MenuViewControllerDelegate
{
    func requestedPresentSavedRecipes()
}
