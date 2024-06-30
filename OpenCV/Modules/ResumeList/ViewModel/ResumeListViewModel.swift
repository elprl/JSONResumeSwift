//
//  EmployeeListViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import Combine

final class ResumeListViewModel: ObservableObject {
    @Published var resumes: [Person] = []
}
