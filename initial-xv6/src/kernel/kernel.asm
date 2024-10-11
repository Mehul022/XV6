
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a5010113          	addi	sp,sp,-1456 # 80008a50 <stack0>
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
    80000054:	8c078793          	addi	a5,a5,-1856 # 80008910 <timer_scratch>
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
    80000066:	55e78793          	addi	a5,a5,1374 # 800065c0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd486f>
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
    80000138:	874080e7          	jalr	-1932(ra) # 800029a8 <either_copyin>
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
    800001a0:	8b450513          	addi	a0,a0,-1868 # 80010a50 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	a9a080e7          	jalr	-1382(ra) # 80000c3e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	8a448493          	addi	s1,s1,-1884 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011917          	auipc	s2,0x11
    800001b8:	93490913          	addi	s2,s2,-1740 # 80010ae8 <cons+0x98>
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
    800001d8:	602080e7          	jalr	1538(ra) # 800027d6 <killed>
    800001dc:	e52d                	bnez	a0,80000246 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	340080e7          	jalr	832(ra) # 80002522 <sleep>
    while(cons.r == cons.w){
    800001ea:	0984a783          	lw	a5,152(s1)
    800001ee:	09c4a703          	lw	a4,156(s1)
    800001f2:	fcf70de3          	beq	a4,a5,800001cc <consoleread+0x4c>
    800001f6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f8:	00011717          	auipc	a4,0x11
    800001fc:	85870713          	addi	a4,a4,-1960 # 80010a50 <cons>
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
    8000022e:	726080e7          	jalr	1830(ra) # 80002950 <either_copyout>
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
    8000024a:	80a50513          	addi	a0,a0,-2038 # 80010a50 <cons>
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
    80000274:	86f72c23          	sw	a5,-1928(a4) # 80010ae8 <cons+0x98>
    80000278:	6be2                	ld	s7,24(sp)
    8000027a:	a031                	j	80000286 <consoleread+0x106>
    8000027c:	ec5e                	sd	s7,24(sp)
    8000027e:	bfad                	j	800001f8 <consoleread+0x78>
    80000280:	6be2                	ld	s7,24(sp)
    80000282:	a011                	j	80000286 <consoleread+0x106>
    80000284:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000286:	00010517          	auipc	a0,0x10
    8000028a:	7ca50513          	addi	a0,a0,1994 # 80010a50 <cons>
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
    800002f2:	76250513          	addi	a0,a0,1890 # 80010a50 <cons>
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
    80000318:	6ec080e7          	jalr	1772(ra) # 80002a00 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031c:	00010517          	auipc	a0,0x10
    80000320:	73450513          	addi	a0,a0,1844 # 80010a50 <cons>
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
    80000342:	71270713          	addi	a4,a4,1810 # 80010a50 <cons>
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
    8000036c:	6e878793          	addi	a5,a5,1768 # 80010a50 <cons>
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
    80000398:	7547a783          	lw	a5,1876(a5) # 80010ae8 <cons+0x98>
    8000039c:	9f1d                	subw	a4,a4,a5
    8000039e:	08000793          	li	a5,128
    800003a2:	f6f71de3          	bne	a4,a5,8000031c <consoleintr+0x3a>
    800003a6:	a0c9                	j	80000468 <consoleintr+0x186>
    800003a8:	e84a                	sd	s2,16(sp)
    800003aa:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    800003ac:	00010717          	auipc	a4,0x10
    800003b0:	6a470713          	addi	a4,a4,1700 # 80010a50 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	00010497          	auipc	s1,0x10
    800003c0:	69448493          	addi	s1,s1,1684 # 80010a50 <cons>
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
    8000040e:	64670713          	addi	a4,a4,1606 # 80010a50 <cons>
    80000412:	0a072783          	lw	a5,160(a4)
    80000416:	09c72703          	lw	a4,156(a4)
    8000041a:	f0f701e3          	beq	a4,a5,8000031c <consoleintr+0x3a>
      cons.e--;
    8000041e:	37fd                	addiw	a5,a5,-1
    80000420:	00010717          	auipc	a4,0x10
    80000424:	6cf72823          	sw	a5,1744(a4) # 80010af0 <cons+0xa0>
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
    8000044a:	60a78793          	addi	a5,a5,1546 # 80010a50 <cons>
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
    8000046c:	68c7a223          	sw	a2,1668(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00010517          	auipc	a0,0x10
    80000474:	67850513          	addi	a0,a0,1656 # 80010ae8 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	10e080e7          	jalr	270(ra) # 80002586 <wakeup>
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
    80000496:	5be50513          	addi	a0,a0,1470 # 80010a50 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	710080e7          	jalr	1808(ra) # 80000baa <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	344080e7          	jalr	836(ra) # 800007e6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00029797          	auipc	a5,0x29
    800004ae:	94e78793          	addi	a5,a5,-1714 # 80028df8 <devsw>
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
    800004ee:	24680813          	addi	a6,a6,582 # 80008730 <digits>
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
    80000570:	5a07a223          	sw	zero,1444(a5) # 80010b10 <pr+0x18>
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
    800005a4:	32f72823          	sw	a5,816(a4) # 800088d0 <panicked>
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
    800005ce:	546dad83          	lw	s11,1350(s11) # 80010b10 <pr+0x18>
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
    80000610:	124a8a93          	addi	s5,s5,292 # 80008730 <digits>
    switch(c){
    80000614:	07300c13          	li	s8,115
    80000618:	a0b9                	j	80000666 <printf+0xbc>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	4de50513          	addi	a0,a0,1246 # 80010af8 <pr>
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
    800007a6:	35650513          	addi	a0,a0,854 # 80010af8 <pr>
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
    800007c2:	33a48493          	addi	s1,s1,826 # 80010af8 <pr>
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
    8000082c:	2f050513          	addi	a0,a0,752 # 80010b18 <uart_tx_lock>
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
    80000858:	07c7a783          	lw	a5,124(a5) # 800088d0 <panicked>
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
    80000892:	04a7b783          	ld	a5,74(a5) # 800088d8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	04a73703          	ld	a4,74(a4) # 800088e0 <uart_tx_w>
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
    800008c0:	25ca8a93          	addi	s5,s5,604 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	01448493          	addi	s1,s1,20 # 800088d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	01098993          	addi	s3,s3,16 # 800088e0 <uart_tx_w>
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
    800008f6:	c94080e7          	jalr	-876(ra) # 80002586 <wakeup>
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
    80000934:	1e850513          	addi	a0,a0,488 # 80010b18 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	306080e7          	jalr	774(ra) # 80000c3e <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	f907a783          	lw	a5,-112(a5) # 800088d0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	f9673703          	ld	a4,-106(a4) # 800088e0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	f867b783          	ld	a5,-122(a5) # 800088d8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	1ba98993          	addi	s3,s3,442 # 80010b18 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	f7248493          	addi	s1,s1,-142 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	f7290913          	addi	s2,s2,-142 # 800088e0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	ba4080e7          	jalr	-1116(ra) # 80002522 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	18448493          	addi	s1,s1,388 # 80010b18 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f2e7bc23          	sd	a4,-200(a5) # 800088e0 <uart_tx_w>
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
    80000a22:	0fa48493          	addi	s1,s1,250 # 80010b18 <uart_tx_lock>
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
    80000a64:	53078793          	addi	a5,a5,1328 # 80029f90 <end>
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
    80000a84:	0d090913          	addi	s2,s2,208 # 80010b50 <kmem>
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
    80000b22:	03250513          	addi	a0,a0,50 # 80010b50 <kmem>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	084080e7          	jalr	132(ra) # 80000baa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2e:	45c5                	li	a1,17
    80000b30:	05ee                	slli	a1,a1,0x1b
    80000b32:	00029517          	auipc	a0,0x29
    80000b36:	45e50513          	addi	a0,a0,1118 # 80029f90 <end>
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
    80000b58:	ffc48493          	addi	s1,s1,-4 # 80010b50 <kmem>
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
    80000b70:	fe450513          	addi	a0,a0,-28 # 80010b50 <kmem>
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
    80000b9c:	fb850513          	addi	a0,a0,-72 # 80010b50 <kmem>
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
    80000db4:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5071>
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
    80000f04:	9e870713          	addi	a4,a4,-1560 # 800088e8 <started>
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
    80000f3a:	db0080e7          	jalr	-592(ra) # 80002ce6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	6c6080e7          	jalr	1734(ra) # 80006604 <plicinithart>
  }

  scheduler();        
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	4aa080e7          	jalr	1194(ra) # 800023f0 <scheduler>
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
    80000fb2:	d10080e7          	jalr	-752(ra) # 80002cbe <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb6:	00002097          	auipc	ra,0x2
    80000fba:	d30080e7          	jalr	-720(ra) # 80002ce6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fbe:	00005097          	auipc	ra,0x5
    80000fc2:	62c080e7          	jalr	1580(ra) # 800065ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc6:	00005097          	auipc	ra,0x5
    80000fca:	63e080e7          	jalr	1598(ra) # 80006604 <plicinithart>
    binit();         // buffer cache
    80000fce:	00002097          	auipc	ra,0x2
    80000fd2:	6b0080e7          	jalr	1712(ra) # 8000367e <binit>
    iinit();         // inode table
    80000fd6:	00003097          	auipc	ra,0x3
    80000fda:	d40080e7          	jalr	-704(ra) # 80003d16 <iinit>
    fileinit();      // file table
    80000fde:	00004097          	auipc	ra,0x4
    80000fe2:	d12080e7          	jalr	-750(ra) # 80004cf0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe6:	00005097          	auipc	ra,0x5
    80000fea:	726080e7          	jalr	1830(ra) # 8000670c <virtio_disk_init>
    userinit();      // first user process
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	df6080e7          	jalr	-522(ra) # 80001de4 <userinit>
    __sync_synchronize();
    80000ff6:	0330000f          	fence	rw,rw
    started = 1;
    80000ffa:	4785                	li	a5,1
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	8ef72623          	sw	a5,-1812(a4) # 800088e8 <started>
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
    80001016:	8de7b783          	ld	a5,-1826(a5) # 800088f0 <kernel_pagetable>
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
    800012d4:	62a7b023          	sd	a0,1568(a5) # 800088f0 <kernel_pagetable>
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
    800018ac:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5070>
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
    800018ec:	ec848493          	addi	s1,s1,-312 # 800117b0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018f0:	8c26                	mv	s8,s1
    800018f2:	8c1357b7          	lui	a5,0x8c135
    800018f6:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b28d>
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
    80001916:	29ea8a93          	addi	s5,s5,670 # 8001ebb0 <tickslock>
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
    80001984:	ef868693          	addi	a3,a3,-264 # 80008878 <seed.2>
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
    800019de:	19650513          	addi	a0,a0,406 # 80010b70 <pid_lock>
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	1c8080e7          	jalr	456(ra) # 80000baa <initlock>
  initlock(&wait_lock, "wait_lock");
    800019ea:	00006597          	auipc	a1,0x6
    800019ee:	7de58593          	addi	a1,a1,2014 # 800081c8 <etext+0x1c8>
    800019f2:	0000f517          	auipc	a0,0xf
    800019f6:	19650513          	addi	a0,a0,406 # 80010b88 <wait_lock>
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	1b0080e7          	jalr	432(ra) # 80000baa <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a02:	00010497          	auipc	s1,0x10
    80001a06:	dae48493          	addi	s1,s1,-594 # 800117b0 <proc>
  {
    initlock(&p->lock, "proc");
    80001a0a:	00006b17          	auipc	s6,0x6
    80001a0e:	7ceb0b13          	addi	s6,s6,1998 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a12:	8aa6                	mv	s5,s1
    80001a14:	8c1357b7          	lui	a5,0x8c135
    80001a18:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b28d>
    80001a1c:	21cfb937          	lui	s2,0x21cfb
    80001a20:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001a24:	1902                	slli	s2,s2,0x20
    80001a26:	993e                	add	s2,s2,a5
    80001a28:	040009b7          	lui	s3,0x4000
    80001a2c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a2e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a30:	0001da17          	auipc	s4,0x1d
    80001a34:	180a0a13          	addi	s4,s4,384 # 8001ebb0 <tickslock>
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
    80001aa2:	10250513          	addi	a0,a0,258 # 80010ba0 <cpus>
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
    80001acc:	0a870713          	addi	a4,a4,168 # 80010b70 <pid_lock>
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
    80001b04:	d707a783          	lw	a5,-656(a5) # 80008870 <first.1>
    80001b08:	eb89                	bnez	a5,80001b1a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b0a:	00001097          	auipc	ra,0x1
    80001b0e:	1f8080e7          	jalr	504(ra) # 80002d02 <usertrapret>
}
    80001b12:	60a2                	ld	ra,8(sp)
    80001b14:	6402                	ld	s0,0(sp)
    80001b16:	0141                	addi	sp,sp,16
    80001b18:	8082                	ret
    first = 0;
    80001b1a:	00007797          	auipc	a5,0x7
    80001b1e:	d407ab23          	sw	zero,-682(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001b22:	4505                	li	a0,1
    80001b24:	00002097          	auipc	ra,0x2
    80001b28:	172080e7          	jalr	370(ra) # 80003c96 <fsinit>
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
    80001b3e:	03690913          	addi	s2,s2,54 # 80010b70 <pid_lock>
    80001b42:	854a                	mv	a0,s2
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	0fa080e7          	jalr	250(ra) # 80000c3e <acquire>
  pid = nextpid;
    80001b4c:	00007797          	auipc	a5,0x7
    80001b50:	d3478793          	addi	a5,a5,-716 # 80008880 <nextpid>
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
    80001ce2:	ad248493          	addi	s1,s1,-1326 # 800117b0 <proc>
    80001ce6:	0001d917          	auipc	s2,0x1d
    80001cea:	eca90913          	addi	s2,s2,-310 # 8001ebb0 <tickslock>
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
    80001d78:	b907a783          	lw	a5,-1136(a5) # 80008904 <ticks>
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
    80001dfc:	b0a7b023          	sd	a0,-1280(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e00:	03400613          	li	a2,52
    80001e04:	00007597          	auipc	a1,0x7
    80001e08:	a8c58593          	addi	a1,a1,-1396 # 80008890 <initcode>
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
    80001e4e:	8b4080e7          	jalr	-1868(ra) # 800046fe <namei>
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
    80001f8a:	dfc080e7          	jalr	-516(ra) # 80004d82 <filedup>
    80001f8e:	00a93023          	sd	a0,0(s2)
    80001f92:	b7e5                	j	80001f7a <fork+0xa8>
  np->cwd = idup(p->cwd);
    80001f94:	328ab503          	ld	a0,808(s5)
    80001f98:	00002097          	auipc	ra,0x2
    80001f9c:	f44080e7          	jalr	-188(ra) # 80003edc <idup>
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
    80001fd0:	bbc48493          	addi	s1,s1,-1092 # 80010b88 <wait_lock>
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
    80002072:	b0270713          	addi	a4,a4,-1278 # 80010b70 <pid_lock>
    80002076:	975e                	add	a4,a4,s7
    80002078:	02073823          	sd	zero,48(a4)
    swtch(&c->context, &selected_proc->context);
    8000207c:	0000f717          	auipc	a4,0xf
    80002080:	b2c70713          	addi	a4,a4,-1236 # 80010ba8 <cpus+0x8>
    80002084:	9bba                	add	s7,s7,a4
    if (boost_ticks >= BOOST_INTERVAL)
    80002086:	00007a17          	auipc	s4,0x7
    8000208a:	87aa0a13          	addi	s4,s4,-1926 # 80008900 <boost_ticks>
    for (p = proc; p < &proc[NPROC]; p++)
    8000208e:	0001d917          	auipc	s2,0x1d
    80002092:	b2290913          	addi	s2,s2,-1246 # 8001ebb0 <tickslock>
    c->proc = selected_proc;
    80002096:	079e                	slli	a5,a5,0x7
    80002098:	0000fb17          	auipc	s6,0xf
    8000209c:	ad8b0b13          	addi	s6,s6,-1320 # 80010b70 <pid_lock>
    800020a0:	9b3e                	add	s6,s6,a5
    800020a2:	aa21                	j	800021ba <scheduler_mlfq+0x16e>
      for (p = proc; p < &proc[NPROC]; p++)
    800020a4:	0000f497          	auipc	s1,0xf
    800020a8:	70c48493          	addi	s1,s1,1804 # 800117b0 <proc>
        if (p->state == RUNNABLE)
    800020ac:	4c0d                	li	s8,3
          p->arrival_time = ticks;
    800020ae:	00007c97          	auipc	s9,0x7
    800020b2:	856c8c93          	addi	s9,s9,-1962 # 80008904 <ticks>
    800020b6:	a029                	j	800020c0 <scheduler_mlfq+0x74>
      for (p = proc; p < &proc[NPROC]; p++)
    800020b8:	35048493          	addi	s1,s1,848
    800020bc:	03248763          	beq	s1,s2,800020ea <scheduler_mlfq+0x9e>
        if (p->state == RUNNABLE)
    800020c0:	4c9c                	lw	a5,24(s1)
    800020c2:	ff879be3          	bne	a5,s8,800020b8 <scheduler_mlfq+0x6c>
          acquire(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	b76080e7          	jalr	-1162(ra) # 80000c3e <acquire>
          p->arrival_time = ticks;
    800020d0:	000ce783          	lwu	a5,0(s9)
    800020d4:	e4fc                	sd	a5,200(s1)
          p->ticks=0;
    800020d6:	0e04a023          	sw	zero,224(s1)
          p->priority = 0;
    800020da:	0c04ac23          	sw	zero,216(s1)
          release(&p->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	c0e080e7          	jalr	-1010(ra) # 80000cee <release>
    800020e8:	bfc1                	j	800020b8 <scheduler_mlfq+0x6c>
      boost_ticks = 0;
    800020ea:	000a2023          	sw	zero,0(s4)
    800020ee:	a0dd                	j	800021d4 <scheduler_mlfq+0x188>
        if (selected_proc == 0)
    800020f0:	cc89                	beqz	s1,8000210a <scheduler_mlfq+0xbe>
        else if (p->priority < min)
    800020f2:	0d87a703          	lw	a4,216(a5)
    800020f6:	04d74d63          	blt	a4,a3,80002150 <scheduler_mlfq+0x104>
        else if (p->priority == min && p->arrival_time < selected_proc->arrival_time)
    800020fa:	04d71d63          	bne	a4,a3,80002154 <scheduler_mlfq+0x108>
    800020fe:	67f0                	ld	a2,200(a5)
    80002100:	64f8                	ld	a4,200(s1)
    80002102:	04e67963          	bgeu	a2,a4,80002154 <scheduler_mlfq+0x108>
          selected_proc = p;
    80002106:	84be                	mv	s1,a5
    80002108:	a0b1                	j	80002154 <scheduler_mlfq+0x108>
          min = selected_proc->priority;
    8000210a:	0d87a683          	lw	a3,216(a5)
          selected_proc = p;
    8000210e:	84be                	mv	s1,a5
    80002110:	a091                	j	80002154 <scheduler_mlfq+0x108>
      release(&selected_proc->lock);
    80002112:	8526                	mv	a0,s1
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	bda080e7          	jalr	-1062(ra) # 80000cee <release>
      continue;
    8000211c:	a879                	j	800021ba <scheduler_mlfq+0x16e>
      if (selected_proc->ticks >= time_slice)
    8000211e:	0e04ac03          	lw	s8,224(s1)
    int time_slice = get_time_slice(selected_proc->priority);
    80002122:	8556                	mv	a0,s5
    80002124:	00000097          	auipc	ra,0x0
    80002128:	efa080e7          	jalr	-262(ra) # 8000201e <get_time_slice>
      if (selected_proc->ticks >= time_slice)
    8000212c:	06ac4b63          	blt	s8,a0,800021a2 <scheduler_mlfq+0x156>
        if (selected_proc->priority < MAX_PRIORITY)
    80002130:	0d84a783          	lw	a5,216(s1)
    80002134:	4709                	li	a4,2
    80002136:	00f74a63          	blt	a4,a5,8000214a <scheduler_mlfq+0xfe>
          selected_proc->priority++;
    8000213a:	2785                	addiw	a5,a5,1
    8000213c:	0cf4ac23          	sw	a5,216(s1)
          selected_proc->arrival_time=ticks;
    80002140:	00006797          	auipc	a5,0x6
    80002144:	7c47e783          	lwu	a5,1988(a5) # 80008904 <ticks>
    80002148:	e4fc                	sd	a5,200(s1)
        selected_proc->ticks = 0;
    8000214a:	0e04a023          	sw	zero,224(s1)
    8000214e:	a891                	j	800021a2 <scheduler_mlfq+0x156>
          min = selected_proc->priority;
    80002150:	86ba                	mv	a3,a4
          selected_proc = p;
    80002152:	84be                	mv	s1,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002154:	35078793          	addi	a5,a5,848
    80002158:	01278a63          	beq	a5,s2,8000216c <scheduler_mlfq+0x120>
      if (p->state == RUNNABLE)
    8000215c:	4f98                	lw	a4,24(a5)
    8000215e:	f93709e3          	beq	a4,s3,800020f0 <scheduler_mlfq+0xa4>
    for (p = proc; p < &proc[NPROC]; p++)
    80002162:	35078793          	addi	a5,a5,848
    80002166:	ff279be3          	bne	a5,s2,8000215c <scheduler_mlfq+0x110>
    if (!selected_proc)
    8000216a:	c8b9                	beqz	s1,800021c0 <scheduler_mlfq+0x174>
    acquire(&selected_proc->lock);
    8000216c:	89a6                	mv	s3,s1
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	ace080e7          	jalr	-1330(ra) # 80000c3e <acquire>
    if (selected_proc->state != RUNNABLE)
    80002178:	4c98                	lw	a4,24(s1)
    8000217a:	478d                	li	a5,3
    8000217c:	f8f71be3          	bne	a4,a5,80002112 <scheduler_mlfq+0xc6>
    selected_proc->state = RUNNING;
    80002180:	4791                	li	a5,4
    80002182:	cc9c                	sw	a5,24(s1)
    c->proc = selected_proc;
    80002184:	029b3823          	sd	s1,48(s6)
    int time_slice = get_time_slice(selected_proc->priority);
    80002188:	0d84aa83          	lw	s5,216(s1)
    swtch(&c->context, &selected_proc->context);
    8000218c:	23848593          	addi	a1,s1,568
    80002190:	855e                	mv	a0,s7
    80002192:	00001097          	auipc	ra,0x1
    80002196:	ac2080e7          	jalr	-1342(ra) # 80002c54 <swtch>
    if (selected_proc->state == RUNNABLE)
    8000219a:	4c98                	lw	a4,24(s1)
    8000219c:	478d                	li	a5,3
    8000219e:	f8f700e3          	beq	a4,a5,8000211e <scheduler_mlfq+0xd2>
    c->proc = 0;
    800021a2:	020b3823          	sd	zero,48(s6)
    release(&selected_proc->lock);
    800021a6:	854e                	mv	a0,s3
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	b46080e7          	jalr	-1210(ra) # 80000cee <release>
    boost_ticks++;
    800021b0:	000a2783          	lw	a5,0(s4)
    800021b4:	2785                	addiw	a5,a5,1
    800021b6:	00fa2023          	sw	a5,0(s4)
    if (boost_ticks >= BOOST_INTERVAL)
    800021ba:	02f00a93          	li	s5,47
    int min=3;
    800021be:	498d                	li	s3,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021c4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021c8:	10079073          	csrw	sstatus,a5
    if (boost_ticks >= BOOST_INTERVAL)
    800021cc:	000a2783          	lw	a5,0(s4)
    800021d0:	ecfacae3          	blt	s5,a5,800020a4 <scheduler_mlfq+0x58>
    int min=3;
    800021d4:	86ce                	mv	a3,s3
    struct proc *selected_proc = 0;
    800021d6:	4481                	li	s1,0
    for (p = proc; p < &proc[NPROC]; p++)
    800021d8:	0000f797          	auipc	a5,0xf
    800021dc:	5d878793          	addi	a5,a5,1496 # 800117b0 <proc>
    800021e0:	bfb5                	j	8000215c <scheduler_mlfq+0x110>

00000000800021e2 <scheduler_rr>:
{
    800021e2:	7139                	addi	sp,sp,-64
    800021e4:	fc06                	sd	ra,56(sp)
    800021e6:	f822                	sd	s0,48(sp)
    800021e8:	f426                	sd	s1,40(sp)
    800021ea:	f04a                	sd	s2,32(sp)
    800021ec:	ec4e                	sd	s3,24(sp)
    800021ee:	e852                	sd	s4,16(sp)
    800021f0:	e456                	sd	s5,8(sp)
    800021f2:	e05a                	sd	s6,0(sp)
    800021f4:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    800021f6:	8792                	mv	a5,tp
  int id = r_tp();
    800021f8:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021fa:	00779a93          	slli	s5,a5,0x7
    800021fe:	0000f717          	auipc	a4,0xf
    80002202:	97270713          	addi	a4,a4,-1678 # 80010b70 <pid_lock>
    80002206:	9756                	add	a4,a4,s5
    80002208:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000220c:	0000f717          	auipc	a4,0xf
    80002210:	99c70713          	addi	a4,a4,-1636 # 80010ba8 <cpus+0x8>
    80002214:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80002216:	498d                	li	s3,3
        p->state = RUNNING;
    80002218:	4b11                	li	s6,4
        c->proc = p;
    8000221a:	079e                	slli	a5,a5,0x7
    8000221c:	0000fa17          	auipc	s4,0xf
    80002220:	954a0a13          	addi	s4,s4,-1708 # 80010b70 <pid_lock>
    80002224:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002226:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000222a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000222e:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002232:	0000f497          	auipc	s1,0xf
    80002236:	57e48493          	addi	s1,s1,1406 # 800117b0 <proc>
    8000223a:	0001d917          	auipc	s2,0x1d
    8000223e:	97690913          	addi	s2,s2,-1674 # 8001ebb0 <tickslock>
    80002242:	a811                	j	80002256 <scheduler_rr+0x74>
      release(&p->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	aa8080e7          	jalr	-1368(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000224e:	35048493          	addi	s1,s1,848
    80002252:	fd248ae3          	beq	s1,s2,80002226 <scheduler_rr+0x44>
      acquire(&p->lock);
    80002256:	8526                	mv	a0,s1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	9e6080e7          	jalr	-1562(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    80002260:	4c9c                	lw	a5,24(s1)
    80002262:	ff3791e3          	bne	a5,s3,80002244 <scheduler_rr+0x62>
        p->state = RUNNING;
    80002266:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000226a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000226e:	23848593          	addi	a1,s1,568
    80002272:	8556                	mv	a0,s5
    80002274:	00001097          	auipc	ra,0x1
    80002278:	9e0080e7          	jalr	-1568(ra) # 80002c54 <swtch>
        c->proc = 0;
    8000227c:	020a3823          	sd	zero,48(s4)
    80002280:	b7d1                	j	80002244 <scheduler_rr+0x62>

0000000080002282 <scheduler_lottery>:
{
    80002282:	715d                	addi	sp,sp,-80
    80002284:	e486                	sd	ra,72(sp)
    80002286:	e0a2                	sd	s0,64(sp)
    80002288:	fc26                	sd	s1,56(sp)
    8000228a:	f84a                	sd	s2,48(sp)
    8000228c:	f44e                	sd	s3,40(sp)
    8000228e:	f052                	sd	s4,32(sp)
    80002290:	ec56                	sd	s5,24(sp)
    80002292:	e85a                	sd	s6,16(sp)
    80002294:	e45e                	sd	s7,8(sp)
    80002296:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80002298:	8792                	mv	a5,tp
  int id = r_tp();
    8000229a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000229c:	00779693          	slli	a3,a5,0x7
    800022a0:	0000f717          	auipc	a4,0xf
    800022a4:	8d070713          	addi	a4,a4,-1840 # 80010b70 <pid_lock>
    800022a8:	9736                	add	a4,a4,a3
    800022aa:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &selected_proc->context);
    800022ae:	0000f717          	auipc	a4,0xf
    800022b2:	8fa70713          	addi	a4,a4,-1798 # 80010ba8 <cpus+0x8>
    800022b6:	9736                	add	a4,a4,a3
    800022b8:	8bba                	mv	s7,a4
      if (p->state == RUNNABLE)
    800022ba:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    800022bc:	0001d917          	auipc	s2,0x1d
    800022c0:	8f490913          	addi	s2,s2,-1804 # 8001ebb0 <tickslock>
        c->proc = selected_proc;
    800022c4:	0000fa97          	auipc	s5,0xf
    800022c8:	8aca8a93          	addi	s5,s5,-1876 # 80010b70 <pid_lock>
    800022cc:	9ab6                	add	s5,s5,a3
    800022ce:	a80d                	j	80002300 <scheduler_lottery+0x7e>
      release(&p->lock);
    800022d0:	8526                	mv	a0,s1
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	a1c080e7          	jalr	-1508(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800022da:	35048493          	addi	s1,s1,848
    800022de:	01248f63          	beq	s1,s2,800022fc <scheduler_lottery+0x7a>
      acquire(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	95a080e7          	jalr	-1702(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    800022ec:	4c9c                	lw	a5,24(s1)
    800022ee:	ff3791e3          	bne	a5,s3,800022d0 <scheduler_lottery+0x4e>
        total_tickets += p->tickets;
    800022f2:	0c04a783          	lw	a5,192(s1)
    800022f6:	01678b3b          	addw	s6,a5,s6
    800022fa:	bfd9                	j	800022d0 <scheduler_lottery+0x4e>
    if (total_tickets == 0)
    800022fc:	000b1e63          	bnez	s6,80002318 <scheduler_lottery+0x96>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002300:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002304:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002308:	10079073          	csrw	sstatus,a5
    total_tickets = 0;
    8000230c:	4b01                	li	s6,0
    for (p = proc; p < &proc[NPROC]; p++)
    8000230e:	0000f497          	auipc	s1,0xf
    80002312:	4a248493          	addi	s1,s1,1186 # 800117b0 <proc>
    80002316:	b7f1                	j	800022e2 <scheduler_lottery+0x60>
    int winning_ticket = rand() % total_tickets;
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	660080e7          	jalr	1632(ra) # 80001978 <rand>
    80002320:	03657b33          	remu	s6,a0,s6
    80002324:	2b01                	sext.w	s6,s6
    int current_ticket = 0;
    80002326:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002328:	0000f497          	auipc	s1,0xf
    8000232c:	48848493          	addi	s1,s1,1160 # 800117b0 <proc>
    80002330:	a811                	j	80002344 <scheduler_lottery+0xc2>
      release(&p->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	9ba080e7          	jalr	-1606(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000233c:	35048493          	addi	s1,s1,848
    80002340:	fd2480e3          	beq	s1,s2,80002300 <scheduler_lottery+0x7e>
      acquire(&p->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	8f8080e7          	jalr	-1800(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    8000234e:	4c9c                	lw	a5,24(s1)
    80002350:	ff3791e3          	bne	a5,s3,80002332 <scheduler_lottery+0xb0>
        current_ticket += p->tickets;
    80002354:	0c04a783          	lw	a5,192(s1)
    80002358:	01478a3b          	addw	s4,a5,s4
        if (current_ticket > winning_ticket)
    8000235c:	fd4b5be3          	bge	s6,s4,80002332 <scheduler_lottery+0xb0>
          release(&p->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	98c080e7          	jalr	-1652(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    8000236a:	0000fa17          	auipc	s4,0xf
    8000236e:	446a0a13          	addi	s4,s4,1094 # 800117b0 <proc>
    80002372:	a811                	j	80002386 <scheduler_lottery+0x104>
          release(&p->lock);
    80002374:	8552                	mv	a0,s4
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	978080e7          	jalr	-1672(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    8000237e:	350a0a13          	addi	s4,s4,848
    80002382:	032a0a63          	beq	s4,s2,800023b6 <scheduler_lottery+0x134>
        if (p != selected_proc)
    80002386:	fe9a0ce3          	beq	s4,s1,8000237e <scheduler_lottery+0xfc>
          acquire(&p->lock);
    8000238a:	8552                	mv	a0,s4
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	8b2080e7          	jalr	-1870(ra) # 80000c3e <acquire>
          if (p->state == RUNNABLE && p->tickets == selected_proc->tickets && p->arrival_time < selected_proc->arrival_time)
    80002394:	018a2783          	lw	a5,24(s4)
    80002398:	fd379ee3          	bne	a5,s3,80002374 <scheduler_lottery+0xf2>
    8000239c:	0c0a2703          	lw	a4,192(s4)
    800023a0:	0c04a783          	lw	a5,192(s1)
    800023a4:	fcf718e3          	bne	a4,a5,80002374 <scheduler_lottery+0xf2>
    800023a8:	0c8a3703          	ld	a4,200(s4)
    800023ac:	64fc                	ld	a5,200(s1)
    800023ae:	fcf773e3          	bgeu	a4,a5,80002374 <scheduler_lottery+0xf2>
            selected_proc = p;
    800023b2:	84d2                	mv	s1,s4
    800023b4:	b7c1                	j	80002374 <scheduler_lottery+0xf2>
      acquire(&selected_proc->lock);
    800023b6:	8a26                	mv	s4,s1
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	884080e7          	jalr	-1916(ra) # 80000c3e <acquire>
      if (selected_proc->state == RUNNABLE)
    800023c2:	4c9c                	lw	a5,24(s1)
    800023c4:	01378863          	beq	a5,s3,800023d4 <scheduler_lottery+0x152>
      release(&selected_proc->lock);
    800023c8:	8552                	mv	a0,s4
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	924080e7          	jalr	-1756(ra) # 80000cee <release>
    800023d2:	b73d                	j	80002300 <scheduler_lottery+0x7e>
        selected_proc->state = RUNNING;
    800023d4:	4791                	li	a5,4
    800023d6:	cc9c                	sw	a5,24(s1)
        c->proc = selected_proc;
    800023d8:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &selected_proc->context);
    800023dc:	23848593          	addi	a1,s1,568
    800023e0:	855e                	mv	a0,s7
    800023e2:	00001097          	auipc	ra,0x1
    800023e6:	872080e7          	jalr	-1934(ra) # 80002c54 <swtch>
        c->proc = 0;
    800023ea:	020ab823          	sd	zero,48(s5)
    800023ee:	bfe9                	j	800023c8 <scheduler_lottery+0x146>

00000000800023f0 <scheduler>:
{
    800023f0:	1141                	addi	sp,sp,-16
    800023f2:	e406                	sd	ra,8(sp)
    800023f4:	e022                	sd	s0,0(sp)
    800023f6:	0800                	addi	s0,sp,16
      printf("LBS");
    800023f8:	00006517          	auipc	a0,0x6
    800023fc:	e0050513          	addi	a0,a0,-512 # 800081f8 <etext+0x1f8>
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	1aa080e7          	jalr	426(ra) # 800005aa <printf>
      scheduler_lottery();
    80002408:	00000097          	auipc	ra,0x0
    8000240c:	e7a080e7          	jalr	-390(ra) # 80002282 <scheduler_lottery>

0000000080002410 <sched>:
{
    80002410:	7179                	addi	sp,sp,-48
    80002412:	f406                	sd	ra,40(sp)
    80002414:	f022                	sd	s0,32(sp)
    80002416:	ec26                	sd	s1,24(sp)
    80002418:	e84a                	sd	s2,16(sp)
    8000241a:	e44e                	sd	s3,8(sp)
    8000241c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	692080e7          	jalr	1682(ra) # 80001ab0 <myproc>
    80002426:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002428:	ffffe097          	auipc	ra,0xffffe
    8000242c:	79c080e7          	jalr	1948(ra) # 80000bc4 <holding>
    80002430:	c93d                	beqz	a0,800024a6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002432:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002434:	2781                	sext.w	a5,a5
    80002436:	079e                	slli	a5,a5,0x7
    80002438:	0000e717          	auipc	a4,0xe
    8000243c:	73870713          	addi	a4,a4,1848 # 80010b70 <pid_lock>
    80002440:	97ba                	add	a5,a5,a4
    80002442:	0a87a703          	lw	a4,168(a5)
    80002446:	4785                	li	a5,1
    80002448:	06f71763          	bne	a4,a5,800024b6 <sched+0xa6>
  if (p->state == RUNNING)
    8000244c:	4c98                	lw	a4,24(s1)
    8000244e:	4791                	li	a5,4
    80002450:	06f70b63          	beq	a4,a5,800024c6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002454:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002458:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000245a:	efb5                	bnez	a5,800024d6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000245c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000245e:	0000e917          	auipc	s2,0xe
    80002462:	71290913          	addi	s2,s2,1810 # 80010b70 <pid_lock>
    80002466:	2781                	sext.w	a5,a5
    80002468:	079e                	slli	a5,a5,0x7
    8000246a:	97ca                	add	a5,a5,s2
    8000246c:	0ac7a983          	lw	s3,172(a5)
    80002470:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002472:	2781                	sext.w	a5,a5
    80002474:	079e                	slli	a5,a5,0x7
    80002476:	0000e597          	auipc	a1,0xe
    8000247a:	73258593          	addi	a1,a1,1842 # 80010ba8 <cpus+0x8>
    8000247e:	95be                	add	a1,a1,a5
    80002480:	23848513          	addi	a0,s1,568
    80002484:	00000097          	auipc	ra,0x0
    80002488:	7d0080e7          	jalr	2000(ra) # 80002c54 <swtch>
    8000248c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000248e:	2781                	sext.w	a5,a5
    80002490:	079e                	slli	a5,a5,0x7
    80002492:	993e                	add	s2,s2,a5
    80002494:	0b392623          	sw	s3,172(s2)
}
    80002498:	70a2                	ld	ra,40(sp)
    8000249a:	7402                	ld	s0,32(sp)
    8000249c:	64e2                	ld	s1,24(sp)
    8000249e:	6942                	ld	s2,16(sp)
    800024a0:	69a2                	ld	s3,8(sp)
    800024a2:	6145                	addi	sp,sp,48
    800024a4:	8082                	ret
    panic("sched p->lock");
    800024a6:	00006517          	auipc	a0,0x6
    800024aa:	d5a50513          	addi	a0,a0,-678 # 80008200 <etext+0x200>
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	0b2080e7          	jalr	178(ra) # 80000560 <panic>
    panic("sched locks");
    800024b6:	00006517          	auipc	a0,0x6
    800024ba:	d5a50513          	addi	a0,a0,-678 # 80008210 <etext+0x210>
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	0a2080e7          	jalr	162(ra) # 80000560 <panic>
    panic("sched running");
    800024c6:	00006517          	auipc	a0,0x6
    800024ca:	d5a50513          	addi	a0,a0,-678 # 80008220 <etext+0x220>
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	092080e7          	jalr	146(ra) # 80000560 <panic>
    panic("sched interruptible");
    800024d6:	00006517          	auipc	a0,0x6
    800024da:	d5a50513          	addi	a0,a0,-678 # 80008230 <etext+0x230>
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	082080e7          	jalr	130(ra) # 80000560 <panic>

00000000800024e6 <yield>:
{
    800024e6:	1101                	addi	sp,sp,-32
    800024e8:	ec06                	sd	ra,24(sp)
    800024ea:	e822                	sd	s0,16(sp)
    800024ec:	e426                	sd	s1,8(sp)
    800024ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	5c0080e7          	jalr	1472(ra) # 80001ab0 <myproc>
    800024f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	744080e7          	jalr	1860(ra) # 80000c3e <acquire>
  p->state = RUNNABLE;
    80002502:	478d                	li	a5,3
    80002504:	cc9c                	sw	a5,24(s1)
  sched();
    80002506:	00000097          	auipc	ra,0x0
    8000250a:	f0a080e7          	jalr	-246(ra) # 80002410 <sched>
  release(&p->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	7de080e7          	jalr	2014(ra) # 80000cee <release>
}
    80002518:	60e2                	ld	ra,24(sp)
    8000251a:	6442                	ld	s0,16(sp)
    8000251c:	64a2                	ld	s1,8(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret

0000000080002522 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	1800                	addi	s0,sp,48
    80002530:	89aa                	mv	s3,a0
    80002532:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	57c080e7          	jalr	1404(ra) # 80001ab0 <myproc>
    8000253c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000253e:	ffffe097          	auipc	ra,0xffffe
    80002542:	700080e7          	jalr	1792(ra) # 80000c3e <acquire>
  release(lk);
    80002546:	854a                	mv	a0,s2
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	7a6080e7          	jalr	1958(ra) # 80000cee <release>

  // Go to sleep.
  p->chan = chan;
    80002550:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002554:	4789                	li	a5,2
    80002556:	cc9c                	sw	a5,24(s1)

  sched();
    80002558:	00000097          	auipc	ra,0x0
    8000255c:	eb8080e7          	jalr	-328(ra) # 80002410 <sched>

  // Tidy up.
  p->chan = 0;
    80002560:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	788080e7          	jalr	1928(ra) # 80000cee <release>
  acquire(lk);
    8000256e:	854a                	mv	a0,s2
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	6ce080e7          	jalr	1742(ra) # 80000c3e <acquire>
}
    80002578:	70a2                	ld	ra,40(sp)
    8000257a:	7402                	ld	s0,32(sp)
    8000257c:	64e2                	ld	s1,24(sp)
    8000257e:	6942                	ld	s2,16(sp)
    80002580:	69a2                	ld	s3,8(sp)
    80002582:	6145                	addi	sp,sp,48
    80002584:	8082                	ret

0000000080002586 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002586:	7139                	addi	sp,sp,-64
    80002588:	fc06                	sd	ra,56(sp)
    8000258a:	f822                	sd	s0,48(sp)
    8000258c:	f426                	sd	s1,40(sp)
    8000258e:	f04a                	sd	s2,32(sp)
    80002590:	ec4e                	sd	s3,24(sp)
    80002592:	e852                	sd	s4,16(sp)
    80002594:	e456                	sd	s5,8(sp)
    80002596:	0080                	addi	s0,sp,64
    80002598:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000259a:	0000f497          	auipc	s1,0xf
    8000259e:	21648493          	addi	s1,s1,534 # 800117b0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800025a2:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800025a4:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800025a6:	0001c917          	auipc	s2,0x1c
    800025aa:	60a90913          	addi	s2,s2,1546 # 8001ebb0 <tickslock>
    800025ae:	a811                	j	800025c2 <wakeup+0x3c>
      }
      release(&p->lock);
    800025b0:	8526                	mv	a0,s1
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	73c080e7          	jalr	1852(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025ba:	35048493          	addi	s1,s1,848
    800025be:	03248663          	beq	s1,s2,800025ea <wakeup+0x64>
    if (p != myproc())
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	4ee080e7          	jalr	1262(ra) # 80001ab0 <myproc>
    800025ca:	fea488e3          	beq	s1,a0,800025ba <wakeup+0x34>
      acquire(&p->lock);
    800025ce:	8526                	mv	a0,s1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	66e080e7          	jalr	1646(ra) # 80000c3e <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800025d8:	4c9c                	lw	a5,24(s1)
    800025da:	fd379be3          	bne	a5,s3,800025b0 <wakeup+0x2a>
    800025de:	709c                	ld	a5,32(s1)
    800025e0:	fd4798e3          	bne	a5,s4,800025b0 <wakeup+0x2a>
        p->state = RUNNABLE;
    800025e4:	0154ac23          	sw	s5,24(s1)
    800025e8:	b7e1                	j	800025b0 <wakeup+0x2a>
    }
  }
}
    800025ea:	70e2                	ld	ra,56(sp)
    800025ec:	7442                	ld	s0,48(sp)
    800025ee:	74a2                	ld	s1,40(sp)
    800025f0:	7902                	ld	s2,32(sp)
    800025f2:	69e2                	ld	s3,24(sp)
    800025f4:	6a42                	ld	s4,16(sp)
    800025f6:	6aa2                	ld	s5,8(sp)
    800025f8:	6121                	addi	sp,sp,64
    800025fa:	8082                	ret

00000000800025fc <reparent>:
{
    800025fc:	7179                	addi	sp,sp,-48
    800025fe:	f406                	sd	ra,40(sp)
    80002600:	f022                	sd	s0,32(sp)
    80002602:	ec26                	sd	s1,24(sp)
    80002604:	e84a                	sd	s2,16(sp)
    80002606:	e44e                	sd	s3,8(sp)
    80002608:	e052                	sd	s4,0(sp)
    8000260a:	1800                	addi	s0,sp,48
    8000260c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000260e:	0000f497          	auipc	s1,0xf
    80002612:	1a248493          	addi	s1,s1,418 # 800117b0 <proc>
      pp->parent = initproc;
    80002616:	00006a17          	auipc	s4,0x6
    8000261a:	2e2a0a13          	addi	s4,s4,738 # 800088f8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000261e:	0001c997          	auipc	s3,0x1c
    80002622:	59298993          	addi	s3,s3,1426 # 8001ebb0 <tickslock>
    80002626:	a029                	j	80002630 <reparent+0x34>
    80002628:	35048493          	addi	s1,s1,848
    8000262c:	01348d63          	beq	s1,s3,80002646 <reparent+0x4a>
    if (pp->parent == p)
    80002630:	7c9c                	ld	a5,56(s1)
    80002632:	ff279be3          	bne	a5,s2,80002628 <reparent+0x2c>
      pp->parent = initproc;
    80002636:	000a3503          	ld	a0,0(s4)
    8000263a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000263c:	00000097          	auipc	ra,0x0
    80002640:	f4a080e7          	jalr	-182(ra) # 80002586 <wakeup>
    80002644:	b7d5                	j	80002628 <reparent+0x2c>
}
    80002646:	70a2                	ld	ra,40(sp)
    80002648:	7402                	ld	s0,32(sp)
    8000264a:	64e2                	ld	s1,24(sp)
    8000264c:	6942                	ld	s2,16(sp)
    8000264e:	69a2                	ld	s3,8(sp)
    80002650:	6a02                	ld	s4,0(sp)
    80002652:	6145                	addi	sp,sp,48
    80002654:	8082                	ret

0000000080002656 <exit>:
{
    80002656:	7179                	addi	sp,sp,-48
    80002658:	f406                	sd	ra,40(sp)
    8000265a:	f022                	sd	s0,32(sp)
    8000265c:	ec26                	sd	s1,24(sp)
    8000265e:	e84a                	sd	s2,16(sp)
    80002660:	e44e                	sd	s3,8(sp)
    80002662:	e052                	sd	s4,0(sp)
    80002664:	1800                	addi	s0,sp,48
    80002666:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002668:	fffff097          	auipc	ra,0xfffff
    8000266c:	448080e7          	jalr	1096(ra) # 80001ab0 <myproc>
    80002670:	89aa                	mv	s3,a0
  if (p == initproc)
    80002672:	00006797          	auipc	a5,0x6
    80002676:	2867b783          	ld	a5,646(a5) # 800088f8 <initproc>
    8000267a:	2a850493          	addi	s1,a0,680
    8000267e:	32850913          	addi	s2,a0,808
    80002682:	00a79d63          	bne	a5,a0,8000269c <exit+0x46>
    panic("init exiting");
    80002686:	00006517          	auipc	a0,0x6
    8000268a:	bc250513          	addi	a0,a0,-1086 # 80008248 <etext+0x248>
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	ed2080e7          	jalr	-302(ra) # 80000560 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002696:	04a1                	addi	s1,s1,8
    80002698:	01248b63          	beq	s1,s2,800026ae <exit+0x58>
    if (p->ofile[fd])
    8000269c:	6088                	ld	a0,0(s1)
    8000269e:	dd65                	beqz	a0,80002696 <exit+0x40>
      fileclose(f);
    800026a0:	00002097          	auipc	ra,0x2
    800026a4:	734080e7          	jalr	1844(ra) # 80004dd4 <fileclose>
      p->ofile[fd] = 0;
    800026a8:	0004b023          	sd	zero,0(s1)
    800026ac:	b7ed                	j	80002696 <exit+0x40>
  begin_op();
    800026ae:	00002097          	auipc	ra,0x2
    800026b2:	256080e7          	jalr	598(ra) # 80004904 <begin_op>
  iput(p->cwd);
    800026b6:	3289b503          	ld	a0,808(s3)
    800026ba:	00002097          	auipc	ra,0x2
    800026be:	a1e080e7          	jalr	-1506(ra) # 800040d8 <iput>
  end_op();
    800026c2:	00002097          	auipc	ra,0x2
    800026c6:	2bc080e7          	jalr	700(ra) # 8000497e <end_op>
  p->cwd = 0;
    800026ca:	3209b423          	sd	zero,808(s3)
  acquire(&wait_lock);
    800026ce:	0000e497          	auipc	s1,0xe
    800026d2:	4ba48493          	addi	s1,s1,1210 # 80010b88 <wait_lock>
    800026d6:	8526                	mv	a0,s1
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	566080e7          	jalr	1382(ra) # 80000c3e <acquire>
  reparent(p);
    800026e0:	854e                	mv	a0,s3
    800026e2:	00000097          	auipc	ra,0x0
    800026e6:	f1a080e7          	jalr	-230(ra) # 800025fc <reparent>
  wakeup(p->parent);
    800026ea:	0389b503          	ld	a0,56(s3)
    800026ee:	00000097          	auipc	ra,0x0
    800026f2:	e98080e7          	jalr	-360(ra) # 80002586 <wakeup>
  acquire(&p->lock);
    800026f6:	854e                	mv	a0,s3
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	546080e7          	jalr	1350(ra) # 80000c3e <acquire>
  p->xstate = status;
    80002700:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002704:	4795                	li	a5,5
    80002706:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000270a:	00006797          	auipc	a5,0x6
    8000270e:	1fa7a783          	lw	a5,506(a5) # 80008904 <ticks>
    80002712:	34f9a423          	sw	a5,840(s3)
  release(&wait_lock);
    80002716:	8526                	mv	a0,s1
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	5d6080e7          	jalr	1494(ra) # 80000cee <release>
  sched();
    80002720:	00000097          	auipc	ra,0x0
    80002724:	cf0080e7          	jalr	-784(ra) # 80002410 <sched>
  panic("zombie exit");
    80002728:	00006517          	auipc	a0,0x6
    8000272c:	b3050513          	addi	a0,a0,-1232 # 80008258 <etext+0x258>
    80002730:	ffffe097          	auipc	ra,0xffffe
    80002734:	e30080e7          	jalr	-464(ra) # 80000560 <panic>

0000000080002738 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	1800                	addi	s0,sp,48
    80002746:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002748:	0000f497          	auipc	s1,0xf
    8000274c:	06848493          	addi	s1,s1,104 # 800117b0 <proc>
    80002750:	0001c997          	auipc	s3,0x1c
    80002754:	46098993          	addi	s3,s3,1120 # 8001ebb0 <tickslock>
  {
    acquire(&p->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	4e4080e7          	jalr	1252(ra) # 80000c3e <acquire>
    if (p->pid == pid)
    80002762:	589c                	lw	a5,48(s1)
    80002764:	01278d63          	beq	a5,s2,8000277e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	584080e7          	jalr	1412(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002772:	35048493          	addi	s1,s1,848
    80002776:	ff3491e3          	bne	s1,s3,80002758 <kill+0x20>
  }
  return -1;
    8000277a:	557d                	li	a0,-1
    8000277c:	a829                	j	80002796 <kill+0x5e>
      p->killed = 1;
    8000277e:	4785                	li	a5,1
    80002780:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002782:	4c98                	lw	a4,24(s1)
    80002784:	4789                	li	a5,2
    80002786:	00f70f63          	beq	a4,a5,800027a4 <kill+0x6c>
      release(&p->lock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	562080e7          	jalr	1378(ra) # 80000cee <release>
      return 0;
    80002794:	4501                	li	a0,0
}
    80002796:	70a2                	ld	ra,40(sp)
    80002798:	7402                	ld	s0,32(sp)
    8000279a:	64e2                	ld	s1,24(sp)
    8000279c:	6942                	ld	s2,16(sp)
    8000279e:	69a2                	ld	s3,8(sp)
    800027a0:	6145                	addi	sp,sp,48
    800027a2:	8082                	ret
        p->state = RUNNABLE;
    800027a4:	478d                	li	a5,3
    800027a6:	cc9c                	sw	a5,24(s1)
    800027a8:	b7cd                	j	8000278a <kill+0x52>

00000000800027aa <setkilled>:

void setkilled(struct proc *p)
{
    800027aa:	1101                	addi	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	1000                	addi	s0,sp,32
    800027b4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	488080e7          	jalr	1160(ra) # 80000c3e <acquire>
  p->killed = 1;
    800027be:	4785                	li	a5,1
    800027c0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800027c2:	8526                	mv	a0,s1
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	52a080e7          	jalr	1322(ra) # 80000cee <release>
}
    800027cc:	60e2                	ld	ra,24(sp)
    800027ce:	6442                	ld	s0,16(sp)
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret

00000000800027d6 <killed>:

int killed(struct proc *p)
{
    800027d6:	1101                	addi	sp,sp,-32
    800027d8:	ec06                	sd	ra,24(sp)
    800027da:	e822                	sd	s0,16(sp)
    800027dc:	e426                	sd	s1,8(sp)
    800027de:	e04a                	sd	s2,0(sp)
    800027e0:	1000                	addi	s0,sp,32
    800027e2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	45a080e7          	jalr	1114(ra) # 80000c3e <acquire>
  k = p->killed;
    800027ec:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800027f0:	8526                	mv	a0,s1
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	4fc080e7          	jalr	1276(ra) # 80000cee <release>
  return k;
}
    800027fa:	854a                	mv	a0,s2
    800027fc:	60e2                	ld	ra,24(sp)
    800027fe:	6442                	ld	s0,16(sp)
    80002800:	64a2                	ld	s1,8(sp)
    80002802:	6902                	ld	s2,0(sp)
    80002804:	6105                	addi	sp,sp,32
    80002806:	8082                	ret

0000000080002808 <wait>:
{
    80002808:	715d                	addi	sp,sp,-80
    8000280a:	e486                	sd	ra,72(sp)
    8000280c:	e0a2                	sd	s0,64(sp)
    8000280e:	fc26                	sd	s1,56(sp)
    80002810:	f84a                	sd	s2,48(sp)
    80002812:	f44e                	sd	s3,40(sp)
    80002814:	f052                	sd	s4,32(sp)
    80002816:	ec56                	sd	s5,24(sp)
    80002818:	e85a                	sd	s6,16(sp)
    8000281a:	e45e                	sd	s7,8(sp)
    8000281c:	0880                	addi	s0,sp,80
    8000281e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002820:	fffff097          	auipc	ra,0xfffff
    80002824:	290080e7          	jalr	656(ra) # 80001ab0 <myproc>
    80002828:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000282a:	0000e517          	auipc	a0,0xe
    8000282e:	35e50513          	addi	a0,a0,862 # 80010b88 <wait_lock>
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	40c080e7          	jalr	1036(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    8000283a:	4a95                	li	s5,5
        havekids = 1;
    8000283c:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000283e:	0001c997          	auipc	s3,0x1c
    80002842:	37298993          	addi	s3,s3,882 # 8001ebb0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002846:	0000eb97          	auipc	s7,0xe
    8000284a:	342b8b93          	addi	s7,s7,834 # 80010b88 <wait_lock>
    8000284e:	a0cd                	j	80002930 <wait+0x128>
    80002850:	04048613          	addi	a2,s1,64
          for (int i = 0; i <= 25; i++)
    80002854:	4701                	li	a4,0
    80002856:	4569                	li	a0,26
            pp->parent->syscall_count[i] += pp->syscall_count[i];
    80002858:	00271693          	slli	a3,a4,0x2
    8000285c:	7c9c                	ld	a5,56(s1)
    8000285e:	97b6                	add	a5,a5,a3
    80002860:	43ac                	lw	a1,64(a5)
    80002862:	4214                	lw	a3,0(a2)
    80002864:	9ead                	addw	a3,a3,a1
    80002866:	c3b4                	sw	a3,64(a5)
          for (int i = 0; i <= 25; i++)
    80002868:	2705                	addiw	a4,a4,1
    8000286a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000286c:	fea716e3          	bne	a4,a0,80002858 <wait+0x50>
          pid = pp->pid;
    80002870:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002874:	000a0e63          	beqz	s4,80002890 <wait+0x88>
    80002878:	4691                	li	a3,4
    8000287a:	02c48613          	addi	a2,s1,44
    8000287e:	85d2                	mv	a1,s4
    80002880:	22893503          	ld	a0,552(s2)
    80002884:	fffff097          	auipc	ra,0xfffff
    80002888:	e8c080e7          	jalr	-372(ra) # 80001710 <copyout>
    8000288c:	04054063          	bltz	a0,800028cc <wait+0xc4>
          freeproc(pp);
    80002890:	8526                	mv	a0,s1
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	3d0080e7          	jalr	976(ra) # 80001c62 <freeproc>
          release(&pp->lock);
    8000289a:	8526                	mv	a0,s1
    8000289c:	ffffe097          	auipc	ra,0xffffe
    800028a0:	452080e7          	jalr	1106(ra) # 80000cee <release>
          release(&wait_lock);
    800028a4:	0000e517          	auipc	a0,0xe
    800028a8:	2e450513          	addi	a0,a0,740 # 80010b88 <wait_lock>
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	442080e7          	jalr	1090(ra) # 80000cee <release>
}
    800028b4:	854e                	mv	a0,s3
    800028b6:	60a6                	ld	ra,72(sp)
    800028b8:	6406                	ld	s0,64(sp)
    800028ba:	74e2                	ld	s1,56(sp)
    800028bc:	7942                	ld	s2,48(sp)
    800028be:	79a2                	ld	s3,40(sp)
    800028c0:	7a02                	ld	s4,32(sp)
    800028c2:	6ae2                	ld	s5,24(sp)
    800028c4:	6b42                	ld	s6,16(sp)
    800028c6:	6ba2                	ld	s7,8(sp)
    800028c8:	6161                	addi	sp,sp,80
    800028ca:	8082                	ret
            release(&pp->lock);
    800028cc:	8526                	mv	a0,s1
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	420080e7          	jalr	1056(ra) # 80000cee <release>
            release(&wait_lock);
    800028d6:	0000e517          	auipc	a0,0xe
    800028da:	2b250513          	addi	a0,a0,690 # 80010b88 <wait_lock>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	410080e7          	jalr	1040(ra) # 80000cee <release>
            return -1;
    800028e6:	59fd                	li	s3,-1
    800028e8:	b7f1                	j	800028b4 <wait+0xac>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800028ea:	35048493          	addi	s1,s1,848
    800028ee:	03348463          	beq	s1,s3,80002916 <wait+0x10e>
      if (pp->parent == p)
    800028f2:	7c9c                	ld	a5,56(s1)
    800028f4:	ff279be3          	bne	a5,s2,800028ea <wait+0xe2>
        acquire(&pp->lock);
    800028f8:	8526                	mv	a0,s1
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	344080e7          	jalr	836(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    80002902:	4c9c                	lw	a5,24(s1)
    80002904:	f55786e3          	beq	a5,s5,80002850 <wait+0x48>
        release(&pp->lock);
    80002908:	8526                	mv	a0,s1
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	3e4080e7          	jalr	996(ra) # 80000cee <release>
        havekids = 1;
    80002912:	875a                	mv	a4,s6
    80002914:	bfd9                	j	800028ea <wait+0xe2>
    if (!havekids || killed(p))
    80002916:	c31d                	beqz	a4,8000293c <wait+0x134>
    80002918:	854a                	mv	a0,s2
    8000291a:	00000097          	auipc	ra,0x0
    8000291e:	ebc080e7          	jalr	-324(ra) # 800027d6 <killed>
    80002922:	ed09                	bnez	a0,8000293c <wait+0x134>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002924:	85de                	mv	a1,s7
    80002926:	854a                	mv	a0,s2
    80002928:	00000097          	auipc	ra,0x0
    8000292c:	bfa080e7          	jalr	-1030(ra) # 80002522 <sleep>
    havekids = 0;
    80002930:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002932:	0000f497          	auipc	s1,0xf
    80002936:	e7e48493          	addi	s1,s1,-386 # 800117b0 <proc>
    8000293a:	bf65                	j	800028f2 <wait+0xea>
      release(&wait_lock);
    8000293c:	0000e517          	auipc	a0,0xe
    80002940:	24c50513          	addi	a0,a0,588 # 80010b88 <wait_lock>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	3aa080e7          	jalr	938(ra) # 80000cee <release>
      return -1;
    8000294c:	59fd                	li	s3,-1
    8000294e:	b79d                	j	800028b4 <wait+0xac>

0000000080002950 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002950:	7179                	addi	sp,sp,-48
    80002952:	f406                	sd	ra,40(sp)
    80002954:	f022                	sd	s0,32(sp)
    80002956:	ec26                	sd	s1,24(sp)
    80002958:	e84a                	sd	s2,16(sp)
    8000295a:	e44e                	sd	s3,8(sp)
    8000295c:	e052                	sd	s4,0(sp)
    8000295e:	1800                	addi	s0,sp,48
    80002960:	84aa                	mv	s1,a0
    80002962:	892e                	mv	s2,a1
    80002964:	89b2                	mv	s3,a2
    80002966:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002968:	fffff097          	auipc	ra,0xfffff
    8000296c:	148080e7          	jalr	328(ra) # 80001ab0 <myproc>
  if (user_dst)
    80002970:	c095                	beqz	s1,80002994 <either_copyout+0x44>
  {
    return copyout(p->pagetable, dst, src, len);
    80002972:	86d2                	mv	a3,s4
    80002974:	864e                	mv	a2,s3
    80002976:	85ca                	mv	a1,s2
    80002978:	22853503          	ld	a0,552(a0)
    8000297c:	fffff097          	auipc	ra,0xfffff
    80002980:	d94080e7          	jalr	-620(ra) # 80001710 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002984:	70a2                	ld	ra,40(sp)
    80002986:	7402                	ld	s0,32(sp)
    80002988:	64e2                	ld	s1,24(sp)
    8000298a:	6942                	ld	s2,16(sp)
    8000298c:	69a2                	ld	s3,8(sp)
    8000298e:	6a02                	ld	s4,0(sp)
    80002990:	6145                	addi	sp,sp,48
    80002992:	8082                	ret
    memmove((char *)dst, src, len);
    80002994:	000a061b          	sext.w	a2,s4
    80002998:	85ce                	mv	a1,s3
    8000299a:	854a                	mv	a0,s2
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	3fe080e7          	jalr	1022(ra) # 80000d9a <memmove>
    return 0;
    800029a4:	8526                	mv	a0,s1
    800029a6:	bff9                	j	80002984 <either_copyout+0x34>

00000000800029a8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029a8:	7179                	addi	sp,sp,-48
    800029aa:	f406                	sd	ra,40(sp)
    800029ac:	f022                	sd	s0,32(sp)
    800029ae:	ec26                	sd	s1,24(sp)
    800029b0:	e84a                	sd	s2,16(sp)
    800029b2:	e44e                	sd	s3,8(sp)
    800029b4:	e052                	sd	s4,0(sp)
    800029b6:	1800                	addi	s0,sp,48
    800029b8:	892a                	mv	s2,a0
    800029ba:	84ae                	mv	s1,a1
    800029bc:	89b2                	mv	s3,a2
    800029be:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	0f0080e7          	jalr	240(ra) # 80001ab0 <myproc>
  if (user_src)
    800029c8:	c095                	beqz	s1,800029ec <either_copyin+0x44>
  {
    return copyin(p->pagetable, dst, src, len);
    800029ca:	86d2                	mv	a3,s4
    800029cc:	864e                	mv	a2,s3
    800029ce:	85ca                	mv	a1,s2
    800029d0:	22853503          	ld	a0,552(a0)
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	dc8080e7          	jalr	-568(ra) # 8000179c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800029dc:	70a2                	ld	ra,40(sp)
    800029de:	7402                	ld	s0,32(sp)
    800029e0:	64e2                	ld	s1,24(sp)
    800029e2:	6942                	ld	s2,16(sp)
    800029e4:	69a2                	ld	s3,8(sp)
    800029e6:	6a02                	ld	s4,0(sp)
    800029e8:	6145                	addi	sp,sp,48
    800029ea:	8082                	ret
    memmove(dst, (char *)src, len);
    800029ec:	000a061b          	sext.w	a2,s4
    800029f0:	85ce                	mv	a1,s3
    800029f2:	854a                	mv	a0,s2
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	3a6080e7          	jalr	934(ra) # 80000d9a <memmove>
    return 0;
    800029fc:	8526                	mv	a0,s1
    800029fe:	bff9                	j	800029dc <either_copyin+0x34>

0000000080002a00 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a00:	715d                	addi	sp,sp,-80
    80002a02:	e486                	sd	ra,72(sp)
    80002a04:	e0a2                	sd	s0,64(sp)
    80002a06:	fc26                	sd	s1,56(sp)
    80002a08:	f84a                	sd	s2,48(sp)
    80002a0a:	f44e                	sd	s3,40(sp)
    80002a0c:	f052                	sd	s4,32(sp)
    80002a0e:	ec56                	sd	s5,24(sp)
    80002a10:	e85a                	sd	s6,16(sp)
    80002a12:	e45e                	sd	s7,8(sp)
    80002a14:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002a16:	00005517          	auipc	a0,0x5
    80002a1a:	5fa50513          	addi	a0,a0,1530 # 80008010 <etext+0x10>
    80002a1e:	ffffe097          	auipc	ra,0xffffe
    80002a22:	b8c080e7          	jalr	-1140(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a26:	0000f497          	auipc	s1,0xf
    80002a2a:	0ba48493          	addi	s1,s1,186 # 80011ae0 <proc+0x330>
    80002a2e:	0001c917          	auipc	s2,0x1c
    80002a32:	4b290913          	addi	s2,s2,1202 # 8001eee0 <bcache+0x318>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a36:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a38:	00006997          	auipc	s3,0x6
    80002a3c:	83098993          	addi	s3,s3,-2000 # 80008268 <etext+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80002a40:	00006a97          	auipc	s5,0x6
    80002a44:	830a8a93          	addi	s5,s5,-2000 # 80008270 <etext+0x270>
    printf("\n");
    80002a48:	00005a17          	auipc	s4,0x5
    80002a4c:	5c8a0a13          	addi	s4,s4,1480 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a50:	00006b97          	auipc	s7,0x6
    80002a54:	cf8b8b93          	addi	s7,s7,-776 # 80008748 <states.0>
    80002a58:	a00d                	j	80002a7a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002a5a:	d006a583          	lw	a1,-768(a3)
    80002a5e:	8556                	mv	a0,s5
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	b4a080e7          	jalr	-1206(ra) # 800005aa <printf>
    printf("\n");
    80002a68:	8552                	mv	a0,s4
    80002a6a:	ffffe097          	auipc	ra,0xffffe
    80002a6e:	b40080e7          	jalr	-1216(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a72:	35048493          	addi	s1,s1,848
    80002a76:	03248263          	beq	s1,s2,80002a9a <procdump+0x9a>
    if (p->state == UNUSED)
    80002a7a:	86a6                	mv	a3,s1
    80002a7c:	ce84a783          	lw	a5,-792(s1)
    80002a80:	dbed                	beqz	a5,80002a72 <procdump+0x72>
      state = "???";
    80002a82:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a84:	fcfb6be3          	bltu	s6,a5,80002a5a <procdump+0x5a>
    80002a88:	02079713          	slli	a4,a5,0x20
    80002a8c:	01d75793          	srli	a5,a4,0x1d
    80002a90:	97de                	add	a5,a5,s7
    80002a92:	6390                	ld	a2,0(a5)
    80002a94:	f279                	bnez	a2,80002a5a <procdump+0x5a>
      state = "???";
    80002a96:	864e                	mv	a2,s3
    80002a98:	b7c9                	j	80002a5a <procdump+0x5a>
  }
}
    80002a9a:	60a6                	ld	ra,72(sp)
    80002a9c:	6406                	ld	s0,64(sp)
    80002a9e:	74e2                	ld	s1,56(sp)
    80002aa0:	7942                	ld	s2,48(sp)
    80002aa2:	79a2                	ld	s3,40(sp)
    80002aa4:	7a02                	ld	s4,32(sp)
    80002aa6:	6ae2                	ld	s5,24(sp)
    80002aa8:	6b42                	ld	s6,16(sp)
    80002aaa:	6ba2                	ld	s7,8(sp)
    80002aac:	6161                	addi	sp,sp,80
    80002aae:	8082                	ret

0000000080002ab0 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002ab0:	711d                	addi	sp,sp,-96
    80002ab2:	ec86                	sd	ra,88(sp)
    80002ab4:	e8a2                	sd	s0,80(sp)
    80002ab6:	e4a6                	sd	s1,72(sp)
    80002ab8:	e0ca                	sd	s2,64(sp)
    80002aba:	fc4e                	sd	s3,56(sp)
    80002abc:	f852                	sd	s4,48(sp)
    80002abe:	f456                	sd	s5,40(sp)
    80002ac0:	f05a                	sd	s6,32(sp)
    80002ac2:	ec5e                	sd	s7,24(sp)
    80002ac4:	e862                	sd	s8,16(sp)
    80002ac6:	e466                	sd	s9,8(sp)
    80002ac8:	1080                	addi	s0,sp,96
    80002aca:	8b2a                	mv	s6,a0
    80002acc:	8bae                	mv	s7,a1
    80002ace:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	fe0080e7          	jalr	-32(ra) # 80001ab0 <myproc>
    80002ad8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002ada:	0000e517          	auipc	a0,0xe
    80002ade:	0ae50513          	addi	a0,a0,174 # 80010b88 <wait_lock>
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	15c080e7          	jalr	348(ra) # 80000c3e <acquire>
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002aea:	4a15                	li	s4,5
        havekids = 1;
    80002aec:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002aee:	0001c997          	auipc	s3,0x1c
    80002af2:	0c298993          	addi	s3,s3,194 # 8001ebb0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002af6:	0000ec97          	auipc	s9,0xe
    80002afa:	092c8c93          	addi	s9,s9,146 # 80010b88 <wait_lock>
    80002afe:	a8e1                	j	80002bd6 <waitx+0x126>
          pid = np->pid;
    80002b00:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002b04:	3404a783          	lw	a5,832(s1)
    80002b08:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    80002b0c:	3444a703          	lw	a4,836(s1)
    80002b10:	9f3d                	addw	a4,a4,a5
    80002b12:	3484a783          	lw	a5,840(s1)
    80002b16:	9f99                	subw	a5,a5,a4
    80002b18:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002b1c:	000b0e63          	beqz	s6,80002b38 <waitx+0x88>
    80002b20:	4691                	li	a3,4
    80002b22:	02c48613          	addi	a2,s1,44
    80002b26:	85da                	mv	a1,s6
    80002b28:	22893503          	ld	a0,552(s2)
    80002b2c:	fffff097          	auipc	ra,0xfffff
    80002b30:	be4080e7          	jalr	-1052(ra) # 80001710 <copyout>
    80002b34:	04054263          	bltz	a0,80002b78 <waitx+0xc8>
          freeproc(np);
    80002b38:	8526                	mv	a0,s1
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	128080e7          	jalr	296(ra) # 80001c62 <freeproc>
          release(&np->lock);
    80002b42:	8526                	mv	a0,s1
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	1aa080e7          	jalr	426(ra) # 80000cee <release>
          release(&wait_lock);
    80002b4c:	0000e517          	auipc	a0,0xe
    80002b50:	03c50513          	addi	a0,a0,60 # 80010b88 <wait_lock>
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	19a080e7          	jalr	410(ra) # 80000cee <release>
  }
}
    80002b5c:	854e                	mv	a0,s3
    80002b5e:	60e6                	ld	ra,88(sp)
    80002b60:	6446                	ld	s0,80(sp)
    80002b62:	64a6                	ld	s1,72(sp)
    80002b64:	6906                	ld	s2,64(sp)
    80002b66:	79e2                	ld	s3,56(sp)
    80002b68:	7a42                	ld	s4,48(sp)
    80002b6a:	7aa2                	ld	s5,40(sp)
    80002b6c:	7b02                	ld	s6,32(sp)
    80002b6e:	6be2                	ld	s7,24(sp)
    80002b70:	6c42                	ld	s8,16(sp)
    80002b72:	6ca2                	ld	s9,8(sp)
    80002b74:	6125                	addi	sp,sp,96
    80002b76:	8082                	ret
            release(&np->lock);
    80002b78:	8526                	mv	a0,s1
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	174080e7          	jalr	372(ra) # 80000cee <release>
            release(&wait_lock);
    80002b82:	0000e517          	auipc	a0,0xe
    80002b86:	00650513          	addi	a0,a0,6 # 80010b88 <wait_lock>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	164080e7          	jalr	356(ra) # 80000cee <release>
            return -1;
    80002b92:	59fd                	li	s3,-1
    80002b94:	b7e1                	j	80002b5c <waitx+0xac>
    for (np = proc; np < &proc[NPROC]; np++)
    80002b96:	35048493          	addi	s1,s1,848
    80002b9a:	03348463          	beq	s1,s3,80002bc2 <waitx+0x112>
      if (np->parent == p)
    80002b9e:	7c9c                	ld	a5,56(s1)
    80002ba0:	ff279be3          	bne	a5,s2,80002b96 <waitx+0xe6>
        acquire(&np->lock);
    80002ba4:	8526                	mv	a0,s1
    80002ba6:	ffffe097          	auipc	ra,0xffffe
    80002baa:	098080e7          	jalr	152(ra) # 80000c3e <acquire>
        if (np->state == ZOMBIE)
    80002bae:	4c9c                	lw	a5,24(s1)
    80002bb0:	f54788e3          	beq	a5,s4,80002b00 <waitx+0x50>
        release(&np->lock);
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	ffffe097          	auipc	ra,0xffffe
    80002bba:	138080e7          	jalr	312(ra) # 80000cee <release>
        havekids = 1;
    80002bbe:	8756                	mv	a4,s5
    80002bc0:	bfd9                	j	80002b96 <waitx+0xe6>
    if (!havekids || p->killed)
    80002bc2:	c305                	beqz	a4,80002be2 <waitx+0x132>
    80002bc4:	02892783          	lw	a5,40(s2)
    80002bc8:	ef89                	bnez	a5,80002be2 <waitx+0x132>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002bca:	85e6                	mv	a1,s9
    80002bcc:	854a                	mv	a0,s2
    80002bce:	00000097          	auipc	ra,0x0
    80002bd2:	954080e7          	jalr	-1708(ra) # 80002522 <sleep>
    havekids = 0;
    80002bd6:	4701                	li	a4,0
    for (np = proc; np < &proc[NPROC]; np++)
    80002bd8:	0000f497          	auipc	s1,0xf
    80002bdc:	bd848493          	addi	s1,s1,-1064 # 800117b0 <proc>
    80002be0:	bf7d                	j	80002b9e <waitx+0xee>
      release(&wait_lock);
    80002be2:	0000e517          	auipc	a0,0xe
    80002be6:	fa650513          	addi	a0,a0,-90 # 80010b88 <wait_lock>
    80002bea:	ffffe097          	auipc	ra,0xffffe
    80002bee:	104080e7          	jalr	260(ra) # 80000cee <release>
      return -1;
    80002bf2:	59fd                	li	s3,-1
    80002bf4:	b7a5                	j	80002b5c <waitx+0xac>

0000000080002bf6 <update_time>:

void update_time()
{
    80002bf6:	7179                	addi	sp,sp,-48
    80002bf8:	f406                	sd	ra,40(sp)
    80002bfa:	f022                	sd	s0,32(sp)
    80002bfc:	ec26                	sd	s1,24(sp)
    80002bfe:	e84a                	sd	s2,16(sp)
    80002c00:	e44e                	sd	s3,8(sp)
    80002c02:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002c04:	0000f497          	auipc	s1,0xf
    80002c08:	bac48493          	addi	s1,s1,-1108 # 800117b0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002c0c:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002c0e:	0001c917          	auipc	s2,0x1c
    80002c12:	fa290913          	addi	s2,s2,-94 # 8001ebb0 <tickslock>
    80002c16:	a811                	j	80002c2a <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002c18:	8526                	mv	a0,s1
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	0d4080e7          	jalr	212(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002c22:	35048493          	addi	s1,s1,848
    80002c26:	03248063          	beq	s1,s2,80002c46 <update_time+0x50>
    acquire(&p->lock);
    80002c2a:	8526                	mv	a0,s1
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	012080e7          	jalr	18(ra) # 80000c3e <acquire>
    if (p->state == RUNNING)
    80002c34:	4c9c                	lw	a5,24(s1)
    80002c36:	ff3791e3          	bne	a5,s3,80002c18 <update_time+0x22>
      p->rtime++;
    80002c3a:	3404a783          	lw	a5,832(s1)
    80002c3e:	2785                	addiw	a5,a5,1
    80002c40:	34f4a023          	sw	a5,832(s1)
    80002c44:	bfd1                	j	80002c18 <update_time+0x22>
  }
    80002c46:	70a2                	ld	ra,40(sp)
    80002c48:	7402                	ld	s0,32(sp)
    80002c4a:	64e2                	ld	s1,24(sp)
    80002c4c:	6942                	ld	s2,16(sp)
    80002c4e:	69a2                	ld	s3,8(sp)
    80002c50:	6145                	addi	sp,sp,48
    80002c52:	8082                	ret

0000000080002c54 <swtch>:
    80002c54:	00153023          	sd	ra,0(a0)
    80002c58:	00253423          	sd	sp,8(a0)
    80002c5c:	e900                	sd	s0,16(a0)
    80002c5e:	ed04                	sd	s1,24(a0)
    80002c60:	03253023          	sd	s2,32(a0)
    80002c64:	03353423          	sd	s3,40(a0)
    80002c68:	03453823          	sd	s4,48(a0)
    80002c6c:	03553c23          	sd	s5,56(a0)
    80002c70:	05653023          	sd	s6,64(a0)
    80002c74:	05753423          	sd	s7,72(a0)
    80002c78:	05853823          	sd	s8,80(a0)
    80002c7c:	05953c23          	sd	s9,88(a0)
    80002c80:	07a53023          	sd	s10,96(a0)
    80002c84:	07b53423          	sd	s11,104(a0)
    80002c88:	0005b083          	ld	ra,0(a1)
    80002c8c:	0085b103          	ld	sp,8(a1)
    80002c90:	6980                	ld	s0,16(a1)
    80002c92:	6d84                	ld	s1,24(a1)
    80002c94:	0205b903          	ld	s2,32(a1)
    80002c98:	0285b983          	ld	s3,40(a1)
    80002c9c:	0305ba03          	ld	s4,48(a1)
    80002ca0:	0385ba83          	ld	s5,56(a1)
    80002ca4:	0405bb03          	ld	s6,64(a1)
    80002ca8:	0485bb83          	ld	s7,72(a1)
    80002cac:	0505bc03          	ld	s8,80(a1)
    80002cb0:	0585bc83          	ld	s9,88(a1)
    80002cb4:	0605bd03          	ld	s10,96(a1)
    80002cb8:	0685bd83          	ld	s11,104(a1)
    80002cbc:	8082                	ret

0000000080002cbe <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002cbe:	1141                	addi	sp,sp,-16
    80002cc0:	e406                	sd	ra,8(sp)
    80002cc2:	e022                	sd	s0,0(sp)
    80002cc4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002cc6:	00005597          	auipc	a1,0x5
    80002cca:	5ea58593          	addi	a1,a1,1514 # 800082b0 <etext+0x2b0>
    80002cce:	0001c517          	auipc	a0,0x1c
    80002cd2:	ee250513          	addi	a0,a0,-286 # 8001ebb0 <tickslock>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	ed4080e7          	jalr	-300(ra) # 80000baa <initlock>
}
    80002cde:	60a2                	ld	ra,8(sp)
    80002ce0:	6402                	ld	s0,0(sp)
    80002ce2:	0141                	addi	sp,sp,16
    80002ce4:	8082                	ret

0000000080002ce6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002ce6:	1141                	addi	sp,sp,-16
    80002ce8:	e406                	sd	ra,8(sp)
    80002cea:	e022                	sd	s0,0(sp)
    80002cec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cee:	00004797          	auipc	a5,0x4
    80002cf2:	84278793          	addi	a5,a5,-1982 # 80006530 <kernelvec>
    80002cf6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cfa:	60a2                	ld	ra,8(sp)
    80002cfc:	6402                	ld	s0,0(sp)
    80002cfe:	0141                	addi	sp,sp,16
    80002d00:	8082                	ret

0000000080002d02 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002d02:	1141                	addi	sp,sp,-16
    80002d04:	e406                	sd	ra,8(sp)
    80002d06:	e022                	sd	s0,0(sp)
    80002d08:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	da6080e7          	jalr	-602(ra) # 80001ab0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d16:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d18:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002d1c:	00004697          	auipc	a3,0x4
    80002d20:	2e468693          	addi	a3,a3,740 # 80007000 <_trampoline>
    80002d24:	00004717          	auipc	a4,0x4
    80002d28:	2dc70713          	addi	a4,a4,732 # 80007000 <_trampoline>
    80002d2c:	8f15                	sub	a4,a4,a3
    80002d2e:	040007b7          	lui	a5,0x4000
    80002d32:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002d34:	07b2                	slli	a5,a5,0xc
    80002d36:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d38:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d3c:	23053703          	ld	a4,560(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d40:	18002673          	csrr	a2,satp
    80002d44:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d46:	23053603          	ld	a2,560(a0)
    80002d4a:	21853703          	ld	a4,536(a0)
    80002d4e:	6585                	lui	a1,0x1
    80002d50:	972e                	add	a4,a4,a1
    80002d52:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d54:	23053703          	ld	a4,560(a0)
    80002d58:	00000617          	auipc	a2,0x0
    80002d5c:	14c60613          	addi	a2,a2,332 # 80002ea4 <usertrap>
    80002d60:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002d62:	23053703          	ld	a4,560(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d66:	8612                	mv	a2,tp
    80002d68:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d6e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d72:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d76:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d7a:	23053703          	ld	a4,560(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d7e:	6f18                	ld	a4,24(a4)
    80002d80:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d84:	22853503          	ld	a0,552(a0)
    80002d88:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d8a:	00004717          	auipc	a4,0x4
    80002d8e:	31270713          	addi	a4,a4,786 # 8000709c <userret>
    80002d92:	8f15                	sub	a4,a4,a3
    80002d94:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002d96:	577d                	li	a4,-1
    80002d98:	177e                	slli	a4,a4,0x3f
    80002d9a:	8d59                	or	a0,a0,a4
    80002d9c:	9782                	jalr	a5
}
    80002d9e:	60a2                	ld	ra,8(sp)
    80002da0:	6402                	ld	s0,0(sp)
    80002da2:	0141                	addi	sp,sp,16
    80002da4:	8082                	ret

0000000080002da6 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	e426                	sd	s1,8(sp)
    80002dae:	e04a                	sd	s2,0(sp)
    80002db0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002db2:	0001c917          	auipc	s2,0x1c
    80002db6:	dfe90913          	addi	s2,s2,-514 # 8001ebb0 <tickslock>
    80002dba:	854a                	mv	a0,s2
    80002dbc:	ffffe097          	auipc	ra,0xffffe
    80002dc0:	e82080e7          	jalr	-382(ra) # 80000c3e <acquire>
  ticks++;
    80002dc4:	00006497          	auipc	s1,0x6
    80002dc8:	b4048493          	addi	s1,s1,-1216 # 80008904 <ticks>
    80002dcc:	409c                	lw	a5,0(s1)
    80002dce:	2785                	addiw	a5,a5,1
    80002dd0:	c09c                	sw	a5,0(s1)
  update_time();
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	e24080e7          	jalr	-476(ra) # 80002bf6 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002dda:	8526                	mv	a0,s1
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	7aa080e7          	jalr	1962(ra) # 80002586 <wakeup>
  release(&tickslock);
    80002de4:	854a                	mv	a0,s2
    80002de6:	ffffe097          	auipc	ra,0xffffe
    80002dea:	f08080e7          	jalr	-248(ra) # 80000cee <release>
}
    80002dee:	60e2                	ld	ra,24(sp)
    80002df0:	6442                	ld	s0,16(sp)
    80002df2:	64a2                	ld	s1,8(sp)
    80002df4:	6902                	ld	s2,0(sp)
    80002df6:	6105                	addi	sp,sp,32
    80002df8:	8082                	ret

0000000080002dfa <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dfa:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002dfe:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002e00:	0a07d163          	bgez	a5,80002ea2 <devintr+0xa8>
{
    80002e04:	1101                	addi	sp,sp,-32
    80002e06:	ec06                	sd	ra,24(sp)
    80002e08:	e822                	sd	s0,16(sp)
    80002e0a:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002e0c:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002e10:	46a5                	li	a3,9
    80002e12:	00d70c63          	beq	a4,a3,80002e2a <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002e16:	577d                	li	a4,-1
    80002e18:	177e                	slli	a4,a4,0x3f
    80002e1a:	0705                	addi	a4,a4,1
    return 0;
    80002e1c:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002e1e:	06e78163          	beq	a5,a4,80002e80 <devintr+0x86>
  }
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret
    80002e2a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002e2c:	00004097          	auipc	ra,0x4
    80002e30:	810080e7          	jalr	-2032(ra) # 8000663c <plic_claim>
    80002e34:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002e36:	47a9                	li	a5,10
    80002e38:	00f50963          	beq	a0,a5,80002e4a <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002e3c:	4785                	li	a5,1
    80002e3e:	00f50b63          	beq	a0,a5,80002e54 <devintr+0x5a>
    return 1;
    80002e42:	4505                	li	a0,1
    else if (irq)
    80002e44:	ec89                	bnez	s1,80002e5e <devintr+0x64>
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	bfe9                	j	80002e22 <devintr+0x28>
      uartintr();
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	bb2080e7          	jalr	-1102(ra) # 800009fc <uartintr>
    if (irq)
    80002e52:	a839                	j	80002e70 <devintr+0x76>
      virtio_disk_intr();
    80002e54:	00004097          	auipc	ra,0x4
    80002e58:	cdc080e7          	jalr	-804(ra) # 80006b30 <virtio_disk_intr>
    if (irq)
    80002e5c:	a811                	j	80002e70 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e5e:	85a6                	mv	a1,s1
    80002e60:	00005517          	auipc	a0,0x5
    80002e64:	45850513          	addi	a0,a0,1112 # 800082b8 <etext+0x2b8>
    80002e68:	ffffd097          	auipc	ra,0xffffd
    80002e6c:	742080e7          	jalr	1858(ra) # 800005aa <printf>
      plic_complete(irq);
    80002e70:	8526                	mv	a0,s1
    80002e72:	00003097          	auipc	ra,0x3
    80002e76:	7ee080e7          	jalr	2030(ra) # 80006660 <plic_complete>
    return 1;
    80002e7a:	4505                	li	a0,1
    80002e7c:	64a2                	ld	s1,8(sp)
    80002e7e:	b755                	j	80002e22 <devintr+0x28>
    if (cpuid() == 0)
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	bfc080e7          	jalr	-1028(ra) # 80001a7c <cpuid>
    80002e88:	c901                	beqz	a0,80002e98 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e8a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e90:	14479073          	csrw	sip,a5
    return 2;
    80002e94:	4509                	li	a0,2
    80002e96:	b771                	j	80002e22 <devintr+0x28>
      clockintr();
    80002e98:	00000097          	auipc	ra,0x0
    80002e9c:	f0e080e7          	jalr	-242(ra) # 80002da6 <clockintr>
    80002ea0:	b7ed                	j	80002e8a <devintr+0x90>
}
    80002ea2:	8082                	ret

0000000080002ea4 <usertrap>:
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	e426                	sd	s1,8(sp)
    80002eac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eae:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002eb2:	1007f793          	andi	a5,a5,256
    80002eb6:	e3c1                	bnez	a5,80002f36 <usertrap+0x92>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002eb8:	00003797          	auipc	a5,0x3
    80002ebc:	67878793          	addi	a5,a5,1656 # 80006530 <kernelvec>
    80002ec0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	bec080e7          	jalr	-1044(ra) # 80001ab0 <myproc>
    80002ecc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ece:	23053783          	ld	a5,560(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ed2:	14102773          	csrr	a4,sepc
    80002ed6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ed8:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002edc:	47a1                	li	a5,8
    80002ede:	06f70463          	beq	a4,a5,80002f46 <usertrap+0xa2>
  else if ((which_dev = devintr()) != 0)
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	f18080e7          	jalr	-232(ra) # 80002dfa <devintr>
    80002eea:	c55d                	beqz	a0,80002f98 <usertrap+0xf4>
  if (which_dev == 2 && p->alarm_interval > 0)
    80002eec:	4789                	li	a5,2
    80002eee:	08f51063          	bne	a0,a5,80002f6e <usertrap+0xca>
    80002ef2:	0e44a703          	lw	a4,228(s1)
    80002ef6:	00e05c63          	blez	a4,80002f0e <usertrap+0x6a>
    p->ticks++;
    80002efa:	0e04a783          	lw	a5,224(s1)
    80002efe:	2785                	addiw	a5,a5,1
    80002f00:	0ef4a023          	sw	a5,224(s1)
    if (p->ticks >= p->alarm_interval && p->alarm_active == 0)
    80002f04:	00e7c563          	blt	a5,a4,80002f0e <usertrap+0x6a>
    80002f08:	2104a783          	lw	a5,528(s1)
    80002f0c:	c3f9                	beqz	a5,80002fd2 <usertrap+0x12e>
    struct proc *p = myproc();
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	ba2080e7          	jalr	-1118(ra) # 80001ab0 <myproc>
    if (p && p->state == RUNNING)
    80002f16:	c509                	beqz	a0,80002f20 <usertrap+0x7c>
    80002f18:	4d18                	lw	a4,24(a0)
    80002f1a:	4791                	li	a5,4
    80002f1c:	0cf70f63          	beq	a4,a5,80002ffa <usertrap+0x156>
  if (killed(p))
    80002f20:	8526                	mv	a0,s1
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	8b4080e7          	jalr	-1868(ra) # 800027d6 <killed>
    80002f2a:	ed69                	bnez	a0,80003004 <usertrap+0x160>
    yield();
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	5ba080e7          	jalr	1466(ra) # 800024e6 <yield>
    80002f34:	a099                	j	80002f7a <usertrap+0xd6>
    panic("usertrap: not from user mode");
    80002f36:	00005517          	auipc	a0,0x5
    80002f3a:	3a250513          	addi	a0,a0,930 # 800082d8 <etext+0x2d8>
    80002f3e:	ffffd097          	auipc	ra,0xffffd
    80002f42:	622080e7          	jalr	1570(ra) # 80000560 <panic>
    if (killed(p))
    80002f46:	00000097          	auipc	ra,0x0
    80002f4a:	890080e7          	jalr	-1904(ra) # 800027d6 <killed>
    80002f4e:	ed1d                	bnez	a0,80002f8c <usertrap+0xe8>
    p->trapframe->epc += 4;
    80002f50:	2304b703          	ld	a4,560(s1)
    80002f54:	6f1c                	ld	a5,24(a4)
    80002f56:	0791                	addi	a5,a5,4
    80002f58:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f5a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f5e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f62:	10079073          	csrw	sstatus,a5
    syscall();
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	30a080e7          	jalr	778(ra) # 80003270 <syscall>
  if (killed(p))
    80002f6e:	8526                	mv	a0,s1
    80002f70:	00000097          	auipc	ra,0x0
    80002f74:	866080e7          	jalr	-1946(ra) # 800027d6 <killed>
    80002f78:	ed41                	bnez	a0,80003010 <usertrap+0x16c>
  usertrapret();
    80002f7a:	00000097          	auipc	ra,0x0
    80002f7e:	d88080e7          	jalr	-632(ra) # 80002d02 <usertrapret>
}
    80002f82:	60e2                	ld	ra,24(sp)
    80002f84:	6442                	ld	s0,16(sp)
    80002f86:	64a2                	ld	s1,8(sp)
    80002f88:	6105                	addi	sp,sp,32
    80002f8a:	8082                	ret
      exit(-1);
    80002f8c:	557d                	li	a0,-1
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	6c8080e7          	jalr	1736(ra) # 80002656 <exit>
    80002f96:	bf6d                	j	80002f50 <usertrap+0xac>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f98:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f9c:	5890                	lw	a2,48(s1)
    80002f9e:	00005517          	auipc	a0,0x5
    80002fa2:	35a50513          	addi	a0,a0,858 # 800082f8 <etext+0x2f8>
    80002fa6:	ffffd097          	auipc	ra,0xffffd
    80002faa:	604080e7          	jalr	1540(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fb2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fb6:	00005517          	auipc	a0,0x5
    80002fba:	37250513          	addi	a0,a0,882 # 80008328 <etext+0x328>
    80002fbe:	ffffd097          	auipc	ra,0xffffd
    80002fc2:	5ec080e7          	jalr	1516(ra) # 800005aa <printf>
    setkilled(p);
    80002fc6:	8526                	mv	a0,s1
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	7e2080e7          	jalr	2018(ra) # 800027aa <setkilled>
  if (which_dev == 2 && p->alarm_interval > 0)
    80002fd0:	bf79                	j	80002f6e <usertrap+0xca>
      p->ticks = 0;        // Reset the tick count
    80002fd2:	0e04a023          	sw	zero,224(s1)
      p->alarm_active = 1; // Mark that handler is active to prevent re-entry
    80002fd6:	4785                	li	a5,1
    80002fd8:	20f4a823          	sw	a5,528(s1)
      memmove(&p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80002fdc:	12000613          	li	a2,288
    80002fe0:	2304b583          	ld	a1,560(s1)
    80002fe4:	0f048513          	addi	a0,s1,240
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	db2080e7          	jalr	-590(ra) # 80000d9a <memmove>
      p->trapframe->epc = p->handler;
    80002ff0:	2304b783          	ld	a5,560(s1)
    80002ff4:	74f8                	ld	a4,232(s1)
    80002ff6:	ef98                	sd	a4,24(a5)
    80002ff8:	bf19                	j	80002f0e <usertrap+0x6a>
      yield(); // Preempt the process after one tick
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	4ec080e7          	jalr	1260(ra) # 800024e6 <yield>
    80003002:	bf39                	j	80002f20 <usertrap+0x7c>
    exit(-1);
    80003004:	557d                	li	a0,-1
    80003006:	fffff097          	auipc	ra,0xfffff
    8000300a:	650080e7          	jalr	1616(ra) # 80002656 <exit>
  if (which_dev == 2)
    8000300e:	bf39                	j	80002f2c <usertrap+0x88>
    exit(-1);
    80003010:	557d                	li	a0,-1
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	644080e7          	jalr	1604(ra) # 80002656 <exit>
  if (which_dev == 2)
    8000301a:	b785                	j	80002f7a <usertrap+0xd6>

000000008000301c <kerneltrap>:
{
    8000301c:	7179                	addi	sp,sp,-48
    8000301e:	f406                	sd	ra,40(sp)
    80003020:	f022                	sd	s0,32(sp)
    80003022:	ec26                	sd	s1,24(sp)
    80003024:	e84a                	sd	s2,16(sp)
    80003026:	e44e                	sd	s3,8(sp)
    80003028:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000302a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000302e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003032:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80003036:	1004f793          	andi	a5,s1,256
    8000303a:	cb85                	beqz	a5,8000306a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000303c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003040:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003042:	ef85                	bnez	a5,8000307a <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003044:	00000097          	auipc	ra,0x0
    80003048:	db6080e7          	jalr	-586(ra) # 80002dfa <devintr>
    8000304c:	cd1d                	beqz	a0,8000308a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000304e:	4789                	li	a5,2
    80003050:	06f50a63          	beq	a0,a5,800030c4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003054:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003058:	10049073          	csrw	sstatus,s1
}
    8000305c:	70a2                	ld	ra,40(sp)
    8000305e:	7402                	ld	s0,32(sp)
    80003060:	64e2                	ld	s1,24(sp)
    80003062:	6942                	ld	s2,16(sp)
    80003064:	69a2                	ld	s3,8(sp)
    80003066:	6145                	addi	sp,sp,48
    80003068:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	2de50513          	addi	a0,a0,734 # 80008348 <etext+0x348>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	4ee080e7          	jalr	1262(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    8000307a:	00005517          	auipc	a0,0x5
    8000307e:	2f650513          	addi	a0,a0,758 # 80008370 <etext+0x370>
    80003082:	ffffd097          	auipc	ra,0xffffd
    80003086:	4de080e7          	jalr	1246(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    8000308a:	85ce                	mv	a1,s3
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	30450513          	addi	a0,a0,772 # 80008390 <etext+0x390>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	516080e7          	jalr	1302(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000309c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030a0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030a4:	00005517          	auipc	a0,0x5
    800030a8:	2fc50513          	addi	a0,a0,764 # 800083a0 <etext+0x3a0>
    800030ac:	ffffd097          	auipc	ra,0xffffd
    800030b0:	4fe080e7          	jalr	1278(ra) # 800005aa <printf>
    panic("kerneltrap");
    800030b4:	00005517          	auipc	a0,0x5
    800030b8:	30450513          	addi	a0,a0,772 # 800083b8 <etext+0x3b8>
    800030bc:	ffffd097          	auipc	ra,0xffffd
    800030c0:	4a4080e7          	jalr	1188(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030c4:	fffff097          	auipc	ra,0xfffff
    800030c8:	9ec080e7          	jalr	-1556(ra) # 80001ab0 <myproc>
    800030cc:	d541                	beqz	a0,80003054 <kerneltrap+0x38>
    800030ce:	fffff097          	auipc	ra,0xfffff
    800030d2:	9e2080e7          	jalr	-1566(ra) # 80001ab0 <myproc>
    800030d6:	4d18                	lw	a4,24(a0)
    800030d8:	4791                	li	a5,4
    800030da:	f6f71de3          	bne	a4,a5,80003054 <kerneltrap+0x38>
    yield();
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	408080e7          	jalr	1032(ra) # 800024e6 <yield>
    800030e6:	b7bd                	j	80003054 <kerneltrap+0x38>

00000000800030e8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	1000                	addi	s0,sp,32
    800030f2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	9bc080e7          	jalr	-1604(ra) # 80001ab0 <myproc>
  switch (n) {
    800030fc:	4795                	li	a5,5
    800030fe:	0497e763          	bltu	a5,s1,8000314c <argraw+0x64>
    80003102:	048a                	slli	s1,s1,0x2
    80003104:	00005717          	auipc	a4,0x5
    80003108:	67470713          	addi	a4,a4,1652 # 80008778 <states.0+0x30>
    8000310c:	94ba                	add	s1,s1,a4
    8000310e:	409c                	lw	a5,0(s1)
    80003110:	97ba                	add	a5,a5,a4
    80003112:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003114:	23053783          	ld	a5,560(a0)
    80003118:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000311a:	60e2                	ld	ra,24(sp)
    8000311c:	6442                	ld	s0,16(sp)
    8000311e:	64a2                	ld	s1,8(sp)
    80003120:	6105                	addi	sp,sp,32
    80003122:	8082                	ret
    return p->trapframe->a1;
    80003124:	23053783          	ld	a5,560(a0)
    80003128:	7fa8                	ld	a0,120(a5)
    8000312a:	bfc5                	j	8000311a <argraw+0x32>
    return p->trapframe->a2;
    8000312c:	23053783          	ld	a5,560(a0)
    80003130:	63c8                	ld	a0,128(a5)
    80003132:	b7e5                	j	8000311a <argraw+0x32>
    return p->trapframe->a3;
    80003134:	23053783          	ld	a5,560(a0)
    80003138:	67c8                	ld	a0,136(a5)
    8000313a:	b7c5                	j	8000311a <argraw+0x32>
    return p->trapframe->a4;
    8000313c:	23053783          	ld	a5,560(a0)
    80003140:	6bc8                	ld	a0,144(a5)
    80003142:	bfe1                	j	8000311a <argraw+0x32>
    return p->trapframe->a5;
    80003144:	23053783          	ld	a5,560(a0)
    80003148:	6fc8                	ld	a0,152(a5)
    8000314a:	bfc1                	j	8000311a <argraw+0x32>
  panic("argraw");
    8000314c:	00005517          	auipc	a0,0x5
    80003150:	27c50513          	addi	a0,a0,636 # 800083c8 <etext+0x3c8>
    80003154:	ffffd097          	auipc	ra,0xffffd
    80003158:	40c080e7          	jalr	1036(ra) # 80000560 <panic>

000000008000315c <fetchaddr>:
{
    8000315c:	1101                	addi	sp,sp,-32
    8000315e:	ec06                	sd	ra,24(sp)
    80003160:	e822                	sd	s0,16(sp)
    80003162:	e426                	sd	s1,8(sp)
    80003164:	e04a                	sd	s2,0(sp)
    80003166:	1000                	addi	s0,sp,32
    80003168:	84aa                	mv	s1,a0
    8000316a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000316c:	fffff097          	auipc	ra,0xfffff
    80003170:	944080e7          	jalr	-1724(ra) # 80001ab0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003174:	22053783          	ld	a5,544(a0)
    80003178:	02f4f963          	bgeu	s1,a5,800031aa <fetchaddr+0x4e>
    8000317c:	00848713          	addi	a4,s1,8
    80003180:	02e7e763          	bltu	a5,a4,800031ae <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003184:	46a1                	li	a3,8
    80003186:	8626                	mv	a2,s1
    80003188:	85ca                	mv	a1,s2
    8000318a:	22853503          	ld	a0,552(a0)
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	60e080e7          	jalr	1550(ra) # 8000179c <copyin>
    80003196:	00a03533          	snez	a0,a0
    8000319a:	40a0053b          	negw	a0,a0
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6902                	ld	s2,0(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret
    return -1;
    800031aa:	557d                	li	a0,-1
    800031ac:	bfcd                	j	8000319e <fetchaddr+0x42>
    800031ae:	557d                	li	a0,-1
    800031b0:	b7fd                	j	8000319e <fetchaddr+0x42>

00000000800031b2 <fetchstr>:
{
    800031b2:	7179                	addi	sp,sp,-48
    800031b4:	f406                	sd	ra,40(sp)
    800031b6:	f022                	sd	s0,32(sp)
    800031b8:	ec26                	sd	s1,24(sp)
    800031ba:	e84a                	sd	s2,16(sp)
    800031bc:	e44e                	sd	s3,8(sp)
    800031be:	1800                	addi	s0,sp,48
    800031c0:	892a                	mv	s2,a0
    800031c2:	84ae                	mv	s1,a1
    800031c4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	8ea080e7          	jalr	-1814(ra) # 80001ab0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800031ce:	86ce                	mv	a3,s3
    800031d0:	864a                	mv	a2,s2
    800031d2:	85a6                	mv	a1,s1
    800031d4:	22853503          	ld	a0,552(a0)
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	652080e7          	jalr	1618(ra) # 8000182a <copyinstr>
    800031e0:	00054e63          	bltz	a0,800031fc <fetchstr+0x4a>
  return strlen(buf);
    800031e4:	8526                	mv	a0,s1
    800031e6:	ffffe097          	auipc	ra,0xffffe
    800031ea:	cdc080e7          	jalr	-804(ra) # 80000ec2 <strlen>
}
    800031ee:	70a2                	ld	ra,40(sp)
    800031f0:	7402                	ld	s0,32(sp)
    800031f2:	64e2                	ld	s1,24(sp)
    800031f4:	6942                	ld	s2,16(sp)
    800031f6:	69a2                	ld	s3,8(sp)
    800031f8:	6145                	addi	sp,sp,48
    800031fa:	8082                	ret
    return -1;
    800031fc:	557d                	li	a0,-1
    800031fe:	bfc5                	j	800031ee <fetchstr+0x3c>

0000000080003200 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003200:	1101                	addi	sp,sp,-32
    80003202:	ec06                	sd	ra,24(sp)
    80003204:	e822                	sd	s0,16(sp)
    80003206:	e426                	sd	s1,8(sp)
    80003208:	1000                	addi	s0,sp,32
    8000320a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000320c:	00000097          	auipc	ra,0x0
    80003210:	edc080e7          	jalr	-292(ra) # 800030e8 <argraw>
    80003214:	c088                	sw	a0,0(s1)
}
    80003216:	60e2                	ld	ra,24(sp)
    80003218:	6442                	ld	s0,16(sp)
    8000321a:	64a2                	ld	s1,8(sp)
    8000321c:	6105                	addi	sp,sp,32
    8000321e:	8082                	ret

0000000080003220 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003220:	1101                	addi	sp,sp,-32
    80003222:	ec06                	sd	ra,24(sp)
    80003224:	e822                	sd	s0,16(sp)
    80003226:	e426                	sd	s1,8(sp)
    80003228:	1000                	addi	s0,sp,32
    8000322a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	ebc080e7          	jalr	-324(ra) # 800030e8 <argraw>
    80003234:	e088                	sd	a0,0(s1)
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	e426                	sd	s1,8(sp)
    80003248:	e04a                	sd	s2,0(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84ae                	mv	s1,a1
    8000324e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003250:	00000097          	auipc	ra,0x0
    80003254:	e98080e7          	jalr	-360(ra) # 800030e8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80003258:	864a                	mv	a2,s2
    8000325a:	85a6                	mv	a1,s1
    8000325c:	00000097          	auipc	ra,0x0
    80003260:	f56080e7          	jalr	-170(ra) # 800031b2 <fetchstr>
}
    80003264:	60e2                	ld	ra,24(sp)
    80003266:	6442                	ld	s0,16(sp)
    80003268:	64a2                	ld	s1,8(sp)
    8000326a:	6902                	ld	s2,0(sp)
    8000326c:	6105                	addi	sp,sp,32
    8000326e:	8082                	ret

0000000080003270 <syscall>:
    [SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80003270:	7179                	addi	sp,sp,-48
    80003272:	f406                	sd	ra,40(sp)
    80003274:	f022                	sd	s0,32(sp)
    80003276:	ec26                	sd	s1,24(sp)
    80003278:	e84a                	sd	s2,16(sp)
    8000327a:	e44e                	sd	s3,8(sp)
    8000327c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    8000327e:	fffff097          	auipc	ra,0xfffff
    80003282:	832080e7          	jalr	-1998(ra) # 80001ab0 <myproc>
    80003286:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003288:	23053983          	ld	s3,560(a0)
    8000328c:	0a89a903          	lw	s2,168(s3)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003290:	fff9071b          	addiw	a4,s2,-1
    80003294:	47e5                	li	a5,25
    80003296:	02e7ec63          	bltu	a5,a4,800032ce <syscall+0x5e>
    8000329a:	e052                	sd	s4,0(sp)
    8000329c:	00391713          	slli	a4,s2,0x3
    800032a0:	00005797          	auipc	a5,0x5
    800032a4:	4f078793          	addi	a5,a5,1264 # 80008790 <syscalls>
    800032a8:	97ba                	add	a5,a5,a4
    800032aa:	639c                	ld	a5,0(a5)
    800032ac:	c385                	beqz	a5,800032cc <syscall+0x5c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800032ae:	9782                	jalr	a5
    800032b0:	06a9b823          	sd	a0,112(s3)
    if(num<26 && num>=0)
    800032b4:	47e5                	li	a5,25
    800032b6:	0527e363          	bltu	a5,s2,800032fc <syscall+0x8c>
    {
      p->syscall_count[num]++;
    800032ba:	090a                	slli	s2,s2,0x2
    800032bc:	9926                	add	s2,s2,s1
    800032be:	04092783          	lw	a5,64(s2)
    800032c2:	2785                	addiw	a5,a5,1
    800032c4:	04f92023          	sw	a5,64(s2)
    800032c8:	6a02                	ld	s4,0(sp)
    800032ca:	a015                	j	800032ee <syscall+0x7e>
    800032cc:	6a02                	ld	s4,0(sp)
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032ce:	86ca                	mv	a3,s2
    800032d0:	33048613          	addi	a2,s1,816
    800032d4:	588c                	lw	a1,48(s1)
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	0fa50513          	addi	a0,a0,250 # 800083d0 <etext+0x3d0>
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	2cc080e7          	jalr	716(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032e6:	2304b783          	ld	a5,560(s1)
    800032ea:	577d                	li	a4,-1
    800032ec:	fbb8                	sd	a4,112(a5)
  }
}
    800032ee:	70a2                	ld	ra,40(sp)
    800032f0:	7402                	ld	s0,32(sp)
    800032f2:	64e2                	ld	s1,24(sp)
    800032f4:	6942                	ld	s2,16(sp)
    800032f6:	69a2                	ld	s3,8(sp)
    800032f8:	6145                	addi	sp,sp,48
    800032fa:	8082                	ret
    800032fc:	6a02                	ld	s4,0(sp)
    800032fe:	bfc5                	j	800032ee <syscall+0x7e>

0000000080003300 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003300:	1101                	addi	sp,sp,-32
    80003302:	ec06                	sd	ra,24(sp)
    80003304:	e822                	sd	s0,16(sp)
    80003306:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003308:	fec40593          	addi	a1,s0,-20
    8000330c:	4501                	li	a0,0
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	ef2080e7          	jalr	-270(ra) # 80003200 <argint>
  exit(n);
    80003316:	fec42503          	lw	a0,-20(s0)
    8000331a:	fffff097          	auipc	ra,0xfffff
    8000331e:	33c080e7          	jalr	828(ra) # 80002656 <exit>
  return 0; // not reached
}
    80003322:	4501                	li	a0,0
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret

000000008000332c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000332c:	1141                	addi	sp,sp,-16
    8000332e:	e406                	sd	ra,8(sp)
    80003330:	e022                	sd	s0,0(sp)
    80003332:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	77c080e7          	jalr	1916(ra) # 80001ab0 <myproc>
}
    8000333c:	5908                	lw	a0,48(a0)
    8000333e:	60a2                	ld	ra,8(sp)
    80003340:	6402                	ld	s0,0(sp)
    80003342:	0141                	addi	sp,sp,16
    80003344:	8082                	ret

0000000080003346 <sys_fork>:

uint64
sys_fork(void)
{
    80003346:	1141                	addi	sp,sp,-16
    80003348:	e406                	sd	ra,8(sp)
    8000334a:	e022                	sd	s0,0(sp)
    8000334c:	0800                	addi	s0,sp,16
  return fork();
    8000334e:	fffff097          	auipc	ra,0xfffff
    80003352:	b84080e7          	jalr	-1148(ra) # 80001ed2 <fork>
}
    80003356:	60a2                	ld	ra,8(sp)
    80003358:	6402                	ld	s0,0(sp)
    8000335a:	0141                	addi	sp,sp,16
    8000335c:	8082                	ret

000000008000335e <sys_wait>:

uint64
sys_wait(void)
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003366:	fe840593          	addi	a1,s0,-24
    8000336a:	4501                	li	a0,0
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	eb4080e7          	jalr	-332(ra) # 80003220 <argaddr>
  return wait(p);
    80003374:	fe843503          	ld	a0,-24(s0)
    80003378:	fffff097          	auipc	ra,0xfffff
    8000337c:	490080e7          	jalr	1168(ra) # 80002808 <wait>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	6105                	addi	sp,sp,32
    80003386:	8082                	ret

0000000080003388 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003388:	7179                	addi	sp,sp,-48
    8000338a:	f406                	sd	ra,40(sp)
    8000338c:	f022                	sd	s0,32(sp)
    8000338e:	ec26                	sd	s1,24(sp)
    80003390:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003392:	fdc40593          	addi	a1,s0,-36
    80003396:	4501                	li	a0,0
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e68080e7          	jalr	-408(ra) # 80003200 <argint>
  addr = myproc()->sz;
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	710080e7          	jalr	1808(ra) # 80001ab0 <myproc>
    800033a8:	22053483          	ld	s1,544(a0)
  if (growproc(n) < 0)
    800033ac:	fdc42503          	lw	a0,-36(s0)
    800033b0:	fffff097          	auipc	ra,0xfffff
    800033b4:	abe080e7          	jalr	-1346(ra) # 80001e6e <growproc>
    800033b8:	00054863          	bltz	a0,800033c8 <sys_sbrk+0x40>
    return -1;
  return addr;
}
    800033bc:	8526                	mv	a0,s1
    800033be:	70a2                	ld	ra,40(sp)
    800033c0:	7402                	ld	s0,32(sp)
    800033c2:	64e2                	ld	s1,24(sp)
    800033c4:	6145                	addi	sp,sp,48
    800033c6:	8082                	ret
    return -1;
    800033c8:	54fd                	li	s1,-1
    800033ca:	bfcd                	j	800033bc <sys_sbrk+0x34>

00000000800033cc <sys_sleep>:

uint64
sys_sleep(void)
{
    800033cc:	7139                	addi	sp,sp,-64
    800033ce:	fc06                	sd	ra,56(sp)
    800033d0:	f822                	sd	s0,48(sp)
    800033d2:	f04a                	sd	s2,32(sp)
    800033d4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800033d6:	fcc40593          	addi	a1,s0,-52
    800033da:	4501                	li	a0,0
    800033dc:	00000097          	auipc	ra,0x0
    800033e0:	e24080e7          	jalr	-476(ra) # 80003200 <argint>
  acquire(&tickslock);
    800033e4:	0001b517          	auipc	a0,0x1b
    800033e8:	7cc50513          	addi	a0,a0,1996 # 8001ebb0 <tickslock>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	852080e7          	jalr	-1966(ra) # 80000c3e <acquire>
  ticks0 = ticks;
    800033f4:	00005917          	auipc	s2,0x5
    800033f8:	51092903          	lw	s2,1296(s2) # 80008904 <ticks>
  while (ticks - ticks0 < n)
    800033fc:	fcc42783          	lw	a5,-52(s0)
    80003400:	c3b9                	beqz	a5,80003446 <sys_sleep+0x7a>
    80003402:	f426                	sd	s1,40(sp)
    80003404:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003406:	0001b997          	auipc	s3,0x1b
    8000340a:	7aa98993          	addi	s3,s3,1962 # 8001ebb0 <tickslock>
    8000340e:	00005497          	auipc	s1,0x5
    80003412:	4f648493          	addi	s1,s1,1270 # 80008904 <ticks>
    if (killed(myproc()))
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	69a080e7          	jalr	1690(ra) # 80001ab0 <myproc>
    8000341e:	fffff097          	auipc	ra,0xfffff
    80003422:	3b8080e7          	jalr	952(ra) # 800027d6 <killed>
    80003426:	ed15                	bnez	a0,80003462 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003428:	85ce                	mv	a1,s3
    8000342a:	8526                	mv	a0,s1
    8000342c:	fffff097          	auipc	ra,0xfffff
    80003430:	0f6080e7          	jalr	246(ra) # 80002522 <sleep>
  while (ticks - ticks0 < n)
    80003434:	409c                	lw	a5,0(s1)
    80003436:	412787bb          	subw	a5,a5,s2
    8000343a:	fcc42703          	lw	a4,-52(s0)
    8000343e:	fce7ece3          	bltu	a5,a4,80003416 <sys_sleep+0x4a>
    80003442:	74a2                	ld	s1,40(sp)
    80003444:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003446:	0001b517          	auipc	a0,0x1b
    8000344a:	76a50513          	addi	a0,a0,1898 # 8001ebb0 <tickslock>
    8000344e:	ffffe097          	auipc	ra,0xffffe
    80003452:	8a0080e7          	jalr	-1888(ra) # 80000cee <release>
  return 0;
    80003456:	4501                	li	a0,0
}
    80003458:	70e2                	ld	ra,56(sp)
    8000345a:	7442                	ld	s0,48(sp)
    8000345c:	7902                	ld	s2,32(sp)
    8000345e:	6121                	addi	sp,sp,64
    80003460:	8082                	ret
      release(&tickslock);
    80003462:	0001b517          	auipc	a0,0x1b
    80003466:	74e50513          	addi	a0,a0,1870 # 8001ebb0 <tickslock>
    8000346a:	ffffe097          	auipc	ra,0xffffe
    8000346e:	884080e7          	jalr	-1916(ra) # 80000cee <release>
      return -1;
    80003472:	557d                	li	a0,-1
    80003474:	74a2                	ld	s1,40(sp)
    80003476:	69e2                	ld	s3,24(sp)
    80003478:	b7c5                	j	80003458 <sys_sleep+0x8c>

000000008000347a <sys_kill>:

uint64
sys_kill(void)
{
    8000347a:	1101                	addi	sp,sp,-32
    8000347c:	ec06                	sd	ra,24(sp)
    8000347e:	e822                	sd	s0,16(sp)
    80003480:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003482:	fec40593          	addi	a1,s0,-20
    80003486:	4501                	li	a0,0
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	d78080e7          	jalr	-648(ra) # 80003200 <argint>
  return kill(pid);
    80003490:	fec42503          	lw	a0,-20(s0)
    80003494:	fffff097          	auipc	ra,0xfffff
    80003498:	2a4080e7          	jalr	676(ra) # 80002738 <kill>
}
    8000349c:	60e2                	ld	ra,24(sp)
    8000349e:	6442                	ld	s0,16(sp)
    800034a0:	6105                	addi	sp,sp,32
    800034a2:	8082                	ret

00000000800034a4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034a4:	1101                	addi	sp,sp,-32
    800034a6:	ec06                	sd	ra,24(sp)
    800034a8:	e822                	sd	s0,16(sp)
    800034aa:	e426                	sd	s1,8(sp)
    800034ac:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034ae:	0001b517          	auipc	a0,0x1b
    800034b2:	70250513          	addi	a0,a0,1794 # 8001ebb0 <tickslock>
    800034b6:	ffffd097          	auipc	ra,0xffffd
    800034ba:	788080e7          	jalr	1928(ra) # 80000c3e <acquire>
  xticks = ticks;
    800034be:	00005497          	auipc	s1,0x5
    800034c2:	4464a483          	lw	s1,1094(s1) # 80008904 <ticks>
  release(&tickslock);
    800034c6:	0001b517          	auipc	a0,0x1b
    800034ca:	6ea50513          	addi	a0,a0,1770 # 8001ebb0 <tickslock>
    800034ce:	ffffe097          	auipc	ra,0xffffe
    800034d2:	820080e7          	jalr	-2016(ra) # 80000cee <release>
  return xticks;
}
    800034d6:	02049513          	slli	a0,s1,0x20
    800034da:	9101                	srli	a0,a0,0x20
    800034dc:	60e2                	ld	ra,24(sp)
    800034de:	6442                	ld	s0,16(sp)
    800034e0:	64a2                	ld	s1,8(sp)
    800034e2:	6105                	addi	sp,sp,32
    800034e4:	8082                	ret

00000000800034e6 <sys_waitx>:

uint64
sys_waitx(void)
{
    800034e6:	715d                	addi	sp,sp,-80
    800034e8:	e486                	sd	ra,72(sp)
    800034ea:	e0a2                	sd	s0,64(sp)
    800034ec:	fc26                	sd	s1,56(sp)
    800034ee:	f84a                	sd	s2,48(sp)
    800034f0:	f44e                	sd	s3,40(sp)
    800034f2:	0880                	addi	s0,sp,80
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800034f4:	fc840593          	addi	a1,s0,-56
    800034f8:	4501                	li	a0,0
    800034fa:	00000097          	auipc	ra,0x0
    800034fe:	d26080e7          	jalr	-730(ra) # 80003220 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003502:	fc040593          	addi	a1,s0,-64
    80003506:	4505                	li	a0,1
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	d18080e7          	jalr	-744(ra) # 80003220 <argaddr>
  argaddr(2, &addr2);
    80003510:	fb840593          	addi	a1,s0,-72
    80003514:	4509                	li	a0,2
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	d0a080e7          	jalr	-758(ra) # 80003220 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000351e:	fb440993          	addi	s3,s0,-76
    80003522:	fb040613          	addi	a2,s0,-80
    80003526:	85ce                	mv	a1,s3
    80003528:	fc843503          	ld	a0,-56(s0)
    8000352c:	fffff097          	auipc	ra,0xfffff
    80003530:	584080e7          	jalr	1412(ra) # 80002ab0 <waitx>
    80003534:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003536:	ffffe097          	auipc	ra,0xffffe
    8000353a:	57a080e7          	jalr	1402(ra) # 80001ab0 <myproc>
    8000353e:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003540:	4691                	li	a3,4
    80003542:	864e                	mv	a2,s3
    80003544:	fc043583          	ld	a1,-64(s0)
    80003548:	22853503          	ld	a0,552(a0)
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	1c4080e7          	jalr	452(ra) # 80001710 <copyout>
    return -1;
    80003554:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003556:	02054063          	bltz	a0,80003576 <sys_waitx+0x90>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000355a:	4691                	li	a3,4
    8000355c:	fb040613          	addi	a2,s0,-80
    80003560:	fb843583          	ld	a1,-72(s0)
    80003564:	2284b503          	ld	a0,552(s1)
    80003568:	ffffe097          	auipc	ra,0xffffe
    8000356c:	1a8080e7          	jalr	424(ra) # 80001710 <copyout>
    80003570:	00054b63          	bltz	a0,80003586 <sys_waitx+0xa0>
    return -1;
  return ret;
    80003574:	87ca                	mv	a5,s2
}
    80003576:	853e                	mv	a0,a5
    80003578:	60a6                	ld	ra,72(sp)
    8000357a:	6406                	ld	s0,64(sp)
    8000357c:	74e2                	ld	s1,56(sp)
    8000357e:	7942                	ld	s2,48(sp)
    80003580:	79a2                	ld	s3,40(sp)
    80003582:	6161                	addi	sp,sp,80
    80003584:	8082                	ret
    return -1;
    80003586:	57fd                	li	a5,-1
    80003588:	b7fd                	j	80003576 <sys_waitx+0x90>

000000008000358a <sys_getSysCount>:

uint64
sys_getSysCount(void)
{
    8000358a:	1101                	addi	sp,sp,-32
    8000358c:	ec06                	sd	ra,24(sp)
    8000358e:	e822                	sd	s0,16(sp)
    80003590:	1000                	addi	s0,sp,32
  int k;
  argint(0, &k);
    80003592:	fec40593          	addi	a1,s0,-20
    80003596:	4501                	li	a0,0
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	c68080e7          	jalr	-920(ra) # 80003200 <argint>
  struct proc *p = myproc();
    800035a0:	ffffe097          	auipc	ra,0xffffe
    800035a4:	510080e7          	jalr	1296(ra) # 80001ab0 <myproc>
  return p->syscall_count[k];
    800035a8:	fec42783          	lw	a5,-20(s0)
    800035ac:	07c1                	addi	a5,a5,16
    800035ae:	078a                	slli	a5,a5,0x2
    800035b0:	953e                	add	a0,a0,a5
}
    800035b2:	4108                	lw	a0,0(a0)
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	6105                	addi	sp,sp,32
    800035ba:	8082                	ret

00000000800035bc <sys_sigalarm>:

// In sysproc.c
uint64 sys_sigalarm(void)
{
    800035bc:	1101                	addi	sp,sp,-32
    800035be:	ec06                	sd	ra,24(sp)
    800035c0:	e822                	sd	s0,16(sp)
    800035c2:	1000                	addi	s0,sp,32
  int interval;
  uint64 handler;
  argaddr(1, &handler);
    800035c4:	fe040593          	addi	a1,s0,-32
    800035c8:	4505                	li	a0,1
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	c56080e7          	jalr	-938(ra) # 80003220 <argaddr>
  argint(0, &interval);
    800035d2:	fec40593          	addi	a1,s0,-20
    800035d6:	4501                	li	a0,0
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	c28080e7          	jalr	-984(ra) # 80003200 <argint>

  struct proc *p = myproc();
    800035e0:	ffffe097          	auipc	ra,0xffffe
    800035e4:	4d0080e7          	jalr	1232(ra) # 80001ab0 <myproc>
  p->alarm_interval = interval;
    800035e8:	fec42783          	lw	a5,-20(s0)
    800035ec:	0ef52223          	sw	a5,228(a0)
  p->handler = handler;
    800035f0:	fe043783          	ld	a5,-32(s0)
    800035f4:	f57c                	sd	a5,232(a0)
  p->ticks = 0;
    800035f6:	0e052023          	sw	zero,224(a0)
  p->alarm_active = 0; // Reset ticks
    800035fa:	20052823          	sw	zero,528(a0)

  return 0; // Success
}
    800035fe:	4501                	li	a0,0
    80003600:	60e2                	ld	ra,24(sp)
    80003602:	6442                	ld	s0,16(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret

0000000080003608 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    80003608:	1101                	addi	sp,sp,-32
    8000360a:	ec06                	sd	ra,24(sp)
    8000360c:	e822                	sd	s0,16(sp)
    8000360e:	e426                	sd	s1,8(sp)
    80003610:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003612:	ffffe097          	auipc	ra,0xffffe
    80003616:	49e080e7          	jalr	1182(ra) # 80001ab0 <myproc>
    8000361a:	84aa                	mv	s1,a0
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe)); // Restore context
    8000361c:	12000613          	li	a2,288
    80003620:	0f050593          	addi	a1,a0,240
    80003624:	23053503          	ld	a0,560(a0)
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	772080e7          	jalr	1906(ra) # 80000d9a <memmove>
  p->alarm_active = 0;                                           // Allow future alarms
    80003630:	2004a823          	sw	zero,528(s1)
  uint64 return_value = p->trapframe->a0;
    80003634:	2304b783          	ld	a5,560(s1)
  return return_value;
}
    80003638:	7ba8                	ld	a0,112(a5)
    8000363a:	60e2                	ld	ra,24(sp)
    8000363c:	6442                	ld	s0,16(sp)
    8000363e:	64a2                	ld	s1,8(sp)
    80003640:	6105                	addi	sp,sp,32
    80003642:	8082                	ret

0000000080003644 <sys_settickets>:

uint64
sys_settickets(void)
{
    80003644:	1101                	addi	sp,sp,-32
    80003646:	ec06                	sd	ra,24(sp)
    80003648:	e822                	sd	s0,16(sp)
    8000364a:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    8000364c:	fec40593          	addi	a1,s0,-20
    80003650:	4501                	li	a0,0
    80003652:	00000097          	auipc	ra,0x0
    80003656:	bae080e7          	jalr	-1106(ra) # 80003200 <argint>
  if (number < 1)
    8000365a:	fec42783          	lw	a5,-20(s0)
    return -1;
    8000365e:	557d                	li	a0,-1
  if (number < 1)
    80003660:	00f05b63          	blez	a5,80003676 <sys_settickets+0x32>
  struct proc *p = myproc();
    80003664:	ffffe097          	auipc	ra,0xffffe
    80003668:	44c080e7          	jalr	1100(ra) # 80001ab0 <myproc>
  p->tickets = number;
    8000366c:	fec42783          	lw	a5,-20(s0)
    80003670:	0cf52023          	sw	a5,192(a0)
  return 0;
    80003674:	4501                	li	a0,0
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	6105                	addi	sp,sp,32
    8000367c:	8082                	ret

000000008000367e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000367e:	7179                	addi	sp,sp,-48
    80003680:	f406                	sd	ra,40(sp)
    80003682:	f022                	sd	s0,32(sp)
    80003684:	ec26                	sd	s1,24(sp)
    80003686:	e84a                	sd	s2,16(sp)
    80003688:	e44e                	sd	s3,8(sp)
    8000368a:	e052                	sd	s4,0(sp)
    8000368c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000368e:	00005597          	auipc	a1,0x5
    80003692:	d6258593          	addi	a1,a1,-670 # 800083f0 <etext+0x3f0>
    80003696:	0001b517          	auipc	a0,0x1b
    8000369a:	53250513          	addi	a0,a0,1330 # 8001ebc8 <bcache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	50c080e7          	jalr	1292(ra) # 80000baa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036a6:	00023797          	auipc	a5,0x23
    800036aa:	52278793          	addi	a5,a5,1314 # 80026bc8 <bcache+0x8000>
    800036ae:	00023717          	auipc	a4,0x23
    800036b2:	78270713          	addi	a4,a4,1922 # 80026e30 <bcache+0x8268>
    800036b6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036ba:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036be:	0001b497          	auipc	s1,0x1b
    800036c2:	52248493          	addi	s1,s1,1314 # 8001ebe0 <bcache+0x18>
    b->next = bcache.head.next;
    800036c6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036c8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036ca:	00005a17          	auipc	s4,0x5
    800036ce:	d2ea0a13          	addi	s4,s4,-722 # 800083f8 <etext+0x3f8>
    b->next = bcache.head.next;
    800036d2:	2b893783          	ld	a5,696(s2)
    800036d6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036d8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036dc:	85d2                	mv	a1,s4
    800036de:	01048513          	addi	a0,s1,16
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	4e4080e7          	jalr	1252(ra) # 80004bc6 <initsleeplock>
    bcache.head.next->prev = b;
    800036ea:	2b893783          	ld	a5,696(s2)
    800036ee:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800036f0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036f4:	45848493          	addi	s1,s1,1112
    800036f8:	fd349de3          	bne	s1,s3,800036d2 <binit+0x54>
  }
}
    800036fc:	70a2                	ld	ra,40(sp)
    800036fe:	7402                	ld	s0,32(sp)
    80003700:	64e2                	ld	s1,24(sp)
    80003702:	6942                	ld	s2,16(sp)
    80003704:	69a2                	ld	s3,8(sp)
    80003706:	6a02                	ld	s4,0(sp)
    80003708:	6145                	addi	sp,sp,48
    8000370a:	8082                	ret

000000008000370c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000370c:	7179                	addi	sp,sp,-48
    8000370e:	f406                	sd	ra,40(sp)
    80003710:	f022                	sd	s0,32(sp)
    80003712:	ec26                	sd	s1,24(sp)
    80003714:	e84a                	sd	s2,16(sp)
    80003716:	e44e                	sd	s3,8(sp)
    80003718:	1800                	addi	s0,sp,48
    8000371a:	892a                	mv	s2,a0
    8000371c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000371e:	0001b517          	auipc	a0,0x1b
    80003722:	4aa50513          	addi	a0,a0,1194 # 8001ebc8 <bcache>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	518080e7          	jalr	1304(ra) # 80000c3e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000372e:	00023497          	auipc	s1,0x23
    80003732:	7524b483          	ld	s1,1874(s1) # 80026e80 <bcache+0x82b8>
    80003736:	00023797          	auipc	a5,0x23
    8000373a:	6fa78793          	addi	a5,a5,1786 # 80026e30 <bcache+0x8268>
    8000373e:	02f48f63          	beq	s1,a5,8000377c <bread+0x70>
    80003742:	873e                	mv	a4,a5
    80003744:	a021                	j	8000374c <bread+0x40>
    80003746:	68a4                	ld	s1,80(s1)
    80003748:	02e48a63          	beq	s1,a4,8000377c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000374c:	449c                	lw	a5,8(s1)
    8000374e:	ff279ce3          	bne	a5,s2,80003746 <bread+0x3a>
    80003752:	44dc                	lw	a5,12(s1)
    80003754:	ff3799e3          	bne	a5,s3,80003746 <bread+0x3a>
      b->refcnt++;
    80003758:	40bc                	lw	a5,64(s1)
    8000375a:	2785                	addiw	a5,a5,1
    8000375c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000375e:	0001b517          	auipc	a0,0x1b
    80003762:	46a50513          	addi	a0,a0,1130 # 8001ebc8 <bcache>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	588080e7          	jalr	1416(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    8000376e:	01048513          	addi	a0,s1,16
    80003772:	00001097          	auipc	ra,0x1
    80003776:	48e080e7          	jalr	1166(ra) # 80004c00 <acquiresleep>
      return b;
    8000377a:	a8b9                	j	800037d8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000377c:	00023497          	auipc	s1,0x23
    80003780:	6fc4b483          	ld	s1,1788(s1) # 80026e78 <bcache+0x82b0>
    80003784:	00023797          	auipc	a5,0x23
    80003788:	6ac78793          	addi	a5,a5,1708 # 80026e30 <bcache+0x8268>
    8000378c:	00f48863          	beq	s1,a5,8000379c <bread+0x90>
    80003790:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003792:	40bc                	lw	a5,64(s1)
    80003794:	cf81                	beqz	a5,800037ac <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003796:	64a4                	ld	s1,72(s1)
    80003798:	fee49de3          	bne	s1,a4,80003792 <bread+0x86>
  panic("bget: no buffers");
    8000379c:	00005517          	auipc	a0,0x5
    800037a0:	c6450513          	addi	a0,a0,-924 # 80008400 <etext+0x400>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	dbc080e7          	jalr	-580(ra) # 80000560 <panic>
      b->dev = dev;
    800037ac:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037b0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037b4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037b8:	4785                	li	a5,1
    800037ba:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037bc:	0001b517          	auipc	a0,0x1b
    800037c0:	40c50513          	addi	a0,a0,1036 # 8001ebc8 <bcache>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	52a080e7          	jalr	1322(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    800037cc:	01048513          	addi	a0,s1,16
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	430080e7          	jalr	1072(ra) # 80004c00 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037d8:	409c                	lw	a5,0(s1)
    800037da:	cb89                	beqz	a5,800037ec <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037dc:	8526                	mv	a0,s1
    800037de:	70a2                	ld	ra,40(sp)
    800037e0:	7402                	ld	s0,32(sp)
    800037e2:	64e2                	ld	s1,24(sp)
    800037e4:	6942                	ld	s2,16(sp)
    800037e6:	69a2                	ld	s3,8(sp)
    800037e8:	6145                	addi	sp,sp,48
    800037ea:	8082                	ret
    virtio_disk_rw(b, 0);
    800037ec:	4581                	li	a1,0
    800037ee:	8526                	mv	a0,s1
    800037f0:	00003097          	auipc	ra,0x3
    800037f4:	118080e7          	jalr	280(ra) # 80006908 <virtio_disk_rw>
    b->valid = 1;
    800037f8:	4785                	li	a5,1
    800037fa:	c09c                	sw	a5,0(s1)
  return b;
    800037fc:	b7c5                	j	800037dc <bread+0xd0>

00000000800037fe <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800037fe:	1101                	addi	sp,sp,-32
    80003800:	ec06                	sd	ra,24(sp)
    80003802:	e822                	sd	s0,16(sp)
    80003804:	e426                	sd	s1,8(sp)
    80003806:	1000                	addi	s0,sp,32
    80003808:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000380a:	0541                	addi	a0,a0,16
    8000380c:	00001097          	auipc	ra,0x1
    80003810:	48e080e7          	jalr	1166(ra) # 80004c9a <holdingsleep>
    80003814:	cd01                	beqz	a0,8000382c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003816:	4585                	li	a1,1
    80003818:	8526                	mv	a0,s1
    8000381a:	00003097          	auipc	ra,0x3
    8000381e:	0ee080e7          	jalr	238(ra) # 80006908 <virtio_disk_rw>
}
    80003822:	60e2                	ld	ra,24(sp)
    80003824:	6442                	ld	s0,16(sp)
    80003826:	64a2                	ld	s1,8(sp)
    80003828:	6105                	addi	sp,sp,32
    8000382a:	8082                	ret
    panic("bwrite");
    8000382c:	00005517          	auipc	a0,0x5
    80003830:	bec50513          	addi	a0,a0,-1044 # 80008418 <etext+0x418>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	d2c080e7          	jalr	-724(ra) # 80000560 <panic>

000000008000383c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000383c:	1101                	addi	sp,sp,-32
    8000383e:	ec06                	sd	ra,24(sp)
    80003840:	e822                	sd	s0,16(sp)
    80003842:	e426                	sd	s1,8(sp)
    80003844:	e04a                	sd	s2,0(sp)
    80003846:	1000                	addi	s0,sp,32
    80003848:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000384a:	01050913          	addi	s2,a0,16
    8000384e:	854a                	mv	a0,s2
    80003850:	00001097          	auipc	ra,0x1
    80003854:	44a080e7          	jalr	1098(ra) # 80004c9a <holdingsleep>
    80003858:	c535                	beqz	a0,800038c4 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    8000385a:	854a                	mv	a0,s2
    8000385c:	00001097          	auipc	ra,0x1
    80003860:	3fa080e7          	jalr	1018(ra) # 80004c56 <releasesleep>

  acquire(&bcache.lock);
    80003864:	0001b517          	auipc	a0,0x1b
    80003868:	36450513          	addi	a0,a0,868 # 8001ebc8 <bcache>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	3d2080e7          	jalr	978(ra) # 80000c3e <acquire>
  b->refcnt--;
    80003874:	40bc                	lw	a5,64(s1)
    80003876:	37fd                	addiw	a5,a5,-1
    80003878:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000387a:	e79d                	bnez	a5,800038a8 <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000387c:	68b8                	ld	a4,80(s1)
    8000387e:	64bc                	ld	a5,72(s1)
    80003880:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003882:	68b8                	ld	a4,80(s1)
    80003884:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003886:	00023797          	auipc	a5,0x23
    8000388a:	34278793          	addi	a5,a5,834 # 80026bc8 <bcache+0x8000>
    8000388e:	2b87b703          	ld	a4,696(a5)
    80003892:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003894:	00023717          	auipc	a4,0x23
    80003898:	59c70713          	addi	a4,a4,1436 # 80026e30 <bcache+0x8268>
    8000389c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000389e:	2b87b703          	ld	a4,696(a5)
    800038a2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038a4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038a8:	0001b517          	auipc	a0,0x1b
    800038ac:	32050513          	addi	a0,a0,800 # 8001ebc8 <bcache>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	43e080e7          	jalr	1086(ra) # 80000cee <release>
}
    800038b8:	60e2                	ld	ra,24(sp)
    800038ba:	6442                	ld	s0,16(sp)
    800038bc:	64a2                	ld	s1,8(sp)
    800038be:	6902                	ld	s2,0(sp)
    800038c0:	6105                	addi	sp,sp,32
    800038c2:	8082                	ret
    panic("brelse");
    800038c4:	00005517          	auipc	a0,0x5
    800038c8:	b5c50513          	addi	a0,a0,-1188 # 80008420 <etext+0x420>
    800038cc:	ffffd097          	auipc	ra,0xffffd
    800038d0:	c94080e7          	jalr	-876(ra) # 80000560 <panic>

00000000800038d4 <bpin>:

void
bpin(struct buf *b) {
    800038d4:	1101                	addi	sp,sp,-32
    800038d6:	ec06                	sd	ra,24(sp)
    800038d8:	e822                	sd	s0,16(sp)
    800038da:	e426                	sd	s1,8(sp)
    800038dc:	1000                	addi	s0,sp,32
    800038de:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038e0:	0001b517          	auipc	a0,0x1b
    800038e4:	2e850513          	addi	a0,a0,744 # 8001ebc8 <bcache>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	356080e7          	jalr	854(ra) # 80000c3e <acquire>
  b->refcnt++;
    800038f0:	40bc                	lw	a5,64(s1)
    800038f2:	2785                	addiw	a5,a5,1
    800038f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038f6:	0001b517          	auipc	a0,0x1b
    800038fa:	2d250513          	addi	a0,a0,722 # 8001ebc8 <bcache>
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	3f0080e7          	jalr	1008(ra) # 80000cee <release>
}
    80003906:	60e2                	ld	ra,24(sp)
    80003908:	6442                	ld	s0,16(sp)
    8000390a:	64a2                	ld	s1,8(sp)
    8000390c:	6105                	addi	sp,sp,32
    8000390e:	8082                	ret

0000000080003910 <bunpin>:

void
bunpin(struct buf *b) {
    80003910:	1101                	addi	sp,sp,-32
    80003912:	ec06                	sd	ra,24(sp)
    80003914:	e822                	sd	s0,16(sp)
    80003916:	e426                	sd	s1,8(sp)
    80003918:	1000                	addi	s0,sp,32
    8000391a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000391c:	0001b517          	auipc	a0,0x1b
    80003920:	2ac50513          	addi	a0,a0,684 # 8001ebc8 <bcache>
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	31a080e7          	jalr	794(ra) # 80000c3e <acquire>
  b->refcnt--;
    8000392c:	40bc                	lw	a5,64(s1)
    8000392e:	37fd                	addiw	a5,a5,-1
    80003930:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003932:	0001b517          	auipc	a0,0x1b
    80003936:	29650513          	addi	a0,a0,662 # 8001ebc8 <bcache>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	3b4080e7          	jalr	948(ra) # 80000cee <release>
}
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	64a2                	ld	s1,8(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret

000000008000394c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	e04a                	sd	s2,0(sp)
    80003956:	1000                	addi	s0,sp,32
    80003958:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000395a:	00d5d79b          	srliw	a5,a1,0xd
    8000395e:	00024597          	auipc	a1,0x24
    80003962:	9465a583          	lw	a1,-1722(a1) # 800272a4 <sb+0x1c>
    80003966:	9dbd                	addw	a1,a1,a5
    80003968:	00000097          	auipc	ra,0x0
    8000396c:	da4080e7          	jalr	-604(ra) # 8000370c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003970:	0074f713          	andi	a4,s1,7
    80003974:	4785                	li	a5,1
    80003976:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000397a:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000397c:	90d9                	srli	s1,s1,0x36
    8000397e:	00950733          	add	a4,a0,s1
    80003982:	05874703          	lbu	a4,88(a4)
    80003986:	00e7f6b3          	and	a3,a5,a4
    8000398a:	c69d                	beqz	a3,800039b8 <bfree+0x6c>
    8000398c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000398e:	94aa                	add	s1,s1,a0
    80003990:	fff7c793          	not	a5,a5
    80003994:	8f7d                	and	a4,a4,a5
    80003996:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	148080e7          	jalr	328(ra) # 80004ae2 <log_write>
  brelse(bp);
    800039a2:	854a                	mv	a0,s2
    800039a4:	00000097          	auipc	ra,0x0
    800039a8:	e98080e7          	jalr	-360(ra) # 8000383c <brelse>
}
    800039ac:	60e2                	ld	ra,24(sp)
    800039ae:	6442                	ld	s0,16(sp)
    800039b0:	64a2                	ld	s1,8(sp)
    800039b2:	6902                	ld	s2,0(sp)
    800039b4:	6105                	addi	sp,sp,32
    800039b6:	8082                	ret
    panic("freeing free block");
    800039b8:	00005517          	auipc	a0,0x5
    800039bc:	a7050513          	addi	a0,a0,-1424 # 80008428 <etext+0x428>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	ba0080e7          	jalr	-1120(ra) # 80000560 <panic>

00000000800039c8 <balloc>:
{
    800039c8:	715d                	addi	sp,sp,-80
    800039ca:	e486                	sd	ra,72(sp)
    800039cc:	e0a2                	sd	s0,64(sp)
    800039ce:	fc26                	sd	s1,56(sp)
    800039d0:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800039d2:	00024797          	auipc	a5,0x24
    800039d6:	8ba7a783          	lw	a5,-1862(a5) # 8002728c <sb+0x4>
    800039da:	10078863          	beqz	a5,80003aea <balloc+0x122>
    800039de:	f84a                	sd	s2,48(sp)
    800039e0:	f44e                	sd	s3,40(sp)
    800039e2:	f052                	sd	s4,32(sp)
    800039e4:	ec56                	sd	s5,24(sp)
    800039e6:	e85a                	sd	s6,16(sp)
    800039e8:	e45e                	sd	s7,8(sp)
    800039ea:	e062                	sd	s8,0(sp)
    800039ec:	8baa                	mv	s7,a0
    800039ee:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800039f0:	00024b17          	auipc	s6,0x24
    800039f4:	898b0b13          	addi	s6,s6,-1896 # 80027288 <sb>
      m = 1 << (bi % 8);
    800039f8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039fa:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800039fc:	6c09                	lui	s8,0x2
    800039fe:	a049                	j	80003a80 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a00:	97ca                	add	a5,a5,s2
    80003a02:	8e55                	or	a2,a2,a3
    80003a04:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	0d8080e7          	jalr	216(ra) # 80004ae2 <log_write>
        brelse(bp);
    80003a12:	854a                	mv	a0,s2
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	e28080e7          	jalr	-472(ra) # 8000383c <brelse>
  bp = bread(dev, bno);
    80003a1c:	85a6                	mv	a1,s1
    80003a1e:	855e                	mv	a0,s7
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	cec080e7          	jalr	-788(ra) # 8000370c <bread>
    80003a28:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a2a:	40000613          	li	a2,1024
    80003a2e:	4581                	li	a1,0
    80003a30:	05850513          	addi	a0,a0,88
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	302080e7          	jalr	770(ra) # 80000d36 <memset>
  log_write(bp);
    80003a3c:	854a                	mv	a0,s2
    80003a3e:	00001097          	auipc	ra,0x1
    80003a42:	0a4080e7          	jalr	164(ra) # 80004ae2 <log_write>
  brelse(bp);
    80003a46:	854a                	mv	a0,s2
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	df4080e7          	jalr	-524(ra) # 8000383c <brelse>
}
    80003a50:	7942                	ld	s2,48(sp)
    80003a52:	79a2                	ld	s3,40(sp)
    80003a54:	7a02                	ld	s4,32(sp)
    80003a56:	6ae2                	ld	s5,24(sp)
    80003a58:	6b42                	ld	s6,16(sp)
    80003a5a:	6ba2                	ld	s7,8(sp)
    80003a5c:	6c02                	ld	s8,0(sp)
}
    80003a5e:	8526                	mv	a0,s1
    80003a60:	60a6                	ld	ra,72(sp)
    80003a62:	6406                	ld	s0,64(sp)
    80003a64:	74e2                	ld	s1,56(sp)
    80003a66:	6161                	addi	sp,sp,80
    80003a68:	8082                	ret
    brelse(bp);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	dd0080e7          	jalr	-560(ra) # 8000383c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a74:	015c0abb          	addw	s5,s8,s5
    80003a78:	004b2783          	lw	a5,4(s6)
    80003a7c:	06faf063          	bgeu	s5,a5,80003adc <balloc+0x114>
    bp = bread(dev, BBLOCK(b, sb));
    80003a80:	41fad79b          	sraiw	a5,s5,0x1f
    80003a84:	0137d79b          	srliw	a5,a5,0x13
    80003a88:	015787bb          	addw	a5,a5,s5
    80003a8c:	40d7d79b          	sraiw	a5,a5,0xd
    80003a90:	01cb2583          	lw	a1,28(s6)
    80003a94:	9dbd                	addw	a1,a1,a5
    80003a96:	855e                	mv	a0,s7
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	c74080e7          	jalr	-908(ra) # 8000370c <bread>
    80003aa0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aa2:	004b2503          	lw	a0,4(s6)
    80003aa6:	84d6                	mv	s1,s5
    80003aa8:	4701                	li	a4,0
    80003aaa:	fca4f0e3          	bgeu	s1,a0,80003a6a <balloc+0xa2>
      m = 1 << (bi % 8);
    80003aae:	00777693          	andi	a3,a4,7
    80003ab2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003ab6:	41f7579b          	sraiw	a5,a4,0x1f
    80003aba:	01d7d79b          	srliw	a5,a5,0x1d
    80003abe:	9fb9                	addw	a5,a5,a4
    80003ac0:	4037d79b          	sraiw	a5,a5,0x3
    80003ac4:	00f90633          	add	a2,s2,a5
    80003ac8:	05864603          	lbu	a2,88(a2)
    80003acc:	00c6f5b3          	and	a1,a3,a2
    80003ad0:	d985                	beqz	a1,80003a00 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ad2:	2705                	addiw	a4,a4,1
    80003ad4:	2485                	addiw	s1,s1,1
    80003ad6:	fd471ae3          	bne	a4,s4,80003aaa <balloc+0xe2>
    80003ada:	bf41                	j	80003a6a <balloc+0xa2>
    80003adc:	7942                	ld	s2,48(sp)
    80003ade:	79a2                	ld	s3,40(sp)
    80003ae0:	7a02                	ld	s4,32(sp)
    80003ae2:	6ae2                	ld	s5,24(sp)
    80003ae4:	6b42                	ld	s6,16(sp)
    80003ae6:	6ba2                	ld	s7,8(sp)
    80003ae8:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003aea:	00005517          	auipc	a0,0x5
    80003aee:	95650513          	addi	a0,a0,-1706 # 80008440 <etext+0x440>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	ab8080e7          	jalr	-1352(ra) # 800005aa <printf>
  return 0;
    80003afa:	4481                	li	s1,0
    80003afc:	b78d                	j	80003a5e <balloc+0x96>

0000000080003afe <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003afe:	7179                	addi	sp,sp,-48
    80003b00:	f406                	sd	ra,40(sp)
    80003b02:	f022                	sd	s0,32(sp)
    80003b04:	ec26                	sd	s1,24(sp)
    80003b06:	e84a                	sd	s2,16(sp)
    80003b08:	e44e                	sd	s3,8(sp)
    80003b0a:	1800                	addi	s0,sp,48
    80003b0c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b0e:	47ad                	li	a5,11
    80003b10:	02b7e563          	bltu	a5,a1,80003b3a <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003b14:	02059793          	slli	a5,a1,0x20
    80003b18:	01e7d593          	srli	a1,a5,0x1e
    80003b1c:	00b504b3          	add	s1,a0,a1
    80003b20:	0504a903          	lw	s2,80(s1)
    80003b24:	06091b63          	bnez	s2,80003b9a <bmap+0x9c>
      addr = balloc(ip->dev);
    80003b28:	4108                	lw	a0,0(a0)
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	e9e080e7          	jalr	-354(ra) # 800039c8 <balloc>
    80003b32:	892a                	mv	s2,a0
      if(addr == 0)
    80003b34:	c13d                	beqz	a0,80003b9a <bmap+0x9c>
        return 0;
      ip->addrs[bn] = addr;
    80003b36:	c8a8                	sw	a0,80(s1)
    80003b38:	a08d                	j	80003b9a <bmap+0x9c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b3a:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003b3e:	0ff00793          	li	a5,255
    80003b42:	0897e363          	bltu	a5,s1,80003bc8 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b46:	08052903          	lw	s2,128(a0)
    80003b4a:	00091d63          	bnez	s2,80003b64 <bmap+0x66>
      addr = balloc(ip->dev);
    80003b4e:	4108                	lw	a0,0(a0)
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	e78080e7          	jalr	-392(ra) # 800039c8 <balloc>
    80003b58:	892a                	mv	s2,a0
      if(addr == 0)
    80003b5a:	c121                	beqz	a0,80003b9a <bmap+0x9c>
    80003b5c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b5e:	08a9a023          	sw	a0,128(s3)
    80003b62:	a011                	j	80003b66 <bmap+0x68>
    80003b64:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003b66:	85ca                	mv	a1,s2
    80003b68:	0009a503          	lw	a0,0(s3)
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	ba0080e7          	jalr	-1120(ra) # 8000370c <bread>
    80003b74:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b76:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b7a:	02049713          	slli	a4,s1,0x20
    80003b7e:	01e75593          	srli	a1,a4,0x1e
    80003b82:	00b784b3          	add	s1,a5,a1
    80003b86:	0004a903          	lw	s2,0(s1)
    80003b8a:	02090063          	beqz	s2,80003baa <bmap+0xac>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b8e:	8552                	mv	a0,s4
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	cac080e7          	jalr	-852(ra) # 8000383c <brelse>
    return addr;
    80003b98:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	70a2                	ld	ra,40(sp)
    80003b9e:	7402                	ld	s0,32(sp)
    80003ba0:	64e2                	ld	s1,24(sp)
    80003ba2:	6942                	ld	s2,16(sp)
    80003ba4:	69a2                	ld	s3,8(sp)
    80003ba6:	6145                	addi	sp,sp,48
    80003ba8:	8082                	ret
      addr = balloc(ip->dev);
    80003baa:	0009a503          	lw	a0,0(s3)
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	e1a080e7          	jalr	-486(ra) # 800039c8 <balloc>
    80003bb6:	892a                	mv	s2,a0
      if(addr){
    80003bb8:	d979                	beqz	a0,80003b8e <bmap+0x90>
        a[bn] = addr;
    80003bba:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003bbc:	8552                	mv	a0,s4
    80003bbe:	00001097          	auipc	ra,0x1
    80003bc2:	f24080e7          	jalr	-220(ra) # 80004ae2 <log_write>
    80003bc6:	b7e1                	j	80003b8e <bmap+0x90>
    80003bc8:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003bca:	00005517          	auipc	a0,0x5
    80003bce:	88e50513          	addi	a0,a0,-1906 # 80008458 <etext+0x458>
    80003bd2:	ffffd097          	auipc	ra,0xffffd
    80003bd6:	98e080e7          	jalr	-1650(ra) # 80000560 <panic>

0000000080003bda <iget>:
{
    80003bda:	7179                	addi	sp,sp,-48
    80003bdc:	f406                	sd	ra,40(sp)
    80003bde:	f022                	sd	s0,32(sp)
    80003be0:	ec26                	sd	s1,24(sp)
    80003be2:	e84a                	sd	s2,16(sp)
    80003be4:	e44e                	sd	s3,8(sp)
    80003be6:	e052                	sd	s4,0(sp)
    80003be8:	1800                	addi	s0,sp,48
    80003bea:	89aa                	mv	s3,a0
    80003bec:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003bee:	00023517          	auipc	a0,0x23
    80003bf2:	6ba50513          	addi	a0,a0,1722 # 800272a8 <itable>
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	048080e7          	jalr	72(ra) # 80000c3e <acquire>
  empty = 0;
    80003bfe:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c00:	00023497          	auipc	s1,0x23
    80003c04:	6c048493          	addi	s1,s1,1728 # 800272c0 <itable+0x18>
    80003c08:	00025697          	auipc	a3,0x25
    80003c0c:	14868693          	addi	a3,a3,328 # 80028d50 <log>
    80003c10:	a039                	j	80003c1e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c12:	02090b63          	beqz	s2,80003c48 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c16:	08848493          	addi	s1,s1,136
    80003c1a:	02d48a63          	beq	s1,a3,80003c4e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c1e:	449c                	lw	a5,8(s1)
    80003c20:	fef059e3          	blez	a5,80003c12 <iget+0x38>
    80003c24:	4098                	lw	a4,0(s1)
    80003c26:	ff3716e3          	bne	a4,s3,80003c12 <iget+0x38>
    80003c2a:	40d8                	lw	a4,4(s1)
    80003c2c:	ff4713e3          	bne	a4,s4,80003c12 <iget+0x38>
      ip->ref++;
    80003c30:	2785                	addiw	a5,a5,1
    80003c32:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c34:	00023517          	auipc	a0,0x23
    80003c38:	67450513          	addi	a0,a0,1652 # 800272a8 <itable>
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	0b2080e7          	jalr	178(ra) # 80000cee <release>
      return ip;
    80003c44:	8926                	mv	s2,s1
    80003c46:	a03d                	j	80003c74 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c48:	f7f9                	bnez	a5,80003c16 <iget+0x3c>
      empty = ip;
    80003c4a:	8926                	mv	s2,s1
    80003c4c:	b7e9                	j	80003c16 <iget+0x3c>
  if(empty == 0)
    80003c4e:	02090c63          	beqz	s2,80003c86 <iget+0xac>
  ip->dev = dev;
    80003c52:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c56:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c5a:	4785                	li	a5,1
    80003c5c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c60:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c64:	00023517          	auipc	a0,0x23
    80003c68:	64450513          	addi	a0,a0,1604 # 800272a8 <itable>
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	082080e7          	jalr	130(ra) # 80000cee <release>
}
    80003c74:	854a                	mv	a0,s2
    80003c76:	70a2                	ld	ra,40(sp)
    80003c78:	7402                	ld	s0,32(sp)
    80003c7a:	64e2                	ld	s1,24(sp)
    80003c7c:	6942                	ld	s2,16(sp)
    80003c7e:	69a2                	ld	s3,8(sp)
    80003c80:	6a02                	ld	s4,0(sp)
    80003c82:	6145                	addi	sp,sp,48
    80003c84:	8082                	ret
    panic("iget: no inodes");
    80003c86:	00004517          	auipc	a0,0x4
    80003c8a:	7ea50513          	addi	a0,a0,2026 # 80008470 <etext+0x470>
    80003c8e:	ffffd097          	auipc	ra,0xffffd
    80003c92:	8d2080e7          	jalr	-1838(ra) # 80000560 <panic>

0000000080003c96 <fsinit>:
fsinit(int dev) {
    80003c96:	7179                	addi	sp,sp,-48
    80003c98:	f406                	sd	ra,40(sp)
    80003c9a:	f022                	sd	s0,32(sp)
    80003c9c:	ec26                	sd	s1,24(sp)
    80003c9e:	e84a                	sd	s2,16(sp)
    80003ca0:	e44e                	sd	s3,8(sp)
    80003ca2:	1800                	addi	s0,sp,48
    80003ca4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ca6:	4585                	li	a1,1
    80003ca8:	00000097          	auipc	ra,0x0
    80003cac:	a64080e7          	jalr	-1436(ra) # 8000370c <bread>
    80003cb0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cb2:	00023997          	auipc	s3,0x23
    80003cb6:	5d698993          	addi	s3,s3,1494 # 80027288 <sb>
    80003cba:	02000613          	li	a2,32
    80003cbe:	05850593          	addi	a1,a0,88
    80003cc2:	854e                	mv	a0,s3
    80003cc4:	ffffd097          	auipc	ra,0xffffd
    80003cc8:	0d6080e7          	jalr	214(ra) # 80000d9a <memmove>
  brelse(bp);
    80003ccc:	8526                	mv	a0,s1
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	b6e080e7          	jalr	-1170(ra) # 8000383c <brelse>
  if(sb.magic != FSMAGIC)
    80003cd6:	0009a703          	lw	a4,0(s3)
    80003cda:	102037b7          	lui	a5,0x10203
    80003cde:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ce2:	02f71263          	bne	a4,a5,80003d06 <fsinit+0x70>
  initlog(dev, &sb);
    80003ce6:	00023597          	auipc	a1,0x23
    80003cea:	5a258593          	addi	a1,a1,1442 # 80027288 <sb>
    80003cee:	854a                	mv	a0,s2
    80003cf0:	00001097          	auipc	ra,0x1
    80003cf4:	b7c080e7          	jalr	-1156(ra) # 8000486c <initlog>
}
    80003cf8:	70a2                	ld	ra,40(sp)
    80003cfa:	7402                	ld	s0,32(sp)
    80003cfc:	64e2                	ld	s1,24(sp)
    80003cfe:	6942                	ld	s2,16(sp)
    80003d00:	69a2                	ld	s3,8(sp)
    80003d02:	6145                	addi	sp,sp,48
    80003d04:	8082                	ret
    panic("invalid file system");
    80003d06:	00004517          	auipc	a0,0x4
    80003d0a:	77a50513          	addi	a0,a0,1914 # 80008480 <etext+0x480>
    80003d0e:	ffffd097          	auipc	ra,0xffffd
    80003d12:	852080e7          	jalr	-1966(ra) # 80000560 <panic>

0000000080003d16 <iinit>:
{
    80003d16:	7179                	addi	sp,sp,-48
    80003d18:	f406                	sd	ra,40(sp)
    80003d1a:	f022                	sd	s0,32(sp)
    80003d1c:	ec26                	sd	s1,24(sp)
    80003d1e:	e84a                	sd	s2,16(sp)
    80003d20:	e44e                	sd	s3,8(sp)
    80003d22:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d24:	00004597          	auipc	a1,0x4
    80003d28:	77458593          	addi	a1,a1,1908 # 80008498 <etext+0x498>
    80003d2c:	00023517          	auipc	a0,0x23
    80003d30:	57c50513          	addi	a0,a0,1404 # 800272a8 <itable>
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	e76080e7          	jalr	-394(ra) # 80000baa <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d3c:	00023497          	auipc	s1,0x23
    80003d40:	59448493          	addi	s1,s1,1428 # 800272d0 <itable+0x28>
    80003d44:	00025997          	auipc	s3,0x25
    80003d48:	01c98993          	addi	s3,s3,28 # 80028d60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d4c:	00004917          	auipc	s2,0x4
    80003d50:	75490913          	addi	s2,s2,1876 # 800084a0 <etext+0x4a0>
    80003d54:	85ca                	mv	a1,s2
    80003d56:	8526                	mv	a0,s1
    80003d58:	00001097          	auipc	ra,0x1
    80003d5c:	e6e080e7          	jalr	-402(ra) # 80004bc6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d60:	08848493          	addi	s1,s1,136
    80003d64:	ff3498e3          	bne	s1,s3,80003d54 <iinit+0x3e>
}
    80003d68:	70a2                	ld	ra,40(sp)
    80003d6a:	7402                	ld	s0,32(sp)
    80003d6c:	64e2                	ld	s1,24(sp)
    80003d6e:	6942                	ld	s2,16(sp)
    80003d70:	69a2                	ld	s3,8(sp)
    80003d72:	6145                	addi	sp,sp,48
    80003d74:	8082                	ret

0000000080003d76 <ialloc>:
{
    80003d76:	7139                	addi	sp,sp,-64
    80003d78:	fc06                	sd	ra,56(sp)
    80003d7a:	f822                	sd	s0,48(sp)
    80003d7c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d7e:	00023717          	auipc	a4,0x23
    80003d82:	51672703          	lw	a4,1302(a4) # 80027294 <sb+0xc>
    80003d86:	4785                	li	a5,1
    80003d88:	06e7f463          	bgeu	a5,a4,80003df0 <ialloc+0x7a>
    80003d8c:	f426                	sd	s1,40(sp)
    80003d8e:	f04a                	sd	s2,32(sp)
    80003d90:	ec4e                	sd	s3,24(sp)
    80003d92:	e852                	sd	s4,16(sp)
    80003d94:	e456                	sd	s5,8(sp)
    80003d96:	e05a                	sd	s6,0(sp)
    80003d98:	8aaa                	mv	s5,a0
    80003d9a:	8b2e                	mv	s6,a1
    80003d9c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003d9e:	00023a17          	auipc	s4,0x23
    80003da2:	4eaa0a13          	addi	s4,s4,1258 # 80027288 <sb>
    80003da6:	00495593          	srli	a1,s2,0x4
    80003daa:	018a2783          	lw	a5,24(s4)
    80003dae:	9dbd                	addw	a1,a1,a5
    80003db0:	8556                	mv	a0,s5
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	95a080e7          	jalr	-1702(ra) # 8000370c <bread>
    80003dba:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003dbc:	05850993          	addi	s3,a0,88
    80003dc0:	00f97793          	andi	a5,s2,15
    80003dc4:	079a                	slli	a5,a5,0x6
    80003dc6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003dc8:	00099783          	lh	a5,0(s3)
    80003dcc:	cf9d                	beqz	a5,80003e0a <ialloc+0x94>
    brelse(bp);
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	a6e080e7          	jalr	-1426(ra) # 8000383c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dd6:	0905                	addi	s2,s2,1
    80003dd8:	00ca2703          	lw	a4,12(s4)
    80003ddc:	0009079b          	sext.w	a5,s2
    80003de0:	fce7e3e3          	bltu	a5,a4,80003da6 <ialloc+0x30>
    80003de4:	74a2                	ld	s1,40(sp)
    80003de6:	7902                	ld	s2,32(sp)
    80003de8:	69e2                	ld	s3,24(sp)
    80003dea:	6a42                	ld	s4,16(sp)
    80003dec:	6aa2                	ld	s5,8(sp)
    80003dee:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003df0:	00004517          	auipc	a0,0x4
    80003df4:	6b850513          	addi	a0,a0,1720 # 800084a8 <etext+0x4a8>
    80003df8:	ffffc097          	auipc	ra,0xffffc
    80003dfc:	7b2080e7          	jalr	1970(ra) # 800005aa <printf>
  return 0;
    80003e00:	4501                	li	a0,0
}
    80003e02:	70e2                	ld	ra,56(sp)
    80003e04:	7442                	ld	s0,48(sp)
    80003e06:	6121                	addi	sp,sp,64
    80003e08:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e0a:	04000613          	li	a2,64
    80003e0e:	4581                	li	a1,0
    80003e10:	854e                	mv	a0,s3
    80003e12:	ffffd097          	auipc	ra,0xffffd
    80003e16:	f24080e7          	jalr	-220(ra) # 80000d36 <memset>
      dip->type = type;
    80003e1a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e1e:	8526                	mv	a0,s1
    80003e20:	00001097          	auipc	ra,0x1
    80003e24:	cc2080e7          	jalr	-830(ra) # 80004ae2 <log_write>
      brelse(bp);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	a12080e7          	jalr	-1518(ra) # 8000383c <brelse>
      return iget(dev, inum);
    80003e32:	0009059b          	sext.w	a1,s2
    80003e36:	8556                	mv	a0,s5
    80003e38:	00000097          	auipc	ra,0x0
    80003e3c:	da2080e7          	jalr	-606(ra) # 80003bda <iget>
    80003e40:	74a2                	ld	s1,40(sp)
    80003e42:	7902                	ld	s2,32(sp)
    80003e44:	69e2                	ld	s3,24(sp)
    80003e46:	6a42                	ld	s4,16(sp)
    80003e48:	6aa2                	ld	s5,8(sp)
    80003e4a:	6b02                	ld	s6,0(sp)
    80003e4c:	bf5d                	j	80003e02 <ialloc+0x8c>

0000000080003e4e <iupdate>:
{
    80003e4e:	1101                	addi	sp,sp,-32
    80003e50:	ec06                	sd	ra,24(sp)
    80003e52:	e822                	sd	s0,16(sp)
    80003e54:	e426                	sd	s1,8(sp)
    80003e56:	e04a                	sd	s2,0(sp)
    80003e58:	1000                	addi	s0,sp,32
    80003e5a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e5c:	415c                	lw	a5,4(a0)
    80003e5e:	0047d79b          	srliw	a5,a5,0x4
    80003e62:	00023597          	auipc	a1,0x23
    80003e66:	43e5a583          	lw	a1,1086(a1) # 800272a0 <sb+0x18>
    80003e6a:	9dbd                	addw	a1,a1,a5
    80003e6c:	4108                	lw	a0,0(a0)
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	89e080e7          	jalr	-1890(ra) # 8000370c <bread>
    80003e76:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e78:	05850793          	addi	a5,a0,88
    80003e7c:	40d8                	lw	a4,4(s1)
    80003e7e:	8b3d                	andi	a4,a4,15
    80003e80:	071a                	slli	a4,a4,0x6
    80003e82:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003e84:	04449703          	lh	a4,68(s1)
    80003e88:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003e8c:	04649703          	lh	a4,70(s1)
    80003e90:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003e94:	04849703          	lh	a4,72(s1)
    80003e98:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003e9c:	04a49703          	lh	a4,74(s1)
    80003ea0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003ea4:	44f8                	lw	a4,76(s1)
    80003ea6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ea8:	03400613          	li	a2,52
    80003eac:	05048593          	addi	a1,s1,80
    80003eb0:	00c78513          	addi	a0,a5,12
    80003eb4:	ffffd097          	auipc	ra,0xffffd
    80003eb8:	ee6080e7          	jalr	-282(ra) # 80000d9a <memmove>
  log_write(bp);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	00001097          	auipc	ra,0x1
    80003ec2:	c24080e7          	jalr	-988(ra) # 80004ae2 <log_write>
  brelse(bp);
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	974080e7          	jalr	-1676(ra) # 8000383c <brelse>
}
    80003ed0:	60e2                	ld	ra,24(sp)
    80003ed2:	6442                	ld	s0,16(sp)
    80003ed4:	64a2                	ld	s1,8(sp)
    80003ed6:	6902                	ld	s2,0(sp)
    80003ed8:	6105                	addi	sp,sp,32
    80003eda:	8082                	ret

0000000080003edc <idup>:
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	1000                	addi	s0,sp,32
    80003ee6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ee8:	00023517          	auipc	a0,0x23
    80003eec:	3c050513          	addi	a0,a0,960 # 800272a8 <itable>
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	d4e080e7          	jalr	-690(ra) # 80000c3e <acquire>
  ip->ref++;
    80003ef8:	449c                	lw	a5,8(s1)
    80003efa:	2785                	addiw	a5,a5,1
    80003efc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003efe:	00023517          	auipc	a0,0x23
    80003f02:	3aa50513          	addi	a0,a0,938 # 800272a8 <itable>
    80003f06:	ffffd097          	auipc	ra,0xffffd
    80003f0a:	de8080e7          	jalr	-536(ra) # 80000cee <release>
}
    80003f0e:	8526                	mv	a0,s1
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6105                	addi	sp,sp,32
    80003f18:	8082                	ret

0000000080003f1a <ilock>:
{
    80003f1a:	1101                	addi	sp,sp,-32
    80003f1c:	ec06                	sd	ra,24(sp)
    80003f1e:	e822                	sd	s0,16(sp)
    80003f20:	e426                	sd	s1,8(sp)
    80003f22:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f24:	c10d                	beqz	a0,80003f46 <ilock+0x2c>
    80003f26:	84aa                	mv	s1,a0
    80003f28:	451c                	lw	a5,8(a0)
    80003f2a:	00f05e63          	blez	a5,80003f46 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003f2e:	0541                	addi	a0,a0,16
    80003f30:	00001097          	auipc	ra,0x1
    80003f34:	cd0080e7          	jalr	-816(ra) # 80004c00 <acquiresleep>
  if(ip->valid == 0){
    80003f38:	40bc                	lw	a5,64(s1)
    80003f3a:	cf99                	beqz	a5,80003f58 <ilock+0x3e>
}
    80003f3c:	60e2                	ld	ra,24(sp)
    80003f3e:	6442                	ld	s0,16(sp)
    80003f40:	64a2                	ld	s1,8(sp)
    80003f42:	6105                	addi	sp,sp,32
    80003f44:	8082                	ret
    80003f46:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003f48:	00004517          	auipc	a0,0x4
    80003f4c:	57850513          	addi	a0,a0,1400 # 800084c0 <etext+0x4c0>
    80003f50:	ffffc097          	auipc	ra,0xffffc
    80003f54:	610080e7          	jalr	1552(ra) # 80000560 <panic>
    80003f58:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f5a:	40dc                	lw	a5,4(s1)
    80003f5c:	0047d79b          	srliw	a5,a5,0x4
    80003f60:	00023597          	auipc	a1,0x23
    80003f64:	3405a583          	lw	a1,832(a1) # 800272a0 <sb+0x18>
    80003f68:	9dbd                	addw	a1,a1,a5
    80003f6a:	4088                	lw	a0,0(s1)
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	7a0080e7          	jalr	1952(ra) # 8000370c <bread>
    80003f74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f76:	05850593          	addi	a1,a0,88
    80003f7a:	40dc                	lw	a5,4(s1)
    80003f7c:	8bbd                	andi	a5,a5,15
    80003f7e:	079a                	slli	a5,a5,0x6
    80003f80:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f82:	00059783          	lh	a5,0(a1)
    80003f86:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f8a:	00259783          	lh	a5,2(a1)
    80003f8e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f92:	00459783          	lh	a5,4(a1)
    80003f96:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f9a:	00659783          	lh	a5,6(a1)
    80003f9e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fa2:	459c                	lw	a5,8(a1)
    80003fa4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fa6:	03400613          	li	a2,52
    80003faa:	05b1                	addi	a1,a1,12
    80003fac:	05048513          	addi	a0,s1,80
    80003fb0:	ffffd097          	auipc	ra,0xffffd
    80003fb4:	dea080e7          	jalr	-534(ra) # 80000d9a <memmove>
    brelse(bp);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	882080e7          	jalr	-1918(ra) # 8000383c <brelse>
    ip->valid = 1;
    80003fc2:	4785                	li	a5,1
    80003fc4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003fc6:	04449783          	lh	a5,68(s1)
    80003fca:	c399                	beqz	a5,80003fd0 <ilock+0xb6>
    80003fcc:	6902                	ld	s2,0(sp)
    80003fce:	b7bd                	j	80003f3c <ilock+0x22>
      panic("ilock: no type");
    80003fd0:	00004517          	auipc	a0,0x4
    80003fd4:	4f850513          	addi	a0,a0,1272 # 800084c8 <etext+0x4c8>
    80003fd8:	ffffc097          	auipc	ra,0xffffc
    80003fdc:	588080e7          	jalr	1416(ra) # 80000560 <panic>

0000000080003fe0 <iunlock>:
{
    80003fe0:	1101                	addi	sp,sp,-32
    80003fe2:	ec06                	sd	ra,24(sp)
    80003fe4:	e822                	sd	s0,16(sp)
    80003fe6:	e426                	sd	s1,8(sp)
    80003fe8:	e04a                	sd	s2,0(sp)
    80003fea:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003fec:	c905                	beqz	a0,8000401c <iunlock+0x3c>
    80003fee:	84aa                	mv	s1,a0
    80003ff0:	01050913          	addi	s2,a0,16
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	00001097          	auipc	ra,0x1
    80003ffa:	ca4080e7          	jalr	-860(ra) # 80004c9a <holdingsleep>
    80003ffe:	cd19                	beqz	a0,8000401c <iunlock+0x3c>
    80004000:	449c                	lw	a5,8(s1)
    80004002:	00f05d63          	blez	a5,8000401c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004006:	854a                	mv	a0,s2
    80004008:	00001097          	auipc	ra,0x1
    8000400c:	c4e080e7          	jalr	-946(ra) # 80004c56 <releasesleep>
}
    80004010:	60e2                	ld	ra,24(sp)
    80004012:	6442                	ld	s0,16(sp)
    80004014:	64a2                	ld	s1,8(sp)
    80004016:	6902                	ld	s2,0(sp)
    80004018:	6105                	addi	sp,sp,32
    8000401a:	8082                	ret
    panic("iunlock");
    8000401c:	00004517          	auipc	a0,0x4
    80004020:	4bc50513          	addi	a0,a0,1212 # 800084d8 <etext+0x4d8>
    80004024:	ffffc097          	auipc	ra,0xffffc
    80004028:	53c080e7          	jalr	1340(ra) # 80000560 <panic>

000000008000402c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000402c:	7179                	addi	sp,sp,-48
    8000402e:	f406                	sd	ra,40(sp)
    80004030:	f022                	sd	s0,32(sp)
    80004032:	ec26                	sd	s1,24(sp)
    80004034:	e84a                	sd	s2,16(sp)
    80004036:	e44e                	sd	s3,8(sp)
    80004038:	1800                	addi	s0,sp,48
    8000403a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000403c:	05050493          	addi	s1,a0,80
    80004040:	08050913          	addi	s2,a0,128
    80004044:	a021                	j	8000404c <itrunc+0x20>
    80004046:	0491                	addi	s1,s1,4
    80004048:	01248d63          	beq	s1,s2,80004062 <itrunc+0x36>
    if(ip->addrs[i]){
    8000404c:	408c                	lw	a1,0(s1)
    8000404e:	dde5                	beqz	a1,80004046 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004050:	0009a503          	lw	a0,0(s3)
    80004054:	00000097          	auipc	ra,0x0
    80004058:	8f8080e7          	jalr	-1800(ra) # 8000394c <bfree>
      ip->addrs[i] = 0;
    8000405c:	0004a023          	sw	zero,0(s1)
    80004060:	b7dd                	j	80004046 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004062:	0809a583          	lw	a1,128(s3)
    80004066:	ed99                	bnez	a1,80004084 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004068:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000406c:	854e                	mv	a0,s3
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	de0080e7          	jalr	-544(ra) # 80003e4e <iupdate>
}
    80004076:	70a2                	ld	ra,40(sp)
    80004078:	7402                	ld	s0,32(sp)
    8000407a:	64e2                	ld	s1,24(sp)
    8000407c:	6942                	ld	s2,16(sp)
    8000407e:	69a2                	ld	s3,8(sp)
    80004080:	6145                	addi	sp,sp,48
    80004082:	8082                	ret
    80004084:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004086:	0009a503          	lw	a0,0(s3)
    8000408a:	fffff097          	auipc	ra,0xfffff
    8000408e:	682080e7          	jalr	1666(ra) # 8000370c <bread>
    80004092:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004094:	05850493          	addi	s1,a0,88
    80004098:	45850913          	addi	s2,a0,1112
    8000409c:	a021                	j	800040a4 <itrunc+0x78>
    8000409e:	0491                	addi	s1,s1,4
    800040a0:	01248b63          	beq	s1,s2,800040b6 <itrunc+0x8a>
      if(a[j])
    800040a4:	408c                	lw	a1,0(s1)
    800040a6:	dde5                	beqz	a1,8000409e <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800040a8:	0009a503          	lw	a0,0(s3)
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	8a0080e7          	jalr	-1888(ra) # 8000394c <bfree>
    800040b4:	b7ed                	j	8000409e <itrunc+0x72>
    brelse(bp);
    800040b6:	8552                	mv	a0,s4
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	784080e7          	jalr	1924(ra) # 8000383c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040c0:	0809a583          	lw	a1,128(s3)
    800040c4:	0009a503          	lw	a0,0(s3)
    800040c8:	00000097          	auipc	ra,0x0
    800040cc:	884080e7          	jalr	-1916(ra) # 8000394c <bfree>
    ip->addrs[NDIRECT] = 0;
    800040d0:	0809a023          	sw	zero,128(s3)
    800040d4:	6a02                	ld	s4,0(sp)
    800040d6:	bf49                	j	80004068 <itrunc+0x3c>

00000000800040d8 <iput>:
{
    800040d8:	1101                	addi	sp,sp,-32
    800040da:	ec06                	sd	ra,24(sp)
    800040dc:	e822                	sd	s0,16(sp)
    800040de:	e426                	sd	s1,8(sp)
    800040e0:	1000                	addi	s0,sp,32
    800040e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040e4:	00023517          	auipc	a0,0x23
    800040e8:	1c450513          	addi	a0,a0,452 # 800272a8 <itable>
    800040ec:	ffffd097          	auipc	ra,0xffffd
    800040f0:	b52080e7          	jalr	-1198(ra) # 80000c3e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040f4:	4498                	lw	a4,8(s1)
    800040f6:	4785                	li	a5,1
    800040f8:	02f70263          	beq	a4,a5,8000411c <iput+0x44>
  ip->ref--;
    800040fc:	449c                	lw	a5,8(s1)
    800040fe:	37fd                	addiw	a5,a5,-1
    80004100:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004102:	00023517          	auipc	a0,0x23
    80004106:	1a650513          	addi	a0,a0,422 # 800272a8 <itable>
    8000410a:	ffffd097          	auipc	ra,0xffffd
    8000410e:	be4080e7          	jalr	-1052(ra) # 80000cee <release>
}
    80004112:	60e2                	ld	ra,24(sp)
    80004114:	6442                	ld	s0,16(sp)
    80004116:	64a2                	ld	s1,8(sp)
    80004118:	6105                	addi	sp,sp,32
    8000411a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000411c:	40bc                	lw	a5,64(s1)
    8000411e:	dff9                	beqz	a5,800040fc <iput+0x24>
    80004120:	04a49783          	lh	a5,74(s1)
    80004124:	ffe1                	bnez	a5,800040fc <iput+0x24>
    80004126:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80004128:	01048913          	addi	s2,s1,16
    8000412c:	854a                	mv	a0,s2
    8000412e:	00001097          	auipc	ra,0x1
    80004132:	ad2080e7          	jalr	-1326(ra) # 80004c00 <acquiresleep>
    release(&itable.lock);
    80004136:	00023517          	auipc	a0,0x23
    8000413a:	17250513          	addi	a0,a0,370 # 800272a8 <itable>
    8000413e:	ffffd097          	auipc	ra,0xffffd
    80004142:	bb0080e7          	jalr	-1104(ra) # 80000cee <release>
    itrunc(ip);
    80004146:	8526                	mv	a0,s1
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	ee4080e7          	jalr	-284(ra) # 8000402c <itrunc>
    ip->type = 0;
    80004150:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004154:	8526                	mv	a0,s1
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	cf8080e7          	jalr	-776(ra) # 80003e4e <iupdate>
    ip->valid = 0;
    8000415e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004162:	854a                	mv	a0,s2
    80004164:	00001097          	auipc	ra,0x1
    80004168:	af2080e7          	jalr	-1294(ra) # 80004c56 <releasesleep>
    acquire(&itable.lock);
    8000416c:	00023517          	auipc	a0,0x23
    80004170:	13c50513          	addi	a0,a0,316 # 800272a8 <itable>
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	aca080e7          	jalr	-1334(ra) # 80000c3e <acquire>
    8000417c:	6902                	ld	s2,0(sp)
    8000417e:	bfbd                	j	800040fc <iput+0x24>

0000000080004180 <iunlockput>:
{
    80004180:	1101                	addi	sp,sp,-32
    80004182:	ec06                	sd	ra,24(sp)
    80004184:	e822                	sd	s0,16(sp)
    80004186:	e426                	sd	s1,8(sp)
    80004188:	1000                	addi	s0,sp,32
    8000418a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	e54080e7          	jalr	-428(ra) # 80003fe0 <iunlock>
  iput(ip);
    80004194:	8526                	mv	a0,s1
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	f42080e7          	jalr	-190(ra) # 800040d8 <iput>
}
    8000419e:	60e2                	ld	ra,24(sp)
    800041a0:	6442                	ld	s0,16(sp)
    800041a2:	64a2                	ld	s1,8(sp)
    800041a4:	6105                	addi	sp,sp,32
    800041a6:	8082                	ret

00000000800041a8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041a8:	1141                	addi	sp,sp,-16
    800041aa:	e406                	sd	ra,8(sp)
    800041ac:	e022                	sd	s0,0(sp)
    800041ae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041b0:	411c                	lw	a5,0(a0)
    800041b2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041b4:	415c                	lw	a5,4(a0)
    800041b6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041b8:	04451783          	lh	a5,68(a0)
    800041bc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041c0:	04a51783          	lh	a5,74(a0)
    800041c4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041c8:	04c56783          	lwu	a5,76(a0)
    800041cc:	e99c                	sd	a5,16(a1)
}
    800041ce:	60a2                	ld	ra,8(sp)
    800041d0:	6402                	ld	s0,0(sp)
    800041d2:	0141                	addi	sp,sp,16
    800041d4:	8082                	ret

00000000800041d6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041d6:	457c                	lw	a5,76(a0)
    800041d8:	10d7e063          	bltu	a5,a3,800042d8 <readi+0x102>
{
    800041dc:	7159                	addi	sp,sp,-112
    800041de:	f486                	sd	ra,104(sp)
    800041e0:	f0a2                	sd	s0,96(sp)
    800041e2:	eca6                	sd	s1,88(sp)
    800041e4:	e0d2                	sd	s4,64(sp)
    800041e6:	fc56                	sd	s5,56(sp)
    800041e8:	f85a                	sd	s6,48(sp)
    800041ea:	f45e                	sd	s7,40(sp)
    800041ec:	1880                	addi	s0,sp,112
    800041ee:	8b2a                	mv	s6,a0
    800041f0:	8bae                	mv	s7,a1
    800041f2:	8a32                	mv	s4,a2
    800041f4:	84b6                	mv	s1,a3
    800041f6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800041f8:	9f35                	addw	a4,a4,a3
    return 0;
    800041fa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800041fc:	0cd76563          	bltu	a4,a3,800042c6 <readi+0xf0>
    80004200:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004202:	00e7f463          	bgeu	a5,a4,8000420a <readi+0x34>
    n = ip->size - off;
    80004206:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000420a:	0a0a8563          	beqz	s5,800042b4 <readi+0xde>
    8000420e:	e8ca                	sd	s2,80(sp)
    80004210:	f062                	sd	s8,32(sp)
    80004212:	ec66                	sd	s9,24(sp)
    80004214:	e86a                	sd	s10,16(sp)
    80004216:	e46e                	sd	s11,8(sp)
    80004218:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000421a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000421e:	5c7d                	li	s8,-1
    80004220:	a82d                	j	8000425a <readi+0x84>
    80004222:	020d1d93          	slli	s11,s10,0x20
    80004226:	020ddd93          	srli	s11,s11,0x20
    8000422a:	05890613          	addi	a2,s2,88
    8000422e:	86ee                	mv	a3,s11
    80004230:	963e                	add	a2,a2,a5
    80004232:	85d2                	mv	a1,s4
    80004234:	855e                	mv	a0,s7
    80004236:	ffffe097          	auipc	ra,0xffffe
    8000423a:	71a080e7          	jalr	1818(ra) # 80002950 <either_copyout>
    8000423e:	05850963          	beq	a0,s8,80004290 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004242:	854a                	mv	a0,s2
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	5f8080e7          	jalr	1528(ra) # 8000383c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000424c:	013d09bb          	addw	s3,s10,s3
    80004250:	009d04bb          	addw	s1,s10,s1
    80004254:	9a6e                	add	s4,s4,s11
    80004256:	0559f963          	bgeu	s3,s5,800042a8 <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    8000425a:	00a4d59b          	srliw	a1,s1,0xa
    8000425e:	855a                	mv	a0,s6
    80004260:	00000097          	auipc	ra,0x0
    80004264:	89e080e7          	jalr	-1890(ra) # 80003afe <bmap>
    80004268:	85aa                	mv	a1,a0
    if(addr == 0)
    8000426a:	c539                	beqz	a0,800042b8 <readi+0xe2>
    bp = bread(ip->dev, addr);
    8000426c:	000b2503          	lw	a0,0(s6)
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	49c080e7          	jalr	1180(ra) # 8000370c <bread>
    80004278:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000427a:	3ff4f793          	andi	a5,s1,1023
    8000427e:	40fc873b          	subw	a4,s9,a5
    80004282:	413a86bb          	subw	a3,s5,s3
    80004286:	8d3a                	mv	s10,a4
    80004288:	f8e6fde3          	bgeu	a3,a4,80004222 <readi+0x4c>
    8000428c:	8d36                	mv	s10,a3
    8000428e:	bf51                	j	80004222 <readi+0x4c>
      brelse(bp);
    80004290:	854a                	mv	a0,s2
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	5aa080e7          	jalr	1450(ra) # 8000383c <brelse>
      tot = -1;
    8000429a:	59fd                	li	s3,-1
      break;
    8000429c:	6946                	ld	s2,80(sp)
    8000429e:	7c02                	ld	s8,32(sp)
    800042a0:	6ce2                	ld	s9,24(sp)
    800042a2:	6d42                	ld	s10,16(sp)
    800042a4:	6da2                	ld	s11,8(sp)
    800042a6:	a831                	j	800042c2 <readi+0xec>
    800042a8:	6946                	ld	s2,80(sp)
    800042aa:	7c02                	ld	s8,32(sp)
    800042ac:	6ce2                	ld	s9,24(sp)
    800042ae:	6d42                	ld	s10,16(sp)
    800042b0:	6da2                	ld	s11,8(sp)
    800042b2:	a801                	j	800042c2 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042b4:	89d6                	mv	s3,s5
    800042b6:	a031                	j	800042c2 <readi+0xec>
    800042b8:	6946                	ld	s2,80(sp)
    800042ba:	7c02                	ld	s8,32(sp)
    800042bc:	6ce2                	ld	s9,24(sp)
    800042be:	6d42                	ld	s10,16(sp)
    800042c0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800042c2:	854e                	mv	a0,s3
    800042c4:	69a6                	ld	s3,72(sp)
}
    800042c6:	70a6                	ld	ra,104(sp)
    800042c8:	7406                	ld	s0,96(sp)
    800042ca:	64e6                	ld	s1,88(sp)
    800042cc:	6a06                	ld	s4,64(sp)
    800042ce:	7ae2                	ld	s5,56(sp)
    800042d0:	7b42                	ld	s6,48(sp)
    800042d2:	7ba2                	ld	s7,40(sp)
    800042d4:	6165                	addi	sp,sp,112
    800042d6:	8082                	ret
    return 0;
    800042d8:	4501                	li	a0,0
}
    800042da:	8082                	ret

00000000800042dc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042dc:	457c                	lw	a5,76(a0)
    800042de:	10d7e963          	bltu	a5,a3,800043f0 <writei+0x114>
{
    800042e2:	7159                	addi	sp,sp,-112
    800042e4:	f486                	sd	ra,104(sp)
    800042e6:	f0a2                	sd	s0,96(sp)
    800042e8:	e8ca                	sd	s2,80(sp)
    800042ea:	e0d2                	sd	s4,64(sp)
    800042ec:	fc56                	sd	s5,56(sp)
    800042ee:	f85a                	sd	s6,48(sp)
    800042f0:	f45e                	sd	s7,40(sp)
    800042f2:	1880                	addi	s0,sp,112
    800042f4:	8aaa                	mv	s5,a0
    800042f6:	8bae                	mv	s7,a1
    800042f8:	8a32                	mv	s4,a2
    800042fa:	8936                	mv	s2,a3
    800042fc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800042fe:	00e687bb          	addw	a5,a3,a4
    80004302:	0ed7e963          	bltu	a5,a3,800043f4 <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004306:	00043737          	lui	a4,0x43
    8000430a:	0ef76763          	bltu	a4,a5,800043f8 <writei+0x11c>
    8000430e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004310:	0c0b0863          	beqz	s6,800043e0 <writei+0x104>
    80004314:	eca6                	sd	s1,88(sp)
    80004316:	f062                	sd	s8,32(sp)
    80004318:	ec66                	sd	s9,24(sp)
    8000431a:	e86a                	sd	s10,16(sp)
    8000431c:	e46e                	sd	s11,8(sp)
    8000431e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004320:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004324:	5c7d                	li	s8,-1
    80004326:	a091                	j	8000436a <writei+0x8e>
    80004328:	020d1d93          	slli	s11,s10,0x20
    8000432c:	020ddd93          	srli	s11,s11,0x20
    80004330:	05848513          	addi	a0,s1,88
    80004334:	86ee                	mv	a3,s11
    80004336:	8652                	mv	a2,s4
    80004338:	85de                	mv	a1,s7
    8000433a:	953e                	add	a0,a0,a5
    8000433c:	ffffe097          	auipc	ra,0xffffe
    80004340:	66c080e7          	jalr	1644(ra) # 800029a8 <either_copyin>
    80004344:	05850e63          	beq	a0,s8,800043a0 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004348:	8526                	mv	a0,s1
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	798080e7          	jalr	1944(ra) # 80004ae2 <log_write>
    brelse(bp);
    80004352:	8526                	mv	a0,s1
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	4e8080e7          	jalr	1256(ra) # 8000383c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000435c:	013d09bb          	addw	s3,s10,s3
    80004360:	012d093b          	addw	s2,s10,s2
    80004364:	9a6e                	add	s4,s4,s11
    80004366:	0569f263          	bgeu	s3,s6,800043aa <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000436a:	00a9559b          	srliw	a1,s2,0xa
    8000436e:	8556                	mv	a0,s5
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	78e080e7          	jalr	1934(ra) # 80003afe <bmap>
    80004378:	85aa                	mv	a1,a0
    if(addr == 0)
    8000437a:	c905                	beqz	a0,800043aa <writei+0xce>
    bp = bread(ip->dev, addr);
    8000437c:	000aa503          	lw	a0,0(s5)
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	38c080e7          	jalr	908(ra) # 8000370c <bread>
    80004388:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000438a:	3ff97793          	andi	a5,s2,1023
    8000438e:	40fc873b          	subw	a4,s9,a5
    80004392:	413b06bb          	subw	a3,s6,s3
    80004396:	8d3a                	mv	s10,a4
    80004398:	f8e6f8e3          	bgeu	a3,a4,80004328 <writei+0x4c>
    8000439c:	8d36                	mv	s10,a3
    8000439e:	b769                	j	80004328 <writei+0x4c>
      brelse(bp);
    800043a0:	8526                	mv	a0,s1
    800043a2:	fffff097          	auipc	ra,0xfffff
    800043a6:	49a080e7          	jalr	1178(ra) # 8000383c <brelse>
  }

  if(off > ip->size)
    800043aa:	04caa783          	lw	a5,76(s5)
    800043ae:	0327fb63          	bgeu	a5,s2,800043e4 <writei+0x108>
    ip->size = off;
    800043b2:	052aa623          	sw	s2,76(s5)
    800043b6:	64e6                	ld	s1,88(sp)
    800043b8:	7c02                	ld	s8,32(sp)
    800043ba:	6ce2                	ld	s9,24(sp)
    800043bc:	6d42                	ld	s10,16(sp)
    800043be:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043c0:	8556                	mv	a0,s5
    800043c2:	00000097          	auipc	ra,0x0
    800043c6:	a8c080e7          	jalr	-1396(ra) # 80003e4e <iupdate>

  return tot;
    800043ca:	854e                	mv	a0,s3
    800043cc:	69a6                	ld	s3,72(sp)
}
    800043ce:	70a6                	ld	ra,104(sp)
    800043d0:	7406                	ld	s0,96(sp)
    800043d2:	6946                	ld	s2,80(sp)
    800043d4:	6a06                	ld	s4,64(sp)
    800043d6:	7ae2                	ld	s5,56(sp)
    800043d8:	7b42                	ld	s6,48(sp)
    800043da:	7ba2                	ld	s7,40(sp)
    800043dc:	6165                	addi	sp,sp,112
    800043de:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043e0:	89da                	mv	s3,s6
    800043e2:	bff9                	j	800043c0 <writei+0xe4>
    800043e4:	64e6                	ld	s1,88(sp)
    800043e6:	7c02                	ld	s8,32(sp)
    800043e8:	6ce2                	ld	s9,24(sp)
    800043ea:	6d42                	ld	s10,16(sp)
    800043ec:	6da2                	ld	s11,8(sp)
    800043ee:	bfc9                	j	800043c0 <writei+0xe4>
    return -1;
    800043f0:	557d                	li	a0,-1
}
    800043f2:	8082                	ret
    return -1;
    800043f4:	557d                	li	a0,-1
    800043f6:	bfe1                	j	800043ce <writei+0xf2>
    return -1;
    800043f8:	557d                	li	a0,-1
    800043fa:	bfd1                	j	800043ce <writei+0xf2>

00000000800043fc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800043fc:	1141                	addi	sp,sp,-16
    800043fe:	e406                	sd	ra,8(sp)
    80004400:	e022                	sd	s0,0(sp)
    80004402:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004404:	4639                	li	a2,14
    80004406:	ffffd097          	auipc	ra,0xffffd
    8000440a:	a0c080e7          	jalr	-1524(ra) # 80000e12 <strncmp>
}
    8000440e:	60a2                	ld	ra,8(sp)
    80004410:	6402                	ld	s0,0(sp)
    80004412:	0141                	addi	sp,sp,16
    80004414:	8082                	ret

0000000080004416 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004416:	711d                	addi	sp,sp,-96
    80004418:	ec86                	sd	ra,88(sp)
    8000441a:	e8a2                	sd	s0,80(sp)
    8000441c:	e4a6                	sd	s1,72(sp)
    8000441e:	e0ca                	sd	s2,64(sp)
    80004420:	fc4e                	sd	s3,56(sp)
    80004422:	f852                	sd	s4,48(sp)
    80004424:	f456                	sd	s5,40(sp)
    80004426:	f05a                	sd	s6,32(sp)
    80004428:	ec5e                	sd	s7,24(sp)
    8000442a:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000442c:	04451703          	lh	a4,68(a0)
    80004430:	4785                	li	a5,1
    80004432:	00f71f63          	bne	a4,a5,80004450 <dirlookup+0x3a>
    80004436:	892a                	mv	s2,a0
    80004438:	8aae                	mv	s5,a1
    8000443a:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000443c:	457c                	lw	a5,76(a0)
    8000443e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004440:	fa040a13          	addi	s4,s0,-96
    80004444:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80004446:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000444a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000444c:	e79d                	bnez	a5,8000447a <dirlookup+0x64>
    8000444e:	a88d                	j	800044c0 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80004450:	00004517          	auipc	a0,0x4
    80004454:	09050513          	addi	a0,a0,144 # 800084e0 <etext+0x4e0>
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	108080e7          	jalr	264(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004460:	00004517          	auipc	a0,0x4
    80004464:	09850513          	addi	a0,a0,152 # 800084f8 <etext+0x4f8>
    80004468:	ffffc097          	auipc	ra,0xffffc
    8000446c:	0f8080e7          	jalr	248(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004470:	24c1                	addiw	s1,s1,16
    80004472:	04c92783          	lw	a5,76(s2)
    80004476:	04f4f463          	bgeu	s1,a5,800044be <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000447a:	874e                	mv	a4,s3
    8000447c:	86a6                	mv	a3,s1
    8000447e:	8652                	mv	a2,s4
    80004480:	4581                	li	a1,0
    80004482:	854a                	mv	a0,s2
    80004484:	00000097          	auipc	ra,0x0
    80004488:	d52080e7          	jalr	-686(ra) # 800041d6 <readi>
    8000448c:	fd351ae3          	bne	a0,s3,80004460 <dirlookup+0x4a>
    if(de.inum == 0)
    80004490:	fa045783          	lhu	a5,-96(s0)
    80004494:	dff1                	beqz	a5,80004470 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80004496:	85da                	mv	a1,s6
    80004498:	8556                	mv	a0,s5
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	f62080e7          	jalr	-158(ra) # 800043fc <namecmp>
    800044a2:	f579                	bnez	a0,80004470 <dirlookup+0x5a>
      if(poff)
    800044a4:	000b8463          	beqz	s7,800044ac <dirlookup+0x96>
        *poff = off;
    800044a8:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800044ac:	fa045583          	lhu	a1,-96(s0)
    800044b0:	00092503          	lw	a0,0(s2)
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	726080e7          	jalr	1830(ra) # 80003bda <iget>
    800044bc:	a011                	j	800044c0 <dirlookup+0xaa>
  return 0;
    800044be:	4501                	li	a0,0
}
    800044c0:	60e6                	ld	ra,88(sp)
    800044c2:	6446                	ld	s0,80(sp)
    800044c4:	64a6                	ld	s1,72(sp)
    800044c6:	6906                	ld	s2,64(sp)
    800044c8:	79e2                	ld	s3,56(sp)
    800044ca:	7a42                	ld	s4,48(sp)
    800044cc:	7aa2                	ld	s5,40(sp)
    800044ce:	7b02                	ld	s6,32(sp)
    800044d0:	6be2                	ld	s7,24(sp)
    800044d2:	6125                	addi	sp,sp,96
    800044d4:	8082                	ret

00000000800044d6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044d6:	711d                	addi	sp,sp,-96
    800044d8:	ec86                	sd	ra,88(sp)
    800044da:	e8a2                	sd	s0,80(sp)
    800044dc:	e4a6                	sd	s1,72(sp)
    800044de:	e0ca                	sd	s2,64(sp)
    800044e0:	fc4e                	sd	s3,56(sp)
    800044e2:	f852                	sd	s4,48(sp)
    800044e4:	f456                	sd	s5,40(sp)
    800044e6:	f05a                	sd	s6,32(sp)
    800044e8:	ec5e                	sd	s7,24(sp)
    800044ea:	e862                	sd	s8,16(sp)
    800044ec:	e466                	sd	s9,8(sp)
    800044ee:	e06a                	sd	s10,0(sp)
    800044f0:	1080                	addi	s0,sp,96
    800044f2:	84aa                	mv	s1,a0
    800044f4:	8b2e                	mv	s6,a1
    800044f6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044f8:	00054703          	lbu	a4,0(a0)
    800044fc:	02f00793          	li	a5,47
    80004500:	02f70363          	beq	a4,a5,80004526 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004504:	ffffd097          	auipc	ra,0xffffd
    80004508:	5ac080e7          	jalr	1452(ra) # 80001ab0 <myproc>
    8000450c:	32853503          	ld	a0,808(a0)
    80004510:	00000097          	auipc	ra,0x0
    80004514:	9cc080e7          	jalr	-1588(ra) # 80003edc <idup>
    80004518:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000451a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000451e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004520:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004522:	4b85                	li	s7,1
    80004524:	a87d                	j	800045e2 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004526:	4585                	li	a1,1
    80004528:	852e                	mv	a0,a1
    8000452a:	fffff097          	auipc	ra,0xfffff
    8000452e:	6b0080e7          	jalr	1712(ra) # 80003bda <iget>
    80004532:	8a2a                	mv	s4,a0
    80004534:	b7dd                	j	8000451a <namex+0x44>
      iunlockput(ip);
    80004536:	8552                	mv	a0,s4
    80004538:	00000097          	auipc	ra,0x0
    8000453c:	c48080e7          	jalr	-952(ra) # 80004180 <iunlockput>
      return 0;
    80004540:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004542:	8552                	mv	a0,s4
    80004544:	60e6                	ld	ra,88(sp)
    80004546:	6446                	ld	s0,80(sp)
    80004548:	64a6                	ld	s1,72(sp)
    8000454a:	6906                	ld	s2,64(sp)
    8000454c:	79e2                	ld	s3,56(sp)
    8000454e:	7a42                	ld	s4,48(sp)
    80004550:	7aa2                	ld	s5,40(sp)
    80004552:	7b02                	ld	s6,32(sp)
    80004554:	6be2                	ld	s7,24(sp)
    80004556:	6c42                	ld	s8,16(sp)
    80004558:	6ca2                	ld	s9,8(sp)
    8000455a:	6d02                	ld	s10,0(sp)
    8000455c:	6125                	addi	sp,sp,96
    8000455e:	8082                	ret
      iunlock(ip);
    80004560:	8552                	mv	a0,s4
    80004562:	00000097          	auipc	ra,0x0
    80004566:	a7e080e7          	jalr	-1410(ra) # 80003fe0 <iunlock>
      return ip;
    8000456a:	bfe1                	j	80004542 <namex+0x6c>
      iunlockput(ip);
    8000456c:	8552                	mv	a0,s4
    8000456e:	00000097          	auipc	ra,0x0
    80004572:	c12080e7          	jalr	-1006(ra) # 80004180 <iunlockput>
      return 0;
    80004576:	8a4e                	mv	s4,s3
    80004578:	b7e9                	j	80004542 <namex+0x6c>
  len = path - s;
    8000457a:	40998633          	sub	a2,s3,s1
    8000457e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004582:	09ac5863          	bge	s8,s10,80004612 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004586:	8666                	mv	a2,s9
    80004588:	85a6                	mv	a1,s1
    8000458a:	8556                	mv	a0,s5
    8000458c:	ffffd097          	auipc	ra,0xffffd
    80004590:	80e080e7          	jalr	-2034(ra) # 80000d9a <memmove>
    80004594:	84ce                	mv	s1,s3
  while(*path == '/')
    80004596:	0004c783          	lbu	a5,0(s1)
    8000459a:	01279763          	bne	a5,s2,800045a8 <namex+0xd2>
    path++;
    8000459e:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045a0:	0004c783          	lbu	a5,0(s1)
    800045a4:	ff278de3          	beq	a5,s2,8000459e <namex+0xc8>
    ilock(ip);
    800045a8:	8552                	mv	a0,s4
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	970080e7          	jalr	-1680(ra) # 80003f1a <ilock>
    if(ip->type != T_DIR){
    800045b2:	044a1783          	lh	a5,68(s4)
    800045b6:	f97790e3          	bne	a5,s7,80004536 <namex+0x60>
    if(nameiparent && *path == '\0'){
    800045ba:	000b0563          	beqz	s6,800045c4 <namex+0xee>
    800045be:	0004c783          	lbu	a5,0(s1)
    800045c2:	dfd9                	beqz	a5,80004560 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045c4:	4601                	li	a2,0
    800045c6:	85d6                	mv	a1,s5
    800045c8:	8552                	mv	a0,s4
    800045ca:	00000097          	auipc	ra,0x0
    800045ce:	e4c080e7          	jalr	-436(ra) # 80004416 <dirlookup>
    800045d2:	89aa                	mv	s3,a0
    800045d4:	dd41                	beqz	a0,8000456c <namex+0x96>
    iunlockput(ip);
    800045d6:	8552                	mv	a0,s4
    800045d8:	00000097          	auipc	ra,0x0
    800045dc:	ba8080e7          	jalr	-1112(ra) # 80004180 <iunlockput>
    ip = next;
    800045e0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800045e2:	0004c783          	lbu	a5,0(s1)
    800045e6:	01279763          	bne	a5,s2,800045f4 <namex+0x11e>
    path++;
    800045ea:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045ec:	0004c783          	lbu	a5,0(s1)
    800045f0:	ff278de3          	beq	a5,s2,800045ea <namex+0x114>
  if(*path == 0)
    800045f4:	cb9d                	beqz	a5,8000462a <namex+0x154>
  while(*path != '/' && *path != 0)
    800045f6:	0004c783          	lbu	a5,0(s1)
    800045fa:	89a6                	mv	s3,s1
  len = path - s;
    800045fc:	4d01                	li	s10,0
    800045fe:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004600:	01278963          	beq	a5,s2,80004612 <namex+0x13c>
    80004604:	dbbd                	beqz	a5,8000457a <namex+0xa4>
    path++;
    80004606:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004608:	0009c783          	lbu	a5,0(s3)
    8000460c:	ff279ce3          	bne	a5,s2,80004604 <namex+0x12e>
    80004610:	b7ad                	j	8000457a <namex+0xa4>
    memmove(name, s, len);
    80004612:	2601                	sext.w	a2,a2
    80004614:	85a6                	mv	a1,s1
    80004616:	8556                	mv	a0,s5
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	782080e7          	jalr	1922(ra) # 80000d9a <memmove>
    name[len] = 0;
    80004620:	9d56                	add	s10,s10,s5
    80004622:	000d0023          	sb	zero,0(s10)
    80004626:	84ce                	mv	s1,s3
    80004628:	b7bd                	j	80004596 <namex+0xc0>
  if(nameiparent){
    8000462a:	f00b0ce3          	beqz	s6,80004542 <namex+0x6c>
    iput(ip);
    8000462e:	8552                	mv	a0,s4
    80004630:	00000097          	auipc	ra,0x0
    80004634:	aa8080e7          	jalr	-1368(ra) # 800040d8 <iput>
    return 0;
    80004638:	4a01                	li	s4,0
    8000463a:	b721                	j	80004542 <namex+0x6c>

000000008000463c <dirlink>:
{
    8000463c:	715d                	addi	sp,sp,-80
    8000463e:	e486                	sd	ra,72(sp)
    80004640:	e0a2                	sd	s0,64(sp)
    80004642:	f84a                	sd	s2,48(sp)
    80004644:	ec56                	sd	s5,24(sp)
    80004646:	e85a                	sd	s6,16(sp)
    80004648:	0880                	addi	s0,sp,80
    8000464a:	892a                	mv	s2,a0
    8000464c:	8aae                	mv	s5,a1
    8000464e:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004650:	4601                	li	a2,0
    80004652:	00000097          	auipc	ra,0x0
    80004656:	dc4080e7          	jalr	-572(ra) # 80004416 <dirlookup>
    8000465a:	e129                	bnez	a0,8000469c <dirlink+0x60>
    8000465c:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000465e:	04c92483          	lw	s1,76(s2)
    80004662:	cca9                	beqz	s1,800046bc <dirlink+0x80>
    80004664:	f44e                	sd	s3,40(sp)
    80004666:	f052                	sd	s4,32(sp)
    80004668:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000466a:	fb040a13          	addi	s4,s0,-80
    8000466e:	49c1                	li	s3,16
    80004670:	874e                	mv	a4,s3
    80004672:	86a6                	mv	a3,s1
    80004674:	8652                	mv	a2,s4
    80004676:	4581                	li	a1,0
    80004678:	854a                	mv	a0,s2
    8000467a:	00000097          	auipc	ra,0x0
    8000467e:	b5c080e7          	jalr	-1188(ra) # 800041d6 <readi>
    80004682:	03351363          	bne	a0,s3,800046a8 <dirlink+0x6c>
    if(de.inum == 0)
    80004686:	fb045783          	lhu	a5,-80(s0)
    8000468a:	c79d                	beqz	a5,800046b8 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000468c:	24c1                	addiw	s1,s1,16
    8000468e:	04c92783          	lw	a5,76(s2)
    80004692:	fcf4efe3          	bltu	s1,a5,80004670 <dirlink+0x34>
    80004696:	79a2                	ld	s3,40(sp)
    80004698:	7a02                	ld	s4,32(sp)
    8000469a:	a00d                	j	800046bc <dirlink+0x80>
    iput(ip);
    8000469c:	00000097          	auipc	ra,0x0
    800046a0:	a3c080e7          	jalr	-1476(ra) # 800040d8 <iput>
    return -1;
    800046a4:	557d                	li	a0,-1
    800046a6:	a0a9                	j	800046f0 <dirlink+0xb4>
      panic("dirlink read");
    800046a8:	00004517          	auipc	a0,0x4
    800046ac:	e6050513          	addi	a0,a0,-416 # 80008508 <etext+0x508>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	eb0080e7          	jalr	-336(ra) # 80000560 <panic>
    800046b8:	79a2                	ld	s3,40(sp)
    800046ba:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800046bc:	4639                	li	a2,14
    800046be:	85d6                	mv	a1,s5
    800046c0:	fb240513          	addi	a0,s0,-78
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	788080e7          	jalr	1928(ra) # 80000e4c <strncpy>
  de.inum = inum;
    800046cc:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046d0:	4741                	li	a4,16
    800046d2:	86a6                	mv	a3,s1
    800046d4:	fb040613          	addi	a2,s0,-80
    800046d8:	4581                	li	a1,0
    800046da:	854a                	mv	a0,s2
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	c00080e7          	jalr	-1024(ra) # 800042dc <writei>
    800046e4:	1541                	addi	a0,a0,-16
    800046e6:	00a03533          	snez	a0,a0
    800046ea:	40a0053b          	negw	a0,a0
    800046ee:	74e2                	ld	s1,56(sp)
}
    800046f0:	60a6                	ld	ra,72(sp)
    800046f2:	6406                	ld	s0,64(sp)
    800046f4:	7942                	ld	s2,48(sp)
    800046f6:	6ae2                	ld	s5,24(sp)
    800046f8:	6b42                	ld	s6,16(sp)
    800046fa:	6161                	addi	sp,sp,80
    800046fc:	8082                	ret

00000000800046fe <namei>:

struct inode*
namei(char *path)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004706:	fe040613          	addi	a2,s0,-32
    8000470a:	4581                	li	a1,0
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	dca080e7          	jalr	-566(ra) # 800044d6 <namex>
}
    80004714:	60e2                	ld	ra,24(sp)
    80004716:	6442                	ld	s0,16(sp)
    80004718:	6105                	addi	sp,sp,32
    8000471a:	8082                	ret

000000008000471c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000471c:	1141                	addi	sp,sp,-16
    8000471e:	e406                	sd	ra,8(sp)
    80004720:	e022                	sd	s0,0(sp)
    80004722:	0800                	addi	s0,sp,16
    80004724:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004726:	4585                	li	a1,1
    80004728:	00000097          	auipc	ra,0x0
    8000472c:	dae080e7          	jalr	-594(ra) # 800044d6 <namex>
}
    80004730:	60a2                	ld	ra,8(sp)
    80004732:	6402                	ld	s0,0(sp)
    80004734:	0141                	addi	sp,sp,16
    80004736:	8082                	ret

0000000080004738 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004738:	1101                	addi	sp,sp,-32
    8000473a:	ec06                	sd	ra,24(sp)
    8000473c:	e822                	sd	s0,16(sp)
    8000473e:	e426                	sd	s1,8(sp)
    80004740:	e04a                	sd	s2,0(sp)
    80004742:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004744:	00024917          	auipc	s2,0x24
    80004748:	60c90913          	addi	s2,s2,1548 # 80028d50 <log>
    8000474c:	01892583          	lw	a1,24(s2)
    80004750:	02892503          	lw	a0,40(s2)
    80004754:	fffff097          	auipc	ra,0xfffff
    80004758:	fb8080e7          	jalr	-72(ra) # 8000370c <bread>
    8000475c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000475e:	02c92603          	lw	a2,44(s2)
    80004762:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004764:	00c05f63          	blez	a2,80004782 <write_head+0x4a>
    80004768:	00024717          	auipc	a4,0x24
    8000476c:	61870713          	addi	a4,a4,1560 # 80028d80 <log+0x30>
    80004770:	87aa                	mv	a5,a0
    80004772:	060a                	slli	a2,a2,0x2
    80004774:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004776:	4314                	lw	a3,0(a4)
    80004778:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000477a:	0711                	addi	a4,a4,4
    8000477c:	0791                	addi	a5,a5,4
    8000477e:	fec79ce3          	bne	a5,a2,80004776 <write_head+0x3e>
  }
  bwrite(buf);
    80004782:	8526                	mv	a0,s1
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	07a080e7          	jalr	122(ra) # 800037fe <bwrite>
  brelse(buf);
    8000478c:	8526                	mv	a0,s1
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	0ae080e7          	jalr	174(ra) # 8000383c <brelse>
}
    80004796:	60e2                	ld	ra,24(sp)
    80004798:	6442                	ld	s0,16(sp)
    8000479a:	64a2                	ld	s1,8(sp)
    8000479c:	6902                	ld	s2,0(sp)
    8000479e:	6105                	addi	sp,sp,32
    800047a0:	8082                	ret

00000000800047a2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047a2:	00024797          	auipc	a5,0x24
    800047a6:	5da7a783          	lw	a5,1498(a5) # 80028d7c <log+0x2c>
    800047aa:	0cf05063          	blez	a5,8000486a <install_trans+0xc8>
{
    800047ae:	715d                	addi	sp,sp,-80
    800047b0:	e486                	sd	ra,72(sp)
    800047b2:	e0a2                	sd	s0,64(sp)
    800047b4:	fc26                	sd	s1,56(sp)
    800047b6:	f84a                	sd	s2,48(sp)
    800047b8:	f44e                	sd	s3,40(sp)
    800047ba:	f052                	sd	s4,32(sp)
    800047bc:	ec56                	sd	s5,24(sp)
    800047be:	e85a                	sd	s6,16(sp)
    800047c0:	e45e                	sd	s7,8(sp)
    800047c2:	0880                	addi	s0,sp,80
    800047c4:	8b2a                	mv	s6,a0
    800047c6:	00024a97          	auipc	s5,0x24
    800047ca:	5baa8a93          	addi	s5,s5,1466 # 80028d80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ce:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047d0:	00024997          	auipc	s3,0x24
    800047d4:	58098993          	addi	s3,s3,1408 # 80028d50 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047d8:	40000b93          	li	s7,1024
    800047dc:	a00d                	j	800047fe <install_trans+0x5c>
    brelse(lbuf);
    800047de:	854a                	mv	a0,s2
    800047e0:	fffff097          	auipc	ra,0xfffff
    800047e4:	05c080e7          	jalr	92(ra) # 8000383c <brelse>
    brelse(dbuf);
    800047e8:	8526                	mv	a0,s1
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	052080e7          	jalr	82(ra) # 8000383c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047f2:	2a05                	addiw	s4,s4,1
    800047f4:	0a91                	addi	s5,s5,4
    800047f6:	02c9a783          	lw	a5,44(s3)
    800047fa:	04fa5d63          	bge	s4,a5,80004854 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047fe:	0189a583          	lw	a1,24(s3)
    80004802:	014585bb          	addw	a1,a1,s4
    80004806:	2585                	addiw	a1,a1,1
    80004808:	0289a503          	lw	a0,40(s3)
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	f00080e7          	jalr	-256(ra) # 8000370c <bread>
    80004814:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004816:	000aa583          	lw	a1,0(s5)
    8000481a:	0289a503          	lw	a0,40(s3)
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	eee080e7          	jalr	-274(ra) # 8000370c <bread>
    80004826:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004828:	865e                	mv	a2,s7
    8000482a:	05890593          	addi	a1,s2,88
    8000482e:	05850513          	addi	a0,a0,88
    80004832:	ffffc097          	auipc	ra,0xffffc
    80004836:	568080e7          	jalr	1384(ra) # 80000d9a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000483a:	8526                	mv	a0,s1
    8000483c:	fffff097          	auipc	ra,0xfffff
    80004840:	fc2080e7          	jalr	-62(ra) # 800037fe <bwrite>
    if(recovering == 0)
    80004844:	f80b1de3          	bnez	s6,800047de <install_trans+0x3c>
      bunpin(dbuf);
    80004848:	8526                	mv	a0,s1
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	0c6080e7          	jalr	198(ra) # 80003910 <bunpin>
    80004852:	b771                	j	800047de <install_trans+0x3c>
}
    80004854:	60a6                	ld	ra,72(sp)
    80004856:	6406                	ld	s0,64(sp)
    80004858:	74e2                	ld	s1,56(sp)
    8000485a:	7942                	ld	s2,48(sp)
    8000485c:	79a2                	ld	s3,40(sp)
    8000485e:	7a02                	ld	s4,32(sp)
    80004860:	6ae2                	ld	s5,24(sp)
    80004862:	6b42                	ld	s6,16(sp)
    80004864:	6ba2                	ld	s7,8(sp)
    80004866:	6161                	addi	sp,sp,80
    80004868:	8082                	ret
    8000486a:	8082                	ret

000000008000486c <initlog>:
{
    8000486c:	7179                	addi	sp,sp,-48
    8000486e:	f406                	sd	ra,40(sp)
    80004870:	f022                	sd	s0,32(sp)
    80004872:	ec26                	sd	s1,24(sp)
    80004874:	e84a                	sd	s2,16(sp)
    80004876:	e44e                	sd	s3,8(sp)
    80004878:	1800                	addi	s0,sp,48
    8000487a:	892a                	mv	s2,a0
    8000487c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000487e:	00024497          	auipc	s1,0x24
    80004882:	4d248493          	addi	s1,s1,1234 # 80028d50 <log>
    80004886:	00004597          	auipc	a1,0x4
    8000488a:	c9258593          	addi	a1,a1,-878 # 80008518 <etext+0x518>
    8000488e:	8526                	mv	a0,s1
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	31a080e7          	jalr	794(ra) # 80000baa <initlock>
  log.start = sb->logstart;
    80004898:	0149a583          	lw	a1,20(s3)
    8000489c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000489e:	0109a783          	lw	a5,16(s3)
    800048a2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048a4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048a8:	854a                	mv	a0,s2
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	e62080e7          	jalr	-414(ra) # 8000370c <bread>
  log.lh.n = lh->n;
    800048b2:	4d30                	lw	a2,88(a0)
    800048b4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048b6:	00c05f63          	blez	a2,800048d4 <initlog+0x68>
    800048ba:	87aa                	mv	a5,a0
    800048bc:	00024717          	auipc	a4,0x24
    800048c0:	4c470713          	addi	a4,a4,1220 # 80028d80 <log+0x30>
    800048c4:	060a                	slli	a2,a2,0x2
    800048c6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800048c8:	4ff4                	lw	a3,92(a5)
    800048ca:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048cc:	0791                	addi	a5,a5,4
    800048ce:	0711                	addi	a4,a4,4
    800048d0:	fec79ce3          	bne	a5,a2,800048c8 <initlog+0x5c>
  brelse(buf);
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	f68080e7          	jalr	-152(ra) # 8000383c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048dc:	4505                	li	a0,1
    800048de:	00000097          	auipc	ra,0x0
    800048e2:	ec4080e7          	jalr	-316(ra) # 800047a2 <install_trans>
  log.lh.n = 0;
    800048e6:	00024797          	auipc	a5,0x24
    800048ea:	4807ab23          	sw	zero,1174(a5) # 80028d7c <log+0x2c>
  write_head(); // clear the log
    800048ee:	00000097          	auipc	ra,0x0
    800048f2:	e4a080e7          	jalr	-438(ra) # 80004738 <write_head>
}
    800048f6:	70a2                	ld	ra,40(sp)
    800048f8:	7402                	ld	s0,32(sp)
    800048fa:	64e2                	ld	s1,24(sp)
    800048fc:	6942                	ld	s2,16(sp)
    800048fe:	69a2                	ld	s3,8(sp)
    80004900:	6145                	addi	sp,sp,48
    80004902:	8082                	ret

0000000080004904 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004904:	1101                	addi	sp,sp,-32
    80004906:	ec06                	sd	ra,24(sp)
    80004908:	e822                	sd	s0,16(sp)
    8000490a:	e426                	sd	s1,8(sp)
    8000490c:	e04a                	sd	s2,0(sp)
    8000490e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004910:	00024517          	auipc	a0,0x24
    80004914:	44050513          	addi	a0,a0,1088 # 80028d50 <log>
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	326080e7          	jalr	806(ra) # 80000c3e <acquire>
  while(1){
    if(log.committing){
    80004920:	00024497          	auipc	s1,0x24
    80004924:	43048493          	addi	s1,s1,1072 # 80028d50 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004928:	4979                	li	s2,30
    8000492a:	a039                	j	80004938 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000492c:	85a6                	mv	a1,s1
    8000492e:	8526                	mv	a0,s1
    80004930:	ffffe097          	auipc	ra,0xffffe
    80004934:	bf2080e7          	jalr	-1038(ra) # 80002522 <sleep>
    if(log.committing){
    80004938:	50dc                	lw	a5,36(s1)
    8000493a:	fbed                	bnez	a5,8000492c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000493c:	5098                	lw	a4,32(s1)
    8000493e:	2705                	addiw	a4,a4,1
    80004940:	0027179b          	slliw	a5,a4,0x2
    80004944:	9fb9                	addw	a5,a5,a4
    80004946:	0017979b          	slliw	a5,a5,0x1
    8000494a:	54d4                	lw	a3,44(s1)
    8000494c:	9fb5                	addw	a5,a5,a3
    8000494e:	00f95963          	bge	s2,a5,80004960 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004952:	85a6                	mv	a1,s1
    80004954:	8526                	mv	a0,s1
    80004956:	ffffe097          	auipc	ra,0xffffe
    8000495a:	bcc080e7          	jalr	-1076(ra) # 80002522 <sleep>
    8000495e:	bfe9                	j	80004938 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004960:	00024517          	auipc	a0,0x24
    80004964:	3f050513          	addi	a0,a0,1008 # 80028d50 <log>
    80004968:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	384080e7          	jalr	900(ra) # 80000cee <release>
      break;
    }
  }
}
    80004972:	60e2                	ld	ra,24(sp)
    80004974:	6442                	ld	s0,16(sp)
    80004976:	64a2                	ld	s1,8(sp)
    80004978:	6902                	ld	s2,0(sp)
    8000497a:	6105                	addi	sp,sp,32
    8000497c:	8082                	ret

000000008000497e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000497e:	7139                	addi	sp,sp,-64
    80004980:	fc06                	sd	ra,56(sp)
    80004982:	f822                	sd	s0,48(sp)
    80004984:	f426                	sd	s1,40(sp)
    80004986:	f04a                	sd	s2,32(sp)
    80004988:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000498a:	00024497          	auipc	s1,0x24
    8000498e:	3c648493          	addi	s1,s1,966 # 80028d50 <log>
    80004992:	8526                	mv	a0,s1
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	2aa080e7          	jalr	682(ra) # 80000c3e <acquire>
  log.outstanding -= 1;
    8000499c:	509c                	lw	a5,32(s1)
    8000499e:	37fd                	addiw	a5,a5,-1
    800049a0:	893e                	mv	s2,a5
    800049a2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049a4:	50dc                	lw	a5,36(s1)
    800049a6:	e7b9                	bnez	a5,800049f4 <end_op+0x76>
    panic("log.committing");
  if(log.outstanding == 0){
    800049a8:	06091263          	bnez	s2,80004a0c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800049ac:	00024497          	auipc	s1,0x24
    800049b0:	3a448493          	addi	s1,s1,932 # 80028d50 <log>
    800049b4:	4785                	li	a5,1
    800049b6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049b8:	8526                	mv	a0,s1
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	334080e7          	jalr	820(ra) # 80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049c2:	54dc                	lw	a5,44(s1)
    800049c4:	06f04863          	bgtz	a5,80004a34 <end_op+0xb6>
    acquire(&log.lock);
    800049c8:	00024497          	auipc	s1,0x24
    800049cc:	38848493          	addi	s1,s1,904 # 80028d50 <log>
    800049d0:	8526                	mv	a0,s1
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	26c080e7          	jalr	620(ra) # 80000c3e <acquire>
    log.committing = 0;
    800049da:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049de:	8526                	mv	a0,s1
    800049e0:	ffffe097          	auipc	ra,0xffffe
    800049e4:	ba6080e7          	jalr	-1114(ra) # 80002586 <wakeup>
    release(&log.lock);
    800049e8:	8526                	mv	a0,s1
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	304080e7          	jalr	772(ra) # 80000cee <release>
}
    800049f2:	a81d                	j	80004a28 <end_op+0xaa>
    800049f4:	ec4e                	sd	s3,24(sp)
    800049f6:	e852                	sd	s4,16(sp)
    800049f8:	e456                	sd	s5,8(sp)
    800049fa:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    800049fc:	00004517          	auipc	a0,0x4
    80004a00:	b2450513          	addi	a0,a0,-1244 # 80008520 <etext+0x520>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	b5c080e7          	jalr	-1188(ra) # 80000560 <panic>
    wakeup(&log);
    80004a0c:	00024497          	auipc	s1,0x24
    80004a10:	34448493          	addi	s1,s1,836 # 80028d50 <log>
    80004a14:	8526                	mv	a0,s1
    80004a16:	ffffe097          	auipc	ra,0xffffe
    80004a1a:	b70080e7          	jalr	-1168(ra) # 80002586 <wakeup>
  release(&log.lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	2ce080e7          	jalr	718(ra) # 80000cee <release>
}
    80004a28:	70e2                	ld	ra,56(sp)
    80004a2a:	7442                	ld	s0,48(sp)
    80004a2c:	74a2                	ld	s1,40(sp)
    80004a2e:	7902                	ld	s2,32(sp)
    80004a30:	6121                	addi	sp,sp,64
    80004a32:	8082                	ret
    80004a34:	ec4e                	sd	s3,24(sp)
    80004a36:	e852                	sd	s4,16(sp)
    80004a38:	e456                	sd	s5,8(sp)
    80004a3a:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a3c:	00024a97          	auipc	s5,0x24
    80004a40:	344a8a93          	addi	s5,s5,836 # 80028d80 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a44:	00024a17          	auipc	s4,0x24
    80004a48:	30ca0a13          	addi	s4,s4,780 # 80028d50 <log>
    memmove(to->data, from->data, BSIZE);
    80004a4c:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a50:	018a2583          	lw	a1,24(s4)
    80004a54:	012585bb          	addw	a1,a1,s2
    80004a58:	2585                	addiw	a1,a1,1
    80004a5a:	028a2503          	lw	a0,40(s4)
    80004a5e:	fffff097          	auipc	ra,0xfffff
    80004a62:	cae080e7          	jalr	-850(ra) # 8000370c <bread>
    80004a66:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a68:	000aa583          	lw	a1,0(s5)
    80004a6c:	028a2503          	lw	a0,40(s4)
    80004a70:	fffff097          	auipc	ra,0xfffff
    80004a74:	c9c080e7          	jalr	-868(ra) # 8000370c <bread>
    80004a78:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a7a:	865a                	mv	a2,s6
    80004a7c:	05850593          	addi	a1,a0,88
    80004a80:	05848513          	addi	a0,s1,88
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	316080e7          	jalr	790(ra) # 80000d9a <memmove>
    bwrite(to);  // write the log
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	fffff097          	auipc	ra,0xfffff
    80004a92:	d70080e7          	jalr	-656(ra) # 800037fe <bwrite>
    brelse(from);
    80004a96:	854e                	mv	a0,s3
    80004a98:	fffff097          	auipc	ra,0xfffff
    80004a9c:	da4080e7          	jalr	-604(ra) # 8000383c <brelse>
    brelse(to);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	fffff097          	auipc	ra,0xfffff
    80004aa6:	d9a080e7          	jalr	-614(ra) # 8000383c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aaa:	2905                	addiw	s2,s2,1
    80004aac:	0a91                	addi	s5,s5,4
    80004aae:	02ca2783          	lw	a5,44(s4)
    80004ab2:	f8f94fe3          	blt	s2,a5,80004a50 <end_op+0xd2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ab6:	00000097          	auipc	ra,0x0
    80004aba:	c82080e7          	jalr	-894(ra) # 80004738 <write_head>
    install_trans(0); // Now install writes to home locations
    80004abe:	4501                	li	a0,0
    80004ac0:	00000097          	auipc	ra,0x0
    80004ac4:	ce2080e7          	jalr	-798(ra) # 800047a2 <install_trans>
    log.lh.n = 0;
    80004ac8:	00024797          	auipc	a5,0x24
    80004acc:	2a07aa23          	sw	zero,692(a5) # 80028d7c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ad0:	00000097          	auipc	ra,0x0
    80004ad4:	c68080e7          	jalr	-920(ra) # 80004738 <write_head>
    80004ad8:	69e2                	ld	s3,24(sp)
    80004ada:	6a42                	ld	s4,16(sp)
    80004adc:	6aa2                	ld	s5,8(sp)
    80004ade:	6b02                	ld	s6,0(sp)
    80004ae0:	b5e5                	j	800049c8 <end_op+0x4a>

0000000080004ae2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ae2:	1101                	addi	sp,sp,-32
    80004ae4:	ec06                	sd	ra,24(sp)
    80004ae6:	e822                	sd	s0,16(sp)
    80004ae8:	e426                	sd	s1,8(sp)
    80004aea:	e04a                	sd	s2,0(sp)
    80004aec:	1000                	addi	s0,sp,32
    80004aee:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004af0:	00024917          	auipc	s2,0x24
    80004af4:	26090913          	addi	s2,s2,608 # 80028d50 <log>
    80004af8:	854a                	mv	a0,s2
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	144080e7          	jalr	324(ra) # 80000c3e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b02:	02c92603          	lw	a2,44(s2)
    80004b06:	47f5                	li	a5,29
    80004b08:	06c7c563          	blt	a5,a2,80004b72 <log_write+0x90>
    80004b0c:	00024797          	auipc	a5,0x24
    80004b10:	2607a783          	lw	a5,608(a5) # 80028d6c <log+0x1c>
    80004b14:	37fd                	addiw	a5,a5,-1
    80004b16:	04f65e63          	bge	a2,a5,80004b72 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b1a:	00024797          	auipc	a5,0x24
    80004b1e:	2567a783          	lw	a5,598(a5) # 80028d70 <log+0x20>
    80004b22:	06f05063          	blez	a5,80004b82 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b26:	4781                	li	a5,0
    80004b28:	06c05563          	blez	a2,80004b92 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b2c:	44cc                	lw	a1,12(s1)
    80004b2e:	00024717          	auipc	a4,0x24
    80004b32:	25270713          	addi	a4,a4,594 # 80028d80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b36:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b38:	4314                	lw	a3,0(a4)
    80004b3a:	04b68c63          	beq	a3,a1,80004b92 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b3e:	2785                	addiw	a5,a5,1
    80004b40:	0711                	addi	a4,a4,4
    80004b42:	fef61be3          	bne	a2,a5,80004b38 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b46:	0621                	addi	a2,a2,8
    80004b48:	060a                	slli	a2,a2,0x2
    80004b4a:	00024797          	auipc	a5,0x24
    80004b4e:	20678793          	addi	a5,a5,518 # 80028d50 <log>
    80004b52:	97b2                	add	a5,a5,a2
    80004b54:	44d8                	lw	a4,12(s1)
    80004b56:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	fffff097          	auipc	ra,0xfffff
    80004b5e:	d7a080e7          	jalr	-646(ra) # 800038d4 <bpin>
    log.lh.n++;
    80004b62:	00024717          	auipc	a4,0x24
    80004b66:	1ee70713          	addi	a4,a4,494 # 80028d50 <log>
    80004b6a:	575c                	lw	a5,44(a4)
    80004b6c:	2785                	addiw	a5,a5,1
    80004b6e:	d75c                	sw	a5,44(a4)
    80004b70:	a82d                	j	80004baa <log_write+0xc8>
    panic("too big a transaction");
    80004b72:	00004517          	auipc	a0,0x4
    80004b76:	9be50513          	addi	a0,a0,-1602 # 80008530 <etext+0x530>
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	9e6080e7          	jalr	-1562(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004b82:	00004517          	auipc	a0,0x4
    80004b86:	9c650513          	addi	a0,a0,-1594 # 80008548 <etext+0x548>
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	9d6080e7          	jalr	-1578(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004b92:	00878693          	addi	a3,a5,8
    80004b96:	068a                	slli	a3,a3,0x2
    80004b98:	00024717          	auipc	a4,0x24
    80004b9c:	1b870713          	addi	a4,a4,440 # 80028d50 <log>
    80004ba0:	9736                	add	a4,a4,a3
    80004ba2:	44d4                	lw	a3,12(s1)
    80004ba4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004ba6:	faf609e3          	beq	a2,a5,80004b58 <log_write+0x76>
  }
  release(&log.lock);
    80004baa:	00024517          	auipc	a0,0x24
    80004bae:	1a650513          	addi	a0,a0,422 # 80028d50 <log>
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	13c080e7          	jalr	316(ra) # 80000cee <release>
}
    80004bba:	60e2                	ld	ra,24(sp)
    80004bbc:	6442                	ld	s0,16(sp)
    80004bbe:	64a2                	ld	s1,8(sp)
    80004bc0:	6902                	ld	s2,0(sp)
    80004bc2:	6105                	addi	sp,sp,32
    80004bc4:	8082                	ret

0000000080004bc6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bc6:	1101                	addi	sp,sp,-32
    80004bc8:	ec06                	sd	ra,24(sp)
    80004bca:	e822                	sd	s0,16(sp)
    80004bcc:	e426                	sd	s1,8(sp)
    80004bce:	e04a                	sd	s2,0(sp)
    80004bd0:	1000                	addi	s0,sp,32
    80004bd2:	84aa                	mv	s1,a0
    80004bd4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004bd6:	00004597          	auipc	a1,0x4
    80004bda:	99258593          	addi	a1,a1,-1646 # 80008568 <etext+0x568>
    80004bde:	0521                	addi	a0,a0,8
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	fca080e7          	jalr	-54(ra) # 80000baa <initlock>
  lk->name = name;
    80004be8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004bec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bf0:	0204a423          	sw	zero,40(s1)
}
    80004bf4:	60e2                	ld	ra,24(sp)
    80004bf6:	6442                	ld	s0,16(sp)
    80004bf8:	64a2                	ld	s1,8(sp)
    80004bfa:	6902                	ld	s2,0(sp)
    80004bfc:	6105                	addi	sp,sp,32
    80004bfe:	8082                	ret

0000000080004c00 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c00:	1101                	addi	sp,sp,-32
    80004c02:	ec06                	sd	ra,24(sp)
    80004c04:	e822                	sd	s0,16(sp)
    80004c06:	e426                	sd	s1,8(sp)
    80004c08:	e04a                	sd	s2,0(sp)
    80004c0a:	1000                	addi	s0,sp,32
    80004c0c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c0e:	00850913          	addi	s2,a0,8
    80004c12:	854a                	mv	a0,s2
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	02a080e7          	jalr	42(ra) # 80000c3e <acquire>
  while (lk->locked) {
    80004c1c:	409c                	lw	a5,0(s1)
    80004c1e:	cb89                	beqz	a5,80004c30 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c20:	85ca                	mv	a1,s2
    80004c22:	8526                	mv	a0,s1
    80004c24:	ffffe097          	auipc	ra,0xffffe
    80004c28:	8fe080e7          	jalr	-1794(ra) # 80002522 <sleep>
  while (lk->locked) {
    80004c2c:	409c                	lw	a5,0(s1)
    80004c2e:	fbed                	bnez	a5,80004c20 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c30:	4785                	li	a5,1
    80004c32:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c34:	ffffd097          	auipc	ra,0xffffd
    80004c38:	e7c080e7          	jalr	-388(ra) # 80001ab0 <myproc>
    80004c3c:	591c                	lw	a5,48(a0)
    80004c3e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c40:	854a                	mv	a0,s2
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	0ac080e7          	jalr	172(ra) # 80000cee <release>
}
    80004c4a:	60e2                	ld	ra,24(sp)
    80004c4c:	6442                	ld	s0,16(sp)
    80004c4e:	64a2                	ld	s1,8(sp)
    80004c50:	6902                	ld	s2,0(sp)
    80004c52:	6105                	addi	sp,sp,32
    80004c54:	8082                	ret

0000000080004c56 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c56:	1101                	addi	sp,sp,-32
    80004c58:	ec06                	sd	ra,24(sp)
    80004c5a:	e822                	sd	s0,16(sp)
    80004c5c:	e426                	sd	s1,8(sp)
    80004c5e:	e04a                	sd	s2,0(sp)
    80004c60:	1000                	addi	s0,sp,32
    80004c62:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c64:	00850913          	addi	s2,a0,8
    80004c68:	854a                	mv	a0,s2
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	fd4080e7          	jalr	-44(ra) # 80000c3e <acquire>
  lk->locked = 0;
    80004c72:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c76:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffe097          	auipc	ra,0xffffe
    80004c80:	90a080e7          	jalr	-1782(ra) # 80002586 <wakeup>
  release(&lk->lk);
    80004c84:	854a                	mv	a0,s2
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	068080e7          	jalr	104(ra) # 80000cee <release>
}
    80004c8e:	60e2                	ld	ra,24(sp)
    80004c90:	6442                	ld	s0,16(sp)
    80004c92:	64a2                	ld	s1,8(sp)
    80004c94:	6902                	ld	s2,0(sp)
    80004c96:	6105                	addi	sp,sp,32
    80004c98:	8082                	ret

0000000080004c9a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c9a:	7179                	addi	sp,sp,-48
    80004c9c:	f406                	sd	ra,40(sp)
    80004c9e:	f022                	sd	s0,32(sp)
    80004ca0:	ec26                	sd	s1,24(sp)
    80004ca2:	e84a                	sd	s2,16(sp)
    80004ca4:	1800                	addi	s0,sp,48
    80004ca6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004ca8:	00850913          	addi	s2,a0,8
    80004cac:	854a                	mv	a0,s2
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	f90080e7          	jalr	-112(ra) # 80000c3e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cb6:	409c                	lw	a5,0(s1)
    80004cb8:	ef91                	bnez	a5,80004cd4 <holdingsleep+0x3a>
    80004cba:	4481                	li	s1,0
  release(&lk->lk);
    80004cbc:	854a                	mv	a0,s2
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	030080e7          	jalr	48(ra) # 80000cee <release>
  return r;
}
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	70a2                	ld	ra,40(sp)
    80004cca:	7402                	ld	s0,32(sp)
    80004ccc:	64e2                	ld	s1,24(sp)
    80004cce:	6942                	ld	s2,16(sp)
    80004cd0:	6145                	addi	sp,sp,48
    80004cd2:	8082                	ret
    80004cd4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cd6:	0284a983          	lw	s3,40(s1)
    80004cda:	ffffd097          	auipc	ra,0xffffd
    80004cde:	dd6080e7          	jalr	-554(ra) # 80001ab0 <myproc>
    80004ce2:	5904                	lw	s1,48(a0)
    80004ce4:	413484b3          	sub	s1,s1,s3
    80004ce8:	0014b493          	seqz	s1,s1
    80004cec:	69a2                	ld	s3,8(sp)
    80004cee:	b7f9                	j	80004cbc <holdingsleep+0x22>

0000000080004cf0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004cf0:	1141                	addi	sp,sp,-16
    80004cf2:	e406                	sd	ra,8(sp)
    80004cf4:	e022                	sd	s0,0(sp)
    80004cf6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004cf8:	00004597          	auipc	a1,0x4
    80004cfc:	88058593          	addi	a1,a1,-1920 # 80008578 <etext+0x578>
    80004d00:	00024517          	auipc	a0,0x24
    80004d04:	19850513          	addi	a0,a0,408 # 80028e98 <ftable>
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	ea2080e7          	jalr	-350(ra) # 80000baa <initlock>
}
    80004d10:	60a2                	ld	ra,8(sp)
    80004d12:	6402                	ld	s0,0(sp)
    80004d14:	0141                	addi	sp,sp,16
    80004d16:	8082                	ret

0000000080004d18 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d18:	1101                	addi	sp,sp,-32
    80004d1a:	ec06                	sd	ra,24(sp)
    80004d1c:	e822                	sd	s0,16(sp)
    80004d1e:	e426                	sd	s1,8(sp)
    80004d20:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d22:	00024517          	auipc	a0,0x24
    80004d26:	17650513          	addi	a0,a0,374 # 80028e98 <ftable>
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	f14080e7          	jalr	-236(ra) # 80000c3e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d32:	00024497          	auipc	s1,0x24
    80004d36:	17e48493          	addi	s1,s1,382 # 80028eb0 <ftable+0x18>
    80004d3a:	00025717          	auipc	a4,0x25
    80004d3e:	11670713          	addi	a4,a4,278 # 80029e50 <disk>
    if(f->ref == 0){
    80004d42:	40dc                	lw	a5,4(s1)
    80004d44:	cf99                	beqz	a5,80004d62 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d46:	02848493          	addi	s1,s1,40
    80004d4a:	fee49ce3          	bne	s1,a4,80004d42 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d4e:	00024517          	auipc	a0,0x24
    80004d52:	14a50513          	addi	a0,a0,330 # 80028e98 <ftable>
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	f98080e7          	jalr	-104(ra) # 80000cee <release>
  return 0;
    80004d5e:	4481                	li	s1,0
    80004d60:	a819                	j	80004d76 <filealloc+0x5e>
      f->ref = 1;
    80004d62:	4785                	li	a5,1
    80004d64:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d66:	00024517          	auipc	a0,0x24
    80004d6a:	13250513          	addi	a0,a0,306 # 80028e98 <ftable>
    80004d6e:	ffffc097          	auipc	ra,0xffffc
    80004d72:	f80080e7          	jalr	-128(ra) # 80000cee <release>
}
    80004d76:	8526                	mv	a0,s1
    80004d78:	60e2                	ld	ra,24(sp)
    80004d7a:	6442                	ld	s0,16(sp)
    80004d7c:	64a2                	ld	s1,8(sp)
    80004d7e:	6105                	addi	sp,sp,32
    80004d80:	8082                	ret

0000000080004d82 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d82:	1101                	addi	sp,sp,-32
    80004d84:	ec06                	sd	ra,24(sp)
    80004d86:	e822                	sd	s0,16(sp)
    80004d88:	e426                	sd	s1,8(sp)
    80004d8a:	1000                	addi	s0,sp,32
    80004d8c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d8e:	00024517          	auipc	a0,0x24
    80004d92:	10a50513          	addi	a0,a0,266 # 80028e98 <ftable>
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	ea8080e7          	jalr	-344(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004d9e:	40dc                	lw	a5,4(s1)
    80004da0:	02f05263          	blez	a5,80004dc4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004da4:	2785                	addiw	a5,a5,1
    80004da6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004da8:	00024517          	auipc	a0,0x24
    80004dac:	0f050513          	addi	a0,a0,240 # 80028e98 <ftable>
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	f3e080e7          	jalr	-194(ra) # 80000cee <release>
  return f;
}
    80004db8:	8526                	mv	a0,s1
    80004dba:	60e2                	ld	ra,24(sp)
    80004dbc:	6442                	ld	s0,16(sp)
    80004dbe:	64a2                	ld	s1,8(sp)
    80004dc0:	6105                	addi	sp,sp,32
    80004dc2:	8082                	ret
    panic("filedup");
    80004dc4:	00003517          	auipc	a0,0x3
    80004dc8:	7bc50513          	addi	a0,a0,1980 # 80008580 <etext+0x580>
    80004dcc:	ffffb097          	auipc	ra,0xffffb
    80004dd0:	794080e7          	jalr	1940(ra) # 80000560 <panic>

0000000080004dd4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004dd4:	7139                	addi	sp,sp,-64
    80004dd6:	fc06                	sd	ra,56(sp)
    80004dd8:	f822                	sd	s0,48(sp)
    80004dda:	f426                	sd	s1,40(sp)
    80004ddc:	0080                	addi	s0,sp,64
    80004dde:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004de0:	00024517          	auipc	a0,0x24
    80004de4:	0b850513          	addi	a0,a0,184 # 80028e98 <ftable>
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	e56080e7          	jalr	-426(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004df0:	40dc                	lw	a5,4(s1)
    80004df2:	04f05a63          	blez	a5,80004e46 <fileclose+0x72>
    panic("fileclose");
  if(--f->ref > 0){
    80004df6:	37fd                	addiw	a5,a5,-1
    80004df8:	c0dc                	sw	a5,4(s1)
    80004dfa:	06f04263          	bgtz	a5,80004e5e <fileclose+0x8a>
    80004dfe:	f04a                	sd	s2,32(sp)
    80004e00:	ec4e                	sd	s3,24(sp)
    80004e02:	e852                	sd	s4,16(sp)
    80004e04:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e06:	0004a903          	lw	s2,0(s1)
    80004e0a:	0094ca83          	lbu	s5,9(s1)
    80004e0e:	0104ba03          	ld	s4,16(s1)
    80004e12:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e16:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e1a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e1e:	00024517          	auipc	a0,0x24
    80004e22:	07a50513          	addi	a0,a0,122 # 80028e98 <ftable>
    80004e26:	ffffc097          	auipc	ra,0xffffc
    80004e2a:	ec8080e7          	jalr	-312(ra) # 80000cee <release>

  if(ff.type == FD_PIPE){
    80004e2e:	4785                	li	a5,1
    80004e30:	04f90463          	beq	s2,a5,80004e78 <fileclose+0xa4>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e34:	3979                	addiw	s2,s2,-2
    80004e36:	4785                	li	a5,1
    80004e38:	0527fb63          	bgeu	a5,s2,80004e8e <fileclose+0xba>
    80004e3c:	7902                	ld	s2,32(sp)
    80004e3e:	69e2                	ld	s3,24(sp)
    80004e40:	6a42                	ld	s4,16(sp)
    80004e42:	6aa2                	ld	s5,8(sp)
    80004e44:	a02d                	j	80004e6e <fileclose+0x9a>
    80004e46:	f04a                	sd	s2,32(sp)
    80004e48:	ec4e                	sd	s3,24(sp)
    80004e4a:	e852                	sd	s4,16(sp)
    80004e4c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004e4e:	00003517          	auipc	a0,0x3
    80004e52:	73a50513          	addi	a0,a0,1850 # 80008588 <etext+0x588>
    80004e56:	ffffb097          	auipc	ra,0xffffb
    80004e5a:	70a080e7          	jalr	1802(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004e5e:	00024517          	auipc	a0,0x24
    80004e62:	03a50513          	addi	a0,a0,58 # 80028e98 <ftable>
    80004e66:	ffffc097          	auipc	ra,0xffffc
    80004e6a:	e88080e7          	jalr	-376(ra) # 80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004e6e:	70e2                	ld	ra,56(sp)
    80004e70:	7442                	ld	s0,48(sp)
    80004e72:	74a2                	ld	s1,40(sp)
    80004e74:	6121                	addi	sp,sp,64
    80004e76:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e78:	85d6                	mv	a1,s5
    80004e7a:	8552                	mv	a0,s4
    80004e7c:	00000097          	auipc	ra,0x0
    80004e80:	3ac080e7          	jalr	940(ra) # 80005228 <pipeclose>
    80004e84:	7902                	ld	s2,32(sp)
    80004e86:	69e2                	ld	s3,24(sp)
    80004e88:	6a42                	ld	s4,16(sp)
    80004e8a:	6aa2                	ld	s5,8(sp)
    80004e8c:	b7cd                	j	80004e6e <fileclose+0x9a>
    begin_op();
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	a76080e7          	jalr	-1418(ra) # 80004904 <begin_op>
    iput(ff.ip);
    80004e96:	854e                	mv	a0,s3
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	240080e7          	jalr	576(ra) # 800040d8 <iput>
    end_op();
    80004ea0:	00000097          	auipc	ra,0x0
    80004ea4:	ade080e7          	jalr	-1314(ra) # 8000497e <end_op>
    80004ea8:	7902                	ld	s2,32(sp)
    80004eaa:	69e2                	ld	s3,24(sp)
    80004eac:	6a42                	ld	s4,16(sp)
    80004eae:	6aa2                	ld	s5,8(sp)
    80004eb0:	bf7d                	j	80004e6e <fileclose+0x9a>

0000000080004eb2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004eb2:	715d                	addi	sp,sp,-80
    80004eb4:	e486                	sd	ra,72(sp)
    80004eb6:	e0a2                	sd	s0,64(sp)
    80004eb8:	fc26                	sd	s1,56(sp)
    80004eba:	f44e                	sd	s3,40(sp)
    80004ebc:	0880                	addi	s0,sp,80
    80004ebe:	84aa                	mv	s1,a0
    80004ec0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	bee080e7          	jalr	-1042(ra) # 80001ab0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004eca:	409c                	lw	a5,0(s1)
    80004ecc:	37f9                	addiw	a5,a5,-2
    80004ece:	4705                	li	a4,1
    80004ed0:	04f76a63          	bltu	a4,a5,80004f24 <filestat+0x72>
    80004ed4:	f84a                	sd	s2,48(sp)
    80004ed6:	f052                	sd	s4,32(sp)
    80004ed8:	892a                	mv	s2,a0
    ilock(f->ip);
    80004eda:	6c88                	ld	a0,24(s1)
    80004edc:	fffff097          	auipc	ra,0xfffff
    80004ee0:	03e080e7          	jalr	62(ra) # 80003f1a <ilock>
    stati(f->ip, &st);
    80004ee4:	fb840a13          	addi	s4,s0,-72
    80004ee8:	85d2                	mv	a1,s4
    80004eea:	6c88                	ld	a0,24(s1)
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	2bc080e7          	jalr	700(ra) # 800041a8 <stati>
    iunlock(f->ip);
    80004ef4:	6c88                	ld	a0,24(s1)
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	0ea080e7          	jalr	234(ra) # 80003fe0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004efe:	46e1                	li	a3,24
    80004f00:	8652                	mv	a2,s4
    80004f02:	85ce                	mv	a1,s3
    80004f04:	22893503          	ld	a0,552(s2)
    80004f08:	ffffd097          	auipc	ra,0xffffd
    80004f0c:	808080e7          	jalr	-2040(ra) # 80001710 <copyout>
    80004f10:	41f5551b          	sraiw	a0,a0,0x1f
    80004f14:	7942                	ld	s2,48(sp)
    80004f16:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004f18:	60a6                	ld	ra,72(sp)
    80004f1a:	6406                	ld	s0,64(sp)
    80004f1c:	74e2                	ld	s1,56(sp)
    80004f1e:	79a2                	ld	s3,40(sp)
    80004f20:	6161                	addi	sp,sp,80
    80004f22:	8082                	ret
  return -1;
    80004f24:	557d                	li	a0,-1
    80004f26:	bfcd                	j	80004f18 <filestat+0x66>

0000000080004f28 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f28:	7179                	addi	sp,sp,-48
    80004f2a:	f406                	sd	ra,40(sp)
    80004f2c:	f022                	sd	s0,32(sp)
    80004f2e:	e84a                	sd	s2,16(sp)
    80004f30:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f32:	00854783          	lbu	a5,8(a0)
    80004f36:	cbc5                	beqz	a5,80004fe6 <fileread+0xbe>
    80004f38:	ec26                	sd	s1,24(sp)
    80004f3a:	e44e                	sd	s3,8(sp)
    80004f3c:	84aa                	mv	s1,a0
    80004f3e:	89ae                	mv	s3,a1
    80004f40:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f42:	411c                	lw	a5,0(a0)
    80004f44:	4705                	li	a4,1
    80004f46:	04e78963          	beq	a5,a4,80004f98 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f4a:	470d                	li	a4,3
    80004f4c:	04e78f63          	beq	a5,a4,80004faa <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f50:	4709                	li	a4,2
    80004f52:	08e79263          	bne	a5,a4,80004fd6 <fileread+0xae>
    ilock(f->ip);
    80004f56:	6d08                	ld	a0,24(a0)
    80004f58:	fffff097          	auipc	ra,0xfffff
    80004f5c:	fc2080e7          	jalr	-62(ra) # 80003f1a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f60:	874a                	mv	a4,s2
    80004f62:	5094                	lw	a3,32(s1)
    80004f64:	864e                	mv	a2,s3
    80004f66:	4585                	li	a1,1
    80004f68:	6c88                	ld	a0,24(s1)
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	26c080e7          	jalr	620(ra) # 800041d6 <readi>
    80004f72:	892a                	mv	s2,a0
    80004f74:	00a05563          	blez	a0,80004f7e <fileread+0x56>
      f->off += r;
    80004f78:	509c                	lw	a5,32(s1)
    80004f7a:	9fa9                	addw	a5,a5,a0
    80004f7c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f7e:	6c88                	ld	a0,24(s1)
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	060080e7          	jalr	96(ra) # 80003fe0 <iunlock>
    80004f88:	64e2                	ld	s1,24(sp)
    80004f8a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004f8c:	854a                	mv	a0,s2
    80004f8e:	70a2                	ld	ra,40(sp)
    80004f90:	7402                	ld	s0,32(sp)
    80004f92:	6942                	ld	s2,16(sp)
    80004f94:	6145                	addi	sp,sp,48
    80004f96:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f98:	6908                	ld	a0,16(a0)
    80004f9a:	00000097          	auipc	ra,0x0
    80004f9e:	41a080e7          	jalr	1050(ra) # 800053b4 <piperead>
    80004fa2:	892a                	mv	s2,a0
    80004fa4:	64e2                	ld	s1,24(sp)
    80004fa6:	69a2                	ld	s3,8(sp)
    80004fa8:	b7d5                	j	80004f8c <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004faa:	02451783          	lh	a5,36(a0)
    80004fae:	03079693          	slli	a3,a5,0x30
    80004fb2:	92c1                	srli	a3,a3,0x30
    80004fb4:	4725                	li	a4,9
    80004fb6:	02d76a63          	bltu	a4,a3,80004fea <fileread+0xc2>
    80004fba:	0792                	slli	a5,a5,0x4
    80004fbc:	00024717          	auipc	a4,0x24
    80004fc0:	e3c70713          	addi	a4,a4,-452 # 80028df8 <devsw>
    80004fc4:	97ba                	add	a5,a5,a4
    80004fc6:	639c                	ld	a5,0(a5)
    80004fc8:	c78d                	beqz	a5,80004ff2 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004fca:	4505                	li	a0,1
    80004fcc:	9782                	jalr	a5
    80004fce:	892a                	mv	s2,a0
    80004fd0:	64e2                	ld	s1,24(sp)
    80004fd2:	69a2                	ld	s3,8(sp)
    80004fd4:	bf65                	j	80004f8c <fileread+0x64>
    panic("fileread");
    80004fd6:	00003517          	auipc	a0,0x3
    80004fda:	5c250513          	addi	a0,a0,1474 # 80008598 <etext+0x598>
    80004fde:	ffffb097          	auipc	ra,0xffffb
    80004fe2:	582080e7          	jalr	1410(ra) # 80000560 <panic>
    return -1;
    80004fe6:	597d                	li	s2,-1
    80004fe8:	b755                	j	80004f8c <fileread+0x64>
      return -1;
    80004fea:	597d                	li	s2,-1
    80004fec:	64e2                	ld	s1,24(sp)
    80004fee:	69a2                	ld	s3,8(sp)
    80004ff0:	bf71                	j	80004f8c <fileread+0x64>
    80004ff2:	597d                	li	s2,-1
    80004ff4:	64e2                	ld	s1,24(sp)
    80004ff6:	69a2                	ld	s3,8(sp)
    80004ff8:	bf51                	j	80004f8c <fileread+0x64>

0000000080004ffa <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ffa:	00954783          	lbu	a5,9(a0)
    80004ffe:	12078c63          	beqz	a5,80005136 <filewrite+0x13c>
{
    80005002:	711d                	addi	sp,sp,-96
    80005004:	ec86                	sd	ra,88(sp)
    80005006:	e8a2                	sd	s0,80(sp)
    80005008:	e0ca                	sd	s2,64(sp)
    8000500a:	f456                	sd	s5,40(sp)
    8000500c:	f05a                	sd	s6,32(sp)
    8000500e:	1080                	addi	s0,sp,96
    80005010:	892a                	mv	s2,a0
    80005012:	8b2e                	mv	s6,a1
    80005014:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80005016:	411c                	lw	a5,0(a0)
    80005018:	4705                	li	a4,1
    8000501a:	02e78963          	beq	a5,a4,8000504c <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000501e:	470d                	li	a4,3
    80005020:	02e78c63          	beq	a5,a4,80005058 <filewrite+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005024:	4709                	li	a4,2
    80005026:	0ee79a63          	bne	a5,a4,8000511a <filewrite+0x120>
    8000502a:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000502c:	0cc05563          	blez	a2,800050f6 <filewrite+0xfc>
    80005030:	e4a6                	sd	s1,72(sp)
    80005032:	fc4e                	sd	s3,56(sp)
    80005034:	ec5e                	sd	s7,24(sp)
    80005036:	e862                	sd	s8,16(sp)
    80005038:	e466                	sd	s9,8(sp)
    int i = 0;
    8000503a:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000503c:	6b85                	lui	s7,0x1
    8000503e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005042:	6c85                	lui	s9,0x1
    80005044:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005048:	4c05                	li	s8,1
    8000504a:	a849                	j	800050dc <filewrite+0xe2>
    ret = pipewrite(f->pipe, addr, n);
    8000504c:	6908                	ld	a0,16(a0)
    8000504e:	00000097          	auipc	ra,0x0
    80005052:	24a080e7          	jalr	586(ra) # 80005298 <pipewrite>
    80005056:	a85d                	j	8000510c <filewrite+0x112>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005058:	02451783          	lh	a5,36(a0)
    8000505c:	03079693          	slli	a3,a5,0x30
    80005060:	92c1                	srli	a3,a3,0x30
    80005062:	4725                	li	a4,9
    80005064:	0cd76b63          	bltu	a4,a3,8000513a <filewrite+0x140>
    80005068:	0792                	slli	a5,a5,0x4
    8000506a:	00024717          	auipc	a4,0x24
    8000506e:	d8e70713          	addi	a4,a4,-626 # 80028df8 <devsw>
    80005072:	97ba                	add	a5,a5,a4
    80005074:	679c                	ld	a5,8(a5)
    80005076:	c7e1                	beqz	a5,8000513e <filewrite+0x144>
    ret = devsw[f->major].write(1, addr, n);
    80005078:	4505                	li	a0,1
    8000507a:	9782                	jalr	a5
    8000507c:	a841                	j	8000510c <filewrite+0x112>
      if(n1 > max)
    8000507e:	2981                	sext.w	s3,s3
      begin_op();
    80005080:	00000097          	auipc	ra,0x0
    80005084:	884080e7          	jalr	-1916(ra) # 80004904 <begin_op>
      ilock(f->ip);
    80005088:	01893503          	ld	a0,24(s2)
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	e8e080e7          	jalr	-370(ra) # 80003f1a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005094:	874e                	mv	a4,s3
    80005096:	02092683          	lw	a3,32(s2)
    8000509a:	016a0633          	add	a2,s4,s6
    8000509e:	85e2                	mv	a1,s8
    800050a0:	01893503          	ld	a0,24(s2)
    800050a4:	fffff097          	auipc	ra,0xfffff
    800050a8:	238080e7          	jalr	568(ra) # 800042dc <writei>
    800050ac:	84aa                	mv	s1,a0
    800050ae:	00a05763          	blez	a0,800050bc <filewrite+0xc2>
        f->off += r;
    800050b2:	02092783          	lw	a5,32(s2)
    800050b6:	9fa9                	addw	a5,a5,a0
    800050b8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800050bc:	01893503          	ld	a0,24(s2)
    800050c0:	fffff097          	auipc	ra,0xfffff
    800050c4:	f20080e7          	jalr	-224(ra) # 80003fe0 <iunlock>
      end_op();
    800050c8:	00000097          	auipc	ra,0x0
    800050cc:	8b6080e7          	jalr	-1866(ra) # 8000497e <end_op>

      if(r != n1){
    800050d0:	02999563          	bne	s3,s1,800050fa <filewrite+0x100>
        // error from writei
        break;
      }
      i += r;
    800050d4:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800050d8:	015a5963          	bge	s4,s5,800050ea <filewrite+0xf0>
      int n1 = n - i;
    800050dc:	414a87bb          	subw	a5,s5,s4
    800050e0:	89be                	mv	s3,a5
      if(n1 > max)
    800050e2:	f8fbdee3          	bge	s7,a5,8000507e <filewrite+0x84>
    800050e6:	89e6                	mv	s3,s9
    800050e8:	bf59                	j	8000507e <filewrite+0x84>
    800050ea:	64a6                	ld	s1,72(sp)
    800050ec:	79e2                	ld	s3,56(sp)
    800050ee:	6be2                	ld	s7,24(sp)
    800050f0:	6c42                	ld	s8,16(sp)
    800050f2:	6ca2                	ld	s9,8(sp)
    800050f4:	a801                	j	80005104 <filewrite+0x10a>
    int i = 0;
    800050f6:	4a01                	li	s4,0
    800050f8:	a031                	j	80005104 <filewrite+0x10a>
    800050fa:	64a6                	ld	s1,72(sp)
    800050fc:	79e2                	ld	s3,56(sp)
    800050fe:	6be2                	ld	s7,24(sp)
    80005100:	6c42                	ld	s8,16(sp)
    80005102:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80005104:	034a9f63          	bne	s5,s4,80005142 <filewrite+0x148>
    80005108:	8556                	mv	a0,s5
    8000510a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000510c:	60e6                	ld	ra,88(sp)
    8000510e:	6446                	ld	s0,80(sp)
    80005110:	6906                	ld	s2,64(sp)
    80005112:	7aa2                	ld	s5,40(sp)
    80005114:	7b02                	ld	s6,32(sp)
    80005116:	6125                	addi	sp,sp,96
    80005118:	8082                	ret
    8000511a:	e4a6                	sd	s1,72(sp)
    8000511c:	fc4e                	sd	s3,56(sp)
    8000511e:	f852                	sd	s4,48(sp)
    80005120:	ec5e                	sd	s7,24(sp)
    80005122:	e862                	sd	s8,16(sp)
    80005124:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80005126:	00003517          	auipc	a0,0x3
    8000512a:	48250513          	addi	a0,a0,1154 # 800085a8 <etext+0x5a8>
    8000512e:	ffffb097          	auipc	ra,0xffffb
    80005132:	432080e7          	jalr	1074(ra) # 80000560 <panic>
    return -1;
    80005136:	557d                	li	a0,-1
}
    80005138:	8082                	ret
      return -1;
    8000513a:	557d                	li	a0,-1
    8000513c:	bfc1                	j	8000510c <filewrite+0x112>
    8000513e:	557d                	li	a0,-1
    80005140:	b7f1                	j	8000510c <filewrite+0x112>
    ret = (i == n ? n : -1);
    80005142:	557d                	li	a0,-1
    80005144:	7a42                	ld	s4,48(sp)
    80005146:	b7d9                	j	8000510c <filewrite+0x112>

0000000080005148 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005148:	7179                	addi	sp,sp,-48
    8000514a:	f406                	sd	ra,40(sp)
    8000514c:	f022                	sd	s0,32(sp)
    8000514e:	ec26                	sd	s1,24(sp)
    80005150:	e052                	sd	s4,0(sp)
    80005152:	1800                	addi	s0,sp,48
    80005154:	84aa                	mv	s1,a0
    80005156:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005158:	0005b023          	sd	zero,0(a1)
    8000515c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005160:	00000097          	auipc	ra,0x0
    80005164:	bb8080e7          	jalr	-1096(ra) # 80004d18 <filealloc>
    80005168:	e088                	sd	a0,0(s1)
    8000516a:	cd49                	beqz	a0,80005204 <pipealloc+0xbc>
    8000516c:	00000097          	auipc	ra,0x0
    80005170:	bac080e7          	jalr	-1108(ra) # 80004d18 <filealloc>
    80005174:	00aa3023          	sd	a0,0(s4)
    80005178:	c141                	beqz	a0,800051f8 <pipealloc+0xb0>
    8000517a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	9ce080e7          	jalr	-1586(ra) # 80000b4a <kalloc>
    80005184:	892a                	mv	s2,a0
    80005186:	c13d                	beqz	a0,800051ec <pipealloc+0xa4>
    80005188:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000518a:	4985                	li	s3,1
    8000518c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005190:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005194:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005198:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000519c:	00003597          	auipc	a1,0x3
    800051a0:	41c58593          	addi	a1,a1,1052 # 800085b8 <etext+0x5b8>
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	a06080e7          	jalr	-1530(ra) # 80000baa <initlock>
  (*f0)->type = FD_PIPE;
    800051ac:	609c                	ld	a5,0(s1)
    800051ae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051b2:	609c                	ld	a5,0(s1)
    800051b4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051b8:	609c                	ld	a5,0(s1)
    800051ba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051be:	609c                	ld	a5,0(s1)
    800051c0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051c4:	000a3783          	ld	a5,0(s4)
    800051c8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051cc:	000a3783          	ld	a5,0(s4)
    800051d0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051d4:	000a3783          	ld	a5,0(s4)
    800051d8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051dc:	000a3783          	ld	a5,0(s4)
    800051e0:	0127b823          	sd	s2,16(a5)
  return 0;
    800051e4:	4501                	li	a0,0
    800051e6:	6942                	ld	s2,16(sp)
    800051e8:	69a2                	ld	s3,8(sp)
    800051ea:	a03d                	j	80005218 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051ec:	6088                	ld	a0,0(s1)
    800051ee:	c119                	beqz	a0,800051f4 <pipealloc+0xac>
    800051f0:	6942                	ld	s2,16(sp)
    800051f2:	a029                	j	800051fc <pipealloc+0xb4>
    800051f4:	6942                	ld	s2,16(sp)
    800051f6:	a039                	j	80005204 <pipealloc+0xbc>
    800051f8:	6088                	ld	a0,0(s1)
    800051fa:	c50d                	beqz	a0,80005224 <pipealloc+0xdc>
    fileclose(*f0);
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	bd8080e7          	jalr	-1064(ra) # 80004dd4 <fileclose>
  if(*f1)
    80005204:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005208:	557d                	li	a0,-1
  if(*f1)
    8000520a:	c799                	beqz	a5,80005218 <pipealloc+0xd0>
    fileclose(*f1);
    8000520c:	853e                	mv	a0,a5
    8000520e:	00000097          	auipc	ra,0x0
    80005212:	bc6080e7          	jalr	-1082(ra) # 80004dd4 <fileclose>
  return -1;
    80005216:	557d                	li	a0,-1
}
    80005218:	70a2                	ld	ra,40(sp)
    8000521a:	7402                	ld	s0,32(sp)
    8000521c:	64e2                	ld	s1,24(sp)
    8000521e:	6a02                	ld	s4,0(sp)
    80005220:	6145                	addi	sp,sp,48
    80005222:	8082                	ret
  return -1;
    80005224:	557d                	li	a0,-1
    80005226:	bfcd                	j	80005218 <pipealloc+0xd0>

0000000080005228 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005228:	1101                	addi	sp,sp,-32
    8000522a:	ec06                	sd	ra,24(sp)
    8000522c:	e822                	sd	s0,16(sp)
    8000522e:	e426                	sd	s1,8(sp)
    80005230:	e04a                	sd	s2,0(sp)
    80005232:	1000                	addi	s0,sp,32
    80005234:	84aa                	mv	s1,a0
    80005236:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005238:	ffffc097          	auipc	ra,0xffffc
    8000523c:	a06080e7          	jalr	-1530(ra) # 80000c3e <acquire>
  if(writable){
    80005240:	02090d63          	beqz	s2,8000527a <pipeclose+0x52>
    pi->writeopen = 0;
    80005244:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005248:	21848513          	addi	a0,s1,536
    8000524c:	ffffd097          	auipc	ra,0xffffd
    80005250:	33a080e7          	jalr	826(ra) # 80002586 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005254:	2204b783          	ld	a5,544(s1)
    80005258:	eb95                	bnez	a5,8000528c <pipeclose+0x64>
    release(&pi->lock);
    8000525a:	8526                	mv	a0,s1
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	a92080e7          	jalr	-1390(ra) # 80000cee <release>
    kfree((char*)pi);
    80005264:	8526                	mv	a0,s1
    80005266:	ffffb097          	auipc	ra,0xffffb
    8000526a:	7e6080e7          	jalr	2022(ra) # 80000a4c <kfree>
  } else
    release(&pi->lock);
}
    8000526e:	60e2                	ld	ra,24(sp)
    80005270:	6442                	ld	s0,16(sp)
    80005272:	64a2                	ld	s1,8(sp)
    80005274:	6902                	ld	s2,0(sp)
    80005276:	6105                	addi	sp,sp,32
    80005278:	8082                	ret
    pi->readopen = 0;
    8000527a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000527e:	21c48513          	addi	a0,s1,540
    80005282:	ffffd097          	auipc	ra,0xffffd
    80005286:	304080e7          	jalr	772(ra) # 80002586 <wakeup>
    8000528a:	b7e9                	j	80005254 <pipeclose+0x2c>
    release(&pi->lock);
    8000528c:	8526                	mv	a0,s1
    8000528e:	ffffc097          	auipc	ra,0xffffc
    80005292:	a60080e7          	jalr	-1440(ra) # 80000cee <release>
}
    80005296:	bfe1                	j	8000526e <pipeclose+0x46>

0000000080005298 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005298:	7159                	addi	sp,sp,-112
    8000529a:	f486                	sd	ra,104(sp)
    8000529c:	f0a2                	sd	s0,96(sp)
    8000529e:	eca6                	sd	s1,88(sp)
    800052a0:	e8ca                	sd	s2,80(sp)
    800052a2:	e4ce                	sd	s3,72(sp)
    800052a4:	e0d2                	sd	s4,64(sp)
    800052a6:	fc56                	sd	s5,56(sp)
    800052a8:	1880                	addi	s0,sp,112
    800052aa:	84aa                	mv	s1,a0
    800052ac:	8aae                	mv	s5,a1
    800052ae:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052b0:	ffffd097          	auipc	ra,0xffffd
    800052b4:	800080e7          	jalr	-2048(ra) # 80001ab0 <myproc>
    800052b8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052ba:	8526                	mv	a0,s1
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	982080e7          	jalr	-1662(ra) # 80000c3e <acquire>
  while(i < n){
    800052c4:	0f405063          	blez	s4,800053a4 <pipewrite+0x10c>
    800052c8:	f85a                	sd	s6,48(sp)
    800052ca:	f45e                	sd	s7,40(sp)
    800052cc:	f062                	sd	s8,32(sp)
    800052ce:	ec66                	sd	s9,24(sp)
    800052d0:	e86a                	sd	s10,16(sp)
  int i = 0;
    800052d2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052d4:	f9f40c13          	addi	s8,s0,-97
    800052d8:	4b85                	li	s7,1
    800052da:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052dc:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800052e0:	21c48c93          	addi	s9,s1,540
    800052e4:	a099                	j	8000532a <pipewrite+0x92>
      release(&pi->lock);
    800052e6:	8526                	mv	a0,s1
    800052e8:	ffffc097          	auipc	ra,0xffffc
    800052ec:	a06080e7          	jalr	-1530(ra) # 80000cee <release>
      return -1;
    800052f0:	597d                	li	s2,-1
    800052f2:	7b42                	ld	s6,48(sp)
    800052f4:	7ba2                	ld	s7,40(sp)
    800052f6:	7c02                	ld	s8,32(sp)
    800052f8:	6ce2                	ld	s9,24(sp)
    800052fa:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800052fc:	854a                	mv	a0,s2
    800052fe:	70a6                	ld	ra,104(sp)
    80005300:	7406                	ld	s0,96(sp)
    80005302:	64e6                	ld	s1,88(sp)
    80005304:	6946                	ld	s2,80(sp)
    80005306:	69a6                	ld	s3,72(sp)
    80005308:	6a06                	ld	s4,64(sp)
    8000530a:	7ae2                	ld	s5,56(sp)
    8000530c:	6165                	addi	sp,sp,112
    8000530e:	8082                	ret
      wakeup(&pi->nread);
    80005310:	856a                	mv	a0,s10
    80005312:	ffffd097          	auipc	ra,0xffffd
    80005316:	274080e7          	jalr	628(ra) # 80002586 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000531a:	85a6                	mv	a1,s1
    8000531c:	8566                	mv	a0,s9
    8000531e:	ffffd097          	auipc	ra,0xffffd
    80005322:	204080e7          	jalr	516(ra) # 80002522 <sleep>
  while(i < n){
    80005326:	05495e63          	bge	s2,s4,80005382 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    8000532a:	2204a783          	lw	a5,544(s1)
    8000532e:	dfc5                	beqz	a5,800052e6 <pipewrite+0x4e>
    80005330:	854e                	mv	a0,s3
    80005332:	ffffd097          	auipc	ra,0xffffd
    80005336:	4a4080e7          	jalr	1188(ra) # 800027d6 <killed>
    8000533a:	f555                	bnez	a0,800052e6 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000533c:	2184a783          	lw	a5,536(s1)
    80005340:	21c4a703          	lw	a4,540(s1)
    80005344:	2007879b          	addiw	a5,a5,512
    80005348:	fcf704e3          	beq	a4,a5,80005310 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000534c:	86de                	mv	a3,s7
    8000534e:	01590633          	add	a2,s2,s5
    80005352:	85e2                	mv	a1,s8
    80005354:	2289b503          	ld	a0,552(s3)
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	444080e7          	jalr	1092(ra) # 8000179c <copyin>
    80005360:	05650463          	beq	a0,s6,800053a8 <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005364:	21c4a783          	lw	a5,540(s1)
    80005368:	0017871b          	addiw	a4,a5,1
    8000536c:	20e4ae23          	sw	a4,540(s1)
    80005370:	1ff7f793          	andi	a5,a5,511
    80005374:	97a6                	add	a5,a5,s1
    80005376:	f9f44703          	lbu	a4,-97(s0)
    8000537a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000537e:	2905                	addiw	s2,s2,1
    80005380:	b75d                	j	80005326 <pipewrite+0x8e>
    80005382:	7b42                	ld	s6,48(sp)
    80005384:	7ba2                	ld	s7,40(sp)
    80005386:	7c02                	ld	s8,32(sp)
    80005388:	6ce2                	ld	s9,24(sp)
    8000538a:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000538c:	21848513          	addi	a0,s1,536
    80005390:	ffffd097          	auipc	ra,0xffffd
    80005394:	1f6080e7          	jalr	502(ra) # 80002586 <wakeup>
  release(&pi->lock);
    80005398:	8526                	mv	a0,s1
    8000539a:	ffffc097          	auipc	ra,0xffffc
    8000539e:	954080e7          	jalr	-1708(ra) # 80000cee <release>
  return i;
    800053a2:	bfa9                	j	800052fc <pipewrite+0x64>
  int i = 0;
    800053a4:	4901                	li	s2,0
    800053a6:	b7dd                	j	8000538c <pipewrite+0xf4>
    800053a8:	7b42                	ld	s6,48(sp)
    800053aa:	7ba2                	ld	s7,40(sp)
    800053ac:	7c02                	ld	s8,32(sp)
    800053ae:	6ce2                	ld	s9,24(sp)
    800053b0:	6d42                	ld	s10,16(sp)
    800053b2:	bfe9                	j	8000538c <pipewrite+0xf4>

00000000800053b4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053b4:	711d                	addi	sp,sp,-96
    800053b6:	ec86                	sd	ra,88(sp)
    800053b8:	e8a2                	sd	s0,80(sp)
    800053ba:	e4a6                	sd	s1,72(sp)
    800053bc:	e0ca                	sd	s2,64(sp)
    800053be:	fc4e                	sd	s3,56(sp)
    800053c0:	f852                	sd	s4,48(sp)
    800053c2:	f456                	sd	s5,40(sp)
    800053c4:	1080                	addi	s0,sp,96
    800053c6:	84aa                	mv	s1,a0
    800053c8:	892e                	mv	s2,a1
    800053ca:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053cc:	ffffc097          	auipc	ra,0xffffc
    800053d0:	6e4080e7          	jalr	1764(ra) # 80001ab0 <myproc>
    800053d4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053d6:	8526                	mv	a0,s1
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	866080e7          	jalr	-1946(ra) # 80000c3e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053e0:	2184a703          	lw	a4,536(s1)
    800053e4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053e8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ec:	02f71b63          	bne	a4,a5,80005422 <piperead+0x6e>
    800053f0:	2244a783          	lw	a5,548(s1)
    800053f4:	c3b1                	beqz	a5,80005438 <piperead+0x84>
    if(killed(pr)){
    800053f6:	8552                	mv	a0,s4
    800053f8:	ffffd097          	auipc	ra,0xffffd
    800053fc:	3de080e7          	jalr	990(ra) # 800027d6 <killed>
    80005400:	e50d                	bnez	a0,8000542a <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005402:	85a6                	mv	a1,s1
    80005404:	854e                	mv	a0,s3
    80005406:	ffffd097          	auipc	ra,0xffffd
    8000540a:	11c080e7          	jalr	284(ra) # 80002522 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000540e:	2184a703          	lw	a4,536(s1)
    80005412:	21c4a783          	lw	a5,540(s1)
    80005416:	fcf70de3          	beq	a4,a5,800053f0 <piperead+0x3c>
    8000541a:	f05a                	sd	s6,32(sp)
    8000541c:	ec5e                	sd	s7,24(sp)
    8000541e:	e862                	sd	s8,16(sp)
    80005420:	a839                	j	8000543e <piperead+0x8a>
    80005422:	f05a                	sd	s6,32(sp)
    80005424:	ec5e                	sd	s7,24(sp)
    80005426:	e862                	sd	s8,16(sp)
    80005428:	a819                	j	8000543e <piperead+0x8a>
      release(&pi->lock);
    8000542a:	8526                	mv	a0,s1
    8000542c:	ffffc097          	auipc	ra,0xffffc
    80005430:	8c2080e7          	jalr	-1854(ra) # 80000cee <release>
      return -1;
    80005434:	59fd                	li	s3,-1
    80005436:	a895                	j	800054aa <piperead+0xf6>
    80005438:	f05a                	sd	s6,32(sp)
    8000543a:	ec5e                	sd	s7,24(sp)
    8000543c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000543e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005440:	faf40c13          	addi	s8,s0,-81
    80005444:	4b85                	li	s7,1
    80005446:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005448:	05505363          	blez	s5,8000548e <piperead+0xda>
    if(pi->nread == pi->nwrite)
    8000544c:	2184a783          	lw	a5,536(s1)
    80005450:	21c4a703          	lw	a4,540(s1)
    80005454:	02f70d63          	beq	a4,a5,8000548e <piperead+0xda>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005458:	0017871b          	addiw	a4,a5,1
    8000545c:	20e4ac23          	sw	a4,536(s1)
    80005460:	1ff7f793          	andi	a5,a5,511
    80005464:	97a6                	add	a5,a5,s1
    80005466:	0187c783          	lbu	a5,24(a5)
    8000546a:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000546e:	86de                	mv	a3,s7
    80005470:	8662                	mv	a2,s8
    80005472:	85ca                	mv	a1,s2
    80005474:	228a3503          	ld	a0,552(s4)
    80005478:	ffffc097          	auipc	ra,0xffffc
    8000547c:	298080e7          	jalr	664(ra) # 80001710 <copyout>
    80005480:	01650763          	beq	a0,s6,8000548e <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005484:	2985                	addiw	s3,s3,1
    80005486:	0905                	addi	s2,s2,1
    80005488:	fd3a92e3          	bne	s5,s3,8000544c <piperead+0x98>
    8000548c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000548e:	21c48513          	addi	a0,s1,540
    80005492:	ffffd097          	auipc	ra,0xffffd
    80005496:	0f4080e7          	jalr	244(ra) # 80002586 <wakeup>
  release(&pi->lock);
    8000549a:	8526                	mv	a0,s1
    8000549c:	ffffc097          	auipc	ra,0xffffc
    800054a0:	852080e7          	jalr	-1966(ra) # 80000cee <release>
    800054a4:	7b02                	ld	s6,32(sp)
    800054a6:	6be2                	ld	s7,24(sp)
    800054a8:	6c42                	ld	s8,16(sp)
  return i;
}
    800054aa:	854e                	mv	a0,s3
    800054ac:	60e6                	ld	ra,88(sp)
    800054ae:	6446                	ld	s0,80(sp)
    800054b0:	64a6                	ld	s1,72(sp)
    800054b2:	6906                	ld	s2,64(sp)
    800054b4:	79e2                	ld	s3,56(sp)
    800054b6:	7a42                	ld	s4,48(sp)
    800054b8:	7aa2                	ld	s5,40(sp)
    800054ba:	6125                	addi	sp,sp,96
    800054bc:	8082                	ret

00000000800054be <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800054be:	1141                	addi	sp,sp,-16
    800054c0:	e406                	sd	ra,8(sp)
    800054c2:	e022                	sd	s0,0(sp)
    800054c4:	0800                	addi	s0,sp,16
    800054c6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800054c8:	0035151b          	slliw	a0,a0,0x3
    800054cc:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800054ce:	8b89                	andi	a5,a5,2
    800054d0:	c399                	beqz	a5,800054d6 <flags2perm+0x18>
      perm |= PTE_W;
    800054d2:	00456513          	ori	a0,a0,4
    return perm;
}
    800054d6:	60a2                	ld	ra,8(sp)
    800054d8:	6402                	ld	s0,0(sp)
    800054da:	0141                	addi	sp,sp,16
    800054dc:	8082                	ret

00000000800054de <exec>:

int
exec(char *path, char **argv)
{
    800054de:	de010113          	addi	sp,sp,-544
    800054e2:	20113c23          	sd	ra,536(sp)
    800054e6:	20813823          	sd	s0,528(sp)
    800054ea:	20913423          	sd	s1,520(sp)
    800054ee:	21213023          	sd	s2,512(sp)
    800054f2:	1400                	addi	s0,sp,544
    800054f4:	892a                	mv	s2,a0
    800054f6:	dea43823          	sd	a0,-528(s0)
    800054fa:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054fe:	ffffc097          	auipc	ra,0xffffc
    80005502:	5b2080e7          	jalr	1458(ra) # 80001ab0 <myproc>
    80005506:	84aa                	mv	s1,a0

  begin_op();
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	3fc080e7          	jalr	1020(ra) # 80004904 <begin_op>

  if((ip = namei(path)) == 0){
    80005510:	854a                	mv	a0,s2
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	1ec080e7          	jalr	492(ra) # 800046fe <namei>
    8000551a:	c525                	beqz	a0,80005582 <exec+0xa4>
    8000551c:	fbd2                	sd	s4,496(sp)
    8000551e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	9fa080e7          	jalr	-1542(ra) # 80003f1a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005528:	04000713          	li	a4,64
    8000552c:	4681                	li	a3,0
    8000552e:	e5040613          	addi	a2,s0,-432
    80005532:	4581                	li	a1,0
    80005534:	8552                	mv	a0,s4
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	ca0080e7          	jalr	-864(ra) # 800041d6 <readi>
    8000553e:	04000793          	li	a5,64
    80005542:	00f51a63          	bne	a0,a5,80005556 <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005546:	e5042703          	lw	a4,-432(s0)
    8000554a:	464c47b7          	lui	a5,0x464c4
    8000554e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005552:	02f70e63          	beq	a4,a5,8000558e <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005556:	8552                	mv	a0,s4
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	c28080e7          	jalr	-984(ra) # 80004180 <iunlockput>
    end_op();
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	41e080e7          	jalr	1054(ra) # 8000497e <end_op>
  }
  return -1;
    80005568:	557d                	li	a0,-1
    8000556a:	7a5e                	ld	s4,496(sp)
}
    8000556c:	21813083          	ld	ra,536(sp)
    80005570:	21013403          	ld	s0,528(sp)
    80005574:	20813483          	ld	s1,520(sp)
    80005578:	20013903          	ld	s2,512(sp)
    8000557c:	22010113          	addi	sp,sp,544
    80005580:	8082                	ret
    end_op();
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	3fc080e7          	jalr	1020(ra) # 8000497e <end_op>
    return -1;
    8000558a:	557d                	li	a0,-1
    8000558c:	b7c5                	j	8000556c <exec+0x8e>
    8000558e:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005590:	8526                	mv	a0,s1
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	5e2080e7          	jalr	1506(ra) # 80001b74 <proc_pagetable>
    8000559a:	8b2a                	mv	s6,a0
    8000559c:	2c050163          	beqz	a0,8000585e <exec+0x380>
    800055a0:	ffce                	sd	s3,504(sp)
    800055a2:	f7d6                	sd	s5,488(sp)
    800055a4:	efde                	sd	s7,472(sp)
    800055a6:	ebe2                	sd	s8,464(sp)
    800055a8:	e7e6                	sd	s9,456(sp)
    800055aa:	e3ea                	sd	s10,448(sp)
    800055ac:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055ae:	e7042683          	lw	a3,-400(s0)
    800055b2:	e8845783          	lhu	a5,-376(s0)
    800055b6:	10078363          	beqz	a5,800056bc <exec+0x1de>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055ba:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055bc:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055be:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800055c2:	6c85                	lui	s9,0x1
    800055c4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800055c8:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800055cc:	6a85                	lui	s5,0x1
    800055ce:	a0b5                	j	8000563a <exec+0x15c>
      panic("loadseg: address should exist");
    800055d0:	00003517          	auipc	a0,0x3
    800055d4:	ff050513          	addi	a0,a0,-16 # 800085c0 <etext+0x5c0>
    800055d8:	ffffb097          	auipc	ra,0xffffb
    800055dc:	f88080e7          	jalr	-120(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800055e0:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055e2:	874a                	mv	a4,s2
    800055e4:	009c06bb          	addw	a3,s8,s1
    800055e8:	4581                	li	a1,0
    800055ea:	8552                	mv	a0,s4
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	bea080e7          	jalr	-1046(ra) # 800041d6 <readi>
    800055f4:	26a91963          	bne	s2,a0,80005866 <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    800055f8:	009a84bb          	addw	s1,s5,s1
    800055fc:	0334f463          	bgeu	s1,s3,80005624 <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80005600:	02049593          	slli	a1,s1,0x20
    80005604:	9181                	srli	a1,a1,0x20
    80005606:	95de                	add	a1,a1,s7
    80005608:	855a                	mv	a0,s6
    8000560a:	ffffc097          	auipc	ra,0xffffc
    8000560e:	ace080e7          	jalr	-1330(ra) # 800010d8 <walkaddr>
    80005612:	862a                	mv	a2,a0
    if(pa == 0)
    80005614:	dd55                	beqz	a0,800055d0 <exec+0xf2>
    if(sz - i < PGSIZE)
    80005616:	409987bb          	subw	a5,s3,s1
    8000561a:	893e                	mv	s2,a5
    8000561c:	fcfcf2e3          	bgeu	s9,a5,800055e0 <exec+0x102>
    80005620:	8956                	mv	s2,s5
    80005622:	bf7d                	j	800055e0 <exec+0x102>
    sz = sz1;
    80005624:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005628:	2d05                	addiw	s10,s10,1
    8000562a:	e0843783          	ld	a5,-504(s0)
    8000562e:	0387869b          	addiw	a3,a5,56
    80005632:	e8845783          	lhu	a5,-376(s0)
    80005636:	08fd5463          	bge	s10,a5,800056be <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000563a:	e0d43423          	sd	a3,-504(s0)
    8000563e:	876e                	mv	a4,s11
    80005640:	e1840613          	addi	a2,s0,-488
    80005644:	4581                	li	a1,0
    80005646:	8552                	mv	a0,s4
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	b8e080e7          	jalr	-1138(ra) # 800041d6 <readi>
    80005650:	21b51963          	bne	a0,s11,80005862 <exec+0x384>
    if(ph.type != ELF_PROG_LOAD)
    80005654:	e1842783          	lw	a5,-488(s0)
    80005658:	4705                	li	a4,1
    8000565a:	fce797e3          	bne	a5,a4,80005628 <exec+0x14a>
    if(ph.memsz < ph.filesz)
    8000565e:	e4043483          	ld	s1,-448(s0)
    80005662:	e3843783          	ld	a5,-456(s0)
    80005666:	22f4e063          	bltu	s1,a5,80005886 <exec+0x3a8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000566a:	e2843783          	ld	a5,-472(s0)
    8000566e:	94be                	add	s1,s1,a5
    80005670:	20f4ee63          	bltu	s1,a5,8000588c <exec+0x3ae>
    if(ph.vaddr % PGSIZE != 0)
    80005674:	de843703          	ld	a4,-536(s0)
    80005678:	8ff9                	and	a5,a5,a4
    8000567a:	20079c63          	bnez	a5,80005892 <exec+0x3b4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000567e:	e1c42503          	lw	a0,-484(s0)
    80005682:	00000097          	auipc	ra,0x0
    80005686:	e3c080e7          	jalr	-452(ra) # 800054be <flags2perm>
    8000568a:	86aa                	mv	a3,a0
    8000568c:	8626                	mv	a2,s1
    8000568e:	85ca                	mv	a1,s2
    80005690:	855a                	mv	a0,s6
    80005692:	ffffc097          	auipc	ra,0xffffc
    80005696:	e0a080e7          	jalr	-502(ra) # 8000149c <uvmalloc>
    8000569a:	dea43c23          	sd	a0,-520(s0)
    8000569e:	1e050d63          	beqz	a0,80005898 <exec+0x3ba>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800056a2:	e2843b83          	ld	s7,-472(s0)
    800056a6:	e2042c03          	lw	s8,-480(s0)
    800056aa:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800056ae:	00098463          	beqz	s3,800056b6 <exec+0x1d8>
    800056b2:	4481                	li	s1,0
    800056b4:	b7b1                	j	80005600 <exec+0x122>
    sz = sz1;
    800056b6:	df843903          	ld	s2,-520(s0)
    800056ba:	b7bd                	j	80005628 <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056bc:	4901                	li	s2,0
  iunlockput(ip);
    800056be:	8552                	mv	a0,s4
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	ac0080e7          	jalr	-1344(ra) # 80004180 <iunlockput>
  end_op();
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	2b6080e7          	jalr	694(ra) # 8000497e <end_op>
  p = myproc();
    800056d0:	ffffc097          	auipc	ra,0xffffc
    800056d4:	3e0080e7          	jalr	992(ra) # 80001ab0 <myproc>
    800056d8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800056da:	22053d03          	ld	s10,544(a0)
  sz = PGROUNDUP(sz);
    800056de:	6985                	lui	s3,0x1
    800056e0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800056e2:	99ca                	add	s3,s3,s2
    800056e4:	77fd                	lui	a5,0xfffff
    800056e6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800056ea:	4691                	li	a3,4
    800056ec:	6609                	lui	a2,0x2
    800056ee:	964e                	add	a2,a2,s3
    800056f0:	85ce                	mv	a1,s3
    800056f2:	855a                	mv	a0,s6
    800056f4:	ffffc097          	auipc	ra,0xffffc
    800056f8:	da8080e7          	jalr	-600(ra) # 8000149c <uvmalloc>
    800056fc:	8a2a                	mv	s4,a0
    800056fe:	e115                	bnez	a0,80005722 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005700:	85ce                	mv	a1,s3
    80005702:	855a                	mv	a0,s6
    80005704:	ffffc097          	auipc	ra,0xffffc
    80005708:	50c080e7          	jalr	1292(ra) # 80001c10 <proc_freepagetable>
  return -1;
    8000570c:	557d                	li	a0,-1
    8000570e:	79fe                	ld	s3,504(sp)
    80005710:	7a5e                	ld	s4,496(sp)
    80005712:	7abe                	ld	s5,488(sp)
    80005714:	7b1e                	ld	s6,480(sp)
    80005716:	6bfe                	ld	s7,472(sp)
    80005718:	6c5e                	ld	s8,464(sp)
    8000571a:	6cbe                	ld	s9,456(sp)
    8000571c:	6d1e                	ld	s10,448(sp)
    8000571e:	7dfa                	ld	s11,440(sp)
    80005720:	b5b1                	j	8000556c <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005722:	75f9                	lui	a1,0xffffe
    80005724:	95aa                	add	a1,a1,a0
    80005726:	855a                	mv	a0,s6
    80005728:	ffffc097          	auipc	ra,0xffffc
    8000572c:	fb6080e7          	jalr	-74(ra) # 800016de <uvmclear>
  stackbase = sp - PGSIZE;
    80005730:	7bfd                	lui	s7,0xfffff
    80005732:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80005734:	e0043783          	ld	a5,-512(s0)
    80005738:	6388                	ld	a0,0(a5)
  sp = sz;
    8000573a:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000573c:	4481                	li	s1,0
    ustack[argc] = sp;
    8000573e:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005742:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80005746:	c135                	beqz	a0,800057aa <exec+0x2cc>
    sp -= strlen(argv[argc]) + 1;
    80005748:	ffffb097          	auipc	ra,0xffffb
    8000574c:	77a080e7          	jalr	1914(ra) # 80000ec2 <strlen>
    80005750:	0015079b          	addiw	a5,a0,1
    80005754:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005758:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000575c:	15796163          	bltu	s2,s7,8000589e <exec+0x3c0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005760:	e0043d83          	ld	s11,-512(s0)
    80005764:	000db983          	ld	s3,0(s11)
    80005768:	854e                	mv	a0,s3
    8000576a:	ffffb097          	auipc	ra,0xffffb
    8000576e:	758080e7          	jalr	1880(ra) # 80000ec2 <strlen>
    80005772:	0015069b          	addiw	a3,a0,1
    80005776:	864e                	mv	a2,s3
    80005778:	85ca                	mv	a1,s2
    8000577a:	855a                	mv	a0,s6
    8000577c:	ffffc097          	auipc	ra,0xffffc
    80005780:	f94080e7          	jalr	-108(ra) # 80001710 <copyout>
    80005784:	10054f63          	bltz	a0,800058a2 <exec+0x3c4>
    ustack[argc] = sp;
    80005788:	00349793          	slli	a5,s1,0x3
    8000578c:	97e6                	add	a5,a5,s9
    8000578e:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5070>
  for(argc = 0; argv[argc]; argc++) {
    80005792:	0485                	addi	s1,s1,1
    80005794:	008d8793          	addi	a5,s11,8
    80005798:	e0f43023          	sd	a5,-512(s0)
    8000579c:	008db503          	ld	a0,8(s11)
    800057a0:	c509                	beqz	a0,800057aa <exec+0x2cc>
    if(argc >= MAXARG)
    800057a2:	fb8493e3          	bne	s1,s8,80005748 <exec+0x26a>
  sz = sz1;
    800057a6:	89d2                	mv	s3,s4
    800057a8:	bfa1                	j	80005700 <exec+0x222>
  ustack[argc] = 0;
    800057aa:	00349793          	slli	a5,s1,0x3
    800057ae:	f9078793          	addi	a5,a5,-112
    800057b2:	97a2                	add	a5,a5,s0
    800057b4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800057b8:	00148693          	addi	a3,s1,1
    800057bc:	068e                	slli	a3,a3,0x3
    800057be:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057c2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800057c6:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800057c8:	f3796ce3          	bltu	s2,s7,80005700 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057cc:	e9040613          	addi	a2,s0,-368
    800057d0:	85ca                	mv	a1,s2
    800057d2:	855a                	mv	a0,s6
    800057d4:	ffffc097          	auipc	ra,0xffffc
    800057d8:	f3c080e7          	jalr	-196(ra) # 80001710 <copyout>
    800057dc:	f20542e3          	bltz	a0,80005700 <exec+0x222>
  p->trapframe->a1 = sp;
    800057e0:	230ab783          	ld	a5,560(s5) # 1230 <_entry-0x7fffedd0>
    800057e4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800057e8:	df043783          	ld	a5,-528(s0)
    800057ec:	0007c703          	lbu	a4,0(a5)
    800057f0:	cf11                	beqz	a4,8000580c <exec+0x32e>
    800057f2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800057f4:	02f00693          	li	a3,47
    800057f8:	a029                	j	80005802 <exec+0x324>
  for(last=s=path; *s; s++)
    800057fa:	0785                	addi	a5,a5,1
    800057fc:	fff7c703          	lbu	a4,-1(a5)
    80005800:	c711                	beqz	a4,8000580c <exec+0x32e>
    if(*s == '/')
    80005802:	fed71ce3          	bne	a4,a3,800057fa <exec+0x31c>
      last = s+1;
    80005806:	def43823          	sd	a5,-528(s0)
    8000580a:	bfc5                	j	800057fa <exec+0x31c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000580c:	4641                	li	a2,16
    8000580e:	df043583          	ld	a1,-528(s0)
    80005812:	330a8513          	addi	a0,s5,816
    80005816:	ffffb097          	auipc	ra,0xffffb
    8000581a:	676080e7          	jalr	1654(ra) # 80000e8c <safestrcpy>
  oldpagetable = p->pagetable;
    8000581e:	228ab503          	ld	a0,552(s5)
  p->pagetable = pagetable;
    80005822:	236ab423          	sd	s6,552(s5)
  p->sz = sz;
    80005826:	234ab023          	sd	s4,544(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000582a:	230ab783          	ld	a5,560(s5)
    8000582e:	e6843703          	ld	a4,-408(s0)
    80005832:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005834:	230ab783          	ld	a5,560(s5)
    80005838:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000583c:	85ea                	mv	a1,s10
    8000583e:	ffffc097          	auipc	ra,0xffffc
    80005842:	3d2080e7          	jalr	978(ra) # 80001c10 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005846:	0004851b          	sext.w	a0,s1
    8000584a:	79fe                	ld	s3,504(sp)
    8000584c:	7a5e                	ld	s4,496(sp)
    8000584e:	7abe                	ld	s5,488(sp)
    80005850:	7b1e                	ld	s6,480(sp)
    80005852:	6bfe                	ld	s7,472(sp)
    80005854:	6c5e                	ld	s8,464(sp)
    80005856:	6cbe                	ld	s9,456(sp)
    80005858:	6d1e                	ld	s10,448(sp)
    8000585a:	7dfa                	ld	s11,440(sp)
    8000585c:	bb01                	j	8000556c <exec+0x8e>
    8000585e:	7b1e                	ld	s6,480(sp)
    80005860:	b9dd                	j	80005556 <exec+0x78>
    80005862:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005866:	df843583          	ld	a1,-520(s0)
    8000586a:	855a                	mv	a0,s6
    8000586c:	ffffc097          	auipc	ra,0xffffc
    80005870:	3a4080e7          	jalr	932(ra) # 80001c10 <proc_freepagetable>
  if(ip){
    80005874:	79fe                	ld	s3,504(sp)
    80005876:	7abe                	ld	s5,488(sp)
    80005878:	7b1e                	ld	s6,480(sp)
    8000587a:	6bfe                	ld	s7,472(sp)
    8000587c:	6c5e                	ld	s8,464(sp)
    8000587e:	6cbe                	ld	s9,456(sp)
    80005880:	6d1e                	ld	s10,448(sp)
    80005882:	7dfa                	ld	s11,440(sp)
    80005884:	b9c9                	j	80005556 <exec+0x78>
    80005886:	df243c23          	sd	s2,-520(s0)
    8000588a:	bff1                	j	80005866 <exec+0x388>
    8000588c:	df243c23          	sd	s2,-520(s0)
    80005890:	bfd9                	j	80005866 <exec+0x388>
    80005892:	df243c23          	sd	s2,-520(s0)
    80005896:	bfc1                	j	80005866 <exec+0x388>
    80005898:	df243c23          	sd	s2,-520(s0)
    8000589c:	b7e9                	j	80005866 <exec+0x388>
  sz = sz1;
    8000589e:	89d2                	mv	s3,s4
    800058a0:	b585                	j	80005700 <exec+0x222>
    800058a2:	89d2                	mv	s3,s4
    800058a4:	bdb1                	j	80005700 <exec+0x222>

00000000800058a6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800058a6:	7179                	addi	sp,sp,-48
    800058a8:	f406                	sd	ra,40(sp)
    800058aa:	f022                	sd	s0,32(sp)
    800058ac:	ec26                	sd	s1,24(sp)
    800058ae:	e84a                	sd	s2,16(sp)
    800058b0:	1800                	addi	s0,sp,48
    800058b2:	892e                	mv	s2,a1
    800058b4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800058b6:	fdc40593          	addi	a1,s0,-36
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	946080e7          	jalr	-1722(ra) # 80003200 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800058c2:	fdc42703          	lw	a4,-36(s0)
    800058c6:	47bd                	li	a5,15
    800058c8:	02e7eb63          	bltu	a5,a4,800058fe <argfd+0x58>
    800058cc:	ffffc097          	auipc	ra,0xffffc
    800058d0:	1e4080e7          	jalr	484(ra) # 80001ab0 <myproc>
    800058d4:	fdc42703          	lw	a4,-36(s0)
    800058d8:	05470793          	addi	a5,a4,84
    800058dc:	078e                	slli	a5,a5,0x3
    800058de:	953e                	add	a0,a0,a5
    800058e0:	651c                	ld	a5,8(a0)
    800058e2:	c385                	beqz	a5,80005902 <argfd+0x5c>
    return -1;
  if(pfd)
    800058e4:	00090463          	beqz	s2,800058ec <argfd+0x46>
    *pfd = fd;
    800058e8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800058ec:	4501                	li	a0,0
  if(pf)
    800058ee:	c091                	beqz	s1,800058f2 <argfd+0x4c>
    *pf = f;
    800058f0:	e09c                	sd	a5,0(s1)
}
    800058f2:	70a2                	ld	ra,40(sp)
    800058f4:	7402                	ld	s0,32(sp)
    800058f6:	64e2                	ld	s1,24(sp)
    800058f8:	6942                	ld	s2,16(sp)
    800058fa:	6145                	addi	sp,sp,48
    800058fc:	8082                	ret
    return -1;
    800058fe:	557d                	li	a0,-1
    80005900:	bfcd                	j	800058f2 <argfd+0x4c>
    80005902:	557d                	li	a0,-1
    80005904:	b7fd                	j	800058f2 <argfd+0x4c>

0000000080005906 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005906:	1101                	addi	sp,sp,-32
    80005908:	ec06                	sd	ra,24(sp)
    8000590a:	e822                	sd	s0,16(sp)
    8000590c:	e426                	sd	s1,8(sp)
    8000590e:	1000                	addi	s0,sp,32
    80005910:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005912:	ffffc097          	auipc	ra,0xffffc
    80005916:	19e080e7          	jalr	414(ra) # 80001ab0 <myproc>
    8000591a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000591c:	2a850793          	addi	a5,a0,680
    80005920:	4501                	li	a0,0
    80005922:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005924:	6398                	ld	a4,0(a5)
    80005926:	cb19                	beqz	a4,8000593c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005928:	2505                	addiw	a0,a0,1
    8000592a:	07a1                	addi	a5,a5,8
    8000592c:	fed51ce3          	bne	a0,a3,80005924 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005930:	557d                	li	a0,-1
}
    80005932:	60e2                	ld	ra,24(sp)
    80005934:	6442                	ld	s0,16(sp)
    80005936:	64a2                	ld	s1,8(sp)
    80005938:	6105                	addi	sp,sp,32
    8000593a:	8082                	ret
      p->ofile[fd] = f;
    8000593c:	05450793          	addi	a5,a0,84
    80005940:	078e                	slli	a5,a5,0x3
    80005942:	963e                	add	a2,a2,a5
    80005944:	e604                	sd	s1,8(a2)
      return fd;
    80005946:	b7f5                	j	80005932 <fdalloc+0x2c>

0000000080005948 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005948:	715d                	addi	sp,sp,-80
    8000594a:	e486                	sd	ra,72(sp)
    8000594c:	e0a2                	sd	s0,64(sp)
    8000594e:	fc26                	sd	s1,56(sp)
    80005950:	f84a                	sd	s2,48(sp)
    80005952:	f44e                	sd	s3,40(sp)
    80005954:	ec56                	sd	s5,24(sp)
    80005956:	e85a                	sd	s6,16(sp)
    80005958:	0880                	addi	s0,sp,80
    8000595a:	8b2e                	mv	s6,a1
    8000595c:	89b2                	mv	s3,a2
    8000595e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005960:	fb040593          	addi	a1,s0,-80
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	db8080e7          	jalr	-584(ra) # 8000471c <nameiparent>
    8000596c:	84aa                	mv	s1,a0
    8000596e:	14050e63          	beqz	a0,80005aca <create+0x182>
    return 0;

  ilock(dp);
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	5a8080e7          	jalr	1448(ra) # 80003f1a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000597a:	4601                	li	a2,0
    8000597c:	fb040593          	addi	a1,s0,-80
    80005980:	8526                	mv	a0,s1
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	a94080e7          	jalr	-1388(ra) # 80004416 <dirlookup>
    8000598a:	8aaa                	mv	s5,a0
    8000598c:	c539                	beqz	a0,800059da <create+0x92>
    iunlockput(dp);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	7f0080e7          	jalr	2032(ra) # 80004180 <iunlockput>
    ilock(ip);
    80005998:	8556                	mv	a0,s5
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	580080e7          	jalr	1408(ra) # 80003f1a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800059a2:	4789                	li	a5,2
    800059a4:	02fb1463          	bne	s6,a5,800059cc <create+0x84>
    800059a8:	044ad783          	lhu	a5,68(s5)
    800059ac:	37f9                	addiw	a5,a5,-2
    800059ae:	17c2                	slli	a5,a5,0x30
    800059b0:	93c1                	srli	a5,a5,0x30
    800059b2:	4705                	li	a4,1
    800059b4:	00f76c63          	bltu	a4,a5,800059cc <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800059b8:	8556                	mv	a0,s5
    800059ba:	60a6                	ld	ra,72(sp)
    800059bc:	6406                	ld	s0,64(sp)
    800059be:	74e2                	ld	s1,56(sp)
    800059c0:	7942                	ld	s2,48(sp)
    800059c2:	79a2                	ld	s3,40(sp)
    800059c4:	6ae2                	ld	s5,24(sp)
    800059c6:	6b42                	ld	s6,16(sp)
    800059c8:	6161                	addi	sp,sp,80
    800059ca:	8082                	ret
    iunlockput(ip);
    800059cc:	8556                	mv	a0,s5
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	7b2080e7          	jalr	1970(ra) # 80004180 <iunlockput>
    return 0;
    800059d6:	4a81                	li	s5,0
    800059d8:	b7c5                	j	800059b8 <create+0x70>
    800059da:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800059dc:	85da                	mv	a1,s6
    800059de:	4088                	lw	a0,0(s1)
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	396080e7          	jalr	918(ra) # 80003d76 <ialloc>
    800059e8:	8a2a                	mv	s4,a0
    800059ea:	c531                	beqz	a0,80005a36 <create+0xee>
  ilock(ip);
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	52e080e7          	jalr	1326(ra) # 80003f1a <ilock>
  ip->major = major;
    800059f4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800059f8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800059fc:	4905                	li	s2,1
    800059fe:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005a02:	8552                	mv	a0,s4
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	44a080e7          	jalr	1098(ra) # 80003e4e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a0c:	032b0d63          	beq	s6,s2,80005a46 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a10:	004a2603          	lw	a2,4(s4)
    80005a14:	fb040593          	addi	a1,s0,-80
    80005a18:	8526                	mv	a0,s1
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	c22080e7          	jalr	-990(ra) # 8000463c <dirlink>
    80005a22:	08054163          	bltz	a0,80005aa4 <create+0x15c>
  iunlockput(dp);
    80005a26:	8526                	mv	a0,s1
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	758080e7          	jalr	1880(ra) # 80004180 <iunlockput>
  return ip;
    80005a30:	8ad2                	mv	s5,s4
    80005a32:	7a02                	ld	s4,32(sp)
    80005a34:	b751                	j	800059b8 <create+0x70>
    iunlockput(dp);
    80005a36:	8526                	mv	a0,s1
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	748080e7          	jalr	1864(ra) # 80004180 <iunlockput>
    return 0;
    80005a40:	8ad2                	mv	s5,s4
    80005a42:	7a02                	ld	s4,32(sp)
    80005a44:	bf95                	j	800059b8 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a46:	004a2603          	lw	a2,4(s4)
    80005a4a:	00003597          	auipc	a1,0x3
    80005a4e:	b9658593          	addi	a1,a1,-1130 # 800085e0 <etext+0x5e0>
    80005a52:	8552                	mv	a0,s4
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	be8080e7          	jalr	-1048(ra) # 8000463c <dirlink>
    80005a5c:	04054463          	bltz	a0,80005aa4 <create+0x15c>
    80005a60:	40d0                	lw	a2,4(s1)
    80005a62:	00003597          	auipc	a1,0x3
    80005a66:	b8658593          	addi	a1,a1,-1146 # 800085e8 <etext+0x5e8>
    80005a6a:	8552                	mv	a0,s4
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	bd0080e7          	jalr	-1072(ra) # 8000463c <dirlink>
    80005a74:	02054863          	bltz	a0,80005aa4 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a78:	004a2603          	lw	a2,4(s4)
    80005a7c:	fb040593          	addi	a1,s0,-80
    80005a80:	8526                	mv	a0,s1
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	bba080e7          	jalr	-1094(ra) # 8000463c <dirlink>
    80005a8a:	00054d63          	bltz	a0,80005aa4 <create+0x15c>
    dp->nlink++;  // for ".."
    80005a8e:	04a4d783          	lhu	a5,74(s1)
    80005a92:	2785                	addiw	a5,a5,1
    80005a94:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	3b4080e7          	jalr	948(ra) # 80003e4e <iupdate>
    80005aa2:	b751                	j	80005a26 <create+0xde>
  ip->nlink = 0;
    80005aa4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005aa8:	8552                	mv	a0,s4
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	3a4080e7          	jalr	932(ra) # 80003e4e <iupdate>
  iunlockput(ip);
    80005ab2:	8552                	mv	a0,s4
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	6cc080e7          	jalr	1740(ra) # 80004180 <iunlockput>
  iunlockput(dp);
    80005abc:	8526                	mv	a0,s1
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	6c2080e7          	jalr	1730(ra) # 80004180 <iunlockput>
  return 0;
    80005ac6:	7a02                	ld	s4,32(sp)
    80005ac8:	bdc5                	j	800059b8 <create+0x70>
    return 0;
    80005aca:	8aaa                	mv	s5,a0
    80005acc:	b5f5                	j	800059b8 <create+0x70>

0000000080005ace <sys_dup>:
{
    80005ace:	7179                	addi	sp,sp,-48
    80005ad0:	f406                	sd	ra,40(sp)
    80005ad2:	f022                	sd	s0,32(sp)
    80005ad4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005ad6:	fd840613          	addi	a2,s0,-40
    80005ada:	4581                	li	a1,0
    80005adc:	4501                	li	a0,0
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	dc8080e7          	jalr	-568(ra) # 800058a6 <argfd>
    return -1;
    80005ae6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005ae8:	02054763          	bltz	a0,80005b16 <sys_dup+0x48>
    80005aec:	ec26                	sd	s1,24(sp)
    80005aee:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005af0:	fd843903          	ld	s2,-40(s0)
    80005af4:	854a                	mv	a0,s2
    80005af6:	00000097          	auipc	ra,0x0
    80005afa:	e10080e7          	jalr	-496(ra) # 80005906 <fdalloc>
    80005afe:	84aa                	mv	s1,a0
    return -1;
    80005b00:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b02:	00054f63          	bltz	a0,80005b20 <sys_dup+0x52>
  filedup(f);
    80005b06:	854a                	mv	a0,s2
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	27a080e7          	jalr	634(ra) # 80004d82 <filedup>
  return fd;
    80005b10:	87a6                	mv	a5,s1
    80005b12:	64e2                	ld	s1,24(sp)
    80005b14:	6942                	ld	s2,16(sp)
}
    80005b16:	853e                	mv	a0,a5
    80005b18:	70a2                	ld	ra,40(sp)
    80005b1a:	7402                	ld	s0,32(sp)
    80005b1c:	6145                	addi	sp,sp,48
    80005b1e:	8082                	ret
    80005b20:	64e2                	ld	s1,24(sp)
    80005b22:	6942                	ld	s2,16(sp)
    80005b24:	bfcd                	j	80005b16 <sys_dup+0x48>

0000000080005b26 <sys_read>:
{
    80005b26:	7179                	addi	sp,sp,-48
    80005b28:	f406                	sd	ra,40(sp)
    80005b2a:	f022                	sd	s0,32(sp)
    80005b2c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b2e:	fd840593          	addi	a1,s0,-40
    80005b32:	4505                	li	a0,1
    80005b34:	ffffd097          	auipc	ra,0xffffd
    80005b38:	6ec080e7          	jalr	1772(ra) # 80003220 <argaddr>
  argint(2, &n);
    80005b3c:	fe440593          	addi	a1,s0,-28
    80005b40:	4509                	li	a0,2
    80005b42:	ffffd097          	auipc	ra,0xffffd
    80005b46:	6be080e7          	jalr	1726(ra) # 80003200 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b4a:	fe840613          	addi	a2,s0,-24
    80005b4e:	4581                	li	a1,0
    80005b50:	4501                	li	a0,0
    80005b52:	00000097          	auipc	ra,0x0
    80005b56:	d54080e7          	jalr	-684(ra) # 800058a6 <argfd>
    80005b5a:	87aa                	mv	a5,a0
    return -1;
    80005b5c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b5e:	0007cc63          	bltz	a5,80005b76 <sys_read+0x50>
  return fileread(f, p, n);
    80005b62:	fe442603          	lw	a2,-28(s0)
    80005b66:	fd843583          	ld	a1,-40(s0)
    80005b6a:	fe843503          	ld	a0,-24(s0)
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	3ba080e7          	jalr	954(ra) # 80004f28 <fileread>
}
    80005b76:	70a2                	ld	ra,40(sp)
    80005b78:	7402                	ld	s0,32(sp)
    80005b7a:	6145                	addi	sp,sp,48
    80005b7c:	8082                	ret

0000000080005b7e <sys_write>:
{
    80005b7e:	7179                	addi	sp,sp,-48
    80005b80:	f406                	sd	ra,40(sp)
    80005b82:	f022                	sd	s0,32(sp)
    80005b84:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b86:	fd840593          	addi	a1,s0,-40
    80005b8a:	4505                	li	a0,1
    80005b8c:	ffffd097          	auipc	ra,0xffffd
    80005b90:	694080e7          	jalr	1684(ra) # 80003220 <argaddr>
  argint(2, &n);
    80005b94:	fe440593          	addi	a1,s0,-28
    80005b98:	4509                	li	a0,2
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	666080e7          	jalr	1638(ra) # 80003200 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ba2:	fe840613          	addi	a2,s0,-24
    80005ba6:	4581                	li	a1,0
    80005ba8:	4501                	li	a0,0
    80005baa:	00000097          	auipc	ra,0x0
    80005bae:	cfc080e7          	jalr	-772(ra) # 800058a6 <argfd>
    80005bb2:	87aa                	mv	a5,a0
    return -1;
    80005bb4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bb6:	0007cc63          	bltz	a5,80005bce <sys_write+0x50>
  return filewrite(f, p, n);
    80005bba:	fe442603          	lw	a2,-28(s0)
    80005bbe:	fd843583          	ld	a1,-40(s0)
    80005bc2:	fe843503          	ld	a0,-24(s0)
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	434080e7          	jalr	1076(ra) # 80004ffa <filewrite>
}
    80005bce:	70a2                	ld	ra,40(sp)
    80005bd0:	7402                	ld	s0,32(sp)
    80005bd2:	6145                	addi	sp,sp,48
    80005bd4:	8082                	ret

0000000080005bd6 <sys_close>:
{
    80005bd6:	1101                	addi	sp,sp,-32
    80005bd8:	ec06                	sd	ra,24(sp)
    80005bda:	e822                	sd	s0,16(sp)
    80005bdc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005bde:	fe040613          	addi	a2,s0,-32
    80005be2:	fec40593          	addi	a1,s0,-20
    80005be6:	4501                	li	a0,0
    80005be8:	00000097          	auipc	ra,0x0
    80005bec:	cbe080e7          	jalr	-834(ra) # 800058a6 <argfd>
    return -1;
    80005bf0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bf2:	02054563          	bltz	a0,80005c1c <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005bf6:	ffffc097          	auipc	ra,0xffffc
    80005bfa:	eba080e7          	jalr	-326(ra) # 80001ab0 <myproc>
    80005bfe:	fec42783          	lw	a5,-20(s0)
    80005c02:	05478793          	addi	a5,a5,84
    80005c06:	078e                	slli	a5,a5,0x3
    80005c08:	953e                	add	a0,a0,a5
    80005c0a:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005c0e:	fe043503          	ld	a0,-32(s0)
    80005c12:	fffff097          	auipc	ra,0xfffff
    80005c16:	1c2080e7          	jalr	450(ra) # 80004dd4 <fileclose>
  return 0;
    80005c1a:	4781                	li	a5,0
}
    80005c1c:	853e                	mv	a0,a5
    80005c1e:	60e2                	ld	ra,24(sp)
    80005c20:	6442                	ld	s0,16(sp)
    80005c22:	6105                	addi	sp,sp,32
    80005c24:	8082                	ret

0000000080005c26 <sys_fstat>:
{
    80005c26:	1101                	addi	sp,sp,-32
    80005c28:	ec06                	sd	ra,24(sp)
    80005c2a:	e822                	sd	s0,16(sp)
    80005c2c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c2e:	fe040593          	addi	a1,s0,-32
    80005c32:	4505                	li	a0,1
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	5ec080e7          	jalr	1516(ra) # 80003220 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c3c:	fe840613          	addi	a2,s0,-24
    80005c40:	4581                	li	a1,0
    80005c42:	4501                	li	a0,0
    80005c44:	00000097          	auipc	ra,0x0
    80005c48:	c62080e7          	jalr	-926(ra) # 800058a6 <argfd>
    80005c4c:	87aa                	mv	a5,a0
    return -1;
    80005c4e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c50:	0007ca63          	bltz	a5,80005c64 <sys_fstat+0x3e>
  return filestat(f, st);
    80005c54:	fe043583          	ld	a1,-32(s0)
    80005c58:	fe843503          	ld	a0,-24(s0)
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	256080e7          	jalr	598(ra) # 80004eb2 <filestat>
}
    80005c64:	60e2                	ld	ra,24(sp)
    80005c66:	6442                	ld	s0,16(sp)
    80005c68:	6105                	addi	sp,sp,32
    80005c6a:	8082                	ret

0000000080005c6c <sys_link>:
{
    80005c6c:	7169                	addi	sp,sp,-304
    80005c6e:	f606                	sd	ra,296(sp)
    80005c70:	f222                	sd	s0,288(sp)
    80005c72:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c74:	08000613          	li	a2,128
    80005c78:	ed040593          	addi	a1,s0,-304
    80005c7c:	4501                	li	a0,0
    80005c7e:	ffffd097          	auipc	ra,0xffffd
    80005c82:	5c2080e7          	jalr	1474(ra) # 80003240 <argstr>
    return -1;
    80005c86:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c88:	12054663          	bltz	a0,80005db4 <sys_link+0x148>
    80005c8c:	08000613          	li	a2,128
    80005c90:	f5040593          	addi	a1,s0,-176
    80005c94:	4505                	li	a0,1
    80005c96:	ffffd097          	auipc	ra,0xffffd
    80005c9a:	5aa080e7          	jalr	1450(ra) # 80003240 <argstr>
    return -1;
    80005c9e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ca0:	10054a63          	bltz	a0,80005db4 <sys_link+0x148>
    80005ca4:	ee26                	sd	s1,280(sp)
  begin_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	c5e080e7          	jalr	-930(ra) # 80004904 <begin_op>
  if((ip = namei(old)) == 0){
    80005cae:	ed040513          	addi	a0,s0,-304
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	a4c080e7          	jalr	-1460(ra) # 800046fe <namei>
    80005cba:	84aa                	mv	s1,a0
    80005cbc:	c949                	beqz	a0,80005d4e <sys_link+0xe2>
  ilock(ip);
    80005cbe:	ffffe097          	auipc	ra,0xffffe
    80005cc2:	25c080e7          	jalr	604(ra) # 80003f1a <ilock>
  if(ip->type == T_DIR){
    80005cc6:	04449703          	lh	a4,68(s1)
    80005cca:	4785                	li	a5,1
    80005ccc:	08f70863          	beq	a4,a5,80005d5c <sys_link+0xf0>
    80005cd0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005cd2:	04a4d783          	lhu	a5,74(s1)
    80005cd6:	2785                	addiw	a5,a5,1
    80005cd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cdc:	8526                	mv	a0,s1
    80005cde:	ffffe097          	auipc	ra,0xffffe
    80005ce2:	170080e7          	jalr	368(ra) # 80003e4e <iupdate>
  iunlock(ip);
    80005ce6:	8526                	mv	a0,s1
    80005ce8:	ffffe097          	auipc	ra,0xffffe
    80005cec:	2f8080e7          	jalr	760(ra) # 80003fe0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005cf0:	fd040593          	addi	a1,s0,-48
    80005cf4:	f5040513          	addi	a0,s0,-176
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	a24080e7          	jalr	-1500(ra) # 8000471c <nameiparent>
    80005d00:	892a                	mv	s2,a0
    80005d02:	cd35                	beqz	a0,80005d7e <sys_link+0x112>
  ilock(dp);
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	216080e7          	jalr	534(ra) # 80003f1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d0c:	00092703          	lw	a4,0(s2)
    80005d10:	409c                	lw	a5,0(s1)
    80005d12:	06f71163          	bne	a4,a5,80005d74 <sys_link+0x108>
    80005d16:	40d0                	lw	a2,4(s1)
    80005d18:	fd040593          	addi	a1,s0,-48
    80005d1c:	854a                	mv	a0,s2
    80005d1e:	fffff097          	auipc	ra,0xfffff
    80005d22:	91e080e7          	jalr	-1762(ra) # 8000463c <dirlink>
    80005d26:	04054763          	bltz	a0,80005d74 <sys_link+0x108>
  iunlockput(dp);
    80005d2a:	854a                	mv	a0,s2
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	454080e7          	jalr	1108(ra) # 80004180 <iunlockput>
  iput(ip);
    80005d34:	8526                	mv	a0,s1
    80005d36:	ffffe097          	auipc	ra,0xffffe
    80005d3a:	3a2080e7          	jalr	930(ra) # 800040d8 <iput>
  end_op();
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	c40080e7          	jalr	-960(ra) # 8000497e <end_op>
  return 0;
    80005d46:	4781                	li	a5,0
    80005d48:	64f2                	ld	s1,280(sp)
    80005d4a:	6952                	ld	s2,272(sp)
    80005d4c:	a0a5                	j	80005db4 <sys_link+0x148>
    end_op();
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	c30080e7          	jalr	-976(ra) # 8000497e <end_op>
    return -1;
    80005d56:	57fd                	li	a5,-1
    80005d58:	64f2                	ld	s1,280(sp)
    80005d5a:	a8a9                	j	80005db4 <sys_link+0x148>
    iunlockput(ip);
    80005d5c:	8526                	mv	a0,s1
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	422080e7          	jalr	1058(ra) # 80004180 <iunlockput>
    end_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	c18080e7          	jalr	-1000(ra) # 8000497e <end_op>
    return -1;
    80005d6e:	57fd                	li	a5,-1
    80005d70:	64f2                	ld	s1,280(sp)
    80005d72:	a089                	j	80005db4 <sys_link+0x148>
    iunlockput(dp);
    80005d74:	854a                	mv	a0,s2
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	40a080e7          	jalr	1034(ra) # 80004180 <iunlockput>
  ilock(ip);
    80005d7e:	8526                	mv	a0,s1
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	19a080e7          	jalr	410(ra) # 80003f1a <ilock>
  ip->nlink--;
    80005d88:	04a4d783          	lhu	a5,74(s1)
    80005d8c:	37fd                	addiw	a5,a5,-1
    80005d8e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d92:	8526                	mv	a0,s1
    80005d94:	ffffe097          	auipc	ra,0xffffe
    80005d98:	0ba080e7          	jalr	186(ra) # 80003e4e <iupdate>
  iunlockput(ip);
    80005d9c:	8526                	mv	a0,s1
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	3e2080e7          	jalr	994(ra) # 80004180 <iunlockput>
  end_op();
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	bd8080e7          	jalr	-1064(ra) # 8000497e <end_op>
  return -1;
    80005dae:	57fd                	li	a5,-1
    80005db0:	64f2                	ld	s1,280(sp)
    80005db2:	6952                	ld	s2,272(sp)
}
    80005db4:	853e                	mv	a0,a5
    80005db6:	70b2                	ld	ra,296(sp)
    80005db8:	7412                	ld	s0,288(sp)
    80005dba:	6155                	addi	sp,sp,304
    80005dbc:	8082                	ret

0000000080005dbe <sys_unlink>:
{
    80005dbe:	7111                	addi	sp,sp,-256
    80005dc0:	fd86                	sd	ra,248(sp)
    80005dc2:	f9a2                	sd	s0,240(sp)
    80005dc4:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80005dc6:	08000613          	li	a2,128
    80005dca:	f2040593          	addi	a1,s0,-224
    80005dce:	4501                	li	a0,0
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	470080e7          	jalr	1136(ra) # 80003240 <argstr>
    80005dd8:	1c054063          	bltz	a0,80005f98 <sys_unlink+0x1da>
    80005ddc:	f5a6                	sd	s1,232(sp)
  begin_op();
    80005dde:	fffff097          	auipc	ra,0xfffff
    80005de2:	b26080e7          	jalr	-1242(ra) # 80004904 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005de6:	fa040593          	addi	a1,s0,-96
    80005dea:	f2040513          	addi	a0,s0,-224
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	92e080e7          	jalr	-1746(ra) # 8000471c <nameiparent>
    80005df6:	84aa                	mv	s1,a0
    80005df8:	c165                	beqz	a0,80005ed8 <sys_unlink+0x11a>
  ilock(dp);
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	120080e7          	jalr	288(ra) # 80003f1a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005e02:	00002597          	auipc	a1,0x2
    80005e06:	7de58593          	addi	a1,a1,2014 # 800085e0 <etext+0x5e0>
    80005e0a:	fa040513          	addi	a0,s0,-96
    80005e0e:	ffffe097          	auipc	ra,0xffffe
    80005e12:	5ee080e7          	jalr	1518(ra) # 800043fc <namecmp>
    80005e16:	16050263          	beqz	a0,80005f7a <sys_unlink+0x1bc>
    80005e1a:	00002597          	auipc	a1,0x2
    80005e1e:	7ce58593          	addi	a1,a1,1998 # 800085e8 <etext+0x5e8>
    80005e22:	fa040513          	addi	a0,s0,-96
    80005e26:	ffffe097          	auipc	ra,0xffffe
    80005e2a:	5d6080e7          	jalr	1494(ra) # 800043fc <namecmp>
    80005e2e:	14050663          	beqz	a0,80005f7a <sys_unlink+0x1bc>
    80005e32:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e34:	f1c40613          	addi	a2,s0,-228
    80005e38:	fa040593          	addi	a1,s0,-96
    80005e3c:	8526                	mv	a0,s1
    80005e3e:	ffffe097          	auipc	ra,0xffffe
    80005e42:	5d8080e7          	jalr	1496(ra) # 80004416 <dirlookup>
    80005e46:	892a                	mv	s2,a0
    80005e48:	12050863          	beqz	a0,80005f78 <sys_unlink+0x1ba>
    80005e4c:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005e4e:	ffffe097          	auipc	ra,0xffffe
    80005e52:	0cc080e7          	jalr	204(ra) # 80003f1a <ilock>
  if(ip->nlink < 1)
    80005e56:	04a91783          	lh	a5,74(s2)
    80005e5a:	08f05663          	blez	a5,80005ee6 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e5e:	04491703          	lh	a4,68(s2)
    80005e62:	4785                	li	a5,1
    80005e64:	08f70b63          	beq	a4,a5,80005efa <sys_unlink+0x13c>
  memset(&de, 0, sizeof(de));
    80005e68:	fb040993          	addi	s3,s0,-80
    80005e6c:	4641                	li	a2,16
    80005e6e:	4581                	li	a1,0
    80005e70:	854e                	mv	a0,s3
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	ec4080e7          	jalr	-316(ra) # 80000d36 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e7a:	4741                	li	a4,16
    80005e7c:	f1c42683          	lw	a3,-228(s0)
    80005e80:	864e                	mv	a2,s3
    80005e82:	4581                	li	a1,0
    80005e84:	8526                	mv	a0,s1
    80005e86:	ffffe097          	auipc	ra,0xffffe
    80005e8a:	456080e7          	jalr	1110(ra) # 800042dc <writei>
    80005e8e:	47c1                	li	a5,16
    80005e90:	0af51f63          	bne	a0,a5,80005f4e <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80005e94:	04491703          	lh	a4,68(s2)
    80005e98:	4785                	li	a5,1
    80005e9a:	0cf70463          	beq	a4,a5,80005f62 <sys_unlink+0x1a4>
  iunlockput(dp);
    80005e9e:	8526                	mv	a0,s1
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	2e0080e7          	jalr	736(ra) # 80004180 <iunlockput>
  ip->nlink--;
    80005ea8:	04a95783          	lhu	a5,74(s2)
    80005eac:	37fd                	addiw	a5,a5,-1
    80005eae:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005eb2:	854a                	mv	a0,s2
    80005eb4:	ffffe097          	auipc	ra,0xffffe
    80005eb8:	f9a080e7          	jalr	-102(ra) # 80003e4e <iupdate>
  iunlockput(ip);
    80005ebc:	854a                	mv	a0,s2
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	2c2080e7          	jalr	706(ra) # 80004180 <iunlockput>
  end_op();
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	ab8080e7          	jalr	-1352(ra) # 8000497e <end_op>
  return 0;
    80005ece:	4501                	li	a0,0
    80005ed0:	74ae                	ld	s1,232(sp)
    80005ed2:	790e                	ld	s2,224(sp)
    80005ed4:	69ee                	ld	s3,216(sp)
    80005ed6:	a86d                	j	80005f90 <sys_unlink+0x1d2>
    end_op();
    80005ed8:	fffff097          	auipc	ra,0xfffff
    80005edc:	aa6080e7          	jalr	-1370(ra) # 8000497e <end_op>
    return -1;
    80005ee0:	557d                	li	a0,-1
    80005ee2:	74ae                	ld	s1,232(sp)
    80005ee4:	a075                	j	80005f90 <sys_unlink+0x1d2>
    80005ee6:	e9d2                	sd	s4,208(sp)
    80005ee8:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80005eea:	00002517          	auipc	a0,0x2
    80005eee:	70650513          	addi	a0,a0,1798 # 800085f0 <etext+0x5f0>
    80005ef2:	ffffa097          	auipc	ra,0xffffa
    80005ef6:	66e080e7          	jalr	1646(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005efa:	04c92703          	lw	a4,76(s2)
    80005efe:	02000793          	li	a5,32
    80005f02:	f6e7f3e3          	bgeu	a5,a4,80005e68 <sys_unlink+0xaa>
    80005f06:	e9d2                	sd	s4,208(sp)
    80005f08:	e5d6                	sd	s5,200(sp)
    80005f0a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f0c:	f0840a93          	addi	s5,s0,-248
    80005f10:	4a41                	li	s4,16
    80005f12:	8752                	mv	a4,s4
    80005f14:	86ce                	mv	a3,s3
    80005f16:	8656                	mv	a2,s5
    80005f18:	4581                	li	a1,0
    80005f1a:	854a                	mv	a0,s2
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	2ba080e7          	jalr	698(ra) # 800041d6 <readi>
    80005f24:	01451d63          	bne	a0,s4,80005f3e <sys_unlink+0x180>
    if(de.inum != 0)
    80005f28:	f0845783          	lhu	a5,-248(s0)
    80005f2c:	eba5                	bnez	a5,80005f9c <sys_unlink+0x1de>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f2e:	29c1                	addiw	s3,s3,16
    80005f30:	04c92783          	lw	a5,76(s2)
    80005f34:	fcf9efe3          	bltu	s3,a5,80005f12 <sys_unlink+0x154>
    80005f38:	6a4e                	ld	s4,208(sp)
    80005f3a:	6aae                	ld	s5,200(sp)
    80005f3c:	b735                	j	80005e68 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005f3e:	00002517          	auipc	a0,0x2
    80005f42:	6ca50513          	addi	a0,a0,1738 # 80008608 <etext+0x608>
    80005f46:	ffffa097          	auipc	ra,0xffffa
    80005f4a:	61a080e7          	jalr	1562(ra) # 80000560 <panic>
    80005f4e:	e9d2                	sd	s4,208(sp)
    80005f50:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80005f52:	00002517          	auipc	a0,0x2
    80005f56:	6ce50513          	addi	a0,a0,1742 # 80008620 <etext+0x620>
    80005f5a:	ffffa097          	auipc	ra,0xffffa
    80005f5e:	606080e7          	jalr	1542(ra) # 80000560 <panic>
    dp->nlink--;
    80005f62:	04a4d783          	lhu	a5,74(s1)
    80005f66:	37fd                	addiw	a5,a5,-1
    80005f68:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f6c:	8526                	mv	a0,s1
    80005f6e:	ffffe097          	auipc	ra,0xffffe
    80005f72:	ee0080e7          	jalr	-288(ra) # 80003e4e <iupdate>
    80005f76:	b725                	j	80005e9e <sys_unlink+0xe0>
    80005f78:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80005f7a:	8526                	mv	a0,s1
    80005f7c:	ffffe097          	auipc	ra,0xffffe
    80005f80:	204080e7          	jalr	516(ra) # 80004180 <iunlockput>
  end_op();
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	9fa080e7          	jalr	-1542(ra) # 8000497e <end_op>
  return -1;
    80005f8c:	557d                	li	a0,-1
    80005f8e:	74ae                	ld	s1,232(sp)
}
    80005f90:	70ee                	ld	ra,248(sp)
    80005f92:	744e                	ld	s0,240(sp)
    80005f94:	6111                	addi	sp,sp,256
    80005f96:	8082                	ret
    return -1;
    80005f98:	557d                	li	a0,-1
    80005f9a:	bfdd                	j	80005f90 <sys_unlink+0x1d2>
    iunlockput(ip);
    80005f9c:	854a                	mv	a0,s2
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	1e2080e7          	jalr	482(ra) # 80004180 <iunlockput>
    goto bad;
    80005fa6:	790e                	ld	s2,224(sp)
    80005fa8:	69ee                	ld	s3,216(sp)
    80005faa:	6a4e                	ld	s4,208(sp)
    80005fac:	6aae                	ld	s5,200(sp)
    80005fae:	b7f1                	j	80005f7a <sys_unlink+0x1bc>

0000000080005fb0 <sys_open>:

uint64
sys_open(void)
{
    80005fb0:	7131                	addi	sp,sp,-192
    80005fb2:	fd06                	sd	ra,184(sp)
    80005fb4:	f922                	sd	s0,176(sp)
    80005fb6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005fb8:	f4c40593          	addi	a1,s0,-180
    80005fbc:	4505                	li	a0,1
    80005fbe:	ffffd097          	auipc	ra,0xffffd
    80005fc2:	242080e7          	jalr	578(ra) # 80003200 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005fc6:	08000613          	li	a2,128
    80005fca:	f5040593          	addi	a1,s0,-176
    80005fce:	4501                	li	a0,0
    80005fd0:	ffffd097          	auipc	ra,0xffffd
    80005fd4:	270080e7          	jalr	624(ra) # 80003240 <argstr>
    80005fd8:	87aa                	mv	a5,a0
    return -1;
    80005fda:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005fdc:	0a07cf63          	bltz	a5,8000609a <sys_open+0xea>
    80005fe0:	f526                	sd	s1,168(sp)

  begin_op();
    80005fe2:	fffff097          	auipc	ra,0xfffff
    80005fe6:	922080e7          	jalr	-1758(ra) # 80004904 <begin_op>

  if(omode & O_CREATE){
    80005fea:	f4c42783          	lw	a5,-180(s0)
    80005fee:	2007f793          	andi	a5,a5,512
    80005ff2:	cfdd                	beqz	a5,800060b0 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    80005ff4:	4681                	li	a3,0
    80005ff6:	4601                	li	a2,0
    80005ff8:	4589                	li	a1,2
    80005ffa:	f5040513          	addi	a0,s0,-176
    80005ffe:	00000097          	auipc	ra,0x0
    80006002:	94a080e7          	jalr	-1718(ra) # 80005948 <create>
    80006006:	84aa                	mv	s1,a0
    if(ip == 0){
    80006008:	cd49                	beqz	a0,800060a2 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000600a:	04449703          	lh	a4,68(s1)
    8000600e:	478d                	li	a5,3
    80006010:	00f71763          	bne	a4,a5,8000601e <sys_open+0x6e>
    80006014:	0464d703          	lhu	a4,70(s1)
    80006018:	47a5                	li	a5,9
    8000601a:	0ee7e263          	bltu	a5,a4,800060fe <sys_open+0x14e>
    8000601e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006020:	fffff097          	auipc	ra,0xfffff
    80006024:	cf8080e7          	jalr	-776(ra) # 80004d18 <filealloc>
    80006028:	892a                	mv	s2,a0
    8000602a:	cd65                	beqz	a0,80006122 <sys_open+0x172>
    8000602c:	ed4e                	sd	s3,152(sp)
    8000602e:	00000097          	auipc	ra,0x0
    80006032:	8d8080e7          	jalr	-1832(ra) # 80005906 <fdalloc>
    80006036:	89aa                	mv	s3,a0
    80006038:	0c054f63          	bltz	a0,80006116 <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000603c:	04449703          	lh	a4,68(s1)
    80006040:	478d                	li	a5,3
    80006042:	0ef70d63          	beq	a4,a5,8000613c <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006046:	4789                	li	a5,2
    80006048:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000604c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006050:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006054:	f4c42783          	lw	a5,-180(s0)
    80006058:	0017f713          	andi	a4,a5,1
    8000605c:	00174713          	xori	a4,a4,1
    80006060:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006064:	0037f713          	andi	a4,a5,3
    80006068:	00e03733          	snez	a4,a4
    8000606c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006070:	4007f793          	andi	a5,a5,1024
    80006074:	c791                	beqz	a5,80006080 <sys_open+0xd0>
    80006076:	04449703          	lh	a4,68(s1)
    8000607a:	4789                	li	a5,2
    8000607c:	0cf70763          	beq	a4,a5,8000614a <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80006080:	8526                	mv	a0,s1
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	f5e080e7          	jalr	-162(ra) # 80003fe0 <iunlock>
  end_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	8f4080e7          	jalr	-1804(ra) # 8000497e <end_op>

  return fd;
    80006092:	854e                	mv	a0,s3
    80006094:	74aa                	ld	s1,168(sp)
    80006096:	790a                	ld	s2,160(sp)
    80006098:	69ea                	ld	s3,152(sp)
}
    8000609a:	70ea                	ld	ra,184(sp)
    8000609c:	744a                	ld	s0,176(sp)
    8000609e:	6129                	addi	sp,sp,192
    800060a0:	8082                	ret
      end_op();
    800060a2:	fffff097          	auipc	ra,0xfffff
    800060a6:	8dc080e7          	jalr	-1828(ra) # 8000497e <end_op>
      return -1;
    800060aa:	557d                	li	a0,-1
    800060ac:	74aa                	ld	s1,168(sp)
    800060ae:	b7f5                	j	8000609a <sys_open+0xea>
    if((ip = namei(path)) == 0){
    800060b0:	f5040513          	addi	a0,s0,-176
    800060b4:	ffffe097          	auipc	ra,0xffffe
    800060b8:	64a080e7          	jalr	1610(ra) # 800046fe <namei>
    800060bc:	84aa                	mv	s1,a0
    800060be:	c90d                	beqz	a0,800060f0 <sys_open+0x140>
    ilock(ip);
    800060c0:	ffffe097          	auipc	ra,0xffffe
    800060c4:	e5a080e7          	jalr	-422(ra) # 80003f1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060c8:	04449703          	lh	a4,68(s1)
    800060cc:	4785                	li	a5,1
    800060ce:	f2f71ee3          	bne	a4,a5,8000600a <sys_open+0x5a>
    800060d2:	f4c42783          	lw	a5,-180(s0)
    800060d6:	d7a1                	beqz	a5,8000601e <sys_open+0x6e>
      iunlockput(ip);
    800060d8:	8526                	mv	a0,s1
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	0a6080e7          	jalr	166(ra) # 80004180 <iunlockput>
      end_op();
    800060e2:	fffff097          	auipc	ra,0xfffff
    800060e6:	89c080e7          	jalr	-1892(ra) # 8000497e <end_op>
      return -1;
    800060ea:	557d                	li	a0,-1
    800060ec:	74aa                	ld	s1,168(sp)
    800060ee:	b775                	j	8000609a <sys_open+0xea>
      end_op();
    800060f0:	fffff097          	auipc	ra,0xfffff
    800060f4:	88e080e7          	jalr	-1906(ra) # 8000497e <end_op>
      return -1;
    800060f8:	557d                	li	a0,-1
    800060fa:	74aa                	ld	s1,168(sp)
    800060fc:	bf79                	j	8000609a <sys_open+0xea>
    iunlockput(ip);
    800060fe:	8526                	mv	a0,s1
    80006100:	ffffe097          	auipc	ra,0xffffe
    80006104:	080080e7          	jalr	128(ra) # 80004180 <iunlockput>
    end_op();
    80006108:	fffff097          	auipc	ra,0xfffff
    8000610c:	876080e7          	jalr	-1930(ra) # 8000497e <end_op>
    return -1;
    80006110:	557d                	li	a0,-1
    80006112:	74aa                	ld	s1,168(sp)
    80006114:	b759                	j	8000609a <sys_open+0xea>
      fileclose(f);
    80006116:	854a                	mv	a0,s2
    80006118:	fffff097          	auipc	ra,0xfffff
    8000611c:	cbc080e7          	jalr	-836(ra) # 80004dd4 <fileclose>
    80006120:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006122:	8526                	mv	a0,s1
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	05c080e7          	jalr	92(ra) # 80004180 <iunlockput>
    end_op();
    8000612c:	fffff097          	auipc	ra,0xfffff
    80006130:	852080e7          	jalr	-1966(ra) # 8000497e <end_op>
    return -1;
    80006134:	557d                	li	a0,-1
    80006136:	74aa                	ld	s1,168(sp)
    80006138:	790a                	ld	s2,160(sp)
    8000613a:	b785                	j	8000609a <sys_open+0xea>
    f->type = FD_DEVICE;
    8000613c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006140:	04649783          	lh	a5,70(s1)
    80006144:	02f91223          	sh	a5,36(s2)
    80006148:	b721                	j	80006050 <sys_open+0xa0>
    itrunc(ip);
    8000614a:	8526                	mv	a0,s1
    8000614c:	ffffe097          	auipc	ra,0xffffe
    80006150:	ee0080e7          	jalr	-288(ra) # 8000402c <itrunc>
    80006154:	b735                	j	80006080 <sys_open+0xd0>

0000000080006156 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006156:	7175                	addi	sp,sp,-144
    80006158:	e506                	sd	ra,136(sp)
    8000615a:	e122                	sd	s0,128(sp)
    8000615c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000615e:	ffffe097          	auipc	ra,0xffffe
    80006162:	7a6080e7          	jalr	1958(ra) # 80004904 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006166:	08000613          	li	a2,128
    8000616a:	f7040593          	addi	a1,s0,-144
    8000616e:	4501                	li	a0,0
    80006170:	ffffd097          	auipc	ra,0xffffd
    80006174:	0d0080e7          	jalr	208(ra) # 80003240 <argstr>
    80006178:	02054963          	bltz	a0,800061aa <sys_mkdir+0x54>
    8000617c:	4681                	li	a3,0
    8000617e:	4601                	li	a2,0
    80006180:	4585                	li	a1,1
    80006182:	f7040513          	addi	a0,s0,-144
    80006186:	fffff097          	auipc	ra,0xfffff
    8000618a:	7c2080e7          	jalr	1986(ra) # 80005948 <create>
    8000618e:	cd11                	beqz	a0,800061aa <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006190:	ffffe097          	auipc	ra,0xffffe
    80006194:	ff0080e7          	jalr	-16(ra) # 80004180 <iunlockput>
  end_op();
    80006198:	ffffe097          	auipc	ra,0xffffe
    8000619c:	7e6080e7          	jalr	2022(ra) # 8000497e <end_op>
  return 0;
    800061a0:	4501                	li	a0,0
}
    800061a2:	60aa                	ld	ra,136(sp)
    800061a4:	640a                	ld	s0,128(sp)
    800061a6:	6149                	addi	sp,sp,144
    800061a8:	8082                	ret
    end_op();
    800061aa:	ffffe097          	auipc	ra,0xffffe
    800061ae:	7d4080e7          	jalr	2004(ra) # 8000497e <end_op>
    return -1;
    800061b2:	557d                	li	a0,-1
    800061b4:	b7fd                	j	800061a2 <sys_mkdir+0x4c>

00000000800061b6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800061b6:	7135                	addi	sp,sp,-160
    800061b8:	ed06                	sd	ra,152(sp)
    800061ba:	e922                	sd	s0,144(sp)
    800061bc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800061be:	ffffe097          	auipc	ra,0xffffe
    800061c2:	746080e7          	jalr	1862(ra) # 80004904 <begin_op>
  argint(1, &major);
    800061c6:	f6c40593          	addi	a1,s0,-148
    800061ca:	4505                	li	a0,1
    800061cc:	ffffd097          	auipc	ra,0xffffd
    800061d0:	034080e7          	jalr	52(ra) # 80003200 <argint>
  argint(2, &minor);
    800061d4:	f6840593          	addi	a1,s0,-152
    800061d8:	4509                	li	a0,2
    800061da:	ffffd097          	auipc	ra,0xffffd
    800061de:	026080e7          	jalr	38(ra) # 80003200 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061e2:	08000613          	li	a2,128
    800061e6:	f7040593          	addi	a1,s0,-144
    800061ea:	4501                	li	a0,0
    800061ec:	ffffd097          	auipc	ra,0xffffd
    800061f0:	054080e7          	jalr	84(ra) # 80003240 <argstr>
    800061f4:	02054b63          	bltz	a0,8000622a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800061f8:	f6841683          	lh	a3,-152(s0)
    800061fc:	f6c41603          	lh	a2,-148(s0)
    80006200:	458d                	li	a1,3
    80006202:	f7040513          	addi	a0,s0,-144
    80006206:	fffff097          	auipc	ra,0xfffff
    8000620a:	742080e7          	jalr	1858(ra) # 80005948 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000620e:	cd11                	beqz	a0,8000622a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006210:	ffffe097          	auipc	ra,0xffffe
    80006214:	f70080e7          	jalr	-144(ra) # 80004180 <iunlockput>
  end_op();
    80006218:	ffffe097          	auipc	ra,0xffffe
    8000621c:	766080e7          	jalr	1894(ra) # 8000497e <end_op>
  return 0;
    80006220:	4501                	li	a0,0
}
    80006222:	60ea                	ld	ra,152(sp)
    80006224:	644a                	ld	s0,144(sp)
    80006226:	610d                	addi	sp,sp,160
    80006228:	8082                	ret
    end_op();
    8000622a:	ffffe097          	auipc	ra,0xffffe
    8000622e:	754080e7          	jalr	1876(ra) # 8000497e <end_op>
    return -1;
    80006232:	557d                	li	a0,-1
    80006234:	b7fd                	j	80006222 <sys_mknod+0x6c>

0000000080006236 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006236:	7135                	addi	sp,sp,-160
    80006238:	ed06                	sd	ra,152(sp)
    8000623a:	e922                	sd	s0,144(sp)
    8000623c:	e14a                	sd	s2,128(sp)
    8000623e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006240:	ffffc097          	auipc	ra,0xffffc
    80006244:	870080e7          	jalr	-1936(ra) # 80001ab0 <myproc>
    80006248:	892a                	mv	s2,a0
  
  begin_op();
    8000624a:	ffffe097          	auipc	ra,0xffffe
    8000624e:	6ba080e7          	jalr	1722(ra) # 80004904 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006252:	08000613          	li	a2,128
    80006256:	f6040593          	addi	a1,s0,-160
    8000625a:	4501                	li	a0,0
    8000625c:	ffffd097          	auipc	ra,0xffffd
    80006260:	fe4080e7          	jalr	-28(ra) # 80003240 <argstr>
    80006264:	04054d63          	bltz	a0,800062be <sys_chdir+0x88>
    80006268:	e526                	sd	s1,136(sp)
    8000626a:	f6040513          	addi	a0,s0,-160
    8000626e:	ffffe097          	auipc	ra,0xffffe
    80006272:	490080e7          	jalr	1168(ra) # 800046fe <namei>
    80006276:	84aa                	mv	s1,a0
    80006278:	c131                	beqz	a0,800062bc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000627a:	ffffe097          	auipc	ra,0xffffe
    8000627e:	ca0080e7          	jalr	-864(ra) # 80003f1a <ilock>
  if(ip->type != T_DIR){
    80006282:	04449703          	lh	a4,68(s1)
    80006286:	4785                	li	a5,1
    80006288:	04f71163          	bne	a4,a5,800062ca <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000628c:	8526                	mv	a0,s1
    8000628e:	ffffe097          	auipc	ra,0xffffe
    80006292:	d52080e7          	jalr	-686(ra) # 80003fe0 <iunlock>
  iput(p->cwd);
    80006296:	32893503          	ld	a0,808(s2)
    8000629a:	ffffe097          	auipc	ra,0xffffe
    8000629e:	e3e080e7          	jalr	-450(ra) # 800040d8 <iput>
  end_op();
    800062a2:	ffffe097          	auipc	ra,0xffffe
    800062a6:	6dc080e7          	jalr	1756(ra) # 8000497e <end_op>
  p->cwd = ip;
    800062aa:	32993423          	sd	s1,808(s2)
  return 0;
    800062ae:	4501                	li	a0,0
    800062b0:	64aa                	ld	s1,136(sp)
}
    800062b2:	60ea                	ld	ra,152(sp)
    800062b4:	644a                	ld	s0,144(sp)
    800062b6:	690a                	ld	s2,128(sp)
    800062b8:	610d                	addi	sp,sp,160
    800062ba:	8082                	ret
    800062bc:	64aa                	ld	s1,136(sp)
    end_op();
    800062be:	ffffe097          	auipc	ra,0xffffe
    800062c2:	6c0080e7          	jalr	1728(ra) # 8000497e <end_op>
    return -1;
    800062c6:	557d                	li	a0,-1
    800062c8:	b7ed                	j	800062b2 <sys_chdir+0x7c>
    iunlockput(ip);
    800062ca:	8526                	mv	a0,s1
    800062cc:	ffffe097          	auipc	ra,0xffffe
    800062d0:	eb4080e7          	jalr	-332(ra) # 80004180 <iunlockput>
    end_op();
    800062d4:	ffffe097          	auipc	ra,0xffffe
    800062d8:	6aa080e7          	jalr	1706(ra) # 8000497e <end_op>
    return -1;
    800062dc:	557d                	li	a0,-1
    800062de:	64aa                	ld	s1,136(sp)
    800062e0:	bfc9                	j	800062b2 <sys_chdir+0x7c>

00000000800062e2 <sys_exec>:

uint64
sys_exec(void)
{
    800062e2:	7105                	addi	sp,sp,-480
    800062e4:	ef86                	sd	ra,472(sp)
    800062e6:	eba2                	sd	s0,464(sp)
    800062e8:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800062ea:	e2840593          	addi	a1,s0,-472
    800062ee:	4505                	li	a0,1
    800062f0:	ffffd097          	auipc	ra,0xffffd
    800062f4:	f30080e7          	jalr	-208(ra) # 80003220 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800062f8:	08000613          	li	a2,128
    800062fc:	f3040593          	addi	a1,s0,-208
    80006300:	4501                	li	a0,0
    80006302:	ffffd097          	auipc	ra,0xffffd
    80006306:	f3e080e7          	jalr	-194(ra) # 80003240 <argstr>
    8000630a:	87aa                	mv	a5,a0
    return -1;
    8000630c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000630e:	0e07ce63          	bltz	a5,8000640a <sys_exec+0x128>
    80006312:	e7a6                	sd	s1,456(sp)
    80006314:	e3ca                	sd	s2,448(sp)
    80006316:	ff4e                	sd	s3,440(sp)
    80006318:	fb52                	sd	s4,432(sp)
    8000631a:	f756                	sd	s5,424(sp)
    8000631c:	f35a                	sd	s6,416(sp)
    8000631e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006320:	e3040a13          	addi	s4,s0,-464
    80006324:	10000613          	li	a2,256
    80006328:	4581                	li	a1,0
    8000632a:	8552                	mv	a0,s4
    8000632c:	ffffb097          	auipc	ra,0xffffb
    80006330:	a0a080e7          	jalr	-1526(ra) # 80000d36 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006334:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80006336:	89d2                	mv	s3,s4
    80006338:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000633a:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000633e:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80006340:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006344:	00391513          	slli	a0,s2,0x3
    80006348:	85d6                	mv	a1,s5
    8000634a:	e2843783          	ld	a5,-472(s0)
    8000634e:	953e                	add	a0,a0,a5
    80006350:	ffffd097          	auipc	ra,0xffffd
    80006354:	e0c080e7          	jalr	-500(ra) # 8000315c <fetchaddr>
    80006358:	02054a63          	bltz	a0,8000638c <sys_exec+0xaa>
    if(uarg == 0){
    8000635c:	e2043783          	ld	a5,-480(s0)
    80006360:	cbb1                	beqz	a5,800063b4 <sys_exec+0xd2>
    argv[i] = kalloc();
    80006362:	ffffa097          	auipc	ra,0xffffa
    80006366:	7e8080e7          	jalr	2024(ra) # 80000b4a <kalloc>
    8000636a:	85aa                	mv	a1,a0
    8000636c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006370:	cd11                	beqz	a0,8000638c <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006372:	865a                	mv	a2,s6
    80006374:	e2043503          	ld	a0,-480(s0)
    80006378:	ffffd097          	auipc	ra,0xffffd
    8000637c:	e3a080e7          	jalr	-454(ra) # 800031b2 <fetchstr>
    80006380:	00054663          	bltz	a0,8000638c <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80006384:	0905                	addi	s2,s2,1
    80006386:	09a1                	addi	s3,s3,8
    80006388:	fb791ee3          	bne	s2,s7,80006344 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000638c:	100a0a13          	addi	s4,s4,256
    80006390:	6088                	ld	a0,0(s1)
    80006392:	c525                	beqz	a0,800063fa <sys_exec+0x118>
    kfree(argv[i]);
    80006394:	ffffa097          	auipc	ra,0xffffa
    80006398:	6b8080e7          	jalr	1720(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000639c:	04a1                	addi	s1,s1,8
    8000639e:	ff4499e3          	bne	s1,s4,80006390 <sys_exec+0xae>
  return -1;
    800063a2:	557d                	li	a0,-1
    800063a4:	64be                	ld	s1,456(sp)
    800063a6:	691e                	ld	s2,448(sp)
    800063a8:	79fa                	ld	s3,440(sp)
    800063aa:	7a5a                	ld	s4,432(sp)
    800063ac:	7aba                	ld	s5,424(sp)
    800063ae:	7b1a                	ld	s6,416(sp)
    800063b0:	6bfa                	ld	s7,408(sp)
    800063b2:	a8a1                	j	8000640a <sys_exec+0x128>
      argv[i] = 0;
    800063b4:	0009079b          	sext.w	a5,s2
    800063b8:	e3040593          	addi	a1,s0,-464
    800063bc:	078e                	slli	a5,a5,0x3
    800063be:	97ae                	add	a5,a5,a1
    800063c0:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    800063c4:	f3040513          	addi	a0,s0,-208
    800063c8:	fffff097          	auipc	ra,0xfffff
    800063cc:	116080e7          	jalr	278(ra) # 800054de <exec>
    800063d0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063d2:	100a0a13          	addi	s4,s4,256
    800063d6:	6088                	ld	a0,0(s1)
    800063d8:	c901                	beqz	a0,800063e8 <sys_exec+0x106>
    kfree(argv[i]);
    800063da:	ffffa097          	auipc	ra,0xffffa
    800063de:	672080e7          	jalr	1650(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063e2:	04a1                	addi	s1,s1,8
    800063e4:	ff4499e3          	bne	s1,s4,800063d6 <sys_exec+0xf4>
  return ret;
    800063e8:	854a                	mv	a0,s2
    800063ea:	64be                	ld	s1,456(sp)
    800063ec:	691e                	ld	s2,448(sp)
    800063ee:	79fa                	ld	s3,440(sp)
    800063f0:	7a5a                	ld	s4,432(sp)
    800063f2:	7aba                	ld	s5,424(sp)
    800063f4:	7b1a                	ld	s6,416(sp)
    800063f6:	6bfa                	ld	s7,408(sp)
    800063f8:	a809                	j	8000640a <sys_exec+0x128>
  return -1;
    800063fa:	557d                	li	a0,-1
    800063fc:	64be                	ld	s1,456(sp)
    800063fe:	691e                	ld	s2,448(sp)
    80006400:	79fa                	ld	s3,440(sp)
    80006402:	7a5a                	ld	s4,432(sp)
    80006404:	7aba                	ld	s5,424(sp)
    80006406:	7b1a                	ld	s6,416(sp)
    80006408:	6bfa                	ld	s7,408(sp)
}
    8000640a:	60fe                	ld	ra,472(sp)
    8000640c:	645e                	ld	s0,464(sp)
    8000640e:	613d                	addi	sp,sp,480
    80006410:	8082                	ret

0000000080006412 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006412:	7139                	addi	sp,sp,-64
    80006414:	fc06                	sd	ra,56(sp)
    80006416:	f822                	sd	s0,48(sp)
    80006418:	f426                	sd	s1,40(sp)
    8000641a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000641c:	ffffb097          	auipc	ra,0xffffb
    80006420:	694080e7          	jalr	1684(ra) # 80001ab0 <myproc>
    80006424:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006426:	fd840593          	addi	a1,s0,-40
    8000642a:	4501                	li	a0,0
    8000642c:	ffffd097          	auipc	ra,0xffffd
    80006430:	df4080e7          	jalr	-524(ra) # 80003220 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006434:	fc840593          	addi	a1,s0,-56
    80006438:	fd040513          	addi	a0,s0,-48
    8000643c:	fffff097          	auipc	ra,0xfffff
    80006440:	d0c080e7          	jalr	-756(ra) # 80005148 <pipealloc>
    return -1;
    80006444:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006446:	0c054963          	bltz	a0,80006518 <sys_pipe+0x106>
  fd0 = -1;
    8000644a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000644e:	fd043503          	ld	a0,-48(s0)
    80006452:	fffff097          	auipc	ra,0xfffff
    80006456:	4b4080e7          	jalr	1204(ra) # 80005906 <fdalloc>
    8000645a:	fca42223          	sw	a0,-60(s0)
    8000645e:	0a054063          	bltz	a0,800064fe <sys_pipe+0xec>
    80006462:	fc843503          	ld	a0,-56(s0)
    80006466:	fffff097          	auipc	ra,0xfffff
    8000646a:	4a0080e7          	jalr	1184(ra) # 80005906 <fdalloc>
    8000646e:	fca42023          	sw	a0,-64(s0)
    80006472:	06054c63          	bltz	a0,800064ea <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006476:	4691                	li	a3,4
    80006478:	fc440613          	addi	a2,s0,-60
    8000647c:	fd843583          	ld	a1,-40(s0)
    80006480:	2284b503          	ld	a0,552(s1)
    80006484:	ffffb097          	auipc	ra,0xffffb
    80006488:	28c080e7          	jalr	652(ra) # 80001710 <copyout>
    8000648c:	02054163          	bltz	a0,800064ae <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006490:	4691                	li	a3,4
    80006492:	fc040613          	addi	a2,s0,-64
    80006496:	fd843583          	ld	a1,-40(s0)
    8000649a:	95b6                	add	a1,a1,a3
    8000649c:	2284b503          	ld	a0,552(s1)
    800064a0:	ffffb097          	auipc	ra,0xffffb
    800064a4:	270080e7          	jalr	624(ra) # 80001710 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800064a8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064aa:	06055763          	bgez	a0,80006518 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    800064ae:	fc442783          	lw	a5,-60(s0)
    800064b2:	05478793          	addi	a5,a5,84
    800064b6:	078e                	slli	a5,a5,0x3
    800064b8:	97a6                	add	a5,a5,s1
    800064ba:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800064be:	fc042783          	lw	a5,-64(s0)
    800064c2:	05478793          	addi	a5,a5,84
    800064c6:	078e                	slli	a5,a5,0x3
    800064c8:	94be                	add	s1,s1,a5
    800064ca:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800064ce:	fd043503          	ld	a0,-48(s0)
    800064d2:	fffff097          	auipc	ra,0xfffff
    800064d6:	902080e7          	jalr	-1790(ra) # 80004dd4 <fileclose>
    fileclose(wf);
    800064da:	fc843503          	ld	a0,-56(s0)
    800064de:	fffff097          	auipc	ra,0xfffff
    800064e2:	8f6080e7          	jalr	-1802(ra) # 80004dd4 <fileclose>
    return -1;
    800064e6:	57fd                	li	a5,-1
    800064e8:	a805                	j	80006518 <sys_pipe+0x106>
    if(fd0 >= 0)
    800064ea:	fc442783          	lw	a5,-60(s0)
    800064ee:	0007c863          	bltz	a5,800064fe <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    800064f2:	05478793          	addi	a5,a5,84
    800064f6:	078e                	slli	a5,a5,0x3
    800064f8:	97a6                	add	a5,a5,s1
    800064fa:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800064fe:	fd043503          	ld	a0,-48(s0)
    80006502:	fffff097          	auipc	ra,0xfffff
    80006506:	8d2080e7          	jalr	-1838(ra) # 80004dd4 <fileclose>
    fileclose(wf);
    8000650a:	fc843503          	ld	a0,-56(s0)
    8000650e:	fffff097          	auipc	ra,0xfffff
    80006512:	8c6080e7          	jalr	-1850(ra) # 80004dd4 <fileclose>
    return -1;
    80006516:	57fd                	li	a5,-1
}
    80006518:	853e                	mv	a0,a5
    8000651a:	70e2                	ld	ra,56(sp)
    8000651c:	7442                	ld	s0,48(sp)
    8000651e:	74a2                	ld	s1,40(sp)
    80006520:	6121                	addi	sp,sp,64
    80006522:	8082                	ret
	...

0000000080006530 <kernelvec>:
    80006530:	7111                	addi	sp,sp,-256
    80006532:	e006                	sd	ra,0(sp)
    80006534:	e40a                	sd	sp,8(sp)
    80006536:	e80e                	sd	gp,16(sp)
    80006538:	ec12                	sd	tp,24(sp)
    8000653a:	f016                	sd	t0,32(sp)
    8000653c:	f41a                	sd	t1,40(sp)
    8000653e:	f81e                	sd	t2,48(sp)
    80006540:	fc22                	sd	s0,56(sp)
    80006542:	e0a6                	sd	s1,64(sp)
    80006544:	e4aa                	sd	a0,72(sp)
    80006546:	e8ae                	sd	a1,80(sp)
    80006548:	ecb2                	sd	a2,88(sp)
    8000654a:	f0b6                	sd	a3,96(sp)
    8000654c:	f4ba                	sd	a4,104(sp)
    8000654e:	f8be                	sd	a5,112(sp)
    80006550:	fcc2                	sd	a6,120(sp)
    80006552:	e146                	sd	a7,128(sp)
    80006554:	e54a                	sd	s2,136(sp)
    80006556:	e94e                	sd	s3,144(sp)
    80006558:	ed52                	sd	s4,152(sp)
    8000655a:	f156                	sd	s5,160(sp)
    8000655c:	f55a                	sd	s6,168(sp)
    8000655e:	f95e                	sd	s7,176(sp)
    80006560:	fd62                	sd	s8,184(sp)
    80006562:	e1e6                	sd	s9,192(sp)
    80006564:	e5ea                	sd	s10,200(sp)
    80006566:	e9ee                	sd	s11,208(sp)
    80006568:	edf2                	sd	t3,216(sp)
    8000656a:	f1f6                	sd	t4,224(sp)
    8000656c:	f5fa                	sd	t5,232(sp)
    8000656e:	f9fe                	sd	t6,240(sp)
    80006570:	aadfc0ef          	jal	8000301c <kerneltrap>
    80006574:	6082                	ld	ra,0(sp)
    80006576:	6122                	ld	sp,8(sp)
    80006578:	61c2                	ld	gp,16(sp)
    8000657a:	7282                	ld	t0,32(sp)
    8000657c:	7322                	ld	t1,40(sp)
    8000657e:	73c2                	ld	t2,48(sp)
    80006580:	7462                	ld	s0,56(sp)
    80006582:	6486                	ld	s1,64(sp)
    80006584:	6526                	ld	a0,72(sp)
    80006586:	65c6                	ld	a1,80(sp)
    80006588:	6666                	ld	a2,88(sp)
    8000658a:	7686                	ld	a3,96(sp)
    8000658c:	7726                	ld	a4,104(sp)
    8000658e:	77c6                	ld	a5,112(sp)
    80006590:	7866                	ld	a6,120(sp)
    80006592:	688a                	ld	a7,128(sp)
    80006594:	692a                	ld	s2,136(sp)
    80006596:	69ca                	ld	s3,144(sp)
    80006598:	6a6a                	ld	s4,152(sp)
    8000659a:	7a8a                	ld	s5,160(sp)
    8000659c:	7b2a                	ld	s6,168(sp)
    8000659e:	7bca                	ld	s7,176(sp)
    800065a0:	7c6a                	ld	s8,184(sp)
    800065a2:	6c8e                	ld	s9,192(sp)
    800065a4:	6d2e                	ld	s10,200(sp)
    800065a6:	6dce                	ld	s11,208(sp)
    800065a8:	6e6e                	ld	t3,216(sp)
    800065aa:	7e8e                	ld	t4,224(sp)
    800065ac:	7f2e                	ld	t5,232(sp)
    800065ae:	7fce                	ld	t6,240(sp)
    800065b0:	6111                	addi	sp,sp,256
    800065b2:	10200073          	sret
    800065b6:	00000013          	nop
    800065ba:	00000013          	nop
    800065be:	0001                	nop

00000000800065c0 <timervec>:
    800065c0:	34051573          	csrrw	a0,mscratch,a0
    800065c4:	e10c                	sd	a1,0(a0)
    800065c6:	e510                	sd	a2,8(a0)
    800065c8:	e914                	sd	a3,16(a0)
    800065ca:	6d0c                	ld	a1,24(a0)
    800065cc:	7110                	ld	a2,32(a0)
    800065ce:	6194                	ld	a3,0(a1)
    800065d0:	96b2                	add	a3,a3,a2
    800065d2:	e194                	sd	a3,0(a1)
    800065d4:	4589                	li	a1,2
    800065d6:	14459073          	csrw	sip,a1
    800065da:	6914                	ld	a3,16(a0)
    800065dc:	6510                	ld	a2,8(a0)
    800065de:	610c                	ld	a1,0(a0)
    800065e0:	34051573          	csrrw	a0,mscratch,a0
    800065e4:	30200073          	mret
	...

00000000800065ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800065ea:	1141                	addi	sp,sp,-16
    800065ec:	e406                	sd	ra,8(sp)
    800065ee:	e022                	sd	s0,0(sp)
    800065f0:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800065f2:	0c000737          	lui	a4,0xc000
    800065f6:	4785                	li	a5,1
    800065f8:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800065fa:	c35c                	sw	a5,4(a4)
}
    800065fc:	60a2                	ld	ra,8(sp)
    800065fe:	6402                	ld	s0,0(sp)
    80006600:	0141                	addi	sp,sp,16
    80006602:	8082                	ret

0000000080006604 <plicinithart>:

void
plicinithart(void)
{
    80006604:	1141                	addi	sp,sp,-16
    80006606:	e406                	sd	ra,8(sp)
    80006608:	e022                	sd	s0,0(sp)
    8000660a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000660c:	ffffb097          	auipc	ra,0xffffb
    80006610:	470080e7          	jalr	1136(ra) # 80001a7c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006614:	0085171b          	slliw	a4,a0,0x8
    80006618:	0c0027b7          	lui	a5,0xc002
    8000661c:	97ba                	add	a5,a5,a4
    8000661e:	40200713          	li	a4,1026
    80006622:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006626:	00d5151b          	slliw	a0,a0,0xd
    8000662a:	0c2017b7          	lui	a5,0xc201
    8000662e:	97aa                	add	a5,a5,a0
    80006630:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006634:	60a2                	ld	ra,8(sp)
    80006636:	6402                	ld	s0,0(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret

000000008000663c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000663c:	1141                	addi	sp,sp,-16
    8000663e:	e406                	sd	ra,8(sp)
    80006640:	e022                	sd	s0,0(sp)
    80006642:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006644:	ffffb097          	auipc	ra,0xffffb
    80006648:	438080e7          	jalr	1080(ra) # 80001a7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000664c:	00d5151b          	slliw	a0,a0,0xd
    80006650:	0c2017b7          	lui	a5,0xc201
    80006654:	97aa                	add	a5,a5,a0
  return irq;
}
    80006656:	43c8                	lw	a0,4(a5)
    80006658:	60a2                	ld	ra,8(sp)
    8000665a:	6402                	ld	s0,0(sp)
    8000665c:	0141                	addi	sp,sp,16
    8000665e:	8082                	ret

0000000080006660 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006660:	1101                	addi	sp,sp,-32
    80006662:	ec06                	sd	ra,24(sp)
    80006664:	e822                	sd	s0,16(sp)
    80006666:	e426                	sd	s1,8(sp)
    80006668:	1000                	addi	s0,sp,32
    8000666a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000666c:	ffffb097          	auipc	ra,0xffffb
    80006670:	410080e7          	jalr	1040(ra) # 80001a7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006674:	00d5179b          	slliw	a5,a0,0xd
    80006678:	0c201737          	lui	a4,0xc201
    8000667c:	97ba                	add	a5,a5,a4
    8000667e:	c3c4                	sw	s1,4(a5)
}
    80006680:	60e2                	ld	ra,24(sp)
    80006682:	6442                	ld	s0,16(sp)
    80006684:	64a2                	ld	s1,8(sp)
    80006686:	6105                	addi	sp,sp,32
    80006688:	8082                	ret

000000008000668a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000668a:	1141                	addi	sp,sp,-16
    8000668c:	e406                	sd	ra,8(sp)
    8000668e:	e022                	sd	s0,0(sp)
    80006690:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006692:	479d                	li	a5,7
    80006694:	04a7cc63          	blt	a5,a0,800066ec <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006698:	00023797          	auipc	a5,0x23
    8000669c:	7b878793          	addi	a5,a5,1976 # 80029e50 <disk>
    800066a0:	97aa                	add	a5,a5,a0
    800066a2:	0187c783          	lbu	a5,24(a5)
    800066a6:	ebb9                	bnez	a5,800066fc <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800066a8:	00451693          	slli	a3,a0,0x4
    800066ac:	00023797          	auipc	a5,0x23
    800066b0:	7a478793          	addi	a5,a5,1956 # 80029e50 <disk>
    800066b4:	6398                	ld	a4,0(a5)
    800066b6:	9736                	add	a4,a4,a3
    800066b8:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800066bc:	6398                	ld	a4,0(a5)
    800066be:	9736                	add	a4,a4,a3
    800066c0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066c4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066c8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066cc:	97aa                	add	a5,a5,a0
    800066ce:	4705                	li	a4,1
    800066d0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066d4:	00023517          	auipc	a0,0x23
    800066d8:	79450513          	addi	a0,a0,1940 # 80029e68 <disk+0x18>
    800066dc:	ffffc097          	auipc	ra,0xffffc
    800066e0:	eaa080e7          	jalr	-342(ra) # 80002586 <wakeup>
}
    800066e4:	60a2                	ld	ra,8(sp)
    800066e6:	6402                	ld	s0,0(sp)
    800066e8:	0141                	addi	sp,sp,16
    800066ea:	8082                	ret
    panic("free_desc 1");
    800066ec:	00002517          	auipc	a0,0x2
    800066f0:	f4450513          	addi	a0,a0,-188 # 80008630 <etext+0x630>
    800066f4:	ffffa097          	auipc	ra,0xffffa
    800066f8:	e6c080e7          	jalr	-404(ra) # 80000560 <panic>
    panic("free_desc 2");
    800066fc:	00002517          	auipc	a0,0x2
    80006700:	f4450513          	addi	a0,a0,-188 # 80008640 <etext+0x640>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	e5c080e7          	jalr	-420(ra) # 80000560 <panic>

000000008000670c <virtio_disk_init>:
{
    8000670c:	1101                	addi	sp,sp,-32
    8000670e:	ec06                	sd	ra,24(sp)
    80006710:	e822                	sd	s0,16(sp)
    80006712:	e426                	sd	s1,8(sp)
    80006714:	e04a                	sd	s2,0(sp)
    80006716:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006718:	00002597          	auipc	a1,0x2
    8000671c:	f3858593          	addi	a1,a1,-200 # 80008650 <etext+0x650>
    80006720:	00024517          	auipc	a0,0x24
    80006724:	85850513          	addi	a0,a0,-1960 # 80029f78 <disk+0x128>
    80006728:	ffffa097          	auipc	ra,0xffffa
    8000672c:	482080e7          	jalr	1154(ra) # 80000baa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006730:	100017b7          	lui	a5,0x10001
    80006734:	4398                	lw	a4,0(a5)
    80006736:	2701                	sext.w	a4,a4
    80006738:	747277b7          	lui	a5,0x74727
    8000673c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006740:	16f71463          	bne	a4,a5,800068a8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006744:	100017b7          	lui	a5,0x10001
    80006748:	43dc                	lw	a5,4(a5)
    8000674a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000674c:	4709                	li	a4,2
    8000674e:	14e79d63          	bne	a5,a4,800068a8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006752:	100017b7          	lui	a5,0x10001
    80006756:	479c                	lw	a5,8(a5)
    80006758:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000675a:	14e79763          	bne	a5,a4,800068a8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000675e:	100017b7          	lui	a5,0x10001
    80006762:	47d8                	lw	a4,12(a5)
    80006764:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006766:	554d47b7          	lui	a5,0x554d4
    8000676a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000676e:	12f71d63          	bne	a4,a5,800068a8 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006772:	100017b7          	lui	a5,0x10001
    80006776:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000677a:	4705                	li	a4,1
    8000677c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000677e:	470d                	li	a4,3
    80006780:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006782:	10001737          	lui	a4,0x10001
    80006786:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006788:	c7ffe6b7          	lui	a3,0xc7ffe
    8000678c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd47cf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006790:	8f75                	and	a4,a4,a3
    80006792:	100016b7          	lui	a3,0x10001
    80006796:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006798:	472d                	li	a4,11
    8000679a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000679c:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800067a0:	439c                	lw	a5,0(a5)
    800067a2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067a6:	8ba1                	andi	a5,a5,8
    800067a8:	10078863          	beqz	a5,800068b8 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800067ac:	100017b7          	lui	a5,0x10001
    800067b0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800067b4:	43fc                	lw	a5,68(a5)
    800067b6:	2781                	sext.w	a5,a5
    800067b8:	10079863          	bnez	a5,800068c8 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800067bc:	100017b7          	lui	a5,0x10001
    800067c0:	5bdc                	lw	a5,52(a5)
    800067c2:	2781                	sext.w	a5,a5
  if(max == 0)
    800067c4:	10078a63          	beqz	a5,800068d8 <virtio_disk_init+0x1cc>
  if(max < NUM)
    800067c8:	471d                	li	a4,7
    800067ca:	10f77f63          	bgeu	a4,a5,800068e8 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    800067ce:	ffffa097          	auipc	ra,0xffffa
    800067d2:	37c080e7          	jalr	892(ra) # 80000b4a <kalloc>
    800067d6:	00023497          	auipc	s1,0x23
    800067da:	67a48493          	addi	s1,s1,1658 # 80029e50 <disk>
    800067de:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800067e0:	ffffa097          	auipc	ra,0xffffa
    800067e4:	36a080e7          	jalr	874(ra) # 80000b4a <kalloc>
    800067e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800067ea:	ffffa097          	auipc	ra,0xffffa
    800067ee:	360080e7          	jalr	864(ra) # 80000b4a <kalloc>
    800067f2:	87aa                	mv	a5,a0
    800067f4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800067f6:	6088                	ld	a0,0(s1)
    800067f8:	10050063          	beqz	a0,800068f8 <virtio_disk_init+0x1ec>
    800067fc:	00023717          	auipc	a4,0x23
    80006800:	65c73703          	ld	a4,1628(a4) # 80029e58 <disk+0x8>
    80006804:	cb75                	beqz	a4,800068f8 <virtio_disk_init+0x1ec>
    80006806:	cbed                	beqz	a5,800068f8 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006808:	6605                	lui	a2,0x1
    8000680a:	4581                	li	a1,0
    8000680c:	ffffa097          	auipc	ra,0xffffa
    80006810:	52a080e7          	jalr	1322(ra) # 80000d36 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006814:	00023497          	auipc	s1,0x23
    80006818:	63c48493          	addi	s1,s1,1596 # 80029e50 <disk>
    8000681c:	6605                	lui	a2,0x1
    8000681e:	4581                	li	a1,0
    80006820:	6488                	ld	a0,8(s1)
    80006822:	ffffa097          	auipc	ra,0xffffa
    80006826:	514080e7          	jalr	1300(ra) # 80000d36 <memset>
  memset(disk.used, 0, PGSIZE);
    8000682a:	6605                	lui	a2,0x1
    8000682c:	4581                	li	a1,0
    8000682e:	6888                	ld	a0,16(s1)
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	506080e7          	jalr	1286(ra) # 80000d36 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006838:	100017b7          	lui	a5,0x10001
    8000683c:	4721                	li	a4,8
    8000683e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006840:	4098                	lw	a4,0(s1)
    80006842:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006846:	40d8                	lw	a4,4(s1)
    80006848:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000684c:	649c                	ld	a5,8(s1)
    8000684e:	0007869b          	sext.w	a3,a5
    80006852:	10001737          	lui	a4,0x10001
    80006856:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000685a:	9781                	srai	a5,a5,0x20
    8000685c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006860:	689c                	ld	a5,16(s1)
    80006862:	0007869b          	sext.w	a3,a5
    80006866:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000686a:	9781                	srai	a5,a5,0x20
    8000686c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006870:	4785                	li	a5,1
    80006872:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006874:	00f48c23          	sb	a5,24(s1)
    80006878:	00f48ca3          	sb	a5,25(s1)
    8000687c:	00f48d23          	sb	a5,26(s1)
    80006880:	00f48da3          	sb	a5,27(s1)
    80006884:	00f48e23          	sb	a5,28(s1)
    80006888:	00f48ea3          	sb	a5,29(s1)
    8000688c:	00f48f23          	sb	a5,30(s1)
    80006890:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006894:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006898:	07272823          	sw	s2,112(a4)
}
    8000689c:	60e2                	ld	ra,24(sp)
    8000689e:	6442                	ld	s0,16(sp)
    800068a0:	64a2                	ld	s1,8(sp)
    800068a2:	6902                	ld	s2,0(sp)
    800068a4:	6105                	addi	sp,sp,32
    800068a6:	8082                	ret
    panic("could not find virtio disk");
    800068a8:	00002517          	auipc	a0,0x2
    800068ac:	db850513          	addi	a0,a0,-584 # 80008660 <etext+0x660>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	cb0080e7          	jalr	-848(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    800068b8:	00002517          	auipc	a0,0x2
    800068bc:	dc850513          	addi	a0,a0,-568 # 80008680 <etext+0x680>
    800068c0:	ffffa097          	auipc	ra,0xffffa
    800068c4:	ca0080e7          	jalr	-864(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    800068c8:	00002517          	auipc	a0,0x2
    800068cc:	dd850513          	addi	a0,a0,-552 # 800086a0 <etext+0x6a0>
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	c90080e7          	jalr	-880(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800068d8:	00002517          	auipc	a0,0x2
    800068dc:	de850513          	addi	a0,a0,-536 # 800086c0 <etext+0x6c0>
    800068e0:	ffffa097          	auipc	ra,0xffffa
    800068e4:	c80080e7          	jalr	-896(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800068e8:	00002517          	auipc	a0,0x2
    800068ec:	df850513          	addi	a0,a0,-520 # 800086e0 <etext+0x6e0>
    800068f0:	ffffa097          	auipc	ra,0xffffa
    800068f4:	c70080e7          	jalr	-912(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800068f8:	00002517          	auipc	a0,0x2
    800068fc:	e0850513          	addi	a0,a0,-504 # 80008700 <etext+0x700>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	c60080e7          	jalr	-928(ra) # 80000560 <panic>

0000000080006908 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006908:	711d                	addi	sp,sp,-96
    8000690a:	ec86                	sd	ra,88(sp)
    8000690c:	e8a2                	sd	s0,80(sp)
    8000690e:	e4a6                	sd	s1,72(sp)
    80006910:	e0ca                	sd	s2,64(sp)
    80006912:	fc4e                	sd	s3,56(sp)
    80006914:	f852                	sd	s4,48(sp)
    80006916:	f456                	sd	s5,40(sp)
    80006918:	f05a                	sd	s6,32(sp)
    8000691a:	ec5e                	sd	s7,24(sp)
    8000691c:	e862                	sd	s8,16(sp)
    8000691e:	1080                	addi	s0,sp,96
    80006920:	89aa                	mv	s3,a0
    80006922:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006924:	00c52b83          	lw	s7,12(a0)
    80006928:	001b9b9b          	slliw	s7,s7,0x1
    8000692c:	1b82                	slli	s7,s7,0x20
    8000692e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006932:	00023517          	auipc	a0,0x23
    80006936:	64650513          	addi	a0,a0,1606 # 80029f78 <disk+0x128>
    8000693a:	ffffa097          	auipc	ra,0xffffa
    8000693e:	304080e7          	jalr	772(ra) # 80000c3e <acquire>
  for(int i = 0; i < NUM; i++){
    80006942:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006944:	00023a97          	auipc	s5,0x23
    80006948:	50ca8a93          	addi	s5,s5,1292 # 80029e50 <disk>
  for(int i = 0; i < 3; i++){
    8000694c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    8000694e:	5c7d                	li	s8,-1
    80006950:	a885                	j	800069c0 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006952:	00fa8733          	add	a4,s5,a5
    80006956:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000695a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000695c:	0207c563          	bltz	a5,80006986 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    80006960:	2905                	addiw	s2,s2,1
    80006962:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006964:	07490263          	beq	s2,s4,800069c8 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    80006968:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000696a:	00023717          	auipc	a4,0x23
    8000696e:	4e670713          	addi	a4,a4,1254 # 80029e50 <disk>
    80006972:	4781                	li	a5,0
    if(disk.free[i]){
    80006974:	01874683          	lbu	a3,24(a4)
    80006978:	fee9                	bnez	a3,80006952 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    8000697a:	2785                	addiw	a5,a5,1
    8000697c:	0705                	addi	a4,a4,1
    8000697e:	fe979be3          	bne	a5,s1,80006974 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80006982:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80006986:	03205163          	blez	s2,800069a8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000698a:	fa042503          	lw	a0,-96(s0)
    8000698e:	00000097          	auipc	ra,0x0
    80006992:	cfc080e7          	jalr	-772(ra) # 8000668a <free_desc>
      for(int j = 0; j < i; j++)
    80006996:	4785                	li	a5,1
    80006998:	0127d863          	bge	a5,s2,800069a8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000699c:	fa442503          	lw	a0,-92(s0)
    800069a0:	00000097          	auipc	ra,0x0
    800069a4:	cea080e7          	jalr	-790(ra) # 8000668a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069a8:	00023597          	auipc	a1,0x23
    800069ac:	5d058593          	addi	a1,a1,1488 # 80029f78 <disk+0x128>
    800069b0:	00023517          	auipc	a0,0x23
    800069b4:	4b850513          	addi	a0,a0,1208 # 80029e68 <disk+0x18>
    800069b8:	ffffc097          	auipc	ra,0xffffc
    800069bc:	b6a080e7          	jalr	-1174(ra) # 80002522 <sleep>
  for(int i = 0; i < 3; i++){
    800069c0:	fa040613          	addi	a2,s0,-96
    800069c4:	4901                	li	s2,0
    800069c6:	b74d                	j	80006968 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069c8:	fa042503          	lw	a0,-96(s0)
    800069cc:	00451693          	slli	a3,a0,0x4

  if(write)
    800069d0:	00023797          	auipc	a5,0x23
    800069d4:	48078793          	addi	a5,a5,1152 # 80029e50 <disk>
    800069d8:	00a50713          	addi	a4,a0,10
    800069dc:	0712                	slli	a4,a4,0x4
    800069de:	973e                	add	a4,a4,a5
    800069e0:	01603633          	snez	a2,s6
    800069e4:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800069e6:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800069ea:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800069ee:	6398                	ld	a4,0(a5)
    800069f0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069f2:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800069f6:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800069f8:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800069fa:	6390                	ld	a2,0(a5)
    800069fc:	00d605b3          	add	a1,a2,a3
    80006a00:	4741                	li	a4,16
    80006a02:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a04:	4805                	li	a6,1
    80006a06:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006a0a:	fa442703          	lw	a4,-92(s0)
    80006a0e:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a12:	0712                	slli	a4,a4,0x4
    80006a14:	963a                	add	a2,a2,a4
    80006a16:	05898593          	addi	a1,s3,88
    80006a1a:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006a1c:	0007b883          	ld	a7,0(a5)
    80006a20:	9746                	add	a4,a4,a7
    80006a22:	40000613          	li	a2,1024
    80006a26:	c710                	sw	a2,8(a4)
  if(write)
    80006a28:	001b3613          	seqz	a2,s6
    80006a2c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a30:	01066633          	or	a2,a2,a6
    80006a34:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006a38:	fa842583          	lw	a1,-88(s0)
    80006a3c:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a40:	00250613          	addi	a2,a0,2
    80006a44:	0612                	slli	a2,a2,0x4
    80006a46:	963e                	add	a2,a2,a5
    80006a48:	577d                	li	a4,-1
    80006a4a:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006a4e:	0592                	slli	a1,a1,0x4
    80006a50:	98ae                	add	a7,a7,a1
    80006a52:	03068713          	addi	a4,a3,48
    80006a56:	973e                	add	a4,a4,a5
    80006a58:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006a5c:	6398                	ld	a4,0(a5)
    80006a5e:	972e                	add	a4,a4,a1
    80006a60:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a64:	4689                	li	a3,2
    80006a66:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006a6a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a6e:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80006a72:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006a76:	6794                	ld	a3,8(a5)
    80006a78:	0026d703          	lhu	a4,2(a3)
    80006a7c:	8b1d                	andi	a4,a4,7
    80006a7e:	0706                	slli	a4,a4,0x1
    80006a80:	96ba                	add	a3,a3,a4
    80006a82:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006a86:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006a8a:	6798                	ld	a4,8(a5)
    80006a8c:	00275783          	lhu	a5,2(a4)
    80006a90:	2785                	addiw	a5,a5,1
    80006a92:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006a96:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a9a:	100017b7          	lui	a5,0x10001
    80006a9e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006aa2:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006aa6:	00023917          	auipc	s2,0x23
    80006aaa:	4d290913          	addi	s2,s2,1234 # 80029f78 <disk+0x128>
  while(b->disk == 1) {
    80006aae:	84c2                	mv	s1,a6
    80006ab0:	01079c63          	bne	a5,a6,80006ac8 <virtio_disk_rw+0x1c0>
    sleep(b, &disk.vdisk_lock);
    80006ab4:	85ca                	mv	a1,s2
    80006ab6:	854e                	mv	a0,s3
    80006ab8:	ffffc097          	auipc	ra,0xffffc
    80006abc:	a6a080e7          	jalr	-1430(ra) # 80002522 <sleep>
  while(b->disk == 1) {
    80006ac0:	0049a783          	lw	a5,4(s3)
    80006ac4:	fe9788e3          	beq	a5,s1,80006ab4 <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80006ac8:	fa042903          	lw	s2,-96(s0)
    80006acc:	00290713          	addi	a4,s2,2
    80006ad0:	0712                	slli	a4,a4,0x4
    80006ad2:	00023797          	auipc	a5,0x23
    80006ad6:	37e78793          	addi	a5,a5,894 # 80029e50 <disk>
    80006ada:	97ba                	add	a5,a5,a4
    80006adc:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006ae0:	00023997          	auipc	s3,0x23
    80006ae4:	37098993          	addi	s3,s3,880 # 80029e50 <disk>
    80006ae8:	00491713          	slli	a4,s2,0x4
    80006aec:	0009b783          	ld	a5,0(s3)
    80006af0:	97ba                	add	a5,a5,a4
    80006af2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006af6:	854a                	mv	a0,s2
    80006af8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006afc:	00000097          	auipc	ra,0x0
    80006b00:	b8e080e7          	jalr	-1138(ra) # 8000668a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b04:	8885                	andi	s1,s1,1
    80006b06:	f0ed                	bnez	s1,80006ae8 <virtio_disk_rw+0x1e0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b08:	00023517          	auipc	a0,0x23
    80006b0c:	47050513          	addi	a0,a0,1136 # 80029f78 <disk+0x128>
    80006b10:	ffffa097          	auipc	ra,0xffffa
    80006b14:	1de080e7          	jalr	478(ra) # 80000cee <release>
}
    80006b18:	60e6                	ld	ra,88(sp)
    80006b1a:	6446                	ld	s0,80(sp)
    80006b1c:	64a6                	ld	s1,72(sp)
    80006b1e:	6906                	ld	s2,64(sp)
    80006b20:	79e2                	ld	s3,56(sp)
    80006b22:	7a42                	ld	s4,48(sp)
    80006b24:	7aa2                	ld	s5,40(sp)
    80006b26:	7b02                	ld	s6,32(sp)
    80006b28:	6be2                	ld	s7,24(sp)
    80006b2a:	6c42                	ld	s8,16(sp)
    80006b2c:	6125                	addi	sp,sp,96
    80006b2e:	8082                	ret

0000000080006b30 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006b30:	1101                	addi	sp,sp,-32
    80006b32:	ec06                	sd	ra,24(sp)
    80006b34:	e822                	sd	s0,16(sp)
    80006b36:	e426                	sd	s1,8(sp)
    80006b38:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b3a:	00023497          	auipc	s1,0x23
    80006b3e:	31648493          	addi	s1,s1,790 # 80029e50 <disk>
    80006b42:	00023517          	auipc	a0,0x23
    80006b46:	43650513          	addi	a0,a0,1078 # 80029f78 <disk+0x128>
    80006b4a:	ffffa097          	auipc	ra,0xffffa
    80006b4e:	0f4080e7          	jalr	244(ra) # 80000c3e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006b52:	100017b7          	lui	a5,0x10001
    80006b56:	53bc                	lw	a5,96(a5)
    80006b58:	8b8d                	andi	a5,a5,3
    80006b5a:	10001737          	lui	a4,0x10001
    80006b5e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006b60:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006b64:	689c                	ld	a5,16(s1)
    80006b66:	0204d703          	lhu	a4,32(s1)
    80006b6a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006b6e:	04f70863          	beq	a4,a5,80006bbe <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006b72:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006b76:	6898                	ld	a4,16(s1)
    80006b78:	0204d783          	lhu	a5,32(s1)
    80006b7c:	8b9d                	andi	a5,a5,7
    80006b7e:	078e                	slli	a5,a5,0x3
    80006b80:	97ba                	add	a5,a5,a4
    80006b82:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006b84:	00278713          	addi	a4,a5,2
    80006b88:	0712                	slli	a4,a4,0x4
    80006b8a:	9726                	add	a4,a4,s1
    80006b8c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006b90:	e721                	bnez	a4,80006bd8 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006b92:	0789                	addi	a5,a5,2
    80006b94:	0792                	slli	a5,a5,0x4
    80006b96:	97a6                	add	a5,a5,s1
    80006b98:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006b9a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006b9e:	ffffc097          	auipc	ra,0xffffc
    80006ba2:	9e8080e7          	jalr	-1560(ra) # 80002586 <wakeup>

    disk.used_idx += 1;
    80006ba6:	0204d783          	lhu	a5,32(s1)
    80006baa:	2785                	addiw	a5,a5,1
    80006bac:	17c2                	slli	a5,a5,0x30
    80006bae:	93c1                	srli	a5,a5,0x30
    80006bb0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006bb4:	6898                	ld	a4,16(s1)
    80006bb6:	00275703          	lhu	a4,2(a4)
    80006bba:	faf71ce3          	bne	a4,a5,80006b72 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006bbe:	00023517          	auipc	a0,0x23
    80006bc2:	3ba50513          	addi	a0,a0,954 # 80029f78 <disk+0x128>
    80006bc6:	ffffa097          	auipc	ra,0xffffa
    80006bca:	128080e7          	jalr	296(ra) # 80000cee <release>
}
    80006bce:	60e2                	ld	ra,24(sp)
    80006bd0:	6442                	ld	s0,16(sp)
    80006bd2:	64a2                	ld	s1,8(sp)
    80006bd4:	6105                	addi	sp,sp,32
    80006bd6:	8082                	ret
      panic("virtio_disk_intr status");
    80006bd8:	00002517          	auipc	a0,0x2
    80006bdc:	b4050513          	addi	a0,a0,-1216 # 80008718 <etext+0x718>
    80006be0:	ffffa097          	auipc	ra,0xffffa
    80006be4:	980080e7          	jalr	-1664(ra) # 80000560 <panic>
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
