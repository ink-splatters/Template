//
//  TemplateApp.swift
//  Template
//
//  Created by Reza Ali on 8/18/22.
//  Copyright © 2022 Reza Ali. All rights reserved.
//

import SwiftUI

@main
struct TemplateApp: App {
    fileprivate enum DefaultKey {
        static let editorPathBookmark = "EditorPathBookmark"
        static let editorPath = "EditorPath"
    }
    
    @StateObject var renderer = Renderer()
    
    @State var presets: [String] = []
    
    var body: some Scene {
        WindowGroup {
            ContentView(renderer: renderer)
                .onAppear {
                    updatePresets()
                }
        }
#if os(macOS)
            .commands {
                CommandMenu("Presets") {
                    Button("Save Preset") {
                        savePreset()
                    }.keyboardShortcut("p", modifiers: [.command])
                    
                    Button("Save Preset As") {
                        savePresetAs()
                    }.keyboardShortcut("p", modifiers: [.command, .shift])
                    
                    Divider()
                    
                    Button("Open Preset") {
                        openPreset()
                    }.keyboardShortcut("o", modifiers: [.command])
                    
                    Divider()
                    
                    Menu("Load Preset") {
                        ForEach(presets, id: \.self) { preset in
                            Button(preset) {
                                renderer.loadPreset(preset)
                            }
                        }
                    }
                }
                    
                CommandMenu("Assets") {
                    Button("Save Assets") {
                        saveResourcesAssets()
                    }
                    .keyboardShortcut("s", modifiers: [.command])
                    
                    Divider()
                    
                    Button("Set Assets Path") {
                        setResourcesAssetsPath()
                    }
                    .keyboardShortcut("c", modifiers: [.option, .command])
                }
                
                CommandMenu("Editor") {
                    Button("Open Editor") {
                        openEditor()
                    }
                    .keyboardShortcut("c", modifiers: [.command])
                    
                    Divider()
                    
                    Button("Set Editor") {
                        setEditor {
                            openEditor()
                        }
                    }
                    .keyboardShortcut("c", modifiers: [.shift, .command])
                }

                CommandMenu("Inspector") {
                    Button("Toggle Inspector") {
                        renderer.toggleInspector()
                    }
                }
            }
#endif
    }
    
#if os(macOS)

    // MARK: - Editor
    
    func setEditor(_ action: (() -> ())? = nil) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.begin(completionHandler: { (result: NSApplication.ModalResponse) in
            if result == .OK, let url = openPanel.url {
                do {
                    let data = try url.bookmarkData()
                    let bookmark = data.base64EncodedString()
                    UserDefaults.standard.set(url.path, forKey: DefaultKey.editorPath)
                    UserDefaults.standard.set(bookmark, forKey: DefaultKey.editorPathBookmark)
                }
                catch {
                    print(error.localizedDescription)
                }
                action?()
            }
            openPanel.close()
        })
    }

    func openEditor() {
        if !_openEditor() {
            let alert = NSAlert()
            alert.messageText = "No Text Editor Application Set"
            alert.informativeText = "Looks like you haven't set a text editor, would you like to set one now?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let result = alert.runModal()
            if result == .alertFirstButtonReturn {
                setEditor {
                    _ = _openEditor()
                }
            }
        }
    }
    
    func _openEditor() -> Bool {
        if let bookmarkDataString = UserDefaults.standard.string(forKey: DefaultKey.editorPathBookmark),
           let bookmarkData = Data(base64Encoded: bookmarkDataString)
        {
            var isStale: Bool = false
            do {
                let editorURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                NSWorkspace.shared.open([getDocumentsPipelinesDirectoryURL()], withApplicationAt: editorURL, configuration: .init()) { _, _ in
                    print("opened editor")
                }
                return true
            }
            catch {
                print(error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    // MARK: - Assets
    
    func setResourcesAssetsPath() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.begin(completionHandler: { (result: NSApplication.ModalResponse) in
            if result == .OK {
                if let url = openPanel.url {
                    do {
                        let data = try url.bookmarkData()
                        UserDefaults.standard.set(url.path, forKey: "ResourcesAssetsPath")
                        UserDefaults.standard.set(data.base64EncodedString(), forKey: "ResourcesAssetsPathBookmark")
                    }
                    catch {
                        print(error)
                    }
                }
            }
            openPanel.close()
        })
    }
    
    func saveResourcesAssets() {
        renderer.save()
        if let bookmarkDataString = UserDefaults.standard.string(forKey: "ResourcesAssetsPathBookmark"), let bookmarkData = Data(base64Encoded: bookmarkDataString) {
            var isStale: Bool = false
            do {
                let appResourcesAssetsURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                copyDirectory(atPath: getDocumentsAssetsDirectoryURL().path, toPath: appResourcesAssetsURL.path, force: true)
            }
            catch {
                print(error)
            }
        }
    }
    
    // MARK: - Presets
    
    func savePreset() {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK") // 1st button
        msg.addButton(withTitle: "Cancel") // 2nd button
        msg.messageText = "Save Preset As"
        msg.informativeText = ""
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        input.stringValue = ""
        input.placeholderString = "Preset Name"
        
        msg.accessoryView = input
        msg.window.initialFirstResponder = input
        let response: NSApplication.ModalResponse = msg.runModal()
        
        let presetName = input.stringValue
        if !presetName.isEmpty, response == NSApplication.ModalResponse.alertFirstButtonReturn {
            renderer.savePreset(presetName)
            updatePresets()
        }
    }
    
    func savePresetAs() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = ""
        savePanel.begin(completionHandler: { (result: NSApplication.ModalResponse) in
            if result == .OK, let url = savePanel.url {
                if fileExists(url) {
                    removeFile(url)
                    _ = createDirectory(url)
                }
                renderer.save(url)
            }
            savePanel.close()
        })
    }
    
    func openPreset() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.begin(completionHandler: { (result: NSApplication.ModalResponse) in
            if result == .OK, let url = openPanel.url {
                renderer.load(url)
            }
            openPanel.close()
        })
    }
#endif
    
    func updatePresets() {
        presets = getPresets(getDocumentsAssetsDirectoryURL())
    }
}
