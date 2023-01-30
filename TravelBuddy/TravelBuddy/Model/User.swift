//
//  User.swift
//  TravelBuddy
//
//  Created by Consultant on 1/20/23.
//

import CoreLocation
import Firebase
import FirebaseStorage

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
    var image: UIImage?
    var imageString: String?
    
    var firstInitial: String { return String(fullname.prefix(1)) }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.imageString = dictionary["imageString"] as? String
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
    
    static func loadImage(imageString: String, completion: @escaping (UIImage?) -> Swift.Void) {
        let storageref = Storage.storage().reference().child(imageString)
        storageref.getData(maxSize: (1 * 1024 * 1024)) { data, error in
            if let error = error{
                print(error.localizedDescription)
            } else {
                if let data  = data {
                    let myImage:UIImage! = UIImage(data: data)
                    completion(myImage)
                }
            }
        }
        
    }
    
    static func uploadImage(image: UIImage, completion: @escaping () -> Swift.Void) {
        let storageref = Storage.storage().reference()
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let imagenode = storageref.child(currentUserId)
        imagenode.putData(image.pngData()!)
    }
    
    static func getUser(_ completion: @escaping (_ user: User) -> ()) {
        let currentUser = Auth.auth().currentUser
        var user = User(uid: "", dictionary: ["":""])
        if let currentUser = currentUser {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
            REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { snapshot in
              // Get user value
                let dict = snapshot.value as? NSDictionary
                user = User(uid: currentUser.uid, dictionary: dict as! [String : Any])
                completion(user)
            
              // ...
            }) { error in
              print(error.localizedDescription)
            }
            
          
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
