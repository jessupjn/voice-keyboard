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
    @IBOutlet var Theme : UILabel!
    @IBOutlet var ButtonShape : UILabel!
    @IBOutlet var TrackSpeed : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPrefs = NSUserDefaults(suiteName: "jack.com.keyboard.prefs")

        self.tableView.delaysContentTouches = false
        self.tableView.allowsSelection = true
        self.tableView.tableHeaderView = buildHeader()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "Back";
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "SafeD Keyboard"
        
        if userPrefs?.objectForKey("THEME") == nil {
            userPrefs!.setObject("THEME_YOSEMITE", forKey: "THEME")
        }
        if userPrefs?.objectForKey("BUTTON_SHAPE") == nil {
            userPrefs!.setInteger(2, forKey: "BUTTON_SHAPE")
        }
        if userPrefs?.objectForKey("TRACKS_SPEED") == nil {
            userPrefs!.setObject("Off", forKey:"TRACKS_SPEED")
        }
        if userPrefs?.objectForKey("THEME_SCHEME") == nil {
            userPrefs!.setObject("DARK", forKey: "THEME_SCHEME")
        }
        
        userPrefs!.synchronize()

        TrackSpeed.text = userPrefs!.stringForKey("TRACKS_SPEED")!.uppercaseString.stringByReplacingOccurrencesOfString("_", withString: " ", options: .LiteralSearch, range: nil)
        
        switch userPrefs!.stringForKey("THEME")!.stringByReplacingOccurrencesOfString("THEME_", withString: "",  options: .LiteralSearch, range: nil) {
        case "YOSEMITE": Theme!.text = "Yosemite"
        case "MAVERICK": Theme!.text = "Maverick"
        default: Theme!.text = "MountainLion"
        }
        
        switch userPrefs!.stringForKey("THEME_SCHEME")! {
        case "LIGHT":
            ThemeScheme!.text = "Light"
        case "EXTRA_LIGHT":
            ThemeScheme!.text = "Extra Light"
        default:
            ThemeScheme!.text = "Dark"
        }
        
        switch userPrefs!.integerForKey("BUTTON_SHAPE") {
        case 0:
            ButtonShape.text = "Custom1"
        case 1:
            ButtonShape.text = "Custom2"
        case 2:
            ButtonShape.text = "Square"
        default:
            ButtonShape.text = "Rounded"
        }
        
        buildPreview()

        
    }

    private func buildHeader() -> UIView {
        var viw = UIView()
        viw.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height / 2.5)
        viw.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        var lbl = UILabel()
        lbl.text = "Preview"
        lbl.sizeToFit()
        lbl.center = viw.center
        lbl.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        lbl.frame = CGRect(x: lbl.frame.origin.x, y: viw.frame.height - lbl.frame.height - 8, width: lbl.frame.width, height: lbl.frame.height)
        viw.addSubview(lbl)
        
        keyboardPreview = UIView(frame: CGRect(x: 0, y: 0, width: viw.frame.width*335/375, height: (viw.frame.width*335/375)*188/335))
        keyboardPreview.center = viw.center
        keyboardPreview.frame = CGRect(x: keyboardPreview.frame.origin.x, y: lbl.frame.origin.y - keyboardPreview.frame.height - 6, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height)
        viw.addSubview(keyboardPreview)
        
        preview = KeyboardPreview(frame: CGRect(x: 0, y: 0, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height))
        keyboardPreview.addSubview(preview!)
        
        return viw
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier? == "SEGUE_MAKE_SELECTION" {
            var str = sender as String
            var vc = segue.destinationViewController as SelectionVC
            
            switch str {
            case "TRACKS_SPEED":
                vc.setupVC(["TRACKS_SPEED"], delegate: self)
            case "THEME":
                vc.setupVC(["Yosemite", "Maverick", "MountainLion"], delegate: self)
            case "BUTTON_SHAPE":
                vc.setupVC(["Custom1", "Custom2", "Square", "Rounded"], delegate: self)
            default:
                vc.setupVC(["Extra Light", "Light", "Dark"], delegate: self)
            }
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
        
        switch userPrefs!.stringForKey("THEME_SCHEME")! {
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
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var viw = UIView()
        viw.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height / 2.5)
        viw.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        var lbl = UILabel()
        lbl.text = "Preview"
        lbl.sizeToFit()
        lbl.center = viw.center
        lbl.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        lbl.frame = CGRect(x: lbl.frame.origin.x, y: viw.frame.height - lbl.frame.height - 8, width: lbl.frame.width, height: lbl.frame.height)
        viw.addSubview(lbl)
        
        keyboardPreview = UIView(frame: CGRect(x: 0, y: 0, width: viw.frame.width*335/375, height: (viw.frame.width*335/375)*188/335))
        keyboardPreview.center = viw.center
        keyboardPreview.frame = CGRect(x: keyboardPreview.frame.origin.x, y: lbl.frame.origin.y - keyboardPreview.frame.height - 6, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height)
        viw.addSubview(keyboardPreview)

        preview = KeyboardPreview(frame: CGRect(x: 0, y: 0, width: keyboardPreview.frame.width, height: keyboardPreview.frame.height))
        keyboardPreview.addSubview(preview!)
        buildPreview()

        return viw
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var id = tableView.cellForRowAtIndexPath(indexPath)!.reuseIdentifier
        if id=="test"{ return }
        
        var keyword : String
        switch id! {
        case "safedmode":
            keyword = "TRACKS_SPEED"
        case "backgroundtheme":
            keyword = "THEME"
        case "buttonshape":
            keyword = "BUTTON_SHAPE"
        case "language":
            keyword = "LANGUAGE"
            UIAlertView(title: "Oops", message: "More languages are being added", delegate: nil, cancelButtonTitle: "Okay").show()
            return
        default:
            keyword = "THEME_SCHEME"
        }
        
        self.performSegueWithIdentifier("SEGUE_MAKE_SELECTION", sender: keyword)
    }
    
    
    
    
    
    //
    //                  SELECTIONVCDELEGATE METHODS
    //
     func didSelect(option: String, forOption: String) {
        
        var _option : AnyObject = option.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil)
        
        switch forOption.uppercaseString {
            
        case "BUTTON_SHAPE":
            switch _option as String {
            case "CUSTOM1": _option = 0
            case "CUSTOM2": _option = 1
            case "SQUARE": _option = 2
            default: _option = 3
            }
            
        case "THEME":
            _option = "THEME_" + (_option as String)
            
        default:
            println("DEFAULT")
            
        }
        
        userPrefs!.setObject(_option, forKey: forOption)
        userPrefs!.synchronize()
        buildPreview()
    }

}

