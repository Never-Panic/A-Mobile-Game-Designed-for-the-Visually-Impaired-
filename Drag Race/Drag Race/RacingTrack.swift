//
//  RacingTrack.swift
//  Drag Race
//
//  Created by 刘坤昊 on 2021/2/11.
//

import Foundation


struct RacingTrack {
    
    var trackLenth: Double
    var cliffDistence: Double // from the finish line
    var car: RacingCar
    
    struct RacingCar {
        var position: Double = 0
        var speed: Double = 0 
    }
}
