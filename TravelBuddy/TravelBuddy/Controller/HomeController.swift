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

//Add tab to show carpool and mileage

protocol LocationInputActivationViewDelegate {
    func presentLocationInputView()
}

class HomeController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var currentLocationField: UITextField!
    
    @IBOutlet weak var destinationField: UITextField!
    
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var locationInputView: UIStackView!
    
    @IBOutlet weak var indicatorView: UIView!

    @IBOutlet weak var tableView: UITableView!
    
    private let cllocationManager = CLLocationManager()
    
    private let locationInputActivationView = LocationInputActivationView()
    
    var locationInputActivationViewDelegate: LocationInputActivationViewDelegate?
    
    var locationInputViewDelegate: LocationInputViewDelegate?
    
    var user: User?
    
    var mainViewIsShowing = true
    
    var locationInputViewIsShowing = true
    
    var region = MKCoordinateRegion()
    
    var searchResults = [MKPlacemark]()
    
    var isEditingCurrent = false
    
    var isEditingDestination = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    var routeCoordinates : [CLLocation] = []
    var routeOverlay : MKOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        self.currentLocationField.delegate = self
        self.destinationField.delegate = self
        self.mapView.delegate = self
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.backgroundColor = .white
        self.currentLocationField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        self.destinationField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

//        view.addGestureRecognizer(tap)
        self.tableView.tableFooterView = UIView()
        self.cllocationManager.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.slideIndicatorView()
        checkIfUserIsLoggedIn()
        User.getUser { user in
            DispatchQueue.main.async {
                self.user = user
                let imageString = ""
                User.loadImage(imageString: self.user?.uid ?? imageString) { image in
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
                        self.imageView.layer.masksToBounds = true
                    }

                }
            }
        }

        enableLocationServices()
        configureMap()
        let indicatorTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.indicatorView.addGestureRecognizer(indicatorTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
        
    }
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        self.slideMenu()
    }
    
    @IBAction func pressedRouteButton(_ sender: Any) {
        self.routeCoordinates.removeAll()
       
        guard let currentAddress = currentLocationField.text else { return }
        guard let destinationAddress = destinationField.text else { return }
        
        self.searchBy(naturalLanguageQuery: currentAddress) { placemarks in
            if let from = placemarks.first {
                self.searchBy(naturalLanguageQuery: destinationAddress) { placemarks in
                    if let to = placemarks.first {
                        self.drawDirections(from: from, to: to) {
                            
                            
                        }
                    }
                    
                }
            }
            
        }
        DispatchQueue.main.async {
            self.addPins()
            self.dismissKeyboard()
            self.slideIndicatorView()
        }
    }
    
    func getLocations(from fromAddress: String, to toAddress: String, completion: @escaping (_ fromLocation: CLLocation?, _ toLocation: CLLocation?)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(fromAddress) { (placemarks, error) in
            guard let placemarks = placemarks,
            let fromLocation = placemarks.first?.location else {
                completion(nil, nil)
                return
            }
            geocoder.geocodeAddressString(toAddress) { (placemarks, error) in
                guard let placemarks = placemarks,
                let toLocation = placemarks.first?.location else {
                    completion(nil, nil)
                    return
                }
                completion(fromLocation, toLocation)
            }
            
        }
    }
    
    func updateMap(routeData: [CLLocation]) {
        self.addPins()
        self.drawRoute(routeData: routeData)
    }
    
    func drawRoute(routeData: [CLLocation]) {
        if routeCoordinates.count == 0 {
            print("🟡 No Coordinates to draw")
            return
        }
        
        let coordinates = routeCoordinates.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
            let customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 20)
            self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, edgePadding: customEdgePadding, animated: false)
        }
    }
    
    func addPins() {
            if routeCoordinates.count != 0  {
                let startPin = MKPointAnnotation()
                startPin.title = "start"
                startPin.coordinate = CLLocationCoordinate2D(
                    latitude: routeCoordinates[0].coordinate.latitude,
                    longitude: routeCoordinates[0].coordinate.longitude
                )
                mapView.addAnnotation(startPin)
                
                let endPin = MKPointAnnotation()
                endPin.title = "end"
                endPin.coordinate = CLLocationCoordinate2D(
                    latitude: routeCoordinates.last!.coordinate.latitude,
                    longitude: routeCoordinates.last!.coordinate.longitude
                )
                mapView.addAnnotation(endPin)
            }
    }
    
    func slideIndicatorView() {
        if self.locationInputViewIsShowing {
            UIView.animate(
                        withDuration: 0.3,
                        delay: 0.0,
                        options: .curveLinear,
                        animations: {
                            self.topConstraint.constant = -220
                            self.topTableViewConstraint.constant = self.tableView.frame.height + self.locationInputView.frame.height
                            
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
                            self.topTableViewConstraint.constant = 0
                    }) { (completed) in
                        self.locationInputViewIsShowing = true
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
    
    func executeSearch(query: String) {
        self.searchBy(naturalLanguageQuery: query) { placemarks in
            DispatchQueue.main.async {
                self.searchResults = placemarks
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            response.mapItems.forEach { item in
                print("DEBUG Item: \(item)")
                results.append(item.placemark)
            }
            completion(results)
        }
        
    }
    
    func drawDirections(from: MKPlacemark, to: MKPlacemark, completion: @escaping() -> Void) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: from)
        request.destination = MKMapItem(placemark: to)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    @IBAction func pressedHamburger(_ sender: Any) {
        slideMenu()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if textField.restorationIdentifier == "current" {
            isEditingCurrent = true
            isEditingDestination = false
        } else {
            isEditingCurrent = false
            isEditingDestination = true
        }
        self.executeSearch(query: text)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.slideIndicatorView()
    }
    
    func configureMap() {
        print("Configure map")
        DispatchQueue.main.async {
            self.cllocationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.cllocationManager.distanceFilter = kCLHeadingFilterNone
            self.cllocationManager.startUpdatingLocation()
            
            self.mapView.showsUserLocation = true
            self.mapView.userTrackingMode = .follow
        }
        
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("User not logged in")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
            
        } else {
            print("User \(String(describing: Auth.auth().currentUser?.uid)) is logged in")
            //self.tabBarController?.selectedIndex = 1
        }
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.slideIndicatorView()
    }
    
}

extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
            renderer.setColors([
                UIColor(red: 0.02, green: 0.91, blue: 0.05, alpha: 1.00),
                UIColor(red: 1.00, green: 0.48, blue: 0.00, alpha: 1.00),
                UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00)
            ], locations: [])
            renderer.lineCap = .round
            renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
            
            if annotationView == nil {
                //CREATE VIEW
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            } else {
                //ASSIGN ANNOTATION
                annotationView?.annotation = annotation
            }
            
            //SET CUSTOM ANNOTATION IMAGES
            switch annotation.title {
            case "end":
                annotationView?.image = UIImage(named: "pinEnd")
            case "start":
                annotationView?.image = UIImage(named: "pinStart")
            default:
                break
            }
            
            return annotationView
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
            self.configureMap()
        case .authorizedWhenInUse:
            print("Authorization When in use")
            cllocationManager.requestAlwaysAuthorization()
        @unknown default:
            print("Authorization Unknown")
            break
        }
        
        
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last
//
//        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
//
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
//
//        self.mapView.setRegion(region, animated: true)
//
//        self.cllocationManager.stopUpdatingLocation()
//
//    }
//
//    func locationManager(
//        _ manager: CLLocationManager,
//        didFailWithError error: Error
//    ) {
//        print("Location Error: \(error.localizedDescription)")
//    }
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        if manager.authorizationStatus == .authorizedWhenInUse {
//            cllocationManager.requestAlwaysAuthorization()
//        }
//    }
    
}

extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        //
        print("Dismiss LocationView")
        self.locationInputView.removeFromSuperview()
    }
    
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "search" {
            return searchResults.count
        } else {
            return 6
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UILabel()
        if tableView.restorationIdentifier == "search" {
            view.backgroundColor = .systemGray6
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if tableView.restorationIdentifier == "search" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as!  LocationCell
            
            let location = self.searchResults[indexPath.row]
            print("Location: \(location)")
            cell.titleLabel.text = location.name
            cell.subTitleLabel.text = location.address
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as!  MenuCell
            
            let index = indexPath.row
            
            switch index {
            case 0:
                cell.menuLabel.text = "Home"
                cell.menuImage.image = UIImage(systemName: "house.fill")
            case 1:
                cell.menuLabel.text = "Messages"
                cell.menuImage.image = UIImage(systemName: "message")
            case 2:
                cell.menuLabel.text = "Profile"
                cell.menuImage.image = UIImage(systemName: "person.fill")
            case 3:
                cell.menuLabel.text = "Settings"
                cell.menuImage.image = UIImage(systemName: "gear")
            case 4:
                cell.menuLabel.text = "Legal"
                cell.menuImage.image = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
            case 5:
                cell.menuLabel.text = "Social"
                cell.menuImage.image = UIImage(systemName: "hand.thumbsup.circle.fill")
            default:
                cell.menuLabel.text = "Testing: \(index)"
            }
            
            return cell
        }
        
        
    }
    

    
    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let location = self.searchResults[indexPath.row]
        print("Selected: \(indexPath.row), \(location.address)")
        
        if isEditingCurrent {
            self.currentLocationField.text = location.address
            isEditingCurrent = false
        } else {
            self.destinationField.text = location.address
            isEditingDestination = false
        }
        
    }
    
}

extension HomeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        self.executeSearch(query: query)
        self.dismissKeyboard()
        return true
    }
    
}
