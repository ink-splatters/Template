//
//  Renderer+Save+Load.swift
//  Template
//
//  Created by Reza Ali on 8/18/21.
//  Copyright © 2021 Reza Ali. All rights reserved.
//

import Foundation

extension Renderer {
    func save() {
        saveParameters(parametersURL)
    }

    func load() {
        loadParameters(parametersURL)
    }

    func save(_ url: URL) {
        let saveParametersURL = url.appendingPathComponent("Parameters")
        removeFile(saveParametersURL)
        if createDirectory(url), createDirectory(saveParametersURL) {
            saveParameters(saveParametersURL)
        }
    }

    func load(_ url: URL) {
        loadParameters(url.appendingPathComponent("Parameters"))
    }

    func saveParameters(_ url: URL) {
        for (key, param) in params {
            if let p = param {
                p.save(url.appendingPathComponent(key + ".json"))
            }
        }
        saveCamera(url.appendingPathComponent("Camera.json"))
    }

    func loadParameters(_ url: URL) {
        for (key, param) in params {
            if let p = param {
                p.load(url.appendingPathComponent(key + ".json"))
            }
        }
        loadCamera(url.appendingPathComponent("Camera.json"))
    }

    func saveCamera(_ url: URL) {
        cameraController.save(url: url)
    }

    func loadCamera(_ url: URL) {
        cameraController.load(url: url)
    }

    func savePreset(_ name: String) {
        let presetURL = presetsURL.appendingPathComponent(name)
        removeFile(presetURL)
        let presetParametersURL = presetURL.appendingPathComponent("Parameters")
        if createDirectory(presetURL), createDirectory(presetParametersURL) {
            saveParameters(presetParametersURL)
        }
    }

    func loadPreset(_ name: String) {
        loadParameters(presetsURL.appendingPathComponent(name).appendingPathComponent("Parameters"))
    }
}
