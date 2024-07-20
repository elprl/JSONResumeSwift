//
//  QRCodeGeneratorService.swift
//  OpenCV
//
//  Created by Paul Leo on 04/07/2024.
//
import UIKit
import CoreImage

protocol CodeGeneratorServiceProtocol { 
    func generateCode(from string: String) -> UIImage?
}

struct QRCodeGenerator  { }

extension QRCodeGenerator: CodeGeneratorServiceProtocol{
    
    func generateCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            if let output = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledOutput = output.transformed(by: transform)
                if let cgImage = CIContext().createCGImage(scaledOutput, from: scaledOutput.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
}
