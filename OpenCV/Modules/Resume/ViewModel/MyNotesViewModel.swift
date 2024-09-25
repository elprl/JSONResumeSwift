//
//  MyNotesViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//

import Combine
import Foundation

final class MyNotesViewModel: ObservableObject {
    @Published var notes: String
    private let resumeUrl: String
    private var cancellable: AnyCancellable?

    init(resumeUrl: String) {
        self.resumeUrl = resumeUrl
        self.notes = UserDefaults.standard.string(forKey: resumeUrl) ?? ""
        
        cancellable = self.$notes
            .dropFirst()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                Log.pres.debug("note receiveCompletion")
            }, receiveValue: { newNote in
                Log.pres.debug("note receiveValue \(newNote)")
                self.saveNote(note: newNote)
            })
    }
    
    func saveNote(note: String) {
        UserDefaults.standard.setValue(note, forKey: resumeUrl)
    }
}
