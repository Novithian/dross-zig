## Framework API Formatting
- Ditch the builder pattern
- .new(allocator) *Self, .free(allocator, self), .clean(self)
	- **New**:  init/create/build a new instance of the structure.
	- **Free**: allocator will destroy the instance after calling a clean method
	- **Clean**: Any pre-deletion preperations
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
- [ ] player.zig
### Utils
- [ ] profiling/frame_statistics.zig
- [ ] file_loader.zig
- [ ] math_helpers.zig
- [ ] timer.zig
- [ ] strings.zig
### Core
- [ ] application.zig
- [ ] core.zig
- [ ] input.zig
- [ ] matrix4.zig
- [ ] vector2.zig
- [ ] vector3.zig
- [ ] resource_handler.zig
### Renderer
- [ ] backend/backend_opengl.zig
- [ ] backend/framebuffer_opengl.zig
- [ ] backend/texture_opengl.zig
- [ ] cameras/camera_2d.zig
- [ ] font/font.zig
- [ ] font/glyph.zig
- [ ] framebuffer.zig
- [ ] renderer.zig
- [ ] sprite.zig
- [ ] texture.zig

