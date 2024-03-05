import Foundation
import ComposableArchitecture

struct PlayerState: Equatable {
    enum Mode {
        case paused
        case playing
        case stopped
    }
    
    var mode: Mode = .stopped
    var duration: TimeInterval = 0
}
