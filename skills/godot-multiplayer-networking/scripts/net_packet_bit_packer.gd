class_name NetPacketBitPacker
extends Node

## Expert Packet Bit-Packing.
## Manually serializes data into PackedByteArray for minimum overhead.

func pack_player_state(pos: Vector3, rot: Vector3, hp: int) -> PackedByteArray:
	var buffer = StreamPeerBuffer.new()
	buffer.put_float(pos.x) # 4 bytes
	buffer.put_float(pos.y) # 4 bytes
	buffer.put_float(pos.z) # 4 bytes
	buffer.put_8(int(rot.y / 360.0 * 255.0)) # Quantized rotation (1 byte)
	buffer.put_u8(hp) # 1 byte
	return buffer.data_array

func unpack_player_state(data: PackedByteArray) -> Dictionary:
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = data
	return {
		"pos": Vector3(buffer.get_float(), buffer.get_float(), buffer.get_float()),
		"rot_y": buffer.get_8() / 255.0 * 360.0,
		"hp": buffer.get_u8()
	}

## Tip: Quantize rotations/angles to 1 byte (`put_8`) to save 3 bytes per packet compared to floats.
