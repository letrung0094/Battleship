//
//  GameViewController.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

class GameViewController: UIViewController{
    
    var currentGame: Game!
    var numberOfColumns: Int = 5
    var numberOfRows: Int = 5
    var field: BattleField!
    
    override func loadView(){
        view = UIView()
    }
    
    override func viewDidLoad(){
        self.title = "Battlefield"
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Force landscape orientation
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        if currentGame == nil {
            createNewGame(1)
        }
        createField()
    }
    
    func createField(){
        field = BattleField(frame: CGRectMake(20, 50, 520, 250))
        field.loadGame(currentGame)
        field.backgroundColor = UIColor.brownColor()
        view.addSubview(field)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func loadGame(oldGame: Game){
        currentGame = oldGame
    }
    
    func createNewGame(newGameID: Int){
        currentGame = Game()
        currentGame.gameID = newGameID
        currentGame.createRandomPlayer1Ships()
        currentGame.createRandomPlayer2Ships()
        currentGame.createBattleField()
    }
    
}
