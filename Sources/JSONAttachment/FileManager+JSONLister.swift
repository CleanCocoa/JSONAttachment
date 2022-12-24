//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

extension FileManager: JSONLister {
    internal func jsonFileURLsInDirectory(url: URL) throws -> [URL] {
        return try self
            .contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            .filter { $0.pathExtension.lowercased() == "json" }
    }
}
