//
//  DBManager.swift
//  Users
//
//  Created by Edgar on 29.08.22.
//

import Foundation
import CoreData
import UIKit

class DBManager {
    private var context: NSManagedObjectContext!

    init() {
        self.context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    func getUsers() -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            let result = try context.fetch(request)
            return result
        } catch (let error) {
            print("Error getting users from DB \(error)")
        }
        
        return []
    }
    
    func saveUser(user: User) {
        guard let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context) else { return }
        
        let largeImage = "\(user.email)_large"
        let mediumImage = "\(user.email)_medium"
        
        let userEntity = UserEntity(entity: entity, insertInto: context)
        userEntity.firstName = user.name.first
        userEntity.lastName = user.name.last
        userEntity.gender = user.gender
        userEntity.country = user.location.country
        userEntity.phone = user.phone
        userEntity.streetName = user.location.street.name
        userEntity.streetNumber = Int16(user.location.street.number)
        userEntity.largeImage = largeImage
        userEntity.mediumImage = mediumImage
        userEntity.email = user.email
        
        do {
            try context.save()
        } catch {
            print("Error saving")
        }
    }
    
    func removeUser(email: String?) {
        if let email = email {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "email == %@", email)
            
            do {
                let result = try context.fetch(request)
                
                context.delete(result[0])
                
                try context.save()
            } catch {
                print("Error on delete")
            }
        }
    }
}
