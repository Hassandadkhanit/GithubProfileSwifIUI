//
//  DownloadedResponse.swift
//  Amplify
//
//  Created by Hassan dad khan on 15/09/2023.
//

import Foundation

struct DownloadResponse: Codable {
    var url: URL?
    var fileURL: URL?
    var memeType: String?
    
    enum CodingKeys: CodingKey {
        case url
        case fileURL
        case memeType
    }
    init(url: URL? = nil, fileURL: URL? = nil, memeType: String? = nil) {
        self.url = url
        self.fileURL = fileURL
        self.memeType = memeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
        self.fileURL = try container.decodeIfPresent(URL.self, forKey: .fileURL)
        self.memeType = try container.decodeIfPresent(String.self, forKey: .memeType)
    }
}
