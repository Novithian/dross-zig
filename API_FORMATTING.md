## Framework API Formatting
- Ditch the builder pattern
- .new(allocator) *Self, .free(allocator, self)	
	- - **New**:  init/create/build a new instance of the structure.
	- **Free**: allocator will destroy the instance after calling a clean method
		- This will be a struct function that will be passed a pointer to the instance. This will allow for cleaner game files if the allocator destory is handled by the free function itself. 1 call rather than two.
		- Examples: 
			- Player.free(allocator, player);
			- VertexArray.free(allocator, vao);
- Naming: 
	- Local Variables:
		- snake_case
	- Global(non-const):
		- snake_case
	- Global(const):
		- SCREAMING_SNAKE_CASE
	- Structures:
		- PascalCase
	- Functions and methods: 
		- camelCase
		- return: type
			- PascalCase
		- setters/getters:
			- setIndex()
			- index()
			- setId()
			- id()
	- File Names
		- snaking_case.zig
		- Platform Specific Implementations:
			- name_platform.zig 
				- texture_opengl.zig
				- texture_vulkan.zig

## Refactor Progress:
- [ ] main.zig 
### Sandbox
- [x] player.zig
### Utils
- [x] profiling/frame_statistics.zig
- [x] file_loader.zig
- [x] math_helpers.zig
- [x] timer.zig
- [x] strings.zig
### Core
- [x] application.zig
- [x] color.zig
- [x] input.zig
- [x] matrix4.zig
- [x] vector2.zig
- [x] vector3.zig
- [x] resource_handler.zig
### Renderer
- [ ] backend/backend_opengl.zig
- [ ] backend/framebuffer_opengl.zig
- [ ] backend/texture_opengl.zig
- [ ] cameras/camera_2d.zig
- [x] font/font.zig
- [x] font/glyph.zig
- [ ] framebuffer.zig
- [ ] renderer.zig
- [ ] sprite.zig
- [ ] texture.zig

