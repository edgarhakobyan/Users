//
//  ViewController.swift
//  Users
//
//  Created by Edgar on 22.08.22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var users = [User]()
    private var filteredUsers = [User]()
    private let dbManager = DBManager()
    
    private var currentPage = 1
    private var isSearchResult = false
    private var isLocalMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        loadUsers(page: currentPage)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let user = self.filteredUsers[indexPath.row]
 
        if isLocalMode {
            cell.userImageView.image = FileStorageManager.retrieveImage(name: user.picture.large)
        } else {
            if !isSearchResult && indexPath.row == self.filteredUsers.count - 1 {
                self.currentPage += 1
                loadUsers(page: self.currentPage)
            }
            
            NetworkManager.shared.downloadImage(url: user.picture.medium) { image in
                DispatchQueue.main.async {
                    cell.userImageView.image = image
                }
            }
        }
        
        cell.userImageView.layer.cornerRadius = 6
        
        cell.nameLabel.text = user.getFullName()
        cell.descriptionLabel.text = user.getDescription()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = self.filteredUsers[indexPath.row]
        performSegue(withIdentifier: "userDetailsSegue", sender: selectedUser)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailsSegue" {
            if let userDetailsVC = segue.destination as? UserDetailsViewController {
                userDetailsVC.user = sender as? User
                userDetailsVC.isSavedUser = self.isLocalMode
            }
        }
    }
    
    private func loadUsers(page: Int) {
        self.isLocalMode = false
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
        NetworkManager.shared.makeRequest(page: page) { [weak self] newUsers in
            self?.users.append(contentsOf: newUsers)
            self?.filteredUsers = self?.users ?? []
            DispatchQueue.main.async {
                self?.indicatorView.stopAnimating()
                self?.indicatorView.isHidden = true
                self?.tableView.reloadData()
            }
        } failure: { [weak self] error in
            print("Error \(error)")
            DispatchQueue.main.async {
                self?.indicatorView.stopAnimating()
                self?.indicatorView.isHidden = true
                self?.tableView.reloadData()
            }
        }

    }
    
    
    @IBAction func segmentedControllAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.users = []
            self.filteredUsers = []
            loadUsers(page: currentPage)
        case 1:
            loadUsersFromDb()
        default:
            print("Wrong segment")
        }
    }
    
    private func loadUsersFromDb() {
        self.isLocalMode = true
        self.users = []
       
        let result = dbManager.getUsers()
        
        for user in result {
            let name = UserName(first: user.firstName!, last: user.lastName!)
            let picture = UserImage(large: user.largeImage!, medium: user.mediumImage!)
            let location = Location(street: Street(number: Int(user.streetNumber), name: user.streetName!), country: user.country!, coordinates: Coordinates(latitude: "1.0", longitude: "1.0"))
            
            let user = User(gender: user.gender!, name: name, phone: user.phone!, picture: picture, location: location, email: user.email!)
            
            self.users.append(user)
        }

        self.filteredUsers = users
        self.tableView.reloadData()
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearchResult = !searchText.isEmpty
        self.filteredUsers = searchText.isEmpty ? self.users : self.users.filter({ user in
            return user.getFullName().range(of: searchText, options: .caseInsensitive) != nil ||
                        user.gender.range(of: searchText, options: .caseInsensitive) != nil ||
                        user.phone.range(of: searchText) != nil ||
                        user.location.country.range(of: searchText, options: .caseInsensitive) != nil ||
                        user.location.street.name.range(of: searchText, options: .caseInsensitive) != nil ||
                        "\(user.location.street.number)".range(of: searchText) != nil
        })
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
