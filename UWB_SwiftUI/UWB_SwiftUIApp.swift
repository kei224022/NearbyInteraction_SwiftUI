//
//  UWB_SwiftUIApp.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

@main
struct UWB_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MultipeerConnectivity())
        }
    }
}
