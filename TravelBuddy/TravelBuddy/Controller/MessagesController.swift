//
//  MessagesController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    let reuseIdentifier = "MessagesCell"
    
    var messages = [Message]()
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsers()
        DispatchQueue.main.async {
            
        }
        
    }
    
    func fetchUsers() {
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        REF_USERS.getData { error, snapshot in
            print("User Snapshot: \(snapshot)")
            if let values = snapshot?.value as? [String: Any] {
                for value in values {
                    if value.key != currentId {
                        REF_USERS.child(value.key).getData { error, snapshot in
                            if let dictionary = snapshot?.value as? [String: Any] {
                                let user = User(uid: snapshot!.key, dictionary: dictionary)
                                self.users.append(user)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    
    func fetchMessages() {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        USER_MESSAGES_REF.child(currentId).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            USER_MESSAGES_REF.child(currentId).child(uid).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                if currentId != messageId {
                    self.fetchMessage(withMessageId: messageId)
                }
                
            }
            print("\nMessages: \(self.messages)")
        }
        
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        print("One Section")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!  MessagesCell
        let user = self.users[indexPath.row]
        cell.user = user
        cell.profileImage.image = UIImage(systemName: "person")
        cell.nameLabel.text = user.fullname
        if cell.user?.accountType == .passenger {
            cell.typeLabel.text = "Passenger"
        } else {
            cell.typeLabel.text = "Driver"
        }
        
        return cell
        
    }
    

    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row: \(indexPath.row)")
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ChatController
        
        let cell = sender as! MessagesCell
        destinationVC.user = cell.user
            
    }
    

}
