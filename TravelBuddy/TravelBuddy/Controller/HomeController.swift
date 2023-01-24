//
//  HomeController.swift
//  TravelBuddy
//
//  Created by Consultant on 1/20/23.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

protocol LocationInputActivationViewDelegate {
    func presentLocationInputView()
}

class HomeController: UIViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var locationInputView: UIStackView!
    
    @IBOutlet weak var indicatorView: UIView!
    
    private let cllocationManager = CLLocationManager()
    
    private let locationInputActivationView = LocationInputActivationView()
    
    var locationInputActivationViewDelegate: LocationInputActivationViewDelegate?
    
    var locationInputViewDelegate: LocationInputViewDelegate?
    
    var user: User?
    
    var mainViewIsShowing = true
    
    var locationInputViewIsShowing = true
    
    var region = MKCoordinateRegion()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cllocationManager.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.slideIndicatorView()
        checkIfUserIsLoggedIn()
        self.getUser { user in
            DispatchQueue.main.async {
                self.user = user
                self.nameLabel.text = self.user?.fullname
            }
        }

        //enableLocationServices()
        //configureMap()
        let indicatorTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.indicatorView.addGestureRecognizer(indicatorTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = 1
    }
    
    func slideIndicatorView() {
        DispatchQueue.main.async {
            
            if self.locationInputViewIsShowing {
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.topConstraint.constant = -220
                                
                        }) { (completed) in
                            self.locationInputViewIsShowing = false
                        }
            } else {
            
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.topConstraint.constant = 0
                        }) { (completed) in
                            self.locationInputViewIsShowing = true
                        }
            }
        }
    }
    
    func slideMenu() {
        DispatchQueue.main.async {
            
            if self.mainViewIsShowing {
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.leadingConstraint.constant = 250
                                
                        }) { (completed) in
                            self.mainViewIsShowing = false
                        }
            } else {
                
                UIView.animate(
                            withDuration: 0.3,
                            delay: 0.0,
                            options: .curveLinear,
                            animations: {
                                self.leadingConstraint.constant = 0
                        }) { (completed) in
                            self.mainViewIsShowing = true
                        }
            }
        }
    }
    
    @IBAction func pressedHamburger(_ sender: Any) {
        slideMenu()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.slideIndicatorView()
    }
    
    func configureMap() {
        print("Configure map")
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.slideIndicatorView()
    }
    
}

extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            print("Available")
            authorizationStatus = cllocationManager.authorizationStatus
        } else {
            print("Not Available")
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .notDetermined:
            print("Authorization Not determined")
            cllocationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Authorization Restricted")
            break
        case .denied:
            print("Authorization Denied")
            break
        case .authorizedAlways:
            print("Authorization Always")
            cllocationManager.desiredAccuracy = kCLLocationAccuracyBest
            cllocationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("Authorization When in use")
            cllocationManager.requestAlwaysAuthorization()
        @unknown default:
            print("Authorization Unknown")
            break
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last

        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)

        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))

        self.mapView.setRegion(region, animated: true)

        self.cllocationManager.stopUpdatingLocation()

    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location Error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            cllocationManager.requestAlwaysAuthorization()
        }
    }
    
}

extension HomeController: LocationInputViewDelegate {
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
    
    
}
