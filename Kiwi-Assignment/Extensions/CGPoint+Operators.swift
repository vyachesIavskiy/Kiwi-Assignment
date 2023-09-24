import CoreGraphics

extension CGPoint {
    static prefix func - (_ point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }
}
