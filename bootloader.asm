bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7A00

    mov si, msg_a20
    call print

    call enable_a20

    mov si, msg_gdt
    call print
    lgdt [gdt_desc]

    mov si, msg_pae
    call print
    mov eax, cr4
    or eax, (1 << 5)  ; Set PAE bit (bit 5)
    mov cr4, eax

    mov si, msg_pe
    call print
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:pmode

bits 32
pmode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x8000

    mov esi, msg_done
    call print32

    jmp $

enable_a20:
    call .kb_wait
    mov al, 0xAD
    out 0x64, al
    
    call .kb_wait
    mov al, 0xD0
    out 0x64, al
    
    call .kb_wait2
    in al, 0x60
    push eax
    
    call .kb_wait
    mov al, 0xD1
    out 0x64, al
    
    call .kb_wait
    pop eax
    or al, 2
    out 0x60, al
    
    call .kb_wait
    mov al, 0xAE
    out 0x64, al
    ret

.kb_wait:
    in al, 0x64
    test al, 2
    jnz .kb_wait
    ret

.kb_wait2:
    in al, 0x64
    test al, 1
    jz .kb_wait2
    ret

print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

print32:
    mov edi, 0xB8000
    mov ah, 0x0F
.loop:
    lodsb
    test al, al
    jz .done
    stosw
    jmp .loop
.done:
    ret

msg_a20 db "Enabling A20...", 0
msg_gdt db "Loading GDT...", 0
msg_pae db "Enabling PAE...", 0
msg_pe db "Setting PE bit...", 0
msg_done db "Fully entered x32 with PAE!", 0

gdt:
    dq 0
    dw 0xFFFF, 0
    db 0, 0x9A, 0xCF, 0
    dw 0xFFFF, 0
    db 0, 0x92, 0xCF, 0
gdt_end:

gdt_desc:
    dw gdt_end - gdt - 1
    dd gdt

times 510-($-$$) db 0
dw 0xAA55
