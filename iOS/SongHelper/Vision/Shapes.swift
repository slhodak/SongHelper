
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
            // Scale and mirror point
            let x = (point.x * -size.width) + size.width
            let y = (point.y * -size.height) + size.height
            
            path.addEllipse(in: CGRect(
                x: x,
                y: y,
                width: dotRadius,
                height: dotRadius)
            )
        }
        
        return path
    }
}
