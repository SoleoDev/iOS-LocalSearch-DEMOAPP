//
//  RecentTableViewController.swift
//  Soleo_Tab_Template
//
//  Created by Victor Jimenez Delgado on 1/28/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import SystemConfiguration
import CoreLocation
import Soleo_Local_Search_API_Framework

protocol RecentTableViewControllerDelegate{
    
    func passSearches(newList: [Search_type])
    func passSegueDisplay(segueToDisplay : String)
    func passFirstViewDelegate(delegate : FirstViewControllerDelegate)
    func passLocation(location : CLLocation)
}

class RecentTableViewController: UITableViewController, RecentTableViewControllerDelegate {

    //MARK: Fields
    
    var searchListToDisplay = [Search_type]()
    
    let cellReuseIdentifier = "favCell"
    
    //MARK: SOLEO API Fields
    
    var APICALL : SoleoAPI?
    
    var businessList = [Business]()
    
    var local : CLLocation?
    
    //MARK: Fields for Segue
    var SeguesForData : String = "ShowCollectionSegue"
    
    //MARK: Delegates
    var FirstViewDelegate : FirstViewControllerDelegate?
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Setting up edit
        navigationItem.rightBarButtonItem = editButtonItem()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(imageLiteral: "background_pattern"))
    }
    
    override func viewDidDisappear(animated: Bool) {
        saveSearches()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table DataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchListToDisplay.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! RecentTableViewCell

        // Configure the cell...
        cell.Search_name.text = searchListToDisplay[indexPath.item].search_name
        cell.ValidTime.text = "Valid until: \(searchListToDisplay[indexPath.item].search_time)"
        
        if searchListToDisplay[indexPath.item].favority.boolValue{
            
            cell.FavButton.image = UIImage(named: "ic_favorite_white_36pt")
        }
        else{
            cell.FavButton.image = UIImage(named: "ic_favorite_border_white_36pt")
        }
        
        
        cell.backgroundColor = UIColor(patternImage: UIImage(imageLiteral: "Cellsbackground"))

        return cell
    }
    
    
    //MARK: TableView Delegate
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var newActions = [UITableViewRowAction]()
        
        
        let FavAction = UITableViewRowAction(style: .Normal, title: (NSLocalizedString("Favorite", comment: "action"))) { (rowAction, indexPath) -> Void in
            
            print("Adding to Fav")
            let Updated = self.searchListToDisplay[indexPath.item]
            
            if Updated.favority.boolValue{
                Updated.favority = false
            }
            else{
                Updated.favority = true
            }
            
            self.searchListToDisplay[indexPath.item] = Updated
            tableView.endEditing(true)
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
        
        FavAction.backgroundColor = UIColor.yellowColor()
        
        let deleteAction = UITableViewRowAction(style: .Destructive, title: (NSLocalizedString("Delete", comment: "action"))) { (rowAction, indexPath) -> Void in
                print("Deleting")

                self.searchListToDisplay.removeAtIndex(indexPath.item)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
        deleteAction.backgroundColor = UIColor.redColor()
        
        
        
        newActions.append(deleteAction)
        
        newActions.append(FavAction)
        
        
        return newActions
    }

    //
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        StartSearch(indexPath.item)
    }

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

    
    // MARK: - Navigation Segue
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  SeguesForData == "showResultsAgainCollection"{
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

    
    
    //MARK: Actions
    
    @IBAction func Search_NavBar_action(sender: AnyObject) {
        
        
            self.tabBarController?.selectedIndex = 0;
        
    }
    
    
    //MARK: Functions DELEGATE
    func passSearches(newList: [Search_type]){
        
        print("Sending it in delegate")
        
        if newList.count > 0
        {
            searchListToDisplay = newList;
            self.tableView.reloadData()
        }
        else {
            if let savedLoading = loadpreviousSearches(){
                
                searchListToDisplay = savedLoading
                self.tableView.reloadData()
                
            }
        }
    }
    
    func passSegueDisplay(segueToDisplay : String){
        
        if segueToDisplay == "ShowCollectionSegue"
        {
            SeguesForData = "showResultsAgainCollection"
        }
        else{
            SeguesForData = "showResultsAgainList"
        }
        
    }
    
    func passFirstViewDelegate(delegate: FirstViewControllerDelegate) {
        self.FirstViewDelegate = delegate
    }
    
    func passLocation(location : CLLocation){
        self.local = location
    }
    
    //MARK: Actions
    func StartSearch(indexForSearch: Int){
        if(self.connectedToNetwork())
        {
            print("Starting Search system")
            
            //Showing Loading screen
            EZLoadingActivity.show(NSLocalizedString("Loading", comment: ""), disableUI: true)
            
            self.businessList.removeAll()
            self.APICALL = SoleoAPI.init()
            self.APICALL?.apiKey = <#YOUR API KEY #>
            
            
            //start API GET DATA
            self.APICALL?.getDataFromPrevoiusSearch(self.searchListToDisplay[indexForSearch] , processCompleter: { (list, error) -> Void in

                
                if(error == nil){
                    print("Finally got \(list!.count)")
                    self.businessList = list!;
                }
                else
                {
                    print("We found a error")
                    EZLoadingActivity.hide(success: false, animated: true)
                    
                    print(error)
                    
                    //Display a warning, NO DATA, ERROR OCCURED.
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                        message: NSLocalizedString("ErrorGettingData", comment: "Error"), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    
                    alert.addAction(okButton)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
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
                        print(#line," We found a error first")
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

    
    //MARK: NSCoding for store data
    //Saved Searches into Disk
    func saveSearches(){
        
        let didSave = NSKeyedArchiver.archiveRootObject(searchListToDisplay, toFile: Search_type.ArchiveURL.path!)
        
        if(!didSave)
        {
            print("Error, Could not save list")
        }
        
        FirstViewDelegate?.passSearchList(searchListToDisplay)
        
    }
    
    //Load Searches from Disk
    func loadpreviousSearches() -> [Search_type]?{
    
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Search_type.ArchiveURL.path!) as? [Search_type]
    }
    

}
