//
//  ConfigureOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/3/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureOptionsView: View {
    @ObservedObject var viewModel: ConfigureViewModel

    var body: some View {
        Grid(verticalSpacing: 16) {
            HStack {
                Text(LocalizedStringKey("Unit"))
                Spacer()
                Picker("", selection: $viewModel.measurementUnit) {
                    Text(LocalizedStringKey("Metric")).tag(MeasurementUnit.metric)
                    Text(LocalizedStringKey("Imperial")).tag(MeasurementUnit.imperial)
                    Text(LocalizedStringKey("All")).tag(MeasurementUnit.all)
                }
                .frame(width: 120)
            }

            ConfigureWeatherOptionsView(viewModel: viewModel)

            // 默认将用户输入的密钥遮蔽显示
            HStack {
                Text("WeatherAPI Key");
                Spacer();
                SecureField("WeatherAPI Key", text: $viewModel.personalWeatherAPIKey)
                    .labelsHidden()
                    .frame(width: 150);
            }

            HStack {
                Text(LocalizedStringKey("Refresh Interval"))
                Spacer()
                Picker("", selection: $viewModel.refreshInterval) {
                    Text(LocalizedStringKey("5 min")).tag(RefreshInterval.fiveMinutes)
                    Text(LocalizedStringKey("15 min")).tag(RefreshInterval.fifteenMinutes)
                    Text(LocalizedStringKey("30 min")).tag(RefreshInterval.thirtyMinutes)
                    Text(LocalizedStringKey("60 min")).tag(RefreshInterval.sixtyMinutes)
                }
                .frame(width: 120)
            }

            HStack {
                Text(LocalizedStringKey("Show Weather Icon"))
                Spacer()
                Toggle(isOn: $viewModel.isShowingWeatherIcon) {}
            }

            HStack {
                Text(LocalizedStringKey("Show Humidity"))
                Spacer()
                Toggle(isOn: $viewModel.isShowingHumidity) {}
            }

            HStack {
                Text(LocalizedStringKey("Show UV Index"))
                Spacer()
                Toggle(isOn: $viewModel.isShowingUVIndex) {}
            }

            HStack {
                Text(LocalizedStringKey("Round-off Data"))
                Spacer()
                Toggle(isOn: $viewModel.isRoundingOffData) {}
            }

            ConfigureUnitOptionsView(viewModel: viewModel)

            ConfigureValueSeparatorOptionsView(viewModel: viewModel)

            HStack {
                Text(LocalizedStringKey("Weather Condition Text"))
                Spacer()
                Toggle(isOn: $viewModel.isWeatherConditionAsTextEnabled) {}
            }

            HStack {
                Text(LocalizedStringKey("Weather Condition Position"))
                Spacer()
                Picker("", selection: $viewModel.weatherConditionPosition) {
                    Text(LocalizedStringKey("Before Temperature"))
                        .tag(WeatherConditionPosition.beforeTemperature)
                    Text(LocalizedStringKey("After Temperature"))
                        .tag(WeatherConditionPosition.afterTemperature)
                }
                .frame(maxWidth: 120)
            }
            .disabled(!viewModel.isWeatherConditionAsTextEnabled)

            // 只控制天气描述和数值之间的标点
            HStack {
                Text(LocalizedStringKey("Show comma next to weather text"));
                Spacer();
                Toggle(isOn: $viewModel.usesWeatherConditionComma) {};
            }
            .disabled(!viewModel.isWeatherConditionAsTextEnabled);
        }
        .padding()
    }
}

#Preview {
    ConfigureOptionsView(
        viewModel: .init(configManager: ConfigManager())
    )
    .frame(width: 380)
}
