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

let userID = "7E177E8A450562B7B65F77881C817B47"
let password = "FDFE29DF7FF33EC5078B03F468B7A04C"
let merchantID = "581"
let timezone = "GMT+800"
let channel = "app"

func generateTransactionIDWithTimestamp(timeStamp: String) -> String {
    let trimmedTimeStamp = String(timeStamp.characters.filter { String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789.")) != nil })
    return "FUNAPP_\(trimmedTimeStamp)"
}

func generateTimeStamp() -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.stringFromDate(NSDate())
}

//MARK: - View Controller
class ViewController: UIViewController , UIScrollViewDelegate, WebServiceDelegate {
    
    //MARK: Properties
    var counter = 0
    let cardInfo: CardInfoView = CardInfoView()
    let header: PointHeaderView = PointHeaderView()
    
    var user: UserModelRepresentation?
    let webService = WebService()

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.blackColor()
        
        
        self.pageIndicator.enabled = false
        self.pageIndicator.numberOfPages = 8
        self.pageIndicator.currentPageIndicatorTintColor = UIColor.yellowColor()
        self.pageIndicator.pageIndicatorTintColor = UIColor.blueColor()
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        let buttonHeight = (self.view.frame.size.height * 0.45) - 45
        
        var xLocation = (self.view.frame.size.width/2) - (buttonHeight/2)
        
        for index in 1...8 {
            
            let imageName = "category" +  "\(index)"
            
            let button = UIButton(type: UIButtonType.Custom)
            button.tag = index
            button.frame = CGRectMake(xLocation, 15, buttonHeight, buttonHeight)
            button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
            //uncomment
            button.addTarget(self, action: #selector(ViewController.buttonsClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.scrollView.addSubview(button)
            
            xLocation = xLocation + self.view.frame.size.width
            
        }
        
        
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 8, 0)
        
        self.header.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.23)
        self.header.setupView()
        self.view.addSubview(self.header)
        
        self.cardInfo.frame = CGRectMake(10, self.view.frame.size.height - ((self.view.frame.size.height * 0.43) + 165 + 20), self.view.frame.size.width - 20, 155)
        
        if self.view.frame.size.height == 480 {
            self.cardInfo.frame = CGRectMake(10, self.view.frame.size.height - ((self.view.frame.size.height * 0.43) + 155 + 5), self.view.frame.size.width - 20, 135)
        }
        self.cardInfo.setupView()
        self.view.addSubview(self.cardInfo)
        
        
        self.webService.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.bringSubviewToFront(self.cardInfo)
        self.view.bringSubviewToFront(self.header)
        self.getDashboardInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Methods
    func goToSurvey() {
        
        let storyboard = UIStoryboard(name: "Survey", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("surveyController") as! SurveyViewController
        vc.user = self.user!
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func goToPulsify() {
        
        let storyboard = UIStoryboard(name: "Pulsify", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("pulsify")
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
        
        var mobileNumber = ""
        if self.user != nil {
            mobileNumber = self.user!.mobileNumber
        } else {
            //generate user from core data
        }
        
        let dictInfo = ["transactionId": transactionID,
                        "mobileNumber": mobileNumber]
        self.webService.connectAndGetDashboardInfo(dictInfo)
    }
    
    //MARK: Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        counter = (Int)(scrollView.contentOffset.x / self.view.frame.size.width)
        self.pageIndicator.currentPage = counter
    }
    
    //MARK: Button Actions
    func buttonsClicked(sender: UIButton) {
        
        if sender.tag == 1 {
            
        }else if sender.tag == 2 {
            
        }else if sender.tag == 3 {
            
        }else if sender.tag == 4 {
            self.goToPasaPoints()
        }else if sender.tag == 5 {
            
        }else if sender.tag == 6 {
            
        }else if sender.tag == 7 {
            self.goToPulsify()
        }else if sender.tag == 8 {
            self.goToSurvey()
        }
        
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
    }
    
    func webServiceDidTimeout() {
        print("timeout")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        print(error)
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

class RegsitrationFormViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, WebServiceDelegate {
    
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
            
            return cell
            
        }
        
        let cellIdentifier = "dateForm"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DateFormTableViewCell
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.viewLabelHolder.layer.cornerRadius = 10
        cell.viewContentHolder.layer.cornerRadius = 10
        cell.labelQuestion.text = dictionary["label"] as? String
        cell.labelContent.text = dictionary["value"] as? String
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTap:")
        cell.button.addTarget(self, action: "didTap:", forControlEvents: .TouchUpInside)
        cell.viewContentHolder.tag = indexPath.row
        cell.button.tag = indexPath.row
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
        self.webService.connectAndRegisterFbInfoWithInfo(dictParams)
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
        
        self.webService.connectAndValidateVirtualCardWithInfo(dictParams)
    }
    
    private func callRegisterWithCardAPI() -> Void {
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
    }
    
    private func callResendPinWithoutCardAPI() -> Void {
        //resend pin to the mobile number provided earlier
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["mobileNumber"] = self.user!.mobileNumber
        
        self.webService.connectAndRegisterVirtualCardWithInfo(dictParams)
    }
    
    private func callResendPinWithCardAPI() -> Void {
        //resend pin to the mobile number provided earlier
        let timeStamp = generateTimeStamp()
        
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
        dictParams["userId"] = userID
        dictParams["password"] = password
        dictParams["merchantId"] = merchantID
        dictParams["cardNumber"] = self.user!.cardNumber
        dictParams["msisdn"] = self.user!.mobileNumber
        dictParams["channel"] = channel
        dictParams["requestTimezone"] = timezone
        dictParams["requestTimestamp"] = timeStamp
        
        //print(dictParams)
        self.webService.connectAndRegisterWithInfo(dictParams)
    }
    
    //MARK: Button Actions

    @IBAction func saveButtonClicked(sender: UIButton) {
        //validate form here
        for content in self.tableContents {
            let dictionary = content as! NSMutableDictionary
            
            //print("Label: \(dictionary["label"] as! String) \(dictionary["value"] as! String)")
            if (dictionary["value"] as! String).characters.count == 0 {
                print("Error >>>> Incomplete form")
                return
            }
        }
        
        //identify if with/without pin
        if self.user!.cardPin.characters.count == 0 {
            self.callRegisterFBInfoAPI()
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
        
        print("resending...")
        //identify with or without card
        if self.user!.cardNumber.characters.count == 0 {
            //without card
            self.callResendPinWithoutCardAPI()
        } else {
            //with card
            self.callResendPinWithCardAPI()
        }
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
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main") as! ViewController
                vc.user = self.user!
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            print("error >>> \(description)")
            
            break
            
        case WebServiceFor.RegisterVirtualCard.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user!.cardPin = pinCode
                print(pinCode)
                print("resent!")
                
                return
            }
            
            print("error >>> \(description)")
            break
            
        case  WebServiceFor.Register.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["StatusDescription"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user!.cardPin = pinCode
                print(pinCode)
                print("resent!")
                
                return
            }
            
            print("error >>> \(errorMessage)")
            break
            
        case WebServiceFor.ValidateCardPin.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["StatusDescription"] as! String
            
            if status == "0" {
                //proceed with card registration
                self.callRegisterFBInfoAPI()
                
                return
            }
            
            print("error >>> \(errorMessage)")
            break
            
        case WebServiceFor.RegisterFbInfo.rawValue:
            let status = parsedDictionary["Status"] as! String
            let errorMessage = parsedDictionary["StatusDescription"] as! String
            
            if status == "0" {
                //proceed to dashboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("main")
                self.presentViewController(vc, animated: true, completion: nil)
                
                return
            }
            
            print("error >>> \(errorMessage)")
            break
            
        default:
            break
        }
    }
    
    func webServiceDidTimeout() {
        print("timeout")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        print(error)
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
class RegistrationMobileNumberViewController : UIViewController, WebServiceDelegate {
    
    //MARK: Properties
    let user = UserModelRepresentation()
    let webService = WebService()
    
    @IBOutlet weak var textNumber: UITextField!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: IBAction Delegate
    @IBAction func buttonClicked(sender: UIButton) {
        
        let number = self.textNumber.text!
        
        if number.hasPrefix("639") == false {
            print("incorrect format")
            //alert
            
            return
        }
        
        sender.enabled = false
        self.user.mobileNumber = number
        self.webService.connectAndCheckMsisdnWithMsisdn(number)
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        let request = parsedDictionary["request"] as! String
        
        switch(request) {
        case WebServiceFor.CheckMsisdn.rawValue:
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
            }
            
            break
            
        case WebServiceFor.RegisterVirtualCard.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                //proceed with registration
                let pinCode = parsedDictionary["PIN"] as! String
                self.user.cardPin = pinCode
                print(pinCode)
                
                self.performSegueWithIdentifier("goToConnectToFacebook", sender: nil)
                return
            }
            
            print("error >>> \(description)")
            
            break
            
        default:
            break
        }
    }
    
    func webServiceDidTimeout() {
        print("timeout")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        print(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
    }
}

//MARK: - Registration Card Number View Controller
class RegistrationCardNumberViewController : UIViewController, WebServiceDelegate {
    
    //MARK: Properties
    let user = UserModelRepresentation()
    let webService = WebService()
    
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: IBAction Delegate
    @IBAction func buttonClicked(sender: UIButton) {
        let mobileNumber = self.txtMobileNumber.text!
        
        if mobileNumber.hasPrefix("639") == false {
            print("incorrect format")
            //alert
            
            return
        }
        
        sender.enabled = false
        
        self.user.cardNumber = self.txtCardNumber.text!
        self.user.mobileNumber = mobileNumber
        self.webService.connectAndCheckMsisdnWithMsisdn(mobileNumber)
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        let request = parsedDictionary["request"] as! String
        
        switch request {
        case  WebServiceFor.CheckMsisdn.rawValue:
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
            
            break
            
        case  WebServiceFor.Register.rawValue:
            let status = parsedDictionary["Status"] as! String
            
            if status != "0" {
                //failed
                let errorMessage = parsedDictionary["StatusDescription"] as! String
                print("error >>>> \(errorMessage)")
                
                return
            }
            
            let cardPin = parsedDictionary["CardPin"] as! String
            print("cardpin: \(cardPin)")
            self.user.cardPin = cardPin
            
            //proceed
            self.performSegueWithIdentifier("goToPinVerification", sender: nil)
            
            break
            
        default:
            break
        }
        
    }
    
    func webServiceDidTimeout() {
        print("timeout")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        print(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
    }
}

//MARK: - Pin Verification View Controller
class PinVerificationViewController : UIViewController, WebServiceDelegate {
    
    //MARK: Properties
    let webService = WebService()
    var user: UserModelRepresentation?
    
    @IBOutlet weak var txtPinCode: UITextField!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: IBAction Delegate
    @IBAction func didPressOkay(sender: UIButton) {
        if self.txtPinCode.text!.characters.count == 0 {
            print("invalid input")
            //alert
            
            return
        }
        
        sender.enabled = false
        
        if self.user!.cardPin != self.txtPinCode.text! {
            print("incorrect pin")
            //alert
            
            sender.enabled = true
            
            return
        }
        
        //proceed
        self.performSegueWithIdentifier("goToConnectToFacebook", sender: self)
    }
    
    @IBAction func didPressResend(sender: UIButton) {
        sender.enabled = false
        
        //resend pin to the mobile number provided earlier
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(generateTimeStamp())
        dictParams["mobileNumber"] = self.user!.mobileNumber
        
        self.webService.connectAndRegisterVirtualCardWithInfo(dictParams)
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        let request = parsedDictionary["request"] as! String
        
        switch(request) {
        case WebServiceFor.RegisterVirtualCard.rawValue:
            let status = parsedDictionary["STATUS"] as! String
            let description = parsedDictionary["DESCRIPTION"] as! String
            
            if status == "0" {
                let pinCode = parsedDictionary["PIN"] as! String
                self.user!.cardPin = pinCode
                print(pinCode)
                print("resent!")
                
                return
            }
            
            print("error >>> \(description)")
            break
            
        default:
            break
        }
    }
    
    func webServiceDidTimeout() {
        print("timeout")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        print(error)
    }
    
    //MARK: NavigationController Delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(self.user, forKey: "user")
    }
}

//MARK: - Registration Facebook View Controller
class RegistrationFacebookViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    var user: UserModelRepresentation?
    
    @IBOutlet var facebookButton: FBSDKLoginButton!

    //MARK: View life cycle
    override func viewDidLoad() {
        self.facebookButton.delegate = self
        self.facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Button Actions
    @IBAction func fbButtonClicked(sender: FBSDKLoginButton) {
        
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
