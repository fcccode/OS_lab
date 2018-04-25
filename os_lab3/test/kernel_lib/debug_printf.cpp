//
// Created by 李新锐 on 23/04/2018.
//

#include "./debug_printf.h"
#include "./sys_utility.h"
#include "../libc/string.h"
#include "../libc/stdlib.h"
#include "../libc/ctype.h"

static int putchar( int ch )
{
    sys_dbg_bochs_putc(ch);
    return ch;
}

static int puts(const char* string)
{
    auto len = strlen(string);
    for(size_t i = 0; i < len; ++i)
    {
        putchar(*(string + i));
    }
    return 0;
}
static int vsprintf( char* buffer, const char* format, va_list vlist )
{
    auto len_fmt = strlen(format);
    auto p_fmt = format;
    auto p_buf = buffer;
    while(len_fmt--)
    {
        if(*p_fmt != '%')
        {
            *(p_buf++) = *(p_fmt++);    //非控制字符
            continue;
        }
        else
        {
            //此时p_fmt = '%'
            char specifier = *(++p_fmt); //%后面一个字符是specifier
            ++p_fmt;                     //记录specifier并跳过
            switch (specifier)
            {
                case 'c':
                {
                    /*
                    依据C语言标准
                    If you pass an integral value with conversion rank
                    smaller than that of int (e. g. char, bool or short)
                     to a function taking a variable number of arguments,
                     it will be converted to int
                    */
                    *(p_buf++) = va_arg(vlist, int);
                    break;
                }
                case 's':
                {
                    const char * str = va_arg(vlist, char*);
                    strcpy(p_buf, str);
                    p_buf += strlen(str);               //p应当永远指向有意义的字符后面一位
                    break;
                }
                case 'd':
                case 'i':
                {
                    int num = va_arg(vlist, int);
                    itoa(p_buf, num, 10);
                    p_buf += strlen(p_buf);             //同理
                    break;
                }
                case 'o':
                {
                    unsigned int num = va_arg(vlist, int);
                    itoa(p_buf, num, 8);
                    p_buf += strlen(p_buf);             //同理
                    break;
                }
                case 'x':
                {
                    unsigned int num = va_arg(vlist, int);
                    itoa(p_buf, num, 16);
                    p_buf += strlen(p_buf);             //同理
                    break;
                }
                case 'X':
                {
                    unsigned int num = va_arg(vlist, int);
                    itoa(p_buf, num, 16, true);
                    p_buf += strlen(p_buf);             //同理
                    break;
                }
                case 'u':
                {
                    unsigned int num = va_arg(vlist, int);
                    itoa(p_buf, num, 10);
                    p_buf += strlen(p_buf);             //同理
                    break;
                }
                default:
                {
                    break;
                }
            }
        }
    }
    *p_buf = '\0';
    return p_buf - buffer;
}

static int sprintf( char *buffer, const char *format, ... )
{
    int ret;
    va_list va;
    va_start(va, format);
    ret = vsprintf(buffer, format, va);
    va_end(va);
    return ret;
}
static char printbuf[80*25];
//TODO 关于这个返回值
int debug_printf( const char* format, ... )
{
    int ret;
    va_list va;
    va_start(va, format);
    ret = vsprintf(printbuf, format, va);
    va_end(va);
    puts(printbuf);
    return ret;
}
static int tty_putchar(tty& dbg_tty, int ch )
{
    sys_dbg_bochs_putc(ch);
    dbg_tty.putchar(ch);
    return ch;
}
static int tty_puts(tty& dbg_tty, const char* string)
{
    auto len = strlen(string);
    for(size_t i = 0; i < len; ++i)
    {
        tty_putchar(dbg_tty, *(string + i));
    }
    return 0;
}
int tty_debug_printf(tty& dbg_tty, const char* format, ... )
{
    int ret;
    va_list va;
    va_start(va, format);
    ret = vsprintf(printbuf, format, va);
    va_end(va);
    tty_puts(dbg_tty, printbuf);
    return ret;
}