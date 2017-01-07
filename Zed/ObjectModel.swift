//
//  ObjectModel.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//MARK: - Card Model
class CardModelRepresentation: NSObject {
    
    //MARK: Properties
    var transactionID: String = ""
    var userID: String = ""
    var password: String = ""
    var merchandID: String = ""
    var cardNumber: String = ""
    var cardPin: String = ""
    var MSISDN: String = ""
    var requestTimeZone: String = ""
    var requestTimeStamp: String = ""
    var status: String = ""
    var statusDescription: String = ""
    
}

//MARK: - User Model
class UserModelRepresentation: NSObject {
    
    //MARK: Properties
    var facebookID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var middleName: String = ""
    var gender: String = ""
    var birthday: String = ""
    var address: String = ""
    var email: String = ""
    var points: String = "0.00"
    var pasaPoints: String = ""
    var profileImage : String = ""
    
    var cardNumber: String = ""
    var cardNumber2: String = "---"
    var cardNumber3: String = "---"
    var cardPin: String = ""
    var mobileNumber: String = ""
    
    var lastPointsEarned: String = "---"
    var lastPointsRedeemed: String = "---"
    var lastPointsPasa: String = "---"
    var lastTransactionDate: String = "---"
    
    func convertManagedObjectToUserModelInfo(managedObject: User) {
        self.facebookID = managedObject.facebookId!
        self.firstName = managedObject.firstName!
        self.lastName = managedObject.lastName!
        self.gender = managedObject.gender!
        self.birthday = managedObject.birthday!
        self.address = managedObject.address!
        self.email = managedObject.email!
        self.mobileNumber = managedObject.mobileNumber!
        self.points = managedObject.points!
        self.cardNumber = managedObject.cardNumber1!
        self.cardNumber2 = managedObject.cardNumber2!
        self.cardNumber3 = managedObject.cardNumber3!
        self.lastPointsEarned = managedObject.lastPointsEarned!
        self.lastPointsRedeemed = managedObject.lastPointsRedeemed!
        self.lastPointsPasa = managedObject.lastPointsPasa!
        self.lastTransactionDate = managedObject.lastTransactionDate!
        self.profileImage = managedObject.profileImage!
    }
    
    func saveUserToCoreData() {
        
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
        print("Profile = \(self.profileImage)")
        user.facebookId = self.facebookID
        user.profileImage = self.profileImage
        user.firstName = self.firstName
        user.lastName = self.lastName
        user.gender = self.gender
        user.birthday = self.birthday
        user.address = self.address
        user.email = self.email
        user.points = self.points
        user.cardNumber1 = self.cardNumber
        user.cardNumber2 = self.cardNumber2
        user.cardNumber3 = self.cardNumber3
        user.lastTransactionDate = self.lastTransactionDate
        user.lastPointsPasa = self.lastPointsPasa
        user.lastPointsRedeemed = self.lastPointsRedeemed
        user.lastPointsEarned = self.lastPointsEarned
        user.mobileNumber = self.mobileNumber
        user.isLoggedIn = true
        
        do {
            try managedContext.save()
            print("Save!!! \(user.isLoggedIn)")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
}

//MARK: - Transaction Model
class TransactionModelRepresentation: NSObject {
    
    //MARK: Properties
    var transactionIdentifier: String = ""
    var pointsEarned: String = ""
    var pointsRedeemed: String = ""
    var pasaPoints: String = ""
    var senderID: String = ""
    var receiverID: String = ""
    var status: String = ""
    var statusDescription: String = ""
    var paymentChannel: String = ""
    
}

//MARK: - Survey Model
class SurveyModelRepresentation: NSObject {
    
    //MARK: Properties
    var identifier: String = ""
    var question: String = ""
    var options: NSMutableArray = NSMutableArray()
    var answer: String = ""
    
}

//MARK: - Survey Model
class BranchModelRepresentation: NSObject {
    
    //MARK: Properties
    
    var branchId: String = ""
    var branchName: String = ""
    var address: String = ""
    var city: String = ""
    var contactNumber: String = ""
    var is24Hours: Bool = false
    var isBreakFast: Bool = false
    var isDelivery: Bool = false
    var isDriverThru: Bool = false
    var isSmartParty: Bool = false
    var latitude: String = ""
    var longitude: String = ""
    var merchant: String = ""
    var operatingHours: String = ""
    var province: String = ""
    
    //MARK: Methods
    
    func convertDictionaryToBranchModelInfo(dictBranch: NSDictionary) {
        self.branchId = dictBranch["branchId"] as! String
        self.branchName = dictBranch["branchName"] as! String
        self.address = dictBranch["address"] as! String
        self.city = dictBranch["city"] as! String
        self.contactNumber = dictBranch["contactNumber"] as! String
        self.is24Hours = dictBranch["is24Hours"] as! Bool
        self.isBreakFast = dictBranch["isBreakFast"] as! Bool
        self.isDelivery = dictBranch["isDelivery"] as! Bool
        self.isDriverThru = dictBranch["isDriverThru"] as! Bool
        self.isSmartParty = dictBranch["isSmartParty"] as! Bool
        self.latitude = dictBranch["latitude"] as! String
        self.longitude = dictBranch["longitude"] as! String
        self.merchant = dictBranch["merchant"] as! String
        self.operatingHours = dictBranch["operatingHours"] as! String
        self.province = dictBranch["province"] as! String
    }
    
    func convertManagedObjectToBranchModelInfo(managedObject: Branch) {
        self.branchId = managedObject.branchId!
        self.branchName = managedObject.branchName!
        self.address = managedObject.address!
        self.city = managedObject.city!
        self.contactNumber = managedObject.contactNumber!
        self.is24Hours = managedObject.is24Hours as! Bool
        self.isBreakFast = managedObject.isBreakfast as! Bool
        self.isDelivery = managedObject.isDelivery as! Bool
        self.isDriverThru = managedObject.isDriveThru as! Bool
        self.isSmartParty = managedObject.isSmartParty as! Bool
        self.latitude = managedObject.latitude!
        self.longitude = managedObject.longitude!
        self.merchant = managedObject.merchant!
        self.operatingHours = managedObject.operatingHours!
        self.province = managedObject.province!
    }
}

//MARK: - Menu Content Model
class MenuContentModelRepresentation : NSObject {
    
    //MARK: Properties
    var identifier: String = ""
    var menuName: String = ""
    var labelOption1: String = ""
    var labelOption2: String = ""
    var labelOption3: String = ""
    var option1: String = ""
    var option2: String = ""
    var option3: String = ""
    
    func getHeight() -> CGFloat {
        
        
        let label = UILabel()
        
        var totalHeight: CGFloat = 62;
        
        var totalWidth = UIScreen.mainScreen().bounds.size.width - 120
        
        var heightOfLabel : CGFloat = label.getLabelHeight(self.menuName, font: UIFont.systemFontOfSize(24), maxSize: CGSizeMake(totalWidth, 1000))
        totalHeight = totalHeight + heightOfLabel
        
        totalWidth = UIScreen.mainScreen().bounds.size.width - 240
        heightOfLabel = label.getLabelHeight(self.labelOption3, font: UIFont.systemFontOfSize(12), maxSize: CGSizeMake(totalWidth, 1000))
        
        totalHeight = totalHeight + heightOfLabel
        
        return totalHeight
    }
    
}
