//
//  Branches+CoreDataProperties.swift
//  
//
//  Created by Marielle Miranda on 10/9/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Branches {

    @NSManaged var branchId: String?
    @NSManaged var branchName: String?
    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var contactNumber: String?
    @NSManaged var is24Hours: NSNumber?
    @NSManaged var isBreakfast: NSNumber?
    @NSManaged var isDelivery: NSNumber?
    @NSManaged var isDriveThru: NSNumber?
    @NSManaged var isSmartParty: NSNumber?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var merchant: String?
    @NSManaged var operatingHours: String?
    @NSManaged var province: String?

}
