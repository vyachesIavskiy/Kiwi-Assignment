import Foundation

struct GraphQLRequest: CustomDebugStringConvertible {
    var path: URL
    var body: String
    var debugDescription: String
}

// MARK: Actual requests
// There are a lot of GraphQL packages and libs, but since I'm not using them and the network
// is not my main priority, I will create my requests this way
extension GraphQLRequest {
    private static let skypickerURL = URL(string: "https://api.skypicker.com/umbrella/v2/graphql")!
    
    private init(body: String, debugDescription: String) {
        self.init(path: Self.skypickerURL, body: body, debugDescription: debugDescription)
    }
    
    static var test: GraphQLRequest {
        GraphQLRequest(
            body: """
                {
                    "query": "query places { places (search: { term: \\"Brno\" }) { ... on PlaceConnection { edges { node { id } } } } }"
                }
                """,
            debugDescription: "test-request"
        )
    }
    
    static func places(searchTerm: String) -> GraphQLRequest {
        GraphQLRequest(
            body: """
                {
                    "query": "query places { \
                            places( \
                                search: { \
                                    term: \\"\(searchTerm)\\" \
                                }, \
                                filter: { \
                                    onlyTypes: [AIRPORT, CITY], \
                                    groupByCity: true \
                                }, \
                                options: { \
                                    sortBy: RANK \
                                }, \
                                first: 20 \
                            ) { \
                                ... on PlaceConnection { \
                                    edges { \
                                        node { \
                                            id \
                                            legacyId \
                                            name \
                                            gps { \
                                                lat \
                                                lng \
                                            } \
                                        } \
                                    } \
                                } \
                            } \
                        }"
                }
                """,
            debugDescription: "places-request"
        )
    }
    
    static func flights(
        from fromIDs: String,
        to toIDs: String,
        adults adultPassengers: Int,
        childrens childrenPassengers: Int,
        startDate: String,
        endDate: String
    ) -> GraphQLRequest {
        GraphQLRequest(
            body: """
                {
                    "query": "fragment stopDetails on Stop { \
                        utcTime \
                        localTime \
                        station { \
                            id \
                            name \
                            code \
                            type \
                            city { \
                                id \
                                legacyId \
                                name \
                                country { \
                                    id \
                                    name \
                                } \
                            } \
                        } \
                    } \
                    \
                    query onewayItineraries { \
                        onewayItineraries( \
                            filter: { \
                                allowChangeInboundSource: false, \
                                allowChangeInboundDestination: false, \
                                allowDifferentStationConnection: true, \
                                allowOvernightStopover: true, \
                                contentProviders: [KIWI], \
                                limit: 10, \
                                showNoCheckedBags: true, \
                                transportTypes: [FLIGHT] \
                            }, \
                            options: { \
                                currency: \\"EUR\\", \
                                partner: \\"skypicker\\", \
                                sortBy: QUALITY, \
                                sortOrder: ASCENDING, \
                                sortVersion: 4, \
                                storeSearch: true \
                            }, search: { \
                                cabinClass: { \
                                    applyMixedClasses: true, \
                                    cabinClass: ECONOMY \
                                }, \
                                itinerary: { \
                                    source: { \
                                        ids: [\(fromIDs)] \
                                    }, \
                                    destination: { \
                                        ids: [\(toIDs)] \
                                    }, \
                                    outboundDepartureDate: { \
                                        start: \(startDate), \
                                        end: \(endDate) \
                                    } \
                                }, \
                                passengers: { \
                                    adults: \(adultPassengers), \
                                    children: \(childrenPassengers) \
                                } \
                            } \
                        ) { \
                            ... on Itineraries { \
                                itineraries { \
                                    ... on ItineraryOneWay { \
                                        id \
                                        duration \
                                        cabinClasses \
                                        bookingOptions { \
                                            edges { \
                                                node { \
                                                    bookingUrl \
                                                    price { \
                                                        amount \
                                                        formattedValue \
                                                    } \
                                                } \
                                            } \
                                        } \
                                        sector { \
                                            id \
                                            duration \
                                            sectorSegments { \
                                                segment { \
                                                    id \
                                                    duration \
                                                    type \
                                                    code \
                                                    source { \
                                                        ...stopDetails \
                                                    } \
                                                    destination { \
                                                        ...stopDetails \
                                                    } \
                                                    carrier { \
                                                        id \
                                                        name \
                                                        code \
                                                    } \
                                                    operatingCarrier { \
                                                        id \
                                                        name \
                                                        code \
                                                    } \
                                                } \
                                                layover { \
                                                    duration \
                                                    isBaggageRecheck \
                                                    transferDuration \
                                                    transferType \
                                                } \
                                                guarantee \
                                            } \
                                        } \
                                    } \
                                } \
                            } \
                        } \
                    }"
                }
                """,
            debugDescription: "flights-request"
        )
    }
}
