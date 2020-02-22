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
        let icon = Icon(image: NSWorkspace.shared.icon(forFile: url.path))
        self.init(
            bundleIdentifier: bundleIdentifier,
            name: name,
            icon: icon)
    }
}

class ViewController: NSViewController {

    @IBOutlet weak var directoryURLLabel: NSTextField!
    @IBOutlet weak var addAppButton: NSButton!
    @IBOutlet weak var removeAllButton: NSButton!
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
        let buttonsAreEnabled: Bool

        if let url = url {
            directoryURLLabel.stringValue = String(describing: url.path)
            buttonsAreEnabled = true
        } else {
            directoryURLLabel.stringValue = ""
            buttonsAreEnabled = false
        }

        addAppButton.isEnabled = buttonsAreEnabled
        removeAllButton.isEnabled = buttonsAreEnabled
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = ""
        log("Launch")

        if let directoryURL = directoryURL {
            let applications: [Application] = (try? EntityReader(directoryURL: directoryURL).all()) ?? []
            log("Restored repo URL: \(directoryURL)\n"
                + applications.map { "- \($0)" }.joined(separator: "\n"))
            displayDirectoryURL(directoryURL)
        } else {
            displayDirectoryURL(nil)
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

        log("Adding applications:")

        for application in applications {
            do {
                try EntityWriter(directoryURL: directoryURL).write(entity: application)
                log("- \(application)")
            } catch {
                log("- Error writing \(application): \(error)")
            }
        }
    }

    @IBAction func removeAll(_ sender: Any) {
    }
}
