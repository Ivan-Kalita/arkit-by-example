//
//  ARUtils.swift
//  arkit-by-example
//
//  Created by Ivan on 27/03/2019.
//  Copyright © 2019 ruanestudios. All rights reserved.
//

import Foundation

@objc class Utils: NSObject {
    @objc class func calculateBoundingRectangle(for pointcloud: [SCNVector3]) -> CaliperResult {
        return CaliperResult(length: 0, width: 0, rotation: 0)
    }
}
