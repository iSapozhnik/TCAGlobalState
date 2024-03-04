import Foundation
import ComposableArchitecture
import Combine

@dynamicMemberLookup
struct PlayerClient: Sendable {
    var get: @Sendable () -> PlayerState
    var set: @Sendable (PlayerState) -> Void
    
    var stream: @Sendable () -> AsyncStream<PlayerState>
    
    func modify(_ operation: (inout PlayerState) -> Void) {
        var me = self.get()
        operation(&me)
        self.set(me)
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<PlayerState, Value>) -> Value {
        self.get()[keyPath: keyPath]
    }
}

extension PlayerClient: DependencyKey {
    static var liveValue: PlayerClient {
        let recording = LockIsolated(PlayerState())
        let subject = PassthroughSubject<PlayerState, Never>()
        return PlayerClient(
            get: { recording.value },
            set: {
                recording.setValue($0)
                subject.send($0)
            },
            stream: { subject.values.eraseToStream() }
        )
    }
}

extension DependencyValues {
    var player: PlayerClient {
        get { self[PlayerClient.self] }
        set { self[PlayerClient.self] = newValue }
    }
}
