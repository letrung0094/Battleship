//
//  GameListViewController.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

class GameListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var gameList: GameCollection = GameCollection()
    
    var gameListView: UITableView{
        return view as! UITableView
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
        
        let tempGame = Game()
        tempGame.gameID = 0
        tempGame.createRandomPlayer1Ships()
        tempGame.createRandomPlayer2Ships()
        tempGame.createBattleField()
        gameList.addGame(tempGame)
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
        cell.textLabel?.text = "Game \(indexPath.section)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.section)
        
        let game = gameList.accessGame(indexPath.section)
        let newGameScreen = GameViewController()
        newGameScreen.loadGame(game)
        navigationController?.pushViewController(newGameScreen, animated: true)
    }
  
    
}