//
//  tileView.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/25/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit

class tileView:UIView{
    var showLabel: UILabel
    init(position: CGPoint, width: CGFloat, height: CGFloat, cardImage: String, label: Int){
        showLabel = UILabel(frame: CGRectMake(0,0, width, height))
        showLabel.textAlignment = NSTextAlignment.Center
        showLabel.minimumScaleFactor = 0.5
        super.init(frame: CGRectMake(position.x, position.y, width, height))
        addSubview(showLabel)
        if(label == 0 ){
            showLabel.text = "Up"
            backgroundColor = UIColor(patternImage:(UIImage(named: cardImage))!)
            
        }else{
            
            showLabel.text = "Down"
            backgroundColor = UIColor.yellowColor()
            backgroundColor = UIColor(patternImage:(UIImage(named: cardImage))!)

        }
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}