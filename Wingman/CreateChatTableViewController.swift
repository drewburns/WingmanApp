//
//  CreateChatTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class CreateChatTableViewController: UITableViewController {
    var user: AppUser?
    var users:[AppUser] = []
    var selectedUsers:[AppUser] = []
    //    var search = ""
    let base = Database.database().reference()
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    
//    @IBOutlet weak var searchUsers: UISearchBar!
    
    
//    @IBAction func done(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchUsers.delegate = self


        getFriends()
        createButton.isEnabled = false
        // get all the user's friends and list them
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
                            print(snapshot.value)
                            if snapshot.exists() {
                                print("made it to 3")
                                let newUser = AppUser()
                                var params = snapshot.value as! [String:Any]
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
        performSegue(withIdentifier: "confirm", sender: nil)
        
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
        return self.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! NewChatUserTVC
        
        // Configure the cell...
        cell.user = self.users[indexPath.row]
        cell.userImage.loadImageUsingCacheWithUrlString((cell.user?.profileImageURL)!)
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
