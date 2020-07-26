//
//  ViewModel.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import Foundation

class ViewModel {

    var photos: [PhotoDisplayModel] = []
    let pendingOperations = PendingOperations()
    let apiHelper = APIHelper()

    func searchImages(query: String, commplete: @escaping (String) -> Void)  {
        apiHelper.searchImages(key: query) { (images, error) in
            Swift.debugPrint("searchImages error=\(error)")
            if let images = images {
                self.photos = images.map { $0.displayModel }

                commplete(error)
            } else {
                commplete(error)
            }
        }
    }

    func clear() {
        photos = []
    }
}


