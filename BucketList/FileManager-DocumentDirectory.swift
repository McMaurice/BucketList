//
//  FileManager-DocumentDirectory.swift
//  BucketList
//
//  Created by Macmaurice Osuji on 5/26/23.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
