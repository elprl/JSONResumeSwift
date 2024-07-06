//
//  String+Utils.swift
//  OpenCV
//
//  Created by Paul Leo on 06/07/2024.
//
import Foundation

extension String {
    var toBase64: String {
        return Data(self.utf8).base64EncodedString()
    }
    
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
