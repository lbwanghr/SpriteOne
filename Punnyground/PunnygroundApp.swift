import SwiftUI
import SpriteKit

@main
struct PunnygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: gameScene).ignoresSafeArea()
    }
}
