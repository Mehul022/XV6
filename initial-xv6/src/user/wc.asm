
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
  36:	20000d13          	li	s10,512
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  3a:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  3c:	00001a17          	auipc	s4,0x1
  40:	944a0a13          	addi	s4,s4,-1724 # 980 <malloc+0x104>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  44:	a805                	j	74 <wc+0x74>
      if(strchr(" \r\t\n\v", buf[i]))
  46:	8552                	mv	a0,s4
  48:	00000097          	auipc	ra,0x0
  4c:	206080e7          	jalr	518(ra) # 24e <strchr>
  50:	c919                	beqz	a0,66 <wc+0x66>
        inword = 0;
  52:	4901                	li	s2,0
    for(i=0; i<n; i++){
  54:	0485                	addi	s1,s1,1
  56:	01348d63          	beq	s1,s3,70 <wc+0x70>
      if(buf[i] == '\n')
  5a:	0004c583          	lbu	a1,0(s1)
  5e:	ff5594e3          	bne	a1,s5,46 <wc+0x46>
        l++;
  62:	2b85                	addiw	s7,s7,1
  64:	b7cd                	j	46 <wc+0x46>
      else if(!inword){
  66:	fe0917e3          	bnez	s2,54 <wc+0x54>
        w++;
  6a:	2c05                	addiw	s8,s8,1
        inword = 1;
  6c:	4905                	li	s2,1
  6e:	b7dd                	j	54 <wc+0x54>
  70:	019b0cbb          	addw	s9,s6,s9
  while((n = read(fd, buf, sizeof(buf))) > 0){
  74:	866a                	mv	a2,s10
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3e6080e7          	jalr	998(ra) # 462 <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
  8a:	00001497          	auipc	s1,0x1
  8e:	f8648493          	addi	s1,s1,-122 # 1010 <buf>
  92:	009b09b3          	add	s3,s6,s1
  96:	b7d1                	j	5a <wc+0x5a>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86e6                	mv	a3,s9
  a2:	8662                	mv	a2,s8
  a4:	85de                	mv	a1,s7
  a6:	00001517          	auipc	a0,0x1
  aa:	8fa50513          	addi	a0,a0,-1798 # 9a0 <malloc+0x124>
  ae:	00000097          	auipc	ra,0x0
  b2:	712080e7          	jalr	1810(ra) # 7c0 <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	8bc50513          	addi	a0,a0,-1860 # 990 <malloc+0x114>
  dc:	00000097          	auipc	ra,0x0
  e0:	6e4080e7          	jalr	1764(ra) # 7c0 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	364080e7          	jalr	868(ra) # 44a <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  f6:	4785                	li	a5,1
  f8:	04a7dc63          	bge	a5,a0,150 <main+0x62>
  fc:	ec26                	sd	s1,24(sp)
  fe:	e84a                	sd	s2,16(sp)
 100:	e44e                	sd	s3,8(sp)
 102:	00858913          	addi	s2,a1,8
 106:	ffe5099b          	addiw	s3,a0,-2
 10a:	02099793          	slli	a5,s3,0x20
 10e:	01d7d993          	srli	s3,a5,0x1d
 112:	05c1                	addi	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	36e080e7          	jalr	878(ra) # 48a <open>
 124:	84aa                	mv	s1,a0
 126:	04054663          	bltz	a0,172 <main+0x84>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	33a080e7          	jalr	826(ra) # 472 <close>
  for(i = 1; i < argc; i++){
 140:	0921                	addi	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	302080e7          	jalr	770(ra) # 44a <exit>
 150:	ec26                	sd	s1,24(sp)
 152:	e84a                	sd	s2,16(sp)
 154:	e44e                	sd	s3,8(sp)
    wc(0, "");
 156:	00001597          	auipc	a1,0x1
 15a:	83258593          	addi	a1,a1,-1998 # 988 <malloc+0x10c>
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	ea0080e7          	jalr	-352(ra) # 0 <wc>
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	2e0080e7          	jalr	736(ra) # 44a <exit>
      printf("wc: cannot open %s\n", argv[i]);
 172:	00093583          	ld	a1,0(s2)
 176:	00001517          	auipc	a0,0x1
 17a:	83a50513          	addi	a0,a0,-1990 # 9b0 <malloc+0x134>
 17e:	00000097          	auipc	ra,0x0
 182:	642080e7          	jalr	1602(ra) # 7c0 <printf>
      exit(1);
 186:	4505                	li	a0,1
 188:	00000097          	auipc	ra,0x0
 18c:	2c2080e7          	jalr	706(ra) # 44a <exit>

0000000000000190 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 190:	1141                	addi	sp,sp,-16
 192:	e406                	sd	ra,8(sp)
 194:	e022                	sd	s0,0(sp)
 196:	0800                	addi	s0,sp,16
  extern int main();
  main();
 198:	00000097          	auipc	ra,0x0
 19c:	f56080e7          	jalr	-170(ra) # ee <main>
  exit(0);
 1a0:	4501                	li	a0,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	2a8080e7          	jalr	680(ra) # 44a <exit>

00000000000001aa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b2:	87aa                	mv	a5,a0
 1b4:	0585                	addi	a1,a1,1
 1b6:	0785                	addi	a5,a5,1
 1b8:	fff5c703          	lbu	a4,-1(a1)
 1bc:	fee78fa3          	sb	a4,-1(a5)
 1c0:	fb75                	bnez	a4,1b4 <strcpy+0xa>
    ;
  return os;
}
 1c2:	60a2                	ld	ra,8(sp)
 1c4:	6402                	ld	s0,0(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e406                	sd	ra,8(sp)
 1ce:	e022                	sd	s0,0(sp)
 1d0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb91                	beqz	a5,1ea <strcmp+0x20>
 1d8:	0005c703          	lbu	a4,0(a1)
 1dc:	00f71763          	bne	a4,a5,1ea <strcmp+0x20>
    p++, q++;
 1e0:	0505                	addi	a0,a0,1
 1e2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbe5                	bnez	a5,1d8 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1ea:	0005c503          	lbu	a0,0(a1)
}
 1ee:	40a7853b          	subw	a0,a5,a0
 1f2:	60a2                	ld	ra,8(sp)
 1f4:	6402                	ld	s0,0(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <strlen>:

uint
strlen(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e406                	sd	ra,8(sp)
 1fe:	e022                	sd	s0,0(sp)
 200:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 202:	00054783          	lbu	a5,0(a0)
 206:	cf99                	beqz	a5,224 <strlen+0x2a>
 208:	0505                	addi	a0,a0,1
 20a:	87aa                	mv	a5,a0
 20c:	86be                	mv	a3,a5
 20e:	0785                	addi	a5,a5,1
 210:	fff7c703          	lbu	a4,-1(a5)
 214:	ff65                	bnez	a4,20c <strlen+0x12>
 216:	40a6853b          	subw	a0,a3,a0
 21a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 21c:	60a2                	ld	ra,8(sp)
 21e:	6402                	ld	s0,0(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
  for(n = 0; s[n]; n++)
 224:	4501                	li	a0,0
 226:	bfdd                	j	21c <strlen+0x22>

0000000000000228 <memset>:

void*
memset(void *dst, int c, uint n)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e406                	sd	ra,8(sp)
 22c:	e022                	sd	s0,0(sp)
 22e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 230:	ca19                	beqz	a2,246 <memset+0x1e>
 232:	87aa                	mv	a5,a0
 234:	1602                	slli	a2,a2,0x20
 236:	9201                	srli	a2,a2,0x20
 238:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 23c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 240:	0785                	addi	a5,a5,1
 242:	fee79de3          	bne	a5,a4,23c <memset+0x14>
  }
  return dst;
}
 246:	60a2                	ld	ra,8(sp)
 248:	6402                	ld	s0,0(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret

000000000000024e <strchr>:

char*
strchr(const char *s, char c)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  for(; *s; s++)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cf81                	beqz	a5,272 <strchr+0x24>
    if(*s == c)
 25c:	00f58763          	beq	a1,a5,26a <strchr+0x1c>
  for(; *s; s++)
 260:	0505                	addi	a0,a0,1
 262:	00054783          	lbu	a5,0(a0)
 266:	fbfd                	bnez	a5,25c <strchr+0xe>
      return (char*)s;
  return 0;
 268:	4501                	li	a0,0
}
 26a:	60a2                	ld	ra,8(sp)
 26c:	6402                	ld	s0,0(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  return 0;
 272:	4501                	li	a0,0
 274:	bfdd                	j	26a <strchr+0x1c>

0000000000000276 <gets>:

char*
gets(char *buf, int max)
{
 276:	7159                	addi	sp,sp,-112
 278:	f486                	sd	ra,104(sp)
 27a:	f0a2                	sd	s0,96(sp)
 27c:	eca6                	sd	s1,88(sp)
 27e:	e8ca                	sd	s2,80(sp)
 280:	e4ce                	sd	s3,72(sp)
 282:	e0d2                	sd	s4,64(sp)
 284:	fc56                	sd	s5,56(sp)
 286:	f85a                	sd	s6,48(sp)
 288:	f45e                	sd	s7,40(sp)
 28a:	f062                	sd	s8,32(sp)
 28c:	ec66                	sd	s9,24(sp)
 28e:	e86a                	sd	s10,16(sp)
 290:	1880                	addi	s0,sp,112
 292:	8caa                	mv	s9,a0
 294:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 296:	892a                	mv	s2,a0
 298:	4481                	li	s1,0
    cc = read(0, &c, 1);
 29a:	f9f40b13          	addi	s6,s0,-97
 29e:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a0:	4ba9                	li	s7,10
 2a2:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 2a4:	8d26                	mv	s10,s1
 2a6:	0014899b          	addiw	s3,s1,1
 2aa:	84ce                	mv	s1,s3
 2ac:	0349d763          	bge	s3,s4,2da <gets+0x64>
    cc = read(0, &c, 1);
 2b0:	8656                	mv	a2,s5
 2b2:	85da                	mv	a1,s6
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	1ac080e7          	jalr	428(ra) # 462 <read>
    if(cc < 1)
 2be:	00a05e63          	blez	a0,2da <gets+0x64>
    buf[i++] = c;
 2c2:	f9f44783          	lbu	a5,-97(s0)
 2c6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ca:	01778763          	beq	a5,s7,2d8 <gets+0x62>
 2ce:	0905                	addi	s2,s2,1
 2d0:	fd879ae3          	bne	a5,s8,2a4 <gets+0x2e>
    buf[i++] = c;
 2d4:	8d4e                	mv	s10,s3
 2d6:	a011                	j	2da <gets+0x64>
 2d8:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 2da:	9d66                	add	s10,s10,s9
 2dc:	000d0023          	sb	zero,0(s10)
  return buf;
}
 2e0:	8566                	mv	a0,s9
 2e2:	70a6                	ld	ra,104(sp)
 2e4:	7406                	ld	s0,96(sp)
 2e6:	64e6                	ld	s1,88(sp)
 2e8:	6946                	ld	s2,80(sp)
 2ea:	69a6                	ld	s3,72(sp)
 2ec:	6a06                	ld	s4,64(sp)
 2ee:	7ae2                	ld	s5,56(sp)
 2f0:	7b42                	ld	s6,48(sp)
 2f2:	7ba2                	ld	s7,40(sp)
 2f4:	7c02                	ld	s8,32(sp)
 2f6:	6ce2                	ld	s9,24(sp)
 2f8:	6d42                	ld	s10,16(sp)
 2fa:	6165                	addi	sp,sp,112
 2fc:	8082                	ret

00000000000002fe <stat>:

int
stat(const char *n, struct stat *st)
{
 2fe:	1101                	addi	sp,sp,-32
 300:	ec06                	sd	ra,24(sp)
 302:	e822                	sd	s0,16(sp)
 304:	e04a                	sd	s2,0(sp)
 306:	1000                	addi	s0,sp,32
 308:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30a:	4581                	li	a1,0
 30c:	00000097          	auipc	ra,0x0
 310:	17e080e7          	jalr	382(ra) # 48a <open>
  if(fd < 0)
 314:	02054663          	bltz	a0,340 <stat+0x42>
 318:	e426                	sd	s1,8(sp)
 31a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 31c:	85ca                	mv	a1,s2
 31e:	00000097          	auipc	ra,0x0
 322:	184080e7          	jalr	388(ra) # 4a2 <fstat>
 326:	892a                	mv	s2,a0
  close(fd);
 328:	8526                	mv	a0,s1
 32a:	00000097          	auipc	ra,0x0
 32e:	148080e7          	jalr	328(ra) # 472 <close>
  return r;
 332:	64a2                	ld	s1,8(sp)
}
 334:	854a                	mv	a0,s2
 336:	60e2                	ld	ra,24(sp)
 338:	6442                	ld	s0,16(sp)
 33a:	6902                	ld	s2,0(sp)
 33c:	6105                	addi	sp,sp,32
 33e:	8082                	ret
    return -1;
 340:	597d                	li	s2,-1
 342:	bfcd                	j	334 <stat+0x36>

0000000000000344 <atoi>:

int
atoi(const char *s)
{
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34c:	00054683          	lbu	a3,0(a0)
 350:	fd06879b          	addiw	a5,a3,-48
 354:	0ff7f793          	zext.b	a5,a5
 358:	4625                	li	a2,9
 35a:	02f66963          	bltu	a2,a5,38c <atoi+0x48>
 35e:	872a                	mv	a4,a0
  n = 0;
 360:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 362:	0705                	addi	a4,a4,1
 364:	0025179b          	slliw	a5,a0,0x2
 368:	9fa9                	addw	a5,a5,a0
 36a:	0017979b          	slliw	a5,a5,0x1
 36e:	9fb5                	addw	a5,a5,a3
 370:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 374:	00074683          	lbu	a3,0(a4)
 378:	fd06879b          	addiw	a5,a3,-48
 37c:	0ff7f793          	zext.b	a5,a5
 380:	fef671e3          	bgeu	a2,a5,362 <atoi+0x1e>
  return n;
}
 384:	60a2                	ld	ra,8(sp)
 386:	6402                	ld	s0,0(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  n = 0;
 38c:	4501                	li	a0,0
 38e:	bfdd                	j	384 <atoi+0x40>

0000000000000390 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e406                	sd	ra,8(sp)
 394:	e022                	sd	s0,0(sp)
 396:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 398:	02b57563          	bgeu	a0,a1,3c2 <memmove+0x32>
    while(n-- > 0)
 39c:	00c05f63          	blez	a2,3ba <memmove+0x2a>
 3a0:	1602                	slli	a2,a2,0x20
 3a2:	9201                	srli	a2,a2,0x20
 3a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3aa:	0585                	addi	a1,a1,1
 3ac:	0705                	addi	a4,a4,1
 3ae:	fff5c683          	lbu	a3,-1(a1)
 3b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ba:	60a2                	ld	ra,8(sp)
 3bc:	6402                	ld	s0,0(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
    dst += n;
 3c2:	00c50733          	add	a4,a0,a2
    src += n;
 3c6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c8:	fec059e3          	blez	a2,3ba <memmove+0x2a>
 3cc:	fff6079b          	addiw	a5,a2,-1
 3d0:	1782                	slli	a5,a5,0x20
 3d2:	9381                	srli	a5,a5,0x20
 3d4:	fff7c793          	not	a5,a5
 3d8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3da:	15fd                	addi	a1,a1,-1
 3dc:	177d                	addi	a4,a4,-1
 3de:	0005c683          	lbu	a3,0(a1)
 3e2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e6:	fef71ae3          	bne	a4,a5,3da <memmove+0x4a>
 3ea:	bfc1                	j	3ba <memmove+0x2a>

00000000000003ec <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e406                	sd	ra,8(sp)
 3f0:	e022                	sd	s0,0(sp)
 3f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f4:	ca0d                	beqz	a2,426 <memcmp+0x3a>
 3f6:	fff6069b          	addiw	a3,a2,-1
 3fa:	1682                	slli	a3,a3,0x20
 3fc:	9281                	srli	a3,a3,0x20
 3fe:	0685                	addi	a3,a3,1
 400:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 402:	00054783          	lbu	a5,0(a0)
 406:	0005c703          	lbu	a4,0(a1)
 40a:	00e79863          	bne	a5,a4,41a <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 40e:	0505                	addi	a0,a0,1
    p2++;
 410:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 412:	fed518e3          	bne	a0,a3,402 <memcmp+0x16>
  }
  return 0;
 416:	4501                	li	a0,0
 418:	a019                	j	41e <memcmp+0x32>
      return *p1 - *p2;
 41a:	40e7853b          	subw	a0,a5,a4
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
  return 0;
 426:	4501                	li	a0,0
 428:	bfdd                	j	41e <memcmp+0x32>

000000000000042a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e406                	sd	ra,8(sp)
 42e:	e022                	sd	s0,0(sp)
 430:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 432:	00000097          	auipc	ra,0x0
 436:	f5e080e7          	jalr	-162(ra) # 390 <memmove>
}
 43a:	60a2                	ld	ra,8(sp)
 43c:	6402                	ld	s0,0(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret

0000000000000442 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 442:	4885                	li	a7,1
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exit>:
.global exit
exit:
 li a7, SYS_exit
 44a:	4889                	li	a7,2
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <wait>:
.global wait
wait:
 li a7, SYS_wait
 452:	488d                	li	a7,3
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45a:	4891                	li	a7,4
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <read>:
.global read
read:
 li a7, SYS_read
 462:	4895                	li	a7,5
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <write>:
.global write
write:
 li a7, SYS_write
 46a:	48c1                	li	a7,16
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <close>:
.global close
close:
 li a7, SYS_close
 472:	48d5                	li	a7,21
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <kill>:
.global kill
kill:
 li a7, SYS_kill
 47a:	4899                	li	a7,6
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <exec>:
.global exec
exec:
 li a7, SYS_exec
 482:	489d                	li	a7,7
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <open>:
.global open
open:
 li a7, SYS_open
 48a:	48bd                	li	a7,15
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 492:	48c5                	li	a7,17
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49a:	48c9                	li	a7,18
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a2:	48a1                	li	a7,8
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <link>:
.global link
link:
 li a7, SYS_link
 4aa:	48cd                	li	a7,19
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b2:	48d1                	li	a7,20
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ba:	48a5                	li	a7,9
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c2:	48a9                	li	a7,10
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ca:	48ad                	li	a7,11
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d2:	48b1                	li	a7,12
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4da:	48b5                	li	a7,13
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e2:	48b9                	li	a7,14
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 4ea:	48d9                	li	a7,22
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 4f2:	48dd                	li	a7,23
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4fa:	48e1                	li	a7,24
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 502:	48e5                	li	a7,25
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50a:	1101                	addi	sp,sp,-32
 50c:	ec06                	sd	ra,24(sp)
 50e:	e822                	sd	s0,16(sp)
 510:	1000                	addi	s0,sp,32
 512:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 516:	4605                	li	a2,1
 518:	fef40593          	addi	a1,s0,-17
 51c:	00000097          	auipc	ra,0x0
 520:	f4e080e7          	jalr	-178(ra) # 46a <write>
}
 524:	60e2                	ld	ra,24(sp)
 526:	6442                	ld	s0,16(sp)
 528:	6105                	addi	sp,sp,32
 52a:	8082                	ret

000000000000052c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52c:	7139                	addi	sp,sp,-64
 52e:	fc06                	sd	ra,56(sp)
 530:	f822                	sd	s0,48(sp)
 532:	f426                	sd	s1,40(sp)
 534:	f04a                	sd	s2,32(sp)
 536:	ec4e                	sd	s3,24(sp)
 538:	0080                	addi	s0,sp,64
 53a:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53c:	c299                	beqz	a3,542 <printint+0x16>
 53e:	0805c063          	bltz	a1,5be <printint+0x92>
  neg = 0;
 542:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 544:	fc040313          	addi	t1,s0,-64
  neg = 0;
 548:	869a                	mv	a3,t1
  i = 0;
 54a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 54c:	00000817          	auipc	a6,0x0
 550:	4dc80813          	addi	a6,a6,1244 # a28 <digits>
 554:	88be                	mv	a7,a5
 556:	0017851b          	addiw	a0,a5,1
 55a:	87aa                	mv	a5,a0
 55c:	02c5f73b          	remuw	a4,a1,a2
 560:	1702                	slli	a4,a4,0x20
 562:	9301                	srli	a4,a4,0x20
 564:	9742                	add	a4,a4,a6
 566:	00074703          	lbu	a4,0(a4)
 56a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 56e:	872e                	mv	a4,a1
 570:	02c5d5bb          	divuw	a1,a1,a2
 574:	0685                	addi	a3,a3,1
 576:	fcc77fe3          	bgeu	a4,a2,554 <printint+0x28>
  if(neg)
 57a:	000e0c63          	beqz	t3,592 <printint+0x66>
    buf[i++] = '-';
 57e:	fd050793          	addi	a5,a0,-48
 582:	00878533          	add	a0,a5,s0
 586:	02d00793          	li	a5,45
 58a:	fef50823          	sb	a5,-16(a0)
 58e:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 592:	fff7899b          	addiw	s3,a5,-1
 596:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 59a:	fff4c583          	lbu	a1,-1(s1)
 59e:	854a                	mv	a0,s2
 5a0:	00000097          	auipc	ra,0x0
 5a4:	f6a080e7          	jalr	-150(ra) # 50a <putc>
  while(--i >= 0)
 5a8:	39fd                	addiw	s3,s3,-1
 5aa:	14fd                	addi	s1,s1,-1
 5ac:	fe09d7e3          	bgez	s3,59a <printint+0x6e>
}
 5b0:	70e2                	ld	ra,56(sp)
 5b2:	7442                	ld	s0,48(sp)
 5b4:	74a2                	ld	s1,40(sp)
 5b6:	7902                	ld	s2,32(sp)
 5b8:	69e2                	ld	s3,24(sp)
 5ba:	6121                	addi	sp,sp,64
 5bc:	8082                	ret
    x = -xx;
 5be:	40b005bb          	negw	a1,a1
    neg = 1;
 5c2:	4e05                	li	t3,1
    x = -xx;
 5c4:	b741                	j	544 <printint+0x18>

00000000000005c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c6:	715d                	addi	sp,sp,-80
 5c8:	e486                	sd	ra,72(sp)
 5ca:	e0a2                	sd	s0,64(sp)
 5cc:	f84a                	sd	s2,48(sp)
 5ce:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d0:	0005c903          	lbu	s2,0(a1)
 5d4:	1a090a63          	beqz	s2,788 <vprintf+0x1c2>
 5d8:	fc26                	sd	s1,56(sp)
 5da:	f44e                	sd	s3,40(sp)
 5dc:	f052                	sd	s4,32(sp)
 5de:	ec56                	sd	s5,24(sp)
 5e0:	e85a                	sd	s6,16(sp)
 5e2:	e45e                	sd	s7,8(sp)
 5e4:	8aaa                	mv	s5,a0
 5e6:	8bb2                	mv	s7,a2
 5e8:	00158493          	addi	s1,a1,1
  state = 0;
 5ec:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ee:	02500a13          	li	s4,37
 5f2:	4b55                	li	s6,21
 5f4:	a839                	j	612 <vprintf+0x4c>
        putc(fd, c);
 5f6:	85ca                	mv	a1,s2
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	f10080e7          	jalr	-240(ra) # 50a <putc>
 602:	a019                	j	608 <vprintf+0x42>
    } else if(state == '%'){
 604:	01498d63          	beq	s3,s4,61e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 608:	0485                	addi	s1,s1,1
 60a:	fff4c903          	lbu	s2,-1(s1)
 60e:	16090763          	beqz	s2,77c <vprintf+0x1b6>
    if(state == 0){
 612:	fe0999e3          	bnez	s3,604 <vprintf+0x3e>
      if(c == '%'){
 616:	ff4910e3          	bne	s2,s4,5f6 <vprintf+0x30>
        state = '%';
 61a:	89d2                	mv	s3,s4
 61c:	b7f5                	j	608 <vprintf+0x42>
      if(c == 'd'){
 61e:	13490463          	beq	s2,s4,746 <vprintf+0x180>
 622:	f9d9079b          	addiw	a5,s2,-99
 626:	0ff7f793          	zext.b	a5,a5
 62a:	12fb6763          	bltu	s6,a5,758 <vprintf+0x192>
 62e:	f9d9079b          	addiw	a5,s2,-99
 632:	0ff7f713          	zext.b	a4,a5
 636:	12eb6163          	bltu	s6,a4,758 <vprintf+0x192>
 63a:	00271793          	slli	a5,a4,0x2
 63e:	00000717          	auipc	a4,0x0
 642:	39270713          	addi	a4,a4,914 # 9d0 <malloc+0x154>
 646:	97ba                	add	a5,a5,a4
 648:	439c                	lw	a5,0(a5)
 64a:	97ba                	add	a5,a5,a4
 64c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 64e:	008b8913          	addi	s2,s7,8
 652:	4685                	li	a3,1
 654:	4629                	li	a2,10
 656:	000ba583          	lw	a1,0(s7)
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	ed0080e7          	jalr	-304(ra) # 52c <printint>
 664:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 666:	4981                	li	s3,0
 668:	b745                	j	608 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000ba583          	lw	a1,0(s7)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	eb4080e7          	jalr	-332(ra) # 52c <printint>
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	b751                	j	608 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000ba583          	lw	a1,0(s7)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e98080e7          	jalr	-360(ra) # 52c <printint>
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b7a5                	j	608 <vprintf+0x42>
 6a2:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6a4:	008b8c13          	addi	s8,s7,8
 6a8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ac:	03000593          	li	a1,48
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e58080e7          	jalr	-424(ra) # 50a <putc>
  putc(fd, 'x');
 6ba:	07800593          	li	a1,120
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e4a080e7          	jalr	-438(ra) # 50a <putc>
 6c8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ca:	00000b97          	auipc	s7,0x0
 6ce:	35eb8b93          	addi	s7,s7,862 # a28 <digits>
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97de                	add	a5,a5,s7
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	e2c080e7          	jalr	-468(ra) # 50a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e6:	0992                	slli	s3,s3,0x4
 6e8:	397d                	addiw	s2,s2,-1
 6ea:	fe0914e3          	bnez	s2,6d2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6ee:	8be2                	mv	s7,s8
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	6c02                	ld	s8,0(sp)
 6f4:	bf11                	j	608 <vprintf+0x42>
        s = va_arg(ap, char*);
 6f6:	008b8993          	addi	s3,s7,8
 6fa:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6fe:	02090163          	beqz	s2,720 <vprintf+0x15a>
        while(*s != 0){
 702:	00094583          	lbu	a1,0(s2)
 706:	c9a5                	beqz	a1,776 <vprintf+0x1b0>
          putc(fd, *s);
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	e00080e7          	jalr	-512(ra) # 50a <putc>
          s++;
 712:	0905                	addi	s2,s2,1
        while(*s != 0){
 714:	00094583          	lbu	a1,0(s2)
 718:	f9e5                	bnez	a1,708 <vprintf+0x142>
        s = va_arg(ap, char*);
 71a:	8bce                	mv	s7,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b5ed                	j	608 <vprintf+0x42>
          s = "(null)";
 720:	00000917          	auipc	s2,0x0
 724:	2a890913          	addi	s2,s2,680 # 9c8 <malloc+0x14c>
        while(*s != 0){
 728:	02800593          	li	a1,40
 72c:	bff1                	j	708 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 72e:	008b8913          	addi	s2,s7,8
 732:	000bc583          	lbu	a1,0(s7)
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	dd2080e7          	jalr	-558(ra) # 50a <putc>
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
 744:	b5d1                	j	608 <vprintf+0x42>
        putc(fd, c);
 746:	02500593          	li	a1,37
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	dbe080e7          	jalr	-578(ra) # 50a <putc>
      state = 0;
 754:	4981                	li	s3,0
 756:	bd4d                	j	608 <vprintf+0x42>
        putc(fd, '%');
 758:	02500593          	li	a1,37
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	dac080e7          	jalr	-596(ra) # 50a <putc>
        putc(fd, c);
 766:	85ca                	mv	a1,s2
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	da0080e7          	jalr	-608(ra) # 50a <putc>
      state = 0;
 772:	4981                	li	s3,0
 774:	bd51                	j	608 <vprintf+0x42>
        s = va_arg(ap, char*);
 776:	8bce                	mv	s7,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	b579                	j	608 <vprintf+0x42>
 77c:	74e2                	ld	s1,56(sp)
 77e:	79a2                	ld	s3,40(sp)
 780:	7a02                	ld	s4,32(sp)
 782:	6ae2                	ld	s5,24(sp)
 784:	6b42                	ld	s6,16(sp)
 786:	6ba2                	ld	s7,8(sp)
    }
  }
}
 788:	60a6                	ld	ra,72(sp)
 78a:	6406                	ld	s0,64(sp)
 78c:	7942                	ld	s2,48(sp)
 78e:	6161                	addi	sp,sp,80
 790:	8082                	ret

0000000000000792 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 792:	715d                	addi	sp,sp,-80
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e010                	sd	a2,0(s0)
 79c:	e414                	sd	a3,8(s0)
 79e:	e818                	sd	a4,16(s0)
 7a0:	ec1c                	sd	a5,24(s0)
 7a2:	03043023          	sd	a6,32(s0)
 7a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7aa:	8622                	mv	a2,s0
 7ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b0:	00000097          	auipc	ra,0x0
 7b4:	e16080e7          	jalr	-490(ra) # 5c6 <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6161                	addi	sp,sp,80
 7be:	8082                	ret

00000000000007c0 <printf>:

void
printf(const char *fmt, ...)
{
 7c0:	711d                	addi	sp,sp,-96
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	1000                	addi	s0,sp,32
 7c8:	e40c                	sd	a1,8(s0)
 7ca:	e810                	sd	a2,16(s0)
 7cc:	ec14                	sd	a3,24(s0)
 7ce:	f018                	sd	a4,32(s0)
 7d0:	f41c                	sd	a5,40(s0)
 7d2:	03043823          	sd	a6,48(s0)
 7d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	00840613          	addi	a2,s0,8
 7de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e2:	85aa                	mv	a1,a0
 7e4:	4505                	li	a0,1
 7e6:	00000097          	auipc	ra,0x0
 7ea:	de0080e7          	jalr	-544(ra) # 5c6 <vprintf>
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	6125                	addi	sp,sp,96
 7f4:	8082                	ret

00000000000007f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f6:	1141                	addi	sp,sp,-16
 7f8:	e406                	sd	ra,8(sp)
 7fa:	e022                	sd	s0,0(sp)
 7fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	00000797          	auipc	a5,0x0
 806:	7fe7b783          	ld	a5,2046(a5) # 1000 <freep>
 80a:	a02d                	j	834 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80c:	4618                	lw	a4,8(a2)
 80e:	9f2d                	addw	a4,a4,a1
 810:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	6398                	ld	a4,0(a5)
 816:	6310                	ld	a2,0(a4)
 818:	a83d                	j	856 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 81a:	ff852703          	lw	a4,-8(a0)
 81e:	9f31                	addw	a4,a4,a2
 820:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 822:	ff053683          	ld	a3,-16(a0)
 826:	a091                	j	86a <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	6398                	ld	a4,0(a5)
 82a:	00e7e463          	bltu	a5,a4,832 <free+0x3c>
 82e:	00e6ea63          	bltu	a3,a4,842 <free+0x4c>
{
 832:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 834:	fed7fae3          	bgeu	a5,a3,828 <free+0x32>
 838:	6398                	ld	a4,0(a5)
 83a:	00e6e463          	bltu	a3,a4,842 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83e:	fee7eae3          	bltu	a5,a4,832 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 842:	ff852583          	lw	a1,-8(a0)
 846:	6390                	ld	a2,0(a5)
 848:	02059813          	slli	a6,a1,0x20
 84c:	01c85713          	srli	a4,a6,0x1c
 850:	9736                	add	a4,a4,a3
 852:	fae60de3          	beq	a2,a4,80c <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 85a:	4790                	lw	a2,8(a5)
 85c:	02061593          	slli	a1,a2,0x20
 860:	01c5d713          	srli	a4,a1,0x1c
 864:	973e                	add	a4,a4,a5
 866:	fae68ae3          	beq	a3,a4,81a <free+0x24>
    p->s.ptr = bp->s.ptr;
 86a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 86c:	00000717          	auipc	a4,0x0
 870:	78f73a23          	sd	a5,1940(a4) # 1000 <freep>
}
 874:	60a2                	ld	ra,8(sp)
 876:	6402                	ld	s0,0(sp)
 878:	0141                	addi	sp,sp,16
 87a:	8082                	ret

000000000000087c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87c:	7139                	addi	sp,sp,-64
 87e:	fc06                	sd	ra,56(sp)
 880:	f822                	sd	s0,48(sp)
 882:	f04a                	sd	s2,32(sp)
 884:	ec4e                	sd	s3,24(sp)
 886:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 888:	02051993          	slli	s3,a0,0x20
 88c:	0209d993          	srli	s3,s3,0x20
 890:	09bd                	addi	s3,s3,15
 892:	0049d993          	srli	s3,s3,0x4
 896:	2985                	addiw	s3,s3,1
 898:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 89a:	00000517          	auipc	a0,0x0
 89e:	76653503          	ld	a0,1894(a0) # 1000 <freep>
 8a2:	c905                	beqz	a0,8d2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	09377a63          	bgeu	a4,s3,93c <malloc+0xc0>
 8ac:	f426                	sd	s1,40(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b4:	8a4e                	mv	s4,s3
 8b6:	6705                	lui	a4,0x1
 8b8:	00e9f363          	bgeu	s3,a4,8be <malloc+0x42>
 8bc:	6a05                	lui	s4,0x1
 8be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c6:	00000497          	auipc	s1,0x0
 8ca:	73a48493          	addi	s1,s1,1850 # 1000 <freep>
  if(p == (char*)-1)
 8ce:	5afd                	li	s5,-1
 8d0:	a089                	j	912 <malloc+0x96>
 8d2:	f426                	sd	s1,40(sp)
 8d4:	e852                	sd	s4,16(sp)
 8d6:	e456                	sd	s5,8(sp)
 8d8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8da:	00001797          	auipc	a5,0x1
 8de:	93678793          	addi	a5,a5,-1738 # 1210 <base>
 8e2:	00000717          	auipc	a4,0x0
 8e6:	70f73f23          	sd	a5,1822(a4) # 1000 <freep>
 8ea:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ec:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f0:	b7d1                	j	8b4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	e118                	sd	a4,0(a0)
 8f6:	a8b9                	j	954 <malloc+0xd8>
  hp->s.size = nu;
 8f8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fc:	0541                	addi	a0,a0,16
 8fe:	00000097          	auipc	ra,0x0
 902:	ef8080e7          	jalr	-264(ra) # 7f6 <free>
  return freep;
 906:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 908:	c135                	beqz	a0,96c <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90c:	4798                	lw	a4,8(a5)
 90e:	03277363          	bgeu	a4,s2,934 <malloc+0xb8>
    if(p == freep)
 912:	6098                	ld	a4,0(s1)
 914:	853e                	mv	a0,a5
 916:	fef71ae3          	bne	a4,a5,90a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 91a:	8552                	mv	a0,s4
 91c:	00000097          	auipc	ra,0x0
 920:	bb6080e7          	jalr	-1098(ra) # 4d2 <sbrk>
  if(p == (char*)-1)
 924:	fd551ae3          	bne	a0,s5,8f8 <malloc+0x7c>
        return 0;
 928:	4501                	li	a0,0
 92a:	74a2                	ld	s1,40(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
 932:	a03d                	j	960 <malloc+0xe4>
 934:	74a2                	ld	s1,40(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 93c:	fae90be3          	beq	s2,a4,8f2 <malloc+0x76>
        p->s.size -= nunits;
 940:	4137073b          	subw	a4,a4,s3
 944:	c798                	sw	a4,8(a5)
        p += p->s.size;
 946:	02071693          	slli	a3,a4,0x20
 94a:	01c6d713          	srli	a4,a3,0x1c
 94e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 950:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 954:	00000717          	auipc	a4,0x0
 958:	6aa73623          	sd	a0,1708(a4) # 1000 <freep>
      return (void*)(p + 1);
 95c:	01078513          	addi	a0,a5,16
  }
}
 960:	70e2                	ld	ra,56(sp)
 962:	7442                	ld	s0,48(sp)
 964:	7902                	ld	s2,32(sp)
 966:	69e2                	ld	s3,24(sp)
 968:	6121                	addi	sp,sp,64
 96a:	8082                	ret
 96c:	74a2                	ld	s1,40(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
 974:	b7f5                	j	960 <malloc+0xe4>
