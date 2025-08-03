import Foundation

class BaiduTrendsFetcher: TrendFetcher {
    let source = "百度指数"
    var mocker: TrendMocker
    
    init() {
        self.mocker = TrendMocker(source: source,
                                  data: [55, 57, 61, 65, 64, 62, 60, 58, 56, 54, 52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22],
                                  index: 7)
    }
    
    func fetch() async -> [TrendData] {
        if isMock {
            return mocker.Mock()
        }
        return []
    }
}

