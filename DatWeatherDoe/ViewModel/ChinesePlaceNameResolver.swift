import CoreLocation
import Foundation
import MapKit

// 按原始坐标解析中文地名，解析失败时保留天气服务的地点名称
final class ChinesePlaceNameResolver {
    // 根据完整经纬度查找地图地名
    private let lookup: (CLLocationCoordinate2D) async -> String?;
    // 由仅本机使用的构建配置提供的地名对应关系
    private let localOverride: (source: String, display: String)?;
    // 仅缓存最近一次成功查到地名的原始坐标
    private var cachedLocation: (coordinates: CLLocationCoordinate2D, name: String)?;

    /** 使用系统地图查询地名，也允许测试传入固定结果 */
    init(
        localOverride: (source: String, display: String)? = ChinesePlaceNameResolver.readLocalOverride(),
        lookup: @escaping (CLLocationCoordinate2D) async -> String? = ChinesePlaceNameResolver.lookupInMaps,
    ) {
        self.localOverride = localOverride;
        self.lookup = lookup;
    }

    /** 从本机应用包读取可选的地名对应关系 */
    private static func readLocalOverride() -> (source: String, display: String)? {
        // 空配置时直接使用系统地图
        let source = Bundle.main.object(forInfoDictionaryKey: "LocalWeatherPlaceSource") as? String ?? "";
        let display = Bundle.main.object(forInfoDictionaryKey: "LocalWeatherPlaceName") as? String ?? "";
        guard !source.isEmpty, !display.isEmpty else { return nil; }
        return (source, display);
    }

    /** 返回已知地名或同一坐标的缓存结果 */
    func availableName(sourceName: String, coordinates: CLLocationCoordinate2D) -> String? {
        // 本机配置仅替换匹配的来源名称，避免覆盖其他位置
        if let localOverride,
           sourceName.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(localOverride.source)
               == .orderedSame {
            return localOverride.display;
        }
        if Self.containsHanCharacters(sourceName) {
            return sourceName;
        }
        guard let cachedLocation,
              cachedLocation.coordinates.latitude == coordinates.latitude,
              cachedLocation.coordinates.longitude == coordinates.longitude else {
            return nil;
        }
        return cachedLocation.name;
    }

    /** 使用简体中文地名，地图不可用时回退到原名 */
    func resolve(sourceName: String, coordinates: CLLocationCoordinate2D) async -> String {
        if let name = availableName(sourceName: sourceName, coordinates: coordinates) {
            return name;
        }
        guard let name = await lookup(coordinates), !Task.isCancelled else { return sourceName; }
        cachedLocation = (coordinates, name);
        return name;
    }

    /** 根据同一坐标请求中文地点名或详细地址 */
    private static func lookupInMaps(coordinates: CLLocationCoordinate2D) async -> String? {
        guard #available(macOS 26.0, *) else { return nil; }
        // 将原始坐标直接交给地图，避免转换成城市中心点
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude);
        guard let request = MKReverseGeocodingRequest(location: location) else { return nil; }
        request.preferredLocale = Locale(identifier: "zh-Hans-CN");

        // 地图服务失败时由调用方保留天气服务地名
        let items = try? await request.mapItems;
        return items?.lazy.compactMap { item in
            Self.detailedName(
                candidates: [item.name, item.address?.shortAddress],
                coarseNames: [
                    item.addressRepresentations?.cityName,
                    item.addressRepresentations?.cityWithContext,
                    item.addressRepresentations?.regionName,
                ],
            );
        }.first;
    }

    /** 从系统地图结果中排除非中文名称和只到城市一级的结果 */
    static func detailedName(candidates: [String?], coarseNames: [String?]) -> String? {
        // 地图有时在名称或地址两端添加空白
        let coarse = Set(coarseNames.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) });
        return candidates.lazy.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.first {
            Self.containsHanCharacters($0) && !coarse.contains($0)
        };
    }

    /** 检查地名是否包含汉字 */
    private static func containsHanCharacters(_ name: String) -> Bool {
        name.range(of: #"\p{Han}"#, options: .regularExpression) != nil;
    }
}
