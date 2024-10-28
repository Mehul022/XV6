
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	ac010113          	addi	sp,sp,-1344 # 80009ac0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	0000a797          	auipc	a5,0xa
    80000054:	93078793          	addi	a5,a5,-1744 # 80009980 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00007797          	auipc	a5,0x7
    80000066:	a4e78793          	addi	a5,a5,-1458 # 80006ab0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb37e7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	fb478793          	addi	a5,a5,-76 # 80001062 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05c63          	blez	a2,80000164 <consolewrite+0x62>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00003097          	auipc	ra,0x3
    80000138:	caa080e7          	jalr	-854(ra) # 80002dde <either_copyin>
    8000013c:	03550663          	beq	a0,s5,80000168 <consolewrite+0x66>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7da080e7          	jalr	2010(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	894e                	mv	s2,s3
    80000156:	64a6                	ld	s1,72(sp)
    80000158:	79e2                	ld	s3,56(sp)
    8000015a:	7a42                	ld	s4,48(sp)
    8000015c:	7aa2                	ld	s5,40(sp)
    8000015e:	7b02                	ld	s6,32(sp)
    80000160:	6be2                	ld	s7,24(sp)
    80000162:	a809                	j	80000174 <consolewrite+0x72>
    80000164:	4901                	li	s2,0
    80000166:	a039                	j	80000174 <consolewrite+0x72>
    80000168:	64a6                	ld	s1,72(sp)
    8000016a:	79e2                	ld	s3,56(sp)
    8000016c:	7a42                	ld	s4,48(sp)
    8000016e:	7aa2                	ld	s5,40(sp)
    80000170:	7b02                	ld	s6,32(sp)
    80000172:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000174:	854a                	mv	a0,s2
    80000176:	60e6                	ld	ra,88(sp)
    80000178:	6446                	ld	s0,80(sp)
    8000017a:	6906                	ld	s2,64(sp)
    8000017c:	6125                	addi	sp,sp,96
    8000017e:	8082                	ret

0000000080000180 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000180:	711d                	addi	sp,sp,-96
    80000182:	ec86                	sd	ra,88(sp)
    80000184:	e8a2                	sd	s0,80(sp)
    80000186:	e4a6                	sd	s1,72(sp)
    80000188:	e0ca                	sd	s2,64(sp)
    8000018a:	fc4e                	sd	s3,56(sp)
    8000018c:	f852                	sd	s4,48(sp)
    8000018e:	f456                	sd	s5,40(sp)
    80000190:	f05a                	sd	s6,32(sp)
    80000192:	1080                	addi	s0,sp,96
    80000194:	8aaa                	mv	s5,a0
    80000196:	8a2e                	mv	s4,a1
    80000198:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019a:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    8000019c:	00012517          	auipc	a0,0x12
    800001a0:	92450513          	addi	a0,a0,-1756 # 80011ac0 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	c0c080e7          	jalr	-1012(ra) # 80000db0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00012497          	auipc	s1,0x12
    800001b0:	91448493          	addi	s1,s1,-1772 # 80011ac0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00012917          	auipc	s2,0x12
    800001b8:	9a490913          	addi	s2,s2,-1628 # 80011b58 <cons+0x98>
  while(n > 0){
    800001bc:	0d305563          	blez	s3,80000286 <consoleread+0x106>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	0af71a63          	bne	a4,a5,8000027c <consoleread+0xfc>
      if(killed(myproc())){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	cb2080e7          	jalr	-846(ra) # 80001e7e <myproc>
    800001d4:	00003097          	auipc	ra,0x3
    800001d8:	a38080e7          	jalr	-1480(ra) # 80002c0c <killed>
    800001dc:	e52d                	bnez	a0,80000246 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	75a080e7          	jalr	1882(ra) # 8000293c <sleep>
    while(cons.r == cons.w){
    800001ea:	0984a783          	lw	a5,152(s1)
    800001ee:	09c4a703          	lw	a4,156(s1)
    800001f2:	fcf70de3          	beq	a4,a5,800001cc <consoleread+0x4c>
    800001f6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f8:	00012717          	auipc	a4,0x12
    800001fc:	8c870713          	addi	a4,a4,-1848 # 80011ac0 <cons>
    80000200:	0017869b          	addiw	a3,a5,1
    80000204:	08d72c23          	sw	a3,152(a4)
    80000208:	07f7f693          	andi	a3,a5,127
    8000020c:	9736                	add	a4,a4,a3
    8000020e:	01874703          	lbu	a4,24(a4)
    80000212:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000216:	4691                	li	a3,4
    80000218:	04db8a63          	beq	s7,a3,8000026c <consoleread+0xec>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000021c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000220:	4685                	li	a3,1
    80000222:	faf40613          	addi	a2,s0,-81
    80000226:	85d2                	mv	a1,s4
    80000228:	8556                	mv	a0,s5
    8000022a:	00003097          	auipc	ra,0x3
    8000022e:	b5c080e7          	jalr	-1188(ra) # 80002d86 <either_copyout>
    80000232:	57fd                	li	a5,-1
    80000234:	04f50863          	beq	a0,a5,80000284 <consoleread+0x104>
      break;

    dst++;
    80000238:	0a05                	addi	s4,s4,1
    --n;
    8000023a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000023c:	47a9                	li	a5,10
    8000023e:	04fb8f63          	beq	s7,a5,8000029c <consoleread+0x11c>
    80000242:	6be2                	ld	s7,24(sp)
    80000244:	bfa5                	j	800001bc <consoleread+0x3c>
        release(&cons.lock);
    80000246:	00012517          	auipc	a0,0x12
    8000024a:	87a50513          	addi	a0,a0,-1926 # 80011ac0 <cons>
    8000024e:	00001097          	auipc	ra,0x1
    80000252:	c12080e7          	jalr	-1006(ra) # 80000e60 <release>
        return -1;
    80000256:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000258:	60e6                	ld	ra,88(sp)
    8000025a:	6446                	ld	s0,80(sp)
    8000025c:	64a6                	ld	s1,72(sp)
    8000025e:	6906                	ld	s2,64(sp)
    80000260:	79e2                	ld	s3,56(sp)
    80000262:	7a42                	ld	s4,48(sp)
    80000264:	7aa2                	ld	s5,40(sp)
    80000266:	7b02                	ld	s6,32(sp)
    80000268:	6125                	addi	sp,sp,96
    8000026a:	8082                	ret
      if(n < target){
    8000026c:	0169fa63          	bgeu	s3,s6,80000280 <consoleread+0x100>
        cons.r--;
    80000270:	00012717          	auipc	a4,0x12
    80000274:	8ef72423          	sw	a5,-1816(a4) # 80011b58 <cons+0x98>
    80000278:	6be2                	ld	s7,24(sp)
    8000027a:	a031                	j	80000286 <consoleread+0x106>
    8000027c:	ec5e                	sd	s7,24(sp)
    8000027e:	bfad                	j	800001f8 <consoleread+0x78>
    80000280:	6be2                	ld	s7,24(sp)
    80000282:	a011                	j	80000286 <consoleread+0x106>
    80000284:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000286:	00012517          	auipc	a0,0x12
    8000028a:	83a50513          	addi	a0,a0,-1990 # 80011ac0 <cons>
    8000028e:	00001097          	auipc	ra,0x1
    80000292:	bd2080e7          	jalr	-1070(ra) # 80000e60 <release>
  return target - n;
    80000296:	413b053b          	subw	a0,s6,s3
    8000029a:	bf7d                	j	80000258 <consoleread+0xd8>
    8000029c:	6be2                	ld	s7,24(sp)
    8000029e:	b7e5                	j	80000286 <consoleread+0x106>

00000000800002a0 <consputc>:
{
    800002a0:	1141                	addi	sp,sp,-16
    800002a2:	e406                	sd	ra,8(sp)
    800002a4:	e022                	sd	s0,0(sp)
    800002a6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a8:	10000793          	li	a5,256
    800002ac:	00f50a63          	beq	a0,a5,800002c0 <consputc+0x20>
    uartputc_sync(c);
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	590080e7          	jalr	1424(ra) # 80000840 <uartputc_sync>
}
    800002b8:	60a2                	ld	ra,8(sp)
    800002ba:	6402                	ld	s0,0(sp)
    800002bc:	0141                	addi	sp,sp,16
    800002be:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002c0:	4521                	li	a0,8
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	02000513          	li	a0,32
    800002ce:	00000097          	auipc	ra,0x0
    800002d2:	572080e7          	jalr	1394(ra) # 80000840 <uartputc_sync>
    800002d6:	4521                	li	a0,8
    800002d8:	00000097          	auipc	ra,0x0
    800002dc:	568080e7          	jalr	1384(ra) # 80000840 <uartputc_sync>
    800002e0:	bfe1                	j	800002b8 <consputc+0x18>

00000000800002e2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e2:	7179                	addi	sp,sp,-48
    800002e4:	f406                	sd	ra,40(sp)
    800002e6:	f022                	sd	s0,32(sp)
    800002e8:	ec26                	sd	s1,24(sp)
    800002ea:	1800                	addi	s0,sp,48
    800002ec:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ee:	00011517          	auipc	a0,0x11
    800002f2:	7d250513          	addi	a0,a0,2002 # 80011ac0 <cons>
    800002f6:	00001097          	auipc	ra,0x1
    800002fa:	aba080e7          	jalr	-1350(ra) # 80000db0 <acquire>

  switch(c){
    800002fe:	47d5                	li	a5,21
    80000300:	0af48463          	beq	s1,a5,800003a8 <consoleintr+0xc6>
    80000304:	0297c963          	blt	a5,s1,80000336 <consoleintr+0x54>
    80000308:	47a1                	li	a5,8
    8000030a:	10f48063          	beq	s1,a5,8000040a <consoleintr+0x128>
    8000030e:	47c1                	li	a5,16
    80000310:	12f49363          	bne	s1,a5,80000436 <consoleintr+0x154>
  case C('P'):  // Print process list.
    procdump();
    80000314:	00003097          	auipc	ra,0x3
    80000318:	b22080e7          	jalr	-1246(ra) # 80002e36 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031c:	00011517          	auipc	a0,0x11
    80000320:	7a450513          	addi	a0,a0,1956 # 80011ac0 <cons>
    80000324:	00001097          	auipc	ra,0x1
    80000328:	b3c080e7          	jalr	-1220(ra) # 80000e60 <release>
}
    8000032c:	70a2                	ld	ra,40(sp)
    8000032e:	7402                	ld	s0,32(sp)
    80000330:	64e2                	ld	s1,24(sp)
    80000332:	6145                	addi	sp,sp,48
    80000334:	8082                	ret
  switch(c){
    80000336:	07f00793          	li	a5,127
    8000033a:	0cf48863          	beq	s1,a5,8000040a <consoleintr+0x128>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000033e:	00011717          	auipc	a4,0x11
    80000342:	78270713          	addi	a4,a4,1922 # 80011ac0 <cons>
    80000346:	0a072783          	lw	a5,160(a4)
    8000034a:	09872703          	lw	a4,152(a4)
    8000034e:	9f99                	subw	a5,a5,a4
    80000350:	07f00713          	li	a4,127
    80000354:	fcf764e3          	bltu	a4,a5,8000031c <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000358:	47b5                	li	a5,13
    8000035a:	0ef48163          	beq	s1,a5,8000043c <consoleintr+0x15a>
      consputc(c);
    8000035e:	8526                	mv	a0,s1
    80000360:	00000097          	auipc	ra,0x0
    80000364:	f40080e7          	jalr	-192(ra) # 800002a0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000368:	00011797          	auipc	a5,0x11
    8000036c:	75878793          	addi	a5,a5,1880 # 80011ac0 <cons>
    80000370:	0a07a683          	lw	a3,160(a5)
    80000374:	0016871b          	addiw	a4,a3,1
    80000378:	863a                	mv	a2,a4
    8000037a:	0ae7a023          	sw	a4,160(a5)
    8000037e:	07f6f693          	andi	a3,a3,127
    80000382:	97b6                	add	a5,a5,a3
    80000384:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000388:	47a9                	li	a5,10
    8000038a:	0cf48f63          	beq	s1,a5,80000468 <consoleintr+0x186>
    8000038e:	4791                	li	a5,4
    80000390:	0cf48c63          	beq	s1,a5,80000468 <consoleintr+0x186>
    80000394:	00011797          	auipc	a5,0x11
    80000398:	7c47a783          	lw	a5,1988(a5) # 80011b58 <cons+0x98>
    8000039c:	9f1d                	subw	a4,a4,a5
    8000039e:	08000793          	li	a5,128
    800003a2:	f6f71de3          	bne	a4,a5,8000031c <consoleintr+0x3a>
    800003a6:	a0c9                	j	80000468 <consoleintr+0x186>
    800003a8:	e84a                	sd	s2,16(sp)
    800003aa:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    800003ac:	00011717          	auipc	a4,0x11
    800003b0:	71470713          	addi	a4,a4,1812 # 80011ac0 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	00011497          	auipc	s1,0x11
    800003c0:	70448493          	addi	s1,s1,1796 # 80011ac0 <cons>
    while(cons.e != cons.w &&
    800003c4:	4929                	li	s2,10
      consputc(BACKSPACE);
    800003c6:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    800003ca:	02f70a63          	beq	a4,a5,800003fe <consoleintr+0x11c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ce:	37fd                	addiw	a5,a5,-1
    800003d0:	07f7f713          	andi	a4,a5,127
    800003d4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003d6:	01874703          	lbu	a4,24(a4)
    800003da:	03270563          	beq	a4,s2,80000404 <consoleintr+0x122>
      cons.e--;
    800003de:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003e2:	854e                	mv	a0,s3
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	ebc080e7          	jalr	-324(ra) # 800002a0 <consputc>
    while(cons.e != cons.w &&
    800003ec:	0a04a783          	lw	a5,160(s1)
    800003f0:	09c4a703          	lw	a4,156(s1)
    800003f4:	fcf71de3          	bne	a4,a5,800003ce <consoleintr+0xec>
    800003f8:	6942                	ld	s2,16(sp)
    800003fa:	69a2                	ld	s3,8(sp)
    800003fc:	b705                	j	8000031c <consoleintr+0x3a>
    800003fe:	6942                	ld	s2,16(sp)
    80000400:	69a2                	ld	s3,8(sp)
    80000402:	bf29                	j	8000031c <consoleintr+0x3a>
    80000404:	6942                	ld	s2,16(sp)
    80000406:	69a2                	ld	s3,8(sp)
    80000408:	bf11                	j	8000031c <consoleintr+0x3a>
    if(cons.e != cons.w){
    8000040a:	00011717          	auipc	a4,0x11
    8000040e:	6b670713          	addi	a4,a4,1718 # 80011ac0 <cons>
    80000412:	0a072783          	lw	a5,160(a4)
    80000416:	09c72703          	lw	a4,156(a4)
    8000041a:	f0f701e3          	beq	a4,a5,8000031c <consoleintr+0x3a>
      cons.e--;
    8000041e:	37fd                	addiw	a5,a5,-1
    80000420:	00011717          	auipc	a4,0x11
    80000424:	74f72023          	sw	a5,1856(a4) # 80011b60 <cons+0xa0>
      consputc(BACKSPACE);
    80000428:	10000513          	li	a0,256
    8000042c:	00000097          	auipc	ra,0x0
    80000430:	e74080e7          	jalr	-396(ra) # 800002a0 <consputc>
    80000434:	b5e5                	j	8000031c <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000436:	ee0483e3          	beqz	s1,8000031c <consoleintr+0x3a>
    8000043a:	b711                	j	8000033e <consoleintr+0x5c>
      consputc(c);
    8000043c:	4529                	li	a0,10
    8000043e:	00000097          	auipc	ra,0x0
    80000442:	e62080e7          	jalr	-414(ra) # 800002a0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000446:	00011797          	auipc	a5,0x11
    8000044a:	67a78793          	addi	a5,a5,1658 # 80011ac0 <cons>
    8000044e:	0a07a703          	lw	a4,160(a5)
    80000452:	0017069b          	addiw	a3,a4,1
    80000456:	8636                	mv	a2,a3
    80000458:	0ad7a023          	sw	a3,160(a5)
    8000045c:	07f77713          	andi	a4,a4,127
    80000460:	97ba                	add	a5,a5,a4
    80000462:	4729                	li	a4,10
    80000464:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000468:	00011797          	auipc	a5,0x11
    8000046c:	6ec7aa23          	sw	a2,1780(a5) # 80011b5c <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00011517          	auipc	a0,0x11
    80000474:	6e850513          	addi	a0,a0,1768 # 80011b58 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	528080e7          	jalr	1320(ra) # 800029a0 <wakeup>
    80000480:	bd71                	j	8000031c <consoleintr+0x3a>

0000000080000482 <consoleinit>:

void
consoleinit(void)
{
    80000482:	1141                	addi	sp,sp,-16
    80000484:	e406                	sd	ra,8(sp)
    80000486:	e022                	sd	s0,0(sp)
    80000488:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000048a:	00009597          	auipc	a1,0x9
    8000048e:	b7658593          	addi	a1,a1,-1162 # 80009000 <etext>
    80000492:	00011517          	auipc	a0,0x11
    80000496:	62e50513          	addi	a0,a0,1582 # 80011ac0 <cons>
    8000049a:	00001097          	auipc	ra,0x1
    8000049e:	882080e7          	jalr	-1918(ra) # 80000d1c <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	344080e7          	jalr	836(ra) # 800007e6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	0024a797          	auipc	a5,0x24a
    800004ae:	9d678793          	addi	a5,a5,-1578 # 80249e80 <devsw>
    800004b2:	00000717          	auipc	a4,0x0
    800004b6:	cce70713          	addi	a4,a4,-818 # 80000180 <consoleread>
    800004ba:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004bc:	00000717          	auipc	a4,0x0
    800004c0:	c4670713          	addi	a4,a4,-954 # 80000102 <consolewrite>
    800004c4:	ef98                	sd	a4,24(a5)
}
    800004c6:	60a2                	ld	ra,8(sp)
    800004c8:	6402                	ld	s0,0(sp)
    800004ca:	0141                	addi	sp,sp,16
    800004cc:	8082                	ret

00000000800004ce <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ce:	7179                	addi	sp,sp,-48
    800004d0:	f406                	sd	ra,40(sp)
    800004d2:	f022                	sd	s0,32(sp)
    800004d4:	ec26                	sd	s1,24(sp)
    800004d6:	e84a                	sd	s2,16(sp)
    800004d8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004da:	c219                	beqz	a2,800004e0 <printint+0x12>
    800004dc:	06054e63          	bltz	a0,80000558 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800004e0:	4e01                	li	t3,0

  i = 0;
    800004e2:	fd040313          	addi	t1,s0,-48
    x = xx;
    800004e6:	869a                	mv	a3,t1
  i = 0;
    800004e8:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800004ea:	00009817          	auipc	a6,0x9
    800004ee:	2be80813          	addi	a6,a6,702 # 800097a8 <digits>
    800004f2:	88be                	mv	a7,a5
    800004f4:	0017861b          	addiw	a2,a5,1
    800004f8:	87b2                	mv	a5,a2
    800004fa:	02b5773b          	remuw	a4,a0,a1
    800004fe:	1702                	slli	a4,a4,0x20
    80000500:	9301                	srli	a4,a4,0x20
    80000502:	9742                	add	a4,a4,a6
    80000504:	00074703          	lbu	a4,0(a4)
    80000508:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000050c:	872a                	mv	a4,a0
    8000050e:	02b5553b          	divuw	a0,a0,a1
    80000512:	0685                	addi	a3,a3,1
    80000514:	fcb77fe3          	bgeu	a4,a1,800004f2 <printint+0x24>

  if(sign)
    80000518:	000e0c63          	beqz	t3,80000530 <printint+0x62>
    buf[i++] = '-';
    8000051c:	fe060793          	addi	a5,a2,-32
    80000520:	00878633          	add	a2,a5,s0
    80000524:	02d00793          	li	a5,45
    80000528:	fef60823          	sb	a5,-16(a2)
    8000052c:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    80000530:	fff7891b          	addiw	s2,a5,-1
    80000534:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    80000538:	fff4c503          	lbu	a0,-1(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d64080e7          	jalr	-668(ra) # 800002a0 <consputc>
  while(--i >= 0)
    80000544:	397d                	addiw	s2,s2,-1
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	fe0958e3          	bgez	s2,80000538 <printint+0x6a>
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	64e2                	ld	s1,24(sp)
    80000552:	6942                	ld	s2,16(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4e05                	li	t3,1
    x = -xx;
    8000055e:	b751                	j	800004e2 <printint+0x14>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00011797          	auipc	a5,0x11
    80000570:	6007aa23          	sw	zero,1556(a5) # 80011b80 <pr+0x18>
  printf("panic: ");
    80000574:	00009517          	auipc	a0,0x9
    80000578:	a9450513          	addi	a0,a0,-1388 # 80009008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00009517          	auipc	a0,0x9
    80000592:	a8250513          	addi	a0,a0,-1406 # 80009010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00009717          	auipc	a4,0x9
    800005a4:	3af72023          	sw	a5,928(a4) # 80009940 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	ec6e                	sd	s11,24(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00011d97          	auipc	s11,0x11
    800005ce:	5b6dad83          	lw	s11,1462(s11) # 80011b80 <pr+0x18>
  if(locking)
    800005d2:	040d9463          	bnez	s11,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050c63          	beqz	a0,8000077e <printf+0x1d4>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	f06a                	sd	s10,32(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	07800c93          	li	s9,120
    8000060a:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060c:	00009a97          	auipc	s5,0x9
    80000610:	19ca8a93          	addi	s5,s5,412 # 800097a8 <digits>
    switch(c){
    80000614:	07300c13          	li	s8,115
    80000618:	a0b9                	j	80000666 <printf+0xbc>
    acquire(&pr.lock);
    8000061a:	00011517          	auipc	a0,0x11
    8000061e:	54e50513          	addi	a0,a0,1358 # 80011b68 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	78e080e7          	jalr	1934(ra) # 80000db0 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    8000063e:	00009517          	auipc	a0,0x9
    80000642:	9e250513          	addi	a0,a0,-1566 # 80009020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c52080e7          	jalr	-942(ra) # 800002a0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	0019879b          	addiw	a5,s3,1
    8000065a:	89be                	mv	s3,a5
    8000065c:	97d2                	add	a5,a5,s4
    8000065e:	0007c503          	lbu	a0,0(a5)
    80000662:	10050563          	beqz	a0,8000076c <printf+0x1c2>
    if(c != '%'){
    80000666:	ff6514e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    8000066a:	0019879b          	addiw	a5,s3,1
    8000066e:	89be                	mv	s3,a5
    80000670:	97d2                	add	a5,a5,s4
    80000672:	0007c783          	lbu	a5,0(a5)
    80000676:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000067a:	10078a63          	beqz	a5,8000078e <printf+0x1e4>
    switch(c){
    8000067e:	05778a63          	beq	a5,s7,800006d2 <printf+0x128>
    80000682:	02fbf463          	bgeu	s7,a5,800006aa <printf+0x100>
    80000686:	09878763          	beq	a5,s8,80000714 <printf+0x16a>
    8000068a:	0d979663          	bne	a5,s9,80000756 <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85ea                	mv	a1,s10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e2e080e7          	jalr	-466(ra) # 800004ce <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	0b678063          	beq	a5,s6,8000074a <printf+0x1a0>
    800006ae:	06400713          	li	a4,100
    800006b2:	0ae79263          	bne	a5,a4,80000756 <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006b6:	f8843783          	ld	a5,-120(s0)
    800006ba:	00878713          	addi	a4,a5,8
    800006be:	f8e43423          	sd	a4,-120(s0)
    800006c2:	4605                	li	a2,1
    800006c4:	45a9                	li	a1,10
    800006c6:	4388                	lw	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	e06080e7          	jalr	-506(ra) # 800004ce <printint>
      break;
    800006d0:	b759                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006d2:	f8843783          	ld	a5,-120(s0)
    800006d6:	00878713          	addi	a4,a5,8
    800006da:	f8e43423          	sd	a4,-120(s0)
    800006de:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006e2:	03000513          	li	a0,48
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	bba080e7          	jalr	-1094(ra) # 800002a0 <consputc>
  consputc('x');
    800006ee:	8566                	mv	a0,s9
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	bb0080e7          	jalr	-1104(ra) # 800002a0 <consputc>
    800006f8:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006fa:	03c95793          	srli	a5,s2,0x3c
    800006fe:	97d6                	add	a5,a5,s5
    80000700:	0007c503          	lbu	a0,0(a5)
    80000704:	00000097          	auipc	ra,0x0
    80000708:	b9c080e7          	jalr	-1124(ra) # 800002a0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0912                	slli	s2,s2,0x4
    8000070e:	34fd                	addiw	s1,s1,-1
    80000710:	f4ed                	bnez	s1,800006fa <printf+0x150>
    80000712:	b791                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000714:	f8843783          	ld	a5,-120(s0)
    80000718:	00878713          	addi	a4,a5,8
    8000071c:	f8e43423          	sd	a4,-120(s0)
    80000720:	6384                	ld	s1,0(a5)
    80000722:	cc89                	beqz	s1,8000073c <printf+0x192>
      for(; *s; s++)
    80000724:	0004c503          	lbu	a0,0(s1)
    80000728:	d51d                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b76080e7          	jalr	-1162(ra) # 800002a0 <consputc>
      for(; *s; s++)
    80000732:	0485                	addi	s1,s1,1
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	f96d                	bnez	a0,8000072a <printf+0x180>
    8000073a:	bf31                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073c:	00009497          	auipc	s1,0x9
    80000740:	8dc48493          	addi	s1,s1,-1828 # 80009018 <etext+0x18>
      for(; *s; s++)
    80000744:	02800513          	li	a0,40
    80000748:	b7cd                	j	8000072a <printf+0x180>
      consputc('%');
    8000074a:	855a                	mv	a0,s6
    8000074c:	00000097          	auipc	ra,0x0
    80000750:	b54080e7          	jalr	-1196(ra) # 800002a0 <consputc>
      break;
    80000754:	b709                	j	80000656 <printf+0xac>
      consputc('%');
    80000756:	855a                	mv	a0,s6
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b48080e7          	jalr	-1208(ra) # 800002a0 <consputc>
      consputc(c);
    80000760:	8526                	mv	a0,s1
    80000762:	00000097          	auipc	ra,0x0
    80000766:	b3e080e7          	jalr	-1218(ra) # 800002a0 <consputc>
      break;
    8000076a:	b5f5                	j	80000656 <printf+0xac>
    8000076c:	74a6                	ld	s1,104(sp)
    8000076e:	7906                	ld	s2,96(sp)
    80000770:	69e6                	ld	s3,88(sp)
    80000772:	6aa6                	ld	s5,72(sp)
    80000774:	6b06                	ld	s6,64(sp)
    80000776:	7be2                	ld	s7,56(sp)
    80000778:	7c42                	ld	s8,48(sp)
    8000077a:	7ca2                	ld	s9,40(sp)
    8000077c:	7d02                	ld	s10,32(sp)
  if(locking)
    8000077e:	020d9263          	bnez	s11,800007a2 <printf+0x1f8>
}
    80000782:	70e6                	ld	ra,120(sp)
    80000784:	7446                	ld	s0,112(sp)
    80000786:	6a46                	ld	s4,80(sp)
    80000788:	6de2                	ld	s11,24(sp)
    8000078a:	6129                	addi	sp,sp,192
    8000078c:	8082                	ret
    8000078e:	74a6                	ld	s1,104(sp)
    80000790:	7906                	ld	s2,96(sp)
    80000792:	69e6                	ld	s3,88(sp)
    80000794:	6aa6                	ld	s5,72(sp)
    80000796:	6b06                	ld	s6,64(sp)
    80000798:	7be2                	ld	s7,56(sp)
    8000079a:	7c42                	ld	s8,48(sp)
    8000079c:	7ca2                	ld	s9,40(sp)
    8000079e:	7d02                	ld	s10,32(sp)
    800007a0:	bff9                	j	8000077e <printf+0x1d4>
    release(&pr.lock);
    800007a2:	00011517          	auipc	a0,0x11
    800007a6:	3c650513          	addi	a0,a0,966 # 80011b68 <pr>
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	6b6080e7          	jalr	1718(ra) # 80000e60 <release>
}
    800007b2:	bfc1                	j	80000782 <printf+0x1d8>

00000000800007b4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b4:	1101                	addi	sp,sp,-32
    800007b6:	ec06                	sd	ra,24(sp)
    800007b8:	e822                	sd	s0,16(sp)
    800007ba:	e426                	sd	s1,8(sp)
    800007bc:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007be:	00011497          	auipc	s1,0x11
    800007c2:	3aa48493          	addi	s1,s1,938 # 80011b68 <pr>
    800007c6:	00009597          	auipc	a1,0x9
    800007ca:	86a58593          	addi	a1,a1,-1942 # 80009030 <etext+0x30>
    800007ce:	8526                	mv	a0,s1
    800007d0:	00000097          	auipc	ra,0x0
    800007d4:	54c080e7          	jalr	1356(ra) # 80000d1c <initlock>
  pr.locking = 1;
    800007d8:	4785                	li	a5,1
    800007da:	cc9c                	sw	a5,24(s1)
}
    800007dc:	60e2                	ld	ra,24(sp)
    800007de:	6442                	ld	s0,16(sp)
    800007e0:	64a2                	ld	s1,8(sp)
    800007e2:	6105                	addi	sp,sp,32
    800007e4:	8082                	ret

00000000800007e6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e6:	1141                	addi	sp,sp,-16
    800007e8:	e406                	sd	ra,8(sp)
    800007ea:	e022                	sd	s0,0(sp)
    800007ec:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ee:	100007b7          	lui	a5,0x10000
    800007f2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f6:	10000737          	lui	a4,0x10000
    800007fa:	f8000693          	li	a3,-128
    800007fe:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	468d                	li	a3,3
    80000804:	10000637          	lui	a2,0x10000
    80000808:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000810:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000814:	8732                	mv	a4,a2
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00009597          	auipc	a1,0x9
    80000824:	81858593          	addi	a1,a1,-2024 # 80009038 <etext+0x38>
    80000828:	00011517          	auipc	a0,0x11
    8000082c:	36050513          	addi	a0,a0,864 # 80011b88 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	4ec080e7          	jalr	1260(ra) # 80000d1c <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	518080e7          	jalr	1304(ra) # 80000d64 <push_off>

  if(panicked){
    80000854:	00009797          	auipc	a5,0x9
    80000858:	0ec7a783          	lw	a5,236(a5) # 80009940 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	58a080e7          	jalr	1418(ra) # 80000e04 <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00009797          	auipc	a5,0x9
    80000892:	0ba7b783          	ld	a5,186(a5) # 80009948 <uart_tx_r>
    80000896:	00009717          	auipc	a4,0x9
    8000089a:	0ba73703          	ld	a4,186(a4) # 80009950 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00011a97          	auipc	s5,0x11
    800008c0:	2cca8a93          	addi	s5,s5,716 # 80011b88 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00009497          	auipc	s1,0x9
    800008c8:	08448493          	addi	s1,s1,132 # 80009948 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00009997          	auipc	s3,0x9
    800008d4:	08098993          	addi	s3,s3,128 # 80009950 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	0ae080e7          	jalr	174(ra) # 800029a0 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00011517          	auipc	a0,0x11
    80000934:	25850513          	addi	a0,a0,600 # 80011b88 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	478080e7          	jalr	1144(ra) # 80000db0 <acquire>
  if(panicked){
    80000940:	00009797          	auipc	a5,0x9
    80000944:	0007a783          	lw	a5,0(a5) # 80009940 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00009717          	auipc	a4,0x9
    8000094e:	00673703          	ld	a4,6(a4) # 80009950 <uart_tx_w>
    80000952:	00009797          	auipc	a5,0x9
    80000956:	ff67b783          	ld	a5,-10(a5) # 80009948 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00011997          	auipc	s3,0x11
    80000962:	22a98993          	addi	s3,s3,554 # 80011b88 <uart_tx_lock>
    80000966:	00009497          	auipc	s1,0x9
    8000096a:	fe248493          	addi	s1,s1,-30 # 80009948 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00009917          	auipc	s2,0x9
    80000972:	fe290913          	addi	s2,s2,-30 # 80009950 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	fbe080e7          	jalr	-66(ra) # 8000293c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00011497          	auipc	s1,0x11
    80000998:	1f448493          	addi	s1,s1,500 # 80011b88 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00009797          	auipc	a5,0x9
    800009ac:	fae7b423          	sd	a4,-88(a5) # 80009950 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	4a6080e7          	jalr	1190(ra) # 80000e60 <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e406                	sd	ra,8(sp)
    800009d8:	e022                	sd	s0,0(sp)
    800009da:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009dc:	100007b7          	lui	a5,0x10000
    800009e0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb89                	beqz	a5,800009f8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	60a2                	ld	ra,8(sp)
    800009f2:	6402                	ld	s0,0(sp)
    800009f4:	0141                	addi	sp,sp,16
    800009f6:	8082                	ret
    return -1;
    800009f8:	557d                	li	a0,-1
    800009fa:	bfdd                	j	800009f0 <uartgetc+0x1c>

00000000800009fc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fc:	1101                	addi	sp,sp,-32
    800009fe:	ec06                	sd	ra,24(sp)
    80000a00:	e822                	sd	s0,16(sp)
    80000a02:	e426                	sd	s1,8(sp)
    80000a04:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a06:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	fcc080e7          	jalr	-52(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a10:	00950763          	beq	a0,s1,80000a1e <uartintr+0x22>
      break;
    consoleintr(c);
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	8ce080e7          	jalr	-1842(ra) # 800002e2 <consoleintr>
  while(1){
    80000a1c:	b7f5                	j	80000a08 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1e:	00011497          	auipc	s1,0x11
    80000a22:	16a48493          	addi	s1,s1,362 # 80011b88 <uart_tx_lock>
    80000a26:	8526                	mv	a0,s1
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	388080e7          	jalr	904(ra) # 80000db0 <acquire>
  uartstart();
    80000a30:	00000097          	auipc	ra,0x0
    80000a34:	e5e080e7          	jalr	-418(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	426080e7          	jalr	1062(ra) # 80000e60 <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret

0000000080000a4c <incref>:
  struct spinlock lock;
  int count[PGROUNDUP(PHYSTOP) >> 12];
} page_ref;

void incref(void *pa)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	1000                	addi	s0,sp,32
    80000a56:	84aa                	mv	s1,a0
  acquire(&page_ref.lock);
    80000a58:	00011517          	auipc	a0,0x11
    80000a5c:	18850513          	addi	a0,a0,392 # 80011be0 <page_ref>
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	350080e7          	jalr	848(ra) # 80000db0 <acquire>
  if (page_ref.count[(uint64)pa >> 12] < 0)
    80000a68:	00c4d793          	srli	a5,s1,0xc
    80000a6c:	00478693          	addi	a3,a5,4
    80000a70:	068a                	slli	a3,a3,0x2
    80000a72:	00011717          	auipc	a4,0x11
    80000a76:	16e70713          	addi	a4,a4,366 # 80011be0 <page_ref>
    80000a7a:	9736                	add	a4,a4,a3
    80000a7c:	4718                	lw	a4,8(a4)
    80000a7e:	02074463          	bltz	a4,80000aa6 <incref+0x5a>
  {
    panic("increase_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]++;
    80000a82:	00011517          	auipc	a0,0x11
    80000a86:	15e50513          	addi	a0,a0,350 # 80011be0 <page_ref>
    80000a8a:	0791                	addi	a5,a5,4
    80000a8c:	078a                	slli	a5,a5,0x2
    80000a8e:	97aa                	add	a5,a5,a0
    80000a90:	2705                	addiw	a4,a4,1
    80000a92:	c798                	sw	a4,8(a5)
  release(&page_ref.lock);
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	3cc080e7          	jalr	972(ra) # 80000e60 <release>
}
    80000a9c:	60e2                	ld	ra,24(sp)
    80000a9e:	6442                	ld	s0,16(sp)
    80000aa0:	64a2                	ld	s1,8(sp)
    80000aa2:	6105                	addi	sp,sp,32
    80000aa4:	8082                	ret
    panic("increase_pgreference");
    80000aa6:	00008517          	auipc	a0,0x8
    80000aaa:	59a50513          	addi	a0,a0,1434 # 80009040 <etext+0x40>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	ab2080e7          	jalr	-1358(ra) # 80000560 <panic>

0000000080000ab6 <decref>:

// Decrement the reference count and free the page if it reaches zero
int decref(void *pa)
{
    80000ab6:	1101                	addi	sp,sp,-32
    80000ab8:	ec06                	sd	ra,24(sp)
    80000aba:	e822                	sd	s0,16(sp)
    80000abc:	e426                	sd	s1,8(sp)
    80000abe:	1000                	addi	s0,sp,32
    80000ac0:	84aa                	mv	s1,a0
  acquire(&page_ref.lock);
    80000ac2:	00011517          	auipc	a0,0x11
    80000ac6:	11e50513          	addi	a0,a0,286 # 80011be0 <page_ref>
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	2e6080e7          	jalr	742(ra) # 80000db0 <acquire>
  if (page_ref.count[(uint64)pa >> 12] <= 0)
    80000ad2:	00c4d513          	srli	a0,s1,0xc
    80000ad6:	00450713          	addi	a4,a0,4
    80000ada:	070a                	slli	a4,a4,0x2
    80000adc:	00011797          	auipc	a5,0x11
    80000ae0:	10478793          	addi	a5,a5,260 # 80011be0 <page_ref>
    80000ae4:	97ba                	add	a5,a5,a4
    80000ae6:	479c                	lw	a5,8(a5)
    80000ae8:	02f05b63          	blez	a5,80000b1e <decref+0x68>
  {
    panic("decrease_pgreference");
  }
  page_ref.count[(uint64)pa >> 12]--;
    80000aec:	37fd                	addiw	a5,a5,-1
    80000aee:	0511                	addi	a0,a0,4
    80000af0:	050a                	slli	a0,a0,0x2
    80000af2:	00011717          	auipc	a4,0x11
    80000af6:	0ee70713          	addi	a4,a4,238 # 80011be0 <page_ref>
    80000afa:	972a                	add	a4,a4,a0
    80000afc:	c71c                	sw	a5,8(a4)
  if (page_ref.count[(uint64)pa >> 12] > 0)
    80000afe:	02f04863          	bgtz	a5,80000b2e <decref+0x78>
  {
    release(&page_ref.lock);
    return 0;
  }
  release(&page_ref.lock);
    80000b02:	00011517          	auipc	a0,0x11
    80000b06:	0de50513          	addi	a0,a0,222 # 80011be0 <page_ref>
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	356080e7          	jalr	854(ra) # 80000e60 <release>
  return 1;
    80000b12:	4505                	li	a0,1
}
    80000b14:	60e2                	ld	ra,24(sp)
    80000b16:	6442                	ld	s0,16(sp)
    80000b18:	64a2                	ld	s1,8(sp)
    80000b1a:	6105                	addi	sp,sp,32
    80000b1c:	8082                	ret
    panic("decrease_pgreference");
    80000b1e:	00008517          	auipc	a0,0x8
    80000b22:	53a50513          	addi	a0,a0,1338 # 80009058 <etext+0x58>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	a3a080e7          	jalr	-1478(ra) # 80000560 <panic>
    release(&page_ref.lock);
    80000b2e:	00011517          	auipc	a0,0x11
    80000b32:	0b250513          	addi	a0,a0,178 # 80011be0 <page_ref>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	32a080e7          	jalr	810(ra) # 80000e60 <release>
    return 0;
    80000b3e:	4501                	li	a0,0
    80000b40:	bfd1                	j	80000b14 <decref+0x5e>

0000000080000b42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000b42:	1101                	addi	sp,sp,-32
    80000b44:	ec06                	sd	ra,24(sp)
    80000b46:	e822                	sd	s0,16(sp)
    80000b48:	e426                	sd	s1,8(sp)
    80000b4a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b4c:	03451793          	slli	a5,a0,0x34
    80000b50:	e795                	bnez	a5,80000b7c <kfree+0x3a>
    80000b52:	84aa                	mv	s1,a0
    80000b54:	0024a797          	auipc	a5,0x24a
    80000b58:	4c478793          	addi	a5,a5,1220 # 8024b018 <end>
    80000b5c:	02f56063          	bltu	a0,a5,80000b7c <kfree+0x3a>
    80000b60:	47c5                	li	a5,17
    80000b62:	07ee                	slli	a5,a5,0x1b
    80000b64:	00f57c63          	bgeu	a0,a5,80000b7c <kfree+0x3a>
    panic("kfree");

  if (!decref(pa))
    80000b68:	00000097          	auipc	ra,0x0
    80000b6c:	f4e080e7          	jalr	-178(ra) # 80000ab6 <decref>
    80000b70:	ed19                	bnez	a0,80000b8e <kfree+0x4c>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000b72:	60e2                	ld	ra,24(sp)
    80000b74:	6442                	ld	s0,16(sp)
    80000b76:	64a2                	ld	s1,8(sp)
    80000b78:	6105                	addi	sp,sp,32
    80000b7a:	8082                	ret
    80000b7c:	e04a                	sd	s2,0(sp)
    panic("kfree");
    80000b7e:	00008517          	auipc	a0,0x8
    80000b82:	4f250513          	addi	a0,a0,1266 # 80009070 <etext+0x70>
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	9da080e7          	jalr	-1574(ra) # 80000560 <panic>
    80000b8e:	e04a                	sd	s2,0(sp)
  memset(pa, 1, PGSIZE);
    80000b90:	6605                	lui	a2,0x1
    80000b92:	4585                	li	a1,1
    80000b94:	8526                	mv	a0,s1
    80000b96:	00000097          	auipc	ra,0x0
    80000b9a:	312080e7          	jalr	786(ra) # 80000ea8 <memset>
  acquire(&kmem.lock);
    80000b9e:	00011917          	auipc	s2,0x11
    80000ba2:	02290913          	addi	s2,s2,34 # 80011bc0 <kmem>
    80000ba6:	854a                	mv	a0,s2
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	208080e7          	jalr	520(ra) # 80000db0 <acquire>
  r->next = kmem.freelist;
    80000bb0:	01893783          	ld	a5,24(s2)
    80000bb4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000bb6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000bba:	854a                	mv	a0,s2
    80000bbc:	00000097          	auipc	ra,0x0
    80000bc0:	2a4080e7          	jalr	676(ra) # 80000e60 <release>
    80000bc4:	6902                	ld	s2,0(sp)
    80000bc6:	b775                	j	80000b72 <kfree+0x30>

0000000080000bc8 <freerange>:
{
    80000bc8:	7139                	addi	sp,sp,-64
    80000bca:	fc06                	sd	ra,56(sp)
    80000bcc:	f822                	sd	s0,48(sp)
    80000bce:	f426                	sd	s1,40(sp)
    80000bd0:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000bd2:	6785                	lui	a5,0x1
    80000bd4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000bd8:	00e504b3          	add	s1,a0,a4
    80000bdc:	777d                	lui	a4,0xfffff
    80000bde:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000be0:	94be                	add	s1,s1,a5
    80000be2:	0295ec63          	bltu	a1,s1,80000c1a <freerange+0x52>
    80000be6:	f04a                	sd	s2,32(sp)
    80000be8:	ec4e                	sd	s3,24(sp)
    80000bea:	e852                	sd	s4,16(sp)
    80000bec:	e456                	sd	s5,8(sp)
    80000bee:	89ae                	mv	s3,a1
    80000bf0:	8aba                	mv	s5,a4
    80000bf2:	8a3e                	mv	s4,a5
    80000bf4:	01548933          	add	s2,s1,s5
    incref(p);
    80000bf8:	854a                	mv	a0,s2
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	e52080e7          	jalr	-430(ra) # 80000a4c <incref>
    kfree(p);
    80000c02:	854a                	mv	a0,s2
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	f3e080e7          	jalr	-194(ra) # 80000b42 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c0c:	94d2                	add	s1,s1,s4
    80000c0e:	fe99f3e3          	bgeu	s3,s1,80000bf4 <freerange+0x2c>
    80000c12:	7902                	ld	s2,32(sp)
    80000c14:	69e2                	ld	s3,24(sp)
    80000c16:	6a42                	ld	s4,16(sp)
    80000c18:	6aa2                	ld	s5,8(sp)
}
    80000c1a:	70e2                	ld	ra,56(sp)
    80000c1c:	7442                	ld	s0,48(sp)
    80000c1e:	74a2                	ld	s1,40(sp)
    80000c20:	6121                	addi	sp,sp,64
    80000c22:	8082                	ret

0000000080000c24 <kinit>:
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  initlock(&page_ref.lock, "page_ref");
    80000c2c:	00008597          	auipc	a1,0x8
    80000c30:	44c58593          	addi	a1,a1,1100 # 80009078 <etext+0x78>
    80000c34:	00011517          	auipc	a0,0x11
    80000c38:	fac50513          	addi	a0,a0,-84 # 80011be0 <page_ref>
    80000c3c:	00000097          	auipc	ra,0x0
    80000c40:	0e0080e7          	jalr	224(ra) # 80000d1c <initlock>
  acquire(&page_ref.lock);
    80000c44:	00011517          	auipc	a0,0x11
    80000c48:	f9c50513          	addi	a0,a0,-100 # 80011be0 <page_ref>
    80000c4c:	00000097          	auipc	ra,0x0
    80000c50:	164080e7          	jalr	356(ra) # 80000db0 <acquire>
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c54:	00011797          	auipc	a5,0x11
    80000c58:	fa478793          	addi	a5,a5,-92 # 80011bf8 <page_ref+0x18>
    80000c5c:	00231717          	auipc	a4,0x231
    80000c60:	f9c70713          	addi	a4,a4,-100 # 80231bf8 <queues_sizes>
    page_ref.count[i] = 0;
    80000c64:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); ++i)
    80000c68:	0791                	addi	a5,a5,4
    80000c6a:	fee79de3          	bne	a5,a4,80000c64 <kinit+0x40>
  release(&page_ref.lock);
    80000c6e:	00011517          	auipc	a0,0x11
    80000c72:	f7250513          	addi	a0,a0,-142 # 80011be0 <page_ref>
    80000c76:	00000097          	auipc	ra,0x0
    80000c7a:	1ea080e7          	jalr	490(ra) # 80000e60 <release>
  initlock(&kmem.lock, "kmem");
    80000c7e:	00008597          	auipc	a1,0x8
    80000c82:	40a58593          	addi	a1,a1,1034 # 80009088 <etext+0x88>
    80000c86:	00011517          	auipc	a0,0x11
    80000c8a:	f3a50513          	addi	a0,a0,-198 # 80011bc0 <kmem>
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	08e080e7          	jalr	142(ra) # 80000d1c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000c96:	45c5                	li	a1,17
    80000c98:	05ee                	slli	a1,a1,0x1b
    80000c9a:	0024a517          	auipc	a0,0x24a
    80000c9e:	37e50513          	addi	a0,a0,894 # 8024b018 <end>
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	f26080e7          	jalr	-218(ra) # 80000bc8 <freerange>
}
    80000caa:	60a2                	ld	ra,8(sp)
    80000cac:	6402                	ld	s0,0(sp)
    80000cae:	0141                	addi	sp,sp,16
    80000cb0:	8082                	ret

0000000080000cb2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000cb2:	1101                	addi	sp,sp,-32
    80000cb4:	ec06                	sd	ra,24(sp)
    80000cb6:	e822                	sd	s0,16(sp)
    80000cb8:	e426                	sd	s1,8(sp)
    80000cba:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000cbc:	00011497          	auipc	s1,0x11
    80000cc0:	f0448493          	addi	s1,s1,-252 # 80011bc0 <kmem>
    80000cc4:	8526                	mv	a0,s1
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	0ea080e7          	jalr	234(ra) # 80000db0 <acquire>
  r = kmem.freelist;
    80000cce:	6c84                	ld	s1,24(s1)
  if(r)
    80000cd0:	cc8d                	beqz	s1,80000d0a <kalloc+0x58>
    kmem.freelist = r->next;
    80000cd2:	609c                	ld	a5,0(s1)
    80000cd4:	00011517          	auipc	a0,0x11
    80000cd8:	eec50513          	addi	a0,a0,-276 # 80011bc0 <kmem>
    80000cdc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	182080e7          	jalr	386(ra) # 80000e60 <release>
  if (r)
  {
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000ce6:	6605                	lui	a2,0x1
    80000ce8:	4595                	li	a1,5
    80000cea:	8526                	mv	a0,s1
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	1bc080e7          	jalr	444(ra) # 80000ea8 <memset>
    incref((void *)r);
    80000cf4:	8526                	mv	a0,s1
    80000cf6:	00000097          	auipc	ra,0x0
    80000cfa:	d56080e7          	jalr	-682(ra) # 80000a4c <incref>
  }
  return (void*)r;
}
    80000cfe:	8526                	mv	a0,s1
    80000d00:	60e2                	ld	ra,24(sp)
    80000d02:	6442                	ld	s0,16(sp)
    80000d04:	64a2                	ld	s1,8(sp)
    80000d06:	6105                	addi	sp,sp,32
    80000d08:	8082                	ret
  release(&kmem.lock);
    80000d0a:	00011517          	auipc	a0,0x11
    80000d0e:	eb650513          	addi	a0,a0,-330 # 80011bc0 <kmem>
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	14e080e7          	jalr	334(ra) # 80000e60 <release>
  if (r)
    80000d1a:	b7d5                	j	80000cfe <kalloc+0x4c>

0000000080000d1c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d1c:	1141                	addi	sp,sp,-16
    80000d1e:	e406                	sd	ra,8(sp)
    80000d20:	e022                	sd	s0,0(sp)
    80000d22:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d24:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d26:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d2a:	00053823          	sd	zero,16(a0)
}
    80000d2e:	60a2                	ld	ra,8(sp)
    80000d30:	6402                	ld	s0,0(sp)
    80000d32:	0141                	addi	sp,sp,16
    80000d34:	8082                	ret

0000000080000d36 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d36:	411c                	lw	a5,0(a0)
    80000d38:	e399                	bnez	a5,80000d3e <holding+0x8>
    80000d3a:	4501                	li	a0,0
  return r;
}
    80000d3c:	8082                	ret
{
    80000d3e:	1101                	addi	sp,sp,-32
    80000d40:	ec06                	sd	ra,24(sp)
    80000d42:	e822                	sd	s0,16(sp)
    80000d44:	e426                	sd	s1,8(sp)
    80000d46:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d48:	6904                	ld	s1,16(a0)
    80000d4a:	00001097          	auipc	ra,0x1
    80000d4e:	114080e7          	jalr	276(ra) # 80001e5e <mycpu>
    80000d52:	40a48533          	sub	a0,s1,a0
    80000d56:	00153513          	seqz	a0,a0
}
    80000d5a:	60e2                	ld	ra,24(sp)
    80000d5c:	6442                	ld	s0,16(sp)
    80000d5e:	64a2                	ld	s1,8(sp)
    80000d60:	6105                	addi	sp,sp,32
    80000d62:	8082                	ret

0000000080000d64 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d64:	1101                	addi	sp,sp,-32
    80000d66:	ec06                	sd	ra,24(sp)
    80000d68:	e822                	sd	s0,16(sp)
    80000d6a:	e426                	sd	s1,8(sp)
    80000d6c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d6e:	100024f3          	csrr	s1,sstatus
    80000d72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d76:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d78:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d7c:	00001097          	auipc	ra,0x1
    80000d80:	0e2080e7          	jalr	226(ra) # 80001e5e <mycpu>
    80000d84:	5d3c                	lw	a5,120(a0)
    80000d86:	cf89                	beqz	a5,80000da0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d88:	00001097          	auipc	ra,0x1
    80000d8c:	0d6080e7          	jalr	214(ra) # 80001e5e <mycpu>
    80000d90:	5d3c                	lw	a5,120(a0)
    80000d92:	2785                	addiw	a5,a5,1
    80000d94:	dd3c                	sw	a5,120(a0)
}
    80000d96:	60e2                	ld	ra,24(sp)
    80000d98:	6442                	ld	s0,16(sp)
    80000d9a:	64a2                	ld	s1,8(sp)
    80000d9c:	6105                	addi	sp,sp,32
    80000d9e:	8082                	ret
    mycpu()->intena = old;
    80000da0:	00001097          	auipc	ra,0x1
    80000da4:	0be080e7          	jalr	190(ra) # 80001e5e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000da8:	8085                	srli	s1,s1,0x1
    80000daa:	8885                	andi	s1,s1,1
    80000dac:	dd64                	sw	s1,124(a0)
    80000dae:	bfe9                	j	80000d88 <push_off+0x24>

0000000080000db0 <acquire>:
{
    80000db0:	1101                	addi	sp,sp,-32
    80000db2:	ec06                	sd	ra,24(sp)
    80000db4:	e822                	sd	s0,16(sp)
    80000db6:	e426                	sd	s1,8(sp)
    80000db8:	1000                	addi	s0,sp,32
    80000dba:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000dbc:	00000097          	auipc	ra,0x0
    80000dc0:	fa8080e7          	jalr	-88(ra) # 80000d64 <push_off>
  if(holding(lk))
    80000dc4:	8526                	mv	a0,s1
    80000dc6:	00000097          	auipc	ra,0x0
    80000dca:	f70080e7          	jalr	-144(ra) # 80000d36 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dce:	4705                	li	a4,1
  if(holding(lk))
    80000dd0:	e115                	bnez	a0,80000df4 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dd2:	87ba                	mv	a5,a4
    80000dd4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dd8:	2781                	sext.w	a5,a5
    80000dda:	ffe5                	bnez	a5,80000dd2 <acquire+0x22>
  __sync_synchronize();
    80000ddc:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000de0:	00001097          	auipc	ra,0x1
    80000de4:	07e080e7          	jalr	126(ra) # 80001e5e <mycpu>
    80000de8:	e888                	sd	a0,16(s1)
}
    80000dea:	60e2                	ld	ra,24(sp)
    80000dec:	6442                	ld	s0,16(sp)
    80000dee:	64a2                	ld	s1,8(sp)
    80000df0:	6105                	addi	sp,sp,32
    80000df2:	8082                	ret
    panic("acquire");
    80000df4:	00008517          	auipc	a0,0x8
    80000df8:	29c50513          	addi	a0,a0,668 # 80009090 <etext+0x90>
    80000dfc:	fffff097          	auipc	ra,0xfffff
    80000e00:	764080e7          	jalr	1892(ra) # 80000560 <panic>

0000000080000e04 <pop_off>:

void
pop_off(void)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e406                	sd	ra,8(sp)
    80000e08:	e022                	sd	s0,0(sp)
    80000e0a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e0c:	00001097          	auipc	ra,0x1
    80000e10:	052080e7          	jalr	82(ra) # 80001e5e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e18:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e1a:	e39d                	bnez	a5,80000e40 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e1c:	5d3c                	lw	a5,120(a0)
    80000e1e:	02f05963          	blez	a5,80000e50 <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000e22:	37fd                	addiw	a5,a5,-1
    80000e24:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e26:	eb89                	bnez	a5,80000e38 <pop_off+0x34>
    80000e28:	5d7c                	lw	a5,124(a0)
    80000e2a:	c799                	beqz	a5,80000e38 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e30:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e34:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e38:	60a2                	ld	ra,8(sp)
    80000e3a:	6402                	ld	s0,0(sp)
    80000e3c:	0141                	addi	sp,sp,16
    80000e3e:	8082                	ret
    panic("pop_off - interruptible");
    80000e40:	00008517          	auipc	a0,0x8
    80000e44:	25850513          	addi	a0,a0,600 # 80009098 <etext+0x98>
    80000e48:	fffff097          	auipc	ra,0xfffff
    80000e4c:	718080e7          	jalr	1816(ra) # 80000560 <panic>
    panic("pop_off");
    80000e50:	00008517          	auipc	a0,0x8
    80000e54:	26050513          	addi	a0,a0,608 # 800090b0 <etext+0xb0>
    80000e58:	fffff097          	auipc	ra,0xfffff
    80000e5c:	708080e7          	jalr	1800(ra) # 80000560 <panic>

0000000080000e60 <release>:
{
    80000e60:	1101                	addi	sp,sp,-32
    80000e62:	ec06                	sd	ra,24(sp)
    80000e64:	e822                	sd	s0,16(sp)
    80000e66:	e426                	sd	s1,8(sp)
    80000e68:	1000                	addi	s0,sp,32
    80000e6a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e6c:	00000097          	auipc	ra,0x0
    80000e70:	eca080e7          	jalr	-310(ra) # 80000d36 <holding>
    80000e74:	c115                	beqz	a0,80000e98 <release+0x38>
  lk->cpu = 0;
    80000e76:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e7a:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000e7e:	0310000f          	fence	rw,w
    80000e82:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000e86:	00000097          	auipc	ra,0x0
    80000e8a:	f7e080e7          	jalr	-130(ra) # 80000e04 <pop_off>
}
    80000e8e:	60e2                	ld	ra,24(sp)
    80000e90:	6442                	ld	s0,16(sp)
    80000e92:	64a2                	ld	s1,8(sp)
    80000e94:	6105                	addi	sp,sp,32
    80000e96:	8082                	ret
    panic("release");
    80000e98:	00008517          	auipc	a0,0x8
    80000e9c:	22050513          	addi	a0,a0,544 # 800090b8 <etext+0xb8>
    80000ea0:	fffff097          	auipc	ra,0xfffff
    80000ea4:	6c0080e7          	jalr	1728(ra) # 80000560 <panic>

0000000080000ea8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e406                	sd	ra,8(sp)
    80000eac:	e022                	sd	s0,0(sp)
    80000eae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000eb0:	ca19                	beqz	a2,80000ec6 <memset+0x1e>
    80000eb2:	87aa                	mv	a5,a0
    80000eb4:	1602                	slli	a2,a2,0x20
    80000eb6:	9201                	srli	a2,a2,0x20
    80000eb8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ebc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ec0:	0785                	addi	a5,a5,1
    80000ec2:	fee79de3          	bne	a5,a4,80000ebc <memset+0x14>
  }
  return dst;
}
    80000ec6:	60a2                	ld	ra,8(sp)
    80000ec8:	6402                	ld	s0,0(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret

0000000080000ece <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ece:	1141                	addi	sp,sp,-16
    80000ed0:	e406                	sd	ra,8(sp)
    80000ed2:	e022                	sd	s0,0(sp)
    80000ed4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ed6:	ca0d                	beqz	a2,80000f08 <memcmp+0x3a>
    80000ed8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000edc:	1682                	slli	a3,a3,0x20
    80000ede:	9281                	srli	a3,a3,0x20
    80000ee0:	0685                	addi	a3,a3,1
    80000ee2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ee4:	00054783          	lbu	a5,0(a0)
    80000ee8:	0005c703          	lbu	a4,0(a1)
    80000eec:	00e79863          	bne	a5,a4,80000efc <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000ef0:	0505                	addi	a0,a0,1
    80000ef2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ef4:	fed518e3          	bne	a0,a3,80000ee4 <memcmp+0x16>
  }

  return 0;
    80000ef8:	4501                	li	a0,0
    80000efa:	a019                	j	80000f00 <memcmp+0x32>
      return *s1 - *s2;
    80000efc:	40e7853b          	subw	a0,a5,a4
}
    80000f00:	60a2                	ld	ra,8(sp)
    80000f02:	6402                	ld	s0,0(sp)
    80000f04:	0141                	addi	sp,sp,16
    80000f06:	8082                	ret
  return 0;
    80000f08:	4501                	li	a0,0
    80000f0a:	bfdd                	j	80000f00 <memcmp+0x32>

0000000080000f0c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f0c:	1141                	addi	sp,sp,-16
    80000f0e:	e406                	sd	ra,8(sp)
    80000f10:	e022                	sd	s0,0(sp)
    80000f12:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f14:	c205                	beqz	a2,80000f34 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f16:	02a5e363          	bltu	a1,a0,80000f3c <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f1a:	1602                	slli	a2,a2,0x20
    80000f1c:	9201                	srli	a2,a2,0x20
    80000f1e:	00c587b3          	add	a5,a1,a2
{
    80000f22:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f24:	0585                	addi	a1,a1,1
    80000f26:	0705                	addi	a4,a4,1
    80000f28:	fff5c683          	lbu	a3,-1(a1)
    80000f2c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f30:	feb79ae3          	bne	a5,a1,80000f24 <memmove+0x18>

  return dst;
}
    80000f34:	60a2                	ld	ra,8(sp)
    80000f36:	6402                	ld	s0,0(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret
  if(s < d && s + n > d){
    80000f3c:	02061693          	slli	a3,a2,0x20
    80000f40:	9281                	srli	a3,a3,0x20
    80000f42:	00d58733          	add	a4,a1,a3
    80000f46:	fce57ae3          	bgeu	a0,a4,80000f1a <memmove+0xe>
    d += n;
    80000f4a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f4c:	fff6079b          	addiw	a5,a2,-1
    80000f50:	1782                	slli	a5,a5,0x20
    80000f52:	9381                	srli	a5,a5,0x20
    80000f54:	fff7c793          	not	a5,a5
    80000f58:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f5a:	177d                	addi	a4,a4,-1
    80000f5c:	16fd                	addi	a3,a3,-1
    80000f5e:	00074603          	lbu	a2,0(a4)
    80000f62:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f66:	fee79ae3          	bne	a5,a4,80000f5a <memmove+0x4e>
    80000f6a:	b7e9                	j	80000f34 <memmove+0x28>

0000000080000f6c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f6c:	1141                	addi	sp,sp,-16
    80000f6e:	e406                	sd	ra,8(sp)
    80000f70:	e022                	sd	s0,0(sp)
    80000f72:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	f98080e7          	jalr	-104(ra) # 80000f0c <memmove>
}
    80000f7c:	60a2                	ld	ra,8(sp)
    80000f7e:	6402                	ld	s0,0(sp)
    80000f80:	0141                	addi	sp,sp,16
    80000f82:	8082                	ret

0000000080000f84 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f84:	1141                	addi	sp,sp,-16
    80000f86:	e406                	sd	ra,8(sp)
    80000f88:	e022                	sd	s0,0(sp)
    80000f8a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f8c:	ce11                	beqz	a2,80000fa8 <strncmp+0x24>
    80000f8e:	00054783          	lbu	a5,0(a0)
    80000f92:	cf89                	beqz	a5,80000fac <strncmp+0x28>
    80000f94:	0005c703          	lbu	a4,0(a1)
    80000f98:	00f71a63          	bne	a4,a5,80000fac <strncmp+0x28>
    n--, p++, q++;
    80000f9c:	367d                	addiw	a2,a2,-1
    80000f9e:	0505                	addi	a0,a0,1
    80000fa0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000fa2:	f675                	bnez	a2,80000f8e <strncmp+0xa>
  if(n == 0)
    return 0;
    80000fa4:	4501                	li	a0,0
    80000fa6:	a801                	j	80000fb6 <strncmp+0x32>
    80000fa8:	4501                	li	a0,0
    80000faa:	a031                	j	80000fb6 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000fac:	00054503          	lbu	a0,0(a0)
    80000fb0:	0005c783          	lbu	a5,0(a1)
    80000fb4:	9d1d                	subw	a0,a0,a5
}
    80000fb6:	60a2                	ld	ra,8(sp)
    80000fb8:	6402                	ld	s0,0(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fbe:	1141                	addi	sp,sp,-16
    80000fc0:	e406                	sd	ra,8(sp)
    80000fc2:	e022                	sd	s0,0(sp)
    80000fc4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fc6:	87aa                	mv	a5,a0
    80000fc8:	86b2                	mv	a3,a2
    80000fca:	367d                	addiw	a2,a2,-1
    80000fcc:	02d05563          	blez	a3,80000ff6 <strncpy+0x38>
    80000fd0:	0785                	addi	a5,a5,1
    80000fd2:	0005c703          	lbu	a4,0(a1)
    80000fd6:	fee78fa3          	sb	a4,-1(a5)
    80000fda:	0585                	addi	a1,a1,1
    80000fdc:	f775                	bnez	a4,80000fc8 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000fde:	873e                	mv	a4,a5
    80000fe0:	00c05b63          	blez	a2,80000ff6 <strncpy+0x38>
    80000fe4:	9fb5                	addw	a5,a5,a3
    80000fe6:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000fe8:	0705                	addi	a4,a4,1
    80000fea:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000fee:	40e786bb          	subw	a3,a5,a4
    80000ff2:	fed04be3          	bgtz	a3,80000fe8 <strncpy+0x2a>
  return os;
}
    80000ff6:	60a2                	ld	ra,8(sp)
    80000ff8:	6402                	ld	s0,0(sp)
    80000ffa:	0141                	addi	sp,sp,16
    80000ffc:	8082                	ret

0000000080000ffe <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ffe:	1141                	addi	sp,sp,-16
    80001000:	e406                	sd	ra,8(sp)
    80001002:	e022                	sd	s0,0(sp)
    80001004:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001006:	02c05363          	blez	a2,8000102c <safestrcpy+0x2e>
    8000100a:	fff6069b          	addiw	a3,a2,-1
    8000100e:	1682                	slli	a3,a3,0x20
    80001010:	9281                	srli	a3,a3,0x20
    80001012:	96ae                	add	a3,a3,a1
    80001014:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001016:	00d58963          	beq	a1,a3,80001028 <safestrcpy+0x2a>
    8000101a:	0585                	addi	a1,a1,1
    8000101c:	0785                	addi	a5,a5,1
    8000101e:	fff5c703          	lbu	a4,-1(a1)
    80001022:	fee78fa3          	sb	a4,-1(a5)
    80001026:	fb65                	bnez	a4,80001016 <safestrcpy+0x18>
    ;
  *s = 0;
    80001028:	00078023          	sb	zero,0(a5)
  return os;
}
    8000102c:	60a2                	ld	ra,8(sp)
    8000102e:	6402                	ld	s0,0(sp)
    80001030:	0141                	addi	sp,sp,16
    80001032:	8082                	ret

0000000080001034 <strlen>:

int
strlen(const char *s)
{
    80001034:	1141                	addi	sp,sp,-16
    80001036:	e406                	sd	ra,8(sp)
    80001038:	e022                	sd	s0,0(sp)
    8000103a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000103c:	00054783          	lbu	a5,0(a0)
    80001040:	cf99                	beqz	a5,8000105e <strlen+0x2a>
    80001042:	0505                	addi	a0,a0,1
    80001044:	87aa                	mv	a5,a0
    80001046:	86be                	mv	a3,a5
    80001048:	0785                	addi	a5,a5,1
    8000104a:	fff7c703          	lbu	a4,-1(a5)
    8000104e:	ff65                	bnez	a4,80001046 <strlen+0x12>
    80001050:	40a6853b          	subw	a0,a3,a0
    80001054:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80001056:	60a2                	ld	ra,8(sp)
    80001058:	6402                	ld	s0,0(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000105e:	4501                	li	a0,0
    80001060:	bfdd                	j	80001056 <strlen+0x22>

0000000080001062 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000106a:	00001097          	auipc	ra,0x1
    8000106e:	de0080e7          	jalr	-544(ra) # 80001e4a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001072:	00009717          	auipc	a4,0x9
    80001076:	8e670713          	addi	a4,a4,-1818 # 80009958 <started>
  if(cpuid() == 0){
    8000107a:	c139                	beqz	a0,800010c0 <main+0x5e>
    while(started == 0)
    8000107c:	431c                	lw	a5,0(a4)
    8000107e:	2781                	sext.w	a5,a5
    80001080:	dff5                	beqz	a5,8000107c <main+0x1a>
      ;
    __sync_synchronize();
    80001082:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80001086:	00001097          	auipc	ra,0x1
    8000108a:	dc4080e7          	jalr	-572(ra) # 80001e4a <cpuid>
    8000108e:	85aa                	mv	a1,a0
    80001090:	00008517          	auipc	a0,0x8
    80001094:	04850513          	addi	a0,a0,72 # 800090d8 <etext+0xd8>
    80001098:	fffff097          	auipc	ra,0xfffff
    8000109c:	512080e7          	jalr	1298(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    800010a0:	00000097          	auipc	ra,0x0
    800010a4:	0d8080e7          	jalr	216(ra) # 80001178 <kvminithart>
    trapinithart();   // install kernel trap vector
    800010a8:	00002097          	auipc	ra,0x2
    800010ac:	074080e7          	jalr	116(ra) # 8000311c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010b0:	00006097          	auipc	ra,0x6
    800010b4:	a44080e7          	jalr	-1468(ra) # 80006af4 <plicinithart>
  }

  scheduler();        
    800010b8:	00001097          	auipc	ra,0x1
    800010bc:	762080e7          	jalr	1890(ra) # 8000281a <scheduler>
    consoleinit();
    800010c0:	fffff097          	auipc	ra,0xfffff
    800010c4:	3c2080e7          	jalr	962(ra) # 80000482 <consoleinit>
    printfinit();
    800010c8:	fffff097          	auipc	ra,0xfffff
    800010cc:	6ec080e7          	jalr	1772(ra) # 800007b4 <printfinit>
    printf("\n");
    800010d0:	00008517          	auipc	a0,0x8
    800010d4:	f4050513          	addi	a0,a0,-192 # 80009010 <etext+0x10>
    800010d8:	fffff097          	auipc	ra,0xfffff
    800010dc:	4d2080e7          	jalr	1234(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    800010e0:	00008517          	auipc	a0,0x8
    800010e4:	fe050513          	addi	a0,a0,-32 # 800090c0 <etext+0xc0>
    800010e8:	fffff097          	auipc	ra,0xfffff
    800010ec:	4c2080e7          	jalr	1218(ra) # 800005aa <printf>
    printf("\n");
    800010f0:	00008517          	auipc	a0,0x8
    800010f4:	f2050513          	addi	a0,a0,-224 # 80009010 <etext+0x10>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	4b2080e7          	jalr	1202(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80001100:	00000097          	auipc	ra,0x0
    80001104:	b24080e7          	jalr	-1244(ra) # 80000c24 <kinit>
    kvminit();       // create kernel page table
    80001108:	00000097          	auipc	ra,0x0
    8000110c:	32a080e7          	jalr	810(ra) # 80001432 <kvminit>
    kvminithart();   // turn on paging
    80001110:	00000097          	auipc	ra,0x0
    80001114:	068080e7          	jalr	104(ra) # 80001178 <kvminithart>
    procinit();      // process table
    80001118:	00001097          	auipc	ra,0x1
    8000111c:	c6c080e7          	jalr	-916(ra) # 80001d84 <procinit>
    trapinit();      // trap vectors
    80001120:	00002097          	auipc	ra,0x2
    80001124:	fd4080e7          	jalr	-44(ra) # 800030f4 <trapinit>
    trapinithart();  // install kernel trap vector
    80001128:	00002097          	auipc	ra,0x2
    8000112c:	ff4080e7          	jalr	-12(ra) # 8000311c <trapinithart>
    plicinit();      // set up interrupt controller
    80001130:	00006097          	auipc	ra,0x6
    80001134:	9aa080e7          	jalr	-1622(ra) # 80006ada <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001138:	00006097          	auipc	ra,0x6
    8000113c:	9bc080e7          	jalr	-1604(ra) # 80006af4 <plicinithart>
    binit();         // buffer cache
    80001140:	00003097          	auipc	ra,0x3
    80001144:	a30080e7          	jalr	-1488(ra) # 80003b70 <binit>
    iinit();         // inode table
    80001148:	00003097          	auipc	ra,0x3
    8000114c:	0c0080e7          	jalr	192(ra) # 80004208 <iinit>
    fileinit();      // file table
    80001150:	00004097          	auipc	ra,0x4
    80001154:	092080e7          	jalr	146(ra) # 800051e2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001158:	00006097          	auipc	ra,0x6
    8000115c:	aa4080e7          	jalr	-1372(ra) # 80006bfc <virtio_disk_init>
    userinit();      // first user process
    80001160:	00001097          	auipc	ra,0x1
    80001164:	052080e7          	jalr	82(ra) # 800021b2 <userinit>
    __sync_synchronize();
    80001168:	0330000f          	fence	rw,rw
    started = 1;
    8000116c:	4785                	li	a5,1
    8000116e:	00008717          	auipc	a4,0x8
    80001172:	7ef72523          	sw	a5,2026(a4) # 80009958 <started>
    80001176:	b789                	j	800010b8 <main+0x56>

0000000080001178 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001180:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001184:	00008797          	auipc	a5,0x8
    80001188:	7dc7b783          	ld	a5,2012(a5) # 80009960 <kernel_pagetable>
    8000118c:	83b1                	srli	a5,a5,0xc
    8000118e:	577d                	li	a4,-1
    80001190:	177e                	slli	a4,a4,0x3f
    80001192:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001194:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001198:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000119c:	60a2                	ld	ra,8(sp)
    8000119e:	6402                	ld	s0,0(sp)
    800011a0:	0141                	addi	sp,sp,16
    800011a2:	8082                	ret

00000000800011a4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011a4:	7139                	addi	sp,sp,-64
    800011a6:	fc06                	sd	ra,56(sp)
    800011a8:	f822                	sd	s0,48(sp)
    800011aa:	f426                	sd	s1,40(sp)
    800011ac:	f04a                	sd	s2,32(sp)
    800011ae:	ec4e                	sd	s3,24(sp)
    800011b0:	e852                	sd	s4,16(sp)
    800011b2:	e456                	sd	s5,8(sp)
    800011b4:	e05a                	sd	s6,0(sp)
    800011b6:	0080                	addi	s0,sp,64
    800011b8:	84aa                	mv	s1,a0
    800011ba:	89ae                	mv	s3,a1
    800011bc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800011be:	57fd                	li	a5,-1
    800011c0:	83e9                	srli	a5,a5,0x1a
    800011c2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011c4:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011c6:	04b7e263          	bltu	a5,a1,8000120a <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    800011ca:	0149d933          	srl	s2,s3,s4
    800011ce:	1ff97913          	andi	s2,s2,511
    800011d2:	090e                	slli	s2,s2,0x3
    800011d4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011d6:	00093483          	ld	s1,0(s2)
    800011da:	0014f793          	andi	a5,s1,1
    800011de:	cf95                	beqz	a5,8000121a <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011e0:	80a9                	srli	s1,s1,0xa
    800011e2:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    800011e4:	3a5d                	addiw	s4,s4,-9
    800011e6:	ff6a12e3          	bne	s4,s6,800011ca <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    800011ea:	00c9d513          	srli	a0,s3,0xc
    800011ee:	1ff57513          	andi	a0,a0,511
    800011f2:	050e                	slli	a0,a0,0x3
    800011f4:	9526                	add	a0,a0,s1
}
    800011f6:	70e2                	ld	ra,56(sp)
    800011f8:	7442                	ld	s0,48(sp)
    800011fa:	74a2                	ld	s1,40(sp)
    800011fc:	7902                	ld	s2,32(sp)
    800011fe:	69e2                	ld	s3,24(sp)
    80001200:	6a42                	ld	s4,16(sp)
    80001202:	6aa2                	ld	s5,8(sp)
    80001204:	6b02                	ld	s6,0(sp)
    80001206:	6121                	addi	sp,sp,64
    80001208:	8082                	ret
    panic("walk");
    8000120a:	00008517          	auipc	a0,0x8
    8000120e:	ee650513          	addi	a0,a0,-282 # 800090f0 <etext+0xf0>
    80001212:	fffff097          	auipc	ra,0xfffff
    80001216:	34e080e7          	jalr	846(ra) # 80000560 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000121a:	020a8663          	beqz	s5,80001246 <walk+0xa2>
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	a94080e7          	jalr	-1388(ra) # 80000cb2 <kalloc>
    80001226:	84aa                	mv	s1,a0
    80001228:	d579                	beqz	a0,800011f6 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000122a:	6605                	lui	a2,0x1
    8000122c:	4581                	li	a1,0
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	c7a080e7          	jalr	-902(ra) # 80000ea8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001236:	00c4d793          	srli	a5,s1,0xc
    8000123a:	07aa                	slli	a5,a5,0xa
    8000123c:	0017e793          	ori	a5,a5,1
    80001240:	00f93023          	sd	a5,0(s2)
    80001244:	b745                	j	800011e4 <walk+0x40>
        return 0;
    80001246:	4501                	li	a0,0
    80001248:	b77d                	j	800011f6 <walk+0x52>

000000008000124a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000124a:	57fd                	li	a5,-1
    8000124c:	83e9                	srli	a5,a5,0x1a
    8000124e:	00b7f463          	bgeu	a5,a1,80001256 <walkaddr+0xc>
    return 0;
    80001252:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001254:	8082                	ret
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000125e:	4601                	li	a2,0
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f44080e7          	jalr	-188(ra) # 800011a4 <walk>
  if(pte == 0)
    80001268:	c105                	beqz	a0,80001288 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000126a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000126c:	0117f693          	andi	a3,a5,17
    80001270:	4745                	li	a4,17
    return 0;
    80001272:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001274:	00e68663          	beq	a3,a4,80001280 <walkaddr+0x36>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret
  pa = PTE2PA(*pte);
    80001280:	83a9                	srli	a5,a5,0xa
    80001282:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001286:	bfcd                	j	80001278 <walkaddr+0x2e>
    return 0;
    80001288:	4501                	li	a0,0
    8000128a:	b7fd                	j	80001278 <walkaddr+0x2e>

000000008000128c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000128c:	715d                	addi	sp,sp,-80
    8000128e:	e486                	sd	ra,72(sp)
    80001290:	e0a2                	sd	s0,64(sp)
    80001292:	fc26                	sd	s1,56(sp)
    80001294:	f84a                	sd	s2,48(sp)
    80001296:	f44e                	sd	s3,40(sp)
    80001298:	f052                	sd	s4,32(sp)
    8000129a:	ec56                	sd	s5,24(sp)
    8000129c:	e85a                	sd	s6,16(sp)
    8000129e:	e45e                	sd	s7,8(sp)
    800012a0:	e062                	sd	s8,0(sp)
    800012a2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800012a4:	ca21                	beqz	a2,800012f4 <mappages+0x68>
    800012a6:	8aaa                	mv	s5,a0
    800012a8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800012aa:	777d                	lui	a4,0xfffff
    800012ac:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800012b0:	fff58993          	addi	s3,a1,-1
    800012b4:	99b2                	add	s3,s3,a2
    800012b6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800012ba:	893e                	mv	s2,a5
    800012bc:	40f68a33          	sub	s4,a3,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    800012c0:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012c2:	6c05                	lui	s8,0x1
    800012c4:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800012c8:	865e                	mv	a2,s7
    800012ca:	85ca                	mv	a1,s2
    800012cc:	8556                	mv	a0,s5
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	ed6080e7          	jalr	-298(ra) # 800011a4 <walk>
    800012d6:	cd1d                	beqz	a0,80001314 <mappages+0x88>
    if(*pte & PTE_V)
    800012d8:	611c                	ld	a5,0(a0)
    800012da:	8b85                	andi	a5,a5,1
    800012dc:	e785                	bnez	a5,80001304 <mappages+0x78>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800012de:	80b1                	srli	s1,s1,0xc
    800012e0:	04aa                	slli	s1,s1,0xa
    800012e2:	0164e4b3          	or	s1,s1,s6
    800012e6:	0014e493          	ori	s1,s1,1
    800012ea:	e104                	sd	s1,0(a0)
    if(a == last)
    800012ec:	05390163          	beq	s2,s3,8000132e <mappages+0xa2>
    a += PGSIZE;
    800012f0:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800012f2:	bfc9                	j	800012c4 <mappages+0x38>
    panic("mappages: size");
    800012f4:	00008517          	auipc	a0,0x8
    800012f8:	e0450513          	addi	a0,a0,-508 # 800090f8 <etext+0xf8>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	264080e7          	jalr	612(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001304:	00008517          	auipc	a0,0x8
    80001308:	e0450513          	addi	a0,a0,-508 # 80009108 <etext+0x108>
    8000130c:	fffff097          	auipc	ra,0xfffff
    80001310:	254080e7          	jalr	596(ra) # 80000560 <panic>
      return -1;
    80001314:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001316:	60a6                	ld	ra,72(sp)
    80001318:	6406                	ld	s0,64(sp)
    8000131a:	74e2                	ld	s1,56(sp)
    8000131c:	7942                	ld	s2,48(sp)
    8000131e:	79a2                	ld	s3,40(sp)
    80001320:	7a02                	ld	s4,32(sp)
    80001322:	6ae2                	ld	s5,24(sp)
    80001324:	6b42                	ld	s6,16(sp)
    80001326:	6ba2                	ld	s7,8(sp)
    80001328:	6c02                	ld	s8,0(sp)
    8000132a:	6161                	addi	sp,sp,80
    8000132c:	8082                	ret
  return 0;
    8000132e:	4501                	li	a0,0
    80001330:	b7dd                	j	80001316 <mappages+0x8a>

0000000080001332 <kvmmap>:
{
    80001332:	1141                	addi	sp,sp,-16
    80001334:	e406                	sd	ra,8(sp)
    80001336:	e022                	sd	s0,0(sp)
    80001338:	0800                	addi	s0,sp,16
    8000133a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000133c:	86b2                	mv	a3,a2
    8000133e:	863e                	mv	a2,a5
    80001340:	00000097          	auipc	ra,0x0
    80001344:	f4c080e7          	jalr	-180(ra) # 8000128c <mappages>
    80001348:	e509                	bnez	a0,80001352 <kvmmap+0x20>
}
    8000134a:	60a2                	ld	ra,8(sp)
    8000134c:	6402                	ld	s0,0(sp)
    8000134e:	0141                	addi	sp,sp,16
    80001350:	8082                	ret
    panic("kvmmap");
    80001352:	00008517          	auipc	a0,0x8
    80001356:	dc650513          	addi	a0,a0,-570 # 80009118 <etext+0x118>
    8000135a:	fffff097          	auipc	ra,0xfffff
    8000135e:	206080e7          	jalr	518(ra) # 80000560 <panic>

0000000080001362 <kvmmake>:
{
    80001362:	1101                	addi	sp,sp,-32
    80001364:	ec06                	sd	ra,24(sp)
    80001366:	e822                	sd	s0,16(sp)
    80001368:	e426                	sd	s1,8(sp)
    8000136a:	e04a                	sd	s2,0(sp)
    8000136c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	944080e7          	jalr	-1724(ra) # 80000cb2 <kalloc>
    80001376:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	b2c080e7          	jalr	-1236(ra) # 80000ea8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001384:	4719                	li	a4,6
    80001386:	6685                	lui	a3,0x1
    80001388:	10000637          	lui	a2,0x10000
    8000138c:	85b2                	mv	a1,a2
    8000138e:	8526                	mv	a0,s1
    80001390:	00000097          	auipc	ra,0x0
    80001394:	fa2080e7          	jalr	-94(ra) # 80001332 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001398:	4719                	li	a4,6
    8000139a:	6685                	lui	a3,0x1
    8000139c:	10001637          	lui	a2,0x10001
    800013a0:	85b2                	mv	a1,a2
    800013a2:	8526                	mv	a0,s1
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	f8e080e7          	jalr	-114(ra) # 80001332 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013ac:	4719                	li	a4,6
    800013ae:	004006b7          	lui	a3,0x400
    800013b2:	0c000637          	lui	a2,0xc000
    800013b6:	85b2                	mv	a1,a2
    800013b8:	8526                	mv	a0,s1
    800013ba:	00000097          	auipc	ra,0x0
    800013be:	f78080e7          	jalr	-136(ra) # 80001332 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013c2:	00008917          	auipc	s2,0x8
    800013c6:	c3e90913          	addi	s2,s2,-962 # 80009000 <etext>
    800013ca:	4729                	li	a4,10
    800013cc:	80008697          	auipc	a3,0x80008
    800013d0:	c3468693          	addi	a3,a3,-972 # 9000 <_entry-0x7fff7000>
    800013d4:	4605                	li	a2,1
    800013d6:	067e                	slli	a2,a2,0x1f
    800013d8:	85b2                	mv	a1,a2
    800013da:	8526                	mv	a0,s1
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	f56080e7          	jalr	-170(ra) # 80001332 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013e4:	4719                	li	a4,6
    800013e6:	46c5                	li	a3,17
    800013e8:	06ee                	slli	a3,a3,0x1b
    800013ea:	412686b3          	sub	a3,a3,s2
    800013ee:	864a                	mv	a2,s2
    800013f0:	85ca                	mv	a1,s2
    800013f2:	8526                	mv	a0,s1
    800013f4:	00000097          	auipc	ra,0x0
    800013f8:	f3e080e7          	jalr	-194(ra) # 80001332 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013fc:	4729                	li	a4,10
    800013fe:	6685                	lui	a3,0x1
    80001400:	00007617          	auipc	a2,0x7
    80001404:	c0060613          	addi	a2,a2,-1024 # 80008000 <_trampoline>
    80001408:	040005b7          	lui	a1,0x4000
    8000140c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000140e:	05b2                	slli	a1,a1,0xc
    80001410:	8526                	mv	a0,s1
    80001412:	00000097          	auipc	ra,0x0
    80001416:	f20080e7          	jalr	-224(ra) # 80001332 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000141a:	8526                	mv	a0,s1
    8000141c:	00000097          	auipc	ra,0x0
    80001420:	714080e7          	jalr	1812(ra) # 80001b30 <proc_mapstacks>
}
    80001424:	8526                	mv	a0,s1
    80001426:	60e2                	ld	ra,24(sp)
    80001428:	6442                	ld	s0,16(sp)
    8000142a:	64a2                	ld	s1,8(sp)
    8000142c:	6902                	ld	s2,0(sp)
    8000142e:	6105                	addi	sp,sp,32
    80001430:	8082                	ret

0000000080001432 <kvminit>:
{
    80001432:	1141                	addi	sp,sp,-16
    80001434:	e406                	sd	ra,8(sp)
    80001436:	e022                	sd	s0,0(sp)
    80001438:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	f28080e7          	jalr	-216(ra) # 80001362 <kvmmake>
    80001442:	00008797          	auipc	a5,0x8
    80001446:	50a7bf23          	sd	a0,1310(a5) # 80009960 <kernel_pagetable>
}
    8000144a:	60a2                	ld	ra,8(sp)
    8000144c:	6402                	ld	s0,0(sp)
    8000144e:	0141                	addi	sp,sp,16
    80001450:	8082                	ret

0000000080001452 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001452:	715d                	addi	sp,sp,-80
    80001454:	e486                	sd	ra,72(sp)
    80001456:	e0a2                	sd	s0,64(sp)
    80001458:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000145a:	03459793          	slli	a5,a1,0x34
    8000145e:	e39d                	bnez	a5,80001484 <uvmunmap+0x32>
    80001460:	f84a                	sd	s2,48(sp)
    80001462:	f44e                	sd	s3,40(sp)
    80001464:	f052                	sd	s4,32(sp)
    80001466:	ec56                	sd	s5,24(sp)
    80001468:	e85a                	sd	s6,16(sp)
    8000146a:	e45e                	sd	s7,8(sp)
    8000146c:	8a2a                	mv	s4,a0
    8000146e:	892e                	mv	s2,a1
    80001470:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001472:	0632                	slli	a2,a2,0xc
    80001474:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001478:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000147a:	6b05                	lui	s6,0x1
    8000147c:	0935fb63          	bgeu	a1,s3,80001512 <uvmunmap+0xc0>
    80001480:	fc26                	sd	s1,56(sp)
    80001482:	a8a9                	j	800014dc <uvmunmap+0x8a>
    80001484:	fc26                	sd	s1,56(sp)
    80001486:	f84a                	sd	s2,48(sp)
    80001488:	f44e                	sd	s3,40(sp)
    8000148a:	f052                	sd	s4,32(sp)
    8000148c:	ec56                	sd	s5,24(sp)
    8000148e:	e85a                	sd	s6,16(sp)
    80001490:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001492:	00008517          	auipc	a0,0x8
    80001496:	c8e50513          	addi	a0,a0,-882 # 80009120 <etext+0x120>
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	0c6080e7          	jalr	198(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    800014a2:	00008517          	auipc	a0,0x8
    800014a6:	c9650513          	addi	a0,a0,-874 # 80009138 <etext+0x138>
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	0b6080e7          	jalr	182(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    800014b2:	00008517          	auipc	a0,0x8
    800014b6:	c9650513          	addi	a0,a0,-874 # 80009148 <etext+0x148>
    800014ba:	fffff097          	auipc	ra,0xfffff
    800014be:	0a6080e7          	jalr	166(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    800014c2:	00008517          	auipc	a0,0x8
    800014c6:	c9e50513          	addi	a0,a0,-866 # 80009160 <etext+0x160>
    800014ca:	fffff097          	auipc	ra,0xfffff
    800014ce:	096080e7          	jalr	150(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800014d2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014d6:	995a                	add	s2,s2,s6
    800014d8:	03397c63          	bgeu	s2,s3,80001510 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014dc:	4601                	li	a2,0
    800014de:	85ca                	mv	a1,s2
    800014e0:	8552                	mv	a0,s4
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	cc2080e7          	jalr	-830(ra) # 800011a4 <walk>
    800014ea:	84aa                	mv	s1,a0
    800014ec:	d95d                	beqz	a0,800014a2 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    800014ee:	6108                	ld	a0,0(a0)
    800014f0:	00157793          	andi	a5,a0,1
    800014f4:	dfdd                	beqz	a5,800014b2 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014f6:	3ff57793          	andi	a5,a0,1023
    800014fa:	fd7784e3          	beq	a5,s7,800014c2 <uvmunmap+0x70>
    if(do_free){
    800014fe:	fc0a8ae3          	beqz	s5,800014d2 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001502:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001504:	0532                	slli	a0,a0,0xc
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	63c080e7          	jalr	1596(ra) # 80000b42 <kfree>
    8000150e:	b7d1                	j	800014d2 <uvmunmap+0x80>
    80001510:	74e2                	ld	s1,56(sp)
    80001512:	7942                	ld	s2,48(sp)
    80001514:	79a2                	ld	s3,40(sp)
    80001516:	7a02                	ld	s4,32(sp)
    80001518:	6ae2                	ld	s5,24(sp)
    8000151a:	6b42                	ld	s6,16(sp)
    8000151c:	6ba2                	ld	s7,8(sp)
  }
}
    8000151e:	60a6                	ld	ra,72(sp)
    80001520:	6406                	ld	s0,64(sp)
    80001522:	6161                	addi	sp,sp,80
    80001524:	8082                	ret

0000000080001526 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001526:	1101                	addi	sp,sp,-32
    80001528:	ec06                	sd	ra,24(sp)
    8000152a:	e822                	sd	s0,16(sp)
    8000152c:	e426                	sd	s1,8(sp)
    8000152e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	782080e7          	jalr	1922(ra) # 80000cb2 <kalloc>
    80001538:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000153a:	c519                	beqz	a0,80001548 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000153c:	6605                	lui	a2,0x1
    8000153e:	4581                	li	a1,0
    80001540:	00000097          	auipc	ra,0x0
    80001544:	968080e7          	jalr	-1688(ra) # 80000ea8 <memset>
  return pagetable;
}
    80001548:	8526                	mv	a0,s1
    8000154a:	60e2                	ld	ra,24(sp)
    8000154c:	6442                	ld	s0,16(sp)
    8000154e:	64a2                	ld	s1,8(sp)
    80001550:	6105                	addi	sp,sp,32
    80001552:	8082                	ret

0000000080001554 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001554:	7179                	addi	sp,sp,-48
    80001556:	f406                	sd	ra,40(sp)
    80001558:	f022                	sd	s0,32(sp)
    8000155a:	ec26                	sd	s1,24(sp)
    8000155c:	e84a                	sd	s2,16(sp)
    8000155e:	e44e                	sd	s3,8(sp)
    80001560:	e052                	sd	s4,0(sp)
    80001562:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001564:	6785                	lui	a5,0x1
    80001566:	04f67863          	bgeu	a2,a5,800015b6 <uvmfirst+0x62>
    8000156a:	8a2a                	mv	s4,a0
    8000156c:	89ae                	mv	s3,a1
    8000156e:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001570:	fffff097          	auipc	ra,0xfffff
    80001574:	742080e7          	jalr	1858(ra) # 80000cb2 <kalloc>
    80001578:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000157a:	6605                	lui	a2,0x1
    8000157c:	4581                	li	a1,0
    8000157e:	00000097          	auipc	ra,0x0
    80001582:	92a080e7          	jalr	-1750(ra) # 80000ea8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001586:	4779                	li	a4,30
    80001588:	86ca                	mv	a3,s2
    8000158a:	6605                	lui	a2,0x1
    8000158c:	4581                	li	a1,0
    8000158e:	8552                	mv	a0,s4
    80001590:	00000097          	auipc	ra,0x0
    80001594:	cfc080e7          	jalr	-772(ra) # 8000128c <mappages>
  memmove(mem, src, sz);
    80001598:	8626                	mv	a2,s1
    8000159a:	85ce                	mv	a1,s3
    8000159c:	854a                	mv	a0,s2
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	96e080e7          	jalr	-1682(ra) # 80000f0c <memmove>
}
    800015a6:	70a2                	ld	ra,40(sp)
    800015a8:	7402                	ld	s0,32(sp)
    800015aa:	64e2                	ld	s1,24(sp)
    800015ac:	6942                	ld	s2,16(sp)
    800015ae:	69a2                	ld	s3,8(sp)
    800015b0:	6a02                	ld	s4,0(sp)
    800015b2:	6145                	addi	sp,sp,48
    800015b4:	8082                	ret
    panic("uvmfirst: more than a page");
    800015b6:	00008517          	auipc	a0,0x8
    800015ba:	bc250513          	addi	a0,a0,-1086 # 80009178 <etext+0x178>
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	fa2080e7          	jalr	-94(ra) # 80000560 <panic>

00000000800015c6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015c6:	1101                	addi	sp,sp,-32
    800015c8:	ec06                	sd	ra,24(sp)
    800015ca:	e822                	sd	s0,16(sp)
    800015cc:	e426                	sd	s1,8(sp)
    800015ce:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015d0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015d2:	00b67d63          	bgeu	a2,a1,800015ec <uvmdealloc+0x26>
    800015d6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015d8:	6785                	lui	a5,0x1
    800015da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015dc:	00f60733          	add	a4,a2,a5
    800015e0:	76fd                	lui	a3,0xfffff
    800015e2:	8f75                	and	a4,a4,a3
    800015e4:	97ae                	add	a5,a5,a1
    800015e6:	8ff5                	and	a5,a5,a3
    800015e8:	00f76863          	bltu	a4,a5,800015f8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800015ec:	8526                	mv	a0,s1
    800015ee:	60e2                	ld	ra,24(sp)
    800015f0:	6442                	ld	s0,16(sp)
    800015f2:	64a2                	ld	s1,8(sp)
    800015f4:	6105                	addi	sp,sp,32
    800015f6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015f8:	8f99                	sub	a5,a5,a4
    800015fa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800015fc:	4685                	li	a3,1
    800015fe:	0007861b          	sext.w	a2,a5
    80001602:	85ba                	mv	a1,a4
    80001604:	00000097          	auipc	ra,0x0
    80001608:	e4e080e7          	jalr	-434(ra) # 80001452 <uvmunmap>
    8000160c:	b7c5                	j	800015ec <uvmdealloc+0x26>

000000008000160e <uvmalloc>:
  if(newsz < oldsz)
    8000160e:	0ab66f63          	bltu	a2,a1,800016cc <uvmalloc+0xbe>
{
    80001612:	715d                	addi	sp,sp,-80
    80001614:	e486                	sd	ra,72(sp)
    80001616:	e0a2                	sd	s0,64(sp)
    80001618:	f052                	sd	s4,32(sp)
    8000161a:	ec56                	sd	s5,24(sp)
    8000161c:	e85a                	sd	s6,16(sp)
    8000161e:	0880                	addi	s0,sp,80
    80001620:	8b2a                	mv	s6,a0
    80001622:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    80001624:	6785                	lui	a5,0x1
    80001626:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001628:	95be                	add	a1,a1,a5
    8000162a:	77fd                	lui	a5,0xfffff
    8000162c:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001630:	0aca7063          	bgeu	s4,a2,800016d0 <uvmalloc+0xc2>
    80001634:	fc26                	sd	s1,56(sp)
    80001636:	f84a                	sd	s2,48(sp)
    80001638:	f44e                	sd	s3,40(sp)
    8000163a:	e45e                	sd	s7,8(sp)
    8000163c:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    8000163e:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001640:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	66e080e7          	jalr	1646(ra) # 80000cb2 <kalloc>
    8000164c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000164e:	c915                	beqz	a0,80001682 <uvmalloc+0x74>
    memset(mem, 0, PGSIZE);
    80001650:	864e                	mv	a2,s3
    80001652:	4581                	li	a1,0
    80001654:	00000097          	auipc	ra,0x0
    80001658:	854080e7          	jalr	-1964(ra) # 80000ea8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000165c:	875e                	mv	a4,s7
    8000165e:	86a6                	mv	a3,s1
    80001660:	864e                	mv	a2,s3
    80001662:	85ca                	mv	a1,s2
    80001664:	855a                	mv	a0,s6
    80001666:	00000097          	auipc	ra,0x0
    8000166a:	c26080e7          	jalr	-986(ra) # 8000128c <mappages>
    8000166e:	ed0d                	bnez	a0,800016a8 <uvmalloc+0x9a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001670:	994e                	add	s2,s2,s3
    80001672:	fd5969e3          	bltu	s2,s5,80001644 <uvmalloc+0x36>
  return newsz;
    80001676:	8556                	mv	a0,s5
    80001678:	74e2                	ld	s1,56(sp)
    8000167a:	7942                	ld	s2,48(sp)
    8000167c:	79a2                	ld	s3,40(sp)
    8000167e:	6ba2                	ld	s7,8(sp)
    80001680:	a829                	j	8000169a <uvmalloc+0x8c>
      uvmdealloc(pagetable, a, oldsz);
    80001682:	8652                	mv	a2,s4
    80001684:	85ca                	mv	a1,s2
    80001686:	855a                	mv	a0,s6
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	f3e080e7          	jalr	-194(ra) # 800015c6 <uvmdealloc>
      return 0;
    80001690:	4501                	li	a0,0
    80001692:	74e2                	ld	s1,56(sp)
    80001694:	7942                	ld	s2,48(sp)
    80001696:	79a2                	ld	s3,40(sp)
    80001698:	6ba2                	ld	s7,8(sp)
}
    8000169a:	60a6                	ld	ra,72(sp)
    8000169c:	6406                	ld	s0,64(sp)
    8000169e:	7a02                	ld	s4,32(sp)
    800016a0:	6ae2                	ld	s5,24(sp)
    800016a2:	6b42                	ld	s6,16(sp)
    800016a4:	6161                	addi	sp,sp,80
    800016a6:	8082                	ret
      kfree(mem);
    800016a8:	8526                	mv	a0,s1
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	498080e7          	jalr	1176(ra) # 80000b42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016b2:	8652                	mv	a2,s4
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	f0e080e7          	jalr	-242(ra) # 800015c6 <uvmdealloc>
      return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	74e2                	ld	s1,56(sp)
    800016c4:	7942                	ld	s2,48(sp)
    800016c6:	79a2                	ld	s3,40(sp)
    800016c8:	6ba2                	ld	s7,8(sp)
    800016ca:	bfc1                	j	8000169a <uvmalloc+0x8c>
    return oldsz;
    800016cc:	852e                	mv	a0,a1
}
    800016ce:	8082                	ret
  return newsz;
    800016d0:	8532                	mv	a0,a2
    800016d2:	b7e1                	j	8000169a <uvmalloc+0x8c>

00000000800016d4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016d4:	7179                	addi	sp,sp,-48
    800016d6:	f406                	sd	ra,40(sp)
    800016d8:	f022                	sd	s0,32(sp)
    800016da:	ec26                	sd	s1,24(sp)
    800016dc:	e84a                	sd	s2,16(sp)
    800016de:	e44e                	sd	s3,8(sp)
    800016e0:	e052                	sd	s4,0(sp)
    800016e2:	1800                	addi	s0,sp,48
    800016e4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016e6:	84aa                	mv	s1,a0
    800016e8:	6905                	lui	s2,0x1
    800016ea:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ec:	4985                	li	s3,1
    800016ee:	a829                	j	80001708 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016f0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800016f2:	00c79513          	slli	a0,a5,0xc
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	fde080e7          	jalr	-34(ra) # 800016d4 <freewalk>
      pagetable[i] = 0;
    800016fe:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001702:	04a1                	addi	s1,s1,8
    80001704:	03248163          	beq	s1,s2,80001726 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001708:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000170a:	00f7f713          	andi	a4,a5,15
    8000170e:	ff3701e3          	beq	a4,s3,800016f0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001712:	8b85                	andi	a5,a5,1
    80001714:	d7fd                	beqz	a5,80001702 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001716:	00008517          	auipc	a0,0x8
    8000171a:	a8250513          	addi	a0,a0,-1406 # 80009198 <etext+0x198>
    8000171e:	fffff097          	auipc	ra,0xfffff
    80001722:	e42080e7          	jalr	-446(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	41a080e7          	jalr	1050(ra) # 80000b42 <kfree>
}
    80001730:	70a2                	ld	ra,40(sp)
    80001732:	7402                	ld	s0,32(sp)
    80001734:	64e2                	ld	s1,24(sp)
    80001736:	6942                	ld	s2,16(sp)
    80001738:	69a2                	ld	s3,8(sp)
    8000173a:	6a02                	ld	s4,0(sp)
    8000173c:	6145                	addi	sp,sp,48
    8000173e:	8082                	ret

0000000080001740 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001740:	1101                	addi	sp,sp,-32
    80001742:	ec06                	sd	ra,24(sp)
    80001744:	e822                	sd	s0,16(sp)
    80001746:	e426                	sd	s1,8(sp)
    80001748:	1000                	addi	s0,sp,32
    8000174a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000174c:	e999                	bnez	a1,80001762 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000174e:	8526                	mv	a0,s1
    80001750:	00000097          	auipc	ra,0x0
    80001754:	f84080e7          	jalr	-124(ra) # 800016d4 <freewalk>
}
    80001758:	60e2                	ld	ra,24(sp)
    8000175a:	6442                	ld	s0,16(sp)
    8000175c:	64a2                	ld	s1,8(sp)
    8000175e:	6105                	addi	sp,sp,32
    80001760:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001762:	6785                	lui	a5,0x1
    80001764:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001766:	95be                	add	a1,a1,a5
    80001768:	4685                	li	a3,1
    8000176a:	00c5d613          	srli	a2,a1,0xc
    8000176e:	4581                	li	a1,0
    80001770:	00000097          	auipc	ra,0x0
    80001774:	ce2080e7          	jalr	-798(ra) # 80001452 <uvmunmap>
    80001778:	bfd9                	j	8000174e <uvmfree+0xe>

000000008000177a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000177a:	ca69                	beqz	a2,8000184c <uvmcopy+0xd2>
{
    8000177c:	715d                	addi	sp,sp,-80
    8000177e:	e486                	sd	ra,72(sp)
    80001780:	e0a2                	sd	s0,64(sp)
    80001782:	fc26                	sd	s1,56(sp)
    80001784:	f84a                	sd	s2,48(sp)
    80001786:	f44e                	sd	s3,40(sp)
    80001788:	f052                	sd	s4,32(sp)
    8000178a:	ec56                	sd	s5,24(sp)
    8000178c:	e85a                	sd	s6,16(sp)
    8000178e:	e45e                	sd	s7,8(sp)
    80001790:	e062                	sd	s8,0(sp)
    80001792:	0880                	addi	s0,sp,80
    80001794:	8baa                	mv	s7,a0
    80001796:	8b2e                	mv	s6,a1
    80001798:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000179a:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000179c:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000179e:	4601                	li	a2,0
    800017a0:	85ce                	mv	a1,s3
    800017a2:	855e                	mv	a0,s7
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	a00080e7          	jalr	-1536(ra) # 800011a4 <walk>
    800017ac:	c529                	beqz	a0,800017f6 <uvmcopy+0x7c>
    if((*pte & PTE_V) == 0)
    800017ae:	6118                	ld	a4,0(a0)
    800017b0:	00177793          	andi	a5,a4,1
    800017b4:	cba9                	beqz	a5,80001806 <uvmcopy+0x8c>
    pa = PTE2PA(*pte);
    800017b6:	00a75593          	srli	a1,a4,0xa
    800017ba:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800017be:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800017c2:	fffff097          	auipc	ra,0xfffff
    800017c6:	4f0080e7          	jalr	1264(ra) # 80000cb2 <kalloc>
    800017ca:	892a                	mv	s2,a0
    800017cc:	c931                	beqz	a0,80001820 <uvmcopy+0xa6>
    memmove(mem, (char*)pa, PGSIZE);
    800017ce:	8652                	mv	a2,s4
    800017d0:	85e2                	mv	a1,s8
    800017d2:	fffff097          	auipc	ra,0xfffff
    800017d6:	73a080e7          	jalr	1850(ra) # 80000f0c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800017da:	8726                	mv	a4,s1
    800017dc:	86ca                	mv	a3,s2
    800017de:	8652                	mv	a2,s4
    800017e0:	85ce                	mv	a1,s3
    800017e2:	855a                	mv	a0,s6
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	aa8080e7          	jalr	-1368(ra) # 8000128c <mappages>
    800017ec:	e50d                	bnez	a0,80001816 <uvmcopy+0x9c>
  for(i = 0; i < sz; i += PGSIZE){
    800017ee:	99d2                	add	s3,s3,s4
    800017f0:	fb59e7e3          	bltu	s3,s5,8000179e <uvmcopy+0x24>
    800017f4:	a081                	j	80001834 <uvmcopy+0xba>
      panic("uvmcopy: pte should exist");
    800017f6:	00008517          	auipc	a0,0x8
    800017fa:	9b250513          	addi	a0,a0,-1614 # 800091a8 <etext+0x1a8>
    800017fe:	fffff097          	auipc	ra,0xfffff
    80001802:	d62080e7          	jalr	-670(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001806:	00008517          	auipc	a0,0x8
    8000180a:	9c250513          	addi	a0,a0,-1598 # 800091c8 <etext+0x1c8>
    8000180e:	fffff097          	auipc	ra,0xfffff
    80001812:	d52080e7          	jalr	-686(ra) # 80000560 <panic>
      kfree(mem);
    80001816:	854a                	mv	a0,s2
    80001818:	fffff097          	auipc	ra,0xfffff
    8000181c:	32a080e7          	jalr	810(ra) # 80000b42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001820:	4685                	li	a3,1
    80001822:	00c9d613          	srli	a2,s3,0xc
    80001826:	4581                	li	a1,0
    80001828:	855a                	mv	a0,s6
    8000182a:	00000097          	auipc	ra,0x0
    8000182e:	c28080e7          	jalr	-984(ra) # 80001452 <uvmunmap>
  return -1;
    80001832:	557d                	li	a0,-1
}
    80001834:	60a6                	ld	ra,72(sp)
    80001836:	6406                	ld	s0,64(sp)
    80001838:	74e2                	ld	s1,56(sp)
    8000183a:	7942                	ld	s2,48(sp)
    8000183c:	79a2                	ld	s3,40(sp)
    8000183e:	7a02                	ld	s4,32(sp)
    80001840:	6ae2                	ld	s5,24(sp)
    80001842:	6b42                	ld	s6,16(sp)
    80001844:	6ba2                	ld	s7,8(sp)
    80001846:	6c02                	ld	s8,0(sp)
    80001848:	6161                	addi	sp,sp,80
    8000184a:	8082                	ret
  return 0;
    8000184c:	4501                	li	a0,0
}
    8000184e:	8082                	ret

0000000080001850 <uvmcowcopy>:

int uvmcowcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	e062                	sd	s8,0(sp)
    80001858:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for (i = 0; i < sz; i += PGSIZE)
    8000185a:	c26d                	beqz	a2,8000193c <uvmcowcopy+0xec>
    8000185c:	fc26                	sd	s1,56(sp)
    8000185e:	f84a                	sd	s2,48(sp)
    80001860:	f44e                	sd	s3,40(sp)
    80001862:	f052                	sd	s4,32(sp)
    80001864:	ec56                	sd	s5,24(sp)
    80001866:	e85a                	sd	s6,16(sp)
    80001868:	e45e                	sd	s7,8(sp)
    8000186a:	8aaa                	mv	s5,a0
    8000186c:	8a2e                	mv	s4,a1
    8000186e:	89b2                	mv	s3,a2
    80001870:	4481                	li	s1,0

    // Mark the page as read-only and set the copy-on-write flag.
    if (flags & PTE_W)
    {
      flags = (flags & (~PTE_W)) | PTE_COW;
      *pte = PA2PTE(pa) | flags;
    80001872:	7b7d                	lui	s6,0xfffff
    80001874:	002b5b13          	srli	s6,s6,0x2
    }
    if (mappages(new, i, PGSIZE, pa, flags) != 0)
    80001878:	6905                	lui	s2,0x1
    8000187a:	a899                	j	800018d0 <uvmcowcopy+0x80>
      panic("uvmcowcopy: pte should exist");
    8000187c:	00008517          	auipc	a0,0x8
    80001880:	96c50513          	addi	a0,a0,-1684 # 800091e8 <etext+0x1e8>
    80001884:	fffff097          	auipc	ra,0xfffff
    80001888:	cdc080e7          	jalr	-804(ra) # 80000560 <panic>
      panic("uvmcowcopy: page not present");
    8000188c:	00008517          	auipc	a0,0x8
    80001890:	97c50513          	addi	a0,a0,-1668 # 80009208 <etext+0x208>
    80001894:	fffff097          	auipc	ra,0xfffff
    80001898:	ccc080e7          	jalr	-820(ra) # 80000560 <panic>
      flags = (flags & (~PTE_W)) | PTE_COW;
    8000189c:	3db77693          	andi	a3,a4,987
    800018a0:	0206e713          	ori	a4,a3,32
      *pte = PA2PTE(pa) | flags;
    800018a4:	0167f7b3          	and	a5,a5,s6
    800018a8:	8fd9                	or	a5,a5,a4
    800018aa:	e11c                	sd	a5,0(a0)
    if (mappages(new, i, PGSIZE, pa, flags) != 0)
    800018ac:	86de                	mv	a3,s7
    800018ae:	864a                	mv	a2,s2
    800018b0:	85a6                	mv	a1,s1
    800018b2:	8552                	mv	a0,s4
    800018b4:	00000097          	auipc	ra,0x0
    800018b8:	9d8080e7          	jalr	-1576(ra) # 8000128c <mappages>
    800018bc:	8c2a                	mv	s8,a0
    800018be:	e121                	bnez	a0,800018fe <uvmcowcopy+0xae>
      goto err;

    // Increment the reference count for the shared page.
    incref((void *)pa); // Increment reference count for the shared page
    800018c0:	855e                	mv	a0,s7
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	18a080e7          	jalr	394(ra) # 80000a4c <incref>
  for (i = 0; i < sz; i += PGSIZE)
    800018ca:	94ca                	add	s1,s1,s2
    800018cc:	0734f063          	bgeu	s1,s3,8000192c <uvmcowcopy+0xdc>
    if ((pte = walk(old, i, 0)) == 0)
    800018d0:	4601                	li	a2,0
    800018d2:	85a6                	mv	a1,s1
    800018d4:	8556                	mv	a0,s5
    800018d6:	00000097          	auipc	ra,0x0
    800018da:	8ce080e7          	jalr	-1842(ra) # 800011a4 <walk>
    800018de:	dd59                	beqz	a0,8000187c <uvmcowcopy+0x2c>
    if ((*pte & PTE_V) == 0)
    800018e0:	611c                	ld	a5,0(a0)
    800018e2:	0017f713          	andi	a4,a5,1
    800018e6:	d35d                	beqz	a4,8000188c <uvmcowcopy+0x3c>
    pa = PTE2PA(*pte);
    800018e8:	00a7db93          	srli	s7,a5,0xa
    800018ec:	0bb2                	slli	s7,s7,0xc
    flags = PTE_FLAGS(*pte);
    800018ee:	0007871b          	sext.w	a4,a5
    if (flags & PTE_W)
    800018f2:	0047f693          	andi	a3,a5,4
    800018f6:	f2dd                	bnez	a3,8000189c <uvmcowcopy+0x4c>
    flags = PTE_FLAGS(*pte);
    800018f8:	3ff77713          	andi	a4,a4,1023
    800018fc:	bf45                	j	800018ac <uvmcowcopy+0x5c>
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800018fe:	4685                	li	a3,1
    80001900:	00c4d613          	srli	a2,s1,0xc
    80001904:	4581                	li	a1,0
    80001906:	8552                	mv	a0,s4
    80001908:	00000097          	auipc	ra,0x0
    8000190c:	b4a080e7          	jalr	-1206(ra) # 80001452 <uvmunmap>
  return -1;
    80001910:	5c7d                	li	s8,-1
    80001912:	74e2                	ld	s1,56(sp)
    80001914:	7942                	ld	s2,48(sp)
    80001916:	79a2                	ld	s3,40(sp)
    80001918:	7a02                	ld	s4,32(sp)
    8000191a:	6ae2                	ld	s5,24(sp)
    8000191c:	6b42                	ld	s6,16(sp)
    8000191e:	6ba2                	ld	s7,8(sp)
}
    80001920:	8562                	mv	a0,s8
    80001922:	60a6                	ld	ra,72(sp)
    80001924:	6406                	ld	s0,64(sp)
    80001926:	6c02                	ld	s8,0(sp)
    80001928:	6161                	addi	sp,sp,80
    8000192a:	8082                	ret
    8000192c:	74e2                	ld	s1,56(sp)
    8000192e:	7942                	ld	s2,48(sp)
    80001930:	79a2                	ld	s3,40(sp)
    80001932:	7a02                	ld	s4,32(sp)
    80001934:	6ae2                	ld	s5,24(sp)
    80001936:	6b42                	ld	s6,16(sp)
    80001938:	6ba2                	ld	s7,8(sp)
    8000193a:	b7dd                	j	80001920 <uvmcowcopy+0xd0>
  return 0;
    8000193c:	4c01                	li	s8,0
    8000193e:	b7cd                	j	80001920 <uvmcowcopy+0xd0>

0000000080001940 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001940:	1141                	addi	sp,sp,-16
    80001942:	e406                	sd	ra,8(sp)
    80001944:	e022                	sd	s0,0(sp)
    80001946:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001948:	4601                	li	a2,0
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	85a080e7          	jalr	-1958(ra) # 800011a4 <walk>
  if(pte == 0)
    80001952:	c901                	beqz	a0,80001962 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001954:	611c                	ld	a5,0(a0)
    80001956:	9bbd                	andi	a5,a5,-17
    80001958:	e11c                	sd	a5,0(a0)
}
    8000195a:	60a2                	ld	ra,8(sp)
    8000195c:	6402                	ld	s0,0(sp)
    8000195e:	0141                	addi	sp,sp,16
    80001960:	8082                	ret
    panic("uvmclear");
    80001962:	00008517          	auipc	a0,0x8
    80001966:	8c650513          	addi	a0,a0,-1850 # 80009228 <etext+0x228>
    8000196a:	fffff097          	auipc	ra,0xfffff
    8000196e:	bf6080e7          	jalr	-1034(ra) # 80000560 <panic>

0000000080001972 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001972:	c6bd                	beqz	a3,800019e0 <copyout+0x6e>
{
    80001974:	715d                	addi	sp,sp,-80
    80001976:	e486                	sd	ra,72(sp)
    80001978:	e0a2                	sd	s0,64(sp)
    8000197a:	fc26                	sd	s1,56(sp)
    8000197c:	f84a                	sd	s2,48(sp)
    8000197e:	f44e                	sd	s3,40(sp)
    80001980:	f052                	sd	s4,32(sp)
    80001982:	ec56                	sd	s5,24(sp)
    80001984:	e85a                	sd	s6,16(sp)
    80001986:	e45e                	sd	s7,8(sp)
    80001988:	e062                	sd	s8,0(sp)
    8000198a:	0880                	addi	s0,sp,80
    8000198c:	8b2a                	mv	s6,a0
    8000198e:	8c2e                	mv	s8,a1
    80001990:	8a32                	mv	s4,a2
    80001992:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001994:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001996:	6a85                	lui	s5,0x1
    80001998:	a015                	j	800019bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000199a:	9562                	add	a0,a0,s8
    8000199c:	0004861b          	sext.w	a2,s1
    800019a0:	85d2                	mv	a1,s4
    800019a2:	41250533          	sub	a0,a0,s2
    800019a6:	fffff097          	auipc	ra,0xfffff
    800019aa:	566080e7          	jalr	1382(ra) # 80000f0c <memmove>

    len -= n;
    800019ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800019b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800019b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800019b8:	02098263          	beqz	s3,800019dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800019bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019c0:	85ca                	mv	a1,s2
    800019c2:	855a                	mv	a0,s6
    800019c4:	00000097          	auipc	ra,0x0
    800019c8:	886080e7          	jalr	-1914(ra) # 8000124a <walkaddr>
    if(pa0 == 0)
    800019cc:	cd01                	beqz	a0,800019e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800019ce:	418904b3          	sub	s1,s2,s8
    800019d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800019d4:	fc99f3e3          	bgeu	s3,s1,8000199a <copyout+0x28>
    800019d8:	84ce                	mv	s1,s3
    800019da:	b7c1                	j	8000199a <copyout+0x28>
  }
  return 0;
    800019dc:	4501                	li	a0,0
    800019de:	a021                	j	800019e6 <copyout+0x74>
    800019e0:	4501                	li	a0,0
}
    800019e2:	8082                	ret
      return -1;
    800019e4:	557d                	li	a0,-1
}
    800019e6:	60a6                	ld	ra,72(sp)
    800019e8:	6406                	ld	s0,64(sp)
    800019ea:	74e2                	ld	s1,56(sp)
    800019ec:	7942                	ld	s2,48(sp)
    800019ee:	79a2                	ld	s3,40(sp)
    800019f0:	7a02                	ld	s4,32(sp)
    800019f2:	6ae2                	ld	s5,24(sp)
    800019f4:	6b42                	ld	s6,16(sp)
    800019f6:	6ba2                	ld	s7,8(sp)
    800019f8:	6c02                	ld	s8,0(sp)
    800019fa:	6161                	addi	sp,sp,80
    800019fc:	8082                	ret

00000000800019fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019fe:	caa5                	beqz	a3,80001a6e <copyin+0x70>
{
    80001a00:	715d                	addi	sp,sp,-80
    80001a02:	e486                	sd	ra,72(sp)
    80001a04:	e0a2                	sd	s0,64(sp)
    80001a06:	fc26                	sd	s1,56(sp)
    80001a08:	f84a                	sd	s2,48(sp)
    80001a0a:	f44e                	sd	s3,40(sp)
    80001a0c:	f052                	sd	s4,32(sp)
    80001a0e:	ec56                	sd	s5,24(sp)
    80001a10:	e85a                	sd	s6,16(sp)
    80001a12:	e45e                	sd	s7,8(sp)
    80001a14:	e062                	sd	s8,0(sp)
    80001a16:	0880                	addi	s0,sp,80
    80001a18:	8b2a                	mv	s6,a0
    80001a1a:	8a2e                	mv	s4,a1
    80001a1c:	8c32                	mv	s8,a2
    80001a1e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001a20:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a22:	6a85                	lui	s5,0x1
    80001a24:	a01d                	j	80001a4a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a26:	018505b3          	add	a1,a0,s8
    80001a2a:	0004861b          	sext.w	a2,s1
    80001a2e:	412585b3          	sub	a1,a1,s2
    80001a32:	8552                	mv	a0,s4
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	4d8080e7          	jalr	1240(ra) # 80000f0c <memmove>

    len -= n;
    80001a3c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001a40:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001a42:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a46:	02098263          	beqz	s3,80001a6a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001a4a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a4e:	85ca                	mv	a1,s2
    80001a50:	855a                	mv	a0,s6
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	7f8080e7          	jalr	2040(ra) # 8000124a <walkaddr>
    if(pa0 == 0)
    80001a5a:	cd01                	beqz	a0,80001a72 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001a5c:	418904b3          	sub	s1,s2,s8
    80001a60:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a62:	fc99f2e3          	bgeu	s3,s1,80001a26 <copyin+0x28>
    80001a66:	84ce                	mv	s1,s3
    80001a68:	bf7d                	j	80001a26 <copyin+0x28>
  }
  return 0;
    80001a6a:	4501                	li	a0,0
    80001a6c:	a021                	j	80001a74 <copyin+0x76>
    80001a6e:	4501                	li	a0,0
}
    80001a70:	8082                	ret
      return -1;
    80001a72:	557d                	li	a0,-1
}
    80001a74:	60a6                	ld	ra,72(sp)
    80001a76:	6406                	ld	s0,64(sp)
    80001a78:	74e2                	ld	s1,56(sp)
    80001a7a:	7942                	ld	s2,48(sp)
    80001a7c:	79a2                	ld	s3,40(sp)
    80001a7e:	7a02                	ld	s4,32(sp)
    80001a80:	6ae2                	ld	s5,24(sp)
    80001a82:	6b42                	ld	s6,16(sp)
    80001a84:	6ba2                	ld	s7,8(sp)
    80001a86:	6c02                	ld	s8,0(sp)
    80001a88:	6161                	addi	sp,sp,80
    80001a8a:	8082                	ret

0000000080001a8c <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80001a8c:	715d                	addi	sp,sp,-80
    80001a8e:	e486                	sd	ra,72(sp)
    80001a90:	e0a2                	sd	s0,64(sp)
    80001a92:	fc26                	sd	s1,56(sp)
    80001a94:	f84a                	sd	s2,48(sp)
    80001a96:	f44e                	sd	s3,40(sp)
    80001a98:	f052                	sd	s4,32(sp)
    80001a9a:	ec56                	sd	s5,24(sp)
    80001a9c:	e85a                	sd	s6,16(sp)
    80001a9e:	e45e                	sd	s7,8(sp)
    80001aa0:	0880                	addi	s0,sp,80
    80001aa2:	8aaa                	mv	s5,a0
    80001aa4:	89ae                	mv	s3,a1
    80001aa6:	8bb2                	mv	s7,a2
    80001aa8:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    80001aaa:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001aac:	6a05                	lui	s4,0x1
    80001aae:	a02d                	j	80001ad8 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001ab0:	00078023          	sb	zero,0(a5)
    80001ab4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001ab6:	0017c793          	xori	a5,a5,1
    80001aba:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001abe:	60a6                	ld	ra,72(sp)
    80001ac0:	6406                	ld	s0,64(sp)
    80001ac2:	74e2                	ld	s1,56(sp)
    80001ac4:	7942                	ld	s2,48(sp)
    80001ac6:	79a2                	ld	s3,40(sp)
    80001ac8:	7a02                	ld	s4,32(sp)
    80001aca:	6ae2                	ld	s5,24(sp)
    80001acc:	6b42                	ld	s6,16(sp)
    80001ace:	6ba2                	ld	s7,8(sp)
    80001ad0:	6161                	addi	sp,sp,80
    80001ad2:	8082                	ret
    srcva = va0 + PGSIZE;
    80001ad4:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001ad8:	c8a1                	beqz	s1,80001b28 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001ada:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001ade:	85ca                	mv	a1,s2
    80001ae0:	8556                	mv	a0,s5
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	768080e7          	jalr	1896(ra) # 8000124a <walkaddr>
    if(pa0 == 0)
    80001aea:	c129                	beqz	a0,80001b2c <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80001aec:	41790633          	sub	a2,s2,s7
    80001af0:	9652                	add	a2,a2,s4
    if(n > max)
    80001af2:	00c4f363          	bgeu	s1,a2,80001af8 <copyinstr+0x6c>
    80001af6:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001af8:	412b8bb3          	sub	s7,s7,s2
    80001afc:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001afe:	da79                	beqz	a2,80001ad4 <copyinstr+0x48>
    80001b00:	87ce                	mv	a5,s3
      if(*p == '\0'){
    80001b02:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001b06:	964e                	add	a2,a2,s3
    80001b08:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001b0a:	00f68733          	add	a4,a3,a5
    80001b0e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb3fe8>
    80001b12:	df59                	beqz	a4,80001ab0 <copyinstr+0x24>
        *dst = *p;
    80001b14:	00e78023          	sb	a4,0(a5)
      dst++;
    80001b18:	0785                	addi	a5,a5,1
    while(n > 0){
    80001b1a:	fec797e3          	bne	a5,a2,80001b08 <copyinstr+0x7c>
    80001b1e:	14fd                	addi	s1,s1,-1
    80001b20:	94ce                	add	s1,s1,s3
      --max;
    80001b22:	8c8d                	sub	s1,s1,a1
    80001b24:	89be                	mv	s3,a5
    80001b26:	b77d                	j	80001ad4 <copyinstr+0x48>
    80001b28:	4781                	li	a5,0
    80001b2a:	b771                	j	80001ab6 <copyinstr+0x2a>
      return -1;
    80001b2c:	557d                	li	a0,-1
    80001b2e:	bf41                	j	80001abe <copyinstr+0x32>

0000000080001b30 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001b30:	715d                	addi	sp,sp,-80
    80001b32:	e486                	sd	ra,72(sp)
    80001b34:	e0a2                	sd	s0,64(sp)
    80001b36:	fc26                	sd	s1,56(sp)
    80001b38:	f84a                	sd	s2,48(sp)
    80001b3a:	f44e                	sd	s3,40(sp)
    80001b3c:	f052                	sd	s4,32(sp)
    80001b3e:	ec56                	sd	s5,24(sp)
    80001b40:	e85a                	sd	s6,16(sp)
    80001b42:	e45e                	sd	s7,8(sp)
    80001b44:	e062                	sd	s8,0(sp)
    80001b46:	0880                	addi	s0,sp,80
    80001b48:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001b4a:	00231497          	auipc	s1,0x231
    80001b4e:	cee48493          	addi	s1,s1,-786 # 80232838 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001b52:	8c26                	mv	s8,s1
    80001b54:	8c1357b7          	lui	a5,0x8c135
    80001b58:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0beea205>
    80001b5c:	21cfb937          	lui	s2,0x21cfb
    80001b60:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001b64:	1902                	slli	s2,s2,0x20
    80001b66:	993e                	add	s2,s2,a5
    80001b68:	040009b7          	lui	s3,0x4000
    80001b6c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b6e:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b70:	4b99                	li	s7,6
    80001b72:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++)
    80001b74:	0023ea97          	auipc	s5,0x23e
    80001b78:	0c4a8a93          	addi	s5,s5,196 # 8023fc38 <tickslock>
    char *pa = kalloc();
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	136080e7          	jalr	310(ra) # 80000cb2 <kalloc>
    80001b84:	862a                	mv	a2,a0
    if (pa == 0)
    80001b86:	c131                	beqz	a0,80001bca <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int)(p - proc));
    80001b88:	418485b3          	sub	a1,s1,s8
    80001b8c:	8591                	srai	a1,a1,0x4
    80001b8e:	032585b3          	mul	a1,a1,s2
    80001b92:	2585                	addiw	a1,a1,1
    80001b94:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b98:	875e                	mv	a4,s7
    80001b9a:	86da                	mv	a3,s6
    80001b9c:	40b985b3          	sub	a1,s3,a1
    80001ba0:	8552                	mv	a0,s4
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	790080e7          	jalr	1936(ra) # 80001332 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001baa:	35048493          	addi	s1,s1,848
    80001bae:	fd5497e3          	bne	s1,s5,80001b7c <proc_mapstacks+0x4c>
  }
}
    80001bb2:	60a6                	ld	ra,72(sp)
    80001bb4:	6406                	ld	s0,64(sp)
    80001bb6:	74e2                	ld	s1,56(sp)
    80001bb8:	7942                	ld	s2,48(sp)
    80001bba:	79a2                	ld	s3,40(sp)
    80001bbc:	7a02                	ld	s4,32(sp)
    80001bbe:	6ae2                	ld	s5,24(sp)
    80001bc0:	6b42                	ld	s6,16(sp)
    80001bc2:	6ba2                	ld	s7,8(sp)
    80001bc4:	6c02                	ld	s8,0(sp)
    80001bc6:	6161                	addi	sp,sp,80
    80001bc8:	8082                	ret
      panic("kalloc");
    80001bca:	00007517          	auipc	a0,0x7
    80001bce:	66e50513          	addi	a0,a0,1646 # 80009238 <etext+0x238>
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	98e080e7          	jalr	-1650(ra) # 80000560 <panic>

0000000080001bda <rand>:
uint64 rand(void)
{
    80001bda:	1141                	addi	sp,sp,-16
    80001bdc:	e406                	sd	ra,8(sp)
    80001bde:	e022                	sd	s0,0(sp)
    80001be0:	0800                	addi	s0,sp,16
  static uint64 seed = 12345;         // Seed value (you can change this)
  seed = (seed * 48271) % 2147483647; // LCG formula
    80001be2:	00008697          	auipc	a3,0x8
    80001be6:	d0668693          	addi	a3,a3,-762 # 800098e8 <seed.2>
    80001bea:	629c                	ld	a5,0(a3)
    80001bec:	6731                	lui	a4,0xc
    80001bee:	c8f70713          	addi	a4,a4,-881 # bc8f <_entry-0x7fff4371>
    80001bf2:	02e787b3          	mul	a5,a5,a4
    80001bf6:	4505                	li	a0,1
    80001bf8:	1506                	slli	a0,a0,0x21
    80001bfa:	0515                	addi	a0,a0,5
    80001bfc:	02a7b533          	mulhu	a0,a5,a0
    80001c00:	40a78733          	sub	a4,a5,a0
    80001c04:	8305                	srli	a4,a4,0x1
    80001c06:	953a                	add	a0,a0,a4
    80001c08:	8179                	srli	a0,a0,0x1e
    80001c0a:	01f51713          	slli	a4,a0,0x1f
    80001c0e:	40a70533          	sub	a0,a4,a0
    80001c12:	40a78533          	sub	a0,a5,a0
    80001c16:	e288                	sd	a0,0(a3)
  return seed;
}
    80001c18:	60a2                	ld	ra,8(sp)
    80001c1a:	6402                	ld	s0,0(sp)
    80001c1c:	0141                	addi	sp,sp,16
    80001c1e:	8082                	ret

0000000080001c20 <Enqueue>:

void Enqueue(struct proc *p, int priority)
{
    80001c20:	1141                	addi	sp,sp,-16
    80001c22:	e406                	sd	ra,8(sp)
    80001c24:	e022                	sd	s0,0(sp)
    80001c26:	0800                	addi	s0,sp,16
  if (!p || priority < 0 || priority >= 4)
    80001c28:	c921                	beqz	a0,80001c78 <Enqueue+0x58>
    80001c2a:	478d                	li	a5,3
    80001c2c:	04b7e663          	bltu	a5,a1,80001c78 <Enqueue+0x58>
    return;
  p->ticks = 0;
    80001c30:	0e052023          	sw	zero,224(a0)
  if (queues_sizes[priority] < NPROC)
    80001c34:	00259713          	slli	a4,a1,0x2
    80001c38:	00230797          	auipc	a5,0x230
    80001c3c:	fc078793          	addi	a5,a5,-64 # 80231bf8 <queues_sizes>
    80001c40:	97ba                	add	a5,a5,a4
    80001c42:	4398                	lw	a4,0(a5)
    80001c44:	03f00793          	li	a5,63
    80001c48:	02e7c863          	blt	a5,a4,80001c78 <Enqueue+0x58>
  {
    mlfq[priority][queues_sizes[priority]++] = p;
    80001c4c:	00259693          	slli	a3,a1,0x2
    80001c50:	00230797          	auipc	a5,0x230
    80001c54:	fa878793          	addi	a5,a5,-88 # 80231bf8 <queues_sizes>
    80001c58:	97b6                	add	a5,a5,a3
    80001c5a:	0017069b          	addiw	a3,a4,1
    80001c5e:	c394                	sw	a3,0(a5)
    80001c60:	00659793          	slli	a5,a1,0x6
    80001c64:	97ba                	add	a5,a5,a4
    80001c66:	078e                	slli	a5,a5,0x3
    80001c68:	00230717          	auipc	a4,0x230
    80001c6c:	3d070713          	addi	a4,a4,976 # 80232038 <mlfq>
    80001c70:	97ba                	add	a5,a5,a4
    80001c72:	e388                	sd	a0,0(a5)
    p->priority = priority;
    80001c74:	0cb52c23          	sw	a1,216(a0)
  }
}
    80001c78:	60a2                	ld	ra,8(sp)
    80001c7a:	6402                	ld	s0,0(sp)
    80001c7c:	0141                	addi	sp,sp,16
    80001c7e:	8082                	ret

0000000080001c80 <dequeue>:

struct proc *dequeue(int priority)
{
    80001c80:	1141                	addi	sp,sp,-16
    80001c82:	e406                	sd	ra,8(sp)
    80001c84:	e022                	sd	s0,0(sp)
    80001c86:	0800                	addi	s0,sp,16
  if (priority < 0 || priority >= 4 || queues_sizes[priority] == 0)
    80001c88:	478d                	li	a5,3
    80001c8a:	08a7e663          	bltu	a5,a0,80001d16 <dequeue+0x96>
    80001c8e:	872a                	mv	a4,a0
    80001c90:	00251693          	slli	a3,a0,0x2
    80001c94:	00230797          	auipc	a5,0x230
    80001c98:	f6478793          	addi	a5,a5,-156 # 80231bf8 <queues_sizes>
    80001c9c:	97b6                	add	a5,a5,a3
    80001c9e:	438c                	lw	a1,0(a5)
    80001ca0:	cdad                	beqz	a1,80001d1a <dequeue+0x9a>
    return 0;

  struct proc *p = mlfq[priority][0];
    80001ca2:	00951693          	slli	a3,a0,0x9
    80001ca6:	00230797          	auipc	a5,0x230
    80001caa:	39278793          	addi	a5,a5,914 # 80232038 <mlfq>
    80001cae:	97b6                	add	a5,a5,a3
    80001cb0:	6388                	ld	a0,0(a5)
  for (int i = 1; i < queues_sizes[priority]; i++)
    80001cb2:	4785                	li	a5,1
    80001cb4:	02b7da63          	bge	a5,a1,80001ce8 <dequeue+0x68>
    80001cb8:	87b6                	mv	a5,a3
    80001cba:	00230697          	auipc	a3,0x230
    80001cbe:	37e68693          	addi	a3,a3,894 # 80232038 <mlfq>
    80001cc2:	97b6                	add	a5,a5,a3
    80001cc4:	00671613          	slli	a2,a4,0x6
    80001cc8:	ffe5869b          	addiw	a3,a1,-2
    80001ccc:	1682                	slli	a3,a3,0x20
    80001cce:	9281                	srli	a3,a3,0x20
    80001cd0:	9636                	add	a2,a2,a3
    80001cd2:	060e                	slli	a2,a2,0x3
    80001cd4:	00230697          	auipc	a3,0x230
    80001cd8:	36c68693          	addi	a3,a3,876 # 80232040 <mlfq+0x8>
    80001cdc:	9636                	add	a2,a2,a3
  {
    mlfq[priority][i - 1] = mlfq[priority][i];
    80001cde:	6794                	ld	a3,8(a5)
    80001ce0:	e394                	sd	a3,0(a5)
  for (int i = 1; i < queues_sizes[priority]; i++)
    80001ce2:	07a1                	addi	a5,a5,8
    80001ce4:	fec79de3          	bne	a5,a2,80001cde <dequeue+0x5e>
  }
  queues_sizes[priority]--;
    80001ce8:	35fd                	addiw	a1,a1,-1
    80001cea:	00271693          	slli	a3,a4,0x2
    80001cee:	00230797          	auipc	a5,0x230
    80001cf2:	f0a78793          	addi	a5,a5,-246 # 80231bf8 <queues_sizes>
    80001cf6:	97b6                	add	a5,a5,a3
    80001cf8:	c38c                	sw	a1,0(a5)
  mlfq[priority][queues_sizes[priority]] = 0;
    80001cfa:	071a                	slli	a4,a4,0x6
    80001cfc:	972e                	add	a4,a4,a1
    80001cfe:	070e                	slli	a4,a4,0x3
    80001d00:	00230797          	auipc	a5,0x230
    80001d04:	33878793          	addi	a5,a5,824 # 80232038 <mlfq>
    80001d08:	97ba                	add	a5,a5,a4
    80001d0a:	0007b023          	sd	zero,0(a5)
  return p;
}
    80001d0e:	60a2                	ld	ra,8(sp)
    80001d10:	6402                	ld	s0,0(sp)
    80001d12:	0141                	addi	sp,sp,16
    80001d14:	8082                	ret
    return 0;
    80001d16:	4501                	li	a0,0
    80001d18:	bfdd                	j	80001d0e <dequeue+0x8e>
    80001d1a:	4501                	li	a0,0
    80001d1c:	bfcd                	j	80001d0e <dequeue+0x8e>

0000000080001d1e <initialize>:

void initialize()
{
    80001d1e:	1141                	addi	sp,sp,-16
    80001d20:	e406                	sd	ra,8(sp)
    80001d22:	e022                	sd	s0,0(sp)
    80001d24:	0800                	addi	s0,sp,16
  for (int i = 0; i < 4; i++)
    80001d26:	00230617          	auipc	a2,0x230
    80001d2a:	ed260613          	addi	a2,a2,-302 # 80231bf8 <queues_sizes>
    80001d2e:	00230517          	auipc	a0,0x230
    80001d32:	30a50513          	addi	a0,a0,778 # 80232038 <mlfq>
  {
    for (int j = 0; j < queues_sizes[i]; j++)
    80001d36:	85aa                	mv	a1,a0
    80001d38:	4681                	li	a3,0
  for (int i = 0; i < 4; i++)
    80001d3a:	10000813          	li	a6,256
    for (int j = 0; j < queues_sizes[i]; j++)
    80001d3e:	4218                	lw	a4,0(a2)
    80001d40:	00e05b63          	blez	a4,80001d56 <initialize+0x38>
    80001d44:	9736                	add	a4,a4,a3
    80001d46:	070e                	slli	a4,a4,0x3
    80001d48:	972a                	add	a4,a4,a0
    80001d4a:	87ae                	mv	a5,a1
    {
      mlfq[i][j] = 0;
    80001d4c:	0007b023          	sd	zero,0(a5)
    for (int j = 0; j < queues_sizes[i]; j++)
    80001d50:	07a1                	addi	a5,a5,8
    80001d52:	fee79de3          	bne	a5,a4,80001d4c <initialize+0x2e>
  for (int i = 0; i < 4; i++)
    80001d56:	0611                	addi	a2,a2,4
    80001d58:	20058593          	addi	a1,a1,512
    80001d5c:	04068693          	addi	a3,a3,64
    80001d60:	fd069fe3          	bne	a3,a6,80001d3e <initialize+0x20>
    }
  }
  // memset(mlfq, 0, sizeof(mlfq));
  for (int i = 0; i < 4; i++)
    queues_sizes[i] = 0;
    80001d64:	00230797          	auipc	a5,0x230
    80001d68:	e9478793          	addi	a5,a5,-364 # 80231bf8 <queues_sizes>
    80001d6c:	0007a023          	sw	zero,0(a5)
    80001d70:	0007a223          	sw	zero,4(a5)
    80001d74:	0007a423          	sw	zero,8(a5)
    80001d78:	0007a623          	sw	zero,12(a5)
}
    80001d7c:	60a2                	ld	ra,8(sp)
    80001d7e:	6402                	ld	s0,0(sp)
    80001d80:	0141                	addi	sp,sp,16
    80001d82:	8082                	ret

0000000080001d84 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001d84:	7139                	addi	sp,sp,-64
    80001d86:	fc06                	sd	ra,56(sp)
    80001d88:	f822                	sd	s0,48(sp)
    80001d8a:	f426                	sd	s1,40(sp)
    80001d8c:	f04a                	sd	s2,32(sp)
    80001d8e:	ec4e                	sd	s3,24(sp)
    80001d90:	e852                	sd	s4,16(sp)
    80001d92:	e456                	sd	s5,8(sp)
    80001d94:	e05a                	sd	s6,0(sp)
    80001d96:	0080                	addi	s0,sp,64
  struct proc *p;
  boost_ticks = 0;
    80001d98:	00008797          	auipc	a5,0x8
    80001d9c:	bc07ac23          	sw	zero,-1064(a5) # 80009970 <boost_ticks>
  // boost_ticks=ticks;
  initlock(&pid_lock, "nextpid");
    80001da0:	00007597          	auipc	a1,0x7
    80001da4:	4a058593          	addi	a1,a1,1184 # 80009240 <etext+0x240>
    80001da8:	00230517          	auipc	a0,0x230
    80001dac:	e6050513          	addi	a0,a0,-416 # 80231c08 <pid_lock>
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	f6c080e7          	jalr	-148(ra) # 80000d1c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001db8:	00007597          	auipc	a1,0x7
    80001dbc:	49058593          	addi	a1,a1,1168 # 80009248 <etext+0x248>
    80001dc0:	00230517          	auipc	a0,0x230
    80001dc4:	e6050513          	addi	a0,a0,-416 # 80231c20 <wait_lock>
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	f54080e7          	jalr	-172(ra) # 80000d1c <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001dd0:	00231497          	auipc	s1,0x231
    80001dd4:	a6848493          	addi	s1,s1,-1432 # 80232838 <proc>
  {
    initlock(&p->lock, "proc");
    80001dd8:	00007b17          	auipc	s6,0x7
    80001ddc:	480b0b13          	addi	s6,s6,1152 # 80009258 <etext+0x258>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001de0:	8aa6                	mv	s5,s1
    80001de2:	8c1357b7          	lui	a5,0x8c135
    80001de6:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0beea205>
    80001dea:	21cfb937          	lui	s2,0x21cfb
    80001dee:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001df2:	1902                	slli	s2,s2,0x20
    80001df4:	993e                	add	s2,s2,a5
    80001df6:	040009b7          	lui	s3,0x4000
    80001dfa:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001dfc:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001dfe:	0023ea17          	auipc	s4,0x23e
    80001e02:	e3aa0a13          	addi	s4,s4,-454 # 8023fc38 <tickslock>
    initlock(&p->lock, "proc");
    80001e06:	85da                	mv	a1,s6
    80001e08:	8526                	mv	a0,s1
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	f12080e7          	jalr	-238(ra) # 80000d1c <initlock>
    p->state = UNUSED;
    80001e12:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001e16:	415487b3          	sub	a5,s1,s5
    80001e1a:	8791                	srai	a5,a5,0x4
    80001e1c:	032787b3          	mul	a5,a5,s2
    80001e20:	2785                	addiw	a5,a5,1
    80001e22:	00d7979b          	slliw	a5,a5,0xd
    80001e26:	40f987b3          	sub	a5,s3,a5
    80001e2a:	20f4bc23          	sd	a5,536(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001e2e:	35048493          	addi	s1,s1,848
    80001e32:	fd449ae3          	bne	s1,s4,80001e06 <procinit+0x82>
  }
}
    80001e36:	70e2                	ld	ra,56(sp)
    80001e38:	7442                	ld	s0,48(sp)
    80001e3a:	74a2                	ld	s1,40(sp)
    80001e3c:	7902                	ld	s2,32(sp)
    80001e3e:	69e2                	ld	s3,24(sp)
    80001e40:	6a42                	ld	s4,16(sp)
    80001e42:	6aa2                	ld	s5,8(sp)
    80001e44:	6b02                	ld	s6,0(sp)
    80001e46:	6121                	addi	sp,sp,64
    80001e48:	8082                	ret

0000000080001e4a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001e4a:	1141                	addi	sp,sp,-16
    80001e4c:	e406                	sd	ra,8(sp)
    80001e4e:	e022                	sd	s0,0(sp)
    80001e50:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e52:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001e54:	2501                	sext.w	a0,a0
    80001e56:	60a2                	ld	ra,8(sp)
    80001e58:	6402                	ld	s0,0(sp)
    80001e5a:	0141                	addi	sp,sp,16
    80001e5c:	8082                	ret

0000000080001e5e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001e5e:	1141                	addi	sp,sp,-16
    80001e60:	e406                	sd	ra,8(sp)
    80001e62:	e022                	sd	s0,0(sp)
    80001e64:	0800                	addi	s0,sp,16
    80001e66:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001e68:	2781                	sext.w	a5,a5
    80001e6a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001e6c:	00230517          	auipc	a0,0x230
    80001e70:	dcc50513          	addi	a0,a0,-564 # 80231c38 <cpus>
    80001e74:	953e                	add	a0,a0,a5
    80001e76:	60a2                	ld	ra,8(sp)
    80001e78:	6402                	ld	s0,0(sp)
    80001e7a:	0141                	addi	sp,sp,16
    80001e7c:	8082                	ret

0000000080001e7e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
  push_off();
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	edc080e7          	jalr	-292(ra) # 80000d64 <push_off>
    80001e90:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001e92:	2781                	sext.w	a5,a5
    80001e94:	079e                	slli	a5,a5,0x7
    80001e96:	00230717          	auipc	a4,0x230
    80001e9a:	d6270713          	addi	a4,a4,-670 # 80231bf8 <queues_sizes>
    80001e9e:	97ba                	add	a5,a5,a4
    80001ea0:	63a4                	ld	s1,64(a5)
  pop_off();
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	f62080e7          	jalr	-158(ra) # 80000e04 <pop_off>
  return p;
}
    80001eaa:	8526                	mv	a0,s1
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001eb6:	1141                	addi	sp,sp,-16
    80001eb8:	e406                	sd	ra,8(sp)
    80001eba:	e022                	sd	s0,0(sp)
    80001ebc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	fc0080e7          	jalr	-64(ra) # 80001e7e <myproc>
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	f9a080e7          	jalr	-102(ra) # 80000e60 <release>

  if (first)
    80001ece:	00008797          	auipc	a5,0x8
    80001ed2:	a127a783          	lw	a5,-1518(a5) # 800098e0 <first.1>
    80001ed6:	eb89                	bnez	a5,80001ee8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ed8:	00001097          	auipc	ra,0x1
    80001edc:	316080e7          	jalr	790(ra) # 800031ee <usertrapret>
}
    80001ee0:	60a2                	ld	ra,8(sp)
    80001ee2:	6402                	ld	s0,0(sp)
    80001ee4:	0141                	addi	sp,sp,16
    80001ee6:	8082                	ret
    first = 0;
    80001ee8:	00008797          	auipc	a5,0x8
    80001eec:	9e07ac23          	sw	zero,-1544(a5) # 800098e0 <first.1>
    fsinit(ROOTDEV);
    80001ef0:	4505                	li	a0,1
    80001ef2:	00002097          	auipc	ra,0x2
    80001ef6:	296080e7          	jalr	662(ra) # 80004188 <fsinit>
    80001efa:	bff9                	j	80001ed8 <forkret+0x22>

0000000080001efc <allocpid>:
{
    80001efc:	1101                	addi	sp,sp,-32
    80001efe:	ec06                	sd	ra,24(sp)
    80001f00:	e822                	sd	s0,16(sp)
    80001f02:	e426                	sd	s1,8(sp)
    80001f04:	e04a                	sd	s2,0(sp)
    80001f06:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001f08:	00230917          	auipc	s2,0x230
    80001f0c:	d0090913          	addi	s2,s2,-768 # 80231c08 <pid_lock>
    80001f10:	854a                	mv	a0,s2
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	e9e080e7          	jalr	-354(ra) # 80000db0 <acquire>
  pid = nextpid;
    80001f1a:	00008797          	auipc	a5,0x8
    80001f1e:	9d678793          	addi	a5,a5,-1578 # 800098f0 <nextpid>
    80001f22:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001f24:	0014871b          	addiw	a4,s1,1
    80001f28:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	f34080e7          	jalr	-204(ra) # 80000e60 <release>
}
    80001f34:	8526                	mv	a0,s1
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	64a2                	ld	s1,8(sp)
    80001f3c:	6902                	ld	s2,0(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret

0000000080001f42 <proc_pagetable>:
{
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	e04a                	sd	s2,0(sp)
    80001f4c:	1000                	addi	s0,sp,32
    80001f4e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f50:	fffff097          	auipc	ra,0xfffff
    80001f54:	5d6080e7          	jalr	1494(ra) # 80001526 <uvmcreate>
    80001f58:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001f5a:	c121                	beqz	a0,80001f9a <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f5c:	4729                	li	a4,10
    80001f5e:	00006697          	auipc	a3,0x6
    80001f62:	0a268693          	addi	a3,a3,162 # 80008000 <_trampoline>
    80001f66:	6605                	lui	a2,0x1
    80001f68:	040005b7          	lui	a1,0x4000
    80001f6c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f6e:	05b2                	slli	a1,a1,0xc
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	31c080e7          	jalr	796(ra) # 8000128c <mappages>
    80001f78:	02054863          	bltz	a0,80001fa8 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f7c:	4719                	li	a4,6
    80001f7e:	23093683          	ld	a3,560(s2)
    80001f82:	6605                	lui	a2,0x1
    80001f84:	020005b7          	lui	a1,0x2000
    80001f88:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001f8a:	05b6                	slli	a1,a1,0xd
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	2fe080e7          	jalr	766(ra) # 8000128c <mappages>
    80001f96:	02054163          	bltz	a0,80001fb8 <proc_pagetable+0x76>
}
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6902                	ld	s2,0(sp)
    80001fa4:	6105                	addi	sp,sp,32
    80001fa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001fa8:	4581                	li	a1,0
    80001faa:	8526                	mv	a0,s1
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	794080e7          	jalr	1940(ra) # 80001740 <uvmfree>
    return 0;
    80001fb4:	4481                	li	s1,0
    80001fb6:	b7d5                	j	80001f9a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fb8:	4681                	li	a3,0
    80001fba:	4605                	li	a2,1
    80001fbc:	040005b7          	lui	a1,0x4000
    80001fc0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001fc2:	05b2                	slli	a1,a1,0xc
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	48c080e7          	jalr	1164(ra) # 80001452 <uvmunmap>
    uvmfree(pagetable, 0);
    80001fce:	4581                	li	a1,0
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	76e080e7          	jalr	1902(ra) # 80001740 <uvmfree>
    return 0;
    80001fda:	4481                	li	s1,0
    80001fdc:	bf7d                	j	80001f9a <proc_pagetable+0x58>

0000000080001fde <proc_freepagetable>:
{
    80001fde:	1101                	addi	sp,sp,-32
    80001fe0:	ec06                	sd	ra,24(sp)
    80001fe2:	e822                	sd	s0,16(sp)
    80001fe4:	e426                	sd	s1,8(sp)
    80001fe6:	e04a                	sd	s2,0(sp)
    80001fe8:	1000                	addi	s0,sp,32
    80001fea:	84aa                	mv	s1,a0
    80001fec:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fee:	4681                	li	a3,0
    80001ff0:	4605                	li	a2,1
    80001ff2:	040005b7          	lui	a1,0x4000
    80001ff6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ff8:	05b2                	slli	a1,a1,0xc
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	458080e7          	jalr	1112(ra) # 80001452 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002002:	4681                	li	a3,0
    80002004:	4605                	li	a2,1
    80002006:	020005b7          	lui	a1,0x2000
    8000200a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000200c:	05b6                	slli	a1,a1,0xd
    8000200e:	8526                	mv	a0,s1
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	442080e7          	jalr	1090(ra) # 80001452 <uvmunmap>
  uvmfree(pagetable, sz);
    80002018:	85ca                	mv	a1,s2
    8000201a:	8526                	mv	a0,s1
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	724080e7          	jalr	1828(ra) # 80001740 <uvmfree>
}
    80002024:	60e2                	ld	ra,24(sp)
    80002026:	6442                	ld	s0,16(sp)
    80002028:	64a2                	ld	s1,8(sp)
    8000202a:	6902                	ld	s2,0(sp)
    8000202c:	6105                	addi	sp,sp,32
    8000202e:	8082                	ret

0000000080002030 <freeproc>:
{
    80002030:	1101                	addi	sp,sp,-32
    80002032:	ec06                	sd	ra,24(sp)
    80002034:	e822                	sd	s0,16(sp)
    80002036:	e426                	sd	s1,8(sp)
    80002038:	1000                	addi	s0,sp,32
    8000203a:	84aa                	mv	s1,a0
  if (p->trapframe)
    8000203c:	23053503          	ld	a0,560(a0)
    80002040:	c509                	beqz	a0,8000204a <freeproc+0x1a>
    kfree((void *)p->trapframe);
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	b00080e7          	jalr	-1280(ra) # 80000b42 <kfree>
  p->trapframe = 0;
    8000204a:	2204b823          	sd	zero,560(s1)
  if (p->pagetable)
    8000204e:	2284b503          	ld	a0,552(s1)
    80002052:	c519                	beqz	a0,80002060 <freeproc+0x30>
    proc_freepagetable(p->pagetable, p->sz);
    80002054:	2204b583          	ld	a1,544(s1)
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	f86080e7          	jalr	-122(ra) # 80001fde <proc_freepagetable>
  p->pagetable = 0;
    80002060:	2204b423          	sd	zero,552(s1)
  p->sz = 0;
    80002064:	2204b023          	sd	zero,544(s1)
  p->pid = 0;
    80002068:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000206c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002070:	32048823          	sb	zero,816(s1)
  p->chan = 0;
    80002074:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002078:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000207c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002080:	0004ac23          	sw	zero,24(s1)
  for (int x = 0; x <= 26; x++)
    80002084:	04048793          	addi	a5,s1,64
    80002088:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    8000208c:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    80002090:	0791                	addi	a5,a5,4
    80002092:	fee79de3          	bne	a5,a4,8000208c <freeproc+0x5c>
}
    80002096:	60e2                	ld	ra,24(sp)
    80002098:	6442                	ld	s0,16(sp)
    8000209a:	64a2                	ld	s1,8(sp)
    8000209c:	6105                	addi	sp,sp,32
    8000209e:	8082                	ret

00000000800020a0 <allocproc>:
{
    800020a0:	1101                	addi	sp,sp,-32
    800020a2:	ec06                	sd	ra,24(sp)
    800020a4:	e822                	sd	s0,16(sp)
    800020a6:	e426                	sd	s1,8(sp)
    800020a8:	e04a                	sd	s2,0(sp)
    800020aa:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    800020ac:	00230497          	auipc	s1,0x230
    800020b0:	78c48493          	addi	s1,s1,1932 # 80232838 <proc>
    800020b4:	0023e917          	auipc	s2,0x23e
    800020b8:	b8490913          	addi	s2,s2,-1148 # 8023fc38 <tickslock>
    acquire(&p->lock);
    800020bc:	8526                	mv	a0,s1
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	cf2080e7          	jalr	-782(ra) # 80000db0 <acquire>
    if (p->state == UNUSED)
    800020c6:	4c9c                	lw	a5,24(s1)
    800020c8:	cf81                	beqz	a5,800020e0 <allocproc+0x40>
      release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	d94080e7          	jalr	-620(ra) # 80000e60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800020d4:	35048493          	addi	s1,s1,848
    800020d8:	ff2492e3          	bne	s1,s2,800020bc <allocproc+0x1c>
  return 0;
    800020dc:	4481                	li	s1,0
    800020de:	a859                	j	80002174 <allocproc+0xd4>
  p->pid = allocpid();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	e1c080e7          	jalr	-484(ra) # 80001efc <allocpid>
    800020e8:	d888                	sw	a0,48(s1)
  p->state = USED;
    800020ea:	4785                	li	a5,1
    800020ec:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	bc4080e7          	jalr	-1084(ra) # 80000cb2 <kalloc>
    800020f6:	892a                	mv	s2,a0
    800020f8:	22a4b823          	sd	a0,560(s1)
    800020fc:	c159                	beqz	a0,80002182 <allocproc+0xe2>
  p->pagetable = proc_pagetable(p);
    800020fe:	8526                	mv	a0,s1
    80002100:	00000097          	auipc	ra,0x0
    80002104:	e42080e7          	jalr	-446(ra) # 80001f42 <proc_pagetable>
    80002108:	892a                	mv	s2,a0
    8000210a:	22a4b423          	sd	a0,552(s1)
  if (p->pagetable == 0)
    8000210e:	c551                	beqz	a0,8000219a <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80002110:	07000613          	li	a2,112
    80002114:	4581                	li	a1,0
    80002116:	23848513          	addi	a0,s1,568
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	d8e080e7          	jalr	-626(ra) # 80000ea8 <memset>
  p->context.ra = (uint64)forkret;
    80002122:	00000797          	auipc	a5,0x0
    80002126:	d9478793          	addi	a5,a5,-620 # 80001eb6 <forkret>
    8000212a:	22f4bc23          	sd	a5,568(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000212e:	2184b783          	ld	a5,536(s1)
    80002132:	6705                	lui	a4,0x1
    80002134:	97ba                	add	a5,a5,a4
    80002136:	24f4b023          	sd	a5,576(s1)
  p->rtime = 0;
    8000213a:	3404a023          	sw	zero,832(s1)
  p->etime = 0;
    8000213e:	3404a423          	sw	zero,840(s1)
  p->ctime = ticks;
    80002142:	00008797          	auipc	a5,0x8
    80002146:	8327a783          	lw	a5,-1998(a5) # 80009974 <ticks>
    8000214a:	34f4a223          	sw	a5,836(s1)
  p->tickets = 1;
    8000214e:	4705                	li	a4,1
    80002150:	0ce4a023          	sw	a4,192(s1)
  p->ticks = 0;
    80002154:	0e04a023          	sw	zero,224(s1)
  p->arrival_time = ticks; // to add new process in the end;
    80002158:	1782                	slli	a5,a5,0x20
    8000215a:	9381                	srli	a5,a5,0x20
    8000215c:	e4fc                	sd	a5,200(s1)
  p->priority = 0;
    8000215e:	0c04ac23          	sw	zero,216(s1)
  for (int x = 0; x <= 26; x++)
    80002162:	04048793          	addi	a5,s1,64
    80002166:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    8000216a:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    8000216e:	0791                	addi	a5,a5,4
    80002170:	fee79de3          	bne	a5,a4,8000216a <allocproc+0xca>
}
    80002174:	8526                	mv	a0,s1
    80002176:	60e2                	ld	ra,24(sp)
    80002178:	6442                	ld	s0,16(sp)
    8000217a:	64a2                	ld	s1,8(sp)
    8000217c:	6902                	ld	s2,0(sp)
    8000217e:	6105                	addi	sp,sp,32
    80002180:	8082                	ret
    freeproc(p);
    80002182:	8526                	mv	a0,s1
    80002184:	00000097          	auipc	ra,0x0
    80002188:	eac080e7          	jalr	-340(ra) # 80002030 <freeproc>
    release(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	cd2080e7          	jalr	-814(ra) # 80000e60 <release>
    return 0;
    80002196:	84ca                	mv	s1,s2
    80002198:	bff1                	j	80002174 <allocproc+0xd4>
    freeproc(p);
    8000219a:	8526                	mv	a0,s1
    8000219c:	00000097          	auipc	ra,0x0
    800021a0:	e94080e7          	jalr	-364(ra) # 80002030 <freeproc>
    release(&p->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	cba080e7          	jalr	-838(ra) # 80000e60 <release>
    return 0;
    800021ae:	84ca                	mv	s1,s2
    800021b0:	b7d1                	j	80002174 <allocproc+0xd4>

00000000800021b2 <userinit>:
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	1000                	addi	s0,sp,32
  p = allocproc();
    800021bc:	00000097          	auipc	ra,0x0
    800021c0:	ee4080e7          	jalr	-284(ra) # 800020a0 <allocproc>
    800021c4:	84aa                	mv	s1,a0
  initproc = p;
    800021c6:	00007797          	auipc	a5,0x7
    800021ca:	7aa7b123          	sd	a0,1954(a5) # 80009968 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800021ce:	03400613          	li	a2,52
    800021d2:	00007597          	auipc	a1,0x7
    800021d6:	72e58593          	addi	a1,a1,1838 # 80009900 <initcode>
    800021da:	22853503          	ld	a0,552(a0)
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	376080e7          	jalr	886(ra) # 80001554 <uvmfirst>
  p->sz = PGSIZE;
    800021e6:	6785                	lui	a5,0x1
    800021e8:	22f4b023          	sd	a5,544(s1)
  p->trapframe->epc = 0;     // user program counter
    800021ec:	2304b703          	ld	a4,560(s1)
    800021f0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    800021f4:	2304b703          	ld	a4,560(s1)
    800021f8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800021fa:	4641                	li	a2,16
    800021fc:	00007597          	auipc	a1,0x7
    80002200:	06458593          	addi	a1,a1,100 # 80009260 <etext+0x260>
    80002204:	33048513          	addi	a0,s1,816
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	df6080e7          	jalr	-522(ra) # 80000ffe <safestrcpy>
  p->cwd = namei("/");
    80002210:	00007517          	auipc	a0,0x7
    80002214:	06050513          	addi	a0,a0,96 # 80009270 <etext+0x270>
    80002218:	00003097          	auipc	ra,0x3
    8000221c:	9d8080e7          	jalr	-1576(ra) # 80004bf0 <namei>
    80002220:	32a4b423          	sd	a0,808(s1)
  p->state = RUNNABLE;
    80002224:	478d                	li	a5,3
    80002226:	cc9c                	sw	a5,24(s1)
  Enqueue(p, p->priority);
    80002228:	0d84a583          	lw	a1,216(s1)
    8000222c:	8526                	mv	a0,s1
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	9f2080e7          	jalr	-1550(ra) # 80001c20 <Enqueue>
  release(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	c28080e7          	jalr	-984(ra) # 80000e60 <release>
}
    80002240:	60e2                	ld	ra,24(sp)
    80002242:	6442                	ld	s0,16(sp)
    80002244:	64a2                	ld	s1,8(sp)
    80002246:	6105                	addi	sp,sp,32
    80002248:	8082                	ret

000000008000224a <growproc>:
{
    8000224a:	1101                	addi	sp,sp,-32
    8000224c:	ec06                	sd	ra,24(sp)
    8000224e:	e822                	sd	s0,16(sp)
    80002250:	e426                	sd	s1,8(sp)
    80002252:	e04a                	sd	s2,0(sp)
    80002254:	1000                	addi	s0,sp,32
    80002256:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	c26080e7          	jalr	-986(ra) # 80001e7e <myproc>
    80002260:	84aa                	mv	s1,a0
  sz = p->sz;
    80002262:	22053583          	ld	a1,544(a0)
  if (n > 0)
    80002266:	01204d63          	bgtz	s2,80002280 <growproc+0x36>
  else if (n < 0)
    8000226a:	02094863          	bltz	s2,8000229a <growproc+0x50>
  p->sz = sz;
    8000226e:	22b4b023          	sd	a1,544(s1)
  return 0;
    80002272:	4501                	li	a0,0
}
    80002274:	60e2                	ld	ra,24(sp)
    80002276:	6442                	ld	s0,16(sp)
    80002278:	64a2                	ld	s1,8(sp)
    8000227a:	6902                	ld	s2,0(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002280:	4691                	li	a3,4
    80002282:	00b90633          	add	a2,s2,a1
    80002286:	22853503          	ld	a0,552(a0)
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	384080e7          	jalr	900(ra) # 8000160e <uvmalloc>
    80002292:	85aa                	mv	a1,a0
    80002294:	fd69                	bnez	a0,8000226e <growproc+0x24>
      return -1;
    80002296:	557d                	li	a0,-1
    80002298:	bff1                	j	80002274 <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000229a:	00b90633          	add	a2,s2,a1
    8000229e:	22853503          	ld	a0,552(a0)
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	324080e7          	jalr	804(ra) # 800015c6 <uvmdealloc>
    800022aa:	85aa                	mv	a1,a0
    800022ac:	b7c9                	j	8000226e <growproc+0x24>

00000000800022ae <fork>:
{
    800022ae:	7139                	addi	sp,sp,-64
    800022b0:	fc06                	sd	ra,56(sp)
    800022b2:	f822                	sd	s0,48(sp)
    800022b4:	f04a                	sd	s2,32(sp)
    800022b6:	e456                	sd	s5,8(sp)
    800022b8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800022ba:	00000097          	auipc	ra,0x0
    800022be:	bc4080e7          	jalr	-1084(ra) # 80001e7e <myproc>
    800022c2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	ddc080e7          	jalr	-548(ra) # 800020a0 <allocproc>
    800022cc:	12050c63          	beqz	a0,80002404 <fork+0x156>
    800022d0:	ec4e                	sd	s3,24(sp)
    800022d2:	89aa                	mv	s3,a0
  if (uvmcowcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800022d4:	220ab603          	ld	a2,544(s5)
    800022d8:	22853583          	ld	a1,552(a0)
    800022dc:	228ab503          	ld	a0,552(s5)
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	570080e7          	jalr	1392(ra) # 80001850 <uvmcowcopy>
    800022e8:	04054a63          	bltz	a0,8000233c <fork+0x8e>
    800022ec:	f426                	sd	s1,40(sp)
    800022ee:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800022f0:	220ab783          	ld	a5,544(s5)
    800022f4:	22f9b023          	sd	a5,544(s3)
  *(np->trapframe) = *(p->trapframe);
    800022f8:	230ab683          	ld	a3,560(s5)
    800022fc:	87b6                	mv	a5,a3
    800022fe:	2309b703          	ld	a4,560(s3)
    80002302:	12068693          	addi	a3,a3,288
    80002306:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000230a:	6788                	ld	a0,8(a5)
    8000230c:	6b8c                	ld	a1,16(a5)
    8000230e:	6f90                	ld	a2,24(a5)
    80002310:	01073023          	sd	a6,0(a4)
    80002314:	e708                	sd	a0,8(a4)
    80002316:	eb0c                	sd	a1,16(a4)
    80002318:	ef10                	sd	a2,24(a4)
    8000231a:	02078793          	addi	a5,a5,32
    8000231e:	02070713          	addi	a4,a4,32
    80002322:	fed792e3          	bne	a5,a3,80002306 <fork+0x58>
  np->trapframe->a0 = 0;
    80002326:	2309b783          	ld	a5,560(s3)
    8000232a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    8000232e:	2a8a8493          	addi	s1,s5,680
    80002332:	2a898913          	addi	s2,s3,680
    80002336:	328a8a13          	addi	s4,s5,808
    8000233a:	a015                	j	8000235e <fork+0xb0>
    freeproc(np);
    8000233c:	854e                	mv	a0,s3
    8000233e:	00000097          	auipc	ra,0x0
    80002342:	cf2080e7          	jalr	-782(ra) # 80002030 <freeproc>
    release(&np->lock);
    80002346:	854e                	mv	a0,s3
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	b18080e7          	jalr	-1256(ra) # 80000e60 <release>
    return -1;
    80002350:	597d                	li	s2,-1
    80002352:	69e2                	ld	s3,24(sp)
    80002354:	a04d                	j	800023f6 <fork+0x148>
  for (i = 0; i < NOFILE; i++)
    80002356:	04a1                	addi	s1,s1,8
    80002358:	0921                	addi	s2,s2,8
    8000235a:	01448b63          	beq	s1,s4,80002370 <fork+0xc2>
    if (p->ofile[i])
    8000235e:	6088                	ld	a0,0(s1)
    80002360:	d97d                	beqz	a0,80002356 <fork+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002362:	00003097          	auipc	ra,0x3
    80002366:	f12080e7          	jalr	-238(ra) # 80005274 <filedup>
    8000236a:	00a93023          	sd	a0,0(s2)
    8000236e:	b7e5                	j	80002356 <fork+0xa8>
  np->cwd = idup(p->cwd);
    80002370:	328ab503          	ld	a0,808(s5)
    80002374:	00002097          	auipc	ra,0x2
    80002378:	05a080e7          	jalr	90(ra) # 800043ce <idup>
    8000237c:	32a9b423          	sd	a0,808(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002380:	4641                	li	a2,16
    80002382:	330a8593          	addi	a1,s5,816
    80002386:	33098513          	addi	a0,s3,816
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	c74080e7          	jalr	-908(ra) # 80000ffe <safestrcpy>
  np->tickets = p->tickets;
    80002392:	0c0aa783          	lw	a5,192(s5)
    80002396:	0cf9a023          	sw	a5,192(s3)
  pid = np->pid;
    8000239a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000239e:	854e                	mv	a0,s3
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	ac0080e7          	jalr	-1344(ra) # 80000e60 <release>
  acquire(&wait_lock);
    800023a8:	00230497          	auipc	s1,0x230
    800023ac:	87848493          	addi	s1,s1,-1928 # 80231c20 <wait_lock>
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	9fe080e7          	jalr	-1538(ra) # 80000db0 <acquire>
  np->parent = p;
    800023ba:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	aa0080e7          	jalr	-1376(ra) # 80000e60 <release>
  acquire(&np->lock);
    800023c8:	854e                	mv	a0,s3
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	9e6080e7          	jalr	-1562(ra) # 80000db0 <acquire>
  np->state = RUNNABLE;
    800023d2:	478d                	li	a5,3
    800023d4:	00f9ac23          	sw	a5,24(s3)
  Enqueue(p, p->priority);
    800023d8:	0d8aa583          	lw	a1,216(s5)
    800023dc:	8556                	mv	a0,s5
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	842080e7          	jalr	-1982(ra) # 80001c20 <Enqueue>
  release(&np->lock);
    800023e6:	854e                	mv	a0,s3
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	a78080e7          	jalr	-1416(ra) # 80000e60 <release>
  return pid;
    800023f0:	74a2                	ld	s1,40(sp)
    800023f2:	69e2                	ld	s3,24(sp)
    800023f4:	6a42                	ld	s4,16(sp)
}
    800023f6:	854a                	mv	a0,s2
    800023f8:	70e2                	ld	ra,56(sp)
    800023fa:	7442                	ld	s0,48(sp)
    800023fc:	7902                	ld	s2,32(sp)
    800023fe:	6aa2                	ld	s5,8(sp)
    80002400:	6121                	addi	sp,sp,64
    80002402:	8082                	ret
    return -1;
    80002404:	597d                	li	s2,-1
    80002406:	bfc5                	j	800023f6 <fork+0x148>

0000000080002408 <get_time_slice>:
{
    80002408:	1141                	addi	sp,sp,-16
    8000240a:	e406                	sd	ra,8(sp)
    8000240c:	e022                	sd	s0,0(sp)
    8000240e:	0800                	addi	s0,sp,16
  switch (priority)
    80002410:	4709                	li	a4,2
    80002412:	00e50d63          	beq	a0,a4,8000242c <get_time_slice+0x24>
    80002416:	87aa                	mv	a5,a0
    80002418:	470d                	li	a4,3
    return 16;
    8000241a:	4541                	li	a0,16
  switch (priority)
    8000241c:	00e78963          	beq	a5,a4,8000242e <get_time_slice+0x26>
    80002420:	4705                	li	a4,1
    80002422:	4511                	li	a0,4
    80002424:	00e78563          	beq	a5,a4,8000242e <get_time_slice+0x26>
    return 1;
    80002428:	853a                	mv	a0,a4
    8000242a:	a011                	j	8000242e <get_time_slice+0x26>
    return 8;
    8000242c:	4521                	li	a0,8
}
    8000242e:	60a2                	ld	ra,8(sp)
    80002430:	6402                	ld	s0,0(sp)
    80002432:	0141                	addi	sp,sp,16
    80002434:	8082                	ret

0000000080002436 <priority_boost>:
{
    80002436:	7179                	addi	sp,sp,-48
    80002438:	f406                	sd	ra,40(sp)
    8000243a:	f022                	sd	s0,32(sp)
    8000243c:	ec26                	sd	s1,24(sp)
    8000243e:	e84a                	sd	s2,16(sp)
    80002440:	e44e                	sd	s3,8(sp)
    80002442:	1800                	addi	s0,sp,48
  initialize();
    80002444:	00000097          	auipc	ra,0x0
    80002448:	8da080e7          	jalr	-1830(ra) # 80001d1e <initialize>
  for (p = proc; p < &proc[NPROC]; p++)
    8000244c:	00230497          	auipc	s1,0x230
    80002450:	3ec48493          	addi	s1,s1,1004 # 80232838 <proc>
    if (p->state == RUNNABLE)
    80002454:	498d                	li	s3,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002456:	0023d917          	auipc	s2,0x23d
    8000245a:	7e290913          	addi	s2,s2,2018 # 8023fc38 <tickslock>
    8000245e:	a811                	j	80002472 <priority_boost+0x3c>
    release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	9fe080e7          	jalr	-1538(ra) # 80000e60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000246a:	35048493          	addi	s1,s1,848
    8000246e:	03248563          	beq	s1,s2,80002498 <priority_boost+0x62>
    acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	93c080e7          	jalr	-1732(ra) # 80000db0 <acquire>
    if (p->state == RUNNABLE)
    8000247c:	4c9c                	lw	a5,24(s1)
    8000247e:	ff3791e3          	bne	a5,s3,80002460 <priority_boost+0x2a>
      p->priority = 0;
    80002482:	0c04ac23          	sw	zero,216(s1)
      p->ticks=0;
    80002486:	0e04a023          	sw	zero,224(s1)
      Enqueue(p, 0);
    8000248a:	4581                	li	a1,0
    8000248c:	8526                	mv	a0,s1
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	792080e7          	jalr	1938(ra) # 80001c20 <Enqueue>
    80002496:	b7e9                	j	80002460 <priority_boost+0x2a>
  boost_ticks = 0;
    80002498:	00007797          	auipc	a5,0x7
    8000249c:	4c07ac23          	sw	zero,1240(a5) # 80009970 <boost_ticks>
}
    800024a0:	70a2                	ld	ra,40(sp)
    800024a2:	7402                	ld	s0,32(sp)
    800024a4:	64e2                	ld	s1,24(sp)
    800024a6:	6942                	ld	s2,16(sp)
    800024a8:	69a2                	ld	s3,8(sp)
    800024aa:	6145                	addi	sp,sp,48
    800024ac:	8082                	ret

00000000800024ae <scheduler_mlfq>:
{
    800024ae:	715d                	addi	sp,sp,-80
    800024b0:	e486                	sd	ra,72(sp)
    800024b2:	e0a2                	sd	s0,64(sp)
    800024b4:	fc26                	sd	s1,56(sp)
    800024b6:	f84a                	sd	s2,48(sp)
    800024b8:	f44e                	sd	s3,40(sp)
    800024ba:	f052                	sd	s4,32(sp)
    800024bc:	ec56                	sd	s5,24(sp)
    800024be:	e85a                	sd	s6,16(sp)
    800024c0:	e45e                	sd	s7,8(sp)
    800024c2:	e062                	sd	s8,0(sp)
    800024c4:	0880                	addi	s0,sp,80
    800024c6:	8792                	mv	a5,tp
  int id = r_tp();
    800024c8:	2781                	sext.w	a5,a5
        swtch(&c->context, &selected_proc->context);
    800024ca:	00779b13          	slli	s6,a5,0x7
    800024ce:	0022f717          	auipc	a4,0x22f
    800024d2:	77270713          	addi	a4,a4,1906 # 80231c40 <cpus+0x8>
    800024d6:	9b3a                	add	s6,s6,a4
    c->proc = 0;
    800024d8:	079e                	slli	a5,a5,0x7
    800024da:	0022fa17          	auipc	s4,0x22f
    800024de:	71ea0a13          	addi	s4,s4,1822 # 80231bf8 <queues_sizes>
    800024e2:	9a3e                	add	s4,s4,a5
    boost_ticks++;
    800024e4:	00007917          	auipc	s2,0x7
    800024e8:	48c90913          	addi	s2,s2,1164 # 80009970 <boost_ticks>
    for (int priority = 0; priority < 4; priority++)
    800024ec:	4491                	li	s1,4
        selected_proc=mlfq[priority][0];
    800024ee:	00230a97          	auipc	s5,0x230
    800024f2:	b4aa8a93          	addi	s5,s5,-1206 # 80232038 <mlfq>
    800024f6:	a8d1                	j	800025ca <scheduler_mlfq+0x11c>
    for (int priority = 0; priority < 4; priority++)
    800024f8:	0022f717          	auipc	a4,0x22f
    800024fc:	70070713          	addi	a4,a4,1792 # 80231bf8 <queues_sizes>
    80002500:	4781                	li	a5,0
      if(queues_sizes[priority]>0)
    80002502:	4314                	lw	a3,0(a4)
    80002504:	02d04a63          	bgtz	a3,80002538 <scheduler_mlfq+0x8a>
    for (int priority = 0; priority < 4; priority++)
    80002508:	2785                	addiw	a5,a5,1
    8000250a:	0711                	addi	a4,a4,4
    8000250c:	fe979be3          	bne	a5,s1,80002502 <scheduler_mlfq+0x54>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002510:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002514:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002518:	10079073          	csrw	sstatus,a5
    c->proc = 0;
    8000251c:	040a3023          	sd	zero,64(s4)
    boost_ticks++;
    80002520:	00092783          	lw	a5,0(s2)
    80002524:	2785                	addiw	a5,a5,1
    80002526:	00f92023          	sw	a5,0(s2)
    if (boost_ticks>BOOST_INTERVAL)
    8000252a:	fcf9d7e3          	bge	s3,a5,800024f8 <scheduler_mlfq+0x4a>
      priority_boost();
    8000252e:	00000097          	auipc	ra,0x0
    80002532:	f08080e7          	jalr	-248(ra) # 80002436 <priority_boost>
    80002536:	b7c9                	j	800024f8 <scheduler_mlfq+0x4a>
        selected_proc=mlfq[priority][0];
    80002538:	07a6                	slli	a5,a5,0x9
    8000253a:	97d6                	add	a5,a5,s5
    8000253c:	0007bb83          	ld	s7,0(a5)
    if (selected_proc)
    80002540:	fc0b88e3          	beqz	s7,80002510 <scheduler_mlfq+0x62>
    int time_slice = get_time_slice(selected_proc->priority);
    80002544:	0d8ba983          	lw	s3,216(s7) # fffffffffffff0d8 <end+0xffffffff7fdb40c0>
      acquire(&selected_proc->lock);
    80002548:	855e                	mv	a0,s7
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	866080e7          	jalr	-1946(ra) # 80000db0 <acquire>
      if (selected_proc->state == RUNNABLE)
    80002552:	018ba703          	lw	a4,24(s7)
    80002556:	478d                	li	a5,3
    80002558:	06f70c63          	beq	a4,a5,800025d0 <scheduler_mlfq+0x122>
      release(&selected_proc->lock);
    8000255c:	855e                	mv	a0,s7
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	902080e7          	jalr	-1790(ra) # 80000e60 <release>
      acquire(&selected_proc->lock);
    80002566:	855e                	mv	a0,s7
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	848080e7          	jalr	-1976(ra) # 80000db0 <acquire>
      selected_proc->ticks++;
    80002570:	0e0ba783          	lw	a5,224(s7)
    80002574:	2785                	addiw	a5,a5,1
    80002576:	0efba023          	sw	a5,224(s7)
      dequeue(selected_proc->priority);
    8000257a:	0d8ba503          	lw	a0,216(s7)
    8000257e:	fffff097          	auipc	ra,0xfffff
    80002582:	702080e7          	jalr	1794(ra) # 80001c80 <dequeue>
      if (selected_proc->state == RUNNABLE)
    80002586:	018ba703          	lw	a4,24(s7)
    8000258a:	478d                	li	a5,3
    8000258c:	02f71a63          	bne	a4,a5,800025c0 <scheduler_mlfq+0x112>
        if (selected_proc->ticks >= time_slice)
    80002590:	0e0bac03          	lw	s8,224(s7)
    int time_slice = get_time_slice(selected_proc->priority);
    80002594:	854e                	mv	a0,s3
    80002596:	00000097          	auipc	ra,0x0
    8000259a:	e72080e7          	jalr	-398(ra) # 80002408 <get_time_slice>
        if (selected_proc->ticks >= time_slice)
    8000259e:	04ac4f63          	blt	s8,a0,800025fc <scheduler_mlfq+0x14e>
          if (selected_proc->priority < 3)
    800025a2:	0d8ba583          	lw	a1,216(s7)
    800025a6:	4789                	li	a5,2
    800025a8:	04b7c263          	blt	a5,a1,800025ec <scheduler_mlfq+0x13e>
            selected_proc->priority++;
    800025ac:	2585                	addiw	a1,a1,1
    800025ae:	0cbbac23          	sw	a1,216(s7)
            Enqueue(selected_proc, selected_proc->priority);
    800025b2:	855e                	mv	a0,s7
    800025b4:	fffff097          	auipc	ra,0xfffff
    800025b8:	66c080e7          	jalr	1644(ra) # 80001c20 <Enqueue>
            selected_proc->ticks = 0;
    800025bc:	0e0ba023          	sw	zero,224(s7)
      release(&selected_proc->lock);
    800025c0:	855e                	mv	a0,s7
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	89e080e7          	jalr	-1890(ra) # 80000e60 <release>
    if (boost_ticks>BOOST_INTERVAL)
    800025ca:	03000993          	li	s3,48
    800025ce:	b789                	j	80002510 <scheduler_mlfq+0x62>
        selected_proc->state = RUNNING;
    800025d0:	009bac23          	sw	s1,24(s7)
        c->proc = selected_proc;
    800025d4:	057a3023          	sd	s7,64(s4)
        swtch(&c->context, &selected_proc->context);
    800025d8:	238b8593          	addi	a1,s7,568
    800025dc:	855a                	mv	a0,s6
    800025de:	00001097          	auipc	ra,0x1
    800025e2:	aac080e7          	jalr	-1364(ra) # 8000308a <swtch>
        c->proc = 0;
    800025e6:	040a3023          	sd	zero,64(s4)
    800025ea:	bf8d                	j	8000255c <scheduler_mlfq+0xae>
            selected_proc->ticks = 0;
    800025ec:	0e0ba023          	sw	zero,224(s7)
            Enqueue(selected_proc, selected_proc->priority);
    800025f0:	855e                	mv	a0,s7
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	62e080e7          	jalr	1582(ra) # 80001c20 <Enqueue>
    800025fa:	b7d9                	j	800025c0 <scheduler_mlfq+0x112>
          Enqueue(selected_proc, selected_proc->priority);
    800025fc:	0d8ba583          	lw	a1,216(s7)
    80002600:	855e                	mv	a0,s7
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	61e080e7          	jalr	1566(ra) # 80001c20 <Enqueue>
    8000260a:	bf5d                	j	800025c0 <scheduler_mlfq+0x112>

000000008000260c <scheduler_rr>:
{
    8000260c:	7139                	addi	sp,sp,-64
    8000260e:	fc06                	sd	ra,56(sp)
    80002610:	f822                	sd	s0,48(sp)
    80002612:	f426                	sd	s1,40(sp)
    80002614:	f04a                	sd	s2,32(sp)
    80002616:	ec4e                	sd	s3,24(sp)
    80002618:	e852                	sd	s4,16(sp)
    8000261a:	e456                	sd	s5,8(sp)
    8000261c:	e05a                	sd	s6,0(sp)
    8000261e:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    80002620:	8792                	mv	a5,tp
  int id = r_tp();
    80002622:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002624:	00779a93          	slli	s5,a5,0x7
    80002628:	0022f717          	auipc	a4,0x22f
    8000262c:	5d070713          	addi	a4,a4,1488 # 80231bf8 <queues_sizes>
    80002630:	9756                	add	a4,a4,s5
    80002632:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &p->context);
    80002636:	0022f717          	auipc	a4,0x22f
    8000263a:	60a70713          	addi	a4,a4,1546 # 80231c40 <cpus+0x8>
    8000263e:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80002640:	498d                	li	s3,3
        p->state = RUNNING;
    80002642:	4b11                	li	s6,4
        c->proc = p;
    80002644:	079e                	slli	a5,a5,0x7
    80002646:	0022fa17          	auipc	s4,0x22f
    8000264a:	5b2a0a13          	addi	s4,s4,1458 # 80231bf8 <queues_sizes>
    8000264e:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002650:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002654:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002658:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000265c:	00230497          	auipc	s1,0x230
    80002660:	1dc48493          	addi	s1,s1,476 # 80232838 <proc>
    80002664:	0023d917          	auipc	s2,0x23d
    80002668:	5d490913          	addi	s2,s2,1492 # 8023fc38 <tickslock>
    8000266c:	a811                	j	80002680 <scheduler_rr+0x74>
      release(&p->lock);
    8000266e:	8526                	mv	a0,s1
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	7f0080e7          	jalr	2032(ra) # 80000e60 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002678:	35048493          	addi	s1,s1,848
    8000267c:	fd248ae3          	beq	s1,s2,80002650 <scheduler_rr+0x44>
      acquire(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	72e080e7          	jalr	1838(ra) # 80000db0 <acquire>
      if (p->state == RUNNABLE)
    8000268a:	4c9c                	lw	a5,24(s1)
    8000268c:	ff3791e3          	bne	a5,s3,8000266e <scheduler_rr+0x62>
        p->state = RUNNING;
    80002690:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002694:	049a3023          	sd	s1,64(s4)
        swtch(&c->context, &p->context);
    80002698:	23848593          	addi	a1,s1,568
    8000269c:	8556                	mv	a0,s5
    8000269e:	00001097          	auipc	ra,0x1
    800026a2:	9ec080e7          	jalr	-1556(ra) # 8000308a <swtch>
        c->proc = 0;
    800026a6:	040a3023          	sd	zero,64(s4)
    800026aa:	b7d1                	j	8000266e <scheduler_rr+0x62>

00000000800026ac <scheduler_lottery>:
{
    800026ac:	715d                	addi	sp,sp,-80
    800026ae:	e486                	sd	ra,72(sp)
    800026b0:	e0a2                	sd	s0,64(sp)
    800026b2:	fc26                	sd	s1,56(sp)
    800026b4:	f84a                	sd	s2,48(sp)
    800026b6:	f44e                	sd	s3,40(sp)
    800026b8:	f052                	sd	s4,32(sp)
    800026ba:	ec56                	sd	s5,24(sp)
    800026bc:	e85a                	sd	s6,16(sp)
    800026be:	e45e                	sd	s7,8(sp)
    800026c0:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c2:	8792                	mv	a5,tp
  int id = r_tp();
    800026c4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800026c6:	00779693          	slli	a3,a5,0x7
    800026ca:	0022f717          	auipc	a4,0x22f
    800026ce:	52e70713          	addi	a4,a4,1326 # 80231bf8 <queues_sizes>
    800026d2:	9736                	add	a4,a4,a3
    800026d4:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &selected_proc->context);
    800026d8:	0022f717          	auipc	a4,0x22f
    800026dc:	56870713          	addi	a4,a4,1384 # 80231c40 <cpus+0x8>
    800026e0:	9736                	add	a4,a4,a3
    800026e2:	8bba                	mv	s7,a4
      if (p->state == RUNNABLE)
    800026e4:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    800026e6:	0023d917          	auipc	s2,0x23d
    800026ea:	55290913          	addi	s2,s2,1362 # 8023fc38 <tickslock>
        c->proc = selected_proc;
    800026ee:	0022fa97          	auipc	s5,0x22f
    800026f2:	50aa8a93          	addi	s5,s5,1290 # 80231bf8 <queues_sizes>
    800026f6:	9ab6                	add	s5,s5,a3
    800026f8:	a80d                	j	8000272a <scheduler_lottery+0x7e>
      release(&p->lock);
    800026fa:	8526                	mv	a0,s1
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	764080e7          	jalr	1892(ra) # 80000e60 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002704:	35048493          	addi	s1,s1,848
    80002708:	01248f63          	beq	s1,s2,80002726 <scheduler_lottery+0x7a>
      acquire(&p->lock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	6a2080e7          	jalr	1698(ra) # 80000db0 <acquire>
      if (p->state == RUNNABLE)
    80002716:	4c9c                	lw	a5,24(s1)
    80002718:	ff3791e3          	bne	a5,s3,800026fa <scheduler_lottery+0x4e>
        total_tickets += p->tickets;
    8000271c:	0c04a783          	lw	a5,192(s1)
    80002720:	01678b3b          	addw	s6,a5,s6
    80002724:	bfd9                	j	800026fa <scheduler_lottery+0x4e>
    if (total_tickets == 0)
    80002726:	000b1e63          	bnez	s6,80002742 <scheduler_lottery+0x96>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000272e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002732:	10079073          	csrw	sstatus,a5
    total_tickets = 0;
    80002736:	4b01                	li	s6,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002738:	00230497          	auipc	s1,0x230
    8000273c:	10048493          	addi	s1,s1,256 # 80232838 <proc>
    80002740:	b7f1                	j	8000270c <scheduler_lottery+0x60>
    int winning_ticket = rand() % total_tickets;
    80002742:	fffff097          	auipc	ra,0xfffff
    80002746:	498080e7          	jalr	1176(ra) # 80001bda <rand>
    8000274a:	03657b33          	remu	s6,a0,s6
    8000274e:	2b01                	sext.w	s6,s6
    int current_ticket = 0;
    80002750:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002752:	00230497          	auipc	s1,0x230
    80002756:	0e648493          	addi	s1,s1,230 # 80232838 <proc>
    8000275a:	a811                	j	8000276e <scheduler_lottery+0xc2>
      release(&p->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	702080e7          	jalr	1794(ra) # 80000e60 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002766:	35048493          	addi	s1,s1,848
    8000276a:	fd2480e3          	beq	s1,s2,8000272a <scheduler_lottery+0x7e>
      acquire(&p->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	640080e7          	jalr	1600(ra) # 80000db0 <acquire>
      if (p->state == RUNNABLE)
    80002778:	4c9c                	lw	a5,24(s1)
    8000277a:	ff3791e3          	bne	a5,s3,8000275c <scheduler_lottery+0xb0>
        current_ticket += p->tickets;
    8000277e:	0c04a783          	lw	a5,192(s1)
    80002782:	01478a3b          	addw	s4,a5,s4
        if (current_ticket > winning_ticket)
    80002786:	fd4b5be3          	bge	s6,s4,8000275c <scheduler_lottery+0xb0>
          release(&p->lock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	6d4080e7          	jalr	1748(ra) # 80000e60 <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002794:	00230a17          	auipc	s4,0x230
    80002798:	0a4a0a13          	addi	s4,s4,164 # 80232838 <proc>
    8000279c:	a811                	j	800027b0 <scheduler_lottery+0x104>
          release(&p->lock);
    8000279e:	8552                	mv	a0,s4
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	6c0080e7          	jalr	1728(ra) # 80000e60 <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800027a8:	350a0a13          	addi	s4,s4,848
    800027ac:	032a0a63          	beq	s4,s2,800027e0 <scheduler_lottery+0x134>
        if (p != selected_proc)
    800027b0:	fe9a0ce3          	beq	s4,s1,800027a8 <scheduler_lottery+0xfc>
          acquire(&p->lock);
    800027b4:	8552                	mv	a0,s4
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	5fa080e7          	jalr	1530(ra) # 80000db0 <acquire>
          if (p->state == RUNNABLE && p->tickets == selected_proc->tickets && p->arrival_time < selected_proc->arrival_time)
    800027be:	018a2783          	lw	a5,24(s4)
    800027c2:	fd379ee3          	bne	a5,s3,8000279e <scheduler_lottery+0xf2>
    800027c6:	0c0a2703          	lw	a4,192(s4)
    800027ca:	0c04a783          	lw	a5,192(s1)
    800027ce:	fcf718e3          	bne	a4,a5,8000279e <scheduler_lottery+0xf2>
    800027d2:	0c8a3703          	ld	a4,200(s4)
    800027d6:	64fc                	ld	a5,200(s1)
    800027d8:	fcf773e3          	bgeu	a4,a5,8000279e <scheduler_lottery+0xf2>
            selected_proc = p;
    800027dc:	84d2                	mv	s1,s4
    800027de:	b7c1                	j	8000279e <scheduler_lottery+0xf2>
      acquire(&selected_proc->lock);
    800027e0:	8a26                	mv	s4,s1
    800027e2:	8526                	mv	a0,s1
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	5cc080e7          	jalr	1484(ra) # 80000db0 <acquire>
      if (selected_proc->state == RUNNABLE)
    800027ec:	4c9c                	lw	a5,24(s1)
    800027ee:	01378863          	beq	a5,s3,800027fe <scheduler_lottery+0x152>
      release(&selected_proc->lock);
    800027f2:	8552                	mv	a0,s4
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	66c080e7          	jalr	1644(ra) # 80000e60 <release>
    800027fc:	b73d                	j	8000272a <scheduler_lottery+0x7e>
        selected_proc->state = RUNNING;
    800027fe:	4791                	li	a5,4
    80002800:	cc9c                	sw	a5,24(s1)
        c->proc = selected_proc;
    80002802:	049ab023          	sd	s1,64(s5)
        swtch(&c->context, &selected_proc->context);
    80002806:	23848593          	addi	a1,s1,568
    8000280a:	855e                	mv	a0,s7
    8000280c:	00001097          	auipc	ra,0x1
    80002810:	87e080e7          	jalr	-1922(ra) # 8000308a <swtch>
        c->proc = 0;
    80002814:	040ab023          	sd	zero,64(s5)
    80002818:	bfe9                	j	800027f2 <scheduler_lottery+0x146>

000000008000281a <scheduler>:
{
    8000281a:	1141                	addi	sp,sp,-16
    8000281c:	e406                	sd	ra,8(sp)
    8000281e:	e022                	sd	s0,0(sp)
    80002820:	0800                	addi	s0,sp,16
      scheduler_rr();
    80002822:	00000097          	auipc	ra,0x0
    80002826:	dea080e7          	jalr	-534(ra) # 8000260c <scheduler_rr>

000000008000282a <sched>:
{
    8000282a:	7179                	addi	sp,sp,-48
    8000282c:	f406                	sd	ra,40(sp)
    8000282e:	f022                	sd	s0,32(sp)
    80002830:	ec26                	sd	s1,24(sp)
    80002832:	e84a                	sd	s2,16(sp)
    80002834:	e44e                	sd	s3,8(sp)
    80002836:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	646080e7          	jalr	1606(ra) # 80001e7e <myproc>
    80002840:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	4f4080e7          	jalr	1268(ra) # 80000d36 <holding>
    8000284a:	c93d                	beqz	a0,800028c0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000284c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000284e:	2781                	sext.w	a5,a5
    80002850:	079e                	slli	a5,a5,0x7
    80002852:	0022f717          	auipc	a4,0x22f
    80002856:	3a670713          	addi	a4,a4,934 # 80231bf8 <queues_sizes>
    8000285a:	97ba                	add	a5,a5,a4
    8000285c:	0b87a703          	lw	a4,184(a5)
    80002860:	4785                	li	a5,1
    80002862:	06f71763          	bne	a4,a5,800028d0 <sched+0xa6>
  if (p->state == RUNNING)
    80002866:	4c98                	lw	a4,24(s1)
    80002868:	4791                	li	a5,4
    8000286a:	06f70b63          	beq	a4,a5,800028e0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002872:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002874:	efb5                	bnez	a5,800028f0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002876:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002878:	0022f917          	auipc	s2,0x22f
    8000287c:	38090913          	addi	s2,s2,896 # 80231bf8 <queues_sizes>
    80002880:	2781                	sext.w	a5,a5
    80002882:	079e                	slli	a5,a5,0x7
    80002884:	97ca                	add	a5,a5,s2
    80002886:	0bc7a983          	lw	s3,188(a5)
    8000288a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000288c:	2781                	sext.w	a5,a5
    8000288e:	079e                	slli	a5,a5,0x7
    80002890:	0022f597          	auipc	a1,0x22f
    80002894:	3b058593          	addi	a1,a1,944 # 80231c40 <cpus+0x8>
    80002898:	95be                	add	a1,a1,a5
    8000289a:	23848513          	addi	a0,s1,568
    8000289e:	00000097          	auipc	ra,0x0
    800028a2:	7ec080e7          	jalr	2028(ra) # 8000308a <swtch>
    800028a6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800028a8:	2781                	sext.w	a5,a5
    800028aa:	079e                	slli	a5,a5,0x7
    800028ac:	993e                	add	s2,s2,a5
    800028ae:	0b392e23          	sw	s3,188(s2)
}
    800028b2:	70a2                	ld	ra,40(sp)
    800028b4:	7402                	ld	s0,32(sp)
    800028b6:	64e2                	ld	s1,24(sp)
    800028b8:	6942                	ld	s2,16(sp)
    800028ba:	69a2                	ld	s3,8(sp)
    800028bc:	6145                	addi	sp,sp,48
    800028be:	8082                	ret
    panic("sched p->lock");
    800028c0:	00007517          	auipc	a0,0x7
    800028c4:	9b850513          	addi	a0,a0,-1608 # 80009278 <etext+0x278>
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	c98080e7          	jalr	-872(ra) # 80000560 <panic>
    panic("sched locks");
    800028d0:	00007517          	auipc	a0,0x7
    800028d4:	9b850513          	addi	a0,a0,-1608 # 80009288 <etext+0x288>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	c88080e7          	jalr	-888(ra) # 80000560 <panic>
    panic("sched running");
    800028e0:	00007517          	auipc	a0,0x7
    800028e4:	9b850513          	addi	a0,a0,-1608 # 80009298 <etext+0x298>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	c78080e7          	jalr	-904(ra) # 80000560 <panic>
    panic("sched interruptible");
    800028f0:	00007517          	auipc	a0,0x7
    800028f4:	9b850513          	addi	a0,a0,-1608 # 800092a8 <etext+0x2a8>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c68080e7          	jalr	-920(ra) # 80000560 <panic>

0000000080002900 <yield>:
{
    80002900:	1101                	addi	sp,sp,-32
    80002902:	ec06                	sd	ra,24(sp)
    80002904:	e822                	sd	s0,16(sp)
    80002906:	e426                	sd	s1,8(sp)
    80002908:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000290a:	fffff097          	auipc	ra,0xfffff
    8000290e:	574080e7          	jalr	1396(ra) # 80001e7e <myproc>
    80002912:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	49c080e7          	jalr	1180(ra) # 80000db0 <acquire>
  p->state = RUNNABLE;
    8000291c:	478d                	li	a5,3
    8000291e:	cc9c                	sw	a5,24(s1)
  sched();
    80002920:	00000097          	auipc	ra,0x0
    80002924:	f0a080e7          	jalr	-246(ra) # 8000282a <sched>
  release(&p->lock);
    80002928:	8526                	mv	a0,s1
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	536080e7          	jalr	1334(ra) # 80000e60 <release>
}
    80002932:	60e2                	ld	ra,24(sp)
    80002934:	6442                	ld	s0,16(sp)
    80002936:	64a2                	ld	s1,8(sp)
    80002938:	6105                	addi	sp,sp,32
    8000293a:	8082                	ret

000000008000293c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000293c:	7179                	addi	sp,sp,-48
    8000293e:	f406                	sd	ra,40(sp)
    80002940:	f022                	sd	s0,32(sp)
    80002942:	ec26                	sd	s1,24(sp)
    80002944:	e84a                	sd	s2,16(sp)
    80002946:	e44e                	sd	s3,8(sp)
    80002948:	1800                	addi	s0,sp,48
    8000294a:	89aa                	mv	s3,a0
    8000294c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000294e:	fffff097          	auipc	ra,0xfffff
    80002952:	530080e7          	jalr	1328(ra) # 80001e7e <myproc>
    80002956:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	458080e7          	jalr	1112(ra) # 80000db0 <acquire>
  release(lk);
    80002960:	854a                	mv	a0,s2
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	4fe080e7          	jalr	1278(ra) # 80000e60 <release>

  // Go to sleep.
  p->chan = chan;
    8000296a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000296e:	4789                	li	a5,2
    80002970:	cc9c                	sw	a5,24(s1)

  sched();
    80002972:	00000097          	auipc	ra,0x0
    80002976:	eb8080e7          	jalr	-328(ra) # 8000282a <sched>

  // Tidy up.
  p->chan = 0;
    8000297a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000297e:	8526                	mv	a0,s1
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	4e0080e7          	jalr	1248(ra) # 80000e60 <release>
  acquire(lk);
    80002988:	854a                	mv	a0,s2
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	426080e7          	jalr	1062(ra) # 80000db0 <acquire>
}
    80002992:	70a2                	ld	ra,40(sp)
    80002994:	7402                	ld	s0,32(sp)
    80002996:	64e2                	ld	s1,24(sp)
    80002998:	6942                	ld	s2,16(sp)
    8000299a:	69a2                	ld	s3,8(sp)
    8000299c:	6145                	addi	sp,sp,48
    8000299e:	8082                	ret

00000000800029a0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800029a0:	7139                	addi	sp,sp,-64
    800029a2:	fc06                	sd	ra,56(sp)
    800029a4:	f822                	sd	s0,48(sp)
    800029a6:	f426                	sd	s1,40(sp)
    800029a8:	f04a                	sd	s2,32(sp)
    800029aa:	ec4e                	sd	s3,24(sp)
    800029ac:	e852                	sd	s4,16(sp)
    800029ae:	e456                	sd	s5,8(sp)
    800029b0:	0080                	addi	s0,sp,64
    800029b2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800029b4:	00230497          	auipc	s1,0x230
    800029b8:	e8448493          	addi	s1,s1,-380 # 80232838 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800029bc:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800029be:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800029c0:	0023d917          	auipc	s2,0x23d
    800029c4:	27890913          	addi	s2,s2,632 # 8023fc38 <tickslock>
    800029c8:	a811                	j	800029dc <wakeup+0x3c>
        Enqueue(p, p->priority);
      }
      release(&p->lock);
    800029ca:	8526                	mv	a0,s1
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	494080e7          	jalr	1172(ra) # 80000e60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800029d4:	35048493          	addi	s1,s1,848
    800029d8:	03248d63          	beq	s1,s2,80002a12 <wakeup+0x72>
    if (p != myproc())
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	4a2080e7          	jalr	1186(ra) # 80001e7e <myproc>
    800029e4:	fea488e3          	beq	s1,a0,800029d4 <wakeup+0x34>
      acquire(&p->lock);
    800029e8:	8526                	mv	a0,s1
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	3c6080e7          	jalr	966(ra) # 80000db0 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800029f2:	4c9c                	lw	a5,24(s1)
    800029f4:	fd379be3          	bne	a5,s3,800029ca <wakeup+0x2a>
    800029f8:	709c                	ld	a5,32(s1)
    800029fa:	fd4798e3          	bne	a5,s4,800029ca <wakeup+0x2a>
        p->state = RUNNABLE;
    800029fe:	0154ac23          	sw	s5,24(s1)
        Enqueue(p, p->priority);
    80002a02:	0d84a583          	lw	a1,216(s1)
    80002a06:	8526                	mv	a0,s1
    80002a08:	fffff097          	auipc	ra,0xfffff
    80002a0c:	218080e7          	jalr	536(ra) # 80001c20 <Enqueue>
    80002a10:	bf6d                	j	800029ca <wakeup+0x2a>
    }
  }
}
    80002a12:	70e2                	ld	ra,56(sp)
    80002a14:	7442                	ld	s0,48(sp)
    80002a16:	74a2                	ld	s1,40(sp)
    80002a18:	7902                	ld	s2,32(sp)
    80002a1a:	69e2                	ld	s3,24(sp)
    80002a1c:	6a42                	ld	s4,16(sp)
    80002a1e:	6aa2                	ld	s5,8(sp)
    80002a20:	6121                	addi	sp,sp,64
    80002a22:	8082                	ret

0000000080002a24 <reparent>:
{
    80002a24:	7179                	addi	sp,sp,-48
    80002a26:	f406                	sd	ra,40(sp)
    80002a28:	f022                	sd	s0,32(sp)
    80002a2a:	ec26                	sd	s1,24(sp)
    80002a2c:	e84a                	sd	s2,16(sp)
    80002a2e:	e44e                	sd	s3,8(sp)
    80002a30:	e052                	sd	s4,0(sp)
    80002a32:	1800                	addi	s0,sp,48
    80002a34:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a36:	00230497          	auipc	s1,0x230
    80002a3a:	e0248493          	addi	s1,s1,-510 # 80232838 <proc>
      pp->parent = initproc;
    80002a3e:	00007a17          	auipc	s4,0x7
    80002a42:	f2aa0a13          	addi	s4,s4,-214 # 80009968 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a46:	0023d997          	auipc	s3,0x23d
    80002a4a:	1f298993          	addi	s3,s3,498 # 8023fc38 <tickslock>
    80002a4e:	a029                	j	80002a58 <reparent+0x34>
    80002a50:	35048493          	addi	s1,s1,848
    80002a54:	01348d63          	beq	s1,s3,80002a6e <reparent+0x4a>
    if (pp->parent == p)
    80002a58:	7c9c                	ld	a5,56(s1)
    80002a5a:	ff279be3          	bne	a5,s2,80002a50 <reparent+0x2c>
      pp->parent = initproc;
    80002a5e:	000a3503          	ld	a0,0(s4)
    80002a62:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002a64:	00000097          	auipc	ra,0x0
    80002a68:	f3c080e7          	jalr	-196(ra) # 800029a0 <wakeup>
    80002a6c:	b7d5                	j	80002a50 <reparent+0x2c>
}
    80002a6e:	70a2                	ld	ra,40(sp)
    80002a70:	7402                	ld	s0,32(sp)
    80002a72:	64e2                	ld	s1,24(sp)
    80002a74:	6942                	ld	s2,16(sp)
    80002a76:	69a2                	ld	s3,8(sp)
    80002a78:	6a02                	ld	s4,0(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret

0000000080002a7e <exit>:
{
    80002a7e:	7179                	addi	sp,sp,-48
    80002a80:	f406                	sd	ra,40(sp)
    80002a82:	f022                	sd	s0,32(sp)
    80002a84:	ec26                	sd	s1,24(sp)
    80002a86:	e84a                	sd	s2,16(sp)
    80002a88:	e44e                	sd	s3,8(sp)
    80002a8a:	e052                	sd	s4,0(sp)
    80002a8c:	1800                	addi	s0,sp,48
    80002a8e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	3ee080e7          	jalr	1006(ra) # 80001e7e <myproc>
    80002a98:	89aa                	mv	s3,a0
  if (p == initproc)
    80002a9a:	00007797          	auipc	a5,0x7
    80002a9e:	ece7b783          	ld	a5,-306(a5) # 80009968 <initproc>
    80002aa2:	2a850493          	addi	s1,a0,680
    80002aa6:	32850913          	addi	s2,a0,808
    80002aaa:	00a79d63          	bne	a5,a0,80002ac4 <exit+0x46>
    panic("init exiting");
    80002aae:	00007517          	auipc	a0,0x7
    80002ab2:	81250513          	addi	a0,a0,-2030 # 800092c0 <etext+0x2c0>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	aaa080e7          	jalr	-1366(ra) # 80000560 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002abe:	04a1                	addi	s1,s1,8
    80002ac0:	01248b63          	beq	s1,s2,80002ad6 <exit+0x58>
    if (p->ofile[fd])
    80002ac4:	6088                	ld	a0,0(s1)
    80002ac6:	dd65                	beqz	a0,80002abe <exit+0x40>
      fileclose(f);
    80002ac8:	00002097          	auipc	ra,0x2
    80002acc:	7fe080e7          	jalr	2046(ra) # 800052c6 <fileclose>
      p->ofile[fd] = 0;
    80002ad0:	0004b023          	sd	zero,0(s1)
    80002ad4:	b7ed                	j	80002abe <exit+0x40>
  begin_op();
    80002ad6:	00002097          	auipc	ra,0x2
    80002ada:	320080e7          	jalr	800(ra) # 80004df6 <begin_op>
  iput(p->cwd);
    80002ade:	3289b503          	ld	a0,808(s3)
    80002ae2:	00002097          	auipc	ra,0x2
    80002ae6:	ae8080e7          	jalr	-1304(ra) # 800045ca <iput>
  end_op();
    80002aea:	00002097          	auipc	ra,0x2
    80002aee:	386080e7          	jalr	902(ra) # 80004e70 <end_op>
  p->cwd = 0;
    80002af2:	3209b423          	sd	zero,808(s3)
  acquire(&wait_lock);
    80002af6:	0022f497          	auipc	s1,0x22f
    80002afa:	12a48493          	addi	s1,s1,298 # 80231c20 <wait_lock>
    80002afe:	8526                	mv	a0,s1
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	2b0080e7          	jalr	688(ra) # 80000db0 <acquire>
  reparent(p);
    80002b08:	854e                	mv	a0,s3
    80002b0a:	00000097          	auipc	ra,0x0
    80002b0e:	f1a080e7          	jalr	-230(ra) # 80002a24 <reparent>
  wakeup(p->parent);
    80002b12:	0389b503          	ld	a0,56(s3)
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	e8a080e7          	jalr	-374(ra) # 800029a0 <wakeup>
  acquire(&p->lock);
    80002b1e:	854e                	mv	a0,s3
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	290080e7          	jalr	656(ra) # 80000db0 <acquire>
  p->xstate = status;
    80002b28:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002b2c:	4795                	li	a5,5
    80002b2e:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002b32:	00007797          	auipc	a5,0x7
    80002b36:	e427a783          	lw	a5,-446(a5) # 80009974 <ticks>
    80002b3a:	34f9a423          	sw	a5,840(s3)
  release(&wait_lock);
    80002b3e:	8526                	mv	a0,s1
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	320080e7          	jalr	800(ra) # 80000e60 <release>
  sched();
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	ce2080e7          	jalr	-798(ra) # 8000282a <sched>
  panic("zombie exit");
    80002b50:	00006517          	auipc	a0,0x6
    80002b54:	78050513          	addi	a0,a0,1920 # 800092d0 <etext+0x2d0>
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	a08080e7          	jalr	-1528(ra) # 80000560 <panic>

0000000080002b60 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002b60:	7179                	addi	sp,sp,-48
    80002b62:	f406                	sd	ra,40(sp)
    80002b64:	f022                	sd	s0,32(sp)
    80002b66:	ec26                	sd	s1,24(sp)
    80002b68:	e84a                	sd	s2,16(sp)
    80002b6a:	e44e                	sd	s3,8(sp)
    80002b6c:	1800                	addi	s0,sp,48
    80002b6e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002b70:	00230497          	auipc	s1,0x230
    80002b74:	cc848493          	addi	s1,s1,-824 # 80232838 <proc>
    80002b78:	0023d997          	auipc	s3,0x23d
    80002b7c:	0c098993          	addi	s3,s3,192 # 8023fc38 <tickslock>
  {
    acquire(&p->lock);
    80002b80:	8526                	mv	a0,s1
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	22e080e7          	jalr	558(ra) # 80000db0 <acquire>
    if (p->pid == pid)
    80002b8a:	589c                	lw	a5,48(s1)
    80002b8c:	01278d63          	beq	a5,s2,80002ba6 <kill+0x46>
        Enqueue(p, p->priority);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002b90:	8526                	mv	a0,s1
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	2ce080e7          	jalr	718(ra) # 80000e60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b9a:	35048493          	addi	s1,s1,848
    80002b9e:	ff3491e3          	bne	s1,s3,80002b80 <kill+0x20>
  }
  return -1;
    80002ba2:	557d                	li	a0,-1
    80002ba4:	a829                	j	80002bbe <kill+0x5e>
      p->killed = 1;
    80002ba6:	4785                	li	a5,1
    80002ba8:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002baa:	4c98                	lw	a4,24(s1)
    80002bac:	4789                	li	a5,2
    80002bae:	00f70f63          	beq	a4,a5,80002bcc <kill+0x6c>
      release(&p->lock);
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	2ac080e7          	jalr	684(ra) # 80000e60 <release>
      return 0;
    80002bbc:	4501                	li	a0,0
}
    80002bbe:	70a2                	ld	ra,40(sp)
    80002bc0:	7402                	ld	s0,32(sp)
    80002bc2:	64e2                	ld	s1,24(sp)
    80002bc4:	6942                	ld	s2,16(sp)
    80002bc6:	69a2                	ld	s3,8(sp)
    80002bc8:	6145                	addi	sp,sp,48
    80002bca:	8082                	ret
        p->state = RUNNABLE;
    80002bcc:	478d                	li	a5,3
    80002bce:	cc9c                	sw	a5,24(s1)
        Enqueue(p, p->priority);
    80002bd0:	0d84a583          	lw	a1,216(s1)
    80002bd4:	8526                	mv	a0,s1
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	04a080e7          	jalr	74(ra) # 80001c20 <Enqueue>
    80002bde:	bfd1                	j	80002bb2 <kill+0x52>

0000000080002be0 <setkilled>:

void setkilled(struct proc *p)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	1000                	addi	s0,sp,32
    80002bea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	1c4080e7          	jalr	452(ra) # 80000db0 <acquire>
  p->killed = 1;
    80002bf4:	4785                	li	a5,1
    80002bf6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	266080e7          	jalr	614(ra) # 80000e60 <release>
}
    80002c02:	60e2                	ld	ra,24(sp)
    80002c04:	6442                	ld	s0,16(sp)
    80002c06:	64a2                	ld	s1,8(sp)
    80002c08:	6105                	addi	sp,sp,32
    80002c0a:	8082                	ret

0000000080002c0c <killed>:

int killed(struct proc *p)
{
    80002c0c:	1101                	addi	sp,sp,-32
    80002c0e:	ec06                	sd	ra,24(sp)
    80002c10:	e822                	sd	s0,16(sp)
    80002c12:	e426                	sd	s1,8(sp)
    80002c14:	e04a                	sd	s2,0(sp)
    80002c16:	1000                	addi	s0,sp,32
    80002c18:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	196080e7          	jalr	406(ra) # 80000db0 <acquire>
  k = p->killed;
    80002c22:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002c26:	8526                	mv	a0,s1
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	238080e7          	jalr	568(ra) # 80000e60 <release>
  return k;
}
    80002c30:	854a                	mv	a0,s2
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6902                	ld	s2,0(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <wait>:
{
    80002c3e:	715d                	addi	sp,sp,-80
    80002c40:	e486                	sd	ra,72(sp)
    80002c42:	e0a2                	sd	s0,64(sp)
    80002c44:	fc26                	sd	s1,56(sp)
    80002c46:	f84a                	sd	s2,48(sp)
    80002c48:	f44e                	sd	s3,40(sp)
    80002c4a:	f052                	sd	s4,32(sp)
    80002c4c:	ec56                	sd	s5,24(sp)
    80002c4e:	e85a                	sd	s6,16(sp)
    80002c50:	e45e                	sd	s7,8(sp)
    80002c52:	0880                	addi	s0,sp,80
    80002c54:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002c56:	fffff097          	auipc	ra,0xfffff
    80002c5a:	228080e7          	jalr	552(ra) # 80001e7e <myproc>
    80002c5e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002c60:	0022f517          	auipc	a0,0x22f
    80002c64:	fc050513          	addi	a0,a0,-64 # 80231c20 <wait_lock>
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	148080e7          	jalr	328(ra) # 80000db0 <acquire>
        if (pp->state == ZOMBIE)
    80002c70:	4a95                	li	s5,5
        havekids = 1;
    80002c72:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002c74:	0023d997          	auipc	s3,0x23d
    80002c78:	fc498993          	addi	s3,s3,-60 # 8023fc38 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002c7c:	0022fb97          	auipc	s7,0x22f
    80002c80:	fa4b8b93          	addi	s7,s7,-92 # 80231c20 <wait_lock>
    80002c84:	a0cd                	j	80002d66 <wait+0x128>
    80002c86:	04048613          	addi	a2,s1,64
          for (int i = 0; i <= 25; i++)
    80002c8a:	4701                	li	a4,0
    80002c8c:	4569                	li	a0,26
            pp->parent->syscall_count[i] += pp->syscall_count[i];
    80002c8e:	00271693          	slli	a3,a4,0x2
    80002c92:	7c9c                	ld	a5,56(s1)
    80002c94:	97b6                	add	a5,a5,a3
    80002c96:	43ac                	lw	a1,64(a5)
    80002c98:	4214                	lw	a3,0(a2)
    80002c9a:	9ead                	addw	a3,a3,a1
    80002c9c:	c3b4                	sw	a3,64(a5)
          for (int i = 0; i <= 25; i++)
    80002c9e:	2705                	addiw	a4,a4,1
    80002ca0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80002ca2:	fea716e3          	bne	a4,a0,80002c8e <wait+0x50>
          pid = pp->pid;
    80002ca6:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002caa:	000a0e63          	beqz	s4,80002cc6 <wait+0x88>
    80002cae:	4691                	li	a3,4
    80002cb0:	02c48613          	addi	a2,s1,44
    80002cb4:	85d2                	mv	a1,s4
    80002cb6:	22893503          	ld	a0,552(s2)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	cb8080e7          	jalr	-840(ra) # 80001972 <copyout>
    80002cc2:	04054063          	bltz	a0,80002d02 <wait+0xc4>
          freeproc(pp);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	368080e7          	jalr	872(ra) # 80002030 <freeproc>
          release(&pp->lock);
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	ffffe097          	auipc	ra,0xffffe
    80002cd6:	18e080e7          	jalr	398(ra) # 80000e60 <release>
          release(&wait_lock);
    80002cda:	0022f517          	auipc	a0,0x22f
    80002cde:	f4650513          	addi	a0,a0,-186 # 80231c20 <wait_lock>
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	17e080e7          	jalr	382(ra) # 80000e60 <release>
}
    80002cea:	854e                	mv	a0,s3
    80002cec:	60a6                	ld	ra,72(sp)
    80002cee:	6406                	ld	s0,64(sp)
    80002cf0:	74e2                	ld	s1,56(sp)
    80002cf2:	7942                	ld	s2,48(sp)
    80002cf4:	79a2                	ld	s3,40(sp)
    80002cf6:	7a02                	ld	s4,32(sp)
    80002cf8:	6ae2                	ld	s5,24(sp)
    80002cfa:	6b42                	ld	s6,16(sp)
    80002cfc:	6ba2                	ld	s7,8(sp)
    80002cfe:	6161                	addi	sp,sp,80
    80002d00:	8082                	ret
            release(&pp->lock);
    80002d02:	8526                	mv	a0,s1
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	15c080e7          	jalr	348(ra) # 80000e60 <release>
            release(&wait_lock);
    80002d0c:	0022f517          	auipc	a0,0x22f
    80002d10:	f1450513          	addi	a0,a0,-236 # 80231c20 <wait_lock>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	14c080e7          	jalr	332(ra) # 80000e60 <release>
            return -1;
    80002d1c:	59fd                	li	s3,-1
    80002d1e:	b7f1                	j	80002cea <wait+0xac>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002d20:	35048493          	addi	s1,s1,848
    80002d24:	03348463          	beq	s1,s3,80002d4c <wait+0x10e>
      if (pp->parent == p)
    80002d28:	7c9c                	ld	a5,56(s1)
    80002d2a:	ff279be3          	bne	a5,s2,80002d20 <wait+0xe2>
        acquire(&pp->lock);
    80002d2e:	8526                	mv	a0,s1
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	080080e7          	jalr	128(ra) # 80000db0 <acquire>
        if (pp->state == ZOMBIE)
    80002d38:	4c9c                	lw	a5,24(s1)
    80002d3a:	f55786e3          	beq	a5,s5,80002c86 <wait+0x48>
        release(&pp->lock);
    80002d3e:	8526                	mv	a0,s1
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	120080e7          	jalr	288(ra) # 80000e60 <release>
        havekids = 1;
    80002d48:	875a                	mv	a4,s6
    80002d4a:	bfd9                	j	80002d20 <wait+0xe2>
    if (!havekids || killed(p))
    80002d4c:	c31d                	beqz	a4,80002d72 <wait+0x134>
    80002d4e:	854a                	mv	a0,s2
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	ebc080e7          	jalr	-324(ra) # 80002c0c <killed>
    80002d58:	ed09                	bnez	a0,80002d72 <wait+0x134>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002d5a:	85de                	mv	a1,s7
    80002d5c:	854a                	mv	a0,s2
    80002d5e:	00000097          	auipc	ra,0x0
    80002d62:	bde080e7          	jalr	-1058(ra) # 8000293c <sleep>
    havekids = 0;
    80002d66:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002d68:	00230497          	auipc	s1,0x230
    80002d6c:	ad048493          	addi	s1,s1,-1328 # 80232838 <proc>
    80002d70:	bf65                	j	80002d28 <wait+0xea>
      release(&wait_lock);
    80002d72:	0022f517          	auipc	a0,0x22f
    80002d76:	eae50513          	addi	a0,a0,-338 # 80231c20 <wait_lock>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	0e6080e7          	jalr	230(ra) # 80000e60 <release>
      return -1;
    80002d82:	59fd                	li	s3,-1
    80002d84:	b79d                	j	80002cea <wait+0xac>

0000000080002d86 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002d86:	7179                	addi	sp,sp,-48
    80002d88:	f406                	sd	ra,40(sp)
    80002d8a:	f022                	sd	s0,32(sp)
    80002d8c:	ec26                	sd	s1,24(sp)
    80002d8e:	e84a                	sd	s2,16(sp)
    80002d90:	e44e                	sd	s3,8(sp)
    80002d92:	e052                	sd	s4,0(sp)
    80002d94:	1800                	addi	s0,sp,48
    80002d96:	84aa                	mv	s1,a0
    80002d98:	892e                	mv	s2,a1
    80002d9a:	89b2                	mv	s3,a2
    80002d9c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	0e0080e7          	jalr	224(ra) # 80001e7e <myproc>
  if (user_dst)
    80002da6:	c095                	beqz	s1,80002dca <either_copyout+0x44>
  {
    return copyout(p->pagetable, dst, src, len);
    80002da8:	86d2                	mv	a3,s4
    80002daa:	864e                	mv	a2,s3
    80002dac:	85ca                	mv	a1,s2
    80002dae:	22853503          	ld	a0,552(a0)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	bc0080e7          	jalr	-1088(ra) # 80001972 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002dba:	70a2                	ld	ra,40(sp)
    80002dbc:	7402                	ld	s0,32(sp)
    80002dbe:	64e2                	ld	s1,24(sp)
    80002dc0:	6942                	ld	s2,16(sp)
    80002dc2:	69a2                	ld	s3,8(sp)
    80002dc4:	6a02                	ld	s4,0(sp)
    80002dc6:	6145                	addi	sp,sp,48
    80002dc8:	8082                	ret
    memmove((char *)dst, src, len);
    80002dca:	000a061b          	sext.w	a2,s4
    80002dce:	85ce                	mv	a1,s3
    80002dd0:	854a                	mv	a0,s2
    80002dd2:	ffffe097          	auipc	ra,0xffffe
    80002dd6:	13a080e7          	jalr	314(ra) # 80000f0c <memmove>
    return 0;
    80002dda:	8526                	mv	a0,s1
    80002ddc:	bff9                	j	80002dba <either_copyout+0x34>

0000000080002dde <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002dde:	7179                	addi	sp,sp,-48
    80002de0:	f406                	sd	ra,40(sp)
    80002de2:	f022                	sd	s0,32(sp)
    80002de4:	ec26                	sd	s1,24(sp)
    80002de6:	e84a                	sd	s2,16(sp)
    80002de8:	e44e                	sd	s3,8(sp)
    80002dea:	e052                	sd	s4,0(sp)
    80002dec:	1800                	addi	s0,sp,48
    80002dee:	892a                	mv	s2,a0
    80002df0:	84ae                	mv	s1,a1
    80002df2:	89b2                	mv	s3,a2
    80002df4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	088080e7          	jalr	136(ra) # 80001e7e <myproc>
  if (user_src)
    80002dfe:	c095                	beqz	s1,80002e22 <either_copyin+0x44>
  {
    return copyin(p->pagetable, dst, src, len);
    80002e00:	86d2                	mv	a3,s4
    80002e02:	864e                	mv	a2,s3
    80002e04:	85ca                	mv	a1,s2
    80002e06:	22853503          	ld	a0,552(a0)
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	bf4080e7          	jalr	-1036(ra) # 800019fe <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002e12:	70a2                	ld	ra,40(sp)
    80002e14:	7402                	ld	s0,32(sp)
    80002e16:	64e2                	ld	s1,24(sp)
    80002e18:	6942                	ld	s2,16(sp)
    80002e1a:	69a2                	ld	s3,8(sp)
    80002e1c:	6a02                	ld	s4,0(sp)
    80002e1e:	6145                	addi	sp,sp,48
    80002e20:	8082                	ret
    memmove(dst, (char *)src, len);
    80002e22:	000a061b          	sext.w	a2,s4
    80002e26:	85ce                	mv	a1,s3
    80002e28:	854a                	mv	a0,s2
    80002e2a:	ffffe097          	auipc	ra,0xffffe
    80002e2e:	0e2080e7          	jalr	226(ra) # 80000f0c <memmove>
    return 0;
    80002e32:	8526                	mv	a0,s1
    80002e34:	bff9                	j	80002e12 <either_copyin+0x34>

0000000080002e36 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002e36:	715d                	addi	sp,sp,-80
    80002e38:	e486                	sd	ra,72(sp)
    80002e3a:	e0a2                	sd	s0,64(sp)
    80002e3c:	fc26                	sd	s1,56(sp)
    80002e3e:	f84a                	sd	s2,48(sp)
    80002e40:	f44e                	sd	s3,40(sp)
    80002e42:	f052                	sd	s4,32(sp)
    80002e44:	ec56                	sd	s5,24(sp)
    80002e46:	e85a                	sd	s6,16(sp)
    80002e48:	e45e                	sd	s7,8(sp)
    80002e4a:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002e4c:	00006517          	auipc	a0,0x6
    80002e50:	1c450513          	addi	a0,a0,452 # 80009010 <etext+0x10>
    80002e54:	ffffd097          	auipc	ra,0xffffd
    80002e58:	756080e7          	jalr	1878(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002e5c:	00230497          	auipc	s1,0x230
    80002e60:	d0c48493          	addi	s1,s1,-756 # 80232b68 <proc+0x330>
    80002e64:	0023d917          	auipc	s2,0x23d
    80002e68:	10490913          	addi	s2,s2,260 # 8023ff68 <bcache+0x318>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e6c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002e6e:	00006997          	auipc	s3,0x6
    80002e72:	47298993          	addi	s3,s3,1138 # 800092e0 <etext+0x2e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002e76:	00006a97          	auipc	s5,0x6
    80002e7a:	472a8a93          	addi	s5,s5,1138 # 800092e8 <etext+0x2e8>
    printf("\n");
    80002e7e:	00006a17          	auipc	s4,0x6
    80002e82:	192a0a13          	addi	s4,s4,402 # 80009010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e86:	00007b97          	auipc	s7,0x7
    80002e8a:	93ab8b93          	addi	s7,s7,-1734 # 800097c0 <states.0>
    80002e8e:	a00d                	j	80002eb0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002e90:	d006a583          	lw	a1,-768(a3)
    80002e94:	8556                	mv	a0,s5
    80002e96:	ffffd097          	auipc	ra,0xffffd
    80002e9a:	714080e7          	jalr	1812(ra) # 800005aa <printf>
    printf("\n");
    80002e9e:	8552                	mv	a0,s4
    80002ea0:	ffffd097          	auipc	ra,0xffffd
    80002ea4:	70a080e7          	jalr	1802(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002ea8:	35048493          	addi	s1,s1,848
    80002eac:	03248263          	beq	s1,s2,80002ed0 <procdump+0x9a>
    if (p->state == UNUSED)
    80002eb0:	86a6                	mv	a3,s1
    80002eb2:	ce84a783          	lw	a5,-792(s1)
    80002eb6:	dbed                	beqz	a5,80002ea8 <procdump+0x72>
      state = "???";
    80002eb8:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002eba:	fcfb6be3          	bltu	s6,a5,80002e90 <procdump+0x5a>
    80002ebe:	02079713          	slli	a4,a5,0x20
    80002ec2:	01d75793          	srli	a5,a4,0x1d
    80002ec6:	97de                	add	a5,a5,s7
    80002ec8:	6390                	ld	a2,0(a5)
    80002eca:	f279                	bnez	a2,80002e90 <procdump+0x5a>
      state = "???";
    80002ecc:	864e                	mv	a2,s3
    80002ece:	b7c9                	j	80002e90 <procdump+0x5a>
  }
}
    80002ed0:	60a6                	ld	ra,72(sp)
    80002ed2:	6406                	ld	s0,64(sp)
    80002ed4:	74e2                	ld	s1,56(sp)
    80002ed6:	7942                	ld	s2,48(sp)
    80002ed8:	79a2                	ld	s3,40(sp)
    80002eda:	7a02                	ld	s4,32(sp)
    80002edc:	6ae2                	ld	s5,24(sp)
    80002ede:	6b42                	ld	s6,16(sp)
    80002ee0:	6ba2                	ld	s7,8(sp)
    80002ee2:	6161                	addi	sp,sp,80
    80002ee4:	8082                	ret

0000000080002ee6 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002ee6:	711d                	addi	sp,sp,-96
    80002ee8:	ec86                	sd	ra,88(sp)
    80002eea:	e8a2                	sd	s0,80(sp)
    80002eec:	e4a6                	sd	s1,72(sp)
    80002eee:	e0ca                	sd	s2,64(sp)
    80002ef0:	fc4e                	sd	s3,56(sp)
    80002ef2:	f852                	sd	s4,48(sp)
    80002ef4:	f456                	sd	s5,40(sp)
    80002ef6:	f05a                	sd	s6,32(sp)
    80002ef8:	ec5e                	sd	s7,24(sp)
    80002efa:	e862                	sd	s8,16(sp)
    80002efc:	e466                	sd	s9,8(sp)
    80002efe:	1080                	addi	s0,sp,96
    80002f00:	8b2a                	mv	s6,a0
    80002f02:	8bae                	mv	s7,a1
    80002f04:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	f78080e7          	jalr	-136(ra) # 80001e7e <myproc>
    80002f0e:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002f10:	0022f517          	auipc	a0,0x22f
    80002f14:	d1050513          	addi	a0,a0,-752 # 80231c20 <wait_lock>
    80002f18:	ffffe097          	auipc	ra,0xffffe
    80002f1c:	e98080e7          	jalr	-360(ra) # 80000db0 <acquire>
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002f20:	4a15                	li	s4,5
        havekids = 1;
    80002f22:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002f24:	0023d997          	auipc	s3,0x23d
    80002f28:	d1498993          	addi	s3,s3,-748 # 8023fc38 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002f2c:	0022fc97          	auipc	s9,0x22f
    80002f30:	cf4c8c93          	addi	s9,s9,-780 # 80231c20 <wait_lock>
    80002f34:	a8e1                	j	8000300c <waitx+0x126>
          pid = np->pid;
    80002f36:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002f3a:	3404a783          	lw	a5,832(s1)
    80002f3e:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    80002f42:	3444a703          	lw	a4,836(s1)
    80002f46:	9f3d                	addw	a4,a4,a5
    80002f48:	3484a783          	lw	a5,840(s1)
    80002f4c:	9f99                	subw	a5,a5,a4
    80002f4e:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002f52:	000b0e63          	beqz	s6,80002f6e <waitx+0x88>
    80002f56:	4691                	li	a3,4
    80002f58:	02c48613          	addi	a2,s1,44
    80002f5c:	85da                	mv	a1,s6
    80002f5e:	22893503          	ld	a0,552(s2)
    80002f62:	fffff097          	auipc	ra,0xfffff
    80002f66:	a10080e7          	jalr	-1520(ra) # 80001972 <copyout>
    80002f6a:	04054263          	bltz	a0,80002fae <waitx+0xc8>
          freeproc(np);
    80002f6e:	8526                	mv	a0,s1
    80002f70:	fffff097          	auipc	ra,0xfffff
    80002f74:	0c0080e7          	jalr	192(ra) # 80002030 <freeproc>
          release(&np->lock);
    80002f78:	8526                	mv	a0,s1
    80002f7a:	ffffe097          	auipc	ra,0xffffe
    80002f7e:	ee6080e7          	jalr	-282(ra) # 80000e60 <release>
          release(&wait_lock);
    80002f82:	0022f517          	auipc	a0,0x22f
    80002f86:	c9e50513          	addi	a0,a0,-866 # 80231c20 <wait_lock>
    80002f8a:	ffffe097          	auipc	ra,0xffffe
    80002f8e:	ed6080e7          	jalr	-298(ra) # 80000e60 <release>
  }
}
    80002f92:	854e                	mv	a0,s3
    80002f94:	60e6                	ld	ra,88(sp)
    80002f96:	6446                	ld	s0,80(sp)
    80002f98:	64a6                	ld	s1,72(sp)
    80002f9a:	6906                	ld	s2,64(sp)
    80002f9c:	79e2                	ld	s3,56(sp)
    80002f9e:	7a42                	ld	s4,48(sp)
    80002fa0:	7aa2                	ld	s5,40(sp)
    80002fa2:	7b02                	ld	s6,32(sp)
    80002fa4:	6be2                	ld	s7,24(sp)
    80002fa6:	6c42                	ld	s8,16(sp)
    80002fa8:	6ca2                	ld	s9,8(sp)
    80002faa:	6125                	addi	sp,sp,96
    80002fac:	8082                	ret
            release(&np->lock);
    80002fae:	8526                	mv	a0,s1
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	eb0080e7          	jalr	-336(ra) # 80000e60 <release>
            release(&wait_lock);
    80002fb8:	0022f517          	auipc	a0,0x22f
    80002fbc:	c6850513          	addi	a0,a0,-920 # 80231c20 <wait_lock>
    80002fc0:	ffffe097          	auipc	ra,0xffffe
    80002fc4:	ea0080e7          	jalr	-352(ra) # 80000e60 <release>
            return -1;
    80002fc8:	59fd                	li	s3,-1
    80002fca:	b7e1                	j	80002f92 <waitx+0xac>
    for (np = proc; np < &proc[NPROC]; np++)
    80002fcc:	35048493          	addi	s1,s1,848
    80002fd0:	03348463          	beq	s1,s3,80002ff8 <waitx+0x112>
      if (np->parent == p)
    80002fd4:	7c9c                	ld	a5,56(s1)
    80002fd6:	ff279be3          	bne	a5,s2,80002fcc <waitx+0xe6>
        acquire(&np->lock);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	dd4080e7          	jalr	-556(ra) # 80000db0 <acquire>
        if (np->state == ZOMBIE)
    80002fe4:	4c9c                	lw	a5,24(s1)
    80002fe6:	f54788e3          	beq	a5,s4,80002f36 <waitx+0x50>
        release(&np->lock);
    80002fea:	8526                	mv	a0,s1
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	e74080e7          	jalr	-396(ra) # 80000e60 <release>
        havekids = 1;
    80002ff4:	8756                	mv	a4,s5
    80002ff6:	bfd9                	j	80002fcc <waitx+0xe6>
    if (!havekids || p->killed)
    80002ff8:	c305                	beqz	a4,80003018 <waitx+0x132>
    80002ffa:	02892783          	lw	a5,40(s2)
    80002ffe:	ef89                	bnez	a5,80003018 <waitx+0x132>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80003000:	85e6                	mv	a1,s9
    80003002:	854a                	mv	a0,s2
    80003004:	00000097          	auipc	ra,0x0
    80003008:	938080e7          	jalr	-1736(ra) # 8000293c <sleep>
    havekids = 0;
    8000300c:	4701                	li	a4,0
    for (np = proc; np < &proc[NPROC]; np++)
    8000300e:	00230497          	auipc	s1,0x230
    80003012:	82a48493          	addi	s1,s1,-2006 # 80232838 <proc>
    80003016:	bf7d                	j	80002fd4 <waitx+0xee>
      release(&wait_lock);
    80003018:	0022f517          	auipc	a0,0x22f
    8000301c:	c0850513          	addi	a0,a0,-1016 # 80231c20 <wait_lock>
    80003020:	ffffe097          	auipc	ra,0xffffe
    80003024:	e40080e7          	jalr	-448(ra) # 80000e60 <release>
      return -1;
    80003028:	59fd                	li	s3,-1
    8000302a:	b7a5                	j	80002f92 <waitx+0xac>

000000008000302c <update_time>:

void update_time()
{
    8000302c:	7179                	addi	sp,sp,-48
    8000302e:	f406                	sd	ra,40(sp)
    80003030:	f022                	sd	s0,32(sp)
    80003032:	ec26                	sd	s1,24(sp)
    80003034:	e84a                	sd	s2,16(sp)
    80003036:	e44e                	sd	s3,8(sp)
    80003038:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    8000303a:	0022f497          	auipc	s1,0x22f
    8000303e:	7fe48493          	addi	s1,s1,2046 # 80232838 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80003042:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80003044:	0023d917          	auipc	s2,0x23d
    80003048:	bf490913          	addi	s2,s2,-1036 # 8023fc38 <tickslock>
    8000304c:	a811                	j	80003060 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    8000304e:	8526                	mv	a0,s1
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	e10080e7          	jalr	-496(ra) # 80000e60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80003058:	35048493          	addi	s1,s1,848
    8000305c:	03248063          	beq	s1,s2,8000307c <update_time+0x50>
    acquire(&p->lock);
    80003060:	8526                	mv	a0,s1
    80003062:	ffffe097          	auipc	ra,0xffffe
    80003066:	d4e080e7          	jalr	-690(ra) # 80000db0 <acquire>
    if (p->state == RUNNING)
    8000306a:	4c9c                	lw	a5,24(s1)
    8000306c:	ff3791e3          	bne	a5,s3,8000304e <update_time+0x22>
      p->rtime++;
    80003070:	3404a783          	lw	a5,832(s1)
    80003074:	2785                	addiw	a5,a5,1
    80003076:	34f4a023          	sw	a5,832(s1)
    8000307a:	bfd1                	j	8000304e <update_time+0x22>
  }
  
    8000307c:	70a2                	ld	ra,40(sp)
    8000307e:	7402                	ld	s0,32(sp)
    80003080:	64e2                	ld	s1,24(sp)
    80003082:	6942                	ld	s2,16(sp)
    80003084:	69a2                	ld	s3,8(sp)
    80003086:	6145                	addi	sp,sp,48
    80003088:	8082                	ret

000000008000308a <swtch>:
    8000308a:	00153023          	sd	ra,0(a0)
    8000308e:	00253423          	sd	sp,8(a0)
    80003092:	e900                	sd	s0,16(a0)
    80003094:	ed04                	sd	s1,24(a0)
    80003096:	03253023          	sd	s2,32(a0)
    8000309a:	03353423          	sd	s3,40(a0)
    8000309e:	03453823          	sd	s4,48(a0)
    800030a2:	03553c23          	sd	s5,56(a0)
    800030a6:	05653023          	sd	s6,64(a0)
    800030aa:	05753423          	sd	s7,72(a0)
    800030ae:	05853823          	sd	s8,80(a0)
    800030b2:	05953c23          	sd	s9,88(a0)
    800030b6:	07a53023          	sd	s10,96(a0)
    800030ba:	07b53423          	sd	s11,104(a0)
    800030be:	0005b083          	ld	ra,0(a1)
    800030c2:	0085b103          	ld	sp,8(a1)
    800030c6:	6980                	ld	s0,16(a1)
    800030c8:	6d84                	ld	s1,24(a1)
    800030ca:	0205b903          	ld	s2,32(a1)
    800030ce:	0285b983          	ld	s3,40(a1)
    800030d2:	0305ba03          	ld	s4,48(a1)
    800030d6:	0385ba83          	ld	s5,56(a1)
    800030da:	0405bb03          	ld	s6,64(a1)
    800030de:	0485bb83          	ld	s7,72(a1)
    800030e2:	0505bc03          	ld	s8,80(a1)
    800030e6:	0585bc83          	ld	s9,88(a1)
    800030ea:	0605bd03          	ld	s10,96(a1)
    800030ee:	0685bd83          	ld	s11,104(a1)
    800030f2:	8082                	ret

00000000800030f4 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800030f4:	1141                	addi	sp,sp,-16
    800030f6:	e406                	sd	ra,8(sp)
    800030f8:	e022                	sd	s0,0(sp)
    800030fa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800030fc:	00006597          	auipc	a1,0x6
    80003100:	22c58593          	addi	a1,a1,556 # 80009328 <etext+0x328>
    80003104:	0023d517          	auipc	a0,0x23d
    80003108:	b3450513          	addi	a0,a0,-1228 # 8023fc38 <tickslock>
    8000310c:	ffffe097          	auipc	ra,0xffffe
    80003110:	c10080e7          	jalr	-1008(ra) # 80000d1c <initlock>
}
    80003114:	60a2                	ld	ra,8(sp)
    80003116:	6402                	ld	s0,0(sp)
    80003118:	0141                	addi	sp,sp,16
    8000311a:	8082                	ret

000000008000311c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    8000311c:	1141                	addi	sp,sp,-16
    8000311e:	e406                	sd	ra,8(sp)
    80003120:	e022                	sd	s0,0(sp)
    80003122:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003124:	00004797          	auipc	a5,0x4
    80003128:	8fc78793          	addi	a5,a5,-1796 # 80006a20 <kernelvec>
    8000312c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003130:	60a2                	ld	ra,8(sp)
    80003132:	6402                	ld	s0,0(sp)
    80003134:	0141                	addi	sp,sp,16
    80003136:	8082                	ret

0000000080003138 <pgfault>:

int pgfault(uint64 va, pagetable_t pagetable)
{
    80003138:	872a                	mv	a4,a0
  // struct proc *p = myproc();

  // Check if va is a valid address
  if (va >= MAXVA || va < PGSIZE)
    8000313a:	76fd                	lui	a3,0xfffff
    8000313c:	96aa                	add	a3,a3,a0
    8000313e:	fefff7b7          	lui	a5,0xfefff
    80003142:	07ba                	slli	a5,a5,0xe
    80003144:	83e9                	srli	a5,a5,0x1a
    80003146:	08d7e663          	bltu	a5,a3,800031d2 <pgfault+0x9a>
{
    8000314a:	7179                	addi	sp,sp,-48
    8000314c:	f406                	sd	ra,40(sp)
    8000314e:	f022                	sd	s0,32(sp)
    80003150:	e44e                	sd	s3,8(sp)
    80003152:	1800                	addi	s0,sp,48
    80003154:	852e                	mv	a0,a1
  {
    return -2; // Return error if accessing an invalid address
  }

  va = PGROUNDDOWN(va);
  pte_t *pte = walk(pagetable, va, 0);
    80003156:	4601                	li	a2,0
    80003158:	75fd                	lui	a1,0xfffff
    8000315a:	8df9                	and	a1,a1,a4
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	048080e7          	jalr	72(ra) # 800011a4 <walk>
    80003164:	89aa                	mv	s3,a0
  if (pte == 0 || !(*pte & PTE_V))
    80003166:	c925                	beqz	a0,800031d6 <pgfault+0x9e>
    80003168:	6118                	ld	a4,0(a0)
    8000316a:	00177793          	andi	a5,a4,1
    8000316e:	c7b5                	beqz	a5,800031da <pgfault+0xa2>
    80003170:	e052                	sd	s4,0(sp)
  {
    return -1; // No valid mapping
  }

  uint64 pa = PTE2PA(*pte);
    80003172:	00a75a13          	srli	s4,a4,0xa
    80003176:	0a32                	slli	s4,s4,0xc
  uint flags = PTE_FLAGS(*pte);
    80003178:	0007079b          	sext.w	a5,a4

  // Check if page is marked COW
  if (flags & PTE_COW)
    8000317c:	02077713          	andi	a4,a4,32
    80003180:	cf39                	beqz	a4,800031de <pgfault+0xa6>
    80003182:	ec26                	sd	s1,24(sp)
    80003184:	e84a                	sd	s2,16(sp)
  {
    flags = (flags | PTE_W) & ~PTE_COW; // Update flags for write permission
    80003186:	3df7f793          	andi	a5,a5,991
    8000318a:	0047e913          	ori	s2,a5,4
    char *mem = kalloc();
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	b24080e7          	jalr	-1244(ra) # 80000cb2 <kalloc>
    80003196:	84aa                	mv	s1,a0
    if (mem == 0)
    80003198:	c531                	beqz	a0,800031e4 <pgfault+0xac>
      return -1;

    memmove(mem, (void *)pa, PGSIZE); // Copy page contents to new memory
    8000319a:	6605                	lui	a2,0x1
    8000319c:	85d2                	mv	a1,s4
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	d6e080e7          	jalr	-658(ra) # 80000f0c <memmove>
    *pte = PA2PTE(mem) | flags;       // Update PTE with new physical address and flags
    800031a6:	80b1                	srli	s1,s1,0xc
    800031a8:	04aa                	slli	s1,s1,0xa
    800031aa:	009967b3          	or	a5,s2,s1
    800031ae:	00f9b023          	sd	a5,0(s3)
  asm volatile("sfence.vma zero, zero");
    800031b2:	12000073          	sfence.vma

    sfence_vma();      // Flush TLB
    kfree((void *)pa); // Free original physical page
    800031b6:	8552                	mv	a0,s4
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	98a080e7          	jalr	-1654(ra) # 80000b42 <kfree>
    return 0;
    800031c0:	4501                	li	a0,0
    800031c2:	64e2                	ld	s1,24(sp)
    800031c4:	6942                	ld	s2,16(sp)
    800031c6:	6a02                	ld	s4,0(sp)
  }
  return -1; // Not a COW page fault, likely an invalid access
}
    800031c8:	70a2                	ld	ra,40(sp)
    800031ca:	7402                	ld	s0,32(sp)
    800031cc:	69a2                	ld	s3,8(sp)
    800031ce:	6145                	addi	sp,sp,48
    800031d0:	8082                	ret
    return -2; // Return error if accessing an invalid address
    800031d2:	5579                	li	a0,-2
}
    800031d4:	8082                	ret
    return -1; // No valid mapping
    800031d6:	557d                	li	a0,-1
    800031d8:	bfc5                	j	800031c8 <pgfault+0x90>
    800031da:	557d                	li	a0,-1
    800031dc:	b7f5                	j	800031c8 <pgfault+0x90>
  return -1; // Not a COW page fault, likely an invalid access
    800031de:	557d                	li	a0,-1
    800031e0:	6a02                	ld	s4,0(sp)
    800031e2:	b7dd                	j	800031c8 <pgfault+0x90>
      return -1;
    800031e4:	557d                	li	a0,-1
    800031e6:	64e2                	ld	s1,24(sp)
    800031e8:	6942                	ld	s2,16(sp)
    800031ea:	6a02                	ld	s4,0(sp)
    800031ec:	bff1                	j	800031c8 <pgfault+0x90>

00000000800031ee <usertrapret>:
}

// return to user space
//
void usertrapret(void)
{
    800031ee:	1141                	addi	sp,sp,-16
    800031f0:	e406                	sd	ra,8(sp)
    800031f2:	e022                	sd	s0,0(sp)
    800031f4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	c88080e7          	jalr	-888(ra) # 80001e7e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003202:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003204:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80003208:	00005697          	auipc	a3,0x5
    8000320c:	df868693          	addi	a3,a3,-520 # 80008000 <_trampoline>
    80003210:	00005717          	auipc	a4,0x5
    80003214:	df070713          	addi	a4,a4,-528 # 80008000 <_trampoline>
    80003218:	8f15                	sub	a4,a4,a3
    8000321a:	040007b7          	lui	a5,0x4000
    8000321e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80003220:	07b2                	slli	a5,a5,0xc
    80003222:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003224:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003228:	23053703          	ld	a4,560(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000322c:	18002673          	csrr	a2,satp
    80003230:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003232:	23053603          	ld	a2,560(a0)
    80003236:	21853703          	ld	a4,536(a0)
    8000323a:	6585                	lui	a1,0x1
    8000323c:	972e                	add	a4,a4,a1
    8000323e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003240:	23053703          	ld	a4,560(a0)
    80003244:	00000617          	auipc	a2,0x0
    80003248:	14c60613          	addi	a2,a2,332 # 80003390 <usertrap>
    8000324c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000324e:	23053703          	ld	a4,560(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003252:	8612                	mv	a2,tp
    80003254:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003256:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000325a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000325e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003262:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003266:	23053703          	ld	a4,560(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000326a:	6f18                	ld	a4,24(a4)
    8000326c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003270:	22853503          	ld	a0,552(a0)
    80003274:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80003276:	00005717          	auipc	a4,0x5
    8000327a:	e2670713          	addi	a4,a4,-474 # 8000809c <userret>
    8000327e:	8f15                	sub	a4,a4,a3
    80003280:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80003282:	577d                	li	a4,-1
    80003284:	177e                	slli	a4,a4,0x3f
    80003286:	8d59                	or	a0,a0,a4
    80003288:	9782                	jalr	a5
}
    8000328a:	60a2                	ld	ra,8(sp)
    8000328c:	6402                	ld	s0,0(sp)
    8000328e:	0141                	addi	sp,sp,16
    80003290:	8082                	ret

0000000080003292 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	e426                	sd	s1,8(sp)
    8000329a:	e04a                	sd	s2,0(sp)
    8000329c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000329e:	0023d917          	auipc	s2,0x23d
    800032a2:	99a90913          	addi	s2,s2,-1638 # 8023fc38 <tickslock>
    800032a6:	854a                	mv	a0,s2
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	b08080e7          	jalr	-1272(ra) # 80000db0 <acquire>
  ticks++;
    800032b0:	00006497          	auipc	s1,0x6
    800032b4:	6c448493          	addi	s1,s1,1732 # 80009974 <ticks>
    800032b8:	409c                	lw	a5,0(s1)
    800032ba:	2785                	addiw	a5,a5,1
    800032bc:	c09c                	sw	a5,0(s1)
  update_time();
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	d6e080e7          	jalr	-658(ra) # 8000302c <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    800032c6:	8526                	mv	a0,s1
    800032c8:	fffff097          	auipc	ra,0xfffff
    800032cc:	6d8080e7          	jalr	1752(ra) # 800029a0 <wakeup>
  release(&tickslock);
    800032d0:	854a                	mv	a0,s2
    800032d2:	ffffe097          	auipc	ra,0xffffe
    800032d6:	b8e080e7          	jalr	-1138(ra) # 80000e60 <release>
}
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6902                	ld	s2,0(sp)
    800032e2:	6105                	addi	sp,sp,32
    800032e4:	8082                	ret

00000000800032e6 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032e6:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    800032ea:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    800032ec:	0a07d163          	bgez	a5,8000338e <devintr+0xa8>
{
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    800032f8:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    800032fc:	46a5                	li	a3,9
    800032fe:	00d70c63          	beq	a4,a3,80003316 <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80003302:	577d                	li	a4,-1
    80003304:	177e                	slli	a4,a4,0x3f
    80003306:	0705                	addi	a4,a4,1
    return 0;
    80003308:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    8000330a:	06e78163          	beq	a5,a4,8000336c <devintr+0x86>
  }
}
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret
    80003316:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80003318:	00004097          	auipc	ra,0x4
    8000331c:	814080e7          	jalr	-2028(ra) # 80006b2c <plic_claim>
    80003320:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80003322:	47a9                	li	a5,10
    80003324:	00f50963          	beq	a0,a5,80003336 <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80003328:	4785                	li	a5,1
    8000332a:	00f50b63          	beq	a0,a5,80003340 <devintr+0x5a>
    return 1;
    8000332e:	4505                	li	a0,1
    else if (irq)
    80003330:	ec89                	bnez	s1,8000334a <devintr+0x64>
    80003332:	64a2                	ld	s1,8(sp)
    80003334:	bfe9                	j	8000330e <devintr+0x28>
      uartintr();
    80003336:	ffffd097          	auipc	ra,0xffffd
    8000333a:	6c6080e7          	jalr	1734(ra) # 800009fc <uartintr>
    if (irq)
    8000333e:	a839                	j	8000335c <devintr+0x76>
      virtio_disk_intr();
    80003340:	00004097          	auipc	ra,0x4
    80003344:	ce0080e7          	jalr	-800(ra) # 80007020 <virtio_disk_intr>
    if (irq)
    80003348:	a811                	j	8000335c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000334a:	85a6                	mv	a1,s1
    8000334c:	00006517          	auipc	a0,0x6
    80003350:	fe450513          	addi	a0,a0,-28 # 80009330 <etext+0x330>
    80003354:	ffffd097          	auipc	ra,0xffffd
    80003358:	256080e7          	jalr	598(ra) # 800005aa <printf>
      plic_complete(irq);
    8000335c:	8526                	mv	a0,s1
    8000335e:	00003097          	auipc	ra,0x3
    80003362:	7f2080e7          	jalr	2034(ra) # 80006b50 <plic_complete>
    return 1;
    80003366:	4505                	li	a0,1
    80003368:	64a2                	ld	s1,8(sp)
    8000336a:	b755                	j	8000330e <devintr+0x28>
    if (cpuid() == 0)
    8000336c:	fffff097          	auipc	ra,0xfffff
    80003370:	ade080e7          	jalr	-1314(ra) # 80001e4a <cpuid>
    80003374:	c901                	beqz	a0,80003384 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003376:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000337a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000337c:	14479073          	csrw	sip,a5
    return 2;
    80003380:	4509                	li	a0,2
    80003382:	b771                	j	8000330e <devintr+0x28>
      clockintr();
    80003384:	00000097          	auipc	ra,0x0
    80003388:	f0e080e7          	jalr	-242(ra) # 80003292 <clockintr>
    8000338c:	b7ed                	j	80003376 <devintr+0x90>
}
    8000338e:	8082                	ret

0000000080003390 <usertrap>:
{
    80003390:	1101                	addi	sp,sp,-32
    80003392:	ec06                	sd	ra,24(sp)
    80003394:	e822                	sd	s0,16(sp)
    80003396:	e426                	sd	s1,8(sp)
    80003398:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000339a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000339e:	1007f793          	andi	a5,a5,256
    800033a2:	efad                	bnez	a5,8000341c <usertrap+0x8c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800033a4:	00003797          	auipc	a5,0x3
    800033a8:	67c78793          	addi	a5,a5,1660 # 80006a20 <kernelvec>
    800033ac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800033b0:	fffff097          	auipc	ra,0xfffff
    800033b4:	ace080e7          	jalr	-1330(ra) # 80001e7e <myproc>
    800033b8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800033ba:	23053783          	ld	a5,560(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033be:	14102773          	csrr	a4,sepc
    800033c2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800033c4:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    800033c8:	47a1                	li	a5,8
    800033ca:	06f70163          	beq	a4,a5,8000342c <usertrap+0x9c>
  else if ((which_dev = devintr()) != 0)
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	f18080e7          	jalr	-232(ra) # 800032e6 <devintr>
    800033d6:	e161                	bnez	a0,80003496 <usertrap+0x106>
    800033d8:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    800033dc:	47bd                	li	a5,15
    800033de:	0af70063          	beq	a4,a5,8000347e <usertrap+0xee>
    800033e2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800033e6:	5890                	lw	a2,48(s1)
    800033e8:	00006517          	auipc	a0,0x6
    800033ec:	f8850513          	addi	a0,a0,-120 # 80009370 <etext+0x370>
    800033f0:	ffffd097          	auipc	ra,0xffffd
    800033f4:	1ba080e7          	jalr	442(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033f8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800033fc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003400:	00006517          	auipc	a0,0x6
    80003404:	fa050513          	addi	a0,a0,-96 # 800093a0 <etext+0x3a0>
    80003408:	ffffd097          	auipc	ra,0xffffd
    8000340c:	1a2080e7          	jalr	418(ra) # 800005aa <printf>
    setkilled(p);
    80003410:	8526                	mv	a0,s1
    80003412:	fffff097          	auipc	ra,0xfffff
    80003416:	7ce080e7          	jalr	1998(ra) # 80002be0 <setkilled>
    8000341a:	a82d                	j	80003454 <usertrap+0xc4>
    panic("usertrap: not from user mode");
    8000341c:	00006517          	auipc	a0,0x6
    80003420:	f3450513          	addi	a0,a0,-204 # 80009350 <etext+0x350>
    80003424:	ffffd097          	auipc	ra,0xffffd
    80003428:	13c080e7          	jalr	316(ra) # 80000560 <panic>
    if (killed(p))
    8000342c:	fffff097          	auipc	ra,0xfffff
    80003430:	7e0080e7          	jalr	2016(ra) # 80002c0c <killed>
    80003434:	ed1d                	bnez	a0,80003472 <usertrap+0xe2>
    p->trapframe->epc += 4;
    80003436:	2304b703          	ld	a4,560(s1)
    8000343a:	6f1c                	ld	a5,24(a4)
    8000343c:	0791                	addi	a5,a5,4
    8000343e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003440:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003444:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003448:	10079073          	csrw	sstatus,a5
    syscall();
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	316080e7          	jalr	790(ra) # 80003762 <syscall>
  if (killed(p))
    80003454:	8526                	mv	a0,s1
    80003456:	fffff097          	auipc	ra,0xfffff
    8000345a:	7b6080e7          	jalr	1974(ra) # 80002c0c <killed>
    8000345e:	e155                	bnez	a0,80003502 <usertrap+0x172>
  usertrapret();
    80003460:	00000097          	auipc	ra,0x0
    80003464:	d8e080e7          	jalr	-626(ra) # 800031ee <usertrapret>
}
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	64a2                	ld	s1,8(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret
      exit(-1);
    80003472:	557d                	li	a0,-1
    80003474:	fffff097          	auipc	ra,0xfffff
    80003478:	60a080e7          	jalr	1546(ra) # 80002a7e <exit>
    8000347c:	bf6d                	j	80003436 <usertrap+0xa6>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000347e:	14302573          	csrr	a0,stval
    int r = pgfault(r_stval(), p->pagetable);
    80003482:	2284b583          	ld	a1,552(s1)
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	cb2080e7          	jalr	-846(ra) # 80003138 <pgfault>
    if (r)
    8000348e:	d179                	beqz	a0,80003454 <usertrap+0xc4>
      p->killed = 1;
    80003490:	4785                	li	a5,1
    80003492:	d49c                	sw	a5,40(s1)
    80003494:	b7c1                	j	80003454 <usertrap+0xc4>
  if (which_dev == 2 && p->alarm_interval > 0)
    80003496:	4789                	li	a5,2
    80003498:	faf51ee3          	bne	a0,a5,80003454 <usertrap+0xc4>
    8000349c:	0e44a703          	lw	a4,228(s1)
    800034a0:	00e05c63          	blez	a4,800034b8 <usertrap+0x128>
    p->ticks++;
    800034a4:	0e04a783          	lw	a5,224(s1)
    800034a8:	2785                	addiw	a5,a5,1
    800034aa:	0ef4a023          	sw	a5,224(s1)
    if (p->ticks >= p->alarm_interval && p->alarm_active == 0)
    800034ae:	00e7c563          	blt	a5,a4,800034b8 <usertrap+0x128>
    800034b2:	2104a783          	lw	a5,528(s1)
    800034b6:	cf81                	beqz	a5,800034ce <usertrap+0x13e>
  if (killed(p))
    800034b8:	8526                	mv	a0,s1
    800034ba:	fffff097          	auipc	ra,0xfffff
    800034be:	752080e7          	jalr	1874(ra) # 80002c0c <killed>
    800034c2:	e915                	bnez	a0,800034f6 <usertrap+0x166>
    yield();
    800034c4:	fffff097          	auipc	ra,0xfffff
    800034c8:	43c080e7          	jalr	1084(ra) # 80002900 <yield>
    800034cc:	bf51                	j	80003460 <usertrap+0xd0>
      p->ticks = 0;        // Reset the tick count
    800034ce:	0e04a023          	sw	zero,224(s1)
      p->alarm_active = 1; // Mark that handler is active to prevent re-entry
    800034d2:	4785                	li	a5,1
    800034d4:	20f4a823          	sw	a5,528(s1)
      memmove(&p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    800034d8:	12000613          	li	a2,288
    800034dc:	2304b583          	ld	a1,560(s1)
    800034e0:	0f048513          	addi	a0,s1,240
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	a28080e7          	jalr	-1496(ra) # 80000f0c <memmove>
      p->trapframe->epc = p->handler;
    800034ec:	2304b783          	ld	a5,560(s1)
    800034f0:	74f8                	ld	a4,232(s1)
    800034f2:	ef98                	sd	a4,24(a5)
    800034f4:	b7d1                	j	800034b8 <usertrap+0x128>
    exit(-1);
    800034f6:	557d                	li	a0,-1
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	586080e7          	jalr	1414(ra) # 80002a7e <exit>
  if (which_dev == 2 && SCHEDULER==RR)
    80003500:	b7d1                	j	800034c4 <usertrap+0x134>
    exit(-1);
    80003502:	557d                	li	a0,-1
    80003504:	fffff097          	auipc	ra,0xfffff
    80003508:	57a080e7          	jalr	1402(ra) # 80002a7e <exit>
  if (which_dev == 2 && SCHEDULER==RR)
    8000350c:	bf91                	j	80003460 <usertrap+0xd0>

000000008000350e <kerneltrap>:
{
    8000350e:	7179                	addi	sp,sp,-48
    80003510:	f406                	sd	ra,40(sp)
    80003512:	f022                	sd	s0,32(sp)
    80003514:	ec26                	sd	s1,24(sp)
    80003516:	e84a                	sd	s2,16(sp)
    80003518:	e44e                	sd	s3,8(sp)
    8000351a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000351c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003520:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003524:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80003528:	1004f793          	andi	a5,s1,256
    8000352c:	cb85                	beqz	a5,8000355c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000352e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003532:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003534:	ef85                	bnez	a5,8000356c <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	db0080e7          	jalr	-592(ra) # 800032e6 <devintr>
    8000353e:	cd1d                	beqz	a0,8000357c <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003540:	4789                	li	a5,2
    80003542:	06f50a63          	beq	a0,a5,800035b6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003546:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000354a:	10049073          	csrw	sstatus,s1
}
    8000354e:	70a2                	ld	ra,40(sp)
    80003550:	7402                	ld	s0,32(sp)
    80003552:	64e2                	ld	s1,24(sp)
    80003554:	6942                	ld	s2,16(sp)
    80003556:	69a2                	ld	s3,8(sp)
    80003558:	6145                	addi	sp,sp,48
    8000355a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000355c:	00006517          	auipc	a0,0x6
    80003560:	e6450513          	addi	a0,a0,-412 # 800093c0 <etext+0x3c0>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	ffc080e7          	jalr	-4(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    8000356c:	00006517          	auipc	a0,0x6
    80003570:	e7c50513          	addi	a0,a0,-388 # 800093e8 <etext+0x3e8>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	fec080e7          	jalr	-20(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    8000357c:	85ce                	mv	a1,s3
    8000357e:	00006517          	auipc	a0,0x6
    80003582:	e8a50513          	addi	a0,a0,-374 # 80009408 <etext+0x408>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000358e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003592:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003596:	00006517          	auipc	a0,0x6
    8000359a:	e8250513          	addi	a0,a0,-382 # 80009418 <etext+0x418>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	00c080e7          	jalr	12(ra) # 800005aa <printf>
    panic("kerneltrap");
    800035a6:	00006517          	auipc	a0,0x6
    800035aa:	e8a50513          	addi	a0,a0,-374 # 80009430 <etext+0x430>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	fb2080e7          	jalr	-78(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800035b6:	fffff097          	auipc	ra,0xfffff
    800035ba:	8c8080e7          	jalr	-1848(ra) # 80001e7e <myproc>
    800035be:	d541                	beqz	a0,80003546 <kerneltrap+0x38>
    800035c0:	fffff097          	auipc	ra,0xfffff
    800035c4:	8be080e7          	jalr	-1858(ra) # 80001e7e <myproc>
    800035c8:	4d18                	lw	a4,24(a0)
    800035ca:	4791                	li	a5,4
    800035cc:	f6f71de3          	bne	a4,a5,80003546 <kerneltrap+0x38>
    yield();
    800035d0:	fffff097          	auipc	ra,0xfffff
    800035d4:	330080e7          	jalr	816(ra) # 80002900 <yield>
    800035d8:	b7bd                	j	80003546 <kerneltrap+0x38>

00000000800035da <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800035da:	1101                	addi	sp,sp,-32
    800035dc:	ec06                	sd	ra,24(sp)
    800035de:	e822                	sd	s0,16(sp)
    800035e0:	e426                	sd	s1,8(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800035e6:	fffff097          	auipc	ra,0xfffff
    800035ea:	898080e7          	jalr	-1896(ra) # 80001e7e <myproc>
  switch (n) {
    800035ee:	4795                	li	a5,5
    800035f0:	0497e763          	bltu	a5,s1,8000363e <argraw+0x64>
    800035f4:	048a                	slli	s1,s1,0x2
    800035f6:	00006717          	auipc	a4,0x6
    800035fa:	1fa70713          	addi	a4,a4,506 # 800097f0 <states.0+0x30>
    800035fe:	94ba                	add	s1,s1,a4
    80003600:	409c                	lw	a5,0(s1)
    80003602:	97ba                	add	a5,a5,a4
    80003604:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003606:	23053783          	ld	a5,560(a0)
    8000360a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000360c:	60e2                	ld	ra,24(sp)
    8000360e:	6442                	ld	s0,16(sp)
    80003610:	64a2                	ld	s1,8(sp)
    80003612:	6105                	addi	sp,sp,32
    80003614:	8082                	ret
    return p->trapframe->a1;
    80003616:	23053783          	ld	a5,560(a0)
    8000361a:	7fa8                	ld	a0,120(a5)
    8000361c:	bfc5                	j	8000360c <argraw+0x32>
    return p->trapframe->a2;
    8000361e:	23053783          	ld	a5,560(a0)
    80003622:	63c8                	ld	a0,128(a5)
    80003624:	b7e5                	j	8000360c <argraw+0x32>
    return p->trapframe->a3;
    80003626:	23053783          	ld	a5,560(a0)
    8000362a:	67c8                	ld	a0,136(a5)
    8000362c:	b7c5                	j	8000360c <argraw+0x32>
    return p->trapframe->a4;
    8000362e:	23053783          	ld	a5,560(a0)
    80003632:	6bc8                	ld	a0,144(a5)
    80003634:	bfe1                	j	8000360c <argraw+0x32>
    return p->trapframe->a5;
    80003636:	23053783          	ld	a5,560(a0)
    8000363a:	6fc8                	ld	a0,152(a5)
    8000363c:	bfc1                	j	8000360c <argraw+0x32>
  panic("argraw");
    8000363e:	00006517          	auipc	a0,0x6
    80003642:	e0250513          	addi	a0,a0,-510 # 80009440 <etext+0x440>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>

000000008000364e <fetchaddr>:
{
    8000364e:	1101                	addi	sp,sp,-32
    80003650:	ec06                	sd	ra,24(sp)
    80003652:	e822                	sd	s0,16(sp)
    80003654:	e426                	sd	s1,8(sp)
    80003656:	e04a                	sd	s2,0(sp)
    80003658:	1000                	addi	s0,sp,32
    8000365a:	84aa                	mv	s1,a0
    8000365c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000365e:	fffff097          	auipc	ra,0xfffff
    80003662:	820080e7          	jalr	-2016(ra) # 80001e7e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003666:	22053783          	ld	a5,544(a0)
    8000366a:	02f4f963          	bgeu	s1,a5,8000369c <fetchaddr+0x4e>
    8000366e:	00848713          	addi	a4,s1,8
    80003672:	02e7e763          	bltu	a5,a4,800036a0 <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003676:	46a1                	li	a3,8
    80003678:	8626                	mv	a2,s1
    8000367a:	85ca                	mv	a1,s2
    8000367c:	22853503          	ld	a0,552(a0)
    80003680:	ffffe097          	auipc	ra,0xffffe
    80003684:	37e080e7          	jalr	894(ra) # 800019fe <copyin>
    80003688:	00a03533          	snez	a0,a0
    8000368c:	40a0053b          	negw	a0,a0
}
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	64a2                	ld	s1,8(sp)
    80003696:	6902                	ld	s2,0(sp)
    80003698:	6105                	addi	sp,sp,32
    8000369a:	8082                	ret
    return -1;
    8000369c:	557d                	li	a0,-1
    8000369e:	bfcd                	j	80003690 <fetchaddr+0x42>
    800036a0:	557d                	li	a0,-1
    800036a2:	b7fd                	j	80003690 <fetchaddr+0x42>

00000000800036a4 <fetchstr>:
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e84a                	sd	s2,16(sp)
    800036ae:	e44e                	sd	s3,8(sp)
    800036b0:	1800                	addi	s0,sp,48
    800036b2:	892a                	mv	s2,a0
    800036b4:	84ae                	mv	s1,a1
    800036b6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800036b8:	ffffe097          	auipc	ra,0xffffe
    800036bc:	7c6080e7          	jalr	1990(ra) # 80001e7e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800036c0:	86ce                	mv	a3,s3
    800036c2:	864a                	mv	a2,s2
    800036c4:	85a6                	mv	a1,s1
    800036c6:	22853503          	ld	a0,552(a0)
    800036ca:	ffffe097          	auipc	ra,0xffffe
    800036ce:	3c2080e7          	jalr	962(ra) # 80001a8c <copyinstr>
    800036d2:	00054e63          	bltz	a0,800036ee <fetchstr+0x4a>
  return strlen(buf);
    800036d6:	8526                	mv	a0,s1
    800036d8:	ffffe097          	auipc	ra,0xffffe
    800036dc:	95c080e7          	jalr	-1700(ra) # 80001034 <strlen>
}
    800036e0:	70a2                	ld	ra,40(sp)
    800036e2:	7402                	ld	s0,32(sp)
    800036e4:	64e2                	ld	s1,24(sp)
    800036e6:	6942                	ld	s2,16(sp)
    800036e8:	69a2                	ld	s3,8(sp)
    800036ea:	6145                	addi	sp,sp,48
    800036ec:	8082                	ret
    return -1;
    800036ee:	557d                	li	a0,-1
    800036f0:	bfc5                	j	800036e0 <fetchstr+0x3c>

00000000800036f2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800036f2:	1101                	addi	sp,sp,-32
    800036f4:	ec06                	sd	ra,24(sp)
    800036f6:	e822                	sd	s0,16(sp)
    800036f8:	e426                	sd	s1,8(sp)
    800036fa:	1000                	addi	s0,sp,32
    800036fc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	edc080e7          	jalr	-292(ra) # 800035da <argraw>
    80003706:	c088                	sw	a0,0(s1)
}
    80003708:	60e2                	ld	ra,24(sp)
    8000370a:	6442                	ld	s0,16(sp)
    8000370c:	64a2                	ld	s1,8(sp)
    8000370e:	6105                	addi	sp,sp,32
    80003710:	8082                	ret

0000000080003712 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003712:	1101                	addi	sp,sp,-32
    80003714:	ec06                	sd	ra,24(sp)
    80003716:	e822                	sd	s0,16(sp)
    80003718:	e426                	sd	s1,8(sp)
    8000371a:	1000                	addi	s0,sp,32
    8000371c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000371e:	00000097          	auipc	ra,0x0
    80003722:	ebc080e7          	jalr	-324(ra) # 800035da <argraw>
    80003726:	e088                	sd	a0,0(s1)
}
    80003728:	60e2                	ld	ra,24(sp)
    8000372a:	6442                	ld	s0,16(sp)
    8000372c:	64a2                	ld	s1,8(sp)
    8000372e:	6105                	addi	sp,sp,32
    80003730:	8082                	ret

0000000080003732 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003732:	1101                	addi	sp,sp,-32
    80003734:	ec06                	sd	ra,24(sp)
    80003736:	e822                	sd	s0,16(sp)
    80003738:	e426                	sd	s1,8(sp)
    8000373a:	e04a                	sd	s2,0(sp)
    8000373c:	1000                	addi	s0,sp,32
    8000373e:	84ae                	mv	s1,a1
    80003740:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003742:	00000097          	auipc	ra,0x0
    80003746:	e98080e7          	jalr	-360(ra) # 800035da <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000374a:	864a                	mv	a2,s2
    8000374c:	85a6                	mv	a1,s1
    8000374e:	00000097          	auipc	ra,0x0
    80003752:	f56080e7          	jalr	-170(ra) # 800036a4 <fetchstr>
}
    80003756:	60e2                	ld	ra,24(sp)
    80003758:	6442                	ld	s0,16(sp)
    8000375a:	64a2                	ld	s1,8(sp)
    8000375c:	6902                	ld	s2,0(sp)
    8000375e:	6105                	addi	sp,sp,32
    80003760:	8082                	ret

0000000080003762 <syscall>:
    [SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80003762:	7179                	addi	sp,sp,-48
    80003764:	f406                	sd	ra,40(sp)
    80003766:	f022                	sd	s0,32(sp)
    80003768:	ec26                	sd	s1,24(sp)
    8000376a:	e84a                	sd	s2,16(sp)
    8000376c:	e44e                	sd	s3,8(sp)
    8000376e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003770:	ffffe097          	auipc	ra,0xffffe
    80003774:	70e080e7          	jalr	1806(ra) # 80001e7e <myproc>
    80003778:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000377a:	23053983          	ld	s3,560(a0)
    8000377e:	0a89a903          	lw	s2,168(s3)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003782:	fff9071b          	addiw	a4,s2,-1
    80003786:	47e5                	li	a5,25
    80003788:	02e7ec63          	bltu	a5,a4,800037c0 <syscall+0x5e>
    8000378c:	e052                	sd	s4,0(sp)
    8000378e:	00391713          	slli	a4,s2,0x3
    80003792:	00006797          	auipc	a5,0x6
    80003796:	07678793          	addi	a5,a5,118 # 80009808 <syscalls>
    8000379a:	97ba                	add	a5,a5,a4
    8000379c:	639c                	ld	a5,0(a5)
    8000379e:	c385                	beqz	a5,800037be <syscall+0x5c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800037a0:	9782                	jalr	a5
    800037a2:	06a9b823          	sd	a0,112(s3)
    if(num<26 && num>=0)
    800037a6:	47e5                	li	a5,25
    800037a8:	0527e363          	bltu	a5,s2,800037ee <syscall+0x8c>
    {
      p->syscall_count[num]++;
    800037ac:	090a                	slli	s2,s2,0x2
    800037ae:	9926                	add	s2,s2,s1
    800037b0:	04092783          	lw	a5,64(s2)
    800037b4:	2785                	addiw	a5,a5,1
    800037b6:	04f92023          	sw	a5,64(s2)
    800037ba:	6a02                	ld	s4,0(sp)
    800037bc:	a015                	j	800037e0 <syscall+0x7e>
    800037be:	6a02                	ld	s4,0(sp)
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    800037c0:	86ca                	mv	a3,s2
    800037c2:	33048613          	addi	a2,s1,816
    800037c6:	588c                	lw	a1,48(s1)
    800037c8:	00006517          	auipc	a0,0x6
    800037cc:	c8050513          	addi	a0,a0,-896 # 80009448 <etext+0x448>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	dda080e7          	jalr	-550(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800037d8:	2304b783          	ld	a5,560(s1)
    800037dc:	577d                	li	a4,-1
    800037de:	fbb8                	sd	a4,112(a5)
  }
}
    800037e0:	70a2                	ld	ra,40(sp)
    800037e2:	7402                	ld	s0,32(sp)
    800037e4:	64e2                	ld	s1,24(sp)
    800037e6:	6942                	ld	s2,16(sp)
    800037e8:	69a2                	ld	s3,8(sp)
    800037ea:	6145                	addi	sp,sp,48
    800037ec:	8082                	ret
    800037ee:	6a02                	ld	s4,0(sp)
    800037f0:	bfc5                	j	800037e0 <syscall+0x7e>

00000000800037f2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800037f2:	1101                	addi	sp,sp,-32
    800037f4:	ec06                	sd	ra,24(sp)
    800037f6:	e822                	sd	s0,16(sp)
    800037f8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800037fa:	fec40593          	addi	a1,s0,-20
    800037fe:	4501                	li	a0,0
    80003800:	00000097          	auipc	ra,0x0
    80003804:	ef2080e7          	jalr	-270(ra) # 800036f2 <argint>
  exit(n);
    80003808:	fec42503          	lw	a0,-20(s0)
    8000380c:	fffff097          	auipc	ra,0xfffff
    80003810:	272080e7          	jalr	626(ra) # 80002a7e <exit>
  return 0; // not reached
}
    80003814:	4501                	li	a0,0
    80003816:	60e2                	ld	ra,24(sp)
    80003818:	6442                	ld	s0,16(sp)
    8000381a:	6105                	addi	sp,sp,32
    8000381c:	8082                	ret

000000008000381e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000381e:	1141                	addi	sp,sp,-16
    80003820:	e406                	sd	ra,8(sp)
    80003822:	e022                	sd	s0,0(sp)
    80003824:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003826:	ffffe097          	auipc	ra,0xffffe
    8000382a:	658080e7          	jalr	1624(ra) # 80001e7e <myproc>
}
    8000382e:	5908                	lw	a0,48(a0)
    80003830:	60a2                	ld	ra,8(sp)
    80003832:	6402                	ld	s0,0(sp)
    80003834:	0141                	addi	sp,sp,16
    80003836:	8082                	ret

0000000080003838 <sys_fork>:

uint64
sys_fork(void)
{
    80003838:	1141                	addi	sp,sp,-16
    8000383a:	e406                	sd	ra,8(sp)
    8000383c:	e022                	sd	s0,0(sp)
    8000383e:	0800                	addi	s0,sp,16
  return fork();
    80003840:	fffff097          	auipc	ra,0xfffff
    80003844:	a6e080e7          	jalr	-1426(ra) # 800022ae <fork>
}
    80003848:	60a2                	ld	ra,8(sp)
    8000384a:	6402                	ld	s0,0(sp)
    8000384c:	0141                	addi	sp,sp,16
    8000384e:	8082                	ret

0000000080003850 <sys_wait>:

uint64
sys_wait(void)
{
    80003850:	1101                	addi	sp,sp,-32
    80003852:	ec06                	sd	ra,24(sp)
    80003854:	e822                	sd	s0,16(sp)
    80003856:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003858:	fe840593          	addi	a1,s0,-24
    8000385c:	4501                	li	a0,0
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	eb4080e7          	jalr	-332(ra) # 80003712 <argaddr>
  return wait(p);
    80003866:	fe843503          	ld	a0,-24(s0)
    8000386a:	fffff097          	auipc	ra,0xfffff
    8000386e:	3d4080e7          	jalr	980(ra) # 80002c3e <wait>
}
    80003872:	60e2                	ld	ra,24(sp)
    80003874:	6442                	ld	s0,16(sp)
    80003876:	6105                	addi	sp,sp,32
    80003878:	8082                	ret

000000008000387a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000387a:	7179                	addi	sp,sp,-48
    8000387c:	f406                	sd	ra,40(sp)
    8000387e:	f022                	sd	s0,32(sp)
    80003880:	ec26                	sd	s1,24(sp)
    80003882:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003884:	fdc40593          	addi	a1,s0,-36
    80003888:	4501                	li	a0,0
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	e68080e7          	jalr	-408(ra) # 800036f2 <argint>
  addr = myproc()->sz;
    80003892:	ffffe097          	auipc	ra,0xffffe
    80003896:	5ec080e7          	jalr	1516(ra) # 80001e7e <myproc>
    8000389a:	22053483          	ld	s1,544(a0)
  if (growproc(n) < 0)
    8000389e:	fdc42503          	lw	a0,-36(s0)
    800038a2:	fffff097          	auipc	ra,0xfffff
    800038a6:	9a8080e7          	jalr	-1624(ra) # 8000224a <growproc>
    800038aa:	00054863          	bltz	a0,800038ba <sys_sbrk+0x40>
    return -1;
  return addr;
}
    800038ae:	8526                	mv	a0,s1
    800038b0:	70a2                	ld	ra,40(sp)
    800038b2:	7402                	ld	s0,32(sp)
    800038b4:	64e2                	ld	s1,24(sp)
    800038b6:	6145                	addi	sp,sp,48
    800038b8:	8082                	ret
    return -1;
    800038ba:	54fd                	li	s1,-1
    800038bc:	bfcd                	j	800038ae <sys_sbrk+0x34>

00000000800038be <sys_sleep>:

uint64
sys_sleep(void)
{
    800038be:	7139                	addi	sp,sp,-64
    800038c0:	fc06                	sd	ra,56(sp)
    800038c2:	f822                	sd	s0,48(sp)
    800038c4:	f04a                	sd	s2,32(sp)
    800038c6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800038c8:	fcc40593          	addi	a1,s0,-52
    800038cc:	4501                	li	a0,0
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	e24080e7          	jalr	-476(ra) # 800036f2 <argint>
  acquire(&tickslock);
    800038d6:	0023c517          	auipc	a0,0x23c
    800038da:	36250513          	addi	a0,a0,866 # 8023fc38 <tickslock>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	4d2080e7          	jalr	1234(ra) # 80000db0 <acquire>
  ticks0 = ticks;
    800038e6:	00006917          	auipc	s2,0x6
    800038ea:	08e92903          	lw	s2,142(s2) # 80009974 <ticks>
  while (ticks - ticks0 < n)
    800038ee:	fcc42783          	lw	a5,-52(s0)
    800038f2:	c3b9                	beqz	a5,80003938 <sys_sleep+0x7a>
    800038f4:	f426                	sd	s1,40(sp)
    800038f6:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800038f8:	0023c997          	auipc	s3,0x23c
    800038fc:	34098993          	addi	s3,s3,832 # 8023fc38 <tickslock>
    80003900:	00006497          	auipc	s1,0x6
    80003904:	07448493          	addi	s1,s1,116 # 80009974 <ticks>
    if (killed(myproc()))
    80003908:	ffffe097          	auipc	ra,0xffffe
    8000390c:	576080e7          	jalr	1398(ra) # 80001e7e <myproc>
    80003910:	fffff097          	auipc	ra,0xfffff
    80003914:	2fc080e7          	jalr	764(ra) # 80002c0c <killed>
    80003918:	ed15                	bnez	a0,80003954 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000391a:	85ce                	mv	a1,s3
    8000391c:	8526                	mv	a0,s1
    8000391e:	fffff097          	auipc	ra,0xfffff
    80003922:	01e080e7          	jalr	30(ra) # 8000293c <sleep>
  while (ticks - ticks0 < n)
    80003926:	409c                	lw	a5,0(s1)
    80003928:	412787bb          	subw	a5,a5,s2
    8000392c:	fcc42703          	lw	a4,-52(s0)
    80003930:	fce7ece3          	bltu	a5,a4,80003908 <sys_sleep+0x4a>
    80003934:	74a2                	ld	s1,40(sp)
    80003936:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003938:	0023c517          	auipc	a0,0x23c
    8000393c:	30050513          	addi	a0,a0,768 # 8023fc38 <tickslock>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	520080e7          	jalr	1312(ra) # 80000e60 <release>
  return 0;
    80003948:	4501                	li	a0,0
}
    8000394a:	70e2                	ld	ra,56(sp)
    8000394c:	7442                	ld	s0,48(sp)
    8000394e:	7902                	ld	s2,32(sp)
    80003950:	6121                	addi	sp,sp,64
    80003952:	8082                	ret
      release(&tickslock);
    80003954:	0023c517          	auipc	a0,0x23c
    80003958:	2e450513          	addi	a0,a0,740 # 8023fc38 <tickslock>
    8000395c:	ffffd097          	auipc	ra,0xffffd
    80003960:	504080e7          	jalr	1284(ra) # 80000e60 <release>
      return -1;
    80003964:	557d                	li	a0,-1
    80003966:	74a2                	ld	s1,40(sp)
    80003968:	69e2                	ld	s3,24(sp)
    8000396a:	b7c5                	j	8000394a <sys_sleep+0x8c>

000000008000396c <sys_kill>:

uint64
sys_kill(void)
{
    8000396c:	1101                	addi	sp,sp,-32
    8000396e:	ec06                	sd	ra,24(sp)
    80003970:	e822                	sd	s0,16(sp)
    80003972:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003974:	fec40593          	addi	a1,s0,-20
    80003978:	4501                	li	a0,0
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	d78080e7          	jalr	-648(ra) # 800036f2 <argint>
  return kill(pid);
    80003982:	fec42503          	lw	a0,-20(s0)
    80003986:	fffff097          	auipc	ra,0xfffff
    8000398a:	1da080e7          	jalr	474(ra) # 80002b60 <kill>
}
    8000398e:	60e2                	ld	ra,24(sp)
    80003990:	6442                	ld	s0,16(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret

0000000080003996 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003996:	1101                	addi	sp,sp,-32
    80003998:	ec06                	sd	ra,24(sp)
    8000399a:	e822                	sd	s0,16(sp)
    8000399c:	e426                	sd	s1,8(sp)
    8000399e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800039a0:	0023c517          	auipc	a0,0x23c
    800039a4:	29850513          	addi	a0,a0,664 # 8023fc38 <tickslock>
    800039a8:	ffffd097          	auipc	ra,0xffffd
    800039ac:	408080e7          	jalr	1032(ra) # 80000db0 <acquire>
  xticks = ticks;
    800039b0:	00006497          	auipc	s1,0x6
    800039b4:	fc44a483          	lw	s1,-60(s1) # 80009974 <ticks>
  release(&tickslock);
    800039b8:	0023c517          	auipc	a0,0x23c
    800039bc:	28050513          	addi	a0,a0,640 # 8023fc38 <tickslock>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	4a0080e7          	jalr	1184(ra) # 80000e60 <release>
  return xticks;
}
    800039c8:	02049513          	slli	a0,s1,0x20
    800039cc:	9101                	srli	a0,a0,0x20
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	64a2                	ld	s1,8(sp)
    800039d4:	6105                	addi	sp,sp,32
    800039d6:	8082                	ret

00000000800039d8 <sys_waitx>:

uint64
sys_waitx(void)
{
    800039d8:	715d                	addi	sp,sp,-80
    800039da:	e486                	sd	ra,72(sp)
    800039dc:	e0a2                	sd	s0,64(sp)
    800039de:	fc26                	sd	s1,56(sp)
    800039e0:	f84a                	sd	s2,48(sp)
    800039e2:	f44e                	sd	s3,40(sp)
    800039e4:	0880                	addi	s0,sp,80
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800039e6:	fc840593          	addi	a1,s0,-56
    800039ea:	4501                	li	a0,0
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	d26080e7          	jalr	-730(ra) # 80003712 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800039f4:	fc040593          	addi	a1,s0,-64
    800039f8:	4505                	li	a0,1
    800039fa:	00000097          	auipc	ra,0x0
    800039fe:	d18080e7          	jalr	-744(ra) # 80003712 <argaddr>
  argaddr(2, &addr2);
    80003a02:	fb840593          	addi	a1,s0,-72
    80003a06:	4509                	li	a0,2
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	d0a080e7          	jalr	-758(ra) # 80003712 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003a10:	fb440993          	addi	s3,s0,-76
    80003a14:	fb040613          	addi	a2,s0,-80
    80003a18:	85ce                	mv	a1,s3
    80003a1a:	fc843503          	ld	a0,-56(s0)
    80003a1e:	fffff097          	auipc	ra,0xfffff
    80003a22:	4c8080e7          	jalr	1224(ra) # 80002ee6 <waitx>
    80003a26:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003a28:	ffffe097          	auipc	ra,0xffffe
    80003a2c:	456080e7          	jalr	1110(ra) # 80001e7e <myproc>
    80003a30:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003a32:	4691                	li	a3,4
    80003a34:	864e                	mv	a2,s3
    80003a36:	fc043583          	ld	a1,-64(s0)
    80003a3a:	22853503          	ld	a0,552(a0)
    80003a3e:	ffffe097          	auipc	ra,0xffffe
    80003a42:	f34080e7          	jalr	-204(ra) # 80001972 <copyout>
    return -1;
    80003a46:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003a48:	02054063          	bltz	a0,80003a68 <sys_waitx+0x90>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003a4c:	4691                	li	a3,4
    80003a4e:	fb040613          	addi	a2,s0,-80
    80003a52:	fb843583          	ld	a1,-72(s0)
    80003a56:	2284b503          	ld	a0,552(s1)
    80003a5a:	ffffe097          	auipc	ra,0xffffe
    80003a5e:	f18080e7          	jalr	-232(ra) # 80001972 <copyout>
    80003a62:	00054b63          	bltz	a0,80003a78 <sys_waitx+0xa0>
    return -1;
  return ret;
    80003a66:	87ca                	mv	a5,s2
}
    80003a68:	853e                	mv	a0,a5
    80003a6a:	60a6                	ld	ra,72(sp)
    80003a6c:	6406                	ld	s0,64(sp)
    80003a6e:	74e2                	ld	s1,56(sp)
    80003a70:	7942                	ld	s2,48(sp)
    80003a72:	79a2                	ld	s3,40(sp)
    80003a74:	6161                	addi	sp,sp,80
    80003a76:	8082                	ret
    return -1;
    80003a78:	57fd                	li	a5,-1
    80003a7a:	b7fd                	j	80003a68 <sys_waitx+0x90>

0000000080003a7c <sys_getSysCount>:

uint64
sys_getSysCount(void)
{
    80003a7c:	1101                	addi	sp,sp,-32
    80003a7e:	ec06                	sd	ra,24(sp)
    80003a80:	e822                	sd	s0,16(sp)
    80003a82:	1000                	addi	s0,sp,32
  int k;
  argint(0, &k);
    80003a84:	fec40593          	addi	a1,s0,-20
    80003a88:	4501                	li	a0,0
    80003a8a:	00000097          	auipc	ra,0x0
    80003a8e:	c68080e7          	jalr	-920(ra) # 800036f2 <argint>
  struct proc *p = myproc();
    80003a92:	ffffe097          	auipc	ra,0xffffe
    80003a96:	3ec080e7          	jalr	1004(ra) # 80001e7e <myproc>
  return p->syscall_count[k];
    80003a9a:	fec42783          	lw	a5,-20(s0)
    80003a9e:	07c1                	addi	a5,a5,16
    80003aa0:	078a                	slli	a5,a5,0x2
    80003aa2:	953e                	add	a0,a0,a5
}
    80003aa4:	4108                	lw	a0,0(a0)
    80003aa6:	60e2                	ld	ra,24(sp)
    80003aa8:	6442                	ld	s0,16(sp)
    80003aaa:	6105                	addi	sp,sp,32
    80003aac:	8082                	ret

0000000080003aae <sys_sigalarm>:

// In sysproc.c
uint64 sys_sigalarm(void)
{
    80003aae:	1101                	addi	sp,sp,-32
    80003ab0:	ec06                	sd	ra,24(sp)
    80003ab2:	e822                	sd	s0,16(sp)
    80003ab4:	1000                	addi	s0,sp,32
  int interval;
  argint(0, &interval);
    80003ab6:	fec40593          	addi	a1,s0,-20
    80003aba:	4501                	li	a0,0
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	c36080e7          	jalr	-970(ra) # 800036f2 <argint>
  uint64 handler;
  argaddr(1, &handler);
    80003ac4:	fe040593          	addi	a1,s0,-32
    80003ac8:	4505                	li	a0,1
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	c48080e7          	jalr	-952(ra) # 80003712 <argaddr>
  struct proc *p = myproc();
    80003ad2:	ffffe097          	auipc	ra,0xffffe
    80003ad6:	3ac080e7          	jalr	940(ra) # 80001e7e <myproc>
  p->alarm_interval = interval;
    80003ada:	fec42783          	lw	a5,-20(s0)
    80003ade:	0ef52223          	sw	a5,228(a0)
  p->handler = handler;
    80003ae2:	fe043783          	ld	a5,-32(s0)
    80003ae6:	f57c                	sd	a5,232(a0)
  p->ticks = 0;
    80003ae8:	0e052023          	sw	zero,224(a0)
  p->alarm_active = 0;
    80003aec:	20052823          	sw	zero,528(a0)
  // printf("gg");
  return 0;
}
    80003af0:	4501                	li	a0,0
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	6105                	addi	sp,sp,32
    80003af8:	8082                	ret

0000000080003afa <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    80003afa:	1101                	addi	sp,sp,-32
    80003afc:	ec06                	sd	ra,24(sp)
    80003afe:	e822                	sd	s0,16(sp)
    80003b00:	e426                	sd	s1,8(sp)
    80003b02:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003b04:	ffffe097          	auipc	ra,0xffffe
    80003b08:	37a080e7          	jalr	890(ra) # 80001e7e <myproc>
    80003b0c:	84aa                	mv	s1,a0
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe));
    80003b0e:	12000613          	li	a2,288
    80003b12:	0f050593          	addi	a1,a0,240
    80003b16:	23053503          	ld	a0,560(a0)
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	3f2080e7          	jalr	1010(ra) # 80000f0c <memmove>
  p->alarm_active = 0;
    80003b22:	2004a823          	sw	zero,528(s1)
  return p->trapframe->a0;
    80003b26:	2304b783          	ld	a5,560(s1)
}
    80003b2a:	7ba8                	ld	a0,112(a5)
    80003b2c:	60e2                	ld	ra,24(sp)
    80003b2e:	6442                	ld	s0,16(sp)
    80003b30:	64a2                	ld	s1,8(sp)
    80003b32:	6105                	addi	sp,sp,32
    80003b34:	8082                	ret

0000000080003b36 <sys_settickets>:

uint64
sys_settickets(void)
{
    80003b36:	1101                	addi	sp,sp,-32
    80003b38:	ec06                	sd	ra,24(sp)
    80003b3a:	e822                	sd	s0,16(sp)
    80003b3c:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    80003b3e:	fec40593          	addi	a1,s0,-20
    80003b42:	4501                	li	a0,0
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	bae080e7          	jalr	-1106(ra) # 800036f2 <argint>
  if (number < 1)
    80003b4c:	fec42783          	lw	a5,-20(s0)
    return -1;
    80003b50:	557d                	li	a0,-1
  if (number < 1)
    80003b52:	00f05b63          	blez	a5,80003b68 <sys_settickets+0x32>
  struct proc *p = myproc();
    80003b56:	ffffe097          	auipc	ra,0xffffe
    80003b5a:	328080e7          	jalr	808(ra) # 80001e7e <myproc>
  p->tickets = number;
    80003b5e:	fec42783          	lw	a5,-20(s0)
    80003b62:	0cf52023          	sw	a5,192(a0)
  return 0;
    80003b66:	4501                	li	a0,0
    80003b68:	60e2                	ld	ra,24(sp)
    80003b6a:	6442                	ld	s0,16(sp)
    80003b6c:	6105                	addi	sp,sp,32
    80003b6e:	8082                	ret

0000000080003b70 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003b70:	7179                	addi	sp,sp,-48
    80003b72:	f406                	sd	ra,40(sp)
    80003b74:	f022                	sd	s0,32(sp)
    80003b76:	ec26                	sd	s1,24(sp)
    80003b78:	e84a                	sd	s2,16(sp)
    80003b7a:	e44e                	sd	s3,8(sp)
    80003b7c:	e052                	sd	s4,0(sp)
    80003b7e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003b80:	00006597          	auipc	a1,0x6
    80003b84:	8e858593          	addi	a1,a1,-1816 # 80009468 <etext+0x468>
    80003b88:	0023c517          	auipc	a0,0x23c
    80003b8c:	0c850513          	addi	a0,a0,200 # 8023fc50 <bcache>
    80003b90:	ffffd097          	auipc	ra,0xffffd
    80003b94:	18c080e7          	jalr	396(ra) # 80000d1c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003b98:	00244797          	auipc	a5,0x244
    80003b9c:	0b878793          	addi	a5,a5,184 # 80247c50 <bcache+0x8000>
    80003ba0:	00244717          	auipc	a4,0x244
    80003ba4:	31870713          	addi	a4,a4,792 # 80247eb8 <bcache+0x8268>
    80003ba8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003bac:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003bb0:	0023c497          	auipc	s1,0x23c
    80003bb4:	0b848493          	addi	s1,s1,184 # 8023fc68 <bcache+0x18>
    b->next = bcache.head.next;
    80003bb8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003bba:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003bbc:	00006a17          	auipc	s4,0x6
    80003bc0:	8b4a0a13          	addi	s4,s4,-1868 # 80009470 <etext+0x470>
    b->next = bcache.head.next;
    80003bc4:	2b893783          	ld	a5,696(s2)
    80003bc8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003bca:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003bce:	85d2                	mv	a1,s4
    80003bd0:	01048513          	addi	a0,s1,16
    80003bd4:	00001097          	auipc	ra,0x1
    80003bd8:	4e4080e7          	jalr	1252(ra) # 800050b8 <initsleeplock>
    bcache.head.next->prev = b;
    80003bdc:	2b893783          	ld	a5,696(s2)
    80003be0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003be2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003be6:	45848493          	addi	s1,s1,1112
    80003bea:	fd349de3          	bne	s1,s3,80003bc4 <binit+0x54>
  }
}
    80003bee:	70a2                	ld	ra,40(sp)
    80003bf0:	7402                	ld	s0,32(sp)
    80003bf2:	64e2                	ld	s1,24(sp)
    80003bf4:	6942                	ld	s2,16(sp)
    80003bf6:	69a2                	ld	s3,8(sp)
    80003bf8:	6a02                	ld	s4,0(sp)
    80003bfa:	6145                	addi	sp,sp,48
    80003bfc:	8082                	ret

0000000080003bfe <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003bfe:	7179                	addi	sp,sp,-48
    80003c00:	f406                	sd	ra,40(sp)
    80003c02:	f022                	sd	s0,32(sp)
    80003c04:	ec26                	sd	s1,24(sp)
    80003c06:	e84a                	sd	s2,16(sp)
    80003c08:	e44e                	sd	s3,8(sp)
    80003c0a:	1800                	addi	s0,sp,48
    80003c0c:	892a                	mv	s2,a0
    80003c0e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003c10:	0023c517          	auipc	a0,0x23c
    80003c14:	04050513          	addi	a0,a0,64 # 8023fc50 <bcache>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	198080e7          	jalr	408(ra) # 80000db0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003c20:	00244497          	auipc	s1,0x244
    80003c24:	2e84b483          	ld	s1,744(s1) # 80247f08 <bcache+0x82b8>
    80003c28:	00244797          	auipc	a5,0x244
    80003c2c:	29078793          	addi	a5,a5,656 # 80247eb8 <bcache+0x8268>
    80003c30:	02f48f63          	beq	s1,a5,80003c6e <bread+0x70>
    80003c34:	873e                	mv	a4,a5
    80003c36:	a021                	j	80003c3e <bread+0x40>
    80003c38:	68a4                	ld	s1,80(s1)
    80003c3a:	02e48a63          	beq	s1,a4,80003c6e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003c3e:	449c                	lw	a5,8(s1)
    80003c40:	ff279ce3          	bne	a5,s2,80003c38 <bread+0x3a>
    80003c44:	44dc                	lw	a5,12(s1)
    80003c46:	ff3799e3          	bne	a5,s3,80003c38 <bread+0x3a>
      b->refcnt++;
    80003c4a:	40bc                	lw	a5,64(s1)
    80003c4c:	2785                	addiw	a5,a5,1
    80003c4e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003c50:	0023c517          	auipc	a0,0x23c
    80003c54:	00050513          	mv	a0,a0
    80003c58:	ffffd097          	auipc	ra,0xffffd
    80003c5c:	208080e7          	jalr	520(ra) # 80000e60 <release>
      acquiresleep(&b->lock);
    80003c60:	01048513          	addi	a0,s1,16
    80003c64:	00001097          	auipc	ra,0x1
    80003c68:	48e080e7          	jalr	1166(ra) # 800050f2 <acquiresleep>
      return b;
    80003c6c:	a8b9                	j	80003cca <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003c6e:	00244497          	auipc	s1,0x244
    80003c72:	2924b483          	ld	s1,658(s1) # 80247f00 <bcache+0x82b0>
    80003c76:	00244797          	auipc	a5,0x244
    80003c7a:	24278793          	addi	a5,a5,578 # 80247eb8 <bcache+0x8268>
    80003c7e:	00f48863          	beq	s1,a5,80003c8e <bread+0x90>
    80003c82:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003c84:	40bc                	lw	a5,64(s1)
    80003c86:	cf81                	beqz	a5,80003c9e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003c88:	64a4                	ld	s1,72(s1)
    80003c8a:	fee49de3          	bne	s1,a4,80003c84 <bread+0x86>
  panic("bget: no buffers");
    80003c8e:	00005517          	auipc	a0,0x5
    80003c92:	7ea50513          	addi	a0,a0,2026 # 80009478 <etext+0x478>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	8ca080e7          	jalr	-1846(ra) # 80000560 <panic>
      b->dev = dev;
    80003c9e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003ca2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003ca6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003caa:	4785                	li	a5,1
    80003cac:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003cae:	0023c517          	auipc	a0,0x23c
    80003cb2:	fa250513          	addi	a0,a0,-94 # 8023fc50 <bcache>
    80003cb6:	ffffd097          	auipc	ra,0xffffd
    80003cba:	1aa080e7          	jalr	426(ra) # 80000e60 <release>
      acquiresleep(&b->lock);
    80003cbe:	01048513          	addi	a0,s1,16
    80003cc2:	00001097          	auipc	ra,0x1
    80003cc6:	430080e7          	jalr	1072(ra) # 800050f2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003cca:	409c                	lw	a5,0(s1)
    80003ccc:	cb89                	beqz	a5,80003cde <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003cce:	8526                	mv	a0,s1
    80003cd0:	70a2                	ld	ra,40(sp)
    80003cd2:	7402                	ld	s0,32(sp)
    80003cd4:	64e2                	ld	s1,24(sp)
    80003cd6:	6942                	ld	s2,16(sp)
    80003cd8:	69a2                	ld	s3,8(sp)
    80003cda:	6145                	addi	sp,sp,48
    80003cdc:	8082                	ret
    virtio_disk_rw(b, 0);
    80003cde:	4581                	li	a1,0
    80003ce0:	8526                	mv	a0,s1
    80003ce2:	00003097          	auipc	ra,0x3
    80003ce6:	116080e7          	jalr	278(ra) # 80006df8 <virtio_disk_rw>
    b->valid = 1;
    80003cea:	4785                	li	a5,1
    80003cec:	c09c                	sw	a5,0(s1)
  return b;
    80003cee:	b7c5                	j	80003cce <bread+0xd0>

0000000080003cf0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003cf0:	1101                	addi	sp,sp,-32
    80003cf2:	ec06                	sd	ra,24(sp)
    80003cf4:	e822                	sd	s0,16(sp)
    80003cf6:	e426                	sd	s1,8(sp)
    80003cf8:	1000                	addi	s0,sp,32
    80003cfa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003cfc:	0541                	addi	a0,a0,16
    80003cfe:	00001097          	auipc	ra,0x1
    80003d02:	48e080e7          	jalr	1166(ra) # 8000518c <holdingsleep>
    80003d06:	cd01                	beqz	a0,80003d1e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003d08:	4585                	li	a1,1
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	00003097          	auipc	ra,0x3
    80003d10:	0ec080e7          	jalr	236(ra) # 80006df8 <virtio_disk_rw>
}
    80003d14:	60e2                	ld	ra,24(sp)
    80003d16:	6442                	ld	s0,16(sp)
    80003d18:	64a2                	ld	s1,8(sp)
    80003d1a:	6105                	addi	sp,sp,32
    80003d1c:	8082                	ret
    panic("bwrite");
    80003d1e:	00005517          	auipc	a0,0x5
    80003d22:	77250513          	addi	a0,a0,1906 # 80009490 <etext+0x490>
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	83a080e7          	jalr	-1990(ra) # 80000560 <panic>

0000000080003d2e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003d2e:	1101                	addi	sp,sp,-32
    80003d30:	ec06                	sd	ra,24(sp)
    80003d32:	e822                	sd	s0,16(sp)
    80003d34:	e426                	sd	s1,8(sp)
    80003d36:	e04a                	sd	s2,0(sp)
    80003d38:	1000                	addi	s0,sp,32
    80003d3a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003d3c:	01050913          	addi	s2,a0,16
    80003d40:	854a                	mv	a0,s2
    80003d42:	00001097          	auipc	ra,0x1
    80003d46:	44a080e7          	jalr	1098(ra) # 8000518c <holdingsleep>
    80003d4a:	c535                	beqz	a0,80003db6 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    80003d4c:	854a                	mv	a0,s2
    80003d4e:	00001097          	auipc	ra,0x1
    80003d52:	3fa080e7          	jalr	1018(ra) # 80005148 <releasesleep>

  acquire(&bcache.lock);
    80003d56:	0023c517          	auipc	a0,0x23c
    80003d5a:	efa50513          	addi	a0,a0,-262 # 8023fc50 <bcache>
    80003d5e:	ffffd097          	auipc	ra,0xffffd
    80003d62:	052080e7          	jalr	82(ra) # 80000db0 <acquire>
  b->refcnt--;
    80003d66:	40bc                	lw	a5,64(s1)
    80003d68:	37fd                	addiw	a5,a5,-1
    80003d6a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003d6c:	e79d                	bnez	a5,80003d9a <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003d6e:	68b8                	ld	a4,80(s1)
    80003d70:	64bc                	ld	a5,72(s1)
    80003d72:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003d74:	68b8                	ld	a4,80(s1)
    80003d76:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003d78:	00244797          	auipc	a5,0x244
    80003d7c:	ed878793          	addi	a5,a5,-296 # 80247c50 <bcache+0x8000>
    80003d80:	2b87b703          	ld	a4,696(a5)
    80003d84:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003d86:	00244717          	auipc	a4,0x244
    80003d8a:	13270713          	addi	a4,a4,306 # 80247eb8 <bcache+0x8268>
    80003d8e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003d90:	2b87b703          	ld	a4,696(a5)
    80003d94:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003d96:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003d9a:	0023c517          	auipc	a0,0x23c
    80003d9e:	eb650513          	addi	a0,a0,-330 # 8023fc50 <bcache>
    80003da2:	ffffd097          	auipc	ra,0xffffd
    80003da6:	0be080e7          	jalr	190(ra) # 80000e60 <release>
}
    80003daa:	60e2                	ld	ra,24(sp)
    80003dac:	6442                	ld	s0,16(sp)
    80003dae:	64a2                	ld	s1,8(sp)
    80003db0:	6902                	ld	s2,0(sp)
    80003db2:	6105                	addi	sp,sp,32
    80003db4:	8082                	ret
    panic("brelse");
    80003db6:	00005517          	auipc	a0,0x5
    80003dba:	6e250513          	addi	a0,a0,1762 # 80009498 <etext+0x498>
    80003dbe:	ffffc097          	auipc	ra,0xffffc
    80003dc2:	7a2080e7          	jalr	1954(ra) # 80000560 <panic>

0000000080003dc6 <bpin>:

void
bpin(struct buf *b) {
    80003dc6:	1101                	addi	sp,sp,-32
    80003dc8:	ec06                	sd	ra,24(sp)
    80003dca:	e822                	sd	s0,16(sp)
    80003dcc:	e426                	sd	s1,8(sp)
    80003dce:	1000                	addi	s0,sp,32
    80003dd0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003dd2:	0023c517          	auipc	a0,0x23c
    80003dd6:	e7e50513          	addi	a0,a0,-386 # 8023fc50 <bcache>
    80003dda:	ffffd097          	auipc	ra,0xffffd
    80003dde:	fd6080e7          	jalr	-42(ra) # 80000db0 <acquire>
  b->refcnt++;
    80003de2:	40bc                	lw	a5,64(s1)
    80003de4:	2785                	addiw	a5,a5,1
    80003de6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003de8:	0023c517          	auipc	a0,0x23c
    80003dec:	e6850513          	addi	a0,a0,-408 # 8023fc50 <bcache>
    80003df0:	ffffd097          	auipc	ra,0xffffd
    80003df4:	070080e7          	jalr	112(ra) # 80000e60 <release>
}
    80003df8:	60e2                	ld	ra,24(sp)
    80003dfa:	6442                	ld	s0,16(sp)
    80003dfc:	64a2                	ld	s1,8(sp)
    80003dfe:	6105                	addi	sp,sp,32
    80003e00:	8082                	ret

0000000080003e02 <bunpin>:

void
bunpin(struct buf *b) {
    80003e02:	1101                	addi	sp,sp,-32
    80003e04:	ec06                	sd	ra,24(sp)
    80003e06:	e822                	sd	s0,16(sp)
    80003e08:	e426                	sd	s1,8(sp)
    80003e0a:	1000                	addi	s0,sp,32
    80003e0c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003e0e:	0023c517          	auipc	a0,0x23c
    80003e12:	e4250513          	addi	a0,a0,-446 # 8023fc50 <bcache>
    80003e16:	ffffd097          	auipc	ra,0xffffd
    80003e1a:	f9a080e7          	jalr	-102(ra) # 80000db0 <acquire>
  b->refcnt--;
    80003e1e:	40bc                	lw	a5,64(s1)
    80003e20:	37fd                	addiw	a5,a5,-1
    80003e22:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003e24:	0023c517          	auipc	a0,0x23c
    80003e28:	e2c50513          	addi	a0,a0,-468 # 8023fc50 <bcache>
    80003e2c:	ffffd097          	auipc	ra,0xffffd
    80003e30:	034080e7          	jalr	52(ra) # 80000e60 <release>
}
    80003e34:	60e2                	ld	ra,24(sp)
    80003e36:	6442                	ld	s0,16(sp)
    80003e38:	64a2                	ld	s1,8(sp)
    80003e3a:	6105                	addi	sp,sp,32
    80003e3c:	8082                	ret

0000000080003e3e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	e04a                	sd	s2,0(sp)
    80003e48:	1000                	addi	s0,sp,32
    80003e4a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003e4c:	00d5d79b          	srliw	a5,a1,0xd
    80003e50:	00244597          	auipc	a1,0x244
    80003e54:	4dc5a583          	lw	a1,1244(a1) # 8024832c <sb+0x1c>
    80003e58:	9dbd                	addw	a1,a1,a5
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	da4080e7          	jalr	-604(ra) # 80003bfe <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003e62:	0074f713          	andi	a4,s1,7
    80003e66:	4785                	li	a5,1
    80003e68:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003e6c:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003e6e:	90d9                	srli	s1,s1,0x36
    80003e70:	00950733          	add	a4,a0,s1
    80003e74:	05874703          	lbu	a4,88(a4)
    80003e78:	00e7f6b3          	and	a3,a5,a4
    80003e7c:	c69d                	beqz	a3,80003eaa <bfree+0x6c>
    80003e7e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003e80:	94aa                	add	s1,s1,a0
    80003e82:	fff7c793          	not	a5,a5
    80003e86:	8f7d                	and	a4,a4,a5
    80003e88:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003e8c:	00001097          	auipc	ra,0x1
    80003e90:	148080e7          	jalr	328(ra) # 80004fd4 <log_write>
  brelse(bp);
    80003e94:	854a                	mv	a0,s2
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	e98080e7          	jalr	-360(ra) # 80003d2e <brelse>
}
    80003e9e:	60e2                	ld	ra,24(sp)
    80003ea0:	6442                	ld	s0,16(sp)
    80003ea2:	64a2                	ld	s1,8(sp)
    80003ea4:	6902                	ld	s2,0(sp)
    80003ea6:	6105                	addi	sp,sp,32
    80003ea8:	8082                	ret
    panic("freeing free block");
    80003eaa:	00005517          	auipc	a0,0x5
    80003eae:	5f650513          	addi	a0,a0,1526 # 800094a0 <etext+0x4a0>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	6ae080e7          	jalr	1710(ra) # 80000560 <panic>

0000000080003eba <balloc>:
{
    80003eba:	715d                	addi	sp,sp,-80
    80003ebc:	e486                	sd	ra,72(sp)
    80003ebe:	e0a2                	sd	s0,64(sp)
    80003ec0:	fc26                	sd	s1,56(sp)
    80003ec2:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003ec4:	00244797          	auipc	a5,0x244
    80003ec8:	4507a783          	lw	a5,1104(a5) # 80248314 <sb+0x4>
    80003ecc:	10078863          	beqz	a5,80003fdc <balloc+0x122>
    80003ed0:	f84a                	sd	s2,48(sp)
    80003ed2:	f44e                	sd	s3,40(sp)
    80003ed4:	f052                	sd	s4,32(sp)
    80003ed6:	ec56                	sd	s5,24(sp)
    80003ed8:	e85a                	sd	s6,16(sp)
    80003eda:	e45e                	sd	s7,8(sp)
    80003edc:	e062                	sd	s8,0(sp)
    80003ede:	8baa                	mv	s7,a0
    80003ee0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003ee2:	00244b17          	auipc	s6,0x244
    80003ee6:	42eb0b13          	addi	s6,s6,1070 # 80248310 <sb>
      m = 1 << (bi % 8);
    80003eea:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003eec:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003eee:	6c09                	lui	s8,0x2
    80003ef0:	a049                	j	80003f72 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003ef2:	97ca                	add	a5,a5,s2
    80003ef4:	8e55                	or	a2,a2,a3
    80003ef6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003efa:	854a                	mv	a0,s2
    80003efc:	00001097          	auipc	ra,0x1
    80003f00:	0d8080e7          	jalr	216(ra) # 80004fd4 <log_write>
        brelse(bp);
    80003f04:	854a                	mv	a0,s2
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	e28080e7          	jalr	-472(ra) # 80003d2e <brelse>
  bp = bread(dev, bno);
    80003f0e:	85a6                	mv	a1,s1
    80003f10:	855e                	mv	a0,s7
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	cec080e7          	jalr	-788(ra) # 80003bfe <bread>
    80003f1a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003f1c:	40000613          	li	a2,1024
    80003f20:	4581                	li	a1,0
    80003f22:	05850513          	addi	a0,a0,88
    80003f26:	ffffd097          	auipc	ra,0xffffd
    80003f2a:	f82080e7          	jalr	-126(ra) # 80000ea8 <memset>
  log_write(bp);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	00001097          	auipc	ra,0x1
    80003f34:	0a4080e7          	jalr	164(ra) # 80004fd4 <log_write>
  brelse(bp);
    80003f38:	854a                	mv	a0,s2
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	df4080e7          	jalr	-524(ra) # 80003d2e <brelse>
}
    80003f42:	7942                	ld	s2,48(sp)
    80003f44:	79a2                	ld	s3,40(sp)
    80003f46:	7a02                	ld	s4,32(sp)
    80003f48:	6ae2                	ld	s5,24(sp)
    80003f4a:	6b42                	ld	s6,16(sp)
    80003f4c:	6ba2                	ld	s7,8(sp)
    80003f4e:	6c02                	ld	s8,0(sp)
}
    80003f50:	8526                	mv	a0,s1
    80003f52:	60a6                	ld	ra,72(sp)
    80003f54:	6406                	ld	s0,64(sp)
    80003f56:	74e2                	ld	s1,56(sp)
    80003f58:	6161                	addi	sp,sp,80
    80003f5a:	8082                	ret
    brelse(bp);
    80003f5c:	854a                	mv	a0,s2
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	dd0080e7          	jalr	-560(ra) # 80003d2e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003f66:	015c0abb          	addw	s5,s8,s5
    80003f6a:	004b2783          	lw	a5,4(s6)
    80003f6e:	06faf063          	bgeu	s5,a5,80003fce <balloc+0x114>
    bp = bread(dev, BBLOCK(b, sb));
    80003f72:	41fad79b          	sraiw	a5,s5,0x1f
    80003f76:	0137d79b          	srliw	a5,a5,0x13
    80003f7a:	015787bb          	addw	a5,a5,s5
    80003f7e:	40d7d79b          	sraiw	a5,a5,0xd
    80003f82:	01cb2583          	lw	a1,28(s6)
    80003f86:	9dbd                	addw	a1,a1,a5
    80003f88:	855e                	mv	a0,s7
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	c74080e7          	jalr	-908(ra) # 80003bfe <bread>
    80003f92:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003f94:	004b2503          	lw	a0,4(s6)
    80003f98:	84d6                	mv	s1,s5
    80003f9a:	4701                	li	a4,0
    80003f9c:	fca4f0e3          	bgeu	s1,a0,80003f5c <balloc+0xa2>
      m = 1 << (bi % 8);
    80003fa0:	00777693          	andi	a3,a4,7
    80003fa4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003fa8:	41f7579b          	sraiw	a5,a4,0x1f
    80003fac:	01d7d79b          	srliw	a5,a5,0x1d
    80003fb0:	9fb9                	addw	a5,a5,a4
    80003fb2:	4037d79b          	sraiw	a5,a5,0x3
    80003fb6:	00f90633          	add	a2,s2,a5
    80003fba:	05864603          	lbu	a2,88(a2)
    80003fbe:	00c6f5b3          	and	a1,a3,a2
    80003fc2:	d985                	beqz	a1,80003ef2 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003fc4:	2705                	addiw	a4,a4,1
    80003fc6:	2485                	addiw	s1,s1,1
    80003fc8:	fd471ae3          	bne	a4,s4,80003f9c <balloc+0xe2>
    80003fcc:	bf41                	j	80003f5c <balloc+0xa2>
    80003fce:	7942                	ld	s2,48(sp)
    80003fd0:	79a2                	ld	s3,40(sp)
    80003fd2:	7a02                	ld	s4,32(sp)
    80003fd4:	6ae2                	ld	s5,24(sp)
    80003fd6:	6b42                	ld	s6,16(sp)
    80003fd8:	6ba2                	ld	s7,8(sp)
    80003fda:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003fdc:	00005517          	auipc	a0,0x5
    80003fe0:	4dc50513          	addi	a0,a0,1244 # 800094b8 <etext+0x4b8>
    80003fe4:	ffffc097          	auipc	ra,0xffffc
    80003fe8:	5c6080e7          	jalr	1478(ra) # 800005aa <printf>
  return 0;
    80003fec:	4481                	li	s1,0
    80003fee:	b78d                	j	80003f50 <balloc+0x96>

0000000080003ff0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ff0:	7179                	addi	sp,sp,-48
    80003ff2:	f406                	sd	ra,40(sp)
    80003ff4:	f022                	sd	s0,32(sp)
    80003ff6:	ec26                	sd	s1,24(sp)
    80003ff8:	e84a                	sd	s2,16(sp)
    80003ffa:	e44e                	sd	s3,8(sp)
    80003ffc:	1800                	addi	s0,sp,48
    80003ffe:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004000:	47ad                	li	a5,11
    80004002:	02b7e563          	bltu	a5,a1,8000402c <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80004006:	02059793          	slli	a5,a1,0x20
    8000400a:	01e7d593          	srli	a1,a5,0x1e
    8000400e:	00b504b3          	add	s1,a0,a1
    80004012:	0504a903          	lw	s2,80(s1)
    80004016:	06091b63          	bnez	s2,8000408c <bmap+0x9c>
      addr = balloc(ip->dev);
    8000401a:	4108                	lw	a0,0(a0)
    8000401c:	00000097          	auipc	ra,0x0
    80004020:	e9e080e7          	jalr	-354(ra) # 80003eba <balloc>
    80004024:	892a                	mv	s2,a0
      if(addr == 0)
    80004026:	c13d                	beqz	a0,8000408c <bmap+0x9c>
        return 0;
      ip->addrs[bn] = addr;
    80004028:	c8a8                	sw	a0,80(s1)
    8000402a:	a08d                	j	8000408c <bmap+0x9c>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000402c:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80004030:	0ff00793          	li	a5,255
    80004034:	0897e363          	bltu	a5,s1,800040ba <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80004038:	08052903          	lw	s2,128(a0)
    8000403c:	00091d63          	bnez	s2,80004056 <bmap+0x66>
      addr = balloc(ip->dev);
    80004040:	4108                	lw	a0,0(a0)
    80004042:	00000097          	auipc	ra,0x0
    80004046:	e78080e7          	jalr	-392(ra) # 80003eba <balloc>
    8000404a:	892a                	mv	s2,a0
      if(addr == 0)
    8000404c:	c121                	beqz	a0,8000408c <bmap+0x9c>
    8000404e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80004050:	08a9a023          	sw	a0,128(s3)
    80004054:	a011                	j	80004058 <bmap+0x68>
    80004056:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80004058:	85ca                	mv	a1,s2
    8000405a:	0009a503          	lw	a0,0(s3)
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	ba0080e7          	jalr	-1120(ra) # 80003bfe <bread>
    80004066:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004068:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000406c:	02049713          	slli	a4,s1,0x20
    80004070:	01e75593          	srli	a1,a4,0x1e
    80004074:	00b784b3          	add	s1,a5,a1
    80004078:	0004a903          	lw	s2,0(s1)
    8000407c:	02090063          	beqz	s2,8000409c <bmap+0xac>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80004080:	8552                	mv	a0,s4
    80004082:	00000097          	auipc	ra,0x0
    80004086:	cac080e7          	jalr	-852(ra) # 80003d2e <brelse>
    return addr;
    8000408a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000408c:	854a                	mv	a0,s2
    8000408e:	70a2                	ld	ra,40(sp)
    80004090:	7402                	ld	s0,32(sp)
    80004092:	64e2                	ld	s1,24(sp)
    80004094:	6942                	ld	s2,16(sp)
    80004096:	69a2                	ld	s3,8(sp)
    80004098:	6145                	addi	sp,sp,48
    8000409a:	8082                	ret
      addr = balloc(ip->dev);
    8000409c:	0009a503          	lw	a0,0(s3)
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	e1a080e7          	jalr	-486(ra) # 80003eba <balloc>
    800040a8:	892a                	mv	s2,a0
      if(addr){
    800040aa:	d979                	beqz	a0,80004080 <bmap+0x90>
        a[bn] = addr;
    800040ac:	c088                	sw	a0,0(s1)
        log_write(bp);
    800040ae:	8552                	mv	a0,s4
    800040b0:	00001097          	auipc	ra,0x1
    800040b4:	f24080e7          	jalr	-220(ra) # 80004fd4 <log_write>
    800040b8:	b7e1                	j	80004080 <bmap+0x90>
    800040ba:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800040bc:	00005517          	auipc	a0,0x5
    800040c0:	41450513          	addi	a0,a0,1044 # 800094d0 <etext+0x4d0>
    800040c4:	ffffc097          	auipc	ra,0xffffc
    800040c8:	49c080e7          	jalr	1180(ra) # 80000560 <panic>

00000000800040cc <iget>:
{
    800040cc:	7179                	addi	sp,sp,-48
    800040ce:	f406                	sd	ra,40(sp)
    800040d0:	f022                	sd	s0,32(sp)
    800040d2:	ec26                	sd	s1,24(sp)
    800040d4:	e84a                	sd	s2,16(sp)
    800040d6:	e44e                	sd	s3,8(sp)
    800040d8:	e052                	sd	s4,0(sp)
    800040da:	1800                	addi	s0,sp,48
    800040dc:	89aa                	mv	s3,a0
    800040de:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800040e0:	00244517          	auipc	a0,0x244
    800040e4:	25050513          	addi	a0,a0,592 # 80248330 <itable>
    800040e8:	ffffd097          	auipc	ra,0xffffd
    800040ec:	cc8080e7          	jalr	-824(ra) # 80000db0 <acquire>
  empty = 0;
    800040f0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800040f2:	00244497          	auipc	s1,0x244
    800040f6:	25648493          	addi	s1,s1,598 # 80248348 <itable+0x18>
    800040fa:	00246697          	auipc	a3,0x246
    800040fe:	cde68693          	addi	a3,a3,-802 # 80249dd8 <log>
    80004102:	a039                	j	80004110 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004104:	02090b63          	beqz	s2,8000413a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004108:	08848493          	addi	s1,s1,136
    8000410c:	02d48a63          	beq	s1,a3,80004140 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004110:	449c                	lw	a5,8(s1)
    80004112:	fef059e3          	blez	a5,80004104 <iget+0x38>
    80004116:	4098                	lw	a4,0(s1)
    80004118:	ff3716e3          	bne	a4,s3,80004104 <iget+0x38>
    8000411c:	40d8                	lw	a4,4(s1)
    8000411e:	ff4713e3          	bne	a4,s4,80004104 <iget+0x38>
      ip->ref++;
    80004122:	2785                	addiw	a5,a5,1
    80004124:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004126:	00244517          	auipc	a0,0x244
    8000412a:	20a50513          	addi	a0,a0,522 # 80248330 <itable>
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	d32080e7          	jalr	-718(ra) # 80000e60 <release>
      return ip;
    80004136:	8926                	mv	s2,s1
    80004138:	a03d                	j	80004166 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000413a:	f7f9                	bnez	a5,80004108 <iget+0x3c>
      empty = ip;
    8000413c:	8926                	mv	s2,s1
    8000413e:	b7e9                	j	80004108 <iget+0x3c>
  if(empty == 0)
    80004140:	02090c63          	beqz	s2,80004178 <iget+0xac>
  ip->dev = dev;
    80004144:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004148:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000414c:	4785                	li	a5,1
    8000414e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004152:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004156:	00244517          	auipc	a0,0x244
    8000415a:	1da50513          	addi	a0,a0,474 # 80248330 <itable>
    8000415e:	ffffd097          	auipc	ra,0xffffd
    80004162:	d02080e7          	jalr	-766(ra) # 80000e60 <release>
}
    80004166:	854a                	mv	a0,s2
    80004168:	70a2                	ld	ra,40(sp)
    8000416a:	7402                	ld	s0,32(sp)
    8000416c:	64e2                	ld	s1,24(sp)
    8000416e:	6942                	ld	s2,16(sp)
    80004170:	69a2                	ld	s3,8(sp)
    80004172:	6a02                	ld	s4,0(sp)
    80004174:	6145                	addi	sp,sp,48
    80004176:	8082                	ret
    panic("iget: no inodes");
    80004178:	00005517          	auipc	a0,0x5
    8000417c:	37050513          	addi	a0,a0,880 # 800094e8 <etext+0x4e8>
    80004180:	ffffc097          	auipc	ra,0xffffc
    80004184:	3e0080e7          	jalr	992(ra) # 80000560 <panic>

0000000080004188 <fsinit>:
fsinit(int dev) {
    80004188:	7179                	addi	sp,sp,-48
    8000418a:	f406                	sd	ra,40(sp)
    8000418c:	f022                	sd	s0,32(sp)
    8000418e:	ec26                	sd	s1,24(sp)
    80004190:	e84a                	sd	s2,16(sp)
    80004192:	e44e                	sd	s3,8(sp)
    80004194:	1800                	addi	s0,sp,48
    80004196:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004198:	4585                	li	a1,1
    8000419a:	00000097          	auipc	ra,0x0
    8000419e:	a64080e7          	jalr	-1436(ra) # 80003bfe <bread>
    800041a2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800041a4:	00244997          	auipc	s3,0x244
    800041a8:	16c98993          	addi	s3,s3,364 # 80248310 <sb>
    800041ac:	02000613          	li	a2,32
    800041b0:	05850593          	addi	a1,a0,88
    800041b4:	854e                	mv	a0,s3
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	d56080e7          	jalr	-682(ra) # 80000f0c <memmove>
  brelse(bp);
    800041be:	8526                	mv	a0,s1
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	b6e080e7          	jalr	-1170(ra) # 80003d2e <brelse>
  if(sb.magic != FSMAGIC)
    800041c8:	0009a703          	lw	a4,0(s3)
    800041cc:	102037b7          	lui	a5,0x10203
    800041d0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800041d4:	02f71263          	bne	a4,a5,800041f8 <fsinit+0x70>
  initlog(dev, &sb);
    800041d8:	00244597          	auipc	a1,0x244
    800041dc:	13858593          	addi	a1,a1,312 # 80248310 <sb>
    800041e0:	854a                	mv	a0,s2
    800041e2:	00001097          	auipc	ra,0x1
    800041e6:	b7c080e7          	jalr	-1156(ra) # 80004d5e <initlog>
}
    800041ea:	70a2                	ld	ra,40(sp)
    800041ec:	7402                	ld	s0,32(sp)
    800041ee:	64e2                	ld	s1,24(sp)
    800041f0:	6942                	ld	s2,16(sp)
    800041f2:	69a2                	ld	s3,8(sp)
    800041f4:	6145                	addi	sp,sp,48
    800041f6:	8082                	ret
    panic("invalid file system");
    800041f8:	00005517          	auipc	a0,0x5
    800041fc:	30050513          	addi	a0,a0,768 # 800094f8 <etext+0x4f8>
    80004200:	ffffc097          	auipc	ra,0xffffc
    80004204:	360080e7          	jalr	864(ra) # 80000560 <panic>

0000000080004208 <iinit>:
{
    80004208:	7179                	addi	sp,sp,-48
    8000420a:	f406                	sd	ra,40(sp)
    8000420c:	f022                	sd	s0,32(sp)
    8000420e:	ec26                	sd	s1,24(sp)
    80004210:	e84a                	sd	s2,16(sp)
    80004212:	e44e                	sd	s3,8(sp)
    80004214:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004216:	00005597          	auipc	a1,0x5
    8000421a:	2fa58593          	addi	a1,a1,762 # 80009510 <etext+0x510>
    8000421e:	00244517          	auipc	a0,0x244
    80004222:	11250513          	addi	a0,a0,274 # 80248330 <itable>
    80004226:	ffffd097          	auipc	ra,0xffffd
    8000422a:	af6080e7          	jalr	-1290(ra) # 80000d1c <initlock>
  for(i = 0; i < NINODE; i++) {
    8000422e:	00244497          	auipc	s1,0x244
    80004232:	12a48493          	addi	s1,s1,298 # 80248358 <itable+0x28>
    80004236:	00246997          	auipc	s3,0x246
    8000423a:	bb298993          	addi	s3,s3,-1102 # 80249de8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000423e:	00005917          	auipc	s2,0x5
    80004242:	2da90913          	addi	s2,s2,730 # 80009518 <etext+0x518>
    80004246:	85ca                	mv	a1,s2
    80004248:	8526                	mv	a0,s1
    8000424a:	00001097          	auipc	ra,0x1
    8000424e:	e6e080e7          	jalr	-402(ra) # 800050b8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004252:	08848493          	addi	s1,s1,136
    80004256:	ff3498e3          	bne	s1,s3,80004246 <iinit+0x3e>
}
    8000425a:	70a2                	ld	ra,40(sp)
    8000425c:	7402                	ld	s0,32(sp)
    8000425e:	64e2                	ld	s1,24(sp)
    80004260:	6942                	ld	s2,16(sp)
    80004262:	69a2                	ld	s3,8(sp)
    80004264:	6145                	addi	sp,sp,48
    80004266:	8082                	ret

0000000080004268 <ialloc>:
{
    80004268:	7139                	addi	sp,sp,-64
    8000426a:	fc06                	sd	ra,56(sp)
    8000426c:	f822                	sd	s0,48(sp)
    8000426e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80004270:	00244717          	auipc	a4,0x244
    80004274:	0ac72703          	lw	a4,172(a4) # 8024831c <sb+0xc>
    80004278:	4785                	li	a5,1
    8000427a:	06e7f463          	bgeu	a5,a4,800042e2 <ialloc+0x7a>
    8000427e:	f426                	sd	s1,40(sp)
    80004280:	f04a                	sd	s2,32(sp)
    80004282:	ec4e                	sd	s3,24(sp)
    80004284:	e852                	sd	s4,16(sp)
    80004286:	e456                	sd	s5,8(sp)
    80004288:	e05a                	sd	s6,0(sp)
    8000428a:	8aaa                	mv	s5,a0
    8000428c:	8b2e                	mv	s6,a1
    8000428e:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80004290:	00244a17          	auipc	s4,0x244
    80004294:	080a0a13          	addi	s4,s4,128 # 80248310 <sb>
    80004298:	00495593          	srli	a1,s2,0x4
    8000429c:	018a2783          	lw	a5,24(s4)
    800042a0:	9dbd                	addw	a1,a1,a5
    800042a2:	8556                	mv	a0,s5
    800042a4:	00000097          	auipc	ra,0x0
    800042a8:	95a080e7          	jalr	-1702(ra) # 80003bfe <bread>
    800042ac:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800042ae:	05850993          	addi	s3,a0,88
    800042b2:	00f97793          	andi	a5,s2,15
    800042b6:	079a                	slli	a5,a5,0x6
    800042b8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800042ba:	00099783          	lh	a5,0(s3)
    800042be:	cf9d                	beqz	a5,800042fc <ialloc+0x94>
    brelse(bp);
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	a6e080e7          	jalr	-1426(ra) # 80003d2e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800042c8:	0905                	addi	s2,s2,1
    800042ca:	00ca2703          	lw	a4,12(s4)
    800042ce:	0009079b          	sext.w	a5,s2
    800042d2:	fce7e3e3          	bltu	a5,a4,80004298 <ialloc+0x30>
    800042d6:	74a2                	ld	s1,40(sp)
    800042d8:	7902                	ld	s2,32(sp)
    800042da:	69e2                	ld	s3,24(sp)
    800042dc:	6a42                	ld	s4,16(sp)
    800042de:	6aa2                	ld	s5,8(sp)
    800042e0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800042e2:	00005517          	auipc	a0,0x5
    800042e6:	23e50513          	addi	a0,a0,574 # 80009520 <etext+0x520>
    800042ea:	ffffc097          	auipc	ra,0xffffc
    800042ee:	2c0080e7          	jalr	704(ra) # 800005aa <printf>
  return 0;
    800042f2:	4501                	li	a0,0
}
    800042f4:	70e2                	ld	ra,56(sp)
    800042f6:	7442                	ld	s0,48(sp)
    800042f8:	6121                	addi	sp,sp,64
    800042fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800042fc:	04000613          	li	a2,64
    80004300:	4581                	li	a1,0
    80004302:	854e                	mv	a0,s3
    80004304:	ffffd097          	auipc	ra,0xffffd
    80004308:	ba4080e7          	jalr	-1116(ra) # 80000ea8 <memset>
      dip->type = type;
    8000430c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004310:	8526                	mv	a0,s1
    80004312:	00001097          	auipc	ra,0x1
    80004316:	cc2080e7          	jalr	-830(ra) # 80004fd4 <log_write>
      brelse(bp);
    8000431a:	8526                	mv	a0,s1
    8000431c:	00000097          	auipc	ra,0x0
    80004320:	a12080e7          	jalr	-1518(ra) # 80003d2e <brelse>
      return iget(dev, inum);
    80004324:	0009059b          	sext.w	a1,s2
    80004328:	8556                	mv	a0,s5
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	da2080e7          	jalr	-606(ra) # 800040cc <iget>
    80004332:	74a2                	ld	s1,40(sp)
    80004334:	7902                	ld	s2,32(sp)
    80004336:	69e2                	ld	s3,24(sp)
    80004338:	6a42                	ld	s4,16(sp)
    8000433a:	6aa2                	ld	s5,8(sp)
    8000433c:	6b02                	ld	s6,0(sp)
    8000433e:	bf5d                	j	800042f4 <ialloc+0x8c>

0000000080004340 <iupdate>:
{
    80004340:	1101                	addi	sp,sp,-32
    80004342:	ec06                	sd	ra,24(sp)
    80004344:	e822                	sd	s0,16(sp)
    80004346:	e426                	sd	s1,8(sp)
    80004348:	e04a                	sd	s2,0(sp)
    8000434a:	1000                	addi	s0,sp,32
    8000434c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000434e:	415c                	lw	a5,4(a0)
    80004350:	0047d79b          	srliw	a5,a5,0x4
    80004354:	00244597          	auipc	a1,0x244
    80004358:	fd45a583          	lw	a1,-44(a1) # 80248328 <sb+0x18>
    8000435c:	9dbd                	addw	a1,a1,a5
    8000435e:	4108                	lw	a0,0(a0)
    80004360:	00000097          	auipc	ra,0x0
    80004364:	89e080e7          	jalr	-1890(ra) # 80003bfe <bread>
    80004368:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000436a:	05850793          	addi	a5,a0,88
    8000436e:	40d8                	lw	a4,4(s1)
    80004370:	8b3d                	andi	a4,a4,15
    80004372:	071a                	slli	a4,a4,0x6
    80004374:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004376:	04449703          	lh	a4,68(s1)
    8000437a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000437e:	04649703          	lh	a4,70(s1)
    80004382:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004386:	04849703          	lh	a4,72(s1)
    8000438a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000438e:	04a49703          	lh	a4,74(s1)
    80004392:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004396:	44f8                	lw	a4,76(s1)
    80004398:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000439a:	03400613          	li	a2,52
    8000439e:	05048593          	addi	a1,s1,80
    800043a2:	00c78513          	addi	a0,a5,12
    800043a6:	ffffd097          	auipc	ra,0xffffd
    800043aa:	b66080e7          	jalr	-1178(ra) # 80000f0c <memmove>
  log_write(bp);
    800043ae:	854a                	mv	a0,s2
    800043b0:	00001097          	auipc	ra,0x1
    800043b4:	c24080e7          	jalr	-988(ra) # 80004fd4 <log_write>
  brelse(bp);
    800043b8:	854a                	mv	a0,s2
    800043ba:	00000097          	auipc	ra,0x0
    800043be:	974080e7          	jalr	-1676(ra) # 80003d2e <brelse>
}
    800043c2:	60e2                	ld	ra,24(sp)
    800043c4:	6442                	ld	s0,16(sp)
    800043c6:	64a2                	ld	s1,8(sp)
    800043c8:	6902                	ld	s2,0(sp)
    800043ca:	6105                	addi	sp,sp,32
    800043cc:	8082                	ret

00000000800043ce <idup>:
{
    800043ce:	1101                	addi	sp,sp,-32
    800043d0:	ec06                	sd	ra,24(sp)
    800043d2:	e822                	sd	s0,16(sp)
    800043d4:	e426                	sd	s1,8(sp)
    800043d6:	1000                	addi	s0,sp,32
    800043d8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800043da:	00244517          	auipc	a0,0x244
    800043de:	f5650513          	addi	a0,a0,-170 # 80248330 <itable>
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	9ce080e7          	jalr	-1586(ra) # 80000db0 <acquire>
  ip->ref++;
    800043ea:	449c                	lw	a5,8(s1)
    800043ec:	2785                	addiw	a5,a5,1
    800043ee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800043f0:	00244517          	auipc	a0,0x244
    800043f4:	f4050513          	addi	a0,a0,-192 # 80248330 <itable>
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	a68080e7          	jalr	-1432(ra) # 80000e60 <release>
}
    80004400:	8526                	mv	a0,s1
    80004402:	60e2                	ld	ra,24(sp)
    80004404:	6442                	ld	s0,16(sp)
    80004406:	64a2                	ld	s1,8(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <ilock>:
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004416:	c10d                	beqz	a0,80004438 <ilock+0x2c>
    80004418:	84aa                	mv	s1,a0
    8000441a:	451c                	lw	a5,8(a0)
    8000441c:	00f05e63          	blez	a5,80004438 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80004420:	0541                	addi	a0,a0,16
    80004422:	00001097          	auipc	ra,0x1
    80004426:	cd0080e7          	jalr	-816(ra) # 800050f2 <acquiresleep>
  if(ip->valid == 0){
    8000442a:	40bc                	lw	a5,64(s1)
    8000442c:	cf99                	beqz	a5,8000444a <ilock+0x3e>
}
    8000442e:	60e2                	ld	ra,24(sp)
    80004430:	6442                	ld	s0,16(sp)
    80004432:	64a2                	ld	s1,8(sp)
    80004434:	6105                	addi	sp,sp,32
    80004436:	8082                	ret
    80004438:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000443a:	00005517          	auipc	a0,0x5
    8000443e:	0fe50513          	addi	a0,a0,254 # 80009538 <etext+0x538>
    80004442:	ffffc097          	auipc	ra,0xffffc
    80004446:	11e080e7          	jalr	286(ra) # 80000560 <panic>
    8000444a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000444c:	40dc                	lw	a5,4(s1)
    8000444e:	0047d79b          	srliw	a5,a5,0x4
    80004452:	00244597          	auipc	a1,0x244
    80004456:	ed65a583          	lw	a1,-298(a1) # 80248328 <sb+0x18>
    8000445a:	9dbd                	addw	a1,a1,a5
    8000445c:	4088                	lw	a0,0(s1)
    8000445e:	fffff097          	auipc	ra,0xfffff
    80004462:	7a0080e7          	jalr	1952(ra) # 80003bfe <bread>
    80004466:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004468:	05850593          	addi	a1,a0,88
    8000446c:	40dc                	lw	a5,4(s1)
    8000446e:	8bbd                	andi	a5,a5,15
    80004470:	079a                	slli	a5,a5,0x6
    80004472:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004474:	00059783          	lh	a5,0(a1)
    80004478:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000447c:	00259783          	lh	a5,2(a1)
    80004480:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004484:	00459783          	lh	a5,4(a1)
    80004488:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000448c:	00659783          	lh	a5,6(a1)
    80004490:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004494:	459c                	lw	a5,8(a1)
    80004496:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004498:	03400613          	li	a2,52
    8000449c:	05b1                	addi	a1,a1,12
    8000449e:	05048513          	addi	a0,s1,80
    800044a2:	ffffd097          	auipc	ra,0xffffd
    800044a6:	a6a080e7          	jalr	-1430(ra) # 80000f0c <memmove>
    brelse(bp);
    800044aa:	854a                	mv	a0,s2
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	882080e7          	jalr	-1918(ra) # 80003d2e <brelse>
    ip->valid = 1;
    800044b4:	4785                	li	a5,1
    800044b6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800044b8:	04449783          	lh	a5,68(s1)
    800044bc:	c399                	beqz	a5,800044c2 <ilock+0xb6>
    800044be:	6902                	ld	s2,0(sp)
    800044c0:	b7bd                	j	8000442e <ilock+0x22>
      panic("ilock: no type");
    800044c2:	00005517          	auipc	a0,0x5
    800044c6:	07e50513          	addi	a0,a0,126 # 80009540 <etext+0x540>
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	096080e7          	jalr	150(ra) # 80000560 <panic>

00000000800044d2 <iunlock>:
{
    800044d2:	1101                	addi	sp,sp,-32
    800044d4:	ec06                	sd	ra,24(sp)
    800044d6:	e822                	sd	s0,16(sp)
    800044d8:	e426                	sd	s1,8(sp)
    800044da:	e04a                	sd	s2,0(sp)
    800044dc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800044de:	c905                	beqz	a0,8000450e <iunlock+0x3c>
    800044e0:	84aa                	mv	s1,a0
    800044e2:	01050913          	addi	s2,a0,16
    800044e6:	854a                	mv	a0,s2
    800044e8:	00001097          	auipc	ra,0x1
    800044ec:	ca4080e7          	jalr	-860(ra) # 8000518c <holdingsleep>
    800044f0:	cd19                	beqz	a0,8000450e <iunlock+0x3c>
    800044f2:	449c                	lw	a5,8(s1)
    800044f4:	00f05d63          	blez	a5,8000450e <iunlock+0x3c>
  releasesleep(&ip->lock);
    800044f8:	854a                	mv	a0,s2
    800044fa:	00001097          	auipc	ra,0x1
    800044fe:	c4e080e7          	jalr	-946(ra) # 80005148 <releasesleep>
}
    80004502:	60e2                	ld	ra,24(sp)
    80004504:	6442                	ld	s0,16(sp)
    80004506:	64a2                	ld	s1,8(sp)
    80004508:	6902                	ld	s2,0(sp)
    8000450a:	6105                	addi	sp,sp,32
    8000450c:	8082                	ret
    panic("iunlock");
    8000450e:	00005517          	auipc	a0,0x5
    80004512:	04250513          	addi	a0,a0,66 # 80009550 <etext+0x550>
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	04a080e7          	jalr	74(ra) # 80000560 <panic>

000000008000451e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000451e:	7179                	addi	sp,sp,-48
    80004520:	f406                	sd	ra,40(sp)
    80004522:	f022                	sd	s0,32(sp)
    80004524:	ec26                	sd	s1,24(sp)
    80004526:	e84a                	sd	s2,16(sp)
    80004528:	e44e                	sd	s3,8(sp)
    8000452a:	1800                	addi	s0,sp,48
    8000452c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000452e:	05050493          	addi	s1,a0,80
    80004532:	08050913          	addi	s2,a0,128
    80004536:	a021                	j	8000453e <itrunc+0x20>
    80004538:	0491                	addi	s1,s1,4
    8000453a:	01248d63          	beq	s1,s2,80004554 <itrunc+0x36>
    if(ip->addrs[i]){
    8000453e:	408c                	lw	a1,0(s1)
    80004540:	dde5                	beqz	a1,80004538 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004542:	0009a503          	lw	a0,0(s3)
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	8f8080e7          	jalr	-1800(ra) # 80003e3e <bfree>
      ip->addrs[i] = 0;
    8000454e:	0004a023          	sw	zero,0(s1)
    80004552:	b7dd                	j	80004538 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004554:	0809a583          	lw	a1,128(s3)
    80004558:	ed99                	bnez	a1,80004576 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000455a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000455e:	854e                	mv	a0,s3
    80004560:	00000097          	auipc	ra,0x0
    80004564:	de0080e7          	jalr	-544(ra) # 80004340 <iupdate>
}
    80004568:	70a2                	ld	ra,40(sp)
    8000456a:	7402                	ld	s0,32(sp)
    8000456c:	64e2                	ld	s1,24(sp)
    8000456e:	6942                	ld	s2,16(sp)
    80004570:	69a2                	ld	s3,8(sp)
    80004572:	6145                	addi	sp,sp,48
    80004574:	8082                	ret
    80004576:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004578:	0009a503          	lw	a0,0(s3)
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	682080e7          	jalr	1666(ra) # 80003bfe <bread>
    80004584:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004586:	05850493          	addi	s1,a0,88
    8000458a:	45850913          	addi	s2,a0,1112
    8000458e:	a021                	j	80004596 <itrunc+0x78>
    80004590:	0491                	addi	s1,s1,4
    80004592:	01248b63          	beq	s1,s2,800045a8 <itrunc+0x8a>
      if(a[j])
    80004596:	408c                	lw	a1,0(s1)
    80004598:	dde5                	beqz	a1,80004590 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    8000459a:	0009a503          	lw	a0,0(s3)
    8000459e:	00000097          	auipc	ra,0x0
    800045a2:	8a0080e7          	jalr	-1888(ra) # 80003e3e <bfree>
    800045a6:	b7ed                	j	80004590 <itrunc+0x72>
    brelse(bp);
    800045a8:	8552                	mv	a0,s4
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	784080e7          	jalr	1924(ra) # 80003d2e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800045b2:	0809a583          	lw	a1,128(s3)
    800045b6:	0009a503          	lw	a0,0(s3)
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	884080e7          	jalr	-1916(ra) # 80003e3e <bfree>
    ip->addrs[NDIRECT] = 0;
    800045c2:	0809a023          	sw	zero,128(s3)
    800045c6:	6a02                	ld	s4,0(sp)
    800045c8:	bf49                	j	8000455a <itrunc+0x3c>

00000000800045ca <iput>:
{
    800045ca:	1101                	addi	sp,sp,-32
    800045cc:	ec06                	sd	ra,24(sp)
    800045ce:	e822                	sd	s0,16(sp)
    800045d0:	e426                	sd	s1,8(sp)
    800045d2:	1000                	addi	s0,sp,32
    800045d4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800045d6:	00244517          	auipc	a0,0x244
    800045da:	d5a50513          	addi	a0,a0,-678 # 80248330 <itable>
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	7d2080e7          	jalr	2002(ra) # 80000db0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800045e6:	4498                	lw	a4,8(s1)
    800045e8:	4785                	li	a5,1
    800045ea:	02f70263          	beq	a4,a5,8000460e <iput+0x44>
  ip->ref--;
    800045ee:	449c                	lw	a5,8(s1)
    800045f0:	37fd                	addiw	a5,a5,-1
    800045f2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800045f4:	00244517          	auipc	a0,0x244
    800045f8:	d3c50513          	addi	a0,a0,-708 # 80248330 <itable>
    800045fc:	ffffd097          	auipc	ra,0xffffd
    80004600:	864080e7          	jalr	-1948(ra) # 80000e60 <release>
}
    80004604:	60e2                	ld	ra,24(sp)
    80004606:	6442                	ld	s0,16(sp)
    80004608:	64a2                	ld	s1,8(sp)
    8000460a:	6105                	addi	sp,sp,32
    8000460c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000460e:	40bc                	lw	a5,64(s1)
    80004610:	dff9                	beqz	a5,800045ee <iput+0x24>
    80004612:	04a49783          	lh	a5,74(s1)
    80004616:	ffe1                	bnez	a5,800045ee <iput+0x24>
    80004618:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000461a:	01048913          	addi	s2,s1,16
    8000461e:	854a                	mv	a0,s2
    80004620:	00001097          	auipc	ra,0x1
    80004624:	ad2080e7          	jalr	-1326(ra) # 800050f2 <acquiresleep>
    release(&itable.lock);
    80004628:	00244517          	auipc	a0,0x244
    8000462c:	d0850513          	addi	a0,a0,-760 # 80248330 <itable>
    80004630:	ffffd097          	auipc	ra,0xffffd
    80004634:	830080e7          	jalr	-2000(ra) # 80000e60 <release>
    itrunc(ip);
    80004638:	8526                	mv	a0,s1
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	ee4080e7          	jalr	-284(ra) # 8000451e <itrunc>
    ip->type = 0;
    80004642:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004646:	8526                	mv	a0,s1
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	cf8080e7          	jalr	-776(ra) # 80004340 <iupdate>
    ip->valid = 0;
    80004650:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004654:	854a                	mv	a0,s2
    80004656:	00001097          	auipc	ra,0x1
    8000465a:	af2080e7          	jalr	-1294(ra) # 80005148 <releasesleep>
    acquire(&itable.lock);
    8000465e:	00244517          	auipc	a0,0x244
    80004662:	cd250513          	addi	a0,a0,-814 # 80248330 <itable>
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	74a080e7          	jalr	1866(ra) # 80000db0 <acquire>
    8000466e:	6902                	ld	s2,0(sp)
    80004670:	bfbd                	j	800045ee <iput+0x24>

0000000080004672 <iunlockput>:
{
    80004672:	1101                	addi	sp,sp,-32
    80004674:	ec06                	sd	ra,24(sp)
    80004676:	e822                	sd	s0,16(sp)
    80004678:	e426                	sd	s1,8(sp)
    8000467a:	1000                	addi	s0,sp,32
    8000467c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	e54080e7          	jalr	-428(ra) # 800044d2 <iunlock>
  iput(ip);
    80004686:	8526                	mv	a0,s1
    80004688:	00000097          	auipc	ra,0x0
    8000468c:	f42080e7          	jalr	-190(ra) # 800045ca <iput>
}
    80004690:	60e2                	ld	ra,24(sp)
    80004692:	6442                	ld	s0,16(sp)
    80004694:	64a2                	ld	s1,8(sp)
    80004696:	6105                	addi	sp,sp,32
    80004698:	8082                	ret

000000008000469a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000469a:	1141                	addi	sp,sp,-16
    8000469c:	e406                	sd	ra,8(sp)
    8000469e:	e022                	sd	s0,0(sp)
    800046a0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800046a2:	411c                	lw	a5,0(a0)
    800046a4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800046a6:	415c                	lw	a5,4(a0)
    800046a8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800046aa:	04451783          	lh	a5,68(a0)
    800046ae:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800046b2:	04a51783          	lh	a5,74(a0)
    800046b6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800046ba:	04c56783          	lwu	a5,76(a0)
    800046be:	e99c                	sd	a5,16(a1)
}
    800046c0:	60a2                	ld	ra,8(sp)
    800046c2:	6402                	ld	s0,0(sp)
    800046c4:	0141                	addi	sp,sp,16
    800046c6:	8082                	ret

00000000800046c8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800046c8:	457c                	lw	a5,76(a0)
    800046ca:	10d7e063          	bltu	a5,a3,800047ca <readi+0x102>
{
    800046ce:	7159                	addi	sp,sp,-112
    800046d0:	f486                	sd	ra,104(sp)
    800046d2:	f0a2                	sd	s0,96(sp)
    800046d4:	eca6                	sd	s1,88(sp)
    800046d6:	e0d2                	sd	s4,64(sp)
    800046d8:	fc56                	sd	s5,56(sp)
    800046da:	f85a                	sd	s6,48(sp)
    800046dc:	f45e                	sd	s7,40(sp)
    800046de:	1880                	addi	s0,sp,112
    800046e0:	8b2a                	mv	s6,a0
    800046e2:	8bae                	mv	s7,a1
    800046e4:	8a32                	mv	s4,a2
    800046e6:	84b6                	mv	s1,a3
    800046e8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800046ea:	9f35                	addw	a4,a4,a3
    return 0;
    800046ec:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800046ee:	0cd76563          	bltu	a4,a3,800047b8 <readi+0xf0>
    800046f2:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800046f4:	00e7f463          	bgeu	a5,a4,800046fc <readi+0x34>
    n = ip->size - off;
    800046f8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800046fc:	0a0a8563          	beqz	s5,800047a6 <readi+0xde>
    80004700:	e8ca                	sd	s2,80(sp)
    80004702:	f062                	sd	s8,32(sp)
    80004704:	ec66                	sd	s9,24(sp)
    80004706:	e86a                	sd	s10,16(sp)
    80004708:	e46e                	sd	s11,8(sp)
    8000470a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000470c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004710:	5c7d                	li	s8,-1
    80004712:	a82d                	j	8000474c <readi+0x84>
    80004714:	020d1d93          	slli	s11,s10,0x20
    80004718:	020ddd93          	srli	s11,s11,0x20
    8000471c:	05890613          	addi	a2,s2,88
    80004720:	86ee                	mv	a3,s11
    80004722:	963e                	add	a2,a2,a5
    80004724:	85d2                	mv	a1,s4
    80004726:	855e                	mv	a0,s7
    80004728:	ffffe097          	auipc	ra,0xffffe
    8000472c:	65e080e7          	jalr	1630(ra) # 80002d86 <either_copyout>
    80004730:	05850963          	beq	a0,s8,80004782 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004734:	854a                	mv	a0,s2
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	5f8080e7          	jalr	1528(ra) # 80003d2e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000473e:	013d09bb          	addw	s3,s10,s3
    80004742:	009d04bb          	addw	s1,s10,s1
    80004746:	9a6e                	add	s4,s4,s11
    80004748:	0559f963          	bgeu	s3,s5,8000479a <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    8000474c:	00a4d59b          	srliw	a1,s1,0xa
    80004750:	855a                	mv	a0,s6
    80004752:	00000097          	auipc	ra,0x0
    80004756:	89e080e7          	jalr	-1890(ra) # 80003ff0 <bmap>
    8000475a:	85aa                	mv	a1,a0
    if(addr == 0)
    8000475c:	c539                	beqz	a0,800047aa <readi+0xe2>
    bp = bread(ip->dev, addr);
    8000475e:	000b2503          	lw	a0,0(s6)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	49c080e7          	jalr	1180(ra) # 80003bfe <bread>
    8000476a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000476c:	3ff4f793          	andi	a5,s1,1023
    80004770:	40fc873b          	subw	a4,s9,a5
    80004774:	413a86bb          	subw	a3,s5,s3
    80004778:	8d3a                	mv	s10,a4
    8000477a:	f8e6fde3          	bgeu	a3,a4,80004714 <readi+0x4c>
    8000477e:	8d36                	mv	s10,a3
    80004780:	bf51                	j	80004714 <readi+0x4c>
      brelse(bp);
    80004782:	854a                	mv	a0,s2
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	5aa080e7          	jalr	1450(ra) # 80003d2e <brelse>
      tot = -1;
    8000478c:	59fd                	li	s3,-1
      break;
    8000478e:	6946                	ld	s2,80(sp)
    80004790:	7c02                	ld	s8,32(sp)
    80004792:	6ce2                	ld	s9,24(sp)
    80004794:	6d42                	ld	s10,16(sp)
    80004796:	6da2                	ld	s11,8(sp)
    80004798:	a831                	j	800047b4 <readi+0xec>
    8000479a:	6946                	ld	s2,80(sp)
    8000479c:	7c02                	ld	s8,32(sp)
    8000479e:	6ce2                	ld	s9,24(sp)
    800047a0:	6d42                	ld	s10,16(sp)
    800047a2:	6da2                	ld	s11,8(sp)
    800047a4:	a801                	j	800047b4 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800047a6:	89d6                	mv	s3,s5
    800047a8:	a031                	j	800047b4 <readi+0xec>
    800047aa:	6946                	ld	s2,80(sp)
    800047ac:	7c02                	ld	s8,32(sp)
    800047ae:	6ce2                	ld	s9,24(sp)
    800047b0:	6d42                	ld	s10,16(sp)
    800047b2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800047b4:	854e                	mv	a0,s3
    800047b6:	69a6                	ld	s3,72(sp)
}
    800047b8:	70a6                	ld	ra,104(sp)
    800047ba:	7406                	ld	s0,96(sp)
    800047bc:	64e6                	ld	s1,88(sp)
    800047be:	6a06                	ld	s4,64(sp)
    800047c0:	7ae2                	ld	s5,56(sp)
    800047c2:	7b42                	ld	s6,48(sp)
    800047c4:	7ba2                	ld	s7,40(sp)
    800047c6:	6165                	addi	sp,sp,112
    800047c8:	8082                	ret
    return 0;
    800047ca:	4501                	li	a0,0
}
    800047cc:	8082                	ret

00000000800047ce <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800047ce:	457c                	lw	a5,76(a0)
    800047d0:	10d7e963          	bltu	a5,a3,800048e2 <writei+0x114>
{
    800047d4:	7159                	addi	sp,sp,-112
    800047d6:	f486                	sd	ra,104(sp)
    800047d8:	f0a2                	sd	s0,96(sp)
    800047da:	e8ca                	sd	s2,80(sp)
    800047dc:	e0d2                	sd	s4,64(sp)
    800047de:	fc56                	sd	s5,56(sp)
    800047e0:	f85a                	sd	s6,48(sp)
    800047e2:	f45e                	sd	s7,40(sp)
    800047e4:	1880                	addi	s0,sp,112
    800047e6:	8aaa                	mv	s5,a0
    800047e8:	8bae                	mv	s7,a1
    800047ea:	8a32                	mv	s4,a2
    800047ec:	8936                	mv	s2,a3
    800047ee:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800047f0:	00e687bb          	addw	a5,a3,a4
    800047f4:	0ed7e963          	bltu	a5,a3,800048e6 <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800047f8:	00043737          	lui	a4,0x43
    800047fc:	0ef76763          	bltu	a4,a5,800048ea <writei+0x11c>
    80004800:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004802:	0c0b0863          	beqz	s6,800048d2 <writei+0x104>
    80004806:	eca6                	sd	s1,88(sp)
    80004808:	f062                	sd	s8,32(sp)
    8000480a:	ec66                	sd	s9,24(sp)
    8000480c:	e86a                	sd	s10,16(sp)
    8000480e:	e46e                	sd	s11,8(sp)
    80004810:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004812:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004816:	5c7d                	li	s8,-1
    80004818:	a091                	j	8000485c <writei+0x8e>
    8000481a:	020d1d93          	slli	s11,s10,0x20
    8000481e:	020ddd93          	srli	s11,s11,0x20
    80004822:	05848513          	addi	a0,s1,88
    80004826:	86ee                	mv	a3,s11
    80004828:	8652                	mv	a2,s4
    8000482a:	85de                	mv	a1,s7
    8000482c:	953e                	add	a0,a0,a5
    8000482e:	ffffe097          	auipc	ra,0xffffe
    80004832:	5b0080e7          	jalr	1456(ra) # 80002dde <either_copyin>
    80004836:	05850e63          	beq	a0,s8,80004892 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000483a:	8526                	mv	a0,s1
    8000483c:	00000097          	auipc	ra,0x0
    80004840:	798080e7          	jalr	1944(ra) # 80004fd4 <log_write>
    brelse(bp);
    80004844:	8526                	mv	a0,s1
    80004846:	fffff097          	auipc	ra,0xfffff
    8000484a:	4e8080e7          	jalr	1256(ra) # 80003d2e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000484e:	013d09bb          	addw	s3,s10,s3
    80004852:	012d093b          	addw	s2,s10,s2
    80004856:	9a6e                	add	s4,s4,s11
    80004858:	0569f263          	bgeu	s3,s6,8000489c <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000485c:	00a9559b          	srliw	a1,s2,0xa
    80004860:	8556                	mv	a0,s5
    80004862:	fffff097          	auipc	ra,0xfffff
    80004866:	78e080e7          	jalr	1934(ra) # 80003ff0 <bmap>
    8000486a:	85aa                	mv	a1,a0
    if(addr == 0)
    8000486c:	c905                	beqz	a0,8000489c <writei+0xce>
    bp = bread(ip->dev, addr);
    8000486e:	000aa503          	lw	a0,0(s5)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	38c080e7          	jalr	908(ra) # 80003bfe <bread>
    8000487a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000487c:	3ff97793          	andi	a5,s2,1023
    80004880:	40fc873b          	subw	a4,s9,a5
    80004884:	413b06bb          	subw	a3,s6,s3
    80004888:	8d3a                	mv	s10,a4
    8000488a:	f8e6f8e3          	bgeu	a3,a4,8000481a <writei+0x4c>
    8000488e:	8d36                	mv	s10,a3
    80004890:	b769                	j	8000481a <writei+0x4c>
      brelse(bp);
    80004892:	8526                	mv	a0,s1
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	49a080e7          	jalr	1178(ra) # 80003d2e <brelse>
  }

  if(off > ip->size)
    8000489c:	04caa783          	lw	a5,76(s5)
    800048a0:	0327fb63          	bgeu	a5,s2,800048d6 <writei+0x108>
    ip->size = off;
    800048a4:	052aa623          	sw	s2,76(s5)
    800048a8:	64e6                	ld	s1,88(sp)
    800048aa:	7c02                	ld	s8,32(sp)
    800048ac:	6ce2                	ld	s9,24(sp)
    800048ae:	6d42                	ld	s10,16(sp)
    800048b0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800048b2:	8556                	mv	a0,s5
    800048b4:	00000097          	auipc	ra,0x0
    800048b8:	a8c080e7          	jalr	-1396(ra) # 80004340 <iupdate>

  return tot;
    800048bc:	854e                	mv	a0,s3
    800048be:	69a6                	ld	s3,72(sp)
}
    800048c0:	70a6                	ld	ra,104(sp)
    800048c2:	7406                	ld	s0,96(sp)
    800048c4:	6946                	ld	s2,80(sp)
    800048c6:	6a06                	ld	s4,64(sp)
    800048c8:	7ae2                	ld	s5,56(sp)
    800048ca:	7b42                	ld	s6,48(sp)
    800048cc:	7ba2                	ld	s7,40(sp)
    800048ce:	6165                	addi	sp,sp,112
    800048d0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800048d2:	89da                	mv	s3,s6
    800048d4:	bff9                	j	800048b2 <writei+0xe4>
    800048d6:	64e6                	ld	s1,88(sp)
    800048d8:	7c02                	ld	s8,32(sp)
    800048da:	6ce2                	ld	s9,24(sp)
    800048dc:	6d42                	ld	s10,16(sp)
    800048de:	6da2                	ld	s11,8(sp)
    800048e0:	bfc9                	j	800048b2 <writei+0xe4>
    return -1;
    800048e2:	557d                	li	a0,-1
}
    800048e4:	8082                	ret
    return -1;
    800048e6:	557d                	li	a0,-1
    800048e8:	bfe1                	j	800048c0 <writei+0xf2>
    return -1;
    800048ea:	557d                	li	a0,-1
    800048ec:	bfd1                	j	800048c0 <writei+0xf2>

00000000800048ee <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800048ee:	1141                	addi	sp,sp,-16
    800048f0:	e406                	sd	ra,8(sp)
    800048f2:	e022                	sd	s0,0(sp)
    800048f4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800048f6:	4639                	li	a2,14
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	68c080e7          	jalr	1676(ra) # 80000f84 <strncmp>
}
    80004900:	60a2                	ld	ra,8(sp)
    80004902:	6402                	ld	s0,0(sp)
    80004904:	0141                	addi	sp,sp,16
    80004906:	8082                	ret

0000000080004908 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004908:	711d                	addi	sp,sp,-96
    8000490a:	ec86                	sd	ra,88(sp)
    8000490c:	e8a2                	sd	s0,80(sp)
    8000490e:	e4a6                	sd	s1,72(sp)
    80004910:	e0ca                	sd	s2,64(sp)
    80004912:	fc4e                	sd	s3,56(sp)
    80004914:	f852                	sd	s4,48(sp)
    80004916:	f456                	sd	s5,40(sp)
    80004918:	f05a                	sd	s6,32(sp)
    8000491a:	ec5e                	sd	s7,24(sp)
    8000491c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000491e:	04451703          	lh	a4,68(a0)
    80004922:	4785                	li	a5,1
    80004924:	00f71f63          	bne	a4,a5,80004942 <dirlookup+0x3a>
    80004928:	892a                	mv	s2,a0
    8000492a:	8aae                	mv	s5,a1
    8000492c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000492e:	457c                	lw	a5,76(a0)
    80004930:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004932:	fa040a13          	addi	s4,s0,-96
    80004936:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80004938:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000493c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000493e:	e79d                	bnez	a5,8000496c <dirlookup+0x64>
    80004940:	a88d                	j	800049b2 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80004942:	00005517          	auipc	a0,0x5
    80004946:	c1650513          	addi	a0,a0,-1002 # 80009558 <etext+0x558>
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	c16080e7          	jalr	-1002(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004952:	00005517          	auipc	a0,0x5
    80004956:	c1e50513          	addi	a0,a0,-994 # 80009570 <etext+0x570>
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	c06080e7          	jalr	-1018(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004962:	24c1                	addiw	s1,s1,16
    80004964:	04c92783          	lw	a5,76(s2)
    80004968:	04f4f463          	bgeu	s1,a5,800049b0 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000496c:	874e                	mv	a4,s3
    8000496e:	86a6                	mv	a3,s1
    80004970:	8652                	mv	a2,s4
    80004972:	4581                	li	a1,0
    80004974:	854a                	mv	a0,s2
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	d52080e7          	jalr	-686(ra) # 800046c8 <readi>
    8000497e:	fd351ae3          	bne	a0,s3,80004952 <dirlookup+0x4a>
    if(de.inum == 0)
    80004982:	fa045783          	lhu	a5,-96(s0)
    80004986:	dff1                	beqz	a5,80004962 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80004988:	85da                	mv	a1,s6
    8000498a:	8556                	mv	a0,s5
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	f62080e7          	jalr	-158(ra) # 800048ee <namecmp>
    80004994:	f579                	bnez	a0,80004962 <dirlookup+0x5a>
      if(poff)
    80004996:	000b8463          	beqz	s7,8000499e <dirlookup+0x96>
        *poff = off;
    8000499a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000499e:	fa045583          	lhu	a1,-96(s0)
    800049a2:	00092503          	lw	a0,0(s2)
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	726080e7          	jalr	1830(ra) # 800040cc <iget>
    800049ae:	a011                	j	800049b2 <dirlookup+0xaa>
  return 0;
    800049b0:	4501                	li	a0,0
}
    800049b2:	60e6                	ld	ra,88(sp)
    800049b4:	6446                	ld	s0,80(sp)
    800049b6:	64a6                	ld	s1,72(sp)
    800049b8:	6906                	ld	s2,64(sp)
    800049ba:	79e2                	ld	s3,56(sp)
    800049bc:	7a42                	ld	s4,48(sp)
    800049be:	7aa2                	ld	s5,40(sp)
    800049c0:	7b02                	ld	s6,32(sp)
    800049c2:	6be2                	ld	s7,24(sp)
    800049c4:	6125                	addi	sp,sp,96
    800049c6:	8082                	ret

00000000800049c8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800049c8:	711d                	addi	sp,sp,-96
    800049ca:	ec86                	sd	ra,88(sp)
    800049cc:	e8a2                	sd	s0,80(sp)
    800049ce:	e4a6                	sd	s1,72(sp)
    800049d0:	e0ca                	sd	s2,64(sp)
    800049d2:	fc4e                	sd	s3,56(sp)
    800049d4:	f852                	sd	s4,48(sp)
    800049d6:	f456                	sd	s5,40(sp)
    800049d8:	f05a                	sd	s6,32(sp)
    800049da:	ec5e                	sd	s7,24(sp)
    800049dc:	e862                	sd	s8,16(sp)
    800049de:	e466                	sd	s9,8(sp)
    800049e0:	e06a                	sd	s10,0(sp)
    800049e2:	1080                	addi	s0,sp,96
    800049e4:	84aa                	mv	s1,a0
    800049e6:	8b2e                	mv	s6,a1
    800049e8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800049ea:	00054703          	lbu	a4,0(a0)
    800049ee:	02f00793          	li	a5,47
    800049f2:	02f70363          	beq	a4,a5,80004a18 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800049f6:	ffffd097          	auipc	ra,0xffffd
    800049fa:	488080e7          	jalr	1160(ra) # 80001e7e <myproc>
    800049fe:	32853503          	ld	a0,808(a0)
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	9cc080e7          	jalr	-1588(ra) # 800043ce <idup>
    80004a0a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004a0c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004a10:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004a12:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004a14:	4b85                	li	s7,1
    80004a16:	a87d                	j	80004ad4 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004a18:	4585                	li	a1,1
    80004a1a:	852e                	mv	a0,a1
    80004a1c:	fffff097          	auipc	ra,0xfffff
    80004a20:	6b0080e7          	jalr	1712(ra) # 800040cc <iget>
    80004a24:	8a2a                	mv	s4,a0
    80004a26:	b7dd                	j	80004a0c <namex+0x44>
      iunlockput(ip);
    80004a28:	8552                	mv	a0,s4
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	c48080e7          	jalr	-952(ra) # 80004672 <iunlockput>
      return 0;
    80004a32:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004a34:	8552                	mv	a0,s4
    80004a36:	60e6                	ld	ra,88(sp)
    80004a38:	6446                	ld	s0,80(sp)
    80004a3a:	64a6                	ld	s1,72(sp)
    80004a3c:	6906                	ld	s2,64(sp)
    80004a3e:	79e2                	ld	s3,56(sp)
    80004a40:	7a42                	ld	s4,48(sp)
    80004a42:	7aa2                	ld	s5,40(sp)
    80004a44:	7b02                	ld	s6,32(sp)
    80004a46:	6be2                	ld	s7,24(sp)
    80004a48:	6c42                	ld	s8,16(sp)
    80004a4a:	6ca2                	ld	s9,8(sp)
    80004a4c:	6d02                	ld	s10,0(sp)
    80004a4e:	6125                	addi	sp,sp,96
    80004a50:	8082                	ret
      iunlock(ip);
    80004a52:	8552                	mv	a0,s4
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	a7e080e7          	jalr	-1410(ra) # 800044d2 <iunlock>
      return ip;
    80004a5c:	bfe1                	j	80004a34 <namex+0x6c>
      iunlockput(ip);
    80004a5e:	8552                	mv	a0,s4
    80004a60:	00000097          	auipc	ra,0x0
    80004a64:	c12080e7          	jalr	-1006(ra) # 80004672 <iunlockput>
      return 0;
    80004a68:	8a4e                	mv	s4,s3
    80004a6a:	b7e9                	j	80004a34 <namex+0x6c>
  len = path - s;
    80004a6c:	40998633          	sub	a2,s3,s1
    80004a70:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004a74:	09ac5863          	bge	s8,s10,80004b04 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004a78:	8666                	mv	a2,s9
    80004a7a:	85a6                	mv	a1,s1
    80004a7c:	8556                	mv	a0,s5
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	48e080e7          	jalr	1166(ra) # 80000f0c <memmove>
    80004a86:	84ce                	mv	s1,s3
  while(*path == '/')
    80004a88:	0004c783          	lbu	a5,0(s1)
    80004a8c:	01279763          	bne	a5,s2,80004a9a <namex+0xd2>
    path++;
    80004a90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004a92:	0004c783          	lbu	a5,0(s1)
    80004a96:	ff278de3          	beq	a5,s2,80004a90 <namex+0xc8>
    ilock(ip);
    80004a9a:	8552                	mv	a0,s4
    80004a9c:	00000097          	auipc	ra,0x0
    80004aa0:	970080e7          	jalr	-1680(ra) # 8000440c <ilock>
    if(ip->type != T_DIR){
    80004aa4:	044a1783          	lh	a5,68(s4)
    80004aa8:	f97790e3          	bne	a5,s7,80004a28 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004aac:	000b0563          	beqz	s6,80004ab6 <namex+0xee>
    80004ab0:	0004c783          	lbu	a5,0(s1)
    80004ab4:	dfd9                	beqz	a5,80004a52 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004ab6:	4601                	li	a2,0
    80004ab8:	85d6                	mv	a1,s5
    80004aba:	8552                	mv	a0,s4
    80004abc:	00000097          	auipc	ra,0x0
    80004ac0:	e4c080e7          	jalr	-436(ra) # 80004908 <dirlookup>
    80004ac4:	89aa                	mv	s3,a0
    80004ac6:	dd41                	beqz	a0,80004a5e <namex+0x96>
    iunlockput(ip);
    80004ac8:	8552                	mv	a0,s4
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	ba8080e7          	jalr	-1112(ra) # 80004672 <iunlockput>
    ip = next;
    80004ad2:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004ad4:	0004c783          	lbu	a5,0(s1)
    80004ad8:	01279763          	bne	a5,s2,80004ae6 <namex+0x11e>
    path++;
    80004adc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ade:	0004c783          	lbu	a5,0(s1)
    80004ae2:	ff278de3          	beq	a5,s2,80004adc <namex+0x114>
  if(*path == 0)
    80004ae6:	cb9d                	beqz	a5,80004b1c <namex+0x154>
  while(*path != '/' && *path != 0)
    80004ae8:	0004c783          	lbu	a5,0(s1)
    80004aec:	89a6                	mv	s3,s1
  len = path - s;
    80004aee:	4d01                	li	s10,0
    80004af0:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004af2:	01278963          	beq	a5,s2,80004b04 <namex+0x13c>
    80004af6:	dbbd                	beqz	a5,80004a6c <namex+0xa4>
    path++;
    80004af8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004afa:	0009c783          	lbu	a5,0(s3)
    80004afe:	ff279ce3          	bne	a5,s2,80004af6 <namex+0x12e>
    80004b02:	b7ad                	j	80004a6c <namex+0xa4>
    memmove(name, s, len);
    80004b04:	2601                	sext.w	a2,a2
    80004b06:	85a6                	mv	a1,s1
    80004b08:	8556                	mv	a0,s5
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	402080e7          	jalr	1026(ra) # 80000f0c <memmove>
    name[len] = 0;
    80004b12:	9d56                	add	s10,s10,s5
    80004b14:	000d0023          	sb	zero,0(s10)
    80004b18:	84ce                	mv	s1,s3
    80004b1a:	b7bd                	j	80004a88 <namex+0xc0>
  if(nameiparent){
    80004b1c:	f00b0ce3          	beqz	s6,80004a34 <namex+0x6c>
    iput(ip);
    80004b20:	8552                	mv	a0,s4
    80004b22:	00000097          	auipc	ra,0x0
    80004b26:	aa8080e7          	jalr	-1368(ra) # 800045ca <iput>
    return 0;
    80004b2a:	4a01                	li	s4,0
    80004b2c:	b721                	j	80004a34 <namex+0x6c>

0000000080004b2e <dirlink>:
{
    80004b2e:	715d                	addi	sp,sp,-80
    80004b30:	e486                	sd	ra,72(sp)
    80004b32:	e0a2                	sd	s0,64(sp)
    80004b34:	f84a                	sd	s2,48(sp)
    80004b36:	ec56                	sd	s5,24(sp)
    80004b38:	e85a                	sd	s6,16(sp)
    80004b3a:	0880                	addi	s0,sp,80
    80004b3c:	892a                	mv	s2,a0
    80004b3e:	8aae                	mv	s5,a1
    80004b40:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b42:	4601                	li	a2,0
    80004b44:	00000097          	auipc	ra,0x0
    80004b48:	dc4080e7          	jalr	-572(ra) # 80004908 <dirlookup>
    80004b4c:	e129                	bnez	a0,80004b8e <dirlink+0x60>
    80004b4e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b50:	04c92483          	lw	s1,76(s2)
    80004b54:	cca9                	beqz	s1,80004bae <dirlink+0x80>
    80004b56:	f44e                	sd	s3,40(sp)
    80004b58:	f052                	sd	s4,32(sp)
    80004b5a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b5c:	fb040a13          	addi	s4,s0,-80
    80004b60:	49c1                	li	s3,16
    80004b62:	874e                	mv	a4,s3
    80004b64:	86a6                	mv	a3,s1
    80004b66:	8652                	mv	a2,s4
    80004b68:	4581                	li	a1,0
    80004b6a:	854a                	mv	a0,s2
    80004b6c:	00000097          	auipc	ra,0x0
    80004b70:	b5c080e7          	jalr	-1188(ra) # 800046c8 <readi>
    80004b74:	03351363          	bne	a0,s3,80004b9a <dirlink+0x6c>
    if(de.inum == 0)
    80004b78:	fb045783          	lhu	a5,-80(s0)
    80004b7c:	c79d                	beqz	a5,80004baa <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b7e:	24c1                	addiw	s1,s1,16
    80004b80:	04c92783          	lw	a5,76(s2)
    80004b84:	fcf4efe3          	bltu	s1,a5,80004b62 <dirlink+0x34>
    80004b88:	79a2                	ld	s3,40(sp)
    80004b8a:	7a02                	ld	s4,32(sp)
    80004b8c:	a00d                	j	80004bae <dirlink+0x80>
    iput(ip);
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	a3c080e7          	jalr	-1476(ra) # 800045ca <iput>
    return -1;
    80004b96:	557d                	li	a0,-1
    80004b98:	a0a9                	j	80004be2 <dirlink+0xb4>
      panic("dirlink read");
    80004b9a:	00005517          	auipc	a0,0x5
    80004b9e:	9e650513          	addi	a0,a0,-1562 # 80009580 <etext+0x580>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	9be080e7          	jalr	-1602(ra) # 80000560 <panic>
    80004baa:	79a2                	ld	s3,40(sp)
    80004bac:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004bae:	4639                	li	a2,14
    80004bb0:	85d6                	mv	a1,s5
    80004bb2:	fb240513          	addi	a0,s0,-78
    80004bb6:	ffffc097          	auipc	ra,0xffffc
    80004bba:	408080e7          	jalr	1032(ra) # 80000fbe <strncpy>
  de.inum = inum;
    80004bbe:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004bc2:	4741                	li	a4,16
    80004bc4:	86a6                	mv	a3,s1
    80004bc6:	fb040613          	addi	a2,s0,-80
    80004bca:	4581                	li	a1,0
    80004bcc:	854a                	mv	a0,s2
    80004bce:	00000097          	auipc	ra,0x0
    80004bd2:	c00080e7          	jalr	-1024(ra) # 800047ce <writei>
    80004bd6:	1541                	addi	a0,a0,-16
    80004bd8:	00a03533          	snez	a0,a0
    80004bdc:	40a0053b          	negw	a0,a0
    80004be0:	74e2                	ld	s1,56(sp)
}
    80004be2:	60a6                	ld	ra,72(sp)
    80004be4:	6406                	ld	s0,64(sp)
    80004be6:	7942                	ld	s2,48(sp)
    80004be8:	6ae2                	ld	s5,24(sp)
    80004bea:	6b42                	ld	s6,16(sp)
    80004bec:	6161                	addi	sp,sp,80
    80004bee:	8082                	ret

0000000080004bf0 <namei>:

struct inode*
namei(char *path)
{
    80004bf0:	1101                	addi	sp,sp,-32
    80004bf2:	ec06                	sd	ra,24(sp)
    80004bf4:	e822                	sd	s0,16(sp)
    80004bf6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004bf8:	fe040613          	addi	a2,s0,-32
    80004bfc:	4581                	li	a1,0
    80004bfe:	00000097          	auipc	ra,0x0
    80004c02:	dca080e7          	jalr	-566(ra) # 800049c8 <namex>
}
    80004c06:	60e2                	ld	ra,24(sp)
    80004c08:	6442                	ld	s0,16(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret

0000000080004c0e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004c0e:	1141                	addi	sp,sp,-16
    80004c10:	e406                	sd	ra,8(sp)
    80004c12:	e022                	sd	s0,0(sp)
    80004c14:	0800                	addi	s0,sp,16
    80004c16:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004c18:	4585                	li	a1,1
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	dae080e7          	jalr	-594(ra) # 800049c8 <namex>
}
    80004c22:	60a2                	ld	ra,8(sp)
    80004c24:	6402                	ld	s0,0(sp)
    80004c26:	0141                	addi	sp,sp,16
    80004c28:	8082                	ret

0000000080004c2a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004c2a:	1101                	addi	sp,sp,-32
    80004c2c:	ec06                	sd	ra,24(sp)
    80004c2e:	e822                	sd	s0,16(sp)
    80004c30:	e426                	sd	s1,8(sp)
    80004c32:	e04a                	sd	s2,0(sp)
    80004c34:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004c36:	00245917          	auipc	s2,0x245
    80004c3a:	1a290913          	addi	s2,s2,418 # 80249dd8 <log>
    80004c3e:	01892583          	lw	a1,24(s2)
    80004c42:	02892503          	lw	a0,40(s2)
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	fb8080e7          	jalr	-72(ra) # 80003bfe <bread>
    80004c4e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004c50:	02c92603          	lw	a2,44(s2)
    80004c54:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004c56:	00c05f63          	blez	a2,80004c74 <write_head+0x4a>
    80004c5a:	00245717          	auipc	a4,0x245
    80004c5e:	1ae70713          	addi	a4,a4,430 # 80249e08 <log+0x30>
    80004c62:	87aa                	mv	a5,a0
    80004c64:	060a                	slli	a2,a2,0x2
    80004c66:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004c68:	4314                	lw	a3,0(a4)
    80004c6a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004c6c:	0711                	addi	a4,a4,4
    80004c6e:	0791                	addi	a5,a5,4
    80004c70:	fec79ce3          	bne	a5,a2,80004c68 <write_head+0x3e>
  }
  bwrite(buf);
    80004c74:	8526                	mv	a0,s1
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	07a080e7          	jalr	122(ra) # 80003cf0 <bwrite>
  brelse(buf);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	0ae080e7          	jalr	174(ra) # 80003d2e <brelse>
}
    80004c88:	60e2                	ld	ra,24(sp)
    80004c8a:	6442                	ld	s0,16(sp)
    80004c8c:	64a2                	ld	s1,8(sp)
    80004c8e:	6902                	ld	s2,0(sp)
    80004c90:	6105                	addi	sp,sp,32
    80004c92:	8082                	ret

0000000080004c94 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c94:	00245797          	auipc	a5,0x245
    80004c98:	1707a783          	lw	a5,368(a5) # 80249e04 <log+0x2c>
    80004c9c:	0cf05063          	blez	a5,80004d5c <install_trans+0xc8>
{
    80004ca0:	715d                	addi	sp,sp,-80
    80004ca2:	e486                	sd	ra,72(sp)
    80004ca4:	e0a2                	sd	s0,64(sp)
    80004ca6:	fc26                	sd	s1,56(sp)
    80004ca8:	f84a                	sd	s2,48(sp)
    80004caa:	f44e                	sd	s3,40(sp)
    80004cac:	f052                	sd	s4,32(sp)
    80004cae:	ec56                	sd	s5,24(sp)
    80004cb0:	e85a                	sd	s6,16(sp)
    80004cb2:	e45e                	sd	s7,8(sp)
    80004cb4:	0880                	addi	s0,sp,80
    80004cb6:	8b2a                	mv	s6,a0
    80004cb8:	00245a97          	auipc	s5,0x245
    80004cbc:	150a8a93          	addi	s5,s5,336 # 80249e08 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004cc0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004cc2:	00245997          	auipc	s3,0x245
    80004cc6:	11698993          	addi	s3,s3,278 # 80249dd8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004cca:	40000b93          	li	s7,1024
    80004cce:	a00d                	j	80004cf0 <install_trans+0x5c>
    brelse(lbuf);
    80004cd0:	854a                	mv	a0,s2
    80004cd2:	fffff097          	auipc	ra,0xfffff
    80004cd6:	05c080e7          	jalr	92(ra) # 80003d2e <brelse>
    brelse(dbuf);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	052080e7          	jalr	82(ra) # 80003d2e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ce4:	2a05                	addiw	s4,s4,1
    80004ce6:	0a91                	addi	s5,s5,4
    80004ce8:	02c9a783          	lw	a5,44(s3)
    80004cec:	04fa5d63          	bge	s4,a5,80004d46 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004cf0:	0189a583          	lw	a1,24(s3)
    80004cf4:	014585bb          	addw	a1,a1,s4
    80004cf8:	2585                	addiw	a1,a1,1
    80004cfa:	0289a503          	lw	a0,40(s3)
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	f00080e7          	jalr	-256(ra) # 80003bfe <bread>
    80004d06:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004d08:	000aa583          	lw	a1,0(s5)
    80004d0c:	0289a503          	lw	a0,40(s3)
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	eee080e7          	jalr	-274(ra) # 80003bfe <bread>
    80004d18:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004d1a:	865e                	mv	a2,s7
    80004d1c:	05890593          	addi	a1,s2,88
    80004d20:	05850513          	addi	a0,a0,88
    80004d24:	ffffc097          	auipc	ra,0xffffc
    80004d28:	1e8080e7          	jalr	488(ra) # 80000f0c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004d2c:	8526                	mv	a0,s1
    80004d2e:	fffff097          	auipc	ra,0xfffff
    80004d32:	fc2080e7          	jalr	-62(ra) # 80003cf0 <bwrite>
    if(recovering == 0)
    80004d36:	f80b1de3          	bnez	s6,80004cd0 <install_trans+0x3c>
      bunpin(dbuf);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	0c6080e7          	jalr	198(ra) # 80003e02 <bunpin>
    80004d44:	b771                	j	80004cd0 <install_trans+0x3c>
}
    80004d46:	60a6                	ld	ra,72(sp)
    80004d48:	6406                	ld	s0,64(sp)
    80004d4a:	74e2                	ld	s1,56(sp)
    80004d4c:	7942                	ld	s2,48(sp)
    80004d4e:	79a2                	ld	s3,40(sp)
    80004d50:	7a02                	ld	s4,32(sp)
    80004d52:	6ae2                	ld	s5,24(sp)
    80004d54:	6b42                	ld	s6,16(sp)
    80004d56:	6ba2                	ld	s7,8(sp)
    80004d58:	6161                	addi	sp,sp,80
    80004d5a:	8082                	ret
    80004d5c:	8082                	ret

0000000080004d5e <initlog>:
{
    80004d5e:	7179                	addi	sp,sp,-48
    80004d60:	f406                	sd	ra,40(sp)
    80004d62:	f022                	sd	s0,32(sp)
    80004d64:	ec26                	sd	s1,24(sp)
    80004d66:	e84a                	sd	s2,16(sp)
    80004d68:	e44e                	sd	s3,8(sp)
    80004d6a:	1800                	addi	s0,sp,48
    80004d6c:	892a                	mv	s2,a0
    80004d6e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004d70:	00245497          	auipc	s1,0x245
    80004d74:	06848493          	addi	s1,s1,104 # 80249dd8 <log>
    80004d78:	00005597          	auipc	a1,0x5
    80004d7c:	81858593          	addi	a1,a1,-2024 # 80009590 <etext+0x590>
    80004d80:	8526                	mv	a0,s1
    80004d82:	ffffc097          	auipc	ra,0xffffc
    80004d86:	f9a080e7          	jalr	-102(ra) # 80000d1c <initlock>
  log.start = sb->logstart;
    80004d8a:	0149a583          	lw	a1,20(s3)
    80004d8e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004d90:	0109a783          	lw	a5,16(s3)
    80004d94:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004d96:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004d9a:	854a                	mv	a0,s2
    80004d9c:	fffff097          	auipc	ra,0xfffff
    80004da0:	e62080e7          	jalr	-414(ra) # 80003bfe <bread>
  log.lh.n = lh->n;
    80004da4:	4d30                	lw	a2,88(a0)
    80004da6:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004da8:	00c05f63          	blez	a2,80004dc6 <initlog+0x68>
    80004dac:	87aa                	mv	a5,a0
    80004dae:	00245717          	auipc	a4,0x245
    80004db2:	05a70713          	addi	a4,a4,90 # 80249e08 <log+0x30>
    80004db6:	060a                	slli	a2,a2,0x2
    80004db8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004dba:	4ff4                	lw	a3,92(a5)
    80004dbc:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004dbe:	0791                	addi	a5,a5,4
    80004dc0:	0711                	addi	a4,a4,4
    80004dc2:	fec79ce3          	bne	a5,a2,80004dba <initlog+0x5c>
  brelse(buf);
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	f68080e7          	jalr	-152(ra) # 80003d2e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004dce:	4505                	li	a0,1
    80004dd0:	00000097          	auipc	ra,0x0
    80004dd4:	ec4080e7          	jalr	-316(ra) # 80004c94 <install_trans>
  log.lh.n = 0;
    80004dd8:	00245797          	auipc	a5,0x245
    80004ddc:	0207a623          	sw	zero,44(a5) # 80249e04 <log+0x2c>
  write_head(); // clear the log
    80004de0:	00000097          	auipc	ra,0x0
    80004de4:	e4a080e7          	jalr	-438(ra) # 80004c2a <write_head>
}
    80004de8:	70a2                	ld	ra,40(sp)
    80004dea:	7402                	ld	s0,32(sp)
    80004dec:	64e2                	ld	s1,24(sp)
    80004dee:	6942                	ld	s2,16(sp)
    80004df0:	69a2                	ld	s3,8(sp)
    80004df2:	6145                	addi	sp,sp,48
    80004df4:	8082                	ret

0000000080004df6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004df6:	1101                	addi	sp,sp,-32
    80004df8:	ec06                	sd	ra,24(sp)
    80004dfa:	e822                	sd	s0,16(sp)
    80004dfc:	e426                	sd	s1,8(sp)
    80004dfe:	e04a                	sd	s2,0(sp)
    80004e00:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004e02:	00245517          	auipc	a0,0x245
    80004e06:	fd650513          	addi	a0,a0,-42 # 80249dd8 <log>
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	fa6080e7          	jalr	-90(ra) # 80000db0 <acquire>
  while(1){
    if(log.committing){
    80004e12:	00245497          	auipc	s1,0x245
    80004e16:	fc648493          	addi	s1,s1,-58 # 80249dd8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004e1a:	4979                	li	s2,30
    80004e1c:	a039                	j	80004e2a <begin_op+0x34>
      sleep(&log, &log.lock);
    80004e1e:	85a6                	mv	a1,s1
    80004e20:	8526                	mv	a0,s1
    80004e22:	ffffe097          	auipc	ra,0xffffe
    80004e26:	b1a080e7          	jalr	-1254(ra) # 8000293c <sleep>
    if(log.committing){
    80004e2a:	50dc                	lw	a5,36(s1)
    80004e2c:	fbed                	bnez	a5,80004e1e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004e2e:	5098                	lw	a4,32(s1)
    80004e30:	2705                	addiw	a4,a4,1
    80004e32:	0027179b          	slliw	a5,a4,0x2
    80004e36:	9fb9                	addw	a5,a5,a4
    80004e38:	0017979b          	slliw	a5,a5,0x1
    80004e3c:	54d4                	lw	a3,44(s1)
    80004e3e:	9fb5                	addw	a5,a5,a3
    80004e40:	00f95963          	bge	s2,a5,80004e52 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004e44:	85a6                	mv	a1,s1
    80004e46:	8526                	mv	a0,s1
    80004e48:	ffffe097          	auipc	ra,0xffffe
    80004e4c:	af4080e7          	jalr	-1292(ra) # 8000293c <sleep>
    80004e50:	bfe9                	j	80004e2a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004e52:	00245517          	auipc	a0,0x245
    80004e56:	f8650513          	addi	a0,a0,-122 # 80249dd8 <log>
    80004e5a:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	004080e7          	jalr	4(ra) # 80000e60 <release>
      break;
    }
  }
}
    80004e64:	60e2                	ld	ra,24(sp)
    80004e66:	6442                	ld	s0,16(sp)
    80004e68:	64a2                	ld	s1,8(sp)
    80004e6a:	6902                	ld	s2,0(sp)
    80004e6c:	6105                	addi	sp,sp,32
    80004e6e:	8082                	ret

0000000080004e70 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004e70:	7139                	addi	sp,sp,-64
    80004e72:	fc06                	sd	ra,56(sp)
    80004e74:	f822                	sd	s0,48(sp)
    80004e76:	f426                	sd	s1,40(sp)
    80004e78:	f04a                	sd	s2,32(sp)
    80004e7a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004e7c:	00245497          	auipc	s1,0x245
    80004e80:	f5c48493          	addi	s1,s1,-164 # 80249dd8 <log>
    80004e84:	8526                	mv	a0,s1
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	f2a080e7          	jalr	-214(ra) # 80000db0 <acquire>
  log.outstanding -= 1;
    80004e8e:	509c                	lw	a5,32(s1)
    80004e90:	37fd                	addiw	a5,a5,-1
    80004e92:	893e                	mv	s2,a5
    80004e94:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004e96:	50dc                	lw	a5,36(s1)
    80004e98:	e7b9                	bnez	a5,80004ee6 <end_op+0x76>
    panic("log.committing");
  if(log.outstanding == 0){
    80004e9a:	06091263          	bnez	s2,80004efe <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004e9e:	00245497          	auipc	s1,0x245
    80004ea2:	f3a48493          	addi	s1,s1,-198 # 80249dd8 <log>
    80004ea6:	4785                	li	a5,1
    80004ea8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	fb4080e7          	jalr	-76(ra) # 80000e60 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004eb4:	54dc                	lw	a5,44(s1)
    80004eb6:	06f04863          	bgtz	a5,80004f26 <end_op+0xb6>
    acquire(&log.lock);
    80004eba:	00245497          	auipc	s1,0x245
    80004ebe:	f1e48493          	addi	s1,s1,-226 # 80249dd8 <log>
    80004ec2:	8526                	mv	a0,s1
    80004ec4:	ffffc097          	auipc	ra,0xffffc
    80004ec8:	eec080e7          	jalr	-276(ra) # 80000db0 <acquire>
    log.committing = 0;
    80004ecc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	ffffe097          	auipc	ra,0xffffe
    80004ed6:	ace080e7          	jalr	-1330(ra) # 800029a0 <wakeup>
    release(&log.lock);
    80004eda:	8526                	mv	a0,s1
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	f84080e7          	jalr	-124(ra) # 80000e60 <release>
}
    80004ee4:	a81d                	j	80004f1a <end_op+0xaa>
    80004ee6:	ec4e                	sd	s3,24(sp)
    80004ee8:	e852                	sd	s4,16(sp)
    80004eea:	e456                	sd	s5,8(sp)
    80004eec:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80004eee:	00004517          	auipc	a0,0x4
    80004ef2:	6aa50513          	addi	a0,a0,1706 # 80009598 <etext+0x598>
    80004ef6:	ffffb097          	auipc	ra,0xffffb
    80004efa:	66a080e7          	jalr	1642(ra) # 80000560 <panic>
    wakeup(&log);
    80004efe:	00245497          	auipc	s1,0x245
    80004f02:	eda48493          	addi	s1,s1,-294 # 80249dd8 <log>
    80004f06:	8526                	mv	a0,s1
    80004f08:	ffffe097          	auipc	ra,0xffffe
    80004f0c:	a98080e7          	jalr	-1384(ra) # 800029a0 <wakeup>
  release(&log.lock);
    80004f10:	8526                	mv	a0,s1
    80004f12:	ffffc097          	auipc	ra,0xffffc
    80004f16:	f4e080e7          	jalr	-178(ra) # 80000e60 <release>
}
    80004f1a:	70e2                	ld	ra,56(sp)
    80004f1c:	7442                	ld	s0,48(sp)
    80004f1e:	74a2                	ld	s1,40(sp)
    80004f20:	7902                	ld	s2,32(sp)
    80004f22:	6121                	addi	sp,sp,64
    80004f24:	8082                	ret
    80004f26:	ec4e                	sd	s3,24(sp)
    80004f28:	e852                	sd	s4,16(sp)
    80004f2a:	e456                	sd	s5,8(sp)
    80004f2c:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f2e:	00245a97          	auipc	s5,0x245
    80004f32:	edaa8a93          	addi	s5,s5,-294 # 80249e08 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004f36:	00245a17          	auipc	s4,0x245
    80004f3a:	ea2a0a13          	addi	s4,s4,-350 # 80249dd8 <log>
    memmove(to->data, from->data, BSIZE);
    80004f3e:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004f42:	018a2583          	lw	a1,24(s4)
    80004f46:	012585bb          	addw	a1,a1,s2
    80004f4a:	2585                	addiw	a1,a1,1
    80004f4c:	028a2503          	lw	a0,40(s4)
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	cae080e7          	jalr	-850(ra) # 80003bfe <bread>
    80004f58:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004f5a:	000aa583          	lw	a1,0(s5)
    80004f5e:	028a2503          	lw	a0,40(s4)
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	c9c080e7          	jalr	-868(ra) # 80003bfe <bread>
    80004f6a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004f6c:	865a                	mv	a2,s6
    80004f6e:	05850593          	addi	a1,a0,88
    80004f72:	05848513          	addi	a0,s1,88
    80004f76:	ffffc097          	auipc	ra,0xffffc
    80004f7a:	f96080e7          	jalr	-106(ra) # 80000f0c <memmove>
    bwrite(to);  // write the log
    80004f7e:	8526                	mv	a0,s1
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	d70080e7          	jalr	-656(ra) # 80003cf0 <bwrite>
    brelse(from);
    80004f88:	854e                	mv	a0,s3
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	da4080e7          	jalr	-604(ra) # 80003d2e <brelse>
    brelse(to);
    80004f92:	8526                	mv	a0,s1
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	d9a080e7          	jalr	-614(ra) # 80003d2e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f9c:	2905                	addiw	s2,s2,1
    80004f9e:	0a91                	addi	s5,s5,4
    80004fa0:	02ca2783          	lw	a5,44(s4)
    80004fa4:	f8f94fe3          	blt	s2,a5,80004f42 <end_op+0xd2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004fa8:	00000097          	auipc	ra,0x0
    80004fac:	c82080e7          	jalr	-894(ra) # 80004c2a <write_head>
    install_trans(0); // Now install writes to home locations
    80004fb0:	4501                	li	a0,0
    80004fb2:	00000097          	auipc	ra,0x0
    80004fb6:	ce2080e7          	jalr	-798(ra) # 80004c94 <install_trans>
    log.lh.n = 0;
    80004fba:	00245797          	auipc	a5,0x245
    80004fbe:	e407a523          	sw	zero,-438(a5) # 80249e04 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004fc2:	00000097          	auipc	ra,0x0
    80004fc6:	c68080e7          	jalr	-920(ra) # 80004c2a <write_head>
    80004fca:	69e2                	ld	s3,24(sp)
    80004fcc:	6a42                	ld	s4,16(sp)
    80004fce:	6aa2                	ld	s5,8(sp)
    80004fd0:	6b02                	ld	s6,0(sp)
    80004fd2:	b5e5                	j	80004eba <end_op+0x4a>

0000000080004fd4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004fd4:	1101                	addi	sp,sp,-32
    80004fd6:	ec06                	sd	ra,24(sp)
    80004fd8:	e822                	sd	s0,16(sp)
    80004fda:	e426                	sd	s1,8(sp)
    80004fdc:	e04a                	sd	s2,0(sp)
    80004fde:	1000                	addi	s0,sp,32
    80004fe0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004fe2:	00245917          	auipc	s2,0x245
    80004fe6:	df690913          	addi	s2,s2,-522 # 80249dd8 <log>
    80004fea:	854a                	mv	a0,s2
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	dc4080e7          	jalr	-572(ra) # 80000db0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004ff4:	02c92603          	lw	a2,44(s2)
    80004ff8:	47f5                	li	a5,29
    80004ffa:	06c7c563          	blt	a5,a2,80005064 <log_write+0x90>
    80004ffe:	00245797          	auipc	a5,0x245
    80005002:	df67a783          	lw	a5,-522(a5) # 80249df4 <log+0x1c>
    80005006:	37fd                	addiw	a5,a5,-1
    80005008:	04f65e63          	bge	a2,a5,80005064 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000500c:	00245797          	auipc	a5,0x245
    80005010:	dec7a783          	lw	a5,-532(a5) # 80249df8 <log+0x20>
    80005014:	06f05063          	blez	a5,80005074 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005018:	4781                	li	a5,0
    8000501a:	06c05563          	blez	a2,80005084 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000501e:	44cc                	lw	a1,12(s1)
    80005020:	00245717          	auipc	a4,0x245
    80005024:	de870713          	addi	a4,a4,-536 # 80249e08 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005028:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000502a:	4314                	lw	a3,0(a4)
    8000502c:	04b68c63          	beq	a3,a1,80005084 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005030:	2785                	addiw	a5,a5,1
    80005032:	0711                	addi	a4,a4,4
    80005034:	fef61be3          	bne	a2,a5,8000502a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005038:	0621                	addi	a2,a2,8
    8000503a:	060a                	slli	a2,a2,0x2
    8000503c:	00245797          	auipc	a5,0x245
    80005040:	d9c78793          	addi	a5,a5,-612 # 80249dd8 <log>
    80005044:	97b2                	add	a5,a5,a2
    80005046:	44d8                	lw	a4,12(s1)
    80005048:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000504a:	8526                	mv	a0,s1
    8000504c:	fffff097          	auipc	ra,0xfffff
    80005050:	d7a080e7          	jalr	-646(ra) # 80003dc6 <bpin>
    log.lh.n++;
    80005054:	00245717          	auipc	a4,0x245
    80005058:	d8470713          	addi	a4,a4,-636 # 80249dd8 <log>
    8000505c:	575c                	lw	a5,44(a4)
    8000505e:	2785                	addiw	a5,a5,1
    80005060:	d75c                	sw	a5,44(a4)
    80005062:	a82d                	j	8000509c <log_write+0xc8>
    panic("too big a transaction");
    80005064:	00004517          	auipc	a0,0x4
    80005068:	54450513          	addi	a0,a0,1348 # 800095a8 <etext+0x5a8>
    8000506c:	ffffb097          	auipc	ra,0xffffb
    80005070:	4f4080e7          	jalr	1268(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80005074:	00004517          	auipc	a0,0x4
    80005078:	54c50513          	addi	a0,a0,1356 # 800095c0 <etext+0x5c0>
    8000507c:	ffffb097          	auipc	ra,0xffffb
    80005080:	4e4080e7          	jalr	1252(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80005084:	00878693          	addi	a3,a5,8
    80005088:	068a                	slli	a3,a3,0x2
    8000508a:	00245717          	auipc	a4,0x245
    8000508e:	d4e70713          	addi	a4,a4,-690 # 80249dd8 <log>
    80005092:	9736                	add	a4,a4,a3
    80005094:	44d4                	lw	a3,12(s1)
    80005096:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005098:	faf609e3          	beq	a2,a5,8000504a <log_write+0x76>
  }
  release(&log.lock);
    8000509c:	00245517          	auipc	a0,0x245
    800050a0:	d3c50513          	addi	a0,a0,-708 # 80249dd8 <log>
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	dbc080e7          	jalr	-580(ra) # 80000e60 <release>
}
    800050ac:	60e2                	ld	ra,24(sp)
    800050ae:	6442                	ld	s0,16(sp)
    800050b0:	64a2                	ld	s1,8(sp)
    800050b2:	6902                	ld	s2,0(sp)
    800050b4:	6105                	addi	sp,sp,32
    800050b6:	8082                	ret

00000000800050b8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800050b8:	1101                	addi	sp,sp,-32
    800050ba:	ec06                	sd	ra,24(sp)
    800050bc:	e822                	sd	s0,16(sp)
    800050be:	e426                	sd	s1,8(sp)
    800050c0:	e04a                	sd	s2,0(sp)
    800050c2:	1000                	addi	s0,sp,32
    800050c4:	84aa                	mv	s1,a0
    800050c6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800050c8:	00004597          	auipc	a1,0x4
    800050cc:	51858593          	addi	a1,a1,1304 # 800095e0 <etext+0x5e0>
    800050d0:	0521                	addi	a0,a0,8
    800050d2:	ffffc097          	auipc	ra,0xffffc
    800050d6:	c4a080e7          	jalr	-950(ra) # 80000d1c <initlock>
  lk->name = name;
    800050da:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800050de:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800050e2:	0204a423          	sw	zero,40(s1)
}
    800050e6:	60e2                	ld	ra,24(sp)
    800050e8:	6442                	ld	s0,16(sp)
    800050ea:	64a2                	ld	s1,8(sp)
    800050ec:	6902                	ld	s2,0(sp)
    800050ee:	6105                	addi	sp,sp,32
    800050f0:	8082                	ret

00000000800050f2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800050f2:	1101                	addi	sp,sp,-32
    800050f4:	ec06                	sd	ra,24(sp)
    800050f6:	e822                	sd	s0,16(sp)
    800050f8:	e426                	sd	s1,8(sp)
    800050fa:	e04a                	sd	s2,0(sp)
    800050fc:	1000                	addi	s0,sp,32
    800050fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005100:	00850913          	addi	s2,a0,8
    80005104:	854a                	mv	a0,s2
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	caa080e7          	jalr	-854(ra) # 80000db0 <acquire>
  while (lk->locked) {
    8000510e:	409c                	lw	a5,0(s1)
    80005110:	cb89                	beqz	a5,80005122 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005112:	85ca                	mv	a1,s2
    80005114:	8526                	mv	a0,s1
    80005116:	ffffe097          	auipc	ra,0xffffe
    8000511a:	826080e7          	jalr	-2010(ra) # 8000293c <sleep>
  while (lk->locked) {
    8000511e:	409c                	lw	a5,0(s1)
    80005120:	fbed                	bnez	a5,80005112 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005122:	4785                	li	a5,1
    80005124:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005126:	ffffd097          	auipc	ra,0xffffd
    8000512a:	d58080e7          	jalr	-680(ra) # 80001e7e <myproc>
    8000512e:	591c                	lw	a5,48(a0)
    80005130:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005132:	854a                	mv	a0,s2
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	d2c080e7          	jalr	-724(ra) # 80000e60 <release>
}
    8000513c:	60e2                	ld	ra,24(sp)
    8000513e:	6442                	ld	s0,16(sp)
    80005140:	64a2                	ld	s1,8(sp)
    80005142:	6902                	ld	s2,0(sp)
    80005144:	6105                	addi	sp,sp,32
    80005146:	8082                	ret

0000000080005148 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005148:	1101                	addi	sp,sp,-32
    8000514a:	ec06                	sd	ra,24(sp)
    8000514c:	e822                	sd	s0,16(sp)
    8000514e:	e426                	sd	s1,8(sp)
    80005150:	e04a                	sd	s2,0(sp)
    80005152:	1000                	addi	s0,sp,32
    80005154:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005156:	00850913          	addi	s2,a0,8
    8000515a:	854a                	mv	a0,s2
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	c54080e7          	jalr	-940(ra) # 80000db0 <acquire>
  lk->locked = 0;
    80005164:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005168:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000516c:	8526                	mv	a0,s1
    8000516e:	ffffe097          	auipc	ra,0xffffe
    80005172:	832080e7          	jalr	-1998(ra) # 800029a0 <wakeup>
  release(&lk->lk);
    80005176:	854a                	mv	a0,s2
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	ce8080e7          	jalr	-792(ra) # 80000e60 <release>
}
    80005180:	60e2                	ld	ra,24(sp)
    80005182:	6442                	ld	s0,16(sp)
    80005184:	64a2                	ld	s1,8(sp)
    80005186:	6902                	ld	s2,0(sp)
    80005188:	6105                	addi	sp,sp,32
    8000518a:	8082                	ret

000000008000518c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000518c:	7179                	addi	sp,sp,-48
    8000518e:	f406                	sd	ra,40(sp)
    80005190:	f022                	sd	s0,32(sp)
    80005192:	ec26                	sd	s1,24(sp)
    80005194:	e84a                	sd	s2,16(sp)
    80005196:	1800                	addi	s0,sp,48
    80005198:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000519a:	00850913          	addi	s2,a0,8
    8000519e:	854a                	mv	a0,s2
    800051a0:	ffffc097          	auipc	ra,0xffffc
    800051a4:	c10080e7          	jalr	-1008(ra) # 80000db0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800051a8:	409c                	lw	a5,0(s1)
    800051aa:	ef91                	bnez	a5,800051c6 <holdingsleep+0x3a>
    800051ac:	4481                	li	s1,0
  release(&lk->lk);
    800051ae:	854a                	mv	a0,s2
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	cb0080e7          	jalr	-848(ra) # 80000e60 <release>
  return r;
}
    800051b8:	8526                	mv	a0,s1
    800051ba:	70a2                	ld	ra,40(sp)
    800051bc:	7402                	ld	s0,32(sp)
    800051be:	64e2                	ld	s1,24(sp)
    800051c0:	6942                	ld	s2,16(sp)
    800051c2:	6145                	addi	sp,sp,48
    800051c4:	8082                	ret
    800051c6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800051c8:	0284a983          	lw	s3,40(s1)
    800051cc:	ffffd097          	auipc	ra,0xffffd
    800051d0:	cb2080e7          	jalr	-846(ra) # 80001e7e <myproc>
    800051d4:	5904                	lw	s1,48(a0)
    800051d6:	413484b3          	sub	s1,s1,s3
    800051da:	0014b493          	seqz	s1,s1
    800051de:	69a2                	ld	s3,8(sp)
    800051e0:	b7f9                	j	800051ae <holdingsleep+0x22>

00000000800051e2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800051e2:	1141                	addi	sp,sp,-16
    800051e4:	e406                	sd	ra,8(sp)
    800051e6:	e022                	sd	s0,0(sp)
    800051e8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800051ea:	00004597          	auipc	a1,0x4
    800051ee:	40658593          	addi	a1,a1,1030 # 800095f0 <etext+0x5f0>
    800051f2:	00245517          	auipc	a0,0x245
    800051f6:	d2e50513          	addi	a0,a0,-722 # 80249f20 <ftable>
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	b22080e7          	jalr	-1246(ra) # 80000d1c <initlock>
}
    80005202:	60a2                	ld	ra,8(sp)
    80005204:	6402                	ld	s0,0(sp)
    80005206:	0141                	addi	sp,sp,16
    80005208:	8082                	ret

000000008000520a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000520a:	1101                	addi	sp,sp,-32
    8000520c:	ec06                	sd	ra,24(sp)
    8000520e:	e822                	sd	s0,16(sp)
    80005210:	e426                	sd	s1,8(sp)
    80005212:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005214:	00245517          	auipc	a0,0x245
    80005218:	d0c50513          	addi	a0,a0,-756 # 80249f20 <ftable>
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	b94080e7          	jalr	-1132(ra) # 80000db0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005224:	00245497          	auipc	s1,0x245
    80005228:	d1448493          	addi	s1,s1,-748 # 80249f38 <ftable+0x18>
    8000522c:	00246717          	auipc	a4,0x246
    80005230:	cac70713          	addi	a4,a4,-852 # 8024aed8 <disk>
    if(f->ref == 0){
    80005234:	40dc                	lw	a5,4(s1)
    80005236:	cf99                	beqz	a5,80005254 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005238:	02848493          	addi	s1,s1,40
    8000523c:	fee49ce3          	bne	s1,a4,80005234 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005240:	00245517          	auipc	a0,0x245
    80005244:	ce050513          	addi	a0,a0,-800 # 80249f20 <ftable>
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	c18080e7          	jalr	-1000(ra) # 80000e60 <release>
  return 0;
    80005250:	4481                	li	s1,0
    80005252:	a819                	j	80005268 <filealloc+0x5e>
      f->ref = 1;
    80005254:	4785                	li	a5,1
    80005256:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005258:	00245517          	auipc	a0,0x245
    8000525c:	cc850513          	addi	a0,a0,-824 # 80249f20 <ftable>
    80005260:	ffffc097          	auipc	ra,0xffffc
    80005264:	c00080e7          	jalr	-1024(ra) # 80000e60 <release>
}
    80005268:	8526                	mv	a0,s1
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	64a2                	ld	s1,8(sp)
    80005270:	6105                	addi	sp,sp,32
    80005272:	8082                	ret

0000000080005274 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005274:	1101                	addi	sp,sp,-32
    80005276:	ec06                	sd	ra,24(sp)
    80005278:	e822                	sd	s0,16(sp)
    8000527a:	e426                	sd	s1,8(sp)
    8000527c:	1000                	addi	s0,sp,32
    8000527e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005280:	00245517          	auipc	a0,0x245
    80005284:	ca050513          	addi	a0,a0,-864 # 80249f20 <ftable>
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	b28080e7          	jalr	-1240(ra) # 80000db0 <acquire>
  if(f->ref < 1)
    80005290:	40dc                	lw	a5,4(s1)
    80005292:	02f05263          	blez	a5,800052b6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005296:	2785                	addiw	a5,a5,1
    80005298:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000529a:	00245517          	auipc	a0,0x245
    8000529e:	c8650513          	addi	a0,a0,-890 # 80249f20 <ftable>
    800052a2:	ffffc097          	auipc	ra,0xffffc
    800052a6:	bbe080e7          	jalr	-1090(ra) # 80000e60 <release>
  return f;
}
    800052aa:	8526                	mv	a0,s1
    800052ac:	60e2                	ld	ra,24(sp)
    800052ae:	6442                	ld	s0,16(sp)
    800052b0:	64a2                	ld	s1,8(sp)
    800052b2:	6105                	addi	sp,sp,32
    800052b4:	8082                	ret
    panic("filedup");
    800052b6:	00004517          	auipc	a0,0x4
    800052ba:	34250513          	addi	a0,a0,834 # 800095f8 <etext+0x5f8>
    800052be:	ffffb097          	auipc	ra,0xffffb
    800052c2:	2a2080e7          	jalr	674(ra) # 80000560 <panic>

00000000800052c6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800052c6:	7139                	addi	sp,sp,-64
    800052c8:	fc06                	sd	ra,56(sp)
    800052ca:	f822                	sd	s0,48(sp)
    800052cc:	f426                	sd	s1,40(sp)
    800052ce:	0080                	addi	s0,sp,64
    800052d0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800052d2:	00245517          	auipc	a0,0x245
    800052d6:	c4e50513          	addi	a0,a0,-946 # 80249f20 <ftable>
    800052da:	ffffc097          	auipc	ra,0xffffc
    800052de:	ad6080e7          	jalr	-1322(ra) # 80000db0 <acquire>
  if(f->ref < 1)
    800052e2:	40dc                	lw	a5,4(s1)
    800052e4:	04f05a63          	blez	a5,80005338 <fileclose+0x72>
    panic("fileclose");
  if(--f->ref > 0){
    800052e8:	37fd                	addiw	a5,a5,-1
    800052ea:	c0dc                	sw	a5,4(s1)
    800052ec:	06f04263          	bgtz	a5,80005350 <fileclose+0x8a>
    800052f0:	f04a                	sd	s2,32(sp)
    800052f2:	ec4e                	sd	s3,24(sp)
    800052f4:	e852                	sd	s4,16(sp)
    800052f6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800052f8:	0004a903          	lw	s2,0(s1)
    800052fc:	0094ca83          	lbu	s5,9(s1)
    80005300:	0104ba03          	ld	s4,16(s1)
    80005304:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005308:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000530c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005310:	00245517          	auipc	a0,0x245
    80005314:	c1050513          	addi	a0,a0,-1008 # 80249f20 <ftable>
    80005318:	ffffc097          	auipc	ra,0xffffc
    8000531c:	b48080e7          	jalr	-1208(ra) # 80000e60 <release>

  if(ff.type == FD_PIPE){
    80005320:	4785                	li	a5,1
    80005322:	04f90463          	beq	s2,a5,8000536a <fileclose+0xa4>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005326:	3979                	addiw	s2,s2,-2
    80005328:	4785                	li	a5,1
    8000532a:	0527fb63          	bgeu	a5,s2,80005380 <fileclose+0xba>
    8000532e:	7902                	ld	s2,32(sp)
    80005330:	69e2                	ld	s3,24(sp)
    80005332:	6a42                	ld	s4,16(sp)
    80005334:	6aa2                	ld	s5,8(sp)
    80005336:	a02d                	j	80005360 <fileclose+0x9a>
    80005338:	f04a                	sd	s2,32(sp)
    8000533a:	ec4e                	sd	s3,24(sp)
    8000533c:	e852                	sd	s4,16(sp)
    8000533e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005340:	00004517          	auipc	a0,0x4
    80005344:	2c050513          	addi	a0,a0,704 # 80009600 <etext+0x600>
    80005348:	ffffb097          	auipc	ra,0xffffb
    8000534c:	218080e7          	jalr	536(ra) # 80000560 <panic>
    release(&ftable.lock);
    80005350:	00245517          	auipc	a0,0x245
    80005354:	bd050513          	addi	a0,a0,-1072 # 80249f20 <ftable>
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	b08080e7          	jalr	-1272(ra) # 80000e60 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005360:	70e2                	ld	ra,56(sp)
    80005362:	7442                	ld	s0,48(sp)
    80005364:	74a2                	ld	s1,40(sp)
    80005366:	6121                	addi	sp,sp,64
    80005368:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000536a:	85d6                	mv	a1,s5
    8000536c:	8552                	mv	a0,s4
    8000536e:	00000097          	auipc	ra,0x0
    80005372:	3ac080e7          	jalr	940(ra) # 8000571a <pipeclose>
    80005376:	7902                	ld	s2,32(sp)
    80005378:	69e2                	ld	s3,24(sp)
    8000537a:	6a42                	ld	s4,16(sp)
    8000537c:	6aa2                	ld	s5,8(sp)
    8000537e:	b7cd                	j	80005360 <fileclose+0x9a>
    begin_op();
    80005380:	00000097          	auipc	ra,0x0
    80005384:	a76080e7          	jalr	-1418(ra) # 80004df6 <begin_op>
    iput(ff.ip);
    80005388:	854e                	mv	a0,s3
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	240080e7          	jalr	576(ra) # 800045ca <iput>
    end_op();
    80005392:	00000097          	auipc	ra,0x0
    80005396:	ade080e7          	jalr	-1314(ra) # 80004e70 <end_op>
    8000539a:	7902                	ld	s2,32(sp)
    8000539c:	69e2                	ld	s3,24(sp)
    8000539e:	6a42                	ld	s4,16(sp)
    800053a0:	6aa2                	ld	s5,8(sp)
    800053a2:	bf7d                	j	80005360 <fileclose+0x9a>

00000000800053a4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800053a4:	715d                	addi	sp,sp,-80
    800053a6:	e486                	sd	ra,72(sp)
    800053a8:	e0a2                	sd	s0,64(sp)
    800053aa:	fc26                	sd	s1,56(sp)
    800053ac:	f44e                	sd	s3,40(sp)
    800053ae:	0880                	addi	s0,sp,80
    800053b0:	84aa                	mv	s1,a0
    800053b2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800053b4:	ffffd097          	auipc	ra,0xffffd
    800053b8:	aca080e7          	jalr	-1334(ra) # 80001e7e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800053bc:	409c                	lw	a5,0(s1)
    800053be:	37f9                	addiw	a5,a5,-2
    800053c0:	4705                	li	a4,1
    800053c2:	04f76a63          	bltu	a4,a5,80005416 <filestat+0x72>
    800053c6:	f84a                	sd	s2,48(sp)
    800053c8:	f052                	sd	s4,32(sp)
    800053ca:	892a                	mv	s2,a0
    ilock(f->ip);
    800053cc:	6c88                	ld	a0,24(s1)
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	03e080e7          	jalr	62(ra) # 8000440c <ilock>
    stati(f->ip, &st);
    800053d6:	fb840a13          	addi	s4,s0,-72
    800053da:	85d2                	mv	a1,s4
    800053dc:	6c88                	ld	a0,24(s1)
    800053de:	fffff097          	auipc	ra,0xfffff
    800053e2:	2bc080e7          	jalr	700(ra) # 8000469a <stati>
    iunlock(f->ip);
    800053e6:	6c88                	ld	a0,24(s1)
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	0ea080e7          	jalr	234(ra) # 800044d2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800053f0:	46e1                	li	a3,24
    800053f2:	8652                	mv	a2,s4
    800053f4:	85ce                	mv	a1,s3
    800053f6:	22893503          	ld	a0,552(s2)
    800053fa:	ffffc097          	auipc	ra,0xffffc
    800053fe:	578080e7          	jalr	1400(ra) # 80001972 <copyout>
    80005402:	41f5551b          	sraiw	a0,a0,0x1f
    80005406:	7942                	ld	s2,48(sp)
    80005408:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000540a:	60a6                	ld	ra,72(sp)
    8000540c:	6406                	ld	s0,64(sp)
    8000540e:	74e2                	ld	s1,56(sp)
    80005410:	79a2                	ld	s3,40(sp)
    80005412:	6161                	addi	sp,sp,80
    80005414:	8082                	ret
  return -1;
    80005416:	557d                	li	a0,-1
    80005418:	bfcd                	j	8000540a <filestat+0x66>

000000008000541a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000541a:	7179                	addi	sp,sp,-48
    8000541c:	f406                	sd	ra,40(sp)
    8000541e:	f022                	sd	s0,32(sp)
    80005420:	e84a                	sd	s2,16(sp)
    80005422:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005424:	00854783          	lbu	a5,8(a0)
    80005428:	cbc5                	beqz	a5,800054d8 <fileread+0xbe>
    8000542a:	ec26                	sd	s1,24(sp)
    8000542c:	e44e                	sd	s3,8(sp)
    8000542e:	84aa                	mv	s1,a0
    80005430:	89ae                	mv	s3,a1
    80005432:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005434:	411c                	lw	a5,0(a0)
    80005436:	4705                	li	a4,1
    80005438:	04e78963          	beq	a5,a4,8000548a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000543c:	470d                	li	a4,3
    8000543e:	04e78f63          	beq	a5,a4,8000549c <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005442:	4709                	li	a4,2
    80005444:	08e79263          	bne	a5,a4,800054c8 <fileread+0xae>
    ilock(f->ip);
    80005448:	6d08                	ld	a0,24(a0)
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	fc2080e7          	jalr	-62(ra) # 8000440c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005452:	874a                	mv	a4,s2
    80005454:	5094                	lw	a3,32(s1)
    80005456:	864e                	mv	a2,s3
    80005458:	4585                	li	a1,1
    8000545a:	6c88                	ld	a0,24(s1)
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	26c080e7          	jalr	620(ra) # 800046c8 <readi>
    80005464:	892a                	mv	s2,a0
    80005466:	00a05563          	blez	a0,80005470 <fileread+0x56>
      f->off += r;
    8000546a:	509c                	lw	a5,32(s1)
    8000546c:	9fa9                	addw	a5,a5,a0
    8000546e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005470:	6c88                	ld	a0,24(s1)
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	060080e7          	jalr	96(ra) # 800044d2 <iunlock>
    8000547a:	64e2                	ld	s1,24(sp)
    8000547c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000547e:	854a                	mv	a0,s2
    80005480:	70a2                	ld	ra,40(sp)
    80005482:	7402                	ld	s0,32(sp)
    80005484:	6942                	ld	s2,16(sp)
    80005486:	6145                	addi	sp,sp,48
    80005488:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000548a:	6908                	ld	a0,16(a0)
    8000548c:	00000097          	auipc	ra,0x0
    80005490:	41a080e7          	jalr	1050(ra) # 800058a6 <piperead>
    80005494:	892a                	mv	s2,a0
    80005496:	64e2                	ld	s1,24(sp)
    80005498:	69a2                	ld	s3,8(sp)
    8000549a:	b7d5                	j	8000547e <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000549c:	02451783          	lh	a5,36(a0)
    800054a0:	03079693          	slli	a3,a5,0x30
    800054a4:	92c1                	srli	a3,a3,0x30
    800054a6:	4725                	li	a4,9
    800054a8:	02d76a63          	bltu	a4,a3,800054dc <fileread+0xc2>
    800054ac:	0792                	slli	a5,a5,0x4
    800054ae:	00245717          	auipc	a4,0x245
    800054b2:	9d270713          	addi	a4,a4,-1582 # 80249e80 <devsw>
    800054b6:	97ba                	add	a5,a5,a4
    800054b8:	639c                	ld	a5,0(a5)
    800054ba:	c78d                	beqz	a5,800054e4 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800054bc:	4505                	li	a0,1
    800054be:	9782                	jalr	a5
    800054c0:	892a                	mv	s2,a0
    800054c2:	64e2                	ld	s1,24(sp)
    800054c4:	69a2                	ld	s3,8(sp)
    800054c6:	bf65                	j	8000547e <fileread+0x64>
    panic("fileread");
    800054c8:	00004517          	auipc	a0,0x4
    800054cc:	14850513          	addi	a0,a0,328 # 80009610 <etext+0x610>
    800054d0:	ffffb097          	auipc	ra,0xffffb
    800054d4:	090080e7          	jalr	144(ra) # 80000560 <panic>
    return -1;
    800054d8:	597d                	li	s2,-1
    800054da:	b755                	j	8000547e <fileread+0x64>
      return -1;
    800054dc:	597d                	li	s2,-1
    800054de:	64e2                	ld	s1,24(sp)
    800054e0:	69a2                	ld	s3,8(sp)
    800054e2:	bf71                	j	8000547e <fileread+0x64>
    800054e4:	597d                	li	s2,-1
    800054e6:	64e2                	ld	s1,24(sp)
    800054e8:	69a2                	ld	s3,8(sp)
    800054ea:	bf51                	j	8000547e <fileread+0x64>

00000000800054ec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800054ec:	00954783          	lbu	a5,9(a0)
    800054f0:	12078c63          	beqz	a5,80005628 <filewrite+0x13c>
{
    800054f4:	711d                	addi	sp,sp,-96
    800054f6:	ec86                	sd	ra,88(sp)
    800054f8:	e8a2                	sd	s0,80(sp)
    800054fa:	e0ca                	sd	s2,64(sp)
    800054fc:	f456                	sd	s5,40(sp)
    800054fe:	f05a                	sd	s6,32(sp)
    80005500:	1080                	addi	s0,sp,96
    80005502:	892a                	mv	s2,a0
    80005504:	8b2e                	mv	s6,a1
    80005506:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80005508:	411c                	lw	a5,0(a0)
    8000550a:	4705                	li	a4,1
    8000550c:	02e78963          	beq	a5,a4,8000553e <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005510:	470d                	li	a4,3
    80005512:	02e78c63          	beq	a5,a4,8000554a <filewrite+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005516:	4709                	li	a4,2
    80005518:	0ee79a63          	bne	a5,a4,8000560c <filewrite+0x120>
    8000551c:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000551e:	0cc05563          	blez	a2,800055e8 <filewrite+0xfc>
    80005522:	e4a6                	sd	s1,72(sp)
    80005524:	fc4e                	sd	s3,56(sp)
    80005526:	ec5e                	sd	s7,24(sp)
    80005528:	e862                	sd	s8,16(sp)
    8000552a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000552c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000552e:	6b85                	lui	s7,0x1
    80005530:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005534:	6c85                	lui	s9,0x1
    80005536:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000553a:	4c05                	li	s8,1
    8000553c:	a849                	j	800055ce <filewrite+0xe2>
    ret = pipewrite(f->pipe, addr, n);
    8000553e:	6908                	ld	a0,16(a0)
    80005540:	00000097          	auipc	ra,0x0
    80005544:	24a080e7          	jalr	586(ra) # 8000578a <pipewrite>
    80005548:	a85d                	j	800055fe <filewrite+0x112>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000554a:	02451783          	lh	a5,36(a0)
    8000554e:	03079693          	slli	a3,a5,0x30
    80005552:	92c1                	srli	a3,a3,0x30
    80005554:	4725                	li	a4,9
    80005556:	0cd76b63          	bltu	a4,a3,8000562c <filewrite+0x140>
    8000555a:	0792                	slli	a5,a5,0x4
    8000555c:	00245717          	auipc	a4,0x245
    80005560:	92470713          	addi	a4,a4,-1756 # 80249e80 <devsw>
    80005564:	97ba                	add	a5,a5,a4
    80005566:	679c                	ld	a5,8(a5)
    80005568:	c7e1                	beqz	a5,80005630 <filewrite+0x144>
    ret = devsw[f->major].write(1, addr, n);
    8000556a:	4505                	li	a0,1
    8000556c:	9782                	jalr	a5
    8000556e:	a841                	j	800055fe <filewrite+0x112>
      if(n1 > max)
    80005570:	2981                	sext.w	s3,s3
      begin_op();
    80005572:	00000097          	auipc	ra,0x0
    80005576:	884080e7          	jalr	-1916(ra) # 80004df6 <begin_op>
      ilock(f->ip);
    8000557a:	01893503          	ld	a0,24(s2)
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	e8e080e7          	jalr	-370(ra) # 8000440c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005586:	874e                	mv	a4,s3
    80005588:	02092683          	lw	a3,32(s2)
    8000558c:	016a0633          	add	a2,s4,s6
    80005590:	85e2                	mv	a1,s8
    80005592:	01893503          	ld	a0,24(s2)
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	238080e7          	jalr	568(ra) # 800047ce <writei>
    8000559e:	84aa                	mv	s1,a0
    800055a0:	00a05763          	blez	a0,800055ae <filewrite+0xc2>
        f->off += r;
    800055a4:	02092783          	lw	a5,32(s2)
    800055a8:	9fa9                	addw	a5,a5,a0
    800055aa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800055ae:	01893503          	ld	a0,24(s2)
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	f20080e7          	jalr	-224(ra) # 800044d2 <iunlock>
      end_op();
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	8b6080e7          	jalr	-1866(ra) # 80004e70 <end_op>

      if(r != n1){
    800055c2:	02999563          	bne	s3,s1,800055ec <filewrite+0x100>
        // error from writei
        break;
      }
      i += r;
    800055c6:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800055ca:	015a5963          	bge	s4,s5,800055dc <filewrite+0xf0>
      int n1 = n - i;
    800055ce:	414a87bb          	subw	a5,s5,s4
    800055d2:	89be                	mv	s3,a5
      if(n1 > max)
    800055d4:	f8fbdee3          	bge	s7,a5,80005570 <filewrite+0x84>
    800055d8:	89e6                	mv	s3,s9
    800055da:	bf59                	j	80005570 <filewrite+0x84>
    800055dc:	64a6                	ld	s1,72(sp)
    800055de:	79e2                	ld	s3,56(sp)
    800055e0:	6be2                	ld	s7,24(sp)
    800055e2:	6c42                	ld	s8,16(sp)
    800055e4:	6ca2                	ld	s9,8(sp)
    800055e6:	a801                	j	800055f6 <filewrite+0x10a>
    int i = 0;
    800055e8:	4a01                	li	s4,0
    800055ea:	a031                	j	800055f6 <filewrite+0x10a>
    800055ec:	64a6                	ld	s1,72(sp)
    800055ee:	79e2                	ld	s3,56(sp)
    800055f0:	6be2                	ld	s7,24(sp)
    800055f2:	6c42                	ld	s8,16(sp)
    800055f4:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800055f6:	034a9f63          	bne	s5,s4,80005634 <filewrite+0x148>
    800055fa:	8556                	mv	a0,s5
    800055fc:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800055fe:	60e6                	ld	ra,88(sp)
    80005600:	6446                	ld	s0,80(sp)
    80005602:	6906                	ld	s2,64(sp)
    80005604:	7aa2                	ld	s5,40(sp)
    80005606:	7b02                	ld	s6,32(sp)
    80005608:	6125                	addi	sp,sp,96
    8000560a:	8082                	ret
    8000560c:	e4a6                	sd	s1,72(sp)
    8000560e:	fc4e                	sd	s3,56(sp)
    80005610:	f852                	sd	s4,48(sp)
    80005612:	ec5e                	sd	s7,24(sp)
    80005614:	e862                	sd	s8,16(sp)
    80005616:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80005618:	00004517          	auipc	a0,0x4
    8000561c:	00850513          	addi	a0,a0,8 # 80009620 <etext+0x620>
    80005620:	ffffb097          	auipc	ra,0xffffb
    80005624:	f40080e7          	jalr	-192(ra) # 80000560 <panic>
    return -1;
    80005628:	557d                	li	a0,-1
}
    8000562a:	8082                	ret
      return -1;
    8000562c:	557d                	li	a0,-1
    8000562e:	bfc1                	j	800055fe <filewrite+0x112>
    80005630:	557d                	li	a0,-1
    80005632:	b7f1                	j	800055fe <filewrite+0x112>
    ret = (i == n ? n : -1);
    80005634:	557d                	li	a0,-1
    80005636:	7a42                	ld	s4,48(sp)
    80005638:	b7d9                	j	800055fe <filewrite+0x112>

000000008000563a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000563a:	7179                	addi	sp,sp,-48
    8000563c:	f406                	sd	ra,40(sp)
    8000563e:	f022                	sd	s0,32(sp)
    80005640:	ec26                	sd	s1,24(sp)
    80005642:	e052                	sd	s4,0(sp)
    80005644:	1800                	addi	s0,sp,48
    80005646:	84aa                	mv	s1,a0
    80005648:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000564a:	0005b023          	sd	zero,0(a1)
    8000564e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005652:	00000097          	auipc	ra,0x0
    80005656:	bb8080e7          	jalr	-1096(ra) # 8000520a <filealloc>
    8000565a:	e088                	sd	a0,0(s1)
    8000565c:	cd49                	beqz	a0,800056f6 <pipealloc+0xbc>
    8000565e:	00000097          	auipc	ra,0x0
    80005662:	bac080e7          	jalr	-1108(ra) # 8000520a <filealloc>
    80005666:	00aa3023          	sd	a0,0(s4)
    8000566a:	c141                	beqz	a0,800056ea <pipealloc+0xb0>
    8000566c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000566e:	ffffb097          	auipc	ra,0xffffb
    80005672:	644080e7          	jalr	1604(ra) # 80000cb2 <kalloc>
    80005676:	892a                	mv	s2,a0
    80005678:	c13d                	beqz	a0,800056de <pipealloc+0xa4>
    8000567a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000567c:	4985                	li	s3,1
    8000567e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005682:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005686:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000568a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000568e:	00004597          	auipc	a1,0x4
    80005692:	fa258593          	addi	a1,a1,-94 # 80009630 <etext+0x630>
    80005696:	ffffb097          	auipc	ra,0xffffb
    8000569a:	686080e7          	jalr	1670(ra) # 80000d1c <initlock>
  (*f0)->type = FD_PIPE;
    8000569e:	609c                	ld	a5,0(s1)
    800056a0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800056a4:	609c                	ld	a5,0(s1)
    800056a6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800056aa:	609c                	ld	a5,0(s1)
    800056ac:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800056b0:	609c                	ld	a5,0(s1)
    800056b2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800056b6:	000a3783          	ld	a5,0(s4)
    800056ba:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800056be:	000a3783          	ld	a5,0(s4)
    800056c2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800056c6:	000a3783          	ld	a5,0(s4)
    800056ca:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800056ce:	000a3783          	ld	a5,0(s4)
    800056d2:	0127b823          	sd	s2,16(a5)
  return 0;
    800056d6:	4501                	li	a0,0
    800056d8:	6942                	ld	s2,16(sp)
    800056da:	69a2                	ld	s3,8(sp)
    800056dc:	a03d                	j	8000570a <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800056de:	6088                	ld	a0,0(s1)
    800056e0:	c119                	beqz	a0,800056e6 <pipealloc+0xac>
    800056e2:	6942                	ld	s2,16(sp)
    800056e4:	a029                	j	800056ee <pipealloc+0xb4>
    800056e6:	6942                	ld	s2,16(sp)
    800056e8:	a039                	j	800056f6 <pipealloc+0xbc>
    800056ea:	6088                	ld	a0,0(s1)
    800056ec:	c50d                	beqz	a0,80005716 <pipealloc+0xdc>
    fileclose(*f0);
    800056ee:	00000097          	auipc	ra,0x0
    800056f2:	bd8080e7          	jalr	-1064(ra) # 800052c6 <fileclose>
  if(*f1)
    800056f6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800056fa:	557d                	li	a0,-1
  if(*f1)
    800056fc:	c799                	beqz	a5,8000570a <pipealloc+0xd0>
    fileclose(*f1);
    800056fe:	853e                	mv	a0,a5
    80005700:	00000097          	auipc	ra,0x0
    80005704:	bc6080e7          	jalr	-1082(ra) # 800052c6 <fileclose>
  return -1;
    80005708:	557d                	li	a0,-1
}
    8000570a:	70a2                	ld	ra,40(sp)
    8000570c:	7402                	ld	s0,32(sp)
    8000570e:	64e2                	ld	s1,24(sp)
    80005710:	6a02                	ld	s4,0(sp)
    80005712:	6145                	addi	sp,sp,48
    80005714:	8082                	ret
  return -1;
    80005716:	557d                	li	a0,-1
    80005718:	bfcd                	j	8000570a <pipealloc+0xd0>

000000008000571a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000571a:	1101                	addi	sp,sp,-32
    8000571c:	ec06                	sd	ra,24(sp)
    8000571e:	e822                	sd	s0,16(sp)
    80005720:	e426                	sd	s1,8(sp)
    80005722:	e04a                	sd	s2,0(sp)
    80005724:	1000                	addi	s0,sp,32
    80005726:	84aa                	mv	s1,a0
    80005728:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000572a:	ffffb097          	auipc	ra,0xffffb
    8000572e:	686080e7          	jalr	1670(ra) # 80000db0 <acquire>
  if(writable){
    80005732:	02090d63          	beqz	s2,8000576c <pipeclose+0x52>
    pi->writeopen = 0;
    80005736:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000573a:	21848513          	addi	a0,s1,536
    8000573e:	ffffd097          	auipc	ra,0xffffd
    80005742:	262080e7          	jalr	610(ra) # 800029a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005746:	2204b783          	ld	a5,544(s1)
    8000574a:	eb95                	bnez	a5,8000577e <pipeclose+0x64>
    release(&pi->lock);
    8000574c:	8526                	mv	a0,s1
    8000574e:	ffffb097          	auipc	ra,0xffffb
    80005752:	712080e7          	jalr	1810(ra) # 80000e60 <release>
    kfree((char*)pi);
    80005756:	8526                	mv	a0,s1
    80005758:	ffffb097          	auipc	ra,0xffffb
    8000575c:	3ea080e7          	jalr	1002(ra) # 80000b42 <kfree>
  } else
    release(&pi->lock);
}
    80005760:	60e2                	ld	ra,24(sp)
    80005762:	6442                	ld	s0,16(sp)
    80005764:	64a2                	ld	s1,8(sp)
    80005766:	6902                	ld	s2,0(sp)
    80005768:	6105                	addi	sp,sp,32
    8000576a:	8082                	ret
    pi->readopen = 0;
    8000576c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005770:	21c48513          	addi	a0,s1,540
    80005774:	ffffd097          	auipc	ra,0xffffd
    80005778:	22c080e7          	jalr	556(ra) # 800029a0 <wakeup>
    8000577c:	b7e9                	j	80005746 <pipeclose+0x2c>
    release(&pi->lock);
    8000577e:	8526                	mv	a0,s1
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	6e0080e7          	jalr	1760(ra) # 80000e60 <release>
}
    80005788:	bfe1                	j	80005760 <pipeclose+0x46>

000000008000578a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000578a:	7159                	addi	sp,sp,-112
    8000578c:	f486                	sd	ra,104(sp)
    8000578e:	f0a2                	sd	s0,96(sp)
    80005790:	eca6                	sd	s1,88(sp)
    80005792:	e8ca                	sd	s2,80(sp)
    80005794:	e4ce                	sd	s3,72(sp)
    80005796:	e0d2                	sd	s4,64(sp)
    80005798:	fc56                	sd	s5,56(sp)
    8000579a:	1880                	addi	s0,sp,112
    8000579c:	84aa                	mv	s1,a0
    8000579e:	8aae                	mv	s5,a1
    800057a0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800057a2:	ffffc097          	auipc	ra,0xffffc
    800057a6:	6dc080e7          	jalr	1756(ra) # 80001e7e <myproc>
    800057aa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800057ac:	8526                	mv	a0,s1
    800057ae:	ffffb097          	auipc	ra,0xffffb
    800057b2:	602080e7          	jalr	1538(ra) # 80000db0 <acquire>
  while(i < n){
    800057b6:	0f405063          	blez	s4,80005896 <pipewrite+0x10c>
    800057ba:	f85a                	sd	s6,48(sp)
    800057bc:	f45e                	sd	s7,40(sp)
    800057be:	f062                	sd	s8,32(sp)
    800057c0:	ec66                	sd	s9,24(sp)
    800057c2:	e86a                	sd	s10,16(sp)
  int i = 0;
    800057c4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800057c6:	f9f40c13          	addi	s8,s0,-97
    800057ca:	4b85                	li	s7,1
    800057cc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800057ce:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800057d2:	21c48c93          	addi	s9,s1,540
    800057d6:	a099                	j	8000581c <pipewrite+0x92>
      release(&pi->lock);
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffb097          	auipc	ra,0xffffb
    800057de:	686080e7          	jalr	1670(ra) # 80000e60 <release>
      return -1;
    800057e2:	597d                	li	s2,-1
    800057e4:	7b42                	ld	s6,48(sp)
    800057e6:	7ba2                	ld	s7,40(sp)
    800057e8:	7c02                	ld	s8,32(sp)
    800057ea:	6ce2                	ld	s9,24(sp)
    800057ec:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800057ee:	854a                	mv	a0,s2
    800057f0:	70a6                	ld	ra,104(sp)
    800057f2:	7406                	ld	s0,96(sp)
    800057f4:	64e6                	ld	s1,88(sp)
    800057f6:	6946                	ld	s2,80(sp)
    800057f8:	69a6                	ld	s3,72(sp)
    800057fa:	6a06                	ld	s4,64(sp)
    800057fc:	7ae2                	ld	s5,56(sp)
    800057fe:	6165                	addi	sp,sp,112
    80005800:	8082                	ret
      wakeup(&pi->nread);
    80005802:	856a                	mv	a0,s10
    80005804:	ffffd097          	auipc	ra,0xffffd
    80005808:	19c080e7          	jalr	412(ra) # 800029a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000580c:	85a6                	mv	a1,s1
    8000580e:	8566                	mv	a0,s9
    80005810:	ffffd097          	auipc	ra,0xffffd
    80005814:	12c080e7          	jalr	300(ra) # 8000293c <sleep>
  while(i < n){
    80005818:	05495e63          	bge	s2,s4,80005874 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    8000581c:	2204a783          	lw	a5,544(s1)
    80005820:	dfc5                	beqz	a5,800057d8 <pipewrite+0x4e>
    80005822:	854e                	mv	a0,s3
    80005824:	ffffd097          	auipc	ra,0xffffd
    80005828:	3e8080e7          	jalr	1000(ra) # 80002c0c <killed>
    8000582c:	f555                	bnez	a0,800057d8 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000582e:	2184a783          	lw	a5,536(s1)
    80005832:	21c4a703          	lw	a4,540(s1)
    80005836:	2007879b          	addiw	a5,a5,512
    8000583a:	fcf704e3          	beq	a4,a5,80005802 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000583e:	86de                	mv	a3,s7
    80005840:	01590633          	add	a2,s2,s5
    80005844:	85e2                	mv	a1,s8
    80005846:	2289b503          	ld	a0,552(s3)
    8000584a:	ffffc097          	auipc	ra,0xffffc
    8000584e:	1b4080e7          	jalr	436(ra) # 800019fe <copyin>
    80005852:	05650463          	beq	a0,s6,8000589a <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005856:	21c4a783          	lw	a5,540(s1)
    8000585a:	0017871b          	addiw	a4,a5,1
    8000585e:	20e4ae23          	sw	a4,540(s1)
    80005862:	1ff7f793          	andi	a5,a5,511
    80005866:	97a6                	add	a5,a5,s1
    80005868:	f9f44703          	lbu	a4,-97(s0)
    8000586c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005870:	2905                	addiw	s2,s2,1
    80005872:	b75d                	j	80005818 <pipewrite+0x8e>
    80005874:	7b42                	ld	s6,48(sp)
    80005876:	7ba2                	ld	s7,40(sp)
    80005878:	7c02                	ld	s8,32(sp)
    8000587a:	6ce2                	ld	s9,24(sp)
    8000587c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000587e:	21848513          	addi	a0,s1,536
    80005882:	ffffd097          	auipc	ra,0xffffd
    80005886:	11e080e7          	jalr	286(ra) # 800029a0 <wakeup>
  release(&pi->lock);
    8000588a:	8526                	mv	a0,s1
    8000588c:	ffffb097          	auipc	ra,0xffffb
    80005890:	5d4080e7          	jalr	1492(ra) # 80000e60 <release>
  return i;
    80005894:	bfa9                	j	800057ee <pipewrite+0x64>
  int i = 0;
    80005896:	4901                	li	s2,0
    80005898:	b7dd                	j	8000587e <pipewrite+0xf4>
    8000589a:	7b42                	ld	s6,48(sp)
    8000589c:	7ba2                	ld	s7,40(sp)
    8000589e:	7c02                	ld	s8,32(sp)
    800058a0:	6ce2                	ld	s9,24(sp)
    800058a2:	6d42                	ld	s10,16(sp)
    800058a4:	bfe9                	j	8000587e <pipewrite+0xf4>

00000000800058a6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800058a6:	711d                	addi	sp,sp,-96
    800058a8:	ec86                	sd	ra,88(sp)
    800058aa:	e8a2                	sd	s0,80(sp)
    800058ac:	e4a6                	sd	s1,72(sp)
    800058ae:	e0ca                	sd	s2,64(sp)
    800058b0:	fc4e                	sd	s3,56(sp)
    800058b2:	f852                	sd	s4,48(sp)
    800058b4:	f456                	sd	s5,40(sp)
    800058b6:	1080                	addi	s0,sp,96
    800058b8:	84aa                	mv	s1,a0
    800058ba:	892e                	mv	s2,a1
    800058bc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800058be:	ffffc097          	auipc	ra,0xffffc
    800058c2:	5c0080e7          	jalr	1472(ra) # 80001e7e <myproc>
    800058c6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffb097          	auipc	ra,0xffffb
    800058ce:	4e6080e7          	jalr	1254(ra) # 80000db0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800058d2:	2184a703          	lw	a4,536(s1)
    800058d6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800058da:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800058de:	02f71b63          	bne	a4,a5,80005914 <piperead+0x6e>
    800058e2:	2244a783          	lw	a5,548(s1)
    800058e6:	c3b1                	beqz	a5,8000592a <piperead+0x84>
    if(killed(pr)){
    800058e8:	8552                	mv	a0,s4
    800058ea:	ffffd097          	auipc	ra,0xffffd
    800058ee:	322080e7          	jalr	802(ra) # 80002c0c <killed>
    800058f2:	e50d                	bnez	a0,8000591c <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800058f4:	85a6                	mv	a1,s1
    800058f6:	854e                	mv	a0,s3
    800058f8:	ffffd097          	auipc	ra,0xffffd
    800058fc:	044080e7          	jalr	68(ra) # 8000293c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005900:	2184a703          	lw	a4,536(s1)
    80005904:	21c4a783          	lw	a5,540(s1)
    80005908:	fcf70de3          	beq	a4,a5,800058e2 <piperead+0x3c>
    8000590c:	f05a                	sd	s6,32(sp)
    8000590e:	ec5e                	sd	s7,24(sp)
    80005910:	e862                	sd	s8,16(sp)
    80005912:	a839                	j	80005930 <piperead+0x8a>
    80005914:	f05a                	sd	s6,32(sp)
    80005916:	ec5e                	sd	s7,24(sp)
    80005918:	e862                	sd	s8,16(sp)
    8000591a:	a819                	j	80005930 <piperead+0x8a>
      release(&pi->lock);
    8000591c:	8526                	mv	a0,s1
    8000591e:	ffffb097          	auipc	ra,0xffffb
    80005922:	542080e7          	jalr	1346(ra) # 80000e60 <release>
      return -1;
    80005926:	59fd                	li	s3,-1
    80005928:	a895                	j	8000599c <piperead+0xf6>
    8000592a:	f05a                	sd	s6,32(sp)
    8000592c:	ec5e                	sd	s7,24(sp)
    8000592e:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005930:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005932:	faf40c13          	addi	s8,s0,-81
    80005936:	4b85                	li	s7,1
    80005938:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000593a:	05505363          	blez	s5,80005980 <piperead+0xda>
    if(pi->nread == pi->nwrite)
    8000593e:	2184a783          	lw	a5,536(s1)
    80005942:	21c4a703          	lw	a4,540(s1)
    80005946:	02f70d63          	beq	a4,a5,80005980 <piperead+0xda>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000594a:	0017871b          	addiw	a4,a5,1
    8000594e:	20e4ac23          	sw	a4,536(s1)
    80005952:	1ff7f793          	andi	a5,a5,511
    80005956:	97a6                	add	a5,a5,s1
    80005958:	0187c783          	lbu	a5,24(a5)
    8000595c:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005960:	86de                	mv	a3,s7
    80005962:	8662                	mv	a2,s8
    80005964:	85ca                	mv	a1,s2
    80005966:	228a3503          	ld	a0,552(s4)
    8000596a:	ffffc097          	auipc	ra,0xffffc
    8000596e:	008080e7          	jalr	8(ra) # 80001972 <copyout>
    80005972:	01650763          	beq	a0,s6,80005980 <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005976:	2985                	addiw	s3,s3,1
    80005978:	0905                	addi	s2,s2,1
    8000597a:	fd3a92e3          	bne	s5,s3,8000593e <piperead+0x98>
    8000597e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005980:	21c48513          	addi	a0,s1,540
    80005984:	ffffd097          	auipc	ra,0xffffd
    80005988:	01c080e7          	jalr	28(ra) # 800029a0 <wakeup>
  release(&pi->lock);
    8000598c:	8526                	mv	a0,s1
    8000598e:	ffffb097          	auipc	ra,0xffffb
    80005992:	4d2080e7          	jalr	1234(ra) # 80000e60 <release>
    80005996:	7b02                	ld	s6,32(sp)
    80005998:	6be2                	ld	s7,24(sp)
    8000599a:	6c42                	ld	s8,16(sp)
  return i;
}
    8000599c:	854e                	mv	a0,s3
    8000599e:	60e6                	ld	ra,88(sp)
    800059a0:	6446                	ld	s0,80(sp)
    800059a2:	64a6                	ld	s1,72(sp)
    800059a4:	6906                	ld	s2,64(sp)
    800059a6:	79e2                	ld	s3,56(sp)
    800059a8:	7a42                	ld	s4,48(sp)
    800059aa:	7aa2                	ld	s5,40(sp)
    800059ac:	6125                	addi	sp,sp,96
    800059ae:	8082                	ret

00000000800059b0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800059b0:	1141                	addi	sp,sp,-16
    800059b2:	e406                	sd	ra,8(sp)
    800059b4:	e022                	sd	s0,0(sp)
    800059b6:	0800                	addi	s0,sp,16
    800059b8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800059ba:	0035151b          	slliw	a0,a0,0x3
    800059be:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800059c0:	8b89                	andi	a5,a5,2
    800059c2:	c399                	beqz	a5,800059c8 <flags2perm+0x18>
      perm |= PTE_W;
    800059c4:	00456513          	ori	a0,a0,4
    return perm;
}
    800059c8:	60a2                	ld	ra,8(sp)
    800059ca:	6402                	ld	s0,0(sp)
    800059cc:	0141                	addi	sp,sp,16
    800059ce:	8082                	ret

00000000800059d0 <exec>:

int
exec(char *path, char **argv)
{
    800059d0:	de010113          	addi	sp,sp,-544
    800059d4:	20113c23          	sd	ra,536(sp)
    800059d8:	20813823          	sd	s0,528(sp)
    800059dc:	20913423          	sd	s1,520(sp)
    800059e0:	21213023          	sd	s2,512(sp)
    800059e4:	1400                	addi	s0,sp,544
    800059e6:	892a                	mv	s2,a0
    800059e8:	dea43823          	sd	a0,-528(s0)
    800059ec:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800059f0:	ffffc097          	auipc	ra,0xffffc
    800059f4:	48e080e7          	jalr	1166(ra) # 80001e7e <myproc>
    800059f8:	84aa                	mv	s1,a0

  begin_op();
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	3fc080e7          	jalr	1020(ra) # 80004df6 <begin_op>

  if((ip = namei(path)) == 0){
    80005a02:	854a                	mv	a0,s2
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	1ec080e7          	jalr	492(ra) # 80004bf0 <namei>
    80005a0c:	c525                	beqz	a0,80005a74 <exec+0xa4>
    80005a0e:	fbd2                	sd	s4,496(sp)
    80005a10:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	9fa080e7          	jalr	-1542(ra) # 8000440c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005a1a:	04000713          	li	a4,64
    80005a1e:	4681                	li	a3,0
    80005a20:	e5040613          	addi	a2,s0,-432
    80005a24:	4581                	li	a1,0
    80005a26:	8552                	mv	a0,s4
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	ca0080e7          	jalr	-864(ra) # 800046c8 <readi>
    80005a30:	04000793          	li	a5,64
    80005a34:	00f51a63          	bne	a0,a5,80005a48 <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005a38:	e5042703          	lw	a4,-432(s0)
    80005a3c:	464c47b7          	lui	a5,0x464c4
    80005a40:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005a44:	02f70e63          	beq	a4,a5,80005a80 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005a48:	8552                	mv	a0,s4
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	c28080e7          	jalr	-984(ra) # 80004672 <iunlockput>
    end_op();
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	41e080e7          	jalr	1054(ra) # 80004e70 <end_op>
  }
  return -1;
    80005a5a:	557d                	li	a0,-1
    80005a5c:	7a5e                	ld	s4,496(sp)
}
    80005a5e:	21813083          	ld	ra,536(sp)
    80005a62:	21013403          	ld	s0,528(sp)
    80005a66:	20813483          	ld	s1,520(sp)
    80005a6a:	20013903          	ld	s2,512(sp)
    80005a6e:	22010113          	addi	sp,sp,544
    80005a72:	8082                	ret
    end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	3fc080e7          	jalr	1020(ra) # 80004e70 <end_op>
    return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	b7c5                	j	80005a5e <exec+0x8e>
    80005a80:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005a82:	8526                	mv	a0,s1
    80005a84:	ffffc097          	auipc	ra,0xffffc
    80005a88:	4be080e7          	jalr	1214(ra) # 80001f42 <proc_pagetable>
    80005a8c:	8b2a                	mv	s6,a0
    80005a8e:	2c050163          	beqz	a0,80005d50 <exec+0x380>
    80005a92:	ffce                	sd	s3,504(sp)
    80005a94:	f7d6                	sd	s5,488(sp)
    80005a96:	efde                	sd	s7,472(sp)
    80005a98:	ebe2                	sd	s8,464(sp)
    80005a9a:	e7e6                	sd	s9,456(sp)
    80005a9c:	e3ea                	sd	s10,448(sp)
    80005a9e:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005aa0:	e7042683          	lw	a3,-400(s0)
    80005aa4:	e8845783          	lhu	a5,-376(s0)
    80005aa8:	10078363          	beqz	a5,80005bae <exec+0x1de>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005aac:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005aae:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005ab0:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80005ab4:	6c85                	lui	s9,0x1
    80005ab6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005aba:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005abe:	6a85                	lui	s5,0x1
    80005ac0:	a0b5                	j	80005b2c <exec+0x15c>
      panic("loadseg: address should exist");
    80005ac2:	00004517          	auipc	a0,0x4
    80005ac6:	b7650513          	addi	a0,a0,-1162 # 80009638 <etext+0x638>
    80005aca:	ffffb097          	auipc	ra,0xffffb
    80005ace:	a96080e7          	jalr	-1386(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005ad2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005ad4:	874a                	mv	a4,s2
    80005ad6:	009c06bb          	addw	a3,s8,s1
    80005ada:	4581                	li	a1,0
    80005adc:	8552                	mv	a0,s4
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	bea080e7          	jalr	-1046(ra) # 800046c8 <readi>
    80005ae6:	26a91963          	bne	s2,a0,80005d58 <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    80005aea:	009a84bb          	addw	s1,s5,s1
    80005aee:	0334f463          	bgeu	s1,s3,80005b16 <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80005af2:	02049593          	slli	a1,s1,0x20
    80005af6:	9181                	srli	a1,a1,0x20
    80005af8:	95de                	add	a1,a1,s7
    80005afa:	855a                	mv	a0,s6
    80005afc:	ffffb097          	auipc	ra,0xffffb
    80005b00:	74e080e7          	jalr	1870(ra) # 8000124a <walkaddr>
    80005b04:	862a                	mv	a2,a0
    if(pa == 0)
    80005b06:	dd55                	beqz	a0,80005ac2 <exec+0xf2>
    if(sz - i < PGSIZE)
    80005b08:	409987bb          	subw	a5,s3,s1
    80005b0c:	893e                	mv	s2,a5
    80005b0e:	fcfcf2e3          	bgeu	s9,a5,80005ad2 <exec+0x102>
    80005b12:	8956                	mv	s2,s5
    80005b14:	bf7d                	j	80005ad2 <exec+0x102>
    sz = sz1;
    80005b16:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b1a:	2d05                	addiw	s10,s10,1
    80005b1c:	e0843783          	ld	a5,-504(s0)
    80005b20:	0387869b          	addiw	a3,a5,56
    80005b24:	e8845783          	lhu	a5,-376(s0)
    80005b28:	08fd5463          	bge	s10,a5,80005bb0 <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005b2c:	e0d43423          	sd	a3,-504(s0)
    80005b30:	876e                	mv	a4,s11
    80005b32:	e1840613          	addi	a2,s0,-488
    80005b36:	4581                	li	a1,0
    80005b38:	8552                	mv	a0,s4
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	b8e080e7          	jalr	-1138(ra) # 800046c8 <readi>
    80005b42:	21b51963          	bne	a0,s11,80005d54 <exec+0x384>
    if(ph.type != ELF_PROG_LOAD)
    80005b46:	e1842783          	lw	a5,-488(s0)
    80005b4a:	4705                	li	a4,1
    80005b4c:	fce797e3          	bne	a5,a4,80005b1a <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80005b50:	e4043483          	ld	s1,-448(s0)
    80005b54:	e3843783          	ld	a5,-456(s0)
    80005b58:	22f4e063          	bltu	s1,a5,80005d78 <exec+0x3a8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005b5c:	e2843783          	ld	a5,-472(s0)
    80005b60:	94be                	add	s1,s1,a5
    80005b62:	20f4ee63          	bltu	s1,a5,80005d7e <exec+0x3ae>
    if(ph.vaddr % PGSIZE != 0)
    80005b66:	de843703          	ld	a4,-536(s0)
    80005b6a:	8ff9                	and	a5,a5,a4
    80005b6c:	20079c63          	bnez	a5,80005d84 <exec+0x3b4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005b70:	e1c42503          	lw	a0,-484(s0)
    80005b74:	00000097          	auipc	ra,0x0
    80005b78:	e3c080e7          	jalr	-452(ra) # 800059b0 <flags2perm>
    80005b7c:	86aa                	mv	a3,a0
    80005b7e:	8626                	mv	a2,s1
    80005b80:	85ca                	mv	a1,s2
    80005b82:	855a                	mv	a0,s6
    80005b84:	ffffc097          	auipc	ra,0xffffc
    80005b88:	a8a080e7          	jalr	-1398(ra) # 8000160e <uvmalloc>
    80005b8c:	dea43c23          	sd	a0,-520(s0)
    80005b90:	1e050d63          	beqz	a0,80005d8a <exec+0x3ba>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005b94:	e2843b83          	ld	s7,-472(s0)
    80005b98:	e2042c03          	lw	s8,-480(s0)
    80005b9c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005ba0:	00098463          	beqz	s3,80005ba8 <exec+0x1d8>
    80005ba4:	4481                	li	s1,0
    80005ba6:	b7b1                	j	80005af2 <exec+0x122>
    sz = sz1;
    80005ba8:	df843903          	ld	s2,-520(s0)
    80005bac:	b7bd                	j	80005b1a <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005bae:	4901                	li	s2,0
  iunlockput(ip);
    80005bb0:	8552                	mv	a0,s4
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	ac0080e7          	jalr	-1344(ra) # 80004672 <iunlockput>
  end_op();
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	2b6080e7          	jalr	694(ra) # 80004e70 <end_op>
  p = myproc();
    80005bc2:	ffffc097          	auipc	ra,0xffffc
    80005bc6:	2bc080e7          	jalr	700(ra) # 80001e7e <myproc>
    80005bca:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005bcc:	22053d03          	ld	s10,544(a0)
  sz = PGROUNDUP(sz);
    80005bd0:	6985                	lui	s3,0x1
    80005bd2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005bd4:	99ca                	add	s3,s3,s2
    80005bd6:	77fd                	lui	a5,0xfffff
    80005bd8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005bdc:	4691                	li	a3,4
    80005bde:	6609                	lui	a2,0x2
    80005be0:	964e                	add	a2,a2,s3
    80005be2:	85ce                	mv	a1,s3
    80005be4:	855a                	mv	a0,s6
    80005be6:	ffffc097          	auipc	ra,0xffffc
    80005bea:	a28080e7          	jalr	-1496(ra) # 8000160e <uvmalloc>
    80005bee:	8a2a                	mv	s4,a0
    80005bf0:	e115                	bnez	a0,80005c14 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005bf2:	85ce                	mv	a1,s3
    80005bf4:	855a                	mv	a0,s6
    80005bf6:	ffffc097          	auipc	ra,0xffffc
    80005bfa:	3e8080e7          	jalr	1000(ra) # 80001fde <proc_freepagetable>
  return -1;
    80005bfe:	557d                	li	a0,-1
    80005c00:	79fe                	ld	s3,504(sp)
    80005c02:	7a5e                	ld	s4,496(sp)
    80005c04:	7abe                	ld	s5,488(sp)
    80005c06:	7b1e                	ld	s6,480(sp)
    80005c08:	6bfe                	ld	s7,472(sp)
    80005c0a:	6c5e                	ld	s8,464(sp)
    80005c0c:	6cbe                	ld	s9,456(sp)
    80005c0e:	6d1e                	ld	s10,448(sp)
    80005c10:	7dfa                	ld	s11,440(sp)
    80005c12:	b5b1                	j	80005a5e <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005c14:	75f9                	lui	a1,0xffffe
    80005c16:	95aa                	add	a1,a1,a0
    80005c18:	855a                	mv	a0,s6
    80005c1a:	ffffc097          	auipc	ra,0xffffc
    80005c1e:	d26080e7          	jalr	-730(ra) # 80001940 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c22:	7bfd                	lui	s7,0xfffff
    80005c24:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80005c26:	e0043783          	ld	a5,-512(s0)
    80005c2a:	6388                	ld	a0,0(a5)
  sp = sz;
    80005c2c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005c2e:	4481                	li	s1,0
    ustack[argc] = sp;
    80005c30:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005c34:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80005c38:	c135                	beqz	a0,80005c9c <exec+0x2cc>
    sp -= strlen(argv[argc]) + 1;
    80005c3a:	ffffb097          	auipc	ra,0xffffb
    80005c3e:	3fa080e7          	jalr	1018(ra) # 80001034 <strlen>
    80005c42:	0015079b          	addiw	a5,a0,1
    80005c46:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c4a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005c4e:	15796163          	bltu	s2,s7,80005d90 <exec+0x3c0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c52:	e0043d83          	ld	s11,-512(s0)
    80005c56:	000db983          	ld	s3,0(s11)
    80005c5a:	854e                	mv	a0,s3
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	3d8080e7          	jalr	984(ra) # 80001034 <strlen>
    80005c64:	0015069b          	addiw	a3,a0,1
    80005c68:	864e                	mv	a2,s3
    80005c6a:	85ca                	mv	a1,s2
    80005c6c:	855a                	mv	a0,s6
    80005c6e:	ffffc097          	auipc	ra,0xffffc
    80005c72:	d04080e7          	jalr	-764(ra) # 80001972 <copyout>
    80005c76:	10054f63          	bltz	a0,80005d94 <exec+0x3c4>
    ustack[argc] = sp;
    80005c7a:	00349793          	slli	a5,s1,0x3
    80005c7e:	97e6                	add	a5,a5,s9
    80005c80:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7fdb3fe8>
  for(argc = 0; argv[argc]; argc++) {
    80005c84:	0485                	addi	s1,s1,1
    80005c86:	008d8793          	addi	a5,s11,8
    80005c8a:	e0f43023          	sd	a5,-512(s0)
    80005c8e:	008db503          	ld	a0,8(s11)
    80005c92:	c509                	beqz	a0,80005c9c <exec+0x2cc>
    if(argc >= MAXARG)
    80005c94:	fb8493e3          	bne	s1,s8,80005c3a <exec+0x26a>
  sz = sz1;
    80005c98:	89d2                	mv	s3,s4
    80005c9a:	bfa1                	j	80005bf2 <exec+0x222>
  ustack[argc] = 0;
    80005c9c:	00349793          	slli	a5,s1,0x3
    80005ca0:	f9078793          	addi	a5,a5,-112
    80005ca4:	97a2                	add	a5,a5,s0
    80005ca6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005caa:	00148693          	addi	a3,s1,1
    80005cae:	068e                	slli	a3,a3,0x3
    80005cb0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005cb4:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005cb8:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005cba:	f3796ce3          	bltu	s2,s7,80005bf2 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005cbe:	e9040613          	addi	a2,s0,-368
    80005cc2:	85ca                	mv	a1,s2
    80005cc4:	855a                	mv	a0,s6
    80005cc6:	ffffc097          	auipc	ra,0xffffc
    80005cca:	cac080e7          	jalr	-852(ra) # 80001972 <copyout>
    80005cce:	f20542e3          	bltz	a0,80005bf2 <exec+0x222>
  p->trapframe->a1 = sp;
    80005cd2:	230ab783          	ld	a5,560(s5) # 1230 <_entry-0x7fffedd0>
    80005cd6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005cda:	df043783          	ld	a5,-528(s0)
    80005cde:	0007c703          	lbu	a4,0(a5)
    80005ce2:	cf11                	beqz	a4,80005cfe <exec+0x32e>
    80005ce4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005ce6:	02f00693          	li	a3,47
    80005cea:	a029                	j	80005cf4 <exec+0x324>
  for(last=s=path; *s; s++)
    80005cec:	0785                	addi	a5,a5,1
    80005cee:	fff7c703          	lbu	a4,-1(a5)
    80005cf2:	c711                	beqz	a4,80005cfe <exec+0x32e>
    if(*s == '/')
    80005cf4:	fed71ce3          	bne	a4,a3,80005cec <exec+0x31c>
      last = s+1;
    80005cf8:	def43823          	sd	a5,-528(s0)
    80005cfc:	bfc5                	j	80005cec <exec+0x31c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005cfe:	4641                	li	a2,16
    80005d00:	df043583          	ld	a1,-528(s0)
    80005d04:	330a8513          	addi	a0,s5,816
    80005d08:	ffffb097          	auipc	ra,0xffffb
    80005d0c:	2f6080e7          	jalr	758(ra) # 80000ffe <safestrcpy>
  oldpagetable = p->pagetable;
    80005d10:	228ab503          	ld	a0,552(s5)
  p->pagetable = pagetable;
    80005d14:	236ab423          	sd	s6,552(s5)
  p->sz = sz;
    80005d18:	234ab023          	sd	s4,544(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005d1c:	230ab783          	ld	a5,560(s5)
    80005d20:	e6843703          	ld	a4,-408(s0)
    80005d24:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005d26:	230ab783          	ld	a5,560(s5)
    80005d2a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005d2e:	85ea                	mv	a1,s10
    80005d30:	ffffc097          	auipc	ra,0xffffc
    80005d34:	2ae080e7          	jalr	686(ra) # 80001fde <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005d38:	0004851b          	sext.w	a0,s1
    80005d3c:	79fe                	ld	s3,504(sp)
    80005d3e:	7a5e                	ld	s4,496(sp)
    80005d40:	7abe                	ld	s5,488(sp)
    80005d42:	7b1e                	ld	s6,480(sp)
    80005d44:	6bfe                	ld	s7,472(sp)
    80005d46:	6c5e                	ld	s8,464(sp)
    80005d48:	6cbe                	ld	s9,456(sp)
    80005d4a:	6d1e                	ld	s10,448(sp)
    80005d4c:	7dfa                	ld	s11,440(sp)
    80005d4e:	bb01                	j	80005a5e <exec+0x8e>
    80005d50:	7b1e                	ld	s6,480(sp)
    80005d52:	b9dd                	j	80005a48 <exec+0x78>
    80005d54:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005d58:	df843583          	ld	a1,-520(s0)
    80005d5c:	855a                	mv	a0,s6
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	280080e7          	jalr	640(ra) # 80001fde <proc_freepagetable>
  if(ip){
    80005d66:	79fe                	ld	s3,504(sp)
    80005d68:	7abe                	ld	s5,488(sp)
    80005d6a:	7b1e                	ld	s6,480(sp)
    80005d6c:	6bfe                	ld	s7,472(sp)
    80005d6e:	6c5e                	ld	s8,464(sp)
    80005d70:	6cbe                	ld	s9,456(sp)
    80005d72:	6d1e                	ld	s10,448(sp)
    80005d74:	7dfa                	ld	s11,440(sp)
    80005d76:	b9c9                	j	80005a48 <exec+0x78>
    80005d78:	df243c23          	sd	s2,-520(s0)
    80005d7c:	bff1                	j	80005d58 <exec+0x388>
    80005d7e:	df243c23          	sd	s2,-520(s0)
    80005d82:	bfd9                	j	80005d58 <exec+0x388>
    80005d84:	df243c23          	sd	s2,-520(s0)
    80005d88:	bfc1                	j	80005d58 <exec+0x388>
    80005d8a:	df243c23          	sd	s2,-520(s0)
    80005d8e:	b7e9                	j	80005d58 <exec+0x388>
  sz = sz1;
    80005d90:	89d2                	mv	s3,s4
    80005d92:	b585                	j	80005bf2 <exec+0x222>
    80005d94:	89d2                	mv	s3,s4
    80005d96:	bdb1                	j	80005bf2 <exec+0x222>

0000000080005d98 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005d98:	7179                	addi	sp,sp,-48
    80005d9a:	f406                	sd	ra,40(sp)
    80005d9c:	f022                	sd	s0,32(sp)
    80005d9e:	ec26                	sd	s1,24(sp)
    80005da0:	e84a                	sd	s2,16(sp)
    80005da2:	1800                	addi	s0,sp,48
    80005da4:	892e                	mv	s2,a1
    80005da6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005da8:	fdc40593          	addi	a1,s0,-36
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	946080e7          	jalr	-1722(ra) # 800036f2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005db4:	fdc42703          	lw	a4,-36(s0)
    80005db8:	47bd                	li	a5,15
    80005dba:	02e7eb63          	bltu	a5,a4,80005df0 <argfd+0x58>
    80005dbe:	ffffc097          	auipc	ra,0xffffc
    80005dc2:	0c0080e7          	jalr	192(ra) # 80001e7e <myproc>
    80005dc6:	fdc42703          	lw	a4,-36(s0)
    80005dca:	05470793          	addi	a5,a4,84
    80005dce:	078e                	slli	a5,a5,0x3
    80005dd0:	953e                	add	a0,a0,a5
    80005dd2:	651c                	ld	a5,8(a0)
    80005dd4:	c385                	beqz	a5,80005df4 <argfd+0x5c>
    return -1;
  if(pfd)
    80005dd6:	00090463          	beqz	s2,80005dde <argfd+0x46>
    *pfd = fd;
    80005dda:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005dde:	4501                	li	a0,0
  if(pf)
    80005de0:	c091                	beqz	s1,80005de4 <argfd+0x4c>
    *pf = f;
    80005de2:	e09c                	sd	a5,0(s1)
}
    80005de4:	70a2                	ld	ra,40(sp)
    80005de6:	7402                	ld	s0,32(sp)
    80005de8:	64e2                	ld	s1,24(sp)
    80005dea:	6942                	ld	s2,16(sp)
    80005dec:	6145                	addi	sp,sp,48
    80005dee:	8082                	ret
    return -1;
    80005df0:	557d                	li	a0,-1
    80005df2:	bfcd                	j	80005de4 <argfd+0x4c>
    80005df4:	557d                	li	a0,-1
    80005df6:	b7fd                	j	80005de4 <argfd+0x4c>

0000000080005df8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005df8:	1101                	addi	sp,sp,-32
    80005dfa:	ec06                	sd	ra,24(sp)
    80005dfc:	e822                	sd	s0,16(sp)
    80005dfe:	e426                	sd	s1,8(sp)
    80005e00:	1000                	addi	s0,sp,32
    80005e02:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e04:	ffffc097          	auipc	ra,0xffffc
    80005e08:	07a080e7          	jalr	122(ra) # 80001e7e <myproc>
    80005e0c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005e0e:	2a850793          	addi	a5,a0,680
    80005e12:	4501                	li	a0,0
    80005e14:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005e16:	6398                	ld	a4,0(a5)
    80005e18:	cb19                	beqz	a4,80005e2e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005e1a:	2505                	addiw	a0,a0,1
    80005e1c:	07a1                	addi	a5,a5,8
    80005e1e:	fed51ce3          	bne	a0,a3,80005e16 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005e22:	557d                	li	a0,-1
}
    80005e24:	60e2                	ld	ra,24(sp)
    80005e26:	6442                	ld	s0,16(sp)
    80005e28:	64a2                	ld	s1,8(sp)
    80005e2a:	6105                	addi	sp,sp,32
    80005e2c:	8082                	ret
      p->ofile[fd] = f;
    80005e2e:	05450793          	addi	a5,a0,84
    80005e32:	078e                	slli	a5,a5,0x3
    80005e34:	963e                	add	a2,a2,a5
    80005e36:	e604                	sd	s1,8(a2)
      return fd;
    80005e38:	b7f5                	j	80005e24 <fdalloc+0x2c>

0000000080005e3a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005e3a:	715d                	addi	sp,sp,-80
    80005e3c:	e486                	sd	ra,72(sp)
    80005e3e:	e0a2                	sd	s0,64(sp)
    80005e40:	fc26                	sd	s1,56(sp)
    80005e42:	f84a                	sd	s2,48(sp)
    80005e44:	f44e                	sd	s3,40(sp)
    80005e46:	ec56                	sd	s5,24(sp)
    80005e48:	e85a                	sd	s6,16(sp)
    80005e4a:	0880                	addi	s0,sp,80
    80005e4c:	8b2e                	mv	s6,a1
    80005e4e:	89b2                	mv	s3,a2
    80005e50:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005e52:	fb040593          	addi	a1,s0,-80
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	db8080e7          	jalr	-584(ra) # 80004c0e <nameiparent>
    80005e5e:	84aa                	mv	s1,a0
    80005e60:	14050e63          	beqz	a0,80005fbc <create+0x182>
    return 0;

  ilock(dp);
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	5a8080e7          	jalr	1448(ra) # 8000440c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005e6c:	4601                	li	a2,0
    80005e6e:	fb040593          	addi	a1,s0,-80
    80005e72:	8526                	mv	a0,s1
    80005e74:	fffff097          	auipc	ra,0xfffff
    80005e78:	a94080e7          	jalr	-1388(ra) # 80004908 <dirlookup>
    80005e7c:	8aaa                	mv	s5,a0
    80005e7e:	c539                	beqz	a0,80005ecc <create+0x92>
    iunlockput(dp);
    80005e80:	8526                	mv	a0,s1
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	7f0080e7          	jalr	2032(ra) # 80004672 <iunlockput>
    ilock(ip);
    80005e8a:	8556                	mv	a0,s5
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	580080e7          	jalr	1408(ra) # 8000440c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005e94:	4789                	li	a5,2
    80005e96:	02fb1463          	bne	s6,a5,80005ebe <create+0x84>
    80005e9a:	044ad783          	lhu	a5,68(s5)
    80005e9e:	37f9                	addiw	a5,a5,-2
    80005ea0:	17c2                	slli	a5,a5,0x30
    80005ea2:	93c1                	srli	a5,a5,0x30
    80005ea4:	4705                	li	a4,1
    80005ea6:	00f76c63          	bltu	a4,a5,80005ebe <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005eaa:	8556                	mv	a0,s5
    80005eac:	60a6                	ld	ra,72(sp)
    80005eae:	6406                	ld	s0,64(sp)
    80005eb0:	74e2                	ld	s1,56(sp)
    80005eb2:	7942                	ld	s2,48(sp)
    80005eb4:	79a2                	ld	s3,40(sp)
    80005eb6:	6ae2                	ld	s5,24(sp)
    80005eb8:	6b42                	ld	s6,16(sp)
    80005eba:	6161                	addi	sp,sp,80
    80005ebc:	8082                	ret
    iunlockput(ip);
    80005ebe:	8556                	mv	a0,s5
    80005ec0:	ffffe097          	auipc	ra,0xffffe
    80005ec4:	7b2080e7          	jalr	1970(ra) # 80004672 <iunlockput>
    return 0;
    80005ec8:	4a81                	li	s5,0
    80005eca:	b7c5                	j	80005eaa <create+0x70>
    80005ecc:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005ece:	85da                	mv	a1,s6
    80005ed0:	4088                	lw	a0,0(s1)
    80005ed2:	ffffe097          	auipc	ra,0xffffe
    80005ed6:	396080e7          	jalr	918(ra) # 80004268 <ialloc>
    80005eda:	8a2a                	mv	s4,a0
    80005edc:	c531                	beqz	a0,80005f28 <create+0xee>
  ilock(ip);
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	52e080e7          	jalr	1326(ra) # 8000440c <ilock>
  ip->major = major;
    80005ee6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005eea:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005eee:	4905                	li	s2,1
    80005ef0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005ef4:	8552                	mv	a0,s4
    80005ef6:	ffffe097          	auipc	ra,0xffffe
    80005efa:	44a080e7          	jalr	1098(ra) # 80004340 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005efe:	032b0d63          	beq	s6,s2,80005f38 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005f02:	004a2603          	lw	a2,4(s4)
    80005f06:	fb040593          	addi	a1,s0,-80
    80005f0a:	8526                	mv	a0,s1
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	c22080e7          	jalr	-990(ra) # 80004b2e <dirlink>
    80005f14:	08054163          	bltz	a0,80005f96 <create+0x15c>
  iunlockput(dp);
    80005f18:	8526                	mv	a0,s1
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	758080e7          	jalr	1880(ra) # 80004672 <iunlockput>
  return ip;
    80005f22:	8ad2                	mv	s5,s4
    80005f24:	7a02                	ld	s4,32(sp)
    80005f26:	b751                	j	80005eaa <create+0x70>
    iunlockput(dp);
    80005f28:	8526                	mv	a0,s1
    80005f2a:	ffffe097          	auipc	ra,0xffffe
    80005f2e:	748080e7          	jalr	1864(ra) # 80004672 <iunlockput>
    return 0;
    80005f32:	8ad2                	mv	s5,s4
    80005f34:	7a02                	ld	s4,32(sp)
    80005f36:	bf95                	j	80005eaa <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005f38:	004a2603          	lw	a2,4(s4)
    80005f3c:	00003597          	auipc	a1,0x3
    80005f40:	71c58593          	addi	a1,a1,1820 # 80009658 <etext+0x658>
    80005f44:	8552                	mv	a0,s4
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	be8080e7          	jalr	-1048(ra) # 80004b2e <dirlink>
    80005f4e:	04054463          	bltz	a0,80005f96 <create+0x15c>
    80005f52:	40d0                	lw	a2,4(s1)
    80005f54:	00003597          	auipc	a1,0x3
    80005f58:	70c58593          	addi	a1,a1,1804 # 80009660 <etext+0x660>
    80005f5c:	8552                	mv	a0,s4
    80005f5e:	fffff097          	auipc	ra,0xfffff
    80005f62:	bd0080e7          	jalr	-1072(ra) # 80004b2e <dirlink>
    80005f66:	02054863          	bltz	a0,80005f96 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005f6a:	004a2603          	lw	a2,4(s4)
    80005f6e:	fb040593          	addi	a1,s0,-80
    80005f72:	8526                	mv	a0,s1
    80005f74:	fffff097          	auipc	ra,0xfffff
    80005f78:	bba080e7          	jalr	-1094(ra) # 80004b2e <dirlink>
    80005f7c:	00054d63          	bltz	a0,80005f96 <create+0x15c>
    dp->nlink++;  // for ".."
    80005f80:	04a4d783          	lhu	a5,74(s1)
    80005f84:	2785                	addiw	a5,a5,1
    80005f86:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f8a:	8526                	mv	a0,s1
    80005f8c:	ffffe097          	auipc	ra,0xffffe
    80005f90:	3b4080e7          	jalr	948(ra) # 80004340 <iupdate>
    80005f94:	b751                	j	80005f18 <create+0xde>
  ip->nlink = 0;
    80005f96:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005f9a:	8552                	mv	a0,s4
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	3a4080e7          	jalr	932(ra) # 80004340 <iupdate>
  iunlockput(ip);
    80005fa4:	8552                	mv	a0,s4
    80005fa6:	ffffe097          	auipc	ra,0xffffe
    80005faa:	6cc080e7          	jalr	1740(ra) # 80004672 <iunlockput>
  iunlockput(dp);
    80005fae:	8526                	mv	a0,s1
    80005fb0:	ffffe097          	auipc	ra,0xffffe
    80005fb4:	6c2080e7          	jalr	1730(ra) # 80004672 <iunlockput>
  return 0;
    80005fb8:	7a02                	ld	s4,32(sp)
    80005fba:	bdc5                	j	80005eaa <create+0x70>
    return 0;
    80005fbc:	8aaa                	mv	s5,a0
    80005fbe:	b5f5                	j	80005eaa <create+0x70>

0000000080005fc0 <sys_dup>:
{
    80005fc0:	7179                	addi	sp,sp,-48
    80005fc2:	f406                	sd	ra,40(sp)
    80005fc4:	f022                	sd	s0,32(sp)
    80005fc6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005fc8:	fd840613          	addi	a2,s0,-40
    80005fcc:	4581                	li	a1,0
    80005fce:	4501                	li	a0,0
    80005fd0:	00000097          	auipc	ra,0x0
    80005fd4:	dc8080e7          	jalr	-568(ra) # 80005d98 <argfd>
    return -1;
    80005fd8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005fda:	02054763          	bltz	a0,80006008 <sys_dup+0x48>
    80005fde:	ec26                	sd	s1,24(sp)
    80005fe0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005fe2:	fd843903          	ld	s2,-40(s0)
    80005fe6:	854a                	mv	a0,s2
    80005fe8:	00000097          	auipc	ra,0x0
    80005fec:	e10080e7          	jalr	-496(ra) # 80005df8 <fdalloc>
    80005ff0:	84aa                	mv	s1,a0
    return -1;
    80005ff2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ff4:	00054f63          	bltz	a0,80006012 <sys_dup+0x52>
  filedup(f);
    80005ff8:	854a                	mv	a0,s2
    80005ffa:	fffff097          	auipc	ra,0xfffff
    80005ffe:	27a080e7          	jalr	634(ra) # 80005274 <filedup>
  return fd;
    80006002:	87a6                	mv	a5,s1
    80006004:	64e2                	ld	s1,24(sp)
    80006006:	6942                	ld	s2,16(sp)
}
    80006008:	853e                	mv	a0,a5
    8000600a:	70a2                	ld	ra,40(sp)
    8000600c:	7402                	ld	s0,32(sp)
    8000600e:	6145                	addi	sp,sp,48
    80006010:	8082                	ret
    80006012:	64e2                	ld	s1,24(sp)
    80006014:	6942                	ld	s2,16(sp)
    80006016:	bfcd                	j	80006008 <sys_dup+0x48>

0000000080006018 <sys_read>:
{
    80006018:	7179                	addi	sp,sp,-48
    8000601a:	f406                	sd	ra,40(sp)
    8000601c:	f022                	sd	s0,32(sp)
    8000601e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80006020:	fd840593          	addi	a1,s0,-40
    80006024:	4505                	li	a0,1
    80006026:	ffffd097          	auipc	ra,0xffffd
    8000602a:	6ec080e7          	jalr	1772(ra) # 80003712 <argaddr>
  argint(2, &n);
    8000602e:	fe440593          	addi	a1,s0,-28
    80006032:	4509                	li	a0,2
    80006034:	ffffd097          	auipc	ra,0xffffd
    80006038:	6be080e7          	jalr	1726(ra) # 800036f2 <argint>
  if(argfd(0, 0, &f) < 0)
    8000603c:	fe840613          	addi	a2,s0,-24
    80006040:	4581                	li	a1,0
    80006042:	4501                	li	a0,0
    80006044:	00000097          	auipc	ra,0x0
    80006048:	d54080e7          	jalr	-684(ra) # 80005d98 <argfd>
    8000604c:	87aa                	mv	a5,a0
    return -1;
    8000604e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80006050:	0007cc63          	bltz	a5,80006068 <sys_read+0x50>
  return fileread(f, p, n);
    80006054:	fe442603          	lw	a2,-28(s0)
    80006058:	fd843583          	ld	a1,-40(s0)
    8000605c:	fe843503          	ld	a0,-24(s0)
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	3ba080e7          	jalr	954(ra) # 8000541a <fileread>
}
    80006068:	70a2                	ld	ra,40(sp)
    8000606a:	7402                	ld	s0,32(sp)
    8000606c:	6145                	addi	sp,sp,48
    8000606e:	8082                	ret

0000000080006070 <sys_write>:
{
    80006070:	7179                	addi	sp,sp,-48
    80006072:	f406                	sd	ra,40(sp)
    80006074:	f022                	sd	s0,32(sp)
    80006076:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80006078:	fd840593          	addi	a1,s0,-40
    8000607c:	4505                	li	a0,1
    8000607e:	ffffd097          	auipc	ra,0xffffd
    80006082:	694080e7          	jalr	1684(ra) # 80003712 <argaddr>
  argint(2, &n);
    80006086:	fe440593          	addi	a1,s0,-28
    8000608a:	4509                	li	a0,2
    8000608c:	ffffd097          	auipc	ra,0xffffd
    80006090:	666080e7          	jalr	1638(ra) # 800036f2 <argint>
  if(argfd(0, 0, &f) < 0)
    80006094:	fe840613          	addi	a2,s0,-24
    80006098:	4581                	li	a1,0
    8000609a:	4501                	li	a0,0
    8000609c:	00000097          	auipc	ra,0x0
    800060a0:	cfc080e7          	jalr	-772(ra) # 80005d98 <argfd>
    800060a4:	87aa                	mv	a5,a0
    return -1;
    800060a6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800060a8:	0007cc63          	bltz	a5,800060c0 <sys_write+0x50>
  return filewrite(f, p, n);
    800060ac:	fe442603          	lw	a2,-28(s0)
    800060b0:	fd843583          	ld	a1,-40(s0)
    800060b4:	fe843503          	ld	a0,-24(s0)
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	434080e7          	jalr	1076(ra) # 800054ec <filewrite>
}
    800060c0:	70a2                	ld	ra,40(sp)
    800060c2:	7402                	ld	s0,32(sp)
    800060c4:	6145                	addi	sp,sp,48
    800060c6:	8082                	ret

00000000800060c8 <sys_close>:
{
    800060c8:	1101                	addi	sp,sp,-32
    800060ca:	ec06                	sd	ra,24(sp)
    800060cc:	e822                	sd	s0,16(sp)
    800060ce:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800060d0:	fe040613          	addi	a2,s0,-32
    800060d4:	fec40593          	addi	a1,s0,-20
    800060d8:	4501                	li	a0,0
    800060da:	00000097          	auipc	ra,0x0
    800060de:	cbe080e7          	jalr	-834(ra) # 80005d98 <argfd>
    return -1;
    800060e2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800060e4:	02054563          	bltz	a0,8000610e <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    800060e8:	ffffc097          	auipc	ra,0xffffc
    800060ec:	d96080e7          	jalr	-618(ra) # 80001e7e <myproc>
    800060f0:	fec42783          	lw	a5,-20(s0)
    800060f4:	05478793          	addi	a5,a5,84
    800060f8:	078e                	slli	a5,a5,0x3
    800060fa:	953e                	add	a0,a0,a5
    800060fc:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80006100:	fe043503          	ld	a0,-32(s0)
    80006104:	fffff097          	auipc	ra,0xfffff
    80006108:	1c2080e7          	jalr	450(ra) # 800052c6 <fileclose>
  return 0;
    8000610c:	4781                	li	a5,0
}
    8000610e:	853e                	mv	a0,a5
    80006110:	60e2                	ld	ra,24(sp)
    80006112:	6442                	ld	s0,16(sp)
    80006114:	6105                	addi	sp,sp,32
    80006116:	8082                	ret

0000000080006118 <sys_fstat>:
{
    80006118:	1101                	addi	sp,sp,-32
    8000611a:	ec06                	sd	ra,24(sp)
    8000611c:	e822                	sd	s0,16(sp)
    8000611e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80006120:	fe040593          	addi	a1,s0,-32
    80006124:	4505                	li	a0,1
    80006126:	ffffd097          	auipc	ra,0xffffd
    8000612a:	5ec080e7          	jalr	1516(ra) # 80003712 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000612e:	fe840613          	addi	a2,s0,-24
    80006132:	4581                	li	a1,0
    80006134:	4501                	li	a0,0
    80006136:	00000097          	auipc	ra,0x0
    8000613a:	c62080e7          	jalr	-926(ra) # 80005d98 <argfd>
    8000613e:	87aa                	mv	a5,a0
    return -1;
    80006140:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80006142:	0007ca63          	bltz	a5,80006156 <sys_fstat+0x3e>
  return filestat(f, st);
    80006146:	fe043583          	ld	a1,-32(s0)
    8000614a:	fe843503          	ld	a0,-24(s0)
    8000614e:	fffff097          	auipc	ra,0xfffff
    80006152:	256080e7          	jalr	598(ra) # 800053a4 <filestat>
}
    80006156:	60e2                	ld	ra,24(sp)
    80006158:	6442                	ld	s0,16(sp)
    8000615a:	6105                	addi	sp,sp,32
    8000615c:	8082                	ret

000000008000615e <sys_link>:
{
    8000615e:	7169                	addi	sp,sp,-304
    80006160:	f606                	sd	ra,296(sp)
    80006162:	f222                	sd	s0,288(sp)
    80006164:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006166:	08000613          	li	a2,128
    8000616a:	ed040593          	addi	a1,s0,-304
    8000616e:	4501                	li	a0,0
    80006170:	ffffd097          	auipc	ra,0xffffd
    80006174:	5c2080e7          	jalr	1474(ra) # 80003732 <argstr>
    return -1;
    80006178:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000617a:	12054663          	bltz	a0,800062a6 <sys_link+0x148>
    8000617e:	08000613          	li	a2,128
    80006182:	f5040593          	addi	a1,s0,-176
    80006186:	4505                	li	a0,1
    80006188:	ffffd097          	auipc	ra,0xffffd
    8000618c:	5aa080e7          	jalr	1450(ra) # 80003732 <argstr>
    return -1;
    80006190:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006192:	10054a63          	bltz	a0,800062a6 <sys_link+0x148>
    80006196:	ee26                	sd	s1,280(sp)
  begin_op();
    80006198:	fffff097          	auipc	ra,0xfffff
    8000619c:	c5e080e7          	jalr	-930(ra) # 80004df6 <begin_op>
  if((ip = namei(old)) == 0){
    800061a0:	ed040513          	addi	a0,s0,-304
    800061a4:	fffff097          	auipc	ra,0xfffff
    800061a8:	a4c080e7          	jalr	-1460(ra) # 80004bf0 <namei>
    800061ac:	84aa                	mv	s1,a0
    800061ae:	c949                	beqz	a0,80006240 <sys_link+0xe2>
  ilock(ip);
    800061b0:	ffffe097          	auipc	ra,0xffffe
    800061b4:	25c080e7          	jalr	604(ra) # 8000440c <ilock>
  if(ip->type == T_DIR){
    800061b8:	04449703          	lh	a4,68(s1)
    800061bc:	4785                	li	a5,1
    800061be:	08f70863          	beq	a4,a5,8000624e <sys_link+0xf0>
    800061c2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800061c4:	04a4d783          	lhu	a5,74(s1)
    800061c8:	2785                	addiw	a5,a5,1
    800061ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800061ce:	8526                	mv	a0,s1
    800061d0:	ffffe097          	auipc	ra,0xffffe
    800061d4:	170080e7          	jalr	368(ra) # 80004340 <iupdate>
  iunlock(ip);
    800061d8:	8526                	mv	a0,s1
    800061da:	ffffe097          	auipc	ra,0xffffe
    800061de:	2f8080e7          	jalr	760(ra) # 800044d2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800061e2:	fd040593          	addi	a1,s0,-48
    800061e6:	f5040513          	addi	a0,s0,-176
    800061ea:	fffff097          	auipc	ra,0xfffff
    800061ee:	a24080e7          	jalr	-1500(ra) # 80004c0e <nameiparent>
    800061f2:	892a                	mv	s2,a0
    800061f4:	cd35                	beqz	a0,80006270 <sys_link+0x112>
  ilock(dp);
    800061f6:	ffffe097          	auipc	ra,0xffffe
    800061fa:	216080e7          	jalr	534(ra) # 8000440c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800061fe:	00092703          	lw	a4,0(s2)
    80006202:	409c                	lw	a5,0(s1)
    80006204:	06f71163          	bne	a4,a5,80006266 <sys_link+0x108>
    80006208:	40d0                	lw	a2,4(s1)
    8000620a:	fd040593          	addi	a1,s0,-48
    8000620e:	854a                	mv	a0,s2
    80006210:	fffff097          	auipc	ra,0xfffff
    80006214:	91e080e7          	jalr	-1762(ra) # 80004b2e <dirlink>
    80006218:	04054763          	bltz	a0,80006266 <sys_link+0x108>
  iunlockput(dp);
    8000621c:	854a                	mv	a0,s2
    8000621e:	ffffe097          	auipc	ra,0xffffe
    80006222:	454080e7          	jalr	1108(ra) # 80004672 <iunlockput>
  iput(ip);
    80006226:	8526                	mv	a0,s1
    80006228:	ffffe097          	auipc	ra,0xffffe
    8000622c:	3a2080e7          	jalr	930(ra) # 800045ca <iput>
  end_op();
    80006230:	fffff097          	auipc	ra,0xfffff
    80006234:	c40080e7          	jalr	-960(ra) # 80004e70 <end_op>
  return 0;
    80006238:	4781                	li	a5,0
    8000623a:	64f2                	ld	s1,280(sp)
    8000623c:	6952                	ld	s2,272(sp)
    8000623e:	a0a5                	j	800062a6 <sys_link+0x148>
    end_op();
    80006240:	fffff097          	auipc	ra,0xfffff
    80006244:	c30080e7          	jalr	-976(ra) # 80004e70 <end_op>
    return -1;
    80006248:	57fd                	li	a5,-1
    8000624a:	64f2                	ld	s1,280(sp)
    8000624c:	a8a9                	j	800062a6 <sys_link+0x148>
    iunlockput(ip);
    8000624e:	8526                	mv	a0,s1
    80006250:	ffffe097          	auipc	ra,0xffffe
    80006254:	422080e7          	jalr	1058(ra) # 80004672 <iunlockput>
    end_op();
    80006258:	fffff097          	auipc	ra,0xfffff
    8000625c:	c18080e7          	jalr	-1000(ra) # 80004e70 <end_op>
    return -1;
    80006260:	57fd                	li	a5,-1
    80006262:	64f2                	ld	s1,280(sp)
    80006264:	a089                	j	800062a6 <sys_link+0x148>
    iunlockput(dp);
    80006266:	854a                	mv	a0,s2
    80006268:	ffffe097          	auipc	ra,0xffffe
    8000626c:	40a080e7          	jalr	1034(ra) # 80004672 <iunlockput>
  ilock(ip);
    80006270:	8526                	mv	a0,s1
    80006272:	ffffe097          	auipc	ra,0xffffe
    80006276:	19a080e7          	jalr	410(ra) # 8000440c <ilock>
  ip->nlink--;
    8000627a:	04a4d783          	lhu	a5,74(s1)
    8000627e:	37fd                	addiw	a5,a5,-1
    80006280:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006284:	8526                	mv	a0,s1
    80006286:	ffffe097          	auipc	ra,0xffffe
    8000628a:	0ba080e7          	jalr	186(ra) # 80004340 <iupdate>
  iunlockput(ip);
    8000628e:	8526                	mv	a0,s1
    80006290:	ffffe097          	auipc	ra,0xffffe
    80006294:	3e2080e7          	jalr	994(ra) # 80004672 <iunlockput>
  end_op();
    80006298:	fffff097          	auipc	ra,0xfffff
    8000629c:	bd8080e7          	jalr	-1064(ra) # 80004e70 <end_op>
  return -1;
    800062a0:	57fd                	li	a5,-1
    800062a2:	64f2                	ld	s1,280(sp)
    800062a4:	6952                	ld	s2,272(sp)
}
    800062a6:	853e                	mv	a0,a5
    800062a8:	70b2                	ld	ra,296(sp)
    800062aa:	7412                	ld	s0,288(sp)
    800062ac:	6155                	addi	sp,sp,304
    800062ae:	8082                	ret

00000000800062b0 <sys_unlink>:
{
    800062b0:	7111                	addi	sp,sp,-256
    800062b2:	fd86                	sd	ra,248(sp)
    800062b4:	f9a2                	sd	s0,240(sp)
    800062b6:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    800062b8:	08000613          	li	a2,128
    800062bc:	f2040593          	addi	a1,s0,-224
    800062c0:	4501                	li	a0,0
    800062c2:	ffffd097          	auipc	ra,0xffffd
    800062c6:	470080e7          	jalr	1136(ra) # 80003732 <argstr>
    800062ca:	1c054063          	bltz	a0,8000648a <sys_unlink+0x1da>
    800062ce:	f5a6                	sd	s1,232(sp)
  begin_op();
    800062d0:	fffff097          	auipc	ra,0xfffff
    800062d4:	b26080e7          	jalr	-1242(ra) # 80004df6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800062d8:	fa040593          	addi	a1,s0,-96
    800062dc:	f2040513          	addi	a0,s0,-224
    800062e0:	fffff097          	auipc	ra,0xfffff
    800062e4:	92e080e7          	jalr	-1746(ra) # 80004c0e <nameiparent>
    800062e8:	84aa                	mv	s1,a0
    800062ea:	c165                	beqz	a0,800063ca <sys_unlink+0x11a>
  ilock(dp);
    800062ec:	ffffe097          	auipc	ra,0xffffe
    800062f0:	120080e7          	jalr	288(ra) # 8000440c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800062f4:	00003597          	auipc	a1,0x3
    800062f8:	36458593          	addi	a1,a1,868 # 80009658 <etext+0x658>
    800062fc:	fa040513          	addi	a0,s0,-96
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	5ee080e7          	jalr	1518(ra) # 800048ee <namecmp>
    80006308:	16050263          	beqz	a0,8000646c <sys_unlink+0x1bc>
    8000630c:	00003597          	auipc	a1,0x3
    80006310:	35458593          	addi	a1,a1,852 # 80009660 <etext+0x660>
    80006314:	fa040513          	addi	a0,s0,-96
    80006318:	ffffe097          	auipc	ra,0xffffe
    8000631c:	5d6080e7          	jalr	1494(ra) # 800048ee <namecmp>
    80006320:	14050663          	beqz	a0,8000646c <sys_unlink+0x1bc>
    80006324:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006326:	f1c40613          	addi	a2,s0,-228
    8000632a:	fa040593          	addi	a1,s0,-96
    8000632e:	8526                	mv	a0,s1
    80006330:	ffffe097          	auipc	ra,0xffffe
    80006334:	5d8080e7          	jalr	1496(ra) # 80004908 <dirlookup>
    80006338:	892a                	mv	s2,a0
    8000633a:	12050863          	beqz	a0,8000646a <sys_unlink+0x1ba>
    8000633e:	edce                	sd	s3,216(sp)
  ilock(ip);
    80006340:	ffffe097          	auipc	ra,0xffffe
    80006344:	0cc080e7          	jalr	204(ra) # 8000440c <ilock>
  if(ip->nlink < 1)
    80006348:	04a91783          	lh	a5,74(s2)
    8000634c:	08f05663          	blez	a5,800063d8 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006350:	04491703          	lh	a4,68(s2)
    80006354:	4785                	li	a5,1
    80006356:	08f70b63          	beq	a4,a5,800063ec <sys_unlink+0x13c>
  memset(&de, 0, sizeof(de));
    8000635a:	fb040993          	addi	s3,s0,-80
    8000635e:	4641                	li	a2,16
    80006360:	4581                	li	a1,0
    80006362:	854e                	mv	a0,s3
    80006364:	ffffb097          	auipc	ra,0xffffb
    80006368:	b44080e7          	jalr	-1212(ra) # 80000ea8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000636c:	4741                	li	a4,16
    8000636e:	f1c42683          	lw	a3,-228(s0)
    80006372:	864e                	mv	a2,s3
    80006374:	4581                	li	a1,0
    80006376:	8526                	mv	a0,s1
    80006378:	ffffe097          	auipc	ra,0xffffe
    8000637c:	456080e7          	jalr	1110(ra) # 800047ce <writei>
    80006380:	47c1                	li	a5,16
    80006382:	0af51f63          	bne	a0,a5,80006440 <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80006386:	04491703          	lh	a4,68(s2)
    8000638a:	4785                	li	a5,1
    8000638c:	0cf70463          	beq	a4,a5,80006454 <sys_unlink+0x1a4>
  iunlockput(dp);
    80006390:	8526                	mv	a0,s1
    80006392:	ffffe097          	auipc	ra,0xffffe
    80006396:	2e0080e7          	jalr	736(ra) # 80004672 <iunlockput>
  ip->nlink--;
    8000639a:	04a95783          	lhu	a5,74(s2)
    8000639e:	37fd                	addiw	a5,a5,-1
    800063a0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800063a4:	854a                	mv	a0,s2
    800063a6:	ffffe097          	auipc	ra,0xffffe
    800063aa:	f9a080e7          	jalr	-102(ra) # 80004340 <iupdate>
  iunlockput(ip);
    800063ae:	854a                	mv	a0,s2
    800063b0:	ffffe097          	auipc	ra,0xffffe
    800063b4:	2c2080e7          	jalr	706(ra) # 80004672 <iunlockput>
  end_op();
    800063b8:	fffff097          	auipc	ra,0xfffff
    800063bc:	ab8080e7          	jalr	-1352(ra) # 80004e70 <end_op>
  return 0;
    800063c0:	4501                	li	a0,0
    800063c2:	74ae                	ld	s1,232(sp)
    800063c4:	790e                	ld	s2,224(sp)
    800063c6:	69ee                	ld	s3,216(sp)
    800063c8:	a86d                	j	80006482 <sys_unlink+0x1d2>
    end_op();
    800063ca:	fffff097          	auipc	ra,0xfffff
    800063ce:	aa6080e7          	jalr	-1370(ra) # 80004e70 <end_op>
    return -1;
    800063d2:	557d                	li	a0,-1
    800063d4:	74ae                	ld	s1,232(sp)
    800063d6:	a075                	j	80006482 <sys_unlink+0x1d2>
    800063d8:	e9d2                	sd	s4,208(sp)
    800063da:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    800063dc:	00003517          	auipc	a0,0x3
    800063e0:	28c50513          	addi	a0,a0,652 # 80009668 <etext+0x668>
    800063e4:	ffffa097          	auipc	ra,0xffffa
    800063e8:	17c080e7          	jalr	380(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800063ec:	04c92703          	lw	a4,76(s2)
    800063f0:	02000793          	li	a5,32
    800063f4:	f6e7f3e3          	bgeu	a5,a4,8000635a <sys_unlink+0xaa>
    800063f8:	e9d2                	sd	s4,208(sp)
    800063fa:	e5d6                	sd	s5,200(sp)
    800063fc:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800063fe:	f0840a93          	addi	s5,s0,-248
    80006402:	4a41                	li	s4,16
    80006404:	8752                	mv	a4,s4
    80006406:	86ce                	mv	a3,s3
    80006408:	8656                	mv	a2,s5
    8000640a:	4581                	li	a1,0
    8000640c:	854a                	mv	a0,s2
    8000640e:	ffffe097          	auipc	ra,0xffffe
    80006412:	2ba080e7          	jalr	698(ra) # 800046c8 <readi>
    80006416:	01451d63          	bne	a0,s4,80006430 <sys_unlink+0x180>
    if(de.inum != 0)
    8000641a:	f0845783          	lhu	a5,-248(s0)
    8000641e:	eba5                	bnez	a5,8000648e <sys_unlink+0x1de>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006420:	29c1                	addiw	s3,s3,16
    80006422:	04c92783          	lw	a5,76(s2)
    80006426:	fcf9efe3          	bltu	s3,a5,80006404 <sys_unlink+0x154>
    8000642a:	6a4e                	ld	s4,208(sp)
    8000642c:	6aae                	ld	s5,200(sp)
    8000642e:	b735                	j	8000635a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006430:	00003517          	auipc	a0,0x3
    80006434:	25050513          	addi	a0,a0,592 # 80009680 <etext+0x680>
    80006438:	ffffa097          	auipc	ra,0xffffa
    8000643c:	128080e7          	jalr	296(ra) # 80000560 <panic>
    80006440:	e9d2                	sd	s4,208(sp)
    80006442:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80006444:	00003517          	auipc	a0,0x3
    80006448:	25450513          	addi	a0,a0,596 # 80009698 <etext+0x698>
    8000644c:	ffffa097          	auipc	ra,0xffffa
    80006450:	114080e7          	jalr	276(ra) # 80000560 <panic>
    dp->nlink--;
    80006454:	04a4d783          	lhu	a5,74(s1)
    80006458:	37fd                	addiw	a5,a5,-1
    8000645a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000645e:	8526                	mv	a0,s1
    80006460:	ffffe097          	auipc	ra,0xffffe
    80006464:	ee0080e7          	jalr	-288(ra) # 80004340 <iupdate>
    80006468:	b725                	j	80006390 <sys_unlink+0xe0>
    8000646a:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    8000646c:	8526                	mv	a0,s1
    8000646e:	ffffe097          	auipc	ra,0xffffe
    80006472:	204080e7          	jalr	516(ra) # 80004672 <iunlockput>
  end_op();
    80006476:	fffff097          	auipc	ra,0xfffff
    8000647a:	9fa080e7          	jalr	-1542(ra) # 80004e70 <end_op>
  return -1;
    8000647e:	557d                	li	a0,-1
    80006480:	74ae                	ld	s1,232(sp)
}
    80006482:	70ee                	ld	ra,248(sp)
    80006484:	744e                	ld	s0,240(sp)
    80006486:	6111                	addi	sp,sp,256
    80006488:	8082                	ret
    return -1;
    8000648a:	557d                	li	a0,-1
    8000648c:	bfdd                	j	80006482 <sys_unlink+0x1d2>
    iunlockput(ip);
    8000648e:	854a                	mv	a0,s2
    80006490:	ffffe097          	auipc	ra,0xffffe
    80006494:	1e2080e7          	jalr	482(ra) # 80004672 <iunlockput>
    goto bad;
    80006498:	790e                	ld	s2,224(sp)
    8000649a:	69ee                	ld	s3,216(sp)
    8000649c:	6a4e                	ld	s4,208(sp)
    8000649e:	6aae                	ld	s5,200(sp)
    800064a0:	b7f1                	j	8000646c <sys_unlink+0x1bc>

00000000800064a2 <sys_open>:

uint64
sys_open(void)
{
    800064a2:	7131                	addi	sp,sp,-192
    800064a4:	fd06                	sd	ra,184(sp)
    800064a6:	f922                	sd	s0,176(sp)
    800064a8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800064aa:	f4c40593          	addi	a1,s0,-180
    800064ae:	4505                	li	a0,1
    800064b0:	ffffd097          	auipc	ra,0xffffd
    800064b4:	242080e7          	jalr	578(ra) # 800036f2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800064b8:	08000613          	li	a2,128
    800064bc:	f5040593          	addi	a1,s0,-176
    800064c0:	4501                	li	a0,0
    800064c2:	ffffd097          	auipc	ra,0xffffd
    800064c6:	270080e7          	jalr	624(ra) # 80003732 <argstr>
    800064ca:	87aa                	mv	a5,a0
    return -1;
    800064cc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800064ce:	0a07cf63          	bltz	a5,8000658c <sys_open+0xea>
    800064d2:	f526                	sd	s1,168(sp)

  begin_op();
    800064d4:	fffff097          	auipc	ra,0xfffff
    800064d8:	922080e7          	jalr	-1758(ra) # 80004df6 <begin_op>

  if(omode & O_CREATE){
    800064dc:	f4c42783          	lw	a5,-180(s0)
    800064e0:	2007f793          	andi	a5,a5,512
    800064e4:	cfdd                	beqz	a5,800065a2 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    800064e6:	4681                	li	a3,0
    800064e8:	4601                	li	a2,0
    800064ea:	4589                	li	a1,2
    800064ec:	f5040513          	addi	a0,s0,-176
    800064f0:	00000097          	auipc	ra,0x0
    800064f4:	94a080e7          	jalr	-1718(ra) # 80005e3a <create>
    800064f8:	84aa                	mv	s1,a0
    if(ip == 0){
    800064fa:	cd49                	beqz	a0,80006594 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800064fc:	04449703          	lh	a4,68(s1)
    80006500:	478d                	li	a5,3
    80006502:	00f71763          	bne	a4,a5,80006510 <sys_open+0x6e>
    80006506:	0464d703          	lhu	a4,70(s1)
    8000650a:	47a5                	li	a5,9
    8000650c:	0ee7e263          	bltu	a5,a4,800065f0 <sys_open+0x14e>
    80006510:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006512:	fffff097          	auipc	ra,0xfffff
    80006516:	cf8080e7          	jalr	-776(ra) # 8000520a <filealloc>
    8000651a:	892a                	mv	s2,a0
    8000651c:	cd65                	beqz	a0,80006614 <sys_open+0x172>
    8000651e:	ed4e                	sd	s3,152(sp)
    80006520:	00000097          	auipc	ra,0x0
    80006524:	8d8080e7          	jalr	-1832(ra) # 80005df8 <fdalloc>
    80006528:	89aa                	mv	s3,a0
    8000652a:	0c054f63          	bltz	a0,80006608 <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000652e:	04449703          	lh	a4,68(s1)
    80006532:	478d                	li	a5,3
    80006534:	0ef70d63          	beq	a4,a5,8000662e <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006538:	4789                	li	a5,2
    8000653a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000653e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006542:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006546:	f4c42783          	lw	a5,-180(s0)
    8000654a:	0017f713          	andi	a4,a5,1
    8000654e:	00174713          	xori	a4,a4,1
    80006552:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006556:	0037f713          	andi	a4,a5,3
    8000655a:	00e03733          	snez	a4,a4
    8000655e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006562:	4007f793          	andi	a5,a5,1024
    80006566:	c791                	beqz	a5,80006572 <sys_open+0xd0>
    80006568:	04449703          	lh	a4,68(s1)
    8000656c:	4789                	li	a5,2
    8000656e:	0cf70763          	beq	a4,a5,8000663c <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80006572:	8526                	mv	a0,s1
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	f5e080e7          	jalr	-162(ra) # 800044d2 <iunlock>
  end_op();
    8000657c:	fffff097          	auipc	ra,0xfffff
    80006580:	8f4080e7          	jalr	-1804(ra) # 80004e70 <end_op>

  return fd;
    80006584:	854e                	mv	a0,s3
    80006586:	74aa                	ld	s1,168(sp)
    80006588:	790a                	ld	s2,160(sp)
    8000658a:	69ea                	ld	s3,152(sp)
}
    8000658c:	70ea                	ld	ra,184(sp)
    8000658e:	744a                	ld	s0,176(sp)
    80006590:	6129                	addi	sp,sp,192
    80006592:	8082                	ret
      end_op();
    80006594:	fffff097          	auipc	ra,0xfffff
    80006598:	8dc080e7          	jalr	-1828(ra) # 80004e70 <end_op>
      return -1;
    8000659c:	557d                	li	a0,-1
    8000659e:	74aa                	ld	s1,168(sp)
    800065a0:	b7f5                	j	8000658c <sys_open+0xea>
    if((ip = namei(path)) == 0){
    800065a2:	f5040513          	addi	a0,s0,-176
    800065a6:	ffffe097          	auipc	ra,0xffffe
    800065aa:	64a080e7          	jalr	1610(ra) # 80004bf0 <namei>
    800065ae:	84aa                	mv	s1,a0
    800065b0:	c90d                	beqz	a0,800065e2 <sys_open+0x140>
    ilock(ip);
    800065b2:	ffffe097          	auipc	ra,0xffffe
    800065b6:	e5a080e7          	jalr	-422(ra) # 8000440c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800065ba:	04449703          	lh	a4,68(s1)
    800065be:	4785                	li	a5,1
    800065c0:	f2f71ee3          	bne	a4,a5,800064fc <sys_open+0x5a>
    800065c4:	f4c42783          	lw	a5,-180(s0)
    800065c8:	d7a1                	beqz	a5,80006510 <sys_open+0x6e>
      iunlockput(ip);
    800065ca:	8526                	mv	a0,s1
    800065cc:	ffffe097          	auipc	ra,0xffffe
    800065d0:	0a6080e7          	jalr	166(ra) # 80004672 <iunlockput>
      end_op();
    800065d4:	fffff097          	auipc	ra,0xfffff
    800065d8:	89c080e7          	jalr	-1892(ra) # 80004e70 <end_op>
      return -1;
    800065dc:	557d                	li	a0,-1
    800065de:	74aa                	ld	s1,168(sp)
    800065e0:	b775                	j	8000658c <sys_open+0xea>
      end_op();
    800065e2:	fffff097          	auipc	ra,0xfffff
    800065e6:	88e080e7          	jalr	-1906(ra) # 80004e70 <end_op>
      return -1;
    800065ea:	557d                	li	a0,-1
    800065ec:	74aa                	ld	s1,168(sp)
    800065ee:	bf79                	j	8000658c <sys_open+0xea>
    iunlockput(ip);
    800065f0:	8526                	mv	a0,s1
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	080080e7          	jalr	128(ra) # 80004672 <iunlockput>
    end_op();
    800065fa:	fffff097          	auipc	ra,0xfffff
    800065fe:	876080e7          	jalr	-1930(ra) # 80004e70 <end_op>
    return -1;
    80006602:	557d                	li	a0,-1
    80006604:	74aa                	ld	s1,168(sp)
    80006606:	b759                	j	8000658c <sys_open+0xea>
      fileclose(f);
    80006608:	854a                	mv	a0,s2
    8000660a:	fffff097          	auipc	ra,0xfffff
    8000660e:	cbc080e7          	jalr	-836(ra) # 800052c6 <fileclose>
    80006612:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006614:	8526                	mv	a0,s1
    80006616:	ffffe097          	auipc	ra,0xffffe
    8000661a:	05c080e7          	jalr	92(ra) # 80004672 <iunlockput>
    end_op();
    8000661e:	fffff097          	auipc	ra,0xfffff
    80006622:	852080e7          	jalr	-1966(ra) # 80004e70 <end_op>
    return -1;
    80006626:	557d                	li	a0,-1
    80006628:	74aa                	ld	s1,168(sp)
    8000662a:	790a                	ld	s2,160(sp)
    8000662c:	b785                	j	8000658c <sys_open+0xea>
    f->type = FD_DEVICE;
    8000662e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006632:	04649783          	lh	a5,70(s1)
    80006636:	02f91223          	sh	a5,36(s2)
    8000663a:	b721                	j	80006542 <sys_open+0xa0>
    itrunc(ip);
    8000663c:	8526                	mv	a0,s1
    8000663e:	ffffe097          	auipc	ra,0xffffe
    80006642:	ee0080e7          	jalr	-288(ra) # 8000451e <itrunc>
    80006646:	b735                	j	80006572 <sys_open+0xd0>

0000000080006648 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006648:	7175                	addi	sp,sp,-144
    8000664a:	e506                	sd	ra,136(sp)
    8000664c:	e122                	sd	s0,128(sp)
    8000664e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006650:	ffffe097          	auipc	ra,0xffffe
    80006654:	7a6080e7          	jalr	1958(ra) # 80004df6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006658:	08000613          	li	a2,128
    8000665c:	f7040593          	addi	a1,s0,-144
    80006660:	4501                	li	a0,0
    80006662:	ffffd097          	auipc	ra,0xffffd
    80006666:	0d0080e7          	jalr	208(ra) # 80003732 <argstr>
    8000666a:	02054963          	bltz	a0,8000669c <sys_mkdir+0x54>
    8000666e:	4681                	li	a3,0
    80006670:	4601                	li	a2,0
    80006672:	4585                	li	a1,1
    80006674:	f7040513          	addi	a0,s0,-144
    80006678:	fffff097          	auipc	ra,0xfffff
    8000667c:	7c2080e7          	jalr	1986(ra) # 80005e3a <create>
    80006680:	cd11                	beqz	a0,8000669c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006682:	ffffe097          	auipc	ra,0xffffe
    80006686:	ff0080e7          	jalr	-16(ra) # 80004672 <iunlockput>
  end_op();
    8000668a:	ffffe097          	auipc	ra,0xffffe
    8000668e:	7e6080e7          	jalr	2022(ra) # 80004e70 <end_op>
  return 0;
    80006692:	4501                	li	a0,0
}
    80006694:	60aa                	ld	ra,136(sp)
    80006696:	640a                	ld	s0,128(sp)
    80006698:	6149                	addi	sp,sp,144
    8000669a:	8082                	ret
    end_op();
    8000669c:	ffffe097          	auipc	ra,0xffffe
    800066a0:	7d4080e7          	jalr	2004(ra) # 80004e70 <end_op>
    return -1;
    800066a4:	557d                	li	a0,-1
    800066a6:	b7fd                	j	80006694 <sys_mkdir+0x4c>

00000000800066a8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800066a8:	7135                	addi	sp,sp,-160
    800066aa:	ed06                	sd	ra,152(sp)
    800066ac:	e922                	sd	s0,144(sp)
    800066ae:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800066b0:	ffffe097          	auipc	ra,0xffffe
    800066b4:	746080e7          	jalr	1862(ra) # 80004df6 <begin_op>
  argint(1, &major);
    800066b8:	f6c40593          	addi	a1,s0,-148
    800066bc:	4505                	li	a0,1
    800066be:	ffffd097          	auipc	ra,0xffffd
    800066c2:	034080e7          	jalr	52(ra) # 800036f2 <argint>
  argint(2, &minor);
    800066c6:	f6840593          	addi	a1,s0,-152
    800066ca:	4509                	li	a0,2
    800066cc:	ffffd097          	auipc	ra,0xffffd
    800066d0:	026080e7          	jalr	38(ra) # 800036f2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066d4:	08000613          	li	a2,128
    800066d8:	f7040593          	addi	a1,s0,-144
    800066dc:	4501                	li	a0,0
    800066de:	ffffd097          	auipc	ra,0xffffd
    800066e2:	054080e7          	jalr	84(ra) # 80003732 <argstr>
    800066e6:	02054b63          	bltz	a0,8000671c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800066ea:	f6841683          	lh	a3,-152(s0)
    800066ee:	f6c41603          	lh	a2,-148(s0)
    800066f2:	458d                	li	a1,3
    800066f4:	f7040513          	addi	a0,s0,-144
    800066f8:	fffff097          	auipc	ra,0xfffff
    800066fc:	742080e7          	jalr	1858(ra) # 80005e3a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006700:	cd11                	beqz	a0,8000671c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006702:	ffffe097          	auipc	ra,0xffffe
    80006706:	f70080e7          	jalr	-144(ra) # 80004672 <iunlockput>
  end_op();
    8000670a:	ffffe097          	auipc	ra,0xffffe
    8000670e:	766080e7          	jalr	1894(ra) # 80004e70 <end_op>
  return 0;
    80006712:	4501                	li	a0,0
}
    80006714:	60ea                	ld	ra,152(sp)
    80006716:	644a                	ld	s0,144(sp)
    80006718:	610d                	addi	sp,sp,160
    8000671a:	8082                	ret
    end_op();
    8000671c:	ffffe097          	auipc	ra,0xffffe
    80006720:	754080e7          	jalr	1876(ra) # 80004e70 <end_op>
    return -1;
    80006724:	557d                	li	a0,-1
    80006726:	b7fd                	j	80006714 <sys_mknod+0x6c>

0000000080006728 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006728:	7135                	addi	sp,sp,-160
    8000672a:	ed06                	sd	ra,152(sp)
    8000672c:	e922                	sd	s0,144(sp)
    8000672e:	e14a                	sd	s2,128(sp)
    80006730:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006732:	ffffb097          	auipc	ra,0xffffb
    80006736:	74c080e7          	jalr	1868(ra) # 80001e7e <myproc>
    8000673a:	892a                	mv	s2,a0
  
  begin_op();
    8000673c:	ffffe097          	auipc	ra,0xffffe
    80006740:	6ba080e7          	jalr	1722(ra) # 80004df6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006744:	08000613          	li	a2,128
    80006748:	f6040593          	addi	a1,s0,-160
    8000674c:	4501                	li	a0,0
    8000674e:	ffffd097          	auipc	ra,0xffffd
    80006752:	fe4080e7          	jalr	-28(ra) # 80003732 <argstr>
    80006756:	04054d63          	bltz	a0,800067b0 <sys_chdir+0x88>
    8000675a:	e526                	sd	s1,136(sp)
    8000675c:	f6040513          	addi	a0,s0,-160
    80006760:	ffffe097          	auipc	ra,0xffffe
    80006764:	490080e7          	jalr	1168(ra) # 80004bf0 <namei>
    80006768:	84aa                	mv	s1,a0
    8000676a:	c131                	beqz	a0,800067ae <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000676c:	ffffe097          	auipc	ra,0xffffe
    80006770:	ca0080e7          	jalr	-864(ra) # 8000440c <ilock>
  if(ip->type != T_DIR){
    80006774:	04449703          	lh	a4,68(s1)
    80006778:	4785                	li	a5,1
    8000677a:	04f71163          	bne	a4,a5,800067bc <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000677e:	8526                	mv	a0,s1
    80006780:	ffffe097          	auipc	ra,0xffffe
    80006784:	d52080e7          	jalr	-686(ra) # 800044d2 <iunlock>
  iput(p->cwd);
    80006788:	32893503          	ld	a0,808(s2)
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	e3e080e7          	jalr	-450(ra) # 800045ca <iput>
  end_op();
    80006794:	ffffe097          	auipc	ra,0xffffe
    80006798:	6dc080e7          	jalr	1756(ra) # 80004e70 <end_op>
  p->cwd = ip;
    8000679c:	32993423          	sd	s1,808(s2)
  return 0;
    800067a0:	4501                	li	a0,0
    800067a2:	64aa                	ld	s1,136(sp)
}
    800067a4:	60ea                	ld	ra,152(sp)
    800067a6:	644a                	ld	s0,144(sp)
    800067a8:	690a                	ld	s2,128(sp)
    800067aa:	610d                	addi	sp,sp,160
    800067ac:	8082                	ret
    800067ae:	64aa                	ld	s1,136(sp)
    end_op();
    800067b0:	ffffe097          	auipc	ra,0xffffe
    800067b4:	6c0080e7          	jalr	1728(ra) # 80004e70 <end_op>
    return -1;
    800067b8:	557d                	li	a0,-1
    800067ba:	b7ed                	j	800067a4 <sys_chdir+0x7c>
    iunlockput(ip);
    800067bc:	8526                	mv	a0,s1
    800067be:	ffffe097          	auipc	ra,0xffffe
    800067c2:	eb4080e7          	jalr	-332(ra) # 80004672 <iunlockput>
    end_op();
    800067c6:	ffffe097          	auipc	ra,0xffffe
    800067ca:	6aa080e7          	jalr	1706(ra) # 80004e70 <end_op>
    return -1;
    800067ce:	557d                	li	a0,-1
    800067d0:	64aa                	ld	s1,136(sp)
    800067d2:	bfc9                	j	800067a4 <sys_chdir+0x7c>

00000000800067d4 <sys_exec>:

uint64
sys_exec(void)
{
    800067d4:	7105                	addi	sp,sp,-480
    800067d6:	ef86                	sd	ra,472(sp)
    800067d8:	eba2                	sd	s0,464(sp)
    800067da:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800067dc:	e2840593          	addi	a1,s0,-472
    800067e0:	4505                	li	a0,1
    800067e2:	ffffd097          	auipc	ra,0xffffd
    800067e6:	f30080e7          	jalr	-208(ra) # 80003712 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800067ea:	08000613          	li	a2,128
    800067ee:	f3040593          	addi	a1,s0,-208
    800067f2:	4501                	li	a0,0
    800067f4:	ffffd097          	auipc	ra,0xffffd
    800067f8:	f3e080e7          	jalr	-194(ra) # 80003732 <argstr>
    800067fc:	87aa                	mv	a5,a0
    return -1;
    800067fe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006800:	0e07ce63          	bltz	a5,800068fc <sys_exec+0x128>
    80006804:	e7a6                	sd	s1,456(sp)
    80006806:	e3ca                	sd	s2,448(sp)
    80006808:	ff4e                	sd	s3,440(sp)
    8000680a:	fb52                	sd	s4,432(sp)
    8000680c:	f756                	sd	s5,424(sp)
    8000680e:	f35a                	sd	s6,416(sp)
    80006810:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006812:	e3040a13          	addi	s4,s0,-464
    80006816:	10000613          	li	a2,256
    8000681a:	4581                	li	a1,0
    8000681c:	8552                	mv	a0,s4
    8000681e:	ffffa097          	auipc	ra,0xffffa
    80006822:	68a080e7          	jalr	1674(ra) # 80000ea8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006826:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80006828:	89d2                	mv	s3,s4
    8000682a:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000682c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006830:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80006832:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006836:	00391513          	slli	a0,s2,0x3
    8000683a:	85d6                	mv	a1,s5
    8000683c:	e2843783          	ld	a5,-472(s0)
    80006840:	953e                	add	a0,a0,a5
    80006842:	ffffd097          	auipc	ra,0xffffd
    80006846:	e0c080e7          	jalr	-500(ra) # 8000364e <fetchaddr>
    8000684a:	02054a63          	bltz	a0,8000687e <sys_exec+0xaa>
    if(uarg == 0){
    8000684e:	e2043783          	ld	a5,-480(s0)
    80006852:	cbb1                	beqz	a5,800068a6 <sys_exec+0xd2>
    argv[i] = kalloc();
    80006854:	ffffa097          	auipc	ra,0xffffa
    80006858:	45e080e7          	jalr	1118(ra) # 80000cb2 <kalloc>
    8000685c:	85aa                	mv	a1,a0
    8000685e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006862:	cd11                	beqz	a0,8000687e <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006864:	865a                	mv	a2,s6
    80006866:	e2043503          	ld	a0,-480(s0)
    8000686a:	ffffd097          	auipc	ra,0xffffd
    8000686e:	e3a080e7          	jalr	-454(ra) # 800036a4 <fetchstr>
    80006872:	00054663          	bltz	a0,8000687e <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80006876:	0905                	addi	s2,s2,1
    80006878:	09a1                	addi	s3,s3,8
    8000687a:	fb791ee3          	bne	s2,s7,80006836 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000687e:	100a0a13          	addi	s4,s4,256
    80006882:	6088                	ld	a0,0(s1)
    80006884:	c525                	beqz	a0,800068ec <sys_exec+0x118>
    kfree(argv[i]);
    80006886:	ffffa097          	auipc	ra,0xffffa
    8000688a:	2bc080e7          	jalr	700(ra) # 80000b42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000688e:	04a1                	addi	s1,s1,8
    80006890:	ff4499e3          	bne	s1,s4,80006882 <sys_exec+0xae>
  return -1;
    80006894:	557d                	li	a0,-1
    80006896:	64be                	ld	s1,456(sp)
    80006898:	691e                	ld	s2,448(sp)
    8000689a:	79fa                	ld	s3,440(sp)
    8000689c:	7a5a                	ld	s4,432(sp)
    8000689e:	7aba                	ld	s5,424(sp)
    800068a0:	7b1a                	ld	s6,416(sp)
    800068a2:	6bfa                	ld	s7,408(sp)
    800068a4:	a8a1                	j	800068fc <sys_exec+0x128>
      argv[i] = 0;
    800068a6:	0009079b          	sext.w	a5,s2
    800068aa:	e3040593          	addi	a1,s0,-464
    800068ae:	078e                	slli	a5,a5,0x3
    800068b0:	97ae                	add	a5,a5,a1
    800068b2:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    800068b6:	f3040513          	addi	a0,s0,-208
    800068ba:	fffff097          	auipc	ra,0xfffff
    800068be:	116080e7          	jalr	278(ra) # 800059d0 <exec>
    800068c2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068c4:	100a0a13          	addi	s4,s4,256
    800068c8:	6088                	ld	a0,0(s1)
    800068ca:	c901                	beqz	a0,800068da <sys_exec+0x106>
    kfree(argv[i]);
    800068cc:	ffffa097          	auipc	ra,0xffffa
    800068d0:	276080e7          	jalr	630(ra) # 80000b42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068d4:	04a1                	addi	s1,s1,8
    800068d6:	ff4499e3          	bne	s1,s4,800068c8 <sys_exec+0xf4>
  return ret;
    800068da:	854a                	mv	a0,s2
    800068dc:	64be                	ld	s1,456(sp)
    800068de:	691e                	ld	s2,448(sp)
    800068e0:	79fa                	ld	s3,440(sp)
    800068e2:	7a5a                	ld	s4,432(sp)
    800068e4:	7aba                	ld	s5,424(sp)
    800068e6:	7b1a                	ld	s6,416(sp)
    800068e8:	6bfa                	ld	s7,408(sp)
    800068ea:	a809                	j	800068fc <sys_exec+0x128>
  return -1;
    800068ec:	557d                	li	a0,-1
    800068ee:	64be                	ld	s1,456(sp)
    800068f0:	691e                	ld	s2,448(sp)
    800068f2:	79fa                	ld	s3,440(sp)
    800068f4:	7a5a                	ld	s4,432(sp)
    800068f6:	7aba                	ld	s5,424(sp)
    800068f8:	7b1a                	ld	s6,416(sp)
    800068fa:	6bfa                	ld	s7,408(sp)
}
    800068fc:	60fe                	ld	ra,472(sp)
    800068fe:	645e                	ld	s0,464(sp)
    80006900:	613d                	addi	sp,sp,480
    80006902:	8082                	ret

0000000080006904 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006904:	7139                	addi	sp,sp,-64
    80006906:	fc06                	sd	ra,56(sp)
    80006908:	f822                	sd	s0,48(sp)
    8000690a:	f426                	sd	s1,40(sp)
    8000690c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000690e:	ffffb097          	auipc	ra,0xffffb
    80006912:	570080e7          	jalr	1392(ra) # 80001e7e <myproc>
    80006916:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006918:	fd840593          	addi	a1,s0,-40
    8000691c:	4501                	li	a0,0
    8000691e:	ffffd097          	auipc	ra,0xffffd
    80006922:	df4080e7          	jalr	-524(ra) # 80003712 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006926:	fc840593          	addi	a1,s0,-56
    8000692a:	fd040513          	addi	a0,s0,-48
    8000692e:	fffff097          	auipc	ra,0xfffff
    80006932:	d0c080e7          	jalr	-756(ra) # 8000563a <pipealloc>
    return -1;
    80006936:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006938:	0c054963          	bltz	a0,80006a0a <sys_pipe+0x106>
  fd0 = -1;
    8000693c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006940:	fd043503          	ld	a0,-48(s0)
    80006944:	fffff097          	auipc	ra,0xfffff
    80006948:	4b4080e7          	jalr	1204(ra) # 80005df8 <fdalloc>
    8000694c:	fca42223          	sw	a0,-60(s0)
    80006950:	0a054063          	bltz	a0,800069f0 <sys_pipe+0xec>
    80006954:	fc843503          	ld	a0,-56(s0)
    80006958:	fffff097          	auipc	ra,0xfffff
    8000695c:	4a0080e7          	jalr	1184(ra) # 80005df8 <fdalloc>
    80006960:	fca42023          	sw	a0,-64(s0)
    80006964:	06054c63          	bltz	a0,800069dc <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006968:	4691                	li	a3,4
    8000696a:	fc440613          	addi	a2,s0,-60
    8000696e:	fd843583          	ld	a1,-40(s0)
    80006972:	2284b503          	ld	a0,552(s1)
    80006976:	ffffb097          	auipc	ra,0xffffb
    8000697a:	ffc080e7          	jalr	-4(ra) # 80001972 <copyout>
    8000697e:	02054163          	bltz	a0,800069a0 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006982:	4691                	li	a3,4
    80006984:	fc040613          	addi	a2,s0,-64
    80006988:	fd843583          	ld	a1,-40(s0)
    8000698c:	95b6                	add	a1,a1,a3
    8000698e:	2284b503          	ld	a0,552(s1)
    80006992:	ffffb097          	auipc	ra,0xffffb
    80006996:	fe0080e7          	jalr	-32(ra) # 80001972 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000699a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000699c:	06055763          	bgez	a0,80006a0a <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    800069a0:	fc442783          	lw	a5,-60(s0)
    800069a4:	05478793          	addi	a5,a5,84
    800069a8:	078e                	slli	a5,a5,0x3
    800069aa:	97a6                	add	a5,a5,s1
    800069ac:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800069b0:	fc042783          	lw	a5,-64(s0)
    800069b4:	05478793          	addi	a5,a5,84
    800069b8:	078e                	slli	a5,a5,0x3
    800069ba:	94be                	add	s1,s1,a5
    800069bc:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800069c0:	fd043503          	ld	a0,-48(s0)
    800069c4:	fffff097          	auipc	ra,0xfffff
    800069c8:	902080e7          	jalr	-1790(ra) # 800052c6 <fileclose>
    fileclose(wf);
    800069cc:	fc843503          	ld	a0,-56(s0)
    800069d0:	fffff097          	auipc	ra,0xfffff
    800069d4:	8f6080e7          	jalr	-1802(ra) # 800052c6 <fileclose>
    return -1;
    800069d8:	57fd                	li	a5,-1
    800069da:	a805                	j	80006a0a <sys_pipe+0x106>
    if(fd0 >= 0)
    800069dc:	fc442783          	lw	a5,-60(s0)
    800069e0:	0007c863          	bltz	a5,800069f0 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    800069e4:	05478793          	addi	a5,a5,84
    800069e8:	078e                	slli	a5,a5,0x3
    800069ea:	97a6                	add	a5,a5,s1
    800069ec:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800069f0:	fd043503          	ld	a0,-48(s0)
    800069f4:	fffff097          	auipc	ra,0xfffff
    800069f8:	8d2080e7          	jalr	-1838(ra) # 800052c6 <fileclose>
    fileclose(wf);
    800069fc:	fc843503          	ld	a0,-56(s0)
    80006a00:	fffff097          	auipc	ra,0xfffff
    80006a04:	8c6080e7          	jalr	-1850(ra) # 800052c6 <fileclose>
    return -1;
    80006a08:	57fd                	li	a5,-1
}
    80006a0a:	853e                	mv	a0,a5
    80006a0c:	70e2                	ld	ra,56(sp)
    80006a0e:	7442                	ld	s0,48(sp)
    80006a10:	74a2                	ld	s1,40(sp)
    80006a12:	6121                	addi	sp,sp,64
    80006a14:	8082                	ret
	...

0000000080006a20 <kernelvec>:
    80006a20:	7111                	addi	sp,sp,-256
    80006a22:	e006                	sd	ra,0(sp)
    80006a24:	e40a                	sd	sp,8(sp)
    80006a26:	e80e                	sd	gp,16(sp)
    80006a28:	ec12                	sd	tp,24(sp)
    80006a2a:	f016                	sd	t0,32(sp)
    80006a2c:	f41a                	sd	t1,40(sp)
    80006a2e:	f81e                	sd	t2,48(sp)
    80006a30:	fc22                	sd	s0,56(sp)
    80006a32:	e0a6                	sd	s1,64(sp)
    80006a34:	e4aa                	sd	a0,72(sp)
    80006a36:	e8ae                	sd	a1,80(sp)
    80006a38:	ecb2                	sd	a2,88(sp)
    80006a3a:	f0b6                	sd	a3,96(sp)
    80006a3c:	f4ba                	sd	a4,104(sp)
    80006a3e:	f8be                	sd	a5,112(sp)
    80006a40:	fcc2                	sd	a6,120(sp)
    80006a42:	e146                	sd	a7,128(sp)
    80006a44:	e54a                	sd	s2,136(sp)
    80006a46:	e94e                	sd	s3,144(sp)
    80006a48:	ed52                	sd	s4,152(sp)
    80006a4a:	f156                	sd	s5,160(sp)
    80006a4c:	f55a                	sd	s6,168(sp)
    80006a4e:	f95e                	sd	s7,176(sp)
    80006a50:	fd62                	sd	s8,184(sp)
    80006a52:	e1e6                	sd	s9,192(sp)
    80006a54:	e5ea                	sd	s10,200(sp)
    80006a56:	e9ee                	sd	s11,208(sp)
    80006a58:	edf2                	sd	t3,216(sp)
    80006a5a:	f1f6                	sd	t4,224(sp)
    80006a5c:	f5fa                	sd	t5,232(sp)
    80006a5e:	f9fe                	sd	t6,240(sp)
    80006a60:	aaffc0ef          	jal	8000350e <kerneltrap>
    80006a64:	6082                	ld	ra,0(sp)
    80006a66:	6122                	ld	sp,8(sp)
    80006a68:	61c2                	ld	gp,16(sp)
    80006a6a:	7282                	ld	t0,32(sp)
    80006a6c:	7322                	ld	t1,40(sp)
    80006a6e:	73c2                	ld	t2,48(sp)
    80006a70:	7462                	ld	s0,56(sp)
    80006a72:	6486                	ld	s1,64(sp)
    80006a74:	6526                	ld	a0,72(sp)
    80006a76:	65c6                	ld	a1,80(sp)
    80006a78:	6666                	ld	a2,88(sp)
    80006a7a:	7686                	ld	a3,96(sp)
    80006a7c:	7726                	ld	a4,104(sp)
    80006a7e:	77c6                	ld	a5,112(sp)
    80006a80:	7866                	ld	a6,120(sp)
    80006a82:	688a                	ld	a7,128(sp)
    80006a84:	692a                	ld	s2,136(sp)
    80006a86:	69ca                	ld	s3,144(sp)
    80006a88:	6a6a                	ld	s4,152(sp)
    80006a8a:	7a8a                	ld	s5,160(sp)
    80006a8c:	7b2a                	ld	s6,168(sp)
    80006a8e:	7bca                	ld	s7,176(sp)
    80006a90:	7c6a                	ld	s8,184(sp)
    80006a92:	6c8e                	ld	s9,192(sp)
    80006a94:	6d2e                	ld	s10,200(sp)
    80006a96:	6dce                	ld	s11,208(sp)
    80006a98:	6e6e                	ld	t3,216(sp)
    80006a9a:	7e8e                	ld	t4,224(sp)
    80006a9c:	7f2e                	ld	t5,232(sp)
    80006a9e:	7fce                	ld	t6,240(sp)
    80006aa0:	6111                	addi	sp,sp,256
    80006aa2:	10200073          	sret
    80006aa6:	00000013          	nop
    80006aaa:	00000013          	nop
    80006aae:	0001                	nop

0000000080006ab0 <timervec>:
    80006ab0:	34051573          	csrrw	a0,mscratch,a0
    80006ab4:	e10c                	sd	a1,0(a0)
    80006ab6:	e510                	sd	a2,8(a0)
    80006ab8:	e914                	sd	a3,16(a0)
    80006aba:	6d0c                	ld	a1,24(a0)
    80006abc:	7110                	ld	a2,32(a0)
    80006abe:	6194                	ld	a3,0(a1)
    80006ac0:	96b2                	add	a3,a3,a2
    80006ac2:	e194                	sd	a3,0(a1)
    80006ac4:	4589                	li	a1,2
    80006ac6:	14459073          	csrw	sip,a1
    80006aca:	6914                	ld	a3,16(a0)
    80006acc:	6510                	ld	a2,8(a0)
    80006ace:	610c                	ld	a1,0(a0)
    80006ad0:	34051573          	csrrw	a0,mscratch,a0
    80006ad4:	30200073          	mret
	...

0000000080006ada <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006ada:	1141                	addi	sp,sp,-16
    80006adc:	e406                	sd	ra,8(sp)
    80006ade:	e022                	sd	s0,0(sp)
    80006ae0:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006ae2:	0c000737          	lui	a4,0xc000
    80006ae6:	4785                	li	a5,1
    80006ae8:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006aea:	c35c                	sw	a5,4(a4)
}
    80006aec:	60a2                	ld	ra,8(sp)
    80006aee:	6402                	ld	s0,0(sp)
    80006af0:	0141                	addi	sp,sp,16
    80006af2:	8082                	ret

0000000080006af4 <plicinithart>:

void
plicinithart(void)
{
    80006af4:	1141                	addi	sp,sp,-16
    80006af6:	e406                	sd	ra,8(sp)
    80006af8:	e022                	sd	s0,0(sp)
    80006afa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006afc:	ffffb097          	auipc	ra,0xffffb
    80006b00:	34e080e7          	jalr	846(ra) # 80001e4a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006b04:	0085171b          	slliw	a4,a0,0x8
    80006b08:	0c0027b7          	lui	a5,0xc002
    80006b0c:	97ba                	add	a5,a5,a4
    80006b0e:	40200713          	li	a4,1026
    80006b12:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006b16:	00d5151b          	slliw	a0,a0,0xd
    80006b1a:	0c2017b7          	lui	a5,0xc201
    80006b1e:	97aa                	add	a5,a5,a0
    80006b20:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006b24:	60a2                	ld	ra,8(sp)
    80006b26:	6402                	ld	s0,0(sp)
    80006b28:	0141                	addi	sp,sp,16
    80006b2a:	8082                	ret

0000000080006b2c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006b2c:	1141                	addi	sp,sp,-16
    80006b2e:	e406                	sd	ra,8(sp)
    80006b30:	e022                	sd	s0,0(sp)
    80006b32:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006b34:	ffffb097          	auipc	ra,0xffffb
    80006b38:	316080e7          	jalr	790(ra) # 80001e4a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006b3c:	00d5151b          	slliw	a0,a0,0xd
    80006b40:	0c2017b7          	lui	a5,0xc201
    80006b44:	97aa                	add	a5,a5,a0
  return irq;
}
    80006b46:	43c8                	lw	a0,4(a5)
    80006b48:	60a2                	ld	ra,8(sp)
    80006b4a:	6402                	ld	s0,0(sp)
    80006b4c:	0141                	addi	sp,sp,16
    80006b4e:	8082                	ret

0000000080006b50 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006b50:	1101                	addi	sp,sp,-32
    80006b52:	ec06                	sd	ra,24(sp)
    80006b54:	e822                	sd	s0,16(sp)
    80006b56:	e426                	sd	s1,8(sp)
    80006b58:	1000                	addi	s0,sp,32
    80006b5a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006b5c:	ffffb097          	auipc	ra,0xffffb
    80006b60:	2ee080e7          	jalr	750(ra) # 80001e4a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006b64:	00d5179b          	slliw	a5,a0,0xd
    80006b68:	0c201737          	lui	a4,0xc201
    80006b6c:	97ba                	add	a5,a5,a4
    80006b6e:	c3c4                	sw	s1,4(a5)
}
    80006b70:	60e2                	ld	ra,24(sp)
    80006b72:	6442                	ld	s0,16(sp)
    80006b74:	64a2                	ld	s1,8(sp)
    80006b76:	6105                	addi	sp,sp,32
    80006b78:	8082                	ret

0000000080006b7a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006b7a:	1141                	addi	sp,sp,-16
    80006b7c:	e406                	sd	ra,8(sp)
    80006b7e:	e022                	sd	s0,0(sp)
    80006b80:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006b82:	479d                	li	a5,7
    80006b84:	04a7cc63          	blt	a5,a0,80006bdc <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006b88:	00244797          	auipc	a5,0x244
    80006b8c:	35078793          	addi	a5,a5,848 # 8024aed8 <disk>
    80006b90:	97aa                	add	a5,a5,a0
    80006b92:	0187c783          	lbu	a5,24(a5)
    80006b96:	ebb9                	bnez	a5,80006bec <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006b98:	00451693          	slli	a3,a0,0x4
    80006b9c:	00244797          	auipc	a5,0x244
    80006ba0:	33c78793          	addi	a5,a5,828 # 8024aed8 <disk>
    80006ba4:	6398                	ld	a4,0(a5)
    80006ba6:	9736                	add	a4,a4,a3
    80006ba8:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80006bac:	6398                	ld	a4,0(a5)
    80006bae:	9736                	add	a4,a4,a3
    80006bb0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006bb4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006bb8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006bbc:	97aa                	add	a5,a5,a0
    80006bbe:	4705                	li	a4,1
    80006bc0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006bc4:	00244517          	auipc	a0,0x244
    80006bc8:	32c50513          	addi	a0,a0,812 # 8024aef0 <disk+0x18>
    80006bcc:	ffffc097          	auipc	ra,0xffffc
    80006bd0:	dd4080e7          	jalr	-556(ra) # 800029a0 <wakeup>
}
    80006bd4:	60a2                	ld	ra,8(sp)
    80006bd6:	6402                	ld	s0,0(sp)
    80006bd8:	0141                	addi	sp,sp,16
    80006bda:	8082                	ret
    panic("free_desc 1");
    80006bdc:	00003517          	auipc	a0,0x3
    80006be0:	acc50513          	addi	a0,a0,-1332 # 800096a8 <etext+0x6a8>
    80006be4:	ffffa097          	auipc	ra,0xffffa
    80006be8:	97c080e7          	jalr	-1668(ra) # 80000560 <panic>
    panic("free_desc 2");
    80006bec:	00003517          	auipc	a0,0x3
    80006bf0:	acc50513          	addi	a0,a0,-1332 # 800096b8 <etext+0x6b8>
    80006bf4:	ffffa097          	auipc	ra,0xffffa
    80006bf8:	96c080e7          	jalr	-1684(ra) # 80000560 <panic>

0000000080006bfc <virtio_disk_init>:
{
    80006bfc:	1101                	addi	sp,sp,-32
    80006bfe:	ec06                	sd	ra,24(sp)
    80006c00:	e822                	sd	s0,16(sp)
    80006c02:	e426                	sd	s1,8(sp)
    80006c04:	e04a                	sd	s2,0(sp)
    80006c06:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006c08:	00003597          	auipc	a1,0x3
    80006c0c:	ac058593          	addi	a1,a1,-1344 # 800096c8 <etext+0x6c8>
    80006c10:	00244517          	auipc	a0,0x244
    80006c14:	3f050513          	addi	a0,a0,1008 # 8024b000 <disk+0x128>
    80006c18:	ffffa097          	auipc	ra,0xffffa
    80006c1c:	104080e7          	jalr	260(ra) # 80000d1c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c20:	100017b7          	lui	a5,0x10001
    80006c24:	4398                	lw	a4,0(a5)
    80006c26:	2701                	sext.w	a4,a4
    80006c28:	747277b7          	lui	a5,0x74727
    80006c2c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006c30:	16f71463          	bne	a4,a5,80006d98 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006c34:	100017b7          	lui	a5,0x10001
    80006c38:	43dc                	lw	a5,4(a5)
    80006c3a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c3c:	4709                	li	a4,2
    80006c3e:	14e79d63          	bne	a5,a4,80006d98 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c42:	100017b7          	lui	a5,0x10001
    80006c46:	479c                	lw	a5,8(a5)
    80006c48:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006c4a:	14e79763          	bne	a5,a4,80006d98 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006c4e:	100017b7          	lui	a5,0x10001
    80006c52:	47d8                	lw	a4,12(a5)
    80006c54:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c56:	554d47b7          	lui	a5,0x554d4
    80006c5a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006c5e:	12f71d63          	bne	a4,a5,80006d98 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c62:	100017b7          	lui	a5,0x10001
    80006c66:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c6a:	4705                	li	a4,1
    80006c6c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c6e:	470d                	li	a4,3
    80006c70:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006c72:	10001737          	lui	a4,0x10001
    80006c76:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006c78:	c7ffe6b7          	lui	a3,0xc7ffe
    80006c7c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db3747>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006c80:	8f75                	and	a4,a4,a3
    80006c82:	100016b7          	lui	a3,0x10001
    80006c86:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c88:	472d                	li	a4,11
    80006c8a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c8c:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006c90:	439c                	lw	a5,0(a5)
    80006c92:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006c96:	8ba1                	andi	a5,a5,8
    80006c98:	10078863          	beqz	a5,80006da8 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006c9c:	100017b7          	lui	a5,0x10001
    80006ca0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006ca4:	43fc                	lw	a5,68(a5)
    80006ca6:	2781                	sext.w	a5,a5
    80006ca8:	10079863          	bnez	a5,80006db8 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006cac:	100017b7          	lui	a5,0x10001
    80006cb0:	5bdc                	lw	a5,52(a5)
    80006cb2:	2781                	sext.w	a5,a5
  if(max == 0)
    80006cb4:	10078a63          	beqz	a5,80006dc8 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006cb8:	471d                	li	a4,7
    80006cba:	10f77f63          	bgeu	a4,a5,80006dd8 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    80006cbe:	ffffa097          	auipc	ra,0xffffa
    80006cc2:	ff4080e7          	jalr	-12(ra) # 80000cb2 <kalloc>
    80006cc6:	00244497          	auipc	s1,0x244
    80006cca:	21248493          	addi	s1,s1,530 # 8024aed8 <disk>
    80006cce:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006cd0:	ffffa097          	auipc	ra,0xffffa
    80006cd4:	fe2080e7          	jalr	-30(ra) # 80000cb2 <kalloc>
    80006cd8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006cda:	ffffa097          	auipc	ra,0xffffa
    80006cde:	fd8080e7          	jalr	-40(ra) # 80000cb2 <kalloc>
    80006ce2:	87aa                	mv	a5,a0
    80006ce4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006ce6:	6088                	ld	a0,0(s1)
    80006ce8:	10050063          	beqz	a0,80006de8 <virtio_disk_init+0x1ec>
    80006cec:	00244717          	auipc	a4,0x244
    80006cf0:	1f473703          	ld	a4,500(a4) # 8024aee0 <disk+0x8>
    80006cf4:	cb75                	beqz	a4,80006de8 <virtio_disk_init+0x1ec>
    80006cf6:	cbed                	beqz	a5,80006de8 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006cf8:	6605                	lui	a2,0x1
    80006cfa:	4581                	li	a1,0
    80006cfc:	ffffa097          	auipc	ra,0xffffa
    80006d00:	1ac080e7          	jalr	428(ra) # 80000ea8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006d04:	00244497          	auipc	s1,0x244
    80006d08:	1d448493          	addi	s1,s1,468 # 8024aed8 <disk>
    80006d0c:	6605                	lui	a2,0x1
    80006d0e:	4581                	li	a1,0
    80006d10:	6488                	ld	a0,8(s1)
    80006d12:	ffffa097          	auipc	ra,0xffffa
    80006d16:	196080e7          	jalr	406(ra) # 80000ea8 <memset>
  memset(disk.used, 0, PGSIZE);
    80006d1a:	6605                	lui	a2,0x1
    80006d1c:	4581                	li	a1,0
    80006d1e:	6888                	ld	a0,16(s1)
    80006d20:	ffffa097          	auipc	ra,0xffffa
    80006d24:	188080e7          	jalr	392(ra) # 80000ea8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006d28:	100017b7          	lui	a5,0x10001
    80006d2c:	4721                	li	a4,8
    80006d2e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006d30:	4098                	lw	a4,0(s1)
    80006d32:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006d36:	40d8                	lw	a4,4(s1)
    80006d38:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006d3c:	649c                	ld	a5,8(s1)
    80006d3e:	0007869b          	sext.w	a3,a5
    80006d42:	10001737          	lui	a4,0x10001
    80006d46:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006d4a:	9781                	srai	a5,a5,0x20
    80006d4c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006d50:	689c                	ld	a5,16(s1)
    80006d52:	0007869b          	sext.w	a3,a5
    80006d56:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006d5a:	9781                	srai	a5,a5,0x20
    80006d5c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006d60:	4785                	li	a5,1
    80006d62:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006d64:	00f48c23          	sb	a5,24(s1)
    80006d68:	00f48ca3          	sb	a5,25(s1)
    80006d6c:	00f48d23          	sb	a5,26(s1)
    80006d70:	00f48da3          	sb	a5,27(s1)
    80006d74:	00f48e23          	sb	a5,28(s1)
    80006d78:	00f48ea3          	sb	a5,29(s1)
    80006d7c:	00f48f23          	sb	a5,30(s1)
    80006d80:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006d84:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d88:	07272823          	sw	s2,112(a4)
}
    80006d8c:	60e2                	ld	ra,24(sp)
    80006d8e:	6442                	ld	s0,16(sp)
    80006d90:	64a2                	ld	s1,8(sp)
    80006d92:	6902                	ld	s2,0(sp)
    80006d94:	6105                	addi	sp,sp,32
    80006d96:	8082                	ret
    panic("could not find virtio disk");
    80006d98:	00003517          	auipc	a0,0x3
    80006d9c:	94050513          	addi	a0,a0,-1728 # 800096d8 <etext+0x6d8>
    80006da0:	ffff9097          	auipc	ra,0xffff9
    80006da4:	7c0080e7          	jalr	1984(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006da8:	00003517          	auipc	a0,0x3
    80006dac:	95050513          	addi	a0,a0,-1712 # 800096f8 <etext+0x6f8>
    80006db0:	ffff9097          	auipc	ra,0xffff9
    80006db4:	7b0080e7          	jalr	1968(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006db8:	00003517          	auipc	a0,0x3
    80006dbc:	96050513          	addi	a0,a0,-1696 # 80009718 <etext+0x718>
    80006dc0:	ffff9097          	auipc	ra,0xffff9
    80006dc4:	7a0080e7          	jalr	1952(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006dc8:	00003517          	auipc	a0,0x3
    80006dcc:	97050513          	addi	a0,a0,-1680 # 80009738 <etext+0x738>
    80006dd0:	ffff9097          	auipc	ra,0xffff9
    80006dd4:	790080e7          	jalr	1936(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006dd8:	00003517          	auipc	a0,0x3
    80006ddc:	98050513          	addi	a0,a0,-1664 # 80009758 <etext+0x758>
    80006de0:	ffff9097          	auipc	ra,0xffff9
    80006de4:	780080e7          	jalr	1920(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006de8:	00003517          	auipc	a0,0x3
    80006dec:	99050513          	addi	a0,a0,-1648 # 80009778 <etext+0x778>
    80006df0:	ffff9097          	auipc	ra,0xffff9
    80006df4:	770080e7          	jalr	1904(ra) # 80000560 <panic>

0000000080006df8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006df8:	711d                	addi	sp,sp,-96
    80006dfa:	ec86                	sd	ra,88(sp)
    80006dfc:	e8a2                	sd	s0,80(sp)
    80006dfe:	e4a6                	sd	s1,72(sp)
    80006e00:	e0ca                	sd	s2,64(sp)
    80006e02:	fc4e                	sd	s3,56(sp)
    80006e04:	f852                	sd	s4,48(sp)
    80006e06:	f456                	sd	s5,40(sp)
    80006e08:	f05a                	sd	s6,32(sp)
    80006e0a:	ec5e                	sd	s7,24(sp)
    80006e0c:	e862                	sd	s8,16(sp)
    80006e0e:	1080                	addi	s0,sp,96
    80006e10:	89aa                	mv	s3,a0
    80006e12:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006e14:	00c52b83          	lw	s7,12(a0)
    80006e18:	001b9b9b          	slliw	s7,s7,0x1
    80006e1c:	1b82                	slli	s7,s7,0x20
    80006e1e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006e22:	00244517          	auipc	a0,0x244
    80006e26:	1de50513          	addi	a0,a0,478 # 8024b000 <disk+0x128>
    80006e2a:	ffffa097          	auipc	ra,0xffffa
    80006e2e:	f86080e7          	jalr	-122(ra) # 80000db0 <acquire>
  for(int i = 0; i < NUM; i++){
    80006e32:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006e34:	00244a97          	auipc	s5,0x244
    80006e38:	0a4a8a93          	addi	s5,s5,164 # 8024aed8 <disk>
  for(int i = 0; i < 3; i++){
    80006e3c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80006e3e:	5c7d                	li	s8,-1
    80006e40:	a885                	j	80006eb0 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006e42:	00fa8733          	add	a4,s5,a5
    80006e46:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006e4a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006e4c:	0207c563          	bltz	a5,80006e76 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    80006e50:	2905                	addiw	s2,s2,1
    80006e52:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006e54:	07490263          	beq	s2,s4,80006eb8 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    80006e58:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006e5a:	00244717          	auipc	a4,0x244
    80006e5e:	07e70713          	addi	a4,a4,126 # 8024aed8 <disk>
    80006e62:	4781                	li	a5,0
    if(disk.free[i]){
    80006e64:	01874683          	lbu	a3,24(a4)
    80006e68:	fee9                	bnez	a3,80006e42 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006e6a:	2785                	addiw	a5,a5,1
    80006e6c:	0705                	addi	a4,a4,1
    80006e6e:	fe979be3          	bne	a5,s1,80006e64 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80006e72:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80006e76:	03205163          	blez	s2,80006e98 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    80006e7a:	fa042503          	lw	a0,-96(s0)
    80006e7e:	00000097          	auipc	ra,0x0
    80006e82:	cfc080e7          	jalr	-772(ra) # 80006b7a <free_desc>
      for(int j = 0; j < i; j++)
    80006e86:	4785                	li	a5,1
    80006e88:	0127d863          	bge	a5,s2,80006e98 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    80006e8c:	fa442503          	lw	a0,-92(s0)
    80006e90:	00000097          	auipc	ra,0x0
    80006e94:	cea080e7          	jalr	-790(ra) # 80006b7a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006e98:	00244597          	auipc	a1,0x244
    80006e9c:	16858593          	addi	a1,a1,360 # 8024b000 <disk+0x128>
    80006ea0:	00244517          	auipc	a0,0x244
    80006ea4:	05050513          	addi	a0,a0,80 # 8024aef0 <disk+0x18>
    80006ea8:	ffffc097          	auipc	ra,0xffffc
    80006eac:	a94080e7          	jalr	-1388(ra) # 8000293c <sleep>
  for(int i = 0; i < 3; i++){
    80006eb0:	fa040613          	addi	a2,s0,-96
    80006eb4:	4901                	li	s2,0
    80006eb6:	b74d                	j	80006e58 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006eb8:	fa042503          	lw	a0,-96(s0)
    80006ebc:	00451693          	slli	a3,a0,0x4

  if(write)
    80006ec0:	00244797          	auipc	a5,0x244
    80006ec4:	01878793          	addi	a5,a5,24 # 8024aed8 <disk>
    80006ec8:	00a50713          	addi	a4,a0,10
    80006ecc:	0712                	slli	a4,a4,0x4
    80006ece:	973e                	add	a4,a4,a5
    80006ed0:	01603633          	snez	a2,s6
    80006ed4:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006ed6:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006eda:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006ede:	6398                	ld	a4,0(a5)
    80006ee0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ee2:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006ee6:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006ee8:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006eea:	6390                	ld	a2,0(a5)
    80006eec:	00d605b3          	add	a1,a2,a3
    80006ef0:	4741                	li	a4,16
    80006ef2:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006ef4:	4805                	li	a6,1
    80006ef6:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006efa:	fa442703          	lw	a4,-92(s0)
    80006efe:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006f02:	0712                	slli	a4,a4,0x4
    80006f04:	963a                	add	a2,a2,a4
    80006f06:	05898593          	addi	a1,s3,88
    80006f0a:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006f0c:	0007b883          	ld	a7,0(a5)
    80006f10:	9746                	add	a4,a4,a7
    80006f12:	40000613          	li	a2,1024
    80006f16:	c710                	sw	a2,8(a4)
  if(write)
    80006f18:	001b3613          	seqz	a2,s6
    80006f1c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006f20:	01066633          	or	a2,a2,a6
    80006f24:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006f28:	fa842583          	lw	a1,-88(s0)
    80006f2c:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006f30:	00250613          	addi	a2,a0,2
    80006f34:	0612                	slli	a2,a2,0x4
    80006f36:	963e                	add	a2,a2,a5
    80006f38:	577d                	li	a4,-1
    80006f3a:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006f3e:	0592                	slli	a1,a1,0x4
    80006f40:	98ae                	add	a7,a7,a1
    80006f42:	03068713          	addi	a4,a3,48
    80006f46:	973e                	add	a4,a4,a5
    80006f48:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006f4c:	6398                	ld	a4,0(a5)
    80006f4e:	972e                	add	a4,a4,a1
    80006f50:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006f54:	4689                	li	a3,2
    80006f56:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006f5a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006f5e:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80006f62:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006f66:	6794                	ld	a3,8(a5)
    80006f68:	0026d703          	lhu	a4,2(a3)
    80006f6c:	8b1d                	andi	a4,a4,7
    80006f6e:	0706                	slli	a4,a4,0x1
    80006f70:	96ba                	add	a3,a3,a4
    80006f72:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006f76:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006f7a:	6798                	ld	a4,8(a5)
    80006f7c:	00275783          	lhu	a5,2(a4)
    80006f80:	2785                	addiw	a5,a5,1
    80006f82:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006f86:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006f8a:	100017b7          	lui	a5,0x10001
    80006f8e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006f92:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006f96:	00244917          	auipc	s2,0x244
    80006f9a:	06a90913          	addi	s2,s2,106 # 8024b000 <disk+0x128>
  while(b->disk == 1) {
    80006f9e:	84c2                	mv	s1,a6
    80006fa0:	01079c63          	bne	a5,a6,80006fb8 <virtio_disk_rw+0x1c0>
    sleep(b, &disk.vdisk_lock);
    80006fa4:	85ca                	mv	a1,s2
    80006fa6:	854e                	mv	a0,s3
    80006fa8:	ffffc097          	auipc	ra,0xffffc
    80006fac:	994080e7          	jalr	-1644(ra) # 8000293c <sleep>
  while(b->disk == 1) {
    80006fb0:	0049a783          	lw	a5,4(s3)
    80006fb4:	fe9788e3          	beq	a5,s1,80006fa4 <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80006fb8:	fa042903          	lw	s2,-96(s0)
    80006fbc:	00290713          	addi	a4,s2,2
    80006fc0:	0712                	slli	a4,a4,0x4
    80006fc2:	00244797          	auipc	a5,0x244
    80006fc6:	f1678793          	addi	a5,a5,-234 # 8024aed8 <disk>
    80006fca:	97ba                	add	a5,a5,a4
    80006fcc:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006fd0:	00244997          	auipc	s3,0x244
    80006fd4:	f0898993          	addi	s3,s3,-248 # 8024aed8 <disk>
    80006fd8:	00491713          	slli	a4,s2,0x4
    80006fdc:	0009b783          	ld	a5,0(s3)
    80006fe0:	97ba                	add	a5,a5,a4
    80006fe2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006fe6:	854a                	mv	a0,s2
    80006fe8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006fec:	00000097          	auipc	ra,0x0
    80006ff0:	b8e080e7          	jalr	-1138(ra) # 80006b7a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006ff4:	8885                	andi	s1,s1,1
    80006ff6:	f0ed                	bnez	s1,80006fd8 <virtio_disk_rw+0x1e0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006ff8:	00244517          	auipc	a0,0x244
    80006ffc:	00850513          	addi	a0,a0,8 # 8024b000 <disk+0x128>
    80007000:	ffffa097          	auipc	ra,0xffffa
    80007004:	e60080e7          	jalr	-416(ra) # 80000e60 <release>
}
    80007008:	60e6                	ld	ra,88(sp)
    8000700a:	6446                	ld	s0,80(sp)
    8000700c:	64a6                	ld	s1,72(sp)
    8000700e:	6906                	ld	s2,64(sp)
    80007010:	79e2                	ld	s3,56(sp)
    80007012:	7a42                	ld	s4,48(sp)
    80007014:	7aa2                	ld	s5,40(sp)
    80007016:	7b02                	ld	s6,32(sp)
    80007018:	6be2                	ld	s7,24(sp)
    8000701a:	6c42                	ld	s8,16(sp)
    8000701c:	6125                	addi	sp,sp,96
    8000701e:	8082                	ret

0000000080007020 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80007020:	1101                	addi	sp,sp,-32
    80007022:	ec06                	sd	ra,24(sp)
    80007024:	e822                	sd	s0,16(sp)
    80007026:	e426                	sd	s1,8(sp)
    80007028:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000702a:	00244497          	auipc	s1,0x244
    8000702e:	eae48493          	addi	s1,s1,-338 # 8024aed8 <disk>
    80007032:	00244517          	auipc	a0,0x244
    80007036:	fce50513          	addi	a0,a0,-50 # 8024b000 <disk+0x128>
    8000703a:	ffffa097          	auipc	ra,0xffffa
    8000703e:	d76080e7          	jalr	-650(ra) # 80000db0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007042:	100017b7          	lui	a5,0x10001
    80007046:	53bc                	lw	a5,96(a5)
    80007048:	8b8d                	andi	a5,a5,3
    8000704a:	10001737          	lui	a4,0x10001
    8000704e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007050:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007054:	689c                	ld	a5,16(s1)
    80007056:	0204d703          	lhu	a4,32(s1)
    8000705a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000705e:	04f70863          	beq	a4,a5,800070ae <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80007062:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007066:	6898                	ld	a4,16(s1)
    80007068:	0204d783          	lhu	a5,32(s1)
    8000706c:	8b9d                	andi	a5,a5,7
    8000706e:	078e                	slli	a5,a5,0x3
    80007070:	97ba                	add	a5,a5,a4
    80007072:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007074:	00278713          	addi	a4,a5,2
    80007078:	0712                	slli	a4,a4,0x4
    8000707a:	9726                	add	a4,a4,s1
    8000707c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80007080:	e721                	bnez	a4,800070c8 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007082:	0789                	addi	a5,a5,2
    80007084:	0792                	slli	a5,a5,0x4
    80007086:	97a6                	add	a5,a5,s1
    80007088:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000708a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000708e:	ffffc097          	auipc	ra,0xffffc
    80007092:	912080e7          	jalr	-1774(ra) # 800029a0 <wakeup>

    disk.used_idx += 1;
    80007096:	0204d783          	lhu	a5,32(s1)
    8000709a:	2785                	addiw	a5,a5,1
    8000709c:	17c2                	slli	a5,a5,0x30
    8000709e:	93c1                	srli	a5,a5,0x30
    800070a0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800070a4:	6898                	ld	a4,16(s1)
    800070a6:	00275703          	lhu	a4,2(a4)
    800070aa:	faf71ce3          	bne	a4,a5,80007062 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    800070ae:	00244517          	auipc	a0,0x244
    800070b2:	f5250513          	addi	a0,a0,-174 # 8024b000 <disk+0x128>
    800070b6:	ffffa097          	auipc	ra,0xffffa
    800070ba:	daa080e7          	jalr	-598(ra) # 80000e60 <release>
}
    800070be:	60e2                	ld	ra,24(sp)
    800070c0:	6442                	ld	s0,16(sp)
    800070c2:	64a2                	ld	s1,8(sp)
    800070c4:	6105                	addi	sp,sp,32
    800070c6:	8082                	ret
      panic("virtio_disk_intr status");
    800070c8:	00002517          	auipc	a0,0x2
    800070cc:	6c850513          	addi	a0,a0,1736 # 80009790 <etext+0x790>
    800070d0:	ffff9097          	auipc	ra,0xffff9
    800070d4:	490080e7          	jalr	1168(ra) # 80000560 <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051073          	csrw	sscratch,a0
    80008004:	02000537          	lui	a0,0x2000
    80008008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000800a:	0536                	slli	a0,a0,0xd
    8000800c:	02153423          	sd	ra,40(a0)
    80008010:	02253823          	sd	sp,48(a0)
    80008014:	02353c23          	sd	gp,56(a0)
    80008018:	04453023          	sd	tp,64(a0)
    8000801c:	04553423          	sd	t0,72(a0)
    80008020:	04653823          	sd	t1,80(a0)
    80008024:	04753c23          	sd	t2,88(a0)
    80008028:	f120                	sd	s0,96(a0)
    8000802a:	f524                	sd	s1,104(a0)
    8000802c:	fd2c                	sd	a1,120(a0)
    8000802e:	e150                	sd	a2,128(a0)
    80008030:	e554                	sd	a3,136(a0)
    80008032:	e958                	sd	a4,144(a0)
    80008034:	ed5c                	sd	a5,152(a0)
    80008036:	0b053023          	sd	a6,160(a0)
    8000803a:	0b153423          	sd	a7,168(a0)
    8000803e:	0b253823          	sd	s2,176(a0)
    80008042:	0b353c23          	sd	s3,184(a0)
    80008046:	0d453023          	sd	s4,192(a0)
    8000804a:	0d553423          	sd	s5,200(a0)
    8000804e:	0d653823          	sd	s6,208(a0)
    80008052:	0d753c23          	sd	s7,216(a0)
    80008056:	0f853023          	sd	s8,224(a0)
    8000805a:	0f953423          	sd	s9,232(a0)
    8000805e:	0fa53823          	sd	s10,240(a0)
    80008062:	0fb53c23          	sd	s11,248(a0)
    80008066:	11c53023          	sd	t3,256(a0)
    8000806a:	11d53423          	sd	t4,264(a0)
    8000806e:	11e53823          	sd	t5,272(a0)
    80008072:	11f53c23          	sd	t6,280(a0)
    80008076:	140022f3          	csrr	t0,sscratch
    8000807a:	06553823          	sd	t0,112(a0)
    8000807e:	00853103          	ld	sp,8(a0)
    80008082:	02053203          	ld	tp,32(a0)
    80008086:	01053283          	ld	t0,16(a0)
    8000808a:	00053303          	ld	t1,0(a0)
    8000808e:	12000073          	sfence.vma
    80008092:	18031073          	csrw	satp,t1
    80008096:	12000073          	sfence.vma
    8000809a:	8282                	jr	t0

000000008000809c <userret>:
    8000809c:	12000073          	sfence.vma
    800080a0:	18051073          	csrw	satp,a0
    800080a4:	12000073          	sfence.vma
    800080a8:	02000537          	lui	a0,0x2000
    800080ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800080ae:	0536                	slli	a0,a0,0xd
    800080b0:	02853083          	ld	ra,40(a0)
    800080b4:	03053103          	ld	sp,48(a0)
    800080b8:	03853183          	ld	gp,56(a0)
    800080bc:	04053203          	ld	tp,64(a0)
    800080c0:	04853283          	ld	t0,72(a0)
    800080c4:	05053303          	ld	t1,80(a0)
    800080c8:	05853383          	ld	t2,88(a0)
    800080cc:	7120                	ld	s0,96(a0)
    800080ce:	7524                	ld	s1,104(a0)
    800080d0:	7d2c                	ld	a1,120(a0)
    800080d2:	6150                	ld	a2,128(a0)
    800080d4:	6554                	ld	a3,136(a0)
    800080d6:	6958                	ld	a4,144(a0)
    800080d8:	6d5c                	ld	a5,152(a0)
    800080da:	0a053803          	ld	a6,160(a0)
    800080de:	0a853883          	ld	a7,168(a0)
    800080e2:	0b053903          	ld	s2,176(a0)
    800080e6:	0b853983          	ld	s3,184(a0)
    800080ea:	0c053a03          	ld	s4,192(a0)
    800080ee:	0c853a83          	ld	s5,200(a0)
    800080f2:	0d053b03          	ld	s6,208(a0)
    800080f6:	0d853b83          	ld	s7,216(a0)
    800080fa:	0e053c03          	ld	s8,224(a0)
    800080fe:	0e853c83          	ld	s9,232(a0)
    80008102:	0f053d03          	ld	s10,240(a0)
    80008106:	0f853d83          	ld	s11,248(a0)
    8000810a:	10053e03          	ld	t3,256(a0)
    8000810e:	10853e83          	ld	t4,264(a0)
    80008112:	11053f03          	ld	t5,272(a0)
    80008116:	11853f83          	ld	t6,280(a0)
    8000811a:	7928                	ld	a0,112(a0)
    8000811c:	10200073          	sret
	...
