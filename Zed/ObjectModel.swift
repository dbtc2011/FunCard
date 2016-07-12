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
    var birthday: String = ""
    var address: String = ""
    var email: String = ""
    var status: String = ""
    var statusDescription: String = ""
    var points: String = ""
    var pasaPoints: String = ""
    
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
