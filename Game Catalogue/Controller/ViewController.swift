//
//  ViewController.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit
import os.log
import Nuke

private let page = "1"
private let helper: Helper! = Helper()
private var gamesData: Games!
private var gameData: [Game]!
var loading = true

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var mainTableView: UITableView!
    var componentGames = URLComponents(string: "https://api.rawg.io/api/games")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameData = [Game]()
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainViewCell")
        // Do any additional setup after loading the view.
        componentGames.queryItems = [
            URLQueryItem(name: "page_size", value: "10")
        ]
        
        let request = URLRequest(url: componentGames.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else { return }
                if (response.statusCode == 200) {
                    gamesData = helper.decodeGamesJSON(data: data)
//                    NSLog("Result" + String(decoding: data, as: UTF8.self))

                    gameData = gamesData?.game
                    loading = false
                    
                    DispatchQueue.main.async {
                        self.mainTableView.reloadData()
                    }
                } else {
                    NSLog("Something When Wrong " + String(response.statusCode))
                }
        }
        
        task.resume()
    }
    
//    private func getDataGame(withID id: String){
//        let componentGame = URLComponents(string: "https://api.rawg.io/api/games"+id)!
//        let request = URLRequest(url: componentGame.url!)
//
//                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                    guard let response = response as? HTTPURLResponse, let data = data else { return }
//                        if (response.statusCode == 200) {
//                            gamesData = helper.decodeGamesJSON(data: data)
//        //                    NSLog("Result" + String(decoding: data, as: UTF8.self))
//
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            gameData = gamesData?.game
//
//                            DispatchQueue.main.async {
//                                self.mainTableView.reloadData()
//                            }
//                        } else {
//                            NSLog("Something When Wrong " + String(response.statusCode))
//                        }
//                }
//
//                task.resume()
//    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(loading){
            return 1
        }else{
            return gameData.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainViewCell", for: indexPath) as! MainTableViewCell
        
        if(loading){
            cell.title.text = "Loading..."
        }else{
            if(gameData?.isEmpty == false){
                let detailGame = gamesData.game![indexPath.row]
                cell.date.text = detailGame.released
                cell.title.text = detailGame.name
                cell.rating.text = detailGame.rating
//                cell.mainPicture.downloaded(from: detailGame.background ?? "https://media.rawg.io/media/games/b11/b115b2bc6a5957a917bc7601f4abdda2.jpg")
                
                let screenWidth = UIScreen.main.bounds.size.width
                let targetSize = CGSize(width: screenWidth, height: (screenWidth / 1.5))
                
                let request = ImageRequest(
                    url: URL(string: detailGame.background ?? "")!,
                    processors: [
                        ImageProcessors.Resize(size: targetSize),
                    ]
                )
                
                Nuke.loadImage(with: request, into: cell.mainPicture)
                
                cell.backgroundColor = helper.hexStringToUIColor(hex: "#ececec")
            }else{
                cell.title.text = "Data Not Found..."
            }
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("You tapped cell number \(indexPath.section).")
    }
}
