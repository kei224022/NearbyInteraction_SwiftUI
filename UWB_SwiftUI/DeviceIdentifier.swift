//
//  DeviceIdentifier.swift
//  UWB_SwiftUI
//
//  Created by Keiichi Ishikawa on 2024/11/22.
//

import Foundation

class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    
    private let uuidKey = "keiUWBProject"
    private(set) var uuid: String
    
    private init() {
        if let existingUUID = UserDefaults.standard.string(forKey: uuidKey) {
            // 既存のUUIDがある場合はそれを使用
            self.uuid = existingUUID
        } else {
            // 新しいUUIDを生成して保存
            self.uuid = UUID().uuidString
            UserDefaults.standard.set(self.uuid, forKey: uuidKey)
        }
    }
    
    func getDeviceUUID() -> String {
        return uuid
    }
}
