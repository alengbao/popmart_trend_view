import Foundation

class GoogleTrendsFetcher: TrendFetcher {
    let source = "谷歌趋势"
    var lastFetchDate: Date?
    var mocker: TrendMocker
    let isMock = false  // 改为 false 以使用真实数据
    
    // 配置参数
    private let apiKey = "f5937bc9b0b54f9ba85cdd4eabae899383530a4a98a62b45059c3283b0924e26"
    private let keyword = "popmart"  // 搜索关键词
    private let timezone = "-480"  // 时区偏移
    private let dateRange = "today+1-m"  // 时间范围：最近1个月
    
    init() {
        self.mocker = TrendMocker(source: source,
                                  data: [40, 47, 51, 56, 61, 62, 67, 62, 57, 55, 53, 52, 50, 48, 46, 44, 42, 40, 38, 56, 60, 77, 79, 80],
                                  index: 7)
    }
    
    func fetch() async -> [TrendData] {
        // 如果使用模拟数据，直接返回
        if isMock {
            print("🎭 使用模拟数据")
            return mocker.Mock()
        }
        
        // 获取谷歌趋势数据
        let trendData = await fetchGoogleTrends()
        
        // 过滤数据：只保留上次获取日期之后的数据
        let filteredData: [TrendData]
        if let lastDate = lastFetchDate {
            filteredData = trendData.filter { $0.date > lastDate }
        } else {
            filteredData = trendData
        }
        
        // 更新最后获取日期：使用原始数据的最新日期
        if let latestDate = trendData.last?.date {
            lastFetchDate = latestDate
        }
        
        return filteredData
    }
    
    // 获取谷歌趋势数据
    private func fetchGoogleTrends() async -> [TrendData] {
        print("🚀 开始谷歌趋势数据获取...")
        
        // 构建 API URL
        let urlString = "https://serpapi.com/search.json?engine=google_trends&q=\(keyword)&tz=\(timezone)&date=\(dateRange)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("❌ 无效的 URL")
            return []
        }
        
        do {
            print("📡 请求 URL: \(urlString)")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP 状态码: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ 请求失败，状态码: \(httpResponse.statusCode)")
                    return []
                }
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📄 响应数据长度: \(responseString.count) 字符")
            
            // 解析 JSON 响应
            return parseGoogleTrendsResponse(data: data)
            
        } catch {
            print("❌ 网络请求失败: \(error)")
            return []
        }
    }
    
    // 解析谷歌趋势响应
    private func parseGoogleTrendsResponse(data: Data) -> [TrendData] {
        print("🔍 解析谷歌趋势响应...")
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let json = json else {
                print("❌ 无法解析为 JSON")
                return []
            }
            
            // 检查响应状态
            if let searchMetadata = json["search_metadata"] as? [String: Any],
               let status = searchMetadata["status"] as? String {
                if status != "Success" {
                    print("❌ API 返回错误状态: \(status)")
                    return []
                }
            }
            
            // 解析趋势数据
            guard let interestOverTime = json["interest_over_time"] as? [String: Any],
                  let timelineData = interestOverTime["timeline_data"] as? [[String: Any]] else {
                print("❌ 无法获取趋势数据")
                return []
            }
            
            print("✅ 获取到 \(timelineData.count) 个数据点")
            
            var trendData: [TrendData] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            
            for timelineItem in timelineData {
                guard let dateString = timelineItem["date"] as? String,
                      let values = timelineItem["values"] as? [[String: Any]],
                      let firstValue = values.first,
                      let extractedValue = firstValue["extracted_value"] as? Int else {
                    continue
                }
                
                // 解析日期
                guard let date = dateFormatter.date(from: dateString) else {
                    print("❌ 无法解析日期: \(dateString)")
                    continue
                }
                
                let trendDataPoint = TrendData(
                    date: date,
                    value: Double(extractedValue),
                    source: source
                )
                trendData.append(trendDataPoint)
                
                // 打印前几个数据点用于调试
                if trendData.count <= 5 {
                    print("📊 \(dateString): \(extractedValue)")
                }
            }
            
            print("✅ 成功解析 \(trendData.count) 个趋势数据点")
            return trendData
            
        } catch {
            print("❌ JSON 解析错误: \(error)")
            return []
        }
    }
    
    // 测试获取功能
    static func testFetch() async {
        let fetcher = GoogleTrendsFetcher()
        let result = await fetcher.fetch()
        print("🧪 谷歌趋势测试结果: 获取到 \(result.count) 个数据点")
        
        for (index, data) in result.prefix(3).enumerated() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            print("数据点 \(index + 1): \(dateFormatter.string(from: data.date)) - \(data.value)")
        }
    }
}

// MARK: - 测试扩展
extension GoogleTrendsFetcher {
    // 测试解析功能
    static func testParseResponse() {
        let testJSON = """
        {
          "search_metadata": {
            "status": "Success"
          },
          "interest_over_time": {
            "timeline_data": [
              {
                "date": "Jul 4, 2025",
                "timestamp": "1751587200",
                "values": [
                  {
                    "query": "popmart",
                    "value": "100",
                    "extracted_value": 100
                  }
                ]
              },
              {
                "date": "Jul 5, 2025",
                "timestamp": "1751673600",
                "values": [
                  {
                    "query": "popmart",
                    "value": "86",
                    "extracted_value": 86
                  }
                ]
              }
            ]
          }
        }
        """
        
        let fetcher = GoogleTrendsFetcher()
        let data = testJSON.data(using: .utf8)!
        let result = fetcher.parseGoogleTrendsResponse(data: data)
        
        print("🧪 解析测试结果: \(result.count) 个数据点")
        for data in result {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            print("📊 \(dateFormatter.string(from: data.date)): \(data.value)")
        }
    }
}

