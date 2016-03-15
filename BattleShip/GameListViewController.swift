//
//  GameListViewController.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

class GameListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GameViewDelegate {
    
    var gameList: GameCollection = GameCollection()
    var navBar: UINavigationController!
    
    var gameListView: UITableView{
        return view as! UITableView
    }
    
    func collection(collection: GameViewController, getGame game: Game){
        print("Game received to save")
        addOrUpdateGame(game)
    }
    
    func addOrUpdateGame(gameToSave: Game){
        gameList.addGame(gameToSave)
        gameListView.reloadData()
    }
    
    override func loadView(){
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        view.backgroundColor = UIColor.whiteColor()
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
        
        if game.gameEnded == true{
            if game.gameWinner == 0{
                cell.textLabel?.text = "Game \(indexPath.row) - Player 1 wins with Score: \(game.player1Ships.count) : \(game.player2Ships.count)"
                cell.backgroundColor = UIColor.redColor()
            }
            else{
                cell.textLabel?.text = "Game \(indexPath.row) - Player 2 wins with Score: \(game.player1Ships.count) : \(game.player2Ships.count)"
                cell.backgroundColor = UIColor.redColor()
            }
        }
        else{
            if game.turn == 0{
                cell.textLabel?.text = "Game \(indexPath.row) - Player 1 turn - Score: \(game.player1Ships.count) : \(game.player2Ships.count)"
            }
            else{
                cell.textLabel?.text = "Game \(indexPath.row) - Player 2 turn - Score: \(game.player1Ships.count) : \(game.player2Ships.count)"
            }
        }
   
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.section)
        
        let game = gameList.accessGame(indexPath.row)
        let newGameScreen = GameViewController()
        newGameScreen.delegate = self
        newGameScreen.loadGame(game)
        navigationController?.pushViewController(newGameScreen, animated: true)
    }
    
    
  
    
}