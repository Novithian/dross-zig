## NOTES ##
-----------
- Currently working on OpenGL backend



## TERMINOLOGY ##
-----------------
### Graphics Programming ###
- **Graphics Pipeline**: The process that handles transforming 3D coordinates to the 2D pixels rendered on your display.
- **Shaders**: Small programs that run on the GPU and determine how pixels should be rendered.
- **Vertex**: Collecton of data per 3D coordinate.
- **Primitives**: What render types to form with the data: triangles, points, long lines?
- **Vertex Shader**: The programmable stage that is responsible for transforming the vertices. Allows for basic processing on the vertex attributes. In other words, allows us to transform 3D coordinates into different 3D coordinates. This stage in the pipeline takes single vertices as input.
- **Primitive Assembly**: Takes in all the vertices from the **Vertex Shader**, that form a primitive, and assembles all the point(s) in the **Primitives** shape that was given.
- **Geometry Shader**: The programmable stage that uses the collection of vertices that form a primitive from the **Primitive Assembly**, and has the ability to generate other shapes by emitting new vertices to for new primitives.
- **Rasterization**: The stage that maps the resulting primitives to the corresponding pixels on the final screen. These **fragments** will be used by the **fragment shader** after **Clipping**.
- **Clipping**: Discards all fragments that are outside the view.
- **Fragment Shader**: The programmable stage that is responsible for calculating the final color of the pixel.
- **Alpha Test and Blending**: This stage checks if the corresponding **depth**(and **stencil**) value of the fragment, and uses those to check if the resulting fragment is in front of or behind other objects. This will determine if the fragment should be discarded. This stage also check for **alpha** values and **blends** the object accordingly.
- **Normalized Device Coordinates**: A small normalized space where x, y, and z are within the ranges from -1.0 to 1.0. These will eventually be transformed into **screen-space coordinates** via the **viewport transform**. The resulting screen-space corrdinates are then transforms to fragments as inputs to the fragment shader.
- **Vertex Buffer**: Known in OpenGL as **Vertex Buffer Objects(VBOs)**. Stores a large number of vertices in the GPU's memory. 
- **Vertex Attributes**: Used to represent vertex data.
    - **Value**: x, y, and z are stored as 32-bit(4 byte) floating point values.
    - **Stride**: Each vertex is componsed of 3 values.
    - **Offset**: No padding between each of the 3 sets of values. They are **packed** in the array.
    - **Position**: The first value in the data is at the beginning of the buffer.
- **Vertex Array**: Known in OpenGL as **Vertex Array Objects(VAOs)**. Once bound, any subsequent vertex attirbute calls will be stored inside the VAO.


### OpenGL ###
- OpenGL allows for binding several buffers at once, as long as they have a different buffer type.
- OpenGL has Vertex Attributes disabled by default, enable by using glEnableVertexAttribute(index).
- VAOs store the following:
    - Calls to glEnableVertexAttribArray or glDisableVertexAttribArray.
    - Vertex attribute configurations via glVertexAttribPointer.
    - Vertex buffer objects associated with vertex attributes by calls to glVertexAttribPointer
    - [Source](https://learnopengl.com/img/getting-started/vertex_array_objects.png)