## **GOALS** ##
- [ ] Create a minimum framework to allow for a small
2D pixel-art game.

## **TODO** ##

### Bugs ###

### General ###

### Renderer ###
- Font Rendering
	- Dynamically generate font atlas and store the uvs in the glyphs
- Pixel snap

### Texture ###
- Texture Atlas

### Sprite ###
- Sprite origin ( Not really working yet )
- Sorting Orderer

### Input ###
- Mouse manage state to detect down

### Collision System ###
- Basic AABB (axis-aligned bounding box) collision system
- Is Mouse over 

### Audio ###
- integrate libsoundio or fmod

### Window ###
- Wrapper for window

## **LOG** ##
- **[06-01-2021]**
	- Finished up basic texture batching for sprites
	- Wrapper for zalgebra vec4
	- Batch boundary catches	 
	- Finished basic batching for font rendering
	- Have a seperate beginGui, endGui
	- Fixed the bug with drawColoredQuad where it did not use the default texture in slot 0, so it was using random textures in the slots.
- **[05-31-2021]**
	- Cont. Batch Rendering
		- Colored Quads now have okay batching
		- Before: 
			- Frame (ms): 1.0334
			- Draw (ms): 0.9024
			- Draw Calls: 1093
			- Quad Count: 1093
		- After:
			- Frame (ms): 0.3093
			- Draw (ms): 0.1884
			- Draw Calls: 90
			- Quad Count: 1093
- **[05-30-2021]**
	- Looking into batch rendering
	- Working on batch rendering with colored quads first.
	- Added random functions for Vector3 and Color for testing purposes.
- **[05-29-2021]**
	- Finished API refactoring, Engine API should be mostly uniform. Minus the files that do not actually used instances. 
	- Renamed OpenGlTexture to TextureGl to fit the new Api format.
	- Renamed FramebufferOpenGl to FramebufferGl
	- Renamed OpenGlBackend to RendererGl
		- Renamed backend_opengl.zig to renderer_opengl.zig
	- Extracted GlVertexBuffer and GlBufferUsage from renderer_opengl.zig to vertex_buffer_opengl.zig
		- Renamed GlVertexBuffer to VertexBufferGl
		- Renamed GlBufferUsage to BufferUseageGl
	- Extracted GlIndexBuffer from renderer_opengl.zig to index_buffer_opengl.zig
		- Renamed GlIndexBuffer to IndexBufferGl
	- Extracted GlVertexArray from renderer_opengl.zig to vertex_array_opengl.zig
		- Renamed GlVertexArray to VertexArrayGl
	- Extracted GlShader and GlShaderType from renderer_opengl.zig to shader_opengl.zig
		- Renamed GlShader to ShaderGl
		- Renamed GlShaderType to ShaderType
	- Extracted GlShaderProgram from renderer_opengl.zig to shader_program_opengl.zig
		- Renamed GlShaderProgram to ShaderProgramGl
	
- **[05-28-2021]**
	- Helper function to get text width
	- Helper function to get text height
	- Started refactoring to the new API format
	- Renamed core.zig to color.zig
- **[05-27-2021]**
	- Fixed font rendering scaling
	- GUI Render event
	- String helpers such as format
	- Allow for quad drawing on the gui layer
	- Let GUI elements use the alpha value
- **[05-26-2021]**
	- Setting up some more basic profiling
	- Started brainstorming API formatting via api_formatting.md
	- Frame stats
- **[05-25-2021]**
	- More Font Rendering
	- Something is on the screen
- **[05-24-2021]**
	- Playing with FreeType2 some more
- **[05-23-2021]**
	- Looking into FreeType library
- **[05-22-2021]**
	- Exploring font rendering
- **[05-21-2021]**
	- Required the passing of the user-defined update event and render event to the run function now rather than exporting the function as it uses the .C calling convension, which does not allow for error return types.
	- Basic scope timer
- **[05-19-2021]**
	- Sprite flip
	- Moved sandbox related files to the /sandbox folder.
	- Made a Player struct to contain the test data.
- **[05-17-2021]**
    - Framebuffer
- **[05-12-2021]**
    - Create Sprite structure
    - Replace any texture loading instances that are using it as a sprite with an actual sprite.
    - create a drawSprite function in the renderer to make it far quicker
    - Create a set of uniform helpers that'll take the location and data pointer
    - Sprite color
    - Sprite scaling
    - Create a lerp for f32s
    - rotation
- **[05-11-2021]**
	- File loader util
    - ResourceHandler
    - Extract the debug texture from the renderer and allow the user to provide a texture for drawTexturedQuad. Have a default white texture for draw quad for geometry drawing.
    - Create the test texture in the main file
- **[05-10-2021]**
	- Allowed for transparency in the fragment shader.
	- Manage Input Keyboard states to allow for proper released input detection 
	- Mouse Input
		- Position and press + release buttons states
- **[05-09-2021]**
	- Implement a Render API to allow for the end user to draw. Rendere will handle pre-draw, and post-draw. Something simple like DrawQuad.
	- Implement a wrapper around zalgebra's vec3 and vec2
	- Replace all instances of using zalgebra's Vectors and move them over to wrapper Vectors.
	- Moving any uses of za's matrices to dross's wrapper matrix in camera/renderer
	- Input Wrapper
	- Orthographic Camera movements
	- Camera zoom
- **[05-08-2021]**
	- Figure out a way to handle lifetime events.
	- Add a render event for the user to implement
	- Wrapper for zalgebra Matrix4
- **[05-07-2021]**
    - Implement basic Camera
    - Updated camera_2d.zig's documentation
	- Create abstraction over zalgebra's mat4 via transform.zig 
- **[05-06-2021]**
    - Added zalgebra as an dependency for linear algebra
    - Implmented a basic delta time
    - Updated documentation from the texture files from yesterday.
    - Update documentation to remove the parametes and return type
        - New format being description and comments.
            - **Description:** What could this mean?
            - **Comments:** Any noteworthy additions, such as memory ownership (if the method/function is passed an allocator), internal use only, etc.
    - Update comments to remove opengl function signatures and consolidate them in zig_gl_conversions.md
    - Log the conversion methods between OpenGL and Zig in zig_gl_conversions.md
- **[05-05-2021]**
    - Add a use helper method to the shader program
    - Add uniform helper methods to the shader program struct
    - import stb_images.h
    - Remove target_api parameter for buildTexture
    - OpenGL Textures
- **[05-04-2021]**
    - Move most of application build code to build method in app
    - Add shader type to shader compilation failure error message
    - Add color inputs to the shaders
    - Automatically read a shader file and input it to a something.
    - Updated README
- **[05-03-2021]**
    - Render a triangle
    - ShaderProgram
    - Vertex Array Object
    - Vertex Buffer Object
    - Implement index buffer
    - Process Input
    - Document ownership on any functions/methods that are passed an allocator
    - Documented and Commented on all new code from today.
- **[05-02-2021]**
    - Imported OpenGL
    - Laid out Application structure
    - Abstracted OpenGL out from the user's end(main.zig in this case)
    - Learned about Memory Allocators
    - Make Renderer MOSTLY graphics api agnostic
    - Go back through all of the TODOs and begin to document the project
    - Helper methods/functions for the Color struct
    - Replace any instances of r, g, b values with the Color struct
- **[05-01-2021]**
    - Setup Repo
    - Setup VSCode
    - Setup up GLFW
