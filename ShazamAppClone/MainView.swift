import SwiftUI

/// Main view with recording functionality
struct MainView: View {
    @ObservedObject var viewModel: ShazamViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Shazam")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .purple.opacity(0.5), radius: 10)
                
                Text("Song Recognizer")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Recording indicator and button
                VStack(spacing: 20) {
                    RecordingIndicatorView(
                        isRecording: viewModel.recognitionState.isRecording,
                        audioLevel: viewModel.audioLevel,
                        remainingTime: viewModel.remainingTime
                    )
                    
                    // Main recording button
                    RecordingButton(
                        state: viewModel.recognitionState,
                        action: viewModel.toggleRecording
                    )
                    
                    // Status text
                    Text(viewModel.recognitionState.displayText)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.recognitionState)
                }
                
                Spacer()
                
                // Result card (if matched)
                if case .matched(let result) = viewModel.recognitionState {
                    SongResultView(result: result) {
                        viewModel.resetAndStartNew()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: result.id)
                }
                
                Spacer()
                
                // Footer
                Text("Tap to identify any song")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

/// Circular recording button
struct RecordingButton: View {
    let state: RecognitionState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring with pulse animation when recording
                Circle()
                    .stroke(
                        state.isRecording ? Color.purple.opacity(0.5) : Color.white.opacity(0.3),
                        lineWidth: state.isRecording ? 4 : 2
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(state.isRecording ? 1.1 : 1.0)
                    .animation(
                        state.isRecording ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default,
                        value: state.isRecording
                    )
                
                // Inner circle
                Circle()
                    .fill(
                        state.isRecording ? Color.red : 
                            (state.canStartRecording ? Color.purple : Color.gray)
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: (state.isRecording ? Color.red : Color.purple).opacity(0.5), radius: 10)
                
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .disabled(isDisabled)
        .opacity(state.canStartRecording || state.isRecording || state.isMatched ? 1.0 : 0.6)
    }
    
    private var iconName: String {
        switch state {
        case .idle, .error:
            return "waveform"
        case .recording:
            return "stop.fill"
        case .processing:
            return "waveform.path.ecg"
        case .matched:
            return "music.note"
        }
    }
    
    private var isDisabled: Bool {
        switch state {
        case .processing:
            return true
        default:
            return false
        }
    }
    
    private var isMatched: Bool {
        if case .matched = state {
            return true
        }
        return false
    }
}

#Preview {
    MainView(viewModel: ShazamViewModel())
}

