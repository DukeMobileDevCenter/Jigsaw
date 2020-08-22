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
        let database = Firestore.firestore()
        do {
            let decoded = try decoder.decode(Game.self, from: data)
            try database.collection("Games").document(decoded.gameName).setData(from: decoded)
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
          "questionType": "SINGLE CHOICE",
          "title": "Q1: Policy",
          "prompt": "What particular immigration-related policy does Buttigieg explicitly support?",
          "choices": [
            {
              "text": "Family-based immigration",
              "value": "0"
            },
            {
              "text": "Diversity visas",
              "value": "1"
            },
            {
              "text": "DACA",
              "value": "2"
            },
            {
              "text": "Temporary protected status",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q2: Law",
          "prompt": "What kind of law does Buttigieg think Congress should pass?",
          "choices": [
            {
              "text": "A law creating a pathway to citizenship for young undocumented immigrants who entered the country illegally as children.",
              "value": "0"
            },
            {
              "text": "A law creating a pathway to citizenship for children entering the country illegally.",
              "value": "1"
            },
            {
              "text": "A law creating a pathway to citizenship for family members of U.S. citizens or green card holders",
              "value": "2"
            },
            {
              "text": "A law inhibiting refugee immigration to the U.S.",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q3: Campaign",
          "prompt": "What is one key shortcoming of Buttigieg’s campaign?",
          "choices": [
            {
              "text": "It proposes policies that are not implementable in a reasonable timeframe",
              "value": "0"
            },
            {
              "text": "It has not outlined any new policy measures",
              "value": "1"
            },
            {
              "text": "It proposes policies that are too expensive to implement",
              "value": "2"
            },
            {
              "text": "It has not outlined substantial policy measures that would support his goal of comprehensive immigration reform.",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q4: Values",
          "prompt": "What values related to immigration does Buttigieg think the U.S. needs to reflect as a nation?",
          "choices": [
            {
              "text": "Equality - especially equal opportunity for all human beings.",
              "value": "0"
            },
            {
              "text": "Humanitarian values - especially humanitarian relief for refugees.",
              "value": "1"
            },
            {
              "text": "Values related to liberty - especially the freedom to pursue a better life",
              "value": "2"
            },
            {
              "text": "Economic values that promote fair wealth distribution.",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q5: Practice",
          "prompt": "What is one particular immigration-related practice that Buttigieg wants to prevent?",
          "choices": [
            {
              "text": "Refusing entry to refugees.",
              "value": "0"
            },
            {
              "text": "The separation of families at the U.S.-Mexico border.",
              "value": "1"
            },
            {
              "text": "Limiting H1-B visas to highly skilled foreign workers.",
              "value": "2"
            },
            {
              "text": "The arbitrary targeting of immigrant families by ICE.",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q6: Opposition",
          "prompt": "Buttigeig opposes ___ deportation policies.",
          "choices": [
            {
              "text": "aggressive",
              "value": "0"
            },
            {
              "text": "inhumane",
              "value": "1"
            },
            {
              "text": "lenient",
              "value": "2"
            },
            {
              "text": "unconstitutional",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SINGLE CHOICE",
          "title": "Q7",
          "prompt": "Castro’s People First Immigration Policy",
          "choices": [
            {
              "text": "provides a pathway to citizenship for people who are in the country unlawfully",
              "value": "0"
            },
            {
              "text": "Castro has not already unveiled his People First Immigration Policy",
              "value": "1"
            },
            {
              "text": "Reverses Trump’s travel ban",
              "value": "2"
            },
            {
              "text": "All of the above",
              "value": "3"
            }
          ],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "INSTRUCTION",
          "title": "Optional Questions",
          "prompt": "The following questions are optional. Just to demonstrate other question types.",
          "choices": [],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "NUMERIC",
          "title": "Q1: Age",
          "prompt": "Please provide your age.",
          "choices": [],
          "custom": "unit:years old, range:1-99",
          "isOptional": false
        },
        {
          "questionType": "SCALE",
          "title": "Q2: Willingness",
          "prompt": "Please evaluate how you feel about going outside today.",
          "choices": [],
          "custom": "range:0-10, step:1, default:5, maxdesc:Very likely, mindesc: Very unlikely",
          "isOptional": true
        },
        {
          "questionType": "MULTIPLE CHOICE",
          "title": "Q3: Multiple",
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
          "isOptional": true
        }
      ],
      "g2Questionnaire": [
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
          "isOptional": false
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
          "isOptional": false
        },
        {
          "questionType": "NUMERIC",
          "title": "Q3: Age",
          "prompt": "Please provide your age.",
          "choices": [],
          "custom": "unit:years old, range:1-99",
          "isOptional": false
        },
        {
          "questionType": "INSTRUCTION",
          "title": "isOptional Questions",
          "prompt": "The following questions are isOptional. More questions answered, more accurate the result will be.",
          "choices": [],
          "custom": "",
          "isOptional": false
        },
        {
          "questionType": "SCALE",
          "title": "Q6: Willingness",
          "prompt": "Please evaluate how you feel about going outside today.",
          "choices": [],
          "custom": "range:0-10, step:1, default:5, maxdesc:Very likely, mindesc: Very unlikely",
          "isOptional": true
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
          "isOptional": true
        }
      ]
    }
    """
}
