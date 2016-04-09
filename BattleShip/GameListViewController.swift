//
//  GameListViewController.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

protocol getGamesDelegate: class{
    func getGameList(gameData: gameInfoCollection)
    func receivePlayerID(id: String, success: Bool)
}

class GameListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GameViewDelegate, getGamesDelegate {
    
    var succeed = false
    var gameToJoin: GameInfo!
    var gameList: gameInfoCollection = gameInfoCollection()
    var nw = Network()
    var alert: UIAlertController!
    var currentPlayer = Player()
    var gameListView: UITableView{
        return view as! UITableView
    }
    

    func receivePlayerID(id: String, success: Bool) {
        currentPlayer.playerID = id
        
        if success{
            let newGameScreen = GameViewController()
            newGameScreen.delegate = self
            newGameScreen.loadGame(gameToJoin, player: currentPlayer)
            navigationController?.pushViewController(newGameScreen, animated: true)
        }
        else{
            let alert = UIAlertController(title: "Error!", message: "You do not belong in this game!", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("OK Pressed")
            }
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func getGameList(gameData: gameInfoCollection){
        print("returned to deleggate")
        gameList = gameData
        print("Games Count in table view: \(gameList.gamesCount)")
        gameListView.reloadData()
    }
    
    override func loadView(){
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        view.backgroundColor = UIColor.whiteColor()
        
        //retrieve games from server
        nw.getGamesFromServer(self)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.gameListView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        gameListView.dataSource = self
        gameListView.delegate = self
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")

        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.gamesCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self))!
        let game = gameList.accessGame(indexPath.row)
        
        if game.status == "DONE"{
            cell.textLabel?.text = "Game: \(game.name)"
            cell.backgroundColor = UIColor.redColor()
            
        }
        else if game.status == "PLAYING"{
            cell.textLabel?.text = "Game: \(game.name)"
            let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)

            cell.backgroundColor = color
        }
        else if game.status == "WAITING"{
            cell.textLabel?.text = "Game: \(game.name)"
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.section)
        
        let game = gameList.accessGame(indexPath.row)
        gameToJoin = game
        print("pressed \(game.name) + id: \(game.id)")
        let playerName = currentPlayer.playerName
        
        //check if player belong to game
        nw.attemptToJoin(self, gameID: game.id, playerName: playerName)
        
       
    }
}