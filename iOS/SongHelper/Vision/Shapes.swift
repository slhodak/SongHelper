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
            let dotRect = CGRect(x: point.x - dotRadius/2, y: point.y - dotRadius/2, width: dotRadius, height: dotRadius)
            path.addEllipse(in: dotRect)
        }
        
        return transformed(path: path)
    }
    
    private func transformed(path: Path) -> Path {
        return path
            .applying(
                CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(
                CGAffineTransform(scaleX: -1, y: -1)
                    .translatedBy(x: -size.width, y: -size.height))
    }
}
