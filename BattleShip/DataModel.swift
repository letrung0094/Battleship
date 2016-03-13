//
//  GameModel.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

//Contains the data model to keep track of games
import Foundation
import UIKit

class GameCollection{
    var listOfActiveGames = [Int: Game]()
    
    var gamesCount: Int{
        return listOfActiveGames.count
    }
    
    func addGame(newGame: Game){
        listOfActiveGames[newGame.gameID] = newGame
    }
    
    func removeGame(gameID: Int){
        listOfActiveGames.removeValueForKey(gameID)
    }
    
    func accessGame(gameID: Int) -> Game{
        let gameToReturn = listOfActiveGames[gameID]
        return gameToReturn!
    }
    
    func updateGameState(gameID: Int){
        
    }
}

class Game{
    
    //0 = player 1 turn, 1 = player 2 turn
    var turn: Int!
    var gameID: Int!
    var player1Ships = [Int: Ship]()
    var player2Ships = [Int: Ship]()
    var numberOfGridColumns = 6
    var numberOfGridRows = 6
    
    func createBattleField(){
        turn = 0
    }
    
    func shootAt(x: Int, y: Int){

    }
    
    func didHit() -> Bool{
        return true
    }
    
    func removeShip(shipIDToRemove: Int){
        //Currently player 1 turn
        if turn == 0{
            player2Ships.removeValueForKey(shipIDToRemove)
        }
        //Player 2 turn
        else{
            player1Ships.removeValueForKey(shipIDToRemove)
        }
    }
    
    func addNewShip(newShip: Ship){
        if turn == 0{
            player1Ships[newShip.shipID] = newShip
        }
        else{
            player2Ships[newShip.shipID] = newShip
        }
    }
    
    func reportWin(){
        if player2Ships.isEmpty{
            //send message that player 1 won
        }
        else if player1Ships.isEmpty{
            //send message that player 2 won
        }
    }
    
    func switchTurn(){
        if turn == 0{
            turn = 1
        }
        else{
            turn = 0
        }
    }
}

class Ship{
    
    var shipID: Int!
    var positionX: Int!
    var positionY: Int!
    var shipSize: Int!
    
    func updateShipID(id: Int){
        shipID = id
    }
    
    func updatePosition(x: Int, y: Int){
        positionX = x
        positionY = y
    }
}

class Player1Grid: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "Player1Ships")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

class Player2Grid: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "Player2Ships")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

class Grid: UIView{
    
    var positionX: Int = 0
    var positionY: Int = 0
    
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        drawWater()
    }
    
    func drawWater(){
        UIImage(named: "Water")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    func updatePosition(newX: Int, newY: Int){
        positionX = newX
        positionY = newY
    }
}












