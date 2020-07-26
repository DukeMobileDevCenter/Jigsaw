//
//  QuestionnaireStore.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

class QuestionnaireStore {
    static let shared = QuestionnaireStore()
    
    var allQuestionnaires = [Questionnaire]()
    
    var isLoaded: Bool {
        return !allQuestionnaires.isEmpty
    }
    
    func loadQuestionnairesToMemory() {
        let urls = loadQuestionnaireURLs()
        for url in urls {
            fetchQuestionnaire(fromURL: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let questionnaire):
                    self.allQuestionnaires.append(questionnaire)
                case .failure(let error):
                    print("Error: loading questionnaire from remote: \(error)")
                }
            }
        }
    }
    
    private func loadQuestionnaireURLs() -> [URL] {
        return [
            URL(string: "https://people.duke.edu/~tc233/hosted_files/questionnaire_v1.json")!
        ]
    }
    
    private func fetchQuestionnaire(fromURL url: URL, completion: @escaping (Result<Questionnaire, Error>) -> Void) {
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
