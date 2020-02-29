# JSONAttachment

![Swift 5](https://img.shields.io/badge/Swift-5-blue.svg?style=flat)
![Version](https://img.shields.io/github/tag/CleanCocoa/JSONAttachment.svg?style=flat)
![License](https://img.shields.io/github/license/CleanCocoa/JSONAttachment.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

I was looking to store some metadata _plus_ images in a convenient way. Swift `Codable` can help with the metadata, but you don't want to store `NSImage` blobs in your JSON.

JSONAttachment takes care of storing and retrieving your stored objects plus their attachments for you.

## Usage

1. Extend your business objects to conform to `JSONAttachment.Entity`,
2. Extend your attachments (e.g. images) to conform to `JSONAttachment.RestorableAttachment`.
3. Optionally use `JSONAttachment.EntityRepository` on a directory to read, write, and maintain your storage for your objects.

See the Example project for an app that copies 32x32 pixel icons from app bundles as "attachment".

    +---------------------+                               
    |    Your Entity      |            +--------------+   
    |                     |    add to  |              |   
    | - name: String      ------------>|  Repository  |   
    | - date: Date        |            |              |   
    | - attachment: Image |            +------|-------+   
    |                     |                   |           
    +---------------------+             +-----+-----+     
                                        |   write   |     
                                        |           |    
                                        v           v     
                                   +--------,    +--------, 
                                   | .json |_\   |  .png |_\
                                   |         |   |         |
                                   | {name:, |   |         |
                                   |  date:} |   |         |
                                   +---------+   +---------+

### Define your `Entity`

Make your objects conform to `Entity` and

- provide an `identifier`, which will also be used for the file names;
- implement the `attachment` property that'll be used to write the attachment to disk, and the `restoringAttachment(_:)` method to attach a restored attachment back to your entity.

The protocol is simple:

```swift
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
```

### Use `RestorableAttachment` e.g. on data

The simplest attachment is `Data`/`NSData`:

```swift
// The Swift API overlaps with the protocol requirements already!
extension Data: RestorableAttachment {}
```

You can write strings or PDF files or images or anything else, too, when you wrap it in such a way.

`NSImage`, for example, comes with `init(contentsOf:)` out of the box, so you would only need to provide the `write(to:)` implementation via the image's `Data`:

```swift
extension NSImage: RestorableAttachment {
    struct ImageNotWritableError: Error {
        let image: NSImage
    }
    
    func write(to url: URL) throws {
        guard let tiffData = self.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:)) else {
            throw ImageNotWritableError(image: self)
        }
        try tiffData.write(to: url)
    }
}
```

**Note:** I would recommend to create your own `Image` or `Icon` wrapper type as the attachment instead of extending AppKit/Foundation types willy-nilly; use something _you_ have full control over when you can so you have full control over the resulting API.

## Installation

### Carthage

Add this to your `Cartfile`:

    github "cleancocoa/JSONAttachment"

Then run 

    $ carthage update

... and include `JSONAttachment.framework` from `Carthage/Build/Mac` in your app. 

## License

Copyright (c) 2020 Christian Tietze. Distributed under the MIT License.
