//
//  WeatherPageViewController.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import UIKit

class WeatherAppPageViewController: UIPageViewController {

    var locationIndex:Int = 0
    var metricIndex:Int = 0
    var locations = [WeatherLocation.UK,WeatherLocation.England,WeatherLocation.Scotland,WeatherLocation.Wales]
    var metrics =  [WeatherMetric.temperatureMax,WeatherMetric.temperatureMin,WeatherMetric.rainfall]
    let dataProvider = WeatherAppDataProvider(weatherAPIInterface: WeatherAppAPI.shared)
    fileprivate lazy var weatherViewControllers: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "weatherViewController", index:0),
            self.getViewController(withIdentifier: "weatherViewController", index:1),
            self.getViewController(withIdentifier: "weatherViewController", index:2),
            self.getViewController(withIdentifier: "weatherViewController", index:3),
        ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String, index:Int) -> UIViewController
    {
        let weatherViewController : WeatherAppViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! WeatherAppViewController
        weatherViewController.cityName = locations[index]
        return weatherViewController
    }
// MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        if let firstVC = weatherViewControllers.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        if !WeatherAppDataBaseController.checkIdLocalDataExists(){
            let viewModel = WeatherAppDataViewModel(dataProvider: dataProvider, location: locations[locationIndex],metric:metrics[metricIndex])
            viewModel.delegate = self
            viewModel.getWeatherData(forLocation: locations[locationIndex],metric: metrics[metricIndex])
        }else{
            //load data from local db
            NotificationCenter.default.post(name: Notification.Name("UpdatesRequired"), object: nil)
        }
       
    }
    
// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
// MARK: - Extensions

extension WeatherAppPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = weatherViewControllers.index(of: viewController)
            else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0
            else {
                return weatherViewControllers.last
        }
        guard weatherViewControllers.count > previousIndex
            else {
                return nil
        }
        return weatherViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
        guard let viewControllerIndex = weatherViewControllers.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < weatherViewControllers.count
            else {
                return weatherViewControllers.first
        }
        guard locations.count > nextIndex else {
            return nil
        }
        return weatherViewControllers[nextIndex]
        
    }
}

extension WeatherAppPageViewController :WeatherAppDataModelDelegate{
    func loadedDataForLocation(location: WeatherLocation, metric: WeatherMetric) {
        if metricIndex < metrics.count - 1 {
            metricIndex = metricIndex + 1
        }else if locationIndex < locations.count - 1{
            locationIndex = locationIndex + 1
            metricIndex = 0
        } else {
            // all data downloaded from server load data
            NotificationCenter.default.post(name: Notification.Name("UpdatesRequired"), object: nil)
            return
        }
        let viewModel = WeatherAppDataViewModel(dataProvider: dataProvider, location: locations[locationIndex],metric:metrics[metricIndex])
        viewModel.delegate = self
        viewModel.getWeatherData(forLocation: locations[locationIndex],metric: metrics[metricIndex])
    }
}
