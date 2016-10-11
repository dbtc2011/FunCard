//
//  NavigationController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 11/10/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit


class FunNavigationController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonMenu: UIButton!
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelProfile: UILabel!
    
    @IBOutlet weak var tableMenu: UITableView!
    
    
    // Controllers
    var home : ViewController?
    var survey : SurveyViewController?
    var pulsify : PulsifyViewController?
    var branches : BranchesViewController?
    
    
    let arrayMenu = ["Home",
                     "Survey",
                     "Products",
                     "Promos",
                     "Coupons",
                     "Games",
                     "Pasa-Points",
                     "Branches",
                     "Pulsify",
                     "Logout"]
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.setupNavigation()
        
    }
    
    
    //MARK: Method
    func setupNavigation() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.home = storyboard.instantiateViewControllerWithIdentifier("main") as? ViewController
        self.home!.setupUI()
        
        self.viewMain.addSubview(self.home!.view)
        
    }
    
    
    //MARK: Button Actions
    @IBAction func buttonPageClicked(sender: UIButton) {
        
        
    }
    
    @IBAction func menuButtonClicked(sender: UIButton) {
        
        sender.selected = !sender.selected
        
        for contstraints in self.view.constraints {
            if (contstraints.firstItem as? NSObject == self.viewMain || contstraints.firstItem as? NSObject == self.buttonMenu) && contstraints.firstAttribute == NSLayoutAttribute.Leading {
                
                contstraints.constant = 0
                if sender.selected {
                    
                    contstraints.constant = 260
                    
                }
                
                
                
            }else if contstraints.firstItem as? NSObject == self.viewMenu && contstraints.firstAttribute == NSLayoutAttribute.Leading {
                
                contstraints.constant = -260
                if sender.selected {
                    
                    contstraints.constant = 0
                    
                }
                
            }
        }
        
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    //MARK: Delegate Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayMenu.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as? MenuTableViewCell else {
            
            let newCell : MenuTableViewCell = MenuTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "menuCell")
            newCell.selectionStyle = UITableViewCellSelectionStyle.None
            return newCell
        }
        print(self.arrayMenu[indexPath.row])
        cell.label.text = self.arrayMenu[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            
        }else if indexPath.row == 2 {
            
        }else if indexPath.row == 3 {
            
        }else if indexPath.row == 4 {
            
        }else if indexPath.row == 5 {
            
        }else if indexPath.row == 6 {
            
        }else if indexPath.row == 7 {
            
        }else if indexPath.row == 8 {
            
        }
     
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40
      
        
    }

}
