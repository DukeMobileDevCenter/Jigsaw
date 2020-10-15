//
//  RoomProgressViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import SafariServices
import ResearchKit
import FirebaseFirestore
import ProgressHUD
import Charts

class RoomProgressViewController: UIViewController {
    /// The label to show current room level, debug only.
    @IBOutlet var roomLevelLabel: UILabel!
    /// The button to initiate next room. Enabled when room 0 is done.
    @IBOutlet var nextRoomButton: UIButton!
    
    @IBOutlet var surveyButton: UIButton!
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    @IBAction func nextRoomButtonTapped(_ sender: UIButton) {
        presentRoom(room: currentRoom!)
    }
    
    @IBAction func surveyButtonTapped(_ sender: UIButton) {
        let controller = SFSafariViewController(url: AppConstants.feedbackFormURL)
        present(controller, animated: true)
        isSurveyShown = true
    }
    
    @IBOutlet var chartView: PieChartView! {
        didSet {
            // Setup the half pie chart view.
            setup(pieChartView: chartView)
        }
    }
    
    private let chartCenterText: NSMutableAttributedString = {
        // Center text settings.
        let centerText = NSMutableAttributedString(string: "Results\nby Jigsaw")
        centerText.setAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ],
            range: NSRange(location: 0, length: centerText.length)
        )
        centerText.addAttributes(
            [
                .font: UIFont(name: "HelveticaNeue-Light", size: 13)!,
                .foregroundColor: UIColor.systemBlue
            ],
            range: NSRange(location: centerText.length - 6, length: 6)
        )
        return centerText
    }()
    
    /// The player's current game group set by the parent view controller.
    var gameGroup: GameGroup!
    /// The allocated game resources for current player set by the parent view controller. Only set once.
    var gameOfMyGroup: GameOfGroup!
    
    /// The game results collected from each room.
    private var roomResults = [ORKTaskResult]()
    
    private var isChatroomShown = false
    private var isSurveyShown = false
    private var isMeDropped = true
    
    private var attempts = 0
    private var currentRoom: Int? = 0 {
        didSet {
            if let room = currentRoom {
                roomLevelLabel.text = "You are in room \(room + 1)"
                nextRoomButton.isEnabled = room > 0
            } else {
                roomLevelLabel.text = "Jigsaw broken 😞"
                nextRoomButton.isEnabled = false
            }
        }
    }
    
    private var chatroomViewController: ChatViewController!
    private var gameViewController: GameViewController!
    
    private var gameGroupListener: ListenerRegistration?
    
    private func presentRoom(room: Int) {
        gameViewController = GameViewController(game: gameOfMyGroup, currentRoom: room)
        gameViewController.delegate = self
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true)
    }
    
    private func addGameHistory(gameHistory: GameHistory) {
        let historyRef = FirebaseConstants.database.collection(["Players", Profiles.userID, "gameHistory"].joined(separator: "/"))
        do {
            // Set a history with the group ID.
            try historyRef.document(gameGroup.id!).setData(from: gameHistory)
            // Insert the played game into history set.
            Profiles.playedGameIDs.insert(gameHistory.gameID)
        } catch {
            presentAlert(error: error)
        }
    }
    
    private func setGameGroupListener() {
        let gameGroupRef = FirebaseConstants.shared.gamegroups
        gameGroupListener = gameGroupRef.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let currentGroup = try? change.document.data(as: GameGroup.self),
              // Only proceed if current player is in the matching group.
              currentGroup.whichGroupContains(userID: Profiles.userID) != nil else { return }
        
        switch change.type {
        case .modified:
            // Only handle increment.
            if currentGroup.chatroomReadyUserIDs.count > gameGroup.chatroomReadyUserIDs.count {
                handleModifiedReadyPlayerCount(group: currentGroup)
            } else if currentGroup.roomAttemptedUserIDs.count > gameGroup.roomAttemptedUserIDs.count {
                handleModifiedAttemptedPlayerCount(group: currentGroup)
            } else if currentGroup.roomFinishedUserIDs.count > gameGroup.roomFinishedUserIDs.count {
                handleModifiedFinishedPlayerCount(group: currentGroup)
            }
        case .removed:
            // If any player dropped the game before they finish, the others cannot play anymore.
            if currentGroup.roomFinishedUserIDs.count != currentGroup.allPlayersUserIDs.count {
                isMeDropped = false
                taskViewController(gameViewController, didFinishWith: .discarded, error: GameError.otherPlayerDropped)
            }
        default:
            break
        }
        // Hold a copy of the changed game group.
        gameGroup = GameGroup(id: change.document.documentID, group: currentGroup)
    }
    
    private func handleModifiedReadyPlayerCount(group: GameGroup) {
        if group.chatroomReadyUserIDs.count == group.allPlayersUserIDs.count {
            // All players are ready for chat.
            // Show the back button if players want to terminate early.
            chatroomViewController.navigationItem.hidesBackButton = false
        }
    }
    
    private func handleModifiedAttemptedPlayerCount(group: GameGroup) {
        if group.roomAttemptedUserIDs.count == group.allPlayersUserIDs.count {
            // All players have reached the wait page.
            if group.roomFinishedUserIDs.count < group.roomAttemptedUserIDs.count {
                // Some players failed.
                // Reset the attempted and finished array.
                FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                    "roomAttemptedUserIDs": FieldValue.arrayRemove([Profiles.userID!]),
                    "roomFinishedUserIDs": FieldValue.arrayRemove([Profiles.userID!])
                ])
                // Go back to the resource page.
                gameViewController.flipToPage(withIdentifier: "Resource", forward: false, animated: true)
            } else {
                // All players have passed.
                gameViewController.goForward()
            }
        }
    }
    
    private func handleModifiedFinishedPlayerCount(group: GameGroup) {
        if group.roomFinishedUserIDs.count == group.allPlayersUserIDs.count {
            // Do nothing here now.
        }
    }
    
    private func loadChatroom(completion: @escaping () -> Void) {
        let chatroomsRef = FirebaseConstants.shared.chatrooms.document(gameGroup.chatroomID)
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                let controller = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom)
                controller.chatroomUserIDs = self.gameGroup.allPlayersUserIDs
                self.chatroomViewController = controller
            } else if let error = error {
                self.presentAlert(error: error)
                self.navigationItem.hidesBackButton = false
            }
            completion()
        }
    }
    
    private func cleanUpRemoteAfterGameEnds() {
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        // Remove matching game group from database after game is dropped.
        FirebaseConstants.shared.gamegroups.document(gameGroup.id!).delete()
        // Remove the chatroom when a player stops the game.
        FirebaseConstants.shared.chatrooms.document(gameGroup.chatroomID).delete()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Listen to modification and removal of the game groups.
        setGameGroupListener()
        // Load chatroom once for each game.
        ProgressHUD.show("Loading Rooms", interaction: false)
        // Hide nav button to disallow players accidentally drop the game.
        navigationItem.hidesBackButton = true
        loadChatroom { [unowned self] in
            ProgressHUD.dismiss()
            // After the chatroom is loaded, present the first room.
            self.presentRoom(room: currentRoom!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do nothing if the player has already seen the survey, which means
        // he either failed or finished the game.
        guard !isSurveyShown else { return }
        
        // Reload doors collection view.
        collectionView.reloadData()
        
        let allPreviosGameResult = GameResult(taskResults: roomResults, questionnaires: gameOfMyGroup.questionnaires)
        
        if roomResults.isEmpty {
            // Update the chart with an empty source.
            setChartData(from: [.correct: 0, .skipped: 1, .incorrect: 0])
        } else {
            // Update the chart with all the up-to-date rooms results.
            setChartData(from: allPreviosGameResult.resultPairs)
        }
        
        // All rooms passed, add the records to player's game history.
        if currentRoom == gameOfMyGroup.questionnaires.count {
            // Mark the player as all rooms finished.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "allRoomsFinishedUserScores": FieldValue.arrayUnion([allPreviosGameResult.score])
            ])
//            // Stop listen to further updates to game groups.
//            gameGroupListener?.remove()
            cleanUpRemoteAfterGameEnds()
            // Add game history to a player's histories collection.
            let gameHistory = GameHistory(
                gameID: gameOfMyGroup.gameID,
                playedDate: gameGroup.createdDate,
                gameCategory: gameOfMyGroup.category,
                gameName: gameOfMyGroup.gameName,
                allPlayers: gameGroup.allPlayersUserIDs,
                gameResult: Dictionary(uniqueKeysWithValues: Array(allPreviosGameResult.resultPairs)),
                score: allPreviosGameResult.score
            )
            addGameHistory(gameHistory: gameHistory)
            navigationItem.hidesBackButton = false
            nextRoomButton.isHidden = true
            surveyButton.isHidden = false
        }
    }
    
    deinit {
        // Reset VCs.
        chatroomViewController = nil
        gameViewController = nil
        print("✅ room vc deinit")
    }
}

extension RoomProgressViewController: ORKTaskViewControllerDelegate {
    private func handleCountdownStep(taskViewController: ORKTaskViewController, stepViewController: ORKActiveStepViewController) {
        // Don't show chatroom again when a player quit the chat and move on.
        if isChatroomShown {
            // When the player has left chatroom, remove player id from the array.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "chatroomReadyUserIDs": FieldValue.arrayRemove([Profiles.userID!])
            ])
            // Reset flag for chatroom.
            isChatroomShown = false
            // Call finish to automatically move to next screen. (Not valid for no timer step.)
            // stepViewController.finish()
            stepViewController.goForward()
            return
        }
        
        // Mark the player who reached chatroom step as ready.
        FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
            "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
        ])
        stepViewController.title = "Leave Chat"
        stepViewController.show(chatroomViewController, sender: nil)
        
        // Hide the back button until all players join the chatroom.
        chatroomViewController.navigationItem.hidesBackButton = true
        // Mark chatrooom is shown for current room level.
        isChatroomShown = true
    }
    
    private func handleWaitStep(taskVC: ORKTaskViewController, stepVC: ORKWaitStepViewController) {
        // Everytime the player reaches wait step, add attempts count.
        attempts += 1
        // Calculate the game result for current room.
        let gameResult = GameResult(taskResults: [taskVC.result], questionnaires: [gameOfMyGroup.questionnaires[currentRoom!]])
        let progress = CGFloat(gameGroup.roomAttemptedUserIDs.count + 1) / CGFloat(gameGroup.allPlayersUserIDs.count)
        stepVC.updateText("Below is a summary of current room (for debug, UI needs update):\n\(gameResult.summary)")
        stepVC.setProgress(progress, animated: true)
        
        // Add user ID to attempted array.
        // Note: it must go after the alert is presented. Otherwise it would cause
        // nav stack bug for not being able to pop while alert is presenting.
        let completion = { [weak self] in
            guard let self = self else { return }
            FirebaseConstants.shared.gamegroups.document(self.gameGroup.id!).updateData([
                "roomAttemptedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
        }
        
        if !gameResult.isPassed {
            // Failed to pass the game.
            if attempts == gameOfMyGroup.maxAttempts {
                // First go to completion to notify the other players.
                completion()
                // Then fail the local game and abort.
                isMeDropped = true
                taskViewController(taskVC, didFinishWith: .failed, error: GameError.maxAttemptReached)
            } else {
                // The player failed the room with wrongCount of wrong answers.
                stepVC.presentAlert(gameError: GameError.currentPlayerFailed(gameResult.wrongCount), completion: completion)
            }
        } else {
            // First mark the player as finished.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "roomFinishedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            // Then mark the player as attempted.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "roomAttemptedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        guard let step = stepViewController.step else { return }
        switch step.identifier {
        case "Countdown":
            handleCountdownStep(taskViewController: taskViewController, stepViewController: stepViewController as! ORKActiveStepViewController)
        case "Wait":
            handleWaitStep(taskVC: taskViewController, stepVC: stepViewController as! ORKWaitStepViewController)
        default:
            break
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Hold current room's result.
        roomResults.append(taskViewController.result)
        
        // Decide what is the outcome of current room.
        switch reason {
        case .failed, .discarded, .saved:
            print("❌ Failed or 💦 Canceled")
            // Set room level to invalid.
            currentRoom = nil
            // Dismiss the game controller to avoid presenting issues.
            taskViewController.dismiss(animated: true)
            if let error = error {
                if let gameError = error as? GameError {
                    presentAlert(gameError: gameError)
                } else {
                    presentAlert(error: error)
                }
            }
            if isMeDropped { cleanUpRemoteAfterGameEnds() }
            surveyButton.isHidden = false
            navigationItem.hidesBackButton = false
            // Log an unsuccessful game result.
        case .completed:
            print("✅ completed")
            // When a room is completed by all players in the group, go to next room.
            currentRoom! += 1
            // Reset attempts.
            attempts = 0
            // Player has passed. Reset the all arrays.
            guard let userID = Profiles.userID else { return }
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "roomAttemptedUserIDs": FieldValue.arrayRemove([userID]),
                "roomFinishedUserIDs": FieldValue.arrayRemove([userID])
            ])
            // Dismiss the game controller.
            taskViewController.dismiss(animated: true)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}

// MARK: - UICollectionView

extension RoomProgressViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gameOfMyGroup.questionnaires.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoorCollectionCell", for: indexPath) as! DoorCollectionCell
        let room = indexPath.item
        let doorImage: UIImage
        let currentLevel = currentRoom ?? -1
        if currentLevel > room {
            doorImage = UIImage(named: "door-open")!
            cell.doorImageView.tintColor = .systemPurple
        } else if currentLevel == room {
            doorImage = UIImage(named: "door-locked")!
            cell.doorImageView.tintColor = .systemGreen
        } else {
            doorImage = UIImage(named: "door-locked")!
            cell.doorImageView.tintColor = .systemGray
        }
        cell.doorImageView.setImage(doorImage)
        cell.nameLabel.text = "Room \(room + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let room = indexPath.item
        let currentLevel = currentRoom ?? -1
        if currentLevel == room {
            presentRoom(room: room)
        }
    }
}

extension RoomProgressViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 96, height: 128)
    }
}

// MARK: - ChartView

extension RoomProgressViewController: ChartViewDelegate {
    private func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.drawHoleEnabled = true
        chartView.highlightPerTapEnabled = true
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        chartView.delegate = self
        
        chartView.holeColor = .clear
        chartView.transparentCircleColor = UIColor.systemBackground.withAlphaComponent(0.5)
        chartView.rotationEnabled = false
        
        chartView.maxAngle = 180 // Half chart
        chartView.rotationAngle = 180 // Rotate to make the half on the upper side
        chartView.centerTextOffset = CGPoint(x: 0, y: -25)
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        chartView.drawCenterTextEnabled = true
        chartView.centerAttributedText = chartCenterText
        // Legend settings.
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.orientation = .horizontal
        chartView.legend.drawInside = false
        chartView.legend.xEntrySpace = 7
        chartView.legend.yEntrySpace = 0
        chartView.legend.yOffset = 0
        chartView.legend.font = UIFont.systemFont(ofSize: 15)
    }
    
    private func setChartData(from resultPairs: KeyValuePairs<AnswerCategory, Int>) {
        // Assuming there are no games with 0 questions.
        let totalCount = resultPairs.reduce(0) { $0 + $1.1 }
        let entries = resultPairs.compactMap { (key, value) -> PieChartDataEntry? in
            if key == .unknown && value == 0 {
                // Omit .unknown category if it is empty.
                return nil
            }
            return PieChartDataEntry(
                value: Double(value) / Double(totalCount),
                label: key.rawValue
            )
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.sliceSpace = 3
        set.selectionShift = 10
        set.colors = ChartColorTemplates.material()
        
        let data = PieChartData(dataSet: set)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 1
        percentageFormatter.multiplier = 1
        percentageFormatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: percentageFormatter))
    
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 13)!)
        data.setValueTextColor(.white)
        
        chartView.data = data
        chartView.setNeedsDisplay()
    }
}
