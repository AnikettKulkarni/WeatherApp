//
//  WeatherAppApi.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import Foundation


// MARK: - Interfaces

protocol WeatherAppAPIInterface {
    /*
     * Fetches weather data with given location and Metric
     */
    func fetchWeatherData(_ location: WeatherLocation, weatherMetric:WeatherMetric, completionHandler: @escaping ([Any]) -> Void)
}

class WeatherAppAPI: WeatherAppAPIInterface {
    
    let defaultSession = URLSession(configuration: .default)
    var downloadTask: URLSessionDownloadTask?
    
    private var baseURLString: String =  "https://s3.eu-west-2.amazonaws.com/interview-question-data/metoffice/"
    
    /**
     A global shared WeatherAppAPI Instance.
     */
    static public let shared: WeatherAppAPI = WeatherAppAPI()
    
    func fetchWeatherData(_ location: WeatherLocation, weatherMetric: WeatherMetric, completionHandler: @escaping ([Any]) -> Void)
    {
        downloadTask?.cancel()
        var urlForRequest = baseURLString
        switch weatherMetric {
        case .temperatureMax:
            urlForRequest = urlForRequest + "Tmax-"
        case .temperatureMin:
            urlForRequest = urlForRequest + "Tmin-"
        case .rainfall:
            urlForRequest = urlForRequest + "Rainfall-"
        }
        switch location {
        case .UK:
            urlForRequest = urlForRequest + "UK"
        case .England:
            urlForRequest = urlForRequest + "England"
        case .Scotland:
            urlForRequest = urlForRequest + "Scotland"
        case .Wales:
            urlForRequest = urlForRequest + "Wales"
        }
        urlForRequest.append(".json")
        guard var urlComponents = URLComponents(string: urlForRequest) else { return }
        guard let url = urlComponents.url else { return }
        print("\(url.absoluteString)")
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            defer {
                self.downloadTask = nil
            }
            
            if let error = error {
                NSLog("[API] Request failed with error: \(error.localizedDescription)")
                return
            }
            if let localURL = localURL {
                if let data = try? Data(contentsOf: localURL) {
                    var model = [WeatherAppResponse]()
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                        print(jsonResponse)
                        guard let jsonArray = jsonResponse as? [[String: Any]] else {
                            return
                        }
                        
                        for dic in jsonArray{
                            model.append(WeatherAppResponse(dic)) // adding now value in Model array
                        }
                        completionHandler(model)
                    }
                }
            }
        }
        
        task.resume()
        
    }
}
