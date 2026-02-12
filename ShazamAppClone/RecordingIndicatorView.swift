import SwiftUI

/// Visual indicator for recording state with waveform and timer
struct RecordingIndicatorView: View {
    let isRecording: Bool
    let audioLevel: Float
    let remainingTime: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Recording indicator dot
            if isRecording {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .shadow(color: .red, radius: 5)
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.3), value: isRecording)
            }
            
            // Timer countdown
            Text(formatTime(remainingTime))
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .foregroundColor(isRecording ? .white : .gray)
                .monospacedDigit()
            
            // Waveform visualization
            WaveformView(audioLevel: audioLevel, isRecording: isRecording)
                .frame(width: 100, height: 40)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(isRecording ? 0.1 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(isRecording ? 0.3 : 0.1), lineWidth: 1)
        )
        .opacity(isRecording ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.3), value: isRecording)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

/// Waveform visualization component
struct WaveformView: View {
    let audioLevel: Float
    let isRecording: Bool
    
    @State private var animatedLevel: Float = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(width: 4, height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.1)
                        .delay(0.02 * Double(index)),
                        value: animatedLevel
                    )
            }
        }
        .onChange(of: audioLevel) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                animatedLevel = newValue
            }
        }
        .onAppear {
            animatedLevel = 0
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let normalizedIndex = CGFloat(index) / 20.0
        let baseHeight: CGFloat = 8
        let maxHeight: CGFloat = 36
        let variation = CGFloat.random(in: 0...1)
        
        let height = baseHeight + (maxHeight - baseHeight) * CGFloat(animatedLevel) * (1 - normalizedIndex * 0.5) + variation * 4
        return min(max(height, baseHeight), maxHeight)
    }
    
    private func barColor(for index: Int) -> Color {
        if isRecording {
            return Color.purple.opacity(Double(0.6 + Float(index) * 0.02))
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

/// Animated circular progress view
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        RecordingIndicatorView(
            isRecording: true,
            audioLevel: 0.7,
            remainingTime: 25
        )
        
        RecordingIndicatorView(
            isRecording: false,
            audioLevel: 0.0,
            remainingTime: 30
        )
    }
    .padding()
    .background(Color.black)
}

