import Foundation
import SwiftUI
import UserNotifications


// 消息管理器
class MessageManager: ObservableObject {
    @Published var inAppMessages: [InAppMessage] = []
    @Published var isNotificationAuthorized = false
    @Published var notificationStatus = "未检查"
    
    init() {
        checkNotificationPermission()
    }
    
    // 添加站内信
    func addInAppMessage(_ content: String) {
        let message = InAppMessage(content: content)
        DispatchQueue.main.async {
            self.inAppMessages.insert(message, at: 0)
            // 限制站内信数量，最多保留20条
            if self.inAppMessages.count > 20 {
                self.inAppMessages = Array(self.inAppMessages.prefix(10))
            }
        }
    }
    
    // 发送站外通知
    func sendPushNotification(_ title: String, body: String) {
        print("=== 开始发送站外通知 ===")
        print("标题: \(title)")
        print("内容: \(body)")
        
        // 首先检查权限
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = "检查权限中..."
                print("当前权限状态: \(settings.authorizationStatus.rawValue)")
                
                switch settings.authorizationStatus {
                case .authorized:
                    print("权限已授权，准备发送通知")
                    self.createAndSendNotification(title: title, body: body)
                case .denied:
                    self.notificationStatus = "通知权限被拒绝"
                    print("❌ 通知权限被拒绝，无法发送站外通知")
                case .notDetermined:
                    self.notificationStatus = "通知权限未确定"
                    print("❌ 通知权限未确定，请先请求权限")
                case .provisional:
                    print("临时权限，准备发送通知")
                    self.createAndSendNotification(title: title, body: body)
                case .ephemeral:
                    print("临时权限，准备发送通知")
                    self.createAndSendNotification(title: title, body: body)
                @unknown default:
                    self.notificationStatus = "未知权限状态"
                    print("❌ 未知的通知权限状态")
                }
            }
        }
    }
    
    // 创建并发送通知
    private func createAndSendNotification(title: String, body: String) {
        print("创建通知内容...")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        // 添加自定义数据
        content.userInfo = ["source": "popmart_trend_view", "timestamp": Date().timeIntervalSince1970]
        
        // 使用立即触发的通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "notification_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        print("通知标识符: \(identifier)")
        print("通知内容: \(content.title) - \(content.body)")
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.notificationStatus = "发送失败: \(error.localizedDescription)"
                    print("❌ 发送站外通知失败: \(error)")
                    print("错误详情: \(error.localizedDescription)")
                } else {
                    self.notificationStatus = "发送成功"
                    print("✅ 站外通知发送成功")
                    print("请检查通知中心或下拉通知栏")
                    
                    // 检查是否有待处理的通知
                    self.checkPendingNotifications()
                }
            }
        }
    }
    
    // 检查待处理的通知
    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("待处理的通知数量: \(requests.count)")
            for request in requests {
                print("待处理通知: \(request.identifier)")
            }
        }
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            print("已发送的通知数量: \(notifications.count)")
            for notification in notifications {
                print("已发送通知: \(notification.request.identifier)")
            }
        }
    }
    
    // 请求通知权限
    func requestNotificationPermission() {
        notificationStatus = "请求权限中..."
        print("=== 请求通知权限 ===")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.isNotificationAuthorized = true
                    self.notificationStatus = "权限已授权"
                    print("✅ 通知权限已授权")
                } else {
                    self.isNotificationAuthorized = false
                    self.notificationStatus = "权限被拒绝"
                    print("❌ 通知权限被拒绝")
                }
                
                if let error = error {
                    self.notificationStatus = "权限请求失败: \(error.localizedDescription)"
                    print("❌ 通知权限请求失败: \(error)")
                }
            }
        }
    }
    
    // 检查通知权限
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.isNotificationAuthorized = true
                    self.notificationStatus = "已授权"
                case .denied:
                    self.isNotificationAuthorized = false
                    self.notificationStatus = "已拒绝"
                case .notDetermined:
                    self.isNotificationAuthorized = false
                    self.notificationStatus = "未确定"
                case .provisional:
                    self.isNotificationAuthorized = true
                    self.notificationStatus = "临时授权"
                case .ephemeral:
                    self.isNotificationAuthorized = true
                    self.notificationStatus = "临时授权"
                @unknown default:
                    self.isNotificationAuthorized = false
                    self.notificationStatus = "未知状态"
                }
            }
        }
    }
    
    // 清空站内信
    func clearInAppMessages() {
        DispatchQueue.main.async {
            self.inAppMessages.removeAll()
        }
    }
    
    // 测试通知功能
    func testNotification() {
        print("=== 开始测试通知功能 ===")
        print("当前权限状态: \(notificationStatus)")
        print("是否已授权: \(isNotificationAuthorized)")
        
        // 先检查权限
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("详细权限信息:")
            print("- 授权状态: \(settings.authorizationStatus.rawValue)")
            print("- 横幅设置: \(settings.alertSetting.rawValue)")
            print("- 声音设置: \(settings.soundSetting.rawValue)")
            print("- 角标设置: \(settings.badgeSetting.rawValue)")
            
            DispatchQueue.main.async {
                self.sendPushNotification("测试通知", body: "这是一个测试通知，时间: \(Date())")
            }
        }
    }
    
    // 清除所有通知
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("已清除所有通知")
    }
} 