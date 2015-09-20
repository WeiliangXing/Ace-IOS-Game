//
//  timer.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/26/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit

class timer: UIViewController {
    
    
    var timer: NSTimer!
    @IBOutlet var timerLabel: UILabel!
    var tenseconds: Int!
    var seconds: Int!
    var milseconds: Int!
    //    var hours, minutes, seconds, secondsLeft : Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tenseconds = 50
        seconds = 5
        milseconds = 0
        timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds) as String
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pressButton(){
        
        timer = NSTimer.scheduledTimerWithTimeInterval( 0.1 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
    }
    
    
    @IBAction func stopButton(){
        if (timer){
            timer.invalidate()
            timer = nil
        }
    }
    
    func update(){
        //println(seconds)
        
        if(tenseconds > 0) {
            
            tenseconds = tenseconds - 1
            seconds = tenseconds / 10
            milseconds = tenseconds % 10
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10)
        } else{
            timer.invalidate()
            tenseconds = 50
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10) as String
        }
        
    }
    
}