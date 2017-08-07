//
//  MapViewController.swift
//  PTestMock
//
//  Created by ITP312 on 31/5/17.
//  Copyright © 2017 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager?
    
    // 2b
    var estateList : [Estate] = []
    
    //declare json object
    let json = JSON.init([])
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var sizeSegment: UISegmentedControl!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // Question 1c:
        
        /*
        //Create Location manager object
        locationManager = CLLocationManager();
        //Set the delegate property of the location manager to self
        locationManager?.delegate = self;
        
        //Set the most accurate location data as possible
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
        // Check for iOS 8. Without this guard the code will
        // crash with "unknown selector" on iOS 7.
        let ios8 = locationManager?.responds(to:
            #selector(CLLocationManager.requestWhenInUseAuthorization))
        if (ios8!) {
            locationManager?.requestWhenInUseAuthorization();
        }
        
        //Tell the location manager to start looking for its location
        //immediately
        locationManager?.startUpdatingLocation();
         */
    }
    
    /*
    var lastLocationUpdateTime : Date = Date()
    
    // This function receives information about the change of the
    // user’s GPS location. The locations array may contain one
    // or more location updates that were collected in-between calls
    // to this function.
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        // There are multiple locations, but we are only
        // interested in the last one.
        let newLocation = locations.last!;
        // Get find out how old (in seconds) this data was.
        let howRecent =
            self.lastLocationUpdateTime.timeIntervalSinceNow;
        // Handle only recent events to save power.
        if (abs(howRecent) > 15)
        {
            print("Longitude = \(newLocation.coordinate.longitude)");
            print("Latitude = \(newLocation.coordinate.latitude)");
            self.lastLocationUpdateTime = Date()
        }
    }
    
    // This function is triggered if the location manager was unable
    // to retrieve a location.
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Could not find location: \(error)");
    }
     */
    
    //1c: 
    var lm = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // same as above let ios8....
        /* 1c:
        */
         if(lm.responds(to: #selector (CLLocationManager.requestAlwaysAuthorization)))
        {
            lm.requestAlwaysAuthorization()
        }
        lm.distanceFilter = 5.0
        lm.delegate = self
        lm.startUpdatingLocation()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
        let url = "http://crowd.sit.nyp.edu.sg/itp312_2017s1/estate/list"
        HTTP.postJSON(
            url: url,
            json: json,
            onComplete:
            {
                json, response, error in
                // this is what will happen after the download from server is complete
                if json == nil
                {
                    return
                }
                
                print(json!.count)
                
                for var i in 0 ..< json!.count{
                    var e = Estate()
                    e.name = json![i]["name"].string!
                    e.population = json![i]["pop"].int!
                    e.latitude = json![i]["latitude"].double!
                    e.longitude = json![i]["longitude"].double!
                    self.estateList.append(e)
                    print(e.name)
                 }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.showMapPins()
                }
                
        })
    }
    
    var currentGPSLocation : CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentGPSLocation = locations.last
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estateList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let e = estateList[indexPath.row]
        cell.textLabel?.text = e.name
        cell.detailTextLabel?.text = "Population: \(e.population)"
        cell.imageView?.image = UIImage(named: "house")
        
        if (sizeSegment.selectedSegmentIndex == 0)
        {
            // ALL
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        if (sizeSegment.selectedSegmentIndex == 1)
        {
            if e.population <= 100000
            {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            else
            {
                cell.textLabel?.textColor = UIColor.gray
                cell.detailTextLabel?.textColor = UIColor.gray
            }
        }
        
        if (sizeSegment.selectedSegmentIndex == 2)
        {
            if e.population > 100000
            {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            else
            {
                cell.textLabel?.textColor = UIColor.gray
                cell.detailTextLabel?.textColor = UIColor.gray
            }
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentChanged(sender: Any)
    {
        tableView.reloadData()
    }

    func showMapPins()
    {
        for var i in 0 ..< estateList.count {
            let e = estateList[i]
            
            let coord = CLLocationCoordinate2D(latitude: e.latitude, longitude: e.longitude)
            var mapAnnotation = MapAnnotation(coordinate: coord, title: e.name, subtitle: "Population: \(e.population)")
            
            mapView.addAnnotation(mapAnnotation)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if currentGPSLocation == nil
        {
            distanceLabel.text = "Distance: ??? km"
            return
        }
        
        let e = estateList[indexPath.row]
        
        let estateCLLocation = CLLocation(
            latitude: e.latitude,
            longitude: e.longitude)
        
        
        var distInKm =
            currentGPSLocation!.distance(from: estateCLLocation)
            / 1000
        
        distanceLabel.text = "Distance: \(distInKm) km"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
