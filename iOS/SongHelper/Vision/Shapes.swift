
//  Shapes.swift
//
//  Created by Sam Hodak
//

import Foundation
import SwiftUI


struct Dot: Shape {
    var points: [CGPoint]
    var size: CGSize
    var dotRadius: CGFloat = 10
    
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
        
        return path
    }
}
