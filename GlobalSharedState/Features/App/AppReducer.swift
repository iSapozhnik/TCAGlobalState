import Foundation
import ComposableArchitecture
import Cocoa
import SwiftUI

@Reducer
struct AppReducer {
    
    @ObservableState
    struct State: Equatable {
        var playerState = PlayerState()
    }
    
    enum Action: Equatable {
        case task

        case playbackModeChanged(PlayerState.Mode)
        
        case settingsClicked
        case quitClicked
        
        case globalPlayerStateUpdated(PlayerState)
    }
    
    @Environment(\.openWindow) private var openWindow
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
            case let .globalPlayerStateUpdated(newState):
                state.playerState = newState
                return .none
                
            // Player actions - could be triggered form the main window or menu bar
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
                
            // Menu bar actions
            case .settingsClicked:
                // Open app settings here
                return .none
            case .quitClicked:
                NSApplication.shared.terminate(nil)
                return .none
            }
        }
    }
}
