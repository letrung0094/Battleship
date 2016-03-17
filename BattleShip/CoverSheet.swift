//
//  CoverSheet.swift
//  BattleShip
//
//  Created by Trung Le on 3/13/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

//Cover sheet that covers the battlefield and displays a message
class CoverSheet: UIView{
    var label: UILabel = UILabel()
    var label2: UILabel = UILabel()
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
    }
    
    //Set label, used to send a message noting whose turn it is
    func setText(s:String){
        label = UILabel(frame: CGRect(x: 180, y: frame.size.height / 2, width: 200.0, height: 20.0))
        label.textColor = UIColor.whiteColor()
        label.text = s
        addSubview(label)
    }
    
    //Set second label, used to send message whether a shot was hit or miss
    func setText2(s:String){
        label2 = UILabel(frame: CGRect(x: 180, y: frame.size.height / 2 + 50, width: 200.0, height: 20.0))
        label2.textColor = UIColor.whiteColor()
        label2.text = s
        addSubview(label2)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }


}
