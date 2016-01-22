use base
use draw
use geometry
use unit

RasterMonochromeTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterMonochrome")
		this add("equals 1", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 equals(image1), is true)
			expect(image1 equals(image2), is false)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterMonochrome_test.png"
			image1 := RasterMonochrome open(this sourceFlower)
			image1 save(output)
			image2 := RasterMonochrome open(output)
			expect(image1 equals(image2), is true)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, same image", func {
			image1 := RasterMonochrome open(this sourceSpace)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("getRow and getColumn", func {
			size := IntVector2D new(500, 256)
			image := RasterMonochrome new(size)
			for (row in 0 .. size y)
				for (column in 0 .. size x)
					image[column, row] = ColorMonochrome new(row)
			for (column in 0 .. size x) {
				columnData := image getColumn(column)
				expect(columnData count, is equal to(size y))
				for (i in 0 .. columnData count)
					expect(columnData[i] as Int, is equal to(i))
			}
			for (row in 0 .. size y) {
				rowData := image getRow(row)
				expect(rowData count, is equal to(size x))
				for (i in 0 .. rowData count)
					expect(rowData[i] as Int, is equal to(row))
			}
			image referenceCount decrease()
		})
		this add("resize", func {
			outputFast := "test/draw/output/RasterMonochrome_upscaledFast.png"
			outputSmooth := "test/draw/output/RasterMonochrome_upscaledSmooth.png"
			size := IntVector2D new(13, 5)
			image := RasterMonochrome open(this sourceFlower)
			image2 := image resizeTo(image size / 2)
			expect(image2 size == image size / 2)
			image3 := image2 resizeTo(image size)
			expect(image3 size == image size)
			expect(image distance(image3) < image size x / 10)
			image3 referenceCount decrease()
			image3 = image2 resizeTo(size)
			expect(image3 size == size)
			image3 referenceCount decrease()
			image2 referenceCount decrease()
			image2 = image resizeTo(image size / 4)
			image referenceCount decrease()
			image = image2 resizeTo(image2 size * 4, InterpolationMode Fast)
			image save(outputFast)
			image referenceCount decrease()
			image = image2 resizeTo(image2 size * 4, InterpolationMode Smooth)
			image save(outputSmooth)
			image referenceCount decrease()
			image2 referenceCount decrease()
			outputFast free()
			outputSmooth free()
		})
		this add("copy", func {
			image := RasterMonochrome open(this sourceFlower)
			image2 := image copy()
			expect(image size == image2 size)
			expect(image stride, is equal to(image2 stride))
			expect(image transform == image2 transform)
			expect(image coordinateSystem == image2 coordinateSystem)
			expect(image crop == image2 crop)
			expect(image wrap, is equal to(image2 wrap))
			expect(image referenceCount != image2 referenceCount)
			image referenceCount decrease()
			image2 referenceCount decrease()
		})
		this add("color monochrome from unsigned types", func {
			image := RasterMonochrome new(IntVector2D new(10, 10))
			value: UInt = 128
			value32: UInt32 = 128
			value64: UInt64 = 128
			image[0, 0] = ColorMonochrome new(value32)
			image[0, 1] = ColorMonochrome new(value64)
			image[0, 2] = ColorMonochrome new(value)
			expect(image[0, 0] y as Int, is equal to(value32 as Int))
			expect(image[0, 1] y as Int, is equal to(value64 as Int))
			expect(image[0, 2] y as Int, is equal to(value as Int))
			image referenceCount decrease()
		})
		/*this add("distance, convertFrom RasterBgra", func {
			source := this sourceFlower
			output := "test/draw/output/RasterBgrToMonochrome.png"
			image1 := RasterMonochrome open(source)
			image2 := RasterMonochrome convertFrom(RasterBgra open(source))
			expect(image1 distance(image2), is equal to(0.0f))
		})*/
	}
}

RasterMonochromeTest new() run() . free()
