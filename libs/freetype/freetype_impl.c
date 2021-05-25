
#define FTSTDLIB_H_
#define ft_ptrdiff_t __PTRDIFF_TYPE__
#define ft_jmp_buf jmp_buf
#define FT_CHAR_BIT __CHAR_BIT__
#define FT_INT_MAX __INT_MAX__
#define FT_INT_MIN (~__INT_MAX__)
#define FT_UINT_MAX ((__INT_MAX__<<1)+1)
#define FT_LONG_MAX __LONG_MAX__
#define FT_ULONG_MAX ((__LONG_MAX__<<1)+1)
#define SHRT_MAX __SHRT_MAX__


#include <include/ft2build.h>
#include FT_FREETYPE_H

