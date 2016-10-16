//
//  NavigationController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 11/10/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit


class FunNavigationController : UIViewController, UITableViewDelegate, UITableViewDataSource, HomePageDelegate {
    
    //MARK: Properties
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonMenu: UIButton!
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelProfile: UILabel!
    
    @IBOutlet weak var tableMenu: UITableView!
    
    
    var user: UserModelRepresentation?
    
    var home : ViewController?
    var survey : SurveyViewController?
    var pulsify : PulsifyViewController?
    var branches : BranchesViewController?
    var pasaPoints : PasaPointsViewController?
    
    
    let arrayMenu = ["Home",
                     "Pulsify",
                     "Promos",
                     "Products",
                     "Games",
                     "Coupons",
                     "Survey",
                     "Pasa-Points",
                     "Branches",
                     "Logout"]
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        
        self.tableMenu.delegate = self
        self.tableMenu.dataSource = self
        
        self.setupNavigation()
        
    }
    
    
    //MARK: Method
    func setupNavigation() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.home = storyboard.instantiateViewControllerWithIdentifier("main") as? ViewController
        self.home!.setupUI()
        self.home!.delegate = self
        
        self.viewMain.addSubview(self.home!.view)
        
    }
    
    //MARK: Action Navigation
    func goToHomePage() {
    
        self.removeSubviewsOfMain()
        self.toggleMenuButton()
    }

    func goToSurvey() {
        
        if self.survey != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        let storyboard = UIStoryboard(name: "Survey", bundle: nil)
        self.survey = storyboard.instantiateViewControllerWithIdentifier("surveyController") as? SurveyViewController
        self.survey!.user = self.user!
        self.viewMain.addSubview(self.survey!.view)
        
        self.toggleMenuButton()
        
    }
    
    func goToPulsify() {
        
        if self.pulsify != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        let storyboard = UIStoryboard(name: "Pulsify", bundle: nil)
        self.pulsify = storyboard.instantiateViewControllerWithIdentifier("pulsify") as? PulsifyViewController
        self.pulsify!.user = self.user!
        self.viewMain.addSubview(self.pulsify!.view)
        
        self.toggleMenuButton()
        
    }
    
    func goToBranches() {
        
        if self.branches != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        let storyboard = UIStoryboard(name: "Branches", bundle: nil)
        self.branches = storyboard.instantiateInitialViewController()! as? BranchesViewController
        self.branches!.user = self.user!
        self.viewMain.addSubview(self.branches!.view)
        
        self.toggleMenuButton()
        
    }
    
    func goToPasaPoints() {
        
        if self.pasaPoints != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        let storyboard = UIStoryboard(name: "PasaPoints", bundle: nil)
        self.pasaPoints = storyboard.instantiateViewControllerWithIdentifier("pasaPoints") as? PasaPointsViewController
        self.pasaPoints!.user = self.user!
        self.viewMain.addSubview(self.pasaPoints!.view)
        
        self.toggleMenuButton()
    }
    
    func removeSubviewsOfMain() {
        
        if self.survey != nil {
            
            self.survey!.view.removeFromSuperview()
            self.survey = nil
            
        }else if self.pulsify != nil {
            
            self.pulsify!.view.removeFromSuperview()
            self.pulsify = nil
            
        }else if self.branches != nil {
            
            self.branches!.view.removeFromSuperview()
            self.branches = nil
            
        }else if self.pasaPoints != nil {
            
            self.pasaPoints!.view.removeFromSuperview()
            self.pasaPoints = nil
            
        }
    }
    func toggleMenuButton() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        
        for contstraints in self.view.constraints {
            if (contstraints.firstItem as? NSObject == self.viewMain || contstraints.firstItem as? NSObject == self.buttonMenu) && contstraints.firstAttribute == NSLayoutAttribute.Leading {
                
                contstraints.constant = 0
                if self.buttonMenu.selected {
                    
                    contstraints.constant = 260
                    
                }
                
            }else if contstraints.firstItem as? NSObject == self.viewMenu && contstraints.firstAttribute == NSLayoutAttribute.Leading {
                
                contstraints.constant = -260
                if self.buttonMenu.selected {
                    
                    contstraints.constant = 0
                    
                }
                
            }
        }
        
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        
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
        
        if indexPath.row == 0 {
            self.goToHomePage()
        }else if indexPath.row == 1 {
            self.goToPulsify()
        }else if indexPath.row == 2 {
            //promos
            self.toggleMenuButton()
        }else if indexPath.row == 3 {
            // Products
            self.toggleMenuButton()
        }else if indexPath.row == 4 {
            //games
            self.toggleMenuButton()
        }else if indexPath.row == 5 {
            //coupons
            self.toggleMenuButton()
        }else if indexPath.row == 6 {
            self.goToSurvey()
        }else if indexPath.row == 7 {
            self.goToPasaPoints()
        }else if indexPath.row == 8 {
            self.goToBranches()
        }
     
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40
      
        
    }
    
    //MARK: Home Page Delegate
    func homeGoToBranches() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToBranches()
        
    }
    
    func homeGoToPasaPoints() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToPasaPoints()
        
    }
    
    func homeGoToSurvey() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToSurvey()
    }
    
    func homeGoToCoupons() {
        

        
    }
    
    func homeGoToGames() {
        
        
    }
    
    func homeGoToProducts() {
        
        
    }
    
    func homeGoToPromos() {
        
        
    }
    
    func homeGoToPulsify() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToPulsify()
        
    }

}
