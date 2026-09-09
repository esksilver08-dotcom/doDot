import SwiftUI

/// Full-screen confetti + "레벨 업!" celebration shown briefly whenever
/// `AppViewModel.levelUpEvent` fires. Auto-dismisses, or tap to dismiss early.
struct LevelUpOverlayView: View {
    let newLevel: Int
    var onDismiss: () -> Void

    @State private var appear = false
    @State private var particles: [Particle] = []

    private let confettiColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    private struct Particle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let delay: Double
        let color: Color
        let rotation: Double
    }

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.35 : 0)

            GeometryReader { proxy in
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: 8, height: 14)
                        .rotationEffect(.degrees(appear ? particle.rotation : 0))
                        .position(
                            x: proxy.size.width / 2 + particle.x * proxy.size.width / 2,
                            y: appear ? proxy.size.height + 40 : proxy.size.height * 0.35
                        )
                        .opacity(appear ? 0 : 1)
                        .animation(.easeIn(duration: 1.4).delay(particle.delay), value: appear)
                }
            }

            VStack(spacing: 8) {
                Text(newLevel >= PlayerCharacter.maxLevel ? "🏆" : "🎉")
                    .font(.system(size: 56))
                Text(newLevel >= PlayerCharacter.maxLevel ? "만렙 달성!" : "레벨 업!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("Lv. \(newLevel)")
                    .font(.title2.bold())
                    .foregroundColor(.yellow)
            }
            .scaleEffect(appear ? 1 : 0.6)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: appear)
        }
        .ignoresSafeArea()
        .onTapGesture { onDismiss() }
        .onAppear {
            particles = (0..<24).map { _ in
                Particle(
                    x: CGFloat.random(in: -1...1),
                    delay: Double.random(in: 0...0.3),
                    color: confettiColors.randomElement() ?? .yellow,
                    rotation: Double.random(in: 180...720)
                )
            }
            appear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onDismiss()
            }
        }
    }
}

#Preview {
    LevelUpOverlayView(newLevel: 5, onDismiss: {})
}
