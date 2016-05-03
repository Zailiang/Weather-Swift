//
//  WeatherTableViewController.swift
//  Nike-demo-Swift
//
//  Created by Zailiang Yu on 4/1/16
//  Copyright © 2016 Zailiang Yu. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherTableViewController: UITableViewController,CLLocationManagerDelegate {

    //making the following parameters public for testing concern and in-class use
    //location manager is set to find user's location
    let locManager = CLLocationManager()
    //user's location is stored in currentLocation
    var currentLocation:CLLocation!
    //apiUrl is set for finding the weather data
    var apiUrl:NSURL! = nil
    //apiId has to be registerred to use open weather map Api
    let appIdString = "c2aec73a8ffd0215ad81f02e11825283"
    //the weather of the coming 16 days will be stored in the weatherArray
    var weatherArray = [String]()
    //the weather icon image names of the coming 16 days will be stored in the iconArray
    var iconArray = [String]()
    
    @IBOutlet var weatherTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load all settings for the view controller
        //setting for the location service
        self.locationServiceSetup()
        //setting for the pull-down table view refresh
        self.refreshWeatherSetup()
        //setting for the timer to achieve 30-minutes automatical data parsing in foreground
        self.timerSetup()
    }
    
    func locationServiceSetup() {
        //tell compiler the delegate methods will be implemented here
        self.locManager.delegate = self
        //tell the compiler satellite will be used
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        //app has to ask for user's permission for the location service
        self.locManager.requestAlwaysAuthorization()
        self.locManager.requestWhenInUseAuthorization()
        //app starts to update location at this point
        self.locManager.startUpdatingLocation()
    }

    func refreshWeatherSetup() {
        //define a refreshcontrol view
        let refreshControl = UIRefreshControl()
        //link the refresh control to a method, every time user pulling down the tableview, it will call the method with name "refresh"
        refreshControl.addTarget(self, action: #selector(WeatherTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //add the refreshcontrol to the tableview
        self.weatherTable?.addSubview(refreshControl)
    }
    
    func timerSetup() {
        //define a timer that will call a method in every 30 minutes
        _ = NSTimer.scheduledTimerWithTimeInterval(30*60, target: self, selector:#selector(WeatherTableViewController.refetch), userInfo: nil, repeats: true)
    }
    
    func refresh(refreshControl:UIRefreshControl) {
        //call the method to restart locating, updating the title and fetching the weather data
        self.refetch()
        //tell compiler the refreshing is done
        refreshControl.endRefreshing()
    }

    func refetch() {
        //show the user that system is refreshing data
        self.title = "Loading..."
        //restart locating, updating the title and fetching the weather data
        self.locManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tCell", forIndexPath: indexPath)

        //set the tableview cell showing the image of the weather icon, the weather status and the date of the weather
        cell.textLabel?.text = "\(weatherArray[indexPath.row])"
        cell.imageView?.image = UIImage(named:"\(iconArray[indexPath.row]).png")

        //reformat the date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE MMM-dd"
        let today = NSDate()
        let cellDate = today.dateByAddingTimeInterval(60*60*24*Double(indexPath.row+1))
        let cellDateString = dateFormatter.stringFromDate(cellDate)
        cell.detailTextLabel?.text = cellDateString
        
        //redesign the style of the tableview cell for better UI
        cell.contentView.layer.cornerRadius = 8;
        cell.contentView.layer.borderColor = UIColor.blackColor().CGColor;
        cell.contentView.layer.borderWidth = 1;
        
        return cell
    }
    
    // MARK: - Location manager delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //show one alert controller to the user when the system's location service is not on
        let locationAlert:UIAlertController = UIAlertController(title: "Alert", message: "Please check if you turn on the location service.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
            action -> Void in
        }
        locationAlert.addAction(okAction)
        //present the alert controller to the user
        self.presentViewController(locationAlert, animated: true) {
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //once the location is found, the system will turn off the location service for battery concern
        self.locManager.stopUpdatingLocation()
        //save the currentlocation data
        self.currentLocation = locations[0]
        //also pass the currentlocation to the appdelegate for the use ofbackground fetch
        let localDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        localDelegate.currentLocation = self.currentLocation
        
        //prepare for the json parsing
        let apiUrlString = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(self.currentLocation.coordinate.latitude)&lon=\(self.currentLocation.coordinate.longitude)&cnt=16&appid=\(appIdString)"
        //make url for the json parsing
        let apiUrl = NSURL(string:apiUrlString)
        //update the navigation title to show user where are you
        self.getCityAndState(self.currentLocation) { (result) in
        }
        //parse the data of the weather forecasting
        self.jsonParsing(apiUrl!) { (result) in
        }
    }
    
    func getCityAndState(location:CLLocation, completion:(result:Bool)->Void) {
        //define geocoder to user location coordinate to find out the city and the state of the user
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            //use place mark to find city and state
            if error == nil {
                if let placemark:CLPlacemark = placemarks![0] {
                    //locality returns city, administrativeArea returns state
                    self.title = "\(placemark.locality!), \(placemark.administrativeArea!)"
                    completion(result: true)
                }
            }
        }
    }
    
    func jsonParsing(weatherUrl:NSURL, completion:(result:Bool) -> Void){
        //user NSURLSession to parse the data
        NSURLSession.sharedSession().dataTaskWithURL(weatherUrl) { (data, response, error) in
            let httpResponse:NSHTTPURLResponse = response as! NSHTTPURLResponse
            if error == nil {
                //check stats using the httpResonse statusCode, 200 means sucess
                if httpResponse.statusCode == 200 {
                    do {
                        //save the jsonData to local after NSJSSONSerialization
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                        //check if the jsonData in NSDictionary format
                        if jsonData.isKindOfClass(NSDictionary) {
                            //make two temp array to refresh the weatherArray and iconArray
                            var tempWeatherArray = [String]()
                            var tempIconArray = [String]()
                            //find the 16 days weather data
                            if let weatherList = jsonData["list"] as? [AnyObject]{
                               // print(weatherList)
                                for oneDayInfo in weatherList {
                                    if let oneDayWeather = oneDayInfo["weather"] as? [AnyObject] {
                                        if let oneDayMainWeather = oneDayWeather[0]["main"] as? String {
                                            //save the mainweather data
                                            tempWeatherArray.append(oneDayMainWeather)
                                        }
                                        if let oneDayWeatherIcon = oneDayWeather[0]["icon"] as? String {
                                            //save the weathericon images name data
                                            tempIconArray.append(oneDayWeatherIcon)
                                        }
                                    }
                                }
                            }
                            //refresh the following arrays
                            self.weatherArray = tempWeatherArray
                            self.iconArray = tempIconArray
                            //set the completion handler, which can be used in the unit test for test the returned value after this process is finished
                            completion(result: true)
                            //reload the data of the tableview in the main queue and also show one alert to the user if rain is coming
                            dispatch_sync(dispatch_get_main_queue(), { 
                                self.weatherTable?.reloadData()
                                
                                if self.checkIfTomorrowRain(self.weatherArray[0]) {
                                    let rainAlert = UIAlertController(title: "Alert", message: "It will rain in 24 hours", preferredStyle: .Alert)
                                    let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                                    rainAlert.addAction(okAction)
                                    self.presentViewController(rainAlert, animated: true, completion: nil)
                                }
                            })
                        }else {
                            //show the failed parsing alert
                            self.showFailParsingAlert()
                        }
                    }
                    catch{
                        //show the failed parsing alert
                        self.showFailParsingAlert()
                    }
                }
            }else {
                //show the failed parsing alert
                self.showFailParsingAlert()
            }
        }.resume()
    }
    
    //define the failed parsing alert
    func showFailParsingAlert() {
        let failAlert = UIAlertController(title: "Alert", message: "Fail to get the weather data, please check your internet access or try this later.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        failAlert.addAction(okAction)
        self.presentViewController(failAlert, animated: true) {
        }
    }
    
    //define a function to check if the rain is coming
    func checkIfTomorrowRain(weather:String) -> Bool {
        if weather == "Rain" {
            return true;
        }else {
            return false;
        }
    }
}
