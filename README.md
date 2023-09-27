#  Kiwi assignment by Slava Nagornyak

## Purpose of this document

The purpose of this document is to describe what is done, how it is done and what I did not have enoght time for.

## Project info

Swift: 5.9 <br />
Xcode: 15.0 <br />
UI: SwiftUI with UIKit for stuff which is not present in SwiftUI <br />
Archtecture: MVVM <br />
Network: GraphQL client built on top of Swift Concurrency 

## What is done?

I started my implementation from GraphQL. Since I do not use any 3rd-party framework/library for this task, I did not use Apollo or simillar framework for GraphQL. I created my own GraphQL client with only 2 requests: for places and for flights. Places are working, I tested it inside `SearchView`, but since `SearchView` is deprecated already, I decided to change search flow, so right now this request is not reachable. Flights request is not tested, I did not have enough time to start implement business logic for Flights UI.

After that I defined all the models I will use throughout the app. They are just representation of GraphQL response I get from Places and Flights requests.

Then I switched to UI. If I had design beforehand I would start with that, but in this case model and domain were the entry point. The UI is where I spent most of my time.

### Search

Search UI is devided between `SearchConfigurationView` and `SearchView`. At first `SearchView` was presented when a user taps on 'From' or 'To' buttons on a `SearchConfigurationView`, but then I decided to change it. I decided to go very wide and implemented here a custom button style for 'From' and 'To' buttons, then I implemented a completely custom `Stepper` where I had to introduce a little of UIKit/SwiftUI mixture. After that I decided to finalize this UI with a new custom `MultiSelectionPicker`.

I could use the standard components for this, but I'm very passionate about UI and wanted to demonstrate my SwiftUI skills.

### Flights

With Flights UI I went completely crazy. I used provided mockup in the assignment as a inspiration and created a complex screen from it. Flights UI consist of pages which represents flights for selected Departures and Destinations. This is a paged scroll view with custom transion effects. It's layered, every layer behaves differently.

Lower layer is Images preview of Departure and Arrival places for current flight. Middle layer is a flight detail card with the most valuable information about the flight. Upper layer is names of places.

Flight details card has a button which should lead to a prived URL to buy a ticker (not implemented). It also has a button for more information about a flight where a user could see a complete flgiht details (not implemented).

## What is not done?

As it mentioned before, the actual flow is not there. I have a half-way done infrastructure based on `ViewModels` and `@Observable`s. This is the simpliest way to deal with SwiftUI and not polute the UI with business logic. If I could use any 3rd-party stuff, I would go with TCA for pretty much everything.

ImageDownloaded is also not there, it was scheduled as a last thing I would implement.

Tests are not implemented for the same reasons.  
