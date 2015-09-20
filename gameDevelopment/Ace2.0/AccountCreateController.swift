//
//  AccountCreateController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/15/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class AccountCreateController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtEmail: UITextField!
    
    
    @IBOutlet var buttonTerm: UIButton!
    @IBOutlet var buttonUpdate: UIButton!
    @IBOutlet var buttonNext: UIButton!
    
    

    var checkButtonTerm: Bool!
    var checkButtonUpdate:Bool!
    var username:String!
    var password:String!
    var email:String!
    
    var checkbox_normal: UIImage = UIImage(named:"checkbox")
    var checkbox_checked: UIImage = UIImage(named:"checkbox-checked")
    var checkbox_highlighted: UIImage = UIImage(named:"checkbox-pressed")
    
    
    var markerUsername: Bool!
    var markerPassword: Bool!
    var markerEmail: Bool!
    
    // for administration
    var deletedItem: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkButtonTerm = false
        checkButtonUpdate = true
        buttonUpdate.setImage(checkbox_checked, forState: UIControlState.Normal)
        txtUsername.tag = 1
        txtPassword.tag = 2
        txtEmail.tag = 3
        txtPassword.secureTextEntry = true
        markerUsername = false
        markerPassword = false
        markerEmail = false
        
        txtUsername.enabled = true
        txtPassword.enabled = false
        txtEmail.enabled = false
        
        //for test
        buttonNext.enabled = false

    }
    
    override func viewWillLayoutSubviews() {
        
        var manuBGM:AudioController = AudioController()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // check agreeterm button
    @IBAction func agreebutton_press(){
        if(checkButtonTerm == false){

            buttonTerm.setImage(checkbox_checked, forState: UIControlState.Normal)
            if(markerEmail && markerPassword && markerUsername){
                buttonNext.enabled = true
            }
            checkButtonTerm = true
        
        }else{
            //println("will uncheck")
            buttonTerm.setImage(checkbox_normal, forState: UIControlState.Normal)
            buttonNext.enabled = false
            checkButtonTerm = false
        }
    }
    
    // check agree update button
    @IBAction func updatebutton_press(){
        if(checkButtonUpdate == false){
            buttonUpdate.setImage(checkbox_checked, forState: UIControlState.Normal)
            checkButtonUpdate = true
            
        }else{
            buttonUpdate.setImage(checkbox_normal, forState: UIControlState.Normal)
            checkButtonUpdate = false
        }
    }
    
    // used to wipe the keyboard when touch or press the button
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
    //UITextField Delegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        
        // used to wipe the keyboard when finishing using it
        switch textField.tag{
        case 1,2,3:textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool{
        
        // Problem: cannot solve the problem: when finish the previous text in error and then type in next text, the alert is covered partially by the keyboard.
        //????????????????????????????????????????????????????????????
        return true
    }
    
    // get the local database data to decide whether unique and valid
    func textFieldDidEndEditing(textField: UITextField!){
        // reference to AppDelegate
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Account")
        request.returnsObjectsAsFaults = false
        
        switch textField.tag{
        case 1 ://username
            request.predicate = NSPredicate(format: "username = %@","" + txtUsername.text)
            var results:NSArray = context.executeFetchRequest(request, error: nil)
            
            if(results.count > 0){
                generateAlert("The username already exists!")
                deletedItem = textField.text
                textField.text = ""
                markerUsername = false
            }else if(textField.text == ""){
                generateAlert("The username is empty!")
                deletedItem = textField.text
            }else {
                markerUsername = true
                txtPassword.enabled = true
                println("username finished")
            }
            
        case 2://password
            if(countElements(textField.text + "") < 6){
                generateAlert("Password must have at least 6 characters!")
                textField.text = ""
                markerPassword = false
            }else if(textField.text == ""){
                generateAlert("The password is empty!")
            }else{
                
                markerPassword = true
                txtEmail.enabled = true
                println("password finished")
            }
            
        case 3://email
            request.predicate = NSPredicate(format: "email = %@","" + txtEmail.text)
            var results:NSArray = context.executeFetchRequest(request, error: nil)
            
            if(NotFindChar("@", str: textField.text) || !textField.text.hasSuffix(".com")){
                generateAlert("Invalid Email Address!")
                markerEmail = false
            }else if(results.count > 0){
                generateAlert("The email already exists!")
                textField.text = ""
                markerEmail = false

            }else if(textField.text == ""){
                generateAlert("The email address is empty!")
            }else{
                markerEmail = true
                
                println("email finished")
            }
            
        default:
            println("nothing")
            
        }
    }
    
    @IBAction func buttonNext_Pressed(){
        
        // indicate portrait creation is the first time
        changePortraitMarkerFromExisting = false
        
        // used to store the infor in local database
        
        // reference to AppDelegate
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var newUser = NSEntityDescription.insertNewObjectForEntityForName("Account", inManagedObjectContext: context) as NSManagedObject
        newUser.setValue("" + txtUsername.text, forKey:"username")
        newUser.setValue("" + txtPassword.text, forKey:"password")
        newUser.setValue("" + txtEmail.text, forKey:"email")
        
        newUser.setValue(Bool(checkButtonTerm), forKey:"checkTerm")
        newUser.setValue(Bool(checkButtonUpdate), forKey:"checkUpdate")
        
        
        newUser.setValue(String(accountSingle.info.rank), forKey: "rank")
        newUser.setValue(String(accountSingle.info.level), forKey: "level")
        newUser.setValue(String(accountSingle.info.win), forKey: "win")
        newUser.setValue(String(accountSingle.info.total), forKey: "total")
        newUser.setValue(String(accountSingle.info.money), forKey: "money")
        
        context.save(nil)
        println("Object Saved.")
        // always add new account at the last of accountSingle, which is used to extract to connect other classes.
        accountSingle.addTask(username: txtUsername.text, password: txtPassword.text, email: txtEmail.text, checkUpdate: checkButtonTerm, checkTerm: checkButtonUpdate, profileInfo: accountSingle.info)
    }
    
    // add alert when something invalid happened
    func generateAlert(message:String){
            var alert: UIAlertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"close", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    // find whether char exists in the string; this is a slow way.
    func NotFindChar(char:Character, str:String) -> Bool{
        for c in str {
            if (c == char){
                return false
            }
        }
        return true
    }
    
    
    // administrator operations: reset all objects in core data
    @IBOutlet var deleteButton:UIButton!
    @IBAction func deleteIterm(){
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        // get management infor from delegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        // if you want to edit the database and then run it, reset the simulator and run it again.
        var stores: NSArray =  appDel.persistentStoreCoordinator.persistentStores
        //var store: NSPersistentStore!
        for var i = 0; i < stores.count; ++i  {
            var store:NSPersistentStore = stores[i] as NSPersistentStore
            appDel.persistentStoreCoordinator.removePersistentStore(store, error: nil)
            NSFileManager.defaultManager().removeItemAtPath(store.URL.path, error: nil)
            
        }
        println("delete account \(deletedItem)")

    }
    
}