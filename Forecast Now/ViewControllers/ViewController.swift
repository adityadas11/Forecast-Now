//
//  ViewController.swift
//  Forecast Now
//
//  Created by Adi on 3/14/20.
//  Copyright © 2020 Adi. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let baseURL = "http://api.openweathermap.org/data/2.5/forecast?q="
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var weatherTableView: UITableView!
    var weatherForecastArray = [WeatherModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
    }
    

    @IBAction func searchButtonTapped(_ sender: Any) {
        if cityTextField.text == ""{
            showError(msg: "Please type in the city name to see the forecast.")
        }
        else{
            weatherAPICall()
        }
    }
    
    //MARK:- Viewcontroller local methods
    func showError(msg:String){
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
        }
        
        alertController.addAction(OKAction)
        alertController.view.layoutIfNeeded()
        
        self.present(alertController, animated: true, completion:nil)
    }
    func weatherAPICall(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let cityName = cityTextField.text!.replacingOccurrences(of: " ", with: "%20")
        
        
        let url = String(format: "%@%@%@",baseURL,cityName,"&APPID=")
        
        let connect = Connection()
        connect.connectionDelegate = self
        connect.connectToServerWithurlGetMethod(url, method: "GET")
           
        }
    //converting Unix time format to desired Date and Time format
    func getDate(epoch : Double) -> String{
            let date = Date(timeIntervalSince1970: epoch)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM dd"
            let currentDateString: String = dateFormatter.string(from: date)
            return currentDateString
    }
    
    
    //MARK:- TableView 	Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForecastArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        cell.dayLabel.text = weatherForecastArray[indexPath.row].day
        cell.weatherLabel.text = weatherForecastArray[indexPath.row].weather
        cell.highTempLabel.text = weatherForecastArray[indexPath.row].highTemp
        cell.lowTempLabel.text = weatherForecastArray[indexPath.row].lowTemp
        let desc = weatherForecastArray[indexPath.row].weather
        var imagePath = ""
        switch desc {
        case "clear sky":
            imagePath = "Sunny.png"
        case "few clouds","broken clouds":
            imagePath = "PartlyCloudy.png"
        case "scattered clouds", "overcast clouds","mist":
            imagePath = "Cloudy.png"
        case "shower rain","rain","light rain":
            imagePath = "HeavyRain.png"
        case "thunderstorm":
            imagePath = "LightningCloud.png"
        case "snow","light snow","Heavy snow":
            imagePath = "Snow.png"
       
        default:
            imagePath = "Sunny.png"
        }
        cell.weatherImageView?.image = UIImage(named: imagePath)
        return cell
    }
}

extension ViewController : ConnectionProtocol{
    func connectionSuccessWithData(_ responseData: Data) {
        MBProgressHUD.hide(for: self.view, animated: true)
        weatherForecastArray.removeAll()
        var tempDict : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        
        do{
            tempDict = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! Dictionary<String, AnyObject>
        }
        catch{
            connectionFailedWithError("Bad Connection")
        }

        guard let allWeatherData = tempDict["list"] as? [NSDictionary] else {
            return
        }
        var uniqueDays = Set<String>()
        for eachDay in allWeatherData{
            let weatherObject = WeatherModel()
            
            guard let tempDay = eachDay["dt"] as? Double else{
                return
            }
            let newDay = getDate(epoch: tempDay)
            //filtering out the 3-hour forecast frequency to just one forecast per day
            if uniqueDays.contains(newDay){
                continue
            }
            else{
                uniqueDays.insert(newDay)
                guard let tempData = eachDay["main"] as? NSDictionary else {
                    return
                }
                guard let minTemp = tempData["temp_min"] as? Double else{
                    return
                }
                guard let maxTemp = tempData["temp_max"] as? Double else{
                    return
                }
                guard let tempDay = eachDay["dt"] as? Double else{
                    return
                }
                guard let weatherDetailsArray = eachDay["weather"] as? NSArray else{
                    return
                }
                guard let weatherDetail = weatherDetailsArray[0] as? NSDictionary else{
                    return
                }
                guard let desc = weatherDetail["description"] as? String else{
                    return
                }
                weatherObject.weather = desc
                
                
                weatherObject.lowTemp = String(format: "%.1f%@",(minTemp - 273.15)*(9/5)+32," °F")
                weatherObject.highTemp = String(format: "%.1f%@",(maxTemp - 273.15)*(9/5)+32," °F")
                weatherObject.day = getDate(epoch: tempDay)
                weatherForecastArray.append(weatherObject)
                
            }
        }
        weatherTableView.reloadData()
       
        
    }
    func connectionFailedWithError(_ errorMsg: String) {
        MBProgressHUD.hide(for: self.view, animated: true)
        showError(msg: errorMsg)
    }
}
