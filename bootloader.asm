bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    cld

enable_a20:
    in al, 0x92
    test al, 2
    jnz a20_done
    or al, 2
    and al, 0xFE
    out 0x92, al

a20_done:
    mov si, a20_msg
    call print_string

    lgdt [gdt_descriptor]
    mov si, gdt_msg
    call print_string

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp 0x08:protected_mode

bits 32
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    hlt

bits 16
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

gdt_start:
    dq 0x0
    dw 0xFFFF, 0x0, 0x9A00, 0x00CF
    dw 0xFFFF, 0x0, 0x9200, 0x00CF

gdt_descriptor:
    dw gdt_descriptor - gdt_start - 1
    dd gdt_start

a20_msg db 'A20 loaded', 0x0D, 0x0A, 0
gdt_msg db 'GDT loaded', 0x0D, 0x0A, 0

times 510 - ($-$$) db 0
dw 0xAA55
