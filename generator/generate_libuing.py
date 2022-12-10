import libuing_parser, libuing_generator

LIBUING_STRUCT_ALIAS = {
    "Vector4": ["Quaternion"],
    "Texture": ["Texture2D", "TextureCubemap"],
    "RenderTexture": ["RenderTexture2D"],
    "Camera3D": ["Camera"],
}

if __name__ == "__main__":

    ctx = libuing_parser.ParseContext('../third_party/libui-ng/ui.h')
    libuing_parser.execute(ctx)

    libuing_generator.sanitize(ctx)
    libuing_generator.generate(ctx,
                              module_name = 'main',
                              struct_alias = LIBUING_STRUCT_ALIAS)
