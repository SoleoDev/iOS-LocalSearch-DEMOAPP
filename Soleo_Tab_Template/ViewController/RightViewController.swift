//
//  RightViewController.swift
//  Soleo_Tab_Template
//
//  Created by Victor Jimenez Delgado on 1/27/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit
import CoreLocation
import Soleo_Local_Search_API_Framework



class RightViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var LeftViewDelegate : LeftViewControllerDelegate?

    //MARK: Fields
    @IBOutlet weak var Current_Location: UILabel!
    @IBOutlet weak var image_Current_location: UIImageView!
    
    @IBOutlet weak var FilterImage: UIImageView!
    
    @IBOutlet weak var FiltersPickerView: UIPickerView!
    
    var Location : CLLocation?
    
    var LocationAutomatic : Bool?
    
    var FilterType : Business_Sort_Type?
    
    var City : String?
    
    var State : String?
    
    var NewLocation : Bool = false
    
    var Radius: String?
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    let pickerData_Sort = ["Both",
        "Distance", "Ad Revenue", "Name, Category, Distance"]
    
    let pickerData_Radius = ["1 mi",
        "5 mi", "10 mi", "25 mi", "50 mi"]
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FiltersPickerView.delegate = self
        FiltersPickerView.dataSource = self
        NewLocation = false;
        
        if ((LocationAutomatic) != nil) {
            image_Current_location.image = UIImage(named: "GPS")
            Current_Location.text = "\(City!), \(State!)"
        }
        else{
            image_Current_location.image = UIImage(named: "GPS-off")
            Current_Location.text = NSLocalizedString("LocationNotSetUI", comment: "")
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         //Send the data to the Left View
        //passDataTotheLeft()
        
    }

    
    func passDataTotheLeft()
    {
        if FilterType != nil{
            LeftViewDelegate?.passToLeft("FilterSelection", data: FilterType!)
        }
        
        if NewLocation
        {
            let dataToSend = ["City": "\(City!)","State":"\(State!)"]
            LeftViewDelegate?.passToLeft("NewLocation", data: dataToSend)
        }
        
        if (Radius != nil)
        {
            LeftViewDelegate?.passToLeft("Radius", data: Radius)
        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Actions
    
    
    //MARK: PickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ _pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int{
            
            if _pickerView.tag == 0{
            return pickerData_Sort.count
            }
            else{
                return pickerData_Radius.count
            }
    }
    
    //MARK: PickerDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return pickerData_Sort[row]
        }
        else{
           return pickerData_Radius[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0{
            switch pickerData_Sort[row]
            {
                case "Ad Revenue":
                    FilterType = Business_Sort_Type.value
                    break
                
                case "Distance":
                    FilterType = Business_Sort_Type.distance
                    break
                
                case "Both":
                    FilterType = Business_Sort_Type.both
                    break
                
                case "Name, Category, Distance":
                    FilterType = Business_Sort_Type.nameCategoryDistance
                
                default:
                    FilterType = Business_Sort_Type.both

            }
        }
        else{
            
            Radius = pickerData_Radius[row]
            
            Radius!.removeSubrange(pickerData_Radius[row].characters.index(pickerData_Radius[row].endIndex, offsetBy: -3)..<pickerData_Radius[row].endIndex)
            
        }
        
        passDataTotheLeft()
    }
    
    //MARK Unwind from Location selection
    @IBAction func saveNewLocationDetail(_ segue:UIStoryboardSegue) {
        
        let MasterView = segue.source as UIViewController
        
        City = (MasterView.view.subviews[MasterView.view.subviews.index(where: {$0.tag == 1})!] as! UITextField).text
        
        State = (MasterView.view.subviews[MasterView.view.subviews.index(where: {$0.tag == 2})!] as! UITextField).text
        
        NewLocation = true
        
        Current_Location.text = "\(City!), \(State!)"
        image_Current_location.image = UIImage(named: "GPS-off")
        
        passDataTotheLeft()
        
    }
    
}
