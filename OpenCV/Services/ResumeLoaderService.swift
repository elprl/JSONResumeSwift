//
//  ResumeLoaderService.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//
import Foundation

struct ResumeLoaderService: ResumeLoaderProtocol {}

protocol ResumeLoaderProtocol {}

extension ResumeLoaderProtocol {
    
    func loadSample() async -> Resume? {
        if let jsonString = await loadJSONFromFile(fileName: "resume") {
            print("JSON content: \(jsonString)")
            return await decodeSample(jsonString: jsonString)
        } else {
            print("Failed to load JSON content.")
        }
        return nil
    }
    
    func loadResume(urlString: String) async throws -> (Resume, String)? {
        guard let url = URL(string: urlString) else { return nil }
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
            guard let resume = await decodeSample(jsonString: jsonString) else { return nil }
            return (resume, jsonString)
        }
        catch {
            // Error handling in case the data couldn't be loaded
            // For now, only display the error on the console
            debugPrint("Error loading \(url): \(String(describing: error))")
            throw error
        }
    }
    
    func loadJSONFromFile(fileName: String = "sampleResume") async -> String? {
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
    
    func decodeSample(jsonString: String) async -> Resume? {
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
