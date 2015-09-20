//
//  MainLoginViewController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/14/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import UIKit
import AVFoundation


class MainLoginViewController: UIViewController {
    
    @IBOutlet var buttonAudio: UIButton!
    
    @IBOutlet var buttonLogin: UIButton!
    
    @IBOutlet var buttonContinue: UIButton!
    
    var audio_normal: UIImage = UIImage(named:"audio")
    var audio_stop: UIImage = UIImage(named:"audioStop")
    override func viewDidLoad() {
        super.viewDidLoad()
        audioMarker = true
        
        if globalFBMarker == true {
            buttonLogin.hidden = true
            buttonLogin.enabled = false
            buttonContinue.hidden = false
            buttonContinue.enabled = true
            
        } else{
            buttonLogin.hidden = false
            buttonContinue.enabled = false
            buttonContinue.hidden = true
            buttonLogin.enabled = true
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        var manuBGM:AudioController = AudioController()
    }
    
    @IBAction func audioPressed(){
        
        if(audioMarker == true){
            buttonAudio.setImage(audio_stop, forState: UIControlState.Normal)
            manuBGMPlayer.stop()
            audioMarker = false
        
        }else{
            buttonAudio.setImage(audio_normal, forState: UIControlState.Normal)
            manuBGMPlayer.play()
            audioMarker = true
        }

        
    }
    
    
    func loginViewFetchedUserInfo(loginView: FBLoginView?, user: FBGraphUser) {
        var name: NSString = user.first_name + " " + user.last_name
        buttonContinue.setTitle(name, forState: UIControlState.Normal)
        
        
    }


}
