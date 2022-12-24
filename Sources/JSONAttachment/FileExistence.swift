//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

protocol FileExistenceChecker {
    func fileExistence(at url: URL) -> FileExistence
}

enum FileExistence: Equatable {
    case none
    case file
    case directory
}
