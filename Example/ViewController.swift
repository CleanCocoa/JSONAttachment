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

    fileprivate let urlAccess = URLAccess(defaultsKey: "directoryURL")
    fileprivate var directoryURL: URL? {
        get { return urlAccess.url }
        set {
            urlAccess.url = newValue
            log(urlAccess.url.map { "Changed repo URL: \($0)" }
                ?? "Removed repo URL")
            displayDirectoryURL(urlAccess.url)
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
