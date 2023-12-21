//
//  Shapes.swift
//
//  Created by Sam Hodak
//

import Foundation
import SwiftUI


struct Dot: Shape {
    var points: [CGPoint]
    var size: CGSize
    var dotRadius: CGFloat = 5 // Adjust the dot size as needed

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for point in points {
            path.addEllipse(in: CGRect(
                x: point.x,
                y: point.y,
                width: dotRadius,
                height: dotRadius)
            )
        }
        
        return transformed(path: path)
    }
    
    private func transformed(path: Path) -> Path {
        return path
            .applying(
                CGAffineTransform.identity
                    .scaledBy(x: size.width, y: size.height))
            .applying(
                CGAffineTransform(scaleX: -1, y: -1)
                    .translatedBy(x: -size.width, y: -size.height))
    }
}
