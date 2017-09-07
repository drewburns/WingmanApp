//
//  UserCell.swift
//  Wingman
//
//  Created by Andrew Burns on 9/5/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setUserInfo()
//            if message?.read! == false {
//                unreadMarker.isHidden = false
//            } else {
//                unreadMarker.isHidden = true
//            }
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
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImage = dictionary["profileImageURL"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
                        self.profileImageView.maskCircle()
                    }
                    
                    
                }
            }, withCancel: nil)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
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
    
//    let unreadMarker: UIView = {
//        let marker = UIView()
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: ,y: 50), radius: CGFloat(5), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
//        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = circlePath.cgPath
//        
//        //change the fill color
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        //you can change the stroke color
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        //you can change the line width
//        shapeLayer.lineWidth = 3.0
//        marker.layer.addSublayer(shapeLayer)
//        
//        return marker
//    }()
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.layer.
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
//        addSubview(unreadMarker)

        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        
//        unreadMarker.rightAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
//        unreadMarker.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        unreadMarker.widthAnchor.constraint(equalToConstant: 10).isActive = true
//        unreadMarker.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
