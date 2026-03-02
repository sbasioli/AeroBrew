import Foundation
import SwiftData
import Observation

@Observable
final class BrewSessionStore {
    private var modelContext: ModelContext
    private(set) var sessions: [BrewSession] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSessions()
    }

    func fetchSessions() {
        let descriptor = FetchDescriptor<BrewSession>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        let all = (try? modelContext.fetch(descriptor)) ?? []
        sessions = Array(all.prefix(100))
    }

    func addSession(_ session: BrewSession) {
        modelContext.insert(session)
        try? modelContext.save()
        fetchSessions()
    }

    func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
        try? modelContext.save()
        fetchSessions()
    }
}
