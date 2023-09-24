import SwiftUI

extension FlightsContentView {
    struct ItineraryPlaceNamesView: View {
        var departureCityName: String
        var arrivalCityName: String
        
        var body: some View {
            ZStack {
                text(departureCityName, horizontalAlignment: .leading, verticalAlignment: .top)
                
                text(arrivalCityName, horizontalAlignment: .trailing, verticalAlignment: .bottom)
            }
        }
        
        @ViewBuilder func text(
            _ string: String,
            horizontalAlignment: HorizontalAlignment,
            verticalAlignment: VerticalAlignment
        ) -> some View {
            ZStack {
                Text(string)
                    .foregroundStyle(.black)
                    .brightness(-4)
                    .blendMode(.softLight)
                
                Text(string)
                    .foregroundStyle(.cyan)
                    .opacity(0.1)
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: horizontalAlignment, vertical: .center))
            .padding()
            .frame(maxHeight: .infinity, alignment: Alignment(horizontal: .center, vertical: verticalAlignment))
        }
    }
}

#Preview("FlightItineraryPlaceNamesView") {
    ZStack {
        Color.blue
            .opacity(0.05)
            .ignoresSafeArea()
        
        FlightsContentView.ItineraryPlaceNamesView(departureCityName: "Prague", arrivalCityName: "New York")
    }
}
