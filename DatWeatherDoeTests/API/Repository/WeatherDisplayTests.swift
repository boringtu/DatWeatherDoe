@testable import DatWeatherDoe
import CoreLocation
import OSLog
import Testing

// 验证菜单栏文字与地点名称的显示设置
@MainActor
struct WeatherDisplayTests {
    /** 验证已知拼音地名能保留到农林场粒度 */
    @Test func preservesKnownLocalPlace() async {
        // 此处无需依赖地图的联网结果
        let resolver = ChinesePlaceNameResolver(
            localOverride: (source: "sampleforest", display: "示例林场"),
            lookup: { _ in nil; },
        );
        let coordinates = CLLocationCoordinate2D(latitude: 30, longitude: 120);
        let name = await resolver.resolve(sourceName: " SampleForest ", coordinates: coordinates);
        #expect(name == "示例林场");
        let other = await resolver.resolve(sourceName: "otherplace", coordinates: coordinates);
        #expect(other == "otherplace");
    }

    /** 验证自动解析使用完整坐标且地图服务失败时保留原名 */
    @Test func usesExactCoordinatesAndFallsBack() async {
        // 模拟两个临近位置，防止把上一地点的名字沿用到新坐标
        let coordinates = CLLocationCoordinate2D(latitude: 26.123456, longitude: 119.56789);
        let nearby = CLLocationCoordinate2D(latitude: 26.123457, longitude: 119.56789);
        let resolver = ChinesePlaceNameResolver(localOverride: nil) { requested in
            requested.latitude == coordinates.latitude && requested.longitude == coordinates.longitude
                ? "某村林场" : nil;
        };
        let name = await resolver.resolve(sourceName: "localplace", coordinates: coordinates);
        #expect(name == "某村林场");
        let fallback = await resolver.resolve(sourceName: "nextplace", coordinates: nearby);
        #expect(fallback == "nextplace");
    }

    /** 验证地图只返回城市名时不会用它覆盖原地点 */
    @Test func rejectsCityOnlyResults() {
        // 当地图还有较详细的地址时优先选用该地址
        let coarseNames = ["示例市", "示例省", "中国"];
        #expect(ChinesePlaceNameResolver.detailedName(candidates: ["示例市"], coarseNames: coarseNames) == nil);
        #expect(
            ChinesePlaceNameResolver.detailedName(
                candidates: ["示例市", " 示例县某镇 "],
                coarseNames: coarseNames,
            ) == "示例县某镇"
        );
    }

    /** 验证逗号开关在天气文本位于温度前后时均生效 */
    @Test(arguments: [WeatherConditionPosition.beforeTemperature, .afterTemperature])
    func optionalComma(position: WeatherConditionPosition) {
        // 使用同一条天气记录验证默认和关闭逗号两种结果
        let withComma = weatherText(position: position, usesComma: true);
        let withoutComma = weatherText(position: position, usesComma: false);
        #expect(withComma.contains(", "));
        #expect(withoutComma == withComma.replacingOccurrences(of: ", ", with: " "));
    }

    /** 用固定摄氏度选项生成用于对照的天气文本 */
    private func weatherText(position: WeatherConditionPosition, usesComma: Bool) -> String {
        WeatherTextBuilder(
            response: response,
            options: .init(
                isWeatherConditionAsTextEnabled: true,
                conditionPosition: position,
                valueSeparator: "|",
                temperatureOptions: .init(
                    unit: .celsius,
                    isRoundingOff: true,
                    isUnitLetterOff: false,
                    isUnitSymbolOff: false,
                ),
                isShowingHumidity: true,
                isShowingUVIndex: false,
                usesWeatherConditionComma: usesComma,
            ),
            logger: Logger(),
        ).build();
    }
}
