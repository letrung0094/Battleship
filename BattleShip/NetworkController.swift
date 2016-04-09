//
//  NetworkController.swift
//  BattleShip
//
//  Created by Trung Le on 3/27/16.
//  Copyright © 2016 Trung Le. All rights reserved.
//

import Foundation

protocol networkDelegate: class{
    func newGame(id: String, gameId: String, playerId: String)
}

class Network{
    
    func getGamesFromServer(delegate: getGamesDelegate){
        
        let gamesList = gameInfoCollection()
        
        //Get games from server
        let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games")!
        let request = NSMutableURLRequest(URL: battleshipURL)
        request.HTTPMethod = "GET"
    
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error)  in
            guard let httpResponse = response as?
                NSHTTPURLResponse else {
                    return
            }
            
            if httpResponse.statusCode == 400 || httpResponse.statusCode == 500{
                return
            }
            
            let gameData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
            
            guard let gameDataArray = gameData as? [AnyObject] else{
                return
            }
            
            //Parse JSON data into game info
            for gameinfo in gameDataArray{
                guard let actualgamedata = gameinfo as? [String: String] else{
                    continue
                }
                
                let newgame: GameInfo = GameInfo()
                newgame.name = actualgamedata["name"]
                newgame.status = actualgamedata["status"]
                newgame.id = actualgamedata["id"]
                
                print("parsed \(newgame.name)")
                
                gamesList.addGame(newgame)
                
            }
            print("Game Count: \(gamesList.gamesCount)")
            
            //pass game back to GameListViewController
            delegate.getGameList(gamesList)
        }
        dataTask.resume()
    
    }
    
    
    
    //playerID: NSUUID, boardID: NSUUID
    func getBoardForPlayer(delegate: GiveBoardDelegate, gameID: String, playerID: String){
        //let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games/" + boardID.UUIDString + "/board")!
        let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games/\(gameID)/board")!
        let t = "http://battleship.pixio.com/api/games/\(gameID)/board"
        let request = NSMutableURLRequest(URL: battleshipURL)
        print(t)
        request.HTTPMethod = "POST"
        //3be2e411-0086-46fd-8fc9-38d11831d0fb
        
        let newPost: NSDictionary = ["playerId": playerID]
        let jsonPost = try? NSJSONSerialization.dataWithJSONObject(newPost, options: [])
        
        request.HTTPBody = jsonPost
        
        request.allHTTPHeaderFields!["content-type"] = "application/json"
        
        let queue: NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse?,responseMessage: NSData?, error: NSError?) -> Void in NSOperationQueue.mainQueue().addOperationWithBlock(
                {
                    if(responseMessage == nil)
                    {
                        print("No Data")
                    }
                    else
                    {
                        let gameData: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(responseMessage!, options: NSJSONReadingOptions()) as! NSDictionary
                        
                        
                        delegate.givePlayerBoard(gameData);
                    }
                    
                })
            })
    }
    
    func createNewGame(delegate: networkDelegate, playerName: String)
    {
        let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games/")!
        let request = NSMutableURLRequest(URL: battleshipURL)
        request.HTTPMethod = "POST"
        //3be2e411-0086-46fd-8fc9-38d11831d0fb
        
        let newPost: NSDictionary = ["gameName": "Duckies", "playerName": playerName]
        let jsonPost = try? NSJSONSerialization.dataWithJSONObject(newPost, options: [])
        
        request.HTTPBody = jsonPost
        
        request.allHTTPHeaderFields!["content-type"] = "application/json"
        
        let queue: NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse?,responseMessage: NSData?, error: NSError?) -> Void in NSOperationQueue.mainQueue().addOperationWithBlock(
            {
                if(responseMessage == nil)
                {
                    print("No Data")
                }
                else
                {
                    let gameData: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(responseMessage!, options: NSJSONReadingOptions()) as! NSDictionary
                    
                    
                    let playerid = gameData["playerId"] as! String
                    let gameId = gameData["gameId"] as! String

                    
                    delegate.newGame(playerid, gameId: gameId, playerId: playerid)
                }
                
        })
        })
    }
    
    func attemptToJoin(delegate: getGamesDelegate, gameID: String, playerName: String){
        var id: String!
        var success = false
        //let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games/" + boardID.UUIDString + "/board")!
        let battleshipURL: NSURL = NSURL(string: "http://battleship.pixio.com/api/games/\(gameID)/join")!
        let request = NSMutableURLRequest(URL: battleshipURL)
        request.HTTPMethod = "POST"
        //3be2e411-0086-46fd-8fc9-38d11831d0fb
        
        let newPost: NSDictionary = ["playerName": playerName]
        let jsonPost = try? NSJSONSerialization.dataWithJSONObject(newPost, options: [])
        
        request.HTTPBody = jsonPost
        
        request.allHTTPHeaderFields!["content-type"] = "application/json"
        
        let queue: NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse?,responseMessage: NSData?, error: NSError?) -> Void in NSOperationQueue.mainQueue().addOperationWithBlock(
            {
                if(responseMessage == nil)
                {
                    print("No Data")
                }
                else
                {
                    let gameData: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(responseMessage!, options: NSJSONReadingOptions()) as! NSDictionary
                    
                    let temp = gameData.allKeys as! [String]
                    if temp.contains("playerId"){
                        success = true
                        id = gameData["playerId"] as! String
                    }
                    else if temp.contains("message"){
                        success = false
                        id = ""
                    }
                    delegate.receivePlayerID(id, success: success)

                }
                
            })
        })
        }


}






//
//let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error)  in
//    print("got here")
//
//
//    guard let httpResponse = response as?
//        NSHTTPURLResponse else {
//            return
//    }
//    
//    if httpResponse.statusCode == 400 || httpResponse.statusCode == 500{
//        return
//}
//
////            let gameData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
////
////            guard let dataArray = gameData as? [AnyObject] else{
////                return
////            }

        //dataTask.resume()

