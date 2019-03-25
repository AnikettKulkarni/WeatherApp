//
//  WeatherAppDataProvider.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import Foundation

// MARK: - Interfaces
protocol WeatherAppDataProviderInterface {
    /*
     * Fetches weather data for given location, metrics with completionHandler
     */
    func fetchWeatherData( location: WeatherLocation, metric:WeatherMetric, completionHandler: @escaping ([Any]) -> Void)
}

class WeatherAppDataProvider: WeatherAppDataProviderInterface {

    var weatherAPIInterface: WeatherAppAPIInterface
    
    init(weatherAPIInterface: WeatherAppAPIInterface) {
        self.weatherAPIInterface = weatherAPIInterface
    }
    func fetchWeatherData( location: WeatherLocation, metric:WeatherMetric, completionHandler: @escaping ([Any]) -> Void){
            self.weatherAPIInterface.fetchWeatherData(location, weatherMetric: metric, completionHandler: { result in
            completionHandler(result)
        })
        }
}



