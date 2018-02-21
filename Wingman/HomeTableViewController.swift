//
//  HomeTableViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class HomeTableViewController: UITableViewController {
    var user:AppUser?
    var messages = [Message]()
    var friends = [String]()
    var messagesDictionary = [String: Message]()
    var setupDictionary = [String: Message]()
//    var idArray:[String] = []
    @IBOutlet weak var meButton: UIBarButtonItem!
    let cellId = "cellId"
    var timer: Timer?
    var wentToChatWithUserId:String?
    let reachability = Reachability()!
    var internet = ""
    var fromLogin = ""
    var setupArray:[String] = []
    var setupsObserving:[String] = []
//    var newUser:AppUser?
    @IBOutlet weak var newChatButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let phoneNumer = "+18607346043"
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumer) { (verificationID, error) in
//            if let error = error {
//                print("ERRORZZZZ BOYZ")
//                print(error)
//                return
//            }
//            // Sign in using the verificationID and the code sent to the user
//            // ...
//        }

//        do {
//            try Auth.auth().signOut()
//        } catch let logerror {
//            print(logerror)
//        }

        if UserDefaults.standard.value(forKey: "first") == nil {
            print("loading wil not appear")
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
        }

        
        
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        meButton.isEnabled = false
        newChatButton.isEnabled = false
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
//            print(snapshot.value)
            if snapshot.exists() == true {
                
                // get num of friends
                
                if var value = snapshot.value as? [String:Any] {
                
                    value["id"] = snapshot.key
                    let newUser = AppUser()
                    newUser.setValuesForKeys(value)
                    self.user = newUser
                    DispatchQueue.main.async {
                        self.meButton.isEnabled = true
                        self.newChatButton.isEnabled =  true
                    }
                }
                let token = UserDefaults.standard.value(forKey: "token")
                print("user token", self.user?.token)
                if  ((self.user?.token) == "none")   {
                    print("We are about to save the user's token into firebase from HomeController")
                    if Auth.auth().currentUser != nil {
                        ref.child("users").child(userID!).updateChildValues(["token": token])
                        self.user?.token = token as! String?
                        UserDefaults.standard.removeObject(forKey: "token")
                    }
                }
//                let string = "https://wingman-notifs.herokuapp.com/send?token=" + (self.user?.token)!
//                print("STRING", string)
//                
//                let request = URLRequest(url: URL(string: string)!)
//                let connection = NSURLConnection(request: request, delegate:nil, startImmediately: true)

                
                print(self.user?.name)
                UserDefaults.standard.set(self.user?.name, forKey: "username")
                print("STORED USER NAME",UserDefaults.standard.string(forKey: "username"))
//                print(self.user?.id)
            } else{
                self.performSegue(withIdentifier: "login", sender: nil)

            }
            
        // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        // get friendship
//        ref.child("friendships").child(userID!).observe(.childAdded, with: {(snapshot) in
//            if snapshot.exists() {
////                print(snapshot.value)
//            } else {
////                print("No friends found")
//            }
//        })
        


        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(SetupCell.self, forCellReuseIdentifier: "setId")
        tableView.allowsMultipleSelectionDuringEditing = true
        messages.removeAll()
        friends.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        getMessagesAndFriends()
        print("Dis", self.isBeingDismissed)
        print("Pres", self.isBeingPresented)
        if UserDefaults.standard.value(forKey: "first") == nil {
            print("yessdaskdsldasks")
            self.dismiss(animated: false, completion: nil)
            UserDefaults.standard.removeObject(forKey:"first")
            UserDefaults.standard.synchronize()
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        

        
    }

    func internetChanged(note: Notification) {
 
    }
    
    
    
    func getMessagesAndFriends() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
 
        
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? [String:[String:Any]] {
                for chatpartner in data {
                    //                let userId = chatpartner.key
                    //                print("User",chatpartner.key)
                    
                    for message in (chatpartner.value) {
                        //                    print(message.value)
                        self.fetchMessageWithMessageId(message.key)
                    }
                } 
            }

        
        })
        
        let setupref = Database.database().reference().child("user-setup").child(uid)
        
        setupref.observeSingleEvent(of: .value, with: {(snapshot) in
            //            print("SETUPS", snapshot.value)
            
            if let setups = snapshot.value as? [String:Any] {
                for setup in setups {
                    
                    print("Setup:", setup)
                    let ref4 = Database.database().reference().child("setup-messages").child(setup.key)
                    ref4.observeSingleEvent(of: .value, with: { (snapshot2) in
                        
                        if let setupmessages = (snapshot2.value as? [String:Any]) {
                            self.setupArray.append(setup.key)
                            for setupmessage in setupmessages {
                                print("MESSAGES")
                                print(setupmessage)
                                self.fetchMessageWithMessageIdSetup(setupmessage.key, setup.key, setupmessage.value as! Int)
                            }
                            
                        }
                    })
                }
            }
            
        })
        let ref2 = Database.database().reference().child("added-friendships").child(uid)
        ref2.observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? [String:Any] {
                for friend in data {
                    //                    print(friend.key)
                    self.friends.append(friend.key)
                }
            }
            //            print("Friends in" , self.friends)
            print("Finished getting values")
            self.observeUserMessages()
        })
        


        
    }
    
    func fetchUserWithId(id: String) {
        
    }

    func observeUserMessages() {

        print("Friends2" , friends)
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
//            print("Found the user-message")
            let userId = snapshot.key
            Database.database().reference().child("user-message").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
//                print("Found next things")

                let messageId = snapshot.key
            
                self.fetchMessageWithMessageId2(messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in

//            print(snapshot.key)
//            print(self.messagesDictionary)
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
        let newref = Database.database().reference().child("added-friendships").child(uid)
//        print("Friends" , friends)
        print("Started Observing")
        newref.observe(.childAdded, with: {(snapshot) in
//            print(self.friends)
//            print(snapshot.key)
            if self.friends.contains(snapshot.key) {
                // do nothing
            } else {
                self.friends.append(snapshot.key)
                self.showFriendBanner(id: snapshot.key)
            }
        })
        print("made it to here")
        
        print("SETUPARRY", setupArray)
        for setup in setupArray {
            let ref10 = Database.database().reference().child("setup-messages").child(setup)
            ref10.observe(.childAdded, with: { (snapshot0) in
                
                self.fetchMessageWithMessageIdSetup2(snapshot0.key, setup, snapshot0.value as! Int)
            }, withCancel: nil)
        }
//
        let setupref = Database.database().reference().child("user-setup").child(uid)
        
        
        setupref.observe(.childAdded, with: {(snapshot1) in
            if self.setupArray.contains(snapshot1.key) {
                print("ALREADY HAVE IT")
            } else {
                print("GOT  ADWD WJNEIWND")
                let newref2 = Database.database().reference().child("setup-messages").child(snapshot1.key)
                
                newref2.observe(.childAdded, with: { (snapshot34) in
                    self.fetchMessageWithMessageIdSetup2(snapshot34.key, snapshot1.key, snapshot34.value as! Int)
                }, withCancel: nil)
            }
        })
        
        
    }
    
    func showFriendBanner(id: String) {
//        newUser = nil
        let ref = Database.database().reference().child("users").child(id)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if var data = snapshot.value as? [String:Any] {
                data["id"] = snapshot.key
                let newuser = AppUser()
                newuser.setValuesForKeys(data)
                let banner = NotificationBanner(title: newuser.name! + " added you as a friend!", subtitle: "Click to view profile", style: .success)
                
                banner.autoDismiss = true
                banner.show(queuePosition: .front)
                banner.onTap = {
                    self.performSegue(withIdentifier: "me", sender: newuser)
                }
            }

        })

    }
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
    
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                dictionary["id"] = snapshot.key as AnyObject?
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    if (self.messagesDictionary[chatPartnerId]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                        self.messagesDictionary[chatPartnerId] = message
                    }
                    
                }
                
                
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)

    }
    
    fileprivate func fetchMessageWithMessageIdSetup(_ messageId: String, _ setupId: String,_ read: Int) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                dictionary["id"] = snapshot.key as AnyObject?
                dictionary["setup"] = true  as AnyObject?
                print("ADWDAWDWADWAD", read)
                if read == 0 {
                    dictionary["read"] = false as AnyObject?
                } else {
                    dictionary["read"] = true as AnyObject?
                }
                let message = Message(dictionary: dictionary)
                let uniqueId = message.toId! + message.fromId!
                let unique2 = message.fromId! + message.toId!
                print("UNIQUE", uniqueId)
                print("OTestld", self.setupDictionary[uniqueId]?.timestamp?.int32Value < message.timestamp?.int32Value)
    
                
                    if (self.setupDictionary[uniqueId]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                        self.setupDictionary[uniqueId] = message
                    }
                
                    if (self.setupDictionary[unique2]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                        self.setupDictionary[unique2] = message
                    }
                
                if self.setupDictionary[uniqueId.splitByLength(28).reversed().joined(separator: "")] != nil {
                    self.setupDictionary[unique2] = nil
                }
                
                print("SETUPPPPP", self.setupDictionary)
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
        
    }
    
    
    fileprivate func fetchMessageWithMessageIdSetup2(_ messageId: String, _ setupId: String,_ read: Int) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                dictionary["id"] = snapshot.key as AnyObject?
                dictionary["setup"] = true  as AnyObject?
                print("ADWDAWDWADWAD", read)
                if read == 0 {
                    dictionary["read"] = false as AnyObject?
                } else {
                    dictionary["read"] = true as AnyObject?
                }
                let message = Message(dictionary: dictionary)
                let uniqueId = message.toId! + message.fromId!
                let unique2 = message.fromId! + message.toId!
                print("UNIQUE", uniqueId)
                print("OTestld", self.setupDictionary[uniqueId]?.timestamp?.int32Value < message.timestamp?.int32Value)
                
                if (self.setupDictionary[uniqueId]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                    self.setupDictionary[uniqueId] = message
                }
                
                if (self.setupDictionary[unique2]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                    self.setupDictionary[unique2] = message
                }
                
                if self.setupDictionary[uniqueId.splitByLength(28).reversed().joined(separator: "")] != nil {
                    self.setupDictionary[unique2] = nil
                }
                
                
                print("SETUPPPPP", self.setupDictionary)
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
        
    }
    
    func usernameFromId(_ id: String) -> String {
        let ref = Database.database().reference().child("users").child(id)
        var name = ""
        ref.observeSingleEvent(of: .value, with: {(snap) in
            print("SNAP VALUE", snap.value)
            if let data = snap.value as? [String:Any] {
                let name1 = data["name"] as? String
                name = name1!.components(separatedBy: " ")[0]
                print("adwidioawokdwa", name)
            } else {
                name = ""
            }
        })
        return name
    }
    
    fileprivate func fetchMessageWithMessageId2(_ messageId: String) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                dictionary["id"] = snapshot.key as AnyObject?
                let message = Message(dictionary: dictionary)
//                self.idArray.append(message.id!)
                
                if let chatPartnerId = message.chatPartnerId() {
                    if self.messagesDictionary[chatPartnerId] == message {
                        // it already exsits
//                        print("NOT WHAT I WANT")
                    } else {
                        if (self.messagesDictionary[chatPartnerId]?.timestamp?.int32Value < message.timestamp?.int32Value) {
                            self.messagesDictionary[chatPartnerId] = message
                            self.showBanner(message: message)
                    
                        }
                    }

                    
                }
                
//                print("Got a truly new value")
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    func showBanner(message: Message) {
        if (message.fromId != Auth.auth().currentUser?.uid && message.fromId != wentToChatWithUserId)  {
            let ref = Database.database().reference().child("users").child(message.fromId!)

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any] {
                    var content = message.text
                
                    if message.imageUrl != nil {
                        content = "Image"
                    }
                    if message.videoUrl != nil {
                        content = "Video"
                    }
                    let banner = NotificationBanner(title: dictionary["name"] as! String, subtitle: content, style: .success)
                    banner.autoDismiss = true
                    banner.show(queuePosition: .front)
                    print("BANNNNNNNNNNNNNNNER")

                    
                }
            }, withCancel: nil)


        }
    }

    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        let temp = Array(self.messagesDictionary.values) + Array(self.setupDictionary.values)
        self.messages = temp
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
        })
//        print(messages.count)
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func showChatControllerForUser(_ user: AppUser) {
        print("SHOWING CHAT LOG")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.currentUserName = (self.user?.name)!
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func showSetupChatControllerForUser(_ user: AppUser,_ user2:AppUser, _ setupId: String) {
        print("SHOWING SETUP LOG")
        let chatLogController = SetUpChatLog(collectionViewLayout: UICollectionViewFlowLayout())
        print("DWADWD", setupId)
        chatLogController.setupId = setupId
        chatLogController.user2 = user2
        chatLogController.user = user
        chatLogController.currentUserName = (self.user?.name)!

        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @IBAction func meClicked(_ sender: Any) {
        goToUser()
    }
    
    func goToUser() {
        performSegue(withIdentifier: "me", sender: user)
    }
    
    @IBAction func newChat(_ sender: Any) {
        performSegue(withIdentifier: "new", sender: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.removeBadges()
        self.attemptReloadOfTable()
        if messagesDictionary.count > 0 {
            if wentToChatWithUserId != nil {
                messagesDictionary[wentToChatWithUserId!]?.read = true
            }
            
        }
         wentToChatWithUserId = ""
        print("VIEW APPEARED")
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
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//         print("MESSAGES HERE", messages)
        let message = messages[indexPath.row]
        if message.setup == true {
//            print("THIS IS A SETUPPP")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setId", for: indexPath) as! SetupCell
            cell.user1 = message.toId
            cell.user2 = message.fromId
            
            cell.message = message
            return cell
        } else {
//            print("THIS IS NOT SETUPPP")
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell.message = message
            return cell
        }
        

       
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTED")
        let message = messages[indexPath.row]
        if message.setup == true {
            
//            if message.toId == Auth.auth().currentUser?.uid {
//                let messageRef = Database.database().reference().child("messages").child(message.id!)
//                print("made read true")
//                
////                messageRef.updateChildValues(["read":true])
                messages[indexPath.row].read = true
////                self.handleReloadTable()
//            }
            
            let thesetupId = message.setupId
            print("THE SET UP IS", thesetupId)
            let ref = Database.database().reference().child("users").child(message.fromId!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let user = AppUser()
                user.setValuesForKeys(dictionary)
                user.id = message.fromId
                let ref2 = Database.database().reference().child("users").child(message.toId!)
                ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let user2 = AppUser()
                    user2.setValuesForKeys(dictionary)
                    user2.id = message.toId
                    //                self.wentToChatWithUserId = chatPartnerId
                    self.showSetupChatControllerForUser(user,user2, thesetupId!)
                    
                }, withCancel: nil)
//                self.wentToChatWithUserId = chatPartnerId
                
            }, withCancel: nil)
            
        } else {
            guard let chatPartnerId = message.chatPartnerId() else {
                return
            }
            
            if message.toId == Auth.auth().currentUser?.uid {
                let messageRef = Database.database().reference().child("messages").child(message.id!)
                print("made read true")
                
                messageRef.updateChildValues(["read":true])
                messages[indexPath.row].read = true
                self.handleReloadTable()
            }
            
            
            
            let ref = Database.database().reference().child("users").child(chatPartnerId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let user = AppUser()
                user.setValuesForKeys(dictionary)
                user.id = chatPartnerId
                self.wentToChatWithUserId = chatPartnerId
                self.showChatControllerForUser(user)
                
            }, withCancel: nil)
        }

    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-message").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
                //                //this is one way of updating the table, but its actually not that safe..
                //                self.messages.removeAtIndex(indexPath.row)
                //                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            })
        }
    }

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
            viewController.user = sender as? AppUser
            viewController.currentUserName = (self.user?.name)!
            
        } else if segue.identifier == "new"{
            let viewController:CreateChatTableViewController = segue.destination as! CreateChatTableViewController
            viewController.user = self.user
        }
        
    }
    

}





extension String {
    func splitByLength(_ length: Int) -> [String] {
        var result = [String]()
        var collectedCharacters = [Character]()
        collectedCharacters.reserveCapacity(length)
        var count = 0
        
        for character in self.characters {
            collectedCharacters.append(character)
            count += 1
            if (count == length) {
                // Reached the desired length
                count = 0
                result.append(String(collectedCharacters))
                collectedCharacters.removeAll(keepingCapacity: true)
            }
        }
        
        // Append the remainder
        if !collectedCharacters.isEmpty {
            result.append(String(collectedCharacters))
        }
        
        return result
    }
}


