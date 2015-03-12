use ooc-math
import svg/Shapes
import math

Orientation: enum {
	Horizontal
	Vertical
}

Axis: class {
	label: String { get set }
	min: Float { get set }
	max: Float { get set }
	tick: Float { get set (length) {
			(value, radix) := Float decomposeToCoefficientAndRadix(length, 1)
			this tick = radix
			if (value != 0) {
				if (length / this tick < 1.1f) {
					this tick /= 10.0f
				} else if (length / this tick < 4.0f) {
					this tick /= 2.0f
				}
			}
		}
	}
	orientation: Orientation { get set }
	fontSize: Int { get set }
	gridOn: Bool { get set }
	precision: Int { get set }
	roundAxisEndpoints: Bool { get set }

	init: func (=orientation) {
		this label = ""
		this fontSize = 10
		this gridOn = true
		this precision = 3
		this roundAxisEndpoints = true
	}

	length: func -> Float {
		result := this max - this min
		result
	}

	getSVG: func (plotAreaSize, axisAreaSize, position, translationToOrigo, scaling: FloatPoint2D) -> String {
		result := ""
		this tick = this length()
		radix := Float getRadix(this length(), this precision)
		if (this orientation == Orientation Horizontal) {
			result = result & "<g desc='X-axis data'>\n" clone()
			labelOffset := FloatPoint2D new(this length() * scaling x / 2.0f, this fontSize + 0.5f * axisAreaSize y)
			numberOffset := FloatPoint2D new(0.0f, this fontSize + 0.2f * axisAreaSize y)
			tickMarkerEndOffset := FloatPoint2D new(0.0f, - axisAreaSize y * 0.1f)
			topTickMarkerStartOffset := FloatPoint2D new(0.0f, - plotAreaSize y)
			result = result & Shapes text(position + labelOffset, this label, this fontSize + 4, "middle")
			if (radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision)) {
				radixOffset := FloatPoint2D new(axisAreaSize x + (plotAreaSize x / plotAreaSize y) * axisAreaSize y / 2, numberOffset y)
				result = result & Shapes text(position + radixOffset, Float getScientificPowerString(radix), this fontSize, "middle")
			}

			tickValue := this getFirstTickValue()
			position x += translationToOrigo x + scaling x * tickValue
			while (tickValue <= this max) {
				result = result & this getTickSVG(tickValue, radix, position, numberOffset, topTickMarkerStartOffset, tickMarkerEndOffset, "middle")
				tickValue += this tick
				position x += scaling x * tick
			}
		} else {
			result = result & "<g desc='Y-axis data'>\n" clone()
			labelOffset := FloatPoint2D new(- 0.6f * axisAreaSize x, - this length() * scaling y / 2.0f)
			numberOffset := FloatPoint2D new(-0.2f * axisAreaSize x, this fontSize / 2)
			tickMarkerEndOffset := FloatPoint2D new(axisAreaSize x * 0.1f, 0.0f)
			rightTickMarkerStartOffset := FloatPoint2D new(plotAreaSize x, 0.0f)
			result = result & "<g desc='rotated Y-axis' transform='rotate(-90," clone() & (position x + labelOffset x) toString() & "," clone() & (position y + labelOffset y) toString() & ")'>\n" clone()
			result = result & Shapes text(position + labelOffset, this label, this fontSize + 4, "middle")
			result = result & "</g>\n" clone()
			if (radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision)) {
				radixOffset := FloatPoint2D new(numberOffset x, - axisAreaSize y - (plotAreaSize y / plotAreaSize x) * axisAreaSize x / 2 + this fontSize / 2)
				result = result & Shapes text(position + radixOffset, Float getScientificPowerString(radix), this fontSize, "end")
			}

			tickValue := this getFirstTickValue()
			position y += translationToOrigo y - plotAreaSize y - scaling y * tickValue
			while (tickValue <= this max) {
				result = result & this getTickSVG(tickValue, radix, position, numberOffset, rightTickMarkerStartOffset, tickMarkerEndOffset, "end")
				tickValue += this tick
				position y += - scaling y * tick
			}
		}
		result = result & "</g>\n" clone()
		result
	}

	getFirstTickValue: func -> Float {
		result: Float
		if ((this min < this tick && this min > 0.0f) || (this min > this tick && this min > 0.0f && this min < 1.0f) )
			result = this min + (this tick - Float modulo(this min, this tick))
		else
			result = this min - Float modulo(this min, this tick)
		result
	}

	getTickSVG: func (tickValue, radix: Float, position, numberOffset, tickMarkerOnOtherSideOffset, tickMarkerEndOffset: FloatPoint2D, textAnchor: String) -> String {
		result := "<g desc='" clone() & tickValue toString() & "'>\n" clone()
		if (this gridOn)
			result = result & Shapes line(position, position + tickMarkerOnOtherSideOffset, "grey", FloatPoint2D new(5,5))
		result = result & Shapes line(position, position + tickMarkerEndOffset, "black")
		result = result & Shapes line(position + tickMarkerOnOtherSideOffset, position + tickMarkerOnOtherSideOffset - tickMarkerEndOffset, "black")
		tickValue = radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision) ? (tickValue / radix) : tickValue
		tempTick := tickValue toString()
		tempTickInt := tickValue as Int toString()
		result = result & Shapes text(position + numberOffset, tickValue == floor(tickValue) ? tempTickInt : tempTick, this fontSize, textAnchor)
		tempTick free()
		tempTickInt free()
		result = result & "</g>\n" clone()
		result
	}

	roundEndpoints: func {
		if (this roundAxisEndpoints) {
			this min = Float roundToValueDigits(this min, 2, false)
			this max = Float roundToValueDigits(this max, 2, true)
		}
	}
}
