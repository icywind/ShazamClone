import Foundation
import AVFoundation
import Combine
import ShazamKit

/// Main ViewModel for coordinating Shazam song recognition
@MainActor
final class ShazamViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recognitionState: RecognitionState = .idle
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var hasPermission: Bool = false
    @Published var showPermissionAlert: Bool = false
    @Published var remainingTime: Int = 30
    
    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var durationTimer: Timer?
    private var recordingStartTime: Date?

    // MARK: - Constants

    let maxRecordingDuration: TimeInterval = 30.0
    
    // MARK: - Initialization
    
    init() {
        if ProcessInfo.isPreview {
            return   // 🚀 Skip real initialization
        }
        
        Task {
            let granted = await requestMicrophonePermission()
            if granted {
                print("Mic access granted")
            } else {
                print("Mic access denied")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Toggle recording state (start/stop)
    func toggleRecording() {
        switch recognitionState {
        case .idle, .error:
            startRecording()
        case .recording:
            stopRecording()
        case .processing:
            // Don't interrupt processing
            break
        case .matched:
            // Reset and start new recording
            resetAndStartNew()
        }
    }
    
    /// Start recording audio
    func startRecording() {
        // Check permission first

    }

    /// Stop recording audio
    func stopRecording() {

    }
    
    /// Reset and prepare for new recognition
    func resetAndStartNew() {
        recognitionState = .idle
        recordingDuration = 0
        audioLevel = 0
        remainingTime = Int(maxRecordingDuration)
    }
    
    /// Request microphone permission
    func requestPermission() {
        Task {
            // PREVIEW LOGIC TO AVOID CRASH
            if ProcessInfo.isPreview {
                hasPermission = true
                return   // 🚀 Skip real initialization
            }
            
            let granted = await requestMicrophonePermission()
            hasPermission = granted
            
            if granted {
                startRecording()
            } else {
                showPermissionAlert = true
            }
        }
    }
    
    // MARK: - Private Methods
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.recordingDuration = Date().timeIntervalSince(startTime)

                // Auto-stop at max duration
                if self.recordingDuration >= self.maxRecordingDuration {
                    self.stopRecording()
                }
            }
        }
    }

    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
}

extension ProcessInfo {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
