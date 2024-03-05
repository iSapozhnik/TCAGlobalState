import Foundation
import ComposableArchitecture
import Combine

@dynamicMemberLookup
struct PlayerStateClient: Sendable {
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

extension PlayerStateClient: DependencyKey {
    static var liveValue: PlayerStateClient {
        let playerState = LockIsolated(PlayerState())
        let subject = PassthroughSubject<PlayerState, Never>()
        return PlayerStateClient(
            get: { playerState.value },
            set: {
                playerState.setValue($0)
                subject.send($0)
            },
            stream: { subject.values.eraseToStream() }
        )
    }
}

extension DependencyValues {
    var playerState: PlayerStateClient {
        get { self[PlayerStateClient.self] }
        set { self[PlayerStateClient.self] = newValue }
    }
}
