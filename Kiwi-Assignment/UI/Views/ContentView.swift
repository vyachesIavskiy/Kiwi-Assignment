import SwiftUI

extension ContentView {
    @Observable
    final class ViewModel {
        enum NavigationState {
            case configuration
            case loading
            case flights
        }
        
        private var graphQLClient: GraphQLClient
        var navigationState = NavigationState.configuration
        
        init(graphQLClient: GraphQLClient) {
            self.graphQLClient = graphQLClient
        }
        
        func setNavigation(to newNavigationState: NavigationState) {
            navigationState = newNavigationState
        }
        
        func searchConfigurationViewModel() -> SearchConfigurationViewModel {
            let viewModel = SearchConfigurationViewModel(graphQLClient: graphQLClient)
            Task { @MainActor in
                await viewModel.onProcceed()
                setNavigation(to: .loading)
            }
            return viewModel
        }
    }
}

struct ContentView: View {
    @State var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            if viewModel.navigationState != .flights {
                GradientBackgroundView()
                    .transition(
                        .scale(0).animation(.easeIn(duration: 0.5))
                        .combined(with: .opacity.animation(.easeIn(duration: 0.35)))
                    )
            }
            
            switch viewModel.navigationState {
            case .configuration:
                SearchConfigurationView(viewModel: viewModel.searchConfigurationViewModel())
                    .transition(
                        .move(edge: .top)
                        .combined(with: .offset(y: -100))
                    )
                
            case .loading:
                FlightsLoadingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .scale(scale: 0).animation(.easeIn(duration: 0.5))
                            .combined(with: .opacity.animation(.easeIn(duration: 0.35)))
                    ))
                
            case .flights:
                FlightsContentView()
                    .transition(
                        .scale(2).animation(.easeOut(duration: 0.5))
                        .combined(with: .opacity.animation(.easeOut(duration: 0.35).delay(0.15)))
                    )
            }
            
            if viewModel.navigationState != .configuration {
                dismissFlightsButton
            }
            
//            HStack {
//                Button("Previous") {
//                    switch viewModel.navigationState {
//                    case .configuration: viewModel.setNavigation(to: .flights)
//                    case .loading: viewModel.setNavigation(to: .configuration)
//                    case .flights: viewModel.setNavigation(to: .loading)
//                    }
//                }
//                
//                Button("Next") {
//                    switch viewModel.navigationState {
//                    case .configuration: viewModel.setNavigation(to: .loading)
//                    case .loading: viewModel.setNavigation(to: .flights)
//                    case .flights: viewModel.setNavigation(to: .configuration)
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
//            .padding()
//            .ignoresSafeArea()
        }
        .animation(.default, value: viewModel.navigationState)
    }
    
    @ViewBuilder private var dismissFlightsButton: some View {
        Button {
            viewModel.setNavigation(to: .configuration)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor, .thickMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.trailing)
        .padding(.top, 10)
    }
}

#Preview {
    ContentView(viewModel: ContentView.ViewModel(graphQLClient: GraphQLClient()))
}
