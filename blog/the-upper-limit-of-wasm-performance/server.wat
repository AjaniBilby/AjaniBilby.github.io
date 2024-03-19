(module
	(type (;0;) (func (param i32) (result i32)))
	(type (;1;) (func (param i32 i32) (result i32)))
	(type (;2;) (func (param i32 i32 i32) (result i32)))
	(type (;3;) (func (param i32 i32 i32 i32) (result i32)))
	(type (;4;) (func (param i32 i32 i32 i32 i32) (result i32)))
	(type (;5;) (func))
	(type (;6;) (func (param i32)))
	(type (;7;) (func (param i32 i32)))
	(import "wasix_32v1" "fd_write" (func (;0;) (type 3)))
	(import "wasix_32v1" "fd_close" (func (;1;) (type 0)))
	(import "wasix_32v1" "sock_open"      (func (;2;) (type 3)))
	(import "wasix_32v1" "sock_bind"      (func (;3;) (type 1)))
	(import "wasix_32v1" "sock_listen"    (func (;4;) (type 1)))
	(import "wasix_32v1" "sock_accept_v2" (func (;5;) (type 3)))
	(import "wasix_32v1" "sock_send"      (func (;6;) (type 4)))
	(import "wasix_32v1" "sock_status"    (func (;7;) (type 1)))
	(import "wasix_32v1" "proc_exit"      (func (;8;) (type 6)))
	(import "wasix_32v1" "sock_shutdown"  (func (;9;) (type 1)))

	;; main()
	(func (;10;) (type 5) (local i32 i32)
		;; Create socket using sock_open
		i32.const 1    ;; PF_NET
		i32.const 1    ;; SOCK_STREAM
		i32.const 0    ;; Protocol
		i32.const 255  ;; result pointer
		call 2         ;; sock_open()

		;; panic on error @
		i32.const 31
		call 11

		;; Load the socket descriptor from memory
		i32.const 255
		i32.load
		local.set 0

		;; Bind socket to address and port
		local.get 0   ;; Socket file descriptor
		i32.const 48  ;; Address of the sockaddr_in structure
		call 3        ;; sock_bind()

		;; panic on error @
		i32.const 44
		call 11

		local.get 0
		call 13 ;; sock_status_print()
		drop

		;; Listen for incoming connections
		local.get 0     ;; Socket file descriptor
		i32.const 100   ;; Backlog (maximum pending connections)
		call 4          ;; sock_listen()

		;; panic on error @
		i32.const 56
		call 11

		local.get 0
		call 13 ;; sock_status_print()
		drop

		(loop
			local.get 0    ;; Listening socket file descriptor
			i32.const 0    ;; Desired file descriptor flags (default)
			i32.const 64   ;; result pointer: new socket
			i32.const 160  ;; result pointer: remote address
			call 5         ;; sock_accept_v2()

			;; panic on error @
			i32.const 69
			call 11

			;; Load the new socket descriptor from memory
			i32.const 64
			i32.load
			local.set 1

			;; Send response to the client
			local.get 1    ;; socket
			i32.const 80   ;; iovs
			i32.const 1    ;; iovs_len
			i32.const 0    ;; No additional flags
			i32.const 160  ;; ptr: remote address
			call 6         ;; sock_send()

			;; panic on error @
			i32.const 93
			call 11

			;; Shutdown the socket
			local.get 1 ;; socket
			i32.const 2 ;; how: SHUT_RDWR
			call 9      ;; sock_shutdown()
			drop

			;; Close the fd
			local.get 1 ;; socket
			call 1      ;; fd_close()
			drop

			br 0
		)
	)

	;; panicOnError(code: i32, lineNum: i32)
	(func (;11;) (type 7) (param i32 i32)
		local.get 0
		i32.const 0
		i32.eq
		if
			return
		end

		;; overwrite string encoding param.0
		i32.const 14
		local.get 0
		i32.const 100
		i32.div_u
		i32.const 2
		call 12
		i32.store8

		i32.const 15
		local.get 0
		i32.const 10
		i32.div_u
		i32.const 1
		call 12
		i32.store8

		i32.const 16
		local.get 0
		i32.const 0
		call 12
		i32.store8

		;; overwrite string encoding param.1
		i32.const 20
		local.get 1
		i32.const 100
		i32.div_u
		i32.const 2
		call 12
		i32.store8

		i32.const 21
		local.get 1
		i32.const 10
		i32.div_u
		i32.const 1
		call 12
		i32.store8

		i32.const 22
		local.get 1
		i32.const 0
		call 12
		i32.store8

		;; write to buffer
		i32.const 1   ;; std.io file descriptor
		i32.const 0   ;; iovs
		i32.const 1   ;; iovs_len
		i32.const 255 ;; nwritten
		call 0        ;; fd_write
		drop

		local.get 0
		call 8
	)

	;; digitToChar(num: i32, place: i32)
	(func (;12;) (type 1) (param i32 i32) (result i32) (local i32)
		local.get 0
		i32.const 10
		i32.rem_u
		local.set 2

		local.get 1
		i32.const 0
		i32.ne
		if
			local.get 2
			i32.const 0
			i32.eq
			if
				i32.const 95
				return
			end
		end

		local.get 2
		i32.const 48
		i32.add
		return
	)

	;; sock_status_print(fd: i32)
	(func (;13;) (type 0) (param i32) (result i32) (local i32)
		local.get 0    ;; socket
		i32.const 255  ;; ptr: status
		call 7         ;; sock_status()

		;; panic on error @
		i32.const 185
		call 11

		i32.const 255
		i32.load
		local.set 1

		;; overwrite string encoding
		i32.const 145
		local.get 1
		i32.const 100
		i32.div_u
		i32.const 2
		call 12
		i32.store8

		i32.const 146
		local.get 1
		i32.const 10
		i32.div_u
		i32.const 1
		call 12
		i32.store8

		i32.const 147
		local.get 1
		i32.const 0
		call 12
		i32.store8

		;; write to buffer
		i32.const 1    ;; std.io file descriptor
		i32.const 124  ;; iovs
		i32.const 1    ;; iovs_len
		i32.const 255  ;; nwritten
		call 0         ;; fd_write
		drop

		local.get 1
		return
	)

	;; sock_wait_opened(fd: i32)
	(func (;14;) (type 6) (param i32)
		block
			loop
				local.get 0
				call 13 ;; sock_status_print()

				i32.const 0
				i32.ne
				if
					br 2
				end
				br 0
			end
		end
	)

	(memory (;0;) 1)
	(export "memory" (memory 0))
	(export "_start" (func 10))

	(data (i32.const 0) "\08\00\00\00\10\00\00\00")
	(data (i32.const 8) "Panic ??? @ ???\0a")

	;; sockaddr_in
	(data (i32.const 48) "\01\00")                   ;; sin_family: AF_INET = 0x0001
	(data (i32.const 50) "\90\1f")                   ;; sin_port:      8080 = 0x1F90
	(data (i32.const 52) "\00\00\00\00")             ;; sin_addr:INADDR_ANY = 0.0.0.0
	(data (i32.const 56) "\00\00\00\00\00\00\00\00") ;; sin_zero = char[8] padding for sockaddr compatibility

	;; http response
	(data (i32.const 80) "\58\00\00\00\24\00\00\00")
	(data (i32.const 88) "HTTP/1.1 200 OK\0d\0a\0d\0aHello, World!")

	(data (i32.const 124) "\84\00\00\00\14\00\00\00")
	(data (i32.const 132) "Sock Status: ???\0d\0a")

	;; global: remote sock_addr
	(data (i32.const 160) "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00")

	;; stack: offset.255
)