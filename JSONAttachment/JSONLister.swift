//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

protocol JSONLister {
    func jsonFileURLsInDirectory(url: URL) throws -> [URL]
}
