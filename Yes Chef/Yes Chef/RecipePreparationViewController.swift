//
//  RecipePreparationViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipePreparationViewController: UITableViewController
{
    @IBOutlet var activeTimeLabel: UILabel!
}

class PreparationStepCell: UITableViewCell
{
    @IBOutlet var stepNumberLabel: UILabel!
    @IBOutlet var instructionsTextView: UITextView!
}
