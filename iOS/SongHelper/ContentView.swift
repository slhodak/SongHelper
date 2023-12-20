//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI


let minorTriad = [0, 3, 7]
let majorTriad = [0, 4, 7]
let halfDim = [0, 3, 6]
let major7 = [0, 4, 7, 11]
let minor7 = [0, 3, 7, 10]
let fullDim = [0, 3, 6, 9]

let majorKeyChords = [
    majorTriad,
    minorTriad,
    minorTriad,
    majorTriad,
    majorTriad,
    minorTriad,
    halfDim,
]


struct ContentView: View {
    @State private var isCameraViewShown = false
    
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    var root = 60 // Middle C
    
    var body: some View {
        CameraView()
    }
}


struct CameraView: View {
    var body: some View {
        HStack {
            Text("We are in the Camera View")
        }
    }
}

