//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import JSONAttachment

struct Application {
    let bundleIdentifier: String
    let name: String
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
            name: try values.decode(String.self, forKey: .name))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleID)
        try container.encode(name, forKey: .name)
    }
}

extension Application: Entity {
    var identifier: Identifier<Application> {
        return Identifier(bundleIdentifier)
    }
}
