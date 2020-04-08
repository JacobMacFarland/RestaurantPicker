//
//  MapViewController.swift
//  RestaurantPicker
//
//  Created by Jacob MacFarland on 6/14/19.
//  Copyright © 2019 Jacob MacFarland. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var restaraunts = [[String:String]]()

    var currentLat: CLLocationDegrees = 0
    var currentLon: CLLocationDegrees = 0
    
    @IBOutlet weak var restaurantDetailView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var restaurantNameButtonImage: UIButton!
    @IBOutlet weak var restaurantAddressButtonImage: UIButton!
    @IBOutlet weak var restaurantPhoneButtonImage: UIButton!
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    @IBOutlet weak var restaurantPhoneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInterface()
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn on location services or GPS")
        }
        
        // Code to handle asyncronous calls... simply wait until decent probability that mapView is populated
        // TODO: Handle this with better asynchronous methods
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            self.getRandomRestaraunt()
        }
    }
    
    /**
        Description - Determine user location and set map view.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userInputLat = Double(SearchInfo.searchRadius) ?? 5.5
        let userInputLon = Double(SearchInfo.searchRadius) ?? 5.5
        
        self.locationManager.stopUpdatingLocation()
        
        let userLocation:CLLocation = locations[0] as CLLocation

        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(userLocation.coordinate.latitude,
                                                                           userLocation.coordinate.longitude),
                                                                           latitudinalMeters: userInputLat,
                                                                           longitudinalMeters: userInputLon);
        
        self.mapView.setRegion(region, animated: true)
        
    }
    
    /**
        Description - Method to satisfy location delegate requirements
     TODO: Make this method more robust later on.
    */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    /**
        Description - a function to convert miles to meters
     */
    func milesToMeters(miles: Double) -> Double {
        // 1 mile is 1609.344 meters
        return 1609.344 * miles;
    }
    
    /**
        Description - Calculates a random restaraunt to add to the map view based on user's current map view location.
     
        Defaults - If no type of restaraunt is chosen in the previous view controller, the food chosen for a search is sushi.

    */
    func getRandomRestaraunt() {
        if (self.mapView!.annotations.count > 0) {
            self.mapView.removeAnnotation(self.mapView.annotations[0])
        }
        // Code you want to be delayed
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = (SearchInfo.foodType != "" ? (SearchInfo.foodType + " food") : self.pickRandomFoodType() + " food")
        request.region = self.mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            if error != nil || response!.mapItems.count == 0 {
                
                let alert = UIAlertController(title: "No Locations Found", message: "No locations were found with your search parameters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //self.performSegue(withIdentifier: "mapToMain", sender: "Error: No restaurants with that name and radius found.")
                print("Error occurred in search: \(error!.localizedDescription)")
                
            } else {
                print("Matches found")
                
                let randomRestarauntIndex = Int.random(in: 0 ..< response!.mapItems.count)
                let randomRestaraunt = response!.mapItems[randomRestarauntIndex]
                
                let randomRestarauntSubThor = randomRestaraunt.placemark.subThoroughfare ?? "NA"
                let randomRestarauntThor = randomRestaraunt.placemark.thoroughfare ?? "NA"
                let randomRestarauntLocality = randomRestaraunt.placemark.locality ?? "NA"
                let randomRestarauntAdmin = randomRestaraunt.placemark.administrativeArea ?? "NA"

                
                let randomRestarauntAddr = randomRestarauntSubThor + " " + randomRestarauntThor + ", " +
                    randomRestarauntLocality + ", " + randomRestarauntAdmin
                
                self.restaurantNameLabel.text = randomRestaraunt.name!
                self.restaurantAddressLabel.text = randomRestarauntAddr
                self.restaurantPhoneLabel.text = randomRestaraunt.phoneNumber ?? "None"
                
                let randomRestarauntAnnotation: MKPointAnnotation = MKPointAnnotation()
                self.currentLat = randomRestaraunt.placemark.coordinate.latitude
                self.currentLon = randomRestaraunt.placemark.coordinate.longitude
                randomRestarauntAnnotation.coordinate = CLLocationCoordinate2DMake(self.currentLat, self.currentLon)
                randomRestarauntAnnotation.title = randomRestaraunt.name!
                
                self.mapView.addAnnotation(randomRestarauntAnnotation)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: randomRestaraunt.placemark.coordinate.latitude, longitude: randomRestaraunt.placemark.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                self.mapView.setRegion(region, animated: true)
            }
        })
    }
    
    /**
          Can't call until tried out on real device
     */
    func callNumber(phoneNumber:String) {
        
        var pNum = phoneNumber.replacingOccurrences(of: "(", with: "")
        pNum = pNum.replacingOccurrences(of: ")", with: "")
        pNum = pNum.replacingOccurrences(of: " ", with: "")
        pNum = pNum.replacingOccurrences(of: "-", with: "")
        pNum.removeFirst()
        pNum.removeLast()
        
        print(pNum)
        
        guard let number = URL(string: "tel://" + pNum) else {
            print("Stupid idiot")
            return }
        UIApplication.shared.open(number)
            
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToMain" && sender is String {
            let destination = segue.destination as! ViewController
            destination.acct = sender as! String
        }
    }*/
    
    /**
        Description - Code for any setup of aesthetics not done in storyboard
    */
    func configureUserInterface() {
        restaurantDetailView.layer.cornerRadius = 8
        restaurantDetailView.layer.masksToBounds = true
    }
    
    /**
        Description - Button press that will choose random restaraunt
    */
    @IBAction func chooseRandomAction(_ sender: Any) {
        self.getRandomRestaraunt()
    }
    
    @IBAction func nameImageButtonTapped(_ sender: Any) {
        self.openRestaurantURL(restaurantAddress: (self.restaurantAddressLabel.text! + self.restaurantNameLabel.text!))
    }

    @IBAction func mapImageButtonTapped(_ sender: Any) {
        self.openMapForRestaurant(lat: currentLat, lon: currentLon, restaurantName: self.restaurantNameLabel.text!)
    }

    @IBAction func callImageButtonTapped(_ sender: Any) {
        self.callAction()
    }
    
    
    func callAction() {
        guard let phoneNumber = restaurantPhoneLabel.text else {
            
            let alert = UIAlertController(title: "No Phone Number", message: "Phone number for this restaurant is not on file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No Phone Number", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        callNumber(phoneNumber: phoneNumber)
    }
    
    func pickRandomFoodType() -> String {
        let foodTypes = ["American", "Italian", "Asian"]
        let randomIndex = Int.random(in: 0 ..< foodTypes.count)
        return foodTypes[randomIndex]
    }
    
    func openMapForRestaurant(lat: CLLocationDegrees, lon: CLLocationDegrees, restaurantName: String) {

        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(lat, lon)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurantName
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openRestaurantURL(restaurantAddress: String) {
        if let encoded = restaurantAddress.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: "https://www.google.com/#q=\(encoded)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }    }
}
