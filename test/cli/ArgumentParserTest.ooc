use cli
use collections
use base
use unit

ArgumentParserTest: class extends Fixture {
	init: func {
		super("ArgumentParser")
		this add("No parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"--arga")
			inputList add(t"-b")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentBValue: Text
			parser add(t"arga", 'a', Event new(func { argumentAValue = t"a" }))
			parser add(t"argb", 'b', Event new(func { argumentBValue = t"b" }))
			parser parse(inputList)
			expect(argumentAValue == t"a")
			expect(argumentBValue == t"b")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
		})
		this add("With parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"--arga")
			inputList add(t"1234")
			inputList add(t"abcd")
			inputList add(t"--argb")
			inputList add(t"qwerty")
			inputList add(t"-c")
			inputList add(t"c1")
			inputList add(t"c2")
			inputList add(t"c3")
			parser := ArgumentParser new()
			argumentAFirstValue: Text
			argumentASecondValue: Text
			argumentBValue: Text
			argumentCFirstValue: Text
			argumentCSecondValue: Text
			argumentCThirdValue: Text
			parser add(t"arga", 'a', 2, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentAFirstValue = list[0]; argumentASecondValue = list[1] }))
			parser add(t"argb", 'b', Event1<Text> new(func (parameter: Text) { argumentBValue = parameter }))
			parser add(t"argc", 'c', 3, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAFirstValue == t"1234")
			expect(argumentASecondValue == t"abcd")
			expect(argumentBValue == t"qwerty")
			expect(argumentCFirstValue == t"c1")
			expect(argumentCSecondValue == t"c2")
			expect(argumentCThirdValue == t"c3")
			inputList free()
			parser free()
			argumentAFirstValue free()
			argumentASecondValue free()
			argumentBValue free()
			argumentCFirstValue free()
			argumentCSecondValue free()
			argumentCThirdValue free()
		})
		this add("Negative parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"-a")
			inputList add(t"-12345")
			inputList add(t"-b")
			inputList add(t"--argc")
			inputList add(t"5")
			inputList add(t"-10")
			inputList add(t"15")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentBValue: Text
			argumentCFirstValue: Text
			argumentCSecondValue: Text
			argumentCThirdValue: Text
			parser add(t"arga", 'a', Event1<Text> new(func (parameter: Text) { argumentAValue = parameter }))
			parser add(t"argb", 'b', Event new(func { argumentBValue = t"b" }))
			parser add(t"argc", 'c', 3, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAValue == t"-12345")
			expect(argumentBValue == t"b")
			expect(argumentCFirstValue == t"5")
			expect(argumentCSecondValue == t"-10")
			expect(argumentCThirdValue == t"15")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
			argumentCFirstValue free()
			argumentCSecondValue free()
			argumentCThirdValue free()
		})
		this add("No shortIdentifier", func {
			inputList := VectorList<Text> new()
			inputList add(t"-a")
			inputList add(t"-12345")
			inputList add(t"-argb")
			inputList add(t"--argc")
			inputList add(t"5")
			inputList add(t"-10")
			inputList add(t"15")
			inputList add(t"--argd")
			inputList add(t"1")
			inputList add(t"2")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentAValue = t""
			argumentBValue: Text
			argumentBValue = t""
			argumentCFirstValue: Text
			argumentCSecondValue: Text
			argumentCThirdValue: Text
			argumentDFirstValue: Text
			argumentDSecondValue: Text
			parser add(t"arga", Event1<Text> new(func (parameter: Text) { argumentAValue = parameter }))
			parser add(t"argb", Event new(func { argumentBValue = t"b" }))
			parser add(t"argc", 'c', 3, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser add(t"argd", 2, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentDFirstValue = list[0]; argumentDSecondValue = list[1] }))
			parser parse(inputList)
			expect(argumentAValue == t"")
			expect(argumentBValue == t"")
			expect(argumentCFirstValue == t"5")
			expect(argumentCSecondValue == t"-10")
			expect(argumentCThirdValue == t"15")
			expect(argumentDFirstValue == t"1")
			expect(argumentDSecondValue == t"2")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
			argumentCFirstValue free()
			argumentCSecondValue free()
			argumentCThirdValue free()
			argumentDFirstValue free()
			argumentDSecondValue free()
		})
		this add("Compact flags", func {
			inputList := VectorList<Text> new()
			inputList add(t"-abc")
			inputList add(t"default")
			inputList add(t"--argd")
			inputList add(t"dVal")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentBValue: Text
			argumentCValue: Text
			argumentDValue: Text
			defaultArgumentValue: Text
			parser add(t"arga", 'a', Event new(func { argumentAValue = t"a" }))
			parser add(t"argb", 'b', Event new(func { argumentBValue = t"b" }))
			parser add(t"argc", 'c', Event new(func { argumentCValue = t"c" }))
			parser add(t"argd", 'd', Event1<Text> new(func (parameter: Text) { argumentDValue = parameter }))
			parser addDefault(Event1<Text> new(func (parameter: Text) { defaultArgumentValue = parameter }))
			parser parse(inputList)
			expect(argumentAValue == t"a")
			expect(argumentBValue == t"b")
			expect(argumentCValue == t"c")
			expect(argumentDValue == t"dVal")
			expect(defaultArgumentValue == t"default")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
			argumentCValue free()
			argumentDValue free()
			defaultArgumentValue free()
		})
	}
}

ArgumentParserTest new() run() . free()
