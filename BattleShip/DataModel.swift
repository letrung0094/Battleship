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

class GameCollection: NSObject, NSCoding{
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(listOfActiveGames, forKey: "gamesList")
    }
    
    required init?(coder aDecoder: NSCoder) {
        listOfActiveGames = aDecoder.decodeObjectOfClass(NSArray.self, forKey: "gamesList") as! [Game]
    }
    
    var gameCollectionName: String?
    
    var listOfActiveGames = [Game]()
    
    var gamesCount: Int{
        return listOfActiveGames.count
    }
    
    func addGame(newGame: Game){
        listOfActiveGames.append(newGame)
    }
    
    func removeGame(gameID: Int){
        listOfActiveGames.removeAtIndex(gameID)
    }
    
    func accessGame(gameID: Int) -> Game{
        let gameToReturn = listOfActiveGames[gameID]
        return gameToReturn
    }
    
    func updateGameState(gameID: Int){
        
    }
}

class Game: NSObject, NSCoding{
    
    //0 = player 1 turn, 1 = player 2 turn
    var turn: Int!
    var gameID: Int!
    var player1Ships = [Ship]()
    var player2Ships = [Ship]()
    var numberOfGridColumns = 6
    var numberOfGridRows = 6
    var gameEnded: Bool = false
    var gameWinner = 3 //cause encoder does not like nil
    var player1DeadShips = [Ship]()
    var player2DeadShips = [Ship]()
    var DestroyedPlayer1Tiles = [Ship]()
    var DestroyedPlayer2Tiles = [Ship]()
    var shipPositionsPlayer1 = [Coordinates]()
    var shipPositionsPlayer2 = [Coordinates]()
    
    func createBattleField(){
        turn = 0
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(listOfActiveGames, forKey: "gamesList")
        aCoder.encodeInteger(turn, forKey: "Turn")
        aCoder.encodeInteger(gameID, forKey: "GameID")
        aCoder.encodeBool(gameEnded, forKey: "GameEnded")
        aCoder.encodeInteger(gameWinner, forKey: "GameWinner")
        aCoder.encodeObject(player1Ships, forKey: "Player1Ships")
        aCoder.encodeObject(player2Ships, forKey: "Player2Ships")
        aCoder.encodeObject(player1DeadShips, forKey: "Player1DeadShips")
        aCoder.encodeObject(player1DeadShips, forKey: "Player2DeadShips")
        aCoder.encodeObject(DestroyedPlayer1Tiles, forKey: "DestroyedPlayer1Tiles")
        aCoder.encodeObject(DestroyedPlayer2Tiles, forKey: "DestroyedPlayer2Tiles")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //listOfActiveGames = aDecoder.decodeObjectOfClass(NSArray.self, forKey: "gamesList") as! [Game]
        turn = aDecoder.decodeIntegerForKey("Turn")
        gameID = aDecoder.decodeIntegerForKey("GameID")
        gameEnded = aDecoder.decodeBoolForKey("GameEnded")
        gameWinner = aDecoder.decodeIntegerForKey("GameWinner")
        player1Ships = aDecoder.decodeObjectForKey("Player1Ships") as! [Ship]
        player2Ships = aDecoder.decodeObjectForKey("Player2Ships") as! [Ship]
        player1DeadShips = aDecoder.decodeObjectForKey("Player1DeadShips") as! [Ship]
        player2DeadShips = aDecoder.decodeObjectForKey("Player2DeadShips") as! [Ship]
        DestroyedPlayer1Tiles = aDecoder.decodeObjectForKey("DestroyedPlayer1Tiles") as! [Ship]
        DestroyedPlayer2Tiles = aDecoder.decodeObjectForKey("DestroyedPlayer2Tiles") as! [Ship]
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
            let missShot = Ship()
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
            let missShot = Ship()
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
class Ship: NSObject, NSCoding{
    var positionX: Int!
    var positionY: Int!
    var shipID = 999999
    var shipSize = 1
    
    func updateShipID(id: Int){
        shipID = id
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(positionX, forKey: "X")
        aCoder.encodeInteger(positionY, forKey: "Y")
        aCoder.encodeInteger(shipID, forKey: "ShipID")
        aCoder.encodeInteger(shipSize, forKey: "ShipSize")
    }
    
    required init?(coder aDecoder: NSCoder) {
        positionX = aDecoder.decodeIntegerForKey("X")
        positionY = aDecoder.decodeIntegerForKey("Y")
        shipID = aDecoder.decodeIntegerForKey("ShipID")
        shipSize = aDecoder.decodeIntegerForKey("ShipSize")
    }
    
    func updatePosition(x: Int, y: Int){
        positionX = x
        positionY = y
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












