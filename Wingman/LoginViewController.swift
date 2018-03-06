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

class LoginViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var agePicker: UIPickerView!
    
    var pickerDataSource = [Int](1...100) as! [Any]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        print("Login")
        pickerDataSource.insert("Select Age", at: 0)
        print(pickerDataSource)
        agePicker.dataSource = self
        agePicker.delegate = self
        setUpNextButton()
        self.addDoneButtonOnKeyboard()
        
        self.hideKeyboardWhenTappedAround() 

        // Do any additional setup after loading the view.
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
        
        self.emailField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.emailField.resignFirstResponder()
        attemptLogin("nothing")
    }
    
    @IBAction func privacy(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "privacy")
        self.show(vc, sender: self)
    }
    
    func setUpNextButton() {
//        self.nextButton.backgroundColor = UIColor.init(rgbColorCodeRed: 33, green: 192, blue: 252, alpha: 1)
//        self.nextButton.setTitleColor(UIColor.white, for: .normal)
//        self.nextButton.layer.cornerRadius = 15
        
        self.nextButton.backgroundColor = UIColor.white
        self.nextButton.setTitleColor(UIColor.black, for: .normal)
        self.nextButton.layer.cornerRadius = 15
//        560E10 86,14,16
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let string = String(describing: pickerDataSource[row])
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        textField.resignFirstResponder()  //if desired
        attemptLogin("WHo cares")
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let x = pickerDataSource[row]
        return String(describing: x)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // use the row to get the selected row from the picker view
        // using the row extract the value from your datasource (array[row])
    }
    
    @IBAction func attemptLogin(_ sender: Any) {
        if pickerDataSource[agePicker.selectedRow(inComponent: 0)] as? String == "Select Age" {
            let banner = NotificationBanner(title: "Error", subtitle: "Select an age", style: .danger)
            
            banner.autoDismiss = true
            banner.show(queuePosition: .front)
            return
        }
        
        let selectedValue = pickerDataSource[agePicker.selectedRow(inComponent: 0)] as! Int
        print("SELCETED VALUE", selectedValue)
        if selectedValue < 13 {
            let banner = NotificationBanner(title: "Error", subtitle: "You must be at least 13 to use Wingman", style: .danger)
            
            banner.autoDismiss = true
            banner.show(queuePosition: .front)
        } else {
            let phoneNumber = "+1" + emailField.text!
            if UserDefaults.standard.value(forKey: "token") == nil || UserDefaults.standard.value(forKey: "token") as? String == "None" {
                print("WE GOT AN ERROR!")
                let banner = NotificationBanner(title: "Error", subtitle: "Notifications need to be enabled", style: .danger)
                banner.autoDismiss = true
                banner.show(queuePosition: .front)
                return
            }
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
                if error != nil {
                    print("WE GOT AN ERROR!", error)
                    let banner = NotificationBanner(title: "Error", subtitle: "Invalid Phone Number", style: .danger)
                    banner.autoDismiss = true
                    banner.show(queuePosition: .front)
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    return
                }
                UserDefaults.standard.set(self.pickerDataSource[self.agePicker.selectedRow(inComponent: 0)] as! Int, forKey: "age")
                UserDefaults.standard.set(verificationID, forKey: "authVID")
                UserDefaults.standard.set("verify", forKey: "loggin_status")
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                
//                DispatchQueue.main.async(execute: {
//                    self.dismiss(animated: true, completion: nil)
//                })
                
                self.performSegue(withIdentifier: "code_sent", sender: nil)
                // Sign in using the verificationID and the code sent to the user
                // ...
            }
        }
//        guard let email = emailField.text, let password = passwordField.text else {
//            print("Errors")
//            return
//        }
//        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
//            if error != nil {
//                print(error.unsafelyUnwrapped.localizedDescription)
//                let banner = NotificationBanner(title: "Error", subtitle: "Incorrect Login", style: .danger)
//                banner.autoDismiss = true
//                banner.show()
//                return
//            }
//
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "app")
//            UserDefaults.standard.setValue(true, forKey: "first")
//            self.show(vc, sender: self)
//
//        })
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
