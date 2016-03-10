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
        
        self.edgesForExtendedLayout = .Top
        
        view.addSubview(recipeOverviewVC.view)
        
        infoStripBottomToBottomLayoutGuideConstraint?.active = true
        containerViewTopToTopLayoutGuideConstraint?.active = true
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if !didInitialLayout {
            didInitialLayout = true
            recipeOverviewVC.view.frame = containerView.frame
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
            
            var startEndFrameBelowScreen = containerView.frame
            startEndFrameBelowScreen.origin.y = containerView.frame.origin.y + containerView.frame.size.height
            
//            let upperContainerFrame = containerView.frame
//            containerView.frame.origin.y = infoStripView.frame.size.height
//            containerView.frame.size.height -= infoStripView.frame.size.height
            
            
            
            oldVC.willMoveToParentViewController(nil)
            (oldVC as? ConversationalTabBarViewController)?.didLoseFocus(nil)
            
            addChildViewController(newVC)
            
            // TODO: Setup start/end frames for animation here
            
            UIView.animateWithDuration(2.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.infoStripBottomToBottomLayoutGuideConstraint?.active = false
                    self.containerViewTopToTopLayoutGuideConstraint?.active = false
                    self.infoStripTopToTopLayoutGuideConstraint?.active = true
                    self.infoStripBottomToContainerViewTopConstraint?.active = true
                
//                    self.containerView.frame.origin.y = self.infoStripView.frame.origin.y + self.infoStripView.frame.size.height
                
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }, completion: { (finished) -> Void in
//                    self.infoStripBottomToContainerViewTopConstraint?.active = true
//                    self.containerViewTopToTopLayoutGuideConstraint?.active = false
                    
//                    self.view.setNeedsLayout()
//                    self.view.layoutIfNeeded()
                }
            )
            
//            UIView.animateWithDuration(2.5) {
//                self.infoStripBottomToBottomLayoutGuideConstraint?.active = false
//                self.infoStripBottomToContainerViewTopConstraint?.active = true
//                self.infoStripTopToTopLayoutGuideConstraint?.active = true
//                self.containerViewTopToTopLayoutGuideConstraint?.active = false
//                
//                //                self.infoStripView.frame.origin.y = self.view.frame.origin.y
//                //                self.containerView.frame.origin.y += self.infoStripView.frame.size.height
//                //                self.containerView.frame.size.height -= self.infoStripView.frame.size.height
//                
//                self.view.setNeedsLayout()
//                self.view.layoutIfNeeded()
//            }
        
            newVC.view.frame = startEndFrameBelowScreen
            
            transitionFromViewController(oldVC,
                toViewController: newVC,
                duration: 2.5,
                options: [.CurveEaseInOut],
                animations: { () -> Void in
                    newVC.view.frame = self.containerView.frame
//                    newVC.view.frame = upperContainerFrame
                    
                    // TODO - Transition infoStrip from bottom to Top:
                    // Change infoStrip's bottom constraint's target to containerView
                    // AKA
                    // Enable infoStripBottomToContainerViewTopConstraint
                    // Disable infoStripBottomToBottomLayoutGuideConstraint
                    // Disable containerViewTopToTopLayoutGuideConstraint
//                    self.infoStripView.frame.origin.y = self.view.frame.origin.y
//                    self.containerView.frame.origin.y += self.infoStripView.frame.size.height
//                    self.containerView.frame.size.height -= self.infoStripView.frame.size.height
//                    
//                    self.view.setNeedsLayout()
//                    self.view.layoutIfNeeded()
                    
//                    self.infoStripBottomToBottomLayoutGuideConstraint?.active = false
//                    self.containerViewTopToTopLayoutGuideConstraint?.active = false
//                    self.infoStripBottomToContainerViewTopConstraint?.active = true
//                    self.view.layoutIfNeeded()
//                    self.view.setNeedsUpdateConstraints()
                    
                    // TODO - Transition infoStrip from Top to Bottom:
                    // Change infoStrip's bottom constraint's target to superview
                    // Change containerView's top constraint's target to superview
                    // AKA
                    // Disable infoStripBottomToContainerViewTopConstraint
                    // Enable infoStripBottomToBottomLayoutGuideConstraint
                    // Enable containerViewTopToTopLayoutGuideConstraint
                },
                completion: { (finished) -> Void in
                    oldVC.removeFromParentViewController()
                    oldVC.view.removeFromSuperview()
                    newVC.didMoveToParentViewController(self)
                    self.view.addSubview(newVC.view)
                    tabViewController.didGainFocus(completionBlock)
                    
//                    self.infoStripBottomToBottomLayoutGuideConstraint?.active = false
//                    self.containerViewTopToTopLayoutGuideConstraint?.active = false
//                    self.infoStripBottomToContainerViewTopConstraint?.active = true
                    
//                    self.view.setNeedsUpdateConstraints()
//                    self.view.layoutIfNeeded()

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
    }
    
    private func setupConstraints()
    {
        infoStripBottomToBottomLayoutGuideConstraint = NSLayoutConstraint(item: infoStripView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0.0)
        infoStripBottomToBottomLayoutGuideConstraint?.identifier = "infoStripBottomToBottomLayoutGuideConstraint"
        
        infoStripBottomToContainerViewTopConstraint = NSLayoutConstraint(item: infoStripView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        infoStripBottomToContainerViewTopConstraint?.identifier = "infoStripBottomToContainerViewTopConstraint"
        
        infoStripTopToTopLayoutGuideConstraint = NSLayoutConstraint(item: infoStripView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        infoStripTopToTopLayoutGuideConstraint?.identifier = "infoStripTopToTopLayoutGuideConstraint"
        
        containerViewTopToTopLayoutGuideConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        containerViewTopToTopLayoutGuideConstraint?.identifier = "containerViewTopToTopLayoutGuideConstraint"
    }
    
    private var infoStripBottomToBottomLayoutGuideConstraint: NSLayoutConstraint?
    private var infoStripBottomToContainerViewTopConstraint: NSLayoutConstraint?
    private var infoStripTopToTopLayoutGuideConstraint: NSLayoutConstraint?
    private var containerViewTopToTopLayoutGuideConstraint: NSLayoutConstraint?
    
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
