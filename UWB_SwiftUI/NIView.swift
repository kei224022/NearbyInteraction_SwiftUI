//
//  NIView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

struct NIView: View {
    @EnvironmentObject var multipeer: MultipeerConnectivity
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .trailing, spacing: 5) {
                Text("Ultra-Wideband")
                    .font(.title)
                    .fontWeight(.thin)
                Text("Distance,Coordinate")
                    .italic()
                    .fontWeight(.thin)
            }
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    Text("Distance:")
                    Text("\(multipeer.Distance)")
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Direction:")
                    Text("X: \(multipeer.Direction?.x ?? 0.0)")
                    Text("Y: \(multipeer.Direction?.y ?? 0.0)")
                    Text("Z: \(multipeer.Direction?.z ?? 0.0)")
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding()
    }
}


struct NIView_Previews: PreviewProvider {
    static var previews: some View {
        NIView()
            .environmentObject(MultipeerConnectivity())
    }
}
