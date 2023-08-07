//
//  WeatheManager.swift
//  WeatherApp
//
//  Created by Павел Кунгурцев on 08.08.2023.
//

import Foundation
import CoreLocation
import Combine

class WeatherManager: ObservableObject {
    
    @Published var weather: ResponseBody?
    
    func kelvinToCelsius(_ kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    
    @Published var currentWeatherIcon: String = "questionmark"
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\("08cd303a109882af54f8b7076a8b8f9e")") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {fatalError("Ошибка ловли даты") }
        var decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        
        // Преобразование температур из Кельвинов в Цельсии
        let temperatureInCelsius = kelvinToCelsius(decodedData.main.temp)
        decodedData.main.temp = temperatureInCelsius
        decodedData.main.feels_like = kelvinToCelsius(decodedData.main.feels_like)
        decodedData.main.temp_min = kelvinToCelsius(decodedData.main.temp_min)
        decodedData.main.temp_max = kelvinToCelsius(decodedData.main.temp_max)
        
        let iconName = iconNameForWeather(decodedData.weather[0].main)
           let capturedDecodedData = decodedData

           DispatchQueue.main.async {
               self.currentWeatherIcon = iconName
               self.weather = capturedDecodedData
           }

           return capturedDecodedData
    
    }
    
    func iconNameForWeather(_ weatherState: String) -> String {
        switch weatherState {
            case "Clear":
                return "sun.max.fill"
            case "Clouds":
                return "cloud.fill"
            case "Rain":
                return "cloud.rain.fill"
            case "Snow":
                return "snow"
            case "Thunderstorm":
                return "cloud.bolt.rain.fill"
            case "Drizzle":
                return "cloud.drizzle.fill"
            case "Mist", "Smoke", "Haze", "Dust", "Fog":
                return "cloud.fog.fill"
            case "Sand", "Ash", "Squall", "Tornado":
                return "tornado"
            default:
                return "questionmark"
            }
    }

}

struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse

    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }

    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
}

extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}


