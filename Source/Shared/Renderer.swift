//
//  Renderer.swift
//  Template
//
//  Created by Reza Ali on 8/22/19.
//  Copyright © 2022 Reza Ali. All rights reserved.
//

import Metal
import MetalKit

import Forge
import Satin
import Youi

class BlobMaterial: LiveMaterial {}

class Renderer: Forge.Renderer, MaterialDelegate {
    // MARK: - Paths

    var assetsURL: URL {
        getDocumentsAssetsDirectoryURL()
    }
    
    var mediaURL: URL {
        getDocumentsMediaDirectoryURL()
    }
    
    var modelsURL: URL {
        getDocumentsMediaDirectoryURL()
    }
    
    var parametersURL: URL {
        getDocumentsParametersDirectoryURL()
    }
    
    var pipelinesURL: URL {
        getDocumentsPipelinesDirectoryURL()
    }
    
    var presetsURL: URL {
        getDocumentsPresetsDirectoryURL()
    }
    
    var settingsFolderURL: URL {
        getDocumentsSettingsDirectoryURL()
    }
    
    var texturesURL: URL {
        getDocumentsTexturesDirectoryURL()
    }
    
    var dataURL: URL {
        getDocumentsDataDirectoryURL()
    }
    
    var paramKeys: [String] {
        return [
            "Controls",
            "Blob Material",
        ]
    }
    
    var params: [String: ParameterGroup?] {
        return [
            "Controls": appParams,
            "Blob Material": blobMaterial.parameters,
        ]
    }
    
    lazy var blobMaterial: BlobMaterial = {
        let material = BlobMaterial(pipelinesURL: pipelinesURL)
        material.delegate = self
        return material
    }()
    
    var inspectorWindow: InspectorWindow?
    var _updateInspector: Bool = true
    
    lazy var bgColorParam: Float4Parameter = {
        Float4Parameter("Background", [1, 1, 1, 1], .colorpicker) { [unowned self] value in
            renderer.setClearColor(value)
        }
    }()
    
    lazy var blobVisibleParam: BoolParameter = {
        let param = BoolParameter("Show Blob", true, .toggle) { [unowned self] value in
            self.blobMesh.visible = value
        }
        return param
    }()
    
    lazy var appParams: ParameterGroup = {
        let params = ParameterGroup("Controls")
        params.append(bgColorParam)
        params.append(blobVisibleParam)
        return params
    }()
    
    var blobGeo = IcoSphereGeometry(radius: 2.0, res: 5)
    lazy var blobMesh: Mesh = {
        let mesh = Mesh(geometry: blobGeo, material: blobMaterial)
        mesh.label = "Blob"
        return mesh
    }()
    
    lazy var scene: Object = {
        let scene = Object()
        scene.add(blobMesh)
        return scene
    }()
    
    lazy var context: Context = {
        Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    }()
    
    lazy var camera: PerspectiveCamera = {
        let camera = PerspectiveCamera()
        camera.position = simd_make_float3(0.0, 0.0, 10.0)
        camera.near = 0.01
        camera.far = 100.0
        return camera
    }()
    
    lazy var cameraController: PerspectiveCameraController = {
        PerspectiveCameraController(camera: camera, view: mtkView)
    }()
    
    lazy var renderer: Satin.Renderer = {
        let renderer = Satin.Renderer(context: context, scene: scene, camera: camera)
        renderer.setClearColor(bgColorParam.value)
        return renderer
    }()
    
    lazy var startTime: CFAbsoluteTime = {
        CFAbsoluteTimeGetCurrent()
    }()
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.sampleCount = 1
        metalKitView.depthStencilPixelFormat = .depth32Float
        metalKitView.preferredFramesPerSecond = 120
    }
        
    deinit {
        print("Saving")
        save()
    }

    override func setup() {
        load()
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
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
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
