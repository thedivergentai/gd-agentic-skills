# MultiMesh Swarm Animation Shader Hook
extends MultiMeshInstance2D

## For swarms (birds, fish, projectiles), Node2D overhead is the bottleneck.
## Use a Shader to animate thousands of instances on the GPU.

func _ready() -> void:
	var mat = material as ShaderMaterial
	# Pass the start time to the shader to sync animations
	mat.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)

# Example Shader Snippet (to be put in .gdshader):
# void vertex() {
#     float phase = TIME * speed + (float(INSTANCE_ID) * 0.5);
#     VERTEX.y += sin(phase) * amplitude; // Procedural GPU animation
# }
