//
//  ContentView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

// MARK: - Main ContentView for displaying tabs
// 主要なタブ表示用のContentView
struct ContentView: View {
    // State variable to track the selected tab
    // 選択されたタブを追跡するためのステート変数
    @State var selectedTag = 1
    
    var body: some View {
        // TabView to switch between different views
        // 異なるビュー間を切り替えるためのTabView
        TabView(selection: $selectedTag) {
            MPCView()
                .tabItem {
                    Label("Device", systemImage: "iphone.radiowaves.left.and.right")
                    // デバイス関連のタブ
                }
                .tag(1)
                
            NIView()
                .tabItem {
                    Label("UWB", systemImage: "airtag.radiowaves.forward")
                    // UWB関連のタブ
                }
                .tag(2)
        }
    }
}

#Preview {
    // Preview with environment object set for testing
    // 環境オブジェクトを設定したプレビュー
    ContentView()
        .environmentObject(MultipeerConnectivityManager())
}
