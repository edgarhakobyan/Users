//
//  User.swift
//  Users
//
//  Created by Edgar on 22.08.22.
//

import Foundation

struct User: Decodable {
    let gender: String
    let name: UserName
    let phone: String
    let picture: UserImage
    let location: Location
    let email: String
    
    func getFullName() -> String {
        return "\(self.name.first) \(self.name.last)"
    }
    
    func getDescription() -> String {
        return "\(self.gender), \(self.phone) \n\(self.location.country) \n\(self.location.street.number), \(self.location.street.name)"
    }
}

struct ResponseData: Decodable {
    let results: [User]
    let info: Info
}

struct UserName: Decodable {
    let first: String
    let last: String
}

struct UserImage: Decodable {
    let large: String
    let medium: String
}

struct Street: Decodable {
    let number: Int
    let name: String
}

struct Location: Decodable {
    let street: Street
    let country: String
    let coordinates: Coordinates
}

struct Info: Decodable {
    let page: Int
}

struct Coordinates: Decodable {
    let latitude: String
    let longitude: String
}

struct Id: Decodable {
    let value: String
}
