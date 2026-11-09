//
//  WeatherRepositoryFactory.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/7/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation
import OSLog

protocol WeatherRepositoryFactoryType {
    func create(location: CLLocationCoordinate2D) -> WeatherRepositoryType
    func create(latLong: String) -> WeatherRepositoryType
}

final class WeatherRepositoryFactory: WeatherRepositoryFactoryType {
    struct Options {
        let appId: String
        let networkClient: NetworkClient
        let logger: Logger
    }

    // 每次创建取数对象时读取当前的密钥
    private let appId: () -> String;
    private let networkClient: NetworkClientType
    private let logger: Logger

    /** 接收密钥读取闭包，使设置保存后无需重启 */
    init(appId: @escaping () -> String, networkClient: NetworkClientType, logger: Logger) {
        self.appId = appId
        self.networkClient = networkClient
        self.logger = logger
    }

    func create(location: CLLocationCoordinate2D) -> WeatherRepositoryType {
        SystemLocationWeatherRepository(
            appId: appId(),
            location: location,
            networkClient: networkClient,
            logger: logger
        )
    }

    func create(latLong: String) -> WeatherRepositoryType {
        LocationCoordinatesWeatherRepository(
            appId: appId(),
            latLong: latLong,
            networkClient: networkClient,
            logger: logger
        )
    }
}
