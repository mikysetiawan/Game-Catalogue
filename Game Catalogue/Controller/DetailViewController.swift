//
//  DetailViewController.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 12/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit
import Nuke
import AVKit
import AVFoundation

class DetailViewController: UIViewController {

    var detailGame: GameModel?
    var parentController: String?
    var clip: Clip?
    var screenShot: [ShortScreenshot]?
    @IBOutlet weak var addToFavBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleGame: UILabel!
    @IBOutlet weak var releasedDate: UILabel!
    @IBOutlet weak var ratingGame: UILabel!
    @IBOutlet weak var descriptionGame: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    private lazy var favoriteProvider: FavoriteGameProvider = { return FavoriteGameProvider() }()

    let inset: CGFloat = 5
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 5
    let cellsPerRow = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "ImageDetailItemCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "imageDetail")

        collectionView.delegate = self
        collectionView.dataSource = self

        // Digunakan untuk menetapkan nilai ke beberapa view yang ada
        if let result = detailGame {
            detailGame = result

            //Check if this game is already added to fav
            self.getFav()

            //print(result.description)
            let screenWidth = UIScreen.main.bounds.size.width
            let targetSize = CGSize(width: screenWidth, height: screenWidth)

            var request = ImageRequest(
                url: URL(string: "https://www.elichai.com/wp-content/uploads/2017/07/placeholder-dark.png")!,
                processors: [
                    ImageProcessors.Resize(size: targetSize),
                    ImageProcessors.CoreImageFilter(name: "CIExposureAdjust",
                    parameters: ["inputEV": -4],
                    identifier: "nuke.demo.monochrome")
                ]
            )

            if result.background != "" {
                request = ImageRequest(
                    url: URL(
                        string: result.background ??
                        "https://www.elichai.com/wp-content/uploads/2017/07/placeholder-dark.png")!,
                    processors: [
                        ImageProcessors.Resize(size: targetSize),
                        ImageProcessors.CoreImageFilter(name: "CIExposureAdjust",
                                                        parameters: ["inputEV": -4],
                                                        identifier: "nuke.demo.monochrome")
                    ]
                )
            }

            let options = ImageLoadingOptions(
                placeholder: UIImage(named: "placeholder-dark"),
                transition: .fadeIn(duration: 0.33)
            )
            Nuke.loadImage(with: request, options: options, into: backgroundImage)

            titleGame.text = result.name
            descriptionGame.attributedText = NSAttributedString(html: result.description ?? "")
            let release = result.released ?? "TBO"
            releasedDate.text = "Released date: "+release
            ratingGame.text = result.rating

            ratingGame.layer.masksToBounds = true
            ratingGame.layer.cornerRadius = 5
            ratingGame.adjustsFontSizeToFitWidth = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenShot = detailGame?.shortScreenshots ?? [ShortScreenshot]()
        if screenShot?.count ?? 0 > 0 {
            return screenShot?.count ?? 0
        } else {
            return 0
        }
    }

    func collectionView (
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "imageDetail",
            for: indexPath) as? ImageDetailItemCell {

            clip = detailGame?.clip
            if indexPath.row == 0 && clip?.clip != nil {
                //Row pertama untuk clip kalau ada
                let targetSize = CGSize(width: 150, height: 150)

                var request = ImageRequest(
                    url: URL(string: "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                    processors: [
                        ImageProcessors.Resize(size: targetSize)
                    ]
                )
                if clip?.preview != "" {
                    request = ImageRequest(
                        url: URL(
                            string: clip?.preview ??
                            "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                        processors: [
                            ImageProcessors.Resize(size: targetSize)
                        ]
                    )
                }

                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: request, options: options, into: cell.imageDetail)
                self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height
                return cell
            }

            screenShot = detailGame?.shortScreenshots ?? [ShortScreenshot]()
            if screenShot?.isEmpty == false && indexPath.row < screenShot?.count ?? 0 {
                let screenshot = screenShot?[indexPath.row]
                let targetSize = CGSize(width: 150, height: 150)

                var request = ImageRequest(
                    url: URL(string: "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                    processors: [
                        ImageProcessors.Resize(size: targetSize)
                    ]
                )
                if screenshot?.image != "" {
                    request = ImageRequest(
                        url: URL(
                            string: screenshot?.image ??
                            "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                        processors: [
                            ImageProcessors.Resize(size: targetSize)
                        ]
                    )
                }

                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: request, options: options, into: cell.imageDetail)
            }

            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left +
            collectionView.safeAreaInsets.right + minimumInteritemSpacing *
            CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && clip?.clip != nil {
            self.playVideo()
        } else {
            self.addImageViewWithImage(index: indexPath.row)
        }
    }

    @objc func removeImage(_ sender: UITapGestureRecognizer? = nil) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false

        if let imageView = (self.view.viewWithTag(100)! as? UIImageView) {
            imageView.removeFromSuperview()
        }
    }

    func addImageViewWithImage(index: Int) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.tag = 100

        if screenShot?.isEmpty == false && index < screenShot?.count ?? 0 {
            let screenshot = screenShot?[index]
            let targetSize = CGSize(width: 150, height: 150)

            let request = ImageRequest(
                url: URL(string: screenshot?.image ?? "https://i.ya-webdesign.com/images/placeholder-image-png-6.png")!,
                processors: [
                    ImageProcessors.Resize(size: targetSize)
                ]
            )

            Nuke.loadImage(with: request, into: imageView)
        }

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(removeImage))
        imageView.addGestureRecognizer(dismissTap)
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
    }

    func playVideo() {
        if let url = URL(string: (clip?.clip)!) {

            let player = AVPlayer(url: url)
            let playerVC=AVPlayerViewController()
            playerVC.player = player
            self.showDetailViewController(playerVC, sender: self)
        }
    }

    @IBAction func addToFavClick(_ sender: Any) {
        if self.addToFavBtn.tintColor == UIColor.systemPink {
            //Remove Fav
            self.removeFav()
            self.addToFavBtn.tintColor = UIColor.white
        } else {
            //Add to Fav
            self.addToFav()
            self.addToFavBtn.tintColor = UIColor.systemPink
        }

    }

    private func addToFav() {
        self.favoriteProvider.addToFavorite(gameDetail: self.detailGame!) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Successful", message: "Added to favorite", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func removeFav() {
        self.favoriteProvider.removeFavorite((detailGame?.id)!) {
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Successful",
                    message: "Removed from favorite",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                    if self.parentController == "FavListController" {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func getFav() {
        self.favoriteProvider.getFavoriteGame((detailGame?.id)!) { (game) in
            if game.id != nil {
                DispatchQueue.main.async {
                    self.addToFavBtn.tintColor = UIColor.systemPink
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UICollectionViewDelegate {
  // table view data source methods
}

// MARK: - UICollectionViewDataSource
extension DetailViewController: UICollectionViewDataSource {
  // table view data source methods
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailViewController: UICollectionViewDelegateFlowLayout {
  // table view data source methods
}
