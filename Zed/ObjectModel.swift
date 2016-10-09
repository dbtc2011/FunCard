//
//  ObjectModel.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

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
    var points: String = ""
    var pasaPoints: String = ""
    
    var cardNumber: String = ""
    var cardNumber2: String = ""
    var cardNumber3: String = ""
    var cardPin: String = ""
    var mobileNumber: String = ""
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
