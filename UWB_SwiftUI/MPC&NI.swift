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

// MARK: - MultipeerConnectivityManager class to handle Multipeer and Nearby Interaction communication
// マルチピア接続およびNearby Interactionを管理するクラス
class MultipeerConnectivityManager: NSObject, ObservableObject {
    
    // Service type identifier for multipeer connectivity communication
    // マルチピア接続通信のためのサービスタイプ識別子
    private let serviceType = "YourServiceName"
    
    // Unique identifier for the current device in the peer-to-peer network
    // ピアツーピアネットワークにおける現在のデバイスの一意識別子
    private var myPeerID = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
    
    // Service to advertise the device in the peer-to-peer network
    // デバイスをピアツーピアネットワーク内でアドバタイズするためのサービス
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    // Service to browse and find other devices in the peer-to-peer network
    // ピアツーピアネットワーク内で他のデバイスを検索するためのサービス
    private let serviceBrowser: MCNearbyServiceBrowser
    
    // Session to manage peer-to-peer data communication
    // ピアツーピアデータ通信を管理するセッション
    private let session: MCSession
    
    // Logger for tracking events and errors
    // イベントやエラーを記録するためのロガー
    private let log = Logger()
    
    // MARK: - NearbyInteraction properties
    // Nearby Interaction関連プロパティ
    var niSession: NISession?  // Session for Nearby Interaction
    // Nearby Interactionのセッション
    var myTokenData: Data?     // Discovery token data for sharing with peers
    // ピアと共有するためのディスカバリートークンデータ
    
    // List of currently connected peers
    // 現在接続されているピアのリスト
    @Published var connectedPeers: [MCPeerID] = []
    
    // Distance and direction to nearby objects using Nearby Interaction
    // Nearby Interactionを使用したオブジェクトとの距離と方向
    @Published var distance: Float = 0.0
    @Published var direction: simd_float3? = simd_float3(0, 0, 0)

    // MARK: - Initializer
    // 初期化処理
    override init() {
        // Initialize the session, advertiser, and browser
        // セッション、アドバタイザ、ブラウザの初期化
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        
        // Set delegate to handle peer events
        // ピアイベントを処理するためにデリゲートを設定
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        // Start advertising and browsing for peers
        // ピアのアドバタイズと検索を開始
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        
        // Initialize Nearby Interaction session if not already initialized
        // Nearby Interactionセッションを初期化（未初期化の場合）
        if niSession == nil {
            setupNearbyInteraction()
        }
    }
    
    // Deinitialize by stopping the advertiser and browser, and invalidating the session
    // デストラクタでアドバタイザとブラウザを停止し、セッションを無効化
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        
        // Invalidate Nearby Interaction session to free resources
        // Nearby Interactionセッションを無効化してリソースを解放
        niSession?.invalidate()
    }
    
    // MARK: - Setup Nearby Interaction
    // Nearby Interactionのセットアップ
    func setupNearbyInteraction() {
        // Check for iOS version and Nearby Interaction support
        // iOSバージョンとNearby Interactionのサポートを確認
        if #available(iOS 16.0, *) {
            // In iOS 16 and later, NISession is always supported
            // iOS 16以降ではNISessionは常にサポートされています
            log.info("Nearby Interaction is supported on this device.")
        } else {
            // For iOS versions before 16.0, check the deprecated isSupported property
            // iOS 16より前のバージョンでは、isSupportedプロパティを使ってチェック
            guard NISession.isSupported else {
                log.error("This device doesn't support Nearby Interaction.")
                // このデバイスはNearby Interactionをサポートしていません
                return
            }
        }
        
        // Create a new Nearby Interaction session and set its delegate
        // 新しいNearby Interactionセッションを作成し、デリゲートを設定
        niSession = NISession()
        niSession?.delegate = self
        
        // Create and store discovery token data to share with peers
        // ピアと共有するためのディスカバリートークンデータを作成し保存
        do {
            guard let token = niSession?.discoveryToken else {
                log.error("Failed to retrieve discovery token.")
                // ディスカバリートークンの取得に失敗しました
                return
            }
            myTokenData = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        } catch {
            log.error("Failed to archive discovery token: \(error.localizedDescription)")
            // ディスカバリートークンのアーカイブに失敗しました
        }
    }
    
    // Custom helper function to get the debug description for MCSessionState
    // MCSessionStateのデバッグ用説明を取得するためのヘルパー関数
    func debugDescription(for state: MCSessionState) -> String {
        switch state {
        case .notConnected:
            return "Not Connected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        @unknown default:
            return "Unknown state: \(state.rawValue)"
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    
    // Error handler for failing to start advertising
    // アドバタイズの開始に失敗した場合のエラーハンドラ
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("Failed to start advertising peer: \(error.localizedDescription)")
        // ピアのアドバタイズ開始に失敗しました
    }

    // Handles incoming invitations from peers
    // ピアからの招待を処理
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically accept invitations and join the session
        // 招待を自動的に承諾してセッションに参加
        invitationHandler(true, session)
        log.info("Received invitation from peer: \(peerID.displayName)")
        // ピアからの招待を受け取りました
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    
    // Error handler for failing to start browsing
    // ピアの検索開始に失敗した場合のエラーハンドラ
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("Failed to start browsing for peers: \(error.localizedDescription)")
        // ピアの検索開始に失敗しました
    }

    // Handles finding a new peer in the network
    // ネットワーク内で新しいピアを見つけた場合の処理
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log.info("Found peer: \(peerID.displayName)")
        // ピアを見つけました
        
        // Invite the found peer to the session
        // 見つけたピアをセッションに招待
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        
        // Add peer to the connected list if not already there
        // 接続されたリストにピアを追加
        if !connectedPeers.contains(peerID) {
            connectedPeers.append(peerID)
        }
    }

    // Handles losing connection to a peer
    // ピアとの接続が切れた場合の処理
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("Lost peer: \(peerID.displayName)")
        // ピアとの接続が切れました
        if let index = connectedPeers.firstIndex(of: peerID) {
            connectedPeers.remove(at: index)
        }
    }
}

// MARK: - MCSessionDelegate
extension MultipeerConnectivityManager: MCSessionDelegate {
    
    // Handle changes in peer connection state
    // ピア接続状態の変更を処理
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //log.info("Peer \(peerID.displayName) changed state to \(state.debugDescription)")
        log.info("Peer \(peerID.displayName) changed state to \(self.debugDescription(for: state))")
        // ピアの状態が変更されました
        
        switch state {
        case .connected:
            // Send token data to connected peers when established
            // 接続が確立されたらトークンデータを送信
            if let tokenData = myTokenData {
                do {
                    try session.send(tokenData, toPeers: session.connectedPeers, with: .reliable)
                } catch {
                    log.error("Failed to send token data: \(error.localizedDescription)")
                    // トークンデータの送信に失敗しました
                }
            } else {
                log.error("No token data available to send.")
                // 送信可能なトークンデータがありません
            }
        case .connecting:
            log.info("Connecting to peer: \(peerID.displayName)")
            // ピアに接続中です
        case .notConnected:
            log.info("Disconnected from peer: \(peerID.displayName)")
            // ピアとの接続が切れました
            DispatchQueue.main.async {
                self.connectedPeers = session.connectedPeers
            }
        @unknown default:
            log.error("Unknown session state: \(state.rawValue)")
            // 未知のセッション状態です
        }
    }

    // Handles receiving data from a peer
    // ピアからデータを受信した際の処理
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Attempt to decode discovery token from received data
        // 受信データからディスカバリートークンをデコード
        do {
            guard let peerToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
                log.error("Failed to decode token data.")
                // トークンデータのデコードに失敗しました
                return
            }
            // Configure the Nearby Interaction session with the peer's token
            // ピアのトークンでNearby Interactionセッションを設定
            let peerConfig = NINearbyPeerConfiguration(peerToken: peerToken)
            niSession?.run(peerConfig)
        } catch {
            log.error("Failed to unarchive data: \(error.localizedDescription)")
            // データのアーカイブ解除に失敗しました
        }
    }

    // These methods are not supported in this implementation
    // この実装では未対応のメソッド
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
        // ストリーム受信はサポートされていません
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
        // リソース受信はサポートされていません
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
        // リソース受信はサポートされていません
    }
}

// MARK: - NISessionDelegate
// Nearby Interactionのセッションデリゲート
extension MultipeerConnectivityManager: NISessionDelegate {
    
    // Handle updates to nearby objects in Nearby Interaction
    // Nearby Interactionで近くのオブジェクトの更新を処理
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first else {
            // オブジェクトが存在しない場合、処理を終了
            return
        }
        
        DispatchQueue.main.async {
            // Update the distance and direction based on the nearby object
            // 近接オブジェクトに基づいて距離と方向を更新
            if let distance = nearbyObject.distance {
                self.distance = distance
            }
            if let direction = nearbyObject.direction {
                self.direction = direction
            }
        }
    }
}
