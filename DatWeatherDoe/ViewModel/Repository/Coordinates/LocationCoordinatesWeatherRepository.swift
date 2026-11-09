//
//  LocationCoordinatesWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import OSLog

final class LocationCoordinatesWeatherRepository: WeatherRepositoryType {
    private let appId: String
    private let latLong: String
    private let networkClient: NetworkClientType
    private let logger: Logger

    init(
        appId: String,
        latLong: String,
        networkClient: NetworkClientType,
        logger: Logger
    ) {
        self.appId = appId
        self.latLong = latLong
        self.networkClient = networkClient
        self.logger = logger
    }

    /** 按原有的查询坐标获取天气并将坐标交给显示层 */
    func getWeather() async throws -> WeatherObservation {
        logger.debug("Getting weather via lat/long")

        do {
            let location = try getLocationCoordinatesFrom(latLong)
            let url = try WeatherURLBuilder(appId: appId, location: location).build()
            let data = try await networkClient.performRequest(url: url)
            // 保留请求坐标，避免采用服务返回的测站或城市坐标
            return .init(response: try WeatherAPIResponseParser().parse(data), coordinates: location);
        } catch {
            logger.error("Getting weather via lat/long failed")

            throw error
        }
    }

    private func getLocationCoordinatesFrom(_ latLong: String) throws -> CLLocationCoordinate2D {
        try LocationValidator(latLong: latLong).validate()

        let latAndlong = try LocationParser().parseCoordinates(latLong)
        return latAndlong
    }
}
