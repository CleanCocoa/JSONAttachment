//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum EntityWritingError: Error {
    case encodingFailed(Error)
    case writingEntityFailed(Error)
    case writingAttachmentFailed(Error)
}

public final class EntityWriter<E: Entity> {
    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    lazy var encoder = JSONEncoder()

    /// - Throws: `EntityWritingError`
    public func write(entity: E) throws {
        let entityURL = entity.identifier.jsonURL(baseURL: directoryURL)
        let attachmentURL = entity.identifier.attachmentURL(baseURL: directoryURL)

        let entityData: Data
        do {
            entityData = try encoder.encode(entity)
        } catch {
            throw EntityWritingError.encodingFailed(error)
        }

        do {
            try entityData.write(to: entityURL, options: .atomicWrite)
        } catch {
            throw EntityWritingError.writingEntityFailed(error)
        }

        do {
            try entity.attachment?.write(to: attachmentURL)
        } catch {
            throw EntityWritingError.writingAttachmentFailed(error)
        }
    }
}
