//
//  ContentView.swift
//  SpriteFour
//
//  Created by Haoran Wang on 2023/7/11.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameFour(), debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
