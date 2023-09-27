import SwiftUI

@Observable
final class SearchConfigurationViewModel {
    typealias CabinClass = Models.Flight.CabinClass
    typealias Place = Models.Place
    typealias SearchMode = SearchViewModel.SearchMode
    
    fileprivate var fromPlaces = Set<Place>()
    fileprivate var toPlaces = Set<Place>()
    fileprivate var numberOfAdults = 1
    fileprivate var numberOfChildren = 0
    fileprivate var selectedCabinClasses: Set<CabinClass> = [.economy]
    fileprivate var searchMode: SearchMode?
    
    private var graphQLClient: GraphQLClient
    private var continuation: CheckedContinuation<Void, Never>?
    
    fileprivate var collapsedSelectedCabinClassesString: String {
        // I need this for proper sorting
        CabinClass.allCases
            .filter(selectedCabinClasses.contains)
            .map(\.stringValue)
            .joined(separator: ", ")
    }
    
    fileprivate var procceedButtonDisabled: Bool {
        fromPlaces.isEmpty && toPlaces.isEmpty
    }
    
    fileprivate var fromPlacesFormatted: String {
        fromPlaces.map(\.name).joined(separator: ", ")
    }
    
    fileprivate var toPlacesFormatted: String {
        toPlaces.map(\.name).joined(separator: ", ")
    }
    
    init(graphQLClient: GraphQLClient) {
        self.graphQLClient = graphQLClient
    }
    
    func onProcceed() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    func procceed() {
        continuation?.resume()
        continuation = nil
    }
    
    fileprivate func presentSearch(mode: SearchMode) {
        searchMode = mode
    }
    
    fileprivate func searchViewModel(searchMode: SearchMode) -> SearchViewModel {
        let viewModel = SearchViewModel(
            searchMode: searchMode,
            selection: fromPlaces,
            graphQLClient: graphQLClient
        )
        
        Task { @MainActor [weak self] in
            guard let newPlaces = try? await viewModel.response() else { return }
            
            switch searchMode {
            case .from: self?.fromPlaces = newPlaces
            case .to: self?.toPlaces = newPlaces
            }
        }
        
        return viewModel
    }
}

struct SearchConfigurationView: View {
    @State var viewModel: SearchConfigurationViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                placesSection
                
                if viewModel.searchMode != .to {
                    Button {
                        viewModel.presentSearch(mode: .from)
                    } label: {
                        HStack {
                            Text("From:")
                                .foregroundStyle(.tertiary)
                            
                            if !viewModel.fromPlaces.isEmpty {
                                ViewThatFits {
                                    Text(viewModel.fromPlacesFormatted)
                                    
                                    Text("\(viewModel.fromPlaces.count) seleted")
                                }
                            } else {
                                Text("Anywhere")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .buttonStyle(.shadow)
                    .transition(.offset(y: -1000))
                }
                
                if viewModel.searchMode != .from {
                    Button {
                        viewModel.presentSearch(mode: .to)
                    } label: {
                        HStack {
                            Text("To:")
                                .foregroundStyle(.tertiary)
                            
                            if !viewModel.toPlaces.isEmpty {
                                ViewThatFits {
                                    Text(viewModel.toPlacesFormatted)
                                    
                                    Text("\(viewModel.toPlaces.count) seleted")
                                }
                            } else {
                                Text("Anywhere")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .buttonStyle(.shadow)
                    .transition(.offset(y: 1000))
                }
                
                searchResultsSection
                
                if viewModel.searchMode == nil {
                    passengersSection
                        .transition(.offset(y: 1000))
                    
                    cabinClassSection
                        .transition(.offset(y: 1000))
                }
            }
            .padding([.horizontal, .top])
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.searchMode == nil {
                Button {
                    viewModel.procceed()
                } label: {
                    Text("Let's go!")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(16)
                }
                .disabled(viewModel.procceedButtonDisabled)
                .buttonStyle(.shadow)
                .backgroundStyle(Color.accentColor)
                .padding()
                .transition(.offset(y: 1000))
            }
        }
        .animation(.default, value: viewModel.searchMode)
//        .sheet(item: $viewModel.searchMode) { searchMode in
//            SearchView(viewModel: viewModel.searchViewModel(searchMode: searchMode))
//        }
    }
    
    @ViewBuilder private var placesSection: some View {
        if viewModel.searchMode == nil {
            Text("Where would you like to go?")
                .font(.title)
                .fontDesign(.rounded)
                .transition(.offset(y: -1000))
        } else {
            Button("Done") {
                viewModel.searchMode = nil
            }
        }
    }
    
    @ViewBuilder private var searchResultsSection: some View {
        if viewModel.searchMode != nil {
            Text("Search result")
        }
    }
    
    @ViewBuilder private var passengersSection: some View {
        Text("Who will be travalling?")
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
        
        Stepper(value: $viewModel.numberOfAdults, in: 1...10) {
            Text("Adults: \(viewModel.numberOfAdults)")
        }
        
        Stepper(value: $viewModel.numberOfChildren, in: 0...10) {
            Text("Children: \(viewModel.numberOfChildren)")
        }
    }
    
    @ViewBuilder private var cabinClassSection: some View {
        Text("Just one more step...")
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
        
        MultiSelectionPicker(
            sources: SearchConfigurationViewModel.CabinClass.allCases,
            selection: $viewModel.selectedCabinClasses
        ) { cabinClass in
            Text(cabinClass.stringValue)
        } collapsedContent: {
            Text(viewModel.collapsedSelectedCabinClassesString)
        } label: {
            Text("Cabin class")
        }
    }
}

#Preview {
    SearchConfigurationView(viewModel: SearchConfigurationViewModel(
        graphQLClient: GraphQLClient()
    ))
}
