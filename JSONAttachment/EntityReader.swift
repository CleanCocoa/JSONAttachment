//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum EntityReadingError: Error {
    case directoryListingFailed(reason: Error)
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

    /// Number of recognizable items in `directoryURL`, based on whether it is recognized as an `Identifier`/JSON file.
    public var count: Result<Int, EntityReadingError> {
        return allIdentifiers().map { $0.count }
    }

    // Testing seams:
    lazy var decoder = JSONDecoder()
    lazy var fileExistenceChecker: FileExistenceChecker = FileManager.default
    lazy var jsonLister: JSONLister = FileManager.default

    
    // MARK: - Result-based accessors

    /// - Returns: A list of entities that were found in the receiver's `directoryURL`.
    public func all() -> Result<[E], EntityReadingError> {
        return jsonFileURLs()
            .flatMap(entity(fromURL:))
            .flatMap(restoringAttachment(entity:))
    }

    public func allIdentifiers() -> Result<[Identifier], EntityReadingError> {
        return jsonFileURLs()
            .compactMap(Identifier.init(url:))
    }

    public func entity(identifier: Identifier) -> Result<E?, EntityReadingError> {
        let url = identifier.jsonURL(baseURL: directoryURL)
        return entity(fromURL: url)
            .map(restoringAttachment(entity:))
    }

    private func jsonFileURLs() -> Result<[URL], EntityReadingError> {
        return Result {
            try jsonLister.jsonFileURLsInDirectory(url: directoryURL)
        }.mapError { .directoryListingFailed(reason: $0) }
    }

    private func entity(fromURL url: URL) -> Result<E, EntityReadingError> {
        switch fileExistenceChecker.fileExistence(at: url) {
        case .none:
            return .failure(.fileDoesNotExist(url))
        case .directory:
            return .failure(.fileIsAirectory(url))
        case .file:
            let data: Data

            do {
                data = try Data(contentsOf: url)
            } catch {
                return .failure(.readingFailed(reason: error))
            }

            do {
                let entity = try decoder.decode(E.self, from: data)
                return .success(entity)
            } catch {
                return .failure(.decodingFailed(reason: error))
            }
        }
    }

    private func restoringAttachment(entity: E) -> E {
        let attachmentURL = entity.identifier.attachmentURL(baseURL: directoryURL)
        return Attachment(contentsOf: attachmentURL).map(entity.restoringAttachment(_:))
            ?? entity
    }


    // MARK: - Throwing variants

    /// - Throws: `EntityReadingError`
    /// - Returns: A list of entities that were found in the receiver's `baseURL`.
    public func all() throws -> [E] {
        let result: Result<[E], EntityReadingError> = all()
        switch result {
        case .success(let entities):
            return entities
        case .failure(let error):
            throw error
        }
    }

    /// - Throws: `EntityReadingError` or directory listing error.
    public func allIdentifiers() throws -> [Identifier] {
        let result: Result<[Identifier], EntityReadingError> = allIdentifiers()
        switch result {
        case .success(let identifiers):
            return identifiers
        case .failure(let error):
            throw error
        }
    }

    /// - Throws: `EntityReadingError`
    public func entity(identifier: Identifier) throws -> E? {
        let result: Result<E?, EntityReadingError> = entity(identifier: identifier)
        switch result {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }
}

extension Result where Success: Collection {
    func flatMap<NewSuccess>(_ transform: (Success.Element) -> Result<NewSuccess, Failure>) -> Result<[NewSuccess], Failure> {
        switch self {
        case .failure(let error):
            return .failure(error)

        case .success(let elements):
            var newSuccesses: [NewSuccess] = []
            newSuccesses.reserveCapacity(elements.count)
            
            for element in elements {
                switch transform(element) {
                case .success(let result):
                    newSuccesses.append(result)
                case .failure(let error):
                    return .failure(error)
                }
            }
            
            return .success(newSuccesses)
        }
    }
}

// MARK: `flatMap` on successful `Collection`s

extension Result where Success: Collection {
    func flatMap<NewSuccess>(_ transform: (Success.Element) -> NewSuccess) -> Result<[NewSuccess], Failure> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let elements):
            return .success(elements.map(transform))
        }
    }

    func compactMap<NewSuccess>(_ transform: (Success.Element) -> NewSuccess?) -> Result<[NewSuccess], Failure> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let elements):
            return .success(elements.compactMap(transform))
        }
    }
}
