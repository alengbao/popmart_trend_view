import Foundation

let isMock = true

// Fetcher协议
protocol TrendFetcher {
    func fetch() async -> [TrendData] // 每次fetch只获取新增的数据
}

// 管理器
class TrendFetcherManager: ObservableObject {
    @Published var trendResults: [TrendData] = []
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
        let allResults = await withTaskGroup(of: [TrendData].self) { group in
            for fetcher in fetchers {
                group.addTask {
                    await fetcher.fetch()
                }
            }
            
            var results: [TrendData] = []
            for await result in group {
                results.append(contentsOf: result)
            }
            return results
        }
        
        await MainActor.run {
            self.trendResults = self.trendResults + allResults
        }
    }
    
    func startPeriodicFetch(interval: TimeInterval = 10) {
        Task {
            while true {
                await runAllFetchers()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
}



class TrendMocker {
    let source: String
    // 模拟数据 要求输入一个数组和index 数组中包含日期和值，日期为Date类型，值为Double类型，index为Int类型，index为数组中的索引，第一次返回返回Index之前的所有数据，之后每次返回Index+1的值，如果Index大于数组长度，则返回随机值
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

