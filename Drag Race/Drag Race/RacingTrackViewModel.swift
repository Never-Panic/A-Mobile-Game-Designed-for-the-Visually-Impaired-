//
//  RacingTrackViewModel.swift
//  Drag Race
//
//  Created by 刘坤昊 on 2021/2/11.
//

import SwiftUI
import CoreMotion
import AudioToolbox

class RacingTrackViewModel:ObservableObject {
    @Published var track =  RacingTrackViewModel.createRacingTrack(trackLenth: 100 , cliffDistence: 20)
    
    private static func createRacingTrack(trackLenth: Double, cliffDistence: Double) -> RacingTrack {
        RacingTrack(trackLenth: trackLenth, cliffDistence: cliffDistence, car: RacingTrack.RacingCar())
    }
    
    // MARK: - Intend(s)
    
    // Accelerometer's data
    private let frequency = 1.0 / 60.0 // 60 Hz
    private var timer: Timer?

    private let motion = CMMotionManager()

    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
          self.motion.accelerometerUpdateInterval = frequency
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
          self.timer = Timer(fire: Date(), interval: frequency,
                             repeats: true, block: { timer in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
//                let x = data.acceleration.x
                let y = data.acceleration.y
//                let z = data.acceleration.z
                // Updates car's speed and position
                
                self.track.car.speed += y / 20
                self.track.car.position += self.track.car.speed
                
                self.CheckDistence()
             }
          })
          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: .default)
       } else {
            print("Don't Support Accelerometer!")
       }
    }
    
    func startGame() {
        gameState = .running
        startAccelerometers()
    }

    func restartGame() {
        if motion.isAccelerometerActive {
            motion.stopAccelerometerUpdates()
        }
        timer?.invalidate()
        track.car.position = 0
        track.car.speed = 0
        stopRadarSound()
    }
    
    // game state
    enum GameState {
        case running
        case firstStart
        case win // 经过终点线，没掉下悬崖
        case dead // 掉下悬崖
        case notFinish // 没过终点线
    }
    
    var gameState = GameState.firstStart
    
    // Radar Sound implementation
    private var soundTimer: Timer?
    func playRadarSound (frequency: Double) {
        stopRadarSound()
        soundTimer = Timer(fire: Date(), interval: frequency, repeats: true) { timer in
            AudioServicesPlaySystemSound(SystemSoundID(1103))
        }
        RunLoop.current.add(soundTimer!, forMode: .default)
    }
    
    func stopRadarSound () {
        if let timer = soundTimer {
            timer.invalidate()
        }
    }
    
    enum CarState: Double { // raw value represents the frequency of radar sound
        case veayNear = 0.05
        case near = 0.1
        case close = 0.2
        case middle = 0.5
        case far = 1.0
        case canNotSeen = 0
    }
    
    
    private var carState: CarState?
    
    func radarSoundJugde (currentState: CarState) {
        if let state = carState {
            if state != currentState {
                playRadarSound(frequency: currentState.rawValue)
                carState = currentState
            }
        } else {
            playRadarSound(frequency: currentState.rawValue)
            carState = currentState
        }
    }
    
    private func CheckDistence () {
        
        if track.car.position > track.cliffDistence + track.trackLenth {
            gameState = .dead
            AudioServicesPlaySystemSound(SystemSoundID(1029))
            restartGame()
            return
        }
            
        if track.car.speed < -0.2 {
            if track.car.position < track.trackLenth {
                gameState = .notFinish
                AudioServicesPlaySystemSound(SystemSoundID(1152))
            } else if track.car.position > track.cliffDistence + track.trackLenth {
                gameState = .dead
                AudioServicesPlaySystemSound(SystemSoundID(1029))
            } else {
                gameState = .win
                AudioServicesPlaySystemSound(SystemSoundID(1021))
            }
            restartGame()
            return
        }
        
        let distence = carPositionForSound
        
        if distence < 0.1 {
            radarSoundJugde(currentState: .veayNear)
        }
        else if distence < 0.3 {
            radarSoundJugde(currentState: .near)
        }
        else if distence < 0.6 {
            radarSoundJugde(currentState: .close)
        }
        else if distence < 0.8 {
            radarSoundJugde(currentState: .middle)
        }
        else if distence < 1{
            radarSoundJugde(currentState: .far)
        }
        else {
            stopRadarSound()
            carState = .canNotSeen
        }
    }
    
    private var carPositionForSound: Double {
        abs(track.car.position - track.trackLenth)/track.trackLenth
    }
    
    // MARK: - Access to the model
    
    var car: RacingTrack.RacingCar {
        track.car
    }
    
    var finishLineDistence: Double {
        track.trackLenth
    }
    
    var cliffDistence: Double {
        track.cliffDistence
    }
    
    var safeTrackLenth: Double {
        cliffDistence + finishLineDistence
    }
}
