//
//  PortraitCreateController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/16/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PortraitCreateController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var button5: UIButton!
    @IBOutlet var buttonCustom: UIButton!
    @IBOutlet var buttonCreate: UIButton!
    
    @IBOutlet var backFirst: UIButton!
    @IBOutlet var backExist: UIButton!
    
    var portraitImage: UIImage!
    
    // this imageview is only for testing
    @IBOutlet var imagePortrait: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if changePortraitMarkerFromExisting == true {
            backFirst.hidden = true
            backFirst.enabled = false
            backExist.hidden = false
            backExist.enabled = true
        }else{
            backFirst.hidden = false
            backFirst.enabled = true
            backExist.hidden = true
            backExist.enabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        
        var manuBGM:AudioController = AudioController()
        
    }
    
    @IBAction func buttonPortrait(sender: UIButton){
        
        // custom choosing portrait.
        //How to build two options below???????????????
        if(sender == buttonCustom){
            var picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentModalViewController(picker, animated: true)
            
        }else{
            portraitImage = sender.currentImage
            
            // image for test
            imagePortrait.image = sender.currentImage
        }
        
        buttonCreate.enabled = true
    }
    
    // pick image from gallery
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!){
        picker.dismissModalViewControllerAnimated(true)
        
        portraitImage = info.objectForKey("UIImagePickerControllerOriginalImage") as UIImage
        
        // image for test
        // in object_C， here shows: imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"
        
        imagePortrait.image = info.objectForKey("UIImagePickerControllerOriginalImage") as UIImage
    }
    
    @IBAction func create_pressed(){
        // here save the figure into local database;
        // no need to save into accountSingle, because the current only useful variable of accountSingle
        // is username to match the data. 
        var username = accountSingle.tasks[accountSingle.tasks.count-1].username
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Account")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "username = %@","" + username)
        var results:NSArray = context.executeFetchRequest(request, error: nil)
        if(results.count > 0){
            var res = results[0] as NSManagedObject
            var imageData: NSData =  UIImageJPEGRepresentation(portraitImage, 1) as NSData
            res.setValue(imageData, forKey: "portrait")
            
            // This is very important because the new input need to be saved into database
            context.save(nil)
            
            //println(results[0])
        }else{
            println("error: nonexist account")
        }
    }
}
