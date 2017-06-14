import CoreLocation

var locationMgr: SLLocationManager = SLLocationManager()

class SLLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    var locationString: String?
    var longitude: String?
    var latitude: String?

    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func getLatestLocation(){
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if (locations.count > 0){
            setUsersClosestCity(locations[0], completion: { (locString) in
                self.locationString = locString
                self.latitude = locations[0].coordinate.latitude.description
                self.longitude = locations[0].coordinate.longitude.description
                self.locationManager.stopUpdatingLocation()
                //logger.message(type: .information, message: "lat: \(self.latitude!), long: \(self.longitude!)")
            })
        }
    }
    
    func setUsersClosestCity(_ location: CLLocation, completion:@escaping (_ locationString: String?) -> Void)
    {
        let geoCoder = CLGeocoder()
        var locString = ""

        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            guard let placeArray = placemarks as [CLPlacemark]! else {
                completion(nil)
                return
            }

            if (placeArray.isEmpty) {
                completion(nil)
                return
            }
            
            guard let placeMark: CLPlacemark = placeArray[0] else {
                completion(nil)
                return
            }
            
            if let locality = placeMark.locality
            {
                locString = locality
            }
            else{
                completion(nil)
            }
            
            if let adminArea = placeMark.administrativeArea
            {
                locString = locString + ", \(adminArea)"
            }
            
            if let country = placeMark.country
            {
                locString = locString + ", \(country)"
            }
            
            completion(locString)
        }
    }
}
