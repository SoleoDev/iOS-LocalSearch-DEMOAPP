//
//  ListingViewController.swift
//  SoLocal API
//
//  Created by Victor Jimenez Delgado on 1/29/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import MapKit


extension String {
    public func toPhoneNumber() -> String {
        return stringByReplacingOccurrencesOfString("(\\d{3})(\\d{3})(\\d+)", withString: "($1) $2-$3", options: .RegularExpressionSearch, range: nil)
    }
}

class ListingDetailsViewController: UIViewController {

    //MARK: IU Fields
    
    @IBOutlet weak var ListingName: UILabel!
    
    @IBOutlet weak var ListingAddress: UILabel!
    
    @IBOutlet weak var ListingCity: UILabel!
    
    @IBOutlet weak var ListingState: UILabel!

    @IBOutlet weak var ListingZipCode: UILabel!
    
    @IBOutlet weak var ListingImage: UIImageView!
    
    @IBOutlet weak var ListinnDisplayNumber: UILabel!
    
    @IBOutlet weak var ListingMonetizationNumber: UILabel!
    
    @IBOutlet weak var ListingType: UILabel!
    
    @IBOutlet weak var Callback_button: UIButton!
    
    @IBOutlet weak var BackButton: UIBarButtonItem!
    
    @IBOutlet weak var Extra_info: UITextView!
    
    @IBOutlet weak var External_info: UITextView!
    
    @IBOutlet weak var ScrollView: UIScrollView!
    
    
    //MARK: internal Fields
    private var APICALL : SoleoAPI?
    
    var business = Business()
    
    var ListingCollectionDelegate : ListingCollectionViewDelegate?
    var ListingTableDelegate : ListingCollectionViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //Remeber, UILabels and other elements are always nil until the view is loaded.
        
    }
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //Time to get the extra information
        //We need to get information twice OR tree times.
        //This is due that we don't display any information at all on the CollectionView Controller.
        //If we where doing this for each Cell, then the Selected Callback will be done for EACH Cell Creationg and update the object there.
        //1) Send the presented to be able to get the Selected callback.
        //2) Send the selected OR selected details if available
        //3) If Selected is only available we need to get the details too in a seperated request. 
        //4) GET NUMBERS after all that TOO...
        
        //NOTE, this must be nested in order to aggregate the results.
        
        Extra_info.scrollEnabled = true
        ScrollView.scrollEnabled = true
        ScrollView.contentSize = CGSize(width: 400, height: 694)
        Extra_info.clearsOnInsertion = true
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()
        
        //Setting Up basic Information
        ListingName.text = business.name
        ListingAddress.text = business.address
        ListingCity.text = business.city
        ListingState.text = business.state
        ListingZipCode.text = business.zip
        
        if(business.type == Business_Type.Sponsored){
            ListingImage.image = UIImage(named: "sponsored")!
        }
        else{
            ListingImage.image = UIImage(named: "organic")!
        }
        
        ListingType.text = business.type.rawValue
     
        
        
        APICALL = SoleoAPI()
        
        if(!business.presented){
        
            APICALL?.getCallBacksData(business, action: Business_Callback_type.present, processCompleter: { (returningBusiness, error) -> Void in
                
                if(error != nil)
                {
                     print("Error Happend on Presented:", error)
                    // Do any additional setup after loading the view.
                    activityIndicator.stopAnimating()
                    
                    //Display a warning, Could not get Listing, ERROR OCCURED.
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                        message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    
                    alert.addAction(okButton)
                    
                    self.presentViewController(alert, animated: true, completion: nil)

                    
                    return
                }
                
                self.APICALL?.getCallBacksData(returningBusiness!, action: Business_Callback_type.selected_with_details, processCompleter: { (returningBusiness, error) -> Void in
                    
                    if(error != nil)
                    {
                         print("Error Happend on Selected with Details:",error)
                        // Do any additional setup after loading the view.
                        activityIndicator.stopAnimating()
                        
                        //Display a warning, Could not get Listing, ERROR OCCURED.
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                            message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        
                        alert.addAction(okButton)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        return
                    }
                    
                    self.APICALL?.getCallBacksData(returningBusiness!, action: Business_Callback_type.getNumbers, processCompleter: { (returningBusiness, error) -> Void in
                        
                        
                        if(error != nil)
                        {
                            print("Error Happend on Selected with Get Callbacks:",error)
                            // Do any additional setup after loading the view.
                            activityIndicator.stopAnimating()
                            
                            //Display a warning, Could not get Listing, ERROR OCCURED.
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            
                            alert.addAction(okButton)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        
                        //Time to load the information we just go:
                        if(returningBusiness != nil){
                            
                            self.business = returningBusiness!
                            self.ListinnDisplayNumber.text =    (self.business.displayNumber!.stringValue).toPhoneNumber()
                            self.ListingMonetizationNumber.text = (self.business.callCompletionNumber!.stringValue).toPhoneNumber()
                            for var details in self.business.extraDetails{
                                details.appendContentsOf("-- \n")
                                self.Extra_info.text?.appendContentsOf(details)
                            }
                            
                            
                        }
                        // Do any additional setup after loading the view.
                        activityIndicator.stopAnimating()
                    })
                })
            })
        }
        else
        {
            //This means that the user already did something in the PreviousView
            //Either created a contact or called
            //So the item is already updated.
            
            ListinnDisplayNumber.text =    (business.displayNumber!.stringValue).toPhoneNumber()
            ListingMonetizationNumber.text = (business.callCompletionNumber!.stringValue).toPhoneNumber()
            for var details in business.extraDetails{
                details.appendContentsOf("-- \n")
                Extra_info.text?.appendContentsOf(details)
            }
            
            // Do any additional setup after loading the view.
            activityIndicator.stopAnimating()

        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if(segue.identifier == "GoToBusiness")
//        {
//            
//            let destinationView = segue.destinationViewController as! MapViewController
//            
//            let geoCoder = CLGeocoder();
//            
//            geoCoder.geocodeAddressString("\(business.address) \(business.city),\(business.state)", completionHandler: {(places, error) -> Void in
//                
//                if (error != nil)
//                {
//                    print("Could not find location, Error: \(error)")
//                    return
//                }
//                
//                
//               destinationView.Location = places![0].location
//                
//                
//            })
//
//            
//        }
        
    }

    
    //MARK: Actions
    @IBAction func doCallBack(sender: UIButton) {
        
        if business.callCompletionNumber != nil{
            let phoneURL = "telprompt://\(business.callCompletionNumber!.stringValue)"
            
            //This will open a URL with TELPROMT which will allow us to return to the app
            //once the user is done.
            UIApplication.sharedApplication().openURL(NSURL(string: phoneURL)!)
            if(business.type == Business_Type.Sponsored)
            {
                APICALL?.getCallBacksData(business, action: Business_Callback_type.calledCompletionNumber, processCompleter: { (returningBusiness, error) -> Void in
                    
                    if(error != nil)
                    {
                        print("Error Happend on Selected with Get Callbacks:",error)
                        //Already called
                        
                        return
                    }
                    
                     if(returningBusiness != nil){
                        self.business = returningBusiness!
                    }
                    
                })
            }
            else
            {
                APICALL?.getCallBacksData(business, action: Business_Callback_type.calledDisplayNumber, processCompleter: { (returningBusiness, error) -> Void in
                    
                    if(error != nil)
                    {
                        print("Error Happend on Selected with Get Callbacks:",error)
                        //Already called
                        
                        return
                    }
                    
                    if(returningBusiness != nil){
                        self.business = returningBusiness!
                    }

                })
            }
        }
        else{
            
            //Display a warning, Could not get Listing, ERROR OCCURED.
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                          message: NSLocalizedString("ErrorGettingNumber", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
            
            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(okButton)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    @IBAction func backButtonPress(sender: AnyObject) {
        
        if ListingTableDelegate != nil{
            ListingTableDelegate!.updateBusinees(business)
        }
        else{
            ListingCollectionDelegate!.updateBusinees(business)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func NavigateTo(sender: UIButton) {
        //Code to add the navigation to function
//        self.performSegueWithIdentifier("GoToBusiness", sender: self)
        
        let geoCoder = CLGeocoder();
        
        geoCoder.geocodeAddressString("\(business.address) \(business.city),\(business.state)", completionHandler: {(places, error) -> Void in
            
            if (error != nil)
            {
                print("Could not find location, Error: \(error)")
                return
            }
            
            
            let Location = places![0]
            let loca = MKPlacemark(placemark: Location)
             //Create a region centered on the starting point with a 10km span
            
            //var region = MKCoordinateRegionMakeWithDistance((Location?.coordinate)!, 10000, 10000);

            // Open the item in Maps, specifying the map region to display.

            let mapKit = MKMapItem.init(placemark: loca)
            mapKit.name = self.business.name
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            mapKit.openInMapsWithLaunchOptions(launchOptions)

        })

        
    }
    

}
