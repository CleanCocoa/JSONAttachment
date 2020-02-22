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

extension Result {
    var value: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
}

class ViewController: NSViewController {
    typealias EntityRepository = JSONAttachment.EntityRepository<Application>

    @IBOutlet weak var directoryURLLabel: NSTextField!
    @IBOutlet weak var addAppButton: NSButton!
    @IBOutlet weak var removeAllButton: NSButton!
    @IBOutlet var textView: NSTextView!
    @IBOutlet var tableView: NSTableView!

    fileprivate let urlAccess = URLAccess(defaultsKey: "directoryURL")
    fileprivate var directoryURL: URL? {
        get { return urlAccess.url }
        set {
            urlAccess.url = newValue
            log(urlAccess.url.map { "Changed repo URL: \($0)" }
                ?? "Removed repo URL")
            displayDirectoryURL(urlAccess.url)
            tableView.reloadData()
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
            let repository = EntityRepository(directoryURL: directoryURL)
            let applications = repository.all().value ?? []
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

        let repository = EntityRepository(directoryURL: directoryURL)
        let applications = panel.urls.compactMap(Application.init(url:))

        log("Adding applications:")

        for application in applications {
            do {
                try repository.add(entity: application)
                log("- \(application)")
            } catch {
                log("- Error writing \(application): \(error)")
            }
        }

        tableView.reloadData()
    }

    @IBAction func removeAll(_ sender: Any) {
        guard let directoryURL = directoryURL else { return }
        let repository = EntityRepository(directoryURL: directoryURL)
        guard case .success(let identifiers) = repository.allIdentifiers() else { return }

        log("Removing applications:")

        for identifier in identifiers {
            do {
                try repository.remove(identifier: identifier)
                log("- \(identifier)")
            } catch {
                log("- Error removing \(identifier): \(error)")
            }
        }

        tableView.reloadData()
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let directoryURL = directoryURL else { return nil }
        let repository = EntityRepository(directoryURL: directoryURL)
        guard case .success(let entities) = repository.all() else { return nil }
        return entities[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let entity = self.tableView(tableView, objectValueFor: tableColumn, row: row) as? Application else { return nil }

        let cell = tableView.makeView(withIdentifier: ApplicationCellView.identifier, owner: self) as? ApplicationCellView
        cell?.configure(application: entity)
        return cell
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let directoryURL = directoryURL else { return 0 }
        let repository = EntityRepository(directoryURL: directoryURL)
        return repository.count.value ?? 0
    }
}
