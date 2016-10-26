//
//  ListingTableViewController.swift
//  SoLocal API
//
//  Created by Victor Jimenez on 2/12/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import Contacts
import MapKit

class ListingTableViewController: UITableViewController, ListingCollectionViewDelegate {
    
    //MARK: Fields
    let reuseIdentifier = "BusinessListingTableCell"
    
    @IBOutlet var LongPressGesture: UILongPressGestureRecognizer!
    
    @IBOutlet var ListingTableView: UITableView!
    
    var APICALL : SoleoAPI?
    
    //MARK: List
    var list = [Business]()
    
    var indexPathSelected : IndexPath = IndexPath()
    
    var userLocation : CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.APICALL = SoleoAPI()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKR: Delegate Functions
    func updateBusinees(_ bussinessToUpdate:Business){
        list[(indexPathSelected as NSIndexPath).item] = bussinessToUpdate;
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell : ListingTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListingTableViewCell
        
        let currentListing = list[(indexPath as NSIndexPath).item]
        
        if(currentListing.type == Business_Type.Sponsored){
            cell.ListingImage.image = UIImage(named: "sponsored")!
        }
        else{
            cell.ListingImage.image = UIImage(named: "organic")!
        }
        
        cell.ListingName.text = currentListing.name
        cell.ListinType.text = currentListing.type.rawValue
        cell.ListingCategory.text = currentListing.Category
        
        cell.ListingAddress.text = "\(currentListing.address) \(currentListing.city) \(currentListing.state), \(currentListing.zip) "

        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)
    
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        indexPathSelected = indexPath
        
        return true
    }

    
    //MARK: Segue Actions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowListingDetails"{
            
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
            let destView2 : ListingDetailsViewController = segue.destination as! ListingDetailsViewController
            
            destView2.business = list[(indexPath as NSIndexPath).item]
            destView2.ListingTableDelegate = self
            
            
        }else{
            print("im here now!")
        }
        
    }
    
    @IBAction func backToSearch(_ sender: AnyObject) {
        
        print("empting list")
        dismiss(animated: true, completion: nil)
        list.removeAll();
        
    }
    
    
    //MARK: Actions
    @IBAction func LongPressCell(_ sender: AnyObject) {
        
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
                    //Leave blank for that the view goes aways automaticly.
                    
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
            
            let cell = self.tableView.cellForRow(at: indexPathSelected)
            PopUp.popoverPresentationController?.sourceView = cell
            PopUp.popoverPresentationController?.sourceRect = (cell?.bounds)!//CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height, 1.0, 1.0);
        }
        
        
        self.present(PopUp, animated: true, completion:nil)
        
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
