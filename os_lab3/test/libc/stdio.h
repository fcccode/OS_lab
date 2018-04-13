#ifndef _STDIO_H
#define _STDIO_H

#include "../include/defines.h"
#include "sys/hhos.h"

#ifndef _HHOS_LIBC_TEST
#define EOF -1
#endif

#ifdef _HHOS_LIBC_TEST
namespace hhlibc {

#endif

#ifndef __cplusplus
extern "C" {
#endif
 
int putchar( int ch );
int puts(const char* string);
int vsprintf( char* buffer, const char* format, va_list vlist );
int sprintf( char *buffer, const char *format, ... );
int printf( const char* format, ... );

int getchar(void);
char *gets( char *str );
int vsscanf( const char* buffer, const char* format, va_list vlist );
int sscanf( const char* buffer, const char* format, ... );
int scanf( const char* format, ... );

int scanf( const char* format, ... );

#ifndef __cplusplus
}
#endif

#ifdef _HHOS_LIBC_TEST
}
#endif

#endif
