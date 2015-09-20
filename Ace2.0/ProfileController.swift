//
//  ProfileController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/16/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class ProfileController: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet var level: UITextField!
    @IBOutlet var rank: UITextField!
    @IBOutlet var money:UITextField!
    @IBOutlet var win: UITextField!
    @IBOutlet var total: UITextField!
    
    @IBOutlet var buttonChangePortrait: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var username = accountSingle.tasks[accountSingle.tasks.count-1].username
        
        println(accountSingle.tasks.count)
        
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Account")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "username = %@","" + username)
        println("run")
        var results:NSArray = context.executeFetchRequest(request, error: nil)

        if(results.count > 0){            
            var res = results[0] as NSManagedObject
            name.text = res.valueForKey("username") as String
            
            //object-c: UIImage *image = [UIImage imageWithData:[selectedObject valueForKey:@"image"]];
            //[[newCustomer yourImageView] setImage:image]; 
            //comments:in swift there is no moer method imagewithdata in UIImage, just use UIImage
            //comments: : is (), space is  .  
            var Image: UIImage = UIImage(data: res.valueForKey("portrait") as NSData)
            profileImage.image = Image
            
            
            level.text = res.valueForKey("level") as String
            rank.text = res.valueForKey("rank") as String
            money.text = res.valueForKey("money") as String
            win.text = res.valueForKey("win") as String
            total.text = res.valueForKey("total") as String
            
            
            println("profile done")
            
        }else{
            println("fail to access")
        }

        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}