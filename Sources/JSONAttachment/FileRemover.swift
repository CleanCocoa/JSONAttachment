//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

protocol FileRemover {
    func removeItem(at url: URL) throws
}
