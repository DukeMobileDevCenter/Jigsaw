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
    /// A bar button to upload the average score to GameCenter.
    @IBOutlet var submitScoreBarButtonItem: UIBarButtonItem! {
        didSet {
            submitScoreBarButtonItem.isEnabled = GameCenterHelper.isAuthenticated
        }
    }
    
    /// Tap button to upload average score to GameCenter.
    @IBAction func submitScoreButtonTapped(_ sender: UIBarButtonItem) {
        // When the data is pulled from remote, submit the score to Game Center.
        GameCenterHelper.shared.submitAverageScore(averageScore * 1000)
        GameCenterHelper.shared.submitGamesPlayed(gameHistories.count)
        // FIXME: for beta, do not reporting achievement.
        // Every time enter a category page, report the progress to GameCenter.
        // We can come up with better strategy.
        // This page will be eventually redesigned to a place to view all records in a timeline
        // as well as summaries for game progress.
//        if GameCenterHelper.isAuthenticated {
//            let percentComplete = GameStore.shared.percentComplete(for: category)
//            GameCenterHelper.shared.submitFinishedAchievement(for: category, progress: percentComplete)
//        }
    }
    
    /// The game history records for a player.
    private var gameHistories = [GameHistory]() {
        didSet {
            tableView.reloadData()
            let scoreText = percentageFormatter.string(from: NSNumber(value: averageScore))!
            totalCountLabel.text = "\(gameHistories.count) game(s) played, average score = \(scoreText)."
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
    
    /// The average score times.
    private var averageScore: Double {
        if gameHistories.isEmpty { return 0 }
        return gameHistories.map { $0.score }.reduce(0, +) / Double(gameHistories.count)
    }
    
    // MARK: UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game History"
        ProgressHUD.show()
        FirebaseHelper.getGameHistory(userID: Profiles.userID) { [weak self] histories, error in
            ProgressHUD.dismiss()
            if let histories = histories {
                self?.gameHistories = histories
                // Add all remote histories to the set.
                Profiles.playedGameIDs = Set(histories.map { $0.gameID })
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
