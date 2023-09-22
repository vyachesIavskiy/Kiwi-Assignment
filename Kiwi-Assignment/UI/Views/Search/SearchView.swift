import SwiftUI

@Observable final class SearchViewModel {
    typealias Places = Models.Places
    typealias Place = Models.Place
    
    enum SearchMode: Identifiable {
        case from
        case to
        
        var id: Self { self }
    }
    
    enum Error: Swift.Error {
        case cancelled
    }
    
    fileprivate var searchTerm = "" {
        didSet {
            guard searchTerm != oldValue else { return }
            
            performSearch()
        }
    }
    fileprivate var searchMode: SearchMode
    
    fileprivate var isSearchPresented = true
    
    private var places = [Place]()
    fileprivate var selectedPlaces: Set<Place> = []
    
    fileprivate var placesToDisplay: [Place] {
        searchTerm.isEmpty ? Array(selectedPlaces) : places
    }
    
    private let graphQLClient: GraphQLClient
    private var searchTask: Task<Void, Never>?
    private var responseContinuation: CheckedContinuation<Set<Place>, Swift.Error>?
    
    fileprivate var searchPrompt: String {
        switch searchMode {
        case .from: "Where from?"
        case .to: "Where to?"
        }
    }
    
    fileprivate var navigationTitle: String {
        switch searchMode {
        case .from: "Departure"
        case .to: "Arrival"
        }
    }
    
    init(searchMode: SearchMode, selection: Set<Place>, graphQLClient: GraphQLClient) {
        self.searchMode = searchMode
        self.selectedPlaces = selection
        self.graphQLClient = graphQLClient
    }
    
    func response() async throws -> Set<Place> {
        try await withCheckedThrowingContinuation { continuation in
            responseContinuation = continuation
        }
    }
    
    private func performSearch() {
        searchTask?.cancel()
        
        guard !searchTerm.isEmpty else {
            places = []
            return
        }
        
        searchTask = Task { @MainActor [weak self, searchTerm, graphQLClient] in
            try? await Task.sleep(for: .seconds(1))
            
            let request = GraphQLRequest.places(searchTerm: searchTerm)
            guard let places = try? await graphQLClient.fetch(Places.self, request: request).places else { return }
            
            guard !Task.isCancelled else { return }
            
            self?.places = places
        }
        
        searchTask = nil
    }
    
    fileprivate func toggleSelection(for place: Place) {
        if selectedPlaces.contains(place) {
            selectedPlaces.remove(place)
        } else {
            selectedPlaces.insert(place)
        }
    }
    
    fileprivate func isSelected(_ place: Place) -> Bool {
        selectedPlaces.contains(place)
    }
    
    fileprivate func confirm() {
        responseContinuation?.resume(returning: selectedPlaces)
    }
    
    fileprivate func cancel() {
        responseContinuation?.resume(throwing: Error.cancelled)
    }
}

struct SearchView: View {
    typealias Place = SearchViewModel.Place
    
    @State var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.placesToDisplay.isEmpty {
                    Text("Type to search for places")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .fontDesign(.rounded)
                } else {
                    List {
                        ForEach(viewModel.placesToDisplay) { place in
                            Button {
                                viewModel.toggleSelection(for: place)
                            } label: {
                                PlaceRow(place, isSelected: viewModel.isSelected(place), image: nil)
                            }
                            .buttonStyle(.shadow)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchTerm,
                isPresented: $viewModel.isSearchPresented,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: viewModel.searchPrompt
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancel()
                        dismiss()
                    }
                }
                
                if !viewModel.selectedPlaces.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Confirm") {
                            viewModel.confirm()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

private struct PlaceRow: View {
    typealias Place = SearchView.Place
    
    var place: Place
    var isSelected: Bool
    var image: Image?
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray
                
                ProgressView()
            }
        }
        .frame(height: 200)
        .overlay {
            ZStack {
                Text(place.name)
                    .foregroundStyle(.background)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background {
                        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.thickMaterial)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        }
    }
    
    init(_ place: Place, isSelected: Bool, image: Image?) {
        self.place = place
        self.isSelected = isSelected
        self.image = image
    }
}

#Preview("Place") {
    Button {} label: {
        PlaceRow(
            Models.Place(id: "test-place", legacyID: "test-place", name: "Test Place", latitude: 0, longitude: 0),
            isSelected: true,
            image: Image("place-preview-image")
        )
    }
    .buttonStyle(.shadow)
    .padding()
}

#Preview("From") {
    SearchView(viewModel: SearchViewModel(searchMode: .from, selection: [], graphQLClient: GraphQLClient()))
}

#Preview("To") {
    SearchView(viewModel: SearchViewModel(searchMode: .to, selection: [], graphQLClient: GraphQLClient()))
}
