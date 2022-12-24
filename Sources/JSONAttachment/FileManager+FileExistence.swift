//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

extension FileManager: FileExistenceChecker {
    internal func fileExistence(at url: URL) -> FileExistence {

        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory: &isDirectory)

        switch (exists, isDirectory.boolValue) {
        case (false, _    ): return .none
        case (true,  false): return .file
        case (true,  true ): return .directory
        }
    }
}
