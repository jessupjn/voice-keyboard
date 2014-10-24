//
//  KeyboardViewController.swift
//  SafeD
//
//  Created by Jack on 10/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import UIKit
import CoreLocation

enum ShiftStates : String {
    case None = "NONE", Shift = "SHIFT", Caps = "CAPS", Number1 = "NUMBER1", Number2 = "NUMBER2"
    static let allValues = [None, Shift, Caps]
}

class KeyboardViewController: UIInputViewController, CLLocationManagerDelegate, UIAlertViewDelegate {

    @IBOutlet var nextKeyboardButton: UIButton!

    // options
    let userDefaults : NSUserDefaults? = NSUserDefaults()//NSUserDefaults(suiteName: "")

    var TRACKS_SPEED : Bool = true
    var BUTTON_SHAPE : Int = 1
    var SPEED_LIMIT : Int = 600
    var foreGround : UIColor = UIColor(red:202/255.0, green:31/255.0, blue:0/255.0, alpha: 1)
    var backGround : UIColor = UIColor.lightTextColor()
    var MIC_OPEN : Bool = false
    
    // variables
    let backgroundView : UIView = UIView()
    var locManager : CLLocationManager = CLLocationManager()
    var screenWidth : CGFloat = 320
    var buttonWidth : CGFloat = 45
    var tagNum : Int = 1000;
    var shiftState = ShiftStates.None
    var goToCaps = false
    var addPeriod = false
    var shiftButton : UIButton?
    var lastChar = " "
    
    // keys
    var lowerCase : [String] = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "SH", "z", "x", "c", "v", "b", "n", "m", "⌫"]
    var upperCase : [String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    var number1 : [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "/", ":", ";", "(", ")", "$", "&", "@", "\"", "#+=", ".", ",", "?", "!", "'", "⌫"]
    var number2 : [String] = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "=", "_", "\\", "|", "~", "<", ">", "€", "£", "¥", "", "123", ".", ",", "?", "!", "'", "⌫"]
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = backGround
        
//        if isOpenAccessGranted() {
//            setCustomOptions()
//        }
    }
    
    func getRow(num : Int) -> [String] {
        var slice : [String] = []
        if shiftState == .Caps || shiftState == .None || shiftState == .Shift {
            if num == 0 {
                slice = Array(upperCase[0...9])
            } else if num == 1 {
                slice = Array(upperCase[10...18])
            } else if num == 2 {
                slice = Array(upperCase[19...upperCase.count-1])
            } else {
                slice = ["123", "NEXT", "MIC", "space", "return"]
            }
        } else if shiftState == ShiftStates.Number1 {
            if num == 0 {
                slice = Array(number1[0...9])
            } else if num == 1 {
                slice = Array(number1[10...19])
            } else if num == 2 {
                slice = Array(number1[20...number1.count-1])
            } else {
                slice = ["ABC", "NEXT", "MIC", "space", "return"]
            }
        } else {
            if num == 0 {
                slice = Array(number2[0...9])
            } else if num == 1 {
                slice = Array(number2[10...19])
            } else if num == 2 {
                slice = Array(number2[20...number2.count-1])
            } else {
                slice = ["ABC", "NEXT", "MIC", "space", "return"]
            }
        }
        return slice
    }
    
    func buildKeyboard()
    {
        println("buildKeyboard")
        
        // REMOVE OLD MATERIALS
        if self.view.subviews.count > 0 {
            for view in self.view.subviews
            {
                view.removeFromSuperview()
            }
        }
        
        tagNum = 1000
        
        // BUILDING VARIOUS BUTTONS USED FOR THE KEYBOARD
        let buttonTitles1 = getRow(0)
        let buttonTitles2 = getRow(1)
        let buttonTitles3 = getRow(2)
        let buttonTitles4 = getRow(3)
        
        screenWidth = UIScreen.mainScreen().bounds.size.width
        buttonWidth = screenWidth / 11
        
        var row1 = createRow(buttonTitles1, width: screenWidth)
        var row2 = createRow(buttonTitles2, width: screenWidth-buttonWidth)
        var row3 = createRow(buttonTitles3, width: screenWidth-buttonWidth)
        var row4 = createRow(buttonTitles4, width: screenWidth)
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addConstraintsToInputView(self.view, rowViews: [row1, row2, row3, row4])
        
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.buttonBorders(self.view)
        })
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        println(touch.locationInView(self.view))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var proxy = textDocumentProxy as UITextDocumentProxy
        if proxy.autocapitalizationType != .None {
            shiftState = .Shift
        }
        
        buildKeyboard()

//        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("checkLoc"), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locManager.distanceFilter = kCLDistanceFilterNone
        locManager.startUpdatingLocation()
    }
    
    func setCustomOptions() {
        if userDefaults!.objectForKey("TRACKS_SPEED") != nil {
            TRACKS_SPEED = userDefaults!.boolForKey("TRACKS_SPEED")
            if TRACKS_SPEED {
                locManager = CLLocationManager()
                locManager.delegate = self
                locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                locManager.distanceFilter = kCLDistanceFilterNone
                locManager.startUpdatingLocation()
            }
        }
        if userDefaults!.objectForKey("BUTTON_SHAPE") != nil {
            BUTTON_SHAPE = userDefaults!.integerForKey("BUTTON_SHAPE")
        }
        if userDefaults!.objectForKey("FOREGROUND_COLOR") != nil {
            foreGround = userDefaults!.objectForKey("FOREGROUND_COLOR") as UIColor
        }
        if userDefaults!.objectForKey("BACKGROUND_COLOR") != nil {
            backGround = userDefaults!.objectForKey("BACKGROUND_COLOR") as UIColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.

    }
    
    
    
    
    
    //
    //                      MY CUSTOM FUNCTIONS
    //
    func createRow(titles:[NSString], width:CGFloat)->UIView
    {
        var buttons = [UIButton]()
        var keyboardRowView = UIView(frame: CGRectMake(0,0, width, 200))
        for buttonTitle in titles{
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        
        return keyboardRowView
    }
    
    func createButtonWithTitle(title: String) -> UIButton {
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, buttonWidth, 35)
        button.sizeToFit()

        button.titleLabel!.font = UIFont.systemFontOfSize(18)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = .clearColor()
        button.setTitleColor(foreGround, forState: .Normal)
        button.tag = tagNum++
        button.clipsToBounds = true
        
        if title == "MIC" || title == "NEXT" {
            button.setBackgroundImage(UIImage(named:title), forState:.Normal)
            button.contentMode = .ScaleAspectFit
            button.setTitle(title, forState:.Reserved)

        } else {
            button.setTitle(title, forState: .Normal)
            if title.uppercaseString == "SH" {
                shiftButton = button
            }
        }
        
        if countElements(title) > 2 {
            button.titleLabel!.font = UIFont.systemFontOfSize(15)
        }
        
        button.contentVerticalAlignment = .Center
        button.contentHorizontalAlignment = .Center
        button.setTitleColor(backGround, forState: UIControlState.Highlighted)
        button.tintColor = foreGround
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "submitString:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    func buttonHighlight(sender:AnyObject?){
//        var this : Bool = sender as Bool
//
    }
    
    var typedString = ""
    func submitString(sender: AnyObject?){
        var viw = sender!.viewWithTag(43)?
        if viw != nil {
           viw?.removeFromSuperview()
        }
        
        if countElements(typedString) > 0 {
            var proxy = textDocumentProxy as UITextDocumentProxy
            proxy.insertText( typedString )
            typedString = ""
        }
        
    }
    
    func didTapButton(sender: AnyObject?) {
        
        submitString(sender)
        
        var rect = CGRectMake(3, 3, sender!.frame.width-6, sender!.frame.height-6)
        var viw = UIView(frame: rect)
        viw.backgroundColor = UIColor(white: 0, alpha: 0.2)
        viw.tag = 43
        sender?.addSubview(viw)
        
        let button = sender as UIButton
        var title : String? = button.titleForState( .Normal )?
        var proxy = textDocumentProxy as UITextDocumentProxy

        if title == nil {
            title = button.titleForState( .Reserved )?
        }
        
        switch(title!.uppercaseString){
            case "⌫":
                proxy.deleteBackward()
            case "ABC":
                shiftState = .None
                buildKeyboard()
            case "#+=":
                shiftState = .Number2
                buildKeyboard()
            case "123":
                shiftState = .Number1
                buildKeyboard()
            case "MIC":
                showMic()
            case "RETURN":
                showMic()
            case "SH":
                if shiftState == .None {
                    shiftState = .Shift
                    goToCaps = true
                    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.17 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        self.goToCaps = false
                    })
                    button.setTitleColor(UIColor.blueColor(), forState:.Normal)
                } else if shiftState == .Caps {
                    shiftState = .None
                    button.setTitleColor( UIColor.blackColor(), forState: .Normal)
                } else {
                    if goToCaps {
                        shiftState = .Caps
                        button.setTitleColor(UIColor.redColor(), forState:.Normal)
                    } else {
                        shiftState = .None
                        button.setTitleColor(UIColor.blackColor(), forState:.Normal)
                    }
                }
            case "NEXT":
                self.advanceToNextInputMode()
            case "SPACE":
                if addPeriod {
                    if countElements(typedString) > 0 {
//                        typedString.insert(".", atIndex: countElements(typedString)-2 )
                    } else {
                        proxy.deleteBackward()
                        proxy.insertText(". ")
                    }
                    
                    title = "." // for autocapitalization
                    addPeriod = false
                }
                else { typedString += " " }
                if(lastChar != " ") {
                    addPeriod = true
                }
                lastChar = " "
                
                // keyboard back to regular
                shiftState = .None
                buildKeyboard()
                
                dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.22 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.addPeriod = false
                    self.lastChar = ""
                })
            
                // autocapitalization
                if (checkForAutocaps()) && shiftState == ShiftStates.None {
                    shiftButton?.sendActionsForControlEvents(.TouchUpInside)
                }
            default:
                lastChar = title!
                if shiftState == ShiftStates.None {
                    typedString += lowerCase[button.tag-1000]
                } else if shiftState == ShiftStates.Shift {
                    typedString += upperCase[button.tag-1000]
                    shiftState = ShiftStates.None
                    button.setTitleColor( UIColor.blackColor(), forState: .Normal)
                } else if shiftState == ShiftStates.Caps {
                    typedString += upperCase[button.tag-1000]
                } else if shiftState == ShiftStates.Number1 {
                    typedString += number1[button.tag-1000]
                } else if shiftState == ShiftStates.Number2 {
                    typedString += number2[button.tag-1000]
                }
            
        }

    }
    
    func checkForAutocaps() -> Bool {
        var proxy = textDocumentProxy as UITextDocumentProxy
        var str : NSString = proxy.documentContextBeforeInput
        if proxy.autocapitalizationType? == .None {
            return false
        } else if (/*proxy.autocapitalizationType? == .AllCharacters ||*/ str.length == 0) {
            return true
        }

        while str.substringWithRange(NSRange(location: str.length - 1, length: 1)) == " " {
//            if proxy.autocapitalizationType? == .Words {
//                return true
//            }
            str = (str as NSString).substringToIndex(str.length - 1)
        }
        if str.substringWithRange(NSRange(location: str.length - 1, length: 1)) == "." {
//            if proxy.autocapitalizationType? == .Sentences {
                return true
//            }
        }
        return false
    }
    //
    //                      CREATE BUTTON SHAPE
    //
    func buttonBorders(view: UIView)
    {
        println(view.tag)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)))
        if view.isKindOfClass(UIButton) && view.tag >= 1000 {
            if BUTTON_SHAPE == 0 {
//                if (view as UIButton).titleLabel?.text?.lowercaseString == "return" {
//                    dispatch_after(time, dispatch_get_main_queue(), {
//                        self.roundCorners(view as UIButton)
//                    })
//                } else {
                    self.roundCorners(view as UIButton)
//                }
            }
            else {
                (view as UIButton).layer.borderColor = foreGround.CGColor
                (view as UIButton).layer.borderWidth = 1
                (view as UIButton).layer.cornerRadius = 5
            }
            return
        }
        for viw in view.subviews {
            buttonBorders(viw as UIView)
        }
    }
    func roundCorners(button: UIView)
    {

        var bounds : CGRect = button.frame
        var bezierPath : UIBezierPath = UIBezierPath()
        bezierPath.lineJoinStyle = kCGLineJoinRound
        bezierPath.moveToPoint( CGPointMake(2,bounds.height/2) )
        bezierPath.addLineToPoint( CGPointMake(2,18) )
        bezierPath.addLineToPoint( CGPointMake(17,3) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-5,3) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-2,6) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-2,bounds.height-18) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-17,bounds.height-3) )
        bezierPath.addLineToPoint( CGPointMake(5,bounds.height-3) )
        bezierPath.addLineToPoint( CGPointMake(2,bounds.height-6) )
        bezierPath.addLineToPoint( CGPointMake(2,bounds.height/2) )
        bezierPath.closePath()
    
        //apply path to shapelayer
        var pathLayer : CAShapeLayer = CAShapeLayer()
        pathLayer.path = bezierPath.CGPath
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.strokeColor = foreGround.CGColor
        pathLayer.frame=CGRectMake(0, 0,bounds.width,bounds.height)
//        pathLayer.masksToBounds = true
        
        //add shape layer to view's layer
//        button.layer.mask = pathLayer
        button.layer.addSublayer(pathLayer)
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        if(buttons.count >= 7)
        {
            var _topConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 2)
            var _bottomConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -2)
            _topConstraint.priority = 1000
            _bottomConstraint.priority = 1000
            mainView.addConstraints([_bottomConstraint, _topConstraint])
        }
        
        if(buttons.count == 9)
        {
            var _middleConstraint = NSLayoutConstraint(item: buttons[4], attribute:.CenterX, relatedBy: .Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            mainView.addConstraint(_middleConstraint)
            var widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/10.7)
            mainView.addConstraints([widthConstraint])
            
            var l = 3, h = 5;
            let dist : CGFloat = UIScreen.mainScreen().bounds.width / 125
            while l >= 0 {
                
                var LwidthConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)
                var HwidthConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)

                var LheightConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                var HheightConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                
                var LcenterY = NSLayoutConstraint(item: buttons[l], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var HcenterY = NSLayoutConstraint(item: buttons[h], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                
                var LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -2)
                var HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant: 2)

                if(buttons[0].titleLabel?.text == "SH"){
                    if(l == 0)
                    {
                        LwidthConstraint.constant = buttons[4].frame.width * 0.6
                        HwidthConstraint.constant = buttons[4].frame.width * 0.6
                    }
                }
                
                mainView.addConstraints([LwidthConstraint, HwidthConstraint])
                mainView.addConstraints([LheightConstraint, HheightConstraint])
                mainView.addConstraints([LcenterY, HcenterY])
                mainView.addConstraints([LdistRight, HdistLeft])

                l--
                h++
            }

            return
        }
        else if buttons.count == 10
        {
            var widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/10.7)
            mainView.addConstraints([widthConstraint])
            
            var l = 4, h = 5
            let dist : CGFloat = UIScreen.mainScreen().bounds.width / 140
            while l >= 0{
                var LcenterY = NSLayoutConstraint(item: buttons[l], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var HcenterY = NSLayoutConstraint(item: buttons[h], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var LheightConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                var HheightConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                
                var LwidthConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)
                var HwidthConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)
                
                var LdistRight : NSLayoutConstraint, HdistLeft : NSLayoutConstraint;
                if l == 4{
                    
                    LdistRight = NSLayoutConstraint(item: buttons[l], attribute:.Right, relatedBy:.Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: -1)
                    HdistLeft = NSLayoutConstraint(item: buttons[h], attribute:.Left, relatedBy:.Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: 1)
                } else {
                    LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -2)
                    HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant:2)
                }
                
                mainView.addConstraints([LcenterY, HcenterY])
                mainView.addConstraints([LheightConstraint, HheightConstraint])
                mainView.addConstraints([LwidthConstraint, HwidthConstraint])
                mainView.addConstraints([LdistRight, HdistLeft])
//                
//                if buttons[l].tag == 1000 {
//                    buttonWidth = buttons[l].frame.size.width
//                }
                l--
                h++
            }
            return
        }
        else if buttons.count == 7 {
            var _middleConstraint = NSLayoutConstraint(item: buttons[3], attribute:.CenterX, relatedBy: .Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            var _topConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 10)
            var _botConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -2)
            var _widthConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/11 + buttons[3].frame.width*0.4)

            mainView.addConstraints([_middleConstraint, _widthConstraint])

            
            var l = 2, h = 4;
            let dist : CGFloat = UIScreen.mainScreen().bounds.width / 125
            while l >= 0 {
                var LwidthConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/11 + buttons[3].frame.width*0.4)
                var HwidthConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/11 + buttons[3].frame.width*0.4)

                var LheightConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)
                var HheightConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)

                var LcenterY = NSLayoutConstraint(item: buttons[l], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var HcenterY = NSLayoutConstraint(item: buttons[h], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)

                var LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -2)
                var HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant: 2)

                if l == 0 {
                    LdistRight.constant -= 4
                    HdistLeft.constant += 4
                    LwidthConstraint.constant = screenWidth/10.7 + buttons[3].frame.width*0.6
                    HwidthConstraint.constant = screenWidth/10.7 + buttons[3].frame.width*0.6
                }

                mainView.addConstraints([LwidthConstraint, HwidthConstraint])
                mainView.addConstraints([LheightConstraint, HheightConstraint])
                mainView.addConstraints([LcenterY, HcenterY])
                mainView.addConstraints([LdistRight, HdistLeft])

                l--
                h++
            }
            return
        }
        
        else {
            
            // 123 NUMBERS BUTTON
            var _topConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            var _bottomConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -4)
            var _widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/11 + buttons[0].frame.width*0.35)
            var _leftConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 5);
            _topConstraint.priority = 1000
            _bottomConstraint.priority = 1000
            mainView.addConstraints([_leftConstraint, _bottomConstraint, _topConstraint, _widthConstraint])
            
            // NEXT BUTTON
            var centerY = NSLayoutConstraint(item: buttons[1], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            var heightConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            var widthConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 1.0, constant: 0)
            var leftConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Left, relatedBy: .Equal, toItem: buttons[0], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])
            
            // MIC BUTTON
            centerY = NSLayoutConstraint(item: buttons[2], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            widthConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 1.0, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Left, relatedBy: .Equal, toItem: buttons[1], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])
            
            // SPACE BUTTON
            centerY = NSLayoutConstraint(item: buttons[3], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            widthConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 2.65, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Left, relatedBy: .Equal, toItem: buttons[2], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])
            
            // RETURN BUTTON
            centerY = NSLayoutConstraint(item: buttons[4], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Left, relatedBy: .Equal, toItem: buttons[3], attribute: .Right, multiplier: 1.0, constant: 3)
            var rightConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -5)
            
            mainView.addConstraints([centerY, heightConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            
            // LEFT/RIGHT SIDES
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -1)
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 1)
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            
            var topConstraint: NSLayoutConstraint
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0)
                if UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width {
                    self.view.addConstraint(NSLayoutConstraint(
                        item:rowView, attribute:NSLayoutAttribute.Height,
                        relatedBy:NSLayoutRelation.Equal,
                        toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                        multiplier:0, constant:UIScreen.mainScreen().bounds.height/12))
                } else {
                    self.view.addConstraint(NSLayoutConstraint(
                        item:rowView, attribute:NSLayoutAttribute.Height,
                        relatedBy:NSLayoutRelation.Equal,
                        toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                        multiplier:0, constant:UIScreen.mainScreen().bounds.height/8))
                }
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: rowView, attribute: .Height, relatedBy: .Equal, toItem: firstRow, attribute: .Height, multiplier: 1.0, constant: -2)
                
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            // BOTTOM
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            }else{
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            println(rowView.frame)
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        println(duration)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64((duration-0.05) * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            for view in self.view.subviews
            {
                view.removeFromSuperview()
            }
        })
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        buildKeyboard()
    }
    
    func giveBlurView(frame: CGRect) -> UIView {
        //blur view
        var blur = UIBlurEffect(style:.ExtraLight)
        var blurView = UIVisualEffectView(effect: blur)
        
        // vibrancy view
        var vibrancy = UIVibrancyEffect(forBlurEffect: blurView.effect as UIBlurEffect)
        var vibrancyView = UIVisualEffectView(effect: vibrancy)
        blurView.frame = frame
        vibrancyView.frame = frame
        vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        blurView.contentView.addSubview(vibrancyView)
        
        return blurView
    }
    
    func showMic()
    {
        MIC_OPEN = true
        var frame = self.view.frame
        frame.origin.y = frame.height
        
        var viw = UIView(frame: frame)
        viw.tag = 99
        viw.backgroundColor = .clearColor()
        self.view.addSubview(viw)
        
        frame = viw.frame
        frame.origin.y = 0;
        frame.size.height = frame.height * 0.75
        var topToolbar = UIView(frame: frame)
        topToolbar .addSubview( giveBlurView(frame) )
        
//        let geniusButton = tintedIconButton(iconNamed: "Genius")
//        geniusButton.center = lightVibrancyView.convertPoint(lightVibrancyView.center, fromView: lightVibrancyView.superview)
//        lightVibrancyView.contentView.addSubview(geniusButton)
        
        frame = viw.frame
        frame.origin.y = frame.height * 0.75 + 1
        frame.size.height = frame.height * 0.25
        var botToolbar = UIView(frame: frame)
        frame.origin.y = 0;
        botToolbar .addSubview(giveBlurView(frame))

        viw.addSubview(topToolbar)
        viw.addSubview(botToolbar)
        
        var botLabel = UILabel(frame: CGRectMake(0, 0, botToolbar.frame.width, botToolbar.frame.height))
        botLabel.text = "Hide Microphone"
        botLabel.textColor = foreGround
        botLabel.textAlignment = .Center
        botLabel.userInteractionEnabled = false
        botToolbar.addSubview(botLabel)
        
        botToolbar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideMic"))
        
        frame = viw.frame
        frame.origin.y = 0
        UIView.animateWithDuration(0.17, animations: { () -> Void in
            viw.frame = frame
            }, completion:{(Bool) in

        })
        
    }
    
    func hideMic(){
        var frame = self.view.viewWithTag(99)!.frame
        frame.origin.y = self.view.frame.height

        UIView.animateWithDuration(0.17, animations:  {() in
            self.view.viewWithTag(99)!.frame = frame
            }, completion:{(Bool) in
                self.MIC_OPEN = false
                self.view.viewWithTag(99)!.removeFromSuperview()
        })
    
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0
        {
            var loc : CLLocation = locations[0] as CLLocation
            if !MIC_OPEN {
                if loc.speed > 10 {
                    showMic()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        
        
    }
    
    func isOpenAccessGranted() -> Bool {
        let fm = NSFileManager.defaultManager()
        let containerPath = fm.containerURLForSecurityApplicationGroupIdentifier(
            "group.com.example")?.path
        var error: NSError?
        fm.contentsOfDirectoryAtPath(containerPath!, error: &error)
        if (error != nil) {
            NSLog("Full Access: Off")
            return false
        }
        NSLog("Full Access: On");
        return true
    }
    
}
