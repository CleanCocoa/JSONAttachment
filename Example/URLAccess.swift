//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

enum URLBookmarkResult {
    case stale(URL)
    case resolved(URL)
    case error(Error)
}

fileprivate func resolve(bookmark: Data) -> URLBookmarkResult {
    do {
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        guard !isStale else { return .stale(url) }
        return .resolved(url)
    } catch {
        return .error(error)
    }
}

final class URLAccess {
    let defaultsKey: String

    init(defaultsKey: String) {
        self.defaultsKey = defaultsKey
    }

    private var _cachedAccessibleURL: URL?
    var url: URL? {
        get {
            if _cachedAccessibleURL == nil {
                guard let url = resolvedURL(),
                    true == url.startAccessingSecurityScopedResource()
                    else { return nil }
                _cachedAccessibleURL = url
            }
            return _cachedAccessibleURL
        }

        set {
            if let currentURL = _cachedAccessibleURL {
                currentURL.stopAccessingSecurityScopedResource()
            }
            
            defer { _cachedAccessibleURL = nil }
            
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: defaultsKey)
                return
            }

            do {
                let bookmark = try newValue.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: defaultsKey)
            } catch {
                assertionFailure("Could not create security-scoped URL bookmark for \(newValue) :(\n\(error)")
            }
        }
    }

    private func resolvedURL() -> URL? {
        guard let bookmark = UserDefaults.standard.data(forKey: defaultsKey) else { return nil }
        switch resolve(bookmark: bookmark) {
        case .resolved(let url):
            return url
        case .stale(let url):
            print("URL is stale: \(url)")
            return nil
        case .error(let error):
            print("Error accessing URL bookmark: \(error)")
            return nil
        }
    }
}

