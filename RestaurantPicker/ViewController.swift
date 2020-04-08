//
//  ViewController.swift
//  RestaurantPicker
//
//  Created by Jacob MacFarland on 6/12/19.
//  Copyright © 2019 Jacob MacFarland. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var foodTypeTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionView: UIView!
    
    var locationManager = CLLocationManager()

    let mapView = MKMapView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuestionView()
        self.foodTypeTextField.delegate = self
        self.radiusTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        SearchInfo.foodType = foodTypeTextField.text!
        SearchInfo.searchRadius = radiusTextField.text!
        performSegue(withIdentifier: "mainToMap", sender: self)

    }
    
    func setupFoodTypeTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: foodTypeTextField.frame.size.height - width, width: view.frame.size.width - 70, height: foodTypeTextField.frame.size.height)

        border.borderWidth = width
        foodTypeTextField.layer.addSublayer(border)
        foodTypeTextField.layer.masksToBounds = true
        foodTypeTextField.placeholder = "Food Type"
        foodTypeTextField.returnKeyType = UIReturnKeyType.done
    }
    
    func setupRadiusTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: radiusTextField.frame.size.height - width, width: view.frame.size.width - 70, height: radiusTextField.frame.size.height)
        
        border.borderWidth = width
        radiusTextField.layer.addSublayer(border)
        radiusTextField.layer.masksToBounds = true
        radiusTextField.placeholder = "Radius (mi)"
        radiusTextField.returnKeyType = UIReturnKeyType.done
    }
    
    func setupSubmitButton() {
        submitButton.layer.cornerRadius = 21
        submitButton.layer.masksToBounds = true
    }
    
    func setupQuestionView() {
        questionView.layer.cornerRadius = 8
        questionView.layer.masksToBounds = true
        
        self.setupRadiusTextField()
        self.setupFoodTypeTextField()
        self.setupSubmitButton()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

