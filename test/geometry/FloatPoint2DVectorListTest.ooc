/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

use geometry
use unit

FloatPoint2DVectorListTest: class extends Fixture {
	init: func {
		super("FloatPoint2DVectorList")
		tolerance := 0.0001f
		this add("sum and mean", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			list add(FloatPoint2D new(7.0f, -1.0f))
			sum := list sum()
			mean := list mean()
			expect(sum x, is equal to(16.0f) within(tolerance))
			expect(sum y, is equal to(1.0f) within(tolerance))
			expect(mean x, is equal to(4.0f) within(tolerance))
			expect(mean y, is equal to(0.25f) within(tolerance))
			list free()
		})
		this add("getX, getY", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			list add(FloatPoint2D new(7.0f, -1.0f))
			xValues := list getX()
			yValues := list getY()
			expect(xValues sum, is equal to(16.0f) within(tolerance))
			expect(yValues sum, is equal to(1.0f) within(tolerance))
			list free()
			xValues free()
			yValues free()
		})
		this add("+ operator", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			added := list + FloatPoint2D new(1.0f, 1.0f)
			expect(added getX() sum, is equal to(12.0f) within(tolerance))
			expect(added getY() sum, is equal to(5.0f) within(tolerance))
			list free()
		})
		this add("resampleLinear", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(-1.5f, 2.0f))
			list add(FloatPoint2D new(-1.0f, 1.0f))
			list add(FloatPoint2D new(1.0f, -5.0f))
			resampledList := list resampleLinear(-1.1f, 1.1f, 0.5f)
			expect(resampledList count, is equal to(6))
			expect(resampledList[0] x, is equal to(-1.1f) within(tolerance))
			expect(resampledList[0] y, is equal to(1.2f) within(tolerance))
			expect(resampledList[1] x, is equal to(-0.6f) within(tolerance))
			expect(resampledList[1] y, is equal to(-0.2f) within(tolerance))
			expect(resampledList[2] x, is equal to(-0.1f) within(tolerance))
			expect(resampledList[2] y, is equal to(-1.7f) within(tolerance))
			expect(resampledList[3] x, is equal to(0.4f) within(tolerance))
			expect(resampledList[3] y, is equal to(-3.2f) within(tolerance))
			expect(resampledList[4] x, is equal to(0.9f) within(tolerance))
			expect(resampledList[4] y, is equal to(-4.7f) within(tolerance))
			expect(resampledList[5] x, is equal to(1.4f) within(tolerance))
			expect(resampledList[5] y, is equal to(-5.0f) within(tolerance))
			list free()
			resampledList free()
		})
		this add("resampleLinear, boundary", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 1.0f))
			list add(FloatPoint2D new(2.0f, 2.0f))
			resampledList := list resampleLinear(0.0f, 3.0f, 0.5f)
			expect(resampledList count, is equal to(7))
			expect(resampledList[0] y, is equal to(1.0f) within(tolerance))
			expect(resampledList[1] y, is equal to(1.0f) within(tolerance))
			expect(resampledList[2] y, is equal to(1.0f) within(tolerance))
			expect(resampledList[3] y, is equal to(1.5f) within(tolerance))
			expect(resampledList[4] y, is equal to(2.0f) within(tolerance))
			expect(resampledList[5] y, is equal to(2.0f) within(tolerance))
			expect(resampledList[6] y, is equal to(2.0f) within(tolerance))
			list free()
			resampledList free()
		})
		this add("resampleLinear, duplicate points", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 1.0f))
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(1.5f, 3.0f))
			resampledList := list resampleLinear(0.5f, 1.5f, 0.5f)
			expect(resampledList count, is equal to(3))
			expect(resampledList[0] y, is equal to(1.0f) within(tolerance))
			expect(resampledList[1] y, is equal to(1.0f) within(tolerance))
			expect(resampledList[2] y, is equal to(3.0f) within(tolerance))
			list free()
			resampledList free()
		})
		this add("sort by x", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(2.0f, 1.0f))
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.5f, 3.0f))
			list add(FloatPoint2D new(5.0f, 5.0f))
			list add(FloatPoint2D new(-3.0f, 6.0f))
			list sortByX()
			expect(list[0] x, is equal to(-3.0f) within(tolerance))
			expect(list[0] y, is equal to(6.0f) within(tolerance))
			expect(list[1] x, is equal to(1.0f) within(tolerance))
			expect(list[1] y, is equal to(2.0f) within(tolerance))
			expect(list[2] x, is equal to(2.0f) within(tolerance))
			expect(list[2] y, is equal to(1.0f) within(tolerance))
			expect(list[3] x, is equal to(3.5f) within(tolerance))
			expect(list[3] y, is equal to(3.0f) within(tolerance))
			expect(list[4] x, is equal to(5.0f) within(tolerance))
			expect(list[4] y, is equal to(5.0f) within(tolerance))
			list free()
		})
		this add("max and min", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(2.0f, 1.0f))
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.5f, 3.0f))
			list add(FloatPoint2D new(5.0f, 5.0f))
			list add(FloatPoint2D new(-3.0f, 6.0f))
			max := list maxValues()
			min := list minValues()
			expect(max x, is equal to(5.0f) within(tolerance))
			expect(max y, is equal to(6.0f) within(tolerance))
			expect(min x, is equal to(-3.0f) within(tolerance))
			expect(min y, is equal to(1.0f) within(tolerance))
		})
		this add("toText", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 4.0f))
			text := list toText() take()
			expect(text, is equal to(t"1.00, 2.00\n3.00, 4.00"))
			text free()
			list free()
		})
		this add("median and mean", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(2.0f, 1.0f))
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.5f, 5.0f))
			list add(FloatPoint2D new(5.0f, 4.0f))
			list add(FloatPoint2D new(6.0f, 3.0f))
			medianPosition := list medianPosition()
			expect(medianPosition x, is equal to(3.5f) within(tolerance))
			expect(medianPosition y, is equal to(3.0f) within(tolerance))

			indices := VectorList<Int> new()
			indices add(0); indices add(1); indices add(4)
			mean := list getMean~indices(indices)
			expect(mean x, is equal to(3.0f) within(tolerance))
			expect(mean y, is equal to(2.0f) within(tolerance))
		})
	}
}

FloatPoint2DVectorListTest new() run() . free()
