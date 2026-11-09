//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation
import OSLog

final class WeatherViewModel: WeatherViewModelType, ObservableObject {
    private let locationFetcher: SystemLocationFetcherType
    private var weatherFactory: WeatherRepositoryFactoryType
    private let configManager: ConfigManagerType
    private var dataFormatter: WeatherDataFormatterType!
    private let logger: Logger
    private var reachability: NetworkReachability!

    // 仅用于解析详情面板的地名
    private let placeNameResolver = ChinesePlaceNameResolver();

    private let forecaster = WeatherForecaster()
    private var weatherTimerTask: Task<Void, Never>?

    @Published var menuOptionData: MenuOptionData?
    @Published var weatherResult: Result<WeatherData, Error>?

    init(
        locationFetcher: SystemLocationFetcher,
        weatherFactory: WeatherRepositoryFactoryType,
        configManager: ConfigManagerType,
        logger: Logger
    ) {
        self.locationFetcher = locationFetcher
        self.configManager = configManager
        self.weatherFactory = weatherFactory
        self.logger = logger

        setupReachability()
    }

    deinit {
        weatherTimerTask?.cancel()
    }

    func setup(with formatter: WeatherDataFormatter) {
        dataFormatter = formatter
    }

    func getUpdatedWeatherAfterRefresh() {
        weatherTimerTask?.cancel()
        weatherTimerTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                await self.getWeatherWithSelectedSource()
                try? await Task.sleep(for: .seconds(configManager.refreshInterval))
            }
        }
    }

    func seeForecastForCurrentCity() {
        forecaster.seeForecastForCity()
    }

    private func setupReachability() {
        reachability = NetworkReachability(
            logger: logger,
            onBecomingReachable: { [weak self] in
                self?.getUpdatedWeatherAfterRefresh()
            }
        )
    }

    /** 先显示天气，再用相同坐标补充中文地名 */
    private func getWeatherWithSelectedSource() async {
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location

        do {
            // 自动定位与手动经纬度都返回原始天气查询坐标
            let result = switch weatherSource {
            case .location:
                try await getWeatherAfterUpdatingLocation()
            case .latLong:
                try await getWeatherViaLocationCoordinates()
            };
            guard !Task.isCancelled else { return; }
            let sourceName = result.data.response.locationName;
            let availableName = placeNameResolver.availableName(sourceName: sourceName, coordinates: result.coordinates);
            updateWeatherData(result.data, displayName: availableName ?? sourceName);
            guard availableName == nil else { return; }

            // 地图请求较慢时天气仍能立即显示
            let displayName = await placeNameResolver.resolve(sourceName: sourceName, coordinates: result.coordinates);
            guard !Task.isCancelled, displayName != sourceName else { return; }
            updateWeatherData(result.data, displayName: displayName);
        } catch {
            guard !Task.isCancelled else { return; }
            updateWeatherData(error);
        }
    }

    /** 按系统定位查询天气并保留坐标 */
    private func getWeatherAfterUpdatingLocation() async throws -> (data: WeatherData, coordinates: CLLocationCoordinate2D) {
        let locationFetcher = locationFetcher
        let location = try await locationFetcher.getLocation()

        return try await getWeather(
            repository: weatherFactory.create(location: location),
            unit: configManager.parsedMeasurementUnit
        )
    }

    /** 按用户填写的经纬度查询天气并保留坐标 */
    private func getWeatherViaLocationCoordinates() async throws -> (data: WeatherData, coordinates: CLLocationCoordinate2D) {
        let latLong = configManager.weatherSourceText
        guard !latLong.isEmpty else {
            throw WeatherError.latLongIncorrect
        }

        return try await getWeather(
            repository: weatherFactory.create(latLong: latLong),
            unit: configManager.parsedMeasurementUnit
        )
    }

    private func buildWeatherDataOptions(for unit: MeasurementUnit) -> WeatherDataBuilder.Options {
        .init(
            unit: unit,
            showWeatherIcon: configManager.isShowingWeatherIcon,
            textOptions: buildWeatherTextOptions(for: unit)
        )
    }

    /** 为菜单栏格式化器组装当前显示设置 */
    private func buildWeatherTextOptions(for unit: MeasurementUnit) -> WeatherTextBuilder.Options {
        let conditionPosition = WeatherConditionPosition(rawValue: configManager.weatherConditionPosition)
            ?? .beforeTemperature
        return .init(
            isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
            conditionPosition: conditionPosition,
            valueSeparator: configManager.valueSeparator,
            temperatureOptions: .init(
                unit: unit.temperatureUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff
            ),
            isShowingHumidity: configManager.isShowingHumidity,
            isShowingUVIndex: configManager.isShowingUVIndex,
            // 单独控制天气描述的标点
            usesWeatherConditionComma: configManager.usesWeatherConditionComma,
        );
    }

    /** 构建天气显示数据并将同一坐标交给地名查询 */
    private func getWeather(
        repository: WeatherRepositoryType,
        unit: MeasurementUnit
    ) async throws -> (data: WeatherData, coordinates: CLLocationCoordinate2D) {
        do {
            // 坐标直接来自发出天气请求的对象
            let observation = try await repository.getWeather();
            let weatherData = WeatherDataBuilder(
                response: observation.response,
                options: buildWeatherDataOptions(for: unit),
                logger: logger
            ).build();
            return (weatherData, observation.coordinates);
        } catch {
            throw WeatherError.networkError
        }
    }

    /** 使用当前解析结果更新菜单详情与菜单栏 */
    private func updateWeatherData(_ data: WeatherData, displayName: String) {
        menuOptionData = MenuOptionData(
            locationText: dataFormatter.getLocation(for: data, displayName: displayName),
            weatherText: dataFormatter.getWeatherText(for: data),
            sunriseSunsetText: dataFormatter.getSunriseSunset(for: data),
            tempHumidityWindText: dataFormatter.getWindSpeedItem(for: data),
            uvIndexAndAirQualityText: dataFormatter.getUVIndexAndAirQuality(for: data)
        )
        weatherResult = .success(data)
    }

    private func updateWeatherData(_ error: Error) {
        menuOptionData = nil
        weatherResult = .failure(error)
    }
}
