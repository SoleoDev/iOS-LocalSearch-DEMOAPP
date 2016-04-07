//
//  FirstViewController.swift
//  Soleo_Tab_Template
//
//  Created by Victor Jimenez Delgado on 1/27/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import SystemConfiguration

protocol FirstViewControllerDelegate{
    
    func passData(name: String, data: Any)
    func passSearchList(list : [Search_type])
}

class FirstViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, FirstViewControllerDelegate, UITabBarControllerDelegate {
    
    
    var LeftSideDelegate : LeftViewControllerDelegate?
    var RecentTableDelegate : RecentTableViewControllerDelegate?
    
    //MARK: Fields
    @IBOutlet weak var Mic_Button: UIImageView!
    @IBOutlet weak var SearchField: UITextField!
    
    @IBOutlet weak var SearchButton: UIButton!
    
    var LocManager : CLLocationManager?
    
    var AudioSession = AVAudioSession()
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    
    //MARK: SOLEO API Fields
    
    var APICALL : SoleoAPI?
    
    var local : CLLocation?
    
    var name : String = ""
    
    var keyword : String = ""
    
    var category : String = ""
    
    var businessList = [Business]()
    
    var toSearch_PostalCode: Int = 0000
    
    var toSearch_City : String = ""
    
    var toSearch_State : String = ""
    
    var toSearch_radius : String = ""
    
    var SeguesForData : String = "ShowListSegue"
    
    var LocationAutomatic : Bool?
    var toSearchFilter : Business_Sort_Type?
    var HaveLocation = false
    
    var searchList = [Search_type]()

    
    //MARK: Override Functions
    override func viewWillAppear(animated: Bool) {
    
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Setup the TextField
        SearchField.delegate = self
        
        let VoiceSearchMinibutton = UIButton(type: UIButtonType.Custom)
        VoiceSearchMinibutton.frame = CGRectMake(0, 0, 16, 16)
        VoiceSearchMinibutton.setImage(UIImage(named:"Mic2"),forState: UIControlState.Normal)
        VoiceSearchMinibutton.addTarget(self, action: #selector(FirstViewController.VoiceSearch_Action(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        SearchField.leftView = VoiceSearchMinibutton;
        SearchField.leftViewMode = UITextFieldViewMode.Always;
        
        if(CLLocationManager.locationServicesEnabled())
        {
            LocManager = CLLocationManager();
            LocManager?.desiredAccuracy = CLLocationAccuracy.init(500)
            if( LocManager != nil)
            {
                if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse)
                {
                    LocManager!.delegate = self
                    //Not going to be moving.
                    LocManager!.startUpdatingLocation()
                    LocManager!.requestLocation();
                }
                else
                {
                    LocManager!.requestWhenInUseAuthorization()
                    LocManager!.delegate = self
                    //Not going to be moving.
                    LocManager!.startUpdatingLocation()
                    LocManager!.requestLocation();
                }
                
            }
        }
        else
        {
            //Location Servces are not available, Display a warning.
            let PopUp = UIAlertController(title: NSLocalizedString("LocationErrorTitle", comment: "Local"),
                message: NSLocalizedString("LocationErrorMessage", comment: "Local"), preferredStyle: UIAlertControllerStyle.Alert)
            
            PopUp.addAction(UIAlertAction(title: NSLocalizedString("LocationErrorActionMessage", comment: "Local"),
                style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(PopUp, animated: true, completion:nil)

        }
        
        //MIC request
        if (AudioSession.respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                //surround the permissions with Do-Catch
                do{
                    if granted {
                        print("granted")
                        _ = try self.AudioSession.setCategory(AVAudioSessionCategoryAudioProcessing)
                        _ = try self.AudioSession.setActive(true)
                    } else{
                        self.Mic_Button.userInteractionEnabled = false
                    }
                }
                catch let error as NSError
                {
                    print(error.description)
                }
                
            })
            
        }
        
        //Set Delegate for LeftData passing
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let LeftView = (appDelegate.drawerContainer?.leftDrawerViewController as! UINavigationController).topViewController as! LeftViewControllerDelegate
        
        self.LeftSideDelegate = LeftView
        
        self.tabBarController?.delegate = self
        
        self.RecentTableDelegate = (self.tabBarController?.viewControllers![1] as! UINavigationController).topViewController as! RecentTableViewController
        self.RecentTableDelegate?.passFirstViewDelegate(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        let PopUp = UIAlertController(title: NSLocalizedString("Warning", comment: "MemWarning"), message: NSLocalizedString("LowMemoryWarning", comment: "MemWarning"), preferredStyle: UIAlertControllerStyle.Alert);
        PopUp.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
            //TODO: Hadle memory warning loginc after this.
        }))
        
        presentViewController(PopUp, animated: true, completion: nil)
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        let name =  (viewController as! UINavigationController).topViewController?.title
        
        if name == "Recent Searches"
        {
            RecentTableDelegate?.passSearches(searchList)
            RecentTableDelegate?.passSegueDisplay(SeguesForData)
            RecentTableDelegate?.passLocation(local!)
        }

        return true
    }
    
    
    // MARK : Delegate Functions
    
    /**
     Delegate Function to Pass DATA
     
     - parameter name: Name in String format
     - parameter data: Data as AnyObject
     */
    func passData(name: String, data: Any)
    {
        //DO STUFF WITH DATA COMING IN
        print(name,data)
        
        
        if( name == "CollectionViewType" )
        {
            if data as! String == "Collection"
            {
                SeguesForData = "ShowCollectionSegue"
            }
            else
            {
                SeguesForData = "ShowListSegue"
            }
        }
        
        if name == "NewCity"{
            
            toSearch_City = data as! String
            LocationAutomatic = false
            
        }
        
        if name == "NewState"{
            toSearch_State = data as! String
            LocationAutomatic = false
            
            let geoCoder = CLGeocoder();
            
            geoCoder.geocodeAddressString("\(toSearch_City),\(toSearch_State)", completionHandler: {(places, error) -> Void in
                
                if (error != nil)
                {
                    print("Could not find location, Error: \(error)")
                    self.HaveLocation = false
                    return
                }
                
                if places?.count != 0{
                    
                    print("Found the place you are in")
                    
                    let actualLocation = places![0] as CLPlacemark
                    
                    if(actualLocation.postalCode == nil)
                    {
                        //Trying to get postal code
                        CLGeocoder().reverseGeocodeLocation(actualLocation.location!, completionHandler: {(places, error) -> Void in
                            
                            if (error != nil)
                            {
                                print("Could not find location, Error: \(error)")
                                return
                            }
                            
                            if places?.count != 0{
                                
                                let actualLocation2 = places![0] as CLPlacemark
                                
                                //Postal Code
                                print("PostalCode \(actualLocation2.postalCode) ")
                                self.toSearch_PostalCode = Int(actualLocation2.postalCode!)!
                                self.HaveLocation = true
                            }
                        })
                        
                    }
                    else
                    {
                        //Postal Code
                        print("PostalCode \(actualLocation.postalCode) ")
                        self.toSearch_PostalCode = Int(actualLocation.postalCode!)!
                        self.HaveLocation = true
                    }
                    
                    self.local = places![0].location
                    
                    return
                }
                self.HaveLocation = false
           })
        }
        
        if(name == "FilterType")
        {
            self.toSearchFilter = Business_Sort_Type(rawValue: data as! String)
        }
        
        if(name == "Radius")
        {
            self.toSearch_radius = data as! String
        }
        
    }
    
    
    func passSearchList(list: [Search_type]) {
        self.searchList = list
    }
    
    //MARK: Functions
    
    
    //MARK: Actions
    
    @IBAction func VoiceSearch_Action(sender: AnyObject) {
    
        
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                                      message: NSLocalizedString("VoiceRegNotAvailable", comment: "Error"),
                        preferredStyle: UIAlertControllerStyle.Alert)
        
                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                        style: UIAlertActionStyle.Cancel, handler: nil)
        
                    alert.addAction(okButton)
        
                    presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func Start_Search(sender: AnyObject) {
        
        if(keyword.isEmpty)
        {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                message: NSLocalizedString("ErrorSearchNoComplete", comment: "Error"),
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(okButton)
            
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            if(self.connectedToNetwork())
            {
                print("Starting Search system")
                
                //Showing Loading screen
                EZLoadingActivity.show(NSLocalizedString("Loading", comment: ""), disableUI: true)
                
                self.businessList.removeAll()
                self.APICALL = SoleoAPI.init(location: local!, name: name, category: category, keyword: keyword,city: toSearch_City, state: toSearch_State, postal: toSearch_PostalCode)
                
                if self.toSearchFilter != nil{
                    self.APICALL?.sortType = toSearchFilter!
                }
                
                if !self.toSearch_radius.isEmpty{
                    self.APICALL?.toSearch_radious = toSearch_radius
                }
                
                
                //start API GET DATA
                self.APICALL?.getData({ (list, error) -> Void in
                    
                    if(error == nil){
                        print("Finally got \(list!.count)")
                        self.businessList = list!;
                    }
                    else
                    {
                        print("We found a error")
                        EZLoadingActivity.hide(success: false, animated: true)
                        
                        print(error)
                        
                        if (error?.userInfo.keys.first == "info")
                        {
                            //Display a warning, NO DATA, ERROR OCCURED.
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                message: error?.userInfo.values.first as? String, preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            
                            alert.addAction(okButton)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        else{
                            //Display a warning, NO DATA, ERROR OCCURED.
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                message: NSLocalizedString("ErrorGettingData", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            
                            alert.addAction(okButton)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    }
                })
                

                Async.background {
                    while self.businessList.isEmpty {
                        //print("Still Loading Data")
                        if self.businessList.count != 0{
                            break
                        }
                        
                        if (self.APICALL?.dataError != nil)
                        {
                            print("Got a error:")
                            print(self.APICALL?.dataError);
                            break;
                        }
                    }
                    }.main {
                        if (self.APICALL?.dataError == nil)
                        {
                            self.performSegueWithIdentifier(self.SeguesForData, sender:self)
                            EZLoadingActivity.hide(success: true, animated: true)
                            self.searchList.append((self.APICALL?.SearchRequest)!)
                        }
                }
                
                
            }
            else
            {
                //Display a warning, NO NETWORK.
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                    message: NSLocalizedString("NoNetworkError", comment: "Error"),
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                    style: UIAlertActionStyle.Cancel, handler: nil)
                
                alert.addAction(okButton)
                
                presentViewController(alert, animated: true, completion: nil)
            }

            
        }
        
        
    }
    
    
    @IBAction func showLeft_Menu(sender: AnyObject) {
        
      let appDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.drawerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        

    }
    
    @IBAction func ChangeDisplaySelection(sender: UISwitch) {
        
        //Change how we are going to send the data...
        print("HEY WE GOT HERE")
    }
    
    //MARK: UITextDelegate Functions
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if(local?.coordinate.latitude == 0.0 && local?.coordinate.longitude == 0.0) || (local == nil) && !HaveLocation{
            let PopUp = UIAlertController(title:  NSLocalizedString("LocationErrorTitle", comment: "Local"),
                message: NSLocalizedString("LocationNotSet", comment: "Local"),
                preferredStyle: UIAlertControllerStyle.Alert)
            
            PopUp.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(PopUp, animated: true, completion:nil)
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        SearchField.resignFirstResponder();
        
        return true

        
    }

    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if (!SearchField.text!.isEmpty)
        {
            keyword = SearchField.text!
//            name = SearchField.text!
        }
    }
    
    //MARK: Location Functions
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        local = location
    
        LocManager!.stopUpdatingLocation()
        
        
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(places, error) -> Void in
            
            if (error != nil)
            {
                print("Could not find location, Error: \(error)")
                return
            }
            
            if places?.count != 0{
                
                let actualLocation = places![0] as CLPlacemark
                
                //Postal Code
                print("PostalCode \(actualLocation.postalCode) ")
                self.toSearch_PostalCode = Int(actualLocation.postalCode!)!
                
                //City
                print("City \(actualLocation.locality) ")
                self.toSearch_City = actualLocation.locality!
                
                //State
                print("PostalCode \(actualLocation.administrativeArea) ")
                self.toSearch_State = actualLocation.administrativeArea!
                
                self.LocationAutomatic = true
                
                let dataToSend = ["AutoLocal" : "true" , "city" : "\(self.toSearch_City)" , "state" : "\(self.toSearch_State)"]
                
                self.LeftSideDelegate?.passToLeft("Location", data: dataToSend)
                self.HaveLocation = true
                
            }
        })


    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print ("Location Error: \(error.description)")
        manager.stopUpdatingLocation();
    }
    
    
    //MARK: Controller DataFlow and Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Passing Information")
        if  SeguesForData == "ShowCollectionSegue"{
            if segue.identifier == SeguesForData{
                
                let NavController = segue.destinationViewController as! UINavigationController
                
                let destView : ListingCollectionViewController = NavController.topViewController as!  ListingCollectionViewController
                
                print("Passing the data for collection \(self.businessList.count)")
                destView.list = self.businessList
                destView.userLocation = self.local
            }

        }
        else
        {
            if segue.identifier == SeguesForData{
                
                let NavController = segue.destinationViewController as! UINavigationController
                
                let destView : ListingTableViewController  = NavController.topViewController as!  ListingTableViewController
                
                print("Passing the data for table \(self.businessList.count)")
                destView.list = self.businessList
                destView.userLocation = self.local
            }

        }
        
    }
    
    
    //MARK: Support Functions
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        //let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable)
    }


}

