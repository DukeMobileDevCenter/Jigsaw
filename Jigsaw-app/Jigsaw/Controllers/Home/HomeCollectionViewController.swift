//
//  HomeCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeCollectionViewController: UICollectionViewController {
    /// The flow layout of the collection view.
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
//        show(reviewVC, sender: sender)
//        let vc = ChatViewController(user: currentUser, chatroom: "zY40mIdv1xnSxyB9GVPK")
        let chatroomRef = Firestore.firestore().collection("Chatrooms")
        chatroomRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                if let chatroom = Chatroom(document: change.document), chatroom.id == "TestChatroom1" {
                    let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom)
                    self.show(chatroomVC, sender: sender)
                }
            }
        }
//        do {
//            let chatroom = Chatroom(name: "US1")
//            _ = try chatroomRef.document(chatroom.id!).setData(from: chatroom)
//        } catch {
//            print("Error saving chatroom: \(error.localizedDescription)")
//        }
//
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameStore.shared
        
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let games):
                // Update collection view UI here.
                DispatchQueue.main.async {
                    print(games.count)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
                print("Error: loading games from remote: \(error)")
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                // For future decision on either game or category.
                print("Index path \(selectedIndexPath).")
                let destinationVC = segue.destination as! MatchingViewController
                destinationVC.games = GameStore.shared.allGames
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.bounds.inset(by: collectionView.safeAreaInsets).size
        let spacing: CGFloat = 10
        // First, try for 3 items in a row.
        var width = (collectionViewSize.width - 4 * spacing) / 3
        if width < 150 {
            // If device width too small, go for 2 in a row.
            width = (collectionViewSize.width - 3 * spacing) / 2
        }
        return CGSize(width: width, height: width)
    }
}
