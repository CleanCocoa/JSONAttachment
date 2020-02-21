//  Copyright © 2020 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        clearRepositoryURLWhenNotExists()
    }

    private func clearRepositoryURLWhenNotExists() {
        guard let url = UserDefaults.standard.url(forKey: "directoryURL") else { return }

        if !FileManager.default.fileExists(atPath: url.path) {
            UserDefaults.standard.removeObject(forKey: "directoryURL")
        }
    }
}
