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
    
    override func loadView(){
        view = UIView()
    }
    
    override func viewDidLoad(){
        self.title = "Battlefield"
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Force landscape orientation
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func loadGame(oldGame: Game){
        
    }
    
    func createNewGame(newGameID: Int){
        currentGame = Game()
        currentGame.gameID = newGameID
    }
    
    
    
    
    
}
