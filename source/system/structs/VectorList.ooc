/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

VectorList: class <T> extends List<T>{
	_vector: Vector<T>
	pointer ::= this _vector _backend as Pointer
	init: func ~default {
		this init(32)
	}
	init: func ~heap (capacity: Int, freeContent := true) {
		this init(HeapVector<T> new(capacity, freeContent))
	}
	init: func (=_vector)
	free: override func {
		this clear()
		this _vector free()
		super()
	}
	add: override func (item: T) {
		if (this _vector capacity <= this _count)
			this _vector resize(this _vector capacity + 8)
		this _vector[this _count] = item
		this _count += 1
	}
	append: override func (other: List<T>) {
		if (this _vector capacity < this _count + other count)
			this _vector resize(this _vector capacity + other count)
		for (i in 0 .. other count)
			this _vector[this _count + i] = other[i]
		this _count += other count
	}
	insert: override func (index: Int, item: T) {
		if (this _vector capacity <= this _count)
			this _vector resize(this _vector capacity + 8)
		this _vector copy(index, index + 1)
		this _vector[index] = item
		this _count += 1
	}
	remove: override func ~last -> T {
		this _count -= 1
		this _vector[this _count]
	}
	remove: override func ~atIndex (index: Int) -> T {
		result := this _vector[index]
		this _vector copy(index + 1, index)
		this _count -= 1
		result
	}
	removeAt: override func (index: Int) {
		this _vector copy(index + 1, index)
		this _count -= 1
	}
	clear: override func {
		this _vector _free(0, this _count)
		this _count = 0
	}
	reverse: override func -> This<T> {
		result := This<T> new(this _count)
		for (i in 0 .. this _count)
			result add(this[(this _count - 1) - i])
		result
	}
	search: override func (matches: Func (T*) -> Bool) -> Int {
		result := -1
		for (index in 0 .. this count)
			if (matches(this[index]&)) {
				result = index
				break
			}
		result
	}
	sort: override func (greaterThan: Func (T, T) -> Bool) {
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0 .. count - 1)
				if (greaterThan(this[i], this[i + 1])) {
					inOrder = false
					tmp := this[i]
					this[i] = this[i + 1]
					this[i + 1] = tmp
				}
		}
	}
	copy: override func -> This<T> {
		result := This new(this _count)
		memcpy(result pointer, this pointer, this _count * T size)
		result _count = this _count
		result
	}
	apply: override func (function: Func(T)) {
		for (i in 0 .. this count)
			function(this[i])
	}
	modify: override func (function: Func(T) -> T) {
		for (i in 0 .. this count)
			this[i] = function(this[i])
	}
	map: override func <S> (function: Func(T) -> S) -> This<S> {
		result := This<S> new(this count)
		for (i in 0 .. this count)
			result add(function(this[i]))
		result
	}
	fold: override func <S> (S: Class, function: Func(T, S) -> S, initial: S) -> S {
		for (i in 0 .. this count)
			initial = function(this[i], initial)
		initial
	}
	getFirstElements: override func (number: Int) -> List<T> {
		result := This<T> new()
		number = number < count ? number : count
		for (i in 0 .. number)
			result add(this _vector[i])
		result
	}
	getElements: override func (indices: List<Int>) -> List<T> {
		result := This<T> new()
		for (i in 0 .. indices count)
			result add(this[indices[i]])
		result
	}
	getSlice: override func ~range (range: Range) -> This<T> {
		result := This<T> new(range count)
		this getSliceInto(range, result)
		result
	}
	getSlice: override func ~indices (start, end: Int) -> This<T> {
		this getSlice(start .. end)
	}
	getSliceInto: final override func ~range (range: Range, buffer: This<T>) {
		if (buffer _vector capacity < range count)
			buffer _vector resize(range count)
		buffer _count = range count
		source := (this _vector _backend + (range min * (T size))) as Pointer
		memcpy(buffer pointer, source, range count * (T size))
	}
	getSliceInto: final override func ~indices (start, end: Int, buffer: This<T>) {
		this getSliceInto(start .. end, buffer)
	}
	iterator: override func -> Iterator<T> { _VectorListIterator<T> new(this) }

	operator [] (index: Int) -> T {
		version (safe)
			raise(index >= this count, "Accessing VectorList index out of range in get operator")
		this _vector[index]
	}
	operator []= (index: Int, item: T) {
		version (safe)
			raise(index >= this count, "Accessing VectorList index out of range in set operator")
		this _vector[index] = item
	}
}

_VectorListIterator: class <T> extends Iterator<T> {
	_backend: VectorList<T>
	_position: UInt
	init: func (=_backend)
	hasNext: override func -> Bool { this _position < this _backend count }
	next: override func -> T {
		result := this _backend[this _position]
		this _position += 1
		result
	}
	remove: override func -> Bool { false }
}