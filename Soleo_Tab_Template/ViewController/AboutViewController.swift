//
//  AboutViewController.swift
//  SoLocal API
//
//  Created by Victor Jimenez Delgado on 3/3/16.
//  Copyright © 2016 Victor Jimenez Delgado. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    //MARK: Field

    @IBOutlet weak var CopyrightField: UILabel!
    
    @IBOutlet weak var LicenseTextView: UITextView!
    
    let Licenses = ["alamofire",
    "async",
    "ezloading",
    "mmdrawercontroller",
    "swiftyjson",
    "bgtableviewrowactionwithimage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        CopyrightField.text = NSLocalizedString("Copyright", comment: "Copyright")
        
        LicenseTextView.text = (NSLocalizedString("External_Project", comment: "About"))
        
        for name in Licenses{
            
            if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil)
            {
                do {
                    LicenseTextView.text.appendContentsOf(" \(name.capitalizedStringWithLocale(nil)) \n")
                    LicenseTextView.text.appendContentsOf(try String(contentsOfFile:path, encoding: NSUTF8StringEncoding))
                    LicenseTextView.text.appendContentsOf("\n")
                } catch _ as NSError {
                    print ("Got a error reading the file")
                }
            }
            else {
                print("Error Finding File")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
