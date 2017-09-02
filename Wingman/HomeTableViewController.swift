//
//  HomeTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController {
    var user:AppUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot.value)
            if snapshot.exists() == true {
                
                // get num of friends
                
                var value = snapshot.value as? [String:Any]
    //            value["id"] = snapshot.
                value?["id"] = snapshot.key
                let username = value?["username"] as? String ?? ""
                //            let user = User.init(username: username)
                var newUser = AppUser()
                newUser.setValuesForKeys(value!)
                self.user = newUser
                print(self.user?.id)
            } else{
                self.performSegue(withIdentifier: "login", sender: nil)

            }
            
        // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        // get friendship
        ref.child("friendships").child(userID!).observe(.childAdded, with: {(snapshot) in
            if snapshot.exists() {
                print(snapshot)
            } else {
                print("No friends found")
            }
        })
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "me" {
           let viewController:PopUpViewController = segue.destination as! PopUpViewController
            viewController.user = self.user
            
        }
    }
    

}
