//
//  ARUtils.swift
//  arkit-by-example
//
//  Created by Ivan on 27/03/2019.
//

import Foundation

@objc class ARUtils: NSObject {
    @objc class func calculateBoundingBox(for pointcloud: [SCNVector3]) -> CaliperResult {
        var result = calculateBoundingRectangle(for: pointcloud)
        result.cenroid = centroid(of: pointcloud)

        let heights = pointcloud.map { return $0.y }

        result.height = (heights.max(by: <) ?? 0) - (heights.min(by: <) ?? 0)

        return result
    }

    @objc class func calculateBoundingRectangle(for pointcloud: [SCNVector3]) -> CaliperResult {
        return (0..<90).map { caliperAxisAngle -> CaliperResult in
            let caliperAxis = SCNMatrix4MakeRotation(Float(caliperAxisAngle), 0, 1, 0) * SCNVector4Make(1, 0, 0, 1)
            let length = mesure(pointcloud: pointcloud, along: caliperAxis.to3())
            let ortogonalAxis = SCNMatrix4MakeRotation(90, 0, 1, 0) * caliperAxis
            let width = mesure(pointcloud: pointcloud, along: ortogonalAxis.to3())
            return CaliperResult(length: length,
                                 width: width,
                                 height: 0,
                                 cenroid: SCNVector3Zero,
                                 rotation2D: Float(caliperAxisAngle))
        }.min { (this, other) -> Bool in
            return (this.length + this.width) < (other.length + other.width)
        } ?? CaliperResult(length: 0, width: 0, height: 0, cenroid: SCNVector3Zero, rotation2D: 0)
    }

    @objc class func mesure(pointcloud:[SCNVector3], along axis: SCNVector3) -> Float {
        return pointcloud.flatMap { firstVector -> [Float] in
            return pointcloud.map { secondVector -> Float in
                return firstVector.project(to: axis).distance(vector: secondVector.project(to: axis))
            }
        }.max(by: <) ?? 0
    }

    @objc class func centroid(of pointcloud: [SCNVector3]) ->  SCNVector3 {
        var avg = SCNVector3Zero
        for point in pointcloud {
            avg.x += point.x
            avg.y += point.y
            avg.z += point.z
        }
        return SCNVector3Make(avg.x / Float(pointcloud.count),
                              avg.y / Float(pointcloud.count),
                              avg.z / Float(pointcloud.count))
    }
}
