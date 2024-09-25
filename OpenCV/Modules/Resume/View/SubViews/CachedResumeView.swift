//
//  CachedResumeView.swift
//  OpenCV
//
//  Created by Paul Leo on 01/07/2024.
//

import SwiftUI

struct CachedResumeView: View {
    @State var resume: Resume?
    let jsonString: String
    let resumeUrl : String
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            if let resume {
                ResumeView(resume: resume, resumeUrl: resumeUrl, modelContext: modelContext)
            } else {
                ProgressView()
            }
        }
        .task {
            resume = try? await ResumeLoaderService().decodeSample(jsonString: jsonString)
        }
    }
}

#Preview {
    CachedResumeView(jsonString: "", resumeUrl: "")
}
