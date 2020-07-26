//
//  ImageDownloader.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import Foundation
import UIKit


enum PhotoRecordState {
    case new, downloaded, failed
}

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {

    let photoRecord: PhotoDisplayModel


    init(_ photoRecord: PhotoDisplayModel) {
        self.photoRecord = photoRecord
    }


    override func main() {

        if isCancelled {
            return
        }

        guard let url = URL(string: photoRecord.imageURL), let imageData = try? Data(contentsOf: url) else {
            Swift.debugPrint("image url is nil or imagedata is nil")
            return
        }


        if isCancelled {
            return
        }


        if !imageData.isEmpty, let image = UIImage(data:imageData), let resizedImage = image.resizeImage(to: CGSize(width: Constants.ImageWidth, height: Constants.ImageHeight)) {
            photoRecord.image = resizedImage
            memoryCache?.store(value: CachImage(resizedImage), forKey: photoRecord.imageURL)
            photoRecord.state = .downloaded
        } else {
            Swift.debugPrint("image download Failed")
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "Failed")
        }
    }
}
