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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"endEdit"))
    }

    func endEdit(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

