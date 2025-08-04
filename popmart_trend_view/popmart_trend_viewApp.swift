//
//  popmart_trend_viewApp.swift
//  popmart_trend_view
//
//  Created by hong on 2025/7/31.
//

import SwiftUI

@main
struct popmart_trend_viewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // 配置App Transport Security
    private func configureAppTransportSecurity() {
        // 注意：在iOS中，ATS策略通常在Info.plist中配置
        // 这里只是打印配置信息
        print("🔒 ATS配置信息:")
        print("- 允许HTTP请求到index.baidu.com")
        print("- 如果仍有问题，请检查网络连接")
    }
}
