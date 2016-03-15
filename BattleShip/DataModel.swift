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
    var player1Ships = [Ship]()
    var player2Ships = [Ship]()
    var numberOfGridColumns = 6
    var numberOfGridRows = 6
    var gameEnded: Bool = false
    var gameWinner: Int!
    var player1DeadShips = [Ship]()
    var player2DeadShips = [Ship]()
    var DestroyedPlayer1Tiles = [Tile]()
    var DestroyedPlayer2Tiles = [Tile]()
    var shipPositionsPlayer1 = [Coordinates]()
    var shipPositionsPlayer2 = [Coordinates]()
    
    func createBattleField(){
        turn = 0
    }
    
    //Attempt to shoot at a tile
    //Update a missed shot or a destroyed ship and append to appropriate data structure
    func shootAt(x: Int, y: Int) -> Bool{
        if turn == 0{
            for var i = 0; i < player2Ships.count; i++ {
                let temp = player2Ships[i]
                if temp.positionX == x % 5 && temp.positionY == y % 5{
                    player2DeadShips.append(temp)
                    player2Ships.removeAtIndex(i)
                    switchTurn()
                    return didHit()
                }
            }
            let missShot = Tile()
            missShot.updatePosition(x, y: y)
            DestroyedPlayer2Tiles.append(missShot)
            switchTurn()
            return false
        }
        else{
            for var i = 0; i < player1Ships.count; i++ {
                let temp = player1Ships[i]
                if temp.positionX == x && temp.positionY == y{
                    player1DeadShips.append(temp)
                    player1Ships.removeAtIndex(i)
                    switchTurn()
                    return didHit()
                }
            }
            let missShot = Tile()
            missShot.updatePosition(x, y: y)
            DestroyedPlayer1Tiles.append(missShot)
            switchTurn()
            return false
        }
        
    }
    
    
    //Return true if hit...
    func didHit() -> Bool{
        return true
    }
    
    //Create random ship locations
    func createRandomPlayer1Ships(){
        turn = 0
        var coordinantes: Coordinates = Coordinates()
        for var i = 0; i < 5; i++ {
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(5)), y: Int(arc4random_uniform(5)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
            }
            while(validPosition1(coordinantes) == false)
            ship.shipID = i
            ship.shipSize = 1
            ship.updateShipID(i+10)
            addNewShip(ship)
        }
    }
    
    func createRandomPlayer2Ships(){
        turn = 1
        var coordinantes: Coordinates = Coordinates()
        for var i = 0; i < 5; i++ {
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(5)), y: Int(arc4random_uniform(5)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
            }
                while(validPosition2(coordinantes) == false)
            ship.shipID = i
            ship.shipSize = 1
            ship.updateShipID(i+20)
            addNewShip(ship)
        }
    }
    
    //Check for valid position
    func validPosition1(coord: Coordinates)->Bool{
        for var i = 0; i < shipPositionsPlayer1.count; i++ {
            let coordToCheck = shipPositionsPlayer1[i]
            if coord.positionX == coordToCheck.positionX && coord.positionY == coordToCheck.positionY {
                return false
            }
        }
        return true
    }
    
    func validPosition2(coord: Coordinates)->Bool{
        for var i = 0; i < shipPositionsPlayer2.count; i++ {
            let coordToCheck = shipPositionsPlayer2[i]
            if coord.positionX == coordToCheck.positionX && coord.positionY == coordToCheck.positionY {
                return false
            }
        }
        return true
    }
    
    //Add a new ship
    func addNewShip(newShip: Ship){
        if turn == 0{
            player1Ships.append(newShip)
        }
        else{
            player2Ships.append(newShip)
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

//Tuple to keep track of coordinates
struct Coordinates{
    var positionX: Int!
    var positionY: Int!
}

//Default tile
class Tile{
    var positionX: Int!
    var positionY: Int!
    
    func updatePosition(x: Int, y: Int){
        positionX = x
        positionY = y
    }
}

//Ship tile
class Ship: Tile{
    var shipID: Int!
    var shipSize: Int!
    
    func updateShipID(id: Int){
        shipID = id
    }
}

//Player1 ship graphics grid
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

//Player 2 ship graphics grid
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

//Player 1 ship destroyed graphics grid
class Player1GridDestroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "Player1ShipOnFire")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 2 ship destroyed graphics grid
class Player2GridDestroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "Player2ShipOnFire")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Water tile destroyed graphics grid
class WaterDestroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "WaterOnFire")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Default grid is water
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












