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

    @IBOutlet var keyboardPreview : UIView!
    var preview : KeyboardPreview?
    
    @IBOutlet var TrackSpeed : UISwitch!
    @IBAction func TrackSpeedToggle(sender : UISwitch){
        userPrefs?.setBool(sender.on, forKey: "TRACKS_SPEED")
        userPrefs?.synchronize()
        buildPreview()
    }
    
    @IBOutlet var ButtonShape : UISegmentedControl!
    @IBAction func ButtonShapeToggle(sender : UISegmentedControl){
        userPrefs?.setInteger(sender.selectedSegmentIndex, forKey: "BUTTON_SHAPE")
        userPrefs?.synchronize()
        buildPreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        preview = KeyboardPreview(frame: CGRect(x: 0, y: 0, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height))
        keyboardPreview.addSubview(preview!)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"endEdit"))
        
        userPrefs = NSUserDefaults(suiteName: "jack.com.keyboard.prefs")
        if userPrefs!.objectForKey("TRACKS_SPEED") == nil {
            userPrefs!.setBool(false, forKey: "TRACKS_SPEED")
            userPrefs!.setObject("THEME_YOSEMITE", forKey: "THEME")
            userPrefs!.setInteger(2, forKey: "BUTTON_SHAPE")
            userPrefs!.synchronize()
            
            ButtonShape.selectedSegmentIndex = userPrefs!.integerForKey("BUTTON_SHAPE")
            TrackSpeed.setOn( userPrefs!.boolForKey("TRACKS_SPEED"), animated: false)
            
        }
        
        buildPreview()
        
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
    
    private func buildPreview(){
        var theme : String = userPrefs!.stringForKey("THEME")!
        var btnShape = userPrefs?.integerForKey("BUTTON_SHAPE")
        preview!.buildWith(.Dark, theme: theme, buttonShape: btnShape!)
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

