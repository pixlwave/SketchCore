import SpriteKit
import SceneKit

public class Cube: SK3DNode {
    
    var node: SCNNode
    public var material: SCNMaterial?
    
    required init?(coder decoder: NSCoder) { fatalError("Not available") }
    
    public init(viewportSize: CGSize, texture: NSImage? = nil) {
        let scene = SCNScene()
        let camera = SCNCamera()
        camera.focalLength = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 4)
        scene.rootNode.addChildNode(cameraNode)
        
        let geometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        material = geometry.firstMaterial
        material?.diffuse.contents = texture
        material?.transparencyMode = .dualLayer     // shows the back face through a transparent texture
        node = SCNNode(geometry: geometry)
        node.position = SCNVector3(10, 10, 0.0)
        node.eulerAngles = SCNVector3(x: 1, y: 1, z: 1)
        scene.rootNode.addChildNode(node)
        
        cameraNode.constraints = [SCNLookAtConstraint(target: node)]
        
        super.init(viewportSize: viewportSize)
        
        autoenablesDefaultLighting = false
        pointOfView = cameraNode
        scnScene = scene
    }
    
    public var eulerAngles: SCNVector3 {
        get { return node.eulerAngles }
        set { node.eulerAngles = newValue }
    }
    
}
