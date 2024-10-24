//
//  MPCView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

// MARK: - View to display Multipeer Connectivity information
// マルチピア接続情報を表示するためのビュー
struct MPCView: View {
    // MultipeerConnectivityManager instance from the environment
    // 環境からのMultipeerConnectivityManagerインスタンス
    @EnvironmentObject var multipeer: MultipeerConnectivityManager
    @State var selectTag = 1
    
    var body: some View {
        // Vertical layout for displaying connected devices
        // 接続されたデバイスを表示するための縦方向レイアウト
        VStack(alignment: .leading) {
            Image(systemName: "iphone.gen3.radiowaves.left.and.right", variableValue: 1)
            
            Text("Connected Devices:")
                .bold()
            // Display the list of connected peers' display names
            // 接続されたピアの表示名をリスト表示
            Text(String(describing: multipeer.connectedPeers.map(\.displayName)))
            
            Divider() // Separator line
            // 仕切り線
        }
        .padding()
    }
}

#Preview {
    // Preview with environment object for testing
    // 環境オブジェクトを設定したプレビュー
    MPCView()
        .environmentObject(MultipeerConnectivityManager())
}
