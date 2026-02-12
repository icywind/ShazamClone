import Foundation

/// Enum representing the current state of song recognition
enum RecognitionState: Equatable {
    case idle
    case recording
    case processing
    case matched(SongRecognitionResult)
    case error(String)
    
    var displayText: String {
        switch self {
        case .idle:
            return "Tap to identify"
        case .recording:
            return "Tap to cancel"
        case .processing:
            return "Identifying..."
        case .matched:
            return "Song Found!"
        case .error(let message):
            print (message)
            return message
        }
    }
    
    var isRecording: Bool {
        if case .recording = self {
            return true
        }
        return false
    }
    
    var canStartRecording: Bool {
        if case .idle = self {
            return true
        }
        if case .error = self {
            return true
        }
        return false
    }
    
    var isMatched: Bool {
        if case .matched = self {
            return true
        }
        return false
    }
    
    static func == (lhs: RecognitionState, rhs: RecognitionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.recording, .recording):
            return true
        case (.processing, .processing):
            return true
        case (.matched(let lhsResult), .matched(let rhsResult)):
            return lhsResult == rhsResult
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

