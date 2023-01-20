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
    
    @IBOutlet weak var indicatorView: UIView!
    
    private let locationManager = CLLocationManager()
    
    private let indicatorActivationView = LocationInputActivationView()
    
    var delegate: LocationInputActivationViewDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //signOut()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        configureMap()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        indicatorView.addGestureRecognizer(tap)
        delegate = self
//        //view.addSubview(indicatorActivationView)
//        indicatorActivationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
//        indicatorActivationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        indicatorActivationView.heightAnchor.constraint(equalToConstant: 34).isActive = true
//        indicatorActivationView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("Tap Recognized")
        delegate?.presentLocationInputView()
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
    
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
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

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        print("Location Input Tap Handled")
    }
    
    
}
