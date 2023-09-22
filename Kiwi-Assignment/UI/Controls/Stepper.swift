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
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let leftSideSafetyOffset = CGFloat(0.45)
    private let rightSideSafetyOffset = CGFloat(0.65)
    
    private var isPressed: Bool {
        tapLocation != nil
    }
    
    private var rotationAngle: Angle {
        switch tapLocation {
        case .left:
            .degrees(-5)
            
        case .right:
            .degrees(5)
        
        default: .zero
        }
    }
    
    private var shadowColor: Color {
        switch resolveAction() {
        case .decrement: .red
        case .increment: .green
        
        default: .black.opacity(0.33)
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "minus")
                .font(.title2)
                .foregroundStyle(.red)
                .disabled(decrementDisabled)
            
            Spacer()
            
            label
            
            Spacer()
            
            Image(systemName: "plus")
                .font(.title2)
                .foregroundStyle(.green)
                .disabled(decrementDisabled)
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
        .overlay {
            LocationTapView(
                action: handleAction,
                repeatAction: handleAction,
                location: resolveTapLocation
            ) {
                tapLocation = nil
            }
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
            let canIncrement = _canIncrement()
            incrementDisabled = !canIncrement
            if canIncrement {
                onIncrement?()
            }
            
        case .decrement:
            let canDecrement = _canDecrement()
            decrementDisabled = !canDecrement
            if canDecrement {
                onDecrement?()
            }
        case nil: break
        }
    }
}

#Preview {
    Stepper {
        Label("Press Me", systemImage: "star")
    } onIncrement: {
        print("Increment pressed")
    } onDecrement: {
        print("Decrement pressed")
    }
}

struct LocationTapView: UIViewRepresentable {
    var delay: Duration
    var repeatDelay: Duration
    var action: (CGPoint) -> Void
    var repeatAction: (CGPoint) -> Void
    var location: (CGPoint) -> Void
    var onEnd: () -> Void
    
    init(
        delay: Duration = .seconds(0.75),
        repeatDelay: Duration = .seconds(0.5),
        action: @escaping (CGPoint) -> Void,
        repeatAction: @escaping (CGPoint) -> Void,
        location: @escaping (CGPoint) -> Void,
        onEnd: @escaping () -> Void
    ) {
        self.delay = delay
        self.repeatDelay = repeatDelay
        self.action = action
        self.repeatAction = repeatAction
        self.location = location
        self.onEnd = onEnd
    }
    
    func makeUIView(context: Context) -> UILocationTapView {
        UILocationTapView(
            delay: delay,
            repeatDelay: repeatDelay,
            action: action,
            repeatAction: repeatAction,
            location: location,
            onEnd: onEnd
        )
    }
    
    func updateUIView(_ uiView: UILocationTapView, context: Context) {
        uiView.delay = delay
        uiView.repeatDelay = repeatDelay
        uiView.action = action
        uiView.repeatAction = repeatAction
        uiView.onEnd = onEnd
    }
}

final class UILocationTapView: UIView {
    var delay: Duration
    var repeatDelay: Duration
    var action: (CGPoint) -> Void
    var repeatAction: (CGPoint) -> Void
    var location: (CGPoint) -> Void
    var onEnd: () -> Void
    
    private var touchesBeginTimeStamp: TimeInterval?
    private var repeatTask: Task<Void, Never>?
    private var aspectLocation: CGPoint?
    
    init(
        delay: Duration,
        repeatDelay: Duration,
        action: @escaping (CGPoint) -> Void,
        repeatAction: @escaping (CGPoint) -> Void,
        location: @escaping (CGPoint) -> Void,
        onEnd: @escaping () -> Void
    ) {
        self.delay = delay
        self.repeatDelay = repeatDelay
        self.action = action
        self.repeatAction = repeatAction
        self.location = location
        self.onEnd = onEnd
        
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let event, touches.count == 1, let firstTouch = touches.first else { return }
        
        touchesBeginTimeStamp = event.timestamp
        updateAspectLocation(from: firstTouch)
        repeatTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.5))
                
                guard !Task.isCancelled else { break }
                
                if let aspectLocation {
                    await MainActor.run {
                        repeatAction(aspectLocation)
                    }
                }
            }
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let firstTouch = touches.first else {
            cancel()
            return
        }
        
        updateAspectLocation(from: firstTouch)
        if let aspectLocation {
            location(aspectLocation)
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            cancel()
        }
        
        guard let event, touches.count == 1, let firstTouch = touches.first else { return }
        
        updateAspectLocation(from: firstTouch)
        
        if let touchesBeginTimeStamp, event.timestamp - touchesBeginTimeStamp < 0.5, let aspectLocation {
            action(aspectLocation)
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancel()
        
        super.touchesCancelled(touches, with: event)
    }
    
    private func cancel() {
        print("Cancel touches")
        touchesBeginTimeStamp = nil
        repeatTask?.cancel()
        repeatTask = nil
        onEnd()
    }
    
    private func updateAspectLocation(from touch: UITouch) {
        let touchLocation = touch.location(in: self)
        aspectLocation = CGPoint(x: touchLocation.x / bounds.width, y: touchLocation.y / bounds.height)
    }
}

#Preview {
    LocationTapView(
        action: { location in
            print("Tap at \(location)")
        },
        repeatAction: { location in
            print("Long tap at \(location)")
        }, location: { location in
            print("Location changed to \(location)")
        },
        onEnd: {
            print("Ended")
        }
    )
}
