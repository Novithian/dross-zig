pub const c_imp = @cImport({
    @cInclude("glad.h");
    @cInclude("glfw3.h");
    @cDefine("STBI_ONLY_PNG", "");
    @cDefine("STBI_NO_STDIO", "");
    @cInclude("stb_image.h");
});
