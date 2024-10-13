
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a4010113          	addi	sp,sp,-1472 # 80008a40 <stack0>
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
    80000054:	8b078793          	addi	a5,a5,-1872 # 80008900 <timer_scratch>
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
    80000066:	71e78793          	addi	a5,a5,1822 # 80006780 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd487f>
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
    80000138:	a22080e7          	jalr	-1502(ra) # 80002b56 <either_copyin>
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
    800001a0:	8a450513          	addi	a0,a0,-1884 # 80010a40 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	a9a080e7          	jalr	-1382(ra) # 80000c3e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	89448493          	addi	s1,s1,-1900 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011917          	auipc	s2,0x11
    800001b8:	92490913          	addi	s2,s2,-1756 # 80010ad8 <cons+0x98>
  while(n > 0){
    800001bc:	0d305563          	blez	s3,80000286 <consoleread+0x106>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	0af71a63          	bne	a4,a5,8000027c <consoleread+0xfc>
      if(killed(myproc())){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	a2a080e7          	jalr	-1494(ra) # 80001bf6 <myproc>
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	7b0080e7          	jalr	1968(ra) # 80002984 <killed>
    800001dc:	e52d                	bnez	a0,80000246 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	4d2080e7          	jalr	1234(ra) # 800026b4 <sleep>
    while(cons.r == cons.w){
    800001ea:	0984a783          	lw	a5,152(s1)
    800001ee:	09c4a703          	lw	a4,156(s1)
    800001f2:	fcf70de3          	beq	a4,a5,800001cc <consoleread+0x4c>
    800001f6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f8:	00011717          	auipc	a4,0x11
    800001fc:	84870713          	addi	a4,a4,-1976 # 80010a40 <cons>
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
    8000022e:	8d4080e7          	jalr	-1836(ra) # 80002afe <either_copyout>
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
    80000246:	00010517          	auipc	a0,0x10
    8000024a:	7fa50513          	addi	a0,a0,2042 # 80010a40 <cons>
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
    80000274:	86f72423          	sw	a5,-1944(a4) # 80010ad8 <cons+0x98>
    80000278:	6be2                	ld	s7,24(sp)
    8000027a:	a031                	j	80000286 <consoleread+0x106>
    8000027c:	ec5e                	sd	s7,24(sp)
    8000027e:	bfad                	j	800001f8 <consoleread+0x78>
    80000280:	6be2                	ld	s7,24(sp)
    80000282:	a011                	j	80000286 <consoleread+0x106>
    80000284:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000286:	00010517          	auipc	a0,0x10
    8000028a:	7ba50513          	addi	a0,a0,1978 # 80010a40 <cons>
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
    800002f2:	75250513          	addi	a0,a0,1874 # 80010a40 <cons>
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
    80000314:	00003097          	auipc	ra,0x3
    80000318:	89a080e7          	jalr	-1894(ra) # 80002bae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031c:	00010517          	auipc	a0,0x10
    80000320:	72450513          	addi	a0,a0,1828 # 80010a40 <cons>
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
    80000342:	70270713          	addi	a4,a4,1794 # 80010a40 <cons>
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
    8000036c:	6d878793          	addi	a5,a5,1752 # 80010a40 <cons>
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
    80000398:	7447a783          	lw	a5,1860(a5) # 80010ad8 <cons+0x98>
    8000039c:	9f1d                	subw	a4,a4,a5
    8000039e:	08000793          	li	a5,128
    800003a2:	f6f71de3          	bne	a4,a5,8000031c <consoleintr+0x3a>
    800003a6:	a0c9                	j	80000468 <consoleintr+0x186>
    800003a8:	e84a                	sd	s2,16(sp)
    800003aa:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    800003ac:	00010717          	auipc	a4,0x10
    800003b0:	69470713          	addi	a4,a4,1684 # 80010a40 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	00010497          	auipc	s1,0x10
    800003c0:	68448493          	addi	s1,s1,1668 # 80010a40 <cons>
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
    8000040e:	63670713          	addi	a4,a4,1590 # 80010a40 <cons>
    80000412:	0a072783          	lw	a5,160(a4)
    80000416:	09c72703          	lw	a4,156(a4)
    8000041a:	f0f701e3          	beq	a4,a5,8000031c <consoleintr+0x3a>
      cons.e--;
    8000041e:	37fd                	addiw	a5,a5,-1
    80000420:	00010717          	auipc	a4,0x10
    80000424:	6cf72023          	sw	a5,1728(a4) # 80010ae0 <cons+0xa0>
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
    8000044a:	5fa78793          	addi	a5,a5,1530 # 80010a40 <cons>
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
    8000046c:	66c7aa23          	sw	a2,1652(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00010517          	auipc	a0,0x10
    80000474:	66850513          	addi	a0,a0,1640 # 80010ad8 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	2a0080e7          	jalr	672(ra) # 80002718 <wakeup>
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
    80000496:	5ae50513          	addi	a0,a0,1454 # 80010a40 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	710080e7          	jalr	1808(ra) # 80000baa <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	344080e7          	jalr	836(ra) # 800007e6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00029797          	auipc	a5,0x29
    800004ae:	93e78793          	addi	a5,a5,-1730 # 80028de8 <devsw>
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
    800004ee:	23e80813          	addi	a6,a6,574 # 80008728 <digits>
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
    80000570:	5807aa23          	sw	zero,1428(a5) # 80010b00 <pr+0x18>
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
    800005a4:	32f72023          	sw	a5,800(a4) # 800088c0 <panicked>
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
    800005ce:	536dad83          	lw	s11,1334(s11) # 80010b00 <pr+0x18>
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
    80000610:	11ca8a93          	addi	s5,s5,284 # 80008728 <digits>
    switch(c){
    80000614:	07300c13          	li	s8,115
    80000618:	a0b9                	j	80000666 <printf+0xbc>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	4ce50513          	addi	a0,a0,1230 # 80010ae8 <pr>
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
    800007a6:	34650513          	addi	a0,a0,838 # 80010ae8 <pr>
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
    800007c2:	32a48493          	addi	s1,s1,810 # 80010ae8 <pr>
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
    8000082c:	2e050513          	addi	a0,a0,736 # 80010b08 <uart_tx_lock>
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
    80000858:	06c7a783          	lw	a5,108(a5) # 800088c0 <panicked>
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
    80000892:	03a7b783          	ld	a5,58(a5) # 800088c8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	03a73703          	ld	a4,58(a4) # 800088d0 <uart_tx_w>
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
    800008c0:	24ca8a93          	addi	s5,s5,588 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	00448493          	addi	s1,s1,4 # 800088c8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	00098993          	mv	s3,s3
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
    800008f6:	e26080e7          	jalr	-474(ra) # 80002718 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3) # 800088d0 <uart_tx_w>
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
    80000934:	1d850513          	addi	a0,a0,472 # 80010b08 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	306080e7          	jalr	774(ra) # 80000c3e <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	f807a783          	lw	a5,-128(a5) # 800088c0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	f8673703          	ld	a4,-122(a4) # 800088d0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	f767b783          	ld	a5,-138(a5) # 800088c8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	1aa98993          	addi	s3,s3,426 # 80010b08 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	f6248493          	addi	s1,s1,-158 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	f6290913          	addi	s2,s2,-158 # 800088d0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	d36080e7          	jalr	-714(ra) # 800026b4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	17448493          	addi	s1,s1,372 # 80010b08 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f2e7b423          	sd	a4,-216(a5) # 800088d0 <uart_tx_w>
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
    80000a22:	0ea48493          	addi	s1,s1,234 # 80010b08 <uart_tx_lock>
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
    80000a64:	52078793          	addi	a5,a5,1312 # 80029f80 <end>
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
    80000a84:	0c090913          	addi	s2,s2,192 # 80010b40 <kmem>
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
    80000b22:	02250513          	addi	a0,a0,34 # 80010b40 <kmem>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	084080e7          	jalr	132(ra) # 80000baa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2e:	45c5                	li	a1,17
    80000b30:	05ee                	slli	a1,a1,0x1b
    80000b32:	00029517          	auipc	a0,0x29
    80000b36:	44e50513          	addi	a0,a0,1102 # 80029f80 <end>
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
    80000b58:	fec48493          	addi	s1,s1,-20 # 80010b40 <kmem>
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
    80000b70:	fd450513          	addi	a0,a0,-44 # 80010b40 <kmem>
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
    80000b9c:	fa850513          	addi	a0,a0,-88 # 80010b40 <kmem>
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
    80000bdc:	ffe080e7          	jalr	-2(ra) # 80001bd6 <mycpu>
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
    80000c0e:	fcc080e7          	jalr	-52(ra) # 80001bd6 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	cf89                	beqz	a5,80000c2e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c16:	00001097          	auipc	ra,0x1
    80000c1a:	fc0080e7          	jalr	-64(ra) # 80001bd6 <mycpu>
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
    80000c32:	fa8080e7          	jalr	-88(ra) # 80001bd6 <mycpu>
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
    80000c72:	f68080e7          	jalr	-152(ra) # 80001bd6 <mycpu>
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
    80000c9e:	f3c080e7          	jalr	-196(ra) # 80001bd6 <mycpu>
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
    80000db4:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5081>
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
    80000efc:	cca080e7          	jalr	-822(ra) # 80001bc2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f00:	00008717          	auipc	a4,0x8
    80000f04:	9d870713          	addi	a4,a4,-1576 # 800088d8 <started>
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
    80000f18:	cae080e7          	jalr	-850(ra) # 80001bc2 <cpuid>
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
    80000f3a:	f5e080e7          	jalr	-162(ra) # 80002e94 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f3e:	00006097          	auipc	ra,0x6
    80000f42:	886080e7          	jalr	-1914(ra) # 800067c4 <plicinithart>
  }

  scheduler();        
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	64c080e7          	jalr	1612(ra) # 80002592 <scheduler>
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
    80000faa:	b56080e7          	jalr	-1194(ra) # 80001afc <procinit>
    trapinit();      // trap vectors
    80000fae:	00002097          	auipc	ra,0x2
    80000fb2:	ebe080e7          	jalr	-322(ra) # 80002e6c <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb6:	00002097          	auipc	ra,0x2
    80000fba:	ede080e7          	jalr	-290(ra) # 80002e94 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fbe:	00005097          	auipc	ra,0x5
    80000fc2:	7ec080e7          	jalr	2028(ra) # 800067aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc6:	00005097          	auipc	ra,0x5
    80000fca:	7fe080e7          	jalr	2046(ra) # 800067c4 <plicinithart>
    binit();         // buffer cache
    80000fce:	00003097          	auipc	ra,0x3
    80000fd2:	874080e7          	jalr	-1932(ra) # 80003842 <binit>
    iinit();         // inode table
    80000fd6:	00003097          	auipc	ra,0x3
    80000fda:	f04080e7          	jalr	-252(ra) # 80003eda <iinit>
    fileinit();      // file table
    80000fde:	00004097          	auipc	ra,0x4
    80000fe2:	ed6080e7          	jalr	-298(ra) # 80004eb4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe6:	00006097          	auipc	ra,0x6
    80000fea:	8e6080e7          	jalr	-1818(ra) # 800068cc <virtio_disk_init>
    userinit();      // first user process
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	f3c080e7          	jalr	-196(ra) # 80001f2a <userinit>
    __sync_synchronize();
    80000ff6:	0330000f          	fence	rw,rw
    started = 1;
    80000ffa:	4785                	li	a5,1
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	8cf72e23          	sw	a5,-1828(a4) # 800088d8 <started>
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
    80001016:	8ce7b783          	ld	a5,-1842(a5) # 800088e0 <kernel_pagetable>
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
    800012d4:	60a7b823          	sd	a0,1552(a5) # 800088e0 <kernel_pagetable>
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
    800018ac:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5080>
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
    800018ec:	eb848493          	addi	s1,s1,-328 # 800117a0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018f0:	8c26                	mv	s8,s1
    800018f2:	8c1357b7          	lui	a5,0x8c135
    800018f6:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b29d>
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
    80001916:	28ea8a93          	addi	s5,s5,654 # 8001eba0 <tickslock>
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
    80001984:	ee868693          	addi	a3,a3,-280 # 80008868 <seed.2>
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

00000000800019be <Enqueue>:

void Enqueue(struct proc *p, int priority)
{
    800019be:	1141                	addi	sp,sp,-16
    800019c0:	e406                	sd	ra,8(sp)
    800019c2:	e022                	sd	s0,0(sp)
    800019c4:	0800                	addi	s0,sp,16
  if (!p || priority < 0 || priority >= 4)
    800019c6:	c921                	beqz	a0,80001a16 <Enqueue+0x58>
    800019c8:	478d                	li	a5,3
    800019ca:	04b7e663          	bltu	a5,a1,80001a16 <Enqueue+0x58>
    return;
  p->ticks = 0;
    800019ce:	0e052023          	sw	zero,224(a0)
  if (queues_sizes[priority] < NPROC)
    800019d2:	00259713          	slli	a4,a1,0x2
    800019d6:	0000f797          	auipc	a5,0xf
    800019da:	18a78793          	addi	a5,a5,394 # 80010b60 <queues_sizes>
    800019de:	97ba                	add	a5,a5,a4
    800019e0:	4398                	lw	a4,0(a5)
    800019e2:	03f00793          	li	a5,63
    800019e6:	02e7c863          	blt	a5,a4,80001a16 <Enqueue+0x58>
  {
    mlfq[priority][queues_sizes[priority]++] = p;
    800019ea:	00259693          	slli	a3,a1,0x2
    800019ee:	0000f797          	auipc	a5,0xf
    800019f2:	17278793          	addi	a5,a5,370 # 80010b60 <queues_sizes>
    800019f6:	97b6                	add	a5,a5,a3
    800019f8:	0017069b          	addiw	a3,a4,1
    800019fc:	c394                	sw	a3,0(a5)
    800019fe:	00659793          	slli	a5,a1,0x6
    80001a02:	97ba                	add	a5,a5,a4
    80001a04:	078e                	slli	a5,a5,0x3
    80001a06:	0000f717          	auipc	a4,0xf
    80001a0a:	59a70713          	addi	a4,a4,1434 # 80010fa0 <mlfq>
    80001a0e:	97ba                	add	a5,a5,a4
    80001a10:	e388                	sd	a0,0(a5)
    p->priority = priority;
    80001a12:	0cb52c23          	sw	a1,216(a0)
  }
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret

0000000080001a1e <dequeue>:

struct proc *dequeue(int priority)
{
    80001a1e:	1141                	addi	sp,sp,-16
    80001a20:	e406                	sd	ra,8(sp)
    80001a22:	e022                	sd	s0,0(sp)
    80001a24:	0800                	addi	s0,sp,16
  if (priority < 0 || priority >= 4 || queues_sizes[priority] == 0)
    80001a26:	478d                	li	a5,3
    80001a28:	08a7e663          	bltu	a5,a0,80001ab4 <dequeue+0x96>
    80001a2c:	872a                	mv	a4,a0
    80001a2e:	00251693          	slli	a3,a0,0x2
    80001a32:	0000f797          	auipc	a5,0xf
    80001a36:	12e78793          	addi	a5,a5,302 # 80010b60 <queues_sizes>
    80001a3a:	97b6                	add	a5,a5,a3
    80001a3c:	438c                	lw	a1,0(a5)
    80001a3e:	cdad                	beqz	a1,80001ab8 <dequeue+0x9a>
    return 0;

  struct proc *p = mlfq[priority][0];
    80001a40:	00951693          	slli	a3,a0,0x9
    80001a44:	0000f797          	auipc	a5,0xf
    80001a48:	55c78793          	addi	a5,a5,1372 # 80010fa0 <mlfq>
    80001a4c:	97b6                	add	a5,a5,a3
    80001a4e:	6388                	ld	a0,0(a5)
  for (int i = 1; i < queues_sizes[priority]; i++)
    80001a50:	4785                	li	a5,1
    80001a52:	02b7da63          	bge	a5,a1,80001a86 <dequeue+0x68>
    80001a56:	87b6                	mv	a5,a3
    80001a58:	0000f697          	auipc	a3,0xf
    80001a5c:	54868693          	addi	a3,a3,1352 # 80010fa0 <mlfq>
    80001a60:	97b6                	add	a5,a5,a3
    80001a62:	00671613          	slli	a2,a4,0x6
    80001a66:	ffe5869b          	addiw	a3,a1,-2
    80001a6a:	1682                	slli	a3,a3,0x20
    80001a6c:	9281                	srli	a3,a3,0x20
    80001a6e:	9636                	add	a2,a2,a3
    80001a70:	060e                	slli	a2,a2,0x3
    80001a72:	0000f697          	auipc	a3,0xf
    80001a76:	53668693          	addi	a3,a3,1334 # 80010fa8 <mlfq+0x8>
    80001a7a:	9636                	add	a2,a2,a3
  {
    mlfq[priority][i - 1] = mlfq[priority][i];
    80001a7c:	6794                	ld	a3,8(a5)
    80001a7e:	e394                	sd	a3,0(a5)
  for (int i = 1; i < queues_sizes[priority]; i++)
    80001a80:	07a1                	addi	a5,a5,8
    80001a82:	fec79de3          	bne	a5,a2,80001a7c <dequeue+0x5e>
  }
  queues_sizes[priority]--;
    80001a86:	35fd                	addiw	a1,a1,-1
    80001a88:	00271693          	slli	a3,a4,0x2
    80001a8c:	0000f797          	auipc	a5,0xf
    80001a90:	0d478793          	addi	a5,a5,212 # 80010b60 <queues_sizes>
    80001a94:	97b6                	add	a5,a5,a3
    80001a96:	c38c                	sw	a1,0(a5)
  mlfq[priority][queues_sizes[priority]] = 0;
    80001a98:	071a                	slli	a4,a4,0x6
    80001a9a:	972e                	add	a4,a4,a1
    80001a9c:	070e                	slli	a4,a4,0x3
    80001a9e:	0000f797          	auipc	a5,0xf
    80001aa2:	50278793          	addi	a5,a5,1282 # 80010fa0 <mlfq>
    80001aa6:	97ba                	add	a5,a5,a4
    80001aa8:	0007b023          	sd	zero,0(a5)
  return p;
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret
    return 0;
    80001ab4:	4501                	li	a0,0
    80001ab6:	bfdd                	j	80001aac <dequeue+0x8e>
    80001ab8:	4501                	li	a0,0
    80001aba:	bfcd                	j	80001aac <dequeue+0x8e>

0000000080001abc <initialize>:

void initialize()
{
    80001abc:	1141                	addi	sp,sp,-16
    80001abe:	e406                	sd	ra,8(sp)
    80001ac0:	e022                	sd	s0,0(sp)
    80001ac2:	0800                	addi	s0,sp,16
  //   for (int j = 0; j < queues_sizes[i]; j++)
  //   {
  //     mlfq[i][j] = 0;
  //   }
  // }
  memset(mlfq, 0, sizeof(mlfq));
    80001ac4:	6605                	lui	a2,0x1
    80001ac6:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001aca:	4581                	li	a1,0
    80001acc:	0000f517          	auipc	a0,0xf
    80001ad0:	4d450513          	addi	a0,a0,1236 # 80010fa0 <mlfq>
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	262080e7          	jalr	610(ra) # 80000d36 <memset>
  for (int i = 0; i < 4; i++)
    queues_sizes[i] = 0;
    80001adc:	0000f797          	auipc	a5,0xf
    80001ae0:	08478793          	addi	a5,a5,132 # 80010b60 <queues_sizes>
    80001ae4:	0007a023          	sw	zero,0(a5)
    80001ae8:	0007a223          	sw	zero,4(a5)
    80001aec:	0007a423          	sw	zero,8(a5)
    80001af0:	0007a623          	sw	zero,12(a5)
}
    80001af4:	60a2                	ld	ra,8(sp)
    80001af6:	6402                	ld	s0,0(sp)
    80001af8:	0141                	addi	sp,sp,16
    80001afa:	8082                	ret

0000000080001afc <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001afc:	7139                	addi	sp,sp,-64
    80001afe:	fc06                	sd	ra,56(sp)
    80001b00:	f822                	sd	s0,48(sp)
    80001b02:	f426                	sd	s1,40(sp)
    80001b04:	f04a                	sd	s2,32(sp)
    80001b06:	ec4e                	sd	s3,24(sp)
    80001b08:	e852                	sd	s4,16(sp)
    80001b0a:	e456                	sd	s5,8(sp)
    80001b0c:	e05a                	sd	s6,0(sp)
    80001b0e:	0080                	addi	s0,sp,64
  struct proc *p;
  boost_ticks = 0;
    80001b10:	00007797          	auipc	a5,0x7
    80001b14:	de07a023          	sw	zero,-544(a5) # 800088f0 <boost_ticks>
  // boost_ticks=ticks;
  initlock(&pid_lock, "nextpid");
    80001b18:	00006597          	auipc	a1,0x6
    80001b1c:	6a858593          	addi	a1,a1,1704 # 800081c0 <etext+0x1c0>
    80001b20:	0000f517          	auipc	a0,0xf
    80001b24:	05050513          	addi	a0,a0,80 # 80010b70 <pid_lock>
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	082080e7          	jalr	130(ra) # 80000baa <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b30:	00006597          	auipc	a1,0x6
    80001b34:	69858593          	addi	a1,a1,1688 # 800081c8 <etext+0x1c8>
    80001b38:	0000f517          	auipc	a0,0xf
    80001b3c:	05050513          	addi	a0,a0,80 # 80010b88 <wait_lock>
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	06a080e7          	jalr	106(ra) # 80000baa <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001b48:	00010497          	auipc	s1,0x10
    80001b4c:	c5848493          	addi	s1,s1,-936 # 800117a0 <proc>
  {
    initlock(&p->lock, "proc");
    80001b50:	00006b17          	auipc	s6,0x6
    80001b54:	688b0b13          	addi	s6,s6,1672 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001b58:	8aa6                	mv	s5,s1
    80001b5a:	8c1357b7          	lui	a5,0x8c135
    80001b5e:	21d78793          	addi	a5,a5,541 # ffffffff8c13521d <end+0xffffffff0c10b29d>
    80001b62:	21cfb937          	lui	s2,0x21cfb
    80001b66:	2b890913          	addi	s2,s2,696 # 21cfb2b8 <_entry-0x5e304d48>
    80001b6a:	1902                	slli	s2,s2,0x20
    80001b6c:	993e                	add	s2,s2,a5
    80001b6e:	040009b7          	lui	s3,0x4000
    80001b72:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b74:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b76:	0001da17          	auipc	s4,0x1d
    80001b7a:	02aa0a13          	addi	s4,s4,42 # 8001eba0 <tickslock>
    initlock(&p->lock, "proc");
    80001b7e:	85da                	mv	a1,s6
    80001b80:	8526                	mv	a0,s1
    80001b82:	fffff097          	auipc	ra,0xfffff
    80001b86:	028080e7          	jalr	40(ra) # 80000baa <initlock>
    p->state = UNUSED;
    80001b8a:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001b8e:	415487b3          	sub	a5,s1,s5
    80001b92:	8791                	srai	a5,a5,0x4
    80001b94:	032787b3          	mul	a5,a5,s2
    80001b98:	2785                	addiw	a5,a5,1
    80001b9a:	00d7979b          	slliw	a5,a5,0xd
    80001b9e:	40f987b3          	sub	a5,s3,a5
    80001ba2:	20f4bc23          	sd	a5,536(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ba6:	35048493          	addi	s1,s1,848
    80001baa:	fd449ae3          	bne	s1,s4,80001b7e <procinit+0x82>
  }
}
    80001bae:	70e2                	ld	ra,56(sp)
    80001bb0:	7442                	ld	s0,48(sp)
    80001bb2:	74a2                	ld	s1,40(sp)
    80001bb4:	7902                	ld	s2,32(sp)
    80001bb6:	69e2                	ld	s3,24(sp)
    80001bb8:	6a42                	ld	s4,16(sp)
    80001bba:	6aa2                	ld	s5,8(sp)
    80001bbc:	6b02                	ld	s6,0(sp)
    80001bbe:	6121                	addi	sp,sp,64
    80001bc0:	8082                	ret

0000000080001bc2 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001bc2:	1141                	addi	sp,sp,-16
    80001bc4:	e406                	sd	ra,8(sp)
    80001bc6:	e022                	sd	s0,0(sp)
    80001bc8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bca:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001bcc:	2501                	sext.w	a0,a0
    80001bce:	60a2                	ld	ra,8(sp)
    80001bd0:	6402                	ld	s0,0(sp)
    80001bd2:	0141                	addi	sp,sp,16
    80001bd4:	8082                	ret

0000000080001bd6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001bd6:	1141                	addi	sp,sp,-16
    80001bd8:	e406                	sd	ra,8(sp)
    80001bda:	e022                	sd	s0,0(sp)
    80001bdc:	0800                	addi	s0,sp,16
    80001bde:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001be0:	2781                	sext.w	a5,a5
    80001be2:	079e                	slli	a5,a5,0x7
  return c;
}
    80001be4:	0000f517          	auipc	a0,0xf
    80001be8:	fbc50513          	addi	a0,a0,-68 # 80010ba0 <cpus>
    80001bec:	953e                	add	a0,a0,a5
    80001bee:	60a2                	ld	ra,8(sp)
    80001bf0:	6402                	ld	s0,0(sp)
    80001bf2:	0141                	addi	sp,sp,16
    80001bf4:	8082                	ret

0000000080001bf6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001bf6:	1101                	addi	sp,sp,-32
    80001bf8:	ec06                	sd	ra,24(sp)
    80001bfa:	e822                	sd	s0,16(sp)
    80001bfc:	e426                	sd	s1,8(sp)
    80001bfe:	1000                	addi	s0,sp,32
  push_off();
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	ff2080e7          	jalr	-14(ra) # 80000bf2 <push_off>
    80001c08:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c0a:	2781                	sext.w	a5,a5
    80001c0c:	079e                	slli	a5,a5,0x7
    80001c0e:	0000f717          	auipc	a4,0xf
    80001c12:	f5270713          	addi	a4,a4,-174 # 80010b60 <queues_sizes>
    80001c16:	97ba                	add	a5,a5,a4
    80001c18:	63a4                	ld	s1,64(a5)
  pop_off();
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	078080e7          	jalr	120(ra) # 80000c92 <pop_off>
  return p;
}
    80001c22:	8526                	mv	a0,s1
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret

0000000080001c2e <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c2e:	1141                	addi	sp,sp,-16
    80001c30:	e406                	sd	ra,8(sp)
    80001c32:	e022                	sd	s0,0(sp)
    80001c34:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001c36:	00000097          	auipc	ra,0x0
    80001c3a:	fc0080e7          	jalr	-64(ra) # 80001bf6 <myproc>
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	0b0080e7          	jalr	176(ra) # 80000cee <release>

  if (first)
    80001c46:	00007797          	auipc	a5,0x7
    80001c4a:	c1a7a783          	lw	a5,-998(a5) # 80008860 <first.1>
    80001c4e:	eb89                	bnez	a5,80001c60 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c50:	00001097          	auipc	ra,0x1
    80001c54:	260080e7          	jalr	608(ra) # 80002eb0 <usertrapret>
}
    80001c58:	60a2                	ld	ra,8(sp)
    80001c5a:	6402                	ld	s0,0(sp)
    80001c5c:	0141                	addi	sp,sp,16
    80001c5e:	8082                	ret
    first = 0;
    80001c60:	00007797          	auipc	a5,0x7
    80001c64:	c007a023          	sw	zero,-1024(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001c68:	4505                	li	a0,1
    80001c6a:	00002097          	auipc	ra,0x2
    80001c6e:	1f0080e7          	jalr	496(ra) # 80003e5a <fsinit>
    80001c72:	bff9                	j	80001c50 <forkret+0x22>

0000000080001c74 <allocpid>:
{
    80001c74:	1101                	addi	sp,sp,-32
    80001c76:	ec06                	sd	ra,24(sp)
    80001c78:	e822                	sd	s0,16(sp)
    80001c7a:	e426                	sd	s1,8(sp)
    80001c7c:	e04a                	sd	s2,0(sp)
    80001c7e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c80:	0000f917          	auipc	s2,0xf
    80001c84:	ef090913          	addi	s2,s2,-272 # 80010b70 <pid_lock>
    80001c88:	854a                	mv	a0,s2
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	fb4080e7          	jalr	-76(ra) # 80000c3e <acquire>
  pid = nextpid;
    80001c92:	00007797          	auipc	a5,0x7
    80001c96:	bde78793          	addi	a5,a5,-1058 # 80008870 <nextpid>
    80001c9a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c9c:	0014871b          	addiw	a4,s1,1
    80001ca0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ca2:	854a                	mv	a0,s2
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	04a080e7          	jalr	74(ra) # 80000cee <release>
}
    80001cac:	8526                	mv	a0,s1
    80001cae:	60e2                	ld	ra,24(sp)
    80001cb0:	6442                	ld	s0,16(sp)
    80001cb2:	64a2                	ld	s1,8(sp)
    80001cb4:	6902                	ld	s2,0(sp)
    80001cb6:	6105                	addi	sp,sp,32
    80001cb8:	8082                	ret

0000000080001cba <proc_pagetable>:
{
    80001cba:	1101                	addi	sp,sp,-32
    80001cbc:	ec06                	sd	ra,24(sp)
    80001cbe:	e822                	sd	s0,16(sp)
    80001cc0:	e426                	sd	s1,8(sp)
    80001cc2:	e04a                	sd	s2,0(sp)
    80001cc4:	1000                	addi	s0,sp,32
    80001cc6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	6ec080e7          	jalr	1772(ra) # 800013b4 <uvmcreate>
    80001cd0:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001cd2:	c121                	beqz	a0,80001d12 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cd4:	4729                	li	a4,10
    80001cd6:	00005697          	auipc	a3,0x5
    80001cda:	32a68693          	addi	a3,a3,810 # 80007000 <_trampoline>
    80001cde:	6605                	lui	a2,0x1
    80001ce0:	040005b7          	lui	a1,0x4000
    80001ce4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ce6:	05b2                	slli	a1,a1,0xc
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	432080e7          	jalr	1074(ra) # 8000111a <mappages>
    80001cf0:	02054863          	bltz	a0,80001d20 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cf4:	4719                	li	a4,6
    80001cf6:	23093683          	ld	a3,560(s2)
    80001cfa:	6605                	lui	a2,0x1
    80001cfc:	020005b7          	lui	a1,0x2000
    80001d00:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d02:	05b6                	slli	a1,a1,0xd
    80001d04:	8526                	mv	a0,s1
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	414080e7          	jalr	1044(ra) # 8000111a <mappages>
    80001d0e:	02054163          	bltz	a0,80001d30 <proc_pagetable+0x76>
}
    80001d12:	8526                	mv	a0,s1
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6902                	ld	s2,0(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret
    uvmfree(pagetable, 0);
    80001d20:	4581                	li	a1,0
    80001d22:	8526                	mv	a0,s1
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	8aa080e7          	jalr	-1878(ra) # 800015ce <uvmfree>
    return 0;
    80001d2c:	4481                	li	s1,0
    80001d2e:	b7d5                	j	80001d12 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d30:	4681                	li	a3,0
    80001d32:	4605                	li	a2,1
    80001d34:	040005b7          	lui	a1,0x4000
    80001d38:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d3a:	05b2                	slli	a1,a1,0xc
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	5a2080e7          	jalr	1442(ra) # 800012e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d46:	4581                	li	a1,0
    80001d48:	8526                	mv	a0,s1
    80001d4a:	00000097          	auipc	ra,0x0
    80001d4e:	884080e7          	jalr	-1916(ra) # 800015ce <uvmfree>
    return 0;
    80001d52:	4481                	li	s1,0
    80001d54:	bf7d                	j	80001d12 <proc_pagetable+0x58>

0000000080001d56 <proc_freepagetable>:
{
    80001d56:	1101                	addi	sp,sp,-32
    80001d58:	ec06                	sd	ra,24(sp)
    80001d5a:	e822                	sd	s0,16(sp)
    80001d5c:	e426                	sd	s1,8(sp)
    80001d5e:	e04a                	sd	s2,0(sp)
    80001d60:	1000                	addi	s0,sp,32
    80001d62:	84aa                	mv	s1,a0
    80001d64:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d66:	4681                	li	a3,0
    80001d68:	4605                	li	a2,1
    80001d6a:	040005b7          	lui	a1,0x4000
    80001d6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d70:	05b2                	slli	a1,a1,0xc
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	56e080e7          	jalr	1390(ra) # 800012e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d7a:	4681                	li	a3,0
    80001d7c:	4605                	li	a2,1
    80001d7e:	020005b7          	lui	a1,0x2000
    80001d82:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d84:	05b6                	slli	a1,a1,0xd
    80001d86:	8526                	mv	a0,s1
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	558080e7          	jalr	1368(ra) # 800012e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d90:	85ca                	mv	a1,s2
    80001d92:	8526                	mv	a0,s1
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	83a080e7          	jalr	-1990(ra) # 800015ce <uvmfree>
}
    80001d9c:	60e2                	ld	ra,24(sp)
    80001d9e:	6442                	ld	s0,16(sp)
    80001da0:	64a2                	ld	s1,8(sp)
    80001da2:	6902                	ld	s2,0(sp)
    80001da4:	6105                	addi	sp,sp,32
    80001da6:	8082                	ret

0000000080001da8 <freeproc>:
{
    80001da8:	1101                	addi	sp,sp,-32
    80001daa:	ec06                	sd	ra,24(sp)
    80001dac:	e822                	sd	s0,16(sp)
    80001dae:	e426                	sd	s1,8(sp)
    80001db0:	1000                	addi	s0,sp,32
    80001db2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001db4:	23053503          	ld	a0,560(a0)
    80001db8:	c509                	beqz	a0,80001dc2 <freeproc+0x1a>
    kfree((void *)p->trapframe);
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	c92080e7          	jalr	-878(ra) # 80000a4c <kfree>
  p->trapframe = 0;
    80001dc2:	2204b823          	sd	zero,560(s1)
  if (p->pagetable)
    80001dc6:	2284b503          	ld	a0,552(s1)
    80001dca:	c519                	beqz	a0,80001dd8 <freeproc+0x30>
    proc_freepagetable(p->pagetable, p->sz);
    80001dcc:	2204b583          	ld	a1,544(s1)
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	f86080e7          	jalr	-122(ra) # 80001d56 <proc_freepagetable>
  p->pagetable = 0;
    80001dd8:	2204b423          	sd	zero,552(s1)
  p->sz = 0;
    80001ddc:	2204b023          	sd	zero,544(s1)
  p->pid = 0;
    80001de0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001de4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001de8:	32048823          	sb	zero,816(s1)
  p->chan = 0;
    80001dec:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001df0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001df4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001df8:	0004ac23          	sw	zero,24(s1)
  for (int x = 0; x <= 26; x++)
    80001dfc:	04048793          	addi	a5,s1,64
    80001e00:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    80001e04:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    80001e08:	0791                	addi	a5,a5,4
    80001e0a:	fee79de3          	bne	a5,a4,80001e04 <freeproc+0x5c>
}
    80001e0e:	60e2                	ld	ra,24(sp)
    80001e10:	6442                	ld	s0,16(sp)
    80001e12:	64a2                	ld	s1,8(sp)
    80001e14:	6105                	addi	sp,sp,32
    80001e16:	8082                	ret

0000000080001e18 <allocproc>:
{
    80001e18:	1101                	addi	sp,sp,-32
    80001e1a:	ec06                	sd	ra,24(sp)
    80001e1c:	e822                	sd	s0,16(sp)
    80001e1e:	e426                	sd	s1,8(sp)
    80001e20:	e04a                	sd	s2,0(sp)
    80001e22:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001e24:	00010497          	auipc	s1,0x10
    80001e28:	97c48493          	addi	s1,s1,-1668 # 800117a0 <proc>
    80001e2c:	0001d917          	auipc	s2,0x1d
    80001e30:	d7490913          	addi	s2,s2,-652 # 8001eba0 <tickslock>
    acquire(&p->lock);
    80001e34:	8526                	mv	a0,s1
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	e08080e7          	jalr	-504(ra) # 80000c3e <acquire>
    if (p->state == UNUSED)
    80001e3e:	4c9c                	lw	a5,24(s1)
    80001e40:	cf81                	beqz	a5,80001e58 <allocproc+0x40>
      release(&p->lock);
    80001e42:	8526                	mv	a0,s1
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	eaa080e7          	jalr	-342(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001e4c:	35048493          	addi	s1,s1,848
    80001e50:	ff2492e3          	bne	s1,s2,80001e34 <allocproc+0x1c>
  return 0;
    80001e54:	4481                	li	s1,0
    80001e56:	a859                	j	80001eec <allocproc+0xd4>
  p->pid = allocpid();
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	e1c080e7          	jalr	-484(ra) # 80001c74 <allocpid>
    80001e60:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e62:	4785                	li	a5,1
    80001e64:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	ce4080e7          	jalr	-796(ra) # 80000b4a <kalloc>
    80001e6e:	892a                	mv	s2,a0
    80001e70:	22a4b823          	sd	a0,560(s1)
    80001e74:	c159                	beqz	a0,80001efa <allocproc+0xe2>
  p->pagetable = proc_pagetable(p);
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	e42080e7          	jalr	-446(ra) # 80001cba <proc_pagetable>
    80001e80:	892a                	mv	s2,a0
    80001e82:	22a4b423          	sd	a0,552(s1)
  if (p->pagetable == 0)
    80001e86:	c551                	beqz	a0,80001f12 <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80001e88:	07000613          	li	a2,112
    80001e8c:	4581                	li	a1,0
    80001e8e:	23848513          	addi	a0,s1,568
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	ea4080e7          	jalr	-348(ra) # 80000d36 <memset>
  p->context.ra = (uint64)forkret;
    80001e9a:	00000797          	auipc	a5,0x0
    80001e9e:	d9478793          	addi	a5,a5,-620 # 80001c2e <forkret>
    80001ea2:	22f4bc23          	sd	a5,568(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ea6:	2184b783          	ld	a5,536(s1)
    80001eaa:	6705                	lui	a4,0x1
    80001eac:	97ba                	add	a5,a5,a4
    80001eae:	24f4b023          	sd	a5,576(s1)
  p->rtime = 0;
    80001eb2:	3404a023          	sw	zero,832(s1)
  p->etime = 0;
    80001eb6:	3404a423          	sw	zero,840(s1)
  p->ctime = ticks;
    80001eba:	00007797          	auipc	a5,0x7
    80001ebe:	a3a7a783          	lw	a5,-1478(a5) # 800088f4 <ticks>
    80001ec2:	34f4a223          	sw	a5,836(s1)
  p->tickets = 1;
    80001ec6:	4705                	li	a4,1
    80001ec8:	0ce4a023          	sw	a4,192(s1)
  p->ticks = 0;
    80001ecc:	0e04a023          	sw	zero,224(s1)
  p->arrival_time = ticks; // to add new process in the end;
    80001ed0:	1782                	slli	a5,a5,0x20
    80001ed2:	9381                	srli	a5,a5,0x20
    80001ed4:	e4fc                	sd	a5,200(s1)
  p->priority = 0;
    80001ed6:	0c04ac23          	sw	zero,216(s1)
  for (int x = 0; x <= 26; x++)
    80001eda:	04048793          	addi	a5,s1,64
    80001ede:	0ac48713          	addi	a4,s1,172
    p->syscall_count[x] = 0;
    80001ee2:	0007a023          	sw	zero,0(a5)
  for (int x = 0; x <= 26; x++)
    80001ee6:	0791                	addi	a5,a5,4
    80001ee8:	fee79de3          	bne	a5,a4,80001ee2 <allocproc+0xca>
}
    80001eec:	8526                	mv	a0,s1
    80001eee:	60e2                	ld	ra,24(sp)
    80001ef0:	6442                	ld	s0,16(sp)
    80001ef2:	64a2                	ld	s1,8(sp)
    80001ef4:	6902                	ld	s2,0(sp)
    80001ef6:	6105                	addi	sp,sp,32
    80001ef8:	8082                	ret
    freeproc(p);
    80001efa:	8526                	mv	a0,s1
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	eac080e7          	jalr	-340(ra) # 80001da8 <freeproc>
    release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	de8080e7          	jalr	-536(ra) # 80000cee <release>
    return 0;
    80001f0e:	84ca                	mv	s1,s2
    80001f10:	bff1                	j	80001eec <allocproc+0xd4>
    freeproc(p);
    80001f12:	8526                	mv	a0,s1
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	e94080e7          	jalr	-364(ra) # 80001da8 <freeproc>
    release(&p->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	dd0080e7          	jalr	-560(ra) # 80000cee <release>
    return 0;
    80001f26:	84ca                	mv	s1,s2
    80001f28:	b7d1                	j	80001eec <allocproc+0xd4>

0000000080001f2a <userinit>:
{
    80001f2a:	1101                	addi	sp,sp,-32
    80001f2c:	ec06                	sd	ra,24(sp)
    80001f2e:	e822                	sd	s0,16(sp)
    80001f30:	e426                	sd	s1,8(sp)
    80001f32:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	ee4080e7          	jalr	-284(ra) # 80001e18 <allocproc>
    80001f3c:	84aa                	mv	s1,a0
  initproc = p;
    80001f3e:	00007797          	auipc	a5,0x7
    80001f42:	9aa7b523          	sd	a0,-1622(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f46:	03400613          	li	a2,52
    80001f4a:	00007597          	auipc	a1,0x7
    80001f4e:	93658593          	addi	a1,a1,-1738 # 80008880 <initcode>
    80001f52:	22853503          	ld	a0,552(a0)
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	48c080e7          	jalr	1164(ra) # 800013e2 <uvmfirst>
  p->sz = PGSIZE;
    80001f5e:	6785                	lui	a5,0x1
    80001f60:	22f4b023          	sd	a5,544(s1)
  p->trapframe->epc = 0;     // user program counter
    80001f64:	2304b703          	ld	a4,560(s1)
    80001f68:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f6c:	2304b703          	ld	a4,560(s1)
    80001f70:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f72:	4641                	li	a2,16
    80001f74:	00006597          	auipc	a1,0x6
    80001f78:	26c58593          	addi	a1,a1,620 # 800081e0 <etext+0x1e0>
    80001f7c:	33048513          	addi	a0,s1,816
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	f0c080e7          	jalr	-244(ra) # 80000e8c <safestrcpy>
  p->cwd = namei("/");
    80001f88:	00006517          	auipc	a0,0x6
    80001f8c:	26850513          	addi	a0,a0,616 # 800081f0 <etext+0x1f0>
    80001f90:	00003097          	auipc	ra,0x3
    80001f94:	932080e7          	jalr	-1742(ra) # 800048c2 <namei>
    80001f98:	32a4b423          	sd	a0,808(s1)
  p->state = RUNNABLE;
    80001f9c:	478d                	li	a5,3
    80001f9e:	cc9c                	sw	a5,24(s1)
  Enqueue(p, p->priority);
    80001fa0:	0d84a583          	lw	a1,216(s1)
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	00000097          	auipc	ra,0x0
    80001faa:	a18080e7          	jalr	-1512(ra) # 800019be <Enqueue>
  release(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	d3e080e7          	jalr	-706(ra) # 80000cee <release>
}
    80001fb8:	60e2                	ld	ra,24(sp)
    80001fba:	6442                	ld	s0,16(sp)
    80001fbc:	64a2                	ld	s1,8(sp)
    80001fbe:	6105                	addi	sp,sp,32
    80001fc0:	8082                	ret

0000000080001fc2 <growproc>:
{
    80001fc2:	1101                	addi	sp,sp,-32
    80001fc4:	ec06                	sd	ra,24(sp)
    80001fc6:	e822                	sd	s0,16(sp)
    80001fc8:	e426                	sd	s1,8(sp)
    80001fca:	e04a                	sd	s2,0(sp)
    80001fcc:	1000                	addi	s0,sp,32
    80001fce:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	c26080e7          	jalr	-986(ra) # 80001bf6 <myproc>
    80001fd8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fda:	22053583          	ld	a1,544(a0)
  if (n > 0)
    80001fde:	01204d63          	bgtz	s2,80001ff8 <growproc+0x36>
  else if (n < 0)
    80001fe2:	02094863          	bltz	s2,80002012 <growproc+0x50>
  p->sz = sz;
    80001fe6:	22b4b023          	sd	a1,544(s1)
  return 0;
    80001fea:	4501                	li	a0,0
}
    80001fec:	60e2                	ld	ra,24(sp)
    80001fee:	6442                	ld	s0,16(sp)
    80001ff0:	64a2                	ld	s1,8(sp)
    80001ff2:	6902                	ld	s2,0(sp)
    80001ff4:	6105                	addi	sp,sp,32
    80001ff6:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001ff8:	4691                	li	a3,4
    80001ffa:	00b90633          	add	a2,s2,a1
    80001ffe:	22853503          	ld	a0,552(a0)
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	49a080e7          	jalr	1178(ra) # 8000149c <uvmalloc>
    8000200a:	85aa                	mv	a1,a0
    8000200c:	fd69                	bnez	a0,80001fe6 <growproc+0x24>
      return -1;
    8000200e:	557d                	li	a0,-1
    80002010:	bff1                	j	80001fec <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002012:	00b90633          	add	a2,s2,a1
    80002016:	22853503          	ld	a0,552(a0)
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	43a080e7          	jalr	1082(ra) # 80001454 <uvmdealloc>
    80002022:	85aa                	mv	a1,a0
    80002024:	b7c9                	j	80001fe6 <growproc+0x24>

0000000080002026 <fork>:
{
    80002026:	7139                	addi	sp,sp,-64
    80002028:	fc06                	sd	ra,56(sp)
    8000202a:	f822                	sd	s0,48(sp)
    8000202c:	f04a                	sd	s2,32(sp)
    8000202e:	e456                	sd	s5,8(sp)
    80002030:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002032:	00000097          	auipc	ra,0x0
    80002036:	bc4080e7          	jalr	-1084(ra) # 80001bf6 <myproc>
    8000203a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	ddc080e7          	jalr	-548(ra) # 80001e18 <allocproc>
    80002044:	12050c63          	beqz	a0,8000217c <fork+0x156>
    80002048:	ec4e                	sd	s3,24(sp)
    8000204a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000204c:	220ab603          	ld	a2,544(s5)
    80002050:	22853583          	ld	a1,552(a0)
    80002054:	228ab503          	ld	a0,552(s5)
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	5b0080e7          	jalr	1456(ra) # 80001608 <uvmcopy>
    80002060:	04054a63          	bltz	a0,800020b4 <fork+0x8e>
    80002064:	f426                	sd	s1,40(sp)
    80002066:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80002068:	220ab783          	ld	a5,544(s5)
    8000206c:	22f9b023          	sd	a5,544(s3)
  *(np->trapframe) = *(p->trapframe);
    80002070:	230ab683          	ld	a3,560(s5)
    80002074:	87b6                	mv	a5,a3
    80002076:	2309b703          	ld	a4,560(s3)
    8000207a:	12068693          	addi	a3,a3,288
    8000207e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002082:	6788                	ld	a0,8(a5)
    80002084:	6b8c                	ld	a1,16(a5)
    80002086:	6f90                	ld	a2,24(a5)
    80002088:	01073023          	sd	a6,0(a4)
    8000208c:	e708                	sd	a0,8(a4)
    8000208e:	eb0c                	sd	a1,16(a4)
    80002090:	ef10                	sd	a2,24(a4)
    80002092:	02078793          	addi	a5,a5,32
    80002096:	02070713          	addi	a4,a4,32
    8000209a:	fed792e3          	bne	a5,a3,8000207e <fork+0x58>
  np->trapframe->a0 = 0;
    8000209e:	2309b783          	ld	a5,560(s3)
    800020a2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020a6:	2a8a8493          	addi	s1,s5,680
    800020aa:	2a898913          	addi	s2,s3,680
    800020ae:	328a8a13          	addi	s4,s5,808
    800020b2:	a015                	j	800020d6 <fork+0xb0>
    freeproc(np);
    800020b4:	854e                	mv	a0,s3
    800020b6:	00000097          	auipc	ra,0x0
    800020ba:	cf2080e7          	jalr	-782(ra) # 80001da8 <freeproc>
    release(&np->lock);
    800020be:	854e                	mv	a0,s3
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	c2e080e7          	jalr	-978(ra) # 80000cee <release>
    return -1;
    800020c8:	597d                	li	s2,-1
    800020ca:	69e2                	ld	s3,24(sp)
    800020cc:	a04d                	j	8000216e <fork+0x148>
  for (i = 0; i < NOFILE; i++)
    800020ce:	04a1                	addi	s1,s1,8
    800020d0:	0921                	addi	s2,s2,8
    800020d2:	01448b63          	beq	s1,s4,800020e8 <fork+0xc2>
    if (p->ofile[i])
    800020d6:	6088                	ld	a0,0(s1)
    800020d8:	d97d                	beqz	a0,800020ce <fork+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    800020da:	00003097          	auipc	ra,0x3
    800020de:	e6c080e7          	jalr	-404(ra) # 80004f46 <filedup>
    800020e2:	00a93023          	sd	a0,0(s2)
    800020e6:	b7e5                	j	800020ce <fork+0xa8>
  np->cwd = idup(p->cwd);
    800020e8:	328ab503          	ld	a0,808(s5)
    800020ec:	00002097          	auipc	ra,0x2
    800020f0:	fb4080e7          	jalr	-76(ra) # 800040a0 <idup>
    800020f4:	32a9b423          	sd	a0,808(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020f8:	4641                	li	a2,16
    800020fa:	330a8593          	addi	a1,s5,816
    800020fe:	33098513          	addi	a0,s3,816
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	d8a080e7          	jalr	-630(ra) # 80000e8c <safestrcpy>
  np->tickets = p->tickets;
    8000210a:	0c0aa783          	lw	a5,192(s5)
    8000210e:	0cf9a023          	sw	a5,192(s3)
  pid = np->pid;
    80002112:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002116:	854e                	mv	a0,s3
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	bd6080e7          	jalr	-1066(ra) # 80000cee <release>
  acquire(&wait_lock);
    80002120:	0000f497          	auipc	s1,0xf
    80002124:	a6848493          	addi	s1,s1,-1432 # 80010b88 <wait_lock>
    80002128:	8526                	mv	a0,s1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b14080e7          	jalr	-1260(ra) # 80000c3e <acquire>
  np->parent = p;
    80002132:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	bb6080e7          	jalr	-1098(ra) # 80000cee <release>
  acquire(&np->lock);
    80002140:	854e                	mv	a0,s3
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	afc080e7          	jalr	-1284(ra) # 80000c3e <acquire>
  np->state = RUNNABLE;
    8000214a:	478d                	li	a5,3
    8000214c:	00f9ac23          	sw	a5,24(s3)
  Enqueue(p, p->priority);
    80002150:	0d8aa583          	lw	a1,216(s5)
    80002154:	8556                	mv	a0,s5
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	868080e7          	jalr	-1944(ra) # 800019be <Enqueue>
  release(&np->lock);
    8000215e:	854e                	mv	a0,s3
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b8e080e7          	jalr	-1138(ra) # 80000cee <release>
  return pid;
    80002168:	74a2                	ld	s1,40(sp)
    8000216a:	69e2                	ld	s3,24(sp)
    8000216c:	6a42                	ld	s4,16(sp)
}
    8000216e:	854a                	mv	a0,s2
    80002170:	70e2                	ld	ra,56(sp)
    80002172:	7442                	ld	s0,48(sp)
    80002174:	7902                	ld	s2,32(sp)
    80002176:	6aa2                	ld	s5,8(sp)
    80002178:	6121                	addi	sp,sp,64
    8000217a:	8082                	ret
    return -1;
    8000217c:	597d                	li	s2,-1
    8000217e:	bfc5                	j	8000216e <fork+0x148>

0000000080002180 <get_time_slice>:
{
    80002180:	1141                	addi	sp,sp,-16
    80002182:	e406                	sd	ra,8(sp)
    80002184:	e022                	sd	s0,0(sp)
    80002186:	0800                	addi	s0,sp,16
  switch (priority)
    80002188:	4709                	li	a4,2
    8000218a:	00e50d63          	beq	a0,a4,800021a4 <get_time_slice+0x24>
    8000218e:	87aa                	mv	a5,a0
    80002190:	470d                	li	a4,3
    return 16;
    80002192:	4541                	li	a0,16
  switch (priority)
    80002194:	00e78963          	beq	a5,a4,800021a6 <get_time_slice+0x26>
    80002198:	4705                	li	a4,1
    8000219a:	4511                	li	a0,4
    8000219c:	00e78563          	beq	a5,a4,800021a6 <get_time_slice+0x26>
    return 1;
    800021a0:	853a                	mv	a0,a4
    800021a2:	a011                	j	800021a6 <get_time_slice+0x26>
    return 8;
    800021a4:	4521                	li	a0,8
}
    800021a6:	60a2                	ld	ra,8(sp)
    800021a8:	6402                	ld	s0,0(sp)
    800021aa:	0141                	addi	sp,sp,16
    800021ac:	8082                	ret

00000000800021ae <priority_boost>:
{
    800021ae:	7179                	addi	sp,sp,-48
    800021b0:	f406                	sd	ra,40(sp)
    800021b2:	f022                	sd	s0,32(sp)
    800021b4:	ec26                	sd	s1,24(sp)
    800021b6:	e84a                	sd	s2,16(sp)
    800021b8:	e44e                	sd	s3,8(sp)
    800021ba:	1800                	addi	s0,sp,48
  initialize();
    800021bc:	00000097          	auipc	ra,0x0
    800021c0:	900080e7          	jalr	-1792(ra) # 80001abc <initialize>
  for (p = proc; p < &proc[NPROC]; p++)
    800021c4:	0000f497          	auipc	s1,0xf
    800021c8:	5dc48493          	addi	s1,s1,1500 # 800117a0 <proc>
    if (p->state == RUNNABLE)
    800021cc:	498d                	li	s3,3
  for (p = proc; p < &proc[NPROC]; p++)
    800021ce:	0001d917          	auipc	s2,0x1d
    800021d2:	9d290913          	addi	s2,s2,-1582 # 8001eba0 <tickslock>
    800021d6:	a811                	j	800021ea <priority_boost+0x3c>
    release(&p->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	b14080e7          	jalr	-1260(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800021e2:	35048493          	addi	s1,s1,848
    800021e6:	03248563          	beq	s1,s2,80002210 <priority_boost+0x62>
    acquire(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a52080e7          	jalr	-1454(ra) # 80000c3e <acquire>
    if (p->state == RUNNABLE)
    800021f4:	4c9c                	lw	a5,24(s1)
    800021f6:	ff3791e3          	bne	a5,s3,800021d8 <priority_boost+0x2a>
      p->priority = 0;
    800021fa:	0c04ac23          	sw	zero,216(s1)
      p->ticks=0;
    800021fe:	0e04a023          	sw	zero,224(s1)
      Enqueue(p, 0);
    80002202:	4581                	li	a1,0
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	7b8080e7          	jalr	1976(ra) # 800019be <Enqueue>
    8000220e:	b7e9                	j	800021d8 <priority_boost+0x2a>
  boost_ticks = 0;
    80002210:	00006797          	auipc	a5,0x6
    80002214:	6e07a023          	sw	zero,1760(a5) # 800088f0 <boost_ticks>
}
    80002218:	70a2                	ld	ra,40(sp)
    8000221a:	7402                	ld	s0,32(sp)
    8000221c:	64e2                	ld	s1,24(sp)
    8000221e:	6942                	ld	s2,16(sp)
    80002220:	69a2                	ld	s3,8(sp)
    80002222:	6145                	addi	sp,sp,48
    80002224:	8082                	ret

0000000080002226 <scheduler_mlfq>:
{
    80002226:	715d                	addi	sp,sp,-80
    80002228:	e486                	sd	ra,72(sp)
    8000222a:	e0a2                	sd	s0,64(sp)
    8000222c:	fc26                	sd	s1,56(sp)
    8000222e:	f84a                	sd	s2,48(sp)
    80002230:	f44e                	sd	s3,40(sp)
    80002232:	f052                	sd	s4,32(sp)
    80002234:	ec56                	sd	s5,24(sp)
    80002236:	e85a                	sd	s6,16(sp)
    80002238:	e45e                	sd	s7,8(sp)
    8000223a:	e062                	sd	s8,0(sp)
    8000223c:	0880                	addi	s0,sp,80
    8000223e:	8792                	mv	a5,tp
  int id = r_tp();
    80002240:	2781                	sext.w	a5,a5
        swtch(&c->context, &selected_proc->context);
    80002242:	00779b13          	slli	s6,a5,0x7
    80002246:	0000f717          	auipc	a4,0xf
    8000224a:	96270713          	addi	a4,a4,-1694 # 80010ba8 <cpus+0x8>
    8000224e:	9b3a                	add	s6,s6,a4
    c->proc = 0;
    80002250:	079e                	slli	a5,a5,0x7
    80002252:	0000fa17          	auipc	s4,0xf
    80002256:	90ea0a13          	addi	s4,s4,-1778 # 80010b60 <queues_sizes>
    8000225a:	9a3e                	add	s4,s4,a5
    boost_ticks++;
    8000225c:	00006917          	auipc	s2,0x6
    80002260:	69490913          	addi	s2,s2,1684 # 800088f0 <boost_ticks>
    for (int priority = 0; priority < 4; priority++)
    80002264:	4491                	li	s1,4
        selected_proc=mlfq[priority][0];
    80002266:	0000fa97          	auipc	s5,0xf
    8000226a:	d3aa8a93          	addi	s5,s5,-710 # 80010fa0 <mlfq>
    8000226e:	a8d1                	j	80002342 <scheduler_mlfq+0x11c>
    for (int priority = 0; priority < 4; priority++)
    80002270:	0000f717          	auipc	a4,0xf
    80002274:	8f070713          	addi	a4,a4,-1808 # 80010b60 <queues_sizes>
    80002278:	4781                	li	a5,0
      if(queues_sizes[priority]>0)
    8000227a:	4314                	lw	a3,0(a4)
    8000227c:	02d04a63          	bgtz	a3,800022b0 <scheduler_mlfq+0x8a>
    for (int priority = 0; priority < 4; priority++)
    80002280:	2785                	addiw	a5,a5,1
    80002282:	0711                	addi	a4,a4,4
    80002284:	fe979be3          	bne	a5,s1,8000227a <scheduler_mlfq+0x54>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002288:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000228c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002290:	10079073          	csrw	sstatus,a5
    c->proc = 0;
    80002294:	040a3023          	sd	zero,64(s4)
    boost_ticks++;
    80002298:	00092783          	lw	a5,0(s2)
    8000229c:	2785                	addiw	a5,a5,1
    8000229e:	00f92023          	sw	a5,0(s2)
    if (boost_ticks>BOOST_INTERVAL)
    800022a2:	fcf9d7e3          	bge	s3,a5,80002270 <scheduler_mlfq+0x4a>
      priority_boost();
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	f08080e7          	jalr	-248(ra) # 800021ae <priority_boost>
    800022ae:	b7c9                	j	80002270 <scheduler_mlfq+0x4a>
        selected_proc=mlfq[priority][0];
    800022b0:	07a6                	slli	a5,a5,0x9
    800022b2:	97d6                	add	a5,a5,s5
    800022b4:	0007bb83          	ld	s7,0(a5)
    if (selected_proc)
    800022b8:	fc0b88e3          	beqz	s7,80002288 <scheduler_mlfq+0x62>
    int time_slice = get_time_slice(selected_proc->priority);
    800022bc:	0d8ba983          	lw	s3,216(s7) # fffffffffffff0d8 <end+0xffffffff7ffd5158>
      acquire(&selected_proc->lock);
    800022c0:	855e                	mv	a0,s7
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	97c080e7          	jalr	-1668(ra) # 80000c3e <acquire>
      if (selected_proc->state == RUNNABLE)
    800022ca:	018ba703          	lw	a4,24(s7)
    800022ce:	478d                	li	a5,3
    800022d0:	06f70c63          	beq	a4,a5,80002348 <scheduler_mlfq+0x122>
      release(&selected_proc->lock);
    800022d4:	855e                	mv	a0,s7
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	a18080e7          	jalr	-1512(ra) # 80000cee <release>
      acquire(&selected_proc->lock);
    800022de:	855e                	mv	a0,s7
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	95e080e7          	jalr	-1698(ra) # 80000c3e <acquire>
      selected_proc->ticks++;
    800022e8:	0e0ba783          	lw	a5,224(s7)
    800022ec:	2785                	addiw	a5,a5,1
    800022ee:	0efba023          	sw	a5,224(s7)
      dequeue(selected_proc->priority);
    800022f2:	0d8ba503          	lw	a0,216(s7)
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	728080e7          	jalr	1832(ra) # 80001a1e <dequeue>
      if (selected_proc->state == RUNNABLE)
    800022fe:	018ba703          	lw	a4,24(s7)
    80002302:	478d                	li	a5,3
    80002304:	02f71a63          	bne	a4,a5,80002338 <scheduler_mlfq+0x112>
        if (selected_proc->ticks >= time_slice)
    80002308:	0e0bac03          	lw	s8,224(s7)
    int time_slice = get_time_slice(selected_proc->priority);
    8000230c:	854e                	mv	a0,s3
    8000230e:	00000097          	auipc	ra,0x0
    80002312:	e72080e7          	jalr	-398(ra) # 80002180 <get_time_slice>
        if (selected_proc->ticks >= time_slice)
    80002316:	04ac4f63          	blt	s8,a0,80002374 <scheduler_mlfq+0x14e>
          if (selected_proc->priority < 3)
    8000231a:	0d8ba583          	lw	a1,216(s7)
    8000231e:	4789                	li	a5,2
    80002320:	04b7c263          	blt	a5,a1,80002364 <scheduler_mlfq+0x13e>
            selected_proc->priority++;
    80002324:	2585                	addiw	a1,a1,1
    80002326:	0cbbac23          	sw	a1,216(s7)
            Enqueue(selected_proc, selected_proc->priority);
    8000232a:	855e                	mv	a0,s7
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	692080e7          	jalr	1682(ra) # 800019be <Enqueue>
            selected_proc->ticks = 0;
    80002334:	0e0ba023          	sw	zero,224(s7)
      release(&selected_proc->lock);
    80002338:	855e                	mv	a0,s7
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	9b4080e7          	jalr	-1612(ra) # 80000cee <release>
    if (boost_ticks>BOOST_INTERVAL)
    80002342:	03000993          	li	s3,48
    80002346:	b789                	j	80002288 <scheduler_mlfq+0x62>
        selected_proc->state = RUNNING;
    80002348:	009bac23          	sw	s1,24(s7)
        c->proc = selected_proc;
    8000234c:	057a3023          	sd	s7,64(s4)
        swtch(&c->context, &selected_proc->context);
    80002350:	238b8593          	addi	a1,s7,568
    80002354:	855a                	mv	a0,s6
    80002356:	00001097          	auipc	ra,0x1
    8000235a:	aac080e7          	jalr	-1364(ra) # 80002e02 <swtch>
        c->proc = 0;
    8000235e:	040a3023          	sd	zero,64(s4)
    80002362:	bf8d                	j	800022d4 <scheduler_mlfq+0xae>
            selected_proc->ticks = 0;
    80002364:	0e0ba023          	sw	zero,224(s7)
            Enqueue(selected_proc, selected_proc->priority);
    80002368:	855e                	mv	a0,s7
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	654080e7          	jalr	1620(ra) # 800019be <Enqueue>
    80002372:	b7d9                	j	80002338 <scheduler_mlfq+0x112>
          Enqueue(selected_proc, selected_proc->priority);
    80002374:	0d8ba583          	lw	a1,216(s7)
    80002378:	855e                	mv	a0,s7
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	644080e7          	jalr	1604(ra) # 800019be <Enqueue>
    80002382:	bf5d                	j	80002338 <scheduler_mlfq+0x112>

0000000080002384 <scheduler_rr>:
{
    80002384:	7139                	addi	sp,sp,-64
    80002386:	fc06                	sd	ra,56(sp)
    80002388:	f822                	sd	s0,48(sp)
    8000238a:	f426                	sd	s1,40(sp)
    8000238c:	f04a                	sd	s2,32(sp)
    8000238e:	ec4e                	sd	s3,24(sp)
    80002390:	e852                	sd	s4,16(sp)
    80002392:	e456                	sd	s5,8(sp)
    80002394:	e05a                	sd	s6,0(sp)
    80002396:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    80002398:	8792                	mv	a5,tp
  int id = r_tp();
    8000239a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000239c:	00779a93          	slli	s5,a5,0x7
    800023a0:	0000e717          	auipc	a4,0xe
    800023a4:	7c070713          	addi	a4,a4,1984 # 80010b60 <queues_sizes>
    800023a8:	9756                	add	a4,a4,s5
    800023aa:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &p->context);
    800023ae:	0000e717          	auipc	a4,0xe
    800023b2:	7fa70713          	addi	a4,a4,2042 # 80010ba8 <cpus+0x8>
    800023b6:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    800023b8:	498d                	li	s3,3
        p->state = RUNNING;
    800023ba:	4b11                	li	s6,4
        c->proc = p;
    800023bc:	079e                	slli	a5,a5,0x7
    800023be:	0000ea17          	auipc	s4,0xe
    800023c2:	7a2a0a13          	addi	s4,s4,1954 # 80010b60 <queues_sizes>
    800023c6:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023c8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023cc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023d0:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800023d4:	0000f497          	auipc	s1,0xf
    800023d8:	3cc48493          	addi	s1,s1,972 # 800117a0 <proc>
    800023dc:	0001c917          	auipc	s2,0x1c
    800023e0:	7c490913          	addi	s2,s2,1988 # 8001eba0 <tickslock>
    800023e4:	a811                	j	800023f8 <scheduler_rr+0x74>
      release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	906080e7          	jalr	-1786(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800023f0:	35048493          	addi	s1,s1,848
    800023f4:	fd248ae3          	beq	s1,s2,800023c8 <scheduler_rr+0x44>
      acquire(&p->lock);
    800023f8:	8526                	mv	a0,s1
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	844080e7          	jalr	-1980(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    80002402:	4c9c                	lw	a5,24(s1)
    80002404:	ff3791e3          	bne	a5,s3,800023e6 <scheduler_rr+0x62>
        p->state = RUNNING;
    80002408:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000240c:	049a3023          	sd	s1,64(s4)
        swtch(&c->context, &p->context);
    80002410:	23848593          	addi	a1,s1,568
    80002414:	8556                	mv	a0,s5
    80002416:	00001097          	auipc	ra,0x1
    8000241a:	9ec080e7          	jalr	-1556(ra) # 80002e02 <swtch>
        c->proc = 0;
    8000241e:	040a3023          	sd	zero,64(s4)
    80002422:	b7d1                	j	800023e6 <scheduler_rr+0x62>

0000000080002424 <scheduler_lottery>:
{
    80002424:	715d                	addi	sp,sp,-80
    80002426:	e486                	sd	ra,72(sp)
    80002428:	e0a2                	sd	s0,64(sp)
    8000242a:	fc26                	sd	s1,56(sp)
    8000242c:	f84a                	sd	s2,48(sp)
    8000242e:	f44e                	sd	s3,40(sp)
    80002430:	f052                	sd	s4,32(sp)
    80002432:	ec56                	sd	s5,24(sp)
    80002434:	e85a                	sd	s6,16(sp)
    80002436:	e45e                	sd	s7,8(sp)
    80002438:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    8000243a:	8792                	mv	a5,tp
  int id = r_tp();
    8000243c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000243e:	00779693          	slli	a3,a5,0x7
    80002442:	0000e717          	auipc	a4,0xe
    80002446:	71e70713          	addi	a4,a4,1822 # 80010b60 <queues_sizes>
    8000244a:	9736                	add	a4,a4,a3
    8000244c:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &selected_proc->context);
    80002450:	0000e717          	auipc	a4,0xe
    80002454:	75870713          	addi	a4,a4,1880 # 80010ba8 <cpus+0x8>
    80002458:	9736                	add	a4,a4,a3
    8000245a:	8bba                	mv	s7,a4
      if (p->state == RUNNABLE)
    8000245c:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000245e:	0001c917          	auipc	s2,0x1c
    80002462:	74290913          	addi	s2,s2,1858 # 8001eba0 <tickslock>
        c->proc = selected_proc;
    80002466:	0000ea97          	auipc	s5,0xe
    8000246a:	6faa8a93          	addi	s5,s5,1786 # 80010b60 <queues_sizes>
    8000246e:	9ab6                	add	s5,s5,a3
    80002470:	a80d                	j	800024a2 <scheduler_lottery+0x7e>
      release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	87a080e7          	jalr	-1926(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000247c:	35048493          	addi	s1,s1,848
    80002480:	01248f63          	beq	s1,s2,8000249e <scheduler_lottery+0x7a>
      acquire(&p->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	7b8080e7          	jalr	1976(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    8000248e:	4c9c                	lw	a5,24(s1)
    80002490:	ff3791e3          	bne	a5,s3,80002472 <scheduler_lottery+0x4e>
        total_tickets += p->tickets;
    80002494:	0c04a783          	lw	a5,192(s1)
    80002498:	01678b3b          	addw	s6,a5,s6
    8000249c:	bfd9                	j	80002472 <scheduler_lottery+0x4e>
    if (total_tickets == 0)
    8000249e:	000b1e63          	bnez	s6,800024ba <scheduler_lottery+0x96>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024aa:	10079073          	csrw	sstatus,a5
    total_tickets = 0;
    800024ae:	4b01                	li	s6,0
    for (p = proc; p < &proc[NPROC]; p++)
    800024b0:	0000f497          	auipc	s1,0xf
    800024b4:	2f048493          	addi	s1,s1,752 # 800117a0 <proc>
    800024b8:	b7f1                	j	80002484 <scheduler_lottery+0x60>
    int winning_ticket = rand() % total_tickets;
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	4be080e7          	jalr	1214(ra) # 80001978 <rand>
    800024c2:	03657b33          	remu	s6,a0,s6
    800024c6:	2b01                	sext.w	s6,s6
    int current_ticket = 0;
    800024c8:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    800024ca:	0000f497          	auipc	s1,0xf
    800024ce:	2d648493          	addi	s1,s1,726 # 800117a0 <proc>
    800024d2:	a811                	j	800024e6 <scheduler_lottery+0xc2>
      release(&p->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	818080e7          	jalr	-2024(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024de:	35048493          	addi	s1,s1,848
    800024e2:	fd2480e3          	beq	s1,s2,800024a2 <scheduler_lottery+0x7e>
      acquire(&p->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	756080e7          	jalr	1878(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    800024f0:	4c9c                	lw	a5,24(s1)
    800024f2:	ff3791e3          	bne	a5,s3,800024d4 <scheduler_lottery+0xb0>
        current_ticket += p->tickets;
    800024f6:	0c04a783          	lw	a5,192(s1)
    800024fa:	01478a3b          	addw	s4,a5,s4
        if (current_ticket > winning_ticket)
    800024fe:	fd4b5be3          	bge	s6,s4,800024d4 <scheduler_lottery+0xb0>
          release(&p->lock);
    80002502:	8526                	mv	a0,s1
    80002504:	ffffe097          	auipc	ra,0xffffe
    80002508:	7ea080e7          	jalr	2026(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    8000250c:	0000fa17          	auipc	s4,0xf
    80002510:	294a0a13          	addi	s4,s4,660 # 800117a0 <proc>
    80002514:	a811                	j	80002528 <scheduler_lottery+0x104>
          release(&p->lock);
    80002516:	8552                	mv	a0,s4
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	7d6080e7          	jalr	2006(ra) # 80000cee <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002520:	350a0a13          	addi	s4,s4,848
    80002524:	032a0a63          	beq	s4,s2,80002558 <scheduler_lottery+0x134>
        if (p != selected_proc)
    80002528:	fe9a0ce3          	beq	s4,s1,80002520 <scheduler_lottery+0xfc>
          acquire(&p->lock);
    8000252c:	8552                	mv	a0,s4
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	710080e7          	jalr	1808(ra) # 80000c3e <acquire>
          if (p->state == RUNNABLE && p->tickets == selected_proc->tickets && p->arrival_time < selected_proc->arrival_time)
    80002536:	018a2783          	lw	a5,24(s4)
    8000253a:	fd379ee3          	bne	a5,s3,80002516 <scheduler_lottery+0xf2>
    8000253e:	0c0a2703          	lw	a4,192(s4)
    80002542:	0c04a783          	lw	a5,192(s1)
    80002546:	fcf718e3          	bne	a4,a5,80002516 <scheduler_lottery+0xf2>
    8000254a:	0c8a3703          	ld	a4,200(s4)
    8000254e:	64fc                	ld	a5,200(s1)
    80002550:	fcf773e3          	bgeu	a4,a5,80002516 <scheduler_lottery+0xf2>
            selected_proc = p;
    80002554:	84d2                	mv	s1,s4
    80002556:	b7c1                	j	80002516 <scheduler_lottery+0xf2>
      acquire(&selected_proc->lock);
    80002558:	8a26                	mv	s4,s1
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	6e2080e7          	jalr	1762(ra) # 80000c3e <acquire>
      if (selected_proc->state == RUNNABLE)
    80002564:	4c9c                	lw	a5,24(s1)
    80002566:	01378863          	beq	a5,s3,80002576 <scheduler_lottery+0x152>
      release(&selected_proc->lock);
    8000256a:	8552                	mv	a0,s4
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	782080e7          	jalr	1922(ra) # 80000cee <release>
    80002574:	b73d                	j	800024a2 <scheduler_lottery+0x7e>
        selected_proc->state = RUNNING;
    80002576:	4791                	li	a5,4
    80002578:	cc9c                	sw	a5,24(s1)
        c->proc = selected_proc;
    8000257a:	049ab023          	sd	s1,64(s5)
        swtch(&c->context, &selected_proc->context);
    8000257e:	23848593          	addi	a1,s1,568
    80002582:	855e                	mv	a0,s7
    80002584:	00001097          	auipc	ra,0x1
    80002588:	87e080e7          	jalr	-1922(ra) # 80002e02 <swtch>
        c->proc = 0;
    8000258c:	040ab023          	sd	zero,64(s5)
    80002590:	bfe9                	j	8000256a <scheduler_lottery+0x146>

0000000080002592 <scheduler>:
{
    80002592:	1141                	addi	sp,sp,-16
    80002594:	e406                	sd	ra,8(sp)
    80002596:	e022                	sd	s0,0(sp)
    80002598:	0800                	addi	s0,sp,16
      scheduler_mlfq();
    8000259a:	00000097          	auipc	ra,0x0
    8000259e:	c8c080e7          	jalr	-884(ra) # 80002226 <scheduler_mlfq>

00000000800025a2 <sched>:
{
    800025a2:	7179                	addi	sp,sp,-48
    800025a4:	f406                	sd	ra,40(sp)
    800025a6:	f022                	sd	s0,32(sp)
    800025a8:	ec26                	sd	s1,24(sp)
    800025aa:	e84a                	sd	s2,16(sp)
    800025ac:	e44e                	sd	s3,8(sp)
    800025ae:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	646080e7          	jalr	1606(ra) # 80001bf6 <myproc>
    800025b8:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	60a080e7          	jalr	1546(ra) # 80000bc4 <holding>
    800025c2:	c93d                	beqz	a0,80002638 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025c4:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800025c6:	2781                	sext.w	a5,a5
    800025c8:	079e                	slli	a5,a5,0x7
    800025ca:	0000e717          	auipc	a4,0xe
    800025ce:	59670713          	addi	a4,a4,1430 # 80010b60 <queues_sizes>
    800025d2:	97ba                	add	a5,a5,a4
    800025d4:	0b87a703          	lw	a4,184(a5)
    800025d8:	4785                	li	a5,1
    800025da:	06f71763          	bne	a4,a5,80002648 <sched+0xa6>
  if (p->state == RUNNING)
    800025de:	4c98                	lw	a4,24(s1)
    800025e0:	4791                	li	a5,4
    800025e2:	06f70b63          	beq	a4,a5,80002658 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025ea:	8b89                	andi	a5,a5,2
  if (intr_get())
    800025ec:	efb5                	bnez	a5,80002668 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ee:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025f0:	0000e917          	auipc	s2,0xe
    800025f4:	57090913          	addi	s2,s2,1392 # 80010b60 <queues_sizes>
    800025f8:	2781                	sext.w	a5,a5
    800025fa:	079e                	slli	a5,a5,0x7
    800025fc:	97ca                	add	a5,a5,s2
    800025fe:	0bc7a983          	lw	s3,188(a5)
    80002602:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002604:	2781                	sext.w	a5,a5
    80002606:	079e                	slli	a5,a5,0x7
    80002608:	0000e597          	auipc	a1,0xe
    8000260c:	5a058593          	addi	a1,a1,1440 # 80010ba8 <cpus+0x8>
    80002610:	95be                	add	a1,a1,a5
    80002612:	23848513          	addi	a0,s1,568
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	7ec080e7          	jalr	2028(ra) # 80002e02 <swtch>
    8000261e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002620:	2781                	sext.w	a5,a5
    80002622:	079e                	slli	a5,a5,0x7
    80002624:	993e                	add	s2,s2,a5
    80002626:	0b392e23          	sw	s3,188(s2)
}
    8000262a:	70a2                	ld	ra,40(sp)
    8000262c:	7402                	ld	s0,32(sp)
    8000262e:	64e2                	ld	s1,24(sp)
    80002630:	6942                	ld	s2,16(sp)
    80002632:	69a2                	ld	s3,8(sp)
    80002634:	6145                	addi	sp,sp,48
    80002636:	8082                	ret
    panic("sched p->lock");
    80002638:	00006517          	auipc	a0,0x6
    8000263c:	bc050513          	addi	a0,a0,-1088 # 800081f8 <etext+0x1f8>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	f20080e7          	jalr	-224(ra) # 80000560 <panic>
    panic("sched locks");
    80002648:	00006517          	auipc	a0,0x6
    8000264c:	bc050513          	addi	a0,a0,-1088 # 80008208 <etext+0x208>
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	f10080e7          	jalr	-240(ra) # 80000560 <panic>
    panic("sched running");
    80002658:	00006517          	auipc	a0,0x6
    8000265c:	bc050513          	addi	a0,a0,-1088 # 80008218 <etext+0x218>
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
    panic("sched interruptible");
    80002668:	00006517          	auipc	a0,0x6
    8000266c:	bc050513          	addi	a0,a0,-1088 # 80008228 <etext+0x228>
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>

0000000080002678 <yield>:
{
    80002678:	1101                	addi	sp,sp,-32
    8000267a:	ec06                	sd	ra,24(sp)
    8000267c:	e822                	sd	s0,16(sp)
    8000267e:	e426                	sd	s1,8(sp)
    80002680:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	574080e7          	jalr	1396(ra) # 80001bf6 <myproc>
    8000268a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	5b2080e7          	jalr	1458(ra) # 80000c3e <acquire>
  p->state = RUNNABLE;
    80002694:	478d                	li	a5,3
    80002696:	cc9c                	sw	a5,24(s1)
  sched();
    80002698:	00000097          	auipc	ra,0x0
    8000269c:	f0a080e7          	jalr	-246(ra) # 800025a2 <sched>
  release(&p->lock);
    800026a0:	8526                	mv	a0,s1
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	64c080e7          	jalr	1612(ra) # 80000cee <release>
}
    800026aa:	60e2                	ld	ra,24(sp)
    800026ac:	6442                	ld	s0,16(sp)
    800026ae:	64a2                	ld	s1,8(sp)
    800026b0:	6105                	addi	sp,sp,32
    800026b2:	8082                	ret

00000000800026b4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800026b4:	7179                	addi	sp,sp,-48
    800026b6:	f406                	sd	ra,40(sp)
    800026b8:	f022                	sd	s0,32(sp)
    800026ba:	ec26                	sd	s1,24(sp)
    800026bc:	e84a                	sd	s2,16(sp)
    800026be:	e44e                	sd	s3,8(sp)
    800026c0:	1800                	addi	s0,sp,48
    800026c2:	89aa                	mv	s3,a0
    800026c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	530080e7          	jalr	1328(ra) # 80001bf6 <myproc>
    800026ce:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	56e080e7          	jalr	1390(ra) # 80000c3e <acquire>
  release(lk);
    800026d8:	854a                	mv	a0,s2
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	614080e7          	jalr	1556(ra) # 80000cee <release>

  // Go to sleep.
  p->chan = chan;
    800026e2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800026e6:	4789                	li	a5,2
    800026e8:	cc9c                	sw	a5,24(s1)

  sched();
    800026ea:	00000097          	auipc	ra,0x0
    800026ee:	eb8080e7          	jalr	-328(ra) # 800025a2 <sched>

  // Tidy up.
  p->chan = 0;
    800026f2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800026f6:	8526                	mv	a0,s1
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	5f6080e7          	jalr	1526(ra) # 80000cee <release>
  acquire(lk);
    80002700:	854a                	mv	a0,s2
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	53c080e7          	jalr	1340(ra) # 80000c3e <acquire>
}
    8000270a:	70a2                	ld	ra,40(sp)
    8000270c:	7402                	ld	s0,32(sp)
    8000270e:	64e2                	ld	s1,24(sp)
    80002710:	6942                	ld	s2,16(sp)
    80002712:	69a2                	ld	s3,8(sp)
    80002714:	6145                	addi	sp,sp,48
    80002716:	8082                	ret

0000000080002718 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002718:	7139                	addi	sp,sp,-64
    8000271a:	fc06                	sd	ra,56(sp)
    8000271c:	f822                	sd	s0,48(sp)
    8000271e:	f426                	sd	s1,40(sp)
    80002720:	f04a                	sd	s2,32(sp)
    80002722:	ec4e                	sd	s3,24(sp)
    80002724:	e852                	sd	s4,16(sp)
    80002726:	e456                	sd	s5,8(sp)
    80002728:	0080                	addi	s0,sp,64
    8000272a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000272c:	0000f497          	auipc	s1,0xf
    80002730:	07448493          	addi	s1,s1,116 # 800117a0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002734:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002736:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002738:	0001c917          	auipc	s2,0x1c
    8000273c:	46890913          	addi	s2,s2,1128 # 8001eba0 <tickslock>
    80002740:	a811                	j	80002754 <wakeup+0x3c>
        Enqueue(p, p->priority);
      }
      release(&p->lock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	5aa080e7          	jalr	1450(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000274c:	35048493          	addi	s1,s1,848
    80002750:	03248d63          	beq	s1,s2,8000278a <wakeup+0x72>
    if (p != myproc())
    80002754:	fffff097          	auipc	ra,0xfffff
    80002758:	4a2080e7          	jalr	1186(ra) # 80001bf6 <myproc>
    8000275c:	fea488e3          	beq	s1,a0,8000274c <wakeup+0x34>
      acquire(&p->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	4dc080e7          	jalr	1244(ra) # 80000c3e <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000276a:	4c9c                	lw	a5,24(s1)
    8000276c:	fd379be3          	bne	a5,s3,80002742 <wakeup+0x2a>
    80002770:	709c                	ld	a5,32(s1)
    80002772:	fd4798e3          	bne	a5,s4,80002742 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002776:	0154ac23          	sw	s5,24(s1)
        Enqueue(p, p->priority);
    8000277a:	0d84a583          	lw	a1,216(s1)
    8000277e:	8526                	mv	a0,s1
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	23e080e7          	jalr	574(ra) # 800019be <Enqueue>
    80002788:	bf6d                	j	80002742 <wakeup+0x2a>
    }
  }
}
    8000278a:	70e2                	ld	ra,56(sp)
    8000278c:	7442                	ld	s0,48(sp)
    8000278e:	74a2                	ld	s1,40(sp)
    80002790:	7902                	ld	s2,32(sp)
    80002792:	69e2                	ld	s3,24(sp)
    80002794:	6a42                	ld	s4,16(sp)
    80002796:	6aa2                	ld	s5,8(sp)
    80002798:	6121                	addi	sp,sp,64
    8000279a:	8082                	ret

000000008000279c <reparent>:
{
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	e052                	sd	s4,0(sp)
    800027aa:	1800                	addi	s0,sp,48
    800027ac:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ae:	0000f497          	auipc	s1,0xf
    800027b2:	ff248493          	addi	s1,s1,-14 # 800117a0 <proc>
      pp->parent = initproc;
    800027b6:	00006a17          	auipc	s4,0x6
    800027ba:	132a0a13          	addi	s4,s4,306 # 800088e8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800027be:	0001c997          	auipc	s3,0x1c
    800027c2:	3e298993          	addi	s3,s3,994 # 8001eba0 <tickslock>
    800027c6:	a029                	j	800027d0 <reparent+0x34>
    800027c8:	35048493          	addi	s1,s1,848
    800027cc:	01348d63          	beq	s1,s3,800027e6 <reparent+0x4a>
    if (pp->parent == p)
    800027d0:	7c9c                	ld	a5,56(s1)
    800027d2:	ff279be3          	bne	a5,s2,800027c8 <reparent+0x2c>
      pp->parent = initproc;
    800027d6:	000a3503          	ld	a0,0(s4)
    800027da:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800027dc:	00000097          	auipc	ra,0x0
    800027e0:	f3c080e7          	jalr	-196(ra) # 80002718 <wakeup>
    800027e4:	b7d5                	j	800027c8 <reparent+0x2c>
}
    800027e6:	70a2                	ld	ra,40(sp)
    800027e8:	7402                	ld	s0,32(sp)
    800027ea:	64e2                	ld	s1,24(sp)
    800027ec:	6942                	ld	s2,16(sp)
    800027ee:	69a2                	ld	s3,8(sp)
    800027f0:	6a02                	ld	s4,0(sp)
    800027f2:	6145                	addi	sp,sp,48
    800027f4:	8082                	ret

00000000800027f6 <exit>:
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	e44e                	sd	s3,8(sp)
    80002802:	e052                	sd	s4,0(sp)
    80002804:	1800                	addi	s0,sp,48
    80002806:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002808:	fffff097          	auipc	ra,0xfffff
    8000280c:	3ee080e7          	jalr	1006(ra) # 80001bf6 <myproc>
    80002810:	89aa                	mv	s3,a0
  if (p == initproc)
    80002812:	00006797          	auipc	a5,0x6
    80002816:	0d67b783          	ld	a5,214(a5) # 800088e8 <initproc>
    8000281a:	2a850493          	addi	s1,a0,680
    8000281e:	32850913          	addi	s2,a0,808
    80002822:	00a79d63          	bne	a5,a0,8000283c <exit+0x46>
    panic("init exiting");
    80002826:	00006517          	auipc	a0,0x6
    8000282a:	a1a50513          	addi	a0,a0,-1510 # 80008240 <etext+0x240>
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	d32080e7          	jalr	-718(ra) # 80000560 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002836:	04a1                	addi	s1,s1,8
    80002838:	01248b63          	beq	s1,s2,8000284e <exit+0x58>
    if (p->ofile[fd])
    8000283c:	6088                	ld	a0,0(s1)
    8000283e:	dd65                	beqz	a0,80002836 <exit+0x40>
      fileclose(f);
    80002840:	00002097          	auipc	ra,0x2
    80002844:	758080e7          	jalr	1880(ra) # 80004f98 <fileclose>
      p->ofile[fd] = 0;
    80002848:	0004b023          	sd	zero,0(s1)
    8000284c:	b7ed                	j	80002836 <exit+0x40>
  begin_op();
    8000284e:	00002097          	auipc	ra,0x2
    80002852:	27a080e7          	jalr	634(ra) # 80004ac8 <begin_op>
  iput(p->cwd);
    80002856:	3289b503          	ld	a0,808(s3)
    8000285a:	00002097          	auipc	ra,0x2
    8000285e:	a42080e7          	jalr	-1470(ra) # 8000429c <iput>
  end_op();
    80002862:	00002097          	auipc	ra,0x2
    80002866:	2e0080e7          	jalr	736(ra) # 80004b42 <end_op>
  p->cwd = 0;
    8000286a:	3209b423          	sd	zero,808(s3)
  acquire(&wait_lock);
    8000286e:	0000e497          	auipc	s1,0xe
    80002872:	31a48493          	addi	s1,s1,794 # 80010b88 <wait_lock>
    80002876:	8526                	mv	a0,s1
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	3c6080e7          	jalr	966(ra) # 80000c3e <acquire>
  reparent(p);
    80002880:	854e                	mv	a0,s3
    80002882:	00000097          	auipc	ra,0x0
    80002886:	f1a080e7          	jalr	-230(ra) # 8000279c <reparent>
  wakeup(p->parent);
    8000288a:	0389b503          	ld	a0,56(s3)
    8000288e:	00000097          	auipc	ra,0x0
    80002892:	e8a080e7          	jalr	-374(ra) # 80002718 <wakeup>
  acquire(&p->lock);
    80002896:	854e                	mv	a0,s3
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	3a6080e7          	jalr	934(ra) # 80000c3e <acquire>
  p->xstate = status;
    800028a0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800028a4:	4795                	li	a5,5
    800028a6:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800028aa:	00006797          	auipc	a5,0x6
    800028ae:	04a7a783          	lw	a5,74(a5) # 800088f4 <ticks>
    800028b2:	34f9a423          	sw	a5,840(s3)
  release(&wait_lock);
    800028b6:	8526                	mv	a0,s1
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	436080e7          	jalr	1078(ra) # 80000cee <release>
  sched();
    800028c0:	00000097          	auipc	ra,0x0
    800028c4:	ce2080e7          	jalr	-798(ra) # 800025a2 <sched>
  panic("zombie exit");
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	98850513          	addi	a0,a0,-1656 # 80008250 <etext+0x250>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	c90080e7          	jalr	-880(ra) # 80000560 <panic>

00000000800028d8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800028d8:	7179                	addi	sp,sp,-48
    800028da:	f406                	sd	ra,40(sp)
    800028dc:	f022                	sd	s0,32(sp)
    800028de:	ec26                	sd	s1,24(sp)
    800028e0:	e84a                	sd	s2,16(sp)
    800028e2:	e44e                	sd	s3,8(sp)
    800028e4:	1800                	addi	s0,sp,48
    800028e6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800028e8:	0000f497          	auipc	s1,0xf
    800028ec:	eb848493          	addi	s1,s1,-328 # 800117a0 <proc>
    800028f0:	0001c997          	auipc	s3,0x1c
    800028f4:	2b098993          	addi	s3,s3,688 # 8001eba0 <tickslock>
  {
    acquire(&p->lock);
    800028f8:	8526                	mv	a0,s1
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	344080e7          	jalr	836(ra) # 80000c3e <acquire>
    if (p->pid == pid)
    80002902:	589c                	lw	a5,48(s1)
    80002904:	01278d63          	beq	a5,s2,8000291e <kill+0x46>
        Enqueue(p, p->priority);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002908:	8526                	mv	a0,s1
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	3e4080e7          	jalr	996(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002912:	35048493          	addi	s1,s1,848
    80002916:	ff3491e3          	bne	s1,s3,800028f8 <kill+0x20>
  }
  return -1;
    8000291a:	557d                	li	a0,-1
    8000291c:	a829                	j	80002936 <kill+0x5e>
      p->killed = 1;
    8000291e:	4785                	li	a5,1
    80002920:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002922:	4c98                	lw	a4,24(s1)
    80002924:	4789                	li	a5,2
    80002926:	00f70f63          	beq	a4,a5,80002944 <kill+0x6c>
      release(&p->lock);
    8000292a:	8526                	mv	a0,s1
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	3c2080e7          	jalr	962(ra) # 80000cee <release>
      return 0;
    80002934:	4501                	li	a0,0
}
    80002936:	70a2                	ld	ra,40(sp)
    80002938:	7402                	ld	s0,32(sp)
    8000293a:	64e2                	ld	s1,24(sp)
    8000293c:	6942                	ld	s2,16(sp)
    8000293e:	69a2                	ld	s3,8(sp)
    80002940:	6145                	addi	sp,sp,48
    80002942:	8082                	ret
        p->state = RUNNABLE;
    80002944:	478d                	li	a5,3
    80002946:	cc9c                	sw	a5,24(s1)
        Enqueue(p, p->priority);
    80002948:	0d84a583          	lw	a1,216(s1)
    8000294c:	8526                	mv	a0,s1
    8000294e:	fffff097          	auipc	ra,0xfffff
    80002952:	070080e7          	jalr	112(ra) # 800019be <Enqueue>
    80002956:	bfd1                	j	8000292a <kill+0x52>

0000000080002958 <setkilled>:

void setkilled(struct proc *p)
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	1000                	addi	s0,sp,32
    80002962:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	2da080e7          	jalr	730(ra) # 80000c3e <acquire>
  p->killed = 1;
    8000296c:	4785                	li	a5,1
    8000296e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002970:	8526                	mv	a0,s1
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	37c080e7          	jalr	892(ra) # 80000cee <release>
}
    8000297a:	60e2                	ld	ra,24(sp)
    8000297c:	6442                	ld	s0,16(sp)
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret

0000000080002984 <killed>:

int killed(struct proc *p)
{
    80002984:	1101                	addi	sp,sp,-32
    80002986:	ec06                	sd	ra,24(sp)
    80002988:	e822                	sd	s0,16(sp)
    8000298a:	e426                	sd	s1,8(sp)
    8000298c:	e04a                	sd	s2,0(sp)
    8000298e:	1000                	addi	s0,sp,32
    80002990:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	2ac080e7          	jalr	684(ra) # 80000c3e <acquire>
  k = p->killed;
    8000299a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000299e:	8526                	mv	a0,s1
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	34e080e7          	jalr	846(ra) # 80000cee <release>
  return k;
}
    800029a8:	854a                	mv	a0,s2
    800029aa:	60e2                	ld	ra,24(sp)
    800029ac:	6442                	ld	s0,16(sp)
    800029ae:	64a2                	ld	s1,8(sp)
    800029b0:	6902                	ld	s2,0(sp)
    800029b2:	6105                	addi	sp,sp,32
    800029b4:	8082                	ret

00000000800029b6 <wait>:
{
    800029b6:	715d                	addi	sp,sp,-80
    800029b8:	e486                	sd	ra,72(sp)
    800029ba:	e0a2                	sd	s0,64(sp)
    800029bc:	fc26                	sd	s1,56(sp)
    800029be:	f84a                	sd	s2,48(sp)
    800029c0:	f44e                	sd	s3,40(sp)
    800029c2:	f052                	sd	s4,32(sp)
    800029c4:	ec56                	sd	s5,24(sp)
    800029c6:	e85a                	sd	s6,16(sp)
    800029c8:	e45e                	sd	s7,8(sp)
    800029ca:	0880                	addi	s0,sp,80
    800029cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	228080e7          	jalr	552(ra) # 80001bf6 <myproc>
    800029d6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800029d8:	0000e517          	auipc	a0,0xe
    800029dc:	1b050513          	addi	a0,a0,432 # 80010b88 <wait_lock>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	25e080e7          	jalr	606(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    800029e8:	4a95                	li	s5,5
        havekids = 1;
    800029ea:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800029ec:	0001c997          	auipc	s3,0x1c
    800029f0:	1b498993          	addi	s3,s3,436 # 8001eba0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800029f4:	0000eb97          	auipc	s7,0xe
    800029f8:	194b8b93          	addi	s7,s7,404 # 80010b88 <wait_lock>
    800029fc:	a0cd                	j	80002ade <wait+0x128>
    800029fe:	04048613          	addi	a2,s1,64
          for (int i = 0; i <= 25; i++)
    80002a02:	4701                	li	a4,0
    80002a04:	4569                	li	a0,26
            pp->parent->syscall_count[i] += pp->syscall_count[i];
    80002a06:	00271693          	slli	a3,a4,0x2
    80002a0a:	7c9c                	ld	a5,56(s1)
    80002a0c:	97b6                	add	a5,a5,a3
    80002a0e:	43ac                	lw	a1,64(a5)
    80002a10:	4214                	lw	a3,0(a2)
    80002a12:	9ead                	addw	a3,a3,a1
    80002a14:	c3b4                	sw	a3,64(a5)
          for (int i = 0; i <= 25; i++)
    80002a16:	2705                	addiw	a4,a4,1
    80002a18:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80002a1a:	fea716e3          	bne	a4,a0,80002a06 <wait+0x50>
          pid = pp->pid;
    80002a1e:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a22:	000a0e63          	beqz	s4,80002a3e <wait+0x88>
    80002a26:	4691                	li	a3,4
    80002a28:	02c48613          	addi	a2,s1,44
    80002a2c:	85d2                	mv	a1,s4
    80002a2e:	22893503          	ld	a0,552(s2)
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	cde080e7          	jalr	-802(ra) # 80001710 <copyout>
    80002a3a:	04054063          	bltz	a0,80002a7a <wait+0xc4>
          freeproc(pp);
    80002a3e:	8526                	mv	a0,s1
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	368080e7          	jalr	872(ra) # 80001da8 <freeproc>
          release(&pp->lock);
    80002a48:	8526                	mv	a0,s1
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	2a4080e7          	jalr	676(ra) # 80000cee <release>
          release(&wait_lock);
    80002a52:	0000e517          	auipc	a0,0xe
    80002a56:	13650513          	addi	a0,a0,310 # 80010b88 <wait_lock>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	294080e7          	jalr	660(ra) # 80000cee <release>
}
    80002a62:	854e                	mv	a0,s3
    80002a64:	60a6                	ld	ra,72(sp)
    80002a66:	6406                	ld	s0,64(sp)
    80002a68:	74e2                	ld	s1,56(sp)
    80002a6a:	7942                	ld	s2,48(sp)
    80002a6c:	79a2                	ld	s3,40(sp)
    80002a6e:	7a02                	ld	s4,32(sp)
    80002a70:	6ae2                	ld	s5,24(sp)
    80002a72:	6b42                	ld	s6,16(sp)
    80002a74:	6ba2                	ld	s7,8(sp)
    80002a76:	6161                	addi	sp,sp,80
    80002a78:	8082                	ret
            release(&pp->lock);
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	272080e7          	jalr	626(ra) # 80000cee <release>
            release(&wait_lock);
    80002a84:	0000e517          	auipc	a0,0xe
    80002a88:	10450513          	addi	a0,a0,260 # 80010b88 <wait_lock>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	262080e7          	jalr	610(ra) # 80000cee <release>
            return -1;
    80002a94:	59fd                	li	s3,-1
    80002a96:	b7f1                	j	80002a62 <wait+0xac>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a98:	35048493          	addi	s1,s1,848
    80002a9c:	03348463          	beq	s1,s3,80002ac4 <wait+0x10e>
      if (pp->parent == p)
    80002aa0:	7c9c                	ld	a5,56(s1)
    80002aa2:	ff279be3          	bne	a5,s2,80002a98 <wait+0xe2>
        acquire(&pp->lock);
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	196080e7          	jalr	406(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    80002ab0:	4c9c                	lw	a5,24(s1)
    80002ab2:	f55786e3          	beq	a5,s5,800029fe <wait+0x48>
        release(&pp->lock);
    80002ab6:	8526                	mv	a0,s1
    80002ab8:	ffffe097          	auipc	ra,0xffffe
    80002abc:	236080e7          	jalr	566(ra) # 80000cee <release>
        havekids = 1;
    80002ac0:	875a                	mv	a4,s6
    80002ac2:	bfd9                	j	80002a98 <wait+0xe2>
    if (!havekids || killed(p))
    80002ac4:	c31d                	beqz	a4,80002aea <wait+0x134>
    80002ac6:	854a                	mv	a0,s2
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	ebc080e7          	jalr	-324(ra) # 80002984 <killed>
    80002ad0:	ed09                	bnez	a0,80002aea <wait+0x134>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002ad2:	85de                	mv	a1,s7
    80002ad4:	854a                	mv	a0,s2
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	bde080e7          	jalr	-1058(ra) # 800026b4 <sleep>
    havekids = 0;
    80002ade:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002ae0:	0000f497          	auipc	s1,0xf
    80002ae4:	cc048493          	addi	s1,s1,-832 # 800117a0 <proc>
    80002ae8:	bf65                	j	80002aa0 <wait+0xea>
      release(&wait_lock);
    80002aea:	0000e517          	auipc	a0,0xe
    80002aee:	09e50513          	addi	a0,a0,158 # 80010b88 <wait_lock>
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	1fc080e7          	jalr	508(ra) # 80000cee <release>
      return -1;
    80002afa:	59fd                	li	s3,-1
    80002afc:	b79d                	j	80002a62 <wait+0xac>

0000000080002afe <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002afe:	7179                	addi	sp,sp,-48
    80002b00:	f406                	sd	ra,40(sp)
    80002b02:	f022                	sd	s0,32(sp)
    80002b04:	ec26                	sd	s1,24(sp)
    80002b06:	e84a                	sd	s2,16(sp)
    80002b08:	e44e                	sd	s3,8(sp)
    80002b0a:	e052                	sd	s4,0(sp)
    80002b0c:	1800                	addi	s0,sp,48
    80002b0e:	84aa                	mv	s1,a0
    80002b10:	892e                	mv	s2,a1
    80002b12:	89b2                	mv	s3,a2
    80002b14:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b16:	fffff097          	auipc	ra,0xfffff
    80002b1a:	0e0080e7          	jalr	224(ra) # 80001bf6 <myproc>
  if (user_dst)
    80002b1e:	c095                	beqz	s1,80002b42 <either_copyout+0x44>
  {
    return copyout(p->pagetable, dst, src, len);
    80002b20:	86d2                	mv	a3,s4
    80002b22:	864e                	mv	a2,s3
    80002b24:	85ca                	mv	a1,s2
    80002b26:	22853503          	ld	a0,552(a0)
    80002b2a:	fffff097          	auipc	ra,0xfffff
    80002b2e:	be6080e7          	jalr	-1050(ra) # 80001710 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b32:	70a2                	ld	ra,40(sp)
    80002b34:	7402                	ld	s0,32(sp)
    80002b36:	64e2                	ld	s1,24(sp)
    80002b38:	6942                	ld	s2,16(sp)
    80002b3a:	69a2                	ld	s3,8(sp)
    80002b3c:	6a02                	ld	s4,0(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret
    memmove((char *)dst, src, len);
    80002b42:	000a061b          	sext.w	a2,s4
    80002b46:	85ce                	mv	a1,s3
    80002b48:	854a                	mv	a0,s2
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	250080e7          	jalr	592(ra) # 80000d9a <memmove>
    return 0;
    80002b52:	8526                	mv	a0,s1
    80002b54:	bff9                	j	80002b32 <either_copyout+0x34>

0000000080002b56 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b56:	7179                	addi	sp,sp,-48
    80002b58:	f406                	sd	ra,40(sp)
    80002b5a:	f022                	sd	s0,32(sp)
    80002b5c:	ec26                	sd	s1,24(sp)
    80002b5e:	e84a                	sd	s2,16(sp)
    80002b60:	e44e                	sd	s3,8(sp)
    80002b62:	e052                	sd	s4,0(sp)
    80002b64:	1800                	addi	s0,sp,48
    80002b66:	892a                	mv	s2,a0
    80002b68:	84ae                	mv	s1,a1
    80002b6a:	89b2                	mv	s3,a2
    80002b6c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	088080e7          	jalr	136(ra) # 80001bf6 <myproc>
  if (user_src)
    80002b76:	c095                	beqz	s1,80002b9a <either_copyin+0x44>
  {
    return copyin(p->pagetable, dst, src, len);
    80002b78:	86d2                	mv	a3,s4
    80002b7a:	864e                	mv	a2,s3
    80002b7c:	85ca                	mv	a1,s2
    80002b7e:	22853503          	ld	a0,552(a0)
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	c1a080e7          	jalr	-998(ra) # 8000179c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002b8a:	70a2                	ld	ra,40(sp)
    80002b8c:	7402                	ld	s0,32(sp)
    80002b8e:	64e2                	ld	s1,24(sp)
    80002b90:	6942                	ld	s2,16(sp)
    80002b92:	69a2                	ld	s3,8(sp)
    80002b94:	6a02                	ld	s4,0(sp)
    80002b96:	6145                	addi	sp,sp,48
    80002b98:	8082                	ret
    memmove(dst, (char *)src, len);
    80002b9a:	000a061b          	sext.w	a2,s4
    80002b9e:	85ce                	mv	a1,s3
    80002ba0:	854a                	mv	a0,s2
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	1f8080e7          	jalr	504(ra) # 80000d9a <memmove>
    return 0;
    80002baa:	8526                	mv	a0,s1
    80002bac:	bff9                	j	80002b8a <either_copyin+0x34>

0000000080002bae <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002bae:	715d                	addi	sp,sp,-80
    80002bb0:	e486                	sd	ra,72(sp)
    80002bb2:	e0a2                	sd	s0,64(sp)
    80002bb4:	fc26                	sd	s1,56(sp)
    80002bb6:	f84a                	sd	s2,48(sp)
    80002bb8:	f44e                	sd	s3,40(sp)
    80002bba:	f052                	sd	s4,32(sp)
    80002bbc:	ec56                	sd	s5,24(sp)
    80002bbe:	e85a                	sd	s6,16(sp)
    80002bc0:	e45e                	sd	s7,8(sp)
    80002bc2:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002bc4:	00005517          	auipc	a0,0x5
    80002bc8:	44c50513          	addi	a0,a0,1100 # 80008010 <etext+0x10>
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	9de080e7          	jalr	-1570(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002bd4:	0000f497          	auipc	s1,0xf
    80002bd8:	efc48493          	addi	s1,s1,-260 # 80011ad0 <proc+0x330>
    80002bdc:	0001c917          	auipc	s2,0x1c
    80002be0:	2f490913          	addi	s2,s2,756 # 8001eed0 <bcache+0x318>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002be4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002be6:	00005997          	auipc	s3,0x5
    80002bea:	67a98993          	addi	s3,s3,1658 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002bee:	00005a97          	auipc	s5,0x5
    80002bf2:	67aa8a93          	addi	s5,s5,1658 # 80008268 <etext+0x268>
    printf("\n");
    80002bf6:	00005a17          	auipc	s4,0x5
    80002bfa:	41aa0a13          	addi	s4,s4,1050 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bfe:	00006b97          	auipc	s7,0x6
    80002c02:	b42b8b93          	addi	s7,s7,-1214 # 80008740 <states.0>
    80002c06:	a00d                	j	80002c28 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002c08:	d006a583          	lw	a1,-768(a3)
    80002c0c:	8556                	mv	a0,s5
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	99c080e7          	jalr	-1636(ra) # 800005aa <printf>
    printf("\n");
    80002c16:	8552                	mv	a0,s4
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	992080e7          	jalr	-1646(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002c20:	35048493          	addi	s1,s1,848
    80002c24:	03248263          	beq	s1,s2,80002c48 <procdump+0x9a>
    if (p->state == UNUSED)
    80002c28:	86a6                	mv	a3,s1
    80002c2a:	ce84a783          	lw	a5,-792(s1)
    80002c2e:	dbed                	beqz	a5,80002c20 <procdump+0x72>
      state = "???";
    80002c30:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c32:	fcfb6be3          	bltu	s6,a5,80002c08 <procdump+0x5a>
    80002c36:	02079713          	slli	a4,a5,0x20
    80002c3a:	01d75793          	srli	a5,a4,0x1d
    80002c3e:	97de                	add	a5,a5,s7
    80002c40:	6390                	ld	a2,0(a5)
    80002c42:	f279                	bnez	a2,80002c08 <procdump+0x5a>
      state = "???";
    80002c44:	864e                	mv	a2,s3
    80002c46:	b7c9                	j	80002c08 <procdump+0x5a>
  }
}
    80002c48:	60a6                	ld	ra,72(sp)
    80002c4a:	6406                	ld	s0,64(sp)
    80002c4c:	74e2                	ld	s1,56(sp)
    80002c4e:	7942                	ld	s2,48(sp)
    80002c50:	79a2                	ld	s3,40(sp)
    80002c52:	7a02                	ld	s4,32(sp)
    80002c54:	6ae2                	ld	s5,24(sp)
    80002c56:	6b42                	ld	s6,16(sp)
    80002c58:	6ba2                	ld	s7,8(sp)
    80002c5a:	6161                	addi	sp,sp,80
    80002c5c:	8082                	ret

0000000080002c5e <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002c5e:	711d                	addi	sp,sp,-96
    80002c60:	ec86                	sd	ra,88(sp)
    80002c62:	e8a2                	sd	s0,80(sp)
    80002c64:	e4a6                	sd	s1,72(sp)
    80002c66:	e0ca                	sd	s2,64(sp)
    80002c68:	fc4e                	sd	s3,56(sp)
    80002c6a:	f852                	sd	s4,48(sp)
    80002c6c:	f456                	sd	s5,40(sp)
    80002c6e:	f05a                	sd	s6,32(sp)
    80002c70:	ec5e                	sd	s7,24(sp)
    80002c72:	e862                	sd	s8,16(sp)
    80002c74:	e466                	sd	s9,8(sp)
    80002c76:	1080                	addi	s0,sp,96
    80002c78:	8b2a                	mv	s6,a0
    80002c7a:	8bae                	mv	s7,a1
    80002c7c:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002c7e:	fffff097          	auipc	ra,0xfffff
    80002c82:	f78080e7          	jalr	-136(ra) # 80001bf6 <myproc>
    80002c86:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002c88:	0000e517          	auipc	a0,0xe
    80002c8c:	f0050513          	addi	a0,a0,-256 # 80010b88 <wait_lock>
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	fae080e7          	jalr	-82(ra) # 80000c3e <acquire>
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002c98:	4a15                	li	s4,5
        havekids = 1;
    80002c9a:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002c9c:	0001c997          	auipc	s3,0x1c
    80002ca0:	f0498993          	addi	s3,s3,-252 # 8001eba0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002ca4:	0000ec97          	auipc	s9,0xe
    80002ca8:	ee4c8c93          	addi	s9,s9,-284 # 80010b88 <wait_lock>
    80002cac:	a8e1                	j	80002d84 <waitx+0x126>
          pid = np->pid;
    80002cae:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002cb2:	3404a783          	lw	a5,832(s1)
    80002cb6:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    80002cba:	3444a703          	lw	a4,836(s1)
    80002cbe:	9f3d                	addw	a4,a4,a5
    80002cc0:	3484a783          	lw	a5,840(s1)
    80002cc4:	9f99                	subw	a5,a5,a4
    80002cc6:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002cca:	000b0e63          	beqz	s6,80002ce6 <waitx+0x88>
    80002cce:	4691                	li	a3,4
    80002cd0:	02c48613          	addi	a2,s1,44
    80002cd4:	85da                	mv	a1,s6
    80002cd6:	22893503          	ld	a0,552(s2)
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	a36080e7          	jalr	-1482(ra) # 80001710 <copyout>
    80002ce2:	04054263          	bltz	a0,80002d26 <waitx+0xc8>
          freeproc(np);
    80002ce6:	8526                	mv	a0,s1
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	0c0080e7          	jalr	192(ra) # 80001da8 <freeproc>
          release(&np->lock);
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	ffc080e7          	jalr	-4(ra) # 80000cee <release>
          release(&wait_lock);
    80002cfa:	0000e517          	auipc	a0,0xe
    80002cfe:	e8e50513          	addi	a0,a0,-370 # 80010b88 <wait_lock>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	fec080e7          	jalr	-20(ra) # 80000cee <release>
  }
}
    80002d0a:	854e                	mv	a0,s3
    80002d0c:	60e6                	ld	ra,88(sp)
    80002d0e:	6446                	ld	s0,80(sp)
    80002d10:	64a6                	ld	s1,72(sp)
    80002d12:	6906                	ld	s2,64(sp)
    80002d14:	79e2                	ld	s3,56(sp)
    80002d16:	7a42                	ld	s4,48(sp)
    80002d18:	7aa2                	ld	s5,40(sp)
    80002d1a:	7b02                	ld	s6,32(sp)
    80002d1c:	6be2                	ld	s7,24(sp)
    80002d1e:	6c42                	ld	s8,16(sp)
    80002d20:	6ca2                	ld	s9,8(sp)
    80002d22:	6125                	addi	sp,sp,96
    80002d24:	8082                	ret
            release(&np->lock);
    80002d26:	8526                	mv	a0,s1
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	fc6080e7          	jalr	-58(ra) # 80000cee <release>
            release(&wait_lock);
    80002d30:	0000e517          	auipc	a0,0xe
    80002d34:	e5850513          	addi	a0,a0,-424 # 80010b88 <wait_lock>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	fb6080e7          	jalr	-74(ra) # 80000cee <release>
            return -1;
    80002d40:	59fd                	li	s3,-1
    80002d42:	b7e1                	j	80002d0a <waitx+0xac>
    for (np = proc; np < &proc[NPROC]; np++)
    80002d44:	35048493          	addi	s1,s1,848
    80002d48:	03348463          	beq	s1,s3,80002d70 <waitx+0x112>
      if (np->parent == p)
    80002d4c:	7c9c                	ld	a5,56(s1)
    80002d4e:	ff279be3          	bne	a5,s2,80002d44 <waitx+0xe6>
        acquire(&np->lock);
    80002d52:	8526                	mv	a0,s1
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	eea080e7          	jalr	-278(ra) # 80000c3e <acquire>
        if (np->state == ZOMBIE)
    80002d5c:	4c9c                	lw	a5,24(s1)
    80002d5e:	f54788e3          	beq	a5,s4,80002cae <waitx+0x50>
        release(&np->lock);
    80002d62:	8526                	mv	a0,s1
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	f8a080e7          	jalr	-118(ra) # 80000cee <release>
        havekids = 1;
    80002d6c:	8756                	mv	a4,s5
    80002d6e:	bfd9                	j	80002d44 <waitx+0xe6>
    if (!havekids || p->killed)
    80002d70:	c305                	beqz	a4,80002d90 <waitx+0x132>
    80002d72:	02892783          	lw	a5,40(s2)
    80002d76:	ef89                	bnez	a5,80002d90 <waitx+0x132>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002d78:	85e6                	mv	a1,s9
    80002d7a:	854a                	mv	a0,s2
    80002d7c:	00000097          	auipc	ra,0x0
    80002d80:	938080e7          	jalr	-1736(ra) # 800026b4 <sleep>
    havekids = 0;
    80002d84:	4701                	li	a4,0
    for (np = proc; np < &proc[NPROC]; np++)
    80002d86:	0000f497          	auipc	s1,0xf
    80002d8a:	a1a48493          	addi	s1,s1,-1510 # 800117a0 <proc>
    80002d8e:	bf7d                	j	80002d4c <waitx+0xee>
      release(&wait_lock);
    80002d90:	0000e517          	auipc	a0,0xe
    80002d94:	df850513          	addi	a0,a0,-520 # 80010b88 <wait_lock>
    80002d98:	ffffe097          	auipc	ra,0xffffe
    80002d9c:	f56080e7          	jalr	-170(ra) # 80000cee <release>
      return -1;
    80002da0:	59fd                	li	s3,-1
    80002da2:	b7a5                	j	80002d0a <waitx+0xac>

0000000080002da4 <update_time>:

void update_time()
{
    80002da4:	7179                	addi	sp,sp,-48
    80002da6:	f406                	sd	ra,40(sp)
    80002da8:	f022                	sd	s0,32(sp)
    80002daa:	ec26                	sd	s1,24(sp)
    80002dac:	e84a                	sd	s2,16(sp)
    80002dae:	e44e                	sd	s3,8(sp)
    80002db0:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002db2:	0000f497          	auipc	s1,0xf
    80002db6:	9ee48493          	addi	s1,s1,-1554 # 800117a0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002dba:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002dbc:	0001c917          	auipc	s2,0x1c
    80002dc0:	de490913          	addi	s2,s2,-540 # 8001eba0 <tickslock>
    80002dc4:	a811                	j	80002dd8 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002dc6:	8526                	mv	a0,s1
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	f26080e7          	jalr	-218(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002dd0:	35048493          	addi	s1,s1,848
    80002dd4:	03248063          	beq	s1,s2,80002df4 <update_time+0x50>
    acquire(&p->lock);
    80002dd8:	8526                	mv	a0,s1
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	e64080e7          	jalr	-412(ra) # 80000c3e <acquire>
    if (p->state == RUNNING)
    80002de2:	4c9c                	lw	a5,24(s1)
    80002de4:	ff3791e3          	bne	a5,s3,80002dc6 <update_time+0x22>
      p->rtime++;
    80002de8:	3404a783          	lw	a5,832(s1)
    80002dec:	2785                	addiw	a5,a5,1
    80002dee:	34f4a023          	sw	a5,832(s1)
    80002df2:	bfd1                	j	80002dc6 <update_time+0x22>
  }
  
    80002df4:	70a2                	ld	ra,40(sp)
    80002df6:	7402                	ld	s0,32(sp)
    80002df8:	64e2                	ld	s1,24(sp)
    80002dfa:	6942                	ld	s2,16(sp)
    80002dfc:	69a2                	ld	s3,8(sp)
    80002dfe:	6145                	addi	sp,sp,48
    80002e00:	8082                	ret

0000000080002e02 <swtch>:
    80002e02:	00153023          	sd	ra,0(a0)
    80002e06:	00253423          	sd	sp,8(a0)
    80002e0a:	e900                	sd	s0,16(a0)
    80002e0c:	ed04                	sd	s1,24(a0)
    80002e0e:	03253023          	sd	s2,32(a0)
    80002e12:	03353423          	sd	s3,40(a0)
    80002e16:	03453823          	sd	s4,48(a0)
    80002e1a:	03553c23          	sd	s5,56(a0)
    80002e1e:	05653023          	sd	s6,64(a0)
    80002e22:	05753423          	sd	s7,72(a0)
    80002e26:	05853823          	sd	s8,80(a0)
    80002e2a:	05953c23          	sd	s9,88(a0)
    80002e2e:	07a53023          	sd	s10,96(a0)
    80002e32:	07b53423          	sd	s11,104(a0)
    80002e36:	0005b083          	ld	ra,0(a1)
    80002e3a:	0085b103          	ld	sp,8(a1)
    80002e3e:	6980                	ld	s0,16(a1)
    80002e40:	6d84                	ld	s1,24(a1)
    80002e42:	0205b903          	ld	s2,32(a1)
    80002e46:	0285b983          	ld	s3,40(a1)
    80002e4a:	0305ba03          	ld	s4,48(a1)
    80002e4e:	0385ba83          	ld	s5,56(a1)
    80002e52:	0405bb03          	ld	s6,64(a1)
    80002e56:	0485bb83          	ld	s7,72(a1)
    80002e5a:	0505bc03          	ld	s8,80(a1)
    80002e5e:	0585bc83          	ld	s9,88(a1)
    80002e62:	0605bd03          	ld	s10,96(a1)
    80002e66:	0685bd83          	ld	s11,104(a1)
    80002e6a:	8082                	ret

0000000080002e6c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002e6c:	1141                	addi	sp,sp,-16
    80002e6e:	e406                	sd	ra,8(sp)
    80002e70:	e022                	sd	s0,0(sp)
    80002e72:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e74:	00005597          	auipc	a1,0x5
    80002e78:	43458593          	addi	a1,a1,1076 # 800082a8 <etext+0x2a8>
    80002e7c:	0001c517          	auipc	a0,0x1c
    80002e80:	d2450513          	addi	a0,a0,-732 # 8001eba0 <tickslock>
    80002e84:	ffffe097          	auipc	ra,0xffffe
    80002e88:	d26080e7          	jalr	-730(ra) # 80000baa <initlock>
}
    80002e8c:	60a2                	ld	ra,8(sp)
    80002e8e:	6402                	ld	s0,0(sp)
    80002e90:	0141                	addi	sp,sp,16
    80002e92:	8082                	ret

0000000080002e94 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002e94:	1141                	addi	sp,sp,-16
    80002e96:	e406                	sd	ra,8(sp)
    80002e98:	e022                	sd	s0,0(sp)
    80002e9a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e9c:	00004797          	auipc	a5,0x4
    80002ea0:	85478793          	addi	a5,a5,-1964 # 800066f0 <kernelvec>
    80002ea4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ea8:	60a2                	ld	ra,8(sp)
    80002eaa:	6402                	ld	s0,0(sp)
    80002eac:	0141                	addi	sp,sp,16
    80002eae:	8082                	ret

0000000080002eb0 <usertrapret>:
}

// return to user space
//
void usertrapret(void)
{
    80002eb0:	1141                	addi	sp,sp,-16
    80002eb2:	e406                	sd	ra,8(sp)
    80002eb4:	e022                	sd	s0,0(sp)
    80002eb6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	d3e080e7          	jalr	-706(ra) # 80001bf6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ec0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ec4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ec6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002eca:	00004697          	auipc	a3,0x4
    80002ece:	13668693          	addi	a3,a3,310 # 80007000 <_trampoline>
    80002ed2:	00004717          	auipc	a4,0x4
    80002ed6:	12e70713          	addi	a4,a4,302 # 80007000 <_trampoline>
    80002eda:	8f15                	sub	a4,a4,a3
    80002edc:	040007b7          	lui	a5,0x4000
    80002ee0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002ee2:	07b2                	slli	a5,a5,0xc
    80002ee4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ee6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002eea:	23053703          	ld	a4,560(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002eee:	18002673          	csrr	a2,satp
    80002ef2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ef4:	23053603          	ld	a2,560(a0)
    80002ef8:	21853703          	ld	a4,536(a0)
    80002efc:	6585                	lui	a1,0x1
    80002efe:	972e                	add	a4,a4,a1
    80002f00:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002f02:	23053703          	ld	a4,560(a0)
    80002f06:	00000617          	auipc	a2,0x0
    80002f0a:	14c60613          	addi	a2,a2,332 # 80003052 <usertrap>
    80002f0e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002f10:	23053703          	ld	a4,560(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f14:	8612                	mv	a2,tp
    80002f16:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f18:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f1c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f20:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f24:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f28:	23053703          	ld	a4,560(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f2c:	6f18                	ld	a4,24(a4)
    80002f2e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f32:	22853503          	ld	a0,552(a0)
    80002f36:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002f38:	00004717          	auipc	a4,0x4
    80002f3c:	16470713          	addi	a4,a4,356 # 8000709c <userret>
    80002f40:	8f15                	sub	a4,a4,a3
    80002f42:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002f44:	577d                	li	a4,-1
    80002f46:	177e                	slli	a4,a4,0x3f
    80002f48:	8d59                	or	a0,a0,a4
    80002f4a:	9782                	jalr	a5
}
    80002f4c:	60a2                	ld	ra,8(sp)
    80002f4e:	6402                	ld	s0,0(sp)
    80002f50:	0141                	addi	sp,sp,16
    80002f52:	8082                	ret

0000000080002f54 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	e426                	sd	s1,8(sp)
    80002f5c:	e04a                	sd	s2,0(sp)
    80002f5e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002f60:	0001c917          	auipc	s2,0x1c
    80002f64:	c4090913          	addi	s2,s2,-960 # 8001eba0 <tickslock>
    80002f68:	854a                	mv	a0,s2
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	cd4080e7          	jalr	-812(ra) # 80000c3e <acquire>
  ticks++;
    80002f72:	00006497          	auipc	s1,0x6
    80002f76:	98248493          	addi	s1,s1,-1662 # 800088f4 <ticks>
    80002f7a:	409c                	lw	a5,0(s1)
    80002f7c:	2785                	addiw	a5,a5,1
    80002f7e:	c09c                	sw	a5,0(s1)
  update_time();
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	e24080e7          	jalr	-476(ra) # 80002da4 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002f88:	8526                	mv	a0,s1
    80002f8a:	fffff097          	auipc	ra,0xfffff
    80002f8e:	78e080e7          	jalr	1934(ra) # 80002718 <wakeup>
  release(&tickslock);
    80002f92:	854a                	mv	a0,s2
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	d5a080e7          	jalr	-678(ra) # 80000cee <release>
}
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6902                	ld	s2,0(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret

0000000080002fa8 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fa8:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002fac:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002fae:	0a07d163          	bgez	a5,80003050 <devintr+0xa8>
{
    80002fb2:	1101                	addi	sp,sp,-32
    80002fb4:	ec06                	sd	ra,24(sp)
    80002fb6:	e822                	sd	s0,16(sp)
    80002fb8:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002fba:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002fbe:	46a5                	li	a3,9
    80002fc0:	00d70c63          	beq	a4,a3,80002fd8 <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002fc4:	577d                	li	a4,-1
    80002fc6:	177e                	slli	a4,a4,0x3f
    80002fc8:	0705                	addi	a4,a4,1
    return 0;
    80002fca:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002fcc:	06e78163          	beq	a5,a4,8000302e <devintr+0x86>
  }
}
    80002fd0:	60e2                	ld	ra,24(sp)
    80002fd2:	6442                	ld	s0,16(sp)
    80002fd4:	6105                	addi	sp,sp,32
    80002fd6:	8082                	ret
    80002fd8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002fda:	00004097          	auipc	ra,0x4
    80002fde:	822080e7          	jalr	-2014(ra) # 800067fc <plic_claim>
    80002fe2:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002fe4:	47a9                	li	a5,10
    80002fe6:	00f50963          	beq	a0,a5,80002ff8 <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002fea:	4785                	li	a5,1
    80002fec:	00f50b63          	beq	a0,a5,80003002 <devintr+0x5a>
    return 1;
    80002ff0:	4505                	li	a0,1
    else if (irq)
    80002ff2:	ec89                	bnez	s1,8000300c <devintr+0x64>
    80002ff4:	64a2                	ld	s1,8(sp)
    80002ff6:	bfe9                	j	80002fd0 <devintr+0x28>
      uartintr();
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	a04080e7          	jalr	-1532(ra) # 800009fc <uartintr>
    if (irq)
    80003000:	a839                	j	8000301e <devintr+0x76>
      virtio_disk_intr();
    80003002:	00004097          	auipc	ra,0x4
    80003006:	cee080e7          	jalr	-786(ra) # 80006cf0 <virtio_disk_intr>
    if (irq)
    8000300a:	a811                	j	8000301e <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000300c:	85a6                	mv	a1,s1
    8000300e:	00005517          	auipc	a0,0x5
    80003012:	2a250513          	addi	a0,a0,674 # 800082b0 <etext+0x2b0>
    80003016:	ffffd097          	auipc	ra,0xffffd
    8000301a:	594080e7          	jalr	1428(ra) # 800005aa <printf>
      plic_complete(irq);
    8000301e:	8526                	mv	a0,s1
    80003020:	00004097          	auipc	ra,0x4
    80003024:	800080e7          	jalr	-2048(ra) # 80006820 <plic_complete>
    return 1;
    80003028:	4505                	li	a0,1
    8000302a:	64a2                	ld	s1,8(sp)
    8000302c:	b755                	j	80002fd0 <devintr+0x28>
    if (cpuid() == 0)
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	b94080e7          	jalr	-1132(ra) # 80001bc2 <cpuid>
    80003036:	c901                	beqz	a0,80003046 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003038:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000303c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000303e:	14479073          	csrw	sip,a5
    return 2;
    80003042:	4509                	li	a0,2
    80003044:	b771                	j	80002fd0 <devintr+0x28>
      clockintr();
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	f0e080e7          	jalr	-242(ra) # 80002f54 <clockintr>
    8000304e:	b7ed                	j	80003038 <devintr+0x90>
}
    80003050:	8082                	ret

0000000080003052 <usertrap>:
{
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000305a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000305e:	1007f793          	andi	a5,a5,256
    80003062:	efa5                	bnez	a5,800030da <usertrap+0x88>
    80003064:	e426                	sd	s1,8(sp)
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003066:	00003797          	auipc	a5,0x3
    8000306a:	68a78793          	addi	a5,a5,1674 # 800066f0 <kernelvec>
    8000306e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	b84080e7          	jalr	-1148(ra) # 80001bf6 <myproc>
    8000307a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000307c:	23053783          	ld	a5,560(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003080:	14102773          	csrr	a4,sepc
    80003084:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003086:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    8000308a:	47a1                	li	a5,8
    8000308c:	06f70163          	beq	a4,a5,800030ee <usertrap+0x9c>
  else if ((which_dev = devintr()) != 0)
    80003090:	00000097          	auipc	ra,0x0
    80003094:	f18080e7          	jalr	-232(ra) # 80002fa8 <devintr>
    80003098:	c545                	beqz	a0,80003140 <usertrap+0xee>
  if (which_dev == 2 && p->alarm_interval > 0)
    8000309a:	4789                	li	a5,2
    8000309c:	06f51d63          	bne	a0,a5,80003116 <usertrap+0xc4>
    800030a0:	e04a                	sd	s2,0(sp)
    800030a2:	0e44a703          	lw	a4,228(s1)
    800030a6:	00e05c63          	blez	a4,800030be <usertrap+0x6c>
    p->ticks++;
    800030aa:	0e04a783          	lw	a5,224(s1)
    800030ae:	2785                	addiw	a5,a5,1
    800030b0:	0ef4a023          	sw	a5,224(s1)
    if (p->ticks >= p->alarm_interval && p->alarm_active == 0)
    800030b4:	00e7c563          	blt	a5,a4,800030be <usertrap+0x6c>
    800030b8:	2104a783          	lw	a5,528(s1)
    800030bc:	cfdd                	beqz	a5,8000317a <usertrap+0x128>
    struct proc *p = myproc();
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	b38080e7          	jalr	-1224(ra) # 80001bf6 <myproc>
    800030c6:	892a                	mv	s2,a0
    if (p && p->state == RUNNING)
    800030c8:	10050a63          	beqz	a0,800031dc <usertrap+0x18a>
    800030cc:	01892703          	lw	a4,24(s2)
    800030d0:	4791                	li	a5,4
    800030d2:	0cf70863          	beq	a4,a5,800031a2 <usertrap+0x150>
    800030d6:	6902                	ld	s2,0(sp)
    800030d8:	a83d                	j	80003116 <usertrap+0xc4>
    800030da:	e426                	sd	s1,8(sp)
    800030dc:	e04a                	sd	s2,0(sp)
    panic("usertrap: not from user mode");
    800030de:	00005517          	auipc	a0,0x5
    800030e2:	1f250513          	addi	a0,a0,498 # 800082d0 <etext+0x2d0>
    800030e6:	ffffd097          	auipc	ra,0xffffd
    800030ea:	47a080e7          	jalr	1146(ra) # 80000560 <panic>
    if (killed(p))
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	896080e7          	jalr	-1898(ra) # 80002984 <killed>
    800030f6:	ed1d                	bnez	a0,80003134 <usertrap+0xe2>
    p->trapframe->epc += 4;
    800030f8:	2304b703          	ld	a4,560(s1)
    800030fc:	6f1c                	ld	a5,24(a4)
    800030fe:	0791                	addi	a5,a5,4
    80003100:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003102:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003106:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000310a:	10079073          	csrw	sstatus,a5
    syscall();
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	326080e7          	jalr	806(ra) # 80003434 <syscall>
  if (killed(p))
    80003116:	8526                	mv	a0,s1
    80003118:	00000097          	auipc	ra,0x0
    8000311c:	86c080e7          	jalr	-1940(ra) # 80002984 <killed>
    80003120:	e945                	bnez	a0,800031d0 <usertrap+0x17e>
  usertrapret();
    80003122:	00000097          	auipc	ra,0x0
    80003126:	d8e080e7          	jalr	-626(ra) # 80002eb0 <usertrapret>
    8000312a:	64a2                	ld	s1,8(sp)
}
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	6105                	addi	sp,sp,32
    80003132:	8082                	ret
      exit(-1);
    80003134:	557d                	li	a0,-1
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	6c0080e7          	jalr	1728(ra) # 800027f6 <exit>
    8000313e:	bf6d                	j	800030f8 <usertrap+0xa6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003140:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003144:	5890                	lw	a2,48(s1)
    80003146:	00005517          	auipc	a0,0x5
    8000314a:	1aa50513          	addi	a0,a0,426 # 800082f0 <etext+0x2f0>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	45c080e7          	jalr	1116(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003156:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000315a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000315e:	00005517          	auipc	a0,0x5
    80003162:	1c250513          	addi	a0,a0,450 # 80008320 <etext+0x320>
    80003166:	ffffd097          	auipc	ra,0xffffd
    8000316a:	444080e7          	jalr	1092(ra) # 800005aa <printf>
    setkilled(p);
    8000316e:	8526                	mv	a0,s1
    80003170:	fffff097          	auipc	ra,0xfffff
    80003174:	7e8080e7          	jalr	2024(ra) # 80002958 <setkilled>
  if (which_dev == 2 && p->alarm_interval > 0)
    80003178:	bf79                	j	80003116 <usertrap+0xc4>
      p->ticks = 0;        // Reset the tick count
    8000317a:	0e04a023          	sw	zero,224(s1)
      p->alarm_active = 1; // Mark that handler is active to prevent re-entry
    8000317e:	4785                	li	a5,1
    80003180:	20f4a823          	sw	a5,528(s1)
      memmove(&p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80003184:	12000613          	li	a2,288
    80003188:	2304b583          	ld	a1,560(s1)
    8000318c:	0f048513          	addi	a0,s1,240
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	c0a080e7          	jalr	-1014(ra) # 80000d9a <memmove>
      p->trapframe->epc = p->handler;
    80003198:	2304b783          	ld	a5,560(s1)
    8000319c:	74f8                	ld	a4,232(s1)
    8000319e:	ef98                	sd	a4,24(a5)
    800031a0:	bf39                	j	800030be <usertrap+0x6c>
      p->ticks++;
    800031a2:	0e092783          	lw	a5,224(s2)
    800031a6:	2785                	addiw	a5,a5,1
    800031a8:	0ef92023          	sw	a5,224(s2)
      int time_slice = get_time_slice(p->priority);
    800031ac:	0d892503          	lw	a0,216(s2)
    800031b0:	fffff097          	auipc	ra,0xfffff
    800031b4:	fd0080e7          	jalr	-48(ra) # 80002180 <get_time_slice>
      if (p->ticks >= time_slice)
    800031b8:	0e092783          	lw	a5,224(s2)
    800031bc:	00a7d463          	bge	a5,a0,800031c4 <usertrap+0x172>
    800031c0:	6902                	ld	s2,0(sp)
    800031c2:	bf91                	j	80003116 <usertrap+0xc4>
        yield();
    800031c4:	fffff097          	auipc	ra,0xfffff
    800031c8:	4b4080e7          	jalr	1204(ra) # 80002678 <yield>
    800031cc:	6902                	ld	s2,0(sp)
    800031ce:	b7a1                	j	80003116 <usertrap+0xc4>
    exit(-1);
    800031d0:	557d                	li	a0,-1
    800031d2:	fffff097          	auipc	ra,0xfffff
    800031d6:	624080e7          	jalr	1572(ra) # 800027f6 <exit>
    800031da:	b7a1                	j	80003122 <usertrap+0xd0>
    800031dc:	6902                	ld	s2,0(sp)
    800031de:	bf25                	j	80003116 <usertrap+0xc4>

00000000800031e0 <kerneltrap>:
{
    800031e0:	7179                	addi	sp,sp,-48
    800031e2:	f406                	sd	ra,40(sp)
    800031e4:	f022                	sd	s0,32(sp)
    800031e6:	ec26                	sd	s1,24(sp)
    800031e8:	e84a                	sd	s2,16(sp)
    800031ea:	e44e                	sd	s3,8(sp)
    800031ec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031ee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031f2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031f6:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800031fa:	1004f793          	andi	a5,s1,256
    800031fe:	cb85                	beqz	a5,8000322e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003200:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003204:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003206:	ef85                	bnez	a5,8000323e <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003208:	00000097          	auipc	ra,0x0
    8000320c:	da0080e7          	jalr	-608(ra) # 80002fa8 <devintr>
    80003210:	cd1d                	beqz	a0,8000324e <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003212:	4789                	li	a5,2
    80003214:	06f50a63          	beq	a0,a5,80003288 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003218:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000321c:	10049073          	csrw	sstatus,s1
}
    80003220:	70a2                	ld	ra,40(sp)
    80003222:	7402                	ld	s0,32(sp)
    80003224:	64e2                	ld	s1,24(sp)
    80003226:	6942                	ld	s2,16(sp)
    80003228:	69a2                	ld	s3,8(sp)
    8000322a:	6145                	addi	sp,sp,48
    8000322c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000322e:	00005517          	auipc	a0,0x5
    80003232:	11250513          	addi	a0,a0,274 # 80008340 <etext+0x340>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	32a080e7          	jalr	810(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    8000323e:	00005517          	auipc	a0,0x5
    80003242:	12a50513          	addi	a0,a0,298 # 80008368 <etext+0x368>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	31a080e7          	jalr	794(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    8000324e:	85ce                	mv	a1,s3
    80003250:	00005517          	auipc	a0,0x5
    80003254:	13850513          	addi	a0,a0,312 # 80008388 <etext+0x388>
    80003258:	ffffd097          	auipc	ra,0xffffd
    8000325c:	352080e7          	jalr	850(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003260:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003264:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003268:	00005517          	auipc	a0,0x5
    8000326c:	13050513          	addi	a0,a0,304 # 80008398 <etext+0x398>
    80003270:	ffffd097          	auipc	ra,0xffffd
    80003274:	33a080e7          	jalr	826(ra) # 800005aa <printf>
    panic("kerneltrap");
    80003278:	00005517          	auipc	a0,0x5
    8000327c:	13850513          	addi	a0,a0,312 # 800083b0 <etext+0x3b0>
    80003280:	ffffd097          	auipc	ra,0xffffd
    80003284:	2e0080e7          	jalr	736(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003288:	fffff097          	auipc	ra,0xfffff
    8000328c:	96e080e7          	jalr	-1682(ra) # 80001bf6 <myproc>
    80003290:	d541                	beqz	a0,80003218 <kerneltrap+0x38>
    80003292:	fffff097          	auipc	ra,0xfffff
    80003296:	964080e7          	jalr	-1692(ra) # 80001bf6 <myproc>
    8000329a:	4d18                	lw	a4,24(a0)
    8000329c:	4791                	li	a5,4
    8000329e:	f6f71de3          	bne	a4,a5,80003218 <kerneltrap+0x38>
    yield();
    800032a2:	fffff097          	auipc	ra,0xfffff
    800032a6:	3d6080e7          	jalr	982(ra) # 80002678 <yield>
    800032aa:	b7bd                	j	80003218 <kerneltrap+0x38>

00000000800032ac <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800032ac:	1101                	addi	sp,sp,-32
    800032ae:	ec06                	sd	ra,24(sp)
    800032b0:	e822                	sd	s0,16(sp)
    800032b2:	e426                	sd	s1,8(sp)
    800032b4:	1000                	addi	s0,sp,32
    800032b6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800032b8:	fffff097          	auipc	ra,0xfffff
    800032bc:	93e080e7          	jalr	-1730(ra) # 80001bf6 <myproc>
  switch (n) {
    800032c0:	4795                	li	a5,5
    800032c2:	0497e763          	bltu	a5,s1,80003310 <argraw+0x64>
    800032c6:	048a                	slli	s1,s1,0x2
    800032c8:	00005717          	auipc	a4,0x5
    800032cc:	4a870713          	addi	a4,a4,1192 # 80008770 <states.0+0x30>
    800032d0:	94ba                	add	s1,s1,a4
    800032d2:	409c                	lw	a5,0(s1)
    800032d4:	97ba                	add	a5,a5,a4
    800032d6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800032d8:	23053783          	ld	a5,560(a0)
    800032dc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6105                	addi	sp,sp,32
    800032e6:	8082                	ret
    return p->trapframe->a1;
    800032e8:	23053783          	ld	a5,560(a0)
    800032ec:	7fa8                	ld	a0,120(a5)
    800032ee:	bfc5                	j	800032de <argraw+0x32>
    return p->trapframe->a2;
    800032f0:	23053783          	ld	a5,560(a0)
    800032f4:	63c8                	ld	a0,128(a5)
    800032f6:	b7e5                	j	800032de <argraw+0x32>
    return p->trapframe->a3;
    800032f8:	23053783          	ld	a5,560(a0)
    800032fc:	67c8                	ld	a0,136(a5)
    800032fe:	b7c5                	j	800032de <argraw+0x32>
    return p->trapframe->a4;
    80003300:	23053783          	ld	a5,560(a0)
    80003304:	6bc8                	ld	a0,144(a5)
    80003306:	bfe1                	j	800032de <argraw+0x32>
    return p->trapframe->a5;
    80003308:	23053783          	ld	a5,560(a0)
    8000330c:	6fc8                	ld	a0,152(a5)
    8000330e:	bfc1                	j	800032de <argraw+0x32>
  panic("argraw");
    80003310:	00005517          	auipc	a0,0x5
    80003314:	0b050513          	addi	a0,a0,176 # 800083c0 <etext+0x3c0>
    80003318:	ffffd097          	auipc	ra,0xffffd
    8000331c:	248080e7          	jalr	584(ra) # 80000560 <panic>

0000000080003320 <fetchaddr>:
{
    80003320:	1101                	addi	sp,sp,-32
    80003322:	ec06                	sd	ra,24(sp)
    80003324:	e822                	sd	s0,16(sp)
    80003326:	e426                	sd	s1,8(sp)
    80003328:	e04a                	sd	s2,0(sp)
    8000332a:	1000                	addi	s0,sp,32
    8000332c:	84aa                	mv	s1,a0
    8000332e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003330:	fffff097          	auipc	ra,0xfffff
    80003334:	8c6080e7          	jalr	-1850(ra) # 80001bf6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003338:	22053783          	ld	a5,544(a0)
    8000333c:	02f4f963          	bgeu	s1,a5,8000336e <fetchaddr+0x4e>
    80003340:	00848713          	addi	a4,s1,8
    80003344:	02e7e763          	bltu	a5,a4,80003372 <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003348:	46a1                	li	a3,8
    8000334a:	8626                	mv	a2,s1
    8000334c:	85ca                	mv	a1,s2
    8000334e:	22853503          	ld	a0,552(a0)
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	44a080e7          	jalr	1098(ra) # 8000179c <copyin>
    8000335a:	00a03533          	snez	a0,a0
    8000335e:	40a0053b          	negw	a0,a0
}
    80003362:	60e2                	ld	ra,24(sp)
    80003364:	6442                	ld	s0,16(sp)
    80003366:	64a2                	ld	s1,8(sp)
    80003368:	6902                	ld	s2,0(sp)
    8000336a:	6105                	addi	sp,sp,32
    8000336c:	8082                	ret
    return -1;
    8000336e:	557d                	li	a0,-1
    80003370:	bfcd                	j	80003362 <fetchaddr+0x42>
    80003372:	557d                	li	a0,-1
    80003374:	b7fd                	j	80003362 <fetchaddr+0x42>

0000000080003376 <fetchstr>:
{
    80003376:	7179                	addi	sp,sp,-48
    80003378:	f406                	sd	ra,40(sp)
    8000337a:	f022                	sd	s0,32(sp)
    8000337c:	ec26                	sd	s1,24(sp)
    8000337e:	e84a                	sd	s2,16(sp)
    80003380:	e44e                	sd	s3,8(sp)
    80003382:	1800                	addi	s0,sp,48
    80003384:	892a                	mv	s2,a0
    80003386:	84ae                	mv	s1,a1
    80003388:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000338a:	fffff097          	auipc	ra,0xfffff
    8000338e:	86c080e7          	jalr	-1940(ra) # 80001bf6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003392:	86ce                	mv	a3,s3
    80003394:	864a                	mv	a2,s2
    80003396:	85a6                	mv	a1,s1
    80003398:	22853503          	ld	a0,552(a0)
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	48e080e7          	jalr	1166(ra) # 8000182a <copyinstr>
    800033a4:	00054e63          	bltz	a0,800033c0 <fetchstr+0x4a>
  return strlen(buf);
    800033a8:	8526                	mv	a0,s1
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	b18080e7          	jalr	-1256(ra) # 80000ec2 <strlen>
}
    800033b2:	70a2                	ld	ra,40(sp)
    800033b4:	7402                	ld	s0,32(sp)
    800033b6:	64e2                	ld	s1,24(sp)
    800033b8:	6942                	ld	s2,16(sp)
    800033ba:	69a2                	ld	s3,8(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret
    return -1;
    800033c0:	557d                	li	a0,-1
    800033c2:	bfc5                	j	800033b2 <fetchstr+0x3c>

00000000800033c4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800033c4:	1101                	addi	sp,sp,-32
    800033c6:	ec06                	sd	ra,24(sp)
    800033c8:	e822                	sd	s0,16(sp)
    800033ca:	e426                	sd	s1,8(sp)
    800033cc:	1000                	addi	s0,sp,32
    800033ce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800033d0:	00000097          	auipc	ra,0x0
    800033d4:	edc080e7          	jalr	-292(ra) # 800032ac <argraw>
    800033d8:	c088                	sw	a0,0(s1)
}
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret

00000000800033e4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	1000                	addi	s0,sp,32
    800033ee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	ebc080e7          	jalr	-324(ra) # 800032ac <argraw>
    800033f8:	e088                	sd	a0,0(s1)
}
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret

0000000080003404 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003404:	1101                	addi	sp,sp,-32
    80003406:	ec06                	sd	ra,24(sp)
    80003408:	e822                	sd	s0,16(sp)
    8000340a:	e426                	sd	s1,8(sp)
    8000340c:	e04a                	sd	s2,0(sp)
    8000340e:	1000                	addi	s0,sp,32
    80003410:	84ae                	mv	s1,a1
    80003412:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003414:	00000097          	auipc	ra,0x0
    80003418:	e98080e7          	jalr	-360(ra) # 800032ac <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000341c:	864a                	mv	a2,s2
    8000341e:	85a6                	mv	a1,s1
    80003420:	00000097          	auipc	ra,0x0
    80003424:	f56080e7          	jalr	-170(ra) # 80003376 <fetchstr>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	64a2                	ld	s1,8(sp)
    8000342e:	6902                	ld	s2,0(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret

0000000080003434 <syscall>:
    [SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80003434:	7179                	addi	sp,sp,-48
    80003436:	f406                	sd	ra,40(sp)
    80003438:	f022                	sd	s0,32(sp)
    8000343a:	ec26                	sd	s1,24(sp)
    8000343c:	e84a                	sd	s2,16(sp)
    8000343e:	e44e                	sd	s3,8(sp)
    80003440:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	7b4080e7          	jalr	1972(ra) # 80001bf6 <myproc>
    8000344a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000344c:	23053983          	ld	s3,560(a0)
    80003450:	0a89a903          	lw	s2,168(s3)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003454:	fff9071b          	addiw	a4,s2,-1
    80003458:	47e5                	li	a5,25
    8000345a:	02e7ec63          	bltu	a5,a4,80003492 <syscall+0x5e>
    8000345e:	e052                	sd	s4,0(sp)
    80003460:	00391713          	slli	a4,s2,0x3
    80003464:	00005797          	auipc	a5,0x5
    80003468:	32478793          	addi	a5,a5,804 # 80008788 <syscalls>
    8000346c:	97ba                	add	a5,a5,a4
    8000346e:	639c                	ld	a5,0(a5)
    80003470:	c385                	beqz	a5,80003490 <syscall+0x5c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003472:	9782                	jalr	a5
    80003474:	06a9b823          	sd	a0,112(s3)
    if(num<26 && num>=0)
    80003478:	47e5                	li	a5,25
    8000347a:	0527e363          	bltu	a5,s2,800034c0 <syscall+0x8c>
    {
      p->syscall_count[num]++;
    8000347e:	090a                	slli	s2,s2,0x2
    80003480:	9926                	add	s2,s2,s1
    80003482:	04092783          	lw	a5,64(s2)
    80003486:	2785                	addiw	a5,a5,1
    80003488:	04f92023          	sw	a5,64(s2)
    8000348c:	6a02                	ld	s4,0(sp)
    8000348e:	a015                	j	800034b2 <syscall+0x7e>
    80003490:	6a02                	ld	s4,0(sp)
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003492:	86ca                	mv	a3,s2
    80003494:	33048613          	addi	a2,s1,816
    80003498:	588c                	lw	a1,48(s1)
    8000349a:	00005517          	auipc	a0,0x5
    8000349e:	f2e50513          	addi	a0,a0,-210 # 800083c8 <etext+0x3c8>
    800034a2:	ffffd097          	auipc	ra,0xffffd
    800034a6:	108080e7          	jalr	264(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800034aa:	2304b783          	ld	a5,560(s1)
    800034ae:	577d                	li	a4,-1
    800034b0:	fbb8                	sd	a4,112(a5)
  }
}
    800034b2:	70a2                	ld	ra,40(sp)
    800034b4:	7402                	ld	s0,32(sp)
    800034b6:	64e2                	ld	s1,24(sp)
    800034b8:	6942                	ld	s2,16(sp)
    800034ba:	69a2                	ld	s3,8(sp)
    800034bc:	6145                	addi	sp,sp,48
    800034be:	8082                	ret
    800034c0:	6a02                	ld	s4,0(sp)
    800034c2:	bfc5                	j	800034b2 <syscall+0x7e>

00000000800034c4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800034c4:	1101                	addi	sp,sp,-32
    800034c6:	ec06                	sd	ra,24(sp)
    800034c8:	e822                	sd	s0,16(sp)
    800034ca:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800034cc:	fec40593          	addi	a1,s0,-20
    800034d0:	4501                	li	a0,0
    800034d2:	00000097          	auipc	ra,0x0
    800034d6:	ef2080e7          	jalr	-270(ra) # 800033c4 <argint>
  exit(n);
    800034da:	fec42503          	lw	a0,-20(s0)
    800034de:	fffff097          	auipc	ra,0xfffff
    800034e2:	318080e7          	jalr	792(ra) # 800027f6 <exit>
  return 0; // not reached
}
    800034e6:	4501                	li	a0,0
    800034e8:	60e2                	ld	ra,24(sp)
    800034ea:	6442                	ld	s0,16(sp)
    800034ec:	6105                	addi	sp,sp,32
    800034ee:	8082                	ret

00000000800034f0 <sys_getpid>:

uint64
sys_getpid(void)
{
    800034f0:	1141                	addi	sp,sp,-16
    800034f2:	e406                	sd	ra,8(sp)
    800034f4:	e022                	sd	s0,0(sp)
    800034f6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	6fe080e7          	jalr	1790(ra) # 80001bf6 <myproc>
}
    80003500:	5908                	lw	a0,48(a0)
    80003502:	60a2                	ld	ra,8(sp)
    80003504:	6402                	ld	s0,0(sp)
    80003506:	0141                	addi	sp,sp,16
    80003508:	8082                	ret

000000008000350a <sys_fork>:

uint64
sys_fork(void)
{
    8000350a:	1141                	addi	sp,sp,-16
    8000350c:	e406                	sd	ra,8(sp)
    8000350e:	e022                	sd	s0,0(sp)
    80003510:	0800                	addi	s0,sp,16
  return fork();
    80003512:	fffff097          	auipc	ra,0xfffff
    80003516:	b14080e7          	jalr	-1260(ra) # 80002026 <fork>
}
    8000351a:	60a2                	ld	ra,8(sp)
    8000351c:	6402                	ld	s0,0(sp)
    8000351e:	0141                	addi	sp,sp,16
    80003520:	8082                	ret

0000000080003522 <sys_wait>:

uint64
sys_wait(void)
{
    80003522:	1101                	addi	sp,sp,-32
    80003524:	ec06                	sd	ra,24(sp)
    80003526:	e822                	sd	s0,16(sp)
    80003528:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000352a:	fe840593          	addi	a1,s0,-24
    8000352e:	4501                	li	a0,0
    80003530:	00000097          	auipc	ra,0x0
    80003534:	eb4080e7          	jalr	-332(ra) # 800033e4 <argaddr>
  return wait(p);
    80003538:	fe843503          	ld	a0,-24(s0)
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	47a080e7          	jalr	1146(ra) # 800029b6 <wait>
}
    80003544:	60e2                	ld	ra,24(sp)
    80003546:	6442                	ld	s0,16(sp)
    80003548:	6105                	addi	sp,sp,32
    8000354a:	8082                	ret

000000008000354c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000354c:	7179                	addi	sp,sp,-48
    8000354e:	f406                	sd	ra,40(sp)
    80003550:	f022                	sd	s0,32(sp)
    80003552:	ec26                	sd	s1,24(sp)
    80003554:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003556:	fdc40593          	addi	a1,s0,-36
    8000355a:	4501                	li	a0,0
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	e68080e7          	jalr	-408(ra) # 800033c4 <argint>
  addr = myproc()->sz;
    80003564:	ffffe097          	auipc	ra,0xffffe
    80003568:	692080e7          	jalr	1682(ra) # 80001bf6 <myproc>
    8000356c:	22053483          	ld	s1,544(a0)
  if (growproc(n) < 0)
    80003570:	fdc42503          	lw	a0,-36(s0)
    80003574:	fffff097          	auipc	ra,0xfffff
    80003578:	a4e080e7          	jalr	-1458(ra) # 80001fc2 <growproc>
    8000357c:	00054863          	bltz	a0,8000358c <sys_sbrk+0x40>
    return -1;
  return addr;
}
    80003580:	8526                	mv	a0,s1
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6145                	addi	sp,sp,48
    8000358a:	8082                	ret
    return -1;
    8000358c:	54fd                	li	s1,-1
    8000358e:	bfcd                	j	80003580 <sys_sbrk+0x34>

0000000080003590 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003590:	7139                	addi	sp,sp,-64
    80003592:	fc06                	sd	ra,56(sp)
    80003594:	f822                	sd	s0,48(sp)
    80003596:	f04a                	sd	s2,32(sp)
    80003598:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000359a:	fcc40593          	addi	a1,s0,-52
    8000359e:	4501                	li	a0,0
    800035a0:	00000097          	auipc	ra,0x0
    800035a4:	e24080e7          	jalr	-476(ra) # 800033c4 <argint>
  acquire(&tickslock);
    800035a8:	0001b517          	auipc	a0,0x1b
    800035ac:	5f850513          	addi	a0,a0,1528 # 8001eba0 <tickslock>
    800035b0:	ffffd097          	auipc	ra,0xffffd
    800035b4:	68e080e7          	jalr	1678(ra) # 80000c3e <acquire>
  ticks0 = ticks;
    800035b8:	00005917          	auipc	s2,0x5
    800035bc:	33c92903          	lw	s2,828(s2) # 800088f4 <ticks>
  while (ticks - ticks0 < n)
    800035c0:	fcc42783          	lw	a5,-52(s0)
    800035c4:	c3b9                	beqz	a5,8000360a <sys_sleep+0x7a>
    800035c6:	f426                	sd	s1,40(sp)
    800035c8:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800035ca:	0001b997          	auipc	s3,0x1b
    800035ce:	5d698993          	addi	s3,s3,1494 # 8001eba0 <tickslock>
    800035d2:	00005497          	auipc	s1,0x5
    800035d6:	32248493          	addi	s1,s1,802 # 800088f4 <ticks>
    if (killed(myproc()))
    800035da:	ffffe097          	auipc	ra,0xffffe
    800035de:	61c080e7          	jalr	1564(ra) # 80001bf6 <myproc>
    800035e2:	fffff097          	auipc	ra,0xfffff
    800035e6:	3a2080e7          	jalr	930(ra) # 80002984 <killed>
    800035ea:	ed15                	bnez	a0,80003626 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800035ec:	85ce                	mv	a1,s3
    800035ee:	8526                	mv	a0,s1
    800035f0:	fffff097          	auipc	ra,0xfffff
    800035f4:	0c4080e7          	jalr	196(ra) # 800026b4 <sleep>
  while (ticks - ticks0 < n)
    800035f8:	409c                	lw	a5,0(s1)
    800035fa:	412787bb          	subw	a5,a5,s2
    800035fe:	fcc42703          	lw	a4,-52(s0)
    80003602:	fce7ece3          	bltu	a5,a4,800035da <sys_sleep+0x4a>
    80003606:	74a2                	ld	s1,40(sp)
    80003608:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000360a:	0001b517          	auipc	a0,0x1b
    8000360e:	59650513          	addi	a0,a0,1430 # 8001eba0 <tickslock>
    80003612:	ffffd097          	auipc	ra,0xffffd
    80003616:	6dc080e7          	jalr	1756(ra) # 80000cee <release>
  return 0;
    8000361a:	4501                	li	a0,0
}
    8000361c:	70e2                	ld	ra,56(sp)
    8000361e:	7442                	ld	s0,48(sp)
    80003620:	7902                	ld	s2,32(sp)
    80003622:	6121                	addi	sp,sp,64
    80003624:	8082                	ret
      release(&tickslock);
    80003626:	0001b517          	auipc	a0,0x1b
    8000362a:	57a50513          	addi	a0,a0,1402 # 8001eba0 <tickslock>
    8000362e:	ffffd097          	auipc	ra,0xffffd
    80003632:	6c0080e7          	jalr	1728(ra) # 80000cee <release>
      return -1;
    80003636:	557d                	li	a0,-1
    80003638:	74a2                	ld	s1,40(sp)
    8000363a:	69e2                	ld	s3,24(sp)
    8000363c:	b7c5                	j	8000361c <sys_sleep+0x8c>

000000008000363e <sys_kill>:

uint64
sys_kill(void)
{
    8000363e:	1101                	addi	sp,sp,-32
    80003640:	ec06                	sd	ra,24(sp)
    80003642:	e822                	sd	s0,16(sp)
    80003644:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003646:	fec40593          	addi	a1,s0,-20
    8000364a:	4501                	li	a0,0
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	d78080e7          	jalr	-648(ra) # 800033c4 <argint>
  return kill(pid);
    80003654:	fec42503          	lw	a0,-20(s0)
    80003658:	fffff097          	auipc	ra,0xfffff
    8000365c:	280080e7          	jalr	640(ra) # 800028d8 <kill>
}
    80003660:	60e2                	ld	ra,24(sp)
    80003662:	6442                	ld	s0,16(sp)
    80003664:	6105                	addi	sp,sp,32
    80003666:	8082                	ret

0000000080003668 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003668:	1101                	addi	sp,sp,-32
    8000366a:	ec06                	sd	ra,24(sp)
    8000366c:	e822                	sd	s0,16(sp)
    8000366e:	e426                	sd	s1,8(sp)
    80003670:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003672:	0001b517          	auipc	a0,0x1b
    80003676:	52e50513          	addi	a0,a0,1326 # 8001eba0 <tickslock>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	5c4080e7          	jalr	1476(ra) # 80000c3e <acquire>
  xticks = ticks;
    80003682:	00005497          	auipc	s1,0x5
    80003686:	2724a483          	lw	s1,626(s1) # 800088f4 <ticks>
  release(&tickslock);
    8000368a:	0001b517          	auipc	a0,0x1b
    8000368e:	51650513          	addi	a0,a0,1302 # 8001eba0 <tickslock>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	65c080e7          	jalr	1628(ra) # 80000cee <release>
  return xticks;
}
    8000369a:	02049513          	slli	a0,s1,0x20
    8000369e:	9101                	srli	a0,a0,0x20
    800036a0:	60e2                	ld	ra,24(sp)
    800036a2:	6442                	ld	s0,16(sp)
    800036a4:	64a2                	ld	s1,8(sp)
    800036a6:	6105                	addi	sp,sp,32
    800036a8:	8082                	ret

00000000800036aa <sys_waitx>:

uint64
sys_waitx(void)
{
    800036aa:	715d                	addi	sp,sp,-80
    800036ac:	e486                	sd	ra,72(sp)
    800036ae:	e0a2                	sd	s0,64(sp)
    800036b0:	fc26                	sd	s1,56(sp)
    800036b2:	f84a                	sd	s2,48(sp)
    800036b4:	f44e                	sd	s3,40(sp)
    800036b6:	0880                	addi	s0,sp,80
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800036b8:	fc840593          	addi	a1,s0,-56
    800036bc:	4501                	li	a0,0
    800036be:	00000097          	auipc	ra,0x0
    800036c2:	d26080e7          	jalr	-730(ra) # 800033e4 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800036c6:	fc040593          	addi	a1,s0,-64
    800036ca:	4505                	li	a0,1
    800036cc:	00000097          	auipc	ra,0x0
    800036d0:	d18080e7          	jalr	-744(ra) # 800033e4 <argaddr>
  argaddr(2, &addr2);
    800036d4:	fb840593          	addi	a1,s0,-72
    800036d8:	4509                	li	a0,2
    800036da:	00000097          	auipc	ra,0x0
    800036de:	d0a080e7          	jalr	-758(ra) # 800033e4 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800036e2:	fb440993          	addi	s3,s0,-76
    800036e6:	fb040613          	addi	a2,s0,-80
    800036ea:	85ce                	mv	a1,s3
    800036ec:	fc843503          	ld	a0,-56(s0)
    800036f0:	fffff097          	auipc	ra,0xfffff
    800036f4:	56e080e7          	jalr	1390(ra) # 80002c5e <waitx>
    800036f8:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800036fa:	ffffe097          	auipc	ra,0xffffe
    800036fe:	4fc080e7          	jalr	1276(ra) # 80001bf6 <myproc>
    80003702:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003704:	4691                	li	a3,4
    80003706:	864e                	mv	a2,s3
    80003708:	fc043583          	ld	a1,-64(s0)
    8000370c:	22853503          	ld	a0,552(a0)
    80003710:	ffffe097          	auipc	ra,0xffffe
    80003714:	000080e7          	jalr	ra # 80001710 <copyout>
    return -1;
    80003718:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000371a:	02054063          	bltz	a0,8000373a <sys_waitx+0x90>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000371e:	4691                	li	a3,4
    80003720:	fb040613          	addi	a2,s0,-80
    80003724:	fb843583          	ld	a1,-72(s0)
    80003728:	2284b503          	ld	a0,552(s1)
    8000372c:	ffffe097          	auipc	ra,0xffffe
    80003730:	fe4080e7          	jalr	-28(ra) # 80001710 <copyout>
    80003734:	00054b63          	bltz	a0,8000374a <sys_waitx+0xa0>
    return -1;
  return ret;
    80003738:	87ca                	mv	a5,s2
}
    8000373a:	853e                	mv	a0,a5
    8000373c:	60a6                	ld	ra,72(sp)
    8000373e:	6406                	ld	s0,64(sp)
    80003740:	74e2                	ld	s1,56(sp)
    80003742:	7942                	ld	s2,48(sp)
    80003744:	79a2                	ld	s3,40(sp)
    80003746:	6161                	addi	sp,sp,80
    80003748:	8082                	ret
    return -1;
    8000374a:	57fd                	li	a5,-1
    8000374c:	b7fd                	j	8000373a <sys_waitx+0x90>

000000008000374e <sys_getSysCount>:

uint64
sys_getSysCount(void)
{
    8000374e:	1101                	addi	sp,sp,-32
    80003750:	ec06                	sd	ra,24(sp)
    80003752:	e822                	sd	s0,16(sp)
    80003754:	1000                	addi	s0,sp,32
  int k;
  argint(0, &k);
    80003756:	fec40593          	addi	a1,s0,-20
    8000375a:	4501                	li	a0,0
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	c68080e7          	jalr	-920(ra) # 800033c4 <argint>
  struct proc *p = myproc();
    80003764:	ffffe097          	auipc	ra,0xffffe
    80003768:	492080e7          	jalr	1170(ra) # 80001bf6 <myproc>
  return p->syscall_count[k];
    8000376c:	fec42783          	lw	a5,-20(s0)
    80003770:	07c1                	addi	a5,a5,16
    80003772:	078a                	slli	a5,a5,0x2
    80003774:	953e                	add	a0,a0,a5
}
    80003776:	4108                	lw	a0,0(a0)
    80003778:	60e2                	ld	ra,24(sp)
    8000377a:	6442                	ld	s0,16(sp)
    8000377c:	6105                	addi	sp,sp,32
    8000377e:	8082                	ret

0000000080003780 <sys_sigalarm>:

// In sysproc.c
uint64 sys_sigalarm(void)
{
    80003780:	1101                	addi	sp,sp,-32
    80003782:	ec06                	sd	ra,24(sp)
    80003784:	e822                	sd	s0,16(sp)
    80003786:	1000                	addi	s0,sp,32
  int interval;
  argint(0, &interval);
    80003788:	fec40593          	addi	a1,s0,-20
    8000378c:	4501                	li	a0,0
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	c36080e7          	jalr	-970(ra) # 800033c4 <argint>
  uint64 handler;
  argaddr(1, &handler);
    80003796:	fe040593          	addi	a1,s0,-32
    8000379a:	4505                	li	a0,1
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	c48080e7          	jalr	-952(ra) # 800033e4 <argaddr>
  struct proc *p = myproc();
    800037a4:	ffffe097          	auipc	ra,0xffffe
    800037a8:	452080e7          	jalr	1106(ra) # 80001bf6 <myproc>
  p->alarm_interval = interval;
    800037ac:	fec42783          	lw	a5,-20(s0)
    800037b0:	0ef52223          	sw	a5,228(a0)
  p->handler = handler;
    800037b4:	fe043783          	ld	a5,-32(s0)
    800037b8:	f57c                	sd	a5,232(a0)
  p->ticks = 0;
    800037ba:	0e052023          	sw	zero,224(a0)
  p->alarm_active = 0;
    800037be:	20052823          	sw	zero,528(a0)
  // printf("gg");
  return 0;
}
    800037c2:	4501                	li	a0,0
    800037c4:	60e2                	ld	ra,24(sp)
    800037c6:	6442                	ld	s0,16(sp)
    800037c8:	6105                	addi	sp,sp,32
    800037ca:	8082                	ret

00000000800037cc <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800037cc:	1101                	addi	sp,sp,-32
    800037ce:	ec06                	sd	ra,24(sp)
    800037d0:	e822                	sd	s0,16(sp)
    800037d2:	e426                	sd	s1,8(sp)
    800037d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800037d6:	ffffe097          	auipc	ra,0xffffe
    800037da:	420080e7          	jalr	1056(ra) # 80001bf6 <myproc>
    800037de:	84aa                	mv	s1,a0
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe));
    800037e0:	12000613          	li	a2,288
    800037e4:	0f050593          	addi	a1,a0,240
    800037e8:	23053503          	ld	a0,560(a0)
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	5ae080e7          	jalr	1454(ra) # 80000d9a <memmove>
  p->alarm_active = 0;
    800037f4:	2004a823          	sw	zero,528(s1)
  return p->trapframe->a0;
    800037f8:	2304b783          	ld	a5,560(s1)
}
    800037fc:	7ba8                	ld	a0,112(a5)
    800037fe:	60e2                	ld	ra,24(sp)
    80003800:	6442                	ld	s0,16(sp)
    80003802:	64a2                	ld	s1,8(sp)
    80003804:	6105                	addi	sp,sp,32
    80003806:	8082                	ret

0000000080003808 <sys_settickets>:

uint64
sys_settickets(void)
{
    80003808:	1101                	addi	sp,sp,-32
    8000380a:	ec06                	sd	ra,24(sp)
    8000380c:	e822                	sd	s0,16(sp)
    8000380e:	1000                	addi	s0,sp,32
  int number;
  argint(0, &number);
    80003810:	fec40593          	addi	a1,s0,-20
    80003814:	4501                	li	a0,0
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	bae080e7          	jalr	-1106(ra) # 800033c4 <argint>
  if (number < 1)
    8000381e:	fec42783          	lw	a5,-20(s0)
    return -1;
    80003822:	557d                	li	a0,-1
  if (number < 1)
    80003824:	00f05b63          	blez	a5,8000383a <sys_settickets+0x32>
  struct proc *p = myproc();
    80003828:	ffffe097          	auipc	ra,0xffffe
    8000382c:	3ce080e7          	jalr	974(ra) # 80001bf6 <myproc>
  p->tickets = number;
    80003830:	fec42783          	lw	a5,-20(s0)
    80003834:	0cf52023          	sw	a5,192(a0)
  return 0;
    80003838:	4501                	li	a0,0
    8000383a:	60e2                	ld	ra,24(sp)
    8000383c:	6442                	ld	s0,16(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret

0000000080003842 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003842:	7179                	addi	sp,sp,-48
    80003844:	f406                	sd	ra,40(sp)
    80003846:	f022                	sd	s0,32(sp)
    80003848:	ec26                	sd	s1,24(sp)
    8000384a:	e84a                	sd	s2,16(sp)
    8000384c:	e44e                	sd	s3,8(sp)
    8000384e:	e052                	sd	s4,0(sp)
    80003850:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003852:	00005597          	auipc	a1,0x5
    80003856:	b9658593          	addi	a1,a1,-1130 # 800083e8 <etext+0x3e8>
    8000385a:	0001b517          	auipc	a0,0x1b
    8000385e:	35e50513          	addi	a0,a0,862 # 8001ebb8 <bcache>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	348080e7          	jalr	840(ra) # 80000baa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000386a:	00023797          	auipc	a5,0x23
    8000386e:	34e78793          	addi	a5,a5,846 # 80026bb8 <bcache+0x8000>
    80003872:	00023717          	auipc	a4,0x23
    80003876:	5ae70713          	addi	a4,a4,1454 # 80026e20 <bcache+0x8268>
    8000387a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000387e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003882:	0001b497          	auipc	s1,0x1b
    80003886:	34e48493          	addi	s1,s1,846 # 8001ebd0 <bcache+0x18>
    b->next = bcache.head.next;
    8000388a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000388c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000388e:	00005a17          	auipc	s4,0x5
    80003892:	b62a0a13          	addi	s4,s4,-1182 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80003896:	2b893783          	ld	a5,696(s2)
    8000389a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000389c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800038a0:	85d2                	mv	a1,s4
    800038a2:	01048513          	addi	a0,s1,16
    800038a6:	00001097          	auipc	ra,0x1
    800038aa:	4e4080e7          	jalr	1252(ra) # 80004d8a <initsleeplock>
    bcache.head.next->prev = b;
    800038ae:	2b893783          	ld	a5,696(s2)
    800038b2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800038b4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038b8:	45848493          	addi	s1,s1,1112
    800038bc:	fd349de3          	bne	s1,s3,80003896 <binit+0x54>
  }
}
    800038c0:	70a2                	ld	ra,40(sp)
    800038c2:	7402                	ld	s0,32(sp)
    800038c4:	64e2                	ld	s1,24(sp)
    800038c6:	6942                	ld	s2,16(sp)
    800038c8:	69a2                	ld	s3,8(sp)
    800038ca:	6a02                	ld	s4,0(sp)
    800038cc:	6145                	addi	sp,sp,48
    800038ce:	8082                	ret

00000000800038d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800038d0:	7179                	addi	sp,sp,-48
    800038d2:	f406                	sd	ra,40(sp)
    800038d4:	f022                	sd	s0,32(sp)
    800038d6:	ec26                	sd	s1,24(sp)
    800038d8:	e84a                	sd	s2,16(sp)
    800038da:	e44e                	sd	s3,8(sp)
    800038dc:	1800                	addi	s0,sp,48
    800038de:	892a                	mv	s2,a0
    800038e0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800038e2:	0001b517          	auipc	a0,0x1b
    800038e6:	2d650513          	addi	a0,a0,726 # 8001ebb8 <bcache>
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	354080e7          	jalr	852(ra) # 80000c3e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038f2:	00023497          	auipc	s1,0x23
    800038f6:	57e4b483          	ld	s1,1406(s1) # 80026e70 <bcache+0x82b8>
    800038fa:	00023797          	auipc	a5,0x23
    800038fe:	52678793          	addi	a5,a5,1318 # 80026e20 <bcache+0x8268>
    80003902:	02f48f63          	beq	s1,a5,80003940 <bread+0x70>
    80003906:	873e                	mv	a4,a5
    80003908:	a021                	j	80003910 <bread+0x40>
    8000390a:	68a4                	ld	s1,80(s1)
    8000390c:	02e48a63          	beq	s1,a4,80003940 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003910:	449c                	lw	a5,8(s1)
    80003912:	ff279ce3          	bne	a5,s2,8000390a <bread+0x3a>
    80003916:	44dc                	lw	a5,12(s1)
    80003918:	ff3799e3          	bne	a5,s3,8000390a <bread+0x3a>
      b->refcnt++;
    8000391c:	40bc                	lw	a5,64(s1)
    8000391e:	2785                	addiw	a5,a5,1
    80003920:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003922:	0001b517          	auipc	a0,0x1b
    80003926:	29650513          	addi	a0,a0,662 # 8001ebb8 <bcache>
    8000392a:	ffffd097          	auipc	ra,0xffffd
    8000392e:	3c4080e7          	jalr	964(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    80003932:	01048513          	addi	a0,s1,16
    80003936:	00001097          	auipc	ra,0x1
    8000393a:	48e080e7          	jalr	1166(ra) # 80004dc4 <acquiresleep>
      return b;
    8000393e:	a8b9                	j	8000399c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003940:	00023497          	auipc	s1,0x23
    80003944:	5284b483          	ld	s1,1320(s1) # 80026e68 <bcache+0x82b0>
    80003948:	00023797          	auipc	a5,0x23
    8000394c:	4d878793          	addi	a5,a5,1240 # 80026e20 <bcache+0x8268>
    80003950:	00f48863          	beq	s1,a5,80003960 <bread+0x90>
    80003954:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003956:	40bc                	lw	a5,64(s1)
    80003958:	cf81                	beqz	a5,80003970 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000395a:	64a4                	ld	s1,72(s1)
    8000395c:	fee49de3          	bne	s1,a4,80003956 <bread+0x86>
  panic("bget: no buffers");
    80003960:	00005517          	auipc	a0,0x5
    80003964:	a9850513          	addi	a0,a0,-1384 # 800083f8 <etext+0x3f8>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	bf8080e7          	jalr	-1032(ra) # 80000560 <panic>
      b->dev = dev;
    80003970:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003974:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003978:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000397c:	4785                	li	a5,1
    8000397e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003980:	0001b517          	auipc	a0,0x1b
    80003984:	23850513          	addi	a0,a0,568 # 8001ebb8 <bcache>
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	366080e7          	jalr	870(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    80003990:	01048513          	addi	a0,s1,16
    80003994:	00001097          	auipc	ra,0x1
    80003998:	430080e7          	jalr	1072(ra) # 80004dc4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000399c:	409c                	lw	a5,0(s1)
    8000399e:	cb89                	beqz	a5,800039b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800039a0:	8526                	mv	a0,s1
    800039a2:	70a2                	ld	ra,40(sp)
    800039a4:	7402                	ld	s0,32(sp)
    800039a6:	64e2                	ld	s1,24(sp)
    800039a8:	6942                	ld	s2,16(sp)
    800039aa:	69a2                	ld	s3,8(sp)
    800039ac:	6145                	addi	sp,sp,48
    800039ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800039b0:	4581                	li	a1,0
    800039b2:	8526                	mv	a0,s1
    800039b4:	00003097          	auipc	ra,0x3
    800039b8:	114080e7          	jalr	276(ra) # 80006ac8 <virtio_disk_rw>
    b->valid = 1;
    800039bc:	4785                	li	a5,1
    800039be:	c09c                	sw	a5,0(s1)
  return b;
    800039c0:	b7c5                	j	800039a0 <bread+0xd0>

00000000800039c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800039c2:	1101                	addi	sp,sp,-32
    800039c4:	ec06                	sd	ra,24(sp)
    800039c6:	e822                	sd	s0,16(sp)
    800039c8:	e426                	sd	s1,8(sp)
    800039ca:	1000                	addi	s0,sp,32
    800039cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039ce:	0541                	addi	a0,a0,16
    800039d0:	00001097          	auipc	ra,0x1
    800039d4:	48e080e7          	jalr	1166(ra) # 80004e5e <holdingsleep>
    800039d8:	cd01                	beqz	a0,800039f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800039da:	4585                	li	a1,1
    800039dc:	8526                	mv	a0,s1
    800039de:	00003097          	auipc	ra,0x3
    800039e2:	0ea080e7          	jalr	234(ra) # 80006ac8 <virtio_disk_rw>
}
    800039e6:	60e2                	ld	ra,24(sp)
    800039e8:	6442                	ld	s0,16(sp)
    800039ea:	64a2                	ld	s1,8(sp)
    800039ec:	6105                	addi	sp,sp,32
    800039ee:	8082                	ret
    panic("bwrite");
    800039f0:	00005517          	auipc	a0,0x5
    800039f4:	a2050513          	addi	a0,a0,-1504 # 80008410 <etext+0x410>
    800039f8:	ffffd097          	auipc	ra,0xffffd
    800039fc:	b68080e7          	jalr	-1176(ra) # 80000560 <panic>

0000000080003a00 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003a00:	1101                	addi	sp,sp,-32
    80003a02:	ec06                	sd	ra,24(sp)
    80003a04:	e822                	sd	s0,16(sp)
    80003a06:	e426                	sd	s1,8(sp)
    80003a08:	e04a                	sd	s2,0(sp)
    80003a0a:	1000                	addi	s0,sp,32
    80003a0c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a0e:	01050913          	addi	s2,a0,16
    80003a12:	854a                	mv	a0,s2
    80003a14:	00001097          	auipc	ra,0x1
    80003a18:	44a080e7          	jalr	1098(ra) # 80004e5e <holdingsleep>
    80003a1c:	c535                	beqz	a0,80003a88 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    80003a1e:	854a                	mv	a0,s2
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	3fa080e7          	jalr	1018(ra) # 80004e1a <releasesleep>

  acquire(&bcache.lock);
    80003a28:	0001b517          	auipc	a0,0x1b
    80003a2c:	19050513          	addi	a0,a0,400 # 8001ebb8 <bcache>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	20e080e7          	jalr	526(ra) # 80000c3e <acquire>
  b->refcnt--;
    80003a38:	40bc                	lw	a5,64(s1)
    80003a3a:	37fd                	addiw	a5,a5,-1
    80003a3c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a3e:	e79d                	bnez	a5,80003a6c <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a40:	68b8                	ld	a4,80(s1)
    80003a42:	64bc                	ld	a5,72(s1)
    80003a44:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003a46:	68b8                	ld	a4,80(s1)
    80003a48:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a4a:	00023797          	auipc	a5,0x23
    80003a4e:	16e78793          	addi	a5,a5,366 # 80026bb8 <bcache+0x8000>
    80003a52:	2b87b703          	ld	a4,696(a5)
    80003a56:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a58:	00023717          	auipc	a4,0x23
    80003a5c:	3c870713          	addi	a4,a4,968 # 80026e20 <bcache+0x8268>
    80003a60:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a62:	2b87b703          	ld	a4,696(a5)
    80003a66:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a68:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a6c:	0001b517          	auipc	a0,0x1b
    80003a70:	14c50513          	addi	a0,a0,332 # 8001ebb8 <bcache>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	27a080e7          	jalr	634(ra) # 80000cee <release>
}
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6902                	ld	s2,0(sp)
    80003a84:	6105                	addi	sp,sp,32
    80003a86:	8082                	ret
    panic("brelse");
    80003a88:	00005517          	auipc	a0,0x5
    80003a8c:	99050513          	addi	a0,a0,-1648 # 80008418 <etext+0x418>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	ad0080e7          	jalr	-1328(ra) # 80000560 <panic>

0000000080003a98 <bpin>:

void
bpin(struct buf *b) {
    80003a98:	1101                	addi	sp,sp,-32
    80003a9a:	ec06                	sd	ra,24(sp)
    80003a9c:	e822                	sd	s0,16(sp)
    80003a9e:	e426                	sd	s1,8(sp)
    80003aa0:	1000                	addi	s0,sp,32
    80003aa2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003aa4:	0001b517          	auipc	a0,0x1b
    80003aa8:	11450513          	addi	a0,a0,276 # 8001ebb8 <bcache>
    80003aac:	ffffd097          	auipc	ra,0xffffd
    80003ab0:	192080e7          	jalr	402(ra) # 80000c3e <acquire>
  b->refcnt++;
    80003ab4:	40bc                	lw	a5,64(s1)
    80003ab6:	2785                	addiw	a5,a5,1
    80003ab8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003aba:	0001b517          	auipc	a0,0x1b
    80003abe:	0fe50513          	addi	a0,a0,254 # 8001ebb8 <bcache>
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	22c080e7          	jalr	556(ra) # 80000cee <release>
}
    80003aca:	60e2                	ld	ra,24(sp)
    80003acc:	6442                	ld	s0,16(sp)
    80003ace:	64a2                	ld	s1,8(sp)
    80003ad0:	6105                	addi	sp,sp,32
    80003ad2:	8082                	ret

0000000080003ad4 <bunpin>:

void
bunpin(struct buf *b) {
    80003ad4:	1101                	addi	sp,sp,-32
    80003ad6:	ec06                	sd	ra,24(sp)
    80003ad8:	e822                	sd	s0,16(sp)
    80003ada:	e426                	sd	s1,8(sp)
    80003adc:	1000                	addi	s0,sp,32
    80003ade:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003ae0:	0001b517          	auipc	a0,0x1b
    80003ae4:	0d850513          	addi	a0,a0,216 # 8001ebb8 <bcache>
    80003ae8:	ffffd097          	auipc	ra,0xffffd
    80003aec:	156080e7          	jalr	342(ra) # 80000c3e <acquire>
  b->refcnt--;
    80003af0:	40bc                	lw	a5,64(s1)
    80003af2:	37fd                	addiw	a5,a5,-1
    80003af4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003af6:	0001b517          	auipc	a0,0x1b
    80003afa:	0c250513          	addi	a0,a0,194 # 8001ebb8 <bcache>
    80003afe:	ffffd097          	auipc	ra,0xffffd
    80003b02:	1f0080e7          	jalr	496(ra) # 80000cee <release>
}
    80003b06:	60e2                	ld	ra,24(sp)
    80003b08:	6442                	ld	s0,16(sp)
    80003b0a:	64a2                	ld	s1,8(sp)
    80003b0c:	6105                	addi	sp,sp,32
    80003b0e:	8082                	ret

0000000080003b10 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003b10:	1101                	addi	sp,sp,-32
    80003b12:	ec06                	sd	ra,24(sp)
    80003b14:	e822                	sd	s0,16(sp)
    80003b16:	e426                	sd	s1,8(sp)
    80003b18:	e04a                	sd	s2,0(sp)
    80003b1a:	1000                	addi	s0,sp,32
    80003b1c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003b1e:	00d5d79b          	srliw	a5,a1,0xd
    80003b22:	00023597          	auipc	a1,0x23
    80003b26:	7725a583          	lw	a1,1906(a1) # 80027294 <sb+0x1c>
    80003b2a:	9dbd                	addw	a1,a1,a5
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	da4080e7          	jalr	-604(ra) # 800038d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b34:	0074f713          	andi	a4,s1,7
    80003b38:	4785                	li	a5,1
    80003b3a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003b3e:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003b40:	90d9                	srli	s1,s1,0x36
    80003b42:	00950733          	add	a4,a0,s1
    80003b46:	05874703          	lbu	a4,88(a4)
    80003b4a:	00e7f6b3          	and	a3,a5,a4
    80003b4e:	c69d                	beqz	a3,80003b7c <bfree+0x6c>
    80003b50:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b52:	94aa                	add	s1,s1,a0
    80003b54:	fff7c793          	not	a5,a5
    80003b58:	8f7d                	and	a4,a4,a5
    80003b5a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003b5e:	00001097          	auipc	ra,0x1
    80003b62:	148080e7          	jalr	328(ra) # 80004ca6 <log_write>
  brelse(bp);
    80003b66:	854a                	mv	a0,s2
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	e98080e7          	jalr	-360(ra) # 80003a00 <brelse>
}
    80003b70:	60e2                	ld	ra,24(sp)
    80003b72:	6442                	ld	s0,16(sp)
    80003b74:	64a2                	ld	s1,8(sp)
    80003b76:	6902                	ld	s2,0(sp)
    80003b78:	6105                	addi	sp,sp,32
    80003b7a:	8082                	ret
    panic("freeing free block");
    80003b7c:	00005517          	auipc	a0,0x5
    80003b80:	8a450513          	addi	a0,a0,-1884 # 80008420 <etext+0x420>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	9dc080e7          	jalr	-1572(ra) # 80000560 <panic>

0000000080003b8c <balloc>:
{
    80003b8c:	715d                	addi	sp,sp,-80
    80003b8e:	e486                	sd	ra,72(sp)
    80003b90:	e0a2                	sd	s0,64(sp)
    80003b92:	fc26                	sd	s1,56(sp)
    80003b94:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003b96:	00023797          	auipc	a5,0x23
    80003b9a:	6e67a783          	lw	a5,1766(a5) # 8002727c <sb+0x4>
    80003b9e:	10078863          	beqz	a5,80003cae <balloc+0x122>
    80003ba2:	f84a                	sd	s2,48(sp)
    80003ba4:	f44e                	sd	s3,40(sp)
    80003ba6:	f052                	sd	s4,32(sp)
    80003ba8:	ec56                	sd	s5,24(sp)
    80003baa:	e85a                	sd	s6,16(sp)
    80003bac:	e45e                	sd	s7,8(sp)
    80003bae:	e062                	sd	s8,0(sp)
    80003bb0:	8baa                	mv	s7,a0
    80003bb2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003bb4:	00023b17          	auipc	s6,0x23
    80003bb8:	6c4b0b13          	addi	s6,s6,1732 # 80027278 <sb>
      m = 1 << (bi % 8);
    80003bbc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bbe:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003bc0:	6c09                	lui	s8,0x2
    80003bc2:	a049                	j	80003c44 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003bc4:	97ca                	add	a5,a5,s2
    80003bc6:	8e55                	or	a2,a2,a3
    80003bc8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003bcc:	854a                	mv	a0,s2
    80003bce:	00001097          	auipc	ra,0x1
    80003bd2:	0d8080e7          	jalr	216(ra) # 80004ca6 <log_write>
        brelse(bp);
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	e28080e7          	jalr	-472(ra) # 80003a00 <brelse>
  bp = bread(dev, bno);
    80003be0:	85a6                	mv	a1,s1
    80003be2:	855e                	mv	a0,s7
    80003be4:	00000097          	auipc	ra,0x0
    80003be8:	cec080e7          	jalr	-788(ra) # 800038d0 <bread>
    80003bec:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003bee:	40000613          	li	a2,1024
    80003bf2:	4581                	li	a1,0
    80003bf4:	05850513          	addi	a0,a0,88
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	13e080e7          	jalr	318(ra) # 80000d36 <memset>
  log_write(bp);
    80003c00:	854a                	mv	a0,s2
    80003c02:	00001097          	auipc	ra,0x1
    80003c06:	0a4080e7          	jalr	164(ra) # 80004ca6 <log_write>
  brelse(bp);
    80003c0a:	854a                	mv	a0,s2
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	df4080e7          	jalr	-524(ra) # 80003a00 <brelse>
}
    80003c14:	7942                	ld	s2,48(sp)
    80003c16:	79a2                	ld	s3,40(sp)
    80003c18:	7a02                	ld	s4,32(sp)
    80003c1a:	6ae2                	ld	s5,24(sp)
    80003c1c:	6b42                	ld	s6,16(sp)
    80003c1e:	6ba2                	ld	s7,8(sp)
    80003c20:	6c02                	ld	s8,0(sp)
}
    80003c22:	8526                	mv	a0,s1
    80003c24:	60a6                	ld	ra,72(sp)
    80003c26:	6406                	ld	s0,64(sp)
    80003c28:	74e2                	ld	s1,56(sp)
    80003c2a:	6161                	addi	sp,sp,80
    80003c2c:	8082                	ret
    brelse(bp);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	dd0080e7          	jalr	-560(ra) # 80003a00 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003c38:	015c0abb          	addw	s5,s8,s5
    80003c3c:	004b2783          	lw	a5,4(s6)
    80003c40:	06faf063          	bgeu	s5,a5,80003ca0 <balloc+0x114>
    bp = bread(dev, BBLOCK(b, sb));
    80003c44:	41fad79b          	sraiw	a5,s5,0x1f
    80003c48:	0137d79b          	srliw	a5,a5,0x13
    80003c4c:	015787bb          	addw	a5,a5,s5
    80003c50:	40d7d79b          	sraiw	a5,a5,0xd
    80003c54:	01cb2583          	lw	a1,28(s6)
    80003c58:	9dbd                	addw	a1,a1,a5
    80003c5a:	855e                	mv	a0,s7
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	c74080e7          	jalr	-908(ra) # 800038d0 <bread>
    80003c64:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c66:	004b2503          	lw	a0,4(s6)
    80003c6a:	84d6                	mv	s1,s5
    80003c6c:	4701                	li	a4,0
    80003c6e:	fca4f0e3          	bgeu	s1,a0,80003c2e <balloc+0xa2>
      m = 1 << (bi % 8);
    80003c72:	00777693          	andi	a3,a4,7
    80003c76:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003c7a:	41f7579b          	sraiw	a5,a4,0x1f
    80003c7e:	01d7d79b          	srliw	a5,a5,0x1d
    80003c82:	9fb9                	addw	a5,a5,a4
    80003c84:	4037d79b          	sraiw	a5,a5,0x3
    80003c88:	00f90633          	add	a2,s2,a5
    80003c8c:	05864603          	lbu	a2,88(a2)
    80003c90:	00c6f5b3          	and	a1,a3,a2
    80003c94:	d985                	beqz	a1,80003bc4 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c96:	2705                	addiw	a4,a4,1
    80003c98:	2485                	addiw	s1,s1,1
    80003c9a:	fd471ae3          	bne	a4,s4,80003c6e <balloc+0xe2>
    80003c9e:	bf41                	j	80003c2e <balloc+0xa2>
    80003ca0:	7942                	ld	s2,48(sp)
    80003ca2:	79a2                	ld	s3,40(sp)
    80003ca4:	7a02                	ld	s4,32(sp)
    80003ca6:	6ae2                	ld	s5,24(sp)
    80003ca8:	6b42                	ld	s6,16(sp)
    80003caa:	6ba2                	ld	s7,8(sp)
    80003cac:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003cae:	00004517          	auipc	a0,0x4
    80003cb2:	78a50513          	addi	a0,a0,1930 # 80008438 <etext+0x438>
    80003cb6:	ffffd097          	auipc	ra,0xffffd
    80003cba:	8f4080e7          	jalr	-1804(ra) # 800005aa <printf>
  return 0;
    80003cbe:	4481                	li	s1,0
    80003cc0:	b78d                	j	80003c22 <balloc+0x96>

0000000080003cc2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003cc2:	7179                	addi	sp,sp,-48
    80003cc4:	f406                	sd	ra,40(sp)
    80003cc6:	f022                	sd	s0,32(sp)
    80003cc8:	ec26                	sd	s1,24(sp)
    80003cca:	e84a                	sd	s2,16(sp)
    80003ccc:	e44e                	sd	s3,8(sp)
    80003cce:	1800                	addi	s0,sp,48
    80003cd0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003cd2:	47ad                	li	a5,11
    80003cd4:	02b7e563          	bltu	a5,a1,80003cfe <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003cd8:	02059793          	slli	a5,a1,0x20
    80003cdc:	01e7d593          	srli	a1,a5,0x1e
    80003ce0:	00b504b3          	add	s1,a0,a1
    80003ce4:	0504a903          	lw	s2,80(s1)
    80003ce8:	06091b63          	bnez	s2,80003d5e <bmap+0x9c>
      addr = balloc(ip->dev);
    80003cec:	4108                	lw	a0,0(a0)
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	e9e080e7          	jalr	-354(ra) # 80003b8c <balloc>
    80003cf6:	892a                	mv	s2,a0
      if(addr == 0)
    80003cf8:	c13d                	beqz	a0,80003d5e <bmap+0x9c>
        return 0;
      ip->addrs[bn] = addr;
    80003cfa:	c8a8                	sw	a0,80(s1)
    80003cfc:	a08d                	j	80003d5e <bmap+0x9c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003cfe:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003d02:	0ff00793          	li	a5,255
    80003d06:	0897e363          	bltu	a5,s1,80003d8c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003d0a:	08052903          	lw	s2,128(a0)
    80003d0e:	00091d63          	bnez	s2,80003d28 <bmap+0x66>
      addr = balloc(ip->dev);
    80003d12:	4108                	lw	a0,0(a0)
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	e78080e7          	jalr	-392(ra) # 80003b8c <balloc>
    80003d1c:	892a                	mv	s2,a0
      if(addr == 0)
    80003d1e:	c121                	beqz	a0,80003d5e <bmap+0x9c>
    80003d20:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003d22:	08a9a023          	sw	a0,128(s3)
    80003d26:	a011                	j	80003d2a <bmap+0x68>
    80003d28:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003d2a:	85ca                	mv	a1,s2
    80003d2c:	0009a503          	lw	a0,0(s3)
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	ba0080e7          	jalr	-1120(ra) # 800038d0 <bread>
    80003d38:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003d3a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003d3e:	02049713          	slli	a4,s1,0x20
    80003d42:	01e75593          	srli	a1,a4,0x1e
    80003d46:	00b784b3          	add	s1,a5,a1
    80003d4a:	0004a903          	lw	s2,0(s1)
    80003d4e:	02090063          	beqz	s2,80003d6e <bmap+0xac>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003d52:	8552                	mv	a0,s4
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	cac080e7          	jalr	-852(ra) # 80003a00 <brelse>
    return addr;
    80003d5c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003d5e:	854a                	mv	a0,s2
    80003d60:	70a2                	ld	ra,40(sp)
    80003d62:	7402                	ld	s0,32(sp)
    80003d64:	64e2                	ld	s1,24(sp)
    80003d66:	6942                	ld	s2,16(sp)
    80003d68:	69a2                	ld	s3,8(sp)
    80003d6a:	6145                	addi	sp,sp,48
    80003d6c:	8082                	ret
      addr = balloc(ip->dev);
    80003d6e:	0009a503          	lw	a0,0(s3)
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	e1a080e7          	jalr	-486(ra) # 80003b8c <balloc>
    80003d7a:	892a                	mv	s2,a0
      if(addr){
    80003d7c:	d979                	beqz	a0,80003d52 <bmap+0x90>
        a[bn] = addr;
    80003d7e:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003d80:	8552                	mv	a0,s4
    80003d82:	00001097          	auipc	ra,0x1
    80003d86:	f24080e7          	jalr	-220(ra) # 80004ca6 <log_write>
    80003d8a:	b7e1                	j	80003d52 <bmap+0x90>
    80003d8c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003d8e:	00004517          	auipc	a0,0x4
    80003d92:	6c250513          	addi	a0,a0,1730 # 80008450 <etext+0x450>
    80003d96:	ffffc097          	auipc	ra,0xffffc
    80003d9a:	7ca080e7          	jalr	1994(ra) # 80000560 <panic>

0000000080003d9e <iget>:
{
    80003d9e:	7179                	addi	sp,sp,-48
    80003da0:	f406                	sd	ra,40(sp)
    80003da2:	f022                	sd	s0,32(sp)
    80003da4:	ec26                	sd	s1,24(sp)
    80003da6:	e84a                	sd	s2,16(sp)
    80003da8:	e44e                	sd	s3,8(sp)
    80003daa:	e052                	sd	s4,0(sp)
    80003dac:	1800                	addi	s0,sp,48
    80003dae:	89aa                	mv	s3,a0
    80003db0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003db2:	00023517          	auipc	a0,0x23
    80003db6:	4e650513          	addi	a0,a0,1254 # 80027298 <itable>
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	e84080e7          	jalr	-380(ra) # 80000c3e <acquire>
  empty = 0;
    80003dc2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003dc4:	00023497          	auipc	s1,0x23
    80003dc8:	4ec48493          	addi	s1,s1,1260 # 800272b0 <itable+0x18>
    80003dcc:	00025697          	auipc	a3,0x25
    80003dd0:	f7468693          	addi	a3,a3,-140 # 80028d40 <log>
    80003dd4:	a039                	j	80003de2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003dd6:	02090b63          	beqz	s2,80003e0c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003dda:	08848493          	addi	s1,s1,136
    80003dde:	02d48a63          	beq	s1,a3,80003e12 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003de2:	449c                	lw	a5,8(s1)
    80003de4:	fef059e3          	blez	a5,80003dd6 <iget+0x38>
    80003de8:	4098                	lw	a4,0(s1)
    80003dea:	ff3716e3          	bne	a4,s3,80003dd6 <iget+0x38>
    80003dee:	40d8                	lw	a4,4(s1)
    80003df0:	ff4713e3          	bne	a4,s4,80003dd6 <iget+0x38>
      ip->ref++;
    80003df4:	2785                	addiw	a5,a5,1
    80003df6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003df8:	00023517          	auipc	a0,0x23
    80003dfc:	4a050513          	addi	a0,a0,1184 # 80027298 <itable>
    80003e00:	ffffd097          	auipc	ra,0xffffd
    80003e04:	eee080e7          	jalr	-274(ra) # 80000cee <release>
      return ip;
    80003e08:	8926                	mv	s2,s1
    80003e0a:	a03d                	j	80003e38 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e0c:	f7f9                	bnez	a5,80003dda <iget+0x3c>
      empty = ip;
    80003e0e:	8926                	mv	s2,s1
    80003e10:	b7e9                	j	80003dda <iget+0x3c>
  if(empty == 0)
    80003e12:	02090c63          	beqz	s2,80003e4a <iget+0xac>
  ip->dev = dev;
    80003e16:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003e1a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003e1e:	4785                	li	a5,1
    80003e20:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003e24:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003e28:	00023517          	auipc	a0,0x23
    80003e2c:	47050513          	addi	a0,a0,1136 # 80027298 <itable>
    80003e30:	ffffd097          	auipc	ra,0xffffd
    80003e34:	ebe080e7          	jalr	-322(ra) # 80000cee <release>
}
    80003e38:	854a                	mv	a0,s2
    80003e3a:	70a2                	ld	ra,40(sp)
    80003e3c:	7402                	ld	s0,32(sp)
    80003e3e:	64e2                	ld	s1,24(sp)
    80003e40:	6942                	ld	s2,16(sp)
    80003e42:	69a2                	ld	s3,8(sp)
    80003e44:	6a02                	ld	s4,0(sp)
    80003e46:	6145                	addi	sp,sp,48
    80003e48:	8082                	ret
    panic("iget: no inodes");
    80003e4a:	00004517          	auipc	a0,0x4
    80003e4e:	61e50513          	addi	a0,a0,1566 # 80008468 <etext+0x468>
    80003e52:	ffffc097          	auipc	ra,0xffffc
    80003e56:	70e080e7          	jalr	1806(ra) # 80000560 <panic>

0000000080003e5a <fsinit>:
fsinit(int dev) {
    80003e5a:	7179                	addi	sp,sp,-48
    80003e5c:	f406                	sd	ra,40(sp)
    80003e5e:	f022                	sd	s0,32(sp)
    80003e60:	ec26                	sd	s1,24(sp)
    80003e62:	e84a                	sd	s2,16(sp)
    80003e64:	e44e                	sd	s3,8(sp)
    80003e66:	1800                	addi	s0,sp,48
    80003e68:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e6a:	4585                	li	a1,1
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	a64080e7          	jalr	-1436(ra) # 800038d0 <bread>
    80003e74:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e76:	00023997          	auipc	s3,0x23
    80003e7a:	40298993          	addi	s3,s3,1026 # 80027278 <sb>
    80003e7e:	02000613          	li	a2,32
    80003e82:	05850593          	addi	a1,a0,88
    80003e86:	854e                	mv	a0,s3
    80003e88:	ffffd097          	auipc	ra,0xffffd
    80003e8c:	f12080e7          	jalr	-238(ra) # 80000d9a <memmove>
  brelse(bp);
    80003e90:	8526                	mv	a0,s1
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	b6e080e7          	jalr	-1170(ra) # 80003a00 <brelse>
  if(sb.magic != FSMAGIC)
    80003e9a:	0009a703          	lw	a4,0(s3)
    80003e9e:	102037b7          	lui	a5,0x10203
    80003ea2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ea6:	02f71263          	bne	a4,a5,80003eca <fsinit+0x70>
  initlog(dev, &sb);
    80003eaa:	00023597          	auipc	a1,0x23
    80003eae:	3ce58593          	addi	a1,a1,974 # 80027278 <sb>
    80003eb2:	854a                	mv	a0,s2
    80003eb4:	00001097          	auipc	ra,0x1
    80003eb8:	b7c080e7          	jalr	-1156(ra) # 80004a30 <initlog>
}
    80003ebc:	70a2                	ld	ra,40(sp)
    80003ebe:	7402                	ld	s0,32(sp)
    80003ec0:	64e2                	ld	s1,24(sp)
    80003ec2:	6942                	ld	s2,16(sp)
    80003ec4:	69a2                	ld	s3,8(sp)
    80003ec6:	6145                	addi	sp,sp,48
    80003ec8:	8082                	ret
    panic("invalid file system");
    80003eca:	00004517          	auipc	a0,0x4
    80003ece:	5ae50513          	addi	a0,a0,1454 # 80008478 <etext+0x478>
    80003ed2:	ffffc097          	auipc	ra,0xffffc
    80003ed6:	68e080e7          	jalr	1678(ra) # 80000560 <panic>

0000000080003eda <iinit>:
{
    80003eda:	7179                	addi	sp,sp,-48
    80003edc:	f406                	sd	ra,40(sp)
    80003ede:	f022                	sd	s0,32(sp)
    80003ee0:	ec26                	sd	s1,24(sp)
    80003ee2:	e84a                	sd	s2,16(sp)
    80003ee4:	e44e                	sd	s3,8(sp)
    80003ee6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ee8:	00004597          	auipc	a1,0x4
    80003eec:	5a858593          	addi	a1,a1,1448 # 80008490 <etext+0x490>
    80003ef0:	00023517          	auipc	a0,0x23
    80003ef4:	3a850513          	addi	a0,a0,936 # 80027298 <itable>
    80003ef8:	ffffd097          	auipc	ra,0xffffd
    80003efc:	cb2080e7          	jalr	-846(ra) # 80000baa <initlock>
  for(i = 0; i < NINODE; i++) {
    80003f00:	00023497          	auipc	s1,0x23
    80003f04:	3c048493          	addi	s1,s1,960 # 800272c0 <itable+0x28>
    80003f08:	00025997          	auipc	s3,0x25
    80003f0c:	e4898993          	addi	s3,s3,-440 # 80028d50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003f10:	00004917          	auipc	s2,0x4
    80003f14:	58890913          	addi	s2,s2,1416 # 80008498 <etext+0x498>
    80003f18:	85ca                	mv	a1,s2
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	00001097          	auipc	ra,0x1
    80003f20:	e6e080e7          	jalr	-402(ra) # 80004d8a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f24:	08848493          	addi	s1,s1,136
    80003f28:	ff3498e3          	bne	s1,s3,80003f18 <iinit+0x3e>
}
    80003f2c:	70a2                	ld	ra,40(sp)
    80003f2e:	7402                	ld	s0,32(sp)
    80003f30:	64e2                	ld	s1,24(sp)
    80003f32:	6942                	ld	s2,16(sp)
    80003f34:	69a2                	ld	s3,8(sp)
    80003f36:	6145                	addi	sp,sp,48
    80003f38:	8082                	ret

0000000080003f3a <ialloc>:
{
    80003f3a:	7139                	addi	sp,sp,-64
    80003f3c:	fc06                	sd	ra,56(sp)
    80003f3e:	f822                	sd	s0,48(sp)
    80003f40:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f42:	00023717          	auipc	a4,0x23
    80003f46:	34272703          	lw	a4,834(a4) # 80027284 <sb+0xc>
    80003f4a:	4785                	li	a5,1
    80003f4c:	06e7f463          	bgeu	a5,a4,80003fb4 <ialloc+0x7a>
    80003f50:	f426                	sd	s1,40(sp)
    80003f52:	f04a                	sd	s2,32(sp)
    80003f54:	ec4e                	sd	s3,24(sp)
    80003f56:	e852                	sd	s4,16(sp)
    80003f58:	e456                	sd	s5,8(sp)
    80003f5a:	e05a                	sd	s6,0(sp)
    80003f5c:	8aaa                	mv	s5,a0
    80003f5e:	8b2e                	mv	s6,a1
    80003f60:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003f62:	00023a17          	auipc	s4,0x23
    80003f66:	316a0a13          	addi	s4,s4,790 # 80027278 <sb>
    80003f6a:	00495593          	srli	a1,s2,0x4
    80003f6e:	018a2783          	lw	a5,24(s4)
    80003f72:	9dbd                	addw	a1,a1,a5
    80003f74:	8556                	mv	a0,s5
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	95a080e7          	jalr	-1702(ra) # 800038d0 <bread>
    80003f7e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f80:	05850993          	addi	s3,a0,88
    80003f84:	00f97793          	andi	a5,s2,15
    80003f88:	079a                	slli	a5,a5,0x6
    80003f8a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f8c:	00099783          	lh	a5,0(s3)
    80003f90:	cf9d                	beqz	a5,80003fce <ialloc+0x94>
    brelse(bp);
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	a6e080e7          	jalr	-1426(ra) # 80003a00 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f9a:	0905                	addi	s2,s2,1
    80003f9c:	00ca2703          	lw	a4,12(s4)
    80003fa0:	0009079b          	sext.w	a5,s2
    80003fa4:	fce7e3e3          	bltu	a5,a4,80003f6a <ialloc+0x30>
    80003fa8:	74a2                	ld	s1,40(sp)
    80003faa:	7902                	ld	s2,32(sp)
    80003fac:	69e2                	ld	s3,24(sp)
    80003fae:	6a42                	ld	s4,16(sp)
    80003fb0:	6aa2                	ld	s5,8(sp)
    80003fb2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003fb4:	00004517          	auipc	a0,0x4
    80003fb8:	4ec50513          	addi	a0,a0,1260 # 800084a0 <etext+0x4a0>
    80003fbc:	ffffc097          	auipc	ra,0xffffc
    80003fc0:	5ee080e7          	jalr	1518(ra) # 800005aa <printf>
  return 0;
    80003fc4:	4501                	li	a0,0
}
    80003fc6:	70e2                	ld	ra,56(sp)
    80003fc8:	7442                	ld	s0,48(sp)
    80003fca:	6121                	addi	sp,sp,64
    80003fcc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003fce:	04000613          	li	a2,64
    80003fd2:	4581                	li	a1,0
    80003fd4:	854e                	mv	a0,s3
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	d60080e7          	jalr	-672(ra) # 80000d36 <memset>
      dip->type = type;
    80003fde:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	00001097          	auipc	ra,0x1
    80003fe8:	cc2080e7          	jalr	-830(ra) # 80004ca6 <log_write>
      brelse(bp);
    80003fec:	8526                	mv	a0,s1
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	a12080e7          	jalr	-1518(ra) # 80003a00 <brelse>
      return iget(dev, inum);
    80003ff6:	0009059b          	sext.w	a1,s2
    80003ffa:	8556                	mv	a0,s5
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	da2080e7          	jalr	-606(ra) # 80003d9e <iget>
    80004004:	74a2                	ld	s1,40(sp)
    80004006:	7902                	ld	s2,32(sp)
    80004008:	69e2                	ld	s3,24(sp)
    8000400a:	6a42                	ld	s4,16(sp)
    8000400c:	6aa2                	ld	s5,8(sp)
    8000400e:	6b02                	ld	s6,0(sp)
    80004010:	bf5d                	j	80003fc6 <ialloc+0x8c>

0000000080004012 <iupdate>:
{
    80004012:	1101                	addi	sp,sp,-32
    80004014:	ec06                	sd	ra,24(sp)
    80004016:	e822                	sd	s0,16(sp)
    80004018:	e426                	sd	s1,8(sp)
    8000401a:	e04a                	sd	s2,0(sp)
    8000401c:	1000                	addi	s0,sp,32
    8000401e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004020:	415c                	lw	a5,4(a0)
    80004022:	0047d79b          	srliw	a5,a5,0x4
    80004026:	00023597          	auipc	a1,0x23
    8000402a:	26a5a583          	lw	a1,618(a1) # 80027290 <sb+0x18>
    8000402e:	9dbd                	addw	a1,a1,a5
    80004030:	4108                	lw	a0,0(a0)
    80004032:	00000097          	auipc	ra,0x0
    80004036:	89e080e7          	jalr	-1890(ra) # 800038d0 <bread>
    8000403a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000403c:	05850793          	addi	a5,a0,88
    80004040:	40d8                	lw	a4,4(s1)
    80004042:	8b3d                	andi	a4,a4,15
    80004044:	071a                	slli	a4,a4,0x6
    80004046:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004048:	04449703          	lh	a4,68(s1)
    8000404c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004050:	04649703          	lh	a4,70(s1)
    80004054:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004058:	04849703          	lh	a4,72(s1)
    8000405c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004060:	04a49703          	lh	a4,74(s1)
    80004064:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004068:	44f8                	lw	a4,76(s1)
    8000406a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000406c:	03400613          	li	a2,52
    80004070:	05048593          	addi	a1,s1,80
    80004074:	00c78513          	addi	a0,a5,12
    80004078:	ffffd097          	auipc	ra,0xffffd
    8000407c:	d22080e7          	jalr	-734(ra) # 80000d9a <memmove>
  log_write(bp);
    80004080:	854a                	mv	a0,s2
    80004082:	00001097          	auipc	ra,0x1
    80004086:	c24080e7          	jalr	-988(ra) # 80004ca6 <log_write>
  brelse(bp);
    8000408a:	854a                	mv	a0,s2
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	974080e7          	jalr	-1676(ra) # 80003a00 <brelse>
}
    80004094:	60e2                	ld	ra,24(sp)
    80004096:	6442                	ld	s0,16(sp)
    80004098:	64a2                	ld	s1,8(sp)
    8000409a:	6902                	ld	s2,0(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret

00000000800040a0 <idup>:
{
    800040a0:	1101                	addi	sp,sp,-32
    800040a2:	ec06                	sd	ra,24(sp)
    800040a4:	e822                	sd	s0,16(sp)
    800040a6:	e426                	sd	s1,8(sp)
    800040a8:	1000                	addi	s0,sp,32
    800040aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040ac:	00023517          	auipc	a0,0x23
    800040b0:	1ec50513          	addi	a0,a0,492 # 80027298 <itable>
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	b8a080e7          	jalr	-1142(ra) # 80000c3e <acquire>
  ip->ref++;
    800040bc:	449c                	lw	a5,8(s1)
    800040be:	2785                	addiw	a5,a5,1
    800040c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040c2:	00023517          	auipc	a0,0x23
    800040c6:	1d650513          	addi	a0,a0,470 # 80027298 <itable>
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	c24080e7          	jalr	-988(ra) # 80000cee <release>
}
    800040d2:	8526                	mv	a0,s1
    800040d4:	60e2                	ld	ra,24(sp)
    800040d6:	6442                	ld	s0,16(sp)
    800040d8:	64a2                	ld	s1,8(sp)
    800040da:	6105                	addi	sp,sp,32
    800040dc:	8082                	ret

00000000800040de <ilock>:
{
    800040de:	1101                	addi	sp,sp,-32
    800040e0:	ec06                	sd	ra,24(sp)
    800040e2:	e822                	sd	s0,16(sp)
    800040e4:	e426                	sd	s1,8(sp)
    800040e6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800040e8:	c10d                	beqz	a0,8000410a <ilock+0x2c>
    800040ea:	84aa                	mv	s1,a0
    800040ec:	451c                	lw	a5,8(a0)
    800040ee:	00f05e63          	blez	a5,8000410a <ilock+0x2c>
  acquiresleep(&ip->lock);
    800040f2:	0541                	addi	a0,a0,16
    800040f4:	00001097          	auipc	ra,0x1
    800040f8:	cd0080e7          	jalr	-816(ra) # 80004dc4 <acquiresleep>
  if(ip->valid == 0){
    800040fc:	40bc                	lw	a5,64(s1)
    800040fe:	cf99                	beqz	a5,8000411c <ilock+0x3e>
}
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	64a2                	ld	s1,8(sp)
    80004106:	6105                	addi	sp,sp,32
    80004108:	8082                	ret
    8000410a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000410c:	00004517          	auipc	a0,0x4
    80004110:	3ac50513          	addi	a0,a0,940 # 800084b8 <etext+0x4b8>
    80004114:	ffffc097          	auipc	ra,0xffffc
    80004118:	44c080e7          	jalr	1100(ra) # 80000560 <panic>
    8000411c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000411e:	40dc                	lw	a5,4(s1)
    80004120:	0047d79b          	srliw	a5,a5,0x4
    80004124:	00023597          	auipc	a1,0x23
    80004128:	16c5a583          	lw	a1,364(a1) # 80027290 <sb+0x18>
    8000412c:	9dbd                	addw	a1,a1,a5
    8000412e:	4088                	lw	a0,0(s1)
    80004130:	fffff097          	auipc	ra,0xfffff
    80004134:	7a0080e7          	jalr	1952(ra) # 800038d0 <bread>
    80004138:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000413a:	05850593          	addi	a1,a0,88
    8000413e:	40dc                	lw	a5,4(s1)
    80004140:	8bbd                	andi	a5,a5,15
    80004142:	079a                	slli	a5,a5,0x6
    80004144:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004146:	00059783          	lh	a5,0(a1)
    8000414a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000414e:	00259783          	lh	a5,2(a1)
    80004152:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004156:	00459783          	lh	a5,4(a1)
    8000415a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000415e:	00659783          	lh	a5,6(a1)
    80004162:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004166:	459c                	lw	a5,8(a1)
    80004168:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000416a:	03400613          	li	a2,52
    8000416e:	05b1                	addi	a1,a1,12
    80004170:	05048513          	addi	a0,s1,80
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	c26080e7          	jalr	-986(ra) # 80000d9a <memmove>
    brelse(bp);
    8000417c:	854a                	mv	a0,s2
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	882080e7          	jalr	-1918(ra) # 80003a00 <brelse>
    ip->valid = 1;
    80004186:	4785                	li	a5,1
    80004188:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000418a:	04449783          	lh	a5,68(s1)
    8000418e:	c399                	beqz	a5,80004194 <ilock+0xb6>
    80004190:	6902                	ld	s2,0(sp)
    80004192:	b7bd                	j	80004100 <ilock+0x22>
      panic("ilock: no type");
    80004194:	00004517          	auipc	a0,0x4
    80004198:	32c50513          	addi	a0,a0,812 # 800084c0 <etext+0x4c0>
    8000419c:	ffffc097          	auipc	ra,0xffffc
    800041a0:	3c4080e7          	jalr	964(ra) # 80000560 <panic>

00000000800041a4 <iunlock>:
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	e04a                	sd	s2,0(sp)
    800041ae:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800041b0:	c905                	beqz	a0,800041e0 <iunlock+0x3c>
    800041b2:	84aa                	mv	s1,a0
    800041b4:	01050913          	addi	s2,a0,16
    800041b8:	854a                	mv	a0,s2
    800041ba:	00001097          	auipc	ra,0x1
    800041be:	ca4080e7          	jalr	-860(ra) # 80004e5e <holdingsleep>
    800041c2:	cd19                	beqz	a0,800041e0 <iunlock+0x3c>
    800041c4:	449c                	lw	a5,8(s1)
    800041c6:	00f05d63          	blez	a5,800041e0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800041ca:	854a                	mv	a0,s2
    800041cc:	00001097          	auipc	ra,0x1
    800041d0:	c4e080e7          	jalr	-946(ra) # 80004e1a <releasesleep>
}
    800041d4:	60e2                	ld	ra,24(sp)
    800041d6:	6442                	ld	s0,16(sp)
    800041d8:	64a2                	ld	s1,8(sp)
    800041da:	6902                	ld	s2,0(sp)
    800041dc:	6105                	addi	sp,sp,32
    800041de:	8082                	ret
    panic("iunlock");
    800041e0:	00004517          	auipc	a0,0x4
    800041e4:	2f050513          	addi	a0,a0,752 # 800084d0 <etext+0x4d0>
    800041e8:	ffffc097          	auipc	ra,0xffffc
    800041ec:	378080e7          	jalr	888(ra) # 80000560 <panic>

00000000800041f0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800041f0:	7179                	addi	sp,sp,-48
    800041f2:	f406                	sd	ra,40(sp)
    800041f4:	f022                	sd	s0,32(sp)
    800041f6:	ec26                	sd	s1,24(sp)
    800041f8:	e84a                	sd	s2,16(sp)
    800041fa:	e44e                	sd	s3,8(sp)
    800041fc:	1800                	addi	s0,sp,48
    800041fe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004200:	05050493          	addi	s1,a0,80
    80004204:	08050913          	addi	s2,a0,128
    80004208:	a021                	j	80004210 <itrunc+0x20>
    8000420a:	0491                	addi	s1,s1,4
    8000420c:	01248d63          	beq	s1,s2,80004226 <itrunc+0x36>
    if(ip->addrs[i]){
    80004210:	408c                	lw	a1,0(s1)
    80004212:	dde5                	beqz	a1,8000420a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004214:	0009a503          	lw	a0,0(s3)
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	8f8080e7          	jalr	-1800(ra) # 80003b10 <bfree>
      ip->addrs[i] = 0;
    80004220:	0004a023          	sw	zero,0(s1)
    80004224:	b7dd                	j	8000420a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004226:	0809a583          	lw	a1,128(s3)
    8000422a:	ed99                	bnez	a1,80004248 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000422c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004230:	854e                	mv	a0,s3
    80004232:	00000097          	auipc	ra,0x0
    80004236:	de0080e7          	jalr	-544(ra) # 80004012 <iupdate>
}
    8000423a:	70a2                	ld	ra,40(sp)
    8000423c:	7402                	ld	s0,32(sp)
    8000423e:	64e2                	ld	s1,24(sp)
    80004240:	6942                	ld	s2,16(sp)
    80004242:	69a2                	ld	s3,8(sp)
    80004244:	6145                	addi	sp,sp,48
    80004246:	8082                	ret
    80004248:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000424a:	0009a503          	lw	a0,0(s3)
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	682080e7          	jalr	1666(ra) # 800038d0 <bread>
    80004256:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004258:	05850493          	addi	s1,a0,88
    8000425c:	45850913          	addi	s2,a0,1112
    80004260:	a021                	j	80004268 <itrunc+0x78>
    80004262:	0491                	addi	s1,s1,4
    80004264:	01248b63          	beq	s1,s2,8000427a <itrunc+0x8a>
      if(a[j])
    80004268:	408c                	lw	a1,0(s1)
    8000426a:	dde5                	beqz	a1,80004262 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    8000426c:	0009a503          	lw	a0,0(s3)
    80004270:	00000097          	auipc	ra,0x0
    80004274:	8a0080e7          	jalr	-1888(ra) # 80003b10 <bfree>
    80004278:	b7ed                	j	80004262 <itrunc+0x72>
    brelse(bp);
    8000427a:	8552                	mv	a0,s4
    8000427c:	fffff097          	auipc	ra,0xfffff
    80004280:	784080e7          	jalr	1924(ra) # 80003a00 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004284:	0809a583          	lw	a1,128(s3)
    80004288:	0009a503          	lw	a0,0(s3)
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	884080e7          	jalr	-1916(ra) # 80003b10 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004294:	0809a023          	sw	zero,128(s3)
    80004298:	6a02                	ld	s4,0(sp)
    8000429a:	bf49                	j	8000422c <itrunc+0x3c>

000000008000429c <iput>:
{
    8000429c:	1101                	addi	sp,sp,-32
    8000429e:	ec06                	sd	ra,24(sp)
    800042a0:	e822                	sd	s0,16(sp)
    800042a2:	e426                	sd	s1,8(sp)
    800042a4:	1000                	addi	s0,sp,32
    800042a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800042a8:	00023517          	auipc	a0,0x23
    800042ac:	ff050513          	addi	a0,a0,-16 # 80027298 <itable>
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	98e080e7          	jalr	-1650(ra) # 80000c3e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042b8:	4498                	lw	a4,8(s1)
    800042ba:	4785                	li	a5,1
    800042bc:	02f70263          	beq	a4,a5,800042e0 <iput+0x44>
  ip->ref--;
    800042c0:	449c                	lw	a5,8(s1)
    800042c2:	37fd                	addiw	a5,a5,-1
    800042c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800042c6:	00023517          	auipc	a0,0x23
    800042ca:	fd250513          	addi	a0,a0,-46 # 80027298 <itable>
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	a20080e7          	jalr	-1504(ra) # 80000cee <release>
}
    800042d6:	60e2                	ld	ra,24(sp)
    800042d8:	6442                	ld	s0,16(sp)
    800042da:	64a2                	ld	s1,8(sp)
    800042dc:	6105                	addi	sp,sp,32
    800042de:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042e0:	40bc                	lw	a5,64(s1)
    800042e2:	dff9                	beqz	a5,800042c0 <iput+0x24>
    800042e4:	04a49783          	lh	a5,74(s1)
    800042e8:	ffe1                	bnez	a5,800042c0 <iput+0x24>
    800042ea:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800042ec:	01048913          	addi	s2,s1,16
    800042f0:	854a                	mv	a0,s2
    800042f2:	00001097          	auipc	ra,0x1
    800042f6:	ad2080e7          	jalr	-1326(ra) # 80004dc4 <acquiresleep>
    release(&itable.lock);
    800042fa:	00023517          	auipc	a0,0x23
    800042fe:	f9e50513          	addi	a0,a0,-98 # 80027298 <itable>
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	9ec080e7          	jalr	-1556(ra) # 80000cee <release>
    itrunc(ip);
    8000430a:	8526                	mv	a0,s1
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	ee4080e7          	jalr	-284(ra) # 800041f0 <itrunc>
    ip->type = 0;
    80004314:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004318:	8526                	mv	a0,s1
    8000431a:	00000097          	auipc	ra,0x0
    8000431e:	cf8080e7          	jalr	-776(ra) # 80004012 <iupdate>
    ip->valid = 0;
    80004322:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004326:	854a                	mv	a0,s2
    80004328:	00001097          	auipc	ra,0x1
    8000432c:	af2080e7          	jalr	-1294(ra) # 80004e1a <releasesleep>
    acquire(&itable.lock);
    80004330:	00023517          	auipc	a0,0x23
    80004334:	f6850513          	addi	a0,a0,-152 # 80027298 <itable>
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	906080e7          	jalr	-1786(ra) # 80000c3e <acquire>
    80004340:	6902                	ld	s2,0(sp)
    80004342:	bfbd                	j	800042c0 <iput+0x24>

0000000080004344 <iunlockput>:
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	1000                	addi	s0,sp,32
    8000434e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004350:	00000097          	auipc	ra,0x0
    80004354:	e54080e7          	jalr	-428(ra) # 800041a4 <iunlock>
  iput(ip);
    80004358:	8526                	mv	a0,s1
    8000435a:	00000097          	auipc	ra,0x0
    8000435e:	f42080e7          	jalr	-190(ra) # 8000429c <iput>
}
    80004362:	60e2                	ld	ra,24(sp)
    80004364:	6442                	ld	s0,16(sp)
    80004366:	64a2                	ld	s1,8(sp)
    80004368:	6105                	addi	sp,sp,32
    8000436a:	8082                	ret

000000008000436c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000436c:	1141                	addi	sp,sp,-16
    8000436e:	e406                	sd	ra,8(sp)
    80004370:	e022                	sd	s0,0(sp)
    80004372:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004374:	411c                	lw	a5,0(a0)
    80004376:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004378:	415c                	lw	a5,4(a0)
    8000437a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000437c:	04451783          	lh	a5,68(a0)
    80004380:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004384:	04a51783          	lh	a5,74(a0)
    80004388:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000438c:	04c56783          	lwu	a5,76(a0)
    80004390:	e99c                	sd	a5,16(a1)
}
    80004392:	60a2                	ld	ra,8(sp)
    80004394:	6402                	ld	s0,0(sp)
    80004396:	0141                	addi	sp,sp,16
    80004398:	8082                	ret

000000008000439a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000439a:	457c                	lw	a5,76(a0)
    8000439c:	10d7e063          	bltu	a5,a3,8000449c <readi+0x102>
{
    800043a0:	7159                	addi	sp,sp,-112
    800043a2:	f486                	sd	ra,104(sp)
    800043a4:	f0a2                	sd	s0,96(sp)
    800043a6:	eca6                	sd	s1,88(sp)
    800043a8:	e0d2                	sd	s4,64(sp)
    800043aa:	fc56                	sd	s5,56(sp)
    800043ac:	f85a                	sd	s6,48(sp)
    800043ae:	f45e                	sd	s7,40(sp)
    800043b0:	1880                	addi	s0,sp,112
    800043b2:	8b2a                	mv	s6,a0
    800043b4:	8bae                	mv	s7,a1
    800043b6:	8a32                	mv	s4,a2
    800043b8:	84b6                	mv	s1,a3
    800043ba:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800043bc:	9f35                	addw	a4,a4,a3
    return 0;
    800043be:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800043c0:	0cd76563          	bltu	a4,a3,8000448a <readi+0xf0>
    800043c4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800043c6:	00e7f463          	bgeu	a5,a4,800043ce <readi+0x34>
    n = ip->size - off;
    800043ca:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043ce:	0a0a8563          	beqz	s5,80004478 <readi+0xde>
    800043d2:	e8ca                	sd	s2,80(sp)
    800043d4:	f062                	sd	s8,32(sp)
    800043d6:	ec66                	sd	s9,24(sp)
    800043d8:	e86a                	sd	s10,16(sp)
    800043da:	e46e                	sd	s11,8(sp)
    800043dc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800043de:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800043e2:	5c7d                	li	s8,-1
    800043e4:	a82d                	j	8000441e <readi+0x84>
    800043e6:	020d1d93          	slli	s11,s10,0x20
    800043ea:	020ddd93          	srli	s11,s11,0x20
    800043ee:	05890613          	addi	a2,s2,88
    800043f2:	86ee                	mv	a3,s11
    800043f4:	963e                	add	a2,a2,a5
    800043f6:	85d2                	mv	a1,s4
    800043f8:	855e                	mv	a0,s7
    800043fa:	ffffe097          	auipc	ra,0xffffe
    800043fe:	704080e7          	jalr	1796(ra) # 80002afe <either_copyout>
    80004402:	05850963          	beq	a0,s8,80004454 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004406:	854a                	mv	a0,s2
    80004408:	fffff097          	auipc	ra,0xfffff
    8000440c:	5f8080e7          	jalr	1528(ra) # 80003a00 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004410:	013d09bb          	addw	s3,s10,s3
    80004414:	009d04bb          	addw	s1,s10,s1
    80004418:	9a6e                	add	s4,s4,s11
    8000441a:	0559f963          	bgeu	s3,s5,8000446c <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    8000441e:	00a4d59b          	srliw	a1,s1,0xa
    80004422:	855a                	mv	a0,s6
    80004424:	00000097          	auipc	ra,0x0
    80004428:	89e080e7          	jalr	-1890(ra) # 80003cc2 <bmap>
    8000442c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000442e:	c539                	beqz	a0,8000447c <readi+0xe2>
    bp = bread(ip->dev, addr);
    80004430:	000b2503          	lw	a0,0(s6)
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	49c080e7          	jalr	1180(ra) # 800038d0 <bread>
    8000443c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000443e:	3ff4f793          	andi	a5,s1,1023
    80004442:	40fc873b          	subw	a4,s9,a5
    80004446:	413a86bb          	subw	a3,s5,s3
    8000444a:	8d3a                	mv	s10,a4
    8000444c:	f8e6fde3          	bgeu	a3,a4,800043e6 <readi+0x4c>
    80004450:	8d36                	mv	s10,a3
    80004452:	bf51                	j	800043e6 <readi+0x4c>
      brelse(bp);
    80004454:	854a                	mv	a0,s2
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	5aa080e7          	jalr	1450(ra) # 80003a00 <brelse>
      tot = -1;
    8000445e:	59fd                	li	s3,-1
      break;
    80004460:	6946                	ld	s2,80(sp)
    80004462:	7c02                	ld	s8,32(sp)
    80004464:	6ce2                	ld	s9,24(sp)
    80004466:	6d42                	ld	s10,16(sp)
    80004468:	6da2                	ld	s11,8(sp)
    8000446a:	a831                	j	80004486 <readi+0xec>
    8000446c:	6946                	ld	s2,80(sp)
    8000446e:	7c02                	ld	s8,32(sp)
    80004470:	6ce2                	ld	s9,24(sp)
    80004472:	6d42                	ld	s10,16(sp)
    80004474:	6da2                	ld	s11,8(sp)
    80004476:	a801                	j	80004486 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004478:	89d6                	mv	s3,s5
    8000447a:	a031                	j	80004486 <readi+0xec>
    8000447c:	6946                	ld	s2,80(sp)
    8000447e:	7c02                	ld	s8,32(sp)
    80004480:	6ce2                	ld	s9,24(sp)
    80004482:	6d42                	ld	s10,16(sp)
    80004484:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004486:	854e                	mv	a0,s3
    80004488:	69a6                	ld	s3,72(sp)
}
    8000448a:	70a6                	ld	ra,104(sp)
    8000448c:	7406                	ld	s0,96(sp)
    8000448e:	64e6                	ld	s1,88(sp)
    80004490:	6a06                	ld	s4,64(sp)
    80004492:	7ae2                	ld	s5,56(sp)
    80004494:	7b42                	ld	s6,48(sp)
    80004496:	7ba2                	ld	s7,40(sp)
    80004498:	6165                	addi	sp,sp,112
    8000449a:	8082                	ret
    return 0;
    8000449c:	4501                	li	a0,0
}
    8000449e:	8082                	ret

00000000800044a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800044a0:	457c                	lw	a5,76(a0)
    800044a2:	10d7e963          	bltu	a5,a3,800045b4 <writei+0x114>
{
    800044a6:	7159                	addi	sp,sp,-112
    800044a8:	f486                	sd	ra,104(sp)
    800044aa:	f0a2                	sd	s0,96(sp)
    800044ac:	e8ca                	sd	s2,80(sp)
    800044ae:	e0d2                	sd	s4,64(sp)
    800044b0:	fc56                	sd	s5,56(sp)
    800044b2:	f85a                	sd	s6,48(sp)
    800044b4:	f45e                	sd	s7,40(sp)
    800044b6:	1880                	addi	s0,sp,112
    800044b8:	8aaa                	mv	s5,a0
    800044ba:	8bae                	mv	s7,a1
    800044bc:	8a32                	mv	s4,a2
    800044be:	8936                	mv	s2,a3
    800044c0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800044c2:	00e687bb          	addw	a5,a3,a4
    800044c6:	0ed7e963          	bltu	a5,a3,800045b8 <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800044ca:	00043737          	lui	a4,0x43
    800044ce:	0ef76763          	bltu	a4,a5,800045bc <writei+0x11c>
    800044d2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044d4:	0c0b0863          	beqz	s6,800045a4 <writei+0x104>
    800044d8:	eca6                	sd	s1,88(sp)
    800044da:	f062                	sd	s8,32(sp)
    800044dc:	ec66                	sd	s9,24(sp)
    800044de:	e86a                	sd	s10,16(sp)
    800044e0:	e46e                	sd	s11,8(sp)
    800044e2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800044e4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800044e8:	5c7d                	li	s8,-1
    800044ea:	a091                	j	8000452e <writei+0x8e>
    800044ec:	020d1d93          	slli	s11,s10,0x20
    800044f0:	020ddd93          	srli	s11,s11,0x20
    800044f4:	05848513          	addi	a0,s1,88
    800044f8:	86ee                	mv	a3,s11
    800044fa:	8652                	mv	a2,s4
    800044fc:	85de                	mv	a1,s7
    800044fe:	953e                	add	a0,a0,a5
    80004500:	ffffe097          	auipc	ra,0xffffe
    80004504:	656080e7          	jalr	1622(ra) # 80002b56 <either_copyin>
    80004508:	05850e63          	beq	a0,s8,80004564 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000450c:	8526                	mv	a0,s1
    8000450e:	00000097          	auipc	ra,0x0
    80004512:	798080e7          	jalr	1944(ra) # 80004ca6 <log_write>
    brelse(bp);
    80004516:	8526                	mv	a0,s1
    80004518:	fffff097          	auipc	ra,0xfffff
    8000451c:	4e8080e7          	jalr	1256(ra) # 80003a00 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004520:	013d09bb          	addw	s3,s10,s3
    80004524:	012d093b          	addw	s2,s10,s2
    80004528:	9a6e                	add	s4,s4,s11
    8000452a:	0569f263          	bgeu	s3,s6,8000456e <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000452e:	00a9559b          	srliw	a1,s2,0xa
    80004532:	8556                	mv	a0,s5
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	78e080e7          	jalr	1934(ra) # 80003cc2 <bmap>
    8000453c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000453e:	c905                	beqz	a0,8000456e <writei+0xce>
    bp = bread(ip->dev, addr);
    80004540:	000aa503          	lw	a0,0(s5)
    80004544:	fffff097          	auipc	ra,0xfffff
    80004548:	38c080e7          	jalr	908(ra) # 800038d0 <bread>
    8000454c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000454e:	3ff97793          	andi	a5,s2,1023
    80004552:	40fc873b          	subw	a4,s9,a5
    80004556:	413b06bb          	subw	a3,s6,s3
    8000455a:	8d3a                	mv	s10,a4
    8000455c:	f8e6f8e3          	bgeu	a3,a4,800044ec <writei+0x4c>
    80004560:	8d36                	mv	s10,a3
    80004562:	b769                	j	800044ec <writei+0x4c>
      brelse(bp);
    80004564:	8526                	mv	a0,s1
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	49a080e7          	jalr	1178(ra) # 80003a00 <brelse>
  }

  if(off > ip->size)
    8000456e:	04caa783          	lw	a5,76(s5)
    80004572:	0327fb63          	bgeu	a5,s2,800045a8 <writei+0x108>
    ip->size = off;
    80004576:	052aa623          	sw	s2,76(s5)
    8000457a:	64e6                	ld	s1,88(sp)
    8000457c:	7c02                	ld	s8,32(sp)
    8000457e:	6ce2                	ld	s9,24(sp)
    80004580:	6d42                	ld	s10,16(sp)
    80004582:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004584:	8556                	mv	a0,s5
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	a8c080e7          	jalr	-1396(ra) # 80004012 <iupdate>

  return tot;
    8000458e:	854e                	mv	a0,s3
    80004590:	69a6                	ld	s3,72(sp)
}
    80004592:	70a6                	ld	ra,104(sp)
    80004594:	7406                	ld	s0,96(sp)
    80004596:	6946                	ld	s2,80(sp)
    80004598:	6a06                	ld	s4,64(sp)
    8000459a:	7ae2                	ld	s5,56(sp)
    8000459c:	7b42                	ld	s6,48(sp)
    8000459e:	7ba2                	ld	s7,40(sp)
    800045a0:	6165                	addi	sp,sp,112
    800045a2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045a4:	89da                	mv	s3,s6
    800045a6:	bff9                	j	80004584 <writei+0xe4>
    800045a8:	64e6                	ld	s1,88(sp)
    800045aa:	7c02                	ld	s8,32(sp)
    800045ac:	6ce2                	ld	s9,24(sp)
    800045ae:	6d42                	ld	s10,16(sp)
    800045b0:	6da2                	ld	s11,8(sp)
    800045b2:	bfc9                	j	80004584 <writei+0xe4>
    return -1;
    800045b4:	557d                	li	a0,-1
}
    800045b6:	8082                	ret
    return -1;
    800045b8:	557d                	li	a0,-1
    800045ba:	bfe1                	j	80004592 <writei+0xf2>
    return -1;
    800045bc:	557d                	li	a0,-1
    800045be:	bfd1                	j	80004592 <writei+0xf2>

00000000800045c0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800045c0:	1141                	addi	sp,sp,-16
    800045c2:	e406                	sd	ra,8(sp)
    800045c4:	e022                	sd	s0,0(sp)
    800045c6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800045c8:	4639                	li	a2,14
    800045ca:	ffffd097          	auipc	ra,0xffffd
    800045ce:	848080e7          	jalr	-1976(ra) # 80000e12 <strncmp>
}
    800045d2:	60a2                	ld	ra,8(sp)
    800045d4:	6402                	ld	s0,0(sp)
    800045d6:	0141                	addi	sp,sp,16
    800045d8:	8082                	ret

00000000800045da <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800045da:	711d                	addi	sp,sp,-96
    800045dc:	ec86                	sd	ra,88(sp)
    800045de:	e8a2                	sd	s0,80(sp)
    800045e0:	e4a6                	sd	s1,72(sp)
    800045e2:	e0ca                	sd	s2,64(sp)
    800045e4:	fc4e                	sd	s3,56(sp)
    800045e6:	f852                	sd	s4,48(sp)
    800045e8:	f456                	sd	s5,40(sp)
    800045ea:	f05a                	sd	s6,32(sp)
    800045ec:	ec5e                	sd	s7,24(sp)
    800045ee:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800045f0:	04451703          	lh	a4,68(a0)
    800045f4:	4785                	li	a5,1
    800045f6:	00f71f63          	bne	a4,a5,80004614 <dirlookup+0x3a>
    800045fa:	892a                	mv	s2,a0
    800045fc:	8aae                	mv	s5,a1
    800045fe:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004600:	457c                	lw	a5,76(a0)
    80004602:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004604:	fa040a13          	addi	s4,s0,-96
    80004608:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000460a:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000460e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004610:	e79d                	bnez	a5,8000463e <dirlookup+0x64>
    80004612:	a88d                	j	80004684 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80004614:	00004517          	auipc	a0,0x4
    80004618:	ec450513          	addi	a0,a0,-316 # 800084d8 <etext+0x4d8>
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	f44080e7          	jalr	-188(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004624:	00004517          	auipc	a0,0x4
    80004628:	ecc50513          	addi	a0,a0,-308 # 800084f0 <etext+0x4f0>
    8000462c:	ffffc097          	auipc	ra,0xffffc
    80004630:	f34080e7          	jalr	-204(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004634:	24c1                	addiw	s1,s1,16
    80004636:	04c92783          	lw	a5,76(s2)
    8000463a:	04f4f463          	bgeu	s1,a5,80004682 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000463e:	874e                	mv	a4,s3
    80004640:	86a6                	mv	a3,s1
    80004642:	8652                	mv	a2,s4
    80004644:	4581                	li	a1,0
    80004646:	854a                	mv	a0,s2
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	d52080e7          	jalr	-686(ra) # 8000439a <readi>
    80004650:	fd351ae3          	bne	a0,s3,80004624 <dirlookup+0x4a>
    if(de.inum == 0)
    80004654:	fa045783          	lhu	a5,-96(s0)
    80004658:	dff1                	beqz	a5,80004634 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    8000465a:	85da                	mv	a1,s6
    8000465c:	8556                	mv	a0,s5
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	f62080e7          	jalr	-158(ra) # 800045c0 <namecmp>
    80004666:	f579                	bnez	a0,80004634 <dirlookup+0x5a>
      if(poff)
    80004668:	000b8463          	beqz	s7,80004670 <dirlookup+0x96>
        *poff = off;
    8000466c:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80004670:	fa045583          	lhu	a1,-96(s0)
    80004674:	00092503          	lw	a0,0(s2)
    80004678:	fffff097          	auipc	ra,0xfffff
    8000467c:	726080e7          	jalr	1830(ra) # 80003d9e <iget>
    80004680:	a011                	j	80004684 <dirlookup+0xaa>
  return 0;
    80004682:	4501                	li	a0,0
}
    80004684:	60e6                	ld	ra,88(sp)
    80004686:	6446                	ld	s0,80(sp)
    80004688:	64a6                	ld	s1,72(sp)
    8000468a:	6906                	ld	s2,64(sp)
    8000468c:	79e2                	ld	s3,56(sp)
    8000468e:	7a42                	ld	s4,48(sp)
    80004690:	7aa2                	ld	s5,40(sp)
    80004692:	7b02                	ld	s6,32(sp)
    80004694:	6be2                	ld	s7,24(sp)
    80004696:	6125                	addi	sp,sp,96
    80004698:	8082                	ret

000000008000469a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000469a:	711d                	addi	sp,sp,-96
    8000469c:	ec86                	sd	ra,88(sp)
    8000469e:	e8a2                	sd	s0,80(sp)
    800046a0:	e4a6                	sd	s1,72(sp)
    800046a2:	e0ca                	sd	s2,64(sp)
    800046a4:	fc4e                	sd	s3,56(sp)
    800046a6:	f852                	sd	s4,48(sp)
    800046a8:	f456                	sd	s5,40(sp)
    800046aa:	f05a                	sd	s6,32(sp)
    800046ac:	ec5e                	sd	s7,24(sp)
    800046ae:	e862                	sd	s8,16(sp)
    800046b0:	e466                	sd	s9,8(sp)
    800046b2:	e06a                	sd	s10,0(sp)
    800046b4:	1080                	addi	s0,sp,96
    800046b6:	84aa                	mv	s1,a0
    800046b8:	8b2e                	mv	s6,a1
    800046ba:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800046bc:	00054703          	lbu	a4,0(a0)
    800046c0:	02f00793          	li	a5,47
    800046c4:	02f70363          	beq	a4,a5,800046ea <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800046c8:	ffffd097          	auipc	ra,0xffffd
    800046cc:	52e080e7          	jalr	1326(ra) # 80001bf6 <myproc>
    800046d0:	32853503          	ld	a0,808(a0)
    800046d4:	00000097          	auipc	ra,0x0
    800046d8:	9cc080e7          	jalr	-1588(ra) # 800040a0 <idup>
    800046dc:	8a2a                	mv	s4,a0
  while(*path == '/')
    800046de:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800046e2:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800046e4:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800046e6:	4b85                	li	s7,1
    800046e8:	a87d                	j	800047a6 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800046ea:	4585                	li	a1,1
    800046ec:	852e                	mv	a0,a1
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	6b0080e7          	jalr	1712(ra) # 80003d9e <iget>
    800046f6:	8a2a                	mv	s4,a0
    800046f8:	b7dd                	j	800046de <namex+0x44>
      iunlockput(ip);
    800046fa:	8552                	mv	a0,s4
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	c48080e7          	jalr	-952(ra) # 80004344 <iunlockput>
      return 0;
    80004704:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004706:	8552                	mv	a0,s4
    80004708:	60e6                	ld	ra,88(sp)
    8000470a:	6446                	ld	s0,80(sp)
    8000470c:	64a6                	ld	s1,72(sp)
    8000470e:	6906                	ld	s2,64(sp)
    80004710:	79e2                	ld	s3,56(sp)
    80004712:	7a42                	ld	s4,48(sp)
    80004714:	7aa2                	ld	s5,40(sp)
    80004716:	7b02                	ld	s6,32(sp)
    80004718:	6be2                	ld	s7,24(sp)
    8000471a:	6c42                	ld	s8,16(sp)
    8000471c:	6ca2                	ld	s9,8(sp)
    8000471e:	6d02                	ld	s10,0(sp)
    80004720:	6125                	addi	sp,sp,96
    80004722:	8082                	ret
      iunlock(ip);
    80004724:	8552                	mv	a0,s4
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	a7e080e7          	jalr	-1410(ra) # 800041a4 <iunlock>
      return ip;
    8000472e:	bfe1                	j	80004706 <namex+0x6c>
      iunlockput(ip);
    80004730:	8552                	mv	a0,s4
    80004732:	00000097          	auipc	ra,0x0
    80004736:	c12080e7          	jalr	-1006(ra) # 80004344 <iunlockput>
      return 0;
    8000473a:	8a4e                	mv	s4,s3
    8000473c:	b7e9                	j	80004706 <namex+0x6c>
  len = path - s;
    8000473e:	40998633          	sub	a2,s3,s1
    80004742:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004746:	09ac5863          	bge	s8,s10,800047d6 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000474a:	8666                	mv	a2,s9
    8000474c:	85a6                	mv	a1,s1
    8000474e:	8556                	mv	a0,s5
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	64a080e7          	jalr	1610(ra) # 80000d9a <memmove>
    80004758:	84ce                	mv	s1,s3
  while(*path == '/')
    8000475a:	0004c783          	lbu	a5,0(s1)
    8000475e:	01279763          	bne	a5,s2,8000476c <namex+0xd2>
    path++;
    80004762:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004764:	0004c783          	lbu	a5,0(s1)
    80004768:	ff278de3          	beq	a5,s2,80004762 <namex+0xc8>
    ilock(ip);
    8000476c:	8552                	mv	a0,s4
    8000476e:	00000097          	auipc	ra,0x0
    80004772:	970080e7          	jalr	-1680(ra) # 800040de <ilock>
    if(ip->type != T_DIR){
    80004776:	044a1783          	lh	a5,68(s4)
    8000477a:	f97790e3          	bne	a5,s7,800046fa <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000477e:	000b0563          	beqz	s6,80004788 <namex+0xee>
    80004782:	0004c783          	lbu	a5,0(s1)
    80004786:	dfd9                	beqz	a5,80004724 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004788:	4601                	li	a2,0
    8000478a:	85d6                	mv	a1,s5
    8000478c:	8552                	mv	a0,s4
    8000478e:	00000097          	auipc	ra,0x0
    80004792:	e4c080e7          	jalr	-436(ra) # 800045da <dirlookup>
    80004796:	89aa                	mv	s3,a0
    80004798:	dd41                	beqz	a0,80004730 <namex+0x96>
    iunlockput(ip);
    8000479a:	8552                	mv	a0,s4
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	ba8080e7          	jalr	-1112(ra) # 80004344 <iunlockput>
    ip = next;
    800047a4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800047a6:	0004c783          	lbu	a5,0(s1)
    800047aa:	01279763          	bne	a5,s2,800047b8 <namex+0x11e>
    path++;
    800047ae:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047b0:	0004c783          	lbu	a5,0(s1)
    800047b4:	ff278de3          	beq	a5,s2,800047ae <namex+0x114>
  if(*path == 0)
    800047b8:	cb9d                	beqz	a5,800047ee <namex+0x154>
  while(*path != '/' && *path != 0)
    800047ba:	0004c783          	lbu	a5,0(s1)
    800047be:	89a6                	mv	s3,s1
  len = path - s;
    800047c0:	4d01                	li	s10,0
    800047c2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800047c4:	01278963          	beq	a5,s2,800047d6 <namex+0x13c>
    800047c8:	dbbd                	beqz	a5,8000473e <namex+0xa4>
    path++;
    800047ca:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800047cc:	0009c783          	lbu	a5,0(s3)
    800047d0:	ff279ce3          	bne	a5,s2,800047c8 <namex+0x12e>
    800047d4:	b7ad                	j	8000473e <namex+0xa4>
    memmove(name, s, len);
    800047d6:	2601                	sext.w	a2,a2
    800047d8:	85a6                	mv	a1,s1
    800047da:	8556                	mv	a0,s5
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	5be080e7          	jalr	1470(ra) # 80000d9a <memmove>
    name[len] = 0;
    800047e4:	9d56                	add	s10,s10,s5
    800047e6:	000d0023          	sb	zero,0(s10)
    800047ea:	84ce                	mv	s1,s3
    800047ec:	b7bd                	j	8000475a <namex+0xc0>
  if(nameiparent){
    800047ee:	f00b0ce3          	beqz	s6,80004706 <namex+0x6c>
    iput(ip);
    800047f2:	8552                	mv	a0,s4
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	aa8080e7          	jalr	-1368(ra) # 8000429c <iput>
    return 0;
    800047fc:	4a01                	li	s4,0
    800047fe:	b721                	j	80004706 <namex+0x6c>

0000000080004800 <dirlink>:
{
    80004800:	715d                	addi	sp,sp,-80
    80004802:	e486                	sd	ra,72(sp)
    80004804:	e0a2                	sd	s0,64(sp)
    80004806:	f84a                	sd	s2,48(sp)
    80004808:	ec56                	sd	s5,24(sp)
    8000480a:	e85a                	sd	s6,16(sp)
    8000480c:	0880                	addi	s0,sp,80
    8000480e:	892a                	mv	s2,a0
    80004810:	8aae                	mv	s5,a1
    80004812:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004814:	4601                	li	a2,0
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	dc4080e7          	jalr	-572(ra) # 800045da <dirlookup>
    8000481e:	e129                	bnez	a0,80004860 <dirlink+0x60>
    80004820:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004822:	04c92483          	lw	s1,76(s2)
    80004826:	cca9                	beqz	s1,80004880 <dirlink+0x80>
    80004828:	f44e                	sd	s3,40(sp)
    8000482a:	f052                	sd	s4,32(sp)
    8000482c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000482e:	fb040a13          	addi	s4,s0,-80
    80004832:	49c1                	li	s3,16
    80004834:	874e                	mv	a4,s3
    80004836:	86a6                	mv	a3,s1
    80004838:	8652                	mv	a2,s4
    8000483a:	4581                	li	a1,0
    8000483c:	854a                	mv	a0,s2
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	b5c080e7          	jalr	-1188(ra) # 8000439a <readi>
    80004846:	03351363          	bne	a0,s3,8000486c <dirlink+0x6c>
    if(de.inum == 0)
    8000484a:	fb045783          	lhu	a5,-80(s0)
    8000484e:	c79d                	beqz	a5,8000487c <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004850:	24c1                	addiw	s1,s1,16
    80004852:	04c92783          	lw	a5,76(s2)
    80004856:	fcf4efe3          	bltu	s1,a5,80004834 <dirlink+0x34>
    8000485a:	79a2                	ld	s3,40(sp)
    8000485c:	7a02                	ld	s4,32(sp)
    8000485e:	a00d                	j	80004880 <dirlink+0x80>
    iput(ip);
    80004860:	00000097          	auipc	ra,0x0
    80004864:	a3c080e7          	jalr	-1476(ra) # 8000429c <iput>
    return -1;
    80004868:	557d                	li	a0,-1
    8000486a:	a0a9                	j	800048b4 <dirlink+0xb4>
      panic("dirlink read");
    8000486c:	00004517          	auipc	a0,0x4
    80004870:	c9450513          	addi	a0,a0,-876 # 80008500 <etext+0x500>
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	cec080e7          	jalr	-788(ra) # 80000560 <panic>
    8000487c:	79a2                	ld	s3,40(sp)
    8000487e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004880:	4639                	li	a2,14
    80004882:	85d6                	mv	a1,s5
    80004884:	fb240513          	addi	a0,s0,-78
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	5c4080e7          	jalr	1476(ra) # 80000e4c <strncpy>
  de.inum = inum;
    80004890:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004894:	4741                	li	a4,16
    80004896:	86a6                	mv	a3,s1
    80004898:	fb040613          	addi	a2,s0,-80
    8000489c:	4581                	li	a1,0
    8000489e:	854a                	mv	a0,s2
    800048a0:	00000097          	auipc	ra,0x0
    800048a4:	c00080e7          	jalr	-1024(ra) # 800044a0 <writei>
    800048a8:	1541                	addi	a0,a0,-16
    800048aa:	00a03533          	snez	a0,a0
    800048ae:	40a0053b          	negw	a0,a0
    800048b2:	74e2                	ld	s1,56(sp)
}
    800048b4:	60a6                	ld	ra,72(sp)
    800048b6:	6406                	ld	s0,64(sp)
    800048b8:	7942                	ld	s2,48(sp)
    800048ba:	6ae2                	ld	s5,24(sp)
    800048bc:	6b42                	ld	s6,16(sp)
    800048be:	6161                	addi	sp,sp,80
    800048c0:	8082                	ret

00000000800048c2 <namei>:

struct inode*
namei(char *path)
{
    800048c2:	1101                	addi	sp,sp,-32
    800048c4:	ec06                	sd	ra,24(sp)
    800048c6:	e822                	sd	s0,16(sp)
    800048c8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800048ca:	fe040613          	addi	a2,s0,-32
    800048ce:	4581                	li	a1,0
    800048d0:	00000097          	auipc	ra,0x0
    800048d4:	dca080e7          	jalr	-566(ra) # 8000469a <namex>
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	6105                	addi	sp,sp,32
    800048de:	8082                	ret

00000000800048e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800048e0:	1141                	addi	sp,sp,-16
    800048e2:	e406                	sd	ra,8(sp)
    800048e4:	e022                	sd	s0,0(sp)
    800048e6:	0800                	addi	s0,sp,16
    800048e8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800048ea:	4585                	li	a1,1
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	dae080e7          	jalr	-594(ra) # 8000469a <namex>
}
    800048f4:	60a2                	ld	ra,8(sp)
    800048f6:	6402                	ld	s0,0(sp)
    800048f8:	0141                	addi	sp,sp,16
    800048fa:	8082                	ret

00000000800048fc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800048fc:	1101                	addi	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	e04a                	sd	s2,0(sp)
    80004906:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004908:	00024917          	auipc	s2,0x24
    8000490c:	43890913          	addi	s2,s2,1080 # 80028d40 <log>
    80004910:	01892583          	lw	a1,24(s2)
    80004914:	02892503          	lw	a0,40(s2)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	fb8080e7          	jalr	-72(ra) # 800038d0 <bread>
    80004920:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004922:	02c92603          	lw	a2,44(s2)
    80004926:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004928:	00c05f63          	blez	a2,80004946 <write_head+0x4a>
    8000492c:	00024717          	auipc	a4,0x24
    80004930:	44470713          	addi	a4,a4,1092 # 80028d70 <log+0x30>
    80004934:	87aa                	mv	a5,a0
    80004936:	060a                	slli	a2,a2,0x2
    80004938:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000493a:	4314                	lw	a3,0(a4)
    8000493c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000493e:	0711                	addi	a4,a4,4
    80004940:	0791                	addi	a5,a5,4
    80004942:	fec79ce3          	bne	a5,a2,8000493a <write_head+0x3e>
  }
  bwrite(buf);
    80004946:	8526                	mv	a0,s1
    80004948:	fffff097          	auipc	ra,0xfffff
    8000494c:	07a080e7          	jalr	122(ra) # 800039c2 <bwrite>
  brelse(buf);
    80004950:	8526                	mv	a0,s1
    80004952:	fffff097          	auipc	ra,0xfffff
    80004956:	0ae080e7          	jalr	174(ra) # 80003a00 <brelse>
}
    8000495a:	60e2                	ld	ra,24(sp)
    8000495c:	6442                	ld	s0,16(sp)
    8000495e:	64a2                	ld	s1,8(sp)
    80004960:	6902                	ld	s2,0(sp)
    80004962:	6105                	addi	sp,sp,32
    80004964:	8082                	ret

0000000080004966 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004966:	00024797          	auipc	a5,0x24
    8000496a:	4067a783          	lw	a5,1030(a5) # 80028d6c <log+0x2c>
    8000496e:	0cf05063          	blez	a5,80004a2e <install_trans+0xc8>
{
    80004972:	715d                	addi	sp,sp,-80
    80004974:	e486                	sd	ra,72(sp)
    80004976:	e0a2                	sd	s0,64(sp)
    80004978:	fc26                	sd	s1,56(sp)
    8000497a:	f84a                	sd	s2,48(sp)
    8000497c:	f44e                	sd	s3,40(sp)
    8000497e:	f052                	sd	s4,32(sp)
    80004980:	ec56                	sd	s5,24(sp)
    80004982:	e85a                	sd	s6,16(sp)
    80004984:	e45e                	sd	s7,8(sp)
    80004986:	0880                	addi	s0,sp,80
    80004988:	8b2a                	mv	s6,a0
    8000498a:	00024a97          	auipc	s5,0x24
    8000498e:	3e6a8a93          	addi	s5,s5,998 # 80028d70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004992:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004994:	00024997          	auipc	s3,0x24
    80004998:	3ac98993          	addi	s3,s3,940 # 80028d40 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000499c:	40000b93          	li	s7,1024
    800049a0:	a00d                	j	800049c2 <install_trans+0x5c>
    brelse(lbuf);
    800049a2:	854a                	mv	a0,s2
    800049a4:	fffff097          	auipc	ra,0xfffff
    800049a8:	05c080e7          	jalr	92(ra) # 80003a00 <brelse>
    brelse(dbuf);
    800049ac:	8526                	mv	a0,s1
    800049ae:	fffff097          	auipc	ra,0xfffff
    800049b2:	052080e7          	jalr	82(ra) # 80003a00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049b6:	2a05                	addiw	s4,s4,1
    800049b8:	0a91                	addi	s5,s5,4
    800049ba:	02c9a783          	lw	a5,44(s3)
    800049be:	04fa5d63          	bge	s4,a5,80004a18 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049c2:	0189a583          	lw	a1,24(s3)
    800049c6:	014585bb          	addw	a1,a1,s4
    800049ca:	2585                	addiw	a1,a1,1
    800049cc:	0289a503          	lw	a0,40(s3)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	f00080e7          	jalr	-256(ra) # 800038d0 <bread>
    800049d8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800049da:	000aa583          	lw	a1,0(s5)
    800049de:	0289a503          	lw	a0,40(s3)
    800049e2:	fffff097          	auipc	ra,0xfffff
    800049e6:	eee080e7          	jalr	-274(ra) # 800038d0 <bread>
    800049ea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800049ec:	865e                	mv	a2,s7
    800049ee:	05890593          	addi	a1,s2,88
    800049f2:	05850513          	addi	a0,a0,88
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	3a4080e7          	jalr	932(ra) # 80000d9a <memmove>
    bwrite(dbuf);  // write dst to disk
    800049fe:	8526                	mv	a0,s1
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	fc2080e7          	jalr	-62(ra) # 800039c2 <bwrite>
    if(recovering == 0)
    80004a08:	f80b1de3          	bnez	s6,800049a2 <install_trans+0x3c>
      bunpin(dbuf);
    80004a0c:	8526                	mv	a0,s1
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	0c6080e7          	jalr	198(ra) # 80003ad4 <bunpin>
    80004a16:	b771                	j	800049a2 <install_trans+0x3c>
}
    80004a18:	60a6                	ld	ra,72(sp)
    80004a1a:	6406                	ld	s0,64(sp)
    80004a1c:	74e2                	ld	s1,56(sp)
    80004a1e:	7942                	ld	s2,48(sp)
    80004a20:	79a2                	ld	s3,40(sp)
    80004a22:	7a02                	ld	s4,32(sp)
    80004a24:	6ae2                	ld	s5,24(sp)
    80004a26:	6b42                	ld	s6,16(sp)
    80004a28:	6ba2                	ld	s7,8(sp)
    80004a2a:	6161                	addi	sp,sp,80
    80004a2c:	8082                	ret
    80004a2e:	8082                	ret

0000000080004a30 <initlog>:
{
    80004a30:	7179                	addi	sp,sp,-48
    80004a32:	f406                	sd	ra,40(sp)
    80004a34:	f022                	sd	s0,32(sp)
    80004a36:	ec26                	sd	s1,24(sp)
    80004a38:	e84a                	sd	s2,16(sp)
    80004a3a:	e44e                	sd	s3,8(sp)
    80004a3c:	1800                	addi	s0,sp,48
    80004a3e:	892a                	mv	s2,a0
    80004a40:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004a42:	00024497          	auipc	s1,0x24
    80004a46:	2fe48493          	addi	s1,s1,766 # 80028d40 <log>
    80004a4a:	00004597          	auipc	a1,0x4
    80004a4e:	ac658593          	addi	a1,a1,-1338 # 80008510 <etext+0x510>
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	156080e7          	jalr	342(ra) # 80000baa <initlock>
  log.start = sb->logstart;
    80004a5c:	0149a583          	lw	a1,20(s3)
    80004a60:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004a62:	0109a783          	lw	a5,16(s3)
    80004a66:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004a68:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004a6c:	854a                	mv	a0,s2
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	e62080e7          	jalr	-414(ra) # 800038d0 <bread>
  log.lh.n = lh->n;
    80004a76:	4d30                	lw	a2,88(a0)
    80004a78:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a7a:	00c05f63          	blez	a2,80004a98 <initlog+0x68>
    80004a7e:	87aa                	mv	a5,a0
    80004a80:	00024717          	auipc	a4,0x24
    80004a84:	2f070713          	addi	a4,a4,752 # 80028d70 <log+0x30>
    80004a88:	060a                	slli	a2,a2,0x2
    80004a8a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004a8c:	4ff4                	lw	a3,92(a5)
    80004a8e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004a90:	0791                	addi	a5,a5,4
    80004a92:	0711                	addi	a4,a4,4
    80004a94:	fec79ce3          	bne	a5,a2,80004a8c <initlog+0x5c>
  brelse(buf);
    80004a98:	fffff097          	auipc	ra,0xfffff
    80004a9c:	f68080e7          	jalr	-152(ra) # 80003a00 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004aa0:	4505                	li	a0,1
    80004aa2:	00000097          	auipc	ra,0x0
    80004aa6:	ec4080e7          	jalr	-316(ra) # 80004966 <install_trans>
  log.lh.n = 0;
    80004aaa:	00024797          	auipc	a5,0x24
    80004aae:	2c07a123          	sw	zero,706(a5) # 80028d6c <log+0x2c>
  write_head(); // clear the log
    80004ab2:	00000097          	auipc	ra,0x0
    80004ab6:	e4a080e7          	jalr	-438(ra) # 800048fc <write_head>
}
    80004aba:	70a2                	ld	ra,40(sp)
    80004abc:	7402                	ld	s0,32(sp)
    80004abe:	64e2                	ld	s1,24(sp)
    80004ac0:	6942                	ld	s2,16(sp)
    80004ac2:	69a2                	ld	s3,8(sp)
    80004ac4:	6145                	addi	sp,sp,48
    80004ac6:	8082                	ret

0000000080004ac8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004ac8:	1101                	addi	sp,sp,-32
    80004aca:	ec06                	sd	ra,24(sp)
    80004acc:	e822                	sd	s0,16(sp)
    80004ace:	e426                	sd	s1,8(sp)
    80004ad0:	e04a                	sd	s2,0(sp)
    80004ad2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004ad4:	00024517          	auipc	a0,0x24
    80004ad8:	26c50513          	addi	a0,a0,620 # 80028d40 <log>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	162080e7          	jalr	354(ra) # 80000c3e <acquire>
  while(1){
    if(log.committing){
    80004ae4:	00024497          	auipc	s1,0x24
    80004ae8:	25c48493          	addi	s1,s1,604 # 80028d40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004aec:	4979                	li	s2,30
    80004aee:	a039                	j	80004afc <begin_op+0x34>
      sleep(&log, &log.lock);
    80004af0:	85a6                	mv	a1,s1
    80004af2:	8526                	mv	a0,s1
    80004af4:	ffffe097          	auipc	ra,0xffffe
    80004af8:	bc0080e7          	jalr	-1088(ra) # 800026b4 <sleep>
    if(log.committing){
    80004afc:	50dc                	lw	a5,36(s1)
    80004afe:	fbed                	bnez	a5,80004af0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b00:	5098                	lw	a4,32(s1)
    80004b02:	2705                	addiw	a4,a4,1
    80004b04:	0027179b          	slliw	a5,a4,0x2
    80004b08:	9fb9                	addw	a5,a5,a4
    80004b0a:	0017979b          	slliw	a5,a5,0x1
    80004b0e:	54d4                	lw	a3,44(s1)
    80004b10:	9fb5                	addw	a5,a5,a3
    80004b12:	00f95963          	bge	s2,a5,80004b24 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004b16:	85a6                	mv	a1,s1
    80004b18:	8526                	mv	a0,s1
    80004b1a:	ffffe097          	auipc	ra,0xffffe
    80004b1e:	b9a080e7          	jalr	-1126(ra) # 800026b4 <sleep>
    80004b22:	bfe9                	j	80004afc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004b24:	00024517          	auipc	a0,0x24
    80004b28:	21c50513          	addi	a0,a0,540 # 80028d40 <log>
    80004b2c:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	1c0080e7          	jalr	448(ra) # 80000cee <release>
      break;
    }
  }
}
    80004b36:	60e2                	ld	ra,24(sp)
    80004b38:	6442                	ld	s0,16(sp)
    80004b3a:	64a2                	ld	s1,8(sp)
    80004b3c:	6902                	ld	s2,0(sp)
    80004b3e:	6105                	addi	sp,sp,32
    80004b40:	8082                	ret

0000000080004b42 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004b42:	7139                	addi	sp,sp,-64
    80004b44:	fc06                	sd	ra,56(sp)
    80004b46:	f822                	sd	s0,48(sp)
    80004b48:	f426                	sd	s1,40(sp)
    80004b4a:	f04a                	sd	s2,32(sp)
    80004b4c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b4e:	00024497          	auipc	s1,0x24
    80004b52:	1f248493          	addi	s1,s1,498 # 80028d40 <log>
    80004b56:	8526                	mv	a0,s1
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	0e6080e7          	jalr	230(ra) # 80000c3e <acquire>
  log.outstanding -= 1;
    80004b60:	509c                	lw	a5,32(s1)
    80004b62:	37fd                	addiw	a5,a5,-1
    80004b64:	893e                	mv	s2,a5
    80004b66:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004b68:	50dc                	lw	a5,36(s1)
    80004b6a:	e7b9                	bnez	a5,80004bb8 <end_op+0x76>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b6c:	06091263          	bnez	s2,80004bd0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004b70:	00024497          	auipc	s1,0x24
    80004b74:	1d048493          	addi	s1,s1,464 # 80028d40 <log>
    80004b78:	4785                	li	a5,1
    80004b7a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	170080e7          	jalr	368(ra) # 80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b86:	54dc                	lw	a5,44(s1)
    80004b88:	06f04863          	bgtz	a5,80004bf8 <end_op+0xb6>
    acquire(&log.lock);
    80004b8c:	00024497          	auipc	s1,0x24
    80004b90:	1b448493          	addi	s1,s1,436 # 80028d40 <log>
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	0a8080e7          	jalr	168(ra) # 80000c3e <acquire>
    log.committing = 0;
    80004b9e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004ba2:	8526                	mv	a0,s1
    80004ba4:	ffffe097          	auipc	ra,0xffffe
    80004ba8:	b74080e7          	jalr	-1164(ra) # 80002718 <wakeup>
    release(&log.lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	140080e7          	jalr	320(ra) # 80000cee <release>
}
    80004bb6:	a81d                	j	80004bec <end_op+0xaa>
    80004bb8:	ec4e                	sd	s3,24(sp)
    80004bba:	e852                	sd	s4,16(sp)
    80004bbc:	e456                	sd	s5,8(sp)
    80004bbe:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80004bc0:	00004517          	auipc	a0,0x4
    80004bc4:	95850513          	addi	a0,a0,-1704 # 80008518 <etext+0x518>
    80004bc8:	ffffc097          	auipc	ra,0xffffc
    80004bcc:	998080e7          	jalr	-1640(ra) # 80000560 <panic>
    wakeup(&log);
    80004bd0:	00024497          	auipc	s1,0x24
    80004bd4:	17048493          	addi	s1,s1,368 # 80028d40 <log>
    80004bd8:	8526                	mv	a0,s1
    80004bda:	ffffe097          	auipc	ra,0xffffe
    80004bde:	b3e080e7          	jalr	-1218(ra) # 80002718 <wakeup>
  release(&log.lock);
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	10a080e7          	jalr	266(ra) # 80000cee <release>
}
    80004bec:	70e2                	ld	ra,56(sp)
    80004bee:	7442                	ld	s0,48(sp)
    80004bf0:	74a2                	ld	s1,40(sp)
    80004bf2:	7902                	ld	s2,32(sp)
    80004bf4:	6121                	addi	sp,sp,64
    80004bf6:	8082                	ret
    80004bf8:	ec4e                	sd	s3,24(sp)
    80004bfa:	e852                	sd	s4,16(sp)
    80004bfc:	e456                	sd	s5,8(sp)
    80004bfe:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c00:	00024a97          	auipc	s5,0x24
    80004c04:	170a8a93          	addi	s5,s5,368 # 80028d70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004c08:	00024a17          	auipc	s4,0x24
    80004c0c:	138a0a13          	addi	s4,s4,312 # 80028d40 <log>
    memmove(to->data, from->data, BSIZE);
    80004c10:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004c14:	018a2583          	lw	a1,24(s4)
    80004c18:	012585bb          	addw	a1,a1,s2
    80004c1c:	2585                	addiw	a1,a1,1
    80004c1e:	028a2503          	lw	a0,40(s4)
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	cae080e7          	jalr	-850(ra) # 800038d0 <bread>
    80004c2a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004c2c:	000aa583          	lw	a1,0(s5)
    80004c30:	028a2503          	lw	a0,40(s4)
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	c9c080e7          	jalr	-868(ra) # 800038d0 <bread>
    80004c3c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004c3e:	865a                	mv	a2,s6
    80004c40:	05850593          	addi	a1,a0,88
    80004c44:	05848513          	addi	a0,s1,88
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	152080e7          	jalr	338(ra) # 80000d9a <memmove>
    bwrite(to);  // write the log
    80004c50:	8526                	mv	a0,s1
    80004c52:	fffff097          	auipc	ra,0xfffff
    80004c56:	d70080e7          	jalr	-656(ra) # 800039c2 <bwrite>
    brelse(from);
    80004c5a:	854e                	mv	a0,s3
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	da4080e7          	jalr	-604(ra) # 80003a00 <brelse>
    brelse(to);
    80004c64:	8526                	mv	a0,s1
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	d9a080e7          	jalr	-614(ra) # 80003a00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c6e:	2905                	addiw	s2,s2,1
    80004c70:	0a91                	addi	s5,s5,4
    80004c72:	02ca2783          	lw	a5,44(s4)
    80004c76:	f8f94fe3          	blt	s2,a5,80004c14 <end_op+0xd2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c7a:	00000097          	auipc	ra,0x0
    80004c7e:	c82080e7          	jalr	-894(ra) # 800048fc <write_head>
    install_trans(0); // Now install writes to home locations
    80004c82:	4501                	li	a0,0
    80004c84:	00000097          	auipc	ra,0x0
    80004c88:	ce2080e7          	jalr	-798(ra) # 80004966 <install_trans>
    log.lh.n = 0;
    80004c8c:	00024797          	auipc	a5,0x24
    80004c90:	0e07a023          	sw	zero,224(a5) # 80028d6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004c94:	00000097          	auipc	ra,0x0
    80004c98:	c68080e7          	jalr	-920(ra) # 800048fc <write_head>
    80004c9c:	69e2                	ld	s3,24(sp)
    80004c9e:	6a42                	ld	s4,16(sp)
    80004ca0:	6aa2                	ld	s5,8(sp)
    80004ca2:	6b02                	ld	s6,0(sp)
    80004ca4:	b5e5                	j	80004b8c <end_op+0x4a>

0000000080004ca6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ca6:	1101                	addi	sp,sp,-32
    80004ca8:	ec06                	sd	ra,24(sp)
    80004caa:	e822                	sd	s0,16(sp)
    80004cac:	e426                	sd	s1,8(sp)
    80004cae:	e04a                	sd	s2,0(sp)
    80004cb0:	1000                	addi	s0,sp,32
    80004cb2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004cb4:	00024917          	auipc	s2,0x24
    80004cb8:	08c90913          	addi	s2,s2,140 # 80028d40 <log>
    80004cbc:	854a                	mv	a0,s2
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	f80080e7          	jalr	-128(ra) # 80000c3e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004cc6:	02c92603          	lw	a2,44(s2)
    80004cca:	47f5                	li	a5,29
    80004ccc:	06c7c563          	blt	a5,a2,80004d36 <log_write+0x90>
    80004cd0:	00024797          	auipc	a5,0x24
    80004cd4:	08c7a783          	lw	a5,140(a5) # 80028d5c <log+0x1c>
    80004cd8:	37fd                	addiw	a5,a5,-1
    80004cda:	04f65e63          	bge	a2,a5,80004d36 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004cde:	00024797          	auipc	a5,0x24
    80004ce2:	0827a783          	lw	a5,130(a5) # 80028d60 <log+0x20>
    80004ce6:	06f05063          	blez	a5,80004d46 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004cea:	4781                	li	a5,0
    80004cec:	06c05563          	blez	a2,80004d56 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004cf0:	44cc                	lw	a1,12(s1)
    80004cf2:	00024717          	auipc	a4,0x24
    80004cf6:	07e70713          	addi	a4,a4,126 # 80028d70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004cfa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004cfc:	4314                	lw	a3,0(a4)
    80004cfe:	04b68c63          	beq	a3,a1,80004d56 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004d02:	2785                	addiw	a5,a5,1
    80004d04:	0711                	addi	a4,a4,4
    80004d06:	fef61be3          	bne	a2,a5,80004cfc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004d0a:	0621                	addi	a2,a2,8
    80004d0c:	060a                	slli	a2,a2,0x2
    80004d0e:	00024797          	auipc	a5,0x24
    80004d12:	03278793          	addi	a5,a5,50 # 80028d40 <log>
    80004d16:	97b2                	add	a5,a5,a2
    80004d18:	44d8                	lw	a4,12(s1)
    80004d1a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	d7a080e7          	jalr	-646(ra) # 80003a98 <bpin>
    log.lh.n++;
    80004d26:	00024717          	auipc	a4,0x24
    80004d2a:	01a70713          	addi	a4,a4,26 # 80028d40 <log>
    80004d2e:	575c                	lw	a5,44(a4)
    80004d30:	2785                	addiw	a5,a5,1
    80004d32:	d75c                	sw	a5,44(a4)
    80004d34:	a82d                	j	80004d6e <log_write+0xc8>
    panic("too big a transaction");
    80004d36:	00003517          	auipc	a0,0x3
    80004d3a:	7f250513          	addi	a0,a0,2034 # 80008528 <etext+0x528>
    80004d3e:	ffffc097          	auipc	ra,0xffffc
    80004d42:	822080e7          	jalr	-2014(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004d46:	00003517          	auipc	a0,0x3
    80004d4a:	7fa50513          	addi	a0,a0,2042 # 80008540 <etext+0x540>
    80004d4e:	ffffc097          	auipc	ra,0xffffc
    80004d52:	812080e7          	jalr	-2030(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004d56:	00878693          	addi	a3,a5,8
    80004d5a:	068a                	slli	a3,a3,0x2
    80004d5c:	00024717          	auipc	a4,0x24
    80004d60:	fe470713          	addi	a4,a4,-28 # 80028d40 <log>
    80004d64:	9736                	add	a4,a4,a3
    80004d66:	44d4                	lw	a3,12(s1)
    80004d68:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004d6a:	faf609e3          	beq	a2,a5,80004d1c <log_write+0x76>
  }
  release(&log.lock);
    80004d6e:	00024517          	auipc	a0,0x24
    80004d72:	fd250513          	addi	a0,a0,-46 # 80028d40 <log>
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	f78080e7          	jalr	-136(ra) # 80000cee <release>
}
    80004d7e:	60e2                	ld	ra,24(sp)
    80004d80:	6442                	ld	s0,16(sp)
    80004d82:	64a2                	ld	s1,8(sp)
    80004d84:	6902                	ld	s2,0(sp)
    80004d86:	6105                	addi	sp,sp,32
    80004d88:	8082                	ret

0000000080004d8a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d8a:	1101                	addi	sp,sp,-32
    80004d8c:	ec06                	sd	ra,24(sp)
    80004d8e:	e822                	sd	s0,16(sp)
    80004d90:	e426                	sd	s1,8(sp)
    80004d92:	e04a                	sd	s2,0(sp)
    80004d94:	1000                	addi	s0,sp,32
    80004d96:	84aa                	mv	s1,a0
    80004d98:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d9a:	00003597          	auipc	a1,0x3
    80004d9e:	7c658593          	addi	a1,a1,1990 # 80008560 <etext+0x560>
    80004da2:	0521                	addi	a0,a0,8
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	e06080e7          	jalr	-506(ra) # 80000baa <initlock>
  lk->name = name;
    80004dac:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004db0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004db4:	0204a423          	sw	zero,40(s1)
}
    80004db8:	60e2                	ld	ra,24(sp)
    80004dba:	6442                	ld	s0,16(sp)
    80004dbc:	64a2                	ld	s1,8(sp)
    80004dbe:	6902                	ld	s2,0(sp)
    80004dc0:	6105                	addi	sp,sp,32
    80004dc2:	8082                	ret

0000000080004dc4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004dc4:	1101                	addi	sp,sp,-32
    80004dc6:	ec06                	sd	ra,24(sp)
    80004dc8:	e822                	sd	s0,16(sp)
    80004dca:	e426                	sd	s1,8(sp)
    80004dcc:	e04a                	sd	s2,0(sp)
    80004dce:	1000                	addi	s0,sp,32
    80004dd0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004dd2:	00850913          	addi	s2,a0,8
    80004dd6:	854a                	mv	a0,s2
    80004dd8:	ffffc097          	auipc	ra,0xffffc
    80004ddc:	e66080e7          	jalr	-410(ra) # 80000c3e <acquire>
  while (lk->locked) {
    80004de0:	409c                	lw	a5,0(s1)
    80004de2:	cb89                	beqz	a5,80004df4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004de4:	85ca                	mv	a1,s2
    80004de6:	8526                	mv	a0,s1
    80004de8:	ffffe097          	auipc	ra,0xffffe
    80004dec:	8cc080e7          	jalr	-1844(ra) # 800026b4 <sleep>
  while (lk->locked) {
    80004df0:	409c                	lw	a5,0(s1)
    80004df2:	fbed                	bnez	a5,80004de4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004df4:	4785                	li	a5,1
    80004df6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004df8:	ffffd097          	auipc	ra,0xffffd
    80004dfc:	dfe080e7          	jalr	-514(ra) # 80001bf6 <myproc>
    80004e00:	591c                	lw	a5,48(a0)
    80004e02:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004e04:	854a                	mv	a0,s2
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	ee8080e7          	jalr	-280(ra) # 80000cee <release>
}
    80004e0e:	60e2                	ld	ra,24(sp)
    80004e10:	6442                	ld	s0,16(sp)
    80004e12:	64a2                	ld	s1,8(sp)
    80004e14:	6902                	ld	s2,0(sp)
    80004e16:	6105                	addi	sp,sp,32
    80004e18:	8082                	ret

0000000080004e1a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004e1a:	1101                	addi	sp,sp,-32
    80004e1c:	ec06                	sd	ra,24(sp)
    80004e1e:	e822                	sd	s0,16(sp)
    80004e20:	e426                	sd	s1,8(sp)
    80004e22:	e04a                	sd	s2,0(sp)
    80004e24:	1000                	addi	s0,sp,32
    80004e26:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e28:	00850913          	addi	s2,a0,8
    80004e2c:	854a                	mv	a0,s2
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	e10080e7          	jalr	-496(ra) # 80000c3e <acquire>
  lk->locked = 0;
    80004e36:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e3a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004e3e:	8526                	mv	a0,s1
    80004e40:	ffffe097          	auipc	ra,0xffffe
    80004e44:	8d8080e7          	jalr	-1832(ra) # 80002718 <wakeup>
  release(&lk->lk);
    80004e48:	854a                	mv	a0,s2
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	ea4080e7          	jalr	-348(ra) # 80000cee <release>
}
    80004e52:	60e2                	ld	ra,24(sp)
    80004e54:	6442                	ld	s0,16(sp)
    80004e56:	64a2                	ld	s1,8(sp)
    80004e58:	6902                	ld	s2,0(sp)
    80004e5a:	6105                	addi	sp,sp,32
    80004e5c:	8082                	ret

0000000080004e5e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e5e:	7179                	addi	sp,sp,-48
    80004e60:	f406                	sd	ra,40(sp)
    80004e62:	f022                	sd	s0,32(sp)
    80004e64:	ec26                	sd	s1,24(sp)
    80004e66:	e84a                	sd	s2,16(sp)
    80004e68:	1800                	addi	s0,sp,48
    80004e6a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e6c:	00850913          	addi	s2,a0,8
    80004e70:	854a                	mv	a0,s2
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	dcc080e7          	jalr	-564(ra) # 80000c3e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e7a:	409c                	lw	a5,0(s1)
    80004e7c:	ef91                	bnez	a5,80004e98 <holdingsleep+0x3a>
    80004e7e:	4481                	li	s1,0
  release(&lk->lk);
    80004e80:	854a                	mv	a0,s2
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	e6c080e7          	jalr	-404(ra) # 80000cee <release>
  return r;
}
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	70a2                	ld	ra,40(sp)
    80004e8e:	7402                	ld	s0,32(sp)
    80004e90:	64e2                	ld	s1,24(sp)
    80004e92:	6942                	ld	s2,16(sp)
    80004e94:	6145                	addi	sp,sp,48
    80004e96:	8082                	ret
    80004e98:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e9a:	0284a983          	lw	s3,40(s1)
    80004e9e:	ffffd097          	auipc	ra,0xffffd
    80004ea2:	d58080e7          	jalr	-680(ra) # 80001bf6 <myproc>
    80004ea6:	5904                	lw	s1,48(a0)
    80004ea8:	413484b3          	sub	s1,s1,s3
    80004eac:	0014b493          	seqz	s1,s1
    80004eb0:	69a2                	ld	s3,8(sp)
    80004eb2:	b7f9                	j	80004e80 <holdingsleep+0x22>

0000000080004eb4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004eb4:	1141                	addi	sp,sp,-16
    80004eb6:	e406                	sd	ra,8(sp)
    80004eb8:	e022                	sd	s0,0(sp)
    80004eba:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ebc:	00003597          	auipc	a1,0x3
    80004ec0:	6b458593          	addi	a1,a1,1716 # 80008570 <etext+0x570>
    80004ec4:	00024517          	auipc	a0,0x24
    80004ec8:	fc450513          	addi	a0,a0,-60 # 80028e88 <ftable>
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	cde080e7          	jalr	-802(ra) # 80000baa <initlock>
}
    80004ed4:	60a2                	ld	ra,8(sp)
    80004ed6:	6402                	ld	s0,0(sp)
    80004ed8:	0141                	addi	sp,sp,16
    80004eda:	8082                	ret

0000000080004edc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004edc:	1101                	addi	sp,sp,-32
    80004ede:	ec06                	sd	ra,24(sp)
    80004ee0:	e822                	sd	s0,16(sp)
    80004ee2:	e426                	sd	s1,8(sp)
    80004ee4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ee6:	00024517          	auipc	a0,0x24
    80004eea:	fa250513          	addi	a0,a0,-94 # 80028e88 <ftable>
    80004eee:	ffffc097          	auipc	ra,0xffffc
    80004ef2:	d50080e7          	jalr	-688(ra) # 80000c3e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ef6:	00024497          	auipc	s1,0x24
    80004efa:	faa48493          	addi	s1,s1,-86 # 80028ea0 <ftable+0x18>
    80004efe:	00025717          	auipc	a4,0x25
    80004f02:	f4270713          	addi	a4,a4,-190 # 80029e40 <disk>
    if(f->ref == 0){
    80004f06:	40dc                	lw	a5,4(s1)
    80004f08:	cf99                	beqz	a5,80004f26 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f0a:	02848493          	addi	s1,s1,40
    80004f0e:	fee49ce3          	bne	s1,a4,80004f06 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004f12:	00024517          	auipc	a0,0x24
    80004f16:	f7650513          	addi	a0,a0,-138 # 80028e88 <ftable>
    80004f1a:	ffffc097          	auipc	ra,0xffffc
    80004f1e:	dd4080e7          	jalr	-556(ra) # 80000cee <release>
  return 0;
    80004f22:	4481                	li	s1,0
    80004f24:	a819                	j	80004f3a <filealloc+0x5e>
      f->ref = 1;
    80004f26:	4785                	li	a5,1
    80004f28:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004f2a:	00024517          	auipc	a0,0x24
    80004f2e:	f5e50513          	addi	a0,a0,-162 # 80028e88 <ftable>
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	dbc080e7          	jalr	-580(ra) # 80000cee <release>
}
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	60e2                	ld	ra,24(sp)
    80004f3e:	6442                	ld	s0,16(sp)
    80004f40:	64a2                	ld	s1,8(sp)
    80004f42:	6105                	addi	sp,sp,32
    80004f44:	8082                	ret

0000000080004f46 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004f46:	1101                	addi	sp,sp,-32
    80004f48:	ec06                	sd	ra,24(sp)
    80004f4a:	e822                	sd	s0,16(sp)
    80004f4c:	e426                	sd	s1,8(sp)
    80004f4e:	1000                	addi	s0,sp,32
    80004f50:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004f52:	00024517          	auipc	a0,0x24
    80004f56:	f3650513          	addi	a0,a0,-202 # 80028e88 <ftable>
    80004f5a:	ffffc097          	auipc	ra,0xffffc
    80004f5e:	ce4080e7          	jalr	-796(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004f62:	40dc                	lw	a5,4(s1)
    80004f64:	02f05263          	blez	a5,80004f88 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f68:	2785                	addiw	a5,a5,1
    80004f6a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f6c:	00024517          	auipc	a0,0x24
    80004f70:	f1c50513          	addi	a0,a0,-228 # 80028e88 <ftable>
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	d7a080e7          	jalr	-646(ra) # 80000cee <release>
  return f;
}
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	60e2                	ld	ra,24(sp)
    80004f80:	6442                	ld	s0,16(sp)
    80004f82:	64a2                	ld	s1,8(sp)
    80004f84:	6105                	addi	sp,sp,32
    80004f86:	8082                	ret
    panic("filedup");
    80004f88:	00003517          	auipc	a0,0x3
    80004f8c:	5f050513          	addi	a0,a0,1520 # 80008578 <etext+0x578>
    80004f90:	ffffb097          	auipc	ra,0xffffb
    80004f94:	5d0080e7          	jalr	1488(ra) # 80000560 <panic>

0000000080004f98 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f98:	7139                	addi	sp,sp,-64
    80004f9a:	fc06                	sd	ra,56(sp)
    80004f9c:	f822                	sd	s0,48(sp)
    80004f9e:	f426                	sd	s1,40(sp)
    80004fa0:	0080                	addi	s0,sp,64
    80004fa2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004fa4:	00024517          	auipc	a0,0x24
    80004fa8:	ee450513          	addi	a0,a0,-284 # 80028e88 <ftable>
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	c92080e7          	jalr	-878(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004fb4:	40dc                	lw	a5,4(s1)
    80004fb6:	04f05a63          	blez	a5,8000500a <fileclose+0x72>
    panic("fileclose");
  if(--f->ref > 0){
    80004fba:	37fd                	addiw	a5,a5,-1
    80004fbc:	c0dc                	sw	a5,4(s1)
    80004fbe:	06f04263          	bgtz	a5,80005022 <fileclose+0x8a>
    80004fc2:	f04a                	sd	s2,32(sp)
    80004fc4:	ec4e                	sd	s3,24(sp)
    80004fc6:	e852                	sd	s4,16(sp)
    80004fc8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004fca:	0004a903          	lw	s2,0(s1)
    80004fce:	0094ca83          	lbu	s5,9(s1)
    80004fd2:	0104ba03          	ld	s4,16(s1)
    80004fd6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004fda:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004fde:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004fe2:	00024517          	auipc	a0,0x24
    80004fe6:	ea650513          	addi	a0,a0,-346 # 80028e88 <ftable>
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	d04080e7          	jalr	-764(ra) # 80000cee <release>

  if(ff.type == FD_PIPE){
    80004ff2:	4785                	li	a5,1
    80004ff4:	04f90463          	beq	s2,a5,8000503c <fileclose+0xa4>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ff8:	3979                	addiw	s2,s2,-2
    80004ffa:	4785                	li	a5,1
    80004ffc:	0527fb63          	bgeu	a5,s2,80005052 <fileclose+0xba>
    80005000:	7902                	ld	s2,32(sp)
    80005002:	69e2                	ld	s3,24(sp)
    80005004:	6a42                	ld	s4,16(sp)
    80005006:	6aa2                	ld	s5,8(sp)
    80005008:	a02d                	j	80005032 <fileclose+0x9a>
    8000500a:	f04a                	sd	s2,32(sp)
    8000500c:	ec4e                	sd	s3,24(sp)
    8000500e:	e852                	sd	s4,16(sp)
    80005010:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005012:	00003517          	auipc	a0,0x3
    80005016:	56e50513          	addi	a0,a0,1390 # 80008580 <etext+0x580>
    8000501a:	ffffb097          	auipc	ra,0xffffb
    8000501e:	546080e7          	jalr	1350(ra) # 80000560 <panic>
    release(&ftable.lock);
    80005022:	00024517          	auipc	a0,0x24
    80005026:	e6650513          	addi	a0,a0,-410 # 80028e88 <ftable>
    8000502a:	ffffc097          	auipc	ra,0xffffc
    8000502e:	cc4080e7          	jalr	-828(ra) # 80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005032:	70e2                	ld	ra,56(sp)
    80005034:	7442                	ld	s0,48(sp)
    80005036:	74a2                	ld	s1,40(sp)
    80005038:	6121                	addi	sp,sp,64
    8000503a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000503c:	85d6                	mv	a1,s5
    8000503e:	8552                	mv	a0,s4
    80005040:	00000097          	auipc	ra,0x0
    80005044:	3ac080e7          	jalr	940(ra) # 800053ec <pipeclose>
    80005048:	7902                	ld	s2,32(sp)
    8000504a:	69e2                	ld	s3,24(sp)
    8000504c:	6a42                	ld	s4,16(sp)
    8000504e:	6aa2                	ld	s5,8(sp)
    80005050:	b7cd                	j	80005032 <fileclose+0x9a>
    begin_op();
    80005052:	00000097          	auipc	ra,0x0
    80005056:	a76080e7          	jalr	-1418(ra) # 80004ac8 <begin_op>
    iput(ff.ip);
    8000505a:	854e                	mv	a0,s3
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	240080e7          	jalr	576(ra) # 8000429c <iput>
    end_op();
    80005064:	00000097          	auipc	ra,0x0
    80005068:	ade080e7          	jalr	-1314(ra) # 80004b42 <end_op>
    8000506c:	7902                	ld	s2,32(sp)
    8000506e:	69e2                	ld	s3,24(sp)
    80005070:	6a42                	ld	s4,16(sp)
    80005072:	6aa2                	ld	s5,8(sp)
    80005074:	bf7d                	j	80005032 <fileclose+0x9a>

0000000080005076 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005076:	715d                	addi	sp,sp,-80
    80005078:	e486                	sd	ra,72(sp)
    8000507a:	e0a2                	sd	s0,64(sp)
    8000507c:	fc26                	sd	s1,56(sp)
    8000507e:	f44e                	sd	s3,40(sp)
    80005080:	0880                	addi	s0,sp,80
    80005082:	84aa                	mv	s1,a0
    80005084:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005086:	ffffd097          	auipc	ra,0xffffd
    8000508a:	b70080e7          	jalr	-1168(ra) # 80001bf6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000508e:	409c                	lw	a5,0(s1)
    80005090:	37f9                	addiw	a5,a5,-2
    80005092:	4705                	li	a4,1
    80005094:	04f76a63          	bltu	a4,a5,800050e8 <filestat+0x72>
    80005098:	f84a                	sd	s2,48(sp)
    8000509a:	f052                	sd	s4,32(sp)
    8000509c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000509e:	6c88                	ld	a0,24(s1)
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	03e080e7          	jalr	62(ra) # 800040de <ilock>
    stati(f->ip, &st);
    800050a8:	fb840a13          	addi	s4,s0,-72
    800050ac:	85d2                	mv	a1,s4
    800050ae:	6c88                	ld	a0,24(s1)
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	2bc080e7          	jalr	700(ra) # 8000436c <stati>
    iunlock(f->ip);
    800050b8:	6c88                	ld	a0,24(s1)
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	0ea080e7          	jalr	234(ra) # 800041a4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800050c2:	46e1                	li	a3,24
    800050c4:	8652                	mv	a2,s4
    800050c6:	85ce                	mv	a1,s3
    800050c8:	22893503          	ld	a0,552(s2)
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	644080e7          	jalr	1604(ra) # 80001710 <copyout>
    800050d4:	41f5551b          	sraiw	a0,a0,0x1f
    800050d8:	7942                	ld	s2,48(sp)
    800050da:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800050dc:	60a6                	ld	ra,72(sp)
    800050de:	6406                	ld	s0,64(sp)
    800050e0:	74e2                	ld	s1,56(sp)
    800050e2:	79a2                	ld	s3,40(sp)
    800050e4:	6161                	addi	sp,sp,80
    800050e6:	8082                	ret
  return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	bfcd                	j	800050dc <filestat+0x66>

00000000800050ec <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800050ec:	7179                	addi	sp,sp,-48
    800050ee:	f406                	sd	ra,40(sp)
    800050f0:	f022                	sd	s0,32(sp)
    800050f2:	e84a                	sd	s2,16(sp)
    800050f4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800050f6:	00854783          	lbu	a5,8(a0)
    800050fa:	cbc5                	beqz	a5,800051aa <fileread+0xbe>
    800050fc:	ec26                	sd	s1,24(sp)
    800050fe:	e44e                	sd	s3,8(sp)
    80005100:	84aa                	mv	s1,a0
    80005102:	89ae                	mv	s3,a1
    80005104:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005106:	411c                	lw	a5,0(a0)
    80005108:	4705                	li	a4,1
    8000510a:	04e78963          	beq	a5,a4,8000515c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000510e:	470d                	li	a4,3
    80005110:	04e78f63          	beq	a5,a4,8000516e <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005114:	4709                	li	a4,2
    80005116:	08e79263          	bne	a5,a4,8000519a <fileread+0xae>
    ilock(f->ip);
    8000511a:	6d08                	ld	a0,24(a0)
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	fc2080e7          	jalr	-62(ra) # 800040de <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005124:	874a                	mv	a4,s2
    80005126:	5094                	lw	a3,32(s1)
    80005128:	864e                	mv	a2,s3
    8000512a:	4585                	li	a1,1
    8000512c:	6c88                	ld	a0,24(s1)
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	26c080e7          	jalr	620(ra) # 8000439a <readi>
    80005136:	892a                	mv	s2,a0
    80005138:	00a05563          	blez	a0,80005142 <fileread+0x56>
      f->off += r;
    8000513c:	509c                	lw	a5,32(s1)
    8000513e:	9fa9                	addw	a5,a5,a0
    80005140:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005142:	6c88                	ld	a0,24(s1)
    80005144:	fffff097          	auipc	ra,0xfffff
    80005148:	060080e7          	jalr	96(ra) # 800041a4 <iunlock>
    8000514c:	64e2                	ld	s1,24(sp)
    8000514e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005150:	854a                	mv	a0,s2
    80005152:	70a2                	ld	ra,40(sp)
    80005154:	7402                	ld	s0,32(sp)
    80005156:	6942                	ld	s2,16(sp)
    80005158:	6145                	addi	sp,sp,48
    8000515a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000515c:	6908                	ld	a0,16(a0)
    8000515e:	00000097          	auipc	ra,0x0
    80005162:	41a080e7          	jalr	1050(ra) # 80005578 <piperead>
    80005166:	892a                	mv	s2,a0
    80005168:	64e2                	ld	s1,24(sp)
    8000516a:	69a2                	ld	s3,8(sp)
    8000516c:	b7d5                	j	80005150 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000516e:	02451783          	lh	a5,36(a0)
    80005172:	03079693          	slli	a3,a5,0x30
    80005176:	92c1                	srli	a3,a3,0x30
    80005178:	4725                	li	a4,9
    8000517a:	02d76a63          	bltu	a4,a3,800051ae <fileread+0xc2>
    8000517e:	0792                	slli	a5,a5,0x4
    80005180:	00024717          	auipc	a4,0x24
    80005184:	c6870713          	addi	a4,a4,-920 # 80028de8 <devsw>
    80005188:	97ba                	add	a5,a5,a4
    8000518a:	639c                	ld	a5,0(a5)
    8000518c:	c78d                	beqz	a5,800051b6 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    8000518e:	4505                	li	a0,1
    80005190:	9782                	jalr	a5
    80005192:	892a                	mv	s2,a0
    80005194:	64e2                	ld	s1,24(sp)
    80005196:	69a2                	ld	s3,8(sp)
    80005198:	bf65                	j	80005150 <fileread+0x64>
    panic("fileread");
    8000519a:	00003517          	auipc	a0,0x3
    8000519e:	3f650513          	addi	a0,a0,1014 # 80008590 <etext+0x590>
    800051a2:	ffffb097          	auipc	ra,0xffffb
    800051a6:	3be080e7          	jalr	958(ra) # 80000560 <panic>
    return -1;
    800051aa:	597d                	li	s2,-1
    800051ac:	b755                	j	80005150 <fileread+0x64>
      return -1;
    800051ae:	597d                	li	s2,-1
    800051b0:	64e2                	ld	s1,24(sp)
    800051b2:	69a2                	ld	s3,8(sp)
    800051b4:	bf71                	j	80005150 <fileread+0x64>
    800051b6:	597d                	li	s2,-1
    800051b8:	64e2                	ld	s1,24(sp)
    800051ba:	69a2                	ld	s3,8(sp)
    800051bc:	bf51                	j	80005150 <fileread+0x64>

00000000800051be <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800051be:	00954783          	lbu	a5,9(a0)
    800051c2:	12078c63          	beqz	a5,800052fa <filewrite+0x13c>
{
    800051c6:	711d                	addi	sp,sp,-96
    800051c8:	ec86                	sd	ra,88(sp)
    800051ca:	e8a2                	sd	s0,80(sp)
    800051cc:	e0ca                	sd	s2,64(sp)
    800051ce:	f456                	sd	s5,40(sp)
    800051d0:	f05a                	sd	s6,32(sp)
    800051d2:	1080                	addi	s0,sp,96
    800051d4:	892a                	mv	s2,a0
    800051d6:	8b2e                	mv	s6,a1
    800051d8:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800051da:	411c                	lw	a5,0(a0)
    800051dc:	4705                	li	a4,1
    800051de:	02e78963          	beq	a5,a4,80005210 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051e2:	470d                	li	a4,3
    800051e4:	02e78c63          	beq	a5,a4,8000521c <filewrite+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800051e8:	4709                	li	a4,2
    800051ea:	0ee79a63          	bne	a5,a4,800052de <filewrite+0x120>
    800051ee:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800051f0:	0cc05563          	blez	a2,800052ba <filewrite+0xfc>
    800051f4:	e4a6                	sd	s1,72(sp)
    800051f6:	fc4e                	sd	s3,56(sp)
    800051f8:	ec5e                	sd	s7,24(sp)
    800051fa:	e862                	sd	s8,16(sp)
    800051fc:	e466                	sd	s9,8(sp)
    int i = 0;
    800051fe:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80005200:	6b85                	lui	s7,0x1
    80005202:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005206:	6c85                	lui	s9,0x1
    80005208:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000520c:	4c05                	li	s8,1
    8000520e:	a849                	j	800052a0 <filewrite+0xe2>
    ret = pipewrite(f->pipe, addr, n);
    80005210:	6908                	ld	a0,16(a0)
    80005212:	00000097          	auipc	ra,0x0
    80005216:	24a080e7          	jalr	586(ra) # 8000545c <pipewrite>
    8000521a:	a85d                	j	800052d0 <filewrite+0x112>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000521c:	02451783          	lh	a5,36(a0)
    80005220:	03079693          	slli	a3,a5,0x30
    80005224:	92c1                	srli	a3,a3,0x30
    80005226:	4725                	li	a4,9
    80005228:	0cd76b63          	bltu	a4,a3,800052fe <filewrite+0x140>
    8000522c:	0792                	slli	a5,a5,0x4
    8000522e:	00024717          	auipc	a4,0x24
    80005232:	bba70713          	addi	a4,a4,-1094 # 80028de8 <devsw>
    80005236:	97ba                	add	a5,a5,a4
    80005238:	679c                	ld	a5,8(a5)
    8000523a:	c7e1                	beqz	a5,80005302 <filewrite+0x144>
    ret = devsw[f->major].write(1, addr, n);
    8000523c:	4505                	li	a0,1
    8000523e:	9782                	jalr	a5
    80005240:	a841                	j	800052d0 <filewrite+0x112>
      if(n1 > max)
    80005242:	2981                	sext.w	s3,s3
      begin_op();
    80005244:	00000097          	auipc	ra,0x0
    80005248:	884080e7          	jalr	-1916(ra) # 80004ac8 <begin_op>
      ilock(f->ip);
    8000524c:	01893503          	ld	a0,24(s2)
    80005250:	fffff097          	auipc	ra,0xfffff
    80005254:	e8e080e7          	jalr	-370(ra) # 800040de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005258:	874e                	mv	a4,s3
    8000525a:	02092683          	lw	a3,32(s2)
    8000525e:	016a0633          	add	a2,s4,s6
    80005262:	85e2                	mv	a1,s8
    80005264:	01893503          	ld	a0,24(s2)
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	238080e7          	jalr	568(ra) # 800044a0 <writei>
    80005270:	84aa                	mv	s1,a0
    80005272:	00a05763          	blez	a0,80005280 <filewrite+0xc2>
        f->off += r;
    80005276:	02092783          	lw	a5,32(s2)
    8000527a:	9fa9                	addw	a5,a5,a0
    8000527c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005280:	01893503          	ld	a0,24(s2)
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	f20080e7          	jalr	-224(ra) # 800041a4 <iunlock>
      end_op();
    8000528c:	00000097          	auipc	ra,0x0
    80005290:	8b6080e7          	jalr	-1866(ra) # 80004b42 <end_op>

      if(r != n1){
    80005294:	02999563          	bne	s3,s1,800052be <filewrite+0x100>
        // error from writei
        break;
      }
      i += r;
    80005298:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000529c:	015a5963          	bge	s4,s5,800052ae <filewrite+0xf0>
      int n1 = n - i;
    800052a0:	414a87bb          	subw	a5,s5,s4
    800052a4:	89be                	mv	s3,a5
      if(n1 > max)
    800052a6:	f8fbdee3          	bge	s7,a5,80005242 <filewrite+0x84>
    800052aa:	89e6                	mv	s3,s9
    800052ac:	bf59                	j	80005242 <filewrite+0x84>
    800052ae:	64a6                	ld	s1,72(sp)
    800052b0:	79e2                	ld	s3,56(sp)
    800052b2:	6be2                	ld	s7,24(sp)
    800052b4:	6c42                	ld	s8,16(sp)
    800052b6:	6ca2                	ld	s9,8(sp)
    800052b8:	a801                	j	800052c8 <filewrite+0x10a>
    int i = 0;
    800052ba:	4a01                	li	s4,0
    800052bc:	a031                	j	800052c8 <filewrite+0x10a>
    800052be:	64a6                	ld	s1,72(sp)
    800052c0:	79e2                	ld	s3,56(sp)
    800052c2:	6be2                	ld	s7,24(sp)
    800052c4:	6c42                	ld	s8,16(sp)
    800052c6:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800052c8:	034a9f63          	bne	s5,s4,80005306 <filewrite+0x148>
    800052cc:	8556                	mv	a0,s5
    800052ce:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800052d0:	60e6                	ld	ra,88(sp)
    800052d2:	6446                	ld	s0,80(sp)
    800052d4:	6906                	ld	s2,64(sp)
    800052d6:	7aa2                	ld	s5,40(sp)
    800052d8:	7b02                	ld	s6,32(sp)
    800052da:	6125                	addi	sp,sp,96
    800052dc:	8082                	ret
    800052de:	e4a6                	sd	s1,72(sp)
    800052e0:	fc4e                	sd	s3,56(sp)
    800052e2:	f852                	sd	s4,48(sp)
    800052e4:	ec5e                	sd	s7,24(sp)
    800052e6:	e862                	sd	s8,16(sp)
    800052e8:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800052ea:	00003517          	auipc	a0,0x3
    800052ee:	2b650513          	addi	a0,a0,694 # 800085a0 <etext+0x5a0>
    800052f2:	ffffb097          	auipc	ra,0xffffb
    800052f6:	26e080e7          	jalr	622(ra) # 80000560 <panic>
    return -1;
    800052fa:	557d                	li	a0,-1
}
    800052fc:	8082                	ret
      return -1;
    800052fe:	557d                	li	a0,-1
    80005300:	bfc1                	j	800052d0 <filewrite+0x112>
    80005302:	557d                	li	a0,-1
    80005304:	b7f1                	j	800052d0 <filewrite+0x112>
    ret = (i == n ? n : -1);
    80005306:	557d                	li	a0,-1
    80005308:	7a42                	ld	s4,48(sp)
    8000530a:	b7d9                	j	800052d0 <filewrite+0x112>

000000008000530c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000530c:	7179                	addi	sp,sp,-48
    8000530e:	f406                	sd	ra,40(sp)
    80005310:	f022                	sd	s0,32(sp)
    80005312:	ec26                	sd	s1,24(sp)
    80005314:	e052                	sd	s4,0(sp)
    80005316:	1800                	addi	s0,sp,48
    80005318:	84aa                	mv	s1,a0
    8000531a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000531c:	0005b023          	sd	zero,0(a1)
    80005320:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005324:	00000097          	auipc	ra,0x0
    80005328:	bb8080e7          	jalr	-1096(ra) # 80004edc <filealloc>
    8000532c:	e088                	sd	a0,0(s1)
    8000532e:	cd49                	beqz	a0,800053c8 <pipealloc+0xbc>
    80005330:	00000097          	auipc	ra,0x0
    80005334:	bac080e7          	jalr	-1108(ra) # 80004edc <filealloc>
    80005338:	00aa3023          	sd	a0,0(s4)
    8000533c:	c141                	beqz	a0,800053bc <pipealloc+0xb0>
    8000533e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005340:	ffffc097          	auipc	ra,0xffffc
    80005344:	80a080e7          	jalr	-2038(ra) # 80000b4a <kalloc>
    80005348:	892a                	mv	s2,a0
    8000534a:	c13d                	beqz	a0,800053b0 <pipealloc+0xa4>
    8000534c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000534e:	4985                	li	s3,1
    80005350:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005354:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005358:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000535c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005360:	00003597          	auipc	a1,0x3
    80005364:	25058593          	addi	a1,a1,592 # 800085b0 <etext+0x5b0>
    80005368:	ffffc097          	auipc	ra,0xffffc
    8000536c:	842080e7          	jalr	-1982(ra) # 80000baa <initlock>
  (*f0)->type = FD_PIPE;
    80005370:	609c                	ld	a5,0(s1)
    80005372:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005376:	609c                	ld	a5,0(s1)
    80005378:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000537c:	609c                	ld	a5,0(s1)
    8000537e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005382:	609c                	ld	a5,0(s1)
    80005384:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005388:	000a3783          	ld	a5,0(s4)
    8000538c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005390:	000a3783          	ld	a5,0(s4)
    80005394:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005398:	000a3783          	ld	a5,0(s4)
    8000539c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800053a0:	000a3783          	ld	a5,0(s4)
    800053a4:	0127b823          	sd	s2,16(a5)
  return 0;
    800053a8:	4501                	li	a0,0
    800053aa:	6942                	ld	s2,16(sp)
    800053ac:	69a2                	ld	s3,8(sp)
    800053ae:	a03d                	j	800053dc <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800053b0:	6088                	ld	a0,0(s1)
    800053b2:	c119                	beqz	a0,800053b8 <pipealloc+0xac>
    800053b4:	6942                	ld	s2,16(sp)
    800053b6:	a029                	j	800053c0 <pipealloc+0xb4>
    800053b8:	6942                	ld	s2,16(sp)
    800053ba:	a039                	j	800053c8 <pipealloc+0xbc>
    800053bc:	6088                	ld	a0,0(s1)
    800053be:	c50d                	beqz	a0,800053e8 <pipealloc+0xdc>
    fileclose(*f0);
    800053c0:	00000097          	auipc	ra,0x0
    800053c4:	bd8080e7          	jalr	-1064(ra) # 80004f98 <fileclose>
  if(*f1)
    800053c8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800053cc:	557d                	li	a0,-1
  if(*f1)
    800053ce:	c799                	beqz	a5,800053dc <pipealloc+0xd0>
    fileclose(*f1);
    800053d0:	853e                	mv	a0,a5
    800053d2:	00000097          	auipc	ra,0x0
    800053d6:	bc6080e7          	jalr	-1082(ra) # 80004f98 <fileclose>
  return -1;
    800053da:	557d                	li	a0,-1
}
    800053dc:	70a2                	ld	ra,40(sp)
    800053de:	7402                	ld	s0,32(sp)
    800053e0:	64e2                	ld	s1,24(sp)
    800053e2:	6a02                	ld	s4,0(sp)
    800053e4:	6145                	addi	sp,sp,48
    800053e6:	8082                	ret
  return -1;
    800053e8:	557d                	li	a0,-1
    800053ea:	bfcd                	j	800053dc <pipealloc+0xd0>

00000000800053ec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800053ec:	1101                	addi	sp,sp,-32
    800053ee:	ec06                	sd	ra,24(sp)
    800053f0:	e822                	sd	s0,16(sp)
    800053f2:	e426                	sd	s1,8(sp)
    800053f4:	e04a                	sd	s2,0(sp)
    800053f6:	1000                	addi	s0,sp,32
    800053f8:	84aa                	mv	s1,a0
    800053fa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	842080e7          	jalr	-1982(ra) # 80000c3e <acquire>
  if(writable){
    80005404:	02090d63          	beqz	s2,8000543e <pipeclose+0x52>
    pi->writeopen = 0;
    80005408:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000540c:	21848513          	addi	a0,s1,536
    80005410:	ffffd097          	auipc	ra,0xffffd
    80005414:	308080e7          	jalr	776(ra) # 80002718 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005418:	2204b783          	ld	a5,544(s1)
    8000541c:	eb95                	bnez	a5,80005450 <pipeclose+0x64>
    release(&pi->lock);
    8000541e:	8526                	mv	a0,s1
    80005420:	ffffc097          	auipc	ra,0xffffc
    80005424:	8ce080e7          	jalr	-1842(ra) # 80000cee <release>
    kfree((char*)pi);
    80005428:	8526                	mv	a0,s1
    8000542a:	ffffb097          	auipc	ra,0xffffb
    8000542e:	622080e7          	jalr	1570(ra) # 80000a4c <kfree>
  } else
    release(&pi->lock);
}
    80005432:	60e2                	ld	ra,24(sp)
    80005434:	6442                	ld	s0,16(sp)
    80005436:	64a2                	ld	s1,8(sp)
    80005438:	6902                	ld	s2,0(sp)
    8000543a:	6105                	addi	sp,sp,32
    8000543c:	8082                	ret
    pi->readopen = 0;
    8000543e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005442:	21c48513          	addi	a0,s1,540
    80005446:	ffffd097          	auipc	ra,0xffffd
    8000544a:	2d2080e7          	jalr	722(ra) # 80002718 <wakeup>
    8000544e:	b7e9                	j	80005418 <pipeclose+0x2c>
    release(&pi->lock);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffc097          	auipc	ra,0xffffc
    80005456:	89c080e7          	jalr	-1892(ra) # 80000cee <release>
}
    8000545a:	bfe1                	j	80005432 <pipeclose+0x46>

000000008000545c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000545c:	7159                	addi	sp,sp,-112
    8000545e:	f486                	sd	ra,104(sp)
    80005460:	f0a2                	sd	s0,96(sp)
    80005462:	eca6                	sd	s1,88(sp)
    80005464:	e8ca                	sd	s2,80(sp)
    80005466:	e4ce                	sd	s3,72(sp)
    80005468:	e0d2                	sd	s4,64(sp)
    8000546a:	fc56                	sd	s5,56(sp)
    8000546c:	1880                	addi	s0,sp,112
    8000546e:	84aa                	mv	s1,a0
    80005470:	8aae                	mv	s5,a1
    80005472:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005474:	ffffc097          	auipc	ra,0xffffc
    80005478:	782080e7          	jalr	1922(ra) # 80001bf6 <myproc>
    8000547c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffb097          	auipc	ra,0xffffb
    80005484:	7be080e7          	jalr	1982(ra) # 80000c3e <acquire>
  while(i < n){
    80005488:	0f405063          	blez	s4,80005568 <pipewrite+0x10c>
    8000548c:	f85a                	sd	s6,48(sp)
    8000548e:	f45e                	sd	s7,40(sp)
    80005490:	f062                	sd	s8,32(sp)
    80005492:	ec66                	sd	s9,24(sp)
    80005494:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005496:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005498:	f9f40c13          	addi	s8,s0,-97
    8000549c:	4b85                	li	s7,1
    8000549e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800054a0:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800054a4:	21c48c93          	addi	s9,s1,540
    800054a8:	a099                	j	800054ee <pipewrite+0x92>
      release(&pi->lock);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffc097          	auipc	ra,0xffffc
    800054b0:	842080e7          	jalr	-1982(ra) # 80000cee <release>
      return -1;
    800054b4:	597d                	li	s2,-1
    800054b6:	7b42                	ld	s6,48(sp)
    800054b8:	7ba2                	ld	s7,40(sp)
    800054ba:	7c02                	ld	s8,32(sp)
    800054bc:	6ce2                	ld	s9,24(sp)
    800054be:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800054c0:	854a                	mv	a0,s2
    800054c2:	70a6                	ld	ra,104(sp)
    800054c4:	7406                	ld	s0,96(sp)
    800054c6:	64e6                	ld	s1,88(sp)
    800054c8:	6946                	ld	s2,80(sp)
    800054ca:	69a6                	ld	s3,72(sp)
    800054cc:	6a06                	ld	s4,64(sp)
    800054ce:	7ae2                	ld	s5,56(sp)
    800054d0:	6165                	addi	sp,sp,112
    800054d2:	8082                	ret
      wakeup(&pi->nread);
    800054d4:	856a                	mv	a0,s10
    800054d6:	ffffd097          	auipc	ra,0xffffd
    800054da:	242080e7          	jalr	578(ra) # 80002718 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800054de:	85a6                	mv	a1,s1
    800054e0:	8566                	mv	a0,s9
    800054e2:	ffffd097          	auipc	ra,0xffffd
    800054e6:	1d2080e7          	jalr	466(ra) # 800026b4 <sleep>
  while(i < n){
    800054ea:	05495e63          	bge	s2,s4,80005546 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    800054ee:	2204a783          	lw	a5,544(s1)
    800054f2:	dfc5                	beqz	a5,800054aa <pipewrite+0x4e>
    800054f4:	854e                	mv	a0,s3
    800054f6:	ffffd097          	auipc	ra,0xffffd
    800054fa:	48e080e7          	jalr	1166(ra) # 80002984 <killed>
    800054fe:	f555                	bnez	a0,800054aa <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005500:	2184a783          	lw	a5,536(s1)
    80005504:	21c4a703          	lw	a4,540(s1)
    80005508:	2007879b          	addiw	a5,a5,512
    8000550c:	fcf704e3          	beq	a4,a5,800054d4 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005510:	86de                	mv	a3,s7
    80005512:	01590633          	add	a2,s2,s5
    80005516:	85e2                	mv	a1,s8
    80005518:	2289b503          	ld	a0,552(s3)
    8000551c:	ffffc097          	auipc	ra,0xffffc
    80005520:	280080e7          	jalr	640(ra) # 8000179c <copyin>
    80005524:	05650463          	beq	a0,s6,8000556c <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005528:	21c4a783          	lw	a5,540(s1)
    8000552c:	0017871b          	addiw	a4,a5,1
    80005530:	20e4ae23          	sw	a4,540(s1)
    80005534:	1ff7f793          	andi	a5,a5,511
    80005538:	97a6                	add	a5,a5,s1
    8000553a:	f9f44703          	lbu	a4,-97(s0)
    8000553e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005542:	2905                	addiw	s2,s2,1
    80005544:	b75d                	j	800054ea <pipewrite+0x8e>
    80005546:	7b42                	ld	s6,48(sp)
    80005548:	7ba2                	ld	s7,40(sp)
    8000554a:	7c02                	ld	s8,32(sp)
    8000554c:	6ce2                	ld	s9,24(sp)
    8000554e:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80005550:	21848513          	addi	a0,s1,536
    80005554:	ffffd097          	auipc	ra,0xffffd
    80005558:	1c4080e7          	jalr	452(ra) # 80002718 <wakeup>
  release(&pi->lock);
    8000555c:	8526                	mv	a0,s1
    8000555e:	ffffb097          	auipc	ra,0xffffb
    80005562:	790080e7          	jalr	1936(ra) # 80000cee <release>
  return i;
    80005566:	bfa9                	j	800054c0 <pipewrite+0x64>
  int i = 0;
    80005568:	4901                	li	s2,0
    8000556a:	b7dd                	j	80005550 <pipewrite+0xf4>
    8000556c:	7b42                	ld	s6,48(sp)
    8000556e:	7ba2                	ld	s7,40(sp)
    80005570:	7c02                	ld	s8,32(sp)
    80005572:	6ce2                	ld	s9,24(sp)
    80005574:	6d42                	ld	s10,16(sp)
    80005576:	bfe9                	j	80005550 <pipewrite+0xf4>

0000000080005578 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005578:	711d                	addi	sp,sp,-96
    8000557a:	ec86                	sd	ra,88(sp)
    8000557c:	e8a2                	sd	s0,80(sp)
    8000557e:	e4a6                	sd	s1,72(sp)
    80005580:	e0ca                	sd	s2,64(sp)
    80005582:	fc4e                	sd	s3,56(sp)
    80005584:	f852                	sd	s4,48(sp)
    80005586:	f456                	sd	s5,40(sp)
    80005588:	1080                	addi	s0,sp,96
    8000558a:	84aa                	mv	s1,a0
    8000558c:	892e                	mv	s2,a1
    8000558e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005590:	ffffc097          	auipc	ra,0xffffc
    80005594:	666080e7          	jalr	1638(ra) # 80001bf6 <myproc>
    80005598:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	6a2080e7          	jalr	1698(ra) # 80000c3e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055a4:	2184a703          	lw	a4,536(s1)
    800055a8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055ac:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055b0:	02f71b63          	bne	a4,a5,800055e6 <piperead+0x6e>
    800055b4:	2244a783          	lw	a5,548(s1)
    800055b8:	c3b1                	beqz	a5,800055fc <piperead+0x84>
    if(killed(pr)){
    800055ba:	8552                	mv	a0,s4
    800055bc:	ffffd097          	auipc	ra,0xffffd
    800055c0:	3c8080e7          	jalr	968(ra) # 80002984 <killed>
    800055c4:	e50d                	bnez	a0,800055ee <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055c6:	85a6                	mv	a1,s1
    800055c8:	854e                	mv	a0,s3
    800055ca:	ffffd097          	auipc	ra,0xffffd
    800055ce:	0ea080e7          	jalr	234(ra) # 800026b4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055d2:	2184a703          	lw	a4,536(s1)
    800055d6:	21c4a783          	lw	a5,540(s1)
    800055da:	fcf70de3          	beq	a4,a5,800055b4 <piperead+0x3c>
    800055de:	f05a                	sd	s6,32(sp)
    800055e0:	ec5e                	sd	s7,24(sp)
    800055e2:	e862                	sd	s8,16(sp)
    800055e4:	a839                	j	80005602 <piperead+0x8a>
    800055e6:	f05a                	sd	s6,32(sp)
    800055e8:	ec5e                	sd	s7,24(sp)
    800055ea:	e862                	sd	s8,16(sp)
    800055ec:	a819                	j	80005602 <piperead+0x8a>
      release(&pi->lock);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffb097          	auipc	ra,0xffffb
    800055f4:	6fe080e7          	jalr	1790(ra) # 80000cee <release>
      return -1;
    800055f8:	59fd                	li	s3,-1
    800055fa:	a895                	j	8000566e <piperead+0xf6>
    800055fc:	f05a                	sd	s6,32(sp)
    800055fe:	ec5e                	sd	s7,24(sp)
    80005600:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005602:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005604:	faf40c13          	addi	s8,s0,-81
    80005608:	4b85                	li	s7,1
    8000560a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000560c:	05505363          	blez	s5,80005652 <piperead+0xda>
    if(pi->nread == pi->nwrite)
    80005610:	2184a783          	lw	a5,536(s1)
    80005614:	21c4a703          	lw	a4,540(s1)
    80005618:	02f70d63          	beq	a4,a5,80005652 <piperead+0xda>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000561c:	0017871b          	addiw	a4,a5,1
    80005620:	20e4ac23          	sw	a4,536(s1)
    80005624:	1ff7f793          	andi	a5,a5,511
    80005628:	97a6                	add	a5,a5,s1
    8000562a:	0187c783          	lbu	a5,24(a5)
    8000562e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005632:	86de                	mv	a3,s7
    80005634:	8662                	mv	a2,s8
    80005636:	85ca                	mv	a1,s2
    80005638:	228a3503          	ld	a0,552(s4)
    8000563c:	ffffc097          	auipc	ra,0xffffc
    80005640:	0d4080e7          	jalr	212(ra) # 80001710 <copyout>
    80005644:	01650763          	beq	a0,s6,80005652 <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005648:	2985                	addiw	s3,s3,1
    8000564a:	0905                	addi	s2,s2,1
    8000564c:	fd3a92e3          	bne	s5,s3,80005610 <piperead+0x98>
    80005650:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005652:	21c48513          	addi	a0,s1,540
    80005656:	ffffd097          	auipc	ra,0xffffd
    8000565a:	0c2080e7          	jalr	194(ra) # 80002718 <wakeup>
  release(&pi->lock);
    8000565e:	8526                	mv	a0,s1
    80005660:	ffffb097          	auipc	ra,0xffffb
    80005664:	68e080e7          	jalr	1678(ra) # 80000cee <release>
    80005668:	7b02                	ld	s6,32(sp)
    8000566a:	6be2                	ld	s7,24(sp)
    8000566c:	6c42                	ld	s8,16(sp)
  return i;
}
    8000566e:	854e                	mv	a0,s3
    80005670:	60e6                	ld	ra,88(sp)
    80005672:	6446                	ld	s0,80(sp)
    80005674:	64a6                	ld	s1,72(sp)
    80005676:	6906                	ld	s2,64(sp)
    80005678:	79e2                	ld	s3,56(sp)
    8000567a:	7a42                	ld	s4,48(sp)
    8000567c:	7aa2                	ld	s5,40(sp)
    8000567e:	6125                	addi	sp,sp,96
    80005680:	8082                	ret

0000000080005682 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005682:	1141                	addi	sp,sp,-16
    80005684:	e406                	sd	ra,8(sp)
    80005686:	e022                	sd	s0,0(sp)
    80005688:	0800                	addi	s0,sp,16
    8000568a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000568c:	0035151b          	slliw	a0,a0,0x3
    80005690:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80005692:	8b89                	andi	a5,a5,2
    80005694:	c399                	beqz	a5,8000569a <flags2perm+0x18>
      perm |= PTE_W;
    80005696:	00456513          	ori	a0,a0,4
    return perm;
}
    8000569a:	60a2                	ld	ra,8(sp)
    8000569c:	6402                	ld	s0,0(sp)
    8000569e:	0141                	addi	sp,sp,16
    800056a0:	8082                	ret

00000000800056a2 <exec>:

int
exec(char *path, char **argv)
{
    800056a2:	de010113          	addi	sp,sp,-544
    800056a6:	20113c23          	sd	ra,536(sp)
    800056aa:	20813823          	sd	s0,528(sp)
    800056ae:	20913423          	sd	s1,520(sp)
    800056b2:	21213023          	sd	s2,512(sp)
    800056b6:	1400                	addi	s0,sp,544
    800056b8:	892a                	mv	s2,a0
    800056ba:	dea43823          	sd	a0,-528(s0)
    800056be:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800056c2:	ffffc097          	auipc	ra,0xffffc
    800056c6:	534080e7          	jalr	1332(ra) # 80001bf6 <myproc>
    800056ca:	84aa                	mv	s1,a0

  begin_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	3fc080e7          	jalr	1020(ra) # 80004ac8 <begin_op>

  if((ip = namei(path)) == 0){
    800056d4:	854a                	mv	a0,s2
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	1ec080e7          	jalr	492(ra) # 800048c2 <namei>
    800056de:	c525                	beqz	a0,80005746 <exec+0xa4>
    800056e0:	fbd2                	sd	s4,496(sp)
    800056e2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	9fa080e7          	jalr	-1542(ra) # 800040de <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800056ec:	04000713          	li	a4,64
    800056f0:	4681                	li	a3,0
    800056f2:	e5040613          	addi	a2,s0,-432
    800056f6:	4581                	li	a1,0
    800056f8:	8552                	mv	a0,s4
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	ca0080e7          	jalr	-864(ra) # 8000439a <readi>
    80005702:	04000793          	li	a5,64
    80005706:	00f51a63          	bne	a0,a5,8000571a <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000570a:	e5042703          	lw	a4,-432(s0)
    8000570e:	464c47b7          	lui	a5,0x464c4
    80005712:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005716:	02f70e63          	beq	a4,a5,80005752 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000571a:	8552                	mv	a0,s4
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	c28080e7          	jalr	-984(ra) # 80004344 <iunlockput>
    end_op();
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	41e080e7          	jalr	1054(ra) # 80004b42 <end_op>
  }
  return -1;
    8000572c:	557d                	li	a0,-1
    8000572e:	7a5e                	ld	s4,496(sp)
}
    80005730:	21813083          	ld	ra,536(sp)
    80005734:	21013403          	ld	s0,528(sp)
    80005738:	20813483          	ld	s1,520(sp)
    8000573c:	20013903          	ld	s2,512(sp)
    80005740:	22010113          	addi	sp,sp,544
    80005744:	8082                	ret
    end_op();
    80005746:	fffff097          	auipc	ra,0xfffff
    8000574a:	3fc080e7          	jalr	1020(ra) # 80004b42 <end_op>
    return -1;
    8000574e:	557d                	li	a0,-1
    80005750:	b7c5                	j	80005730 <exec+0x8e>
    80005752:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005754:	8526                	mv	a0,s1
    80005756:	ffffc097          	auipc	ra,0xffffc
    8000575a:	564080e7          	jalr	1380(ra) # 80001cba <proc_pagetable>
    8000575e:	8b2a                	mv	s6,a0
    80005760:	2c050163          	beqz	a0,80005a22 <exec+0x380>
    80005764:	ffce                	sd	s3,504(sp)
    80005766:	f7d6                	sd	s5,488(sp)
    80005768:	efde                	sd	s7,472(sp)
    8000576a:	ebe2                	sd	s8,464(sp)
    8000576c:	e7e6                	sd	s9,456(sp)
    8000576e:	e3ea                	sd	s10,448(sp)
    80005770:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005772:	e7042683          	lw	a3,-400(s0)
    80005776:	e8845783          	lhu	a5,-376(s0)
    8000577a:	10078363          	beqz	a5,80005880 <exec+0x1de>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000577e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005780:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005782:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80005786:	6c85                	lui	s9,0x1
    80005788:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000578c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005790:	6a85                	lui	s5,0x1
    80005792:	a0b5                	j	800057fe <exec+0x15c>
      panic("loadseg: address should exist");
    80005794:	00003517          	auipc	a0,0x3
    80005798:	e2450513          	addi	a0,a0,-476 # 800085b8 <etext+0x5b8>
    8000579c:	ffffb097          	auipc	ra,0xffffb
    800057a0:	dc4080e7          	jalr	-572(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800057a4:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800057a6:	874a                	mv	a4,s2
    800057a8:	009c06bb          	addw	a3,s8,s1
    800057ac:	4581                	li	a1,0
    800057ae:	8552                	mv	a0,s4
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	bea080e7          	jalr	-1046(ra) # 8000439a <readi>
    800057b8:	26a91963          	bne	s2,a0,80005a2a <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    800057bc:	009a84bb          	addw	s1,s5,s1
    800057c0:	0334f463          	bgeu	s1,s3,800057e8 <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    800057c4:	02049593          	slli	a1,s1,0x20
    800057c8:	9181                	srli	a1,a1,0x20
    800057ca:	95de                	add	a1,a1,s7
    800057cc:	855a                	mv	a0,s6
    800057ce:	ffffc097          	auipc	ra,0xffffc
    800057d2:	90a080e7          	jalr	-1782(ra) # 800010d8 <walkaddr>
    800057d6:	862a                	mv	a2,a0
    if(pa == 0)
    800057d8:	dd55                	beqz	a0,80005794 <exec+0xf2>
    if(sz - i < PGSIZE)
    800057da:	409987bb          	subw	a5,s3,s1
    800057de:	893e                	mv	s2,a5
    800057e0:	fcfcf2e3          	bgeu	s9,a5,800057a4 <exec+0x102>
    800057e4:	8956                	mv	s2,s5
    800057e6:	bf7d                	j	800057a4 <exec+0x102>
    sz = sz1;
    800057e8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057ec:	2d05                	addiw	s10,s10,1
    800057ee:	e0843783          	ld	a5,-504(s0)
    800057f2:	0387869b          	addiw	a3,a5,56
    800057f6:	e8845783          	lhu	a5,-376(s0)
    800057fa:	08fd5463          	bge	s10,a5,80005882 <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057fe:	e0d43423          	sd	a3,-504(s0)
    80005802:	876e                	mv	a4,s11
    80005804:	e1840613          	addi	a2,s0,-488
    80005808:	4581                	li	a1,0
    8000580a:	8552                	mv	a0,s4
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	b8e080e7          	jalr	-1138(ra) # 8000439a <readi>
    80005814:	21b51963          	bne	a0,s11,80005a26 <exec+0x384>
    if(ph.type != ELF_PROG_LOAD)
    80005818:	e1842783          	lw	a5,-488(s0)
    8000581c:	4705                	li	a4,1
    8000581e:	fce797e3          	bne	a5,a4,800057ec <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80005822:	e4043483          	ld	s1,-448(s0)
    80005826:	e3843783          	ld	a5,-456(s0)
    8000582a:	22f4e063          	bltu	s1,a5,80005a4a <exec+0x3a8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000582e:	e2843783          	ld	a5,-472(s0)
    80005832:	94be                	add	s1,s1,a5
    80005834:	20f4ee63          	bltu	s1,a5,80005a50 <exec+0x3ae>
    if(ph.vaddr % PGSIZE != 0)
    80005838:	de843703          	ld	a4,-536(s0)
    8000583c:	8ff9                	and	a5,a5,a4
    8000583e:	20079c63          	bnez	a5,80005a56 <exec+0x3b4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005842:	e1c42503          	lw	a0,-484(s0)
    80005846:	00000097          	auipc	ra,0x0
    8000584a:	e3c080e7          	jalr	-452(ra) # 80005682 <flags2perm>
    8000584e:	86aa                	mv	a3,a0
    80005850:	8626                	mv	a2,s1
    80005852:	85ca                	mv	a1,s2
    80005854:	855a                	mv	a0,s6
    80005856:	ffffc097          	auipc	ra,0xffffc
    8000585a:	c46080e7          	jalr	-954(ra) # 8000149c <uvmalloc>
    8000585e:	dea43c23          	sd	a0,-520(s0)
    80005862:	1e050d63          	beqz	a0,80005a5c <exec+0x3ba>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005866:	e2843b83          	ld	s7,-472(s0)
    8000586a:	e2042c03          	lw	s8,-480(s0)
    8000586e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005872:	00098463          	beqz	s3,8000587a <exec+0x1d8>
    80005876:	4481                	li	s1,0
    80005878:	b7b1                	j	800057c4 <exec+0x122>
    sz = sz1;
    8000587a:	df843903          	ld	s2,-520(s0)
    8000587e:	b7bd                	j	800057ec <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005880:	4901                	li	s2,0
  iunlockput(ip);
    80005882:	8552                	mv	a0,s4
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	ac0080e7          	jalr	-1344(ra) # 80004344 <iunlockput>
  end_op();
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	2b6080e7          	jalr	694(ra) # 80004b42 <end_op>
  p = myproc();
    80005894:	ffffc097          	auipc	ra,0xffffc
    80005898:	362080e7          	jalr	866(ra) # 80001bf6 <myproc>
    8000589c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000589e:	22053d03          	ld	s10,544(a0)
  sz = PGROUNDUP(sz);
    800058a2:	6985                	lui	s3,0x1
    800058a4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800058a6:	99ca                	add	s3,s3,s2
    800058a8:	77fd                	lui	a5,0xfffff
    800058aa:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800058ae:	4691                	li	a3,4
    800058b0:	6609                	lui	a2,0x2
    800058b2:	964e                	add	a2,a2,s3
    800058b4:	85ce                	mv	a1,s3
    800058b6:	855a                	mv	a0,s6
    800058b8:	ffffc097          	auipc	ra,0xffffc
    800058bc:	be4080e7          	jalr	-1052(ra) # 8000149c <uvmalloc>
    800058c0:	8a2a                	mv	s4,a0
    800058c2:	e115                	bnez	a0,800058e6 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    800058c4:	85ce                	mv	a1,s3
    800058c6:	855a                	mv	a0,s6
    800058c8:	ffffc097          	auipc	ra,0xffffc
    800058cc:	48e080e7          	jalr	1166(ra) # 80001d56 <proc_freepagetable>
  return -1;
    800058d0:	557d                	li	a0,-1
    800058d2:	79fe                	ld	s3,504(sp)
    800058d4:	7a5e                	ld	s4,496(sp)
    800058d6:	7abe                	ld	s5,488(sp)
    800058d8:	7b1e                	ld	s6,480(sp)
    800058da:	6bfe                	ld	s7,472(sp)
    800058dc:	6c5e                	ld	s8,464(sp)
    800058de:	6cbe                	ld	s9,456(sp)
    800058e0:	6d1e                	ld	s10,448(sp)
    800058e2:	7dfa                	ld	s11,440(sp)
    800058e4:	b5b1                	j	80005730 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058e6:	75f9                	lui	a1,0xffffe
    800058e8:	95aa                	add	a1,a1,a0
    800058ea:	855a                	mv	a0,s6
    800058ec:	ffffc097          	auipc	ra,0xffffc
    800058f0:	df2080e7          	jalr	-526(ra) # 800016de <uvmclear>
  stackbase = sp - PGSIZE;
    800058f4:	7bfd                	lui	s7,0xfffff
    800058f6:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    800058f8:	e0043783          	ld	a5,-512(s0)
    800058fc:	6388                	ld	a0,0(a5)
  sp = sz;
    800058fe:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005900:	4481                	li	s1,0
    ustack[argc] = sp;
    80005902:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005906:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000590a:	c135                	beqz	a0,8000596e <exec+0x2cc>
    sp -= strlen(argv[argc]) + 1;
    8000590c:	ffffb097          	auipc	ra,0xffffb
    80005910:	5b6080e7          	jalr	1462(ra) # 80000ec2 <strlen>
    80005914:	0015079b          	addiw	a5,a0,1
    80005918:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000591c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005920:	15796163          	bltu	s2,s7,80005a62 <exec+0x3c0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005924:	e0043d83          	ld	s11,-512(s0)
    80005928:	000db983          	ld	s3,0(s11)
    8000592c:	854e                	mv	a0,s3
    8000592e:	ffffb097          	auipc	ra,0xffffb
    80005932:	594080e7          	jalr	1428(ra) # 80000ec2 <strlen>
    80005936:	0015069b          	addiw	a3,a0,1
    8000593a:	864e                	mv	a2,s3
    8000593c:	85ca                	mv	a1,s2
    8000593e:	855a                	mv	a0,s6
    80005940:	ffffc097          	auipc	ra,0xffffc
    80005944:	dd0080e7          	jalr	-560(ra) # 80001710 <copyout>
    80005948:	10054f63          	bltz	a0,80005a66 <exec+0x3c4>
    ustack[argc] = sp;
    8000594c:	00349793          	slli	a5,s1,0x3
    80005950:	97e6                	add	a5,a5,s9
    80005952:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5080>
  for(argc = 0; argv[argc]; argc++) {
    80005956:	0485                	addi	s1,s1,1
    80005958:	008d8793          	addi	a5,s11,8
    8000595c:	e0f43023          	sd	a5,-512(s0)
    80005960:	008db503          	ld	a0,8(s11)
    80005964:	c509                	beqz	a0,8000596e <exec+0x2cc>
    if(argc >= MAXARG)
    80005966:	fb8493e3          	bne	s1,s8,8000590c <exec+0x26a>
  sz = sz1;
    8000596a:	89d2                	mv	s3,s4
    8000596c:	bfa1                	j	800058c4 <exec+0x222>
  ustack[argc] = 0;
    8000596e:	00349793          	slli	a5,s1,0x3
    80005972:	f9078793          	addi	a5,a5,-112
    80005976:	97a2                	add	a5,a5,s0
    80005978:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000597c:	00148693          	addi	a3,s1,1
    80005980:	068e                	slli	a3,a3,0x3
    80005982:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005986:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000598a:	89d2                	mv	s3,s4
  if(sp < stackbase)
    8000598c:	f3796ce3          	bltu	s2,s7,800058c4 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005990:	e9040613          	addi	a2,s0,-368
    80005994:	85ca                	mv	a1,s2
    80005996:	855a                	mv	a0,s6
    80005998:	ffffc097          	auipc	ra,0xffffc
    8000599c:	d78080e7          	jalr	-648(ra) # 80001710 <copyout>
    800059a0:	f20542e3          	bltz	a0,800058c4 <exec+0x222>
  p->trapframe->a1 = sp;
    800059a4:	230ab783          	ld	a5,560(s5) # 1230 <_entry-0x7fffedd0>
    800059a8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800059ac:	df043783          	ld	a5,-528(s0)
    800059b0:	0007c703          	lbu	a4,0(a5)
    800059b4:	cf11                	beqz	a4,800059d0 <exec+0x32e>
    800059b6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800059b8:	02f00693          	li	a3,47
    800059bc:	a029                	j	800059c6 <exec+0x324>
  for(last=s=path; *s; s++)
    800059be:	0785                	addi	a5,a5,1
    800059c0:	fff7c703          	lbu	a4,-1(a5)
    800059c4:	c711                	beqz	a4,800059d0 <exec+0x32e>
    if(*s == '/')
    800059c6:	fed71ce3          	bne	a4,a3,800059be <exec+0x31c>
      last = s+1;
    800059ca:	def43823          	sd	a5,-528(s0)
    800059ce:	bfc5                	j	800059be <exec+0x31c>
  safestrcpy(p->name, last, sizeof(p->name));
    800059d0:	4641                	li	a2,16
    800059d2:	df043583          	ld	a1,-528(s0)
    800059d6:	330a8513          	addi	a0,s5,816
    800059da:	ffffb097          	auipc	ra,0xffffb
    800059de:	4b2080e7          	jalr	1202(ra) # 80000e8c <safestrcpy>
  oldpagetable = p->pagetable;
    800059e2:	228ab503          	ld	a0,552(s5)
  p->pagetable = pagetable;
    800059e6:	236ab423          	sd	s6,552(s5)
  p->sz = sz;
    800059ea:	234ab023          	sd	s4,544(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800059ee:	230ab783          	ld	a5,560(s5)
    800059f2:	e6843703          	ld	a4,-408(s0)
    800059f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800059f8:	230ab783          	ld	a5,560(s5)
    800059fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005a00:	85ea                	mv	a1,s10
    80005a02:	ffffc097          	auipc	ra,0xffffc
    80005a06:	354080e7          	jalr	852(ra) # 80001d56 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005a0a:	0004851b          	sext.w	a0,s1
    80005a0e:	79fe                	ld	s3,504(sp)
    80005a10:	7a5e                	ld	s4,496(sp)
    80005a12:	7abe                	ld	s5,488(sp)
    80005a14:	7b1e                	ld	s6,480(sp)
    80005a16:	6bfe                	ld	s7,472(sp)
    80005a18:	6c5e                	ld	s8,464(sp)
    80005a1a:	6cbe                	ld	s9,456(sp)
    80005a1c:	6d1e                	ld	s10,448(sp)
    80005a1e:	7dfa                	ld	s11,440(sp)
    80005a20:	bb01                	j	80005730 <exec+0x8e>
    80005a22:	7b1e                	ld	s6,480(sp)
    80005a24:	b9dd                	j	8000571a <exec+0x78>
    80005a26:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005a2a:	df843583          	ld	a1,-520(s0)
    80005a2e:	855a                	mv	a0,s6
    80005a30:	ffffc097          	auipc	ra,0xffffc
    80005a34:	326080e7          	jalr	806(ra) # 80001d56 <proc_freepagetable>
  if(ip){
    80005a38:	79fe                	ld	s3,504(sp)
    80005a3a:	7abe                	ld	s5,488(sp)
    80005a3c:	7b1e                	ld	s6,480(sp)
    80005a3e:	6bfe                	ld	s7,472(sp)
    80005a40:	6c5e                	ld	s8,464(sp)
    80005a42:	6cbe                	ld	s9,456(sp)
    80005a44:	6d1e                	ld	s10,448(sp)
    80005a46:	7dfa                	ld	s11,440(sp)
    80005a48:	b9c9                	j	8000571a <exec+0x78>
    80005a4a:	df243c23          	sd	s2,-520(s0)
    80005a4e:	bff1                	j	80005a2a <exec+0x388>
    80005a50:	df243c23          	sd	s2,-520(s0)
    80005a54:	bfd9                	j	80005a2a <exec+0x388>
    80005a56:	df243c23          	sd	s2,-520(s0)
    80005a5a:	bfc1                	j	80005a2a <exec+0x388>
    80005a5c:	df243c23          	sd	s2,-520(s0)
    80005a60:	b7e9                	j	80005a2a <exec+0x388>
  sz = sz1;
    80005a62:	89d2                	mv	s3,s4
    80005a64:	b585                	j	800058c4 <exec+0x222>
    80005a66:	89d2                	mv	s3,s4
    80005a68:	bdb1                	j	800058c4 <exec+0x222>

0000000080005a6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a6a:	7179                	addi	sp,sp,-48
    80005a6c:	f406                	sd	ra,40(sp)
    80005a6e:	f022                	sd	s0,32(sp)
    80005a70:	ec26                	sd	s1,24(sp)
    80005a72:	e84a                	sd	s2,16(sp)
    80005a74:	1800                	addi	s0,sp,48
    80005a76:	892e                	mv	s2,a1
    80005a78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a7a:	fdc40593          	addi	a1,s0,-36
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	946080e7          	jalr	-1722(ra) # 800033c4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a86:	fdc42703          	lw	a4,-36(s0)
    80005a8a:	47bd                	li	a5,15
    80005a8c:	02e7eb63          	bltu	a5,a4,80005ac2 <argfd+0x58>
    80005a90:	ffffc097          	auipc	ra,0xffffc
    80005a94:	166080e7          	jalr	358(ra) # 80001bf6 <myproc>
    80005a98:	fdc42703          	lw	a4,-36(s0)
    80005a9c:	05470793          	addi	a5,a4,84
    80005aa0:	078e                	slli	a5,a5,0x3
    80005aa2:	953e                	add	a0,a0,a5
    80005aa4:	651c                	ld	a5,8(a0)
    80005aa6:	c385                	beqz	a5,80005ac6 <argfd+0x5c>
    return -1;
  if(pfd)
    80005aa8:	00090463          	beqz	s2,80005ab0 <argfd+0x46>
    *pfd = fd;
    80005aac:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005ab0:	4501                	li	a0,0
  if(pf)
    80005ab2:	c091                	beqz	s1,80005ab6 <argfd+0x4c>
    *pf = f;
    80005ab4:	e09c                	sd	a5,0(s1)
}
    80005ab6:	70a2                	ld	ra,40(sp)
    80005ab8:	7402                	ld	s0,32(sp)
    80005aba:	64e2                	ld	s1,24(sp)
    80005abc:	6942                	ld	s2,16(sp)
    80005abe:	6145                	addi	sp,sp,48
    80005ac0:	8082                	ret
    return -1;
    80005ac2:	557d                	li	a0,-1
    80005ac4:	bfcd                	j	80005ab6 <argfd+0x4c>
    80005ac6:	557d                	li	a0,-1
    80005ac8:	b7fd                	j	80005ab6 <argfd+0x4c>

0000000080005aca <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005aca:	1101                	addi	sp,sp,-32
    80005acc:	ec06                	sd	ra,24(sp)
    80005ace:	e822                	sd	s0,16(sp)
    80005ad0:	e426                	sd	s1,8(sp)
    80005ad2:	1000                	addi	s0,sp,32
    80005ad4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	120080e7          	jalr	288(ra) # 80001bf6 <myproc>
    80005ade:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ae0:	2a850793          	addi	a5,a0,680
    80005ae4:	4501                	li	a0,0
    80005ae6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ae8:	6398                	ld	a4,0(a5)
    80005aea:	cb19                	beqz	a4,80005b00 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005aec:	2505                	addiw	a0,a0,1
    80005aee:	07a1                	addi	a5,a5,8
    80005af0:	fed51ce3          	bne	a0,a3,80005ae8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005af4:	557d                	li	a0,-1
}
    80005af6:	60e2                	ld	ra,24(sp)
    80005af8:	6442                	ld	s0,16(sp)
    80005afa:	64a2                	ld	s1,8(sp)
    80005afc:	6105                	addi	sp,sp,32
    80005afe:	8082                	ret
      p->ofile[fd] = f;
    80005b00:	05450793          	addi	a5,a0,84
    80005b04:	078e                	slli	a5,a5,0x3
    80005b06:	963e                	add	a2,a2,a5
    80005b08:	e604                	sd	s1,8(a2)
      return fd;
    80005b0a:	b7f5                	j	80005af6 <fdalloc+0x2c>

0000000080005b0c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005b0c:	715d                	addi	sp,sp,-80
    80005b0e:	e486                	sd	ra,72(sp)
    80005b10:	e0a2                	sd	s0,64(sp)
    80005b12:	fc26                	sd	s1,56(sp)
    80005b14:	f84a                	sd	s2,48(sp)
    80005b16:	f44e                	sd	s3,40(sp)
    80005b18:	ec56                	sd	s5,24(sp)
    80005b1a:	e85a                	sd	s6,16(sp)
    80005b1c:	0880                	addi	s0,sp,80
    80005b1e:	8b2e                	mv	s6,a1
    80005b20:	89b2                	mv	s3,a2
    80005b22:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005b24:	fb040593          	addi	a1,s0,-80
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	db8080e7          	jalr	-584(ra) # 800048e0 <nameiparent>
    80005b30:	84aa                	mv	s1,a0
    80005b32:	14050e63          	beqz	a0,80005c8e <create+0x182>
    return 0;

  ilock(dp);
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	5a8080e7          	jalr	1448(ra) # 800040de <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005b3e:	4601                	li	a2,0
    80005b40:	fb040593          	addi	a1,s0,-80
    80005b44:	8526                	mv	a0,s1
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	a94080e7          	jalr	-1388(ra) # 800045da <dirlookup>
    80005b4e:	8aaa                	mv	s5,a0
    80005b50:	c539                	beqz	a0,80005b9e <create+0x92>
    iunlockput(dp);
    80005b52:	8526                	mv	a0,s1
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	7f0080e7          	jalr	2032(ra) # 80004344 <iunlockput>
    ilock(ip);
    80005b5c:	8556                	mv	a0,s5
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	580080e7          	jalr	1408(ra) # 800040de <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b66:	4789                	li	a5,2
    80005b68:	02fb1463          	bne	s6,a5,80005b90 <create+0x84>
    80005b6c:	044ad783          	lhu	a5,68(s5)
    80005b70:	37f9                	addiw	a5,a5,-2
    80005b72:	17c2                	slli	a5,a5,0x30
    80005b74:	93c1                	srli	a5,a5,0x30
    80005b76:	4705                	li	a4,1
    80005b78:	00f76c63          	bltu	a4,a5,80005b90 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b7c:	8556                	mv	a0,s5
    80005b7e:	60a6                	ld	ra,72(sp)
    80005b80:	6406                	ld	s0,64(sp)
    80005b82:	74e2                	ld	s1,56(sp)
    80005b84:	7942                	ld	s2,48(sp)
    80005b86:	79a2                	ld	s3,40(sp)
    80005b88:	6ae2                	ld	s5,24(sp)
    80005b8a:	6b42                	ld	s6,16(sp)
    80005b8c:	6161                	addi	sp,sp,80
    80005b8e:	8082                	ret
    iunlockput(ip);
    80005b90:	8556                	mv	a0,s5
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	7b2080e7          	jalr	1970(ra) # 80004344 <iunlockput>
    return 0;
    80005b9a:	4a81                	li	s5,0
    80005b9c:	b7c5                	j	80005b7c <create+0x70>
    80005b9e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005ba0:	85da                	mv	a1,s6
    80005ba2:	4088                	lw	a0,0(s1)
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	396080e7          	jalr	918(ra) # 80003f3a <ialloc>
    80005bac:	8a2a                	mv	s4,a0
    80005bae:	c531                	beqz	a0,80005bfa <create+0xee>
  ilock(ip);
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	52e080e7          	jalr	1326(ra) # 800040de <ilock>
  ip->major = major;
    80005bb8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005bbc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005bc0:	4905                	li	s2,1
    80005bc2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005bc6:	8552                	mv	a0,s4
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	44a080e7          	jalr	1098(ra) # 80004012 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005bd0:	032b0d63          	beq	s6,s2,80005c0a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bd4:	004a2603          	lw	a2,4(s4)
    80005bd8:	fb040593          	addi	a1,s0,-80
    80005bdc:	8526                	mv	a0,s1
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	c22080e7          	jalr	-990(ra) # 80004800 <dirlink>
    80005be6:	08054163          	bltz	a0,80005c68 <create+0x15c>
  iunlockput(dp);
    80005bea:	8526                	mv	a0,s1
    80005bec:	ffffe097          	auipc	ra,0xffffe
    80005bf0:	758080e7          	jalr	1880(ra) # 80004344 <iunlockput>
  return ip;
    80005bf4:	8ad2                	mv	s5,s4
    80005bf6:	7a02                	ld	s4,32(sp)
    80005bf8:	b751                	j	80005b7c <create+0x70>
    iunlockput(dp);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	748080e7          	jalr	1864(ra) # 80004344 <iunlockput>
    return 0;
    80005c04:	8ad2                	mv	s5,s4
    80005c06:	7a02                	ld	s4,32(sp)
    80005c08:	bf95                	j	80005b7c <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005c0a:	004a2603          	lw	a2,4(s4)
    80005c0e:	00003597          	auipc	a1,0x3
    80005c12:	9ca58593          	addi	a1,a1,-1590 # 800085d8 <etext+0x5d8>
    80005c16:	8552                	mv	a0,s4
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	be8080e7          	jalr	-1048(ra) # 80004800 <dirlink>
    80005c20:	04054463          	bltz	a0,80005c68 <create+0x15c>
    80005c24:	40d0                	lw	a2,4(s1)
    80005c26:	00003597          	auipc	a1,0x3
    80005c2a:	9ba58593          	addi	a1,a1,-1606 # 800085e0 <etext+0x5e0>
    80005c2e:	8552                	mv	a0,s4
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	bd0080e7          	jalr	-1072(ra) # 80004800 <dirlink>
    80005c38:	02054863          	bltz	a0,80005c68 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c3c:	004a2603          	lw	a2,4(s4)
    80005c40:	fb040593          	addi	a1,s0,-80
    80005c44:	8526                	mv	a0,s1
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	bba080e7          	jalr	-1094(ra) # 80004800 <dirlink>
    80005c4e:	00054d63          	bltz	a0,80005c68 <create+0x15c>
    dp->nlink++;  // for ".."
    80005c52:	04a4d783          	lhu	a5,74(s1)
    80005c56:	2785                	addiw	a5,a5,1
    80005c58:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c5c:	8526                	mv	a0,s1
    80005c5e:	ffffe097          	auipc	ra,0xffffe
    80005c62:	3b4080e7          	jalr	948(ra) # 80004012 <iupdate>
    80005c66:	b751                	j	80005bea <create+0xde>
  ip->nlink = 0;
    80005c68:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005c6c:	8552                	mv	a0,s4
    80005c6e:	ffffe097          	auipc	ra,0xffffe
    80005c72:	3a4080e7          	jalr	932(ra) # 80004012 <iupdate>
  iunlockput(ip);
    80005c76:	8552                	mv	a0,s4
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	6cc080e7          	jalr	1740(ra) # 80004344 <iunlockput>
  iunlockput(dp);
    80005c80:	8526                	mv	a0,s1
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	6c2080e7          	jalr	1730(ra) # 80004344 <iunlockput>
  return 0;
    80005c8a:	7a02                	ld	s4,32(sp)
    80005c8c:	bdc5                	j	80005b7c <create+0x70>
    return 0;
    80005c8e:	8aaa                	mv	s5,a0
    80005c90:	b5f5                	j	80005b7c <create+0x70>

0000000080005c92 <sys_dup>:
{
    80005c92:	7179                	addi	sp,sp,-48
    80005c94:	f406                	sd	ra,40(sp)
    80005c96:	f022                	sd	s0,32(sp)
    80005c98:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c9a:	fd840613          	addi	a2,s0,-40
    80005c9e:	4581                	li	a1,0
    80005ca0:	4501                	li	a0,0
    80005ca2:	00000097          	auipc	ra,0x0
    80005ca6:	dc8080e7          	jalr	-568(ra) # 80005a6a <argfd>
    return -1;
    80005caa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005cac:	02054763          	bltz	a0,80005cda <sys_dup+0x48>
    80005cb0:	ec26                	sd	s1,24(sp)
    80005cb2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005cb4:	fd843903          	ld	s2,-40(s0)
    80005cb8:	854a                	mv	a0,s2
    80005cba:	00000097          	auipc	ra,0x0
    80005cbe:	e10080e7          	jalr	-496(ra) # 80005aca <fdalloc>
    80005cc2:	84aa                	mv	s1,a0
    return -1;
    80005cc4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005cc6:	00054f63          	bltz	a0,80005ce4 <sys_dup+0x52>
  filedup(f);
    80005cca:	854a                	mv	a0,s2
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	27a080e7          	jalr	634(ra) # 80004f46 <filedup>
  return fd;
    80005cd4:	87a6                	mv	a5,s1
    80005cd6:	64e2                	ld	s1,24(sp)
    80005cd8:	6942                	ld	s2,16(sp)
}
    80005cda:	853e                	mv	a0,a5
    80005cdc:	70a2                	ld	ra,40(sp)
    80005cde:	7402                	ld	s0,32(sp)
    80005ce0:	6145                	addi	sp,sp,48
    80005ce2:	8082                	ret
    80005ce4:	64e2                	ld	s1,24(sp)
    80005ce6:	6942                	ld	s2,16(sp)
    80005ce8:	bfcd                	j	80005cda <sys_dup+0x48>

0000000080005cea <sys_read>:
{
    80005cea:	7179                	addi	sp,sp,-48
    80005cec:	f406                	sd	ra,40(sp)
    80005cee:	f022                	sd	s0,32(sp)
    80005cf0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005cf2:	fd840593          	addi	a1,s0,-40
    80005cf6:	4505                	li	a0,1
    80005cf8:	ffffd097          	auipc	ra,0xffffd
    80005cfc:	6ec080e7          	jalr	1772(ra) # 800033e4 <argaddr>
  argint(2, &n);
    80005d00:	fe440593          	addi	a1,s0,-28
    80005d04:	4509                	li	a0,2
    80005d06:	ffffd097          	auipc	ra,0xffffd
    80005d0a:	6be080e7          	jalr	1726(ra) # 800033c4 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d0e:	fe840613          	addi	a2,s0,-24
    80005d12:	4581                	li	a1,0
    80005d14:	4501                	li	a0,0
    80005d16:	00000097          	auipc	ra,0x0
    80005d1a:	d54080e7          	jalr	-684(ra) # 80005a6a <argfd>
    80005d1e:	87aa                	mv	a5,a0
    return -1;
    80005d20:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d22:	0007cc63          	bltz	a5,80005d3a <sys_read+0x50>
  return fileread(f, p, n);
    80005d26:	fe442603          	lw	a2,-28(s0)
    80005d2a:	fd843583          	ld	a1,-40(s0)
    80005d2e:	fe843503          	ld	a0,-24(s0)
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	3ba080e7          	jalr	954(ra) # 800050ec <fileread>
}
    80005d3a:	70a2                	ld	ra,40(sp)
    80005d3c:	7402                	ld	s0,32(sp)
    80005d3e:	6145                	addi	sp,sp,48
    80005d40:	8082                	ret

0000000080005d42 <sys_write>:
{
    80005d42:	7179                	addi	sp,sp,-48
    80005d44:	f406                	sd	ra,40(sp)
    80005d46:	f022                	sd	s0,32(sp)
    80005d48:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d4a:	fd840593          	addi	a1,s0,-40
    80005d4e:	4505                	li	a0,1
    80005d50:	ffffd097          	auipc	ra,0xffffd
    80005d54:	694080e7          	jalr	1684(ra) # 800033e4 <argaddr>
  argint(2, &n);
    80005d58:	fe440593          	addi	a1,s0,-28
    80005d5c:	4509                	li	a0,2
    80005d5e:	ffffd097          	auipc	ra,0xffffd
    80005d62:	666080e7          	jalr	1638(ra) # 800033c4 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d66:	fe840613          	addi	a2,s0,-24
    80005d6a:	4581                	li	a1,0
    80005d6c:	4501                	li	a0,0
    80005d6e:	00000097          	auipc	ra,0x0
    80005d72:	cfc080e7          	jalr	-772(ra) # 80005a6a <argfd>
    80005d76:	87aa                	mv	a5,a0
    return -1;
    80005d78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d7a:	0007cc63          	bltz	a5,80005d92 <sys_write+0x50>
  return filewrite(f, p, n);
    80005d7e:	fe442603          	lw	a2,-28(s0)
    80005d82:	fd843583          	ld	a1,-40(s0)
    80005d86:	fe843503          	ld	a0,-24(s0)
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	434080e7          	jalr	1076(ra) # 800051be <filewrite>
}
    80005d92:	70a2                	ld	ra,40(sp)
    80005d94:	7402                	ld	s0,32(sp)
    80005d96:	6145                	addi	sp,sp,48
    80005d98:	8082                	ret

0000000080005d9a <sys_close>:
{
    80005d9a:	1101                	addi	sp,sp,-32
    80005d9c:	ec06                	sd	ra,24(sp)
    80005d9e:	e822                	sd	s0,16(sp)
    80005da0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005da2:	fe040613          	addi	a2,s0,-32
    80005da6:	fec40593          	addi	a1,s0,-20
    80005daa:	4501                	li	a0,0
    80005dac:	00000097          	auipc	ra,0x0
    80005db0:	cbe080e7          	jalr	-834(ra) # 80005a6a <argfd>
    return -1;
    80005db4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005db6:	02054563          	bltz	a0,80005de0 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005dba:	ffffc097          	auipc	ra,0xffffc
    80005dbe:	e3c080e7          	jalr	-452(ra) # 80001bf6 <myproc>
    80005dc2:	fec42783          	lw	a5,-20(s0)
    80005dc6:	05478793          	addi	a5,a5,84
    80005dca:	078e                	slli	a5,a5,0x3
    80005dcc:	953e                	add	a0,a0,a5
    80005dce:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005dd2:	fe043503          	ld	a0,-32(s0)
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	1c2080e7          	jalr	450(ra) # 80004f98 <fileclose>
  return 0;
    80005dde:	4781                	li	a5,0
}
    80005de0:	853e                	mv	a0,a5
    80005de2:	60e2                	ld	ra,24(sp)
    80005de4:	6442                	ld	s0,16(sp)
    80005de6:	6105                	addi	sp,sp,32
    80005de8:	8082                	ret

0000000080005dea <sys_fstat>:
{
    80005dea:	1101                	addi	sp,sp,-32
    80005dec:	ec06                	sd	ra,24(sp)
    80005dee:	e822                	sd	s0,16(sp)
    80005df0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005df2:	fe040593          	addi	a1,s0,-32
    80005df6:	4505                	li	a0,1
    80005df8:	ffffd097          	auipc	ra,0xffffd
    80005dfc:	5ec080e7          	jalr	1516(ra) # 800033e4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005e00:	fe840613          	addi	a2,s0,-24
    80005e04:	4581                	li	a1,0
    80005e06:	4501                	li	a0,0
    80005e08:	00000097          	auipc	ra,0x0
    80005e0c:	c62080e7          	jalr	-926(ra) # 80005a6a <argfd>
    80005e10:	87aa                	mv	a5,a0
    return -1;
    80005e12:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e14:	0007ca63          	bltz	a5,80005e28 <sys_fstat+0x3e>
  return filestat(f, st);
    80005e18:	fe043583          	ld	a1,-32(s0)
    80005e1c:	fe843503          	ld	a0,-24(s0)
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	256080e7          	jalr	598(ra) # 80005076 <filestat>
}
    80005e28:	60e2                	ld	ra,24(sp)
    80005e2a:	6442                	ld	s0,16(sp)
    80005e2c:	6105                	addi	sp,sp,32
    80005e2e:	8082                	ret

0000000080005e30 <sys_link>:
{
    80005e30:	7169                	addi	sp,sp,-304
    80005e32:	f606                	sd	ra,296(sp)
    80005e34:	f222                	sd	s0,288(sp)
    80005e36:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e38:	08000613          	li	a2,128
    80005e3c:	ed040593          	addi	a1,s0,-304
    80005e40:	4501                	li	a0,0
    80005e42:	ffffd097          	auipc	ra,0xffffd
    80005e46:	5c2080e7          	jalr	1474(ra) # 80003404 <argstr>
    return -1;
    80005e4a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e4c:	12054663          	bltz	a0,80005f78 <sys_link+0x148>
    80005e50:	08000613          	li	a2,128
    80005e54:	f5040593          	addi	a1,s0,-176
    80005e58:	4505                	li	a0,1
    80005e5a:	ffffd097          	auipc	ra,0xffffd
    80005e5e:	5aa080e7          	jalr	1450(ra) # 80003404 <argstr>
    return -1;
    80005e62:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e64:	10054a63          	bltz	a0,80005f78 <sys_link+0x148>
    80005e68:	ee26                	sd	s1,280(sp)
  begin_op();
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	c5e080e7          	jalr	-930(ra) # 80004ac8 <begin_op>
  if((ip = namei(old)) == 0){
    80005e72:	ed040513          	addi	a0,s0,-304
    80005e76:	fffff097          	auipc	ra,0xfffff
    80005e7a:	a4c080e7          	jalr	-1460(ra) # 800048c2 <namei>
    80005e7e:	84aa                	mv	s1,a0
    80005e80:	c949                	beqz	a0,80005f12 <sys_link+0xe2>
  ilock(ip);
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	25c080e7          	jalr	604(ra) # 800040de <ilock>
  if(ip->type == T_DIR){
    80005e8a:	04449703          	lh	a4,68(s1)
    80005e8e:	4785                	li	a5,1
    80005e90:	08f70863          	beq	a4,a5,80005f20 <sys_link+0xf0>
    80005e94:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005e96:	04a4d783          	lhu	a5,74(s1)
    80005e9a:	2785                	addiw	a5,a5,1
    80005e9c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ea0:	8526                	mv	a0,s1
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	170080e7          	jalr	368(ra) # 80004012 <iupdate>
  iunlock(ip);
    80005eaa:	8526                	mv	a0,s1
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	2f8080e7          	jalr	760(ra) # 800041a4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005eb4:	fd040593          	addi	a1,s0,-48
    80005eb8:	f5040513          	addi	a0,s0,-176
    80005ebc:	fffff097          	auipc	ra,0xfffff
    80005ec0:	a24080e7          	jalr	-1500(ra) # 800048e0 <nameiparent>
    80005ec4:	892a                	mv	s2,a0
    80005ec6:	cd35                	beqz	a0,80005f42 <sys_link+0x112>
  ilock(dp);
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	216080e7          	jalr	534(ra) # 800040de <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005ed0:	00092703          	lw	a4,0(s2)
    80005ed4:	409c                	lw	a5,0(s1)
    80005ed6:	06f71163          	bne	a4,a5,80005f38 <sys_link+0x108>
    80005eda:	40d0                	lw	a2,4(s1)
    80005edc:	fd040593          	addi	a1,s0,-48
    80005ee0:	854a                	mv	a0,s2
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	91e080e7          	jalr	-1762(ra) # 80004800 <dirlink>
    80005eea:	04054763          	bltz	a0,80005f38 <sys_link+0x108>
  iunlockput(dp);
    80005eee:	854a                	mv	a0,s2
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	454080e7          	jalr	1108(ra) # 80004344 <iunlockput>
  iput(ip);
    80005ef8:	8526                	mv	a0,s1
    80005efa:	ffffe097          	auipc	ra,0xffffe
    80005efe:	3a2080e7          	jalr	930(ra) # 8000429c <iput>
  end_op();
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	c40080e7          	jalr	-960(ra) # 80004b42 <end_op>
  return 0;
    80005f0a:	4781                	li	a5,0
    80005f0c:	64f2                	ld	s1,280(sp)
    80005f0e:	6952                	ld	s2,272(sp)
    80005f10:	a0a5                	j	80005f78 <sys_link+0x148>
    end_op();
    80005f12:	fffff097          	auipc	ra,0xfffff
    80005f16:	c30080e7          	jalr	-976(ra) # 80004b42 <end_op>
    return -1;
    80005f1a:	57fd                	li	a5,-1
    80005f1c:	64f2                	ld	s1,280(sp)
    80005f1e:	a8a9                	j	80005f78 <sys_link+0x148>
    iunlockput(ip);
    80005f20:	8526                	mv	a0,s1
    80005f22:	ffffe097          	auipc	ra,0xffffe
    80005f26:	422080e7          	jalr	1058(ra) # 80004344 <iunlockput>
    end_op();
    80005f2a:	fffff097          	auipc	ra,0xfffff
    80005f2e:	c18080e7          	jalr	-1000(ra) # 80004b42 <end_op>
    return -1;
    80005f32:	57fd                	li	a5,-1
    80005f34:	64f2                	ld	s1,280(sp)
    80005f36:	a089                	j	80005f78 <sys_link+0x148>
    iunlockput(dp);
    80005f38:	854a                	mv	a0,s2
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	40a080e7          	jalr	1034(ra) # 80004344 <iunlockput>
  ilock(ip);
    80005f42:	8526                	mv	a0,s1
    80005f44:	ffffe097          	auipc	ra,0xffffe
    80005f48:	19a080e7          	jalr	410(ra) # 800040de <ilock>
  ip->nlink--;
    80005f4c:	04a4d783          	lhu	a5,74(s1)
    80005f50:	37fd                	addiw	a5,a5,-1
    80005f52:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f56:	8526                	mv	a0,s1
    80005f58:	ffffe097          	auipc	ra,0xffffe
    80005f5c:	0ba080e7          	jalr	186(ra) # 80004012 <iupdate>
  iunlockput(ip);
    80005f60:	8526                	mv	a0,s1
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	3e2080e7          	jalr	994(ra) # 80004344 <iunlockput>
  end_op();
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	bd8080e7          	jalr	-1064(ra) # 80004b42 <end_op>
  return -1;
    80005f72:	57fd                	li	a5,-1
    80005f74:	64f2                	ld	s1,280(sp)
    80005f76:	6952                	ld	s2,272(sp)
}
    80005f78:	853e                	mv	a0,a5
    80005f7a:	70b2                	ld	ra,296(sp)
    80005f7c:	7412                	ld	s0,288(sp)
    80005f7e:	6155                	addi	sp,sp,304
    80005f80:	8082                	ret

0000000080005f82 <sys_unlink>:
{
    80005f82:	7111                	addi	sp,sp,-256
    80005f84:	fd86                	sd	ra,248(sp)
    80005f86:	f9a2                	sd	s0,240(sp)
    80005f88:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80005f8a:	08000613          	li	a2,128
    80005f8e:	f2040593          	addi	a1,s0,-224
    80005f92:	4501                	li	a0,0
    80005f94:	ffffd097          	auipc	ra,0xffffd
    80005f98:	470080e7          	jalr	1136(ra) # 80003404 <argstr>
    80005f9c:	1c054063          	bltz	a0,8000615c <sys_unlink+0x1da>
    80005fa0:	f5a6                	sd	s1,232(sp)
  begin_op();
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	b26080e7          	jalr	-1242(ra) # 80004ac8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005faa:	fa040593          	addi	a1,s0,-96
    80005fae:	f2040513          	addi	a0,s0,-224
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	92e080e7          	jalr	-1746(ra) # 800048e0 <nameiparent>
    80005fba:	84aa                	mv	s1,a0
    80005fbc:	c165                	beqz	a0,8000609c <sys_unlink+0x11a>
  ilock(dp);
    80005fbe:	ffffe097          	auipc	ra,0xffffe
    80005fc2:	120080e7          	jalr	288(ra) # 800040de <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005fc6:	00002597          	auipc	a1,0x2
    80005fca:	61258593          	addi	a1,a1,1554 # 800085d8 <etext+0x5d8>
    80005fce:	fa040513          	addi	a0,s0,-96
    80005fd2:	ffffe097          	auipc	ra,0xffffe
    80005fd6:	5ee080e7          	jalr	1518(ra) # 800045c0 <namecmp>
    80005fda:	16050263          	beqz	a0,8000613e <sys_unlink+0x1bc>
    80005fde:	00002597          	auipc	a1,0x2
    80005fe2:	60258593          	addi	a1,a1,1538 # 800085e0 <etext+0x5e0>
    80005fe6:	fa040513          	addi	a0,s0,-96
    80005fea:	ffffe097          	auipc	ra,0xffffe
    80005fee:	5d6080e7          	jalr	1494(ra) # 800045c0 <namecmp>
    80005ff2:	14050663          	beqz	a0,8000613e <sys_unlink+0x1bc>
    80005ff6:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ff8:	f1c40613          	addi	a2,s0,-228
    80005ffc:	fa040593          	addi	a1,s0,-96
    80006000:	8526                	mv	a0,s1
    80006002:	ffffe097          	auipc	ra,0xffffe
    80006006:	5d8080e7          	jalr	1496(ra) # 800045da <dirlookup>
    8000600a:	892a                	mv	s2,a0
    8000600c:	12050863          	beqz	a0,8000613c <sys_unlink+0x1ba>
    80006010:	edce                	sd	s3,216(sp)
  ilock(ip);
    80006012:	ffffe097          	auipc	ra,0xffffe
    80006016:	0cc080e7          	jalr	204(ra) # 800040de <ilock>
  if(ip->nlink < 1)
    8000601a:	04a91783          	lh	a5,74(s2)
    8000601e:	08f05663          	blez	a5,800060aa <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006022:	04491703          	lh	a4,68(s2)
    80006026:	4785                	li	a5,1
    80006028:	08f70b63          	beq	a4,a5,800060be <sys_unlink+0x13c>
  memset(&de, 0, sizeof(de));
    8000602c:	fb040993          	addi	s3,s0,-80
    80006030:	4641                	li	a2,16
    80006032:	4581                	li	a1,0
    80006034:	854e                	mv	a0,s3
    80006036:	ffffb097          	auipc	ra,0xffffb
    8000603a:	d00080e7          	jalr	-768(ra) # 80000d36 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000603e:	4741                	li	a4,16
    80006040:	f1c42683          	lw	a3,-228(s0)
    80006044:	864e                	mv	a2,s3
    80006046:	4581                	li	a1,0
    80006048:	8526                	mv	a0,s1
    8000604a:	ffffe097          	auipc	ra,0xffffe
    8000604e:	456080e7          	jalr	1110(ra) # 800044a0 <writei>
    80006052:	47c1                	li	a5,16
    80006054:	0af51f63          	bne	a0,a5,80006112 <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80006058:	04491703          	lh	a4,68(s2)
    8000605c:	4785                	li	a5,1
    8000605e:	0cf70463          	beq	a4,a5,80006126 <sys_unlink+0x1a4>
  iunlockput(dp);
    80006062:	8526                	mv	a0,s1
    80006064:	ffffe097          	auipc	ra,0xffffe
    80006068:	2e0080e7          	jalr	736(ra) # 80004344 <iunlockput>
  ip->nlink--;
    8000606c:	04a95783          	lhu	a5,74(s2)
    80006070:	37fd                	addiw	a5,a5,-1
    80006072:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006076:	854a                	mv	a0,s2
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	f9a080e7          	jalr	-102(ra) # 80004012 <iupdate>
  iunlockput(ip);
    80006080:	854a                	mv	a0,s2
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	2c2080e7          	jalr	706(ra) # 80004344 <iunlockput>
  end_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	ab8080e7          	jalr	-1352(ra) # 80004b42 <end_op>
  return 0;
    80006092:	4501                	li	a0,0
    80006094:	74ae                	ld	s1,232(sp)
    80006096:	790e                	ld	s2,224(sp)
    80006098:	69ee                	ld	s3,216(sp)
    8000609a:	a86d                	j	80006154 <sys_unlink+0x1d2>
    end_op();
    8000609c:	fffff097          	auipc	ra,0xfffff
    800060a0:	aa6080e7          	jalr	-1370(ra) # 80004b42 <end_op>
    return -1;
    800060a4:	557d                	li	a0,-1
    800060a6:	74ae                	ld	s1,232(sp)
    800060a8:	a075                	j	80006154 <sys_unlink+0x1d2>
    800060aa:	e9d2                	sd	s4,208(sp)
    800060ac:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    800060ae:	00002517          	auipc	a0,0x2
    800060b2:	53a50513          	addi	a0,a0,1338 # 800085e8 <etext+0x5e8>
    800060b6:	ffffa097          	auipc	ra,0xffffa
    800060ba:	4aa080e7          	jalr	1194(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060be:	04c92703          	lw	a4,76(s2)
    800060c2:	02000793          	li	a5,32
    800060c6:	f6e7f3e3          	bgeu	a5,a4,8000602c <sys_unlink+0xaa>
    800060ca:	e9d2                	sd	s4,208(sp)
    800060cc:	e5d6                	sd	s5,200(sp)
    800060ce:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800060d0:	f0840a93          	addi	s5,s0,-248
    800060d4:	4a41                	li	s4,16
    800060d6:	8752                	mv	a4,s4
    800060d8:	86ce                	mv	a3,s3
    800060da:	8656                	mv	a2,s5
    800060dc:	4581                	li	a1,0
    800060de:	854a                	mv	a0,s2
    800060e0:	ffffe097          	auipc	ra,0xffffe
    800060e4:	2ba080e7          	jalr	698(ra) # 8000439a <readi>
    800060e8:	01451d63          	bne	a0,s4,80006102 <sys_unlink+0x180>
    if(de.inum != 0)
    800060ec:	f0845783          	lhu	a5,-248(s0)
    800060f0:	eba5                	bnez	a5,80006160 <sys_unlink+0x1de>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060f2:	29c1                	addiw	s3,s3,16
    800060f4:	04c92783          	lw	a5,76(s2)
    800060f8:	fcf9efe3          	bltu	s3,a5,800060d6 <sys_unlink+0x154>
    800060fc:	6a4e                	ld	s4,208(sp)
    800060fe:	6aae                	ld	s5,200(sp)
    80006100:	b735                	j	8000602c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006102:	00002517          	auipc	a0,0x2
    80006106:	4fe50513          	addi	a0,a0,1278 # 80008600 <etext+0x600>
    8000610a:	ffffa097          	auipc	ra,0xffffa
    8000610e:	456080e7          	jalr	1110(ra) # 80000560 <panic>
    80006112:	e9d2                	sd	s4,208(sp)
    80006114:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80006116:	00002517          	auipc	a0,0x2
    8000611a:	50250513          	addi	a0,a0,1282 # 80008618 <etext+0x618>
    8000611e:	ffffa097          	auipc	ra,0xffffa
    80006122:	442080e7          	jalr	1090(ra) # 80000560 <panic>
    dp->nlink--;
    80006126:	04a4d783          	lhu	a5,74(s1)
    8000612a:	37fd                	addiw	a5,a5,-1
    8000612c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006130:	8526                	mv	a0,s1
    80006132:	ffffe097          	auipc	ra,0xffffe
    80006136:	ee0080e7          	jalr	-288(ra) # 80004012 <iupdate>
    8000613a:	b725                	j	80006062 <sys_unlink+0xe0>
    8000613c:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    8000613e:	8526                	mv	a0,s1
    80006140:	ffffe097          	auipc	ra,0xffffe
    80006144:	204080e7          	jalr	516(ra) # 80004344 <iunlockput>
  end_op();
    80006148:	fffff097          	auipc	ra,0xfffff
    8000614c:	9fa080e7          	jalr	-1542(ra) # 80004b42 <end_op>
  return -1;
    80006150:	557d                	li	a0,-1
    80006152:	74ae                	ld	s1,232(sp)
}
    80006154:	70ee                	ld	ra,248(sp)
    80006156:	744e                	ld	s0,240(sp)
    80006158:	6111                	addi	sp,sp,256
    8000615a:	8082                	ret
    return -1;
    8000615c:	557d                	li	a0,-1
    8000615e:	bfdd                	j	80006154 <sys_unlink+0x1d2>
    iunlockput(ip);
    80006160:	854a                	mv	a0,s2
    80006162:	ffffe097          	auipc	ra,0xffffe
    80006166:	1e2080e7          	jalr	482(ra) # 80004344 <iunlockput>
    goto bad;
    8000616a:	790e                	ld	s2,224(sp)
    8000616c:	69ee                	ld	s3,216(sp)
    8000616e:	6a4e                	ld	s4,208(sp)
    80006170:	6aae                	ld	s5,200(sp)
    80006172:	b7f1                	j	8000613e <sys_unlink+0x1bc>

0000000080006174 <sys_open>:

uint64
sys_open(void)
{
    80006174:	7131                	addi	sp,sp,-192
    80006176:	fd06                	sd	ra,184(sp)
    80006178:	f922                	sd	s0,176(sp)
    8000617a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000617c:	f4c40593          	addi	a1,s0,-180
    80006180:	4505                	li	a0,1
    80006182:	ffffd097          	auipc	ra,0xffffd
    80006186:	242080e7          	jalr	578(ra) # 800033c4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000618a:	08000613          	li	a2,128
    8000618e:	f5040593          	addi	a1,s0,-176
    80006192:	4501                	li	a0,0
    80006194:	ffffd097          	auipc	ra,0xffffd
    80006198:	270080e7          	jalr	624(ra) # 80003404 <argstr>
    8000619c:	87aa                	mv	a5,a0
    return -1;
    8000619e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800061a0:	0a07cf63          	bltz	a5,8000625e <sys_open+0xea>
    800061a4:	f526                	sd	s1,168(sp)

  begin_op();
    800061a6:	fffff097          	auipc	ra,0xfffff
    800061aa:	922080e7          	jalr	-1758(ra) # 80004ac8 <begin_op>

  if(omode & O_CREATE){
    800061ae:	f4c42783          	lw	a5,-180(s0)
    800061b2:	2007f793          	andi	a5,a5,512
    800061b6:	cfdd                	beqz	a5,80006274 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    800061b8:	4681                	li	a3,0
    800061ba:	4601                	li	a2,0
    800061bc:	4589                	li	a1,2
    800061be:	f5040513          	addi	a0,s0,-176
    800061c2:	00000097          	auipc	ra,0x0
    800061c6:	94a080e7          	jalr	-1718(ra) # 80005b0c <create>
    800061ca:	84aa                	mv	s1,a0
    if(ip == 0){
    800061cc:	cd49                	beqz	a0,80006266 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800061ce:	04449703          	lh	a4,68(s1)
    800061d2:	478d                	li	a5,3
    800061d4:	00f71763          	bne	a4,a5,800061e2 <sys_open+0x6e>
    800061d8:	0464d703          	lhu	a4,70(s1)
    800061dc:	47a5                	li	a5,9
    800061de:	0ee7e263          	bltu	a5,a4,800062c2 <sys_open+0x14e>
    800061e2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	cf8080e7          	jalr	-776(ra) # 80004edc <filealloc>
    800061ec:	892a                	mv	s2,a0
    800061ee:	cd65                	beqz	a0,800062e6 <sys_open+0x172>
    800061f0:	ed4e                	sd	s3,152(sp)
    800061f2:	00000097          	auipc	ra,0x0
    800061f6:	8d8080e7          	jalr	-1832(ra) # 80005aca <fdalloc>
    800061fa:	89aa                	mv	s3,a0
    800061fc:	0c054f63          	bltz	a0,800062da <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006200:	04449703          	lh	a4,68(s1)
    80006204:	478d                	li	a5,3
    80006206:	0ef70d63          	beq	a4,a5,80006300 <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000620a:	4789                	li	a5,2
    8000620c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006210:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006214:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006218:	f4c42783          	lw	a5,-180(s0)
    8000621c:	0017f713          	andi	a4,a5,1
    80006220:	00174713          	xori	a4,a4,1
    80006224:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006228:	0037f713          	andi	a4,a5,3
    8000622c:	00e03733          	snez	a4,a4
    80006230:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006234:	4007f793          	andi	a5,a5,1024
    80006238:	c791                	beqz	a5,80006244 <sys_open+0xd0>
    8000623a:	04449703          	lh	a4,68(s1)
    8000623e:	4789                	li	a5,2
    80006240:	0cf70763          	beq	a4,a5,8000630e <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80006244:	8526                	mv	a0,s1
    80006246:	ffffe097          	auipc	ra,0xffffe
    8000624a:	f5e080e7          	jalr	-162(ra) # 800041a4 <iunlock>
  end_op();
    8000624e:	fffff097          	auipc	ra,0xfffff
    80006252:	8f4080e7          	jalr	-1804(ra) # 80004b42 <end_op>

  return fd;
    80006256:	854e                	mv	a0,s3
    80006258:	74aa                	ld	s1,168(sp)
    8000625a:	790a                	ld	s2,160(sp)
    8000625c:	69ea                	ld	s3,152(sp)
}
    8000625e:	70ea                	ld	ra,184(sp)
    80006260:	744a                	ld	s0,176(sp)
    80006262:	6129                	addi	sp,sp,192
    80006264:	8082                	ret
      end_op();
    80006266:	fffff097          	auipc	ra,0xfffff
    8000626a:	8dc080e7          	jalr	-1828(ra) # 80004b42 <end_op>
      return -1;
    8000626e:	557d                	li	a0,-1
    80006270:	74aa                	ld	s1,168(sp)
    80006272:	b7f5                	j	8000625e <sys_open+0xea>
    if((ip = namei(path)) == 0){
    80006274:	f5040513          	addi	a0,s0,-176
    80006278:	ffffe097          	auipc	ra,0xffffe
    8000627c:	64a080e7          	jalr	1610(ra) # 800048c2 <namei>
    80006280:	84aa                	mv	s1,a0
    80006282:	c90d                	beqz	a0,800062b4 <sys_open+0x140>
    ilock(ip);
    80006284:	ffffe097          	auipc	ra,0xffffe
    80006288:	e5a080e7          	jalr	-422(ra) # 800040de <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000628c:	04449703          	lh	a4,68(s1)
    80006290:	4785                	li	a5,1
    80006292:	f2f71ee3          	bne	a4,a5,800061ce <sys_open+0x5a>
    80006296:	f4c42783          	lw	a5,-180(s0)
    8000629a:	d7a1                	beqz	a5,800061e2 <sys_open+0x6e>
      iunlockput(ip);
    8000629c:	8526                	mv	a0,s1
    8000629e:	ffffe097          	auipc	ra,0xffffe
    800062a2:	0a6080e7          	jalr	166(ra) # 80004344 <iunlockput>
      end_op();
    800062a6:	fffff097          	auipc	ra,0xfffff
    800062aa:	89c080e7          	jalr	-1892(ra) # 80004b42 <end_op>
      return -1;
    800062ae:	557d                	li	a0,-1
    800062b0:	74aa                	ld	s1,168(sp)
    800062b2:	b775                	j	8000625e <sys_open+0xea>
      end_op();
    800062b4:	fffff097          	auipc	ra,0xfffff
    800062b8:	88e080e7          	jalr	-1906(ra) # 80004b42 <end_op>
      return -1;
    800062bc:	557d                	li	a0,-1
    800062be:	74aa                	ld	s1,168(sp)
    800062c0:	bf79                	j	8000625e <sys_open+0xea>
    iunlockput(ip);
    800062c2:	8526                	mv	a0,s1
    800062c4:	ffffe097          	auipc	ra,0xffffe
    800062c8:	080080e7          	jalr	128(ra) # 80004344 <iunlockput>
    end_op();
    800062cc:	fffff097          	auipc	ra,0xfffff
    800062d0:	876080e7          	jalr	-1930(ra) # 80004b42 <end_op>
    return -1;
    800062d4:	557d                	li	a0,-1
    800062d6:	74aa                	ld	s1,168(sp)
    800062d8:	b759                	j	8000625e <sys_open+0xea>
      fileclose(f);
    800062da:	854a                	mv	a0,s2
    800062dc:	fffff097          	auipc	ra,0xfffff
    800062e0:	cbc080e7          	jalr	-836(ra) # 80004f98 <fileclose>
    800062e4:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800062e6:	8526                	mv	a0,s1
    800062e8:	ffffe097          	auipc	ra,0xffffe
    800062ec:	05c080e7          	jalr	92(ra) # 80004344 <iunlockput>
    end_op();
    800062f0:	fffff097          	auipc	ra,0xfffff
    800062f4:	852080e7          	jalr	-1966(ra) # 80004b42 <end_op>
    return -1;
    800062f8:	557d                	li	a0,-1
    800062fa:	74aa                	ld	s1,168(sp)
    800062fc:	790a                	ld	s2,160(sp)
    800062fe:	b785                	j	8000625e <sys_open+0xea>
    f->type = FD_DEVICE;
    80006300:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006304:	04649783          	lh	a5,70(s1)
    80006308:	02f91223          	sh	a5,36(s2)
    8000630c:	b721                	j	80006214 <sys_open+0xa0>
    itrunc(ip);
    8000630e:	8526                	mv	a0,s1
    80006310:	ffffe097          	auipc	ra,0xffffe
    80006314:	ee0080e7          	jalr	-288(ra) # 800041f0 <itrunc>
    80006318:	b735                	j	80006244 <sys_open+0xd0>

000000008000631a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000631a:	7175                	addi	sp,sp,-144
    8000631c:	e506                	sd	ra,136(sp)
    8000631e:	e122                	sd	s0,128(sp)
    80006320:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006322:	ffffe097          	auipc	ra,0xffffe
    80006326:	7a6080e7          	jalr	1958(ra) # 80004ac8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000632a:	08000613          	li	a2,128
    8000632e:	f7040593          	addi	a1,s0,-144
    80006332:	4501                	li	a0,0
    80006334:	ffffd097          	auipc	ra,0xffffd
    80006338:	0d0080e7          	jalr	208(ra) # 80003404 <argstr>
    8000633c:	02054963          	bltz	a0,8000636e <sys_mkdir+0x54>
    80006340:	4681                	li	a3,0
    80006342:	4601                	li	a2,0
    80006344:	4585                	li	a1,1
    80006346:	f7040513          	addi	a0,s0,-144
    8000634a:	fffff097          	auipc	ra,0xfffff
    8000634e:	7c2080e7          	jalr	1986(ra) # 80005b0c <create>
    80006352:	cd11                	beqz	a0,8000636e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006354:	ffffe097          	auipc	ra,0xffffe
    80006358:	ff0080e7          	jalr	-16(ra) # 80004344 <iunlockput>
  end_op();
    8000635c:	ffffe097          	auipc	ra,0xffffe
    80006360:	7e6080e7          	jalr	2022(ra) # 80004b42 <end_op>
  return 0;
    80006364:	4501                	li	a0,0
}
    80006366:	60aa                	ld	ra,136(sp)
    80006368:	640a                	ld	s0,128(sp)
    8000636a:	6149                	addi	sp,sp,144
    8000636c:	8082                	ret
    end_op();
    8000636e:	ffffe097          	auipc	ra,0xffffe
    80006372:	7d4080e7          	jalr	2004(ra) # 80004b42 <end_op>
    return -1;
    80006376:	557d                	li	a0,-1
    80006378:	b7fd                	j	80006366 <sys_mkdir+0x4c>

000000008000637a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000637a:	7135                	addi	sp,sp,-160
    8000637c:	ed06                	sd	ra,152(sp)
    8000637e:	e922                	sd	s0,144(sp)
    80006380:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006382:	ffffe097          	auipc	ra,0xffffe
    80006386:	746080e7          	jalr	1862(ra) # 80004ac8 <begin_op>
  argint(1, &major);
    8000638a:	f6c40593          	addi	a1,s0,-148
    8000638e:	4505                	li	a0,1
    80006390:	ffffd097          	auipc	ra,0xffffd
    80006394:	034080e7          	jalr	52(ra) # 800033c4 <argint>
  argint(2, &minor);
    80006398:	f6840593          	addi	a1,s0,-152
    8000639c:	4509                	li	a0,2
    8000639e:	ffffd097          	auipc	ra,0xffffd
    800063a2:	026080e7          	jalr	38(ra) # 800033c4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800063a6:	08000613          	li	a2,128
    800063aa:	f7040593          	addi	a1,s0,-144
    800063ae:	4501                	li	a0,0
    800063b0:	ffffd097          	auipc	ra,0xffffd
    800063b4:	054080e7          	jalr	84(ra) # 80003404 <argstr>
    800063b8:	02054b63          	bltz	a0,800063ee <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800063bc:	f6841683          	lh	a3,-152(s0)
    800063c0:	f6c41603          	lh	a2,-148(s0)
    800063c4:	458d                	li	a1,3
    800063c6:	f7040513          	addi	a0,s0,-144
    800063ca:	fffff097          	auipc	ra,0xfffff
    800063ce:	742080e7          	jalr	1858(ra) # 80005b0c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800063d2:	cd11                	beqz	a0,800063ee <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800063d4:	ffffe097          	auipc	ra,0xffffe
    800063d8:	f70080e7          	jalr	-144(ra) # 80004344 <iunlockput>
  end_op();
    800063dc:	ffffe097          	auipc	ra,0xffffe
    800063e0:	766080e7          	jalr	1894(ra) # 80004b42 <end_op>
  return 0;
    800063e4:	4501                	li	a0,0
}
    800063e6:	60ea                	ld	ra,152(sp)
    800063e8:	644a                	ld	s0,144(sp)
    800063ea:	610d                	addi	sp,sp,160
    800063ec:	8082                	ret
    end_op();
    800063ee:	ffffe097          	auipc	ra,0xffffe
    800063f2:	754080e7          	jalr	1876(ra) # 80004b42 <end_op>
    return -1;
    800063f6:	557d                	li	a0,-1
    800063f8:	b7fd                	j	800063e6 <sys_mknod+0x6c>

00000000800063fa <sys_chdir>:

uint64
sys_chdir(void)
{
    800063fa:	7135                	addi	sp,sp,-160
    800063fc:	ed06                	sd	ra,152(sp)
    800063fe:	e922                	sd	s0,144(sp)
    80006400:	e14a                	sd	s2,128(sp)
    80006402:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006404:	ffffb097          	auipc	ra,0xffffb
    80006408:	7f2080e7          	jalr	2034(ra) # 80001bf6 <myproc>
    8000640c:	892a                	mv	s2,a0
  
  begin_op();
    8000640e:	ffffe097          	auipc	ra,0xffffe
    80006412:	6ba080e7          	jalr	1722(ra) # 80004ac8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006416:	08000613          	li	a2,128
    8000641a:	f6040593          	addi	a1,s0,-160
    8000641e:	4501                	li	a0,0
    80006420:	ffffd097          	auipc	ra,0xffffd
    80006424:	fe4080e7          	jalr	-28(ra) # 80003404 <argstr>
    80006428:	04054d63          	bltz	a0,80006482 <sys_chdir+0x88>
    8000642c:	e526                	sd	s1,136(sp)
    8000642e:	f6040513          	addi	a0,s0,-160
    80006432:	ffffe097          	auipc	ra,0xffffe
    80006436:	490080e7          	jalr	1168(ra) # 800048c2 <namei>
    8000643a:	84aa                	mv	s1,a0
    8000643c:	c131                	beqz	a0,80006480 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000643e:	ffffe097          	auipc	ra,0xffffe
    80006442:	ca0080e7          	jalr	-864(ra) # 800040de <ilock>
  if(ip->type != T_DIR){
    80006446:	04449703          	lh	a4,68(s1)
    8000644a:	4785                	li	a5,1
    8000644c:	04f71163          	bne	a4,a5,8000648e <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006450:	8526                	mv	a0,s1
    80006452:	ffffe097          	auipc	ra,0xffffe
    80006456:	d52080e7          	jalr	-686(ra) # 800041a4 <iunlock>
  iput(p->cwd);
    8000645a:	32893503          	ld	a0,808(s2)
    8000645e:	ffffe097          	auipc	ra,0xffffe
    80006462:	e3e080e7          	jalr	-450(ra) # 8000429c <iput>
  end_op();
    80006466:	ffffe097          	auipc	ra,0xffffe
    8000646a:	6dc080e7          	jalr	1756(ra) # 80004b42 <end_op>
  p->cwd = ip;
    8000646e:	32993423          	sd	s1,808(s2)
  return 0;
    80006472:	4501                	li	a0,0
    80006474:	64aa                	ld	s1,136(sp)
}
    80006476:	60ea                	ld	ra,152(sp)
    80006478:	644a                	ld	s0,144(sp)
    8000647a:	690a                	ld	s2,128(sp)
    8000647c:	610d                	addi	sp,sp,160
    8000647e:	8082                	ret
    80006480:	64aa                	ld	s1,136(sp)
    end_op();
    80006482:	ffffe097          	auipc	ra,0xffffe
    80006486:	6c0080e7          	jalr	1728(ra) # 80004b42 <end_op>
    return -1;
    8000648a:	557d                	li	a0,-1
    8000648c:	b7ed                	j	80006476 <sys_chdir+0x7c>
    iunlockput(ip);
    8000648e:	8526                	mv	a0,s1
    80006490:	ffffe097          	auipc	ra,0xffffe
    80006494:	eb4080e7          	jalr	-332(ra) # 80004344 <iunlockput>
    end_op();
    80006498:	ffffe097          	auipc	ra,0xffffe
    8000649c:	6aa080e7          	jalr	1706(ra) # 80004b42 <end_op>
    return -1;
    800064a0:	557d                	li	a0,-1
    800064a2:	64aa                	ld	s1,136(sp)
    800064a4:	bfc9                	j	80006476 <sys_chdir+0x7c>

00000000800064a6 <sys_exec>:

uint64
sys_exec(void)
{
    800064a6:	7105                	addi	sp,sp,-480
    800064a8:	ef86                	sd	ra,472(sp)
    800064aa:	eba2                	sd	s0,464(sp)
    800064ac:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800064ae:	e2840593          	addi	a1,s0,-472
    800064b2:	4505                	li	a0,1
    800064b4:	ffffd097          	auipc	ra,0xffffd
    800064b8:	f30080e7          	jalr	-208(ra) # 800033e4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800064bc:	08000613          	li	a2,128
    800064c0:	f3040593          	addi	a1,s0,-208
    800064c4:	4501                	li	a0,0
    800064c6:	ffffd097          	auipc	ra,0xffffd
    800064ca:	f3e080e7          	jalr	-194(ra) # 80003404 <argstr>
    800064ce:	87aa                	mv	a5,a0
    return -1;
    800064d0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800064d2:	0e07ce63          	bltz	a5,800065ce <sys_exec+0x128>
    800064d6:	e7a6                	sd	s1,456(sp)
    800064d8:	e3ca                	sd	s2,448(sp)
    800064da:	ff4e                	sd	s3,440(sp)
    800064dc:	fb52                	sd	s4,432(sp)
    800064de:	f756                	sd	s5,424(sp)
    800064e0:	f35a                	sd	s6,416(sp)
    800064e2:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800064e4:	e3040a13          	addi	s4,s0,-464
    800064e8:	10000613          	li	a2,256
    800064ec:	4581                	li	a1,0
    800064ee:	8552                	mv	a0,s4
    800064f0:	ffffb097          	auipc	ra,0xffffb
    800064f4:	846080e7          	jalr	-1978(ra) # 80000d36 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800064f8:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800064fa:	89d2                	mv	s3,s4
    800064fc:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800064fe:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006502:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80006504:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006508:	00391513          	slli	a0,s2,0x3
    8000650c:	85d6                	mv	a1,s5
    8000650e:	e2843783          	ld	a5,-472(s0)
    80006512:	953e                	add	a0,a0,a5
    80006514:	ffffd097          	auipc	ra,0xffffd
    80006518:	e0c080e7          	jalr	-500(ra) # 80003320 <fetchaddr>
    8000651c:	02054a63          	bltz	a0,80006550 <sys_exec+0xaa>
    if(uarg == 0){
    80006520:	e2043783          	ld	a5,-480(s0)
    80006524:	cbb1                	beqz	a5,80006578 <sys_exec+0xd2>
    argv[i] = kalloc();
    80006526:	ffffa097          	auipc	ra,0xffffa
    8000652a:	624080e7          	jalr	1572(ra) # 80000b4a <kalloc>
    8000652e:	85aa                	mv	a1,a0
    80006530:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006534:	cd11                	beqz	a0,80006550 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006536:	865a                	mv	a2,s6
    80006538:	e2043503          	ld	a0,-480(s0)
    8000653c:	ffffd097          	auipc	ra,0xffffd
    80006540:	e3a080e7          	jalr	-454(ra) # 80003376 <fetchstr>
    80006544:	00054663          	bltz	a0,80006550 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80006548:	0905                	addi	s2,s2,1
    8000654a:	09a1                	addi	s3,s3,8
    8000654c:	fb791ee3          	bne	s2,s7,80006508 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006550:	100a0a13          	addi	s4,s4,256
    80006554:	6088                	ld	a0,0(s1)
    80006556:	c525                	beqz	a0,800065be <sys_exec+0x118>
    kfree(argv[i]);
    80006558:	ffffa097          	auipc	ra,0xffffa
    8000655c:	4f4080e7          	jalr	1268(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006560:	04a1                	addi	s1,s1,8
    80006562:	ff4499e3          	bne	s1,s4,80006554 <sys_exec+0xae>
  return -1;
    80006566:	557d                	li	a0,-1
    80006568:	64be                	ld	s1,456(sp)
    8000656a:	691e                	ld	s2,448(sp)
    8000656c:	79fa                	ld	s3,440(sp)
    8000656e:	7a5a                	ld	s4,432(sp)
    80006570:	7aba                	ld	s5,424(sp)
    80006572:	7b1a                	ld	s6,416(sp)
    80006574:	6bfa                	ld	s7,408(sp)
    80006576:	a8a1                	j	800065ce <sys_exec+0x128>
      argv[i] = 0;
    80006578:	0009079b          	sext.w	a5,s2
    8000657c:	e3040593          	addi	a1,s0,-464
    80006580:	078e                	slli	a5,a5,0x3
    80006582:	97ae                	add	a5,a5,a1
    80006584:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80006588:	f3040513          	addi	a0,s0,-208
    8000658c:	fffff097          	auipc	ra,0xfffff
    80006590:	116080e7          	jalr	278(ra) # 800056a2 <exec>
    80006594:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006596:	100a0a13          	addi	s4,s4,256
    8000659a:	6088                	ld	a0,0(s1)
    8000659c:	c901                	beqz	a0,800065ac <sys_exec+0x106>
    kfree(argv[i]);
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	4ae080e7          	jalr	1198(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065a6:	04a1                	addi	s1,s1,8
    800065a8:	ff4499e3          	bne	s1,s4,8000659a <sys_exec+0xf4>
  return ret;
    800065ac:	854a                	mv	a0,s2
    800065ae:	64be                	ld	s1,456(sp)
    800065b0:	691e                	ld	s2,448(sp)
    800065b2:	79fa                	ld	s3,440(sp)
    800065b4:	7a5a                	ld	s4,432(sp)
    800065b6:	7aba                	ld	s5,424(sp)
    800065b8:	7b1a                	ld	s6,416(sp)
    800065ba:	6bfa                	ld	s7,408(sp)
    800065bc:	a809                	j	800065ce <sys_exec+0x128>
  return -1;
    800065be:	557d                	li	a0,-1
    800065c0:	64be                	ld	s1,456(sp)
    800065c2:	691e                	ld	s2,448(sp)
    800065c4:	79fa                	ld	s3,440(sp)
    800065c6:	7a5a                	ld	s4,432(sp)
    800065c8:	7aba                	ld	s5,424(sp)
    800065ca:	7b1a                	ld	s6,416(sp)
    800065cc:	6bfa                	ld	s7,408(sp)
}
    800065ce:	60fe                	ld	ra,472(sp)
    800065d0:	645e                	ld	s0,464(sp)
    800065d2:	613d                	addi	sp,sp,480
    800065d4:	8082                	ret

00000000800065d6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800065d6:	7139                	addi	sp,sp,-64
    800065d8:	fc06                	sd	ra,56(sp)
    800065da:	f822                	sd	s0,48(sp)
    800065dc:	f426                	sd	s1,40(sp)
    800065de:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800065e0:	ffffb097          	auipc	ra,0xffffb
    800065e4:	616080e7          	jalr	1558(ra) # 80001bf6 <myproc>
    800065e8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800065ea:	fd840593          	addi	a1,s0,-40
    800065ee:	4501                	li	a0,0
    800065f0:	ffffd097          	auipc	ra,0xffffd
    800065f4:	df4080e7          	jalr	-524(ra) # 800033e4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800065f8:	fc840593          	addi	a1,s0,-56
    800065fc:	fd040513          	addi	a0,s0,-48
    80006600:	fffff097          	auipc	ra,0xfffff
    80006604:	d0c080e7          	jalr	-756(ra) # 8000530c <pipealloc>
    return -1;
    80006608:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000660a:	0c054963          	bltz	a0,800066dc <sys_pipe+0x106>
  fd0 = -1;
    8000660e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006612:	fd043503          	ld	a0,-48(s0)
    80006616:	fffff097          	auipc	ra,0xfffff
    8000661a:	4b4080e7          	jalr	1204(ra) # 80005aca <fdalloc>
    8000661e:	fca42223          	sw	a0,-60(s0)
    80006622:	0a054063          	bltz	a0,800066c2 <sys_pipe+0xec>
    80006626:	fc843503          	ld	a0,-56(s0)
    8000662a:	fffff097          	auipc	ra,0xfffff
    8000662e:	4a0080e7          	jalr	1184(ra) # 80005aca <fdalloc>
    80006632:	fca42023          	sw	a0,-64(s0)
    80006636:	06054c63          	bltz	a0,800066ae <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000663a:	4691                	li	a3,4
    8000663c:	fc440613          	addi	a2,s0,-60
    80006640:	fd843583          	ld	a1,-40(s0)
    80006644:	2284b503          	ld	a0,552(s1)
    80006648:	ffffb097          	auipc	ra,0xffffb
    8000664c:	0c8080e7          	jalr	200(ra) # 80001710 <copyout>
    80006650:	02054163          	bltz	a0,80006672 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006654:	4691                	li	a3,4
    80006656:	fc040613          	addi	a2,s0,-64
    8000665a:	fd843583          	ld	a1,-40(s0)
    8000665e:	95b6                	add	a1,a1,a3
    80006660:	2284b503          	ld	a0,552(s1)
    80006664:	ffffb097          	auipc	ra,0xffffb
    80006668:	0ac080e7          	jalr	172(ra) # 80001710 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000666c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000666e:	06055763          	bgez	a0,800066dc <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80006672:	fc442783          	lw	a5,-60(s0)
    80006676:	05478793          	addi	a5,a5,84
    8000667a:	078e                	slli	a5,a5,0x3
    8000667c:	97a6                	add	a5,a5,s1
    8000667e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006682:	fc042783          	lw	a5,-64(s0)
    80006686:	05478793          	addi	a5,a5,84
    8000668a:	078e                	slli	a5,a5,0x3
    8000668c:	94be                	add	s1,s1,a5
    8000668e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006692:	fd043503          	ld	a0,-48(s0)
    80006696:	fffff097          	auipc	ra,0xfffff
    8000669a:	902080e7          	jalr	-1790(ra) # 80004f98 <fileclose>
    fileclose(wf);
    8000669e:	fc843503          	ld	a0,-56(s0)
    800066a2:	fffff097          	auipc	ra,0xfffff
    800066a6:	8f6080e7          	jalr	-1802(ra) # 80004f98 <fileclose>
    return -1;
    800066aa:	57fd                	li	a5,-1
    800066ac:	a805                	j	800066dc <sys_pipe+0x106>
    if(fd0 >= 0)
    800066ae:	fc442783          	lw	a5,-60(s0)
    800066b2:	0007c863          	bltz	a5,800066c2 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    800066b6:	05478793          	addi	a5,a5,84
    800066ba:	078e                	slli	a5,a5,0x3
    800066bc:	97a6                	add	a5,a5,s1
    800066be:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800066c2:	fd043503          	ld	a0,-48(s0)
    800066c6:	fffff097          	auipc	ra,0xfffff
    800066ca:	8d2080e7          	jalr	-1838(ra) # 80004f98 <fileclose>
    fileclose(wf);
    800066ce:	fc843503          	ld	a0,-56(s0)
    800066d2:	fffff097          	auipc	ra,0xfffff
    800066d6:	8c6080e7          	jalr	-1850(ra) # 80004f98 <fileclose>
    return -1;
    800066da:	57fd                	li	a5,-1
}
    800066dc:	853e                	mv	a0,a5
    800066de:	70e2                	ld	ra,56(sp)
    800066e0:	7442                	ld	s0,48(sp)
    800066e2:	74a2                	ld	s1,40(sp)
    800066e4:	6121                	addi	sp,sp,64
    800066e6:	8082                	ret
	...

00000000800066f0 <kernelvec>:
    800066f0:	7111                	addi	sp,sp,-256
    800066f2:	e006                	sd	ra,0(sp)
    800066f4:	e40a                	sd	sp,8(sp)
    800066f6:	e80e                	sd	gp,16(sp)
    800066f8:	ec12                	sd	tp,24(sp)
    800066fa:	f016                	sd	t0,32(sp)
    800066fc:	f41a                	sd	t1,40(sp)
    800066fe:	f81e                	sd	t2,48(sp)
    80006700:	fc22                	sd	s0,56(sp)
    80006702:	e0a6                	sd	s1,64(sp)
    80006704:	e4aa                	sd	a0,72(sp)
    80006706:	e8ae                	sd	a1,80(sp)
    80006708:	ecb2                	sd	a2,88(sp)
    8000670a:	f0b6                	sd	a3,96(sp)
    8000670c:	f4ba                	sd	a4,104(sp)
    8000670e:	f8be                	sd	a5,112(sp)
    80006710:	fcc2                	sd	a6,120(sp)
    80006712:	e146                	sd	a7,128(sp)
    80006714:	e54a                	sd	s2,136(sp)
    80006716:	e94e                	sd	s3,144(sp)
    80006718:	ed52                	sd	s4,152(sp)
    8000671a:	f156                	sd	s5,160(sp)
    8000671c:	f55a                	sd	s6,168(sp)
    8000671e:	f95e                	sd	s7,176(sp)
    80006720:	fd62                	sd	s8,184(sp)
    80006722:	e1e6                	sd	s9,192(sp)
    80006724:	e5ea                	sd	s10,200(sp)
    80006726:	e9ee                	sd	s11,208(sp)
    80006728:	edf2                	sd	t3,216(sp)
    8000672a:	f1f6                	sd	t4,224(sp)
    8000672c:	f5fa                	sd	t5,232(sp)
    8000672e:	f9fe                	sd	t6,240(sp)
    80006730:	ab1fc0ef          	jal	800031e0 <kerneltrap>
    80006734:	6082                	ld	ra,0(sp)
    80006736:	6122                	ld	sp,8(sp)
    80006738:	61c2                	ld	gp,16(sp)
    8000673a:	7282                	ld	t0,32(sp)
    8000673c:	7322                	ld	t1,40(sp)
    8000673e:	73c2                	ld	t2,48(sp)
    80006740:	7462                	ld	s0,56(sp)
    80006742:	6486                	ld	s1,64(sp)
    80006744:	6526                	ld	a0,72(sp)
    80006746:	65c6                	ld	a1,80(sp)
    80006748:	6666                	ld	a2,88(sp)
    8000674a:	7686                	ld	a3,96(sp)
    8000674c:	7726                	ld	a4,104(sp)
    8000674e:	77c6                	ld	a5,112(sp)
    80006750:	7866                	ld	a6,120(sp)
    80006752:	688a                	ld	a7,128(sp)
    80006754:	692a                	ld	s2,136(sp)
    80006756:	69ca                	ld	s3,144(sp)
    80006758:	6a6a                	ld	s4,152(sp)
    8000675a:	7a8a                	ld	s5,160(sp)
    8000675c:	7b2a                	ld	s6,168(sp)
    8000675e:	7bca                	ld	s7,176(sp)
    80006760:	7c6a                	ld	s8,184(sp)
    80006762:	6c8e                	ld	s9,192(sp)
    80006764:	6d2e                	ld	s10,200(sp)
    80006766:	6dce                	ld	s11,208(sp)
    80006768:	6e6e                	ld	t3,216(sp)
    8000676a:	7e8e                	ld	t4,224(sp)
    8000676c:	7f2e                	ld	t5,232(sp)
    8000676e:	7fce                	ld	t6,240(sp)
    80006770:	6111                	addi	sp,sp,256
    80006772:	10200073          	sret
    80006776:	00000013          	nop
    8000677a:	00000013          	nop
    8000677e:	0001                	nop

0000000080006780 <timervec>:
    80006780:	34051573          	csrrw	a0,mscratch,a0
    80006784:	e10c                	sd	a1,0(a0)
    80006786:	e510                	sd	a2,8(a0)
    80006788:	e914                	sd	a3,16(a0)
    8000678a:	6d0c                	ld	a1,24(a0)
    8000678c:	7110                	ld	a2,32(a0)
    8000678e:	6194                	ld	a3,0(a1)
    80006790:	96b2                	add	a3,a3,a2
    80006792:	e194                	sd	a3,0(a1)
    80006794:	4589                	li	a1,2
    80006796:	14459073          	csrw	sip,a1
    8000679a:	6914                	ld	a3,16(a0)
    8000679c:	6510                	ld	a2,8(a0)
    8000679e:	610c                	ld	a1,0(a0)
    800067a0:	34051573          	csrrw	a0,mscratch,a0
    800067a4:	30200073          	mret
	...

00000000800067aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800067aa:	1141                	addi	sp,sp,-16
    800067ac:	e406                	sd	ra,8(sp)
    800067ae:	e022                	sd	s0,0(sp)
    800067b0:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800067b2:	0c000737          	lui	a4,0xc000
    800067b6:	4785                	li	a5,1
    800067b8:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800067ba:	c35c                	sw	a5,4(a4)
}
    800067bc:	60a2                	ld	ra,8(sp)
    800067be:	6402                	ld	s0,0(sp)
    800067c0:	0141                	addi	sp,sp,16
    800067c2:	8082                	ret

00000000800067c4 <plicinithart>:

void
plicinithart(void)
{
    800067c4:	1141                	addi	sp,sp,-16
    800067c6:	e406                	sd	ra,8(sp)
    800067c8:	e022                	sd	s0,0(sp)
    800067ca:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800067cc:	ffffb097          	auipc	ra,0xffffb
    800067d0:	3f6080e7          	jalr	1014(ra) # 80001bc2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800067d4:	0085171b          	slliw	a4,a0,0x8
    800067d8:	0c0027b7          	lui	a5,0xc002
    800067dc:	97ba                	add	a5,a5,a4
    800067de:	40200713          	li	a4,1026
    800067e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800067e6:	00d5151b          	slliw	a0,a0,0xd
    800067ea:	0c2017b7          	lui	a5,0xc201
    800067ee:	97aa                	add	a5,a5,a0
    800067f0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800067f4:	60a2                	ld	ra,8(sp)
    800067f6:	6402                	ld	s0,0(sp)
    800067f8:	0141                	addi	sp,sp,16
    800067fa:	8082                	ret

00000000800067fc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800067fc:	1141                	addi	sp,sp,-16
    800067fe:	e406                	sd	ra,8(sp)
    80006800:	e022                	sd	s0,0(sp)
    80006802:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006804:	ffffb097          	auipc	ra,0xffffb
    80006808:	3be080e7          	jalr	958(ra) # 80001bc2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000680c:	00d5151b          	slliw	a0,a0,0xd
    80006810:	0c2017b7          	lui	a5,0xc201
    80006814:	97aa                	add	a5,a5,a0
  return irq;
}
    80006816:	43c8                	lw	a0,4(a5)
    80006818:	60a2                	ld	ra,8(sp)
    8000681a:	6402                	ld	s0,0(sp)
    8000681c:	0141                	addi	sp,sp,16
    8000681e:	8082                	ret

0000000080006820 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006820:	1101                	addi	sp,sp,-32
    80006822:	ec06                	sd	ra,24(sp)
    80006824:	e822                	sd	s0,16(sp)
    80006826:	e426                	sd	s1,8(sp)
    80006828:	1000                	addi	s0,sp,32
    8000682a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000682c:	ffffb097          	auipc	ra,0xffffb
    80006830:	396080e7          	jalr	918(ra) # 80001bc2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006834:	00d5179b          	slliw	a5,a0,0xd
    80006838:	0c201737          	lui	a4,0xc201
    8000683c:	97ba                	add	a5,a5,a4
    8000683e:	c3c4                	sw	s1,4(a5)
}
    80006840:	60e2                	ld	ra,24(sp)
    80006842:	6442                	ld	s0,16(sp)
    80006844:	64a2                	ld	s1,8(sp)
    80006846:	6105                	addi	sp,sp,32
    80006848:	8082                	ret

000000008000684a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000684a:	1141                	addi	sp,sp,-16
    8000684c:	e406                	sd	ra,8(sp)
    8000684e:	e022                	sd	s0,0(sp)
    80006850:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006852:	479d                	li	a5,7
    80006854:	04a7cc63          	blt	a5,a0,800068ac <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006858:	00023797          	auipc	a5,0x23
    8000685c:	5e878793          	addi	a5,a5,1512 # 80029e40 <disk>
    80006860:	97aa                	add	a5,a5,a0
    80006862:	0187c783          	lbu	a5,24(a5)
    80006866:	ebb9                	bnez	a5,800068bc <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006868:	00451693          	slli	a3,a0,0x4
    8000686c:	00023797          	auipc	a5,0x23
    80006870:	5d478793          	addi	a5,a5,1492 # 80029e40 <disk>
    80006874:	6398                	ld	a4,0(a5)
    80006876:	9736                	add	a4,a4,a3
    80006878:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    8000687c:	6398                	ld	a4,0(a5)
    8000687e:	9736                	add	a4,a4,a3
    80006880:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006884:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006888:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000688c:	97aa                	add	a5,a5,a0
    8000688e:	4705                	li	a4,1
    80006890:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006894:	00023517          	auipc	a0,0x23
    80006898:	5c450513          	addi	a0,a0,1476 # 80029e58 <disk+0x18>
    8000689c:	ffffc097          	auipc	ra,0xffffc
    800068a0:	e7c080e7          	jalr	-388(ra) # 80002718 <wakeup>
}
    800068a4:	60a2                	ld	ra,8(sp)
    800068a6:	6402                	ld	s0,0(sp)
    800068a8:	0141                	addi	sp,sp,16
    800068aa:	8082                	ret
    panic("free_desc 1");
    800068ac:	00002517          	auipc	a0,0x2
    800068b0:	d7c50513          	addi	a0,a0,-644 # 80008628 <etext+0x628>
    800068b4:	ffffa097          	auipc	ra,0xffffa
    800068b8:	cac080e7          	jalr	-852(ra) # 80000560 <panic>
    panic("free_desc 2");
    800068bc:	00002517          	auipc	a0,0x2
    800068c0:	d7c50513          	addi	a0,a0,-644 # 80008638 <etext+0x638>
    800068c4:	ffffa097          	auipc	ra,0xffffa
    800068c8:	c9c080e7          	jalr	-868(ra) # 80000560 <panic>

00000000800068cc <virtio_disk_init>:
{
    800068cc:	1101                	addi	sp,sp,-32
    800068ce:	ec06                	sd	ra,24(sp)
    800068d0:	e822                	sd	s0,16(sp)
    800068d2:	e426                	sd	s1,8(sp)
    800068d4:	e04a                	sd	s2,0(sp)
    800068d6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800068d8:	00002597          	auipc	a1,0x2
    800068dc:	d7058593          	addi	a1,a1,-656 # 80008648 <etext+0x648>
    800068e0:	00023517          	auipc	a0,0x23
    800068e4:	68850513          	addi	a0,a0,1672 # 80029f68 <disk+0x128>
    800068e8:	ffffa097          	auipc	ra,0xffffa
    800068ec:	2c2080e7          	jalr	706(ra) # 80000baa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068f0:	100017b7          	lui	a5,0x10001
    800068f4:	4398                	lw	a4,0(a5)
    800068f6:	2701                	sext.w	a4,a4
    800068f8:	747277b7          	lui	a5,0x74727
    800068fc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006900:	16f71463          	bne	a4,a5,80006a68 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006904:	100017b7          	lui	a5,0x10001
    80006908:	43dc                	lw	a5,4(a5)
    8000690a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000690c:	4709                	li	a4,2
    8000690e:	14e79d63          	bne	a5,a4,80006a68 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006912:	100017b7          	lui	a5,0x10001
    80006916:	479c                	lw	a5,8(a5)
    80006918:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000691a:	14e79763          	bne	a5,a4,80006a68 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000691e:	100017b7          	lui	a5,0x10001
    80006922:	47d8                	lw	a4,12(a5)
    80006924:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006926:	554d47b7          	lui	a5,0x554d4
    8000692a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000692e:	12f71d63          	bne	a4,a5,80006a68 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006932:	100017b7          	lui	a5,0x10001
    80006936:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000693a:	4705                	li	a4,1
    8000693c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000693e:	470d                	li	a4,3
    80006940:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006942:	10001737          	lui	a4,0x10001
    80006946:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006948:	c7ffe6b7          	lui	a3,0xc7ffe
    8000694c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd47df>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006950:	8f75                	and	a4,a4,a3
    80006952:	100016b7          	lui	a3,0x10001
    80006956:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006958:	472d                	li	a4,11
    8000695a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000695c:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006960:	439c                	lw	a5,0(a5)
    80006962:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006966:	8ba1                	andi	a5,a5,8
    80006968:	10078863          	beqz	a5,80006a78 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000696c:	100017b7          	lui	a5,0x10001
    80006970:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006974:	43fc                	lw	a5,68(a5)
    80006976:	2781                	sext.w	a5,a5
    80006978:	10079863          	bnez	a5,80006a88 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000697c:	100017b7          	lui	a5,0x10001
    80006980:	5bdc                	lw	a5,52(a5)
    80006982:	2781                	sext.w	a5,a5
  if(max == 0)
    80006984:	10078a63          	beqz	a5,80006a98 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006988:	471d                	li	a4,7
    8000698a:	10f77f63          	bgeu	a4,a5,80006aa8 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    8000698e:	ffffa097          	auipc	ra,0xffffa
    80006992:	1bc080e7          	jalr	444(ra) # 80000b4a <kalloc>
    80006996:	00023497          	auipc	s1,0x23
    8000699a:	4aa48493          	addi	s1,s1,1194 # 80029e40 <disk>
    8000699e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800069a0:	ffffa097          	auipc	ra,0xffffa
    800069a4:	1aa080e7          	jalr	426(ra) # 80000b4a <kalloc>
    800069a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800069aa:	ffffa097          	auipc	ra,0xffffa
    800069ae:	1a0080e7          	jalr	416(ra) # 80000b4a <kalloc>
    800069b2:	87aa                	mv	a5,a0
    800069b4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800069b6:	6088                	ld	a0,0(s1)
    800069b8:	10050063          	beqz	a0,80006ab8 <virtio_disk_init+0x1ec>
    800069bc:	00023717          	auipc	a4,0x23
    800069c0:	48c73703          	ld	a4,1164(a4) # 80029e48 <disk+0x8>
    800069c4:	cb75                	beqz	a4,80006ab8 <virtio_disk_init+0x1ec>
    800069c6:	cbed                	beqz	a5,80006ab8 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800069c8:	6605                	lui	a2,0x1
    800069ca:	4581                	li	a1,0
    800069cc:	ffffa097          	auipc	ra,0xffffa
    800069d0:	36a080e7          	jalr	874(ra) # 80000d36 <memset>
  memset(disk.avail, 0, PGSIZE);
    800069d4:	00023497          	auipc	s1,0x23
    800069d8:	46c48493          	addi	s1,s1,1132 # 80029e40 <disk>
    800069dc:	6605                	lui	a2,0x1
    800069de:	4581                	li	a1,0
    800069e0:	6488                	ld	a0,8(s1)
    800069e2:	ffffa097          	auipc	ra,0xffffa
    800069e6:	354080e7          	jalr	852(ra) # 80000d36 <memset>
  memset(disk.used, 0, PGSIZE);
    800069ea:	6605                	lui	a2,0x1
    800069ec:	4581                	li	a1,0
    800069ee:	6888                	ld	a0,16(s1)
    800069f0:	ffffa097          	auipc	ra,0xffffa
    800069f4:	346080e7          	jalr	838(ra) # 80000d36 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800069f8:	100017b7          	lui	a5,0x10001
    800069fc:	4721                	li	a4,8
    800069fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006a00:	4098                	lw	a4,0(s1)
    80006a02:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006a06:	40d8                	lw	a4,4(s1)
    80006a08:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006a0c:	649c                	ld	a5,8(s1)
    80006a0e:	0007869b          	sext.w	a3,a5
    80006a12:	10001737          	lui	a4,0x10001
    80006a16:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006a1a:	9781                	srai	a5,a5,0x20
    80006a1c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006a20:	689c                	ld	a5,16(s1)
    80006a22:	0007869b          	sext.w	a3,a5
    80006a26:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006a2a:	9781                	srai	a5,a5,0x20
    80006a2c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006a30:	4785                	li	a5,1
    80006a32:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006a34:	00f48c23          	sb	a5,24(s1)
    80006a38:	00f48ca3          	sb	a5,25(s1)
    80006a3c:	00f48d23          	sb	a5,26(s1)
    80006a40:	00f48da3          	sb	a5,27(s1)
    80006a44:	00f48e23          	sb	a5,28(s1)
    80006a48:	00f48ea3          	sb	a5,29(s1)
    80006a4c:	00f48f23          	sb	a5,30(s1)
    80006a50:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006a54:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a58:	07272823          	sw	s2,112(a4)
}
    80006a5c:	60e2                	ld	ra,24(sp)
    80006a5e:	6442                	ld	s0,16(sp)
    80006a60:	64a2                	ld	s1,8(sp)
    80006a62:	6902                	ld	s2,0(sp)
    80006a64:	6105                	addi	sp,sp,32
    80006a66:	8082                	ret
    panic("could not find virtio disk");
    80006a68:	00002517          	auipc	a0,0x2
    80006a6c:	bf050513          	addi	a0,a0,-1040 # 80008658 <etext+0x658>
    80006a70:	ffffa097          	auipc	ra,0xffffa
    80006a74:	af0080e7          	jalr	-1296(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006a78:	00002517          	auipc	a0,0x2
    80006a7c:	c0050513          	addi	a0,a0,-1024 # 80008678 <etext+0x678>
    80006a80:	ffffa097          	auipc	ra,0xffffa
    80006a84:	ae0080e7          	jalr	-1312(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006a88:	00002517          	auipc	a0,0x2
    80006a8c:	c1050513          	addi	a0,a0,-1008 # 80008698 <etext+0x698>
    80006a90:	ffffa097          	auipc	ra,0xffffa
    80006a94:	ad0080e7          	jalr	-1328(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006a98:	00002517          	auipc	a0,0x2
    80006a9c:	c2050513          	addi	a0,a0,-992 # 800086b8 <etext+0x6b8>
    80006aa0:	ffffa097          	auipc	ra,0xffffa
    80006aa4:	ac0080e7          	jalr	-1344(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006aa8:	00002517          	auipc	a0,0x2
    80006aac:	c3050513          	addi	a0,a0,-976 # 800086d8 <etext+0x6d8>
    80006ab0:	ffffa097          	auipc	ra,0xffffa
    80006ab4:	ab0080e7          	jalr	-1360(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006ab8:	00002517          	auipc	a0,0x2
    80006abc:	c4050513          	addi	a0,a0,-960 # 800086f8 <etext+0x6f8>
    80006ac0:	ffffa097          	auipc	ra,0xffffa
    80006ac4:	aa0080e7          	jalr	-1376(ra) # 80000560 <panic>

0000000080006ac8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ac8:	711d                	addi	sp,sp,-96
    80006aca:	ec86                	sd	ra,88(sp)
    80006acc:	e8a2                	sd	s0,80(sp)
    80006ace:	e4a6                	sd	s1,72(sp)
    80006ad0:	e0ca                	sd	s2,64(sp)
    80006ad2:	fc4e                	sd	s3,56(sp)
    80006ad4:	f852                	sd	s4,48(sp)
    80006ad6:	f456                	sd	s5,40(sp)
    80006ad8:	f05a                	sd	s6,32(sp)
    80006ada:	ec5e                	sd	s7,24(sp)
    80006adc:	e862                	sd	s8,16(sp)
    80006ade:	1080                	addi	s0,sp,96
    80006ae0:	89aa                	mv	s3,a0
    80006ae2:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ae4:	00c52b83          	lw	s7,12(a0)
    80006ae8:	001b9b9b          	slliw	s7,s7,0x1
    80006aec:	1b82                	slli	s7,s7,0x20
    80006aee:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006af2:	00023517          	auipc	a0,0x23
    80006af6:	47650513          	addi	a0,a0,1142 # 80029f68 <disk+0x128>
    80006afa:	ffffa097          	auipc	ra,0xffffa
    80006afe:	144080e7          	jalr	324(ra) # 80000c3e <acquire>
  for(int i = 0; i < NUM; i++){
    80006b02:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006b04:	00023a97          	auipc	s5,0x23
    80006b08:	33ca8a93          	addi	s5,s5,828 # 80029e40 <disk>
  for(int i = 0; i < 3; i++){
    80006b0c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80006b0e:	5c7d                	li	s8,-1
    80006b10:	a885                	j	80006b80 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006b12:	00fa8733          	add	a4,s5,a5
    80006b16:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006b1a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b1c:	0207c563          	bltz	a5,80006b46 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    80006b20:	2905                	addiw	s2,s2,1
    80006b22:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006b24:	07490263          	beq	s2,s4,80006b88 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    80006b28:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b2a:	00023717          	auipc	a4,0x23
    80006b2e:	31670713          	addi	a4,a4,790 # 80029e40 <disk>
    80006b32:	4781                	li	a5,0
    if(disk.free[i]){
    80006b34:	01874683          	lbu	a3,24(a4)
    80006b38:	fee9                	bnez	a3,80006b12 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006b3a:	2785                	addiw	a5,a5,1
    80006b3c:	0705                	addi	a4,a4,1
    80006b3e:	fe979be3          	bne	a5,s1,80006b34 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80006b42:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80006b46:	03205163          	blez	s2,80006b68 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    80006b4a:	fa042503          	lw	a0,-96(s0)
    80006b4e:	00000097          	auipc	ra,0x0
    80006b52:	cfc080e7          	jalr	-772(ra) # 8000684a <free_desc>
      for(int j = 0; j < i; j++)
    80006b56:	4785                	li	a5,1
    80006b58:	0127d863          	bge	a5,s2,80006b68 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    80006b5c:	fa442503          	lw	a0,-92(s0)
    80006b60:	00000097          	auipc	ra,0x0
    80006b64:	cea080e7          	jalr	-790(ra) # 8000684a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b68:	00023597          	auipc	a1,0x23
    80006b6c:	40058593          	addi	a1,a1,1024 # 80029f68 <disk+0x128>
    80006b70:	00023517          	auipc	a0,0x23
    80006b74:	2e850513          	addi	a0,a0,744 # 80029e58 <disk+0x18>
    80006b78:	ffffc097          	auipc	ra,0xffffc
    80006b7c:	b3c080e7          	jalr	-1220(ra) # 800026b4 <sleep>
  for(int i = 0; i < 3; i++){
    80006b80:	fa040613          	addi	a2,s0,-96
    80006b84:	4901                	li	s2,0
    80006b86:	b74d                	j	80006b28 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006b88:	fa042503          	lw	a0,-96(s0)
    80006b8c:	00451693          	slli	a3,a0,0x4

  if(write)
    80006b90:	00023797          	auipc	a5,0x23
    80006b94:	2b078793          	addi	a5,a5,688 # 80029e40 <disk>
    80006b98:	00a50713          	addi	a4,a0,10
    80006b9c:	0712                	slli	a4,a4,0x4
    80006b9e:	973e                	add	a4,a4,a5
    80006ba0:	01603633          	snez	a2,s6
    80006ba4:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006ba6:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006baa:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bae:	6398                	ld	a4,0(a5)
    80006bb0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006bb2:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006bb6:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bb8:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006bba:	6390                	ld	a2,0(a5)
    80006bbc:	00d605b3          	add	a1,a2,a3
    80006bc0:	4741                	li	a4,16
    80006bc2:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006bc4:	4805                	li	a6,1
    80006bc6:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006bca:	fa442703          	lw	a4,-92(s0)
    80006bce:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006bd2:	0712                	slli	a4,a4,0x4
    80006bd4:	963a                	add	a2,a2,a4
    80006bd6:	05898593          	addi	a1,s3,88
    80006bda:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006bdc:	0007b883          	ld	a7,0(a5)
    80006be0:	9746                	add	a4,a4,a7
    80006be2:	40000613          	li	a2,1024
    80006be6:	c710                	sw	a2,8(a4)
  if(write)
    80006be8:	001b3613          	seqz	a2,s6
    80006bec:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006bf0:	01066633          	or	a2,a2,a6
    80006bf4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006bf8:	fa842583          	lw	a1,-88(s0)
    80006bfc:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006c00:	00250613          	addi	a2,a0,2
    80006c04:	0612                	slli	a2,a2,0x4
    80006c06:	963e                	add	a2,a2,a5
    80006c08:	577d                	li	a4,-1
    80006c0a:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006c0e:	0592                	slli	a1,a1,0x4
    80006c10:	98ae                	add	a7,a7,a1
    80006c12:	03068713          	addi	a4,a3,48
    80006c16:	973e                	add	a4,a4,a5
    80006c18:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006c1c:	6398                	ld	a4,0(a5)
    80006c1e:	972e                	add	a4,a4,a1
    80006c20:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c24:	4689                	li	a3,2
    80006c26:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006c2a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c2e:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80006c32:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c36:	6794                	ld	a3,8(a5)
    80006c38:	0026d703          	lhu	a4,2(a3)
    80006c3c:	8b1d                	andi	a4,a4,7
    80006c3e:	0706                	slli	a4,a4,0x1
    80006c40:	96ba                	add	a3,a3,a4
    80006c42:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006c46:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c4a:	6798                	ld	a4,8(a5)
    80006c4c:	00275783          	lhu	a5,2(a4)
    80006c50:	2785                	addiw	a5,a5,1
    80006c52:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006c56:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c5a:	100017b7          	lui	a5,0x10001
    80006c5e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c62:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006c66:	00023917          	auipc	s2,0x23
    80006c6a:	30290913          	addi	s2,s2,770 # 80029f68 <disk+0x128>
  while(b->disk == 1) {
    80006c6e:	84c2                	mv	s1,a6
    80006c70:	01079c63          	bne	a5,a6,80006c88 <virtio_disk_rw+0x1c0>
    sleep(b, &disk.vdisk_lock);
    80006c74:	85ca                	mv	a1,s2
    80006c76:	854e                	mv	a0,s3
    80006c78:	ffffc097          	auipc	ra,0xffffc
    80006c7c:	a3c080e7          	jalr	-1476(ra) # 800026b4 <sleep>
  while(b->disk == 1) {
    80006c80:	0049a783          	lw	a5,4(s3)
    80006c84:	fe9788e3          	beq	a5,s1,80006c74 <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80006c88:	fa042903          	lw	s2,-96(s0)
    80006c8c:	00290713          	addi	a4,s2,2
    80006c90:	0712                	slli	a4,a4,0x4
    80006c92:	00023797          	auipc	a5,0x23
    80006c96:	1ae78793          	addi	a5,a5,430 # 80029e40 <disk>
    80006c9a:	97ba                	add	a5,a5,a4
    80006c9c:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006ca0:	00023997          	auipc	s3,0x23
    80006ca4:	1a098993          	addi	s3,s3,416 # 80029e40 <disk>
    80006ca8:	00491713          	slli	a4,s2,0x4
    80006cac:	0009b783          	ld	a5,0(s3)
    80006cb0:	97ba                	add	a5,a5,a4
    80006cb2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006cb6:	854a                	mv	a0,s2
    80006cb8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006cbc:	00000097          	auipc	ra,0x0
    80006cc0:	b8e080e7          	jalr	-1138(ra) # 8000684a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006cc4:	8885                	andi	s1,s1,1
    80006cc6:	f0ed                	bnez	s1,80006ca8 <virtio_disk_rw+0x1e0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006cc8:	00023517          	auipc	a0,0x23
    80006ccc:	2a050513          	addi	a0,a0,672 # 80029f68 <disk+0x128>
    80006cd0:	ffffa097          	auipc	ra,0xffffa
    80006cd4:	01e080e7          	jalr	30(ra) # 80000cee <release>
}
    80006cd8:	60e6                	ld	ra,88(sp)
    80006cda:	6446                	ld	s0,80(sp)
    80006cdc:	64a6                	ld	s1,72(sp)
    80006cde:	6906                	ld	s2,64(sp)
    80006ce0:	79e2                	ld	s3,56(sp)
    80006ce2:	7a42                	ld	s4,48(sp)
    80006ce4:	7aa2                	ld	s5,40(sp)
    80006ce6:	7b02                	ld	s6,32(sp)
    80006ce8:	6be2                	ld	s7,24(sp)
    80006cea:	6c42                	ld	s8,16(sp)
    80006cec:	6125                	addi	sp,sp,96
    80006cee:	8082                	ret

0000000080006cf0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006cf0:	1101                	addi	sp,sp,-32
    80006cf2:	ec06                	sd	ra,24(sp)
    80006cf4:	e822                	sd	s0,16(sp)
    80006cf6:	e426                	sd	s1,8(sp)
    80006cf8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006cfa:	00023497          	auipc	s1,0x23
    80006cfe:	14648493          	addi	s1,s1,326 # 80029e40 <disk>
    80006d02:	00023517          	auipc	a0,0x23
    80006d06:	26650513          	addi	a0,a0,614 # 80029f68 <disk+0x128>
    80006d0a:	ffffa097          	auipc	ra,0xffffa
    80006d0e:	f34080e7          	jalr	-204(ra) # 80000c3e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d12:	100017b7          	lui	a5,0x10001
    80006d16:	53bc                	lw	a5,96(a5)
    80006d18:	8b8d                	andi	a5,a5,3
    80006d1a:	10001737          	lui	a4,0x10001
    80006d1e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006d20:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d24:	689c                	ld	a5,16(s1)
    80006d26:	0204d703          	lhu	a4,32(s1)
    80006d2a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006d2e:	04f70863          	beq	a4,a5,80006d7e <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006d32:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d36:	6898                	ld	a4,16(s1)
    80006d38:	0204d783          	lhu	a5,32(s1)
    80006d3c:	8b9d                	andi	a5,a5,7
    80006d3e:	078e                	slli	a5,a5,0x3
    80006d40:	97ba                	add	a5,a5,a4
    80006d42:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006d44:	00278713          	addi	a4,a5,2
    80006d48:	0712                	slli	a4,a4,0x4
    80006d4a:	9726                	add	a4,a4,s1
    80006d4c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006d50:	e721                	bnez	a4,80006d98 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006d52:	0789                	addi	a5,a5,2
    80006d54:	0792                	slli	a5,a5,0x4
    80006d56:	97a6                	add	a5,a5,s1
    80006d58:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006d5a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006d5e:	ffffc097          	auipc	ra,0xffffc
    80006d62:	9ba080e7          	jalr	-1606(ra) # 80002718 <wakeup>

    disk.used_idx += 1;
    80006d66:	0204d783          	lhu	a5,32(s1)
    80006d6a:	2785                	addiw	a5,a5,1
    80006d6c:	17c2                	slli	a5,a5,0x30
    80006d6e:	93c1                	srli	a5,a5,0x30
    80006d70:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006d74:	6898                	ld	a4,16(s1)
    80006d76:	00275703          	lhu	a4,2(a4)
    80006d7a:	faf71ce3          	bne	a4,a5,80006d32 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006d7e:	00023517          	auipc	a0,0x23
    80006d82:	1ea50513          	addi	a0,a0,490 # 80029f68 <disk+0x128>
    80006d86:	ffffa097          	auipc	ra,0xffffa
    80006d8a:	f68080e7          	jalr	-152(ra) # 80000cee <release>
}
    80006d8e:	60e2                	ld	ra,24(sp)
    80006d90:	6442                	ld	s0,16(sp)
    80006d92:	64a2                	ld	s1,8(sp)
    80006d94:	6105                	addi	sp,sp,32
    80006d96:	8082                	ret
      panic("virtio_disk_intr status");
    80006d98:	00002517          	auipc	a0,0x2
    80006d9c:	97850513          	addi	a0,a0,-1672 # 80008710 <etext+0x710>
    80006da0:	ffff9097          	auipc	ra,0xffff9
    80006da4:	7c0080e7          	jalr	1984(ra) # 80000560 <panic>
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
