//
//  ChatCell.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
    }
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        
        
    }
    
//    func adjustCellPosition(direction: String) {
//        var anchors = [NSLayoutConstraint]()
//        let leftAnchor = self. self.contentView.leadingAnchor.constraint(equalTo: )
//        if direction == "left" {
//            anchors.append(view.topAnchor.constraint(equalTo: gamePreview.topAnchor, constant: 0))
//        } else {
//            
//        }
//           anchors.append(view.topAnchor.constraint(equalTo: gamePreview.topAnchor, constant: 0))
//           anchors.append(view.leadingAnchor.constraint(equalTo: gamePreview.leadingAnchor, constant: 0))
//           anchors.append(view.trailingAnchor.constraint(equalTo: gamePreview.trailingAnchor, constant: 0))
//           anchors.append(view.heightAnchor.constraint(equalTo: gamePreview.heightAnchor, multiplier: 1, constant: 131))
//           NSLayoutConstraint.activate(anchors)
//    }
    
}
