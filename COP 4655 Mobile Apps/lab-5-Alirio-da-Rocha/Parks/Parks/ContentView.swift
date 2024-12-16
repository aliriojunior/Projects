//
//  ContentView.swift
//  Parks
//
//  Created by Alirio Da Rocha on 10/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var parks: [Park] = []
    
    var body: some View {
        Text("Alirio da Rocha Z23335350")
        
        NavigationStack{
            ScrollView {
                LazyVStack {
                    ForEach(parks) { park in
                        NavigationLink(value: park) {
                            ParkRow(park: park)
                        }
                    }
                }
            }
            .navigationDestination(for: Park.self) { park in
                ParkDetailView(park: park)
            }
            .navigationTitle("National Parks")
        }
     .padding()
     .onAppear(perform: {
         Task {
             await fetchParks()
         }
     })
 }

 private func fetchParks() async {
     // URL for the API endpoint
     // 👋👋👋 Make sure to replace {YOUR_API_KEY} in the URL with your actual NPS API Key
     let url = URL(string: "https://developer.nps.gov/api/v1/parks?stateCode=ca&api_key=L4W3QHSXc7YKKYvftHQNiakm8aPZU1m0YLCuRfjF")!
     do {

         // Perform an asynchronous data request
         let (data, _) = try await URLSession.shared.data(from: url)

         // Decode json data into ParksResponse type
         let parksResponse = try JSONDecoder().decode(ParksResponse.self, from: data)

         // Get the array of parks from the response
         let parks = parksResponse.data

         // Print the full name of each park in the array
         for park in parks {
             print(park.fullName)
         }

         // Set the parks state property
         self.parks = parks

     } catch {
         print(error.localizedDescription)
     }
 }
}
