import SwiftUI

struct Triangle: Shape {
    enum Corner {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    var corner: Corner
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            switch corner {
            case .topLeft:
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.closeSubpath()
                
            case .topRight:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.closeSubpath()
                
            case .bottomRight:
                path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.closeSubpath()
                
            case .bottomLeft:
                path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minY, y: rect.minY))
                path.closeSubpath()
            }
        }
    }
}

#Preview("Triangles") {
    VStack {
        Triangle(corner: .topLeft)
            .overlay(alignment: .topLeading) {
                Text("Top left")
                    .foregroundStyle(.background)
            }
        
        Triangle(corner: .topRight)
            .overlay(alignment: .topTrailing) {
                Text("Top right")
                    .foregroundStyle(.background)
            }
        
        Triangle(corner: .bottomRight)
            .overlay(alignment: .bottomTrailing) {
                Text("Bottom right")
                    .foregroundStyle(.background)
            }
        
        Triangle(corner: .bottomLeft)
            .overlay(alignment: .bottomLeading) {
                Text("Bottom left")
                    .foregroundStyle(.background)
            }
        
    }
    .padding()
}

