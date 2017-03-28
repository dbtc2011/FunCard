//
//  RegistrationNumberController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 22/03/2017.
//  Copyright © 2017 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

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

