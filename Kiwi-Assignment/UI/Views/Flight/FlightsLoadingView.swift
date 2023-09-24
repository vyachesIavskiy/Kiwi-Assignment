import SwiftUI

struct FlightsLoadingView: View {
    var body: some View {
        Text("Looking for the best fligts for you")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .fontWeight(.semibold)
            .foregroundStyle(.black)
            .brightness(-3)
            .blendMode(.overlay)
            .padding(.bottom, 250)
            .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.blue, .orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            .opacity(0.3)
            .ignoresSafeArea()
        
        FlightsLoadingView()
    }
}
