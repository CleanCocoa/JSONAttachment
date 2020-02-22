//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

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

    public func all() throws -> [Entity] {
        return try reader.all()
    }

    public func allIdentifiers() throws -> [Identifier] {
        return try reader.allIdentifiers()
    }

    public func entity(identifier: Identifier) throws -> Entity? {
        return try reader.entity(identifier: identifier)
    }

    public func add(entity: Entity) throws {
        try writer.write(entity: entity)
    }

    public func remove(identifier: Identifier) throws {
        try remover.removeEntity(identifier: identifier)
    }
}
