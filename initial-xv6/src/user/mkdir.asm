
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7dd63          	bge	a5,a0,44 <main+0x44>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	374080e7          	jalr	884(ra) # 39c <mkdir>
  30:	02054a63          	bltz	a0,64 <main+0x64>
  for(i = 1; i < argc; i++){
  34:	04a1                	addi	s1,s1,8
  36:	ff2498e3          	bne	s1,s2,26 <main+0x26>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	2f8080e7          	jalr	760(ra) # 334 <exit>
  44:	e426                	sd	s1,8(sp)
  46:	e04a                	sd	s2,0(sp)
    fprintf(2, "Usage: mkdir files...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	81858593          	addi	a1,a1,-2024 # 860 <malloc+0xfa>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	62a080e7          	jalr	1578(ra) # 67c <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2d8080e7          	jalr	728(ra) # 334 <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  64:	6090                	ld	a2,0(s1)
  66:	00001597          	auipc	a1,0x1
  6a:	81258593          	addi	a1,a1,-2030 # 878 <malloc+0x112>
  6e:	4509                	li	a0,2
  70:	00000097          	auipc	ra,0x0
  74:	60c080e7          	jalr	1548(ra) # 67c <fprintf>
      break;
  78:	b7c9                	j	3a <main+0x3a>

000000000000007a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e406                	sd	ra,8(sp)
  7e:	e022                	sd	s0,0(sp)
  80:	0800                	addi	s0,sp,16
  extern int main();
  main();
  82:	00000097          	auipc	ra,0x0
  86:	f7e080e7          	jalr	-130(ra) # 0 <main>
  exit(0);
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	2a8080e7          	jalr	680(ra) # 334 <exit>

0000000000000094 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0xa>
    ;
  return os;
}
  ac:	60a2                	ld	ra,8(sp)
  ae:	6402                	ld	s0,0(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x20>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x20>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf99                	beqz	a5,10e <strlen+0x2a>
  f2:	0505                	addi	a0,a0,1
  f4:	87aa                	mv	a5,a0
  f6:	86be                	mv	a3,a5
  f8:	0785                	addi	a5,a5,1
  fa:	fff7c703          	lbu	a4,-1(a5)
  fe:	ff65                	bnez	a4,f6 <strlen+0x12>
 100:	40a6853b          	subw	a0,a3,a0
 104:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 106:	60a2                	ld	ra,8(sp)
 108:	6402                	ld	s0,0(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  for(n = 0; s[n]; n++)
 10e:	4501                	li	a0,0
 110:	bfdd                	j	106 <strlen+0x22>

0000000000000112 <memset>:

void*
memset(void *dst, int c, uint n)
{
 112:	1141                	addi	sp,sp,-16
 114:	e406                	sd	ra,8(sp)
 116:	e022                	sd	s0,0(sp)
 118:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11a:	ca19                	beqz	a2,130 <memset+0x1e>
 11c:	87aa                	mv	a5,a0
 11e:	1602                	slli	a2,a2,0x20
 120:	9201                	srli	a2,a2,0x20
 122:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 126:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12a:	0785                	addi	a5,a5,1
 12c:	fee79de3          	bne	a5,a4,126 <memset+0x14>
  }
  return dst;
}
 130:	60a2                	ld	ra,8(sp)
 132:	6402                	ld	s0,0(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret

0000000000000138 <strchr>:

char*
strchr(const char *s, char c)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 140:	00054783          	lbu	a5,0(a0)
 144:	cf81                	beqz	a5,15c <strchr+0x24>
    if(*s == c)
 146:	00f58763          	beq	a1,a5,154 <strchr+0x1c>
  for(; *s; s++)
 14a:	0505                	addi	a0,a0,1
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbfd                	bnez	a5,146 <strchr+0xe>
      return (char*)s;
  return 0;
 152:	4501                	li	a0,0
}
 154:	60a2                	ld	ra,8(sp)
 156:	6402                	ld	s0,0(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfdd                	j	154 <strchr+0x1c>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	7159                	addi	sp,sp,-112
 162:	f486                	sd	ra,104(sp)
 164:	f0a2                	sd	s0,96(sp)
 166:	eca6                	sd	s1,88(sp)
 168:	e8ca                	sd	s2,80(sp)
 16a:	e4ce                	sd	s3,72(sp)
 16c:	e0d2                	sd	s4,64(sp)
 16e:	fc56                	sd	s5,56(sp)
 170:	f85a                	sd	s6,48(sp)
 172:	f45e                	sd	s7,40(sp)
 174:	f062                	sd	s8,32(sp)
 176:	ec66                	sd	s9,24(sp)
 178:	e86a                	sd	s10,16(sp)
 17a:	1880                	addi	s0,sp,112
 17c:	8caa                	mv	s9,a0
 17e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	892a                	mv	s2,a0
 182:	4481                	li	s1,0
    cc = read(0, &c, 1);
 184:	f9f40b13          	addi	s6,s0,-97
 188:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18a:	4ba9                	li	s7,10
 18c:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 18e:	8d26                	mv	s10,s1
 190:	0014899b          	addiw	s3,s1,1
 194:	84ce                	mv	s1,s3
 196:	0349d763          	bge	s3,s4,1c4 <gets+0x64>
    cc = read(0, &c, 1);
 19a:	8656                	mv	a2,s5
 19c:	85da                	mv	a1,s6
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	1ac080e7          	jalr	428(ra) # 34c <read>
    if(cc < 1)
 1a8:	00a05e63          	blez	a0,1c4 <gets+0x64>
    buf[i++] = c;
 1ac:	f9f44783          	lbu	a5,-97(s0)
 1b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b4:	01778763          	beq	a5,s7,1c2 <gets+0x62>
 1b8:	0905                	addi	s2,s2,1
 1ba:	fd879ae3          	bne	a5,s8,18e <gets+0x2e>
    buf[i++] = c;
 1be:	8d4e                	mv	s10,s3
 1c0:	a011                	j	1c4 <gets+0x64>
 1c2:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1c4:	9d66                	add	s10,s10,s9
 1c6:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1ca:	8566                	mv	a0,s9
 1cc:	70a6                	ld	ra,104(sp)
 1ce:	7406                	ld	s0,96(sp)
 1d0:	64e6                	ld	s1,88(sp)
 1d2:	6946                	ld	s2,80(sp)
 1d4:	69a6                	ld	s3,72(sp)
 1d6:	6a06                	ld	s4,64(sp)
 1d8:	7ae2                	ld	s5,56(sp)
 1da:	7b42                	ld	s6,48(sp)
 1dc:	7ba2                	ld	s7,40(sp)
 1de:	7c02                	ld	s8,32(sp)
 1e0:	6ce2                	ld	s9,24(sp)
 1e2:	6d42                	ld	s10,16(sp)
 1e4:	6165                	addi	sp,sp,112
 1e6:	8082                	ret

00000000000001e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e8:	1101                	addi	sp,sp,-32
 1ea:	ec06                	sd	ra,24(sp)
 1ec:	e822                	sd	s0,16(sp)
 1ee:	e04a                	sd	s2,0(sp)
 1f0:	1000                	addi	s0,sp,32
 1f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	4581                	li	a1,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	17e080e7          	jalr	382(ra) # 374 <open>
  if(fd < 0)
 1fe:	02054663          	bltz	a0,22a <stat+0x42>
 202:	e426                	sd	s1,8(sp)
 204:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 206:	85ca                	mv	a1,s2
 208:	00000097          	auipc	ra,0x0
 20c:	184080e7          	jalr	388(ra) # 38c <fstat>
 210:	892a                	mv	s2,a0
  close(fd);
 212:	8526                	mv	a0,s1
 214:	00000097          	auipc	ra,0x0
 218:	148080e7          	jalr	328(ra) # 35c <close>
  return r;
 21c:	64a2                	ld	s1,8(sp)
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfcd                	j	21e <stat+0x36>

000000000000022e <atoi>:

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e406                	sd	ra,8(sp)
 232:	e022                	sd	s0,0(sp)
 234:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 236:	00054683          	lbu	a3,0(a0)
 23a:	fd06879b          	addiw	a5,a3,-48
 23e:	0ff7f793          	zext.b	a5,a5
 242:	4625                	li	a2,9
 244:	02f66963          	bltu	a2,a5,276 <atoi+0x48>
 248:	872a                	mv	a4,a0
  n = 0;
 24a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24c:	0705                	addi	a4,a4,1
 24e:	0025179b          	slliw	a5,a0,0x2
 252:	9fa9                	addw	a5,a5,a0
 254:	0017979b          	slliw	a5,a5,0x1
 258:	9fb5                	addw	a5,a5,a3
 25a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25e:	00074683          	lbu	a3,0(a4)
 262:	fd06879b          	addiw	a5,a3,-48
 266:	0ff7f793          	zext.b	a5,a5
 26a:	fef671e3          	bgeu	a2,a5,24c <atoi+0x1e>
  return n;
}
 26e:	60a2                	ld	ra,8(sp)
 270:	6402                	ld	s0,0(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  n = 0;
 276:	4501                	li	a0,0
 278:	bfdd                	j	26e <atoi+0x40>

000000000000027a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 282:	02b57563          	bgeu	a0,a1,2ac <memmove+0x32>
    while(n-- > 0)
 286:	00c05f63          	blez	a2,2a4 <memmove+0x2a>
 28a:	1602                	slli	a2,a2,0x20
 28c:	9201                	srli	a2,a2,0x20
 28e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 292:	872a                	mv	a4,a0
      *dst++ = *src++;
 294:	0585                	addi	a1,a1,1
 296:	0705                	addi	a4,a4,1
 298:	fff5c683          	lbu	a3,-1(a1)
 29c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a0:	fee79ae3          	bne	a5,a4,294 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec059e3          	blez	a2,2a4 <memmove+0x2a>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fef71ae3          	bne	a4,a5,2c4 <memmove+0x4a>
 2d4:	bfc1                	j	2a4 <memmove+0x2a>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2de:	ca0d                	beqz	a2,310 <memcmp+0x3a>
 2e0:	fff6069b          	addiw	a3,a2,-1
 2e4:	1682                	slli	a3,a3,0x20
 2e6:	9281                	srli	a3,a3,0x20
 2e8:	0685                	addi	a3,a3,1
 2ea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	0005c703          	lbu	a4,0(a1)
 2f4:	00e79863          	bne	a5,a4,304 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2f8:	0505                	addi	a0,a0,1
    p2++;
 2fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fc:	fed518e3          	bne	a0,a3,2ec <memcmp+0x16>
  }
  return 0;
 300:	4501                	li	a0,0
 302:	a019                	j	308 <memcmp+0x32>
      return *p1 - *p2;
 304:	40e7853b          	subw	a0,a5,a4
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfdd                	j	308 <memcmp+0x32>

0000000000000314 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31c:	00000097          	auipc	ra,0x0
 320:	f5e080e7          	jalr	-162(ra) # 27a <memmove>
}
 324:	60a2                	ld	ra,8(sp)
 326:	6402                	ld	s0,0(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret

000000000000032c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32c:	4885                	li	a7,1
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exit>:
.global exit
exit:
 li a7, SYS_exit
 334:	4889                	li	a7,2
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <wait>:
.global wait
wait:
 li a7, SYS_wait
 33c:	488d                	li	a7,3
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 344:	4891                	li	a7,4
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <read>:
.global read
read:
 li a7, SYS_read
 34c:	4895                	li	a7,5
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <write>:
.global write
write:
 li a7, SYS_write
 354:	48c1                	li	a7,16
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <close>:
.global close
close:
 li a7, SYS_close
 35c:	48d5                	li	a7,21
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <kill>:
.global kill
kill:
 li a7, SYS_kill
 364:	4899                	li	a7,6
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exec>:
.global exec
exec:
 li a7, SYS_exec
 36c:	489d                	li	a7,7
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <open>:
.global open
open:
 li a7, SYS_open
 374:	48bd                	li	a7,15
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37c:	48c5                	li	a7,17
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 384:	48c9                	li	a7,18
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38c:	48a1                	li	a7,8
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <link>:
.global link
link:
 li a7, SYS_link
 394:	48cd                	li	a7,19
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39c:	48d1                	li	a7,20
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a4:	48a5                	li	a7,9
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ac:	48a9                	li	a7,10
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b4:	48ad                	li	a7,11
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3bc:	48b1                	li	a7,12
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c4:	48b5                	li	a7,13
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3cc:	48b9                	li	a7,14
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3d4:	48d9                	li	a7,22
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 3dc:	48dd                	li	a7,23
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3e4:	48e1                	li	a7,24
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3ec:	48e5                	li	a7,25
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f4:	1101                	addi	sp,sp,-32
 3f6:	ec06                	sd	ra,24(sp)
 3f8:	e822                	sd	s0,16(sp)
 3fa:	1000                	addi	s0,sp,32
 3fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 400:	4605                	li	a2,1
 402:	fef40593          	addi	a1,s0,-17
 406:	00000097          	auipc	ra,0x0
 40a:	f4e080e7          	jalr	-178(ra) # 354 <write>
}
 40e:	60e2                	ld	ra,24(sp)
 410:	6442                	ld	s0,16(sp)
 412:	6105                	addi	sp,sp,32
 414:	8082                	ret

0000000000000416 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 416:	7139                	addi	sp,sp,-64
 418:	fc06                	sd	ra,56(sp)
 41a:	f822                	sd	s0,48(sp)
 41c:	f426                	sd	s1,40(sp)
 41e:	f04a                	sd	s2,32(sp)
 420:	ec4e                	sd	s3,24(sp)
 422:	0080                	addi	s0,sp,64
 424:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 426:	c299                	beqz	a3,42c <printint+0x16>
 428:	0805c063          	bltz	a1,4a8 <printint+0x92>
  neg = 0;
 42c:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 42e:	fc040313          	addi	t1,s0,-64
  neg = 0;
 432:	869a                	mv	a3,t1
  i = 0;
 434:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 436:	00000817          	auipc	a6,0x0
 43a:	4c280813          	addi	a6,a6,1218 # 8f8 <digits>
 43e:	88be                	mv	a7,a5
 440:	0017851b          	addiw	a0,a5,1
 444:	87aa                	mv	a5,a0
 446:	02c5f73b          	remuw	a4,a1,a2
 44a:	1702                	slli	a4,a4,0x20
 44c:	9301                	srli	a4,a4,0x20
 44e:	9742                	add	a4,a4,a6
 450:	00074703          	lbu	a4,0(a4)
 454:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 458:	872e                	mv	a4,a1
 45a:	02c5d5bb          	divuw	a1,a1,a2
 45e:	0685                	addi	a3,a3,1
 460:	fcc77fe3          	bgeu	a4,a2,43e <printint+0x28>
  if(neg)
 464:	000e0c63          	beqz	t3,47c <printint+0x66>
    buf[i++] = '-';
 468:	fd050793          	addi	a5,a0,-48
 46c:	00878533          	add	a0,a5,s0
 470:	02d00793          	li	a5,45
 474:	fef50823          	sb	a5,-16(a0)
 478:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 47c:	fff7899b          	addiw	s3,a5,-1
 480:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 484:	fff4c583          	lbu	a1,-1(s1)
 488:	854a                	mv	a0,s2
 48a:	00000097          	auipc	ra,0x0
 48e:	f6a080e7          	jalr	-150(ra) # 3f4 <putc>
  while(--i >= 0)
 492:	39fd                	addiw	s3,s3,-1
 494:	14fd                	addi	s1,s1,-1
 496:	fe09d7e3          	bgez	s3,484 <printint+0x6e>
}
 49a:	70e2                	ld	ra,56(sp)
 49c:	7442                	ld	s0,48(sp)
 49e:	74a2                	ld	s1,40(sp)
 4a0:	7902                	ld	s2,32(sp)
 4a2:	69e2                	ld	s3,24(sp)
 4a4:	6121                	addi	sp,sp,64
 4a6:	8082                	ret
    x = -xx;
 4a8:	40b005bb          	negw	a1,a1
    neg = 1;
 4ac:	4e05                	li	t3,1
    x = -xx;
 4ae:	b741                	j	42e <printint+0x18>

00000000000004b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b0:	715d                	addi	sp,sp,-80
 4b2:	e486                	sd	ra,72(sp)
 4b4:	e0a2                	sd	s0,64(sp)
 4b6:	f84a                	sd	s2,48(sp)
 4b8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ba:	0005c903          	lbu	s2,0(a1)
 4be:	1a090a63          	beqz	s2,672 <vprintf+0x1c2>
 4c2:	fc26                	sd	s1,56(sp)
 4c4:	f44e                	sd	s3,40(sp)
 4c6:	f052                	sd	s4,32(sp)
 4c8:	ec56                	sd	s5,24(sp)
 4ca:	e85a                	sd	s6,16(sp)
 4cc:	e45e                	sd	s7,8(sp)
 4ce:	8aaa                	mv	s5,a0
 4d0:	8bb2                	mv	s7,a2
 4d2:	00158493          	addi	s1,a1,1
  state = 0;
 4d6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d8:	02500a13          	li	s4,37
 4dc:	4b55                	li	s6,21
 4de:	a839                	j	4fc <vprintf+0x4c>
        putc(fd, c);
 4e0:	85ca                	mv	a1,s2
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f10080e7          	jalr	-240(ra) # 3f4 <putc>
 4ec:	a019                	j	4f2 <vprintf+0x42>
    } else if(state == '%'){
 4ee:	01498d63          	beq	s3,s4,508 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4f2:	0485                	addi	s1,s1,1
 4f4:	fff4c903          	lbu	s2,-1(s1)
 4f8:	16090763          	beqz	s2,666 <vprintf+0x1b6>
    if(state == 0){
 4fc:	fe0999e3          	bnez	s3,4ee <vprintf+0x3e>
      if(c == '%'){
 500:	ff4910e3          	bne	s2,s4,4e0 <vprintf+0x30>
        state = '%';
 504:	89d2                	mv	s3,s4
 506:	b7f5                	j	4f2 <vprintf+0x42>
      if(c == 'd'){
 508:	13490463          	beq	s2,s4,630 <vprintf+0x180>
 50c:	f9d9079b          	addiw	a5,s2,-99
 510:	0ff7f793          	zext.b	a5,a5
 514:	12fb6763          	bltu	s6,a5,642 <vprintf+0x192>
 518:	f9d9079b          	addiw	a5,s2,-99
 51c:	0ff7f713          	zext.b	a4,a5
 520:	12eb6163          	bltu	s6,a4,642 <vprintf+0x192>
 524:	00271793          	slli	a5,a4,0x2
 528:	00000717          	auipc	a4,0x0
 52c:	37870713          	addi	a4,a4,888 # 8a0 <malloc+0x13a>
 530:	97ba                	add	a5,a5,a4
 532:	439c                	lw	a5,0(a5)
 534:	97ba                	add	a5,a5,a4
 536:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 538:	008b8913          	addi	s2,s7,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	ed0080e7          	jalr	-304(ra) # 416 <printint>
 54e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 550:	4981                	li	s3,0
 552:	b745                	j	4f2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 554:	008b8913          	addi	s2,s7,8
 558:	4681                	li	a3,0
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	eb4080e7          	jalr	-332(ra) # 416 <printint>
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b751                	j	4f2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 570:	008b8913          	addi	s2,s7,8
 574:	4681                	li	a3,0
 576:	4641                	li	a2,16
 578:	000ba583          	lw	a1,0(s7)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e98080e7          	jalr	-360(ra) # 416 <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b7a5                	j	4f2 <vprintf+0x42>
 58c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 58e:	008b8c13          	addi	s8,s7,8
 592:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 596:	03000593          	li	a1,48
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e58080e7          	jalr	-424(ra) # 3f4 <putc>
  putc(fd, 'x');
 5a4:	07800593          	li	a1,120
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e4a080e7          	jalr	-438(ra) # 3f4 <putc>
 5b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b4:	00000b97          	auipc	s7,0x0
 5b8:	344b8b93          	addi	s7,s7,836 # 8f8 <digits>
 5bc:	03c9d793          	srli	a5,s3,0x3c
 5c0:	97de                	add	a5,a5,s7
 5c2:	0007c583          	lbu	a1,0(a5)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e2c080e7          	jalr	-468(ra) # 3f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d0:	0992                	slli	s3,s3,0x4
 5d2:	397d                	addiw	s2,s2,-1
 5d4:	fe0914e3          	bnez	s2,5bc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5d8:	8be2                	mv	s7,s8
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	6c02                	ld	s8,0(sp)
 5de:	bf11                	j	4f2 <vprintf+0x42>
        s = va_arg(ap, char*);
 5e0:	008b8993          	addi	s3,s7,8
 5e4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5e8:	02090163          	beqz	s2,60a <vprintf+0x15a>
        while(*s != 0){
 5ec:	00094583          	lbu	a1,0(s2)
 5f0:	c9a5                	beqz	a1,660 <vprintf+0x1b0>
          putc(fd, *s);
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e00080e7          	jalr	-512(ra) # 3f4 <putc>
          s++;
 5fc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5fe:	00094583          	lbu	a1,0(s2)
 602:	f9e5                	bnez	a1,5f2 <vprintf+0x142>
        s = va_arg(ap, char*);
 604:	8bce                	mv	s7,s3
      state = 0;
 606:	4981                	li	s3,0
 608:	b5ed                	j	4f2 <vprintf+0x42>
          s = "(null)";
 60a:	00000917          	auipc	s2,0x0
 60e:	28e90913          	addi	s2,s2,654 # 898 <malloc+0x132>
        while(*s != 0){
 612:	02800593          	li	a1,40
 616:	bff1                	j	5f2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 618:	008b8913          	addi	s2,s7,8
 61c:	000bc583          	lbu	a1,0(s7)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	dd2080e7          	jalr	-558(ra) # 3f4 <putc>
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5d1                	j	4f2 <vprintf+0x42>
        putc(fd, c);
 630:	02500593          	li	a1,37
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	dbe080e7          	jalr	-578(ra) # 3f4 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd4d                	j	4f2 <vprintf+0x42>
        putc(fd, '%');
 642:	02500593          	li	a1,37
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dac080e7          	jalr	-596(ra) # 3f4 <putc>
        putc(fd, c);
 650:	85ca                	mv	a1,s2
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	da0080e7          	jalr	-608(ra) # 3f4 <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd51                	j	4f2 <vprintf+0x42>
        s = va_arg(ap, char*);
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b579                	j	4f2 <vprintf+0x42>
 666:	74e2                	ld	s1,56(sp)
 668:	79a2                	ld	s3,40(sp)
 66a:	7a02                	ld	s4,32(sp)
 66c:	6ae2                	ld	s5,24(sp)
 66e:	6b42                	ld	s6,16(sp)
 670:	6ba2                	ld	s7,8(sp)
    }
  }
}
 672:	60a6                	ld	ra,72(sp)
 674:	6406                	ld	s0,64(sp)
 676:	7942                	ld	s2,48(sp)
 678:	6161                	addi	sp,sp,80
 67a:	8082                	ret

000000000000067c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 67c:	715d                	addi	sp,sp,-80
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	e010                	sd	a2,0(s0)
 686:	e414                	sd	a3,8(s0)
 688:	e818                	sd	a4,16(s0)
 68a:	ec1c                	sd	a5,24(s0)
 68c:	03043023          	sd	a6,32(s0)
 690:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 694:	8622                	mv	a2,s0
 696:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 69a:	00000097          	auipc	ra,0x0
 69e:	e16080e7          	jalr	-490(ra) # 4b0 <vprintf>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret

00000000000006aa <printf>:

void
printf(const char *fmt, ...)
{
 6aa:	711d                	addi	sp,sp,-96
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e40c                	sd	a1,8(s0)
 6b4:	e810                	sd	a2,16(s0)
 6b6:	ec14                	sd	a3,24(s0)
 6b8:	f018                	sd	a4,32(s0)
 6ba:	f41c                	sd	a5,40(s0)
 6bc:	03043823          	sd	a6,48(s0)
 6c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	00840613          	addi	a2,s0,8
 6c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6cc:	85aa                	mv	a1,a0
 6ce:	4505                	li	a0,1
 6d0:	00000097          	auipc	ra,0x0
 6d4:	de0080e7          	jalr	-544(ra) # 4b0 <vprintf>
}
 6d8:	60e2                	ld	ra,24(sp)
 6da:	6442                	ld	s0,16(sp)
 6dc:	6125                	addi	sp,sp,96
 6de:	8082                	ret

00000000000006e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e0:	1141                	addi	sp,sp,-16
 6e2:	e406                	sd	ra,8(sp)
 6e4:	e022                	sd	s0,0(sp)
 6e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ec:	00001797          	auipc	a5,0x1
 6f0:	9147b783          	ld	a5,-1772(a5) # 1000 <freep>
 6f4:	a02d                	j	71e <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f6:	4618                	lw	a4,8(a2)
 6f8:	9f2d                	addw	a4,a4,a1
 6fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fe:	6398                	ld	a4,0(a5)
 700:	6310                	ld	a2,0(a4)
 702:	a83d                	j	740 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 704:	ff852703          	lw	a4,-8(a0)
 708:	9f31                	addw	a4,a4,a2
 70a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 70c:	ff053683          	ld	a3,-16(a0)
 710:	a091                	j	754 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 712:	6398                	ld	a4,0(a5)
 714:	00e7e463          	bltu	a5,a4,71c <free+0x3c>
 718:	00e6ea63          	bltu	a3,a4,72c <free+0x4c>
{
 71c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71e:	fed7fae3          	bgeu	a5,a3,712 <free+0x32>
 722:	6398                	ld	a4,0(a5)
 724:	00e6e463          	bltu	a3,a4,72c <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 728:	fee7eae3          	bltu	a5,a4,71c <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 72c:	ff852583          	lw	a1,-8(a0)
 730:	6390                	ld	a2,0(a5)
 732:	02059813          	slli	a6,a1,0x20
 736:	01c85713          	srli	a4,a6,0x1c
 73a:	9736                	add	a4,a4,a3
 73c:	fae60de3          	beq	a2,a4,6f6 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 740:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 744:	4790                	lw	a2,8(a5)
 746:	02061593          	slli	a1,a2,0x20
 74a:	01c5d713          	srli	a4,a1,0x1c
 74e:	973e                	add	a4,a4,a5
 750:	fae68ae3          	beq	a3,a4,704 <free+0x24>
    p->s.ptr = bp->s.ptr;
 754:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 756:	00001717          	auipc	a4,0x1
 75a:	8af73523          	sd	a5,-1878(a4) # 1000 <freep>
}
 75e:	60a2                	ld	ra,8(sp)
 760:	6402                	ld	s0,0(sp)
 762:	0141                	addi	sp,sp,16
 764:	8082                	ret

0000000000000766 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 766:	7139                	addi	sp,sp,-64
 768:	fc06                	sd	ra,56(sp)
 76a:	f822                	sd	s0,48(sp)
 76c:	f04a                	sd	s2,32(sp)
 76e:	ec4e                	sd	s3,24(sp)
 770:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 772:	02051993          	slli	s3,a0,0x20
 776:	0209d993          	srli	s3,s3,0x20
 77a:	09bd                	addi	s3,s3,15
 77c:	0049d993          	srli	s3,s3,0x4
 780:	2985                	addiw	s3,s3,1
 782:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 784:	00001517          	auipc	a0,0x1
 788:	87c53503          	ld	a0,-1924(a0) # 1000 <freep>
 78c:	c905                	beqz	a0,7bc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 790:	4798                	lw	a4,8(a5)
 792:	09377a63          	bgeu	a4,s3,826 <malloc+0xc0>
 796:	f426                	sd	s1,40(sp)
 798:	e852                	sd	s4,16(sp)
 79a:	e456                	sd	s5,8(sp)
 79c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 79e:	8a4e                	mv	s4,s3
 7a0:	6705                	lui	a4,0x1
 7a2:	00e9f363          	bgeu	s3,a4,7a8 <malloc+0x42>
 7a6:	6a05                	lui	s4,0x1
 7a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b0:	00001497          	auipc	s1,0x1
 7b4:	85048493          	addi	s1,s1,-1968 # 1000 <freep>
  if(p == (char*)-1)
 7b8:	5afd                	li	s5,-1
 7ba:	a089                	j	7fc <malloc+0x96>
 7bc:	f426                	sd	s1,40(sp)
 7be:	e852                	sd	s4,16(sp)
 7c0:	e456                	sd	s5,8(sp)
 7c2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7c4:	00001797          	auipc	a5,0x1
 7c8:	84c78793          	addi	a5,a5,-1972 # 1010 <base>
 7cc:	00001717          	auipc	a4,0x1
 7d0:	82f73a23          	sd	a5,-1996(a4) # 1000 <freep>
 7d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7da:	b7d1                	j	79e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7dc:	6398                	ld	a4,0(a5)
 7de:	e118                	sd	a4,0(a0)
 7e0:	a8b9                	j	83e <malloc+0xd8>
  hp->s.size = nu;
 7e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e6:	0541                	addi	a0,a0,16
 7e8:	00000097          	auipc	ra,0x0
 7ec:	ef8080e7          	jalr	-264(ra) # 6e0 <free>
  return freep;
 7f0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7f2:	c135                	beqz	a0,856 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	03277363          	bgeu	a4,s2,81e <malloc+0xb8>
    if(p == freep)
 7fc:	6098                	ld	a4,0(s1)
 7fe:	853e                	mv	a0,a5
 800:	fef71ae3          	bne	a4,a5,7f4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 804:	8552                	mv	a0,s4
 806:	00000097          	auipc	ra,0x0
 80a:	bb6080e7          	jalr	-1098(ra) # 3bc <sbrk>
  if(p == (char*)-1)
 80e:	fd551ae3          	bne	a0,s5,7e2 <malloc+0x7c>
        return 0;
 812:	4501                	li	a0,0
 814:	74a2                	ld	s1,40(sp)
 816:	6a42                	ld	s4,16(sp)
 818:	6aa2                	ld	s5,8(sp)
 81a:	6b02                	ld	s6,0(sp)
 81c:	a03d                	j	84a <malloc+0xe4>
 81e:	74a2                	ld	s1,40(sp)
 820:	6a42                	ld	s4,16(sp)
 822:	6aa2                	ld	s5,8(sp)
 824:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 826:	fae90be3          	beq	s2,a4,7dc <malloc+0x76>
        p->s.size -= nunits;
 82a:	4137073b          	subw	a4,a4,s3
 82e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 830:	02071693          	slli	a3,a4,0x20
 834:	01c6d713          	srli	a4,a3,0x1c
 838:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 83a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 83e:	00000717          	auipc	a4,0x0
 842:	7ca73123          	sd	a0,1986(a4) # 1000 <freep>
      return (void*)(p + 1);
 846:	01078513          	addi	a0,a5,16
  }
}
 84a:	70e2                	ld	ra,56(sp)
 84c:	7442                	ld	s0,48(sp)
 84e:	7902                	ld	s2,32(sp)
 850:	69e2                	ld	s3,24(sp)
 852:	6121                	addi	sp,sp,64
 854:	8082                	ret
 856:	74a2                	ld	s1,40(sp)
 858:	6a42                	ld	s4,16(sp)
 85a:	6aa2                	ld	s5,8(sp)
 85c:	6b02                	ld	s6,0(sp)
 85e:	b7f5                	j	84a <malloc+0xe4>
