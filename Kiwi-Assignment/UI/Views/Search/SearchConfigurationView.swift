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
    
    private var navigation: Binding<[Navigation]>
    private var graphQLClient: GraphQLClient
    
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
    
    init(navigation: Binding<[Navigation]>, graphQLClient: GraphQLClient) {
        self.navigation = navigation
        self.graphQLClient = graphQLClient
    }
    
    fileprivate func presentSearch(mode: SearchMode) {
        searchMode = mode
    }
    
    fileprivate func procceed() {
        navigation.wrappedValue.append(.flights)
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
                Text("Where would you like to go?")
                    .font(.title)
                    .fontDesign(.rounded)
                
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
            .padding([.horizontal, .top])
        }
        .safeAreaInset(edge: .bottom) {
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
        }.sheet(item: $viewModel.searchMode) { searchMode in
            SearchView(viewModel: viewModel.searchViewModel(searchMode: searchMode))
        }
    }
}

#Preview {
    SearchConfigurationView(viewModel: SearchConfigurationViewModel(
        navigation: .constant([]),
        graphQLClient: GraphQLClient()
    ))
}
