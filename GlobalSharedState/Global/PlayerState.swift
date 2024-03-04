import Foundation

struct PlayerState: Equatable {
    enum Mode {
        case paused
        case playing
        case stopped
    }
    
    var mode: Mode = .playing
}
