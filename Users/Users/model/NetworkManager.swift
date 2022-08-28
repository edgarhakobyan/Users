//
//  NetworkManager.swift
//  Users
//
//  Created by Edgar on 22.08.22.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit

class NetworkManager {
    private let baseUrl = "https://randomuser.me/api?seed=renderforest&results=20&page="
    private let imageCache = AutoPurgingImageCache()
    private var isTotalItemReached = false
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func makeRequest(page: Int, completion: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: AFError) -> ()) {
        guard let url = URL(string: baseUrl + "\(page)") else { return }
        
        if isTotalItemReached {
            completion([User]())
        } else {
            AF.request(url).validate().responseDecodable(of: ResponseData.self) { [weak self] response in
                switch response.result {
                case .success(let value):
                    if page < value.info.page {
                        self?.isTotalItemReached = true
                        completion([User]())
                    } else {
                        completion(value.results)
                    }
                case .failure(let error):
                    failure(error)
                }
            }
        }
    }
    
    func downloadImage(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        print("url -> \(url)")
        if let cachedImage = self.imageCache.image(withIdentifier: url) {
            print("Getting from cahce")
            completion(cachedImage)
        } else {
            guard let urlObj = URL(string: url) else { return }
            AF.request(urlObj).validate().responseImage { [weak self] image in
                switch image.result {
                case .success(let value):
                    print("Adding into cache")
                    self?.imageCache.add(value, withIdentifier: url)
                    completion(value)
                case .failure(let error):
                    print("Error \(error)")
                }
            }
        }
    }
    
}
