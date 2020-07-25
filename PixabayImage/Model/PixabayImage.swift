//
//  PixabayImage.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import Foundation
import UIKit

struct PixabayImageSearchResult: Codable {
    let total, totalHits: Int
    let hits: [PixabayImage]
}

// MARK: - PixabayImage
struct PixabayImage: Codable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let previewURL: String
    let previewWidth, previewHeight: Int
    let webformatURL: String
    let webformatWidth, webformatHeight: Int
    let largeImageURL: String
    let imageWidth, imageHeight, imageSize, views: Int
    let downloads, favorites, likes, comments: Int
    let userId: Int
    let user: String
    let userImageURL: String




//    enum CodingKeys: String, CodingKey {
//        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, favorites, likes, comments
//        case userID = "user_id"
//        case user, userImageURL
//    }

    var displayModel: PhotoDisplayModel {
        PhotoDisplayModel(tags: tags, imageURL: webformatURL, user: user)
    }
}

class PhotoDisplayModel {
    var image = UIImage(named: "Placeholder")
    var state = PhotoRecordState.new
    var tags: String
    var imageURL: String
    var user: String

    init(tags: String, imageURL: String, user: String) {
        self.tags = tags
        self.imageURL = imageURL
        self.user = user
    }
}


