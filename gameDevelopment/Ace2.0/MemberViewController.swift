//
//  MemberViewController.swift
//  Ace2.0
//
//  Created by Weiliang Xing on 6/24/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit

var changePortraitMarkerFromExisting = true

class MemberViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var loginView: FBLoginView!
    

    override func viewDidLoad() {
        super.viewDidLoad()    
        
        if globalFBMarker == true {
            loginView.hidden = false
            signOutButton.enabled = false
            signOutButton.hidden = true            
            
        } else{
            loginView.hidden = true
            signOutButton.enabled = true
            signOutButton.hidden = false
            
           
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView?) {
        globalFBMarker = false
       self.performSegueWithIdentifier("RegisterIdentifier", sender: self)
        
    }


}