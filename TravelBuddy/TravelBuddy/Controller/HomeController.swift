//
//  HomeController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/20/23.
//

import UIKit
import Firebase
import MapKit

protocol LocationInputActivationViewDelegate {
    func presentLocationInputView()
}


class HomeController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var locationInputView: UIStackView!
    
    @IBOutlet weak var indicatorView: UIView!
    
    private let locationManager = CLLocationManager()
    
    private let locationInputActivationView = LocationInputActivationView()
    
    var locationInputActivationViewDelegate: LocationInputActivationViewDelegate?
    
    var locationInputViewDelegate: LocationInputViewDelegate?
    
    var user: User?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //signOut()
        //self.locationInputView.isHidden = true
        //self.slideIndicatorInputView(direction: "up")
        checkIfUserIsLoggedIn()
        self.getUser { user in
            DispatchQueue.main.async {
                self.user = user
                self.nameLabel.text = self.user?.fullname
            }
        }
        enableLocationServices()
        configureMap()
//        let indicatorTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.indicatorView.addGestureRecognizer(indicatorTap)
//        let optionsTap = UITapGestureRecognizer(target: self, action: #selector(self.pressedOptions(_:)))
//        self.optionsButton.addGestureRecognizer(optionsTap)
//        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.pressedBack(_:)))
//        self.backButton.addGestureRecognizer(backTap)
        
        //self.slideIndicatorView(direction: "up")
        //locationInputActivationViewDelegate = self
        //locationInputView.delegate = self
        //delegate = self
//        //view.addSubview(indicatorActivationView)
//        indicatorActivationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
//        indicatorActivationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        indicatorActivationView.heightAnchor.constraint(equalToConstant: 34).isActive = true
//        indicatorActivationView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    @objc func pressedOptions(_ sender: UITapGestureRecognizer? = nil) {
        print("Pressed Options")
    }
    
    @objc func pressedBack(_ sender: UITapGestureRecognizer? = nil) {
        print("Pressed Back")
        self.slideIndicatorInputView(direction: "up")
    }
    @IBAction func pressedHamburger(_ sender: Any) {
        print("Pressed Options")
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.slideIndicatorInputView(direction: "down")
        //self.presentLocationInputView()
        //locationInputActivationViewDelegate?.presentLocationInputView()
    }
    
    func configureMap() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("User not logged in")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
            
        } else {
            print("User \(String(describing: Auth.auth().currentUser?.uid)) is logged in")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func slideIndicatorInputView(direction: String) {
        
        DispatchQueue.main.async {
            let newY = self.view.frame.origin.y - self.locationInputView.frame.height
            if direction == "up" {
                print("indicator up")
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.locationInputView.frame = CGRect(x: 0, y: newY, width: self.locationInputView.frame.width, height: self.locationInputView.frame.height)
                                
                                print("-200")
                        }) { (completed) in

                        }
            } else {
                self.locationInputView.isHidden = false
                self.backButton.isEnabled = true
                print("indicator down")
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.locationInputView.frame = CGRect(x: 0, y: 0, width: self.locationInputView.frame.width, height: self.locationInputView.frame.height)
                                
                                print("+200")
                        }) { (completed) in

                        }
            }
        }
        
    }
    
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        print("Pressed Option")
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("Pressed Back")
        //self.slideIndicatorInputView(direction: "up")
    }
    
    
}

extension HomeController: CLLocationManagerDelegate {
    func enableLocationServices() {
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("Always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("When in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}

extension HomeController: LocationInputActivationViewDelegate, LocationInputViewDelegate {
    func dismissLocationInputView() {
        //
        print("Dismiss LocationView")
        self.locationInputView.removeFromSuperview()
    }
    
    func executeSearch(query: String) {
        //
    }
    
    func getUser(_ completion: @escaping (_ user: User) -> ()) {
        let currentUser = Auth.auth().currentUser
        var user = User(uid: "", dictionary: ["":""])
        if let currentUser = currentUser {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
            REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { snapshot in
              // Get user value
                let dict = snapshot.value as? NSDictionary
                user = User(uid: currentUser.uid, dictionary: dict as! [String : Any])
                completion(user)
            
              // ...
            }) { error in
              print(error.localizedDescription)
            }
            
          
        }

    }
    
    func presentLocationInputView() {
        
        DispatchQueue.main.async {
            self.slideIndicatorInputView(direction: "down")
        }
        
    }
    
    
}
