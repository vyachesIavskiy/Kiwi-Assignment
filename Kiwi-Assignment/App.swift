import SwiftUI

enum Navigation {
    case flights
}

@Observable final class RootViewModel {
    var navigationPath = [Navigation]()
    var graphQLClient = GraphQLClient()
    
    var searchConfigurationViewModel: SearchConfigurationViewModel {
        SearchConfigurationViewModel(
            navigation: Binding { [weak self] in
                self?.navigationPath ?? []
            } set: { [weak self] newValue in
                self?.navigationPath = newValue
            },
            graphQLClient: graphQLClient
        )
    }
}

@main
struct Kiwi_AssignmentApp: App {
    @State private var viewModel = RootViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $viewModel.navigationPath) {
                SearchConfigurationView(viewModel: viewModel.searchConfigurationViewModel)
            }
            .navigationDestination(for: Navigation.self) { path in
                switch path {
                case .flights: EmptyView()
                }
            }
        }
    }
}
