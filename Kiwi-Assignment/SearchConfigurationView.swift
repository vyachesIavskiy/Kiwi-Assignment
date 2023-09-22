import SwiftUI

@Observable
final class SearchConfigurationViewModel {
    typealias CabinClass = Models.Flight.CabinClass
    typealias Place = Models.Place
    
    var fromPlaces = [Place]()
    var toPlaces = [Place]()
    var numberOfAdults = 1
    var numberOfChildren = 0
    var selectedCabinClasses: Set<CabinClass> = [.economy]
    
    var collapsedSelectedCabinClassesString: String {
        // I need this for proper sorting
        CabinClass.allCases
            .filter(selectedCabinClasses.contains)
            .map(\.stringValue)
            .joined(separator: ", ")
    }
    
    var procceedButtonDisabled: Bool {
        fromPlaces.isEmpty && toPlaces.isEmpty
    }
    
    func procceed() {
        // TODO: Procceed to flight selection view
    }
}

struct SearchConfigurationView: View {
    @State private var viewModel = SearchConfigurationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Where would you like to go?")
                        .font(.title)
                        .fontDesign(.rounded)
                    
                    Button {
                        
                    } label: {
                        Text("From")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.shadow)
                    
                    Button {
                        
                    } label: {
                        Text("To")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.tertiary)
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
            }
        }
    }
}

#Preview {
    SearchConfigurationView()
}
