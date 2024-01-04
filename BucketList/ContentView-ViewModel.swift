//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Macmaurice Osuji on 5/26/23.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        @Published private(set)var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        @Published var authenticationFailed = false
        @Published var noAuthenticationFound = false
        @Published var alertMessage = ""
        
        let savePath = FileManager.documentsDirectory.appendingPathExtension("SavePlace")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newlocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newlocation)
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "You need to authenticate yourself"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {success,authenticationError in
                    if success {
                        Task { @MainActor in
                            self.isUnlocked = true
                        }
                    } else {
                        Task { @MainActor in
                            self.authenticationFailed = true
                            self.alertMessage = "Sorry, we are unable to verify it's you"
                        }
                    }
                }
            } else {
                noAuthenticationFound = true
                alertMessage = "Sorry your device can't carry out authentications at this moment"
                
            }
        }
        
    }
}

