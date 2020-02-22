//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public final class EntityWriter<E: Entity> {
    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    lazy var encoder = JSONEncoder()

    public func write(entity: E) throws {
        let data = try encoder.encode(entity)
        let url = entity.identifier.url(baseURL: directoryURL)
        try data.write(to: url, options: .atomicWrite)
    }
}
