//
//  ContentView.swift
//  SpriteTwo
//
//  Created by Haoran Wang on 2023/7/9.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameTwo()).ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
