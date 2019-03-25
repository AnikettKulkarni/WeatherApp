//
//  WeatherAppDataViewModel.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import Foundation
enum WeatherMetric: String{
    case temperatureMax = "Tmax"
    case temperatureMin = "Tmin"
    case rainfall = "Rainfall"
}

enum WeatherLocation: String{
    case UK = "UK"
    case England = "England"
    case Scotland = "Scotland"
    case Wales = "Wales"
    
}
extension WeatherMetric: CaseIterable {}
// MARK: - Interfaces
protocol WeatherAppDataModelDelegate : class{
    func loadedDataForLocation (location:WeatherLocation, metric:WeatherMetric)
}
protocol WeatherAppDataViewModelInterface {
    /*
     * View Model method to get weather data for location , metric
     */
    func getWeatherData(forLocation:WeatherLocation, metric:WeatherMetric)
}
/*
 * This class get data from WeatherAppDataProvider and passed it to WeatherAppDataBaseController to store locally
 */
class WeatherAppDataViewModel : WeatherAppDataViewModelInterface{
    
    
    private let dataProvider: WeatherAppDataProviderInterface
    private var weatherData: [Any] = []
    var location: WeatherLocation
    var metric: WeatherMetric
    public weak var delegate: WeatherAppDataModelDelegate?

    init(dataProvider: WeatherAppDataProviderInterface, location:WeatherLocation, metric:WeatherMetric) {
        self.dataProvider = dataProvider
        self.location = location
        self.metric = metric
    }
    
    func getWeatherData(forLocation:WeatherLocation, metric:WeatherMetric){
    self.location = forLocation
    self.dataProvider.fetchWeatherData(location: forLocation, metric: metric, completionHandler: { result in
        DispatchQueue.main.async {
            self.storeDataLocally(weatherDataSet: result, location :forLocation, metric: metric)
        }
    })
}
    private func storeDataLocally(weatherDataSet:[Any],location :WeatherLocation, metric: WeatherMetric){
        for weatherData in weatherDataSet {
            WeatherAppDataBaseController.addEntityObject(entityName: "WeatherData", withData: weatherData as! WeatherAppResponse , location: location, metric: metric)
        }
        WeatherAppDataBaseController.saveContext()
        delegate?.loadedDataForLocation(location: location, metric: metric)
    }
    
}
