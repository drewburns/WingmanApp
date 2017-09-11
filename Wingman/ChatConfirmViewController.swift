//
//  ChatConfirmViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 9/3/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class ChatConfirmViewController: UIViewController , UITextViewDelegate{
    var users:[AppUser] = []
    var user: AppUser?
    var nav: UINavigationController?
    let base = Database.database().reference()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var user1Image: UIImageView!
    @IBOutlet weak var user2Image: UIImageView!
    @IBOutlet weak var user1Name: UILabel!
    @IBOutlet weak var user2Name: UILabel!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    let reachability = Reachability()!
    var internet = ""
    
    
    func internetChanged(note: Notification) {
        
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if textInput.text != "" {
            let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            createSetUp()
            createFirstMessage()
            goBack()
            dismiss(animated: false, completion: nil)
        } else {
            print("Please enter some text")
        }

      
    }
    
    func createFirstMessage() {
//        let ref = base.child("messages").childByAutoId()
//        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
//        print(timestamp)
//        let values = ["toId": self.users[0].id, "fromId": self.users[1].id, "timestamp": timestamp, "text": self.textInput.text!, "first": true] as [String : Any]
//        print(values)
//        
//        ref.updateChildValues(values, withCompletionBlock: {(err, ref) in
//            if err != nil {
//                print(err)
//                return
//            }
//            print("first message ref")
//            self.createUserMessages(messageId: ref.key)
//            
//            
//        })
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = users[0].id
        let fromId = users[1].id
        let timestamp = Int(Date().timeIntervalSince1970)
        let text = "From Setup: " + textInput.text!
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": text as AnyObject, "first": true as AnyObject, "read": false as AnyObject]
        
        

        
        
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
//            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-message").child(fromId!).child(toId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-message").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            let banner = NotificationBanner(title: "Success", subtitle: "Chat created!", style: .success)
            banner.autoDismiss = true
            banner.show()
        }
    }
    
//    func createUserMessages(messageId: String) {
//        let ref = base.child("user-message").child((user?.id)!)
//        let values = [messageId: 1] as [String : Any]
//        
//        ref.updateChildValues(values, withCompletionBlock: {(err, ref) in
//            if err != nil {
//                print(err)
//                return
//            }
//            //            print(ref)
//        })
//        let ref2 = base.child("user-message").child(users[1].id!)
//        let values2 = [messageId: 1] as [String : Any]
//        
//        ref2.updateChildValues(values, withCompletionBlock: {(err, ref) in
//            if err != nil {
//                print(err)
//                return
//            }
//            //            print(ref)
//        })
//    }
    
    
    
    func makeUserSetUp(setUpId: String) {
        let ref = base.child("user-setup").child((user?.id)!)
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
        print(timestamp)
        let values = [setUpId: 1] as [String : Any]
        print(values)
        
        ref.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if err != nil {
                print(err)
                return
            }
            //            print(ref.substring(from:ref.index(ref.endIndex, offsetBy: -20)))
        })
        
        
    }
    
    func createSetUp() {
        let ref = base.child("setup").childByAutoId()
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
        print(timestamp)
        let values = ["user1": self.users[0].id, "user2": self.users[1].id, "timestamp": timestamp] as [String : Any]
        print(values)
        
        ref.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if err != nil {
                print(err)
                return
            }
            print("setup ref")
            self.makeUserSetUp(setUpId: ref.key)
            //            print(ref.substring(from:ref.index(ref.endIndex, offsetBy: -20)))
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        user1Image.loadImageUsingCacheWithUrlString((users[0].profileImageURL)!)
        user2Image.loadImageUsingCacheWithUrlString((users[1].profileImageURL)!)
        user1Image.maskCircle()
        user2Image.maskCircle()
        user1Name.text = users[0].name
        user2Name.text = users[1].name
        mainView.layer.cornerRadius = 5;
        mainView.layer.masksToBounds = true;
        self.hideKeyboardWhenTappedAround()
        var downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.mainView.addGestureRecognizer(downSwipe)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    

    
   func goBack() {
    self.dismiss(animated: true, completion: {
//        let presenting = self.presentedViewController
//        let nav = presenting?.navigationController
            self.nav?.popToRootViewController(animated: true)
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
    public func maskCircle() {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
//        self.image = anyImage
    }
}
