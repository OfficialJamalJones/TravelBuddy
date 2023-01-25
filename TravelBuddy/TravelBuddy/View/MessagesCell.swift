//
//  MessagesCell.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit
import Firebase

class MessagesCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var user: User?
    
    var message: Message? {
        
        didSet {
    
            if let seconds = message?.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: seconds)
            }
            
            self.configureUserData()
        }
    }
    
    func configureUserData() {
        guard let chatPartnerId = self.message?.getChatPartnerId() else { return }
        REF_USERS.child(chatPartnerId).getData { error, snapshot in
            let snap = snapshot?.value
            print("\nMessage Cell Snapshot: \(snap)")
            
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

}
