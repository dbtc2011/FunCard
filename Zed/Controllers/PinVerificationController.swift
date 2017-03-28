//
//  PinVerificationController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 22/03/2017.
//  Copyright © 2017 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
        user.profileImage = self.user!.profileImage
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    private func callValidateCard() -> Void {
        
        let timeStamp = generateTimeStamp()
        
        let dictParams = NSMutableDictionary()
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
        dictParams["userId"] = userID
        dictParams["password"] = password
        dictParams["merchantId"] = merchantID
        dictParams["cardNumber"] = self.user!.cardNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        dictParams["msisdn"] = self.user!.mobileNumber
        dictParams["cardPin"] = self.user!.cardPin
        dictParams["channel"] = channel
        dictParams["requestTimezone"] = timezone
        dictParams["requestTimestamp"] = timeStamp
        
        print("Parameter = \(dictParams)")
        self.webService.connectAndValidateCardPinWithInfo(dictParams)
        
    
    }
    
    private func proceedSignup() {
        
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
        btnSender = sender
        if self.user!.cardPin != self.txtPinCode.text! {
            displayAlert("Pin code entered is incorrect.\nPlease try again.", title: "")
            
            sender.enabled = true
            
            return
        }
        
        if self.user!.cardNumber != "" {
            self.callValidateCard()
        }else {
            self.proceedSignup()
        }
        
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
            
        case WebServiceFor.ValidateCardPin.rawValue:
            
            self.btnSender!.enabled = true
            
            let status = parsedDictionary["Status"] as? String ?? ""
            let description = parsedDictionary["StatusDescription"] as? String ?? ""
            btnSender!.enabled = true
            if status == "0" {
                
                self.proceedSignup()
                
            }else {
                
//                displayAlertRequestError(status, descripion: description)
                
                self.dismissViewControllerAnimated(true, completion: { 
                    
                })
                
            }
            
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