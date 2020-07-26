//
//  PixabayImageTests.swift
//  PixabayImageTests
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import XCTest
@testable import PixabayImage

class PixabayImageTests: XCTestCase {
    var cache :MemoryCache<CachImage>?

    override func setUpWithError() throws {
        cache = MemoryCache<CachImage>(countLimit: Constants.ImageCacheCount)
    }

    override func tearDownWithError() throws {
        cache = nil
    }

    func testCache() throws {
        guard let image = UIImage(named: "Placeholder") else {
            return
        }
        for i in 1...110 {
            cache?.store(value: CachImage(image), forKey: String(i))
        }

        XCTAssertTrue(cache?.queue.count == 100)
        XCTAssertFalse(cache?.isCached(forKey: "1") ?? false)
        XCTAssertTrue(cache?.isCached(forKey: "110") ?? false)

    }



}
