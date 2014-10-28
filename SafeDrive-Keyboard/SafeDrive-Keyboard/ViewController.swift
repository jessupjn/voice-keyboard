//
//  ViewController.swift
//  SafeDrive-Keyboard
//
//  Created by Jack on 10/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate{
    func BackgroundColorChanged();
    func ForegroundColorChanged();
}

class ViewController: UITableViewController {

    var userPrefs : NSUserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"endEdit"))
        
        userPrefs = NSUserDefaults(suiteName: "jack.com.keyboard.prefs")
        
        if NSBundle.mainBundle().bundleIdentifier! == "com.JacksonJessup.SafeD-Free" {
            
        } else {
            
        }
    }

    func endEdit(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //
    //                UITABLEVIEW DELEGATE AND DATASOURCE METHODS
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            
        } else if indexPath.row == 1 {
            
        } else if indexPath.row == 2 {
            
        } else if indexPath.row == 3 {
            
        } else if indexPath.row == 4 {
            
        }
    }

}

