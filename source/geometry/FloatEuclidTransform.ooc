//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use collections
use math
import FloatVector3D
import FloatRotation3D
import FloatTransform2D
import FloatTransform3D
import Quaternion

FloatEuclidTransform: cover {
	rotation: FloatRotation3D
	translation: FloatVector3D
	scaling: Float

	inverse ::= This new(-this translation, this rotation inverse, 1.0f / this scaling)
	transform ::= FloatTransform3D createScaling(this scaling, this scaling, 1.0f) * FloatTransform3D createTranslation(this translation) * this rotation transform

	init: func@ ~default { this init(FloatVector3D new(), FloatRotation3D identity, 1.0f) }
	init: func@ ~translationAndRotation (translation: FloatVector3D, rotation: FloatRotation3D) { this init(translation, rotation, 1.0f) }
	init: func@ ~full (=translation, =rotation, =scaling)
	init: func@ ~fromTransform (transform: FloatTransform2D) {
		rotationZ := atan(- transform d / transform a)
		scaling := ((transform a * transform a + transform b * transform b) sqrt() + (transform d * transform d + transform e * transform e) sqrt()) / 2.0f
		this init(FloatVector3D new(transform g, transform h, 0.0f), FloatRotation3D createRotationZ(rotationZ), scaling)
	}
	toString: func -> String {
		"Translation: " << this translation toString() >> " Rotation: " & this rotation toString() >> " Scaling: " & this scaling toString()
	}
	toText: func -> Text {
		t"Translation: " + this translation toText() + t" Rotation: " + this rotation toText() + t" Scaling: " + this scaling toText()
	}

	operator * (other: This) -> This { This new(this translation + other translation, this rotation * other rotation, this scaling * other scaling) }
	operator == (other: This) -> Bool {
		this translation == other translation &&
		this rotation == other rotation &&
		this scaling == other scaling
	}

	kean_math_floatEuclidTransform_toFloatTransform3D: unmangled func -> FloatTransform3D { this transform }

	convolveCenter: static func (euclidTransforms: VectorList<This>, kernel: FloatVectorList) -> This {
		result := This new()
		if (euclidTransforms count > 0) {
			result scaling = 0.0f
			quaternions := VectorList<Quaternion> new(euclidTransforms count)
			for (i in 0 .. euclidTransforms count) {
				euclidTransform := euclidTransforms[i]
				weight := kernel[i]
				result translation = result translation + euclidTransform translation * weight
				result scaling = result scaling + euclidTransform scaling * weight
				rotation := euclidTransform rotation
				quaternions add(rotation _quaternion)
			}
			result rotation = FloatRotation3D new(Quaternion weightedMean(quaternions, kernel))
			quaternions free()
		}
		result
	}
}
