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
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
    }
    
    func setText(s:String){
        label = UILabel(frame: CGRect(x: 180, y: frame.size.height / 2, width: 200.0, height: 20.0))
        label.textColor = UIColor.whiteColor()
        label.text = s
        addSubview(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }


}
