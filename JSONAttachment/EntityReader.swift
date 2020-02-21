//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum EntityReadingError: Error {
    case fileDoesNotExist(URL)
    case fileIsAirectory(URL)
    case readingFailed(reason: Error)
    case decodingFailed(reason: Error)
}

public final class EntityReader<E: Entity> {
    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    // Testing seams:
    lazy var decoder = JSONDecoder()
    lazy var fileExistenceChecker: FileExistenceChecker = FileManager.default
    lazy var jsonLister: JSONLister = FileManager.default

    /// - Throws: `EntityReadingError`
    public func entity(identifier: Identifier<E>) throws -> E? {
        let url = identifier.url(baseURL: directory)
        return try entity(fromURL: url)
    }

    /// - Throws: `EntityReadingError` to wrap file access errors and decoding errors.
    private func entity(fromURL url: URL) throws -> E {
        switch fileExistenceChecker.fileExistence(at: url) {
        case .none:
            throw EntityReadingError.fileDoesNotExist(url)
        case .directory:
            throw EntityReadingError.fileIsAirectory(url)
        case .file:
            let data: Data

            do {
                data = try Data(contentsOf: url)
            } catch {
                throw EntityReadingError.readingFailed(reason: error)
            }

            do {
                return try decoder.decode(E.self, from: data)
            } catch {
                throw EntityReadingError.decodingFailed(reason: error)
            }
        }
    }

    /// - Throws: `EntityReadingError`
    /// - Returns: A list of entities that were found in the receiver's `baseURL`.
    public func all() throws -> [E] {
        return try jsonLister
            .jsonFileURLsInDirectory(url: directory)
            .map(entity(fromURL:))
    }
}
