//
//  ListingCollectionViewController.swift
//  SoLocal API
//
//  Created by Victor Jimenez Delgado on 1/29/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import Contacts
import MapKit
import Soleo_Local_Search_API_Framework

protocol ListingCollectionViewDelegate {
    
    func updateBusinees(_ bussinessToUpdate:Business)
    
}


class ListingCollectionViewController: UICollectionViewController, ListingCollectionViewDelegate {
    
    //MARK: Fields

    @IBOutlet var ListingCollectionView: UICollectionView!
    
    @IBOutlet var LongPressGesture: UILongPressGestureRecognizer!
    
    //Change this to your theme
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    let reuseIdentifier = "BusinessListingCell"
    
    var APICALL : SoleoAPI?
    
    //MARK: List
    var list = [Business]()
    
    var indexPathSelected : IndexPath = IndexPath()
    
    var userLocation : CLLocation?

    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //UI code does not like to re-register if doing it in StoryBoard. Only for programatic items
//        self.collectionView!.registerClass(ListingCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.ListingCollectionView.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)
        
        self.ListingCollectionView.reloadData()

        // Do any additional setup after loading the view.
        self.APICALL = SoleoAPI()
        self.APICALL?.apiKey = <#Your APIKEY#>
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKR: Delegate Functions
    func updateBusinees(_ bussinessToUpdate:Business){
        list[(indexPathSelected as NSIndexPath).item] = bussinessToUpdate;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //We only want 1 Business Listing per View.
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return list.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        
        let cell : ListingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ListingCollectionViewCell
        
        let currentListing = list[(indexPath as NSIndexPath).item]
        
        if(currentListing.type == Business_Type.Sponsored){
            cell.ListingImage.image = UIImage(named: "sponsored")!
        }
        else{
        cell.ListingImage.image = UIImage(named: "organic")!
        }
        
        cell.ListingName.text = currentListing.name
        cell.ListingType.text = currentListing.type.rawValue
        cell.ListingCategory.text = currentListing.Category
        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
        cell.ListingAddress.text = "\(currentListing.address) \(currentListing.city) \(currentListing.state), \(currentListing.zip) "
        
        if currentListing.Location!.coordinate.latitude != 0.0
        {
            
            let df = MKDistanceFormatter()
            df.units = .imperialWithYards
            df.unitStyle = .abbreviated
            
            let prettyDistance = df.string(fromDistance: currentListing.distance * 1600)
            
            cell.ListingDistance.text = NSLocalizedString("DistanceTo", comment: "Distance") + "\(prettyDistance)"
            
        }
        else if (currentListing.address.isEmpty)
        {
            cell.ListingDistance.text = "National"
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        indexPathSelected = indexPath
        
        return true
    }


    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    //MARK: Segue Actions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowListingDetails"{
            
            let indexPath: IndexPath = self.ListingCollectionView.indexPathsForSelectedItems![0]
            let destView2 : ListingDetailsViewController = segue.destination as! ListingDetailsViewController
            
            destView2.business = list[(indexPath as NSIndexPath).item]
            destView2.ListingCollectionDelegate = self

            
        }else{
            print("im here now!")
        }
        
    }

    
    //MARK: Exit Actions
    @IBAction func back_to_Search(_ sender: AnyObject) {
        print("empting list")
        dismiss(animated: true, completion: nil)
        list.removeAll();
    }
    
    //Used for returning from results view
    @IBAction func unwindToViewController(_ segue:UIStoryboardSegue) {
        print("Going to unwind")
        print("empting list")
        dismiss(animated: true, completion: nil)
        list.removeAll()
    }
    
    
    //MARK: Actions
    @IBAction func LongPress(_ sender: AnyObject) {
    
        let PopUp = UIAlertController(title: NSLocalizedString("ActionsTitle", comment: ""),
            message: NSLocalizedString("ActionsMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        PopUp.addAction(UIAlertAction(title: NSLocalizedString("Call", comment: ""),
            style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!)in
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.view.addSubview(activityIndicator)
            activityIndicator.frame = self.view.bounds

            activityIndicator.startAnimating()
            if(!self.list[(self.indexPathSelected as NSIndexPath).item].presented){
                    
                    self.APICALL!.getCallBacksData(self.list[(self.indexPathSelected as NSIndexPath).item], action: Business_Callback_type.present, processCompleter: { (returningBusiness, error) -> Void in
                        
                        if(error != nil)
                        {
                            print("Error Happend on Selected with Get Callbacks:",error)
                            // Do any additional setup after loading the view.
                            activityIndicator.stopAnimating()
                            
                            //Display a warning, Could not get Listing, ERROR OCCURED.
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                            
                            alert.addAction(okButton)
                            
                            // Do any additional setup after loading the view.
                            activityIndicator.stopAnimating()
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        if(returningBusiness != nil){
                            self.APICALL!.getCallBacksData(returningBusiness!, action: Business_Callback_type.selected_with_details, processCompleter: { (returningBusiness, error) -> Void in
                                
                                if(error != nil)
                                {
                                    print("Error Happend on Selected with Get Callbacks:",error)
                                    // Do any additional setup after loading the view.
                                    activityIndicator.stopAnimating()
                                    
                                    //Display a warning, Could not get Listing, ERROR OCCURED.
                                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                        message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                                    
                                    alert.addAction(okButton)
                                    
                                    // Do any additional setup after loading the view.
                                    activityIndicator.stopAnimating()
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    return
                                }
                                
                                if(returningBusiness != nil)
                                {
                                    self.APICALL!.getCallBacksData(returningBusiness!, action: Business_Callback_type.getNumbers, processCompleter: { (returningBusiness, error) -> Void in
                                        
                                        if(error != nil)
                                        {
                                            print("Error Happend on Selected with Get Callbacks:",error)
                                            // Do any additional setup after loading the view.
                                            activityIndicator.stopAnimating()
                                            
                                            //Display a warning, Could not get Listing, ERROR OCCURED.
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                                message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                                            
                                            alert.addAction(okButton)
                                            
                                            // Do any additional setup after loading the view.
                                            activityIndicator.stopAnimating()
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                            return
                                        }
                                        
                                        
                                        
                                        //Time to load the information we just go:
                                        if(returningBusiness != nil){
                                            self.list[(self.indexPathSelected as NSIndexPath).item] = returningBusiness!
                                            
                                            // Do any additional setup after loading the view.
                                            activityIndicator.stopAnimating()
                                            
                                            let phoneURL = "telprompt://\(self.list[(self.indexPathSelected as NSIndexPath).item].callCompletionNumber!.stringValue)"
                                            
                                            //This will open a URL with TELPROMT which will allow us to return to the app
                                            //once the user is done.
                                            UIApplication.shared.openURL(URL(string: phoneURL)!)
                                            
                                            self.APICALL?.getCallBacksData(self.list[(self.indexPathSelected as NSIndexPath).item], action: Business_Callback_type.calledCompletionNumber, processCompleter: { (returningBusiness, error) -> Void in
                                                self.list[(self.indexPathSelected as NSIndexPath).item] = returningBusiness!
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
        }))
        
        PopUp.addAction(UIAlertAction(title: NSLocalizedString("AddToContacts", comment: ""),
            style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                //Going to move forward REALLY QUICK HERE...
                //This might cause issues.
                
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                self.view.addSubview(activityIndicator)
                activityIndicator.frame = self.view.bounds
                activityIndicator.startAnimating()
                
                if(!self.list[(self.indexPathSelected as NSIndexPath).item].presented){
                    
                    self.APICALL!.getCallBacksData(self.list[(self.indexPathSelected as NSIndexPath).item], action: Business_Callback_type.present, processCompleter: { (returningBusiness, error) -> Void in
                        
                        if(error != nil)
                        {
                            print("Error Happend on Selected with Get Callbacks:",error)
                            // Do any additional setup after loading the view.
                            activityIndicator.stopAnimating()
                            
                            //Display a warning, Could not get Listing, ERROR OCCURED.
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                            
                            alert.addAction(okButton)
                            
                            // Do any additional setup after loading the view.
                            activityIndicator.stopAnimating()
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        if(returningBusiness != nil){
                            self.APICALL!.getCallBacksData(returningBusiness!, action: Business_Callback_type.selected_with_details, processCompleter: { (returningBusiness, error) -> Void in
                                
                                if(error != nil)
                                {
                                    print("Error Happend on Selected with Get Callbacks:",error)
                                    // Do any additional setup after loading the view.
                                    activityIndicator.stopAnimating()
                                    
                                    //Display a warning, Could not get Listing, ERROR OCCURED.
                                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                        message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                                    
                                    alert.addAction(okButton)
                                    
                                    // Do any additional setup after loading the view.
                                    activityIndicator.stopAnimating()
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    return
                                }
                                
                                if(returningBusiness != nil){
                                    self.APICALL!.getCallBacksData(returningBusiness!, action: Business_Callback_type.getNumbers, processCompleter: { (returningBusiness, error) -> Void in
                                        
                                        if(error != nil)
                                        {
                                            print("Error Happend on Selected with Get Callbacks:",error)
                                            // Do any additional setup after loading the view.
                                            activityIndicator.stopAnimating()
                                            
                                            //Display a warning, Could not get Listing, ERROR OCCURED.
                                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                                                message: NSLocalizedString("ErrorGettingBusiness", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                                            
                                            alert.addAction(okButton)
                                            
                                            // Do any additional setup after loading the view.
                                            activityIndicator.stopAnimating()
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                            return
                                        }
                                        
                                        
                                        
                                        
                                        //Time to load the information we just go:
                                        if(returningBusiness != nil){
                                            
                                            self.makeandSaveContact(returningBusiness!)
                                            self.list[(self.indexPathSelected as NSIndexPath).item] = returningBusiness!
                                            
                                        }
                                        
                                        // Do any additional setup after loading the view.
                                        activityIndicator.stopAnimating()
                                    })
                                }
                            })
                        }
                    })
                }
        }))
        
        if(self.list[(self.indexPathSelected as NSIndexPath).item].address != "")
        {
            PopUp.addAction(UIAlertAction(title: NSLocalizedString("NavigateTo", comment: ""),
                style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    
                    
                    let geoCoder = CLGeocoder();
                    
                    geoCoder.geocodeAddressString("\(self.list[(self.indexPathSelected as NSIndexPath).item].address) \(self.list[(self.indexPathSelected as NSIndexPath).item].city),\(self.list[(self.indexPathSelected as NSIndexPath).item].state)", completionHandler: {(places, error) -> Void in
                        
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
                        mapKit.name = self.list[(self.indexPathSelected as NSIndexPath).item].name

                    
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey : true, MKLaunchOptionsMapCenterKey: NSValue.init(mkCoordinate: (self.userLocation?.coordinate)!) ] as [String : Any]
                        
                        
                        mapKit.openInMaps(launchOptions: launchOptions)
                        
                    })
                    
            }))
        }
        
        PopUp.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
             //Leave blank for that the view goes aways automaticly.
            
        }))
        
        //For iPad support
        if PopUp.popoverPresentationController != nil{
            
            let cell = self.collectionView?.cellForItem(at: indexPathSelected)
            PopUp.popoverPresentationController?.sourceView = cell
            PopUp.popoverPresentationController?.sourceRect = (cell?.bounds)!//CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height, 1.0, 1.0);
        }

        
        self.present(PopUp, animated: true, completion:nil)
        
    }
    
    @IBAction func show_LeftMenu(_ sender: AnyObject) {
        
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
        
    }
    
    //MARK: Support Function:
    func makeandSaveContact(_ businessToAdd: Business)
    {
        // Creating a mutable object to add to the contact
        let contact = CNMutableContact()
        
        contact.imageData = Data() // The profile picture as a NSData object
        
        contact.organizationName = businessToAdd.name
        contact.givenName = businessToAdd.name
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberMain,
            value:businessToAdd.displayNumber!)]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = businessToAdd.address
        homeAddress.city = businessToAdd.city
        homeAddress.state = businessToAdd.state
        homeAddress.postalCode = businessToAdd.zip
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        
        contact.note = NSLocalizedString("CreatedBranding", comment: "")
        
        
        // Saving the newly created contact
        do{
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try store.execute(saveRequest)
        }
        catch let error as NSError{
            print("Got a error while saving the contact: \(contact)" , error)
        }

    }

}

//MARK: EXTENSIONS
extension ListingCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            //If the listing is different change this insect value.
        
            return CGSize(width: 175, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}
