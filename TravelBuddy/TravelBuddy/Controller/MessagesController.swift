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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMessages()
        
    }
    
    func fetchMessages() {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        USER_MESSAGES_REF.child(currentId).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            USER_MESSAGES_REF.child(currentId).child(uid).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
            }
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
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!  MessagesCell

        let message = messages[indexPath.row]
        cell.message = message
        cell.profileImage.image = UIImage(systemName: "person")
        cell.nameLabel.text = "Jamal"
        cell.typeLabel.text = "Passenger"
        cell.timeLabel.text = "4h"

        return cell
    }
    

    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row: \(indexPath.row)")
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ChatController
        //get from user
        
        let uid = "YoASw2J3UZQ6ff2LNzMfq3ut2Ii2"
        let dict = ["fullname": "test", "email": "test@yopmail.com", "accountType": 0] as [String : Any]
        destinationVC.user = User(uid: uid, dictionary: dict)
            
    }
    

}
