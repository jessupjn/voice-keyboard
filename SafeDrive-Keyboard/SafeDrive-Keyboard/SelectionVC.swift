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
    
    private var _options : [String]?
    private var _delegate : SelectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Make a Selection"
    }
    
    func setupVC(options : [String], delegate : SelectionVCDelegate){
        _options = options
        _delegate = delegate
        self.tableView.reloadData()
    }
    
    
    //
    //  tableview datasource/delegate methods
    //
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if _delegate != nil {
            _delegate?.didSelect( tableView.cellForRowAtIndexPath(indexPath)!.textLabel.text!, forOption: "" )
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _options == nil {
            return 0
        } else {
            return countElements(_options!)
        }
    }
}