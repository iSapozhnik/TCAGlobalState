import ComposableArchitecture
import Foundation
import Combine

struct PlayerClient {
    var play: @Sendable () async throws -> Void
    var pause: @Sendable () async throws -> Void
    var stop: @Sendable () async throws -> Void
    
    var stateStream: @Sendable () -> AsyncStream<PlayerState>
}

extension PlayerClient: DependencyKey {

    static var liveValue: PlayerClient {
        
        let player = Player()

        return Self(
            play: {
                player.play()
            },
            pause: {
                player.pause()
            },
            stop: {
                player.stop()
            },
            stateStream: {
                player.playerState.stream()
            }
        )
    }
}

extension DependencyValues {
    var player: PlayerClient {
        get { self[PlayerClient.self] }
        set { self[PlayerClient.self] = newValue }
    }
}

final class Player {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.playerState) var playerState

    private var task: Task<Void, Never>?
    
    func play() {
        playerState.modify { $0.mode = .playing }
        task = Task {
            for await _ in self.clock.timer(interval: .seconds(1)) {
                playerState.modify { $0.duration += 1 }
            }
        }
    }
    
    func stop() {
        playerState.modify { $0.mode = .stopped; $0.duration = 0 }
        task?.cancel()
        task = nil
    }
    
    func pause() {
        playerState.modify { $0.mode = .paused }
        task?.cancel()
        task = nil
    }
}
