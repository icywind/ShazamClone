# 🎵 ShazamAppClone

A modern iOS music recognition app built with SwiftUI and Apple's ShazamKit framework. Identify songs playing around you with a beautiful, intuitive interface.

![iOS](https://img.shields.io/badge/iOS-16.6+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

<p align="Left">
  <img src="Docs/ScreenShots.png" alt="Shazam App Screenshots" style="max-width:90%; height:auto;">
</p>


## ✨ Features

- 🎤 **Real-time Audio Recognition** - Identify songs using Apple's ShazamKit
- 🎨 **Modern UI** - Beautiful dark theme with purple/pink gradients
- 📊 **Visual Feedback** - Animated waveforms and audio level indicators
- ⏱️ **Smart Recording** - 30-second max duration with countdown timer
- ❌ **Cancel Anytime** - Tap to cancel recording before processing
- 🎵 **Detailed Results** - View song title, artist, album art, and metadata
- 🔗 **Quick Actions** - Open in Apple Music or web browser
- 🔄 **Smooth Navigation** - Full-screen detail view with native iOS navigation

## 📱 Screenshots

<!-- Add screenshots here when available -->

## 🛠️ Technologies

- **SwiftUI** - Modern declarative UI framework
- **ShazamKit** - Apple's audio recognition framework
- **AVFoundation** - Audio recording and processing
- **Combine** - Reactive programming for state management
- **Swift Concurrency** - Async/await and actors for thread safety

## 🏗️ Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

```
ShazamAppClone/
├── Models/
│   ├── RecognitionState.swift      # State machine for recognition flow
│   └── SongRecognitionResult.swift # Song data model
├── Views/
│   ├── ContentView.swift           # Root navigation container
│   ├── MainView.swift              # Main recording interface
│   ├── RecordingIndicatorView.swift # Waveform and timer display
│   └── SongResultView.swift        # Song detail views
├── ViewModels/
│   └── ShazamViewModel.swift       # Core business logic
└── ShazamAppCloneApp.swift         # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.6+ deployment target
- macOS 13.0+ (for development)
- Apple Developer account (for device testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ShazamAppClone.git
   cd ShazamAppClone
   ```

2. **Open in Xcode**
   ```bash
   open ShazamAppClone.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run
   - Grant microphone permissions when prompted

### Configuration

No additional configuration or API keys required! ShazamKit is built into iOS.

## 📖 Usage

1. **Start Recording**
   - Tap the purple waveform button
   - The button turns red and displays an "X" icon

2. **Cancel Recording**
   - Tap the red button while recording
   - Returns to idle state without processing

3. **View Results**
   - Wait for recognition to complete
   - Tap the result card to view full details
   - Use action buttons to open in Apple Music or browser

4. **Start New Recognition**
   - Tap "Recognize Another Song" from detail view
   - Or tap the green button from main screen

## 🎯 Key Components

### ShazamViewModel
Core ViewModel managing:
- Audio recording with `AVAudioEngine`
- ShazamKit session and streaming
- State management and timers
- Microphone permissions

### RecognitionState
State machine with five states:
- `idle` - Ready to start
- `recording` - Actively listening
- `processing` - Analyzing audio
- `matched(result)` - Song found
- `error(message)` - Recognition failed

### SongRecognitionResult
Model containing:
- Song title and artist
- Album artwork URL
- Apple Music and web URLs
- Genres and metadata
- ISRC code and timestamp

## 🎨 UI/UX Highlights

- **Pulsing Animations** - Button pulses during recording and when matched
- **Color-Coded States** - Purple (idle), Red (recording), Gray (processing), Green (matched)
- **Real-time Waveform** - Visual audio level feedback
- **Countdown Timer** - Shows remaining recording time
- **Smooth Transitions** - Native iOS navigation with custom styling

## 🔧 Technical Details

### Audio Processing
- Sample rate: 44.1 kHz
- Buffer size: 4096 frames
- RMS-based audio level calculation
- Streaming recognition for faster results

### State Management
- `@Published` properties for reactive UI updates
- `@MainActor` for thread-safe UI operations
- Combine framework for cancellable subscriptions

### Timer Management
- Duration timer (0.1s intervals)
- Remaining time countdown (1s intervals)
- Audio level updates (0.05s intervals)
- Automatic cleanup on completion

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple's ShazamKit framework
- SwiftUI community
- Shazam for inspiration

## 👨‍💻 Author

Rick Cheng - [@rickcheng14](https://twitter.com/rickcheng14)

## 🐛 Known Issues

None at this time. Please report issues on GitHub.

## 🚧 Future Enhancements

- [ ] Recognition history
- [ ] Favorites/bookmarks
- [ ] Share functionality
- [ ] Dark/light mode toggle
- [ ] Haptic feedback
- [ ] Widget support
- [ ] iPad optimization

---

**Note**: This is an educational project demonstrating ShazamKit integration. It is not affiliated with Shazam Entertainment Limited.

