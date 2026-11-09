//
//  SystemLocationWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import OSLog

final class SystemLocationWeatherRepository: WeatherRepositoryType {
    private let appId: String
    private let location: CLLocationCoordinate2D
    private let networkClient: NetworkClientType
    private let logger: Logger

    init(
        appId: String,
        location: CLLocationCoordinate2D,
        networkClient: NetworkClientType,
        logger: Logger
    ) {
        self.appId = appId
        self.location = location
        self.networkClient = networkClient
        self.logger = logger
    }

    /** 按原有的查询坐标获取天气并将坐标交给显示层 */
    func getWeather() async throws -> WeatherObservation {
        logger.debug("Getting weather via location")

        do {
            let url = try WeatherURLBuilder(appId: appId, location: location).build()
            let data = try await networkClient.performRequest(url: url)
            // 保留请求坐标，避免采用服务返回的测站或城市坐标
            return .init(response: try WeatherAPIResponseParser().parse(data), coordinates: location);
        } catch {
            logger.error("Getting weather via location failed")

            throw error
        }
    }
}
