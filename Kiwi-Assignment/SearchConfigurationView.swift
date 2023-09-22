import SwiftUI

struct SearchConfigurationView: View {
    @State private var numberOfAdults = 1
    @State private var numberOfChildren = 0
    @State private var cabinClasses: Set<Models.Flight.CabinClass> = [.economy]
    
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
                    
                    Stepper(value: $numberOfAdults, in: 1...10) {
                        Text("Adults: \(numberOfAdults)")
                    }
                    
                    Stepper(value: $numberOfChildren, in: 0...10) {
                        Text("Children: \(numberOfChildren)")
                    }
                    
                    Text("Just one more step...")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    
                    MultiSelectionPicker(sources: Models.Flight.CabinClass.allCases, selection: $cabinClasses) { cabinClass in
                        Text(cabinClass.stringValue)
                    } collapsedContent: {
                        Text(cabinClasses.map(\.stringValue).joined(separator: ", "))
                    } label: {
                        Text("Cabin class")
                    }
                }
                .padding([.horizontal, .top])
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    
                } label: {
                    Text("Let's go!")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(16)
                }
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
