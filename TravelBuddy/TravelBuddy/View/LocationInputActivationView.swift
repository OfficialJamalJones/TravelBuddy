//
//  LocationInputActivationView.swift
//  TravelBuddy
//
//  Created by Consultant on 1/20/23.
//

import UIKit

class LocationInputActivationView: UIView {
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("Init: LocationInputActivationView")
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
        
        addSubview(indicatorView)
        indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicatorView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
        indicatorView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 6).isActive = true
        addSubview(placeholderLabel)
        placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        placeholderLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
