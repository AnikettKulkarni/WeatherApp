//
//  WeatherAppResponse.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import Foundation
struct WeatherAppResponse: Codable {
    let value: Double
    let year: Double
    let month: Double
    
    init(_ dictionary: [String: Any]) {
        self.value = dictionary["value"] as? Double ?? 0
        self.year = dictionary["year"] as? Double ?? 0
        self.month = dictionary["month"] as? Double ?? 0
    }
}

