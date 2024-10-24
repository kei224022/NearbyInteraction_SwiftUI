//
//  NIView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

// MARK: - View to display Nearby Interaction data
// Nearby Interactionのデータを表示するためのビュー
struct NIView: View {
    // MultipeerConnectivityManager instance from the environment
    // 環境からのMultipeerConnectivityManagerインスタンス
    @EnvironmentObject var multipeer: MultipeerConnectivityManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Display title and subtitle for UWB data
            // UWBデータのタイトルとサブタイトルを表示
            VStack(alignment: .trailing, spacing: 5) {
                Text("Ultra-Wideband")
                    .font(.title)
                    .fontWeight(.thin)
                
                Text("Distance, Coordinate")
                    .italic()
                    .fontWeight(.thin)
            }
            Spacer()
            
            // Display the distance and direction information
            // 距離と方向情報を表示
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    Text("Distance:")
                    // Show the distance value from the multipeer object
                    // Multipeerオブジェクトから取得した距離を表示
                    Text("\(multipeer.distance, specifier: "%.2f") meters")
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Direction:")
                    // Show the X, Y, Z components of direction from the multipeer object
                    // Multipeerオブジェクトから取得した方向のX, Y, Z成分を表示
                    Text("X: \(multipeer.direction?.x ?? 0.0, specifier: "%.2f")")
                    Text("Y: \(multipeer.direction?.y ?? 0.0, specifier: "%.2f")")
                    Text("Z: \(multipeer.direction?.z ?? 0.0, specifier: "%.2f")")
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    // Preview with environment object set for testing
    // 環境オブジェクトを設定したプレビュー
    NIView()
        .environmentObject(MultipeerConnectivityManager())
}
