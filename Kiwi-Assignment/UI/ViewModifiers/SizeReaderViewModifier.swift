import SwiftUI

struct SizeReaderViewModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizeReaderPreferenceKey.self, value: geometry.size)
                }
            }
            .onPreferenceChange(SizeReaderPreferenceKey.self) { size = $0 }
    }
}

private struct SizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    @ViewBuilder func readSize(_ binding: Binding<CGSize>) -> some View {
        modifier(SizeReaderViewModifier(size: binding))
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(SizeReaderViewModifier(size: .constant(.zero)))
}
