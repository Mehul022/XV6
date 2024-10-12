
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ae010113          	addi	sp,sp,-1312 # 80008ae0 <stack0>
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
    80000050:	00009797          	auipc	a5,0x9
    80000054:	95078793          	addi	a5,a5,-1712 # 800089a0 <timer_scratch>
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
    80000062:	00006797          	auipc	a5,0x6
    80000066:	56e78793          	addi	a5,a5,1390 # 800065d0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd47df>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e4278793          	addi	a5,a5,-446 # 80000ef0 <main>
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
    80000138:	8a6080e7          	jalr	-1882(ra) # 800029da <either_copyin>
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
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	94450513          	addi	a0,a0,-1724 # 80010ae0 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	a9a080e7          	jalr	-1382(ra) # 80000c3e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	93448493          	addi	s1,s1,-1740 # 80010ae0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011917          	auipc	s2,0x11
    800001b8:	9c490913          	addi	s2,s2,-1596 # 80010b78 <cons+0x98>
  while(n > 0){
    800001bc:	0d305563          	blez	s3,80000286 <consoleread+0x106>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	0af71a63          	bne	a4,a5,8000027c <consoleread+0xfc>
      if(killed(myproc())){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	8e4080e7          	jalr	-1820(ra) # 80001ab0 <myproc>
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	634080e7          	jalr	1588(ra) # 80002808 <killed>
    800001dc:	e52d                	bnez	a0,80000246 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	372080e7          	jalr	882(ra) # 80002554 <sleep>
    while(cons.r == cons.w){
    800001ea:	0984a783          	lw	a5,152(s1)
    800001ee:	09c4a703          	lw	a4,156(s1)
    800001f2:	fcf70de3          	beq	a4,a5,800001cc <consoleread+0x4c>
    800001f6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f8:	00011717          	auipc	a4,0x11
    800001fc:	8e870713          	addi	a4,a4,-1816 # 80010ae0 <cons>
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
    8000022a:	00002097          	auipc	ra,0x2
    8000022e:	758080e7          	jalr	1880(ra) # 80002982 <either_copyout>
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
    80000246:	00011517          	auipc	a0,0x11
    8000024a:	89a50513          	addi	a0,a0,-1894 # 80010ae0 <cons>
    8000024e:	00001097          	auipc	ra,0x1
    80000252:	aa0080e7          	jalr	-1376(ra) # 80000cee <release>
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
    80000270:	00011717          	auipc	a4,0x11
    80000274:	90f72423          	sw	a5,-1784(a4) # 80010b78 <cons+0x98>
    80000278:	6be2                	ld	s7,24(sp)
    8000027a:	a031                	j	80000286 <consoleread+0x106>
    8000027c:	ec5e                	sd	s7,24(sp)
    8000027e:	bfad                	j	800001f8 <consoleread+0x78>
    80000280:	6be2                	ld	s7,24(sp)
    80000282:	a011                	j	80000286 <consoleread+0x106>
    80000284:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000286:	00011517          	auipc	a0,0x11
    8000028a:	85a50513          	addi	a0,a0,-1958 # 80010ae0 <cons>
    8000028e:	00001097          	auipc	ra,0x1
    80000292:	a60080e7          	jalr	-1440(ra) # 80000cee <release>
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
    800002ee:	00010517          	auipc	a0,0x10
    800002f2:	7f250513          	addi	a0,a0,2034 # 80010ae0 <cons>
    800002f6:	00001097          	auipc	ra,0x1
    800002fa:	948080e7          	jalr	-1720(ra) # 80000c3e <acquire>

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
    80000314:	00002097          	auipc	ra,0x2
    80000318:	71e080e7          	jalr	1822(ra) # 80002a32 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031c:	00010517          	auipc	a0,0x10
    80000320:	7c450513          	addi	a0,a0,1988 # 80010ae0 <cons>
    80000324:	00001097          	auipc	ra,0x1
    80000328:	9ca080e7          	jalr	-1590(ra) # 80000cee <release>
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
    8000033e:	00010717          	auipc	a4,0x10
    80000342:	7a270713          	addi	a4,a4,1954 # 80010ae0 <cons>
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
    80000368:	00010797          	auipc	a5,0x10
    8000036c:	77878793          	addi	a5,a5,1912 # 80010ae0 <cons>
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
    80000394:	00010797          	auipc	a5,0x10
    80000398:	7e47a783          	lw	a5,2020(a5) # 80010b78 <cons+0x98>
    8000039c:	9f1d                	subw	a4,a4,a5
    8000039e:	08000793          	li	a5,128
    800003a2:	f6f71de3          	bne	a4,a5,8000031c <consoleintr+0x3a>
    800003a6:	a0c9                	j	80000468 <consoleintr+0x186>
    800003a8:	e84a                	sd	s2,16(sp)
    800003aa:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    800003ac:	00010717          	auipc	a4,0x10
    800003b0:	73470713          	addi	a4,a4,1844 # 80010ae0 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	00010497          	auipc	s1,0x10
    800003c0:	72448493          	addi	s1,s1,1828 # 80010ae0 <cons>
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
    8000040a:	00010717          	auipc	a4,0x10
    8000040e:	6d670713          	addi	a4,a4,1750 # 80010ae0 <cons>
    80000412:	0a072783          	lw	a5,160(a4)
    80000416:	09c72703          	lw	a4,156(a4)
    8000041a:	f0f701e3          	beq	a4,a5,8000031c <consoleintr+0x3a>
      cons.e--;
    8000041e:	37fd                	addiw	a5,a5,-1
    80000420:	00010717          	auipc	a4,0x10
    80000424:	76f72023          	sw	a5,1888(a4) # 80010b80 <cons+0xa0>
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
    80000446:	00010797          	auipc	a5,0x10
    8000044a:	69a78793          	addi	a5,a5,1690 # 80010ae0 <cons>
    8000044e:	0a07a703          	lw	a4,160(a5)
    80000452:	0017069b          	addiw	a3,a4,1
    80000456:	8636                	mv	a2,a3
    80000458:	0ad7a023          	sw	a3,160(a5)
    8000045c:	07f77713          	andi	a4,a4,127
    80000460:	97ba                	add	a5,a5,a4
    80000462:	4729                	li	a4,10
    80000464:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000468:	00010797          	auipc	a5,0x10
    8000046c:	70c7aa23          	sw	a2,1812(a5) # 80010b7c <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00010517          	auipc	a0,0x10
    80000474:	70850513          	addi	a0,a0,1800 # 80010b78 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	140080e7          	jalr	320(ra) # 800025b8 <wakeup>
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
    8000048a:	00008597          	auipc	a1,0x8
    8000048e:	b7658593          	addi	a1,a1,-1162 # 80008000 <etext>
    80000492:	00010517          	auipc	a0,0x10
    80000496:	64e50513          	addi	a0,a0,1614 # 80010ae0 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	710080e7          	jalr	1808(ra) # 80000baa <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	344080e7          	jalr	836(ra) # 800007e6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00029797          	auipc	a5,0x29
    800004ae:	9de78793          	addi	a5,a5,-1570 # 80028e88 <devsw>
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
    800004ea:	00008817          	auipc	a6,0x8
    800004ee:	2d680813          	addi	a6,a6,726 # 800087c0 <digits>
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
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	6207aa23          	sw	zero,1588(a5) # 80010ba0 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	3cf72023          	sw	a5,960(a4) # 80008960 <panicked>
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
    800005ca:	00010d97          	auipc	s11,0x10
    800005ce:	5d6dad83          	lw	s11,1494(s11) # 80010ba0 <pr+0x18>
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
    8000060c:	00008a97          	auipc	s5,0x8
    80000610:	1b4a8a93          	addi	s5,s5,436 # 800087c0 <digits>
    switch(c){
    80000614:	07300c13          	li	s8,115
    80000618:	a0b9                	j	80000666 <printf+0xbc>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	56e50513          	addi	a0,a0,1390 # 80010b88 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	61c080e7          	jalr	1564(ra) # 80000c3e <acquire>
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
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
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
    8000073c:	00008497          	auipc	s1,0x8
    80000740:	8dc48493          	addi	s1,s1,-1828 # 80008018 <etext+0x18>
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
    800007a2:	00010517          	auipc	a0,0x10
    800007a6:	3e650513          	addi	a0,a0,998 # 80010b88 <pr>
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	544080e7          	jalr	1348(ra) # 80000cee <release>
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
    800007be:	00010497          	auipc	s1,0x10
    800007c2:	3ca48493          	addi	s1,s1,970 # 80010b88 <pr>
    800007c6:	00008597          	auipc	a1,0x8
    800007ca:	86a58593          	addi	a1,a1,-1942 # 80008030 <etext+0x30>
    800007ce:	8526                	mv	a0,s1
    800007d0:	00000097          	auipc	ra,0x0
    800007d4:	3da080e7          	jalr	986(ra) # 80000baa <initlock>
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
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	38050513          	addi	a0,a0,896 # 80010ba8 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	37a080e7          	jalr	890(ra) # 80000baa <initlock>
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
    80000850:	3a6080e7          	jalr	934(ra) # 80000bf2 <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	10c7a783          	lw	a5,268(a5) # 80008960 <panicked>
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
    8000087e:	418080e7          	jalr	1048(ra) # 80000c92 <pop_off>
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
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	0da7b783          	ld	a5,218(a5) # 80008968 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	0da73703          	ld	a4,218(a4) # 80008970 <uart_tx_w>
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
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	2eca8a93          	addi	s5,s5,748 # 80010ba8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	0a448493          	addi	s1,s1,164 # 80008968 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	0a098993          	addi	s3,s3,160 # 80008970 <uart_tx_w>
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
    800008f6:	cc6080e7          	jalr	-826(ra) # 800025b8 <wakeup>
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
    80000930:	00010517          	auipc	a0,0x10
    80000934:	27850513          	addi	a0,a0,632 # 80010ba8 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	306080e7          	jalr	774(ra) # 80000c3e <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	0207a783          	lw	a5,32(a5) # 80008960 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	02673703          	ld	a4,38(a4) # 80008970 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	0167b783          	ld	a5,22(a5) # 80008968 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	24a98993          	addi	s3,s3,586 # 80010ba8 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	00248493          	addi	s1,s1,2 # 80008968 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	00290913          	addi	s2,s2,2 # 80008970 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	bd6080e7          	jalr	-1066(ra) # 80002554 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	21448493          	addi	s1,s1,532 # 80010ba8 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	fce7b423          	sd	a4,-56(a5) # 80008970 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	334080e7          	jalr	820(ra) # 80000cee <release>
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
    80000a1e:	00010497          	auipc	s1,0x10
    80000a22:	18a48493          	addi	s1,s1,394 # 80010ba8 <uart_tx_lock>
    80000a26:	8526                	mv	a0,s1
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	216080e7          	jalr	534(ra) # 80000c3e <acquire>
  uartstart();
    80000a30:	00000097          	auipc	ra,0x0
    80000a34:	e5e080e7          	jalr	-418(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	2b4080e7          	jalr	692(ra) # 80000cee <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret

0000000080000a4c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	e04a                	sd	s2,0(sp)
    80000a56:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a58:	03451793          	slli	a5,a0,0x34
    80000a5c:	ebb9                	bnez	a5,80000ab2 <kfree+0x66>
    80000a5e:	84aa                	mv	s1,a0
    80000a60:	00029797          	auipc	a5,0x29
    80000a64:	5c078793          	addi	a5,a5,1472 # 8002a020 <end>
    80000a68:	04f56563          	bltu	a0,a5,80000ab2 <kfree+0x66>
    80000a6c:	47c5                	li	a5,17
    80000a6e:	07ee                	slli	a5,a5,0x1b
    80000a70:	04f57163          	bgeu	a0,a5,80000ab2 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a74:	6605                	lui	a2,0x1
    80000a76:	4585                	li	a1,1
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	2be080e7          	jalr	702(ra) # 80000d36 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a80:	00010917          	auipc	s2,0x10
    80000a84:	16090913          	addi	s2,s2,352 # 80010be0 <kmem>
    80000a88:	854a                	mv	a0,s2
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	1b4080e7          	jalr	436(ra) # 80000c3e <acquire>
  r->next = kmem.freelist;
    80000a92:	01893783          	ld	a5,24(s2)
    80000a96:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a98:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9c:	854a                	mv	a0,s2
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	250080e7          	jalr	592(ra) # 80000cee <release>
}
    80000aa6:	60e2                	ld	ra,24(sp)
    80000aa8:	6442                	ld	s0,16(sp)
    80000aaa:	64a2                	ld	s1,8(sp)
    80000aac:	6902                	ld	s2,0(sp)
    80000aae:	6105                	addi	sp,sp,32
    80000ab0:	8082                	ret
    panic("kfree");
    80000ab2:	00007517          	auipc	a0,0x7
    80000ab6:	58e50513          	addi	a0,a0,1422 # 80008040 <etext+0x40>
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	aa6080e7          	jalr	-1370(ra) # 80000560 <panic>

0000000080000ac2 <freerange>:
{
    80000ac2:	7179                	addi	sp,sp,-48
    80000ac4:	f406                	sd	ra,40(sp)
    80000ac6:	f022                	sd	s0,32(sp)
    80000ac8:	ec26                	sd	s1,24(sp)
    80000aca:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000acc:	6785                	lui	a5,0x1
    80000ace:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad2:	00e504b3          	add	s1,a0,a4
    80000ad6:	777d                	lui	a4,0xfffff
    80000ad8:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94be                	add	s1,s1,a5
    80000adc:	0295e463          	bltu	a1,s1,80000b04 <freerange+0x42>
    80000ae0:	e84a                	sd	s2,16(sp)
    80000ae2:	e44e                	sd	s3,8(sp)
    80000ae4:	e052                	sd	s4,0(sp)
    80000ae6:	892e                	mv	s2,a1
    kfree(p);
    80000ae8:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aea:	89be                	mv	s3,a5
    kfree(p);
    80000aec:	01448533          	add	a0,s1,s4
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	f5c080e7          	jalr	-164(ra) # 80000a4c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	94ce                	add	s1,s1,s3
    80000afa:	fe9979e3          	bgeu	s2,s1,80000aec <freerange+0x2a>
    80000afe:	6942                	ld	s2,16(sp)
    80000b00:	69a2                	ld	s3,8(sp)
    80000b02:	6a02                	ld	s4,0(sp)
}
    80000b04:	70a2                	ld	ra,40(sp)
    80000b06:	7402                	ld	s0,32(sp)
    80000b08:	64e2                	ld	s1,24(sp)
    80000b0a:	6145                	addi	sp,sp,48
    80000b0c:	8082                	ret

0000000080000b0e <kinit>:
{
    80000b0e:	1141                	addi	sp,sp,-16
    80000b10:	e406                	sd	ra,8(sp)
    80000b12:	e022                	sd	s0,0(sp)
    80000b14:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b16:	00007597          	auipc	a1,0x7
    80000b1a:	53258593          	addi	a1,a1,1330 # 80008048 <etext+0x48>
    80000b1e:	00010517          	auipc	a0,0x10
    80000b22:	0c250513          	addi	a0,a0,194 # 80010be0 <kmem>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	084080e7          	jalr	132(ra) # 80000baa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2e:	45c5                	li	a1,17
    80000b30:	05ee                	slli	a1,a1,0x1b
    80000b32:	00029517          	auipc	a0,0x29
    80000b36:	4ee50513          	addi	a0,a0,1262 # 8002a020 <end>
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	f88080e7          	jalr	-120(ra) # 80000ac2 <freerange>
}
    80000b42:	60a2                	ld	ra,8(sp)
    80000b44:	6402                	ld	s0,0(sp)
    80000b46:	0141                	addi	sp,sp,16
    80000b48:	8082                	ret

0000000080000b4a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b4a:	1101                	addi	sp,sp,-32
    80000b4c:	ec06                	sd	ra,24(sp)
    80000b4e:	e822                	sd	s0,16(sp)
    80000b50:	e426                	sd	s1,8(sp)
    80000b52:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b54:	00010497          	auipc	s1,0x10
    80000b58:	08c48493          	addi	s1,s1,140 # 80010be0 <kmem>
    80000b5c:	8526                	mv	a0,s1
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	0e0080e7          	jalr	224(ra) # 80000c3e <acquire>
  r = kmem.freelist;
    80000b66:	6c84                	ld	s1,24(s1)
  if(r)
    80000b68:	c885                	beqz	s1,80000b98 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b6a:	609c                	ld	a5,0(s1)
    80000b6c:	00010517          	auipc	a0,0x10
    80000b70:	07450513          	addi	a0,a0,116 # 80010be0 <kmem>
    80000b74:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	178080e7          	jalr	376(ra) # 80000cee <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7e:	6605                	lui	a2,0x1
    80000b80:	4595                	li	a1,5
    80000b82:	8526                	mv	a0,s1
    80000b84:	00000097          	auipc	ra,0x0
    80000b88:	1b2080e7          	jalr	434(ra) # 80000d36 <memset>
  return (void*)r;
}
    80000b8c:	8526                	mv	a0,s1
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret
  release(&kmem.lock);
    80000b98:	00010517          	auipc	a0,0x10
    80000b9c:	04850513          	addi	a0,a0,72 # 80010be0 <kmem>
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	14e080e7          	jalr	334(ra) # 80000cee <release>
  if(r)
    80000ba8:	b7d5                	j	80000b8c <kalloc+0x42>

0000000080000baa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000baa:	1141                	addi	sp,sp,-16
    80000bac:	e406                	sd	ra,8(sp)
    80000bae:	e022                	sd	s0,0(sp)
    80000bb0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bb2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb8:	00053823          	sd	zero,16(a0)
}
    80000bbc:	60a2                	ld	ra,8(sp)
    80000bbe:	6402                	ld	s0,0(sp)
    80000bc0:	0141                	addi	sp,sp,16
    80000bc2:	8082                	ret

0000000080000bc4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bc4:	411c                	lw	a5,0(a0)
    80000bc6:	e399                	bnez	a5,80000bcc <holding+0x8>
    80000bc8:	4501                	li	a0,0
  return r;
}
    80000bca:	8082                	ret
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd6:	6904                	ld	s1,16(a0)
    80000bd8:	00001097          	auipc	ra,0x1
    80000bdc:	eb8080e7          	jalr	-328(ra) # 80001a90 <mycpu>
    80000be0:	40a48533          	sub	a0,s1,a0
    80000be4:	00153513          	seqz	a0,a0
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret

0000000080000bf2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bf2:	1101                	addi	sp,sp,-32
    80000bf4:	ec06                	sd	ra,24(sp)
    80000bf6:	e822                	sd	s0,16(sp)
    80000bf8:	e426                	sd	s1,8(sp)
    80000bfa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bfc:	100024f3          	csrr	s1,sstatus
    80000c00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c06:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	e86080e7          	jalr	-378(ra) # 80001a90 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	cf89                	beqz	a5,80000c2e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c16:	00001097          	auipc	ra,0x1
    80000c1a:	e7a080e7          	jalr	-390(ra) # 80001a90 <mycpu>
    80000c1e:	5d3c                	lw	a5,120(a0)
    80000c20:	2785                	addiw	a5,a5,1
    80000c22:	dd3c                	sw	a5,120(a0)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    mycpu()->intena = old;
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	e62080e7          	jalr	-414(ra) # 80001a90 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c36:	8085                	srli	s1,s1,0x1
    80000c38:	8885                	andi	s1,s1,1
    80000c3a:	dd64                	sw	s1,124(a0)
    80000c3c:	bfe9                	j	80000c16 <push_off+0x24>

0000000080000c3e <acquire>:
{
    80000c3e:	1101                	addi	sp,sp,-32
    80000c40:	ec06                	sd	ra,24(sp)
    80000c42:	e822                	sd	s0,16(sp)
    80000c44:	e426                	sd	s1,8(sp)
    80000c46:	1000                	addi	s0,sp,32
    80000c48:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	fa8080e7          	jalr	-88(ra) # 80000bf2 <push_off>
  if(holding(lk))
    80000c52:	8526                	mv	a0,s1
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	f70080e7          	jalr	-144(ra) # 80000bc4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5c:	4705                	li	a4,1
  if(holding(lk))
    80000c5e:	e115                	bnez	a0,80000c82 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c60:	87ba                	mv	a5,a4
    80000c62:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c66:	2781                	sext.w	a5,a5
    80000c68:	ffe5                	bnez	a5,80000c60 <acquire+0x22>
  __sync_synchronize();
    80000c6a:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c6e:	00001097          	auipc	ra,0x1
    80000c72:	e22080e7          	jalr	-478(ra) # 80001a90 <mycpu>
    80000c76:	e888                	sd	a0,16(s1)
}
    80000c78:	60e2                	ld	ra,24(sp)
    80000c7a:	6442                	ld	s0,16(sp)
    80000c7c:	64a2                	ld	s1,8(sp)
    80000c7e:	6105                	addi	sp,sp,32
    80000c80:	8082                	ret
    panic("acquire");
    80000c82:	00007517          	auipc	a0,0x7
    80000c86:	3ce50513          	addi	a0,a0,974 # 80008050 <etext+0x50>
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	8d6080e7          	jalr	-1834(ra) # 80000560 <panic>

0000000080000c92 <pop_off>:

void
pop_off(void)
{
    80000c92:	1141                	addi	sp,sp,-16
    80000c94:	e406                	sd	ra,8(sp)
    80000c96:	e022                	sd	s0,0(sp)
    80000c98:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c9a:	00001097          	auipc	ra,0x1
    80000c9e:	df6080e7          	jalr	-522(ra) # 80001a90 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ca2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca6:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca8:	e39d                	bnez	a5,80000cce <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000caa:	5d3c                	lw	a5,120(a0)
    80000cac:	02f05963          	blez	a5,80000cde <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cb0:	37fd                	addiw	a5,a5,-1
    80000cb2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb4:	eb89                	bnez	a5,80000cc6 <pop_off+0x34>
    80000cb6:	5d7c                	lw	a5,124(a0)
    80000cb8:	c799                	beqz	a5,80000cc6 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc6:	60a2                	ld	ra,8(sp)
    80000cc8:	6402                	ld	s0,0(sp)
    80000cca:	0141                	addi	sp,sp,16
    80000ccc:	8082                	ret
    panic("pop_off - interruptible");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	38a50513          	addi	a0,a0,906 # 80008058 <etext+0x58>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	88a080e7          	jalr	-1910(ra) # 80000560 <panic>
    panic("pop_off");
    80000cde:	00007517          	auipc	a0,0x7
    80000ce2:	39250513          	addi	a0,a0,914 # 80008070 <etext+0x70>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	87a080e7          	jalr	-1926(ra) # 80000560 <panic>

0000000080000cee <release>:
{
    80000cee:	1101                	addi	sp,sp,-32
    80000cf0:	ec06                	sd	ra,24(sp)
    80000cf2:	e822                	sd	s0,16(sp)
    80000cf4:	e426                	sd	s1,8(sp)
    80000cf6:	1000                	addi	s0,sp,32
    80000cf8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	eca080e7          	jalr	-310(ra) # 80000bc4 <holding>
    80000d02:	c115                	beqz	a0,80000d26 <release+0x38>
  lk->cpu = 0;
    80000d04:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d08:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d0c:	0310000f          	fence	rw,w
    80000d10:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d14:	00000097          	auipc	ra,0x0
    80000d18:	f7e080e7          	jalr	-130(ra) # 80000c92 <pop_off>
}
    80000d1c:	60e2                	ld	ra,24(sp)
    80000d1e:	6442                	ld	s0,16(sp)
    80000d20:	64a2                	ld	s1,8(sp)
    80000d22:	6105                	addi	sp,sp,32
    80000d24:	8082                	ret
    panic("release");
    80000d26:	00007517          	auipc	a0,0x7
    80000d2a:	35250513          	addi	a0,a0,850 # 80008078 <etext+0x78>
    80000d2e:	00000097          	auipc	ra,0x0
    80000d32:	832080e7          	jalr	-1998(ra) # 80000560 <panic>

0000000080000d36 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d36:	1141                	addi	sp,sp,-16
    80000d38:	e406                	sd	ra,8(sp)
    80000d3a:	e022                	sd	s0,0(sp)
    80000d3c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3e:	ca19                	beqz	a2,80000d54 <memset+0x1e>
    80000d40:	87aa                	mv	a5,a0
    80000d42:	1602                	slli	a2,a2,0x20
    80000d44:	9201                	srli	a2,a2,0x20
    80000d46:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d4a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4e:	0785                	addi	a5,a5,1
    80000d50:	fee79de3          	bne	a5,a4,80000d4a <memset+0x14>
  }
  return dst;
}
    80000d54:	60a2                	ld	ra,8(sp)
    80000d56:	6402                	ld	s0,0(sp)
    80000d58:	0141                	addi	sp,sp,16
    80000d5a:	8082                	ret

0000000080000d5c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d5c:	1141                	addi	sp,sp,-16
    80000d5e:	e406                	sd	ra,8(sp)
    80000d60:	e022                	sd	s0,0(sp)
    80000d62:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d64:	ca0d                	beqz	a2,80000d96 <memcmp+0x3a>
    80000d66:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d6a:	1682                	slli	a3,a3,0x20
    80000d6c:	9281                	srli	a3,a3,0x20
    80000d6e:	0685                	addi	a3,a3,1
    80000d70:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d72:	00054783          	lbu	a5,0(a0)
    80000d76:	0005c703          	lbu	a4,0(a1)
    80000d7a:	00e79863          	bne	a5,a4,80000d8a <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d7e:	0505                	addi	a0,a0,1
    80000d80:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d82:	fed518e3          	bne	a0,a3,80000d72 <memcmp+0x16>
  }

  return 0;
    80000d86:	4501                	li	a0,0
    80000d88:	a019                	j	80000d8e <memcmp+0x32>
      return *s1 - *s2;
    80000d8a:	40e7853b          	subw	a0,a5,a4
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret
  return 0;
    80000d96:	4501                	li	a0,0
    80000d98:	bfdd                	j	80000d8e <memcmp+0x32>

0000000080000d9a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e406                	sd	ra,8(sp)
    80000d9e:	e022                	sd	s0,0(sp)
    80000da0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000da2:	c205                	beqz	a2,80000dc2 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da4:	02a5e363          	bltu	a1,a0,80000dca <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000da8:	1602                	slli	a2,a2,0x20
    80000daa:	9201                	srli	a2,a2,0x20
    80000dac:	00c587b3          	add	a5,a1,a2
{
    80000db0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000db2:	0585                	addi	a1,a1,1
    80000db4:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd4fe1>
    80000db6:	fff5c683          	lbu	a3,-1(a1)
    80000dba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dbe:	feb79ae3          	bne	a5,a1,80000db2 <memmove+0x18>

  return dst;
}
    80000dc2:	60a2                	ld	ra,8(sp)
    80000dc4:	6402                	ld	s0,0(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret
  if(s < d && s + n > d){
    80000dca:	02061693          	slli	a3,a2,0x20
    80000dce:	9281                	srli	a3,a3,0x20
    80000dd0:	00d58733          	add	a4,a1,a3
    80000dd4:	fce57ae3          	bgeu	a0,a4,80000da8 <memmove+0xe>
    d += n;
    80000dd8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dda:	fff6079b          	addiw	a5,a2,-1
    80000dde:	1782                	slli	a5,a5,0x20
    80000de0:	9381                	srli	a5,a5,0x20
    80000de2:	fff7c793          	not	a5,a5
    80000de6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000de8:	177d                	addi	a4,a4,-1
    80000dea:	16fd                	addi	a3,a3,-1
    80000dec:	00074603          	lbu	a2,0(a4)
    80000df0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000df4:	fee79ae3          	bne	a5,a4,80000de8 <memmove+0x4e>
    80000df8:	b7e9                	j	80000dc2 <memmove+0x28>

0000000080000dfa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e406                	sd	ra,8(sp)
    80000dfe:	e022                	sd	s0,0(sp)
    80000e00:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e02:	00000097          	auipc	ra,0x0
    80000e06:	f98080e7          	jalr	-104(ra) # 80000d9a <memmove>
}
    80000e0a:	60a2                	ld	ra,8(sp)
    80000e0c:	6402                	ld	s0,0(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e406                	sd	ra,8(sp)
    80000e16:	e022                	sd	s0,0(sp)
    80000e18:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e1a:	ce11                	beqz	a2,80000e36 <strncmp+0x24>
    80000e1c:	00054783          	lbu	a5,0(a0)
    80000e20:	cf89                	beqz	a5,80000e3a <strncmp+0x28>
    80000e22:	0005c703          	lbu	a4,0(a1)
    80000e26:	00f71a63          	bne	a4,a5,80000e3a <strncmp+0x28>
    n--, p++, q++;
    80000e2a:	367d                	addiw	a2,a2,-1
    80000e2c:	0505                	addi	a0,a0,1
    80000e2e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e30:	f675                	bnez	a2,80000e1c <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e32:	4501                	li	a0,0
    80000e34:	a801                	j	80000e44 <strncmp+0x32>
    80000e36:	4501                	li	a0,0
    80000e38:	a031                	j	80000e44 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e3a:	00054503          	lbu	a0,0(a0)
    80000e3e:	0005c783          	lbu	a5,0(a1)
    80000e42:	9d1d                	subw	a0,a0,a5
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e54:	87aa                	mv	a5,a0
    80000e56:	86b2                	mv	a3,a2
    80000e58:	367d                	addiw	a2,a2,-1
    80000e5a:	02d05563          	blez	a3,80000e84 <strncpy+0x38>
    80000e5e:	0785                	addi	a5,a5,1
    80000e60:	0005c703          	lbu	a4,0(a1)
    80000e64:	fee78fa3          	sb	a4,-1(a5)
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	f775                	bnez	a4,80000e56 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e6c:	873e                	mv	a4,a5
    80000e6e:	00c05b63          	blez	a2,80000e84 <strncpy+0x38>
    80000e72:	9fb5                	addw	a5,a5,a3
    80000e74:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e76:	0705                	addi	a4,a4,1
    80000e78:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e7c:	40e786bb          	subw	a3,a5,a4
    80000e80:	fed04be3          	bgtz	a3,80000e76 <strncpy+0x2a>
  return os;
}
    80000e84:	60a2                	ld	ra,8(sp)
    80000e86:	6402                	ld	s0,0(sp)
    80000e88:	0141                	addi	sp,sp,16
    80000e8a:	8082                	ret

0000000080000e8c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e406                	sd	ra,8(sp)
    80000e90:	e022                	sd	s0,0(sp)
    80000e92:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e94:	02c05363          	blez	a2,80000eba <safestrcpy+0x2e>
    80000e98:	fff6069b          	addiw	a3,a2,-1
    80000e9c:	1682                	slli	a3,a3,0x20
    80000e9e:	9281                	srli	a3,a3,0x20
    80000ea0:	96ae                	add	a3,a3,a1
    80000ea2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ea4:	00d58963          	beq	a1,a3,80000eb6 <safestrcpy+0x2a>
    80000ea8:	0585                	addi	a1,a1,1
    80000eaa:	0785                	addi	a5,a5,1
    80000eac:	fff5c703          	lbu	a4,-1(a1)
    80000eb0:	fee78fa3          	sb	a4,-1(a5)
    80000eb4:	fb65                	bnez	a4,80000ea4 <safestrcpy+0x18>
    ;
  *s = 0;
    80000eb6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eba:	60a2                	ld	ra,8(sp)
    80000ebc:	6402                	ld	s0,0(sp)
    80000ebe:	0141                	addi	sp,sp,16
    80000ec0:	8082                	ret

0000000080000ec2 <strlen>:

int
strlen(const char *s)
{
    80000ec2:	1141                	addi	sp,sp,-16
    80000ec4:	e406                	sd	ra,8(sp)
    80000ec6:	e022                	sd	s0,0(sp)
    80000ec8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eca:	00054783          	lbu	a5,0(a0)
    80000ece:	cf99                	beqz	a5,80000eec <strlen+0x2a>
    80000ed0:	0505                	addi	a0,a0,1
    80000ed2:	87aa                	mv	a5,a0
    80000ed4:	86be                	mv	a3,a5
    80000ed6:	0785                	addi	a5,a5,1
    80000ed8:	fff7c703          	lbu	a4,-1(a5)
    80000edc:	ff65                	bnez	a4,80000ed4 <strlen+0x12>
    80000ede:	40a6853b          	subw	a0,a3,a0
    80000ee2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ee4:	60a2                	ld	ra,8(sp)
    80000ee6:	6402                	ld	s0,0(sp)
    80000ee8:	0141                	addi	sp,sp,16
    80000eea:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eec:	4501                	li	a0,0
    80000eee:	bfdd                	j	80000ee4 <strlen+0x22>

0000000080000ef0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef0:	1141                	addi	sp,sp,-16
    80000ef2:	e406                	sd	ra,8(sp)
    80000ef4:	e022                	sd	s0,0(sp)
    80000ef6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ef8:	00001097          	auipc	ra,0x1
    80000efc:	b84080e7          	jalr	-1148(ra) # 80001a7c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f00:	00008717          	auipc	a4,0x8
    80000f04:	a7870713          	addi	a4,a4,-1416 # 80008978 <started>
  if(cpuid() == 0){
    80000f08:	c139                	beqz	a0,80000f4e <main+0x5e>
    while(started == 0)
    80000f0a:	431c                	lw	a5,0(a4)
    80000f0c:	2781                	sext.w	a5,a5
    80000f0e:	dff5                	beqz	a5,80000f0a <main+0x1a>
      ;
    __sync_synchronize();
    80000f10:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	b68080e7          	jalr	-1176(ra) # 80001a7c <cpuid>
    80000f1c:	85aa                	mv	a1,a0
    80000f1e:	00007517          	auipc	a0,0x7
    80000f22:	17a50513          	addi	a0,a0,378 # 80008098 <etext+0x98>
    80000f26:	fffff097          	auipc	ra,0xfffff
    80000f2a:	684080e7          	jalr	1668(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	0d8080e7          	jalr	216(ra) # 80001006 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	de2080e7          	jalr	-542(ra) # 80002d18 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	6d6080e7          	jalr	1750(ra) # 80006614 <plicinithart>
  }

  scheduler();        
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	4ec080e7          	jalr	1260(ra) # 80002432 <scheduler>
    consoleinit();
    80000f4e:	fffff097          	auipc	ra,0xfffff
    80000f52:	534080e7          	jalr	1332(ra) # 80000482 <consoleinit>
    printfinit();
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	85e080e7          	jalr	-1954(ra) # 800007b4 <printfinit>
    printf("\n");
    80000f5e:	00007517          	auipc	a0,0x7
    80000f62:	0b250513          	addi	a0,a0,178 # 80008010 <etext+0x10>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	644080e7          	jalr	1604(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	11250513          	addi	a0,a0,274 # 80008080 <etext+0x80>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	634080e7          	jalr	1588(ra) # 800005aa <printf>
    printf("\n");
    80000f7e:	00007517          	auipc	a0,0x7
    80000f82:	09250513          	addi	a0,a0,146 # 80008010 <etext+0x10>
    80000f86:	fffff097          	auipc	ra,0xfffff
    80000f8a:	624080e7          	jalr	1572(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f8e:	00000097          	auipc	ra,0x0
    80000f92:	b80080e7          	jalr	-1152(ra) # 80000b0e <kinit>
    kvminit();       // create kernel page table
    80000f96:	00000097          	auipc	ra,0x0
    80000f9a:	32a080e7          	jalr	810(ra) # 800012c0 <kvminit>
    kvminithart();   // turn on paging
    80000f9e:	00000097          	auipc	ra,0x0
    80000fa2:	068080e7          	jalr	104(ra) # 80001006 <kvminithart>
    procinit();      // process table
    80000fa6:	00001097          	auipc	ra,0x1
    80000faa:	a18080e7          	jalr	-1512(ra) # 800019be <procinit>
    trapinit();      // trap vectors
    80000fae:	00002097          	auipc	ra,0x2
    80000fb2:	d42080e7          	jalr	-702(ra) # 80002cf0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb6:	00002097          	auipc	ra,0x2
    80000fba:	d62080e7          	jalr	-670(ra) # 80002d18 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fbe:	00005097          	auipc	ra,0x5
    80000fc2:	63c080e7          	jalr	1596(ra) # 800065fa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc6:	00005097          	auipc	ra,0x5
    80000fca:	64e080e7          	jalr	1614(ra) # 80006614 <plicinithart>
    binit();         // buffer cache
    80000fce:	00002097          	auipc	ra,0x2
    80000fd2:	6c6080e7          	jalr	1734(ra) # 80003694 <binit>
    iinit();         // inode table
    80000fd6:	00003097          	auipc	ra,0x3
    80000fda:	d56080e7          	jalr	-682(ra) # 80003d2c <iinit>
    fileinit();      // file table
    80000fde:	00004097          	auipc	ra,0x4
    80000fe2:	d28080e7          	jalr	-728(ra) # 80004d06 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe6:	00005097          	auipc	ra,0x5
    80000fea:	736080e7          	jalr	1846(ra) # 8000671c <virtio_disk_init>
    userinit();      // first user process
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	df6080e7          	jalr	-522(ra) # 80001de4 <userinit>
    __sync_synchronize();
    80000ff6:	0330000f          	fence	rw,rw
    started = 1;
    80000ffa:	4785                	li	a5,1
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	96f72e23          	sw	a5,-1668(a4) # 80008978 <started>
    80001004:	b789                	j	80000f46 <main+0x56>

0000000080001006 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001006:	1141                	addi	sp,sp,-16
    80001008:	e406                	sd	ra,8(sp)
    8000100a:	e022                	sd	s0,0(sp)
    8000100c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000100e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001012:	00008797          	auipc	a5,0x8
    80001016:	96e7b783          	ld	a5,-1682(a5) # 80008980 <kernel_pagetable>
    8000101a:	83b1                	srli	a5,a5,0xc
    8000101c:	577d                	li	a4,-1
    8000101e:	177e                	slli	a4,a4,0x3f
    80001020:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001022:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001026:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000102a:	60a2                	ld	ra,8(sp)
    8000102c:	6402                	ld	s0,0(sp)
    8000102e:	0141                	addi	sp,sp,16
    80001030:	8082                	ret

0000000080001032 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001032:	7139                	addi	sp,sp,-64
    80001034:	fc06                	sd	ra,56(sp)
    80001036:	f822                	sd	s0,48(sp)
    80001038:	f426                	sd	s1,40(sp)
    8000103a:	f04a                	sd	s2,32(sp)
    8000103c:	ec4e                	sd	s3,24(sp)
    8000103e:	e852                	sd	s4,16(sp)
    80001040:	e456                	sd	s5,8(sp)
    80001042:	e05a                	sd	s6,0(sp)
    80001044:	0080                	addi	s0,sp,64
    80001046:	84aa                	mv	s1,a0
    80001048:	89ae                	mv	s3,a1
    8000104a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001052:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001054:	04b7e263          	bltu	a5,a1,80001098 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001058:	0149d933          	srl	s2,s3,s4
    8000105c:	1ff97913          	andi	s2,s2,511
    80001060:	090e                	slli	s2,s2,0x3
    80001062:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001064:	00093483          	ld	s1,0(s2)
    80001068:	0014f793          	andi	a5,s1,1
    8000106c:	cf95                	beqz	a5,800010a8 <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000106e:	80a9                	srli	s1,s1,0xa
    80001070:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001072:	3a5d                	addiw	s4,s4,-9
    80001074:	ff6a12e3          	bne	s4,s6,80001058 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001078:	00c9d513          	srli	a0,s3,0xc
    8000107c:	1ff57513          	andi	a0,a0,511
    80001080:	050e                	slli	a0,a0,0x3
    80001082:	9526                	add	a0,a0,s1
}
    80001084:	70e2                	ld	ra,56(sp)
    80001086:	7442                	ld	s0,48(sp)
    80001088:	74a2                	ld	s1,40(sp)
    8000108a:	7902                	ld	s2,32(sp)
    8000108c:	69e2                	ld	s3,24(sp)
    8000108e:	6a42                	ld	s4,16(sp)
    80001090:	6aa2                	ld	s5,8(sp)
    80001092:	6b02                	ld	s6,0(sp)
    80001094:	6121                	addi	sp,sp,64
    80001096:	8082                	ret
    panic("walk");
    80001098:	00007517          	auipc	a0,0x7
    8000109c:	01850513          	addi	a0,a0,24 # 800080b0 <etext+0xb0>
    800010a0:	fffff097          	auipc	ra,0xfffff
    800010a4:	4c0080e7          	jalr	1216(ra) # 80000560 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010a8:	020a8663          	beqz	s5,800010d4 <walk+0xa2>
    800010ac:	00000097          	auipc	ra,0x0
    800010b0:	a9e080e7          	jalr	-1378(ra) # 80000b4a <kalloc>
    800010b4:	84aa                	mv	s1,a0
    800010b6:	d579                	beqz	a0,80001084 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010b8:	6605                	lui	a2,0x1
    800010ba:	4581                	li	a1,0
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	c7a080e7          	jalr	-902(ra) # 80000d36 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010c4:	00c4d793          	srli	a5,s1,0xc
    800010c8:	07aa                	slli	a5,a5,0xa
    800010ca:	0017e793          	ori	a5,a5,1
    800010ce:	00f93023          	sd	a5,0(s2)
    800010d2:	b745                	j	80001072 <walk+0x40>
        return 0;
    800010d4:	4501                	li	a0,0
    800010d6:	b77d                	j	80001084 <walk+0x52>

00000000800010d8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d8:	57fd                	li	a5,-1
    800010da:	83e9                	srli	a5,a5,0x1a
    800010dc:	00b7f463          	bgeu	a5,a1,800010e4 <walkaddr+0xc>
    return 0;
    800010e0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e2:	8082                	ret
{
    800010e4:	1141                	addi	sp,sp,-16
    800010e6:	e406                	sd	ra,8(sp)
    800010e8:	e022                	sd	s0,0(sp)
    800010ea:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ec:	4601                	li	a2,0
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	f44080e7          	jalr	-188(ra) # 80001032 <walk>
  if(pte == 0)
    800010f6:	c105                	beqz	a0,80001116 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010fa:	0117f693          	andi	a3,a5,17
    800010fe:	4745                	li	a4,17
    return 0;
    80001100:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001102:	00e68663          	beq	a3,a4,8000110e <walkaddr+0x36>
}
    80001106:	60a2                	ld	ra,8(sp)
    80001108:	6402                	ld	s0,0(sp)
    8000110a:	0141                	addi	sp,sp,16
    8000110c:	8082                	ret
  pa = PTE2PA(*pte);
    8000110e:	83a9                	srli	a5,a5,0xa
    80001110:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001114:	bfcd                	j	80001106 <walkaddr+0x2e>
    return 0;
    80001116:	4501                	li	a0,0
    80001118:	b7fd                	j	80001106 <walkaddr+0x2e>

000000008000111a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000111a:	715d                	addi	sp,sp,-80
    8000111c:	e486                	sd	ra,72(sp)
    8000111e:	e0a2                	sd	s0,64(sp)
    80001120:	fc26                	sd	s1,56(sp)
    80001122:	f84a                	sd	s2,48(sp)
    80001124:	f44e                	sd	s3,40(sp)
    80001126:	f052                	sd	s4,32(sp)
    80001128:	ec56                	sd	s5,24(sp)
    8000112a:	e85a                	sd	s6,16(sp)
    8000112c:	e45e                	sd	s7,8(sp)
    8000112e:	e062                	sd	s8,0(sp)
    80001130:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001132:	ca21                	beqz	a2,80001182 <mappages+0x68>
    80001134:	8aaa                	mv	s5,a0
    80001136:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001138:	777d                	lui	a4,0xfffff
    8000113a:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000113e:	fff58993          	addi	s3,a1,-1
    80001142:	99b2                	add	s3,s3,a2
    80001144:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001148:	893e                	mv	s2,a5
    8000114a:	40f68a33          	sub	s4,a3,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    8000114e:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001150:	6c05                	lui	s8,0x1
    80001152:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001156:	865e                	mv	a2,s7
    80001158:	85ca                	mv	a1,s2
    8000115a:	8556                	mv	a0,s5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	ed6080e7          	jalr	-298(ra) # 80001032 <walk>
    80001164:	cd1d                	beqz	a0,800011a2 <mappages+0x88>
    if(*pte & PTE_V)
    80001166:	611c                	ld	a5,0(a0)
    80001168:	8b85                	andi	a5,a5,1
    8000116a:	e785                	bnez	a5,80001192 <mappages+0x78>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000116c:	80b1                	srli	s1,s1,0xc
    8000116e:	04aa                	slli	s1,s1,0xa
    80001170:	0164e4b3          	or	s1,s1,s6
    80001174:	0014e493          	ori	s1,s1,1
    80001178:	e104                	sd	s1,0(a0)
    if(a == last)
    8000117a:	05390163          	beq	s2,s3,800011bc <mappages+0xa2>
    a += PGSIZE;
    8000117e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    80001180:	bfc9                	j	80001152 <mappages+0x38>
    panic("mappages: size");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	f3650513          	addi	a0,a0,-202 # 800080b8 <etext+0xb8>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3d6080e7          	jalr	982(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001192:	00007517          	auipc	a0,0x7
    80001196:	f3650513          	addi	a0,a0,-202 # 800080c8 <etext+0xc8>
    8000119a:	fffff097          	auipc	ra,0xfffff
    8000119e:	3c6080e7          	jalr	966(ra) # 80000560 <panic>
      return -1;
    800011a2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011a4:	60a6                	ld	ra,72(sp)
    800011a6:	6406                	ld	s0,64(sp)
    800011a8:	74e2                	ld	s1,56(sp)
    800011aa:	7942                	ld	s2,48(sp)
    800011ac:	79a2                	ld	s3,40(sp)
    800011ae:	7a02                	ld	s4,32(sp)
    800011b0:	6ae2                	ld	s5,24(sp)
    800011b2:	6b42                	ld	s6,16(sp)
    800011b4:	6ba2                	ld	s7,8(sp)
    800011b6:	6c02                	ld	s8,0(sp)
    800011b8:	6161                	addi	sp,sp,80
    800011ba:	8082                	ret
  return 0;
    800011bc:	4501                	li	a0,0
    800011be:	b7dd                	j	800011a4 <mappages+0x8a>

00000000800011c0 <kvmmap>:
{
    800011c0:	1141                	addi	sp,sp,-16
    800011c2:	e406                	sd	ra,8(sp)
    800011c4:	e022                	sd	s0,0(sp)
    800011c6:	0800                	addi	s0,sp,16
    800011c8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011ca:	86b2                	mv	a3,a2
    800011cc:	863e                	mv	a2,a5
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f4c080e7          	jalr	-180(ra) # 8000111a <mappages>
    800011d6:	e509                	bnez	a0,800011e0 <kvmmap+0x20>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret
    panic("kvmmap");
    800011e0:	00007517          	auipc	a0,0x7
    800011e4:	ef850513          	addi	a0,a0,-264 # 800080d8 <etext+0xd8>
    800011e8:	fffff097          	auipc	ra,0xfffff
    800011ec:	378080e7          	jalr	888(ra) # 80000560 <panic>

00000000800011f0 <kvmmake>:
{
    800011f0:	1101                	addi	sp,sp,-32
    800011f2:	ec06                	sd	ra,24(sp)
    800011f4:	e822                	sd	s0,16(sp)
    800011f6:	e426                	sd	s1,8(sp)
    800011f8:	e04a                	sd	s2,0(sp)
    800011fa:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	94e080e7          	jalr	-1714(ra) # 80000b4a <kalloc>
    80001204:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001206:	6605                	lui	a2,0x1
    80001208:	4581                	li	a1,0
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	b2c080e7          	jalr	-1236(ra) # 80000d36 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	6685                	lui	a3,0x1
    80001216:	10000637          	lui	a2,0x10000
    8000121a:	85b2                	mv	a1,a2
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	fa2080e7          	jalr	-94(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001226:	4719                	li	a4,6
    80001228:	6685                	lui	a3,0x1
    8000122a:	10001637          	lui	a2,0x10001
    8000122e:	85b2                	mv	a1,a2
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f8e080e7          	jalr	-114(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	004006b7          	lui	a3,0x400
    80001240:	0c000637          	lui	a2,0xc000
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f78080e7          	jalr	-136(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001250:	00007917          	auipc	s2,0x7
    80001254:	db090913          	addi	s2,s2,-592 # 80008000 <etext>
    80001258:	4729                	li	a4,10
    8000125a:	80007697          	auipc	a3,0x80007
    8000125e:	da668693          	addi	a3,a3,-602 # 8000 <_entry-0x7fff8000>
    80001262:	4605                	li	a2,1
    80001264:	067e                	slli	a2,a2,0x1f
    80001266:	85b2                	mv	a1,a2
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f56080e7          	jalr	-170(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001272:	4719                	li	a4,6
    80001274:	46c5                	li	a3,17
    80001276:	06ee                	slli	a3,a3,0x1b
    80001278:	412686b3          	sub	a3,a3,s2
    8000127c:	864a                	mv	a2,s2
    8000127e:	85ca                	mv	a1,s2
    80001280:	8526                	mv	a0,s1
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f3e080e7          	jalr	-194(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000128a:	4729                	li	a4,10
    8000128c:	6685                	lui	a3,0x1
    8000128e:	00006617          	auipc	a2,0x6
    80001292:	d7260613          	addi	a2,a2,-654 # 80007000 <_trampoline>
    80001296:	040005b7          	lui	a1,0x4000
    8000129a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000129c:	05b2                	slli	a1,a1,0xc
    8000129e:	8526                	mv	a0,s1
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f20080e7          	jalr	-224(ra) # 800011c0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012a8:	8526                	mv	a0,s1
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	624080e7          	jalr	1572(ra) # 800018ce <proc_mapstacks>
}
    800012b2:	8526                	mv	a0,s1
    800012b4:	60e2                	ld	ra,24(sp)
    800012b6:	6442                	ld	s0,16(sp)
    800012b8:	64a2                	ld	s1,8(sp)
    800012ba:	6902                	ld	s2,0(sp)
    800012bc:	6105                	addi	sp,sp,32
    800012be:	8082                	ret

00000000800012c0 <kvminit>:
{
    800012c0:	1141                	addi	sp,sp,-16
    800012c2:	e406                	sd	ra,8(sp)
    800012c4:	e022                	sd	s0,0(sp)
    800012c6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	f28080e7          	jalr	-216(ra) # 800011f0 <kvmmake>
    800012d0:	00007797          	auipc	a5,0x7
    800012d4:	6aa7b823          	sd	a0,1712(a5) # 80008980 <kernel_pagetable>
}
    800012d8:	60a2                	ld	ra,8(sp)
    800012da:	6402                	ld	s0,0(sp)
    800012dc:	0141                	addi	sp,sp,16
    800012de:	8082                	ret

00000000800012e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012e0:	715d                	addi	sp,sp,-80
    800012e2:	e486                	sd	ra,72(sp)
    800012e4:	e0a2                	sd	s0,64(sp)
    800012e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012e8:	03459793          	slli	a5,a1,0x34
    800012ec:	e39d                	bnez	a5,80001312 <uvmunmap+0x32>
    800012ee:	f84a                	sd	s2,48(sp)
    800012f0:	f44e                	sd	s3,40(sp)
    800012f2:	f052                	sd	s4,32(sp)
    800012f4:	ec56                	sd	s5,24(sp)
    800012f6:	e85a                	sd	s6,16(sp)
    800012f8:	e45e                	sd	s7,8(sp)
    800012fa:	8a2a                	mv	s4,a0
    800012fc:	892e                	mv	s2,a1
    800012fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001300:	0632                	slli	a2,a2,0xc
    80001302:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001306:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001308:	6b05                	lui	s6,0x1
    8000130a:	0935fb63          	bgeu	a1,s3,800013a0 <uvmunmap+0xc0>
    8000130e:	fc26                	sd	s1,56(sp)
    80001310:	a8a9                	j	8000136a <uvmunmap+0x8a>
    80001312:	fc26                	sd	s1,56(sp)
    80001314:	f84a                	sd	s2,48(sp)
    80001316:	f44e                	sd	s3,40(sp)
    80001318:	f052                	sd	s4,32(sp)
    8000131a:	ec56                	sd	s5,24(sp)
    8000131c:	e85a                	sd	s6,16(sp)
    8000131e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001320:	00007517          	auipc	a0,0x7
    80001324:	dc050513          	addi	a0,a0,-576 # 800080e0 <etext+0xe0>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	238080e7          	jalr	568(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    80001330:	00007517          	auipc	a0,0x7
    80001334:	dc850513          	addi	a0,a0,-568 # 800080f8 <etext+0xf8>
    80001338:	fffff097          	auipc	ra,0xfffff
    8000133c:	228080e7          	jalr	552(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001340:	00007517          	auipc	a0,0x7
    80001344:	dc850513          	addi	a0,a0,-568 # 80008108 <etext+0x108>
    80001348:	fffff097          	auipc	ra,0xfffff
    8000134c:	218080e7          	jalr	536(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001350:	00007517          	auipc	a0,0x7
    80001354:	dd050513          	addi	a0,a0,-560 # 80008120 <etext+0x120>
    80001358:	fffff097          	auipc	ra,0xfffff
    8000135c:	208080e7          	jalr	520(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001360:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001364:	995a                	add	s2,s2,s6
    80001366:	03397c63          	bgeu	s2,s3,8000139e <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000136a:	4601                	li	a2,0
    8000136c:	85ca                	mv	a1,s2
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	cc2080e7          	jalr	-830(ra) # 80001032 <walk>
    80001378:	84aa                	mv	s1,a0
    8000137a:	d95d                	beqz	a0,80001330 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000137c:	6108                	ld	a0,0(a0)
    8000137e:	00157793          	andi	a5,a0,1
    80001382:	dfdd                	beqz	a5,80001340 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001384:	3ff57793          	andi	a5,a0,1023
    80001388:	fd7784e3          	beq	a5,s7,80001350 <uvmunmap+0x70>
    if(do_free){
    8000138c:	fc0a8ae3          	beqz	s5,80001360 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001390:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001392:	0532                	slli	a0,a0,0xc
    80001394:	fffff097          	auipc	ra,0xfffff
    80001398:	6b8080e7          	jalr	1720(ra) # 80000a4c <kfree>
    8000139c:	b7d1                	j	80001360 <uvmunmap+0x80>
    8000139e:	74e2                	ld	s1,56(sp)
    800013a0:	7942                	ld	s2,48(sp)
    800013a2:	79a2                	ld	s3,40(sp)
    800013a4:	7a02                	ld	s4,32(sp)
    800013a6:	6ae2                	ld	s5,24(sp)
    800013a8:	6b42                	ld	s6,16(sp)
    800013aa:	6ba2                	ld	s7,8(sp)
  }
}
    800013ac:	60a6                	ld	ra,72(sp)
    800013ae:	6406                	ld	s0,64(sp)
    800013b0:	6161                	addi	sp,sp,80
    800013b2:	8082                	ret

00000000800013b4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	78c080e7          	jalr	1932(ra) # 80000b4a <kalloc>
    800013c6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013c8:	c519                	beqz	a0,800013d6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ca:	6605                	lui	a2,0x1
    800013cc:	4581                	li	a1,0
    800013ce:	00000097          	auipc	ra,0x0
    800013d2:	968080e7          	jalr	-1688(ra) # 80000d36 <memset>
  return pagetable;
}
    800013d6:	8526                	mv	a0,s1
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6105                	addi	sp,sp,32
    800013e0:	8082                	ret

00000000800013e2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013e2:	7179                	addi	sp,sp,-48
    800013e4:	f406                	sd	ra,40(sp)
    800013e6:	f022                	sd	s0,32(sp)
    800013e8:	ec26                	sd	s1,24(sp)
    800013ea:	e84a                	sd	s2,16(sp)
    800013ec:	e44e                	sd	s3,8(sp)
    800013ee:	e052                	sd	s4,0(sp)
    800013f0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013f2:	6785                	lui	a5,0x1
    800013f4:	04f67863          	bgeu	a2,a5,80001444 <uvmfirst+0x62>
    800013f8:	8a2a                	mv	s4,a0
    800013fa:	89ae                	mv	s3,a1
    800013fc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	74c080e7          	jalr	1868(ra) # 80000b4a <kalloc>
    80001406:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	4581                	li	a1,0
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	92a080e7          	jalr	-1750(ra) # 80000d36 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001414:	4779                	li	a4,30
    80001416:	86ca                	mv	a3,s2
    80001418:	6605                	lui	a2,0x1
    8000141a:	4581                	li	a1,0
    8000141c:	8552                	mv	a0,s4
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	cfc080e7          	jalr	-772(ra) # 8000111a <mappages>
  memmove(mem, src, sz);
    80001426:	8626                	mv	a2,s1
    80001428:	85ce                	mv	a1,s3
    8000142a:	854a                	mv	a0,s2
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	96e080e7          	jalr	-1682(ra) # 80000d9a <memmove>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret
    panic("uvmfirst: more than a page");
    80001444:	00007517          	auipc	a0,0x7
    80001448:	cf450513          	addi	a0,a0,-780 # 80008138 <etext+0x138>
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	114080e7          	jalr	276(ra) # 80000560 <panic>

0000000080001454 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001454:	1101                	addi	sp,sp,-32
    80001456:	ec06                	sd	ra,24(sp)
    80001458:	e822                	sd	s0,16(sp)
    8000145a:	e426                	sd	s1,8(sp)
    8000145c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000145e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001460:	00b67d63          	bgeu	a2,a1,8000147a <uvmdealloc+0x26>
    80001464:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001466:	6785                	lui	a5,0x1
    80001468:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000146a:	00f60733          	add	a4,a2,a5
    8000146e:	76fd                	lui	a3,0xfffff
    80001470:	8f75                	and	a4,a4,a3
    80001472:	97ae                	add	a5,a5,a1
    80001474:	8ff5                	and	a5,a5,a3
    80001476:	00f76863          	bltu	a4,a5,80001486 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000147a:	8526                	mv	a0,s1
    8000147c:	60e2                	ld	ra,24(sp)
    8000147e:	6442                	ld	s0,16(sp)
    80001480:	64a2                	ld	s1,8(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001486:	8f99                	sub	a5,a5,a4
    80001488:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000148a:	4685                	li	a3,1
    8000148c:	0007861b          	sext.w	a2,a5
    80001490:	85ba                	mv	a1,a4
    80001492:	00000097          	auipc	ra,0x0
    80001496:	e4e080e7          	jalr	-434(ra) # 800012e0 <uvmunmap>
    8000149a:	b7c5                	j	8000147a <uvmdealloc+0x26>

000000008000149c <uvmalloc>:
  if(newsz < oldsz)
    8000149c:	0ab66f63          	bltu	a2,a1,8000155a <uvmalloc+0xbe>
{
    800014a0:	715d                	addi	sp,sp,-80
    800014a2:	e486                	sd	ra,72(sp)
    800014a4:	e0a2                	sd	s0,64(sp)
    800014a6:	f052                	sd	s4,32(sp)
    800014a8:	ec56                	sd	s5,24(sp)
    800014aa:	e85a                	sd	s6,16(sp)
    800014ac:	0880                	addi	s0,sp,80
    800014ae:	8b2a                	mv	s6,a0
    800014b0:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    800014b2:	6785                	lui	a5,0x1
    800014b4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014b6:	95be                	add	a1,a1,a5
    800014b8:	77fd                	lui	a5,0xfffff
    800014ba:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014be:	0aca7063          	bgeu	s4,a2,8000155e <uvmalloc+0xc2>
    800014c2:	fc26                	sd	s1,56(sp)
    800014c4:	f84a                	sd	s2,48(sp)
    800014c6:	f44e                	sd	s3,40(sp)
    800014c8:	e45e                	sd	s7,8(sp)
    800014ca:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    800014cc:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014ce:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	678080e7          	jalr	1656(ra) # 80000b4a <kalloc>
    800014da:	84aa                	mv	s1,a0
    if(mem == 0){
    800014dc:	c915                	beqz	a0,80001510 <uvmalloc+0x74>
    memset(mem, 0, PGSIZE);
    800014de:	864e                	mv	a2,s3
    800014e0:	4581                	li	a1,0
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	854080e7          	jalr	-1964(ra) # 80000d36 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014ea:	875e                	mv	a4,s7
    800014ec:	86a6                	mv	a3,s1
    800014ee:	864e                	mv	a2,s3
    800014f0:	85ca                	mv	a1,s2
    800014f2:	855a                	mv	a0,s6
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	c26080e7          	jalr	-986(ra) # 8000111a <mappages>
    800014fc:	ed0d                	bnez	a0,80001536 <uvmalloc+0x9a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014fe:	994e                	add	s2,s2,s3
    80001500:	fd5969e3          	bltu	s2,s5,800014d2 <uvmalloc+0x36>
  return newsz;
    80001504:	8556                	mv	a0,s5
    80001506:	74e2                	ld	s1,56(sp)
    80001508:	7942                	ld	s2,48(sp)
    8000150a:	79a2                	ld	s3,40(sp)
    8000150c:	6ba2                	ld	s7,8(sp)
    8000150e:	a829                	j	80001528 <uvmalloc+0x8c>
      uvmdealloc(pagetable, a, oldsz);
    80001510:	8652                	mv	a2,s4
    80001512:	85ca                	mv	a1,s2
    80001514:	855a                	mv	a0,s6
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	f3e080e7          	jalr	-194(ra) # 80001454 <uvmdealloc>
      return 0;
    8000151e:	4501                	li	a0,0
    80001520:	74e2                	ld	s1,56(sp)
    80001522:	7942                	ld	s2,48(sp)
    80001524:	79a2                	ld	s3,40(sp)
    80001526:	6ba2                	ld	s7,8(sp)
}
    80001528:	60a6                	ld	ra,72(sp)
    8000152a:	6406                	ld	s0,64(sp)
    8000152c:	7a02                	ld	s4,32(sp)
    8000152e:	6ae2                	ld	s5,24(sp)
    80001530:	6b42                	ld	s6,16(sp)
    80001532:	6161                	addi	sp,sp,80
    80001534:	8082                	ret
      kfree(mem);
    80001536:	8526                	mv	a0,s1
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	514080e7          	jalr	1300(ra) # 80000a4c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001540:	8652                	mv	a2,s4
    80001542:	85ca                	mv	a1,s2
    80001544:	855a                	mv	a0,s6
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f0e080e7          	jalr	-242(ra) # 80001454 <uvmdealloc>
      return 0;
    8000154e:	4501                	li	a0,0
    80001550:	74e2                	ld	s1,56(sp)
    80001552:	7942                	ld	s2,48(sp)
    80001554:	79a2                	ld	s3,40(sp)
    80001556:	6ba2                	ld	s7,8(sp)
    80001558:	bfc1                	j	80001528 <uvmalloc+0x8c>
    return oldsz;
    8000155a:	852e                	mv	a0,a1
}
    8000155c:	8082                	ret
  return newsz;
    8000155e:	8532                	mv	a0,a2
    80001560:	b7e1                	j	80001528 <uvmalloc+0x8c>

0000000080001562 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001562:	7179                	addi	sp,sp,-48
    80001564:	f406                	sd	ra,40(sp)
    80001566:	f022                	sd	s0,32(sp)
    80001568:	ec26                	sd	s1,24(sp)
    8000156a:	e84a                	sd	s2,16(sp)
    8000156c:	e44e                	sd	s3,8(sp)
    8000156e:	e052                	sd	s4,0(sp)
    80001570:	1800                	addi	s0,sp,48
    80001572:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001574:	84aa                	mv	s1,a0
    80001576:	6905                	lui	s2,0x1
    80001578:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000157a:	4985                	li	s3,1
    8000157c:	a829                	j	80001596 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000157e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001580:	00c79513          	slli	a0,a5,0xc
    80001584:	00000097          	auipc	ra,0x0
    80001588:	fde080e7          	jalr	-34(ra) # 80001562 <freewalk>
      pagetable[i] = 0;
    8000158c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001590:	04a1                	addi	s1,s1,8
    80001592:	03248163          	beq	s1,s2,800015b4 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001596:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001598:	00f7f713          	andi	a4,a5,15
    8000159c:	ff3701e3          	beq	a4,s3,8000157e <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015a0:	8b85                	andi	a5,a5,1
    800015a2:	d7fd                	beqz	a5,80001590 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015a4:	00007517          	auipc	a0,0x7
    800015a8:	bb450513          	addi	a0,a0,-1100 # 80008158 <etext+0x158>
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	fb4080e7          	jalr	-76(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    800015b4:	8552                	mv	a0,s4
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	496080e7          	jalr	1174(ra) # 80000a4c <kfree>
}
    800015be:	70a2                	ld	ra,40(sp)
    800015c0:	7402                	ld	s0,32(sp)
    800015c2:	64e2                	ld	s1,24(sp)
    800015c4:	6942                	ld	s2,16(sp)
    800015c6:	69a2                	ld	s3,8(sp)
    800015c8:	6a02                	ld	s4,0(sp)
    800015ca:	6145                	addi	sp,sp,48
    800015cc:	8082                	ret

00000000800015ce <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ce:	1101                	addi	sp,sp,-32
    800015d0:	ec06                	sd	ra,24(sp)
    800015d2:	e822                	sd	s0,16(sp)
    800015d4:	e426                	sd	s1,8(sp)
    800015d6:	1000                	addi	s0,sp,32
    800015d8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015da:	e999                	bnez	a1,800015f0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015dc:	8526                	mv	a0,s1
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	f84080e7          	jalr	-124(ra) # 80001562 <freewalk>
}
    800015e6:	60e2                	ld	ra,24(sp)
    800015e8:	6442                	ld	s0,16(sp)
    800015ea:	64a2                	ld	s1,8(sp)
    800015ec:	6105                	addi	sp,sp,32
    800015ee:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f0:	6785                	lui	a5,0x1
    800015f2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015f4:	95be                	add	a1,a1,a5
    800015f6:	4685                	li	a3,1
    800015f8:	00c5d613          	srli	a2,a1,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	ce2080e7          	jalr	-798(ra) # 800012e0 <uvmunmap>
    80001606:	bfd9                	j	800015dc <uvmfree+0xe>

0000000080001608 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001608:	ca69                	beqz	a2,800016da <uvmcopy+0xd2>
{
    8000160a:	715d                	addi	sp,sp,-80
    8000160c:	e486                	sd	ra,72(sp)
    8000160e:	e0a2                	sd	s0,64(sp)
    80001610:	fc26                	sd	s1,56(sp)
    80001612:	f84a                	sd	s2,48(sp)
    80001614:	f44e                	sd	s3,40(sp)
    80001616:	f052                	sd	s4,32(sp)
    80001618:	ec56                	sd	s5,24(sp)
    8000161a:	e85a                	sd	s6,16(sp)
    8000161c:	e45e                	sd	s7,8(sp)
    8000161e:	e062                	sd	s8,0(sp)
    80001620:	0880                	addi	s0,sp,80
    80001622:	8baa                	mv	s7,a0
    80001624:	8b2e                	mv	s6,a1
    80001626:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162a:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000162c:	4601                	li	a2,0
    8000162e:	85ce                	mv	a1,s3
    80001630:	855e                	mv	a0,s7
    80001632:	00000097          	auipc	ra,0x0
    80001636:	a00080e7          	jalr	-1536(ra) # 80001032 <walk>
    8000163a:	c529                	beqz	a0,80001684 <uvmcopy+0x7c>
    if((*pte & PTE_V) == 0)
    8000163c:	6118                	ld	a4,0(a0)
    8000163e:	00177793          	andi	a5,a4,1
    80001642:	cba9                	beqz	a5,80001694 <uvmcopy+0x8c>
    pa = PTE2PA(*pte);
    80001644:	00a75593          	srli	a1,a4,0xa
    80001648:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000164c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	4fa080e7          	jalr	1274(ra) # 80000b4a <kalloc>
    80001658:	892a                	mv	s2,a0
    8000165a:	c931                	beqz	a0,800016ae <uvmcopy+0xa6>
    memmove(mem, (char*)pa, PGSIZE);
    8000165c:	8652                	mv	a2,s4
    8000165e:	85e2                	mv	a1,s8
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	73a080e7          	jalr	1850(ra) # 80000d9a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001668:	8726                	mv	a4,s1
    8000166a:	86ca                	mv	a3,s2
    8000166c:	8652                	mv	a2,s4
    8000166e:	85ce                	mv	a1,s3
    80001670:	855a                	mv	a0,s6
    80001672:	00000097          	auipc	ra,0x0
    80001676:	aa8080e7          	jalr	-1368(ra) # 8000111a <mappages>
    8000167a:	e50d                	bnez	a0,800016a4 <uvmcopy+0x9c>
  for(i = 0; i < sz; i += PGSIZE){
    8000167c:	99d2                	add	s3,s3,s4
    8000167e:	fb59e7e3          	bltu	s3,s5,8000162c <uvmcopy+0x24>
    80001682:	a081                	j	800016c2 <uvmcopy+0xba>
      panic("uvmcopy: pte should exist");
    80001684:	00007517          	auipc	a0,0x7
    80001688:	ae450513          	addi	a0,a0,-1308 # 80008168 <etext+0x168>
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	ed4080e7          	jalr	-300(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001694:	00007517          	auipc	a0,0x7
    80001698:	af450513          	addi	a0,a0,-1292 # 80008188 <etext+0x188>
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	ec4080e7          	jalr	-316(ra) # 80000560 <panic>
      kfree(mem);
    800016a4:	854a                	mv	a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	3a6080e7          	jalr	934(ra) # 80000a4c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ae:	4685                	li	a3,1
    800016b0:	00c9d613          	srli	a2,s3,0xc
    800016b4:	4581                	li	a1,0
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	c28080e7          	jalr	-984(ra) # 800012e0 <uvmunmap>
  return -1;
    800016c0:	557d                	li	a0,-1
}
    800016c2:	60a6                	ld	ra,72(sp)
    800016c4:	6406                	ld	s0,64(sp)
    800016c6:	74e2                	ld	s1,56(sp)
    800016c8:	7942                	ld	s2,48(sp)
    800016ca:	79a2                	ld	s3,40(sp)
    800016cc:	7a02                	ld	s4,32(sp)
    800016ce:	6ae2                	ld	s5,24(sp)
    800016d0:	6b42                	ld	s6,16(sp)
    800016d2:	6ba2                	ld	s7,8(sp)
    800016d4:	6c02                	ld	s8,0(sp)
    800016d6:	6161                	addi	sp,sp,80
    800016d8:	8082                	ret
  return 0;
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret

00000000800016de <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016de:	1141                	addi	sp,sp,-16
    800016e0:	e406                	sd	ra,8(sp)
    800016e2:	e022                	sd	s0,0(sp)
    800016e4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e6:	4601                	li	a2,0
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	94a080e7          	jalr	-1718(ra) # 80001032 <walk>
  if(pte == 0)
    800016f0:	c901                	beqz	a0,80001700 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016f2:	611c                	ld	a5,0(a0)
    800016f4:	9bbd                	andi	a5,a5,-17
    800016f6:	e11c                	sd	a5,0(a0)
}
    800016f8:	60a2                	ld	ra,8(sp)
    800016fa:	6402                	ld	s0,0(sp)
    800016fc:	0141                	addi	sp,sp,16
    800016fe:	8082                	ret
    panic("uvmclear");
    80001700:	00007517          	auipc	a0,0x7
    80001704:	aa850513          	addi	a0,a0,-1368 # 800081a8 <etext+0x1a8>
    80001708:	fffff097          	auipc	ra,0xfffff
    8000170c:	e58080e7          	jalr	-424(ra) # 80000560 <panic>

0000000080001710 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyout+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8c2e                	mv	s8,a1
    8000172e:	8a32                	mv	s4,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	85d2                	mv	a1,s4
    80001740:	41250533          	sub	a0,a0,s2
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	656080e7          	jalr	1622(ra) # 80000d9a <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001750:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	976080e7          	jalr	-1674(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyout+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyout+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyout+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000179c:	caa5                	beqz	a3,8000180c <copyin+0x70>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	e062                	sd	s8,0(sp)
    800017b4:	0880                	addi	s0,sp,80
    800017b6:	8b2a                	mv	s6,a0
    800017b8:	8a2e                	mv	s4,a1
    800017ba:	8c32                	mv	s8,a2
    800017bc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017be:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c0:	6a85                	lui	s5,0x1
    800017c2:	a01d                	j	800017e8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017c4:	018505b3          	add	a1,a0,s8
    800017c8:	0004861b          	sext.w	a2,s1
    800017cc:	412585b3          	sub	a1,a1,s2
    800017d0:	8552                	mv	a0,s4
    800017d2:	fffff097          	auipc	ra,0xfffff
    800017d6:	5c8080e7          	jalr	1480(ra) # 80000d9a <memmove>

    len -= n;
    800017da:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017de:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017e0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e4:	02098263          	beqz	s3,80001808 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017ec:	85ca                	mv	a1,s2
    800017ee:	855a                	mv	a0,s6
    800017f0:	00000097          	auipc	ra,0x0
    800017f4:	8e8080e7          	jalr	-1816(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    800017f8:	cd01                	beqz	a0,80001810 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017fa:	418904b3          	sub	s1,s2,s8
    800017fe:	94d6                	add	s1,s1,s5
    if(n > len)
    80001800:	fc99f2e3          	bgeu	s3,s1,800017c4 <copyin+0x28>
    80001804:	84ce                	mv	s1,s3
    80001806:	bf7d                	j	800017c4 <copyin+0x28>
  }
  return 0;
    80001808:	4501                	li	a0,0
    8000180a:	a021                	j	80001812 <copyin+0x76>
    8000180c:	4501                	li	a0,0
}
    8000180e:	8082                	ret
      return -1;
    80001810:	557d                	li	a0,-1
}
    80001812:	60a6                	ld	ra,72(sp)
    80001814:	6406                	ld	s0,64(sp)
    80001816:	74e2                	ld	s1,56(sp)
    80001818:	7942                	ld	s2,48(sp)
    8000181a:	79a2                	ld	s3,40(sp)
    8000181c:	7a02                	ld	s4,32(sp)
    8000181e:	6ae2                	ld	s5,24(sp)
    80001820:	6b42                	ld	s6,16(sp)
    80001822:	6ba2                	ld	s7,8(sp)
    80001824:	6c02                	ld	s8,0(sp)
    80001826:	6161                	addi	sp,sp,80
    80001828:	8082                	ret

000000008000182a <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    8000182a:	715d                	addi	sp,sp,-80
    8000182c:	e486                	sd	ra,72(sp)
    8000182e:	e0a2                	sd	s0,64(sp)
    80001830:	fc26                	sd	s1,56(sp)
    80001832:	f84a                	sd	s2,48(sp)
    80001834:	f44e                	sd	s3,40(sp)
    80001836:	f052                	sd	s4,32(sp)
    80001838:	ec56                	sd	s5,24(sp)
    8000183a:	e85a                	sd	s6,16(sp)
    8000183c:	e45e                	sd	s7,8(sp)
    8000183e:	0880                	addi	s0,sp,80
    80001840:	8aaa                	mv	s5,a0
    80001842:	89ae                	mv	s3,a1
    80001844:	8bb2                	mv	s7,a2
    80001846:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    80001848:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000184a:	6a05                	lui	s4,0x1
    8000184c:	a02d                	j	80001876 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184e:	00078023          	sb	zero,0(a5)
    80001852:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001854:	0017c793          	xori	a5,a5,1
    80001858:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000185c:	60a6                	ld	ra,72(sp)
    8000185e:	6406                	ld	s0,64(sp)
    80001860:	74e2                	ld	s1,56(sp)
    80001862:	7942                	ld	s2,48(sp)
    80001864:	79a2                	ld	s3,40(sp)
    80001866:	7a02                	ld	s4,32(sp)
    80001868:	6ae2                	ld	s5,24(sp)
    8000186a:	6b42                	ld	s6,16(sp)
    8000186c:	6ba2                	ld	s7,8(sp)
    8000186e:	6161                	addi	sp,sp,80
    80001870:	8082                	ret
    srcva = va0 + PGSIZE;
    80001872:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001876:	c8a1                	beqz	s1,800018c6 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001878:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000187c:	85ca                	mv	a1,s2
    8000187e:	8556                	mv	a0,s5
    80001880:	00000097          	auipc	ra,0x0
    80001884:	858080e7          	jalr	-1960(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    80001888:	c129                	beqz	a0,800018ca <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000188a:	41790633          	sub	a2,s2,s7
    8000188e:	9652                	add	a2,a2,s4
    if(n > max)
    80001890:	00c4f363          	bgeu	s1,a2,80001896 <copyinstr+0x6c>
    80001894:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001896:	412b8bb3          	sub	s7,s7,s2
    8000189a:	9baa                	add	s7,s7,a0
    while(n > 0){
    8000189c:	da79                	beqz	a2,80001872 <copyinstr+0x48>
    8000189e:	87ce                	mv	a5,s3
      if(*p == '\0'){
    800018a0:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    800018a4:	964e                	add	a2,a2,s3
    800018a6:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018a8:	00f68733          	add	a4,a3,a5
    800018ac:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd4fe0>
    800018b0:	df59                	beqz	a4,8000184e <copyinstr+0x24>
        *dst = *p;
    800018b2:	00e78023          	sb	a4,0(a5)
      dst++;
    800018b6:	0785                	addi	a5,a5,1
    while(n > 0){
    800018b8:	fec797e3          	bne	a5,a2,800018a6 <copyinstr+0x7c>
    800018bc:	14fd                	addi	s1,s1,-1
    800018be:	94ce                	add	s1,s1,s3
      --max;
    800018c0:	8c8d                	sub	s1,s1,a1
    800018c2:	89be                	mv	s3,a5
    800018c4:	b77d                	j	80001872 <copyinstr+0x48>
    800018c6:	4781                	li	a5,0
    800018c8:	b771                	j	80001854 <copyinstr+0x2a>
      return -1;
    800018ca:	557d                	li	a0,-1
    800018cc:	bf41                	j	8000185c <copyinstr+0x32>

00000000800018ce <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800018ce:	715d                	addi	sp,sp,-80
    800018d0:	e486                	sd	ra,72(sp)
    800018d2:	e0a2                	sd	s0,64(sp)
    800018d4:	fc26                	sd	s1,56(sp)
    800018d6:	f84a                	sd	s2,48(sp)
    800018d8:	f44e                	sd	s3,40(sp)
    800018da:	f052                	sd	s4,32(sp)
    800018dc:	ec56                	sd	s5,24(sp)
    800018de:	e85a                	sd	s6,16(sp)
    800018e0:	e45e                	sd	s7,8(sp)
    800018e2:	e062                	sd	s8,0(sp)
    800018e4:	0880                	addi	s0,sp,80
    800018e6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800018e8:	00010497          	auipc	s1,0x10
    800018ec:	f5848493          	addi	s1,s1,-168 # 80011840 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018f0:	8c26                	mv	s8,s1
    800018f2:	8c1357b7          	lui	a5,0x8c135
    800018f6:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b1fd>
    800018fa:	21cfb937          	lui	s2,0x21cfb
    800018fe:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001902:	1902                	slli	s2,s2,0x20
    80001904:	993e                	add	s2,s2,a5
    80001906:	040009b7          	lui	s3,0x4000
    8000190a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000190c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000190e:	4b99                	li	s7,6
    80001910:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++)
    80001912:	0001da97          	auipc	s5,0x1d
    80001916:	32ea8a93          	addi	s5,s5,814 # 8001ec40 <tickslock>
    char *pa = kalloc();
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	230080e7          	jalr	560(ra) # 80000b4a <kalloc>
    80001922:	862a                	mv	a2,a0
    if (pa == 0)
    80001924:	c131                	beqz	a0,80001968 <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int)(p - proc));
    80001926:	418485b3          	sub	a1,s1,s8
    8000192a:	8591                	srai	a1,a1,0x4
    8000192c:	032585b3          	mul	a1,a1,s2
    80001930:	2585                	addiw	a1,a1,1
    80001932:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001936:	875e                	mv	a4,s7
    80001938:	86da                	mv	a3,s6
    8000193a:	40b985b3          	sub	a1,s3,a1
    8000193e:	8552                	mv	a0,s4
    80001940:	00000097          	auipc	ra,0x0
    80001944:	880080e7          	jalr	-1920(ra) # 800011c0 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001948:	35048493          	addi	s1,s1,848
    8000194c:	fd5497e3          	bne	s1,s5,8000191a <proc_mapstacks+0x4c>
  }
}
    80001950:	60a6                	ld	ra,72(sp)
    80001952:	6406                	ld	s0,64(sp)
    80001954:	74e2                	ld	s1,56(sp)
    80001956:	7942                	ld	s2,48(sp)
    80001958:	79a2                	ld	s3,40(sp)
    8000195a:	7a02                	ld	s4,32(sp)
    8000195c:	6ae2                	ld	s5,24(sp)
    8000195e:	6b42                	ld	s6,16(sp)
    80001960:	6ba2                	ld	s7,8(sp)
    80001962:	6c02                	ld	s8,0(sp)
    80001964:	6161                	addi	sp,sp,80
    80001966:	8082                	ret
      panic("kalloc");
    80001968:	00007517          	auipc	a0,0x7
    8000196c:	85050513          	addi	a0,a0,-1968 # 800081b8 <etext+0x1b8>
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	bf0080e7          	jalr	-1040(ra) # 80000560 <panic>

0000000080001978 <rand>:
uint64 rand(void)
{
    80001978:	1141                	addi	sp,sp,-16
    8000197a:	e406                	sd	ra,8(sp)
    8000197c:	e022                	sd	s0,0(sp)
    8000197e:	0800                	addi	s0,sp,16
  static uint64 seed = 12345;         // Seed value (you can change this)
  seed = (seed * 48271) % 2147483647; // LCG formula
    80001980:	00007697          	auipc	a3,0x7
    80001984:	f8868693          	addi	a3,a3,-120 # 80008908 <seed.2>
    80001988:	629c                	ld	a5,0(a3)
    8000198a:	6731                	lui	a4,0xc
    8000198c:	c8f70713          	addi	a4,a4,-881 # bc8f <_entry-0x7fff4371>
    80001990:	02e787b3          	mul	a5,a5,a4
    80001994:	4505                	li	a0,1
    80001996:	1506                	slli	a0,a0,0x21
    80001998:	0515                	addi	a0,a0,5
    8000199a:	02a7b533          	mulhu	a0,a5,a0
    8000199e:	40a78733          	sub	a4,a5,a0
    800019a2:	8305                	srli	a4,a4,0x1
    800019a4:	953a                	add	a0,a0,a4
    800019a6:	8179                	srli	a0,a0,0x1e
    800019a8:	01f51713          	slli	a4,a0,0x1f
    800019ac:	40a70533          	sub	a0,a4,a0
    800019b0:	40a78533          	sub	a0,a5,a0
    800019b4:	e288                	sd	a0,0(a3)
  return seed;
}
    800019b6:	60a2                	ld	ra,8(sp)
    800019b8:	6402                	ld	s0,0(sp)
    800019ba:	0141                	addi	sp,sp,16
    800019bc:	8082                	ret

00000000800019be <procinit>:
// initialize the proc table.
void procinit(void)
{
    800019be:	7139                	addi	sp,sp,-64
    800019c0:	fc06                	sd	ra,56(sp)
    800019c2:	f822                	sd	s0,48(sp)
    800019c4:	f426                	sd	s1,40(sp)
    800019c6:	f04a                	sd	s2,32(sp)
    800019c8:	ec4e                	sd	s3,24(sp)
    800019ca:	e852                	sd	s4,16(sp)
    800019cc:	e456                	sd	s5,8(sp)
    800019ce:	e05a                	sd	s6,0(sp)
    800019d0:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800019d2:	00006597          	auipc	a1,0x6
    800019d6:	7ee58593          	addi	a1,a1,2030 # 800081c0 <etext+0x1c0>
    800019da:	0000f517          	auipc	a0,0xf
    800019de:	22650513          	addi	a0,a0,550 # 80010c00 <pid_lock>
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	1c8080e7          	jalr	456(ra) # 80000baa <initlock>
  initlock(&wait_lock, "wait_lock");
    800019ea:	00006597          	auipc	a1,0x6
    800019ee:	7de58593          	addi	a1,a1,2014 # 800081c8 <etext+0x1c8>
    800019f2:	0000f517          	auipc	a0,0xf
    800019f6:	22650513          	addi	a0,a0,550 # 80010c18 <wait_lock>
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	1b0080e7          	jalr	432(ra) # 80000baa <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a02:	00010497          	auipc	s1,0x10
    80001a06:	e3e48493          	addi	s1,s1,-450 # 80011840 <proc>
  {
    initlock(&p->lock, "proc");
    80001a0a:	00006b17          	auipc	s6,0x6
    80001a0e:	7ceb0b13          	addi	s6,s6,1998 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a12:	8aa6                	mv	s5,s1
    80001a14:	8c1357b7          	lui	a5,0x8c135
    80001a18:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b1fd>
    80001a1c:	21cfb937          	lui	s2,0x21cfb
    80001a20:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001a24:	1902                	slli	s2,s2,0x20
    80001a26:	993e                	add	s2,s2,a5
    80001a28:	040009b7          	lui	s3,0x4000
    80001a2c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a2e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a30:	0001da17          	auipc	s4,0x1d
    80001a34:	210a0a13          	addi	s4,s4,528 # 8001ec40 <tickslock>
    initlock(&p->lock, "proc");
    80001a38:	85da                	mv	a1,s6
    80001a3a:	8526                	mv	a0,s1
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	16e080e7          	jalr	366(ra) # 80000baa <initlock>
    p->state = UNUSED;
    80001a44:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001a48:	415487b3          	sub	a5,s1,s5
    80001a4c:	8791                	srai	a5,a5,0x4
    80001a4e:	032787b3          	mul	a5,a5,s2
    80001a52:	2785                	addiw	a5,a5,1
    80001a54:	00d7979b          	slliw	a5,a5,0xd
    80001a58:	40f987b3          	sub	a5,s3,a5
    80001a5c:	20f4bc23          	sd	a5,536(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a60:	35048493          	addi	s1,s1,848
    80001a64:	fd449ae3          	bne	s1,s4,80001a38 <procinit+0x7a>
  }
}
    80001a68:	70e2                	ld	ra,56(sp)
    80001a6a:	7442                	ld	s0,48(sp)
    80001a6c:	74a2                	ld	s1,40(sp)
    80001a6e:	7902                	ld	s2,32(sp)
    80001a70:	69e2                	ld	s3,24(sp)
    80001a72:	6a42                	ld	s4,16(sp)
    80001a74:	6aa2                	ld	s5,8(sp)
    80001a76:	6b02                	ld	s6,0(sp)
    80001a78:	6121                	addi	sp,sp,64
    80001a7a:	8082                	ret

0000000080001a7c <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001a7c:	1141                	addi	sp,sp,-16
    80001a7e:	e406                	sd	ra,8(sp)
    80001a80:	e022                	sd	s0,0(sp)
    80001a82:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a84:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a86:	2501                	sext.w	a0,a0
    80001a88:	60a2                	ld	ra,8(sp)
    80001a8a:	6402                	ld	s0,0(sp)
    80001a8c:	0141                	addi	sp,sp,16
    80001a8e:	8082                	ret

0000000080001a90 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a90:	1141                	addi	sp,sp,-16
    80001a92:	e406                	sd	ra,8(sp)
    80001a94:	e022                	sd	s0,0(sp)
    80001a96:	0800                	addi	s0,sp,16
    80001a98:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a9a:	2781                	sext.w	a5,a5
    80001a9c:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a9e:	0000f517          	auipc	a0,0xf
    80001aa2:	19250513          	addi	a0,a0,402 # 80010c30 <cpus>
    80001aa6:	953e                	add	a0,a0,a5
    80001aa8:	60a2                	ld	ra,8(sp)
    80001aaa:	6402                	ld	s0,0(sp)
    80001aac:	0141                	addi	sp,sp,16
    80001aae:	8082                	ret

0000000080001ab0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	1000                	addi	s0,sp,32
  push_off();
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	138080e7          	jalr	312(ra) # 80000bf2 <push_off>
    80001ac2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ac4:	2781                	sext.w	a5,a5
    80001ac6:	079e                	slli	a5,a5,0x7
    80001ac8:	0000f717          	auipc	a4,0xf
    80001acc:	13870713          	addi	a4,a4,312 # 80010c00 <pid_lock>
    80001ad0:	97ba                	add	a5,a5,a4
    80001ad2:	7b84                	ld	s1,48(a5)
  pop_off();
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	1be080e7          	jalr	446(ra) # 80000c92 <pop_off>
  return p;
}
    80001adc:	8526                	mv	a0,s1
    80001ade:	60e2                	ld	ra,24(sp)
    80001ae0:	6442                	ld	s0,16(sp)
    80001ae2:	64a2                	ld	s1,8(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ae8:	1141                	addi	sp,sp,-16
    80001aea:	e406                	sd	ra,8(sp)
    80001aec:	e022                	sd	s0,0(sp)
    80001aee:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001af0:	00000097          	auipc	ra,0x0
    80001af4:	fc0080e7          	jalr	-64(ra) # 80001ab0 <myproc>
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f6080e7          	jalr	502(ra) # 80000cee <release>

  if (first)
    80001b00:	00007797          	auipc	a5,0x7
    80001b04:	e007a783          	lw	a5,-512(a5) # 80008900 <first.1>
    80001b08:	eb89                	bnez	a5,80001b1a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b0a:	00001097          	auipc	ra,0x1
    80001b0e:	22a080e7          	jalr	554(ra) # 80002d34 <usertrapret>
}
    80001b12:	60a2                	ld	ra,8(sp)
    80001b14:	6402                	ld	s0,0(sp)
    80001b16:	0141                	addi	sp,sp,16
    80001b18:	8082                	ret
    first = 0;
    80001b1a:	00007797          	auipc	a5,0x7
    80001b1e:	de07a323          	sw	zero,-538(a5) # 80008900 <first.1>
    fsinit(ROOTDEV);
    80001b22:	4505                	li	a0,1
    80001b24:	00002097          	auipc	ra,0x2
    80001b28:	188080e7          	jalr	392(ra) # 80003cac <fsinit>
    80001b2c:	bff9                	j	80001b0a <forkret+0x22>

0000000080001b2e <allocpid>:
{
    80001b2e:	1101                	addi	sp,sp,-32
    80001b30:	ec06                	sd	ra,24(sp)
    80001b32:	e822                	sd	s0,16(sp)
    80001b34:	e426                	sd	s1,8(sp)
    80001b36:	e04a                	sd	s2,0(sp)
    80001b38:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b3a:	0000f917          	auipc	s2,0xf
    80001b3e:	0c690913          	addi	s2,s2,198 # 80010c00 <pid_lock>
    80001b42:	854a                	mv	a0,s2
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	0fa080e7          	jalr	250(ra) # 80000c3e <acquire>
  pid = nextpid;
    80001b4c:	00007797          	auipc	a5,0x7
    80001b50:	dc478793          	addi	a5,a5,-572 # 80008910 <nextpid>
    80001b54:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b56:	0014871b          	addiw	a4,s1,1
    80001b5a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b5c:	854a                	mv	a0,s2
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	190080e7          	jalr	400(ra) # 80000cee <release>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret

0000000080001b74 <proc_pagetable>:
{
    80001b74:	1101                	addi	sp,sp,-32
    80001b76:	ec06                	sd	ra,24(sp)
    80001b78:	e822                	sd	s0,16(sp)
    80001b7a:	e426                	sd	s1,8(sp)
    80001b7c:	e04a                	sd	s2,0(sp)
    80001b7e:	1000                	addi	s0,sp,32
    80001b80:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b82:	00000097          	auipc	ra,0x0
    80001b86:	832080e7          	jalr	-1998(ra) # 800013b4 <uvmcreate>
    80001b8a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b8c:	c121                	beqz	a0,80001bcc <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b8e:	4729                	li	a4,10
    80001b90:	00005697          	auipc	a3,0x5
    80001b94:	47068693          	addi	a3,a3,1136 # 80007000 <_trampoline>
    80001b98:	6605                	lui	a2,0x1
    80001b9a:	040005b7          	lui	a1,0x4000
    80001b9e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ba0:	05b2                	slli	a1,a1,0xc
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	578080e7          	jalr	1400(ra) # 8000111a <mappages>
    80001baa:	02054863          	bltz	a0,80001bda <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bae:	4719                	li	a4,6
    80001bb0:	23093683          	ld	a3,560(s2)
    80001bb4:	6605                	lui	a2,0x1
    80001bb6:	020005b7          	lui	a1,0x2000
    80001bba:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bbc:	05b6                	slli	a1,a1,0xd
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	55a080e7          	jalr	1370(ra) # 8000111a <mappages>
    80001bc8:	02054163          	bltz	a0,80001bea <proc_pagetable+0x76>
}
    80001bcc:	8526                	mv	a0,s1
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6902                	ld	s2,0(sp)
    80001bd6:	6105                	addi	sp,sp,32
    80001bd8:	8082                	ret
    uvmfree(pagetable, 0);
    80001bda:	4581                	li	a1,0
    80001bdc:	8526                	mv	a0,s1
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	9f0080e7          	jalr	-1552(ra) # 800015ce <uvmfree>
    return 0;
    80001be6:	4481                	li	s1,0
    80001be8:	b7d5                	j	80001bcc <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bea:	4681                	li	a3,0
    80001bec:	4605                	li	a2,1
    80001bee:	040005b7          	lui	a1,0x4000
    80001bf2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bf4:	05b2                	slli	a1,a1,0xc
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	6e8080e7          	jalr	1768(ra) # 800012e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c00:	4581                	li	a1,0
    80001c02:	8526                	mv	a0,s1
    80001c04:	00000097          	auipc	ra,0x0
    80001c08:	9ca080e7          	jalr	-1590(ra) # 800015ce <uvmfree>
    return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	bf7d                	j	80001bcc <proc_pagetable+0x58>

0000000080001c10 <proc_freepagetable>:
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	e04a                	sd	s2,0(sp)
    80001c1a:	1000                	addi	s0,sp,32
    80001c1c:	84aa                	mv	s1,a0
    80001c1e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c20:	4681                	li	a3,0
    80001c22:	4605                	li	a2,1
    80001c24:	040005b7          	lui	a1,0x4000
    80001c28:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c2a:	05b2                	slli	a1,a1,0xc
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	6b4080e7          	jalr	1716(ra) # 800012e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c34:	4681                	li	a3,0
    80001c36:	4605                	li	a2,1
    80001c38:	020005b7          	lui	a1,0x2000
    80001c3c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c3e:	05b6                	slli	a1,a1,0xd
    80001c40:	8526                	mv	a0,s1
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	69e080e7          	jalr	1694(ra) # 800012e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c4a:	85ca                	mv	a1,s2
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	00000097          	auipc	ra,0x0
    80001c52:	980080e7          	jalr	-1664(ra) # 800015ce <uvmfree>
}
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret

0000000080001c62 <freeproc>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	1000                	addi	s0,sp,32
    80001c6c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c6e:	23053503          	ld	a0,560(a0)
    80001c72:	c509                	beqz	a0,80001c7c <freeproc+0x1a>
    kfree((void *)p->trapframe);
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	dd8080e7          	jalr	-552(ra) # 80000a4c <kfree>
  p->trapframe = 0;
    80001c7c:	2204b823          	sd	zero,560(s1)
  if (p->pagetable)
    80001c80:	2284b503          	ld	a0,552(s1)
    80001c84:	c519                	beqz	a0,80001c92 <freeproc+0x30>
    proc_freepagetable(p->pagetable, p->sz);
    80001c86:	2204b583          	ld	a1,544(s1)
    80001c8a:	00000097          	auipc	ra,0x0
    80001c8e:	f86080e7          	jalr	-122(ra) # 80001c10 <proc_freepagetable>
  p->pagetable = 0;
    80001c92:	2204b423          	sd	zero,552(s1)
  p->sz = 0;
    80001c96:	2204b023          	sd	zero,544(s1)
  p->pid = 0;
    80001c9a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c9e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ca2:	32048823          	sb	zero,816(s1)
  p->chan = 0;
    80001ca6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001caa:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cb2:	0004ac23          	sw	zero,24(s1)
  for (int x = 0; x <= 26; x++)
    80001cb6:	04048793          	addi	a5,s1,64
    80001cba:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    80001cbe:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    80001cc2:	0791                	addi	a5,a5,4
    80001cc4:	fee79de3          	bne	a5,a4,80001cbe <freeproc+0x5c>
}
    80001cc8:	60e2                	ld	ra,24(sp)
    80001cca:	6442                	ld	s0,16(sp)
    80001ccc:	64a2                	ld	s1,8(sp)
    80001cce:	6105                	addi	sp,sp,32
    80001cd0:	8082                	ret

0000000080001cd2 <allocproc>:
{
    80001cd2:	1101                	addi	sp,sp,-32
    80001cd4:	ec06                	sd	ra,24(sp)
    80001cd6:	e822                	sd	s0,16(sp)
    80001cd8:	e426                	sd	s1,8(sp)
    80001cda:	e04a                	sd	s2,0(sp)
    80001cdc:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001cde:	00010497          	auipc	s1,0x10
    80001ce2:	b6248493          	addi	s1,s1,-1182 # 80011840 <proc>
    80001ce6:	0001d917          	auipc	s2,0x1d
    80001cea:	f5a90913          	addi	s2,s2,-166 # 8001ec40 <tickslock>
    acquire(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	f4e080e7          	jalr	-178(ra) # 80000c3e <acquire>
    if (p->state == UNUSED)
    80001cf8:	4c9c                	lw	a5,24(s1)
    80001cfa:	cf81                	beqz	a5,80001d12 <allocproc+0x40>
      release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	ff0080e7          	jalr	-16(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d06:	35048493          	addi	s1,s1,848
    80001d0a:	ff2492e3          	bne	s1,s2,80001cee <allocproc+0x1c>
  return 0;
    80001d0e:	4481                	li	s1,0
    80001d10:	a859                	j	80001da6 <allocproc+0xd4>
  p->pid = allocpid();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	e1c080e7          	jalr	-484(ra) # 80001b2e <allocpid>
    80001d1a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d1c:	4785                	li	a5,1
    80001d1e:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	e2a080e7          	jalr	-470(ra) # 80000b4a <kalloc>
    80001d28:	892a                	mv	s2,a0
    80001d2a:	22a4b823          	sd	a0,560(s1)
    80001d2e:	c159                	beqz	a0,80001db4 <allocproc+0xe2>
  p->pagetable = proc_pagetable(p);
    80001d30:	8526                	mv	a0,s1
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	e42080e7          	jalr	-446(ra) # 80001b74 <proc_pagetable>
    80001d3a:	892a                	mv	s2,a0
    80001d3c:	22a4b423          	sd	a0,552(s1)
  if (p->pagetable == 0)
    80001d40:	c551                	beqz	a0,80001dcc <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80001d42:	07000613          	li	a2,112
    80001d46:	4581                	li	a1,0
    80001d48:	23848513          	addi	a0,s1,568
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	fea080e7          	jalr	-22(ra) # 80000d36 <memset>
  p->context.ra = (uint64)forkret;
    80001d54:	00000797          	auipc	a5,0x0
    80001d58:	d9478793          	addi	a5,a5,-620 # 80001ae8 <forkret>
    80001d5c:	22f4bc23          	sd	a5,568(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d60:	2184b783          	ld	a5,536(s1)
    80001d64:	6705                	lui	a4,0x1
    80001d66:	97ba                	add	a5,a5,a4
    80001d68:	24f4b023          	sd	a5,576(s1)
  p->rtime = 0;
    80001d6c:	3404a023          	sw	zero,832(s1)
  p->etime = 0;
    80001d70:	3404a423          	sw	zero,840(s1)
  p->ctime = ticks;
    80001d74:	00007797          	auipc	a5,0x7
    80001d78:	c207a783          	lw	a5,-992(a5) # 80008994 <ticks>
    80001d7c:	34f4a223          	sw	a5,836(s1)
  p->tickets = 1;
    80001d80:	4705                	li	a4,1
    80001d82:	0ce4a023          	sw	a4,192(s1)
  p->ticks = 0;
    80001d86:	0e04a023          	sw	zero,224(s1)
  p->arrival_time = ticks;// to add new process in the end;
    80001d8a:	1782                	slli	a5,a5,0x20
    80001d8c:	9381                	srli	a5,a5,0x20
    80001d8e:	e4fc                	sd	a5,200(s1)
  p->priority = 0;
    80001d90:	0c04ac23          	sw	zero,216(s1)
  for (int x = 0; x <= 26; x++)
    80001d94:	04048793          	addi	a5,s1,64
    80001d98:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    80001d9c:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    80001da0:	0791                	addi	a5,a5,4
    80001da2:	fee79de3          	bne	a5,a4,80001d9c <allocproc+0xca>
}
    80001da6:	8526                	mv	a0,s1
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret
    freeproc(p);
    80001db4:	8526                	mv	a0,s1
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	eac080e7          	jalr	-340(ra) # 80001c62 <freeproc>
    release(&p->lock);
    80001dbe:	8526                	mv	a0,s1
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	f2e080e7          	jalr	-210(ra) # 80000cee <release>
    return 0;
    80001dc8:	84ca                	mv	s1,s2
    80001dca:	bff1                	j	80001da6 <allocproc+0xd4>
    freeproc(p);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	e94080e7          	jalr	-364(ra) # 80001c62 <freeproc>
    release(&p->lock);
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	f16080e7          	jalr	-234(ra) # 80000cee <release>
    return 0;
    80001de0:	84ca                	mv	s1,s2
    80001de2:	b7d1                	j	80001da6 <allocproc+0xd4>

0000000080001de4 <userinit>:
{
    80001de4:	1101                	addi	sp,sp,-32
    80001de6:	ec06                	sd	ra,24(sp)
    80001de8:	e822                	sd	s0,16(sp)
    80001dea:	e426                	sd	s1,8(sp)
    80001dec:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	ee4080e7          	jalr	-284(ra) # 80001cd2 <allocproc>
    80001df6:	84aa                	mv	s1,a0
  initproc = p;
    80001df8:	00007797          	auipc	a5,0x7
    80001dfc:	b8a7b823          	sd	a0,-1136(a5) # 80008988 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e00:	03400613          	li	a2,52
    80001e04:	00007597          	auipc	a1,0x7
    80001e08:	b1c58593          	addi	a1,a1,-1252 # 80008920 <initcode>
    80001e0c:	22853503          	ld	a0,552(a0)
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	5d2080e7          	jalr	1490(ra) # 800013e2 <uvmfirst>
  p->sz = PGSIZE;
    80001e18:	6785                	lui	a5,0x1
    80001e1a:	22f4b023          	sd	a5,544(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e1e:	2304b703          	ld	a4,560(s1)
    80001e22:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001e26:	2304b703          	ld	a4,560(s1)
    80001e2a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e2c:	4641                	li	a2,16
    80001e2e:	00006597          	auipc	a1,0x6
    80001e32:	3b258593          	addi	a1,a1,946 # 800081e0 <etext+0x1e0>
    80001e36:	33048513          	addi	a0,s1,816
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	052080e7          	jalr	82(ra) # 80000e8c <safestrcpy>
  p->cwd = namei("/");
    80001e42:	00006517          	auipc	a0,0x6
    80001e46:	3ae50513          	addi	a0,a0,942 # 800081f0 <etext+0x1f0>
    80001e4a:	00003097          	auipc	ra,0x3
    80001e4e:	8ca080e7          	jalr	-1846(ra) # 80004714 <namei>
    80001e52:	32a4b423          	sd	a0,808(s1)
  p->state = RUNNABLE;
    80001e56:	478d                	li	a5,3
    80001e58:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	e92080e7          	jalr	-366(ra) # 80000cee <release>
}
    80001e64:	60e2                	ld	ra,24(sp)
    80001e66:	6442                	ld	s0,16(sp)
    80001e68:	64a2                	ld	s1,8(sp)
    80001e6a:	6105                	addi	sp,sp,32
    80001e6c:	8082                	ret

0000000080001e6e <growproc>:
{
    80001e6e:	1101                	addi	sp,sp,-32
    80001e70:	ec06                	sd	ra,24(sp)
    80001e72:	e822                	sd	s0,16(sp)
    80001e74:	e426                	sd	s1,8(sp)
    80001e76:	e04a                	sd	s2,0(sp)
    80001e78:	1000                	addi	s0,sp,32
    80001e7a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	c34080e7          	jalr	-972(ra) # 80001ab0 <myproc>
    80001e84:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e86:	22053583          	ld	a1,544(a0)
  if (n > 0)
    80001e8a:	01204d63          	bgtz	s2,80001ea4 <growproc+0x36>
  else if (n < 0)
    80001e8e:	02094863          	bltz	s2,80001ebe <growproc+0x50>
  p->sz = sz;
    80001e92:	22b4b023          	sd	a1,544(s1)
  return 0;
    80001e96:	4501                	li	a0,0
}
    80001e98:	60e2                	ld	ra,24(sp)
    80001e9a:	6442                	ld	s0,16(sp)
    80001e9c:	64a2                	ld	s1,8(sp)
    80001e9e:	6902                	ld	s2,0(sp)
    80001ea0:	6105                	addi	sp,sp,32
    80001ea2:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001ea4:	4691                	li	a3,4
    80001ea6:	00b90633          	add	a2,s2,a1
    80001eaa:	22853503          	ld	a0,552(a0)
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	5ee080e7          	jalr	1518(ra) # 8000149c <uvmalloc>
    80001eb6:	85aa                	mv	a1,a0
    80001eb8:	fd69                	bnez	a0,80001e92 <growproc+0x24>
      return -1;
    80001eba:	557d                	li	a0,-1
    80001ebc:	bff1                	j	80001e98 <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ebe:	00b90633          	add	a2,s2,a1
    80001ec2:	22853503          	ld	a0,552(a0)
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	58e080e7          	jalr	1422(ra) # 80001454 <uvmdealloc>
    80001ece:	85aa                	mv	a1,a0
    80001ed0:	b7c9                	j	80001e92 <growproc+0x24>

0000000080001ed2 <fork>:
{
    80001ed2:	7139                	addi	sp,sp,-64
    80001ed4:	fc06                	sd	ra,56(sp)
    80001ed6:	f822                	sd	s0,48(sp)
    80001ed8:	f04a                	sd	s2,32(sp)
    80001eda:	e456                	sd	s5,8(sp)
    80001edc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ede:	00000097          	auipc	ra,0x0
    80001ee2:	bd2080e7          	jalr	-1070(ra) # 80001ab0 <myproc>
    80001ee6:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	dea080e7          	jalr	-534(ra) # 80001cd2 <allocproc>
    80001ef0:	12050563          	beqz	a0,8000201a <fork+0x148>
    80001ef4:	ec4e                	sd	s3,24(sp)
    80001ef6:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001ef8:	220ab603          	ld	a2,544(s5)
    80001efc:	22853583          	ld	a1,552(a0)
    80001f00:	228ab503          	ld	a0,552(s5)
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	704080e7          	jalr	1796(ra) # 80001608 <uvmcopy>
    80001f0c:	04054a63          	bltz	a0,80001f60 <fork+0x8e>
    80001f10:	f426                	sd	s1,40(sp)
    80001f12:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001f14:	220ab783          	ld	a5,544(s5)
    80001f18:	22f9b023          	sd	a5,544(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f1c:	230ab683          	ld	a3,560(s5)
    80001f20:	87b6                	mv	a5,a3
    80001f22:	2309b703          	ld	a4,560(s3)
    80001f26:	12068693          	addi	a3,a3,288
    80001f2a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f2e:	6788                	ld	a0,8(a5)
    80001f30:	6b8c                	ld	a1,16(a5)
    80001f32:	6f90                	ld	a2,24(a5)
    80001f34:	01073023          	sd	a6,0(a4)
    80001f38:	e708                	sd	a0,8(a4)
    80001f3a:	eb0c                	sd	a1,16(a4)
    80001f3c:	ef10                	sd	a2,24(a4)
    80001f3e:	02078793          	addi	a5,a5,32
    80001f42:	02070713          	addi	a4,a4,32
    80001f46:	fed792e3          	bne	a5,a3,80001f2a <fork+0x58>
  np->trapframe->a0 = 0;
    80001f4a:	2309b783          	ld	a5,560(s3)
    80001f4e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001f52:	2a8a8493          	addi	s1,s5,680
    80001f56:	2a898913          	addi	s2,s3,680
    80001f5a:	328a8a13          	addi	s4,s5,808
    80001f5e:	a015                	j	80001f82 <fork+0xb0>
    freeproc(np);
    80001f60:	854e                	mv	a0,s3
    80001f62:	00000097          	auipc	ra,0x0
    80001f66:	d00080e7          	jalr	-768(ra) # 80001c62 <freeproc>
    release(&np->lock);
    80001f6a:	854e                	mv	a0,s3
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	d82080e7          	jalr	-638(ra) # 80000cee <release>
    return -1;
    80001f74:	597d                	li	s2,-1
    80001f76:	69e2                	ld	s3,24(sp)
    80001f78:	a851                	j	8000200c <fork+0x13a>
  for (i = 0; i < NOFILE; i++)
    80001f7a:	04a1                	addi	s1,s1,8
    80001f7c:	0921                	addi	s2,s2,8
    80001f7e:	01448b63          	beq	s1,s4,80001f94 <fork+0xc2>
    if (p->ofile[i])
    80001f82:	6088                	ld	a0,0(s1)
    80001f84:	d97d                	beqz	a0,80001f7a <fork+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f86:	00003097          	auipc	ra,0x3
    80001f8a:	e12080e7          	jalr	-494(ra) # 80004d98 <filedup>
    80001f8e:	00a93023          	sd	a0,0(s2)
    80001f92:	b7e5                	j	80001f7a <fork+0xa8>
  np->cwd = idup(p->cwd);
    80001f94:	328ab503          	ld	a0,808(s5)
    80001f98:	00002097          	auipc	ra,0x2
    80001f9c:	f5a080e7          	jalr	-166(ra) # 80003ef2 <idup>
    80001fa0:	32a9b423          	sd	a0,808(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fa4:	4641                	li	a2,16
    80001fa6:	330a8593          	addi	a1,s5,816
    80001faa:	33098513          	addi	a0,s3,816
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	ede080e7          	jalr	-290(ra) # 80000e8c <safestrcpy>
  np->tickets = p->tickets;
    80001fb6:	0c0aa783          	lw	a5,192(s5)
    80001fba:	0cf9a023          	sw	a5,192(s3)
  pid = np->pid;
    80001fbe:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001fc2:	854e                	mv	a0,s3
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	d2a080e7          	jalr	-726(ra) # 80000cee <release>
  acquire(&wait_lock);
    80001fcc:	0000f497          	auipc	s1,0xf
    80001fd0:	c4c48493          	addi	s1,s1,-948 # 80010c18 <wait_lock>
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	c68080e7          	jalr	-920(ra) # 80000c3e <acquire>
  np->parent = p;
    80001fde:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	d0a080e7          	jalr	-758(ra) # 80000cee <release>
  acquire(&np->lock);
    80001fec:	854e                	mv	a0,s3
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	c50080e7          	jalr	-944(ra) # 80000c3e <acquire>
  np->state = RUNNABLE;
    80001ff6:	478d                	li	a5,3
    80001ff8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ffc:	854e                	mv	a0,s3
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	cf0080e7          	jalr	-784(ra) # 80000cee <release>
  return pid;
    80002006:	74a2                	ld	s1,40(sp)
    80002008:	69e2                	ld	s3,24(sp)
    8000200a:	6a42                	ld	s4,16(sp)
}
    8000200c:	854a                	mv	a0,s2
    8000200e:	70e2                	ld	ra,56(sp)
    80002010:	7442                	ld	s0,48(sp)
    80002012:	7902                	ld	s2,32(sp)
    80002014:	6aa2                	ld	s5,8(sp)
    80002016:	6121                	addi	sp,sp,64
    80002018:	8082                	ret
    return -1;
    8000201a:	597d                	li	s2,-1
    8000201c:	bfc5                	j	8000200c <fork+0x13a>

000000008000201e <get_time_slice>:
{
    8000201e:	1141                	addi	sp,sp,-16
    80002020:	e406                	sd	ra,8(sp)
    80002022:	e022                	sd	s0,0(sp)
    80002024:	0800                	addi	s0,sp,16
  switch (priority)
    80002026:	4709                	li	a4,2
    80002028:	00e50d63          	beq	a0,a4,80002042 <get_time_slice+0x24>
    8000202c:	87aa                	mv	a5,a0
    8000202e:	470d                	li	a4,3
    return 16;
    80002030:	4541                	li	a0,16
  switch (priority)
    80002032:	00e78963          	beq	a5,a4,80002044 <get_time_slice+0x26>
    80002036:	4705                	li	a4,1
    80002038:	4511                	li	a0,4
    8000203a:	00e78563          	beq	a5,a4,80002044 <get_time_slice+0x26>
    return 1;
    8000203e:	853a                	mv	a0,a4
    80002040:	a011                	j	80002044 <get_time_slice+0x26>
    return 8;
    80002042:	4521                	li	a0,8
}
    80002044:	60a2                	ld	ra,8(sp)
    80002046:	6402                	ld	s0,0(sp)
    80002048:	0141                	addi	sp,sp,16
    8000204a:	8082                	ret

000000008000204c <scheduler_mlfq>:
{
    8000204c:	711d                	addi	sp,sp,-96
    8000204e:	ec86                	sd	ra,88(sp)
    80002050:	e8a2                	sd	s0,80(sp)
    80002052:	e4a6                	sd	s1,72(sp)
    80002054:	e0ca                	sd	s2,64(sp)
    80002056:	fc4e                	sd	s3,56(sp)
    80002058:	f852                	sd	s4,48(sp)
    8000205a:	f456                	sd	s5,40(sp)
    8000205c:	f05a                	sd	s6,32(sp)
    8000205e:	ec5e                	sd	s7,24(sp)
    80002060:	e862                	sd	s8,16(sp)
    80002062:	e466                	sd	s9,8(sp)
    80002064:	1080                	addi	s0,sp,96
    80002066:	8792                	mv	a5,tp
  int id = r_tp();
    80002068:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000206a:	00779b93          	slli	s7,a5,0x7
    8000206e:	0000f717          	auipc	a4,0xf
    80002072:	b9270713          	addi	a4,a4,-1134 # 80010c00 <pid_lock>
    80002076:	975e                	add	a4,a4,s7
    80002078:	02073823          	sd	zero,48(a4)
    swtch(&c->context, &selected_proc->context);
    8000207c:	0000f717          	auipc	a4,0xf
    80002080:	bbc70713          	addi	a4,a4,-1092 # 80010c38 <cpus+0x8>
    80002084:	9bba                	add	s7,s7,a4
    if (boost_ticks >= BOOST_INTERVAL)
    80002086:	00007a17          	auipc	s4,0x7
    8000208a:	90aa0a13          	addi	s4,s4,-1782 # 80008990 <boost_ticks>
    for (p = proc; p < &proc[NPROC]; p++)
    8000208e:	0001d917          	auipc	s2,0x1d
    80002092:	bb290913          	addi	s2,s2,-1102 # 8001ec40 <tickslock>
    c->proc = selected_proc;
    80002096:	079e                	slli	a5,a5,0x7
    80002098:	0000fb17          	auipc	s6,0xf
    8000209c:	b68b0b13          	addi	s6,s6,-1176 # 80010c00 <pid_lock>
    800020a0:	9b3e                	add	s6,s6,a5
    800020a2:	aaa9                	j	800021fc <scheduler_mlfq+0x1b0>
      for (p = proc; p < &proc[NPROC]; p++)
    800020a4:	0000f497          	auipc	s1,0xf
    800020a8:	79c48493          	addi	s1,s1,1948 # 80011840 <proc>
            printf("Priority boost to process id %d from priority %d to 0.\n",p->pid,p->priority);
    800020ac:	00006c97          	auipc	s9,0x6
    800020b0:	14cc8c93          	addi	s9,s9,332 # 800081f8 <etext+0x1f8>
          p->arrival_time = ticks;
    800020b4:	00007c17          	auipc	s8,0x7
    800020b8:	8e0c0c13          	addi	s8,s8,-1824 # 80008994 <ticks>
    800020bc:	a00d                	j	800020de <scheduler_mlfq+0x92>
    800020be:	000c6783          	lwu	a5,0(s8)
    800020c2:	e4fc                	sd	a5,200(s1)
          p->ticks=0;
    800020c4:	0e04a023          	sw	zero,224(s1)
          p->priority = 0;
    800020c8:	0c04ac23          	sw	zero,216(s1)
          release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	c20080e7          	jalr	-992(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800020d6:	35048493          	addi	s1,s1,848
    800020da:	03248163          	beq	s1,s2,800020fc <scheduler_mlfq+0xb0>
          acquire(&p->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	b5e080e7          	jalr	-1186(ra) # 80000c3e <acquire>
          if(p->priority!=0)
    800020e8:	0d84a603          	lw	a2,216(s1)
    800020ec:	da69                	beqz	a2,800020be <scheduler_mlfq+0x72>
            printf("Priority boost to process id %d from priority %d to 0.\n",p->pid,p->priority);
    800020ee:	588c                	lw	a1,48(s1)
    800020f0:	8566                	mv	a0,s9
    800020f2:	ffffe097          	auipc	ra,0xffffe
    800020f6:	4b8080e7          	jalr	1208(ra) # 800005aa <printf>
    800020fa:	b7d1                	j	800020be <scheduler_mlfq+0x72>
      boost_ticks = 0;
    800020fc:	000a2023          	sw	zero,0(s4)
    80002100:	aa19                	j	80002216 <scheduler_mlfq+0x1ca>
        if (selected_proc == 0)
    80002102:	cc89                	beqz	s1,8000211c <scheduler_mlfq+0xd0>
        else if (p->priority < min)
    80002104:	0d87a703          	lw	a4,216(a5)
    80002108:	06d74a63          	blt	a4,a3,8000217c <scheduler_mlfq+0x130>
        else if (p->priority == min && p->arrival_time < selected_proc->arrival_time)
    8000210c:	06d71a63          	bne	a4,a3,80002180 <scheduler_mlfq+0x134>
    80002110:	67f0                	ld	a2,200(a5)
    80002112:	64f8                	ld	a4,200(s1)
    80002114:	06e67663          	bgeu	a2,a4,80002180 <scheduler_mlfq+0x134>
          selected_proc = p;
    80002118:	84be                	mv	s1,a5
    8000211a:	a09d                	j	80002180 <scheduler_mlfq+0x134>
          min = selected_proc->priority;
    8000211c:	0d87a683          	lw	a3,216(a5)
          selected_proc = p;
    80002120:	84be                	mv	s1,a5
    80002122:	a8b9                	j	80002180 <scheduler_mlfq+0x134>
      release(&selected_proc->lock);
    80002124:	8526                	mv	a0,s1
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	bc8080e7          	jalr	-1080(ra) # 80000cee <release>
      continue;
    8000212e:	a0f9                	j	800021fc <scheduler_mlfq+0x1b0>
      if (selected_proc->ticks >= time_slice)
    80002130:	0e04ac03          	lw	s8,224(s1)
    int time_slice = get_time_slice(selected_proc->priority);
    80002134:	8556                	mv	a0,s5
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	ee8080e7          	jalr	-280(ra) # 8000201e <get_time_slice>
      if (selected_proc->ticks >= time_slice)
    8000213e:	0aac4363          	blt	s8,a0,800021e4 <scheduler_mlfq+0x198>
        if (selected_proc->priority < MAX_PRIORITY)
    80002142:	0d84a683          	lw	a3,216(s1)
    80002146:	4789                	li	a5,2
    80002148:	08d7ce63          	blt	a5,a3,800021e4 <scheduler_mlfq+0x198>
          printf("Process with pid %d priority id decreased to %d from %d\n",selected_proc->pid, selected_proc->priority+1,selected_proc->priority);
    8000214c:	0016861b          	addiw	a2,a3,1
    80002150:	588c                	lw	a1,48(s1)
    80002152:	00006517          	auipc	a0,0x6
    80002156:	0fe50513          	addi	a0,a0,254 # 80008250 <etext+0x250>
    8000215a:	ffffe097          	auipc	ra,0xffffe
    8000215e:	450080e7          	jalr	1104(ra) # 800005aa <printf>
          selected_proc->priority++;
    80002162:	0d84a783          	lw	a5,216(s1)
    80002166:	2785                	addiw	a5,a5,1
    80002168:	0cf4ac23          	sw	a5,216(s1)
          selected_proc->arrival_time=ticks;
    8000216c:	00007797          	auipc	a5,0x7
    80002170:	8287e783          	lwu	a5,-2008(a5) # 80008994 <ticks>
    80002174:	e4fc                	sd	a5,200(s1)
          selected_proc->ticks = 0;
    80002176:	0e04a023          	sw	zero,224(s1)
    8000217a:	a0ad                	j	800021e4 <scheduler_mlfq+0x198>
          min = selected_proc->priority;
    8000217c:	86ba                	mv	a3,a4
          selected_proc = p;
    8000217e:	84be                	mv	s1,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002180:	35078793          	addi	a5,a5,848
    80002184:	01278a63          	beq	a5,s2,80002198 <scheduler_mlfq+0x14c>
      if (p->state == RUNNABLE)
    80002188:	4f98                	lw	a4,24(a5)
    8000218a:	f7370ce3          	beq	a4,s3,80002102 <scheduler_mlfq+0xb6>
    for (p = proc; p < &proc[NPROC]; p++)
    8000218e:	35078793          	addi	a5,a5,848
    80002192:	ff279be3          	bne	a5,s2,80002188 <scheduler_mlfq+0x13c>
    if (!selected_proc)
    80002196:	c4b5                	beqz	s1,80002202 <scheduler_mlfq+0x1b6>
    acquire(&selected_proc->lock);
    80002198:	89a6                	mv	s3,s1
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	aa2080e7          	jalr	-1374(ra) # 80000c3e <acquire>
    if (selected_proc->state != RUNNABLE)
    800021a4:	4c98                	lw	a4,24(s1)
    800021a6:	478d                	li	a5,3
    800021a8:	f6f71ee3          	bne	a4,a5,80002124 <scheduler_mlfq+0xd8>
    selected_proc->state = RUNNING;
    800021ac:	4791                	li	a5,4
    800021ae:	cc9c                	sw	a5,24(s1)
    c->proc = selected_proc;
    800021b0:	029b3823          	sd	s1,48(s6)
    printf("Process %d has priority %d\n", selected_proc->pid, selected_proc->priority);
    800021b4:	0d84a603          	lw	a2,216(s1)
    800021b8:	588c                	lw	a1,48(s1)
    800021ba:	00006517          	auipc	a0,0x6
    800021be:	07650513          	addi	a0,a0,118 # 80008230 <etext+0x230>
    800021c2:	ffffe097          	auipc	ra,0xffffe
    800021c6:	3e8080e7          	jalr	1000(ra) # 800005aa <printf>
    int time_slice = get_time_slice(selected_proc->priority);
    800021ca:	0d84aa83          	lw	s5,216(s1)
    swtch(&c->context, &selected_proc->context);
    800021ce:	23848593          	addi	a1,s1,568
    800021d2:	855e                	mv	a0,s7
    800021d4:	00001097          	auipc	ra,0x1
    800021d8:	ab2080e7          	jalr	-1358(ra) # 80002c86 <swtch>
    if (selected_proc->state == RUNNABLE)
    800021dc:	4c98                	lw	a4,24(s1)
    800021de:	478d                	li	a5,3
    800021e0:	f4f708e3          	beq	a4,a5,80002130 <scheduler_mlfq+0xe4>
    c->proc = 0;
    800021e4:	020b3823          	sd	zero,48(s6)
    release(&selected_proc->lock);
    800021e8:	854e                	mv	a0,s3
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	b04080e7          	jalr	-1276(ra) # 80000cee <release>
    boost_ticks++;
    800021f2:	000a2783          	lw	a5,0(s4)
    800021f6:	2785                	addiw	a5,a5,1
    800021f8:	00fa2023          	sw	a5,0(s4)
    if (boost_ticks >= BOOST_INTERVAL)
    800021fc:	02f00a93          	li	s5,47
    int min=3;
    80002200:	498d                	li	s3,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002202:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002206:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000220a:	10079073          	csrw	sstatus,a5
    if (boost_ticks >= BOOST_INTERVAL)
    8000220e:	000a2783          	lw	a5,0(s4)
    80002212:	e8fac9e3          	blt	s5,a5,800020a4 <scheduler_mlfq+0x58>
    int min=3;
    80002216:	86ce                	mv	a3,s3
    struct proc *selected_proc = 0;
    80002218:	4481                	li	s1,0
    for (p = proc; p < &proc[NPROC]; p++)
    8000221a:	0000f797          	auipc	a5,0xf
    8000221e:	62678793          	addi	a5,a5,1574 # 80011840 <proc>
    80002222:	b79d                	j	80002188 <scheduler_mlfq+0x13c>

0000000080002224 <scheduler_rr>:
{
    80002224:	7139                	addi	sp,sp,-64
    80002226:	fc06                	sd	ra,56(sp)
    80002228:	f822                	sd	s0,48(sp)
    8000222a:	f426                	sd	s1,40(sp)
    8000222c:	f04a                	sd	s2,32(sp)
    8000222e:	ec4e                	sd	s3,24(sp)
    80002230:	e852                	sd	s4,16(sp)
    80002232:	e456                	sd	s5,8(sp)
    80002234:	e05a                	sd	s6,0(sp)
    80002236:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    80002238:	8792                	mv	a5,tp
  int id = r_tp();
    8000223a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000223c:	00779a93          	slli	s5,a5,0x7
    80002240:	0000f717          	auipc	a4,0xf
    80002244:	9c070713          	addi	a4,a4,-1600 # 80010c00 <pid_lock>
    80002248:	9756                	add	a4,a4,s5
    8000224a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000224e:	0000f717          	auipc	a4,0xf
    80002252:	9ea70713          	addi	a4,a4,-1558 # 80010c38 <cpus+0x8>
    80002256:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80002258:	498d                	li	s3,3
        p->state = RUNNING;
    8000225a:	4b11                	li	s6,4
        c->proc = p;
    8000225c:	079e                	slli	a5,a5,0x7
    8000225e:	0000fa17          	auipc	s4,0xf
    80002262:	9a2a0a13          	addi	s4,s4,-1630 # 80010c00 <pid_lock>
    80002266:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002268:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000226c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002270:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002274:	0000f497          	auipc	s1,0xf
    80002278:	5cc48493          	addi	s1,s1,1484 # 80011840 <proc>
    8000227c:	0001d917          	auipc	s2,0x1d
    80002280:	9c490913          	addi	s2,s2,-1596 # 8001ec40 <tickslock>
    80002284:	a811                	j	80002298 <scheduler_rr+0x74>
      release(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a66080e7          	jalr	-1434(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002290:	35048493          	addi	s1,s1,848
    80002294:	fd248ae3          	beq	s1,s2,80002268 <scheduler_rr+0x44>
      acquire(&p->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	9a4080e7          	jalr	-1628(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    800022a2:	4c9c                	lw	a5,24(s1)
    800022a4:	ff3791e3          	bne	a5,s3,80002286 <scheduler_rr+0x62>
        p->state = RUNNING;
    800022a8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800022ac:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800022b0:	23848593          	addi	a1,s1,568
    800022b4:	8556                	mv	a0,s5
    800022b6:	00001097          	auipc	ra,0x1
    800022ba:	9d0080e7          	jalr	-1584(ra) # 80002c86 <swtch>
        c->proc = 0;
    800022be:	020a3823          	sd	zero,48(s4)
    800022c2:	b7d1                	j	80002286 <scheduler_rr+0x62>

00000000800022c4 <scheduler_lottery>:
{
    800022c4:	715d                	addi	sp,sp,-80
    800022c6:	e486                	sd	ra,72(sp)
    800022c8:	e0a2                	sd	s0,64(sp)
    800022ca:	fc26                	sd	s1,56(sp)
    800022cc:	f84a                	sd	s2,48(sp)
    800022ce:	f44e                	sd	s3,40(sp)
    800022d0:	f052                	sd	s4,32(sp)
    800022d2:	ec56                	sd	s5,24(sp)
    800022d4:	e85a                	sd	s6,16(sp)
    800022d6:	e45e                	sd	s7,8(sp)
    800022d8:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    800022da:	8792                	mv	a5,tp
  int id = r_tp();
    800022dc:	2781                	sext.w	a5,a5
  c->proc = 0;
    800022de:	00779693          	slli	a3,a5,0x7
    800022e2:	0000f717          	auipc	a4,0xf
    800022e6:	91e70713          	addi	a4,a4,-1762 # 80010c00 <pid_lock>
    800022ea:	9736                	add	a4,a4,a3
    800022ec:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &selected_proc->context);
    800022f0:	0000f717          	auipc	a4,0xf
    800022f4:	94870713          	addi	a4,a4,-1720 # 80010c38 <cpus+0x8>
    800022f8:	9736                	add	a4,a4,a3
    800022fa:	8bba                	mv	s7,a4
      if (p->state == RUNNABLE)
    800022fc:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    800022fe:	0001d917          	auipc	s2,0x1d
    80002302:	94290913          	addi	s2,s2,-1726 # 8001ec40 <tickslock>
        c->proc = selected_proc;
    80002306:	0000fa97          	auipc	s5,0xf
    8000230a:	8faa8a93          	addi	s5,s5,-1798 # 80010c00 <pid_lock>
    8000230e:	9ab6                	add	s5,s5,a3
    80002310:	a80d                	j	80002342 <scheduler_lottery+0x7e>
      release(&p->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	9da080e7          	jalr	-1574(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000231c:	35048493          	addi	s1,s1,848
    80002320:	01248f63          	beq	s1,s2,8000233e <scheduler_lottery+0x7a>
      acquire(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	918080e7          	jalr	-1768(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    8000232e:	4c9c                	lw	a5,24(s1)
    80002330:	ff3791e3          	bne	a5,s3,80002312 <scheduler_lottery+0x4e>
        total_tickets += p->tickets;
    80002334:	0c04a783          	lw	a5,192(s1)
    80002338:	01678b3b          	addw	s6,a5,s6
    8000233c:	bfd9                	j	80002312 <scheduler_lottery+0x4e>
    if (total_tickets == 0)
    8000233e:	000b1e63          	bnez	s6,8000235a <scheduler_lottery+0x96>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002342:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002346:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000234a:	10079073          	csrw	sstatus,a5
    total_tickets = 0;
    8000234e:	4b01                	li	s6,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002350:	0000f497          	auipc	s1,0xf
    80002354:	4f048493          	addi	s1,s1,1264 # 80011840 <proc>
    80002358:	b7f1                	j	80002324 <scheduler_lottery+0x60>
    int winning_ticket = rand() % total_tickets;
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	61e080e7          	jalr	1566(ra) # 80001978 <rand>
    80002362:	03657b33          	remu	s6,a0,s6
    80002366:	2b01                	sext.w	s6,s6
    int current_ticket = 0;
    80002368:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    8000236a:	0000f497          	auipc	s1,0xf
    8000236e:	4d648493          	addi	s1,s1,1238 # 80011840 <proc>
    80002372:	a811                	j	80002386 <scheduler_lottery+0xc2>
      release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	978080e7          	jalr	-1672(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000237e:	35048493          	addi	s1,s1,848
    80002382:	fd2480e3          	beq	s1,s2,80002342 <scheduler_lottery+0x7e>
      acquire(&p->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	8b6080e7          	jalr	-1866(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    80002390:	4c9c                	lw	a5,24(s1)
    80002392:	ff3791e3          	bne	a5,s3,80002374 <scheduler_lottery+0xb0>
        current_ticket += p->tickets;
    80002396:	0c04a783          	lw	a5,192(s1)
    8000239a:	01478a3b          	addw	s4,a5,s4
        if (current_ticket > winning_ticket)
    8000239e:	fd4b5be3          	bge	s6,s4,80002374 <scheduler_lottery+0xb0>
          release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	94a080e7          	jalr	-1718(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800023ac:	0000fa17          	auipc	s4,0xf
    800023b0:	494a0a13          	addi	s4,s4,1172 # 80011840 <proc>
    800023b4:	a811                	j	800023c8 <scheduler_lottery+0x104>
          release(&p->lock);
    800023b6:	8552                	mv	a0,s4
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	936080e7          	jalr	-1738(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800023c0:	350a0a13          	addi	s4,s4,848
    800023c4:	032a0a63          	beq	s4,s2,800023f8 <scheduler_lottery+0x134>
        if (p != selected_proc)
    800023c8:	fe9a0ce3          	beq	s4,s1,800023c0 <scheduler_lottery+0xfc>
          acquire(&p->lock);
    800023cc:	8552                	mv	a0,s4
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	870080e7          	jalr	-1936(ra) # 80000c3e <acquire>
          if (p->state == RUNNABLE && p->tickets == selected_proc->tickets && p->arrival_time < selected_proc->arrival_time)
    800023d6:	018a2783          	lw	a5,24(s4)
    800023da:	fd379ee3          	bne	a5,s3,800023b6 <scheduler_lottery+0xf2>
    800023de:	0c0a2703          	lw	a4,192(s4)
    800023e2:	0c04a783          	lw	a5,192(s1)
    800023e6:	fcf718e3          	bne	a4,a5,800023b6 <scheduler_lottery+0xf2>
    800023ea:	0c8a3703          	ld	a4,200(s4)
    800023ee:	64fc                	ld	a5,200(s1)
    800023f0:	fcf773e3          	bgeu	a4,a5,800023b6 <scheduler_lottery+0xf2>
            selected_proc = p;
    800023f4:	84d2                	mv	s1,s4
    800023f6:	b7c1                	j	800023b6 <scheduler_lottery+0xf2>
      acquire(&selected_proc->lock);
    800023f8:	8a26                	mv	s4,s1
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	842080e7          	jalr	-1982(ra) # 80000c3e <acquire>
      if (selected_proc->state == RUNNABLE)
    80002404:	4c9c                	lw	a5,24(s1)
    80002406:	01378863          	beq	a5,s3,80002416 <scheduler_lottery+0x152>
      release(&selected_proc->lock);
    8000240a:	8552                	mv	a0,s4
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	8e2080e7          	jalr	-1822(ra) # 80000cee <release>
    80002414:	b73d                	j	80002342 <scheduler_lottery+0x7e>
        selected_proc->state = RUNNING;
    80002416:	4791                	li	a5,4
    80002418:	cc9c                	sw	a5,24(s1)
        c->proc = selected_proc;
    8000241a:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &selected_proc->context);
    8000241e:	23848593          	addi	a1,s1,568
    80002422:	855e                	mv	a0,s7
    80002424:	00001097          	auipc	ra,0x1
    80002428:	862080e7          	jalr	-1950(ra) # 80002c86 <swtch>
        c->proc = 0;
    8000242c:	020ab823          	sd	zero,48(s5)
    80002430:	bfe9                	j	8000240a <scheduler_lottery+0x146>

0000000080002432 <scheduler>:
{
    80002432:	1141                	addi	sp,sp,-16
    80002434:	e406                	sd	ra,8(sp)
    80002436:	e022                	sd	s0,0(sp)
    80002438:	0800                	addi	s0,sp,16
      scheduler_rr();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	dea080e7          	jalr	-534(ra) # 80002224 <scheduler_rr>

0000000080002442 <sched>:
{
    80002442:	7179                	addi	sp,sp,-48
    80002444:	f406                	sd	ra,40(sp)
    80002446:	f022                	sd	s0,32(sp)
    80002448:	ec26                	sd	s1,24(sp)
    8000244a:	e84a                	sd	s2,16(sp)
    8000244c:	e44e                	sd	s3,8(sp)
    8000244e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	660080e7          	jalr	1632(ra) # 80001ab0 <myproc>
    80002458:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	76a080e7          	jalr	1898(ra) # 80000bc4 <holding>
    80002462:	c93d                	beqz	a0,800024d8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002464:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002466:	2781                	sext.w	a5,a5
    80002468:	079e                	slli	a5,a5,0x7
    8000246a:	0000e717          	auipc	a4,0xe
    8000246e:	79670713          	addi	a4,a4,1942 # 80010c00 <pid_lock>
    80002472:	97ba                	add	a5,a5,a4
    80002474:	0a87a703          	lw	a4,168(a5)
    80002478:	4785                	li	a5,1
    8000247a:	06f71763          	bne	a4,a5,800024e8 <sched+0xa6>
  if (p->state == RUNNING)
    8000247e:	4c98                	lw	a4,24(s1)
    80002480:	4791                	li	a5,4
    80002482:	06f70b63          	beq	a4,a5,800024f8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002486:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000248a:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000248c:	efb5                	bnez	a5,80002508 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000248e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002490:	0000e917          	auipc	s2,0xe
    80002494:	77090913          	addi	s2,s2,1904 # 80010c00 <pid_lock>
    80002498:	2781                	sext.w	a5,a5
    8000249a:	079e                	slli	a5,a5,0x7
    8000249c:	97ca                	add	a5,a5,s2
    8000249e:	0ac7a983          	lw	s3,172(a5)
    800024a2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800024a4:	2781                	sext.w	a5,a5
    800024a6:	079e                	slli	a5,a5,0x7
    800024a8:	0000e597          	auipc	a1,0xe
    800024ac:	79058593          	addi	a1,a1,1936 # 80010c38 <cpus+0x8>
    800024b0:	95be                	add	a1,a1,a5
    800024b2:	23848513          	addi	a0,s1,568
    800024b6:	00000097          	auipc	ra,0x0
    800024ba:	7d0080e7          	jalr	2000(ra) # 80002c86 <swtch>
    800024be:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024c0:	2781                	sext.w	a5,a5
    800024c2:	079e                	slli	a5,a5,0x7
    800024c4:	993e                	add	s2,s2,a5
    800024c6:	0b392623          	sw	s3,172(s2)
}
    800024ca:	70a2                	ld	ra,40(sp)
    800024cc:	7402                	ld	s0,32(sp)
    800024ce:	64e2                	ld	s1,24(sp)
    800024d0:	6942                	ld	s2,16(sp)
    800024d2:	69a2                	ld	s3,8(sp)
    800024d4:	6145                	addi	sp,sp,48
    800024d6:	8082                	ret
    panic("sched p->lock");
    800024d8:	00006517          	auipc	a0,0x6
    800024dc:	db850513          	addi	a0,a0,-584 # 80008290 <etext+0x290>
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	080080e7          	jalr	128(ra) # 80000560 <panic>
    panic("sched locks");
    800024e8:	00006517          	auipc	a0,0x6
    800024ec:	db850513          	addi	a0,a0,-584 # 800082a0 <etext+0x2a0>
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	070080e7          	jalr	112(ra) # 80000560 <panic>
    panic("sched running");
    800024f8:	00006517          	auipc	a0,0x6
    800024fc:	db850513          	addi	a0,a0,-584 # 800082b0 <etext+0x2b0>
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	060080e7          	jalr	96(ra) # 80000560 <panic>
    panic("sched interruptible");
    80002508:	00006517          	auipc	a0,0x6
    8000250c:	db850513          	addi	a0,a0,-584 # 800082c0 <etext+0x2c0>
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	050080e7          	jalr	80(ra) # 80000560 <panic>

0000000080002518 <yield>:
{
    80002518:	1101                	addi	sp,sp,-32
    8000251a:	ec06                	sd	ra,24(sp)
    8000251c:	e822                	sd	s0,16(sp)
    8000251e:	e426                	sd	s1,8(sp)
    80002520:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	58e080e7          	jalr	1422(ra) # 80001ab0 <myproc>
    8000252a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	712080e7          	jalr	1810(ra) # 80000c3e <acquire>
  p->state = RUNNABLE;
    80002534:	478d                	li	a5,3
    80002536:	cc9c                	sw	a5,24(s1)
  sched();
    80002538:	00000097          	auipc	ra,0x0
    8000253c:	f0a080e7          	jalr	-246(ra) # 80002442 <sched>
  release(&p->lock);
    80002540:	8526                	mv	a0,s1
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	7ac080e7          	jalr	1964(ra) # 80000cee <release>
}
    8000254a:	60e2                	ld	ra,24(sp)
    8000254c:	6442                	ld	s0,16(sp)
    8000254e:	64a2                	ld	s1,8(sp)
    80002550:	6105                	addi	sp,sp,32
    80002552:	8082                	ret

0000000080002554 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002554:	7179                	addi	sp,sp,-48
    80002556:	f406                	sd	ra,40(sp)
    80002558:	f022                	sd	s0,32(sp)
    8000255a:	ec26                	sd	s1,24(sp)
    8000255c:	e84a                	sd	s2,16(sp)
    8000255e:	e44e                	sd	s3,8(sp)
    80002560:	1800                	addi	s0,sp,48
    80002562:	89aa                	mv	s3,a0
    80002564:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	54a080e7          	jalr	1354(ra) # 80001ab0 <myproc>
    8000256e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	6ce080e7          	jalr	1742(ra) # 80000c3e <acquire>
  release(lk);
    80002578:	854a                	mv	a0,s2
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	774080e7          	jalr	1908(ra) # 80000cee <release>

  // Go to sleep.
  p->chan = chan;
    80002582:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002586:	4789                	li	a5,2
    80002588:	cc9c                	sw	a5,24(s1)

  sched();
    8000258a:	00000097          	auipc	ra,0x0
    8000258e:	eb8080e7          	jalr	-328(ra) # 80002442 <sched>

  // Tidy up.
  p->chan = 0;
    80002592:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002596:	8526                	mv	a0,s1
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	756080e7          	jalr	1878(ra) # 80000cee <release>
  acquire(lk);
    800025a0:	854a                	mv	a0,s2
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	69c080e7          	jalr	1692(ra) # 80000c3e <acquire>
}
    800025aa:	70a2                	ld	ra,40(sp)
    800025ac:	7402                	ld	s0,32(sp)
    800025ae:	64e2                	ld	s1,24(sp)
    800025b0:	6942                	ld	s2,16(sp)
    800025b2:	69a2                	ld	s3,8(sp)
    800025b4:	6145                	addi	sp,sp,48
    800025b6:	8082                	ret

00000000800025b8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800025b8:	7139                	addi	sp,sp,-64
    800025ba:	fc06                	sd	ra,56(sp)
    800025bc:	f822                	sd	s0,48(sp)
    800025be:	f426                	sd	s1,40(sp)
    800025c0:	f04a                	sd	s2,32(sp)
    800025c2:	ec4e                	sd	s3,24(sp)
    800025c4:	e852                	sd	s4,16(sp)
    800025c6:	e456                	sd	s5,8(sp)
    800025c8:	0080                	addi	s0,sp,64
    800025ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800025cc:	0000f497          	auipc	s1,0xf
    800025d0:	27448493          	addi	s1,s1,628 # 80011840 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800025d4:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800025d6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800025d8:	0001c917          	auipc	s2,0x1c
    800025dc:	66890913          	addi	s2,s2,1640 # 8001ec40 <tickslock>
    800025e0:	a811                	j	800025f4 <wakeup+0x3c>
      }
      release(&p->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	70a080e7          	jalr	1802(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025ec:	35048493          	addi	s1,s1,848
    800025f0:	03248663          	beq	s1,s2,8000261c <wakeup+0x64>
    if (p != myproc())
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	4bc080e7          	jalr	1212(ra) # 80001ab0 <myproc>
    800025fc:	fea488e3          	beq	s1,a0,800025ec <wakeup+0x34>
      acquire(&p->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	63c080e7          	jalr	1596(ra) # 80000c3e <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000260a:	4c9c                	lw	a5,24(s1)
    8000260c:	fd379be3          	bne	a5,s3,800025e2 <wakeup+0x2a>
    80002610:	709c                	ld	a5,32(s1)
    80002612:	fd4798e3          	bne	a5,s4,800025e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002616:	0154ac23          	sw	s5,24(s1)
    8000261a:	b7e1                	j	800025e2 <wakeup+0x2a>
    }
  }
}
    8000261c:	70e2                	ld	ra,56(sp)
    8000261e:	7442                	ld	s0,48(sp)
    80002620:	74a2                	ld	s1,40(sp)
    80002622:	7902                	ld	s2,32(sp)
    80002624:	69e2                	ld	s3,24(sp)
    80002626:	6a42                	ld	s4,16(sp)
    80002628:	6aa2                	ld	s5,8(sp)
    8000262a:	6121                	addi	sp,sp,64
    8000262c:	8082                	ret

000000008000262e <reparent>:
{
    8000262e:	7179                	addi	sp,sp,-48
    80002630:	f406                	sd	ra,40(sp)
    80002632:	f022                	sd	s0,32(sp)
    80002634:	ec26                	sd	s1,24(sp)
    80002636:	e84a                	sd	s2,16(sp)
    80002638:	e44e                	sd	s3,8(sp)
    8000263a:	e052                	sd	s4,0(sp)
    8000263c:	1800                	addi	s0,sp,48
    8000263e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002640:	0000f497          	auipc	s1,0xf
    80002644:	20048493          	addi	s1,s1,512 # 80011840 <proc>
      pp->parent = initproc;
    80002648:	00006a17          	auipc	s4,0x6
    8000264c:	340a0a13          	addi	s4,s4,832 # 80008988 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002650:	0001c997          	auipc	s3,0x1c
    80002654:	5f098993          	addi	s3,s3,1520 # 8001ec40 <tickslock>
    80002658:	a029                	j	80002662 <reparent+0x34>
    8000265a:	35048493          	addi	s1,s1,848
    8000265e:	01348d63          	beq	s1,s3,80002678 <reparent+0x4a>
    if (pp->parent == p)
    80002662:	7c9c                	ld	a5,56(s1)
    80002664:	ff279be3          	bne	a5,s2,8000265a <reparent+0x2c>
      pp->parent = initproc;
    80002668:	000a3503          	ld	a0,0(s4)
    8000266c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000266e:	00000097          	auipc	ra,0x0
    80002672:	f4a080e7          	jalr	-182(ra) # 800025b8 <wakeup>
    80002676:	b7d5                	j	8000265a <reparent+0x2c>
}
    80002678:	70a2                	ld	ra,40(sp)
    8000267a:	7402                	ld	s0,32(sp)
    8000267c:	64e2                	ld	s1,24(sp)
    8000267e:	6942                	ld	s2,16(sp)
    80002680:	69a2                	ld	s3,8(sp)
    80002682:	6a02                	ld	s4,0(sp)
    80002684:	6145                	addi	sp,sp,48
    80002686:	8082                	ret

0000000080002688 <exit>:
{
    80002688:	7179                	addi	sp,sp,-48
    8000268a:	f406                	sd	ra,40(sp)
    8000268c:	f022                	sd	s0,32(sp)
    8000268e:	ec26                	sd	s1,24(sp)
    80002690:	e84a                	sd	s2,16(sp)
    80002692:	e44e                	sd	s3,8(sp)
    80002694:	e052                	sd	s4,0(sp)
    80002696:	1800                	addi	s0,sp,48
    80002698:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000269a:	fffff097          	auipc	ra,0xfffff
    8000269e:	416080e7          	jalr	1046(ra) # 80001ab0 <myproc>
    800026a2:	89aa                	mv	s3,a0
  if (p == initproc)
    800026a4:	00006797          	auipc	a5,0x6
    800026a8:	2e47b783          	ld	a5,740(a5) # 80008988 <initproc>
    800026ac:	2a850493          	addi	s1,a0,680
    800026b0:	32850913          	addi	s2,a0,808
    800026b4:	00a79d63          	bne	a5,a0,800026ce <exit+0x46>
    panic("init exiting");
    800026b8:	00006517          	auipc	a0,0x6
    800026bc:	c2050513          	addi	a0,a0,-992 # 800082d8 <etext+0x2d8>
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	ea0080e7          	jalr	-352(ra) # 80000560 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    800026c8:	04a1                	addi	s1,s1,8
    800026ca:	01248b63          	beq	s1,s2,800026e0 <exit+0x58>
    if (p->ofile[fd])
    800026ce:	6088                	ld	a0,0(s1)
    800026d0:	dd65                	beqz	a0,800026c8 <exit+0x40>
      fileclose(f);
    800026d2:	00002097          	auipc	ra,0x2
    800026d6:	718080e7          	jalr	1816(ra) # 80004dea <fileclose>
      p->ofile[fd] = 0;
    800026da:	0004b023          	sd	zero,0(s1)
    800026de:	b7ed                	j	800026c8 <exit+0x40>
  begin_op();
    800026e0:	00002097          	auipc	ra,0x2
    800026e4:	23a080e7          	jalr	570(ra) # 8000491a <begin_op>
  iput(p->cwd);
    800026e8:	3289b503          	ld	a0,808(s3)
    800026ec:	00002097          	auipc	ra,0x2
    800026f0:	a02080e7          	jalr	-1534(ra) # 800040ee <iput>
  end_op();
    800026f4:	00002097          	auipc	ra,0x2
    800026f8:	2a0080e7          	jalr	672(ra) # 80004994 <end_op>
  p->cwd = 0;
    800026fc:	3209b423          	sd	zero,808(s3)
  acquire(&wait_lock);
    80002700:	0000e497          	auipc	s1,0xe
    80002704:	51848493          	addi	s1,s1,1304 # 80010c18 <wait_lock>
    80002708:	8526                	mv	a0,s1
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	534080e7          	jalr	1332(ra) # 80000c3e <acquire>
  reparent(p);
    80002712:	854e                	mv	a0,s3
    80002714:	00000097          	auipc	ra,0x0
    80002718:	f1a080e7          	jalr	-230(ra) # 8000262e <reparent>
  wakeup(p->parent);
    8000271c:	0389b503          	ld	a0,56(s3)
    80002720:	00000097          	auipc	ra,0x0
    80002724:	e98080e7          	jalr	-360(ra) # 800025b8 <wakeup>
  acquire(&p->lock);
    80002728:	854e                	mv	a0,s3
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	514080e7          	jalr	1300(ra) # 80000c3e <acquire>
  p->xstate = status;
    80002732:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002736:	4795                	li	a5,5
    80002738:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000273c:	00006797          	auipc	a5,0x6
    80002740:	2587a783          	lw	a5,600(a5) # 80008994 <ticks>
    80002744:	34f9a423          	sw	a5,840(s3)
  release(&wait_lock);
    80002748:	8526                	mv	a0,s1
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	5a4080e7          	jalr	1444(ra) # 80000cee <release>
  sched();
    80002752:	00000097          	auipc	ra,0x0
    80002756:	cf0080e7          	jalr	-784(ra) # 80002442 <sched>
  panic("zombie exit");
    8000275a:	00006517          	auipc	a0,0x6
    8000275e:	b8e50513          	addi	a0,a0,-1138 # 800082e8 <etext+0x2e8>
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	dfe080e7          	jalr	-514(ra) # 80000560 <panic>

000000008000276a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000276a:	7179                	addi	sp,sp,-48
    8000276c:	f406                	sd	ra,40(sp)
    8000276e:	f022                	sd	s0,32(sp)
    80002770:	ec26                	sd	s1,24(sp)
    80002772:	e84a                	sd	s2,16(sp)
    80002774:	e44e                	sd	s3,8(sp)
    80002776:	1800                	addi	s0,sp,48
    80002778:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000277a:	0000f497          	auipc	s1,0xf
    8000277e:	0c648493          	addi	s1,s1,198 # 80011840 <proc>
    80002782:	0001c997          	auipc	s3,0x1c
    80002786:	4be98993          	addi	s3,s3,1214 # 8001ec40 <tickslock>
  {
    acquire(&p->lock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	4b2080e7          	jalr	1202(ra) # 80000c3e <acquire>
    if (p->pid == pid)
    80002794:	589c                	lw	a5,48(s1)
    80002796:	01278d63          	beq	a5,s2,800027b0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	552080e7          	jalr	1362(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027a4:	35048493          	addi	s1,s1,848
    800027a8:	ff3491e3          	bne	s1,s3,8000278a <kill+0x20>
  }
  return -1;
    800027ac:	557d                	li	a0,-1
    800027ae:	a829                	j	800027c8 <kill+0x5e>
      p->killed = 1;
    800027b0:	4785                	li	a5,1
    800027b2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800027b4:	4c98                	lw	a4,24(s1)
    800027b6:	4789                	li	a5,2
    800027b8:	00f70f63          	beq	a4,a5,800027d6 <kill+0x6c>
      release(&p->lock);
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	530080e7          	jalr	1328(ra) # 80000cee <release>
      return 0;
    800027c6:	4501                	li	a0,0
}
    800027c8:	70a2                	ld	ra,40(sp)
    800027ca:	7402                	ld	s0,32(sp)
    800027cc:	64e2                	ld	s1,24(sp)
    800027ce:	6942                	ld	s2,16(sp)
    800027d0:	69a2                	ld	s3,8(sp)
    800027d2:	6145                	addi	sp,sp,48
    800027d4:	8082                	ret
        p->state = RUNNABLE;
    800027d6:	478d                	li	a5,3
    800027d8:	cc9c                	sw	a5,24(s1)
    800027da:	b7cd                	j	800027bc <kill+0x52>

00000000800027dc <setkilled>:

void setkilled(struct proc *p)
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	456080e7          	jalr	1110(ra) # 80000c3e <acquire>
  p->killed = 1;
    800027f0:	4785                	li	a5,1
    800027f2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	4f8080e7          	jalr	1272(ra) # 80000cee <release>
}
    800027fe:	60e2                	ld	ra,24(sp)
    80002800:	6442                	ld	s0,16(sp)
    80002802:	64a2                	ld	s1,8(sp)
    80002804:	6105                	addi	sp,sp,32
    80002806:	8082                	ret

0000000080002808 <killed>:

int killed(struct proc *p)
{
    80002808:	1101                	addi	sp,sp,-32
    8000280a:	ec06                	sd	ra,24(sp)
    8000280c:	e822                	sd	s0,16(sp)
    8000280e:	e426                	sd	s1,8(sp)
    80002810:	e04a                	sd	s2,0(sp)
    80002812:	1000                	addi	s0,sp,32
    80002814:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002816:	ffffe097          	auipc	ra,0xffffe
    8000281a:	428080e7          	jalr	1064(ra) # 80000c3e <acquire>
  k = p->killed;
    8000281e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002822:	8526                	mv	a0,s1
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	4ca080e7          	jalr	1226(ra) # 80000cee <release>
  return k;
}
    8000282c:	854a                	mv	a0,s2
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6902                	ld	s2,0(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret

000000008000283a <wait>:
{
    8000283a:	715d                	addi	sp,sp,-80
    8000283c:	e486                	sd	ra,72(sp)
    8000283e:	e0a2                	sd	s0,64(sp)
    80002840:	fc26                	sd	s1,56(sp)
    80002842:	f84a                	sd	s2,48(sp)
    80002844:	f44e                	sd	s3,40(sp)
    80002846:	f052                	sd	s4,32(sp)
    80002848:	ec56                	sd	s5,24(sp)
    8000284a:	e85a                	sd	s6,16(sp)
    8000284c:	e45e                	sd	s7,8(sp)
    8000284e:	0880                	addi	s0,sp,80
    80002850:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002852:	fffff097          	auipc	ra,0xfffff
    80002856:	25e080e7          	jalr	606(ra) # 80001ab0 <myproc>
    8000285a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000285c:	0000e517          	auipc	a0,0xe
    80002860:	3bc50513          	addi	a0,a0,956 # 80010c18 <wait_lock>
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	3da080e7          	jalr	986(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    8000286c:	4a95                	li	s5,5
        havekids = 1;
    8000286e:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002870:	0001c997          	auipc	s3,0x1c
    80002874:	3d098993          	addi	s3,s3,976 # 8001ec40 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002878:	0000eb97          	auipc	s7,0xe
    8000287c:	3a0b8b93          	addi	s7,s7,928 # 80010c18 <wait_lock>
    80002880:	a0cd                	j	80002962 <wait+0x128>
    80002882:	04048613          	addi	a2,s1,64
          for (int i = 0; i <= 25; i++)
    80002886:	4701                	li	a4,0
    80002888:	4569                	li	a0,26
            pp->parent->syscall_count[i] += pp->syscall_count[i];
    8000288a:	00271693          	slli	a3,a4,0x2
    8000288e:	7c9c                	ld	a5,56(s1)
    80002890:	97b6                	add	a5,a5,a3
    80002892:	43ac                	lw	a1,64(a5)
    80002894:	4214                	lw	a3,0(a2)
    80002896:	9ead                	addw	a3,a3,a1
    80002898:	c3b4                	sw	a3,64(a5)
          for (int i = 0; i <= 25; i++)
    8000289a:	2705                	addiw	a4,a4,1
    8000289c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000289e:	fea716e3          	bne	a4,a0,8000288a <wait+0x50>
          pid = pp->pid;
    800028a2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028a6:	000a0e63          	beqz	s4,800028c2 <wait+0x88>
    800028aa:	4691                	li	a3,4
    800028ac:	02c48613          	addi	a2,s1,44
    800028b0:	85d2                	mv	a1,s4
    800028b2:	22893503          	ld	a0,552(s2)
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	e5a080e7          	jalr	-422(ra) # 80001710 <copyout>
    800028be:	04054063          	bltz	a0,800028fe <wait+0xc4>
          freeproc(pp);
    800028c2:	8526                	mv	a0,s1
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	39e080e7          	jalr	926(ra) # 80001c62 <freeproc>
          release(&pp->lock);
    800028cc:	8526                	mv	a0,s1
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	420080e7          	jalr	1056(ra) # 80000cee <release>
          release(&wait_lock);
    800028d6:	0000e517          	auipc	a0,0xe
    800028da:	34250513          	addi	a0,a0,834 # 80010c18 <wait_lock>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	410080e7          	jalr	1040(ra) # 80000cee <release>
}
    800028e6:	854e                	mv	a0,s3
    800028e8:	60a6                	ld	ra,72(sp)
    800028ea:	6406                	ld	s0,64(sp)
    800028ec:	74e2                	ld	s1,56(sp)
    800028ee:	7942                	ld	s2,48(sp)
    800028f0:	79a2                	ld	s3,40(sp)
    800028f2:	7a02                	ld	s4,32(sp)
    800028f4:	6ae2                	ld	s5,24(sp)
    800028f6:	6b42                	ld	s6,16(sp)
    800028f8:	6ba2                	ld	s7,8(sp)
    800028fa:	6161                	addi	sp,sp,80
    800028fc:	8082                	ret
            release(&pp->lock);
    800028fe:	8526                	mv	a0,s1
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	3ee080e7          	jalr	1006(ra) # 80000cee <release>
            release(&wait_lock);
    80002908:	0000e517          	auipc	a0,0xe
    8000290c:	31050513          	addi	a0,a0,784 # 80010c18 <wait_lock>
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	3de080e7          	jalr	990(ra) # 80000cee <release>
            return -1;
    80002918:	59fd                	li	s3,-1
    8000291a:	b7f1                	j	800028e6 <wait+0xac>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000291c:	35048493          	addi	s1,s1,848
    80002920:	03348463          	beq	s1,s3,80002948 <wait+0x10e>
      if (pp->parent == p)
    80002924:	7c9c                	ld	a5,56(s1)
    80002926:	ff279be3          	bne	a5,s2,8000291c <wait+0xe2>
        acquire(&pp->lock);
    8000292a:	8526                	mv	a0,s1
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	312080e7          	jalr	786(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    80002934:	4c9c                	lw	a5,24(s1)
    80002936:	f55786e3          	beq	a5,s5,80002882 <wait+0x48>
        release(&pp->lock);
    8000293a:	8526                	mv	a0,s1
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	3b2080e7          	jalr	946(ra) # 80000cee <release>
        havekids = 1;
    80002944:	875a                	mv	a4,s6
    80002946:	bfd9                	j	8000291c <wait+0xe2>
    if (!havekids || killed(p))
    80002948:	c31d                	beqz	a4,8000296e <wait+0x134>
    8000294a:	854a                	mv	a0,s2
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	ebc080e7          	jalr	-324(ra) # 80002808 <killed>
    80002954:	ed09                	bnez	a0,8000296e <wait+0x134>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002956:	85de                	mv	a1,s7
    80002958:	854a                	mv	a0,s2
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	bfa080e7          	jalr	-1030(ra) # 80002554 <sleep>
    havekids = 0;
    80002962:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002964:	0000f497          	auipc	s1,0xf
    80002968:	edc48493          	addi	s1,s1,-292 # 80011840 <proc>
    8000296c:	bf65                	j	80002924 <wait+0xea>
      release(&wait_lock);
    8000296e:	0000e517          	auipc	a0,0xe
    80002972:	2aa50513          	addi	a0,a0,682 # 80010c18 <wait_lock>
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	378080e7          	jalr	888(ra) # 80000cee <release>
      return -1;
    8000297e:	59fd                	li	s3,-1
    80002980:	b79d                	j	800028e6 <wait+0xac>

0000000080002982 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002982:	7179                	addi	sp,sp,-48
    80002984:	f406                	sd	ra,40(sp)
    80002986:	f022                	sd	s0,32(sp)
    80002988:	ec26                	sd	s1,24(sp)
    8000298a:	e84a                	sd	s2,16(sp)
    8000298c:	e44e                	sd	s3,8(sp)
    8000298e:	e052                	sd	s4,0(sp)
    80002990:	1800                	addi	s0,sp,48
    80002992:	84aa                	mv	s1,a0
    80002994:	892e                	mv	s2,a1
    80002996:	89b2                	mv	s3,a2
    80002998:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000299a:	fffff097          	auipc	ra,0xfffff
    8000299e:	116080e7          	jalr	278(ra) # 80001ab0 <myproc>
  if (user_dst)
    800029a2:	c095                	beqz	s1,800029c6 <either_copyout+0x44>
  {
    return copyout(p->pagetable, dst, src, len);
    800029a4:	86d2                	mv	a3,s4
    800029a6:	864e                	mv	a2,s3
    800029a8:	85ca                	mv	a1,s2
    800029aa:	22853503          	ld	a0,552(a0)
    800029ae:	fffff097          	auipc	ra,0xfffff
    800029b2:	d62080e7          	jalr	-670(ra) # 80001710 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029b6:	70a2                	ld	ra,40(sp)
    800029b8:	7402                	ld	s0,32(sp)
    800029ba:	64e2                	ld	s1,24(sp)
    800029bc:	6942                	ld	s2,16(sp)
    800029be:	69a2                	ld	s3,8(sp)
    800029c0:	6a02                	ld	s4,0(sp)
    800029c2:	6145                	addi	sp,sp,48
    800029c4:	8082                	ret
    memmove((char *)dst, src, len);
    800029c6:	000a061b          	sext.w	a2,s4
    800029ca:	85ce                	mv	a1,s3
    800029cc:	854a                	mv	a0,s2
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	3cc080e7          	jalr	972(ra) # 80000d9a <memmove>
    return 0;
    800029d6:	8526                	mv	a0,s1
    800029d8:	bff9                	j	800029b6 <either_copyout+0x34>

00000000800029da <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029da:	7179                	addi	sp,sp,-48
    800029dc:	f406                	sd	ra,40(sp)
    800029de:	f022                	sd	s0,32(sp)
    800029e0:	ec26                	sd	s1,24(sp)
    800029e2:	e84a                	sd	s2,16(sp)
    800029e4:	e44e                	sd	s3,8(sp)
    800029e6:	e052                	sd	s4,0(sp)
    800029e8:	1800                	addi	s0,sp,48
    800029ea:	892a                	mv	s2,a0
    800029ec:	84ae                	mv	s1,a1
    800029ee:	89b2                	mv	s3,a2
    800029f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029f2:	fffff097          	auipc	ra,0xfffff
    800029f6:	0be080e7          	jalr	190(ra) # 80001ab0 <myproc>
  if (user_src)
    800029fa:	c095                	beqz	s1,80002a1e <either_copyin+0x44>
  {
    return copyin(p->pagetable, dst, src, len);
    800029fc:	86d2                	mv	a3,s4
    800029fe:	864e                	mv	a2,s3
    80002a00:	85ca                	mv	a1,s2
    80002a02:	22853503          	ld	a0,552(a0)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	d96080e7          	jalr	-618(ra) # 8000179c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002a0e:	70a2                	ld	ra,40(sp)
    80002a10:	7402                	ld	s0,32(sp)
    80002a12:	64e2                	ld	s1,24(sp)
    80002a14:	6942                	ld	s2,16(sp)
    80002a16:	69a2                	ld	s3,8(sp)
    80002a18:	6a02                	ld	s4,0(sp)
    80002a1a:	6145                	addi	sp,sp,48
    80002a1c:	8082                	ret
    memmove(dst, (char *)src, len);
    80002a1e:	000a061b          	sext.w	a2,s4
    80002a22:	85ce                	mv	a1,s3
    80002a24:	854a                	mv	a0,s2
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	374080e7          	jalr	884(ra) # 80000d9a <memmove>
    return 0;
    80002a2e:	8526                	mv	a0,s1
    80002a30:	bff9                	j	80002a0e <either_copyin+0x34>

0000000080002a32 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a32:	715d                	addi	sp,sp,-80
    80002a34:	e486                	sd	ra,72(sp)
    80002a36:	e0a2                	sd	s0,64(sp)
    80002a38:	fc26                	sd	s1,56(sp)
    80002a3a:	f84a                	sd	s2,48(sp)
    80002a3c:	f44e                	sd	s3,40(sp)
    80002a3e:	f052                	sd	s4,32(sp)
    80002a40:	ec56                	sd	s5,24(sp)
    80002a42:	e85a                	sd	s6,16(sp)
    80002a44:	e45e                	sd	s7,8(sp)
    80002a46:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002a48:	00005517          	auipc	a0,0x5
    80002a4c:	5c850513          	addi	a0,a0,1480 # 80008010 <etext+0x10>
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	b5a080e7          	jalr	-1190(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a58:	0000f497          	auipc	s1,0xf
    80002a5c:	11848493          	addi	s1,s1,280 # 80011b70 <proc+0x330>
    80002a60:	0001c917          	auipc	s2,0x1c
    80002a64:	51090913          	addi	s2,s2,1296 # 8001ef70 <bcache+0x318>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a68:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a6a:	00006997          	auipc	s3,0x6
    80002a6e:	88e98993          	addi	s3,s3,-1906 # 800082f8 <etext+0x2f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002a72:	00006a97          	auipc	s5,0x6
    80002a76:	88ea8a93          	addi	s5,s5,-1906 # 80008300 <etext+0x300>
    printf("\n");
    80002a7a:	00005a17          	auipc	s4,0x5
    80002a7e:	596a0a13          	addi	s4,s4,1430 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a82:	00006b97          	auipc	s7,0x6
    80002a86:	d56b8b93          	addi	s7,s7,-682 # 800087d8 <states.0>
    80002a8a:	a00d                	j	80002aac <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002a8c:	d006a583          	lw	a1,-768(a3)
    80002a90:	8556                	mv	a0,s5
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	b18080e7          	jalr	-1256(ra) # 800005aa <printf>
    printf("\n");
    80002a9a:	8552                	mv	a0,s4
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	b0e080e7          	jalr	-1266(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002aa4:	35048493          	addi	s1,s1,848
    80002aa8:	03248263          	beq	s1,s2,80002acc <procdump+0x9a>
    if (p->state == UNUSED)
    80002aac:	86a6                	mv	a3,s1
    80002aae:	ce84a783          	lw	a5,-792(s1)
    80002ab2:	dbed                	beqz	a5,80002aa4 <procdump+0x72>
      state = "???";
    80002ab4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ab6:	fcfb6be3          	bltu	s6,a5,80002a8c <procdump+0x5a>
    80002aba:	02079713          	slli	a4,a5,0x20
    80002abe:	01d75793          	srli	a5,a4,0x1d
    80002ac2:	97de                	add	a5,a5,s7
    80002ac4:	6390                	ld	a2,0(a5)
    80002ac6:	f279                	bnez	a2,80002a8c <procdump+0x5a>
      state = "???";
    80002ac8:	864e                	mv	a2,s3
    80002aca:	b7c9                	j	80002a8c <procdump+0x5a>
  }
}
    80002acc:	60a6                	ld	ra,72(sp)
    80002ace:	6406                	ld	s0,64(sp)
    80002ad0:	74e2                	ld	s1,56(sp)
    80002ad2:	7942                	ld	s2,48(sp)
    80002ad4:	79a2                	ld	s3,40(sp)
    80002ad6:	7a02                	ld	s4,32(sp)
    80002ad8:	6ae2                	ld	s5,24(sp)
    80002ada:	6b42                	ld	s6,16(sp)
    80002adc:	6ba2                	ld	s7,8(sp)
    80002ade:	6161                	addi	sp,sp,80
    80002ae0:	8082                	ret

0000000080002ae2 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002ae2:	711d                	addi	sp,sp,-96
    80002ae4:	ec86                	sd	ra,88(sp)
    80002ae6:	e8a2                	sd	s0,80(sp)
    80002ae8:	e4a6                	sd	s1,72(sp)
    80002aea:	e0ca                	sd	s2,64(sp)
    80002aec:	fc4e                	sd	s3,56(sp)
    80002aee:	f852                	sd	s4,48(sp)
    80002af0:	f456                	sd	s5,40(sp)
    80002af2:	f05a                	sd	s6,32(sp)
    80002af4:	ec5e                	sd	s7,24(sp)
    80002af6:	e862                	sd	s8,16(sp)
    80002af8:	e466                	sd	s9,8(sp)
    80002afa:	1080                	addi	s0,sp,96
    80002afc:	8b2a                	mv	s6,a0
    80002afe:	8bae                	mv	s7,a1
    80002b00:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	fae080e7          	jalr	-82(ra) # 80001ab0 <myproc>
    80002b0a:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002b0c:	0000e517          	auipc	a0,0xe
    80002b10:	10c50513          	addi	a0,a0,268 # 80010c18 <wait_lock>
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	12a080e7          	jalr	298(ra) # 80000c3e <acquire>
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002b1c:	4a15                	li	s4,5
        havekids = 1;
    80002b1e:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002b20:	0001c997          	auipc	s3,0x1c
    80002b24:	12098993          	addi	s3,s3,288 # 8001ec40 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002b28:	0000ec97          	auipc	s9,0xe
    80002b2c:	0f0c8c93          	addi	s9,s9,240 # 80010c18 <wait_lock>
    80002b30:	a8e1                	j	80002c08 <waitx+0x126>
          pid = np->pid;
    80002b32:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002b36:	3404a783          	lw	a5,832(s1)
    80002b3a:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002b3e:	3444a703          	lw	a4,836(s1)
    80002b42:	9f3d                	addw	a4,a4,a5
    80002b44:	3484a783          	lw	a5,840(s1)
    80002b48:	9f99                	subw	a5,a5,a4
    80002b4a:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002b4e:	000b0e63          	beqz	s6,80002b6a <waitx+0x88>
    80002b52:	4691                	li	a3,4
    80002b54:	02c48613          	addi	a2,s1,44
    80002b58:	85da                	mv	a1,s6
    80002b5a:	22893503          	ld	a0,552(s2)
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	bb2080e7          	jalr	-1102(ra) # 80001710 <copyout>
    80002b66:	04054263          	bltz	a0,80002baa <waitx+0xc8>
          freeproc(np);
    80002b6a:	8526                	mv	a0,s1
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	0f6080e7          	jalr	246(ra) # 80001c62 <freeproc>
          release(&np->lock);
    80002b74:	8526                	mv	a0,s1
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	178080e7          	jalr	376(ra) # 80000cee <release>
          release(&wait_lock);
    80002b7e:	0000e517          	auipc	a0,0xe
    80002b82:	09a50513          	addi	a0,a0,154 # 80010c18 <wait_lock>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	168080e7          	jalr	360(ra) # 80000cee <release>
  }
}
    80002b8e:	854e                	mv	a0,s3
    80002b90:	60e6                	ld	ra,88(sp)
    80002b92:	6446                	ld	s0,80(sp)
    80002b94:	64a6                	ld	s1,72(sp)
    80002b96:	6906                	ld	s2,64(sp)
    80002b98:	79e2                	ld	s3,56(sp)
    80002b9a:	7a42                	ld	s4,48(sp)
    80002b9c:	7aa2                	ld	s5,40(sp)
    80002b9e:	7b02                	ld	s6,32(sp)
    80002ba0:	6be2                	ld	s7,24(sp)
    80002ba2:	6c42                	ld	s8,16(sp)
    80002ba4:	6ca2                	ld	s9,8(sp)
    80002ba6:	6125                	addi	sp,sp,96
    80002ba8:	8082                	ret
            release(&np->lock);
    80002baa:	8526                	mv	a0,s1
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	142080e7          	jalr	322(ra) # 80000cee <release>
            release(&wait_lock);
    80002bb4:	0000e517          	auipc	a0,0xe
    80002bb8:	06450513          	addi	a0,a0,100 # 80010c18 <wait_lock>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	132080e7          	jalr	306(ra) # 80000cee <release>
            return -1;
    80002bc4:	59fd                	li	s3,-1
    80002bc6:	b7e1                	j	80002b8e <waitx+0xac>
    for (np = proc; np < &proc[NPROC]; np++)
    80002bc8:	35048493          	addi	s1,s1,848
    80002bcc:	03348463          	beq	s1,s3,80002bf4 <waitx+0x112>
      if (np->parent == p)
    80002bd0:	7c9c                	ld	a5,56(s1)
    80002bd2:	ff279be3          	bne	a5,s2,80002bc8 <waitx+0xe6>
        acquire(&np->lock);
    80002bd6:	8526                	mv	a0,s1
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	066080e7          	jalr	102(ra) # 80000c3e <acquire>
        if (np->state == ZOMBIE)
    80002be0:	4c9c                	lw	a5,24(s1)
    80002be2:	f54788e3          	beq	a5,s4,80002b32 <waitx+0x50>
        release(&np->lock);
    80002be6:	8526                	mv	a0,s1
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	106080e7          	jalr	262(ra) # 80000cee <release>
        havekids = 1;
    80002bf0:	8756                	mv	a4,s5
    80002bf2:	bfd9                	j	80002bc8 <waitx+0xe6>
    if (!havekids || p->killed)
    80002bf4:	c305                	beqz	a4,80002c14 <waitx+0x132>
    80002bf6:	02892783          	lw	a5,40(s2)
    80002bfa:	ef89                	bnez	a5,80002c14 <waitx+0x132>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002bfc:	85e6                	mv	a1,s9
    80002bfe:	854a                	mv	a0,s2
    80002c00:	00000097          	auipc	ra,0x0
    80002c04:	954080e7          	jalr	-1708(ra) # 80002554 <sleep>
    havekids = 0;
    80002c08:	4701                	li	a4,0
    for (np = proc; np < &proc[NPROC]; np++)
    80002c0a:	0000f497          	auipc	s1,0xf
    80002c0e:	c3648493          	addi	s1,s1,-970 # 80011840 <proc>
    80002c12:	bf7d                	j	80002bd0 <waitx+0xee>
      release(&wait_lock);
    80002c14:	0000e517          	auipc	a0,0xe
    80002c18:	00450513          	addi	a0,a0,4 # 80010c18 <wait_lock>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	0d2080e7          	jalr	210(ra) # 80000cee <release>
      return -1;
    80002c24:	59fd                	li	s3,-1
    80002c26:	b7a5                	j	80002b8e <waitx+0xac>

0000000080002c28 <update_time>:

void update_time()
{
    80002c28:	7179                	addi	sp,sp,-48
    80002c2a:	f406                	sd	ra,40(sp)
    80002c2c:	f022                	sd	s0,32(sp)
    80002c2e:	ec26                	sd	s1,24(sp)
    80002c30:	e84a                	sd	s2,16(sp)
    80002c32:	e44e                	sd	s3,8(sp)
    80002c34:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002c36:	0000f497          	auipc	s1,0xf
    80002c3a:	c0a48493          	addi	s1,s1,-1014 # 80011840 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002c3e:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002c40:	0001c917          	auipc	s2,0x1c
    80002c44:	00090913          	mv	s2,s2
    80002c48:	a811                	j	80002c5c <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	0a2080e7          	jalr	162(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002c54:	35048493          	addi	s1,s1,848
    80002c58:	03248063          	beq	s1,s2,80002c78 <update_time+0x50>
    acquire(&p->lock);
    80002c5c:	8526                	mv	a0,s1
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	fe0080e7          	jalr	-32(ra) # 80000c3e <acquire>
    if (p->state == RUNNING)
    80002c66:	4c9c                	lw	a5,24(s1)
    80002c68:	ff3791e3          	bne	a5,s3,80002c4a <update_time+0x22>
      p->rtime++;
    80002c6c:	3404a783          	lw	a5,832(s1)
    80002c70:	2785                	addiw	a5,a5,1
    80002c72:	34f4a023          	sw	a5,832(s1)
    80002c76:	bfd1                	j	80002c4a <update_time+0x22>
  }
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6942                	ld	s2,16(sp)
    80002c80:	69a2                	ld	s3,8(sp)
    80002c82:	6145                	addi	sp,sp,48
    80002c84:	8082                	ret

0000000080002c86 <swtch>:
    80002c86:	00153023          	sd	ra,0(a0)
    80002c8a:	00253423          	sd	sp,8(a0)
    80002c8e:	e900                	sd	s0,16(a0)
    80002c90:	ed04                	sd	s1,24(a0)
    80002c92:	03253023          	sd	s2,32(a0)
    80002c96:	03353423          	sd	s3,40(a0)
    80002c9a:	03453823          	sd	s4,48(a0)
    80002c9e:	03553c23          	sd	s5,56(a0)
    80002ca2:	05653023          	sd	s6,64(a0)
    80002ca6:	05753423          	sd	s7,72(a0)
    80002caa:	05853823          	sd	s8,80(a0)
    80002cae:	05953c23          	sd	s9,88(a0)
    80002cb2:	07a53023          	sd	s10,96(a0)
    80002cb6:	07b53423          	sd	s11,104(a0)
    80002cba:	0005b083          	ld	ra,0(a1)
    80002cbe:	0085b103          	ld	sp,8(a1)
    80002cc2:	6980                	ld	s0,16(a1)
    80002cc4:	6d84                	ld	s1,24(a1)
    80002cc6:	0205b903          	ld	s2,32(a1)
    80002cca:	0285b983          	ld	s3,40(a1)
    80002cce:	0305ba03          	ld	s4,48(a1)
    80002cd2:	0385ba83          	ld	s5,56(a1)
    80002cd6:	0405bb03          	ld	s6,64(a1)
    80002cda:	0485bb83          	ld	s7,72(a1)
    80002cde:	0505bc03          	ld	s8,80(a1)
    80002ce2:	0585bc83          	ld	s9,88(a1)
    80002ce6:	0605bd03          	ld	s10,96(a1)
    80002cea:	0685bd83          	ld	s11,104(a1)
    80002cee:	8082                	ret

0000000080002cf0 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002cf0:	1141                	addi	sp,sp,-16
    80002cf2:	e406                	sd	ra,8(sp)
    80002cf4:	e022                	sd	s0,0(sp)
    80002cf6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002cf8:	00005597          	auipc	a1,0x5
    80002cfc:	64858593          	addi	a1,a1,1608 # 80008340 <etext+0x340>
    80002d00:	0001c517          	auipc	a0,0x1c
    80002d04:	f4050513          	addi	a0,a0,-192 # 8001ec40 <tickslock>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	ea2080e7          	jalr	-350(ra) # 80000baa <initlock>
}
    80002d10:	60a2                	ld	ra,8(sp)
    80002d12:	6402                	ld	s0,0(sp)
    80002d14:	0141                	addi	sp,sp,16
    80002d16:	8082                	ret

0000000080002d18 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002d18:	1141                	addi	sp,sp,-16
    80002d1a:	e406                	sd	ra,8(sp)
    80002d1c:	e022                	sd	s0,0(sp)
    80002d1e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d20:	00004797          	auipc	a5,0x4
    80002d24:	82078793          	addi	a5,a5,-2016 # 80006540 <kernelvec>
    80002d28:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002d2c:	60a2                	ld	ra,8(sp)
    80002d2e:	6402                	ld	s0,0(sp)
    80002d30:	0141                	addi	sp,sp,16
    80002d32:	8082                	ret

0000000080002d34 <usertrapret>:
}

// return to user space
//
void usertrapret(void)
{
    80002d34:	1141                	addi	sp,sp,-16
    80002d36:	e406                	sd	ra,8(sp)
    80002d38:	e022                	sd	s0,0(sp)
    80002d3a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	d74080e7          	jalr	-652(ra) # 80001ab0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d48:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d4a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002d4e:	00004697          	auipc	a3,0x4
    80002d52:	2b268693          	addi	a3,a3,690 # 80007000 <_trampoline>
    80002d56:	00004717          	auipc	a4,0x4
    80002d5a:	2aa70713          	addi	a4,a4,682 # 80007000 <_trampoline>
    80002d5e:	8f15                	sub	a4,a4,a3
    80002d60:	040007b7          	lui	a5,0x4000
    80002d64:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002d66:	07b2                	slli	a5,a5,0xc
    80002d68:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d6a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d6e:	23053703          	ld	a4,560(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d72:	18002673          	csrr	a2,satp
    80002d76:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d78:	23053603          	ld	a2,560(a0)
    80002d7c:	21853703          	ld	a4,536(a0)
    80002d80:	6585                	lui	a1,0x1
    80002d82:	972e                	add	a4,a4,a1
    80002d84:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d86:	23053703          	ld	a4,560(a0)
    80002d8a:	00000617          	auipc	a2,0x0
    80002d8e:	14c60613          	addi	a2,a2,332 # 80002ed6 <usertrap>
    80002d92:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002d94:	23053703          	ld	a4,560(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d98:	8612                	mv	a2,tp
    80002d9a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d9c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002da0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002da4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002da8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002dac:	23053703          	ld	a4,560(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002db0:	6f18                	ld	a4,24(a4)
    80002db2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002db6:	22853503          	ld	a0,552(a0)
    80002dba:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002dbc:	00004717          	auipc	a4,0x4
    80002dc0:	2e070713          	addi	a4,a4,736 # 8000709c <userret>
    80002dc4:	8f15                	sub	a4,a4,a3
    80002dc6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002dc8:	577d                	li	a4,-1
    80002dca:	177e                	slli	a4,a4,0x3f
    80002dcc:	8d59                	or	a0,a0,a4
    80002dce:	9782                	jalr	a5
}
    80002dd0:	60a2                	ld	ra,8(sp)
    80002dd2:	6402                	ld	s0,0(sp)
    80002dd4:	0141                	addi	sp,sp,16
    80002dd6:	8082                	ret

0000000080002dd8 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	e426                	sd	s1,8(sp)
    80002de0:	e04a                	sd	s2,0(sp)
    80002de2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002de4:	0001c917          	auipc	s2,0x1c
    80002de8:	e5c90913          	addi	s2,s2,-420 # 8001ec40 <tickslock>
    80002dec:	854a                	mv	a0,s2
    80002dee:	ffffe097          	auipc	ra,0xffffe
    80002df2:	e50080e7          	jalr	-432(ra) # 80000c3e <acquire>
  ticks++;
    80002df6:	00006497          	auipc	s1,0x6
    80002dfa:	b9e48493          	addi	s1,s1,-1122 # 80008994 <ticks>
    80002dfe:	409c                	lw	a5,0(s1)
    80002e00:	2785                	addiw	a5,a5,1
    80002e02:	c09c                	sw	a5,0(s1)
  update_time();
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	e24080e7          	jalr	-476(ra) # 80002c28 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	fffff097          	auipc	ra,0xfffff
    80002e12:	7aa080e7          	jalr	1962(ra) # 800025b8 <wakeup>
  release(&tickslock);
    80002e16:	854a                	mv	a0,s2
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	ed6080e7          	jalr	-298(ra) # 80000cee <release>
}
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	64a2                	ld	s1,8(sp)
    80002e26:	6902                	ld	s2,0(sp)
    80002e28:	6105                	addi	sp,sp,32
    80002e2a:	8082                	ret

0000000080002e2c <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e2c:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002e30:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002e32:	0a07d163          	bgez	a5,80002ed4 <devintr+0xa8>
{
    80002e36:	1101                	addi	sp,sp,-32
    80002e38:	ec06                	sd	ra,24(sp)
    80002e3a:	e822                	sd	s0,16(sp)
    80002e3c:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002e3e:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002e42:	46a5                	li	a3,9
    80002e44:	00d70c63          	beq	a4,a3,80002e5c <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002e48:	577d                	li	a4,-1
    80002e4a:	177e                	slli	a4,a4,0x3f
    80002e4c:	0705                	addi	a4,a4,1
    return 0;
    80002e4e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002e50:	06e78163          	beq	a5,a4,80002eb2 <devintr+0x86>
  }
}
    80002e54:	60e2                	ld	ra,24(sp)
    80002e56:	6442                	ld	s0,16(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret
    80002e5c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002e5e:	00003097          	auipc	ra,0x3
    80002e62:	7ee080e7          	jalr	2030(ra) # 8000664c <plic_claim>
    80002e66:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002e68:	47a9                	li	a5,10
    80002e6a:	00f50963          	beq	a0,a5,80002e7c <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002e6e:	4785                	li	a5,1
    80002e70:	00f50b63          	beq	a0,a5,80002e86 <devintr+0x5a>
    return 1;
    80002e74:	4505                	li	a0,1
    else if (irq)
    80002e76:	ec89                	bnez	s1,80002e90 <devintr+0x64>
    80002e78:	64a2                	ld	s1,8(sp)
    80002e7a:	bfe9                	j	80002e54 <devintr+0x28>
      uartintr();
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	b80080e7          	jalr	-1152(ra) # 800009fc <uartintr>
    if (irq)
    80002e84:	a839                	j	80002ea2 <devintr+0x76>
      virtio_disk_intr();
    80002e86:	00004097          	auipc	ra,0x4
    80002e8a:	cba080e7          	jalr	-838(ra) # 80006b40 <virtio_disk_intr>
    if (irq)
    80002e8e:	a811                	j	80002ea2 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e90:	85a6                	mv	a1,s1
    80002e92:	00005517          	auipc	a0,0x5
    80002e96:	4b650513          	addi	a0,a0,1206 # 80008348 <etext+0x348>
    80002e9a:	ffffd097          	auipc	ra,0xffffd
    80002e9e:	710080e7          	jalr	1808(ra) # 800005aa <printf>
      plic_complete(irq);
    80002ea2:	8526                	mv	a0,s1
    80002ea4:	00003097          	auipc	ra,0x3
    80002ea8:	7cc080e7          	jalr	1996(ra) # 80006670 <plic_complete>
    return 1;
    80002eac:	4505                	li	a0,1
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	b755                	j	80002e54 <devintr+0x28>
    if (cpuid() == 0)
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	bca080e7          	jalr	-1078(ra) # 80001a7c <cpuid>
    80002eba:	c901                	beqz	a0,80002eca <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ebc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ec0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ec2:	14479073          	csrw	sip,a5
    return 2;
    80002ec6:	4509                	li	a0,2
    80002ec8:	b771                	j	80002e54 <devintr+0x28>
      clockintr();
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	f0e080e7          	jalr	-242(ra) # 80002dd8 <clockintr>
    80002ed2:	b7ed                	j	80002ebc <devintr+0x90>
}
    80002ed4:	8082                	ret

0000000080002ed6 <usertrap>:
{
    80002ed6:	1101                	addi	sp,sp,-32
    80002ed8:	ec06                	sd	ra,24(sp)
    80002eda:	e822                	sd	s0,16(sp)
    80002edc:	e426                	sd	s1,8(sp)
    80002ede:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ee0:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ee4:	1007f793          	andi	a5,a5,256
    80002ee8:	e7bd                	bnez	a5,80002f56 <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002eea:	00003797          	auipc	a5,0x3
    80002eee:	65678793          	addi	a5,a5,1622 # 80006540 <kernelvec>
    80002ef2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	bba080e7          	jalr	-1094(ra) # 80001ab0 <myproc>
    80002efe:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002f00:	23053783          	ld	a5,560(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f04:	14102773          	csrr	a4,sepc
    80002f08:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f0a:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002f0e:	47a1                	li	a5,8
    80002f10:	04f70b63          	beq	a4,a5,80002f66 <usertrap+0x90>
  else if ((which_dev = devintr()) != 0)
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	f18080e7          	jalr	-232(ra) # 80002e2c <devintr>
    80002f1c:	cd51                	beqz	a0,80002fb8 <usertrap+0xe2>
  if (which_dev == 2 && p->alarm_interval > 0)
    80002f1e:	4789                	li	a5,2
    80002f20:	06f51763          	bne	a0,a5,80002f8e <usertrap+0xb8>
    80002f24:	0e44a703          	lw	a4,228(s1)
    80002f28:	00e05c63          	blez	a4,80002f40 <usertrap+0x6a>
    p->ticks++;
    80002f2c:	0e04a783          	lw	a5,224(s1)
    80002f30:	2785                	addiw	a5,a5,1
    80002f32:	0ef4a023          	sw	a5,224(s1)
    if (p->ticks >= p->alarm_interval && p->alarm_active == 0)
    80002f36:	00e7c563          	blt	a5,a4,80002f40 <usertrap+0x6a>
    80002f3a:	2104a783          	lw	a5,528(s1)
    80002f3e:	cbd5                	beqz	a5,80002ff2 <usertrap+0x11c>
  if (killed(p))
    80002f40:	8526                	mv	a0,s1
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	8c6080e7          	jalr	-1850(ra) # 80002808 <killed>
    80002f4a:	e961                	bnez	a0,8000301a <usertrap+0x144>
    yield();
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	5cc080e7          	jalr	1484(ra) # 80002518 <yield>
    80002f54:	a099                	j	80002f9a <usertrap+0xc4>
    panic("usertrap: not from user mode");
    80002f56:	00005517          	auipc	a0,0x5
    80002f5a:	41250513          	addi	a0,a0,1042 # 80008368 <etext+0x368>
    80002f5e:	ffffd097          	auipc	ra,0xffffd
    80002f62:	602080e7          	jalr	1538(ra) # 80000560 <panic>
    if (killed(p))
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	8a2080e7          	jalr	-1886(ra) # 80002808 <killed>
    80002f6e:	ed1d                	bnez	a0,80002fac <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002f70:	2304b703          	ld	a4,560(s1)
    80002f74:	6f1c                	ld	a5,24(a4)
    80002f76:	0791                	addi	a5,a5,4
    80002f78:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f82:	10079073          	csrw	sstatus,a5
    syscall();
    80002f86:	00000097          	auipc	ra,0x0
    80002f8a:	300080e7          	jalr	768(ra) # 80003286 <syscall>
  if (killed(p))
    80002f8e:	8526                	mv	a0,s1
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	878080e7          	jalr	-1928(ra) # 80002808 <killed>
    80002f98:	e559                	bnez	a0,80003026 <usertrap+0x150>
  usertrapret();
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	d9a080e7          	jalr	-614(ra) # 80002d34 <usertrapret>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	64a2                	ld	s1,8(sp)
    80002fa8:	6105                	addi	sp,sp,32
    80002faa:	8082                	ret
      exit(-1);
    80002fac:	557d                	li	a0,-1
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	6da080e7          	jalr	1754(ra) # 80002688 <exit>
    80002fb6:	bf6d                	j	80002f70 <usertrap+0x9a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fb8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002fbc:	5890                	lw	a2,48(s1)
    80002fbe:	00005517          	auipc	a0,0x5
    80002fc2:	3ca50513          	addi	a0,a0,970 # 80008388 <etext+0x388>
    80002fc6:	ffffd097          	auipc	ra,0xffffd
    80002fca:	5e4080e7          	jalr	1508(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fd2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fd6:	00005517          	auipc	a0,0x5
    80002fda:	3e250513          	addi	a0,a0,994 # 800083b8 <etext+0x3b8>
    80002fde:	ffffd097          	auipc	ra,0xffffd
    80002fe2:	5cc080e7          	jalr	1484(ra) # 800005aa <printf>
    setkilled(p);
    80002fe6:	8526                	mv	a0,s1
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	7f4080e7          	jalr	2036(ra) # 800027dc <setkilled>
  if (which_dev == 2 && p->alarm_interval > 0)
    80002ff0:	bf79                	j	80002f8e <usertrap+0xb8>
      p->ticks = 0;        // Reset the tick count
    80002ff2:	0e04a023          	sw	zero,224(s1)
      p->alarm_active = 1; // Mark that handler is active to prevent re-entry
    80002ff6:	4785                	li	a5,1
    80002ff8:	20f4a823          	sw	a5,528(s1)
      memmove(&p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80002ffc:	12000613          	li	a2,288
    80003000:	2304b583          	ld	a1,560(s1)
    80003004:	0f048513          	addi	a0,s1,240
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	d92080e7          	jalr	-622(ra) # 80000d9a <memmove>
      p->trapframe->epc = p->handler;
    80003010:	2304b783          	ld	a5,560(s1)
    80003014:	74f8                	ld	a4,232(s1)
    80003016:	ef98                	sd	a4,24(a5)
    80003018:	b725                	j	80002f40 <usertrap+0x6a>
    exit(-1);
    8000301a:	557d                	li	a0,-1
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	66c080e7          	jalr	1644(ra) # 80002688 <exit>
  if (which_dev == 2)
    80003024:	b725                	j	80002f4c <usertrap+0x76>
    exit(-1);
    80003026:	557d                	li	a0,-1
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	660080e7          	jalr	1632(ra) # 80002688 <exit>
  if (which_dev == 2)
    80003030:	b7ad                	j	80002f9a <usertrap+0xc4>

0000000080003032 <kerneltrap>:
{
    80003032:	7179                	addi	sp,sp,-48
    80003034:	f406                	sd	ra,40(sp)
    80003036:	f022                	sd	s0,32(sp)
    80003038:	ec26                	sd	s1,24(sp)
    8000303a:	e84a                	sd	s2,16(sp)
    8000303c:	e44e                	sd	s3,8(sp)
    8000303e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003040:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003044:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003048:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000304c:	1004f793          	andi	a5,s1,256
    80003050:	cb85                	beqz	a5,80003080 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003052:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003056:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003058:	ef85                	bnez	a5,80003090 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    8000305a:	00000097          	auipc	ra,0x0
    8000305e:	dd2080e7          	jalr	-558(ra) # 80002e2c <devintr>
    80003062:	cd1d                	beqz	a0,800030a0 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003064:	4789                	li	a5,2
    80003066:	06f50a63          	beq	a0,a5,800030da <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000306a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000306e:	10049073          	csrw	sstatus,s1
}
    80003072:	70a2                	ld	ra,40(sp)
    80003074:	7402                	ld	s0,32(sp)
    80003076:	64e2                	ld	s1,24(sp)
    80003078:	6942                	ld	s2,16(sp)
    8000307a:	69a2                	ld	s3,8(sp)
    8000307c:	6145                	addi	sp,sp,48
    8000307e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003080:	00005517          	auipc	a0,0x5
    80003084:	35850513          	addi	a0,a0,856 # 800083d8 <etext+0x3d8>
    80003088:	ffffd097          	auipc	ra,0xffffd
    8000308c:	4d8080e7          	jalr	1240(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80003090:	00005517          	auipc	a0,0x5
    80003094:	37050513          	addi	a0,a0,880 # 80008400 <etext+0x400>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4c8080e7          	jalr	1224(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    800030a0:	85ce                	mv	a1,s3
    800030a2:	00005517          	auipc	a0,0x5
    800030a6:	37e50513          	addi	a0,a0,894 # 80008420 <etext+0x420>
    800030aa:	ffffd097          	auipc	ra,0xffffd
    800030ae:	500080e7          	jalr	1280(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030b2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030b6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030ba:	00005517          	auipc	a0,0x5
    800030be:	37650513          	addi	a0,a0,886 # 80008430 <etext+0x430>
    800030c2:	ffffd097          	auipc	ra,0xffffd
    800030c6:	4e8080e7          	jalr	1256(ra) # 800005aa <printf>
    panic("kerneltrap");
    800030ca:	00005517          	auipc	a0,0x5
    800030ce:	37e50513          	addi	a0,a0,894 # 80008448 <etext+0x448>
    800030d2:	ffffd097          	auipc	ra,0xffffd
    800030d6:	48e080e7          	jalr	1166(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030da:	fffff097          	auipc	ra,0xfffff
    800030de:	9d6080e7          	jalr	-1578(ra) # 80001ab0 <myproc>
    800030e2:	d541                	beqz	a0,8000306a <kerneltrap+0x38>
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	9cc080e7          	jalr	-1588(ra) # 80001ab0 <myproc>
    800030ec:	4d18                	lw	a4,24(a0)
    800030ee:	4791                	li	a5,4
    800030f0:	f6f71de3          	bne	a4,a5,8000306a <kerneltrap+0x38>
    yield();
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	424080e7          	jalr	1060(ra) # 80002518 <yield>
    800030fc:	b7bd                	j	8000306a <kerneltrap+0x38>

00000000800030fe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800030fe:	1101                	addi	sp,sp,-32
    80003100:	ec06                	sd	ra,24(sp)
    80003102:	e822                	sd	s0,16(sp)
    80003104:	e426                	sd	s1,8(sp)
    80003106:	1000                	addi	s0,sp,32
    80003108:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000310a:	fffff097          	auipc	ra,0xfffff
    8000310e:	9a6080e7          	jalr	-1626(ra) # 80001ab0 <myproc>
  switch (n) {
    80003112:	4795                	li	a5,5
    80003114:	0497e763          	bltu	a5,s1,80003162 <argraw+0x64>
    80003118:	048a                	slli	s1,s1,0x2
    8000311a:	00005717          	auipc	a4,0x5
    8000311e:	6ee70713          	addi	a4,a4,1774 # 80008808 <states.0+0x30>
    80003122:	94ba                	add	s1,s1,a4
    80003124:	409c                	lw	a5,0(s1)
    80003126:	97ba                	add	a5,a5,a4
    80003128:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000312a:	23053783          	ld	a5,560(a0)
    8000312e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret
    return p->trapframe->a1;
    8000313a:	23053783          	ld	a5,560(a0)
    8000313e:	7fa8                	ld	a0,120(a5)
    80003140:	bfc5                	j	80003130 <argraw+0x32>
    return p->trapframe->a2;
    80003142:	23053783          	ld	a5,560(a0)
    80003146:	63c8                	ld	a0,128(a5)
    80003148:	b7e5                	j	80003130 <argraw+0x32>
    return p->trapframe->a3;
    8000314a:	23053783          	ld	a5,560(a0)
    8000314e:	67c8                	ld	a0,136(a5)
    80003150:	b7c5                	j	80003130 <argraw+0x32>
    return p->trapframe->a4;
    80003152:	23053783          	ld	a5,560(a0)
    80003156:	6bc8                	ld	a0,144(a5)
    80003158:	bfe1                	j	80003130 <argraw+0x32>
    return p->trapframe->a5;
    8000315a:	23053783          	ld	a5,560(a0)
    8000315e:	6fc8                	ld	a0,152(a5)
    80003160:	bfc1                	j	80003130 <argraw+0x32>
  panic("argraw");
    80003162:	00005517          	auipc	a0,0x5
    80003166:	2f650513          	addi	a0,a0,758 # 80008458 <etext+0x458>
    8000316a:	ffffd097          	auipc	ra,0xffffd
    8000316e:	3f6080e7          	jalr	1014(ra) # 80000560 <panic>

0000000080003172 <fetchaddr>:
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	e04a                	sd	s2,0(sp)
    8000317c:	1000                	addi	s0,sp,32
    8000317e:	84aa                	mv	s1,a0
    80003180:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003182:	fffff097          	auipc	ra,0xfffff
    80003186:	92e080e7          	jalr	-1746(ra) # 80001ab0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000318a:	22053783          	ld	a5,544(a0)
    8000318e:	02f4f963          	bgeu	s1,a5,800031c0 <fetchaddr+0x4e>
    80003192:	00848713          	addi	a4,s1,8
    80003196:	02e7e763          	bltu	a5,a4,800031c4 <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000319a:	46a1                	li	a3,8
    8000319c:	8626                	mv	a2,s1
    8000319e:	85ca                	mv	a1,s2
    800031a0:	22853503          	ld	a0,552(a0)
    800031a4:	ffffe097          	auipc	ra,0xffffe
    800031a8:	5f8080e7          	jalr	1528(ra) # 8000179c <copyin>
    800031ac:	00a03533          	snez	a0,a0
    800031b0:	40a0053b          	negw	a0,a0
}
    800031b4:	60e2                	ld	ra,24(sp)
    800031b6:	6442                	ld	s0,16(sp)
    800031b8:	64a2                	ld	s1,8(sp)
    800031ba:	6902                	ld	s2,0(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret
    return -1;
    800031c0:	557d                	li	a0,-1
    800031c2:	bfcd                	j	800031b4 <fetchaddr+0x42>
    800031c4:	557d                	li	a0,-1
    800031c6:	b7fd                	j	800031b4 <fetchaddr+0x42>

00000000800031c8 <fetchstr>:
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	1800                	addi	s0,sp,48
    800031d6:	892a                	mv	s2,a0
    800031d8:	84ae                	mv	s1,a1
    800031da:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	8d4080e7          	jalr	-1836(ra) # 80001ab0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800031e4:	86ce                	mv	a3,s3
    800031e6:	864a                	mv	a2,s2
    800031e8:	85a6                	mv	a1,s1
    800031ea:	22853503          	ld	a0,552(a0)
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	63c080e7          	jalr	1596(ra) # 8000182a <copyinstr>
    800031f6:	00054e63          	bltz	a0,80003212 <fetchstr+0x4a>
  return strlen(buf);
    800031fa:	8526                	mv	a0,s1
    800031fc:	ffffe097          	auipc	ra,0xffffe
    80003200:	cc6080e7          	jalr	-826(ra) # 80000ec2 <strlen>
}
    80003204:	70a2                	ld	ra,40(sp)
    80003206:	7402                	ld	s0,32(sp)
    80003208:	64e2                	ld	s1,24(sp)
    8000320a:	6942                	ld	s2,16(sp)
    8000320c:	69a2                	ld	s3,8(sp)
    8000320e:	6145                	addi	sp,sp,48
    80003210:	8082                	ret
    return -1;
    80003212:	557d                	li	a0,-1
    80003214:	bfc5                	j	80003204 <fetchstr+0x3c>

0000000080003216 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003222:	00000097          	auipc	ra,0x0
    80003226:	edc080e7          	jalr	-292(ra) # 800030fe <argraw>
    8000322a:	c088                	sw	a0,0(s1)
}
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	64a2                	ld	s1,8(sp)
    80003232:	6105                	addi	sp,sp,32
    80003234:	8082                	ret

0000000080003236 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003236:	1101                	addi	sp,sp,-32
    80003238:	ec06                	sd	ra,24(sp)
    8000323a:	e822                	sd	s0,16(sp)
    8000323c:	e426                	sd	s1,8(sp)
    8000323e:	1000                	addi	s0,sp,32
    80003240:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003242:	00000097          	auipc	ra,0x0
    80003246:	ebc080e7          	jalr	-324(ra) # 800030fe <argraw>
    8000324a:	e088                	sd	a0,0(s1)
}
    8000324c:	60e2                	ld	ra,24(sp)
    8000324e:	6442                	ld	s0,16(sp)
    80003250:	64a2                	ld	s1,8(sp)
    80003252:	6105                	addi	sp,sp,32
    80003254:	8082                	ret

0000000080003256 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	e426                	sd	s1,8(sp)
    8000325e:	e04a                	sd	s2,0(sp)
    80003260:	1000                	addi	s0,sp,32
    80003262:	84ae                	mv	s1,a1
    80003264:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003266:	00000097          	auipc	ra,0x0
    8000326a:	e98080e7          	jalr	-360(ra) # 800030fe <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000326e:	864a                	mv	a2,s2
    80003270:	85a6                	mv	a1,s1
    80003272:	00000097          	auipc	ra,0x0
    80003276:	f56080e7          	jalr	-170(ra) # 800031c8 <fetchstr>
}
    8000327a:	60e2                	ld	ra,24(sp)
    8000327c:	6442                	ld	s0,16(sp)
    8000327e:	64a2                	ld	s1,8(sp)
    80003280:	6902                	ld	s2,0(sp)
    80003282:	6105                	addi	sp,sp,32
    80003284:	8082                	ret

0000000080003286 <syscall>:
    [SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80003286:	7179                	addi	sp,sp,-48
    80003288:	f406                	sd	ra,40(sp)
    8000328a:	f022                	sd	s0,32(sp)
    8000328c:	ec26                	sd	s1,24(sp)
    8000328e:	e84a                	sd	s2,16(sp)
    80003290:	e44e                	sd	s3,8(sp)
    80003292:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003294:	fffff097          	auipc	ra,0xfffff
    80003298:	81c080e7          	jalr	-2020(ra) # 80001ab0 <myproc>
    8000329c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000329e:	23053983          	ld	s3,560(a0)
    800032a2:	0a89a903          	lw	s2,168(s3)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800032a6:	fff9071b          	addiw	a4,s2,-1
    800032aa:	47e5                	li	a5,25
    800032ac:	02e7ec63          	bltu	a5,a4,800032e4 <syscall+0x5e>
    800032b0:	e052                	sd	s4,0(sp)
    800032b2:	00391713          	slli	a4,s2,0x3
    800032b6:	00005797          	auipc	a5,0x5
    800032ba:	56a78793          	addi	a5,a5,1386 # 80008820 <syscalls>
    800032be:	97ba                	add	a5,a5,a4
    800032c0:	639c                	ld	a5,0(a5)
    800032c2:	c385                	beqz	a5,800032e2 <syscall+0x5c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800032c4:	9782                	jalr	a5
    800032c6:	06a9b823          	sd	a0,112(s3)
    if(num<26 && num>=0)
    800032ca:	47e5                	li	a5,25
    800032cc:	0527e363          	bltu	a5,s2,80003312 <syscall+0x8c>
    {
      p->syscall_count[num]++;
    800032d0:	090a                	slli	s2,s2,0x2
    800032d2:	9926                	add	s2,s2,s1
    800032d4:	04092783          	lw	a5,64(s2)
    800032d8:	2785                	addiw	a5,a5,1
    800032da:	04f92023          	sw	a5,64(s2)
    800032de:	6a02                	ld	s4,0(sp)
    800032e0:	a015                	j	80003304 <syscall+0x7e>
    800032e2:	6a02                	ld	s4,0(sp)
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032e4:	86ca                	mv	a3,s2
    800032e6:	33048613          	addi	a2,s1,816
    800032ea:	588c                	lw	a1,48(s1)
    800032ec:	00005517          	auipc	a0,0x5
    800032f0:	17450513          	addi	a0,a0,372 # 80008460 <etext+0x460>
    800032f4:	ffffd097          	auipc	ra,0xffffd
    800032f8:	2b6080e7          	jalr	694(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032fc:	2304b783          	ld	a5,560(s1)
    80003300:	577d                	li	a4,-1
    80003302:	fbb8                	sd	a4,112(a5)
  }
}
    80003304:	70a2                	ld	ra,40(sp)
    80003306:	7402                	ld	s0,32(sp)
    80003308:	64e2                	ld	s1,24(sp)
    8000330a:	6942                	ld	s2,16(sp)
    8000330c:	69a2                	ld	s3,8(sp)
    8000330e:	6145                	addi	sp,sp,48
    80003310:	8082                	ret
    80003312:	6a02                	ld	s4,0(sp)
    80003314:	bfc5                	j	80003304 <syscall+0x7e>

0000000080003316 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003316:	1101                	addi	sp,sp,-32
    80003318:	ec06                	sd	ra,24(sp)
    8000331a:	e822                	sd	s0,16(sp)
    8000331c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000331e:	fec40593          	addi	a1,s0,-20
    80003322:	4501                	li	a0,0
    80003324:	00000097          	auipc	ra,0x0
    80003328:	ef2080e7          	jalr	-270(ra) # 80003216 <argint>
  exit(n);
    8000332c:	fec42503          	lw	a0,-20(s0)
    80003330:	fffff097          	auipc	ra,0xfffff
    80003334:	358080e7          	jalr	856(ra) # 80002688 <exit>
  return 0; // not reached
}
    80003338:	4501                	li	a0,0
    8000333a:	60e2                	ld	ra,24(sp)
    8000333c:	6442                	ld	s0,16(sp)
    8000333e:	6105                	addi	sp,sp,32
    80003340:	8082                	ret

0000000080003342 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003342:	1141                	addi	sp,sp,-16
    80003344:	e406                	sd	ra,8(sp)
    80003346:	e022                	sd	s0,0(sp)
    80003348:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	766080e7          	jalr	1894(ra) # 80001ab0 <myproc>
}
    80003352:	5908                	lw	a0,48(a0)
    80003354:	60a2                	ld	ra,8(sp)
    80003356:	6402                	ld	s0,0(sp)
    80003358:	0141                	addi	sp,sp,16
    8000335a:	8082                	ret

000000008000335c <sys_fork>:

uint64
sys_fork(void)
{
    8000335c:	1141                	addi	sp,sp,-16
    8000335e:	e406                	sd	ra,8(sp)
    80003360:	e022                	sd	s0,0(sp)
    80003362:	0800                	addi	s0,sp,16
  return fork();
    80003364:	fffff097          	auipc	ra,0xfffff
    80003368:	b6e080e7          	jalr	-1170(ra) # 80001ed2 <fork>
}
    8000336c:	60a2                	ld	ra,8(sp)
    8000336e:	6402                	ld	s0,0(sp)
    80003370:	0141                	addi	sp,sp,16
    80003372:	8082                	ret

0000000080003374 <sys_wait>:

uint64
sys_wait(void)
{
    80003374:	1101                	addi	sp,sp,-32
    80003376:	ec06                	sd	ra,24(sp)
    80003378:	e822                	sd	s0,16(sp)
    8000337a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000337c:	fe840593          	addi	a1,s0,-24
    80003380:	4501                	li	a0,0
    80003382:	00000097          	auipc	ra,0x0
    80003386:	eb4080e7          	jalr	-332(ra) # 80003236 <argaddr>
  return wait(p);
    8000338a:	fe843503          	ld	a0,-24(s0)
    8000338e:	fffff097          	auipc	ra,0xfffff
    80003392:	4ac080e7          	jalr	1196(ra) # 8000283a <wait>
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000339e:	7179                	addi	sp,sp,-48
    800033a0:	f406                	sd	ra,40(sp)
    800033a2:	f022                	sd	s0,32(sp)
    800033a4:	ec26                	sd	s1,24(sp)
    800033a6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800033a8:	fdc40593          	addi	a1,s0,-36
    800033ac:	4501                	li	a0,0
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	e68080e7          	jalr	-408(ra) # 80003216 <argint>
  addr = myproc()->sz;
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	6fa080e7          	jalr	1786(ra) # 80001ab0 <myproc>
    800033be:	22053483          	ld	s1,544(a0)
  if (growproc(n) < 0)
    800033c2:	fdc42503          	lw	a0,-36(s0)
    800033c6:	fffff097          	auipc	ra,0xfffff
    800033ca:	aa8080e7          	jalr	-1368(ra) # 80001e6e <growproc>
    800033ce:	00054863          	bltz	a0,800033de <sys_sbrk+0x40>
    return -1;
  return addr;
}
    800033d2:	8526                	mv	a0,s1
    800033d4:	70a2                	ld	ra,40(sp)
    800033d6:	7402                	ld	s0,32(sp)
    800033d8:	64e2                	ld	s1,24(sp)
    800033da:	6145                	addi	sp,sp,48
    800033dc:	8082                	ret
    return -1;
    800033de:	54fd                	li	s1,-1
    800033e0:	bfcd                	j	800033d2 <sys_sbrk+0x34>

00000000800033e2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800033e2:	7139                	addi	sp,sp,-64
    800033e4:	fc06                	sd	ra,56(sp)
    800033e6:	f822                	sd	s0,48(sp)
    800033e8:	f04a                	sd	s2,32(sp)
    800033ea:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800033ec:	fcc40593          	addi	a1,s0,-52
    800033f0:	4501                	li	a0,0
    800033f2:	00000097          	auipc	ra,0x0
    800033f6:	e24080e7          	jalr	-476(ra) # 80003216 <argint>
  acquire(&tickslock);
    800033fa:	0001c517          	auipc	a0,0x1c
    800033fe:	84650513          	addi	a0,a0,-1978 # 8001ec40 <tickslock>
    80003402:	ffffe097          	auipc	ra,0xffffe
    80003406:	83c080e7          	jalr	-1988(ra) # 80000c3e <acquire>
  ticks0 = ticks;
    8000340a:	00005917          	auipc	s2,0x5
    8000340e:	58a92903          	lw	s2,1418(s2) # 80008994 <ticks>
  while (ticks - ticks0 < n)
    80003412:	fcc42783          	lw	a5,-52(s0)
    80003416:	c3b9                	beqz	a5,8000345c <sys_sleep+0x7a>
    80003418:	f426                	sd	s1,40(sp)
    8000341a:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000341c:	0001c997          	auipc	s3,0x1c
    80003420:	82498993          	addi	s3,s3,-2012 # 8001ec40 <tickslock>
    80003424:	00005497          	auipc	s1,0x5
    80003428:	57048493          	addi	s1,s1,1392 # 80008994 <ticks>
    if (killed(myproc()))
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	684080e7          	jalr	1668(ra) # 80001ab0 <myproc>
    80003434:	fffff097          	auipc	ra,0xfffff
    80003438:	3d4080e7          	jalr	980(ra) # 80002808 <killed>
    8000343c:	ed15                	bnez	a0,80003478 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000343e:	85ce                	mv	a1,s3
    80003440:	8526                	mv	a0,s1
    80003442:	fffff097          	auipc	ra,0xfffff
    80003446:	112080e7          	jalr	274(ra) # 80002554 <sleep>
  while (ticks - ticks0 < n)
    8000344a:	409c                	lw	a5,0(s1)
    8000344c:	412787bb          	subw	a5,a5,s2
    80003450:	fcc42703          	lw	a4,-52(s0)
    80003454:	fce7ece3          	bltu	a5,a4,8000342c <sys_sleep+0x4a>
    80003458:	74a2                	ld	s1,40(sp)
    8000345a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000345c:	0001b517          	auipc	a0,0x1b
    80003460:	7e450513          	addi	a0,a0,2020 # 8001ec40 <tickslock>
    80003464:	ffffe097          	auipc	ra,0xffffe
    80003468:	88a080e7          	jalr	-1910(ra) # 80000cee <release>
  return 0;
    8000346c:	4501                	li	a0,0
}
    8000346e:	70e2                	ld	ra,56(sp)
    80003470:	7442                	ld	s0,48(sp)
    80003472:	7902                	ld	s2,32(sp)
    80003474:	6121                	addi	sp,sp,64
    80003476:	8082                	ret
      release(&tickslock);
    80003478:	0001b517          	auipc	a0,0x1b
    8000347c:	7c850513          	addi	a0,a0,1992 # 8001ec40 <tickslock>
    80003480:	ffffe097          	auipc	ra,0xffffe
    80003484:	86e080e7          	jalr	-1938(ra) # 80000cee <release>
      return -1;
    80003488:	557d                	li	a0,-1
    8000348a:	74a2                	ld	s1,40(sp)
    8000348c:	69e2                	ld	s3,24(sp)
    8000348e:	b7c5                	j	8000346e <sys_sleep+0x8c>

0000000080003490 <sys_kill>:

uint64
sys_kill(void)
{
    80003490:	1101                	addi	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003498:	fec40593          	addi	a1,s0,-20
    8000349c:	4501                	li	a0,0
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	d78080e7          	jalr	-648(ra) # 80003216 <argint>
  return kill(pid);
    800034a6:	fec42503          	lw	a0,-20(s0)
    800034aa:	fffff097          	auipc	ra,0xfffff
    800034ae:	2c0080e7          	jalr	704(ra) # 8000276a <kill>
}
    800034b2:	60e2                	ld	ra,24(sp)
    800034b4:	6442                	ld	s0,16(sp)
    800034b6:	6105                	addi	sp,sp,32
    800034b8:	8082                	ret

00000000800034ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034ba:	1101                	addi	sp,sp,-32
    800034bc:	ec06                	sd	ra,24(sp)
    800034be:	e822                	sd	s0,16(sp)
    800034c0:	e426                	sd	s1,8(sp)
    800034c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034c4:	0001b517          	auipc	a0,0x1b
    800034c8:	77c50513          	addi	a0,a0,1916 # 8001ec40 <tickslock>
    800034cc:	ffffd097          	auipc	ra,0xffffd
    800034d0:	772080e7          	jalr	1906(ra) # 80000c3e <acquire>
  xticks = ticks;
    800034d4:	00005497          	auipc	s1,0x5
    800034d8:	4c04a483          	lw	s1,1216(s1) # 80008994 <ticks>
  release(&tickslock);
    800034dc:	0001b517          	auipc	a0,0x1b
    800034e0:	76450513          	addi	a0,a0,1892 # 8001ec40 <tickslock>
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	80a080e7          	jalr	-2038(ra) # 80000cee <release>
  return xticks;
}
    800034ec:	02049513          	slli	a0,s1,0x20
    800034f0:	9101                	srli	a0,a0,0x20
    800034f2:	60e2                	ld	ra,24(sp)
    800034f4:	6442                	ld	s0,16(sp)
    800034f6:	64a2                	ld	s1,8(sp)
    800034f8:	6105                	addi	sp,sp,32
    800034fa:	8082                	ret

00000000800034fc <sys_waitx>:

uint64
sys_waitx(void)
{
    800034fc:	715d                	addi	sp,sp,-80
    800034fe:	e486                	sd	ra,72(sp)
    80003500:	e0a2                	sd	s0,64(sp)
    80003502:	fc26                	sd	s1,56(sp)
    80003504:	f84a                	sd	s2,48(sp)
    80003506:	f44e                	sd	s3,40(sp)
    80003508:	0880                	addi	s0,sp,80
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000350a:	fc840593          	addi	a1,s0,-56
    8000350e:	4501                	li	a0,0
    80003510:	00000097          	auipc	ra,0x0
    80003514:	d26080e7          	jalr	-730(ra) # 80003236 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003518:	fc040593          	addi	a1,s0,-64
    8000351c:	4505                	li	a0,1
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	d18080e7          	jalr	-744(ra) # 80003236 <argaddr>
  argaddr(2, &addr2);
    80003526:	fb840593          	addi	a1,s0,-72
    8000352a:	4509                	li	a0,2
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	d0a080e7          	jalr	-758(ra) # 80003236 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003534:	fb440993          	addi	s3,s0,-76
    80003538:	fb040613          	addi	a2,s0,-80
    8000353c:	85ce                	mv	a1,s3
    8000353e:	fc843503          	ld	a0,-56(s0)
    80003542:	fffff097          	auipc	ra,0xfffff
    80003546:	5a0080e7          	jalr	1440(ra) # 80002ae2 <waitx>
    8000354a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	564080e7          	jalr	1380(ra) # 80001ab0 <myproc>
    80003554:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003556:	4691                	li	a3,4
    80003558:	864e                	mv	a2,s3
    8000355a:	fc043583          	ld	a1,-64(s0)
    8000355e:	22853503          	ld	a0,552(a0)
    80003562:	ffffe097          	auipc	ra,0xffffe
    80003566:	1ae080e7          	jalr	430(ra) # 80001710 <copyout>
    return -1;
    8000356a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000356c:	02054063          	bltz	a0,8000358c <sys_waitx+0x90>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003570:	4691                	li	a3,4
    80003572:	fb040613          	addi	a2,s0,-80
    80003576:	fb843583          	ld	a1,-72(s0)
    8000357a:	2284b503          	ld	a0,552(s1)
    8000357e:	ffffe097          	auipc	ra,0xffffe
    80003582:	192080e7          	jalr	402(ra) # 80001710 <copyout>
    80003586:	00054b63          	bltz	a0,8000359c <sys_waitx+0xa0>
    return -1;
  return ret;
    8000358a:	87ca                	mv	a5,s2
}
    8000358c:	853e                	mv	a0,a5
    8000358e:	60a6                	ld	ra,72(sp)
    80003590:	6406                	ld	s0,64(sp)
    80003592:	74e2                	ld	s1,56(sp)
    80003594:	7942                	ld	s2,48(sp)
    80003596:	79a2                	ld	s3,40(sp)
    80003598:	6161                	addi	sp,sp,80
    8000359a:	8082                	ret
    return -1;
    8000359c:	57fd                	li	a5,-1
    8000359e:	b7fd                	j	8000358c <sys_waitx+0x90>

00000000800035a0 <sys_getSysCount>:

uint64
sys_getSysCount(void)
{
    800035a0:	1101                	addi	sp,sp,-32
    800035a2:	ec06                	sd	ra,24(sp)
    800035a4:	e822                	sd	s0,16(sp)
    800035a6:	1000                	addi	s0,sp,32
  int k;
  argint(0, &k);
    800035a8:	fec40593          	addi	a1,s0,-20
    800035ac:	4501                	li	a0,0
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	c68080e7          	jalr	-920(ra) # 80003216 <argint>
  struct proc *p = myproc();
    800035b6:	ffffe097          	auipc	ra,0xffffe
    800035ba:	4fa080e7          	jalr	1274(ra) # 80001ab0 <myproc>
  return p->syscall_count[k];
    800035be:	fec42783          	lw	a5,-20(s0)
    800035c2:	07c1                	addi	a5,a5,16
    800035c4:	078a                	slli	a5,a5,0x2
    800035c6:	953e                	add	a0,a0,a5
}
    800035c8:	4108                	lw	a0,0(a0)
    800035ca:	60e2                	ld	ra,24(sp)
    800035cc:	6442                	ld	s0,16(sp)
    800035ce:	6105                	addi	sp,sp,32
    800035d0:	8082                	ret

00000000800035d2 <sys_sigalarm>:

// In sysproc.c
uint64 sys_sigalarm(void)
{
    800035d2:	1101                	addi	sp,sp,-32
    800035d4:	ec06                	sd	ra,24(sp)
    800035d6:	e822                	sd	s0,16(sp)
    800035d8:	1000                	addi	s0,sp,32
  int interval;
  argint(0, &interval);
    800035da:	fec40593          	addi	a1,s0,-20
    800035de:	4501                	li	a0,0
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	c36080e7          	jalr	-970(ra) # 80003216 <argint>
  uint64 handler;
  argaddr(1, &handler);
    800035e8:	fe040593          	addi	a1,s0,-32
    800035ec:	4505                	li	a0,1
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	c48080e7          	jalr	-952(ra) # 80003236 <argaddr>
  struct proc *p = myproc();
    800035f6:	ffffe097          	auipc	ra,0xffffe
    800035fa:	4ba080e7          	jalr	1210(ra) # 80001ab0 <myproc>
  p->alarm_interval = interval;
    800035fe:	fec42783          	lw	a5,-20(s0)
    80003602:	0ef52223          	sw	a5,228(a0)
  p->handler = handler;
    80003606:	fe043783          	ld	a5,-32(s0)
    8000360a:	f57c                	sd	a5,232(a0)
  p->ticks = 0;
    8000360c:	0e052023          	sw	zero,224(a0)
  p->alarm_active = 0;
    80003610:	20052823          	sw	zero,528(a0)
  return 0;
}
    80003614:	4501                	li	a0,0
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    8000361e:	1101                	addi	sp,sp,-32
    80003620:	ec06                	sd	ra,24(sp)
    80003622:	e822                	sd	s0,16(sp)
    80003624:	e426                	sd	s1,8(sp)
    80003626:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003628:	ffffe097          	auipc	ra,0xffffe
    8000362c:	488080e7          	jalr	1160(ra) # 80001ab0 <myproc>
    80003630:	84aa                	mv	s1,a0
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe));
    80003632:	12000613          	li	a2,288
    80003636:	0f050593          	addi	a1,a0,240
    8000363a:	23053503          	ld	a0,560(a0)
    8000363e:	ffffd097          	auipc	ra,0xffffd
    80003642:	75c080e7          	jalr	1884(ra) # 80000d9a <memmove>
  p->alarm_active = 0;
    80003646:	2004a823          	sw	zero,528(s1)
  return p->trapframe->a0;
    8000364a:	2304b783          	ld	a5,560(s1)
}
    8000364e:	7ba8                	ld	a0,112(a5)
    80003650:	60e2                	ld	ra,24(sp)
    80003652:	6442                	ld	s0,16(sp)
    80003654:	64a2                	ld	s1,8(sp)
    80003656:	6105                	addi	sp,sp,32
    80003658:	8082                	ret

000000008000365a <sys_settickets>:

uint64
sys_settickets(void)
{
    8000365a:	1101                	addi	sp,sp,-32
    8000365c:	ec06                	sd	ra,24(sp)
    8000365e:	e822                	sd	s0,16(sp)
    80003660:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    80003662:	fec40593          	addi	a1,s0,-20
    80003666:	4501                	li	a0,0
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	bae080e7          	jalr	-1106(ra) # 80003216 <argint>
  if (number < 1)
    80003670:	fec42783          	lw	a5,-20(s0)
    return -1;
    80003674:	557d                	li	a0,-1
  if (number < 1)
    80003676:	00f05b63          	blez	a5,8000368c <sys_settickets+0x32>
  struct proc *p = myproc();
    8000367a:	ffffe097          	auipc	ra,0xffffe
    8000367e:	436080e7          	jalr	1078(ra) # 80001ab0 <myproc>
  p->tickets = number;
    80003682:	fec42783          	lw	a5,-20(s0)
    80003686:	0cf52023          	sw	a5,192(a0)
  return 0;
    8000368a:	4501                	li	a0,0
    8000368c:	60e2                	ld	ra,24(sp)
    8000368e:	6442                	ld	s0,16(sp)
    80003690:	6105                	addi	sp,sp,32
    80003692:	8082                	ret

0000000080003694 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003694:	7179                	addi	sp,sp,-48
    80003696:	f406                	sd	ra,40(sp)
    80003698:	f022                	sd	s0,32(sp)
    8000369a:	ec26                	sd	s1,24(sp)
    8000369c:	e84a                	sd	s2,16(sp)
    8000369e:	e44e                	sd	s3,8(sp)
    800036a0:	e052                	sd	s4,0(sp)
    800036a2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036a4:	00005597          	auipc	a1,0x5
    800036a8:	ddc58593          	addi	a1,a1,-548 # 80008480 <etext+0x480>
    800036ac:	0001b517          	auipc	a0,0x1b
    800036b0:	5ac50513          	addi	a0,a0,1452 # 8001ec58 <bcache>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	4f6080e7          	jalr	1270(ra) # 80000baa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036bc:	00023797          	auipc	a5,0x23
    800036c0:	59c78793          	addi	a5,a5,1436 # 80026c58 <bcache+0x8000>
    800036c4:	00023717          	auipc	a4,0x23
    800036c8:	7fc70713          	addi	a4,a4,2044 # 80026ec0 <bcache+0x8268>
    800036cc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036d0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036d4:	0001b497          	auipc	s1,0x1b
    800036d8:	59c48493          	addi	s1,s1,1436 # 8001ec70 <bcache+0x18>
    b->next = bcache.head.next;
    800036dc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036de:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036e0:	00005a17          	auipc	s4,0x5
    800036e4:	da8a0a13          	addi	s4,s4,-600 # 80008488 <etext+0x488>
    b->next = bcache.head.next;
    800036e8:	2b893783          	ld	a5,696(s2)
    800036ec:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036ee:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036f2:	85d2                	mv	a1,s4
    800036f4:	01048513          	addi	a0,s1,16
    800036f8:	00001097          	auipc	ra,0x1
    800036fc:	4e4080e7          	jalr	1252(ra) # 80004bdc <initsleeplock>
    bcache.head.next->prev = b;
    80003700:	2b893783          	ld	a5,696(s2)
    80003704:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003706:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000370a:	45848493          	addi	s1,s1,1112
    8000370e:	fd349de3          	bne	s1,s3,800036e8 <binit+0x54>
  }
}
    80003712:	70a2                	ld	ra,40(sp)
    80003714:	7402                	ld	s0,32(sp)
    80003716:	64e2                	ld	s1,24(sp)
    80003718:	6942                	ld	s2,16(sp)
    8000371a:	69a2                	ld	s3,8(sp)
    8000371c:	6a02                	ld	s4,0(sp)
    8000371e:	6145                	addi	sp,sp,48
    80003720:	8082                	ret

0000000080003722 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003722:	7179                	addi	sp,sp,-48
    80003724:	f406                	sd	ra,40(sp)
    80003726:	f022                	sd	s0,32(sp)
    80003728:	ec26                	sd	s1,24(sp)
    8000372a:	e84a                	sd	s2,16(sp)
    8000372c:	e44e                	sd	s3,8(sp)
    8000372e:	1800                	addi	s0,sp,48
    80003730:	892a                	mv	s2,a0
    80003732:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003734:	0001b517          	auipc	a0,0x1b
    80003738:	52450513          	addi	a0,a0,1316 # 8001ec58 <bcache>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	502080e7          	jalr	1282(ra) # 80000c3e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003744:	00023497          	auipc	s1,0x23
    80003748:	7cc4b483          	ld	s1,1996(s1) # 80026f10 <bcache+0x82b8>
    8000374c:	00023797          	auipc	a5,0x23
    80003750:	77478793          	addi	a5,a5,1908 # 80026ec0 <bcache+0x8268>
    80003754:	02f48f63          	beq	s1,a5,80003792 <bread+0x70>
    80003758:	873e                	mv	a4,a5
    8000375a:	a021                	j	80003762 <bread+0x40>
    8000375c:	68a4                	ld	s1,80(s1)
    8000375e:	02e48a63          	beq	s1,a4,80003792 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003762:	449c                	lw	a5,8(s1)
    80003764:	ff279ce3          	bne	a5,s2,8000375c <bread+0x3a>
    80003768:	44dc                	lw	a5,12(s1)
    8000376a:	ff3799e3          	bne	a5,s3,8000375c <bread+0x3a>
      b->refcnt++;
    8000376e:	40bc                	lw	a5,64(s1)
    80003770:	2785                	addiw	a5,a5,1
    80003772:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003774:	0001b517          	auipc	a0,0x1b
    80003778:	4e450513          	addi	a0,a0,1252 # 8001ec58 <bcache>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	572080e7          	jalr	1394(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    80003784:	01048513          	addi	a0,s1,16
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	48e080e7          	jalr	1166(ra) # 80004c16 <acquiresleep>
      return b;
    80003790:	a8b9                	j	800037ee <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003792:	00023497          	auipc	s1,0x23
    80003796:	7764b483          	ld	s1,1910(s1) # 80026f08 <bcache+0x82b0>
    8000379a:	00023797          	auipc	a5,0x23
    8000379e:	72678793          	addi	a5,a5,1830 # 80026ec0 <bcache+0x8268>
    800037a2:	00f48863          	beq	s1,a5,800037b2 <bread+0x90>
    800037a6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037a8:	40bc                	lw	a5,64(s1)
    800037aa:	cf81                	beqz	a5,800037c2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037ac:	64a4                	ld	s1,72(s1)
    800037ae:	fee49de3          	bne	s1,a4,800037a8 <bread+0x86>
  panic("bget: no buffers");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	cde50513          	addi	a0,a0,-802 # 80008490 <etext+0x490>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	da6080e7          	jalr	-602(ra) # 80000560 <panic>
      b->dev = dev;
    800037c2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037c6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037ca:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037ce:	4785                	li	a5,1
    800037d0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037d2:	0001b517          	auipc	a0,0x1b
    800037d6:	48650513          	addi	a0,a0,1158 # 8001ec58 <bcache>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	514080e7          	jalr	1300(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    800037e2:	01048513          	addi	a0,s1,16
    800037e6:	00001097          	auipc	ra,0x1
    800037ea:	430080e7          	jalr	1072(ra) # 80004c16 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037ee:	409c                	lw	a5,0(s1)
    800037f0:	cb89                	beqz	a5,80003802 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037f2:	8526                	mv	a0,s1
    800037f4:	70a2                	ld	ra,40(sp)
    800037f6:	7402                	ld	s0,32(sp)
    800037f8:	64e2                	ld	s1,24(sp)
    800037fa:	6942                	ld	s2,16(sp)
    800037fc:	69a2                	ld	s3,8(sp)
    800037fe:	6145                	addi	sp,sp,48
    80003800:	8082                	ret
    virtio_disk_rw(b, 0);
    80003802:	4581                	li	a1,0
    80003804:	8526                	mv	a0,s1
    80003806:	00003097          	auipc	ra,0x3
    8000380a:	112080e7          	jalr	274(ra) # 80006918 <virtio_disk_rw>
    b->valid = 1;
    8000380e:	4785                	li	a5,1
    80003810:	c09c                	sw	a5,0(s1)
  return b;
    80003812:	b7c5                	j	800037f2 <bread+0xd0>

0000000080003814 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	1000                	addi	s0,sp,32
    8000381e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003820:	0541                	addi	a0,a0,16
    80003822:	00001097          	auipc	ra,0x1
    80003826:	48e080e7          	jalr	1166(ra) # 80004cb0 <holdingsleep>
    8000382a:	cd01                	beqz	a0,80003842 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000382c:	4585                	li	a1,1
    8000382e:	8526                	mv	a0,s1
    80003830:	00003097          	auipc	ra,0x3
    80003834:	0e8080e7          	jalr	232(ra) # 80006918 <virtio_disk_rw>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret
    panic("bwrite");
    80003842:	00005517          	auipc	a0,0x5
    80003846:	c6650513          	addi	a0,a0,-922 # 800084a8 <etext+0x4a8>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	d16080e7          	jalr	-746(ra) # 80000560 <panic>

0000000080003852 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003852:	1101                	addi	sp,sp,-32
    80003854:	ec06                	sd	ra,24(sp)
    80003856:	e822                	sd	s0,16(sp)
    80003858:	e426                	sd	s1,8(sp)
    8000385a:	e04a                	sd	s2,0(sp)
    8000385c:	1000                	addi	s0,sp,32
    8000385e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003860:	01050913          	addi	s2,a0,16
    80003864:	854a                	mv	a0,s2
    80003866:	00001097          	auipc	ra,0x1
    8000386a:	44a080e7          	jalr	1098(ra) # 80004cb0 <holdingsleep>
    8000386e:	c535                	beqz	a0,800038da <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    80003870:	854a                	mv	a0,s2
    80003872:	00001097          	auipc	ra,0x1
    80003876:	3fa080e7          	jalr	1018(ra) # 80004c6c <releasesleep>

  acquire(&bcache.lock);
    8000387a:	0001b517          	auipc	a0,0x1b
    8000387e:	3de50513          	addi	a0,a0,990 # 8001ec58 <bcache>
    80003882:	ffffd097          	auipc	ra,0xffffd
    80003886:	3bc080e7          	jalr	956(ra) # 80000c3e <acquire>
  b->refcnt--;
    8000388a:	40bc                	lw	a5,64(s1)
    8000388c:	37fd                	addiw	a5,a5,-1
    8000388e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003890:	e79d                	bnez	a5,800038be <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003892:	68b8                	ld	a4,80(s1)
    80003894:	64bc                	ld	a5,72(s1)
    80003896:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003898:	68b8                	ld	a4,80(s1)
    8000389a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000389c:	00023797          	auipc	a5,0x23
    800038a0:	3bc78793          	addi	a5,a5,956 # 80026c58 <bcache+0x8000>
    800038a4:	2b87b703          	ld	a4,696(a5)
    800038a8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038aa:	00023717          	auipc	a4,0x23
    800038ae:	61670713          	addi	a4,a4,1558 # 80026ec0 <bcache+0x8268>
    800038b2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038b4:	2b87b703          	ld	a4,696(a5)
    800038b8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038ba:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038be:	0001b517          	auipc	a0,0x1b
    800038c2:	39a50513          	addi	a0,a0,922 # 8001ec58 <bcache>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	428080e7          	jalr	1064(ra) # 80000cee <release>
}
    800038ce:	60e2                	ld	ra,24(sp)
    800038d0:	6442                	ld	s0,16(sp)
    800038d2:	64a2                	ld	s1,8(sp)
    800038d4:	6902                	ld	s2,0(sp)
    800038d6:	6105                	addi	sp,sp,32
    800038d8:	8082                	ret
    panic("brelse");
    800038da:	00005517          	auipc	a0,0x5
    800038de:	bd650513          	addi	a0,a0,-1066 # 800084b0 <etext+0x4b0>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	c7e080e7          	jalr	-898(ra) # 80000560 <panic>

00000000800038ea <bpin>:

void
bpin(struct buf *b) {
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	1000                	addi	s0,sp,32
    800038f4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038f6:	0001b517          	auipc	a0,0x1b
    800038fa:	36250513          	addi	a0,a0,866 # 8001ec58 <bcache>
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	340080e7          	jalr	832(ra) # 80000c3e <acquire>
  b->refcnt++;
    80003906:	40bc                	lw	a5,64(s1)
    80003908:	2785                	addiw	a5,a5,1
    8000390a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000390c:	0001b517          	auipc	a0,0x1b
    80003910:	34c50513          	addi	a0,a0,844 # 8001ec58 <bcache>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	3da080e7          	jalr	986(ra) # 80000cee <release>
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret

0000000080003926 <bunpin>:

void
bunpin(struct buf *b) {
    80003926:	1101                	addi	sp,sp,-32
    80003928:	ec06                	sd	ra,24(sp)
    8000392a:	e822                	sd	s0,16(sp)
    8000392c:	e426                	sd	s1,8(sp)
    8000392e:	1000                	addi	s0,sp,32
    80003930:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003932:	0001b517          	auipc	a0,0x1b
    80003936:	32650513          	addi	a0,a0,806 # 8001ec58 <bcache>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	304080e7          	jalr	772(ra) # 80000c3e <acquire>
  b->refcnt--;
    80003942:	40bc                	lw	a5,64(s1)
    80003944:	37fd                	addiw	a5,a5,-1
    80003946:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003948:	0001b517          	auipc	a0,0x1b
    8000394c:	31050513          	addi	a0,a0,784 # 8001ec58 <bcache>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	39e080e7          	jalr	926(ra) # 80000cee <release>
}
    80003958:	60e2                	ld	ra,24(sp)
    8000395a:	6442                	ld	s0,16(sp)
    8000395c:	64a2                	ld	s1,8(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret

0000000080003962 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	e04a                	sd	s2,0(sp)
    8000396c:	1000                	addi	s0,sp,32
    8000396e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003970:	00d5d79b          	srliw	a5,a1,0xd
    80003974:	00024597          	auipc	a1,0x24
    80003978:	9c05a583          	lw	a1,-1600(a1) # 80027334 <sb+0x1c>
    8000397c:	9dbd                	addw	a1,a1,a5
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	da4080e7          	jalr	-604(ra) # 80003722 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003986:	0074f713          	andi	a4,s1,7
    8000398a:	4785                	li	a5,1
    8000398c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003990:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003992:	90d9                	srli	s1,s1,0x36
    80003994:	00950733          	add	a4,a0,s1
    80003998:	05874703          	lbu	a4,88(a4)
    8000399c:	00e7f6b3          	and	a3,a5,a4
    800039a0:	c69d                	beqz	a3,800039ce <bfree+0x6c>
    800039a2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039a4:	94aa                	add	s1,s1,a0
    800039a6:	fff7c793          	not	a5,a5
    800039aa:	8f7d                	and	a4,a4,a5
    800039ac:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800039b0:	00001097          	auipc	ra,0x1
    800039b4:	148080e7          	jalr	328(ra) # 80004af8 <log_write>
  brelse(bp);
    800039b8:	854a                	mv	a0,s2
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	e98080e7          	jalr	-360(ra) # 80003852 <brelse>
}
    800039c2:	60e2                	ld	ra,24(sp)
    800039c4:	6442                	ld	s0,16(sp)
    800039c6:	64a2                	ld	s1,8(sp)
    800039c8:	6902                	ld	s2,0(sp)
    800039ca:	6105                	addi	sp,sp,32
    800039cc:	8082                	ret
    panic("freeing free block");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	aea50513          	addi	a0,a0,-1302 # 800084b8 <etext+0x4b8>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	b8a080e7          	jalr	-1142(ra) # 80000560 <panic>

00000000800039de <balloc>:
{
    800039de:	715d                	addi	sp,sp,-80
    800039e0:	e486                	sd	ra,72(sp)
    800039e2:	e0a2                	sd	s0,64(sp)
    800039e4:	fc26                	sd	s1,56(sp)
    800039e6:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800039e8:	00024797          	auipc	a5,0x24
    800039ec:	9347a783          	lw	a5,-1740(a5) # 8002731c <sb+0x4>
    800039f0:	10078863          	beqz	a5,80003b00 <balloc+0x122>
    800039f4:	f84a                	sd	s2,48(sp)
    800039f6:	f44e                	sd	s3,40(sp)
    800039f8:	f052                	sd	s4,32(sp)
    800039fa:	ec56                	sd	s5,24(sp)
    800039fc:	e85a                	sd	s6,16(sp)
    800039fe:	e45e                	sd	s7,8(sp)
    80003a00:	e062                	sd	s8,0(sp)
    80003a02:	8baa                	mv	s7,a0
    80003a04:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a06:	00024b17          	auipc	s6,0x24
    80003a0a:	912b0b13          	addi	s6,s6,-1774 # 80027318 <sb>
      m = 1 << (bi % 8);
    80003a0e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a10:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a12:	6c09                	lui	s8,0x2
    80003a14:	a049                	j	80003a96 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a16:	97ca                	add	a5,a5,s2
    80003a18:	8e55                	or	a2,a2,a3
    80003a1a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a1e:	854a                	mv	a0,s2
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	0d8080e7          	jalr	216(ra) # 80004af8 <log_write>
        brelse(bp);
    80003a28:	854a                	mv	a0,s2
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	e28080e7          	jalr	-472(ra) # 80003852 <brelse>
  bp = bread(dev, bno);
    80003a32:	85a6                	mv	a1,s1
    80003a34:	855e                	mv	a0,s7
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	cec080e7          	jalr	-788(ra) # 80003722 <bread>
    80003a3e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a40:	40000613          	li	a2,1024
    80003a44:	4581                	li	a1,0
    80003a46:	05850513          	addi	a0,a0,88
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	2ec080e7          	jalr	748(ra) # 80000d36 <memset>
  log_write(bp);
    80003a52:	854a                	mv	a0,s2
    80003a54:	00001097          	auipc	ra,0x1
    80003a58:	0a4080e7          	jalr	164(ra) # 80004af8 <log_write>
  brelse(bp);
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	df4080e7          	jalr	-524(ra) # 80003852 <brelse>
}
    80003a66:	7942                	ld	s2,48(sp)
    80003a68:	79a2                	ld	s3,40(sp)
    80003a6a:	7a02                	ld	s4,32(sp)
    80003a6c:	6ae2                	ld	s5,24(sp)
    80003a6e:	6b42                	ld	s6,16(sp)
    80003a70:	6ba2                	ld	s7,8(sp)
    80003a72:	6c02                	ld	s8,0(sp)
}
    80003a74:	8526                	mv	a0,s1
    80003a76:	60a6                	ld	ra,72(sp)
    80003a78:	6406                	ld	s0,64(sp)
    80003a7a:	74e2                	ld	s1,56(sp)
    80003a7c:	6161                	addi	sp,sp,80
    80003a7e:	8082                	ret
    brelse(bp);
    80003a80:	854a                	mv	a0,s2
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	dd0080e7          	jalr	-560(ra) # 80003852 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a8a:	015c0abb          	addw	s5,s8,s5
    80003a8e:	004b2783          	lw	a5,4(s6)
    80003a92:	06faf063          	bgeu	s5,a5,80003af2 <balloc+0x114>
    bp = bread(dev, BBLOCK(b, sb));
    80003a96:	41fad79b          	sraiw	a5,s5,0x1f
    80003a9a:	0137d79b          	srliw	a5,a5,0x13
    80003a9e:	015787bb          	addw	a5,a5,s5
    80003aa2:	40d7d79b          	sraiw	a5,a5,0xd
    80003aa6:	01cb2583          	lw	a1,28(s6)
    80003aaa:	9dbd                	addw	a1,a1,a5
    80003aac:	855e                	mv	a0,s7
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	c74080e7          	jalr	-908(ra) # 80003722 <bread>
    80003ab6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ab8:	004b2503          	lw	a0,4(s6)
    80003abc:	84d6                	mv	s1,s5
    80003abe:	4701                	li	a4,0
    80003ac0:	fca4f0e3          	bgeu	s1,a0,80003a80 <balloc+0xa2>
      m = 1 << (bi % 8);
    80003ac4:	00777693          	andi	a3,a4,7
    80003ac8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003acc:	41f7579b          	sraiw	a5,a4,0x1f
    80003ad0:	01d7d79b          	srliw	a5,a5,0x1d
    80003ad4:	9fb9                	addw	a5,a5,a4
    80003ad6:	4037d79b          	sraiw	a5,a5,0x3
    80003ada:	00f90633          	add	a2,s2,a5
    80003ade:	05864603          	lbu	a2,88(a2)
    80003ae2:	00c6f5b3          	and	a1,a3,a2
    80003ae6:	d985                	beqz	a1,80003a16 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ae8:	2705                	addiw	a4,a4,1
    80003aea:	2485                	addiw	s1,s1,1
    80003aec:	fd471ae3          	bne	a4,s4,80003ac0 <balloc+0xe2>
    80003af0:	bf41                	j	80003a80 <balloc+0xa2>
    80003af2:	7942                	ld	s2,48(sp)
    80003af4:	79a2                	ld	s3,40(sp)
    80003af6:	7a02                	ld	s4,32(sp)
    80003af8:	6ae2                	ld	s5,24(sp)
    80003afa:	6b42                	ld	s6,16(sp)
    80003afc:	6ba2                	ld	s7,8(sp)
    80003afe:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003b00:	00005517          	auipc	a0,0x5
    80003b04:	9d050513          	addi	a0,a0,-1584 # 800084d0 <etext+0x4d0>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	aa2080e7          	jalr	-1374(ra) # 800005aa <printf>
  return 0;
    80003b10:	4481                	li	s1,0
    80003b12:	b78d                	j	80003a74 <balloc+0x96>

0000000080003b14 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b14:	7179                	addi	sp,sp,-48
    80003b16:	f406                	sd	ra,40(sp)
    80003b18:	f022                	sd	s0,32(sp)
    80003b1a:	ec26                	sd	s1,24(sp)
    80003b1c:	e84a                	sd	s2,16(sp)
    80003b1e:	e44e                	sd	s3,8(sp)
    80003b20:	1800                	addi	s0,sp,48
    80003b22:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b24:	47ad                	li	a5,11
    80003b26:	02b7e563          	bltu	a5,a1,80003b50 <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003b2a:	02059793          	slli	a5,a1,0x20
    80003b2e:	01e7d593          	srli	a1,a5,0x1e
    80003b32:	00b504b3          	add	s1,a0,a1
    80003b36:	0504a903          	lw	s2,80(s1)
    80003b3a:	06091b63          	bnez	s2,80003bb0 <bmap+0x9c>
      addr = balloc(ip->dev);
    80003b3e:	4108                	lw	a0,0(a0)
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	e9e080e7          	jalr	-354(ra) # 800039de <balloc>
    80003b48:	892a                	mv	s2,a0
      if(addr == 0)
    80003b4a:	c13d                	beqz	a0,80003bb0 <bmap+0x9c>
        return 0;
      ip->addrs[bn] = addr;
    80003b4c:	c8a8                	sw	a0,80(s1)
    80003b4e:	a08d                	j	80003bb0 <bmap+0x9c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b50:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003b54:	0ff00793          	li	a5,255
    80003b58:	0897e363          	bltu	a5,s1,80003bde <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b5c:	08052903          	lw	s2,128(a0)
    80003b60:	00091d63          	bnez	s2,80003b7a <bmap+0x66>
      addr = balloc(ip->dev);
    80003b64:	4108                	lw	a0,0(a0)
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	e78080e7          	jalr	-392(ra) # 800039de <balloc>
    80003b6e:	892a                	mv	s2,a0
      if(addr == 0)
    80003b70:	c121                	beqz	a0,80003bb0 <bmap+0x9c>
    80003b72:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b74:	08a9a023          	sw	a0,128(s3)
    80003b78:	a011                	j	80003b7c <bmap+0x68>
    80003b7a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003b7c:	85ca                	mv	a1,s2
    80003b7e:	0009a503          	lw	a0,0(s3)
    80003b82:	00000097          	auipc	ra,0x0
    80003b86:	ba0080e7          	jalr	-1120(ra) # 80003722 <bread>
    80003b8a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b8c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b90:	02049713          	slli	a4,s1,0x20
    80003b94:	01e75593          	srli	a1,a4,0x1e
    80003b98:	00b784b3          	add	s1,a5,a1
    80003b9c:	0004a903          	lw	s2,0(s1)
    80003ba0:	02090063          	beqz	s2,80003bc0 <bmap+0xac>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	00000097          	auipc	ra,0x0
    80003baa:	cac080e7          	jalr	-852(ra) # 80003852 <brelse>
    return addr;
    80003bae:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003bb0:	854a                	mv	a0,s2
    80003bb2:	70a2                	ld	ra,40(sp)
    80003bb4:	7402                	ld	s0,32(sp)
    80003bb6:	64e2                	ld	s1,24(sp)
    80003bb8:	6942                	ld	s2,16(sp)
    80003bba:	69a2                	ld	s3,8(sp)
    80003bbc:	6145                	addi	sp,sp,48
    80003bbe:	8082                	ret
      addr = balloc(ip->dev);
    80003bc0:	0009a503          	lw	a0,0(s3)
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	e1a080e7          	jalr	-486(ra) # 800039de <balloc>
    80003bcc:	892a                	mv	s2,a0
      if(addr){
    80003bce:	d979                	beqz	a0,80003ba4 <bmap+0x90>
        a[bn] = addr;
    80003bd0:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003bd2:	8552                	mv	a0,s4
    80003bd4:	00001097          	auipc	ra,0x1
    80003bd8:	f24080e7          	jalr	-220(ra) # 80004af8 <log_write>
    80003bdc:	b7e1                	j	80003ba4 <bmap+0x90>
    80003bde:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003be0:	00005517          	auipc	a0,0x5
    80003be4:	90850513          	addi	a0,a0,-1784 # 800084e8 <etext+0x4e8>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	978080e7          	jalr	-1672(ra) # 80000560 <panic>

0000000080003bf0 <iget>:
{
    80003bf0:	7179                	addi	sp,sp,-48
    80003bf2:	f406                	sd	ra,40(sp)
    80003bf4:	f022                	sd	s0,32(sp)
    80003bf6:	ec26                	sd	s1,24(sp)
    80003bf8:	e84a                	sd	s2,16(sp)
    80003bfa:	e44e                	sd	s3,8(sp)
    80003bfc:	e052                	sd	s4,0(sp)
    80003bfe:	1800                	addi	s0,sp,48
    80003c00:	89aa                	mv	s3,a0
    80003c02:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c04:	00023517          	auipc	a0,0x23
    80003c08:	73450513          	addi	a0,a0,1844 # 80027338 <itable>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	032080e7          	jalr	50(ra) # 80000c3e <acquire>
  empty = 0;
    80003c14:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c16:	00023497          	auipc	s1,0x23
    80003c1a:	73a48493          	addi	s1,s1,1850 # 80027350 <itable+0x18>
    80003c1e:	00025697          	auipc	a3,0x25
    80003c22:	1c268693          	addi	a3,a3,450 # 80028de0 <log>
    80003c26:	a039                	j	80003c34 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c28:	02090b63          	beqz	s2,80003c5e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c2c:	08848493          	addi	s1,s1,136
    80003c30:	02d48a63          	beq	s1,a3,80003c64 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c34:	449c                	lw	a5,8(s1)
    80003c36:	fef059e3          	blez	a5,80003c28 <iget+0x38>
    80003c3a:	4098                	lw	a4,0(s1)
    80003c3c:	ff3716e3          	bne	a4,s3,80003c28 <iget+0x38>
    80003c40:	40d8                	lw	a4,4(s1)
    80003c42:	ff4713e3          	bne	a4,s4,80003c28 <iget+0x38>
      ip->ref++;
    80003c46:	2785                	addiw	a5,a5,1
    80003c48:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c4a:	00023517          	auipc	a0,0x23
    80003c4e:	6ee50513          	addi	a0,a0,1774 # 80027338 <itable>
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	09c080e7          	jalr	156(ra) # 80000cee <release>
      return ip;
    80003c5a:	8926                	mv	s2,s1
    80003c5c:	a03d                	j	80003c8a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c5e:	f7f9                	bnez	a5,80003c2c <iget+0x3c>
      empty = ip;
    80003c60:	8926                	mv	s2,s1
    80003c62:	b7e9                	j	80003c2c <iget+0x3c>
  if(empty == 0)
    80003c64:	02090c63          	beqz	s2,80003c9c <iget+0xac>
  ip->dev = dev;
    80003c68:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c6c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c70:	4785                	li	a5,1
    80003c72:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c76:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c7a:	00023517          	auipc	a0,0x23
    80003c7e:	6be50513          	addi	a0,a0,1726 # 80027338 <itable>
    80003c82:	ffffd097          	auipc	ra,0xffffd
    80003c86:	06c080e7          	jalr	108(ra) # 80000cee <release>
}
    80003c8a:	854a                	mv	a0,s2
    80003c8c:	70a2                	ld	ra,40(sp)
    80003c8e:	7402                	ld	s0,32(sp)
    80003c90:	64e2                	ld	s1,24(sp)
    80003c92:	6942                	ld	s2,16(sp)
    80003c94:	69a2                	ld	s3,8(sp)
    80003c96:	6a02                	ld	s4,0(sp)
    80003c98:	6145                	addi	sp,sp,48
    80003c9a:	8082                	ret
    panic("iget: no inodes");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	86450513          	addi	a0,a0,-1948 # 80008500 <etext+0x500>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	8bc080e7          	jalr	-1860(ra) # 80000560 <panic>

0000000080003cac <fsinit>:
fsinit(int dev) {
    80003cac:	7179                	addi	sp,sp,-48
    80003cae:	f406                	sd	ra,40(sp)
    80003cb0:	f022                	sd	s0,32(sp)
    80003cb2:	ec26                	sd	s1,24(sp)
    80003cb4:	e84a                	sd	s2,16(sp)
    80003cb6:	e44e                	sd	s3,8(sp)
    80003cb8:	1800                	addi	s0,sp,48
    80003cba:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cbc:	4585                	li	a1,1
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	a64080e7          	jalr	-1436(ra) # 80003722 <bread>
    80003cc6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cc8:	00023997          	auipc	s3,0x23
    80003ccc:	65098993          	addi	s3,s3,1616 # 80027318 <sb>
    80003cd0:	02000613          	li	a2,32
    80003cd4:	05850593          	addi	a1,a0,88
    80003cd8:	854e                	mv	a0,s3
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	0c0080e7          	jalr	192(ra) # 80000d9a <memmove>
  brelse(bp);
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	b6e080e7          	jalr	-1170(ra) # 80003852 <brelse>
  if(sb.magic != FSMAGIC)
    80003cec:	0009a703          	lw	a4,0(s3)
    80003cf0:	102037b7          	lui	a5,0x10203
    80003cf4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003cf8:	02f71263          	bne	a4,a5,80003d1c <fsinit+0x70>
  initlog(dev, &sb);
    80003cfc:	00023597          	auipc	a1,0x23
    80003d00:	61c58593          	addi	a1,a1,1564 # 80027318 <sb>
    80003d04:	854a                	mv	a0,s2
    80003d06:	00001097          	auipc	ra,0x1
    80003d0a:	b7c080e7          	jalr	-1156(ra) # 80004882 <initlog>
}
    80003d0e:	70a2                	ld	ra,40(sp)
    80003d10:	7402                	ld	s0,32(sp)
    80003d12:	64e2                	ld	s1,24(sp)
    80003d14:	6942                	ld	s2,16(sp)
    80003d16:	69a2                	ld	s3,8(sp)
    80003d18:	6145                	addi	sp,sp,48
    80003d1a:	8082                	ret
    panic("invalid file system");
    80003d1c:	00004517          	auipc	a0,0x4
    80003d20:	7f450513          	addi	a0,a0,2036 # 80008510 <etext+0x510>
    80003d24:	ffffd097          	auipc	ra,0xffffd
    80003d28:	83c080e7          	jalr	-1988(ra) # 80000560 <panic>

0000000080003d2c <iinit>:
{
    80003d2c:	7179                	addi	sp,sp,-48
    80003d2e:	f406                	sd	ra,40(sp)
    80003d30:	f022                	sd	s0,32(sp)
    80003d32:	ec26                	sd	s1,24(sp)
    80003d34:	e84a                	sd	s2,16(sp)
    80003d36:	e44e                	sd	s3,8(sp)
    80003d38:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d3a:	00004597          	auipc	a1,0x4
    80003d3e:	7ee58593          	addi	a1,a1,2030 # 80008528 <etext+0x528>
    80003d42:	00023517          	auipc	a0,0x23
    80003d46:	5f650513          	addi	a0,a0,1526 # 80027338 <itable>
    80003d4a:	ffffd097          	auipc	ra,0xffffd
    80003d4e:	e60080e7          	jalr	-416(ra) # 80000baa <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d52:	00023497          	auipc	s1,0x23
    80003d56:	60e48493          	addi	s1,s1,1550 # 80027360 <itable+0x28>
    80003d5a:	00025997          	auipc	s3,0x25
    80003d5e:	09698993          	addi	s3,s3,150 # 80028df0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d62:	00004917          	auipc	s2,0x4
    80003d66:	7ce90913          	addi	s2,s2,1998 # 80008530 <etext+0x530>
    80003d6a:	85ca                	mv	a1,s2
    80003d6c:	8526                	mv	a0,s1
    80003d6e:	00001097          	auipc	ra,0x1
    80003d72:	e6e080e7          	jalr	-402(ra) # 80004bdc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d76:	08848493          	addi	s1,s1,136
    80003d7a:	ff3498e3          	bne	s1,s3,80003d6a <iinit+0x3e>
}
    80003d7e:	70a2                	ld	ra,40(sp)
    80003d80:	7402                	ld	s0,32(sp)
    80003d82:	64e2                	ld	s1,24(sp)
    80003d84:	6942                	ld	s2,16(sp)
    80003d86:	69a2                	ld	s3,8(sp)
    80003d88:	6145                	addi	sp,sp,48
    80003d8a:	8082                	ret

0000000080003d8c <ialloc>:
{
    80003d8c:	7139                	addi	sp,sp,-64
    80003d8e:	fc06                	sd	ra,56(sp)
    80003d90:	f822                	sd	s0,48(sp)
    80003d92:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d94:	00023717          	auipc	a4,0x23
    80003d98:	59072703          	lw	a4,1424(a4) # 80027324 <sb+0xc>
    80003d9c:	4785                	li	a5,1
    80003d9e:	06e7f463          	bgeu	a5,a4,80003e06 <ialloc+0x7a>
    80003da2:	f426                	sd	s1,40(sp)
    80003da4:	f04a                	sd	s2,32(sp)
    80003da6:	ec4e                	sd	s3,24(sp)
    80003da8:	e852                	sd	s4,16(sp)
    80003daa:	e456                	sd	s5,8(sp)
    80003dac:	e05a                	sd	s6,0(sp)
    80003dae:	8aaa                	mv	s5,a0
    80003db0:	8b2e                	mv	s6,a1
    80003db2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003db4:	00023a17          	auipc	s4,0x23
    80003db8:	564a0a13          	addi	s4,s4,1380 # 80027318 <sb>
    80003dbc:	00495593          	srli	a1,s2,0x4
    80003dc0:	018a2783          	lw	a5,24(s4)
    80003dc4:	9dbd                	addw	a1,a1,a5
    80003dc6:	8556                	mv	a0,s5
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	95a080e7          	jalr	-1702(ra) # 80003722 <bread>
    80003dd0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003dd2:	05850993          	addi	s3,a0,88
    80003dd6:	00f97793          	andi	a5,s2,15
    80003dda:	079a                	slli	a5,a5,0x6
    80003ddc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003dde:	00099783          	lh	a5,0(s3)
    80003de2:	cf9d                	beqz	a5,80003e20 <ialloc+0x94>
    brelse(bp);
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	a6e080e7          	jalr	-1426(ra) # 80003852 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dec:	0905                	addi	s2,s2,1
    80003dee:	00ca2703          	lw	a4,12(s4)
    80003df2:	0009079b          	sext.w	a5,s2
    80003df6:	fce7e3e3          	bltu	a5,a4,80003dbc <ialloc+0x30>
    80003dfa:	74a2                	ld	s1,40(sp)
    80003dfc:	7902                	ld	s2,32(sp)
    80003dfe:	69e2                	ld	s3,24(sp)
    80003e00:	6a42                	ld	s4,16(sp)
    80003e02:	6aa2                	ld	s5,8(sp)
    80003e04:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003e06:	00004517          	auipc	a0,0x4
    80003e0a:	73250513          	addi	a0,a0,1842 # 80008538 <etext+0x538>
    80003e0e:	ffffc097          	auipc	ra,0xffffc
    80003e12:	79c080e7          	jalr	1948(ra) # 800005aa <printf>
  return 0;
    80003e16:	4501                	li	a0,0
}
    80003e18:	70e2                	ld	ra,56(sp)
    80003e1a:	7442                	ld	s0,48(sp)
    80003e1c:	6121                	addi	sp,sp,64
    80003e1e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e20:	04000613          	li	a2,64
    80003e24:	4581                	li	a1,0
    80003e26:	854e                	mv	a0,s3
    80003e28:	ffffd097          	auipc	ra,0xffffd
    80003e2c:	f0e080e7          	jalr	-242(ra) # 80000d36 <memset>
      dip->type = type;
    80003e30:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e34:	8526                	mv	a0,s1
    80003e36:	00001097          	auipc	ra,0x1
    80003e3a:	cc2080e7          	jalr	-830(ra) # 80004af8 <log_write>
      brelse(bp);
    80003e3e:	8526                	mv	a0,s1
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	a12080e7          	jalr	-1518(ra) # 80003852 <brelse>
      return iget(dev, inum);
    80003e48:	0009059b          	sext.w	a1,s2
    80003e4c:	8556                	mv	a0,s5
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	da2080e7          	jalr	-606(ra) # 80003bf0 <iget>
    80003e56:	74a2                	ld	s1,40(sp)
    80003e58:	7902                	ld	s2,32(sp)
    80003e5a:	69e2                	ld	s3,24(sp)
    80003e5c:	6a42                	ld	s4,16(sp)
    80003e5e:	6aa2                	ld	s5,8(sp)
    80003e60:	6b02                	ld	s6,0(sp)
    80003e62:	bf5d                	j	80003e18 <ialloc+0x8c>

0000000080003e64 <iupdate>:
{
    80003e64:	1101                	addi	sp,sp,-32
    80003e66:	ec06                	sd	ra,24(sp)
    80003e68:	e822                	sd	s0,16(sp)
    80003e6a:	e426                	sd	s1,8(sp)
    80003e6c:	e04a                	sd	s2,0(sp)
    80003e6e:	1000                	addi	s0,sp,32
    80003e70:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e72:	415c                	lw	a5,4(a0)
    80003e74:	0047d79b          	srliw	a5,a5,0x4
    80003e78:	00023597          	auipc	a1,0x23
    80003e7c:	4b85a583          	lw	a1,1208(a1) # 80027330 <sb+0x18>
    80003e80:	9dbd                	addw	a1,a1,a5
    80003e82:	4108                	lw	a0,0(a0)
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	89e080e7          	jalr	-1890(ra) # 80003722 <bread>
    80003e8c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e8e:	05850793          	addi	a5,a0,88
    80003e92:	40d8                	lw	a4,4(s1)
    80003e94:	8b3d                	andi	a4,a4,15
    80003e96:	071a                	slli	a4,a4,0x6
    80003e98:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003e9a:	04449703          	lh	a4,68(s1)
    80003e9e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003ea2:	04649703          	lh	a4,70(s1)
    80003ea6:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003eaa:	04849703          	lh	a4,72(s1)
    80003eae:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003eb2:	04a49703          	lh	a4,74(s1)
    80003eb6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003eba:	44f8                	lw	a4,76(s1)
    80003ebc:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ebe:	03400613          	li	a2,52
    80003ec2:	05048593          	addi	a1,s1,80
    80003ec6:	00c78513          	addi	a0,a5,12
    80003eca:	ffffd097          	auipc	ra,0xffffd
    80003ece:	ed0080e7          	jalr	-304(ra) # 80000d9a <memmove>
  log_write(bp);
    80003ed2:	854a                	mv	a0,s2
    80003ed4:	00001097          	auipc	ra,0x1
    80003ed8:	c24080e7          	jalr	-988(ra) # 80004af8 <log_write>
  brelse(bp);
    80003edc:	854a                	mv	a0,s2
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	974080e7          	jalr	-1676(ra) # 80003852 <brelse>
}
    80003ee6:	60e2                	ld	ra,24(sp)
    80003ee8:	6442                	ld	s0,16(sp)
    80003eea:	64a2                	ld	s1,8(sp)
    80003eec:	6902                	ld	s2,0(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret

0000000080003ef2 <idup>:
{
    80003ef2:	1101                	addi	sp,sp,-32
    80003ef4:	ec06                	sd	ra,24(sp)
    80003ef6:	e822                	sd	s0,16(sp)
    80003ef8:	e426                	sd	s1,8(sp)
    80003efa:	1000                	addi	s0,sp,32
    80003efc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003efe:	00023517          	auipc	a0,0x23
    80003f02:	43a50513          	addi	a0,a0,1082 # 80027338 <itable>
    80003f06:	ffffd097          	auipc	ra,0xffffd
    80003f0a:	d38080e7          	jalr	-712(ra) # 80000c3e <acquire>
  ip->ref++;
    80003f0e:	449c                	lw	a5,8(s1)
    80003f10:	2785                	addiw	a5,a5,1
    80003f12:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f14:	00023517          	auipc	a0,0x23
    80003f18:	42450513          	addi	a0,a0,1060 # 80027338 <itable>
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	dd2080e7          	jalr	-558(ra) # 80000cee <release>
}
    80003f24:	8526                	mv	a0,s1
    80003f26:	60e2                	ld	ra,24(sp)
    80003f28:	6442                	ld	s0,16(sp)
    80003f2a:	64a2                	ld	s1,8(sp)
    80003f2c:	6105                	addi	sp,sp,32
    80003f2e:	8082                	ret

0000000080003f30 <ilock>:
{
    80003f30:	1101                	addi	sp,sp,-32
    80003f32:	ec06                	sd	ra,24(sp)
    80003f34:	e822                	sd	s0,16(sp)
    80003f36:	e426                	sd	s1,8(sp)
    80003f38:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f3a:	c10d                	beqz	a0,80003f5c <ilock+0x2c>
    80003f3c:	84aa                	mv	s1,a0
    80003f3e:	451c                	lw	a5,8(a0)
    80003f40:	00f05e63          	blez	a5,80003f5c <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003f44:	0541                	addi	a0,a0,16
    80003f46:	00001097          	auipc	ra,0x1
    80003f4a:	cd0080e7          	jalr	-816(ra) # 80004c16 <acquiresleep>
  if(ip->valid == 0){
    80003f4e:	40bc                	lw	a5,64(s1)
    80003f50:	cf99                	beqz	a5,80003f6e <ilock+0x3e>
}
    80003f52:	60e2                	ld	ra,24(sp)
    80003f54:	6442                	ld	s0,16(sp)
    80003f56:	64a2                	ld	s1,8(sp)
    80003f58:	6105                	addi	sp,sp,32
    80003f5a:	8082                	ret
    80003f5c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003f5e:	00004517          	auipc	a0,0x4
    80003f62:	5f250513          	addi	a0,a0,1522 # 80008550 <etext+0x550>
    80003f66:	ffffc097          	auipc	ra,0xffffc
    80003f6a:	5fa080e7          	jalr	1530(ra) # 80000560 <panic>
    80003f6e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f70:	40dc                	lw	a5,4(s1)
    80003f72:	0047d79b          	srliw	a5,a5,0x4
    80003f76:	00023597          	auipc	a1,0x23
    80003f7a:	3ba5a583          	lw	a1,954(a1) # 80027330 <sb+0x18>
    80003f7e:	9dbd                	addw	a1,a1,a5
    80003f80:	4088                	lw	a0,0(s1)
    80003f82:	fffff097          	auipc	ra,0xfffff
    80003f86:	7a0080e7          	jalr	1952(ra) # 80003722 <bread>
    80003f8a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f8c:	05850593          	addi	a1,a0,88
    80003f90:	40dc                	lw	a5,4(s1)
    80003f92:	8bbd                	andi	a5,a5,15
    80003f94:	079a                	slli	a5,a5,0x6
    80003f96:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f98:	00059783          	lh	a5,0(a1)
    80003f9c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fa0:	00259783          	lh	a5,2(a1)
    80003fa4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fa8:	00459783          	lh	a5,4(a1)
    80003fac:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fb0:	00659783          	lh	a5,6(a1)
    80003fb4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fb8:	459c                	lw	a5,8(a1)
    80003fba:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fbc:	03400613          	li	a2,52
    80003fc0:	05b1                	addi	a1,a1,12
    80003fc2:	05048513          	addi	a0,s1,80
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	dd4080e7          	jalr	-556(ra) # 80000d9a <memmove>
    brelse(bp);
    80003fce:	854a                	mv	a0,s2
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	882080e7          	jalr	-1918(ra) # 80003852 <brelse>
    ip->valid = 1;
    80003fd8:	4785                	li	a5,1
    80003fda:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003fdc:	04449783          	lh	a5,68(s1)
    80003fe0:	c399                	beqz	a5,80003fe6 <ilock+0xb6>
    80003fe2:	6902                	ld	s2,0(sp)
    80003fe4:	b7bd                	j	80003f52 <ilock+0x22>
      panic("ilock: no type");
    80003fe6:	00004517          	auipc	a0,0x4
    80003fea:	57250513          	addi	a0,a0,1394 # 80008558 <etext+0x558>
    80003fee:	ffffc097          	auipc	ra,0xffffc
    80003ff2:	572080e7          	jalr	1394(ra) # 80000560 <panic>

0000000080003ff6 <iunlock>:
{
    80003ff6:	1101                	addi	sp,sp,-32
    80003ff8:	ec06                	sd	ra,24(sp)
    80003ffa:	e822                	sd	s0,16(sp)
    80003ffc:	e426                	sd	s1,8(sp)
    80003ffe:	e04a                	sd	s2,0(sp)
    80004000:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004002:	c905                	beqz	a0,80004032 <iunlock+0x3c>
    80004004:	84aa                	mv	s1,a0
    80004006:	01050913          	addi	s2,a0,16
    8000400a:	854a                	mv	a0,s2
    8000400c:	00001097          	auipc	ra,0x1
    80004010:	ca4080e7          	jalr	-860(ra) # 80004cb0 <holdingsleep>
    80004014:	cd19                	beqz	a0,80004032 <iunlock+0x3c>
    80004016:	449c                	lw	a5,8(s1)
    80004018:	00f05d63          	blez	a5,80004032 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000401c:	854a                	mv	a0,s2
    8000401e:	00001097          	auipc	ra,0x1
    80004022:	c4e080e7          	jalr	-946(ra) # 80004c6c <releasesleep>
}
    80004026:	60e2                	ld	ra,24(sp)
    80004028:	6442                	ld	s0,16(sp)
    8000402a:	64a2                	ld	s1,8(sp)
    8000402c:	6902                	ld	s2,0(sp)
    8000402e:	6105                	addi	sp,sp,32
    80004030:	8082                	ret
    panic("iunlock");
    80004032:	00004517          	auipc	a0,0x4
    80004036:	53650513          	addi	a0,a0,1334 # 80008568 <etext+0x568>
    8000403a:	ffffc097          	auipc	ra,0xffffc
    8000403e:	526080e7          	jalr	1318(ra) # 80000560 <panic>

0000000080004042 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004042:	7179                	addi	sp,sp,-48
    80004044:	f406                	sd	ra,40(sp)
    80004046:	f022                	sd	s0,32(sp)
    80004048:	ec26                	sd	s1,24(sp)
    8000404a:	e84a                	sd	s2,16(sp)
    8000404c:	e44e                	sd	s3,8(sp)
    8000404e:	1800                	addi	s0,sp,48
    80004050:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004052:	05050493          	addi	s1,a0,80
    80004056:	08050913          	addi	s2,a0,128
    8000405a:	a021                	j	80004062 <itrunc+0x20>
    8000405c:	0491                	addi	s1,s1,4
    8000405e:	01248d63          	beq	s1,s2,80004078 <itrunc+0x36>
    if(ip->addrs[i]){
    80004062:	408c                	lw	a1,0(s1)
    80004064:	dde5                	beqz	a1,8000405c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004066:	0009a503          	lw	a0,0(s3)
    8000406a:	00000097          	auipc	ra,0x0
    8000406e:	8f8080e7          	jalr	-1800(ra) # 80003962 <bfree>
      ip->addrs[i] = 0;
    80004072:	0004a023          	sw	zero,0(s1)
    80004076:	b7dd                	j	8000405c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004078:	0809a583          	lw	a1,128(s3)
    8000407c:	ed99                	bnez	a1,8000409a <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000407e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004082:	854e                	mv	a0,s3
    80004084:	00000097          	auipc	ra,0x0
    80004088:	de0080e7          	jalr	-544(ra) # 80003e64 <iupdate>
}
    8000408c:	70a2                	ld	ra,40(sp)
    8000408e:	7402                	ld	s0,32(sp)
    80004090:	64e2                	ld	s1,24(sp)
    80004092:	6942                	ld	s2,16(sp)
    80004094:	69a2                	ld	s3,8(sp)
    80004096:	6145                	addi	sp,sp,48
    80004098:	8082                	ret
    8000409a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000409c:	0009a503          	lw	a0,0(s3)
    800040a0:	fffff097          	auipc	ra,0xfffff
    800040a4:	682080e7          	jalr	1666(ra) # 80003722 <bread>
    800040a8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040aa:	05850493          	addi	s1,a0,88
    800040ae:	45850913          	addi	s2,a0,1112
    800040b2:	a021                	j	800040ba <itrunc+0x78>
    800040b4:	0491                	addi	s1,s1,4
    800040b6:	01248b63          	beq	s1,s2,800040cc <itrunc+0x8a>
      if(a[j])
    800040ba:	408c                	lw	a1,0(s1)
    800040bc:	dde5                	beqz	a1,800040b4 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800040be:	0009a503          	lw	a0,0(s3)
    800040c2:	00000097          	auipc	ra,0x0
    800040c6:	8a0080e7          	jalr	-1888(ra) # 80003962 <bfree>
    800040ca:	b7ed                	j	800040b4 <itrunc+0x72>
    brelse(bp);
    800040cc:	8552                	mv	a0,s4
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	784080e7          	jalr	1924(ra) # 80003852 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040d6:	0809a583          	lw	a1,128(s3)
    800040da:	0009a503          	lw	a0,0(s3)
    800040de:	00000097          	auipc	ra,0x0
    800040e2:	884080e7          	jalr	-1916(ra) # 80003962 <bfree>
    ip->addrs[NDIRECT] = 0;
    800040e6:	0809a023          	sw	zero,128(s3)
    800040ea:	6a02                	ld	s4,0(sp)
    800040ec:	bf49                	j	8000407e <itrunc+0x3c>

00000000800040ee <iput>:
{
    800040ee:	1101                	addi	sp,sp,-32
    800040f0:	ec06                	sd	ra,24(sp)
    800040f2:	e822                	sd	s0,16(sp)
    800040f4:	e426                	sd	s1,8(sp)
    800040f6:	1000                	addi	s0,sp,32
    800040f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040fa:	00023517          	auipc	a0,0x23
    800040fe:	23e50513          	addi	a0,a0,574 # 80027338 <itable>
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	b3c080e7          	jalr	-1220(ra) # 80000c3e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000410a:	4498                	lw	a4,8(s1)
    8000410c:	4785                	li	a5,1
    8000410e:	02f70263          	beq	a4,a5,80004132 <iput+0x44>
  ip->ref--;
    80004112:	449c                	lw	a5,8(s1)
    80004114:	37fd                	addiw	a5,a5,-1
    80004116:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004118:	00023517          	auipc	a0,0x23
    8000411c:	22050513          	addi	a0,a0,544 # 80027338 <itable>
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	bce080e7          	jalr	-1074(ra) # 80000cee <release>
}
    80004128:	60e2                	ld	ra,24(sp)
    8000412a:	6442                	ld	s0,16(sp)
    8000412c:	64a2                	ld	s1,8(sp)
    8000412e:	6105                	addi	sp,sp,32
    80004130:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004132:	40bc                	lw	a5,64(s1)
    80004134:	dff9                	beqz	a5,80004112 <iput+0x24>
    80004136:	04a49783          	lh	a5,74(s1)
    8000413a:	ffe1                	bnez	a5,80004112 <iput+0x24>
    8000413c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000413e:	01048913          	addi	s2,s1,16
    80004142:	854a                	mv	a0,s2
    80004144:	00001097          	auipc	ra,0x1
    80004148:	ad2080e7          	jalr	-1326(ra) # 80004c16 <acquiresleep>
    release(&itable.lock);
    8000414c:	00023517          	auipc	a0,0x23
    80004150:	1ec50513          	addi	a0,a0,492 # 80027338 <itable>
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	b9a080e7          	jalr	-1126(ra) # 80000cee <release>
    itrunc(ip);
    8000415c:	8526                	mv	a0,s1
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	ee4080e7          	jalr	-284(ra) # 80004042 <itrunc>
    ip->type = 0;
    80004166:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000416a:	8526                	mv	a0,s1
    8000416c:	00000097          	auipc	ra,0x0
    80004170:	cf8080e7          	jalr	-776(ra) # 80003e64 <iupdate>
    ip->valid = 0;
    80004174:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004178:	854a                	mv	a0,s2
    8000417a:	00001097          	auipc	ra,0x1
    8000417e:	af2080e7          	jalr	-1294(ra) # 80004c6c <releasesleep>
    acquire(&itable.lock);
    80004182:	00023517          	auipc	a0,0x23
    80004186:	1b650513          	addi	a0,a0,438 # 80027338 <itable>
    8000418a:	ffffd097          	auipc	ra,0xffffd
    8000418e:	ab4080e7          	jalr	-1356(ra) # 80000c3e <acquire>
    80004192:	6902                	ld	s2,0(sp)
    80004194:	bfbd                	j	80004112 <iput+0x24>

0000000080004196 <iunlockput>:
{
    80004196:	1101                	addi	sp,sp,-32
    80004198:	ec06                	sd	ra,24(sp)
    8000419a:	e822                	sd	s0,16(sp)
    8000419c:	e426                	sd	s1,8(sp)
    8000419e:	1000                	addi	s0,sp,32
    800041a0:	84aa                	mv	s1,a0
  iunlock(ip);
    800041a2:	00000097          	auipc	ra,0x0
    800041a6:	e54080e7          	jalr	-428(ra) # 80003ff6 <iunlock>
  iput(ip);
    800041aa:	8526                	mv	a0,s1
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	f42080e7          	jalr	-190(ra) # 800040ee <iput>
}
    800041b4:	60e2                	ld	ra,24(sp)
    800041b6:	6442                	ld	s0,16(sp)
    800041b8:	64a2                	ld	s1,8(sp)
    800041ba:	6105                	addi	sp,sp,32
    800041bc:	8082                	ret

00000000800041be <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041be:	1141                	addi	sp,sp,-16
    800041c0:	e406                	sd	ra,8(sp)
    800041c2:	e022                	sd	s0,0(sp)
    800041c4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041c6:	411c                	lw	a5,0(a0)
    800041c8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041ca:	415c                	lw	a5,4(a0)
    800041cc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041ce:	04451783          	lh	a5,68(a0)
    800041d2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041d6:	04a51783          	lh	a5,74(a0)
    800041da:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041de:	04c56783          	lwu	a5,76(a0)
    800041e2:	e99c                	sd	a5,16(a1)
}
    800041e4:	60a2                	ld	ra,8(sp)
    800041e6:	6402                	ld	s0,0(sp)
    800041e8:	0141                	addi	sp,sp,16
    800041ea:	8082                	ret

00000000800041ec <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041ec:	457c                	lw	a5,76(a0)
    800041ee:	10d7e063          	bltu	a5,a3,800042ee <readi+0x102>
{
    800041f2:	7159                	addi	sp,sp,-112
    800041f4:	f486                	sd	ra,104(sp)
    800041f6:	f0a2                	sd	s0,96(sp)
    800041f8:	eca6                	sd	s1,88(sp)
    800041fa:	e0d2                	sd	s4,64(sp)
    800041fc:	fc56                	sd	s5,56(sp)
    800041fe:	f85a                	sd	s6,48(sp)
    80004200:	f45e                	sd	s7,40(sp)
    80004202:	1880                	addi	s0,sp,112
    80004204:	8b2a                	mv	s6,a0
    80004206:	8bae                	mv	s7,a1
    80004208:	8a32                	mv	s4,a2
    8000420a:	84b6                	mv	s1,a3
    8000420c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000420e:	9f35                	addw	a4,a4,a3
    return 0;
    80004210:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004212:	0cd76563          	bltu	a4,a3,800042dc <readi+0xf0>
    80004216:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004218:	00e7f463          	bgeu	a5,a4,80004220 <readi+0x34>
    n = ip->size - off;
    8000421c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004220:	0a0a8563          	beqz	s5,800042ca <readi+0xde>
    80004224:	e8ca                	sd	s2,80(sp)
    80004226:	f062                	sd	s8,32(sp)
    80004228:	ec66                	sd	s9,24(sp)
    8000422a:	e86a                	sd	s10,16(sp)
    8000422c:	e46e                	sd	s11,8(sp)
    8000422e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004230:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004234:	5c7d                	li	s8,-1
    80004236:	a82d                	j	80004270 <readi+0x84>
    80004238:	020d1d93          	slli	s11,s10,0x20
    8000423c:	020ddd93          	srli	s11,s11,0x20
    80004240:	05890613          	addi	a2,s2,88
    80004244:	86ee                	mv	a3,s11
    80004246:	963e                	add	a2,a2,a5
    80004248:	85d2                	mv	a1,s4
    8000424a:	855e                	mv	a0,s7
    8000424c:	ffffe097          	auipc	ra,0xffffe
    80004250:	736080e7          	jalr	1846(ra) # 80002982 <either_copyout>
    80004254:	05850963          	beq	a0,s8,800042a6 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004258:	854a                	mv	a0,s2
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	5f8080e7          	jalr	1528(ra) # 80003852 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004262:	013d09bb          	addw	s3,s10,s3
    80004266:	009d04bb          	addw	s1,s10,s1
    8000426a:	9a6e                	add	s4,s4,s11
    8000426c:	0559f963          	bgeu	s3,s5,800042be <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    80004270:	00a4d59b          	srliw	a1,s1,0xa
    80004274:	855a                	mv	a0,s6
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	89e080e7          	jalr	-1890(ra) # 80003b14 <bmap>
    8000427e:	85aa                	mv	a1,a0
    if(addr == 0)
    80004280:	c539                	beqz	a0,800042ce <readi+0xe2>
    bp = bread(ip->dev, addr);
    80004282:	000b2503          	lw	a0,0(s6)
    80004286:	fffff097          	auipc	ra,0xfffff
    8000428a:	49c080e7          	jalr	1180(ra) # 80003722 <bread>
    8000428e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004290:	3ff4f793          	andi	a5,s1,1023
    80004294:	40fc873b          	subw	a4,s9,a5
    80004298:	413a86bb          	subw	a3,s5,s3
    8000429c:	8d3a                	mv	s10,a4
    8000429e:	f8e6fde3          	bgeu	a3,a4,80004238 <readi+0x4c>
    800042a2:	8d36                	mv	s10,a3
    800042a4:	bf51                	j	80004238 <readi+0x4c>
      brelse(bp);
    800042a6:	854a                	mv	a0,s2
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	5aa080e7          	jalr	1450(ra) # 80003852 <brelse>
      tot = -1;
    800042b0:	59fd                	li	s3,-1
      break;
    800042b2:	6946                	ld	s2,80(sp)
    800042b4:	7c02                	ld	s8,32(sp)
    800042b6:	6ce2                	ld	s9,24(sp)
    800042b8:	6d42                	ld	s10,16(sp)
    800042ba:	6da2                	ld	s11,8(sp)
    800042bc:	a831                	j	800042d8 <readi+0xec>
    800042be:	6946                	ld	s2,80(sp)
    800042c0:	7c02                	ld	s8,32(sp)
    800042c2:	6ce2                	ld	s9,24(sp)
    800042c4:	6d42                	ld	s10,16(sp)
    800042c6:	6da2                	ld	s11,8(sp)
    800042c8:	a801                	j	800042d8 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042ca:	89d6                	mv	s3,s5
    800042cc:	a031                	j	800042d8 <readi+0xec>
    800042ce:	6946                	ld	s2,80(sp)
    800042d0:	7c02                	ld	s8,32(sp)
    800042d2:	6ce2                	ld	s9,24(sp)
    800042d4:	6d42                	ld	s10,16(sp)
    800042d6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800042d8:	854e                	mv	a0,s3
    800042da:	69a6                	ld	s3,72(sp)
}
    800042dc:	70a6                	ld	ra,104(sp)
    800042de:	7406                	ld	s0,96(sp)
    800042e0:	64e6                	ld	s1,88(sp)
    800042e2:	6a06                	ld	s4,64(sp)
    800042e4:	7ae2                	ld	s5,56(sp)
    800042e6:	7b42                	ld	s6,48(sp)
    800042e8:	7ba2                	ld	s7,40(sp)
    800042ea:	6165                	addi	sp,sp,112
    800042ec:	8082                	ret
    return 0;
    800042ee:	4501                	li	a0,0
}
    800042f0:	8082                	ret

00000000800042f2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042f2:	457c                	lw	a5,76(a0)
    800042f4:	10d7e963          	bltu	a5,a3,80004406 <writei+0x114>
{
    800042f8:	7159                	addi	sp,sp,-112
    800042fa:	f486                	sd	ra,104(sp)
    800042fc:	f0a2                	sd	s0,96(sp)
    800042fe:	e8ca                	sd	s2,80(sp)
    80004300:	e0d2                	sd	s4,64(sp)
    80004302:	fc56                	sd	s5,56(sp)
    80004304:	f85a                	sd	s6,48(sp)
    80004306:	f45e                	sd	s7,40(sp)
    80004308:	1880                	addi	s0,sp,112
    8000430a:	8aaa                	mv	s5,a0
    8000430c:	8bae                	mv	s7,a1
    8000430e:	8a32                	mv	s4,a2
    80004310:	8936                	mv	s2,a3
    80004312:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004314:	00e687bb          	addw	a5,a3,a4
    80004318:	0ed7e963          	bltu	a5,a3,8000440a <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000431c:	00043737          	lui	a4,0x43
    80004320:	0ef76763          	bltu	a4,a5,8000440e <writei+0x11c>
    80004324:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004326:	0c0b0863          	beqz	s6,800043f6 <writei+0x104>
    8000432a:	eca6                	sd	s1,88(sp)
    8000432c:	f062                	sd	s8,32(sp)
    8000432e:	ec66                	sd	s9,24(sp)
    80004330:	e86a                	sd	s10,16(sp)
    80004332:	e46e                	sd	s11,8(sp)
    80004334:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004336:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000433a:	5c7d                	li	s8,-1
    8000433c:	a091                	j	80004380 <writei+0x8e>
    8000433e:	020d1d93          	slli	s11,s10,0x20
    80004342:	020ddd93          	srli	s11,s11,0x20
    80004346:	05848513          	addi	a0,s1,88
    8000434a:	86ee                	mv	a3,s11
    8000434c:	8652                	mv	a2,s4
    8000434e:	85de                	mv	a1,s7
    80004350:	953e                	add	a0,a0,a5
    80004352:	ffffe097          	auipc	ra,0xffffe
    80004356:	688080e7          	jalr	1672(ra) # 800029da <either_copyin>
    8000435a:	05850e63          	beq	a0,s8,800043b6 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000435e:	8526                	mv	a0,s1
    80004360:	00000097          	auipc	ra,0x0
    80004364:	798080e7          	jalr	1944(ra) # 80004af8 <log_write>
    brelse(bp);
    80004368:	8526                	mv	a0,s1
    8000436a:	fffff097          	auipc	ra,0xfffff
    8000436e:	4e8080e7          	jalr	1256(ra) # 80003852 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004372:	013d09bb          	addw	s3,s10,s3
    80004376:	012d093b          	addw	s2,s10,s2
    8000437a:	9a6e                	add	s4,s4,s11
    8000437c:	0569f263          	bgeu	s3,s6,800043c0 <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004380:	00a9559b          	srliw	a1,s2,0xa
    80004384:	8556                	mv	a0,s5
    80004386:	fffff097          	auipc	ra,0xfffff
    8000438a:	78e080e7          	jalr	1934(ra) # 80003b14 <bmap>
    8000438e:	85aa                	mv	a1,a0
    if(addr == 0)
    80004390:	c905                	beqz	a0,800043c0 <writei+0xce>
    bp = bread(ip->dev, addr);
    80004392:	000aa503          	lw	a0,0(s5)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	38c080e7          	jalr	908(ra) # 80003722 <bread>
    8000439e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043a0:	3ff97793          	andi	a5,s2,1023
    800043a4:	40fc873b          	subw	a4,s9,a5
    800043a8:	413b06bb          	subw	a3,s6,s3
    800043ac:	8d3a                	mv	s10,a4
    800043ae:	f8e6f8e3          	bgeu	a3,a4,8000433e <writei+0x4c>
    800043b2:	8d36                	mv	s10,a3
    800043b4:	b769                	j	8000433e <writei+0x4c>
      brelse(bp);
    800043b6:	8526                	mv	a0,s1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	49a080e7          	jalr	1178(ra) # 80003852 <brelse>
  }

  if(off > ip->size)
    800043c0:	04caa783          	lw	a5,76(s5)
    800043c4:	0327fb63          	bgeu	a5,s2,800043fa <writei+0x108>
    ip->size = off;
    800043c8:	052aa623          	sw	s2,76(s5)
    800043cc:	64e6                	ld	s1,88(sp)
    800043ce:	7c02                	ld	s8,32(sp)
    800043d0:	6ce2                	ld	s9,24(sp)
    800043d2:	6d42                	ld	s10,16(sp)
    800043d4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043d6:	8556                	mv	a0,s5
    800043d8:	00000097          	auipc	ra,0x0
    800043dc:	a8c080e7          	jalr	-1396(ra) # 80003e64 <iupdate>

  return tot;
    800043e0:	854e                	mv	a0,s3
    800043e2:	69a6                	ld	s3,72(sp)
}
    800043e4:	70a6                	ld	ra,104(sp)
    800043e6:	7406                	ld	s0,96(sp)
    800043e8:	6946                	ld	s2,80(sp)
    800043ea:	6a06                	ld	s4,64(sp)
    800043ec:	7ae2                	ld	s5,56(sp)
    800043ee:	7b42                	ld	s6,48(sp)
    800043f0:	7ba2                	ld	s7,40(sp)
    800043f2:	6165                	addi	sp,sp,112
    800043f4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043f6:	89da                	mv	s3,s6
    800043f8:	bff9                	j	800043d6 <writei+0xe4>
    800043fa:	64e6                	ld	s1,88(sp)
    800043fc:	7c02                	ld	s8,32(sp)
    800043fe:	6ce2                	ld	s9,24(sp)
    80004400:	6d42                	ld	s10,16(sp)
    80004402:	6da2                	ld	s11,8(sp)
    80004404:	bfc9                	j	800043d6 <writei+0xe4>
    return -1;
    80004406:	557d                	li	a0,-1
}
    80004408:	8082                	ret
    return -1;
    8000440a:	557d                	li	a0,-1
    8000440c:	bfe1                	j	800043e4 <writei+0xf2>
    return -1;
    8000440e:	557d                	li	a0,-1
    80004410:	bfd1                	j	800043e4 <writei+0xf2>

0000000080004412 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004412:	1141                	addi	sp,sp,-16
    80004414:	e406                	sd	ra,8(sp)
    80004416:	e022                	sd	s0,0(sp)
    80004418:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000441a:	4639                	li	a2,14
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	9f6080e7          	jalr	-1546(ra) # 80000e12 <strncmp>
}
    80004424:	60a2                	ld	ra,8(sp)
    80004426:	6402                	ld	s0,0(sp)
    80004428:	0141                	addi	sp,sp,16
    8000442a:	8082                	ret

000000008000442c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000442c:	711d                	addi	sp,sp,-96
    8000442e:	ec86                	sd	ra,88(sp)
    80004430:	e8a2                	sd	s0,80(sp)
    80004432:	e4a6                	sd	s1,72(sp)
    80004434:	e0ca                	sd	s2,64(sp)
    80004436:	fc4e                	sd	s3,56(sp)
    80004438:	f852                	sd	s4,48(sp)
    8000443a:	f456                	sd	s5,40(sp)
    8000443c:	f05a                	sd	s6,32(sp)
    8000443e:	ec5e                	sd	s7,24(sp)
    80004440:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004442:	04451703          	lh	a4,68(a0)
    80004446:	4785                	li	a5,1
    80004448:	00f71f63          	bne	a4,a5,80004466 <dirlookup+0x3a>
    8000444c:	892a                	mv	s2,a0
    8000444e:	8aae                	mv	s5,a1
    80004450:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004452:	457c                	lw	a5,76(a0)
    80004454:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004456:	fa040a13          	addi	s4,s0,-96
    8000445a:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000445c:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004460:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004462:	e79d                	bnez	a5,80004490 <dirlookup+0x64>
    80004464:	a88d                	j	800044d6 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80004466:	00004517          	auipc	a0,0x4
    8000446a:	10a50513          	addi	a0,a0,266 # 80008570 <etext+0x570>
    8000446e:	ffffc097          	auipc	ra,0xffffc
    80004472:	0f2080e7          	jalr	242(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004476:	00004517          	auipc	a0,0x4
    8000447a:	11250513          	addi	a0,a0,274 # 80008588 <etext+0x588>
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	0e2080e7          	jalr	226(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004486:	24c1                	addiw	s1,s1,16
    80004488:	04c92783          	lw	a5,76(s2)
    8000448c:	04f4f463          	bgeu	s1,a5,800044d4 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004490:	874e                	mv	a4,s3
    80004492:	86a6                	mv	a3,s1
    80004494:	8652                	mv	a2,s4
    80004496:	4581                	li	a1,0
    80004498:	854a                	mv	a0,s2
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	d52080e7          	jalr	-686(ra) # 800041ec <readi>
    800044a2:	fd351ae3          	bne	a0,s3,80004476 <dirlookup+0x4a>
    if(de.inum == 0)
    800044a6:	fa045783          	lhu	a5,-96(s0)
    800044aa:	dff1                	beqz	a5,80004486 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    800044ac:	85da                	mv	a1,s6
    800044ae:	8556                	mv	a0,s5
    800044b0:	00000097          	auipc	ra,0x0
    800044b4:	f62080e7          	jalr	-158(ra) # 80004412 <namecmp>
    800044b8:	f579                	bnez	a0,80004486 <dirlookup+0x5a>
      if(poff)
    800044ba:	000b8463          	beqz	s7,800044c2 <dirlookup+0x96>
        *poff = off;
    800044be:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800044c2:	fa045583          	lhu	a1,-96(s0)
    800044c6:	00092503          	lw	a0,0(s2)
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	726080e7          	jalr	1830(ra) # 80003bf0 <iget>
    800044d2:	a011                	j	800044d6 <dirlookup+0xaa>
  return 0;
    800044d4:	4501                	li	a0,0
}
    800044d6:	60e6                	ld	ra,88(sp)
    800044d8:	6446                	ld	s0,80(sp)
    800044da:	64a6                	ld	s1,72(sp)
    800044dc:	6906                	ld	s2,64(sp)
    800044de:	79e2                	ld	s3,56(sp)
    800044e0:	7a42                	ld	s4,48(sp)
    800044e2:	7aa2                	ld	s5,40(sp)
    800044e4:	7b02                	ld	s6,32(sp)
    800044e6:	6be2                	ld	s7,24(sp)
    800044e8:	6125                	addi	sp,sp,96
    800044ea:	8082                	ret

00000000800044ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044ec:	711d                	addi	sp,sp,-96
    800044ee:	ec86                	sd	ra,88(sp)
    800044f0:	e8a2                	sd	s0,80(sp)
    800044f2:	e4a6                	sd	s1,72(sp)
    800044f4:	e0ca                	sd	s2,64(sp)
    800044f6:	fc4e                	sd	s3,56(sp)
    800044f8:	f852                	sd	s4,48(sp)
    800044fa:	f456                	sd	s5,40(sp)
    800044fc:	f05a                	sd	s6,32(sp)
    800044fe:	ec5e                	sd	s7,24(sp)
    80004500:	e862                	sd	s8,16(sp)
    80004502:	e466                	sd	s9,8(sp)
    80004504:	e06a                	sd	s10,0(sp)
    80004506:	1080                	addi	s0,sp,96
    80004508:	84aa                	mv	s1,a0
    8000450a:	8b2e                	mv	s6,a1
    8000450c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000450e:	00054703          	lbu	a4,0(a0)
    80004512:	02f00793          	li	a5,47
    80004516:	02f70363          	beq	a4,a5,8000453c <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000451a:	ffffd097          	auipc	ra,0xffffd
    8000451e:	596080e7          	jalr	1430(ra) # 80001ab0 <myproc>
    80004522:	32853503          	ld	a0,808(a0)
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	9cc080e7          	jalr	-1588(ra) # 80003ef2 <idup>
    8000452e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004530:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004534:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004536:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004538:	4b85                	li	s7,1
    8000453a:	a87d                	j	800045f8 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000453c:	4585                	li	a1,1
    8000453e:	852e                	mv	a0,a1
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	6b0080e7          	jalr	1712(ra) # 80003bf0 <iget>
    80004548:	8a2a                	mv	s4,a0
    8000454a:	b7dd                	j	80004530 <namex+0x44>
      iunlockput(ip);
    8000454c:	8552                	mv	a0,s4
    8000454e:	00000097          	auipc	ra,0x0
    80004552:	c48080e7          	jalr	-952(ra) # 80004196 <iunlockput>
      return 0;
    80004556:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004558:	8552                	mv	a0,s4
    8000455a:	60e6                	ld	ra,88(sp)
    8000455c:	6446                	ld	s0,80(sp)
    8000455e:	64a6                	ld	s1,72(sp)
    80004560:	6906                	ld	s2,64(sp)
    80004562:	79e2                	ld	s3,56(sp)
    80004564:	7a42                	ld	s4,48(sp)
    80004566:	7aa2                	ld	s5,40(sp)
    80004568:	7b02                	ld	s6,32(sp)
    8000456a:	6be2                	ld	s7,24(sp)
    8000456c:	6c42                	ld	s8,16(sp)
    8000456e:	6ca2                	ld	s9,8(sp)
    80004570:	6d02                	ld	s10,0(sp)
    80004572:	6125                	addi	sp,sp,96
    80004574:	8082                	ret
      iunlock(ip);
    80004576:	8552                	mv	a0,s4
    80004578:	00000097          	auipc	ra,0x0
    8000457c:	a7e080e7          	jalr	-1410(ra) # 80003ff6 <iunlock>
      return ip;
    80004580:	bfe1                	j	80004558 <namex+0x6c>
      iunlockput(ip);
    80004582:	8552                	mv	a0,s4
    80004584:	00000097          	auipc	ra,0x0
    80004588:	c12080e7          	jalr	-1006(ra) # 80004196 <iunlockput>
      return 0;
    8000458c:	8a4e                	mv	s4,s3
    8000458e:	b7e9                	j	80004558 <namex+0x6c>
  len = path - s;
    80004590:	40998633          	sub	a2,s3,s1
    80004594:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004598:	09ac5863          	bge	s8,s10,80004628 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000459c:	8666                	mv	a2,s9
    8000459e:	85a6                	mv	a1,s1
    800045a0:	8556                	mv	a0,s5
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	7f8080e7          	jalr	2040(ra) # 80000d9a <memmove>
    800045aa:	84ce                	mv	s1,s3
  while(*path == '/')
    800045ac:	0004c783          	lbu	a5,0(s1)
    800045b0:	01279763          	bne	a5,s2,800045be <namex+0xd2>
    path++;
    800045b4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045b6:	0004c783          	lbu	a5,0(s1)
    800045ba:	ff278de3          	beq	a5,s2,800045b4 <namex+0xc8>
    ilock(ip);
    800045be:	8552                	mv	a0,s4
    800045c0:	00000097          	auipc	ra,0x0
    800045c4:	970080e7          	jalr	-1680(ra) # 80003f30 <ilock>
    if(ip->type != T_DIR){
    800045c8:	044a1783          	lh	a5,68(s4)
    800045cc:	f97790e3          	bne	a5,s7,8000454c <namex+0x60>
    if(nameiparent && *path == '\0'){
    800045d0:	000b0563          	beqz	s6,800045da <namex+0xee>
    800045d4:	0004c783          	lbu	a5,0(s1)
    800045d8:	dfd9                	beqz	a5,80004576 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045da:	4601                	li	a2,0
    800045dc:	85d6                	mv	a1,s5
    800045de:	8552                	mv	a0,s4
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	e4c080e7          	jalr	-436(ra) # 8000442c <dirlookup>
    800045e8:	89aa                	mv	s3,a0
    800045ea:	dd41                	beqz	a0,80004582 <namex+0x96>
    iunlockput(ip);
    800045ec:	8552                	mv	a0,s4
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	ba8080e7          	jalr	-1112(ra) # 80004196 <iunlockput>
    ip = next;
    800045f6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800045f8:	0004c783          	lbu	a5,0(s1)
    800045fc:	01279763          	bne	a5,s2,8000460a <namex+0x11e>
    path++;
    80004600:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004602:	0004c783          	lbu	a5,0(s1)
    80004606:	ff278de3          	beq	a5,s2,80004600 <namex+0x114>
  if(*path == 0)
    8000460a:	cb9d                	beqz	a5,80004640 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000460c:	0004c783          	lbu	a5,0(s1)
    80004610:	89a6                	mv	s3,s1
  len = path - s;
    80004612:	4d01                	li	s10,0
    80004614:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004616:	01278963          	beq	a5,s2,80004628 <namex+0x13c>
    8000461a:	dbbd                	beqz	a5,80004590 <namex+0xa4>
    path++;
    8000461c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000461e:	0009c783          	lbu	a5,0(s3)
    80004622:	ff279ce3          	bne	a5,s2,8000461a <namex+0x12e>
    80004626:	b7ad                	j	80004590 <namex+0xa4>
    memmove(name, s, len);
    80004628:	2601                	sext.w	a2,a2
    8000462a:	85a6                	mv	a1,s1
    8000462c:	8556                	mv	a0,s5
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	76c080e7          	jalr	1900(ra) # 80000d9a <memmove>
    name[len] = 0;
    80004636:	9d56                	add	s10,s10,s5
    80004638:	000d0023          	sb	zero,0(s10)
    8000463c:	84ce                	mv	s1,s3
    8000463e:	b7bd                	j	800045ac <namex+0xc0>
  if(nameiparent){
    80004640:	f00b0ce3          	beqz	s6,80004558 <namex+0x6c>
    iput(ip);
    80004644:	8552                	mv	a0,s4
    80004646:	00000097          	auipc	ra,0x0
    8000464a:	aa8080e7          	jalr	-1368(ra) # 800040ee <iput>
    return 0;
    8000464e:	4a01                	li	s4,0
    80004650:	b721                	j	80004558 <namex+0x6c>

0000000080004652 <dirlink>:
{
    80004652:	715d                	addi	sp,sp,-80
    80004654:	e486                	sd	ra,72(sp)
    80004656:	e0a2                	sd	s0,64(sp)
    80004658:	f84a                	sd	s2,48(sp)
    8000465a:	ec56                	sd	s5,24(sp)
    8000465c:	e85a                	sd	s6,16(sp)
    8000465e:	0880                	addi	s0,sp,80
    80004660:	892a                	mv	s2,a0
    80004662:	8aae                	mv	s5,a1
    80004664:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004666:	4601                	li	a2,0
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	dc4080e7          	jalr	-572(ra) # 8000442c <dirlookup>
    80004670:	e129                	bnez	a0,800046b2 <dirlink+0x60>
    80004672:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004674:	04c92483          	lw	s1,76(s2)
    80004678:	cca9                	beqz	s1,800046d2 <dirlink+0x80>
    8000467a:	f44e                	sd	s3,40(sp)
    8000467c:	f052                	sd	s4,32(sp)
    8000467e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004680:	fb040a13          	addi	s4,s0,-80
    80004684:	49c1                	li	s3,16
    80004686:	874e                	mv	a4,s3
    80004688:	86a6                	mv	a3,s1
    8000468a:	8652                	mv	a2,s4
    8000468c:	4581                	li	a1,0
    8000468e:	854a                	mv	a0,s2
    80004690:	00000097          	auipc	ra,0x0
    80004694:	b5c080e7          	jalr	-1188(ra) # 800041ec <readi>
    80004698:	03351363          	bne	a0,s3,800046be <dirlink+0x6c>
    if(de.inum == 0)
    8000469c:	fb045783          	lhu	a5,-80(s0)
    800046a0:	c79d                	beqz	a5,800046ce <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046a2:	24c1                	addiw	s1,s1,16
    800046a4:	04c92783          	lw	a5,76(s2)
    800046a8:	fcf4efe3          	bltu	s1,a5,80004686 <dirlink+0x34>
    800046ac:	79a2                	ld	s3,40(sp)
    800046ae:	7a02                	ld	s4,32(sp)
    800046b0:	a00d                	j	800046d2 <dirlink+0x80>
    iput(ip);
    800046b2:	00000097          	auipc	ra,0x0
    800046b6:	a3c080e7          	jalr	-1476(ra) # 800040ee <iput>
    return -1;
    800046ba:	557d                	li	a0,-1
    800046bc:	a0a9                	j	80004706 <dirlink+0xb4>
      panic("dirlink read");
    800046be:	00004517          	auipc	a0,0x4
    800046c2:	eda50513          	addi	a0,a0,-294 # 80008598 <etext+0x598>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	e9a080e7          	jalr	-358(ra) # 80000560 <panic>
    800046ce:	79a2                	ld	s3,40(sp)
    800046d0:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800046d2:	4639                	li	a2,14
    800046d4:	85d6                	mv	a1,s5
    800046d6:	fb240513          	addi	a0,s0,-78
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	772080e7          	jalr	1906(ra) # 80000e4c <strncpy>
  de.inum = inum;
    800046e2:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046e6:	4741                	li	a4,16
    800046e8:	86a6                	mv	a3,s1
    800046ea:	fb040613          	addi	a2,s0,-80
    800046ee:	4581                	li	a1,0
    800046f0:	854a                	mv	a0,s2
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	c00080e7          	jalr	-1024(ra) # 800042f2 <writei>
    800046fa:	1541                	addi	a0,a0,-16
    800046fc:	00a03533          	snez	a0,a0
    80004700:	40a0053b          	negw	a0,a0
    80004704:	74e2                	ld	s1,56(sp)
}
    80004706:	60a6                	ld	ra,72(sp)
    80004708:	6406                	ld	s0,64(sp)
    8000470a:	7942                	ld	s2,48(sp)
    8000470c:	6ae2                	ld	s5,24(sp)
    8000470e:	6b42                	ld	s6,16(sp)
    80004710:	6161                	addi	sp,sp,80
    80004712:	8082                	ret

0000000080004714 <namei>:

struct inode*
namei(char *path)
{
    80004714:	1101                	addi	sp,sp,-32
    80004716:	ec06                	sd	ra,24(sp)
    80004718:	e822                	sd	s0,16(sp)
    8000471a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000471c:	fe040613          	addi	a2,s0,-32
    80004720:	4581                	li	a1,0
    80004722:	00000097          	auipc	ra,0x0
    80004726:	dca080e7          	jalr	-566(ra) # 800044ec <namex>
}
    8000472a:	60e2                	ld	ra,24(sp)
    8000472c:	6442                	ld	s0,16(sp)
    8000472e:	6105                	addi	sp,sp,32
    80004730:	8082                	ret

0000000080004732 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004732:	1141                	addi	sp,sp,-16
    80004734:	e406                	sd	ra,8(sp)
    80004736:	e022                	sd	s0,0(sp)
    80004738:	0800                	addi	s0,sp,16
    8000473a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000473c:	4585                	li	a1,1
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	dae080e7          	jalr	-594(ra) # 800044ec <namex>
}
    80004746:	60a2                	ld	ra,8(sp)
    80004748:	6402                	ld	s0,0(sp)
    8000474a:	0141                	addi	sp,sp,16
    8000474c:	8082                	ret

000000008000474e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000474e:	1101                	addi	sp,sp,-32
    80004750:	ec06                	sd	ra,24(sp)
    80004752:	e822                	sd	s0,16(sp)
    80004754:	e426                	sd	s1,8(sp)
    80004756:	e04a                	sd	s2,0(sp)
    80004758:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000475a:	00024917          	auipc	s2,0x24
    8000475e:	68690913          	addi	s2,s2,1670 # 80028de0 <log>
    80004762:	01892583          	lw	a1,24(s2)
    80004766:	02892503          	lw	a0,40(s2)
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	fb8080e7          	jalr	-72(ra) # 80003722 <bread>
    80004772:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004774:	02c92603          	lw	a2,44(s2)
    80004778:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000477a:	00c05f63          	blez	a2,80004798 <write_head+0x4a>
    8000477e:	00024717          	auipc	a4,0x24
    80004782:	69270713          	addi	a4,a4,1682 # 80028e10 <log+0x30>
    80004786:	87aa                	mv	a5,a0
    80004788:	060a                	slli	a2,a2,0x2
    8000478a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000478c:	4314                	lw	a3,0(a4)
    8000478e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004790:	0711                	addi	a4,a4,4
    80004792:	0791                	addi	a5,a5,4
    80004794:	fec79ce3          	bne	a5,a2,8000478c <write_head+0x3e>
  }
  bwrite(buf);
    80004798:	8526                	mv	a0,s1
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	07a080e7          	jalr	122(ra) # 80003814 <bwrite>
  brelse(buf);
    800047a2:	8526                	mv	a0,s1
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	0ae080e7          	jalr	174(ra) # 80003852 <brelse>
}
    800047ac:	60e2                	ld	ra,24(sp)
    800047ae:	6442                	ld	s0,16(sp)
    800047b0:	64a2                	ld	s1,8(sp)
    800047b2:	6902                	ld	s2,0(sp)
    800047b4:	6105                	addi	sp,sp,32
    800047b6:	8082                	ret

00000000800047b8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047b8:	00024797          	auipc	a5,0x24
    800047bc:	6547a783          	lw	a5,1620(a5) # 80028e0c <log+0x2c>
    800047c0:	0cf05063          	blez	a5,80004880 <install_trans+0xc8>
{
    800047c4:	715d                	addi	sp,sp,-80
    800047c6:	e486                	sd	ra,72(sp)
    800047c8:	e0a2                	sd	s0,64(sp)
    800047ca:	fc26                	sd	s1,56(sp)
    800047cc:	f84a                	sd	s2,48(sp)
    800047ce:	f44e                	sd	s3,40(sp)
    800047d0:	f052                	sd	s4,32(sp)
    800047d2:	ec56                	sd	s5,24(sp)
    800047d4:	e85a                	sd	s6,16(sp)
    800047d6:	e45e                	sd	s7,8(sp)
    800047d8:	0880                	addi	s0,sp,80
    800047da:	8b2a                	mv	s6,a0
    800047dc:	00024a97          	auipc	s5,0x24
    800047e0:	634a8a93          	addi	s5,s5,1588 # 80028e10 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047e6:	00024997          	auipc	s3,0x24
    800047ea:	5fa98993          	addi	s3,s3,1530 # 80028de0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047ee:	40000b93          	li	s7,1024
    800047f2:	a00d                	j	80004814 <install_trans+0x5c>
    brelse(lbuf);
    800047f4:	854a                	mv	a0,s2
    800047f6:	fffff097          	auipc	ra,0xfffff
    800047fa:	05c080e7          	jalr	92(ra) # 80003852 <brelse>
    brelse(dbuf);
    800047fe:	8526                	mv	a0,s1
    80004800:	fffff097          	auipc	ra,0xfffff
    80004804:	052080e7          	jalr	82(ra) # 80003852 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004808:	2a05                	addiw	s4,s4,1
    8000480a:	0a91                	addi	s5,s5,4
    8000480c:	02c9a783          	lw	a5,44(s3)
    80004810:	04fa5d63          	bge	s4,a5,8000486a <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004814:	0189a583          	lw	a1,24(s3)
    80004818:	014585bb          	addw	a1,a1,s4
    8000481c:	2585                	addiw	a1,a1,1
    8000481e:	0289a503          	lw	a0,40(s3)
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	f00080e7          	jalr	-256(ra) # 80003722 <bread>
    8000482a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000482c:	000aa583          	lw	a1,0(s5)
    80004830:	0289a503          	lw	a0,40(s3)
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	eee080e7          	jalr	-274(ra) # 80003722 <bread>
    8000483c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000483e:	865e                	mv	a2,s7
    80004840:	05890593          	addi	a1,s2,88
    80004844:	05850513          	addi	a0,a0,88
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	552080e7          	jalr	1362(ra) # 80000d9a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004850:	8526                	mv	a0,s1
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	fc2080e7          	jalr	-62(ra) # 80003814 <bwrite>
    if(recovering == 0)
    8000485a:	f80b1de3          	bnez	s6,800047f4 <install_trans+0x3c>
      bunpin(dbuf);
    8000485e:	8526                	mv	a0,s1
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	0c6080e7          	jalr	198(ra) # 80003926 <bunpin>
    80004868:	b771                	j	800047f4 <install_trans+0x3c>
}
    8000486a:	60a6                	ld	ra,72(sp)
    8000486c:	6406                	ld	s0,64(sp)
    8000486e:	74e2                	ld	s1,56(sp)
    80004870:	7942                	ld	s2,48(sp)
    80004872:	79a2                	ld	s3,40(sp)
    80004874:	7a02                	ld	s4,32(sp)
    80004876:	6ae2                	ld	s5,24(sp)
    80004878:	6b42                	ld	s6,16(sp)
    8000487a:	6ba2                	ld	s7,8(sp)
    8000487c:	6161                	addi	sp,sp,80
    8000487e:	8082                	ret
    80004880:	8082                	ret

0000000080004882 <initlog>:
{
    80004882:	7179                	addi	sp,sp,-48
    80004884:	f406                	sd	ra,40(sp)
    80004886:	f022                	sd	s0,32(sp)
    80004888:	ec26                	sd	s1,24(sp)
    8000488a:	e84a                	sd	s2,16(sp)
    8000488c:	e44e                	sd	s3,8(sp)
    8000488e:	1800                	addi	s0,sp,48
    80004890:	892a                	mv	s2,a0
    80004892:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004894:	00024497          	auipc	s1,0x24
    80004898:	54c48493          	addi	s1,s1,1356 # 80028de0 <log>
    8000489c:	00004597          	auipc	a1,0x4
    800048a0:	d0c58593          	addi	a1,a1,-756 # 800085a8 <etext+0x5a8>
    800048a4:	8526                	mv	a0,s1
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	304080e7          	jalr	772(ra) # 80000baa <initlock>
  log.start = sb->logstart;
    800048ae:	0149a583          	lw	a1,20(s3)
    800048b2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800048b4:	0109a783          	lw	a5,16(s3)
    800048b8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048ba:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048be:	854a                	mv	a0,s2
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	e62080e7          	jalr	-414(ra) # 80003722 <bread>
  log.lh.n = lh->n;
    800048c8:	4d30                	lw	a2,88(a0)
    800048ca:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048cc:	00c05f63          	blez	a2,800048ea <initlog+0x68>
    800048d0:	87aa                	mv	a5,a0
    800048d2:	00024717          	auipc	a4,0x24
    800048d6:	53e70713          	addi	a4,a4,1342 # 80028e10 <log+0x30>
    800048da:	060a                	slli	a2,a2,0x2
    800048dc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800048de:	4ff4                	lw	a3,92(a5)
    800048e0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048e2:	0791                	addi	a5,a5,4
    800048e4:	0711                	addi	a4,a4,4
    800048e6:	fec79ce3          	bne	a5,a2,800048de <initlog+0x5c>
  brelse(buf);
    800048ea:	fffff097          	auipc	ra,0xfffff
    800048ee:	f68080e7          	jalr	-152(ra) # 80003852 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048f2:	4505                	li	a0,1
    800048f4:	00000097          	auipc	ra,0x0
    800048f8:	ec4080e7          	jalr	-316(ra) # 800047b8 <install_trans>
  log.lh.n = 0;
    800048fc:	00024797          	auipc	a5,0x24
    80004900:	5007a823          	sw	zero,1296(a5) # 80028e0c <log+0x2c>
  write_head(); // clear the log
    80004904:	00000097          	auipc	ra,0x0
    80004908:	e4a080e7          	jalr	-438(ra) # 8000474e <write_head>
}
    8000490c:	70a2                	ld	ra,40(sp)
    8000490e:	7402                	ld	s0,32(sp)
    80004910:	64e2                	ld	s1,24(sp)
    80004912:	6942                	ld	s2,16(sp)
    80004914:	69a2                	ld	s3,8(sp)
    80004916:	6145                	addi	sp,sp,48
    80004918:	8082                	ret

000000008000491a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000491a:	1101                	addi	sp,sp,-32
    8000491c:	ec06                	sd	ra,24(sp)
    8000491e:	e822                	sd	s0,16(sp)
    80004920:	e426                	sd	s1,8(sp)
    80004922:	e04a                	sd	s2,0(sp)
    80004924:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004926:	00024517          	auipc	a0,0x24
    8000492a:	4ba50513          	addi	a0,a0,1210 # 80028de0 <log>
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	310080e7          	jalr	784(ra) # 80000c3e <acquire>
  while(1){
    if(log.committing){
    80004936:	00024497          	auipc	s1,0x24
    8000493a:	4aa48493          	addi	s1,s1,1194 # 80028de0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000493e:	4979                	li	s2,30
    80004940:	a039                	j	8000494e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004942:	85a6                	mv	a1,s1
    80004944:	8526                	mv	a0,s1
    80004946:	ffffe097          	auipc	ra,0xffffe
    8000494a:	c0e080e7          	jalr	-1010(ra) # 80002554 <sleep>
    if(log.committing){
    8000494e:	50dc                	lw	a5,36(s1)
    80004950:	fbed                	bnez	a5,80004942 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004952:	5098                	lw	a4,32(s1)
    80004954:	2705                	addiw	a4,a4,1
    80004956:	0027179b          	slliw	a5,a4,0x2
    8000495a:	9fb9                	addw	a5,a5,a4
    8000495c:	0017979b          	slliw	a5,a5,0x1
    80004960:	54d4                	lw	a3,44(s1)
    80004962:	9fb5                	addw	a5,a5,a3
    80004964:	00f95963          	bge	s2,a5,80004976 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004968:	85a6                	mv	a1,s1
    8000496a:	8526                	mv	a0,s1
    8000496c:	ffffe097          	auipc	ra,0xffffe
    80004970:	be8080e7          	jalr	-1048(ra) # 80002554 <sleep>
    80004974:	bfe9                	j	8000494e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004976:	00024517          	auipc	a0,0x24
    8000497a:	46a50513          	addi	a0,a0,1130 # 80028de0 <log>
    8000497e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	36e080e7          	jalr	878(ra) # 80000cee <release>
      break;
    }
  }
}
    80004988:	60e2                	ld	ra,24(sp)
    8000498a:	6442                	ld	s0,16(sp)
    8000498c:	64a2                	ld	s1,8(sp)
    8000498e:	6902                	ld	s2,0(sp)
    80004990:	6105                	addi	sp,sp,32
    80004992:	8082                	ret

0000000080004994 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004994:	7139                	addi	sp,sp,-64
    80004996:	fc06                	sd	ra,56(sp)
    80004998:	f822                	sd	s0,48(sp)
    8000499a:	f426                	sd	s1,40(sp)
    8000499c:	f04a                	sd	s2,32(sp)
    8000499e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049a0:	00024497          	auipc	s1,0x24
    800049a4:	44048493          	addi	s1,s1,1088 # 80028de0 <log>
    800049a8:	8526                	mv	a0,s1
    800049aa:	ffffc097          	auipc	ra,0xffffc
    800049ae:	294080e7          	jalr	660(ra) # 80000c3e <acquire>
  log.outstanding -= 1;
    800049b2:	509c                	lw	a5,32(s1)
    800049b4:	37fd                	addiw	a5,a5,-1
    800049b6:	893e                	mv	s2,a5
    800049b8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049ba:	50dc                	lw	a5,36(s1)
    800049bc:	e7b9                	bnez	a5,80004a0a <end_op+0x76>
    panic("log.committing");
  if(log.outstanding == 0){
    800049be:	06091263          	bnez	s2,80004a22 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800049c2:	00024497          	auipc	s1,0x24
    800049c6:	41e48493          	addi	s1,s1,1054 # 80028de0 <log>
    800049ca:	4785                	li	a5,1
    800049cc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049ce:	8526                	mv	a0,s1
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	31e080e7          	jalr	798(ra) # 80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049d8:	54dc                	lw	a5,44(s1)
    800049da:	06f04863          	bgtz	a5,80004a4a <end_op+0xb6>
    acquire(&log.lock);
    800049de:	00024497          	auipc	s1,0x24
    800049e2:	40248493          	addi	s1,s1,1026 # 80028de0 <log>
    800049e6:	8526                	mv	a0,s1
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	256080e7          	jalr	598(ra) # 80000c3e <acquire>
    log.committing = 0;
    800049f0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049f4:	8526                	mv	a0,s1
    800049f6:	ffffe097          	auipc	ra,0xffffe
    800049fa:	bc2080e7          	jalr	-1086(ra) # 800025b8 <wakeup>
    release(&log.lock);
    800049fe:	8526                	mv	a0,s1
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	2ee080e7          	jalr	750(ra) # 80000cee <release>
}
    80004a08:	a81d                	j	80004a3e <end_op+0xaa>
    80004a0a:	ec4e                	sd	s3,24(sp)
    80004a0c:	e852                	sd	s4,16(sp)
    80004a0e:	e456                	sd	s5,8(sp)
    80004a10:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80004a12:	00004517          	auipc	a0,0x4
    80004a16:	b9e50513          	addi	a0,a0,-1122 # 800085b0 <etext+0x5b0>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	b46080e7          	jalr	-1210(ra) # 80000560 <panic>
    wakeup(&log);
    80004a22:	00024497          	auipc	s1,0x24
    80004a26:	3be48493          	addi	s1,s1,958 # 80028de0 <log>
    80004a2a:	8526                	mv	a0,s1
    80004a2c:	ffffe097          	auipc	ra,0xffffe
    80004a30:	b8c080e7          	jalr	-1140(ra) # 800025b8 <wakeup>
  release(&log.lock);
    80004a34:	8526                	mv	a0,s1
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	2b8080e7          	jalr	696(ra) # 80000cee <release>
}
    80004a3e:	70e2                	ld	ra,56(sp)
    80004a40:	7442                	ld	s0,48(sp)
    80004a42:	74a2                	ld	s1,40(sp)
    80004a44:	7902                	ld	s2,32(sp)
    80004a46:	6121                	addi	sp,sp,64
    80004a48:	8082                	ret
    80004a4a:	ec4e                	sd	s3,24(sp)
    80004a4c:	e852                	sd	s4,16(sp)
    80004a4e:	e456                	sd	s5,8(sp)
    80004a50:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a52:	00024a97          	auipc	s5,0x24
    80004a56:	3bea8a93          	addi	s5,s5,958 # 80028e10 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a5a:	00024a17          	auipc	s4,0x24
    80004a5e:	386a0a13          	addi	s4,s4,902 # 80028de0 <log>
    memmove(to->data, from->data, BSIZE);
    80004a62:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a66:	018a2583          	lw	a1,24(s4)
    80004a6a:	012585bb          	addw	a1,a1,s2
    80004a6e:	2585                	addiw	a1,a1,1
    80004a70:	028a2503          	lw	a0,40(s4)
    80004a74:	fffff097          	auipc	ra,0xfffff
    80004a78:	cae080e7          	jalr	-850(ra) # 80003722 <bread>
    80004a7c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a7e:	000aa583          	lw	a1,0(s5)
    80004a82:	028a2503          	lw	a0,40(s4)
    80004a86:	fffff097          	auipc	ra,0xfffff
    80004a8a:	c9c080e7          	jalr	-868(ra) # 80003722 <bread>
    80004a8e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a90:	865a                	mv	a2,s6
    80004a92:	05850593          	addi	a1,a0,88
    80004a96:	05848513          	addi	a0,s1,88
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	300080e7          	jalr	768(ra) # 80000d9a <memmove>
    bwrite(to);  // write the log
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	fffff097          	auipc	ra,0xfffff
    80004aa8:	d70080e7          	jalr	-656(ra) # 80003814 <bwrite>
    brelse(from);
    80004aac:	854e                	mv	a0,s3
    80004aae:	fffff097          	auipc	ra,0xfffff
    80004ab2:	da4080e7          	jalr	-604(ra) # 80003852 <brelse>
    brelse(to);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	d9a080e7          	jalr	-614(ra) # 80003852 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ac0:	2905                	addiw	s2,s2,1
    80004ac2:	0a91                	addi	s5,s5,4
    80004ac4:	02ca2783          	lw	a5,44(s4)
    80004ac8:	f8f94fe3          	blt	s2,a5,80004a66 <end_op+0xd2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004acc:	00000097          	auipc	ra,0x0
    80004ad0:	c82080e7          	jalr	-894(ra) # 8000474e <write_head>
    install_trans(0); // Now install writes to home locations
    80004ad4:	4501                	li	a0,0
    80004ad6:	00000097          	auipc	ra,0x0
    80004ada:	ce2080e7          	jalr	-798(ra) # 800047b8 <install_trans>
    log.lh.n = 0;
    80004ade:	00024797          	auipc	a5,0x24
    80004ae2:	3207a723          	sw	zero,814(a5) # 80028e0c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ae6:	00000097          	auipc	ra,0x0
    80004aea:	c68080e7          	jalr	-920(ra) # 8000474e <write_head>
    80004aee:	69e2                	ld	s3,24(sp)
    80004af0:	6a42                	ld	s4,16(sp)
    80004af2:	6aa2                	ld	s5,8(sp)
    80004af4:	6b02                	ld	s6,0(sp)
    80004af6:	b5e5                	j	800049de <end_op+0x4a>

0000000080004af8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004af8:	1101                	addi	sp,sp,-32
    80004afa:	ec06                	sd	ra,24(sp)
    80004afc:	e822                	sd	s0,16(sp)
    80004afe:	e426                	sd	s1,8(sp)
    80004b00:	e04a                	sd	s2,0(sp)
    80004b02:	1000                	addi	s0,sp,32
    80004b04:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b06:	00024917          	auipc	s2,0x24
    80004b0a:	2da90913          	addi	s2,s2,730 # 80028de0 <log>
    80004b0e:	854a                	mv	a0,s2
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	12e080e7          	jalr	302(ra) # 80000c3e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b18:	02c92603          	lw	a2,44(s2)
    80004b1c:	47f5                	li	a5,29
    80004b1e:	06c7c563          	blt	a5,a2,80004b88 <log_write+0x90>
    80004b22:	00024797          	auipc	a5,0x24
    80004b26:	2da7a783          	lw	a5,730(a5) # 80028dfc <log+0x1c>
    80004b2a:	37fd                	addiw	a5,a5,-1
    80004b2c:	04f65e63          	bge	a2,a5,80004b88 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b30:	00024797          	auipc	a5,0x24
    80004b34:	2d07a783          	lw	a5,720(a5) # 80028e00 <log+0x20>
    80004b38:	06f05063          	blez	a5,80004b98 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b3c:	4781                	li	a5,0
    80004b3e:	06c05563          	blez	a2,80004ba8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b42:	44cc                	lw	a1,12(s1)
    80004b44:	00024717          	auipc	a4,0x24
    80004b48:	2cc70713          	addi	a4,a4,716 # 80028e10 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b4c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b4e:	4314                	lw	a3,0(a4)
    80004b50:	04b68c63          	beq	a3,a1,80004ba8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b54:	2785                	addiw	a5,a5,1
    80004b56:	0711                	addi	a4,a4,4
    80004b58:	fef61be3          	bne	a2,a5,80004b4e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b5c:	0621                	addi	a2,a2,8
    80004b5e:	060a                	slli	a2,a2,0x2
    80004b60:	00024797          	auipc	a5,0x24
    80004b64:	28078793          	addi	a5,a5,640 # 80028de0 <log>
    80004b68:	97b2                	add	a5,a5,a2
    80004b6a:	44d8                	lw	a4,12(s1)
    80004b6c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	fffff097          	auipc	ra,0xfffff
    80004b74:	d7a080e7          	jalr	-646(ra) # 800038ea <bpin>
    log.lh.n++;
    80004b78:	00024717          	auipc	a4,0x24
    80004b7c:	26870713          	addi	a4,a4,616 # 80028de0 <log>
    80004b80:	575c                	lw	a5,44(a4)
    80004b82:	2785                	addiw	a5,a5,1
    80004b84:	d75c                	sw	a5,44(a4)
    80004b86:	a82d                	j	80004bc0 <log_write+0xc8>
    panic("too big a transaction");
    80004b88:	00004517          	auipc	a0,0x4
    80004b8c:	a3850513          	addi	a0,a0,-1480 # 800085c0 <etext+0x5c0>
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	9d0080e7          	jalr	-1584(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004b98:	00004517          	auipc	a0,0x4
    80004b9c:	a4050513          	addi	a0,a0,-1472 # 800085d8 <etext+0x5d8>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	9c0080e7          	jalr	-1600(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004ba8:	00878693          	addi	a3,a5,8
    80004bac:	068a                	slli	a3,a3,0x2
    80004bae:	00024717          	auipc	a4,0x24
    80004bb2:	23270713          	addi	a4,a4,562 # 80028de0 <log>
    80004bb6:	9736                	add	a4,a4,a3
    80004bb8:	44d4                	lw	a3,12(s1)
    80004bba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004bbc:	faf609e3          	beq	a2,a5,80004b6e <log_write+0x76>
  }
  release(&log.lock);
    80004bc0:	00024517          	auipc	a0,0x24
    80004bc4:	22050513          	addi	a0,a0,544 # 80028de0 <log>
    80004bc8:	ffffc097          	auipc	ra,0xffffc
    80004bcc:	126080e7          	jalr	294(ra) # 80000cee <release>
}
    80004bd0:	60e2                	ld	ra,24(sp)
    80004bd2:	6442                	ld	s0,16(sp)
    80004bd4:	64a2                	ld	s1,8(sp)
    80004bd6:	6902                	ld	s2,0(sp)
    80004bd8:	6105                	addi	sp,sp,32
    80004bda:	8082                	ret

0000000080004bdc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bdc:	1101                	addi	sp,sp,-32
    80004bde:	ec06                	sd	ra,24(sp)
    80004be0:	e822                	sd	s0,16(sp)
    80004be2:	e426                	sd	s1,8(sp)
    80004be4:	e04a                	sd	s2,0(sp)
    80004be6:	1000                	addi	s0,sp,32
    80004be8:	84aa                	mv	s1,a0
    80004bea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004bec:	00004597          	auipc	a1,0x4
    80004bf0:	a0c58593          	addi	a1,a1,-1524 # 800085f8 <etext+0x5f8>
    80004bf4:	0521                	addi	a0,a0,8
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	fb4080e7          	jalr	-76(ra) # 80000baa <initlock>
  lk->name = name;
    80004bfe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c06:	0204a423          	sw	zero,40(s1)
}
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6902                	ld	s2,0(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret

0000000080004c16 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c16:	1101                	addi	sp,sp,-32
    80004c18:	ec06                	sd	ra,24(sp)
    80004c1a:	e822                	sd	s0,16(sp)
    80004c1c:	e426                	sd	s1,8(sp)
    80004c1e:	e04a                	sd	s2,0(sp)
    80004c20:	1000                	addi	s0,sp,32
    80004c22:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c24:	00850913          	addi	s2,a0,8
    80004c28:	854a                	mv	a0,s2
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	014080e7          	jalr	20(ra) # 80000c3e <acquire>
  while (lk->locked) {
    80004c32:	409c                	lw	a5,0(s1)
    80004c34:	cb89                	beqz	a5,80004c46 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c36:	85ca                	mv	a1,s2
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffe097          	auipc	ra,0xffffe
    80004c3e:	91a080e7          	jalr	-1766(ra) # 80002554 <sleep>
  while (lk->locked) {
    80004c42:	409c                	lw	a5,0(s1)
    80004c44:	fbed                	bnez	a5,80004c36 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c46:	4785                	li	a5,1
    80004c48:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	e66080e7          	jalr	-410(ra) # 80001ab0 <myproc>
    80004c52:	591c                	lw	a5,48(a0)
    80004c54:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c56:	854a                	mv	a0,s2
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	096080e7          	jalr	150(ra) # 80000cee <release>
}
    80004c60:	60e2                	ld	ra,24(sp)
    80004c62:	6442                	ld	s0,16(sp)
    80004c64:	64a2                	ld	s1,8(sp)
    80004c66:	6902                	ld	s2,0(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret

0000000080004c6c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c6c:	1101                	addi	sp,sp,-32
    80004c6e:	ec06                	sd	ra,24(sp)
    80004c70:	e822                	sd	s0,16(sp)
    80004c72:	e426                	sd	s1,8(sp)
    80004c74:	e04a                	sd	s2,0(sp)
    80004c76:	1000                	addi	s0,sp,32
    80004c78:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c7a:	00850913          	addi	s2,a0,8
    80004c7e:	854a                	mv	a0,s2
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	fbe080e7          	jalr	-66(ra) # 80000c3e <acquire>
  lk->locked = 0;
    80004c88:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c8c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c90:	8526                	mv	a0,s1
    80004c92:	ffffe097          	auipc	ra,0xffffe
    80004c96:	926080e7          	jalr	-1754(ra) # 800025b8 <wakeup>
  release(&lk->lk);
    80004c9a:	854a                	mv	a0,s2
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	052080e7          	jalr	82(ra) # 80000cee <release>
}
    80004ca4:	60e2                	ld	ra,24(sp)
    80004ca6:	6442                	ld	s0,16(sp)
    80004ca8:	64a2                	ld	s1,8(sp)
    80004caa:	6902                	ld	s2,0(sp)
    80004cac:	6105                	addi	sp,sp,32
    80004cae:	8082                	ret

0000000080004cb0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cb0:	7179                	addi	sp,sp,-48
    80004cb2:	f406                	sd	ra,40(sp)
    80004cb4:	f022                	sd	s0,32(sp)
    80004cb6:	ec26                	sd	s1,24(sp)
    80004cb8:	e84a                	sd	s2,16(sp)
    80004cba:	1800                	addi	s0,sp,48
    80004cbc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004cbe:	00850913          	addi	s2,a0,8
    80004cc2:	854a                	mv	a0,s2
    80004cc4:	ffffc097          	auipc	ra,0xffffc
    80004cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ccc:	409c                	lw	a5,0(s1)
    80004cce:	ef91                	bnez	a5,80004cea <holdingsleep+0x3a>
    80004cd0:	4481                	li	s1,0
  release(&lk->lk);
    80004cd2:	854a                	mv	a0,s2
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	01a080e7          	jalr	26(ra) # 80000cee <release>
  return r;
}
    80004cdc:	8526                	mv	a0,s1
    80004cde:	70a2                	ld	ra,40(sp)
    80004ce0:	7402                	ld	s0,32(sp)
    80004ce2:	64e2                	ld	s1,24(sp)
    80004ce4:	6942                	ld	s2,16(sp)
    80004ce6:	6145                	addi	sp,sp,48
    80004ce8:	8082                	ret
    80004cea:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cec:	0284a983          	lw	s3,40(s1)
    80004cf0:	ffffd097          	auipc	ra,0xffffd
    80004cf4:	dc0080e7          	jalr	-576(ra) # 80001ab0 <myproc>
    80004cf8:	5904                	lw	s1,48(a0)
    80004cfa:	413484b3          	sub	s1,s1,s3
    80004cfe:	0014b493          	seqz	s1,s1
    80004d02:	69a2                	ld	s3,8(sp)
    80004d04:	b7f9                	j	80004cd2 <holdingsleep+0x22>

0000000080004d06 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d06:	1141                	addi	sp,sp,-16
    80004d08:	e406                	sd	ra,8(sp)
    80004d0a:	e022                	sd	s0,0(sp)
    80004d0c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d0e:	00004597          	auipc	a1,0x4
    80004d12:	8fa58593          	addi	a1,a1,-1798 # 80008608 <etext+0x608>
    80004d16:	00024517          	auipc	a0,0x24
    80004d1a:	21250513          	addi	a0,a0,530 # 80028f28 <ftable>
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	e8c080e7          	jalr	-372(ra) # 80000baa <initlock>
}
    80004d26:	60a2                	ld	ra,8(sp)
    80004d28:	6402                	ld	s0,0(sp)
    80004d2a:	0141                	addi	sp,sp,16
    80004d2c:	8082                	ret

0000000080004d2e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d2e:	1101                	addi	sp,sp,-32
    80004d30:	ec06                	sd	ra,24(sp)
    80004d32:	e822                	sd	s0,16(sp)
    80004d34:	e426                	sd	s1,8(sp)
    80004d36:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d38:	00024517          	auipc	a0,0x24
    80004d3c:	1f050513          	addi	a0,a0,496 # 80028f28 <ftable>
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	efe080e7          	jalr	-258(ra) # 80000c3e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d48:	00024497          	auipc	s1,0x24
    80004d4c:	1f848493          	addi	s1,s1,504 # 80028f40 <ftable+0x18>
    80004d50:	00025717          	auipc	a4,0x25
    80004d54:	19070713          	addi	a4,a4,400 # 80029ee0 <disk>
    if(f->ref == 0){
    80004d58:	40dc                	lw	a5,4(s1)
    80004d5a:	cf99                	beqz	a5,80004d78 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d5c:	02848493          	addi	s1,s1,40
    80004d60:	fee49ce3          	bne	s1,a4,80004d58 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d64:	00024517          	auipc	a0,0x24
    80004d68:	1c450513          	addi	a0,a0,452 # 80028f28 <ftable>
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	f82080e7          	jalr	-126(ra) # 80000cee <release>
  return 0;
    80004d74:	4481                	li	s1,0
    80004d76:	a819                	j	80004d8c <filealloc+0x5e>
      f->ref = 1;
    80004d78:	4785                	li	a5,1
    80004d7a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d7c:	00024517          	auipc	a0,0x24
    80004d80:	1ac50513          	addi	a0,a0,428 # 80028f28 <ftable>
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	f6a080e7          	jalr	-150(ra) # 80000cee <release>
}
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	60e2                	ld	ra,24(sp)
    80004d90:	6442                	ld	s0,16(sp)
    80004d92:	64a2                	ld	s1,8(sp)
    80004d94:	6105                	addi	sp,sp,32
    80004d96:	8082                	ret

0000000080004d98 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d98:	1101                	addi	sp,sp,-32
    80004d9a:	ec06                	sd	ra,24(sp)
    80004d9c:	e822                	sd	s0,16(sp)
    80004d9e:	e426                	sd	s1,8(sp)
    80004da0:	1000                	addi	s0,sp,32
    80004da2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004da4:	00024517          	auipc	a0,0x24
    80004da8:	18450513          	addi	a0,a0,388 # 80028f28 <ftable>
    80004dac:	ffffc097          	auipc	ra,0xffffc
    80004db0:	e92080e7          	jalr	-366(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004db4:	40dc                	lw	a5,4(s1)
    80004db6:	02f05263          	blez	a5,80004dda <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004dba:	2785                	addiw	a5,a5,1
    80004dbc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004dbe:	00024517          	auipc	a0,0x24
    80004dc2:	16a50513          	addi	a0,a0,362 # 80028f28 <ftable>
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	f28080e7          	jalr	-216(ra) # 80000cee <release>
  return f;
}
    80004dce:	8526                	mv	a0,s1
    80004dd0:	60e2                	ld	ra,24(sp)
    80004dd2:	6442                	ld	s0,16(sp)
    80004dd4:	64a2                	ld	s1,8(sp)
    80004dd6:	6105                	addi	sp,sp,32
    80004dd8:	8082                	ret
    panic("filedup");
    80004dda:	00004517          	auipc	a0,0x4
    80004dde:	83650513          	addi	a0,a0,-1994 # 80008610 <etext+0x610>
    80004de2:	ffffb097          	auipc	ra,0xffffb
    80004de6:	77e080e7          	jalr	1918(ra) # 80000560 <panic>

0000000080004dea <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004dea:	7139                	addi	sp,sp,-64
    80004dec:	fc06                	sd	ra,56(sp)
    80004dee:	f822                	sd	s0,48(sp)
    80004df0:	f426                	sd	s1,40(sp)
    80004df2:	0080                	addi	s0,sp,64
    80004df4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004df6:	00024517          	auipc	a0,0x24
    80004dfa:	13250513          	addi	a0,a0,306 # 80028f28 <ftable>
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	e40080e7          	jalr	-448(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004e06:	40dc                	lw	a5,4(s1)
    80004e08:	04f05a63          	blez	a5,80004e5c <fileclose+0x72>
    panic("fileclose");
  if(--f->ref > 0){
    80004e0c:	37fd                	addiw	a5,a5,-1
    80004e0e:	c0dc                	sw	a5,4(s1)
    80004e10:	06f04263          	bgtz	a5,80004e74 <fileclose+0x8a>
    80004e14:	f04a                	sd	s2,32(sp)
    80004e16:	ec4e                	sd	s3,24(sp)
    80004e18:	e852                	sd	s4,16(sp)
    80004e1a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e1c:	0004a903          	lw	s2,0(s1)
    80004e20:	0094ca83          	lbu	s5,9(s1)
    80004e24:	0104ba03          	ld	s4,16(s1)
    80004e28:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e2c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e30:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e34:	00024517          	auipc	a0,0x24
    80004e38:	0f450513          	addi	a0,a0,244 # 80028f28 <ftable>
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	eb2080e7          	jalr	-334(ra) # 80000cee <release>

  if(ff.type == FD_PIPE){
    80004e44:	4785                	li	a5,1
    80004e46:	04f90463          	beq	s2,a5,80004e8e <fileclose+0xa4>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e4a:	3979                	addiw	s2,s2,-2
    80004e4c:	4785                	li	a5,1
    80004e4e:	0527fb63          	bgeu	a5,s2,80004ea4 <fileclose+0xba>
    80004e52:	7902                	ld	s2,32(sp)
    80004e54:	69e2                	ld	s3,24(sp)
    80004e56:	6a42                	ld	s4,16(sp)
    80004e58:	6aa2                	ld	s5,8(sp)
    80004e5a:	a02d                	j	80004e84 <fileclose+0x9a>
    80004e5c:	f04a                	sd	s2,32(sp)
    80004e5e:	ec4e                	sd	s3,24(sp)
    80004e60:	e852                	sd	s4,16(sp)
    80004e62:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004e64:	00003517          	auipc	a0,0x3
    80004e68:	7b450513          	addi	a0,a0,1972 # 80008618 <etext+0x618>
    80004e6c:	ffffb097          	auipc	ra,0xffffb
    80004e70:	6f4080e7          	jalr	1780(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004e74:	00024517          	auipc	a0,0x24
    80004e78:	0b450513          	addi	a0,a0,180 # 80028f28 <ftable>
    80004e7c:	ffffc097          	auipc	ra,0xffffc
    80004e80:	e72080e7          	jalr	-398(ra) # 80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004e84:	70e2                	ld	ra,56(sp)
    80004e86:	7442                	ld	s0,48(sp)
    80004e88:	74a2                	ld	s1,40(sp)
    80004e8a:	6121                	addi	sp,sp,64
    80004e8c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e8e:	85d6                	mv	a1,s5
    80004e90:	8552                	mv	a0,s4
    80004e92:	00000097          	auipc	ra,0x0
    80004e96:	3ac080e7          	jalr	940(ra) # 8000523e <pipeclose>
    80004e9a:	7902                	ld	s2,32(sp)
    80004e9c:	69e2                	ld	s3,24(sp)
    80004e9e:	6a42                	ld	s4,16(sp)
    80004ea0:	6aa2                	ld	s5,8(sp)
    80004ea2:	b7cd                	j	80004e84 <fileclose+0x9a>
    begin_op();
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	a76080e7          	jalr	-1418(ra) # 8000491a <begin_op>
    iput(ff.ip);
    80004eac:	854e                	mv	a0,s3
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	240080e7          	jalr	576(ra) # 800040ee <iput>
    end_op();
    80004eb6:	00000097          	auipc	ra,0x0
    80004eba:	ade080e7          	jalr	-1314(ra) # 80004994 <end_op>
    80004ebe:	7902                	ld	s2,32(sp)
    80004ec0:	69e2                	ld	s3,24(sp)
    80004ec2:	6a42                	ld	s4,16(sp)
    80004ec4:	6aa2                	ld	s5,8(sp)
    80004ec6:	bf7d                	j	80004e84 <fileclose+0x9a>

0000000080004ec8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ec8:	715d                	addi	sp,sp,-80
    80004eca:	e486                	sd	ra,72(sp)
    80004ecc:	e0a2                	sd	s0,64(sp)
    80004ece:	fc26                	sd	s1,56(sp)
    80004ed0:	f44e                	sd	s3,40(sp)
    80004ed2:	0880                	addi	s0,sp,80
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ed8:	ffffd097          	auipc	ra,0xffffd
    80004edc:	bd8080e7          	jalr	-1064(ra) # 80001ab0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ee0:	409c                	lw	a5,0(s1)
    80004ee2:	37f9                	addiw	a5,a5,-2
    80004ee4:	4705                	li	a4,1
    80004ee6:	04f76a63          	bltu	a4,a5,80004f3a <filestat+0x72>
    80004eea:	f84a                	sd	s2,48(sp)
    80004eec:	f052                	sd	s4,32(sp)
    80004eee:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ef0:	6c88                	ld	a0,24(s1)
    80004ef2:	fffff097          	auipc	ra,0xfffff
    80004ef6:	03e080e7          	jalr	62(ra) # 80003f30 <ilock>
    stati(f->ip, &st);
    80004efa:	fb840a13          	addi	s4,s0,-72
    80004efe:	85d2                	mv	a1,s4
    80004f00:	6c88                	ld	a0,24(s1)
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	2bc080e7          	jalr	700(ra) # 800041be <stati>
    iunlock(f->ip);
    80004f0a:	6c88                	ld	a0,24(s1)
    80004f0c:	fffff097          	auipc	ra,0xfffff
    80004f10:	0ea080e7          	jalr	234(ra) # 80003ff6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f14:	46e1                	li	a3,24
    80004f16:	8652                	mv	a2,s4
    80004f18:	85ce                	mv	a1,s3
    80004f1a:	22893503          	ld	a0,552(s2)
    80004f1e:	ffffc097          	auipc	ra,0xffffc
    80004f22:	7f2080e7          	jalr	2034(ra) # 80001710 <copyout>
    80004f26:	41f5551b          	sraiw	a0,a0,0x1f
    80004f2a:	7942                	ld	s2,48(sp)
    80004f2c:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004f2e:	60a6                	ld	ra,72(sp)
    80004f30:	6406                	ld	s0,64(sp)
    80004f32:	74e2                	ld	s1,56(sp)
    80004f34:	79a2                	ld	s3,40(sp)
    80004f36:	6161                	addi	sp,sp,80
    80004f38:	8082                	ret
  return -1;
    80004f3a:	557d                	li	a0,-1
    80004f3c:	bfcd                	j	80004f2e <filestat+0x66>

0000000080004f3e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f3e:	7179                	addi	sp,sp,-48
    80004f40:	f406                	sd	ra,40(sp)
    80004f42:	f022                	sd	s0,32(sp)
    80004f44:	e84a                	sd	s2,16(sp)
    80004f46:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f48:	00854783          	lbu	a5,8(a0)
    80004f4c:	cbc5                	beqz	a5,80004ffc <fileread+0xbe>
    80004f4e:	ec26                	sd	s1,24(sp)
    80004f50:	e44e                	sd	s3,8(sp)
    80004f52:	84aa                	mv	s1,a0
    80004f54:	89ae                	mv	s3,a1
    80004f56:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f58:	411c                	lw	a5,0(a0)
    80004f5a:	4705                	li	a4,1
    80004f5c:	04e78963          	beq	a5,a4,80004fae <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f60:	470d                	li	a4,3
    80004f62:	04e78f63          	beq	a5,a4,80004fc0 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f66:	4709                	li	a4,2
    80004f68:	08e79263          	bne	a5,a4,80004fec <fileread+0xae>
    ilock(f->ip);
    80004f6c:	6d08                	ld	a0,24(a0)
    80004f6e:	fffff097          	auipc	ra,0xfffff
    80004f72:	fc2080e7          	jalr	-62(ra) # 80003f30 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f76:	874a                	mv	a4,s2
    80004f78:	5094                	lw	a3,32(s1)
    80004f7a:	864e                	mv	a2,s3
    80004f7c:	4585                	li	a1,1
    80004f7e:	6c88                	ld	a0,24(s1)
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	26c080e7          	jalr	620(ra) # 800041ec <readi>
    80004f88:	892a                	mv	s2,a0
    80004f8a:	00a05563          	blez	a0,80004f94 <fileread+0x56>
      f->off += r;
    80004f8e:	509c                	lw	a5,32(s1)
    80004f90:	9fa9                	addw	a5,a5,a0
    80004f92:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f94:	6c88                	ld	a0,24(s1)
    80004f96:	fffff097          	auipc	ra,0xfffff
    80004f9a:	060080e7          	jalr	96(ra) # 80003ff6 <iunlock>
    80004f9e:	64e2                	ld	s1,24(sp)
    80004fa0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004fa2:	854a                	mv	a0,s2
    80004fa4:	70a2                	ld	ra,40(sp)
    80004fa6:	7402                	ld	s0,32(sp)
    80004fa8:	6942                	ld	s2,16(sp)
    80004faa:	6145                	addi	sp,sp,48
    80004fac:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004fae:	6908                	ld	a0,16(a0)
    80004fb0:	00000097          	auipc	ra,0x0
    80004fb4:	41a080e7          	jalr	1050(ra) # 800053ca <piperead>
    80004fb8:	892a                	mv	s2,a0
    80004fba:	64e2                	ld	s1,24(sp)
    80004fbc:	69a2                	ld	s3,8(sp)
    80004fbe:	b7d5                	j	80004fa2 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fc0:	02451783          	lh	a5,36(a0)
    80004fc4:	03079693          	slli	a3,a5,0x30
    80004fc8:	92c1                	srli	a3,a3,0x30
    80004fca:	4725                	li	a4,9
    80004fcc:	02d76a63          	bltu	a4,a3,80005000 <fileread+0xc2>
    80004fd0:	0792                	slli	a5,a5,0x4
    80004fd2:	00024717          	auipc	a4,0x24
    80004fd6:	eb670713          	addi	a4,a4,-330 # 80028e88 <devsw>
    80004fda:	97ba                	add	a5,a5,a4
    80004fdc:	639c                	ld	a5,0(a5)
    80004fde:	c78d                	beqz	a5,80005008 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004fe0:	4505                	li	a0,1
    80004fe2:	9782                	jalr	a5
    80004fe4:	892a                	mv	s2,a0
    80004fe6:	64e2                	ld	s1,24(sp)
    80004fe8:	69a2                	ld	s3,8(sp)
    80004fea:	bf65                	j	80004fa2 <fileread+0x64>
    panic("fileread");
    80004fec:	00003517          	auipc	a0,0x3
    80004ff0:	63c50513          	addi	a0,a0,1596 # 80008628 <etext+0x628>
    80004ff4:	ffffb097          	auipc	ra,0xffffb
    80004ff8:	56c080e7          	jalr	1388(ra) # 80000560 <panic>
    return -1;
    80004ffc:	597d                	li	s2,-1
    80004ffe:	b755                	j	80004fa2 <fileread+0x64>
      return -1;
    80005000:	597d                	li	s2,-1
    80005002:	64e2                	ld	s1,24(sp)
    80005004:	69a2                	ld	s3,8(sp)
    80005006:	bf71                	j	80004fa2 <fileread+0x64>
    80005008:	597d                	li	s2,-1
    8000500a:	64e2                	ld	s1,24(sp)
    8000500c:	69a2                	ld	s3,8(sp)
    8000500e:	bf51                	j	80004fa2 <fileread+0x64>

0000000080005010 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005010:	00954783          	lbu	a5,9(a0)
    80005014:	12078c63          	beqz	a5,8000514c <filewrite+0x13c>
{
    80005018:	711d                	addi	sp,sp,-96
    8000501a:	ec86                	sd	ra,88(sp)
    8000501c:	e8a2                	sd	s0,80(sp)
    8000501e:	e0ca                	sd	s2,64(sp)
    80005020:	f456                	sd	s5,40(sp)
    80005022:	f05a                	sd	s6,32(sp)
    80005024:	1080                	addi	s0,sp,96
    80005026:	892a                	mv	s2,a0
    80005028:	8b2e                	mv	s6,a1
    8000502a:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000502c:	411c                	lw	a5,0(a0)
    8000502e:	4705                	li	a4,1
    80005030:	02e78963          	beq	a5,a4,80005062 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005034:	470d                	li	a4,3
    80005036:	02e78c63          	beq	a5,a4,8000506e <filewrite+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000503a:	4709                	li	a4,2
    8000503c:	0ee79a63          	bne	a5,a4,80005130 <filewrite+0x120>
    80005040:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005042:	0cc05563          	blez	a2,8000510c <filewrite+0xfc>
    80005046:	e4a6                	sd	s1,72(sp)
    80005048:	fc4e                	sd	s3,56(sp)
    8000504a:	ec5e                	sd	s7,24(sp)
    8000504c:	e862                	sd	s8,16(sp)
    8000504e:	e466                	sd	s9,8(sp)
    int i = 0;
    80005050:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80005052:	6b85                	lui	s7,0x1
    80005054:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005058:	6c85                	lui	s9,0x1
    8000505a:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000505e:	4c05                	li	s8,1
    80005060:	a849                	j	800050f2 <filewrite+0xe2>
    ret = pipewrite(f->pipe, addr, n);
    80005062:	6908                	ld	a0,16(a0)
    80005064:	00000097          	auipc	ra,0x0
    80005068:	24a080e7          	jalr	586(ra) # 800052ae <pipewrite>
    8000506c:	a85d                	j	80005122 <filewrite+0x112>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000506e:	02451783          	lh	a5,36(a0)
    80005072:	03079693          	slli	a3,a5,0x30
    80005076:	92c1                	srli	a3,a3,0x30
    80005078:	4725                	li	a4,9
    8000507a:	0cd76b63          	bltu	a4,a3,80005150 <filewrite+0x140>
    8000507e:	0792                	slli	a5,a5,0x4
    80005080:	00024717          	auipc	a4,0x24
    80005084:	e0870713          	addi	a4,a4,-504 # 80028e88 <devsw>
    80005088:	97ba                	add	a5,a5,a4
    8000508a:	679c                	ld	a5,8(a5)
    8000508c:	c7e1                	beqz	a5,80005154 <filewrite+0x144>
    ret = devsw[f->major].write(1, addr, n);
    8000508e:	4505                	li	a0,1
    80005090:	9782                	jalr	a5
    80005092:	a841                	j	80005122 <filewrite+0x112>
      if(n1 > max)
    80005094:	2981                	sext.w	s3,s3
      begin_op();
    80005096:	00000097          	auipc	ra,0x0
    8000509a:	884080e7          	jalr	-1916(ra) # 8000491a <begin_op>
      ilock(f->ip);
    8000509e:	01893503          	ld	a0,24(s2)
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	e8e080e7          	jalr	-370(ra) # 80003f30 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050aa:	874e                	mv	a4,s3
    800050ac:	02092683          	lw	a3,32(s2)
    800050b0:	016a0633          	add	a2,s4,s6
    800050b4:	85e2                	mv	a1,s8
    800050b6:	01893503          	ld	a0,24(s2)
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	238080e7          	jalr	568(ra) # 800042f2 <writei>
    800050c2:	84aa                	mv	s1,a0
    800050c4:	00a05763          	blez	a0,800050d2 <filewrite+0xc2>
        f->off += r;
    800050c8:	02092783          	lw	a5,32(s2)
    800050cc:	9fa9                	addw	a5,a5,a0
    800050ce:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800050d2:	01893503          	ld	a0,24(s2)
    800050d6:	fffff097          	auipc	ra,0xfffff
    800050da:	f20080e7          	jalr	-224(ra) # 80003ff6 <iunlock>
      end_op();
    800050de:	00000097          	auipc	ra,0x0
    800050e2:	8b6080e7          	jalr	-1866(ra) # 80004994 <end_op>

      if(r != n1){
    800050e6:	02999563          	bne	s3,s1,80005110 <filewrite+0x100>
        // error from writei
        break;
      }
      i += r;
    800050ea:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800050ee:	015a5963          	bge	s4,s5,80005100 <filewrite+0xf0>
      int n1 = n - i;
    800050f2:	414a87bb          	subw	a5,s5,s4
    800050f6:	89be                	mv	s3,a5
      if(n1 > max)
    800050f8:	f8fbdee3          	bge	s7,a5,80005094 <filewrite+0x84>
    800050fc:	89e6                	mv	s3,s9
    800050fe:	bf59                	j	80005094 <filewrite+0x84>
    80005100:	64a6                	ld	s1,72(sp)
    80005102:	79e2                	ld	s3,56(sp)
    80005104:	6be2                	ld	s7,24(sp)
    80005106:	6c42                	ld	s8,16(sp)
    80005108:	6ca2                	ld	s9,8(sp)
    8000510a:	a801                	j	8000511a <filewrite+0x10a>
    int i = 0;
    8000510c:	4a01                	li	s4,0
    8000510e:	a031                	j	8000511a <filewrite+0x10a>
    80005110:	64a6                	ld	s1,72(sp)
    80005112:	79e2                	ld	s3,56(sp)
    80005114:	6be2                	ld	s7,24(sp)
    80005116:	6c42                	ld	s8,16(sp)
    80005118:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000511a:	034a9f63          	bne	s5,s4,80005158 <filewrite+0x148>
    8000511e:	8556                	mv	a0,s5
    80005120:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005122:	60e6                	ld	ra,88(sp)
    80005124:	6446                	ld	s0,80(sp)
    80005126:	6906                	ld	s2,64(sp)
    80005128:	7aa2                	ld	s5,40(sp)
    8000512a:	7b02                	ld	s6,32(sp)
    8000512c:	6125                	addi	sp,sp,96
    8000512e:	8082                	ret
    80005130:	e4a6                	sd	s1,72(sp)
    80005132:	fc4e                	sd	s3,56(sp)
    80005134:	f852                	sd	s4,48(sp)
    80005136:	ec5e                	sd	s7,24(sp)
    80005138:	e862                	sd	s8,16(sp)
    8000513a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000513c:	00003517          	auipc	a0,0x3
    80005140:	4fc50513          	addi	a0,a0,1276 # 80008638 <etext+0x638>
    80005144:	ffffb097          	auipc	ra,0xffffb
    80005148:	41c080e7          	jalr	1052(ra) # 80000560 <panic>
    return -1;
    8000514c:	557d                	li	a0,-1
}
    8000514e:	8082                	ret
      return -1;
    80005150:	557d                	li	a0,-1
    80005152:	bfc1                	j	80005122 <filewrite+0x112>
    80005154:	557d                	li	a0,-1
    80005156:	b7f1                	j	80005122 <filewrite+0x112>
    ret = (i == n ? n : -1);
    80005158:	557d                	li	a0,-1
    8000515a:	7a42                	ld	s4,48(sp)
    8000515c:	b7d9                	j	80005122 <filewrite+0x112>

000000008000515e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000515e:	7179                	addi	sp,sp,-48
    80005160:	f406                	sd	ra,40(sp)
    80005162:	f022                	sd	s0,32(sp)
    80005164:	ec26                	sd	s1,24(sp)
    80005166:	e052                	sd	s4,0(sp)
    80005168:	1800                	addi	s0,sp,48
    8000516a:	84aa                	mv	s1,a0
    8000516c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000516e:	0005b023          	sd	zero,0(a1)
    80005172:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005176:	00000097          	auipc	ra,0x0
    8000517a:	bb8080e7          	jalr	-1096(ra) # 80004d2e <filealloc>
    8000517e:	e088                	sd	a0,0(s1)
    80005180:	cd49                	beqz	a0,8000521a <pipealloc+0xbc>
    80005182:	00000097          	auipc	ra,0x0
    80005186:	bac080e7          	jalr	-1108(ra) # 80004d2e <filealloc>
    8000518a:	00aa3023          	sd	a0,0(s4)
    8000518e:	c141                	beqz	a0,8000520e <pipealloc+0xb0>
    80005190:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	9b8080e7          	jalr	-1608(ra) # 80000b4a <kalloc>
    8000519a:	892a                	mv	s2,a0
    8000519c:	c13d                	beqz	a0,80005202 <pipealloc+0xa4>
    8000519e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800051a0:	4985                	li	s3,1
    800051a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051b2:	00003597          	auipc	a1,0x3
    800051b6:	49658593          	addi	a1,a1,1174 # 80008648 <etext+0x648>
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	9f0080e7          	jalr	-1552(ra) # 80000baa <initlock>
  (*f0)->type = FD_PIPE;
    800051c2:	609c                	ld	a5,0(s1)
    800051c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051c8:	609c                	ld	a5,0(s1)
    800051ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051ce:	609c                	ld	a5,0(s1)
    800051d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051d4:	609c                	ld	a5,0(s1)
    800051d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051da:	000a3783          	ld	a5,0(s4)
    800051de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051e2:	000a3783          	ld	a5,0(s4)
    800051e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051ea:	000a3783          	ld	a5,0(s4)
    800051ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051f2:	000a3783          	ld	a5,0(s4)
    800051f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800051fa:	4501                	li	a0,0
    800051fc:	6942                	ld	s2,16(sp)
    800051fe:	69a2                	ld	s3,8(sp)
    80005200:	a03d                	j	8000522e <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005202:	6088                	ld	a0,0(s1)
    80005204:	c119                	beqz	a0,8000520a <pipealloc+0xac>
    80005206:	6942                	ld	s2,16(sp)
    80005208:	a029                	j	80005212 <pipealloc+0xb4>
    8000520a:	6942                	ld	s2,16(sp)
    8000520c:	a039                	j	8000521a <pipealloc+0xbc>
    8000520e:	6088                	ld	a0,0(s1)
    80005210:	c50d                	beqz	a0,8000523a <pipealloc+0xdc>
    fileclose(*f0);
    80005212:	00000097          	auipc	ra,0x0
    80005216:	bd8080e7          	jalr	-1064(ra) # 80004dea <fileclose>
  if(*f1)
    8000521a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000521e:	557d                	li	a0,-1
  if(*f1)
    80005220:	c799                	beqz	a5,8000522e <pipealloc+0xd0>
    fileclose(*f1);
    80005222:	853e                	mv	a0,a5
    80005224:	00000097          	auipc	ra,0x0
    80005228:	bc6080e7          	jalr	-1082(ra) # 80004dea <fileclose>
  return -1;
    8000522c:	557d                	li	a0,-1
}
    8000522e:	70a2                	ld	ra,40(sp)
    80005230:	7402                	ld	s0,32(sp)
    80005232:	64e2                	ld	s1,24(sp)
    80005234:	6a02                	ld	s4,0(sp)
    80005236:	6145                	addi	sp,sp,48
    80005238:	8082                	ret
  return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	bfcd                	j	8000522e <pipealloc+0xd0>

000000008000523e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000523e:	1101                	addi	sp,sp,-32
    80005240:	ec06                	sd	ra,24(sp)
    80005242:	e822                	sd	s0,16(sp)
    80005244:	e426                	sd	s1,8(sp)
    80005246:	e04a                	sd	s2,0(sp)
    80005248:	1000                	addi	s0,sp,32
    8000524a:	84aa                	mv	s1,a0
    8000524c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	9f0080e7          	jalr	-1552(ra) # 80000c3e <acquire>
  if(writable){
    80005256:	02090d63          	beqz	s2,80005290 <pipeclose+0x52>
    pi->writeopen = 0;
    8000525a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000525e:	21848513          	addi	a0,s1,536
    80005262:	ffffd097          	auipc	ra,0xffffd
    80005266:	356080e7          	jalr	854(ra) # 800025b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000526a:	2204b783          	ld	a5,544(s1)
    8000526e:	eb95                	bnez	a5,800052a2 <pipeclose+0x64>
    release(&pi->lock);
    80005270:	8526                	mv	a0,s1
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	a7c080e7          	jalr	-1412(ra) # 80000cee <release>
    kfree((char*)pi);
    8000527a:	8526                	mv	a0,s1
    8000527c:	ffffb097          	auipc	ra,0xffffb
    80005280:	7d0080e7          	jalr	2000(ra) # 80000a4c <kfree>
  } else
    release(&pi->lock);
}
    80005284:	60e2                	ld	ra,24(sp)
    80005286:	6442                	ld	s0,16(sp)
    80005288:	64a2                	ld	s1,8(sp)
    8000528a:	6902                	ld	s2,0(sp)
    8000528c:	6105                	addi	sp,sp,32
    8000528e:	8082                	ret
    pi->readopen = 0;
    80005290:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005294:	21c48513          	addi	a0,s1,540
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	320080e7          	jalr	800(ra) # 800025b8 <wakeup>
    800052a0:	b7e9                	j	8000526a <pipeclose+0x2c>
    release(&pi->lock);
    800052a2:	8526                	mv	a0,s1
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	a4a080e7          	jalr	-1462(ra) # 80000cee <release>
}
    800052ac:	bfe1                	j	80005284 <pipeclose+0x46>

00000000800052ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052ae:	7159                	addi	sp,sp,-112
    800052b0:	f486                	sd	ra,104(sp)
    800052b2:	f0a2                	sd	s0,96(sp)
    800052b4:	eca6                	sd	s1,88(sp)
    800052b6:	e8ca                	sd	s2,80(sp)
    800052b8:	e4ce                	sd	s3,72(sp)
    800052ba:	e0d2                	sd	s4,64(sp)
    800052bc:	fc56                	sd	s5,56(sp)
    800052be:	1880                	addi	s0,sp,112
    800052c0:	84aa                	mv	s1,a0
    800052c2:	8aae                	mv	s5,a1
    800052c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052c6:	ffffc097          	auipc	ra,0xffffc
    800052ca:	7ea080e7          	jalr	2026(ra) # 80001ab0 <myproc>
    800052ce:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052d0:	8526                	mv	a0,s1
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	96c080e7          	jalr	-1684(ra) # 80000c3e <acquire>
  while(i < n){
    800052da:	0f405063          	blez	s4,800053ba <pipewrite+0x10c>
    800052de:	f85a                	sd	s6,48(sp)
    800052e0:	f45e                	sd	s7,40(sp)
    800052e2:	f062                	sd	s8,32(sp)
    800052e4:	ec66                	sd	s9,24(sp)
    800052e6:	e86a                	sd	s10,16(sp)
  int i = 0;
    800052e8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052ea:	f9f40c13          	addi	s8,s0,-97
    800052ee:	4b85                	li	s7,1
    800052f0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052f2:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800052f6:	21c48c93          	addi	s9,s1,540
    800052fa:	a099                	j	80005340 <pipewrite+0x92>
      release(&pi->lock);
    800052fc:	8526                	mv	a0,s1
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	9f0080e7          	jalr	-1552(ra) # 80000cee <release>
      return -1;
    80005306:	597d                	li	s2,-1
    80005308:	7b42                	ld	s6,48(sp)
    8000530a:	7ba2                	ld	s7,40(sp)
    8000530c:	7c02                	ld	s8,32(sp)
    8000530e:	6ce2                	ld	s9,24(sp)
    80005310:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005312:	854a                	mv	a0,s2
    80005314:	70a6                	ld	ra,104(sp)
    80005316:	7406                	ld	s0,96(sp)
    80005318:	64e6                	ld	s1,88(sp)
    8000531a:	6946                	ld	s2,80(sp)
    8000531c:	69a6                	ld	s3,72(sp)
    8000531e:	6a06                	ld	s4,64(sp)
    80005320:	7ae2                	ld	s5,56(sp)
    80005322:	6165                	addi	sp,sp,112
    80005324:	8082                	ret
      wakeup(&pi->nread);
    80005326:	856a                	mv	a0,s10
    80005328:	ffffd097          	auipc	ra,0xffffd
    8000532c:	290080e7          	jalr	656(ra) # 800025b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005330:	85a6                	mv	a1,s1
    80005332:	8566                	mv	a0,s9
    80005334:	ffffd097          	auipc	ra,0xffffd
    80005338:	220080e7          	jalr	544(ra) # 80002554 <sleep>
  while(i < n){
    8000533c:	05495e63          	bge	s2,s4,80005398 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    80005340:	2204a783          	lw	a5,544(s1)
    80005344:	dfc5                	beqz	a5,800052fc <pipewrite+0x4e>
    80005346:	854e                	mv	a0,s3
    80005348:	ffffd097          	auipc	ra,0xffffd
    8000534c:	4c0080e7          	jalr	1216(ra) # 80002808 <killed>
    80005350:	f555                	bnez	a0,800052fc <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005352:	2184a783          	lw	a5,536(s1)
    80005356:	21c4a703          	lw	a4,540(s1)
    8000535a:	2007879b          	addiw	a5,a5,512
    8000535e:	fcf704e3          	beq	a4,a5,80005326 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005362:	86de                	mv	a3,s7
    80005364:	01590633          	add	a2,s2,s5
    80005368:	85e2                	mv	a1,s8
    8000536a:	2289b503          	ld	a0,552(s3)
    8000536e:	ffffc097          	auipc	ra,0xffffc
    80005372:	42e080e7          	jalr	1070(ra) # 8000179c <copyin>
    80005376:	05650463          	beq	a0,s6,800053be <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000537a:	21c4a783          	lw	a5,540(s1)
    8000537e:	0017871b          	addiw	a4,a5,1
    80005382:	20e4ae23          	sw	a4,540(s1)
    80005386:	1ff7f793          	andi	a5,a5,511
    8000538a:	97a6                	add	a5,a5,s1
    8000538c:	f9f44703          	lbu	a4,-97(s0)
    80005390:	00e78c23          	sb	a4,24(a5)
      i++;
    80005394:	2905                	addiw	s2,s2,1
    80005396:	b75d                	j	8000533c <pipewrite+0x8e>
    80005398:	7b42                	ld	s6,48(sp)
    8000539a:	7ba2                	ld	s7,40(sp)
    8000539c:	7c02                	ld	s8,32(sp)
    8000539e:	6ce2                	ld	s9,24(sp)
    800053a0:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800053a2:	21848513          	addi	a0,s1,536
    800053a6:	ffffd097          	auipc	ra,0xffffd
    800053aa:	212080e7          	jalr	530(ra) # 800025b8 <wakeup>
  release(&pi->lock);
    800053ae:	8526                	mv	a0,s1
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	93e080e7          	jalr	-1730(ra) # 80000cee <release>
  return i;
    800053b8:	bfa9                	j	80005312 <pipewrite+0x64>
  int i = 0;
    800053ba:	4901                	li	s2,0
    800053bc:	b7dd                	j	800053a2 <pipewrite+0xf4>
    800053be:	7b42                	ld	s6,48(sp)
    800053c0:	7ba2                	ld	s7,40(sp)
    800053c2:	7c02                	ld	s8,32(sp)
    800053c4:	6ce2                	ld	s9,24(sp)
    800053c6:	6d42                	ld	s10,16(sp)
    800053c8:	bfe9                	j	800053a2 <pipewrite+0xf4>

00000000800053ca <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053ca:	711d                	addi	sp,sp,-96
    800053cc:	ec86                	sd	ra,88(sp)
    800053ce:	e8a2                	sd	s0,80(sp)
    800053d0:	e4a6                	sd	s1,72(sp)
    800053d2:	e0ca                	sd	s2,64(sp)
    800053d4:	fc4e                	sd	s3,56(sp)
    800053d6:	f852                	sd	s4,48(sp)
    800053d8:	f456                	sd	s5,40(sp)
    800053da:	1080                	addi	s0,sp,96
    800053dc:	84aa                	mv	s1,a0
    800053de:	892e                	mv	s2,a1
    800053e0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053e2:	ffffc097          	auipc	ra,0xffffc
    800053e6:	6ce080e7          	jalr	1742(ra) # 80001ab0 <myproc>
    800053ea:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053ec:	8526                	mv	a0,s1
    800053ee:	ffffc097          	auipc	ra,0xffffc
    800053f2:	850080e7          	jalr	-1968(ra) # 80000c3e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053f6:	2184a703          	lw	a4,536(s1)
    800053fa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053fe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005402:	02f71b63          	bne	a4,a5,80005438 <piperead+0x6e>
    80005406:	2244a783          	lw	a5,548(s1)
    8000540a:	c3b1                	beqz	a5,8000544e <piperead+0x84>
    if(killed(pr)){
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffd097          	auipc	ra,0xffffd
    80005412:	3fa080e7          	jalr	1018(ra) # 80002808 <killed>
    80005416:	e50d                	bnez	a0,80005440 <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005418:	85a6                	mv	a1,s1
    8000541a:	854e                	mv	a0,s3
    8000541c:	ffffd097          	auipc	ra,0xffffd
    80005420:	138080e7          	jalr	312(ra) # 80002554 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005424:	2184a703          	lw	a4,536(s1)
    80005428:	21c4a783          	lw	a5,540(s1)
    8000542c:	fcf70de3          	beq	a4,a5,80005406 <piperead+0x3c>
    80005430:	f05a                	sd	s6,32(sp)
    80005432:	ec5e                	sd	s7,24(sp)
    80005434:	e862                	sd	s8,16(sp)
    80005436:	a839                	j	80005454 <piperead+0x8a>
    80005438:	f05a                	sd	s6,32(sp)
    8000543a:	ec5e                	sd	s7,24(sp)
    8000543c:	e862                	sd	s8,16(sp)
    8000543e:	a819                	j	80005454 <piperead+0x8a>
      release(&pi->lock);
    80005440:	8526                	mv	a0,s1
    80005442:	ffffc097          	auipc	ra,0xffffc
    80005446:	8ac080e7          	jalr	-1876(ra) # 80000cee <release>
      return -1;
    8000544a:	59fd                	li	s3,-1
    8000544c:	a895                	j	800054c0 <piperead+0xf6>
    8000544e:	f05a                	sd	s6,32(sp)
    80005450:	ec5e                	sd	s7,24(sp)
    80005452:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005454:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005456:	faf40c13          	addi	s8,s0,-81
    8000545a:	4b85                	li	s7,1
    8000545c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000545e:	05505363          	blez	s5,800054a4 <piperead+0xda>
    if(pi->nread == pi->nwrite)
    80005462:	2184a783          	lw	a5,536(s1)
    80005466:	21c4a703          	lw	a4,540(s1)
    8000546a:	02f70d63          	beq	a4,a5,800054a4 <piperead+0xda>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000546e:	0017871b          	addiw	a4,a5,1
    80005472:	20e4ac23          	sw	a4,536(s1)
    80005476:	1ff7f793          	andi	a5,a5,511
    8000547a:	97a6                	add	a5,a5,s1
    8000547c:	0187c783          	lbu	a5,24(a5)
    80005480:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005484:	86de                	mv	a3,s7
    80005486:	8662                	mv	a2,s8
    80005488:	85ca                	mv	a1,s2
    8000548a:	228a3503          	ld	a0,552(s4)
    8000548e:	ffffc097          	auipc	ra,0xffffc
    80005492:	282080e7          	jalr	642(ra) # 80001710 <copyout>
    80005496:	01650763          	beq	a0,s6,800054a4 <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000549a:	2985                	addiw	s3,s3,1
    8000549c:	0905                	addi	s2,s2,1
    8000549e:	fd3a92e3          	bne	s5,s3,80005462 <piperead+0x98>
    800054a2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800054a4:	21c48513          	addi	a0,s1,540
    800054a8:	ffffd097          	auipc	ra,0xffffd
    800054ac:	110080e7          	jalr	272(ra) # 800025b8 <wakeup>
  release(&pi->lock);
    800054b0:	8526                	mv	a0,s1
    800054b2:	ffffc097          	auipc	ra,0xffffc
    800054b6:	83c080e7          	jalr	-1988(ra) # 80000cee <release>
    800054ba:	7b02                	ld	s6,32(sp)
    800054bc:	6be2                	ld	s7,24(sp)
    800054be:	6c42                	ld	s8,16(sp)
  return i;
}
    800054c0:	854e                	mv	a0,s3
    800054c2:	60e6                	ld	ra,88(sp)
    800054c4:	6446                	ld	s0,80(sp)
    800054c6:	64a6                	ld	s1,72(sp)
    800054c8:	6906                	ld	s2,64(sp)
    800054ca:	79e2                	ld	s3,56(sp)
    800054cc:	7a42                	ld	s4,48(sp)
    800054ce:	7aa2                	ld	s5,40(sp)
    800054d0:	6125                	addi	sp,sp,96
    800054d2:	8082                	ret

00000000800054d4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800054d4:	1141                	addi	sp,sp,-16
    800054d6:	e406                	sd	ra,8(sp)
    800054d8:	e022                	sd	s0,0(sp)
    800054da:	0800                	addi	s0,sp,16
    800054dc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800054de:	0035151b          	slliw	a0,a0,0x3
    800054e2:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800054e4:	8b89                	andi	a5,a5,2
    800054e6:	c399                	beqz	a5,800054ec <flags2perm+0x18>
      perm |= PTE_W;
    800054e8:	00456513          	ori	a0,a0,4
    return perm;
}
    800054ec:	60a2                	ld	ra,8(sp)
    800054ee:	6402                	ld	s0,0(sp)
    800054f0:	0141                	addi	sp,sp,16
    800054f2:	8082                	ret

00000000800054f4 <exec>:

int
exec(char *path, char **argv)
{
    800054f4:	de010113          	addi	sp,sp,-544
    800054f8:	20113c23          	sd	ra,536(sp)
    800054fc:	20813823          	sd	s0,528(sp)
    80005500:	20913423          	sd	s1,520(sp)
    80005504:	21213023          	sd	s2,512(sp)
    80005508:	1400                	addi	s0,sp,544
    8000550a:	892a                	mv	s2,a0
    8000550c:	dea43823          	sd	a0,-528(s0)
    80005510:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005514:	ffffc097          	auipc	ra,0xffffc
    80005518:	59c080e7          	jalr	1436(ra) # 80001ab0 <myproc>
    8000551c:	84aa                	mv	s1,a0

  begin_op();
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	3fc080e7          	jalr	1020(ra) # 8000491a <begin_op>

  if((ip = namei(path)) == 0){
    80005526:	854a                	mv	a0,s2
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	1ec080e7          	jalr	492(ra) # 80004714 <namei>
    80005530:	c525                	beqz	a0,80005598 <exec+0xa4>
    80005532:	fbd2                	sd	s4,496(sp)
    80005534:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	9fa080e7          	jalr	-1542(ra) # 80003f30 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000553e:	04000713          	li	a4,64
    80005542:	4681                	li	a3,0
    80005544:	e5040613          	addi	a2,s0,-432
    80005548:	4581                	li	a1,0
    8000554a:	8552                	mv	a0,s4
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	ca0080e7          	jalr	-864(ra) # 800041ec <readi>
    80005554:	04000793          	li	a5,64
    80005558:	00f51a63          	bne	a0,a5,8000556c <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000555c:	e5042703          	lw	a4,-432(s0)
    80005560:	464c47b7          	lui	a5,0x464c4
    80005564:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005568:	02f70e63          	beq	a4,a5,800055a4 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000556c:	8552                	mv	a0,s4
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	c28080e7          	jalr	-984(ra) # 80004196 <iunlockput>
    end_op();
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	41e080e7          	jalr	1054(ra) # 80004994 <end_op>
  }
  return -1;
    8000557e:	557d                	li	a0,-1
    80005580:	7a5e                	ld	s4,496(sp)
}
    80005582:	21813083          	ld	ra,536(sp)
    80005586:	21013403          	ld	s0,528(sp)
    8000558a:	20813483          	ld	s1,520(sp)
    8000558e:	20013903          	ld	s2,512(sp)
    80005592:	22010113          	addi	sp,sp,544
    80005596:	8082                	ret
    end_op();
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	3fc080e7          	jalr	1020(ra) # 80004994 <end_op>
    return -1;
    800055a0:	557d                	li	a0,-1
    800055a2:	b7c5                	j	80005582 <exec+0x8e>
    800055a4:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800055a6:	8526                	mv	a0,s1
    800055a8:	ffffc097          	auipc	ra,0xffffc
    800055ac:	5cc080e7          	jalr	1484(ra) # 80001b74 <proc_pagetable>
    800055b0:	8b2a                	mv	s6,a0
    800055b2:	2c050163          	beqz	a0,80005874 <exec+0x380>
    800055b6:	ffce                	sd	s3,504(sp)
    800055b8:	f7d6                	sd	s5,488(sp)
    800055ba:	efde                	sd	s7,472(sp)
    800055bc:	ebe2                	sd	s8,464(sp)
    800055be:	e7e6                	sd	s9,456(sp)
    800055c0:	e3ea                	sd	s10,448(sp)
    800055c2:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055c4:	e7042683          	lw	a3,-400(s0)
    800055c8:	e8845783          	lhu	a5,-376(s0)
    800055cc:	10078363          	beqz	a5,800056d2 <exec+0x1de>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055d0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055d2:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055d4:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800055d8:	6c85                	lui	s9,0x1
    800055da:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800055de:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800055e2:	6a85                	lui	s5,0x1
    800055e4:	a0b5                	j	80005650 <exec+0x15c>
      panic("loadseg: address should exist");
    800055e6:	00003517          	auipc	a0,0x3
    800055ea:	06a50513          	addi	a0,a0,106 # 80008650 <etext+0x650>
    800055ee:	ffffb097          	auipc	ra,0xffffb
    800055f2:	f72080e7          	jalr	-142(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800055f6:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055f8:	874a                	mv	a4,s2
    800055fa:	009c06bb          	addw	a3,s8,s1
    800055fe:	4581                	li	a1,0
    80005600:	8552                	mv	a0,s4
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	bea080e7          	jalr	-1046(ra) # 800041ec <readi>
    8000560a:	26a91963          	bne	s2,a0,8000587c <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    8000560e:	009a84bb          	addw	s1,s5,s1
    80005612:	0334f463          	bgeu	s1,s3,8000563a <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80005616:	02049593          	slli	a1,s1,0x20
    8000561a:	9181                	srli	a1,a1,0x20
    8000561c:	95de                	add	a1,a1,s7
    8000561e:	855a                	mv	a0,s6
    80005620:	ffffc097          	auipc	ra,0xffffc
    80005624:	ab8080e7          	jalr	-1352(ra) # 800010d8 <walkaddr>
    80005628:	862a                	mv	a2,a0
    if(pa == 0)
    8000562a:	dd55                	beqz	a0,800055e6 <exec+0xf2>
    if(sz - i < PGSIZE)
    8000562c:	409987bb          	subw	a5,s3,s1
    80005630:	893e                	mv	s2,a5
    80005632:	fcfcf2e3          	bgeu	s9,a5,800055f6 <exec+0x102>
    80005636:	8956                	mv	s2,s5
    80005638:	bf7d                	j	800055f6 <exec+0x102>
    sz = sz1;
    8000563a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000563e:	2d05                	addiw	s10,s10,1
    80005640:	e0843783          	ld	a5,-504(s0)
    80005644:	0387869b          	addiw	a3,a5,56
    80005648:	e8845783          	lhu	a5,-376(s0)
    8000564c:	08fd5463          	bge	s10,a5,800056d4 <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005650:	e0d43423          	sd	a3,-504(s0)
    80005654:	876e                	mv	a4,s11
    80005656:	e1840613          	addi	a2,s0,-488
    8000565a:	4581                	li	a1,0
    8000565c:	8552                	mv	a0,s4
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	b8e080e7          	jalr	-1138(ra) # 800041ec <readi>
    80005666:	21b51963          	bne	a0,s11,80005878 <exec+0x384>
    if(ph.type != ELF_PROG_LOAD)
    8000566a:	e1842783          	lw	a5,-488(s0)
    8000566e:	4705                	li	a4,1
    80005670:	fce797e3          	bne	a5,a4,8000563e <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80005674:	e4043483          	ld	s1,-448(s0)
    80005678:	e3843783          	ld	a5,-456(s0)
    8000567c:	22f4e063          	bltu	s1,a5,8000589c <exec+0x3a8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005680:	e2843783          	ld	a5,-472(s0)
    80005684:	94be                	add	s1,s1,a5
    80005686:	20f4ee63          	bltu	s1,a5,800058a2 <exec+0x3ae>
    if(ph.vaddr % PGSIZE != 0)
    8000568a:	de843703          	ld	a4,-536(s0)
    8000568e:	8ff9                	and	a5,a5,a4
    80005690:	20079c63          	bnez	a5,800058a8 <exec+0x3b4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005694:	e1c42503          	lw	a0,-484(s0)
    80005698:	00000097          	auipc	ra,0x0
    8000569c:	e3c080e7          	jalr	-452(ra) # 800054d4 <flags2perm>
    800056a0:	86aa                	mv	a3,a0
    800056a2:	8626                	mv	a2,s1
    800056a4:	85ca                	mv	a1,s2
    800056a6:	855a                	mv	a0,s6
    800056a8:	ffffc097          	auipc	ra,0xffffc
    800056ac:	df4080e7          	jalr	-524(ra) # 8000149c <uvmalloc>
    800056b0:	dea43c23          	sd	a0,-520(s0)
    800056b4:	1e050d63          	beqz	a0,800058ae <exec+0x3ba>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800056b8:	e2843b83          	ld	s7,-472(s0)
    800056bc:	e2042c03          	lw	s8,-480(s0)
    800056c0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800056c4:	00098463          	beqz	s3,800056cc <exec+0x1d8>
    800056c8:	4481                	li	s1,0
    800056ca:	b7b1                	j	80005616 <exec+0x122>
    sz = sz1;
    800056cc:	df843903          	ld	s2,-520(s0)
    800056d0:	b7bd                	j	8000563e <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056d2:	4901                	li	s2,0
  iunlockput(ip);
    800056d4:	8552                	mv	a0,s4
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	ac0080e7          	jalr	-1344(ra) # 80004196 <iunlockput>
  end_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	2b6080e7          	jalr	694(ra) # 80004994 <end_op>
  p = myproc();
    800056e6:	ffffc097          	auipc	ra,0xffffc
    800056ea:	3ca080e7          	jalr	970(ra) # 80001ab0 <myproc>
    800056ee:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800056f0:	22053d03          	ld	s10,544(a0)
  sz = PGROUNDUP(sz);
    800056f4:	6985                	lui	s3,0x1
    800056f6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800056f8:	99ca                	add	s3,s3,s2
    800056fa:	77fd                	lui	a5,0xfffff
    800056fc:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005700:	4691                	li	a3,4
    80005702:	6609                	lui	a2,0x2
    80005704:	964e                	add	a2,a2,s3
    80005706:	85ce                	mv	a1,s3
    80005708:	855a                	mv	a0,s6
    8000570a:	ffffc097          	auipc	ra,0xffffc
    8000570e:	d92080e7          	jalr	-622(ra) # 8000149c <uvmalloc>
    80005712:	8a2a                	mv	s4,a0
    80005714:	e115                	bnez	a0,80005738 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005716:	85ce                	mv	a1,s3
    80005718:	855a                	mv	a0,s6
    8000571a:	ffffc097          	auipc	ra,0xffffc
    8000571e:	4f6080e7          	jalr	1270(ra) # 80001c10 <proc_freepagetable>
  return -1;
    80005722:	557d                	li	a0,-1
    80005724:	79fe                	ld	s3,504(sp)
    80005726:	7a5e                	ld	s4,496(sp)
    80005728:	7abe                	ld	s5,488(sp)
    8000572a:	7b1e                	ld	s6,480(sp)
    8000572c:	6bfe                	ld	s7,472(sp)
    8000572e:	6c5e                	ld	s8,464(sp)
    80005730:	6cbe                	ld	s9,456(sp)
    80005732:	6d1e                	ld	s10,448(sp)
    80005734:	7dfa                	ld	s11,440(sp)
    80005736:	b5b1                	j	80005582 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005738:	75f9                	lui	a1,0xffffe
    8000573a:	95aa                	add	a1,a1,a0
    8000573c:	855a                	mv	a0,s6
    8000573e:	ffffc097          	auipc	ra,0xffffc
    80005742:	fa0080e7          	jalr	-96(ra) # 800016de <uvmclear>
  stackbase = sp - PGSIZE;
    80005746:	7bfd                	lui	s7,0xfffff
    80005748:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    8000574a:	e0043783          	ld	a5,-512(s0)
    8000574e:	6388                	ld	a0,0(a5)
  sp = sz;
    80005750:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005752:	4481                	li	s1,0
    ustack[argc] = sp;
    80005754:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005758:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000575c:	c135                	beqz	a0,800057c0 <exec+0x2cc>
    sp -= strlen(argv[argc]) + 1;
    8000575e:	ffffb097          	auipc	ra,0xffffb
    80005762:	764080e7          	jalr	1892(ra) # 80000ec2 <strlen>
    80005766:	0015079b          	addiw	a5,a0,1
    8000576a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000576e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005772:	15796163          	bltu	s2,s7,800058b4 <exec+0x3c0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005776:	e0043d83          	ld	s11,-512(s0)
    8000577a:	000db983          	ld	s3,0(s11)
    8000577e:	854e                	mv	a0,s3
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	742080e7          	jalr	1858(ra) # 80000ec2 <strlen>
    80005788:	0015069b          	addiw	a3,a0,1
    8000578c:	864e                	mv	a2,s3
    8000578e:	85ca                	mv	a1,s2
    80005790:	855a                	mv	a0,s6
    80005792:	ffffc097          	auipc	ra,0xffffc
    80005796:	f7e080e7          	jalr	-130(ra) # 80001710 <copyout>
    8000579a:	10054f63          	bltz	a0,800058b8 <exec+0x3c4>
    ustack[argc] = sp;
    8000579e:	00349793          	slli	a5,s1,0x3
    800057a2:	97e6                	add	a5,a5,s9
    800057a4:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd4fe0>
  for(argc = 0; argv[argc]; argc++) {
    800057a8:	0485                	addi	s1,s1,1
    800057aa:	008d8793          	addi	a5,s11,8
    800057ae:	e0f43023          	sd	a5,-512(s0)
    800057b2:	008db503          	ld	a0,8(s11)
    800057b6:	c509                	beqz	a0,800057c0 <exec+0x2cc>
    if(argc >= MAXARG)
    800057b8:	fb8493e3          	bne	s1,s8,8000575e <exec+0x26a>
  sz = sz1;
    800057bc:	89d2                	mv	s3,s4
    800057be:	bfa1                	j	80005716 <exec+0x222>
  ustack[argc] = 0;
    800057c0:	00349793          	slli	a5,s1,0x3
    800057c4:	f9078793          	addi	a5,a5,-112
    800057c8:	97a2                	add	a5,a5,s0
    800057ca:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800057ce:	00148693          	addi	a3,s1,1
    800057d2:	068e                	slli	a3,a3,0x3
    800057d4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057d8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800057dc:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800057de:	f3796ce3          	bltu	s2,s7,80005716 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057e2:	e9040613          	addi	a2,s0,-368
    800057e6:	85ca                	mv	a1,s2
    800057e8:	855a                	mv	a0,s6
    800057ea:	ffffc097          	auipc	ra,0xffffc
    800057ee:	f26080e7          	jalr	-218(ra) # 80001710 <copyout>
    800057f2:	f20542e3          	bltz	a0,80005716 <exec+0x222>
  p->trapframe->a1 = sp;
    800057f6:	230ab783          	ld	a5,560(s5) # 1230 <_entry-0x7fffedd0>
    800057fa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800057fe:	df043783          	ld	a5,-528(s0)
    80005802:	0007c703          	lbu	a4,0(a5)
    80005806:	cf11                	beqz	a4,80005822 <exec+0x32e>
    80005808:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000580a:	02f00693          	li	a3,47
    8000580e:	a029                	j	80005818 <exec+0x324>
  for(last=s=path; *s; s++)
    80005810:	0785                	addi	a5,a5,1
    80005812:	fff7c703          	lbu	a4,-1(a5)
    80005816:	c711                	beqz	a4,80005822 <exec+0x32e>
    if(*s == '/')
    80005818:	fed71ce3          	bne	a4,a3,80005810 <exec+0x31c>
      last = s+1;
    8000581c:	def43823          	sd	a5,-528(s0)
    80005820:	bfc5                	j	80005810 <exec+0x31c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005822:	4641                	li	a2,16
    80005824:	df043583          	ld	a1,-528(s0)
    80005828:	330a8513          	addi	a0,s5,816
    8000582c:	ffffb097          	auipc	ra,0xffffb
    80005830:	660080e7          	jalr	1632(ra) # 80000e8c <safestrcpy>
  oldpagetable = p->pagetable;
    80005834:	228ab503          	ld	a0,552(s5)
  p->pagetable = pagetable;
    80005838:	236ab423          	sd	s6,552(s5)
  p->sz = sz;
    8000583c:	234ab023          	sd	s4,544(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005840:	230ab783          	ld	a5,560(s5)
    80005844:	e6843703          	ld	a4,-408(s0)
    80005848:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000584a:	230ab783          	ld	a5,560(s5)
    8000584e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005852:	85ea                	mv	a1,s10
    80005854:	ffffc097          	auipc	ra,0xffffc
    80005858:	3bc080e7          	jalr	956(ra) # 80001c10 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000585c:	0004851b          	sext.w	a0,s1
    80005860:	79fe                	ld	s3,504(sp)
    80005862:	7a5e                	ld	s4,496(sp)
    80005864:	7abe                	ld	s5,488(sp)
    80005866:	7b1e                	ld	s6,480(sp)
    80005868:	6bfe                	ld	s7,472(sp)
    8000586a:	6c5e                	ld	s8,464(sp)
    8000586c:	6cbe                	ld	s9,456(sp)
    8000586e:	6d1e                	ld	s10,448(sp)
    80005870:	7dfa                	ld	s11,440(sp)
    80005872:	bb01                	j	80005582 <exec+0x8e>
    80005874:	7b1e                	ld	s6,480(sp)
    80005876:	b9dd                	j	8000556c <exec+0x78>
    80005878:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000587c:	df843583          	ld	a1,-520(s0)
    80005880:	855a                	mv	a0,s6
    80005882:	ffffc097          	auipc	ra,0xffffc
    80005886:	38e080e7          	jalr	910(ra) # 80001c10 <proc_freepagetable>
  if(ip){
    8000588a:	79fe                	ld	s3,504(sp)
    8000588c:	7abe                	ld	s5,488(sp)
    8000588e:	7b1e                	ld	s6,480(sp)
    80005890:	6bfe                	ld	s7,472(sp)
    80005892:	6c5e                	ld	s8,464(sp)
    80005894:	6cbe                	ld	s9,456(sp)
    80005896:	6d1e                	ld	s10,448(sp)
    80005898:	7dfa                	ld	s11,440(sp)
    8000589a:	b9c9                	j	8000556c <exec+0x78>
    8000589c:	df243c23          	sd	s2,-520(s0)
    800058a0:	bff1                	j	8000587c <exec+0x388>
    800058a2:	df243c23          	sd	s2,-520(s0)
    800058a6:	bfd9                	j	8000587c <exec+0x388>
    800058a8:	df243c23          	sd	s2,-520(s0)
    800058ac:	bfc1                	j	8000587c <exec+0x388>
    800058ae:	df243c23          	sd	s2,-520(s0)
    800058b2:	b7e9                	j	8000587c <exec+0x388>
  sz = sz1;
    800058b4:	89d2                	mv	s3,s4
    800058b6:	b585                	j	80005716 <exec+0x222>
    800058b8:	89d2                	mv	s3,s4
    800058ba:	bdb1                	j	80005716 <exec+0x222>

00000000800058bc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800058bc:	7179                	addi	sp,sp,-48
    800058be:	f406                	sd	ra,40(sp)
    800058c0:	f022                	sd	s0,32(sp)
    800058c2:	ec26                	sd	s1,24(sp)
    800058c4:	e84a                	sd	s2,16(sp)
    800058c6:	1800                	addi	s0,sp,48
    800058c8:	892e                	mv	s2,a1
    800058ca:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800058cc:	fdc40593          	addi	a1,s0,-36
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	946080e7          	jalr	-1722(ra) # 80003216 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800058d8:	fdc42703          	lw	a4,-36(s0)
    800058dc:	47bd                	li	a5,15
    800058de:	02e7eb63          	bltu	a5,a4,80005914 <argfd+0x58>
    800058e2:	ffffc097          	auipc	ra,0xffffc
    800058e6:	1ce080e7          	jalr	462(ra) # 80001ab0 <myproc>
    800058ea:	fdc42703          	lw	a4,-36(s0)
    800058ee:	05470793          	addi	a5,a4,84
    800058f2:	078e                	slli	a5,a5,0x3
    800058f4:	953e                	add	a0,a0,a5
    800058f6:	651c                	ld	a5,8(a0)
    800058f8:	c385                	beqz	a5,80005918 <argfd+0x5c>
    return -1;
  if(pfd)
    800058fa:	00090463          	beqz	s2,80005902 <argfd+0x46>
    *pfd = fd;
    800058fe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005902:	4501                	li	a0,0
  if(pf)
    80005904:	c091                	beqz	s1,80005908 <argfd+0x4c>
    *pf = f;
    80005906:	e09c                	sd	a5,0(s1)
}
    80005908:	70a2                	ld	ra,40(sp)
    8000590a:	7402                	ld	s0,32(sp)
    8000590c:	64e2                	ld	s1,24(sp)
    8000590e:	6942                	ld	s2,16(sp)
    80005910:	6145                	addi	sp,sp,48
    80005912:	8082                	ret
    return -1;
    80005914:	557d                	li	a0,-1
    80005916:	bfcd                	j	80005908 <argfd+0x4c>
    80005918:	557d                	li	a0,-1
    8000591a:	b7fd                	j	80005908 <argfd+0x4c>

000000008000591c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000591c:	1101                	addi	sp,sp,-32
    8000591e:	ec06                	sd	ra,24(sp)
    80005920:	e822                	sd	s0,16(sp)
    80005922:	e426                	sd	s1,8(sp)
    80005924:	1000                	addi	s0,sp,32
    80005926:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005928:	ffffc097          	auipc	ra,0xffffc
    8000592c:	188080e7          	jalr	392(ra) # 80001ab0 <myproc>
    80005930:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005932:	2a850793          	addi	a5,a0,680
    80005936:	4501                	li	a0,0
    80005938:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000593a:	6398                	ld	a4,0(a5)
    8000593c:	cb19                	beqz	a4,80005952 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000593e:	2505                	addiw	a0,a0,1
    80005940:	07a1                	addi	a5,a5,8
    80005942:	fed51ce3          	bne	a0,a3,8000593a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005946:	557d                	li	a0,-1
}
    80005948:	60e2                	ld	ra,24(sp)
    8000594a:	6442                	ld	s0,16(sp)
    8000594c:	64a2                	ld	s1,8(sp)
    8000594e:	6105                	addi	sp,sp,32
    80005950:	8082                	ret
      p->ofile[fd] = f;
    80005952:	05450793          	addi	a5,a0,84
    80005956:	078e                	slli	a5,a5,0x3
    80005958:	963e                	add	a2,a2,a5
    8000595a:	e604                	sd	s1,8(a2)
      return fd;
    8000595c:	b7f5                	j	80005948 <fdalloc+0x2c>

000000008000595e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000595e:	715d                	addi	sp,sp,-80
    80005960:	e486                	sd	ra,72(sp)
    80005962:	e0a2                	sd	s0,64(sp)
    80005964:	fc26                	sd	s1,56(sp)
    80005966:	f84a                	sd	s2,48(sp)
    80005968:	f44e                	sd	s3,40(sp)
    8000596a:	ec56                	sd	s5,24(sp)
    8000596c:	e85a                	sd	s6,16(sp)
    8000596e:	0880                	addi	s0,sp,80
    80005970:	8b2e                	mv	s6,a1
    80005972:	89b2                	mv	s3,a2
    80005974:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005976:	fb040593          	addi	a1,s0,-80
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	db8080e7          	jalr	-584(ra) # 80004732 <nameiparent>
    80005982:	84aa                	mv	s1,a0
    80005984:	14050e63          	beqz	a0,80005ae0 <create+0x182>
    return 0;

  ilock(dp);
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	5a8080e7          	jalr	1448(ra) # 80003f30 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005990:	4601                	li	a2,0
    80005992:	fb040593          	addi	a1,s0,-80
    80005996:	8526                	mv	a0,s1
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	a94080e7          	jalr	-1388(ra) # 8000442c <dirlookup>
    800059a0:	8aaa                	mv	s5,a0
    800059a2:	c539                	beqz	a0,800059f0 <create+0x92>
    iunlockput(dp);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	7f0080e7          	jalr	2032(ra) # 80004196 <iunlockput>
    ilock(ip);
    800059ae:	8556                	mv	a0,s5
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	580080e7          	jalr	1408(ra) # 80003f30 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800059b8:	4789                	li	a5,2
    800059ba:	02fb1463          	bne	s6,a5,800059e2 <create+0x84>
    800059be:	044ad783          	lhu	a5,68(s5)
    800059c2:	37f9                	addiw	a5,a5,-2
    800059c4:	17c2                	slli	a5,a5,0x30
    800059c6:	93c1                	srli	a5,a5,0x30
    800059c8:	4705                	li	a4,1
    800059ca:	00f76c63          	bltu	a4,a5,800059e2 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800059ce:	8556                	mv	a0,s5
    800059d0:	60a6                	ld	ra,72(sp)
    800059d2:	6406                	ld	s0,64(sp)
    800059d4:	74e2                	ld	s1,56(sp)
    800059d6:	7942                	ld	s2,48(sp)
    800059d8:	79a2                	ld	s3,40(sp)
    800059da:	6ae2                	ld	s5,24(sp)
    800059dc:	6b42                	ld	s6,16(sp)
    800059de:	6161                	addi	sp,sp,80
    800059e0:	8082                	ret
    iunlockput(ip);
    800059e2:	8556                	mv	a0,s5
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	7b2080e7          	jalr	1970(ra) # 80004196 <iunlockput>
    return 0;
    800059ec:	4a81                	li	s5,0
    800059ee:	b7c5                	j	800059ce <create+0x70>
    800059f0:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800059f2:	85da                	mv	a1,s6
    800059f4:	4088                	lw	a0,0(s1)
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	396080e7          	jalr	918(ra) # 80003d8c <ialloc>
    800059fe:	8a2a                	mv	s4,a0
    80005a00:	c531                	beqz	a0,80005a4c <create+0xee>
  ilock(ip);
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	52e080e7          	jalr	1326(ra) # 80003f30 <ilock>
  ip->major = major;
    80005a0a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005a0e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005a12:	4905                	li	s2,1
    80005a14:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005a18:	8552                	mv	a0,s4
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	44a080e7          	jalr	1098(ra) # 80003e64 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a22:	032b0d63          	beq	s6,s2,80005a5c <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a26:	004a2603          	lw	a2,4(s4)
    80005a2a:	fb040593          	addi	a1,s0,-80
    80005a2e:	8526                	mv	a0,s1
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	c22080e7          	jalr	-990(ra) # 80004652 <dirlink>
    80005a38:	08054163          	bltz	a0,80005aba <create+0x15c>
  iunlockput(dp);
    80005a3c:	8526                	mv	a0,s1
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	758080e7          	jalr	1880(ra) # 80004196 <iunlockput>
  return ip;
    80005a46:	8ad2                	mv	s5,s4
    80005a48:	7a02                	ld	s4,32(sp)
    80005a4a:	b751                	j	800059ce <create+0x70>
    iunlockput(dp);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	748080e7          	jalr	1864(ra) # 80004196 <iunlockput>
    return 0;
    80005a56:	8ad2                	mv	s5,s4
    80005a58:	7a02                	ld	s4,32(sp)
    80005a5a:	bf95                	j	800059ce <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a5c:	004a2603          	lw	a2,4(s4)
    80005a60:	00003597          	auipc	a1,0x3
    80005a64:	c1058593          	addi	a1,a1,-1008 # 80008670 <etext+0x670>
    80005a68:	8552                	mv	a0,s4
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	be8080e7          	jalr	-1048(ra) # 80004652 <dirlink>
    80005a72:	04054463          	bltz	a0,80005aba <create+0x15c>
    80005a76:	40d0                	lw	a2,4(s1)
    80005a78:	00003597          	auipc	a1,0x3
    80005a7c:	c0058593          	addi	a1,a1,-1024 # 80008678 <etext+0x678>
    80005a80:	8552                	mv	a0,s4
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	bd0080e7          	jalr	-1072(ra) # 80004652 <dirlink>
    80005a8a:	02054863          	bltz	a0,80005aba <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a8e:	004a2603          	lw	a2,4(s4)
    80005a92:	fb040593          	addi	a1,s0,-80
    80005a96:	8526                	mv	a0,s1
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	bba080e7          	jalr	-1094(ra) # 80004652 <dirlink>
    80005aa0:	00054d63          	bltz	a0,80005aba <create+0x15c>
    dp->nlink++;  // for ".."
    80005aa4:	04a4d783          	lhu	a5,74(s1)
    80005aa8:	2785                	addiw	a5,a5,1
    80005aaa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	3b4080e7          	jalr	948(ra) # 80003e64 <iupdate>
    80005ab8:	b751                	j	80005a3c <create+0xde>
  ip->nlink = 0;
    80005aba:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005abe:	8552                	mv	a0,s4
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	3a4080e7          	jalr	932(ra) # 80003e64 <iupdate>
  iunlockput(ip);
    80005ac8:	8552                	mv	a0,s4
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	6cc080e7          	jalr	1740(ra) # 80004196 <iunlockput>
  iunlockput(dp);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	6c2080e7          	jalr	1730(ra) # 80004196 <iunlockput>
  return 0;
    80005adc:	7a02                	ld	s4,32(sp)
    80005ade:	bdc5                	j	800059ce <create+0x70>
    return 0;
    80005ae0:	8aaa                	mv	s5,a0
    80005ae2:	b5f5                	j	800059ce <create+0x70>

0000000080005ae4 <sys_dup>:
{
    80005ae4:	7179                	addi	sp,sp,-48
    80005ae6:	f406                	sd	ra,40(sp)
    80005ae8:	f022                	sd	s0,32(sp)
    80005aea:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005aec:	fd840613          	addi	a2,s0,-40
    80005af0:	4581                	li	a1,0
    80005af2:	4501                	li	a0,0
    80005af4:	00000097          	auipc	ra,0x0
    80005af8:	dc8080e7          	jalr	-568(ra) # 800058bc <argfd>
    return -1;
    80005afc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005afe:	02054763          	bltz	a0,80005b2c <sys_dup+0x48>
    80005b02:	ec26                	sd	s1,24(sp)
    80005b04:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005b06:	fd843903          	ld	s2,-40(s0)
    80005b0a:	854a                	mv	a0,s2
    80005b0c:	00000097          	auipc	ra,0x0
    80005b10:	e10080e7          	jalr	-496(ra) # 8000591c <fdalloc>
    80005b14:	84aa                	mv	s1,a0
    return -1;
    80005b16:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b18:	00054f63          	bltz	a0,80005b36 <sys_dup+0x52>
  filedup(f);
    80005b1c:	854a                	mv	a0,s2
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	27a080e7          	jalr	634(ra) # 80004d98 <filedup>
  return fd;
    80005b26:	87a6                	mv	a5,s1
    80005b28:	64e2                	ld	s1,24(sp)
    80005b2a:	6942                	ld	s2,16(sp)
}
    80005b2c:	853e                	mv	a0,a5
    80005b2e:	70a2                	ld	ra,40(sp)
    80005b30:	7402                	ld	s0,32(sp)
    80005b32:	6145                	addi	sp,sp,48
    80005b34:	8082                	ret
    80005b36:	64e2                	ld	s1,24(sp)
    80005b38:	6942                	ld	s2,16(sp)
    80005b3a:	bfcd                	j	80005b2c <sys_dup+0x48>

0000000080005b3c <sys_read>:
{
    80005b3c:	7179                	addi	sp,sp,-48
    80005b3e:	f406                	sd	ra,40(sp)
    80005b40:	f022                	sd	s0,32(sp)
    80005b42:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b44:	fd840593          	addi	a1,s0,-40
    80005b48:	4505                	li	a0,1
    80005b4a:	ffffd097          	auipc	ra,0xffffd
    80005b4e:	6ec080e7          	jalr	1772(ra) # 80003236 <argaddr>
  argint(2, &n);
    80005b52:	fe440593          	addi	a1,s0,-28
    80005b56:	4509                	li	a0,2
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	6be080e7          	jalr	1726(ra) # 80003216 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b60:	fe840613          	addi	a2,s0,-24
    80005b64:	4581                	li	a1,0
    80005b66:	4501                	li	a0,0
    80005b68:	00000097          	auipc	ra,0x0
    80005b6c:	d54080e7          	jalr	-684(ra) # 800058bc <argfd>
    80005b70:	87aa                	mv	a5,a0
    return -1;
    80005b72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b74:	0007cc63          	bltz	a5,80005b8c <sys_read+0x50>
  return fileread(f, p, n);
    80005b78:	fe442603          	lw	a2,-28(s0)
    80005b7c:	fd843583          	ld	a1,-40(s0)
    80005b80:	fe843503          	ld	a0,-24(s0)
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	3ba080e7          	jalr	954(ra) # 80004f3e <fileread>
}
    80005b8c:	70a2                	ld	ra,40(sp)
    80005b8e:	7402                	ld	s0,32(sp)
    80005b90:	6145                	addi	sp,sp,48
    80005b92:	8082                	ret

0000000080005b94 <sys_write>:
{
    80005b94:	7179                	addi	sp,sp,-48
    80005b96:	f406                	sd	ra,40(sp)
    80005b98:	f022                	sd	s0,32(sp)
    80005b9a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b9c:	fd840593          	addi	a1,s0,-40
    80005ba0:	4505                	li	a0,1
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	694080e7          	jalr	1684(ra) # 80003236 <argaddr>
  argint(2, &n);
    80005baa:	fe440593          	addi	a1,s0,-28
    80005bae:	4509                	li	a0,2
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	666080e7          	jalr	1638(ra) # 80003216 <argint>
  if(argfd(0, 0, &f) < 0)
    80005bb8:	fe840613          	addi	a2,s0,-24
    80005bbc:	4581                	li	a1,0
    80005bbe:	4501                	li	a0,0
    80005bc0:	00000097          	auipc	ra,0x0
    80005bc4:	cfc080e7          	jalr	-772(ra) # 800058bc <argfd>
    80005bc8:	87aa                	mv	a5,a0
    return -1;
    80005bca:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bcc:	0007cc63          	bltz	a5,80005be4 <sys_write+0x50>
  return filewrite(f, p, n);
    80005bd0:	fe442603          	lw	a2,-28(s0)
    80005bd4:	fd843583          	ld	a1,-40(s0)
    80005bd8:	fe843503          	ld	a0,-24(s0)
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	434080e7          	jalr	1076(ra) # 80005010 <filewrite>
}
    80005be4:	70a2                	ld	ra,40(sp)
    80005be6:	7402                	ld	s0,32(sp)
    80005be8:	6145                	addi	sp,sp,48
    80005bea:	8082                	ret

0000000080005bec <sys_close>:
{
    80005bec:	1101                	addi	sp,sp,-32
    80005bee:	ec06                	sd	ra,24(sp)
    80005bf0:	e822                	sd	s0,16(sp)
    80005bf2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005bf4:	fe040613          	addi	a2,s0,-32
    80005bf8:	fec40593          	addi	a1,s0,-20
    80005bfc:	4501                	li	a0,0
    80005bfe:	00000097          	auipc	ra,0x0
    80005c02:	cbe080e7          	jalr	-834(ra) # 800058bc <argfd>
    return -1;
    80005c06:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005c08:	02054563          	bltz	a0,80005c32 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005c0c:	ffffc097          	auipc	ra,0xffffc
    80005c10:	ea4080e7          	jalr	-348(ra) # 80001ab0 <myproc>
    80005c14:	fec42783          	lw	a5,-20(s0)
    80005c18:	05478793          	addi	a5,a5,84
    80005c1c:	078e                	slli	a5,a5,0x3
    80005c1e:	953e                	add	a0,a0,a5
    80005c20:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005c24:	fe043503          	ld	a0,-32(s0)
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	1c2080e7          	jalr	450(ra) # 80004dea <fileclose>
  return 0;
    80005c30:	4781                	li	a5,0
}
    80005c32:	853e                	mv	a0,a5
    80005c34:	60e2                	ld	ra,24(sp)
    80005c36:	6442                	ld	s0,16(sp)
    80005c38:	6105                	addi	sp,sp,32
    80005c3a:	8082                	ret

0000000080005c3c <sys_fstat>:
{
    80005c3c:	1101                	addi	sp,sp,-32
    80005c3e:	ec06                	sd	ra,24(sp)
    80005c40:	e822                	sd	s0,16(sp)
    80005c42:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c44:	fe040593          	addi	a1,s0,-32
    80005c48:	4505                	li	a0,1
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	5ec080e7          	jalr	1516(ra) # 80003236 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c52:	fe840613          	addi	a2,s0,-24
    80005c56:	4581                	li	a1,0
    80005c58:	4501                	li	a0,0
    80005c5a:	00000097          	auipc	ra,0x0
    80005c5e:	c62080e7          	jalr	-926(ra) # 800058bc <argfd>
    80005c62:	87aa                	mv	a5,a0
    return -1;
    80005c64:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c66:	0007ca63          	bltz	a5,80005c7a <sys_fstat+0x3e>
  return filestat(f, st);
    80005c6a:	fe043583          	ld	a1,-32(s0)
    80005c6e:	fe843503          	ld	a0,-24(s0)
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	256080e7          	jalr	598(ra) # 80004ec8 <filestat>
}
    80005c7a:	60e2                	ld	ra,24(sp)
    80005c7c:	6442                	ld	s0,16(sp)
    80005c7e:	6105                	addi	sp,sp,32
    80005c80:	8082                	ret

0000000080005c82 <sys_link>:
{
    80005c82:	7169                	addi	sp,sp,-304
    80005c84:	f606                	sd	ra,296(sp)
    80005c86:	f222                	sd	s0,288(sp)
    80005c88:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c8a:	08000613          	li	a2,128
    80005c8e:	ed040593          	addi	a1,s0,-304
    80005c92:	4501                	li	a0,0
    80005c94:	ffffd097          	auipc	ra,0xffffd
    80005c98:	5c2080e7          	jalr	1474(ra) # 80003256 <argstr>
    return -1;
    80005c9c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c9e:	12054663          	bltz	a0,80005dca <sys_link+0x148>
    80005ca2:	08000613          	li	a2,128
    80005ca6:	f5040593          	addi	a1,s0,-176
    80005caa:	4505                	li	a0,1
    80005cac:	ffffd097          	auipc	ra,0xffffd
    80005cb0:	5aa080e7          	jalr	1450(ra) # 80003256 <argstr>
    return -1;
    80005cb4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cb6:	10054a63          	bltz	a0,80005dca <sys_link+0x148>
    80005cba:	ee26                	sd	s1,280(sp)
  begin_op();
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	c5e080e7          	jalr	-930(ra) # 8000491a <begin_op>
  if((ip = namei(old)) == 0){
    80005cc4:	ed040513          	addi	a0,s0,-304
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	a4c080e7          	jalr	-1460(ra) # 80004714 <namei>
    80005cd0:	84aa                	mv	s1,a0
    80005cd2:	c949                	beqz	a0,80005d64 <sys_link+0xe2>
  ilock(ip);
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	25c080e7          	jalr	604(ra) # 80003f30 <ilock>
  if(ip->type == T_DIR){
    80005cdc:	04449703          	lh	a4,68(s1)
    80005ce0:	4785                	li	a5,1
    80005ce2:	08f70863          	beq	a4,a5,80005d72 <sys_link+0xf0>
    80005ce6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005ce8:	04a4d783          	lhu	a5,74(s1)
    80005cec:	2785                	addiw	a5,a5,1
    80005cee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	170080e7          	jalr	368(ra) # 80003e64 <iupdate>
  iunlock(ip);
    80005cfc:	8526                	mv	a0,s1
    80005cfe:	ffffe097          	auipc	ra,0xffffe
    80005d02:	2f8080e7          	jalr	760(ra) # 80003ff6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005d06:	fd040593          	addi	a1,s0,-48
    80005d0a:	f5040513          	addi	a0,s0,-176
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	a24080e7          	jalr	-1500(ra) # 80004732 <nameiparent>
    80005d16:	892a                	mv	s2,a0
    80005d18:	cd35                	beqz	a0,80005d94 <sys_link+0x112>
  ilock(dp);
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	216080e7          	jalr	534(ra) # 80003f30 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d22:	00092703          	lw	a4,0(s2)
    80005d26:	409c                	lw	a5,0(s1)
    80005d28:	06f71163          	bne	a4,a5,80005d8a <sys_link+0x108>
    80005d2c:	40d0                	lw	a2,4(s1)
    80005d2e:	fd040593          	addi	a1,s0,-48
    80005d32:	854a                	mv	a0,s2
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	91e080e7          	jalr	-1762(ra) # 80004652 <dirlink>
    80005d3c:	04054763          	bltz	a0,80005d8a <sys_link+0x108>
  iunlockput(dp);
    80005d40:	854a                	mv	a0,s2
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	454080e7          	jalr	1108(ra) # 80004196 <iunlockput>
  iput(ip);
    80005d4a:	8526                	mv	a0,s1
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	3a2080e7          	jalr	930(ra) # 800040ee <iput>
  end_op();
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	c40080e7          	jalr	-960(ra) # 80004994 <end_op>
  return 0;
    80005d5c:	4781                	li	a5,0
    80005d5e:	64f2                	ld	s1,280(sp)
    80005d60:	6952                	ld	s2,272(sp)
    80005d62:	a0a5                	j	80005dca <sys_link+0x148>
    end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	c30080e7          	jalr	-976(ra) # 80004994 <end_op>
    return -1;
    80005d6c:	57fd                	li	a5,-1
    80005d6e:	64f2                	ld	s1,280(sp)
    80005d70:	a8a9                	j	80005dca <sys_link+0x148>
    iunlockput(ip);
    80005d72:	8526                	mv	a0,s1
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	422080e7          	jalr	1058(ra) # 80004196 <iunlockput>
    end_op();
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	c18080e7          	jalr	-1000(ra) # 80004994 <end_op>
    return -1;
    80005d84:	57fd                	li	a5,-1
    80005d86:	64f2                	ld	s1,280(sp)
    80005d88:	a089                	j	80005dca <sys_link+0x148>
    iunlockput(dp);
    80005d8a:	854a                	mv	a0,s2
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	40a080e7          	jalr	1034(ra) # 80004196 <iunlockput>
  ilock(ip);
    80005d94:	8526                	mv	a0,s1
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	19a080e7          	jalr	410(ra) # 80003f30 <ilock>
  ip->nlink--;
    80005d9e:	04a4d783          	lhu	a5,74(s1)
    80005da2:	37fd                	addiw	a5,a5,-1
    80005da4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005da8:	8526                	mv	a0,s1
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	0ba080e7          	jalr	186(ra) # 80003e64 <iupdate>
  iunlockput(ip);
    80005db2:	8526                	mv	a0,s1
    80005db4:	ffffe097          	auipc	ra,0xffffe
    80005db8:	3e2080e7          	jalr	994(ra) # 80004196 <iunlockput>
  end_op();
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	bd8080e7          	jalr	-1064(ra) # 80004994 <end_op>
  return -1;
    80005dc4:	57fd                	li	a5,-1
    80005dc6:	64f2                	ld	s1,280(sp)
    80005dc8:	6952                	ld	s2,272(sp)
}
    80005dca:	853e                	mv	a0,a5
    80005dcc:	70b2                	ld	ra,296(sp)
    80005dce:	7412                	ld	s0,288(sp)
    80005dd0:	6155                	addi	sp,sp,304
    80005dd2:	8082                	ret

0000000080005dd4 <sys_unlink>:
{
    80005dd4:	7111                	addi	sp,sp,-256
    80005dd6:	fd86                	sd	ra,248(sp)
    80005dd8:	f9a2                	sd	s0,240(sp)
    80005dda:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80005ddc:	08000613          	li	a2,128
    80005de0:	f2040593          	addi	a1,s0,-224
    80005de4:	4501                	li	a0,0
    80005de6:	ffffd097          	auipc	ra,0xffffd
    80005dea:	470080e7          	jalr	1136(ra) # 80003256 <argstr>
    80005dee:	1c054063          	bltz	a0,80005fae <sys_unlink+0x1da>
    80005df2:	f5a6                	sd	s1,232(sp)
  begin_op();
    80005df4:	fffff097          	auipc	ra,0xfffff
    80005df8:	b26080e7          	jalr	-1242(ra) # 8000491a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005dfc:	fa040593          	addi	a1,s0,-96
    80005e00:	f2040513          	addi	a0,s0,-224
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	92e080e7          	jalr	-1746(ra) # 80004732 <nameiparent>
    80005e0c:	84aa                	mv	s1,a0
    80005e0e:	c165                	beqz	a0,80005eee <sys_unlink+0x11a>
  ilock(dp);
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	120080e7          	jalr	288(ra) # 80003f30 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005e18:	00003597          	auipc	a1,0x3
    80005e1c:	85858593          	addi	a1,a1,-1960 # 80008670 <etext+0x670>
    80005e20:	fa040513          	addi	a0,s0,-96
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	5ee080e7          	jalr	1518(ra) # 80004412 <namecmp>
    80005e2c:	16050263          	beqz	a0,80005f90 <sys_unlink+0x1bc>
    80005e30:	00003597          	auipc	a1,0x3
    80005e34:	84858593          	addi	a1,a1,-1976 # 80008678 <etext+0x678>
    80005e38:	fa040513          	addi	a0,s0,-96
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	5d6080e7          	jalr	1494(ra) # 80004412 <namecmp>
    80005e44:	14050663          	beqz	a0,80005f90 <sys_unlink+0x1bc>
    80005e48:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e4a:	f1c40613          	addi	a2,s0,-228
    80005e4e:	fa040593          	addi	a1,s0,-96
    80005e52:	8526                	mv	a0,s1
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	5d8080e7          	jalr	1496(ra) # 8000442c <dirlookup>
    80005e5c:	892a                	mv	s2,a0
    80005e5e:	12050863          	beqz	a0,80005f8e <sys_unlink+0x1ba>
    80005e62:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	0cc080e7          	jalr	204(ra) # 80003f30 <ilock>
  if(ip->nlink < 1)
    80005e6c:	04a91783          	lh	a5,74(s2)
    80005e70:	08f05663          	blez	a5,80005efc <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e74:	04491703          	lh	a4,68(s2)
    80005e78:	4785                	li	a5,1
    80005e7a:	08f70b63          	beq	a4,a5,80005f10 <sys_unlink+0x13c>
  memset(&de, 0, sizeof(de));
    80005e7e:	fb040993          	addi	s3,s0,-80
    80005e82:	4641                	li	a2,16
    80005e84:	4581                	li	a1,0
    80005e86:	854e                	mv	a0,s3
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	eae080e7          	jalr	-338(ra) # 80000d36 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e90:	4741                	li	a4,16
    80005e92:	f1c42683          	lw	a3,-228(s0)
    80005e96:	864e                	mv	a2,s3
    80005e98:	4581                	li	a1,0
    80005e9a:	8526                	mv	a0,s1
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	456080e7          	jalr	1110(ra) # 800042f2 <writei>
    80005ea4:	47c1                	li	a5,16
    80005ea6:	0af51f63          	bne	a0,a5,80005f64 <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80005eaa:	04491703          	lh	a4,68(s2)
    80005eae:	4785                	li	a5,1
    80005eb0:	0cf70463          	beq	a4,a5,80005f78 <sys_unlink+0x1a4>
  iunlockput(dp);
    80005eb4:	8526                	mv	a0,s1
    80005eb6:	ffffe097          	auipc	ra,0xffffe
    80005eba:	2e0080e7          	jalr	736(ra) # 80004196 <iunlockput>
  ip->nlink--;
    80005ebe:	04a95783          	lhu	a5,74(s2)
    80005ec2:	37fd                	addiw	a5,a5,-1
    80005ec4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ec8:	854a                	mv	a0,s2
    80005eca:	ffffe097          	auipc	ra,0xffffe
    80005ece:	f9a080e7          	jalr	-102(ra) # 80003e64 <iupdate>
  iunlockput(ip);
    80005ed2:	854a                	mv	a0,s2
    80005ed4:	ffffe097          	auipc	ra,0xffffe
    80005ed8:	2c2080e7          	jalr	706(ra) # 80004196 <iunlockput>
  end_op();
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	ab8080e7          	jalr	-1352(ra) # 80004994 <end_op>
  return 0;
    80005ee4:	4501                	li	a0,0
    80005ee6:	74ae                	ld	s1,232(sp)
    80005ee8:	790e                	ld	s2,224(sp)
    80005eea:	69ee                	ld	s3,216(sp)
    80005eec:	a86d                	j	80005fa6 <sys_unlink+0x1d2>
    end_op();
    80005eee:	fffff097          	auipc	ra,0xfffff
    80005ef2:	aa6080e7          	jalr	-1370(ra) # 80004994 <end_op>
    return -1;
    80005ef6:	557d                	li	a0,-1
    80005ef8:	74ae                	ld	s1,232(sp)
    80005efa:	a075                	j	80005fa6 <sys_unlink+0x1d2>
    80005efc:	e9d2                	sd	s4,208(sp)
    80005efe:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80005f00:	00002517          	auipc	a0,0x2
    80005f04:	78050513          	addi	a0,a0,1920 # 80008680 <etext+0x680>
    80005f08:	ffffa097          	auipc	ra,0xffffa
    80005f0c:	658080e7          	jalr	1624(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f10:	04c92703          	lw	a4,76(s2)
    80005f14:	02000793          	li	a5,32
    80005f18:	f6e7f3e3          	bgeu	a5,a4,80005e7e <sys_unlink+0xaa>
    80005f1c:	e9d2                	sd	s4,208(sp)
    80005f1e:	e5d6                	sd	s5,200(sp)
    80005f20:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f22:	f0840a93          	addi	s5,s0,-248
    80005f26:	4a41                	li	s4,16
    80005f28:	8752                	mv	a4,s4
    80005f2a:	86ce                	mv	a3,s3
    80005f2c:	8656                	mv	a2,s5
    80005f2e:	4581                	li	a1,0
    80005f30:	854a                	mv	a0,s2
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	2ba080e7          	jalr	698(ra) # 800041ec <readi>
    80005f3a:	01451d63          	bne	a0,s4,80005f54 <sys_unlink+0x180>
    if(de.inum != 0)
    80005f3e:	f0845783          	lhu	a5,-248(s0)
    80005f42:	eba5                	bnez	a5,80005fb2 <sys_unlink+0x1de>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f44:	29c1                	addiw	s3,s3,16
    80005f46:	04c92783          	lw	a5,76(s2)
    80005f4a:	fcf9efe3          	bltu	s3,a5,80005f28 <sys_unlink+0x154>
    80005f4e:	6a4e                	ld	s4,208(sp)
    80005f50:	6aae                	ld	s5,200(sp)
    80005f52:	b735                	j	80005e7e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005f54:	00002517          	auipc	a0,0x2
    80005f58:	74450513          	addi	a0,a0,1860 # 80008698 <etext+0x698>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	604080e7          	jalr	1540(ra) # 80000560 <panic>
    80005f64:	e9d2                	sd	s4,208(sp)
    80005f66:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80005f68:	00002517          	auipc	a0,0x2
    80005f6c:	74850513          	addi	a0,a0,1864 # 800086b0 <etext+0x6b0>
    80005f70:	ffffa097          	auipc	ra,0xffffa
    80005f74:	5f0080e7          	jalr	1520(ra) # 80000560 <panic>
    dp->nlink--;
    80005f78:	04a4d783          	lhu	a5,74(s1)
    80005f7c:	37fd                	addiw	a5,a5,-1
    80005f7e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f82:	8526                	mv	a0,s1
    80005f84:	ffffe097          	auipc	ra,0xffffe
    80005f88:	ee0080e7          	jalr	-288(ra) # 80003e64 <iupdate>
    80005f8c:	b725                	j	80005eb4 <sys_unlink+0xe0>
    80005f8e:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80005f90:	8526                	mv	a0,s1
    80005f92:	ffffe097          	auipc	ra,0xffffe
    80005f96:	204080e7          	jalr	516(ra) # 80004196 <iunlockput>
  end_op();
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	9fa080e7          	jalr	-1542(ra) # 80004994 <end_op>
  return -1;
    80005fa2:	557d                	li	a0,-1
    80005fa4:	74ae                	ld	s1,232(sp)
}
    80005fa6:	70ee                	ld	ra,248(sp)
    80005fa8:	744e                	ld	s0,240(sp)
    80005faa:	6111                	addi	sp,sp,256
    80005fac:	8082                	ret
    return -1;
    80005fae:	557d                	li	a0,-1
    80005fb0:	bfdd                	j	80005fa6 <sys_unlink+0x1d2>
    iunlockput(ip);
    80005fb2:	854a                	mv	a0,s2
    80005fb4:	ffffe097          	auipc	ra,0xffffe
    80005fb8:	1e2080e7          	jalr	482(ra) # 80004196 <iunlockput>
    goto bad;
    80005fbc:	790e                	ld	s2,224(sp)
    80005fbe:	69ee                	ld	s3,216(sp)
    80005fc0:	6a4e                	ld	s4,208(sp)
    80005fc2:	6aae                	ld	s5,200(sp)
    80005fc4:	b7f1                	j	80005f90 <sys_unlink+0x1bc>

0000000080005fc6 <sys_open>:

uint64
sys_open(void)
{
    80005fc6:	7131                	addi	sp,sp,-192
    80005fc8:	fd06                	sd	ra,184(sp)
    80005fca:	f922                	sd	s0,176(sp)
    80005fcc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005fce:	f4c40593          	addi	a1,s0,-180
    80005fd2:	4505                	li	a0,1
    80005fd4:	ffffd097          	auipc	ra,0xffffd
    80005fd8:	242080e7          	jalr	578(ra) # 80003216 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005fdc:	08000613          	li	a2,128
    80005fe0:	f5040593          	addi	a1,s0,-176
    80005fe4:	4501                	li	a0,0
    80005fe6:	ffffd097          	auipc	ra,0xffffd
    80005fea:	270080e7          	jalr	624(ra) # 80003256 <argstr>
    80005fee:	87aa                	mv	a5,a0
    return -1;
    80005ff0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ff2:	0a07cf63          	bltz	a5,800060b0 <sys_open+0xea>
    80005ff6:	f526                	sd	s1,168(sp)

  begin_op();
    80005ff8:	fffff097          	auipc	ra,0xfffff
    80005ffc:	922080e7          	jalr	-1758(ra) # 8000491a <begin_op>

  if(omode & O_CREATE){
    80006000:	f4c42783          	lw	a5,-180(s0)
    80006004:	2007f793          	andi	a5,a5,512
    80006008:	cfdd                	beqz	a5,800060c6 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    8000600a:	4681                	li	a3,0
    8000600c:	4601                	li	a2,0
    8000600e:	4589                	li	a1,2
    80006010:	f5040513          	addi	a0,s0,-176
    80006014:	00000097          	auipc	ra,0x0
    80006018:	94a080e7          	jalr	-1718(ra) # 8000595e <create>
    8000601c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000601e:	cd49                	beqz	a0,800060b8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006020:	04449703          	lh	a4,68(s1)
    80006024:	478d                	li	a5,3
    80006026:	00f71763          	bne	a4,a5,80006034 <sys_open+0x6e>
    8000602a:	0464d703          	lhu	a4,70(s1)
    8000602e:	47a5                	li	a5,9
    80006030:	0ee7e263          	bltu	a5,a4,80006114 <sys_open+0x14e>
    80006034:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	cf8080e7          	jalr	-776(ra) # 80004d2e <filealloc>
    8000603e:	892a                	mv	s2,a0
    80006040:	cd65                	beqz	a0,80006138 <sys_open+0x172>
    80006042:	ed4e                	sd	s3,152(sp)
    80006044:	00000097          	auipc	ra,0x0
    80006048:	8d8080e7          	jalr	-1832(ra) # 8000591c <fdalloc>
    8000604c:	89aa                	mv	s3,a0
    8000604e:	0c054f63          	bltz	a0,8000612c <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006052:	04449703          	lh	a4,68(s1)
    80006056:	478d                	li	a5,3
    80006058:	0ef70d63          	beq	a4,a5,80006152 <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000605c:	4789                	li	a5,2
    8000605e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006062:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006066:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000606a:	f4c42783          	lw	a5,-180(s0)
    8000606e:	0017f713          	andi	a4,a5,1
    80006072:	00174713          	xori	a4,a4,1
    80006076:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000607a:	0037f713          	andi	a4,a5,3
    8000607e:	00e03733          	snez	a4,a4
    80006082:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006086:	4007f793          	andi	a5,a5,1024
    8000608a:	c791                	beqz	a5,80006096 <sys_open+0xd0>
    8000608c:	04449703          	lh	a4,68(s1)
    80006090:	4789                	li	a5,2
    80006092:	0cf70763          	beq	a4,a5,80006160 <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80006096:	8526                	mv	a0,s1
    80006098:	ffffe097          	auipc	ra,0xffffe
    8000609c:	f5e080e7          	jalr	-162(ra) # 80003ff6 <iunlock>
  end_op();
    800060a0:	fffff097          	auipc	ra,0xfffff
    800060a4:	8f4080e7          	jalr	-1804(ra) # 80004994 <end_op>

  return fd;
    800060a8:	854e                	mv	a0,s3
    800060aa:	74aa                	ld	s1,168(sp)
    800060ac:	790a                	ld	s2,160(sp)
    800060ae:	69ea                	ld	s3,152(sp)
}
    800060b0:	70ea                	ld	ra,184(sp)
    800060b2:	744a                	ld	s0,176(sp)
    800060b4:	6129                	addi	sp,sp,192
    800060b6:	8082                	ret
      end_op();
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	8dc080e7          	jalr	-1828(ra) # 80004994 <end_op>
      return -1;
    800060c0:	557d                	li	a0,-1
    800060c2:	74aa                	ld	s1,168(sp)
    800060c4:	b7f5                	j	800060b0 <sys_open+0xea>
    if((ip = namei(path)) == 0){
    800060c6:	f5040513          	addi	a0,s0,-176
    800060ca:	ffffe097          	auipc	ra,0xffffe
    800060ce:	64a080e7          	jalr	1610(ra) # 80004714 <namei>
    800060d2:	84aa                	mv	s1,a0
    800060d4:	c90d                	beqz	a0,80006106 <sys_open+0x140>
    ilock(ip);
    800060d6:	ffffe097          	auipc	ra,0xffffe
    800060da:	e5a080e7          	jalr	-422(ra) # 80003f30 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060de:	04449703          	lh	a4,68(s1)
    800060e2:	4785                	li	a5,1
    800060e4:	f2f71ee3          	bne	a4,a5,80006020 <sys_open+0x5a>
    800060e8:	f4c42783          	lw	a5,-180(s0)
    800060ec:	d7a1                	beqz	a5,80006034 <sys_open+0x6e>
      iunlockput(ip);
    800060ee:	8526                	mv	a0,s1
    800060f0:	ffffe097          	auipc	ra,0xffffe
    800060f4:	0a6080e7          	jalr	166(ra) # 80004196 <iunlockput>
      end_op();
    800060f8:	fffff097          	auipc	ra,0xfffff
    800060fc:	89c080e7          	jalr	-1892(ra) # 80004994 <end_op>
      return -1;
    80006100:	557d                	li	a0,-1
    80006102:	74aa                	ld	s1,168(sp)
    80006104:	b775                	j	800060b0 <sys_open+0xea>
      end_op();
    80006106:	fffff097          	auipc	ra,0xfffff
    8000610a:	88e080e7          	jalr	-1906(ra) # 80004994 <end_op>
      return -1;
    8000610e:	557d                	li	a0,-1
    80006110:	74aa                	ld	s1,168(sp)
    80006112:	bf79                	j	800060b0 <sys_open+0xea>
    iunlockput(ip);
    80006114:	8526                	mv	a0,s1
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	080080e7          	jalr	128(ra) # 80004196 <iunlockput>
    end_op();
    8000611e:	fffff097          	auipc	ra,0xfffff
    80006122:	876080e7          	jalr	-1930(ra) # 80004994 <end_op>
    return -1;
    80006126:	557d                	li	a0,-1
    80006128:	74aa                	ld	s1,168(sp)
    8000612a:	b759                	j	800060b0 <sys_open+0xea>
      fileclose(f);
    8000612c:	854a                	mv	a0,s2
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	cbc080e7          	jalr	-836(ra) # 80004dea <fileclose>
    80006136:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006138:	8526                	mv	a0,s1
    8000613a:	ffffe097          	auipc	ra,0xffffe
    8000613e:	05c080e7          	jalr	92(ra) # 80004196 <iunlockput>
    end_op();
    80006142:	fffff097          	auipc	ra,0xfffff
    80006146:	852080e7          	jalr	-1966(ra) # 80004994 <end_op>
    return -1;
    8000614a:	557d                	li	a0,-1
    8000614c:	74aa                	ld	s1,168(sp)
    8000614e:	790a                	ld	s2,160(sp)
    80006150:	b785                	j	800060b0 <sys_open+0xea>
    f->type = FD_DEVICE;
    80006152:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006156:	04649783          	lh	a5,70(s1)
    8000615a:	02f91223          	sh	a5,36(s2)
    8000615e:	b721                	j	80006066 <sys_open+0xa0>
    itrunc(ip);
    80006160:	8526                	mv	a0,s1
    80006162:	ffffe097          	auipc	ra,0xffffe
    80006166:	ee0080e7          	jalr	-288(ra) # 80004042 <itrunc>
    8000616a:	b735                	j	80006096 <sys_open+0xd0>

000000008000616c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000616c:	7175                	addi	sp,sp,-144
    8000616e:	e506                	sd	ra,136(sp)
    80006170:	e122                	sd	s0,128(sp)
    80006172:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006174:	ffffe097          	auipc	ra,0xffffe
    80006178:	7a6080e7          	jalr	1958(ra) # 8000491a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000617c:	08000613          	li	a2,128
    80006180:	f7040593          	addi	a1,s0,-144
    80006184:	4501                	li	a0,0
    80006186:	ffffd097          	auipc	ra,0xffffd
    8000618a:	0d0080e7          	jalr	208(ra) # 80003256 <argstr>
    8000618e:	02054963          	bltz	a0,800061c0 <sys_mkdir+0x54>
    80006192:	4681                	li	a3,0
    80006194:	4601                	li	a2,0
    80006196:	4585                	li	a1,1
    80006198:	f7040513          	addi	a0,s0,-144
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	7c2080e7          	jalr	1986(ra) # 8000595e <create>
    800061a4:	cd11                	beqz	a0,800061c0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061a6:	ffffe097          	auipc	ra,0xffffe
    800061aa:	ff0080e7          	jalr	-16(ra) # 80004196 <iunlockput>
  end_op();
    800061ae:	ffffe097          	auipc	ra,0xffffe
    800061b2:	7e6080e7          	jalr	2022(ra) # 80004994 <end_op>
  return 0;
    800061b6:	4501                	li	a0,0
}
    800061b8:	60aa                	ld	ra,136(sp)
    800061ba:	640a                	ld	s0,128(sp)
    800061bc:	6149                	addi	sp,sp,144
    800061be:	8082                	ret
    end_op();
    800061c0:	ffffe097          	auipc	ra,0xffffe
    800061c4:	7d4080e7          	jalr	2004(ra) # 80004994 <end_op>
    return -1;
    800061c8:	557d                	li	a0,-1
    800061ca:	b7fd                	j	800061b8 <sys_mkdir+0x4c>

00000000800061cc <sys_mknod>:

uint64
sys_mknod(void)
{
    800061cc:	7135                	addi	sp,sp,-160
    800061ce:	ed06                	sd	ra,152(sp)
    800061d0:	e922                	sd	s0,144(sp)
    800061d2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800061d4:	ffffe097          	auipc	ra,0xffffe
    800061d8:	746080e7          	jalr	1862(ra) # 8000491a <begin_op>
  argint(1, &major);
    800061dc:	f6c40593          	addi	a1,s0,-148
    800061e0:	4505                	li	a0,1
    800061e2:	ffffd097          	auipc	ra,0xffffd
    800061e6:	034080e7          	jalr	52(ra) # 80003216 <argint>
  argint(2, &minor);
    800061ea:	f6840593          	addi	a1,s0,-152
    800061ee:	4509                	li	a0,2
    800061f0:	ffffd097          	auipc	ra,0xffffd
    800061f4:	026080e7          	jalr	38(ra) # 80003216 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061f8:	08000613          	li	a2,128
    800061fc:	f7040593          	addi	a1,s0,-144
    80006200:	4501                	li	a0,0
    80006202:	ffffd097          	auipc	ra,0xffffd
    80006206:	054080e7          	jalr	84(ra) # 80003256 <argstr>
    8000620a:	02054b63          	bltz	a0,80006240 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000620e:	f6841683          	lh	a3,-152(s0)
    80006212:	f6c41603          	lh	a2,-148(s0)
    80006216:	458d                	li	a1,3
    80006218:	f7040513          	addi	a0,s0,-144
    8000621c:	fffff097          	auipc	ra,0xfffff
    80006220:	742080e7          	jalr	1858(ra) # 8000595e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006224:	cd11                	beqz	a0,80006240 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006226:	ffffe097          	auipc	ra,0xffffe
    8000622a:	f70080e7          	jalr	-144(ra) # 80004196 <iunlockput>
  end_op();
    8000622e:	ffffe097          	auipc	ra,0xffffe
    80006232:	766080e7          	jalr	1894(ra) # 80004994 <end_op>
  return 0;
    80006236:	4501                	li	a0,0
}
    80006238:	60ea                	ld	ra,152(sp)
    8000623a:	644a                	ld	s0,144(sp)
    8000623c:	610d                	addi	sp,sp,160
    8000623e:	8082                	ret
    end_op();
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	754080e7          	jalr	1876(ra) # 80004994 <end_op>
    return -1;
    80006248:	557d                	li	a0,-1
    8000624a:	b7fd                	j	80006238 <sys_mknod+0x6c>

000000008000624c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000624c:	7135                	addi	sp,sp,-160
    8000624e:	ed06                	sd	ra,152(sp)
    80006250:	e922                	sd	s0,144(sp)
    80006252:	e14a                	sd	s2,128(sp)
    80006254:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006256:	ffffc097          	auipc	ra,0xffffc
    8000625a:	85a080e7          	jalr	-1958(ra) # 80001ab0 <myproc>
    8000625e:	892a                	mv	s2,a0
  
  begin_op();
    80006260:	ffffe097          	auipc	ra,0xffffe
    80006264:	6ba080e7          	jalr	1722(ra) # 8000491a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006268:	08000613          	li	a2,128
    8000626c:	f6040593          	addi	a1,s0,-160
    80006270:	4501                	li	a0,0
    80006272:	ffffd097          	auipc	ra,0xffffd
    80006276:	fe4080e7          	jalr	-28(ra) # 80003256 <argstr>
    8000627a:	04054d63          	bltz	a0,800062d4 <sys_chdir+0x88>
    8000627e:	e526                	sd	s1,136(sp)
    80006280:	f6040513          	addi	a0,s0,-160
    80006284:	ffffe097          	auipc	ra,0xffffe
    80006288:	490080e7          	jalr	1168(ra) # 80004714 <namei>
    8000628c:	84aa                	mv	s1,a0
    8000628e:	c131                	beqz	a0,800062d2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006290:	ffffe097          	auipc	ra,0xffffe
    80006294:	ca0080e7          	jalr	-864(ra) # 80003f30 <ilock>
  if(ip->type != T_DIR){
    80006298:	04449703          	lh	a4,68(s1)
    8000629c:	4785                	li	a5,1
    8000629e:	04f71163          	bne	a4,a5,800062e0 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800062a2:	8526                	mv	a0,s1
    800062a4:	ffffe097          	auipc	ra,0xffffe
    800062a8:	d52080e7          	jalr	-686(ra) # 80003ff6 <iunlock>
  iput(p->cwd);
    800062ac:	32893503          	ld	a0,808(s2)
    800062b0:	ffffe097          	auipc	ra,0xffffe
    800062b4:	e3e080e7          	jalr	-450(ra) # 800040ee <iput>
  end_op();
    800062b8:	ffffe097          	auipc	ra,0xffffe
    800062bc:	6dc080e7          	jalr	1756(ra) # 80004994 <end_op>
  p->cwd = ip;
    800062c0:	32993423          	sd	s1,808(s2)
  return 0;
    800062c4:	4501                	li	a0,0
    800062c6:	64aa                	ld	s1,136(sp)
}
    800062c8:	60ea                	ld	ra,152(sp)
    800062ca:	644a                	ld	s0,144(sp)
    800062cc:	690a                	ld	s2,128(sp)
    800062ce:	610d                	addi	sp,sp,160
    800062d0:	8082                	ret
    800062d2:	64aa                	ld	s1,136(sp)
    end_op();
    800062d4:	ffffe097          	auipc	ra,0xffffe
    800062d8:	6c0080e7          	jalr	1728(ra) # 80004994 <end_op>
    return -1;
    800062dc:	557d                	li	a0,-1
    800062de:	b7ed                	j	800062c8 <sys_chdir+0x7c>
    iunlockput(ip);
    800062e0:	8526                	mv	a0,s1
    800062e2:	ffffe097          	auipc	ra,0xffffe
    800062e6:	eb4080e7          	jalr	-332(ra) # 80004196 <iunlockput>
    end_op();
    800062ea:	ffffe097          	auipc	ra,0xffffe
    800062ee:	6aa080e7          	jalr	1706(ra) # 80004994 <end_op>
    return -1;
    800062f2:	557d                	li	a0,-1
    800062f4:	64aa                	ld	s1,136(sp)
    800062f6:	bfc9                	j	800062c8 <sys_chdir+0x7c>

00000000800062f8 <sys_exec>:

uint64
sys_exec(void)
{
    800062f8:	7105                	addi	sp,sp,-480
    800062fa:	ef86                	sd	ra,472(sp)
    800062fc:	eba2                	sd	s0,464(sp)
    800062fe:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006300:	e2840593          	addi	a1,s0,-472
    80006304:	4505                	li	a0,1
    80006306:	ffffd097          	auipc	ra,0xffffd
    8000630a:	f30080e7          	jalr	-208(ra) # 80003236 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000630e:	08000613          	li	a2,128
    80006312:	f3040593          	addi	a1,s0,-208
    80006316:	4501                	li	a0,0
    80006318:	ffffd097          	auipc	ra,0xffffd
    8000631c:	f3e080e7          	jalr	-194(ra) # 80003256 <argstr>
    80006320:	87aa                	mv	a5,a0
    return -1;
    80006322:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006324:	0e07ce63          	bltz	a5,80006420 <sys_exec+0x128>
    80006328:	e7a6                	sd	s1,456(sp)
    8000632a:	e3ca                	sd	s2,448(sp)
    8000632c:	ff4e                	sd	s3,440(sp)
    8000632e:	fb52                	sd	s4,432(sp)
    80006330:	f756                	sd	s5,424(sp)
    80006332:	f35a                	sd	s6,416(sp)
    80006334:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006336:	e3040a13          	addi	s4,s0,-464
    8000633a:	10000613          	li	a2,256
    8000633e:	4581                	li	a1,0
    80006340:	8552                	mv	a0,s4
    80006342:	ffffb097          	auipc	ra,0xffffb
    80006346:	9f4080e7          	jalr	-1548(ra) # 80000d36 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000634a:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000634c:	89d2                	mv	s3,s4
    8000634e:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006350:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006354:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80006356:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000635a:	00391513          	slli	a0,s2,0x3
    8000635e:	85d6                	mv	a1,s5
    80006360:	e2843783          	ld	a5,-472(s0)
    80006364:	953e                	add	a0,a0,a5
    80006366:	ffffd097          	auipc	ra,0xffffd
    8000636a:	e0c080e7          	jalr	-500(ra) # 80003172 <fetchaddr>
    8000636e:	02054a63          	bltz	a0,800063a2 <sys_exec+0xaa>
    if(uarg == 0){
    80006372:	e2043783          	ld	a5,-480(s0)
    80006376:	cbb1                	beqz	a5,800063ca <sys_exec+0xd2>
    argv[i] = kalloc();
    80006378:	ffffa097          	auipc	ra,0xffffa
    8000637c:	7d2080e7          	jalr	2002(ra) # 80000b4a <kalloc>
    80006380:	85aa                	mv	a1,a0
    80006382:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006386:	cd11                	beqz	a0,800063a2 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006388:	865a                	mv	a2,s6
    8000638a:	e2043503          	ld	a0,-480(s0)
    8000638e:	ffffd097          	auipc	ra,0xffffd
    80006392:	e3a080e7          	jalr	-454(ra) # 800031c8 <fetchstr>
    80006396:	00054663          	bltz	a0,800063a2 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    8000639a:	0905                	addi	s2,s2,1
    8000639c:	09a1                	addi	s3,s3,8
    8000639e:	fb791ee3          	bne	s2,s7,8000635a <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063a2:	100a0a13          	addi	s4,s4,256
    800063a6:	6088                	ld	a0,0(s1)
    800063a8:	c525                	beqz	a0,80006410 <sys_exec+0x118>
    kfree(argv[i]);
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	6a2080e7          	jalr	1698(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063b2:	04a1                	addi	s1,s1,8
    800063b4:	ff4499e3          	bne	s1,s4,800063a6 <sys_exec+0xae>
  return -1;
    800063b8:	557d                	li	a0,-1
    800063ba:	64be                	ld	s1,456(sp)
    800063bc:	691e                	ld	s2,448(sp)
    800063be:	79fa                	ld	s3,440(sp)
    800063c0:	7a5a                	ld	s4,432(sp)
    800063c2:	7aba                	ld	s5,424(sp)
    800063c4:	7b1a                	ld	s6,416(sp)
    800063c6:	6bfa                	ld	s7,408(sp)
    800063c8:	a8a1                	j	80006420 <sys_exec+0x128>
      argv[i] = 0;
    800063ca:	0009079b          	sext.w	a5,s2
    800063ce:	e3040593          	addi	a1,s0,-464
    800063d2:	078e                	slli	a5,a5,0x3
    800063d4:	97ae                	add	a5,a5,a1
    800063d6:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    800063da:	f3040513          	addi	a0,s0,-208
    800063de:	fffff097          	auipc	ra,0xfffff
    800063e2:	116080e7          	jalr	278(ra) # 800054f4 <exec>
    800063e6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063e8:	100a0a13          	addi	s4,s4,256
    800063ec:	6088                	ld	a0,0(s1)
    800063ee:	c901                	beqz	a0,800063fe <sys_exec+0x106>
    kfree(argv[i]);
    800063f0:	ffffa097          	auipc	ra,0xffffa
    800063f4:	65c080e7          	jalr	1628(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063f8:	04a1                	addi	s1,s1,8
    800063fa:	ff4499e3          	bne	s1,s4,800063ec <sys_exec+0xf4>
  return ret;
    800063fe:	854a                	mv	a0,s2
    80006400:	64be                	ld	s1,456(sp)
    80006402:	691e                	ld	s2,448(sp)
    80006404:	79fa                	ld	s3,440(sp)
    80006406:	7a5a                	ld	s4,432(sp)
    80006408:	7aba                	ld	s5,424(sp)
    8000640a:	7b1a                	ld	s6,416(sp)
    8000640c:	6bfa                	ld	s7,408(sp)
    8000640e:	a809                	j	80006420 <sys_exec+0x128>
  return -1;
    80006410:	557d                	li	a0,-1
    80006412:	64be                	ld	s1,456(sp)
    80006414:	691e                	ld	s2,448(sp)
    80006416:	79fa                	ld	s3,440(sp)
    80006418:	7a5a                	ld	s4,432(sp)
    8000641a:	7aba                	ld	s5,424(sp)
    8000641c:	7b1a                	ld	s6,416(sp)
    8000641e:	6bfa                	ld	s7,408(sp)
}
    80006420:	60fe                	ld	ra,472(sp)
    80006422:	645e                	ld	s0,464(sp)
    80006424:	613d                	addi	sp,sp,480
    80006426:	8082                	ret

0000000080006428 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006428:	7139                	addi	sp,sp,-64
    8000642a:	fc06                	sd	ra,56(sp)
    8000642c:	f822                	sd	s0,48(sp)
    8000642e:	f426                	sd	s1,40(sp)
    80006430:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006432:	ffffb097          	auipc	ra,0xffffb
    80006436:	67e080e7          	jalr	1662(ra) # 80001ab0 <myproc>
    8000643a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000643c:	fd840593          	addi	a1,s0,-40
    80006440:	4501                	li	a0,0
    80006442:	ffffd097          	auipc	ra,0xffffd
    80006446:	df4080e7          	jalr	-524(ra) # 80003236 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000644a:	fc840593          	addi	a1,s0,-56
    8000644e:	fd040513          	addi	a0,s0,-48
    80006452:	fffff097          	auipc	ra,0xfffff
    80006456:	d0c080e7          	jalr	-756(ra) # 8000515e <pipealloc>
    return -1;
    8000645a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000645c:	0c054963          	bltz	a0,8000652e <sys_pipe+0x106>
  fd0 = -1;
    80006460:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006464:	fd043503          	ld	a0,-48(s0)
    80006468:	fffff097          	auipc	ra,0xfffff
    8000646c:	4b4080e7          	jalr	1204(ra) # 8000591c <fdalloc>
    80006470:	fca42223          	sw	a0,-60(s0)
    80006474:	0a054063          	bltz	a0,80006514 <sys_pipe+0xec>
    80006478:	fc843503          	ld	a0,-56(s0)
    8000647c:	fffff097          	auipc	ra,0xfffff
    80006480:	4a0080e7          	jalr	1184(ra) # 8000591c <fdalloc>
    80006484:	fca42023          	sw	a0,-64(s0)
    80006488:	06054c63          	bltz	a0,80006500 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000648c:	4691                	li	a3,4
    8000648e:	fc440613          	addi	a2,s0,-60
    80006492:	fd843583          	ld	a1,-40(s0)
    80006496:	2284b503          	ld	a0,552(s1)
    8000649a:	ffffb097          	auipc	ra,0xffffb
    8000649e:	276080e7          	jalr	630(ra) # 80001710 <copyout>
    800064a2:	02054163          	bltz	a0,800064c4 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800064a6:	4691                	li	a3,4
    800064a8:	fc040613          	addi	a2,s0,-64
    800064ac:	fd843583          	ld	a1,-40(s0)
    800064b0:	95b6                	add	a1,a1,a3
    800064b2:	2284b503          	ld	a0,552(s1)
    800064b6:	ffffb097          	auipc	ra,0xffffb
    800064ba:	25a080e7          	jalr	602(ra) # 80001710 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800064be:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064c0:	06055763          	bgez	a0,8000652e <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    800064c4:	fc442783          	lw	a5,-60(s0)
    800064c8:	05478793          	addi	a5,a5,84
    800064cc:	078e                	slli	a5,a5,0x3
    800064ce:	97a6                	add	a5,a5,s1
    800064d0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800064d4:	fc042783          	lw	a5,-64(s0)
    800064d8:	05478793          	addi	a5,a5,84
    800064dc:	078e                	slli	a5,a5,0x3
    800064de:	94be                	add	s1,s1,a5
    800064e0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800064e4:	fd043503          	ld	a0,-48(s0)
    800064e8:	fffff097          	auipc	ra,0xfffff
    800064ec:	902080e7          	jalr	-1790(ra) # 80004dea <fileclose>
    fileclose(wf);
    800064f0:	fc843503          	ld	a0,-56(s0)
    800064f4:	fffff097          	auipc	ra,0xfffff
    800064f8:	8f6080e7          	jalr	-1802(ra) # 80004dea <fileclose>
    return -1;
    800064fc:	57fd                	li	a5,-1
    800064fe:	a805                	j	8000652e <sys_pipe+0x106>
    if(fd0 >= 0)
    80006500:	fc442783          	lw	a5,-60(s0)
    80006504:	0007c863          	bltz	a5,80006514 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80006508:	05478793          	addi	a5,a5,84
    8000650c:	078e                	slli	a5,a5,0x3
    8000650e:	97a6                	add	a5,a5,s1
    80006510:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80006514:	fd043503          	ld	a0,-48(s0)
    80006518:	fffff097          	auipc	ra,0xfffff
    8000651c:	8d2080e7          	jalr	-1838(ra) # 80004dea <fileclose>
    fileclose(wf);
    80006520:	fc843503          	ld	a0,-56(s0)
    80006524:	fffff097          	auipc	ra,0xfffff
    80006528:	8c6080e7          	jalr	-1850(ra) # 80004dea <fileclose>
    return -1;
    8000652c:	57fd                	li	a5,-1
}
    8000652e:	853e                	mv	a0,a5
    80006530:	70e2                	ld	ra,56(sp)
    80006532:	7442                	ld	s0,48(sp)
    80006534:	74a2                	ld	s1,40(sp)
    80006536:	6121                	addi	sp,sp,64
    80006538:	8082                	ret
    8000653a:	0000                	unimp
    8000653c:	0000                	unimp
	...

0000000080006540 <kernelvec>:
    80006540:	7111                	addi	sp,sp,-256
    80006542:	e006                	sd	ra,0(sp)
    80006544:	e40a                	sd	sp,8(sp)
    80006546:	e80e                	sd	gp,16(sp)
    80006548:	ec12                	sd	tp,24(sp)
    8000654a:	f016                	sd	t0,32(sp)
    8000654c:	f41a                	sd	t1,40(sp)
    8000654e:	f81e                	sd	t2,48(sp)
    80006550:	fc22                	sd	s0,56(sp)
    80006552:	e0a6                	sd	s1,64(sp)
    80006554:	e4aa                	sd	a0,72(sp)
    80006556:	e8ae                	sd	a1,80(sp)
    80006558:	ecb2                	sd	a2,88(sp)
    8000655a:	f0b6                	sd	a3,96(sp)
    8000655c:	f4ba                	sd	a4,104(sp)
    8000655e:	f8be                	sd	a5,112(sp)
    80006560:	fcc2                	sd	a6,120(sp)
    80006562:	e146                	sd	a7,128(sp)
    80006564:	e54a                	sd	s2,136(sp)
    80006566:	e94e                	sd	s3,144(sp)
    80006568:	ed52                	sd	s4,152(sp)
    8000656a:	f156                	sd	s5,160(sp)
    8000656c:	f55a                	sd	s6,168(sp)
    8000656e:	f95e                	sd	s7,176(sp)
    80006570:	fd62                	sd	s8,184(sp)
    80006572:	e1e6                	sd	s9,192(sp)
    80006574:	e5ea                	sd	s10,200(sp)
    80006576:	e9ee                	sd	s11,208(sp)
    80006578:	edf2                	sd	t3,216(sp)
    8000657a:	f1f6                	sd	t4,224(sp)
    8000657c:	f5fa                	sd	t5,232(sp)
    8000657e:	f9fe                	sd	t6,240(sp)
    80006580:	ab3fc0ef          	jal	80003032 <kerneltrap>
    80006584:	6082                	ld	ra,0(sp)
    80006586:	6122                	ld	sp,8(sp)
    80006588:	61c2                	ld	gp,16(sp)
    8000658a:	7282                	ld	t0,32(sp)
    8000658c:	7322                	ld	t1,40(sp)
    8000658e:	73c2                	ld	t2,48(sp)
    80006590:	7462                	ld	s0,56(sp)
    80006592:	6486                	ld	s1,64(sp)
    80006594:	6526                	ld	a0,72(sp)
    80006596:	65c6                	ld	a1,80(sp)
    80006598:	6666                	ld	a2,88(sp)
    8000659a:	7686                	ld	a3,96(sp)
    8000659c:	7726                	ld	a4,104(sp)
    8000659e:	77c6                	ld	a5,112(sp)
    800065a0:	7866                	ld	a6,120(sp)
    800065a2:	688a                	ld	a7,128(sp)
    800065a4:	692a                	ld	s2,136(sp)
    800065a6:	69ca                	ld	s3,144(sp)
    800065a8:	6a6a                	ld	s4,152(sp)
    800065aa:	7a8a                	ld	s5,160(sp)
    800065ac:	7b2a                	ld	s6,168(sp)
    800065ae:	7bca                	ld	s7,176(sp)
    800065b0:	7c6a                	ld	s8,184(sp)
    800065b2:	6c8e                	ld	s9,192(sp)
    800065b4:	6d2e                	ld	s10,200(sp)
    800065b6:	6dce                	ld	s11,208(sp)
    800065b8:	6e6e                	ld	t3,216(sp)
    800065ba:	7e8e                	ld	t4,224(sp)
    800065bc:	7f2e                	ld	t5,232(sp)
    800065be:	7fce                	ld	t6,240(sp)
    800065c0:	6111                	addi	sp,sp,256
    800065c2:	10200073          	sret
    800065c6:	00000013          	nop
    800065ca:	00000013          	nop
    800065ce:	0001                	nop

00000000800065d0 <timervec>:
    800065d0:	34051573          	csrrw	a0,mscratch,a0
    800065d4:	e10c                	sd	a1,0(a0)
    800065d6:	e510                	sd	a2,8(a0)
    800065d8:	e914                	sd	a3,16(a0)
    800065da:	6d0c                	ld	a1,24(a0)
    800065dc:	7110                	ld	a2,32(a0)
    800065de:	6194                	ld	a3,0(a1)
    800065e0:	96b2                	add	a3,a3,a2
    800065e2:	e194                	sd	a3,0(a1)
    800065e4:	4589                	li	a1,2
    800065e6:	14459073          	csrw	sip,a1
    800065ea:	6914                	ld	a3,16(a0)
    800065ec:	6510                	ld	a2,8(a0)
    800065ee:	610c                	ld	a1,0(a0)
    800065f0:	34051573          	csrrw	a0,mscratch,a0
    800065f4:	30200073          	mret
	...

00000000800065fa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800065fa:	1141                	addi	sp,sp,-16
    800065fc:	e406                	sd	ra,8(sp)
    800065fe:	e022                	sd	s0,0(sp)
    80006600:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006602:	0c000737          	lui	a4,0xc000
    80006606:	4785                	li	a5,1
    80006608:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000660a:	c35c                	sw	a5,4(a4)
}
    8000660c:	60a2                	ld	ra,8(sp)
    8000660e:	6402                	ld	s0,0(sp)
    80006610:	0141                	addi	sp,sp,16
    80006612:	8082                	ret

0000000080006614 <plicinithart>:

void
plicinithart(void)
{
    80006614:	1141                	addi	sp,sp,-16
    80006616:	e406                	sd	ra,8(sp)
    80006618:	e022                	sd	s0,0(sp)
    8000661a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000661c:	ffffb097          	auipc	ra,0xffffb
    80006620:	460080e7          	jalr	1120(ra) # 80001a7c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006624:	0085171b          	slliw	a4,a0,0x8
    80006628:	0c0027b7          	lui	a5,0xc002
    8000662c:	97ba                	add	a5,a5,a4
    8000662e:	40200713          	li	a4,1026
    80006632:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006636:	00d5151b          	slliw	a0,a0,0xd
    8000663a:	0c2017b7          	lui	a5,0xc201
    8000663e:	97aa                	add	a5,a5,a0
    80006640:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006644:	60a2                	ld	ra,8(sp)
    80006646:	6402                	ld	s0,0(sp)
    80006648:	0141                	addi	sp,sp,16
    8000664a:	8082                	ret

000000008000664c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000664c:	1141                	addi	sp,sp,-16
    8000664e:	e406                	sd	ra,8(sp)
    80006650:	e022                	sd	s0,0(sp)
    80006652:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006654:	ffffb097          	auipc	ra,0xffffb
    80006658:	428080e7          	jalr	1064(ra) # 80001a7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000665c:	00d5151b          	slliw	a0,a0,0xd
    80006660:	0c2017b7          	lui	a5,0xc201
    80006664:	97aa                	add	a5,a5,a0
  return irq;
}
    80006666:	43c8                	lw	a0,4(a5)
    80006668:	60a2                	ld	ra,8(sp)
    8000666a:	6402                	ld	s0,0(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret

0000000080006670 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006670:	1101                	addi	sp,sp,-32
    80006672:	ec06                	sd	ra,24(sp)
    80006674:	e822                	sd	s0,16(sp)
    80006676:	e426                	sd	s1,8(sp)
    80006678:	1000                	addi	s0,sp,32
    8000667a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000667c:	ffffb097          	auipc	ra,0xffffb
    80006680:	400080e7          	jalr	1024(ra) # 80001a7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006684:	00d5179b          	slliw	a5,a0,0xd
    80006688:	0c201737          	lui	a4,0xc201
    8000668c:	97ba                	add	a5,a5,a4
    8000668e:	c3c4                	sw	s1,4(a5)
}
    80006690:	60e2                	ld	ra,24(sp)
    80006692:	6442                	ld	s0,16(sp)
    80006694:	64a2                	ld	s1,8(sp)
    80006696:	6105                	addi	sp,sp,32
    80006698:	8082                	ret

000000008000669a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000669a:	1141                	addi	sp,sp,-16
    8000669c:	e406                	sd	ra,8(sp)
    8000669e:	e022                	sd	s0,0(sp)
    800066a0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800066a2:	479d                	li	a5,7
    800066a4:	04a7cc63          	blt	a5,a0,800066fc <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800066a8:	00024797          	auipc	a5,0x24
    800066ac:	83878793          	addi	a5,a5,-1992 # 80029ee0 <disk>
    800066b0:	97aa                	add	a5,a5,a0
    800066b2:	0187c783          	lbu	a5,24(a5)
    800066b6:	ebb9                	bnez	a5,8000670c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800066b8:	00451693          	slli	a3,a0,0x4
    800066bc:	00024797          	auipc	a5,0x24
    800066c0:	82478793          	addi	a5,a5,-2012 # 80029ee0 <disk>
    800066c4:	6398                	ld	a4,0(a5)
    800066c6:	9736                	add	a4,a4,a3
    800066c8:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800066cc:	6398                	ld	a4,0(a5)
    800066ce:	9736                	add	a4,a4,a3
    800066d0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066d4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066d8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066dc:	97aa                	add	a5,a5,a0
    800066de:	4705                	li	a4,1
    800066e0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066e4:	00024517          	auipc	a0,0x24
    800066e8:	81450513          	addi	a0,a0,-2028 # 80029ef8 <disk+0x18>
    800066ec:	ffffc097          	auipc	ra,0xffffc
    800066f0:	ecc080e7          	jalr	-308(ra) # 800025b8 <wakeup>
}
    800066f4:	60a2                	ld	ra,8(sp)
    800066f6:	6402                	ld	s0,0(sp)
    800066f8:	0141                	addi	sp,sp,16
    800066fa:	8082                	ret
    panic("free_desc 1");
    800066fc:	00002517          	auipc	a0,0x2
    80006700:	fc450513          	addi	a0,a0,-60 # 800086c0 <etext+0x6c0>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	e5c080e7          	jalr	-420(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000670c:	00002517          	auipc	a0,0x2
    80006710:	fc450513          	addi	a0,a0,-60 # 800086d0 <etext+0x6d0>
    80006714:	ffffa097          	auipc	ra,0xffffa
    80006718:	e4c080e7          	jalr	-436(ra) # 80000560 <panic>

000000008000671c <virtio_disk_init>:
{
    8000671c:	1101                	addi	sp,sp,-32
    8000671e:	ec06                	sd	ra,24(sp)
    80006720:	e822                	sd	s0,16(sp)
    80006722:	e426                	sd	s1,8(sp)
    80006724:	e04a                	sd	s2,0(sp)
    80006726:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006728:	00002597          	auipc	a1,0x2
    8000672c:	fb858593          	addi	a1,a1,-72 # 800086e0 <etext+0x6e0>
    80006730:	00024517          	auipc	a0,0x24
    80006734:	8d850513          	addi	a0,a0,-1832 # 8002a008 <disk+0x128>
    80006738:	ffffa097          	auipc	ra,0xffffa
    8000673c:	472080e7          	jalr	1138(ra) # 80000baa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006740:	100017b7          	lui	a5,0x10001
    80006744:	4398                	lw	a4,0(a5)
    80006746:	2701                	sext.w	a4,a4
    80006748:	747277b7          	lui	a5,0x74727
    8000674c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006750:	16f71463          	bne	a4,a5,800068b8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006754:	100017b7          	lui	a5,0x10001
    80006758:	43dc                	lw	a5,4(a5)
    8000675a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000675c:	4709                	li	a4,2
    8000675e:	14e79d63          	bne	a5,a4,800068b8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006762:	100017b7          	lui	a5,0x10001
    80006766:	479c                	lw	a5,8(a5)
    80006768:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000676a:	14e79763          	bne	a5,a4,800068b8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000676e:	100017b7          	lui	a5,0x10001
    80006772:	47d8                	lw	a4,12(a5)
    80006774:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006776:	554d47b7          	lui	a5,0x554d4
    8000677a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000677e:	12f71d63          	bne	a4,a5,800068b8 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006782:	100017b7          	lui	a5,0x10001
    80006786:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000678a:	4705                	li	a4,1
    8000678c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000678e:	470d                	li	a4,3
    80006790:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006792:	10001737          	lui	a4,0x10001
    80006796:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006798:	c7ffe6b7          	lui	a3,0xc7ffe
    8000679c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd473f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067a0:	8f75                	and	a4,a4,a3
    800067a2:	100016b7          	lui	a3,0x10001
    800067a6:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067a8:	472d                	li	a4,11
    800067aa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067ac:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800067b0:	439c                	lw	a5,0(a5)
    800067b2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067b6:	8ba1                	andi	a5,a5,8
    800067b8:	10078863          	beqz	a5,800068c8 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800067bc:	100017b7          	lui	a5,0x10001
    800067c0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800067c4:	43fc                	lw	a5,68(a5)
    800067c6:	2781                	sext.w	a5,a5
    800067c8:	10079863          	bnez	a5,800068d8 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800067cc:	100017b7          	lui	a5,0x10001
    800067d0:	5bdc                	lw	a5,52(a5)
    800067d2:	2781                	sext.w	a5,a5
  if(max == 0)
    800067d4:	10078a63          	beqz	a5,800068e8 <virtio_disk_init+0x1cc>
  if(max < NUM)
    800067d8:	471d                	li	a4,7
    800067da:	10f77f63          	bgeu	a4,a5,800068f8 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	36c080e7          	jalr	876(ra) # 80000b4a <kalloc>
    800067e6:	00023497          	auipc	s1,0x23
    800067ea:	6fa48493          	addi	s1,s1,1786 # 80029ee0 <disk>
    800067ee:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800067f0:	ffffa097          	auipc	ra,0xffffa
    800067f4:	35a080e7          	jalr	858(ra) # 80000b4a <kalloc>
    800067f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800067fa:	ffffa097          	auipc	ra,0xffffa
    800067fe:	350080e7          	jalr	848(ra) # 80000b4a <kalloc>
    80006802:	87aa                	mv	a5,a0
    80006804:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006806:	6088                	ld	a0,0(s1)
    80006808:	10050063          	beqz	a0,80006908 <virtio_disk_init+0x1ec>
    8000680c:	00023717          	auipc	a4,0x23
    80006810:	6dc73703          	ld	a4,1756(a4) # 80029ee8 <disk+0x8>
    80006814:	cb75                	beqz	a4,80006908 <virtio_disk_init+0x1ec>
    80006816:	cbed                	beqz	a5,80006908 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006818:	6605                	lui	a2,0x1
    8000681a:	4581                	li	a1,0
    8000681c:	ffffa097          	auipc	ra,0xffffa
    80006820:	51a080e7          	jalr	1306(ra) # 80000d36 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006824:	00023497          	auipc	s1,0x23
    80006828:	6bc48493          	addi	s1,s1,1724 # 80029ee0 <disk>
    8000682c:	6605                	lui	a2,0x1
    8000682e:	4581                	li	a1,0
    80006830:	6488                	ld	a0,8(s1)
    80006832:	ffffa097          	auipc	ra,0xffffa
    80006836:	504080e7          	jalr	1284(ra) # 80000d36 <memset>
  memset(disk.used, 0, PGSIZE);
    8000683a:	6605                	lui	a2,0x1
    8000683c:	4581                	li	a1,0
    8000683e:	6888                	ld	a0,16(s1)
    80006840:	ffffa097          	auipc	ra,0xffffa
    80006844:	4f6080e7          	jalr	1270(ra) # 80000d36 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006848:	100017b7          	lui	a5,0x10001
    8000684c:	4721                	li	a4,8
    8000684e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006850:	4098                	lw	a4,0(s1)
    80006852:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006856:	40d8                	lw	a4,4(s1)
    80006858:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000685c:	649c                	ld	a5,8(s1)
    8000685e:	0007869b          	sext.w	a3,a5
    80006862:	10001737          	lui	a4,0x10001
    80006866:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000686a:	9781                	srai	a5,a5,0x20
    8000686c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006870:	689c                	ld	a5,16(s1)
    80006872:	0007869b          	sext.w	a3,a5
    80006876:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000687a:	9781                	srai	a5,a5,0x20
    8000687c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006880:	4785                	li	a5,1
    80006882:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006884:	00f48c23          	sb	a5,24(s1)
    80006888:	00f48ca3          	sb	a5,25(s1)
    8000688c:	00f48d23          	sb	a5,26(s1)
    80006890:	00f48da3          	sb	a5,27(s1)
    80006894:	00f48e23          	sb	a5,28(s1)
    80006898:	00f48ea3          	sb	a5,29(s1)
    8000689c:	00f48f23          	sb	a5,30(s1)
    800068a0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800068a4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068a8:	07272823          	sw	s2,112(a4)
}
    800068ac:	60e2                	ld	ra,24(sp)
    800068ae:	6442                	ld	s0,16(sp)
    800068b0:	64a2                	ld	s1,8(sp)
    800068b2:	6902                	ld	s2,0(sp)
    800068b4:	6105                	addi	sp,sp,32
    800068b6:	8082                	ret
    panic("could not find virtio disk");
    800068b8:	00002517          	auipc	a0,0x2
    800068bc:	e3850513          	addi	a0,a0,-456 # 800086f0 <etext+0x6f0>
    800068c0:	ffffa097          	auipc	ra,0xffffa
    800068c4:	ca0080e7          	jalr	-864(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    800068c8:	00002517          	auipc	a0,0x2
    800068cc:	e4850513          	addi	a0,a0,-440 # 80008710 <etext+0x710>
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	c90080e7          	jalr	-880(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    800068d8:	00002517          	auipc	a0,0x2
    800068dc:	e5850513          	addi	a0,a0,-424 # 80008730 <etext+0x730>
    800068e0:	ffffa097          	auipc	ra,0xffffa
    800068e4:	c80080e7          	jalr	-896(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800068e8:	00002517          	auipc	a0,0x2
    800068ec:	e6850513          	addi	a0,a0,-408 # 80008750 <etext+0x750>
    800068f0:	ffffa097          	auipc	ra,0xffffa
    800068f4:	c70080e7          	jalr	-912(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800068f8:	00002517          	auipc	a0,0x2
    800068fc:	e7850513          	addi	a0,a0,-392 # 80008770 <etext+0x770>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	c60080e7          	jalr	-928(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006908:	00002517          	auipc	a0,0x2
    8000690c:	e8850513          	addi	a0,a0,-376 # 80008790 <etext+0x790>
    80006910:	ffffa097          	auipc	ra,0xffffa
    80006914:	c50080e7          	jalr	-944(ra) # 80000560 <panic>

0000000080006918 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006918:	711d                	addi	sp,sp,-96
    8000691a:	ec86                	sd	ra,88(sp)
    8000691c:	e8a2                	sd	s0,80(sp)
    8000691e:	e4a6                	sd	s1,72(sp)
    80006920:	e0ca                	sd	s2,64(sp)
    80006922:	fc4e                	sd	s3,56(sp)
    80006924:	f852                	sd	s4,48(sp)
    80006926:	f456                	sd	s5,40(sp)
    80006928:	f05a                	sd	s6,32(sp)
    8000692a:	ec5e                	sd	s7,24(sp)
    8000692c:	e862                	sd	s8,16(sp)
    8000692e:	1080                	addi	s0,sp,96
    80006930:	89aa                	mv	s3,a0
    80006932:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006934:	00c52b83          	lw	s7,12(a0)
    80006938:	001b9b9b          	slliw	s7,s7,0x1
    8000693c:	1b82                	slli	s7,s7,0x20
    8000693e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006942:	00023517          	auipc	a0,0x23
    80006946:	6c650513          	addi	a0,a0,1734 # 8002a008 <disk+0x128>
    8000694a:	ffffa097          	auipc	ra,0xffffa
    8000694e:	2f4080e7          	jalr	756(ra) # 80000c3e <acquire>
  for(int i = 0; i < NUM; i++){
    80006952:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006954:	00023a97          	auipc	s5,0x23
    80006958:	58ca8a93          	addi	s5,s5,1420 # 80029ee0 <disk>
  for(int i = 0; i < 3; i++){
    8000695c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    8000695e:	5c7d                	li	s8,-1
    80006960:	a885                	j	800069d0 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006962:	00fa8733          	add	a4,s5,a5
    80006966:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000696a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000696c:	0207c563          	bltz	a5,80006996 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    80006970:	2905                	addiw	s2,s2,1
    80006972:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006974:	07490263          	beq	s2,s4,800069d8 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    80006978:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000697a:	00023717          	auipc	a4,0x23
    8000697e:	56670713          	addi	a4,a4,1382 # 80029ee0 <disk>
    80006982:	4781                	li	a5,0
    if(disk.free[i]){
    80006984:	01874683          	lbu	a3,24(a4)
    80006988:	fee9                	bnez	a3,80006962 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    8000698a:	2785                	addiw	a5,a5,1
    8000698c:	0705                	addi	a4,a4,1
    8000698e:	fe979be3          	bne	a5,s1,80006984 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80006992:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80006996:	03205163          	blez	s2,800069b8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000699a:	fa042503          	lw	a0,-96(s0)
    8000699e:	00000097          	auipc	ra,0x0
    800069a2:	cfc080e7          	jalr	-772(ra) # 8000669a <free_desc>
      for(int j = 0; j < i; j++)
    800069a6:	4785                	li	a5,1
    800069a8:	0127d863          	bge	a5,s2,800069b8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800069ac:	fa442503          	lw	a0,-92(s0)
    800069b0:	00000097          	auipc	ra,0x0
    800069b4:	cea080e7          	jalr	-790(ra) # 8000669a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069b8:	00023597          	auipc	a1,0x23
    800069bc:	65058593          	addi	a1,a1,1616 # 8002a008 <disk+0x128>
    800069c0:	00023517          	auipc	a0,0x23
    800069c4:	53850513          	addi	a0,a0,1336 # 80029ef8 <disk+0x18>
    800069c8:	ffffc097          	auipc	ra,0xffffc
    800069cc:	b8c080e7          	jalr	-1140(ra) # 80002554 <sleep>
  for(int i = 0; i < 3; i++){
    800069d0:	fa040613          	addi	a2,s0,-96
    800069d4:	4901                	li	s2,0
    800069d6:	b74d                	j	80006978 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069d8:	fa042503          	lw	a0,-96(s0)
    800069dc:	00451693          	slli	a3,a0,0x4

  if(write)
    800069e0:	00023797          	auipc	a5,0x23
    800069e4:	50078793          	addi	a5,a5,1280 # 80029ee0 <disk>
    800069e8:	00a50713          	addi	a4,a0,10
    800069ec:	0712                	slli	a4,a4,0x4
    800069ee:	973e                	add	a4,a4,a5
    800069f0:	01603633          	snez	a2,s6
    800069f4:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800069f6:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800069fa:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800069fe:	6398                	ld	a4,0(a5)
    80006a00:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a02:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006a06:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a08:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a0a:	6390                	ld	a2,0(a5)
    80006a0c:	00d605b3          	add	a1,a2,a3
    80006a10:	4741                	li	a4,16
    80006a12:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a14:	4805                	li	a6,1
    80006a16:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006a1a:	fa442703          	lw	a4,-92(s0)
    80006a1e:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a22:	0712                	slli	a4,a4,0x4
    80006a24:	963a                	add	a2,a2,a4
    80006a26:	05898593          	addi	a1,s3,88
    80006a2a:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006a2c:	0007b883          	ld	a7,0(a5)
    80006a30:	9746                	add	a4,a4,a7
    80006a32:	40000613          	li	a2,1024
    80006a36:	c710                	sw	a2,8(a4)
  if(write)
    80006a38:	001b3613          	seqz	a2,s6
    80006a3c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a40:	01066633          	or	a2,a2,a6
    80006a44:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006a48:	fa842583          	lw	a1,-88(s0)
    80006a4c:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a50:	00250613          	addi	a2,a0,2
    80006a54:	0612                	slli	a2,a2,0x4
    80006a56:	963e                	add	a2,a2,a5
    80006a58:	577d                	li	a4,-1
    80006a5a:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006a5e:	0592                	slli	a1,a1,0x4
    80006a60:	98ae                	add	a7,a7,a1
    80006a62:	03068713          	addi	a4,a3,48
    80006a66:	973e                	add	a4,a4,a5
    80006a68:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006a6c:	6398                	ld	a4,0(a5)
    80006a6e:	972e                	add	a4,a4,a1
    80006a70:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a74:	4689                	li	a3,2
    80006a76:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006a7a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a7e:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80006a82:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006a86:	6794                	ld	a3,8(a5)
    80006a88:	0026d703          	lhu	a4,2(a3)
    80006a8c:	8b1d                	andi	a4,a4,7
    80006a8e:	0706                	slli	a4,a4,0x1
    80006a90:	96ba                	add	a3,a3,a4
    80006a92:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006a96:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006a9a:	6798                	ld	a4,8(a5)
    80006a9c:	00275783          	lhu	a5,2(a4)
    80006aa0:	2785                	addiw	a5,a5,1
    80006aa2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006aa6:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006aaa:	100017b7          	lui	a5,0x10001
    80006aae:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006ab2:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006ab6:	00023917          	auipc	s2,0x23
    80006aba:	55290913          	addi	s2,s2,1362 # 8002a008 <disk+0x128>
  while(b->disk == 1) {
    80006abe:	84c2                	mv	s1,a6
    80006ac0:	01079c63          	bne	a5,a6,80006ad8 <virtio_disk_rw+0x1c0>
    sleep(b, &disk.vdisk_lock);
    80006ac4:	85ca                	mv	a1,s2
    80006ac6:	854e                	mv	a0,s3
    80006ac8:	ffffc097          	auipc	ra,0xffffc
    80006acc:	a8c080e7          	jalr	-1396(ra) # 80002554 <sleep>
  while(b->disk == 1) {
    80006ad0:	0049a783          	lw	a5,4(s3)
    80006ad4:	fe9788e3          	beq	a5,s1,80006ac4 <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80006ad8:	fa042903          	lw	s2,-96(s0)
    80006adc:	00290713          	addi	a4,s2,2
    80006ae0:	0712                	slli	a4,a4,0x4
    80006ae2:	00023797          	auipc	a5,0x23
    80006ae6:	3fe78793          	addi	a5,a5,1022 # 80029ee0 <disk>
    80006aea:	97ba                	add	a5,a5,a4
    80006aec:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006af0:	00023997          	auipc	s3,0x23
    80006af4:	3f098993          	addi	s3,s3,1008 # 80029ee0 <disk>
    80006af8:	00491713          	slli	a4,s2,0x4
    80006afc:	0009b783          	ld	a5,0(s3)
    80006b00:	97ba                	add	a5,a5,a4
    80006b02:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b06:	854a                	mv	a0,s2
    80006b08:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b0c:	00000097          	auipc	ra,0x0
    80006b10:	b8e080e7          	jalr	-1138(ra) # 8000669a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b14:	8885                	andi	s1,s1,1
    80006b16:	f0ed                	bnez	s1,80006af8 <virtio_disk_rw+0x1e0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b18:	00023517          	auipc	a0,0x23
    80006b1c:	4f050513          	addi	a0,a0,1264 # 8002a008 <disk+0x128>
    80006b20:	ffffa097          	auipc	ra,0xffffa
    80006b24:	1ce080e7          	jalr	462(ra) # 80000cee <release>
}
    80006b28:	60e6                	ld	ra,88(sp)
    80006b2a:	6446                	ld	s0,80(sp)
    80006b2c:	64a6                	ld	s1,72(sp)
    80006b2e:	6906                	ld	s2,64(sp)
    80006b30:	79e2                	ld	s3,56(sp)
    80006b32:	7a42                	ld	s4,48(sp)
    80006b34:	7aa2                	ld	s5,40(sp)
    80006b36:	7b02                	ld	s6,32(sp)
    80006b38:	6be2                	ld	s7,24(sp)
    80006b3a:	6c42                	ld	s8,16(sp)
    80006b3c:	6125                	addi	sp,sp,96
    80006b3e:	8082                	ret

0000000080006b40 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006b40:	1101                	addi	sp,sp,-32
    80006b42:	ec06                	sd	ra,24(sp)
    80006b44:	e822                	sd	s0,16(sp)
    80006b46:	e426                	sd	s1,8(sp)
    80006b48:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b4a:	00023497          	auipc	s1,0x23
    80006b4e:	39648493          	addi	s1,s1,918 # 80029ee0 <disk>
    80006b52:	00023517          	auipc	a0,0x23
    80006b56:	4b650513          	addi	a0,a0,1206 # 8002a008 <disk+0x128>
    80006b5a:	ffffa097          	auipc	ra,0xffffa
    80006b5e:	0e4080e7          	jalr	228(ra) # 80000c3e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006b62:	100017b7          	lui	a5,0x10001
    80006b66:	53bc                	lw	a5,96(a5)
    80006b68:	8b8d                	andi	a5,a5,3
    80006b6a:	10001737          	lui	a4,0x10001
    80006b6e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006b70:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006b74:	689c                	ld	a5,16(s1)
    80006b76:	0204d703          	lhu	a4,32(s1)
    80006b7a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006b7e:	04f70863          	beq	a4,a5,80006bce <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006b82:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006b86:	6898                	ld	a4,16(s1)
    80006b88:	0204d783          	lhu	a5,32(s1)
    80006b8c:	8b9d                	andi	a5,a5,7
    80006b8e:	078e                	slli	a5,a5,0x3
    80006b90:	97ba                	add	a5,a5,a4
    80006b92:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006b94:	00278713          	addi	a4,a5,2
    80006b98:	0712                	slli	a4,a4,0x4
    80006b9a:	9726                	add	a4,a4,s1
    80006b9c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006ba0:	e721                	bnez	a4,80006be8 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006ba2:	0789                	addi	a5,a5,2
    80006ba4:	0792                	slli	a5,a5,0x4
    80006ba6:	97a6                	add	a5,a5,s1
    80006ba8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006baa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006bae:	ffffc097          	auipc	ra,0xffffc
    80006bb2:	a0a080e7          	jalr	-1526(ra) # 800025b8 <wakeup>

    disk.used_idx += 1;
    80006bb6:	0204d783          	lhu	a5,32(s1)
    80006bba:	2785                	addiw	a5,a5,1
    80006bbc:	17c2                	slli	a5,a5,0x30
    80006bbe:	93c1                	srli	a5,a5,0x30
    80006bc0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006bc4:	6898                	ld	a4,16(s1)
    80006bc6:	00275703          	lhu	a4,2(a4)
    80006bca:	faf71ce3          	bne	a4,a5,80006b82 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006bce:	00023517          	auipc	a0,0x23
    80006bd2:	43a50513          	addi	a0,a0,1082 # 8002a008 <disk+0x128>
    80006bd6:	ffffa097          	auipc	ra,0xffffa
    80006bda:	118080e7          	jalr	280(ra) # 80000cee <release>
}
    80006bde:	60e2                	ld	ra,24(sp)
    80006be0:	6442                	ld	s0,16(sp)
    80006be2:	64a2                	ld	s1,8(sp)
    80006be4:	6105                	addi	sp,sp,32
    80006be6:	8082                	ret
      panic("virtio_disk_intr status");
    80006be8:	00002517          	auipc	a0,0x2
    80006bec:	bc050513          	addi	a0,a0,-1088 # 800087a8 <etext+0x7a8>
    80006bf0:	ffffa097          	auipc	ra,0xffffa
    80006bf4:	970080e7          	jalr	-1680(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
