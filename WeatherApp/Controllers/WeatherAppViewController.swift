//
//  ViewController.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//

import UIKit
enum Months :Int{
    case January = 1
    case February
    case March
    case April
//    case May =
//    case June = "6"
//    case July = "7"
//    case August = "8"
//    case September = "9"
//    case October = "10"
//    case November = "11"
//    case December = "12"
}
struct Constants {
    static let cellIdentifier = "weatherDataCell"
    static let collectionCellNibName = "WeatherAppCollectionViewCell"
}
class WeatherAppViewController: UIViewController {
    //IBOutlet
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var yearLable: UILabel!
    // Variables
    var cityName:WeatherLocation
    var dataSet:[WeatherDataManagedObject]?
    var yearPickerValues:[String]?
    var selectedIndex = 0
    // MARK: - Life Cycle 

    required init?(coder aDecoder: NSCoder) {
        self.cityName = WeatherLocation.UK
        super.init(coder: aDecoder)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityNameLable.text = self.cityName.rawValue
        self.collectionView.register(UINib(nibName: Constants.collectionCellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("UpdatesRequired"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if WeatherAppDataBaseController.checkIdLocalDataExists(){
            self.loadDataFromLocalDatabase()
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
// MARK: - Private Functions
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.loadDataFromLocalDatabase()
       
    }
    
    private func loadDataFromLocalDatabase() {
        if let yearPickerValue = WeatherAppDataBaseController.getWeatherDataYearsForLocation(location: self.cityName){
            self.yearPickerValues = yearPickerValue
            let year  = (yearPickerValues?[selectedIndex])!
            yearLable.text = year
            loadDataForYear(year: year)
        }
    }
    private func loadDataForYear(year:String) {
        dataSet = WeatherAppDataBaseController.getWeatherDataForLocation(location: self.cityName, year: year )
        self.collectionView.reloadData()
        self.yearPicker.reloadAllComponents()
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

// MARK: - Extensions

extension WeatherAppViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSet?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WeatherAppCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! WeatherAppCollectionViewCell
        let weatherData:WeatherDataManagedObject  = (dataSet?[indexPath.row])!
        cell.maximumTemperatureLable.text = weatherData.maximumTemperature.clean + "°"
        cell.minimumTemperatureLable.text = weatherData.minimumTemperature.clean + "°"
        cell.rainfallLable.text = weatherData.rainfall.clean + "mm"
        cell.yearLable.text = weatherData.year.clean
        cell.monthLable.text = self.getMonthString(month: weatherData.month.clean)


        return cell
        
    }
    func getMonthString(month:String) ->String{
        let monthInt = Int(month)!
        let dateFormat = DateFormatter()
        let monthName = dateFormat.monthSymbols[monthInt - 1]
        return monthName
    }
    
}


extension WeatherAppViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return yearPickerValues?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let year  = (yearPickerValues?[row])!
        return year
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectedIndex = row
        let year = (yearPickerValues?[row])!
        yearLable.text = year
        self.view.endEditing(true)
        loadDataForYear(year: year)
    }

}
extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
