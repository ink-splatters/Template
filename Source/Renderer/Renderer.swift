//
//  Renderer.swift
//  Template
//
//  Created by Reza Ali on 8/22/19.
//  Copyright © 2022 Reza Ali. All rights reserved.
//

import Combine
import Metal
import MetalKit

import Forge
import Satin
import Youi

class Renderer: Forge.Renderer, MaterialDelegate, ObservableObject {
    class BlobMaterial: SourceMaterial {}
    
    // MARK: - Paths

    var assetsURL: URL { getDocumentsAssetsDirectoryURL() }
    var mediaURL: URL { getDocumentsMediaDirectoryURL() }
    var modelsURL: URL { getDocumentsModelsDirectoryURL() }
    var parametersURL: URL { getDocumentsParametersDirectoryURL() }
    var pipelinesURL: URL { getDocumentsPipelinesDirectoryURL() }
    var presetsURL: URL { getDocumentsPresetsDirectoryURL() }
    var settingsFolderURL: URL { getDocumentsSettingsDirectoryURL() }
    var texturesURL: URL { getDocumentsTexturesDirectoryURL() }
    var dataURL: URL { getDocumentsDataDirectoryURL() }
    
    var paramKeys: [String] { return ["Controls", "Blob Material"] }
    
    var params: [String: ParameterGroup?] {
        return [
            "Controls": appParams,
            "Blob Material": blobMaterial.parameters,
        ]
    }
    
    // MARK: - UI
    
    var inspectorWindow: InspectorWindow?
    var _updateInspector: Bool = true
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var appParams = ParameterGroup("Controls", [bgColorParam])
    var bgColorParam = Float4Parameter("Background", [1, 1, 1, 1], .colorpicker)
    
    // MARK: - 3D Scene
    
    lazy var scene = Object("Scene", [blobMesh])

    lazy var blobMesh = Mesh(geometry: IcoSphereGeometry(radius: 2.0, res: 5), material: blobMaterial)
    lazy var blobMaterial = BlobMaterial(pipelinesURL: pipelinesURL)
    
    var camera = PerspectiveCamera(position: [0.0, 0.0, 10.0], near: 0.01, far: 100.0)

    lazy var context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    lazy var cameraController = PerspectiveCameraController(camera: camera, view: mtkView)
    lazy var renderer = Satin.Renderer(context: context)
    
    lazy var startTime: CFAbsoluteTime = { CFAbsoluteTimeGetCurrent() }()
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.sampleCount = 1
        metalKitView.depthStencilPixelFormat = .depth32Float
        metalKitView.preferredFramesPerSecond = 120
    }
        
    deinit {
        save()
    }

    override func setup() {
        setupObservers()
        blobMaterial.delegate = self
        blobMaterial
        load()
    }

    func setupObservers() {
        bgColorParam.$value.sink { [weak self] value in
            guard let self = self else { return }
            self.renderer.setClearColor(value)
        }.store(in: &cancellables)
    }
    
    func getTime() -> Float {
        return Float(CFAbsoluteTimeGetCurrent() - startTime)
    }

    override func update() {
        blobMaterial.set("Time", getTime())
        cameraController.update()
        updateInspector()
    }
    
    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderer.draw(
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            scene: scene,
            camera: camera
        )
    }
    
    override func resize(_ size: (width: Float, height: Float)) {
        camera.aspect = size.width / size.height
        renderer.resize(size)
    }
    
    func updated(material: Material) {
        print("Material Updated: \(material.label)")
        _updateInspector = true
    }
}
