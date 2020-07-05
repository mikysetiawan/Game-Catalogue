//
//  MainViewController.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MainTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        return cell
    }
}
