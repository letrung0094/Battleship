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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.gamesCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
  
    
}