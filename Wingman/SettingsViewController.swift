//
//  SettingsViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class SettingsViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var user:AppUser?
    let reachability = Reachability()!
    var internet = ""
    var vc: UIViewController?
     var imagePicker = UIImagePickerController()
    
    func internetChanged(note: Notification) {
        
    }
    
    @IBAction func changeProfile(_ sender: Any) {
        changeProfileImage()
    }
    
    func changeProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.modalPresentationStyle = .overCurrentContext
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let banner = NotificationBanner(title: "Error", subtitle: "Enable photo access", style: .danger)
            banner.autoDismiss = true
            banner.show()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'
            self.imageView.image = editedImage
            
            self.uploadImageAndSave(image: editedImage)
            
            /// else if you could't find the edited image that means user select original image same is it without editing .
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'.
            self.imageView.image = orginalImage
        }
        else { print ("error") }
        
        /// if the request successfully done just dismiss
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func uploadImageAndSave(image: UIImage) {
        let uid = self.user?.id
        let storageRef = Storage.storage().reference().child("\(uid)-profile.png")
        if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
            storageRef.putData(uploadData, metadata: nil , completion: {(metadata, error) in
                
                if error != nil {
                    print(error)
                    let banner = NotificationBanner(title: "Error", subtitle: "Failed to upload", style: .danger)
                    banner.autoDismiss = true
                    banner.show()
//                    DispatchQueue.main.async(execute: {
//                        self.dismiss(animated: true, completion: nil)
//                    })
                    return
                }
                if let age = UserDefaults.standard.value(forKey: "age") {
                    var values = ["profileImageURL": metadata?.downloadURL()?.absoluteString]
                    print("VALUES",values)
                    
                    
                    let ref = Database.database().reference().child("users").child(uid!)
                    ref.updateChildValues(values)
                    // segue to app
                    let banner = NotificationBanner(title: "Success", subtitle: "Profile image will be changed when app is relaunched!", style: .success)
                    banner.autoDismiss = true
                    banner.show()
                }
                
                //                self.createUser(uid: uid, values: values )
                
            })
        }
    }
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        changeProfileImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.user?.profileImageURL == nil {
            imageView.image = #imageLiteral(resourceName: "logo")
        } else {
            imageView.loadImageUsingCacheWithUrlString((self.user?.profileImageURL)!)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.maskCircle()
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
    
    

    

    @IBAction func logout(_ sender: Any) {
        handleLogout()
    }
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logerror {
            print(logerror)
        }
        
        self.dismiss(animated: true, completion: {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "login")
            self.vc?.show(vc, sender: self)
        
        })

    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func contact(_ sender: Any) {
        let email = "wingmanapphelp@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                let alert = UIAlertController(title: "Contact", message: "Email to: wingmanapphelp@gmail.com ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func terms(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "terms")
        self.vc?.show(vc, sender: self)
    }
    
    @IBAction func privacy(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "privacy")
        self.vc?.show(vc, sender: self)
    }
    
    
    @IBAction func credits(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "credits")
        self.vc?.show(vc, sender: self)
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
