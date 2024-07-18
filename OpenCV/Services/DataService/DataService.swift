//
//  DataService.swift
//  OpenCV
//
//  Created by Paul Leo on 18/07/2024.
//

import Foundation
import SwiftData

/// ```swift
///  // It is important that this actor works as a mutex,
///  // so you must have one instance of the Actor for one container
//   // for it to work correctly.
///  let actor = BackgroundSerialPersistenceActor(container: modelContainer)
///
///  Task {
///      let data: [MyModel] = try? await actor.fetchData()
///  }
///  ```
@available(iOS 17, *)
@ModelActor
actor DataService<T> where T : PersistentModel {}

extension DataService {

    public func fetchData(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try modelContext.fetch(fetchDescriptor)
        return list
    }
    
    public func fetchDataIds(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [PersistentIdentifier] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.id})
    }

    public func fetchCount(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> Int {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let count = try modelContext.fetchCount(fetchDescriptor)
        return count
    }

    public func insert(data: T) {
        modelContext.insert(data)
    }

    public func save() throws {
        try modelContext.save()
    }

    public func remove(predicate: Predicate<T>? = nil) throws {
        try modelContext.delete(model: T.self, where: predicate)
    }
    
    public func remove(id: PersistentIdentifier) {
        if let item = modelContext.model(for: id) as? T {
            modelContext.delete(item)
        }
    }

    public func saveAndInsertIfNeeded(
        data: T,
        predicate: Predicate<T>
    ) throws {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let savedCount = try modelContext.fetchCount(descriptor)

        if savedCount == 0 {
            modelContext.insert(data)
        }
        try modelContext.save()
    }
}
