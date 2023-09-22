import SwiftUI

struct ShadowButtonStyle: ButtonStyle {
    @Environment(\.backgroundStyle) private var backgroundStyle
    
    private var resolvedBackgroundStyle: AnyShapeStyle {
        backgroundStyle ?? AnyShapeStyle(.background)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .background(
                resolvedBackgroundStyle.shadow(.drop(
                    radius: configuration.isPressed ? 2 : 5,
                    y: configuration.isPressed ? 0 : 2
                )),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ShadowButtonStyle {
    static var shadow: ShadowButtonStyle { ShadowButtonStyle() }
}

#Preview("Accent Button") {
    Button(action: { print("Pressed") }) {
        Label("Press Me", systemImage: "star")
            .foregroundStyle(.white)
    }
    .buttonStyle(.shadow)
    .backgroundStyle(Color.accentColor)
    .padding()
}

#Preview("TextField Button") {
    Button(action: { print("Pressed") }) {
        Label("Press Me", systemImage: "star")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.tertiary)
    }
    .buttonStyle(.shadow)
    .padding()
}
