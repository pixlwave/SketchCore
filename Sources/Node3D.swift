import SpriteKit
import SceneKit

open class Node3D: SK3DNode {
    
    public var colorFlow = ColorFlow(gradients: [[NSColor]]())
    
    required public init?(coder decoder: NSCoder) { fatalError("Not available") }
    
    public override init(viewportSize: CGSize) {
        let scene = SCNScene()        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Double(viewportSize.height / 2)
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 10)
        scene.rootNode.addChildNode(cameraNode)
        
        super.init(viewportSize: viewportSize)
        
        position = CGPoint(x: viewportSize.width / 2, y: viewportSize.height / 2)
        autoenablesDefaultLighting = false
        pointOfView = cameraNode
        scnScene = scene
    }
    
}
