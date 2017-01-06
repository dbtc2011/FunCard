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
            self.alertView = CustomAlertView(frame: self.view.frame)
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
        self.displayAlert("\(error.code): \(error.localizedDescription)",
                          title: "Internal Error")
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

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.header.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        let status = parsedDictionary["STATUS"] as! String
        let description = parsedDictionary["DESCRIPTION"] as! String
        
        if status == "0" {
            self.user!.points = parsedDictionary["TOTALPOINTS"] as! String
            self.user!.cardNumber = parsedDictionary["PRIMARYCARDNUMBER"] as! String
            
            if parsedDictionary["LinkedCards"] != nil {
                let cards = parsedDictionary["LinkedCards"] as! NSArray
                
                for card in cards {
                    let index = cards.indexOfObject(card)
                    
                    switch index {
                    case 0:
                        self.user!.cardNumber2 = card["CARDNUMBER"] as! String
                        
                        var cardNumber2 = ""
                        for char in self.user!.cardNumber2.characters {
                            cardNumber2.append(char)
                            
                            let strForComparison = cardNumber2.stringByReplacingOccurrencesOfString("-", withString: "")
                            if strForComparison.characters.count%4 == 0 && cardNumber2.characters.count < 19 {
                                cardNumber2 += "-"
                            }
                        }
                        
                        self.cardInfo.labelCard2.text = cardNumber2
                        
                        break
                    case 1:
                        self.user!.cardNumber3 = card["CARDNUMBER"] as! String
                        
                        var cardNumber3 = ""
                        for char in self.user!.cardNumber3.characters {
                            cardNumber3.append(char)
                            
                            let strForComparison = cardNumber3.stringByReplacingOccurrencesOfString("-", withString: "")
                            if strForComparison.characters.count%4 == 0 && cardNumber3.characters.count < 19 {
                                cardNumber3 += "-"
                            }
                        }
                        
                        self.cardInfo.labelCard3.text = cardNumber3
                        
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

//MARK: - Registration Form View Controller
import ActionSheetPicker_3_0

class RegsitrationFormViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, WebServiceDelegate {
    
    //MARK: Properties
    let webService = WebService()
    var user: UserModelRepresentation?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnResend: UIButton!
    
    var tableContents: NSMutableArray = NSMutableArray()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
        
        self.tableView.scrollEnabled = false
        self.tableView.backgroundColor = UIColor.clearColor()
        self.presetValues()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.user != nil {
            
            let firstName = self.tableContents[0] as! NSMutableDictionary
            firstName.setObject(self.user!.firstName, forKey: "value")
            
            let lastName = self.tableContents[1] as! NSMutableDictionary
            lastName.setObject(self.user!.lastName, forKey: "value")
            
            let gender = self.tableContents[3] as! NSMutableDictionary
            gender.setObject(self.user!.gender, forKey: "value")
            
            let email = self.tableContents[5] as! NSMutableDictionary
            email.setObject(self.user!.email, forKey: "value")
            
            
            self.tableContents.replaceObjectAtIndex(0, withObject: firstName)
            self.tableContents.replaceObjectAtIndex(1, withObject: lastName)
            self.tableContents.replaceObjectAtIndex(3, withObject: gender)
            self.tableContents.replaceObjectAtIndex(5, withObject: email)
            
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: Method
    func presetValues() {
        
        let firstName = NSMutableDictionary()
        firstName.setObject("First Name:", forKey: "label")
        firstName.setObject("", forKey: "value")
        firstName.setObject("text", forKey: "type")
        
        let lastName = NSMutableDictionary()
        lastName.setObject("Last Name:", forKey: "label")
        lastName.setObject("", forKey: "value")
        lastName.setObject("text", forKey: "type")
        
        let birthdate = NSMutableDictionary()
        birthdate.setObject("Birth Date:", forKey: "label")
        birthdate.setObject("", forKey: "value")
        birthdate.setObject("date", forKey: "type")
        birthdate.setObject("image_name", forKey: "button_icon")
        
        let gender = NSMutableDictionary()
        gender.setObject("Gender:", forKey: "label")
        gender.setObject("", forKey: "value")
        gender.setObject("gender", forKey: "type")
        gender.setObject("image_name", forKey: "button_icon")
        
        let address = NSMutableDictionary()
        address.setObject("Address:", forKey: "label")
        address.setObject("", forKey: "value")
        address.setObject("text", forKey: "type")
        
        let email = NSMutableDictionary()
        email.setObject("Email:", forKey: "label")
        email.setObject("", forKey: "value")
        email.setObject("text", forKey: "type")
        
        let pin = NSMutableDictionary()
        pin.setObject("Pin Code:", forKey: "label")
        pin.setObject("", forKey: "value")
        pin.setObject("text", forKey: "type")
        
        self.tableContents.addObject(firstName)
        self.tableContents.addObject(lastName)
        self.tableContents.addObject(birthdate)
        self.tableContents.addObject(gender)
        self.tableContents.addObject(address)
        self.tableContents.addObject(email)
        
        if self.user!.cardPin.characters.count > 0 {
            
            if self.user!.cardNumber.characters.count == 0 {
                self.tableContents.addObject(pin)
            } else {
                //hide resend pin button
                self.btnResend.hidden = true
            }
        } else {
            //hide resend pin button
            self.btnResend.hidden = true
        }
    }
    
    //MARK: Delegate
    //MARK: Tableview
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tableContents.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let dictionary = self.tableContents[indexPath.row] as! NSMutableDictionary
        
        if dictionary["type"] as? String == "text" {
            
            let cellIdentifier = "textForm"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextFormTableViewCell
            
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.labelContent.text = dictionary["label"] as? String
            //\cell.textContent.placeholder = dictionary["label"] as? String
            cell.textContent.text = dictionary["value"] as? String
            cell.textContent.delegate = self
            cell.labelContent.backgroundColor = UIColor.clearColor()
            cell.textContent.delegate = self
            cell.textContent.tag = indexPath.row
            cell.viewTextHolder.layer.cornerRadius = 10
            cell.viewLabelHolder.layer.cornerRadius = 10
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.layer.cornerRadius = 3.0
            
            return cell
            
        }
        
        let cellIdentifier = "dateForm"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DateFormTableViewCell
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.viewLabelHolder.layer.cornerRadius = 10
        cell.viewContentHolder.layer.cornerRadius = 10
        cell.labelQuestion.text = dictionary["label"] as? String
        cell.labelContent.text = dictionary["value"] as? String
        
        if (dictionary["type"] as? String) == "gender" {
            cell.button.setImage(UIImage(named: "dropdown"), forState: .Normal)
        }
        
        //uncomment
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegsitrationFormViewController.didTap(_:)))
        cell.button.addTarget(self, action: #selector(RegsitrationFormViewController.didTap(_:)), forControlEvents: .TouchUpInside)
        cell.viewContentHolder.tag = indexPath.row
        cell.button.tag = indexPath.row
        //uncomment
        cell.viewContentHolder.addGestureRecognizer(tapGestureRecognizer)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func didTap(sender: AnyObject) -> Void {
        //print("tap")
        
        var tag = 0
        
        if sender.isKindOfClass(UIButton.classForCoder()) {
            //button
            tag = sender.tag
        } else {
            //gesture
            let gesture = sender as! UITapGestureRecognizer
            let gestureView = gesture.view!
            
            tag = gestureView.tag
        }
        
        let dictionary = self.tableContents[tag] as! NSMutableDictionary
        let type = dictionary["type"] as! String
        
        switch type {
        case "date":
            //birthday
            ActionSheetDatePicker.showPickerWithTitle("", datePickerMode: .Date, selectedDate: NSDate(), doneBlock: { (picker, date, view) -> Void in
                //print(date)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let strDate = dateFormatter.stringFromDate(date as! NSDate)
                
                dictionary.setObject(strDate, forKey: "value")
                self.tableContents.replaceObjectAtIndex(tag, withObject: dictionary)
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: tag, inSection: 0)], withRowAnimation: .Fade)
                
                }, cancelBlock: { (picker) -> Void in
                    print("cancel")
                }, origin: self.view)
            
            break
            
        case "gender":
            //gender
            let genders = ["male","female"]
            
            ActionSheetStringPicker.showPickerWithTitle("", rows: genders, initialSelection: 0, doneBlock: { (picker, index, value) -> Void in
                //print(index)
                // print(value)
                
                dictionary.setObject(value, forKey: "value")
                self.tableContents.replaceObjectAtIndex(tag, withObject: dictionary)
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: tag, inSection: 0)], withRowAnimation: .Fade)
                
                }, cancelBlock: { (picker) -> Void in
                    print("cancel")
                }, origin: self.view)
            
            break
            
        default:
            break
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    //MARK: TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textNSString = textField.text! as NSString
        
        let text = textNSString.stringByReplacingCharactersInRange(range, withString: string)
        
        let dictionary = self.tableContents[textField.tag] as! NSMutableDictionary
        dictionary.setObject(text, forKey: "value")
        self.tableContents.replaceObjectAtIndex(textField.tag, withObject: dictionary)
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    //MARK: API Calls
    
    private func callRegisterFBInfoAPI() -> Void {
        let dictParams = NSMutableDictionary()
        dictParams["facebookId"] = self.user!.facebookID
        dictParams["firstName"] = self.tableContents[0]["value"] as! String
        dictParams["lastName"] = self.tableContents[1]["value"] as! String
        dictParams["middleName"] = " "
        dictParams["birthday"] = self.tableContents[2]["value"] as! String
        dictParams["address"] = self.tableContents[4]["value"] as! String
        dictParams["email"] = self.tableContents[5]["value"] as! String
        dictParams["msisdn"] = self.user!.mobileNumber
        
        //print(dictParams)
        displayLoadingScreen()
        self.webService.connectAndRegisterFbInfoWithInfo(dictParams)
    }
    
    private func callUpdateFBInfoAPI() -> Void {
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["msisdn"] = self.user!.mobileNumber
        dictParams["firstName"] = self.tableContents[0]["value"] as! String
        dictParams["middleName"] = " "
        dictParams["lastName"] = self.tableContents[1]["value"] as! String
        dictParams["gender"] = self.tableContents[3]["value"] as! String
        dictParams["birthday"] = self.tableContents[2]["value"] as! String
        dictParams["email"] = self.tableContents[5]["value"] as! String
        dictParams["address"] = self.tableContents[4]["value"] as! String
        
        //print(dictParams)
        displayLoadingScreen()
        self.webService.connectAndUpdateFbInfoWithInfo(dictParams)
    }
    
    private func callRegisterWithoutCardAPI() -> Void {
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["mobileNumber"] = self.user!.mobileNumber
        dictParams["cardPin"] = self.tableContents[6]["value"] as! String
        dictParams["facebookId"] = self.user!.facebookID
        dictParams["lastName"] = self.tableContents[1]["value"] as! String
        dictParams["firstName"] = self.tableContents[0]["value"] as! String
        dictParams["secondName"] = " "
        dictParams["birthday"] = self.tableContents[2]["value"] as! String
        dictParams["gender"] = self.tableContents[3]["value"] as! String
        dictParams["address"] = self.tableContents[4]["value"] as! String
        dictParams["email"] = self.tableContents[5]["value"] as! String
        
        displayLoadingScreen()
        self.webService.connectAndValidateVirtualCardWithInfo(dictParams)
    }
    
    private func callRegisterWithCardAPI() -> Void {
        /*
        let timeStamp = generateTimeStamp()
        
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
        dictParams["userId"] = userID
        dictParams["password"] = password
        dictParams["merchantId"] = merchantID
        dictParams["cardNumber"] = self.user!.cardNumber
        dictParams["msisdn"] = self.user!.mobileNumber
        dictParams["cardPin"] = self.user!.cardPin
        dictParams["channel"] = channel
        dictParams["requestTimezone"] = timezone
        dictParams["requestTimestamp"] = timeStamp
        
        self.webService.connectAndValidateCardPinWithInfo(dictParams)
        */
        
        if self.user!.facebookID == "" {
            //no fb
            let dictParams = NSMutableDictionary()
            dictParams["dateOfBirth"] = self.tableContents[2]["value"] as! String
            dictParams["email"] = self.tableContents[5]["value"] as! String
            dictParams["firstName"] = self.tableContents[0]["value"] as! String
            dictParams["gender"] = self.tableContents[3]["value"] as! String
            dictParams["lastName"] = self.tableContents[1]["value"] as! String
            
            displayLoadingScreen()
            self.webService.connectAndMemberEmailWithInfo(dictParams)
            
            return
        }
        
        //with fb
        self.callRegisterFBInfoAPI()
    }
    
    private func callResendPin() -> Void {
        //resend pin to the mobile number provided earlier
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["mobileNumber"] = self.user!.mobileNumber
        
        displayLoadingScreen()
        self.webService.connectAndForgotPinWithInfo(dictParams)
    }
    
    private func saveUserToCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! User
        
        user.setValue("1", forKey: "userId")
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            user.setValue("\(results.count+1)", forKey: "userId")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        user.facebookId = self.user!.facebookID
        user.profileImage = self.user!.profileImage
        user.firstName = self.tableContents[0]["value"] as? String
        user.lastName = self.tableContents[1]["value"] as? String
        user.gender = self.tableContents[3]["value"] as? String
        user.birthday = self.tableContents[2]["value"] as? String
        user.address = self.tableContents[4]["value"] as? String
        user.email = self.tableContents[5]["value"] as? String
        user.points = "0.00"
        user.cardNumber1 = self.user!.cardNumber
        user.cardNumber2 = "---"
        user.cardNumber3 = "---"
        user.lastTransactionDate = "---"
        user.lastPointsPasa = "---"
        user.lastPointsRedeemed = "---"
        user.lastPointsEarned = "---"
        user.mobileNumber = self.user!.mobileNumber
        user.isLoggedIn = true
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Button Actions

    @IBAction func saveButtonClicked(sender: UIButton) {
        //validate form here
        for content in self.tableContents {
            let dictionary = content as! NSMutableDictionary
            
            //print("Label: \(dictionary["label"] as! String) \(dictionary["value"] as! String)")
            if (dictionary["value"] as! String).characters.count == 0 {
                displayAlertValidationError()
                return
            }
        }
        
        sender.enabled = false
        btnSender = sender
        
        //identify if with/without pin
        if self.user!.cardPin.characters.count == 0 {
            self.callRegisterWithCardAPI()
            return
        }
        
        //identify with or without card
        if self.user!.cardNumber.characters.count == 0 {
            //without card
            self.callRegisterWithoutCardAPI()
        } else {
            //with card
            self.callRegisterWithCardAPI()
        }
    }
    
    @IBAction func resendButtonClicked(sender: UIButton) {
        sender.enabled = false
        btnSender = sender
        
        print("resending...")
        self.callResendPin()
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        let request = parsedDictionary["request"] as! String
        
        switch(request) {
        case WebServiceFor.ValidateVirtualCard.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                hideLoadingScreen()
                
                //save to core data
                self.saveUserToCoreData()
                /*
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main") as! ViewController
                */
                let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("navigationView") as! FunNavigationController
                vc.user = self.user!
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            
            break
            
        case WebServiceFor.ForgotPin.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            self.btnSender!.enabled = true
            hideLoadingScreen()
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user!.cardPin = pinCode
                print(pinCode)
                
                displayAlert("Pin code has been successfully resent!", title: "")
                
                return
            }
            
            btnSender!.enabled = true
            displayAlertRequestError(status, descripion: description)
            break
        
        case WebServiceFor.FunMember_Email.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["Description"] as! String
            
            if status == "0" {
                //proceed with updateFbInfo
                self.callUpdateFBInfoAPI()
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: errorMessage)
            
            break
            
        case WebServiceFor.RegisterFbInfo.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["StatusDescription"] as! String
            
            if status == "0" {
                self.hideLoadingScreen()
                
                self.saveUserToCoreData()
                /*
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main")
                */
                let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("navigationView") as! FunNavigationController
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: errorMessage)
            
            break
            
        case WebServiceFor.UpdateFbInfo.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["StatusDescription"] as! String
            
            if status == "0" {
                self.hideLoadingScreen()
                
                //save to core data here
                self.saveUserToCoreData()
                /*
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main")
                 */
                let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("navigationView") as! FunNavigationController
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: errorMessage)
            
            break
            
        default:
            break
        }
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
    }
    
    func webServiceDidTimeout() {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertTimedOut("Unable to proceed with registration.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertWithError(error)
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

//MARK: - Registration Mobile Number View Controller
class RegistrationMobileNumberViewController : BaseViewController, WebServiceDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    let user = UserModelRepresentation()
    let webService = WebService()
    
    @IBOutlet var viewHolderMobileNumber: UIView!
    @IBOutlet var viewHolderLabel: UIView!
    @IBOutlet weak var textNumber: UITextField!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewHolderMobileNumber.layer.cornerRadius = 5.0
        self.viewHolderLabel.layer.cornerRadius = 5.0
    }
    
    //MARK: IBAction Delegate
    @IBAction func buttonClicked(sender: UIButton) {
        
        self.textNumber.resignFirstResponder()
        let number = self.textNumber.text!
        
        if number.hasPrefix("639") == false || number.characters.count != 12 || Int(number) < 0 {
            displayAlert("Please make sure that the mobile number you have entered is correct.",
                         title: "Validation Error")
            
            return
        }
        
        sender.enabled = false
        btnSender = sender
        
        self.user.mobileNumber = number
        
        //connect to web service
        displayLoadingScreen()
        self.webService.connectAndRegColMsisdnWithMsisdn(number)
    }
    
    //MARK: Methods
    private func processRegColResponse(parsedDict: NSDictionary) {
        let status = parsedDict["Status"] as! String
        let description = parsedDict["Description"] as! String
        
        switch (status) {
        case "3":
            //mobile number not found, proceed with reg
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
            dictParams["mobileNumber"] = self.textNumber.text!
            
            self.webService.connectAndRegisterVirtualCardWithInfo(dictParams)
            break
            
        case "24":
            //mobile number found with profile, proceed to forgotpin
            self.user.address = parsedDict["Address"] as! String
            self.user.birthday = parsedDict["Birthday"] as! String
            self.user.email = parsedDict["Email"] as! String
            self.user.firstName = parsedDict["FirstName"] as! String
            self.user.gender = parsedDict["Gender"] as! String
            self.user.lastName = parsedDict["LastName"] as! String
            self.user.middleName = parsedDict["MiddleName"] as! String
            self.user.cardNumber = parsedDict["PrimaryCardNumber"] as! String
            
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
            dictParams["mobileNumber"] = self.textNumber.text!
            
            self.webService.connectAndForgotPinWithInfo(dictParams)
            break
            
        case "240":
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
            dictParams["mobileNumber"] = self.textNumber.text!
            
            self.webService.connectAndForgotPinWithInfo(dictParams)
            break
            
        default:
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            break
        }
    }
    
    //MARK: UITextfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        let request = parsedDictionary["request"] as! String
        
        switch(request) {
        case WebServiceFor.FunRegCol_Msisdn.rawValue:
            self.processRegColResponse(parsedDictionary)
            
            /*
            let isRegistered = parsedDictionary["IsRegistered"] as! String
            
            if isRegistered == "YES" {
                //let cardNumber = parsedDictionary["CardNumber"] as! String
                let facebookID = parsedDictionary["FacebookId"] as? String
                //print("cardnumber: \(cardNumber)\nfacebookid: \(facebookID)")
                
                if facebookID?.characters.count == 0 || facebookID == nil {
                    //proceed with registration
                    self.performSegueWithIdentifier("goToConnectToFacebook", sender: nil)
                    return
                }
                
                let cardNumber = parsedDictionary["CardNumber"] as? String
                self.user.facebookID = facebookID!
                self.user.cardNumber = cardNumber!
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main") as! ViewController
                vc.user = self.user
                
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                //send pin to the indicated mobile number
                let dictParams = NSMutableDictionary()
                dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
                dictParams["mobileNumber"] = self.textNumber.text!
                
                self.webService.connectAndRegisterVirtualCardWithInfo(dictParams)
            }*/
            
            break
            
        case WebServiceFor.ForgotPin.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user.cardPin = pinCode
                print(pinCode)
                
                var segueId = ""
                if self.user.firstName == "" { //means the user has no profile yet
                    //go to selection options
                    segueId = "goToConnectToFacebook"
                } else {
                    //go to enter pin
                    segueId = "goToPinVerification"
                }
                
                self.performSegueWithIdentifier(segueId, sender: nil)
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            
            break
            
        case WebServiceFor.RegisterVirtualCard.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user.cardPin = pinCode
                print(pinCode)
                
                self.performSegueWithIdentifier("goToConnectToFacebook", sender: nil)
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            
            break
            
        default:
            break
        }
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
        
    }
    
    func webServiceDidTimeout() {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertTimedOut("Unable to proceed with registration.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertWithError(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
    }
}

//MARK: - Registration Card Number View Controller
class RegistrationCardNumberViewController : BaseViewController, WebServiceDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    let user = UserModelRepresentation()
    let webService = WebService()
    
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet var viewHolderCardNumber: UIView!
    @IBOutlet var viewHolderMobileNumber: UIView!
    @IBOutlet var viewHolderCardNumberLabel: UIView!
    @IBOutlet var viewHolderMobileNumberLabel: UIView!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewHolderCardNumber.layer.cornerRadius = 5.0
        self.viewHolderCardNumberLabel.layer.cornerRadius = 5.0
        self.viewHolderMobileNumber.layer.cornerRadius = 5.0
        self.viewHolderMobileNumberLabel.layer.cornerRadius = 5.0
    }
    
    //MARK: IBAction Delegate
    @IBAction func buttonClicked(sender: UIButton) {
        self.view.endEditing(true)
        let mobileNumber = self.txtMobileNumber.text!
        
        if mobileNumber.hasPrefix("639") == false || mobileNumber.characters.count != 12 || Int(mobileNumber) < 0 || self.txtCardNumber.text!.characters.count < 19 {
            displayAlertValidationError()
            
            return
        }
        
        sender.enabled = false
        btnSender = sender
        
        self.user.cardNumber = self.txtCardNumber.text!
        self.user.mobileNumber = mobileNumber
        
        //connect to web service
        displayLoadingScreen()
        self.webService.connectAndRegColMsisdnWithMsisdn(mobileNumber)
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtMobileNumber {
            return true
        }
        
        let text = textField.text! + string
        let charCount = text.characters.count
        
        if string.characters.count == 0 {
            if charCount%5 == 0 {
                textField.text = textField.text!.substringToIndex(textField.text!.endIndex.predecessor())
            }
            return true
        }
        
        if charCount == 0 {
            return true
        }
        
        if charCount == 20 {
            return false
        }
        
        let dashCount = charCount/4
        if (charCount-dashCount)%4 == 0 {
            textField.text = textField.text! + "-"
        }
        
        return true
    }
    
    
    //MARK: Methods
    private func processRegColResponse(parsedDict: NSDictionary) {
        let status = parsedDict["Status"] as! String
        let description = parsedDict["Description"] as! String
        
        switch (status) {
        case "3":
            //mobile number not found, proceed with reg
            let timeStamp = generateTimeStamp()
            
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
            dictParams["userId"] = userID
            dictParams["password"] = password
            dictParams["merchantId"] = merchantID
            dictParams["cardNumber"] = self.txtCardNumber.text!
            dictParams["msisdn"] = self.txtMobileNumber.text!
            dictParams["channel"] = channel
            dictParams["requestTimezone"] = timezone
            dictParams["requestTimestamp"] = timeStamp
            
            //print(dictParams)
            self.webService.connectAndRegisterWithInfo(dictParams)
            break
            
        case "24":
            //mobile number found with profile, proceed to forgotpin
            self.user.address = parsedDict["Address"] as! String
            self.user.birthday = parsedDict["Birthday"] as! String
            self.user.email = parsedDict["Email"] as! String
            self.user.firstName = parsedDict["FirstName"] as! String
            self.user.gender = parsedDict["Gender"] as! String
            self.user.lastName = parsedDict["LastName"] as! String
            self.user.middleName = parsedDict["MiddleName"] as! String
            self.user.cardNumber = parsedDict["PrimaryCardNumber"] as! String
            
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
            dictParams["mobileNumber"] = self.txtMobileNumber.text!
            
            self.webService.connectAndForgotPinWithInfo(dictParams)
            break
            
        case "240":
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
            dictParams["mobileNumber"] = self.txtMobileNumber.text!
            
            self.webService.connectAndForgotPinWithInfo(dictParams)
            break
            
        default:
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            break
        }
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        let request = parsedDictionary["request"] as! String
        
        switch request {
        case  WebServiceFor.FunRegCol_Msisdn.rawValue:
            /*
            let isRegistered = parsedDictionary["IsRegistered"] as! String
            
            if isRegistered == "YES" {
                //let cardNumber = parsedDictionary["CardNumber"] as! String
                let facebookID = parsedDictionary["FacebookId"] as? String
                //print("cardnumber: \(cardNumber)\nfacebookid: \(facebookID)")
                
                if facebookID?.characters.count == 0 || facebookID == nil {
                    //proceed with registration
                    self.performSegueWithIdentifier("goToConnectToFacebook", sender: nil)
                    return
                }
                
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main")
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            //proceed with registration
            let timeStamp = generateTimeStamp()
            
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
            dictParams["userId"] = userID
            dictParams["password"] = password
            dictParams["merchantId"] = merchantID
            dictParams["cardNumber"] = self.txtCardNumber.text!
            dictParams["msisdn"] = self.txtMobileNumber.text!
            dictParams["channel"] = channel
            dictParams["requestTimezone"] = timezone
            dictParams["requestTimestamp"] = timeStamp
            
            //print(dictParams)
            self.webService.connectAndRegisterWithInfo(dictParams)
            */
            self.processRegColResponse(parsedDictionary)
            
            break
            
        case  WebServiceFor.Register.rawValue:
            let status = parsedDictionary["Status"] as! String
            
            if status != "0" && status != "77" {
                //failed
                let errorMessage = parsedDictionary["StatusDescription"] as! String
                
                btnSender!.enabled = true
                hideLoadingScreen()
                displayAlertRequestError(status, descripion: errorMessage)
                
                return
            }
            
            let cardPin = parsedDictionary["CardPin"] as! String
            print("cardpin: \(cardPin)")
            self.user.cardPin = cardPin
            
            //proceed
            self.performSegueWithIdentifier("goToPinVerification", sender: nil)
            
            break
            
        case WebServiceFor.ForgotPin.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user.cardPin = pinCode
                print(pinCode)
                
                self.performSegueWithIdentifier("goToPinVerification", sender: nil)
                
                return
            }
            
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            
            break
            
        default:
            break
        }
        
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
        
    }
    
    func webServiceDidTimeout() {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertTimedOut("Unable to proceed with registration.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertWithError(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
    }
}

//MARK: - Pin Verification View Controller
class PinVerificationViewController : BaseViewController, WebServiceDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    let webService = WebService()
    var user: UserModelRepresentation?
    
    @IBOutlet weak var txtPinCode: UITextField!
    @IBOutlet var viewCenter: UIView!
    @IBOutlet var viewTextfield: UIView!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewCenter.layer.cornerRadius = 5.0
        self.viewTextfield.layer.cornerRadius = 5.0
    }
    
    //MARK: Methods
    private func saveUserToCoreData() {
        displayLoadingScreen()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! User
        
        user.setValue("1", forKey: "userId")
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            user.setValue("\(results.count+1)", forKey: "userId")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        user.facebookId = self.user!.facebookID
        user.firstName = self.user!.firstName
        user.lastName = self.user!.lastName
        user.gender = self.user!.gender
        user.birthday = self.user!.birthday
        user.address = self.user!.address
        user.email = self.user!.email
        user.mobileNumber = self.user!.mobileNumber
        user.isLoggedIn = true
        user.points = "0.00"
        user.cardNumber1 = self.user!.cardNumber
        user.cardNumber2 = "---"
        user.cardNumber3 = "---"
        user.lastTransactionDate = "---"
        user.lastPointsPasa = "---"
        user.lastPointsRedeemed = "---"
        user.lastPointsEarned = "---"
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //MARK: UITextfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: IBAction Delegate
    @IBAction func didPressOkay(sender: UIButton) {
        if self.txtPinCode.text!.characters.count == 0 {
            displayAlertValidationError()
            
            return
        }
        
        sender.enabled = false
        
        if self.user!.cardPin != self.txtPinCode.text! {
            displayAlert("Pin code entered is incorrect.\nPlease try again.", title: "")
            
            sender.enabled = true
            
            return
        }
        
        //proceed
        if self.user!.firstName != "" { //means the user has profile already
            //save to core data
            self.saveUserToCoreData()
            
            /*
            //proceed to dashboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("main") as! ViewController
            vc.user = self.user
            
            self.presentViewController(vc, animated: true, completion: nil)
            */
            
            hideLoadingScreen()
            
            let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("navigationView") as! FunNavigationController
            self.presentViewController(vc, animated: true, completion: nil)
            
            return
        }
        
        self.performSegueWithIdentifier("goToConnectToFacebook", sender: self)
    }
    
    @IBAction func didPressResend(sender: UIButton) {
        sender.enabled = false
        btnSender = sender
        
        //resend pin to the mobile number provided earlier
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["mobileNumber"] = self.user!.mobileNumber
        
        displayLoadingScreen()
        self.webService.connectAndForgotPinWithInfo(dictParams)
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        let request = parsedDictionary["request"] as! String
        
        switch(request) {
        case WebServiceFor.ForgotPin.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            self.btnSender!.enabled = true
            hideLoadingScreen()
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user!.cardPin = pinCode
                print(pinCode)
                
                displayAlert("Pin code has been successfully resent!", title: "")
                
                return
            }
            
            btnSender!.enabled = true
            displayAlertRequestError(status, descripion: description)
            break
            
        default:
            break
        }
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
        
    }
    
    func webServiceDidTimeout() {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertTimedOut("Unable to proceed with registration.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertWithError(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
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
