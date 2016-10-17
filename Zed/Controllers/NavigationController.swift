//
//  NavigationController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 11/10/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FunNavigationController : UIViewController, UITableViewDelegate, UITableViewDataSource, HomePageDelegate, ModuleViewControllerDelegate {
    
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
    var products : ProductsViewController?
    var pulsify : PulsifyViewController?
    var branches : BranchSelectionViewContoller?
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
        self.setupUser()
    }
    
    //MARK: Method
    func setupNavigation() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.home = storyboard.instantiateViewControllerWithIdentifier("main") as? ViewController
        self.home!.setupUI()
        self.home!.delegate = self
        
        self.viewMain.addSubview(self.home!.view)
        
    }
    
    func setupUser() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let predicate = NSPredicate(format: "self.isLoggedIn == 1")
                let arrayFiltered = (results as NSArray).filteredArrayUsingPredicate(predicate)
                
                if arrayFiltered.count > 0 {
                    self.user = UserModelRepresentation()
                    self.user!.convertManagedObjectToUserModelInfo(arrayFiltered.first! as! User)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
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
        self.survey?.delegate = self
        self.survey!.user = self.user!
        self.viewMain.addSubview(self.survey!.view)
        
        self.toggleMenuButton()
        
    }
    
    func goToProducts() {
        
        if self.products != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        let storyboard = UIStoryboard(name: "Products", bundle: nil)
        self.products = storyboard.instantiateInitialViewController() as? ProductsViewController
        self.products?.delegate = self
        self.viewMain.addSubview(self.products!.view)
        
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
        self.pulsify?.delegate = self
        self.viewMain.addSubview(self.pulsify!.view)
        
        self.toggleMenuButton()
        
    }
    
    func goToBranches() {
        
        if self.branches != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        let storyboard = UIStoryboard(name: "Branches", bundle: nil)
        self.branches = storyboard.instantiateInitialViewController()! as? BranchSelectionViewContoller
        self.branches?.delegate = self
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
        self.pasaPoints?.delegate = self
        self.viewMain.addSubview(self.pasaPoints!.view)
        
        self.toggleMenuButton()
    }
    
    func logout() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let predicate = NSPredicate(format: "self.isLoggedIn == 1")
                let arrayFiltered = (results as NSArray).filteredArrayUsingPredicate(predicate)
                
                if arrayFiltered.count > 0 {
                    let user = arrayFiltered.first as! User
                    user.isLoggedIn = 0
                    
                    try managedContext.save()
                    
                    //back to start
                    let storyboard = UIStoryboard(name: "Registration", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController()
                    appDelegate.window!.rootViewController = vc
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
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
            
        }else if self.products != nil {
            
            self.products!.view.removeFromSuperview()
            self.products = nil
            
        }

    }
    func toggleMenuButton() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
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
            self.goToProducts()
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
        }else if indexPath.row == 9 {
            self.logout()
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
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToProducts()
    }
    
    func homeGoToPromos() {
        
        
    }
    
    func homeGoToPulsify() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToPulsify()
        
    }
    
    //MARK: Modules Delegate/Call back
    func pulsifyDidClose() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToHomePage()
        
    }
    
    func surveyDidClose() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToHomePage()
        
    }
    
    func pasaPointsDidClose() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToHomePage()
        
    }
    
    func branchesDidClose() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToHomePage()
        
    }
    
    func productsDidClose() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToHomePage()
        
    }
    
    
    


}
