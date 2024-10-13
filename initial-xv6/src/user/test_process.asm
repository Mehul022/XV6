
user/_test_process:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_bound>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void cpu_bound()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    volatile int i;
    
    // printf("CPU-bound process started: PID %d\n", getpid());
    for (i = 0; i < 3000000000; i++)
   8:	fe042623          	sw	zero,-20(s0)
   c:	fec42783          	lw	a5,-20(s0)
  10:	fec42783          	lw	a5,-20(s0)
  14:	2785                	addiw	a5,a5,1
  16:	fef42623          	sw	a5,-20(s0)
  1a:	bfcd                	j	c <cpu_bound+0xc>

000000000000001c <cpu_bound2>:
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}
void cpu_bound2()
{
  1c:	1101                	addi	sp,sp,-32
  1e:	ec06                	sd	ra,24(sp)
  20:	e822                	sd	s0,16(sp)
  22:	1000                	addi	s0,sp,32
    volatile int i;

    // printf("CPU-bound process started: PID %d\n", getpid());
    for (i = 0; i < 1500000000; i++)
  24:	fe042623          	sw	zero,-20(s0)
  28:	fec42703          	lw	a4,-20(s0)
  2c:	2701                	sext.w	a4,a4
  2e:	596837b7          	lui	a5,0x59683
  32:	eff78793          	addi	a5,a5,-257 # 59682eff <base+0x59681eef>
  36:	00e7cd63          	blt	a5,a4,50 <cpu_bound2+0x34>
  3a:	873e                	mv	a4,a5
  3c:	fec42783          	lw	a5,-20(s0)
  40:	2785                	addiw	a5,a5,1
  42:	fef42623          	sw	a5,-20(s0)
  46:	fec42783          	lw	a5,-20(s0)
  4a:	2781                	sext.w	a5,a5
  4c:	fef758e3          	bge	a4,a5,3c <cpu_bound2+0x20>
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}
  50:	60e2                	ld	ra,24(sp)
  52:	6442                	ld	s0,16(sp)
  54:	6105                	addi	sp,sp,32
  56:	8082                	ret

0000000000000058 <io_bound>:

void io_bound()
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
    // printf("I/O-bound process started: PID %d\n", getpid());
    for (int i = 0; i < 2; i++)
    {
        sleep(100); // Simulate I/O wait
  60:	06400513          	li	a0,100
  64:	00000097          	auipc	ra,0x0
  68:	3fc080e7          	jalr	1020(ra) # 460 <sleep>
  6c:	06400513          	li	a0,100
  70:	00000097          	auipc	ra,0x0
  74:	3f0080e7          	jalr	1008(ra) # 460 <sleep>
    }
    // printf("I/O-bound process finished: PID %d\n", getpid());
}
  78:	60a2                	ld	ra,8(sp)
  7a:	6402                	ld	s0,0(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <main>:

int main(int argc, char *argv[])
{
  80:	1141                	addi	sp,sp,-16
  82:	e406                	sd	ra,8(sp)
  84:	e022                	sd	s0,0(sp)
  86:	0800                	addi	s0,sp,16
    int pid;
    // for (int i = 0; i < 2; i++)
    // { // 3 CPU-bound processes
        pid = fork();
  88:	00000097          	auipc	ra,0x0
  8c:	340080e7          	jalr	832(ra) # 3c8 <fork>
        if (pid == 0)
  90:	e509                	bnez	a0,9a <main+0x1a>
        {
            cpu_bound();
  92:	00000097          	auipc	ra,0x0
  96:	f6e080e7          	jalr	-146(ra) # 0 <cpu_bound>
            exit(0);
        }
        pid = fork();
  9a:	00000097          	auipc	ra,0x0
  9e:	32e080e7          	jalr	814(ra) # 3c8 <fork>
        if (pid == 0)
  a2:	c921                	beqz	a0,f2 <main+0x72>
            exit(0);
        }
    // }
    for (int i = 0; i < 2; i++)
    { // 2 I/O-bound processes
        pid = fork();
  a4:	00000097          	auipc	ra,0x0
  a8:	324080e7          	jalr	804(ra) # 3c8 <fork>
        if (pid == 0)
  ac:	cd21                	beqz	a0,104 <main+0x84>
        pid = fork();
  ae:	00000097          	auipc	ra,0x0
  b2:	31a080e7          	jalr	794(ra) # 3c8 <fork>
        if (pid == 0)
  b6:	c539                	beqz	a0,104 <main+0x84>
        {
            io_bound();
            exit(0);
        }
    }
    pid=fork();
  b8:	00000097          	auipc	ra,0x0
  bc:	310080e7          	jalr	784(ra) # 3c8 <fork>
    for (int i = 0; i < 4; i++)
    { // Wait for child processes
        wait(0);
  c0:	4501                	li	a0,0
  c2:	00000097          	auipc	ra,0x0
  c6:	316080e7          	jalr	790(ra) # 3d8 <wait>
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	30c080e7          	jalr	780(ra) # 3d8 <wait>
  d4:	4501                	li	a0,0
  d6:	00000097          	auipc	ra,0x0
  da:	302080e7          	jalr	770(ra) # 3d8 <wait>
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	2f8080e7          	jalr	760(ra) # 3d8 <wait>
    }
    exit(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	2e6080e7          	jalr	742(ra) # 3d0 <exit>
            cpu_bound2();
  f2:	00000097          	auipc	ra,0x0
  f6:	f2a080e7          	jalr	-214(ra) # 1c <cpu_bound2>
            exit(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	2d4080e7          	jalr	724(ra) # 3d0 <exit>
            io_bound();
 104:	00000097          	auipc	ra,0x0
 108:	f54080e7          	jalr	-172(ra) # 58 <io_bound>
            exit(0);
 10c:	4501                	li	a0,0
 10e:	00000097          	auipc	ra,0x0
 112:	2c2080e7          	jalr	706(ra) # 3d0 <exit>

0000000000000116 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 116:	1141                	addi	sp,sp,-16
 118:	e406                	sd	ra,8(sp)
 11a:	e022                	sd	s0,0(sp)
 11c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11e:	00000097          	auipc	ra,0x0
 122:	f62080e7          	jalr	-158(ra) # 80 <main>
  exit(0);
 126:	4501                	li	a0,0
 128:	00000097          	auipc	ra,0x0
 12c:	2a8080e7          	jalr	680(ra) # 3d0 <exit>

0000000000000130 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 130:	1141                	addi	sp,sp,-16
 132:	e406                	sd	ra,8(sp)
 134:	e022                	sd	s0,0(sp)
 136:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 138:	87aa                	mv	a5,a0
 13a:	0585                	addi	a1,a1,1
 13c:	0785                	addi	a5,a5,1
 13e:	fff5c703          	lbu	a4,-1(a1)
 142:	fee78fa3          	sb	a4,-1(a5)
 146:	fb75                	bnez	a4,13a <strcpy+0xa>
    ;
  return os;
}
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 150:	1141                	addi	sp,sp,-16
 152:	e406                	sd	ra,8(sp)
 154:	e022                	sd	s0,0(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x20>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x20>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	60a2                	ld	ra,8(sp)
 17a:	6402                	ld	s0,0(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cf99                	beqz	a5,1aa <strlen+0x2a>
 18e:	0505                	addi	a0,a0,1
 190:	87aa                	mv	a5,a0
 192:	86be                	mv	a3,a5
 194:	0785                	addi	a5,a5,1
 196:	fff7c703          	lbu	a4,-1(a5)
 19a:	ff65                	bnez	a4,192 <strlen+0x12>
 19c:	40a6853b          	subw	a0,a3,a0
 1a0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  for(n = 0; s[n]; n++)
 1aa:	4501                	li	a0,0
 1ac:	bfdd                	j	1a2 <strlen+0x22>

00000000000001ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b6:	ca19                	beqz	a2,1cc <memset+0x1e>
 1b8:	87aa                	mv	a5,a0
 1ba:	1602                	slli	a2,a2,0x20
 1bc:	9201                	srli	a2,a2,0x20
 1be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c6:	0785                	addi	a5,a5,1
 1c8:	fee79de3          	bne	a5,a4,1c2 <memset+0x14>
  }
  return dst;
}
 1cc:	60a2                	ld	ra,8(sp)
 1ce:	6402                	ld	s0,0(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret

00000000000001d4 <strchr>:

char*
strchr(const char *s, char c)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cf81                	beqz	a5,1f8 <strchr+0x24>
    if(*s == c)
 1e2:	00f58763          	beq	a1,a5,1f0 <strchr+0x1c>
  for(; *s; s++)
 1e6:	0505                	addi	a0,a0,1
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	fbfd                	bnez	a5,1e2 <strchr+0xe>
      return (char*)s;
  return 0;
 1ee:	4501                	li	a0,0
}
 1f0:	60a2                	ld	ra,8(sp)
 1f2:	6402                	ld	s0,0(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  return 0;
 1f8:	4501                	li	a0,0
 1fa:	bfdd                	j	1f0 <strchr+0x1c>

00000000000001fc <gets>:

char*
gets(char *buf, int max)
{
 1fc:	7159                	addi	sp,sp,-112
 1fe:	f486                	sd	ra,104(sp)
 200:	f0a2                	sd	s0,96(sp)
 202:	eca6                	sd	s1,88(sp)
 204:	e8ca                	sd	s2,80(sp)
 206:	e4ce                	sd	s3,72(sp)
 208:	e0d2                	sd	s4,64(sp)
 20a:	fc56                	sd	s5,56(sp)
 20c:	f85a                	sd	s6,48(sp)
 20e:	f45e                	sd	s7,40(sp)
 210:	f062                	sd	s8,32(sp)
 212:	ec66                	sd	s9,24(sp)
 214:	e86a                	sd	s10,16(sp)
 216:	1880                	addi	s0,sp,112
 218:	8caa                	mv	s9,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 220:	f9f40b13          	addi	s6,s0,-97
 224:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 226:	4ba9                	li	s7,10
 228:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 22a:	8d26                	mv	s10,s1
 22c:	0014899b          	addiw	s3,s1,1
 230:	84ce                	mv	s1,s3
 232:	0349d763          	bge	s3,s4,260 <gets+0x64>
    cc = read(0, &c, 1);
 236:	8656                	mv	a2,s5
 238:	85da                	mv	a1,s6
 23a:	4501                	li	a0,0
 23c:	00000097          	auipc	ra,0x0
 240:	1ac080e7          	jalr	428(ra) # 3e8 <read>
    if(cc < 1)
 244:	00a05e63          	blez	a0,260 <gets+0x64>
    buf[i++] = c;
 248:	f9f44783          	lbu	a5,-97(s0)
 24c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 250:	01778763          	beq	a5,s7,25e <gets+0x62>
 254:	0905                	addi	s2,s2,1
 256:	fd879ae3          	bne	a5,s8,22a <gets+0x2e>
    buf[i++] = c;
 25a:	8d4e                	mv	s10,s3
 25c:	a011                	j	260 <gets+0x64>
 25e:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 260:	9d66                	add	s10,s10,s9
 262:	000d0023          	sb	zero,0(s10)
  return buf;
}
 266:	8566                	mv	a0,s9
 268:	70a6                	ld	ra,104(sp)
 26a:	7406                	ld	s0,96(sp)
 26c:	64e6                	ld	s1,88(sp)
 26e:	6946                	ld	s2,80(sp)
 270:	69a6                	ld	s3,72(sp)
 272:	6a06                	ld	s4,64(sp)
 274:	7ae2                	ld	s5,56(sp)
 276:	7b42                	ld	s6,48(sp)
 278:	7ba2                	ld	s7,40(sp)
 27a:	7c02                	ld	s8,32(sp)
 27c:	6ce2                	ld	s9,24(sp)
 27e:	6d42                	ld	s10,16(sp)
 280:	6165                	addi	sp,sp,112
 282:	8082                	ret

0000000000000284 <stat>:

int
stat(const char *n, struct stat *st)
{
 284:	1101                	addi	sp,sp,-32
 286:	ec06                	sd	ra,24(sp)
 288:	e822                	sd	s0,16(sp)
 28a:	e04a                	sd	s2,0(sp)
 28c:	1000                	addi	s0,sp,32
 28e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 290:	4581                	li	a1,0
 292:	00000097          	auipc	ra,0x0
 296:	17e080e7          	jalr	382(ra) # 410 <open>
  if(fd < 0)
 29a:	02054663          	bltz	a0,2c6 <stat+0x42>
 29e:	e426                	sd	s1,8(sp)
 2a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a2:	85ca                	mv	a1,s2
 2a4:	00000097          	auipc	ra,0x0
 2a8:	184080e7          	jalr	388(ra) # 428 <fstat>
 2ac:	892a                	mv	s2,a0
  close(fd);
 2ae:	8526                	mv	a0,s1
 2b0:	00000097          	auipc	ra,0x0
 2b4:	148080e7          	jalr	328(ra) # 3f8 <close>
  return r;
 2b8:	64a2                	ld	s1,8(sp)
}
 2ba:	854a                	mv	a0,s2
 2bc:	60e2                	ld	ra,24(sp)
 2be:	6442                	ld	s0,16(sp)
 2c0:	6902                	ld	s2,0(sp)
 2c2:	6105                	addi	sp,sp,32
 2c4:	8082                	ret
    return -1;
 2c6:	597d                	li	s2,-1
 2c8:	bfcd                	j	2ba <stat+0x36>

00000000000002ca <atoi>:

int
atoi(const char *s)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d2:	00054683          	lbu	a3,0(a0)
 2d6:	fd06879b          	addiw	a5,a3,-48
 2da:	0ff7f793          	zext.b	a5,a5
 2de:	4625                	li	a2,9
 2e0:	02f66963          	bltu	a2,a5,312 <atoi+0x48>
 2e4:	872a                	mv	a4,a0
  n = 0;
 2e6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e8:	0705                	addi	a4,a4,1
 2ea:	0025179b          	slliw	a5,a0,0x2
 2ee:	9fa9                	addw	a5,a5,a0
 2f0:	0017979b          	slliw	a5,a5,0x1
 2f4:	9fb5                	addw	a5,a5,a3
 2f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fa:	00074683          	lbu	a3,0(a4)
 2fe:	fd06879b          	addiw	a5,a3,-48
 302:	0ff7f793          	zext.b	a5,a5
 306:	fef671e3          	bgeu	a2,a5,2e8 <atoi+0x1e>
  return n;
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfdd                	j	30a <atoi+0x40>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31e:	02b57563          	bgeu	a0,a1,348 <memmove+0x32>
    while(n-- > 0)
 322:	00c05f63          	blez	a2,340 <memmove+0x2a>
 326:	1602                	slli	a2,a2,0x20
 328:	9201                	srli	a2,a2,0x20
 32a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32e:	872a                	mv	a4,a0
      *dst++ = *src++;
 330:	0585                	addi	a1,a1,1
 332:	0705                	addi	a4,a4,1
 334:	fff5c683          	lbu	a3,-1(a1)
 338:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33c:	fee79ae3          	bne	a5,a4,330 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
    dst += n;
 348:	00c50733          	add	a4,a0,a2
    src += n;
 34c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34e:	fec059e3          	blez	a2,340 <memmove+0x2a>
 352:	fff6079b          	addiw	a5,a2,-1
 356:	1782                	slli	a5,a5,0x20
 358:	9381                	srli	a5,a5,0x20
 35a:	fff7c793          	not	a5,a5
 35e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 360:	15fd                	addi	a1,a1,-1
 362:	177d                	addi	a4,a4,-1
 364:	0005c683          	lbu	a3,0(a1)
 368:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36c:	fef71ae3          	bne	a4,a5,360 <memmove+0x4a>
 370:	bfc1                	j	340 <memmove+0x2a>

0000000000000372 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37a:	ca0d                	beqz	a2,3ac <memcmp+0x3a>
 37c:	fff6069b          	addiw	a3,a2,-1
 380:	1682                	slli	a3,a3,0x20
 382:	9281                	srli	a3,a3,0x20
 384:	0685                	addi	a3,a3,1
 386:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 388:	00054783          	lbu	a5,0(a0)
 38c:	0005c703          	lbu	a4,0(a1)
 390:	00e79863          	bne	a5,a4,3a0 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 394:	0505                	addi	a0,a0,1
    p2++;
 396:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 398:	fed518e3          	bne	a0,a3,388 <memcmp+0x16>
  }
  return 0;
 39c:	4501                	li	a0,0
 39e:	a019                	j	3a4 <memcmp+0x32>
      return *p1 - *p2;
 3a0:	40e7853b          	subw	a0,a5,a4
}
 3a4:	60a2                	ld	ra,8(sp)
 3a6:	6402                	ld	s0,0(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	bfdd                	j	3a4 <memcmp+0x32>

00000000000003b0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b8:	00000097          	auipc	ra,0x0
 3bc:	f5e080e7          	jalr	-162(ra) # 316 <memmove>
}
 3c0:	60a2                	ld	ra,8(sp)
 3c2:	6402                	ld	s0,0(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret

00000000000003c8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c8:	4885                	li	a7,1
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d0:	4889                	li	a7,2
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d8:	488d                	li	a7,3
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e0:	4891                	li	a7,4
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <read>:
.global read
read:
 li a7, SYS_read
 3e8:	4895                	li	a7,5
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <write>:
.global write
write:
 li a7, SYS_write
 3f0:	48c1                	li	a7,16
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <close>:
.global close
close:
 li a7, SYS_close
 3f8:	48d5                	li	a7,21
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <kill>:
.global kill
kill:
 li a7, SYS_kill
 400:	4899                	li	a7,6
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <exec>:
.global exec
exec:
 li a7, SYS_exec
 408:	489d                	li	a7,7
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <open>:
.global open
open:
 li a7, SYS_open
 410:	48bd                	li	a7,15
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 418:	48c5                	li	a7,17
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 420:	48c9                	li	a7,18
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 428:	48a1                	li	a7,8
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <link>:
.global link
link:
 li a7, SYS_link
 430:	48cd                	li	a7,19
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 438:	48d1                	li	a7,20
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 440:	48a5                	li	a7,9
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <dup>:
.global dup
dup:
 li a7, SYS_dup
 448:	48a9                	li	a7,10
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 450:	48ad                	li	a7,11
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 458:	48b1                	li	a7,12
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 460:	48b5                	li	a7,13
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 468:	48b9                	li	a7,14
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 470:	48d9                	li	a7,22
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 478:	48dd                	li	a7,23
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 480:	48e1                	li	a7,24
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 488:	48e5                	li	a7,25
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 490:	1101                	addi	sp,sp,-32
 492:	ec06                	sd	ra,24(sp)
 494:	e822                	sd	s0,16(sp)
 496:	1000                	addi	s0,sp,32
 498:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49c:	4605                	li	a2,1
 49e:	fef40593          	addi	a1,s0,-17
 4a2:	00000097          	auipc	ra,0x0
 4a6:	f4e080e7          	jalr	-178(ra) # 3f0 <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b2:	7139                	addi	sp,sp,-64
 4b4:	fc06                	sd	ra,56(sp)
 4b6:	f822                	sd	s0,48(sp)
 4b8:	f426                	sd	s1,40(sp)
 4ba:	f04a                	sd	s2,32(sp)
 4bc:	ec4e                	sd	s3,24(sp)
 4be:	0080                	addi	s0,sp,64
 4c0:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c2:	c299                	beqz	a3,4c8 <printint+0x16>
 4c4:	0805c063          	bltz	a1,544 <printint+0x92>
  neg = 0;
 4c8:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ca:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4ce:	869a                	mv	a3,t1
  i = 0;
 4d0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4d2:	00000817          	auipc	a6,0x0
 4d6:	48e80813          	addi	a6,a6,1166 # 960 <digits>
 4da:	88be                	mv	a7,a5
 4dc:	0017851b          	addiw	a0,a5,1
 4e0:	87aa                	mv	a5,a0
 4e2:	02c5f73b          	remuw	a4,a1,a2
 4e6:	1702                	slli	a4,a4,0x20
 4e8:	9301                	srli	a4,a4,0x20
 4ea:	9742                	add	a4,a4,a6
 4ec:	00074703          	lbu	a4,0(a4)
 4f0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4f4:	872e                	mv	a4,a1
 4f6:	02c5d5bb          	divuw	a1,a1,a2
 4fa:	0685                	addi	a3,a3,1
 4fc:	fcc77fe3          	bgeu	a4,a2,4da <printint+0x28>
  if(neg)
 500:	000e0c63          	beqz	t3,518 <printint+0x66>
    buf[i++] = '-';
 504:	fd050793          	addi	a5,a0,-48
 508:	00878533          	add	a0,a5,s0
 50c:	02d00793          	li	a5,45
 510:	fef50823          	sb	a5,-16(a0)
 514:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 518:	fff7899b          	addiw	s3,a5,-1
 51c:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 520:	fff4c583          	lbu	a1,-1(s1)
 524:	854a                	mv	a0,s2
 526:	00000097          	auipc	ra,0x0
 52a:	f6a080e7          	jalr	-150(ra) # 490 <putc>
  while(--i >= 0)
 52e:	39fd                	addiw	s3,s3,-1
 530:	14fd                	addi	s1,s1,-1
 532:	fe09d7e3          	bgez	s3,520 <printint+0x6e>
}
 536:	70e2                	ld	ra,56(sp)
 538:	7442                	ld	s0,48(sp)
 53a:	74a2                	ld	s1,40(sp)
 53c:	7902                	ld	s2,32(sp)
 53e:	69e2                	ld	s3,24(sp)
 540:	6121                	addi	sp,sp,64
 542:	8082                	ret
    x = -xx;
 544:	40b005bb          	negw	a1,a1
    neg = 1;
 548:	4e05                	li	t3,1
    x = -xx;
 54a:	b741                	j	4ca <printint+0x18>

000000000000054c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54c:	715d                	addi	sp,sp,-80
 54e:	e486                	sd	ra,72(sp)
 550:	e0a2                	sd	s0,64(sp)
 552:	f84a                	sd	s2,48(sp)
 554:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 556:	0005c903          	lbu	s2,0(a1)
 55a:	1a090a63          	beqz	s2,70e <vprintf+0x1c2>
 55e:	fc26                	sd	s1,56(sp)
 560:	f44e                	sd	s3,40(sp)
 562:	f052                	sd	s4,32(sp)
 564:	ec56                	sd	s5,24(sp)
 566:	e85a                	sd	s6,16(sp)
 568:	e45e                	sd	s7,8(sp)
 56a:	8aaa                	mv	s5,a0
 56c:	8bb2                	mv	s7,a2
 56e:	00158493          	addi	s1,a1,1
  state = 0;
 572:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 574:	02500a13          	li	s4,37
 578:	4b55                	li	s6,21
 57a:	a839                	j	598 <vprintf+0x4c>
        putc(fd, c);
 57c:	85ca                	mv	a1,s2
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	f10080e7          	jalr	-240(ra) # 490 <putc>
 588:	a019                	j	58e <vprintf+0x42>
    } else if(state == '%'){
 58a:	01498d63          	beq	s3,s4,5a4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 58e:	0485                	addi	s1,s1,1
 590:	fff4c903          	lbu	s2,-1(s1)
 594:	16090763          	beqz	s2,702 <vprintf+0x1b6>
    if(state == 0){
 598:	fe0999e3          	bnez	s3,58a <vprintf+0x3e>
      if(c == '%'){
 59c:	ff4910e3          	bne	s2,s4,57c <vprintf+0x30>
        state = '%';
 5a0:	89d2                	mv	s3,s4
 5a2:	b7f5                	j	58e <vprintf+0x42>
      if(c == 'd'){
 5a4:	13490463          	beq	s2,s4,6cc <vprintf+0x180>
 5a8:	f9d9079b          	addiw	a5,s2,-99
 5ac:	0ff7f793          	zext.b	a5,a5
 5b0:	12fb6763          	bltu	s6,a5,6de <vprintf+0x192>
 5b4:	f9d9079b          	addiw	a5,s2,-99
 5b8:	0ff7f713          	zext.b	a4,a5
 5bc:	12eb6163          	bltu	s6,a4,6de <vprintf+0x192>
 5c0:	00271793          	slli	a5,a4,0x2
 5c4:	00000717          	auipc	a4,0x0
 5c8:	34470713          	addi	a4,a4,836 # 908 <malloc+0x106>
 5cc:	97ba                	add	a5,a5,a4
 5ce:	439c                	lw	a5,0(a5)
 5d0:	97ba                	add	a5,a5,a4
 5d2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000ba583          	lw	a1,0(s7)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	ed0080e7          	jalr	-304(ra) # 4b2 <printint>
 5ea:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b745                	j	58e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000ba583          	lw	a1,0(s7)
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	eb4080e7          	jalr	-332(ra) # 4b2 <printint>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	b751                	j	58e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4641                	li	a2,16
 614:	000ba583          	lw	a1,0(s7)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e98080e7          	jalr	-360(ra) # 4b2 <printint>
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
 626:	b7a5                	j	58e <vprintf+0x42>
 628:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 62a:	008b8c13          	addi	s8,s7,8
 62e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 632:	03000593          	li	a1,48
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e58080e7          	jalr	-424(ra) # 490 <putc>
  putc(fd, 'x');
 640:	07800593          	li	a1,120
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e4a080e7          	jalr	-438(ra) # 490 <putc>
 64e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 650:	00000b97          	auipc	s7,0x0
 654:	310b8b93          	addi	s7,s7,784 # 960 <digits>
 658:	03c9d793          	srli	a5,s3,0x3c
 65c:	97de                	add	a5,a5,s7
 65e:	0007c583          	lbu	a1,0(a5)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e2c080e7          	jalr	-468(ra) # 490 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66c:	0992                	slli	s3,s3,0x4
 66e:	397d                	addiw	s2,s2,-1
 670:	fe0914e3          	bnez	s2,658 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 674:	8be2                	mv	s7,s8
      state = 0;
 676:	4981                	li	s3,0
 678:	6c02                	ld	s8,0(sp)
 67a:	bf11                	j	58e <vprintf+0x42>
        s = va_arg(ap, char*);
 67c:	008b8993          	addi	s3,s7,8
 680:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 684:	02090163          	beqz	s2,6a6 <vprintf+0x15a>
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	c9a5                	beqz	a1,6fc <vprintf+0x1b0>
          putc(fd, *s);
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e00080e7          	jalr	-512(ra) # 490 <putc>
          s++;
 698:	0905                	addi	s2,s2,1
        while(*s != 0){
 69a:	00094583          	lbu	a1,0(s2)
 69e:	f9e5                	bnez	a1,68e <vprintf+0x142>
        s = va_arg(ap, char*);
 6a0:	8bce                	mv	s7,s3
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b5ed                	j	58e <vprintf+0x42>
          s = "(null)";
 6a6:	00000917          	auipc	s2,0x0
 6aa:	25a90913          	addi	s2,s2,602 # 900 <malloc+0xfe>
        while(*s != 0){
 6ae:	02800593          	li	a1,40
 6b2:	bff1                	j	68e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	000bc583          	lbu	a1,0(s7)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	dd2080e7          	jalr	-558(ra) # 490 <putc>
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b5d1                	j	58e <vprintf+0x42>
        putc(fd, c);
 6cc:	02500593          	li	a1,37
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	dbe080e7          	jalr	-578(ra) # 490 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd4d                	j	58e <vprintf+0x42>
        putc(fd, '%');
 6de:	02500593          	li	a1,37
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dac080e7          	jalr	-596(ra) # 490 <putc>
        putc(fd, c);
 6ec:	85ca                	mv	a1,s2
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	da0080e7          	jalr	-608(ra) # 490 <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd51                	j	58e <vprintf+0x42>
        s = va_arg(ap, char*);
 6fc:	8bce                	mv	s7,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b579                	j	58e <vprintf+0x42>
 702:	74e2                	ld	s1,56(sp)
 704:	79a2                	ld	s3,40(sp)
 706:	7a02                	ld	s4,32(sp)
 708:	6ae2                	ld	s5,24(sp)
 70a:	6b42                	ld	s6,16(sp)
 70c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 70e:	60a6                	ld	ra,72(sp)
 710:	6406                	ld	s0,64(sp)
 712:	7942                	ld	s2,48(sp)
 714:	6161                	addi	sp,sp,80
 716:	8082                	ret

0000000000000718 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 718:	715d                	addi	sp,sp,-80
 71a:	ec06                	sd	ra,24(sp)
 71c:	e822                	sd	s0,16(sp)
 71e:	1000                	addi	s0,sp,32
 720:	e010                	sd	a2,0(s0)
 722:	e414                	sd	a3,8(s0)
 724:	e818                	sd	a4,16(s0)
 726:	ec1c                	sd	a5,24(s0)
 728:	03043023          	sd	a6,32(s0)
 72c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	8622                	mv	a2,s0
 732:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 736:	00000097          	auipc	ra,0x0
 73a:	e16080e7          	jalr	-490(ra) # 54c <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6161                	addi	sp,sp,80
 744:	8082                	ret

0000000000000746 <printf>:

void
printf(const char *fmt, ...)
{
 746:	711d                	addi	sp,sp,-96
 748:	ec06                	sd	ra,24(sp)
 74a:	e822                	sd	s0,16(sp)
 74c:	1000                	addi	s0,sp,32
 74e:	e40c                	sd	a1,8(s0)
 750:	e810                	sd	a2,16(s0)
 752:	ec14                	sd	a3,24(s0)
 754:	f018                	sd	a4,32(s0)
 756:	f41c                	sd	a5,40(s0)
 758:	03043823          	sd	a6,48(s0)
 75c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	00840613          	addi	a2,s0,8
 764:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 768:	85aa                	mv	a1,a0
 76a:	4505                	li	a0,1
 76c:	00000097          	auipc	ra,0x0
 770:	de0080e7          	jalr	-544(ra) # 54c <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6125                	addi	sp,sp,96
 77a:	8082                	ret

000000000000077c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77c:	1141                	addi	sp,sp,-16
 77e:	e406                	sd	ra,8(sp)
 780:	e022                	sd	s0,0(sp)
 782:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 784:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00001797          	auipc	a5,0x1
 78c:	8787b783          	ld	a5,-1928(a5) # 1000 <freep>
 790:	a02d                	j	7ba <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 792:	4618                	lw	a4,8(a2)
 794:	9f2d                	addw	a4,a4,a1
 796:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	6310                	ld	a2,0(a4)
 79e:	a83d                	j	7dc <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9f31                	addw	a4,a4,a2
 7a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053683          	ld	a3,-16(a0)
 7ac:	a091                	j	7f0 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e7e463          	bltu	a5,a4,7b8 <free+0x3c>
 7b4:	00e6ea63          	bltu	a3,a4,7c8 <free+0x4c>
{
 7b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	fed7fae3          	bgeu	a5,a3,7ae <free+0x32>
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e6e463          	bltu	a3,a4,7c8 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	fee7eae3          	bltu	a5,a4,7b8 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7c8:	ff852583          	lw	a1,-8(a0)
 7cc:	6390                	ld	a2,0(a5)
 7ce:	02059813          	slli	a6,a1,0x20
 7d2:	01c85713          	srli	a4,a6,0x1c
 7d6:	9736                	add	a4,a4,a3
 7d8:	fae60de3          	beq	a2,a4,792 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e0:	4790                	lw	a2,8(a5)
 7e2:	02061593          	slli	a1,a2,0x20
 7e6:	01c5d713          	srli	a4,a1,0x1c
 7ea:	973e                	add	a4,a4,a5
 7ec:	fae68ae3          	beq	a3,a4,7a0 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f2:	00001717          	auipc	a4,0x1
 7f6:	80f73723          	sd	a5,-2034(a4) # 1000 <freep>
}
 7fa:	60a2                	ld	ra,8(sp)
 7fc:	6402                	ld	s0,0(sp)
 7fe:	0141                	addi	sp,sp,16
 800:	8082                	ret

0000000000000802 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 802:	7139                	addi	sp,sp,-64
 804:	fc06                	sd	ra,56(sp)
 806:	f822                	sd	s0,48(sp)
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80e:	02051993          	slli	s3,a0,0x20
 812:	0209d993          	srli	s3,s3,0x20
 816:	09bd                	addi	s3,s3,15
 818:	0049d993          	srli	s3,s3,0x4
 81c:	2985                	addiw	s3,s3,1
 81e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 820:	00000517          	auipc	a0,0x0
 824:	7e053503          	ld	a0,2016(a0) # 1000 <freep>
 828:	c905                	beqz	a0,858 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	09377a63          	bgeu	a4,s3,8c2 <malloc+0xc0>
 832:	f426                	sd	s1,40(sp)
 834:	e852                	sd	s4,16(sp)
 836:	e456                	sd	s5,8(sp)
 838:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 83a:	8a4e                	mv	s4,s3
 83c:	6705                	lui	a4,0x1
 83e:	00e9f363          	bgeu	s3,a4,844 <malloc+0x42>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84c:	00000497          	auipc	s1,0x0
 850:	7b448493          	addi	s1,s1,1972 # 1000 <freep>
  if(p == (char*)-1)
 854:	5afd                	li	s5,-1
 856:	a089                	j	898 <malloc+0x96>
 858:	f426                	sd	s1,40(sp)
 85a:	e852                	sd	s4,16(sp)
 85c:	e456                	sd	s5,8(sp)
 85e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 860:	00000797          	auipc	a5,0x0
 864:	7b078793          	addi	a5,a5,1968 # 1010 <base>
 868:	00000717          	auipc	a4,0x0
 86c:	78f73c23          	sd	a5,1944(a4) # 1000 <freep>
 870:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 872:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 876:	b7d1                	j	83a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	e118                	sd	a4,0(a0)
 87c:	a8b9                	j	8da <malloc+0xd8>
  hp->s.size = nu;
 87e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 882:	0541                	addi	a0,a0,16
 884:	00000097          	auipc	ra,0x0
 888:	ef8080e7          	jalr	-264(ra) # 77c <free>
  return freep;
 88c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 88e:	c135                	beqz	a0,8f2 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	03277363          	bgeu	a4,s2,8ba <malloc+0xb8>
    if(p == freep)
 898:	6098                	ld	a4,0(s1)
 89a:	853e                	mv	a0,a5
 89c:	fef71ae3          	bne	a4,a5,890 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8a0:	8552                	mv	a0,s4
 8a2:	00000097          	auipc	ra,0x0
 8a6:	bb6080e7          	jalr	-1098(ra) # 458 <sbrk>
  if(p == (char*)-1)
 8aa:	fd551ae3          	bne	a0,s5,87e <malloc+0x7c>
        return 0;
 8ae:	4501                	li	a0,0
 8b0:	74a2                	ld	s1,40(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	a03d                	j	8e6 <malloc+0xe4>
 8ba:	74a2                	ld	s1,40(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8c2:	fae90be3          	beq	s2,a4,878 <malloc+0x76>
        p->s.size -= nunits;
 8c6:	4137073b          	subw	a4,a4,s3
 8ca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8cc:	02071693          	slli	a3,a4,0x20
 8d0:	01c6d713          	srli	a4,a3,0x1c
 8d4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8da:	00000717          	auipc	a4,0x0
 8de:	72a73323          	sd	a0,1830(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e2:	01078513          	addi	a0,a5,16
  }
}
 8e6:	70e2                	ld	ra,56(sp)
 8e8:	7442                	ld	s0,48(sp)
 8ea:	7902                	ld	s2,32(sp)
 8ec:	69e2                	ld	s3,24(sp)
 8ee:	6121                	addi	sp,sp,64
 8f0:	8082                	ret
 8f2:	74a2                	ld	s1,40(sp)
 8f4:	6a42                	ld	s4,16(sp)
 8f6:	6aa2                	ld	s5,8(sp)
 8f8:	6b02                	ld	s6,0(sp)
 8fa:	b7f5                	j	8e6 <malloc+0xe4>
