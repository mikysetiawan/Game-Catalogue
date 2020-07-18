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

private var page = 1
private let itemPerBatch = "10"
private let helper: Helper! = Helper()
private var gamesData: Games!
private var gameData: [GameModel]!
private var gameDataFiltered: [GameModel]!
var loading = true
var searching = false
var textQuery = ""

class ViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var loadMoreDataView: UIView!
    @IBOutlet weak var noMoreDataView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var rightButtonNavbar: UIBarButtonItem!
    let width = UIScreen.main.bounds.size.width - 100
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width, height: 20))
    
    var componentGames = URLComponents(string: "https://api.rawg.io/api/games")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameData = [GameModel]()
        gameDataFiltered = [GameModel]()
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainViewCell")
        
        searchBar.placeholder = "Search Game Name"
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        searchBar.delegate = self
        
        fetchData()
    }
    

    @IBAction func tryAgainButton(_ sender: Any) {
        fetchData()
    }
    
    private func showLoadMoreDataView(_ show: Bool) {
        loadMoreDataView.isHidden = show ? false : true
        noMoreDataView.isHidden = show ? true : false
    }
    
    private func showLoadMoreDataView() {
        showLoadMoreDataView(true)
    }
    
    private func showNoMoreDataView() {
        showLoadMoreDataView(false)
    }
    
    // Handle show load more data view or no more data view when fetch data
    private func fetchData() {
        showLoadMoreDataView()
        getDataGame { (newData) in
            if (newData.count == 0) {
                self.showNoMoreDataView()
            }
            else {
                self.insertNewData(newData: newData)
                page += 1
            }
        }
    }
    
    private func getDataGame(fetched: @escaping (_ newData: [GameModel]) -> Void){
        componentGames.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: itemPerBatch)
        ]
        
        let request = URLRequest(url: componentGames.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else { return }
                if (response.statusCode == 200) {
                    gamesData = helper.decodeGamesJSON(data: data)
//                    NSLog("Result" + String(decoding: data, as: UTF8.self))

                    loading = false
                    
                    var gameFetched: [GameModel] = []
                    let new:[Game] =  gamesData?.game ?? [Game]()
                    new.forEach { (result) in
                        let newData = GameModel(id: result.id ?? 0, slug: result.slug ?? "", name: result.name ?? "", released: result.released ?? "", tba: result.tba ?? false, background: result.background ?? "", rating: result.rating ?? "", parent_platforms: result.parent_platforms ?? [ParentPlatform](), clip: result.clip!, short_screenshots: result.short_screenshots ?? [ShortScreenshot]())
                        
                        gameFetched.append(newData)
                    }
                    
                    fetched(gameFetched)
                } else {
                    NSLog("Something When Wrong " + String(response.statusCode))
                }
        }
        
        task.resume()
    }
    
    private func getDataGameSearch(append: Bool){
        let searchQuery = textQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            componentGames.queryItems = [
                URLQueryItem(name: "search", value: searchQuery),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "page_size", value: itemPerBatch)
            ]
            
            let request = URLRequest(url: componentGames.url!)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let response = response as? HTTPURLResponse, let data = data else { return }
                    if (response.statusCode == 200) {
                        gamesData = helper.decodeGamesJSON(data: data)
    //                    NSLog("Result" + String(decoding: data, as: UTF8.self))

                        loading = false
                        
                        if(!append){
                            gameDataFiltered = []
                        }
                        
                        let new:[Game] =  gamesData?.game ?? [Game]()
                        new.forEach { (result) in
                            let newData = GameModel(id: result.id ?? 0, slug: result.slug ?? "", name: result.name ?? "", released: result.released ?? "", tba: result.tba ?? false, background: result.background ?? "", rating: result.rating ?? "", parent_platforms: result.parent_platforms ?? [ParentPlatform](), clip: result.clip!, short_screenshots: result.short_screenshots ?? [ShortScreenshot]())
                            
                            gameDataFiltered.append(newData)
                        }
                        
                        DispatchQueue.main.async {
                            self.mainTableView.reloadData()
                        }
                    } else {
                        NSLog("Something When Wrong " + String(response.statusCode))
                    }
            }
            
            task.resume()
        }
    
    private func getDataGameDetail(id : Int, index: Int){
        let componentGameDetail = URLComponents(string: "https://api.rawg.io/api/games/"+String(id))!
            
        let request = URLRequest(url: componentGameDetail.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else { return }
                if (response.statusCode == 200) {
                    let detail = helper.decodeDetailGameJSON(data: data)
                    let result: GameDetail = detail
                    gameData[index].description = result.description ?? ""
                } else {
                    NSLog("Something When Wrong " + String(response.statusCode))
                }
        }
        
        task.resume()
    }
    
    // Insert new data into table view
    private func insertNewData(newData: [GameModel]) {
        if (newData.count > 0) {
            gameData.append(contentsOf: newData)
            gameDataFiltered = gameData
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(loading){
            return 1
        }else{
            return gameDataFiltered.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainViewCell", for: indexPath) as! MainTableViewCell
        
        cell.selectionStyle = .none
        
        if(loading){
            cell.title.text = "Loading..."
        }else{
            if(gameDataFiltered?.isEmpty == false && indexPath.row < gameDataFiltered.count){
//                print("=============TEST==============")
//                print(gameDataFiltered)
                let detailGame = gameDataFiltered![indexPath.row]
                cell.date.text = detailGame.released
                cell.title.text = detailGame.name
                cell.rating.text = detailGame.rating
                
                cell.platform1.isHidden = true
                cell.platform2.isHidden = true
                cell.platform3.isHidden = true
                
                let screenWidth = UIScreen.main.bounds.size.width
                let targetSize = CGSize(width: screenWidth, height: screenWidth)
                
                let request = ImageRequest(
                    url: URL(string: detailGame.background ?? "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                    processors: [
                        ImageProcessors.Resize(size: targetSize),
                    ]
                )
                
                
                var countTotalPlatform = 0, countPlatform = 0;
                let parentPlatform:[ParentPlatform] = detailGame.parent_platforms ?? [ParentPlatform]()
                
                for platform in parentPlatform {
                    let childPlatform = platform.platform
                    let icon = helper.getIconPlatform(slug: childPlatform?.slug ?? "")

                    if(icon != ""){
                        let image = UIImage(named: icon)
                        
                        if(countPlatform == 0){
                            cell.platform1.isHidden = false
                            cell.platform1.image = image
                            countPlatform += 1
                        }else if(countPlatform == 1){
                            cell.platform2.isHidden = false
                            cell.platform2.image = image
                            countPlatform += 1
                        }else if(countPlatform == 2){
                            cell.platform3.isHidden = false
                            cell.platform3.image = image
                            countPlatform += 1
                        }
                    }
                    
                    countTotalPlatform += 1
                }
                
                if(countTotalPlatform > 3){
                    cell.platformNumber.isHidden = false
                    cell.platformNumber.text = "+ " + String((countTotalPlatform - 3))
                }else{
                    cell.platformNumber.isHidden = true
                }
                
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: request, options: options, into: cell.mainPicture)
                
                cell.backgroundColor = helper.hexStringToUIColor(hex: "#ececec")
                
                getDataGameDetail(id: detailGame.id!, index: indexPath.row)
            }else{
                cell.title.text = "Data Not Found..."
            }
        }
        
        return cell
    }
    
    // Call fetchData method when last row is about to be presented
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            //print("last")
            if(gameDataFiltered.count > 0){
                if(searching){
                    getDataGameSearch(append: true)
                }else{
                    fetchData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!gameDataFiltered.isEmpty){
            // Memanggil View Controller dengan berkas NIB/XIB di dalamnya
            let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        
            // Mengirim data
            detail.detailGame = gameDataFiltered[indexPath.row]
            
            // Push/mendorong view controller lain
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0){
            textQuery = searchText
            if(!searching){
                //First time search, use last data for better performance
                gameDataFiltered = gameData.filter {
                    $0.name!.contains(searchText)
                }
                
                page = 1
            }else{
                getDataGameSearch(append: false)
            }
            searching = true
        }else{
            searching = false
            gameDataFiltered = gameData
            
            page = 1
        }
        
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }
}
