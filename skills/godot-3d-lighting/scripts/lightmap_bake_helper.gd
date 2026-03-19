# Shadowmasking and LightmapGI Setup
extends LightmapGI

## Advanced baking workflow: Distant shadows are baked (Lightmap)
## while nearby shadows remain dynamic (DirectionalLight3D).

func configure_expert_bake() -> void:
    # Forward+ Renderer required for high quality
    quality = LightmapGI.BAKE_QUALITY_ULTRA
    bounces = 3
    
    # Architecture Tip: Ensure your DirectionalLight3D is set to 'Bake Mode: Dynamic'
    # so it results in shadowmasking instead of full static bake.
    
    # Use denoiser for soft, realistic transitions
    use_denoiser = true
