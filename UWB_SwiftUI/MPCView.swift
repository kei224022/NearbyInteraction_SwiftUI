//
//  MPCView.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import SwiftUI

struct MPCView: View {
    @EnvironmentObject var multipeer: MultipeerConnectivity
    @State var selectTag = 1
    
    var body: some View {
            VStack(alignment: .leading) {
                
                Image(systemName: "iphone.gen3.radiowaves.left.and.right", variableValue: 1)
                Text("Connected Devices:")
                    .bold()
                Text(String(describing:
                      multipeer.connectedPeers.map(\.displayName)))
                Divider()
            }
            .padding()
    }
}

struct MPCView_Previews: PreviewProvider {
    static var previews: some View {
        MPCView()
            .environmentObject(MultipeerConnectivity())
    }
}
