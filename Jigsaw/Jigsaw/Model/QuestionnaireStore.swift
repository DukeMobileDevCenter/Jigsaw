//
//  QuestionnaireStore.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

class QuestionnaireStore {
    static let questionnaireStoreDirectory: URL = {
        let fileManager = FileManager.default
        let documentDirectories = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return documentDirectories.first!.appendingPathComponent("Questionnaires", isDirectory: true)
    }()
    
    static let shared = QuestionnaireStore()
    
    var allQuestionnaires = [(filename: String, questionnaire: Questionnaire)]()
    
    private init() {
        loadFromRemoteToMemory()
        removeAllFromDisk()
    }
    
    private func removeAllFromDisk() {
        let fileManager = FileManager.default
        let directory = QuestionnaireStore.questionnaireStoreDirectory
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: directory.path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: directory.appendingPathComponent(filePath, isDirectory: false).path)
            }
        } catch {
            print("Error: Could not clear questionnaire folder: \(error)")
        }
    }
    
    private func loadFromRemoteToMemory() {
        
    }

    private func loadFromDisk() {
        let fileManager = FileManager.default
        let directory = QuestionnaireStore.questionnaireStoreDirectory
        let decoder = JSONDecoder()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: directory.path)
            for filePath in filePaths {
                guard let fileURL = URL(string: filePath), filePath.hasSuffix("json") else { return }
                let data = try Data(contentsOf: fileURL)
                let questionnaire = try decoder.decode(Questionnaire.self, from: data)
                allQuestionnaires.append((fileURL.lastPathComponent, questionnaire))
            }
        } catch let decodingError as DecodingError {
            print("Error reading in saved items: \(decodingError)")
        } catch let nsError as NSError {
            print("NSError: \(nsError.localizedDescription)")
        } catch {
            print("Error: Could not load questionnaire with unknown error: \(error)")
        }
    }

    private func saveToDisk() throws {
        let encoder = JSONEncoder()
        let directory = QuestionnaireStore.questionnaireStoreDirectory
        do {
            for (filename, questionnaire) in allQuestionnaires {
                let data = try encoder.encode(questionnaire)
                let filePath = directory.appendingPathComponent(filename, isDirectory: false)
                try data.write(to: filePath, options: [.atomic])
            }
        } catch let encodingError as EncodingError {
            print("Error encoding allItems: \(encodingError)")
            throw encodingError
        } catch {
            print("Error: Could not save questionnaire to disk with unknown error: \(error)")
            throw error
        }
    }
}
