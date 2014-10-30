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

class ViewController: UITableViewController, SelectionVCDelegate {

    var userPrefs : NSUserDefaults?

    @IBOutlet var keyboardPreview : UIView!
    var preview : KeyboardPreview?
    
    @IBOutlet var ThemeScheme : UILabel!
    var _themeScheme : UIBlurEffectStyle = .Dark
    
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
        
        // add keyboard preview
        preview = KeyboardPreview(frame: CGRect(x: 0, y: 0, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height))
        keyboardPreview.addSubview(preview!)
        
        
        // end editing gesture recognizer
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"endEdit"))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        userPrefs = NSUserDefaults(suiteName: "jack.com.keyboard.prefs")
        if userPrefs?.objectForKey("TRACKS_SPEED") == nil {
            userPrefs!.setBool(false, forKey: "TRACKS_SPEED")
        }
        if userPrefs?.objectForKey("THEME") == nil {
            userPrefs!.setObject("THEME_YOSEMITE", forKey: "THEME")
        }
        if userPrefs?.objectForKey("BUTTON_SHAPE") == nil {
            userPrefs!.setInteger(2, forKey: "BUTTON_SHAPE")
        }
        if userPrefs?.objectForKey("TRACKS_SPEED") == nil {
            userPrefs!.setBool(false, forKey: "TRACKS_SPEED")
        }
        if userPrefs?.objectForKey("THEME_SCHEME") == nil {
            userPrefs!.setObject("DARK", forKey: "THEME_SCHEME")
        }
        
        userPrefs!.synchronize()
        
        // initialize view with settings information correct
        ButtonShape.selectedSegmentIndex = userPrefs!.integerForKey("BUTTON_SHAPE")
        TrackSpeed.setOn( userPrefs!.boolForKey("TRACKS_SPEED"), animated: false)
        switch userPrefs!.stringForKey("THEME_SCHEME")! {
        case "LIGHT":
            ThemeScheme!.text = "Light"
        case "EXTRA_LIGHT":
            ThemeScheme!.text = "Extra Light"
        default:
            ThemeScheme!.text = "Dark"
        }
        
        
        buildPreview()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var str = sender as String
        if segue.identifier? == "SEGUE_MAKE_SELECTION" {
            var vc = segue.destinationViewController as SelectionVC
            vc.setupVC(["Extra Light", "Light", "Dark"], delegate: self)
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
        var theme = userPrefs?.stringForKey("THEME")
        var btnShape = userPrefs?.integerForKey("BUTTON_SHAPE")
        var blurStyle : UIBlurEffectStyle = .Dark
        
        switch ThemeScheme.text! {
        case "LIGHT":
            blurStyle = .Light
        case "EXTRA_LIGHT":
            blurStyle = .ExtraLight
        default:
            blurStyle = .Dark
        }
        
        preview!.buildWith(blurStyle, theme: theme!, buttonShape: btnShape!)
    }
    
    //
    //                UITABLEVIEW DELEGATE AND DATASOURCE METHODS
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("SEGUE_MAKE_SELECTION", sender: "")
    }

    //
    //                  SELECTIONVCDELEGATE METHODS
    //
     func didSelect(option: String, forOption: String) {
//        switch forOption.uppercaseString {
//        case "THEME":
//    
//        }
        println("DIDSELECT")
    }

}

