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

    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = ""
        log("Launch")

        if let url = UserDefaults.standard.url(forKey: "directoryURL") {
            log("Restored repo URL: \(url)")
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
        UserDefaults.standard.set(url, forKey: "directoryURL")
        log("Changed repo to: \(url)")
    }

    @IBAction func pickApps(_ sender: Any) {
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
