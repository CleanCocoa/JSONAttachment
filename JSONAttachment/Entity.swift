//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Identifier<E> where E: Entity {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

public protocol Entity {
    var identifier: Identifier<Self> { get }
}
