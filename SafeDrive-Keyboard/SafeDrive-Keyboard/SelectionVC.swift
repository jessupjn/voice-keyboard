//
//  SelectionVC.swift
//  SafeDrive-Keyboard
//
//  Created by Jack on 10/30/14.
//  Copyright (c) 2014 Jackson Jessup. All rights reserved.
//

import Foundation
import UIKit

protocol SelectionVCDelegate {
    func didSelect(option:String, forOption:String)
}

class SelectionVC: UITableViewController {
    
    private var _selectionType : String?
    private var _options : [String]?
    private var _delegate : SelectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Make a Selection"
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        self.navigationItem.backBarButtonItem?.title = "Back"
    }
    
    func setupVC(options : [String], delegate : SelectionVCDelegate){
        _options = options
        _delegate = delegate
        
        self.tableView.reloadData()
        
        if _options?[0].uppercaseString == "EXTRA LIGHT" {
            _selectionType = "THEME_SCHEME"
        } else if _options?[0].uppercaseString == "CUSTOM1" {
            _selectionType = "BUTTON_SHAPE"
        } else if _options?[0].uppercaseString == "TRACKS_SPEED" {
            _options = ["Off"]
            for var i = 1; i < 20; i++ {
                _options?.append( String(5*i) + " MPH")
            }
            _selectionType = "TRACKS_SPEED"
        }else {
            _selectionType = "THEME"
        }
    }
    
    
    //
    //  tableview datasource/delegate methods
    //
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if _delegate != nil {
            _delegate?.didSelect( _options![indexPath.row], forOption: _selectionType! )
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        if _selectionType == "TRACKS_SPEED" {
//            UIAlertView(title: "", message: "", delegate: nil, cancelButtonTitle: "Okay")
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell_ : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(cell_ == nil)
        {
            cell_ = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        if(_selectionType == "THEME"){
            var itemSize = CGSizeMake(70, 40);
            
            cell_?.imageView.image = UIImage(named: "THEME_" + _options![indexPath.row].uppercaseString)
            cell_?.imageView.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
            cell_?.imageView.layer.cornerRadius = 4.0;
            cell_?.imageView.contentMode = .ScaleAspectFill;
            cell_?.imageView.layer.masksToBounds = true;
            
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
            var imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
            cell_?.imageView.image?.drawInRect(imageRect)
            cell_?.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }
        

        cell_!.textLabel.text = _options![indexPath.row]
        
        return cell_!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _options == nil {
            return 0
        } else {
            return countElements(_options!)
        }
    }
}