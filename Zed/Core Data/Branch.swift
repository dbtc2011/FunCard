//
//  Branches.swift
//  
//
//  Created by Marielle Miranda on 10/9/16.
//
//

import Foundation
import CoreData


class Branch: NSManagedObject {
    
    func convertDictionaryToBranchManagedObject(dictBranch: NSDictionary) {
        self.branchId = dictBranch["branchId"] as? String
        self.branchName = dictBranch["branchName"] as? String
        self.address = dictBranch["address"] as? String
        self.city = dictBranch["city"] as? String
        self.contactNumber = dictBranch["contactNumber"] as? String
        self.is24Hours = dictBranch["is24Hours"] as! Bool
        self.isBreakfast = dictBranch["isBreakFast"] as! Bool
        self.isDelivery = dictBranch["isDelivery"] as! Bool
        self.isDriveThru = dictBranch["isDriverThru"] as! Bool
        self.isSmartParty = dictBranch["isSmartParty"] as! Bool
        self.latitude = dictBranch["latitude"] as? String
        self.longitude = dictBranch["longitude"] as? String
        self.merchant = dictBranch["merchant"] as? String
        self.operatingHours = dictBranch["operatingHours"] as? String
        self.province = dictBranch["province"] as? String
    }
}
