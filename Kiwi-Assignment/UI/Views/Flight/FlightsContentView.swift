import SwiftUI

struct FlightsContentView: View {
    struct PreviewState: Identifiable {
        var departureName: String
        var departureCode: String
        var departureImage: Image
        
        var arrivalName: String
        var arrivalCode: String
        var arrivalImage: Image
        
        var duration: String
        var stops: Int
        var price: String
        
        var id: String { departureCode }
    }
    
    @State private var items = [
        PreviewState(
            departureName: "Prague",
            departureCode: "PRG",
            departureImage: Image("place-preview-image-1"),
            arrivalName: "New York",
            arrivalCode: "JFK",
            arrivalImage: Image("place-preview-image-2"),
            duration: "12h 31m",
            stops: 2,
            price: "$ 199"
        ),
        PreviewState(
            departureName: "Brno",
            departureCode: "BRN",
            departureImage: Image("place-preview-image-2"),
            arrivalName: "Amsterdam",
            arrivalCode: "AMS",
            arrivalImage: Image("place-preview-image-3"),
            duration: "3h 12m",
            stops: 0,
            price: "$ 312.33"
        )
    ]
    @State private var scrollOffset = CGPoint.zero
    @State private var flightDetailsSize = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                itineraryImages(geometry)
                
                materialOverlay(geometry)
                
                itineraryPlaceNames(geometry)
                
                flightsDetailsScrollView(geometry)
            }
        }
    }
    
    @ViewBuilder private func itineraryImages(_ geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                let cornerRadius = cornerRadius(from: geometry, index: index)
                let item = items[index]
                
                ItineraryImagesView(
                    departureCityImage: item.departureImage,
                    arrivalCityImage: item.arrivalImage,
                    cornerRadius: cornerRadius
                )
                .opacity(opacity(from: geometry, index: index))
                .scaleEffect(scaleForImages(from: geometry, index: index))
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder private func itineraryPlaceNames(_ geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                
                ItineraryPlaceNamesView(
                    departureCityName: item.departureName,
                    arrivalCityName: item.arrivalName
                )
                .opacity(opacity(from: geometry, index: index))
                .scaleEffect(scaleForNames(from: geometry, index: index))
            }
        }
        .padding(.bottom, flightDetailsSize.height)
    }
    
    @ViewBuilder private func materialOverlay(_ geometry: GeometryProxy) -> some View {
        let contentHeight = geometry.size.height
        let height = contentHeight + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
        let availableHeight = contentHeight - flightDetailsSize.height
        
        let availableRatio = availableHeight / height
        let topQuarterRatio = 0.2
        let bottomQuarterRatio = 0.15
        
        let topSafeArea = geometry.safeAreaInsets.top / height
        let topQuarter = topQuarterRatio * availableRatio
        let bottomQuarter = (1 - bottomQuarterRatio) * availableRatio

        Rectangle()
            .foregroundStyle(.bar)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .white, location: 0),
                        .init(color: .clear, location: topSafeArea + topQuarter),
                        .init(color: .clear, location: topSafeArea + bottomQuarter),
                        .init(color: .white, location: topSafeArea + availableRatio),
                        .init(color: .white, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }
    
    @ViewBuilder private func flightsDetailsScrollView(_ geometry: GeometryProxy) -> some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom, spacing: 0) {
                ScrollViewOffsetReader(.horizontal, scrollOffset: $scrollOffset)
                
                ForEach(items) { item in
                    DetailView(
                        departureCode: item.departureCode,
                        arrivalCode: item.arrivalCode,
                        time: item.duration,
                        stopCount: item.stops,
                        price: item.price
                    )
                    .padding(.horizontal)
                    .frame(width: geometry.size.width)
                }
            }
            .readSize($flightDetailsSize)
            .padding(.bottom, geometry.safeAreaInsets.bottom)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}

private extension FlightsContentView {
    func pageFloat(from geometry: GeometryProxy) -> CGFloat {
        scrollOffset.x / geometry.size.width
    }
    
    func page(from geometry: GeometryProxy) -> Int {
        Int(pageFloat(from: geometry))
    }
    
    func pageOffset(from geometry: GeometryProxy) -> CGFloat {
        pageFloat(from: geometry) - CGFloat(page(from: geometry))
    }
    
    func cornerRadius(from geometry: GeometryProxy, index: Int) -> Double {
        let page = page(from: geometry)
        let pageOffset = pageOffset(from: geometry)
        
        return if page == index {
            max(12, 64 * pageOffset)
        } else {
            12
        }
    }
    
    func opacity(from geometry: GeometryProxy, index: Int) -> Double {
        let page = page(from: geometry)
        let pageOffset = pageOffset(from: geometry)
        
        return if page == index {
            1.2 - pageOffset * 1.2
        } else if index == page + 1 {
            -0.2 + pageOffset * 1.4
        } else {
            0
        }
    }
    
    func scaleForImages(from geometry: GeometryProxy, index: Int) -> Double {
        let page = page(from: geometry)
        let pageOffset = pageOffset(from: geometry)
        
        return if page == index {
            max(0.4, 1.0 - pageOffset * 0.5)
        } else if index == page + 1 {
            2.0 - pageOffset
        } else {
            0
        }
    }
    
    func scaleForNames(from geometry: GeometryProxy, index: Int) -> Double {
        let page = page(from: geometry)
        let pageOffset = pageOffset(from: geometry)
        
        return if page == index {
            max(0, 1.0 - pageOffset * 2)
        } else if index == page + 1 {
            3.0 - pageOffset * 2
        } else {
            0
        }
    }
}

#Preview {
    FlightsContentView()
}
