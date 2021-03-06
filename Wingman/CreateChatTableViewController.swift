//
//  CreateChatTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import NotificationBannerSwift

class CreateChatTableViewController: UITableViewController, UISearchBarDelegate {
    var user: AppUser?
    var users:[AppUser] = []
    var friends:[AppUser] = []
    var selectedUsers:[AppUser] = []
    //    var search = ""
    let base = Database.database().reference()
    let reachability = Reachability()!
    var internet = ""
    var contactUsers:[CNContact] = []
    var contacts:[AppUser] = []
    var searchUsers:[AppUser] = []
    
    var isSearching = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    
//    @IBOutlet weak var searchUsers: UISearchBar!
    
    
//    @IBAction func done(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func askForContactPriv() {
        var contacts: [CNContact] = {
            let contactStore = CNContactStore()
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey] as [Any]
            
            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }
            
            var results: [CNContact] = []
            
            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching results for container")
                }
            }
            for result in results {
                contactUsers.append(result)
                
            }
            return results
        }()
    }
    
    func getContactsOnAppNotFriends() {
        
        var numbersWeHave = self.friends.map { $0.phoneNumber! }
        numbersWeHave.append((self.user?.phoneNumber)!)
        print("NUMBERS WE HAVE", numbersWeHave)
//        let pendingToAdd = self.users
//        self.users.removeAll()
        for result in contactUsers {
            let num = result.correctNumber()
            let name = result.givenName + " " + result.familyName
            
            if numbersWeHave.contains(num) {
                // we have this number as a friend so do nothing
            } else {
                // lets check if they exist in the app
                self.tryToFindUserWithNum(num: num, name: name)
            }
            // get the phone number and name
            // if phone number is already in friend list - don't do anything
            // check to see if user exists in app
            // if none of these - create a user with just phone number and name
            // sort all alphabetically
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // filter the things
        if searchBar.text == "" || searchBar.text == nil {
            print("TEXT IS NIL HERE", searchBar.text)
            isSearching = false
            view.endEditing(true)
            searchUsers = []
            tableView.reloadData()
        } else {
            print("TEXT IS EXISTING HERE", searchBar.text)
            isSearching = true
            
            let text = searchBar.text!
            searchUsers = users.filter({ ($0.name?.contains(text))! })
            tableView.reloadData()
        }
    }
    

    
    func tryToFindUserWithNum(num: String, name: String) {
        Database.database().reference().child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: num).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                for user in snapshot.value as! [String:[String:Any]] {
                    var params = user.value
                    params["id"] = user.key
                    print(params)
                    params.removeValue(forKey: "age")
                    let newUser = AppUser()
                    newUser.setValuesForKeys(params)
//                    self.users.append(newUser)
                    self.friends.append(newUser)
                    self.friends.sort { $0.name! < $1.name! }
                    
                    self.users = self.friends + self.contacts
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                
                // get the user
                // check to see if the user is a friend or not
                // then append to list -> usersFromContacts
                // then when search bar has input greater than 3 display search and when not display this list
            } else {
                if num != "none" {
                    var params = ["phoneNumber": num, "name": name]
                    //                params.removeValue(forKey: "age")
                    let newUser = AppUser()
                    newUser.setValuesForKeys(params)
                    self.contacts.append(newUser)
                    
                    self.contacts.sort { $0.name! < $1.name! }
                    
                    self.users = self.friends + self.contacts
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }

                // user doesn't exist for that number
            }
//            self.users = pending + self.users
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        

        askForContactPriv()
//        getFriends()
//        askForContactPriv()
        getContactsOnAppNotFriends()
        createButton.isEnabled = false
        reachability.whenReachable = { _ in
            if self.internet == "unreachable" {
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: false, completion: nil)
                    // dismiss unreachable view
                })
                self.internet = ""
            }
            
        }
        
        reachability.whenUnreachable = {_ in
            self.internet = "unreachable"
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: nil, message: "Connect to Internet", preferredStyle: .alert)
                
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                loadingIndicator.startAnimating();
                
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            // something went wrong
        }
        // get all the user's friends and list them
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func internetChanged(note: Notification) {
        
    }
    func getFriends() {
        print("here")
        let ref = base.child("friendships").child((user?.id)!)
        ref.observeSingleEvent(of: .value, with:{ (snapshot) in
            if snapshot.exists() {
                print("made it to 1")
                if let friendStrings = snapshot.value as? [String:String] {
                    print("made it to 2")
                    for friendString in friendStrings {
                        
                        self.base.child("users").child(friendString.key).observeSingleEvent(of: .value, with: { (snapshot) in
//                            print(snapshot.value)
                            if snapshot.exists() {
                                print("made it to 3")
                                let newUser = AppUser()
                                var params = snapshot.value as! [String:Any]
                                params.removeValue(forKey: "age")
                                params["id"] = snapshot.key
                                newUser.setValuesForKeys(params)
                                self.users.append(newUser)
                                self.users.sort { $0.name! < $1.name! }
                                DispatchQueue.main.async {
                                   self.tableView.reloadData()
                                }
                                
                            }
                        })
                    }
                    self.getContactsOnAppNotFriends()
                    
                }
            } else {
                print("no friends")
                // no friends
            }
        })

    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        users.removeAll()
//        self.tableView.reloadData()
//        if searchUsers.text!.characters.count > 1 {
//            
////            let ref = Database.database().reference()
//            
//            let strSearch = searchUsers.text!.lowercased()
//            print(strSearch)
//            // restrict the users by the search
//            
//        }
//    }
    
    
    
    @IBAction func createChat(_ sender: Any) {
//        createSetUp()
//        createFirstMessage()
//        let presenting = self.presentingViewController
        print("here")
        if self.selectedUsers[0].id != nil || self.selectedUsers[1].id != nil {
            performSegue(withIdentifier: "confirm", sender: nil)
        } else {
            let banner = NotificationBanner(title: "Error", subtitle: "One user in the chat must have an account", style: .danger)
            banner.autoDismiss = true
            banner.show()
            // make an alert saying one user must already have the app installed
        }
        
//        let nav = self.navigationController
//        
//        
//        nav?.popViewController(animated: true)
        
    }

    

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching {
            return self.searchUsers.count
        }
        return self.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! NewChatUserTVC
        
        // Configure the cell...
        if isSearching {
            cell.user = self.searchUsers[indexPath.row]
        } else {
            cell.user = self.users[indexPath.row]
        }
        if cell.user?.profileImageURL != nil {
            cell.userImage.loadImageUsingCacheWithUrlString((cell.user?.profileImageURL)!)
        } else {
            cell.userImage.image = #imageLiteral(resourceName: "logo")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set checkbox to checked and highlight kind of

        if let list = tableView.indexPathsForSelectedRows {
            selectedUsers.removeAll()
            for item in list {
                self.selectedUsers.append(self.users[item.row])
            }
            if list.count > 2 {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            if list.count == 2 {
                createButton.isEnabled = true
            } else {
                createButton.isEnabled = false
            }
        }
//        print(indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let list = tableView.indexPathsForSelectedRows {
            selectedUsers.removeAll()
            for item in list {
                self.selectedUsers.append(self.users[item.row])
            }
            
            if list.count == 2 {
                createButton.isEnabled = true
            } else {
                createButton.isEnabled = false
            }
            
        }
//        print(indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "confirm" {
            let viewController:ChatConfirmViewController = segue.destination as! ChatConfirmViewController
            viewController.nav = self.navigationController
            viewController.users = self.selectedUsers
            viewController.user = self.user
        }
    }
    

}

extension CNContact {
//    _$!<Mobile>!$_
    func correctNumber() -> String {
        var final_num = "none"
        if let mobile = self.phoneNumbers.first(where: { $0.label == "_$!<Mobile>!$_" }) {
            let string = mobile.value.stringValue
            let index = string.index(string.startIndex, offsetBy: 0)
            let x = String(string[index])
            if x == "+" {
                print("HAD A PLUS", string)
                let matched = matches(for: "[0-9]", in: mobile.value.stringValue)
                let final = ("+" + matched.flatMap({$0}).joined())
                print("JDWIDJAIODJWIAO", final)
                final_num = final
            } else {
                print("DIDNT HAVE A PLUS", string)
                let matched = matches(for: "[0-9]", in: mobile.value.stringValue)
                let final = ("+1" + matched.flatMap({$0}).joined())
                print("JDWIDJAIODJWIAO", final)
                final_num =  final
            }
        } else {
            let number = self.phoneNumbers.first
            if let string = number?.value.stringValue {
                let index = string.index((string.startIndex), offsetBy: 0)
                let x = String(string[index])
                if x == "+" {
                    print("HAD A PLUS", string)
                    let matched = matches(for: "[0-9]", in: (number?.value.stringValue)!)
                    let final = ("+" + matched.flatMap({$0}).joined())
                    print("JDWIDJAIODJWIAO", final)
                    
                    final_num = final
                } else {
                    print("DIDNT HAVE A PLUS", string)
                    let matched = matches(for: "[0-9]", in: (number?.value.stringValue)!)
                    let final = ("+1" + matched.flatMap({$0}).joined())
                    print("JDWIDJAIODJWIAO", final)
                    final_num = final
                }
            } else {
                // we have an error
            }

        }
        return final_num
    }
    
    
}

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
