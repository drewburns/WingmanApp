//
//  SearchUserTVC.swift
//  Wingman
//
//  Created by Andrew Burns on 9/1/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class SearchUserTVC: UITableViewCell {
    var user:AppUser? {
        didSet {
            setAddButton()
            nameLabel.text! = (user?.name)!
            usernameLabel.text! = (user?.usernamesearch)!
            userImage.maskCircle()
            let currentUser = Auth.auth().currentUser?.uid
            let ref = base.child("friendships").child(currentUser!)
            
            print(currentUser! == (self.user?.id)!)
            if currentUser! != (self.user?.id)! {
                ref.observe(.value, with: {(snapshot) in
                    if snapshot.exists() {
                        if let friends = snapshot.value as? [String:String] {
                            if friends[(self.user?.id)!] != nil {
                                self.addButton.isEnabled = true
                                self.addButton.setTitle("Friends", for: .normal)
                            } else {
                                self.addButton.isEnabled = true
                                self.addButton.setTitle("Add", for: .normal)
                            }
                        }
                    } else {
                        self.addButton.isEnabled = true
                        self.addButton.setTitle("Add", for: .normal)
                    }
                })
            } else {
                self.addButton.isEnabled = false
                self.addButton.setTitle("Me", for: .disabled)
            }
        }
    }
    
    func setAddButton() {
        //stuff
    }
    let base = Database.database().reference()
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    

    @IBAction func friendChange(_ sender: Any) {
        print("Button clicked")
        if addButton.titleLabel?.text == "Add" {
            addFriendship()
        } else {
            removeFriendship()
        }
    }
    
    func addFriendship() {
        let currentID = Auth.auth().currentUser?.uid
        let ref = base.child("friendships").child(currentID!)
        if let userId = self.user?.id {
            ref.updateChildValues([userId: userId], withCompletionBlock: { (error, ref) in
                print("Done!")
                self.addButton.setTitle("Friends", for: .normal)
            })
        }
        
        if let userId = self.user?.id {
            let ref2 = base.child("added-friendships").child(userId)
            ref2.updateChildValues([currentID!: 0], withCompletionBlock: { (error, ref) in
            })
        }
        if (self.user?.token != "none" && self.user?.token == nil){
            print("Stored name", UserDefaults.standard.string(forKey: "username"))
            var alert = UserDefaults.standard.string(forKey: "username")! + "added you as a friend"
            alert = alert.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            if ((self.user?.token) != nil) {
                let string = "https://wingman-notifs.herokuapp.com/send?token=" + (self.user?.token)! + "&alert=" + alert
                
                let url = URL(string: string)
                URLSession.shared.dataTask(with: url!, completionHandler: {
                    (data, response, error) in
                    if(error != nil){
                        print("error")
                    }else{
                        do{
                            
                        } catch let error as NSError{
                            print(error)
                        }
                    }
                }).resume()
 
            }
        }
    }
    
    func removeFriendship() {
        let currentID = Auth.auth().currentUser?.uid
        let ref = base.child("friendships").child(currentID!).child((self.user?.id)!)
        ref.removeValue()
        let ref2 = base.child("added-friendships").child((self.user?.id)!).child(currentID!)
        ref2.removeValue()
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("test!!!!!!!!!!!")

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    

}
