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

//CLASSES FOR NETWORK BATTLESHIP

class Player: NSObject, NSCoding{
    var playerName: String!
    var playerID: String!
    
    override init() {
        super.init()
    }
    
    //Encode data
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(playerName, forKey: "playerName")
        aCoder.encodeObject(playerID, forKey: "playerID")
    }
    
    //Decode data
    required init?(coder aDecoder: NSCoder) {
        playerName = aDecoder.decodeObjectForKey("playerName") as! String
        playerID = aDecoder.decodeObjectForKey("playerID") as! String
    }
    
}

class gameInfoCollection {
    var listOfActiveGames = [GameInfo]()
    
    var gamesCount: Int{
        return listOfActiveGames.count
    }
    
    func addGame(newGame: GameInfo){
        listOfActiveGames.append(newGame)
    }
    
    func accessGame(gameID: Int) -> GameInfo{
        let gameToReturn = listOfActiveGames[gameID]
        return gameToReturn
    }
}

//Used to model pixio API
class GameInfo {
    var name: String!
    var id: String!
    var status: String!
    
    
    func setGameVariables(n: String, i: String, s: String){
        name = n
        id = i
        status = s
    }
}












//CLASSES FOR LOCAl BATTLESHIP BELOW

class GameCollection: NSObject, NSCoding{
    
    override init() {
        super.init()
    }
    
    //Encode games
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(listOfActiveGames, forKey: "gamesList")
    }
    
    //Called to decode data into game object
    required init?(coder aDecoder: NSCoder) {
        listOfActiveGames = aDecoder.decodeObjectOfClass(NSArray.self, forKey: "gamesList") as! [Game]
    }
    
    var gameCollectionName: String?
    
    var listOfActiveGames = [Game]()
    
    var gamesCount: Int{
        return listOfActiveGames.count
    }
    
    func addGame(newGame: Game){
        
        //If new game, append
        if checkID(newGame.gameID){
            listOfActiveGames.append(newGame)
        }
        //Else update old game
        else{
            listOfActiveGames[newGame.gameID] = newGame
        }
    }
    
    func removeGame(gameID: Int){
        listOfActiveGames.removeAtIndex(gameID)
    }
    
    func accessGame(gameID: Int) -> Game{
        let gameToReturn = listOfActiveGames[gameID]
        return gameToReturn
    }
    
    //Returns true if game is new, false if game already exists
    func checkID(id:Int) -> Bool{
        for var i = 0; i < listOfActiveGames.count; i++ {
            let temp = listOfActiveGames[i]
            if temp.gameID == id{
                return false
            }
        }
        return true
    }
}


protocol GameDelegate: class{
    func collection(collection: Game, shipSunk sunk: Int)
}

class Game: NSObject, NSCoding{
    
    //0 = player 1 turn, 1 = player 2 turn
    var turn: Int!
    var gameID: Int!
    var player1Ships = [Ship]()
    var player2Ships = [Ship]()
    var numberOfGridColumns = 8
    var numberOfGridRows = 8
    var gameEnded: Bool = false
    var gameWinner = 3 //cause encoder does not like nil
    var player1DeadShips = [Ship]()
    var player2DeadShips = [Ship]()
    var DestroyedPlayer1Tiles = [Ship]()
    var DestroyedPlayer2Tiles = [Ship]()
    var shipPositionsPlayer1 = [Coordinates]()
    var shipPositionsPlayer2 = [Coordinates]()
    
    weak var delegate: GameDelegate?
    
    func createBattleField(){
        turn = 0
//        //Create ships for player 1
//        createShipSize2(0)
//        createShipSize3(0)
//        createShipSize3(0)
//        createShipSize4(0)
//        createShipSize5(0)
//        
//        //Create ships for player 2
//        createShipSize2(1)
//        createShipSize3(1)
//        createShipSize3(1)
//        createShipSize4(1)
//        createShipSize5(1)
    }
    
    override init() {
        super.init()
    }
    
    
    //Encode data
    func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(listOfActiveGames, forKey: "gamesList")
        aCoder.encodeInteger(turn, forKey: "Turn")
        aCoder.encodeInteger(gameID, forKey: "GameID")
        aCoder.encodeBool(gameEnded, forKey: "GameEnded")
        aCoder.encodeInteger(gameWinner, forKey: "GameWinner")
        aCoder.encodeObject(player1Ships, forKey: "Player1Ships")
        aCoder.encodeObject(player2Ships, forKey: "Player2Ships")
        aCoder.encodeObject(player1DeadShips, forKey: "Player1DeadShips")
        aCoder.encodeObject(player2DeadShips, forKey: "Player2DeadShips")
        aCoder.encodeObject(DestroyedPlayer1Tiles, forKey: "DestroyedPlayer1Tiles")
        aCoder.encodeObject(DestroyedPlayer2Tiles, forKey: "DestroyedPlayer2Tiles")
    }
    
    //Decode data
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
            let X = x - 1
            for var i = 0; i < player2Ships.count; i++ {
                let temp = player2Ships[i]
                
                //Check if any portion of a ship is hit
                for var j = 0; j < temp.shipSize; j++ {
                    if (temp.positionX + j == X % 8 && temp.positionY == y % 8){
                        //If hit, decrement the hit points
                        player2Ships[i].life--
                        
                        //When hit points = 0 remove ship from game and append to destroyed ships
                        if player2Ships[i].life == 0{
                            player2DeadShips.append(temp)
                            player2Ships.removeAtIndex(i)
                            delegate?.collection(self, shipSunk: 2)
                            switchTurn()
                            return didHit()
                        }
                        
                        delegate?.collection(self, shipSunk: 1)
                        switchTurn()
                        return didHit()
                    }
                    
                }
            }
            //If no hit, add shot to missed shots
            let missShot = Ship()
            missShot.updatePosition(X, y: y)
            DestroyedPlayer2Tiles.append(missShot)
            switchTurn()
            delegate?.collection(self, shipSunk: 0)
            return false
        }
        else{
            for var i = 0; i < player1Ships.count; i++ {
                let temp = player1Ships[i]
                for var j = 0; j < temp.shipSize; j++ {
                    if (temp.positionX + j == x && temp.positionY == y){
                        player1Ships[i].life--
                        if player1Ships[i].life == 0{
                            player1DeadShips.append(temp)
                            player1Ships.removeAtIndex(i)
                            delegate?.collection(self, shipSunk: 2)
                            switchTurn()
                            return didHit()
                        }
                        
                        delegate?.collection(self, shipSunk: 1)
                        switchTurn()
                        return didHit()
                        
                    }
                }
            }
            let missShot = Ship()
            missShot.updatePosition(x, y: y)
            DestroyedPlayer1Tiles.append(missShot)
            switchTurn()
            delegate?.collection(self, shipSunk: 0)
            return false
        }
        
    }
    
    
    //Return true if hit...
    func didHit() -> Bool{
        return true
    }
    
    //Creates a ship of size 2
    func createShipSize2(forPlayer: Int){
        var coor2 = Coordinates()
        var coordinantes = Coordinates()
        //0 = player 1
        if forPlayer == 0{
            turn = 0
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(7)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor2.positionY = ship.positionY
            }
            while(validPosition1(coordinantes) == false || validPosition1(coor2) == false)
            ship.shipID = generateID()
            ship.life = 2
            ship.shipSize = 2
            shipPositionsPlayer1.append(coordinantes)
            shipPositionsPlayer1.append(coor2)
            addNewShip(ship)
            
        }
        //1 = player 2
        else{
            turn = 1
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(7)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor2.positionY = ship.positionY
            }
            while(validPosition2(coordinantes) == false || validPosition2(coor2) == false)
            ship.shipID = generateID()
            ship.life = 2
            ship.shipSize = 2
            shipPositionsPlayer2.append(coordinantes)
            shipPositionsPlayer2.append(coor2)
            addNewShip(ship)
        }
    }
    
    //Creates ship of size 3
    func createShipSize3(forPlayer: Int){
        var coor2 = Coordinates()
        var coor3 = Coordinates()
        var coordinantes = Coordinates()
        if forPlayer == 0{
            turn = 0
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(6)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
            }
            while(validPosition1(coordinantes) == false || validPosition1(coor2) == false || validPosition1(coor3) == false)
            ship.shipID = generateID()
            ship.life = 3
            ship.shipSize = 3
            shipPositionsPlayer1.append(coordinantes)
            shipPositionsPlayer1.append(coor2)
            shipPositionsPlayer1.append(coor3)
            addNewShip(ship)
        }
        else{
            turn = 1
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(6)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
            }
            while(validPosition2(coordinantes) == false || validPosition2(coor2) == false || validPosition2(coor3) == false)
            ship.shipID = generateID()
            ship.life = 3
            ship.shipSize = 3
            shipPositionsPlayer2.append(coordinantes)
            shipPositionsPlayer2.append(coor2)
            shipPositionsPlayer2.append(coor3)
            addNewShip(ship)
        }
    }
    
    //Create ship of size 4
    func createShipSize4(forPlayer: Int){
        var coor4 = Coordinates()
        var coor2 = Coordinates()
        var coor3 = Coordinates()
        var coordinantes = Coordinates()
        if forPlayer == 0{
            turn = 0
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(5)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor4.positionX = ship.positionX + 3
                coor4.positionY = ship.positionY
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
            }
            while(validPosition1(coordinantes) == false || validPosition1(coor2) == false || validPosition1(coor3) == false || validPosition1(coor4) == false)
            ship.shipID = generateID()
            ship.life = 4
            ship.shipSize = 4
            shipPositionsPlayer1.append(coordinantes)
            shipPositionsPlayer1.append(coor2)
            shipPositionsPlayer1.append(coor3)
            shipPositionsPlayer1.append(coor4)
            addNewShip(ship)
            
        }
        else{
            turn = 1
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(5)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor4.positionX = ship.positionX + 3
                coor4.positionY = ship.positionY
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
            }
            while(validPosition2(coordinantes) == false || validPosition2(coor2) == false || validPosition2(coor3) == false || validPosition2(coor4) == false)
            ship.shipID = generateID()
            ship.life = 4
            ship.shipSize = 4
            shipPositionsPlayer2.append(coordinantes)
            shipPositionsPlayer2.append(coor2)
            shipPositionsPlayer2.append(coor3)
            shipPositionsPlayer2.append(coor4)
            addNewShip(ship)
        }
    }
    
    //Create ship of size 5
    func createShipSize5(forPlayer: Int){
        var coor5 = Coordinates()
        var coor4 = Coordinates()
        var coor2 = Coordinates()
        var coor3 = Coordinates()
        var coordinantes = Coordinates()
        if forPlayer == 0{
            turn = 0
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(4)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor4.positionX = ship.positionX + 3
                coor5.positionX = ship.positionX + 4
                coor5.positionY = ship.positionY
                coor4.positionY = ship.positionY
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
            }
            while(validPosition1(coordinantes) == false || validPosition1(coor2) == false || validPosition1(coor3) == false || validPosition1(coor4) == false || validPosition1(coor5) == false)
            ship.shipID = generateID()
            ship.life = 5
            ship.shipSize = 5
            shipPositionsPlayer1.append(coordinantes)
            shipPositionsPlayer1.append(coor2)
            shipPositionsPlayer1.append(coor3)
            shipPositionsPlayer1.append(coor4)
            shipPositionsPlayer1.append(coor5)
            addNewShip(ship)
            
        }
        else{
            turn = 1
            let ship = Ship()
            repeat{
                ship.updatePosition(Int(arc4random_uniform(4)), y: Int(arc4random_uniform(8)))
                coordinantes.positionX = ship.positionX
                coordinantes.positionY = ship.positionY
                coor2.positionX = ship.positionX + 1
                coor3.positionX = ship.positionX + 2
                coor4.positionX = ship.positionX + 3
                coor4.positionY = ship.positionY
                coor3.positionY = ship.positionY
                coor2.positionY = ship.positionY
                coor5.positionX = ship.positionX + 4
                coor5.positionY = ship.positionY
            }
            while(validPosition2(coordinantes) == false || validPosition2(coor2) == false || validPosition2(coor3) == false || validPosition2(coor4) == false || validPosition2(coor5) == false)
            ship.shipID = generateID()
            ship.life = 5
            ship.shipSize = 5
            shipPositionsPlayer2.append(coordinantes)
            shipPositionsPlayer2.append(coor2)
            shipPositionsPlayer2.append(coor3)
            shipPositionsPlayer2.append(coor4)
            shipPositionsPlayer2.append(coor5)
            addNewShip(ship)
        }
    }
    
    //Check for valid position
    func validPosition1(coord: Coordinates)->Bool{
        for var i = 0; i < shipPositionsPlayer1.count; i++ {
            let temp = shipPositionsPlayer1[i]
            if temp.positionX == coord.positionX && temp.positionY == coord.positionY{
                print("Invalid location 1")
                return false
            }
        }
        return true
    }
    
    //If coordinate location already exists, return false
    func validPosition2(coord: Coordinates)->Bool{
        for var i = 0; i < shipPositionsPlayer2.count; i++ {
            let temp = shipPositionsPlayer2[i]
            if temp.positionX == coord.positionX && temp.positionY == coord.positionY{
                print("Invalid location 2")
                return false
            }
            
        }
        return true
    }
    
    //Generate a random unique id
    func generateID() -> Int{
        var temp = Int(arc4random_uniform(UInt32.max))
        var check: Bool
        repeat{
            temp = Int(arc4random_uniform(UInt32.max))
            check = true
            for var i = 0; i < player1Ships.count; i++ {
                let ship = player1Ships[i]
                if temp == ship.shipID{
                    check = false
                }
            for var i = 0; i < player2Ships.count; i++ {
                let ship = player2Ships[i]
                if temp == ship.shipID{
                    check = false
                }
            }
        }
        }while check == false
        
        return temp
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
    var life = 0
    var shipSize = 1
    
    func updateShipID(id: Int){
        shipID = id
    }
    
    override init() {
        super.init()
    }
    
    //Encode data
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(positionX, forKey: "X")
        aCoder.encodeInteger(positionY, forKey: "Y")
        aCoder.encodeInteger(shipID, forKey: "ShipID")
        aCoder.encodeInteger(shipSize, forKey: "ShipSize")
    }
    
    //Decode data
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
class ShipEnd: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipEnd1")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 2 ship graphics grid
class ShipMid: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipMid")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 1 ship destroyed graphics grid
class ShipEnd2: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipEnd2")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 2 ship destroyed graphics grid
class ShipEnd1Destroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipEnd1Fire")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 2 ship destroyed graphics grid
class ShipMidDestroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipMidFire")?.drawInRect(self.bounds)
        UIGraphicsBeginImageContext(self.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
}

//Player 2 ship destroyed graphics grid
class ShipEnd2Destroyed: Grid{
    override func drawRect(rect:CGRect){
        super.drawRect(rect)
        
        UIImage(named: "ShipEnd2Fire")?.drawInRect(self.bounds)
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












