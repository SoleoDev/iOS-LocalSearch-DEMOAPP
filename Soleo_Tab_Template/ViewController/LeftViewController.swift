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
    
    func passToLeft(_ name: String, data: Any)
    
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let FirstView = ((appDelegate.drawerContainer?.centerViewController as! UITabBarController).viewControllers![0] as! UINavigationController).topViewController as! FirstViewController
        
        self.FirstViewdelegate = FirstView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Send the data to the center View
        passDataForward(ViewType.keys.first!, dataToSend: ViewType.values.first! as AnyObject)
        
        if ( location_auto != nil  && !location_auto!){
            if location_city != nil{
                passDataForward("NewCity", dataToSend: location_city! as AnyObject)
            }
            
            if location_state != nil{
                passDataForward("NewState", dataToSend: location_state! as AnyObject)
            }
            
        }
        
         passDataForward("FilterType", dataToSend: FilterType.rawValue)
        
        if( radius_toSearch != nil)
        {
            passDataForward("Radius", dataToSend: radius_toSearch! as AnyObject)
        }

        
    }
    
    //MARK: DELEGATION
    func passDataForward(_ dataType: String, dataToSend: AnyObject)
    {
        FirstViewdelegate?.passData(dataType, data: dataToSend)
    }
    
    func passToLeft(_ name: String, data: Any) {
        
        //GET THE CODE FORM THE RIGHT VIEW CONTROLLER
        
        if name == "Location"
        {
            let dataConverted = data as AnyObject
            location_auto = (dataConverted.value(forKey: "AutoLocal") as AnyObject).boolValue
            location_city = dataConverted.value(forKey: "city") as? String
            location_state = dataConverted.value(forKey: "state") as? String
        }
        
        if name == "FilterSelection"
        {
            FilterType = data as! Business_Sort_Type
        }
        
        if name == "NewLocation"
        {
            let dataConverted = data as AnyObject
            location_auto = false
            location_city = dataConverted.value(forKey: "City") as? String
            location_state = dataConverted.value(forKey: "State") as? String
        }
        
        if name == "Radius"
        {
            radius_toSearch = data as? String
        }
        
    }
    
    @IBAction func SettingsSelection(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "ShowSettingMenu", sender:self)
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
    @IBAction func SwitchAction(_ sender: UISwitch) {
    
        if sender.isOn{
            ViewType = ["CollectionViewType":"Collection"]
        }
        else{
            ViewType = ["CollectionViewType":"List"]
        }
        
        
    }
    
    
    
    //MARK: Segue Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocations"{
         let destination = segue.destination as! RightViewController
            destination.LocationAutomatic = self.location_auto
            destination.City = self.location_city
            destination.State = self.location_state
            destination.LeftViewDelegate = self
            destination.FilterType = self.FilterType
            
        }
        
    }
    
    

}
