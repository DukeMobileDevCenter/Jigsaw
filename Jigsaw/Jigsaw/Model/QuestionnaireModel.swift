//
//  QuestionnaireModel.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import ResearchKit

struct Questionnaire: Codable {
    let version: Int
    let questions: [Question]

    init(version: Int, list: [Question]) {
        self.version = version
        self.questions = list
    }
    
    static func load(fromURL url: URL, completion: @escaping (Result<Questionnaire, Error>) -> Void) {
        let decoder = JSONDecoder()
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                // text/plain text/html application/json
                if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data {
                    do {
                        let decoded = try decoder.decode(Questionnaire.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct Question: Codable {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let choices: [Choice]
    let custom: String
    let optional: Bool

    init(questionType: String, title: String, prompt: String, choices: [Choice], custom: String, optional: Bool) {
//        self.questionType = QuestionType(rawValue: questionType)
        
        switch questionType {
        case "INSTRUCTION":
            self.questionType = .instruction
        case "MULTIPLE CHOICE":
            self.questionType = .multipleChoice
        case "SINGLE CHOICE":
            self.questionType = .singleChoice
        case "NUMERIC":
            self.questionType = .numeric
        case "MAP":
            self.questionType = .map
        case "SCALE":
            self.questionType = .scale
        default:
            self.questionType = .unknown
        }
        
        self.title = title
        self.prompt = prompt
        self.choices = choices
        self.custom = custom
        self.optional = optional
    }
}

enum QuestionType: String, Codable {
    case instruction = "INSTRUCTION"
    case multipleChoice = "MULTIPLE CHOICE"
    case singleChoice = "SINGLE CHOICE"
    case numeric = "NUMERIC"
    case map = "MAP"
    case scale = "SCALE"
    case unknown = "UNKNOWN"
}

struct Choice: Codable {
    let text: String
    let value: String

    init(text: String, value: String) {
        self.text = text
        self.value = value
    }
}
