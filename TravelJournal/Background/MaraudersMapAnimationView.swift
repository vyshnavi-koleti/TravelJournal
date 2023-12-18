import SwiftUI
import Foundation
import Combine



struct Footstep: Identifiable, Hashable {
    let id = UUID()
    var position: CGPoint

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }

    static func == (lhs: Footstep, rhs: Footstep) -> Bool {
        lhs.id == rhs.id
    }
}





struct FootprintView: View {
    enum Foot {
        case left, right
    }

    var foot: Foot

    var body: some View {
        Path { path in
            // Common parameters
            let width: CGFloat = 10
            let height: CGFloat = 12
            let gapHeight: CGFloat = 4
            let circleSize: CGFloat = 10

            // Top part (ellipse)
            let ellipseOffsetX: CGFloat = foot == .left ? 5 : 0
            let topEllipseRect = CGRect(x: ellipseOffsetX, y: 0, width: width, height: height)
            path.addEllipse(in: topEllipseRect)

            // Bottom part (inverted half-circle)
            let circleOffsetX: CGFloat = foot == .left ? 5 : 0
            let bottomCircleRect = CGRect(x: circleOffsetX, y: topEllipseRect.maxY + gapHeight, width: circleSize, height: circleSize)
            path.addArc(center: CGPoint(x: bottomCircleRect.midX, y: bottomCircleRect.minY), radius: bottomCircleRect.width / 2, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        }
        .fill(Color(hex: "#355D48"))
        .frame(width: 20, height: 20)
    }
}



struct MaraudersMapAnimationView: View {
    @State private var footsteps: [Footstep] = []
    let screenSize: CGSize
    let maxFootsteps: Int = 7 // Adjusted for pairs

    var body: some View {
        ZStack {
//            Color(hex: "#e6dfd0")
//                .edgesIgnoringSafeArea(.all)
            ForEach(footsteps) { footstep in
                FootprintView(foot: .left)
                    .position(footstep.position)
                FootprintView(foot: .right)
                    .position(CGPoint(x: footstep.position.x + 20, y: footstep.position.y + 10)) // Offset for the right foot
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                addFootstepPair()
                if footsteps.count > maxFootsteps {
                    footsteps.removeFirst(2) // Remove pairs
                }
            }
        }
    }

    private func addFootstepPair() {
        let newFootstep = Footstep(position: CGPoint(x: CGFloat.random(in: 0...screenSize.width - 20), y: CGFloat.random(in: 0...screenSize.height - 10)))
        footsteps.append(newFootstep)
    }
}
