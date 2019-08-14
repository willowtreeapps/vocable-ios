//
//  SCNVector4+Extensions.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 8/31/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

extension SCNVector4 {

    init(_ simdFloat3: simd_float3, w: Float) {
        self.init(simdFloat3.x, simdFloat3.y, simdFloat3.z, w)
    }

    var vector3: SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }

    var simdVector4: simd_float4 {
        return simd_make_float4(self.x, self.y, self.z, self.w)
    }

}
