//
//  TravelJournalApp.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//

import SwiftUI
import SwiftData

@main
struct TravelJournalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Color("#355D48"))
        }
    }
}

//For orangish color - #EBBB86
//for green color - #355D48

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}


