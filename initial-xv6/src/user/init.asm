
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	8d250513          	addi	a0,a0,-1838 # 8e0 <malloc+0xfc>
  16:	00000097          	auipc	ra,0x0
  1a:	3dc080e7          	jalr	988(ra) # 3f2 <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	406080e7          	jalr	1030(ra) # 42a <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3fc080e7          	jalr	1020(ra) # 42a <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	8b290913          	addi	s2,s2,-1870 # 8e8 <malloc+0x104>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6e8080e7          	jalr	1768(ra) # 728 <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	362080e7          	jalr	866(ra) # 3aa <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	360080e7          	jalr	864(ra) # 3ba <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	8ce50513          	addi	a0,a0,-1842 # 938 <malloc+0x154>
  72:	00000097          	auipc	ra,0x0
  76:	6b6080e7          	jalr	1718(ra) # 728 <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	336080e7          	jalr	822(ra) # 3b2 <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	85850513          	addi	a0,a0,-1960 # 8e0 <malloc+0xfc>
  90:	00000097          	auipc	ra,0x0
  94:	36a080e7          	jalr	874(ra) # 3fa <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	84650513          	addi	a0,a0,-1978 # 8e0 <malloc+0xfc>
  a2:	00000097          	auipc	ra,0x0
  a6:	350080e7          	jalr	848(ra) # 3f2 <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	85450513          	addi	a0,a0,-1964 # 900 <malloc+0x11c>
  b4:	00000097          	auipc	ra,0x0
  b8:	674080e7          	jalr	1652(ra) # 728 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2f4080e7          	jalr	756(ra) # 3b2 <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	addi	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	84a50513          	addi	a0,a0,-1974 # 918 <malloc+0x134>
  d6:	00000097          	auipc	ra,0x0
  da:	314080e7          	jalr	788(ra) # 3ea <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	84250513          	addi	a0,a0,-1982 # 920 <malloc+0x13c>
  e6:	00000097          	auipc	ra,0x0
  ea:	642080e7          	jalr	1602(ra) # 728 <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	2c2080e7          	jalr	706(ra) # 3b2 <exit>

00000000000000f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	2a8080e7          	jalr	680(ra) # 3b2 <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e406                	sd	ra,8(sp)
 116:	e022                	sd	s0,0(sp)
 118:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11a:	87aa                	mv	a5,a0
 11c:	0585                	addi	a1,a1,1
 11e:	0785                	addi	a5,a5,1
 120:	fff5c703          	lbu	a4,-1(a1)
 124:	fee78fa3          	sb	a4,-1(a5)
 128:	fb75                	bnez	a4,11c <strcpy+0xa>
    ;
  return os;
}
 12a:	60a2                	ld	ra,8(sp)
 12c:	6402                	ld	s0,0(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x20>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x20>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	60a2                	ld	ra,8(sp)
 15c:	6402                	ld	s0,0(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strlen>:

uint
strlen(const char *s)
{
 162:	1141                	addi	sp,sp,-16
 164:	e406                	sd	ra,8(sp)
 166:	e022                	sd	s0,0(sp)
 168:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cf99                	beqz	a5,18c <strlen+0x2a>
 170:	0505                	addi	a0,a0,1
 172:	87aa                	mv	a5,a0
 174:	86be                	mv	a3,a5
 176:	0785                	addi	a5,a5,1
 178:	fff7c703          	lbu	a4,-1(a5)
 17c:	ff65                	bnez	a4,174 <strlen+0x12>
 17e:	40a6853b          	subw	a0,a3,a0
 182:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  for(n = 0; s[n]; n++)
 18c:	4501                	li	a0,0
 18e:	bfdd                	j	184 <strlen+0x22>

0000000000000190 <memset>:

void*
memset(void *dst, int c, uint n)
{
 190:	1141                	addi	sp,sp,-16
 192:	e406                	sd	ra,8(sp)
 194:	e022                	sd	s0,0(sp)
 196:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 198:	ca19                	beqz	a2,1ae <memset+0x1e>
 19a:	87aa                	mv	a5,a0
 19c:	1602                	slli	a2,a2,0x20
 19e:	9201                	srli	a2,a2,0x20
 1a0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a8:	0785                	addi	a5,a5,1
 1aa:	fee79de3          	bne	a5,a4,1a4 <memset+0x14>
  }
  return dst;
}
 1ae:	60a2                	ld	ra,8(sp)
 1b0:	6402                	ld	s0,0(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strchr>:

char*
strchr(const char *s, char c)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e406                	sd	ra,8(sp)
 1ba:	e022                	sd	s0,0(sp)
 1bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cf81                	beqz	a5,1da <strchr+0x24>
    if(*s == c)
 1c4:	00f58763          	beq	a1,a5,1d2 <strchr+0x1c>
  for(; *s; s++)
 1c8:	0505                	addi	a0,a0,1
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbfd                	bnez	a5,1c4 <strchr+0xe>
      return (char*)s;
  return 0;
 1d0:	4501                	li	a0,0
}
 1d2:	60a2                	ld	ra,8(sp)
 1d4:	6402                	ld	s0,0(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfdd                	j	1d2 <strchr+0x1c>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	7159                	addi	sp,sp,-112
 1e0:	f486                	sd	ra,104(sp)
 1e2:	f0a2                	sd	s0,96(sp)
 1e4:	eca6                	sd	s1,88(sp)
 1e6:	e8ca                	sd	s2,80(sp)
 1e8:	e4ce                	sd	s3,72(sp)
 1ea:	e0d2                	sd	s4,64(sp)
 1ec:	fc56                	sd	s5,56(sp)
 1ee:	f85a                	sd	s6,48(sp)
 1f0:	f45e                	sd	s7,40(sp)
 1f2:	f062                	sd	s8,32(sp)
 1f4:	ec66                	sd	s9,24(sp)
 1f6:	e86a                	sd	s10,16(sp)
 1f8:	1880                	addi	s0,sp,112
 1fa:	8caa                	mv	s9,a0
 1fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	892a                	mv	s2,a0
 200:	4481                	li	s1,0
    cc = read(0, &c, 1);
 202:	f9f40b13          	addi	s6,s0,-97
 206:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 208:	4ba9                	li	s7,10
 20a:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 20c:	8d26                	mv	s10,s1
 20e:	0014899b          	addiw	s3,s1,1
 212:	84ce                	mv	s1,s3
 214:	0349d763          	bge	s3,s4,242 <gets+0x64>
    cc = read(0, &c, 1);
 218:	8656                	mv	a2,s5
 21a:	85da                	mv	a1,s6
 21c:	4501                	li	a0,0
 21e:	00000097          	auipc	ra,0x0
 222:	1ac080e7          	jalr	428(ra) # 3ca <read>
    if(cc < 1)
 226:	00a05e63          	blez	a0,242 <gets+0x64>
    buf[i++] = c;
 22a:	f9f44783          	lbu	a5,-97(s0)
 22e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 232:	01778763          	beq	a5,s7,240 <gets+0x62>
 236:	0905                	addi	s2,s2,1
 238:	fd879ae3          	bne	a5,s8,20c <gets+0x2e>
    buf[i++] = c;
 23c:	8d4e                	mv	s10,s3
 23e:	a011                	j	242 <gets+0x64>
 240:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 242:	9d66                	add	s10,s10,s9
 244:	000d0023          	sb	zero,0(s10)
  return buf;
}
 248:	8566                	mv	a0,s9
 24a:	70a6                	ld	ra,104(sp)
 24c:	7406                	ld	s0,96(sp)
 24e:	64e6                	ld	s1,88(sp)
 250:	6946                	ld	s2,80(sp)
 252:	69a6                	ld	s3,72(sp)
 254:	6a06                	ld	s4,64(sp)
 256:	7ae2                	ld	s5,56(sp)
 258:	7b42                	ld	s6,48(sp)
 25a:	7ba2                	ld	s7,40(sp)
 25c:	7c02                	ld	s8,32(sp)
 25e:	6ce2                	ld	s9,24(sp)
 260:	6d42                	ld	s10,16(sp)
 262:	6165                	addi	sp,sp,112
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	addi	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	00000097          	auipc	ra,0x0
 278:	17e080e7          	jalr	382(ra) # 3f2 <open>
  if(fd < 0)
 27c:	02054663          	bltz	a0,2a8 <stat+0x42>
 280:	e426                	sd	s1,8(sp)
 282:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 284:	85ca                	mv	a1,s2
 286:	00000097          	auipc	ra,0x0
 28a:	184080e7          	jalr	388(ra) # 40a <fstat>
 28e:	892a                	mv	s2,a0
  close(fd);
 290:	8526                	mv	a0,s1
 292:	00000097          	auipc	ra,0x0
 296:	148080e7          	jalr	328(ra) # 3da <close>
  return r;
 29a:	64a2                	ld	s1,8(sp)
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	6902                	ld	s2,0(sp)
 2a4:	6105                	addi	sp,sp,32
 2a6:	8082                	ret
    return -1;
 2a8:	597d                	li	s2,-1
 2aa:	bfcd                	j	29c <stat+0x36>

00000000000002ac <atoi>:

int
atoi(const char *s)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b4:	00054683          	lbu	a3,0(a0)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	zext.b	a5,a5
 2c0:	4625                	li	a2,9
 2c2:	02f66963          	bltu	a2,a5,2f4 <atoi+0x48>
 2c6:	872a                	mv	a4,a0
  n = 0;
 2c8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ca:	0705                	addi	a4,a4,1
 2cc:	0025179b          	slliw	a5,a0,0x2
 2d0:	9fa9                	addw	a5,a5,a0
 2d2:	0017979b          	slliw	a5,a5,0x1
 2d6:	9fb5                	addw	a5,a5,a3
 2d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2dc:	00074683          	lbu	a3,0(a4)
 2e0:	fd06879b          	addiw	a5,a3,-48
 2e4:	0ff7f793          	zext.b	a5,a5
 2e8:	fef671e3          	bgeu	a2,a5,2ca <atoi+0x1e>
  return n;
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  n = 0;
 2f4:	4501                	li	a0,0
 2f6:	bfdd                	j	2ec <atoi+0x40>

00000000000002f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 300:	02b57563          	bgeu	a0,a1,32a <memmove+0x32>
    while(n-- > 0)
 304:	00c05f63          	blez	a2,322 <memmove+0x2a>
 308:	1602                	slli	a2,a2,0x20
 30a:	9201                	srli	a2,a2,0x20
 30c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 310:	872a                	mv	a4,a0
      *dst++ = *src++;
 312:	0585                	addi	a1,a1,1
 314:	0705                	addi	a4,a4,1
 316:	fff5c683          	lbu	a3,-1(a1)
 31a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31e:	fee79ae3          	bne	a5,a4,312 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
    dst += n;
 32a:	00c50733          	add	a4,a0,a2
    src += n;
 32e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 330:	fec059e3          	blez	a2,322 <memmove+0x2a>
 334:	fff6079b          	addiw	a5,a2,-1
 338:	1782                	slli	a5,a5,0x20
 33a:	9381                	srli	a5,a5,0x20
 33c:	fff7c793          	not	a5,a5
 340:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 342:	15fd                	addi	a1,a1,-1
 344:	177d                	addi	a4,a4,-1
 346:	0005c683          	lbu	a3,0(a1)
 34a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34e:	fef71ae3          	bne	a4,a5,342 <memmove+0x4a>
 352:	bfc1                	j	322 <memmove+0x2a>

0000000000000354 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 35c:	ca0d                	beqz	a2,38e <memcmp+0x3a>
 35e:	fff6069b          	addiw	a3,a2,-1
 362:	1682                	slli	a3,a3,0x20
 364:	9281                	srli	a3,a3,0x20
 366:	0685                	addi	a3,a3,1
 368:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 36a:	00054783          	lbu	a5,0(a0)
 36e:	0005c703          	lbu	a4,0(a1)
 372:	00e79863          	bne	a5,a4,382 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 376:	0505                	addi	a0,a0,1
    p2++;
 378:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 37a:	fed518e3          	bne	a0,a3,36a <memcmp+0x16>
  }
  return 0;
 37e:	4501                	li	a0,0
 380:	a019                	j	386 <memcmp+0x32>
      return *p1 - *p2;
 382:	40e7853b          	subw	a0,a5,a4
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  return 0;
 38e:	4501                	li	a0,0
 390:	bfdd                	j	386 <memcmp+0x32>

0000000000000392 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e406                	sd	ra,8(sp)
 396:	e022                	sd	s0,0(sp)
 398:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 39a:	00000097          	auipc	ra,0x0
 39e:	f5e080e7          	jalr	-162(ra) # 2f8 <memmove>
}
 3a2:	60a2                	ld	ra,8(sp)
 3a4:	6402                	ld	s0,0(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret

00000000000003aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3aa:	4885                	li	a7,1
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b2:	4889                	li	a7,2
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ba:	488d                	li	a7,3
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c2:	4891                	li	a7,4
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <read>:
.global read
read:
 li a7, SYS_read
 3ca:	4895                	li	a7,5
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <write>:
.global write
write:
 li a7, SYS_write
 3d2:	48c1                	li	a7,16
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <close>:
.global close
close:
 li a7, SYS_close
 3da:	48d5                	li	a7,21
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e2:	4899                	li	a7,6
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ea:	489d                	li	a7,7
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <open>:
.global open
open:
 li a7, SYS_open
 3f2:	48bd                	li	a7,15
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3fa:	48c5                	li	a7,17
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 402:	48c9                	li	a7,18
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 40a:	48a1                	li	a7,8
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <link>:
.global link
link:
 li a7, SYS_link
 412:	48cd                	li	a7,19
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 41a:	48d1                	li	a7,20
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 422:	48a5                	li	a7,9
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <dup>:
.global dup
dup:
 li a7, SYS_dup
 42a:	48a9                	li	a7,10
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 432:	48ad                	li	a7,11
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 43a:	48b1                	li	a7,12
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 442:	48b5                	li	a7,13
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 44a:	48b9                	li	a7,14
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 452:	48d9                	li	a7,22
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 45a:	48dd                	li	a7,23
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 462:	48e1                	li	a7,24
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 46a:	48e5                	li	a7,25
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 472:	1101                	addi	sp,sp,-32
 474:	ec06                	sd	ra,24(sp)
 476:	e822                	sd	s0,16(sp)
 478:	1000                	addi	s0,sp,32
 47a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47e:	4605                	li	a2,1
 480:	fef40593          	addi	a1,s0,-17
 484:	00000097          	auipc	ra,0x0
 488:	f4e080e7          	jalr	-178(ra) # 3d2 <write>
}
 48c:	60e2                	ld	ra,24(sp)
 48e:	6442                	ld	s0,16(sp)
 490:	6105                	addi	sp,sp,32
 492:	8082                	ret

0000000000000494 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 494:	7139                	addi	sp,sp,-64
 496:	fc06                	sd	ra,56(sp)
 498:	f822                	sd	s0,48(sp)
 49a:	f426                	sd	s1,40(sp)
 49c:	f04a                	sd	s2,32(sp)
 49e:	ec4e                	sd	s3,24(sp)
 4a0:	0080                	addi	s0,sp,64
 4a2:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a4:	c299                	beqz	a3,4aa <printint+0x16>
 4a6:	0805c063          	bltz	a1,526 <printint+0x92>
  neg = 0;
 4aa:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ac:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4b0:	869a                	mv	a3,t1
  i = 0;
 4b2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b4:	00000817          	auipc	a6,0x0
 4b8:	50480813          	addi	a6,a6,1284 # 9b8 <digits>
 4bc:	88be                	mv	a7,a5
 4be:	0017851b          	addiw	a0,a5,1
 4c2:	87aa                	mv	a5,a0
 4c4:	02c5f73b          	remuw	a4,a1,a2
 4c8:	1702                	slli	a4,a4,0x20
 4ca:	9301                	srli	a4,a4,0x20
 4cc:	9742                	add	a4,a4,a6
 4ce:	00074703          	lbu	a4,0(a4)
 4d2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4d6:	872e                	mv	a4,a1
 4d8:	02c5d5bb          	divuw	a1,a1,a2
 4dc:	0685                	addi	a3,a3,1
 4de:	fcc77fe3          	bgeu	a4,a2,4bc <printint+0x28>
  if(neg)
 4e2:	000e0c63          	beqz	t3,4fa <printint+0x66>
    buf[i++] = '-';
 4e6:	fd050793          	addi	a5,a0,-48
 4ea:	00878533          	add	a0,a5,s0
 4ee:	02d00793          	li	a5,45
 4f2:	fef50823          	sb	a5,-16(a0)
 4f6:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4fa:	fff7899b          	addiw	s3,a5,-1
 4fe:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 502:	fff4c583          	lbu	a1,-1(s1)
 506:	854a                	mv	a0,s2
 508:	00000097          	auipc	ra,0x0
 50c:	f6a080e7          	jalr	-150(ra) # 472 <putc>
  while(--i >= 0)
 510:	39fd                	addiw	s3,s3,-1
 512:	14fd                	addi	s1,s1,-1
 514:	fe09d7e3          	bgez	s3,502 <printint+0x6e>
}
 518:	70e2                	ld	ra,56(sp)
 51a:	7442                	ld	s0,48(sp)
 51c:	74a2                	ld	s1,40(sp)
 51e:	7902                	ld	s2,32(sp)
 520:	69e2                	ld	s3,24(sp)
 522:	6121                	addi	sp,sp,64
 524:	8082                	ret
    x = -xx;
 526:	40b005bb          	negw	a1,a1
    neg = 1;
 52a:	4e05                	li	t3,1
    x = -xx;
 52c:	b741                	j	4ac <printint+0x18>

000000000000052e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52e:	715d                	addi	sp,sp,-80
 530:	e486                	sd	ra,72(sp)
 532:	e0a2                	sd	s0,64(sp)
 534:	f84a                	sd	s2,48(sp)
 536:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 538:	0005c903          	lbu	s2,0(a1)
 53c:	1a090a63          	beqz	s2,6f0 <vprintf+0x1c2>
 540:	fc26                	sd	s1,56(sp)
 542:	f44e                	sd	s3,40(sp)
 544:	f052                	sd	s4,32(sp)
 546:	ec56                	sd	s5,24(sp)
 548:	e85a                	sd	s6,16(sp)
 54a:	e45e                	sd	s7,8(sp)
 54c:	8aaa                	mv	s5,a0
 54e:	8bb2                	mv	s7,a2
 550:	00158493          	addi	s1,a1,1
  state = 0;
 554:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 556:	02500a13          	li	s4,37
 55a:	4b55                	li	s6,21
 55c:	a839                	j	57a <vprintf+0x4c>
        putc(fd, c);
 55e:	85ca                	mv	a1,s2
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	f10080e7          	jalr	-240(ra) # 472 <putc>
 56a:	a019                	j	570 <vprintf+0x42>
    } else if(state == '%'){
 56c:	01498d63          	beq	s3,s4,586 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 570:	0485                	addi	s1,s1,1
 572:	fff4c903          	lbu	s2,-1(s1)
 576:	16090763          	beqz	s2,6e4 <vprintf+0x1b6>
    if(state == 0){
 57a:	fe0999e3          	bnez	s3,56c <vprintf+0x3e>
      if(c == '%'){
 57e:	ff4910e3          	bne	s2,s4,55e <vprintf+0x30>
        state = '%';
 582:	89d2                	mv	s3,s4
 584:	b7f5                	j	570 <vprintf+0x42>
      if(c == 'd'){
 586:	13490463          	beq	s2,s4,6ae <vprintf+0x180>
 58a:	f9d9079b          	addiw	a5,s2,-99
 58e:	0ff7f793          	zext.b	a5,a5
 592:	12fb6763          	bltu	s6,a5,6c0 <vprintf+0x192>
 596:	f9d9079b          	addiw	a5,s2,-99
 59a:	0ff7f713          	zext.b	a4,a5
 59e:	12eb6163          	bltu	s6,a4,6c0 <vprintf+0x192>
 5a2:	00271793          	slli	a5,a4,0x2
 5a6:	00000717          	auipc	a4,0x0
 5aa:	3ba70713          	addi	a4,a4,954 # 960 <malloc+0x17c>
 5ae:	97ba                	add	a5,a5,a4
 5b0:	439c                	lw	a5,0(a5)
 5b2:	97ba                	add	a5,a5,a4
 5b4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4685                	li	a3,1
 5bc:	4629                	li	a2,10
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	ed0080e7          	jalr	-304(ra) # 494 <printint>
 5cc:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b745                	j	570 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4629                	li	a2,10
 5da:	000ba583          	lw	a1,0(s7)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	eb4080e7          	jalr	-332(ra) # 494 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b751                	j	570 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000ba583          	lw	a1,0(s7)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e98080e7          	jalr	-360(ra) # 494 <printint>
 604:	8bca                	mv	s7,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	b7a5                	j	570 <vprintf+0x42>
 60a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 60c:	008b8c13          	addi	s8,s7,8
 610:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 614:	03000593          	li	a1,48
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e58080e7          	jalr	-424(ra) # 472 <putc>
  putc(fd, 'x');
 622:	07800593          	li	a1,120
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e4a080e7          	jalr	-438(ra) # 472 <putc>
 630:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 632:	00000b97          	auipc	s7,0x0
 636:	386b8b93          	addi	s7,s7,902 # 9b8 <digits>
 63a:	03c9d793          	srli	a5,s3,0x3c
 63e:	97de                	add	a5,a5,s7
 640:	0007c583          	lbu	a1,0(a5)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e2c080e7          	jalr	-468(ra) # 472 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 64e:	0992                	slli	s3,s3,0x4
 650:	397d                	addiw	s2,s2,-1
 652:	fe0914e3          	bnez	s2,63a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 656:	8be2                	mv	s7,s8
      state = 0;
 658:	4981                	li	s3,0
 65a:	6c02                	ld	s8,0(sp)
 65c:	bf11                	j	570 <vprintf+0x42>
        s = va_arg(ap, char*);
 65e:	008b8993          	addi	s3,s7,8
 662:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 666:	02090163          	beqz	s2,688 <vprintf+0x15a>
        while(*s != 0){
 66a:	00094583          	lbu	a1,0(s2)
 66e:	c9a5                	beqz	a1,6de <vprintf+0x1b0>
          putc(fd, *s);
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e00080e7          	jalr	-512(ra) # 472 <putc>
          s++;
 67a:	0905                	addi	s2,s2,1
        while(*s != 0){
 67c:	00094583          	lbu	a1,0(s2)
 680:	f9e5                	bnez	a1,670 <vprintf+0x142>
        s = va_arg(ap, char*);
 682:	8bce                	mv	s7,s3
      state = 0;
 684:	4981                	li	s3,0
 686:	b5ed                	j	570 <vprintf+0x42>
          s = "(null)";
 688:	00000917          	auipc	s2,0x0
 68c:	2d090913          	addi	s2,s2,720 # 958 <malloc+0x174>
        while(*s != 0){
 690:	02800593          	li	a1,40
 694:	bff1                	j	670 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 696:	008b8913          	addi	s2,s7,8
 69a:	000bc583          	lbu	a1,0(s7)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dd2080e7          	jalr	-558(ra) # 472 <putc>
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b5d1                	j	570 <vprintf+0x42>
        putc(fd, c);
 6ae:	02500593          	li	a1,37
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	dbe080e7          	jalr	-578(ra) # 472 <putc>
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bd4d                	j	570 <vprintf+0x42>
        putc(fd, '%');
 6c0:	02500593          	li	a1,37
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	dac080e7          	jalr	-596(ra) # 472 <putc>
        putc(fd, c);
 6ce:	85ca                	mv	a1,s2
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	da0080e7          	jalr	-608(ra) # 472 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd51                	j	570 <vprintf+0x42>
        s = va_arg(ap, char*);
 6de:	8bce                	mv	s7,s3
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b579                	j	570 <vprintf+0x42>
 6e4:	74e2                	ld	s1,56(sp)
 6e6:	79a2                	ld	s3,40(sp)
 6e8:	7a02                	ld	s4,32(sp)
 6ea:	6ae2                	ld	s5,24(sp)
 6ec:	6b42                	ld	s6,16(sp)
 6ee:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6f0:	60a6                	ld	ra,72(sp)
 6f2:	6406                	ld	s0,64(sp)
 6f4:	7942                	ld	s2,48(sp)
 6f6:	6161                	addi	sp,sp,80
 6f8:	8082                	ret

00000000000006fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6fa:	715d                	addi	sp,sp,-80
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	1000                	addi	s0,sp,32
 702:	e010                	sd	a2,0(s0)
 704:	e414                	sd	a3,8(s0)
 706:	e818                	sd	a4,16(s0)
 708:	ec1c                	sd	a5,24(s0)
 70a:	03043023          	sd	a6,32(s0)
 70e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 712:	8622                	mv	a2,s0
 714:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 718:	00000097          	auipc	ra,0x0
 71c:	e16080e7          	jalr	-490(ra) # 52e <vprintf>
}
 720:	60e2                	ld	ra,24(sp)
 722:	6442                	ld	s0,16(sp)
 724:	6161                	addi	sp,sp,80
 726:	8082                	ret

0000000000000728 <printf>:

void
printf(const char *fmt, ...)
{
 728:	711d                	addi	sp,sp,-96
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	e40c                	sd	a1,8(s0)
 732:	e810                	sd	a2,16(s0)
 734:	ec14                	sd	a3,24(s0)
 736:	f018                	sd	a4,32(s0)
 738:	f41c                	sd	a5,40(s0)
 73a:	03043823          	sd	a6,48(s0)
 73e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	00840613          	addi	a2,s0,8
 746:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 74a:	85aa                	mv	a1,a0
 74c:	4505                	li	a0,1
 74e:	00000097          	auipc	ra,0x0
 752:	de0080e7          	jalr	-544(ra) # 52e <vprintf>
}
 756:	60e2                	ld	ra,24(sp)
 758:	6442                	ld	s0,16(sp)
 75a:	6125                	addi	sp,sp,96
 75c:	8082                	ret

000000000000075e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75e:	1141                	addi	sp,sp,-16
 760:	e406                	sd	ra,8(sp)
 762:	e022                	sd	s0,0(sp)
 764:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	00001797          	auipc	a5,0x1
 76e:	8a67b783          	ld	a5,-1882(a5) # 1010 <freep>
 772:	a02d                	j	79c <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 774:	4618                	lw	a4,8(a2)
 776:	9f2d                	addw	a4,a4,a1
 778:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77c:	6398                	ld	a4,0(a5)
 77e:	6310                	ld	a2,0(a4)
 780:	a83d                	j	7be <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 782:	ff852703          	lw	a4,-8(a0)
 786:	9f31                	addw	a4,a4,a2
 788:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 78a:	ff053683          	ld	a3,-16(a0)
 78e:	a091                	j	7d2 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x3c>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x4c>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x32>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059813          	slli	a6,a1,0x20
 7b4:	01c85713          	srli	a4,a6,0x1c
 7b8:	9736                	add	a4,a4,a3
 7ba:	fae60de3          	beq	a2,a4,774 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061593          	slli	a1,a2,0x20
 7c8:	01c5d713          	srli	a4,a1,0x1c
 7cc:	973e                	add	a4,a4,a5
 7ce:	fae68ae3          	beq	a3,a4,782 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73e23          	sd	a5,-1988(a4) # 1010 <freep>
}
 7dc:	60a2                	ld	ra,8(sp)
 7de:	6402                	ld	s0,0(sp)
 7e0:	0141                	addi	sp,sp,16
 7e2:	8082                	ret

00000000000007e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e4:	7139                	addi	sp,sp,-64
 7e6:	fc06                	sd	ra,56(sp)
 7e8:	f822                	sd	s0,48(sp)
 7ea:	f04a                	sd	s2,32(sp)
 7ec:	ec4e                	sd	s3,24(sp)
 7ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f0:	02051993          	slli	s3,a0,0x20
 7f4:	0209d993          	srli	s3,s3,0x20
 7f8:	09bd                	addi	s3,s3,15
 7fa:	0049d993          	srli	s3,s3,0x4
 7fe:	2985                	addiw	s3,s3,1
 800:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 802:	00001517          	auipc	a0,0x1
 806:	80e53503          	ld	a0,-2034(a0) # 1010 <freep>
 80a:	c905                	beqz	a0,83a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80e:	4798                	lw	a4,8(a5)
 810:	09377a63          	bgeu	a4,s3,8a4 <malloc+0xc0>
 814:	f426                	sd	s1,40(sp)
 816:	e852                	sd	s4,16(sp)
 818:	e456                	sd	s5,8(sp)
 81a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 81c:	8a4e                	mv	s4,s3
 81e:	6705                	lui	a4,0x1
 820:	00e9f363          	bgeu	s3,a4,826 <malloc+0x42>
 824:	6a05                	lui	s4,0x1
 826:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82e:	00000497          	auipc	s1,0x0
 832:	7e248493          	addi	s1,s1,2018 # 1010 <freep>
  if(p == (char*)-1)
 836:	5afd                	li	s5,-1
 838:	a089                	j	87a <malloc+0x96>
 83a:	f426                	sd	s1,40(sp)
 83c:	e852                	sd	s4,16(sp)
 83e:	e456                	sd	s5,8(sp)
 840:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 842:	00000797          	auipc	a5,0x0
 846:	7de78793          	addi	a5,a5,2014 # 1020 <base>
 84a:	00000717          	auipc	a4,0x0
 84e:	7cf73323          	sd	a5,1990(a4) # 1010 <freep>
 852:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 854:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 858:	b7d1                	j	81c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	e118                	sd	a4,0(a0)
 85e:	a8b9                	j	8bc <malloc+0xd8>
  hp->s.size = nu;
 860:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 864:	0541                	addi	a0,a0,16
 866:	00000097          	auipc	ra,0x0
 86a:	ef8080e7          	jalr	-264(ra) # 75e <free>
  return freep;
 86e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 870:	c135                	beqz	a0,8d4 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	03277363          	bgeu	a4,s2,89c <malloc+0xb8>
    if(p == freep)
 87a:	6098                	ld	a4,0(s1)
 87c:	853e                	mv	a0,a5
 87e:	fef71ae3          	bne	a4,a5,872 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 882:	8552                	mv	a0,s4
 884:	00000097          	auipc	ra,0x0
 888:	bb6080e7          	jalr	-1098(ra) # 43a <sbrk>
  if(p == (char*)-1)
 88c:	fd551ae3          	bne	a0,s5,860 <malloc+0x7c>
        return 0;
 890:	4501                	li	a0,0
 892:	74a2                	ld	s1,40(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	a03d                	j	8c8 <malloc+0xe4>
 89c:	74a2                	ld	s1,40(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a4:	fae90be3          	beq	s2,a4,85a <malloc+0x76>
        p->s.size -= nunits;
 8a8:	4137073b          	subw	a4,a4,s3
 8ac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ae:	02071693          	slli	a3,a4,0x20
 8b2:	01c6d713          	srli	a4,a3,0x1c
 8b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74a73a23          	sd	a0,1876(a4) # 1010 <freep>
      return (void*)(p + 1);
 8c4:	01078513          	addi	a0,a5,16
  }
}
 8c8:	70e2                	ld	ra,56(sp)
 8ca:	7442                	ld	s0,48(sp)
 8cc:	7902                	ld	s2,32(sp)
 8ce:	69e2                	ld	s3,24(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
 8d4:	74a2                	ld	s1,40(sp)
 8d6:	6a42                	ld	s4,16(sp)
 8d8:	6aa2                	ld	s5,8(sp)
 8da:	6b02                	ld	s6,0(sp)
 8dc:	b7f5                	j	8c8 <malloc+0xe4>
