//
//  MPC&NI.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2023/09/15.
//

import Foundation
import MultipeerConnectivity
import NearbyInteraction
import os

class MultipeerConnectivity: NSObject, ObservableObject{
    private let serviceType = "YourServiceName"
    private var myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let log = Logger()
    //MARK: - NearbyInteraction
    var niSession: NISession?
    var myTokenData: Data?
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var Distance: Float = 0.0
    @Published var Direction: simd_float3? = simd_float3(0, 0, 0)
    
    override init(){
        session = MCSession(peer: myPeerID, securityIdentity:nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil,serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        
        if niSession != nil {
            return
        }
        setupNearbyInteraction()
    }
    
    deinit{
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    // MARK: - Initial setting
    func setupNearbyInteraction() {
        // Check if Nearby Interaction is supported.
        guard NISession.isSupported else {
            print("This device doesn't support Nearby Interaction.")
            return
        }
        // Set the NISession.
        niSession = NISession()
        niSession?.delegate = self
        
        // Create a token and change Data type.
        guard let token = niSession?.discoveryToken else {
            return
        }
        myTokenData = try! NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
    }
}

extension MultipeerConnectivity: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertiserPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        log.info("didReceiveInvitationFromPeer \(peerID)")
    }
}

extension MultipeerConnectivity: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBrowser didiNotStartBrowsingForPeer: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        log.info("ServiceBrowser found peer: \(peerID)")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
            
            if !connectedPeers.contains(peerID) {
                connectedPeers.append(peerID)
            }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        guard let index = connectedPeers.firstIndex(of: peerID) else { return }
        connectedPeers.remove(at: index)
    }
}

extension MultipeerConnectivity: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            log.info("peer \(peerID) didChangeState: \(state.debugDescription)")
        switch state {
        case .connected:
            
            do {
                try session.send(myTokenData!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print(error.localizedDescription)
            }
        case .connecting:
            print("接続中")
        case .notConnected:
            print("切断されました")
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
        default:
            print("MCSession state is \(state)")
        }
        }

        func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            
            guard let peerDiscoverToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
                print("Failed to decode data.")
                return }

            let config = NINearbyPeerConfiguration(peerToken: peerDiscoverToken)
            niSession?.run(config)
        }

        public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
            log.error("Receiving streams is not supported")
        }

        public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
            log.error("Receiving resources is not supported")
        }

        public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
            log.error("Receiving resources is not supported")
        }
}

extension MCSessionState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .notConnected:
            return "notConnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        @unknown default:
            return "\(rawValue)"
        }
    }
}

// MARK: - NISessionDelegate
extension MultipeerConnectivity: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let accessory = nearbyObjects.first else { return }

        DispatchQueue.main.async {
            if let distance = accessory.distance {
                self.Distance = distance
            }
            
            if let direction = accessory.direction {
                self.Direction = direction
            }
        }
    }
}
