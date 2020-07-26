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

class CachImage: CacheCostCalculable {
    var image: UIImage

    var cacheCost: Int {
        let pixel = Int(image.size.width * image.size.height * image.scale * image.scale)
        guard let cgImage = image.cgImage else {
               return pixel * 4
           }
           return pixel * cgImage.bitsPerPixel / 8
       }

    init(_ image: UIImage) {
        self.image = image
    }
}


