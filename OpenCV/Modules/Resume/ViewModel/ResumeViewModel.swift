//
//  ResumeViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//
import Foundation
import Combine

final class ResumeViewModel: ObservableObject {
    @Published var resume: Resume?
    
    @MainActor
    func loadResume() async {
        if let resume = await SampleLoader().loadSample() {
            self.resume = resume
        }
    }
}

struct SampleLoader {
    
    func loadSample() async -> Resume? {
        if let jsonString = await loadJSONFromFile(fileName: "resume") {
            print("JSON content: \(jsonString)")
            return await decodeSample(jsonString: jsonString)
        } else {
            print("Failed to load JSON content.")
        }
        return nil
    }
    
    private func loadJSONFromFile(fileName: String = "sampleResume") async -> String? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("File not found.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
    
    private func decodeSample(jsonString: String) async -> Resume? {
        // Convert JSON string to Data
        if let jsonData = jsonString.data(using: .utf8) {
            
            // Create the date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Decode JSON data to Resume model
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            do {
                let resume = try decoder.decode(Resume.self, from: jsonData)
                return resume
            } catch {
                print("Error: \(error)")
            }
        }
        return nil
    }
}
