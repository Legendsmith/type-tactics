## A collection of bits to compact boolean values into a small set.
class_name UCBitset
extends RefCounted
# author: milesturin
# license: MIT
# description: A class that allows for easily manipulated bitmasks of any size
# usage:
#	By setting enforce_soft_size to false, the Bitset will allow the user to access
#	bits that have been reserved by the script, but are outside of the requested size.

## The size of bits inside a mask segment of the bitset.
const MASK_SIZE := 8

## The collection of bitmasks used to store the bits inside the bitset.
var bitmasks: PackedByteArray = PackedByteArray()

## The amount of bits available inside of the bitset.
var bits: int

func _init(size: int, default_state: bool = false, enforce_soft_size: bool = true) -> void:
	resize(size, default_state, enforce_soft_size)


## Resizes the bitset to the desired size.[br]
## [br]
## [b]size[/b] - The desired size of the bitset.[br]
## [b]default_state[/b] - The default state of the bits when the new size is larger than the previous size.[br]
## [b]enforce_soft_size[/b] - Determines if the new size should be in line with the desired size or if it should be aligned to the mask size.
func resize(size: int, default_state: bool = false, enforce_soft_size: bool = true) -> void:
	assert(size >= 0)
	var old_masks := bitmasks.size()
	if old_masks > 0 and bits % MASK_SIZE:
		if default_state:
			bitmasks[old_masks - 1] |= (~0 << (bits % MASK_SIZE))
		else:
			bitmasks[old_masks - 1] &= ~((~0) << (bits % MASK_SIZE))
	bitmasks.resize(ceil(size / float(MASK_SIZE)))
	bits = size if enforce_soft_size else bitmasks.size() * MASK_SIZE
	for i in range(old_masks, bitmasks.size()):
		bitmasks[i] = ~0 if default_state else 0


## Determines if the bit at the given index is set to true or false.[br]
## [br]
## [b]index[/b] - The index of the bit inside of the bitset.
func check_bit(index: int) -> bool:
	assert(index < bits and index >= 0)
	@warning_ignore("integer_division")
	return bitmasks[index / MASK_SIZE] & (1 << (index % MASK_SIZE)) != 0


## Determines if any bit has been set to true in the bit set.[br]
## [u]note[/u]: If the set has a size of zero, the function will return false.
func has_any_bit_set() -> bool:
	if bits == 0:
		return false
	
	for mask in bitmasks:
		if mask != 0:
			return true
	
	return false


## Sets the state of the bit at the given index to true or false.[br]
## [br]
## [b]index[/b] - The index of the bit inside of the bitset.[br]
## [b]state[/b] - The state the bit will set to.
func set_bit(index: int, state: bool) -> void:
	assert(index < bits and index >= 0)
	if state:
		@warning_ignore("integer_division")
		bitmasks[index / MASK_SIZE] |= (1 << (index % MASK_SIZE))
	else:
		@warning_ignore("integer_division")
		bitmasks[index / MASK_SIZE] &= ~(1 << (index % MASK_SIZE))


## Flips the state of the bit at the given index to true or false.[br]
## [br]
## [b]index[/b] - The index of the bit inside of the bitset.
func flip_bit(index: int) -> void:
	assert(index < bits and index >= 0)
	set_bit(index, !check_bit(index))


## Creates a new instance of the bitset with the same bits set.
func duplicate() -> UCBitset:
	var new_set = UCBitset.new(bits)
	
	for i in bitmasks.size():
		new_set.bitmasks[i] = self.bitmasks[i]
	return new_set


func print_bits(multiline: bool = true) -> void:
	if multiline:
		for i in range(bits):
			print("bit " + String.num(i) + ": " + String.num(check_bit(i)))
	else:
		var output := ""
		for i in range(bits):
			output += '1' if check_bit(i) else '0'
		print(output)


func as_base_64() -> String:
	return Marshalls.raw_to_base64(bitmasks)


func from_base_64(data_string: String) -> void:
	var data: PackedByteArray = Marshalls.base64_to_raw(data_string)
	var mask_count: int = ceil(bits / float(MASK_SIZE))
	# make sure that the data is about the same size as the 
	data.resize(mask_count)
	
	var used_bits: int = bits % MASK_SIZE
	if used_bits == 0:
		used_bits = MASK_SIZE

	# Construct a mask that only keeps valid bits
	var valid_mask: int = (1 << used_bits) - 1
	data[-1] &= valid_mask
