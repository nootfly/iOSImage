//
//  MemoryCache.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import Foundation
import UIKit

class Queue<T> {
    private var elements: [T] = []

    func enqueue(_ value: T) {
        elements.append(value)
    }

    func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }

    var head: T? {
        return elements.first
    }

    var count: Int {
        elements.count
    }

    var tail: T? {
        return elements.last
    }
}

class StorageObject<T> {
    let value: T
    let key: String

    init(_ value: T, key: String) {
        self.value = value
        self.key = key

    }
}

public protocol CacheCostCalculable {
    var cacheCost: Int { get }
}

public class MemoryCache<T: CacheCostCalculable> {
    let storage = NSCache<NSString, StorageObject<T>>()

    var keys = Set<String>()
    var queue = Queue<String>()

    private var cleanTimer: Timer? = nil
    private let lock = NSLock()


    public init(totalCostLimit: Int, countLimit: Int) {
        storage.totalCostLimit = totalCostLimit
        storage.countLimit = countLimit
    }

    func removeOldest() {
        if queue.count < storage.countLimit {
            return
        }
        lock.lock()
        defer { lock.unlock() }
        if let key = queue.dequeue() {
            let nsKey = key as NSString
            guard let _ = storage.object(forKey: nsKey) else {
                return
            }
            storage.removeObject(forKey: nsKey)
            keys.remove(key)
        }
    }


    func storeNoThrow(
        value: T,
        forKey key: String)
    {
        lock.lock()
        defer { lock.unlock() }


        let object = StorageObject(value, key: key)
        storage.setObject(object, forKey: key as NSString, cost: value.cacheCost)
        keys.insert(key)
        queue.enqueue(key)
    }


    func value(forKey key: String) -> T? {
        guard let object = storage.object(forKey: key as NSString) else {
            return nil
        }


        return object.value
    }

    func isCached(forKey key: String) -> Bool {
        guard let _ = value(forKey: key) else {
            return false
        }
        return true
    }

    func remove(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeObject(forKey: key as NSString)
        keys.remove(key)
    }

    func removeAll() throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAllObjects()
        keys.removeAll()
    }
}

