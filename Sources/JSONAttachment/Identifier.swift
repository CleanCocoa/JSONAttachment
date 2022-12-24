//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

public struct Identifier<E: Entity>: Equatable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Identifier {
    internal init?(url: URL) {
        let filename = url.deletingPathExtension().lastPathComponent
        guard !filename.isEmpty else { return nil }
        self.init(filename)
    }

    internal func jsonURL(baseURL: URL) -> URL {
        return baseURL
            .appendingPathComponent(self.rawValue)
            .appendingPathExtension("json")
    }

    internal func attachmentURL(baseURL: URL) -> URL {
        return baseURL
            .appendingPathComponent(self.rawValue)
            .appendingPathExtension("attachment")
    }
}
