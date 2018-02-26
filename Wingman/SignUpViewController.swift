//
//  SignUpViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
class SignUpViewController: UIViewController ,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
     var imagePicker = UIImagePickerController()

    @IBOutlet weak var sexPicker: UISwitch!
    
    @IBOutlet weak var createBUtton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.nameField.delegate = self
        self.usernameField.delegate = self
//        self.navigationController = ni
       let ref = Database.database().reference(fromURL: "https://wingman-d2039.firebaseio.com/")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
        userImage.maskCircle()
        
        self.createBUtton.backgroundColor = UIColor.white
        self.createBUtton.setTitleColor(UIColor.black, for: .normal)
        self.createBUtton.layer.cornerRadius = 15

        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.placeholder == "Username" {
            nameField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()  //if desired
            attemptCreate()
        }
        //textField code

        return true
    }
    
    @IBAction func privacy(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "privacy")
        self.show(vc, sender: self)
    }
    
    @IBAction func terms(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "terms")
        self.show(vc, sender: self)
    }
    
    func attemptCreate() {
        // update User and set loggin_status to nil
        // segue to app
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
        let storageRef = Storage.storage().reference().child("\(uid)-profile.png")

        if let uploadData = UIImagePNGRepresentation(self.userImage.image!) {
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();

            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            storageRef.putData(uploadData, metadata: nil , completion: {(metadata, error) in

                if error != nil {
                    print(error)
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    return
                }
                let name = self.nameField.text!
                let username = self.usernameField.text!
                var sex:String?
                if self.sexPicker.isOn == false {
                    sex = "Male"
                } else {
                    sex = "Female"
                }
                if let age = UserDefaults.standard.value(forKey: "age") {
                    var values = ["name": name,  "username":username, "namesearch": name.lowercased(), "usernamesearch": username.lowercased(), "profileImageURL": metadata?.downloadURL()?.absoluteString, "age": age, "sex": sex]
                    values["token"] = "none"
                    print("VALUES",values)
                    
                    
                    let ref = Database.database().reference().child("users").child(uid)
                    ref.updateChildValues(values)
                    // segue to app
                    UserDefaults.standard.set(nil, forKey: "loggin_status")
                    
                    //                DispatchQueue.main.async(execute: {
                    //
                    //                    self.dismiss(animated: true, completion: nil)
                    //                })
                    
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "app")
                    UserDefaults.standard.setValue(true, forKey: "first")
                    self.show(vc, sender: self)
                }

//                self.createUser(uid: uid, values: values )

            })
        }

    
    }
    
//    let name = nameField.text!
//    let username = usernameField.text!
//    var values = ["name": name,  "username":username, "namesearch": name.lowercased(), "usernamesearch": username.lowercased()]
//    values["token"] = "none"
//    if let uid = Auth.auth().currentUser?.uid {
//        let ref = Database.database().reference().child("users").child(uid)
//        ref.updateChildValues(values)
//        // segue to app
//        UserDefaults.standard.set(nil, forKey: "loggin_status")
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "app")
//        UserDefaults.standard.setValue(true, forKey: "first")
//        self.show(vc, sender: self)
//    } else {
//    // segue back to login
//    }
    
    @IBAction func selectImageButton(_ sender: Any) {
        self.setImage()
    }
    
//
//    func attemptCreate() {
//
//        Auth.auth().createUser(withEmail: email, password: password, completion: {(user: User? , err) in
//            if err != nil {
//                print(err)
//                return
//            }
//            //worked
//
//            guard let uid = user?.uid else {
//                return
//            }
//
////            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
////
////            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
////            loadingIndicator.hidesWhenStopped = true
////            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
////            loadingIndicator.startAnimating();
////
////            alert.view.addSubview(loadingIndicator)
////            self.present(alert, animated: true, completion: nil)
//
//
//            let storageRef = Storage.storage().reference().child("\(uid)-profile.png")
//
//            if let uploadData = UIImagePNGRepresentation(self.userImage.image!) {
//                let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
//
//                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//                loadingIndicator.hidesWhenStopped = true
//                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                loadingIndicator.startAnimating();
//
//                alert.view.addSubview(loadingIndicator)
//                self.present(alert, animated: true, completion: nil)
//                storageRef.putData(uploadData, metadata: nil , completion: {(metadata, error) in
//
//                    if error != nil {
//                        print(error)
//                        return
//                    }
//                    let name = self.nameField.text!
//                    let username = self.usernameField.text!
//
//                    var values = ["name": name,  "username":username, "namesearch": name.lowercased(), "usernamesearch": username.lowercased(), "profileImageURL": metadata?.downloadURL()?.absoluteString]
//                    values["token"] = "none"
//                    print("VALUES",values)
//
//
//                    self.createUser(uid: uid, values: values )
//
//                })
//                self.dismiss(animated: true, completion: nil)
//            }
//
//
//        })
//    }
//    func createUser(uid: String, values: [String:Any]) {
//        let ref = Database.database().reference(fromURL: "https://wingman-d2039.firebaseio.com/")
//        let usersref = ref.child("users").child(uid)
//
//
//
//        usersref.updateChildValues(values, withCompletionBlock: {( err,ref ) in
//            if err != nil {
//                print(err)
//                return
//            }
////            self.dismiss(animated: true, completion: nil)
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "app")
//            UserDefaults.standard.setValue(true, forKey: "first")
//            self.show(vc, sender: self)
//            print("Saved!")
//        })
//
//    }

    @IBAction func create(_ sender: Any) {
        
        var errors = [String]()
        if usernameField.text!.containsWhitespace == true {
            errors.append("Can't have whitespaces")
        }
        
        if usernameField.text!.characters.count < 3 {
            errors.append("Username must be longer than 3")
        }
        
        if nameField.text! == "" {
            errors.append("Enter a name")
        }

        let refUsers = Database.database().reference(fromURL: "https://wingman-d2039.firebaseio.com/").child("users")
        refUsers.queryOrdered(byChild: "username").queryEqual(toValue: usernameField.text!).observeSingleEvent(of: .value , with: {
            snapshot in
            
            if snapshot.exists() {
               errors.append("Username taken")
                
            }
            if errors.count > 0 {
                print(errors)
                let banner = NotificationBanner(title: "Error", subtitle: errors.joined(separator: ", "), style: .danger)
                banner.autoDismiss = true
                banner.show()
            } else {
                
                self.attemptCreate()
            }
            
        }) { error in
            
            print(error.localizedDescription)
            
        }

        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // image stuff 
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
        setImage()
        // Your action
    }
    
    func setImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.modalPresentationStyle = .overCurrentContext
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {

            /// if user update it and already got it , just return it to 'self.imgView.image'
            self.userImage.image = editedImage

            /// else if you could't find the edited image that means user select original image same is it without editing .
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            /// if user update it and already got it , just return it to 'self.imgView.image'.
            self.userImage.image = orginalImage
        }
        else { print ("error") }

        /// if the request successfully done just dismiss
        picker.dismiss(animated: true, completion: nil)
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

extension UIView {
    func setRadius(radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2;
        self.layer.masksToBounds = true;
    }
}

extension String {
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}
