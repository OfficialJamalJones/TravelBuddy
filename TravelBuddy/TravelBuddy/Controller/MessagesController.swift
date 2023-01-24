//
//  MessagesController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit

class MessagesController: UITableViewController {

    let reuseIdentifier = "MessagesCell"
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        return 5
        //return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!  MessagesCell

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
        
        let uid = "100"
        let dict = ["fullname": "Jamal", "email": "email", "accountType": 0] as [String : Any]
        destinationVC.user = User(uid: uid, dictionary: dict)
            
    }
    

}
