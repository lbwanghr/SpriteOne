//
//  ContentView.swift
//  SpriteThree
//
//  Created by Haoran Wang on 2023/7/10.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameThree(), debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
