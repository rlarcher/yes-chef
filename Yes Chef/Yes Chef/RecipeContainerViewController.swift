//
//  RecipeContainerViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/8/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeContainerViewController: UIViewController, RecipeNavigationConversationTopicEventHandler, RecipeContainerViewDelegate
{
    var recipeNavigationConversationTopic: RecipeNavigationConversationTopic!    
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeCourseLabel: UILabel!
    @IBOutlet weak var recipeRatingLabel: UILabel!
    
    @IBOutlet weak var ingredientsButton: UIButton!
    @IBOutlet weak var preparationButton: UIButton!
    @IBOutlet weak var caloriesButton: UIButton!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        recipeNavigationConversationTopic = RecipeNavigationConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        instantiateChildrenViewControllers()
        setupConversationTopic()
        
        // Start by showing the OverviewVC in our container.
        addChildViewController(recipeOverviewVC)
        recipeOverviewVC.view.frame = containerView.frame
        view.addSubview(recipeOverviewVC.view)
        recipeOverviewVC.didMoveToParentViewController(self)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        recipeOverviewVC.didGainFocus(nil)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        recipeNavigationConversationTopic.topicDidLoseFocus()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillDisappear(animated)
    }
    
    // This must be called immediately after instantiating the VC.
    func setRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        recipeNavigationConversationTopic.updateRecipe(recipe)
    }
    
    @IBAction func ingredientsButtonTapped(sender: AnyObject)
    {
        if let currentVC = childViewControllers.first where !(currentVC is RecipeIngredientsViewController) {
            switchToTab(recipeIngredientsVC, then: nil)
        }
    }
    
    @IBAction func preparationButtonTapped(sender: AnyObject)
    {
        if let currentVC = childViewControllers.first where !(currentVC is RecipePreparationViewController) {
            switchToTab(recipePreparationVC, then: nil)
        }
    }
    
    @IBAction func caloriesButtonTapped(sender: AnyObject)
    {
        if let currentVC = childViewControllers.first where !(currentVC is RecipeOverviewViewController) {
            switchToTab(recipeOverviewVC, then: nil)
        }
    }
    
    // MARK: Navigation
    
    func switchToTab(tabViewController: ConversationalTabBarViewController, then completionBlock: (() -> Void)?)
    {
        if
            let newVC = tabViewController as? UIViewController,
            let oldVC = childViewControllers.first
        {
            oldVC.willMoveToParentViewController(nil)
            (oldVC as? ConversationalTabBarViewController)?.didLoseFocus(nil)
            
            addChildViewController(newVC)
            
            // TODO: Setup start/end frames for animation here
            
            transitionFromViewController(oldVC,
                toViewController: newVC,
                duration: 0.25,
                options: .CurveEaseInOut,
                animations: nil,
                completion: { (finished) -> Void in
                    // TODO
                    oldVC.removeFromParentViewController()
                    newVC.didMoveToParentViewController(self)
                    tabViewController.didGainFocus(completionBlock)
                })
        }
    }
    
    // MARK: RecipeNavigationConversationTopicEventHandler Protocol Methods
    
    // This method is called when the user speaks a command to focus on a certain tab.
    func requestedSwitchTab(newTab: RecipeTab)
    {
        switch newTab {
        case .Overview:
            switchToTab(recipeOverviewVC, then: nil)
        case .Preparation:
            switchToTab(recipePreparationVC, then: nil)
        case .Ingredients:
            switchToTab(recipeIngredientsVC, then: nil)
        }
    }
    
    // MARK: RecipeContainerViewDelegate Protocol Methods
    
    // This method is called when a child view controller wants to change the focused tab.
    func requestedSwitchToTab(tab: ConversationalTabBarViewController, completion: () -> Void)
    {
        switchToTab(tab, then: completion)
    }
    
    // MARK: Helpers
    
    private func instantiateChildrenViewControllers()
    {
        if let overviewVC = storyboard?.instantiateViewControllerWithIdentifier("RecipeOverviewViewController") as? RecipeOverviewViewController
        {
            overviewVC.updateRecipe(self.recipe)
            overviewVC.delegate = self
            self.recipeOverviewVC = overviewVC
        }
        
        if let ingredientsVC = storyboard?.instantiateViewControllerWithIdentifier("RecipeIngredientsViewController") as? RecipeIngredientsViewController
        {
            ingredientsVC.updateRecipe(self.recipe)
            ingredientsVC.delegate = self
            self.recipeIngredientsVC = ingredientsVC
        }
        
        if let preparationVC = storyboard?.instantiateViewControllerWithIdentifier("RecipePreparationViewController") as? RecipePreparationViewController
        {
            preparationVC.updateRecipe(self.recipe)
            preparationVC.delegate = self
            self.recipePreparationVC = preparationVC
        }
    }
    
    private func setupConversationTopic()
    {
        recipeNavigationConversationTopic.addSubtopic(recipeOverviewVC.recipeOverviewConversationTopic)
        recipeNavigationConversationTopic.addSubtopic(recipeIngredientsVC.recipeIngredientsConversationTopic)
        recipeNavigationConversationTopic.addSubtopic(recipePreparationVC.recipePreparationConversationTopic)
    }
    
    private var recipe: Recipe!
    private weak var recipeOverviewVC: RecipeOverviewViewController!
    private weak var recipeIngredientsVC: RecipeIngredientsViewController!
    private weak var recipePreparationVC: RecipePreparationViewController!
}

protocol RecipeContainerViewDelegate
{
    func requestedSwitchToTab(tab: ConversationalTabBarViewController, completion: () -> Void)
}
