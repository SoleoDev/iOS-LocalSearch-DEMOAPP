//
//  LeftViewController.swift
//  Soleo_Tab_Template
//
//  Created by Victor Jimenez Delgado on 1/27/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import Soleo_Local_Search_API_Framework

protocol LeftViewControllerDelegate{
    
    func passToLeft(name: String, data: Any)
    
}

class LeftViewController: UIViewController, LeftViewControllerDelegate {
    
    //MARK: Fields
    
    var FirstViewdelegate : FirstViewControllerDelegate?
    
    @IBOutlet weak var CollectionSwitch: UISwitch!
    
    @IBOutlet weak var Facebook_button: UIImageView!
    
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    var FilterType : Business_Sort_Type = Business_Sort_Type.both
    
    var ViewType : [String: String] = ["CollectionViewType":"List"]
    
    var location_city : String?
    var location_state : String?
    var location_auto : Bool?
    
    var radius_toSearch : String?

    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let FirstView = ((appDelegate.drawerContainer?.centerViewController as! UITabBarController).viewControllers![0] as! UINavigationController).topViewController as! FirstViewController
        
        self.FirstViewdelegate = FirstView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        //Send the data to the center View
        passDataForward(ViewType.keys.first!, dataToSend: ViewType.values.first!)
        
        if ( location_auto != nil  && !location_auto!){
            if location_city != nil{
                passDataForward("NewCity", dataToSend: location_city!)
            }
            
            if location_state != nil{
                passDataForward("NewState", dataToSend: location_state!)
            }
            
        }
        
         passDataForward("FilterType", dataToSend: FilterType.rawValue)
        
        if( radius_toSearch != nil)
        {
            passDataForward("Radius", dataToSend: radius_toSearch!)
        }

        
    }
    
    //MARK: DELEGATION
    func passDataForward(dataType: String, dataToSend: AnyObject)
    {
        FirstViewdelegate?.passData(dataType, data: dataToSend)
    }
    
    func passToLeft(name: String, data: Any) {
        
        //GET THE CODE FORM THE RIGHT VIEW CONTROLLER
        
        if name == "Location"
        {
            let dataConverted = data as! AnyObject
            location_auto = dataConverted.valueForKey("AutoLocal")?.boolValue
            location_city = dataConverted.valueForKey("city") as? String
            location_state = dataConverted.valueForKey("state") as? String
        }
        
        if name == "FilterSelection"
        {
            FilterType = data as! Business_Sort_Type
        }
        
        if name == "NewLocation"
        {
            let dataConverted = data as! AnyObject
            location_auto = false
            location_city = dataConverted.valueForKey("City") as? String
            location_state = dataConverted.valueForKey("State") as? String
        }
        
        if name == "Radius"
        {
            radius_toSearch = data as? String
        }
        
    }
    
    @IBAction func SettingsSelection(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("ShowSettingMenu", sender:self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: Actionn
    @IBAction func SwitchAction(sender: UISwitch) {
    
        if sender.on{
            ViewType = ["CollectionViewType":"Collection"]
        }
        else{
            ViewType = ["CollectionViewType":"List"]
        }
        
        
    }
    
    
    
    //MARK: Segue Overrides
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocations"{
         let destination = segue.destinationViewController as! RightViewController
            destination.LocationAutomatic = self.location_auto
            destination.City = self.location_city
            destination.State = self.location_state
            destination.LeftViewDelegate = self
            destination.FilterType = self.FilterType
            
        }
        
    }
    
    

}
