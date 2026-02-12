import Foundation
import ShazamKit

/// Model representing song recognition result from ShazamKit
struct SongRecognitionResult: Identifiable, Equatable, Hashable {
    let id = UUID()
    let uniqueID: String
    let title: String
    let artist: String
    let subtitle: String?
    let genres: [String]
    let artworkURL: URL?
    let appleMusicURL: URL?
    let webURL: URL?
    let isrc: String?
    let timestamp: Date
    
    /// Create a result from ShazamKit's SHMatchedMediaItem
    init?(from item: SHMatchedMediaItem) {
        guard let title = item.title,
              let artist = item.artist else {
            return nil
        }
        
        self.uniqueID = item.shazamID ?? UUID().uuidString
        self.title = title
        self.artist = artist
        self.subtitle = item.subtitle
        self.genres = item.genres 
        self.artworkURL = item.artworkURL
        self.appleMusicURL = item.appleMusicURL
        self.webURL = item.webURL
        self.isrc = item.isrc
        self.timestamp = Date()
    }
    
    /// Create a placeholder result for testing
    init(
        title: String,
        artist: String,
        subtitle: String? = nil,
        genres: [String] = [],
        artworkURL: URL? = nil,
        appleMusicURL: URL? = nil,
        webURL: URL? = nil
    ) {
        self.uniqueID = UUID().uuidString
        self.title = title
        self.artist = artist
        self.subtitle = subtitle
        self.genres = genres
        self.artworkURL = artworkURL
        self.appleMusicURL = appleMusicURL
        self.webURL = webURL
        self.isrc = nil
        self.timestamp = Date()
    }
    
    static func == (lhs: SongRecognitionResult, rhs: SongRecognitionResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

