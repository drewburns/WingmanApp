//
//  Message.swift
//  Wingman
//
//  Created by Andrew Burns on 9/5/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var videoUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var first: Bool?
    var read: Bool?
    var id: String?
    var setup: Bool?
    var setupId: String?
    var userWhoSetup: String?

    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.videoUrl = dictionary["videoUrl"] as? String
        
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.first = dictionary["first"] as? Bool
        self.read = dictionary["read"] as? Bool
        self.id = dictionary["id"] as? String
        self.setup = dictionary["setup"] as? Bool
        self.setupId = dictionary["setupId"] as? String
        self.userWhoSetup = dictionary["userWhoSetup"] as? String
    
    }
    
    func chatPartnerId() -> String? {
        print("current ", Auth.auth().currentUser?.uid)
        print("fromID ", fromId)
        print("toId ", toId)
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}
