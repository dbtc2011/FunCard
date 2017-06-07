//
//  NavigationController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 11/10/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//
// 260 width
import Foundation
import UIKit
import CoreData

let keyProfile = "profile_picture"

//MARK: - Navigation Controller
class FunNavigationController : UIViewController, UITableViewDelegate, UITableViewDataSource, HomePageDelegate, ModuleViewControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonMenu: UIButton!
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelProfile: UILabel!
    
    @IBOutlet weak var tableMenu: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var downloadsSession: NSURLSession?
    
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
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.downloadsSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        self.setupNavigation()
        self.setupUser()
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.labelProfile.text = self.user!.firstName + " " + self.user!.lastName
    }
    
    //MARK: Method
    func setupNavigation() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.home = storyboard.instantiateViewControllerWithIdentifier("main") as? ViewController
        self.home!.delegate = self
        self.addChildViewController(self.home!)
        self.viewMain.addSubview(self.home!.view)
        self.home!.willMoveToParentViewController(self)
        self.home!.setupUI()
    }
    
    func setupUser() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        self.imageProfile.layer.cornerRadius = 45
        self.imageProfile.layer.borderColor = UIColor.yellowColor().CGColor
        self.imageProfile.layer.borderWidth = 2.0
    
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let predicate = NSPredicate(format: "self.isLoggedIn == 1")
                let arrayFiltered = (results as NSArray).filteredArrayUsingPredicate(predicate)
                
                if arrayFiltered.count > 0 {
                    self.user = UserModelRepresentation()
                    self.user!.convertManagedObjectToUserModelInfo(arrayFiltered.first! as! User)
                    
                    self.labelProfile.text = self.user!.firstName + " " + self.user!.lastName
                    if self.user!.profileImage != "" {
                        print("Download image \(self.user!.profileImage)")
                        let download = Download(url: self.user!.profileImage)
                        
                        let url: NSURL = NSURL(string: self.user!.profileImage)!
                        // 2
                        download.downloadTask = downloadsSession!.downloadTaskWithURL(url)
                        // 3
                        download.downloadTask!.resume()
                        // 4
                        download.isDownloading = true
                    }
                
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Action Navigation
    func goToHomePage() {
        

        self.removeSubviewsOfMain()
        
        if self.user == nil {
            
            self.user = UserModelRepresentation()
            
        }
        
        self.addChildViewController(self.home!)
        
        self.viewMain.addSubview(self.home!.view)
        self.home!.willMoveToParentViewController(self)
        
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
        self.addChildViewController(self.survey!)
        
        self.viewMain.addSubview(self.survey!.view)
        self.survey!.willMoveToParentViewController(self)
        
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
        self.addChildViewController(self.products!)
        
        self.viewMain.addSubview(self.products!.view)
        self.products!.willMoveToParentViewController(self)
        
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
        self.pulsify!.delegate = self
        
        self.addChildViewController(self.pulsify!)
        
        self.viewMain.addSubview(self.pulsify!.view)
        self.pulsify!.willMoveToParentViewController(self)
        
        self.toggleMenuButton()
        
    }
    
    func goToBranches() {
        
        if self.branches != nil {
            self.toggleMenuButton()
            return
        }
        
        self.removeSubviewsOfMain()
        
        let storyboard = UIStoryboard(name: "Branches", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        self.branches = navController.viewControllers.first! as? BranchSelectionViewContoller
        self.branches?.delegate = self
        self.addChildViewController(navController)
        
        self.viewMain.addSubview(navController.view)
        self.branches!.willMoveToParentViewController(self)
        
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
        self.addChildViewController(self.pasaPoints!)
        
        self.viewMain.addSubview(self.pasaPoints!.view)
        self.pasaPoints!.willMoveToParentViewController(self)
        
        self.toggleMenuButton()
    }
    
    func presentComingSoon(){
        
        let comingSoonView = ComingSoonView(frame: self.view.frame)
        self.view.addSubview(comingSoonView)
        
    }
    
    func logout() {
        let alertView = UIAlertController(title: "Fun Card PH", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default)
        { action -> Void in
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
                        
                        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
                        let vc = storyboard.instantiateInitialViewController()
                        appDelegate.window!.rootViewController = vc
                        //back to start
                        self.dismissViewControllerAnimated(true, completion: {
                            
                            
                            
                        })
                    }
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            })
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        { action -> Void in
            
        })
        
        self.presentViewController(alertView, animated: true) {
        }
    }
    
    func removeSubviewsOfMain() {
        if self.home != nil {
            
            self.home!.willMoveToParentViewController(nil)
            self.home!.view.removeFromSuperview()
            self.home!.removeFromParentViewController()
            
        }
        
        if self.survey != nil {
            
            self.survey!.willMoveToParentViewController(nil)
            self.survey!.view.removeFromSuperview()
            self.survey! .removeFromParentViewController()
            
            self.survey = nil
            
        }else if self.pulsify != nil {
            
            self.pulsify!.willMoveToParentViewController(nil)
            self.pulsify!.view.removeFromSuperview()
            self.pulsify! .removeFromParentViewController()
            self.pulsify = nil
            
        }else if self.branches != nil {
            
            self.branches!.willMoveToParentViewController(nil)
            self.branches!.view.removeFromSuperview()
            self.branches! .removeFromParentViewController()
            self.branches = nil
            
        }else if self.pasaPoints != nil {
            
            self.pasaPoints!.willMoveToParentViewController(nil)
            self.pasaPoints!.view.removeFromSuperview()
            self.pasaPoints! .removeFromParentViewController()
            self.pasaPoints = nil
            
        }else if self.products != nil {
            
            self.products!.willMoveToParentViewController(nil)
            self.products!.view.removeFromSuperview()
            self.products! .removeFromParentViewController()
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
        
        let storyboard = UIStoryboard(name: "Registration", bundle: NSBundle.mainBundle())
        let controller = storyboard.instantiateViewControllerWithIdentifier("regForm") as! RegsitrationFormViewController
        controller.user = self.user!
        controller.isEditingProfile = true
        self.presentViewController(controller, animated: true) { 
            
            
        }
        
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
            self.presentComingSoon()
            self.goToHomePage()
        }else if indexPath.row == 3 {
            self.goToProducts()
        }else if indexPath.row == 4 {
            self.presentComingSoon()
            self.goToHomePage()
        }else if indexPath.row == 5 {
            self.presentComingSoon()
            self.goToHomePage()
        }else if indexPath.row == 6 {
            self.goToSurvey()
        }else if indexPath.row == 7 {
            self.goToPasaPoints()
        }else if indexPath.row == 8 {
            self.goToBranches()
        }else if indexPath.row == 9 {
            self.toggleMenuButton()
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
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.presentComingSoon()
        
    }
    
    func homeGoToGames() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.presentComingSoon()
        
    }
    
    func homeGoToProducts() {
        
        self.buttonMenu.selected = !self.buttonMenu.selected
        self.goToProducts()
        
    }
    
    func homeGoToPromos() {
        
        self.presentComingSoon()
        
        
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
extension FunNavigationController : NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            let dataImage = NSData(contentsOfURL: location)
            print("Image = \(dataImage?.length)")
            self.imageProfile.image = UIImage(data: dataImage!)
            self.imageProfile.clipsToBounds = true
        }
       
    }
    
    
    
}



