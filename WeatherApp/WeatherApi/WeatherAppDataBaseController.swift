//
//  WeatherAppDataBaseController.swift
//  WeatherApp
//
//  Created by Aniket on 23/03/19.
//  Copyright © 2019 Aniket Kulkarni. All rights reserved.
//
/*
 * Thisclass is used to store the weather data in Coredata.
 */
import Foundation
import CoreData
struct Entities {
    static let WeatherData = "WeatherData"
}

class WeatherAppDataBaseController {
    
    private init() {}
    
    
    //Returns the current Persistent Container for CoreData
    class func getContext () -> NSManagedObjectContext {
        return WeatherAppDataBaseController.persistentContainer.viewContext
    }
   static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = WeatherAppDataBaseController.getContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    class func addEntityObject(entityName: String, withData: WeatherAppResponse, location:WeatherLocation, metric:WeatherMetric?){
        let context = WeatherAppDataBaseController.getContext()
        self.fetchRecord(entityName: entityName, year: withData.year, month: withData.month, location: location.rawValue, completionHandler: { result in
            var updateObject = result
            if updateObject == nil {
                let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
                updateObject = NSManagedObject(entity: entity!, insertInto: context)
            }
            switch entityName {
            case Entities.WeatherData:
                updateObject?.setValue(withData.value, forKey: self.getKeyForMetric(metric: metric!))
                updateObject?.setValue(withData.month, forKey: "month")
                updateObject?.setValue(withData.year, forKey: "year")
                updateObject?.setValue(location.rawValue, forKey: "location")
            default:
                break
            }
        })
    }
    class func getKeyForMetric(metric:WeatherMetric) ->String{
        switch metric {
        case WeatherMetric.temperatureMax:
            return "maximumTemperature"
        case WeatherMetric.temperatureMin:
            return "minimumTemperature"
        case WeatherMetric.rainfall:
            return "rainfall"
        }
    }

    class func fetchRecord(entityName:String, year:Double, month:Double, location:String,completionHandler : @escaping (NSManagedObject?) -> Void) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName:entityName )
    let nilObject:NSManagedObject? = nil
    request.predicate = NSPredicate(format: "year = %lf AND month = %lf AND location = %@", year,month,location)
    do {
    let result = try WeatherAppDataBaseController.getContext().fetch(request)
    for data in result as! [NSManagedObject] {
        completionHandler(data)
        return
    }
        completionHandler(nilObject)
    } catch {
        print("Failed")
        completionHandler(nilObject)
    }
    }
    class func getWeatherDataForLocation(location:WeatherLocation, year:String?) ->[WeatherDataManagedObject]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherData")
        request.predicate = NSPredicate(format: "location = %@ AND year = %@", location.rawValue,year ?? "")
        let sortDescriptors = [NSSortDescriptor(key: "year", ascending: true), NSSortDescriptor(key: "month", ascending: true)]
        request.sortDescriptors = sortDescriptors
        do {
            let result = try WeatherAppDataBaseController.getContext().fetch(request)
            return result as? [WeatherDataManagedObject];
        } catch {
            print(" error fetching")
        }
        return []
    }
    class func getWeatherDataYearsForLocation(location:WeatherLocation) ->[String]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherData")
        request.predicate = NSPredicate(format: "location = %@", location.rawValue)
        request.propertiesToFetch = ["year"]
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        let sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
        request.sortDescriptors = sortDescriptors
        var resultSet:[String] = []
        do {
            let result = try WeatherAppDataBaseController.getContext().fetch(request)
            for data in result as! [NSDictionary]  {
                resultSet.append(String(format: "%.0f", data.value(forKey:"year") as! Double))
            }
            return resultSet
        } catch {
            print(" error fetching")
        }
        return []
    }
    class func checkIdLocalDataExists() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherData")
        do {
            let result = try WeatherAppDataBaseController.getContext().fetch(request)
             let count = result.count;
            if count > 0 {
                return true
            }
        } catch {
        }
        return false
    }
}
