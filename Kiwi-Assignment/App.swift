import SwiftUI

@Observable final class RootViewModel {
    private var graphQLClient = GraphQLClient()
    
    var searchConfigurationViewModel: SearchConfigurationViewModel {
        SearchConfigurationViewModel(
            graphQLClient: graphQLClient
        )
    }
    
    var contentViewModel: ContentView.ViewModel {
        ContentView.ViewModel(graphQLClient: graphQLClient)
    }
}

@main
struct Kiwi_AssignmentApp: App {
    @State private var viewModel = RootViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel.contentViewModel)
        }
    }
}
