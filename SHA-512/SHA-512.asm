.arch rhody			;use rhody.cfg
.outfmt hex			;output format is hex
.memsize 2048			;specify 2K words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define part to be included in user's program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.define tx		0x0900	;text video X (0 - 79)
.define ty		0x0901	;text video Y (0 - 59)
.define taddr		0x0902	;text video address
.define tascii		0x0903	;text video ASCII code
.define cursor		0x0904	;ASCII for text cursor
.define prompt		0x0905	;prompt length for BS left limit
.define tnum		0x0906	;text video number to be printed
.define format		0x0907	;number output format
.define gx		0x0908	;graphic video X (0 - 799)
.define gy		0x0909	;graphic video Y (0 - 479)
.define gaddr		0x090A	;graphic video address
.define color		0x090B	;color for graphic
.define x1		0x090C	;x1 for line/circle
.define y1		0x090D	;y1
.define x2		0x090E	;x2 for line
.define y2		0x090F	;y2
.define rad		0x0910	;radius for circle
.define	string		0x0911	;string pointer
;I/O Address;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.define kcntrl		0xf0000	;keyboard control register
.define kascii		0xf0001	;keyboard ASCII code
.define vcntrl		0xf0002	;video control register
.define time0		0xf0003	;Timer 0
.define time1		0xf0004	;Timer 1
.define inport 		0xf0005	;GPIO read address
.define outport		0xf0005	;GPIO write address
.define rand		0xf0006	;random number
.define msx		0xf0007	;mouse X
.define msy		0xf0008	;mouse Y
.define msrb		0xf0009	;mouse right button
.define mslb		0xf000A	;mouse left button
.define trdy		0xf0010	;touch ready
.define tcnt		0xf0011	;touch count
.define gesture		0xf0012	;touch gesture
.define tx1		0xf0013	;touch X1
.define ty1		0xf0014	;touch Y1
.define tx2		0xf0015	;touch X2
.define ty2		0xf0016	;touch Y2
.define tx3		0xf0017	;touch X3
.define ty3		0xf0018	;touch Y3
.define tx4		0xf0019	;touch X4
.define ty4		0xf001A	;touch Y4
.define tx5		0xf001B	;touch X5
.define ty5		0xf001C	;touch Y5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SHA512 Program variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.define m1024		0x0800	;32 words M 0x800-0x81F
.define w80		0x0820	;160 words W 0x820-0x8BF
.define wva		0x08C0	;working variable a H
.define wval		0x08C1	;working variable a L
.define wvb		0x08C2	;working variable b H
.define wvbl		0x08C3	;working variable b L
.define wvc		0x08C4	;working variable c H
.define wvcl		0x08C5	;working variable c L
.define wvd		0x08C6	;working variable d H
.define wvdl		0x08C7	;working variable d L
.define wve		0x08C8	;working variable e H
.define wvel		0x08C9	;working variable e L
.define wvf 		0x08CA	;working variable f H
.define wvfl		0x08CB	;working variable f L
.define wvg 		0x08CC	;working variable g H
.define wvgl		0x08CD	;working variable g L
.define wvh 		0x08CE	;working variable h H
.define wvhl		0x08CF	;working variable h L
.define h0		0x08D0	;hash value 0 H
.define h0l 		0x08D1	;hash value 0 L
.define h1		0x08D2	;hash value 1 H
.define h1l		0x08D3	;hash value 1 L
.define h2		0x08D4	;hash value 2 H
.define h2l 		0x08D5	;hash value 2 L
.define h3		0x08D6	;hash value 3 H
.define h3l		0x08D7	;hash value 3 L
.define h4		0x08D8	;hash value 4 H
.define h4l		0x08D9	;hash value 4 L
.define h5		0x08DA	;hash value 5 H
.define h5l 		0x08DB	;hash value 5 L
.define h6		0x08DC	;hash value 6 H
.define h6l		0x08DD	;hash value 6 L
.define h7		0x08DE	;hash value 7 H
.define h7l		0x08DF	;hash value 7 L
.define t1		0x08E2	;temporary value 1
.define t2		0x08E3	;temporary value 2
.define t1l		0x08E4	; temp reg 1 lower
.define t2l		0x08E5	; temp reg 2 lower
.define count		0x08E0	;hash count
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;User defined SHA512 Program variables
;The unused data memory spaces are:
; 0x08E1 -- 0x08FF
; 0x0912 -- 0x09FF
;;;;;;;;;;;;;;2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SHA512_time_trial:
;The HASH subroutine is checked first with
;pre-defined message and answer.
;Then, use randomly generated message for SHA-512
;count how many hashes per seconds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHA512_time_trial:
	ldi	r0, 0
	stm	format, r0
	sys	clear
	ldi	r0, m1024
	ldi	r1, test_message
	ldi	r2, 32
test1:	
	ldr	r3, r1		;copy test message to buffer
	str	r0, r3
	adi	r0, 1
	adi	r1, 1
	adi	r2, 0xffff
	jnz	test1
	call	HASH		;produce hash for the test message
	ldi	r0, h0
	ldi	r1, answer
	ldi	r2, 16
test2:	
	ldr	r3, r0
	ldr	r4, r1
	cmp	r3, r4
	jnz	wrong		;subroutine HASH is wrong
	adi	r0, 1
	adi	r1, 1
	adi	r2, 0xffff
	jnz	test2
;prepare hash count and timer
	ldi	r0, 0
	stm	count, r0
	ldi	r0, 1
	stm	time0, r0	;turn on 1-second timer
;Prepare the random inputs;;;;;;;;;;;;;;;;;;;;;;;;
sha1:	ldi	r5, m1024	;pointer to message buffer
	ldi	r2, 16
sha2:	ldm	r0, rand	;get random number
	str	r5, r0	
	adi	r5, 1
	adi	r2, 0xFFFF
	jnz	sha2
	ldh	r0, 0x8000
	ldl	r0, 0x0000
	str	r5, r0		;stop byte in 17th word
	ldi	r0, 0
	adi	r5, 1
	ldi	r2, 14		;fill in '0' to 14 words
sha3:	str	r5, r0	
	adi	r5, 1
	adi	r2, 0xFFFF
	jnz	sha3
	ldi	r0, 0x0200	;length=512
	str	r5, r0
	call	HASH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldm	r0, count
	adi	r0, 1
	stm	count, r0	;inc hash count
	ldm	r0, time0
	ldm	r1, timeup
	cmp	r0, r1		;>= time up?
	js	sha1
	ldi	r0, 0
	stm	tx, r0
	stm	ty, r0
	ldm	r0, count
	stm	tnum, r0
	sys	printn
	ldi	r0, hashps
	stm	string, r0
	sys	prints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
halt:	jmp	halt		;print count and stop
timeup:	word	1000000		;1sec = 1000000us
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HASH subroutine produced wrong hash
;print "dead" on 7-segment displays and stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrong:
	ldi	r0, 0xdead
	stm	outport, r0
wrong_stop:
	jmp	wrong_stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pre-defined test message: this is a test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test_message:
	word	0x74686973	;this
	word	0x20697320	; is 
	word	0x61207465	;a te
	word	0x73748000	;st
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000000
	word	0x00000070	;message length in bits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hash for pre-define test message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
answer:
	word	0x7d0a8468
	word	0xed220400
	word	0xc0b8e6f3
	word	0x35baa7e0
	word	0x70ce880a
	word	0x37e2ac59
	word	0x95b9a97b
	word	0x809026de
	word	0x626da636
	word	0xac736524
	word	0x9bb974c7
	word	0x19edf543
	word	0xb52ed286
	word	0x646f437d
	word	0xc7f810cc
	word	0x2068375c
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hash per second
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hashps:
	byte	0x20
	byte	0x68		;h
	byte	0x61		;a
	byte	0x73		;s
	byte	0x68		;h
	byte	0x2F		;/
	byte	0x73		;s
	byte	0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The 80 64-bit K constants in 160 32-bit words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
K512:	word	0x428a2f98	;k0	K Constant
	word	0xd728ae22
	word	0x71374491	;k1
	word	0x23ef65cd 
	word	0xb5c0fbcf	;k2
	word	0xec4d3b2f 
	word	0xe9b5dba5	;k3
	word	0x8189dbbc 
	word	0x3956c25b	;k4
	word	0xf348b538 
	word	0x59f111f1	;k5
	word	0xb605d019 
	word	0x923f82a4	;k6
	word	0xaf194f9b 
	word	0xab1c5ed5	;k7
	word	0xda6d8118 
	word	0xd807aa98	;k8
	word	0xa3030242 
	word	0x12835b01	;k9
	word	0x45706fbe 
	word	0x243185be	;k10
	word	0x4ee4b28c 
	word	0x550c7dc3	;k11
	word	0xd5ffb4e2 
	word	0x72be5d74	;k12
	word	0xf27b896f 
	word	0x80deb1fe	;k13
	word	0x3b1696b1 
	word	0x9bdc06a7	;k14
	word	0x25c71235 
	word	0xc19bf174	;k15
	word	0xcf692694 
	word	0xe49b69c1	;k16
	word	0x9ef14ad2 
	word	0xefbe4786	;k17
	word	0x384f25e3 
	word	0x0fc19dc6	;k18
	word	0x8b8cd5b5 
	word	0x240ca1cc	;k19
	word	0x77ac9c65 
	word	0x2de92c6f	;k20
	word	0x592b0275 
	word	0x4a7484aa	;k21
	word	0x6ea6e483 
	word	0x5cb0a9dc	;k22
	word	0xbd41fbd4 
	word	0x76f988da	;k23
	word	0x831153b5 
	word	0x983e5152	;k24
	word	0xee66dfab 
	word	0xa831c66d	;k25
	word	0x2db43210 
	word	0xb00327c8	;k26
	word	0x98fb213f 
	word	0xbf597fc7	;k27
	word	0xbeef0ee4 
	word	0xc6e00bf3	;k28
	word	0x3da88fc2 
	word	0xd5a79147	;k29
	word	0x930aa725 
	word	0x06ca6351	;k30
	word	0xe003826f 
	word	0x14292967	;k31
	word	0x0a0e6e70 
	word	0x27b70a85	;k32
	word	0x46d22ffc 
	word	0x2e1b2138	;k33
	word	0x5c26c926 
	word	0x4d2c6dfc	;k34
	word	0x5ac42aed 
	word	0x53380d13	;k35
	word	0x9d95b3df 
	word	0x650a7354	;k36
	word	0x8baf63de 
	word	0x766a0abb	;k37
	word	0x3c77b2a8 
	word	0x81c2c92e	;k38
	word	0x47edaee6 
	word	0x92722c85	;k39
	word	0x1482353b 
	word	0xa2bfe8a1	;k40
	word	0x4cf10364 
	word	0xa81a664b	;k41
	word	0xbc423001 
	word	0xc24b8b70	;k42
	word	0xd0f89791 
	word	0xc76c51a3	;k43
	word	0x0654be30 
	word	0xd192e819	;k44
	word	0xd6ef5218 
	word	0xd6990624	;k45
	word	0x5565a910 
	word	0xf40e3585	;k46
	word	0x5771202a 
	word	0x106aa070	;k47
	word	0x32bbd1b8 
	word	0x19a4c116	;k48
	word	0xb8d2d0c8 
	word	0x1e376c08	;k49
	word	0x5141ab53 
	word	0x2748774c	;k50
	word	0xdf8eeb99 
	word	0x34b0bcb5	;k51
	word	0xe19b48a8 
	word	0x391c0cb3	;k52
	word	0xc5c95a63 
	word	0x4ed8aa4a	;k53
	word	0xe3418acb 
	word	0x5b9cca4f	;k54
	word	0x7763e373 
	word	0x682e6ff3	;k55
	word	0xd6b2b8a3 
	word	0x748f82ee	;k56
	word	0x5defb2fc 
	word	0x78a5636f	;k57
	word	0x43172f60 
	word	0x84c87814	;k58
	word	0xa1f0ab72 
	word	0x8cc70208	;k59
	word	0x1a6439ec 
	word	0x90befffa	;k60
	word	0x23631e28 
	word	0xa4506ceb	;k61
	word	0xde82bde9 
	word	0xbef9a3f7	;k62
	word	0xb2c67915 
	word	0xc67178f2	;k63
	word	0xe372532b 
	word	0xca273ece	;k64
	word	0xea26619c 
	word	0xd186b8c7	;k65
	word	0x21c0c207 
	word	0xeada7dd6	;k66
	word	0xcde0eb1e 
	word	0xf57d4f7f	;k67
	word	0xee6ed178 
	word	0x06f067aa	;k68
	word	0x72176fba 
	word	0x0a637dc5	;k69
	word	0xa2c898a6 
	word	0x113f9804	;k70
	word	0xbef90dae 
	word	0x1b710b35	;k71
	word	0x131c471b 
	word	0x28db77f5	;k72
	word	0x23047d84 
	word	0x32caab7b	;k73
	word	0x40c72493 
	word	0x3c9ebe0a	;k74
	word	0x15c9bebc 
	word	0x431d67c4	;k75
	word	0x9c100d4c 
	word	0x4cc5d4be	;k76
	word	0xcb3e42b6 
	word	0x597f299c	;k77
	word	0xfc657e2a 
	word	0x5fcb6fab	;k78
	word	0x3ad6faec 
	word	0x6c44198c	;k79
	word	0x4a475817 
	byte	0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The 8 64-bit initial H in 16 32-bit words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hinit:
	word	0x6a09e667	;H0	initial Hash
	word	0xf3bcc908
	word	0xbb67ae85	;H1
	word	0x84caa73b
	word	0x3c6ef372	;H2
	word	0xfe94f82b
	word	0xa54ff53a	;H3
	word	0x5f1d36f1
	word	0x510e527f	;H4
	word	0xade682d1
	word	0x9b05688c	;H5
	word	0x2b3e6c1f
	word	0x1f83d9ab	;H6
	word	0xfb41bd6b
	word	0x5be0cd19	;H7
	word	0x137e2179
	byte	0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HASH subroutine to generate the 512-bit message digest
;inputs: 
;  M = m1024 is the 16-words (64-bit word) input buffer
;		This is emulated using 32 32-bit words
;  W = w80 is the 80-word (64-bit word) message schedule
;		This is emulated using 160 32-bit words 
;  wva, wvb, ..., wvh = working variables a to h
;  K = K512 the 80 64-bit words constant array
;  Hinit is the 8 64-bit words initial H
;outputs:
;  h0 to h7 = hash values (each takes two 32-bit words)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HASH:	
	ldi	r5, m1024	;load pointer to starting memory address to m1024 into r5
	ldi	r7, w80		;load pointer to starting memory address to w80 into r7
sch1:	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word) UNROLLED LOOP
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)
	
	ldr	r0, r5		;store R5 contents (pointer to memory address of m1024) into R0 (upper half word)
	str	r7, r0		;store R0 contents into R7 (pointer to memory address of first address of m1024) into R7[mem] (first address of w80)
	adi	r5, 1		;increment R5 by 1 (point to next address of m1024)
	adi	r7, 1		;increment R7 by 1 (point to next address of w80)

	
	ldi	r2, 64		;load loop count
sch2:	
	mov	r6, r7		;move contents of r7 (pointer to buffer W) into r6
	adi	r6, 0xFFFC	;t-4
	ldr	r0, r6		;r0=W(t-4)
	adi	r6, 1		;increment r6 to point to t-3
	ldr	r1, r6		;r1=W(t-3)
	sig1	r0		;r0=sig1(W(t-4)), r1=sig1(W(t-3))
	mov	r6, r7		;move pointer to buffer into R6
	adi	r6, 0xFFF2	;t-14
	ldr	r4, r6		;r4=W(t-14)
	adi	r6, 1		;increment r6 so it becomes r6=W(t-13)
	ldr	r5, r6		;r5=W(t-13)
	add64	r0, r4		;r0&r1=r0&r1 + r4&r5 
	push 	r0		;push R0 onto stack (output of ADD64)
	push	r1		;push R1 onto stack (output of ADD64)
	mov	r6, r7
	adi	r6, 0xFFE2	;decrement R6 (t-30)
	ldr	r0, r6		;put R6 contents in R0 (R0=W(t-30))
	adi	r6, 1		;increment R6 to have t-29
	ldr	r1, r6		;put R6 contents into R1 (R1=W(t-29))
	sig0	r0		;call sig0 with r0&r1 as input
	mov	r6, r7		;move contents of r7 (w80) into r6
	adi	r6, 0xFFE0	;decrement R6 by 32 to have t-32
	ldr 	r4, r6		;put contents of R6 (W(t-32)) into R4
	adi	r6, 1		;increment R6 to point to W(t-31)
	ldr	r5, r6		;put W(t-31) into R5
	add64	r0, r4		;call ADD64 Function (W(t-30), W(t-29), W(t-32), W(t-31))
	pop	r5
	pop	r4
	add64	r0, r4	
	str 	r7, r0		;store R0 contents at address in R7
	adi	r7, 1		;increment R7 to point to next address
	str 	r7, r1		;store R1 contents at address in R7
	adi	r7, 1		;increment R7 to point to next address
	adi	r2, 0xFFFF	;decrement counter by 1
	jnz	sch2		;if counter does not equal 0 go back through loop sch2

	sch3			;sch3 instruction

	ldi	r6, 0		;index 0
	ldi	r7, 1		;index 1
sch4:
	ldix	r0, r6, k512	;k512[0]
	ldix	r1, r7, k512	;k512[1]
	ldix	r2, r6, w80	;w80[0]
	ldix	r3, r7, w80	;w80[1]
	sch4			;sch4 instruction call
	adi	r6, 2		;increment index 0 by 2
	adi	r7, 2		;increment index 1 by 2
	cmpi	r6, 160		;compare index 0 to 160, loop must run 80 times (80*2=160)
	jnz 	sch4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	sch50			;sch5 loop first instruction to calculate & assign values to registers
	s64	h0, r0, r1	;store h0 & h0l to memory
	s64	h1, r2, r3	;store h1 & h1l to memory
	s64	h2, r4, r5	;store h2 & h2l to memory
	s64	h3, r6, r7	;store h3 & h3l to memory
	sch51			;sch5 loop second instruction
	s64	h4, r0, r1	;store h4 & h4l to memory
	s64	h5, r2, r3	;store h5 & h5l to memory
	s64	h6, r4, r5	;store h6 & h6l to memory
	s64	h7, r6, r7	;store h7 & h7l to memory
	ret


