//
//  FileManager.swift
//  Users
//
//  Created by Edgar on 27.08.22.
//

import Foundation
import UIKit

struct FileStorageManager {
    static func retrieveImage(name: String) -> UIImage? {
        if let filePath = filePath(key: name),
            let fileData = FileManager.default.contents(atPath: filePath.path) {
            return UIImage(data: fileData)
        }
        return nil
    }
    
    static func store(image: UIImage?, name: String) {
        if let imageData = image?.jpegData(compressionQuality: 1),
           let path = filePath(key: name) {
            do {
                try imageData.write(to: path)
            } catch let err {
                print("Error on file saving \(err)")
            }
        }
    }
    
    static func filePath(key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return documentUrl.appendingPathComponent(key + ".jpg")
    }
}
