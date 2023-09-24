import SwiftUI

struct ScrollViewOffsetReader: View {
    var axis: Axis.Set
    @Binding var scrollOffset: CGPoint
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: ScrollViewOffsetReaderPreferenceKey.self,
                    value: -geometry.frame(in: .scrollView).origin
                )
        }
        .onPreferenceChange(ScrollViewOffsetReaderPreferenceKey.self) { scrollOffset = $0 }
        .frame(width: 0, height: 0)
    }
    
    init(_ axis: Axis.Set = [.horizontal, .vertical], scrollOffset: Binding<CGPoint>) {
        self.axis = axis
        self._scrollOffset = scrollOffset
    }
}

private struct ScrollViewOffsetReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

#Preview {
    struct Preview: View {
        @State private var scrollOffset = CGPoint.zero
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(spacing: 0) {
                        ScrollViewOffsetReader(.vertical, scrollOffset: $scrollOffset)
                        
                        VStack {
                            ForEach(0..<10) { _ in
                                Rectangle()
                                    .frame(height: 200)
                            }
                        }
                    }
                }
                
                Text("Offset: (\(scrollOffset.x), \(scrollOffset.y))")
                    .padding()
                    .foregroundStyle(.blue)
            }
        }
    }
    
    return Preview()
}
