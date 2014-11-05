//
//  KeyboardPreview.swift
//  SafeDrive-Keyboard
//
//  Created by Jack on 10/29/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import UIKit

class KeyboardPreview : UIView {

    // SETTINGS
    private var _style: UIBlurEffectStyle?
    private var _theme: String?
    private var _buttonShape: Int?
    private var _language: String?
    
    // OTHER PRIVATE VARIABLES
    var screenWidth : CGFloat = 100
    var buttonWidth : CGFloat = 100
    
    internal func buildWith(style: UIBlurEffectStyle, theme: String, buttonShape: Int) {
        _style = style
        _theme = theme
        _buttonShape = buttonShape
        
        rebuildKeyboard()
    }
    
    private func rebuildKeyboard() {
        
        // require attributes to be set
        if _theme == nil || _style == nil || _buttonShape == nil { return }
        
        // Remove Previous Views
        if self.subviews.count > 0 {
            for view in self.subviews
            {
                view.removeFromSuperview()
            }
        }
        
        var fr : CGRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let bgImg = UIImageView(frame: fr)
        bgImg.image = UIImage(named: _theme!)
        self.addSubview(bgImg)
        let blur = UIBlurEffect(style: _style!)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = bgImg.frame
        self.addSubview(blurView)
        
        var arr = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "SH", "Z", "X", "C", "V", "B", "N", "M", "⌫"]

        screenWidth = self.frame.width
        buttonWidth = screenWidth / 11
        
        var row1 = buildRow(blurView, titles: Array(arr[0...9]), width: screenWidth)
        var row2 = buildRow(blurView, titles: Array(arr[10...18]), width: screenWidth-buttonWidth)
        var row3 = buildRow(blurView, titles: Array(arr[19...arr.count-1]), width: screenWidth-buttonWidth)
        var row4 = buildRow(blurView, titles: ["123", "NEXT", "MIC", "space", "return"], width: screenWidth)
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraintsToInputView(blurView, rowViews: [row1, row2, row3, row4])
        
    } // rebuildKeyboard

    // buildRow
    private func buildRow(blurView: UIVisualEffectView, titles:[NSString], width:CGFloat)->UIView
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

        addIndividualButtonConstraints(buttons, mainView: keyboardRowView.contentView)
        
        return keyboardRowView
    } // buildRow
    
    // createButtonWithTitle
    private func createButtonWithTitle(title: String) -> UIButton {
        var sh : String = "BORDER_"
        switch _buttonShape! {
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
        button.clipsToBounds = true
        button.userInteractionEnabled = false
        button.setBackgroundImage(borderImage, forState: .Normal)
        
        if title == "MIC" || title == "NEXT" {
            let iconImage = UIImage(named: title)!.imageWithRenderingMode(.AlwaysTemplate)
            button.setImage(iconImage, forState:.Normal)
            button.contentMode = .ScaleAspectFit
            button.setTitle(title, forState:.Reserved)
        } else {
            if title.uppercaseString == "SH" {
                button.setTitle(title, forState:.Reserved)
                var img : UIImage = UIImage(named: "SHIFT_NONE")!.imageWithRenderingMode(.AlwaysTemplate)
                button.setImage(img, forState: .Normal)
            } else {
                button.setTitle(title, forState: .Normal)
            }
        }
        
        button.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
        if countElements(title) > 2 {
            button.titleLabel!.font = UIFont.systemFontOfSize(15)
        }
        
        return button
    } // createButtonWithTitle
    
    
    //
    //  CONSTRAINTS
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
            var width = self.frame.width - x - 8
            widthConstraint = NSLayoutConstraint(item: buttons[4], attribute: .Width, relatedBy: .Equal, toItem:nil, attribute:.NotAnAttribute, multiplier: 1.0, constant: width )
            
            mainView.addConstraints([centerY, heightConstraint, leftConstraint, widthConstraint])
        }
    } // addIndividualButtonConstraints
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            
            // LEFT/RIGHT SIDES
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: 0.0)
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 0.0)
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0.0)
                
                var HC = NSLayoutConstraint(item:rowView, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:0, constant:self.frame.height/4)
                HC.priority = 1000
                self.addConstraint(HC)
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
        
    } // addConstraintsToInputView
}
