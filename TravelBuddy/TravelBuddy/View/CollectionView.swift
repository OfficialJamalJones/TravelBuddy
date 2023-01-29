//
//  CollectionView.swift
//  TravelBuddy
//
//  Created by Consultant on 1/24/23.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class CollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var messages = [Message]()
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.dataSource = self
            self.delegate = self
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        return NSString(string: text).boundingRect(with: size, context: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        guard let currentId = Auth.auth().currentUser?.uid else { return UICollectionViewCell() }
        let message = self.messages[indexPath.row]
        let fromId = self.messages[indexPath.row].fromId
        if fromId == currentId {
            cell.leftLabel.backgroundColor = .clear
            cell.rightLabel.layer.cornerRadius = 6
            cell.rightLabel.layer.masksToBounds = true
            cell.rightLabel.text = message.messageText
            cell.rightLabel.numberOfLines = 0
            cell.rightLabel.sizeToFit()
        } else {
            cell.rightLabel.backgroundColor = .clear
            cell.leftLabel.layer.cornerRadius = 6
            cell.leftLabel.layer.masksToBounds = true
            cell.leftLabel.text = message.messageText
            cell.leftLabel.numberOfLines = 0
            cell.leftLabel.sizeToFit()
        }

        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 80
//        let message = self.messages[indexPath.row]
//        height = estimateFrameForText(message.messageText).height + 20
//        return CGSize(width: 200, height: height)
//    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    
}
