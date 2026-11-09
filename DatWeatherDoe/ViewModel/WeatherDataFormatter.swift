//
//  WeatherDataFormatter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/24/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherDataFormatterType {
    /** 组合地点名称和天气描述 */
    func getLocation(for data: WeatherData, displayName: String) -> String;
    func getWeatherText(for data: WeatherData) -> String
    func getSunriseSunset(for data: WeatherData) -> String
    func getWindSpeedItem(for data: WeatherData) -> String
    func getUVIndexAndAirQuality(for data: WeatherData) -> String
}

final class WeatherDataFormatter: WeatherDataFormatterType {
    let configManager: ConfigManagerType

    init(configManager: ConfigManagerType) {
        self.configManager = configManager
    }

    /** 生成详情面板上的地点和天气描述 */
    func getLocation(for data: WeatherData, displayName: String) -> String {
        return [
            displayName,
            WeatherConditionTextMapper().map(data.weatherCondition)
        ]
        .joined(separator: " - ");
    }

    func getWeatherText(for data: WeatherData) -> String {
        TemperatureForecastTextBuilder(
            temperatureData: data.response.temperatureData,
            forecastTemperatureData: data.response.forecastDayData.temperatureData,
            options: .init(
                unit: configManager.parsedMeasurementUnit.temperatureUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff
            )
        ).build()
    }

    func getSunriseSunset(for data: WeatherData) -> String {
        SunriseAndSunsetTextBuilder(
            sunset: data.response.forecastDayData.astro.sunset,
            sunrise: data.response.forecastDayData.astro.sunrise
        ).build()
    }

    func getWindSpeedItem(for data: WeatherData) -> String {
        if configManager.measurementUnit == MeasurementUnit.all.rawValue {
            WindSpeedFormatter()
                .getFormattedWindSpeedStringForAllUnits(
                    windData: data.response.windData,
                    isRoundingOff: configManager.isRoundingOffData
                )
        } else {
            WindSpeedFormatter()
                .getFormattedWindSpeedString(
                    unit: configManager.parsedMeasurementUnit,
                    windData: data.response.windData
                )
        }
    }

    func getUVIndexAndAirQuality(for data: WeatherData) -> String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentUVIndex = data.response.getHourlyUVIndex(hour: currentHour)
        let uvIndex = "UV Index: \(currentUVIndex)"

        let airQualityIndex = "AQI: \(data.response.airQualityIndex.description)"

        return [uvIndex, airQualityIndex].joined(separator: " | ")
    }
}
