// Copyright 2016 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build mips || mipsle
// +build mips mipsle

#include "textflag.h"

// Called by C code generated by cmd/cgo.
// func crosscall2(fn, a unsafe.Pointer, n int32, ctxt uintptr)
// Saves C callee-saved registers and calls cgocallback with three arguments.
// fn is the PC of a func(a unsafe.Pointer) function.
TEXT crosscall2(SB),NOSPLIT|NOFRAME,$0
	/*
	 * We still need to save all callee save register as before, and then
	 *  push 3 args for fn (R4, R5, R7), skipping R6.
	 * Also note that at procedure entry in gc world, 4(R29) will be the
	 *  first arg.
	 */

	// Space for 9 caller-saved GPR + LR + 6 caller-saved FPR.
	// O32 ABI allows us to smash 16 bytes argument area of caller frame.
#ifndef GOMIPS_softfloat
	SUBU	$(4*14+8*6-16), R29
#else
	SUBU	$(4*14-16), R29	// For soft-float, no FPR.
#endif
	MOVW	R4, (4*1)(R29)	// fn unsafe.Pointer
	MOVW	R5, (4*2)(R29)	// a unsafe.Pointer
	MOVW	R7, (4*3)(R29)	// ctxt uintptr
	MOVW	R16, (4*4)(R29)
	MOVW	R17, (4*5)(R29)
	MOVW	R18, (4*6)(R29)
	MOVW	R19, (4*7)(R29)
	MOVW	R20, (4*8)(R29)
	MOVW	R21, (4*9)(R29)
	MOVW	R22, (4*10)(R29)
	MOVW	R23, (4*11)(R29)
	MOVW	g, (4*12)(R29)
	MOVW	R31, (4*13)(R29)
#ifndef GOMIPS_softfloat
	MOVD	F20, (4*14)(R29)
	MOVD	F22, (4*14+8*1)(R29)
	MOVD	F24, (4*14+8*2)(R29)
	MOVD	F26, (4*14+8*3)(R29)
	MOVD	F28, (4*14+8*4)(R29)
	MOVD	F30, (4*14+8*5)(R29)
#endif
	JAL	runtime·load_g(SB)

	JAL	runtime·cgocallback(SB)

	MOVW	(4*4)(R29), R16
	MOVW	(4*5)(R29), R17
	MOVW	(4*6)(R29), R18
	MOVW	(4*7)(R29), R19
	MOVW	(4*8)(R29), R20
	MOVW	(4*9)(R29), R21
	MOVW	(4*10)(R29), R22
	MOVW	(4*11)(R29), R23
	MOVW	(4*12)(R29), g
	MOVW	(4*13)(R29), R31
#ifndef GOMIPS_softfloat
	MOVD	(4*14)(R29), F20
	MOVD	(4*14+8*1)(R29), F22
	MOVD	(4*14+8*2)(R29), F24
	MOVD	(4*14+8*3)(R29), F26
	MOVD	(4*14+8*4)(R29), F28
	MOVD	(4*14+8*5)(R29), F30

	ADDU	$(4*14+8*6-16), R29
#else
	ADDU	$(4*14-16), R29
#endif
	RET
