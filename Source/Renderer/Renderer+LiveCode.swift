//
//  Renderer+LiveCode.swift
//  Template
//
//  Created by Reza Ali on 1/7/21.
//  Copyright © 2021 Reza Ali. All rights reserved.
//

#if os(macOS)
import AppKit

extension Renderer {
    func openEditor() {
        if let editorURL = UserDefaults.standard.url(forKey: "Editor") {
            openEditor(at: editorURL)
        }
        else {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = true
            openPanel.allowsMultipleSelection = false
            openPanel.canCreateDirectories = false
            openPanel.begin(completionHandler: { [unowned self] (result: NSApplication.ModalResponse) in
                if result == .OK {
                    if let editorUrl = openPanel.url {
                        UserDefaults.standard.set(editorUrl, forKey: "Editor")
                        self.openEditor(at: editorUrl)
                    }
                }
                openPanel.close()
            })
        }
    }

    func openEditor(at editorURL: URL) {
        NSWorkspace.shared.open([self.assetsURL], withApplicationAt: editorURL, configuration: .init(), completionHandler: nil)
    }
}

#endif
