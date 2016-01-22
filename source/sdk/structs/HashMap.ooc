import ArrayList

getStandardEquals: func <T> (T: Class) -> Func <T> (T, T) -> Bool {
	if (T == String)
		stringEquals
	else if (T == CString)
		cstringEquals
	else if (T size == Pointer size)
		pointerEquals
	else if (T size == UInt size)
		intEquals
	else if (T size == Char size)
		charEquals
	else
		genericEquals
}

stringEquals: func <K> (k1, k2: K) -> Bool { k1 as String equals(k2 as String) }

cstringEquals: func <K> (k1, k2: K) -> Bool { k1 as CString == k2 as CString }

pointerEquals: func <K> (k1, k2: K) -> Bool { k1 as Pointer == k2 as Pointer }

intEquals: func <K> (k1, k2: K) -> Bool { k1 as Int == k2 as Int }

charEquals: func <K> (k1, k2: K) -> Bool { k1 as Char == k2 as Char }

genericEquals: func <K> (k1, k2: K) -> Bool { memcmp(k1, k2, K size) == 0 }

HashEntry: cover {
	key, value: Pointer
	next: This* = null

	init: func@ ~keyVal (=key, =value)
	free: func {
		free(this key)
		free(this value)
		if (this next != null) {
			temp := this next@
			temp free()
			free(this next)
		}
	}
}

nullHashEntry: HashEntry
memset(nullHashEntry&, 0, HashEntry size)

intHash: func <K> (key: K) -> SizeT {
	result: SizeT = key as Int
	result
}

pointerHash: func <K> (key: K) -> SizeT {
	(key as Pointer) as SizeT
}

charHash: func <K> (key: K) -> SizeT {
	// both casts are necessary
	// Casting 'key' directly to UInt would deref a pointer to UInt
	// which would read random memory just after the char, which is not a good idea..
	(key as Char) as SizeT
}

/**
	Port of Austin Appleby's Murmur Hash implementation
	http://code.google.com/p/smhasher/
*/
murmurHash: func <K> (keyTagazok: K) -> SizeT {
	seed: SizeT = 1

	len := K size
	m = 0x5bd1e995: SizeT
	r = 24: SSizeT
	l := len

	h : SizeT = seed ^ len
	data := (keyTagazok&) as Octet*

	while (true) {
		k := (data as SizeT*)@

		k *= m
		k ^= k >> r
		k *= m

		h *= m
		h ^= k

		data += 4
		if (len < 4) break
		len -= 4
	}

	t := 0

	if (len == 3) h ^= data[2] << 16
	if (len == 2) h ^= data[1] << 8
	if (len == 1) h ^= data[0]

	t *= m; t ^= t >> r; t *= m; h *= m; h ^= t
	l *= m; l ^= l >> r; l *= m; h *= m; h ^= l

	h ^= h >> 13
	h *= m
	h ^= h >> 15

	h
}

/**
 * khash's ac_X31_hash_string
 * http://attractivechaos.awardspace.com/khash.h.html
 * @access private
 * @param s The string to hash
 * @return UInt
 */
ac_X31_hash: func <K> (key: K) -> SizeT {
	assert(key != null)
	s : Char* = (K == String) ? (key as String) toCString() as Char* : key as Char*
	h = s@ : SizeT
	if (h) {
		s += 1
		while (s@) {
			h = (h << 5) - h + s@
			s += 1
		}
	}
	h
}

getStandardHashFunc: func <T> (T: Class) -> Func <T> (T) -> SizeT {
	if (T == String || T == CString)
		ac_X31_hash
	else if (T size == Pointer size)
		pointerHash
	else if (T size == UInt size)
		intHash
	else if (T size == Char size)
		charHash
	else
		murmurHash
}

HashMap: class <K, V> extends BackIterable<V> {
	_size, capacity: SizeT
	keyEquals: Func <K> (K, K) -> Bool
	hashKey: Func <K> (K) -> SizeT

	buckets: HashEntry[]
	keys: ArrayList<K>

	size ::= _size
	isEmpty ::= keys empty()

	init: func { init(3) }

	init: func ~withCapacity (=capacity) {
		_size = 0

		buckets = HashEntry[capacity] new()
		keys = ArrayList<K> new()

		keyEquals = getStandardEquals(K)
		hashKey = getStandardHashFunc(K)
	}
	free: override func {
		for (i in 0 .. this buckets length)
			this buckets[i] free()
		this buckets free()
		this keys free()
		super()
	}
	getEntry: func (key: K, result: HashEntry*) -> Bool {
		hash : SizeT = hashKey(key) % capacity
		entry := buckets[hash]

		if (entry key == null) { return false }

		while (true) {
			if (keyEquals(entry key as K, key)) {
				if (result) {
					result@ = entry
				}
				return true
			}

			if (entry next) {
				entry = entry next@
			} else {
				return false
			}
		}
		return false
	}
	/**
	 * Returns the HashEntry associated with a key.
	 * @access private
	 * @param key The key associated with the HashEntry
	 * @return HashEntry
	 */
	getEntryForHash: func (key: K, hash: SizeT, result: HashEntry*) -> Bool {
		entry := buckets[hash]

		if (entry key == null) {
			return false
		}

		while (true) {
			if (keyEquals(entry key as K, key)) {
				if (result) {
					result@ = entry
				}
				return true
			}

			if (entry next) {
				entry = entry next@
			} else {
				return false
			}
		}
		return false
	}
	clone: func -> This<K, V> {
		copy := This<K, V> new()
		each(|k, v| copy put(k, v))
		copy
	}
	merge: func (other: This<K, V>) -> This<K, V> {
		c := clone()
		c merge~inplace(other)
		c
	}
	merge: func ~inplace (other: This<K, V>) -> This<K, V> {
		f := func (k: K, v: V) { put(k, v) }
		other each(f)
		(f as Closure) free()
		this
	}
	// If the pair already exists, it is overwritten.
	put: func (key: K, value: V) -> Bool {
		hash: SizeT = hashKey(key) % capacity
		entry: HashEntry

		if (getEntryForHash(key, hash, entry&)) {
			// replace value if the key is already existing
			memcpy(entry value, value, V size)
		} else {
			keys add(key)

			current := buckets[hash]
			if (current key != null) {
				currentPointer := (buckets data as HashEntry*)[hash]&

				while (currentPointer@ next)
					currentPointer = currentPointer@ next

				newEntry := gc_malloc(HashEntry size) as HashEntry*

				newEntry@ key = gc_malloc(K size)
				memcpy(newEntry@ key, key, K size)

				newEntry@ value = gc_malloc(V size)
				memcpy(newEntry@ value, value, V size)

				currentPointer@ next = newEntry
			} else {
				entry key = gc_malloc(K size)
				memcpy(entry key, key, K size)

				entry value = gc_malloc(V size)
				memcpy(entry value, value, V size)

				entry next = null

				buckets[hash] = entry
			}
			_size += 1

			if ((_size as Float / capacity as Float) > 0.75)
				resize(_size * (_size > 50000 ? 2 : 4))
		}
		true
	}
	add: func (key: K, value: V) -> Bool {
		put(key, value)
	}
	get: func (key: K) -> V {
		entry: HashEntry
		if (getEntry(key, entry&))
			return entry value as V
		return null
	}
	contains: func (key: K) -> Bool {
		getEntry(key, null)
	}
	remove: func (key: K) -> Bool {
		hash : SizeT = hashKey(key) % capacity
		prev = null : HashEntry*
		entry: HashEntry* = (buckets data as HashEntry*)[hash]&

		result := false
		if (entry@ key != null) {
			while (true) {
				if (keyEquals(entry@ key as K, key)) {
					free(entry@ key)
					free(entry@ value)

					if (prev)
						prev@ next = entry@ next // re-connect the previous to the next one
					else if (entry@ next)
						buckets[hash] = entry@ next@ // just put the next one instead of us
					else
						buckets[hash] = nullHashEntry

					for (i in 0 .. keys size) {
						cKey := keys get(i)
						if (keyEquals(key, cKey)) {
							keys removeAt(i)
							break
						}
					}
					_size -= 1
					result = true
					break
				}

				// do we have a next element?
				if (entry@ next) {
					// save the previous just to know where to reconnect
					prev = entry
					entry = entry@ next
				} else
					break
			}
		}
		result
	}
	resize: func (_capacity: SizeT) -> Bool {
		oldCapacity := capacity
		oldBuckets := buckets

		oldKeys := keys clone()
		keys clear()
		_size = 0

		/* Transfer old buckets to new buckets! */
		capacity = _capacity
		buckets = HashEntry[capacity] new()

		for (i in 0 .. oldCapacity) {
			entry := oldBuckets[i]
			if (entry key == null) continue

			put(entry key as K, entry value as V)

			while (entry next) {
				entry = entry next@
				put(entry key as K, entry value as V)
			}
		}

		// restore old keys to keep order
		keys = oldKeys
		true
	}
	iterator: override func -> BackIterator<V> {
		HashMapValueIterator<K, V> new(this)
	}
	backIterator: func -> BackIterator<V> {
		iter := HashMapValueIterator<K, V> new(this)
		iter index = keys getSize()
		iter
	}
	clear: func {
		_size = 0
		for (i in 0 .. capacity)
			buckets[i] = nullHashEntry
		keys clear()
	}
	each: func ~withKeys (f: Func (K, V)) {
		for (i in 0 .. keys size) {
			key := keys[i]
			f(key, get(key))
		}
	}
	each: func (f: Func (V)) {
		for (i in 0 .. keys size)
			f(get(keys[i]))
	}
}

HashMapValueIterator: class <K, T> extends BackIterator<T> {
	map: HashMap<K, T>
	index := 0

	init: func ~withMap (=map)

	hasNext?: override func -> Bool { index < map keys size }

	next: override func -> T {
		key := map keys get(index)
		index += 1
		return map get(key)
	}

	hasPrev?: override func -> Bool { index > 0 }

	prev: override func -> T {
		index -= 1
		key := map keys get(index)
		return map get(key)
	}

	remove: override func -> Bool {
		result := map remove(map keys get(index))
		if (index <= map keys size) index -= 1
		return result
	}
}

operator [] <K, V> (map: HashMap<K, V>, key: K) -> V { map get(key) }
operator []= <K, V> (map: HashMap<K, V>, key: K, value: V) { map put(key, value) }
