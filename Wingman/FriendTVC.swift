//
//  FriendTVC.swift
//  Wingman
//
//  Created by Andrew Burns on 9/2/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class FriendTVC: UITableViewCell {
    var user:AppUser? {
        didSet {
            setAddButton()
            nameLabel.text! = (user?.name)!
            usernameLabel.text! = (user?.usernamesearch)!
            userImage.setRadius(radius: 18)
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
                                self.addButton.setTitle("Add Friend", for: .normal)
                            }
                        }
                    } else {
                        self.addButton.isEnabled = true
                        self.addButton.setTitle("Add Friend", for: .normal)
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
        if addButton.titleLabel?.text == "Add Friend" {
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
    }
    
    func removeFriendship() {
        let currentID = Auth.auth().currentUser?.uid
        let ref = base.child("friendships").child(currentID!).child((self.user?.id)!)
        ref.removeValue()
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
