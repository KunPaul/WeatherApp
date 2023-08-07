//
//  Extentions.swift
//  WeatherApp
//
//  Created by Павел Кунгурцев on 09.08.2023.
//

import Foundation
import SwiftUI

extension Double {
    func kelvinToCelsius(_ kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

extension View {
    func cornerRadius (_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners , cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
}
