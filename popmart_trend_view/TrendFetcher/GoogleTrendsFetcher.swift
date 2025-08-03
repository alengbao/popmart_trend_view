import Foundation

class GoogleTrendsFetcher: TrendFetcher {
    let source = "谷歌趋势"
    var mocker: TrendMocker
    
    init() {
        self.mocker = TrendMocker(source: source,
                                  data: [40, 47, 51, 56, 61, 62, 67, 62, 57, 55, 53, 52, 50, 48, 46, 44, 42, 40, 38, 56, 60, 77, 79, 80],
              index: 7)
    }
    
    func fetch() async -> [TrendData] {
        if isMock {
            return mocker.Mock()
        }
        return []
    }
}

