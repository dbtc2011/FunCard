//
//  RegistrationCardController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 22/03/2017.
//  Copyright © 2017 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

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
            dictParams["cardNumber"] = self.txtCardNumber.text!.stringByReplacingOccurrencesOfString("-", withString: "")
            dictParams["msisdn"] = self.txtMobileNumber.text!
            dictParams["channel"] = channel
            dictParams["requestTimezone"] = timezone
            dictParams["requestTimestamp"] = timeStamp
            
            self.webService.connectAndRegisterWithInfo(dictParams)
            break
            
        case "240":
            
            //mobile number not found, proceed with reg
            let timeStamp = generateTimeStamp()
            
            let dictParams = NSMutableDictionary()
            dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
            dictParams["userId"] = userID
            dictParams["password"] = password
            dictParams["merchantId"] = merchantID
            dictParams["cardNumber"] = self.txtCardNumber.text!.stringByReplacingOccurrencesOfString("-", withString: "")
            dictParams["msisdn"] = self.txtMobileNumber.text!
            dictParams["channel"] = channel
            dictParams["requestTimezone"] = timezone
            dictParams["requestTimestamp"] = timeStamp
            
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
            
        default:
            btnSender!.enabled = true
            hideLoadingScreen()
            displayAlertRequestError(status, descripion: description)
            break
        }
    }
    
    private func callForgotPin (parsedDict: NSDictionary) {
        
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
    
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        let request = parsedDictionary["request"] as! String
        
        switch request {
        case  WebServiceFor.FunRegCol_Msisdn.rawValue:
            
            self.processRegColResponse(parsedDictionary)
            
            break
            
        case  WebServiceFor.Register.rawValue:
            
            let status = parsedDictionary["Status"] as! String
            
            
            
            if status == "0" {
                
                let cardPin = parsedDictionary["CardPin"] as! String
                print("cardpin: \(cardPin)")
                self.user.cardPin = cardPin
                
//                proceed
                self.performSegueWithIdentifier("goToPinVerification", sender: nil)
                
            }else if status == "77" {
                
                self.callForgotPin(parsedDictionary)
                
                
            }else {
                
                //failed
                let errorMessage = parsedDictionary["StatusDescription"] as! String
                
                btnSender!.enabled = true
                hideLoadingScreen()
                displayAlertRequestError(status, descripion: errorMessage)
                
            }
    
            break
            
        case WebServiceFor.ForgotPin.rawValue:
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
