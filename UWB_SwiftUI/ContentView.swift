//
//  ContentView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTag = 1
    
    // MARK: - TagView
    var body: some View {
        TabView(selection: $selectedTag){
            MPCView()
                .tabItem{
                    Label("Device", systemImage: "iphone.radiowaves.left.and.right")
                }
                .tag(1)
                
            NIView()
                .tabItem{
                    Label("UWB", systemImage: "airtag.radiowaves.forward")
                }
                .tag(2)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MultipeerConnectivity())
    }
}
