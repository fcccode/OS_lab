/* define the constant need by protect mode such as idt, gdt */
#ifndef __PM_H 
#define __PM_H 

#include "../include/defines.h"

/* ref: http://wiki.osdev.org/GDT */
/* ref: http://wiki.osdev.org/IDT */

#define FLAG_IF 0x200

#define NGDT 256

#define AC_AC 0x1       // access
#define AC_RW 0x2       // readable for code selector & writeable for data selector
#define AC_DC 0x4       // direcion
#define AC_EX 0x8       // executable, code segment
#define AC_RE 0x10 
#define AC_PR 0x80      // persent in memory

#define AC_DPL_KERN 0x0  // RING 0 kernel level
#define AC_DPL_USER 0x60 // RING 3 user level

#define GDT_GR  0x8     // Granularity bit : limit in 4k blocks
#define GDT_SZ  0x4     // Default Operation Size : 32 bit protect mode

#define NGDT 256

// gdt selector 
#define SEL_KCODE   0x1
#define SEL_KDATA   0x2
#define SEL_VIDEO   0x3
#define SEL_STACK   0x4
#define SEL_UCODE   0x5
#define SEL_UDATA   0x6
#define SEL_TSS     0x7
#define SEL_UCODE0   0x8
#define SEL_UDATA0   0x9
#define SEL_UCODE1   0xa
#define SEL_UDATA1   0xb
#define SEL_UCODE2   0xc
#define SEL_UDATA2   0xd
#define SEL_UCODE3   0xe
#define SEL_UDATA3   0xf


#define RPL_KERN    0x0
#define RPL_USER    0x3

#define SEL_KERN_CODE 0x8
#define SEL_KERN_DATA 0x10
#define SEL_KERN_VIDEO 0x18
#define SEL_USER_CODE0   0x8 * 0x8
#define SEL_USER_DATA0   0x8 * 0x9
#define SEL_USER_CODE1   0x8 * 0xa
#define SEL_USER_DATA1   0x8 * 0xb
#define SEL_USER_CODE2   0x8 * 0xc
#define SEL_USER_DATA2   0x8 * 0xd
#define SEL_USER_CODE3   0x8 * 0xe
#define SEL_USER_DATA3   0x8 * 0xf

#define CPL_KERN    0x0
#define CPL_USER    0x3

struct gdt_entry{
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t base_middle;
    uint8_t access;
    unsigned limit_high: 4;
    unsigned flags: 4;
    uint8_t base_high;
} __attribute__((packed));

struct gdt_ptr{
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

#define NIDT 256

/* 386 32-bit gata type */
#define GATE_TASK 0x5
#define GATE_INT  0xe
#define GATE_TRAP 0xf

#define IDT_SS   0x1        // store segment
#define IDT_DPL_KERN 0x0    // descriptor privilege level
#define IDT_DPL_USER 0x6    
#define IDT_PR  0x8         // present in memory

struct idt_entry{
    uint16_t base_low;
    uint16_t selector;
    uint8_t always0;
    unsigned gate_type: 4;   // gate type
    unsigned flags: 4;  // S(0) DPL(1-2) P(3)
    uint16_t base_high;
} __attribute__((packed));

struct idt_ptr{
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

struct tss_entry{
    uint32_t link;
    uint32_t esp0;
    uint32_t ss0;
    uint32_t esp1;
    uint32_t ss1;
    uint32_t esp2;
    uint32_t ss2;
    uint32_t cr3;
    uint32_t eip;
    uint32_t eflags;
    uint32_t eax;
    uint32_t ecx;
    uint32_t edx;
    uint32_t ebx;
    uint32_t esp;
    uint32_t ebp;
    uint32_t esi;
    uint32_t edi;
    uint32_t es;
    uint32_t cs;
    uint32_t ss;
    uint32_t ds;
    uint32_t fs;
    uint32_t gs;
    uint32_t ldtr;
    uint16_t padding1;
    uint16_t iopb_off;
} __attribute__ ((packed));

/* kern/gdt.c */
extern "C" void gdt_init();
void tss_set(uint16_t ss0, uint32_t esp0);

/* kern/idt.c */
extern "C" void idt_init();
void idt_install(uint8_t num, uint32_t base, uint16_t selector, uint8_t gate, uint8_t flags);

#define USER_PROG_LOAD_ADDR 0xA100
#define USER_PROG_LOAD_SEG SEL_KERN_DATA
#endif
