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
import EZLoadingActivity

protocol RecentTableViewControllerDelegate{
    
    func passSearches(_ newList: [Search_type])
    func passSegueDisplay(_ segueToDisplay : String)
    func passFirstViewDelegate(_ delegate : FirstViewControllerDelegate)
    func passLocation(_ location : CLLocation)
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
        navigationItem.rightBarButtonItem = editButtonItem
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background_pattern")!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        saveSearches()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchListToDisplay.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! RecentTableViewCell

        // Configure the cell...
        cell.Search_name.text = searchListToDisplay[(indexPath as NSIndexPath).item].search_name
        cell.ValidTime.text = "Valid until: \(searchListToDisplay[(indexPath as NSIndexPath).item].search_time)"
        
        if searchListToDisplay[(indexPath as NSIndexPath).item].favority{
            
            cell.FavButton.image = UIImage(named: "ic_favorite_white_36pt")
        }
        else{
            cell.FavButton.image = UIImage(named: "ic_favorite_border_white_36pt")
        }
        
        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "Cellsbackground")!)

        return cell
    }
    
    
    //MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var newActions = [UITableViewRowAction]()
        
        
        let FavAction = UITableViewRowAction(style: .normal, title: (NSLocalizedString("Favorite", comment: "action"))) { (rowAction, indexPath) -> Void in
            
            print("Adding to Fav")
            let Updated = self.searchListToDisplay[(indexPath as NSIndexPath).item]
            
            if Updated.favority{
                Updated.favority = false
            }
            else{
                Updated.favority = true
            }
            
            self.searchListToDisplay[(indexPath as NSIndexPath).item] = Updated
            tableView.endEditing(true)
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        FavAction.backgroundColor = UIColor.yellow
        
        let deleteAction = UITableViewRowAction(style: .default, title: (NSLocalizedString("Delete", comment: "action"))) { (rowAction, indexPath) -> Void in
                print("Deleting")

                self.searchListToDisplay.remove(at: (indexPath as NSIndexPath).item)
                tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        
        
        newActions.append(deleteAction)
        
        newActions.append(FavAction)
        
        
        return newActions
    }

    //
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        StartSearch((indexPath as NSIndexPath).item)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  SeguesForData == "showResultsAgainCollection"{
            if segue.identifier == SeguesForData{
                
                let NavController = segue.destination as! UINavigationController
                
                let destView : ListingCollectionViewController = NavController.topViewController as!  ListingCollectionViewController
                
                print("Passing the data for collection \(self.businessList.count)")
                destView.list = self.businessList
                destView.userLocation = self.local
            }
            
        }
        else
        {
            if segue.identifier == SeguesForData{
                
                let NavController = segue.destination as! UINavigationController
                
                let destView : ListingTableViewController  = NavController.topViewController as!  ListingTableViewController
                
                print("Passing the data for table \(self.businessList.count)")
                destView.list = self.businessList
                destView.userLocation = self.local
            }
            
        }
        
    }

    
    
    //MARK: Actions
    
    @IBAction func Search_NavBar_action(_ sender: AnyObject) {
        
        
            self.tabBarController?.selectedIndex = 0;
        
    }
    
    
    //MARK: Functions DELEGATE
    func passSearches(_ newList: [Search_type]){
        
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
    
    func passSegueDisplay(_ segueToDisplay : String){
        
        if segueToDisplay == "ShowCollectionSegue"
        {
            SeguesForData = "showResultsAgainCollection"
        }
        else{
            SeguesForData = "showResultsAgainList"
        }
        
    }
    
    func passFirstViewDelegate(_ delegate: FirstViewControllerDelegate) {
        self.FirstViewDelegate = delegate
    }
    
    func passLocation(_ location : CLLocation){
        self.local = location
    }
    
    //MARK: Actions
    func StartSearch(_ indexForSearch: Int){
        if(self.connectedToNetwork())
        {
            print("Starting Search system")
            
            //Showing Loading screen
            EZLoadingActivity.show(NSLocalizedString("Loading", comment: ""), disableUI: true)
            
            self.businessList.removeAll()
            self.APICALL = SoleoAPI.init()
            self.APICALL?.apiKey = <#Your APIKEY#>
            
            
            //start API GET DATA
            self.APICALL?.getDataFromPrevoiusSearch(self.searchListToDisplay[indexForSearch] , processCompleter: { (list, error) -> Void in

                
                if(error == nil){
                    print("Finally got \(list!.count)")
                    self.businessList = list!;
                }
                else
                {
                    print("We found a error")
                    EZLoadingActivity.hide(true,animated: true)
                    
                    print(error)
                    
                    //Display a warning, NO DATA, ERROR OCCURED.
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                        message: NSLocalizedString("ErrorGettingData", comment: "Error"), preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                    
                    alert.addAction(okButton)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
            })
            
            
            DispatchQueue.global(qos: .background).async {
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
                DispatchQueue.main.async {
                    if (self.APICALL?.dataError == nil)
                    {
                        self.performSegue(withIdentifier: self.SeguesForData, sender:self)
                        EZLoadingActivity.hide(true, animated: true)
                    }
                }
            }
            
            
        }
        else
        {
            //Display a warning, NO NETWORK.
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                message: NSLocalizedString("NoNetworkError", comment: "Error"),
                preferredStyle: UIAlertControllerStyle.alert)
            
            let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                style: UIAlertActionStyle.cancel, handler: nil)
            
            
            alert.addAction(okButton)
            
            present(alert, animated: true, completion: nil)
        }

    }
    
    //MARK: Support Functions
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        //let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable)
        
        
    }

    
    //MARK: NSCoding for store data
    //Saved Searches into Disk
    func saveSearches(){
        
        let didSave = NSKeyedArchiver.archiveRootObject(searchListToDisplay, toFile: Search_type.ArchiveURL.path)
        
        if(!didSave)
        {
            print("Error, Could not save list")
        }
        
        FirstViewDelegate?.passSearchList(searchListToDisplay)
        
    }
    
    //Load Searches from Disk
    func loadpreviousSearches() -> [Search_type]?{
    
        return NSKeyedUnarchiver.unarchiveObject(withFile: Search_type.ArchiveURL.path) as? [Search_type]
    }
    

}
