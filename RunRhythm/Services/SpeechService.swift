//
//  SpeechService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import AVFoundation

final class SpeechService {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synth.speak(utterance)
    }
}

