import Foundation

class BaiduTrendsFetcher: TrendFetcher {
    let source = "百度指数"
    var lastFetchDate: Date?
    var mocker: TrendMocker
    let isMock = false
    let zoom = 1000

    // 配置参数 - 直接在代码中设置
    private let keyword = "泡泡玛特"  // 搜索关键词
    private let cookieFile = "baidu_cookie.txt"  // Cookie文件
    
    init() {
        self.mocker = TrendMocker(source: source,
                                  data: [55, 57, 61, 65, 64, 62, 60, 58, 56, 54, 52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22],
                                  index: 7)
    }
    
    func fetch() async -> [TrendData] {
        // 如果使用模拟数据，直接返回
        if isMock {
            print("🎭 使用模拟数据")
            return mocker.Mock()
        }
        
        // 按顺序执行爬取流程
        let trendData = await crawlBaiduIndex()
        
        // 过滤数据：只保留上次获取日期之后的数据
        let filteredData: [TrendData]
        if let lastDate = lastFetchDate {
            filteredData = trendData.filter { $0.date > lastDate }
        } else {
            filteredData = trendData
        }
        
        // 更新最后获取日期：使用原始数据的最新日期，而不是过滤后的数据
        if let latestDate = trendData.last?.date {
            lastFetchDate = latestDate
        }
        
        return filteredData
    }
    
    // 主爬取流程
    private func crawlBaiduIndex() async -> [TrendData] {
        print("🚀 开始百度指数爬取流程...")
        
        // 1. 获取Cookie
        guard let cookie = getCookie() else {
            print("❌ Cookie获取失败")
            return []
        }
        print("✅ Cookie获取成功，长度: \(cookie.count)")
        
        // 2. 获取数据
        guard let responseData = await fetchData(cookie: cookie) else {
            print("❌ 数据获取失败")
            return []
        }
        print("✅ 数据获取成功，长度: \(responseData.count)")
        
        // 3. 解析JSON
        guard let json = parseJSON(data: responseData) else {
            print("❌ JSON解析失败")
            return []
        }
        print("✅ JSON解析成功")
        
        // 4. 获取uniqid并获取字典
        guard let uniqid = getUniqid(from: json) else {
            print("❌ 无法获取uniqid")
            return []
        }
        print("✅ 获取到uniqid: \(uniqid)")
        
        guard let ptbk = await getDecryptionDictionary(uniqid: uniqid, cookie: cookie) else {
            print("❌ 无法获取解密字典")
            return []
        }
        print("✅ 获取到解密字典，长度: \(ptbk.count)")
        
        // 5. 解析密文
        let trendData = decryptData(ptbk: ptbk, json: json)
        print("✅ 密文解析完成，共解析 \(trendData.count) 个数据点")
        
        return trendData
    }
    
    // 1. 获取Cookie
    private func getCookie() -> String? {
        print("🔍 获取Cookie...")
        
        // 获取当前文件所在目录
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectory = currentFileURL.deletingLastPathComponent()
        let cookieFileURL = currentDirectory.appendingPathComponent(cookieFile)
        
        print("📁 Cookie文件路径: \(cookieFileURL.path)")
        
        do {
            let cookie = try String(contentsOf: cookieFileURL, encoding: .utf8)
            if !cookie.isEmpty {
                return cookie
            } else {
                print("❌ Cookie文件为空")
                return nil
            }
        } catch {
            print("❌ 无法读取Cookie文件: \(error)")
            print("💡 请确保Cookie文件存在于: \(cookieFileURL.path)")
            return nil
        }
    }
    
    // 2. 获取数据
    private func fetchData(cookie: String) async -> Data? {
        print("📡 获取百度指数数据...")
        
        // 构建请求参数
        let words = [[["name": keyword, "wordType": 1]]]
        let wordsJson = try? JSONSerialization.data(withJSONObject: words)
        let wordsString = String(data: wordsJson ?? Data(), encoding: .utf8) ?? "[]"
        
        let urlString = "https://index.baidu.com/api/SearchApi/index?area=0&word=\(wordsString)&days=30"
        
        guard let url = URL(string: urlString) else {
            print("❌ 无效的URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        // 设置请求头
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("1698156005330_1698238860769_ZPrC2QTaXriysBT+5sgXcnbTX3/lW65av4zgu9uR1usPy82bArEg4m9deebXm7/O5g6QWhRxEd9/r/hqHad2WnVFVVWybHPFg3YZUUCKMTIYFeSUIn23C6HdTT1SI8mxsG5mhO4X9nnD6NGI8hF8L5/G+a5cxq+b21PADOpt/XB5eu/pWxNdwfa12krVNuYI1E8uHQ7TFIYjCzLX9MoJzPU6prjkgJtbi3v0X7WGKDJw9hwnd5Op4muW0vWKMuo7pbxUNfEW8wPRmSQjIgW0z5p7GjNpsg98rc3FtHpuhG5JFU0kZ6tHgU8+j6ekZW7+JljdyHUMwEoBOh131bGl+oIHR8vw8Ijtg8UXr0xZqcZbMEagEBzWiiKkEAfibCui59hltAgW5LG8IOtBDqp8RJkbK+IL5GcFkNaXaZfNMpI=", forHTTPHeaderField: "Cipher-Text")
        request.setValue("https://index.baidu.com/v2/main/index.html", forHTTPHeaderField: "Referer")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        
        do {
            print("📡 请求URL: \(urlString)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP状态码: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ 请求失败，状态码: \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📄 响应数据长度: \(responseString.count) 字符")
            print("📄 响应内容预览: \(responseString)")
            
            return data
            
        } catch {
            print("❌ 网络请求失败: \(error)")
            return nil
        }
    }
    
    // 3. 解析JSON
    private func parseJSON(data: Data) -> [String: Any]? {
        print("🔍 解析JSON...")
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let json = json {
                // 检查状态
                if let status = json["status"] as? Int, status != 0 {
                    print("❌ API返回错误状态: \(status)")
                    if let message = json["message"] as? String {
                        print("错误信息: \(message)")
                    }
                    return nil
                }
                
                return json
            } else {
                print("❌ 无法解析为JSON")
                return nil
            }
        } catch {
            print("❌ JSON解析错误: \(error)")
            return nil
        }
    }
    
    // 4. 获取uniqid
    private func getUniqid(from json: [String: Any]) -> String? {
        print("🔍 获取uniqid...")
        
        guard let data = json["data"] as? [String: Any],
              let uniqid = data["uniqid"] as? String else {
            print("❌ 无法获取uniqid")
            return nil
        }
        
        return uniqid
    }
    
    // 4. 获取解密字典
    private func getDecryptionDictionary(uniqid: String, cookie: String) async -> String? {
        print("🔑 获取解密字典...")
        
        let urlString = "https://index.baidu.com/Interface/ptbk?uniqid=\(uniqid)"
        
        guard let url = URL(string: urlString) else {
            print("❌ 无效的解密URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        // 设置请求头
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("1698156005330_1698238860769_ZPrC2QTaXriysBT+5sgXcnbTX3/lW65av4zgu9uR1usPy82bArEg4m9deebXm7/O5g6QWhRxEd9/r/hqHad2WnVFVVWybHPFg3YZUUCKMTIYFeSUIn23C6HdTT1SI8mxsG5mhO4X9nnD6NGI8hF8L5/G+a5cxq+b21PADOpt/XB5eu/pWxNdwfa12krVNuYI1E8uHQ7TFIYjCzLX9MoJzPU6prjkgJtbi3v0X7WGKDJw9hwnd5Op4muW0vWKMuo7pbxUNfEW8wPRmSQjIgW0z5p7GjNpsg98rc3FtHpuhG5JFU0kZ6tHgU8+j6ekZW7+JljdyHUMwEoBOh131bGl+oIHR8vw8Ijtg8UXr0xZqcZbMEagEBzWiiKkEAfibCui59hltAgW5LG8IOtBDqp8RJkbK+IL5GcFkNaXaZfNMpI=", forHTTPHeaderField: "Cipher-Text")
        request.setValue("https://index.baidu.com/v2/main/index.html", forHTTPHeaderField: "Referer")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        
        do {
            print("🔑 解密字典URL: \(urlString)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 解密请求状态码: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ 解密请求失败，状态码: \(httpResponse.statusCode)")
                    return nil
                }
            }
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📄 响应数据长度: \(responseString.count) 字符")
            print("📄 响应内容预览: \(responseString)")
            
            // 解析解密响应
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let json = json,
                  let ptbk = json["data"] as? String else {
                print("❌ 无法获取解密字典")
                return nil
            }
            
            return ptbk
            
        } catch {
            print("❌ 获取解密字典失败: \(error)")
            return nil
        }
    }
    
    // 5. 解析密文
    private func decryptData(ptbk: String, json: [String: Any]) -> [TrendData] {
        print("🔓 解析密文...")
        
        // 获取加密的指数数据
        guard let data = json["data"] as? [String: Any],
              let userIndexes = data["userIndexes"] as? [[String: Any]] else {
            print("❌ 无法获取用户指数数据")
            return []
        }
        
        var trendData: [TrendData] = []
        
        for userIndex in userIndexes {
            // 获取关键词信息
            guard let wordArray = userIndex["word"] as? [[String: Any]],
                  let firstWord = wordArray.first,
                  let wordName = firstWord["name"] as? String else {
                continue
            }
            
            print("📊 解析关键词: \(wordName)")
            
            // 处理all数据（总体数据）
            if let allData = userIndex["all"] as? [String: Any],
               let encryptedData = allData["data"] as? String,
               let startDate = allData["startDate"] as? String,
               let endDate = allData["endDate"] as? String {
                
                print("📈 解析all数据: \(startDate) 到 \(endDate)")
                let decryptedValues = decrypt(ptbk: ptbk, indexData: encryptedData)
                let dataPoints = parseDecryptedData(decryptedValues: decryptedValues, startDate: startDate, endDate: endDate, source: "\(source)-\(wordName)-all")
                trendData.append(contentsOf: dataPoints)
            }
        }
        
        return trendData
    }
    
    // 解析解密后的数据
    private func parseDecryptedData(decryptedValues: String, startDate: String, endDate: String, source: String) -> [TrendData] {
        var trendData: [TrendData] = []
        
        // 解析日期范围
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let start = dateFormatter.date(from: startDate),
              let end = dateFormatter.date(from: endDate) else {
            print("❌ 无法解析日期范围")
            return []
        }
        
        // 计算天数差
        let calendar = Calendar.current
        _ = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        
        // 分割解密后的数值
        let values = decryptedValues.components(separatedBy: ",")
        
        for (index, valueStr) in values.enumerated() {
            guard let value = Double(valueStr.trimmingCharacters(in: .whitespaces)) else {
                continue
            }
            
            // 计算对应日期
            let date = calendar.date(byAdding: .day, value: index, to: start) ?? start
            
            let trendDataPoint = TrendData(
                date: date,
                value: value,
                source: source
            )
            trendData.append(trendDataPoint)
            
            if index < 5 { // 只打印前5个数据点
                print("📊 \(dateFormatter.string(from: date)): \(value)")
            }
        }
        
        return trendData
    }
    
    // 解密函数（对应Python的decrypt函数）
    private func decrypt(ptbk: String, indexData: String) -> String {
        let n = ptbk.count / 2
        let ptbkArray = Array(ptbk)
        
        // 创建映射字典
        var mapping: [Character: Character] = [:]
        for i in 0..<n {
            mapping[ptbkArray[i]] = ptbkArray[i + n]
        }
        
        // 解密
        let result = indexData.map { char in
            return mapping[char] ?? char
        }
        
        return String(result)
    }
    
    // 保存Cookie到代码同目录下
    static func saveCookie(_ cookie: String) {
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectory = currentFileURL.deletingLastPathComponent()
        let cookieFileURL = currentDirectory.appendingPathComponent("baidu_cookie.txt")
        
        do {
            try cookie.write(to: cookieFileURL, atomically: true, encoding: .utf8)
            print("✅ Cookie已保存到: \(cookieFileURL.path)")
        } catch {
            print("❌ 保存Cookie失败: \(error)")
        }
    }
    
    // 测试爬取功能
    static func testFetch() async {
        let fetcher = BaiduTrendsFetcher()
        let result = await fetcher.fetch()
        print("🧪 测试结果: 获取到 \(result.count) 个数据点")
        
        for (index, data) in result.prefix(3).enumerated() {
            print("数据点 \(index + 1): \(data.date) - \(data.value)")
        }
    }
}

