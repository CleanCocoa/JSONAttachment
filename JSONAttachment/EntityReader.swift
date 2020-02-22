//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum EntityReadingError: Error {
    case fileDoesNotExist(URL)
    case fileIsAirectory(URL)
    case readingFailed(reason: Error)
    case decodingFailed(reason: Error)
}

public final class EntityReader<E: Entity> {
    public typealias Identifier = JSONAttachment.Identifier<E>
    public typealias Attachment = E.Attachment

    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    // Testing seams:
    lazy var decoder = JSONDecoder()
    lazy var fileExistenceChecker: FileExistenceChecker = FileManager.default
    lazy var jsonLister: JSONLister = FileManager.default

    /// - Throws: `EntityReadingError`
    public func entity(identifier: Identifier) throws -> E? {
        let url = identifier.jsonURL(baseURL: directoryURL)
        let restoredEntity = try entity(fromURL: url)
        return restoringAttachment(entity: restoredEntity)
    }

    private func restoringAttachment(entity: E) -> E {
        let attachmentURL = entity.identifier.attachmentURL(baseURL: directoryURL)
        return Attachment(contentsOf: attachmentURL).map(entity.restoringAttachment(_:))
            ?? entity
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

    /// - Throws: `EntityReadingError` or directory listing error.
    /// - Returns: A list of entities that were found in the receiver's `baseURL`.
    public func all() throws -> [E] {
        return try jsonLister
            .jsonFileURLsInDirectory(url: directoryURL)
            .map(entity(fromURL:))
            .map(restoringAttachment(entity:))
    }

    /// - Throws: `EntityReadingError` or directory listing error.
    public func allIdentifiers() throws -> [Identifier] {
        return try jsonLister
            .jsonFileURLsInDirectory(url: directoryURL)
            .compactMap(Identifier.init(url:))
    }
}
