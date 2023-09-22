import SwiftUI

struct Stepper<Label: View>: View {
    private var label: Label
    private var onIncrement: (() -> Void)?
    private var onDecrement: (() -> Void)?
    
    private var _canIncrement: () -> Bool
    private var _canDecrement: () -> Bool
    
    @State private var tapLocation: TapLocation?
    @State private var incrementDisabled = false
    @State private var decrementDisabled = false
    @State private var appeared = false
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let leftSideSafetyOffset = CGFloat(0.45)
    private let rightSideSafetyOffset = CGFloat(0.65)
    
    private var isPressed: Bool {
        tapLocation != nil
    }
    
    private var rotationAngle: Angle {
        let action = resolveAction()
        
        return switch tapLocation {
        case .left:
            if (action == .increment && !incrementDisabled) ||
               (action == .decrement && !decrementDisabled) {
                .degrees(-5)
            } else {
                .zero
            }
            
        case .right:
            if (action == .increment && !incrementDisabled) ||
               (action == .decrement && !decrementDisabled) {
                .degrees(5)
            } else {
                .zero
            }
        
        default: .zero
        }
    }
    
    private var shadowColor: Color {
        switch resolveAction() {
        case .decrement: _canDecrement() ? .red : .gray
        case .increment: _canIncrement() ? .green : .gray
        
        default: .black.opacity(0.33)
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "minus")
                .font(.title2)
                .foregroundStyle(decrementDisabled ? .gray : .red)
            
            Spacer()
            
            label
            
            Spacer()
            
            Image(systemName: "plus")
                .font(.title2)
                .foregroundStyle(incrementDisabled ? .gray : .green)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(
            .background.shadow(.drop(color: shadowColor, radius: isPressed ? 2 : 5, y: isPressed ? 0 : 2)),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .rotation3DEffect(rotationAngle, axis: (x: 0.0, y: 1.0, z: 0.0))
        .animation(.default, value: isPressed)
        .animation(.default, value: tapLocation)
        .animation(.default, value: rotationAngle)
        .overlay {
            TapLocationView(
                action: handleAction,
                repeatAction: handleAction,
                location: resolveTapLocation
            ) {
                tapLocation = nil
            }
        }
        .onAppear {
            incrementDisabled = !_canIncrement()
            decrementDisabled = !_canDecrement()
            appeared = true
        }
    }
    
    init(@ViewBuilder label: () -> Label, onIncrement: (() -> Void)?, onDecrement: (() -> Void)?) {
        self.label = label()
        self._canIncrement = { true }
        self._canDecrement = { true }
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    init<V: Strideable>(value: Binding<V>, step: V.Stride = 1, @ViewBuilder label: () -> Label) {
        self.label = label()
        self._canIncrement = { true }
        self._canDecrement = { true }
        self.onIncrement = { value.wrappedValue = value.wrappedValue.advanced(by: step) }
        self.onDecrement = { value.wrappedValue = value.wrappedValue.advanced(by: -step) }
    }
    
    init<V: Strideable>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self._canIncrement = {
            let newValue = value.wrappedValue.advanced(by: step)
            return bounds.contains(newValue)
        }
        self._canDecrement = {
            let newValue = value.wrappedValue.advanced(by: -step)
            return bounds.contains(newValue)
        }
        self.onIncrement = {
            let newValue = value.wrappedValue.advanced(by: step)
            if bounds.contains(newValue) {
                value.wrappedValue = newValue
            }
        }
        self.onDecrement = {
            let newValue = value.wrappedValue.advanced(by: -step)
            if bounds.contains(newValue) {
                value.wrappedValue = newValue
            }
        }
    }
}

private extension Stepper {
    enum Action {
        case decrement
        case increment
    }
    
    enum TapLocation {
        case left
        case middle
        case right
    }
    
    func resolveTapLocation(from location: CGPoint) {
        tapLocation = if location.x < leftSideSafetyOffset {
            .left
        } else if location.x > rightSideSafetyOffset {
            .right
        } else {
            .middle
        }
    }
    
    func resolveAction() -> Action? {
        switch tapLocation {
        case .left:
            layoutDirection == .leftToRight ? .decrement : .increment
        case .right:
            layoutDirection == .leftToRight ? .increment : .decrement
            
        default:
            nil
        }
    }
    
    func handleAction(_ location: CGPoint) {
        resolveTapLocation(from: location)
        
        let action = resolveAction()
        switch action {
        case .increment:
            if _canIncrement() {
                onIncrement?()
            }
            
        case .decrement:
            if _canDecrement() {
                onDecrement?()
            }
            
        case nil: break
        }
        
        incrementDisabled = !_canIncrement()
        decrementDisabled = !_canDecrement()
    }
}

#Preview("Stepper (closures)") {
    Stepper {
        Label("Press Me", systemImage: "star")
    } onIncrement: {
        print("Increment pressed")
    } onDecrement: {
        print("Decrement pressed")
    }
}

#Preview("Stepper (binding)") {
    @State var counter = 0
    
    return Stepper(value: $counter) {
        Text("Counter \(counter)")
    }
}
