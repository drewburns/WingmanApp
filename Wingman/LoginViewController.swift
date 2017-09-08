//
//  LoginViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Login")
        self.hideKeyboardWhenTappedAround() 

        // Do any additional setup after loading the view.
    }
    @IBAction func attemptLogin(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {
            print("Errors")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                print(error.unsafelyUnwrapped.localizedDescription)
                let banner = NotificationBanner(title: "Error", subtitle: "Incorrect Login", style: .danger)
                banner.autoDismiss = true
                banner.show()
                return
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "app")
            self.show(vc, sender: self)
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
