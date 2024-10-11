
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
    "chdir", "dup", "getpid", "sbrk", "sleep", "uptime", "open",
    "write", "mknod", "unlink", "link", "mkdir", "close", "waitx",
    "getSysCount"};

int main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f04a                	sd	s2,32(sp)
   8:	e852                	sd	s4,16(sp)
   a:	0080                	addi	s0,sp,64
    if (argc < 3)
   c:	4789                	li	a5,2
   e:	08a7dd63          	bge	a5,a0,a8 <main+0xa8>
  12:	8a2e                	mv	s4,a1
    {
        fprintf(2, "Usage: syscount <mask> command [args]\n");
        exit(1);
    }
    int mask = atoi(argv[1]);
  14:	6588                	ld	a0,8(a1)
  16:	00000097          	auipc	ra,0x0
  1a:	2e2080e7          	jalr	738(ra) # 2f8 <atoi>
    if (mask <= 0 || (mask & (mask - 1)) != 0)
  1e:	0aa05663          	blez	a0,ca <main+0xca>
  22:	fff5091b          	addiw	s2,a0,-1
  26:	01257933          	and	s2,a0,s2
  2a:	2901                	sext.w	s2,s2
  2c:	08091f63          	bnez	s2,ca <main+0xca>
    {
        printf("Invalid mask!!\n");
        return 0;
    }
    int syscall_index = -1;
    while (mask > 1)
  30:	4685                	li	a3,1
    int syscall_index = -1;
  32:	57fd                	li	a5,-1
    while (mask > 1)
  34:	8736                	mv	a4,a3
  36:	0aa6dc63          	bge	a3,a0,ee <main+0xee>
  3a:	f426                	sd	s1,40(sp)
  3c:	ec4e                	sd	s3,24(sp)
    {
        mask >>= 1;
  3e:	4015551b          	sraiw	a0,a0,0x1
        syscall_index++;
  42:	89be                	mv	s3,a5
  44:	0017849b          	addiw	s1,a5,1
  48:	87a6                	mv	a5,s1
    while (mask > 1)
  4a:	fea74ae3          	blt	a4,a0,3e <main+0x3e>
    }
    if (syscall_index < 0 || syscall_index >= 23)
  4e:	4759                	li	a4,22
  50:	08976d63          	bltu	a4,s1,ea <main+0xea>
  54:	e456                	sd	s5,8(sp)
    {
        printf("Invalid mask!!\n");
        return 0;
    }
    int p = fork();
  56:	00000097          	auipc	ra,0x0
  5a:	3a0080e7          	jalr	928(ra) # 3f6 <fork>
  5e:	8aaa                	mv	s5,a0
    if (p < 0)
  60:	0a054063          	bltz	a0,100 <main+0x100>
    {
        printf("fork");
        return -1;
    }
    else if (p == 0)
  64:	c95d                	beqz	a0,11a <main+0x11a>
        printf("Exec failed");
        exit(1);
    }
    else
    {
        wait(0);
  66:	4501                	li	a0,0
  68:	00000097          	auipc	ra,0x0
  6c:	39e080e7          	jalr	926(ra) # 406 <wait>
        printf("PID %d called %s %d times.\n", p, syscall_names[syscall_index], getSysCount(syscall_index + 1));
  70:	048e                	slli	s1,s1,0x3
  72:	00001797          	auipc	a5,0x1
  76:	f8e78793          	addi	a5,a5,-114 # 1000 <syscall_names>
  7a:	97a6                	add	a5,a5,s1
  7c:	6384                	ld	s1,0(a5)
  7e:	0029851b          	addiw	a0,s3,2
  82:	00000097          	auipc	ra,0x0
  86:	424080e7          	jalr	1060(ra) # 4a6 <getSysCount>
  8a:	86aa                	mv	a3,a0
  8c:	8626                	mv	a2,s1
  8e:	85d6                	mv	a1,s5
  90:	00001517          	auipc	a0,0x1
  94:	8f850513          	addi	a0,a0,-1800 # 988 <malloc+0x158>
  98:	00000097          	auipc	ra,0x0
  9c:	6dc080e7          	jalr	1756(ra) # 774 <printf>
  a0:	74a2                	ld	s1,40(sp)
  a2:	69e2                	ld	s3,24(sp)
  a4:	6aa2                	ld	s5,8(sp)
    }
    return 0;
  a6:	a81d                	j	dc <main+0xdc>
  a8:	f426                	sd	s1,40(sp)
  aa:	ec4e                	sd	s3,24(sp)
  ac:	e456                	sd	s5,8(sp)
        fprintf(2, "Usage: syscount <mask> command [args]\n");
  ae:	00001597          	auipc	a1,0x1
  b2:	88258593          	addi	a1,a1,-1918 # 930 <malloc+0x100>
  b6:	853e                	mv	a0,a5
  b8:	00000097          	auipc	ra,0x0
  bc:	68e080e7          	jalr	1678(ra) # 746 <fprintf>
        exit(1);
  c0:	4505                	li	a0,1
  c2:	00000097          	auipc	ra,0x0
  c6:	33c080e7          	jalr	828(ra) # 3fe <exit>
        printf("Invalid mask!!\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	89650513          	addi	a0,a0,-1898 # 960 <malloc+0x130>
  d2:	00000097          	auipc	ra,0x0
  d6:	6a2080e7          	jalr	1698(ra) # 774 <printf>
        return 0;
  da:	4901                	li	s2,0
  dc:	854a                	mv	a0,s2
  de:	70e2                	ld	ra,56(sp)
  e0:	7442                	ld	s0,48(sp)
  e2:	7902                	ld	s2,32(sp)
  e4:	6a42                	ld	s4,16(sp)
  e6:	6121                	addi	sp,sp,64
  e8:	8082                	ret
  ea:	74a2                	ld	s1,40(sp)
  ec:	69e2                	ld	s3,24(sp)
        printf("Invalid mask!!\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	87250513          	addi	a0,a0,-1934 # 960 <malloc+0x130>
  f6:	00000097          	auipc	ra,0x0
  fa:	67e080e7          	jalr	1662(ra) # 774 <printf>
        return 0;
  fe:	bff9                	j	dc <main+0xdc>
        printf("fork");
 100:	00001517          	auipc	a0,0x1
 104:	87050513          	addi	a0,a0,-1936 # 970 <malloc+0x140>
 108:	00000097          	auipc	ra,0x0
 10c:	66c080e7          	jalr	1644(ra) # 774 <printf>
        return -1;
 110:	597d                	li	s2,-1
 112:	74a2                	ld	s1,40(sp)
 114:	69e2                	ld	s3,24(sp)
 116:	6aa2                	ld	s5,8(sp)
 118:	b7d1                	j	dc <main+0xdc>
        exec(argv[2], argv + 2);
 11a:	010a0593          	addi	a1,s4,16
 11e:	010a3503          	ld	a0,16(s4)
 122:	00000097          	auipc	ra,0x0
 126:	314080e7          	jalr	788(ra) # 436 <exec>
        printf("Exec failed");
 12a:	00001517          	auipc	a0,0x1
 12e:	84e50513          	addi	a0,a0,-1970 # 978 <malloc+0x148>
 132:	00000097          	auipc	ra,0x0
 136:	642080e7          	jalr	1602(ra) # 774 <printf>
        exit(1);
 13a:	4505                	li	a0,1
 13c:	00000097          	auipc	ra,0x0
 140:	2c2080e7          	jalr	706(ra) # 3fe <exit>

0000000000000144 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 144:	1141                	addi	sp,sp,-16
 146:	e406                	sd	ra,8(sp)
 148:	e022                	sd	s0,0(sp)
 14a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 14c:	00000097          	auipc	ra,0x0
 150:	eb4080e7          	jalr	-332(ra) # 0 <main>
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2a8080e7          	jalr	680(ra) # 3fe <exit>

000000000000015e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e406                	sd	ra,8(sp)
 162:	e022                	sd	s0,0(sp)
 164:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 166:	87aa                	mv	a5,a0
 168:	0585                	addi	a1,a1,1
 16a:	0785                	addi	a5,a5,1
 16c:	fff5c703          	lbu	a4,-1(a1)
 170:	fee78fa3          	sb	a4,-1(a5)
 174:	fb75                	bnez	a4,168 <strcpy+0xa>
    ;
  return os;
}
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cb91                	beqz	a5,19e <strcmp+0x20>
 18c:	0005c703          	lbu	a4,0(a1)
 190:	00f71763          	bne	a4,a5,19e <strcmp+0x20>
    p++, q++;
 194:	0505                	addi	a0,a0,1
 196:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 198:	00054783          	lbu	a5,0(a0)
 19c:	fbe5                	bnez	a5,18c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 19e:	0005c503          	lbu	a0,0(a1)
}
 1a2:	40a7853b          	subw	a0,a5,a0
 1a6:	60a2                	ld	ra,8(sp)
 1a8:	6402                	ld	s0,0(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strlen>:

uint
strlen(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	cf99                	beqz	a5,1d8 <strlen+0x2a>
 1bc:	0505                	addi	a0,a0,1
 1be:	87aa                	mv	a5,a0
 1c0:	86be                	mv	a3,a5
 1c2:	0785                	addi	a5,a5,1
 1c4:	fff7c703          	lbu	a4,-1(a5)
 1c8:	ff65                	bnez	a4,1c0 <strlen+0x12>
 1ca:	40a6853b          	subw	a0,a3,a0
 1ce:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d0:	60a2                	ld	ra,8(sp)
 1d2:	6402                	ld	s0,0(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  for(n = 0; s[n]; n++)
 1d8:	4501                	li	a0,0
 1da:	bfdd                	j	1d0 <strlen+0x22>

00000000000001dc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e406                	sd	ra,8(sp)
 1e0:	e022                	sd	s0,0(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1e>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x14>
  }
  return dst;
}
 1fa:	60a2                	ld	ra,8(sp)
 1fc:	6402                	ld	s0,0(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strchr>:

char*
strchr(const char *s, char c)
{
 202:	1141                	addi	sp,sp,-16
 204:	e406                	sd	ra,8(sp)
 206:	e022                	sd	s0,0(sp)
 208:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cf81                	beqz	a5,226 <strchr+0x24>
    if(*s == c)
 210:	00f58763          	beq	a1,a5,21e <strchr+0x1c>
  for(; *s; s++)
 214:	0505                	addi	a0,a0,1
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbfd                	bnez	a5,210 <strchr+0xe>
      return (char*)s;
  return 0;
 21c:	4501                	li	a0,0
}
 21e:	60a2                	ld	ra,8(sp)
 220:	6402                	ld	s0,0(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
  return 0;
 226:	4501                	li	a0,0
 228:	bfdd                	j	21e <strchr+0x1c>

000000000000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	7159                	addi	sp,sp,-112
 22c:	f486                	sd	ra,104(sp)
 22e:	f0a2                	sd	s0,96(sp)
 230:	eca6                	sd	s1,88(sp)
 232:	e8ca                	sd	s2,80(sp)
 234:	e4ce                	sd	s3,72(sp)
 236:	e0d2                	sd	s4,64(sp)
 238:	fc56                	sd	s5,56(sp)
 23a:	f85a                	sd	s6,48(sp)
 23c:	f45e                	sd	s7,40(sp)
 23e:	f062                	sd	s8,32(sp)
 240:	ec66                	sd	s9,24(sp)
 242:	e86a                	sd	s10,16(sp)
 244:	1880                	addi	s0,sp,112
 246:	8caa                	mv	s9,a0
 248:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24a:	892a                	mv	s2,a0
 24c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 24e:	f9f40b13          	addi	s6,s0,-97
 252:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 254:	4ba9                	li	s7,10
 256:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 258:	8d26                	mv	s10,s1
 25a:	0014899b          	addiw	s3,s1,1
 25e:	84ce                	mv	s1,s3
 260:	0349d763          	bge	s3,s4,28e <gets+0x64>
    cc = read(0, &c, 1);
 264:	8656                	mv	a2,s5
 266:	85da                	mv	a1,s6
 268:	4501                	li	a0,0
 26a:	00000097          	auipc	ra,0x0
 26e:	1ac080e7          	jalr	428(ra) # 416 <read>
    if(cc < 1)
 272:	00a05e63          	blez	a0,28e <gets+0x64>
    buf[i++] = c;
 276:	f9f44783          	lbu	a5,-97(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	01778763          	beq	a5,s7,28c <gets+0x62>
 282:	0905                	addi	s2,s2,1
 284:	fd879ae3          	bne	a5,s8,258 <gets+0x2e>
    buf[i++] = c;
 288:	8d4e                	mv	s10,s3
 28a:	a011                	j	28e <gets+0x64>
 28c:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 28e:	9d66                	add	s10,s10,s9
 290:	000d0023          	sb	zero,0(s10)
  return buf;
}
 294:	8566                	mv	a0,s9
 296:	70a6                	ld	ra,104(sp)
 298:	7406                	ld	s0,96(sp)
 29a:	64e6                	ld	s1,88(sp)
 29c:	6946                	ld	s2,80(sp)
 29e:	69a6                	ld	s3,72(sp)
 2a0:	6a06                	ld	s4,64(sp)
 2a2:	7ae2                	ld	s5,56(sp)
 2a4:	7b42                	ld	s6,48(sp)
 2a6:	7ba2                	ld	s7,40(sp)
 2a8:	7c02                	ld	s8,32(sp)
 2aa:	6ce2                	ld	s9,24(sp)
 2ac:	6d42                	ld	s10,16(sp)
 2ae:	6165                	addi	sp,sp,112
 2b0:	8082                	ret

00000000000002b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b2:	1101                	addi	sp,sp,-32
 2b4:	ec06                	sd	ra,24(sp)
 2b6:	e822                	sd	s0,16(sp)
 2b8:	e04a                	sd	s2,0(sp)
 2ba:	1000                	addi	s0,sp,32
 2bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2be:	4581                	li	a1,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	17e080e7          	jalr	382(ra) # 43e <open>
  if(fd < 0)
 2c8:	02054663          	bltz	a0,2f4 <stat+0x42>
 2cc:	e426                	sd	s1,8(sp)
 2ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d0:	85ca                	mv	a1,s2
 2d2:	00000097          	auipc	ra,0x0
 2d6:	184080e7          	jalr	388(ra) # 456 <fstat>
 2da:	892a                	mv	s2,a0
  close(fd);
 2dc:	8526                	mv	a0,s1
 2de:	00000097          	auipc	ra,0x0
 2e2:	148080e7          	jalr	328(ra) # 426 <close>
  return r;
 2e6:	64a2                	ld	s1,8(sp)
}
 2e8:	854a                	mv	a0,s2
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	6902                	ld	s2,0(sp)
 2f0:	6105                	addi	sp,sp,32
 2f2:	8082                	ret
    return -1;
 2f4:	597d                	li	s2,-1
 2f6:	bfcd                	j	2e8 <stat+0x36>

00000000000002f8 <atoi>:

int
atoi(const char *s)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 300:	00054683          	lbu	a3,0(a0)
 304:	fd06879b          	addiw	a5,a3,-48
 308:	0ff7f793          	zext.b	a5,a5
 30c:	4625                	li	a2,9
 30e:	02f66963          	bltu	a2,a5,340 <atoi+0x48>
 312:	872a                	mv	a4,a0
  n = 0;
 314:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 316:	0705                	addi	a4,a4,1
 318:	0025179b          	slliw	a5,a0,0x2
 31c:	9fa9                	addw	a5,a5,a0
 31e:	0017979b          	slliw	a5,a5,0x1
 322:	9fb5                	addw	a5,a5,a3
 324:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 328:	00074683          	lbu	a3,0(a4)
 32c:	fd06879b          	addiw	a5,a3,-48
 330:	0ff7f793          	zext.b	a5,a5
 334:	fef671e3          	bgeu	a2,a5,316 <atoi+0x1e>
  return n;
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  n = 0;
 340:	4501                	li	a0,0
 342:	bfdd                	j	338 <atoi+0x40>

0000000000000344 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 34c:	02b57563          	bgeu	a0,a1,376 <memmove+0x32>
    while(n-- > 0)
 350:	00c05f63          	blez	a2,36e <memmove+0x2a>
 354:	1602                	slli	a2,a2,0x20
 356:	9201                	srli	a2,a2,0x20
 358:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 35c:	872a                	mv	a4,a0
      *dst++ = *src++;
 35e:	0585                	addi	a1,a1,1
 360:	0705                	addi	a4,a4,1
 362:	fff5c683          	lbu	a3,-1(a1)
 366:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 36a:	fee79ae3          	bne	a5,a4,35e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
    dst += n;
 376:	00c50733          	add	a4,a0,a2
    src += n;
 37a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 37c:	fec059e3          	blez	a2,36e <memmove+0x2a>
 380:	fff6079b          	addiw	a5,a2,-1
 384:	1782                	slli	a5,a5,0x20
 386:	9381                	srli	a5,a5,0x20
 388:	fff7c793          	not	a5,a5
 38c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38e:	15fd                	addi	a1,a1,-1
 390:	177d                	addi	a4,a4,-1
 392:	0005c683          	lbu	a3,0(a1)
 396:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 39a:	fef71ae3          	bne	a4,a5,38e <memmove+0x4a>
 39e:	bfc1                	j	36e <memmove+0x2a>

00000000000003a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a8:	ca0d                	beqz	a2,3da <memcmp+0x3a>
 3aa:	fff6069b          	addiw	a3,a2,-1
 3ae:	1682                	slli	a3,a3,0x20
 3b0:	9281                	srli	a3,a3,0x20
 3b2:	0685                	addi	a3,a3,1
 3b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b6:	00054783          	lbu	a5,0(a0)
 3ba:	0005c703          	lbu	a4,0(a1)
 3be:	00e79863          	bne	a5,a4,3ce <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 3c2:	0505                	addi	a0,a0,1
    p2++;
 3c4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c6:	fed518e3          	bne	a0,a3,3b6 <memcmp+0x16>
  }
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	a019                	j	3d2 <memcmp+0x32>
      return *p1 - *p2;
 3ce:	40e7853b          	subw	a0,a5,a4
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret
  return 0;
 3da:	4501                	li	a0,0
 3dc:	bfdd                	j	3d2 <memcmp+0x32>

00000000000003de <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e6:	00000097          	auipc	ra,0x0
 3ea:	f5e080e7          	jalr	-162(ra) # 344 <memmove>
}
 3ee:	60a2                	ld	ra,8(sp)
 3f0:	6402                	ld	s0,0(sp)
 3f2:	0141                	addi	sp,sp,16
 3f4:	8082                	ret

00000000000003f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f6:	4885                	li	a7,1
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fe:	4889                	li	a7,2
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <wait>:
.global wait
wait:
 li a7, SYS_wait
 406:	488d                	li	a7,3
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40e:	4891                	li	a7,4
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <read>:
.global read
read:
 li a7, SYS_read
 416:	4895                	li	a7,5
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <write>:
.global write
write:
 li a7, SYS_write
 41e:	48c1                	li	a7,16
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <close>:
.global close
close:
 li a7, SYS_close
 426:	48d5                	li	a7,21
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <kill>:
.global kill
kill:
 li a7, SYS_kill
 42e:	4899                	li	a7,6
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <exec>:
.global exec
exec:
 li a7, SYS_exec
 436:	489d                	li	a7,7
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <open>:
.global open
open:
 li a7, SYS_open
 43e:	48bd                	li	a7,15
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 446:	48c5                	li	a7,17
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44e:	48c9                	li	a7,18
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 456:	48a1                	li	a7,8
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <link>:
.global link
link:
 li a7, SYS_link
 45e:	48cd                	li	a7,19
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 466:	48d1                	li	a7,20
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46e:	48a5                	li	a7,9
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <dup>:
.global dup
dup:
 li a7, SYS_dup
 476:	48a9                	li	a7,10
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47e:	48ad                	li	a7,11
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 486:	48b1                	li	a7,12
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48e:	48b5                	li	a7,13
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 496:	48b9                	li	a7,14
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 49e:	48d9                	li	a7,22
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 4a6:	48dd                	li	a7,23
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4ae:	48e1                	li	a7,24
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4b6:	48e5                	li	a7,25
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4be:	1101                	addi	sp,sp,-32
 4c0:	ec06                	sd	ra,24(sp)
 4c2:	e822                	sd	s0,16(sp)
 4c4:	1000                	addi	s0,sp,32
 4c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ca:	4605                	li	a2,1
 4cc:	fef40593          	addi	a1,s0,-17
 4d0:	00000097          	auipc	ra,0x0
 4d4:	f4e080e7          	jalr	-178(ra) # 41e <write>
}
 4d8:	60e2                	ld	ra,24(sp)
 4da:	6442                	ld	s0,16(sp)
 4dc:	6105                	addi	sp,sp,32
 4de:	8082                	ret

00000000000004e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e0:	7139                	addi	sp,sp,-64
 4e2:	fc06                	sd	ra,56(sp)
 4e4:	f822                	sd	s0,48(sp)
 4e6:	f426                	sd	s1,40(sp)
 4e8:	f04a                	sd	s2,32(sp)
 4ea:	ec4e                	sd	s3,24(sp)
 4ec:	0080                	addi	s0,sp,64
 4ee:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f0:	c299                	beqz	a3,4f6 <printint+0x16>
 4f2:	0805c063          	bltz	a1,572 <printint+0x92>
  neg = 0;
 4f6:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4f8:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4fc:	869a                	mv	a3,t1
  i = 0;
 4fe:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 500:	00000817          	auipc	a6,0x0
 504:	5c080813          	addi	a6,a6,1472 # ac0 <digits>
 508:	88be                	mv	a7,a5
 50a:	0017851b          	addiw	a0,a5,1
 50e:	87aa                	mv	a5,a0
 510:	02c5f73b          	remuw	a4,a1,a2
 514:	1702                	slli	a4,a4,0x20
 516:	9301                	srli	a4,a4,0x20
 518:	9742                	add	a4,a4,a6
 51a:	00074703          	lbu	a4,0(a4)
 51e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 522:	872e                	mv	a4,a1
 524:	02c5d5bb          	divuw	a1,a1,a2
 528:	0685                	addi	a3,a3,1
 52a:	fcc77fe3          	bgeu	a4,a2,508 <printint+0x28>
  if(neg)
 52e:	000e0c63          	beqz	t3,546 <printint+0x66>
    buf[i++] = '-';
 532:	fd050793          	addi	a5,a0,-48
 536:	00878533          	add	a0,a5,s0
 53a:	02d00793          	li	a5,45
 53e:	fef50823          	sb	a5,-16(a0)
 542:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 546:	fff7899b          	addiw	s3,a5,-1
 54a:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 54e:	fff4c583          	lbu	a1,-1(s1)
 552:	854a                	mv	a0,s2
 554:	00000097          	auipc	ra,0x0
 558:	f6a080e7          	jalr	-150(ra) # 4be <putc>
  while(--i >= 0)
 55c:	39fd                	addiw	s3,s3,-1
 55e:	14fd                	addi	s1,s1,-1
 560:	fe09d7e3          	bgez	s3,54e <printint+0x6e>
}
 564:	70e2                	ld	ra,56(sp)
 566:	7442                	ld	s0,48(sp)
 568:	74a2                	ld	s1,40(sp)
 56a:	7902                	ld	s2,32(sp)
 56c:	69e2                	ld	s3,24(sp)
 56e:	6121                	addi	sp,sp,64
 570:	8082                	ret
    x = -xx;
 572:	40b005bb          	negw	a1,a1
    neg = 1;
 576:	4e05                	li	t3,1
    x = -xx;
 578:	b741                	j	4f8 <printint+0x18>

000000000000057a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57a:	715d                	addi	sp,sp,-80
 57c:	e486                	sd	ra,72(sp)
 57e:	e0a2                	sd	s0,64(sp)
 580:	f84a                	sd	s2,48(sp)
 582:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 584:	0005c903          	lbu	s2,0(a1)
 588:	1a090a63          	beqz	s2,73c <vprintf+0x1c2>
 58c:	fc26                	sd	s1,56(sp)
 58e:	f44e                	sd	s3,40(sp)
 590:	f052                	sd	s4,32(sp)
 592:	ec56                	sd	s5,24(sp)
 594:	e85a                	sd	s6,16(sp)
 596:	e45e                	sd	s7,8(sp)
 598:	8aaa                	mv	s5,a0
 59a:	8bb2                	mv	s7,a2
 59c:	00158493          	addi	s1,a1,1
  state = 0;
 5a0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a2:	02500a13          	li	s4,37
 5a6:	4b55                	li	s6,21
 5a8:	a839                	j	5c6 <vprintf+0x4c>
        putc(fd, c);
 5aa:	85ca                	mv	a1,s2
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	f10080e7          	jalr	-240(ra) # 4be <putc>
 5b6:	a019                	j	5bc <vprintf+0x42>
    } else if(state == '%'){
 5b8:	01498d63          	beq	s3,s4,5d2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5bc:	0485                	addi	s1,s1,1
 5be:	fff4c903          	lbu	s2,-1(s1)
 5c2:	16090763          	beqz	s2,730 <vprintf+0x1b6>
    if(state == 0){
 5c6:	fe0999e3          	bnez	s3,5b8 <vprintf+0x3e>
      if(c == '%'){
 5ca:	ff4910e3          	bne	s2,s4,5aa <vprintf+0x30>
        state = '%';
 5ce:	89d2                	mv	s3,s4
 5d0:	b7f5                	j	5bc <vprintf+0x42>
      if(c == 'd'){
 5d2:	13490463          	beq	s2,s4,6fa <vprintf+0x180>
 5d6:	f9d9079b          	addiw	a5,s2,-99
 5da:	0ff7f793          	zext.b	a5,a5
 5de:	12fb6763          	bltu	s6,a5,70c <vprintf+0x192>
 5e2:	f9d9079b          	addiw	a5,s2,-99
 5e6:	0ff7f713          	zext.b	a4,a5
 5ea:	12eb6163          	bltu	s6,a4,70c <vprintf+0x192>
 5ee:	00271793          	slli	a5,a4,0x2
 5f2:	00000717          	auipc	a4,0x0
 5f6:	47670713          	addi	a4,a4,1142 # a68 <malloc+0x238>
 5fa:	97ba                	add	a5,a5,a4
 5fc:	439c                	lw	a5,0(a5)
 5fe:	97ba                	add	a5,a5,a4
 600:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 602:	008b8913          	addi	s2,s7,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000ba583          	lw	a1,0(s7)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	ed0080e7          	jalr	-304(ra) # 4e0 <printint>
 618:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b745                	j	5bc <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000ba583          	lw	a1,0(s7)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	eb4080e7          	jalr	-332(ra) # 4e0 <printint>
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	b751                	j	5bc <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000ba583          	lw	a1,0(s7)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e98080e7          	jalr	-360(ra) # 4e0 <printint>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	b7a5                	j	5bc <vprintf+0x42>
 656:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 658:	008b8c13          	addi	s8,s7,8
 65c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 660:	03000593          	li	a1,48
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e58080e7          	jalr	-424(ra) # 4be <putc>
  putc(fd, 'x');
 66e:	07800593          	li	a1,120
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e4a080e7          	jalr	-438(ra) # 4be <putc>
 67c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67e:	00000b97          	auipc	s7,0x0
 682:	442b8b93          	addi	s7,s7,1090 # ac0 <digits>
 686:	03c9d793          	srli	a5,s3,0x3c
 68a:	97de                	add	a5,a5,s7
 68c:	0007c583          	lbu	a1,0(a5)
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	e2c080e7          	jalr	-468(ra) # 4be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69a:	0992                	slli	s3,s3,0x4
 69c:	397d                	addiw	s2,s2,-1
 69e:	fe0914e3          	bnez	s2,686 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6a2:	8be2                	mv	s7,s8
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	6c02                	ld	s8,0(sp)
 6a8:	bf11                	j	5bc <vprintf+0x42>
        s = va_arg(ap, char*);
 6aa:	008b8993          	addi	s3,s7,8
 6ae:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6b2:	02090163          	beqz	s2,6d4 <vprintf+0x15a>
        while(*s != 0){
 6b6:	00094583          	lbu	a1,0(s2)
 6ba:	c9a5                	beqz	a1,72a <vprintf+0x1b0>
          putc(fd, *s);
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	e00080e7          	jalr	-512(ra) # 4be <putc>
          s++;
 6c6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	f9e5                	bnez	a1,6bc <vprintf+0x142>
        s = va_arg(ap, char*);
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b5ed                	j	5bc <vprintf+0x42>
          s = "(null)";
 6d4:	00000917          	auipc	s2,0x0
 6d8:	38c90913          	addi	s2,s2,908 # a60 <malloc+0x230>
        while(*s != 0){
 6dc:	02800593          	li	a1,40
 6e0:	bff1                	j	6bc <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	000bc583          	lbu	a1,0(s7)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	dd2080e7          	jalr	-558(ra) # 4be <putc>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b5d1                	j	5bc <vprintf+0x42>
        putc(fd, c);
 6fa:	02500593          	li	a1,37
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	dbe080e7          	jalr	-578(ra) # 4be <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd4d                	j	5bc <vprintf+0x42>
        putc(fd, '%');
 70c:	02500593          	li	a1,37
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	dac080e7          	jalr	-596(ra) # 4be <putc>
        putc(fd, c);
 71a:	85ca                	mv	a1,s2
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	da0080e7          	jalr	-608(ra) # 4be <putc>
      state = 0;
 726:	4981                	li	s3,0
 728:	bd51                	j	5bc <vprintf+0x42>
        s = va_arg(ap, char*);
 72a:	8bce                	mv	s7,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b579                	j	5bc <vprintf+0x42>
 730:	74e2                	ld	s1,56(sp)
 732:	79a2                	ld	s3,40(sp)
 734:	7a02                	ld	s4,32(sp)
 736:	6ae2                	ld	s5,24(sp)
 738:	6b42                	ld	s6,16(sp)
 73a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 73c:	60a6                	ld	ra,72(sp)
 73e:	6406                	ld	s0,64(sp)
 740:	7942                	ld	s2,48(sp)
 742:	6161                	addi	sp,sp,80
 744:	8082                	ret

0000000000000746 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 746:	715d                	addi	sp,sp,-80
 748:	ec06                	sd	ra,24(sp)
 74a:	e822                	sd	s0,16(sp)
 74c:	1000                	addi	s0,sp,32
 74e:	e010                	sd	a2,0(s0)
 750:	e414                	sd	a3,8(s0)
 752:	e818                	sd	a4,16(s0)
 754:	ec1c                	sd	a5,24(s0)
 756:	03043023          	sd	a6,32(s0)
 75a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75e:	8622                	mv	a2,s0
 760:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 764:	00000097          	auipc	ra,0x0
 768:	e16080e7          	jalr	-490(ra) # 57a <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6161                	addi	sp,sp,80
 772:	8082                	ret

0000000000000774 <printf>:

void
printf(const char *fmt, ...)
{
 774:	711d                	addi	sp,sp,-96
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e40c                	sd	a1,8(s0)
 77e:	e810                	sd	a2,16(s0)
 780:	ec14                	sd	a3,24(s0)
 782:	f018                	sd	a4,32(s0)
 784:	f41c                	sd	a5,40(s0)
 786:	03043823          	sd	a6,48(s0)
 78a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 78e:	00840613          	addi	a2,s0,8
 792:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 796:	85aa                	mv	a1,a0
 798:	4505                	li	a0,1
 79a:	00000097          	auipc	ra,0x0
 79e:	de0080e7          	jalr	-544(ra) # 57a <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6125                	addi	sp,sp,96
 7a8:	8082                	ret

00000000000007aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7aa:	1141                	addi	sp,sp,-16
 7ac:	e406                	sd	ra,8(sp)
 7ae:	e022                	sd	s0,0(sp)
 7b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	00001797          	auipc	a5,0x1
 7ba:	90a7b783          	ld	a5,-1782(a5) # 10c0 <freep>
 7be:	a02d                	j	7e8 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c0:	4618                	lw	a4,8(a2)
 7c2:	9f2d                	addw	a4,a4,a1
 7c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c8:	6398                	ld	a4,0(a5)
 7ca:	6310                	ld	a2,0(a4)
 7cc:	a83d                	j	80a <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ce:	ff852703          	lw	a4,-8(a0)
 7d2:	9f31                	addw	a4,a4,a2
 7d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d6:	ff053683          	ld	a3,-16(a0)
 7da:	a091                	j	81e <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e7e463          	bltu	a5,a4,7e6 <free+0x3c>
 7e2:	00e6ea63          	bltu	a3,a4,7f6 <free+0x4c>
{
 7e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	fed7fae3          	bgeu	a5,a3,7dc <free+0x32>
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e6e463          	bltu	a3,a4,7f6 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	fee7eae3          	bltu	a5,a4,7e6 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7f6:	ff852583          	lw	a1,-8(a0)
 7fa:	6390                	ld	a2,0(a5)
 7fc:	02059813          	slli	a6,a1,0x20
 800:	01c85713          	srli	a4,a6,0x1c
 804:	9736                	add	a4,a4,a3
 806:	fae60de3          	beq	a2,a4,7c0 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80e:	4790                	lw	a2,8(a5)
 810:	02061593          	slli	a1,a2,0x20
 814:	01c5d713          	srli	a4,a1,0x1c
 818:	973e                	add	a4,a4,a5
 81a:	fae68ae3          	beq	a3,a4,7ce <free+0x24>
    p->s.ptr = bp->s.ptr;
 81e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 820:	00001717          	auipc	a4,0x1
 824:	8af73023          	sd	a5,-1888(a4) # 10c0 <freep>
}
 828:	60a2                	ld	ra,8(sp)
 82a:	6402                	ld	s0,0(sp)
 82c:	0141                	addi	sp,sp,16
 82e:	8082                	ret

0000000000000830 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 830:	7139                	addi	sp,sp,-64
 832:	fc06                	sd	ra,56(sp)
 834:	f822                	sd	s0,48(sp)
 836:	f04a                	sd	s2,32(sp)
 838:	ec4e                	sd	s3,24(sp)
 83a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83c:	02051993          	slli	s3,a0,0x20
 840:	0209d993          	srli	s3,s3,0x20
 844:	09bd                	addi	s3,s3,15
 846:	0049d993          	srli	s3,s3,0x4
 84a:	2985                	addiw	s3,s3,1
 84c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 84e:	00001517          	auipc	a0,0x1
 852:	87253503          	ld	a0,-1934(a0) # 10c0 <freep>
 856:	c905                	beqz	a0,886 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 858:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85a:	4798                	lw	a4,8(a5)
 85c:	09377a63          	bgeu	a4,s3,8f0 <malloc+0xc0>
 860:	f426                	sd	s1,40(sp)
 862:	e852                	sd	s4,16(sp)
 864:	e456                	sd	s5,8(sp)
 866:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 868:	8a4e                	mv	s4,s3
 86a:	6705                	lui	a4,0x1
 86c:	00e9f363          	bgeu	s3,a4,872 <malloc+0x42>
 870:	6a05                	lui	s4,0x1
 872:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 876:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87a:	00001497          	auipc	s1,0x1
 87e:	84648493          	addi	s1,s1,-1978 # 10c0 <freep>
  if(p == (char*)-1)
 882:	5afd                	li	s5,-1
 884:	a089                	j	8c6 <malloc+0x96>
 886:	f426                	sd	s1,40(sp)
 888:	e852                	sd	s4,16(sp)
 88a:	e456                	sd	s5,8(sp)
 88c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 88e:	00001797          	auipc	a5,0x1
 892:	84278793          	addi	a5,a5,-1982 # 10d0 <base>
 896:	00001717          	auipc	a4,0x1
 89a:	82f73523          	sd	a5,-2006(a4) # 10c0 <freep>
 89e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a4:	b7d1                	j	868 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8a6:	6398                	ld	a4,0(a5)
 8a8:	e118                	sd	a4,0(a0)
 8aa:	a8b9                	j	908 <malloc+0xd8>
  hp->s.size = nu;
 8ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b0:	0541                	addi	a0,a0,16
 8b2:	00000097          	auipc	ra,0x0
 8b6:	ef8080e7          	jalr	-264(ra) # 7aa <free>
  return freep;
 8ba:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8bc:	c135                	beqz	a0,920 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c0:	4798                	lw	a4,8(a5)
 8c2:	03277363          	bgeu	a4,s2,8e8 <malloc+0xb8>
    if(p == freep)
 8c6:	6098                	ld	a4,0(s1)
 8c8:	853e                	mv	a0,a5
 8ca:	fef71ae3          	bne	a4,a5,8be <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	00000097          	auipc	ra,0x0
 8d4:	bb6080e7          	jalr	-1098(ra) # 486 <sbrk>
  if(p == (char*)-1)
 8d8:	fd551ae3          	bne	a0,s5,8ac <malloc+0x7c>
        return 0;
 8dc:	4501                	li	a0,0
 8de:	74a2                	ld	s1,40(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	a03d                	j	914 <malloc+0xe4>
 8e8:	74a2                	ld	s1,40(sp)
 8ea:	6a42                	ld	s4,16(sp)
 8ec:	6aa2                	ld	s5,8(sp)
 8ee:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8f0:	fae90be3          	beq	s2,a4,8a6 <malloc+0x76>
        p->s.size -= nunits;
 8f4:	4137073b          	subw	a4,a4,s3
 8f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fa:	02071693          	slli	a3,a4,0x20
 8fe:	01c6d713          	srli	a4,a3,0x1c
 902:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 904:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 908:	00000717          	auipc	a4,0x0
 90c:	7aa73c23          	sd	a0,1976(a4) # 10c0 <freep>
      return (void*)(p + 1);
 910:	01078513          	addi	a0,a5,16
  }
}
 914:	70e2                	ld	ra,56(sp)
 916:	7442                	ld	s0,48(sp)
 918:	7902                	ld	s2,32(sp)
 91a:	69e2                	ld	s3,24(sp)
 91c:	6121                	addi	sp,sp,64
 91e:	8082                	ret
 920:	74a2                	ld	s1,40(sp)
 922:	6a42                	ld	s4,16(sp)
 924:	6aa2                	ld	s5,8(sp)
 926:	6b02                	ld	s6,0(sp)
 928:	b7f5                	j	914 <malloc+0xe4>
