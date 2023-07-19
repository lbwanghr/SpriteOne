//
//  animation0App.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/7.
//

import SwiftUI
import SpriteKit

@main
struct animation0App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            SpriteView(scene: loadScene)
        }
        .ignoresSafeArea()
    }
}
