//
//  ContentView.swift
//  physics1-10
//
//  Created by Haoran Wang on 2023/7/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: PlaneScene())
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
