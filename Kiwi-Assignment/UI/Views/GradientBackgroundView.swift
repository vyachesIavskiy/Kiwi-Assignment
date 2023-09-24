import SwiftUI

struct GradientBackgroundView: View {
    @State private var rotationAngle = Angle.zero
    
    private var animation: Animation {
        .linear(duration: 20).repeatForever(autoreverses: false)
    }
    
    var body: some View {
        AngularGradient(
            colors: [
                .orange,
                .cyan,
                .cyan,
                .yellow,
                .yellow,
                .green,
                .green,
                .orange
            ],
            center: .center,
            angle: rotationAngle
        )
        .saturation(2.5)
        .opacity(0.4)
        .ignoresSafeArea()
        .blur(radius: 75)
        .onAppear {
            withAnimation(animation) {
                rotationAngle = .degrees(360)
            }
        }
    }
}

#Preview {
    GradientBackgroundView()
}
