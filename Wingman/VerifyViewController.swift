//
//  VerifyViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 2/21/18.
//  Copyright © 2018 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class VerifyViewController: UIViewController {

    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButton(_ sender: Any) {
        loginOrCreate()
    }
    
    @IBAction func resendCode(_ sender: Any) {
        if let phoneNum = UserDefaults.standard.value(forKey: "phone_number") as? String {
            let phoneNumber = "+1" + phoneNum
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
                if let error = error {
                    print("ERRORZZZZ BOYZ")
                    print(error)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVID")
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
            Auth.auth().signIn(with: creds) { (user, error) in
                if error != nil {
                    // handle error
                    // probably segue back
                    // or send new code
                } else {
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
