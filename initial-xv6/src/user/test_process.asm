
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
    for (i = 0; i < 2000000000; i++)
   8:	fe042623          	sw	zero,-20(s0)
   c:	fec42703          	lw	a4,-20(s0)
  10:	2701                	sext.w	a4,a4
  12:	773597b7          	lui	a5,0x77359
  16:	3ff78793          	addi	a5,a5,1023 # 773593ff <base+0x773583ef>
  1a:	00e7cd63          	blt	a5,a4,34 <cpu_bound+0x34>
  1e:	873e                	mv	a4,a5
  20:	fec42783          	lw	a5,-20(s0)
  24:	2785                	addiw	a5,a5,1
  26:	fef42623          	sw	a5,-20(s0)
  2a:	fec42783          	lw	a5,-20(s0)
  2e:	2781                	sext.w	a5,a5
  30:	fef758e3          	bge	a4,a5,20 <cpu_bound+0x20>
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}
  34:	60e2                	ld	ra,24(sp)
  36:	6442                	ld	s0,16(sp)
  38:	6105                	addi	sp,sp,32
  3a:	8082                	ret

000000000000003c <cpu_bound2>:
void cpu_bound2()
{
  3c:	1101                	addi	sp,sp,-32
  3e:	ec06                	sd	ra,24(sp)
  40:	e822                	sd	s0,16(sp)
  42:	1000                	addi	s0,sp,32
    volatile int i;

    // printf("CPU-bound process started: PID %d\n", getpid());
    for (i = 0; i < 1500000000; i++)
  44:	fe042623          	sw	zero,-20(s0)
  48:	fec42703          	lw	a4,-20(s0)
  4c:	2701                	sext.w	a4,a4
  4e:	596837b7          	lui	a5,0x59683
  52:	eff78793          	addi	a5,a5,-257 # 59682eff <base+0x59681eef>
  56:	00e7cd63          	blt	a5,a4,70 <cpu_bound2+0x34>
  5a:	873e                	mv	a4,a5
  5c:	fec42783          	lw	a5,-20(s0)
  60:	2785                	addiw	a5,a5,1
  62:	fef42623          	sw	a5,-20(s0)
  66:	fec42783          	lw	a5,-20(s0)
  6a:	2781                	sext.w	a5,a5
  6c:	fef758e3          	bge	a4,a5,5c <cpu_bound2+0x20>
        ; // Busy wait (CPU-bound)
    // printf("CPU-bound process finished: PID %d\n", getpid());
}
  70:	60e2                	ld	ra,24(sp)
  72:	6442                	ld	s0,16(sp)
  74:	6105                	addi	sp,sp,32
  76:	8082                	ret

0000000000000078 <io_bound>:

void io_bound()
{
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
    // printf("I/O-bound process started: PID %d\n", getpid());
    for (int i = 0; i < 2; i++)
    {
        sleep(10); // Simulate I/O wait
  80:	4529                	li	a0,10
  82:	00000097          	auipc	ra,0x0
  86:	404080e7          	jalr	1028(ra) # 486 <sleep>
  8a:	4529                	li	a0,10
  8c:	00000097          	auipc	ra,0x0
  90:	3fa080e7          	jalr	1018(ra) # 486 <sleep>
    }
    // printf("I/O-bound process finished: PID %d\n", getpid());
}
  94:	60a2                	ld	ra,8(sp)
  96:	6402                	ld	s0,0(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret

000000000000009c <main>:

int main(int argc, char *argv[])
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e406                	sd	ra,8(sp)
  a0:	e022                	sd	s0,0(sp)
  a2:	0800                	addi	s0,sp,16
    int pid;
    // for (int i = 0; i < 2; i++)
    // { // 3 CPU-bound processes
        pid = fork();
  a4:	00000097          	auipc	ra,0x0
  a8:	34a080e7          	jalr	842(ra) # 3ee <fork>
        if (pid == 0)
  ac:	e911                	bnez	a0,c0 <main+0x24>
        {
            cpu_bound();
  ae:	00000097          	auipc	ra,0x0
  b2:	f52080e7          	jalr	-174(ra) # 0 <cpu_bound>
            exit(0);
  b6:	4501                	li	a0,0
  b8:	00000097          	auipc	ra,0x0
  bc:	33e080e7          	jalr	830(ra) # 3f6 <exit>
        }
        pid = fork();
  c0:	00000097          	auipc	ra,0x0
  c4:	32e080e7          	jalr	814(ra) # 3ee <fork>
        if (pid == 0)
  c8:	c921                	beqz	a0,118 <main+0x7c>
            exit(0);
        }
    // }
    for (int i = 0; i < 2; i++)
    { // 2 I/O-bound processes
        pid = fork();
  ca:	00000097          	auipc	ra,0x0
  ce:	324080e7          	jalr	804(ra) # 3ee <fork>
        if (pid == 0)
  d2:	cd21                	beqz	a0,12a <main+0x8e>
        pid = fork();
  d4:	00000097          	auipc	ra,0x0
  d8:	31a080e7          	jalr	794(ra) # 3ee <fork>
        if (pid == 0)
  dc:	c539                	beqz	a0,12a <main+0x8e>
        {
            io_bound();
            exit(0);
        }
    }
    pid=fork();
  de:	00000097          	auipc	ra,0x0
  e2:	310080e7          	jalr	784(ra) # 3ee <fork>
    for (int i = 0; i < 4; i++)
    { // Wait for child processes
        wait(0);
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	316080e7          	jalr	790(ra) # 3fe <wait>
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	30c080e7          	jalr	780(ra) # 3fe <wait>
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	302080e7          	jalr	770(ra) # 3fe <wait>
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2f8080e7          	jalr	760(ra) # 3fe <wait>
    }
    exit(0);
 10e:	4501                	li	a0,0
 110:	00000097          	auipc	ra,0x0
 114:	2e6080e7          	jalr	742(ra) # 3f6 <exit>
            cpu_bound2();
 118:	00000097          	auipc	ra,0x0
 11c:	f24080e7          	jalr	-220(ra) # 3c <cpu_bound2>
            exit(0);
 120:	4501                	li	a0,0
 122:	00000097          	auipc	ra,0x0
 126:	2d4080e7          	jalr	724(ra) # 3f6 <exit>
            io_bound();
 12a:	00000097          	auipc	ra,0x0
 12e:	f4e080e7          	jalr	-178(ra) # 78 <io_bound>
            exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	2c2080e7          	jalr	706(ra) # 3f6 <exit>

000000000000013c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  extern int main();
  main();
 144:	00000097          	auipc	ra,0x0
 148:	f58080e7          	jalr	-168(ra) # 9c <main>
  exit(0);
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	2a8080e7          	jalr	680(ra) # 3f6 <exit>

0000000000000156 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 15e:	87aa                	mv	a5,a0
 160:	0585                	addi	a1,a1,1
 162:	0785                	addi	a5,a5,1
 164:	fff5c703          	lbu	a4,-1(a1)
 168:	fee78fa3          	sb	a4,-1(a5)
 16c:	fb75                	bnez	a4,160 <strcpy+0xa>
    ;
  return os;
}
 16e:	60a2                	ld	ra,8(sp)
 170:	6402                	ld	s0,0(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 176:	1141                	addi	sp,sp,-16
 178:	e406                	sd	ra,8(sp)
 17a:	e022                	sd	s0,0(sp)
 17c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cb91                	beqz	a5,196 <strcmp+0x20>
 184:	0005c703          	lbu	a4,0(a1)
 188:	00f71763          	bne	a4,a5,196 <strcmp+0x20>
    p++, q++;
 18c:	0505                	addi	a0,a0,1
 18e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	fbe5                	bnez	a5,184 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 196:	0005c503          	lbu	a0,0(a1)
}
 19a:	40a7853b          	subw	a0,a5,a0
 19e:	60a2                	ld	ra,8(sp)
 1a0:	6402                	ld	s0,0(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strlen>:

uint
strlen(const char *s)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e406                	sd	ra,8(sp)
 1aa:	e022                	sd	s0,0(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cf99                	beqz	a5,1d0 <strlen+0x2a>
 1b4:	0505                	addi	a0,a0,1
 1b6:	87aa                	mv	a5,a0
 1b8:	86be                	mv	a3,a5
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff7c703          	lbu	a4,-1(a5)
 1c0:	ff65                	bnez	a4,1b8 <strlen+0x12>
 1c2:	40a6853b          	subw	a0,a3,a0
 1c6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1c8:	60a2                	ld	ra,8(sp)
 1ca:	6402                	ld	s0,0(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  for(n = 0; s[n]; n++)
 1d0:	4501                	li	a0,0
 1d2:	bfdd                	j	1c8 <strlen+0x22>

00000000000001d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1dc:	ca19                	beqz	a2,1f2 <memset+0x1e>
 1de:	87aa                	mv	a5,a0
 1e0:	1602                	slli	a2,a2,0x20
 1e2:	9201                	srli	a2,a2,0x20
 1e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ec:	0785                	addi	a5,a5,1
 1ee:	fee79de3          	bne	a5,a4,1e8 <memset+0x14>
  }
  return dst;
}
 1f2:	60a2                	ld	ra,8(sp)
 1f4:	6402                	ld	s0,0(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <strchr>:

char*
strchr(const char *s, char c)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e406                	sd	ra,8(sp)
 1fe:	e022                	sd	s0,0(sp)
 200:	0800                	addi	s0,sp,16
  for(; *s; s++)
 202:	00054783          	lbu	a5,0(a0)
 206:	cf81                	beqz	a5,21e <strchr+0x24>
    if(*s == c)
 208:	00f58763          	beq	a1,a5,216 <strchr+0x1c>
  for(; *s; s++)
 20c:	0505                	addi	a0,a0,1
 20e:	00054783          	lbu	a5,0(a0)
 212:	fbfd                	bnez	a5,208 <strchr+0xe>
      return (char*)s;
  return 0;
 214:	4501                	li	a0,0
}
 216:	60a2                	ld	ra,8(sp)
 218:	6402                	ld	s0,0(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  return 0;
 21e:	4501                	li	a0,0
 220:	bfdd                	j	216 <strchr+0x1c>

0000000000000222 <gets>:

char*
gets(char *buf, int max)
{
 222:	7159                	addi	sp,sp,-112
 224:	f486                	sd	ra,104(sp)
 226:	f0a2                	sd	s0,96(sp)
 228:	eca6                	sd	s1,88(sp)
 22a:	e8ca                	sd	s2,80(sp)
 22c:	e4ce                	sd	s3,72(sp)
 22e:	e0d2                	sd	s4,64(sp)
 230:	fc56                	sd	s5,56(sp)
 232:	f85a                	sd	s6,48(sp)
 234:	f45e                	sd	s7,40(sp)
 236:	f062                	sd	s8,32(sp)
 238:	ec66                	sd	s9,24(sp)
 23a:	e86a                	sd	s10,16(sp)
 23c:	1880                	addi	s0,sp,112
 23e:	8caa                	mv	s9,a0
 240:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 242:	892a                	mv	s2,a0
 244:	4481                	li	s1,0
    cc = read(0, &c, 1);
 246:	f9f40b13          	addi	s6,s0,-97
 24a:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 24c:	4ba9                	li	s7,10
 24e:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 250:	8d26                	mv	s10,s1
 252:	0014899b          	addiw	s3,s1,1
 256:	84ce                	mv	s1,s3
 258:	0349d763          	bge	s3,s4,286 <gets+0x64>
    cc = read(0, &c, 1);
 25c:	8656                	mv	a2,s5
 25e:	85da                	mv	a1,s6
 260:	4501                	li	a0,0
 262:	00000097          	auipc	ra,0x0
 266:	1ac080e7          	jalr	428(ra) # 40e <read>
    if(cc < 1)
 26a:	00a05e63          	blez	a0,286 <gets+0x64>
    buf[i++] = c;
 26e:	f9f44783          	lbu	a5,-97(s0)
 272:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 276:	01778763          	beq	a5,s7,284 <gets+0x62>
 27a:	0905                	addi	s2,s2,1
 27c:	fd879ae3          	bne	a5,s8,250 <gets+0x2e>
    buf[i++] = c;
 280:	8d4e                	mv	s10,s3
 282:	a011                	j	286 <gets+0x64>
 284:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 286:	9d66                	add	s10,s10,s9
 288:	000d0023          	sb	zero,0(s10)
  return buf;
}
 28c:	8566                	mv	a0,s9
 28e:	70a6                	ld	ra,104(sp)
 290:	7406                	ld	s0,96(sp)
 292:	64e6                	ld	s1,88(sp)
 294:	6946                	ld	s2,80(sp)
 296:	69a6                	ld	s3,72(sp)
 298:	6a06                	ld	s4,64(sp)
 29a:	7ae2                	ld	s5,56(sp)
 29c:	7b42                	ld	s6,48(sp)
 29e:	7ba2                	ld	s7,40(sp)
 2a0:	7c02                	ld	s8,32(sp)
 2a2:	6ce2                	ld	s9,24(sp)
 2a4:	6d42                	ld	s10,16(sp)
 2a6:	6165                	addi	sp,sp,112
 2a8:	8082                	ret

00000000000002aa <stat>:

int
stat(const char *n, struct stat *st)
{
 2aa:	1101                	addi	sp,sp,-32
 2ac:	ec06                	sd	ra,24(sp)
 2ae:	e822                	sd	s0,16(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	17e080e7          	jalr	382(ra) # 436 <open>
  if(fd < 0)
 2c0:	02054663          	bltz	a0,2ec <stat+0x42>
 2c4:	e426                	sd	s1,8(sp)
 2c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c8:	85ca                	mv	a1,s2
 2ca:	00000097          	auipc	ra,0x0
 2ce:	184080e7          	jalr	388(ra) # 44e <fstat>
 2d2:	892a                	mv	s2,a0
  close(fd);
 2d4:	8526                	mv	a0,s1
 2d6:	00000097          	auipc	ra,0x0
 2da:	148080e7          	jalr	328(ra) # 41e <close>
  return r;
 2de:	64a2                	ld	s1,8(sp)
}
 2e0:	854a                	mv	a0,s2
 2e2:	60e2                	ld	ra,24(sp)
 2e4:	6442                	ld	s0,16(sp)
 2e6:	6902                	ld	s2,0(sp)
 2e8:	6105                	addi	sp,sp,32
 2ea:	8082                	ret
    return -1;
 2ec:	597d                	li	s2,-1
 2ee:	bfcd                	j	2e0 <stat+0x36>

00000000000002f0 <atoi>:

int
atoi(const char *s)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f8:	00054683          	lbu	a3,0(a0)
 2fc:	fd06879b          	addiw	a5,a3,-48
 300:	0ff7f793          	zext.b	a5,a5
 304:	4625                	li	a2,9
 306:	02f66963          	bltu	a2,a5,338 <atoi+0x48>
 30a:	872a                	mv	a4,a0
  n = 0;
 30c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 30e:	0705                	addi	a4,a4,1
 310:	0025179b          	slliw	a5,a0,0x2
 314:	9fa9                	addw	a5,a5,a0
 316:	0017979b          	slliw	a5,a5,0x1
 31a:	9fb5                	addw	a5,a5,a3
 31c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 320:	00074683          	lbu	a3,0(a4)
 324:	fd06879b          	addiw	a5,a3,-48
 328:	0ff7f793          	zext.b	a5,a5
 32c:	fef671e3          	bgeu	a2,a5,30e <atoi+0x1e>
  return n;
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
  n = 0;
 338:	4501                	li	a0,0
 33a:	bfdd                	j	330 <atoi+0x40>

000000000000033c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 344:	02b57563          	bgeu	a0,a1,36e <memmove+0x32>
    while(n-- > 0)
 348:	00c05f63          	blez	a2,366 <memmove+0x2a>
 34c:	1602                	slli	a2,a2,0x20
 34e:	9201                	srli	a2,a2,0x20
 350:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 354:	872a                	mv	a4,a0
      *dst++ = *src++;
 356:	0585                	addi	a1,a1,1
 358:	0705                	addi	a4,a4,1
 35a:	fff5c683          	lbu	a3,-1(a1)
 35e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 362:	fee79ae3          	bne	a5,a4,356 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 366:	60a2                	ld	ra,8(sp)
 368:	6402                	ld	s0,0(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
    dst += n;
 36e:	00c50733          	add	a4,a0,a2
    src += n;
 372:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 374:	fec059e3          	blez	a2,366 <memmove+0x2a>
 378:	fff6079b          	addiw	a5,a2,-1
 37c:	1782                	slli	a5,a5,0x20
 37e:	9381                	srli	a5,a5,0x20
 380:	fff7c793          	not	a5,a5
 384:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 386:	15fd                	addi	a1,a1,-1
 388:	177d                	addi	a4,a4,-1
 38a:	0005c683          	lbu	a3,0(a1)
 38e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 392:	fef71ae3          	bne	a4,a5,386 <memmove+0x4a>
 396:	bfc1                	j	366 <memmove+0x2a>

0000000000000398 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a0:	ca0d                	beqz	a2,3d2 <memcmp+0x3a>
 3a2:	fff6069b          	addiw	a3,a2,-1
 3a6:	1682                	slli	a3,a3,0x20
 3a8:	9281                	srli	a3,a3,0x20
 3aa:	0685                	addi	a3,a3,1
 3ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ae:	00054783          	lbu	a5,0(a0)
 3b2:	0005c703          	lbu	a4,0(a1)
 3b6:	00e79863          	bne	a5,a4,3c6 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 3ba:	0505                	addi	a0,a0,1
    p2++;
 3bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3be:	fed518e3          	bne	a0,a3,3ae <memcmp+0x16>
  }
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	a019                	j	3ca <memcmp+0x32>
      return *p1 - *p2;
 3c6:	40e7853b          	subw	a0,a5,a4
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  return 0;
 3d2:	4501                	li	a0,0
 3d4:	bfdd                	j	3ca <memcmp+0x32>

00000000000003d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e406                	sd	ra,8(sp)
 3da:	e022                	sd	s0,0(sp)
 3dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3de:	00000097          	auipc	ra,0x0
 3e2:	f5e080e7          	jalr	-162(ra) # 33c <memmove>
}
 3e6:	60a2                	ld	ra,8(sp)
 3e8:	6402                	ld	s0,0(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret

00000000000003ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ee:	4885                	li	a7,1
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f6:	4889                	li	a7,2
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fe:	488d                	li	a7,3
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 406:	4891                	li	a7,4
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <read>:
.global read
read:
 li a7, SYS_read
 40e:	4895                	li	a7,5
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <write>:
.global write
write:
 li a7, SYS_write
 416:	48c1                	li	a7,16
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <close>:
.global close
close:
 li a7, SYS_close
 41e:	48d5                	li	a7,21
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <kill>:
.global kill
kill:
 li a7, SYS_kill
 426:	4899                	li	a7,6
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <exec>:
.global exec
exec:
 li a7, SYS_exec
 42e:	489d                	li	a7,7
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <open>:
.global open
open:
 li a7, SYS_open
 436:	48bd                	li	a7,15
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43e:	48c5                	li	a7,17
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 446:	48c9                	li	a7,18
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44e:	48a1                	li	a7,8
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <link>:
.global link
link:
 li a7, SYS_link
 456:	48cd                	li	a7,19
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45e:	48d1                	li	a7,20
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 466:	48a5                	li	a7,9
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <dup>:
.global dup
dup:
 li a7, SYS_dup
 46e:	48a9                	li	a7,10
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 476:	48ad                	li	a7,11
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 47e:	48b1                	li	a7,12
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 486:	48b5                	li	a7,13
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48e:	48b9                	li	a7,14
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 496:	48d9                	li	a7,22
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 49e:	48dd                	li	a7,23
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4a6:	48e1                	li	a7,24
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4ae:	48e5                	li	a7,25
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b6:	1101                	addi	sp,sp,-32
 4b8:	ec06                	sd	ra,24(sp)
 4ba:	e822                	sd	s0,16(sp)
 4bc:	1000                	addi	s0,sp,32
 4be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c2:	4605                	li	a2,1
 4c4:	fef40593          	addi	a1,s0,-17
 4c8:	00000097          	auipc	ra,0x0
 4cc:	f4e080e7          	jalr	-178(ra) # 416 <write>
}
 4d0:	60e2                	ld	ra,24(sp)
 4d2:	6442                	ld	s0,16(sp)
 4d4:	6105                	addi	sp,sp,32
 4d6:	8082                	ret

00000000000004d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d8:	7139                	addi	sp,sp,-64
 4da:	fc06                	sd	ra,56(sp)
 4dc:	f822                	sd	s0,48(sp)
 4de:	f426                	sd	s1,40(sp)
 4e0:	f04a                	sd	s2,32(sp)
 4e2:	ec4e                	sd	s3,24(sp)
 4e4:	0080                	addi	s0,sp,64
 4e6:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e8:	c299                	beqz	a3,4ee <printint+0x16>
 4ea:	0805c063          	bltz	a1,56a <printint+0x92>
  neg = 0;
 4ee:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4f0:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4f4:	869a                	mv	a3,t1
  i = 0;
 4f6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4f8:	00000817          	auipc	a6,0x0
 4fc:	49880813          	addi	a6,a6,1176 # 990 <digits>
 500:	88be                	mv	a7,a5
 502:	0017851b          	addiw	a0,a5,1
 506:	87aa                	mv	a5,a0
 508:	02c5f73b          	remuw	a4,a1,a2
 50c:	1702                	slli	a4,a4,0x20
 50e:	9301                	srli	a4,a4,0x20
 510:	9742                	add	a4,a4,a6
 512:	00074703          	lbu	a4,0(a4)
 516:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 51a:	872e                	mv	a4,a1
 51c:	02c5d5bb          	divuw	a1,a1,a2
 520:	0685                	addi	a3,a3,1
 522:	fcc77fe3          	bgeu	a4,a2,500 <printint+0x28>
  if(neg)
 526:	000e0c63          	beqz	t3,53e <printint+0x66>
    buf[i++] = '-';
 52a:	fd050793          	addi	a5,a0,-48
 52e:	00878533          	add	a0,a5,s0
 532:	02d00793          	li	a5,45
 536:	fef50823          	sb	a5,-16(a0)
 53a:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 53e:	fff7899b          	addiw	s3,a5,-1
 542:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 546:	fff4c583          	lbu	a1,-1(s1)
 54a:	854a                	mv	a0,s2
 54c:	00000097          	auipc	ra,0x0
 550:	f6a080e7          	jalr	-150(ra) # 4b6 <putc>
  while(--i >= 0)
 554:	39fd                	addiw	s3,s3,-1
 556:	14fd                	addi	s1,s1,-1
 558:	fe09d7e3          	bgez	s3,546 <printint+0x6e>
}
 55c:	70e2                	ld	ra,56(sp)
 55e:	7442                	ld	s0,48(sp)
 560:	74a2                	ld	s1,40(sp)
 562:	7902                	ld	s2,32(sp)
 564:	69e2                	ld	s3,24(sp)
 566:	6121                	addi	sp,sp,64
 568:	8082                	ret
    x = -xx;
 56a:	40b005bb          	negw	a1,a1
    neg = 1;
 56e:	4e05                	li	t3,1
    x = -xx;
 570:	b741                	j	4f0 <printint+0x18>

0000000000000572 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 572:	715d                	addi	sp,sp,-80
 574:	e486                	sd	ra,72(sp)
 576:	e0a2                	sd	s0,64(sp)
 578:	f84a                	sd	s2,48(sp)
 57a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57c:	0005c903          	lbu	s2,0(a1)
 580:	1a090a63          	beqz	s2,734 <vprintf+0x1c2>
 584:	fc26                	sd	s1,56(sp)
 586:	f44e                	sd	s3,40(sp)
 588:	f052                	sd	s4,32(sp)
 58a:	ec56                	sd	s5,24(sp)
 58c:	e85a                	sd	s6,16(sp)
 58e:	e45e                	sd	s7,8(sp)
 590:	8aaa                	mv	s5,a0
 592:	8bb2                	mv	s7,a2
 594:	00158493          	addi	s1,a1,1
  state = 0;
 598:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 59a:	02500a13          	li	s4,37
 59e:	4b55                	li	s6,21
 5a0:	a839                	j	5be <vprintf+0x4c>
        putc(fd, c);
 5a2:	85ca                	mv	a1,s2
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	f10080e7          	jalr	-240(ra) # 4b6 <putc>
 5ae:	a019                	j	5b4 <vprintf+0x42>
    } else if(state == '%'){
 5b0:	01498d63          	beq	s3,s4,5ca <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5b4:	0485                	addi	s1,s1,1
 5b6:	fff4c903          	lbu	s2,-1(s1)
 5ba:	16090763          	beqz	s2,728 <vprintf+0x1b6>
    if(state == 0){
 5be:	fe0999e3          	bnez	s3,5b0 <vprintf+0x3e>
      if(c == '%'){
 5c2:	ff4910e3          	bne	s2,s4,5a2 <vprintf+0x30>
        state = '%';
 5c6:	89d2                	mv	s3,s4
 5c8:	b7f5                	j	5b4 <vprintf+0x42>
      if(c == 'd'){
 5ca:	13490463          	beq	s2,s4,6f2 <vprintf+0x180>
 5ce:	f9d9079b          	addiw	a5,s2,-99
 5d2:	0ff7f793          	zext.b	a5,a5
 5d6:	12fb6763          	bltu	s6,a5,704 <vprintf+0x192>
 5da:	f9d9079b          	addiw	a5,s2,-99
 5de:	0ff7f713          	zext.b	a4,a5
 5e2:	12eb6163          	bltu	s6,a4,704 <vprintf+0x192>
 5e6:	00271793          	slli	a5,a4,0x2
 5ea:	00000717          	auipc	a4,0x0
 5ee:	34e70713          	addi	a4,a4,846 # 938 <malloc+0x110>
 5f2:	97ba                	add	a5,a5,a4
 5f4:	439c                	lw	a5,0(a5)
 5f6:	97ba                	add	a5,a5,a4
 5f8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4685                	li	a3,1
 600:	4629                	li	a2,10
 602:	000ba583          	lw	a1,0(s7)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	ed0080e7          	jalr	-304(ra) # 4d8 <printint>
 610:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 612:	4981                	li	s3,0
 614:	b745                	j	5b4 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4629                	li	a2,10
 61e:	000ba583          	lw	a1,0(s7)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	eb4080e7          	jalr	-332(ra) # 4d8 <printint>
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
 630:	b751                	j	5b4 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000ba583          	lw	a1,0(s7)
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e98080e7          	jalr	-360(ra) # 4d8 <printint>
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b7a5                	j	5b4 <vprintf+0x42>
 64e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 650:	008b8c13          	addi	s8,s7,8
 654:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 658:	03000593          	li	a1,48
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e58080e7          	jalr	-424(ra) # 4b6 <putc>
  putc(fd, 'x');
 666:	07800593          	li	a1,120
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	e4a080e7          	jalr	-438(ra) # 4b6 <putc>
 674:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 676:	00000b97          	auipc	s7,0x0
 67a:	31ab8b93          	addi	s7,s7,794 # 990 <digits>
 67e:	03c9d793          	srli	a5,s3,0x3c
 682:	97de                	add	a5,a5,s7
 684:	0007c583          	lbu	a1,0(a5)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e2c080e7          	jalr	-468(ra) # 4b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 692:	0992                	slli	s3,s3,0x4
 694:	397d                	addiw	s2,s2,-1
 696:	fe0914e3          	bnez	s2,67e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 69a:	8be2                	mv	s7,s8
      state = 0;
 69c:	4981                	li	s3,0
 69e:	6c02                	ld	s8,0(sp)
 6a0:	bf11                	j	5b4 <vprintf+0x42>
        s = va_arg(ap, char*);
 6a2:	008b8993          	addi	s3,s7,8
 6a6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6aa:	02090163          	beqz	s2,6cc <vprintf+0x15a>
        while(*s != 0){
 6ae:	00094583          	lbu	a1,0(s2)
 6b2:	c9a5                	beqz	a1,722 <vprintf+0x1b0>
          putc(fd, *s);
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e00080e7          	jalr	-512(ra) # 4b6 <putc>
          s++;
 6be:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c0:	00094583          	lbu	a1,0(s2)
 6c4:	f9e5                	bnez	a1,6b4 <vprintf+0x142>
        s = va_arg(ap, char*);
 6c6:	8bce                	mv	s7,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b5ed                	j	5b4 <vprintf+0x42>
          s = "(null)";
 6cc:	00000917          	auipc	s2,0x0
 6d0:	26490913          	addi	s2,s2,612 # 930 <malloc+0x108>
        while(*s != 0){
 6d4:	02800593          	li	a1,40
 6d8:	bff1                	j	6b4 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6da:	008b8913          	addi	s2,s7,8
 6de:	000bc583          	lbu	a1,0(s7)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dd2080e7          	jalr	-558(ra) # 4b6 <putc>
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b5d1                	j	5b4 <vprintf+0x42>
        putc(fd, c);
 6f2:	02500593          	li	a1,37
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	dbe080e7          	jalr	-578(ra) # 4b6 <putc>
      state = 0;
 700:	4981                	li	s3,0
 702:	bd4d                	j	5b4 <vprintf+0x42>
        putc(fd, '%');
 704:	02500593          	li	a1,37
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	dac080e7          	jalr	-596(ra) # 4b6 <putc>
        putc(fd, c);
 712:	85ca                	mv	a1,s2
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	da0080e7          	jalr	-608(ra) # 4b6 <putc>
      state = 0;
 71e:	4981                	li	s3,0
 720:	bd51                	j	5b4 <vprintf+0x42>
        s = va_arg(ap, char*);
 722:	8bce                	mv	s7,s3
      state = 0;
 724:	4981                	li	s3,0
 726:	b579                	j	5b4 <vprintf+0x42>
 728:	74e2                	ld	s1,56(sp)
 72a:	79a2                	ld	s3,40(sp)
 72c:	7a02                	ld	s4,32(sp)
 72e:	6ae2                	ld	s5,24(sp)
 730:	6b42                	ld	s6,16(sp)
 732:	6ba2                	ld	s7,8(sp)
    }
  }
}
 734:	60a6                	ld	ra,72(sp)
 736:	6406                	ld	s0,64(sp)
 738:	7942                	ld	s2,48(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73e:	715d                	addi	sp,sp,-80
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e010                	sd	a2,0(s0)
 748:	e414                	sd	a3,8(s0)
 74a:	e818                	sd	a4,16(s0)
 74c:	ec1c                	sd	a5,24(s0)
 74e:	03043023          	sd	a6,32(s0)
 752:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	8622                	mv	a2,s0
 758:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75c:	00000097          	auipc	ra,0x0
 760:	e16080e7          	jalr	-490(ra) # 572 <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6161                	addi	sp,sp,80
 76a:	8082                	ret

000000000000076c <printf>:

void
printf(const char *fmt, ...)
{
 76c:	711d                	addi	sp,sp,-96
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e40c                	sd	a1,8(s0)
 776:	e810                	sd	a2,16(s0)
 778:	ec14                	sd	a3,24(s0)
 77a:	f018                	sd	a4,32(s0)
 77c:	f41c                	sd	a5,40(s0)
 77e:	03043823          	sd	a6,48(s0)
 782:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	00840613          	addi	a2,s0,8
 78a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78e:	85aa                	mv	a1,a0
 790:	4505                	li	a0,1
 792:	00000097          	auipc	ra,0x0
 796:	de0080e7          	jalr	-544(ra) # 572 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6125                	addi	sp,sp,96
 7a0:	8082                	ret

00000000000007a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a2:	1141                	addi	sp,sp,-16
 7a4:	e406                	sd	ra,8(sp)
 7a6:	e022                	sd	s0,0(sp)
 7a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	00001797          	auipc	a5,0x1
 7b2:	8527b783          	ld	a5,-1966(a5) # 1000 <freep>
 7b6:	a02d                	j	7e0 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b8:	4618                	lw	a4,8(a2)
 7ba:	9f2d                	addw	a4,a4,a1
 7bc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	6398                	ld	a4,0(a5)
 7c2:	6310                	ld	a2,0(a4)
 7c4:	a83d                	j	802 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c6:	ff852703          	lw	a4,-8(a0)
 7ca:	9f31                	addw	a4,a4,a2
 7cc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ce:	ff053683          	ld	a3,-16(a0)
 7d2:	a091                	j	816 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	6398                	ld	a4,0(a5)
 7d6:	00e7e463          	bltu	a5,a4,7de <free+0x3c>
 7da:	00e6ea63          	bltu	a3,a4,7ee <free+0x4c>
{
 7de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	fed7fae3          	bgeu	a5,a3,7d4 <free+0x32>
 7e4:	6398                	ld	a4,0(a5)
 7e6:	00e6e463          	bltu	a3,a4,7ee <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ea:	fee7eae3          	bltu	a5,a4,7de <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7ee:	ff852583          	lw	a1,-8(a0)
 7f2:	6390                	ld	a2,0(a5)
 7f4:	02059813          	slli	a6,a1,0x20
 7f8:	01c85713          	srli	a4,a6,0x1c
 7fc:	9736                	add	a4,a4,a3
 7fe:	fae60de3          	beq	a2,a4,7b8 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 802:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 806:	4790                	lw	a2,8(a5)
 808:	02061593          	slli	a1,a2,0x20
 80c:	01c5d713          	srli	a4,a1,0x1c
 810:	973e                	add	a4,a4,a5
 812:	fae68ae3          	beq	a3,a4,7c6 <free+0x24>
    p->s.ptr = bp->s.ptr;
 816:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 818:	00000717          	auipc	a4,0x0
 81c:	7ef73423          	sd	a5,2024(a4) # 1000 <freep>
}
 820:	60a2                	ld	ra,8(sp)
 822:	6402                	ld	s0,0(sp)
 824:	0141                	addi	sp,sp,16
 826:	8082                	ret

0000000000000828 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 828:	7139                	addi	sp,sp,-64
 82a:	fc06                	sd	ra,56(sp)
 82c:	f822                	sd	s0,48(sp)
 82e:	f04a                	sd	s2,32(sp)
 830:	ec4e                	sd	s3,24(sp)
 832:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 834:	02051993          	slli	s3,a0,0x20
 838:	0209d993          	srli	s3,s3,0x20
 83c:	09bd                	addi	s3,s3,15
 83e:	0049d993          	srli	s3,s3,0x4
 842:	2985                	addiw	s3,s3,1
 844:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 846:	00000517          	auipc	a0,0x0
 84a:	7ba53503          	ld	a0,1978(a0) # 1000 <freep>
 84e:	c905                	beqz	a0,87e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 852:	4798                	lw	a4,8(a5)
 854:	09377a63          	bgeu	a4,s3,8e8 <malloc+0xc0>
 858:	f426                	sd	s1,40(sp)
 85a:	e852                	sd	s4,16(sp)
 85c:	e456                	sd	s5,8(sp)
 85e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 860:	8a4e                	mv	s4,s3
 862:	6705                	lui	a4,0x1
 864:	00e9f363          	bgeu	s3,a4,86a <malloc+0x42>
 868:	6a05                	lui	s4,0x1
 86a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 872:	00000497          	auipc	s1,0x0
 876:	78e48493          	addi	s1,s1,1934 # 1000 <freep>
  if(p == (char*)-1)
 87a:	5afd                	li	s5,-1
 87c:	a089                	j	8be <malloc+0x96>
 87e:	f426                	sd	s1,40(sp)
 880:	e852                	sd	s4,16(sp)
 882:	e456                	sd	s5,8(sp)
 884:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 886:	00000797          	auipc	a5,0x0
 88a:	78a78793          	addi	a5,a5,1930 # 1010 <base>
 88e:	00000717          	auipc	a4,0x0
 892:	76f73923          	sd	a5,1906(a4) # 1000 <freep>
 896:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 898:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89c:	b7d1                	j	860 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 89e:	6398                	ld	a4,0(a5)
 8a0:	e118                	sd	a4,0(a0)
 8a2:	a8b9                	j	900 <malloc+0xd8>
  hp->s.size = nu;
 8a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a8:	0541                	addi	a0,a0,16
 8aa:	00000097          	auipc	ra,0x0
 8ae:	ef8080e7          	jalr	-264(ra) # 7a2 <free>
  return freep;
 8b2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8b4:	c135                	beqz	a0,918 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	03277363          	bgeu	a4,s2,8e0 <malloc+0xb8>
    if(p == freep)
 8be:	6098                	ld	a4,0(s1)
 8c0:	853e                	mv	a0,a5
 8c2:	fef71ae3          	bne	a4,a5,8b6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8c6:	8552                	mv	a0,s4
 8c8:	00000097          	auipc	ra,0x0
 8cc:	bb6080e7          	jalr	-1098(ra) # 47e <sbrk>
  if(p == (char*)-1)
 8d0:	fd551ae3          	bne	a0,s5,8a4 <malloc+0x7c>
        return 0;
 8d4:	4501                	li	a0,0
 8d6:	74a2                	ld	s1,40(sp)
 8d8:	6a42                	ld	s4,16(sp)
 8da:	6aa2                	ld	s5,8(sp)
 8dc:	6b02                	ld	s6,0(sp)
 8de:	a03d                	j	90c <malloc+0xe4>
 8e0:	74a2                	ld	s1,40(sp)
 8e2:	6a42                	ld	s4,16(sp)
 8e4:	6aa2                	ld	s5,8(sp)
 8e6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8e8:	fae90be3          	beq	s2,a4,89e <malloc+0x76>
        p->s.size -= nunits;
 8ec:	4137073b          	subw	a4,a4,s3
 8f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f2:	02071693          	slli	a3,a4,0x20
 8f6:	01c6d713          	srli	a4,a3,0x1c
 8fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 900:	00000717          	auipc	a4,0x0
 904:	70a73023          	sd	a0,1792(a4) # 1000 <freep>
      return (void*)(p + 1);
 908:	01078513          	addi	a0,a5,16
  }
}
 90c:	70e2                	ld	ra,56(sp)
 90e:	7442                	ld	s0,48(sp)
 910:	7902                	ld	s2,32(sp)
 912:	69e2                	ld	s3,24(sp)
 914:	6121                	addi	sp,sp,64
 916:	8082                	ret
 918:	74a2                	ld	s1,40(sp)
 91a:	6a42                	ld	s4,16(sp)
 91c:	6aa2                	ld	s5,8(sp)
 91e:	6b02                	ld	s6,0(sp)
 920:	b7f5                	j	90c <malloc+0xe4>
