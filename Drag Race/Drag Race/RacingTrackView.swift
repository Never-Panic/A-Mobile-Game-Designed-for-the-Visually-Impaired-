//
//  RacingTrackView.swift
//  Drag Race
//
//  Created by 刘坤昊 on 2021/2/11.
//

import SwiftUI


struct RacingTrackView: View {
    @ObservedObject var racingTrack: RacingTrackViewModel
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack{
                ZStack{
                    Text("cliff")
                        .foregroundColor(.red)
                        .position(x: geometry.size.width / 2, y: 0)
                        .padding(.top)
                    Text("finish line")
                        .position(x: geometry.size.width / 2, y: geometry.size.height * (1-finishLinePositionPercentage))
                    Text("car")
                        .font(.title)
                        .foregroundColor(.green)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * (1-carPositionPercentage))
                        .padding(.bottom)
                        .opacity(racingTrack.gameState == .running ? 1 : 0)
                    
                    
                    switch racingTrack.gameState {
                        case .firstStart :
                            ZStack{
                                Color.yellow
                                Text("Press Start or Double Tap")
                                    .frame(maxWidth: 300)
                            }
                            .onTapGesture(count: 2, perform: {
                                racingTrack.startGame()
                            })
                        case .win :
                            ZStack{
                                Color.green
                                Text("You Won!\nPress Start or Double Tap")
                                    .frame(maxWidth: 300)
                            }
                            .onTapGesture(count: 2, perform: {
                                racingTrack.startGame()
                            })
                        case .dead :
                            ZStack{
                                Color.red
                                Text("You Fell Off the Cliff!\nPress Start or Double Tap")
                                    .frame(maxWidth: 300)
                            }
                            .onTapGesture(count: 2, perform: {
                                racingTrack.startGame()
                            })
                        case .notFinish :
                            ZStack{
                                Color.gray
                                Text("You Didn't Finish the Track!\nPress Start or Double Tap")
                                    .frame(maxWidth: 300)
                            }
                            .onTapGesture(count: 2, perform: {
                                racingTrack.startGame()
                            })
                        default :
                            EmptyView()
                    }
                    
                }
                
                if racingTrack.gameState == .running {
                    Button("restart"){
                        racingTrack.gameState = .firstStart
                        racingTrack.restartGame()
                    }
                    .padding(.horizontal)
                } else {
                    Button("start") {
                        racingTrack.startGame()
                    }
                    .padding(.horizontal)
                }
                
            }
        })
    }
    
    var carPositionPercentage: CGFloat {
        CGFloat(racingTrack.car.position / racingTrack.safeTrackLenth)
    }
    
    var finishLinePositionPercentage: CGFloat {
        CGFloat(racingTrack.finishLineDistence / racingTrack.safeTrackLenth)
    }
    
    
}
