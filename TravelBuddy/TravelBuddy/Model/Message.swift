//
//  Message.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import Foundation
import Firebase

class Message {
    
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func getChatPartnerId() -> String {
        guard let currentId = Auth.auth().currentUser?.uid else { return "" }
        if fromId == currentId {
            return toId
        } else {
            return fromId
        }
    }
}
