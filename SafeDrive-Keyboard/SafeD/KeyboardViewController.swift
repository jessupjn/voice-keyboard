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

class KeyboardViewController: UIInputViewController, CLLocationManagerDelegate {

    @IBOutlet var nextKeyboardButton: UIButton!

    // options
    var TRACKS_SPEED : Bool = true
    var CUSTOM_SHAPE : Bool = true
    var foreGround : UIColor = UIColor(red:202/255.0, green:31/255.0, blue:0/255.0, alpha: 1)
    var backGround : UIColor = UIColor.lightTextColor()
    
    // variables
    let locManager : CLLocationManager = CLLocationManager()
    var screenWidth : CGFloat?
    var buttonWidth : CGFloat?
    var tagNum : Int = 1000;
    var shiftState = ShiftStates.None
    var goToCaps = false
    var addPeriod = false

    //
    var lowerCase : [String] = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "SH", "z", "x", "c", "v", "b", "n", "m", "⌫"]
    var upperCase : [String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    var number1 : [String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    var number2 : [String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = backGround
        
        buttonBorders(self.view)

    }
    
    func buildKeyboard()
    {
        println("buildKeyboard")
        tagNum = 1000
        
        // BUILDING VARIOUS BUTTONS USED FOR THE KEYBOARD
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
        let buttonTitles4 = ["#", "NEXT", "MIC", "space", "return"]
        
        screenWidth = UIScreen.mainScreen().bounds.size.width
        buttonWidth = screenWidth! / 11
        
        var row1 = createRow(buttonTitles1, width: screenWidth!)
        var row2 = createRow(buttonTitles2, width: screenWidth!-buttonWidth!)
        var row3 = createRow(buttonTitles3, width: screenWidth!-buttonWidth!)
        var row4 = createRow(buttonTitles4, width: screenWidth!)
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addConstraintsToInputView(self.view, rowViews: [row1, row2, row3, row4])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TRACKS_SPEED {
            self.locManager.delegate = self
            self.locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            self.locManager.distanceFilter = kCLDistanceFilterNone
            self.locManager.startUpdatingLocation()
        }
        
        buildKeyboard()

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
        button.frame = CGRectMake(0, 0, buttonWidth!, 35)
        button.sizeToFit()
        button.frame = CGRectMake(0, 0, button.frame.size.width+4, 35)
        button.titleLabel!.font = UIFont.systemFontOfSize(18)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(foreGround, forState: .Normal)
        button.tag = tagNum++
        
        if title == "MIC" {
            button.setBackgroundImage(UIImage(named:title), forState:.Normal)
        }
        else {
            button.setTitle(title, forState: .Normal)
        }
        
        button.contentVerticalAlignment = .Top
        button.contentHorizontalAlignment = .Center
        button.setTitleColor(backGround, forState: UIControlState.Highlighted)
        button.tintColor = foreGround
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        button.backgroundColor = .greenColor()
        return button
    }
    
    func buttonHighlight(sender:AnyObject?){
//        var this : Bool = sender as Bool
//
    }
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as UIButton
        let title : String = button.titleForState( button.state )!
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        switch(title){
            case "⌫":
                proxy.deleteBackward()
            case "MIC":
                showMic()
            case "SH":
                if shiftState == ShiftStates.None {
                    shiftState = ShiftStates.Shift
                    goToCaps = true
                    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.17 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        self.goToCaps = false
                    })
                    button.setTitleColor(UIColor.blueColor(), forState:.Normal)
                } else if shiftState == ShiftStates.Caps {
                    shiftState = ShiftStates.None
                    button.setTitleColor( UIColor.blackColor(), forState: .Normal)
                } else {
                    if goToCaps {
                        shiftState = ShiftStates.Caps
                        button.setTitleColor(UIColor.redColor(), forState:.Normal)
                    } else {
                        shiftState = ShiftStates.None
                        button.setTitleColor(UIColor.blackColor(), forState:.Normal)
                    }
                }
            case "NEXT":
                self.advanceToNextInputMode()
            case "SPACE":
                if addPeriod {
                    proxy.deleteBackward()
                    proxy.insertText(". ")
                }
                else { proxy.insertText(" ") }
                addPeriod = true;
                dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.17 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.addPeriod = false
                })
            default:
                if shiftState == ShiftStates.None {
                    proxy.insertText(lowerCase[button.tag-1000])
                } else if shiftState == ShiftStates.Shift {
                    proxy.insertText(upperCase[button.tag-1000])
                    shiftState = ShiftStates.None
                } else if shiftState == ShiftStates.Caps {
                    proxy.insertText(upperCase[button.tag-1000])
                } else if shiftState == ShiftStates.Number1 {
                    proxy.insertText(number1[button.tag-1000])
                } else if shiftState == ShiftStates.Number2 {
                    proxy.insertText(number2[button.tag-1000])
                }
        }
    }
    
    //
    //                      CREATE BUTTON SHAPE
    //
    func buttonBorders(view: UIView)
    {
        println(view.tag)
        if view.isKindOfClass(UIButton) && view.tag >= 1000 {
            if CUSTOM_SHAPE {
                roundCorners(view as UIButton)
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
        
        var bounds : CGRect = button.bounds
        var bezierPath : UIBezierPath = UIBezierPath()
        bezierPath.lineJoinStyle = kCGLineJoinRound
        bezierPath.moveToPoint( CGPointMake(0,bounds.height/2) )
        bezierPath.addLineToPoint( CGPointMake(0,15) )
        bezierPath.addLineToPoint( CGPointMake(15,0) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-3,0) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width,3) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width,bounds.height-15) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width-15,bounds.height) )
        bezierPath.addLineToPoint( CGPointMake(3,bounds.height) )
        bezierPath.addLineToPoint( CGPointMake(0,bounds.height-3) )
        bezierPath.addLineToPoint( CGPointMake(0,bounds.height/2) )
        bezierPath.closePath()
        
        //apply path to shapelayer
        var pathLayer : CAShapeLayer = CAShapeLayer()
        pathLayer.path = bezierPath.CGPath
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.strokeColor = foreGround.CGColor
        pathLayer.frame=CGRectMake(0, 0,bounds.width,bounds.height);
        
        //add shape layer to view's layer
        button.layer.addSublayer(pathLayer)
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        if(buttons.count > 4)
        {
            var _topConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 10)
            var _bottomConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            _topConstraint.priority = 1000
            _bottomConstraint.priority = 1000
            mainView.addConstraints([_bottomConstraint, _topConstraint])
        }
        
        if(buttons.count == 9)
        {
            var _middleConstraint = NSLayoutConstraint(item: buttons[4], attribute:.CenterX, relatedBy: .Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            mainView.addConstraint(_middleConstraint)
            
            var l = 3, h = 5;
            let dist : CGFloat = UIScreen.mainScreen().bounds.width / 125
            while l >= 0 {
                var LwidthConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)
                var HwidthConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Width, relatedBy: .Equal, toItem: buttons[4], attribute: .Width, multiplier: 1.0, constant: 0)

                var LheightConstraint = NSLayoutConstraint(item: buttons[l], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                var HheightConstraint = NSLayoutConstraint(item: buttons[h], attribute: .Height, relatedBy: .Equal, toItem: buttons[4], attribute: .Height, multiplier: 1.0, constant: 0)
                
                var LcenterY = NSLayoutConstraint(item: buttons[l], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                var HcenterY = NSLayoutConstraint(item: buttons[h], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[4], attribute: .CenterY, multiplier: 1.0, constant: 0)
                
                var LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -dist-6)
                var HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant: dist+6)

                if(buttons[0].titleLabel?.text == "SH"){
                    if(l == 0)
                    {
                        LwidthConstraint.constant = 14
                        HwidthConstraint.constant = 14
                    }
                    else
                    {
                        LdistRight.constant += 2;
                        HdistLeft.constant -= 2;
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
            var ltopConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 10)
            var lbotConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            
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
                    
                    LdistRight = NSLayoutConstraint(item: buttons[l], attribute:.Right, relatedBy:.Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: -(dist+4)/2)
                    HdistLeft = NSLayoutConstraint(item: buttons[h], attribute:.Left, relatedBy:.Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: (dist+4)/2)
                }
                else{
                    LdistRight = NSLayoutConstraint(item: buttons[l], attribute: .Right, relatedBy: .Equal, toItem: buttons[l+1], attribute: .Left, multiplier: 1.0, constant: -dist-4)
                    HdistLeft = NSLayoutConstraint(item: buttons[h], attribute: .Left, relatedBy: .Equal, toItem: buttons[h-1], attribute: .Right, multiplier: 1.0, constant: dist+4)
                }
                
                mainView.addConstraints([LcenterY, HcenterY])
                mainView.addConstraints([LheightConstraint, HheightConstraint])
                mainView.addConstraints([LwidthConstraint, HwidthConstraint])
                mainView.addConstraints([LdistRight, HdistLeft])
                
                if buttons[l].tag == 1000 {
                    buttonWidth = buttons[l].frame.size.width
                }
                l--
                h++
            }
            return;
        }
        
//      ["#", "NEXT", "MIC", "space", "return"]
        var _middleConstraint = NSLayoutConstraint(item: buttons[3], attribute:.CenterX, relatedBy: .Equal, toItem: mainView, attribute: .CenterX, multiplier: 1.0, constant: buttonWidth!-13)
        var _topConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 10)
        var _bottomConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var _widthConstraint = NSLayoutConstraint(item: buttons[3], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonWidth!*4 + 8)
        _topConstraint.priority = 1000
        _bottomConstraint.priority = 1000
        mainView.addConstraints([_middleConstraint, _bottomConstraint, _topConstraint, _widthConstraint])
        
        let dist : CGFloat = UIScreen.mainScreen().bounds.width / 125
        
        // return button
        var centerY = NSLayoutConstraint(item: buttons[4], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)
        var heightConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)
        var widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2*buttonWidth! + dist + 6)
        var borderDistConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Left, relatedBy: .Equal, toItem: buttons[3], attribute: .Right, multiplier: 1.0, constant: dist + 6)

        mainView.addConstraints([centerY, heightConstraint, widthConstraint, borderDistConstraint])

        // mic button
        centerY = NSLayoutConstraint(item: buttons[2], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)
        heightConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)
        widthConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonWidth!)
        borderDistConstraint = NSLayoutConstraint(item: buttons[2], attribute: .Right, relatedBy: .Equal, toItem: buttons[3], attribute: .Left, multiplier: 1.0, constant: -dist - 6)
        
        mainView.addConstraints([centerY, heightConstraint, widthConstraint, borderDistConstraint])
        
        // next button
        centerY = NSLayoutConstraint(item: buttons[1], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)
        heightConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)
        widthConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonWidth!)
        borderDistConstraint = NSLayoutConstraint(item: buttons[1], attribute: .Right, relatedBy: .Equal, toItem: buttons[2], attribute: .Left, multiplier: 1.0, constant: -dist - 6)
        
        mainView.addConstraints([centerY, heightConstraint, widthConstraint, borderDistConstraint])
        
        // number button
        centerY = NSLayoutConstraint(item: buttons[0], attribute: .CenterY, relatedBy: .Equal, toItem: buttons[3], attribute: .CenterY, multiplier: 1.0, constant: 0)
        heightConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Height, relatedBy: .Equal, toItem: buttons[3], attribute: .Height, multiplier: 1.0, constant: 0)
        widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonWidth!)
        borderDistConstraint = NSLayoutConstraint(item: buttons[0], attribute: .Right, relatedBy: .Equal, toItem: buttons[1], attribute: .Left, multiplier: 1.0, constant: -dist - 6)
        
        mainView.addConstraints([centerY, heightConstraint, widthConstraint, borderDistConstraint])
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {

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
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: -5)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: rowView, attribute: .Height, relatedBy: .Equal, toItem: firstRow, attribute: .Height, multiplier: 1.0, constant: 0)
                
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 5)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 5)
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
        buttonBorders(self.view)
    }
    
    func showMic()
    {
        
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if(locations.count > 0)
        {
            var loc : CLLocation = locations[0] as CLLocation
            println(loc)
            println(loc.speed)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        
        
    }
    
}
