import SwiftUI

extension FlightsContentView {
    struct DetailView: View {
        var departureCode: String
        var arrivalCode: String
        var time: String
        var stopCount: Int
        var price: String
        
        // This is another good place for localization
        private var stopsText: String {
            if stopCount == 0 {
                "Direct"
            } else if stopCount == 1 {
                "1 stop"
            } else {
                "\(stopCount) stops"
            }
        }
        
        var body: some View {
            VStack(spacing: 40) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        Text("\(departureCode) \(Image(systemName: "chevron.forward")) \(arrivalCode)")
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(time)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Text(stopsText)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                HStack {
                    Button {
                        // TODO: Open URL
                    } label: {
                        Text(price)
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    
                    Button {
                        // TODO: Open detail screen
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.largeTitle)
                    }
                    .foregroundStyle(Color.accentColor.secondary)
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview("Flight detail") {
    FlightsContentView.DetailView(
        departureCode: "PRG",
        arrivalCode: "JFK",
        time: "12h 31m",
        stopCount: 2,
        price: "$ 199"
    )
}
