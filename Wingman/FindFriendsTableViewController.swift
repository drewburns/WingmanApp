//
//  FindFriendsTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import Contacts

class FindFriendsTableViewController: UITableViewController, UISearchBarDelegate {
    var users:[AppUser] = []
    var usersFromContacts:[AppUser] = []
//    var search = ""


    let reachability = Reachability()!
    var internet = ""
    var friends:[String] = []
    var numbersToNotSearch:[String] = []
    @IBOutlet weak var searchUsers: UISearchBar!
    
    func internetChanged(note: Notification) {
        
    }
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNumbersBlackList()
//        lookForFriends()
        
//        users = usersFromContacts
        searchUsers.delegate = self
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getNumbersBlackList() {
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
//            let numbers = results[0].phoneNumbers
//            for number in numbers {
//                
//            }
//            print(results[0].phoneNumbers[0].value.stringValue)
            
            //            let phoneNumber = "(555) 564-8583"
            
            //            let matched = matches(for: "[0-9]", in: phoneNumber)
            //            print("+1" + matched.flatMap({$0}).joined())
            
            
            return results
        }()
        if let myNum = UserDefaults.standard.value(forKey: "phoneNumber") {
            self.numbersToNotSearch.append(myNum as! String)
        }
        for friend in friends {
            let ref = Database.database().reference().child("users").child(friend)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
//                    print("SNAP", snapshot)
                    let data = snapshot.value as? [String:Any]
                    if let num = data!["phoneNumber"] as? String {
                        print("NUMM", num)
                        self.numbersToNotSearch.append(num)
                        self.lookForFriends()
                    }
                }
            }, withCancel: nil)
        }
    }
    func lookForFriends() {

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
            var numbers:[String] = []
            
            if results.count != 0 {
                print("NUMS NOT TO SEARCH", numbersToNotSearch)
                for person in results {
                    for number in person.phoneNumbers {
                        print("NUMBER:" , number.label )
                        let string = number.value.stringValue
                        let index = string.index(string.startIndex, offsetBy: 0)
                        let x = String(string[index])
                        if x == "+" {
                            print("HAD A PLUS", string)
                            let matched = matches(for: "[0-9]", in: number.value.stringValue)
                            let final = ("+" + matched.flatMap({$0}).joined())
                                                    print("JDWIDJAIODJWIAO", final)
                            if (numbersToNotSearch.contains(final)) {
                                // already have
                            } else {
                                numbers.append(final)
                            }
                        } else {
                            print("DIDNT HAVE A PLUS", string)
                            let matched = matches(for: "[0-9]", in: number.value.stringValue)
                            let final = ("+1" + matched.flatMap({$0}).joined())
                                                    print("JDWIDJAIODJWIAO", final)
                            if (numbersToNotSearch.contains(final)) {
                                print("WE ALREADY HAVE THIS NUMBER")
                            } else {
                                numbers.append(final)
                            }
                        }

                    }
                }
            }
            self.searchForNumbers(numbers: numbers)
//            print(results[0].phoneNumbers[0].label)
//            print(results[0].phoneNumbers[0].value.stringValue)
            
            return results
        }()
    }
    func searchForNumbers(numbers: [String]) {
        for number in numbers {
            Database.database().reference().child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: number).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    for user in snapshot.value as! [String:[String:Any]] {
                        var params = user.value
                        params["id"] = user.key
                        print(params)
                        params.removeValue(forKey: "age")
                        let newUser = AppUser()
                        newUser.setValuesForKeys(params)
                        self.users.append(newUser)
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                    
                    // get the user
                    // check to see if the user is a friend or not
                    // then append to list -> usersFromContacts
                    // then when search bar has input greater than 3 display search and when not display this list
                } else {
                    // user doesn't exist for that number
                }
            })
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchUsers.text!.characters.count > 2 {
            users.removeAll()
            self.tableView.reloadData()
            let ref = Database.database().reference()

            let strSearch = searchUsers.text!.lowercased()
            print(strSearch)
            ref.child("users").queryOrdered(byChild:"usernamesearch").queryStarting(atValue: strSearch).queryEnding(atValue: strSearch + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() == true {
                    for user in snapshot.value as! [String:[String:Any]] {
                        var params = user.value
                        params["id"] = user.key
                        print("PARAMS", params)
                        let newUser = AppUser()
                        params.removeValue(forKey: "age")
                        newUser.setValuesForKeys(params)
                        self.users.append(newUser)
//                        self.tableView.reloadData()
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                } else {
                    // no users found
                    print("no users found -----------")
                }
   
                
            })
            
        }
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
        return self.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "findFriend", for: indexPath) as! SearchUserTVC

        // Configure the cell...
        cell.user = self.users[indexPath.row]
        print("PROFILE", cell.user?.profileImageURL)
        if cell.user?.profileImageURL != nil {
            cell.userImage?.loadImageUsingCacheSync((cell.user?.profileImageURL!)!)
//            cell.userImage?.maskCircle()
        } else {
           cell.userImage.image = #imageLiteral(resourceName: "logo")
        }
        cell.userImage.maskCircle()
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.user = self.users[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SearchUserTVC {
            cell.base.removeAllObservers()
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}
