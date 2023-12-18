import SwiftUI
import Foundation
import Combine

struct FootstepsBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            MaraudersMapAnimationView(screenSize: geometry.size)
        }
    }
}
