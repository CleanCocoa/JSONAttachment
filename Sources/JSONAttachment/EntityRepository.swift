//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

public final class EntityRepository<Entity: JSONAttachment.Entity> {
    public typealias Identifier = JSONAttachment.Identifier<Entity>

    public let directoryURL: URL

    private let reader: EntityReader<Entity>
    private let writer: EntityWriter<Entity>
    private let remover: EntityRemover<Entity>

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
        self.reader = EntityReader(directoryURL: directoryURL)
        self.writer = EntityWriter(directoryURL: directoryURL)
        self.remover = EntityRemover(directoryURL: directoryURL)
    }

    public func all() -> Result<[Entity], EntityReadingError> {
        return reader.all()
    }

    public func allIdentifiers() -> Result<[Identifier], EntityReadingError> {
        return reader.allIdentifiers()
    }

    public func entity(identifier: Identifier) -> Result<Entity?, EntityReadingError> {
        return reader.entity(identifier: identifier)
    }

    public func add(_ entity: Entity) -> Result<Entity, EntityWritingError> {
        return writer.write(entity: entity)
            .map { _ in entity }
    }

    public func remove(identifier: Identifier) -> Result<Identifier, EntityRemovingError> {
        return remover.removeEntity(identifier: identifier)
            .map { _ in identifier }
    }

    /// Number of recognizable items in `directoryURL`, based on whether it is recognized as an `Identifier`/JSON file.
    public var count: Result<Int, EntityReadingError> {
        return reader.count
    }
}
