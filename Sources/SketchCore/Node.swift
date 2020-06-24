import SpriteKit

open class Node: SKNode {
    
    public let size: CGSize
    public var colorFlow = ColorFlow(gradients: [[NSColor]]())
    
    required public init?(coder decoder: NSCoder) { fatalError("Not available") }
    
    public init(size: CGSize) {
        self.size = size
        super.init()
    }
    
}
