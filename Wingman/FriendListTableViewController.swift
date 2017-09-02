//
//  FriendListTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class FriendListTableViewController: UITableViewController {
    var user:AppUser?
    var users:[AppUser] = []
    let base = Database.database().reference()
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        getFriends()

        

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
                                self.users.sort { $0.usernamesearch! < $1.usernamesearch! }
                                self.tableView.reloadData()
                                print(self.users.count)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! FriendTVC
        
        // Configure the cell...
        cell.user = self.users[indexPath.row]
        cell.userImage.loadImageUsingCacheWithUrlString((cell.user?.profileImageURL)!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.user = self.users[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? FriendTVC {
            cell.base.removeAllObservers()
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
