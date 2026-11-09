//
//  APIKeyParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class APIKeyParser {
    /** 优先使用本机设置中的个人密钥，留空时使用构建配置 */
    func parse(personalKey: String) -> String {
        // 允许从网页粘贴时带有首尾空白
        let configuredKey = personalKey.trimmingCharacters(in: .whitespacesAndNewlines);
        guard configuredKey.isEmpty else { return configuredKey; }
        return Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String ?? "";
    }
}
