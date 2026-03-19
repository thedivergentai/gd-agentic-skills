# Expert Custom Build Stripper (SCons)
# Usage: Copy to godot root and run 'scons platform=windows target=template_release'
# Disables unused modules to reduce binary size significantly.

module_navigation_enabled = "no"
module_mobile_vr_enabled = "no"
module_text_server_fb_enabled = "no"
module_upnp_enabled = "no"

# For specialized 2D apps, disable 3D:
# disable_3d = "yes"

# Optimize for size
optimize = "size"
