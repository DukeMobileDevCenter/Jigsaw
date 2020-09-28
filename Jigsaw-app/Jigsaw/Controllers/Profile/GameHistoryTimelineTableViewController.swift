//
//  GameHistoryTimelineTableViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/29/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ProgressHUD

class GameHistoryTimelineTableViewController: UITableViewController {
    /// A label to display the count of total games played.
    @IBOutlet var totalCountLabel: UILabel!
    
    /// The game history records for a player.
    private var gameHistories = [GameHistory]() {
        didSet {
            tableView.reloadData()
            totalCountLabel.text = "\(gameHistories.count) game(s) played in total."
        }
    }
    
    /// A number formatter to format percentage strings.
    private let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.multiplier = 100
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    /// A date formatter to format the date of a game record.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM yy"
        return formatter
    }()
    
    // MARK: UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game History"
        ProgressHUD.show()
        FirebaseHelper.getGameHistory(userID: Profiles.userID) { [weak self] histories, error in
            ProgressHUD.dismiss()
            if let histories = histories {
                self?.gameHistories = histories
                histories.forEach { history in
                    Profiles.playedGameIDs.insert(history.gameID)
                }
            } else if let error = error {
                self?.presentAlert(error: error)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameHistories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let history = gameHistories[indexPath.row]
        cell.textLabel?.text = dateFormatter.string(from: history.playedDate)
        cell.detailTextLabel?.text = history.gameName + " " + percentageFormatter.string(from: NSNumber(value: history.score))!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentAlert(title: "Placeholder info", message: gameHistories[indexPath.row].description)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
