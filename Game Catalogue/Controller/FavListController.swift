//
//  FavListController.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 25/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit
import Nuke

private let helper: Helper! = Helper()

class FavListController: UIViewController {
    
    private var favoriteGames: [GameModel] = []
    @IBOutlet weak var noFavView: UIView!
    @IBOutlet weak var favoriteTableView: UITableView!
    private lazy var favoriteProvider: FavoriteGameProvider = { return FavoriteGameProvider() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorite()
    }
    
    private func loadFavorite(){
        self.favoriteProvider.getAllFavoriteGame{ (result) in
//            dump(result)
            if(result.count > 0){
                DispatchQueue.main.async {
                    self.noFavView.isHidden = true
                    self.favoriteTableView.isHidden = false
                    
                    self.favoriteGames = result
                    self.favoriteTableView.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    self.noFavView.isHidden = false
                    self.favoriteTableView.isHidden = true
                }
                
            }
        }
    }
    
    private func setupView(){
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainViewCell")
    }
}

extension FavListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainViewCell", for: indexPath) as? MainTableViewCell{
                
                cell.selectionStyle = .none
                
                if(loading){
                    cell.title.text = "Loading..."
                }else{
                    if(favoriteGames.isEmpty == false && indexPath.row < favoriteGames.count){
        //                print("=============TEST==============")
        //                print(gameDataFiltered)
                        let detailGame = favoriteGames[indexPath.row]
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
                    }else{
                        cell.title.text = "Data Not Found..."
                    }
                }
                
                return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension FavListController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!favoriteGames.isEmpty){
            // Memanggil View Controller dengan berkas NIB/XIB di dalamnya
            let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        
            // Mengirim data
            detail.detailGame = favoriteGames[indexPath.row]
            detail.parentController = "FavListController"
            
            // Push/mendorong view controller lain
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

