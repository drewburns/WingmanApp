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
    let reachability = Reachability()!
    var internet = ""
    var currentUserName = ""
    
    @IBOutlet weak var mainView: UIView!
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
        performZoomInForStartingImageView(userImage)

        //
        // Your action
    }
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.view.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.view.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.mainView.addGestureRecognizer(downSwipe)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
        
        userImage.maskCircle()
        mainView.layer.cornerRadius = 5;
        mainView.layer.masksToBounds = true;
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
            friendButton.setTitle("Added Me", for: .normal)
            
                
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
                closeButton.isEnabled = false
                closeButton.setTitle("", for: .disabled)
                findFriendsButton.isEnabled = false
                findFriendsButton.setTitle("", for: .disabled)
            }

        }
    }
    
    @IBAction func friendButtonClicked(_ sender: Any) {
        if friendButton.titleLabel?.text! == "Added Me" {
            performSegue(withIdentifier: "addedme", sender: nil)
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
        
        if let userId = self.user?.id  {
            let ref2 = Database.database().reference().child("added-friendships").child(userId)
            ref2.updateChildValues([currentID!: 0], withCompletionBlock: {
                (error, ref) in
                if self.user?.token != "none" && self.user?.token != nil {
                    var alert = UserDefaults.standard.string(forKey: "username")! + " added you as a friend"
                    alert = alert.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let string = "https://wingman-notifs.herokuapp.com/send?token=" + (self.user?.token)! + "&alert=" + alert
                
                    let url = URL(string: string)
                    URLSession.shared.dataTask(with: url!, completionHandler: {
                        (data, response, error) in
                        if(error != nil){
                            print("error")
                        }else{
                            do{
       
                            }catch let error as NSError{
                                print(error)
                            }
                        }
                    }).resume()
                }

                
            })
        }
    }
    
    func removeFriendship() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Remove Friend?", message: "Are you sure?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let currentID = Auth.auth().currentUser?.uid
            let ref = Database.database().reference().child("friendships").child(currentID!).child((self.user?.id)!)
            let ref2 = Database.database().reference().child("added-friendships").child((self.user?.id)!).child(currentID!)
            ref.removeValue()
            ref2.removeValue()
            self.friendButton.setTitle("Add Friend", for: .normal)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            //
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        let currentID = Auth.auth().currentUser?.uid

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
        self.performSegue(withIdentifier:"settings", sender: nil)
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
            
        } else if segue.identifier == "addedme" {
            var DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! AddedMeTableViewController
            targetController.user = self.user
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        var touch: UITouch? = touches.first as! UITouch?
//        //location is relative to the current view
//        // do something with the touched point
//        if touch?.view != mainView || touch?.view != userImage {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
    
    func internetChanged(note: Notification) {
        
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
