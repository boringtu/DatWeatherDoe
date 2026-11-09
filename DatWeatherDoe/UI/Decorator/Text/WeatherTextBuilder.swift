//
//  WeatherTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import OSLog

protocol WeatherTextBuilderType {
    func build() -> String
}

final class WeatherTextBuilder: WeatherTextBuilderType {
    struct Options {
        let isWeatherConditionAsTextEnabled: Bool
        let conditionPosition: WeatherConditionPosition
        let valueSeparator: String
        let temperatureOptions: TemperatureTextBuilder.Options
        let isShowingHumidity: Bool
        let isShowingUVIndex: Bool
        // 为 false 时用单个空格分隔天气描述与数值
        let usesWeatherConditionComma: Bool
    }

    private let response: WeatherAPIResponse
    private let options: Options
    private let logger: Logger

    init(
        response: WeatherAPIResponse,
        options: Options,
        logger: Logger
    ) {
        self.response = response
        self.options = options
        self.logger = logger
    }

    func build() -> String {
        let finalString = appendTemperatureAsText() |>
            appendUVIndex |>
            appendHumidityText |>
            buildWeatherConditionAsText
        return finalString
    }

    private func appendTemperatureAsText() -> String {
        TemperatureTextBuilder(
            response: response,
            options: options.temperatureOptions,
            temperatureCreator: TemperatureWithDegreesCreator()
        ).build() ?? ""
    }

    private func appendUVIndex(initial: String) -> String {
        guard options.isShowingUVIndex else { return initial }

        return UVIndexTextBuilder(
            initial: initial,
            separator: options.valueSeparator
        ).build(from: response)
    }

    private func appendHumidityText(initial: String) -> String {
        guard options.isShowingHumidity else { return initial }

        return HumidityTextBuilder(
            initial: initial,
            valueSeparator: options.valueSeparator,
            humidity: response.humidity,
            logger: logger
        ).build()
    }

    /** 将天气描述按设定位置和标点拼接到菜单栏数值 */
    private func buildWeatherConditionAsText(initial: String) -> String {
        guard options.isWeatherConditionAsTextEnabled else { return initial }

        let weatherCondition = WeatherConditionBuilder(response: response).build()
        let weatherConditionText = WeatherConditionTextMapper().map(weatherCondition)

        let combinedString = options.conditionPosition == .beforeTemperature ?
            [weatherConditionText, initial] :
            [initial, weatherConditionText.lowercased()]

        // 缺少任意一段文字时不添加分隔符
        let separator = options.usesWeatherConditionComma ? ", " : " ";
        return combinedString.filter { !$0.isEmpty }.joined(separator: separator);
    }
}

precedencegroup ForwardPipe {
    associativity: left
}

infix operator |>: ForwardPipe

private func |> <T, U>(value: T, function: (T) -> U) -> U {
    function(value)
}
