//
//  VectorScpaceUtils.swift
//  arkit-by-example
//
//  Created by Ivan on 29/03/2019.
//  Copyright © 2019 ruanestudios. All rights reserved.
//

import Foundation

extension float4x4 {
    init(_ matrix: SCNMatrix4) {
        self.init([
            float4(matrix.m11, matrix.m12, matrix.m13, matrix.m14),
            float4(matrix.m21, matrix.m22, matrix.m23, matrix.m24),
            float4(matrix.m31, matrix.m32, matrix.m33, matrix.m34),
            float4(matrix.m41, matrix.m42, matrix.m43, matrix.m44)
            ])
    }
}

extension float4 {
    init(_ vector: SCNVector4) {
        self.init(vector.x, vector.y, vector.z, vector.w)
    }

    init(_ vector: SCNVector3) {
        self.init(vector.x, vector.y, vector.z, 1)
    }
}

extension SCNVector4 {
    init(_ vector: float4) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: vector.w)
    }

    init(_ vector: SCNVector3) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: 1)
    }
}

extension SCNVector3 {
    init(_ vector: float4) {
        self.init(x: vector.x / vector.w, y: vector.y / vector.w, z: vector.z / vector.w)
    }
}

func * (left: SCNMatrix4, right: SCNVector3) -> SCNVector3 {
    let matrix = float4x4(left)
    let vector = float4(right)
    let result = matrix * vector

    return SCNVector3(result)
}

extension SCNVector4 {
    public func to3() -> SCNVector3 {
        return SCNVector3(self.x , self.y, self.z)
    }
}

extension SCNVector3 {
    func project(to vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Project(vectorToProject: self, projectionVector: vector)
    }

    var magnitude: Float {
        return SCNVector3Length(self)
    }
}

extension SCNVector3
{
    /**
     * Negates the vector described by SCNVector3 and returns
     * the result as a new SCNVector3.
     */
    func negate() -> SCNVector3 {
        return self * -1
    }

    /**
     * Negates the vector described by SCNVector3
     */
    mutating func negated() -> SCNVector3 {
        self = negate()
        return self
    }

    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }

    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    func normalized() -> SCNVector3 {
        return self / length()
    }

    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0.
     */
    mutating func normalize() -> SCNVector3 {
        self = normalized()
        return self
    }

    /**
     * Calculates the distance between two SCNVector3. Pythagoras!
     */
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }

    /**
     * Calculates the dot product between two SCNVector3.
     */
    func dot(vector: SCNVector3) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }

    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }
}

/**
 * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 * Increments a SCNVector3 with the value of another.
 */
func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 * Decrements a SCNVector3 with the value of another.
 */
func -= (left: inout  SCNVector3, right: SCNVector3) {
    left = left - right
}

/**
 * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 * Multiplies a SCNVector3 with another.
 */
func *= (left: inout  SCNVector3, right: SCNVector3) {
    left = left * right
}

/**
 * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
 * returns the result as a new SCNVector3.
 */
func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/**
 * Multiplies the x and y fields of a SCNVector3 with the same scalar value.
 */
func *= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector * scalar
}

/**
 * Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
 */
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 * Divides a SCNVector3 by another.
 */
func /= (left: inout  SCNVector3, right: SCNVector3) {
    left = left / right
}

/**
 * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
 * returns the result as a new SCNVector3.
 */
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
 * Divides the x, y and z of a SCNVector3 by the same scalar value.
 */
func /= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector / scalar
}

/**
 * Negate a vector
 */
func SCNVector3Negate(vector: SCNVector3) -> SCNVector3 {
    return vector * -1
}


func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
    let scale: Float = SCNVector3DotProduct(projectionVector, right: vectorToProject) / SCNVector3DotProduct(projectionVector, right: projectionVector)
    let v: SCNVector3 = SCNVector3Make(projectionVector.x * scale, projectionVector.y * scale, projectionVector.z * scale)
    return v
}

func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
    return SCNVector3Length(vectorEnd - vectorStart)
}


func SCNVector3DotProduct(_ left: SCNVector3, right: SCNVector3) -> Float {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

func SCNVector3Length(_ vector: SCNVector3) -> Float
{
    return sqrtf(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
}

