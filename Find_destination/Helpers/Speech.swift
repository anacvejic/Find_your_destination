//
//  Speech.swift
//  Find_destination
//
//  Created by anacvejic on 16/03/2023.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import AVFoundation

class Speech{
    
    static let shared = Speech()
    
    func voiceMessage(message: String){
        
        let speachUtterance = AVSpeechUtterance(string: message)
        speachUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        speachUtterance.rate = 0.4
        
        let synthesiyer = AVSpeechSynthesizer()
        synthesiyer.speak(speachUtterance)
    }
}
