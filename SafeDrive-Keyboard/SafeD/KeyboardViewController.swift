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

    var foreGround : UIColor = UIColor(red:0.7, green: 0.2, blue: 0.3, alpha: 1)
    var backGround : UIColor = UIColor.lightTextColor()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = backGround
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton.buttonWithType(.System) as UIButton
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
        
        // BUILDING VARIOUS BUTTONS USED FOR THE KEYBOARD
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["Z", "X", "C", "V", "B", "N", "M"]
        
        var buttons = [UIButton]()
        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        for buttonTitle in buttonTitles1{
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        self.view.addSubview(keyboardRowView)
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
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 20, 20)
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel!.font = UIFont.systemFontOfSize(15)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.clearColor();
        button.setTitleColor(foreGround, forState: .Normal)
        
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        
        self.roundCorners((UIRectCorner.TopLeft|UIRectCorner.BottomRight), radius: 7, button: button)
        
        return button
    }
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as UIButton
        let title = button.titleForState(.Normal)
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        proxy.insertText(title!)
    }
    
    //
    //                      CREATE BUTTON SHAPE
    //
    func roundCorners(corners: UIRectCorner, radius: CGFloat, button: UIView)
    {
        var bounds : CGRect = button.bounds
        
        var maskPath : UIBezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:(.TopLeft|.BottomRight), cornerRadii: CGSizeMake(10, 10))
    
//        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        var maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        
        button.layer.mask = maskLayer;

//    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
        var frameLayer : CAShapeLayer = CAShapeLayer()
        frameLayer.frame = bounds;
        frameLayer.path = maskPath.CGPath;
        frameLayer.strokeColor = foreGround.CGColor
        frameLayer.fillColor = nil;
    
        button.layer.addSublayer(frameLayer)
    }
    
    
}
