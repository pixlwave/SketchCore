import SpriteKit
import MetalKit

public typealias FrameHandler = (MTLTexture) -> ()

public class SketchView: MTKView {
    
    var texture: MTLTexture
    var scenePipeline: MTLRenderPipelineState
    var sceneRenderPassDescriptor = MTLRenderPassDescriptor()
    var texturedQuadPipeline: MTLRenderPipelineState
    var renderer: SKRenderer
    var scene = SketchScene()
    var backgroundColor = vector_float4(0, 0, 0, 1)
    var frameHandler: FrameHandler?
    
    required init(coder: NSCoder) {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Metal device not found") }
        
        // setup off screen buffer
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Sketch.pixelWidth, height: Sketch.pixelHeight, mipmapped: false)
        textureDescriptor.storageMode = .private
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else { fatalError("Error creating Metal texture") }
        self.texture = texture
        
        sceneRenderPassDescriptor.colorAttachments[0].texture = texture
        sceneRenderPassDescriptor.colorAttachments[0].loadAction = .load
        sceneRenderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // setup the render pipeline
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle(for: SketchView.self)) else {
            fatalError("Failed to make Metal library")
        }
        
        // make pipeline to render to off screen buffer with blending
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .max
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexSimpleQuad")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayColor")
        
        do {
            scenePipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to make render pipeline state")
        }
        
        // make pipeline to render a full screen textured quad
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
        
        do {
            texturedQuadPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to make render pipeline state")
        }
        
        // create scene renderer
        renderer = SKRenderer(device: device)
        
        super.init(coder: coder)

        // store device and set up color properties
        self.device = device
        colorPixelFormat = .bgra8Unorm
        colorspace = nil    // remove colorspace conversions as using unmanaged colors for performance - matches tested syphon clients
        #warning("Colorspaces need more investigation.")
    }
    
    public func presentScene(_ scene: SketchScene) {
        // pause the draw loop
        isPaused = true
        
        self.scene = scene
        scene.sketchView = self
        
        // replace the off-screen buffer texture if the sketch size has changed
        if Sketch.pixelWidth != texture.width || Sketch.pixelHeight != texture.height {
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Sketch.pixelWidth, height: Sketch.pixelHeight, mipmapped: false)
            textureDescriptor.storageMode = .private
            textureDescriptor.usage = [.renderTarget, .shaderRead]
            
            guard let texture = device?.makeTexture(descriptor: textureDescriptor) else { fatalError("Error creating Metal texture") }
            self.texture = texture
            
            sceneRenderPassDescriptor.colorAttachments[0].texture = texture
        }
        
        // set up the scene renderer
        renderer.ignoresSiblingOrder = scene.ignoresSiblingOrder
        renderer.showsNodeCount = scene.showsNodeCount
        renderer.showsDrawCount = scene.showsDrawCount
        renderer.showsPhysics = scene.showsPhysics
        renderer.scene = scene
        
        // fix the view's aspect ratio to the scene's
        let aspectRatio = scene.size.width / scene.size.height
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: aspectRatio, constant: 1))
        
        // run the scene and the draw loop
        scene.isPaused = false
        isPaused = false
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        // update the renderer with the current time
        renderer.update(atTime: CACurrentMediaTime())
        
        updateBackgroundColor()
        drawScene()
    }
    
    func updateBackgroundColor() {
        let color = scene.backgroundColor
        
        if scene.clearTexture {
            backgroundColor = vector_float4(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent), 1.0)
            scene.clearTexture = false
        } else {
            backgroundColor = vector_float4(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent), Float(color.alphaComponent))
        }
    }
    
    func drawScene() {
        if scene.exportPNG { exportPNG(); scene.exportPNG = false }
        
        // make command buffer
        guard let commandQueue = device?.makeCommandQueue() else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // render background color to the texture using a quad
        guard let backgroundCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: sceneRenderPassDescriptor) else { return }
        backgroundCommandEncoder.setRenderPipelineState(scenePipeline)
        backgroundCommandEncoder.setFragmentBytes(&backgroundColor, length: MemoryLayout.size(ofValue: backgroundColor), index: 0)
        backgroundCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        backgroundCommandEncoder.endEncoding()
        
        // render scenekit scene to texture
        renderer.render(withViewport: CGRect(x: 0, y: 0, width: texture.width, height: texture.height), commandBuffer: commandBuffer, renderPassDescriptor: sceneRenderPassDescriptor)
        
        // configure current drawable
        guard let renderPassDescriptor = currentRenderPassDescriptor else { return }
        guard let currentDrawable = currentDrawable else { return }
        renderPassDescriptor.colorAttachments[0].loadAction = .dontCare
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // render the texture to current drawable using a quad
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        commandEncoder.setRenderPipelineState(texturedQuadPipeline)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()
        
        // add time when finished to frame times
        commandBuffer.addCompletedHandler { buffer in
            self.scene.frameTimes.append(CACurrentMediaTime())
            self.scene.frameTimes.removeFirst()
        }
        
        // present and commit
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        
        // wait and call the scene's frame handler if set
        if let frameHandler = scene.frameHandler {
            commandBuffer.waitUntilCompleted()
            frameHandler(texture)
        }
    }
    
    func exportPNG() {
        guard
            let device = device,
            let sRGB = CGColorSpace(name: CGColorSpace.sRGB),
            let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.appendingPathComponent("Sketches \(Date().formatted()).png")
            else {
                return
        }
        
        let context = CIContext(mtlDevice: device)
        guard let ciImage = CIImage(mtlTexture: texture, options: [.colorSpace: sRGB]) else { return }
        let flippedImage = ciImage.transformed(by: ciImage.orientationTransform(for: .downMirrored))
        let data = context.pngRepresentation(of: flippedImage, format: .RGBA8, colorSpace: sRGB)
        
        try? data?.write(to: url)
    }
    
    override public func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(scene)
    }
    
}
