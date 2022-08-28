//
//  UserDetailsViewController.swift
//  Users
//
//  Created by Edgar on 23.08.22.
//

import UIKit
import MapKit

class UserDetailsViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var user: User?
    var isSavedUser = false
    private let dbManager = DBManager()
            
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.user?.getFullName()
        self.userNameLabel.text = self.user?.getFullName()
        self.userDescriptionLabel.text = self.user?.getDescription()
        
        configureMap()
        configuteButtons(isSavedUser: isSavedUser)
        configureImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Users"
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        guard let user = self.user else { return }
        
        let largeImage = "\(user.email)_large"
        FileStorageManager.store(image: self.userImageView.image, name: largeImage)
            
        dbManager.saveUser(user: user)
        
        isSavedUser = true
        configuteButtons(isSavedUser: isSavedUser)
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        dbManager.removeUser(email: user?.email)
        isSavedUser = false
        configuteButtons(isSavedUser: isSavedUser)
    }
    
    
    private func configuteButtons(isSavedUser: Bool) {
        if isSavedUser {
            self.saveButton.tintColor = .black
            self.saveButton.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            self.saveButton.setTitle("User saved", for: .normal)
            self.saveButton.isEnabled = false
            self.removeButton.isHidden = false
        } else {
            self.saveButton.tintColor = .white
            self.saveButton.backgroundColor = UIColor(red: 18/255, green: 201/255, blue: 110/255, alpha: 1.0)
            self.saveButton.setTitle("Save user", for: .normal)
            self.saveButton.isEnabled = true
            self.removeButton.isHidden = true
        }
    }
    
    private func configureMap() {
        if let lat = Double(self.user!.location.coordinates.latitude),
           let lng = Double(self.user!.location.coordinates.longitude) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    private func configureImageView() {
        if isSavedUser {
            if let imageName = self.user?.picture.large {
                self.userImageView.image = FileStorageManager.retrieveImage(name: imageName)
            }
        } else {
            if let imageUrl = self.user?.picture.large {
                NetworkManager.shared.downloadImage(url: imageUrl) { image in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
            }
        }
    }
}
