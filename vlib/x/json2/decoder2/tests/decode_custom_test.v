import decoder2 as json
import x.json2
import math.big

struct MyString implements json.StringDecoder, json.NumberDecoder, json.BooleanDecoder, json.NullDecoder {
mut:
	data string
}

pub fn (mut ms MyString) from_json_string(raw_string string) ! {
	ms.data = raw_string
}

pub fn (mut ms MyString) from_json_number(raw_number string) ! {
	mut first := true

	for digit in raw_number {
		if first {
			first = false
		} else {
			ms.data += '-'
		}

		ms.data += match digit {
			`-` { 'minus' }
			`.` { 'dot' }
			`e`, `E` { 'e' }
			`0` { 'zero' }
			`1` { 'one' }
			`2` { 'two' }
			`3` { 'three' }
			`4` { 'four' }
			`5` { 'five' }
			`6` { 'six' }
			`7` { 'seven' }
			`8` { 'eight' }
			`9` { 'nine' }
			else { 'none' }
		}
	}
}

pub fn (mut ms MyString) from_json_boolean(boolean_value bool) {
	ms.data = if boolean_value { 'yes' } else { 'no' }
}

pub fn (mut ms MyString) from_json_null() {
	ms.data = 'default value'
}

struct NoCustom {
	a int
	b string
}

fn test_custom() {
	assert json.decode[NoCustom]('{"a": 99, "b": "hi"}')! == NoCustom{
		a: 99
		b: 'hi'
	}

	assert json.decode[[]MyString]('["hi", -9.8e7, true, null]')! == [
		MyString{
			data: 'hi'
		},
		MyString{
			data: 'minus-nine-dot-eight-e-seven'
		},
		MyString{
			data: 'yes'
		},
		MyString{
			data: 'default value'
		},
	]
}

fn test_null() {
	assert json.decode[json2.Any]('null]')! == json2.Any(json2.null)
	assert json.decode[json2.Any]('{"hi": 90, "bye": ["lol", -1, null]}')!.str() == '{"hi":90,"bye":["lol",-1,null]}'
}

fn test_big() {
	assert json.decode[big.Integer]('0')!.str() == '0'

	assert json.decode[big.Integer]('12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890')!.str() == '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'

	assert json.decode[big.Integer]('-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890')!.str() == '-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
}
