//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum EntityRemovingError: Error {
    case fileIsDirectory(URL)
    case removalFailed(Error)
}

public final class EntityRemover<E: Entity> {
    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    // Testing seams:
    lazy var fileExistenceChecker: FileExistenceChecker = FileManager.default
    lazy var fileRemover: FileRemover = FileManager.default

    /// - Throws: `EntityRemovingError`
    public func removeEntity(identifier: Identifier<E>) throws {
        try removeFileIfExists(url: identifier.jsonURL(baseURL: directoryURL))
        try removeFileIfExists(url: identifier.attachmentURL(baseURL: directoryURL))
    }

    /// - Throws: `EntityRemovingError`
    private func removeFileIfExists(url: URL) throws {
        switch fileExistenceChecker.fileExistence(at: url) {
        case .none:
            return

        case .directory:
            throw EntityRemovingError.fileIsDirectory(url)

        case .file:
            do {
                try fileRemover.removeItem(at: url)
            } catch {
                throw EntityRemovingError.removalFailed(error)
            }
        }
    }
}
