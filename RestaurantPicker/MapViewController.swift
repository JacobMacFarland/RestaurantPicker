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

    
    @IBOutlet weak var restaurantDetailView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    @IBOutlet weak var restaurantPhoneNum: UILabel!
    
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
        
        var userInputLat = Double(SearchInfo.searchRadius) ?? 5.5
        var userInputLon = Double(SearchInfo.searchRadius) ?? 5.5
        
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
        request.naturalLanguageQuery = (SearchInfo.foodType != "" ? SearchInfo.foodType: "sushi")
        
        request.region = self.mapView.region
        
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            if error != nil {
                print("Error occurred in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
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
                self.restaurantPhoneNum.text = randomRestaraunt.phoneNumber ?? "None"
                
                let randomRestarauntAnnotation: MKPointAnnotation = MKPointAnnotation()
                randomRestarauntAnnotation.coordinate = CLLocationCoordinate2DMake(randomRestaraunt.placemark.coordinate.latitude, randomRestaraunt.placemark.coordinate.longitude);
                randomRestarauntAnnotation.title = randomRestaraunt.name!
                self.mapView.addAnnotation(randomRestarauntAnnotation)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: randomRestaraunt.placemark.coordinate.latitude, longitude: randomRestaraunt.placemark.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                self.mapView.setRegion(region, animated: true)
                print(self.mapView.annotations)
            }
        })
    }
    
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
        getRandomRestaraunt()
    }
    
}
