//
//  FindFriendsTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class FindFriendsTableViewController: UITableViewController, UISearchBarDelegate {
    var users:[AppUser] = []
    var search = ""


    
    @IBOutlet weak var searchUsers: UISearchBar!
    
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchUsers.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        users.removeAll()
        self.tableView.reloadData()
        if searchUsers.text!.characters.count > 2 {

            let ref = Database.database().reference()

            let strSearch = searchUsers.text!.lowercased()
            print(strSearch)
            ref.child("users").queryOrdered(byChild:  "username").queryStarting(atValue: strSearch).queryEnding(atValue: strSearch + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() == true {
                    for user in snapshot.value as! [String:[String:Any]] {
                        var params = user.value
                        params["id"] = user.key
                        print(params)
                        var newUser = AppUser()
                        newUser.setValuesForKeys(params)
                        self.users.append(newUser)
                        self.tableView.reloadData()
                    }
                } else {
                    // no users found
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
