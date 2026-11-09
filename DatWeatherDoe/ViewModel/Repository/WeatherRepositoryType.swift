////
////  WeatherRepositoryType.swift
////  DatWeatherDoe
////
////  Created by Inder Dhir on 1/30/16.
////  Copyright © 2016 Inder Dhir. All rights reserved.
////

import CoreLocation

// 天气响应与用于这次天气查询的原始位置
struct WeatherObservation {
    // 天气服务返回的响应
    let response: WeatherAPIResponse;
    // 天气请求实际使用的坐标
    let coordinates: CLLocationCoordinate2D;
}

protocol WeatherRepositoryType: AnyObject {
    /** 获取天气响应并保留原始查询坐标 */
    func getWeather() async throws -> WeatherObservation;
}
