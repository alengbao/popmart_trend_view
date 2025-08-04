import Foundation
import SwiftUI

// Fetcher协议
protocol TrendFetcher {
    func fetch() async -> [TrendData] // 每次fetch只获取新增的数据
    func getSource() -> String
}

// 管理器
class TrendFetcherManager: ObservableObject {
    @Published var update: Bool = false
    var messageManager: MessageManager = MessageManager()
    var trendResults: [String: [TrendData]] = [:]
    private var strategyCenter: StrategyCenter = StrategyCenter()
    private var fetchers: [TrendFetcher] = []
    
    init() {
        setupFetchers()
    }
    
    private func setupFetchers() {
        register(GoogleTrendsFetcher())
        register(BaiduTrendsFetcher())
    }
    
    func register(_ fetcher: TrendFetcher) {
        fetchers.append(fetcher)
    }
    
    func runAllFetchers() async {
        let allResults = await withTaskGroup(of: (String, [TrendData]).self) { group in
            for fetcher in fetchers {
                group.addTask {
                    let results = await fetcher.fetch()
                    return (fetcher.getSource(), results)
                }
            }
            
            var groupedResults: [String: [TrendData]] = [:]
            for await (source, results) in group {
                if !results.isEmpty {
                    groupedResults[source] = results
                }
            }
            return groupedResults
        }
        
        await MainActor.run {
            // 合并新数据到现有结果中
            var totalNewDataCount = 0
            
            for (source, newData) in allResults {
                if let existingData = self.trendResults[source] {
                    // 如果该 source 已存在数据，则合并
                    self.trendResults[source] = existingData + newData
                    totalNewDataCount += newData.count
                    print("📊 \(source): 添加了 \(newData.count) 条新数据")
                } else {
                    // 如果该 source 不存在，则创建新的
                    self.trendResults[source] = newData
                    totalNewDataCount += newData.count
                    print("📊 \(source): 新增 \(newData.count) 条数据")
                }
            }
            
            if totalNewDataCount > 0 {
                print("✅ 总共获取到 \(totalNewDataCount) 条新数据")
                let results = strategyCenter.runStrategies(data: self.trendResults)
                for result in results {
                    if result.isTriggered {
                        // 根据策略类型和等级确定消息类型
                        let messageType = determineMessageType(from: result)
                        messageManager.addInAppMessage(result.getMessage(), type: messageType)
                        messageManager.sendPushNotification(result.getTitle(), body: result.getMessage())
                        print("触发消息：msg=\(result.getMessage())")
                    }
                }
                update = !update
            }
        }
    }
    
    func startPeriodicFetch(interval: TimeInterval = 1000) {
        Task {
            while true {
                await runAllFetchers()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    // MARK: - 便利方法
    
    /// 获取指定来源的数据
    func getData(for source: String) -> [TrendData] {
        return trendResults[source] ?? []
    }
    
    /// 获取所有来源的数据
    func getAllData() -> [TrendData] {
        return trendResults.values.flatMap { $0 }
    }
    
    /// 获取所有来源的列表
    func getAllSources() -> [String] {
        return Array(trendResults.keys)
    }
    
    /// 获取指定来源的数据数量
    func getDataCount(for source: String) -> Int {
        return trendResults[source]?.count ?? 0
    }
    
    /// 获取总数据数量
    func getTotalDataCount() -> Int {
        return trendResults.values.reduce(0) { $0 + $1.count }
    }
    
    /// 清空指定来源的数据
    func clearData(for source: String) {
        trendResults[source] = []
    }
    
    /// 清空所有数据
    func clearAllData() {
        trendResults.removeAll()
    }
    
    /// 获取最新的数据点（按日期排序）
    func getLatestData(for source: String) -> TrendData? {
        return trendResults[source]?.max { $0.date < $1.date }
    }
    
    /// 获取所有来源的最新数据
    func getAllLatestData() -> [String: TrendData] {
        var latestData: [String: TrendData] = [:]
        for (source, data) in trendResults {
            if let latest = data.max(by: { $0.date < $1.date }) {
                latestData[source] = latest
            }
        }
        return latestData
    }
    
    /// 根据策略结果确定消息类型
    private func determineMessageType(from result: StrategyResult) -> MessageType {
        switch (result.strategyType, result.level) {
        case (.buy, .strong):
            return .strongBuy
        case (.buy, .normal):
            return .normalBuy
        case (.sell, .strong):
            return .strongSell
        case (.sell, .normal):
            return .normalSell
        }
    }
}

class TrendMocker {
    let source: String
    var index: Int = 0
    var data: [TrendData] = []
    var isFirst: Bool
    init(source: String, data: [Double], index: Int = 0) {
        self.source = source
        self.data = data.enumerated().map { idx, value in
            TrendData(date: Calendar.current.date(byAdding: .day, value: idx - index, to: Date()) ?? Date(), value: value, source: source)
        }
        self.index = index
        self.isFirst = true
    }
    
    func Mock() -> [TrendData] {
        if index < data.count {
            if isFirst && index > 0 {
                isFirst = false
                return Array(data[0..<index])
            }
            let result = data[index]
            index += 1
            return [result]
        }
        // 生成模拟数据
        let value = Double.random(in: 50...70)
        let trendData = TrendData(
            date: Calendar.current.date(byAdding: .day, value: 1, to: data.last?.date ?? Date()) ?? Date(),
            value: value,
            source: source
        )
        data.append(trendData)
        return [trendData]
    }
}
