//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class ApplicationCellView: NSTableCellView {
    static let identifier = NSUserInterfaceItemIdentifier("ApplicationCell")
    func configure(application: Application) {
        self.textField?.stringValue = application.name
        self.imageView?.image = application.icon?.image
    }
}
