//
// Created by 李新锐 on 23/04/2018.
//

#ifndef HHOS_DEBUG_PRINTF_H
#define HHOS_DEBUG_PRINTF_H

#include "../include/defines.h"
#include "../kernel/tty.h"

extern "C" {

int debug_printf( const char* format, ... );
int tty_debug_printf(tty& dbg_tty, const char* format, ... );
};
#endif //HHOS_DEBUG_PRINTF_H