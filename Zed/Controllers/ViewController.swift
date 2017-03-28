//
//  ViewController.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import UIKit
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData

let userID = "7E177E8A450562B7B65F77881C817B47"
let password = "FDFE29DF7FF33EC5078B03F468B7A04C"
let merchantID = "581"
let timezone = "GMT+800"
let channel = "WEB"
let currency = "PHP"

func generateTransactionIDWithTimestamp(timeStamp: String) -> String {
    let trimmedTimeStamp = String(timeStamp.characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil })
    return "FUNAPP_\(trimmedTimeStamp)"
}

func generateTimeStamp() -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.stringFromDate(NSDate())
}

protocol HomePageDelegate {
    
    func homeGoToSurvey()
    func homeGoToPulsify()
    func homeGoToBranches()
    func homeGoToPasaPoints()
    func homeGoToPromos()
    func homeGoToGames()
    func homeGoToCoupons()
    func homeGoToProducts()
    
}

//MARK: - Base View Controller
class BaseViewController: UIViewController {
    
    //MARK: Properties
    
    var alertView: CustomAlertView?
    var loadingView: CustomLoadingView?
    var btnSender: UIButton?
    
    //MARK: Methods
    
    //alert
    func displayAlert(message: String, title: String) {
        if self.alertView == nil {
            
            let alertFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            
            self.alertView = CustomAlertView(frame: alertFrame)
        }
        
        self.alertView!.setAlertMessageAndTitle(message, title: title)
        self.view.addSubview(self.alertView!)
    }
    
    func displayAlertValidationError() {
        self.displayAlert("Please check if your inputs have been filled out correctly.",
                          title: "Validation Error")
    }
    
    func displayAlertRequestError(status: String, descripion: String) {
        self.displayAlert("\(status): \(descripion)",
                          title: "Request Error")
    }
    
    func displayAlertTimedOut(message: String) {
        self.displayAlert("\(message)",
                          title: "Request Timed Out")
    }
    
    func displayAlertWithError(error: NSError) {
        if error.code == -1009 {
            self.displayAlertNoConnection()
            return
        }
        
        self.displayAlert("Something went wrong with the app.",
                          title: "Internal Server Error")
    }
    
    func displayAlertNoConnection() {
        self.displayAlert("Make sure your device is connected to the internet.",
                          title: "No Internet Connection")
    }
    
    //loading
    func displayLoadingScreen() {
        if self.loadingView == nil {
            self.loadingView = CustomLoadingView(frame: self.view.frame)
        }
        
        self.view.addSubview(self.loadingView!)
    }
    
    func hideLoadingScreen() {
        self.loadingView!.removeFromSuperview()
    }
    
    //internet checking
    func checkConnection() -> Bool {
        if Reachability.isConnectedToNetwork() == true {
            return true
        }
        
        return false
    }
}

//MARK: - View Controller
class ViewController: BaseViewController , UIScrollViewDelegate, WebServiceDelegate, PointHeaderViewDelegate {
    
    //MARK: Properties
    var counter = 0
    let cardInfo: CardInfoView = CardInfoView()
    let header: PointHeaderView = PointHeaderView()
    
    var user: UserModelRepresentation?
    let webService = WebService()
    var delegate: HomePageDelegate?
    
    var hideGuilde : Bool = true
    var viewGuide : UIView?
    
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("identify_card") as! String == "false" {
            
            self.hideGuilde = false
            
        }
        self.setupUI()
        self.header.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.hideGuilde == false {
            self.showGuide()
        }
        
        self.view.bringSubviewToFront(self.cardInfo)
        self.view.bringSubviewToFront(self.header)
        self.getDashboardInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for contstraints in self.view.constraints {
            
            if contstraints.firstItem as? NSObject == self.view {
                
                if contstraints.firstAttribute == NSLayoutAttribute.Height {
                    contstraints.constant = UIScreen.mainScreen().bounds.size.height
                }else if contstraints.firstAttribute == NSLayoutAttribute.Width {
                    contstraints.constant = UIScreen.mainScreen().bounds.size.width
                }
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: PointHeaderView Delegate
    func pointHeaderViewDidRefresh() {
        
        self.getDashboardInfo()
    }
    
    func pointHeaderDidLogout() {
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
                        
                        //back to start
                        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
                        let vc = storyboard.instantiateInitialViewController()
                        appDelegate.window!.rootViewController = vc
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
    
    //MARK: Methods
    func setupUI() {
        self.webService.delegate = self
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.view.backgroundColor = UIColor.blackColor()
            self.pageIndicator.enabled = false
            self.pageIndicator.numberOfPages = 8
            
            self.scrollView.showsHorizontalScrollIndicator = false
            self.scrollView.showsVerticalScrollIndicator = false
            
            let buttonHeight = (UIScreen.mainScreen().bounds.size.height * 0.45) - 45
            
            var xLocation = (UIScreen.mainScreen().bounds.size.width/2) - (buttonHeight/2)
            
            for index in 1...8 {
                
                let imageName = "category" +  "\(index)"
                
                let button = UIButton(type: UIButtonType.Custom)
                button.tag = index
                button.frame = CGRectMake(xLocation, 15, buttonHeight, buttonHeight)
                button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
                //uncomment
                button.addTarget(self, action: #selector(ViewController.buttonsClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                self.scrollView.addSubview(button)
                
                xLocation = xLocation + UIScreen.mainScreen().bounds.size.width
                
            }
            
            self.scrollView.scrollEnabled = true
            self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * 8, 0)
            
            self.header.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height * 0.23)
            self.header.setupView()
            self.view.addSubview(self.header)
            
            
            
            self.cardInfo.frame = CGRectMake(10, UIScreen.mainScreen().bounds.size.height - ((UIScreen.mainScreen().bounds.size.height * 0.43) + 200), UIScreen.mainScreen().bounds.size.width - 20, 155)
            
            if UIScreen.mainScreen().bounds.size.height == 480 {
                self.cardInfo.frame = CGRectMake(10, UIScreen.mainScreen().bounds.size.height - ((UIScreen.mainScreen().bounds.size.height * 0.43) + 155 + 5), UIScreen.mainScreen().bounds.size.width - 20, 135)
            }
            self.cardInfo.setupView()
            self.view.addSubview(self.cardInfo)
            
            self.fetchUserFromCoreData()
        }
        
    }
    
    func showGuide() {
        
        self.hideGuilde = true
        
        var guideFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        
        self.viewGuide = UIView(frame: guideFrame)
        self.view.window!.addSubview(self.viewGuide!)
        
        let blackBG = UIImageView(frame: guideFrame)
        blackBG.backgroundColor = UIColor.blackColor()
        blackBG.alpha = 0.5
        self.viewGuide!.addSubview(blackBG)
        
        guideFrame.origin.y = CGRectGetMinY(self.cardInfo.frame) + 5
        guideFrame.origin.x = 10
        guideFrame.size.width = self.cardInfo.frame.size.width
        guideFrame.size.height = 25
        
        let imageRect = UIImageView(frame: guideFrame)
        imageRect.image = UIImage(named: "rect")
        self.viewGuide!.addSubview(imageRect)
        
        guideFrame.origin.x = 10
        guideFrame.origin.y = 0
        guideFrame.size.width = 120
        guideFrame.size.height = 25
        
        let labelCard = UILabel(frame: guideFrame)
        labelCard.text = "Card 1:"
        labelCard.font = UIFont.systemFontOfSize(13)
        labelCard.textAlignment = NSTextAlignment.Left
        labelCard.textColor = UIColor(red: 248/255, green: 227/255, blue: 56/255, alpha: 1.0)
        imageRect.addSubview(labelCard)
        
        
        guideFrame.origin.x = 130
        guideFrame.size.width = self.cardInfo.frame.size.width - 140
        
        let guideCardNumber = UILabel(frame: guideFrame)
        guideCardNumber.text = self.user!.cardNumber
        guideCardNumber.font = UIFont.systemFontOfSize(13)
        guideCardNumber.textAlignment = NSTextAlignment.Right
        guideCardNumber.backgroundColor = UIColor.clearColor()
        guideCardNumber.textColor = UIColor.whiteColor()
        imageRect.addSubview(guideCardNumber)
        
        guideFrame.origin.x = self.cardInfo.frame.size.width - 70
        guideFrame.size.width = 25
        guideFrame.size.height = 100
        guideFrame.origin.y = CGRectGetMaxY(imageRect.frame) + 20
        
        let imageArrow = UIImageView(frame: guideFrame)
        imageArrow.image = UIImage(named: "arrow")
        self.viewGuide!.addSubview(imageArrow)
        
        
        guideFrame.origin.x = 0
        guideFrame.origin.y = CGRectGetMaxY(imageArrow.frame) - 20
        guideFrame.size.width = self.viewGuide!.frame.size.width
        guideFrame.size.height = 55
        
        let labelHere = UILabel(frame: guideFrame)
        labelHere.font = UIFont.systemFontOfSize(22)
        labelHere.textAlignment = NSTextAlignment.Center
        labelHere.textColor = UIColor(red: 248/255, green: 227/255, blue: 56/255, alpha: 1.0)
        labelHere.text = "Here is your\nnew VCard Number!"
        labelHere.numberOfLines = 2
        self.viewGuide!.addSubview(labelHere)
        
        guideFrame.origin.x = -25
        guideFrame.origin.y = self.viewGuide!.frame.size.height - 170
        guideFrame.size.width = 200
        guideFrame.size.height = 200
        
        let ninjaImage = UIImageView(frame: guideFrame)
        ninjaImage.image = UIImage(named: "register")
        ninjaImage.transform = CGAffineTransformMakeRotation(CGFloat(0.4));
        self.viewGuide!.addSubview(ninjaImage)
        
        guideFrame.origin.x = 0
        guideFrame.origin.y = 0
        guideFrame.size.width = UIScreen.mainScreen().bounds.size.width
        guideFrame.size.height = UIScreen.mainScreen().bounds.size.height
        
        let buttonHide = UIButton(type: UIButtonType.Custom)
        buttonHide.frame = guideFrame
        buttonHide.setTitle("", forState: UIControlState.Normal)
        //uncomment
        buttonHide.addTarget(self, action: #selector(ViewController.hideGuideButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.viewGuide!.addSubview(buttonHide)
        
    }
    
    func goToSurvey() {
        
        let storyboard = UIStoryboard(name: "Survey", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("surveyController") as! SurveyViewController
        vc.user = self.user!
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func goToPulsify() {
        
        let storyboard = UIStoryboard(name: "Pulsify", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("pulsify") as! PulsifyViewController
        vc.user = self.user!
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func goToBranches() {
        
        let storyboard = UIStoryboard(name: "Branches", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func goToPasaPoints() {
        //PasaPoints
        
        let storyboard = UIStoryboard(name: "PasaPoints", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("pasaPoints")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func getDashboardInfo() {
        let transactionID = generateTransactionIDWithTimestamp(generateTimeStamp())
        
        if self.user == nil {
            self.fetchUserFromCoreData()
        }
        
        let mobileNumber = self.user!.mobileNumber
        let dictInfo = ["transactionId": transactionID,
                        "mobileNumber": mobileNumber]
        self.webService.connectAndGetDashboardInfo(dictInfo)
    }
    
    func fetchUserFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        self.user = UserModelRepresentation()
        
        //3
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let user = results.last!
                self.user!.convertManagedObjectToUserModelInfo(user)
                
                //update ui
                var cardNumber1 = ""
                for char in self.user!.cardNumber.characters {
                    cardNumber1.append(char)
                    
                    let strForComparison = cardNumber1.stringByReplacingOccurrencesOfString("-", withString: "")
                    if strForComparison.characters.count%4 == 0 && cardNumber1.characters.count < 19 {
                        cardNumber1 += "-"
                    }
                }
                
                var cardNumber2 = ""
                if self.user!.cardNumber2.characters.count > 3 {
                    for char in self.user!.cardNumber2.characters {
                        cardNumber2.append(char)
                        
                        let strForComparison = cardNumber2.stringByReplacingOccurrencesOfString("-", withString: "")
                        if strForComparison.characters.count%4 == 0 && cardNumber2.characters.count < 19 {
                            cardNumber2 += "-"
                        }
                    }
                } else {
                    cardNumber2 = self.user!.cardNumber2
                }
                
                var cardNumber3 = ""
                if self.user!.cardNumber3.characters.count > 3 {
                    for char in self.user!.cardNumber3.characters {
                        cardNumber3.append(char)
                        
                        let strForComparison = cardNumber3.stringByReplacingOccurrencesOfString("-", withString: "")
                        if strForComparison.characters.count%4 == 0 && cardNumber3.characters.count < 19 {
                            cardNumber3 += "-"
                        }
                    }
                } else {
                    cardNumber3 = self.user!.cardNumber3
                }
                
                self.header.labelPoints.text = self.user!.points
                self.cardInfo.labelCard1.text = cardNumber1
                self.cardInfo.labelCard2.text = cardNumber2
                self.cardInfo.labelCard3.text = cardNumber3
                
                self.cardInfo.labelPointsEarned.text = self.user!.lastPointsEarned
                self.cardInfo.labelPointsRedeemed.text = self.user!.lastPointsRedeemed
                self.cardInfo.labelPasaPoints.text = self.user!.lastPointsPasa
                self.cardInfo.labelTransactionDate.text = self.user!.lastTransactionDate
                
                if NSUserDefaults.standardUserDefaults().objectForKey("lastUpdated") == nil {
                    NSUserDefaults.standardUserDefaults().setObject("---", forKey: "lastUpdated")
                }
                self.header.labelLastUpdate.text = "Last Updated  \(NSUserDefaults.standardUserDefaults().objectForKey("lastUpdated")!)"
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func updateUserFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let user = results.last!
                user.points = self.user!.points
                user.cardNumber1 = self.user!.cardNumber
                user.cardNumber2 = self.user!.cardNumber2
                user.cardNumber3 = self.user!.cardNumber3
                user.lastPointsEarned = self.user!.lastPointsEarned
                user.lastPointsRedeemed = self.user!.lastPointsRedeemed
                user.lastPointsPasa = self.user!.lastPointsPasa
                user.lastTransactionDate = self.user!.lastTransactionDate
                
                try managedContext.save()
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        counter = (Int)(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width)
        self.pageIndicator.currentPage = counter
        
        
        print("scroll offset = \(scrollView.contentOffset.x) view = \(self.view.frame.size.width)")
        print("Page is == \((Int)(scrollView.contentOffset.x / self.view.frame.size.width))")
    }
    
    //MARK: Button Actions
    func buttonsClicked(sender: UIButton) {
        if sender.tag == 1 {
            self.delegate?.homeGoToPulsify()
        }else if sender.tag == 2 {
            self.delegate?.homeGoToPromos()
        }else if sender.tag == 3 {
            self.delegate?.homeGoToProducts()
        }else if sender.tag == 4 {
            self.delegate?.homeGoToGames()
        }else if sender.tag == 5 {
            self.delegate?.homeGoToCoupons()
        }else if sender.tag == 6 {
            self.delegate?.homeGoToSurvey()
        }else if sender.tag == 7 {
            self.delegate?.homeGoToPasaPoints()
        }else if sender.tag == 8 {
            self.delegate?.homeGoToBranches()
        }
    }
    
    func hideGuideButton(sender : UIButton) {
        
        self.viewGuide!.removeFromSuperview()
        self.viewGuide = nil
        
    }
    
    func modifyCardNumber(cardNumber: String) -> String {
        var newCardNumber = ""
        
        for char in cardNumber.characters {
            newCardNumber.append(char)
            
            let strForComparison = newCardNumber.stringByReplacingOccurrencesOfString("-", withString: "")
            if strForComparison.characters.count%4 == 0 && newCardNumber.characters.count < 19 {
                newCardNumber += "-"
            }
        }
        
        return newCardNumber
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        header.userInteractionEnabled = true
        
        let status = parsedDictionary["STATUS"] as! String
        let description = parsedDictionary["DESCRIPTION"] as! String
        
        if status == "0" {
            self.user!.points = parsedDictionary["TOTALPOINTS"] as! String
            
            if parsedDictionary["LinkedCards"] != nil {
                
                let linkedCardsArray = parsedDictionary["LinkedCards"] as! [[String: AnyObject]]
                //self.user!.cardNumber = parsedDictionary["PRIMARYCARDNUMBER"] as! String
                
                for card in linkedCardsArray {
                    let index = (linkedCardsArray as NSArray).indexOfObject(card)
                    let oldCardNumber = "\(card["CARDNUMBER"]!)"
                    let newCardNumber = oldCardNumber
                    
                    switch index {
                    case 0:
                        self.user!.cardNumber = oldCardNumber
                        self.cardInfo.labelCard1.text = newCardNumber
                        
                        break
                    case 1:
                        self.user!.cardNumber2 = oldCardNumber
                        self.cardInfo.labelCard2.text = newCardNumber
                        
                        break
                    case 2:
                        self.user!.cardNumber3 = oldCardNumber
                        self.cardInfo.labelCard3.text = newCardNumber
                        
                        break
                    default:
                        break
                    }
                }
            }
            
            if parsedDictionary["Transactions"] != nil {
                let transactions = parsedDictionary["Transactions"] as! NSArray
                if transactions.count > 0 {
                    let lastTransaction = transactions.firstObject! as! NSDictionary
                    
                    self.user!.lastPointsEarned = lastTransaction["EARNED"] as! String
                    self.user!.lastPointsPasa = lastTransaction["PASA"] as! String
                    self.user!.lastPointsRedeemed = lastTransaction["REDEEMED"] as! String
                    self.user!.lastTransactionDate = lastTransaction["DATE"] as! String
                }
            }
            
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy | h:mm a"
            NSUserDefaults.standardUserDefaults().setObject(dateFormatter.stringFromDate(date), forKey: "lastUpdated")
            
            //update core data
            self.updateUserFromCoreData()
            
            //update ui here
            var cardNumber1 = ""
            for char in self.user!.cardNumber.characters {
                cardNumber1.append(char)
                
                let strForComparison = cardNumber1.stringByReplacingOccurrencesOfString("-", withString: "")
                if strForComparison.characters.count%4 == 0 && cardNumber1.characters.count < 19 {
                    cardNumber1 += "-"
                }
            }
            
            self.header.labelPoints.text = self.user!.points
            self.cardInfo.labelCard1.text = cardNumber1
            self.header.labelLastUpdate.text = "Last Updated  \(NSUserDefaults.standardUserDefaults().objectForKey("lastUpdated")!)"
            self.cardInfo.labelPointsEarned.text = self.user!.lastPointsEarned
            self.cardInfo.labelPointsRedeemed.text = self.user!.lastPointsRedeemed
            self.cardInfo.labelPasaPoints.text = self.user!.lastPointsPasa
            self.cardInfo.labelTransactionDate.text = self.user!.lastTransactionDate
            
            return
        }
        
        displayAlertRequestError(status, descripion: description)
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
        
    }
    
    func webServiceDidTimeout() {
        displayAlertTimedOut("Failed to fetch updated information")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        displayAlertWithError(error)
    }
    
    
}

//MARK: - Menu View Controller
class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var imageBranchLOgo: UIImageView!
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var branchName2: UILabel!
    @IBOutlet weak var menu2: UILabel!
    @IBOutlet weak var back2: UIButton!
    
    @IBOutlet weak var branchName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var showMenuType: Bool = true
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
    
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewHolder.sendSubviewToBack(self.imageBranchLOgo)
        
        self.branchName.text = "KFC MENU"
        self.branchName2.text = "KFC MENU"
        self.menu2.text =  "Chicken & Bowl Meals"
        
        self.viewHolder.bringSubviewToFront(self.branchName)
        self.viewHolder.bringSubviewToFront(self.branchName2)
        self.viewHolder.bringSubviewToFront(self.menu2)
        self.viewHolder.bringSubviewToFront(self.back2)
        
        self.imageBranchLOgo.layer.cornerRadius = 5.0
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
    }
    
    
    //MARK: Method
    
    
    func setMenuHidden(hidden: Bool) {
        
        if hidden {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.branchName.alpha = 0.0
                self.tableView.alpha = 0.0
                
                }, completion: { (animated: Bool) -> Void in
                    self.tableView.reloadData()
                    self.tableView.alpha = 1.0
                    self.menu2.alpha = 1.0
                    self.back2.alpha = 1.0
                    self.branchName2.alpha = 1.0
                    
            })
            
        } else {
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.tableView.alpha = 0.0
                self.menu2.alpha = 0.0
                self.back2.alpha = 0.0
                self.branchName2.alpha = 0.0
                
                }, completion: { (animated: Bool) -> Void in
                    
                    self.tableView.reloadData()
                    self.tableView.alpha = 1.0
                    self.branchName.alpha = 1.0
                    
            })
        }
        
    }
    //MARK: Button Action
    @IBAction func backClicked(sender: UIButton) {
        
        self.showMenuType = !self.showMenuType
        self.setMenuHidden(false)
        
    }
    
    //MARK: Delegate Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if self.showMenuType {
            
            guard let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier") as? MenuTypeTableViewCell else {
                
                let newCell : MenuTypeTableViewCell = MenuTypeTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellIdentifier")
                newCell.menuType = "Chicken"
                newCell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, 40))
                newCell.selectionStyle = UITableViewCellSelectionStyle.None
                return newCell
            }
            
            cell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, 40))
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
            return cell
        }
        
        let tempContent = MenuContentModelRepresentation()
        tempContent.menuName = "AM Chicken Longganisa"
        tempContent.labelOption1 = "Ala Carte:"
        tempContent.labelOption2 = "Combo:"
        tempContent.labelOption3 = "Combo w/ Hashbrown:"
        tempContent.option1 = "PHP 90.00"
        tempContent.option2 = "PHP 95.00"
        tempContent.option3 = "100.00"
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cellContentIdentifier") as? MenuTypeContentTableViewCell else {
            
            let newCell : MenuTypeContentTableViewCell = MenuTypeContentTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellContentIdentifier")
            newCell.content = tempContent
            newCell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, tempContent.getHeight()))
            newCell.selectionStyle = UITableViewCellSelectionStyle.None
            return newCell
            
        }
        
        cell.content = tempContent
        cell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, tempContent.getHeight()))
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = self.tableView.backgroundColor
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !self.showMenuType {
            return
        }
        self.showMenuType = !self.showMenuType
        self.setMenuHidden(true)
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if self.showMenuType {
            
            return 40
            
        }
        
        let tempContent = MenuContentModelRepresentation()
        tempContent.menuName = "AM Chicken Longganisa"
        tempContent.labelOption1 = "Ala Carte:"
        tempContent.labelOption2 = "Combo:"
        tempContent.labelOption3 = "Combo w/ Hashbrown:"
        tempContent.option1 = "PHP 90.00"
        tempContent.option2 = "PHP 95.00"
        tempContent.option3 = "100.00"
        return tempContent.getHeight()
    }
    
    
}

//MARK: - Registration Card View Controller
class RegistrationCardViewController : UIViewController {
    
    //MARK: Properties
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
   
    
    @IBAction func withCardClicked(sender: UIButton) {
        
        
        self.performSegueWithIdentifier("goToCardNumber", sender: nil)
        
        
    }
    
    
    @IBAction func withoutCardClicked(sender: UIButton) {
        
        
        self.performSegueWithIdentifier("goToMobileNumber", sender: nil)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
}


//MARK: - Registration Facebook View Controller
class RegistrationFacebookViewController : BaseViewController, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    var user: UserModelRepresentation?
    
    @IBOutlet var facebookButton: UIButton!

    //MARK: View life cycle
    override func viewDidLoad() {
        //self.facebookButton.delegate = self
        //self.facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Button Actions
    @IBAction func fbButtonClicked(sender: FBSDKLoginButton) {
        sender.enabled = false
        displayLoadingScreen()
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            } else {
                sender.enabled = true
                self.hideLoadingScreen()
                self.displayAlertWithError(error)
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result)
                    
                    if (FBSDKAccessToken.currentAccessToken() != nil) {
                        
                        let parametersDictionary = NSMutableDictionary()
                        parametersDictionary.setObject("id", forKey: "fields")
                        parametersDictionary.setObject("first_name, last_name, picture, email, gender", forKey: "fields")
                        let request = FBSDKGraphRequest(graphPath: "me", parameters: parametersDictionary as AnyObject as! [NSObject : AnyObject], HTTPMethod: "GET")
                        request.startWithCompletionHandler({ (connection, result, error) -> Void in
                            
                            self.hideLoadingScreen()
                            
                            let dictionaryResult = result as! NSDictionary
                            print(result)
                            
                            let dictionaryPicture = dictionaryResult["picture"] as! NSDictionary
                            let dictionaryData = dictionaryPicture["data"] as! NSDictionary
                            self.user?.profileImage = dictionaryData["url"] as! String
                            //self.user = nil
                            //self.user = UserModelRepresentation()
                            
                            self.user?.firstName = dictionaryResult["first_name"] as! String
                            self.user?.email = dictionaryResult["email"] as! String
                            self.user?.lastName = dictionaryResult["last_name"] as! String
                            self.user?.facebookID = dictionaryResult["id"] as! String
                            self.user?.gender = dictionaryResult["gender"] as! String
                            
                            self.performSegueWithIdentifier("goToForm", sender: nil)
                            
                            
                        })
                    } else {
                        self.btnSender!.enabled = true
                        self.hideLoadingScreen()
                    }
                } else {
                    self.btnSender!.enabled = true
                    self.hideLoadingScreen()
                    self.displayAlertWithError(error)
                }
            })
        } else {
            self.btnSender!.enabled = true
            self.hideLoadingScreen()
        }
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("goToForm", sender: nil)
    }
    
    //MARK: Facebook Delegate
    //FBSDKLoginButton Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        print(result.dictionaryWithValuesForKeys(["first_name", "last_name", "email"]))
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            let parametersDictionary = NSMutableDictionary()
            parametersDictionary.setObject("id", forKey: "fields")
            parametersDictionary.setObject("first_name, last_name, picture, email, gender", forKey: "fields")
            let request = FBSDKGraphRequest(graphPath: "me", parameters: parametersDictionary as AnyObject as! [NSObject : AnyObject], HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                
                
                let dictionaryResult = result as! NSDictionary
                print(result)
//                let dictionaryPicture = dictionaryResult["picture"] as! NSDictionary
//                let dictionaryData = dictionaryPicture["data"] as! NSDictionary
                
                //self.user = nil
                //self.user = UserModelRepresentation()
              
                self.user?.firstName = dictionaryResult["first_name"] as! String
                self.user?.email = dictionaryResult["email"] as! String
                self.user?.lastName = dictionaryResult["last_name"] as! String
                self.user?.facebookID = dictionaryResult["id"] as! String
                self.user?.gender = dictionaryResult["gender"] as! String
                
                self.performSegueWithIdentifier("goToForm", sender: nil)

                
            })
        }
//
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! RegsitrationFormViewController
        controller.user = self.user
    }
}
