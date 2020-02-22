//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import JSONAttachment
import AppKit

struct Icon {
    let image: NSImage

    init(image: NSImage) {
        self.image = image
    }
}

struct Application: CustomStringConvertible {
    let bundleIdentifier: String
    let name: String
    var icon: Icon?

    var description: String {
        return "Application(ID: \(bundleIdentifier), name: \(name), hasIcon: \(icon != nil))"
    }
}

// MARK: - Entity conformance

extension Application: Codable {
    enum CodingKeys: String, CodingKey {
        case bundleID, name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            bundleIdentifier: try values.decode(String.self, forKey: .bundleID),
            name: try values.decode(String.self, forKey: .name),
            icon: nil)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleID)
        try container.encode(name, forKey: .name)
    }
}

extension Application: Entity {
    typealias Attachment = Icon

    var attachment: Icon? {
        return icon
    }

    func restoringAttachment(_ attachment: Icon) -> Application {
        var result = self
        result.icon = attachment
        return result
    }

    var identifier: Identifier<Application> {
        return Identifier(bundleIdentifier)
    }
}

extension Icon: RestorableAttachment {
    private static let size = NSSize(width: 64, height: 64)

    init?(contentsOf url: URL) {
        guard let image = NSImage(contentsOf: url) else { return nil }
        self.init(image: image)
    }

    func write(to url: URL) throws {
        guard let representation = image
            .bestRepresentation(for: NSRect(origin: .zero, size: Icon.size),
                                context: nil,
                                hints: [.interpolation : NSImageInterpolation.high])
            // Attempt fallback to generic TIFF representation e.g. for vectors
            ?? image.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:))
            else { return }

        guard let destination = CGImageDestinationCreateWithURL(url as NSURL, kUTTypePNG, 1, nil) else { return }
        guard let cgImage = representation.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)
    }
}
