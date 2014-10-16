//
//  KeyboardViewController.swift
//  SafeD
//
//  Created by Jack on 10/15/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    var foreGround : UIColor = UIColor(red:202/255.0, green:31/255.0, blue:0/255.0, alpha: 1)
    var backGround : UIColor = UIColor.lightTextColor()
    var screenWidth : CGFloat?
    var buttonWidth : CGFloat?
    var tagNum : Int = 1000;
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = backGround
        buildKeyboard()
    }
    
    func buildKeyboard()
    {
        println("buildKeyboard");
        
        // BUILDING VARIOUS BUTTONS USED FOR THE KEYBOARD
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["SH", "Z", "X", "C", "V", "B", "N", "M", "BP"]
        let buttonTitles4 = ["NEXT", "EMOJI", "SPACE", "MIC"]
        
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
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton.buttonWithType(.System) as UIButton
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
//        self.view.addSubview(self.nextKeyboardButton)
//    
//        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
//        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
//        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])

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
    
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
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
        for button in buttons {
            roundCorners(button)
        }
        
        return keyboardRowView
    }
    
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, buttonWidth!, 35)
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.frame = CGRectMake(0, 0, button.frame.size.width+2, 35)
        button.titleLabel!.font = UIFont.systemFontOfSize(18)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.clearColor();
        button.setTitleColor(foreGround, forState: .Normal)
        button.tag = tagNum++
        
        button.contentVerticalAlignment = .Top
        button.contentHorizontalAlignment = .Center
        button.setTitleColor(backGround, forState: UIControlState.Highlighted)
        button.tintColor = foreGround
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)

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
            case "BP":
                proxy.deleteBackward()
            case "SH":
                println("shift")
            case "MIC":
                showMic()
            case "NEXT":
                self.advanceToNextInputMode()
            case "SPACE":
                proxy.insertText(" ")
            default:
                proxy.insertText(title)
        }
    }
    
    //
    //                      CREATE BUTTON SHAPE
    //
    func roundCorners(button: UIView)
    {
        var bounds : CGRect = button.frame
        if (button as UIButton).titleLabel?.text == "SPACE"{
            println(bounds)
        }
        var bezierPath : UIBezierPath = UIBezierPath()
        bezierPath.moveToPoint( CGPointMake(0,bounds.height/2) )
        bezierPath.addLineToPoint( CGPointMake(0,bounds.height/3) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width/3,0) )
        bezierPath.addLineToPoint( CGPointMake(9*bounds.width/10,0) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width,bounds.height/10) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width,2*bounds.height/3) )
        bezierPath.addLineToPoint( CGPointMake(2*bounds.width/3,bounds.height) )
        bezierPath.addLineToPoint( CGPointMake(bounds.width/10,bounds.height) )
        bezierPath.addLineToPoint( CGPointMake(0,9*bounds.height/10) )
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
                        LwidthConstraint.constant = 6
                        HwidthConstraint.constant = 6
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
            var lbotConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            
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
                
                l--
                h++
            }
            return;
        }
        
        for (index, button) in enumerate(buttons) {
            
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 10)
            
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -1)
                
            }
            else{
                
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 3)
                
                println(button.tag)
            }
            else{
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
                var firstButton = buttons[0]
                var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -1)
            
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 1)
            
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0)
                self.view.addConstraint(NSLayoutConstraint(
                    item:rowView, attribute:NSLayoutAttribute.Height,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                    multiplier:0, constant:UIScreen.mainScreen().bounds.size.height/12))

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
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(duration - 0.05))
        dispatch_after(time, dispatch_get_main_queue(), {
            for view in self.view.subviews
            {
                view.removeFromSuperview()
            }
        })
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        buttonWidth = UIScreen.mainScreen().bounds.size.width / 11
        buildKeyboard()
    }
    
    func showMic()
    {
        
    }

    
}
