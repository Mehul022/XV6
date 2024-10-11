
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	172080e7          	jalr	370(ra) # 17e <strlen>
  14:	862a                	mv	a2,a0
  16:	85a6                	mv	a1,s1
  18:	4505                	li	a0,1
  1a:	00000097          	auipc	ra,0x0
  1e:	3d4080e7          	jalr	980(ra) # 3ee <write>
}
  22:	60e2                	ld	ra,24(sp)
  24:	6442                	ld	s0,16(sp)
  26:	64a2                	ld	s1,8(sp)
  28:	6105                	addi	sp,sp,32
  2a:	8082                	ret

000000000000002c <forktest>:

void
forktest(void)
{
  2c:	1101                	addi	sp,sp,-32
  2e:	ec06                	sd	ra,24(sp)
  30:	e822                	sd	s0,16(sp)
  32:	e426                	sd	s1,8(sp)
  34:	e04a                	sd	s2,0(sp)
  36:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  38:	00000517          	auipc	a0,0x0
  3c:	45850513          	addi	a0,a0,1112 # 490 <sigreturn+0xa>
  40:	00000097          	auipc	ra,0x0
  44:	fc0080e7          	jalr	-64(ra) # 0 <print>

  for(n=0; n<N; n++){
  48:	4481                	li	s1,0
  4a:	3e800913          	li	s2,1000
    pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	378080e7          	jalr	888(ra) # 3c6 <fork>
    if(pid < 0)
  56:	06054163          	bltz	a0,b8 <forktest+0x8c>
      break;
    if(pid == 0)
  5a:	c10d                	beqz	a0,7c <forktest+0x50>
  for(n=0; n<N; n++){
  5c:	2485                	addiw	s1,s1,1
  5e:	ff2498e3          	bne	s1,s2,4e <forktest+0x22>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  62:	00000517          	auipc	a0,0x0
  66:	47e50513          	addi	a0,a0,1150 # 4e0 <sigreturn+0x5a>
  6a:	00000097          	auipc	ra,0x0
  6e:	f96080e7          	jalr	-106(ra) # 0 <print>
    exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	35a080e7          	jalr	858(ra) # 3ce <exit>
      exit(0);
  7c:	00000097          	auipc	ra,0x0
  80:	352080e7          	jalr	850(ra) # 3ce <exit>
  }

  for(; n > 0; n--){
    if(wait(0) < 0){
      print("wait stopped early\n");
  84:	00000517          	auipc	a0,0x0
  88:	41c50513          	addi	a0,a0,1052 # 4a0 <sigreturn+0x1a>
  8c:	00000097          	auipc	ra,0x0
  90:	f74080e7          	jalr	-140(ra) # 0 <print>
      exit(1);
  94:	4505                	li	a0,1
  96:	00000097          	auipc	ra,0x0
  9a:	338080e7          	jalr	824(ra) # 3ce <exit>
    }
  }

  if(wait(0) != -1){
    print("wait got too many\n");
  9e:	00000517          	auipc	a0,0x0
  a2:	41a50513          	addi	a0,a0,1050 # 4b8 <sigreturn+0x32>
  a6:	00000097          	auipc	ra,0x0
  aa:	f5a080e7          	jalr	-166(ra) # 0 <print>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	31e080e7          	jalr	798(ra) # 3ce <exit>
  for(; n > 0; n--){
  b8:	00905b63          	blez	s1,ce <forktest+0xa2>
    if(wait(0) < 0){
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	318080e7          	jalr	792(ra) # 3d6 <wait>
  c6:	fa054fe3          	bltz	a0,84 <forktest+0x58>
  for(; n > 0; n--){
  ca:	34fd                	addiw	s1,s1,-1
  cc:	f8e5                	bnez	s1,bc <forktest+0x90>
  if(wait(0) != -1){
  ce:	4501                	li	a0,0
  d0:	00000097          	auipc	ra,0x0
  d4:	306080e7          	jalr	774(ra) # 3d6 <wait>
  d8:	57fd                	li	a5,-1
  da:	fcf512e3          	bne	a0,a5,9e <forktest+0x72>
  }

  print("fork test OK\n");
  de:	00000517          	auipc	a0,0x0
  e2:	3f250513          	addi	a0,a0,1010 # 4d0 <sigreturn+0x4a>
  e6:	00000097          	auipc	ra,0x0
  ea:	f1a080e7          	jalr	-230(ra) # 0 <print>
}
  ee:	60e2                	ld	ra,24(sp)
  f0:	6442                	ld	s0,16(sp)
  f2:	64a2                	ld	s1,8(sp)
  f4:	6902                	ld	s2,0(sp)
  f6:	6105                	addi	sp,sp,32
  f8:	8082                	ret

00000000000000fa <main>:

int
main(void)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  forktest();
 102:	00000097          	auipc	ra,0x0
 106:	f2a080e7          	jalr	-214(ra) # 2c <forktest>
  exit(0);
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	2c2080e7          	jalr	706(ra) # 3ce <exit>

0000000000000114 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 114:	1141                	addi	sp,sp,-16
 116:	e406                	sd	ra,8(sp)
 118:	e022                	sd	s0,0(sp)
 11a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11c:	00000097          	auipc	ra,0x0
 120:	fde080e7          	jalr	-34(ra) # fa <main>
  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	2a8080e7          	jalr	680(ra) # 3ce <exit>

000000000000012e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 136:	87aa                	mv	a5,a0
 138:	0585                	addi	a1,a1,1
 13a:	0785                	addi	a5,a5,1
 13c:	fff5c703          	lbu	a4,-1(a1)
 140:	fee78fa3          	sb	a4,-1(a5)
 144:	fb75                	bnez	a4,138 <strcpy+0xa>
    ;
  return os;
}
 146:	60a2                	ld	ra,8(sp)
 148:	6402                	ld	s0,0(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb91                	beqz	a5,16e <strcmp+0x20>
 15c:	0005c703          	lbu	a4,0(a1)
 160:	00f71763          	bne	a4,a5,16e <strcmp+0x20>
    p++, q++;
 164:	0505                	addi	a0,a0,1
 166:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbe5                	bnez	a5,15c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 16e:	0005c503          	lbu	a0,0(a1)
}
 172:	40a7853b          	subw	a0,a5,a0
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf99                	beqz	a5,1a8 <strlen+0x2a>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	86be                	mv	a3,a5
 192:	0785                	addi	a5,a5,1
 194:	fff7c703          	lbu	a4,-1(a5)
 198:	ff65                	bnez	a4,190 <strlen+0x12>
 19a:	40a6853b          	subw	a0,a3,a0
 19e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1a0:	60a2                	ld	ra,8(sp)
 1a2:	6402                	ld	s0,0(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret
  for(n = 0; s[n]; n++)
 1a8:	4501                	li	a0,0
 1aa:	bfdd                	j	1a0 <strlen+0x22>

00000000000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e406                	sd	ra,8(sp)
 1b0:	e022                	sd	s0,0(sp)
 1b2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b4:	ca19                	beqz	a2,1ca <memset+0x1e>
 1b6:	87aa                	mv	a5,a0
 1b8:	1602                	slli	a2,a2,0x20
 1ba:	9201                	srli	a2,a2,0x20
 1bc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c4:	0785                	addi	a5,a5,1
 1c6:	fee79de3          	bne	a5,a4,1c0 <memset+0x14>
  }
  return dst;
}
 1ca:	60a2                	ld	ra,8(sp)
 1cc:	6402                	ld	s0,0(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret

00000000000001d2 <strchr>:

char*
strchr(const char *s, char c)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1da:	00054783          	lbu	a5,0(a0)
 1de:	cf81                	beqz	a5,1f6 <strchr+0x24>
    if(*s == c)
 1e0:	00f58763          	beq	a1,a5,1ee <strchr+0x1c>
  for(; *s; s++)
 1e4:	0505                	addi	a0,a0,1
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	fbfd                	bnez	a5,1e0 <strchr+0xe>
      return (char*)s;
  return 0;
 1ec:	4501                	li	a0,0
}
 1ee:	60a2                	ld	ra,8(sp)
 1f0:	6402                	ld	s0,0(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  return 0;
 1f6:	4501                	li	a0,0
 1f8:	bfdd                	j	1ee <strchr+0x1c>

00000000000001fa <gets>:

char*
gets(char *buf, int max)
{
 1fa:	7159                	addi	sp,sp,-112
 1fc:	f486                	sd	ra,104(sp)
 1fe:	f0a2                	sd	s0,96(sp)
 200:	eca6                	sd	s1,88(sp)
 202:	e8ca                	sd	s2,80(sp)
 204:	e4ce                	sd	s3,72(sp)
 206:	e0d2                	sd	s4,64(sp)
 208:	fc56                	sd	s5,56(sp)
 20a:	f85a                	sd	s6,48(sp)
 20c:	f45e                	sd	s7,40(sp)
 20e:	f062                	sd	s8,32(sp)
 210:	ec66                	sd	s9,24(sp)
 212:	e86a                	sd	s10,16(sp)
 214:	1880                	addi	s0,sp,112
 216:	8caa                	mv	s9,a0
 218:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	892a                	mv	s2,a0
 21c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 21e:	f9f40b13          	addi	s6,s0,-97
 222:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 224:	4ba9                	li	s7,10
 226:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 228:	8d26                	mv	s10,s1
 22a:	0014899b          	addiw	s3,s1,1
 22e:	84ce                	mv	s1,s3
 230:	0349d763          	bge	s3,s4,25e <gets+0x64>
    cc = read(0, &c, 1);
 234:	8656                	mv	a2,s5
 236:	85da                	mv	a1,s6
 238:	4501                	li	a0,0
 23a:	00000097          	auipc	ra,0x0
 23e:	1ac080e7          	jalr	428(ra) # 3e6 <read>
    if(cc < 1)
 242:	00a05e63          	blez	a0,25e <gets+0x64>
    buf[i++] = c;
 246:	f9f44783          	lbu	a5,-97(s0)
 24a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24e:	01778763          	beq	a5,s7,25c <gets+0x62>
 252:	0905                	addi	s2,s2,1
 254:	fd879ae3          	bne	a5,s8,228 <gets+0x2e>
    buf[i++] = c;
 258:	8d4e                	mv	s10,s3
 25a:	a011                	j	25e <gets+0x64>
 25c:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 25e:	9d66                	add	s10,s10,s9
 260:	000d0023          	sb	zero,0(s10)
  return buf;
}
 264:	8566                	mv	a0,s9
 266:	70a6                	ld	ra,104(sp)
 268:	7406                	ld	s0,96(sp)
 26a:	64e6                	ld	s1,88(sp)
 26c:	6946                	ld	s2,80(sp)
 26e:	69a6                	ld	s3,72(sp)
 270:	6a06                	ld	s4,64(sp)
 272:	7ae2                	ld	s5,56(sp)
 274:	7b42                	ld	s6,48(sp)
 276:	7ba2                	ld	s7,40(sp)
 278:	7c02                	ld	s8,32(sp)
 27a:	6ce2                	ld	s9,24(sp)
 27c:	6d42                	ld	s10,16(sp)
 27e:	6165                	addi	sp,sp,112
 280:	8082                	ret

0000000000000282 <stat>:

int
stat(const char *n, struct stat *st)
{
 282:	1101                	addi	sp,sp,-32
 284:	ec06                	sd	ra,24(sp)
 286:	e822                	sd	s0,16(sp)
 288:	e04a                	sd	s2,0(sp)
 28a:	1000                	addi	s0,sp,32
 28c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28e:	4581                	li	a1,0
 290:	00000097          	auipc	ra,0x0
 294:	17e080e7          	jalr	382(ra) # 40e <open>
  if(fd < 0)
 298:	02054663          	bltz	a0,2c4 <stat+0x42>
 29c:	e426                	sd	s1,8(sp)
 29e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a0:	85ca                	mv	a1,s2
 2a2:	00000097          	auipc	ra,0x0
 2a6:	184080e7          	jalr	388(ra) # 426 <fstat>
 2aa:	892a                	mv	s2,a0
  close(fd);
 2ac:	8526                	mv	a0,s1
 2ae:	00000097          	auipc	ra,0x0
 2b2:	148080e7          	jalr	328(ra) # 3f6 <close>
  return r;
 2b6:	64a2                	ld	s1,8(sp)
}
 2b8:	854a                	mv	a0,s2
 2ba:	60e2                	ld	ra,24(sp)
 2bc:	6442                	ld	s0,16(sp)
 2be:	6902                	ld	s2,0(sp)
 2c0:	6105                	addi	sp,sp,32
 2c2:	8082                	ret
    return -1;
 2c4:	597d                	li	s2,-1
 2c6:	bfcd                	j	2b8 <stat+0x36>

00000000000002c8 <atoi>:

int
atoi(const char *s)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d0:	00054683          	lbu	a3,0(a0)
 2d4:	fd06879b          	addiw	a5,a3,-48
 2d8:	0ff7f793          	zext.b	a5,a5
 2dc:	4625                	li	a2,9
 2de:	02f66963          	bltu	a2,a5,310 <atoi+0x48>
 2e2:	872a                	mv	a4,a0
  n = 0;
 2e4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e6:	0705                	addi	a4,a4,1
 2e8:	0025179b          	slliw	a5,a0,0x2
 2ec:	9fa9                	addw	a5,a5,a0
 2ee:	0017979b          	slliw	a5,a5,0x1
 2f2:	9fb5                	addw	a5,a5,a3
 2f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f8:	00074683          	lbu	a3,0(a4)
 2fc:	fd06879b          	addiw	a5,a3,-48
 300:	0ff7f793          	zext.b	a5,a5
 304:	fef671e3          	bgeu	a2,a5,2e6 <atoi+0x1e>
  return n;
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  n = 0;
 310:	4501                	li	a0,0
 312:	bfdd                	j	308 <atoi+0x40>

0000000000000314 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57563          	bgeu	a0,a1,346 <memmove+0x32>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x2a>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
    dst += n;
 346:	00c50733          	add	a4,a0,a2
    src += n;
 34a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34c:	fec059e3          	blez	a2,33e <memmove+0x2a>
 350:	fff6079b          	addiw	a5,a2,-1
 354:	1782                	slli	a5,a5,0x20
 356:	9381                	srli	a5,a5,0x20
 358:	fff7c793          	not	a5,a5
 35c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35e:	15fd                	addi	a1,a1,-1
 360:	177d                	addi	a4,a4,-1
 362:	0005c683          	lbu	a3,0(a1)
 366:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36a:	fef71ae3          	bne	a4,a5,35e <memmove+0x4a>
 36e:	bfc1                	j	33e <memmove+0x2a>

0000000000000370 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 378:	ca0d                	beqz	a2,3aa <memcmp+0x3a>
 37a:	fff6069b          	addiw	a3,a2,-1
 37e:	1682                	slli	a3,a3,0x20
 380:	9281                	srli	a3,a3,0x20
 382:	0685                	addi	a3,a3,1
 384:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 386:	00054783          	lbu	a5,0(a0)
 38a:	0005c703          	lbu	a4,0(a1)
 38e:	00e79863          	bne	a5,a4,39e <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 392:	0505                	addi	a0,a0,1
    p2++;
 394:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 396:	fed518e3          	bne	a0,a3,386 <memcmp+0x16>
  }
  return 0;
 39a:	4501                	li	a0,0
 39c:	a019                	j	3a2 <memcmp+0x32>
      return *p1 - *p2;
 39e:	40e7853b          	subw	a0,a5,a4
}
 3a2:	60a2                	ld	ra,8(sp)
 3a4:	6402                	ld	s0,0(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	bfdd                	j	3a2 <memcmp+0x32>

00000000000003ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b6:	00000097          	auipc	ra,0x0
 3ba:	f5e080e7          	jalr	-162(ra) # 314 <memmove>
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c6:	4885                	li	a7,1
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ce:	4889                	li	a7,2
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d6:	488d                	li	a7,3
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3de:	4891                	li	a7,4
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <read>:
.global read
read:
 li a7, SYS_read
 3e6:	4895                	li	a7,5
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <write>:
.global write
write:
 li a7, SYS_write
 3ee:	48c1                	li	a7,16
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <close>:
.global close
close:
 li a7, SYS_close
 3f6:	48d5                	li	a7,21
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fe:	4899                	li	a7,6
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exec>:
.global exec
exec:
 li a7, SYS_exec
 406:	489d                	li	a7,7
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <open>:
.global open
open:
 li a7, SYS_open
 40e:	48bd                	li	a7,15
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 416:	48c5                	li	a7,17
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41e:	48c9                	li	a7,18
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 426:	48a1                	li	a7,8
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <link>:
.global link
link:
 li a7, SYS_link
 42e:	48cd                	li	a7,19
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 436:	48d1                	li	a7,20
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43e:	48a5                	li	a7,9
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <dup>:
.global dup
dup:
 li a7, SYS_dup
 446:	48a9                	li	a7,10
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44e:	48ad                	li	a7,11
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 456:	48b1                	li	a7,12
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 45e:	48b5                	li	a7,13
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 466:	48b9                	li	a7,14
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 46e:	48d9                	li	a7,22
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 476:	48dd                	li	a7,23
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 47e:	48e1                	li	a7,24
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 486:	48e5                	li	a7,25
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret
