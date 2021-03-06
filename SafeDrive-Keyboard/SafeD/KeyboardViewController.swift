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

class KeyboardViewController: UIInputViewController, CLLocationManagerDelegate, UIAlertViewDelegate, WitDelegate {

    @IBOutlet var nextKeyboardButton: UIButton!

    // options
    let userDefaults : NSUserDefaults? = NSUserDefaults(suiteName: "jack.com.keyboard.prefs")

    var TRACKS_SPEED : Bool = true
    var BUTTON_SHAPE : Int = 2
    var THEME_STYLE : String = "THEME_MOUNTAINLION"
    var BLUR_STYLE : UIBlurEffectStyle = .Light
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
    var number2 : [String] = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "=", "_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•", "123", ".", ",", "?", "!", "'", "⌫"]
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        buildKeyboard()
        // Add custom view sizing constraints here
    }

    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = .clearColor() //backGround
        
        Wit.sharedInstance().accessToken = "XNG5DZHE2AVVOQNZ42H47PNUMEX4I7UP"
        Wit.sharedInstance().detectSpeechStop = .DetectSpeechStop
        Wit.sharedInstance().delegate = self
        
//        if isOpenAccessGranted() {
            setCustomOptions()
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
        
        var fr : CGRect
        if UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width {
            fr = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height/3)
        } else {
            fr = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height/2)
        }
        let bgImg = UIImageView(frame: fr)
        bgImg.image = UIImage(named: "THEME_MOUNTAINLION")
        bgImg.tag = 69
        self.view.addSubview(bgImg)
        
        let blur = UIBlurEffect(style: BLUR_STYLE)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = CGRect(x: 0, y: 0, width: bgImg.frame.width, height: bgImg.frame.height)
        self.view.addSubview(blurView)

        tagNum = 1000

        // BUILDING VARIOUS BUTTONS USED FOR THE KEYBOARD
        let buttonTitles1 = getRow(0)
        let buttonTitles2 = getRow(1)
        let buttonTitles3 = getRow(2)
        let buttonTitles4 = getRow(3)

        screenWidth = UIScreen.mainScreen().bounds.size.width
        buttonWidth = screenWidth / 11
        
        var row1 = createRow(blurView, titles: buttonTitles1, width: screenWidth)
        var row2 = createRow(blurView, titles: buttonTitles2, width: screenWidth-buttonWidth)
        var row3 = createRow(blurView, titles: buttonTitles3, width: screenWidth-buttonWidth)
        var row4 = createRow(blurView, titles: buttonTitles4, width: screenWidth)
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraintsToInputView(blurView, rowViews: [row1, row2, row3, row4])

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var proxy = textDocumentProxy as UITextDocumentProxy
        if proxy.autocapitalizationType != .None {
            shiftState = .Shift
        }
        
        buildKeyboard()

    }
    
    override func viewDidAppear(animated: Bool) {
        
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
        
        println( userDefaults!.dictionaryRepresentation())
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
    func createRow(blurView: UIVisualEffectView, titles:[NSString], width:CGFloat)->UIView
    {

        let vibrancy = UIVibrancyEffect(forBlurEffect: blurView.effect as UIBlurEffect)
        let keyboardRowView = UIVisualEffectView(effect: vibrancy)
        keyboardRowView.frame = blurView.bounds
        keyboardRowView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        blurView.contentView.addSubview(keyboardRowView)
        
        var buttons = [UIButton]()
        for buttonTitle in titles{
            let button = createButtonWithTitle(buttonTitle)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            buttons.append(button)
            keyboardRowView.contentView.addSubview(button)
        }
        keyboardRowView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        keyboardRowView.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView.contentView)
        return keyboardRowView
    }
    
    private func tintedIconButton(iconNamed iconName: String) -> UIButton {
        let iconImage = UIImage(named: iconName)!.imageWithRenderingMode(.AlwaysTemplate)
        let borderImage = UIImage(named: "BORDER_RD")!.imageWithRenderingMode(.AlwaysTemplate)
        
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: borderImage.size))
        button.setBackgroundImage(borderImage, forState: .Normal)
        button.setImage(iconImage, forState: .Normal)
        return button
    }
    func createButtonWithTitle(title: String) -> UIButton {
        var sh : String = "BORDER_"
        switch BUTTON_SHAPE {
        case 0:
            sh += "SH1"
        case 1:
            sh += "SH2"
        case 2:
            sh += "SQ"
        default:
            sh += "RD"
        }
        
        let borderImage = UIImage(named: sh)!.imageWithRenderingMode(.AlwaysTemplate)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: borderImage.size))
        button.frame = CGRectMake(0, 0, buttonWidth, 35)
        button.sizeToFit()
        button.tag = tagNum++
        button.clipsToBounds = true
        
        button.setBackgroundImage(borderImage, forState: .Normal)
        if title == "MIC" || title == "NEXT" {
            let iconImage = UIImage(named: title)!.imageWithRenderingMode(.AlwaysTemplate)
            button.setImage(iconImage, forState:.Normal)
            button.contentMode = .ScaleAspectFit
            button.setTitle(title, forState:.Reserved)

        } else {
            if title.uppercaseString == "SH" {
                shiftButton = button
                button.setTitle(title, forState:.Reserved)
                var img : UIImage
                switch shiftState {
                case .Caps:
                    img = UIImage(named: "SHIFT_CAPS")!.imageWithRenderingMode(.AlwaysTemplate)
                case .Shift:
                    img = UIImage(named: "SHIFT_SHIFT")!.imageWithRenderingMode(.AlwaysTemplate)
                default:
                    img = UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate)
                }
                shiftButton?.setImage(img, forState: .Normal)

            } else {
                button.setTitle(title, forState: .Normal)
            }
        }
        
        button.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
        if countElements(title) > 2 {
            button.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
        }

        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "playSound:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "submitString:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    var typedString = ""
    func submitString(sender: AnyObject?){
        
        if countElements(typedString) > 0 {
            var proxy = textDocumentProxy as UITextDocumentProxy
            proxy.insertText( typedString )
            typedString = ""
        }
        
    }
    
    func playSound(sender: AnyObject?) {
        return
            
        var path = NSBundle.mainBundle().URLForResource("", withExtension: "wav")
        var sound : SystemSoundID = 0
        AudioServicesCreateSystemSoundID(path, &sound)
        AudioServicesPlaySystemSound(sound)
    }
    
    func didTapButton(sender: AnyObject?) {
        
        submitString(sender)

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
                shiftButton?.setImage(UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
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
//                proxy.
                showMic()
            case "SH":
                if shiftState == .None {
                    shiftState = .Shift
                    shiftButton?.setImage(UIImage(named: "SHIFT_SHIFT")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                    goToCaps = true
                    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.17 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        self.goToCaps = false
                    })
                } else if shiftState == .Caps {
                    shiftState = .None
                    shiftButton?.setImage(UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                } else {
                    if goToCaps {
                        shiftState = .Caps
                        shiftButton?.setImage(UIImage(named: "SHIFT_CAPS")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                    } else {
                        shiftState = .None
                        shiftButton?.setImage(UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
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
                        
                        // autocapitalization
                        if (checkForAutocaps()) && shiftState == ShiftStates.None {
                            shiftButton?.sendActionsForControlEvents(.TouchUpInside)
                        }
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
                if shiftState == .Caps {
                    shiftState = .None
                    shiftButton?.setImage(UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                    buildKeyboard()
                }
        
                dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.22 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.addPeriod = false
                    self.lastChar = ""
                })
            default:
                lastChar = title!
                if shiftState == ShiftStates.None {
                    typedString += lowerCase[button.tag-1000]
                } else if shiftState == ShiftStates.Shift {
                    typedString += upperCase[button.tag-1000]
                    shiftState = ShiftStates.None
                    shiftButton?.setImage(UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
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
        } else if ( /*proxy.autocapitalizationType? == .AllCharacters ||*/ str.length == 0) {
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
    //   KEYBOARD CONSTRAINTS
    //
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
            var _middleConstraint = NSLayoutConstraint(item: buttons[4], attribute:.CenterX, relatedBy: .Equal, toItem: mainView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0)
            mainView.superview!.addConstraint(_middleConstraint)
            var widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/10.7)
            mainView.addConstraints([widthConstraint])
            
            var l = 3, h = 5;
            while l >= 0 {
                
                var LwidthConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)
                var HwidthConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)

                var LheightConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                var HheightConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                
                var LcenterY = NSLayoutConstraint(item: buttons[l], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var HcenterY = NSLayoutConstraint(item: buttons[h], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                
                var LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -2)
                var HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant: 2)

                if buttons[l].titleForState(.Reserved)?.uppercaseString == "SH" {
                    LwidthConstraint.constant = buttons[4].frame.width * 0.6
                    HwidthConstraint.constant = buttons[4].frame.width * 0.6
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
            mainView.superview!.addConstraints([widthConstraint])
            
            var l = 4, h = 5
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
            var x :CGFloat = 0.0

            // 123 NUMBERS BUTTON
            var _topConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            var _bottomConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -4)
            var _widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenWidth/11 + buttons[0].frame.width*0.35)
            var _leftConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 5);
            _topConstraint.priority = 1000
            _bottomConstraint.priority = 1000
            mainView.addConstraints([_leftConstraint, _bottomConstraint, _topConstraint, _widthConstraint])

            x += (_leftConstraint.constant + _widthConstraint.constant)
            
            // NEXT BUTTON
            var centerY = NSLayoutConstraint(item: buttons[1], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            var heightConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            var widthConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 1.0, constant: 0)
            var leftConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Left, relatedBy: .Equal, toItem: buttons[0], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])

            x += (leftConstraint.constant + _widthConstraint.constant)

            // MIC BUTTON
            centerY = NSLayoutConstraint(item: buttons[2], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            widthConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 1.0, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Left, relatedBy: .Equal, toItem: buttons[1], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])

            x += (leftConstraint.constant + _widthConstraint.constant)

            // SPACE BUTTON
            centerY = NSLayoutConstraint(item: buttons[3], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            widthConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Width, relatedBy: .Equal, toItem: buttons[0], attribute: .Width, multiplier: 2.65, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Left, relatedBy: .Equal, toItem: buttons[2], attribute: .Right, multiplier: 1.0, constant: 3)
            
            mainView.addConstraints([centerY, heightConstraint, widthConstraint, leftConstraint])

            x += (leftConstraint.constant + (_widthConstraint.constant * 2.65))

            // RETURN BUTTON
            centerY = NSLayoutConstraint(item: buttons[4], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[0], attribute: .CenterY, multiplier: 1.0, constant: 0)
            heightConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Height, relatedBy: .Equal, toItem: buttons[0], attribute: .Height, multiplier: 1.0, constant: 0)
            leftConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Left, relatedBy: .Equal, toItem: buttons[3], attribute: .Right, multiplier: 1.0, constant: 3)
            var width = UIScreen.mainScreen().bounds.width - x - 8
            widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem:nil, attribute:.NotAnAttribute, multiplier: 1.0, constant: width )

            mainView.addConstraints([centerY, heightConstraint, leftConstraint, widthConstraint])
        }
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            
            // LEFT/RIGHT SIDES
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: 0.0)
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 0.0)
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0.0)
               
                var HC = NSLayoutConstraint(item:rowView, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:0, constant:0)
                if UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width {
                    HC.constant = UIScreen.mainScreen().bounds.height/12
                } else {
                    HC.constant = UIScreen.mainScreen().bounds.height/8
                }
                HC.priority = 1000
                self.view.addConstraint(HC)
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: rowView, attribute: .Height, relatedBy: .Equal, toItem: firstRow, attribute: .Height, multiplier: 1.0, constant: -2)
                
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            // BOTTOM
            var bottomConstraint: NSLayoutConstraint
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            }else{
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            bottomConstraint.priority = 900
            inputView.addConstraint(bottomConstraint)
        }
        
    }
    
    //
    //              VIEW WILL ROTATE - DEVICE ROTATION
    //
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        for view in self.view.subviews
//        {
//            if toInterfaceOrientation == .LandscapeLeft || toInterfaceOrientation == .LandscapeRight {
//                (view as UIView).frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width,  UIScreen.mainScreen().bounds.height/1.5)
//            } else {
//                (view as UIView).frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width,  UIScreen.mainScreen().bounds.height/3)
//            }
//            
//            for viw in view.subviews
//            {
//                viw.removeFromSuperview()
//            }
//        }
//    }
//    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        buildKeyboard()
//    }
    
    //
    //              CREATE A BLUR VIEW
    //
    func giveBlurView(frame: CGRect, style : UIBlurEffectStyle) -> UIView {
        //blur view
        var blur = UIBlurEffect(style:style)
        var blurView = UIVisualEffectView(effect: blur)
        blurView.tag = 1
        
        // vibrancy view
        var vibrancy = UIVibrancyEffect(forBlurEffect: blurView.effect as UIBlurEffect)
        var vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.tag = 1
        blurView.frame = frame
        vibrancyView.frame = frame
        vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        blurView.contentView.addSubview(vibrancyView)
        
        return blurView
    }
    
    
    //
    //              SHOW/HIDE THE MICROPHONE BUTTON
    //
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
        topToolbar .addSubview( giveBlurView(frame, style: BLUR_STYLE) )

        // create the button
        var screen = topToolbar.bounds;
        var w : CGFloat = 100;
        var rect = CGRectMake(screen.size.width/2 - w/2, screen.size.height/2 - w/2, w, w);
        var witButton = WITMicButton(frame: rect)
        
        // ADD WIT BUTTON
        var vibrancyView = (topToolbar.viewWithTag(1) as UIVisualEffectView).contentView.viewWithTag(1) as UIVisualEffectView
        vibrancyView.contentView.addSubview(witButton);

        topToolbar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "micClick:"))
        
        frame = viw.frame
        frame.origin.y = frame.height * 0.75 + 1
        frame.size.height = frame.height * 0.25
        var botToolbar = UIView(frame: frame)
        frame.origin.y = 0;
        botToolbar .addSubview(giveBlurView(frame, style: BLUR_STYLE))
        viw.addSubview(topToolbar)
        viw.addSubview(botToolbar)
        
        var botLabel = UILabel(frame: CGRectMake(0, 0, botToolbar.frame.width, botToolbar.frame.height))
        botLabel.text = "Hide Microphone"
        botLabel.textColor = foreGround
        botLabel.textAlignment = .Center
        botLabel.userInteractionEnabled = false
        
        // ADD HIDE MIC LABEL
        vibrancyView = (botToolbar.viewWithTag(1) as UIVisualEffectView).contentView.viewWithTag(1) as UIVisualEffectView
        vibrancyView.contentView.addSubview(botLabel)
        
        botToolbar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideMic"))
        
        frame = viw.frame
        frame.origin.y = 0
        UIView.animateWithDuration(0.17, animations: { () -> Void in
            viw.frame = frame
            }, completion:{(Bool) in

        })
        
    }
    
    func micClick(tap : UITapGestureRecognizer){
        for viw in tap.view!.subviews {
            if viw.isKindOfClass(WITMicButton) {
                (viw as WITMicButton).sendActionsForControlEvents(.TouchUpInside)
                return;
            }
        }
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
    
    
    
    
    // TODO TODO TODO
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
    
    
    //
    //
    //                CLLOCATIONMANAGER DELEGATE METHODS
    //
    //
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
    
    //
    //
    //                WIT DELEGATE METHODS
    //
    //
    func witDidStartRecording() {
    }
    func witDidStopRecording() {
    }
    func witDidGraspIntent(intent: String!, entities: [NSObject : AnyObject]!, body: String!, messageId: String!, confidence: NSNumber!, customData: AnyObject!, error e: NSError!) {
        if e != nil {
            
            return
        }
        
        var proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText( body )
        
    }
}
