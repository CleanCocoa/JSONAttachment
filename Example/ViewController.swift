//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import JSONAttachment

extension Application {
    fileprivate init?(url: URL) {
        guard let bundle = Bundle(url: url),
            let bundleIdentifier = bundle.bundleIdentifier
            else { return nil }
        let name = bundle.infoDictionary?["CFBundleName"] as? String
            ?? FileManager.default.displayName(atPath: url.path)
        self.init(
            bundleIdentifier: bundleIdentifier,
            name: name)
    }
}

class ViewController: NSViewController {

    @IBOutlet weak var directoryURLLabel: NSTextField!
    @IBOutlet var textView: NSTextView!

    fileprivate var directoryURL: URL? {
        get {
            guard let bookmark = UserDefaults.standard.data(forKey: "directoryURL") else { return nil }
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                guard !isStale else {
                    UserDefaults.standard.removeObject(forKey: "directoryURL")
                    log("Repo URL is stale and was removed: \(url)")
                    return nil
                }
                return url
            } catch {
                UserDefaults.standard.removeObject(forKey: "directoryURL")
                log("Repo URL bookmark couldn't be resolved and was removed")
                return nil
            }
        }
        set {
            if let newValue = newValue {
                do {
                    let bookmark = try newValue.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    UserDefaults.standard.set(bookmark, forKey: "directoryURL")
                    log("Changed repo to: \(newValue)")
                    displayDirectoryURL(newValue)
                } catch {
                    log("Could not create security-scoped URL bookmark for \(newValue) :(")
                    displayDirectoryURL(nil)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "directoryURL")
                log("Removed the repo")
                displayDirectoryURL(nil)
            }
        }
    }

    private func displayDirectoryURL(_ url: URL?) {
        if let url = url {
            directoryURLLabel.stringValue = String(describing: url.path)
        } else {
            directoryURLLabel.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = ""
        log("Launch")

        if let directoryURL = directoryURL {
            log("Restored repo URL: \(directoryURL)")
            displayDirectoryURL(directoryURL)
        }
    }

    func log(_ text: String) {
        let message = "\(Date()) > \(text)\n"
        textView.string.append(message)
        textView.scrollToEndOfDocument(self)
    }

    @IBAction func pickDirectory(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        guard .OK == panel.runModal() else { return }
        guard let url = panel.url else { return }
        self.directoryURL = url
    }

    @IBAction func pickApps(_ sender: Any) {
        guard let directoryURL = self.directoryURL else { return }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["app"]
        panel.allowsMultipleSelection = true

        guard .OK == panel.runModal() else { return }

        let applications = panel.urls.compactMap(Application.init(url:))
        log("Picked: \(applications)")
    }

    @IBAction func removeAll(_ sender: Any) {
    }
}
