// pointwise_add pointwise_sub

.syntax unified
.thumb

.align 2
.global pointwise_sub
.type pointwise_sub, %function
pointwise_sub:
  push.w {r4-r11, lr}

  movw r14, #51
  1:
    ldrsh.w r4, [r1, #2]
    ldrsh.w r5, [r1, #4]
    ldrsh.w r6, [r1, #6]
    ldrsh.w r7, [r1, #8]
    ldrsh.w r3, [r1], #10
    ldrsh.w r9, [r2, #2]
    ldrsh.w r10, [r2, #4]
    ldrsh.w r11, [r2, #6]
    ldrsh.w r12, [r2, #8]
    ldrsh.w r8, [r2], #10

    sub.w r3, r3, r8
    sub.w r4, r4, r9
    sub.w r5, r5, r10
    sub.w r6, r6, r11
    sub.w r7, r7, r12

    strh.w r4, [r0, #2]
    strh.w r5, [r0, #4]
    strh.w r6, [r0, #6]
    strh.w r7, [r0, #8]
    strh.w r3, [r0], #10
    subs.w r14, #1
  bne.w 1b

  ldrsh.w r3, [r1]
  ldrsh.w r4, [r2]
  sub.w r3, r3, r4
  strh.w r3, [r0]

  pop.w {r4-r11, pc}


.align 2
.global pointwise_add
.type pointwise_add, %function
pointwise_add:
  push.w {r4-r11, lr}
  movw.w r14, #51
  1:
    ldrsh.w r4, [r1, #2]
    ldrsh.w r5, [r1, #4]
    ldrsh.w r6, [r1, #6]
    ldrsh.w r7, [r1, #8]
    ldrsh.w r3, [r1], #10
    ldrsh.w r9, [r2, #2]
    ldrsh.w r10, [r2, #4]
    ldrsh.w r11, [r2, #6]
    ldrsh.w r12, [r2, #8]
    ldrsh.w r8, [r2], #10

    add.w r3, r3, r8
    add.w r4, r4, r9
    add.w r5, r5, r10
    add.w r6, r6, r11
    add.w r7, r7, r12

    strh.w r4, [r0, #2]
    strh.w r5, [r0, #4]
    strh.w r6, [r0, #6]
    strh.w r7, [r0, #8]
    strh.w r3, [r0], #10
    subs.w r14, #1
  bne.w 1b

  ldrsh.w r3, [r1]
  ldrsh.w r4, [r2]
  add.w r3, r3, r4
  strh.w r3, [r0]
  pop.w {r4-r11, pc}
