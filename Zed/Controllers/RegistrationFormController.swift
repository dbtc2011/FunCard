//
//  RegistrationFormController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 22/03/2017.
//  Copyright © 2017 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
        self.tableContents.addObject(pin)
        
        /*
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
        */
    }
    
    func getGenderForAPI(gender: String) -> String {
        
        if gender == "male" {
            return "M"
        }
        
        return "F"
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
        print("Value = \(self.tableContents[2]["value"] as! String)")
        dictParams["birthday"] = self.tableContents[2]["value"] as! String
        dictParams["gender"] = self.tableContents[3]["value"] as! String
        dictParams["address"] = self.tableContents[4]["value"] as! String
        dictParams["email"] = self.tableContents[5]["value"] as! String
        
        displayLoadingScreen()
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
        
        
        if self.user!.facebookID == "" {
            //no fb
            let dictParams = NSMutableDictionary()
            
            let date = (self.tableContents[2]["value"] as! String).stringByReplacingOccurrencesOfString("-", withString: "")
            dictParams["dateOfBirth"] = date
            print("Value date = \(self.tableContents[2]["value"] as! String)")
            dictParams["email"] = self.tableContents[5]["value"] as! String
            dictParams["firstName"] = self.tableContents[0]["value"] as! String
            dictParams["gender"] = self.getGenderForAPI((self.tableContents[3]["value"] as! String))
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
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("false", forKey: "identify_card")
            
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
            let status = parsedDictionary["STATUS"] as! String
            let errorMessage = parsedDictionary["DESCRIPTION"] as! String
            
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
            let status = parsedDictionary["STATUS"] as! String
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
