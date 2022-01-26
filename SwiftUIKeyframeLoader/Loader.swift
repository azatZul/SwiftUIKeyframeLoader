//
//  Loader.swift
//  SwiftUIKeyframeLoader
//
//  Created by Azat Zulkarniaev on 25/01/2022.
//

import SwiftUI

struct LoaderConfiguration {
    let dotsColor: Color
    let dotRadius: CGFloat
    let dotsSpacing: CGFloat
}

struct Loader: View {
    private let config: LoaderConfiguration
    
    @State
    private var progress: Double = 0
    private let animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    
    
    public init(config: LoaderConfiguration) {
        self.config = config
    }
    
    public var body: some View {
        HStack(spacing: config.dotsSpacing) {
            ForEach((0..<3), id: \.self) { index in
                Circle()
                    .fill(self.config.dotsColor)
                    .frame(
                        width: self.config.dotRadius * 2,
                        height: self.config.dotRadius * 2
                    )
                    .modifier(DotScale(index: index, progress: self.progress))
                
            }
        }
        .onAppear {
            withAnimation(self.animation, {
                self.progress = 1
            })
        }
        
    }
}

struct DotScale: GeometryEffect {
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    private let index: Double
    private var progress: Double = 0
    
    private static let numberOfCircles: Double = 3
    private static let relativeDelay: Double = 0.25
    private static let dotScaleMaxAddition: Double = 0.7
    
    private static let relativeDuration: Double = 1 - (Self.numberOfCircles - 1) * Self.relativeDelay
    
    private var startPoint: Double {
        Self.relativeDelay * self.index
    }
    
    private var endPoint: Double {
        self.startPoint + Self.relativeDuration
    }
    
    init(index: Int, progress: Double) {
        self.index = Double(index)
        self.progress = progress
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        if progress <= self.startPoint || progress >= self.endPoint {
            return ProjectionTransform(CGAffineTransform.identity)
        }
        let localProgress = (progress - self.startPoint) / Self.relativeDuration
        
        let multiplier = 2 * (-abs(localProgress - 0.5)) + 1
        let scale = CGFloat(1 + (Self.dotScaleMaxAddition * multiplier))
        let translation: CGFloat = (1 - scale) * size.width / 2
        
        let transform = CGAffineTransform(
            scaleX: scale,
            y: scale
        )
            .concatenating(
                CGAffineTransform(
                    translationX: translation,
                    y: translation
                )
            )
        
        return ProjectionTransform(transform)
    }
}

struct LoaderContentView: View {
    var body: some View {
        Loader(config: .init(dotsColor: .black, dotRadius: 3.5, dotsSpacing: 3))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderContentView()
    }
}
