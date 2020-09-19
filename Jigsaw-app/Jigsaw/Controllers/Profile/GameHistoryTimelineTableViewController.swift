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
    
    /// Load game history records from database.
    ///
    /// - Parameters:
    ///   - completion: A closure called after fetching data from database that passes an array of `GameHistory`.
    ///   - gameHistories: An array of `GameHistory`.
    private func loadGameHistories(completion: @escaping (_ gameHistories: [GameHistory]) -> Void) {
        let historyRef = FirebaseConstants.database.collection(["Players", Profiles.userID, "gameHistory"].joined(separator: "/"))
        var gameHistories: [GameHistory] = []
        historyRef.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let historyRecords = querySnapshot {
                for gameHistory in historyRecords.documents {
                    if let history = try? gameHistory.data(as: GameHistory.self) {
                        gameHistories.append(history)
                    }
                }
            } else if let error = error {
                self.presentAlert(error: error)
            }
            completion(gameHistories)
        }
    }
    
    // MARK: UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game History"
        ProgressHUD.show()
        loadGameHistories { [weak self] histories in
            self?.gameHistories = histories
            ProgressHUD.dismiss()
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
