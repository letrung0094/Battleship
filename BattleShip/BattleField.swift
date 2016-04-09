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

protocol GiveBoardDelegate
{
    func givePlayerBoard(dict: NSDictionary)
}

class BattleField: UIView, GiveBoardDelegate{
    var game: Game!
    var currentGameInfo: GameInfo!
    var cover: CoverSheet!
    var validTouch: Bool = false
    var coverHidden: Bool = false
    var check = [Int]()
    var audioPlayer = AVAudioPlayer()
    var message = ""
    let bombSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Explosion", ofType: "mp3")!)
    let nw = Network()
    //var currentPlayer: Player!

    
    //Draw boards here
    func givePlayerBoard(dict: NSDictionary) {
        print("Got to draw board delegate")
        
        if dict.count == 2 {
            let playerBoard = dict["playerBoard"] as! NSArray
            let opponentBoard = dict["opponentBoard"] as! NSArray
            
            for i in 0 ..< playerBoard.count {
                let currentTile = playerBoard[i] as! NSDictionary
                let xPos = currentTile["xPos"] as! Int
                let yPos = currentTile["yPos"] as! Int
                let status = currentTile["status"] as! String
                createPlayerTile(xPos, y: yPos, s: status)
            }
            
            for i in 0 ..< opponentBoard.count {
                let currentTile = opponentBoard[i] as! NSDictionary
                let xPos = currentTile["xPos"] as! Int
                let yPos = currentTile["yPos"] as! Int
                let status = currentTile["status"] as! String
                createOpponentTile(xPos, y: yPos, s: status)
            }
        }
        else{
            createCoverSheet("Game not in play!")
        }
    
    }
    
    func createOpponentTile(x: Int, y: Int, s: String){
        
        let offSet = frame.width/2 + 10
        
        if s == "NONE"{
            let waterGrid = Grid(frame: CGRectMake(CGFloat(25 * x) + offSet, CGFloat(25 * y), 25, 25))
            waterGrid.updatePosition(x, newY: y)
            addSubview(waterGrid)
        }
            
            //Draw ship segment
        else if s == "SHIP"{
            let shipGrid = ShipMid(frame: CGRectMake(CGFloat(25 * x) + offSet, CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
            
            //Draw damaged ship segment
        else if s == "HIT"{
            let shipGrid = ShipMidDestroyed(frame: CGRectMake(CGFloat(25 * x) + offSet, CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
            
            //Draw missed shot
        else{
            let shipGrid = WaterDestroyed(frame: CGRectMake(CGFloat(25 * x) + offSet, CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
    }
    
    func createPlayerTile(x: Int, y: Int, s: String){
        //Draw water tile
        if s == "NONE"{
            let waterGrid = Grid(frame: CGRectMake(CGFloat(25 * x), CGFloat(25 * y), 25, 25))
            waterGrid.updatePosition(x, newY: y)
            addSubview(waterGrid)
        }
        
        //Draw ship segment
        else if s == "SHIP"{
            let shipGrid = ShipMid(frame: CGRectMake(CGFloat(25 * x), CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
        
        //Draw damaged ship segment
        else if s == "HIT"{
            let shipGrid = ShipMidDestroyed(frame: CGRectMake(CGFloat(25 * x), CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
        
        //Draw missed shot
        else{
            let shipGrid = WaterDestroyed(frame: CGRectMake(CGFloat(25 * x), CGFloat(25 * y), 25, 25))
            shipGrid.updatePosition(x, newY: y)
            addSubview(shipGrid)
        }
    }
    
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        //nw.getBoardForPlayer(self)
        
        //Start at player 1 turn
//        if game.turn == 0{
//            print("Player 1 turn")
//            showActivePlayer1Ships()
//            hideActivePlayer2Ships()
//            createCoverSheet("Player 1 are you ready?")
//        }
//        else{
//            print("Player 2 turn")
//            showActivePlayer2Ships()
//            hideActivePlayer1Ships()
//            createCoverSheet("Player 2 are you ready?")
//        }
//        
//        //Display game stats but do not allow play
//        if game.gameEnded == true{
//            if game.gameWinner == 0{
//                createCoverSheet("Player 1 has already won!")
//            }
//            else if game.gameWinner == 1{
//                createCoverSheet("Player 2 has already won!")
//            }
//        }
        
        //Preparation
        do { audioPlayer = try AVAudioPlayer(contentsOfURL: bombSound, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        audioPlayer.prepareToPlay()
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
    func loadGame(gameToLoad: GameInfo, player: Player){
        //currentPlayer = player
        currentGameInfo = gameToLoad
        //nw.getBoardForPlayer(self, gameID: currentGameInfo.id, playerID: "bfc72880-346b-4007-8d60-2b108e4004c8")
        nw.getBoardForPlayer(self, gameID: currentGameInfo.id, playerID: player.playerID)

    }
    
    //Create water tiles and ship tiles for player 1
    func createPlayer1Grid(){
        
    }
    
    //Create water tiles and ship tiles for player 2
    func createPlayer2Grid(){

    }
    
    //Create ships of various sizes for player 1
    func createDestroyedShipsPlayer1(ship:Ship){

    }
    
    //Create destroyed portions of ships of various sizes for player 1
    func createDestroyedShipsPlayer2(ship:Ship){

    }
    
    //Create ships of various sizes for player 2
    func createGridPlayer2(ship:Ship){

    }
    
    //Create ships of various sizes for player 1
    func createGridPlayer1(ship:Ship){

    }
    
    //Hide all of player 1's ships when its player 2's turn
    func hideActivePlayer1Ships(){
//        for i in 0 ..< game.player1Ships.count {
//            let shipTemp = game.player1Ships[i]
//            for j in 0 ..< shipTemp.shipSize {
//                let id = shipTemp.shipID + (shipTemp.shipSize * 300) + j
//                viewWithTag(id)!.hidden = true
//            }
//        }
    }
    
    //Same as above but vice versa
    func hideActivePlayer2Ships(){
//        for i in 0 ..< game.player2Ships.count {
//            let shipTemp = game.player2Ships[i]
//            for var j = 0; j < shipTemp.shipSize; j++ {
//                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 200) + j)!.hidden = true
//            }
//        }
    }
    
    //Show player 1's ships for player 1's turn
    func showActivePlayer1Ships(){
//        for var i = 0; i < game.player1Ships.count; i++ {
//            let shipTemp = game.player1Ships[i]
//            for var j = 0; j < shipTemp.shipSize; j++ {
//                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 300) + j)!.hidden = false
//            }
//        }
    }
    
    //Same as above but vice versa
    func showActivePlayer2Ships(){
//        for var i = 0; i < game.player2Ships.count; i++ {
//            let shipTemp = game.player2Ships[i]
//            for var j = 0; j < shipTemp.shipSize; j++ {
//                viewWithTag(shipTemp.shipID + (shipTemp.shipSize * 200) + j)!.hidden = false
//            }
//        }
    }
    
    //After a succesful touch, display m
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
//        if validTouch == true && game.gameEnded == false{
//            print("Switching turns")
//            if game.turn == 0 {
//                
//                let delay = 3 * Double(NSEC_PER_SEC)
//                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                dispatch_after(time, dispatch_get_main_queue()) {
//                    // After 2 seconds this line will be executed
//                    print("Player 1 turn")
//                    self.createCoverSheet("Player 1 are you ready?")
//                    self.coverHidden = false
//                    self.hideActivePlayer2Ships()
//                    self.showActivePlayer1Ships()
//                }
//            }
//            else{
//                let delay = 3 * Double(NSEC_PER_SEC)
//                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                dispatch_after(time, dispatch_get_main_queue()) {
//                    // After 2 seconds this line will be executed
//                    print("Player 2 turn")
//                    self.createCoverSheet("Player 2 are you ready?")
//                    self.coverHidden = false
//                    self.showActivePlayer2Ships()
//                    self.hideActivePlayer1Ships()
//                }
//            }
//        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
//        let touch: UITouch = touches.first!
//        let touchPoint: CGPoint = touch.locationInView(self)
//        
//        //To get exact coordinates
//        let x = floor(touchPoint.x / 30.0)
//        let y = floor(touchPoint.y / 30.0)
//        
//        //Player 1 turn
//        if game.turn == 0 && coverHidden == true && game.gameEnded == false {
//            //Player 1 can only shoot at player 2 grid
//            if x > 7{
//                if game.shootAt(Int(x), y: Int(y)){
//                    let destroyedTile = ShipMidDestroyed(frame: CGRectMake(CGFloat(30 * x) + 10, CGFloat(30 * y), 30, 30))
//                    addSubview(destroyedTile)
//                    if game.player2Ships.isEmpty{
//                        reportPlayer1Win()
//                    }
//                }
//                else{
//                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(30 * x) + 10, CGFloat(30 * y), 30, 30))
//                    addSubview(destroyedTile)
//                }
//                print("Shoot point: (\(x), \(y))")
//                audioPlayer.play()
//                validTouch = true
//            }
//            else{
//                validTouch = false
//            }
//        }
//        //Player 2 turn
//        else if game.turn == 1 && coverHidden == true && game.gameEnded == false {
//            //Player 2 can only shoot at player 1 grid
//            if x < 8{
//                if game.shootAt(Int(x), y: Int(y)){
//                    let destroyedTile = ShipMidDestroyed(frame: CGRectMake(CGFloat(30 * x), CGFloat(30 * y), 30, 30))
//                    addSubview(destroyedTile)
//                    if game.player1Ships.isEmpty{
//                        reportPlayer2Win()
//                    }
//                }
//                else{
//                    let destroyedTile = WaterDestroyed(frame: CGRectMake(CGFloat(30 * x), CGFloat(30 * y), 30, 30))
//                    addSubview(destroyedTile)
//                }
//                print("Shoot point: (\(x), \(y))")
//                audioPlayer.play()
//                validTouch = true
//            }
//            else{
//                validTouch = false
//            }
//        }
//        //For dealing with getting rid of the cover sheet
//        else{
//            validTouch = false
//            cover.hidden = true
//            coverHidden = true
//        }
    }
    
    //End the game with player 1 winning
    func reportPlayer1Win(){
//        game.gameEnded = true
//        game.gameWinner = 0
//        createCoverSheet("Player 1 has won!")
    }
    
    //End the game with player 2 winning
    func reportPlayer2Win(){
//        game.gameEnded = true
//        game.gameWinner = 1
//        createCoverSheet("Player 2 has won!")
    }
}