//
//  PopulateGames.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class PopulateGames {
    static let shared = PopulateGames()
    
    func uploadGame() {
        let data = jsonStringUSImmigration1.data(using: .utf8)!
        let decoder = JSONDecoder()
        let db = Firestore.firestore()
        do {
            let decoded = try decoder.decode(Game.self, from: data)
            try db.collection("Games").document(decoded.gameName).setData(from: decoded)
        } catch {
            print(error)
        }
    }
    
    let jsonStringUSImmigration1: String =
    """
    {
      "gameName": "USImmigration1",
      "version": "200808",
      "g1resURL": "https://githubschool.github.io/github-games-yo1995/JigsawBetaHost/USImmigration1/Group1Resource/",
      "g2resURL": "https://githubschool.github.io/github-games-yo1995/JigsawBetaHost/USImmigration1/Group2Resource/",
      "backgroundImageURL": "https://images.unsplash.com/photo-1559282136-1d3983a48c7b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=80",
      "category": "immigration",
      "g1Questionnaire": [
        {
          "questionType": "INSTRUCTION",
          "title": "Required Questions",
          "prompt": "The following questions are essential for the search. Please answer carefully.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q1: Energy",
          "prompt": "How long can you be active today?",
          "choices": [
            {
              "text": "20 min or less",
              "value": "19"
            },
            {
              "text": "30 min",
              "value": "29"
            },
            {
              "text": "45 min",
              "value": "44"
            },
            {
              "text": "60 min",
              "value": "59"
            },
            {
              "text": "more than 60 min",
              "value": "999"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q2: Indoor",
          "prompt": "Do you want to be inside or outside?",
          "choices": [
            {
              "text": "inside",
              "value": "TRUE"
            },
            {
              "text": "outside",
              "value": "FALSE"
            },
            {
              "text": "either",
              "value": "BOTH"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "NUMERIC",
          "title": "Q3: Age",
          "prompt": "Please provide your age.",
          "choices": [],
          "custom": "unit:years old, range:1-99",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q4: Distance",
          "prompt": "What distance are you willing to travel to be active today",
          "choices": [
            {
              "text": "2 miles",
              "value": "2"
            },
            {
              "text": "5 miles",
              "value": "5"
            },
            {
              "text": "10 miles",
              "value": "10"
            },
            {
              "text": "doesn’t matter",
              "value": "100"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "MAP",
          "title": "Q5: Location",
          "prompt": "Please pick a location.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "INSTRUCTION",
          "title": "Optional Questions",
          "prompt": "The following questions are optional. More questions answered, more accurate the result will be.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SCALE",
          "title": "Q6: Willingness",
          "prompt": "Please evaluate how you feel about going outside today.",
          "choices": [],
          "custom": "range:0-10, step:1, default:5, maxdesc:Very likely, mindesc: Very unlikely",
          "optional": true
        },
        {
          "questionType": "MULTIPLE CHOICE",
          "title": "Q7: Multiple",
          "prompt": "Just a multiple choice test.",
          "choices": [
            {
              "text": "pick 0",
              "value": "0"
            },
            {
              "text": "pick 1",
              "value": "1"
            },
            {
              "text": "pick 2",
              "value": "2"
            }
          ],
          "custom": "",
          "optional": true
        }
      ],
      "g2Questionnaire": [
        {
          "questionType": "INSTRUCTION",
          "title": "Required Questions",
          "prompt": "The following questions are essential for the search. Please answer carefully.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q1: Energy",
          "prompt": "How long can you be active today?",
          "choices": [
            {
              "text": "20 min or less",
              "value": "19"
            },
            {
              "text": "30 min",
              "value": "29"
            },
            {
              "text": "45 min",
              "value": "44"
            },
            {
              "text": "60 min",
              "value": "59"
            },
            {
              "text": "more than 60 min",
              "value": "999"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q2: Indoor",
          "prompt": "Do you want to be inside or outside?",
          "choices": [
            {
              "text": "inside",
              "value": "TRUE"
            },
            {
              "text": "outside",
              "value": "FALSE"
            },
            {
              "text": "either",
              "value": "BOTH"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "NUMERIC",
          "title": "Q3: Age",
          "prompt": "Please provide your age.",
          "choices": [],
          "custom": "unit:years old, range:1-99",
          "optional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q4: Distance",
          "prompt": "What distance are you willing to travel to be active today",
          "choices": [
            {
              "text": "2 miles",
              "value": "2"
            },
            {
              "text": "5 miles",
              "value": "5"
            },
            {
              "text": "10 miles",
              "value": "10"
            },
            {
              "text": "doesn’t matter",
              "value": "100"
            }
          ],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "MAP",
          "title": "Q5: Location",
          "prompt": "Please pick a location.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "INSTRUCTION",
          "title": "Optional Questions",
          "prompt": "The following questions are optional. More questions answered, more accurate the result will be.",
          "choices": [],
          "custom": "",
          "optional": false
        },
        {
          "questionType": "SCALE",
          "title": "Q6: Willingness",
          "prompt": "Please evaluate how you feel about going outside today.",
          "choices": [],
          "custom": "range:0-10, step:1, default:5, maxdesc:Very likely, mindesc: Very unlikely",
          "optional": true
        },
        {
          "questionType": "MULTIPLE CHOICE",
          "title": "Q7: Multiple",
          "prompt": "Just a multiple choice test.",
          "choices": [
            {
              "text": "pick 0",
              "value": "0"
            },
            {
              "text": "pick 1",
              "value": "1"
            },
            {
              "text": "pick 2",
              "value": "2"
            }
          ],
          "custom": "",
          "optional": true
        }
      ]
    }
    """
}
