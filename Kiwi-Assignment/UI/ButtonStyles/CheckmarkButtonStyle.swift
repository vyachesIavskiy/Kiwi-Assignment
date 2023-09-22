import SwiftUI

struct CheckmarkButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .opacity(configuration.isPressed ? 0.6 : 1)
                
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .animation(.default, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CheckmarkButtonStyle {
    static func checkmark(selected: Bool) -> CheckmarkButtonStyle {
        CheckmarkButtonStyle(isSelected: selected)
    }
}

#Preview {
    VStack {
        Button(action: { print("Pressed") }) {
            Label("Press Me", systemImage: "star")
        }
        .buttonStyle(.checkmark(selected: false))
        
        Button(action: { print("Pressed") }) {
            Label("Press Me", systemImage: "star")
        }
        .buttonStyle(.checkmark(selected: true))
    }
}
