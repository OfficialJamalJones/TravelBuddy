//
//  User.swift
//  TravelBuddy
//
//  Created by Consultant on 1/20/23.
//

import CoreLocation
import Firebase

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    
    var firstInitial: String { return String(fullname.prefix(1)) }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
    
    static func getLastMessage(from fromId: String, completionHandler: (Message?) -> Void) {
        var messages = [Message]()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        USER_MESSAGES_REF.child(currentId).observe(.childAdded) { snapshot in
            
            print("USER_MESSAGES_REF1: \(snapshot)")
            let uid = snapshot.key
            if uid == fromId {
                USER_MESSAGES_REF.child(currentId).child(fromId).observe(.childAdded) { snapshot in
                    print("USER_MESSAGES_REF2: \(snapshot)")
                    let messageId = snapshot.key
                    MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
                        guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                        let message = Message(dictionary: dictionary)
                        print("Message: \(messages)")
                        messages.append(message)
                    }
                    
                }
            }
            
        }
        completionHandler(messages.last)
    }
    
    static func getMessages(from fromId: String, completionHandler: ([Message]) -> Void) {
        var messages = [Message]()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        USER_MESSAGES_REF.child(currentId).observe(.childAdded) { snapshot in
            
            print("USER_MESSAGES_REF1: \(snapshot)")
            let uid = snapshot.key
            if uid == fromId {
                USER_MESSAGES_REF.child(currentId).child(fromId).observe(.childAdded) { snapshot in
                    print("USER_MESSAGES_REF2: \(snapshot)")
                    let messageId = snapshot.key
                    MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
                        guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                        let message = Message(dictionary: dictionary)
                        print("Message: \(messages)")
                        messages.append(message)
                    }
                    
                }
            }
            
        }
        completionHandler(messages)
    }
    
    
}
