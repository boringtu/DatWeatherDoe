//
//  ConfigureViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 3/20/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine
import Foundation

final class ConfigureViewModel: ObservableObject {
    @Published var measurementUnit: MeasurementUnit {
        didSet { configManager.measurementUnit = measurementUnit.rawValue }
    }

    @Published var weatherSource: WeatherSource

    @Published var weatherSourceText: String

    @Published var refreshInterval: RefreshInterval {
        didSet { configManager.refreshInterval = refreshInterval.rawValue }
    }

    @Published var isShowingWeatherIcon: Bool {
        didSet { configManager.isShowingWeatherIcon = isShowingWeatherIcon }
    }

    @Published var isShowingHumidity: Bool {
        didSet { configManager.isShowingHumidity = isShowingHumidity }
    }

    @Published var isShowingUVIndex: Bool {
        didSet { configManager.isShowingUVIndex = isShowingUVIndex }
    }

    @Published var isRoundingOffData: Bool {
        didSet { configManager.isRoundingOffData = isRoundingOffData }
    }

    @Published var isUnitLetterOff: Bool {
        didSet { configManager.isUnitLetterOff = isUnitLetterOff }
    }

    @Published var isUnitSymbolOff: Bool {
        didSet { configManager.isUnitSymbolOff = isUnitSymbolOff }
    }

    @Published var valueSeparator = "|" {
        didSet { configManager.valueSeparator = valueSeparator }
    }

    @Published var isWeatherConditionAsTextEnabled: Bool {
        didSet { configManager.isWeatherConditionAsTextEnabled = isWeatherConditionAsTextEnabled }
    }

    @Published var weatherConditionPosition: WeatherConditionPosition {
        didSet { configManager.weatherConditionPosition = weatherConditionPosition.rawValue }
    }

    // 记录天气描述旁的逗号开关
    @Published var usesWeatherConditionComma: Bool {
        didSet { configManager.usesWeatherConditionComma = usesWeatherConditionComma; }
    }

    // 点击完成或关闭面板时保存的个人密钥
    @Published var personalWeatherAPIKey: String;

    private let configManager: ConfigManagerType

    init(configManager: ConfigManagerType) {
        self.configManager = configManager

        measurementUnit = configManager.parsedMeasurementUnit
        
        weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location
        weatherSourceText = configManager.weatherSourceText
        // 载入已保存的显示设置
        personalWeatherAPIKey = configManager.personalWeatherAPIKey;
        usesWeatherConditionComma = configManager.usesWeatherConditionComma;

        switch configManager.refreshInterval {
        case 300: refreshInterval = .fiveMinutes
        case 900: refreshInterval = .fifteenMinutes
        case 1800: refreshInterval = .thirtyMinutes
        case 3600: refreshInterval = .sixtyMinutes
        default: refreshInterval = .fifteenMinutes
        }

        isShowingWeatherIcon = configManager.isShowingWeatherIcon
        isShowingHumidity = configManager.isShowingHumidity
        isShowingUVIndex = configManager.isShowingUVIndex
        isRoundingOffData = configManager.isRoundingOffData
        isUnitLetterOff = configManager.isUnitLetterOff
        isUnitSymbolOff = configManager.isUnitSymbolOff
        isWeatherConditionAsTextEnabled = configManager.isWeatherConditionAsTextEnabled
        weatherConditionPosition = WeatherConditionPosition(rawValue: configManager.weatherConditionPosition)
            ?? .beforeTemperature
    }

    /** 保存取数设置与显示偏好 */
    func saveConfig() {
        configManager.personalWeatherAPIKey = personalWeatherAPIKey;
        configManager.updateWeatherSource(weatherSource, sourceText: weatherSourceText)
        weatherSourceText = configManager.weatherSourceText

        configManager.setConfigOptions(
            .init(
                refreshInterval: refreshInterval,
                isShowingHumidity: isShowingHumidity,
                isShowingUVIndex: isShowingUVIndex,
                isRoundingOffData: isRoundingOffData,
                isUnitLetterOff: isUnitLetterOff,
                isUnitSymbolOff: isUnitSymbolOff,
                valueSeparator: valueSeparator,
                isWeatherConditionAsTextEnabled: isWeatherConditionAsTextEnabled
            )
        )
    }
}
