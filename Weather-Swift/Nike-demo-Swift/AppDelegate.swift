//
//  AppDelegate.swift
//  Nike-demo-Swift
//
//  Created by Zailiang Yu on 4/1/16
//  Copyright © 2016 Zailiang Yu. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //making the following parameters public for testing concern and in-class use
    var window: UIWindow?
    //get the current location from the weather view controller
    var currentLocation = CLLocation()
    //set the appId for the json parsing
    let appIdString = "c2aec73a8ffd0215ad81f02e11825283"
    //set the array to store the main weather
    var weatherArray = [String]()
    //prpare a local nitification to tell user rain is coming
    var localNotification = UILocalNotification()
    
    
    //setup for the local notifications when app is lunched
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.cancelAllLocalNotifications()
        
        return true
    }

    //set the background fetch to happen in every 30 minutes
    func applicationDidEnterBackground(application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(30*60)
        
    }

    //cancel all notifications when user teminate the app
    func applicationWillTerminate(application: UIApplication) {
        application.cancelAllLocalNotifications()
    }

    //json parsing in the performFetchWithComletionHandler UIApplication delegate method
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        //setup the url for the json parsing
        let apiUrlString = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(self.currentLocation.coordinate.latitude)&lon=\(self.currentLocation.coordinate.longitude)&cnt=1&appid=\(appIdString)"
        
        let apiUrl = NSURL(string:apiUrlString)
        
        //use NSURLSession to parse the json data
        NSURLSession.sharedSession().dataTaskWithURL(apiUrl!) { (data, response, error) in
            let httpResponse:NSHTTPURLResponse = response as! NSHTTPURLResponse
            if error == nil {
                //user httpRespnse to check if json parsing is success
                if httpResponse.statusCode == 200 {
                    do {
                        //store the jsonData locally with NSJSONSerialization
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                        //check if it is in NSDictionary format
                        if jsonData.isKindOfClass(NSDictionary) {
                            
                            //only save the main weather data
                            var tempWeatherArray = [String]()
                            
                            if let weatherList = jsonData["list"] as? [AnyObject]{
                                for oneDayInfo in weatherList {
                                    if let oneDayWeather = oneDayInfo["weather"] as? [AnyObject] {
                                        if let oneDayMainWeather = oneDayWeather[0]["main"] as? String {
                                            tempWeatherArray.append(oneDayMainWeather)
                                        }
                                    }
                                }
                            }
                            self.weatherArray = tempWeatherArray
                            if self.weatherArray[0] == "Rain"{
                                //if rain is coming, the local notification will be registerred
                                self.registerLocalNotification(true)
                            }
                            //setup the completionHandler for the unit test
                            completionHandler(UIBackgroundFetchResult.NewData)
                        }
                    }
                    catch{
                    }
                }
            }else {
            }
            }.resume()
    }
    
    //setup the local notification
    func registerLocalNotification(real:Bool) {
        if real {
            self.localNotification.fireDate = NSDate()
            self.localNotification.timeZone = NSTimeZone.defaultTimeZone()
            self.localNotification.alertBody = "It will rain in 24 hours"
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
}

