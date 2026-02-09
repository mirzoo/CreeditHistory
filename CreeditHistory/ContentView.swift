//
//  ContentView.swift
//  CreeditHistory
//
//  Created by Mirzomansur Okhunov on 08.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Открыть") {
                isPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $isPresented) {
            FullScreenModalView()
        }
    }
}

// MARK: - Full Screen Modal

struct FullScreenModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var score: Double = 589
    @State private var displayedScore: Int = 589

    private let maxScore = 999

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Средние шансы получить кредит на\u{00A0}нужную сумму и\u{00A0}по\u{00A0}низкой ставке")
                        .font(.system(size: 17))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 32)

                    CreditScoreGaugeView(score: score, maxScore: maxScore)
                        .frame(height: 170)
                        .overlay {
                            Text("\(displayedScore)")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }
                        .padding(.bottom, -8)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Почему такой рейтинг")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .center)

                        VStack(spacing: 12) {
                            ReasonCardView(
                                icon: "Bad",
                                text: "2\u{00A0}месяца назад была просрочка",
                                iconBackground: Color(red: 0.35, green: 0.12, blue: 0.13)
                            )
                            ReasonCardView(
                                icon: "Good",
                                text: "Внесли вовремя 99% платежей",
                                iconBackground: .white.opacity(0.15)
                            )
                            ReasonCardView(
                                icon: "Normal",
                                text: "Выплатили 1\u{00A0}000\u{00A0}000\u{00A0}₽ по\u{00A0}всем кредитам",
                                iconBackground: Color(red: 0.38, green: 0.31, blue: 0.14)
                            )
                            ReasonCardView(
                                icon: "Normal",
                                text: "Ваш самый длинный кредит —\u{00A0}всего 2\u{00A0}года",
                                iconBackground: Color(red: 0.38, green: 0.31, blue: 0.14)
                            )
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .onAppear {
                let customEasing = Animation.timingCurve(0.66, 0, 0.34, 1, duration: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(customEasing) {
                        score = 970
                        displayedScore = 970
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(customEasing) {
                        score = 235
                        displayedScore = 235
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(customEasing) {
                        score = 589
                        displayedScore = 589
                    }
                }
            }
            .navigationTitle("Кредитный рейтинг")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Credit Score Gauge

struct CreditScoreGaugeView: View, Animatable {
    var score: Double
    let maxScore: Int

    var animatableData: Double {
        get { score }
        set { score = newValue }
    }

    private let arcStartAngle: Double = 150
    private let arcSweep: Double = 240

    private static let gradientStops: [(location: Double, r: Double, g: Double, b: Double)] = [
        (0.11, 0.976, 0.478, 0.478),
        (0.34, 0.980, 0.600, 0.482),
        (0.38, 0.984, 0.906, 0.490),
        (0.56, 0.984, 0.906, 0.490),
        (0.61, 0.400, 0.835, 0.506),
        (0.79, 0.329, 0.796, 0.443),
        (0.89, 0.247, 0.753, 0.373)
    ]

    private static let scoreToArc: [(score: Double, arc: Double)] = [
        (1, 0.0),
        (300, 0.38),
        (600, 0.56),
        (900, 0.89),
        (999, 1.0)
    ]

    private var progress: Double {
        let s = min(max(score, 1), 999)
        let map = Self.scoreToArc

        guard let upperIndex = map.firstIndex(where: { $0.score >= s }) else {
            return 1.0
        }

        if upperIndex == 0 {
            return map[0].arc
        }

        let lower = map[upperIndex - 1]
        let upper = map[upperIndex]
        let fraction = (s - lower.score) / (upper.score - lower.score)
        return lower.arc + (upper.arc - lower.arc) * fraction
    }

    private var dotColor: Color {
        let t = progress
        let stops = Self.gradientStops

        guard let upperIndex = stops.firstIndex(where: { $0.location >= t }) else {
            let last = stops.last!
            return Color(red: last.r, green: last.g, blue: last.b)
        }

        if upperIndex == 0 {
            let first = stops.first!
            return Color(red: first.r, green: first.g, blue: first.b)
        }

        let lower = stops[upperIndex - 1]
        let upper = stops[upperIndex]
        let range = upper.location - lower.location
        let fraction = range > 0 ? (t - lower.location) / range : 0

        return Color(
            red: lower.r + (upper.r - lower.r) * fraction,
            green: lower.g + (upper.g - lower.g) * fraction,
            blue: lower.b + (upper.b - lower.b) * fraction
        )
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.5)
            let radius: CGFloat = 69

            let arcGradient = AngularGradient(
                stops: [
                    .init(color: Color(red: 0.976, green: 0.478, blue: 0.478), location: 0.11),
                    .init(color: Color(red: 0.980, green: 0.600, blue: 0.482), location: 0.34),
                    .init(color: Color(red: 0.984, green: 0.906, blue: 0.490), location: 0.38),
                    .init(color: Color(red: 0.984, green: 0.906, blue: 0.490), location: 0.56),
                    .init(color: Color(red: 0.400, green: 0.835, blue: 0.506), location: 0.61),
                    .init(color: Color(red: 0.329, green: 0.796, blue: 0.443), location: 0.79),
                    .init(color: Color(red: 0.247, green: 0.753, blue: 0.373), location: 0.89)
                ],
                center: .center,
                startAngle: .degrees(arcStartAngle),
                endAngle: .degrees(arcStartAngle + arcSweep)
            )

            ZStack {
                // Main arc
                ArcShape(
                    startAngle: .degrees(arcStartAngle),
                    endAngle: .degrees(arcStartAngle + arcSweep)
                )
                .stroke(arcGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: radius * 2, height: radius * 2)
                .position(center)

                // Indicator dot (color matches gradient position)
                let dotAngle = (arcStartAngle + progress * arcSweep) * .pi / 180
                Circle()
                    .fill(dotColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.11, green: 0.11, blue: 0.12), lineWidth: 4)
                    )
                    .position(
                        x: center.x + cos(dotAngle) * radius,
                        y: center.y + sin(dotAngle) * radius
                    )

                // Glow arc (blurred, on top)
                ArcShape(
                    startAngle: .degrees(arcStartAngle),
                    endAngle: .degrees(arcStartAngle + arcSweep)
                )
                .stroke(arcGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
                .blur(radius: 16)
                .opacity(0.6)
                .allowsHitTesting(false)

                // Min label "1"
                let minAngle = arcStartAngle * .pi / 180
                Text("1")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
                    .position(
                        x: center.x + cos(minAngle) * (radius + 20),
                        y: center.y + sin(minAngle) * (radius + 20)
                    )

                // Max label
                let maxAngle = (arcStartAngle + arcSweep) * .pi / 180
                Text("\(maxScore)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
                    .position(
                        x: center.x + cos(maxAngle) * (radius + 20) + 8,
                        y: center.y + sin(maxAngle) * (radius + 20)
                    )
            }
        }
    }
}

// MARK: - Arc Shape

struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// MARK: - Reason Card

struct ReasonCardView: View {
    let icon: String
    let text: String
    let iconBackground: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }

            Text(text)
                .font(.body)
                .foregroundStyle(Color(red: 0.96, green: 0.97, blue: 0.97))
                .lineLimit(2)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}
