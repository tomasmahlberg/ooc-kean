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

use ooc-base
use ooc-math
use ooc-collections

Canvas: abstract class {
	init: func
	drawPoint: func ~withIntPoint2D (position: IntPoint2D) {
		this drawPoint(FloatPoint2D new(position x as Float, position y as Float))
	}
	drawPoint: func ~withFloatPoint2D (position: FloatPoint2D) {
		list := VectorList<FloatPoint2D> new()
		list add(position)
		this drawPoints(list)
		list free()
	}
	drawLine: func ~withFloatPoint2D (start, end: FloatPoint2D) {
		list := VectorList<FloatPoint2D> new()
		list add(start) . add(end)
		this drawLines(list)
		list free()
	}
	drawPoints: abstract func (pointList: VectorList<FloatPoint2D>) { raise("drawPoints unimplemented!") }
	drawLines: abstract func (lines: VectorList<FloatPoint2D>)
	drawBox: virtual func (box: FloatBox2D) {
		positions := VectorList<FloatPoint2D> new()
		positions add(box leftTop)
		positions add(box rightTop)
		positions add(box rightBottom)
		positions add(box leftBottom)
		positions add(box leftTop)
		this drawLines(positions)
		positions free()
	}

	readPixels: virtual func -> ByteBuffer { raise("readPixels unimplemented!") }
}
