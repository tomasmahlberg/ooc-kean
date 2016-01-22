use collections
use math
use geometry
use unit

FloatEuclidTransformTest: class extends Fixture {
	tolerance := 1.0e-5f
	init: func {
		super("FloatEuclidTransform")
		this add("convolveCenter translations 1", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			kernel := FloatVectorList new(5)
			for (i in 0 .. 5) {
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(i, i, i), FloatRotation3D identity))
				kernel add(0.2f)
			}
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)

			expect(result translation x, is equal to (euclidTransforms[2] translation x) within(this tolerance))
			expect(result translation y, is equal to (euclidTransforms[2] translation y) within(this tolerance))
			expect(result translation z, is equal to (euclidTransforms[2] translation z) within(this tolerance))
			expect(result scaling, is equal to (euclidTransforms[2] scaling) within(this tolerance))

			kernel free()
			euclidTransforms free()
		})
		this add("convolveCenter translations 2", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			kernel := FloatVectorList gaussianKernel(5)
			for (i in 0 .. 5)
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(i, i, i), FloatRotation3D identity))
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)

			expectedResult := 0.0f
			for (i in 0 .. euclidTransforms count)
				expectedResult += kernel[i] * euclidTransforms[i] translation x

			expect(result translation x, is equal to (expectedResult) within(this tolerance))
			expect(result translation y, is equal to (expectedResult) within(this tolerance))
			expect(result translation z, is equal to (expectedResult) within(this tolerance))
			expect(result scaling, is equal to (expectedResult - 1.0f) within(this tolerance))

			kernel free()
			euclidTransforms free()
		})
		this add("convolveCenter rotations", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			quaternions := VectorList<Quaternion> new(5)
			kernel := FloatVectorList gaussianKernel(5)
			for (i in 0 .. 5) {
				rotation := FloatRotation3D createRotationZ(i)
				quaternions add(rotation _quaternion)
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(), rotation))
			}
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)
			expectedRotation := Quaternion weightedMean(quaternions, kernel)

			expect(result rotation _quaternion distance(expectedRotation), is equal to (0.0f) within(this tolerance))

			kernel free()
			quaternions free()
			euclidTransforms free()
		})
		this add("toText", func {
			euclidTransform := FloatEuclidTransform new()
			text := euclidTransform toText() take()
			expect(text, is equal to(t"Translation: 0.00, 0.00, 0.00 Rotation: Real: 1.00 Imaginary: 0.00 0.00 0.00 Scaling: 1.00"))
			text free()
		})
	}
}

FloatEuclidTransformTest new() run() . free()
