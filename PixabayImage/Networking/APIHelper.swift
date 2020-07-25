//
//  APIHelper.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import Foundation
import UIKit

class APIHelper {

    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var images: [PixabayImage] = []


    typealias QueryResult = ([PixabayImage]?, String) -> Void

    func searchImages(key: String, completion: @escaping QueryResult) {

        dataTask?.cancel()

        guard let url = prepareUrl(query: key) else{
            Swift.debugPrint("url is nil")
            return
        }

        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }

            if let error = error {
                self?.errorMessage += "DataTask error: " +
                    error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                do {
                    let result = try appDecoder.decode(PixabayImageSearchResult.self, from: data)
                    self?.images = result.hits


                } catch let parseError as NSError {
                    self?.errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"

                }
                DispatchQueue.main.async {
                    completion(self?.images, self?.errorMessage ?? "")
                }
            }
        }

        dataTask?.resume()
    }

    func prepareUrl(query: String) -> URL? {
        let queryItems = [URLQueryItem(name: Constants.QueryKey, value:  Constants.APIkey),
                          URLQueryItem(name: Constants.QueryQ, value: query),
         URLQueryItem(name: Constants.QueryPerPage, value: Constants.PageCount)]

        var urlComps = URLComponents(string: Constants.SearchUrl)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
    
}


