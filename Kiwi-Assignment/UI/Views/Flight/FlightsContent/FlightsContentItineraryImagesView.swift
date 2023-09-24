import SwiftUI

extension FlightsContentView {
    struct ItineraryImagesView: View {
        var departureCityImage: Image
        var arrivalCityImage: Image
        var cornerRadius: Double
        
        var body: some View {
            ZStack {
                tile(departureCityImage, corner: .topLeft)
                
                tile(arrivalCityImage, corner: .bottomRight)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        
        @ViewBuilder private func tile(_ image: Image, corner: Triangle.Corner) -> some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .overlay {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .mask(Triangle(corner: corner).aspectRatio(1, contentMode: .fill))
        }
    }
}

#Preview("FlightItineraryImagesView") {
    FlightsContentView.ItineraryImagesView(
        departureCityImage: Image("place-preview-image-1"),
        arrivalCityImage: Image("place-preview-image-2"),
        cornerRadius: 12
    )
    .padding()
}
