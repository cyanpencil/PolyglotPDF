BITS 64
		org     0x400000
ehdr:                                                 ; Elf32_Ehdr
		db      0x7F, "ELFORNOTELF??"         ;   e_ident
		times 2 db      0
		dw      2                               ;   e_type
		dw      0x3e                            ;   e_machine
		dd      1                               ;   e_version
		dq      _start                          ;   e_entry
		dq      phdr - $$                       ;   e_phoff
		dq      0                               ;   e_shoff
		dd      0                               ;   e_flags
		dw      ehdrsize                        ;   e_ehsize
		dw      phdrsize                        ;   e_phentsize
		dw      1                               ;   e_phnum
		dw      0                               ;   e_shentsize
		dw      0                               ;   e_shnum
		dw      0                               ;   e_shstrndx

ehdrsize      equ     $ - ehdr

phdr:                                                 ; Elf64_Phdr
		dd      1                               ;   p_type
		dd      5                               ;   p_flags
		dq      0                               ;   p_offset
		dq      $$                              ;   p_vaddr
		dq      $$                              ;   p_paddr
		dq      filesize                        ;   p_filesz
		dq      filesize                        ;   p_memsz
		dq      0x1000                          ;   p_align

phdrsize      equ     $ - phdr

;_open:
		;mov rax, 2
		;mov rdi, $rsp
		;mov rsi, 0
		;mov rdx, 0
		;syscall

_strlen: ;strlen(rsi) - return len in rdx
		mov rdx, -1

	loop:
		inc rdx
		mov bl, [rsi + rdx]
		test rbx, rbx
		jg loop
		
		ret


_code:
		;db 19, 17, 21, 23, 0, 9, 0, 9, 31, 21, 13, 92, 26, 106, 50, 103, 13, 15, 18, 5, 37, 51, 30, 61, 7, 91, 69, 39, 63
		db 23, 23, 27, 2, 21, 26, 68, 3, 29, 2, 81, 0, 23, 56, 1, 5, 38, 95, 61, 49, 47, 15, 18, 5, 37, 51, 30, 61, 7, 91, 69, 0,0,0, 39, 18

_patch:
		add rsi, 0x25d + filesize
		mov rdi, _code
		mov rbx, 0

	loop3:
		mov al, [_code + rbx]
		xor byte [rsi + rbx], al
		inc rbx
		cmp bl, 35
		jbe loop3

		ret

_open_myself:
		mov rax, 2
		mov rdi, [rsp + 16]
		mov rsi, 0
		mov rdx, 0
		syscall ; open("a.out", O_RDONLY)
		mov r8, rax

		mov rdi, r8
		mov rax, 0
		lea rsi, [rsp - 35000]
		mov rdx, 35000
		syscall ; read


		lea rsi, [rsp - 35000]
		call _patch

		mov rax, 87
		mov rdi, [rsp + 16]
		syscall ; unlink("a.out")

		mov rax, 2
		mov rdi, [rsp + 16]
		mov rsi, 65
		mov rdx, 511 
		syscall ; open("a.out", O_WRITE, 0777)
		mov r8, rax

		mov rax, 1 
		mov rdi, r8
		lea rsi, [rsp - 35000]
		mov rdx, 35000
		syscall

		ret

_check:
		mov rsi, [rsp + 16]
		call _strlen
		inc rdx
		add rsi, rdx
		call _strlen

		cmp byte [rsi + 0], 'c'
		jne _wrong
		cmp byte [rsi + 1], 'i'
		jne _wrong
		cmp byte [rsi + 2], 'a'
		jne _wrong
		cmp byte [rsi + 3], 'o'
		jne _wrong

		call _good

		ret

_start:
		;mov rax, 1 
		;mov rdi, 1
		;mov rsi, ehdr + 4
		;mov rdx, 80
		;syscall
		;call _exit

		call _check
		call _open_myself
		call _exit

_wrong:
		mov rax, 1
		mov rdi, 1
		lea rsi, [rsp - 16]

		mov dword [rsi], "Wron"
		mov dword [rsi + 4], "g!!!"
		mov byte [rsi + 8], 0x0a

		mov rdx, 9
		syscall

		call _exit

		ret

_good:
		mov rax, 1
		mov rdi, 1
		lea rsi, [rsp - 16]

		mov dword [rsi], "Nice"
		mov byte [rsi + 4], 0x0a

		mov rdx, 5
		syscall

		ret
	

_exit:
		mov rax, 60
		mov rdi, 42
		syscall

filesize      equ     $ - $$
