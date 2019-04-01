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

        let heights = pointcloud.map{ $0.y }
        result.cenroid = SCNVector3Make(result.cenroid.x,
                                        ((heights.max(by: >) ?? 0) + (heights.min(by: >) ?? 0)) / 2.0,
                                        result.cenroid.z)

        result.height = (heights.max(by: <) ?? 0) - (heights.min(by: <) ?? 0)

        return result
    }

    @objc class func calculateBoundingRectangle(for pointcloud: [SCNVector3]) -> CaliperResult {
        return (0..<90).map { caliperAxisAngle -> CaliperResult in
            let caliperAxis = SCNMatrix4MakeRotation(Degress(caliperAxisAngle).toRadians(), 0, 1, 0) * SCNVector3Make(1, 0, 0)
            let width = mesure(pointcloud: pointcloud, along: caliperAxis)
            let ortogonalAxis = SCNMatrix4MakeRotation(Degress(90).toRadians(), 0, 1, 0) * caliperAxis
            let length = mesure(pointcloud: pointcloud, along: ortogonalAxis)
            return CaliperResult(length: length,
                                 width: width,
                                 height: 0,
                                 cenroid: calculateXZCentroid(of: pointcloud, along: caliperAxis),
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

    private class func calculateXZCentroid(of pointcloud:[SCNVector3], along axis: SCNVector3) -> SCNVector3 {
        let axisBounds = calculateBounds(of: pointcloud, projectedTo: axis)
        let ortogonalAxis = SCNMatrix4MakeRotation(Degress(90).toRadians(), 0, 1, 0) * axis
        let ortogonalAxisBounds = calculateBounds(of: pointcloud, projectedTo: ortogonalAxis)
        return avg(of: [axisBounds.0, axisBounds.1, ortogonalAxisBounds.0, ortogonalAxisBounds.1])
    }

    private class func calculateBounds(of pointcloud: [SCNVector3], projectedTo axis: SCNVector3) -> (SCNVector3, SCNVector3) {
        return pointcloud.flatMap { firstVector -> [(SCNVector3, SCNVector3)] in
            return pointcloud.map { secondVector -> (SCNVector3, SCNVector3) in
                return (firstVector.project(to: axis), secondVector.project(to: axis))
            }
        }.max(by: { $0.0.distance(vector: $0.1) < $1.0.distance(vector: $1.1)}) ?? (SCNVector3Zero, SCNVector3Zero)
    }

    @objc class func avg(of pointcloud: [SCNVector3]) ->  SCNVector3 {
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

typealias Degress = Float

extension Degress {
    func toRadians() -> Float {
        return self * (Float.pi / 180.0)
    }
}
