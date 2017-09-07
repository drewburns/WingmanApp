//
//  SettingsViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 8/31/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textview: UITextView!
    var vc: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    

    
    func textViewDidChange(textView: UITextView) {

        
        
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
