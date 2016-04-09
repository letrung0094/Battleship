//
//  AppDelegate.swift
//  BattleShip
//  Project 3
//  Created by Trung Le on 3/12/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GameViewDelegate, networkDelegate {

    var window: UIWindow?
    var gameListcontroller: GameListViewController!
    var navBar: UINavigationController!
    let nw = Network()
    var currentPlayer: Player!
    var alert: UIAlertController!
    let color = UIColor(red: 38.0/255.0, green: 191.0/255.0, blue: 199.0/255.0, alpha: 1.0)
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Reload data if there is any
        gameListcontroller = GameListViewController()
        gameListcontroller.title = "List Of Games"
        
        navBar = UINavigationController(rootViewController: gameListcontroller)
        navBar.navigationBar.barTintColor = color
        navBar.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newGame")
        gameListcontroller.navigationItem.rightBarButtonItem = rightButton
        navBar.navigationBar.tintColor = UIColor.whiteColor()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navBar
        
        
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("playerName") as? NSData {
            let player = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Player
            currentPlayer = player
            gameListcontroller.currentPlayer = player
        }
        else{
            createAlert()
        }
        
    
        
  
        return true
    }
    

    func newGame(id: String, gameId: String, playerId: String){
        print("Got back to new game delegate")
        let game = GameInfo()
        game.id = gameId
        currentPlayer.playerID = playerId
        
        let gamecontroller: GameViewController = GameViewController()
        gamecontroller.delegate = self
        gamecontroller.loadGame(game, player: currentPlayer)
        navBar?.pushViewController(gamecontroller, animated: true)
    }

    
    func newGame(){
        print("Creating a new game")
        nw.createNewGame(self, playerName: currentPlayer.playerName)
    }
    
    func createAlert(){
        alert = UIAlertController(title: "BattleShip!!!", message: "User name:", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Alexa"
        })
        
        
        //Get player name
        //3. Grab the value from the text field, and print it when the user clicks OK.
        if currentPlayer == nil{
            currentPlayer = Player()
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                let textField = self.alert.textFields![0] as UITextField
                print("Text field->>>>: \(textField.text) dasfas")
                self.currentPlayer.playerName = textField.text
                self.gameListcontroller.currentPlayer.playerName = textField.text
            }))
        }
        // 4. Present the alert.
    
        navBar.presentViewController(alert, animated: true, completion: nil)
    }
    
    func collection(collection: GameViewController, getGame game: Game) {
        print("Game received in app delegate")
        //gameListcontroller.addOrUpdateGame(game)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let player = gameListcontroller.currentPlayer
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(player), forKey: "playerName")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }


}

