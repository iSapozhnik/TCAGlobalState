import SwiftUI
import ComposableArchitecture

@main
struct GlobalSharedStateApp: App {
    private let store: StoreOf<AppReducer> = {
        @Dependency(\.player) var player
        
        return .init(
            initialState: .init(playerState: .init(mode: player.get().mode)), 
            reducer: { AppReducer() }
        )
    }()
    
    var body: some Scene {
        RootScene(store: store)
    }
}
