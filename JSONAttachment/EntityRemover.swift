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

    // MARK: - Result-based accessors

    public func removeEntity(identifier: Identifier<E>) -> Result<Void, EntityRemovingError> {
        // Try to carry out both side effects first
        let jsonResult = removeFileIfExists(url: identifier.jsonURL(baseURL: directoryURL))
        let attachmentResult = removeFileIfExists(url: identifier.attachmentURL(baseURL: directoryURL))
        return jsonResult.flatMap { _ in attachmentResult }
    }

    private func removeFileIfExists(url: URL) -> Result<Void, EntityRemovingError> {
        switch fileExistenceChecker.fileExistence(at: url) {
        case .none:
            return .success(())

        case .directory:
            return .failure(.fileIsDirectory(url))

        case .file:
            do {
                try fileRemover.removeItem(at: url)
                return .success(())
            } catch {
                return .failure(.removalFailed(error))
            }
        }
    }


    // MARK: - Throwing variants

    /// - Throws: `EntityRemovingError`
    public func removeEntity(identifier: Identifier<E>) throws {
        try removeFileIfExists(url: identifier.jsonURL(baseURL: directoryURL)).get()
        try removeFileIfExists(url: identifier.attachmentURL(baseURL: directoryURL)).get()
    }

}
