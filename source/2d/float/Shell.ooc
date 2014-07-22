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
import math
import ../../FloatExtension
import Point
import Size
import Box
import text/StringTokenizer
import structs/ArrayList

Shell : cover {
	left, right, top, bottom: Float
	LeftTop: Point { get { Point new(this left, this top) } }
	Size: Size { get { Size new(this left + this right, this top + this bottom) } }
	Balance: Point { get { Point new(this right - this left, this bottom - this top) } }
	IsZero: Bool { get { this left == 0 && this right == 0 && this top == 0 && this bottom == 0 } }
	NotZero: Bool { get { this left != 0 && this right != 0 && this top != 0 && this bottom != 0 } }
	init: func@ (=left, =right, =top, =bottom) { }
	init: func@ ~fromFloat(value: Float) {
		this init(value, value)
	}
	init: func@ ~fromFloats(x, y: Float) {
		this init(x, x, y, y)
	}
	init: func@ ~default() {
		this init(0.0f)
	}
	decrease: func (size: Size) -> Box {
		Box new(this left, this top, size width - this left - this right, size height - this top - this bottom)
	}
	increase: func (size: Size) -> Box {
		Box new(-this left, -this right, size width + this left + this right, size height + this top + this bottom)
	}
	decrease: func ~byBox (box: Box) -> Box {
		Box new(box leftTop x + this left, box leftTop y + this top, box size width - this left - this right, box size height - this top - this bottom)
	}
	increase: func ~byBox (box: Box) -> Box {
		Box new(box leftTop x - this left, box leftTop y - this top, box size width + this left + this right, box size height + this top + this bottom)
	}
	operator + (other: This) -> This {
		This new(this left + other left, this right + other right, this top + other top, this bottom + other bottom)
	}
	operator - (other: This) -> This {
		This new(this left - other left, this right - other right, this top - other top, this bottom - other bottom)
	}
	operator / (other: Float) -> This {
		This new(this left / other, this right / other, this top / other, this bottom / other)
	}
	maximum: func (other: This) -> This {
		This new(this left maximum(other left), this right maximum(other right), this top maximum(other top), this bottom maximum(other bottom))
	}
	minimum: func (other: This) -> This {
		This new(this left minimum(other left), this right minimum(other right), this top minimum(other top), this bottom minimum(other bottom))
	}
	operator == (other: This) -> Bool {
		this left == other left && this right == other right && this top == other top && this bottom == other bottom
	}
	operator != (other: This) -> Bool {
		!(this == other)
	}
	operator as -> String {
		this toString()
	}
	toString: func -> String {
		"#{this left}, #{this right}, #{this top}, #{this bottom}"
	}
	parse: static func(input: String) -> This {
		array := input split(',')
		This new(array[0] toFloat(), array[1] toFloat(), array[2] toFloat(), array[3] toFloat())
	}
}
