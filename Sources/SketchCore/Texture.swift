import SpriteKit

public class Texture {
    
    private static var cache = [String: SKTexture]()
    
    public static func circle(size: CGSize, stroke: CGFloat, inverted: Bool) -> SKTexture {
        if let cachedTexture = cache["circle, \(size.debugDescription), \(stroke.description), \(inverted.description)"] {
            return cachedTexture
        }
        var scale = CGAffineTransform(scaleX: Sketch.scaleFactor, y: Sketch.scaleFactor)
        let path = CGPath(ellipseIn: CGRect(origin: .zero, size: size), transform: &scale)
        let image = path.cgImage(strokeWidth: stroke * Sketch.scaleFactor, inverted: inverted)
        let texture = SKTexture(cgImage: image)
        cache["circle, \(size.debugDescription), \(stroke.description), \(inverted.description)"] = texture
        return texture
    }
    
    public static func rect(size: CGSize, stroke: CGFloat, inverted: Bool) -> SKTexture {
        if let cachedTexture = cache["rect, \(size.debugDescription), \(stroke.description), \(inverted.description)"] {
            return cachedTexture
        }
        var scale = CGAffineTransform(scaleX: Sketch.scaleFactor, y: Sketch.scaleFactor)
        let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: &scale)
        let image = path.cgImage(strokeWidth: stroke * Sketch.scaleFactor, inverted: inverted)
        let texture = SKTexture(cgImage: image)
        cache["rect, \(size.debugDescription), \(stroke.description), \(inverted.description)"] = texture
        return texture
    }
    
    public static func roundedRect(size: CGSize, stroke: CGFloat, inverted: Bool) -> SKTexture {
        if let cachedTexture = cache["roundedRect, \(size.debugDescription), \(stroke.description), \(inverted.description)"] {
            return cachedTexture
        }
        var scale = CGAffineTransform(scaleX: Sketch.scaleFactor, y: Sketch.scaleFactor)
        let path = CGPath(roundedRect: CGRect(origin: .zero, size: size), cornerWidth: size.width / 4, cornerHeight: size.width / 4, transform: &scale)
        let image = path.cgImage(strokeWidth: stroke * Sketch.scaleFactor, inverted: inverted)
        let texture = SKTexture(cgImage: image)
        cache["roundedRect, \(size.debugDescription), \(stroke.description), \(inverted.description)"] = texture
        return texture
    }
    
    public static func text(string: String, fontName: String, fontSize: CGFloat, inverted: Bool) -> SKTexture {
        if let cachedTexture = cache["text, \(string), \(fontName), \(fontSize) \(inverted)"] {
            return cachedTexture
        }
        
        let scaledFont = NSFont(name: fontName, size: fontSize * Sketch.scaleFactor)
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = scaledFont
        attributes[.foregroundColor] = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 1)
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        
        let image = attributedString.cgImage()
        let texture = SKTexture(cgImage: image)
        cache["text, \(string), \(fontName), \(fontSize) \(inverted)"] = texture
        return texture
    }
    
}
