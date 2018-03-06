//
//  VerifyViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 2/21/18.
//  Copyright © 2018 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class VerifyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MADE IT TO VERIFT")
        self.code.delegate = self
        setUpButton()
        self.hideKeyboardWhenTappedAround()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    func doneButtonAction() {
        self.code.resignFirstResponder()
         loginOrCreate()
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.code.inputAccessoryView = doneToolbar
    }
    
    func setUpButton() {
        self.doneButton.backgroundColor = UIColor.white
        self.doneButton.setTitleColor(UIColor.black, for: .normal)
        self.doneButton.layer.cornerRadius = 15
        
        self.resendCodeButton.backgroundColor = UIColor.init(rgbColorCodeRed: 33, green: 192, blue: 252, alpha: 1)
        self.resendCodeButton.setTitleColor(UIColor.white, for: .normal)
        self.resendCodeButton.layer.cornerRadius = 15

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        loginOrCreate()
        
        return true
    }

    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButton(_ sender: Any) {
        loginOrCreate()
    }
    
    @IBAction func resendCode(_ sender: Any) {
        if let phoneNum = UserDefaults.standard.value(forKey: "phoneNumber") as? String {
            let phoneNumber = phoneNum
            
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            print("PHONE NUMBER", phoneNumber)
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
                if let error = error {
                    print("ERRORZZZZ BOYZ")
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    print(error)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVID")
                
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
                // pop up that code resent
                //            self.performSegue(withIdentifier: "something", sender: nil)
                // Sign in using the verificationID and the code sent to the user
                // ...
            }
        } else {
            // we don't have a phone number - so lets segue back to login
        }
    }
    
    
    func loginOrCreate() {
        if let vid = UserDefaults.standard.value(forKey: "authVID") as? String {
            let creds:PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: vid, verificationCode: code.text!)
            
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            Auth.auth().signIn(with: creds) { (the_user, error) in
                if error != nil {
                    print(error)
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    // handle error
                    // probably segue back
                    // or send new code
                } else {
                    let ref = Database.database().reference().child("users").child((the_user?.uid)!)
                    print("REF", ref)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        print("SNAPSHOT VALUE", snapshot.exists())
                        if snapshot.exists() {
                                print("USER DATA EXISTS DOES EXIsT")
                                UserDefaults.standard.set(nil, forKey: "loggin_status")
                                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "app")
                                UserDefaults.standard.setValue(true, forKey: "first")
                                self.show(vc, sender: self)
                            } else {
                                UserDefaults.standard.set("add_info", forKey: "loggin_status")
//                                DispatchQueue.main.async(execute: {
//                                    self.dismiss(animated: true, completion: nil)
//                                })
                                self.performSegue(withIdentifier: "add_info", sender: nil)
                            }
                    })
                    // logged in
                    // check to see if user has a name or not
                    // if user has a name
                        // set loggin_status to nil
                        // segue to app
                    // else
                        // set loggin_status to add_info
                        // segue to add info
                    
                }
            }
        } else {
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
            // need to resend code
            // segue to login screen
        }

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

