//
//  PopulateGamesFromYAML.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Yams

class PopulateGamesFromYAML {
    static let shared = PopulateGamesFromYAML()
    
    func uploadGame() {
        let database = Firestore.firestore()
        do {
            let data = try Yams.load(yaml: yamlString) as? [String: Any]
            if let loadedDictionary = data {
                database.collection("Games2").document(loadedDictionary["gameName"] as! String).setData(loadedDictionary)
            } else {
                print("cannot cast yaml to dictionary")
            }
        } catch {
            print(error)
        }
    }
    
    let yamlString =
    """
    gameName: "USImmigration1"
    version: "200808"
    g1resURL: "https://githubschool.github.io/github-games-yo1995/JigsawBetaHost/USImmigration1/Group1Resource/"
    g2resURL: "https://githubschool.github.io/github-games-yo1995/JigsawBetaHost/USImmigration1/Group2Resource/"
    backgroundImageURL: "https://images.unsplash.com/photo-1559282136-1d3983a48c7b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=80"
    category: "immigration"
    g1Questionnaire:
      - questionType: "INSTRUCTION"
        title: "This is an instruction"
        prompt: "Provide instructional information in this step."
        isOptional: false
      - questionType: "SINGLE CHOICE"
        title: "Q1: Policy"
        prompt: "What particular immigration-related policy does Buttigieg explicitly support?"
        choices:
          - "Family-based immigration"
          - "Diversity visas"
          - "DACA"
          - "Temporary protected status"
        correctAnswer: "Family-based immigration"
        isOptional: false
      - questionType: "MULTIPLE CHOICE"
        title: "Q2: Multiple choice example"
        prompt: "A multiple choice example."
        choices:
          - "Pick 0"
          - "Pick 1"
          - "Pick 2"
          - "Pick 3"
        correctAnswers:
          - "Pick 1"
          - "Pick 3"
        isOptional: false
      - questionType: "NUMERIC"
        title: "Q3: Numeric question example"
        prompt: "A numeric question example."
        unit: "years old"
        minValue: 0
        maxValue: 99
        correctMinValue: 25
        correctMaxValue: 30
        isOptional: false
      - questionType: "SCALE"
        title: "Q4: Scale question example"
        prompt: "A scale question example."
        minDescription: "Very unlikely"
        maxDescription: "Very likely"
        minValue: 0
        maxValue: 10
        defaultValue: 5
        step: 1
        correctMinValue: 5
        correctMaxValue: 6
        isOptional: false
      - questionType: "BOOLEAN"
        title: "Q5: True or false example"
        prompt: "A boolean question example."
        trueDescription: "This is true"
        falseDescription: "This is false"
        correctAnswer: true
        isOptional: false
      - questionType: "SINGLE CHOICE"
        title: "Q6: Optional question"
        prompt: "This might be a bonus question, and allows user to skip."
        choices:
          - "Pick 0"
          - "Pick 1"
          - "Pick 2"
          - "Pick 3"
        correctAnswer: "Pick 0"
        isOptional: true
    g2Questionnaire:
      - questionType: "INSTRUCTION"
        title: "This is an instruction"
        prompt: "Provide instructional information in this step."
        isOptional: false
      - questionType: "SINGLE CHOICE"
        title: "Q1: Dummy"
        prompt: "You can define another set of questions for the other game group."
        choices:
          - "A"
          - "B"
          - "C"
          - "D"
        correctAnswer: "A"
        isOptional: false
    """
}
