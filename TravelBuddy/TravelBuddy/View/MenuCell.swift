//
//  MenuCell.swift
//  TravelBuddy
//
//  Created by Consultant on 2/1/23.
//

import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
