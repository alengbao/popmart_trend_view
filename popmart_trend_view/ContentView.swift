//
//  ContentView.swift
//  popmart_trend_view
//
//  Created by hong on 2025/7/31.
//

import SwiftUI
import Charts
import UserNotifications

struct ContentView: View {
    @StateObject private var manager = TrendFetcherManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("趋势分析")
                .font(.title)
                .fontWeight(.bold)
            
            // 更新按钮
            HStack {
                Button("更新数据") {
                    Task {
                        await updateData()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                // 测试按钮
                // Button("测试消息") {
                //     testMessages()
                // }
                // .buttonStyle(.bordered)
                
                // 添加一个清楚站内信的按钮
                if !manager.messageManager.inAppMessages.isEmpty {
                    Button("清除站内信") {
                        manager.messageManager.clearInAppMessages()
                        manager.update = !manager.update
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // 站内信列表
            if !manager.messageManager.inAppMessages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("站内信")
                            .font(.headline)
                        Spacer()
                        Text("\(manager.messageManager.inAppMessages.count) 条")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(manager.messageManager.inAppMessages) { message in
                                MessageRow(message: message)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 150)
                }
            }
            
            // 图表
            if !manager.trendResults.isEmpty {
                chartView(trendData: manager.trendResults.values.flatMap { $0 })
            } else {
                Text("暂无数据")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            manager.startPeriodicFetch(interval: 300)
            manager.messageManager.requestNotificationPermission()
        }
    }
    
    // 图表视图
    private func chartView(trendData: [TrendData]) -> some View {
        VStack(spacing: 10) {
            // 数据统计信息
            ForEach(manager.trendResults.keys.sorted(), id: \.self) { source in
                if let data = manager.trendResults[source], !data.isEmpty {
                    let sortedData = data.sorted { $0.date < $1.date }
                    let recentData = Array(sortedData.suffix(7))
                    
                    if recentData.count >= 7 {
                        let values = recentData.map { $0.value }
                        let sevenDayAverage = values.reduce(0, +) / Double(values.count)
                        let latestValue = values.last ?? 0
                        
                        HStack {
                            Text("\(source)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .center, spacing: 2) {
                                    Text("7日均值")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f", sevenDayAverage))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                VStack(alignment: .center, spacing: 2) {
                                    Text("最新数据")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f", latestValue))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // 图表
            Chart(trendData) {
                LineMark(
                    x: .value("时间", $0.date),
                    y: .value("数值", $0.value)
                )
                .foregroundStyle(by:.value("source", $0.source))
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 300)
        }
    }
    

    
    // 更新数据
    private func updateData() async {
        await manager.runAllFetchers()
    }
    
    // 测试消息
    private func testMessages() {
        manager.messageManager.addInAppMessage("强烈买入信号！最新数据(85.2)超过7日均值(45.1)88.9%", type: .strongBuy)
        manager.messageManager.addInAppMessage("普通买入信号！最新数据(65.3)超过7日均值(45.1)44.8%", type: .normalBuy)
        manager.messageManager.addInAppMessage("普通卖出信号！最新数据(25.1)低于7日均值(45.1)44.3%", type: .normalSell)
        manager.messageManager.addInAppMessage("强烈卖出信号！最新数据(8.2)低于7日均值(45.1)81.8%", type: .strongSell)
        manager.messageManager.addInAppMessage("数据更新完成", type: .neutral)
        manager.update = !manager.update
    }
}

// 站内信行视图
struct MessageRow: View {
    let message: InAppMessage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.type.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(message.type.color)
                        .cornerRadius(4)
                    
                    Spacer()
                }
                
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(message.type.backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(message.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
