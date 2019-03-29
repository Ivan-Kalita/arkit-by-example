//
//  ARUtils.swift
//  arkit-by-example
//
//  Created by Ivan on 27/03/2019.
//

import Foundation

@objc class Utils: NSObject {
    @objc class func calculateBoundingRectangle(for pointcloud: [SCNVector3]) -> CaliperResult {
        return (0..<90).map { caliperAxisAngle -> CaliperResult in
            let caliperAxis = SCNMatrix4MakeRotation(Float(caliperAxisAngle), 0, 1, 0) * SCNVector4Make(1, 0, 0, 1)
            let length = mesure(pointcloud: pointcloud, along: caliperAxis.to3())
            let ortogonalAxis = SCNMatrix4MakeRotation(90, 0, 1, 0) * caliperAxis
            let width = mesure(pointcloud: pointcloud, along: ortogonalAxis.to3())
            return CaliperResult(length: length, width: width, rotation: Float(caliperAxisAngle))
        }.min { (this, other) -> Bool in
            return (this.length + this.width) < (other.length + other.width)
        } ?? CaliperResult(length: 0, width: 0, rotation: 0)
    }

    @objc class func mesure(pointcloud:[SCNVector3], along axis: SCNVector3) -> Float {
        return pointcloud.flatMap { firstVector -> [Float] in
            return pointcloud.map { secondVector -> Float in
                return firstVector.project(to: axis).distance(vector: secondVector.project(to: axis))
            }
        }.max(by: >) ?? 0
    }

}
