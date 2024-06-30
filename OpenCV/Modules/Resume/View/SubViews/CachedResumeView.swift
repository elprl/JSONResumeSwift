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
    
    var body: some View {
        VStack {
            if let resume {
                ResumeView(resume: resume)
            } else {
                ProgressView()
            }
        }
        .task {
            resume = await ResumeLoader().decodeSample(jsonString: jsonString)
        }
    }
}

#Preview {
    CachedResumeView(jsonString: "")
}
