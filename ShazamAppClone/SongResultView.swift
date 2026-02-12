import SwiftUI

/// Full-screen detail view for recognized song
struct SongResultDetailView: View {
    let result: SongRecognitionResult
    let onDismiss: () -> Void

    @State private var artworkImage: UIImage?
    @State private var isLoadingArtwork = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 20)

                    // Album artwork
                    ZStack {
                        if let artworkImage = artworkImage {
                            Image(uiImage: artworkImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            placeholderImage
                        }

                        if isLoadingArtwork {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 250, height: 250)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(20)
                        }
                    }
                    .frame(width: 250, height: 250)
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.6), radius: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                    // Song title
                    Text(result.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Artist name
                    Text(result.artist)
                        .font(.title2)
                        .foregroundColor(.purple.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Additional info
                    VStack(spacing: 12) {
                        if let subtitle = result.subtitle {
                            HStack {
                                Image(systemName: "music.note.list")
                                    .foregroundColor(.gray)
                                Text(subtitle)
                                    .foregroundColor(.gray)
                            }
                            .font(.body)
                        }

                        if !result.genres.isEmpty {
                            HStack {
                                Image(systemName: "guitars.fill")
                                    .foregroundColor(.gray)
                                Text(result.genres.joined(separator: ", "))
                                    .foregroundColor(.gray)
                            }
                            .font(.body)
                        }

                        // Timestamp
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("Recognized \(formatTimestamp(result.timestamp))")
                                .foregroundColor(.gray)
                        }
                        .font(.caption)
                    }
                    .padding(.top, 10)

                    // Apple Music button
                    if let appleMusicURL = result.appleMusicURL {
                        Button(action: {
                            UIApplication.shared.open(appleMusicURL)
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                Text("Listen on Apple Music")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .purple.opacity(0.5), radius: 10)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    }

                    // Web link button
                    if let webURL = result.webURL {
                        Button(action: {
                            UIApplication.shared.open(webURL)
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                Text("View on Web")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, 30)
                    }

                    // Recognize another button
                    Button(action: {
                        dismiss()
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Recognize Another Song")
                        }
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)

                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.purple)
        .onAppear {
            loadArtwork()
        }
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 250, height: 250)
        .cornerRadius(20)
    }

    private func loadArtwork() {
        guard let artworkURL = result.artworkURL else {
            isLoadingArtwork = false
            return
        }

        isLoadingArtwork = true

        URLSession.shared.dataTask(with: artworkURL) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.artworkImage = image
                }
                self.isLoadingArtwork = false
            }
        }.resume()
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// View displaying recognized song information (inline card)
struct SongResultView: View {
    let result: SongRecognitionResult
    let onDismiss: () -> Void
    
    @State private var isExpanded = false
    @State private var artworkImage: UIImage?
    @State private var isLoadingArtwork = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Album artwork
            ZStack {
                if let artworkImage = artworkImage {
                    Image(uiImage: artworkImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholderImage
                }
                
                if isLoadingArtwork {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 180, height: 180)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .frame(width: 180, height: 180)
            .cornerRadius(12)
            .shadow(color: .purple.opacity(0.5), radius: 15)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            
            // Song title
            Text(result.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Artist name
            Text(result.artist)
                .font(.title3)
                .foregroundColor(.purple.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // Additional info
            VStack(spacing: 8) {
                if let subtitle = result.subtitle {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.gray)
                        Text(subtitle)
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                
                if !result.genres.isEmpty {
                    HStack {
                        Image(systemName: "guitars.fill")
                            .foregroundColor(.gray)
                        Text(result.genres.joined(separator: ", "))
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.top, 5)
            
            // Apple Music button
            if let appleMusicURL = result.appleMusicURL {
                Button(action: {
                    UIApplication.shared.open(appleMusicURL)
                }) {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Listen on Apple Music")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .purple.opacity(0.4), radius: 8)
                }
                .padding(.top, 10)
            }
            
            // Dismiss/Recognize another button
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Recognize Another")
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.top, 5)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            loadArtwork()
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "music.note")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 180, height: 180)
        .cornerRadius(12)
    }
    
    private func loadArtwork() {
        guard let artworkURL = result.artworkURL else {
            isLoadingArtwork = false
            return
        }
        
        isLoadingArtwork = true
        
        URLSession.shared.dataTask(with: artworkURL) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.artworkImage = image
                }
                self.isLoadingArtwork = false
            }
        }.resume()
    }
}

/// Compact song result card for smaller displays
struct SongResultCard: View {
    let result: SongRecognitionResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Thumbnail
                ZStack {
                    if let artworkURL = result.artworkURL,
                       let url = URL(string: artworkURL.absoluteString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                compactPlaceholder
                            case .empty:
                                compactPlaceholder
                                    .overlay(ProgressView())
                            @unknown default:
                                compactPlaceholder
                            }
                        }
                    } else {
                        compactPlaceholder
                    }
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(result.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var compactPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "music.note")
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 60, height: 60)
        .cornerRadius(8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        SongResultView(
            result: SongRecognitionResult(
                title: "Blinding Lights",
                artist: "The Weeknd",
                subtitle: "After Hours",
                genres: ["Pop", "Synth-pop"],
                appleMusicURL: URL(string: "https://music.apple.com")
            ),
            onDismiss: { }
        )
    }
}

