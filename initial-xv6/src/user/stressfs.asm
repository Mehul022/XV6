
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dc010113          	addi	sp,sp,-576
   4:	22113c23          	sd	ra,568(sp)
   8:	22813823          	sd	s0,560(sp)
   c:	22913423          	sd	s1,552(sp)
  10:	23213023          	sd	s2,544(sp)
  14:	21313c23          	sd	s3,536(sp)
  18:	21413823          	sd	s4,528(sp)
  1c:	0480                	addi	s0,sp,576
  int fd, i;
  char path[] = "stressfs0";
  1e:	00001797          	auipc	a5,0x1
  22:	92278793          	addi	a5,a5,-1758 # 940 <malloc+0x138>
  26:	6398                	ld	a4,0(a5)
  28:	fce43023          	sd	a4,-64(s0)
  2c:	0087d783          	lhu	a5,8(a5)
  30:	fcf41423          	sh	a5,-56(s0)
  char data[512];

  printf("stressfs starting\n");
  34:	00001517          	auipc	a0,0x1
  38:	8dc50513          	addi	a0,a0,-1828 # 910 <malloc+0x108>
  3c:	00000097          	auipc	ra,0x0
  40:	710080e7          	jalr	1808(ra) # 74c <printf>
  memset(data, 'a', sizeof(data));
  44:	20000613          	li	a2,512
  48:	06100593          	li	a1,97
  4c:	dc040513          	addi	a0,s0,-576
  50:	00000097          	auipc	ra,0x0
  54:	164080e7          	jalr	356(ra) # 1b4 <memset>

  for(i = 0; i < 4; i++)
  58:	4481                	li	s1,0
  5a:	4911                	li	s2,4
    if(fork() > 0)
  5c:	00000097          	auipc	ra,0x0
  60:	372080e7          	jalr	882(ra) # 3ce <fork>
  64:	00a04563          	bgtz	a0,6e <main+0x6e>
  for(i = 0; i < 4; i++)
  68:	2485                	addiw	s1,s1,1
  6a:	ff2499e3          	bne	s1,s2,5c <main+0x5c>
      break;

  printf("write %d\n", i);
  6e:	85a6                	mv	a1,s1
  70:	00001517          	auipc	a0,0x1
  74:	8b850513          	addi	a0,a0,-1864 # 928 <malloc+0x120>
  78:	00000097          	auipc	ra,0x0
  7c:	6d4080e7          	jalr	1748(ra) # 74c <printf>

  path[8] += i;
  80:	fc844783          	lbu	a5,-56(s0)
  84:	9fa5                	addw	a5,a5,s1
  86:	fcf40423          	sb	a5,-56(s0)
  fd = open(path, O_CREATE | O_RDWR);
  8a:	20200593          	li	a1,514
  8e:	fc040513          	addi	a0,s0,-64
  92:	00000097          	auipc	ra,0x0
  96:	384080e7          	jalr	900(ra) # 416 <open>
  9a:	892a                	mv	s2,a0
  9c:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  9e:	dc040a13          	addi	s4,s0,-576
  a2:	20000993          	li	s3,512
  a6:	864e                	mv	a2,s3
  a8:	85d2                	mv	a1,s4
  aa:	854a                	mv	a0,s2
  ac:	00000097          	auipc	ra,0x0
  b0:	34a080e7          	jalr	842(ra) # 3f6 <write>
  for(i = 0; i < 20; i++)
  b4:	34fd                	addiw	s1,s1,-1
  b6:	f8e5                	bnez	s1,a6 <main+0xa6>
  close(fd);
  b8:	854a                	mv	a0,s2
  ba:	00000097          	auipc	ra,0x0
  be:	344080e7          	jalr	836(ra) # 3fe <close>

  printf("read\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	87650513          	addi	a0,a0,-1930 # 938 <malloc+0x130>
  ca:	00000097          	auipc	ra,0x0
  ce:	682080e7          	jalr	1666(ra) # 74c <printf>

  fd = open(path, O_RDONLY);
  d2:	4581                	li	a1,0
  d4:	fc040513          	addi	a0,s0,-64
  d8:	00000097          	auipc	ra,0x0
  dc:	33e080e7          	jalr	830(ra) # 416 <open>
  e0:	892a                	mv	s2,a0
  e2:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  e4:	dc040a13          	addi	s4,s0,-576
  e8:	20000993          	li	s3,512
  ec:	864e                	mv	a2,s3
  ee:	85d2                	mv	a1,s4
  f0:	854a                	mv	a0,s2
  f2:	00000097          	auipc	ra,0x0
  f6:	2fc080e7          	jalr	764(ra) # 3ee <read>
  for (i = 0; i < 20; i++)
  fa:	34fd                	addiw	s1,s1,-1
  fc:	f8e5                	bnez	s1,ec <main+0xec>
  close(fd);
  fe:	854a                	mv	a0,s2
 100:	00000097          	auipc	ra,0x0
 104:	2fe080e7          	jalr	766(ra) # 3fe <close>

  wait(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	2d4080e7          	jalr	724(ra) # 3de <wait>

  exit(0);
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	2c2080e7          	jalr	706(ra) # 3d6 <exit>

000000000000011c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  extern int main();
  main();
 124:	00000097          	auipc	ra,0x0
 128:	edc080e7          	jalr	-292(ra) # 0 <main>
  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2a8080e7          	jalr	680(ra) # 3d6 <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0xa>
    ;
  return os;
}
 14e:	60a2                	ld	ra,8(sp)
 150:	6402                	ld	s0,0(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cb91                	beqz	a5,176 <strcmp+0x20>
 164:	0005c703          	lbu	a4,0(a1)
 168:	00f71763          	bne	a4,a5,176 <strcmp+0x20>
    p++, q++;
 16c:	0505                	addi	a0,a0,1
 16e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	fbe5                	bnez	a5,164 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 176:	0005c503          	lbu	a0,0(a1)
}
 17a:	40a7853b          	subw	a0,a5,a0
 17e:	60a2                	ld	ra,8(sp)
 180:	6402                	ld	s0,0(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strlen>:

uint
strlen(const char *s)
{
 186:	1141                	addi	sp,sp,-16
 188:	e406                	sd	ra,8(sp)
 18a:	e022                	sd	s0,0(sp)
 18c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cf99                	beqz	a5,1b0 <strlen+0x2a>
 194:	0505                	addi	a0,a0,1
 196:	87aa                	mv	a5,a0
 198:	86be                	mv	a3,a5
 19a:	0785                	addi	a5,a5,1
 19c:	fff7c703          	lbu	a4,-1(a5)
 1a0:	ff65                	bnez	a4,198 <strlen+0x12>
 1a2:	40a6853b          	subw	a0,a3,a0
 1a6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1a8:	60a2                	ld	ra,8(sp)
 1aa:	6402                	ld	s0,0(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  for(n = 0; s[n]; n++)
 1b0:	4501                	li	a0,0
 1b2:	bfdd                	j	1a8 <strlen+0x22>

00000000000001b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e406                	sd	ra,8(sp)
 1b8:	e022                	sd	s0,0(sp)
 1ba:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1bc:	ca19                	beqz	a2,1d2 <memset+0x1e>
 1be:	87aa                	mv	a5,a0
 1c0:	1602                	slli	a2,a2,0x20
 1c2:	9201                	srli	a2,a2,0x20
 1c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1cc:	0785                	addi	a5,a5,1
 1ce:	fee79de3          	bne	a5,a4,1c8 <memset+0x14>
  }
  return dst;
}
 1d2:	60a2                	ld	ra,8(sp)
 1d4:	6402                	ld	s0,0(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret

00000000000001da <strchr>:

char*
strchr(const char *s, char c)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cf81                	beqz	a5,1fe <strchr+0x24>
    if(*s == c)
 1e8:	00f58763          	beq	a1,a5,1f6 <strchr+0x1c>
  for(; *s; s++)
 1ec:	0505                	addi	a0,a0,1
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbfd                	bnez	a5,1e8 <strchr+0xe>
      return (char*)s;
  return 0;
 1f4:	4501                	li	a0,0
}
 1f6:	60a2                	ld	ra,8(sp)
 1f8:	6402                	ld	s0,0(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  return 0;
 1fe:	4501                	li	a0,0
 200:	bfdd                	j	1f6 <strchr+0x1c>

0000000000000202 <gets>:

char*
gets(char *buf, int max)
{
 202:	7159                	addi	sp,sp,-112
 204:	f486                	sd	ra,104(sp)
 206:	f0a2                	sd	s0,96(sp)
 208:	eca6                	sd	s1,88(sp)
 20a:	e8ca                	sd	s2,80(sp)
 20c:	e4ce                	sd	s3,72(sp)
 20e:	e0d2                	sd	s4,64(sp)
 210:	fc56                	sd	s5,56(sp)
 212:	f85a                	sd	s6,48(sp)
 214:	f45e                	sd	s7,40(sp)
 216:	f062                	sd	s8,32(sp)
 218:	ec66                	sd	s9,24(sp)
 21a:	e86a                	sd	s10,16(sp)
 21c:	1880                	addi	s0,sp,112
 21e:	8caa                	mv	s9,a0
 220:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	892a                	mv	s2,a0
 224:	4481                	li	s1,0
    cc = read(0, &c, 1);
 226:	f9f40b13          	addi	s6,s0,-97
 22a:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22c:	4ba9                	li	s7,10
 22e:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 230:	8d26                	mv	s10,s1
 232:	0014899b          	addiw	s3,s1,1
 236:	84ce                	mv	s1,s3
 238:	0349d763          	bge	s3,s4,266 <gets+0x64>
    cc = read(0, &c, 1);
 23c:	8656                	mv	a2,s5
 23e:	85da                	mv	a1,s6
 240:	4501                	li	a0,0
 242:	00000097          	auipc	ra,0x0
 246:	1ac080e7          	jalr	428(ra) # 3ee <read>
    if(cc < 1)
 24a:	00a05e63          	blez	a0,266 <gets+0x64>
    buf[i++] = c;
 24e:	f9f44783          	lbu	a5,-97(s0)
 252:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 256:	01778763          	beq	a5,s7,264 <gets+0x62>
 25a:	0905                	addi	s2,s2,1
 25c:	fd879ae3          	bne	a5,s8,230 <gets+0x2e>
    buf[i++] = c;
 260:	8d4e                	mv	s10,s3
 262:	a011                	j	266 <gets+0x64>
 264:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 266:	9d66                	add	s10,s10,s9
 268:	000d0023          	sb	zero,0(s10)
  return buf;
}
 26c:	8566                	mv	a0,s9
 26e:	70a6                	ld	ra,104(sp)
 270:	7406                	ld	s0,96(sp)
 272:	64e6                	ld	s1,88(sp)
 274:	6946                	ld	s2,80(sp)
 276:	69a6                	ld	s3,72(sp)
 278:	6a06                	ld	s4,64(sp)
 27a:	7ae2                	ld	s5,56(sp)
 27c:	7b42                	ld	s6,48(sp)
 27e:	7ba2                	ld	s7,40(sp)
 280:	7c02                	ld	s8,32(sp)
 282:	6ce2                	ld	s9,24(sp)
 284:	6d42                	ld	s10,16(sp)
 286:	6165                	addi	sp,sp,112
 288:	8082                	ret

000000000000028a <stat>:

int
stat(const char *n, struct stat *st)
{
 28a:	1101                	addi	sp,sp,-32
 28c:	ec06                	sd	ra,24(sp)
 28e:	e822                	sd	s0,16(sp)
 290:	e04a                	sd	s2,0(sp)
 292:	1000                	addi	s0,sp,32
 294:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 296:	4581                	li	a1,0
 298:	00000097          	auipc	ra,0x0
 29c:	17e080e7          	jalr	382(ra) # 416 <open>
  if(fd < 0)
 2a0:	02054663          	bltz	a0,2cc <stat+0x42>
 2a4:	e426                	sd	s1,8(sp)
 2a6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a8:	85ca                	mv	a1,s2
 2aa:	00000097          	auipc	ra,0x0
 2ae:	184080e7          	jalr	388(ra) # 42e <fstat>
 2b2:	892a                	mv	s2,a0
  close(fd);
 2b4:	8526                	mv	a0,s1
 2b6:	00000097          	auipc	ra,0x0
 2ba:	148080e7          	jalr	328(ra) # 3fe <close>
  return r;
 2be:	64a2                	ld	s1,8(sp)
}
 2c0:	854a                	mv	a0,s2
 2c2:	60e2                	ld	ra,24(sp)
 2c4:	6442                	ld	s0,16(sp)
 2c6:	6902                	ld	s2,0(sp)
 2c8:	6105                	addi	sp,sp,32
 2ca:	8082                	ret
    return -1;
 2cc:	597d                	li	s2,-1
 2ce:	bfcd                	j	2c0 <stat+0x36>

00000000000002d0 <atoi>:

int
atoi(const char *s)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d8:	00054683          	lbu	a3,0(a0)
 2dc:	fd06879b          	addiw	a5,a3,-48
 2e0:	0ff7f793          	zext.b	a5,a5
 2e4:	4625                	li	a2,9
 2e6:	02f66963          	bltu	a2,a5,318 <atoi+0x48>
 2ea:	872a                	mv	a4,a0
  n = 0;
 2ec:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ee:	0705                	addi	a4,a4,1
 2f0:	0025179b          	slliw	a5,a0,0x2
 2f4:	9fa9                	addw	a5,a5,a0
 2f6:	0017979b          	slliw	a5,a5,0x1
 2fa:	9fb5                	addw	a5,a5,a3
 2fc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 300:	00074683          	lbu	a3,0(a4)
 304:	fd06879b          	addiw	a5,a3,-48
 308:	0ff7f793          	zext.b	a5,a5
 30c:	fef671e3          	bgeu	a2,a5,2ee <atoi+0x1e>
  return n;
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
  n = 0;
 318:	4501                	li	a0,0
 31a:	bfdd                	j	310 <atoi+0x40>

000000000000031c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 324:	02b57563          	bgeu	a0,a1,34e <memmove+0x32>
    while(n-- > 0)
 328:	00c05f63          	blez	a2,346 <memmove+0x2a>
 32c:	1602                	slli	a2,a2,0x20
 32e:	9201                	srli	a2,a2,0x20
 330:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 334:	872a                	mv	a4,a0
      *dst++ = *src++;
 336:	0585                	addi	a1,a1,1
 338:	0705                	addi	a4,a4,1
 33a:	fff5c683          	lbu	a3,-1(a1)
 33e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 342:	fee79ae3          	bne	a5,a4,336 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 346:	60a2                	ld	ra,8(sp)
 348:	6402                	ld	s0,0(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret
    dst += n;
 34e:	00c50733          	add	a4,a0,a2
    src += n;
 352:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 354:	fec059e3          	blez	a2,346 <memmove+0x2a>
 358:	fff6079b          	addiw	a5,a2,-1
 35c:	1782                	slli	a5,a5,0x20
 35e:	9381                	srli	a5,a5,0x20
 360:	fff7c793          	not	a5,a5
 364:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 366:	15fd                	addi	a1,a1,-1
 368:	177d                	addi	a4,a4,-1
 36a:	0005c683          	lbu	a3,0(a1)
 36e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 372:	fef71ae3          	bne	a4,a5,366 <memmove+0x4a>
 376:	bfc1                	j	346 <memmove+0x2a>

0000000000000378 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e406                	sd	ra,8(sp)
 37c:	e022                	sd	s0,0(sp)
 37e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 380:	ca0d                	beqz	a2,3b2 <memcmp+0x3a>
 382:	fff6069b          	addiw	a3,a2,-1
 386:	1682                	slli	a3,a3,0x20
 388:	9281                	srli	a3,a3,0x20
 38a:	0685                	addi	a3,a3,1
 38c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38e:	00054783          	lbu	a5,0(a0)
 392:	0005c703          	lbu	a4,0(a1)
 396:	00e79863          	bne	a5,a4,3a6 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 39a:	0505                	addi	a0,a0,1
    p2++;
 39c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39e:	fed518e3          	bne	a0,a3,38e <memcmp+0x16>
  }
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	a019                	j	3aa <memcmp+0x32>
      return *p1 - *p2;
 3a6:	40e7853b          	subw	a0,a5,a4
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret
  return 0;
 3b2:	4501                	li	a0,0
 3b4:	bfdd                	j	3aa <memcmp+0x32>

00000000000003b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3be:	00000097          	auipc	ra,0x0
 3c2:	f5e080e7          	jalr	-162(ra) # 31c <memmove>
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret

00000000000003ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ce:	4885                	li	a7,1
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d6:	4889                	li	a7,2
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <wait>:
.global wait
wait:
 li a7, SYS_wait
 3de:	488d                	li	a7,3
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e6:	4891                	li	a7,4
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <read>:
.global read
read:
 li a7, SYS_read
 3ee:	4895                	li	a7,5
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <write>:
.global write
write:
 li a7, SYS_write
 3f6:	48c1                	li	a7,16
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <close>:
.global close
close:
 li a7, SYS_close
 3fe:	48d5                	li	a7,21
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <kill>:
.global kill
kill:
 li a7, SYS_kill
 406:	4899                	li	a7,6
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exec>:
.global exec
exec:
 li a7, SYS_exec
 40e:	489d                	li	a7,7
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <open>:
.global open
open:
 li a7, SYS_open
 416:	48bd                	li	a7,15
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41e:	48c5                	li	a7,17
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 426:	48c9                	li	a7,18
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42e:	48a1                	li	a7,8
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <link>:
.global link
link:
 li a7, SYS_link
 436:	48cd                	li	a7,19
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43e:	48d1                	li	a7,20
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 446:	48a5                	li	a7,9
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <dup>:
.global dup
dup:
 li a7, SYS_dup
 44e:	48a9                	li	a7,10
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 456:	48ad                	li	a7,11
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 45e:	48b1                	li	a7,12
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 466:	48b5                	li	a7,13
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46e:	48b9                	li	a7,14
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 476:	48d9                	li	a7,22
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 47e:	48dd                	li	a7,23
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 486:	48e1                	li	a7,24
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 48e:	48e5                	li	a7,25
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 496:	1101                	addi	sp,sp,-32
 498:	ec06                	sd	ra,24(sp)
 49a:	e822                	sd	s0,16(sp)
 49c:	1000                	addi	s0,sp,32
 49e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a2:	4605                	li	a2,1
 4a4:	fef40593          	addi	a1,s0,-17
 4a8:	00000097          	auipc	ra,0x0
 4ac:	f4e080e7          	jalr	-178(ra) # 3f6 <write>
}
 4b0:	60e2                	ld	ra,24(sp)
 4b2:	6442                	ld	s0,16(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret

00000000000004b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b8:	7139                	addi	sp,sp,-64
 4ba:	fc06                	sd	ra,56(sp)
 4bc:	f822                	sd	s0,48(sp)
 4be:	f426                	sd	s1,40(sp)
 4c0:	f04a                	sd	s2,32(sp)
 4c2:	ec4e                	sd	s3,24(sp)
 4c4:	0080                	addi	s0,sp,64
 4c6:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c8:	c299                	beqz	a3,4ce <printint+0x16>
 4ca:	0805c063          	bltz	a1,54a <printint+0x92>
  neg = 0;
 4ce:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4d0:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4d4:	869a                	mv	a3,t1
  i = 0;
 4d6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4d8:	00000817          	auipc	a6,0x0
 4dc:	4d880813          	addi	a6,a6,1240 # 9b0 <digits>
 4e0:	88be                	mv	a7,a5
 4e2:	0017851b          	addiw	a0,a5,1
 4e6:	87aa                	mv	a5,a0
 4e8:	02c5f73b          	remuw	a4,a1,a2
 4ec:	1702                	slli	a4,a4,0x20
 4ee:	9301                	srli	a4,a4,0x20
 4f0:	9742                	add	a4,a4,a6
 4f2:	00074703          	lbu	a4,0(a4)
 4f6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4fa:	872e                	mv	a4,a1
 4fc:	02c5d5bb          	divuw	a1,a1,a2
 500:	0685                	addi	a3,a3,1
 502:	fcc77fe3          	bgeu	a4,a2,4e0 <printint+0x28>
  if(neg)
 506:	000e0c63          	beqz	t3,51e <printint+0x66>
    buf[i++] = '-';
 50a:	fd050793          	addi	a5,a0,-48
 50e:	00878533          	add	a0,a5,s0
 512:	02d00793          	li	a5,45
 516:	fef50823          	sb	a5,-16(a0)
 51a:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 51e:	fff7899b          	addiw	s3,a5,-1
 522:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 526:	fff4c583          	lbu	a1,-1(s1)
 52a:	854a                	mv	a0,s2
 52c:	00000097          	auipc	ra,0x0
 530:	f6a080e7          	jalr	-150(ra) # 496 <putc>
  while(--i >= 0)
 534:	39fd                	addiw	s3,s3,-1
 536:	14fd                	addi	s1,s1,-1
 538:	fe09d7e3          	bgez	s3,526 <printint+0x6e>
}
 53c:	70e2                	ld	ra,56(sp)
 53e:	7442                	ld	s0,48(sp)
 540:	74a2                	ld	s1,40(sp)
 542:	7902                	ld	s2,32(sp)
 544:	69e2                	ld	s3,24(sp)
 546:	6121                	addi	sp,sp,64
 548:	8082                	ret
    x = -xx;
 54a:	40b005bb          	negw	a1,a1
    neg = 1;
 54e:	4e05                	li	t3,1
    x = -xx;
 550:	b741                	j	4d0 <printint+0x18>

0000000000000552 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 552:	715d                	addi	sp,sp,-80
 554:	e486                	sd	ra,72(sp)
 556:	e0a2                	sd	s0,64(sp)
 558:	f84a                	sd	s2,48(sp)
 55a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55c:	0005c903          	lbu	s2,0(a1)
 560:	1a090a63          	beqz	s2,714 <vprintf+0x1c2>
 564:	fc26                	sd	s1,56(sp)
 566:	f44e                	sd	s3,40(sp)
 568:	f052                	sd	s4,32(sp)
 56a:	ec56                	sd	s5,24(sp)
 56c:	e85a                	sd	s6,16(sp)
 56e:	e45e                	sd	s7,8(sp)
 570:	8aaa                	mv	s5,a0
 572:	8bb2                	mv	s7,a2
 574:	00158493          	addi	s1,a1,1
  state = 0;
 578:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 57a:	02500a13          	li	s4,37
 57e:	4b55                	li	s6,21
 580:	a839                	j	59e <vprintf+0x4c>
        putc(fd, c);
 582:	85ca                	mv	a1,s2
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	f10080e7          	jalr	-240(ra) # 496 <putc>
 58e:	a019                	j	594 <vprintf+0x42>
    } else if(state == '%'){
 590:	01498d63          	beq	s3,s4,5aa <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 594:	0485                	addi	s1,s1,1
 596:	fff4c903          	lbu	s2,-1(s1)
 59a:	16090763          	beqz	s2,708 <vprintf+0x1b6>
    if(state == 0){
 59e:	fe0999e3          	bnez	s3,590 <vprintf+0x3e>
      if(c == '%'){
 5a2:	ff4910e3          	bne	s2,s4,582 <vprintf+0x30>
        state = '%';
 5a6:	89d2                	mv	s3,s4
 5a8:	b7f5                	j	594 <vprintf+0x42>
      if(c == 'd'){
 5aa:	13490463          	beq	s2,s4,6d2 <vprintf+0x180>
 5ae:	f9d9079b          	addiw	a5,s2,-99
 5b2:	0ff7f793          	zext.b	a5,a5
 5b6:	12fb6763          	bltu	s6,a5,6e4 <vprintf+0x192>
 5ba:	f9d9079b          	addiw	a5,s2,-99
 5be:	0ff7f713          	zext.b	a4,a5
 5c2:	12eb6163          	bltu	s6,a4,6e4 <vprintf+0x192>
 5c6:	00271793          	slli	a5,a4,0x2
 5ca:	00000717          	auipc	a4,0x0
 5ce:	38e70713          	addi	a4,a4,910 # 958 <malloc+0x150>
 5d2:	97ba                	add	a5,a5,a4
 5d4:	439c                	lw	a5,0(a5)
 5d6:	97ba                	add	a5,a5,a4
 5d8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ed0080e7          	jalr	-304(ra) # 4b8 <printint>
 5f0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b745                	j	594 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4629                	li	a2,10
 5fe:	000ba583          	lw	a1,0(s7)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	eb4080e7          	jalr	-332(ra) # 4b8 <printint>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b751                	j	594 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 612:	008b8913          	addi	s2,s7,8
 616:	4681                	li	a3,0
 618:	4641                	li	a2,16
 61a:	000ba583          	lw	a1,0(s7)
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e98080e7          	jalr	-360(ra) # 4b8 <printint>
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b7a5                	j	594 <vprintf+0x42>
 62e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 630:	008b8c13          	addi	s8,s7,8
 634:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 638:	03000593          	li	a1,48
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	e58080e7          	jalr	-424(ra) # 496 <putc>
  putc(fd, 'x');
 646:	07800593          	li	a1,120
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e4a080e7          	jalr	-438(ra) # 496 <putc>
 654:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 656:	00000b97          	auipc	s7,0x0
 65a:	35ab8b93          	addi	s7,s7,858 # 9b0 <digits>
 65e:	03c9d793          	srli	a5,s3,0x3c
 662:	97de                	add	a5,a5,s7
 664:	0007c583          	lbu	a1,0(a5)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e2c080e7          	jalr	-468(ra) # 496 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 672:	0992                	slli	s3,s3,0x4
 674:	397d                	addiw	s2,s2,-1
 676:	fe0914e3          	bnez	s2,65e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 67a:	8be2                	mv	s7,s8
      state = 0;
 67c:	4981                	li	s3,0
 67e:	6c02                	ld	s8,0(sp)
 680:	bf11                	j	594 <vprintf+0x42>
        s = va_arg(ap, char*);
 682:	008b8993          	addi	s3,s7,8
 686:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 68a:	02090163          	beqz	s2,6ac <vprintf+0x15a>
        while(*s != 0){
 68e:	00094583          	lbu	a1,0(s2)
 692:	c9a5                	beqz	a1,702 <vprintf+0x1b0>
          putc(fd, *s);
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e00080e7          	jalr	-512(ra) # 496 <putc>
          s++;
 69e:	0905                	addi	s2,s2,1
        while(*s != 0){
 6a0:	00094583          	lbu	a1,0(s2)
 6a4:	f9e5                	bnez	a1,694 <vprintf+0x142>
        s = va_arg(ap, char*);
 6a6:	8bce                	mv	s7,s3
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b5ed                	j	594 <vprintf+0x42>
          s = "(null)";
 6ac:	00000917          	auipc	s2,0x0
 6b0:	2a490913          	addi	s2,s2,676 # 950 <malloc+0x148>
        while(*s != 0){
 6b4:	02800593          	li	a1,40
 6b8:	bff1                	j	694 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6ba:	008b8913          	addi	s2,s7,8
 6be:	000bc583          	lbu	a1,0(s7)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	dd2080e7          	jalr	-558(ra) # 496 <putc>
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b5d1                	j	594 <vprintf+0x42>
        putc(fd, c);
 6d2:	02500593          	li	a1,37
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	dbe080e7          	jalr	-578(ra) # 496 <putc>
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd4d                	j	594 <vprintf+0x42>
        putc(fd, '%');
 6e4:	02500593          	li	a1,37
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	dac080e7          	jalr	-596(ra) # 496 <putc>
        putc(fd, c);
 6f2:	85ca                	mv	a1,s2
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	da0080e7          	jalr	-608(ra) # 496 <putc>
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd51                	j	594 <vprintf+0x42>
        s = va_arg(ap, char*);
 702:	8bce                	mv	s7,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b579                	j	594 <vprintf+0x42>
 708:	74e2                	ld	s1,56(sp)
 70a:	79a2                	ld	s3,40(sp)
 70c:	7a02                	ld	s4,32(sp)
 70e:	6ae2                	ld	s5,24(sp)
 710:	6b42                	ld	s6,16(sp)
 712:	6ba2                	ld	s7,8(sp)
    }
  }
}
 714:	60a6                	ld	ra,72(sp)
 716:	6406                	ld	s0,64(sp)
 718:	7942                	ld	s2,48(sp)
 71a:	6161                	addi	sp,sp,80
 71c:	8082                	ret

000000000000071e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71e:	715d                	addi	sp,sp,-80
 720:	ec06                	sd	ra,24(sp)
 722:	e822                	sd	s0,16(sp)
 724:	1000                	addi	s0,sp,32
 726:	e010                	sd	a2,0(s0)
 728:	e414                	sd	a3,8(s0)
 72a:	e818                	sd	a4,16(s0)
 72c:	ec1c                	sd	a5,24(s0)
 72e:	03043023          	sd	a6,32(s0)
 732:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 736:	8622                	mv	a2,s0
 738:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73c:	00000097          	auipc	ra,0x0
 740:	e16080e7          	jalr	-490(ra) # 552 <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6161                	addi	sp,sp,80
 74a:	8082                	ret

000000000000074c <printf>:

void
printf(const char *fmt, ...)
{
 74c:	711d                	addi	sp,sp,-96
 74e:	ec06                	sd	ra,24(sp)
 750:	e822                	sd	s0,16(sp)
 752:	1000                	addi	s0,sp,32
 754:	e40c                	sd	a1,8(s0)
 756:	e810                	sd	a2,16(s0)
 758:	ec14                	sd	a3,24(s0)
 75a:	f018                	sd	a4,32(s0)
 75c:	f41c                	sd	a5,40(s0)
 75e:	03043823          	sd	a6,48(s0)
 762:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	00840613          	addi	a2,s0,8
 76a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76e:	85aa                	mv	a1,a0
 770:	4505                	li	a0,1
 772:	00000097          	auipc	ra,0x0
 776:	de0080e7          	jalr	-544(ra) # 552 <vprintf>
}
 77a:	60e2                	ld	ra,24(sp)
 77c:	6442                	ld	s0,16(sp)
 77e:	6125                	addi	sp,sp,96
 780:	8082                	ret

0000000000000782 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 782:	1141                	addi	sp,sp,-16
 784:	e406                	sd	ra,8(sp)
 786:	e022                	sd	s0,0(sp)
 788:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78e:	00001797          	auipc	a5,0x1
 792:	8727b783          	ld	a5,-1934(a5) # 1000 <freep>
 796:	a02d                	j	7c0 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 798:	4618                	lw	a4,8(a2)
 79a:	9f2d                	addw	a4,a4,a1
 79c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a0:	6398                	ld	a4,0(a5)
 7a2:	6310                	ld	a2,0(a4)
 7a4:	a83d                	j	7e2 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a6:	ff852703          	lw	a4,-8(a0)
 7aa:	9f31                	addw	a4,a4,a2
 7ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ae:	ff053683          	ld	a3,-16(a0)
 7b2:	a091                	j	7f6 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b4:	6398                	ld	a4,0(a5)
 7b6:	00e7e463          	bltu	a5,a4,7be <free+0x3c>
 7ba:	00e6ea63          	bltu	a3,a4,7ce <free+0x4c>
{
 7be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	fed7fae3          	bgeu	a5,a3,7b4 <free+0x32>
 7c4:	6398                	ld	a4,0(a5)
 7c6:	00e6e463          	bltu	a3,a4,7ce <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	fee7eae3          	bltu	a5,a4,7be <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7ce:	ff852583          	lw	a1,-8(a0)
 7d2:	6390                	ld	a2,0(a5)
 7d4:	02059813          	slli	a6,a1,0x20
 7d8:	01c85713          	srli	a4,a6,0x1c
 7dc:	9736                	add	a4,a4,a3
 7de:	fae60de3          	beq	a2,a4,798 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e6:	4790                	lw	a2,8(a5)
 7e8:	02061593          	slli	a1,a2,0x20
 7ec:	01c5d713          	srli	a4,a1,0x1c
 7f0:	973e                	add	a4,a4,a5
 7f2:	fae68ae3          	beq	a3,a4,7a6 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f8:	00001717          	auipc	a4,0x1
 7fc:	80f73423          	sd	a5,-2040(a4) # 1000 <freep>
}
 800:	60a2                	ld	ra,8(sp)
 802:	6402                	ld	s0,0(sp)
 804:	0141                	addi	sp,sp,16
 806:	8082                	ret

0000000000000808 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 808:	7139                	addi	sp,sp,-64
 80a:	fc06                	sd	ra,56(sp)
 80c:	f822                	sd	s0,48(sp)
 80e:	f04a                	sd	s2,32(sp)
 810:	ec4e                	sd	s3,24(sp)
 812:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 814:	02051993          	slli	s3,a0,0x20
 818:	0209d993          	srli	s3,s3,0x20
 81c:	09bd                	addi	s3,s3,15
 81e:	0049d993          	srli	s3,s3,0x4
 822:	2985                	addiw	s3,s3,1
 824:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 826:	00000517          	auipc	a0,0x0
 82a:	7da53503          	ld	a0,2010(a0) # 1000 <freep>
 82e:	c905                	beqz	a0,85e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 830:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 832:	4798                	lw	a4,8(a5)
 834:	09377a63          	bgeu	a4,s3,8c8 <malloc+0xc0>
 838:	f426                	sd	s1,40(sp)
 83a:	e852                	sd	s4,16(sp)
 83c:	e456                	sd	s5,8(sp)
 83e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 840:	8a4e                	mv	s4,s3
 842:	6705                	lui	a4,0x1
 844:	00e9f363          	bgeu	s3,a4,84a <malloc+0x42>
 848:	6a05                	lui	s4,0x1
 84a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 852:	00000497          	auipc	s1,0x0
 856:	7ae48493          	addi	s1,s1,1966 # 1000 <freep>
  if(p == (char*)-1)
 85a:	5afd                	li	s5,-1
 85c:	a089                	j	89e <malloc+0x96>
 85e:	f426                	sd	s1,40(sp)
 860:	e852                	sd	s4,16(sp)
 862:	e456                	sd	s5,8(sp)
 864:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 866:	00000797          	auipc	a5,0x0
 86a:	7aa78793          	addi	a5,a5,1962 # 1010 <base>
 86e:	00000717          	auipc	a4,0x0
 872:	78f73923          	sd	a5,1938(a4) # 1000 <freep>
 876:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 878:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87c:	b7d1                	j	840 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 87e:	6398                	ld	a4,0(a5)
 880:	e118                	sd	a4,0(a0)
 882:	a8b9                	j	8e0 <malloc+0xd8>
  hp->s.size = nu;
 884:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 888:	0541                	addi	a0,a0,16
 88a:	00000097          	auipc	ra,0x0
 88e:	ef8080e7          	jalr	-264(ra) # 782 <free>
  return freep;
 892:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 894:	c135                	beqz	a0,8f8 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 896:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 898:	4798                	lw	a4,8(a5)
 89a:	03277363          	bgeu	a4,s2,8c0 <malloc+0xb8>
    if(p == freep)
 89e:	6098                	ld	a4,0(s1)
 8a0:	853e                	mv	a0,a5
 8a2:	fef71ae3          	bne	a4,a5,896 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8a6:	8552                	mv	a0,s4
 8a8:	00000097          	auipc	ra,0x0
 8ac:	bb6080e7          	jalr	-1098(ra) # 45e <sbrk>
  if(p == (char*)-1)
 8b0:	fd551ae3          	bne	a0,s5,884 <malloc+0x7c>
        return 0;
 8b4:	4501                	li	a0,0
 8b6:	74a2                	ld	s1,40(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
 8be:	a03d                	j	8ec <malloc+0xe4>
 8c0:	74a2                	ld	s1,40(sp)
 8c2:	6a42                	ld	s4,16(sp)
 8c4:	6aa2                	ld	s5,8(sp)
 8c6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8c8:	fae90be3          	beq	s2,a4,87e <malloc+0x76>
        p->s.size -= nunits;
 8cc:	4137073b          	subw	a4,a4,s3
 8d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d2:	02071693          	slli	a3,a4,0x20
 8d6:	01c6d713          	srli	a4,a3,0x1c
 8da:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8dc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e0:	00000717          	auipc	a4,0x0
 8e4:	72a73023          	sd	a0,1824(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e8:	01078513          	addi	a0,a5,16
  }
}
 8ec:	70e2                	ld	ra,56(sp)
 8ee:	7442                	ld	s0,48(sp)
 8f0:	7902                	ld	s2,32(sp)
 8f2:	69e2                	ld	s3,24(sp)
 8f4:	6121                	addi	sp,sp,64
 8f6:	8082                	ret
 8f8:	74a2                	ld	s1,40(sp)
 8fa:	6a42                	ld	s4,16(sp)
 8fc:	6aa2                	ld	s5,8(sp)
 8fe:	6b02                	ld	s6,0(sp)
 900:	b7f5                	j	8ec <malloc+0xe4>
