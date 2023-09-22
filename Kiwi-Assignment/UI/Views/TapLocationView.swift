import SwiftUI

struct TapLocationView: UIViewRepresentable {
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
    
    func makeUIView(context: Context) -> TapLocationUIView {
        TapLocationUIView(
            delay: delay,
            repeatDelay: repeatDelay,
            action: action,
            repeatAction: repeatAction,
            location: location,
            onEnd: onEnd
        )
    }
    
    func updateUIView(_ uiView: TapLocationUIView, context: Context) {
        uiView.delay = delay
        uiView.repeatDelay = repeatDelay
        uiView.action = action
        uiView.repeatAction = repeatAction
        uiView.onEnd = onEnd
    }
}

final class TapLocationUIView: UIView {
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
        if let aspectLocation {
            location(aspectLocation)
        }
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
    TapLocationView(
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
