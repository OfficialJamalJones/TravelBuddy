//
//  ChatController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit
import Firebase

class ChatController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var collectionView: CollectionView!
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        self.observeMessages()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func pressedSendButton(_ sender: Any) {
        uploadMessage()
        textField.text = nil
    }
    
    func uploadMessage() {
        guard let messageText = textField.text else { return }
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValues = ["creationDate": creationDate, "fromId": currentId, "toId": user.uid, "messageText": messageText] as [String: Any]
        
        let messageRef = MESSAGES_REF.childByAutoId()
        messageRef.updateChildValues(messageValues)
        
        let userMessagesValues = [messageRef.key: 1]
        
        USER_MESSAGES_REF.child(currentId).child(user.uid).updateChildValues(userMessagesValues) { error, ref in
            print("Error: \(String(describing: error?.localizedDescription)) Ref: \(ref)")
        }
        USER_MESSAGES_REF.child(user.uid).child(currentId).updateChildValues(userMessagesValues) { error, ref in
            print("Error: \(String(describing: error?.localizedDescription)) Ref: \(ref)")
        }
    }
    
    func observeMessages() {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = user?.uid else { return }
        USER_MESSAGES_REF.child(currentId).child(chatPartnerId).observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            self.fetchMessage(withMessageId: messageId)
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.collectionView.messages.append(message)
            self.collectionView.reloadData()
        }
    }
    
}
