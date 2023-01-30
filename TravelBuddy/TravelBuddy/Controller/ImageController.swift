//
//  ImageController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/30/23.
//

import UIKit
import Firebase

class ImageController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
    
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            User.uploadImage(image: image) {
                
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
        func pickImage()
        {
            print("Pick Image")
            let imagepicker = UIImagePickerController()
            imagepicker.delegate = self
            imagepicker.sourceType = .photoLibrary
            imagepicker.allowsEditing = true
            
            present(imagepicker, animated: true, completion: nil)
              
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage
            {
                self.imageView.image = image

            }
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true, completion: nil)
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
