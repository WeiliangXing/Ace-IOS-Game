//
//  AudioController.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/16/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import AVFoundation

var manuBGMPlayer: AVAudioPlayer = AVAudioPlayer()
var audioMarker:Bool!

class AudioController{
    init(){
        //audioMarker = true
        var bgMusicURL: NSURL = NSBundle.mainBundle().URLForResource("manu_bgmusic", withExtension: "mp3")
        
        manuBGMPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL, error: nil)
        manuBGMPlayer.numberOfLoops = -1
        manuBGMPlayer.prepareToPlay()
        if(audioMarker == true){
            manuBGMPlayer.play()
        }else{
            manuBGMPlayer.stop()
        }
    }
}