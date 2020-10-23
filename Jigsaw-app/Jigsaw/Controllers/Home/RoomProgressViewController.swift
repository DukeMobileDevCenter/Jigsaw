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
    // MARK: Storyboard views
    
    /// The collection view to display a series of doors.
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    /// The chart view for game results.
    @IBOutlet var chartView: PieChartView! {
        didSet {
            // Setup the half pie chart view.
            setup(pieChartView: chartView)
        }
    }
    /// The label to show current room level, debug only.
    @IBOutlet var roomLevelLabel: UILabel!
    /// The button to initiate next room. Enabled when room 0 is done.
    @IBOutlet var nextRoomButton: UIButton! {
        didSet {
            nextRoomButton.layer.cornerRadius = 15
        }
    }
    /// The button to fill out the beta survey.
    @IBOutlet var surveyButton: UIButton!
    
    // MARK: Properties
    
    /// The player's current game group set by the parent view controller.
    var gameGroup: GameGroup!
    /// The allocated game resources for current player set by the parent view controller. Only set once.
    var gameOfMyGroup: GameOfGroup!
    
    private let confettiView = ConfettiView()
    
    /// The game results collected from each room.
    private var roomResults = [ORKTaskResult]()
    /// A copy of wait step results in current room, to decide if the player passed the room.
    private var currentWaitStepRoomResult: GameResult!
    /// A reference to the chatroom controller shared by all rooms in current game.
    private var chatroomViewController: ChatViewController!
    /// A reference to the room controller, i.e. the RK questionnaires.
    private var roomViewController: GameViewController!
    /// A FireStore listener on "GameGroups" collection.
    private var gameGroupListener: ListenerRegistration?
    
    /// A flag to indicate if chatroom is shown for current room.
    private var isChatroomShown = false
    /// A flag to indicate if the game failure is caused by the current player.
    private var isMeDropped = true
    
    /// The attempts count for each room.
    private var attempts = 0
    /// The index of current room, e.g. 0, 1, 2, 3...
    private var currentRoom: Int? = 0 {
        didSet {
            if let room = currentRoom {
                if gameCompleted {
                    roomLevelLabel.text = "You've completed the game! 🎉"
                    nextRoomButton.isHidden = true
                    surveyButton.isHidden = false
                    navigationItem.hidesBackButton = false
                } else {
                    roomLevelLabel.text = "You are now in room \(room + 1)"
                    nextRoomButton.isEnabled = true
                }
            } else {
                roomLevelLabel.text = "Jigsaw broken 😞"
                nextRoomButton.isEnabled = false
                surveyButton.isHidden = false
                navigationItem.hidesBackButton = false
            }
        }
    }
    
    /// A boolean to indicate if all rooms are done in a game.
    private var gameCompleted: Bool {
        guard let room = currentRoom, room >= gameOfMyGroup.questionnaires.count else {
            return false
        }
        return true
    }
    
    // MARK: Actions
    
    @IBAction func nextRoomButtonTapped(_ sender: UIButton) {
        presentRoom(room: currentRoom!)
    }
    
    @IBAction func surveyButtonTapped(_ sender: UIButton) {
        let controller = SFSafariViewController(url: AppConstants.feedbackFormURL)
        present(controller, animated: true)
        surveyButton.isHidden = true
    }
    
    private func presentRoom(room: Int) {
        roomViewController = GameViewController(game: gameOfMyGroup, currentRoom: room)
        roomViewController.delegate = self
        // Disallow dismiss-by-interactive-swipe-down for iOS 13 and above.
        roomViewController.isModalInPresentation = true
        present(roomViewController, animated: true)
    }
    
    // MARK: Methods
    
    private func addGameHistory(gameHistory: GameHistory) {
        let historyRef = FirebaseConstants.playerGameHistoryRef(userID: Profiles.userID)
        // Set a history with the group ID.
        try? historyRef.document(gameGroup.id!).setData(from: gameHistory)
        // Insert the played game into history set.
        Profiles.playedGameIDs.insert(gameHistory.gameID)
    }
    
    private func setGameGroupListener() {
        let gameGroupRef = FirebaseConstants.gamegroups
        gameGroupListener = gameGroupRef.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    private func loadChatroom(completion: @escaping () -> Void) {
        let chatroomsRef = FirebaseConstants.chatrooms.document(gameGroup.chatroomID)
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                let controller = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom)
                controller.chatroomUserIDs = self.gameGroup.allPlayersUserIDs
                self.chatroomViewController = controller
            } else if let error = error {
                self.presentAlert(error: error)
                self.currentRoom = nil
            }
            completion()
        }
    }
    
    // MARK: FireStore listener related methods
    
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
            // Handle deletion when players finished all the rooms.
            if currentGroup.allRoomsFinishedUserScores.count > gameGroup.allRoomsFinishedUserScores.count {
                handleAllRoomFinished(group: currentGroup)
            }
        case .removed:
            // If any player dropped the game before they finish, the others cannot play anymore.
            if currentGroup.allRoomsFinishedUserScores.count < currentGroup.allPlayersUserIDs.count {
                isMeDropped = false
                taskViewController(roomViewController, didFinishWith: .failed, error: GameError.otherPlayerDropped)
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
                FirebaseConstants.gamegroups.document(gameGroup.id!).updateData([
                    "roomAttemptedUserIDs": FieldValue.arrayRemove([Profiles.userID!]),
                    "roomFinishedUserIDs": FieldValue.arrayRemove([Profiles.userID!])
                ])
                // Go back to the resource page.
                roomViewController.flipToPage(withIdentifier: "Resource", forward: false, animated: true)
                // Not me failed, present room failure type.
                if currentWaitStepRoomResult.isPassed {
                    roomViewController.presentAlert(gameError: .otherPlayerFailed)
                } else {
                    roomViewController.presentAlert(gameError: .currentPlayerFailed(currentWaitStepRoomResult.wrongCount))
                }
            }
        }
    }
    
    private func handleModifiedFinishedPlayerCount(group: GameGroup) {
        if group.roomFinishedUserIDs.count == group.allPlayersUserIDs.count {
            // All players have passed. Move forward from the wait step.
            roomViewController.goForward()
        }
    }
    
    private func handleAllRoomFinished(group: GameGroup) {
        if group.allRoomsFinishedUserScores.count == group.allPlayersUserIDs.count {
            // Might be called by multiple players to take care of clean up.
            cleanUpRemoteAfterGameEnds()
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Listen to modification and removal of the game groups.
        setGameGroupListener()
        // Update the chart with an empty source.
        setChartData(from: [.correct: 0, .skipped: 0, .incorrect: 0, .unknown: 1])
        // Hide nav button to disallow players accidentally drop the game.
        navigationItem.hidesBackButton = true
        // Add confetti view to the main view.
        view.addSubview(confettiView)
        // Load chatroom once for each game.
        ProgressHUD.show("Loading Rooms", interaction: false)
        loadChatroom { [unowned self] in
            ProgressHUD.dismiss()
            // After the chatroom is loaded, present the first room.
            self.presentRoom(room: self.currentRoom!)
        }
    }
    
    private func cleanUpRemoteAfterGameEnds() {
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        gameGroupListener = nil
        // Remove matching game group from database after game is dropped.
        FirebaseConstants.gamegroups.document(gameGroup.id!).delete()
        // Remove the chatroom when a player stops the game.
        let chatroomId = gameGroup.chatroomID
        // First remove all the messages, then remove the chatroom itself.
        FirebaseHelper.deleteMessages(chatroomID: chatroomId) { [weak self] error in
            if let error = error {
                self?.presentAlert(error: error)
            } else {
                FirebaseConstants.chatrooms.document(chatroomId).delete()
            }
        }
    }
    
    private func roomDidFinish(withResult result: Result<Int, GameError>) {
        // Reload doors collection view.
        collectionView.reloadData()
        // Reload chart datasource.
        let allRoomsResult = GameResult(taskResults: roomResults, questionnaires: gameOfMyGroup.questionnaires)
        
        // Update the chart with all the up-to-date rooms results.
        setChartData(from: allRoomsResult.resultPairs)
        
        switch result {
        case .success(let currentRoomLevel):
            // Increase room count to go to next room.
            currentRoom = currentRoomLevel + 1
            // Reset attempts.
            attempts = 0
            // All rooms passed, add the records to player's game history.
            if gameCompleted {
                // Mark the player as all rooms finished.
                let userScoreString = gameGroup.userScoreString(userID: Profiles.userID, score: allRoomsResult.score)
                FirebaseConstants.gamegroups.document(gameGroup.id!).updateData([
                    "allRoomsFinishedUserScores": FieldValue.arrayUnion([userScoreString])
                ])
                // Add game history to a player's histories collection.
                let gameHistory = GameHistory(
                    gameID: gameOfMyGroup.gameID,
                    playedDate: gameGroup.createdDate,
                    gameCategory: gameOfMyGroup.category,
                    gameName: gameOfMyGroup.gameName,
                    allPlayers: gameGroup.allPlayersUserIDs,
                    gameResult: Dictionary(uniqueKeysWithValues: Array(allRoomsResult.resultPairs)),
                    score: allRoomsResult.score
                )
                addGameHistory(gameHistory: gameHistory)
                // Emit some confetti.
                confettiView.emit([
                    .text("🧩"),
                    .text("🧩")
                ], for: 5)
            } else {
                // Emit some confetti.
                confettiView.emit([
                    .text("🎊"),
                    .text("🎉")
                ], for: 3)
            }
        case .failure(let gameError):
            // Set room level to invalid.
            currentRoom = nil
            // Present the game failure type.
            presentAlert(gameError: gameError)
            if isMeDropped { cleanUpRemoteAfterGameEnds() }
        }
    }
    
    deinit {
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        gameGroupListener = nil
        // Reset VCs.
        chatroomViewController = nil
        roomViewController = nil
        // Clear group ID.
        Profiles.currentGroupID = nil
        print("✅ room vc deinit")
    }
}

// MARK: - ORKTaskViewControllerDelegate

extension RoomProgressViewController: ORKTaskViewControllerDelegate {
    private func handleCountdownStep(taskViewController: ORKTaskViewController, stepViewController: ORKActiveStepViewController) {
        // Don't show chatroom again when a player quit the chat and move on.
        if isChatroomShown {
            // When the player has left chatroom, remove player id from the array.
            FirebaseConstants.gamegroups.document(gameGroup.id!).updateData([
                "chatroomReadyUserIDs": FieldValue.arrayRemove([Profiles.userID!])
            ])
            // Call finish to automatically move to next screen. (Not valid for no timer step.)
            // stepViewController.finish()
            stepViewController.goForward()
            // Reset flag for chatroom. Not using `.toggle()` for clarity. :-)
            isChatroomShown = false
        } else {
            // Mark the player who reached chatroom step as ready.
            FirebaseConstants.gamegroups.document(gameGroup.id!).updateData([
                "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            stepViewController.title = "Leave Chat"
            stepViewController.show(chatroomViewController, sender: nil)
            // Hide the back button until all players join the chatroom.
            chatroomViewController.navigationItem.hidesBackButton = true
            // Mark chatrooom is shown for current room level.
            isChatroomShown = true
        }
    }
    
    private func handleWaitStep(taskVC: ORKTaskViewController, stepVC: ORKWaitStepViewController) {
        // Everytime the player reaches wait step, add attempts count.
        attempts += 1
        // Calculate the game result for current room.
        currentWaitStepRoomResult = GameResult(taskResults: [taskVC.result], questionnaires: [gameOfMyGroup.questionnaires[currentRoom!]])
        let progress = CGFloat(gameGroup.roomAttemptedUserIDs.count + 1) / CGFloat(gameGroup.allPlayersUserIDs.count)
        stepVC.updateText("Below is a summary of current room (for debug, UI needs update):\n\(currentWaitStepRoomResult.summary)")
        stepVC.setProgress(progress, animated: true)
        
        if !currentWaitStepRoomResult.isPassed {
            // Failed to pass the game.
            
            // First notify the other players that current player has attempted.
            FirebaseConstants.gamegroups.document(self.gameGroup.id!).updateData([
                "roomAttemptedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            
            if attempts == gameOfMyGroup.maxAttempts {
                // Then fail the local game and abort if max attempt reached.
                isMeDropped = true
                taskViewController(taskVC, didFinishWith: .failed, error: GameError.maxAttemptReached)
            }
        } else {
            let groupID = gameGroup.id!
            let userID = Profiles.userID!
            // First mark the player as finished.
            FirebaseConstants.gamegroups.document(groupID).updateData([
                "roomFinishedUserIDs": FieldValue.arrayUnion([userID])
            ]) { _ in
                // Then mark the player as attempted.
                FirebaseConstants.gamegroups.document(groupID).updateData([
                    "roomAttemptedUserIDs": FieldValue.arrayUnion([userID])
                ])
            }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        guard let step = stepViewController.step else { return }
        switch step.identifier {
        case "Countdown":
            handleCountdownStep(taskViewController: taskViewController, stepViewController: stepViewController as! ORKActiveStepViewController)
        case "Wait":
            handleWaitStep(taskVC: taskViewController, stepVC: stepViewController as! ORKWaitStepViewController)
        case "conclusion":
            // Don't allow going back to wait step from completion step.
            stepViewController.navigationItem.hidesBackButton = true
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
            // Dismiss the game controller to avoid presenting issues.
            taskViewController.dismiss(animated: true)
            // Call the did finish function to handle remaining clean up.
            if let error = error, let gameError = error as? GameError {
                roomDidFinish(withResult: .failure(gameError))
            } else if reason == .discarded {
                // Current player dropped the game.
                isMeDropped = true
                roomDidFinish(withResult: .failure(.currentPlayerDropped))
            } else {
                // This should never happen.
                isMeDropped = true
                roomDidFinish(withResult: .failure(.unknown))
            }
            // Log an unsuccessful game result.
        case .completed:
            print("✅ completed")
            // Player has passed. Reset the all arrays.
            guard let userID = Profiles.userID else { return }
            FirebaseConstants.gamegroups.document(gameGroup.id!).updateData([
                "roomAttemptedUserIDs": FieldValue.arrayRemove([userID]),
                "roomFinishedUserIDs": FieldValue.arrayRemove([userID])
            ])
            // Dismiss the game controller.
            taskViewController.dismiss(animated: true)
            roomDidFinish(withResult: .success(currentRoom!))
        @unknown default:
            fatalError("Error: Game task yields unknown result.")
        }
    }
}

// MARK: - UICollectionView

extension RoomProgressViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        if let currentLevel = currentRoom, currentLevel == room {
            presentRoom(room: room)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 96, height: 128)
    }
}

// MARK: - ChartView

extension RoomProgressViewController: ChartViewDelegate {
    private var chartCenterText: NSMutableAttributedString {
        // Center text settings.
        let centerText = NSMutableAttributedString(string: "Results\nby Jigsaw")
        centerText.setAttributes(
            [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.label],
            range: NSRange(location: 0, length: centerText.length)
        )
        centerText.addAttributes(
            [.font: UIFont(name: "HelveticaNeue-Light", size: 13)!, .foregroundColor: UIColor.systemBlue],
            range: NSRange(location: centerText.length - 6, length: 6)
        )
        return centerText
    }
    
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
        var pairs = resultPairs
        var totalCount = pairs.reduce(0) { $0 + $1.1 }
        // Show an unknown chart if no results.
        if totalCount == 0 {
            pairs = [.correct: 0, .skipped: 0, .incorrect: 0, .unknown: 1]
            totalCount = pairs.reduce(0) { $0 + $1.1 }
        }
        let entries = pairs.compactMap { (key, value) -> PieChartDataEntry? in
            if key == .unknown && value == 0 {
                // Omit .unknown category if it is empty.
                return nil
            }
            return PieChartDataEntry(
                value: Double(value) / Double(totalCount),
                label: key.label
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
