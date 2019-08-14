//
//  SCNVector3+Extensions.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 8/31/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

func SCNVector3FromSIMDFloat4(_ float4: simd_float4) -> SCNVector3 {
    return SCNVector3(x: float4.x, y: float4.y, z: float4.z)
}

extension SCNVector3 {

    var simdVector3: simd_float3 {
        return simd_make_float3(self.x, self.y, self.z)
    }

}
