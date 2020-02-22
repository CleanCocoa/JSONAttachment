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
    private static let size = NSSize(width: 32, height: 32)

    init?(contentsOf url: URL) {
        guard let image = NSImage(contentsOf: url) else { return nil }
        self.init(image: image)
    }

    func write(to url: URL) throws {
        let iconRepresentations = self.iconRepresentations(size: Icon.size)

        guard !iconRepresentations.isEmpty else { return }
        guard let destination = CGImageDestinationCreateWithURL(url as NSURL, kUTTypeAppleICNS, iconRepresentations.count, nil) else { return }

        for representation in iconRepresentations {
            guard let cgImage = representation.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
            let dpiFactor = representation.dpiFactor
            let hints: [CFString : Any] = [
                kCGImagePropertyDPIWidth : dpiFactor.dpi as NSNumber,
                kCGImagePropertyDPIHeight : dpiFactor.dpi  as NSNumber,
                kCGImagePropertyPixelWidth : representation.pixelsWide as NSNumber,
                kCGImagePropertyPixelHeight : representation.pixelsHigh as NSNumber
            ]
            CGImageDestinationAddImage(destination, cgImage, hints as NSDictionary)
        }

        let success = CGImageDestinationFinalize(destination)
        assert(success)
    }

    private func iconRepresentations(size: NSSize) -> [NSImageRep] {
        let representations = self.image.representations.filter { $0.size == size }

        if !representations.isEmpty {
            return representations
        }

        guard let fallbackRepresentation = self.image
            .bestRepresentation(for: NSRect(origin: .zero, size: Icon.size),
                                context: nil,
                                hints: [.interpolation : NSImageInterpolation.high])
            // Attempt fallback to generic TIFF representation e.g. for vectors
            ?? image.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:))
            else { return [] }
        return [fallbackRepresentation]
    }
}

extension NSImageRep {
    fileprivate enum DPIFactor {
        case at1x, at2x, at3x

        var dpi: Int {
            switch self {
            case .at1x: return (1 * 72)
            case .at2x: return (2 * 72)
            case .at3x: return (3 * 72)
            }
        }
    }

    fileprivate var dpiFactor: DPIFactor {
        let sizeWidth = Int(size.width)
        let sizeHeight = Int(size.height)

        if pixelsWide == sizeWidth * 3 && pixelsHigh == sizeHeight * 3 {
            return .at3x
        }

        if pixelsWide == sizeWidth * 2 && pixelsHigh == sizeHeight * 2 {
            return .at2x
        }

        return .at1x
    }
}
