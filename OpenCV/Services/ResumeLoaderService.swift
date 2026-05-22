//
//  ResumeLoaderService.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//
import Foundation
import OSLog

struct ResumeLoaderService: ResumeLoaderProtocol {}

protocol ResumeLoaderProtocol {}

extension ResumeLoaderProtocol {
    
    func loadSample() async -> Resume? {
        if let jsonString = await loadJSONFromFile(fileName: "resume") { // include file in target
            Log.itr.error("JSON content: \(jsonString)")
            return try? await decodeSample(jsonString: jsonString)
        } else {
            Log.itr.error("Failed to load JSON content.")
        }
        return nil
    }
    
    func loadResume(urlString: String) async throws -> (Resume, String)? {
        guard let url = URL(string: urlString) else { return nil }
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            guard let jsonString = String(data: data, encoding: .utf8) else { throw TDAPIError.invalidJsonDecoding }
            guard let resume = try await decodeSample(jsonString: jsonString) else { throw TDAPIError.invalidJsonDecoding }
            return (resume, jsonString)
        }
        catch {
            // Error handling in case the data couldn't be loaded
            // For now, only display the error on the console
            Log.itr.error("Error loading \(url): \(String(describing: error))")
            throw error
        }
    }
    
    func loadJSONFromFile(fileName: String = "sampleResume") async -> String? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            Log.itr.error("File not found.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return String(data: data, encoding: .utf8)
        } catch {
            Log.itr.error("Error reading file: \(error)")
            return nil
        }
    }
    
    func decodeSample(jsonString: String) async throws -> Resume? {
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
                Log.itr.error("Error: \(error)")
                throw TDAPIError.invalidJsonDecoding
            }
        }
        throw TDAPIError.invalidJsonDecoding
    }
}
