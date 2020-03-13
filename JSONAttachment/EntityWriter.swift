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

    // MARK: - Result-based accessors

    public func write(entity: E) -> Result<(), EntityWritingError> {
        let entityURL = entity.identifier.jsonURL(baseURL: directoryURL)
        let attachmentURL = entity.identifier.attachmentURL(baseURL: directoryURL)

        return data(entity: entity)
            .flatMap { write(data: $0, to: entityURL) }
            .flatMap { write(attachment: entity.attachment, to: attachmentURL) }
    }

    private func data(entity: E) -> Result<Data, EntityWritingError> {
        do {
            let data = try encoder.encode(entity)
            return .success(data)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }

    private func write(data: Data, to entityURL: URL) -> Result<Void, EntityWritingError> {
        do {
            try data.write(to: entityURL, options: .atomicWrite)
            return .success(())
        } catch {
            return .failure(.writingEntityFailed(error))
        }
    }

    private func write(attachment: E.Attachment?, to attachmentURL: URL) -> Result<Void, EntityWritingError> {
        do {
            try attachment?.write(to: attachmentURL)
            return .success(())
        } catch {
            return .failure(.writingAttachmentFailed(error))
        }
    }

    // MARK: - Throwing variants

    public func write(entity: E) throws {
        try write(entity: entity).get()
    }
}
