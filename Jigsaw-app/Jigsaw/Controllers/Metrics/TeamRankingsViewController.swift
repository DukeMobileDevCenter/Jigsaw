//
//  TeamRankingsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/14/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ProgressHUD

class TeamRankingsViewController: UITableViewController {
    @IBOutlet var teamRankingsFooterLabel: UILabel!
    
    private var rankings = [TeamRanking]() {
        didSet {
            tableView.reloadData()
            teamRankingsFooterLabel.text = "Top 25 teams are displayed."
        }
    }
    
    /// A date formatter to format the date of a game record.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM yy"
        return formatter
    }()
    
    // MARK: UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressHUD.show()
        FirebaseHelper.getTeamRankings { [weak self] rankings, error in
            ProgressHUD.dismiss()
            if let rankings = rankings {
                self?.rankings = rankings
            } else if let error = error {
                self?.presentAlert(error: error)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rankings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRankingsCell", for: indexPath)
        let rank = rankings[indexPath.row]
        if rank.isMyTeam {
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = rank.teamName + dateFormatter.string(from: rank.playedDate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rank = rankings[indexPath.row]
        if rank.isMyTeam {
            presentAlert(title: "Placeholder my team", message: rank.description)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
