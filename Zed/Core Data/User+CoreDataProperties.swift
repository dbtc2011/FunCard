//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var userId: String?
    @NSManaged var facebookId: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var gender: String?
    @NSManaged var birthday: String?
    @NSManaged var address: String?
    @NSManaged var email: String?
    @NSManaged var points: String?
    @NSManaged var cardNumber1: String?
    @NSManaged var cardNumber3: String?
    @NSManaged var cardNumber2: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var isLoggedIn: NSNumber?

}
