## **Conversions** ##
| GL            | Zig       | Conversion Method |
| :----         | :---:     | ----------------: |
| GLuint* x     | y: c_uint  | @ptrCast(*c_uint, &y) |
| Gluint  x     | y: c_uint  | x = y |
| GLint x       | y: c_int   | x = y |
| (*void)x      | y: *any    | @ptrCast(*c_void, &y) |
| const GLchar *name | y: [:0]const u8  | &y.ptr |
| GLsizeiptr x  | y: c_uint | @ptrCast(c_longlong, y) |
| GLsizei x     | y: c_int | @intCast(c_longlong, y) |
| const GLvoid* x | y: c_int | @intToPtr(*c_void, 0) |

## **OpenGL Function Signatures** ##
```cpp
// General
glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
glDrawElements(GLenum mode, GLsizei count, GLenum type,
                const GLvoid* indices)
glClear(GLbitfield mask);
glClearColor(GLfloat red, GLfloat green, GLfloat blue,
            GLfloat alpha)
glPolygonMode(GLenum face, GLenum mode);
glPixelStorei(c.GL_UNPACK_ALIGNMENT, 4);

// Textures
glGenTexture(GLsizei n, GLuint* textures)
glBindTexture(GLenum target, GLuint texture)
glActiveTexture(c.GL_TEXTURE0);
glTexImage2D(GLenumn target, GLint, level,
            GLint internal_format, GLsizei width,
            GLsizei height, GLint border,
            GLenum format, GLenum type,
            const GLvoid* data)
glGenerateMipmap(GLenum target)

// Buffers
glGenBuffers(GLsizei size, GLuint* buffers)
glDeleteBuffer(GLsizei count, GLuint buffer))
glBindBuffer(GLenum target, GLuint buffer)
glBufferData(GLenum mode, Glsizeiptr size,
            const GLvoid* data, GLenum usage)

// Vertex Array Object
glGenVertexArrays(GLsizei size, GLuint* array)
glEnableVertexAttribArray(GLuint index)
glVertexAttribPointer(GLuint index, Glint size, GLenum type,
                    GLboolean normalized, GLsizei stride,
                    const GLvoid *pointer)


glDeleteVetexArrays(GLsizei count, GLuint array))
glBindVertexArray(GLuint array)

// Uniforms
glUniform1i(GLint location, GLint)
glUniform1f(GLint location, GLfloat)
glGetUniformLocation(Gluint program, const GLchar *name)

// Shaders
glCreateShader(GLenum shaderType)
glDeleteShader(GLuint shader)
glAttachShaer(GLuint program, GLuint shader)
glShaderSource(GLuint shader, GLsizei count, 
                const GLchar** string, const GLint *length)
glCompileShader(GLuint shader)
glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
glGetShaderInfoLog(GLuint shader, GLsizei maxLength, 
                    GLsizei *length, GLchar *infoLog)

// Programs
glCreateProgram()
glDeleteProgram(GLuint program)
glUseProgram(GLuint)
glLinkProgram(GLuint program)
glGetProgramiv(GLuint program, GLenum pname, GLint *params)
glGetProgramInfoLog(GLuint shader, GLsizei maxLength, 
                    GLsizei *length, GLchar *infoLog)
```