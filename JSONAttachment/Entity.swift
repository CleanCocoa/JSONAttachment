//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol RestorableAttachment {
    init?(contentsOf url: URL)
    func write(to url: URL) throws
}

public protocol Entity: Codable {
    associatedtype Attachment: RestorableAttachment
    
    var identifier: Identifier<Self> { get }
    var attachment: Attachment? { get }

    func restoringAttachment(_ attachment: Attachment) -> Self
}
