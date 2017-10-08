//
//  UserCell.swift
//  Wingman
//
//  Created by Andrew Burns on 9/5/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class SetupCell: UITableViewCell {
    
    var user1:String?
    
    
    var user2:String?
    var message: Message? {
        didSet {
            
            setUserInfo()
            print("READ OR UNDREAD", message?.read!)
            if message?.read! == false {
                //                unreadMarker.isHidden = false
                //                detailTextLabel?.textColor = UIColor.blue
                profileImageView.layer.borderWidth = 2
                
                profileImageView.layer.borderColor = UIColor.blue.cgColor
                profileImageView2.layer.borderWidth = 2
                
                profileImageView2.layer.borderColor = UIColor.blue.cgColor
                timeLabel.textColor = UIColor.blue
            } else {
                //                detailTextLabel?.textColor = UIColor.black
                profileImageView.layer.borderWidth = 0
                timeLabel.textColor = UIColor.black
                profileImageView.layer.borderColor = UIColor.red.cgColor
                
                profileImageView2.layer.borderWidth = 0
//                timeLabel.textColor = UIColor.black
                profileImageView2.layer.borderColor = UIColor.red.cgColor
                //                unreadMarker.isHidden = true
                
            }
            if message?.text != nil{
                let str = message?.text
                if (str?.characters.count)! < 30 {
                    detailTextLabel?.text = str
                } else {
                    let index = str?.index((str?.startIndex)!, offsetBy: 30)// Hello
                    detailTextLabel?.text = (str?.substring(to: index!))! + " ..."
                }
                
            } else {
                detailTextLabel?.text = "Image/Video"
            }
            
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate.init(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserInfo() {
//        self.textLabel?.font = textLabel?.font.withSize(12)
        if let id = user1 {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any] {
                    self.textLabel?.text = (dictionary["name"] as? String)?.components(separatedBy: " ")[0]
                    
                    if let profileImage = dictionary["profileImageURL"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
                        self.profileImageView.maskCircle()
                    }
                    
                    
                }
                
                if let id2 = self.user2 {
                    let ref2 = Database.database().reference().child("users").child(id2)
                    ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String:Any] {
                            
                            let addition = (dictionary["name"] as? String)?.components(separatedBy: " ")[0]
                            self.textLabel?.text =  (self.textLabel?.text)! + " & " +  addition!
                            print("SNAPSHOT",self.textLabel?.text)
                            if let profileImage = dictionary["profileImageURL"] as? String {
                                self.profileImageView2.loadImageUsingCacheWithUrlString(profileImage)
                                self.profileImageView2.maskCircle()
                            }
                            
                            
                        }
                    }, withCancel: nil)
                }
            }, withCancel: nil)
        }
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let profileImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let unreadMarker: UIView = {
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        
        //        circle.center = self.center
        circle.layer.cornerRadius = 50
        circle.backgroundColor = UIColor.black
        circle.clipsToBounds = true
        
        
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        var blurView = UIVisualEffectView(effect: darkBlur)
        
        blurView.frame = circle.bounds
        
        return circle
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        self.layer.
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(profileImageView2)
        addSubview(timeLabel)
        //        addSubview(unreadMarker)
        //        addSubview(unreadMarker)
        
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        ////
        //        unreadMarker.rightAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        //        unreadMarker.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //        unreadMarker.widthAnchor.constraint(equalToConstant: 10).isActive = true
        //        unreadMarker.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        profileImageView2.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 21).isActive = true
        profileImageView2.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 8.0).isActive = true
        profileImageView2.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView2.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
