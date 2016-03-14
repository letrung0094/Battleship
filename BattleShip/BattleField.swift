//
//  BattleField.swift
//  BattleShip
//
//  Created by Trung Le on 3/13/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit
import Darwin
import SpriteKit
import AVFoundation

class BattleField: UIView{
    var game: Game!
    var cover: CoverSheet!
    var validTouch: Bool = false
    var coverHidden: Bool = false
    var audioPlayer = AVAudioPlayer()
    let bombSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Explosion", ofType: "mp3")!)

    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        createPlayer1Grid()
        createPlayer2Grid()
        
        //Start at player 1 turn
        print("Player 1 turn")
        showActivePlayer1Ships()
        hideActivePlayer2Ships()
        createCoverSheet("Player 1 are you ready1?")
        cover.hidden = true
        
        //Set sound
        print(bombSound)
        
        //Preparation
        do { audioPlayer = try AVAudioPlayer(contentsOfURL: bombSound, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        audioPlayer.prepareToPlay()
    }
    
    func createCoverSheet(s:String){
        if cover == nil{
            cover = CoverSheet(frame: CGRectMake(0, 0, 520, 250))
            let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)
            cover.backgroundColor = color
            cover.setText(s)
            cover.tag = 1000
        }
        else{
            cover = nil
            viewWithTag(1000)?.removeFromSuperview()
            cover = CoverSheet(frame: CGRectMake(0, 0, 520, 250))
            let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)
            cover.backgroundColor = color
            cover.setText(s)
            cover.tag = 1000
        }
        
        addSubview(cover)
    }
    
    func loadGame(gameToLoad: Game){
        game = gameToLoad
    }
    
    func createPlayer1Grid(){
        for var i = 0; i < 5; i++ {
            for var j = 0; j < 5; j++ {
                let waterGrid = Grid(frame: CGRectMake(CGFloat(50 * i), CGFloat(50 * j), 50, 50))
                waterGrid.updatePosition(i, newY: j)
                addSubview(waterGrid)
            }
        }
        
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            let player1Grid = Player1Grid(frame: CGRectMake(CGFloat(50 * shipTemp.positionX), CGFloat(50 * shipTemp.positionY), 50, 50))
            player1Grid.updatePosition(shipTemp.positionX, newY: shipTemp.positionY)
            player1Grid.tag = shipTemp.shipID
            addSubview(player1Grid)
        }
        
    }
    
    func createPlayer2Grid(){
        for var i = 0; i < 5; i++ {
            for var j = 0; j < 5; j++ {
                let waterGrid = Grid(frame: CGRectMake(frame.width/2 + CGFloat(50 * i) + 10, CGFloat(50 * j), 50, 50))
                waterGrid.updatePosition(i, newY: j)
                addSubview(waterGrid)
            }
        }
        
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            let player2Grid = Player2Grid(frame: CGRectMake(frame.width/2 + CGFloat(50 * shipTemp.positionX) + 10, CGFloat(50 * shipTemp.positionY), 50, 50))
            player2Grid.updatePosition(shipTemp.positionX, newY: shipTemp.positionY)
            player2Grid.tag = shipTemp.shipID
            addSubview(player2Grid)
        }
    }
    
    func hideActivePlayer1Ships(){
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            viewWithTag(shipTemp.shipID)!.hidden = true
        }
    }
    
    func hideActivePlayer2Ships(){
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            viewWithTag(shipTemp.shipID)!.hidden = true
        }
    }
    
    func showActivePlayer1Ships(){
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            viewWithTag(shipTemp.shipID)!.hidden = false
        }
    }
    
    func showActivePlayer2Ships(){
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            viewWithTag(shipTemp.shipID)!.hidden = false
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if validTouch == true {
            print("Switching turns")
            if game.turn == 0 {
                
                let delay = 3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    // After 2 seconds this line will be executed
                    print("Player 1 turn")
                    self.createCoverSheet("Player 1 are you ready2?")
                    self.coverHidden = false
                    self.hideActivePlayer2Ships()
                    self.showActivePlayer1Ships()
                }
            }
            else{
                let delay = 3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    // After 2 seconds this line will be executed
                    print("Player 2 turn")
                    self.createCoverSheet("Player 2 are you ready2?")
                    self.coverHidden = false
                    self.showActivePlayer2Ships()
                    self.hideActivePlayer1Ships()
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self)
        
        let x = floor(touchPoint.x / 50.0)
        let y = floor(touchPoint.y / 50.0)
        
        
        //Player 1 turn
        if game.turn == 0 && coverHidden == true {
            //Player 1 can only shoot at player 2 grid
            if x > 4{
                if game.shootAt(Int(x), y: Int(y)){
                    let destroyedTile = Player2GridDestroyed(frame: CGRectMake(CGFloat(50 * x) + 20, CGFloat(50 * y), 50, 50))
                    addSubview(destroyedTile)
                }
                else{
                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(50 * x) + 20, CGFloat(50 * y), 50, 50))
                    addSubview(destroyedTile)
                }
                print("Shoot point: (\(x), \(y))")
                audioPlayer.play()
                validTouch = true
            }
            else{
                validTouch = false
            }
        }
        //Player 2 turn
        else if game.turn == 1 && coverHidden == true {
            //Player 2 can only shoot at player 1 grid
            if x < 5{
                if game.shootAt(Int(x), y: Int(y)){
                    let destroyedTile = Player1GridDestroyed(frame: CGRectMake(CGFloat(50 * x), CGFloat(50 * y), 50, 50))
                    addSubview(destroyedTile)
                }
                else{
                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(50 * x), CGFloat(50 * y), 50, 50))
                    addSubview(destroyedTile)
                }
                print("Shoot point: (\(x), \(y))")
                audioPlayer.play()
                validTouch = true
            }
            else{
                validTouch = false
            }
        }
        else{
            validTouch = false
            cover.hidden = true
            coverHidden = true
        }
    }
}