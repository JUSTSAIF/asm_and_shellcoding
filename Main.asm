
.386
.model flat, stdcall
.stack 4096
assume fs:nothing

.code
main PROC
	sub esp, 20h ; add 8 vars


	;;;;;;;; sub & add & div & mul ;;;;;;;;
	;mov eax, 10 ; set eax val 10
	;sub eax, 5  ; subtract 5 from eax
	;add eax, 15 ; add to eax 15 now eax equl 20
	; divide & mul
	;xor edx, edx
	;mov ecx, 2
	;div ecx ; or mul

	;;;;;;;; Function ;;;;;;;;
	;jmp callgma
	;GetMyAge:
	;	mov ebx, 2022; date now
	;	mov eax, 1995; your dob
	;	sub ebx, eax
	;callgma:
	;	call GetMyAge


	;;;;;;;; Loop ;;;;;;;;
	;mov ecx, 10
	;myLoop:
	;	add eax, 1
	;loop myLoop


	;;;;;;;; FIND KERNEL32 ;;;;;;;;
	xor eax, eax
	mov eax, [fs:30h]
	mov eax, [eax + 0ch]
	mov eax, [eax + 14h]
	mov eax, [eax]
	mov eax, [eax]
	mov eax, [eax + 10h]
	mov ebx, eax
	;;;; FIND NUMBER OF FUNCTIONS
	; ebx base addr of kernal32

	mov eax, [ebx + 3ch]
	add eax, ebx ; ebx now is "Offest to New EXE Header"

	mov eax, [eax + 78h] ; 78h = EXPORT Table - edx
	add eax, ebx

	mov ecx, [eax + 14h] ; 14h = num of func RVA - first item in the table //// Now Should the ECX value is count of of funcs `647`
	

	;;;;;;;; FIND WINEXEC POINTER ;;;;;;;;
	mov [ebp-4h], ecx ; Number Of Funs 

	mov edx, [eax + 1ch]
	add edx, ebx
	mov [ebp-8h], edx ;  Export Addr Table

	mov edx, [eax + 20h]
	add edx, ebx
	mov [ebp-0ch], edx ; Pointer Table

	mov edx, [eax + 24h]
	add edx, ebx
	mov [ebp-10h], edx ; Ordinal Table

	; WinExec\0 = 57 69 6E 45 78 65 63 00
	push 00636578h
	push 456E6957h

	mov [ebp-14h], esp

	xor eax, eax
	xor ecx, ecx

	FindWINEXEC:
		; 1st = ESI / WinExec
		; 2st = EDI / ...647

		mov esi, [ebp-14h] ; WinExec
		mov edi, [ebp-0ch] ; pointer table str

		cld

		mov edi, [edi + eax * 4]
		add edi, ebx
		mov cx, 8
		repe cmpsb

		jz findSuccess
		inc eax

		cmp [ebp-4h], eax
		jne FindWINEXEC
		jmp notFound

		findSuccess:
			;;;;; CALL WINEXEC ;;;;;
			mov ecx, [ebp-10h] ; Ordinal Table
			mov edx, [ebp-8h] ; Export Table

			; EAX = WinExec / 603h

			mov ax, [ecx + eax *2]
			mov eax, [edx + eax *4]
			add eax, ebx ; add kernel base / WinExec

			; cmd.exe = 63 6D 64  2E 65 78 65
			xor ecx, ecx
			push ecx
			push 6578652Eh
			push 646D63h

			mov edx, esp ; calc.exe in EDX
			push 10
			push edx 
			call eax

		notFound:
			mov eax, 404h
main ENDP
END main