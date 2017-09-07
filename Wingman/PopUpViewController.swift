//
//  PopUpViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class PopUpViewController: UIViewController {
    var user:AppUser?
    
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var findFriendsButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewFriendButton: UIButton!

    
    @IBOutlet weak var mainView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.mainView.addGestureRecognizer(downSwipe)
        userImage.maskCircle()
        mainView.layer.cornerRadius = 5;
        mainView.layer.masksToBounds = true;

        // Do any additional setup after loading the view.
    }
    func setImage() {
        self.userImage.loadImageUsingCacheWithUrlString((user?.profileImageURL)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        setImage()
        nameLabel.text! = (user?.name)!
        usernameLabel.text! = (user?.usernamesearch)!

        setFriendButton()
        
    }
    
    @IBAction func viewFriends(_ sender: Any) {
//        let objVC: FriendListTableViewController? = FriendListTableViewController()
//        let aObjNavi = UINavigationController(rootViewController: objVC!)
//        objVC?.user = self.user
//        self.present(aObjNavi, animated: true)
        performSegue(withIdentifier: "friendlist", sender: nil)
    }
    
    func setFriendButton() {
        let currentID = Auth.auth().currentUser?.uid
        let id = Auth.auth().currentUser?.uid
        if user?.id == Auth.auth().currentUser?.uid {
            friendButton.setTitle("Settings", for: .normal)
                
            } else {
                // if current user friendship exists
                print("setting up friends stuff")
            if (currentID != nil) {
                let ref = Database.database().reference().child("friendships").child(currentID!).child((self.user?.id)!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.exists() {
                        self.friendButton.setTitle("Friends", for: .normal)
                    } else {
                        self.friendButton.setTitle("Add Friend", for: .normal)
                    }
                })
                
                // if this vc's user is contained in current users friendship -> show "friends"
                // else -> show "add"
                print("ete")
                findFriendsButton.isEnabled = false
                findFriendsButton.setTitle("", for: .disabled)
            }

        }
    }
    
    @IBAction func friendButtonClicked(_ sender: Any) {
        if friendButton.titleLabel?.text! == "Settings" {
            performSegue(withIdentifier: "settings", sender: nil)
        } else if friendButton.titleLabel?.text! == "Friends" {
            // and others
            removeFriendship()
//            performSegue(withIdentifier: "friendlist", sender: nil)
            
        } else if friendButton.titleLabel?.text! == "Add Friend" {
            addFriendship()
        }
    }
    
    
    func addFriendship() {
        let currentID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("friendships").child(currentID!)
        if let userId = self.user?.id {
            ref.updateChildValues([userId: userId], withCompletionBlock: { (error, ref) in
                print("Done!")
                self.friendButton.setTitle("Friends", for: .normal)
            })
        }
    }
    
    func removeFriendship() {
        let currentID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("friendships").child(currentID!).child((self.user?.id)!)
        ref.removeValue()
        self.friendButton.setTitle("Add Friend", for: .normal)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logerror {
            print(logerror)
        }
        
    
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        self.show(vc, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "friendlist" {
//            UINavigationController
            var DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! FriendListTableViewController
            targetController.user = self.user
            
        } else if segue.identifier == "settings" {
            let viewController:SettingsViewController = segue.destination as! SettingsViewController
            viewController.vc = self.self
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first as! UITouch?
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != mainView {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    

}

extension UIViewController {
    func swipeAction(swipe:UIGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
