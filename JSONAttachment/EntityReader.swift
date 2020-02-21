//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public final class EntityReader<E: Entity> {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    lazy var decoder = JSONDecoder()

    public func entity(identifier: Identifier<E>) throws -> E? {
        let url = baseURL.appendingPathComponent(identifier.rawValue)
        let data = try Data(contentsOf: url)
        return try decoder.decode(E.self, from: data)
    }
}
