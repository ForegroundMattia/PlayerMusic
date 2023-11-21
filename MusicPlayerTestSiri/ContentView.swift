//
//  ContentView.swift
//  MusicPlayerTestSiri
//
//  Created by Mattia Marranzino on 21/11/23.
//
import SwiftUI
import AVKit
import UIKit


struct ContentView: View {
    
    let audioFileName = "titanium-170190"
    let audioMetronome = "metronome"
    
    
    @State private var pressedButton1x : Bool = true
    @State private var pressedButton05x : Bool = false
    @State private var pressedButton2x : Bool = false
    
    
    @State private var player: AVAudioPlayer?
    @State private var playerMetronome : AVAudioPlayer?
    
    @State private var toggleBool : Bool = false
    @State private var isPlaying: Bool = false
    @State private var isPlayingMetronome: Bool = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var volumeMetronome : Float = 1
    @State private var rlPositionAudio : Float = 0
    
    
    
    @State var showSheet: Bool = false
    @State var finalBpm : Float = 0
    
    
    
    @State var songBpm : Float = 130
    
    @State var rateBpm : Float = 0
    
    
    var body: some View {
 
        
        
        ZStack{
            
            Color.black
                .ignoresSafeArea()
            VStack{
                Spacer()
                HStack{
                    
                    Spacer()
                    Text(timeString(time: currentTime)).foregroundStyle(.white)
                    
                    Slider(value: Binding(get: {
                       currentTime
                   }, set: { newValue in
                       seekAudio(to: newValue)
                   }), in: 0...totalTime)
                   .accentColor(.white)
                   
                  Text(timeString(time: totalTime)).foregroundStyle(.white)
                }

               
                
                HStack{

                    Button{
                        showSheet = true
                    } label: {
                        Image(systemName: "metronome").foregroundStyle(.white).font(.system(size: 30))
                    }.sheet(isPresented: $showSheet){
                        Group{
                            ZStack{
                                Color.gray.ignoresSafeArea()
                                VStack{
                                    HStack{
                                        Text("Metronomo").padding().font(.title).bold()
                                        Toggle(isOn: $toggleBool) {
                                            
                                        }.padding().onChange(of: toggleBool) {
                                            if toggleBool {
                                                playerMetronome?.volume = volumeMetronome
                                                
                                            }else{
                                                playerMetronome?.volume = 0
                                            }
                                        }
                                    }
                                    HStack{
                                        VStack{
                                            Text("Volume")
                                            Slider(value: $volumeMetronome,in: 0...1){ editing in
                                                playerMetronome?.volume = volumeMetronome
                                                
                                            }.padding().disabled(!toggleBool)
                                        }.padding()
                                        VStack{
                                            Text("L & R")
                                            Slider(value: $rlPositionAudio,in: -1...1){ editing in
                                                playerMetronome?.pan = rlPositionAudio
                                            }.padding().disabled(!toggleBool)
                                        }.padding()
                                        
                                    }
                                    VStack(alignment: .leading){
                                        Text("Suddivisione").foregroundStyle(.white).bold()
                                        HStack{
                                            
                                            Button {
                                                playerMetronome?.rate = 1
                                                playerMetronome?.rate *= 0.5
                                                pressedButton05x.toggle()
                                                pressedButton1x = false
                                                pressedButton2x = false
                                                
                                            } label: {
                                                Text("0.5x")
                                                    .frame(minWidth: 70, minHeight: 20)
                                                    .padding()
                                                    .foregroundColor(pressedButton05x ? .black : .white)
                                                    .background(
                                                        RoundedRectangle(
                                                            cornerRadius: 10,
                                                            style: .continuous
                                                        )
                                                        .stroke(pressedButton05x ? .white : .black, lineWidth: 2)
                                                        .fill(pressedButton05x ? .white : .clear)

                                                    )
                                            }
                                            
                                            Button {
                                                playerMetronome?.rate = finalBpm/songBpm
                                                pressedButton1x.toggle()
                                                pressedButton05x = false
                                                pressedButton2x = false

                                            } label: {
                                                Text("1x")
                                                    .frame(minWidth:70,minHeight: 20)
                                                    .padding()
                                                    .foregroundColor(pressedButton1x ? .black : .white)
                                                    .background(
                                                        RoundedRectangle(
                                                            cornerRadius: 10,
                                                            style: .continuous
                                                            
                                                        )
                                                        .stroke(pressedButton1x ? .white : .black, lineWidth: 2)
                                                        .fill(pressedButton1x ? .white : .clear)
                                                        
                                                        

                                                    )
                                            }.padding()
                                            
                                            Button {
                                                playerMetronome?.rate = 1
                                                playerMetronome?.rate *= 2
                                                pressedButton2x.toggle()
                                                pressedButton1x = false
                                                pressedButton05x = false
                                                
                                            } label: {
                                                
                                                Text("2x")
                                                    .frame(minWidth:70,minHeight: 20)
                                                    .padding()
                                                    .foregroundColor(pressedButton2x ? .black : .white)
                                                    .background(
                                                        RoundedRectangle(
                                                            cornerRadius: 10,
                                                            style: .continuous
                                                        )
                                                        .stroke(pressedButton2x ? .white : .black, lineWidth: 2)
                                                        .fill(pressedButton2x ? .white : .clear)

                                                    )
                                            }

                                       
                                            
                           
                                            
                                        }
                                    }
                                    Slider(value: $finalBpm, in: 23...190) { editing in
                                        player?.rate = finalBpm/songBpm
                                        playerMetronome?.rate = finalBpm/songBpm
                                        
                                        
                                    }.padding()
                                
                                    Button("Back To original") {
                                        finalBpm = songBpm
                                        player?.rate = 1
                                        playerMetronome?.rate = 1
                                        
                                    
                                    }

                                }
                            }

                            
                            
                        }.presentationDetents([.height(430), .medium])
                            .presentationDragIndicator(.automatic)

                    }
                    
                    
                    
                    Button{
                       
                    }label: {
                        Image(systemName: "backward.fill").foregroundStyle(.white).font(.system(size: 20))
                    }
                   
                    
                    
                    Button{
                        if isPlaying {stopAudio()}else{playAudio()}
                        
                        // if isPlaying {stopAudio()}else{playAudio()}
                        if isPlayingMetronome{stopAudioMetronome()}else{playAudioMetronome()}
                    }label: {
                        
                        Image(systemName: "play.circle.fill").foregroundStyle(.white).font(.system(size: 50))
                        
                    }
                    
                    
                    Button{
                        
                    }label: {
                        Image(systemName: "forward.fill").foregroundStyle(.white).font(.system(size: 20))
                    }
                    
                }.onAppear(perform: startAudio)
                    .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    updateSlider()
                        
                    }
                
                
            }
        }
            
        
        

        
        
    }
    
    private func seekAudio(to time: TimeInterval) {
        player?.currentTime = time
    }
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
    private func updateSlider() {
        guard let player = player else { return }
        currentTime = player.currentTime
    }
    
    private func startAudio(){
        finalBpm = songBpm
        
        //CodeBlock for Song
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3")
        else{
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.enableRate = true
            player?.volume = 0.7
            totalTime = player?.duration ?? 0.0
            
            
        }catch {
            print("Error")
        }
        
        //CodeBlock for bpm
        guard let url2 = Bundle.main.url(forResource: audioMetronome, withExtension: "mp3")
        else{
            return
        }
        do{
            playerMetronome = try AVAudioPlayer(contentsOf: url2)
            playerMetronome?.prepareToPlay()
            playerMetronome?.enableRate = true
            playerMetronome?.volume = 0
           
          
        }catch{
            print("Error")
        }
        
    }

    private func stopAudio(){
        player?.stop()
        isPlaying = false
        
    }
    
    private func playAudio(){
        player?.play()
        isPlaying = true
    }
    
   private func playAudioMetronome(){
        playerMetronome?.play()
        isPlayingMetronome = true
    }
    
    private func stopAudioMetronome(){
        playerMetronome?.stop()
        isPlayingMetronome = false
        
    }


   

}


#Preview {
    ContentView()
}

