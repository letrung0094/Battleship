//
//  GameViewController.swift
//  BattleShip
//
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation
import UIKit

protocol GameViewDelegate: class{
    func collection(collection: GameViewController, getGame game: Game)
}

class GameViewController: UIViewController, GameDelegate{
    
    var currentGame: Game!
    var numberOfColumns: Int = 5
    var numberOfRows: Int = 5
    var field: BattleField!
    var newGameID: Int!
    var label: UILabel!
    
    weak var delegate: GameViewDelegate?
    
    override func loadView(){
        view = UIView()
    }
    
    func collection(collection: Game, shipSunk sunk: Int){
        //0 = miss
        //1 = hit
        //2 = hit and sunk
        if sunk == 0 {
            field.message = "Miss!"
        }
        else if sunk == 1{
            field.message = "Hit!"

        }
        else if sunk == 2{
            field.message = "Hit and Ship Sunk!"
        }
        
    }

    //Set up view
    override func viewDidLoad(){
        self.title = "Battlefield"
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Force landscape orientation
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        if currentGame == nil {
            createNewGame(newGameID)
        }
        createField()
        label = UILabel(frame: CGRect(x: 250, y: 280,  width: 200.0, height: 20.0))
        label.hidden = true
        view.addSubview(label)

    }
    
    //Set ID for game
    func setPotentialID(newID: Int){
        newGameID = newID
    }
    
    //Create the field and load in a previous game
    func createField(){
        field = BattleField(frame: CGRectMake(20, 50, 520, 240))
        field.loadGame(currentGame)
        field.backgroundColor = UIColor.brownColor()
        view.addSubview(field)
    }
    
    //Call delegate to add to table view data source
    override func viewDidDisappear(animated: Bool) {
        print("Leaving game view")
        currentGame = field.getGameStatus()
        delegate?.collection(self, getGame: currentGame)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    //Load in an old game
    func loadGame(oldGame: Game){
        currentGame = oldGame
    }
    
    //Creates a brand new game
    func createNewGame(newGameID: Int){
        currentGame = Game()
        currentGame.gameID = newGameID
        currentGame.createBattleField()
        currentGame.turn = 0
        currentGame.delegate = self
    }
    
}
