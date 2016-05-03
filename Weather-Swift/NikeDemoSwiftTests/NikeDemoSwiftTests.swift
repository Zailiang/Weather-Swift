//
//  NikeDemoSwiftTests.swift
//  NikeDemoSwiftTests
//
//  Created by Zailiang Yu on 4/1/16
//  Copyright © 2016 Zailiang Yu. All rights reserved.
//

import XCTest
import CoreLocation

@testable import NikeDemoSwift

class NikeDemoSwiftTests: XCTestCase {
    let vcToTest = WeatherTableViewController()
    let classToTest = AppDelegate()
    var userLocation = CLLocation()
    var appIdString = String()
    var apiUrlString = String()
    var apiUrl = NSURL()
    
    override func setUp() {
        super.setUp()
        //using to one location in california to do the following test
        self.userLocation = CLLocation(latitude: 37.332331, longitude: -122.031219)
        
        //making url with appId and current location
        self.appIdString = "c2aec73a8ffd0215ad81f02e11825283"
        self.apiUrlString = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(self.self.userLocation.coordinate.latitude)&lon=\(self.userLocation.coordinate.longitude)&cnt=16&appid=\(appIdString)"
        self.apiUrl = NSURL(string:self.apiUrlString)!
        
        //when I am running the test, tomorrow's weather condition for the preset userlocation is "Clear"
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPerformances() {
        //test the performances of the following methods 
        
        self.measureBlock {
            self.vcToTest.timerSetup()
            self.vcToTest.locationServiceSetup()
            self.vcToTest.refreshWeatherSetup()
            self.vcToTest.refetch()
            self.vcToTest.checkIfTomorrowRain("Rain")
            self.vcToTest.getCityAndState(self.userLocation, completion: { (result) in
            })
            self.vcToTest.jsonParsing(self.apiUrl, completion: { (result) in
            })
            
            self.classToTest.application(UIApplication.sharedApplication(), performFetchWithCompletionHandler: { (result) in
            })
            self.classToTest.registerLocalNotification(true)
        }
    }
    
    //Mark: tests for the viewcontroller methods
    func testGetCityAndState() {
        
        //completion handler makes sure the data is fetched even in a different thread
        self.vcToTest.getCityAndState(self.userLocation) { (result) in
            if result {
                XCTAssertTrue(self.vcToTest.title!.containsString("CA"))
                XCTAssertTrue(self.vcToTest.title!.characters.count >= 6)
            }
        }
    }
    
    func testForegroundJsonParsing() {
        
        //completion handler makes sure the data is fetched even in a different thread
        self.vcToTest.jsonParsing(self.apiUrl) { (result) in
            if result {
                XCTAssertEqual(16, self.vcToTest.weatherArray.count)
                XCTAssertEqual("Clear", self.vcToTest.weatherArray[0])
            }
        }
    }
    
    func testRainCheck() {
        XCTAssertTrue(self.vcToTest.checkIfTomorrowRain("Rain"))
    }
    
    
    //Mark: tests for the class methods
    func testBackgroundJsonParsing() {
        
        //completion handler makes sure the data is fetched even in a different thread
        self.classToTest.application(UIApplication.sharedApplication()) { (result) in
            if result == UIBackgroundFetchResult.NewData {
                XCTAssertNotNil(self.classToTest.weatherArray)
                XCTAssertTrue(self.classToTest.weatherArray[0].containsString("Clear"))
            }
        }
    }
    
    func testNotification() {
        self.classToTest.registerLocalNotification(true)
        XCTAssertNotNil(self.classToTest.localNotification)
    }
    
}
