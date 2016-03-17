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
    var check = [Int]()
    var audioPlayer = AVAudioPlayer()
    var message = ""
    let bombSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Explosion", ofType: "mp3")!)
    

    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        createPlayer1Grid()
        createPlayer2Grid()
        
        //Start at player 1 turn
        if game.turn == 0{
            print("Player 1 turn")
            showActivePlayer1Ships()
            hideActivePlayer2Ships()
            createCoverSheet("Player 1 are you ready?")
        }
        else{
            print("Player 2 turn")
            showActivePlayer2Ships()
            hideActivePlayer1Ships()
            createCoverSheet("Player 2 are you ready?")
        }
        
        //Display game stats but do not allow play
        if game.gameEnded == true{
            if game.gameWinner == 0{
                createCoverSheet("Player 1 has already won!")
            }
            else if game.gameWinner == 1{
                createCoverSheet("Player 2 has already won!")
            }
        }
        
        //Set sound
        print(bombSound)
        
        //Preparation
        do { audioPlayer = try AVAudioPlayer(contentsOfURL: bombSound, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        audioPlayer.prepareToPlay()
    }
    
    func getGameStatus() -> Game{
        return game
    }
    
    //Creates a cover sheet with appropriate message
    func createCoverSheet(s:String){
        if cover == nil{
            cover = CoverSheet(frame: CGRectMake(0, 0, 520, 250))
            let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)
            cover.backgroundColor = color
            cover.setText(s)
            cover.setText2(message)
            cover.tag = 1000
        }
        else{
            cover = nil
            viewWithTag(1000)?.removeFromSuperview()
            cover = CoverSheet(frame: CGRectMake(0, 0, 520, 250))
            let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)
            cover.backgroundColor = color
            cover.setText(s)
            cover.setText2(message)
            cover.tag = 1000
            
        }
        
        addSubview(cover)
    }
    
    //Loads an old game
    func loadGame(gameToLoad: Game){
        game = gameToLoad
    }
    
    //Create water tiles and ship tiles for player 1
    func createPlayer1Grid(){
        //Create water tiles
        for var i = 0; i < 8; i++ {
            for var j = 0; j < 8; j++ {
                let waterGrid = Grid(frame: CGRectMake(CGFloat(30 * i), CGFloat(30 * j), 30, 30))
                waterGrid.updatePosition(i, newY: j)
                addSubview(waterGrid)
            }
        }
        //Create ship tiles
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            createGridPlayer1(shipTemp)
        }
        //Create previous destroyed ships
        for var i = 0; i < game.player1DeadShips.count; i++ {
            let shipTemp = game.player1DeadShips[i]
            createDestroyedShipsPlayer1(shipTemp)
        }
        //Create destroyed water tiles
        for var i = 0; i < game.DestroyedPlayer1Tiles.count; i++ {
            let waterTemp = game.DestroyedPlayer1Tiles[i]
            let waterGrid = WaterDestroyed(frame: CGRectMake(CGFloat(30 * waterTemp.positionX), CGFloat(30 * waterTemp.positionY), 30, 30))
            waterGrid.updatePosition(waterTemp.positionX, newY: waterTemp.positionY)
            addSubview(waterGrid)
        }
    }
    
    //Create water tiles and ship tiles for player 2
    func createPlayer2Grid(){
        //Create water tiles
        for var i = 0; i < 8; i++ {
            for var j = 0; j < 8; j++ {
                let waterGrid = Grid(frame: CGRectMake(frame.width/2 + CGFloat(30 * i) + 20, CGFloat(30 * j), 30, 30))
                waterGrid.updatePosition(i, newY: j)
                addSubview(waterGrid)
            }
        }
        //Create ship tiles
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            createGridPlayer2(shipTemp)
        }
        //Create previous destroyed ships
        for var i = 0; i < game.player2DeadShips.count; i++ {
            let shipTemp = game.player2DeadShips[i]
            createDestroyedShipsPlayer2(shipTemp)
        }
        //Create destroyed water tiles
        for var i = 0; i < game.DestroyedPlayer2Tiles.count; i++ {
            let waterTemp = game.DestroyedPlayer2Tiles[i]
            let waterGrid = WaterDestroyed(frame: CGRectMake(CGFloat(30 * waterTemp.positionX) + 20, CGFloat(30 * waterTemp.positionY), 30, 30))
            waterGrid.updatePosition(waterTemp.positionX, newY: waterTemp.positionY)
            addSubview(waterGrid)
        }
    }
    
    //Create ships of various sizes for player 1
    func createDestroyedShipsPlayer1(ship:Ship){
        for var i = 0; i < ship.shipSize; i++ {
            let offset = i * 30
            let player1Grid = ShipMidDestroyed(frame: CGRectMake(CGFloat(30 * ship.positionX) + CGFloat(offset), CGFloat(30 * ship.positionY), 30, 30))
            player1Grid.updatePosition(ship.positionX, newY: ship.positionY)
            player1Grid.tag = ship.shipID + (ship.shipSize * 300) + i
            check.append(player1Grid.tag)
            addSubview(player1Grid)
        }
    }
    
    //Create destroyed portions of ships of various sizes for player 1
    func createDestroyedShipsPlayer2(ship:Ship){
        for var i = 0; i < ship.shipSize; i++ {
            let offset = i * 30 + 20
            let player2Grid = ShipMidDestroyed(frame: CGRectMake(frame.width/2 + CGFloat(30 * ship.positionX) + CGFloat(offset), CGFloat(30 * ship.positionY), 30, 30))
            player2Grid.updatePosition(ship.positionX, newY: ship.positionY)
            player2Grid.tag = ship.shipID + (ship.shipSize * 200) + i
            check.append(player2Grid.tag)
            addSubview(player2Grid)
        }
    }
    
    //Create ships of various sizes for player 2
    func createGridPlayer2(ship:Ship){
        for var i = 0; i < ship.shipSize; i++ {
            let offset = i * 30 + 20
            let player2Grid = ShipMid(frame: CGRectMake(frame.width/2 + CGFloat(30 * ship.positionX) + CGFloat(offset), CGFloat(30 * ship.positionY), 30, 30))
            player2Grid.updatePosition(ship.positionX, newY: ship.positionY)
            player2Grid.tag = ship.shipID + (ship.shipSize * 200) + i
            check.append(player2Grid.tag)
            addSubview(player2Grid)
        }
    }
    
    //Create ships of various sizes for player 1
    func createGridPlayer1(ship:Ship){
        for var i = 0; i < ship.shipSize; i++ {
            let offset = i * 30
            let player1Grid = ShipMid(frame: CGRectMake(CGFloat(30 * ship.positionX) + CGFloat(offset), CGFloat(30 * ship.positionY), 30, 30))
            player1Grid.updatePosition(ship.positionX, newY: ship.positionY)
            player1Grid.tag = ship.shipID + (ship.shipSize * 300) + i
            check.append(player1Grid.tag)
            addSubview(player1Grid)
        }
    }
    
    //Hide all of player 1's ships when its player 2's turn
    func hideActivePlayer1Ships(){
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            for var j = 0; j < shipTemp.shipSize; j++ {
                let id = shipTemp.shipID + (shipTemp.shipSize * 300) + j
                viewWithTag(id)!.hidden = true
            }
        }
    }
    
    //Same as above but vice versa
    func hideActivePlayer2Ships(){
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            for var j = 0; j < shipTemp.shipSize; j++ {
                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 200) + j)!.hidden = true
            }
        }
    }
    
    //Show player 1's ships for player 1's turn
    func showActivePlayer1Ships(){
        for var i = 0; i < game.player1Ships.count; i++ {
            let shipTemp = game.player1Ships[i]
            for var j = 0; j < shipTemp.shipSize; j++ {
                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 300) + j)!.hidden = false
            }
        }
    }
    
    //Same as above but vice versa
    func showActivePlayer2Ships(){
        for var i = 0; i < game.player2Ships.count; i++ {
            let shipTemp = game.player2Ships[i]
            for var j = 0; j < shipTemp.shipSize; j++ {
                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 200) + j)!.hidden = false
            }
        }
    }
    
    //After a succesful touch, display m
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if validTouch == true && game.gameEnded == false{
            print("Switching turns")
            if game.turn == 0 {
                
                let delay = 3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    // After 2 seconds this line will be executed
                    print("Player 1 turn")
                    self.createCoverSheet("Player 1 are you ready?")
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
                    self.createCoverSheet("Player 2 are you ready?")
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
        
        //To get exact coordinates
        let x = floor(touchPoint.x / 30.0)
        let y = floor(touchPoint.y / 30.0)
        
        //Player 1 turn
        if game.turn == 0 && coverHidden == true && game.gameEnded == false {
            //Player 1 can only shoot at player 2 grid
            if x > 7{
                if game.shootAt(Int(x), y: Int(y)){
                    let destroyedTile = ShipMidDestroyed(frame: CGRectMake(CGFloat(30 * x) + 10, CGFloat(30 * y), 30, 30))
                    addSubview(destroyedTile)
                    if game.player2Ships.isEmpty{
                        reportPlayer1Win()
                    }
                }
                else{
                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(30 * x) + 10, CGFloat(30 * y), 30, 30))
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
        else if game.turn == 1 && coverHidden == true && game.gameEnded == false {
            //Player 2 can only shoot at player 1 grid
            if x < 8{
                if game.shootAt(Int(x), y: Int(y)){
                    let destroyedTile = ShipMidDestroyed(frame: CGRectMake(CGFloat(30 * x), CGFloat(30 * y), 30, 30))
                    addSubview(destroyedTile)
                    if game.player1Ships.isEmpty{
                        reportPlayer2Win()
                    }
                }
                else{
                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(30 * x), CGFloat(30 * y), 30, 30))
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
        //For dealing with getting rid of the cover sheet
        else{
            validTouch = false
            cover.hidden = true
            coverHidden = true
        }
    }
    
    //End the game with player 1 winning
    func reportPlayer1Win(){
        game.gameEnded = true
        game.gameWinner = 0
        createCoverSheet("Player 1 has won!")
    }
    
    //End the game with player 2 winning
    func reportPlayer2Win(){
        game.gameEnded = true
        game.gameWinner = 1
        createCoverSheet("Player 2 has won!")
    }
}