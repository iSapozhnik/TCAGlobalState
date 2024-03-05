import Foundation
import ComposableArchitecture
import Cocoa

@Reducer
struct MainReducer {
    @ObservableState
    struct State: Equatable {
        var playerState = PlayerState()
    }
    
    enum Action: Equatable {
        case task
        
        case playbackModeChanged(PlayerState.Mode)
        
        case globalPlayerStateUpdated(PlayerState)
    }

    @Dependency(\.player) var player
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                // now we can start observing any changes in the global state
                // and sync with the local copy of the global state
                return .run { send in
                    for await newState in player.stateStream() {
                        await send(.globalPlayerStateUpdated(newState))
                    }
                }
                
            case let .playbackModeChanged(newMode):
                return .run { _ in
                    switch newMode {
                    case .playing:
                        try await player.play()
                    case .paused:
                        try await player.pause()
                    case .stopped:
                        try await player.stop()
                    }
                }
                
            case let .globalPlayerStateUpdated(newState):
                state.playerState = newState
                return .none
            }
        }
    }
}
