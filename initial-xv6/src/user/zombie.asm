
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2d4080e7          	jalr	724(ra) # 2dc <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	2ce080e7          	jalr	718(ra) # 2e4 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	354080e7          	jalr	852(ra) # 374 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	2a8080e7          	jalr	680(ra) # 2e4 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0xa>
    ;
  return os;
}
  5c:	60a2                	ld	ra,8(sp)
  5e:	6402                	ld	s0,0(sp)
  60:	0141                	addi	sp,sp,16
  62:	8082                	ret

0000000000000064 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  6c:	00054783          	lbu	a5,0(a0)
  70:	cb91                	beqz	a5,84 <strcmp+0x20>
  72:	0005c703          	lbu	a4,0(a1)
  76:	00f71763          	bne	a4,a5,84 <strcmp+0x20>
    p++, q++;
  7a:	0505                	addi	a0,a0,1
  7c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	fbe5                	bnez	a5,72 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  84:	0005c503          	lbu	a0,0(a1)
}
  88:	40a7853b          	subw	a0,a5,a0
  8c:	60a2                	ld	ra,8(sp)
  8e:	6402                	ld	s0,0(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strlen>:

uint
strlen(const char *s)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cf99                	beqz	a5,be <strlen+0x2a>
  a2:	0505                	addi	a0,a0,1
  a4:	87aa                	mv	a5,a0
  a6:	86be                	mv	a3,a5
  a8:	0785                	addi	a5,a5,1
  aa:	fff7c703          	lbu	a4,-1(a5)
  ae:	ff65                	bnez	a4,a6 <strlen+0x12>
  b0:	40a6853b          	subw	a0,a3,a0
  b4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  b6:	60a2                	ld	ra,8(sp)
  b8:	6402                	ld	s0,0(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret
  for(n = 0; s[n]; n++)
  be:	4501                	li	a0,0
  c0:	bfdd                	j	b6 <strlen+0x22>

00000000000000c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e406                	sd	ra,8(sp)
  c6:	e022                	sd	s0,0(sp)
  c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ca:	ca19                	beqz	a2,e0 <memset+0x1e>
  cc:	87aa                	mv	a5,a0
  ce:	1602                	slli	a2,a2,0x20
  d0:	9201                	srli	a2,a2,0x20
  d2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  da:	0785                	addi	a5,a5,1
  dc:	fee79de3          	bne	a5,a4,d6 <memset+0x14>
  }
  return dst;
}
  e0:	60a2                	ld	ra,8(sp)
  e2:	6402                	ld	s0,0(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strchr>:

char*
strchr(const char *s, char c)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e406                	sd	ra,8(sp)
  ec:	e022                	sd	s0,0(sp)
  ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cf81                	beqz	a5,10c <strchr+0x24>
    if(*s == c)
  f6:	00f58763          	beq	a1,a5,104 <strchr+0x1c>
  for(; *s; s++)
  fa:	0505                	addi	a0,a0,1
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbfd                	bnez	a5,f6 <strchr+0xe>
      return (char*)s;
  return 0;
 102:	4501                	li	a0,0
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  return 0;
 10c:	4501                	li	a0,0
 10e:	bfdd                	j	104 <strchr+0x1c>

0000000000000110 <gets>:

char*
gets(char *buf, int max)
{
 110:	7159                	addi	sp,sp,-112
 112:	f486                	sd	ra,104(sp)
 114:	f0a2                	sd	s0,96(sp)
 116:	eca6                	sd	s1,88(sp)
 118:	e8ca                	sd	s2,80(sp)
 11a:	e4ce                	sd	s3,72(sp)
 11c:	e0d2                	sd	s4,64(sp)
 11e:	fc56                	sd	s5,56(sp)
 120:	f85a                	sd	s6,48(sp)
 122:	f45e                	sd	s7,40(sp)
 124:	f062                	sd	s8,32(sp)
 126:	ec66                	sd	s9,24(sp)
 128:	e86a                	sd	s10,16(sp)
 12a:	1880                	addi	s0,sp,112
 12c:	8caa                	mv	s9,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
 134:	f9f40b13          	addi	s6,s0,-97
 138:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4ba9                	li	s7,10
 13c:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 13e:	8d26                	mv	s10,s1
 140:	0014899b          	addiw	s3,s1,1
 144:	84ce                	mv	s1,s3
 146:	0349d763          	bge	s3,s4,174 <gets+0x64>
    cc = read(0, &c, 1);
 14a:	8656                	mv	a2,s5
 14c:	85da                	mv	a1,s6
 14e:	4501                	li	a0,0
 150:	00000097          	auipc	ra,0x0
 154:	1ac080e7          	jalr	428(ra) # 2fc <read>
    if(cc < 1)
 158:	00a05e63          	blez	a0,174 <gets+0x64>
    buf[i++] = c;
 15c:	f9f44783          	lbu	a5,-97(s0)
 160:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 164:	01778763          	beq	a5,s7,172 <gets+0x62>
 168:	0905                	addi	s2,s2,1
 16a:	fd879ae3          	bne	a5,s8,13e <gets+0x2e>
    buf[i++] = c;
 16e:	8d4e                	mv	s10,s3
 170:	a011                	j	174 <gets+0x64>
 172:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 174:	9d66                	add	s10,s10,s9
 176:	000d0023          	sb	zero,0(s10)
  return buf;
}
 17a:	8566                	mv	a0,s9
 17c:	70a6                	ld	ra,104(sp)
 17e:	7406                	ld	s0,96(sp)
 180:	64e6                	ld	s1,88(sp)
 182:	6946                	ld	s2,80(sp)
 184:	69a6                	ld	s3,72(sp)
 186:	6a06                	ld	s4,64(sp)
 188:	7ae2                	ld	s5,56(sp)
 18a:	7b42                	ld	s6,48(sp)
 18c:	7ba2                	ld	s7,40(sp)
 18e:	7c02                	ld	s8,32(sp)
 190:	6ce2                	ld	s9,24(sp)
 192:	6d42                	ld	s10,16(sp)
 194:	6165                	addi	sp,sp,112
 196:	8082                	ret

0000000000000198 <stat>:

int
stat(const char *n, struct stat *st)
{
 198:	1101                	addi	sp,sp,-32
 19a:	ec06                	sd	ra,24(sp)
 19c:	e822                	sd	s0,16(sp)
 19e:	e04a                	sd	s2,0(sp)
 1a0:	1000                	addi	s0,sp,32
 1a2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a4:	4581                	li	a1,0
 1a6:	00000097          	auipc	ra,0x0
 1aa:	17e080e7          	jalr	382(ra) # 324 <open>
  if(fd < 0)
 1ae:	02054663          	bltz	a0,1da <stat+0x42>
 1b2:	e426                	sd	s1,8(sp)
 1b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b6:	85ca                	mv	a1,s2
 1b8:	00000097          	auipc	ra,0x0
 1bc:	184080e7          	jalr	388(ra) # 33c <fstat>
 1c0:	892a                	mv	s2,a0
  close(fd);
 1c2:	8526                	mv	a0,s1
 1c4:	00000097          	auipc	ra,0x0
 1c8:	148080e7          	jalr	328(ra) # 30c <close>
  return r;
 1cc:	64a2                	ld	s1,8(sp)
}
 1ce:	854a                	mv	a0,s2
 1d0:	60e2                	ld	ra,24(sp)
 1d2:	6442                	ld	s0,16(sp)
 1d4:	6902                	ld	s2,0(sp)
 1d6:	6105                	addi	sp,sp,32
 1d8:	8082                	ret
    return -1;
 1da:	597d                	li	s2,-1
 1dc:	bfcd                	j	1ce <stat+0x36>

00000000000001de <atoi>:

int
atoi(const char *s)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e406                	sd	ra,8(sp)
 1e2:	e022                	sd	s0,0(sp)
 1e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e6:	00054683          	lbu	a3,0(a0)
 1ea:	fd06879b          	addiw	a5,a3,-48
 1ee:	0ff7f793          	zext.b	a5,a5
 1f2:	4625                	li	a2,9
 1f4:	02f66963          	bltu	a2,a5,226 <atoi+0x48>
 1f8:	872a                	mv	a4,a0
  n = 0;
 1fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1fc:	0705                	addi	a4,a4,1
 1fe:	0025179b          	slliw	a5,a0,0x2
 202:	9fa9                	addw	a5,a5,a0
 204:	0017979b          	slliw	a5,a5,0x1
 208:	9fb5                	addw	a5,a5,a3
 20a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 20e:	00074683          	lbu	a3,0(a4)
 212:	fd06879b          	addiw	a5,a3,-48
 216:	0ff7f793          	zext.b	a5,a5
 21a:	fef671e3          	bgeu	a2,a5,1fc <atoi+0x1e>
  return n;
}
 21e:	60a2                	ld	ra,8(sp)
 220:	6402                	ld	s0,0(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
  n = 0;
 226:	4501                	li	a0,0
 228:	bfdd                	j	21e <atoi+0x40>

000000000000022a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e406                	sd	ra,8(sp)
 22e:	e022                	sd	s0,0(sp)
 230:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 232:	02b57563          	bgeu	a0,a1,25c <memmove+0x32>
    while(n-- > 0)
 236:	00c05f63          	blez	a2,254 <memmove+0x2a>
 23a:	1602                	slli	a2,a2,0x20
 23c:	9201                	srli	a2,a2,0x20
 23e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 242:	872a                	mv	a4,a0
      *dst++ = *src++;
 244:	0585                	addi	a1,a1,1
 246:	0705                	addi	a4,a4,1
 248:	fff5c683          	lbu	a3,-1(a1)
 24c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 250:	fee79ae3          	bne	a5,a4,244 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 254:	60a2                	ld	ra,8(sp)
 256:	6402                	ld	s0,0(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
    dst += n;
 25c:	00c50733          	add	a4,a0,a2
    src += n;
 260:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 262:	fec059e3          	blez	a2,254 <memmove+0x2a>
 266:	fff6079b          	addiw	a5,a2,-1
 26a:	1782                	slli	a5,a5,0x20
 26c:	9381                	srli	a5,a5,0x20
 26e:	fff7c793          	not	a5,a5
 272:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 274:	15fd                	addi	a1,a1,-1
 276:	177d                	addi	a4,a4,-1
 278:	0005c683          	lbu	a3,0(a1)
 27c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 280:	fef71ae3          	bne	a4,a5,274 <memmove+0x4a>
 284:	bfc1                	j	254 <memmove+0x2a>

0000000000000286 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28e:	ca0d                	beqz	a2,2c0 <memcmp+0x3a>
 290:	fff6069b          	addiw	a3,a2,-1
 294:	1682                	slli	a3,a3,0x20
 296:	9281                	srli	a3,a3,0x20
 298:	0685                	addi	a3,a3,1
 29a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00e79863          	bne	a5,a4,2b4 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2a8:	0505                	addi	a0,a0,1
    p2++;
 2aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ac:	fed518e3          	bne	a0,a3,29c <memcmp+0x16>
  }
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	a019                	j	2b8 <memcmp+0x32>
      return *p1 - *p2;
 2b4:	40e7853b          	subw	a0,a5,a4
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	bfdd                	j	2b8 <memcmp+0x32>

00000000000002c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2cc:	00000097          	auipc	ra,0x0
 2d0:	f5e080e7          	jalr	-162(ra) # 22a <memmove>
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2dc:	4885                	li	a7,1
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e4:	4889                	li	a7,2
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ec:	488d                	li	a7,3
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f4:	4891                	li	a7,4
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <read>:
.global read
read:
 li a7, SYS_read
 2fc:	4895                	li	a7,5
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <write>:
.global write
write:
 li a7, SYS_write
 304:	48c1                	li	a7,16
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <close>:
.global close
close:
 li a7, SYS_close
 30c:	48d5                	li	a7,21
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <kill>:
.global kill
kill:
 li a7, SYS_kill
 314:	4899                	li	a7,6
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <exec>:
.global exec
exec:
 li a7, SYS_exec
 31c:	489d                	li	a7,7
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <open>:
.global open
open:
 li a7, SYS_open
 324:	48bd                	li	a7,15
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32c:	48c5                	li	a7,17
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 334:	48c9                	li	a7,18
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33c:	48a1                	li	a7,8
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <link>:
.global link
link:
 li a7, SYS_link
 344:	48cd                	li	a7,19
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34c:	48d1                	li	a7,20
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 354:	48a5                	li	a7,9
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <dup>:
.global dup
dup:
 li a7, SYS_dup
 35c:	48a9                	li	a7,10
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 364:	48ad                	li	a7,11
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 36c:	48b1                	li	a7,12
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 374:	48b5                	li	a7,13
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37c:	48b9                	li	a7,14
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 384:	48d9                	li	a7,22
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 38c:	48dd                	li	a7,23
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 394:	48e1                	li	a7,24
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 39c:	48e5                	li	a7,25
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b0:	4605                	li	a2,1
 3b2:	fef40593          	addi	a1,s0,-17
 3b6:	00000097          	auipc	ra,0x0
 3ba:	f4e080e7          	jalr	-178(ra) # 304 <write>
}
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret

00000000000003c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c6:	7139                	addi	sp,sp,-64
 3c8:	fc06                	sd	ra,56(sp)
 3ca:	f822                	sd	s0,48(sp)
 3cc:	f426                	sd	s1,40(sp)
 3ce:	f04a                	sd	s2,32(sp)
 3d0:	ec4e                	sd	s3,24(sp)
 3d2:	0080                	addi	s0,sp,64
 3d4:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d6:	c299                	beqz	a3,3dc <printint+0x16>
 3d8:	0805c063          	bltz	a1,458 <printint+0x92>
  neg = 0;
 3dc:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3de:	fc040313          	addi	t1,s0,-64
  neg = 0;
 3e2:	869a                	mv	a3,t1
  i = 0;
 3e4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3e6:	00000817          	auipc	a6,0x0
 3ea:	48a80813          	addi	a6,a6,1162 # 870 <digits>
 3ee:	88be                	mv	a7,a5
 3f0:	0017851b          	addiw	a0,a5,1
 3f4:	87aa                	mv	a5,a0
 3f6:	02c5f73b          	remuw	a4,a1,a2
 3fa:	1702                	slli	a4,a4,0x20
 3fc:	9301                	srli	a4,a4,0x20
 3fe:	9742                	add	a4,a4,a6
 400:	00074703          	lbu	a4,0(a4)
 404:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 408:	872e                	mv	a4,a1
 40a:	02c5d5bb          	divuw	a1,a1,a2
 40e:	0685                	addi	a3,a3,1
 410:	fcc77fe3          	bgeu	a4,a2,3ee <printint+0x28>
  if(neg)
 414:	000e0c63          	beqz	t3,42c <printint+0x66>
    buf[i++] = '-';
 418:	fd050793          	addi	a5,a0,-48
 41c:	00878533          	add	a0,a5,s0
 420:	02d00793          	li	a5,45
 424:	fef50823          	sb	a5,-16(a0)
 428:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 42c:	fff7899b          	addiw	s3,a5,-1
 430:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 434:	fff4c583          	lbu	a1,-1(s1)
 438:	854a                	mv	a0,s2
 43a:	00000097          	auipc	ra,0x0
 43e:	f6a080e7          	jalr	-150(ra) # 3a4 <putc>
  while(--i >= 0)
 442:	39fd                	addiw	s3,s3,-1
 444:	14fd                	addi	s1,s1,-1
 446:	fe09d7e3          	bgez	s3,434 <printint+0x6e>
}
 44a:	70e2                	ld	ra,56(sp)
 44c:	7442                	ld	s0,48(sp)
 44e:	74a2                	ld	s1,40(sp)
 450:	7902                	ld	s2,32(sp)
 452:	69e2                	ld	s3,24(sp)
 454:	6121                	addi	sp,sp,64
 456:	8082                	ret
    x = -xx;
 458:	40b005bb          	negw	a1,a1
    neg = 1;
 45c:	4e05                	li	t3,1
    x = -xx;
 45e:	b741                	j	3de <printint+0x18>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	715d                	addi	sp,sp,-80
 462:	e486                	sd	ra,72(sp)
 464:	e0a2                	sd	s0,64(sp)
 466:	f84a                	sd	s2,48(sp)
 468:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46a:	0005c903          	lbu	s2,0(a1)
 46e:	1a090a63          	beqz	s2,622 <vprintf+0x1c2>
 472:	fc26                	sd	s1,56(sp)
 474:	f44e                	sd	s3,40(sp)
 476:	f052                	sd	s4,32(sp)
 478:	ec56                	sd	s5,24(sp)
 47a:	e85a                	sd	s6,16(sp)
 47c:	e45e                	sd	s7,8(sp)
 47e:	8aaa                	mv	s5,a0
 480:	8bb2                	mv	s7,a2
 482:	00158493          	addi	s1,a1,1
  state = 0;
 486:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 488:	02500a13          	li	s4,37
 48c:	4b55                	li	s6,21
 48e:	a839                	j	4ac <vprintf+0x4c>
        putc(fd, c);
 490:	85ca                	mv	a1,s2
 492:	8556                	mv	a0,s5
 494:	00000097          	auipc	ra,0x0
 498:	f10080e7          	jalr	-240(ra) # 3a4 <putc>
 49c:	a019                	j	4a2 <vprintf+0x42>
    } else if(state == '%'){
 49e:	01498d63          	beq	s3,s4,4b8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4a2:	0485                	addi	s1,s1,1
 4a4:	fff4c903          	lbu	s2,-1(s1)
 4a8:	16090763          	beqz	s2,616 <vprintf+0x1b6>
    if(state == 0){
 4ac:	fe0999e3          	bnez	s3,49e <vprintf+0x3e>
      if(c == '%'){
 4b0:	ff4910e3          	bne	s2,s4,490 <vprintf+0x30>
        state = '%';
 4b4:	89d2                	mv	s3,s4
 4b6:	b7f5                	j	4a2 <vprintf+0x42>
      if(c == 'd'){
 4b8:	13490463          	beq	s2,s4,5e0 <vprintf+0x180>
 4bc:	f9d9079b          	addiw	a5,s2,-99
 4c0:	0ff7f793          	zext.b	a5,a5
 4c4:	12fb6763          	bltu	s6,a5,5f2 <vprintf+0x192>
 4c8:	f9d9079b          	addiw	a5,s2,-99
 4cc:	0ff7f713          	zext.b	a4,a5
 4d0:	12eb6163          	bltu	s6,a4,5f2 <vprintf+0x192>
 4d4:	00271793          	slli	a5,a4,0x2
 4d8:	00000717          	auipc	a4,0x0
 4dc:	34070713          	addi	a4,a4,832 # 818 <malloc+0x102>
 4e0:	97ba                	add	a5,a5,a4
 4e2:	439c                	lw	a5,0(a5)
 4e4:	97ba                	add	a5,a5,a4
 4e6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4e8:	008b8913          	addi	s2,s7,8
 4ec:	4685                	li	a3,1
 4ee:	4629                	li	a2,10
 4f0:	000ba583          	lw	a1,0(s7)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	ed0080e7          	jalr	-304(ra) # 3c6 <printint>
 4fe:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 500:	4981                	li	s3,0
 502:	b745                	j	4a2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 504:	008b8913          	addi	s2,s7,8
 508:	4681                	li	a3,0
 50a:	4629                	li	a2,10
 50c:	000ba583          	lw	a1,0(s7)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	eb4080e7          	jalr	-332(ra) # 3c6 <printint>
 51a:	8bca                	mv	s7,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	b751                	j	4a2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 520:	008b8913          	addi	s2,s7,8
 524:	4681                	li	a3,0
 526:	4641                	li	a2,16
 528:	000ba583          	lw	a1,0(s7)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e98080e7          	jalr	-360(ra) # 3c6 <printint>
 536:	8bca                	mv	s7,s2
      state = 0;
 538:	4981                	li	s3,0
 53a:	b7a5                	j	4a2 <vprintf+0x42>
 53c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 53e:	008b8c13          	addi	s8,s7,8
 542:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 546:	03000593          	li	a1,48
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e58080e7          	jalr	-424(ra) # 3a4 <putc>
  putc(fd, 'x');
 554:	07800593          	li	a1,120
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e4a080e7          	jalr	-438(ra) # 3a4 <putc>
 562:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 564:	00000b97          	auipc	s7,0x0
 568:	30cb8b93          	addi	s7,s7,780 # 870 <digits>
 56c:	03c9d793          	srli	a5,s3,0x3c
 570:	97de                	add	a5,a5,s7
 572:	0007c583          	lbu	a1,0(a5)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e2c080e7          	jalr	-468(ra) # 3a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 580:	0992                	slli	s3,s3,0x4
 582:	397d                	addiw	s2,s2,-1
 584:	fe0914e3          	bnez	s2,56c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 588:	8be2                	mv	s7,s8
      state = 0;
 58a:	4981                	li	s3,0
 58c:	6c02                	ld	s8,0(sp)
 58e:	bf11                	j	4a2 <vprintf+0x42>
        s = va_arg(ap, char*);
 590:	008b8993          	addi	s3,s7,8
 594:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 598:	02090163          	beqz	s2,5ba <vprintf+0x15a>
        while(*s != 0){
 59c:	00094583          	lbu	a1,0(s2)
 5a0:	c9a5                	beqz	a1,610 <vprintf+0x1b0>
          putc(fd, *s);
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e00080e7          	jalr	-512(ra) # 3a4 <putc>
          s++;
 5ac:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ae:	00094583          	lbu	a1,0(s2)
 5b2:	f9e5                	bnez	a1,5a2 <vprintf+0x142>
        s = va_arg(ap, char*);
 5b4:	8bce                	mv	s7,s3
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b5ed                	j	4a2 <vprintf+0x42>
          s = "(null)";
 5ba:	00000917          	auipc	s2,0x0
 5be:	25690913          	addi	s2,s2,598 # 810 <malloc+0xfa>
        while(*s != 0){
 5c2:	02800593          	li	a1,40
 5c6:	bff1                	j	5a2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	000bc583          	lbu	a1,0(s7)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	dd2080e7          	jalr	-558(ra) # 3a4 <putc>
 5da:	8bca                	mv	s7,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b5d1                	j	4a2 <vprintf+0x42>
        putc(fd, c);
 5e0:	02500593          	li	a1,37
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	dbe080e7          	jalr	-578(ra) # 3a4 <putc>
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bd4d                	j	4a2 <vprintf+0x42>
        putc(fd, '%');
 5f2:	02500593          	li	a1,37
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	dac080e7          	jalr	-596(ra) # 3a4 <putc>
        putc(fd, c);
 600:	85ca                	mv	a1,s2
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	da0080e7          	jalr	-608(ra) # 3a4 <putc>
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd51                	j	4a2 <vprintf+0x42>
        s = va_arg(ap, char*);
 610:	8bce                	mv	s7,s3
      state = 0;
 612:	4981                	li	s3,0
 614:	b579                	j	4a2 <vprintf+0x42>
 616:	74e2                	ld	s1,56(sp)
 618:	79a2                	ld	s3,40(sp)
 61a:	7a02                	ld	s4,32(sp)
 61c:	6ae2                	ld	s5,24(sp)
 61e:	6b42                	ld	s6,16(sp)
 620:	6ba2                	ld	s7,8(sp)
    }
  }
}
 622:	60a6                	ld	ra,72(sp)
 624:	6406                	ld	s0,64(sp)
 626:	7942                	ld	s2,48(sp)
 628:	6161                	addi	sp,sp,80
 62a:	8082                	ret

000000000000062c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 62c:	715d                	addi	sp,sp,-80
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e010                	sd	a2,0(s0)
 636:	e414                	sd	a3,8(s0)
 638:	e818                	sd	a4,16(s0)
 63a:	ec1c                	sd	a5,24(s0)
 63c:	03043023          	sd	a6,32(s0)
 640:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 644:	8622                	mv	a2,s0
 646:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 64a:	00000097          	auipc	ra,0x0
 64e:	e16080e7          	jalr	-490(ra) # 460 <vprintf>
}
 652:	60e2                	ld	ra,24(sp)
 654:	6442                	ld	s0,16(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret

000000000000065a <printf>:

void
printf(const char *fmt, ...)
{
 65a:	711d                	addi	sp,sp,-96
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	e40c                	sd	a1,8(s0)
 664:	e810                	sd	a2,16(s0)
 666:	ec14                	sd	a3,24(s0)
 668:	f018                	sd	a4,32(s0)
 66a:	f41c                	sd	a5,40(s0)
 66c:	03043823          	sd	a6,48(s0)
 670:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 674:	00840613          	addi	a2,s0,8
 678:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 67c:	85aa                	mv	a1,a0
 67e:	4505                	li	a0,1
 680:	00000097          	auipc	ra,0x0
 684:	de0080e7          	jalr	-544(ra) # 460 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6125                	addi	sp,sp,96
 68e:	8082                	ret

0000000000000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	1141                	addi	sp,sp,-16
 692:	e406                	sd	ra,8(sp)
 694:	e022                	sd	s0,0(sp)
 696:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 698:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69c:	00001797          	auipc	a5,0x1
 6a0:	9647b783          	ld	a5,-1692(a5) # 1000 <freep>
 6a4:	a02d                	j	6ce <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a6:	4618                	lw	a4,8(a2)
 6a8:	9f2d                	addw	a4,a4,a1
 6aa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ae:	6398                	ld	a4,0(a5)
 6b0:	6310                	ld	a2,0(a4)
 6b2:	a83d                	j	6f0 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6b4:	ff852703          	lw	a4,-8(a0)
 6b8:	9f31                	addw	a4,a4,a2
 6ba:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6bc:	ff053683          	ld	a3,-16(a0)
 6c0:	a091                	j	704 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c2:	6398                	ld	a4,0(a5)
 6c4:	00e7e463          	bltu	a5,a4,6cc <free+0x3c>
 6c8:	00e6ea63          	bltu	a3,a4,6dc <free+0x4c>
{
 6cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ce:	fed7fae3          	bgeu	a5,a3,6c2 <free+0x32>
 6d2:	6398                	ld	a4,0(a5)
 6d4:	00e6e463          	bltu	a3,a4,6dc <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d8:	fee7eae3          	bltu	a5,a4,6cc <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 6dc:	ff852583          	lw	a1,-8(a0)
 6e0:	6390                	ld	a2,0(a5)
 6e2:	02059813          	slli	a6,a1,0x20
 6e6:	01c85713          	srli	a4,a6,0x1c
 6ea:	9736                	add	a4,a4,a3
 6ec:	fae60de3          	beq	a2,a4,6a6 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 6f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f4:	4790                	lw	a2,8(a5)
 6f6:	02061593          	slli	a1,a2,0x20
 6fa:	01c5d713          	srli	a4,a1,0x1c
 6fe:	973e                	add	a4,a4,a5
 700:	fae68ae3          	beq	a3,a4,6b4 <free+0x24>
    p->s.ptr = bp->s.ptr;
 704:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 706:	00001717          	auipc	a4,0x1
 70a:	8ef73d23          	sd	a5,-1798(a4) # 1000 <freep>
}
 70e:	60a2                	ld	ra,8(sp)
 710:	6402                	ld	s0,0(sp)
 712:	0141                	addi	sp,sp,16
 714:	8082                	ret

0000000000000716 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 716:	7139                	addi	sp,sp,-64
 718:	fc06                	sd	ra,56(sp)
 71a:	f822                	sd	s0,48(sp)
 71c:	f04a                	sd	s2,32(sp)
 71e:	ec4e                	sd	s3,24(sp)
 720:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 722:	02051993          	slli	s3,a0,0x20
 726:	0209d993          	srli	s3,s3,0x20
 72a:	09bd                	addi	s3,s3,15
 72c:	0049d993          	srli	s3,s3,0x4
 730:	2985                	addiw	s3,s3,1
 732:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 734:	00001517          	auipc	a0,0x1
 738:	8cc53503          	ld	a0,-1844(a0) # 1000 <freep>
 73c:	c905                	beqz	a0,76c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 73e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 740:	4798                	lw	a4,8(a5)
 742:	09377a63          	bgeu	a4,s3,7d6 <malloc+0xc0>
 746:	f426                	sd	s1,40(sp)
 748:	e852                	sd	s4,16(sp)
 74a:	e456                	sd	s5,8(sp)
 74c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 74e:	8a4e                	mv	s4,s3
 750:	6705                	lui	a4,0x1
 752:	00e9f363          	bgeu	s3,a4,758 <malloc+0x42>
 756:	6a05                	lui	s4,0x1
 758:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 75c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 760:	00001497          	auipc	s1,0x1
 764:	8a048493          	addi	s1,s1,-1888 # 1000 <freep>
  if(p == (char*)-1)
 768:	5afd                	li	s5,-1
 76a:	a089                	j	7ac <malloc+0x96>
 76c:	f426                	sd	s1,40(sp)
 76e:	e852                	sd	s4,16(sp)
 770:	e456                	sd	s5,8(sp)
 772:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 774:	00001797          	auipc	a5,0x1
 778:	89c78793          	addi	a5,a5,-1892 # 1010 <base>
 77c:	00001717          	auipc	a4,0x1
 780:	88f73223          	sd	a5,-1916(a4) # 1000 <freep>
 784:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 786:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 78a:	b7d1                	j	74e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	e118                	sd	a4,0(a0)
 790:	a8b9                	j	7ee <malloc+0xd8>
  hp->s.size = nu;
 792:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 796:	0541                	addi	a0,a0,16
 798:	00000097          	auipc	ra,0x0
 79c:	ef8080e7          	jalr	-264(ra) # 690 <free>
  return freep;
 7a0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7a2:	c135                	beqz	a0,806 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a6:	4798                	lw	a4,8(a5)
 7a8:	03277363          	bgeu	a4,s2,7ce <malloc+0xb8>
    if(p == freep)
 7ac:	6098                	ld	a4,0(s1)
 7ae:	853e                	mv	a0,a5
 7b0:	fef71ae3          	bne	a4,a5,7a4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7b4:	8552                	mv	a0,s4
 7b6:	00000097          	auipc	ra,0x0
 7ba:	bb6080e7          	jalr	-1098(ra) # 36c <sbrk>
  if(p == (char*)-1)
 7be:	fd551ae3          	bne	a0,s5,792 <malloc+0x7c>
        return 0;
 7c2:	4501                	li	a0,0
 7c4:	74a2                	ld	s1,40(sp)
 7c6:	6a42                	ld	s4,16(sp)
 7c8:	6aa2                	ld	s5,8(sp)
 7ca:	6b02                	ld	s6,0(sp)
 7cc:	a03d                	j	7fa <malloc+0xe4>
 7ce:	74a2                	ld	s1,40(sp)
 7d0:	6a42                	ld	s4,16(sp)
 7d2:	6aa2                	ld	s5,8(sp)
 7d4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7d6:	fae90be3          	beq	s2,a4,78c <malloc+0x76>
        p->s.size -= nunits;
 7da:	4137073b          	subw	a4,a4,s3
 7de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7e0:	02071693          	slli	a3,a4,0x20
 7e4:	01c6d713          	srli	a4,a3,0x1c
 7e8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ea:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ee:	00001717          	auipc	a4,0x1
 7f2:	80a73923          	sd	a0,-2030(a4) # 1000 <freep>
      return (void*)(p + 1);
 7f6:	01078513          	addi	a0,a5,16
  }
}
 7fa:	70e2                	ld	ra,56(sp)
 7fc:	7442                	ld	s0,48(sp)
 7fe:	7902                	ld	s2,32(sp)
 800:	69e2                	ld	s3,24(sp)
 802:	6121                	addi	sp,sp,64
 804:	8082                	ret
 806:	74a2                	ld	s1,40(sp)
 808:	6a42                	ld	s4,16(sp)
 80a:	6aa2                	ld	s5,8(sp)
 80c:	6b02                	ld	s6,0(sp)
 80e:	b7f5                	j	7fa <malloc+0xe4>
