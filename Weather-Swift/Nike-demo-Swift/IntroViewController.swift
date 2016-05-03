//
//  IntroViewController.swift
//  NikeDemoSwift
//
//  Created by Zailiang Yu on 4/1/16
//  Copyright © 2016 Zailiang Yu. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    //connect to the ui components
    @IBOutlet weak var textSubview: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Intro & Hints"
        
        //to make betther UI, textview are not used, instead, a label is put on top of the scroll view
        //we have to disable the scroll view's horizontal scrolling direction
        let scrollSize = CGSizeMake(self.view.frame.size.width-40,1000)
        self.textScrollView.contentSize = scrollSize
        
        //set the alpha of the subview to make better UI, using the following command, the content on the subview's alpha remains 1, however the subview's alpha is changed to be 0.8
        self.textSubview.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        //make the subview round-connerred for better UI
        self.textSubview.layer.cornerRadius = 5
        
        textLabel.text = "Application functionalities:\n\n 1. App can fetch the coming 16 days weather forecast in the weather view controller. In this veiw controller, user's location will be loaded firstly. (used Core Location framework, CLLocation Manager, CLGeocoder and CLPlacemark. To save battery, once user's location is found, app will stop updating user's location.) According to the user's location, the weather forecast will be shown (used NSURLSession without third party API).\n\n 2. After the weather forecast is loaded, a local notification will be scheduled to fetch to weather data again and again in every 30 minutes. (Alternatively, NSTimer can be used as well, but the local notification is more reliable. It is worth noting that this local notification is not aim to show user if it will or not rain in 24 hours.)\n\n 3. Each time after weather forecast data is loaded, app will check if it will rain in 24 hours, if so, an alert controller will be shown to remind user rain is coming.\n\n 4. If user hits home button, app will resign active and work in the background. In this app status, background data fetching is setup to happen in every 30 minutes as well. (used uiapplication method performFetch and NSURLSession.) If it will rain in 24 hours, another local notification will be setup to remind the user on the Banner.\n\n 5. App is validated by the unit test. In the unit test case, all the methods are tested for both functional and performing perspectives. To achieve the unit test, some properties and methods of AppDelegate and WeatherViewController are modified to public."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
