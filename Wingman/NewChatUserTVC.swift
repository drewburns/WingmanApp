//
//  NewChatUserTVC.swift
//  Wingman
//
//  Created by Andrew Burns on 9/2/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class NewChatUserTVC: UITableViewCell {
    var user:AppUser? {
        didSet {
            nameLabel.text! = (user?.name)!
            userNameLabel.text! = (user?.usernamesearch)!
            checkbox.setTitle("", for: .normal)
            userImage.maskCircle()
        }
    }
    let base = Database.database().reference()
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            checkbox.setTitle("✓", for: .normal)
        } else {
            checkbox.setTitle("", for: .normal)
        }
        // Configure the view for the selected state
    }
    
    


    
    @IBAction func clickCheckBox(_ sender: Any) {
        if isSelected == true {
            checkbox.setTitle("", for: .normal)
            isSelected = false
        } else {
            checkbox.setTitle("✓", for: .normal)
            isSelected = true
        }
    }

}
