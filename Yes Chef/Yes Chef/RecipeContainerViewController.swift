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
    @IBOutlet weak var movableView: UIView!
    @IBOutlet weak var infoStripView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
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
        setupNavigationBar()
        setupConstraints()
        
        backgroundImageView.af_setImageWithURL(recipe.heroImageURL, placeholderImage: nil)
        
        // This constraint is defined programmatically so that its constant will reflect the height of the infoStripView, which is proportional to the screen size.
        movableViewTopToBottomLayoutGuideConstraint?.active = true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if !didInitialLayout {
            didInitialLayout = true
            movableViewTopToBottomLayoutGuideConstraint?.constant = -infoStripView.frame.size.height
        }
        
        view.bringSubviewToFront(infoStripView)
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
    
    func favoriteButtonTapped()
    {
        // TODO
        print("RecipeTabBarController favoriteButtonTapped")
    }
    
    func backButtonTapped()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Navigation
    
    func switchToTab(tabViewController: ConversationalTabBarViewController, then completionBlock: (() -> Void)?)
    {
        if
            let newVC = tabViewController as? UIViewController,
            let oldVC = childViewControllers.first
        {
            self.view.layoutIfNeeded()
            
            oldVC.willMoveToParentViewController(nil)
            (oldVC as? ConversationalTabBarViewController)?.didLoseFocus(nil)
            
            addChildViewController(newVC)
            
            transitionFromViewController(oldVC, toViewController: newVC, duration: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    // Transition in the new view controller's content view by setting constraints. Trying to set this by frame doesn't work well with the animation of the movableView's constraints in the completion block.
                    newVC.view.translatesAutoresizingMaskIntoConstraints = false
                
                    let fillConstraints = self.buildConstraintsToFillContainerView(self.containerView, withView: newVC.view)
                    NSLayoutConstraint.activateConstraints(fillConstraints)
                }, completion: { (finished) -> Void in
                    oldVC.removeFromParentViewController()
                    oldVC.view.removeFromSuperview()
                    newVC.didMoveToParentViewController(self)
                    tabViewController.didGainFocus(completionBlock)
            
                    UIView.animateWithDuration(0.35) {
                        self.movableViewTopToBottomLayoutGuideConstraint?.active = false
                        self.movableViewTopToTopLayoutGuideConstraint?.active = true
                    
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
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
    
    private func setupNavigationBar()
    {
        navigationItem.title = ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "♡", style: .Plain, target: self, action: "favoriteButtonTapped")
        navigationItem.rightBarButtonItem?.enabled = false  // TODO: Activate this
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .Plain, target: self, action: "backButtonTapped") // TODO: Just customize the existing back button, with proper image.
        
        // Roundabout way to make the navigation bar's background completely invisible:
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Have content underlap the translucent navigation bar.
        edgesForExtendedLayout = .Top
    }
    
    private func setupConstraints()
    {
        movableViewTopToBottomLayoutGuideConstraint = NSLayoutConstraint(item: movableView, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: -infoStripView.frame.size.height)
        movableViewTopToBottomLayoutGuideConstraint?.identifier = "movableViewTopToBottomLayoutGuideConstraint"
        
        movableViewTopToTopLayoutGuideConstraint = NSLayoutConstraint(item: movableView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        movableViewTopToTopLayoutGuideConstraint?.identifier = "movableViewTopToTopLayoutGuideConstraint"
    }
    
    private func buildConstraintsToFillContainerView(firstView: UIView, withView secondView: UIView) -> [NSLayoutConstraint]
    {
        let topConstraint = NSLayoutConstraint(item: firstView, attribute: .Top, relatedBy: .Equal, toItem: secondView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: firstView, attribute: .Bottom, relatedBy: .Equal, toItem: secondView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: firstView, attribute: .Left, relatedBy: .Equal, toItem: secondView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: firstView, attribute: .Right, relatedBy: .Equal, toItem: secondView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return [topConstraint, bottomConstraint, leftConstraint, rightConstraint]
    }
    
    private var movableViewTopToBottomLayoutGuideConstraint: NSLayoutConstraint?
    private var movableViewTopToTopLayoutGuideConstraint: NSLayoutConstraint?

    private var didInitialLayout: Bool = false
    
    private var recipe: Recipe!
    private weak var recipeOverviewVC: RecipeOverviewViewController!
    private weak var recipeIngredientsVC: RecipeIngredientsViewController!
    private weak var recipePreparationVC: RecipePreparationViewController!
}

protocol RecipeContainerViewDelegate
{
    func requestedSwitchToTab(tab: ConversationalTabBarViewController, completion: () -> Void)
}
