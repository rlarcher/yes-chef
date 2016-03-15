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
    @IBOutlet weak var selectedTabIndicatorView: UIImageView!
    
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
        setupInfoStripLabels()
        setupConstraints()
        
        backgroundImageView.af_setImageWithURL(recipe.heroImageURL, placeholderImage: nil)
        
        // This constraint is defined programmatically so that its constant will reflect the height of the infoStripView, which is proportional to the screen size.
        dispatch_async(dispatch_get_main_queue()) {
            self.movableViewTopToBottomLayoutGuideConstraint?.active = true
        }
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
            switchToTab(.Ingredients, then: nil)
        }
    }
    
    @IBAction func preparationButtonTapped(sender: AnyObject)
    {
        if let currentVC = childViewControllers.first where !(currentVC is RecipePreparationViewController) {
            switchToTab(.Preparation, then: nil)
        }
    }
    
    @IBAction func caloriesButtonTapped(sender: AnyObject)
    {
        if let currentVC = childViewControllers.first where !(currentVC is RecipeOverviewViewController) {
            switchToTab(.Overview, then: nil)
        }
    }
    
    func favoriteButtonTapped()
    {
        // TODO
        print("RecipeContainerViewController favoriteButtonTapped")
    }
    
    func backButtonTapped()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Navigation

    func switchToTab(tab: RecipeTab, then completionBlock: (() -> Void)?)
    {
        if let oldVC = childViewControllers.first where currentlySelectedTab != tab {
            self.view.layoutIfNeeded()
            
            let newVC: UIViewController
            switch tab {
            case .Overview:
                newVC = recipeOverviewVC
            case .Ingredients:
                newVC = recipeIngredientsVC
            case .Preparation:
                newVC = recipePreparationVC
            }
            
            moveTabIndicatorToTab(tab)
            updateTabFontAttributes(tab)
            
            oldVC.willMoveToParentViewController(nil)
            (oldVC as? ConversationalTabBarViewController)?.didLoseFocus(nil)
            
            addChildViewController(newVC)
            
            if oldVC is RecipeOverviewViewController {
                transitionFromOverview(oldVC, toNewViewController: newVC, then: completionBlock)
            }
            else if newVC is RecipeOverviewViewController {
                transitionToOverview(newVC, fromOldViewController: oldVC, then: completionBlock)
            }
            else {
                transitionBetweenDetailScreensFrom(oldVC, toNewViewController: newVC, then: completionBlock)
            }
            
            self.currentlySelectedTab = tab
        }
        else {
            // We're already on the requested tab, so just fire the completion block, if any.
            completionBlock?()
        }
    }
    
    // MARK: RecipeNavigationConversationTopicEventHandler and RecipeContainerViewDelegate Protocol Methods
    
    // This method is called when the user speaks a command to focus on a certain tab, or when a child view controller wants to change the focused tab.
    func requestedSwitchTab(newTab: RecipeTab, completion: (() -> Void)?)
    {
        switchToTab(newTab, then: completion)
    }
    
    // MARK: Transition Methods
    
    // When this transition starts, the details page is off screen.
    // 1) Instantly transition in the newVC's content view (while still off screen).
    // 2) Then animate the movableView up into visible space.
    private func transitionFromOverview(oldVC: UIViewController, toNewViewController newVC: UIViewController, /*usingTabViewController tabVC: ConversationalTabBarViewController,*/ then completionBlock: (() -> Void)?)
    {
        assert(newVC is ConversationalTabBarViewController)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.transitionFromViewController(oldVC, toViewController: newVC, duration: 0.0, options: .CurveEaseInOut,
                animations: { () -> Void in
                    // Transition in the new view controller's content view by setting constraints. Trying to set this by frame doesn't work well with the animation of the movableView's constraints in the completion block.
                    newVC.view.translatesAutoresizingMaskIntoConstraints = false
                    let fillConstraints = self.buildConstraintsToFillContainerView(self.containerView, withView: newVC.view)
                    NSLayoutConstraint.activateConstraints(fillConstraints)
                }, completion: { (finished) -> Void in
                    oldVC.removeFromParentViewController()
                    oldVC.view.removeFromSuperview()
                    newVC.didMoveToParentViewController(self)
                    (newVC as! ConversationalTabBarViewController).didGainFocus(completionBlock)
                    
                    UIView.animateWithDuration(0.35) {
                        self.movableViewTopToBottomLayoutGuideConstraint?.active = false
                        self.movableViewTopToTopLayoutGuideConstraint?.active = true
                        
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
            })
        }
    }
    
    // When this transition starts, the details page is on screen.
    // 1) Animate the movableView down off screen.
    // 2) Then instantly transition the newVC's content view into place (won't be visible anyways!).
    private func transitionToOverview(newVC: UIViewController, fromOldViewController oldVC: UIViewController, /*usingTabViewController tabVC: ConversationalTabBarViewController,*/ then completionBlock: (() -> Void)?)
    {
        assert(newVC is ConversationalTabBarViewController)
        
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                self.movableViewTopToTopLayoutGuideConstraint?.active = false
                self.movableViewTopToBottomLayoutGuideConstraint?.active = true
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.transitionFromViewController(oldVC, toViewController: newVC, duration: 0.0, options: .CurveEaseInOut,
                    animations: { () -> Void in
                        newVC.view.translatesAutoresizingMaskIntoConstraints = false
                        let fillConstraints = self.buildConstraintsToFillContainerView(self.containerView, withView: newVC.view)
                        NSLayoutConstraint.activateConstraints(fillConstraints)
                    }, completion: { (finished) -> Void in
                        oldVC.removeFromParentViewController()
                        oldVC.view.removeFromSuperview()
                        newVC.didMoveToParentViewController(self)
                        (newVC as! ConversationalTabBarViewController).didGainFocus(completionBlock)
                })
            }
        }
    }
    
    // Ingredients -> Preparation, and Preparation -> Ingredients
    // When this transition starts, the details page is on screen.
    // 1) Transition over time the newVC.
    // 2) That's it!
    private func transitionBetweenDetailScreensFrom(oldVC: UIViewController, toNewViewController newVC: UIViewController, /*usingTabViewController tabVC: ConversationalTabBarViewController,*/ then completionBlock: (() -> Void)?)
    {
        assert(newVC is ConversationalTabBarViewController)
        
        dispatch_async(dispatch_get_main_queue()) {
            // TODO: Add some movement animation to this. Enter left, exit right or vice versa.
            self.transitionFromViewController(oldVC, toViewController: newVC, duration: 0.35, options: .CurveEaseInOut,
                animations: { () -> Void in
                    newVC.view.translatesAutoresizingMaskIntoConstraints = false
                    let fillConstraints = self.buildConstraintsToFillContainerView(self.containerView, withView: newVC.view)
                    NSLayoutConstraint.activateConstraints(fillConstraints)
                }, completion: { (finished) -> Void in
                    oldVC.removeFromParentViewController()
                    oldVC.view.removeFromSuperview()
                    newVC.didMoveToParentViewController(self)
                    (newVC as! ConversationalTabBarViewController).didGainFocus(completionBlock)
            })
        }
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
    
    // NOTE: This must be called before `setupConstraints()`, so that the buttons are resized to fit their labels prior to adjusting constraints.
    private func setupInfoStripLabels()
    {
        dispatch_async(dispatch_get_main_queue()) {
            // Upper info strip:
            self.recipeNameLabel.text = self.recipe.name
            self.recipeCourseLabel.text = self.recipe.category.rawValue
            let ratingLabels = Utils.getLabelsForRating(self.recipe.presentableRating)
            self.recipeRatingLabel.text = ratingLabels.textLabel
            self.recipeRatingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
            
            // Lower info strip:
            
            let paragraphAttributes = NSMutableParagraphStyle()
            paragraphAttributes.alignment = .Center
            let defaultAttributes = [NSParagraphStyleAttributeName: paragraphAttributes,
                                     NSForegroundColorAttributeName: UIColor.darkTextColor(),
                                     NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)]
            let countAttributes = [NSParagraphStyleAttributeName: paragraphAttributes,
                                   NSForegroundColorAttributeName: UIColor.darkTextColor(),
                                   NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
            
            // Ingredients Button
            let ingredientsNSString = NSString(string: self.recipe.ingredients.count.withSuffix("\nIngredient"))
            let ingredientsCountRange = ingredientsNSString.rangeOfString("\(self.recipe.ingredients.count)")
            let ingredientsTitle = NSMutableAttributedString(string: ingredientsNSString as String, attributes: defaultAttributes)
            ingredientsTitle.setAttributes(countAttributes, range: ingredientsCountRange)
            self.ingredientsButton.setAttributedTitle(ingredientsTitle, forState: .Normal)
            self.ingredientsButton.sizeToFit()
            
            // Prep Time Button
            let prepTimeCount = (self.recipe.totalPreparationTime != nil) ? "\(self.recipe.totalPreparationTime!) min" : "Unknown"
            let prepTimeNSString  = NSString(string: "\(prepTimeCount)\nPrep Time")
            let prepTimeCountRange = prepTimeNSString.rangeOfString(prepTimeCount)
            let prepTimeTitle = NSMutableAttributedString(string: prepTimeNSString as String, attributes: defaultAttributes)
            prepTimeTitle.setAttributes(countAttributes, range: prepTimeCountRange)
            self.preparationButton.setAttributedTitle(prepTimeTitle, forState: .Normal)
            self.preparationButton.sizeToFit()
            
            // Calories (Overview) Button
            let caloriesCount = (self.recipe.calories == 0) ? "Unknown" : "\(self.recipe.calories)"
            let caloriesNSString = NSString(string: "\(caloriesCount)\nCalories")
            let caloriesCountRange = caloriesNSString.rangeOfString(caloriesCount)
            let caloriesTitle = NSMutableAttributedString(string: caloriesNSString as String, attributes: defaultAttributes)
            caloriesTitle.setAttributes(countAttributes, range: caloriesCountRange)
            self.caloriesButton.setAttributedTitle(caloriesTitle, forState: .Normal)
            self.caloriesButton.sizeToFit()
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveTabIndicatorToTab(tab: RecipeTab)
    {
        UIView.animateWithDuration(0.3) {
            switch tab {
            case .Overview:
                self.tabIndicatorAlignCenterXToPreparationButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToIngredientsButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToOverviewButtonConstraint?.active = true
            case .Ingredients:
                self.tabIndicatorAlignCenterXToPreparationButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToOverviewButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToIngredientsButtonConstraint?.active = true
            case .Preparation:
                self.tabIndicatorAlignCenterXToIngredientsButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToOverviewButtonConstraint?.active = false
                self.tabIndicatorAlignCenterXToPreparationButtonConstraint?.active = true
            }
        }
    }
    
    private func updateTabFontAttributes(tab: RecipeTab)
    {
        switch tab {
        case .Overview:
            setAttributedTitleOfButton(caloriesButton, toColor: UIColor.darkTextColor())
            setAttributedTitleOfButton(ingredientsButton, toColor: UIColor.darkTextColor())
            setAttributedTitleOfButton(preparationButton, toColor: UIColor.darkTextColor())
        case .Ingredients:
            setAttributedTitleOfButton(caloriesButton, toColor: UIColor.lightGrayColor())
            setAttributedTitleOfButton(ingredientsButton, toColor: UIColor.darkTextColor())
            setAttributedTitleOfButton(preparationButton, toColor: UIColor.lightGrayColor())
        case .Preparation:
            setAttributedTitleOfButton(caloriesButton, toColor: UIColor.lightGrayColor())
            setAttributedTitleOfButton(ingredientsButton, toColor: UIColor.lightGrayColor())
            setAttributedTitleOfButton(preparationButton, toColor: UIColor.darkTextColor())
        }
    }
    
    private func setAttributedTitleOfButton(button: UIButton, toColor color: UIColor)
    {
        if let currentAttributedTitle = button.currentAttributedTitle {
            let titleTextRange = NSMakeRange(0, NSString(string: currentAttributedTitle.string).length)
            let newAttributedText = NSMutableAttributedString(attributedString: currentAttributedTitle)
            newAttributedText.addAttributes([NSForegroundColorAttributeName: color], range: titleTextRange)
            button.setAttributedTitle(newAttributedText, forState: .Normal)
        }
    }
    
    private func setupConstraints()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.movableViewTopToBottomLayoutGuideConstraint = NSLayoutConstraint(item: self.movableView, attribute: .Top, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: -self.infoStripView.frame.size.height)
            self.movableViewTopToBottomLayoutGuideConstraint?.identifier = "movableViewTopToBottomLayoutGuideConstraint"
            
            self.movableViewTopToTopLayoutGuideConstraint = NSLayoutConstraint(item: self.movableView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
            self.movableViewTopToTopLayoutGuideConstraint?.identifier = "movableViewTopToTopLayoutGuideConstraint"
            
            self.tabIndicatorAlignCenterXToOverviewButtonConstraint = NSLayoutConstraint(item: self.selectedTabIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self.caloriesButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            self.tabIndicatorAlignCenterXToOverviewButtonConstraint?.identifier = "tabIndicatorAlignCenterXToOverviewButtonConstraint"
            
            self.tabIndicatorAlignCenterXToIngredientsButtonConstraint = NSLayoutConstraint(item: self.selectedTabIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self.ingredientsButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            self.tabIndicatorAlignCenterXToIngredientsButtonConstraint?.identifier = "tabIndicatorAlignCenterXToIngredientsButtonConstraint"
            
            self.tabIndicatorAlignCenterXToPreparationButtonConstraint = NSLayoutConstraint(item: self.selectedTabIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self.preparationButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            self.tabIndicatorAlignCenterXToPreparationButtonConstraint?.identifier = "tabIndicatorAlignCenterXToPreparationButtonConstraint"
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func buildConstraintsToFillContainerView(firstView: UIView, withView secondView: UIView) -> [NSLayoutConstraint]
    {
        let topConstraint = NSLayoutConstraint(item: firstView, attribute: .Top, relatedBy: .Equal, toItem: secondView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: firstView, attribute: .Bottom, relatedBy: .Equal, toItem: secondView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: firstView, attribute: .Left, relatedBy: .Equal, toItem: secondView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: firstView, attribute: .Right, relatedBy: .Equal, toItem: secondView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return [topConstraint, bottomConstraint, leftConstraint, rightConstraint]
    }
    
    private var tabIndicatorAlignCenterXToOverviewButtonConstraint: NSLayoutConstraint?
    private var tabIndicatorAlignCenterXToPreparationButtonConstraint: NSLayoutConstraint?
    private var tabIndicatorAlignCenterXToIngredientsButtonConstraint: NSLayoutConstraint?
    
    private var movableViewTopToBottomLayoutGuideConstraint: NSLayoutConstraint?
    private var movableViewTopToTopLayoutGuideConstraint: NSLayoutConstraint?

    private var didInitialLayout: Bool = false
    
    private var recipe: Recipe!
    private var currentlySelectedTab: RecipeTab = .Overview
    private weak var recipeOverviewVC: RecipeOverviewViewController!
    private weak var recipeIngredientsVC: RecipeIngredientsViewController!
    private weak var recipePreparationVC: RecipePreparationViewController!
}

protocol RecipeContainerViewDelegate
{
    func requestedSwitchTab(newTab: RecipeTab, completion: (() -> Void)?)
}

enum RecipeTab: String
{
    case Overview = "Overview"
    case Preparation = "Preparation"
    case Ingredients = "Ingredients"
    
    static func orderedCases() -> [RecipeTab]
    {
        return [.Overview, .Preparation, .Ingredients]
    }
}
