import Foundation
import AVFoundation
import Combine
import ShazamKit

/// Main ViewModel for coordinating Shazam song recognition
@MainActor
final class ShazamViewModel: NSObject, ObservableObject {

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
    private var remainingTimeTimer: Timer?
    private var recordingStartTime: Date?

    // Audio and ShazamKit properties
    private let audioEngine = AVAudioEngine()
    private var shazamSession: SHSession?
    private var audioLevelTimer: Timer?

    // MARK: - Constants

    let maxRecordingDuration: TimeInterval = 30.0
    
    // MARK: - Initialization

    override init() {
        super.init()

        if ProcessInfo.isPreview {
            return   // 🚀 Skip real initialization
        }

        // Initialize ShazamKit session
        shazamSession = SHSession()
        shazamSession?.delegate = self

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
    
    /// Toggle recording state (start/stop/cancel)
    func toggleRecording() {
        switch recognitionState {
        case .idle, .error:
            startRecording()
        case .recording:
            cancelRecording()
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
        guard hasPermission else {
            requestPermission()
            return
        }

        // Prevent starting if already recording or processing
        guard recognitionState == .idle || recognitionState == .error(recognitionState.displayText) else {
            return
        }

        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // Get input node
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            // Install tap on input node to capture audio
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
                guard let self = self else { return }

                // Send audio buffer to ShazamKit
                self.shazamSession?.matchStreamingBuffer(buffer, at: time)

                // Calculate audio level for visualization
                Task { @MainActor in
                    self.updateAudioLevel(from: buffer)
                }
            }

            // Start audio engine
            try audioEngine.start()

            // Update state
            recognitionState = .recording
            recordingStartTime = Date()
            remainingTime = Int(maxRecordingDuration)

            // Start timers
            startDurationTimer()
            startRemainingTimeTimer()

            print("✅ Recording started")

        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
            recognitionState = .error("Failed to start recording")
        }
    }

    /// Stop recording audio and process
    func stopRecording() {
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        // Stop timers
        stopDurationTimer()
        stopRemainingTimeTimer()
        stopAudioLevelTimer()

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error.localizedDescription)")
        }

        // Update state to processing
        recognitionState = .processing
        audioLevel = 0

        print("⏹️ Recording stopped, processing...")
    }

    /// Cancel recording without processing
    func cancelRecording() {
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        // Stop timers
        stopDurationTimer()
        stopRemainingTimeTimer()
        stopAudioLevelTimer()

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error.localizedDescription)")
        }

        // Reset to idle state without processing
        recognitionState = .idle
        recordingDuration = 0
        audioLevel = 0
        remainingTime = Int(maxRecordingDuration)

        print("❌ Recording canceled")
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

    private func startRemainingTimeTimer() {
        remainingTime = Int(maxRecordingDuration)
        remainingTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.remainingTime = max(0, Int(self.maxRecordingDuration - self.recordingDuration))
            }
        }
    }

    private func stopRemainingTimeTimer() {
        remainingTimeTimer?.invalidate()
        remainingTimeTimer = nil
    }

    private func stopAudioLevelTimer() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
    }

    /// Clean up recording resources (audio engine, timers, session)
    private func cleanupRecording() {
        // Stop audio engine if running
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        // Stop all timers
        stopDurationTimer()
        stopRemainingTimeTimer()
        stopAudioLevelTimer()

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error.localizedDescription)")
        }

        // Reset properties
        audioLevel = 0
        recordingStartTime = nil
        recordingDuration = 0
    }

    /// Calculate audio level from buffer for visualization
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }

        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        let normalizedLevel = max(0, min(1, (avgPower + 50) / 50))

        audioLevel = normalizedLevel
    }
}

// MARK: - SHSessionDelegate

extension ShazamViewModel: SHSessionDelegate {
    nonisolated func session(_ session: SHSession, didFind match: SHMatch) {
        Task { @MainActor in
            print("🎵 Match found!")

            // Get the best match
            guard let mediaItem = match.mediaItems.first,
                  let result = SongRecognitionResult(from: mediaItem) else {
                recognitionState = .error("No match found")
                cleanupRecording()
                return
            }

            // Clean up recording resources
            cleanupRecording()

            // Update state with result
            recognitionState = .matched(result)
            print("✅ Song: \(result.title) by \(result.artist)")
        }
    }

    nonisolated func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        Task { @MainActor in
            print("❌ No match found")

            // Clean up recording resources
            cleanupRecording()

            if let error = error {
                print("Error: \(error.localizedDescription)")
                recognitionState = .error("Recognition failed: \(error.localizedDescription)")
            } else {
                recognitionState = .error("No match found")
            }
        }
    }
}

extension ProcessInfo {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
