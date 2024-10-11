
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	ea8080e7          	jalr	-344(ra) # 5eb8 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	e96080e7          	jalr	-362(ra) # 5eb8 <open>
    if(fd >= 0){
      2a:	55fd                	li	a1,-1
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	37250513          	addi	a0,a0,882 # 63b0 <malloc+0x106>
      46:	00006097          	auipc	ra,0x6
      4a:	1a8080e7          	jalr	424(ra) # 61ee <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	e28080e7          	jalr	-472(ra) # 5e78 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	addi	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	addi	a3,a3,-1000 # cc78 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	35050513          	addi	a0,a0,848 # 63d0 <malloc+0x126>
      88:	00006097          	auipc	ra,0x6
      8c:	166080e7          	jalr	358(ra) # 61ee <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	de6080e7          	jalr	-538(ra) # 5e78 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	34050513          	addi	a0,a0,832 # 63e8 <malloc+0x13e>
      b0:	00006097          	auipc	ra,0x6
      b4:	e08080e7          	jalr	-504(ra) # 5eb8 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	de4080e7          	jalr	-540(ra) # 5ea0 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	34250513          	addi	a0,a0,834 # 6408 <malloc+0x15e>
      ce:	00006097          	auipc	ra,0x6
      d2:	dea080e7          	jalr	-534(ra) # 5eb8 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	30a50513          	addi	a0,a0,778 # 63f0 <malloc+0x146>
      ee:	00006097          	auipc	ra,0x6
      f2:	100080e7          	jalr	256(ra) # 61ee <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	d80080e7          	jalr	-640(ra) # 5e78 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	31650513          	addi	a0,a0,790 # 6418 <malloc+0x16e>
     10a:	00006097          	auipc	ra,0x6
     10e:	0e4080e7          	jalr	228(ra) # 61ee <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	d64080e7          	jalr	-668(ra) # 5e78 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	31450513          	addi	a0,a0,788 # 6440 <malloc+0x196>
     134:	00006097          	auipc	ra,0x6
     138:	d94080e7          	jalr	-620(ra) # 5ec8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	30050513          	addi	a0,a0,768 # 6440 <malloc+0x196>
     148:	00006097          	auipc	ra,0x6
     14c:	d70080e7          	jalr	-656(ra) # 5eb8 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	2fc58593          	addi	a1,a1,764 # 6450 <malloc+0x1a6>
     15c:	00006097          	auipc	ra,0x6
     160:	d3c080e7          	jalr	-708(ra) # 5e98 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	2d850513          	addi	a0,a0,728 # 6440 <malloc+0x196>
     170:	00006097          	auipc	ra,0x6
     174:	d48080e7          	jalr	-696(ra) # 5eb8 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	2dc58593          	addi	a1,a1,732 # 6458 <malloc+0x1ae>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	d12080e7          	jalr	-750(ra) # 5e98 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	2ac50513          	addi	a0,a0,684 # 6440 <malloc+0x196>
     19c:	00006097          	auipc	ra,0x6
     1a0:	d2c080e7          	jalr	-724(ra) # 5ec8 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	cfa080e7          	jalr	-774(ra) # 5ea0 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	cf0080e7          	jalr	-784(ra) # 5ea0 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	29650513          	addi	a0,a0,662 # 6460 <malloc+0x1b6>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	01c080e7          	jalr	28(ra) # 61ee <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	c9c080e7          	jalr	-868(ra) # 5e78 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7139                	addi	sp,sp,-64
     1e6:	fc06                	sd	ra,56(sp)
     1e8:	f822                	sd	s0,48(sp)
     1ea:	f426                	sd	s1,40(sp)
     1ec:	f04a                	sd	s2,32(sp)
     1ee:	ec4e                	sd	s3,24(sp)
     1f0:	e852                	sd	s4,16(sp)
     1f2:	0080                	addi	s0,sp,64
  name[0] = 'a';
     1f4:	06100793          	li	a5,97
     1f8:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     1fc:	fc040523          	sb	zero,-54(s0)
     200:	03000493          	li	s1,48
    fd = open(name, O_CREATE|O_RDWR);
     204:	fc840a13          	addi	s4,s0,-56
     208:	20200993          	li	s3,514
  for(i = 0; i < N; i++){
     20c:	06400913          	li	s2,100
    name[1] = '0' + i;
     210:	fc9404a3          	sb	s1,-55(s0)
    fd = open(name, O_CREATE|O_RDWR);
     214:	85ce                	mv	a1,s3
     216:	8552                	mv	a0,s4
     218:	00006097          	auipc	ra,0x6
     21c:	ca0080e7          	jalr	-864(ra) # 5eb8 <open>
    close(fd);
     220:	00006097          	auipc	ra,0x6
     224:	c80080e7          	jalr	-896(ra) # 5ea0 <close>
  for(i = 0; i < N; i++){
     228:	2485                	addiw	s1,s1,1
     22a:	0ff4f493          	zext.b	s1,s1
     22e:	ff2491e3          	bne	s1,s2,210 <createtest+0x2c>
  name[0] = 'a';
     232:	06100793          	li	a5,97
     236:	fcf40423          	sb	a5,-56(s0)
  name[2] = '\0';
     23a:	fc040523          	sb	zero,-54(s0)
     23e:	03000493          	li	s1,48
    unlink(name);
     242:	fc840993          	addi	s3,s0,-56
  for(i = 0; i < N; i++){
     246:	06400913          	li	s2,100
    name[1] = '0' + i;
     24a:	fc9404a3          	sb	s1,-55(s0)
    unlink(name);
     24e:	854e                	mv	a0,s3
     250:	00006097          	auipc	ra,0x6
     254:	c78080e7          	jalr	-904(ra) # 5ec8 <unlink>
  for(i = 0; i < N; i++){
     258:	2485                	addiw	s1,s1,1
     25a:	0ff4f493          	zext.b	s1,s1
     25e:	ff2496e3          	bne	s1,s2,24a <createtest+0x66>
}
     262:	70e2                	ld	ra,56(sp)
     264:	7442                	ld	s0,48(sp)
     266:	74a2                	ld	s1,40(sp)
     268:	7902                	ld	s2,32(sp)
     26a:	69e2                	ld	s3,24(sp)
     26c:	6a42                	ld	s4,16(sp)
     26e:	6121                	addi	sp,sp,64
     270:	8082                	ret

0000000000000272 <bigwrite>:
{
     272:	715d                	addi	sp,sp,-80
     274:	e486                	sd	ra,72(sp)
     276:	e0a2                	sd	s0,64(sp)
     278:	fc26                	sd	s1,56(sp)
     27a:	f84a                	sd	s2,48(sp)
     27c:	f44e                	sd	s3,40(sp)
     27e:	f052                	sd	s4,32(sp)
     280:	ec56                	sd	s5,24(sp)
     282:	e85a                	sd	s6,16(sp)
     284:	e45e                	sd	s7,8(sp)
     286:	e062                	sd	s8,0(sp)
     288:	0880                	addi	s0,sp,80
     28a:	8c2a                	mv	s8,a0
  unlink("bigwrite");
     28c:	00006517          	auipc	a0,0x6
     290:	1fc50513          	addi	a0,a0,508 # 6488 <malloc+0x1de>
     294:	00006097          	auipc	ra,0x6
     298:	c34080e7          	jalr	-972(ra) # 5ec8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     29c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a0:	20200b93          	li	s7,514
     2a4:	00006a97          	auipc	s5,0x6
     2a8:	1e4a8a93          	addi	s5,s5,484 # 6488 <malloc+0x1de>
      int cc = write(fd, buf, sz);
     2ac:	0000da17          	auipc	s4,0xd
     2b0:	9cca0a13          	addi	s4,s4,-1588 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <fourteen+0x61>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	85de                	mv	a1,s7
     2bc:	8556                	mv	a0,s5
     2be:	00006097          	auipc	ra,0x6
     2c2:	bfa080e7          	jalr	-1030(ra) # 5eb8 <open>
     2c6:	892a                	mv	s2,a0
    if(fd < 0){
     2c8:	04054e63          	bltz	a0,324 <bigwrite+0xb2>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	00006097          	auipc	ra,0x6
     2d4:	bc8080e7          	jalr	-1080(ra) # 5e98 <write>
     2d8:	89aa                	mv	s3,a0
      if(cc != sz){
     2da:	06a49363          	bne	s1,a0,340 <bigwrite+0xce>
      int cc = write(fd, buf, sz);
     2de:	8626                	mv	a2,s1
     2e0:	85d2                	mv	a1,s4
     2e2:	854a                	mv	a0,s2
     2e4:	00006097          	auipc	ra,0x6
     2e8:	bb4080e7          	jalr	-1100(ra) # 5e98 <write>
      if(cc != sz){
     2ec:	04951b63          	bne	a0,s1,342 <bigwrite+0xd0>
    close(fd);
     2f0:	854a                	mv	a0,s2
     2f2:	00006097          	auipc	ra,0x6
     2f6:	bae080e7          	jalr	-1106(ra) # 5ea0 <close>
    unlink("bigwrite");
     2fa:	8556                	mv	a0,s5
     2fc:	00006097          	auipc	ra,0x6
     300:	bcc080e7          	jalr	-1076(ra) # 5ec8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     304:	1d74849b          	addiw	s1,s1,471
     308:	fb6499e3          	bne	s1,s6,2ba <bigwrite+0x48>
}
     30c:	60a6                	ld	ra,72(sp)
     30e:	6406                	ld	s0,64(sp)
     310:	74e2                	ld	s1,56(sp)
     312:	7942                	ld	s2,48(sp)
     314:	79a2                	ld	s3,40(sp)
     316:	7a02                	ld	s4,32(sp)
     318:	6ae2                	ld	s5,24(sp)
     31a:	6b42                	ld	s6,16(sp)
     31c:	6ba2                	ld	s7,8(sp)
     31e:	6c02                	ld	s8,0(sp)
     320:	6161                	addi	sp,sp,80
     322:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     324:	85e2                	mv	a1,s8
     326:	00006517          	auipc	a0,0x6
     32a:	17250513          	addi	a0,a0,370 # 6498 <malloc+0x1ee>
     32e:	00006097          	auipc	ra,0x6
     332:	ec0080e7          	jalr	-320(ra) # 61ee <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00006097          	auipc	ra,0x6
     33c:	b40080e7          	jalr	-1216(ra) # 5e78 <exit>
      if(cc != sz){
     340:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     342:	86aa                	mv	a3,a0
     344:	864e                	mv	a2,s3
     346:	85e2                	mv	a1,s8
     348:	00006517          	auipc	a0,0x6
     34c:	17050513          	addi	a0,a0,368 # 64b8 <malloc+0x20e>
     350:	00006097          	auipc	ra,0x6
     354:	e9e080e7          	jalr	-354(ra) # 61ee <printf>
        exit(1);
     358:	4505                	li	a0,1
     35a:	00006097          	auipc	ra,0x6
     35e:	b1e080e7          	jalr	-1250(ra) # 5e78 <exit>

0000000000000362 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     362:	7139                	addi	sp,sp,-64
     364:	fc06                	sd	ra,56(sp)
     366:	f822                	sd	s0,48(sp)
     368:	f426                	sd	s1,40(sp)
     36a:	f04a                	sd	s2,32(sp)
     36c:	ec4e                	sd	s3,24(sp)
     36e:	e852                	sd	s4,16(sp)
     370:	e456                	sd	s5,8(sp)
     372:	e05a                	sd	s6,0(sp)
     374:	0080                	addi	s0,sp,64
  int assumed_free = 600;
  
  unlink("junk");
     376:	00006517          	auipc	a0,0x6
     37a:	15a50513          	addi	a0,a0,346 # 64d0 <malloc+0x226>
     37e:	00006097          	auipc	ra,0x6
     382:	b4a080e7          	jalr	-1206(ra) # 5ec8 <unlink>
     386:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     38a:	20100a93          	li	s5,513
     38e:	00006997          	auipc	s3,0x6
     392:	14298993          	addi	s3,s3,322 # 64d0 <malloc+0x226>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     396:	4b05                	li	s6,1
     398:	5a7d                	li	s4,-1
     39a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     39e:	85d6                	mv	a1,s5
     3a0:	854e                	mv	a0,s3
     3a2:	00006097          	auipc	ra,0x6
     3a6:	b16080e7          	jalr	-1258(ra) # 5eb8 <open>
     3aa:	84aa                	mv	s1,a0
    if(fd < 0){
     3ac:	06054b63          	bltz	a0,422 <badwrite+0xc0>
    write(fd, (char*)0xffffffffffL, 1);
     3b0:	865a                	mv	a2,s6
     3b2:	85d2                	mv	a1,s4
     3b4:	00006097          	auipc	ra,0x6
     3b8:	ae4080e7          	jalr	-1308(ra) # 5e98 <write>
    close(fd);
     3bc:	8526                	mv	a0,s1
     3be:	00006097          	auipc	ra,0x6
     3c2:	ae2080e7          	jalr	-1310(ra) # 5ea0 <close>
    unlink("junk");
     3c6:	854e                	mv	a0,s3
     3c8:	00006097          	auipc	ra,0x6
     3cc:	b00080e7          	jalr	-1280(ra) # 5ec8 <unlink>
  for(int i = 0; i < assumed_free; i++){
     3d0:	397d                	addiw	s2,s2,-1
     3d2:	fc0916e3          	bnez	s2,39e <badwrite+0x3c>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3d6:	20100593          	li	a1,513
     3da:	00006517          	auipc	a0,0x6
     3de:	0f650513          	addi	a0,a0,246 # 64d0 <malloc+0x226>
     3e2:	00006097          	auipc	ra,0x6
     3e6:	ad6080e7          	jalr	-1322(ra) # 5eb8 <open>
     3ea:	84aa                	mv	s1,a0
  if(fd < 0){
     3ec:	04054863          	bltz	a0,43c <badwrite+0xda>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3f0:	4605                	li	a2,1
     3f2:	00006597          	auipc	a1,0x6
     3f6:	06658593          	addi	a1,a1,102 # 6458 <malloc+0x1ae>
     3fa:	00006097          	auipc	ra,0x6
     3fe:	a9e080e7          	jalr	-1378(ra) # 5e98 <write>
     402:	4785                	li	a5,1
     404:	04f50963          	beq	a0,a5,456 <badwrite+0xf4>
    printf("write failed\n");
     408:	00006517          	auipc	a0,0x6
     40c:	0e850513          	addi	a0,a0,232 # 64f0 <malloc+0x246>
     410:	00006097          	auipc	ra,0x6
     414:	dde080e7          	jalr	-546(ra) # 61ee <printf>
    exit(1);
     418:	4505                	li	a0,1
     41a:	00006097          	auipc	ra,0x6
     41e:	a5e080e7          	jalr	-1442(ra) # 5e78 <exit>
      printf("open junk failed\n");
     422:	00006517          	auipc	a0,0x6
     426:	0b650513          	addi	a0,a0,182 # 64d8 <malloc+0x22e>
     42a:	00006097          	auipc	ra,0x6
     42e:	dc4080e7          	jalr	-572(ra) # 61ee <printf>
      exit(1);
     432:	4505                	li	a0,1
     434:	00006097          	auipc	ra,0x6
     438:	a44080e7          	jalr	-1468(ra) # 5e78 <exit>
    printf("open junk failed\n");
     43c:	00006517          	auipc	a0,0x6
     440:	09c50513          	addi	a0,a0,156 # 64d8 <malloc+0x22e>
     444:	00006097          	auipc	ra,0x6
     448:	daa080e7          	jalr	-598(ra) # 61ee <printf>
    exit(1);
     44c:	4505                	li	a0,1
     44e:	00006097          	auipc	ra,0x6
     452:	a2a080e7          	jalr	-1494(ra) # 5e78 <exit>
  }
  close(fd);
     456:	8526                	mv	a0,s1
     458:	00006097          	auipc	ra,0x6
     45c:	a48080e7          	jalr	-1464(ra) # 5ea0 <close>
  unlink("junk");
     460:	00006517          	auipc	a0,0x6
     464:	07050513          	addi	a0,a0,112 # 64d0 <malloc+0x226>
     468:	00006097          	auipc	ra,0x6
     46c:	a60080e7          	jalr	-1440(ra) # 5ec8 <unlink>

  exit(0);
     470:	4501                	li	a0,0
     472:	00006097          	auipc	ra,0x6
     476:	a06080e7          	jalr	-1530(ra) # 5e78 <exit>

000000000000047a <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     47a:	711d                	addi	sp,sp,-96
     47c:	ec86                	sd	ra,88(sp)
     47e:	e8a2                	sd	s0,80(sp)
     480:	e4a6                	sd	s1,72(sp)
     482:	e0ca                	sd	s2,64(sp)
     484:	fc4e                	sd	s3,56(sp)
     486:	f852                	sd	s4,48(sp)
     488:	f456                	sd	s5,40(sp)
     48a:	1080                	addi	s0,sp,96
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     48c:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     48e:	07a00993          	li	s3,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     492:	fa040913          	addi	s2,s0,-96
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     496:	60200a13          	li	s4,1538
  for(int i = 0; i < nzz; i++){
     49a:	40000a93          	li	s5,1024
    name[0] = 'z';
     49e:	fb340023          	sb	s3,-96(s0)
    name[1] = 'z';
     4a2:	fb3400a3          	sb	s3,-95(s0)
    name[2] = '0' + (i / 32);
     4a6:	41f4d71b          	sraiw	a4,s1,0x1f
     4aa:	01b7571b          	srliw	a4,a4,0x1b
     4ae:	009707bb          	addw	a5,a4,s1
     4b2:	4057d69b          	sraiw	a3,a5,0x5
     4b6:	0306869b          	addiw	a3,a3,48
     4ba:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     4be:	8bfd                	andi	a5,a5,31
     4c0:	9f99                	subw	a5,a5,a4
     4c2:	0307879b          	addiw	a5,a5,48
     4c6:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     4ca:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     4ce:	854a                	mv	a0,s2
     4d0:	00006097          	auipc	ra,0x6
     4d4:	9f8080e7          	jalr	-1544(ra) # 5ec8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4d8:	85d2                	mv	a1,s4
     4da:	854a                	mv	a0,s2
     4dc:	00006097          	auipc	ra,0x6
     4e0:	9dc080e7          	jalr	-1572(ra) # 5eb8 <open>
    if(fd < 0){
     4e4:	00054963          	bltz	a0,4f6 <outofinodes+0x7c>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4e8:	00006097          	auipc	ra,0x6
     4ec:	9b8080e7          	jalr	-1608(ra) # 5ea0 <close>
  for(int i = 0; i < nzz; i++){
     4f0:	2485                	addiw	s1,s1,1
     4f2:	fb5496e3          	bne	s1,s5,49e <outofinodes+0x24>
     4f6:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4f8:	07a00913          	li	s2,122
    name[1] = 'z';
    name[2] = '0' + (i / 32);
    name[3] = '0' + (i % 32);
    name[4] = '\0';
    unlink(name);
     4fc:	fa040a13          	addi	s4,s0,-96
  for(int i = 0; i < nzz; i++){
     500:	40000993          	li	s3,1024
    name[0] = 'z';
     504:	fb240023          	sb	s2,-96(s0)
    name[1] = 'z';
     508:	fb2400a3          	sb	s2,-95(s0)
    name[2] = '0' + (i / 32);
     50c:	41f4d71b          	sraiw	a4,s1,0x1f
     510:	01b7571b          	srliw	a4,a4,0x1b
     514:	009707bb          	addw	a5,a4,s1
     518:	4057d69b          	sraiw	a3,a5,0x5
     51c:	0306869b          	addiw	a3,a3,48
     520:	fad40123          	sb	a3,-94(s0)
    name[3] = '0' + (i % 32);
     524:	8bfd                	andi	a5,a5,31
     526:	9f99                	subw	a5,a5,a4
     528:	0307879b          	addiw	a5,a5,48
     52c:	faf401a3          	sb	a5,-93(s0)
    name[4] = '\0';
     530:	fa040223          	sb	zero,-92(s0)
    unlink(name);
     534:	8552                	mv	a0,s4
     536:	00006097          	auipc	ra,0x6
     53a:	992080e7          	jalr	-1646(ra) # 5ec8 <unlink>
  for(int i = 0; i < nzz; i++){
     53e:	2485                	addiw	s1,s1,1
     540:	fd3492e3          	bne	s1,s3,504 <outofinodes+0x8a>
  }
}
     544:	60e6                	ld	ra,88(sp)
     546:	6446                	ld	s0,80(sp)
     548:	64a6                	ld	s1,72(sp)
     54a:	6906                	ld	s2,64(sp)
     54c:	79e2                	ld	s3,56(sp)
     54e:	7a42                	ld	s4,48(sp)
     550:	7aa2                	ld	s5,40(sp)
     552:	6125                	addi	sp,sp,96
     554:	8082                	ret

0000000000000556 <copyin>:
{
     556:	7159                	addi	sp,sp,-112
     558:	f486                	sd	ra,104(sp)
     55a:	f0a2                	sd	s0,96(sp)
     55c:	eca6                	sd	s1,88(sp)
     55e:	e8ca                	sd	s2,80(sp)
     560:	e4ce                	sd	s3,72(sp)
     562:	e0d2                	sd	s4,64(sp)
     564:	fc56                	sd	s5,56(sp)
     566:	f85a                	sd	s6,48(sp)
     568:	f45e                	sd	s7,40(sp)
     56a:	f062                	sd	s8,32(sp)
     56c:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     56e:	4785                	li	a5,1
     570:	07fe                	slli	a5,a5,0x1f
     572:	faf43023          	sd	a5,-96(s0)
     576:	57fd                	li	a5,-1
     578:	faf43423          	sd	a5,-88(s0)
  for(int ai = 0; ai < 2; ai++){
     57c:	fa040913          	addi	s2,s0,-96
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     580:	20100b93          	li	s7,513
     584:	00006a97          	auipc	s5,0x6
     588:	f7ca8a93          	addi	s5,s5,-132 # 6500 <malloc+0x256>
    int n = write(fd, (void*)addr, 8192);
     58c:	6a09                	lui	s4,0x2
    n = write(1, (char*)addr, 8192);
     58e:	4b05                	li	s6,1
    if(pipe(fds) < 0){
     590:	f9840c13          	addi	s8,s0,-104
    uint64 addr = addrs[ai];
     594:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     598:	85de                	mv	a1,s7
     59a:	8556                	mv	a0,s5
     59c:	00006097          	auipc	ra,0x6
     5a0:	91c080e7          	jalr	-1764(ra) # 5eb8 <open>
     5a4:	84aa                	mv	s1,a0
    if(fd < 0){
     5a6:	08054b63          	bltz	a0,63c <copyin+0xe6>
    int n = write(fd, (void*)addr, 8192);
     5aa:	8652                	mv	a2,s4
     5ac:	85ce                	mv	a1,s3
     5ae:	00006097          	auipc	ra,0x6
     5b2:	8ea080e7          	jalr	-1814(ra) # 5e98 <write>
    if(n >= 0){
     5b6:	0a055063          	bgez	a0,656 <copyin+0x100>
    close(fd);
     5ba:	8526                	mv	a0,s1
     5bc:	00006097          	auipc	ra,0x6
     5c0:	8e4080e7          	jalr	-1820(ra) # 5ea0 <close>
    unlink("copyin1");
     5c4:	8556                	mv	a0,s5
     5c6:	00006097          	auipc	ra,0x6
     5ca:	902080e7          	jalr	-1790(ra) # 5ec8 <unlink>
    n = write(1, (char*)addr, 8192);
     5ce:	8652                	mv	a2,s4
     5d0:	85ce                	mv	a1,s3
     5d2:	855a                	mv	a0,s6
     5d4:	00006097          	auipc	ra,0x6
     5d8:	8c4080e7          	jalr	-1852(ra) # 5e98 <write>
    if(n > 0){
     5dc:	08a04c63          	bgtz	a0,674 <copyin+0x11e>
    if(pipe(fds) < 0){
     5e0:	8562                	mv	a0,s8
     5e2:	00006097          	auipc	ra,0x6
     5e6:	8a6080e7          	jalr	-1882(ra) # 5e88 <pipe>
     5ea:	0a054463          	bltz	a0,692 <copyin+0x13c>
    n = write(fds[1], (char*)addr, 8192);
     5ee:	8652                	mv	a2,s4
     5f0:	85ce                	mv	a1,s3
     5f2:	f9c42503          	lw	a0,-100(s0)
     5f6:	00006097          	auipc	ra,0x6
     5fa:	8a2080e7          	jalr	-1886(ra) # 5e98 <write>
    if(n > 0){
     5fe:	0aa04763          	bgtz	a0,6ac <copyin+0x156>
    close(fds[0]);
     602:	f9842503          	lw	a0,-104(s0)
     606:	00006097          	auipc	ra,0x6
     60a:	89a080e7          	jalr	-1894(ra) # 5ea0 <close>
    close(fds[1]);
     60e:	f9c42503          	lw	a0,-100(s0)
     612:	00006097          	auipc	ra,0x6
     616:	88e080e7          	jalr	-1906(ra) # 5ea0 <close>
  for(int ai = 0; ai < 2; ai++){
     61a:	0921                	addi	s2,s2,8
     61c:	fb040793          	addi	a5,s0,-80
     620:	f6f91ae3          	bne	s2,a5,594 <copyin+0x3e>
}
     624:	70a6                	ld	ra,104(sp)
     626:	7406                	ld	s0,96(sp)
     628:	64e6                	ld	s1,88(sp)
     62a:	6946                	ld	s2,80(sp)
     62c:	69a6                	ld	s3,72(sp)
     62e:	6a06                	ld	s4,64(sp)
     630:	7ae2                	ld	s5,56(sp)
     632:	7b42                	ld	s6,48(sp)
     634:	7ba2                	ld	s7,40(sp)
     636:	7c02                	ld	s8,32(sp)
     638:	6165                	addi	sp,sp,112
     63a:	8082                	ret
      printf("open(copyin1) failed\n");
     63c:	00006517          	auipc	a0,0x6
     640:	ecc50513          	addi	a0,a0,-308 # 6508 <malloc+0x25e>
     644:	00006097          	auipc	ra,0x6
     648:	baa080e7          	jalr	-1110(ra) # 61ee <printf>
      exit(1);
     64c:	4505                	li	a0,1
     64e:	00006097          	auipc	ra,0x6
     652:	82a080e7          	jalr	-2006(ra) # 5e78 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     656:	862a                	mv	a2,a0
     658:	85ce                	mv	a1,s3
     65a:	00006517          	auipc	a0,0x6
     65e:	ec650513          	addi	a0,a0,-314 # 6520 <malloc+0x276>
     662:	00006097          	auipc	ra,0x6
     666:	b8c080e7          	jalr	-1140(ra) # 61ee <printf>
      exit(1);
     66a:	4505                	li	a0,1
     66c:	00006097          	auipc	ra,0x6
     670:	80c080e7          	jalr	-2036(ra) # 5e78 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     674:	862a                	mv	a2,a0
     676:	85ce                	mv	a1,s3
     678:	00006517          	auipc	a0,0x6
     67c:	ed850513          	addi	a0,a0,-296 # 6550 <malloc+0x2a6>
     680:	00006097          	auipc	ra,0x6
     684:	b6e080e7          	jalr	-1170(ra) # 61ee <printf>
      exit(1);
     688:	4505                	li	a0,1
     68a:	00005097          	auipc	ra,0x5
     68e:	7ee080e7          	jalr	2030(ra) # 5e78 <exit>
      printf("pipe() failed\n");
     692:	00006517          	auipc	a0,0x6
     696:	eee50513          	addi	a0,a0,-274 # 6580 <malloc+0x2d6>
     69a:	00006097          	auipc	ra,0x6
     69e:	b54080e7          	jalr	-1196(ra) # 61ee <printf>
      exit(1);
     6a2:	4505                	li	a0,1
     6a4:	00005097          	auipc	ra,0x5
     6a8:	7d4080e7          	jalr	2004(ra) # 5e78 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     6ac:	862a                	mv	a2,a0
     6ae:	85ce                	mv	a1,s3
     6b0:	00006517          	auipc	a0,0x6
     6b4:	ee050513          	addi	a0,a0,-288 # 6590 <malloc+0x2e6>
     6b8:	00006097          	auipc	ra,0x6
     6bc:	b36080e7          	jalr	-1226(ra) # 61ee <printf>
      exit(1);
     6c0:	4505                	li	a0,1
     6c2:	00005097          	auipc	ra,0x5
     6c6:	7b6080e7          	jalr	1974(ra) # 5e78 <exit>

00000000000006ca <copyout>:
{
     6ca:	7159                	addi	sp,sp,-112
     6cc:	f486                	sd	ra,104(sp)
     6ce:	f0a2                	sd	s0,96(sp)
     6d0:	eca6                	sd	s1,88(sp)
     6d2:	e8ca                	sd	s2,80(sp)
     6d4:	e4ce                	sd	s3,72(sp)
     6d6:	e0d2                	sd	s4,64(sp)
     6d8:	fc56                	sd	s5,56(sp)
     6da:	f85a                	sd	s6,48(sp)
     6dc:	f45e                	sd	s7,40(sp)
     6de:	f062                	sd	s8,32(sp)
     6e0:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     6e2:	4785                	li	a5,1
     6e4:	07fe                	slli	a5,a5,0x1f
     6e6:	faf43023          	sd	a5,-96(s0)
     6ea:	57fd                	li	a5,-1
     6ec:	faf43423          	sd	a5,-88(s0)
  for(int ai = 0; ai < 2; ai++){
     6f0:	fa040913          	addi	s2,s0,-96
    int fd = open("README", 0);
     6f4:	00006b97          	auipc	s7,0x6
     6f8:	eccb8b93          	addi	s7,s7,-308 # 65c0 <malloc+0x316>
    int n = read(fd, (void*)addr, 8192);
     6fc:	6a09                	lui	s4,0x2
    if(pipe(fds) < 0){
     6fe:	f9840b13          	addi	s6,s0,-104
    n = write(fds[1], "x", 1);
     702:	4a85                	li	s5,1
     704:	00006c17          	auipc	s8,0x6
     708:	d54c0c13          	addi	s8,s8,-684 # 6458 <malloc+0x1ae>
    uint64 addr = addrs[ai];
     70c:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     710:	4581                	li	a1,0
     712:	855e                	mv	a0,s7
     714:	00005097          	auipc	ra,0x5
     718:	7a4080e7          	jalr	1956(ra) # 5eb8 <open>
     71c:	84aa                	mv	s1,a0
    if(fd < 0){
     71e:	08054763          	bltz	a0,7ac <copyout+0xe2>
    int n = read(fd, (void*)addr, 8192);
     722:	8652                	mv	a2,s4
     724:	85ce                	mv	a1,s3
     726:	00005097          	auipc	ra,0x5
     72a:	76a080e7          	jalr	1898(ra) # 5e90 <read>
    if(n > 0){
     72e:	08a04c63          	bgtz	a0,7c6 <copyout+0xfc>
    close(fd);
     732:	8526                	mv	a0,s1
     734:	00005097          	auipc	ra,0x5
     738:	76c080e7          	jalr	1900(ra) # 5ea0 <close>
    if(pipe(fds) < 0){
     73c:	855a                	mv	a0,s6
     73e:	00005097          	auipc	ra,0x5
     742:	74a080e7          	jalr	1866(ra) # 5e88 <pipe>
     746:	08054f63          	bltz	a0,7e4 <copyout+0x11a>
    n = write(fds[1], "x", 1);
     74a:	8656                	mv	a2,s5
     74c:	85e2                	mv	a1,s8
     74e:	f9c42503          	lw	a0,-100(s0)
     752:	00005097          	auipc	ra,0x5
     756:	746080e7          	jalr	1862(ra) # 5e98 <write>
    if(n != 1){
     75a:	0b551263          	bne	a0,s5,7fe <copyout+0x134>
    n = read(fds[0], (void*)addr, 8192);
     75e:	8652                	mv	a2,s4
     760:	85ce                	mv	a1,s3
     762:	f9842503          	lw	a0,-104(s0)
     766:	00005097          	auipc	ra,0x5
     76a:	72a080e7          	jalr	1834(ra) # 5e90 <read>
    if(n > 0){
     76e:	0aa04563          	bgtz	a0,818 <copyout+0x14e>
    close(fds[0]);
     772:	f9842503          	lw	a0,-104(s0)
     776:	00005097          	auipc	ra,0x5
     77a:	72a080e7          	jalr	1834(ra) # 5ea0 <close>
    close(fds[1]);
     77e:	f9c42503          	lw	a0,-100(s0)
     782:	00005097          	auipc	ra,0x5
     786:	71e080e7          	jalr	1822(ra) # 5ea0 <close>
  for(int ai = 0; ai < 2; ai++){
     78a:	0921                	addi	s2,s2,8
     78c:	fb040793          	addi	a5,s0,-80
     790:	f6f91ee3          	bne	s2,a5,70c <copyout+0x42>
}
     794:	70a6                	ld	ra,104(sp)
     796:	7406                	ld	s0,96(sp)
     798:	64e6                	ld	s1,88(sp)
     79a:	6946                	ld	s2,80(sp)
     79c:	69a6                	ld	s3,72(sp)
     79e:	6a06                	ld	s4,64(sp)
     7a0:	7ae2                	ld	s5,56(sp)
     7a2:	7b42                	ld	s6,48(sp)
     7a4:	7ba2                	ld	s7,40(sp)
     7a6:	7c02                	ld	s8,32(sp)
     7a8:	6165                	addi	sp,sp,112
     7aa:	8082                	ret
      printf("open(README) failed\n");
     7ac:	00006517          	auipc	a0,0x6
     7b0:	e1c50513          	addi	a0,a0,-484 # 65c8 <malloc+0x31e>
     7b4:	00006097          	auipc	ra,0x6
     7b8:	a3a080e7          	jalr	-1478(ra) # 61ee <printf>
      exit(1);
     7bc:	4505                	li	a0,1
     7be:	00005097          	auipc	ra,0x5
     7c2:	6ba080e7          	jalr	1722(ra) # 5e78 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7c6:	862a                	mv	a2,a0
     7c8:	85ce                	mv	a1,s3
     7ca:	00006517          	auipc	a0,0x6
     7ce:	e1650513          	addi	a0,a0,-490 # 65e0 <malloc+0x336>
     7d2:	00006097          	auipc	ra,0x6
     7d6:	a1c080e7          	jalr	-1508(ra) # 61ee <printf>
      exit(1);
     7da:	4505                	li	a0,1
     7dc:	00005097          	auipc	ra,0x5
     7e0:	69c080e7          	jalr	1692(ra) # 5e78 <exit>
      printf("pipe() failed\n");
     7e4:	00006517          	auipc	a0,0x6
     7e8:	d9c50513          	addi	a0,a0,-612 # 6580 <malloc+0x2d6>
     7ec:	00006097          	auipc	ra,0x6
     7f0:	a02080e7          	jalr	-1534(ra) # 61ee <printf>
      exit(1);
     7f4:	4505                	li	a0,1
     7f6:	00005097          	auipc	ra,0x5
     7fa:	682080e7          	jalr	1666(ra) # 5e78 <exit>
      printf("pipe write failed\n");
     7fe:	00006517          	auipc	a0,0x6
     802:	e1250513          	addi	a0,a0,-494 # 6610 <malloc+0x366>
     806:	00006097          	auipc	ra,0x6
     80a:	9e8080e7          	jalr	-1560(ra) # 61ee <printf>
      exit(1);
     80e:	4505                	li	a0,1
     810:	00005097          	auipc	ra,0x5
     814:	668080e7          	jalr	1640(ra) # 5e78 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     818:	862a                	mv	a2,a0
     81a:	85ce                	mv	a1,s3
     81c:	00006517          	auipc	a0,0x6
     820:	e0c50513          	addi	a0,a0,-500 # 6628 <malloc+0x37e>
     824:	00006097          	auipc	ra,0x6
     828:	9ca080e7          	jalr	-1590(ra) # 61ee <printf>
      exit(1);
     82c:	4505                	li	a0,1
     82e:	00005097          	auipc	ra,0x5
     832:	64a080e7          	jalr	1610(ra) # 5e78 <exit>

0000000000000836 <truncate1>:
{
     836:	711d                	addi	sp,sp,-96
     838:	ec86                	sd	ra,88(sp)
     83a:	e8a2                	sd	s0,80(sp)
     83c:	e4a6                	sd	s1,72(sp)
     83e:	e0ca                	sd	s2,64(sp)
     840:	fc4e                	sd	s3,56(sp)
     842:	f852                	sd	s4,48(sp)
     844:	f456                	sd	s5,40(sp)
     846:	1080                	addi	s0,sp,96
     848:	8aaa                	mv	s5,a0
  unlink("truncfile");
     84a:	00006517          	auipc	a0,0x6
     84e:	bf650513          	addi	a0,a0,-1034 # 6440 <malloc+0x196>
     852:	00005097          	auipc	ra,0x5
     856:	676080e7          	jalr	1654(ra) # 5ec8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     85a:	60100593          	li	a1,1537
     85e:	00006517          	auipc	a0,0x6
     862:	be250513          	addi	a0,a0,-1054 # 6440 <malloc+0x196>
     866:	00005097          	auipc	ra,0x5
     86a:	652080e7          	jalr	1618(ra) # 5eb8 <open>
     86e:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     870:	4611                	li	a2,4
     872:	00006597          	auipc	a1,0x6
     876:	bde58593          	addi	a1,a1,-1058 # 6450 <malloc+0x1a6>
     87a:	00005097          	auipc	ra,0x5
     87e:	61e080e7          	jalr	1566(ra) # 5e98 <write>
  close(fd1);
     882:	8526                	mv	a0,s1
     884:	00005097          	auipc	ra,0x5
     888:	61c080e7          	jalr	1564(ra) # 5ea0 <close>
  int fd2 = open("truncfile", O_RDONLY);
     88c:	4581                	li	a1,0
     88e:	00006517          	auipc	a0,0x6
     892:	bb250513          	addi	a0,a0,-1102 # 6440 <malloc+0x196>
     896:	00005097          	auipc	ra,0x5
     89a:	622080e7          	jalr	1570(ra) # 5eb8 <open>
     89e:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     8a0:	02000613          	li	a2,32
     8a4:	fa040593          	addi	a1,s0,-96
     8a8:	00005097          	auipc	ra,0x5
     8ac:	5e8080e7          	jalr	1512(ra) # 5e90 <read>
  if(n != 4){
     8b0:	4791                	li	a5,4
     8b2:	0cf51e63          	bne	a0,a5,98e <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     8b6:	40100593          	li	a1,1025
     8ba:	00006517          	auipc	a0,0x6
     8be:	b8650513          	addi	a0,a0,-1146 # 6440 <malloc+0x196>
     8c2:	00005097          	auipc	ra,0x5
     8c6:	5f6080e7          	jalr	1526(ra) # 5eb8 <open>
     8ca:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     8cc:	4581                	li	a1,0
     8ce:	00006517          	auipc	a0,0x6
     8d2:	b7250513          	addi	a0,a0,-1166 # 6440 <malloc+0x196>
     8d6:	00005097          	auipc	ra,0x5
     8da:	5e2080e7          	jalr	1506(ra) # 5eb8 <open>
     8de:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     8e0:	02000613          	li	a2,32
     8e4:	fa040593          	addi	a1,s0,-96
     8e8:	00005097          	auipc	ra,0x5
     8ec:	5a8080e7          	jalr	1448(ra) # 5e90 <read>
     8f0:	8a2a                	mv	s4,a0
  if(n != 0){
     8f2:	ed4d                	bnez	a0,9ac <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8f4:	02000613          	li	a2,32
     8f8:	fa040593          	addi	a1,s0,-96
     8fc:	8526                	mv	a0,s1
     8fe:	00005097          	auipc	ra,0x5
     902:	592080e7          	jalr	1426(ra) # 5e90 <read>
     906:	8a2a                	mv	s4,a0
  if(n != 0){
     908:	e971                	bnez	a0,9dc <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     90a:	4619                	li	a2,6
     90c:	00006597          	auipc	a1,0x6
     910:	dac58593          	addi	a1,a1,-596 # 66b8 <malloc+0x40e>
     914:	854e                	mv	a0,s3
     916:	00005097          	auipc	ra,0x5
     91a:	582080e7          	jalr	1410(ra) # 5e98 <write>
  n = read(fd3, buf, sizeof(buf));
     91e:	02000613          	li	a2,32
     922:	fa040593          	addi	a1,s0,-96
     926:	854a                	mv	a0,s2
     928:	00005097          	auipc	ra,0x5
     92c:	568080e7          	jalr	1384(ra) # 5e90 <read>
  if(n != 6){
     930:	4799                	li	a5,6
     932:	0cf51d63          	bne	a0,a5,a0c <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     936:	02000613          	li	a2,32
     93a:	fa040593          	addi	a1,s0,-96
     93e:	8526                	mv	a0,s1
     940:	00005097          	auipc	ra,0x5
     944:	550080e7          	jalr	1360(ra) # 5e90 <read>
  if(n != 2){
     948:	4789                	li	a5,2
     94a:	0ef51063          	bne	a0,a5,a2a <truncate1+0x1f4>
  unlink("truncfile");
     94e:	00006517          	auipc	a0,0x6
     952:	af250513          	addi	a0,a0,-1294 # 6440 <malloc+0x196>
     956:	00005097          	auipc	ra,0x5
     95a:	572080e7          	jalr	1394(ra) # 5ec8 <unlink>
  close(fd1);
     95e:	854e                	mv	a0,s3
     960:	00005097          	auipc	ra,0x5
     964:	540080e7          	jalr	1344(ra) # 5ea0 <close>
  close(fd2);
     968:	8526                	mv	a0,s1
     96a:	00005097          	auipc	ra,0x5
     96e:	536080e7          	jalr	1334(ra) # 5ea0 <close>
  close(fd3);
     972:	854a                	mv	a0,s2
     974:	00005097          	auipc	ra,0x5
     978:	52c080e7          	jalr	1324(ra) # 5ea0 <close>
}
     97c:	60e6                	ld	ra,88(sp)
     97e:	6446                	ld	s0,80(sp)
     980:	64a6                	ld	s1,72(sp)
     982:	6906                	ld	s2,64(sp)
     984:	79e2                	ld	s3,56(sp)
     986:	7a42                	ld	s4,48(sp)
     988:	7aa2                	ld	s5,40(sp)
     98a:	6125                	addi	sp,sp,96
     98c:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     98e:	862a                	mv	a2,a0
     990:	85d6                	mv	a1,s5
     992:	00006517          	auipc	a0,0x6
     996:	cc650513          	addi	a0,a0,-826 # 6658 <malloc+0x3ae>
     99a:	00006097          	auipc	ra,0x6
     99e:	854080e7          	jalr	-1964(ra) # 61ee <printf>
    exit(1);
     9a2:	4505                	li	a0,1
     9a4:	00005097          	auipc	ra,0x5
     9a8:	4d4080e7          	jalr	1236(ra) # 5e78 <exit>
    printf("aaa fd3=%d\n", fd3);
     9ac:	85ca                	mv	a1,s2
     9ae:	00006517          	auipc	a0,0x6
     9b2:	cca50513          	addi	a0,a0,-822 # 6678 <malloc+0x3ce>
     9b6:	00006097          	auipc	ra,0x6
     9ba:	838080e7          	jalr	-1992(ra) # 61ee <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9be:	8652                	mv	a2,s4
     9c0:	85d6                	mv	a1,s5
     9c2:	00006517          	auipc	a0,0x6
     9c6:	cc650513          	addi	a0,a0,-826 # 6688 <malloc+0x3de>
     9ca:	00006097          	auipc	ra,0x6
     9ce:	824080e7          	jalr	-2012(ra) # 61ee <printf>
    exit(1);
     9d2:	4505                	li	a0,1
     9d4:	00005097          	auipc	ra,0x5
     9d8:	4a4080e7          	jalr	1188(ra) # 5e78 <exit>
    printf("bbb fd2=%d\n", fd2);
     9dc:	85a6                	mv	a1,s1
     9de:	00006517          	auipc	a0,0x6
     9e2:	cca50513          	addi	a0,a0,-822 # 66a8 <malloc+0x3fe>
     9e6:	00006097          	auipc	ra,0x6
     9ea:	808080e7          	jalr	-2040(ra) # 61ee <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9ee:	8652                	mv	a2,s4
     9f0:	85d6                	mv	a1,s5
     9f2:	00006517          	auipc	a0,0x6
     9f6:	c9650513          	addi	a0,a0,-874 # 6688 <malloc+0x3de>
     9fa:	00005097          	auipc	ra,0x5
     9fe:	7f4080e7          	jalr	2036(ra) # 61ee <printf>
    exit(1);
     a02:	4505                	li	a0,1
     a04:	00005097          	auipc	ra,0x5
     a08:	474080e7          	jalr	1140(ra) # 5e78 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     a0c:	862a                	mv	a2,a0
     a0e:	85d6                	mv	a1,s5
     a10:	00006517          	auipc	a0,0x6
     a14:	cb050513          	addi	a0,a0,-848 # 66c0 <malloc+0x416>
     a18:	00005097          	auipc	ra,0x5
     a1c:	7d6080e7          	jalr	2006(ra) # 61ee <printf>
    exit(1);
     a20:	4505                	li	a0,1
     a22:	00005097          	auipc	ra,0x5
     a26:	456080e7          	jalr	1110(ra) # 5e78 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     a2a:	862a                	mv	a2,a0
     a2c:	85d6                	mv	a1,s5
     a2e:	00006517          	auipc	a0,0x6
     a32:	cb250513          	addi	a0,a0,-846 # 66e0 <malloc+0x436>
     a36:	00005097          	auipc	ra,0x5
     a3a:	7b8080e7          	jalr	1976(ra) # 61ee <printf>
    exit(1);
     a3e:	4505                	li	a0,1
     a40:	00005097          	auipc	ra,0x5
     a44:	438080e7          	jalr	1080(ra) # 5e78 <exit>

0000000000000a48 <writetest>:
{
     a48:	715d                	addi	sp,sp,-80
     a4a:	e486                	sd	ra,72(sp)
     a4c:	e0a2                	sd	s0,64(sp)
     a4e:	fc26                	sd	s1,56(sp)
     a50:	f84a                	sd	s2,48(sp)
     a52:	f44e                	sd	s3,40(sp)
     a54:	f052                	sd	s4,32(sp)
     a56:	ec56                	sd	s5,24(sp)
     a58:	e85a                	sd	s6,16(sp)
     a5a:	e45e                	sd	s7,8(sp)
     a5c:	0880                	addi	s0,sp,80
     a5e:	8baa                	mv	s7,a0
  fd = open("small", O_CREATE|O_RDWR);
     a60:	20200593          	li	a1,514
     a64:	00006517          	auipc	a0,0x6
     a68:	c9c50513          	addi	a0,a0,-868 # 6700 <malloc+0x456>
     a6c:	00005097          	auipc	ra,0x5
     a70:	44c080e7          	jalr	1100(ra) # 5eb8 <open>
  if(fd < 0){
     a74:	0a054d63          	bltz	a0,b2e <writetest+0xe6>
     a78:	89aa                	mv	s3,a0
     a7a:	4901                	li	s2,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a7c:	44a9                	li	s1,10
     a7e:	00006a17          	auipc	s4,0x6
     a82:	caaa0a13          	addi	s4,s4,-854 # 6728 <malloc+0x47e>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a86:	00006b17          	auipc	s6,0x6
     a8a:	cdab0b13          	addi	s6,s6,-806 # 6760 <malloc+0x4b6>
  for(i = 0; i < N; i++){
     a8e:	06400a93          	li	s5,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a92:	8626                	mv	a2,s1
     a94:	85d2                	mv	a1,s4
     a96:	854e                	mv	a0,s3
     a98:	00005097          	auipc	ra,0x5
     a9c:	400080e7          	jalr	1024(ra) # 5e98 <write>
     aa0:	0a951563          	bne	a0,s1,b4a <writetest+0x102>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     aa4:	8626                	mv	a2,s1
     aa6:	85da                	mv	a1,s6
     aa8:	854e                	mv	a0,s3
     aaa:	00005097          	auipc	ra,0x5
     aae:	3ee080e7          	jalr	1006(ra) # 5e98 <write>
     ab2:	0a951b63          	bne	a0,s1,b68 <writetest+0x120>
  for(i = 0; i < N; i++){
     ab6:	2905                	addiw	s2,s2,1
     ab8:	fd591de3          	bne	s2,s5,a92 <writetest+0x4a>
  close(fd);
     abc:	854e                	mv	a0,s3
     abe:	00005097          	auipc	ra,0x5
     ac2:	3e2080e7          	jalr	994(ra) # 5ea0 <close>
  fd = open("small", O_RDONLY);
     ac6:	4581                	li	a1,0
     ac8:	00006517          	auipc	a0,0x6
     acc:	c3850513          	addi	a0,a0,-968 # 6700 <malloc+0x456>
     ad0:	00005097          	auipc	ra,0x5
     ad4:	3e8080e7          	jalr	1000(ra) # 5eb8 <open>
     ad8:	84aa                	mv	s1,a0
  if(fd < 0){
     ada:	0a054663          	bltz	a0,b86 <writetest+0x13e>
  i = read(fd, buf, N*SZ*2);
     ade:	7d000613          	li	a2,2000
     ae2:	0000c597          	auipc	a1,0xc
     ae6:	19658593          	addi	a1,a1,406 # cc78 <buf>
     aea:	00005097          	auipc	ra,0x5
     aee:	3a6080e7          	jalr	934(ra) # 5e90 <read>
  if(i != N*SZ*2){
     af2:	7d000793          	li	a5,2000
     af6:	0af51663          	bne	a0,a5,ba2 <writetest+0x15a>
  close(fd);
     afa:	8526                	mv	a0,s1
     afc:	00005097          	auipc	ra,0x5
     b00:	3a4080e7          	jalr	932(ra) # 5ea0 <close>
  if(unlink("small") < 0){
     b04:	00006517          	auipc	a0,0x6
     b08:	bfc50513          	addi	a0,a0,-1028 # 6700 <malloc+0x456>
     b0c:	00005097          	auipc	ra,0x5
     b10:	3bc080e7          	jalr	956(ra) # 5ec8 <unlink>
     b14:	0a054563          	bltz	a0,bbe <writetest+0x176>
}
     b18:	60a6                	ld	ra,72(sp)
     b1a:	6406                	ld	s0,64(sp)
     b1c:	74e2                	ld	s1,56(sp)
     b1e:	7942                	ld	s2,48(sp)
     b20:	79a2                	ld	s3,40(sp)
     b22:	7a02                	ld	s4,32(sp)
     b24:	6ae2                	ld	s5,24(sp)
     b26:	6b42                	ld	s6,16(sp)
     b28:	6ba2                	ld	s7,8(sp)
     b2a:	6161                	addi	sp,sp,80
     b2c:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     b2e:	85de                	mv	a1,s7
     b30:	00006517          	auipc	a0,0x6
     b34:	bd850513          	addi	a0,a0,-1064 # 6708 <malloc+0x45e>
     b38:	00005097          	auipc	ra,0x5
     b3c:	6b6080e7          	jalr	1718(ra) # 61ee <printf>
    exit(1);
     b40:	4505                	li	a0,1
     b42:	00005097          	auipc	ra,0x5
     b46:	336080e7          	jalr	822(ra) # 5e78 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     b4a:	864a                	mv	a2,s2
     b4c:	85de                	mv	a1,s7
     b4e:	00006517          	auipc	a0,0x6
     b52:	bea50513          	addi	a0,a0,-1046 # 6738 <malloc+0x48e>
     b56:	00005097          	auipc	ra,0x5
     b5a:	698080e7          	jalr	1688(ra) # 61ee <printf>
      exit(1);
     b5e:	4505                	li	a0,1
     b60:	00005097          	auipc	ra,0x5
     b64:	318080e7          	jalr	792(ra) # 5e78 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b68:	864a                	mv	a2,s2
     b6a:	85de                	mv	a1,s7
     b6c:	00006517          	auipc	a0,0x6
     b70:	c0450513          	addi	a0,a0,-1020 # 6770 <malloc+0x4c6>
     b74:	00005097          	auipc	ra,0x5
     b78:	67a080e7          	jalr	1658(ra) # 61ee <printf>
      exit(1);
     b7c:	4505                	li	a0,1
     b7e:	00005097          	auipc	ra,0x5
     b82:	2fa080e7          	jalr	762(ra) # 5e78 <exit>
    printf("%s: error: open small failed!\n", s);
     b86:	85de                	mv	a1,s7
     b88:	00006517          	auipc	a0,0x6
     b8c:	c1050513          	addi	a0,a0,-1008 # 6798 <malloc+0x4ee>
     b90:	00005097          	auipc	ra,0x5
     b94:	65e080e7          	jalr	1630(ra) # 61ee <printf>
    exit(1);
     b98:	4505                	li	a0,1
     b9a:	00005097          	auipc	ra,0x5
     b9e:	2de080e7          	jalr	734(ra) # 5e78 <exit>
    printf("%s: read failed\n", s);
     ba2:	85de                	mv	a1,s7
     ba4:	00006517          	auipc	a0,0x6
     ba8:	c1450513          	addi	a0,a0,-1004 # 67b8 <malloc+0x50e>
     bac:	00005097          	auipc	ra,0x5
     bb0:	642080e7          	jalr	1602(ra) # 61ee <printf>
    exit(1);
     bb4:	4505                	li	a0,1
     bb6:	00005097          	auipc	ra,0x5
     bba:	2c2080e7          	jalr	706(ra) # 5e78 <exit>
    printf("%s: unlink small failed\n", s);
     bbe:	85de                	mv	a1,s7
     bc0:	00006517          	auipc	a0,0x6
     bc4:	c1050513          	addi	a0,a0,-1008 # 67d0 <malloc+0x526>
     bc8:	00005097          	auipc	ra,0x5
     bcc:	626080e7          	jalr	1574(ra) # 61ee <printf>
    exit(1);
     bd0:	4505                	li	a0,1
     bd2:	00005097          	auipc	ra,0x5
     bd6:	2a6080e7          	jalr	678(ra) # 5e78 <exit>

0000000000000bda <writebig>:
{
     bda:	7139                	addi	sp,sp,-64
     bdc:	fc06                	sd	ra,56(sp)
     bde:	f822                	sd	s0,48(sp)
     be0:	f426                	sd	s1,40(sp)
     be2:	f04a                	sd	s2,32(sp)
     be4:	ec4e                	sd	s3,24(sp)
     be6:	e852                	sd	s4,16(sp)
     be8:	e456                	sd	s5,8(sp)
     bea:	e05a                	sd	s6,0(sp)
     bec:	0080                	addi	s0,sp,64
     bee:	8b2a                	mv	s6,a0
  fd = open("big", O_CREATE|O_RDWR);
     bf0:	20200593          	li	a1,514
     bf4:	00006517          	auipc	a0,0x6
     bf8:	bfc50513          	addi	a0,a0,-1028 # 67f0 <malloc+0x546>
     bfc:	00005097          	auipc	ra,0x5
     c00:	2bc080e7          	jalr	700(ra) # 5eb8 <open>
  if(fd < 0){
     c04:	08054263          	bltz	a0,c88 <writebig+0xae>
     c08:	8a2a                	mv	s4,a0
     c0a:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     c0c:	0000c997          	auipc	s3,0xc
     c10:	06c98993          	addi	s3,s3,108 # cc78 <buf>
    if(write(fd, buf, BSIZE) != BSIZE){
     c14:	40000913          	li	s2,1024
  for(i = 0; i < MAXFILE; i++){
     c18:	10c00a93          	li	s5,268
    ((int*)buf)[0] = i;
     c1c:	0099a023          	sw	s1,0(s3)
    if(write(fd, buf, BSIZE) != BSIZE){
     c20:	864a                	mv	a2,s2
     c22:	85ce                	mv	a1,s3
     c24:	8552                	mv	a0,s4
     c26:	00005097          	auipc	ra,0x5
     c2a:	272080e7          	jalr	626(ra) # 5e98 <write>
     c2e:	07251b63          	bne	a0,s2,ca4 <writebig+0xca>
  for(i = 0; i < MAXFILE; i++){
     c32:	2485                	addiw	s1,s1,1
     c34:	ff5494e3          	bne	s1,s5,c1c <writebig+0x42>
  close(fd);
     c38:	8552                	mv	a0,s4
     c3a:	00005097          	auipc	ra,0x5
     c3e:	266080e7          	jalr	614(ra) # 5ea0 <close>
  fd = open("big", O_RDONLY);
     c42:	4581                	li	a1,0
     c44:	00006517          	auipc	a0,0x6
     c48:	bac50513          	addi	a0,a0,-1108 # 67f0 <malloc+0x546>
     c4c:	00005097          	auipc	ra,0x5
     c50:	26c080e7          	jalr	620(ra) # 5eb8 <open>
     c54:	8a2a                	mv	s4,a0
  n = 0;
     c56:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c58:	40000993          	li	s3,1024
     c5c:	0000c917          	auipc	s2,0xc
     c60:	01c90913          	addi	s2,s2,28 # cc78 <buf>
  if(fd < 0){
     c64:	04054f63          	bltz	a0,cc2 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     c68:	864e                	mv	a2,s3
     c6a:	85ca                	mv	a1,s2
     c6c:	8552                	mv	a0,s4
     c6e:	00005097          	auipc	ra,0x5
     c72:	222080e7          	jalr	546(ra) # 5e90 <read>
    if(i == 0){
     c76:	c525                	beqz	a0,cde <writebig+0x104>
    } else if(i != BSIZE){
     c78:	0b351f63          	bne	a0,s3,d36 <writebig+0x15c>
    if(((int*)buf)[0] != n){
     c7c:	00092683          	lw	a3,0(s2)
     c80:	0c969a63          	bne	a3,s1,d54 <writebig+0x17a>
    n++;
     c84:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c86:	b7cd                	j	c68 <writebig+0x8e>
    printf("%s: error: creat big failed!\n", s);
     c88:	85da                	mv	a1,s6
     c8a:	00006517          	auipc	a0,0x6
     c8e:	b6e50513          	addi	a0,a0,-1170 # 67f8 <malloc+0x54e>
     c92:	00005097          	auipc	ra,0x5
     c96:	55c080e7          	jalr	1372(ra) # 61ee <printf>
    exit(1);
     c9a:	4505                	li	a0,1
     c9c:	00005097          	auipc	ra,0x5
     ca0:	1dc080e7          	jalr	476(ra) # 5e78 <exit>
      printf("%s: error: write big file failed\n", s, i);
     ca4:	8626                	mv	a2,s1
     ca6:	85da                	mv	a1,s6
     ca8:	00006517          	auipc	a0,0x6
     cac:	b7050513          	addi	a0,a0,-1168 # 6818 <malloc+0x56e>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	53e080e7          	jalr	1342(ra) # 61ee <printf>
      exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	1be080e7          	jalr	446(ra) # 5e78 <exit>
    printf("%s: error: open big failed!\n", s);
     cc2:	85da                	mv	a1,s6
     cc4:	00006517          	auipc	a0,0x6
     cc8:	b7c50513          	addi	a0,a0,-1156 # 6840 <malloc+0x596>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	522080e7          	jalr	1314(ra) # 61ee <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	1a2080e7          	jalr	418(ra) # 5e78 <exit>
      if(n == MAXFILE - 1){
     cde:	10b00793          	li	a5,267
     ce2:	02f48b63          	beq	s1,a5,d18 <writebig+0x13e>
  close(fd);
     ce6:	8552                	mv	a0,s4
     ce8:	00005097          	auipc	ra,0x5
     cec:	1b8080e7          	jalr	440(ra) # 5ea0 <close>
  if(unlink("big") < 0){
     cf0:	00006517          	auipc	a0,0x6
     cf4:	b0050513          	addi	a0,a0,-1280 # 67f0 <malloc+0x546>
     cf8:	00005097          	auipc	ra,0x5
     cfc:	1d0080e7          	jalr	464(ra) # 5ec8 <unlink>
     d00:	06054963          	bltz	a0,d72 <writebig+0x198>
}
     d04:	70e2                	ld	ra,56(sp)
     d06:	7442                	ld	s0,48(sp)
     d08:	74a2                	ld	s1,40(sp)
     d0a:	7902                	ld	s2,32(sp)
     d0c:	69e2                	ld	s3,24(sp)
     d0e:	6a42                	ld	s4,16(sp)
     d10:	6aa2                	ld	s5,8(sp)
     d12:	6b02                	ld	s6,0(sp)
     d14:	6121                	addi	sp,sp,64
     d16:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     d18:	863e                	mv	a2,a5
     d1a:	85da                	mv	a1,s6
     d1c:	00006517          	auipc	a0,0x6
     d20:	b4450513          	addi	a0,a0,-1212 # 6860 <malloc+0x5b6>
     d24:	00005097          	auipc	ra,0x5
     d28:	4ca080e7          	jalr	1226(ra) # 61ee <printf>
        exit(1);
     d2c:	4505                	li	a0,1
     d2e:	00005097          	auipc	ra,0x5
     d32:	14a080e7          	jalr	330(ra) # 5e78 <exit>
      printf("%s: read failed %d\n", s, i);
     d36:	862a                	mv	a2,a0
     d38:	85da                	mv	a1,s6
     d3a:	00006517          	auipc	a0,0x6
     d3e:	b4e50513          	addi	a0,a0,-1202 # 6888 <malloc+0x5de>
     d42:	00005097          	auipc	ra,0x5
     d46:	4ac080e7          	jalr	1196(ra) # 61ee <printf>
      exit(1);
     d4a:	4505                	li	a0,1
     d4c:	00005097          	auipc	ra,0x5
     d50:	12c080e7          	jalr	300(ra) # 5e78 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d54:	8626                	mv	a2,s1
     d56:	85da                	mv	a1,s6
     d58:	00006517          	auipc	a0,0x6
     d5c:	b4850513          	addi	a0,a0,-1208 # 68a0 <malloc+0x5f6>
     d60:	00005097          	auipc	ra,0x5
     d64:	48e080e7          	jalr	1166(ra) # 61ee <printf>
      exit(1);
     d68:	4505                	li	a0,1
     d6a:	00005097          	auipc	ra,0x5
     d6e:	10e080e7          	jalr	270(ra) # 5e78 <exit>
    printf("%s: unlink big failed\n", s);
     d72:	85da                	mv	a1,s6
     d74:	00006517          	auipc	a0,0x6
     d78:	b5450513          	addi	a0,a0,-1196 # 68c8 <malloc+0x61e>
     d7c:	00005097          	auipc	ra,0x5
     d80:	472080e7          	jalr	1138(ra) # 61ee <printf>
    exit(1);
     d84:	4505                	li	a0,1
     d86:	00005097          	auipc	ra,0x5
     d8a:	0f2080e7          	jalr	242(ra) # 5e78 <exit>

0000000000000d8e <unlinkread>:
{
     d8e:	7179                	addi	sp,sp,-48
     d90:	f406                	sd	ra,40(sp)
     d92:	f022                	sd	s0,32(sp)
     d94:	ec26                	sd	s1,24(sp)
     d96:	e84a                	sd	s2,16(sp)
     d98:	e44e                	sd	s3,8(sp)
     d9a:	1800                	addi	s0,sp,48
     d9c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d9e:	20200593          	li	a1,514
     da2:	00006517          	auipc	a0,0x6
     da6:	b3e50513          	addi	a0,a0,-1218 # 68e0 <malloc+0x636>
     daa:	00005097          	auipc	ra,0x5
     dae:	10e080e7          	jalr	270(ra) # 5eb8 <open>
  if(fd < 0){
     db2:	0e054563          	bltz	a0,e9c <unlinkread+0x10e>
     db6:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     db8:	4615                	li	a2,5
     dba:	00006597          	auipc	a1,0x6
     dbe:	b5658593          	addi	a1,a1,-1194 # 6910 <malloc+0x666>
     dc2:	00005097          	auipc	ra,0x5
     dc6:	0d6080e7          	jalr	214(ra) # 5e98 <write>
  close(fd);
     dca:	8526                	mv	a0,s1
     dcc:	00005097          	auipc	ra,0x5
     dd0:	0d4080e7          	jalr	212(ra) # 5ea0 <close>
  fd = open("unlinkread", O_RDWR);
     dd4:	4589                	li	a1,2
     dd6:	00006517          	auipc	a0,0x6
     dda:	b0a50513          	addi	a0,a0,-1270 # 68e0 <malloc+0x636>
     dde:	00005097          	auipc	ra,0x5
     de2:	0da080e7          	jalr	218(ra) # 5eb8 <open>
     de6:	84aa                	mv	s1,a0
  if(fd < 0){
     de8:	0c054863          	bltz	a0,eb8 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     dec:	00006517          	auipc	a0,0x6
     df0:	af450513          	addi	a0,a0,-1292 # 68e0 <malloc+0x636>
     df4:	00005097          	auipc	ra,0x5
     df8:	0d4080e7          	jalr	212(ra) # 5ec8 <unlink>
     dfc:	ed61                	bnez	a0,ed4 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dfe:	20200593          	li	a1,514
     e02:	00006517          	auipc	a0,0x6
     e06:	ade50513          	addi	a0,a0,-1314 # 68e0 <malloc+0x636>
     e0a:	00005097          	auipc	ra,0x5
     e0e:	0ae080e7          	jalr	174(ra) # 5eb8 <open>
     e12:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     e14:	460d                	li	a2,3
     e16:	00006597          	auipc	a1,0x6
     e1a:	b4258593          	addi	a1,a1,-1214 # 6958 <malloc+0x6ae>
     e1e:	00005097          	auipc	ra,0x5
     e22:	07a080e7          	jalr	122(ra) # 5e98 <write>
  close(fd1);
     e26:	854a                	mv	a0,s2
     e28:	00005097          	auipc	ra,0x5
     e2c:	078080e7          	jalr	120(ra) # 5ea0 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     e30:	660d                	lui	a2,0x3
     e32:	0000c597          	auipc	a1,0xc
     e36:	e4658593          	addi	a1,a1,-442 # cc78 <buf>
     e3a:	8526                	mv	a0,s1
     e3c:	00005097          	auipc	ra,0x5
     e40:	054080e7          	jalr	84(ra) # 5e90 <read>
     e44:	4795                	li	a5,5
     e46:	0af51563          	bne	a0,a5,ef0 <unlinkread+0x162>
  if(buf[0] != 'h'){
     e4a:	0000c717          	auipc	a4,0xc
     e4e:	e2e74703          	lbu	a4,-466(a4) # cc78 <buf>
     e52:	06800793          	li	a5,104
     e56:	0af71b63          	bne	a4,a5,f0c <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e5a:	4629                	li	a2,10
     e5c:	0000c597          	auipc	a1,0xc
     e60:	e1c58593          	addi	a1,a1,-484 # cc78 <buf>
     e64:	8526                	mv	a0,s1
     e66:	00005097          	auipc	ra,0x5
     e6a:	032080e7          	jalr	50(ra) # 5e98 <write>
     e6e:	47a9                	li	a5,10
     e70:	0af51c63          	bne	a0,a5,f28 <unlinkread+0x19a>
  close(fd);
     e74:	8526                	mv	a0,s1
     e76:	00005097          	auipc	ra,0x5
     e7a:	02a080e7          	jalr	42(ra) # 5ea0 <close>
  unlink("unlinkread");
     e7e:	00006517          	auipc	a0,0x6
     e82:	a6250513          	addi	a0,a0,-1438 # 68e0 <malloc+0x636>
     e86:	00005097          	auipc	ra,0x5
     e8a:	042080e7          	jalr	66(ra) # 5ec8 <unlink>
}
     e8e:	70a2                	ld	ra,40(sp)
     e90:	7402                	ld	s0,32(sp)
     e92:	64e2                	ld	s1,24(sp)
     e94:	6942                	ld	s2,16(sp)
     e96:	69a2                	ld	s3,8(sp)
     e98:	6145                	addi	sp,sp,48
     e9a:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e9c:	85ce                	mv	a1,s3
     e9e:	00006517          	auipc	a0,0x6
     ea2:	a5250513          	addi	a0,a0,-1454 # 68f0 <malloc+0x646>
     ea6:	00005097          	auipc	ra,0x5
     eaa:	348080e7          	jalr	840(ra) # 61ee <printf>
    exit(1);
     eae:	4505                	li	a0,1
     eb0:	00005097          	auipc	ra,0x5
     eb4:	fc8080e7          	jalr	-56(ra) # 5e78 <exit>
    printf("%s: open unlinkread failed\n", s);
     eb8:	85ce                	mv	a1,s3
     eba:	00006517          	auipc	a0,0x6
     ebe:	a5e50513          	addi	a0,a0,-1442 # 6918 <malloc+0x66e>
     ec2:	00005097          	auipc	ra,0x5
     ec6:	32c080e7          	jalr	812(ra) # 61ee <printf>
    exit(1);
     eca:	4505                	li	a0,1
     ecc:	00005097          	auipc	ra,0x5
     ed0:	fac080e7          	jalr	-84(ra) # 5e78 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ed4:	85ce                	mv	a1,s3
     ed6:	00006517          	auipc	a0,0x6
     eda:	a6250513          	addi	a0,a0,-1438 # 6938 <malloc+0x68e>
     ede:	00005097          	auipc	ra,0x5
     ee2:	310080e7          	jalr	784(ra) # 61ee <printf>
    exit(1);
     ee6:	4505                	li	a0,1
     ee8:	00005097          	auipc	ra,0x5
     eec:	f90080e7          	jalr	-112(ra) # 5e78 <exit>
    printf("%s: unlinkread read failed", s);
     ef0:	85ce                	mv	a1,s3
     ef2:	00006517          	auipc	a0,0x6
     ef6:	a6e50513          	addi	a0,a0,-1426 # 6960 <malloc+0x6b6>
     efa:	00005097          	auipc	ra,0x5
     efe:	2f4080e7          	jalr	756(ra) # 61ee <printf>
    exit(1);
     f02:	4505                	li	a0,1
     f04:	00005097          	auipc	ra,0x5
     f08:	f74080e7          	jalr	-140(ra) # 5e78 <exit>
    printf("%s: unlinkread wrong data\n", s);
     f0c:	85ce                	mv	a1,s3
     f0e:	00006517          	auipc	a0,0x6
     f12:	a7250513          	addi	a0,a0,-1422 # 6980 <malloc+0x6d6>
     f16:	00005097          	auipc	ra,0x5
     f1a:	2d8080e7          	jalr	728(ra) # 61ee <printf>
    exit(1);
     f1e:	4505                	li	a0,1
     f20:	00005097          	auipc	ra,0x5
     f24:	f58080e7          	jalr	-168(ra) # 5e78 <exit>
    printf("%s: unlinkread write failed\n", s);
     f28:	85ce                	mv	a1,s3
     f2a:	00006517          	auipc	a0,0x6
     f2e:	a7650513          	addi	a0,a0,-1418 # 69a0 <malloc+0x6f6>
     f32:	00005097          	auipc	ra,0x5
     f36:	2bc080e7          	jalr	700(ra) # 61ee <printf>
    exit(1);
     f3a:	4505                	li	a0,1
     f3c:	00005097          	auipc	ra,0x5
     f40:	f3c080e7          	jalr	-196(ra) # 5e78 <exit>

0000000000000f44 <linktest>:
{
     f44:	1101                	addi	sp,sp,-32
     f46:	ec06                	sd	ra,24(sp)
     f48:	e822                	sd	s0,16(sp)
     f4a:	e426                	sd	s1,8(sp)
     f4c:	e04a                	sd	s2,0(sp)
     f4e:	1000                	addi	s0,sp,32
     f50:	892a                	mv	s2,a0
  unlink("lf1");
     f52:	00006517          	auipc	a0,0x6
     f56:	a6e50513          	addi	a0,a0,-1426 # 69c0 <malloc+0x716>
     f5a:	00005097          	auipc	ra,0x5
     f5e:	f6e080e7          	jalr	-146(ra) # 5ec8 <unlink>
  unlink("lf2");
     f62:	00006517          	auipc	a0,0x6
     f66:	a6650513          	addi	a0,a0,-1434 # 69c8 <malloc+0x71e>
     f6a:	00005097          	auipc	ra,0x5
     f6e:	f5e080e7          	jalr	-162(ra) # 5ec8 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f72:	20200593          	li	a1,514
     f76:	00006517          	auipc	a0,0x6
     f7a:	a4a50513          	addi	a0,a0,-1462 # 69c0 <malloc+0x716>
     f7e:	00005097          	auipc	ra,0x5
     f82:	f3a080e7          	jalr	-198(ra) # 5eb8 <open>
  if(fd < 0){
     f86:	10054763          	bltz	a0,1094 <linktest+0x150>
     f8a:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f8c:	4615                	li	a2,5
     f8e:	00006597          	auipc	a1,0x6
     f92:	98258593          	addi	a1,a1,-1662 # 6910 <malloc+0x666>
     f96:	00005097          	auipc	ra,0x5
     f9a:	f02080e7          	jalr	-254(ra) # 5e98 <write>
     f9e:	4795                	li	a5,5
     fa0:	10f51863          	bne	a0,a5,10b0 <linktest+0x16c>
  close(fd);
     fa4:	8526                	mv	a0,s1
     fa6:	00005097          	auipc	ra,0x5
     faa:	efa080e7          	jalr	-262(ra) # 5ea0 <close>
  if(link("lf1", "lf2") < 0){
     fae:	00006597          	auipc	a1,0x6
     fb2:	a1a58593          	addi	a1,a1,-1510 # 69c8 <malloc+0x71e>
     fb6:	00006517          	auipc	a0,0x6
     fba:	a0a50513          	addi	a0,a0,-1526 # 69c0 <malloc+0x716>
     fbe:	00005097          	auipc	ra,0x5
     fc2:	f1a080e7          	jalr	-230(ra) # 5ed8 <link>
     fc6:	10054363          	bltz	a0,10cc <linktest+0x188>
  unlink("lf1");
     fca:	00006517          	auipc	a0,0x6
     fce:	9f650513          	addi	a0,a0,-1546 # 69c0 <malloc+0x716>
     fd2:	00005097          	auipc	ra,0x5
     fd6:	ef6080e7          	jalr	-266(ra) # 5ec8 <unlink>
  if(open("lf1", 0) >= 0){
     fda:	4581                	li	a1,0
     fdc:	00006517          	auipc	a0,0x6
     fe0:	9e450513          	addi	a0,a0,-1564 # 69c0 <malloc+0x716>
     fe4:	00005097          	auipc	ra,0x5
     fe8:	ed4080e7          	jalr	-300(ra) # 5eb8 <open>
     fec:	0e055e63          	bgez	a0,10e8 <linktest+0x1a4>
  fd = open("lf2", 0);
     ff0:	4581                	li	a1,0
     ff2:	00006517          	auipc	a0,0x6
     ff6:	9d650513          	addi	a0,a0,-1578 # 69c8 <malloc+0x71e>
     ffa:	00005097          	auipc	ra,0x5
     ffe:	ebe080e7          	jalr	-322(ra) # 5eb8 <open>
    1002:	84aa                	mv	s1,a0
  if(fd < 0){
    1004:	10054063          	bltz	a0,1104 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    1008:	660d                	lui	a2,0x3
    100a:	0000c597          	auipc	a1,0xc
    100e:	c6e58593          	addi	a1,a1,-914 # cc78 <buf>
    1012:	00005097          	auipc	ra,0x5
    1016:	e7e080e7          	jalr	-386(ra) # 5e90 <read>
    101a:	4795                	li	a5,5
    101c:	10f51263          	bne	a0,a5,1120 <linktest+0x1dc>
  close(fd);
    1020:	8526                	mv	a0,s1
    1022:	00005097          	auipc	ra,0x5
    1026:	e7e080e7          	jalr	-386(ra) # 5ea0 <close>
  if(link("lf2", "lf2") >= 0){
    102a:	00006597          	auipc	a1,0x6
    102e:	99e58593          	addi	a1,a1,-1634 # 69c8 <malloc+0x71e>
    1032:	852e                	mv	a0,a1
    1034:	00005097          	auipc	ra,0x5
    1038:	ea4080e7          	jalr	-348(ra) # 5ed8 <link>
    103c:	10055063          	bgez	a0,113c <linktest+0x1f8>
  unlink("lf2");
    1040:	00006517          	auipc	a0,0x6
    1044:	98850513          	addi	a0,a0,-1656 # 69c8 <malloc+0x71e>
    1048:	00005097          	auipc	ra,0x5
    104c:	e80080e7          	jalr	-384(ra) # 5ec8 <unlink>
  if(link("lf2", "lf1") >= 0){
    1050:	00006597          	auipc	a1,0x6
    1054:	97058593          	addi	a1,a1,-1680 # 69c0 <malloc+0x716>
    1058:	00006517          	auipc	a0,0x6
    105c:	97050513          	addi	a0,a0,-1680 # 69c8 <malloc+0x71e>
    1060:	00005097          	auipc	ra,0x5
    1064:	e78080e7          	jalr	-392(ra) # 5ed8 <link>
    1068:	0e055863          	bgez	a0,1158 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    106c:	00006597          	auipc	a1,0x6
    1070:	95458593          	addi	a1,a1,-1708 # 69c0 <malloc+0x716>
    1074:	00006517          	auipc	a0,0x6
    1078:	a5c50513          	addi	a0,a0,-1444 # 6ad0 <malloc+0x826>
    107c:	00005097          	auipc	ra,0x5
    1080:	e5c080e7          	jalr	-420(ra) # 5ed8 <link>
    1084:	0e055863          	bgez	a0,1174 <linktest+0x230>
}
    1088:	60e2                	ld	ra,24(sp)
    108a:	6442                	ld	s0,16(sp)
    108c:	64a2                	ld	s1,8(sp)
    108e:	6902                	ld	s2,0(sp)
    1090:	6105                	addi	sp,sp,32
    1092:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1094:	85ca                	mv	a1,s2
    1096:	00006517          	auipc	a0,0x6
    109a:	93a50513          	addi	a0,a0,-1734 # 69d0 <malloc+0x726>
    109e:	00005097          	auipc	ra,0x5
    10a2:	150080e7          	jalr	336(ra) # 61ee <printf>
    exit(1);
    10a6:	4505                	li	a0,1
    10a8:	00005097          	auipc	ra,0x5
    10ac:	dd0080e7          	jalr	-560(ra) # 5e78 <exit>
    printf("%s: write lf1 failed\n", s);
    10b0:	85ca                	mv	a1,s2
    10b2:	00006517          	auipc	a0,0x6
    10b6:	93650513          	addi	a0,a0,-1738 # 69e8 <malloc+0x73e>
    10ba:	00005097          	auipc	ra,0x5
    10be:	134080e7          	jalr	308(ra) # 61ee <printf>
    exit(1);
    10c2:	4505                	li	a0,1
    10c4:	00005097          	auipc	ra,0x5
    10c8:	db4080e7          	jalr	-588(ra) # 5e78 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    10cc:	85ca                	mv	a1,s2
    10ce:	00006517          	auipc	a0,0x6
    10d2:	93250513          	addi	a0,a0,-1742 # 6a00 <malloc+0x756>
    10d6:	00005097          	auipc	ra,0x5
    10da:	118080e7          	jalr	280(ra) # 61ee <printf>
    exit(1);
    10de:	4505                	li	a0,1
    10e0:	00005097          	auipc	ra,0x5
    10e4:	d98080e7          	jalr	-616(ra) # 5e78 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    10e8:	85ca                	mv	a1,s2
    10ea:	00006517          	auipc	a0,0x6
    10ee:	93650513          	addi	a0,a0,-1738 # 6a20 <malloc+0x776>
    10f2:	00005097          	auipc	ra,0x5
    10f6:	0fc080e7          	jalr	252(ra) # 61ee <printf>
    exit(1);
    10fa:	4505                	li	a0,1
    10fc:	00005097          	auipc	ra,0x5
    1100:	d7c080e7          	jalr	-644(ra) # 5e78 <exit>
    printf("%s: open lf2 failed\n", s);
    1104:	85ca                	mv	a1,s2
    1106:	00006517          	auipc	a0,0x6
    110a:	94a50513          	addi	a0,a0,-1718 # 6a50 <malloc+0x7a6>
    110e:	00005097          	auipc	ra,0x5
    1112:	0e0080e7          	jalr	224(ra) # 61ee <printf>
    exit(1);
    1116:	4505                	li	a0,1
    1118:	00005097          	auipc	ra,0x5
    111c:	d60080e7          	jalr	-672(ra) # 5e78 <exit>
    printf("%s: read lf2 failed\n", s);
    1120:	85ca                	mv	a1,s2
    1122:	00006517          	auipc	a0,0x6
    1126:	94650513          	addi	a0,a0,-1722 # 6a68 <malloc+0x7be>
    112a:	00005097          	auipc	ra,0x5
    112e:	0c4080e7          	jalr	196(ra) # 61ee <printf>
    exit(1);
    1132:	4505                	li	a0,1
    1134:	00005097          	auipc	ra,0x5
    1138:	d44080e7          	jalr	-700(ra) # 5e78 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    113c:	85ca                	mv	a1,s2
    113e:	00006517          	auipc	a0,0x6
    1142:	94250513          	addi	a0,a0,-1726 # 6a80 <malloc+0x7d6>
    1146:	00005097          	auipc	ra,0x5
    114a:	0a8080e7          	jalr	168(ra) # 61ee <printf>
    exit(1);
    114e:	4505                	li	a0,1
    1150:	00005097          	auipc	ra,0x5
    1154:	d28080e7          	jalr	-728(ra) # 5e78 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    1158:	85ca                	mv	a1,s2
    115a:	00006517          	auipc	a0,0x6
    115e:	94e50513          	addi	a0,a0,-1714 # 6aa8 <malloc+0x7fe>
    1162:	00005097          	auipc	ra,0x5
    1166:	08c080e7          	jalr	140(ra) # 61ee <printf>
    exit(1);
    116a:	4505                	li	a0,1
    116c:	00005097          	auipc	ra,0x5
    1170:	d0c080e7          	jalr	-756(ra) # 5e78 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1174:	85ca                	mv	a1,s2
    1176:	00006517          	auipc	a0,0x6
    117a:	96250513          	addi	a0,a0,-1694 # 6ad8 <malloc+0x82e>
    117e:	00005097          	auipc	ra,0x5
    1182:	070080e7          	jalr	112(ra) # 61ee <printf>
    exit(1);
    1186:	4505                	li	a0,1
    1188:	00005097          	auipc	ra,0x5
    118c:	cf0080e7          	jalr	-784(ra) # 5e78 <exit>

0000000000001190 <validatetest>:
{
    1190:	7139                	addi	sp,sp,-64
    1192:	fc06                	sd	ra,56(sp)
    1194:	f822                	sd	s0,48(sp)
    1196:	f426                	sd	s1,40(sp)
    1198:	f04a                	sd	s2,32(sp)
    119a:	ec4e                	sd	s3,24(sp)
    119c:	e852                	sd	s4,16(sp)
    119e:	e456                	sd	s5,8(sp)
    11a0:	e05a                	sd	s6,0(sp)
    11a2:	0080                	addi	s0,sp,64
    11a4:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    11a6:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    11a8:	00006997          	auipc	s3,0x6
    11ac:	95098993          	addi	s3,s3,-1712 # 6af8 <malloc+0x84e>
    11b0:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    11b2:	6a85                	lui	s5,0x1
    11b4:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    11b8:	85a6                	mv	a1,s1
    11ba:	854e                	mv	a0,s3
    11bc:	00005097          	auipc	ra,0x5
    11c0:	d1c080e7          	jalr	-740(ra) # 5ed8 <link>
    11c4:	01251f63          	bne	a0,s2,11e2 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    11c8:	94d6                	add	s1,s1,s5
    11ca:	ff4497e3          	bne	s1,s4,11b8 <validatetest+0x28>
}
    11ce:	70e2                	ld	ra,56(sp)
    11d0:	7442                	ld	s0,48(sp)
    11d2:	74a2                	ld	s1,40(sp)
    11d4:	7902                	ld	s2,32(sp)
    11d6:	69e2                	ld	s3,24(sp)
    11d8:	6a42                	ld	s4,16(sp)
    11da:	6aa2                	ld	s5,8(sp)
    11dc:	6b02                	ld	s6,0(sp)
    11de:	6121                	addi	sp,sp,64
    11e0:	8082                	ret
      printf("%s: link should not succeed\n", s);
    11e2:	85da                	mv	a1,s6
    11e4:	00006517          	auipc	a0,0x6
    11e8:	92450513          	addi	a0,a0,-1756 # 6b08 <malloc+0x85e>
    11ec:	00005097          	auipc	ra,0x5
    11f0:	002080e7          	jalr	2(ra) # 61ee <printf>
      exit(1);
    11f4:	4505                	li	a0,1
    11f6:	00005097          	auipc	ra,0x5
    11fa:	c82080e7          	jalr	-894(ra) # 5e78 <exit>

00000000000011fe <bigdir>:
{
    11fe:	711d                	addi	sp,sp,-96
    1200:	ec86                	sd	ra,88(sp)
    1202:	e8a2                	sd	s0,80(sp)
    1204:	e4a6                	sd	s1,72(sp)
    1206:	e0ca                	sd	s2,64(sp)
    1208:	fc4e                	sd	s3,56(sp)
    120a:	f852                	sd	s4,48(sp)
    120c:	f456                	sd	s5,40(sp)
    120e:	f05a                	sd	s6,32(sp)
    1210:	ec5e                	sd	s7,24(sp)
    1212:	1080                	addi	s0,sp,96
    1214:	89aa                	mv	s3,a0
  unlink("bd");
    1216:	00006517          	auipc	a0,0x6
    121a:	91250513          	addi	a0,a0,-1774 # 6b28 <malloc+0x87e>
    121e:	00005097          	auipc	ra,0x5
    1222:	caa080e7          	jalr	-854(ra) # 5ec8 <unlink>
  fd = open("bd", O_CREATE);
    1226:	20000593          	li	a1,512
    122a:	00006517          	auipc	a0,0x6
    122e:	8fe50513          	addi	a0,a0,-1794 # 6b28 <malloc+0x87e>
    1232:	00005097          	auipc	ra,0x5
    1236:	c86080e7          	jalr	-890(ra) # 5eb8 <open>
  if(fd < 0){
    123a:	0c054c63          	bltz	a0,1312 <bigdir+0x114>
  close(fd);
    123e:	00005097          	auipc	ra,0x5
    1242:	c62080e7          	jalr	-926(ra) # 5ea0 <close>
  for(i = 0; i < N; i++){
    1246:	4901                	li	s2,0
    name[0] = 'x';
    1248:	07800b13          	li	s6,120
    if(link("bd", name) != 0){
    124c:	fa040a93          	addi	s5,s0,-96
    1250:	00006a17          	auipc	s4,0x6
    1254:	8d8a0a13          	addi	s4,s4,-1832 # 6b28 <malloc+0x87e>
  for(i = 0; i < N; i++){
    1258:	1f400b93          	li	s7,500
    name[0] = 'x';
    125c:	fb640023          	sb	s6,-96(s0)
    name[1] = '0' + (i / 64);
    1260:	41f9571b          	sraiw	a4,s2,0x1f
    1264:	01a7571b          	srliw	a4,a4,0x1a
    1268:	012707bb          	addw	a5,a4,s2
    126c:	4067d69b          	sraiw	a3,a5,0x6
    1270:	0306869b          	addiw	a3,a3,48
    1274:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
    1278:	03f7f793          	andi	a5,a5,63
    127c:	9f99                	subw	a5,a5,a4
    127e:	0307879b          	addiw	a5,a5,48
    1282:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
    1286:	fa0401a3          	sb	zero,-93(s0)
    if(link("bd", name) != 0){
    128a:	85d6                	mv	a1,s5
    128c:	8552                	mv	a0,s4
    128e:	00005097          	auipc	ra,0x5
    1292:	c4a080e7          	jalr	-950(ra) # 5ed8 <link>
    1296:	84aa                	mv	s1,a0
    1298:	e959                	bnez	a0,132e <bigdir+0x130>
  for(i = 0; i < N; i++){
    129a:	2905                	addiw	s2,s2,1
    129c:	fd7910e3          	bne	s2,s7,125c <bigdir+0x5e>
  unlink("bd");
    12a0:	00006517          	auipc	a0,0x6
    12a4:	88850513          	addi	a0,a0,-1912 # 6b28 <malloc+0x87e>
    12a8:	00005097          	auipc	ra,0x5
    12ac:	c20080e7          	jalr	-992(ra) # 5ec8 <unlink>
    name[0] = 'x';
    12b0:	07800a13          	li	s4,120
    if(unlink(name) != 0){
    12b4:	fa040913          	addi	s2,s0,-96
  for(i = 0; i < N; i++){
    12b8:	1f400a93          	li	s5,500
    name[0] = 'x';
    12bc:	fb440023          	sb	s4,-96(s0)
    name[1] = '0' + (i / 64);
    12c0:	41f4d71b          	sraiw	a4,s1,0x1f
    12c4:	01a7571b          	srliw	a4,a4,0x1a
    12c8:	009707bb          	addw	a5,a4,s1
    12cc:	4067d69b          	sraiw	a3,a5,0x6
    12d0:	0306869b          	addiw	a3,a3,48
    12d4:	fad400a3          	sb	a3,-95(s0)
    name[2] = '0' + (i % 64);
    12d8:	03f7f793          	andi	a5,a5,63
    12dc:	9f99                	subw	a5,a5,a4
    12de:	0307879b          	addiw	a5,a5,48
    12e2:	faf40123          	sb	a5,-94(s0)
    name[3] = '\0';
    12e6:	fa0401a3          	sb	zero,-93(s0)
    if(unlink(name) != 0){
    12ea:	854a                	mv	a0,s2
    12ec:	00005097          	auipc	ra,0x5
    12f0:	bdc080e7          	jalr	-1060(ra) # 5ec8 <unlink>
    12f4:	ed29                	bnez	a0,134e <bigdir+0x150>
  for(i = 0; i < N; i++){
    12f6:	2485                	addiw	s1,s1,1
    12f8:	fd5492e3          	bne	s1,s5,12bc <bigdir+0xbe>
}
    12fc:	60e6                	ld	ra,88(sp)
    12fe:	6446                	ld	s0,80(sp)
    1300:	64a6                	ld	s1,72(sp)
    1302:	6906                	ld	s2,64(sp)
    1304:	79e2                	ld	s3,56(sp)
    1306:	7a42                	ld	s4,48(sp)
    1308:	7aa2                	ld	s5,40(sp)
    130a:	7b02                	ld	s6,32(sp)
    130c:	6be2                	ld	s7,24(sp)
    130e:	6125                	addi	sp,sp,96
    1310:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1312:	85ce                	mv	a1,s3
    1314:	00006517          	auipc	a0,0x6
    1318:	81c50513          	addi	a0,a0,-2020 # 6b30 <malloc+0x886>
    131c:	00005097          	auipc	ra,0x5
    1320:	ed2080e7          	jalr	-302(ra) # 61ee <printf>
    exit(1);
    1324:	4505                	li	a0,1
    1326:	00005097          	auipc	ra,0x5
    132a:	b52080e7          	jalr	-1198(ra) # 5e78 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    132e:	fa040613          	addi	a2,s0,-96
    1332:	85ce                	mv	a1,s3
    1334:	00006517          	auipc	a0,0x6
    1338:	81c50513          	addi	a0,a0,-2020 # 6b50 <malloc+0x8a6>
    133c:	00005097          	auipc	ra,0x5
    1340:	eb2080e7          	jalr	-334(ra) # 61ee <printf>
      exit(1);
    1344:	4505                	li	a0,1
    1346:	00005097          	auipc	ra,0x5
    134a:	b32080e7          	jalr	-1230(ra) # 5e78 <exit>
      printf("%s: bigdir unlink failed", s);
    134e:	85ce                	mv	a1,s3
    1350:	00006517          	auipc	a0,0x6
    1354:	82050513          	addi	a0,a0,-2016 # 6b70 <malloc+0x8c6>
    1358:	00005097          	auipc	ra,0x5
    135c:	e96080e7          	jalr	-362(ra) # 61ee <printf>
      exit(1);
    1360:	4505                	li	a0,1
    1362:	00005097          	auipc	ra,0x5
    1366:	b16080e7          	jalr	-1258(ra) # 5e78 <exit>

000000000000136a <pgbug>:
{
    136a:	7179                	addi	sp,sp,-48
    136c:	f406                	sd	ra,40(sp)
    136e:	f022                	sd	s0,32(sp)
    1370:	ec26                	sd	s1,24(sp)
    1372:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1374:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1378:	00008497          	auipc	s1,0x8
    137c:	c8848493          	addi	s1,s1,-888 # 9000 <big>
    1380:	fd840593          	addi	a1,s0,-40
    1384:	6088                	ld	a0,0(s1)
    1386:	00005097          	auipc	ra,0x5
    138a:	b2a080e7          	jalr	-1238(ra) # 5eb0 <exec>
  pipe(big);
    138e:	6088                	ld	a0,0(s1)
    1390:	00005097          	auipc	ra,0x5
    1394:	af8080e7          	jalr	-1288(ra) # 5e88 <pipe>
  exit(0);
    1398:	4501                	li	a0,0
    139a:	00005097          	auipc	ra,0x5
    139e:	ade080e7          	jalr	-1314(ra) # 5e78 <exit>

00000000000013a2 <badarg>:
{
    13a2:	7139                	addi	sp,sp,-64
    13a4:	fc06                	sd	ra,56(sp)
    13a6:	f822                	sd	s0,48(sp)
    13a8:	f426                	sd	s1,40(sp)
    13aa:	f04a                	sd	s2,32(sp)
    13ac:	ec4e                	sd	s3,24(sp)
    13ae:	e852                	sd	s4,16(sp)
    13b0:	0080                	addi	s0,sp,64
    13b2:	64b1                	lui	s1,0xc
    13b4:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    13b8:	597d                	li	s2,-1
    13ba:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    13be:	fc040a13          	addi	s4,s0,-64
    13c2:	00005997          	auipc	s3,0x5
    13c6:	02698993          	addi	s3,s3,38 # 63e8 <malloc+0x13e>
    argv[0] = (char*)0xffffffff;
    13ca:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    13ce:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    13d2:	85d2                	mv	a1,s4
    13d4:	854e                	mv	a0,s3
    13d6:	00005097          	auipc	ra,0x5
    13da:	ada080e7          	jalr	-1318(ra) # 5eb0 <exec>
  for(int i = 0; i < 50000; i++){
    13de:	34fd                	addiw	s1,s1,-1
    13e0:	f4ed                	bnez	s1,13ca <badarg+0x28>
  exit(0);
    13e2:	4501                	li	a0,0
    13e4:	00005097          	auipc	ra,0x5
    13e8:	a94080e7          	jalr	-1388(ra) # 5e78 <exit>

00000000000013ec <copyinstr2>:
{
    13ec:	7155                	addi	sp,sp,-208
    13ee:	e586                	sd	ra,200(sp)
    13f0:	e1a2                	sd	s0,192(sp)
    13f2:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    13f4:	f6840793          	addi	a5,s0,-152
    13f8:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13fc:	07800713          	li	a4,120
    1400:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1404:	0785                	addi	a5,a5,1
    1406:	fed79de3          	bne	a5,a3,1400 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    140a:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    140e:	f6840513          	addi	a0,s0,-152
    1412:	00005097          	auipc	ra,0x5
    1416:	ab6080e7          	jalr	-1354(ra) # 5ec8 <unlink>
  if(ret != -1){
    141a:	57fd                	li	a5,-1
    141c:	0ef51063          	bne	a0,a5,14fc <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    1420:	20100593          	li	a1,513
    1424:	f6840513          	addi	a0,s0,-152
    1428:	00005097          	auipc	ra,0x5
    142c:	a90080e7          	jalr	-1392(ra) # 5eb8 <open>
  if(fd != -1){
    1430:	57fd                	li	a5,-1
    1432:	0ef51563          	bne	a0,a5,151c <copyinstr2+0x130>
  ret = link(b, b);
    1436:	f6840513          	addi	a0,s0,-152
    143a:	85aa                	mv	a1,a0
    143c:	00005097          	auipc	ra,0x5
    1440:	a9c080e7          	jalr	-1380(ra) # 5ed8 <link>
  if(ret != -1){
    1444:	57fd                	li	a5,-1
    1446:	0ef51b63          	bne	a0,a5,153c <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    144a:	00007797          	auipc	a5,0x7
    144e:	97e78793          	addi	a5,a5,-1666 # 7dc8 <malloc+0x1b1e>
    1452:	f4f43c23          	sd	a5,-168(s0)
    1456:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    145a:	f5840593          	addi	a1,s0,-168
    145e:	f6840513          	addi	a0,s0,-152
    1462:	00005097          	auipc	ra,0x5
    1466:	a4e080e7          	jalr	-1458(ra) # 5eb0 <exec>
  if(ret != -1){
    146a:	57fd                	li	a5,-1
    146c:	0ef51963          	bne	a0,a5,155e <copyinstr2+0x172>
  int pid = fork();
    1470:	00005097          	auipc	ra,0x5
    1474:	a00080e7          	jalr	-1536(ra) # 5e70 <fork>
  if(pid < 0){
    1478:	10054363          	bltz	a0,157e <copyinstr2+0x192>
  if(pid == 0){
    147c:	12051463          	bnez	a0,15a4 <copyinstr2+0x1b8>
    1480:	00008797          	auipc	a5,0x8
    1484:	0e078793          	addi	a5,a5,224 # 9560 <big.0>
    1488:	00009697          	auipc	a3,0x9
    148c:	0d868693          	addi	a3,a3,216 # a560 <big.0+0x1000>
      big[i] = 'x';
    1490:	07800713          	li	a4,120
    1494:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1498:	0785                	addi	a5,a5,1
    149a:	fed79de3          	bne	a5,a3,1494 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    149e:	00009797          	auipc	a5,0x9
    14a2:	0c078123          	sb	zero,194(a5) # a560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    14a6:	00007797          	auipc	a5,0x7
    14aa:	36a78793          	addi	a5,a5,874 # 8810 <malloc+0x2566>
    14ae:	6390                	ld	a2,0(a5)
    14b0:	6794                	ld	a3,8(a5)
    14b2:	6b98                	ld	a4,16(a5)
    14b4:	6f9c                	ld	a5,24(a5)
    14b6:	f2c43823          	sd	a2,-208(s0)
    14ba:	f2d43c23          	sd	a3,-200(s0)
    14be:	f4e43023          	sd	a4,-192(s0)
    14c2:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    14c6:	f3040593          	addi	a1,s0,-208
    14ca:	00005517          	auipc	a0,0x5
    14ce:	f1e50513          	addi	a0,a0,-226 # 63e8 <malloc+0x13e>
    14d2:	00005097          	auipc	ra,0x5
    14d6:	9de080e7          	jalr	-1570(ra) # 5eb0 <exec>
    if(ret != -1){
    14da:	57fd                	li	a5,-1
    14dc:	0af50e63          	beq	a0,a5,1598 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    14e0:	85be                	mv	a1,a5
    14e2:	00005517          	auipc	a0,0x5
    14e6:	73650513          	addi	a0,a0,1846 # 6c18 <malloc+0x96e>
    14ea:	00005097          	auipc	ra,0x5
    14ee:	d04080e7          	jalr	-764(ra) # 61ee <printf>
      exit(1);
    14f2:	4505                	li	a0,1
    14f4:	00005097          	auipc	ra,0x5
    14f8:	984080e7          	jalr	-1660(ra) # 5e78 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14fc:	862a                	mv	a2,a0
    14fe:	f6840593          	addi	a1,s0,-152
    1502:	00005517          	auipc	a0,0x5
    1506:	68e50513          	addi	a0,a0,1678 # 6b90 <malloc+0x8e6>
    150a:	00005097          	auipc	ra,0x5
    150e:	ce4080e7          	jalr	-796(ra) # 61ee <printf>
    exit(1);
    1512:	4505                	li	a0,1
    1514:	00005097          	auipc	ra,0x5
    1518:	964080e7          	jalr	-1692(ra) # 5e78 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    151c:	862a                	mv	a2,a0
    151e:	f6840593          	addi	a1,s0,-152
    1522:	00005517          	auipc	a0,0x5
    1526:	68e50513          	addi	a0,a0,1678 # 6bb0 <malloc+0x906>
    152a:	00005097          	auipc	ra,0x5
    152e:	cc4080e7          	jalr	-828(ra) # 61ee <printf>
    exit(1);
    1532:	4505                	li	a0,1
    1534:	00005097          	auipc	ra,0x5
    1538:	944080e7          	jalr	-1724(ra) # 5e78 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    153c:	f6840593          	addi	a1,s0,-152
    1540:	86aa                	mv	a3,a0
    1542:	862e                	mv	a2,a1
    1544:	00005517          	auipc	a0,0x5
    1548:	68c50513          	addi	a0,a0,1676 # 6bd0 <malloc+0x926>
    154c:	00005097          	auipc	ra,0x5
    1550:	ca2080e7          	jalr	-862(ra) # 61ee <printf>
    exit(1);
    1554:	4505                	li	a0,1
    1556:	00005097          	auipc	ra,0x5
    155a:	922080e7          	jalr	-1758(ra) # 5e78 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    155e:	863e                	mv	a2,a5
    1560:	f6840593          	addi	a1,s0,-152
    1564:	00005517          	auipc	a0,0x5
    1568:	69450513          	addi	a0,a0,1684 # 6bf8 <malloc+0x94e>
    156c:	00005097          	auipc	ra,0x5
    1570:	c82080e7          	jalr	-894(ra) # 61ee <printf>
    exit(1);
    1574:	4505                	li	a0,1
    1576:	00005097          	auipc	ra,0x5
    157a:	902080e7          	jalr	-1790(ra) # 5e78 <exit>
    printf("fork failed\n");
    157e:	00006517          	auipc	a0,0x6
    1582:	afa50513          	addi	a0,a0,-1286 # 7078 <malloc+0xdce>
    1586:	00005097          	auipc	ra,0x5
    158a:	c68080e7          	jalr	-920(ra) # 61ee <printf>
    exit(1);
    158e:	4505                	li	a0,1
    1590:	00005097          	auipc	ra,0x5
    1594:	8e8080e7          	jalr	-1816(ra) # 5e78 <exit>
    exit(747); // OK
    1598:	2eb00513          	li	a0,747
    159c:	00005097          	auipc	ra,0x5
    15a0:	8dc080e7          	jalr	-1828(ra) # 5e78 <exit>
  int st = 0;
    15a4:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    15a8:	f5440513          	addi	a0,s0,-172
    15ac:	00005097          	auipc	ra,0x5
    15b0:	8d4080e7          	jalr	-1836(ra) # 5e80 <wait>
  if(st != 747){
    15b4:	f5442703          	lw	a4,-172(s0)
    15b8:	2eb00793          	li	a5,747
    15bc:	00f71663          	bne	a4,a5,15c8 <copyinstr2+0x1dc>
}
    15c0:	60ae                	ld	ra,200(sp)
    15c2:	640e                	ld	s0,192(sp)
    15c4:	6169                	addi	sp,sp,208
    15c6:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    15c8:	00005517          	auipc	a0,0x5
    15cc:	67850513          	addi	a0,a0,1656 # 6c40 <malloc+0x996>
    15d0:	00005097          	auipc	ra,0x5
    15d4:	c1e080e7          	jalr	-994(ra) # 61ee <printf>
    exit(1);
    15d8:	4505                	li	a0,1
    15da:	00005097          	auipc	ra,0x5
    15de:	89e080e7          	jalr	-1890(ra) # 5e78 <exit>

00000000000015e2 <truncate3>:
{
    15e2:	7175                	addi	sp,sp,-144
    15e4:	e506                	sd	ra,136(sp)
    15e6:	e122                	sd	s0,128(sp)
    15e8:	ecd6                	sd	s5,88(sp)
    15ea:	0900                	addi	s0,sp,144
    15ec:	8aaa                	mv	s5,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    15ee:	60100593          	li	a1,1537
    15f2:	00005517          	auipc	a0,0x5
    15f6:	e4e50513          	addi	a0,a0,-434 # 6440 <malloc+0x196>
    15fa:	00005097          	auipc	ra,0x5
    15fe:	8be080e7          	jalr	-1858(ra) # 5eb8 <open>
    1602:	00005097          	auipc	ra,0x5
    1606:	89e080e7          	jalr	-1890(ra) # 5ea0 <close>
  pid = fork();
    160a:	00005097          	auipc	ra,0x5
    160e:	866080e7          	jalr	-1946(ra) # 5e70 <fork>
  if(pid < 0){
    1612:	08054b63          	bltz	a0,16a8 <truncate3+0xc6>
  if(pid == 0){
    1616:	ed65                	bnez	a0,170e <truncate3+0x12c>
    1618:	fca6                	sd	s1,120(sp)
    161a:	f8ca                	sd	s2,112(sp)
    161c:	f4ce                	sd	s3,104(sp)
    161e:	f0d2                	sd	s4,96(sp)
    1620:	e8da                	sd	s6,80(sp)
    1622:	e4de                	sd	s7,72(sp)
    1624:	e0e2                	sd	s8,64(sp)
    1626:	fc66                	sd	s9,56(sp)
    1628:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    162c:	4b05                	li	s6,1
    162e:	00005997          	auipc	s3,0x5
    1632:	e1298993          	addi	s3,s3,-494 # 6440 <malloc+0x196>
      int n = write(fd, "1234567890", 10);
    1636:	4a29                	li	s4,10
    1638:	00005b97          	auipc	s7,0x5
    163c:	668b8b93          	addi	s7,s7,1640 # 6ca0 <malloc+0x9f6>
      read(fd, buf, sizeof(buf));
    1640:	f7840c93          	addi	s9,s0,-136
    1644:	02000c13          	li	s8,32
      int fd = open("truncfile", O_WRONLY);
    1648:	85da                	mv	a1,s6
    164a:	854e                	mv	a0,s3
    164c:	00005097          	auipc	ra,0x5
    1650:	86c080e7          	jalr	-1940(ra) # 5eb8 <open>
    1654:	84aa                	mv	s1,a0
      if(fd < 0){
    1656:	06054f63          	bltz	a0,16d4 <truncate3+0xf2>
      int n = write(fd, "1234567890", 10);
    165a:	8652                	mv	a2,s4
    165c:	85de                	mv	a1,s7
    165e:	00005097          	auipc	ra,0x5
    1662:	83a080e7          	jalr	-1990(ra) # 5e98 <write>
      if(n != 10){
    1666:	09451563          	bne	a0,s4,16f0 <truncate3+0x10e>
      close(fd);
    166a:	8526                	mv	a0,s1
    166c:	00005097          	auipc	ra,0x5
    1670:	834080e7          	jalr	-1996(ra) # 5ea0 <close>
      fd = open("truncfile", O_RDONLY);
    1674:	4581                	li	a1,0
    1676:	854e                	mv	a0,s3
    1678:	00005097          	auipc	ra,0x5
    167c:	840080e7          	jalr	-1984(ra) # 5eb8 <open>
    1680:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1682:	8662                	mv	a2,s8
    1684:	85e6                	mv	a1,s9
    1686:	00005097          	auipc	ra,0x5
    168a:	80a080e7          	jalr	-2038(ra) # 5e90 <read>
      close(fd);
    168e:	8526                	mv	a0,s1
    1690:	00005097          	auipc	ra,0x5
    1694:	810080e7          	jalr	-2032(ra) # 5ea0 <close>
    for(int i = 0; i < 100; i++){
    1698:	397d                	addiw	s2,s2,-1
    169a:	fa0917e3          	bnez	s2,1648 <truncate3+0x66>
    exit(0);
    169e:	4501                	li	a0,0
    16a0:	00004097          	auipc	ra,0x4
    16a4:	7d8080e7          	jalr	2008(ra) # 5e78 <exit>
    16a8:	fca6                	sd	s1,120(sp)
    16aa:	f8ca                	sd	s2,112(sp)
    16ac:	f4ce                	sd	s3,104(sp)
    16ae:	f0d2                	sd	s4,96(sp)
    16b0:	e8da                	sd	s6,80(sp)
    16b2:	e4de                	sd	s7,72(sp)
    16b4:	e0e2                	sd	s8,64(sp)
    16b6:	fc66                	sd	s9,56(sp)
    printf("%s: fork failed\n", s);
    16b8:	85d6                	mv	a1,s5
    16ba:	00005517          	auipc	a0,0x5
    16be:	5b650513          	addi	a0,a0,1462 # 6c70 <malloc+0x9c6>
    16c2:	00005097          	auipc	ra,0x5
    16c6:	b2c080e7          	jalr	-1236(ra) # 61ee <printf>
    exit(1);
    16ca:	4505                	li	a0,1
    16cc:	00004097          	auipc	ra,0x4
    16d0:	7ac080e7          	jalr	1964(ra) # 5e78 <exit>
        printf("%s: open failed\n", s);
    16d4:	85d6                	mv	a1,s5
    16d6:	00005517          	auipc	a0,0x5
    16da:	5b250513          	addi	a0,a0,1458 # 6c88 <malloc+0x9de>
    16de:	00005097          	auipc	ra,0x5
    16e2:	b10080e7          	jalr	-1264(ra) # 61ee <printf>
        exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	790080e7          	jalr	1936(ra) # 5e78 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    16f0:	862a                	mv	a2,a0
    16f2:	85d6                	mv	a1,s5
    16f4:	00005517          	auipc	a0,0x5
    16f8:	5bc50513          	addi	a0,a0,1468 # 6cb0 <malloc+0xa06>
    16fc:	00005097          	auipc	ra,0x5
    1700:	af2080e7          	jalr	-1294(ra) # 61ee <printf>
        exit(1);
    1704:	4505                	li	a0,1
    1706:	00004097          	auipc	ra,0x4
    170a:	772080e7          	jalr	1906(ra) # 5e78 <exit>
    170e:	fca6                	sd	s1,120(sp)
    1710:	f8ca                	sd	s2,112(sp)
    1712:	f4ce                	sd	s3,104(sp)
    1714:	f0d2                	sd	s4,96(sp)
    1716:	e8da                	sd	s6,80(sp)
    1718:	e4de                	sd	s7,72(sp)
    171a:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    171e:	60100b13          	li	s6,1537
    1722:	00005a17          	auipc	s4,0x5
    1726:	d1ea0a13          	addi	s4,s4,-738 # 6440 <malloc+0x196>
    int n = write(fd, "xxx", 3);
    172a:	498d                	li	s3,3
    172c:	00005b97          	auipc	s7,0x5
    1730:	5a4b8b93          	addi	s7,s7,1444 # 6cd0 <malloc+0xa26>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1734:	85da                	mv	a1,s6
    1736:	8552                	mv	a0,s4
    1738:	00004097          	auipc	ra,0x4
    173c:	780080e7          	jalr	1920(ra) # 5eb8 <open>
    1740:	84aa                	mv	s1,a0
    if(fd < 0){
    1742:	04054863          	bltz	a0,1792 <truncate3+0x1b0>
    int n = write(fd, "xxx", 3);
    1746:	864e                	mv	a2,s3
    1748:	85de                	mv	a1,s7
    174a:	00004097          	auipc	ra,0x4
    174e:	74e080e7          	jalr	1870(ra) # 5e98 <write>
    if(n != 3){
    1752:	07351063          	bne	a0,s3,17b2 <truncate3+0x1d0>
    close(fd);
    1756:	8526                	mv	a0,s1
    1758:	00004097          	auipc	ra,0x4
    175c:	748080e7          	jalr	1864(ra) # 5ea0 <close>
  for(int i = 0; i < 150; i++){
    1760:	397d                	addiw	s2,s2,-1
    1762:	fc0919e3          	bnez	s2,1734 <truncate3+0x152>
    1766:	e0e2                	sd	s8,64(sp)
    1768:	fc66                	sd	s9,56(sp)
  wait(&xstatus);
    176a:	f9c40513          	addi	a0,s0,-100
    176e:	00004097          	auipc	ra,0x4
    1772:	712080e7          	jalr	1810(ra) # 5e80 <wait>
  unlink("truncfile");
    1776:	00005517          	auipc	a0,0x5
    177a:	cca50513          	addi	a0,a0,-822 # 6440 <malloc+0x196>
    177e:	00004097          	auipc	ra,0x4
    1782:	74a080e7          	jalr	1866(ra) # 5ec8 <unlink>
  exit(xstatus);
    1786:	f9c42503          	lw	a0,-100(s0)
    178a:	00004097          	auipc	ra,0x4
    178e:	6ee080e7          	jalr	1774(ra) # 5e78 <exit>
    1792:	e0e2                	sd	s8,64(sp)
    1794:	fc66                	sd	s9,56(sp)
      printf("%s: open failed\n", s);
    1796:	85d6                	mv	a1,s5
    1798:	00005517          	auipc	a0,0x5
    179c:	4f050513          	addi	a0,a0,1264 # 6c88 <malloc+0x9de>
    17a0:	00005097          	auipc	ra,0x5
    17a4:	a4e080e7          	jalr	-1458(ra) # 61ee <printf>
      exit(1);
    17a8:	4505                	li	a0,1
    17aa:	00004097          	auipc	ra,0x4
    17ae:	6ce080e7          	jalr	1742(ra) # 5e78 <exit>
    17b2:	e0e2                	sd	s8,64(sp)
    17b4:	fc66                	sd	s9,56(sp)
      printf("%s: write got %d, expected 3\n", s, n);
    17b6:	862a                	mv	a2,a0
    17b8:	85d6                	mv	a1,s5
    17ba:	00005517          	auipc	a0,0x5
    17be:	51e50513          	addi	a0,a0,1310 # 6cd8 <malloc+0xa2e>
    17c2:	00005097          	auipc	ra,0x5
    17c6:	a2c080e7          	jalr	-1492(ra) # 61ee <printf>
      exit(1);
    17ca:	4505                	li	a0,1
    17cc:	00004097          	auipc	ra,0x4
    17d0:	6ac080e7          	jalr	1708(ra) # 5e78 <exit>

00000000000017d4 <exectest>:
{
    17d4:	715d                	addi	sp,sp,-80
    17d6:	e486                	sd	ra,72(sp)
    17d8:	e0a2                	sd	s0,64(sp)
    17da:	f84a                	sd	s2,48(sp)
    17dc:	0880                	addi	s0,sp,80
    17de:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    17e0:	00005797          	auipc	a5,0x5
    17e4:	c0878793          	addi	a5,a5,-1016 # 63e8 <malloc+0x13e>
    17e8:	fcf43023          	sd	a5,-64(s0)
    17ec:	00005797          	auipc	a5,0x5
    17f0:	50c78793          	addi	a5,a5,1292 # 6cf8 <malloc+0xa4e>
    17f4:	fcf43423          	sd	a5,-56(s0)
    17f8:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    17fc:	00005517          	auipc	a0,0x5
    1800:	50450513          	addi	a0,a0,1284 # 6d00 <malloc+0xa56>
    1804:	00004097          	auipc	ra,0x4
    1808:	6c4080e7          	jalr	1732(ra) # 5ec8 <unlink>
  pid = fork();
    180c:	00004097          	auipc	ra,0x4
    1810:	664080e7          	jalr	1636(ra) # 5e70 <fork>
  if(pid < 0) {
    1814:	04054763          	bltz	a0,1862 <exectest+0x8e>
    1818:	fc26                	sd	s1,56(sp)
    181a:	84aa                	mv	s1,a0
  if(pid == 0) {
    181c:	ed41                	bnez	a0,18b4 <exectest+0xe0>
    close(1);
    181e:	4505                	li	a0,1
    1820:	00004097          	auipc	ra,0x4
    1824:	680080e7          	jalr	1664(ra) # 5ea0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1828:	20100593          	li	a1,513
    182c:	00005517          	auipc	a0,0x5
    1830:	4d450513          	addi	a0,a0,1236 # 6d00 <malloc+0xa56>
    1834:	00004097          	auipc	ra,0x4
    1838:	684080e7          	jalr	1668(ra) # 5eb8 <open>
    if(fd < 0) {
    183c:	04054263          	bltz	a0,1880 <exectest+0xac>
    if(fd != 1) {
    1840:	4785                	li	a5,1
    1842:	04f50d63          	beq	a0,a5,189c <exectest+0xc8>
      printf("%s: wrong fd\n", s);
    1846:	85ca                	mv	a1,s2
    1848:	00005517          	auipc	a0,0x5
    184c:	4d850513          	addi	a0,a0,1240 # 6d20 <malloc+0xa76>
    1850:	00005097          	auipc	ra,0x5
    1854:	99e080e7          	jalr	-1634(ra) # 61ee <printf>
      exit(1);
    1858:	4505                	li	a0,1
    185a:	00004097          	auipc	ra,0x4
    185e:	61e080e7          	jalr	1566(ra) # 5e78 <exit>
    1862:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    1864:	85ca                	mv	a1,s2
    1866:	00005517          	auipc	a0,0x5
    186a:	40a50513          	addi	a0,a0,1034 # 6c70 <malloc+0x9c6>
    186e:	00005097          	auipc	ra,0x5
    1872:	980080e7          	jalr	-1664(ra) # 61ee <printf>
     exit(1);
    1876:	4505                	li	a0,1
    1878:	00004097          	auipc	ra,0x4
    187c:	600080e7          	jalr	1536(ra) # 5e78 <exit>
      printf("%s: create failed\n", s);
    1880:	85ca                	mv	a1,s2
    1882:	00005517          	auipc	a0,0x5
    1886:	48650513          	addi	a0,a0,1158 # 6d08 <malloc+0xa5e>
    188a:	00005097          	auipc	ra,0x5
    188e:	964080e7          	jalr	-1692(ra) # 61ee <printf>
      exit(1);
    1892:	4505                	li	a0,1
    1894:	00004097          	auipc	ra,0x4
    1898:	5e4080e7          	jalr	1508(ra) # 5e78 <exit>
    if(exec("echo", echoargv) < 0){
    189c:	fc040593          	addi	a1,s0,-64
    18a0:	00005517          	auipc	a0,0x5
    18a4:	b4850513          	addi	a0,a0,-1208 # 63e8 <malloc+0x13e>
    18a8:	00004097          	auipc	ra,0x4
    18ac:	608080e7          	jalr	1544(ra) # 5eb0 <exec>
    18b0:	02054163          	bltz	a0,18d2 <exectest+0xfe>
  if (wait(&xstatus) != pid) {
    18b4:	fdc40513          	addi	a0,s0,-36
    18b8:	00004097          	auipc	ra,0x4
    18bc:	5c8080e7          	jalr	1480(ra) # 5e80 <wait>
    18c0:	02951763          	bne	a0,s1,18ee <exectest+0x11a>
  if(xstatus != 0)
    18c4:	fdc42503          	lw	a0,-36(s0)
    18c8:	cd0d                	beqz	a0,1902 <exectest+0x12e>
    exit(xstatus);
    18ca:	00004097          	auipc	ra,0x4
    18ce:	5ae080e7          	jalr	1454(ra) # 5e78 <exit>
      printf("%s: exec echo failed\n", s);
    18d2:	85ca                	mv	a1,s2
    18d4:	00005517          	auipc	a0,0x5
    18d8:	45c50513          	addi	a0,a0,1116 # 6d30 <malloc+0xa86>
    18dc:	00005097          	auipc	ra,0x5
    18e0:	912080e7          	jalr	-1774(ra) # 61ee <printf>
      exit(1);
    18e4:	4505                	li	a0,1
    18e6:	00004097          	auipc	ra,0x4
    18ea:	592080e7          	jalr	1426(ra) # 5e78 <exit>
    printf("%s: wait failed!\n", s);
    18ee:	85ca                	mv	a1,s2
    18f0:	00005517          	auipc	a0,0x5
    18f4:	45850513          	addi	a0,a0,1112 # 6d48 <malloc+0xa9e>
    18f8:	00005097          	auipc	ra,0x5
    18fc:	8f6080e7          	jalr	-1802(ra) # 61ee <printf>
    1900:	b7d1                	j	18c4 <exectest+0xf0>
  fd = open("echo-ok", O_RDONLY);
    1902:	4581                	li	a1,0
    1904:	00005517          	auipc	a0,0x5
    1908:	3fc50513          	addi	a0,a0,1020 # 6d00 <malloc+0xa56>
    190c:	00004097          	auipc	ra,0x4
    1910:	5ac080e7          	jalr	1452(ra) # 5eb8 <open>
  if(fd < 0) {
    1914:	02054a63          	bltz	a0,1948 <exectest+0x174>
  if (read(fd, buf, 2) != 2) {
    1918:	4609                	li	a2,2
    191a:	fb840593          	addi	a1,s0,-72
    191e:	00004097          	auipc	ra,0x4
    1922:	572080e7          	jalr	1394(ra) # 5e90 <read>
    1926:	4789                	li	a5,2
    1928:	02f50e63          	beq	a0,a5,1964 <exectest+0x190>
    printf("%s: read failed\n", s);
    192c:	85ca                	mv	a1,s2
    192e:	00005517          	auipc	a0,0x5
    1932:	e8a50513          	addi	a0,a0,-374 # 67b8 <malloc+0x50e>
    1936:	00005097          	auipc	ra,0x5
    193a:	8b8080e7          	jalr	-1864(ra) # 61ee <printf>
    exit(1);
    193e:	4505                	li	a0,1
    1940:	00004097          	auipc	ra,0x4
    1944:	538080e7          	jalr	1336(ra) # 5e78 <exit>
    printf("%s: open failed\n", s);
    1948:	85ca                	mv	a1,s2
    194a:	00005517          	auipc	a0,0x5
    194e:	33e50513          	addi	a0,a0,830 # 6c88 <malloc+0x9de>
    1952:	00005097          	auipc	ra,0x5
    1956:	89c080e7          	jalr	-1892(ra) # 61ee <printf>
    exit(1);
    195a:	4505                	li	a0,1
    195c:	00004097          	auipc	ra,0x4
    1960:	51c080e7          	jalr	1308(ra) # 5e78 <exit>
  unlink("echo-ok");
    1964:	00005517          	auipc	a0,0x5
    1968:	39c50513          	addi	a0,a0,924 # 6d00 <malloc+0xa56>
    196c:	00004097          	auipc	ra,0x4
    1970:	55c080e7          	jalr	1372(ra) # 5ec8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1974:	fb844703          	lbu	a4,-72(s0)
    1978:	04f00793          	li	a5,79
    197c:	00f71863          	bne	a4,a5,198c <exectest+0x1b8>
    1980:	fb944703          	lbu	a4,-71(s0)
    1984:	04b00793          	li	a5,75
    1988:	02f70063          	beq	a4,a5,19a8 <exectest+0x1d4>
    printf("%s: wrong output\n", s);
    198c:	85ca                	mv	a1,s2
    198e:	00005517          	auipc	a0,0x5
    1992:	3d250513          	addi	a0,a0,978 # 6d60 <malloc+0xab6>
    1996:	00005097          	auipc	ra,0x5
    199a:	858080e7          	jalr	-1960(ra) # 61ee <printf>
    exit(1);
    199e:	4505                	li	a0,1
    19a0:	00004097          	auipc	ra,0x4
    19a4:	4d8080e7          	jalr	1240(ra) # 5e78 <exit>
    exit(0);
    19a8:	4501                	li	a0,0
    19aa:	00004097          	auipc	ra,0x4
    19ae:	4ce080e7          	jalr	1230(ra) # 5e78 <exit>

00000000000019b2 <pipe1>:
{
    19b2:	711d                	addi	sp,sp,-96
    19b4:	ec86                	sd	ra,88(sp)
    19b6:	e8a2                	sd	s0,80(sp)
    19b8:	e0ca                	sd	s2,64(sp)
    19ba:	1080                	addi	s0,sp,96
    19bc:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    19be:	fa840513          	addi	a0,s0,-88
    19c2:	00004097          	auipc	ra,0x4
    19c6:	4c6080e7          	jalr	1222(ra) # 5e88 <pipe>
    19ca:	ed2d                	bnez	a0,1a44 <pipe1+0x92>
    19cc:	e4a6                	sd	s1,72(sp)
    19ce:	f852                	sd	s4,48(sp)
    19d0:	84aa                	mv	s1,a0
  pid = fork();
    19d2:	00004097          	auipc	ra,0x4
    19d6:	49e080e7          	jalr	1182(ra) # 5e70 <fork>
    19da:	8a2a                	mv	s4,a0
  if(pid == 0){
    19dc:	c949                	beqz	a0,1a6e <pipe1+0xbc>
  } else if(pid > 0){
    19de:	18a05c63          	blez	a0,1b76 <pipe1+0x1c4>
    19e2:	fc4e                	sd	s3,56(sp)
    19e4:	f456                	sd	s5,40(sp)
    close(fds[1]);
    19e6:	fac42503          	lw	a0,-84(s0)
    19ea:	00004097          	auipc	ra,0x4
    19ee:	4b6080e7          	jalr	1206(ra) # 5ea0 <close>
    total = 0;
    19f2:	8a26                	mv	s4,s1
    cc = 1;
    19f4:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    19f6:	0000ba97          	auipc	s5,0xb
    19fa:	282a8a93          	addi	s5,s5,642 # cc78 <buf>
    19fe:	864e                	mv	a2,s3
    1a00:	85d6                	mv	a1,s5
    1a02:	fa842503          	lw	a0,-88(s0)
    1a06:	00004097          	auipc	ra,0x4
    1a0a:	48a080e7          	jalr	1162(ra) # 5e90 <read>
    1a0e:	10a05963          	blez	a0,1b20 <pipe1+0x16e>
    1a12:	0000b717          	auipc	a4,0xb
    1a16:	26670713          	addi	a4,a4,614 # cc78 <buf>
    1a1a:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1a1e:	00074683          	lbu	a3,0(a4)
    1a22:	0ff4f793          	zext.b	a5,s1
    1a26:	2485                	addiw	s1,s1,1
    1a28:	0cf69a63          	bne	a3,a5,1afc <pipe1+0x14a>
      for(i = 0; i < n; i++){
    1a2c:	0705                	addi	a4,a4,1
    1a2e:	fec498e3          	bne	s1,a2,1a1e <pipe1+0x6c>
      total += n;
    1a32:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1a36:	0019999b          	slliw	s3,s3,0x1
      if(cc > sizeof(buf))
    1a3a:	678d                	lui	a5,0x3
    1a3c:	fd37f1e3          	bgeu	a5,s3,19fe <pipe1+0x4c>
        cc = sizeof(buf);
    1a40:	89be                	mv	s3,a5
    1a42:	bf75                	j	19fe <pipe1+0x4c>
    1a44:	e4a6                	sd	s1,72(sp)
    1a46:	fc4e                	sd	s3,56(sp)
    1a48:	f852                	sd	s4,48(sp)
    1a4a:	f456                	sd	s5,40(sp)
    1a4c:	f05a                	sd	s6,32(sp)
    1a4e:	ec5e                	sd	s7,24(sp)
    1a50:	e862                	sd	s8,16(sp)
    printf("%s: pipe() failed\n", s);
    1a52:	85ca                	mv	a1,s2
    1a54:	00005517          	auipc	a0,0x5
    1a58:	32450513          	addi	a0,a0,804 # 6d78 <malloc+0xace>
    1a5c:	00004097          	auipc	ra,0x4
    1a60:	792080e7          	jalr	1938(ra) # 61ee <printf>
    exit(1);
    1a64:	4505                	li	a0,1
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	412080e7          	jalr	1042(ra) # 5e78 <exit>
    1a6e:	fc4e                	sd	s3,56(sp)
    1a70:	f456                	sd	s5,40(sp)
    1a72:	f05a                	sd	s6,32(sp)
    1a74:	ec5e                	sd	s7,24(sp)
    1a76:	e862                	sd	s8,16(sp)
    close(fds[0]);
    1a78:	fa842503          	lw	a0,-88(s0)
    1a7c:	00004097          	auipc	ra,0x4
    1a80:	424080e7          	jalr	1060(ra) # 5ea0 <close>
    for(n = 0; n < N; n++){
    1a84:	0000bb97          	auipc	s7,0xb
    1a88:	1f4b8b93          	addi	s7,s7,500 # cc78 <buf>
    1a8c:	417004bb          	negw	s1,s7
    1a90:	0ff4f493          	zext.b	s1,s1
    1a94:	409b8993          	addi	s3,s7,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a98:	40900a93          	li	s5,1033
    1a9c:	8c5e                	mv	s8,s7
    for(n = 0; n < N; n++){
    1a9e:	6b05                	lui	s6,0x1
    1aa0:	42db0b13          	addi	s6,s6,1069 # 142d <copyinstr2+0x41>
{
    1aa4:	87de                	mv	a5,s7
        buf[i] = seq++;
    1aa6:	0097873b          	addw	a4,a5,s1
    1aaa:	00e78023          	sb	a4,0(a5) # 3000 <sbrklast+0x72>
      for(i = 0; i < SZ; i++)
    1aae:	0785                	addi	a5,a5,1
    1ab0:	ff379be3          	bne	a5,s3,1aa6 <pipe1+0xf4>
    1ab4:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1ab8:	8656                	mv	a2,s5
    1aba:	85e2                	mv	a1,s8
    1abc:	fac42503          	lw	a0,-84(s0)
    1ac0:	00004097          	auipc	ra,0x4
    1ac4:	3d8080e7          	jalr	984(ra) # 5e98 <write>
    1ac8:	01551c63          	bne	a0,s5,1ae0 <pipe1+0x12e>
    for(n = 0; n < N; n++){
    1acc:	24a5                	addiw	s1,s1,9
    1ace:	0ff4f493          	zext.b	s1,s1
    1ad2:	fd6a19e3          	bne	s4,s6,1aa4 <pipe1+0xf2>
    exit(0);
    1ad6:	4501                	li	a0,0
    1ad8:	00004097          	auipc	ra,0x4
    1adc:	3a0080e7          	jalr	928(ra) # 5e78 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1ae0:	85ca                	mv	a1,s2
    1ae2:	00005517          	auipc	a0,0x5
    1ae6:	2ae50513          	addi	a0,a0,686 # 6d90 <malloc+0xae6>
    1aea:	00004097          	auipc	ra,0x4
    1aee:	704080e7          	jalr	1796(ra) # 61ee <printf>
        exit(1);
    1af2:	4505                	li	a0,1
    1af4:	00004097          	auipc	ra,0x4
    1af8:	384080e7          	jalr	900(ra) # 5e78 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1afc:	85ca                	mv	a1,s2
    1afe:	00005517          	auipc	a0,0x5
    1b02:	2aa50513          	addi	a0,a0,682 # 6da8 <malloc+0xafe>
    1b06:	00004097          	auipc	ra,0x4
    1b0a:	6e8080e7          	jalr	1768(ra) # 61ee <printf>
          return;
    1b0e:	64a6                	ld	s1,72(sp)
    1b10:	79e2                	ld	s3,56(sp)
    1b12:	7a42                	ld	s4,48(sp)
    1b14:	7aa2                	ld	s5,40(sp)
}
    1b16:	60e6                	ld	ra,88(sp)
    1b18:	6446                	ld	s0,80(sp)
    1b1a:	6906                	ld	s2,64(sp)
    1b1c:	6125                	addi	sp,sp,96
    1b1e:	8082                	ret
    if(total != N * SZ){
    1b20:	6785                	lui	a5,0x1
    1b22:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x41>
    1b26:	02fa0363          	beq	s4,a5,1b4c <pipe1+0x19a>
    1b2a:	f05a                	sd	s6,32(sp)
    1b2c:	ec5e                	sd	s7,24(sp)
    1b2e:	e862                	sd	s8,16(sp)
      printf("%s: pipe1 oops 3 total %d\n", total);
    1b30:	85d2                	mv	a1,s4
    1b32:	00005517          	auipc	a0,0x5
    1b36:	28e50513          	addi	a0,a0,654 # 6dc0 <malloc+0xb16>
    1b3a:	00004097          	auipc	ra,0x4
    1b3e:	6b4080e7          	jalr	1716(ra) # 61ee <printf>
      exit(1);
    1b42:	4505                	li	a0,1
    1b44:	00004097          	auipc	ra,0x4
    1b48:	334080e7          	jalr	820(ra) # 5e78 <exit>
    1b4c:	f05a                	sd	s6,32(sp)
    1b4e:	ec5e                	sd	s7,24(sp)
    1b50:	e862                	sd	s8,16(sp)
    close(fds[0]);
    1b52:	fa842503          	lw	a0,-88(s0)
    1b56:	00004097          	auipc	ra,0x4
    1b5a:	34a080e7          	jalr	842(ra) # 5ea0 <close>
    wait(&xstatus);
    1b5e:	fa440513          	addi	a0,s0,-92
    1b62:	00004097          	auipc	ra,0x4
    1b66:	31e080e7          	jalr	798(ra) # 5e80 <wait>
    exit(xstatus);
    1b6a:	fa442503          	lw	a0,-92(s0)
    1b6e:	00004097          	auipc	ra,0x4
    1b72:	30a080e7          	jalr	778(ra) # 5e78 <exit>
    1b76:	fc4e                	sd	s3,56(sp)
    1b78:	f456                	sd	s5,40(sp)
    1b7a:	f05a                	sd	s6,32(sp)
    1b7c:	ec5e                	sd	s7,24(sp)
    1b7e:	e862                	sd	s8,16(sp)
    printf("%s: fork() failed\n", s);
    1b80:	85ca                	mv	a1,s2
    1b82:	00005517          	auipc	a0,0x5
    1b86:	25e50513          	addi	a0,a0,606 # 6de0 <malloc+0xb36>
    1b8a:	00004097          	auipc	ra,0x4
    1b8e:	664080e7          	jalr	1636(ra) # 61ee <printf>
    exit(1);
    1b92:	4505                	li	a0,1
    1b94:	00004097          	auipc	ra,0x4
    1b98:	2e4080e7          	jalr	740(ra) # 5e78 <exit>

0000000000001b9c <exitwait>:
{
    1b9c:	715d                	addi	sp,sp,-80
    1b9e:	e486                	sd	ra,72(sp)
    1ba0:	e0a2                	sd	s0,64(sp)
    1ba2:	fc26                	sd	s1,56(sp)
    1ba4:	f84a                	sd	s2,48(sp)
    1ba6:	f44e                	sd	s3,40(sp)
    1ba8:	f052                	sd	s4,32(sp)
    1baa:	ec56                	sd	s5,24(sp)
    1bac:	0880                	addi	s0,sp,80
    1bae:	8aaa                	mv	s5,a0
  for(i = 0; i < 100; i++){
    1bb0:	4901                	li	s2,0
      if(wait(&xstate) != pid){
    1bb2:	fbc40993          	addi	s3,s0,-68
  for(i = 0; i < 100; i++){
    1bb6:	06400a13          	li	s4,100
    pid = fork();
    1bba:	00004097          	auipc	ra,0x4
    1bbe:	2b6080e7          	jalr	694(ra) # 5e70 <fork>
    1bc2:	84aa                	mv	s1,a0
    if(pid < 0){
    1bc4:	02054a63          	bltz	a0,1bf8 <exitwait+0x5c>
    if(pid){
    1bc8:	c151                	beqz	a0,1c4c <exitwait+0xb0>
      if(wait(&xstate) != pid){
    1bca:	854e                	mv	a0,s3
    1bcc:	00004097          	auipc	ra,0x4
    1bd0:	2b4080e7          	jalr	692(ra) # 5e80 <wait>
    1bd4:	04951063          	bne	a0,s1,1c14 <exitwait+0x78>
      if(i != xstate) {
    1bd8:	fbc42783          	lw	a5,-68(s0)
    1bdc:	05279a63          	bne	a5,s2,1c30 <exitwait+0x94>
  for(i = 0; i < 100; i++){
    1be0:	2905                	addiw	s2,s2,1
    1be2:	fd491ce3          	bne	s2,s4,1bba <exitwait+0x1e>
}
    1be6:	60a6                	ld	ra,72(sp)
    1be8:	6406                	ld	s0,64(sp)
    1bea:	74e2                	ld	s1,56(sp)
    1bec:	7942                	ld	s2,48(sp)
    1bee:	79a2                	ld	s3,40(sp)
    1bf0:	7a02                	ld	s4,32(sp)
    1bf2:	6ae2                	ld	s5,24(sp)
    1bf4:	6161                	addi	sp,sp,80
    1bf6:	8082                	ret
      printf("%s: fork failed\n", s);
    1bf8:	85d6                	mv	a1,s5
    1bfa:	00005517          	auipc	a0,0x5
    1bfe:	07650513          	addi	a0,a0,118 # 6c70 <malloc+0x9c6>
    1c02:	00004097          	auipc	ra,0x4
    1c06:	5ec080e7          	jalr	1516(ra) # 61ee <printf>
      exit(1);
    1c0a:	4505                	li	a0,1
    1c0c:	00004097          	auipc	ra,0x4
    1c10:	26c080e7          	jalr	620(ra) # 5e78 <exit>
        printf("%s: wait wrong pid\n", s);
    1c14:	85d6                	mv	a1,s5
    1c16:	00005517          	auipc	a0,0x5
    1c1a:	1e250513          	addi	a0,a0,482 # 6df8 <malloc+0xb4e>
    1c1e:	00004097          	auipc	ra,0x4
    1c22:	5d0080e7          	jalr	1488(ra) # 61ee <printf>
        exit(1);
    1c26:	4505                	li	a0,1
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	250080e7          	jalr	592(ra) # 5e78 <exit>
        printf("%s: wait wrong exit status\n", s);
    1c30:	85d6                	mv	a1,s5
    1c32:	00005517          	auipc	a0,0x5
    1c36:	1de50513          	addi	a0,a0,478 # 6e10 <malloc+0xb66>
    1c3a:	00004097          	auipc	ra,0x4
    1c3e:	5b4080e7          	jalr	1460(ra) # 61ee <printf>
        exit(1);
    1c42:	4505                	li	a0,1
    1c44:	00004097          	auipc	ra,0x4
    1c48:	234080e7          	jalr	564(ra) # 5e78 <exit>
      exit(i);
    1c4c:	854a                	mv	a0,s2
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	22a080e7          	jalr	554(ra) # 5e78 <exit>

0000000000001c56 <twochildren>:
{
    1c56:	1101                	addi	sp,sp,-32
    1c58:	ec06                	sd	ra,24(sp)
    1c5a:	e822                	sd	s0,16(sp)
    1c5c:	e426                	sd	s1,8(sp)
    1c5e:	e04a                	sd	s2,0(sp)
    1c60:	1000                	addi	s0,sp,32
    1c62:	892a                	mv	s2,a0
    1c64:	3e800493          	li	s1,1000
    int pid1 = fork();
    1c68:	00004097          	auipc	ra,0x4
    1c6c:	208080e7          	jalr	520(ra) # 5e70 <fork>
    if(pid1 < 0){
    1c70:	02054c63          	bltz	a0,1ca8 <twochildren+0x52>
    if(pid1 == 0){
    1c74:	c921                	beqz	a0,1cc4 <twochildren+0x6e>
      int pid2 = fork();
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	1fa080e7          	jalr	506(ra) # 5e70 <fork>
      if(pid2 < 0){
    1c7e:	04054763          	bltz	a0,1ccc <twochildren+0x76>
      if(pid2 == 0){
    1c82:	c13d                	beqz	a0,1ce8 <twochildren+0x92>
        wait(0);
    1c84:	4501                	li	a0,0
    1c86:	00004097          	auipc	ra,0x4
    1c8a:	1fa080e7          	jalr	506(ra) # 5e80 <wait>
        wait(0);
    1c8e:	4501                	li	a0,0
    1c90:	00004097          	auipc	ra,0x4
    1c94:	1f0080e7          	jalr	496(ra) # 5e80 <wait>
  for(int i = 0; i < 1000; i++){
    1c98:	34fd                	addiw	s1,s1,-1
    1c9a:	f4f9                	bnez	s1,1c68 <twochildren+0x12>
}
    1c9c:	60e2                	ld	ra,24(sp)
    1c9e:	6442                	ld	s0,16(sp)
    1ca0:	64a2                	ld	s1,8(sp)
    1ca2:	6902                	ld	s2,0(sp)
    1ca4:	6105                	addi	sp,sp,32
    1ca6:	8082                	ret
      printf("%s: fork failed\n", s);
    1ca8:	85ca                	mv	a1,s2
    1caa:	00005517          	auipc	a0,0x5
    1cae:	fc650513          	addi	a0,a0,-58 # 6c70 <malloc+0x9c6>
    1cb2:	00004097          	auipc	ra,0x4
    1cb6:	53c080e7          	jalr	1340(ra) # 61ee <printf>
      exit(1);
    1cba:	4505                	li	a0,1
    1cbc:	00004097          	auipc	ra,0x4
    1cc0:	1bc080e7          	jalr	444(ra) # 5e78 <exit>
      exit(0);
    1cc4:	00004097          	auipc	ra,0x4
    1cc8:	1b4080e7          	jalr	436(ra) # 5e78 <exit>
        printf("%s: fork failed\n", s);
    1ccc:	85ca                	mv	a1,s2
    1cce:	00005517          	auipc	a0,0x5
    1cd2:	fa250513          	addi	a0,a0,-94 # 6c70 <malloc+0x9c6>
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	518080e7          	jalr	1304(ra) # 61ee <printf>
        exit(1);
    1cde:	4505                	li	a0,1
    1ce0:	00004097          	auipc	ra,0x4
    1ce4:	198080e7          	jalr	408(ra) # 5e78 <exit>
        exit(0);
    1ce8:	00004097          	auipc	ra,0x4
    1cec:	190080e7          	jalr	400(ra) # 5e78 <exit>

0000000000001cf0 <forkfork>:
{
    1cf0:	7179                	addi	sp,sp,-48
    1cf2:	f406                	sd	ra,40(sp)
    1cf4:	f022                	sd	s0,32(sp)
    1cf6:	ec26                	sd	s1,24(sp)
    1cf8:	1800                	addi	s0,sp,48
    1cfa:	84aa                	mv	s1,a0
    int pid = fork();
    1cfc:	00004097          	auipc	ra,0x4
    1d00:	174080e7          	jalr	372(ra) # 5e70 <fork>
    if(pid < 0){
    1d04:	04054163          	bltz	a0,1d46 <forkfork+0x56>
    if(pid == 0){
    1d08:	cd29                	beqz	a0,1d62 <forkfork+0x72>
    int pid = fork();
    1d0a:	00004097          	auipc	ra,0x4
    1d0e:	166080e7          	jalr	358(ra) # 5e70 <fork>
    if(pid < 0){
    1d12:	02054a63          	bltz	a0,1d46 <forkfork+0x56>
    if(pid == 0){
    1d16:	c531                	beqz	a0,1d62 <forkfork+0x72>
    wait(&xstatus);
    1d18:	fdc40513          	addi	a0,s0,-36
    1d1c:	00004097          	auipc	ra,0x4
    1d20:	164080e7          	jalr	356(ra) # 5e80 <wait>
    if(xstatus != 0) {
    1d24:	fdc42783          	lw	a5,-36(s0)
    1d28:	ebbd                	bnez	a5,1d9e <forkfork+0xae>
    wait(&xstatus);
    1d2a:	fdc40513          	addi	a0,s0,-36
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	152080e7          	jalr	338(ra) # 5e80 <wait>
    if(xstatus != 0) {
    1d36:	fdc42783          	lw	a5,-36(s0)
    1d3a:	e3b5                	bnez	a5,1d9e <forkfork+0xae>
}
    1d3c:	70a2                	ld	ra,40(sp)
    1d3e:	7402                	ld	s0,32(sp)
    1d40:	64e2                	ld	s1,24(sp)
    1d42:	6145                	addi	sp,sp,48
    1d44:	8082                	ret
      printf("%s: fork failed", s);
    1d46:	85a6                	mv	a1,s1
    1d48:	00005517          	auipc	a0,0x5
    1d4c:	0e850513          	addi	a0,a0,232 # 6e30 <malloc+0xb86>
    1d50:	00004097          	auipc	ra,0x4
    1d54:	49e080e7          	jalr	1182(ra) # 61ee <printf>
      exit(1);
    1d58:	4505                	li	a0,1
    1d5a:	00004097          	auipc	ra,0x4
    1d5e:	11e080e7          	jalr	286(ra) # 5e78 <exit>
{
    1d62:	0c800493          	li	s1,200
        int pid1 = fork();
    1d66:	00004097          	auipc	ra,0x4
    1d6a:	10a080e7          	jalr	266(ra) # 5e70 <fork>
        if(pid1 < 0){
    1d6e:	00054f63          	bltz	a0,1d8c <forkfork+0x9c>
        if(pid1 == 0){
    1d72:	c115                	beqz	a0,1d96 <forkfork+0xa6>
        wait(0);
    1d74:	4501                	li	a0,0
    1d76:	00004097          	auipc	ra,0x4
    1d7a:	10a080e7          	jalr	266(ra) # 5e80 <wait>
      for(int j = 0; j < 200; j++){
    1d7e:	34fd                	addiw	s1,s1,-1
    1d80:	f0fd                	bnez	s1,1d66 <forkfork+0x76>
      exit(0);
    1d82:	4501                	li	a0,0
    1d84:	00004097          	auipc	ra,0x4
    1d88:	0f4080e7          	jalr	244(ra) # 5e78 <exit>
          exit(1);
    1d8c:	4505                	li	a0,1
    1d8e:	00004097          	auipc	ra,0x4
    1d92:	0ea080e7          	jalr	234(ra) # 5e78 <exit>
          exit(0);
    1d96:	00004097          	auipc	ra,0x4
    1d9a:	0e2080e7          	jalr	226(ra) # 5e78 <exit>
      printf("%s: fork in child failed", s);
    1d9e:	85a6                	mv	a1,s1
    1da0:	00005517          	auipc	a0,0x5
    1da4:	0a050513          	addi	a0,a0,160 # 6e40 <malloc+0xb96>
    1da8:	00004097          	auipc	ra,0x4
    1dac:	446080e7          	jalr	1094(ra) # 61ee <printf>
      exit(1);
    1db0:	4505                	li	a0,1
    1db2:	00004097          	auipc	ra,0x4
    1db6:	0c6080e7          	jalr	198(ra) # 5e78 <exit>

0000000000001dba <reparent2>:
{
    1dba:	1101                	addi	sp,sp,-32
    1dbc:	ec06                	sd	ra,24(sp)
    1dbe:	e822                	sd	s0,16(sp)
    1dc0:	e426                	sd	s1,8(sp)
    1dc2:	1000                	addi	s0,sp,32
    1dc4:	32000493          	li	s1,800
    int pid1 = fork();
    1dc8:	00004097          	auipc	ra,0x4
    1dcc:	0a8080e7          	jalr	168(ra) # 5e70 <fork>
    if(pid1 < 0){
    1dd0:	00054f63          	bltz	a0,1dee <reparent2+0x34>
    if(pid1 == 0){
    1dd4:	c915                	beqz	a0,1e08 <reparent2+0x4e>
    wait(0);
    1dd6:	4501                	li	a0,0
    1dd8:	00004097          	auipc	ra,0x4
    1ddc:	0a8080e7          	jalr	168(ra) # 5e80 <wait>
  for(int i = 0; i < 800; i++){
    1de0:	34fd                	addiw	s1,s1,-1
    1de2:	f0fd                	bnez	s1,1dc8 <reparent2+0xe>
  exit(0);
    1de4:	4501                	li	a0,0
    1de6:	00004097          	auipc	ra,0x4
    1dea:	092080e7          	jalr	146(ra) # 5e78 <exit>
      printf("fork failed\n");
    1dee:	00005517          	auipc	a0,0x5
    1df2:	28a50513          	addi	a0,a0,650 # 7078 <malloc+0xdce>
    1df6:	00004097          	auipc	ra,0x4
    1dfa:	3f8080e7          	jalr	1016(ra) # 61ee <printf>
      exit(1);
    1dfe:	4505                	li	a0,1
    1e00:	00004097          	auipc	ra,0x4
    1e04:	078080e7          	jalr	120(ra) # 5e78 <exit>
      fork();
    1e08:	00004097          	auipc	ra,0x4
    1e0c:	068080e7          	jalr	104(ra) # 5e70 <fork>
      fork();
    1e10:	00004097          	auipc	ra,0x4
    1e14:	060080e7          	jalr	96(ra) # 5e70 <fork>
      exit(0);
    1e18:	4501                	li	a0,0
    1e1a:	00004097          	auipc	ra,0x4
    1e1e:	05e080e7          	jalr	94(ra) # 5e78 <exit>

0000000000001e22 <createdelete>:
{
    1e22:	7175                	addi	sp,sp,-144
    1e24:	e506                	sd	ra,136(sp)
    1e26:	e122                	sd	s0,128(sp)
    1e28:	fca6                	sd	s1,120(sp)
    1e2a:	f8ca                	sd	s2,112(sp)
    1e2c:	f4ce                	sd	s3,104(sp)
    1e2e:	f0d2                	sd	s4,96(sp)
    1e30:	ecd6                	sd	s5,88(sp)
    1e32:	e8da                	sd	s6,80(sp)
    1e34:	e4de                	sd	s7,72(sp)
    1e36:	e0e2                	sd	s8,64(sp)
    1e38:	fc66                	sd	s9,56(sp)
    1e3a:	f86a                	sd	s10,48(sp)
    1e3c:	0900                	addi	s0,sp,144
    1e3e:	8d2a                	mv	s10,a0
  for(pi = 0; pi < NCHILD; pi++){
    1e40:	4901                	li	s2,0
    1e42:	4991                	li	s3,4
    pid = fork();
    1e44:	00004097          	auipc	ra,0x4
    1e48:	02c080e7          	jalr	44(ra) # 5e70 <fork>
    1e4c:	84aa                	mv	s1,a0
    if(pid < 0){
    1e4e:	04054063          	bltz	a0,1e8e <createdelete+0x6c>
    if(pid == 0){
    1e52:	cd21                	beqz	a0,1eaa <createdelete+0x88>
  for(pi = 0; pi < NCHILD; pi++){
    1e54:	2905                	addiw	s2,s2,1
    1e56:	ff3917e3          	bne	s2,s3,1e44 <createdelete+0x22>
    1e5a:	4491                	li	s1,4
    wait(&xstatus);
    1e5c:	f7c40993          	addi	s3,s0,-132
    1e60:	854e                	mv	a0,s3
    1e62:	00004097          	auipc	ra,0x4
    1e66:	01e080e7          	jalr	30(ra) # 5e80 <wait>
    if(xstatus != 0)
    1e6a:	f7c42903          	lw	s2,-132(s0)
    1e6e:	0e091463          	bnez	s2,1f56 <createdelete+0x134>
  for(pi = 0; pi < NCHILD; pi++){
    1e72:	34fd                	addiw	s1,s1,-1
    1e74:	f4f5                	bnez	s1,1e60 <createdelete+0x3e>
  name[0] = name[1] = name[2] = 0;
    1e76:	f8040123          	sb	zero,-126(s0)
    1e7a:	03000993          	li	s3,48
    1e7e:	5afd                	li	s5,-1
    1e80:	07000c93          	li	s9,112
      if((i == 0 || i >= N/2) && fd < 0){
    1e84:	4ba5                	li	s7,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1e86:	4c21                	li	s8,8
    for(pi = 0; pi < NCHILD; pi++){
    1e88:	07400b13          	li	s6,116
    1e8c:	a295                	j	1ff0 <createdelete+0x1ce>
      printf("fork failed\n", s);
    1e8e:	85ea                	mv	a1,s10
    1e90:	00005517          	auipc	a0,0x5
    1e94:	1e850513          	addi	a0,a0,488 # 7078 <malloc+0xdce>
    1e98:	00004097          	auipc	ra,0x4
    1e9c:	356080e7          	jalr	854(ra) # 61ee <printf>
      exit(1);
    1ea0:	4505                	li	a0,1
    1ea2:	00004097          	auipc	ra,0x4
    1ea6:	fd6080e7          	jalr	-42(ra) # 5e78 <exit>
      name[0] = 'p' + pi;
    1eaa:	0709091b          	addiw	s2,s2,112
    1eae:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1eb2:	f8040123          	sb	zero,-126(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1eb6:	f8040913          	addi	s2,s0,-128
    1eba:	20200993          	li	s3,514
      for(i = 0; i < N; i++){
    1ebe:	4a51                	li	s4,20
    1ec0:	a081                	j	1f00 <createdelete+0xde>
          printf("%s: create failed\n", s);
    1ec2:	85ea                	mv	a1,s10
    1ec4:	00005517          	auipc	a0,0x5
    1ec8:	e4450513          	addi	a0,a0,-444 # 6d08 <malloc+0xa5e>
    1ecc:	00004097          	auipc	ra,0x4
    1ed0:	322080e7          	jalr	802(ra) # 61ee <printf>
          exit(1);
    1ed4:	4505                	li	a0,1
    1ed6:	00004097          	auipc	ra,0x4
    1eda:	fa2080e7          	jalr	-94(ra) # 5e78 <exit>
          name[1] = '0' + (i / 2);
    1ede:	01f4d79b          	srliw	a5,s1,0x1f
    1ee2:	9fa5                	addw	a5,a5,s1
    1ee4:	4017d79b          	sraiw	a5,a5,0x1
    1ee8:	0307879b          	addiw	a5,a5,48
    1eec:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1ef0:	854a                	mv	a0,s2
    1ef2:	00004097          	auipc	ra,0x4
    1ef6:	fd6080e7          	jalr	-42(ra) # 5ec8 <unlink>
    1efa:	04054063          	bltz	a0,1f3a <createdelete+0x118>
      for(i = 0; i < N; i++){
    1efe:	2485                	addiw	s1,s1,1
        name[1] = '0' + i;
    1f00:	0304879b          	addiw	a5,s1,48
    1f04:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1f08:	85ce                	mv	a1,s3
    1f0a:	854a                	mv	a0,s2
    1f0c:	00004097          	auipc	ra,0x4
    1f10:	fac080e7          	jalr	-84(ra) # 5eb8 <open>
        if(fd < 0){
    1f14:	fa0547e3          	bltz	a0,1ec2 <createdelete+0xa0>
        close(fd);
    1f18:	00004097          	auipc	ra,0x4
    1f1c:	f88080e7          	jalr	-120(ra) # 5ea0 <close>
        if(i > 0 && (i % 2 ) == 0){
    1f20:	fc905fe3          	blez	s1,1efe <createdelete+0xdc>
    1f24:	0014f793          	andi	a5,s1,1
    1f28:	dbdd                	beqz	a5,1ede <createdelete+0xbc>
      for(i = 0; i < N; i++){
    1f2a:	2485                	addiw	s1,s1,1
    1f2c:	fd449ae3          	bne	s1,s4,1f00 <createdelete+0xde>
      exit(0);
    1f30:	4501                	li	a0,0
    1f32:	00004097          	auipc	ra,0x4
    1f36:	f46080e7          	jalr	-186(ra) # 5e78 <exit>
            printf("%s: unlink failed\n", s);
    1f3a:	85ea                	mv	a1,s10
    1f3c:	00005517          	auipc	a0,0x5
    1f40:	f2450513          	addi	a0,a0,-220 # 6e60 <malloc+0xbb6>
    1f44:	00004097          	auipc	ra,0x4
    1f48:	2aa080e7          	jalr	682(ra) # 61ee <printf>
            exit(1);
    1f4c:	4505                	li	a0,1
    1f4e:	00004097          	auipc	ra,0x4
    1f52:	f2a080e7          	jalr	-214(ra) # 5e78 <exit>
      exit(1);
    1f56:	4505                	li	a0,1
    1f58:	00004097          	auipc	ra,0x4
    1f5c:	f20080e7          	jalr	-224(ra) # 5e78 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1f60:	f8040613          	addi	a2,s0,-128
    1f64:	85ea                	mv	a1,s10
    1f66:	00005517          	auipc	a0,0x5
    1f6a:	f1250513          	addi	a0,a0,-238 # 6e78 <malloc+0xbce>
    1f6e:	00004097          	auipc	ra,0x4
    1f72:	280080e7          	jalr	640(ra) # 61ee <printf>
        exit(1);
    1f76:	4505                	li	a0,1
    1f78:	00004097          	auipc	ra,0x4
    1f7c:	f00080e7          	jalr	-256(ra) # 5e78 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f80:	035c7e63          	bgeu	s8,s5,1fbc <createdelete+0x19a>
      if(fd >= 0)
    1f84:	02055763          	bgez	a0,1fb2 <createdelete+0x190>
    for(pi = 0; pi < NCHILD; pi++){
    1f88:	2485                	addiw	s1,s1,1
    1f8a:	0ff4f493          	zext.b	s1,s1
    1f8e:	05648963          	beq	s1,s6,1fe0 <createdelete+0x1be>
      name[0] = 'p' + pi;
    1f92:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1f96:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1f9a:	4581                	li	a1,0
    1f9c:	8552                	mv	a0,s4
    1f9e:	00004097          	auipc	ra,0x4
    1fa2:	f1a080e7          	jalr	-230(ra) # 5eb8 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1fa6:	00090463          	beqz	s2,1fae <createdelete+0x18c>
    1faa:	fd2bdbe3          	bge	s7,s2,1f80 <createdelete+0x15e>
    1fae:	fa0549e3          	bltz	a0,1f60 <createdelete+0x13e>
        close(fd);
    1fb2:	00004097          	auipc	ra,0x4
    1fb6:	eee080e7          	jalr	-274(ra) # 5ea0 <close>
    1fba:	b7f9                	j	1f88 <createdelete+0x166>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1fbc:	fc0546e3          	bltz	a0,1f88 <createdelete+0x166>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1fc0:	f8040613          	addi	a2,s0,-128
    1fc4:	85ea                	mv	a1,s10
    1fc6:	00005517          	auipc	a0,0x5
    1fca:	eda50513          	addi	a0,a0,-294 # 6ea0 <malloc+0xbf6>
    1fce:	00004097          	auipc	ra,0x4
    1fd2:	220080e7          	jalr	544(ra) # 61ee <printf>
        exit(1);
    1fd6:	4505                	li	a0,1
    1fd8:	00004097          	auipc	ra,0x4
    1fdc:	ea0080e7          	jalr	-352(ra) # 5e78 <exit>
  for(i = 0; i < N; i++){
    1fe0:	2905                	addiw	s2,s2,1
    1fe2:	2a85                	addiw	s5,s5,1
    1fe4:	2985                	addiw	s3,s3,1
    1fe6:	0ff9f993          	zext.b	s3,s3
    1fea:	47d1                	li	a5,20
    1fec:	00f90663          	beq	s2,a5,1ff8 <createdelete+0x1d6>
    for(pi = 0; pi < NCHILD; pi++){
    1ff0:	84e6                	mv	s1,s9
      fd = open(name, 0);
    1ff2:	f8040a13          	addi	s4,s0,-128
    1ff6:	bf71                	j	1f92 <createdelete+0x170>
    1ff8:	03000993          	li	s3,48
    1ffc:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    2000:	4b11                	li	s6,4
      unlink(name);
    2002:	f8040a13          	addi	s4,s0,-128
  for(i = 0; i < N; i++){
    2006:	08400a93          	li	s5,132
  name[0] = name[1] = name[2] = 0;
    200a:	84da                	mv	s1,s6
      name[0] = 'p' + i;
    200c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    2010:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    2014:	8552                	mv	a0,s4
    2016:	00004097          	auipc	ra,0x4
    201a:	eb2080e7          	jalr	-334(ra) # 5ec8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    201e:	34fd                	addiw	s1,s1,-1
    2020:	f4f5                	bnez	s1,200c <createdelete+0x1ea>
  for(i = 0; i < N; i++){
    2022:	2905                	addiw	s2,s2,1
    2024:	0ff97913          	zext.b	s2,s2
    2028:	2985                	addiw	s3,s3,1
    202a:	0ff9f993          	zext.b	s3,s3
    202e:	fd591ee3          	bne	s2,s5,200a <createdelete+0x1e8>
}
    2032:	60aa                	ld	ra,136(sp)
    2034:	640a                	ld	s0,128(sp)
    2036:	74e6                	ld	s1,120(sp)
    2038:	7946                	ld	s2,112(sp)
    203a:	79a6                	ld	s3,104(sp)
    203c:	7a06                	ld	s4,96(sp)
    203e:	6ae6                	ld	s5,88(sp)
    2040:	6b46                	ld	s6,80(sp)
    2042:	6ba6                	ld	s7,72(sp)
    2044:	6c06                	ld	s8,64(sp)
    2046:	7ce2                	ld	s9,56(sp)
    2048:	7d42                	ld	s10,48(sp)
    204a:	6149                	addi	sp,sp,144
    204c:	8082                	ret

000000000000204e <linkunlink>:
{
    204e:	711d                	addi	sp,sp,-96
    2050:	ec86                	sd	ra,88(sp)
    2052:	e8a2                	sd	s0,80(sp)
    2054:	e4a6                	sd	s1,72(sp)
    2056:	e0ca                	sd	s2,64(sp)
    2058:	fc4e                	sd	s3,56(sp)
    205a:	f852                	sd	s4,48(sp)
    205c:	f456                	sd	s5,40(sp)
    205e:	f05a                	sd	s6,32(sp)
    2060:	ec5e                	sd	s7,24(sp)
    2062:	e862                	sd	s8,16(sp)
    2064:	e466                	sd	s9,8(sp)
    2066:	e06a                	sd	s10,0(sp)
    2068:	1080                	addi	s0,sp,96
    206a:	84aa                	mv	s1,a0
  unlink("x");
    206c:	00004517          	auipc	a0,0x4
    2070:	3ec50513          	addi	a0,a0,1004 # 6458 <malloc+0x1ae>
    2074:	00004097          	auipc	ra,0x4
    2078:	e54080e7          	jalr	-428(ra) # 5ec8 <unlink>
  pid = fork();
    207c:	00004097          	auipc	ra,0x4
    2080:	df4080e7          	jalr	-524(ra) # 5e70 <fork>
  if(pid < 0){
    2084:	04054363          	bltz	a0,20ca <linkunlink+0x7c>
    2088:	8d2a                	mv	s10,a0
  unsigned int x = (pid ? 1 : 97);
    208a:	06100913          	li	s2,97
    208e:	c111                	beqz	a0,2092 <linkunlink+0x44>
    2090:	4905                	li	s2,1
    2092:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2096:	41c65ab7          	lui	s5,0x41c65
    209a:	e6da8a9b          	addiw	s5,s5,-403 # 41c64e6d <base+0x41c551f5>
    209e:	6a0d                	lui	s4,0x3
    20a0:	039a0a1b          	addiw	s4,s4,57 # 3039 <sbrklast+0xab>
    if((x % 3) == 0){
    20a4:	000ab9b7          	lui	s3,0xab
    20a8:	aab98993          	addi	s3,s3,-1365 # aaaab <base+0x9ae33>
    20ac:	09b2                	slli	s3,s3,0xc
    20ae:	aab98993          	addi	s3,s3,-1365
    } else if((x % 3) == 1){
    20b2:	4b85                	li	s7,1
      unlink("x");
    20b4:	00004b17          	auipc	s6,0x4
    20b8:	3a4b0b13          	addi	s6,s6,932 # 6458 <malloc+0x1ae>
      link("cat", "x");
    20bc:	00005c97          	auipc	s9,0x5
    20c0:	e0cc8c93          	addi	s9,s9,-500 # 6ec8 <malloc+0xc1e>
      close(open("x", O_RDWR | O_CREATE));
    20c4:	20200c13          	li	s8,514
    20c8:	a089                	j	210a <linkunlink+0xbc>
    printf("%s: fork failed\n", s);
    20ca:	85a6                	mv	a1,s1
    20cc:	00005517          	auipc	a0,0x5
    20d0:	ba450513          	addi	a0,a0,-1116 # 6c70 <malloc+0x9c6>
    20d4:	00004097          	auipc	ra,0x4
    20d8:	11a080e7          	jalr	282(ra) # 61ee <printf>
    exit(1);
    20dc:	4505                	li	a0,1
    20de:	00004097          	auipc	ra,0x4
    20e2:	d9a080e7          	jalr	-614(ra) # 5e78 <exit>
      close(open("x", O_RDWR | O_CREATE));
    20e6:	85e2                	mv	a1,s8
    20e8:	855a                	mv	a0,s6
    20ea:	00004097          	auipc	ra,0x4
    20ee:	dce080e7          	jalr	-562(ra) # 5eb8 <open>
    20f2:	00004097          	auipc	ra,0x4
    20f6:	dae080e7          	jalr	-594(ra) # 5ea0 <close>
    20fa:	a031                	j	2106 <linkunlink+0xb8>
      unlink("x");
    20fc:	855a                	mv	a0,s6
    20fe:	00004097          	auipc	ra,0x4
    2102:	dca080e7          	jalr	-566(ra) # 5ec8 <unlink>
  for(i = 0; i < 100; i++){
    2106:	34fd                	addiw	s1,s1,-1
    2108:	c895                	beqz	s1,213c <linkunlink+0xee>
    x = x * 1103515245 + 12345;
    210a:	035907bb          	mulw	a5,s2,s5
    210e:	00fa07bb          	addw	a5,s4,a5
    2112:	893e                	mv	s2,a5
    if((x % 3) == 0){
    2114:	02079713          	slli	a4,a5,0x20
    2118:	9301                	srli	a4,a4,0x20
    211a:	03370733          	mul	a4,a4,s3
    211e:	9305                	srli	a4,a4,0x21
    2120:	0017169b          	slliw	a3,a4,0x1
    2124:	9f35                	addw	a4,a4,a3
    2126:	9f99                	subw	a5,a5,a4
    2128:	dfdd                	beqz	a5,20e6 <linkunlink+0x98>
    } else if((x % 3) == 1){
    212a:	fd7799e3          	bne	a5,s7,20fc <linkunlink+0xae>
      link("cat", "x");
    212e:	85da                	mv	a1,s6
    2130:	8566                	mv	a0,s9
    2132:	00004097          	auipc	ra,0x4
    2136:	da6080e7          	jalr	-602(ra) # 5ed8 <link>
    213a:	b7f1                	j	2106 <linkunlink+0xb8>
  if(pid)
    213c:	020d0563          	beqz	s10,2166 <linkunlink+0x118>
    wait(0);
    2140:	4501                	li	a0,0
    2142:	00004097          	auipc	ra,0x4
    2146:	d3e080e7          	jalr	-706(ra) # 5e80 <wait>
}
    214a:	60e6                	ld	ra,88(sp)
    214c:	6446                	ld	s0,80(sp)
    214e:	64a6                	ld	s1,72(sp)
    2150:	6906                	ld	s2,64(sp)
    2152:	79e2                	ld	s3,56(sp)
    2154:	7a42                	ld	s4,48(sp)
    2156:	7aa2                	ld	s5,40(sp)
    2158:	7b02                	ld	s6,32(sp)
    215a:	6be2                	ld	s7,24(sp)
    215c:	6c42                	ld	s8,16(sp)
    215e:	6ca2                	ld	s9,8(sp)
    2160:	6d02                	ld	s10,0(sp)
    2162:	6125                	addi	sp,sp,96
    2164:	8082                	ret
    exit(0);
    2166:	4501                	li	a0,0
    2168:	00004097          	auipc	ra,0x4
    216c:	d10080e7          	jalr	-752(ra) # 5e78 <exit>

0000000000002170 <forktest>:
{
    2170:	7179                	addi	sp,sp,-48
    2172:	f406                	sd	ra,40(sp)
    2174:	f022                	sd	s0,32(sp)
    2176:	ec26                	sd	s1,24(sp)
    2178:	e84a                	sd	s2,16(sp)
    217a:	e44e                	sd	s3,8(sp)
    217c:	1800                	addi	s0,sp,48
    217e:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    2180:	4481                	li	s1,0
    2182:	3e800913          	li	s2,1000
    pid = fork();
    2186:	00004097          	auipc	ra,0x4
    218a:	cea080e7          	jalr	-790(ra) # 5e70 <fork>
    if(pid < 0)
    218e:	08054263          	bltz	a0,2212 <forktest+0xa2>
    if(pid == 0)
    2192:	c115                	beqz	a0,21b6 <forktest+0x46>
  for(n=0; n<N; n++){
    2194:	2485                	addiw	s1,s1,1
    2196:	ff2498e3          	bne	s1,s2,2186 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    219a:	85ce                	mv	a1,s3
    219c:	00005517          	auipc	a0,0x5
    21a0:	d7c50513          	addi	a0,a0,-644 # 6f18 <malloc+0xc6e>
    21a4:	00004097          	auipc	ra,0x4
    21a8:	04a080e7          	jalr	74(ra) # 61ee <printf>
    exit(1);
    21ac:	4505                	li	a0,1
    21ae:	00004097          	auipc	ra,0x4
    21b2:	cca080e7          	jalr	-822(ra) # 5e78 <exit>
      exit(0);
    21b6:	00004097          	auipc	ra,0x4
    21ba:	cc2080e7          	jalr	-830(ra) # 5e78 <exit>
    printf("%s: no fork at all!\n", s);
    21be:	85ce                	mv	a1,s3
    21c0:	00005517          	auipc	a0,0x5
    21c4:	d1050513          	addi	a0,a0,-752 # 6ed0 <malloc+0xc26>
    21c8:	00004097          	auipc	ra,0x4
    21cc:	026080e7          	jalr	38(ra) # 61ee <printf>
    exit(1);
    21d0:	4505                	li	a0,1
    21d2:	00004097          	auipc	ra,0x4
    21d6:	ca6080e7          	jalr	-858(ra) # 5e78 <exit>
      printf("%s: wait stopped early\n", s);
    21da:	85ce                	mv	a1,s3
    21dc:	00005517          	auipc	a0,0x5
    21e0:	d0c50513          	addi	a0,a0,-756 # 6ee8 <malloc+0xc3e>
    21e4:	00004097          	auipc	ra,0x4
    21e8:	00a080e7          	jalr	10(ra) # 61ee <printf>
      exit(1);
    21ec:	4505                	li	a0,1
    21ee:	00004097          	auipc	ra,0x4
    21f2:	c8a080e7          	jalr	-886(ra) # 5e78 <exit>
    printf("%s: wait got too many\n", s);
    21f6:	85ce                	mv	a1,s3
    21f8:	00005517          	auipc	a0,0x5
    21fc:	d0850513          	addi	a0,a0,-760 # 6f00 <malloc+0xc56>
    2200:	00004097          	auipc	ra,0x4
    2204:	fee080e7          	jalr	-18(ra) # 61ee <printf>
    exit(1);
    2208:	4505                	li	a0,1
    220a:	00004097          	auipc	ra,0x4
    220e:	c6e080e7          	jalr	-914(ra) # 5e78 <exit>
  if (n == 0) {
    2212:	d4d5                	beqz	s1,21be <forktest+0x4e>
    if(wait(0) < 0){
    2214:	4501                	li	a0,0
    2216:	00004097          	auipc	ra,0x4
    221a:	c6a080e7          	jalr	-918(ra) # 5e80 <wait>
    221e:	fa054ee3          	bltz	a0,21da <forktest+0x6a>
  for(; n > 0; n--){
    2222:	34fd                	addiw	s1,s1,-1
    2224:	fe9048e3          	bgtz	s1,2214 <forktest+0xa4>
  if(wait(0) != -1){
    2228:	4501                	li	a0,0
    222a:	00004097          	auipc	ra,0x4
    222e:	c56080e7          	jalr	-938(ra) # 5e80 <wait>
    2232:	57fd                	li	a5,-1
    2234:	fcf511e3          	bne	a0,a5,21f6 <forktest+0x86>
}
    2238:	70a2                	ld	ra,40(sp)
    223a:	7402                	ld	s0,32(sp)
    223c:	64e2                	ld	s1,24(sp)
    223e:	6942                	ld	s2,16(sp)
    2240:	69a2                	ld	s3,8(sp)
    2242:	6145                	addi	sp,sp,48
    2244:	8082                	ret

0000000000002246 <kernmem>:
{
    2246:	715d                	addi	sp,sp,-80
    2248:	e486                	sd	ra,72(sp)
    224a:	e0a2                	sd	s0,64(sp)
    224c:	fc26                	sd	s1,56(sp)
    224e:	f84a                	sd	s2,48(sp)
    2250:	f44e                	sd	s3,40(sp)
    2252:	f052                	sd	s4,32(sp)
    2254:	ec56                	sd	s5,24(sp)
    2256:	e85a                	sd	s6,16(sp)
    2258:	0880                	addi	s0,sp,80
    225a:	8b2a                	mv	s6,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    225c:	4485                	li	s1,1
    225e:	04fe                	slli	s1,s1,0x1f
    wait(&xstatus);
    2260:	fbc40a93          	addi	s5,s0,-68
    if(xstatus != -1)  // did kernel kill child?
    2264:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2266:	69b1                	lui	s3,0xc
    2268:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    226c:	1003d937          	lui	s2,0x1003d
    2270:	090e                	slli	s2,s2,0x3
    2272:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    2276:	00004097          	auipc	ra,0x4
    227a:	bfa080e7          	jalr	-1030(ra) # 5e70 <fork>
    if(pid < 0){
    227e:	02054963          	bltz	a0,22b0 <kernmem+0x6a>
    if(pid == 0){
    2282:	c529                	beqz	a0,22cc <kernmem+0x86>
    wait(&xstatus);
    2284:	8556                	mv	a0,s5
    2286:	00004097          	auipc	ra,0x4
    228a:	bfa080e7          	jalr	-1030(ra) # 5e80 <wait>
    if(xstatus != -1)  // did kernel kill child?
    228e:	fbc42783          	lw	a5,-68(s0)
    2292:	05479e63          	bne	a5,s4,22ee <kernmem+0xa8>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2296:	94ce                	add	s1,s1,s3
    2298:	fd249fe3          	bne	s1,s2,2276 <kernmem+0x30>
}
    229c:	60a6                	ld	ra,72(sp)
    229e:	6406                	ld	s0,64(sp)
    22a0:	74e2                	ld	s1,56(sp)
    22a2:	7942                	ld	s2,48(sp)
    22a4:	79a2                	ld	s3,40(sp)
    22a6:	7a02                	ld	s4,32(sp)
    22a8:	6ae2                	ld	s5,24(sp)
    22aa:	6b42                	ld	s6,16(sp)
    22ac:	6161                	addi	sp,sp,80
    22ae:	8082                	ret
      printf("%s: fork failed\n", s);
    22b0:	85da                	mv	a1,s6
    22b2:	00005517          	auipc	a0,0x5
    22b6:	9be50513          	addi	a0,a0,-1602 # 6c70 <malloc+0x9c6>
    22ba:	00004097          	auipc	ra,0x4
    22be:	f34080e7          	jalr	-204(ra) # 61ee <printf>
      exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00004097          	auipc	ra,0x4
    22c8:	bb4080e7          	jalr	-1100(ra) # 5e78 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    22cc:	0004c683          	lbu	a3,0(s1)
    22d0:	8626                	mv	a2,s1
    22d2:	85da                	mv	a1,s6
    22d4:	00005517          	auipc	a0,0x5
    22d8:	c6c50513          	addi	a0,a0,-916 # 6f40 <malloc+0xc96>
    22dc:	00004097          	auipc	ra,0x4
    22e0:	f12080e7          	jalr	-238(ra) # 61ee <printf>
      exit(1);
    22e4:	4505                	li	a0,1
    22e6:	00004097          	auipc	ra,0x4
    22ea:	b92080e7          	jalr	-1134(ra) # 5e78 <exit>
      exit(1);
    22ee:	4505                	li	a0,1
    22f0:	00004097          	auipc	ra,0x4
    22f4:	b88080e7          	jalr	-1144(ra) # 5e78 <exit>

00000000000022f8 <MAXVAplus>:
{
    22f8:	7139                	addi	sp,sp,-64
    22fa:	fc06                	sd	ra,56(sp)
    22fc:	f822                	sd	s0,48(sp)
    22fe:	0080                	addi	s0,sp,64
  volatile uint64 a = MAXVA;
    2300:	4785                	li	a5,1
    2302:	179a                	slli	a5,a5,0x26
    2304:	fcf43423          	sd	a5,-56(s0)
  for( ; a != 0; a <<= 1){
    2308:	fc843783          	ld	a5,-56(s0)
    230c:	c3b9                	beqz	a5,2352 <MAXVAplus+0x5a>
    230e:	f426                	sd	s1,40(sp)
    2310:	f04a                	sd	s2,32(sp)
    2312:	ec4e                	sd	s3,24(sp)
    2314:	89aa                	mv	s3,a0
    wait(&xstatus);
    2316:	fc440913          	addi	s2,s0,-60
    if(xstatus != -1)  // did kernel kill child?
    231a:	54fd                	li	s1,-1
    pid = fork();
    231c:	00004097          	auipc	ra,0x4
    2320:	b54080e7          	jalr	-1196(ra) # 5e70 <fork>
    if(pid < 0){
    2324:	02054b63          	bltz	a0,235a <MAXVAplus+0x62>
    if(pid == 0){
    2328:	c539                	beqz	a0,2376 <MAXVAplus+0x7e>
    wait(&xstatus);
    232a:	854a                	mv	a0,s2
    232c:	00004097          	auipc	ra,0x4
    2330:	b54080e7          	jalr	-1196(ra) # 5e80 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2334:	fc442783          	lw	a5,-60(s0)
    2338:	06979563          	bne	a5,s1,23a2 <MAXVAplus+0xaa>
  for( ; a != 0; a <<= 1){
    233c:	fc843783          	ld	a5,-56(s0)
    2340:	0786                	slli	a5,a5,0x1
    2342:	fcf43423          	sd	a5,-56(s0)
    2346:	fc843783          	ld	a5,-56(s0)
    234a:	fbe9                	bnez	a5,231c <MAXVAplus+0x24>
    234c:	74a2                	ld	s1,40(sp)
    234e:	7902                	ld	s2,32(sp)
    2350:	69e2                	ld	s3,24(sp)
}
    2352:	70e2                	ld	ra,56(sp)
    2354:	7442                	ld	s0,48(sp)
    2356:	6121                	addi	sp,sp,64
    2358:	8082                	ret
      printf("%s: fork failed\n", s);
    235a:	85ce                	mv	a1,s3
    235c:	00005517          	auipc	a0,0x5
    2360:	91450513          	addi	a0,a0,-1772 # 6c70 <malloc+0x9c6>
    2364:	00004097          	auipc	ra,0x4
    2368:	e8a080e7          	jalr	-374(ra) # 61ee <printf>
      exit(1);
    236c:	4505                	li	a0,1
    236e:	00004097          	auipc	ra,0x4
    2372:	b0a080e7          	jalr	-1270(ra) # 5e78 <exit>
      *(char*)a = 99;
    2376:	fc843783          	ld	a5,-56(s0)
    237a:	06300713          	li	a4,99
    237e:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    2382:	fc843603          	ld	a2,-56(s0)
    2386:	85ce                	mv	a1,s3
    2388:	00005517          	auipc	a0,0x5
    238c:	bd850513          	addi	a0,a0,-1064 # 6f60 <malloc+0xcb6>
    2390:	00004097          	auipc	ra,0x4
    2394:	e5e080e7          	jalr	-418(ra) # 61ee <printf>
      exit(1);
    2398:	4505                	li	a0,1
    239a:	00004097          	auipc	ra,0x4
    239e:	ade080e7          	jalr	-1314(ra) # 5e78 <exit>
      exit(1);
    23a2:	4505                	li	a0,1
    23a4:	00004097          	auipc	ra,0x4
    23a8:	ad4080e7          	jalr	-1324(ra) # 5e78 <exit>

00000000000023ac <bigargtest>:
{
    23ac:	7179                	addi	sp,sp,-48
    23ae:	f406                	sd	ra,40(sp)
    23b0:	f022                	sd	s0,32(sp)
    23b2:	ec26                	sd	s1,24(sp)
    23b4:	1800                	addi	s0,sp,48
    23b6:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    23b8:	00005517          	auipc	a0,0x5
    23bc:	bc050513          	addi	a0,a0,-1088 # 6f78 <malloc+0xcce>
    23c0:	00004097          	auipc	ra,0x4
    23c4:	b08080e7          	jalr	-1272(ra) # 5ec8 <unlink>
  pid = fork();
    23c8:	00004097          	auipc	ra,0x4
    23cc:	aa8080e7          	jalr	-1368(ra) # 5e70 <fork>
  if(pid == 0){
    23d0:	c121                	beqz	a0,2410 <bigargtest+0x64>
  } else if(pid < 0){
    23d2:	0a054063          	bltz	a0,2472 <bigargtest+0xc6>
  wait(&xstatus);
    23d6:	fdc40513          	addi	a0,s0,-36
    23da:	00004097          	auipc	ra,0x4
    23de:	aa6080e7          	jalr	-1370(ra) # 5e80 <wait>
  if(xstatus != 0)
    23e2:	fdc42503          	lw	a0,-36(s0)
    23e6:	e545                	bnez	a0,248e <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    23e8:	4581                	li	a1,0
    23ea:	00005517          	auipc	a0,0x5
    23ee:	b8e50513          	addi	a0,a0,-1138 # 6f78 <malloc+0xcce>
    23f2:	00004097          	auipc	ra,0x4
    23f6:	ac6080e7          	jalr	-1338(ra) # 5eb8 <open>
  if(fd < 0){
    23fa:	08054e63          	bltz	a0,2496 <bigargtest+0xea>
  close(fd);
    23fe:	00004097          	auipc	ra,0x4
    2402:	aa2080e7          	jalr	-1374(ra) # 5ea0 <close>
}
    2406:	70a2                	ld	ra,40(sp)
    2408:	7402                	ld	s0,32(sp)
    240a:	64e2                	ld	s1,24(sp)
    240c:	6145                	addi	sp,sp,48
    240e:	8082                	ret
    2410:	00007797          	auipc	a5,0x7
    2414:	05078793          	addi	a5,a5,80 # 9460 <args.1>
    2418:	00007697          	auipc	a3,0x7
    241c:	14068693          	addi	a3,a3,320 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2420:	00005717          	auipc	a4,0x5
    2424:	b6870713          	addi	a4,a4,-1176 # 6f88 <malloc+0xcde>
    2428:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    242a:	07a1                	addi	a5,a5,8
    242c:	fed79ee3          	bne	a5,a3,2428 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2430:	00007597          	auipc	a1,0x7
    2434:	03058593          	addi	a1,a1,48 # 9460 <args.1>
    2438:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    243c:	00004517          	auipc	a0,0x4
    2440:	fac50513          	addi	a0,a0,-84 # 63e8 <malloc+0x13e>
    2444:	00004097          	auipc	ra,0x4
    2448:	a6c080e7          	jalr	-1428(ra) # 5eb0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    244c:	20000593          	li	a1,512
    2450:	00005517          	auipc	a0,0x5
    2454:	b2850513          	addi	a0,a0,-1240 # 6f78 <malloc+0xcce>
    2458:	00004097          	auipc	ra,0x4
    245c:	a60080e7          	jalr	-1440(ra) # 5eb8 <open>
    close(fd);
    2460:	00004097          	auipc	ra,0x4
    2464:	a40080e7          	jalr	-1472(ra) # 5ea0 <close>
    exit(0);
    2468:	4501                	li	a0,0
    246a:	00004097          	auipc	ra,0x4
    246e:	a0e080e7          	jalr	-1522(ra) # 5e78 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2472:	85a6                	mv	a1,s1
    2474:	00005517          	auipc	a0,0x5
    2478:	bf450513          	addi	a0,a0,-1036 # 7068 <malloc+0xdbe>
    247c:	00004097          	auipc	ra,0x4
    2480:	d72080e7          	jalr	-654(ra) # 61ee <printf>
    exit(1);
    2484:	4505                	li	a0,1
    2486:	00004097          	auipc	ra,0x4
    248a:	9f2080e7          	jalr	-1550(ra) # 5e78 <exit>
    exit(xstatus);
    248e:	00004097          	auipc	ra,0x4
    2492:	9ea080e7          	jalr	-1558(ra) # 5e78 <exit>
    printf("%s: bigarg test failed!\n", s);
    2496:	85a6                	mv	a1,s1
    2498:	00005517          	auipc	a0,0x5
    249c:	bf050513          	addi	a0,a0,-1040 # 7088 <malloc+0xdde>
    24a0:	00004097          	auipc	ra,0x4
    24a4:	d4e080e7          	jalr	-690(ra) # 61ee <printf>
    exit(1);
    24a8:	4505                	li	a0,1
    24aa:	00004097          	auipc	ra,0x4
    24ae:	9ce080e7          	jalr	-1586(ra) # 5e78 <exit>

00000000000024b2 <stacktest>:
{
    24b2:	7179                	addi	sp,sp,-48
    24b4:	f406                	sd	ra,40(sp)
    24b6:	f022                	sd	s0,32(sp)
    24b8:	ec26                	sd	s1,24(sp)
    24ba:	1800                	addi	s0,sp,48
    24bc:	84aa                	mv	s1,a0
  pid = fork();
    24be:	00004097          	auipc	ra,0x4
    24c2:	9b2080e7          	jalr	-1614(ra) # 5e70 <fork>
  if(pid == 0) {
    24c6:	c115                	beqz	a0,24ea <stacktest+0x38>
  } else if(pid < 0){
    24c8:	04054463          	bltz	a0,2510 <stacktest+0x5e>
  wait(&xstatus);
    24cc:	fdc40513          	addi	a0,s0,-36
    24d0:	00004097          	auipc	ra,0x4
    24d4:	9b0080e7          	jalr	-1616(ra) # 5e80 <wait>
  if(xstatus == -1)  // kernel killed child?
    24d8:	fdc42503          	lw	a0,-36(s0)
    24dc:	57fd                	li	a5,-1
    24de:	04f50763          	beq	a0,a5,252c <stacktest+0x7a>
    exit(xstatus);
    24e2:	00004097          	auipc	ra,0x4
    24e6:	996080e7          	jalr	-1642(ra) # 5e78 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    24ea:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    24ec:	77fd                	lui	a5,0xfffff
    24ee:	97ba                	add	a5,a5,a4
    24f0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    24f4:	85a6                	mv	a1,s1
    24f6:	00005517          	auipc	a0,0x5
    24fa:	bb250513          	addi	a0,a0,-1102 # 70a8 <malloc+0xdfe>
    24fe:	00004097          	auipc	ra,0x4
    2502:	cf0080e7          	jalr	-784(ra) # 61ee <printf>
    exit(1);
    2506:	4505                	li	a0,1
    2508:	00004097          	auipc	ra,0x4
    250c:	970080e7          	jalr	-1680(ra) # 5e78 <exit>
    printf("%s: fork failed\n", s);
    2510:	85a6                	mv	a1,s1
    2512:	00004517          	auipc	a0,0x4
    2516:	75e50513          	addi	a0,a0,1886 # 6c70 <malloc+0x9c6>
    251a:	00004097          	auipc	ra,0x4
    251e:	cd4080e7          	jalr	-812(ra) # 61ee <printf>
    exit(1);
    2522:	4505                	li	a0,1
    2524:	00004097          	auipc	ra,0x4
    2528:	954080e7          	jalr	-1708(ra) # 5e78 <exit>
    exit(0);
    252c:	4501                	li	a0,0
    252e:	00004097          	auipc	ra,0x4
    2532:	94a080e7          	jalr	-1718(ra) # 5e78 <exit>

0000000000002536 <textwrite>:
{
    2536:	7179                	addi	sp,sp,-48
    2538:	f406                	sd	ra,40(sp)
    253a:	f022                	sd	s0,32(sp)
    253c:	ec26                	sd	s1,24(sp)
    253e:	1800                	addi	s0,sp,48
    2540:	84aa                	mv	s1,a0
  pid = fork();
    2542:	00004097          	auipc	ra,0x4
    2546:	92e080e7          	jalr	-1746(ra) # 5e70 <fork>
  if(pid == 0) {
    254a:	c115                	beqz	a0,256e <textwrite+0x38>
  } else if(pid < 0){
    254c:	02054963          	bltz	a0,257e <textwrite+0x48>
  wait(&xstatus);
    2550:	fdc40513          	addi	a0,s0,-36
    2554:	00004097          	auipc	ra,0x4
    2558:	92c080e7          	jalr	-1748(ra) # 5e80 <wait>
  if(xstatus == -1)  // kernel killed child?
    255c:	fdc42503          	lw	a0,-36(s0)
    2560:	57fd                	li	a5,-1
    2562:	02f50c63          	beq	a0,a5,259a <textwrite+0x64>
    exit(xstatus);
    2566:	00004097          	auipc	ra,0x4
    256a:	912080e7          	jalr	-1774(ra) # 5e78 <exit>
    *addr = 10;
    256e:	47a9                	li	a5,10
    2570:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    2574:	4505                	li	a0,1
    2576:	00004097          	auipc	ra,0x4
    257a:	902080e7          	jalr	-1790(ra) # 5e78 <exit>
    printf("%s: fork failed\n", s);
    257e:	85a6                	mv	a1,s1
    2580:	00004517          	auipc	a0,0x4
    2584:	6f050513          	addi	a0,a0,1776 # 6c70 <malloc+0x9c6>
    2588:	00004097          	auipc	ra,0x4
    258c:	c66080e7          	jalr	-922(ra) # 61ee <printf>
    exit(1);
    2590:	4505                	li	a0,1
    2592:	00004097          	auipc	ra,0x4
    2596:	8e6080e7          	jalr	-1818(ra) # 5e78 <exit>
    exit(0);
    259a:	4501                	li	a0,0
    259c:	00004097          	auipc	ra,0x4
    25a0:	8dc080e7          	jalr	-1828(ra) # 5e78 <exit>

00000000000025a4 <manywrites>:
{
    25a4:	7159                	addi	sp,sp,-112
    25a6:	f486                	sd	ra,104(sp)
    25a8:	f0a2                	sd	s0,96(sp)
    25aa:	eca6                	sd	s1,88(sp)
    25ac:	e8ca                	sd	s2,80(sp)
    25ae:	e4ce                	sd	s3,72(sp)
    25b0:	fc56                	sd	s5,56(sp)
    25b2:	1880                	addi	s0,sp,112
    25b4:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    25b6:	4901                	li	s2,0
    25b8:	4991                	li	s3,4
    int pid = fork();
    25ba:	00004097          	auipc	ra,0x4
    25be:	8b6080e7          	jalr	-1866(ra) # 5e70 <fork>
    25c2:	84aa                	mv	s1,a0
    if(pid < 0){
    25c4:	04054163          	bltz	a0,2606 <manywrites+0x62>
    if(pid == 0){
    25c8:	c135                	beqz	a0,262c <manywrites+0x88>
  for(int ci = 0; ci < nchildren; ci++){
    25ca:	2905                	addiw	s2,s2,1
    25cc:	ff3917e3          	bne	s2,s3,25ba <manywrites+0x16>
    25d0:	4491                	li	s1,4
    wait(&st);
    25d2:	f9840913          	addi	s2,s0,-104
    int st = 0;
    25d6:	f8042c23          	sw	zero,-104(s0)
    wait(&st);
    25da:	854a                	mv	a0,s2
    25dc:	00004097          	auipc	ra,0x4
    25e0:	8a4080e7          	jalr	-1884(ra) # 5e80 <wait>
    if(st != 0)
    25e4:	f9842503          	lw	a0,-104(s0)
    25e8:	12051063          	bnez	a0,2708 <manywrites+0x164>
  for(int ci = 0; ci < nchildren; ci++){
    25ec:	34fd                	addiw	s1,s1,-1
    25ee:	f4e5                	bnez	s1,25d6 <manywrites+0x32>
    25f0:	e0d2                	sd	s4,64(sp)
    25f2:	f85a                	sd	s6,48(sp)
    25f4:	f45e                	sd	s7,40(sp)
    25f6:	f062                	sd	s8,32(sp)
    25f8:	ec66                	sd	s9,24(sp)
    25fa:	e86a                	sd	s10,16(sp)
  exit(0);
    25fc:	4501                	li	a0,0
    25fe:	00004097          	auipc	ra,0x4
    2602:	87a080e7          	jalr	-1926(ra) # 5e78 <exit>
    2606:	e0d2                	sd	s4,64(sp)
    2608:	f85a                	sd	s6,48(sp)
    260a:	f45e                	sd	s7,40(sp)
    260c:	f062                	sd	s8,32(sp)
    260e:	ec66                	sd	s9,24(sp)
    2610:	e86a                	sd	s10,16(sp)
      printf("fork failed\n");
    2612:	00005517          	auipc	a0,0x5
    2616:	a6650513          	addi	a0,a0,-1434 # 7078 <malloc+0xdce>
    261a:	00004097          	auipc	ra,0x4
    261e:	bd4080e7          	jalr	-1068(ra) # 61ee <printf>
      exit(1);
    2622:	4505                	li	a0,1
    2624:	00004097          	auipc	ra,0x4
    2628:	854080e7          	jalr	-1964(ra) # 5e78 <exit>
    262c:	e0d2                	sd	s4,64(sp)
    262e:	f85a                	sd	s6,48(sp)
    2630:	f45e                	sd	s7,40(sp)
    2632:	f062                	sd	s8,32(sp)
    2634:	ec66                	sd	s9,24(sp)
    2636:	e86a                	sd	s10,16(sp)
      name[0] = 'b';
    2638:	06200793          	li	a5,98
    263c:	f8f40c23          	sb	a5,-104(s0)
      name[1] = 'a' + ci;
    2640:	0619079b          	addiw	a5,s2,97
    2644:	f8f40ca3          	sb	a5,-103(s0)
      name[2] = '\0';
    2648:	f8040d23          	sb	zero,-102(s0)
      unlink(name);
    264c:	f9840513          	addi	a0,s0,-104
    2650:	00004097          	auipc	ra,0x4
    2654:	878080e7          	jalr	-1928(ra) # 5ec8 <unlink>
    2658:	4d79                	li	s10,30
          int fd = open(name, O_CREATE | O_RDWR);
    265a:	f9840c13          	addi	s8,s0,-104
    265e:	20200b93          	li	s7,514
          int cc = write(fd, buf, sz);
    2662:	6b0d                	lui	s6,0x3
    2664:	0000ac97          	auipc	s9,0xa
    2668:	614c8c93          	addi	s9,s9,1556 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    266c:	8a26                	mv	s4,s1
          int fd = open(name, O_CREATE | O_RDWR);
    266e:	85de                	mv	a1,s7
    2670:	8562                	mv	a0,s8
    2672:	00004097          	auipc	ra,0x4
    2676:	846080e7          	jalr	-1978(ra) # 5eb8 <open>
    267a:	89aa                	mv	s3,a0
          if(fd < 0){
    267c:	04054663          	bltz	a0,26c8 <manywrites+0x124>
          int cc = write(fd, buf, sz);
    2680:	865a                	mv	a2,s6
    2682:	85e6                	mv	a1,s9
    2684:	00004097          	auipc	ra,0x4
    2688:	814080e7          	jalr	-2028(ra) # 5e98 <write>
          if(cc != sz){
    268c:	05651e63          	bne	a0,s6,26e8 <manywrites+0x144>
          close(fd);
    2690:	854e                	mv	a0,s3
    2692:	00004097          	auipc	ra,0x4
    2696:	80e080e7          	jalr	-2034(ra) # 5ea0 <close>
        for(int i = 0; i < ci+1; i++){
    269a:	2a05                	addiw	s4,s4,1
    269c:	fd4959e3          	bge	s2,s4,266e <manywrites+0xca>
        unlink(name);
    26a0:	f9840513          	addi	a0,s0,-104
    26a4:	00004097          	auipc	ra,0x4
    26a8:	824080e7          	jalr	-2012(ra) # 5ec8 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    26ac:	3d7d                	addiw	s10,s10,-1
    26ae:	fa0d1fe3          	bnez	s10,266c <manywrites+0xc8>
      unlink(name);
    26b2:	f9840513          	addi	a0,s0,-104
    26b6:	00004097          	auipc	ra,0x4
    26ba:	812080e7          	jalr	-2030(ra) # 5ec8 <unlink>
      exit(0);
    26be:	4501                	li	a0,0
    26c0:	00003097          	auipc	ra,0x3
    26c4:	7b8080e7          	jalr	1976(ra) # 5e78 <exit>
            printf("%s: cannot create %s\n", s, name);
    26c8:	f9840613          	addi	a2,s0,-104
    26cc:	85d6                	mv	a1,s5
    26ce:	00005517          	auipc	a0,0x5
    26d2:	a0250513          	addi	a0,a0,-1534 # 70d0 <malloc+0xe26>
    26d6:	00004097          	auipc	ra,0x4
    26da:	b18080e7          	jalr	-1256(ra) # 61ee <printf>
            exit(1);
    26de:	4505                	li	a0,1
    26e0:	00003097          	auipc	ra,0x3
    26e4:	798080e7          	jalr	1944(ra) # 5e78 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    26e8:	86aa                	mv	a3,a0
    26ea:	660d                	lui	a2,0x3
    26ec:	85d6                	mv	a1,s5
    26ee:	00004517          	auipc	a0,0x4
    26f2:	dca50513          	addi	a0,a0,-566 # 64b8 <malloc+0x20e>
    26f6:	00004097          	auipc	ra,0x4
    26fa:	af8080e7          	jalr	-1288(ra) # 61ee <printf>
            exit(1);
    26fe:	4505                	li	a0,1
    2700:	00003097          	auipc	ra,0x3
    2704:	778080e7          	jalr	1912(ra) # 5e78 <exit>
    2708:	e0d2                	sd	s4,64(sp)
    270a:	f85a                	sd	s6,48(sp)
    270c:	f45e                	sd	s7,40(sp)
    270e:	f062                	sd	s8,32(sp)
    2710:	ec66                	sd	s9,24(sp)
    2712:	e86a                	sd	s10,16(sp)
      exit(st);
    2714:	00003097          	auipc	ra,0x3
    2718:	764080e7          	jalr	1892(ra) # 5e78 <exit>

000000000000271c <copyinstr3>:
{
    271c:	7179                	addi	sp,sp,-48
    271e:	f406                	sd	ra,40(sp)
    2720:	f022                	sd	s0,32(sp)
    2722:	ec26                	sd	s1,24(sp)
    2724:	1800                	addi	s0,sp,48
  sbrk(8192);
    2726:	6509                	lui	a0,0x2
    2728:	00003097          	auipc	ra,0x3
    272c:	7d8080e7          	jalr	2008(ra) # 5f00 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2730:	4501                	li	a0,0
    2732:	00003097          	auipc	ra,0x3
    2736:	7ce080e7          	jalr	1998(ra) # 5f00 <sbrk>
  if((top % PGSIZE) != 0){
    273a:	03451793          	slli	a5,a0,0x34
    273e:	e3c9                	bnez	a5,27c0 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2740:	4501                	li	a0,0
    2742:	00003097          	auipc	ra,0x3
    2746:	7be080e7          	jalr	1982(ra) # 5f00 <sbrk>
  if(top % PGSIZE){
    274a:	03451793          	slli	a5,a0,0x34
    274e:	e7c1                	bnez	a5,27d6 <copyinstr3+0xba>
  char *b = (char *) (top - 1);
    2750:	fff50493          	addi	s1,a0,-1 # 1fff <createdelete+0x1dd>
  *b = 'x';
    2754:	07800793          	li	a5,120
    2758:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    275c:	8526                	mv	a0,s1
    275e:	00003097          	auipc	ra,0x3
    2762:	76a080e7          	jalr	1898(ra) # 5ec8 <unlink>
  if(ret != -1){
    2766:	57fd                	li	a5,-1
    2768:	08f51463          	bne	a0,a5,27f0 <copyinstr3+0xd4>
  int fd = open(b, O_CREATE | O_WRONLY);
    276c:	20100593          	li	a1,513
    2770:	8526                	mv	a0,s1
    2772:	00003097          	auipc	ra,0x3
    2776:	746080e7          	jalr	1862(ra) # 5eb8 <open>
  if(fd != -1){
    277a:	57fd                	li	a5,-1
    277c:	08f51963          	bne	a0,a5,280e <copyinstr3+0xf2>
  ret = link(b, b);
    2780:	85a6                	mv	a1,s1
    2782:	8526                	mv	a0,s1
    2784:	00003097          	auipc	ra,0x3
    2788:	754080e7          	jalr	1876(ra) # 5ed8 <link>
  if(ret != -1){
    278c:	57fd                	li	a5,-1
    278e:	08f51f63          	bne	a0,a5,282c <copyinstr3+0x110>
  char *args[] = { "xx", 0 };
    2792:	00005797          	auipc	a5,0x5
    2796:	63678793          	addi	a5,a5,1590 # 7dc8 <malloc+0x1b1e>
    279a:	fcf43823          	sd	a5,-48(s0)
    279e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    27a2:	fd040593          	addi	a1,s0,-48
    27a6:	8526                	mv	a0,s1
    27a8:	00003097          	auipc	ra,0x3
    27ac:	708080e7          	jalr	1800(ra) # 5eb0 <exec>
  if(ret != -1){
    27b0:	57fd                	li	a5,-1
    27b2:	08f51d63          	bne	a0,a5,284c <copyinstr3+0x130>
}
    27b6:	70a2                	ld	ra,40(sp)
    27b8:	7402                	ld	s0,32(sp)
    27ba:	64e2                	ld	s1,24(sp)
    27bc:	6145                	addi	sp,sp,48
    27be:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    27c0:	6785                	lui	a5,0x1
    27c2:	fff78713          	addi	a4,a5,-1 # fff <linktest+0xbb>
    27c6:	8d79                	and	a0,a0,a4
    27c8:	40a7853b          	subw	a0,a5,a0
    27cc:	00003097          	auipc	ra,0x3
    27d0:	734080e7          	jalr	1844(ra) # 5f00 <sbrk>
    27d4:	b7b5                	j	2740 <copyinstr3+0x24>
    printf("oops\n");
    27d6:	00005517          	auipc	a0,0x5
    27da:	91250513          	addi	a0,a0,-1774 # 70e8 <malloc+0xe3e>
    27de:	00004097          	auipc	ra,0x4
    27e2:	a10080e7          	jalr	-1520(ra) # 61ee <printf>
    exit(1);
    27e6:	4505                	li	a0,1
    27e8:	00003097          	auipc	ra,0x3
    27ec:	690080e7          	jalr	1680(ra) # 5e78 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    27f0:	862a                	mv	a2,a0
    27f2:	85a6                	mv	a1,s1
    27f4:	00004517          	auipc	a0,0x4
    27f8:	39c50513          	addi	a0,a0,924 # 6b90 <malloc+0x8e6>
    27fc:	00004097          	auipc	ra,0x4
    2800:	9f2080e7          	jalr	-1550(ra) # 61ee <printf>
    exit(1);
    2804:	4505                	li	a0,1
    2806:	00003097          	auipc	ra,0x3
    280a:	672080e7          	jalr	1650(ra) # 5e78 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    280e:	862a                	mv	a2,a0
    2810:	85a6                	mv	a1,s1
    2812:	00004517          	auipc	a0,0x4
    2816:	39e50513          	addi	a0,a0,926 # 6bb0 <malloc+0x906>
    281a:	00004097          	auipc	ra,0x4
    281e:	9d4080e7          	jalr	-1580(ra) # 61ee <printf>
    exit(1);
    2822:	4505                	li	a0,1
    2824:	00003097          	auipc	ra,0x3
    2828:	654080e7          	jalr	1620(ra) # 5e78 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    282c:	86aa                	mv	a3,a0
    282e:	8626                	mv	a2,s1
    2830:	85a6                	mv	a1,s1
    2832:	00004517          	auipc	a0,0x4
    2836:	39e50513          	addi	a0,a0,926 # 6bd0 <malloc+0x926>
    283a:	00004097          	auipc	ra,0x4
    283e:	9b4080e7          	jalr	-1612(ra) # 61ee <printf>
    exit(1);
    2842:	4505                	li	a0,1
    2844:	00003097          	auipc	ra,0x3
    2848:	634080e7          	jalr	1588(ra) # 5e78 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    284c:	863e                	mv	a2,a5
    284e:	85a6                	mv	a1,s1
    2850:	00004517          	auipc	a0,0x4
    2854:	3a850513          	addi	a0,a0,936 # 6bf8 <malloc+0x94e>
    2858:	00004097          	auipc	ra,0x4
    285c:	996080e7          	jalr	-1642(ra) # 61ee <printf>
    exit(1);
    2860:	4505                	li	a0,1
    2862:	00003097          	auipc	ra,0x3
    2866:	616080e7          	jalr	1558(ra) # 5e78 <exit>

000000000000286a <rwsbrk>:
{
    286a:	1101                	addi	sp,sp,-32
    286c:	ec06                	sd	ra,24(sp)
    286e:	e822                	sd	s0,16(sp)
    2870:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2872:	6509                	lui	a0,0x2
    2874:	00003097          	auipc	ra,0x3
    2878:	68c080e7          	jalr	1676(ra) # 5f00 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    287c:	57fd                	li	a5,-1
    287e:	06f50463          	beq	a0,a5,28e6 <rwsbrk+0x7c>
    2882:	e426                	sd	s1,8(sp)
    2884:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2886:	7579                	lui	a0,0xffffe
    2888:	00003097          	auipc	ra,0x3
    288c:	678080e7          	jalr	1656(ra) # 5f00 <sbrk>
    2890:	57fd                	li	a5,-1
    2892:	06f50963          	beq	a0,a5,2904 <rwsbrk+0x9a>
    2896:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2898:	20100593          	li	a1,513
    289c:	00005517          	auipc	a0,0x5
    28a0:	88c50513          	addi	a0,a0,-1908 # 7128 <malloc+0xe7e>
    28a4:	00003097          	auipc	ra,0x3
    28a8:	614080e7          	jalr	1556(ra) # 5eb8 <open>
    28ac:	892a                	mv	s2,a0
  if(fd < 0){
    28ae:	06054963          	bltz	a0,2920 <rwsbrk+0xb6>
  n = write(fd, (void*)(a+4096), 1024);
    28b2:	6785                	lui	a5,0x1
    28b4:	94be                	add	s1,s1,a5
    28b6:	40000613          	li	a2,1024
    28ba:	85a6                	mv	a1,s1
    28bc:	00003097          	auipc	ra,0x3
    28c0:	5dc080e7          	jalr	1500(ra) # 5e98 <write>
    28c4:	862a                	mv	a2,a0
  if(n >= 0){
    28c6:	06054a63          	bltz	a0,293a <rwsbrk+0xd0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    28ca:	85a6                	mv	a1,s1
    28cc:	00005517          	auipc	a0,0x5
    28d0:	87c50513          	addi	a0,a0,-1924 # 7148 <malloc+0xe9e>
    28d4:	00004097          	auipc	ra,0x4
    28d8:	91a080e7          	jalr	-1766(ra) # 61ee <printf>
    exit(1);
    28dc:	4505                	li	a0,1
    28de:	00003097          	auipc	ra,0x3
    28e2:	59a080e7          	jalr	1434(ra) # 5e78 <exit>
    28e6:	e426                	sd	s1,8(sp)
    28e8:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    28ea:	00005517          	auipc	a0,0x5
    28ee:	80650513          	addi	a0,a0,-2042 # 70f0 <malloc+0xe46>
    28f2:	00004097          	auipc	ra,0x4
    28f6:	8fc080e7          	jalr	-1796(ra) # 61ee <printf>
    exit(1);
    28fa:	4505                	li	a0,1
    28fc:	00003097          	auipc	ra,0x3
    2900:	57c080e7          	jalr	1404(ra) # 5e78 <exit>
    2904:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    2906:	00005517          	auipc	a0,0x5
    290a:	80250513          	addi	a0,a0,-2046 # 7108 <malloc+0xe5e>
    290e:	00004097          	auipc	ra,0x4
    2912:	8e0080e7          	jalr	-1824(ra) # 61ee <printf>
    exit(1);
    2916:	4505                	li	a0,1
    2918:	00003097          	auipc	ra,0x3
    291c:	560080e7          	jalr	1376(ra) # 5e78 <exit>
    printf("open(rwsbrk) failed\n");
    2920:	00005517          	auipc	a0,0x5
    2924:	81050513          	addi	a0,a0,-2032 # 7130 <malloc+0xe86>
    2928:	00004097          	auipc	ra,0x4
    292c:	8c6080e7          	jalr	-1850(ra) # 61ee <printf>
    exit(1);
    2930:	4505                	li	a0,1
    2932:	00003097          	auipc	ra,0x3
    2936:	546080e7          	jalr	1350(ra) # 5e78 <exit>
  close(fd);
    293a:	854a                	mv	a0,s2
    293c:	00003097          	auipc	ra,0x3
    2940:	564080e7          	jalr	1380(ra) # 5ea0 <close>
  unlink("rwsbrk");
    2944:	00004517          	auipc	a0,0x4
    2948:	7e450513          	addi	a0,a0,2020 # 7128 <malloc+0xe7e>
    294c:	00003097          	auipc	ra,0x3
    2950:	57c080e7          	jalr	1404(ra) # 5ec8 <unlink>
  fd = open("README", O_RDONLY);
    2954:	4581                	li	a1,0
    2956:	00004517          	auipc	a0,0x4
    295a:	c6a50513          	addi	a0,a0,-918 # 65c0 <malloc+0x316>
    295e:	00003097          	auipc	ra,0x3
    2962:	55a080e7          	jalr	1370(ra) # 5eb8 <open>
    2966:	892a                	mv	s2,a0
  if(fd < 0){
    2968:	02054963          	bltz	a0,299a <rwsbrk+0x130>
  n = read(fd, (void*)(a+4096), 10);
    296c:	4629                	li	a2,10
    296e:	85a6                	mv	a1,s1
    2970:	00003097          	auipc	ra,0x3
    2974:	520080e7          	jalr	1312(ra) # 5e90 <read>
    2978:	862a                	mv	a2,a0
  if(n >= 0){
    297a:	02054d63          	bltz	a0,29b4 <rwsbrk+0x14a>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    297e:	85a6                	mv	a1,s1
    2980:	00004517          	auipc	a0,0x4
    2984:	7f850513          	addi	a0,a0,2040 # 7178 <malloc+0xece>
    2988:	00004097          	auipc	ra,0x4
    298c:	866080e7          	jalr	-1946(ra) # 61ee <printf>
    exit(1);
    2990:	4505                	li	a0,1
    2992:	00003097          	auipc	ra,0x3
    2996:	4e6080e7          	jalr	1254(ra) # 5e78 <exit>
    printf("open(rwsbrk) failed\n");
    299a:	00004517          	auipc	a0,0x4
    299e:	79650513          	addi	a0,a0,1942 # 7130 <malloc+0xe86>
    29a2:	00004097          	auipc	ra,0x4
    29a6:	84c080e7          	jalr	-1972(ra) # 61ee <printf>
    exit(1);
    29aa:	4505                	li	a0,1
    29ac:	00003097          	auipc	ra,0x3
    29b0:	4cc080e7          	jalr	1228(ra) # 5e78 <exit>
  close(fd);
    29b4:	854a                	mv	a0,s2
    29b6:	00003097          	auipc	ra,0x3
    29ba:	4ea080e7          	jalr	1258(ra) # 5ea0 <close>
  exit(0);
    29be:	4501                	li	a0,0
    29c0:	00003097          	auipc	ra,0x3
    29c4:	4b8080e7          	jalr	1208(ra) # 5e78 <exit>

00000000000029c8 <sbrkbasic>:
{
    29c8:	715d                	addi	sp,sp,-80
    29ca:	e486                	sd	ra,72(sp)
    29cc:	e0a2                	sd	s0,64(sp)
    29ce:	ec56                	sd	s5,24(sp)
    29d0:	0880                	addi	s0,sp,80
    29d2:	8aaa                	mv	s5,a0
  pid = fork();
    29d4:	00003097          	auipc	ra,0x3
    29d8:	49c080e7          	jalr	1180(ra) # 5e70 <fork>
  if(pid < 0){
    29dc:	04054063          	bltz	a0,2a1c <sbrkbasic+0x54>
  if(pid == 0){
    29e0:	e925                	bnez	a0,2a50 <sbrkbasic+0x88>
    a = sbrk(TOOMUCH);
    29e2:	40000537          	lui	a0,0x40000
    29e6:	00003097          	auipc	ra,0x3
    29ea:	51a080e7          	jalr	1306(ra) # 5f00 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    29ee:	57fd                	li	a5,-1
    29f0:	04f50763          	beq	a0,a5,2a3e <sbrkbasic+0x76>
    29f4:	fc26                	sd	s1,56(sp)
    29f6:	f84a                	sd	s2,48(sp)
    29f8:	f44e                	sd	s3,40(sp)
    29fa:	f052                	sd	s4,32(sp)
    for(b = a; b < a+TOOMUCH; b += 4096){
    29fc:	400007b7          	lui	a5,0x40000
    2a00:	97aa                	add	a5,a5,a0
      *b = 99;
    2a02:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2a06:	6705                	lui	a4,0x1
      *b = 99;
    2a08:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2a0c:	953a                	add	a0,a0,a4
    2a0e:	fef51de3          	bne	a0,a5,2a08 <sbrkbasic+0x40>
    exit(1);
    2a12:	4505                	li	a0,1
    2a14:	00003097          	auipc	ra,0x3
    2a18:	464080e7          	jalr	1124(ra) # 5e78 <exit>
    2a1c:	fc26                	sd	s1,56(sp)
    2a1e:	f84a                	sd	s2,48(sp)
    2a20:	f44e                	sd	s3,40(sp)
    2a22:	f052                	sd	s4,32(sp)
    printf("fork failed in sbrkbasic\n");
    2a24:	00004517          	auipc	a0,0x4
    2a28:	77c50513          	addi	a0,a0,1916 # 71a0 <malloc+0xef6>
    2a2c:	00003097          	auipc	ra,0x3
    2a30:	7c2080e7          	jalr	1986(ra) # 61ee <printf>
    exit(1);
    2a34:	4505                	li	a0,1
    2a36:	00003097          	auipc	ra,0x3
    2a3a:	442080e7          	jalr	1090(ra) # 5e78 <exit>
    2a3e:	fc26                	sd	s1,56(sp)
    2a40:	f84a                	sd	s2,48(sp)
    2a42:	f44e                	sd	s3,40(sp)
    2a44:	f052                	sd	s4,32(sp)
      exit(0);
    2a46:	4501                	li	a0,0
    2a48:	00003097          	auipc	ra,0x3
    2a4c:	430080e7          	jalr	1072(ra) # 5e78 <exit>
  wait(&xstatus);
    2a50:	fbc40513          	addi	a0,s0,-68
    2a54:	00003097          	auipc	ra,0x3
    2a58:	42c080e7          	jalr	1068(ra) # 5e80 <wait>
  if(xstatus == 1){
    2a5c:	fbc42703          	lw	a4,-68(s0)
    2a60:	4785                	li	a5,1
    2a62:	02f70263          	beq	a4,a5,2a86 <sbrkbasic+0xbe>
    2a66:	fc26                	sd	s1,56(sp)
    2a68:	f84a                	sd	s2,48(sp)
    2a6a:	f44e                	sd	s3,40(sp)
    2a6c:	f052                	sd	s4,32(sp)
  a = sbrk(0);
    2a6e:	4501                	li	a0,0
    2a70:	00003097          	auipc	ra,0x3
    2a74:	490080e7          	jalr	1168(ra) # 5f00 <sbrk>
    2a78:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2a7a:	4901                	li	s2,0
    b = sbrk(1);
    2a7c:	4985                	li	s3,1
  for(i = 0; i < 5000; i++){
    2a7e:	6a05                	lui	s4,0x1
    2a80:	388a0a13          	addi	s4,s4,904 # 1388 <pgbug+0x1e>
    2a84:	a025                	j	2aac <sbrkbasic+0xe4>
    2a86:	fc26                	sd	s1,56(sp)
    2a88:	f84a                	sd	s2,48(sp)
    2a8a:	f44e                	sd	s3,40(sp)
    2a8c:	f052                	sd	s4,32(sp)
    printf("%s: too much memory allocated!\n", s);
    2a8e:	85d6                	mv	a1,s5
    2a90:	00004517          	auipc	a0,0x4
    2a94:	73050513          	addi	a0,a0,1840 # 71c0 <malloc+0xf16>
    2a98:	00003097          	auipc	ra,0x3
    2a9c:	756080e7          	jalr	1878(ra) # 61ee <printf>
    exit(1);
    2aa0:	4505                	li	a0,1
    2aa2:	00003097          	auipc	ra,0x3
    2aa6:	3d6080e7          	jalr	982(ra) # 5e78 <exit>
    2aaa:	84be                	mv	s1,a5
    b = sbrk(1);
    2aac:	854e                	mv	a0,s3
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	452080e7          	jalr	1106(ra) # 5f00 <sbrk>
    if(b != a){
    2ab6:	04951b63          	bne	a0,s1,2b0c <sbrkbasic+0x144>
    *b = 1;
    2aba:	01348023          	sb	s3,0(s1)
    a = b + 1;
    2abe:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2ac2:	2905                	addiw	s2,s2,1
    2ac4:	ff4913e3          	bne	s2,s4,2aaa <sbrkbasic+0xe2>
  pid = fork();
    2ac8:	00003097          	auipc	ra,0x3
    2acc:	3a8080e7          	jalr	936(ra) # 5e70 <fork>
    2ad0:	892a                	mv	s2,a0
  if(pid < 0){
    2ad2:	04054e63          	bltz	a0,2b2e <sbrkbasic+0x166>
  c = sbrk(1);
    2ad6:	4505                	li	a0,1
    2ad8:	00003097          	auipc	ra,0x3
    2adc:	428080e7          	jalr	1064(ra) # 5f00 <sbrk>
  c = sbrk(1);
    2ae0:	4505                	li	a0,1
    2ae2:	00003097          	auipc	ra,0x3
    2ae6:	41e080e7          	jalr	1054(ra) # 5f00 <sbrk>
  if(c != a + 1){
    2aea:	0489                	addi	s1,s1,2
    2aec:	04a48f63          	beq	s1,a0,2b4a <sbrkbasic+0x182>
    printf("%s: sbrk test failed post-fork\n", s);
    2af0:	85d6                	mv	a1,s5
    2af2:	00004517          	auipc	a0,0x4
    2af6:	72e50513          	addi	a0,a0,1838 # 7220 <malloc+0xf76>
    2afa:	00003097          	auipc	ra,0x3
    2afe:	6f4080e7          	jalr	1780(ra) # 61ee <printf>
    exit(1);
    2b02:	4505                	li	a0,1
    2b04:	00003097          	auipc	ra,0x3
    2b08:	374080e7          	jalr	884(ra) # 5e78 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2b0c:	872a                	mv	a4,a0
    2b0e:	86a6                	mv	a3,s1
    2b10:	864a                	mv	a2,s2
    2b12:	85d6                	mv	a1,s5
    2b14:	00004517          	auipc	a0,0x4
    2b18:	6cc50513          	addi	a0,a0,1740 # 71e0 <malloc+0xf36>
    2b1c:	00003097          	auipc	ra,0x3
    2b20:	6d2080e7          	jalr	1746(ra) # 61ee <printf>
      exit(1);
    2b24:	4505                	li	a0,1
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	352080e7          	jalr	850(ra) # 5e78 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2b2e:	85d6                	mv	a1,s5
    2b30:	00004517          	auipc	a0,0x4
    2b34:	6d050513          	addi	a0,a0,1744 # 7200 <malloc+0xf56>
    2b38:	00003097          	auipc	ra,0x3
    2b3c:	6b6080e7          	jalr	1718(ra) # 61ee <printf>
    exit(1);
    2b40:	4505                	li	a0,1
    2b42:	00003097          	auipc	ra,0x3
    2b46:	336080e7          	jalr	822(ra) # 5e78 <exit>
  if(pid == 0)
    2b4a:	00091763          	bnez	s2,2b58 <sbrkbasic+0x190>
    exit(0);
    2b4e:	4501                	li	a0,0
    2b50:	00003097          	auipc	ra,0x3
    2b54:	328080e7          	jalr	808(ra) # 5e78 <exit>
  wait(&xstatus);
    2b58:	fbc40513          	addi	a0,s0,-68
    2b5c:	00003097          	auipc	ra,0x3
    2b60:	324080e7          	jalr	804(ra) # 5e80 <wait>
  exit(xstatus);
    2b64:	fbc42503          	lw	a0,-68(s0)
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	310080e7          	jalr	784(ra) # 5e78 <exit>

0000000000002b70 <sbrkmuch>:
{
    2b70:	7179                	addi	sp,sp,-48
    2b72:	f406                	sd	ra,40(sp)
    2b74:	f022                	sd	s0,32(sp)
    2b76:	ec26                	sd	s1,24(sp)
    2b78:	e84a                	sd	s2,16(sp)
    2b7a:	e44e                	sd	s3,8(sp)
    2b7c:	e052                	sd	s4,0(sp)
    2b7e:	1800                	addi	s0,sp,48
    2b80:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2b82:	4501                	li	a0,0
    2b84:	00003097          	auipc	ra,0x3
    2b88:	37c080e7          	jalr	892(ra) # 5f00 <sbrk>
    2b8c:	892a                	mv	s2,a0
  a = sbrk(0);
    2b8e:	4501                	li	a0,0
    2b90:	00003097          	auipc	ra,0x3
    2b94:	370080e7          	jalr	880(ra) # 5f00 <sbrk>
    2b98:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2b9a:	06400537          	lui	a0,0x6400
    2b9e:	9d05                	subw	a0,a0,s1
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	360080e7          	jalr	864(ra) # 5f00 <sbrk>
  if (p != a) {
    2ba8:	0ca49863          	bne	s1,a0,2c78 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2bac:	4501                	li	a0,0
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	352080e7          	jalr	850(ra) # 5f00 <sbrk>
    2bb6:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2bb8:	00a4f963          	bgeu	s1,a0,2bca <sbrkmuch+0x5a>
    *pp = 1;
    2bbc:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2bbe:	6705                	lui	a4,0x1
    *pp = 1;
    2bc0:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2bc4:	94ba                	add	s1,s1,a4
    2bc6:	fef4ede3          	bltu	s1,a5,2bc0 <sbrkmuch+0x50>
  *lastaddr = 99;
    2bca:	064007b7          	lui	a5,0x6400
    2bce:	06300713          	li	a4,99
    2bd2:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2bd6:	4501                	li	a0,0
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	328080e7          	jalr	808(ra) # 5f00 <sbrk>
    2be0:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2be2:	757d                	lui	a0,0xfffff
    2be4:	00003097          	auipc	ra,0x3
    2be8:	31c080e7          	jalr	796(ra) # 5f00 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2bec:	57fd                	li	a5,-1
    2bee:	0af50363          	beq	a0,a5,2c94 <sbrkmuch+0x124>
  c = sbrk(0);
    2bf2:	4501                	li	a0,0
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	30c080e7          	jalr	780(ra) # 5f00 <sbrk>
  if(c != a - PGSIZE){
    2bfc:	77fd                	lui	a5,0xfffff
    2bfe:	97a6                	add	a5,a5,s1
    2c00:	0af51863          	bne	a0,a5,2cb0 <sbrkmuch+0x140>
  a = sbrk(0);
    2c04:	4501                	li	a0,0
    2c06:	00003097          	auipc	ra,0x3
    2c0a:	2fa080e7          	jalr	762(ra) # 5f00 <sbrk>
    2c0e:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2c10:	6505                	lui	a0,0x1
    2c12:	00003097          	auipc	ra,0x3
    2c16:	2ee080e7          	jalr	750(ra) # 5f00 <sbrk>
    2c1a:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2c1c:	0aa49a63          	bne	s1,a0,2cd0 <sbrkmuch+0x160>
    2c20:	4501                	li	a0,0
    2c22:	00003097          	auipc	ra,0x3
    2c26:	2de080e7          	jalr	734(ra) # 5f00 <sbrk>
    2c2a:	6785                	lui	a5,0x1
    2c2c:	97a6                	add	a5,a5,s1
    2c2e:	0af51163          	bne	a0,a5,2cd0 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2c32:	064007b7          	lui	a5,0x6400
    2c36:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2c3a:	06300793          	li	a5,99
    2c3e:	0af70963          	beq	a4,a5,2cf0 <sbrkmuch+0x180>
  a = sbrk(0);
    2c42:	4501                	li	a0,0
    2c44:	00003097          	auipc	ra,0x3
    2c48:	2bc080e7          	jalr	700(ra) # 5f00 <sbrk>
    2c4c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2c4e:	4501                	li	a0,0
    2c50:	00003097          	auipc	ra,0x3
    2c54:	2b0080e7          	jalr	688(ra) # 5f00 <sbrk>
    2c58:	40a9053b          	subw	a0,s2,a0
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	2a4080e7          	jalr	676(ra) # 5f00 <sbrk>
  if(c != a){
    2c64:	0aa49463          	bne	s1,a0,2d0c <sbrkmuch+0x19c>
}
    2c68:	70a2                	ld	ra,40(sp)
    2c6a:	7402                	ld	s0,32(sp)
    2c6c:	64e2                	ld	s1,24(sp)
    2c6e:	6942                	ld	s2,16(sp)
    2c70:	69a2                	ld	s3,8(sp)
    2c72:	6a02                	ld	s4,0(sp)
    2c74:	6145                	addi	sp,sp,48
    2c76:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2c78:	85ce                	mv	a1,s3
    2c7a:	00004517          	auipc	a0,0x4
    2c7e:	5c650513          	addi	a0,a0,1478 # 7240 <malloc+0xf96>
    2c82:	00003097          	auipc	ra,0x3
    2c86:	56c080e7          	jalr	1388(ra) # 61ee <printf>
    exit(1);
    2c8a:	4505                	li	a0,1
    2c8c:	00003097          	auipc	ra,0x3
    2c90:	1ec080e7          	jalr	492(ra) # 5e78 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2c94:	85ce                	mv	a1,s3
    2c96:	00004517          	auipc	a0,0x4
    2c9a:	5f250513          	addi	a0,a0,1522 # 7288 <malloc+0xfde>
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	550080e7          	jalr	1360(ra) # 61ee <printf>
    exit(1);
    2ca6:	4505                	li	a0,1
    2ca8:	00003097          	auipc	ra,0x3
    2cac:	1d0080e7          	jalr	464(ra) # 5e78 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2cb0:	86aa                	mv	a3,a0
    2cb2:	8626                	mv	a2,s1
    2cb4:	85ce                	mv	a1,s3
    2cb6:	00004517          	auipc	a0,0x4
    2cba:	5f250513          	addi	a0,a0,1522 # 72a8 <malloc+0xffe>
    2cbe:	00003097          	auipc	ra,0x3
    2cc2:	530080e7          	jalr	1328(ra) # 61ee <printf>
    exit(1);
    2cc6:	4505                	li	a0,1
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	1b0080e7          	jalr	432(ra) # 5e78 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2cd0:	86d2                	mv	a3,s4
    2cd2:	8626                	mv	a2,s1
    2cd4:	85ce                	mv	a1,s3
    2cd6:	00004517          	auipc	a0,0x4
    2cda:	61250513          	addi	a0,a0,1554 # 72e8 <malloc+0x103e>
    2cde:	00003097          	auipc	ra,0x3
    2ce2:	510080e7          	jalr	1296(ra) # 61ee <printf>
    exit(1);
    2ce6:	4505                	li	a0,1
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	190080e7          	jalr	400(ra) # 5e78 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2cf0:	85ce                	mv	a1,s3
    2cf2:	00004517          	auipc	a0,0x4
    2cf6:	62650513          	addi	a0,a0,1574 # 7318 <malloc+0x106e>
    2cfa:	00003097          	auipc	ra,0x3
    2cfe:	4f4080e7          	jalr	1268(ra) # 61ee <printf>
    exit(1);
    2d02:	4505                	li	a0,1
    2d04:	00003097          	auipc	ra,0x3
    2d08:	174080e7          	jalr	372(ra) # 5e78 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2d0c:	86aa                	mv	a3,a0
    2d0e:	8626                	mv	a2,s1
    2d10:	85ce                	mv	a1,s3
    2d12:	00004517          	auipc	a0,0x4
    2d16:	63e50513          	addi	a0,a0,1598 # 7350 <malloc+0x10a6>
    2d1a:	00003097          	auipc	ra,0x3
    2d1e:	4d4080e7          	jalr	1236(ra) # 61ee <printf>
    exit(1);
    2d22:	4505                	li	a0,1
    2d24:	00003097          	auipc	ra,0x3
    2d28:	154080e7          	jalr	340(ra) # 5e78 <exit>

0000000000002d2c <sbrkarg>:
{
    2d2c:	7179                	addi	sp,sp,-48
    2d2e:	f406                	sd	ra,40(sp)
    2d30:	f022                	sd	s0,32(sp)
    2d32:	ec26                	sd	s1,24(sp)
    2d34:	e84a                	sd	s2,16(sp)
    2d36:	e44e                	sd	s3,8(sp)
    2d38:	1800                	addi	s0,sp,48
    2d3a:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2d3c:	6505                	lui	a0,0x1
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	1c2080e7          	jalr	450(ra) # 5f00 <sbrk>
    2d46:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2d48:	20100593          	li	a1,513
    2d4c:	00004517          	auipc	a0,0x4
    2d50:	62c50513          	addi	a0,a0,1580 # 7378 <malloc+0x10ce>
    2d54:	00003097          	auipc	ra,0x3
    2d58:	164080e7          	jalr	356(ra) # 5eb8 <open>
    2d5c:	84aa                	mv	s1,a0
  unlink("sbrk");
    2d5e:	00004517          	auipc	a0,0x4
    2d62:	61a50513          	addi	a0,a0,1562 # 7378 <malloc+0x10ce>
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	162080e7          	jalr	354(ra) # 5ec8 <unlink>
  if(fd < 0)  {
    2d6e:	0404c163          	bltz	s1,2db0 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2d72:	6605                	lui	a2,0x1
    2d74:	85ca                	mv	a1,s2
    2d76:	8526                	mv	a0,s1
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	120080e7          	jalr	288(ra) # 5e98 <write>
    2d80:	04054663          	bltz	a0,2dcc <sbrkarg+0xa0>
  close(fd);
    2d84:	8526                	mv	a0,s1
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	11a080e7          	jalr	282(ra) # 5ea0 <close>
  a = sbrk(PGSIZE);
    2d8e:	6505                	lui	a0,0x1
    2d90:	00003097          	auipc	ra,0x3
    2d94:	170080e7          	jalr	368(ra) # 5f00 <sbrk>
  if(pipe((int *) a) != 0){
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	0f0080e7          	jalr	240(ra) # 5e88 <pipe>
    2da0:	e521                	bnez	a0,2de8 <sbrkarg+0xbc>
}
    2da2:	70a2                	ld	ra,40(sp)
    2da4:	7402                	ld	s0,32(sp)
    2da6:	64e2                	ld	s1,24(sp)
    2da8:	6942                	ld	s2,16(sp)
    2daa:	69a2                	ld	s3,8(sp)
    2dac:	6145                	addi	sp,sp,48
    2dae:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2db0:	85ce                	mv	a1,s3
    2db2:	00004517          	auipc	a0,0x4
    2db6:	5ce50513          	addi	a0,a0,1486 # 7380 <malloc+0x10d6>
    2dba:	00003097          	auipc	ra,0x3
    2dbe:	434080e7          	jalr	1076(ra) # 61ee <printf>
    exit(1);
    2dc2:	4505                	li	a0,1
    2dc4:	00003097          	auipc	ra,0x3
    2dc8:	0b4080e7          	jalr	180(ra) # 5e78 <exit>
    printf("%s: write sbrk failed\n", s);
    2dcc:	85ce                	mv	a1,s3
    2dce:	00004517          	auipc	a0,0x4
    2dd2:	5ca50513          	addi	a0,a0,1482 # 7398 <malloc+0x10ee>
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	418080e7          	jalr	1048(ra) # 61ee <printf>
    exit(1);
    2dde:	4505                	li	a0,1
    2de0:	00003097          	auipc	ra,0x3
    2de4:	098080e7          	jalr	152(ra) # 5e78 <exit>
    printf("%s: pipe() failed\n", s);
    2de8:	85ce                	mv	a1,s3
    2dea:	00004517          	auipc	a0,0x4
    2dee:	f8e50513          	addi	a0,a0,-114 # 6d78 <malloc+0xace>
    2df2:	00003097          	auipc	ra,0x3
    2df6:	3fc080e7          	jalr	1020(ra) # 61ee <printf>
    exit(1);
    2dfa:	4505                	li	a0,1
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	07c080e7          	jalr	124(ra) # 5e78 <exit>

0000000000002e04 <argptest>:
{
    2e04:	1101                	addi	sp,sp,-32
    2e06:	ec06                	sd	ra,24(sp)
    2e08:	e822                	sd	s0,16(sp)
    2e0a:	e426                	sd	s1,8(sp)
    2e0c:	e04a                	sd	s2,0(sp)
    2e0e:	1000                	addi	s0,sp,32
    2e10:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2e12:	4581                	li	a1,0
    2e14:	00004517          	auipc	a0,0x4
    2e18:	59c50513          	addi	a0,a0,1436 # 73b0 <malloc+0x1106>
    2e1c:	00003097          	auipc	ra,0x3
    2e20:	09c080e7          	jalr	156(ra) # 5eb8 <open>
  if (fd < 0) {
    2e24:	02054b63          	bltz	a0,2e5a <argptest+0x56>
    2e28:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2e2a:	4501                	li	a0,0
    2e2c:	00003097          	auipc	ra,0x3
    2e30:	0d4080e7          	jalr	212(ra) # 5f00 <sbrk>
    2e34:	567d                	li	a2,-1
    2e36:	00c505b3          	add	a1,a0,a2
    2e3a:	8526                	mv	a0,s1
    2e3c:	00003097          	auipc	ra,0x3
    2e40:	054080e7          	jalr	84(ra) # 5e90 <read>
  close(fd);
    2e44:	8526                	mv	a0,s1
    2e46:	00003097          	auipc	ra,0x3
    2e4a:	05a080e7          	jalr	90(ra) # 5ea0 <close>
}
    2e4e:	60e2                	ld	ra,24(sp)
    2e50:	6442                	ld	s0,16(sp)
    2e52:	64a2                	ld	s1,8(sp)
    2e54:	6902                	ld	s2,0(sp)
    2e56:	6105                	addi	sp,sp,32
    2e58:	8082                	ret
    printf("%s: open failed\n", s);
    2e5a:	85ca                	mv	a1,s2
    2e5c:	00004517          	auipc	a0,0x4
    2e60:	e2c50513          	addi	a0,a0,-468 # 6c88 <malloc+0x9de>
    2e64:	00003097          	auipc	ra,0x3
    2e68:	38a080e7          	jalr	906(ra) # 61ee <printf>
    exit(1);
    2e6c:	4505                	li	a0,1
    2e6e:	00003097          	auipc	ra,0x3
    2e72:	00a080e7          	jalr	10(ra) # 5e78 <exit>

0000000000002e76 <sbrkbugs>:
{
    2e76:	1141                	addi	sp,sp,-16
    2e78:	e406                	sd	ra,8(sp)
    2e7a:	e022                	sd	s0,0(sp)
    2e7c:	0800                	addi	s0,sp,16
  int pid = fork();
    2e7e:	00003097          	auipc	ra,0x3
    2e82:	ff2080e7          	jalr	-14(ra) # 5e70 <fork>
  if(pid < 0){
    2e86:	02054263          	bltz	a0,2eaa <sbrkbugs+0x34>
  if(pid == 0){
    2e8a:	ed0d                	bnez	a0,2ec4 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2e8c:	00003097          	auipc	ra,0x3
    2e90:	074080e7          	jalr	116(ra) # 5f00 <sbrk>
    sbrk(-sz);
    2e94:	40a0053b          	negw	a0,a0
    2e98:	00003097          	auipc	ra,0x3
    2e9c:	068080e7          	jalr	104(ra) # 5f00 <sbrk>
    exit(0);
    2ea0:	4501                	li	a0,0
    2ea2:	00003097          	auipc	ra,0x3
    2ea6:	fd6080e7          	jalr	-42(ra) # 5e78 <exit>
    printf("fork failed\n");
    2eaa:	00004517          	auipc	a0,0x4
    2eae:	1ce50513          	addi	a0,a0,462 # 7078 <malloc+0xdce>
    2eb2:	00003097          	auipc	ra,0x3
    2eb6:	33c080e7          	jalr	828(ra) # 61ee <printf>
    exit(1);
    2eba:	4505                	li	a0,1
    2ebc:	00003097          	auipc	ra,0x3
    2ec0:	fbc080e7          	jalr	-68(ra) # 5e78 <exit>
  wait(0);
    2ec4:	4501                	li	a0,0
    2ec6:	00003097          	auipc	ra,0x3
    2eca:	fba080e7          	jalr	-70(ra) # 5e80 <wait>
  pid = fork();
    2ece:	00003097          	auipc	ra,0x3
    2ed2:	fa2080e7          	jalr	-94(ra) # 5e70 <fork>
  if(pid < 0){
    2ed6:	02054563          	bltz	a0,2f00 <sbrkbugs+0x8a>
  if(pid == 0){
    2eda:	e121                	bnez	a0,2f1a <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2edc:	00003097          	auipc	ra,0x3
    2ee0:	024080e7          	jalr	36(ra) # 5f00 <sbrk>
    sbrk(-(sz - 3500));
    2ee4:	6785                	lui	a5,0x1
    2ee6:	dac7879b          	addiw	a5,a5,-596 # dac <unlinkread+0x1e>
    2eea:	40a7853b          	subw	a0,a5,a0
    2eee:	00003097          	auipc	ra,0x3
    2ef2:	012080e7          	jalr	18(ra) # 5f00 <sbrk>
    exit(0);
    2ef6:	4501                	li	a0,0
    2ef8:	00003097          	auipc	ra,0x3
    2efc:	f80080e7          	jalr	-128(ra) # 5e78 <exit>
    printf("fork failed\n");
    2f00:	00004517          	auipc	a0,0x4
    2f04:	17850513          	addi	a0,a0,376 # 7078 <malloc+0xdce>
    2f08:	00003097          	auipc	ra,0x3
    2f0c:	2e6080e7          	jalr	742(ra) # 61ee <printf>
    exit(1);
    2f10:	4505                	li	a0,1
    2f12:	00003097          	auipc	ra,0x3
    2f16:	f66080e7          	jalr	-154(ra) # 5e78 <exit>
  wait(0);
    2f1a:	4501                	li	a0,0
    2f1c:	00003097          	auipc	ra,0x3
    2f20:	f64080e7          	jalr	-156(ra) # 5e80 <wait>
  pid = fork();
    2f24:	00003097          	auipc	ra,0x3
    2f28:	f4c080e7          	jalr	-180(ra) # 5e70 <fork>
  if(pid < 0){
    2f2c:	02054a63          	bltz	a0,2f60 <sbrkbugs+0xea>
  if(pid == 0){
    2f30:	e529                	bnez	a0,2f7a <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2f32:	00003097          	auipc	ra,0x3
    2f36:	fce080e7          	jalr	-50(ra) # 5f00 <sbrk>
    2f3a:	67ad                	lui	a5,0xb
    2f3c:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x298>
    2f40:	40a7853b          	subw	a0,a5,a0
    2f44:	00003097          	auipc	ra,0x3
    2f48:	fbc080e7          	jalr	-68(ra) # 5f00 <sbrk>
    sbrk(-10);
    2f4c:	5559                	li	a0,-10
    2f4e:	00003097          	auipc	ra,0x3
    2f52:	fb2080e7          	jalr	-78(ra) # 5f00 <sbrk>
    exit(0);
    2f56:	4501                	li	a0,0
    2f58:	00003097          	auipc	ra,0x3
    2f5c:	f20080e7          	jalr	-224(ra) # 5e78 <exit>
    printf("fork failed\n");
    2f60:	00004517          	auipc	a0,0x4
    2f64:	11850513          	addi	a0,a0,280 # 7078 <malloc+0xdce>
    2f68:	00003097          	auipc	ra,0x3
    2f6c:	286080e7          	jalr	646(ra) # 61ee <printf>
    exit(1);
    2f70:	4505                	li	a0,1
    2f72:	00003097          	auipc	ra,0x3
    2f76:	f06080e7          	jalr	-250(ra) # 5e78 <exit>
  wait(0);
    2f7a:	4501                	li	a0,0
    2f7c:	00003097          	auipc	ra,0x3
    2f80:	f04080e7          	jalr	-252(ra) # 5e80 <wait>
  exit(0);
    2f84:	4501                	li	a0,0
    2f86:	00003097          	auipc	ra,0x3
    2f8a:	ef2080e7          	jalr	-270(ra) # 5e78 <exit>

0000000000002f8e <sbrklast>:
{
    2f8e:	7179                	addi	sp,sp,-48
    2f90:	f406                	sd	ra,40(sp)
    2f92:	f022                	sd	s0,32(sp)
    2f94:	ec26                	sd	s1,24(sp)
    2f96:	e84a                	sd	s2,16(sp)
    2f98:	e44e                	sd	s3,8(sp)
    2f9a:	e052                	sd	s4,0(sp)
    2f9c:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2f9e:	4501                	li	a0,0
    2fa0:	00003097          	auipc	ra,0x3
    2fa4:	f60080e7          	jalr	-160(ra) # 5f00 <sbrk>
  if((top % 4096) != 0)
    2fa8:	03451793          	slli	a5,a0,0x34
    2fac:	ebd9                	bnez	a5,3042 <sbrklast+0xb4>
  sbrk(4096);
    2fae:	6505                	lui	a0,0x1
    2fb0:	00003097          	auipc	ra,0x3
    2fb4:	f50080e7          	jalr	-176(ra) # 5f00 <sbrk>
  sbrk(10);
    2fb8:	4529                	li	a0,10
    2fba:	00003097          	auipc	ra,0x3
    2fbe:	f46080e7          	jalr	-186(ra) # 5f00 <sbrk>
  sbrk(-20);
    2fc2:	5531                	li	a0,-20
    2fc4:	00003097          	auipc	ra,0x3
    2fc8:	f3c080e7          	jalr	-196(ra) # 5f00 <sbrk>
  top = (uint64) sbrk(0);
    2fcc:	4501                	li	a0,0
    2fce:	00003097          	auipc	ra,0x3
    2fd2:	f32080e7          	jalr	-206(ra) # 5f00 <sbrk>
    2fd6:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2fd8:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0x7c>
  p[0] = 'x';
    2fdc:	07800a13          	li	s4,120
    2fe0:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2fe4:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2fe8:	20200593          	li	a1,514
    2fec:	854a                	mv	a0,s2
    2fee:	00003097          	auipc	ra,0x3
    2ff2:	eca080e7          	jalr	-310(ra) # 5eb8 <open>
    2ff6:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2ff8:	4605                	li	a2,1
    2ffa:	85ca                	mv	a1,s2
    2ffc:	00003097          	auipc	ra,0x3
    3000:	e9c080e7          	jalr	-356(ra) # 5e98 <write>
  close(fd);
    3004:	854e                	mv	a0,s3
    3006:	00003097          	auipc	ra,0x3
    300a:	e9a080e7          	jalr	-358(ra) # 5ea0 <close>
  fd = open(p, O_RDWR);
    300e:	4589                	li	a1,2
    3010:	854a                	mv	a0,s2
    3012:	00003097          	auipc	ra,0x3
    3016:	ea6080e7          	jalr	-346(ra) # 5eb8 <open>
  p[0] = '\0';
    301a:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    301e:	4605                	li	a2,1
    3020:	85ca                	mv	a1,s2
    3022:	00003097          	auipc	ra,0x3
    3026:	e6e080e7          	jalr	-402(ra) # 5e90 <read>
  if(p[0] != 'x')
    302a:	fc04c783          	lbu	a5,-64(s1)
    302e:	03479563          	bne	a5,s4,3058 <sbrklast+0xca>
}
    3032:	70a2                	ld	ra,40(sp)
    3034:	7402                	ld	s0,32(sp)
    3036:	64e2                	ld	s1,24(sp)
    3038:	6942                	ld	s2,16(sp)
    303a:	69a2                	ld	s3,8(sp)
    303c:	6a02                	ld	s4,0(sp)
    303e:	6145                	addi	sp,sp,48
    3040:	8082                	ret
    sbrk(4096 - (top % 4096));
    3042:	6785                	lui	a5,0x1
    3044:	fff78713          	addi	a4,a5,-1 # fff <linktest+0xbb>
    3048:	8d79                	and	a0,a0,a4
    304a:	40a7853b          	subw	a0,a5,a0
    304e:	00003097          	auipc	ra,0x3
    3052:	eb2080e7          	jalr	-334(ra) # 5f00 <sbrk>
    3056:	bfa1                	j	2fae <sbrklast+0x20>
    exit(1);
    3058:	4505                	li	a0,1
    305a:	00003097          	auipc	ra,0x3
    305e:	e1e080e7          	jalr	-482(ra) # 5e78 <exit>

0000000000003062 <sbrk8000>:
{
    3062:	1141                	addi	sp,sp,-16
    3064:	e406                	sd	ra,8(sp)
    3066:	e022                	sd	s0,0(sp)
    3068:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    306a:	80000537          	lui	a0,0x80000
    306e:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    3070:	00003097          	auipc	ra,0x3
    3074:	e90080e7          	jalr	-368(ra) # 5f00 <sbrk>
  volatile char *top = sbrk(0);
    3078:	4501                	li	a0,0
    307a:	00003097          	auipc	ra,0x3
    307e:	e86080e7          	jalr	-378(ra) # 5f00 <sbrk>
  *(top-1) = *(top-1) + 1;
    3082:	fff54783          	lbu	a5,-1(a0)
    3086:	0785                	addi	a5,a5,1
    3088:	0ff7f793          	zext.b	a5,a5
    308c:	fef50fa3          	sb	a5,-1(a0)
}
    3090:	60a2                	ld	ra,8(sp)
    3092:	6402                	ld	s0,0(sp)
    3094:	0141                	addi	sp,sp,16
    3096:	8082                	ret

0000000000003098 <execout>:
{
    3098:	711d                	addi	sp,sp,-96
    309a:	ec86                	sd	ra,88(sp)
    309c:	e8a2                	sd	s0,80(sp)
    309e:	e4a6                	sd	s1,72(sp)
    30a0:	e0ca                	sd	s2,64(sp)
    30a2:	fc4e                	sd	s3,56(sp)
    30a4:	1080                	addi	s0,sp,96
  for(int avail = 0; avail < 15; avail++){
    30a6:	4901                	li	s2,0
    30a8:	49bd                	li	s3,15
    int pid = fork();
    30aa:	00003097          	auipc	ra,0x3
    30ae:	dc6080e7          	jalr	-570(ra) # 5e70 <fork>
    30b2:	84aa                	mv	s1,a0
    if(pid < 0){
    30b4:	02054263          	bltz	a0,30d8 <execout+0x40>
    } else if(pid == 0){
    30b8:	cd1d                	beqz	a0,30f6 <execout+0x5e>
      wait((int*)0);
    30ba:	4501                	li	a0,0
    30bc:	00003097          	auipc	ra,0x3
    30c0:	dc4080e7          	jalr	-572(ra) # 5e80 <wait>
  for(int avail = 0; avail < 15; avail++){
    30c4:	2905                	addiw	s2,s2,1
    30c6:	ff3912e3          	bne	s2,s3,30aa <execout+0x12>
    30ca:	f852                	sd	s4,48(sp)
    30cc:	f456                	sd	s5,40(sp)
  exit(0);
    30ce:	4501                	li	a0,0
    30d0:	00003097          	auipc	ra,0x3
    30d4:	da8080e7          	jalr	-600(ra) # 5e78 <exit>
    30d8:	f852                	sd	s4,48(sp)
    30da:	f456                	sd	s5,40(sp)
      printf("fork failed\n");
    30dc:	00004517          	auipc	a0,0x4
    30e0:	f9c50513          	addi	a0,a0,-100 # 7078 <malloc+0xdce>
    30e4:	00003097          	auipc	ra,0x3
    30e8:	10a080e7          	jalr	266(ra) # 61ee <printf>
      exit(1);
    30ec:	4505                	li	a0,1
    30ee:	00003097          	auipc	ra,0x3
    30f2:	d8a080e7          	jalr	-630(ra) # 5e78 <exit>
    30f6:	f852                	sd	s4,48(sp)
    30f8:	f456                	sd	s5,40(sp)
        uint64 a = (uint64) sbrk(4096);
    30fa:	6985                	lui	s3,0x1
        if(a == 0xffffffffffffffffLL)
    30fc:	5a7d                	li	s4,-1
        *(char*)(a + 4096 - 1) = 1;
    30fe:	4a85                	li	s5,1
        uint64 a = (uint64) sbrk(4096);
    3100:	854e                	mv	a0,s3
    3102:	00003097          	auipc	ra,0x3
    3106:	dfe080e7          	jalr	-514(ra) # 5f00 <sbrk>
        if(a == 0xffffffffffffffffLL)
    310a:	01450663          	beq	a0,s4,3116 <execout+0x7e>
        *(char*)(a + 4096 - 1) = 1;
    310e:	954e                	add	a0,a0,s3
    3110:	ff550fa3          	sb	s5,-1(a0)
      while(1){
    3114:	b7f5                	j	3100 <execout+0x68>
        sbrk(-4096);
    3116:	79fd                	lui	s3,0xfffff
      for(int i = 0; i < avail; i++)
    3118:	01205a63          	blez	s2,312c <execout+0x94>
        sbrk(-4096);
    311c:	854e                	mv	a0,s3
    311e:	00003097          	auipc	ra,0x3
    3122:	de2080e7          	jalr	-542(ra) # 5f00 <sbrk>
      for(int i = 0; i < avail; i++)
    3126:	2485                	addiw	s1,s1,1
    3128:	ff249ae3          	bne	s1,s2,311c <execout+0x84>
      close(1);
    312c:	4505                	li	a0,1
    312e:	00003097          	auipc	ra,0x3
    3132:	d72080e7          	jalr	-654(ra) # 5ea0 <close>
      char *args[] = { "echo", "x", 0 };
    3136:	00003517          	auipc	a0,0x3
    313a:	2b250513          	addi	a0,a0,690 # 63e8 <malloc+0x13e>
    313e:	faa43423          	sd	a0,-88(s0)
    3142:	00003797          	auipc	a5,0x3
    3146:	31678793          	addi	a5,a5,790 # 6458 <malloc+0x1ae>
    314a:	faf43823          	sd	a5,-80(s0)
    314e:	fa043c23          	sd	zero,-72(s0)
      exec("echo", args);
    3152:	fa840593          	addi	a1,s0,-88
    3156:	00003097          	auipc	ra,0x3
    315a:	d5a080e7          	jalr	-678(ra) # 5eb0 <exec>
      exit(0);
    315e:	4501                	li	a0,0
    3160:	00003097          	auipc	ra,0x3
    3164:	d18080e7          	jalr	-744(ra) # 5e78 <exit>

0000000000003168 <fourteen>:
{
    3168:	1101                	addi	sp,sp,-32
    316a:	ec06                	sd	ra,24(sp)
    316c:	e822                	sd	s0,16(sp)
    316e:	e426                	sd	s1,8(sp)
    3170:	1000                	addi	s0,sp,32
    3172:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    3174:	00004517          	auipc	a0,0x4
    3178:	41450513          	addi	a0,a0,1044 # 7588 <malloc+0x12de>
    317c:	00003097          	auipc	ra,0x3
    3180:	d64080e7          	jalr	-668(ra) # 5ee0 <mkdir>
    3184:	e165                	bnez	a0,3264 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3186:	00004517          	auipc	a0,0x4
    318a:	25a50513          	addi	a0,a0,602 # 73e0 <malloc+0x1136>
    318e:	00003097          	auipc	ra,0x3
    3192:	d52080e7          	jalr	-686(ra) # 5ee0 <mkdir>
    3196:	e56d                	bnez	a0,3280 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3198:	20000593          	li	a1,512
    319c:	00004517          	auipc	a0,0x4
    31a0:	29c50513          	addi	a0,a0,668 # 7438 <malloc+0x118e>
    31a4:	00003097          	auipc	ra,0x3
    31a8:	d14080e7          	jalr	-748(ra) # 5eb8 <open>
  if(fd < 0){
    31ac:	0e054863          	bltz	a0,329c <fourteen+0x134>
  close(fd);
    31b0:	00003097          	auipc	ra,0x3
    31b4:	cf0080e7          	jalr	-784(ra) # 5ea0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    31b8:	4581                	li	a1,0
    31ba:	00004517          	auipc	a0,0x4
    31be:	2f650513          	addi	a0,a0,758 # 74b0 <malloc+0x1206>
    31c2:	00003097          	auipc	ra,0x3
    31c6:	cf6080e7          	jalr	-778(ra) # 5eb8 <open>
  if(fd < 0){
    31ca:	0e054763          	bltz	a0,32b8 <fourteen+0x150>
  close(fd);
    31ce:	00003097          	auipc	ra,0x3
    31d2:	cd2080e7          	jalr	-814(ra) # 5ea0 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    31d6:	00004517          	auipc	a0,0x4
    31da:	34a50513          	addi	a0,a0,842 # 7520 <malloc+0x1276>
    31de:	00003097          	auipc	ra,0x3
    31e2:	d02080e7          	jalr	-766(ra) # 5ee0 <mkdir>
    31e6:	c57d                	beqz	a0,32d4 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    31e8:	00004517          	auipc	a0,0x4
    31ec:	39050513          	addi	a0,a0,912 # 7578 <malloc+0x12ce>
    31f0:	00003097          	auipc	ra,0x3
    31f4:	cf0080e7          	jalr	-784(ra) # 5ee0 <mkdir>
    31f8:	cd65                	beqz	a0,32f0 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    31fa:	00004517          	auipc	a0,0x4
    31fe:	37e50513          	addi	a0,a0,894 # 7578 <malloc+0x12ce>
    3202:	00003097          	auipc	ra,0x3
    3206:	cc6080e7          	jalr	-826(ra) # 5ec8 <unlink>
  unlink("12345678901234/12345678901234");
    320a:	00004517          	auipc	a0,0x4
    320e:	31650513          	addi	a0,a0,790 # 7520 <malloc+0x1276>
    3212:	00003097          	auipc	ra,0x3
    3216:	cb6080e7          	jalr	-842(ra) # 5ec8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    321a:	00004517          	auipc	a0,0x4
    321e:	29650513          	addi	a0,a0,662 # 74b0 <malloc+0x1206>
    3222:	00003097          	auipc	ra,0x3
    3226:	ca6080e7          	jalr	-858(ra) # 5ec8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    322a:	00004517          	auipc	a0,0x4
    322e:	20e50513          	addi	a0,a0,526 # 7438 <malloc+0x118e>
    3232:	00003097          	auipc	ra,0x3
    3236:	c96080e7          	jalr	-874(ra) # 5ec8 <unlink>
  unlink("12345678901234/123456789012345");
    323a:	00004517          	auipc	a0,0x4
    323e:	1a650513          	addi	a0,a0,422 # 73e0 <malloc+0x1136>
    3242:	00003097          	auipc	ra,0x3
    3246:	c86080e7          	jalr	-890(ra) # 5ec8 <unlink>
  unlink("12345678901234");
    324a:	00004517          	auipc	a0,0x4
    324e:	33e50513          	addi	a0,a0,830 # 7588 <malloc+0x12de>
    3252:	00003097          	auipc	ra,0x3
    3256:	c76080e7          	jalr	-906(ra) # 5ec8 <unlink>
}
    325a:	60e2                	ld	ra,24(sp)
    325c:	6442                	ld	s0,16(sp)
    325e:	64a2                	ld	s1,8(sp)
    3260:	6105                	addi	sp,sp,32
    3262:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3264:	85a6                	mv	a1,s1
    3266:	00004517          	auipc	a0,0x4
    326a:	15250513          	addi	a0,a0,338 # 73b8 <malloc+0x110e>
    326e:	00003097          	auipc	ra,0x3
    3272:	f80080e7          	jalr	-128(ra) # 61ee <printf>
    exit(1);
    3276:	4505                	li	a0,1
    3278:	00003097          	auipc	ra,0x3
    327c:	c00080e7          	jalr	-1024(ra) # 5e78 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3280:	85a6                	mv	a1,s1
    3282:	00004517          	auipc	a0,0x4
    3286:	17e50513          	addi	a0,a0,382 # 7400 <malloc+0x1156>
    328a:	00003097          	auipc	ra,0x3
    328e:	f64080e7          	jalr	-156(ra) # 61ee <printf>
    exit(1);
    3292:	4505                	li	a0,1
    3294:	00003097          	auipc	ra,0x3
    3298:	be4080e7          	jalr	-1052(ra) # 5e78 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    329c:	85a6                	mv	a1,s1
    329e:	00004517          	auipc	a0,0x4
    32a2:	1ca50513          	addi	a0,a0,458 # 7468 <malloc+0x11be>
    32a6:	00003097          	auipc	ra,0x3
    32aa:	f48080e7          	jalr	-184(ra) # 61ee <printf>
    exit(1);
    32ae:	4505                	li	a0,1
    32b0:	00003097          	auipc	ra,0x3
    32b4:	bc8080e7          	jalr	-1080(ra) # 5e78 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    32b8:	85a6                	mv	a1,s1
    32ba:	00004517          	auipc	a0,0x4
    32be:	22650513          	addi	a0,a0,550 # 74e0 <malloc+0x1236>
    32c2:	00003097          	auipc	ra,0x3
    32c6:	f2c080e7          	jalr	-212(ra) # 61ee <printf>
    exit(1);
    32ca:	4505                	li	a0,1
    32cc:	00003097          	auipc	ra,0x3
    32d0:	bac080e7          	jalr	-1108(ra) # 5e78 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    32d4:	85a6                	mv	a1,s1
    32d6:	00004517          	auipc	a0,0x4
    32da:	26a50513          	addi	a0,a0,618 # 7540 <malloc+0x1296>
    32de:	00003097          	auipc	ra,0x3
    32e2:	f10080e7          	jalr	-240(ra) # 61ee <printf>
    exit(1);
    32e6:	4505                	li	a0,1
    32e8:	00003097          	auipc	ra,0x3
    32ec:	b90080e7          	jalr	-1136(ra) # 5e78 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    32f0:	85a6                	mv	a1,s1
    32f2:	00004517          	auipc	a0,0x4
    32f6:	2a650513          	addi	a0,a0,678 # 7598 <malloc+0x12ee>
    32fa:	00003097          	auipc	ra,0x3
    32fe:	ef4080e7          	jalr	-268(ra) # 61ee <printf>
    exit(1);
    3302:	4505                	li	a0,1
    3304:	00003097          	auipc	ra,0x3
    3308:	b74080e7          	jalr	-1164(ra) # 5e78 <exit>

000000000000330c <diskfull>:
{
    330c:	b6010113          	addi	sp,sp,-1184
    3310:	48113c23          	sd	ra,1176(sp)
    3314:	48813823          	sd	s0,1168(sp)
    3318:	48913423          	sd	s1,1160(sp)
    331c:	49213023          	sd	s2,1152(sp)
    3320:	47313c23          	sd	s3,1144(sp)
    3324:	47413823          	sd	s4,1136(sp)
    3328:	47513423          	sd	s5,1128(sp)
    332c:	47613023          	sd	s6,1120(sp)
    3330:	45713c23          	sd	s7,1112(sp)
    3334:	45813823          	sd	s8,1104(sp)
    3338:	45913423          	sd	s9,1096(sp)
    333c:	45a13023          	sd	s10,1088(sp)
    3340:	43b13c23          	sd	s11,1080(sp)
    3344:	4a010413          	addi	s0,sp,1184
    3348:	b6a43423          	sd	a0,-1176(s0)
  unlink("diskfulldir");
    334c:	00004517          	auipc	a0,0x4
    3350:	28450513          	addi	a0,a0,644 # 75d0 <malloc+0x1326>
    3354:	00003097          	auipc	ra,0x3
    3358:	b74080e7          	jalr	-1164(ra) # 5ec8 <unlink>
  for(fi = 0; done == 0; fi++){
    335c:	4a81                	li	s5,0
    name[0] = 'b';
    335e:	06200d13          	li	s10,98
    name[1] = 'i';
    3362:	06900c93          	li	s9,105
    name[2] = 'g';
    3366:	06700c13          	li	s8,103
    unlink(name);
    336a:	b7040b13          	addi	s6,s0,-1168
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    336e:	60200b93          	li	s7,1538
    3372:	10c00d93          	li	s11,268
      if(write(fd, buf, BSIZE) != BSIZE){
    3376:	b9040a13          	addi	s4,s0,-1136
    337a:	aa49                	j	350c <diskfull+0x200>
      printf("%s: could not create file %s\n", s, name);
    337c:	b7040613          	addi	a2,s0,-1168
    3380:	b6843583          	ld	a1,-1176(s0)
    3384:	00004517          	auipc	a0,0x4
    3388:	25c50513          	addi	a0,a0,604 # 75e0 <malloc+0x1336>
    338c:	00003097          	auipc	ra,0x3
    3390:	e62080e7          	jalr	-414(ra) # 61ee <printf>
      break;
    3394:	a821                	j	33ac <diskfull+0xa0>
        close(fd);
    3396:	854e                	mv	a0,s3
    3398:	00003097          	auipc	ra,0x3
    339c:	b08080e7          	jalr	-1272(ra) # 5ea0 <close>
    close(fd);
    33a0:	854e                	mv	a0,s3
    33a2:	00003097          	auipc	ra,0x3
    33a6:	afe080e7          	jalr	-1282(ra) # 5ea0 <close>
  for(fi = 0; done == 0; fi++){
    33aa:	2a85                	addiw	s5,s5,1
  for(int i = 0; i < nzz; i++){
    33ac:	4481                	li	s1,0
    name[0] = 'z';
    33ae:	07a00993          	li	s3,122
    unlink(name);
    33b2:	b9040913          	addi	s2,s0,-1136
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    33b6:	60200a13          	li	s4,1538
  for(int i = 0; i < nzz; i++){
    33ba:	08000b13          	li	s6,128
    name[0] = 'z';
    33be:	b9340823          	sb	s3,-1136(s0)
    name[1] = 'z';
    33c2:	b93408a3          	sb	s3,-1135(s0)
    name[2] = '0' + (i / 32);
    33c6:	41f4d71b          	sraiw	a4,s1,0x1f
    33ca:	01b7571b          	srliw	a4,a4,0x1b
    33ce:	009707bb          	addw	a5,a4,s1
    33d2:	4057d69b          	sraiw	a3,a5,0x5
    33d6:	0306869b          	addiw	a3,a3,48
    33da:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    33de:	8bfd                	andi	a5,a5,31
    33e0:	9f99                	subw	a5,a5,a4
    33e2:	0307879b          	addiw	a5,a5,48
    33e6:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33ea:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    33ee:	854a                	mv	a0,s2
    33f0:	00003097          	auipc	ra,0x3
    33f4:	ad8080e7          	jalr	-1320(ra) # 5ec8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    33f8:	85d2                	mv	a1,s4
    33fa:	854a                	mv	a0,s2
    33fc:	00003097          	auipc	ra,0x3
    3400:	abc080e7          	jalr	-1348(ra) # 5eb8 <open>
    if(fd < 0)
    3404:	00054963          	bltz	a0,3416 <diskfull+0x10a>
    close(fd);
    3408:	00003097          	auipc	ra,0x3
    340c:	a98080e7          	jalr	-1384(ra) # 5ea0 <close>
  for(int i = 0; i < nzz; i++){
    3410:	2485                	addiw	s1,s1,1
    3412:	fb6496e3          	bne	s1,s6,33be <diskfull+0xb2>
  if(mkdir("diskfulldir") == 0)
    3416:	00004517          	auipc	a0,0x4
    341a:	1ba50513          	addi	a0,a0,442 # 75d0 <malloc+0x1326>
    341e:	00003097          	auipc	ra,0x3
    3422:	ac2080e7          	jalr	-1342(ra) # 5ee0 <mkdir>
    3426:	12050c63          	beqz	a0,355e <diskfull+0x252>
  unlink("diskfulldir");
    342a:	00004517          	auipc	a0,0x4
    342e:	1a650513          	addi	a0,a0,422 # 75d0 <malloc+0x1326>
    3432:	00003097          	auipc	ra,0x3
    3436:	a96080e7          	jalr	-1386(ra) # 5ec8 <unlink>
  for(int i = 0; i < nzz; i++){
    343a:	4481                	li	s1,0
    name[0] = 'z';
    343c:	07a00913          	li	s2,122
    unlink(name);
    3440:	b9040a13          	addi	s4,s0,-1136
  for(int i = 0; i < nzz; i++){
    3444:	08000993          	li	s3,128
    name[0] = 'z';
    3448:	b9240823          	sb	s2,-1136(s0)
    name[1] = 'z';
    344c:	b92408a3          	sb	s2,-1135(s0)
    name[2] = '0' + (i / 32);
    3450:	41f4d71b          	sraiw	a4,s1,0x1f
    3454:	01b7571b          	srliw	a4,a4,0x1b
    3458:	009707bb          	addw	a5,a4,s1
    345c:	4057d69b          	sraiw	a3,a5,0x5
    3460:	0306869b          	addiw	a3,a3,48
    3464:	b8d40923          	sb	a3,-1134(s0)
    name[3] = '0' + (i % 32);
    3468:	8bfd                	andi	a5,a5,31
    346a:	9f99                	subw	a5,a5,a4
    346c:	0307879b          	addiw	a5,a5,48
    3470:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    3474:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3478:	8552                	mv	a0,s4
    347a:	00003097          	auipc	ra,0x3
    347e:	a4e080e7          	jalr	-1458(ra) # 5ec8 <unlink>
  for(int i = 0; i < nzz; i++){
    3482:	2485                	addiw	s1,s1,1
    3484:	fd3492e3          	bne	s1,s3,3448 <diskfull+0x13c>
  for(int i = 0; i < fi; i++){
    3488:	03505f63          	blez	s5,34c6 <diskfull+0x1ba>
    348c:	4481                	li	s1,0
    name[0] = 'b';
    348e:	06200b13          	li	s6,98
    name[1] = 'i';
    3492:	06900a13          	li	s4,105
    name[2] = 'g';
    3496:	06700993          	li	s3,103
    unlink(name);
    349a:	b9040913          	addi	s2,s0,-1136
    name[0] = 'b';
    349e:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    34a2:	b94408a3          	sb	s4,-1135(s0)
    name[2] = 'g';
    34a6:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + i;
    34aa:	0304879b          	addiw	a5,s1,48
    34ae:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    34b2:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    34b6:	854a                	mv	a0,s2
    34b8:	00003097          	auipc	ra,0x3
    34bc:	a10080e7          	jalr	-1520(ra) # 5ec8 <unlink>
  for(int i = 0; i < fi; i++){
    34c0:	2485                	addiw	s1,s1,1
    34c2:	fd549ee3          	bne	s1,s5,349e <diskfull+0x192>
}
    34c6:	49813083          	ld	ra,1176(sp)
    34ca:	49013403          	ld	s0,1168(sp)
    34ce:	48813483          	ld	s1,1160(sp)
    34d2:	48013903          	ld	s2,1152(sp)
    34d6:	47813983          	ld	s3,1144(sp)
    34da:	47013a03          	ld	s4,1136(sp)
    34de:	46813a83          	ld	s5,1128(sp)
    34e2:	46013b03          	ld	s6,1120(sp)
    34e6:	45813b83          	ld	s7,1112(sp)
    34ea:	45013c03          	ld	s8,1104(sp)
    34ee:	44813c83          	ld	s9,1096(sp)
    34f2:	44013d03          	ld	s10,1088(sp)
    34f6:	43813d83          	ld	s11,1080(sp)
    34fa:	4a010113          	addi	sp,sp,1184
    34fe:	8082                	ret
    close(fd);
    3500:	854e                	mv	a0,s3
    3502:	00003097          	auipc	ra,0x3
    3506:	99e080e7          	jalr	-1634(ra) # 5ea0 <close>
  for(fi = 0; done == 0; fi++){
    350a:	2a85                	addiw	s5,s5,1
    name[0] = 'b';
    350c:	b7a40823          	sb	s10,-1168(s0)
    name[1] = 'i';
    3510:	b79408a3          	sb	s9,-1167(s0)
    name[2] = 'g';
    3514:	b7840923          	sb	s8,-1166(s0)
    name[3] = '0' + fi;
    3518:	030a879b          	addiw	a5,s5,48
    351c:	b6f409a3          	sb	a5,-1165(s0)
    name[4] = '\0';
    3520:	b6040a23          	sb	zero,-1164(s0)
    unlink(name);
    3524:	855a                	mv	a0,s6
    3526:	00003097          	auipc	ra,0x3
    352a:	9a2080e7          	jalr	-1630(ra) # 5ec8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    352e:	85de                	mv	a1,s7
    3530:	855a                	mv	a0,s6
    3532:	00003097          	auipc	ra,0x3
    3536:	986080e7          	jalr	-1658(ra) # 5eb8 <open>
    353a:	89aa                	mv	s3,a0
    if(fd < 0){
    353c:	e40540e3          	bltz	a0,337c <diskfull+0x70>
    3540:	84ee                	mv	s1,s11
      if(write(fd, buf, BSIZE) != BSIZE){
    3542:	40000913          	li	s2,1024
    3546:	864a                	mv	a2,s2
    3548:	85d2                	mv	a1,s4
    354a:	854e                	mv	a0,s3
    354c:	00003097          	auipc	ra,0x3
    3550:	94c080e7          	jalr	-1716(ra) # 5e98 <write>
    3554:	e52511e3          	bne	a0,s2,3396 <diskfull+0x8a>
    for(int i = 0; i < MAXFILE; i++){
    3558:	34fd                	addiw	s1,s1,-1
    355a:	f4f5                	bnez	s1,3546 <diskfull+0x23a>
    355c:	b755                	j	3500 <diskfull+0x1f4>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    355e:	00004517          	auipc	a0,0x4
    3562:	0a250513          	addi	a0,a0,162 # 7600 <malloc+0x1356>
    3566:	00003097          	auipc	ra,0x3
    356a:	c88080e7          	jalr	-888(ra) # 61ee <printf>
    356e:	bd75                	j	342a <diskfull+0x11e>

0000000000003570 <iputtest>:
{
    3570:	1101                	addi	sp,sp,-32
    3572:	ec06                	sd	ra,24(sp)
    3574:	e822                	sd	s0,16(sp)
    3576:	e426                	sd	s1,8(sp)
    3578:	1000                	addi	s0,sp,32
    357a:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    357c:	00004517          	auipc	a0,0x4
    3580:	0b450513          	addi	a0,a0,180 # 7630 <malloc+0x1386>
    3584:	00003097          	auipc	ra,0x3
    3588:	95c080e7          	jalr	-1700(ra) # 5ee0 <mkdir>
    358c:	04054563          	bltz	a0,35d6 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3590:	00004517          	auipc	a0,0x4
    3594:	0a050513          	addi	a0,a0,160 # 7630 <malloc+0x1386>
    3598:	00003097          	auipc	ra,0x3
    359c:	950080e7          	jalr	-1712(ra) # 5ee8 <chdir>
    35a0:	04054963          	bltz	a0,35f2 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    35a4:	00004517          	auipc	a0,0x4
    35a8:	0cc50513          	addi	a0,a0,204 # 7670 <malloc+0x13c6>
    35ac:	00003097          	auipc	ra,0x3
    35b0:	91c080e7          	jalr	-1764(ra) # 5ec8 <unlink>
    35b4:	04054d63          	bltz	a0,360e <iputtest+0x9e>
  if(chdir("/") < 0){
    35b8:	00004517          	auipc	a0,0x4
    35bc:	0e850513          	addi	a0,a0,232 # 76a0 <malloc+0x13f6>
    35c0:	00003097          	auipc	ra,0x3
    35c4:	928080e7          	jalr	-1752(ra) # 5ee8 <chdir>
    35c8:	06054163          	bltz	a0,362a <iputtest+0xba>
}
    35cc:	60e2                	ld	ra,24(sp)
    35ce:	6442                	ld	s0,16(sp)
    35d0:	64a2                	ld	s1,8(sp)
    35d2:	6105                	addi	sp,sp,32
    35d4:	8082                	ret
    printf("%s: mkdir failed\n", s);
    35d6:	85a6                	mv	a1,s1
    35d8:	00004517          	auipc	a0,0x4
    35dc:	06050513          	addi	a0,a0,96 # 7638 <malloc+0x138e>
    35e0:	00003097          	auipc	ra,0x3
    35e4:	c0e080e7          	jalr	-1010(ra) # 61ee <printf>
    exit(1);
    35e8:	4505                	li	a0,1
    35ea:	00003097          	auipc	ra,0x3
    35ee:	88e080e7          	jalr	-1906(ra) # 5e78 <exit>
    printf("%s: chdir iputdir failed\n", s);
    35f2:	85a6                	mv	a1,s1
    35f4:	00004517          	auipc	a0,0x4
    35f8:	05c50513          	addi	a0,a0,92 # 7650 <malloc+0x13a6>
    35fc:	00003097          	auipc	ra,0x3
    3600:	bf2080e7          	jalr	-1038(ra) # 61ee <printf>
    exit(1);
    3604:	4505                	li	a0,1
    3606:	00003097          	auipc	ra,0x3
    360a:	872080e7          	jalr	-1934(ra) # 5e78 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    360e:	85a6                	mv	a1,s1
    3610:	00004517          	auipc	a0,0x4
    3614:	07050513          	addi	a0,a0,112 # 7680 <malloc+0x13d6>
    3618:	00003097          	auipc	ra,0x3
    361c:	bd6080e7          	jalr	-1066(ra) # 61ee <printf>
    exit(1);
    3620:	4505                	li	a0,1
    3622:	00003097          	auipc	ra,0x3
    3626:	856080e7          	jalr	-1962(ra) # 5e78 <exit>
    printf("%s: chdir / failed\n", s);
    362a:	85a6                	mv	a1,s1
    362c:	00004517          	auipc	a0,0x4
    3630:	07c50513          	addi	a0,a0,124 # 76a8 <malloc+0x13fe>
    3634:	00003097          	auipc	ra,0x3
    3638:	bba080e7          	jalr	-1094(ra) # 61ee <printf>
    exit(1);
    363c:	4505                	li	a0,1
    363e:	00003097          	auipc	ra,0x3
    3642:	83a080e7          	jalr	-1990(ra) # 5e78 <exit>

0000000000003646 <exitiputtest>:
{
    3646:	7179                	addi	sp,sp,-48
    3648:	f406                	sd	ra,40(sp)
    364a:	f022                	sd	s0,32(sp)
    364c:	ec26                	sd	s1,24(sp)
    364e:	1800                	addi	s0,sp,48
    3650:	84aa                	mv	s1,a0
  pid = fork();
    3652:	00003097          	auipc	ra,0x3
    3656:	81e080e7          	jalr	-2018(ra) # 5e70 <fork>
  if(pid < 0){
    365a:	04054663          	bltz	a0,36a6 <exitiputtest+0x60>
  if(pid == 0){
    365e:	ed45                	bnez	a0,3716 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    3660:	00004517          	auipc	a0,0x4
    3664:	fd050513          	addi	a0,a0,-48 # 7630 <malloc+0x1386>
    3668:	00003097          	auipc	ra,0x3
    366c:	878080e7          	jalr	-1928(ra) # 5ee0 <mkdir>
    3670:	04054963          	bltz	a0,36c2 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    3674:	00004517          	auipc	a0,0x4
    3678:	fbc50513          	addi	a0,a0,-68 # 7630 <malloc+0x1386>
    367c:	00003097          	auipc	ra,0x3
    3680:	86c080e7          	jalr	-1940(ra) # 5ee8 <chdir>
    3684:	04054d63          	bltz	a0,36de <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    3688:	00004517          	auipc	a0,0x4
    368c:	fe850513          	addi	a0,a0,-24 # 7670 <malloc+0x13c6>
    3690:	00003097          	auipc	ra,0x3
    3694:	838080e7          	jalr	-1992(ra) # 5ec8 <unlink>
    3698:	06054163          	bltz	a0,36fa <exitiputtest+0xb4>
    exit(0);
    369c:	4501                	li	a0,0
    369e:	00002097          	auipc	ra,0x2
    36a2:	7da080e7          	jalr	2010(ra) # 5e78 <exit>
    printf("%s: fork failed\n", s);
    36a6:	85a6                	mv	a1,s1
    36a8:	00003517          	auipc	a0,0x3
    36ac:	5c850513          	addi	a0,a0,1480 # 6c70 <malloc+0x9c6>
    36b0:	00003097          	auipc	ra,0x3
    36b4:	b3e080e7          	jalr	-1218(ra) # 61ee <printf>
    exit(1);
    36b8:	4505                	li	a0,1
    36ba:	00002097          	auipc	ra,0x2
    36be:	7be080e7          	jalr	1982(ra) # 5e78 <exit>
      printf("%s: mkdir failed\n", s);
    36c2:	85a6                	mv	a1,s1
    36c4:	00004517          	auipc	a0,0x4
    36c8:	f7450513          	addi	a0,a0,-140 # 7638 <malloc+0x138e>
    36cc:	00003097          	auipc	ra,0x3
    36d0:	b22080e7          	jalr	-1246(ra) # 61ee <printf>
      exit(1);
    36d4:	4505                	li	a0,1
    36d6:	00002097          	auipc	ra,0x2
    36da:	7a2080e7          	jalr	1954(ra) # 5e78 <exit>
      printf("%s: child chdir failed\n", s);
    36de:	85a6                	mv	a1,s1
    36e0:	00004517          	auipc	a0,0x4
    36e4:	fe050513          	addi	a0,a0,-32 # 76c0 <malloc+0x1416>
    36e8:	00003097          	auipc	ra,0x3
    36ec:	b06080e7          	jalr	-1274(ra) # 61ee <printf>
      exit(1);
    36f0:	4505                	li	a0,1
    36f2:	00002097          	auipc	ra,0x2
    36f6:	786080e7          	jalr	1926(ra) # 5e78 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    36fa:	85a6                	mv	a1,s1
    36fc:	00004517          	auipc	a0,0x4
    3700:	f8450513          	addi	a0,a0,-124 # 7680 <malloc+0x13d6>
    3704:	00003097          	auipc	ra,0x3
    3708:	aea080e7          	jalr	-1302(ra) # 61ee <printf>
      exit(1);
    370c:	4505                	li	a0,1
    370e:	00002097          	auipc	ra,0x2
    3712:	76a080e7          	jalr	1898(ra) # 5e78 <exit>
  wait(&xstatus);
    3716:	fdc40513          	addi	a0,s0,-36
    371a:	00002097          	auipc	ra,0x2
    371e:	766080e7          	jalr	1894(ra) # 5e80 <wait>
  exit(xstatus);
    3722:	fdc42503          	lw	a0,-36(s0)
    3726:	00002097          	auipc	ra,0x2
    372a:	752080e7          	jalr	1874(ra) # 5e78 <exit>

000000000000372e <dirtest>:
{
    372e:	1101                	addi	sp,sp,-32
    3730:	ec06                	sd	ra,24(sp)
    3732:	e822                	sd	s0,16(sp)
    3734:	e426                	sd	s1,8(sp)
    3736:	1000                	addi	s0,sp,32
    3738:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    373a:	00004517          	auipc	a0,0x4
    373e:	f9e50513          	addi	a0,a0,-98 # 76d8 <malloc+0x142e>
    3742:	00002097          	auipc	ra,0x2
    3746:	79e080e7          	jalr	1950(ra) # 5ee0 <mkdir>
    374a:	04054563          	bltz	a0,3794 <dirtest+0x66>
  if(chdir("dir0") < 0){
    374e:	00004517          	auipc	a0,0x4
    3752:	f8a50513          	addi	a0,a0,-118 # 76d8 <malloc+0x142e>
    3756:	00002097          	auipc	ra,0x2
    375a:	792080e7          	jalr	1938(ra) # 5ee8 <chdir>
    375e:	04054963          	bltz	a0,37b0 <dirtest+0x82>
  if(chdir("..") < 0){
    3762:	00004517          	auipc	a0,0x4
    3766:	f9650513          	addi	a0,a0,-106 # 76f8 <malloc+0x144e>
    376a:	00002097          	auipc	ra,0x2
    376e:	77e080e7          	jalr	1918(ra) # 5ee8 <chdir>
    3772:	04054d63          	bltz	a0,37cc <dirtest+0x9e>
  if(unlink("dir0") < 0){
    3776:	00004517          	auipc	a0,0x4
    377a:	f6250513          	addi	a0,a0,-158 # 76d8 <malloc+0x142e>
    377e:	00002097          	auipc	ra,0x2
    3782:	74a080e7          	jalr	1866(ra) # 5ec8 <unlink>
    3786:	06054163          	bltz	a0,37e8 <dirtest+0xba>
}
    378a:	60e2                	ld	ra,24(sp)
    378c:	6442                	ld	s0,16(sp)
    378e:	64a2                	ld	s1,8(sp)
    3790:	6105                	addi	sp,sp,32
    3792:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3794:	85a6                	mv	a1,s1
    3796:	00004517          	auipc	a0,0x4
    379a:	ea250513          	addi	a0,a0,-350 # 7638 <malloc+0x138e>
    379e:	00003097          	auipc	ra,0x3
    37a2:	a50080e7          	jalr	-1456(ra) # 61ee <printf>
    exit(1);
    37a6:	4505                	li	a0,1
    37a8:	00002097          	auipc	ra,0x2
    37ac:	6d0080e7          	jalr	1744(ra) # 5e78 <exit>
    printf("%s: chdir dir0 failed\n", s);
    37b0:	85a6                	mv	a1,s1
    37b2:	00004517          	auipc	a0,0x4
    37b6:	f2e50513          	addi	a0,a0,-210 # 76e0 <malloc+0x1436>
    37ba:	00003097          	auipc	ra,0x3
    37be:	a34080e7          	jalr	-1484(ra) # 61ee <printf>
    exit(1);
    37c2:	4505                	li	a0,1
    37c4:	00002097          	auipc	ra,0x2
    37c8:	6b4080e7          	jalr	1716(ra) # 5e78 <exit>
    printf("%s: chdir .. failed\n", s);
    37cc:	85a6                	mv	a1,s1
    37ce:	00004517          	auipc	a0,0x4
    37d2:	f3250513          	addi	a0,a0,-206 # 7700 <malloc+0x1456>
    37d6:	00003097          	auipc	ra,0x3
    37da:	a18080e7          	jalr	-1512(ra) # 61ee <printf>
    exit(1);
    37de:	4505                	li	a0,1
    37e0:	00002097          	auipc	ra,0x2
    37e4:	698080e7          	jalr	1688(ra) # 5e78 <exit>
    printf("%s: unlink dir0 failed\n", s);
    37e8:	85a6                	mv	a1,s1
    37ea:	00004517          	auipc	a0,0x4
    37ee:	f2e50513          	addi	a0,a0,-210 # 7718 <malloc+0x146e>
    37f2:	00003097          	auipc	ra,0x3
    37f6:	9fc080e7          	jalr	-1540(ra) # 61ee <printf>
    exit(1);
    37fa:	4505                	li	a0,1
    37fc:	00002097          	auipc	ra,0x2
    3800:	67c080e7          	jalr	1660(ra) # 5e78 <exit>

0000000000003804 <subdir>:
{
    3804:	1101                	addi	sp,sp,-32
    3806:	ec06                	sd	ra,24(sp)
    3808:	e822                	sd	s0,16(sp)
    380a:	e426                	sd	s1,8(sp)
    380c:	e04a                	sd	s2,0(sp)
    380e:	1000                	addi	s0,sp,32
    3810:	892a                	mv	s2,a0
  unlink("ff");
    3812:	00004517          	auipc	a0,0x4
    3816:	04e50513          	addi	a0,a0,78 # 7860 <malloc+0x15b6>
    381a:	00002097          	auipc	ra,0x2
    381e:	6ae080e7          	jalr	1710(ra) # 5ec8 <unlink>
  if(mkdir("dd") != 0){
    3822:	00004517          	auipc	a0,0x4
    3826:	f0e50513          	addi	a0,a0,-242 # 7730 <malloc+0x1486>
    382a:	00002097          	auipc	ra,0x2
    382e:	6b6080e7          	jalr	1718(ra) # 5ee0 <mkdir>
    3832:	38051663          	bnez	a0,3bbe <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3836:	20200593          	li	a1,514
    383a:	00004517          	auipc	a0,0x4
    383e:	f1650513          	addi	a0,a0,-234 # 7750 <malloc+0x14a6>
    3842:	00002097          	auipc	ra,0x2
    3846:	676080e7          	jalr	1654(ra) # 5eb8 <open>
    384a:	84aa                	mv	s1,a0
  if(fd < 0){
    384c:	38054763          	bltz	a0,3bda <subdir+0x3d6>
  write(fd, "ff", 2);
    3850:	4609                	li	a2,2
    3852:	00004597          	auipc	a1,0x4
    3856:	00e58593          	addi	a1,a1,14 # 7860 <malloc+0x15b6>
    385a:	00002097          	auipc	ra,0x2
    385e:	63e080e7          	jalr	1598(ra) # 5e98 <write>
  close(fd);
    3862:	8526                	mv	a0,s1
    3864:	00002097          	auipc	ra,0x2
    3868:	63c080e7          	jalr	1596(ra) # 5ea0 <close>
  if(unlink("dd") >= 0){
    386c:	00004517          	auipc	a0,0x4
    3870:	ec450513          	addi	a0,a0,-316 # 7730 <malloc+0x1486>
    3874:	00002097          	auipc	ra,0x2
    3878:	654080e7          	jalr	1620(ra) # 5ec8 <unlink>
    387c:	36055d63          	bgez	a0,3bf6 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3880:	00004517          	auipc	a0,0x4
    3884:	f2850513          	addi	a0,a0,-216 # 77a8 <malloc+0x14fe>
    3888:	00002097          	auipc	ra,0x2
    388c:	658080e7          	jalr	1624(ra) # 5ee0 <mkdir>
    3890:	38051163          	bnez	a0,3c12 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3894:	20200593          	li	a1,514
    3898:	00004517          	auipc	a0,0x4
    389c:	f3850513          	addi	a0,a0,-200 # 77d0 <malloc+0x1526>
    38a0:	00002097          	auipc	ra,0x2
    38a4:	618080e7          	jalr	1560(ra) # 5eb8 <open>
    38a8:	84aa                	mv	s1,a0
  if(fd < 0){
    38aa:	38054263          	bltz	a0,3c2e <subdir+0x42a>
  write(fd, "FF", 2);
    38ae:	4609                	li	a2,2
    38b0:	00004597          	auipc	a1,0x4
    38b4:	f5058593          	addi	a1,a1,-176 # 7800 <malloc+0x1556>
    38b8:	00002097          	auipc	ra,0x2
    38bc:	5e0080e7          	jalr	1504(ra) # 5e98 <write>
  close(fd);
    38c0:	8526                	mv	a0,s1
    38c2:	00002097          	auipc	ra,0x2
    38c6:	5de080e7          	jalr	1502(ra) # 5ea0 <close>
  fd = open("dd/dd/../ff", 0);
    38ca:	4581                	li	a1,0
    38cc:	00004517          	auipc	a0,0x4
    38d0:	f3c50513          	addi	a0,a0,-196 # 7808 <malloc+0x155e>
    38d4:	00002097          	auipc	ra,0x2
    38d8:	5e4080e7          	jalr	1508(ra) # 5eb8 <open>
    38dc:	84aa                	mv	s1,a0
  if(fd < 0){
    38de:	36054663          	bltz	a0,3c4a <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    38e2:	660d                	lui	a2,0x3
    38e4:	00009597          	auipc	a1,0x9
    38e8:	39458593          	addi	a1,a1,916 # cc78 <buf>
    38ec:	00002097          	auipc	ra,0x2
    38f0:	5a4080e7          	jalr	1444(ra) # 5e90 <read>
  if(cc != 2 || buf[0] != 'f'){
    38f4:	4789                	li	a5,2
    38f6:	36f51863          	bne	a0,a5,3c66 <subdir+0x462>
    38fa:	00009717          	auipc	a4,0x9
    38fe:	37e74703          	lbu	a4,894(a4) # cc78 <buf>
    3902:	06600793          	li	a5,102
    3906:	36f71063          	bne	a4,a5,3c66 <subdir+0x462>
  close(fd);
    390a:	8526                	mv	a0,s1
    390c:	00002097          	auipc	ra,0x2
    3910:	594080e7          	jalr	1428(ra) # 5ea0 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3914:	00004597          	auipc	a1,0x4
    3918:	f4458593          	addi	a1,a1,-188 # 7858 <malloc+0x15ae>
    391c:	00004517          	auipc	a0,0x4
    3920:	eb450513          	addi	a0,a0,-332 # 77d0 <malloc+0x1526>
    3924:	00002097          	auipc	ra,0x2
    3928:	5b4080e7          	jalr	1460(ra) # 5ed8 <link>
    392c:	34051b63          	bnez	a0,3c82 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3930:	00004517          	auipc	a0,0x4
    3934:	ea050513          	addi	a0,a0,-352 # 77d0 <malloc+0x1526>
    3938:	00002097          	auipc	ra,0x2
    393c:	590080e7          	jalr	1424(ra) # 5ec8 <unlink>
    3940:	34051f63          	bnez	a0,3c9e <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3944:	4581                	li	a1,0
    3946:	00004517          	auipc	a0,0x4
    394a:	e8a50513          	addi	a0,a0,-374 # 77d0 <malloc+0x1526>
    394e:	00002097          	auipc	ra,0x2
    3952:	56a080e7          	jalr	1386(ra) # 5eb8 <open>
    3956:	36055263          	bgez	a0,3cba <subdir+0x4b6>
  if(chdir("dd") != 0){
    395a:	00004517          	auipc	a0,0x4
    395e:	dd650513          	addi	a0,a0,-554 # 7730 <malloc+0x1486>
    3962:	00002097          	auipc	ra,0x2
    3966:	586080e7          	jalr	1414(ra) # 5ee8 <chdir>
    396a:	36051663          	bnez	a0,3cd6 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    396e:	00004517          	auipc	a0,0x4
    3972:	f8250513          	addi	a0,a0,-126 # 78f0 <malloc+0x1646>
    3976:	00002097          	auipc	ra,0x2
    397a:	572080e7          	jalr	1394(ra) # 5ee8 <chdir>
    397e:	36051a63          	bnez	a0,3cf2 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3982:	00004517          	auipc	a0,0x4
    3986:	f9e50513          	addi	a0,a0,-98 # 7920 <malloc+0x1676>
    398a:	00002097          	auipc	ra,0x2
    398e:	55e080e7          	jalr	1374(ra) # 5ee8 <chdir>
    3992:	36051e63          	bnez	a0,3d0e <subdir+0x50a>
  if(chdir("./..") != 0){
    3996:	00004517          	auipc	a0,0x4
    399a:	fba50513          	addi	a0,a0,-70 # 7950 <malloc+0x16a6>
    399e:	00002097          	auipc	ra,0x2
    39a2:	54a080e7          	jalr	1354(ra) # 5ee8 <chdir>
    39a6:	38051263          	bnez	a0,3d2a <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    39aa:	4581                	li	a1,0
    39ac:	00004517          	auipc	a0,0x4
    39b0:	eac50513          	addi	a0,a0,-340 # 7858 <malloc+0x15ae>
    39b4:	00002097          	auipc	ra,0x2
    39b8:	504080e7          	jalr	1284(ra) # 5eb8 <open>
    39bc:	84aa                	mv	s1,a0
  if(fd < 0){
    39be:	38054463          	bltz	a0,3d46 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    39c2:	660d                	lui	a2,0x3
    39c4:	00009597          	auipc	a1,0x9
    39c8:	2b458593          	addi	a1,a1,692 # cc78 <buf>
    39cc:	00002097          	auipc	ra,0x2
    39d0:	4c4080e7          	jalr	1220(ra) # 5e90 <read>
    39d4:	4789                	li	a5,2
    39d6:	38f51663          	bne	a0,a5,3d62 <subdir+0x55e>
  close(fd);
    39da:	8526                	mv	a0,s1
    39dc:	00002097          	auipc	ra,0x2
    39e0:	4c4080e7          	jalr	1220(ra) # 5ea0 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    39e4:	4581                	li	a1,0
    39e6:	00004517          	auipc	a0,0x4
    39ea:	dea50513          	addi	a0,a0,-534 # 77d0 <malloc+0x1526>
    39ee:	00002097          	auipc	ra,0x2
    39f2:	4ca080e7          	jalr	1226(ra) # 5eb8 <open>
    39f6:	38055463          	bgez	a0,3d7e <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    39fa:	20200593          	li	a1,514
    39fe:	00004517          	auipc	a0,0x4
    3a02:	fe250513          	addi	a0,a0,-30 # 79e0 <malloc+0x1736>
    3a06:	00002097          	auipc	ra,0x2
    3a0a:	4b2080e7          	jalr	1202(ra) # 5eb8 <open>
    3a0e:	38055663          	bgez	a0,3d9a <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3a12:	20200593          	li	a1,514
    3a16:	00004517          	auipc	a0,0x4
    3a1a:	ffa50513          	addi	a0,a0,-6 # 7a10 <malloc+0x1766>
    3a1e:	00002097          	auipc	ra,0x2
    3a22:	49a080e7          	jalr	1178(ra) # 5eb8 <open>
    3a26:	38055863          	bgez	a0,3db6 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3a2a:	20000593          	li	a1,512
    3a2e:	00004517          	auipc	a0,0x4
    3a32:	d0250513          	addi	a0,a0,-766 # 7730 <malloc+0x1486>
    3a36:	00002097          	auipc	ra,0x2
    3a3a:	482080e7          	jalr	1154(ra) # 5eb8 <open>
    3a3e:	38055a63          	bgez	a0,3dd2 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3a42:	4589                	li	a1,2
    3a44:	00004517          	auipc	a0,0x4
    3a48:	cec50513          	addi	a0,a0,-788 # 7730 <malloc+0x1486>
    3a4c:	00002097          	auipc	ra,0x2
    3a50:	46c080e7          	jalr	1132(ra) # 5eb8 <open>
    3a54:	38055d63          	bgez	a0,3dee <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3a58:	4585                	li	a1,1
    3a5a:	00004517          	auipc	a0,0x4
    3a5e:	cd650513          	addi	a0,a0,-810 # 7730 <malloc+0x1486>
    3a62:	00002097          	auipc	ra,0x2
    3a66:	456080e7          	jalr	1110(ra) # 5eb8 <open>
    3a6a:	3a055063          	bgez	a0,3e0a <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3a6e:	00004597          	auipc	a1,0x4
    3a72:	03258593          	addi	a1,a1,50 # 7aa0 <malloc+0x17f6>
    3a76:	00004517          	auipc	a0,0x4
    3a7a:	f6a50513          	addi	a0,a0,-150 # 79e0 <malloc+0x1736>
    3a7e:	00002097          	auipc	ra,0x2
    3a82:	45a080e7          	jalr	1114(ra) # 5ed8 <link>
    3a86:	3a050063          	beqz	a0,3e26 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3a8a:	00004597          	auipc	a1,0x4
    3a8e:	01658593          	addi	a1,a1,22 # 7aa0 <malloc+0x17f6>
    3a92:	00004517          	auipc	a0,0x4
    3a96:	f7e50513          	addi	a0,a0,-130 # 7a10 <malloc+0x1766>
    3a9a:	00002097          	auipc	ra,0x2
    3a9e:	43e080e7          	jalr	1086(ra) # 5ed8 <link>
    3aa2:	3a050063          	beqz	a0,3e42 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3aa6:	00004597          	auipc	a1,0x4
    3aaa:	db258593          	addi	a1,a1,-590 # 7858 <malloc+0x15ae>
    3aae:	00004517          	auipc	a0,0x4
    3ab2:	ca250513          	addi	a0,a0,-862 # 7750 <malloc+0x14a6>
    3ab6:	00002097          	auipc	ra,0x2
    3aba:	422080e7          	jalr	1058(ra) # 5ed8 <link>
    3abe:	3a050063          	beqz	a0,3e5e <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3ac2:	00004517          	auipc	a0,0x4
    3ac6:	f1e50513          	addi	a0,a0,-226 # 79e0 <malloc+0x1736>
    3aca:	00002097          	auipc	ra,0x2
    3ace:	416080e7          	jalr	1046(ra) # 5ee0 <mkdir>
    3ad2:	3a050463          	beqz	a0,3e7a <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3ad6:	00004517          	auipc	a0,0x4
    3ada:	f3a50513          	addi	a0,a0,-198 # 7a10 <malloc+0x1766>
    3ade:	00002097          	auipc	ra,0x2
    3ae2:	402080e7          	jalr	1026(ra) # 5ee0 <mkdir>
    3ae6:	3a050863          	beqz	a0,3e96 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3aea:	00004517          	auipc	a0,0x4
    3aee:	d6e50513          	addi	a0,a0,-658 # 7858 <malloc+0x15ae>
    3af2:	00002097          	auipc	ra,0x2
    3af6:	3ee080e7          	jalr	1006(ra) # 5ee0 <mkdir>
    3afa:	3a050c63          	beqz	a0,3eb2 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3afe:	00004517          	auipc	a0,0x4
    3b02:	f1250513          	addi	a0,a0,-238 # 7a10 <malloc+0x1766>
    3b06:	00002097          	auipc	ra,0x2
    3b0a:	3c2080e7          	jalr	962(ra) # 5ec8 <unlink>
    3b0e:	3c050063          	beqz	a0,3ece <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3b12:	00004517          	auipc	a0,0x4
    3b16:	ece50513          	addi	a0,a0,-306 # 79e0 <malloc+0x1736>
    3b1a:	00002097          	auipc	ra,0x2
    3b1e:	3ae080e7          	jalr	942(ra) # 5ec8 <unlink>
    3b22:	3c050463          	beqz	a0,3eea <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	c2a50513          	addi	a0,a0,-982 # 7750 <malloc+0x14a6>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	3ba080e7          	jalr	954(ra) # 5ee8 <chdir>
    3b36:	3c050863          	beqz	a0,3f06 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3b3a:	00004517          	auipc	a0,0x4
    3b3e:	0b650513          	addi	a0,a0,182 # 7bf0 <malloc+0x1946>
    3b42:	00002097          	auipc	ra,0x2
    3b46:	3a6080e7          	jalr	934(ra) # 5ee8 <chdir>
    3b4a:	3c050c63          	beqz	a0,3f22 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3b4e:	00004517          	auipc	a0,0x4
    3b52:	d0a50513          	addi	a0,a0,-758 # 7858 <malloc+0x15ae>
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	372080e7          	jalr	882(ra) # 5ec8 <unlink>
    3b5e:	3e051063          	bnez	a0,3f3e <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3b62:	00004517          	auipc	a0,0x4
    3b66:	bee50513          	addi	a0,a0,-1042 # 7750 <malloc+0x14a6>
    3b6a:	00002097          	auipc	ra,0x2
    3b6e:	35e080e7          	jalr	862(ra) # 5ec8 <unlink>
    3b72:	3e051463          	bnez	a0,3f5a <subdir+0x756>
  if(unlink("dd") == 0){
    3b76:	00004517          	auipc	a0,0x4
    3b7a:	bba50513          	addi	a0,a0,-1094 # 7730 <malloc+0x1486>
    3b7e:	00002097          	auipc	ra,0x2
    3b82:	34a080e7          	jalr	842(ra) # 5ec8 <unlink>
    3b86:	3e050863          	beqz	a0,3f76 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3b8a:	00004517          	auipc	a0,0x4
    3b8e:	0d650513          	addi	a0,a0,214 # 7c60 <malloc+0x19b6>
    3b92:	00002097          	auipc	ra,0x2
    3b96:	336080e7          	jalr	822(ra) # 5ec8 <unlink>
    3b9a:	3e054c63          	bltz	a0,3f92 <subdir+0x78e>
  if(unlink("dd") < 0){
    3b9e:	00004517          	auipc	a0,0x4
    3ba2:	b9250513          	addi	a0,a0,-1134 # 7730 <malloc+0x1486>
    3ba6:	00002097          	auipc	ra,0x2
    3baa:	322080e7          	jalr	802(ra) # 5ec8 <unlink>
    3bae:	40054063          	bltz	a0,3fae <subdir+0x7aa>
}
    3bb2:	60e2                	ld	ra,24(sp)
    3bb4:	6442                	ld	s0,16(sp)
    3bb6:	64a2                	ld	s1,8(sp)
    3bb8:	6902                	ld	s2,0(sp)
    3bba:	6105                	addi	sp,sp,32
    3bbc:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3bbe:	85ca                	mv	a1,s2
    3bc0:	00004517          	auipc	a0,0x4
    3bc4:	b7850513          	addi	a0,a0,-1160 # 7738 <malloc+0x148e>
    3bc8:	00002097          	auipc	ra,0x2
    3bcc:	626080e7          	jalr	1574(ra) # 61ee <printf>
    exit(1);
    3bd0:	4505                	li	a0,1
    3bd2:	00002097          	auipc	ra,0x2
    3bd6:	2a6080e7          	jalr	678(ra) # 5e78 <exit>
    printf("%s: create dd/ff failed\n", s);
    3bda:	85ca                	mv	a1,s2
    3bdc:	00004517          	auipc	a0,0x4
    3be0:	b7c50513          	addi	a0,a0,-1156 # 7758 <malloc+0x14ae>
    3be4:	00002097          	auipc	ra,0x2
    3be8:	60a080e7          	jalr	1546(ra) # 61ee <printf>
    exit(1);
    3bec:	4505                	li	a0,1
    3bee:	00002097          	auipc	ra,0x2
    3bf2:	28a080e7          	jalr	650(ra) # 5e78 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3bf6:	85ca                	mv	a1,s2
    3bf8:	00004517          	auipc	a0,0x4
    3bfc:	b8050513          	addi	a0,a0,-1152 # 7778 <malloc+0x14ce>
    3c00:	00002097          	auipc	ra,0x2
    3c04:	5ee080e7          	jalr	1518(ra) # 61ee <printf>
    exit(1);
    3c08:	4505                	li	a0,1
    3c0a:	00002097          	auipc	ra,0x2
    3c0e:	26e080e7          	jalr	622(ra) # 5e78 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3c12:	85ca                	mv	a1,s2
    3c14:	00004517          	auipc	a0,0x4
    3c18:	b9c50513          	addi	a0,a0,-1124 # 77b0 <malloc+0x1506>
    3c1c:	00002097          	auipc	ra,0x2
    3c20:	5d2080e7          	jalr	1490(ra) # 61ee <printf>
    exit(1);
    3c24:	4505                	li	a0,1
    3c26:	00002097          	auipc	ra,0x2
    3c2a:	252080e7          	jalr	594(ra) # 5e78 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3c2e:	85ca                	mv	a1,s2
    3c30:	00004517          	auipc	a0,0x4
    3c34:	bb050513          	addi	a0,a0,-1104 # 77e0 <malloc+0x1536>
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	5b6080e7          	jalr	1462(ra) # 61ee <printf>
    exit(1);
    3c40:	4505                	li	a0,1
    3c42:	00002097          	auipc	ra,0x2
    3c46:	236080e7          	jalr	566(ra) # 5e78 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3c4a:	85ca                	mv	a1,s2
    3c4c:	00004517          	auipc	a0,0x4
    3c50:	bcc50513          	addi	a0,a0,-1076 # 7818 <malloc+0x156e>
    3c54:	00002097          	auipc	ra,0x2
    3c58:	59a080e7          	jalr	1434(ra) # 61ee <printf>
    exit(1);
    3c5c:	4505                	li	a0,1
    3c5e:	00002097          	auipc	ra,0x2
    3c62:	21a080e7          	jalr	538(ra) # 5e78 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3c66:	85ca                	mv	a1,s2
    3c68:	00004517          	auipc	a0,0x4
    3c6c:	bd050513          	addi	a0,a0,-1072 # 7838 <malloc+0x158e>
    3c70:	00002097          	auipc	ra,0x2
    3c74:	57e080e7          	jalr	1406(ra) # 61ee <printf>
    exit(1);
    3c78:	4505                	li	a0,1
    3c7a:	00002097          	auipc	ra,0x2
    3c7e:	1fe080e7          	jalr	510(ra) # 5e78 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3c82:	85ca                	mv	a1,s2
    3c84:	00004517          	auipc	a0,0x4
    3c88:	be450513          	addi	a0,a0,-1052 # 7868 <malloc+0x15be>
    3c8c:	00002097          	auipc	ra,0x2
    3c90:	562080e7          	jalr	1378(ra) # 61ee <printf>
    exit(1);
    3c94:	4505                	li	a0,1
    3c96:	00002097          	auipc	ra,0x2
    3c9a:	1e2080e7          	jalr	482(ra) # 5e78 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3c9e:	85ca                	mv	a1,s2
    3ca0:	00004517          	auipc	a0,0x4
    3ca4:	bf050513          	addi	a0,a0,-1040 # 7890 <malloc+0x15e6>
    3ca8:	00002097          	auipc	ra,0x2
    3cac:	546080e7          	jalr	1350(ra) # 61ee <printf>
    exit(1);
    3cb0:	4505                	li	a0,1
    3cb2:	00002097          	auipc	ra,0x2
    3cb6:	1c6080e7          	jalr	454(ra) # 5e78 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3cba:	85ca                	mv	a1,s2
    3cbc:	00004517          	auipc	a0,0x4
    3cc0:	bf450513          	addi	a0,a0,-1036 # 78b0 <malloc+0x1606>
    3cc4:	00002097          	auipc	ra,0x2
    3cc8:	52a080e7          	jalr	1322(ra) # 61ee <printf>
    exit(1);
    3ccc:	4505                	li	a0,1
    3cce:	00002097          	auipc	ra,0x2
    3cd2:	1aa080e7          	jalr	426(ra) # 5e78 <exit>
    printf("%s: chdir dd failed\n", s);
    3cd6:	85ca                	mv	a1,s2
    3cd8:	00004517          	auipc	a0,0x4
    3cdc:	c0050513          	addi	a0,a0,-1024 # 78d8 <malloc+0x162e>
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	50e080e7          	jalr	1294(ra) # 61ee <printf>
    exit(1);
    3ce8:	4505                	li	a0,1
    3cea:	00002097          	auipc	ra,0x2
    3cee:	18e080e7          	jalr	398(ra) # 5e78 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3cf2:	85ca                	mv	a1,s2
    3cf4:	00004517          	auipc	a0,0x4
    3cf8:	c0c50513          	addi	a0,a0,-1012 # 7900 <malloc+0x1656>
    3cfc:	00002097          	auipc	ra,0x2
    3d00:	4f2080e7          	jalr	1266(ra) # 61ee <printf>
    exit(1);
    3d04:	4505                	li	a0,1
    3d06:	00002097          	auipc	ra,0x2
    3d0a:	172080e7          	jalr	370(ra) # 5e78 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3d0e:	85ca                	mv	a1,s2
    3d10:	00004517          	auipc	a0,0x4
    3d14:	c2050513          	addi	a0,a0,-992 # 7930 <malloc+0x1686>
    3d18:	00002097          	auipc	ra,0x2
    3d1c:	4d6080e7          	jalr	1238(ra) # 61ee <printf>
    exit(1);
    3d20:	4505                	li	a0,1
    3d22:	00002097          	auipc	ra,0x2
    3d26:	156080e7          	jalr	342(ra) # 5e78 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3d2a:	85ca                	mv	a1,s2
    3d2c:	00004517          	auipc	a0,0x4
    3d30:	c2c50513          	addi	a0,a0,-980 # 7958 <malloc+0x16ae>
    3d34:	00002097          	auipc	ra,0x2
    3d38:	4ba080e7          	jalr	1210(ra) # 61ee <printf>
    exit(1);
    3d3c:	4505                	li	a0,1
    3d3e:	00002097          	auipc	ra,0x2
    3d42:	13a080e7          	jalr	314(ra) # 5e78 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3d46:	85ca                	mv	a1,s2
    3d48:	00004517          	auipc	a0,0x4
    3d4c:	c2850513          	addi	a0,a0,-984 # 7970 <malloc+0x16c6>
    3d50:	00002097          	auipc	ra,0x2
    3d54:	49e080e7          	jalr	1182(ra) # 61ee <printf>
    exit(1);
    3d58:	4505                	li	a0,1
    3d5a:	00002097          	auipc	ra,0x2
    3d5e:	11e080e7          	jalr	286(ra) # 5e78 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3d62:	85ca                	mv	a1,s2
    3d64:	00004517          	auipc	a0,0x4
    3d68:	c2c50513          	addi	a0,a0,-980 # 7990 <malloc+0x16e6>
    3d6c:	00002097          	auipc	ra,0x2
    3d70:	482080e7          	jalr	1154(ra) # 61ee <printf>
    exit(1);
    3d74:	4505                	li	a0,1
    3d76:	00002097          	auipc	ra,0x2
    3d7a:	102080e7          	jalr	258(ra) # 5e78 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3d7e:	85ca                	mv	a1,s2
    3d80:	00004517          	auipc	a0,0x4
    3d84:	c3050513          	addi	a0,a0,-976 # 79b0 <malloc+0x1706>
    3d88:	00002097          	auipc	ra,0x2
    3d8c:	466080e7          	jalr	1126(ra) # 61ee <printf>
    exit(1);
    3d90:	4505                	li	a0,1
    3d92:	00002097          	auipc	ra,0x2
    3d96:	0e6080e7          	jalr	230(ra) # 5e78 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3d9a:	85ca                	mv	a1,s2
    3d9c:	00004517          	auipc	a0,0x4
    3da0:	c5450513          	addi	a0,a0,-940 # 79f0 <malloc+0x1746>
    3da4:	00002097          	auipc	ra,0x2
    3da8:	44a080e7          	jalr	1098(ra) # 61ee <printf>
    exit(1);
    3dac:	4505                	li	a0,1
    3dae:	00002097          	auipc	ra,0x2
    3db2:	0ca080e7          	jalr	202(ra) # 5e78 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3db6:	85ca                	mv	a1,s2
    3db8:	00004517          	auipc	a0,0x4
    3dbc:	c6850513          	addi	a0,a0,-920 # 7a20 <malloc+0x1776>
    3dc0:	00002097          	auipc	ra,0x2
    3dc4:	42e080e7          	jalr	1070(ra) # 61ee <printf>
    exit(1);
    3dc8:	4505                	li	a0,1
    3dca:	00002097          	auipc	ra,0x2
    3dce:	0ae080e7          	jalr	174(ra) # 5e78 <exit>
    printf("%s: create dd succeeded!\n", s);
    3dd2:	85ca                	mv	a1,s2
    3dd4:	00004517          	auipc	a0,0x4
    3dd8:	c6c50513          	addi	a0,a0,-916 # 7a40 <malloc+0x1796>
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	412080e7          	jalr	1042(ra) # 61ee <printf>
    exit(1);
    3de4:	4505                	li	a0,1
    3de6:	00002097          	auipc	ra,0x2
    3dea:	092080e7          	jalr	146(ra) # 5e78 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3dee:	85ca                	mv	a1,s2
    3df0:	00004517          	auipc	a0,0x4
    3df4:	c7050513          	addi	a0,a0,-912 # 7a60 <malloc+0x17b6>
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	3f6080e7          	jalr	1014(ra) # 61ee <printf>
    exit(1);
    3e00:	4505                	li	a0,1
    3e02:	00002097          	auipc	ra,0x2
    3e06:	076080e7          	jalr	118(ra) # 5e78 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3e0a:	85ca                	mv	a1,s2
    3e0c:	00004517          	auipc	a0,0x4
    3e10:	c7450513          	addi	a0,a0,-908 # 7a80 <malloc+0x17d6>
    3e14:	00002097          	auipc	ra,0x2
    3e18:	3da080e7          	jalr	986(ra) # 61ee <printf>
    exit(1);
    3e1c:	4505                	li	a0,1
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	05a080e7          	jalr	90(ra) # 5e78 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3e26:	85ca                	mv	a1,s2
    3e28:	00004517          	auipc	a0,0x4
    3e2c:	c8850513          	addi	a0,a0,-888 # 7ab0 <malloc+0x1806>
    3e30:	00002097          	auipc	ra,0x2
    3e34:	3be080e7          	jalr	958(ra) # 61ee <printf>
    exit(1);
    3e38:	4505                	li	a0,1
    3e3a:	00002097          	auipc	ra,0x2
    3e3e:	03e080e7          	jalr	62(ra) # 5e78 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3e42:	85ca                	mv	a1,s2
    3e44:	00004517          	auipc	a0,0x4
    3e48:	c9450513          	addi	a0,a0,-876 # 7ad8 <malloc+0x182e>
    3e4c:	00002097          	auipc	ra,0x2
    3e50:	3a2080e7          	jalr	930(ra) # 61ee <printf>
    exit(1);
    3e54:	4505                	li	a0,1
    3e56:	00002097          	auipc	ra,0x2
    3e5a:	022080e7          	jalr	34(ra) # 5e78 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3e5e:	85ca                	mv	a1,s2
    3e60:	00004517          	auipc	a0,0x4
    3e64:	ca050513          	addi	a0,a0,-864 # 7b00 <malloc+0x1856>
    3e68:	00002097          	auipc	ra,0x2
    3e6c:	386080e7          	jalr	902(ra) # 61ee <printf>
    exit(1);
    3e70:	4505                	li	a0,1
    3e72:	00002097          	auipc	ra,0x2
    3e76:	006080e7          	jalr	6(ra) # 5e78 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3e7a:	85ca                	mv	a1,s2
    3e7c:	00004517          	auipc	a0,0x4
    3e80:	cac50513          	addi	a0,a0,-852 # 7b28 <malloc+0x187e>
    3e84:	00002097          	auipc	ra,0x2
    3e88:	36a080e7          	jalr	874(ra) # 61ee <printf>
    exit(1);
    3e8c:	4505                	li	a0,1
    3e8e:	00002097          	auipc	ra,0x2
    3e92:	fea080e7          	jalr	-22(ra) # 5e78 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3e96:	85ca                	mv	a1,s2
    3e98:	00004517          	auipc	a0,0x4
    3e9c:	cb050513          	addi	a0,a0,-848 # 7b48 <malloc+0x189e>
    3ea0:	00002097          	auipc	ra,0x2
    3ea4:	34e080e7          	jalr	846(ra) # 61ee <printf>
    exit(1);
    3ea8:	4505                	li	a0,1
    3eaa:	00002097          	auipc	ra,0x2
    3eae:	fce080e7          	jalr	-50(ra) # 5e78 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3eb2:	85ca                	mv	a1,s2
    3eb4:	00004517          	auipc	a0,0x4
    3eb8:	cb450513          	addi	a0,a0,-844 # 7b68 <malloc+0x18be>
    3ebc:	00002097          	auipc	ra,0x2
    3ec0:	332080e7          	jalr	818(ra) # 61ee <printf>
    exit(1);
    3ec4:	4505                	li	a0,1
    3ec6:	00002097          	auipc	ra,0x2
    3eca:	fb2080e7          	jalr	-78(ra) # 5e78 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3ece:	85ca                	mv	a1,s2
    3ed0:	00004517          	auipc	a0,0x4
    3ed4:	cc050513          	addi	a0,a0,-832 # 7b90 <malloc+0x18e6>
    3ed8:	00002097          	auipc	ra,0x2
    3edc:	316080e7          	jalr	790(ra) # 61ee <printf>
    exit(1);
    3ee0:	4505                	li	a0,1
    3ee2:	00002097          	auipc	ra,0x2
    3ee6:	f96080e7          	jalr	-106(ra) # 5e78 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3eea:	85ca                	mv	a1,s2
    3eec:	00004517          	auipc	a0,0x4
    3ef0:	cc450513          	addi	a0,a0,-828 # 7bb0 <malloc+0x1906>
    3ef4:	00002097          	auipc	ra,0x2
    3ef8:	2fa080e7          	jalr	762(ra) # 61ee <printf>
    exit(1);
    3efc:	4505                	li	a0,1
    3efe:	00002097          	auipc	ra,0x2
    3f02:	f7a080e7          	jalr	-134(ra) # 5e78 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3f06:	85ca                	mv	a1,s2
    3f08:	00004517          	auipc	a0,0x4
    3f0c:	cc850513          	addi	a0,a0,-824 # 7bd0 <malloc+0x1926>
    3f10:	00002097          	auipc	ra,0x2
    3f14:	2de080e7          	jalr	734(ra) # 61ee <printf>
    exit(1);
    3f18:	4505                	li	a0,1
    3f1a:	00002097          	auipc	ra,0x2
    3f1e:	f5e080e7          	jalr	-162(ra) # 5e78 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3f22:	85ca                	mv	a1,s2
    3f24:	00004517          	auipc	a0,0x4
    3f28:	cd450513          	addi	a0,a0,-812 # 7bf8 <malloc+0x194e>
    3f2c:	00002097          	auipc	ra,0x2
    3f30:	2c2080e7          	jalr	706(ra) # 61ee <printf>
    exit(1);
    3f34:	4505                	li	a0,1
    3f36:	00002097          	auipc	ra,0x2
    3f3a:	f42080e7          	jalr	-190(ra) # 5e78 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3f3e:	85ca                	mv	a1,s2
    3f40:	00004517          	auipc	a0,0x4
    3f44:	95050513          	addi	a0,a0,-1712 # 7890 <malloc+0x15e6>
    3f48:	00002097          	auipc	ra,0x2
    3f4c:	2a6080e7          	jalr	678(ra) # 61ee <printf>
    exit(1);
    3f50:	4505                	li	a0,1
    3f52:	00002097          	auipc	ra,0x2
    3f56:	f26080e7          	jalr	-218(ra) # 5e78 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3f5a:	85ca                	mv	a1,s2
    3f5c:	00004517          	auipc	a0,0x4
    3f60:	cbc50513          	addi	a0,a0,-836 # 7c18 <malloc+0x196e>
    3f64:	00002097          	auipc	ra,0x2
    3f68:	28a080e7          	jalr	650(ra) # 61ee <printf>
    exit(1);
    3f6c:	4505                	li	a0,1
    3f6e:	00002097          	auipc	ra,0x2
    3f72:	f0a080e7          	jalr	-246(ra) # 5e78 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3f76:	85ca                	mv	a1,s2
    3f78:	00004517          	auipc	a0,0x4
    3f7c:	cc050513          	addi	a0,a0,-832 # 7c38 <malloc+0x198e>
    3f80:	00002097          	auipc	ra,0x2
    3f84:	26e080e7          	jalr	622(ra) # 61ee <printf>
    exit(1);
    3f88:	4505                	li	a0,1
    3f8a:	00002097          	auipc	ra,0x2
    3f8e:	eee080e7          	jalr	-274(ra) # 5e78 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3f92:	85ca                	mv	a1,s2
    3f94:	00004517          	auipc	a0,0x4
    3f98:	cd450513          	addi	a0,a0,-812 # 7c68 <malloc+0x19be>
    3f9c:	00002097          	auipc	ra,0x2
    3fa0:	252080e7          	jalr	594(ra) # 61ee <printf>
    exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	00002097          	auipc	ra,0x2
    3faa:	ed2080e7          	jalr	-302(ra) # 5e78 <exit>
    printf("%s: unlink dd failed\n", s);
    3fae:	85ca                	mv	a1,s2
    3fb0:	00004517          	auipc	a0,0x4
    3fb4:	cd850513          	addi	a0,a0,-808 # 7c88 <malloc+0x19de>
    3fb8:	00002097          	auipc	ra,0x2
    3fbc:	236080e7          	jalr	566(ra) # 61ee <printf>
    exit(1);
    3fc0:	4505                	li	a0,1
    3fc2:	00002097          	auipc	ra,0x2
    3fc6:	eb6080e7          	jalr	-330(ra) # 5e78 <exit>

0000000000003fca <rmdot>:
{
    3fca:	1101                	addi	sp,sp,-32
    3fcc:	ec06                	sd	ra,24(sp)
    3fce:	e822                	sd	s0,16(sp)
    3fd0:	e426                	sd	s1,8(sp)
    3fd2:	1000                	addi	s0,sp,32
    3fd4:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3fd6:	00004517          	auipc	a0,0x4
    3fda:	cca50513          	addi	a0,a0,-822 # 7ca0 <malloc+0x19f6>
    3fde:	00002097          	auipc	ra,0x2
    3fe2:	f02080e7          	jalr	-254(ra) # 5ee0 <mkdir>
    3fe6:	e549                	bnez	a0,4070 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3fe8:	00004517          	auipc	a0,0x4
    3fec:	cb850513          	addi	a0,a0,-840 # 7ca0 <malloc+0x19f6>
    3ff0:	00002097          	auipc	ra,0x2
    3ff4:	ef8080e7          	jalr	-264(ra) # 5ee8 <chdir>
    3ff8:	e951                	bnez	a0,408c <rmdot+0xc2>
  if(unlink(".") == 0){
    3ffa:	00003517          	auipc	a0,0x3
    3ffe:	ad650513          	addi	a0,a0,-1322 # 6ad0 <malloc+0x826>
    4002:	00002097          	auipc	ra,0x2
    4006:	ec6080e7          	jalr	-314(ra) # 5ec8 <unlink>
    400a:	cd59                	beqz	a0,40a8 <rmdot+0xde>
  if(unlink("..") == 0){
    400c:	00003517          	auipc	a0,0x3
    4010:	6ec50513          	addi	a0,a0,1772 # 76f8 <malloc+0x144e>
    4014:	00002097          	auipc	ra,0x2
    4018:	eb4080e7          	jalr	-332(ra) # 5ec8 <unlink>
    401c:	c545                	beqz	a0,40c4 <rmdot+0xfa>
  if(chdir("/") != 0){
    401e:	00003517          	auipc	a0,0x3
    4022:	68250513          	addi	a0,a0,1666 # 76a0 <malloc+0x13f6>
    4026:	00002097          	auipc	ra,0x2
    402a:	ec2080e7          	jalr	-318(ra) # 5ee8 <chdir>
    402e:	e94d                	bnez	a0,40e0 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    4030:	00004517          	auipc	a0,0x4
    4034:	cd850513          	addi	a0,a0,-808 # 7d08 <malloc+0x1a5e>
    4038:	00002097          	auipc	ra,0x2
    403c:	e90080e7          	jalr	-368(ra) # 5ec8 <unlink>
    4040:	cd55                	beqz	a0,40fc <rmdot+0x132>
  if(unlink("dots/..") == 0){
    4042:	00004517          	auipc	a0,0x4
    4046:	cee50513          	addi	a0,a0,-786 # 7d30 <malloc+0x1a86>
    404a:	00002097          	auipc	ra,0x2
    404e:	e7e080e7          	jalr	-386(ra) # 5ec8 <unlink>
    4052:	c179                	beqz	a0,4118 <rmdot+0x14e>
  if(unlink("dots") != 0){
    4054:	00004517          	auipc	a0,0x4
    4058:	c4c50513          	addi	a0,a0,-948 # 7ca0 <malloc+0x19f6>
    405c:	00002097          	auipc	ra,0x2
    4060:	e6c080e7          	jalr	-404(ra) # 5ec8 <unlink>
    4064:	e961                	bnez	a0,4134 <rmdot+0x16a>
}
    4066:	60e2                	ld	ra,24(sp)
    4068:	6442                	ld	s0,16(sp)
    406a:	64a2                	ld	s1,8(sp)
    406c:	6105                	addi	sp,sp,32
    406e:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    4070:	85a6                	mv	a1,s1
    4072:	00004517          	auipc	a0,0x4
    4076:	c3650513          	addi	a0,a0,-970 # 7ca8 <malloc+0x19fe>
    407a:	00002097          	auipc	ra,0x2
    407e:	174080e7          	jalr	372(ra) # 61ee <printf>
    exit(1);
    4082:	4505                	li	a0,1
    4084:	00002097          	auipc	ra,0x2
    4088:	df4080e7          	jalr	-524(ra) # 5e78 <exit>
    printf("%s: chdir dots failed\n", s);
    408c:	85a6                	mv	a1,s1
    408e:	00004517          	auipc	a0,0x4
    4092:	c3250513          	addi	a0,a0,-974 # 7cc0 <malloc+0x1a16>
    4096:	00002097          	auipc	ra,0x2
    409a:	158080e7          	jalr	344(ra) # 61ee <printf>
    exit(1);
    409e:	4505                	li	a0,1
    40a0:	00002097          	auipc	ra,0x2
    40a4:	dd8080e7          	jalr	-552(ra) # 5e78 <exit>
    printf("%s: rm . worked!\n", s);
    40a8:	85a6                	mv	a1,s1
    40aa:	00004517          	auipc	a0,0x4
    40ae:	c2e50513          	addi	a0,a0,-978 # 7cd8 <malloc+0x1a2e>
    40b2:	00002097          	auipc	ra,0x2
    40b6:	13c080e7          	jalr	316(ra) # 61ee <printf>
    exit(1);
    40ba:	4505                	li	a0,1
    40bc:	00002097          	auipc	ra,0x2
    40c0:	dbc080e7          	jalr	-580(ra) # 5e78 <exit>
    printf("%s: rm .. worked!\n", s);
    40c4:	85a6                	mv	a1,s1
    40c6:	00004517          	auipc	a0,0x4
    40ca:	c2a50513          	addi	a0,a0,-982 # 7cf0 <malloc+0x1a46>
    40ce:	00002097          	auipc	ra,0x2
    40d2:	120080e7          	jalr	288(ra) # 61ee <printf>
    exit(1);
    40d6:	4505                	li	a0,1
    40d8:	00002097          	auipc	ra,0x2
    40dc:	da0080e7          	jalr	-608(ra) # 5e78 <exit>
    printf("%s: chdir / failed\n", s);
    40e0:	85a6                	mv	a1,s1
    40e2:	00003517          	auipc	a0,0x3
    40e6:	5c650513          	addi	a0,a0,1478 # 76a8 <malloc+0x13fe>
    40ea:	00002097          	auipc	ra,0x2
    40ee:	104080e7          	jalr	260(ra) # 61ee <printf>
    exit(1);
    40f2:	4505                	li	a0,1
    40f4:	00002097          	auipc	ra,0x2
    40f8:	d84080e7          	jalr	-636(ra) # 5e78 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    40fc:	85a6                	mv	a1,s1
    40fe:	00004517          	auipc	a0,0x4
    4102:	c1250513          	addi	a0,a0,-1006 # 7d10 <malloc+0x1a66>
    4106:	00002097          	auipc	ra,0x2
    410a:	0e8080e7          	jalr	232(ra) # 61ee <printf>
    exit(1);
    410e:	4505                	li	a0,1
    4110:	00002097          	auipc	ra,0x2
    4114:	d68080e7          	jalr	-664(ra) # 5e78 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    4118:	85a6                	mv	a1,s1
    411a:	00004517          	auipc	a0,0x4
    411e:	c1e50513          	addi	a0,a0,-994 # 7d38 <malloc+0x1a8e>
    4122:	00002097          	auipc	ra,0x2
    4126:	0cc080e7          	jalr	204(ra) # 61ee <printf>
    exit(1);
    412a:	4505                	li	a0,1
    412c:	00002097          	auipc	ra,0x2
    4130:	d4c080e7          	jalr	-692(ra) # 5e78 <exit>
    printf("%s: unlink dots failed!\n", s);
    4134:	85a6                	mv	a1,s1
    4136:	00004517          	auipc	a0,0x4
    413a:	c2250513          	addi	a0,a0,-990 # 7d58 <malloc+0x1aae>
    413e:	00002097          	auipc	ra,0x2
    4142:	0b0080e7          	jalr	176(ra) # 61ee <printf>
    exit(1);
    4146:	4505                	li	a0,1
    4148:	00002097          	auipc	ra,0x2
    414c:	d30080e7          	jalr	-720(ra) # 5e78 <exit>

0000000000004150 <dirfile>:
{
    4150:	1101                	addi	sp,sp,-32
    4152:	ec06                	sd	ra,24(sp)
    4154:	e822                	sd	s0,16(sp)
    4156:	e426                	sd	s1,8(sp)
    4158:	e04a                	sd	s2,0(sp)
    415a:	1000                	addi	s0,sp,32
    415c:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    415e:	20000593          	li	a1,512
    4162:	00004517          	auipc	a0,0x4
    4166:	c1650513          	addi	a0,a0,-1002 # 7d78 <malloc+0x1ace>
    416a:	00002097          	auipc	ra,0x2
    416e:	d4e080e7          	jalr	-690(ra) # 5eb8 <open>
  if(fd < 0){
    4172:	0e054d63          	bltz	a0,426c <dirfile+0x11c>
  close(fd);
    4176:	00002097          	auipc	ra,0x2
    417a:	d2a080e7          	jalr	-726(ra) # 5ea0 <close>
  if(chdir("dirfile") == 0){
    417e:	00004517          	auipc	a0,0x4
    4182:	bfa50513          	addi	a0,a0,-1030 # 7d78 <malloc+0x1ace>
    4186:	00002097          	auipc	ra,0x2
    418a:	d62080e7          	jalr	-670(ra) # 5ee8 <chdir>
    418e:	cd6d                	beqz	a0,4288 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4190:	4581                	li	a1,0
    4192:	00004517          	auipc	a0,0x4
    4196:	c2e50513          	addi	a0,a0,-978 # 7dc0 <malloc+0x1b16>
    419a:	00002097          	auipc	ra,0x2
    419e:	d1e080e7          	jalr	-738(ra) # 5eb8 <open>
  if(fd >= 0){
    41a2:	10055163          	bgez	a0,42a4 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    41a6:	20000593          	li	a1,512
    41aa:	00004517          	auipc	a0,0x4
    41ae:	c1650513          	addi	a0,a0,-1002 # 7dc0 <malloc+0x1b16>
    41b2:	00002097          	auipc	ra,0x2
    41b6:	d06080e7          	jalr	-762(ra) # 5eb8 <open>
  if(fd >= 0){
    41ba:	10055363          	bgez	a0,42c0 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    41be:	00004517          	auipc	a0,0x4
    41c2:	c0250513          	addi	a0,a0,-1022 # 7dc0 <malloc+0x1b16>
    41c6:	00002097          	auipc	ra,0x2
    41ca:	d1a080e7          	jalr	-742(ra) # 5ee0 <mkdir>
    41ce:	10050763          	beqz	a0,42dc <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    41d2:	00004517          	auipc	a0,0x4
    41d6:	bee50513          	addi	a0,a0,-1042 # 7dc0 <malloc+0x1b16>
    41da:	00002097          	auipc	ra,0x2
    41de:	cee080e7          	jalr	-786(ra) # 5ec8 <unlink>
    41e2:	10050b63          	beqz	a0,42f8 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    41e6:	00004597          	auipc	a1,0x4
    41ea:	bda58593          	addi	a1,a1,-1062 # 7dc0 <malloc+0x1b16>
    41ee:	00002517          	auipc	a0,0x2
    41f2:	3d250513          	addi	a0,a0,978 # 65c0 <malloc+0x316>
    41f6:	00002097          	auipc	ra,0x2
    41fa:	ce2080e7          	jalr	-798(ra) # 5ed8 <link>
    41fe:	10050b63          	beqz	a0,4314 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    4202:	00004517          	auipc	a0,0x4
    4206:	b7650513          	addi	a0,a0,-1162 # 7d78 <malloc+0x1ace>
    420a:	00002097          	auipc	ra,0x2
    420e:	cbe080e7          	jalr	-834(ra) # 5ec8 <unlink>
    4212:	10051f63          	bnez	a0,4330 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    4216:	4589                	li	a1,2
    4218:	00003517          	auipc	a0,0x3
    421c:	8b850513          	addi	a0,a0,-1864 # 6ad0 <malloc+0x826>
    4220:	00002097          	auipc	ra,0x2
    4224:	c98080e7          	jalr	-872(ra) # 5eb8 <open>
  if(fd >= 0){
    4228:	12055263          	bgez	a0,434c <dirfile+0x1fc>
  fd = open(".", 0);
    422c:	4581                	li	a1,0
    422e:	00003517          	auipc	a0,0x3
    4232:	8a250513          	addi	a0,a0,-1886 # 6ad0 <malloc+0x826>
    4236:	00002097          	auipc	ra,0x2
    423a:	c82080e7          	jalr	-894(ra) # 5eb8 <open>
    423e:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    4240:	4605                	li	a2,1
    4242:	00002597          	auipc	a1,0x2
    4246:	21658593          	addi	a1,a1,534 # 6458 <malloc+0x1ae>
    424a:	00002097          	auipc	ra,0x2
    424e:	c4e080e7          	jalr	-946(ra) # 5e98 <write>
    4252:	10a04b63          	bgtz	a0,4368 <dirfile+0x218>
  close(fd);
    4256:	8526                	mv	a0,s1
    4258:	00002097          	auipc	ra,0x2
    425c:	c48080e7          	jalr	-952(ra) # 5ea0 <close>
}
    4260:	60e2                	ld	ra,24(sp)
    4262:	6442                	ld	s0,16(sp)
    4264:	64a2                	ld	s1,8(sp)
    4266:	6902                	ld	s2,0(sp)
    4268:	6105                	addi	sp,sp,32
    426a:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    426c:	85ca                	mv	a1,s2
    426e:	00004517          	auipc	a0,0x4
    4272:	b1250513          	addi	a0,a0,-1262 # 7d80 <malloc+0x1ad6>
    4276:	00002097          	auipc	ra,0x2
    427a:	f78080e7          	jalr	-136(ra) # 61ee <printf>
    exit(1);
    427e:	4505                	li	a0,1
    4280:	00002097          	auipc	ra,0x2
    4284:	bf8080e7          	jalr	-1032(ra) # 5e78 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    4288:	85ca                	mv	a1,s2
    428a:	00004517          	auipc	a0,0x4
    428e:	b1650513          	addi	a0,a0,-1258 # 7da0 <malloc+0x1af6>
    4292:	00002097          	auipc	ra,0x2
    4296:	f5c080e7          	jalr	-164(ra) # 61ee <printf>
    exit(1);
    429a:	4505                	li	a0,1
    429c:	00002097          	auipc	ra,0x2
    42a0:	bdc080e7          	jalr	-1060(ra) # 5e78 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    42a4:	85ca                	mv	a1,s2
    42a6:	00004517          	auipc	a0,0x4
    42aa:	b2a50513          	addi	a0,a0,-1238 # 7dd0 <malloc+0x1b26>
    42ae:	00002097          	auipc	ra,0x2
    42b2:	f40080e7          	jalr	-192(ra) # 61ee <printf>
    exit(1);
    42b6:	4505                	li	a0,1
    42b8:	00002097          	auipc	ra,0x2
    42bc:	bc0080e7          	jalr	-1088(ra) # 5e78 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    42c0:	85ca                	mv	a1,s2
    42c2:	00004517          	auipc	a0,0x4
    42c6:	b0e50513          	addi	a0,a0,-1266 # 7dd0 <malloc+0x1b26>
    42ca:	00002097          	auipc	ra,0x2
    42ce:	f24080e7          	jalr	-220(ra) # 61ee <printf>
    exit(1);
    42d2:	4505                	li	a0,1
    42d4:	00002097          	auipc	ra,0x2
    42d8:	ba4080e7          	jalr	-1116(ra) # 5e78 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    42dc:	85ca                	mv	a1,s2
    42de:	00004517          	auipc	a0,0x4
    42e2:	b1a50513          	addi	a0,a0,-1254 # 7df8 <malloc+0x1b4e>
    42e6:	00002097          	auipc	ra,0x2
    42ea:	f08080e7          	jalr	-248(ra) # 61ee <printf>
    exit(1);
    42ee:	4505                	li	a0,1
    42f0:	00002097          	auipc	ra,0x2
    42f4:	b88080e7          	jalr	-1144(ra) # 5e78 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    42f8:	85ca                	mv	a1,s2
    42fa:	00004517          	auipc	a0,0x4
    42fe:	b2650513          	addi	a0,a0,-1242 # 7e20 <malloc+0x1b76>
    4302:	00002097          	auipc	ra,0x2
    4306:	eec080e7          	jalr	-276(ra) # 61ee <printf>
    exit(1);
    430a:	4505                	li	a0,1
    430c:	00002097          	auipc	ra,0x2
    4310:	b6c080e7          	jalr	-1172(ra) # 5e78 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    4314:	85ca                	mv	a1,s2
    4316:	00004517          	auipc	a0,0x4
    431a:	b3250513          	addi	a0,a0,-1230 # 7e48 <malloc+0x1b9e>
    431e:	00002097          	auipc	ra,0x2
    4322:	ed0080e7          	jalr	-304(ra) # 61ee <printf>
    exit(1);
    4326:	4505                	li	a0,1
    4328:	00002097          	auipc	ra,0x2
    432c:	b50080e7          	jalr	-1200(ra) # 5e78 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    4330:	85ca                	mv	a1,s2
    4332:	00004517          	auipc	a0,0x4
    4336:	b3e50513          	addi	a0,a0,-1218 # 7e70 <malloc+0x1bc6>
    433a:	00002097          	auipc	ra,0x2
    433e:	eb4080e7          	jalr	-332(ra) # 61ee <printf>
    exit(1);
    4342:	4505                	li	a0,1
    4344:	00002097          	auipc	ra,0x2
    4348:	b34080e7          	jalr	-1228(ra) # 5e78 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    434c:	85ca                	mv	a1,s2
    434e:	00004517          	auipc	a0,0x4
    4352:	b4250513          	addi	a0,a0,-1214 # 7e90 <malloc+0x1be6>
    4356:	00002097          	auipc	ra,0x2
    435a:	e98080e7          	jalr	-360(ra) # 61ee <printf>
    exit(1);
    435e:	4505                	li	a0,1
    4360:	00002097          	auipc	ra,0x2
    4364:	b18080e7          	jalr	-1256(ra) # 5e78 <exit>
    printf("%s: write . succeeded!\n", s);
    4368:	85ca                	mv	a1,s2
    436a:	00004517          	auipc	a0,0x4
    436e:	b4e50513          	addi	a0,a0,-1202 # 7eb8 <malloc+0x1c0e>
    4372:	00002097          	auipc	ra,0x2
    4376:	e7c080e7          	jalr	-388(ra) # 61ee <printf>
    exit(1);
    437a:	4505                	li	a0,1
    437c:	00002097          	auipc	ra,0x2
    4380:	afc080e7          	jalr	-1284(ra) # 5e78 <exit>

0000000000004384 <iref>:
{
    4384:	715d                	addi	sp,sp,-80
    4386:	e486                	sd	ra,72(sp)
    4388:	e0a2                	sd	s0,64(sp)
    438a:	fc26                	sd	s1,56(sp)
    438c:	f84a                	sd	s2,48(sp)
    438e:	f44e                	sd	s3,40(sp)
    4390:	f052                	sd	s4,32(sp)
    4392:	ec56                	sd	s5,24(sp)
    4394:	e85a                	sd	s6,16(sp)
    4396:	e45e                	sd	s7,8(sp)
    4398:	0880                	addi	s0,sp,80
    439a:	8baa                	mv	s7,a0
    439c:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    43a0:	00004a97          	auipc	s5,0x4
    43a4:	b30a8a93          	addi	s5,s5,-1232 # 7ed0 <malloc+0x1c26>
    mkdir("");
    43a8:	00003497          	auipc	s1,0x3
    43ac:	63048493          	addi	s1,s1,1584 # 79d8 <malloc+0x172e>
    link("README", "");
    43b0:	00002b17          	auipc	s6,0x2
    43b4:	210b0b13          	addi	s6,s6,528 # 65c0 <malloc+0x316>
    fd = open("", O_CREATE);
    43b8:	20000a13          	li	s4,512
    fd = open("xx", O_CREATE);
    43bc:	00004997          	auipc	s3,0x4
    43c0:	a0c98993          	addi	s3,s3,-1524 # 7dc8 <malloc+0x1b1e>
    43c4:	a891                	j	4418 <iref+0x94>
      printf("%s: mkdir irefd failed\n", s);
    43c6:	85de                	mv	a1,s7
    43c8:	00004517          	auipc	a0,0x4
    43cc:	b1050513          	addi	a0,a0,-1264 # 7ed8 <malloc+0x1c2e>
    43d0:	00002097          	auipc	ra,0x2
    43d4:	e1e080e7          	jalr	-482(ra) # 61ee <printf>
      exit(1);
    43d8:	4505                	li	a0,1
    43da:	00002097          	auipc	ra,0x2
    43de:	a9e080e7          	jalr	-1378(ra) # 5e78 <exit>
      printf("%s: chdir irefd failed\n", s);
    43e2:	85de                	mv	a1,s7
    43e4:	00004517          	auipc	a0,0x4
    43e8:	b0c50513          	addi	a0,a0,-1268 # 7ef0 <malloc+0x1c46>
    43ec:	00002097          	auipc	ra,0x2
    43f0:	e02080e7          	jalr	-510(ra) # 61ee <printf>
      exit(1);
    43f4:	4505                	li	a0,1
    43f6:	00002097          	auipc	ra,0x2
    43fa:	a82080e7          	jalr	-1406(ra) # 5e78 <exit>
      close(fd);
    43fe:	00002097          	auipc	ra,0x2
    4402:	aa2080e7          	jalr	-1374(ra) # 5ea0 <close>
    4406:	a881                	j	4456 <iref+0xd2>
    unlink("xx");
    4408:	854e                	mv	a0,s3
    440a:	00002097          	auipc	ra,0x2
    440e:	abe080e7          	jalr	-1346(ra) # 5ec8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4412:	397d                	addiw	s2,s2,-1
    4414:	04090e63          	beqz	s2,4470 <iref+0xec>
    if(mkdir("irefd") != 0){
    4418:	8556                	mv	a0,s5
    441a:	00002097          	auipc	ra,0x2
    441e:	ac6080e7          	jalr	-1338(ra) # 5ee0 <mkdir>
    4422:	f155                	bnez	a0,43c6 <iref+0x42>
    if(chdir("irefd") != 0){
    4424:	8556                	mv	a0,s5
    4426:	00002097          	auipc	ra,0x2
    442a:	ac2080e7          	jalr	-1342(ra) # 5ee8 <chdir>
    442e:	f955                	bnez	a0,43e2 <iref+0x5e>
    mkdir("");
    4430:	8526                	mv	a0,s1
    4432:	00002097          	auipc	ra,0x2
    4436:	aae080e7          	jalr	-1362(ra) # 5ee0 <mkdir>
    link("README", "");
    443a:	85a6                	mv	a1,s1
    443c:	855a                	mv	a0,s6
    443e:	00002097          	auipc	ra,0x2
    4442:	a9a080e7          	jalr	-1382(ra) # 5ed8 <link>
    fd = open("", O_CREATE);
    4446:	85d2                	mv	a1,s4
    4448:	8526                	mv	a0,s1
    444a:	00002097          	auipc	ra,0x2
    444e:	a6e080e7          	jalr	-1426(ra) # 5eb8 <open>
    if(fd >= 0)
    4452:	fa0556e3          	bgez	a0,43fe <iref+0x7a>
    fd = open("xx", O_CREATE);
    4456:	85d2                	mv	a1,s4
    4458:	854e                	mv	a0,s3
    445a:	00002097          	auipc	ra,0x2
    445e:	a5e080e7          	jalr	-1442(ra) # 5eb8 <open>
    if(fd >= 0)
    4462:	fa0543e3          	bltz	a0,4408 <iref+0x84>
      close(fd);
    4466:	00002097          	auipc	ra,0x2
    446a:	a3a080e7          	jalr	-1478(ra) # 5ea0 <close>
    446e:	bf69                	j	4408 <iref+0x84>
    4470:	03300493          	li	s1,51
    chdir("..");
    4474:	00003997          	auipc	s3,0x3
    4478:	28498993          	addi	s3,s3,644 # 76f8 <malloc+0x144e>
    unlink("irefd");
    447c:	00004917          	auipc	s2,0x4
    4480:	a5490913          	addi	s2,s2,-1452 # 7ed0 <malloc+0x1c26>
    chdir("..");
    4484:	854e                	mv	a0,s3
    4486:	00002097          	auipc	ra,0x2
    448a:	a62080e7          	jalr	-1438(ra) # 5ee8 <chdir>
    unlink("irefd");
    448e:	854a                	mv	a0,s2
    4490:	00002097          	auipc	ra,0x2
    4494:	a38080e7          	jalr	-1480(ra) # 5ec8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4498:	34fd                	addiw	s1,s1,-1
    449a:	f4ed                	bnez	s1,4484 <iref+0x100>
  chdir("/");
    449c:	00003517          	auipc	a0,0x3
    44a0:	20450513          	addi	a0,a0,516 # 76a0 <malloc+0x13f6>
    44a4:	00002097          	auipc	ra,0x2
    44a8:	a44080e7          	jalr	-1468(ra) # 5ee8 <chdir>
}
    44ac:	60a6                	ld	ra,72(sp)
    44ae:	6406                	ld	s0,64(sp)
    44b0:	74e2                	ld	s1,56(sp)
    44b2:	7942                	ld	s2,48(sp)
    44b4:	79a2                	ld	s3,40(sp)
    44b6:	7a02                	ld	s4,32(sp)
    44b8:	6ae2                	ld	s5,24(sp)
    44ba:	6b42                	ld	s6,16(sp)
    44bc:	6ba2                	ld	s7,8(sp)
    44be:	6161                	addi	sp,sp,80
    44c0:	8082                	ret

00000000000044c2 <openiputtest>:
{
    44c2:	7179                	addi	sp,sp,-48
    44c4:	f406                	sd	ra,40(sp)
    44c6:	f022                	sd	s0,32(sp)
    44c8:	ec26                	sd	s1,24(sp)
    44ca:	1800                	addi	s0,sp,48
    44cc:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    44ce:	00004517          	auipc	a0,0x4
    44d2:	a3a50513          	addi	a0,a0,-1478 # 7f08 <malloc+0x1c5e>
    44d6:	00002097          	auipc	ra,0x2
    44da:	a0a080e7          	jalr	-1526(ra) # 5ee0 <mkdir>
    44de:	04054263          	bltz	a0,4522 <openiputtest+0x60>
  pid = fork();
    44e2:	00002097          	auipc	ra,0x2
    44e6:	98e080e7          	jalr	-1650(ra) # 5e70 <fork>
  if(pid < 0){
    44ea:	04054a63          	bltz	a0,453e <openiputtest+0x7c>
  if(pid == 0){
    44ee:	e93d                	bnez	a0,4564 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    44f0:	4589                	li	a1,2
    44f2:	00004517          	auipc	a0,0x4
    44f6:	a1650513          	addi	a0,a0,-1514 # 7f08 <malloc+0x1c5e>
    44fa:	00002097          	auipc	ra,0x2
    44fe:	9be080e7          	jalr	-1602(ra) # 5eb8 <open>
    if(fd >= 0){
    4502:	04054c63          	bltz	a0,455a <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    4506:	85a6                	mv	a1,s1
    4508:	00004517          	auipc	a0,0x4
    450c:	a2050513          	addi	a0,a0,-1504 # 7f28 <malloc+0x1c7e>
    4510:	00002097          	auipc	ra,0x2
    4514:	cde080e7          	jalr	-802(ra) # 61ee <printf>
      exit(1);
    4518:	4505                	li	a0,1
    451a:	00002097          	auipc	ra,0x2
    451e:	95e080e7          	jalr	-1698(ra) # 5e78 <exit>
    printf("%s: mkdir oidir failed\n", s);
    4522:	85a6                	mv	a1,s1
    4524:	00004517          	auipc	a0,0x4
    4528:	9ec50513          	addi	a0,a0,-1556 # 7f10 <malloc+0x1c66>
    452c:	00002097          	auipc	ra,0x2
    4530:	cc2080e7          	jalr	-830(ra) # 61ee <printf>
    exit(1);
    4534:	4505                	li	a0,1
    4536:	00002097          	auipc	ra,0x2
    453a:	942080e7          	jalr	-1726(ra) # 5e78 <exit>
    printf("%s: fork failed\n", s);
    453e:	85a6                	mv	a1,s1
    4540:	00002517          	auipc	a0,0x2
    4544:	73050513          	addi	a0,a0,1840 # 6c70 <malloc+0x9c6>
    4548:	00002097          	auipc	ra,0x2
    454c:	ca6080e7          	jalr	-858(ra) # 61ee <printf>
    exit(1);
    4550:	4505                	li	a0,1
    4552:	00002097          	auipc	ra,0x2
    4556:	926080e7          	jalr	-1754(ra) # 5e78 <exit>
    exit(0);
    455a:	4501                	li	a0,0
    455c:	00002097          	auipc	ra,0x2
    4560:	91c080e7          	jalr	-1764(ra) # 5e78 <exit>
  sleep(1);
    4564:	4505                	li	a0,1
    4566:	00002097          	auipc	ra,0x2
    456a:	9a2080e7          	jalr	-1630(ra) # 5f08 <sleep>
  if(unlink("oidir") != 0){
    456e:	00004517          	auipc	a0,0x4
    4572:	99a50513          	addi	a0,a0,-1638 # 7f08 <malloc+0x1c5e>
    4576:	00002097          	auipc	ra,0x2
    457a:	952080e7          	jalr	-1710(ra) # 5ec8 <unlink>
    457e:	cd19                	beqz	a0,459c <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    4580:	85a6                	mv	a1,s1
    4582:	00003517          	auipc	a0,0x3
    4586:	8de50513          	addi	a0,a0,-1826 # 6e60 <malloc+0xbb6>
    458a:	00002097          	auipc	ra,0x2
    458e:	c64080e7          	jalr	-924(ra) # 61ee <printf>
    exit(1);
    4592:	4505                	li	a0,1
    4594:	00002097          	auipc	ra,0x2
    4598:	8e4080e7          	jalr	-1820(ra) # 5e78 <exit>
  wait(&xstatus);
    459c:	fdc40513          	addi	a0,s0,-36
    45a0:	00002097          	auipc	ra,0x2
    45a4:	8e0080e7          	jalr	-1824(ra) # 5e80 <wait>
  exit(xstatus);
    45a8:	fdc42503          	lw	a0,-36(s0)
    45ac:	00002097          	auipc	ra,0x2
    45b0:	8cc080e7          	jalr	-1844(ra) # 5e78 <exit>

00000000000045b4 <forkforkfork>:
{
    45b4:	1101                	addi	sp,sp,-32
    45b6:	ec06                	sd	ra,24(sp)
    45b8:	e822                	sd	s0,16(sp)
    45ba:	e426                	sd	s1,8(sp)
    45bc:	1000                	addi	s0,sp,32
    45be:	84aa                	mv	s1,a0
  unlink("stopforking");
    45c0:	00004517          	auipc	a0,0x4
    45c4:	99050513          	addi	a0,a0,-1648 # 7f50 <malloc+0x1ca6>
    45c8:	00002097          	auipc	ra,0x2
    45cc:	900080e7          	jalr	-1792(ra) # 5ec8 <unlink>
  int pid = fork();
    45d0:	00002097          	auipc	ra,0x2
    45d4:	8a0080e7          	jalr	-1888(ra) # 5e70 <fork>
  if(pid < 0){
    45d8:	04054563          	bltz	a0,4622 <forkforkfork+0x6e>
  if(pid == 0){
    45dc:	c12d                	beqz	a0,463e <forkforkfork+0x8a>
  sleep(20); // two seconds
    45de:	4551                	li	a0,20
    45e0:	00002097          	auipc	ra,0x2
    45e4:	928080e7          	jalr	-1752(ra) # 5f08 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    45e8:	20200593          	li	a1,514
    45ec:	00004517          	auipc	a0,0x4
    45f0:	96450513          	addi	a0,a0,-1692 # 7f50 <malloc+0x1ca6>
    45f4:	00002097          	auipc	ra,0x2
    45f8:	8c4080e7          	jalr	-1852(ra) # 5eb8 <open>
    45fc:	00002097          	auipc	ra,0x2
    4600:	8a4080e7          	jalr	-1884(ra) # 5ea0 <close>
  wait(0);
    4604:	4501                	li	a0,0
    4606:	00002097          	auipc	ra,0x2
    460a:	87a080e7          	jalr	-1926(ra) # 5e80 <wait>
  sleep(10); // one second
    460e:	4529                	li	a0,10
    4610:	00002097          	auipc	ra,0x2
    4614:	8f8080e7          	jalr	-1800(ra) # 5f08 <sleep>
}
    4618:	60e2                	ld	ra,24(sp)
    461a:	6442                	ld	s0,16(sp)
    461c:	64a2                	ld	s1,8(sp)
    461e:	6105                	addi	sp,sp,32
    4620:	8082                	ret
    printf("%s: fork failed", s);
    4622:	85a6                	mv	a1,s1
    4624:	00003517          	auipc	a0,0x3
    4628:	80c50513          	addi	a0,a0,-2036 # 6e30 <malloc+0xb86>
    462c:	00002097          	auipc	ra,0x2
    4630:	bc2080e7          	jalr	-1086(ra) # 61ee <printf>
    exit(1);
    4634:	4505                	li	a0,1
    4636:	00002097          	auipc	ra,0x2
    463a:	842080e7          	jalr	-1982(ra) # 5e78 <exit>
      int fd = open("stopforking", 0);
    463e:	00004497          	auipc	s1,0x4
    4642:	91248493          	addi	s1,s1,-1774 # 7f50 <malloc+0x1ca6>
    4646:	4581                	li	a1,0
    4648:	8526                	mv	a0,s1
    464a:	00002097          	auipc	ra,0x2
    464e:	86e080e7          	jalr	-1938(ra) # 5eb8 <open>
      if(fd >= 0){
    4652:	02055763          	bgez	a0,4680 <forkforkfork+0xcc>
      if(fork() < 0){
    4656:	00002097          	auipc	ra,0x2
    465a:	81a080e7          	jalr	-2022(ra) # 5e70 <fork>
    465e:	fe0554e3          	bgez	a0,4646 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    4662:	20200593          	li	a1,514
    4666:	00004517          	auipc	a0,0x4
    466a:	8ea50513          	addi	a0,a0,-1814 # 7f50 <malloc+0x1ca6>
    466e:	00002097          	auipc	ra,0x2
    4672:	84a080e7          	jalr	-1974(ra) # 5eb8 <open>
    4676:	00002097          	auipc	ra,0x2
    467a:	82a080e7          	jalr	-2006(ra) # 5ea0 <close>
    467e:	b7e1                	j	4646 <forkforkfork+0x92>
        exit(0);
    4680:	4501                	li	a0,0
    4682:	00001097          	auipc	ra,0x1
    4686:	7f6080e7          	jalr	2038(ra) # 5e78 <exit>

000000000000468a <killstatus>:
{
    468a:	715d                	addi	sp,sp,-80
    468c:	e486                	sd	ra,72(sp)
    468e:	e0a2                	sd	s0,64(sp)
    4690:	fc26                	sd	s1,56(sp)
    4692:	f84a                	sd	s2,48(sp)
    4694:	f44e                	sd	s3,40(sp)
    4696:	f052                	sd	s4,32(sp)
    4698:	ec56                	sd	s5,24(sp)
    469a:	e85a                	sd	s6,16(sp)
    469c:	0880                	addi	s0,sp,80
    469e:	8b2a                	mv	s6,a0
    46a0:	06400913          	li	s2,100
    sleep(1);
    46a4:	4a85                	li	s5,1
    wait(&xst);
    46a6:	fbc40a13          	addi	s4,s0,-68
    if(xst != -1) {
    46aa:	59fd                	li	s3,-1
    int pid1 = fork();
    46ac:	00001097          	auipc	ra,0x1
    46b0:	7c4080e7          	jalr	1988(ra) # 5e70 <fork>
    46b4:	84aa                	mv	s1,a0
    if(pid1 < 0){
    46b6:	02054e63          	bltz	a0,46f2 <killstatus+0x68>
    if(pid1 == 0){
    46ba:	c931                	beqz	a0,470e <killstatus+0x84>
    sleep(1);
    46bc:	8556                	mv	a0,s5
    46be:	00002097          	auipc	ra,0x2
    46c2:	84a080e7          	jalr	-1974(ra) # 5f08 <sleep>
    kill(pid1);
    46c6:	8526                	mv	a0,s1
    46c8:	00001097          	auipc	ra,0x1
    46cc:	7e0080e7          	jalr	2016(ra) # 5ea8 <kill>
    wait(&xst);
    46d0:	8552                	mv	a0,s4
    46d2:	00001097          	auipc	ra,0x1
    46d6:	7ae080e7          	jalr	1966(ra) # 5e80 <wait>
    if(xst != -1) {
    46da:	fbc42783          	lw	a5,-68(s0)
    46de:	03379d63          	bne	a5,s3,4718 <killstatus+0x8e>
  for(int i = 0; i < 100; i++){
    46e2:	397d                	addiw	s2,s2,-1
    46e4:	fc0914e3          	bnez	s2,46ac <killstatus+0x22>
  exit(0);
    46e8:	4501                	li	a0,0
    46ea:	00001097          	auipc	ra,0x1
    46ee:	78e080e7          	jalr	1934(ra) # 5e78 <exit>
      printf("%s: fork failed\n", s);
    46f2:	85da                	mv	a1,s6
    46f4:	00002517          	auipc	a0,0x2
    46f8:	57c50513          	addi	a0,a0,1404 # 6c70 <malloc+0x9c6>
    46fc:	00002097          	auipc	ra,0x2
    4700:	af2080e7          	jalr	-1294(ra) # 61ee <printf>
      exit(1);
    4704:	4505                	li	a0,1
    4706:	00001097          	auipc	ra,0x1
    470a:	772080e7          	jalr	1906(ra) # 5e78 <exit>
        getpid();
    470e:	00001097          	auipc	ra,0x1
    4712:	7ea080e7          	jalr	2026(ra) # 5ef8 <getpid>
      while(1) {
    4716:	bfe5                	j	470e <killstatus+0x84>
       printf("%s: status should be -1\n", s);
    4718:	85da                	mv	a1,s6
    471a:	00004517          	auipc	a0,0x4
    471e:	84650513          	addi	a0,a0,-1978 # 7f60 <malloc+0x1cb6>
    4722:	00002097          	auipc	ra,0x2
    4726:	acc080e7          	jalr	-1332(ra) # 61ee <printf>
       exit(1);
    472a:	4505                	li	a0,1
    472c:	00001097          	auipc	ra,0x1
    4730:	74c080e7          	jalr	1868(ra) # 5e78 <exit>

0000000000004734 <preempt>:
{
    4734:	7139                	addi	sp,sp,-64
    4736:	fc06                	sd	ra,56(sp)
    4738:	f822                	sd	s0,48(sp)
    473a:	f426                	sd	s1,40(sp)
    473c:	f04a                	sd	s2,32(sp)
    473e:	ec4e                	sd	s3,24(sp)
    4740:	e852                	sd	s4,16(sp)
    4742:	0080                	addi	s0,sp,64
    4744:	892a                	mv	s2,a0
  pid1 = fork();
    4746:	00001097          	auipc	ra,0x1
    474a:	72a080e7          	jalr	1834(ra) # 5e70 <fork>
  if(pid1 < 0) {
    474e:	00054563          	bltz	a0,4758 <preempt+0x24>
    4752:	84aa                	mv	s1,a0
  if(pid1 == 0)
    4754:	e105                	bnez	a0,4774 <preempt+0x40>
    for(;;)
    4756:	a001                	j	4756 <preempt+0x22>
    printf("%s: fork failed", s);
    4758:	85ca                	mv	a1,s2
    475a:	00002517          	auipc	a0,0x2
    475e:	6d650513          	addi	a0,a0,1750 # 6e30 <malloc+0xb86>
    4762:	00002097          	auipc	ra,0x2
    4766:	a8c080e7          	jalr	-1396(ra) # 61ee <printf>
    exit(1);
    476a:	4505                	li	a0,1
    476c:	00001097          	auipc	ra,0x1
    4770:	70c080e7          	jalr	1804(ra) # 5e78 <exit>
  pid2 = fork();
    4774:	00001097          	auipc	ra,0x1
    4778:	6fc080e7          	jalr	1788(ra) # 5e70 <fork>
    477c:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    477e:	00054463          	bltz	a0,4786 <preempt+0x52>
  if(pid2 == 0)
    4782:	e105                	bnez	a0,47a2 <preempt+0x6e>
    for(;;)
    4784:	a001                	j	4784 <preempt+0x50>
    printf("%s: fork failed\n", s);
    4786:	85ca                	mv	a1,s2
    4788:	00002517          	auipc	a0,0x2
    478c:	4e850513          	addi	a0,a0,1256 # 6c70 <malloc+0x9c6>
    4790:	00002097          	auipc	ra,0x2
    4794:	a5e080e7          	jalr	-1442(ra) # 61ee <printf>
    exit(1);
    4798:	4505                	li	a0,1
    479a:	00001097          	auipc	ra,0x1
    479e:	6de080e7          	jalr	1758(ra) # 5e78 <exit>
  pipe(pfds);
    47a2:	fc840513          	addi	a0,s0,-56
    47a6:	00001097          	auipc	ra,0x1
    47aa:	6e2080e7          	jalr	1762(ra) # 5e88 <pipe>
  pid3 = fork();
    47ae:	00001097          	auipc	ra,0x1
    47b2:	6c2080e7          	jalr	1730(ra) # 5e70 <fork>
    47b6:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    47b8:	02054e63          	bltz	a0,47f4 <preempt+0xc0>
  if(pid3 == 0){
    47bc:	e525                	bnez	a0,4824 <preempt+0xf0>
    close(pfds[0]);
    47be:	fc842503          	lw	a0,-56(s0)
    47c2:	00001097          	auipc	ra,0x1
    47c6:	6de080e7          	jalr	1758(ra) # 5ea0 <close>
    if(write(pfds[1], "x", 1) != 1)
    47ca:	4605                	li	a2,1
    47cc:	00002597          	auipc	a1,0x2
    47d0:	c8c58593          	addi	a1,a1,-884 # 6458 <malloc+0x1ae>
    47d4:	fcc42503          	lw	a0,-52(s0)
    47d8:	00001097          	auipc	ra,0x1
    47dc:	6c0080e7          	jalr	1728(ra) # 5e98 <write>
    47e0:	4785                	li	a5,1
    47e2:	02f51763          	bne	a0,a5,4810 <preempt+0xdc>
    close(pfds[1]);
    47e6:	fcc42503          	lw	a0,-52(s0)
    47ea:	00001097          	auipc	ra,0x1
    47ee:	6b6080e7          	jalr	1718(ra) # 5ea0 <close>
    for(;;)
    47f2:	a001                	j	47f2 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    47f4:	85ca                	mv	a1,s2
    47f6:	00002517          	auipc	a0,0x2
    47fa:	47a50513          	addi	a0,a0,1146 # 6c70 <malloc+0x9c6>
    47fe:	00002097          	auipc	ra,0x2
    4802:	9f0080e7          	jalr	-1552(ra) # 61ee <printf>
     exit(1);
    4806:	4505                	li	a0,1
    4808:	00001097          	auipc	ra,0x1
    480c:	670080e7          	jalr	1648(ra) # 5e78 <exit>
      printf("%s: preempt write error", s);
    4810:	85ca                	mv	a1,s2
    4812:	00003517          	auipc	a0,0x3
    4816:	76e50513          	addi	a0,a0,1902 # 7f80 <malloc+0x1cd6>
    481a:	00002097          	auipc	ra,0x2
    481e:	9d4080e7          	jalr	-1580(ra) # 61ee <printf>
    4822:	b7d1                	j	47e6 <preempt+0xb2>
  close(pfds[1]);
    4824:	fcc42503          	lw	a0,-52(s0)
    4828:	00001097          	auipc	ra,0x1
    482c:	678080e7          	jalr	1656(ra) # 5ea0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    4830:	660d                	lui	a2,0x3
    4832:	00008597          	auipc	a1,0x8
    4836:	44658593          	addi	a1,a1,1094 # cc78 <buf>
    483a:	fc842503          	lw	a0,-56(s0)
    483e:	00001097          	auipc	ra,0x1
    4842:	652080e7          	jalr	1618(ra) # 5e90 <read>
    4846:	4785                	li	a5,1
    4848:	02f50363          	beq	a0,a5,486e <preempt+0x13a>
    printf("%s: preempt read error", s);
    484c:	85ca                	mv	a1,s2
    484e:	00003517          	auipc	a0,0x3
    4852:	74a50513          	addi	a0,a0,1866 # 7f98 <malloc+0x1cee>
    4856:	00002097          	auipc	ra,0x2
    485a:	998080e7          	jalr	-1640(ra) # 61ee <printf>
}
    485e:	70e2                	ld	ra,56(sp)
    4860:	7442                	ld	s0,48(sp)
    4862:	74a2                	ld	s1,40(sp)
    4864:	7902                	ld	s2,32(sp)
    4866:	69e2                	ld	s3,24(sp)
    4868:	6a42                	ld	s4,16(sp)
    486a:	6121                	addi	sp,sp,64
    486c:	8082                	ret
  close(pfds[0]);
    486e:	fc842503          	lw	a0,-56(s0)
    4872:	00001097          	auipc	ra,0x1
    4876:	62e080e7          	jalr	1582(ra) # 5ea0 <close>
  printf("kill... ");
    487a:	00003517          	auipc	a0,0x3
    487e:	73650513          	addi	a0,a0,1846 # 7fb0 <malloc+0x1d06>
    4882:	00002097          	auipc	ra,0x2
    4886:	96c080e7          	jalr	-1684(ra) # 61ee <printf>
  kill(pid1);
    488a:	8526                	mv	a0,s1
    488c:	00001097          	auipc	ra,0x1
    4890:	61c080e7          	jalr	1564(ra) # 5ea8 <kill>
  kill(pid2);
    4894:	854e                	mv	a0,s3
    4896:	00001097          	auipc	ra,0x1
    489a:	612080e7          	jalr	1554(ra) # 5ea8 <kill>
  kill(pid3);
    489e:	8552                	mv	a0,s4
    48a0:	00001097          	auipc	ra,0x1
    48a4:	608080e7          	jalr	1544(ra) # 5ea8 <kill>
  printf("wait... ");
    48a8:	00003517          	auipc	a0,0x3
    48ac:	71850513          	addi	a0,a0,1816 # 7fc0 <malloc+0x1d16>
    48b0:	00002097          	auipc	ra,0x2
    48b4:	93e080e7          	jalr	-1730(ra) # 61ee <printf>
  wait(0);
    48b8:	4501                	li	a0,0
    48ba:	00001097          	auipc	ra,0x1
    48be:	5c6080e7          	jalr	1478(ra) # 5e80 <wait>
  wait(0);
    48c2:	4501                	li	a0,0
    48c4:	00001097          	auipc	ra,0x1
    48c8:	5bc080e7          	jalr	1468(ra) # 5e80 <wait>
  wait(0);
    48cc:	4501                	li	a0,0
    48ce:	00001097          	auipc	ra,0x1
    48d2:	5b2080e7          	jalr	1458(ra) # 5e80 <wait>
    48d6:	b761                	j	485e <preempt+0x12a>

00000000000048d8 <reparent>:
{
    48d8:	7179                	addi	sp,sp,-48
    48da:	f406                	sd	ra,40(sp)
    48dc:	f022                	sd	s0,32(sp)
    48de:	ec26                	sd	s1,24(sp)
    48e0:	e84a                	sd	s2,16(sp)
    48e2:	e44e                	sd	s3,8(sp)
    48e4:	e052                	sd	s4,0(sp)
    48e6:	1800                	addi	s0,sp,48
    48e8:	89aa                	mv	s3,a0
  int master_pid = getpid();
    48ea:	00001097          	auipc	ra,0x1
    48ee:	60e080e7          	jalr	1550(ra) # 5ef8 <getpid>
    48f2:	8a2a                	mv	s4,a0
    48f4:	0c800913          	li	s2,200
    int pid = fork();
    48f8:	00001097          	auipc	ra,0x1
    48fc:	578080e7          	jalr	1400(ra) # 5e70 <fork>
    4900:	84aa                	mv	s1,a0
    if(pid < 0){
    4902:	02054263          	bltz	a0,4926 <reparent+0x4e>
    if(pid){
    4906:	cd21                	beqz	a0,495e <reparent+0x86>
      if(wait(0) != pid){
    4908:	4501                	li	a0,0
    490a:	00001097          	auipc	ra,0x1
    490e:	576080e7          	jalr	1398(ra) # 5e80 <wait>
    4912:	02951863          	bne	a0,s1,4942 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4916:	397d                	addiw	s2,s2,-1
    4918:	fe0910e3          	bnez	s2,48f8 <reparent+0x20>
  exit(0);
    491c:	4501                	li	a0,0
    491e:	00001097          	auipc	ra,0x1
    4922:	55a080e7          	jalr	1370(ra) # 5e78 <exit>
      printf("%s: fork failed\n", s);
    4926:	85ce                	mv	a1,s3
    4928:	00002517          	auipc	a0,0x2
    492c:	34850513          	addi	a0,a0,840 # 6c70 <malloc+0x9c6>
    4930:	00002097          	auipc	ra,0x2
    4934:	8be080e7          	jalr	-1858(ra) # 61ee <printf>
      exit(1);
    4938:	4505                	li	a0,1
    493a:	00001097          	auipc	ra,0x1
    493e:	53e080e7          	jalr	1342(ra) # 5e78 <exit>
        printf("%s: wait wrong pid\n", s);
    4942:	85ce                	mv	a1,s3
    4944:	00002517          	auipc	a0,0x2
    4948:	4b450513          	addi	a0,a0,1204 # 6df8 <malloc+0xb4e>
    494c:	00002097          	auipc	ra,0x2
    4950:	8a2080e7          	jalr	-1886(ra) # 61ee <printf>
        exit(1);
    4954:	4505                	li	a0,1
    4956:	00001097          	auipc	ra,0x1
    495a:	522080e7          	jalr	1314(ra) # 5e78 <exit>
      int pid2 = fork();
    495e:	00001097          	auipc	ra,0x1
    4962:	512080e7          	jalr	1298(ra) # 5e70 <fork>
      if(pid2 < 0){
    4966:	00054763          	bltz	a0,4974 <reparent+0x9c>
      exit(0);
    496a:	4501                	li	a0,0
    496c:	00001097          	auipc	ra,0x1
    4970:	50c080e7          	jalr	1292(ra) # 5e78 <exit>
        kill(master_pid);
    4974:	8552                	mv	a0,s4
    4976:	00001097          	auipc	ra,0x1
    497a:	532080e7          	jalr	1330(ra) # 5ea8 <kill>
        exit(1);
    497e:	4505                	li	a0,1
    4980:	00001097          	auipc	ra,0x1
    4984:	4f8080e7          	jalr	1272(ra) # 5e78 <exit>

0000000000004988 <sbrkfail>:
{
    4988:	7175                	addi	sp,sp,-144
    498a:	e506                	sd	ra,136(sp)
    498c:	e122                	sd	s0,128(sp)
    498e:	fca6                	sd	s1,120(sp)
    4990:	f8ca                	sd	s2,112(sp)
    4992:	f4ce                	sd	s3,104(sp)
    4994:	f0d2                	sd	s4,96(sp)
    4996:	ecd6                	sd	s5,88(sp)
    4998:	e8da                	sd	s6,80(sp)
    499a:	e4de                	sd	s7,72(sp)
    499c:	0900                	addi	s0,sp,144
    499e:	8baa                	mv	s7,a0
  if(pipe(fds) != 0){
    49a0:	fa040513          	addi	a0,s0,-96
    49a4:	00001097          	auipc	ra,0x1
    49a8:	4e4080e7          	jalr	1252(ra) # 5e88 <pipe>
    49ac:	e919                	bnez	a0,49c2 <sbrkfail+0x3a>
    49ae:	f7040493          	addi	s1,s0,-144
    49b2:	f9840993          	addi	s3,s0,-104
    49b6:	8926                	mv	s2,s1
    if(pids[i] != -1)
    49b8:	5a7d                	li	s4,-1
      read(fds[0], &scratch, 1);
    49ba:	f9f40b13          	addi	s6,s0,-97
    49be:	4a85                	li	s5,1
    49c0:	a08d                	j	4a22 <sbrkfail+0x9a>
    printf("%s: pipe() failed\n", s);
    49c2:	85de                	mv	a1,s7
    49c4:	00002517          	auipc	a0,0x2
    49c8:	3b450513          	addi	a0,a0,948 # 6d78 <malloc+0xace>
    49cc:	00002097          	auipc	ra,0x2
    49d0:	822080e7          	jalr	-2014(ra) # 61ee <printf>
    exit(1);
    49d4:	4505                	li	a0,1
    49d6:	00001097          	auipc	ra,0x1
    49da:	4a2080e7          	jalr	1186(ra) # 5e78 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    49de:	00001097          	auipc	ra,0x1
    49e2:	522080e7          	jalr	1314(ra) # 5f00 <sbrk>
    49e6:	064007b7          	lui	a5,0x6400
    49ea:	40a7853b          	subw	a0,a5,a0
    49ee:	00001097          	auipc	ra,0x1
    49f2:	512080e7          	jalr	1298(ra) # 5f00 <sbrk>
      write(fds[1], "x", 1);
    49f6:	4605                	li	a2,1
    49f8:	00002597          	auipc	a1,0x2
    49fc:	a6058593          	addi	a1,a1,-1440 # 6458 <malloc+0x1ae>
    4a00:	fa442503          	lw	a0,-92(s0)
    4a04:	00001097          	auipc	ra,0x1
    4a08:	494080e7          	jalr	1172(ra) # 5e98 <write>
      for(;;) sleep(1000);
    4a0c:	3e800493          	li	s1,1000
    4a10:	8526                	mv	a0,s1
    4a12:	00001097          	auipc	ra,0x1
    4a16:	4f6080e7          	jalr	1270(ra) # 5f08 <sleep>
    4a1a:	bfdd                	j	4a10 <sbrkfail+0x88>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4a1c:	0911                	addi	s2,s2,4
    4a1e:	03390463          	beq	s2,s3,4a46 <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    4a22:	00001097          	auipc	ra,0x1
    4a26:	44e080e7          	jalr	1102(ra) # 5e70 <fork>
    4a2a:	00a92023          	sw	a0,0(s2)
    4a2e:	d945                	beqz	a0,49de <sbrkfail+0x56>
    if(pids[i] != -1)
    4a30:	ff4506e3          	beq	a0,s4,4a1c <sbrkfail+0x94>
      read(fds[0], &scratch, 1);
    4a34:	8656                	mv	a2,s5
    4a36:	85da                	mv	a1,s6
    4a38:	fa042503          	lw	a0,-96(s0)
    4a3c:	00001097          	auipc	ra,0x1
    4a40:	454080e7          	jalr	1108(ra) # 5e90 <read>
    4a44:	bfe1                	j	4a1c <sbrkfail+0x94>
  c = sbrk(PGSIZE);
    4a46:	6505                	lui	a0,0x1
    4a48:	00001097          	auipc	ra,0x1
    4a4c:	4b8080e7          	jalr	1208(ra) # 5f00 <sbrk>
    4a50:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4a52:	597d                	li	s2,-1
    4a54:	a021                	j	4a5c <sbrkfail+0xd4>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4a56:	0491                	addi	s1,s1,4
    4a58:	01348f63          	beq	s1,s3,4a76 <sbrkfail+0xee>
    if(pids[i] == -1)
    4a5c:	4088                	lw	a0,0(s1)
    4a5e:	ff250ce3          	beq	a0,s2,4a56 <sbrkfail+0xce>
    kill(pids[i]);
    4a62:	00001097          	auipc	ra,0x1
    4a66:	446080e7          	jalr	1094(ra) # 5ea8 <kill>
    wait(0);
    4a6a:	4501                	li	a0,0
    4a6c:	00001097          	auipc	ra,0x1
    4a70:	414080e7          	jalr	1044(ra) # 5e80 <wait>
    4a74:	b7cd                	j	4a56 <sbrkfail+0xce>
  if(c == (char*)0xffffffffffffffffL){
    4a76:	57fd                	li	a5,-1
    4a78:	04fa0363          	beq	s4,a5,4abe <sbrkfail+0x136>
  pid = fork();
    4a7c:	00001097          	auipc	ra,0x1
    4a80:	3f4080e7          	jalr	1012(ra) # 5e70 <fork>
    4a84:	84aa                	mv	s1,a0
  if(pid < 0){
    4a86:	04054a63          	bltz	a0,4ada <sbrkfail+0x152>
  if(pid == 0){
    4a8a:	c535                	beqz	a0,4af6 <sbrkfail+0x16e>
  wait(&xstatus);
    4a8c:	fac40513          	addi	a0,s0,-84
    4a90:	00001097          	auipc	ra,0x1
    4a94:	3f0080e7          	jalr	1008(ra) # 5e80 <wait>
  if(xstatus != -1 && xstatus != 2)
    4a98:	fac42783          	lw	a5,-84(s0)
    4a9c:	577d                	li	a4,-1
    4a9e:	00e78563          	beq	a5,a4,4aa8 <sbrkfail+0x120>
    4aa2:	4709                	li	a4,2
    4aa4:	08e79f63          	bne	a5,a4,4b42 <sbrkfail+0x1ba>
}
    4aa8:	60aa                	ld	ra,136(sp)
    4aaa:	640a                	ld	s0,128(sp)
    4aac:	74e6                	ld	s1,120(sp)
    4aae:	7946                	ld	s2,112(sp)
    4ab0:	79a6                	ld	s3,104(sp)
    4ab2:	7a06                	ld	s4,96(sp)
    4ab4:	6ae6                	ld	s5,88(sp)
    4ab6:	6b46                	ld	s6,80(sp)
    4ab8:	6ba6                	ld	s7,72(sp)
    4aba:	6149                	addi	sp,sp,144
    4abc:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4abe:	85de                	mv	a1,s7
    4ac0:	00003517          	auipc	a0,0x3
    4ac4:	51050513          	addi	a0,a0,1296 # 7fd0 <malloc+0x1d26>
    4ac8:	00001097          	auipc	ra,0x1
    4acc:	726080e7          	jalr	1830(ra) # 61ee <printf>
    exit(1);
    4ad0:	4505                	li	a0,1
    4ad2:	00001097          	auipc	ra,0x1
    4ad6:	3a6080e7          	jalr	934(ra) # 5e78 <exit>
    printf("%s: fork failed\n", s);
    4ada:	85de                	mv	a1,s7
    4adc:	00002517          	auipc	a0,0x2
    4ae0:	19450513          	addi	a0,a0,404 # 6c70 <malloc+0x9c6>
    4ae4:	00001097          	auipc	ra,0x1
    4ae8:	70a080e7          	jalr	1802(ra) # 61ee <printf>
    exit(1);
    4aec:	4505                	li	a0,1
    4aee:	00001097          	auipc	ra,0x1
    4af2:	38a080e7          	jalr	906(ra) # 5e78 <exit>
    a = sbrk(0);
    4af6:	4501                	li	a0,0
    4af8:	00001097          	auipc	ra,0x1
    4afc:	408080e7          	jalr	1032(ra) # 5f00 <sbrk>
    4b00:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4b02:	3e800537          	lui	a0,0x3e800
    4b06:	00001097          	auipc	ra,0x1
    4b0a:	3fa080e7          	jalr	1018(ra) # 5f00 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4b0e:	87ca                	mv	a5,s2
    4b10:	3e800737          	lui	a4,0x3e800
    4b14:	993a                	add	s2,s2,a4
    4b16:	6705                	lui	a4,0x1
      n += *(a+i);
    4b18:	0007c603          	lbu	a2,0(a5) # 6400000 <base+0x63f0388>
    4b1c:	9e25                	addw	a2,a2,s1
    4b1e:	84b2                	mv	s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4b20:	97ba                	add	a5,a5,a4
    4b22:	fef91be3          	bne	s2,a5,4b18 <sbrkfail+0x190>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4b26:	85de                	mv	a1,s7
    4b28:	00003517          	auipc	a0,0x3
    4b2c:	4c850513          	addi	a0,a0,1224 # 7ff0 <malloc+0x1d46>
    4b30:	00001097          	auipc	ra,0x1
    4b34:	6be080e7          	jalr	1726(ra) # 61ee <printf>
    exit(1);
    4b38:	4505                	li	a0,1
    4b3a:	00001097          	auipc	ra,0x1
    4b3e:	33e080e7          	jalr	830(ra) # 5e78 <exit>
    exit(1);
    4b42:	4505                	li	a0,1
    4b44:	00001097          	auipc	ra,0x1
    4b48:	334080e7          	jalr	820(ra) # 5e78 <exit>

0000000000004b4c <mem>:
{
    4b4c:	7139                	addi	sp,sp,-64
    4b4e:	fc06                	sd	ra,56(sp)
    4b50:	f822                	sd	s0,48(sp)
    4b52:	f426                	sd	s1,40(sp)
    4b54:	f04a                	sd	s2,32(sp)
    4b56:	ec4e                	sd	s3,24(sp)
    4b58:	0080                	addi	s0,sp,64
    4b5a:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4b5c:	00001097          	auipc	ra,0x1
    4b60:	314080e7          	jalr	788(ra) # 5e70 <fork>
    m1 = 0;
    4b64:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4b66:	6909                	lui	s2,0x2
    4b68:	71190913          	addi	s2,s2,1809 # 2711 <manywrites+0x16d>
  if((pid = fork()) == 0){
    4b6c:	c115                	beqz	a0,4b90 <mem+0x44>
    wait(&xstatus);
    4b6e:	fcc40513          	addi	a0,s0,-52
    4b72:	00001097          	auipc	ra,0x1
    4b76:	30e080e7          	jalr	782(ra) # 5e80 <wait>
    if(xstatus == -1){
    4b7a:	fcc42503          	lw	a0,-52(s0)
    4b7e:	57fd                	li	a5,-1
    4b80:	06f50363          	beq	a0,a5,4be6 <mem+0x9a>
    exit(xstatus);
    4b84:	00001097          	auipc	ra,0x1
    4b88:	2f4080e7          	jalr	756(ra) # 5e78 <exit>
      *(char**)m2 = m1;
    4b8c:	e104                	sd	s1,0(a0)
      m1 = m2;
    4b8e:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    4b90:	854a                	mv	a0,s2
    4b92:	00001097          	auipc	ra,0x1
    4b96:	718080e7          	jalr	1816(ra) # 62aa <malloc>
    4b9a:	f96d                	bnez	a0,4b8c <mem+0x40>
    while(m1){
    4b9c:	c881                	beqz	s1,4bac <mem+0x60>
      m2 = *(char**)m1;
    4b9e:	8526                	mv	a0,s1
    4ba0:	6084                	ld	s1,0(s1)
      free(m1);
    4ba2:	00001097          	auipc	ra,0x1
    4ba6:	682080e7          	jalr	1666(ra) # 6224 <free>
    while(m1){
    4baa:	f8f5                	bnez	s1,4b9e <mem+0x52>
    m1 = malloc(1024*20);
    4bac:	6515                	lui	a0,0x5
    4bae:	00001097          	auipc	ra,0x1
    4bb2:	6fc080e7          	jalr	1788(ra) # 62aa <malloc>
    if(m1 == 0){
    4bb6:	c911                	beqz	a0,4bca <mem+0x7e>
    free(m1);
    4bb8:	00001097          	auipc	ra,0x1
    4bbc:	66c080e7          	jalr	1644(ra) # 6224 <free>
    exit(0);
    4bc0:	4501                	li	a0,0
    4bc2:	00001097          	auipc	ra,0x1
    4bc6:	2b6080e7          	jalr	694(ra) # 5e78 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4bca:	85ce                	mv	a1,s3
    4bcc:	00003517          	auipc	a0,0x3
    4bd0:	45450513          	addi	a0,a0,1108 # 8020 <malloc+0x1d76>
    4bd4:	00001097          	auipc	ra,0x1
    4bd8:	61a080e7          	jalr	1562(ra) # 61ee <printf>
      exit(1);
    4bdc:	4505                	li	a0,1
    4bde:	00001097          	auipc	ra,0x1
    4be2:	29a080e7          	jalr	666(ra) # 5e78 <exit>
      exit(0);
    4be6:	4501                	li	a0,0
    4be8:	00001097          	auipc	ra,0x1
    4bec:	290080e7          	jalr	656(ra) # 5e78 <exit>

0000000000004bf0 <sharedfd>:
{
    4bf0:	7119                	addi	sp,sp,-128
    4bf2:	fc86                	sd	ra,120(sp)
    4bf4:	f8a2                	sd	s0,112(sp)
    4bf6:	e0da                	sd	s6,64(sp)
    4bf8:	0100                	addi	s0,sp,128
    4bfa:	8b2a                	mv	s6,a0
  unlink("sharedfd");
    4bfc:	00003517          	auipc	a0,0x3
    4c00:	44450513          	addi	a0,a0,1092 # 8040 <malloc+0x1d96>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	2c4080e7          	jalr	708(ra) # 5ec8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4c0c:	20200593          	li	a1,514
    4c10:	00003517          	auipc	a0,0x3
    4c14:	43050513          	addi	a0,a0,1072 # 8040 <malloc+0x1d96>
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	2a0080e7          	jalr	672(ra) # 5eb8 <open>
  if(fd < 0){
    4c20:	06054363          	bltz	a0,4c86 <sharedfd+0x96>
    4c24:	f4a6                	sd	s1,104(sp)
    4c26:	f0ca                	sd	s2,96(sp)
    4c28:	ecce                	sd	s3,88(sp)
    4c2a:	e8d2                	sd	s4,80(sp)
    4c2c:	e4d6                	sd	s5,72(sp)
    4c2e:	89aa                	mv	s3,a0
  pid = fork();
    4c30:	00001097          	auipc	ra,0x1
    4c34:	240080e7          	jalr	576(ra) # 5e70 <fork>
    4c38:	8aaa                	mv	s5,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4c3a:	07000593          	li	a1,112
    4c3e:	e119                	bnez	a0,4c44 <sharedfd+0x54>
    4c40:	06300593          	li	a1,99
    4c44:	4629                	li	a2,10
    4c46:	f9040513          	addi	a0,s0,-112
    4c4a:	00001097          	auipc	ra,0x1
    4c4e:	00c080e7          	jalr	12(ra) # 5c56 <memset>
    4c52:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4c56:	f9040a13          	addi	s4,s0,-112
    4c5a:	4929                	li	s2,10
    4c5c:	864a                	mv	a2,s2
    4c5e:	85d2                	mv	a1,s4
    4c60:	854e                	mv	a0,s3
    4c62:	00001097          	auipc	ra,0x1
    4c66:	236080e7          	jalr	566(ra) # 5e98 <write>
    4c6a:	05251463          	bne	a0,s2,4cb2 <sharedfd+0xc2>
  for(i = 0; i < N; i++){
    4c6e:	34fd                	addiw	s1,s1,-1
    4c70:	f4f5                	bnez	s1,4c5c <sharedfd+0x6c>
  if(pid == 0) {
    4c72:	060a9163          	bnez	s5,4cd4 <sharedfd+0xe4>
    4c76:	fc5e                	sd	s7,56(sp)
    4c78:	f862                	sd	s8,48(sp)
    4c7a:	f466                	sd	s9,40(sp)
    exit(0);
    4c7c:	4501                	li	a0,0
    4c7e:	00001097          	auipc	ra,0x1
    4c82:	1fa080e7          	jalr	506(ra) # 5e78 <exit>
    4c86:	f4a6                	sd	s1,104(sp)
    4c88:	f0ca                	sd	s2,96(sp)
    4c8a:	ecce                	sd	s3,88(sp)
    4c8c:	e8d2                	sd	s4,80(sp)
    4c8e:	e4d6                	sd	s5,72(sp)
    4c90:	fc5e                	sd	s7,56(sp)
    4c92:	f862                	sd	s8,48(sp)
    4c94:	f466                	sd	s9,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    4c96:	85da                	mv	a1,s6
    4c98:	00003517          	auipc	a0,0x3
    4c9c:	3b850513          	addi	a0,a0,952 # 8050 <malloc+0x1da6>
    4ca0:	00001097          	auipc	ra,0x1
    4ca4:	54e080e7          	jalr	1358(ra) # 61ee <printf>
    exit(1);
    4ca8:	4505                	li	a0,1
    4caa:	00001097          	auipc	ra,0x1
    4cae:	1ce080e7          	jalr	462(ra) # 5e78 <exit>
    4cb2:	fc5e                	sd	s7,56(sp)
    4cb4:	f862                	sd	s8,48(sp)
    4cb6:	f466                	sd	s9,40(sp)
      printf("%s: write sharedfd failed\n", s);
    4cb8:	85da                	mv	a1,s6
    4cba:	00003517          	auipc	a0,0x3
    4cbe:	3be50513          	addi	a0,a0,958 # 8078 <malloc+0x1dce>
    4cc2:	00001097          	auipc	ra,0x1
    4cc6:	52c080e7          	jalr	1324(ra) # 61ee <printf>
      exit(1);
    4cca:	4505                	li	a0,1
    4ccc:	00001097          	auipc	ra,0x1
    4cd0:	1ac080e7          	jalr	428(ra) # 5e78 <exit>
    wait(&xstatus);
    4cd4:	f8c40513          	addi	a0,s0,-116
    4cd8:	00001097          	auipc	ra,0x1
    4cdc:	1a8080e7          	jalr	424(ra) # 5e80 <wait>
    if(xstatus != 0)
    4ce0:	f8c42a03          	lw	s4,-116(s0)
    4ce4:	000a0a63          	beqz	s4,4cf8 <sharedfd+0x108>
    4ce8:	fc5e                	sd	s7,56(sp)
    4cea:	f862                	sd	s8,48(sp)
    4cec:	f466                	sd	s9,40(sp)
      exit(xstatus);
    4cee:	8552                	mv	a0,s4
    4cf0:	00001097          	auipc	ra,0x1
    4cf4:	188080e7          	jalr	392(ra) # 5e78 <exit>
    4cf8:	fc5e                	sd	s7,56(sp)
  close(fd);
    4cfa:	854e                	mv	a0,s3
    4cfc:	00001097          	auipc	ra,0x1
    4d00:	1a4080e7          	jalr	420(ra) # 5ea0 <close>
  fd = open("sharedfd", 0);
    4d04:	4581                	li	a1,0
    4d06:	00003517          	auipc	a0,0x3
    4d0a:	33a50513          	addi	a0,a0,826 # 8040 <malloc+0x1d96>
    4d0e:	00001097          	auipc	ra,0x1
    4d12:	1aa080e7          	jalr	426(ra) # 5eb8 <open>
    4d16:	8baa                	mv	s7,a0
  nc = np = 0;
    4d18:	89d2                	mv	s3,s4
  if(fd < 0){
    4d1a:	02054963          	bltz	a0,4d4c <sharedfd+0x15c>
    4d1e:	f862                	sd	s8,48(sp)
    4d20:	f466                	sd	s9,40(sp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4d22:	f9040c93          	addi	s9,s0,-112
    4d26:	4c29                	li	s8,10
    4d28:	f9a40913          	addi	s2,s0,-102
      if(buf[i] == 'c')
    4d2c:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4d30:	07000a93          	li	s5,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4d34:	8662                	mv	a2,s8
    4d36:	85e6                	mv	a1,s9
    4d38:	855e                	mv	a0,s7
    4d3a:	00001097          	auipc	ra,0x1
    4d3e:	156080e7          	jalr	342(ra) # 5e90 <read>
    4d42:	04a05163          	blez	a0,4d84 <sharedfd+0x194>
    4d46:	f9040793          	addi	a5,s0,-112
    4d4a:	a02d                	j	4d74 <sharedfd+0x184>
    4d4c:	f862                	sd	s8,48(sp)
    4d4e:	f466                	sd	s9,40(sp)
    printf("%s: cannot open sharedfd for reading\n", s);
    4d50:	85da                	mv	a1,s6
    4d52:	00003517          	auipc	a0,0x3
    4d56:	34650513          	addi	a0,a0,838 # 8098 <malloc+0x1dee>
    4d5a:	00001097          	auipc	ra,0x1
    4d5e:	494080e7          	jalr	1172(ra) # 61ee <printf>
    exit(1);
    4d62:	4505                	li	a0,1
    4d64:	00001097          	auipc	ra,0x1
    4d68:	114080e7          	jalr	276(ra) # 5e78 <exit>
        nc++;
    4d6c:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    4d6e:	0785                	addi	a5,a5,1
    4d70:	fd2782e3          	beq	a5,s2,4d34 <sharedfd+0x144>
      if(buf[i] == 'c')
    4d74:	0007c703          	lbu	a4,0(a5)
    4d78:	fe970ae3          	beq	a4,s1,4d6c <sharedfd+0x17c>
      if(buf[i] == 'p')
    4d7c:	ff5719e3          	bne	a4,s5,4d6e <sharedfd+0x17e>
        np++;
    4d80:	2985                	addiw	s3,s3,1
    4d82:	b7f5                	j	4d6e <sharedfd+0x17e>
  close(fd);
    4d84:	855e                	mv	a0,s7
    4d86:	00001097          	auipc	ra,0x1
    4d8a:	11a080e7          	jalr	282(ra) # 5ea0 <close>
  unlink("sharedfd");
    4d8e:	00003517          	auipc	a0,0x3
    4d92:	2b250513          	addi	a0,a0,690 # 8040 <malloc+0x1d96>
    4d96:	00001097          	auipc	ra,0x1
    4d9a:	132080e7          	jalr	306(ra) # 5ec8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4d9e:	6789                	lui	a5,0x2
    4da0:	71078793          	addi	a5,a5,1808 # 2710 <manywrites+0x16c>
    4da4:	00fa1763          	bne	s4,a5,4db2 <sharedfd+0x1c2>
    4da8:	6789                	lui	a5,0x2
    4daa:	71078793          	addi	a5,a5,1808 # 2710 <manywrites+0x16c>
    4dae:	02f98063          	beq	s3,a5,4dce <sharedfd+0x1de>
    printf("%s: nc/np test fails\n", s);
    4db2:	85da                	mv	a1,s6
    4db4:	00003517          	auipc	a0,0x3
    4db8:	30c50513          	addi	a0,a0,780 # 80c0 <malloc+0x1e16>
    4dbc:	00001097          	auipc	ra,0x1
    4dc0:	432080e7          	jalr	1074(ra) # 61ee <printf>
    exit(1);
    4dc4:	4505                	li	a0,1
    4dc6:	00001097          	auipc	ra,0x1
    4dca:	0b2080e7          	jalr	178(ra) # 5e78 <exit>
    exit(0);
    4dce:	4501                	li	a0,0
    4dd0:	00001097          	auipc	ra,0x1
    4dd4:	0a8080e7          	jalr	168(ra) # 5e78 <exit>

0000000000004dd8 <fourfiles>:
{
    4dd8:	7135                	addi	sp,sp,-160
    4dda:	ed06                	sd	ra,152(sp)
    4ddc:	e922                	sd	s0,144(sp)
    4dde:	e526                	sd	s1,136(sp)
    4de0:	e14a                	sd	s2,128(sp)
    4de2:	fcce                	sd	s3,120(sp)
    4de4:	f8d2                	sd	s4,112(sp)
    4de6:	f4d6                	sd	s5,104(sp)
    4de8:	f0da                	sd	s6,96(sp)
    4dea:	ecde                	sd	s7,88(sp)
    4dec:	e8e2                	sd	s8,80(sp)
    4dee:	e4e6                	sd	s9,72(sp)
    4df0:	e0ea                	sd	s10,64(sp)
    4df2:	fc6e                	sd	s11,56(sp)
    4df4:	1100                	addi	s0,sp,160
    4df6:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4df8:	00003797          	auipc	a5,0x3
    4dfc:	2e078793          	addi	a5,a5,736 # 80d8 <malloc+0x1e2e>
    4e00:	f6f43823          	sd	a5,-144(s0)
    4e04:	00003797          	auipc	a5,0x3
    4e08:	2dc78793          	addi	a5,a5,732 # 80e0 <malloc+0x1e36>
    4e0c:	f6f43c23          	sd	a5,-136(s0)
    4e10:	00003797          	auipc	a5,0x3
    4e14:	2d878793          	addi	a5,a5,728 # 80e8 <malloc+0x1e3e>
    4e18:	f8f43023          	sd	a5,-128(s0)
    4e1c:	00003797          	auipc	a5,0x3
    4e20:	2d478793          	addi	a5,a5,724 # 80f0 <malloc+0x1e46>
    4e24:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4e28:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4e2c:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4e2e:	4481                	li	s1,0
    4e30:	4a11                	li	s4,4
    fname = names[pi];
    4e32:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4e36:	854e                	mv	a0,s3
    4e38:	00001097          	auipc	ra,0x1
    4e3c:	090080e7          	jalr	144(ra) # 5ec8 <unlink>
    pid = fork();
    4e40:	00001097          	auipc	ra,0x1
    4e44:	030080e7          	jalr	48(ra) # 5e70 <fork>
    if(pid < 0){
    4e48:	04054263          	bltz	a0,4e8c <fourfiles+0xb4>
    if(pid == 0){
    4e4c:	cd31                	beqz	a0,4ea8 <fourfiles+0xd0>
  for(pi = 0; pi < NCHILD; pi++){
    4e4e:	2485                	addiw	s1,s1,1
    4e50:	0921                	addi	s2,s2,8
    4e52:	ff4490e3          	bne	s1,s4,4e32 <fourfiles+0x5a>
    4e56:	4491                	li	s1,4
    wait(&xstatus);
    4e58:	f6c40913          	addi	s2,s0,-148
    4e5c:	854a                	mv	a0,s2
    4e5e:	00001097          	auipc	ra,0x1
    4e62:	022080e7          	jalr	34(ra) # 5e80 <wait>
    if(xstatus != 0)
    4e66:	f6c42b03          	lw	s6,-148(s0)
    4e6a:	0c0b1863          	bnez	s6,4f3a <fourfiles+0x162>
  for(pi = 0; pi < NCHILD; pi++){
    4e6e:	34fd                	addiw	s1,s1,-1
    4e70:	f4f5                	bnez	s1,4e5c <fourfiles+0x84>
    4e72:	03000493          	li	s1,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e76:	6a8d                	lui	s5,0x3
    4e78:	00008a17          	auipc	s4,0x8
    4e7c:	e00a0a13          	addi	s4,s4,-512 # cc78 <buf>
    if(total != N*SZ){
    4e80:	6d05                	lui	s10,0x1
    4e82:	770d0d13          	addi	s10,s10,1904 # 1770 <truncate3+0x18e>
  for(i = 0; i < NCHILD; i++){
    4e86:	03400d93          	li	s11,52
    4e8a:	a8dd                	j	4f80 <fourfiles+0x1a8>
      printf("fork failed\n", s);
    4e8c:	85e6                	mv	a1,s9
    4e8e:	00002517          	auipc	a0,0x2
    4e92:	1ea50513          	addi	a0,a0,490 # 7078 <malloc+0xdce>
    4e96:	00001097          	auipc	ra,0x1
    4e9a:	358080e7          	jalr	856(ra) # 61ee <printf>
      exit(1);
    4e9e:	4505                	li	a0,1
    4ea0:	00001097          	auipc	ra,0x1
    4ea4:	fd8080e7          	jalr	-40(ra) # 5e78 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4ea8:	20200593          	li	a1,514
    4eac:	854e                	mv	a0,s3
    4eae:	00001097          	auipc	ra,0x1
    4eb2:	00a080e7          	jalr	10(ra) # 5eb8 <open>
    4eb6:	892a                	mv	s2,a0
      if(fd < 0){
    4eb8:	04054663          	bltz	a0,4f04 <fourfiles+0x12c>
      memset(buf, '0'+pi, SZ);
    4ebc:	1f400613          	li	a2,500
    4ec0:	0304859b          	addiw	a1,s1,48
    4ec4:	00008517          	auipc	a0,0x8
    4ec8:	db450513          	addi	a0,a0,-588 # cc78 <buf>
    4ecc:	00001097          	auipc	ra,0x1
    4ed0:	d8a080e7          	jalr	-630(ra) # 5c56 <memset>
    4ed4:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4ed6:	1f400993          	li	s3,500
    4eda:	00008a17          	auipc	s4,0x8
    4ede:	d9ea0a13          	addi	s4,s4,-610 # cc78 <buf>
    4ee2:	864e                	mv	a2,s3
    4ee4:	85d2                	mv	a1,s4
    4ee6:	854a                	mv	a0,s2
    4ee8:	00001097          	auipc	ra,0x1
    4eec:	fb0080e7          	jalr	-80(ra) # 5e98 <write>
    4ef0:	85aa                	mv	a1,a0
    4ef2:	03351763          	bne	a0,s3,4f20 <fourfiles+0x148>
      for(i = 0; i < N; i++){
    4ef6:	34fd                	addiw	s1,s1,-1
    4ef8:	f4ed                	bnez	s1,4ee2 <fourfiles+0x10a>
      exit(0);
    4efa:	4501                	li	a0,0
    4efc:	00001097          	auipc	ra,0x1
    4f00:	f7c080e7          	jalr	-132(ra) # 5e78 <exit>
        printf("create failed\n", s);
    4f04:	85e6                	mv	a1,s9
    4f06:	00003517          	auipc	a0,0x3
    4f0a:	1f250513          	addi	a0,a0,498 # 80f8 <malloc+0x1e4e>
    4f0e:	00001097          	auipc	ra,0x1
    4f12:	2e0080e7          	jalr	736(ra) # 61ee <printf>
        exit(1);
    4f16:	4505                	li	a0,1
    4f18:	00001097          	auipc	ra,0x1
    4f1c:	f60080e7          	jalr	-160(ra) # 5e78 <exit>
          printf("write failed %d\n", n);
    4f20:	00003517          	auipc	a0,0x3
    4f24:	1e850513          	addi	a0,a0,488 # 8108 <malloc+0x1e5e>
    4f28:	00001097          	auipc	ra,0x1
    4f2c:	2c6080e7          	jalr	710(ra) # 61ee <printf>
          exit(1);
    4f30:	4505                	li	a0,1
    4f32:	00001097          	auipc	ra,0x1
    4f36:	f46080e7          	jalr	-186(ra) # 5e78 <exit>
      exit(xstatus);
    4f3a:	855a                	mv	a0,s6
    4f3c:	00001097          	auipc	ra,0x1
    4f40:	f3c080e7          	jalr	-196(ra) # 5e78 <exit>
          printf("wrong char\n", s);
    4f44:	85e6                	mv	a1,s9
    4f46:	00003517          	auipc	a0,0x3
    4f4a:	1da50513          	addi	a0,a0,474 # 8120 <malloc+0x1e76>
    4f4e:	00001097          	auipc	ra,0x1
    4f52:	2a0080e7          	jalr	672(ra) # 61ee <printf>
          exit(1);
    4f56:	4505                	li	a0,1
    4f58:	00001097          	auipc	ra,0x1
    4f5c:	f20080e7          	jalr	-224(ra) # 5e78 <exit>
    close(fd);
    4f60:	854e                	mv	a0,s3
    4f62:	00001097          	auipc	ra,0x1
    4f66:	f3e080e7          	jalr	-194(ra) # 5ea0 <close>
    if(total != N*SZ){
    4f6a:	05a91e63          	bne	s2,s10,4fc6 <fourfiles+0x1ee>
    unlink(fname);
    4f6e:	8562                	mv	a0,s8
    4f70:	00001097          	auipc	ra,0x1
    4f74:	f58080e7          	jalr	-168(ra) # 5ec8 <unlink>
  for(i = 0; i < NCHILD; i++){
    4f78:	0ba1                	addi	s7,s7,8
    4f7a:	2485                	addiw	s1,s1,1
    4f7c:	07b48363          	beq	s1,s11,4fe2 <fourfiles+0x20a>
    fname = names[i];
    4f80:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4f84:	4581                	li	a1,0
    4f86:	8562                	mv	a0,s8
    4f88:	00001097          	auipc	ra,0x1
    4f8c:	f30080e7          	jalr	-208(ra) # 5eb8 <open>
    4f90:	89aa                	mv	s3,a0
    total = 0;
    4f92:	895a                	mv	s2,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4f94:	8656                	mv	a2,s5
    4f96:	85d2                	mv	a1,s4
    4f98:	854e                	mv	a0,s3
    4f9a:	00001097          	auipc	ra,0x1
    4f9e:	ef6080e7          	jalr	-266(ra) # 5e90 <read>
    4fa2:	faa05fe3          	blez	a0,4f60 <fourfiles+0x188>
    4fa6:	00008797          	auipc	a5,0x8
    4faa:	cd278793          	addi	a5,a5,-814 # cc78 <buf>
    4fae:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    4fb2:	0007c703          	lbu	a4,0(a5)
    4fb6:	f89717e3          	bne	a4,s1,4f44 <fourfiles+0x16c>
      for(j = 0; j < n; j++){
    4fba:	0785                	addi	a5,a5,1
    4fbc:	fed79be3          	bne	a5,a3,4fb2 <fourfiles+0x1da>
      total += n;
    4fc0:	00a9093b          	addw	s2,s2,a0
    4fc4:	bfc1                	j	4f94 <fourfiles+0x1bc>
      printf("wrong length %d\n", total);
    4fc6:	85ca                	mv	a1,s2
    4fc8:	00003517          	auipc	a0,0x3
    4fcc:	16850513          	addi	a0,a0,360 # 8130 <malloc+0x1e86>
    4fd0:	00001097          	auipc	ra,0x1
    4fd4:	21e080e7          	jalr	542(ra) # 61ee <printf>
      exit(1);
    4fd8:	4505                	li	a0,1
    4fda:	00001097          	auipc	ra,0x1
    4fde:	e9e080e7          	jalr	-354(ra) # 5e78 <exit>
}
    4fe2:	60ea                	ld	ra,152(sp)
    4fe4:	644a                	ld	s0,144(sp)
    4fe6:	64aa                	ld	s1,136(sp)
    4fe8:	690a                	ld	s2,128(sp)
    4fea:	79e6                	ld	s3,120(sp)
    4fec:	7a46                	ld	s4,112(sp)
    4fee:	7aa6                	ld	s5,104(sp)
    4ff0:	7b06                	ld	s6,96(sp)
    4ff2:	6be6                	ld	s7,88(sp)
    4ff4:	6c46                	ld	s8,80(sp)
    4ff6:	6ca6                	ld	s9,72(sp)
    4ff8:	6d06                	ld	s10,64(sp)
    4ffa:	7de2                	ld	s11,56(sp)
    4ffc:	610d                	addi	sp,sp,160
    4ffe:	8082                	ret

0000000000005000 <concreate>:
{
    5000:	7171                	addi	sp,sp,-176
    5002:	f506                	sd	ra,168(sp)
    5004:	f122                	sd	s0,160(sp)
    5006:	ed26                	sd	s1,152(sp)
    5008:	e94a                	sd	s2,144(sp)
    500a:	e54e                	sd	s3,136(sp)
    500c:	e152                	sd	s4,128(sp)
    500e:	fcd6                	sd	s5,120(sp)
    5010:	f8da                	sd	s6,112(sp)
    5012:	f4de                	sd	s7,104(sp)
    5014:	f0e2                	sd	s8,96(sp)
    5016:	ece6                	sd	s9,88(sp)
    5018:	e8ea                	sd	s10,80(sp)
    501a:	1900                	addi	s0,sp,176
    501c:	8baa                	mv	s7,a0
  file[0] = 'C';
    501e:	04300793          	li	a5,67
    5022:	f8f40c23          	sb	a5,-104(s0)
  file[2] = '\0';
    5026:	f8040d23          	sb	zero,-102(s0)
  for(i = 0; i < N; i++){
    502a:	4901                	li	s2,0
    unlink(file);
    502c:	f9840993          	addi	s3,s0,-104
    if(pid && (i % 3) == 1){
    5030:	55555b37          	lui	s6,0x55555
    5034:	556b0b13          	addi	s6,s6,1366 # 55555556 <base+0x555458de>
    5038:	4c05                	li	s8,1
      fd = open(file, O_CREATE | O_RDWR);
    503a:	20200c93          	li	s9,514
      link("C0", file);
    503e:	00003d17          	auipc	s10,0x3
    5042:	10ad0d13          	addi	s10,s10,266 # 8148 <malloc+0x1e9e>
      wait(&xstatus);
    5046:	f5c40a93          	addi	s5,s0,-164
  for(i = 0; i < N; i++){
    504a:	02800a13          	li	s4,40
    504e:	a4dd                	j	5334 <concreate+0x334>
      link("C0", file);
    5050:	85ce                	mv	a1,s3
    5052:	856a                	mv	a0,s10
    5054:	00001097          	auipc	ra,0x1
    5058:	e84080e7          	jalr	-380(ra) # 5ed8 <link>
    if(pid == 0) {
    505c:	a4c1                	j	531c <concreate+0x31c>
    } else if(pid == 0 && (i % 5) == 1){
    505e:	666667b7          	lui	a5,0x66666
    5062:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x666569ef>
    5066:	02f907b3          	mul	a5,s2,a5
    506a:	9785                	srai	a5,a5,0x21
    506c:	41f9571b          	sraiw	a4,s2,0x1f
    5070:	9f99                	subw	a5,a5,a4
    5072:	0027971b          	slliw	a4,a5,0x2
    5076:	9fb9                	addw	a5,a5,a4
    5078:	40f9093b          	subw	s2,s2,a5
    507c:	4785                	li	a5,1
    507e:	02f90b63          	beq	s2,a5,50b4 <concreate+0xb4>
      fd = open(file, O_CREATE | O_RDWR);
    5082:	20200593          	li	a1,514
    5086:	f9840513          	addi	a0,s0,-104
    508a:	00001097          	auipc	ra,0x1
    508e:	e2e080e7          	jalr	-466(ra) # 5eb8 <open>
      if(fd < 0){
    5092:	26055c63          	bgez	a0,530a <concreate+0x30a>
        printf("concreate create %s failed\n", file);
    5096:	f9840593          	addi	a1,s0,-104
    509a:	00003517          	auipc	a0,0x3
    509e:	0b650513          	addi	a0,a0,182 # 8150 <malloc+0x1ea6>
    50a2:	00001097          	auipc	ra,0x1
    50a6:	14c080e7          	jalr	332(ra) # 61ee <printf>
        exit(1);
    50aa:	4505                	li	a0,1
    50ac:	00001097          	auipc	ra,0x1
    50b0:	dcc080e7          	jalr	-564(ra) # 5e78 <exit>
      link("C0", file);
    50b4:	f9840593          	addi	a1,s0,-104
    50b8:	00003517          	auipc	a0,0x3
    50bc:	09050513          	addi	a0,a0,144 # 8148 <malloc+0x1e9e>
    50c0:	00001097          	auipc	ra,0x1
    50c4:	e18080e7          	jalr	-488(ra) # 5ed8 <link>
      exit(0);
    50c8:	4501                	li	a0,0
    50ca:	00001097          	auipc	ra,0x1
    50ce:	dae080e7          	jalr	-594(ra) # 5e78 <exit>
        exit(1);
    50d2:	4505                	li	a0,1
    50d4:	00001097          	auipc	ra,0x1
    50d8:	da4080e7          	jalr	-604(ra) # 5e78 <exit>
  memset(fa, 0, sizeof(fa));
    50dc:	02800613          	li	a2,40
    50e0:	4581                	li	a1,0
    50e2:	f7040513          	addi	a0,s0,-144
    50e6:	00001097          	auipc	ra,0x1
    50ea:	b70080e7          	jalr	-1168(ra) # 5c56 <memset>
  fd = open(".", 0);
    50ee:	4581                	li	a1,0
    50f0:	00002517          	auipc	a0,0x2
    50f4:	9e050513          	addi	a0,a0,-1568 # 6ad0 <malloc+0x826>
    50f8:	00001097          	auipc	ra,0x1
    50fc:	dc0080e7          	jalr	-576(ra) # 5eb8 <open>
    5100:	892a                	mv	s2,a0
  n = 0;
    5102:	8b26                	mv	s6,s1
  while(read(fd, &de, sizeof(de)) > 0){
    5104:	f6040a13          	addi	s4,s0,-160
    5108:	49c1                	li	s3,16
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    510a:	04300a93          	li	s5,67
      if(i < 0 || i >= sizeof(fa)){
    510e:	02700c13          	li	s8,39
      fa[i] = 1;
    5112:	4c85                	li	s9,1
  while(read(fd, &de, sizeof(de)) > 0){
    5114:	864e                	mv	a2,s3
    5116:	85d2                	mv	a1,s4
    5118:	854a                	mv	a0,s2
    511a:	00001097          	auipc	ra,0x1
    511e:	d76080e7          	jalr	-650(ra) # 5e90 <read>
    5122:	06a05f63          	blez	a0,51a0 <concreate+0x1a0>
    if(de.inum == 0)
    5126:	f6045783          	lhu	a5,-160(s0)
    512a:	d7ed                	beqz	a5,5114 <concreate+0x114>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    512c:	f6244783          	lbu	a5,-158(s0)
    5130:	ff5792e3          	bne	a5,s5,5114 <concreate+0x114>
    5134:	f6444783          	lbu	a5,-156(s0)
    5138:	fff1                	bnez	a5,5114 <concreate+0x114>
      i = de.name[1] - '0';
    513a:	f6344783          	lbu	a5,-157(s0)
    513e:	fd07879b          	addiw	a5,a5,-48
      if(i < 0 || i >= sizeof(fa)){
    5142:	00fc6f63          	bltu	s8,a5,5160 <concreate+0x160>
      if(fa[i]){
    5146:	fa078713          	addi	a4,a5,-96
    514a:	9722                	add	a4,a4,s0
    514c:	fd074703          	lbu	a4,-48(a4) # fd0 <linktest+0x8c>
    5150:	eb05                	bnez	a4,5180 <concreate+0x180>
      fa[i] = 1;
    5152:	fa078793          	addi	a5,a5,-96
    5156:	97a2                	add	a5,a5,s0
    5158:	fd978823          	sb	s9,-48(a5)
      n++;
    515c:	2b05                	addiw	s6,s6,1
    515e:	bf5d                	j	5114 <concreate+0x114>
        printf("%s: concreate weird file %s\n", s, de.name);
    5160:	f6240613          	addi	a2,s0,-158
    5164:	85de                	mv	a1,s7
    5166:	00003517          	auipc	a0,0x3
    516a:	00a50513          	addi	a0,a0,10 # 8170 <malloc+0x1ec6>
    516e:	00001097          	auipc	ra,0x1
    5172:	080080e7          	jalr	128(ra) # 61ee <printf>
        exit(1);
    5176:	4505                	li	a0,1
    5178:	00001097          	auipc	ra,0x1
    517c:	d00080e7          	jalr	-768(ra) # 5e78 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    5180:	f6240613          	addi	a2,s0,-158
    5184:	85de                	mv	a1,s7
    5186:	00003517          	auipc	a0,0x3
    518a:	00a50513          	addi	a0,a0,10 # 8190 <malloc+0x1ee6>
    518e:	00001097          	auipc	ra,0x1
    5192:	060080e7          	jalr	96(ra) # 61ee <printf>
        exit(1);
    5196:	4505                	li	a0,1
    5198:	00001097          	auipc	ra,0x1
    519c:	ce0080e7          	jalr	-800(ra) # 5e78 <exit>
  close(fd);
    51a0:	854a                	mv	a0,s2
    51a2:	00001097          	auipc	ra,0x1
    51a6:	cfe080e7          	jalr	-770(ra) # 5ea0 <close>
  if(n != N){
    51aa:	02800793          	li	a5,40
    51ae:	00fb1b63          	bne	s6,a5,51c4 <concreate+0x1c4>
    if(((i % 3) == 0 && pid == 0) ||
    51b2:	55555a37          	lui	s4,0x55555
    51b6:	556a0a13          	addi	s4,s4,1366 # 55555556 <base+0x555458de>
      close(open(file, 0));
    51ba:	f9840993          	addi	s3,s0,-104
    if(((i % 3) == 0 && pid == 0) ||
    51be:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    51c0:	8abe                	mv	s5,a5
    51c2:	a0d9                	j	5288 <concreate+0x288>
    printf("%s: concreate not enough files in directory listing\n", s);
    51c4:	85de                	mv	a1,s7
    51c6:	00003517          	auipc	a0,0x3
    51ca:	ff250513          	addi	a0,a0,-14 # 81b8 <malloc+0x1f0e>
    51ce:	00001097          	auipc	ra,0x1
    51d2:	020080e7          	jalr	32(ra) # 61ee <printf>
    exit(1);
    51d6:	4505                	li	a0,1
    51d8:	00001097          	auipc	ra,0x1
    51dc:	ca0080e7          	jalr	-864(ra) # 5e78 <exit>
      printf("%s: fork failed\n", s);
    51e0:	85de                	mv	a1,s7
    51e2:	00002517          	auipc	a0,0x2
    51e6:	a8e50513          	addi	a0,a0,-1394 # 6c70 <malloc+0x9c6>
    51ea:	00001097          	auipc	ra,0x1
    51ee:	004080e7          	jalr	4(ra) # 61ee <printf>
      exit(1);
    51f2:	4505                	li	a0,1
    51f4:	00001097          	auipc	ra,0x1
    51f8:	c84080e7          	jalr	-892(ra) # 5e78 <exit>
      close(open(file, 0));
    51fc:	4581                	li	a1,0
    51fe:	854e                	mv	a0,s3
    5200:	00001097          	auipc	ra,0x1
    5204:	cb8080e7          	jalr	-840(ra) # 5eb8 <open>
    5208:	00001097          	auipc	ra,0x1
    520c:	c98080e7          	jalr	-872(ra) # 5ea0 <close>
      close(open(file, 0));
    5210:	4581                	li	a1,0
    5212:	854e                	mv	a0,s3
    5214:	00001097          	auipc	ra,0x1
    5218:	ca4080e7          	jalr	-860(ra) # 5eb8 <open>
    521c:	00001097          	auipc	ra,0x1
    5220:	c84080e7          	jalr	-892(ra) # 5ea0 <close>
      close(open(file, 0));
    5224:	4581                	li	a1,0
    5226:	854e                	mv	a0,s3
    5228:	00001097          	auipc	ra,0x1
    522c:	c90080e7          	jalr	-880(ra) # 5eb8 <open>
    5230:	00001097          	auipc	ra,0x1
    5234:	c70080e7          	jalr	-912(ra) # 5ea0 <close>
      close(open(file, 0));
    5238:	4581                	li	a1,0
    523a:	854e                	mv	a0,s3
    523c:	00001097          	auipc	ra,0x1
    5240:	c7c080e7          	jalr	-900(ra) # 5eb8 <open>
    5244:	00001097          	auipc	ra,0x1
    5248:	c5c080e7          	jalr	-932(ra) # 5ea0 <close>
      close(open(file, 0));
    524c:	4581                	li	a1,0
    524e:	854e                	mv	a0,s3
    5250:	00001097          	auipc	ra,0x1
    5254:	c68080e7          	jalr	-920(ra) # 5eb8 <open>
    5258:	00001097          	auipc	ra,0x1
    525c:	c48080e7          	jalr	-952(ra) # 5ea0 <close>
      close(open(file, 0));
    5260:	4581                	li	a1,0
    5262:	854e                	mv	a0,s3
    5264:	00001097          	auipc	ra,0x1
    5268:	c54080e7          	jalr	-940(ra) # 5eb8 <open>
    526c:	00001097          	auipc	ra,0x1
    5270:	c34080e7          	jalr	-972(ra) # 5ea0 <close>
    if(pid == 0)
    5274:	08090663          	beqz	s2,5300 <concreate+0x300>
      wait(0);
    5278:	4501                	li	a0,0
    527a:	00001097          	auipc	ra,0x1
    527e:	c06080e7          	jalr	-1018(ra) # 5e80 <wait>
  for(i = 0; i < N; i++){
    5282:	2485                	addiw	s1,s1,1
    5284:	0f548d63          	beq	s1,s5,537e <concreate+0x37e>
    file[1] = '0' + i;
    5288:	0304879b          	addiw	a5,s1,48
    528c:	f8f40ca3          	sb	a5,-103(s0)
    pid = fork();
    5290:	00001097          	auipc	ra,0x1
    5294:	be0080e7          	jalr	-1056(ra) # 5e70 <fork>
    5298:	892a                	mv	s2,a0
    if(pid < 0){
    529a:	f40543e3          	bltz	a0,51e0 <concreate+0x1e0>
    if(((i % 3) == 0 && pid == 0) ||
    529e:	03448733          	mul	a4,s1,s4
    52a2:	9301                	srli	a4,a4,0x20
    52a4:	41f4d79b          	sraiw	a5,s1,0x1f
    52a8:	9f1d                	subw	a4,a4,a5
    52aa:	0017179b          	slliw	a5,a4,0x1
    52ae:	9fb9                	addw	a5,a5,a4
    52b0:	40f487bb          	subw	a5,s1,a5
    52b4:	873e                	mv	a4,a5
    52b6:	8fc9                	or	a5,a5,a0
    52b8:	2781                	sext.w	a5,a5
    52ba:	d3a9                	beqz	a5,51fc <concreate+0x1fc>
    52bc:	01671363          	bne	a4,s6,52c2 <concreate+0x2c2>
       ((i % 3) == 1 && pid != 0)){
    52c0:	fd15                	bnez	a0,51fc <concreate+0x1fc>
      unlink(file);
    52c2:	854e                	mv	a0,s3
    52c4:	00001097          	auipc	ra,0x1
    52c8:	c04080e7          	jalr	-1020(ra) # 5ec8 <unlink>
      unlink(file);
    52cc:	854e                	mv	a0,s3
    52ce:	00001097          	auipc	ra,0x1
    52d2:	bfa080e7          	jalr	-1030(ra) # 5ec8 <unlink>
      unlink(file);
    52d6:	854e                	mv	a0,s3
    52d8:	00001097          	auipc	ra,0x1
    52dc:	bf0080e7          	jalr	-1040(ra) # 5ec8 <unlink>
      unlink(file);
    52e0:	854e                	mv	a0,s3
    52e2:	00001097          	auipc	ra,0x1
    52e6:	be6080e7          	jalr	-1050(ra) # 5ec8 <unlink>
      unlink(file);
    52ea:	854e                	mv	a0,s3
    52ec:	00001097          	auipc	ra,0x1
    52f0:	bdc080e7          	jalr	-1060(ra) # 5ec8 <unlink>
      unlink(file);
    52f4:	854e                	mv	a0,s3
    52f6:	00001097          	auipc	ra,0x1
    52fa:	bd2080e7          	jalr	-1070(ra) # 5ec8 <unlink>
    52fe:	bf9d                	j	5274 <concreate+0x274>
      exit(0);
    5300:	4501                	li	a0,0
    5302:	00001097          	auipc	ra,0x1
    5306:	b76080e7          	jalr	-1162(ra) # 5e78 <exit>
      close(fd);
    530a:	00001097          	auipc	ra,0x1
    530e:	b96080e7          	jalr	-1130(ra) # 5ea0 <close>
    if(pid == 0) {
    5312:	bb5d                	j	50c8 <concreate+0xc8>
      close(fd);
    5314:	00001097          	auipc	ra,0x1
    5318:	b8c080e7          	jalr	-1140(ra) # 5ea0 <close>
      wait(&xstatus);
    531c:	8556                	mv	a0,s5
    531e:	00001097          	auipc	ra,0x1
    5322:	b62080e7          	jalr	-1182(ra) # 5e80 <wait>
      if(xstatus != 0)
    5326:	f5c42483          	lw	s1,-164(s0)
    532a:	da0494e3          	bnez	s1,50d2 <concreate+0xd2>
  for(i = 0; i < N; i++){
    532e:	2905                	addiw	s2,s2,1
    5330:	db4906e3          	beq	s2,s4,50dc <concreate+0xdc>
    file[1] = '0' + i;
    5334:	0309079b          	addiw	a5,s2,48
    5338:	f8f40ca3          	sb	a5,-103(s0)
    unlink(file);
    533c:	854e                	mv	a0,s3
    533e:	00001097          	auipc	ra,0x1
    5342:	b8a080e7          	jalr	-1142(ra) # 5ec8 <unlink>
    pid = fork();
    5346:	00001097          	auipc	ra,0x1
    534a:	b2a080e7          	jalr	-1238(ra) # 5e70 <fork>
    if(pid && (i % 3) == 1){
    534e:	d00508e3          	beqz	a0,505e <concreate+0x5e>
    5352:	036907b3          	mul	a5,s2,s6
    5356:	9381                	srli	a5,a5,0x20
    5358:	41f9571b          	sraiw	a4,s2,0x1f
    535c:	9f99                	subw	a5,a5,a4
    535e:	0017971b          	slliw	a4,a5,0x1
    5362:	9fb9                	addw	a5,a5,a4
    5364:	40f907bb          	subw	a5,s2,a5
    5368:	cf8784e3          	beq	a5,s8,5050 <concreate+0x50>
      fd = open(file, O_CREATE | O_RDWR);
    536c:	85e6                	mv	a1,s9
    536e:	854e                	mv	a0,s3
    5370:	00001097          	auipc	ra,0x1
    5374:	b48080e7          	jalr	-1208(ra) # 5eb8 <open>
      if(fd < 0){
    5378:	f8055ee3          	bgez	a0,5314 <concreate+0x314>
    537c:	bb29                	j	5096 <concreate+0x96>
}
    537e:	70aa                	ld	ra,168(sp)
    5380:	740a                	ld	s0,160(sp)
    5382:	64ea                	ld	s1,152(sp)
    5384:	694a                	ld	s2,144(sp)
    5386:	69aa                	ld	s3,136(sp)
    5388:	6a0a                	ld	s4,128(sp)
    538a:	7ae6                	ld	s5,120(sp)
    538c:	7b46                	ld	s6,112(sp)
    538e:	7ba6                	ld	s7,104(sp)
    5390:	7c06                	ld	s8,96(sp)
    5392:	6ce6                	ld	s9,88(sp)
    5394:	6d46                	ld	s10,80(sp)
    5396:	614d                	addi	sp,sp,176
    5398:	8082                	ret

000000000000539a <bigfile>:
{
    539a:	7139                	addi	sp,sp,-64
    539c:	fc06                	sd	ra,56(sp)
    539e:	f822                	sd	s0,48(sp)
    53a0:	f426                	sd	s1,40(sp)
    53a2:	f04a                	sd	s2,32(sp)
    53a4:	ec4e                	sd	s3,24(sp)
    53a6:	e852                	sd	s4,16(sp)
    53a8:	e456                	sd	s5,8(sp)
    53aa:	e05a                	sd	s6,0(sp)
    53ac:	0080                	addi	s0,sp,64
    53ae:	8b2a                	mv	s6,a0
  unlink("bigfile.dat");
    53b0:	00003517          	auipc	a0,0x3
    53b4:	e4050513          	addi	a0,a0,-448 # 81f0 <malloc+0x1f46>
    53b8:	00001097          	auipc	ra,0x1
    53bc:	b10080e7          	jalr	-1264(ra) # 5ec8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    53c0:	20200593          	li	a1,514
    53c4:	00003517          	auipc	a0,0x3
    53c8:	e2c50513          	addi	a0,a0,-468 # 81f0 <malloc+0x1f46>
    53cc:	00001097          	auipc	ra,0x1
    53d0:	aec080e7          	jalr	-1300(ra) # 5eb8 <open>
  if(fd < 0){
    53d4:	0a054463          	bltz	a0,547c <bigfile+0xe2>
    53d8:	8a2a                	mv	s4,a0
    53da:	4481                	li	s1,0
    memset(buf, i, SZ);
    53dc:	25800913          	li	s2,600
    53e0:	00008997          	auipc	s3,0x8
    53e4:	89898993          	addi	s3,s3,-1896 # cc78 <buf>
  for(i = 0; i < N; i++){
    53e8:	4ad1                	li	s5,20
    memset(buf, i, SZ);
    53ea:	864a                	mv	a2,s2
    53ec:	85a6                	mv	a1,s1
    53ee:	854e                	mv	a0,s3
    53f0:	00001097          	auipc	ra,0x1
    53f4:	866080e7          	jalr	-1946(ra) # 5c56 <memset>
    if(write(fd, buf, SZ) != SZ){
    53f8:	864a                	mv	a2,s2
    53fa:	85ce                	mv	a1,s3
    53fc:	8552                	mv	a0,s4
    53fe:	00001097          	auipc	ra,0x1
    5402:	a9a080e7          	jalr	-1382(ra) # 5e98 <write>
    5406:	09251963          	bne	a0,s2,5498 <bigfile+0xfe>
  for(i = 0; i < N; i++){
    540a:	2485                	addiw	s1,s1,1
    540c:	fd549fe3          	bne	s1,s5,53ea <bigfile+0x50>
  close(fd);
    5410:	8552                	mv	a0,s4
    5412:	00001097          	auipc	ra,0x1
    5416:	a8e080e7          	jalr	-1394(ra) # 5ea0 <close>
  fd = open("bigfile.dat", 0);
    541a:	4581                	li	a1,0
    541c:	00003517          	auipc	a0,0x3
    5420:	dd450513          	addi	a0,a0,-556 # 81f0 <malloc+0x1f46>
    5424:	00001097          	auipc	ra,0x1
    5428:	a94080e7          	jalr	-1388(ra) # 5eb8 <open>
    542c:	8aaa                	mv	s5,a0
  total = 0;
    542e:	4a01                	li	s4,0
  for(i = 0; ; i++){
    5430:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    5432:	12c00993          	li	s3,300
    5436:	00008917          	auipc	s2,0x8
    543a:	84290913          	addi	s2,s2,-1982 # cc78 <buf>
  if(fd < 0){
    543e:	06054b63          	bltz	a0,54b4 <bigfile+0x11a>
    cc = read(fd, buf, SZ/2);
    5442:	864e                	mv	a2,s3
    5444:	85ca                	mv	a1,s2
    5446:	8556                	mv	a0,s5
    5448:	00001097          	auipc	ra,0x1
    544c:	a48080e7          	jalr	-1464(ra) # 5e90 <read>
    if(cc < 0){
    5450:	08054063          	bltz	a0,54d0 <bigfile+0x136>
    if(cc == 0)
    5454:	c961                	beqz	a0,5524 <bigfile+0x18a>
    if(cc != SZ/2){
    5456:	09351b63          	bne	a0,s3,54ec <bigfile+0x152>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    545a:	01f4d79b          	srliw	a5,s1,0x1f
    545e:	9fa5                	addw	a5,a5,s1
    5460:	4017d79b          	sraiw	a5,a5,0x1
    5464:	00094703          	lbu	a4,0(s2)
    5468:	0af71063          	bne	a4,a5,5508 <bigfile+0x16e>
    546c:	12b94703          	lbu	a4,299(s2)
    5470:	08f71c63          	bne	a4,a5,5508 <bigfile+0x16e>
    total += cc;
    5474:	12ca0a1b          	addiw	s4,s4,300
  for(i = 0; ; i++){
    5478:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    547a:	b7e1                	j	5442 <bigfile+0xa8>
    printf("%s: cannot create bigfile", s);
    547c:	85da                	mv	a1,s6
    547e:	00003517          	auipc	a0,0x3
    5482:	d8250513          	addi	a0,a0,-638 # 8200 <malloc+0x1f56>
    5486:	00001097          	auipc	ra,0x1
    548a:	d68080e7          	jalr	-664(ra) # 61ee <printf>
    exit(1);
    548e:	4505                	li	a0,1
    5490:	00001097          	auipc	ra,0x1
    5494:	9e8080e7          	jalr	-1560(ra) # 5e78 <exit>
      printf("%s: write bigfile failed\n", s);
    5498:	85da                	mv	a1,s6
    549a:	00003517          	auipc	a0,0x3
    549e:	d8650513          	addi	a0,a0,-634 # 8220 <malloc+0x1f76>
    54a2:	00001097          	auipc	ra,0x1
    54a6:	d4c080e7          	jalr	-692(ra) # 61ee <printf>
      exit(1);
    54aa:	4505                	li	a0,1
    54ac:	00001097          	auipc	ra,0x1
    54b0:	9cc080e7          	jalr	-1588(ra) # 5e78 <exit>
    printf("%s: cannot open bigfile\n", s);
    54b4:	85da                	mv	a1,s6
    54b6:	00003517          	auipc	a0,0x3
    54ba:	d8a50513          	addi	a0,a0,-630 # 8240 <malloc+0x1f96>
    54be:	00001097          	auipc	ra,0x1
    54c2:	d30080e7          	jalr	-720(ra) # 61ee <printf>
    exit(1);
    54c6:	4505                	li	a0,1
    54c8:	00001097          	auipc	ra,0x1
    54cc:	9b0080e7          	jalr	-1616(ra) # 5e78 <exit>
      printf("%s: read bigfile failed\n", s);
    54d0:	85da                	mv	a1,s6
    54d2:	00003517          	auipc	a0,0x3
    54d6:	d8e50513          	addi	a0,a0,-626 # 8260 <malloc+0x1fb6>
    54da:	00001097          	auipc	ra,0x1
    54de:	d14080e7          	jalr	-748(ra) # 61ee <printf>
      exit(1);
    54e2:	4505                	li	a0,1
    54e4:	00001097          	auipc	ra,0x1
    54e8:	994080e7          	jalr	-1644(ra) # 5e78 <exit>
      printf("%s: short read bigfile\n", s);
    54ec:	85da                	mv	a1,s6
    54ee:	00003517          	auipc	a0,0x3
    54f2:	d9250513          	addi	a0,a0,-622 # 8280 <malloc+0x1fd6>
    54f6:	00001097          	auipc	ra,0x1
    54fa:	cf8080e7          	jalr	-776(ra) # 61ee <printf>
      exit(1);
    54fe:	4505                	li	a0,1
    5500:	00001097          	auipc	ra,0x1
    5504:	978080e7          	jalr	-1672(ra) # 5e78 <exit>
      printf("%s: read bigfile wrong data\n", s);
    5508:	85da                	mv	a1,s6
    550a:	00003517          	auipc	a0,0x3
    550e:	d8e50513          	addi	a0,a0,-626 # 8298 <malloc+0x1fee>
    5512:	00001097          	auipc	ra,0x1
    5516:	cdc080e7          	jalr	-804(ra) # 61ee <printf>
      exit(1);
    551a:	4505                	li	a0,1
    551c:	00001097          	auipc	ra,0x1
    5520:	95c080e7          	jalr	-1700(ra) # 5e78 <exit>
  close(fd);
    5524:	8556                	mv	a0,s5
    5526:	00001097          	auipc	ra,0x1
    552a:	97a080e7          	jalr	-1670(ra) # 5ea0 <close>
  if(total != N*SZ){
    552e:	678d                	lui	a5,0x3
    5530:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrkbugs+0x6a>
    5534:	02fa1463          	bne	s4,a5,555c <bigfile+0x1c2>
  unlink("bigfile.dat");
    5538:	00003517          	auipc	a0,0x3
    553c:	cb850513          	addi	a0,a0,-840 # 81f0 <malloc+0x1f46>
    5540:	00001097          	auipc	ra,0x1
    5544:	988080e7          	jalr	-1656(ra) # 5ec8 <unlink>
}
    5548:	70e2                	ld	ra,56(sp)
    554a:	7442                	ld	s0,48(sp)
    554c:	74a2                	ld	s1,40(sp)
    554e:	7902                	ld	s2,32(sp)
    5550:	69e2                	ld	s3,24(sp)
    5552:	6a42                	ld	s4,16(sp)
    5554:	6aa2                	ld	s5,8(sp)
    5556:	6b02                	ld	s6,0(sp)
    5558:	6121                	addi	sp,sp,64
    555a:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    555c:	85da                	mv	a1,s6
    555e:	00003517          	auipc	a0,0x3
    5562:	d5a50513          	addi	a0,a0,-678 # 82b8 <malloc+0x200e>
    5566:	00001097          	auipc	ra,0x1
    556a:	c88080e7          	jalr	-888(ra) # 61ee <printf>
    exit(1);
    556e:	4505                	li	a0,1
    5570:	00001097          	auipc	ra,0x1
    5574:	908080e7          	jalr	-1784(ra) # 5e78 <exit>

0000000000005578 <fsfull>:
{
    5578:	7171                	addi	sp,sp,-176
    557a:	f506                	sd	ra,168(sp)
    557c:	f122                	sd	s0,160(sp)
    557e:	ed26                	sd	s1,152(sp)
    5580:	e94a                	sd	s2,144(sp)
    5582:	e54e                	sd	s3,136(sp)
    5584:	e152                	sd	s4,128(sp)
    5586:	fcd6                	sd	s5,120(sp)
    5588:	f8da                	sd	s6,112(sp)
    558a:	f4de                	sd	s7,104(sp)
    558c:	f0e2                	sd	s8,96(sp)
    558e:	ece6                	sd	s9,88(sp)
    5590:	e8ea                	sd	s10,80(sp)
    5592:	e4ee                	sd	s11,72(sp)
    5594:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    5596:	00003517          	auipc	a0,0x3
    559a:	d4250513          	addi	a0,a0,-702 # 82d8 <malloc+0x202e>
    559e:	00001097          	auipc	ra,0x1
    55a2:	c50080e7          	jalr	-944(ra) # 61ee <printf>
  for(nfiles = 0; ; nfiles++){
    55a6:	4481                	li	s1,0
    name[0] = 'f';
    55a8:	06600d93          	li	s11,102
    name[1] = '0' + nfiles / 1000;
    55ac:	10625cb7          	lui	s9,0x10625
    55b0:	dd3c8c93          	addi	s9,s9,-557 # 10624dd3 <base+0x1061515b>
    name[2] = '0' + (nfiles % 1000) / 100;
    55b4:	51eb8ab7          	lui	s5,0x51eb8
    55b8:	51fa8a93          	addi	s5,s5,1311 # 51eb851f <base+0x51ea88a7>
    name[3] = '0' + (nfiles % 100) / 10;
    55bc:	66666a37          	lui	s4,0x66666
    55c0:	667a0a13          	addi	s4,s4,1639 # 66666667 <base+0x666569ef>
    printf("writing %s\n", name);
    55c4:	f5040d13          	addi	s10,s0,-176
    name[0] = 'f';
    55c8:	f5b40823          	sb	s11,-176(s0)
    name[1] = '0' + nfiles / 1000;
    55cc:	039487b3          	mul	a5,s1,s9
    55d0:	9799                	srai	a5,a5,0x26
    55d2:	41f4d69b          	sraiw	a3,s1,0x1f
    55d6:	9f95                	subw	a5,a5,a3
    55d8:	0307871b          	addiw	a4,a5,48
    55dc:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    55e0:	3e800713          	li	a4,1000
    55e4:	02f707bb          	mulw	a5,a4,a5
    55e8:	40f487bb          	subw	a5,s1,a5
    55ec:	03578733          	mul	a4,a5,s5
    55f0:	9715                	srai	a4,a4,0x25
    55f2:	41f7d79b          	sraiw	a5,a5,0x1f
    55f6:	40f707bb          	subw	a5,a4,a5
    55fa:	0307879b          	addiw	a5,a5,48
    55fe:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5602:	035487b3          	mul	a5,s1,s5
    5606:	9795                	srai	a5,a5,0x25
    5608:	9f95                	subw	a5,a5,a3
    560a:	06400713          	li	a4,100
    560e:	02f707bb          	mulw	a5,a4,a5
    5612:	40f487bb          	subw	a5,s1,a5
    5616:	03478733          	mul	a4,a5,s4
    561a:	9709                	srai	a4,a4,0x22
    561c:	41f7d79b          	sraiw	a5,a5,0x1f
    5620:	40f707bb          	subw	a5,a4,a5
    5624:	0307879b          	addiw	a5,a5,48
    5628:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    562c:	03448733          	mul	a4,s1,s4
    5630:	9709                	srai	a4,a4,0x22
    5632:	9f15                	subw	a4,a4,a3
    5634:	0027179b          	slliw	a5,a4,0x2
    5638:	9fb9                	addw	a5,a5,a4
    563a:	0017979b          	slliw	a5,a5,0x1
    563e:	40f487bb          	subw	a5,s1,a5
    5642:	0307879b          	addiw	a5,a5,48
    5646:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    564a:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    564e:	85ea                	mv	a1,s10
    5650:	00003517          	auipc	a0,0x3
    5654:	c9850513          	addi	a0,a0,-872 # 82e8 <malloc+0x203e>
    5658:	00001097          	auipc	ra,0x1
    565c:	b96080e7          	jalr	-1130(ra) # 61ee <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    5660:	20200593          	li	a1,514
    5664:	856a                	mv	a0,s10
    5666:	00001097          	auipc	ra,0x1
    566a:	852080e7          	jalr	-1966(ra) # 5eb8 <open>
    566e:	892a                	mv	s2,a0
    if(fd < 0){
    5670:	0e055e63          	bgez	a0,576c <fsfull+0x1f4>
      printf("open %s failed\n", name);
    5674:	f5040593          	addi	a1,s0,-176
    5678:	00003517          	auipc	a0,0x3
    567c:	c8050513          	addi	a0,a0,-896 # 82f8 <malloc+0x204e>
    5680:	00001097          	auipc	ra,0x1
    5684:	b6e080e7          	jalr	-1170(ra) # 61ee <printf>
    name[0] = 'f';
    5688:	06600c13          	li	s8,102
    name[1] = '0' + nfiles / 1000;
    568c:	10625a37          	lui	s4,0x10625
    5690:	dd3a0a13          	addi	s4,s4,-557 # 10624dd3 <base+0x1061515b>
    name[2] = '0' + (nfiles % 1000) / 100;
    5694:	3e800b93          	li	s7,1000
    5698:	51eb89b7          	lui	s3,0x51eb8
    569c:	51f98993          	addi	s3,s3,1311 # 51eb851f <base+0x51ea88a7>
    name[3] = '0' + (nfiles % 100) / 10;
    56a0:	06400b13          	li	s6,100
    56a4:	66666937          	lui	s2,0x66666
    56a8:	66790913          	addi	s2,s2,1639 # 66666667 <base+0x666569ef>
    unlink(name);
    56ac:	f5040a93          	addi	s5,s0,-176
    name[0] = 'f';
    56b0:	f5840823          	sb	s8,-176(s0)
    name[1] = '0' + nfiles / 1000;
    56b4:	034487b3          	mul	a5,s1,s4
    56b8:	9799                	srai	a5,a5,0x26
    56ba:	41f4d69b          	sraiw	a3,s1,0x1f
    56be:	9f95                	subw	a5,a5,a3
    56c0:	0307871b          	addiw	a4,a5,48
    56c4:	f4e408a3          	sb	a4,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    56c8:	02fb87bb          	mulw	a5,s7,a5
    56cc:	40f487bb          	subw	a5,s1,a5
    56d0:	03378733          	mul	a4,a5,s3
    56d4:	9715                	srai	a4,a4,0x25
    56d6:	41f7d79b          	sraiw	a5,a5,0x1f
    56da:	40f707bb          	subw	a5,a4,a5
    56de:	0307879b          	addiw	a5,a5,48
    56e2:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    56e6:	033487b3          	mul	a5,s1,s3
    56ea:	9795                	srai	a5,a5,0x25
    56ec:	9f95                	subw	a5,a5,a3
    56ee:	02fb07bb          	mulw	a5,s6,a5
    56f2:	40f487bb          	subw	a5,s1,a5
    56f6:	03278733          	mul	a4,a5,s2
    56fa:	9709                	srai	a4,a4,0x22
    56fc:	41f7d79b          	sraiw	a5,a5,0x1f
    5700:	40f707bb          	subw	a5,a4,a5
    5704:	0307879b          	addiw	a5,a5,48
    5708:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    570c:	03248733          	mul	a4,s1,s2
    5710:	9709                	srai	a4,a4,0x22
    5712:	9f15                	subw	a4,a4,a3
    5714:	0027179b          	slliw	a5,a4,0x2
    5718:	9fb9                	addw	a5,a5,a4
    571a:	0017979b          	slliw	a5,a5,0x1
    571e:	40f487bb          	subw	a5,s1,a5
    5722:	0307879b          	addiw	a5,a5,48
    5726:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    572a:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    572e:	8556                	mv	a0,s5
    5730:	00000097          	auipc	ra,0x0
    5734:	798080e7          	jalr	1944(ra) # 5ec8 <unlink>
    nfiles--;
    5738:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    573a:	f604dbe3          	bgez	s1,56b0 <fsfull+0x138>
  printf("fsfull test finished\n");
    573e:	00003517          	auipc	a0,0x3
    5742:	bda50513          	addi	a0,a0,-1062 # 8318 <malloc+0x206e>
    5746:	00001097          	auipc	ra,0x1
    574a:	aa8080e7          	jalr	-1368(ra) # 61ee <printf>
}
    574e:	70aa                	ld	ra,168(sp)
    5750:	740a                	ld	s0,160(sp)
    5752:	64ea                	ld	s1,152(sp)
    5754:	694a                	ld	s2,144(sp)
    5756:	69aa                	ld	s3,136(sp)
    5758:	6a0a                	ld	s4,128(sp)
    575a:	7ae6                	ld	s5,120(sp)
    575c:	7b46                	ld	s6,112(sp)
    575e:	7ba6                	ld	s7,104(sp)
    5760:	7c06                	ld	s8,96(sp)
    5762:	6ce6                	ld	s9,88(sp)
    5764:	6d46                	ld	s10,80(sp)
    5766:	6da6                	ld	s11,72(sp)
    5768:	614d                	addi	sp,sp,176
    576a:	8082                	ret
    int total = 0;
    576c:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    576e:	40000c13          	li	s8,1024
    5772:	00007b97          	auipc	s7,0x7
    5776:	506b8b93          	addi	s7,s7,1286 # cc78 <buf>
      if(cc < BSIZE)
    577a:	3ff00b13          	li	s6,1023
      int cc = write(fd, buf, BSIZE);
    577e:	8662                	mv	a2,s8
    5780:	85de                	mv	a1,s7
    5782:	854a                	mv	a0,s2
    5784:	00000097          	auipc	ra,0x0
    5788:	714080e7          	jalr	1812(ra) # 5e98 <write>
      if(cc < BSIZE)
    578c:	00ab5563          	bge	s6,a0,5796 <fsfull+0x21e>
      total += cc;
    5790:	00a989bb          	addw	s3,s3,a0
    while(1){
    5794:	b7ed                	j	577e <fsfull+0x206>
    printf("wrote %d bytes\n", total);
    5796:	85ce                	mv	a1,s3
    5798:	00003517          	auipc	a0,0x3
    579c:	b7050513          	addi	a0,a0,-1168 # 8308 <malloc+0x205e>
    57a0:	00001097          	auipc	ra,0x1
    57a4:	a4e080e7          	jalr	-1458(ra) # 61ee <printf>
    close(fd);
    57a8:	854a                	mv	a0,s2
    57aa:	00000097          	auipc	ra,0x0
    57ae:	6f6080e7          	jalr	1782(ra) # 5ea0 <close>
    if(total == 0)
    57b2:	ec098be3          	beqz	s3,5688 <fsfull+0x110>
  for(nfiles = 0; ; nfiles++){
    57b6:	2485                	addiw	s1,s1,1
    57b8:	bd01                	j	55c8 <fsfull+0x50>

00000000000057ba <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    57ba:	7179                	addi	sp,sp,-48
    57bc:	f406                	sd	ra,40(sp)
    57be:	f022                	sd	s0,32(sp)
    57c0:	ec26                	sd	s1,24(sp)
    57c2:	e84a                	sd	s2,16(sp)
    57c4:	1800                	addi	s0,sp,48
    57c6:	84aa                	mv	s1,a0
    57c8:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    57ca:	00003517          	auipc	a0,0x3
    57ce:	b6650513          	addi	a0,a0,-1178 # 8330 <malloc+0x2086>
    57d2:	00001097          	auipc	ra,0x1
    57d6:	a1c080e7          	jalr	-1508(ra) # 61ee <printf>
  if((pid = fork()) < 0) {
    57da:	00000097          	auipc	ra,0x0
    57de:	696080e7          	jalr	1686(ra) # 5e70 <fork>
    57e2:	02054e63          	bltz	a0,581e <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    57e6:	c929                	beqz	a0,5838 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    57e8:	fdc40513          	addi	a0,s0,-36
    57ec:	00000097          	auipc	ra,0x0
    57f0:	694080e7          	jalr	1684(ra) # 5e80 <wait>
    if(xstatus != 0) 
    57f4:	fdc42783          	lw	a5,-36(s0)
    57f8:	c7b9                	beqz	a5,5846 <run+0x8c>
      printf("FAILED\n");
    57fa:	00003517          	auipc	a0,0x3
    57fe:	b5e50513          	addi	a0,a0,-1186 # 8358 <malloc+0x20ae>
    5802:	00001097          	auipc	ra,0x1
    5806:	9ec080e7          	jalr	-1556(ra) # 61ee <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    580a:	fdc42503          	lw	a0,-36(s0)
  }
}
    580e:	00153513          	seqz	a0,a0
    5812:	70a2                	ld	ra,40(sp)
    5814:	7402                	ld	s0,32(sp)
    5816:	64e2                	ld	s1,24(sp)
    5818:	6942                	ld	s2,16(sp)
    581a:	6145                	addi	sp,sp,48
    581c:	8082                	ret
    printf("runtest: fork error\n");
    581e:	00003517          	auipc	a0,0x3
    5822:	b2250513          	addi	a0,a0,-1246 # 8340 <malloc+0x2096>
    5826:	00001097          	auipc	ra,0x1
    582a:	9c8080e7          	jalr	-1592(ra) # 61ee <printf>
    exit(1);
    582e:	4505                	li	a0,1
    5830:	00000097          	auipc	ra,0x0
    5834:	648080e7          	jalr	1608(ra) # 5e78 <exit>
    f(s);
    5838:	854a                	mv	a0,s2
    583a:	9482                	jalr	s1
    exit(0);
    583c:	4501                	li	a0,0
    583e:	00000097          	auipc	ra,0x0
    5842:	63a080e7          	jalr	1594(ra) # 5e78 <exit>
      printf("OK\n");
    5846:	00003517          	auipc	a0,0x3
    584a:	b1a50513          	addi	a0,a0,-1254 # 8360 <malloc+0x20b6>
    584e:	00001097          	auipc	ra,0x1
    5852:	9a0080e7          	jalr	-1632(ra) # 61ee <printf>
    5856:	bf55                	j	580a <run+0x50>

0000000000005858 <runtests>:

int
runtests(struct test *tests, char *justone) {
    5858:	1101                	addi	sp,sp,-32
    585a:	ec06                	sd	ra,24(sp)
    585c:	e822                	sd	s0,16(sp)
    585e:	e426                	sd	s1,8(sp)
    5860:	e04a                	sd	s2,0(sp)
    5862:	1000                	addi	s0,sp,32
    5864:	84aa                	mv	s1,a0
    5866:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    5868:	6508                	ld	a0,8(a0)
    586a:	ed09                	bnez	a0,5884 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    586c:	4501                	li	a0,0
    586e:	a82d                	j	58a8 <runtests+0x50>
      if(!run(t->f, t->s)){
    5870:	648c                	ld	a1,8(s1)
    5872:	6088                	ld	a0,0(s1)
    5874:	00000097          	auipc	ra,0x0
    5878:	f46080e7          	jalr	-186(ra) # 57ba <run>
    587c:	cd09                	beqz	a0,5896 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    587e:	04c1                	addi	s1,s1,16
    5880:	6488                	ld	a0,8(s1)
    5882:	c11d                	beqz	a0,58a8 <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5884:	fe0906e3          	beqz	s2,5870 <runtests+0x18>
    5888:	85ca                	mv	a1,s2
    588a:	00000097          	auipc	ra,0x0
    588e:	36e080e7          	jalr	878(ra) # 5bf8 <strcmp>
    5892:	f575                	bnez	a0,587e <runtests+0x26>
    5894:	bff1                	j	5870 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    5896:	00003517          	auipc	a0,0x3
    589a:	ad250513          	addi	a0,a0,-1326 # 8368 <malloc+0x20be>
    589e:	00001097          	auipc	ra,0x1
    58a2:	950080e7          	jalr	-1712(ra) # 61ee <printf>
        return 1;
    58a6:	4505                	li	a0,1
}
    58a8:	60e2                	ld	ra,24(sp)
    58aa:	6442                	ld	s0,16(sp)
    58ac:	64a2                	ld	s1,8(sp)
    58ae:	6902                	ld	s2,0(sp)
    58b0:	6105                	addi	sp,sp,32
    58b2:	8082                	ret

00000000000058b4 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    58b4:	7139                	addi	sp,sp,-64
    58b6:	fc06                	sd	ra,56(sp)
    58b8:	f822                	sd	s0,48(sp)
    58ba:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    58bc:	fc840513          	addi	a0,s0,-56
    58c0:	00000097          	auipc	ra,0x0
    58c4:	5c8080e7          	jalr	1480(ra) # 5e88 <pipe>
    58c8:	06054b63          	bltz	a0,593e <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    58cc:	00000097          	auipc	ra,0x0
    58d0:	5a4080e7          	jalr	1444(ra) # 5e70 <fork>

  if(pid < 0){
    58d4:	08054663          	bltz	a0,5960 <countfree+0xac>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    58d8:	e955                	bnez	a0,598c <countfree+0xd8>
    58da:	f426                	sd	s1,40(sp)
    58dc:	f04a                	sd	s2,32(sp)
    58de:	ec4e                	sd	s3,24(sp)
    58e0:	e852                	sd	s4,16(sp)
    close(fds[0]);
    58e2:	fc842503          	lw	a0,-56(s0)
    58e6:	00000097          	auipc	ra,0x0
    58ea:	5ba080e7          	jalr	1466(ra) # 5ea0 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
    58ee:	6905                	lui	s2,0x1
      if(a == 0xffffffffffffffff){
    58f0:	59fd                	li	s3,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    58f2:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    58f4:	00001a17          	auipc	s4,0x1
    58f8:	b64a0a13          	addi	s4,s4,-1180 # 6458 <malloc+0x1ae>
      uint64 a = (uint64) sbrk(4096);
    58fc:	854a                	mv	a0,s2
    58fe:	00000097          	auipc	ra,0x0
    5902:	602080e7          	jalr	1538(ra) # 5f00 <sbrk>
      if(a == 0xffffffffffffffff){
    5906:	07350e63          	beq	a0,s3,5982 <countfree+0xce>
      *(char *)(a + 4096 - 1) = 1;
    590a:	954a                	add	a0,a0,s2
    590c:	fe950fa3          	sb	s1,-1(a0)
      if(write(fds[1], "x", 1) != 1){
    5910:	8626                	mv	a2,s1
    5912:	85d2                	mv	a1,s4
    5914:	fcc42503          	lw	a0,-52(s0)
    5918:	00000097          	auipc	ra,0x0
    591c:	580080e7          	jalr	1408(ra) # 5e98 <write>
    5920:	fc950ee3          	beq	a0,s1,58fc <countfree+0x48>
        printf("write() failed in countfree()\n");
    5924:	00003517          	auipc	a0,0x3
    5928:	a9c50513          	addi	a0,a0,-1380 # 83c0 <malloc+0x2116>
    592c:	00001097          	auipc	ra,0x1
    5930:	8c2080e7          	jalr	-1854(ra) # 61ee <printf>
        exit(1);
    5934:	4505                	li	a0,1
    5936:	00000097          	auipc	ra,0x0
    593a:	542080e7          	jalr	1346(ra) # 5e78 <exit>
    593e:	f426                	sd	s1,40(sp)
    5940:	f04a                	sd	s2,32(sp)
    5942:	ec4e                	sd	s3,24(sp)
    5944:	e852                	sd	s4,16(sp)
    printf("pipe() failed in countfree()\n");
    5946:	00003517          	auipc	a0,0x3
    594a:	a3a50513          	addi	a0,a0,-1478 # 8380 <malloc+0x20d6>
    594e:	00001097          	auipc	ra,0x1
    5952:	8a0080e7          	jalr	-1888(ra) # 61ee <printf>
    exit(1);
    5956:	4505                	li	a0,1
    5958:	00000097          	auipc	ra,0x0
    595c:	520080e7          	jalr	1312(ra) # 5e78 <exit>
    5960:	f426                	sd	s1,40(sp)
    5962:	f04a                	sd	s2,32(sp)
    5964:	ec4e                	sd	s3,24(sp)
    5966:	e852                	sd	s4,16(sp)
    printf("fork failed in countfree()\n");
    5968:	00003517          	auipc	a0,0x3
    596c:	a3850513          	addi	a0,a0,-1480 # 83a0 <malloc+0x20f6>
    5970:	00001097          	auipc	ra,0x1
    5974:	87e080e7          	jalr	-1922(ra) # 61ee <printf>
    exit(1);
    5978:	4505                	li	a0,1
    597a:	00000097          	auipc	ra,0x0
    597e:	4fe080e7          	jalr	1278(ra) # 5e78 <exit>
      }
    }

    exit(0);
    5982:	4501                	li	a0,0
    5984:	00000097          	auipc	ra,0x0
    5988:	4f4080e7          	jalr	1268(ra) # 5e78 <exit>
    598c:	f426                	sd	s1,40(sp)
    598e:	f04a                	sd	s2,32(sp)
    5990:	ec4e                	sd	s3,24(sp)
  }

  close(fds[1]);
    5992:	fcc42503          	lw	a0,-52(s0)
    5996:	00000097          	auipc	ra,0x0
    599a:	50a080e7          	jalr	1290(ra) # 5ea0 <close>

  int n = 0;
    599e:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    59a0:	fc740993          	addi	s3,s0,-57
    59a4:	4905                	li	s2,1
    59a6:	864a                	mv	a2,s2
    59a8:	85ce                	mv	a1,s3
    59aa:	fc842503          	lw	a0,-56(s0)
    59ae:	00000097          	auipc	ra,0x0
    59b2:	4e2080e7          	jalr	1250(ra) # 5e90 <read>
    if(cc < 0){
    59b6:	00054563          	bltz	a0,59c0 <countfree+0x10c>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    59ba:	c10d                	beqz	a0,59dc <countfree+0x128>
      break;
    n += 1;
    59bc:	2485                	addiw	s1,s1,1
  while(1){
    59be:	b7e5                	j	59a6 <countfree+0xf2>
    59c0:	e852                	sd	s4,16(sp)
      printf("read() failed in countfree()\n");
    59c2:	00003517          	auipc	a0,0x3
    59c6:	a1e50513          	addi	a0,a0,-1506 # 83e0 <malloc+0x2136>
    59ca:	00001097          	auipc	ra,0x1
    59ce:	824080e7          	jalr	-2012(ra) # 61ee <printf>
      exit(1);
    59d2:	4505                	li	a0,1
    59d4:	00000097          	auipc	ra,0x0
    59d8:	4a4080e7          	jalr	1188(ra) # 5e78 <exit>
  }

  close(fds[0]);
    59dc:	fc842503          	lw	a0,-56(s0)
    59e0:	00000097          	auipc	ra,0x0
    59e4:	4c0080e7          	jalr	1216(ra) # 5ea0 <close>
  wait((int*)0);
    59e8:	4501                	li	a0,0
    59ea:	00000097          	auipc	ra,0x0
    59ee:	496080e7          	jalr	1174(ra) # 5e80 <wait>
  
  return n;
}
    59f2:	8526                	mv	a0,s1
    59f4:	74a2                	ld	s1,40(sp)
    59f6:	7902                	ld	s2,32(sp)
    59f8:	69e2                	ld	s3,24(sp)
    59fa:	70e2                	ld	ra,56(sp)
    59fc:	7442                	ld	s0,48(sp)
    59fe:	6121                	addi	sp,sp,64
    5a00:	8082                	ret

0000000000005a02 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    5a02:	711d                	addi	sp,sp,-96
    5a04:	ec86                	sd	ra,88(sp)
    5a06:	e8a2                	sd	s0,80(sp)
    5a08:	e4a6                	sd	s1,72(sp)
    5a0a:	e0ca                	sd	s2,64(sp)
    5a0c:	fc4e                	sd	s3,56(sp)
    5a0e:	f852                	sd	s4,48(sp)
    5a10:	f456                	sd	s5,40(sp)
    5a12:	f05a                	sd	s6,32(sp)
    5a14:	ec5e                	sd	s7,24(sp)
    5a16:	e862                	sd	s8,16(sp)
    5a18:	e466                	sd	s9,8(sp)
    5a1a:	e06a                	sd	s10,0(sp)
    5a1c:	1080                	addi	s0,sp,96
    5a1e:	8aaa                	mv	s5,a0
    5a20:	89ae                	mv	s3,a1
    5a22:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    5a24:	00003b97          	auipc	s7,0x3
    5a28:	9dcb8b93          	addi	s7,s7,-1572 # 8400 <malloc+0x2156>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    5a2c:	00003b17          	auipc	s6,0x3
    5a30:	5e4b0b13          	addi	s6,s6,1508 # 9010 <quicktests>
      if(continuous != 2) {
    5a34:	4a09                	li	s4,2
      }
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      if (runtests(slowtests, justone)) {
    5a36:	00004c17          	auipc	s8,0x4
    5a3a:	9aac0c13          	addi	s8,s8,-1622 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    5a3e:	00003d17          	auipc	s10,0x3
    5a42:	9dad0d13          	addi	s10,s10,-1574 # 8418 <malloc+0x216e>
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5a46:	00003c97          	auipc	s9,0x3
    5a4a:	9f2c8c93          	addi	s9,s9,-1550 # 8438 <malloc+0x218e>
    5a4e:	a839                	j	5a6c <drivetests+0x6a>
        printf("usertests slow tests starting\n");
    5a50:	856a                	mv	a0,s10
    5a52:	00000097          	auipc	ra,0x0
    5a56:	79c080e7          	jalr	1948(ra) # 61ee <printf>
    5a5a:	a081                	j	5a9a <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    5a5c:	00000097          	auipc	ra,0x0
    5a60:	e58080e7          	jalr	-424(ra) # 58b4 <countfree>
    5a64:	04954663          	blt	a0,s1,5ab0 <drivetests+0xae>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    5a68:	06098163          	beqz	s3,5aca <drivetests+0xc8>
    printf("usertests starting\n");
    5a6c:	855e                	mv	a0,s7
    5a6e:	00000097          	auipc	ra,0x0
    5a72:	780080e7          	jalr	1920(ra) # 61ee <printf>
    int free0 = countfree();
    5a76:	00000097          	auipc	ra,0x0
    5a7a:	e3e080e7          	jalr	-450(ra) # 58b4 <countfree>
    5a7e:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    5a80:	85ca                	mv	a1,s2
    5a82:	855a                	mv	a0,s6
    5a84:	00000097          	auipc	ra,0x0
    5a88:	dd4080e7          	jalr	-556(ra) # 5858 <runtests>
    5a8c:	c119                	beqz	a0,5a92 <drivetests+0x90>
      if(continuous != 2) {
    5a8e:	03499c63          	bne	s3,s4,5ac6 <drivetests+0xc4>
    if(!quick) {
    5a92:	fc0a95e3          	bnez	s5,5a5c <drivetests+0x5a>
      if (justone == 0)
    5a96:	fa090de3          	beqz	s2,5a50 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    5a9a:	85ca                	mv	a1,s2
    5a9c:	8562                	mv	a0,s8
    5a9e:	00000097          	auipc	ra,0x0
    5aa2:	dba080e7          	jalr	-582(ra) # 5858 <runtests>
    5aa6:	d95d                	beqz	a0,5a5c <drivetests+0x5a>
        if(continuous != 2) {
    5aa8:	fb498ae3          	beq	s3,s4,5a5c <drivetests+0x5a>
          return 1;
    5aac:	4505                	li	a0,1
    5aae:	a839                	j	5acc <drivetests+0xca>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5ab0:	8626                	mv	a2,s1
    5ab2:	85aa                	mv	a1,a0
    5ab4:	8566                	mv	a0,s9
    5ab6:	00000097          	auipc	ra,0x0
    5aba:	738080e7          	jalr	1848(ra) # 61ee <printf>
      if(continuous != 2) {
    5abe:	fb4987e3          	beq	s3,s4,5a6c <drivetests+0x6a>
        return 1;
    5ac2:	4505                	li	a0,1
    5ac4:	a021                	j	5acc <drivetests+0xca>
        return 1;
    5ac6:	4505                	li	a0,1
    5ac8:	a011                	j	5acc <drivetests+0xca>
  return 0;
    5aca:	854e                	mv	a0,s3
}
    5acc:	60e6                	ld	ra,88(sp)
    5ace:	6446                	ld	s0,80(sp)
    5ad0:	64a6                	ld	s1,72(sp)
    5ad2:	6906                	ld	s2,64(sp)
    5ad4:	79e2                	ld	s3,56(sp)
    5ad6:	7a42                	ld	s4,48(sp)
    5ad8:	7aa2                	ld	s5,40(sp)
    5ada:	7b02                	ld	s6,32(sp)
    5adc:	6be2                	ld	s7,24(sp)
    5ade:	6c42                	ld	s8,16(sp)
    5ae0:	6ca2                	ld	s9,8(sp)
    5ae2:	6d02                	ld	s10,0(sp)
    5ae4:	6125                	addi	sp,sp,96
    5ae6:	8082                	ret

0000000000005ae8 <main>:

int
main(int argc, char *argv[])
{
    5ae8:	1101                	addi	sp,sp,-32
    5aea:	ec06                	sd	ra,24(sp)
    5aec:	e822                	sd	s0,16(sp)
    5aee:	e426                	sd	s1,8(sp)
    5af0:	e04a                	sd	s2,0(sp)
    5af2:	1000                	addi	s0,sp,32
    5af4:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5af6:	4789                	li	a5,2
    5af8:	02f50263          	beq	a0,a5,5b1c <main+0x34>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5afc:	4785                	li	a5,1
    5afe:	08a7c063          	blt	a5,a0,5b7e <main+0x96>
  char *justone = 0;
    5b02:	4601                	li	a2,0
  int quick = 0;
    5b04:	4501                	li	a0,0
  int continuous = 0;
    5b06:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5b08:	00000097          	auipc	ra,0x0
    5b0c:	efa080e7          	jalr	-262(ra) # 5a02 <drivetests>
    5b10:	c951                	beqz	a0,5ba4 <main+0xbc>
    exit(1);
    5b12:	4505                	li	a0,1
    5b14:	00000097          	auipc	ra,0x0
    5b18:	364080e7          	jalr	868(ra) # 5e78 <exit>
    5b1c:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5b1e:	00003597          	auipc	a1,0x3
    5b22:	94a58593          	addi	a1,a1,-1718 # 8468 <malloc+0x21be>
    5b26:	00893503          	ld	a0,8(s2) # 1008 <linktest+0xc4>
    5b2a:	00000097          	auipc	ra,0x0
    5b2e:	0ce080e7          	jalr	206(ra) # 5bf8 <strcmp>
    5b32:	85aa                	mv	a1,a0
    5b34:	e501                	bnez	a0,5b3c <main+0x54>
  char *justone = 0;
    5b36:	4601                	li	a2,0
    quick = 1;
    5b38:	4505                	li	a0,1
    5b3a:	b7f9                	j	5b08 <main+0x20>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5b3c:	00003597          	auipc	a1,0x3
    5b40:	93458593          	addi	a1,a1,-1740 # 8470 <malloc+0x21c6>
    5b44:	00893503          	ld	a0,8(s2)
    5b48:	00000097          	auipc	ra,0x0
    5b4c:	0b0080e7          	jalr	176(ra) # 5bf8 <strcmp>
    5b50:	c521                	beqz	a0,5b98 <main+0xb0>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5b52:	00003597          	auipc	a1,0x3
    5b56:	96e58593          	addi	a1,a1,-1682 # 84c0 <malloc+0x2216>
    5b5a:	00893503          	ld	a0,8(s2)
    5b5e:	00000097          	auipc	ra,0x0
    5b62:	09a080e7          	jalr	154(ra) # 5bf8 <strcmp>
    5b66:	cd05                	beqz	a0,5b9e <main+0xb6>
  } else if(argc == 2 && argv[1][0] != '-'){
    5b68:	00893603          	ld	a2,8(s2)
    5b6c:	00064703          	lbu	a4,0(a2) # 3000 <sbrklast+0x72>
    5b70:	02d00793          	li	a5,45
    5b74:	00f70563          	beq	a4,a5,5b7e <main+0x96>
  int quick = 0;
    5b78:	4501                	li	a0,0
  int continuous = 0;
    5b7a:	4581                	li	a1,0
    5b7c:	b771                	j	5b08 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5b7e:	00003517          	auipc	a0,0x3
    5b82:	8fa50513          	addi	a0,a0,-1798 # 8478 <malloc+0x21ce>
    5b86:	00000097          	auipc	ra,0x0
    5b8a:	668080e7          	jalr	1640(ra) # 61ee <printf>
    exit(1);
    5b8e:	4505                	li	a0,1
    5b90:	00000097          	auipc	ra,0x0
    5b94:	2e8080e7          	jalr	744(ra) # 5e78 <exit>
  char *justone = 0;
    5b98:	4601                	li	a2,0
    continuous = 1;
    5b9a:	4585                	li	a1,1
    5b9c:	b7b5                	j	5b08 <main+0x20>
    continuous = 2;
    5b9e:	85a6                	mv	a1,s1
  char *justone = 0;
    5ba0:	4601                	li	a2,0
    5ba2:	b79d                	j	5b08 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5ba4:	00003517          	auipc	a0,0x3
    5ba8:	90450513          	addi	a0,a0,-1788 # 84a8 <malloc+0x21fe>
    5bac:	00000097          	auipc	ra,0x0
    5bb0:	642080e7          	jalr	1602(ra) # 61ee <printf>
  exit(0);
    5bb4:	4501                	li	a0,0
    5bb6:	00000097          	auipc	ra,0x0
    5bba:	2c2080e7          	jalr	706(ra) # 5e78 <exit>

0000000000005bbe <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5bbe:	1141                	addi	sp,sp,-16
    5bc0:	e406                	sd	ra,8(sp)
    5bc2:	e022                	sd	s0,0(sp)
    5bc4:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5bc6:	00000097          	auipc	ra,0x0
    5bca:	f22080e7          	jalr	-222(ra) # 5ae8 <main>
  exit(0);
    5bce:	4501                	li	a0,0
    5bd0:	00000097          	auipc	ra,0x0
    5bd4:	2a8080e7          	jalr	680(ra) # 5e78 <exit>

0000000000005bd8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    5bd8:	1141                	addi	sp,sp,-16
    5bda:	e406                	sd	ra,8(sp)
    5bdc:	e022                	sd	s0,0(sp)
    5bde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5be0:	87aa                	mv	a5,a0
    5be2:	0585                	addi	a1,a1,1
    5be4:	0785                	addi	a5,a5,1
    5be6:	fff5c703          	lbu	a4,-1(a1)
    5bea:	fee78fa3          	sb	a4,-1(a5)
    5bee:	fb75                	bnez	a4,5be2 <strcpy+0xa>
    ;
  return os;
}
    5bf0:	60a2                	ld	ra,8(sp)
    5bf2:	6402                	ld	s0,0(sp)
    5bf4:	0141                	addi	sp,sp,16
    5bf6:	8082                	ret

0000000000005bf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5bf8:	1141                	addi	sp,sp,-16
    5bfa:	e406                	sd	ra,8(sp)
    5bfc:	e022                	sd	s0,0(sp)
    5bfe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5c00:	00054783          	lbu	a5,0(a0)
    5c04:	cb91                	beqz	a5,5c18 <strcmp+0x20>
    5c06:	0005c703          	lbu	a4,0(a1)
    5c0a:	00f71763          	bne	a4,a5,5c18 <strcmp+0x20>
    p++, q++;
    5c0e:	0505                	addi	a0,a0,1
    5c10:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5c12:	00054783          	lbu	a5,0(a0)
    5c16:	fbe5                	bnez	a5,5c06 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
    5c18:	0005c503          	lbu	a0,0(a1)
}
    5c1c:	40a7853b          	subw	a0,a5,a0
    5c20:	60a2                	ld	ra,8(sp)
    5c22:	6402                	ld	s0,0(sp)
    5c24:	0141                	addi	sp,sp,16
    5c26:	8082                	ret

0000000000005c28 <strlen>:

uint
strlen(const char *s)
{
    5c28:	1141                	addi	sp,sp,-16
    5c2a:	e406                	sd	ra,8(sp)
    5c2c:	e022                	sd	s0,0(sp)
    5c2e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5c30:	00054783          	lbu	a5,0(a0)
    5c34:	cf99                	beqz	a5,5c52 <strlen+0x2a>
    5c36:	0505                	addi	a0,a0,1
    5c38:	87aa                	mv	a5,a0
    5c3a:	86be                	mv	a3,a5
    5c3c:	0785                	addi	a5,a5,1
    5c3e:	fff7c703          	lbu	a4,-1(a5)
    5c42:	ff65                	bnez	a4,5c3a <strlen+0x12>
    5c44:	40a6853b          	subw	a0,a3,a0
    5c48:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    5c4a:	60a2                	ld	ra,8(sp)
    5c4c:	6402                	ld	s0,0(sp)
    5c4e:	0141                	addi	sp,sp,16
    5c50:	8082                	ret
  for(n = 0; s[n]; n++)
    5c52:	4501                	li	a0,0
    5c54:	bfdd                	j	5c4a <strlen+0x22>

0000000000005c56 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5c56:	1141                	addi	sp,sp,-16
    5c58:	e406                	sd	ra,8(sp)
    5c5a:	e022                	sd	s0,0(sp)
    5c5c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5c5e:	ca19                	beqz	a2,5c74 <memset+0x1e>
    5c60:	87aa                	mv	a5,a0
    5c62:	1602                	slli	a2,a2,0x20
    5c64:	9201                	srli	a2,a2,0x20
    5c66:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5c6a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5c6e:	0785                	addi	a5,a5,1
    5c70:	fee79de3          	bne	a5,a4,5c6a <memset+0x14>
  }
  return dst;
}
    5c74:	60a2                	ld	ra,8(sp)
    5c76:	6402                	ld	s0,0(sp)
    5c78:	0141                	addi	sp,sp,16
    5c7a:	8082                	ret

0000000000005c7c <strchr>:

char*
strchr(const char *s, char c)
{
    5c7c:	1141                	addi	sp,sp,-16
    5c7e:	e406                	sd	ra,8(sp)
    5c80:	e022                	sd	s0,0(sp)
    5c82:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5c84:	00054783          	lbu	a5,0(a0)
    5c88:	cf81                	beqz	a5,5ca0 <strchr+0x24>
    if(*s == c)
    5c8a:	00f58763          	beq	a1,a5,5c98 <strchr+0x1c>
  for(; *s; s++)
    5c8e:	0505                	addi	a0,a0,1
    5c90:	00054783          	lbu	a5,0(a0)
    5c94:	fbfd                	bnez	a5,5c8a <strchr+0xe>
      return (char*)s;
  return 0;
    5c96:	4501                	li	a0,0
}
    5c98:	60a2                	ld	ra,8(sp)
    5c9a:	6402                	ld	s0,0(sp)
    5c9c:	0141                	addi	sp,sp,16
    5c9e:	8082                	ret
  return 0;
    5ca0:	4501                	li	a0,0
    5ca2:	bfdd                	j	5c98 <strchr+0x1c>

0000000000005ca4 <gets>:

char*
gets(char *buf, int max)
{
    5ca4:	7159                	addi	sp,sp,-112
    5ca6:	f486                	sd	ra,104(sp)
    5ca8:	f0a2                	sd	s0,96(sp)
    5caa:	eca6                	sd	s1,88(sp)
    5cac:	e8ca                	sd	s2,80(sp)
    5cae:	e4ce                	sd	s3,72(sp)
    5cb0:	e0d2                	sd	s4,64(sp)
    5cb2:	fc56                	sd	s5,56(sp)
    5cb4:	f85a                	sd	s6,48(sp)
    5cb6:	f45e                	sd	s7,40(sp)
    5cb8:	f062                	sd	s8,32(sp)
    5cba:	ec66                	sd	s9,24(sp)
    5cbc:	e86a                	sd	s10,16(sp)
    5cbe:	1880                	addi	s0,sp,112
    5cc0:	8caa                	mv	s9,a0
    5cc2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5cc4:	892a                	mv	s2,a0
    5cc6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    5cc8:	f9f40b13          	addi	s6,s0,-97
    5ccc:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5cce:	4ba9                	li	s7,10
    5cd0:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
    5cd2:	8d26                	mv	s10,s1
    5cd4:	0014899b          	addiw	s3,s1,1
    5cd8:	84ce                	mv	s1,s3
    5cda:	0349d763          	bge	s3,s4,5d08 <gets+0x64>
    cc = read(0, &c, 1);
    5cde:	8656                	mv	a2,s5
    5ce0:	85da                	mv	a1,s6
    5ce2:	4501                	li	a0,0
    5ce4:	00000097          	auipc	ra,0x0
    5ce8:	1ac080e7          	jalr	428(ra) # 5e90 <read>
    if(cc < 1)
    5cec:	00a05e63          	blez	a0,5d08 <gets+0x64>
    buf[i++] = c;
    5cf0:	f9f44783          	lbu	a5,-97(s0)
    5cf4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5cf8:	01778763          	beq	a5,s7,5d06 <gets+0x62>
    5cfc:	0905                	addi	s2,s2,1
    5cfe:	fd879ae3          	bne	a5,s8,5cd2 <gets+0x2e>
    buf[i++] = c;
    5d02:	8d4e                	mv	s10,s3
    5d04:	a011                	j	5d08 <gets+0x64>
    5d06:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
    5d08:	9d66                	add	s10,s10,s9
    5d0a:	000d0023          	sb	zero,0(s10)
  return buf;
}
    5d0e:	8566                	mv	a0,s9
    5d10:	70a6                	ld	ra,104(sp)
    5d12:	7406                	ld	s0,96(sp)
    5d14:	64e6                	ld	s1,88(sp)
    5d16:	6946                	ld	s2,80(sp)
    5d18:	69a6                	ld	s3,72(sp)
    5d1a:	6a06                	ld	s4,64(sp)
    5d1c:	7ae2                	ld	s5,56(sp)
    5d1e:	7b42                	ld	s6,48(sp)
    5d20:	7ba2                	ld	s7,40(sp)
    5d22:	7c02                	ld	s8,32(sp)
    5d24:	6ce2                	ld	s9,24(sp)
    5d26:	6d42                	ld	s10,16(sp)
    5d28:	6165                	addi	sp,sp,112
    5d2a:	8082                	ret

0000000000005d2c <stat>:

int
stat(const char *n, struct stat *st)
{
    5d2c:	1101                	addi	sp,sp,-32
    5d2e:	ec06                	sd	ra,24(sp)
    5d30:	e822                	sd	s0,16(sp)
    5d32:	e04a                	sd	s2,0(sp)
    5d34:	1000                	addi	s0,sp,32
    5d36:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5d38:	4581                	li	a1,0
    5d3a:	00000097          	auipc	ra,0x0
    5d3e:	17e080e7          	jalr	382(ra) # 5eb8 <open>
  if(fd < 0)
    5d42:	02054663          	bltz	a0,5d6e <stat+0x42>
    5d46:	e426                	sd	s1,8(sp)
    5d48:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5d4a:	85ca                	mv	a1,s2
    5d4c:	00000097          	auipc	ra,0x0
    5d50:	184080e7          	jalr	388(ra) # 5ed0 <fstat>
    5d54:	892a                	mv	s2,a0
  close(fd);
    5d56:	8526                	mv	a0,s1
    5d58:	00000097          	auipc	ra,0x0
    5d5c:	148080e7          	jalr	328(ra) # 5ea0 <close>
  return r;
    5d60:	64a2                	ld	s1,8(sp)
}
    5d62:	854a                	mv	a0,s2
    5d64:	60e2                	ld	ra,24(sp)
    5d66:	6442                	ld	s0,16(sp)
    5d68:	6902                	ld	s2,0(sp)
    5d6a:	6105                	addi	sp,sp,32
    5d6c:	8082                	ret
    return -1;
    5d6e:	597d                	li	s2,-1
    5d70:	bfcd                	j	5d62 <stat+0x36>

0000000000005d72 <atoi>:

int
atoi(const char *s)
{
    5d72:	1141                	addi	sp,sp,-16
    5d74:	e406                	sd	ra,8(sp)
    5d76:	e022                	sd	s0,0(sp)
    5d78:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5d7a:	00054683          	lbu	a3,0(a0)
    5d7e:	fd06879b          	addiw	a5,a3,-48
    5d82:	0ff7f793          	zext.b	a5,a5
    5d86:	4625                	li	a2,9
    5d88:	02f66963          	bltu	a2,a5,5dba <atoi+0x48>
    5d8c:	872a                	mv	a4,a0
  n = 0;
    5d8e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    5d90:	0705                	addi	a4,a4,1
    5d92:	0025179b          	slliw	a5,a0,0x2
    5d96:	9fa9                	addw	a5,a5,a0
    5d98:	0017979b          	slliw	a5,a5,0x1
    5d9c:	9fb5                	addw	a5,a5,a3
    5d9e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5da2:	00074683          	lbu	a3,0(a4)
    5da6:	fd06879b          	addiw	a5,a3,-48
    5daa:	0ff7f793          	zext.b	a5,a5
    5dae:	fef671e3          	bgeu	a2,a5,5d90 <atoi+0x1e>
  return n;
}
    5db2:	60a2                	ld	ra,8(sp)
    5db4:	6402                	ld	s0,0(sp)
    5db6:	0141                	addi	sp,sp,16
    5db8:	8082                	ret
  n = 0;
    5dba:	4501                	li	a0,0
    5dbc:	bfdd                	j	5db2 <atoi+0x40>

0000000000005dbe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5dbe:	1141                	addi	sp,sp,-16
    5dc0:	e406                	sd	ra,8(sp)
    5dc2:	e022                	sd	s0,0(sp)
    5dc4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5dc6:	02b57563          	bgeu	a0,a1,5df0 <memmove+0x32>
    while(n-- > 0)
    5dca:	00c05f63          	blez	a2,5de8 <memmove+0x2a>
    5dce:	1602                	slli	a2,a2,0x20
    5dd0:	9201                	srli	a2,a2,0x20
    5dd2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5dd6:	872a                	mv	a4,a0
      *dst++ = *src++;
    5dd8:	0585                	addi	a1,a1,1
    5dda:	0705                	addi	a4,a4,1
    5ddc:	fff5c683          	lbu	a3,-1(a1)
    5de0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5de4:	fee79ae3          	bne	a5,a4,5dd8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5de8:	60a2                	ld	ra,8(sp)
    5dea:	6402                	ld	s0,0(sp)
    5dec:	0141                	addi	sp,sp,16
    5dee:	8082                	ret
    dst += n;
    5df0:	00c50733          	add	a4,a0,a2
    src += n;
    5df4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5df6:	fec059e3          	blez	a2,5de8 <memmove+0x2a>
    5dfa:	fff6079b          	addiw	a5,a2,-1
    5dfe:	1782                	slli	a5,a5,0x20
    5e00:	9381                	srli	a5,a5,0x20
    5e02:	fff7c793          	not	a5,a5
    5e06:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5e08:	15fd                	addi	a1,a1,-1
    5e0a:	177d                	addi	a4,a4,-1
    5e0c:	0005c683          	lbu	a3,0(a1)
    5e10:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5e14:	fef71ae3          	bne	a4,a5,5e08 <memmove+0x4a>
    5e18:	bfc1                	j	5de8 <memmove+0x2a>

0000000000005e1a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5e1a:	1141                	addi	sp,sp,-16
    5e1c:	e406                	sd	ra,8(sp)
    5e1e:	e022                	sd	s0,0(sp)
    5e20:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5e22:	ca0d                	beqz	a2,5e54 <memcmp+0x3a>
    5e24:	fff6069b          	addiw	a3,a2,-1
    5e28:	1682                	slli	a3,a3,0x20
    5e2a:	9281                	srli	a3,a3,0x20
    5e2c:	0685                	addi	a3,a3,1
    5e2e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5e30:	00054783          	lbu	a5,0(a0)
    5e34:	0005c703          	lbu	a4,0(a1)
    5e38:	00e79863          	bne	a5,a4,5e48 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
    5e3c:	0505                	addi	a0,a0,1
    p2++;
    5e3e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5e40:	fed518e3          	bne	a0,a3,5e30 <memcmp+0x16>
  }
  return 0;
    5e44:	4501                	li	a0,0
    5e46:	a019                	j	5e4c <memcmp+0x32>
      return *p1 - *p2;
    5e48:	40e7853b          	subw	a0,a5,a4
}
    5e4c:	60a2                	ld	ra,8(sp)
    5e4e:	6402                	ld	s0,0(sp)
    5e50:	0141                	addi	sp,sp,16
    5e52:	8082                	ret
  return 0;
    5e54:	4501                	li	a0,0
    5e56:	bfdd                	j	5e4c <memcmp+0x32>

0000000000005e58 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5e58:	1141                	addi	sp,sp,-16
    5e5a:	e406                	sd	ra,8(sp)
    5e5c:	e022                	sd	s0,0(sp)
    5e5e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5e60:	00000097          	auipc	ra,0x0
    5e64:	f5e080e7          	jalr	-162(ra) # 5dbe <memmove>
}
    5e68:	60a2                	ld	ra,8(sp)
    5e6a:	6402                	ld	s0,0(sp)
    5e6c:	0141                	addi	sp,sp,16
    5e6e:	8082                	ret

0000000000005e70 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5e70:	4885                	li	a7,1
 ecall
    5e72:	00000073          	ecall
 ret
    5e76:	8082                	ret

0000000000005e78 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5e78:	4889                	li	a7,2
 ecall
    5e7a:	00000073          	ecall
 ret
    5e7e:	8082                	ret

0000000000005e80 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5e80:	488d                	li	a7,3
 ecall
    5e82:	00000073          	ecall
 ret
    5e86:	8082                	ret

0000000000005e88 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5e88:	4891                	li	a7,4
 ecall
    5e8a:	00000073          	ecall
 ret
    5e8e:	8082                	ret

0000000000005e90 <read>:
.global read
read:
 li a7, SYS_read
    5e90:	4895                	li	a7,5
 ecall
    5e92:	00000073          	ecall
 ret
    5e96:	8082                	ret

0000000000005e98 <write>:
.global write
write:
 li a7, SYS_write
    5e98:	48c1                	li	a7,16
 ecall
    5e9a:	00000073          	ecall
 ret
    5e9e:	8082                	ret

0000000000005ea0 <close>:
.global close
close:
 li a7, SYS_close
    5ea0:	48d5                	li	a7,21
 ecall
    5ea2:	00000073          	ecall
 ret
    5ea6:	8082                	ret

0000000000005ea8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5ea8:	4899                	li	a7,6
 ecall
    5eaa:	00000073          	ecall
 ret
    5eae:	8082                	ret

0000000000005eb0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5eb0:	489d                	li	a7,7
 ecall
    5eb2:	00000073          	ecall
 ret
    5eb6:	8082                	ret

0000000000005eb8 <open>:
.global open
open:
 li a7, SYS_open
    5eb8:	48bd                	li	a7,15
 ecall
    5eba:	00000073          	ecall
 ret
    5ebe:	8082                	ret

0000000000005ec0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5ec0:	48c5                	li	a7,17
 ecall
    5ec2:	00000073          	ecall
 ret
    5ec6:	8082                	ret

0000000000005ec8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5ec8:	48c9                	li	a7,18
 ecall
    5eca:	00000073          	ecall
 ret
    5ece:	8082                	ret

0000000000005ed0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5ed0:	48a1                	li	a7,8
 ecall
    5ed2:	00000073          	ecall
 ret
    5ed6:	8082                	ret

0000000000005ed8 <link>:
.global link
link:
 li a7, SYS_link
    5ed8:	48cd                	li	a7,19
 ecall
    5eda:	00000073          	ecall
 ret
    5ede:	8082                	ret

0000000000005ee0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5ee0:	48d1                	li	a7,20
 ecall
    5ee2:	00000073          	ecall
 ret
    5ee6:	8082                	ret

0000000000005ee8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5ee8:	48a5                	li	a7,9
 ecall
    5eea:	00000073          	ecall
 ret
    5eee:	8082                	ret

0000000000005ef0 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5ef0:	48a9                	li	a7,10
 ecall
    5ef2:	00000073          	ecall
 ret
    5ef6:	8082                	ret

0000000000005ef8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5ef8:	48ad                	li	a7,11
 ecall
    5efa:	00000073          	ecall
 ret
    5efe:	8082                	ret

0000000000005f00 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5f00:	48b1                	li	a7,12
 ecall
    5f02:	00000073          	ecall
 ret
    5f06:	8082                	ret

0000000000005f08 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5f08:	48b5                	li	a7,13
 ecall
    5f0a:	00000073          	ecall
 ret
    5f0e:	8082                	ret

0000000000005f10 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5f10:	48b9                	li	a7,14
 ecall
    5f12:	00000073          	ecall
 ret
    5f16:	8082                	ret

0000000000005f18 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5f18:	48d9                	li	a7,22
 ecall
    5f1a:	00000073          	ecall
 ret
    5f1e:	8082                	ret

0000000000005f20 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
    5f20:	48dd                	li	a7,23
 ecall
    5f22:	00000073          	ecall
 ret
    5f26:	8082                	ret

0000000000005f28 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
    5f28:	48e1                	li	a7,24
 ecall
    5f2a:	00000073          	ecall
 ret
    5f2e:	8082                	ret

0000000000005f30 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
    5f30:	48e5                	li	a7,25
 ecall
    5f32:	00000073          	ecall
 ret
    5f36:	8082                	ret

0000000000005f38 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5f38:	1101                	addi	sp,sp,-32
    5f3a:	ec06                	sd	ra,24(sp)
    5f3c:	e822                	sd	s0,16(sp)
    5f3e:	1000                	addi	s0,sp,32
    5f40:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5f44:	4605                	li	a2,1
    5f46:	fef40593          	addi	a1,s0,-17
    5f4a:	00000097          	auipc	ra,0x0
    5f4e:	f4e080e7          	jalr	-178(ra) # 5e98 <write>
}
    5f52:	60e2                	ld	ra,24(sp)
    5f54:	6442                	ld	s0,16(sp)
    5f56:	6105                	addi	sp,sp,32
    5f58:	8082                	ret

0000000000005f5a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5f5a:	7139                	addi	sp,sp,-64
    5f5c:	fc06                	sd	ra,56(sp)
    5f5e:	f822                	sd	s0,48(sp)
    5f60:	f426                	sd	s1,40(sp)
    5f62:	f04a                	sd	s2,32(sp)
    5f64:	ec4e                	sd	s3,24(sp)
    5f66:	0080                	addi	s0,sp,64
    5f68:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5f6a:	c299                	beqz	a3,5f70 <printint+0x16>
    5f6c:	0805c063          	bltz	a1,5fec <printint+0x92>
  neg = 0;
    5f70:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    5f72:	fc040313          	addi	t1,s0,-64
  neg = 0;
    5f76:	869a                	mv	a3,t1
  i = 0;
    5f78:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    5f7a:	00003817          	auipc	a6,0x3
    5f7e:	90e80813          	addi	a6,a6,-1778 # 8888 <digits>
    5f82:	88be                	mv	a7,a5
    5f84:	0017851b          	addiw	a0,a5,1
    5f88:	87aa                	mv	a5,a0
    5f8a:	02c5f73b          	remuw	a4,a1,a2
    5f8e:	1702                	slli	a4,a4,0x20
    5f90:	9301                	srli	a4,a4,0x20
    5f92:	9742                	add	a4,a4,a6
    5f94:	00074703          	lbu	a4,0(a4)
    5f98:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    5f9c:	872e                	mv	a4,a1
    5f9e:	02c5d5bb          	divuw	a1,a1,a2
    5fa2:	0685                	addi	a3,a3,1
    5fa4:	fcc77fe3          	bgeu	a4,a2,5f82 <printint+0x28>
  if(neg)
    5fa8:	000e0c63          	beqz	t3,5fc0 <printint+0x66>
    buf[i++] = '-';
    5fac:	fd050793          	addi	a5,a0,-48
    5fb0:	00878533          	add	a0,a5,s0
    5fb4:	02d00793          	li	a5,45
    5fb8:	fef50823          	sb	a5,-16(a0)
    5fbc:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    5fc0:	fff7899b          	addiw	s3,a5,-1
    5fc4:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
    5fc8:	fff4c583          	lbu	a1,-1(s1)
    5fcc:	854a                	mv	a0,s2
    5fce:	00000097          	auipc	ra,0x0
    5fd2:	f6a080e7          	jalr	-150(ra) # 5f38 <putc>
  while(--i >= 0)
    5fd6:	39fd                	addiw	s3,s3,-1
    5fd8:	14fd                	addi	s1,s1,-1
    5fda:	fe09d7e3          	bgez	s3,5fc8 <printint+0x6e>
}
    5fde:	70e2                	ld	ra,56(sp)
    5fe0:	7442                	ld	s0,48(sp)
    5fe2:	74a2                	ld	s1,40(sp)
    5fe4:	7902                	ld	s2,32(sp)
    5fe6:	69e2                	ld	s3,24(sp)
    5fe8:	6121                	addi	sp,sp,64
    5fea:	8082                	ret
    x = -xx;
    5fec:	40b005bb          	negw	a1,a1
    neg = 1;
    5ff0:	4e05                	li	t3,1
    x = -xx;
    5ff2:	b741                	j	5f72 <printint+0x18>

0000000000005ff4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5ff4:	715d                	addi	sp,sp,-80
    5ff6:	e486                	sd	ra,72(sp)
    5ff8:	e0a2                	sd	s0,64(sp)
    5ffa:	f84a                	sd	s2,48(sp)
    5ffc:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5ffe:	0005c903          	lbu	s2,0(a1)
    6002:	1a090a63          	beqz	s2,61b6 <vprintf+0x1c2>
    6006:	fc26                	sd	s1,56(sp)
    6008:	f44e                	sd	s3,40(sp)
    600a:	f052                	sd	s4,32(sp)
    600c:	ec56                	sd	s5,24(sp)
    600e:	e85a                	sd	s6,16(sp)
    6010:	e45e                	sd	s7,8(sp)
    6012:	8aaa                	mv	s5,a0
    6014:	8bb2                	mv	s7,a2
    6016:	00158493          	addi	s1,a1,1
  state = 0;
    601a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    601c:	02500a13          	li	s4,37
    6020:	4b55                	li	s6,21
    6022:	a839                	j	6040 <vprintf+0x4c>
        putc(fd, c);
    6024:	85ca                	mv	a1,s2
    6026:	8556                	mv	a0,s5
    6028:	00000097          	auipc	ra,0x0
    602c:	f10080e7          	jalr	-240(ra) # 5f38 <putc>
    6030:	a019                	j	6036 <vprintf+0x42>
    } else if(state == '%'){
    6032:	01498d63          	beq	s3,s4,604c <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    6036:	0485                	addi	s1,s1,1
    6038:	fff4c903          	lbu	s2,-1(s1)
    603c:	16090763          	beqz	s2,61aa <vprintf+0x1b6>
    if(state == 0){
    6040:	fe0999e3          	bnez	s3,6032 <vprintf+0x3e>
      if(c == '%'){
    6044:	ff4910e3          	bne	s2,s4,6024 <vprintf+0x30>
        state = '%';
    6048:	89d2                	mv	s3,s4
    604a:	b7f5                	j	6036 <vprintf+0x42>
      if(c == 'd'){
    604c:	13490463          	beq	s2,s4,6174 <vprintf+0x180>
    6050:	f9d9079b          	addiw	a5,s2,-99
    6054:	0ff7f793          	zext.b	a5,a5
    6058:	12fb6763          	bltu	s6,a5,6186 <vprintf+0x192>
    605c:	f9d9079b          	addiw	a5,s2,-99
    6060:	0ff7f713          	zext.b	a4,a5
    6064:	12eb6163          	bltu	s6,a4,6186 <vprintf+0x192>
    6068:	00271793          	slli	a5,a4,0x2
    606c:	00002717          	auipc	a4,0x2
    6070:	7c470713          	addi	a4,a4,1988 # 8830 <malloc+0x2586>
    6074:	97ba                	add	a5,a5,a4
    6076:	439c                	lw	a5,0(a5)
    6078:	97ba                	add	a5,a5,a4
    607a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    607c:	008b8913          	addi	s2,s7,8
    6080:	4685                	li	a3,1
    6082:	4629                	li	a2,10
    6084:	000ba583          	lw	a1,0(s7)
    6088:	8556                	mv	a0,s5
    608a:	00000097          	auipc	ra,0x0
    608e:	ed0080e7          	jalr	-304(ra) # 5f5a <printint>
    6092:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    6094:	4981                	li	s3,0
    6096:	b745                	j	6036 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    6098:	008b8913          	addi	s2,s7,8
    609c:	4681                	li	a3,0
    609e:	4629                	li	a2,10
    60a0:	000ba583          	lw	a1,0(s7)
    60a4:	8556                	mv	a0,s5
    60a6:	00000097          	auipc	ra,0x0
    60aa:	eb4080e7          	jalr	-332(ra) # 5f5a <printint>
    60ae:	8bca                	mv	s7,s2
      state = 0;
    60b0:	4981                	li	s3,0
    60b2:	b751                	j	6036 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    60b4:	008b8913          	addi	s2,s7,8
    60b8:	4681                	li	a3,0
    60ba:	4641                	li	a2,16
    60bc:	000ba583          	lw	a1,0(s7)
    60c0:	8556                	mv	a0,s5
    60c2:	00000097          	auipc	ra,0x0
    60c6:	e98080e7          	jalr	-360(ra) # 5f5a <printint>
    60ca:	8bca                	mv	s7,s2
      state = 0;
    60cc:	4981                	li	s3,0
    60ce:	b7a5                	j	6036 <vprintf+0x42>
    60d0:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    60d2:	008b8c13          	addi	s8,s7,8
    60d6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    60da:	03000593          	li	a1,48
    60de:	8556                	mv	a0,s5
    60e0:	00000097          	auipc	ra,0x0
    60e4:	e58080e7          	jalr	-424(ra) # 5f38 <putc>
  putc(fd, 'x');
    60e8:	07800593          	li	a1,120
    60ec:	8556                	mv	a0,s5
    60ee:	00000097          	auipc	ra,0x0
    60f2:	e4a080e7          	jalr	-438(ra) # 5f38 <putc>
    60f6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    60f8:	00002b97          	auipc	s7,0x2
    60fc:	790b8b93          	addi	s7,s7,1936 # 8888 <digits>
    6100:	03c9d793          	srli	a5,s3,0x3c
    6104:	97de                	add	a5,a5,s7
    6106:	0007c583          	lbu	a1,0(a5)
    610a:	8556                	mv	a0,s5
    610c:	00000097          	auipc	ra,0x0
    6110:	e2c080e7          	jalr	-468(ra) # 5f38 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    6114:	0992                	slli	s3,s3,0x4
    6116:	397d                	addiw	s2,s2,-1
    6118:	fe0914e3          	bnez	s2,6100 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    611c:	8be2                	mv	s7,s8
      state = 0;
    611e:	4981                	li	s3,0
    6120:	6c02                	ld	s8,0(sp)
    6122:	bf11                	j	6036 <vprintf+0x42>
        s = va_arg(ap, char*);
    6124:	008b8993          	addi	s3,s7,8
    6128:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    612c:	02090163          	beqz	s2,614e <vprintf+0x15a>
        while(*s != 0){
    6130:	00094583          	lbu	a1,0(s2)
    6134:	c9a5                	beqz	a1,61a4 <vprintf+0x1b0>
          putc(fd, *s);
    6136:	8556                	mv	a0,s5
    6138:	00000097          	auipc	ra,0x0
    613c:	e00080e7          	jalr	-512(ra) # 5f38 <putc>
          s++;
    6140:	0905                	addi	s2,s2,1
        while(*s != 0){
    6142:	00094583          	lbu	a1,0(s2)
    6146:	f9e5                	bnez	a1,6136 <vprintf+0x142>
        s = va_arg(ap, char*);
    6148:	8bce                	mv	s7,s3
      state = 0;
    614a:	4981                	li	s3,0
    614c:	b5ed                	j	6036 <vprintf+0x42>
          s = "(null)";
    614e:	00002917          	auipc	s2,0x2
    6152:	6ba90913          	addi	s2,s2,1722 # 8808 <malloc+0x255e>
        while(*s != 0){
    6156:	02800593          	li	a1,40
    615a:	bff1                	j	6136 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    615c:	008b8913          	addi	s2,s7,8
    6160:	000bc583          	lbu	a1,0(s7)
    6164:	8556                	mv	a0,s5
    6166:	00000097          	auipc	ra,0x0
    616a:	dd2080e7          	jalr	-558(ra) # 5f38 <putc>
    616e:	8bca                	mv	s7,s2
      state = 0;
    6170:	4981                	li	s3,0
    6172:	b5d1                	j	6036 <vprintf+0x42>
        putc(fd, c);
    6174:	02500593          	li	a1,37
    6178:	8556                	mv	a0,s5
    617a:	00000097          	auipc	ra,0x0
    617e:	dbe080e7          	jalr	-578(ra) # 5f38 <putc>
      state = 0;
    6182:	4981                	li	s3,0
    6184:	bd4d                	j	6036 <vprintf+0x42>
        putc(fd, '%');
    6186:	02500593          	li	a1,37
    618a:	8556                	mv	a0,s5
    618c:	00000097          	auipc	ra,0x0
    6190:	dac080e7          	jalr	-596(ra) # 5f38 <putc>
        putc(fd, c);
    6194:	85ca                	mv	a1,s2
    6196:	8556                	mv	a0,s5
    6198:	00000097          	auipc	ra,0x0
    619c:	da0080e7          	jalr	-608(ra) # 5f38 <putc>
      state = 0;
    61a0:	4981                	li	s3,0
    61a2:	bd51                	j	6036 <vprintf+0x42>
        s = va_arg(ap, char*);
    61a4:	8bce                	mv	s7,s3
      state = 0;
    61a6:	4981                	li	s3,0
    61a8:	b579                	j	6036 <vprintf+0x42>
    61aa:	74e2                	ld	s1,56(sp)
    61ac:	79a2                	ld	s3,40(sp)
    61ae:	7a02                	ld	s4,32(sp)
    61b0:	6ae2                	ld	s5,24(sp)
    61b2:	6b42                	ld	s6,16(sp)
    61b4:	6ba2                	ld	s7,8(sp)
    }
  }
}
    61b6:	60a6                	ld	ra,72(sp)
    61b8:	6406                	ld	s0,64(sp)
    61ba:	7942                	ld	s2,48(sp)
    61bc:	6161                	addi	sp,sp,80
    61be:	8082                	ret

00000000000061c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    61c0:	715d                	addi	sp,sp,-80
    61c2:	ec06                	sd	ra,24(sp)
    61c4:	e822                	sd	s0,16(sp)
    61c6:	1000                	addi	s0,sp,32
    61c8:	e010                	sd	a2,0(s0)
    61ca:	e414                	sd	a3,8(s0)
    61cc:	e818                	sd	a4,16(s0)
    61ce:	ec1c                	sd	a5,24(s0)
    61d0:	03043023          	sd	a6,32(s0)
    61d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    61d8:	8622                	mv	a2,s0
    61da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    61de:	00000097          	auipc	ra,0x0
    61e2:	e16080e7          	jalr	-490(ra) # 5ff4 <vprintf>
}
    61e6:	60e2                	ld	ra,24(sp)
    61e8:	6442                	ld	s0,16(sp)
    61ea:	6161                	addi	sp,sp,80
    61ec:	8082                	ret

00000000000061ee <printf>:

void
printf(const char *fmt, ...)
{
    61ee:	711d                	addi	sp,sp,-96
    61f0:	ec06                	sd	ra,24(sp)
    61f2:	e822                	sd	s0,16(sp)
    61f4:	1000                	addi	s0,sp,32
    61f6:	e40c                	sd	a1,8(s0)
    61f8:	e810                	sd	a2,16(s0)
    61fa:	ec14                	sd	a3,24(s0)
    61fc:	f018                	sd	a4,32(s0)
    61fe:	f41c                	sd	a5,40(s0)
    6200:	03043823          	sd	a6,48(s0)
    6204:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    6208:	00840613          	addi	a2,s0,8
    620c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    6210:	85aa                	mv	a1,a0
    6212:	4505                	li	a0,1
    6214:	00000097          	auipc	ra,0x0
    6218:	de0080e7          	jalr	-544(ra) # 5ff4 <vprintf>
}
    621c:	60e2                	ld	ra,24(sp)
    621e:	6442                	ld	s0,16(sp)
    6220:	6125                	addi	sp,sp,96
    6222:	8082                	ret

0000000000006224 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    6224:	1141                	addi	sp,sp,-16
    6226:	e406                	sd	ra,8(sp)
    6228:	e022                	sd	s0,0(sp)
    622a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    622c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6230:	00003797          	auipc	a5,0x3
    6234:	2207b783          	ld	a5,544(a5) # 9450 <freep>
    6238:	a02d                	j	6262 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    623a:	4618                	lw	a4,8(a2)
    623c:	9f2d                	addw	a4,a4,a1
    623e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    6242:	6398                	ld	a4,0(a5)
    6244:	6310                	ld	a2,0(a4)
    6246:	a83d                	j	6284 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    6248:	ff852703          	lw	a4,-8(a0)
    624c:	9f31                	addw	a4,a4,a2
    624e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    6250:	ff053683          	ld	a3,-16(a0)
    6254:	a091                	j	6298 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    6256:	6398                	ld	a4,0(a5)
    6258:	00e7e463          	bltu	a5,a4,6260 <free+0x3c>
    625c:	00e6ea63          	bltu	a3,a4,6270 <free+0x4c>
{
    6260:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6262:	fed7fae3          	bgeu	a5,a3,6256 <free+0x32>
    6266:	6398                	ld	a4,0(a5)
    6268:	00e6e463          	bltu	a3,a4,6270 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    626c:	fee7eae3          	bltu	a5,a4,6260 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
    6270:	ff852583          	lw	a1,-8(a0)
    6274:	6390                	ld	a2,0(a5)
    6276:	02059813          	slli	a6,a1,0x20
    627a:	01c85713          	srli	a4,a6,0x1c
    627e:	9736                	add	a4,a4,a3
    6280:	fae60de3          	beq	a2,a4,623a <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
    6284:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    6288:	4790                	lw	a2,8(a5)
    628a:	02061593          	slli	a1,a2,0x20
    628e:	01c5d713          	srli	a4,a1,0x1c
    6292:	973e                	add	a4,a4,a5
    6294:	fae68ae3          	beq	a3,a4,6248 <free+0x24>
    p->s.ptr = bp->s.ptr;
    6298:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    629a:	00003717          	auipc	a4,0x3
    629e:	1af73b23          	sd	a5,438(a4) # 9450 <freep>
}
    62a2:	60a2                	ld	ra,8(sp)
    62a4:	6402                	ld	s0,0(sp)
    62a6:	0141                	addi	sp,sp,16
    62a8:	8082                	ret

00000000000062aa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    62aa:	7139                	addi	sp,sp,-64
    62ac:	fc06                	sd	ra,56(sp)
    62ae:	f822                	sd	s0,48(sp)
    62b0:	f04a                	sd	s2,32(sp)
    62b2:	ec4e                	sd	s3,24(sp)
    62b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    62b6:	02051993          	slli	s3,a0,0x20
    62ba:	0209d993          	srli	s3,s3,0x20
    62be:	09bd                	addi	s3,s3,15
    62c0:	0049d993          	srli	s3,s3,0x4
    62c4:	2985                	addiw	s3,s3,1
    62c6:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    62c8:	00003517          	auipc	a0,0x3
    62cc:	18853503          	ld	a0,392(a0) # 9450 <freep>
    62d0:	c905                	beqz	a0,6300 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    62d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    62d4:	4798                	lw	a4,8(a5)
    62d6:	09377a63          	bgeu	a4,s3,636a <malloc+0xc0>
    62da:	f426                	sd	s1,40(sp)
    62dc:	e852                	sd	s4,16(sp)
    62de:	e456                	sd	s5,8(sp)
    62e0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    62e2:	8a4e                	mv	s4,s3
    62e4:	6705                	lui	a4,0x1
    62e6:	00e9f363          	bgeu	s3,a4,62ec <malloc+0x42>
    62ea:	6a05                	lui	s4,0x1
    62ec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    62f0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    62f4:	00003497          	auipc	s1,0x3
    62f8:	15c48493          	addi	s1,s1,348 # 9450 <freep>
  if(p == (char*)-1)
    62fc:	5afd                	li	s5,-1
    62fe:	a089                	j	6340 <malloc+0x96>
    6300:	f426                	sd	s1,40(sp)
    6302:	e852                	sd	s4,16(sp)
    6304:	e456                	sd	s5,8(sp)
    6306:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    6308:	0000a797          	auipc	a5,0xa
    630c:	97078793          	addi	a5,a5,-1680 # fc78 <base>
    6310:	00003717          	auipc	a4,0x3
    6314:	14f73023          	sd	a5,320(a4) # 9450 <freep>
    6318:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    631a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    631e:	b7d1                	j	62e2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    6320:	6398                	ld	a4,0(a5)
    6322:	e118                	sd	a4,0(a0)
    6324:	a8b9                	j	6382 <malloc+0xd8>
  hp->s.size = nu;
    6326:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    632a:	0541                	addi	a0,a0,16
    632c:	00000097          	auipc	ra,0x0
    6330:	ef8080e7          	jalr	-264(ra) # 6224 <free>
  return freep;
    6334:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    6336:	c135                	beqz	a0,639a <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6338:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    633a:	4798                	lw	a4,8(a5)
    633c:	03277363          	bgeu	a4,s2,6362 <malloc+0xb8>
    if(p == freep)
    6340:	6098                	ld	a4,0(s1)
    6342:	853e                	mv	a0,a5
    6344:	fef71ae3          	bne	a4,a5,6338 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    6348:	8552                	mv	a0,s4
    634a:	00000097          	auipc	ra,0x0
    634e:	bb6080e7          	jalr	-1098(ra) # 5f00 <sbrk>
  if(p == (char*)-1)
    6352:	fd551ae3          	bne	a0,s5,6326 <malloc+0x7c>
        return 0;
    6356:	4501                	li	a0,0
    6358:	74a2                	ld	s1,40(sp)
    635a:	6a42                	ld	s4,16(sp)
    635c:	6aa2                	ld	s5,8(sp)
    635e:	6b02                	ld	s6,0(sp)
    6360:	a03d                	j	638e <malloc+0xe4>
    6362:	74a2                	ld	s1,40(sp)
    6364:	6a42                	ld	s4,16(sp)
    6366:	6aa2                	ld	s5,8(sp)
    6368:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    636a:	fae90be3          	beq	s2,a4,6320 <malloc+0x76>
        p->s.size -= nunits;
    636e:	4137073b          	subw	a4,a4,s3
    6372:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6374:	02071693          	slli	a3,a4,0x20
    6378:	01c6d713          	srli	a4,a3,0x1c
    637c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    637e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    6382:	00003717          	auipc	a4,0x3
    6386:	0ca73723          	sd	a0,206(a4) # 9450 <freep>
      return (void*)(p + 1);
    638a:	01078513          	addi	a0,a5,16
  }
}
    638e:	70e2                	ld	ra,56(sp)
    6390:	7442                	ld	s0,48(sp)
    6392:	7902                	ld	s2,32(sp)
    6394:	69e2                	ld	s3,24(sp)
    6396:	6121                	addi	sp,sp,64
    6398:	8082                	ret
    639a:	74a2                	ld	s1,40(sp)
    639c:	6a42                	ld	s4,16(sp)
    639e:	6aa2                	ld	s5,8(sp)
    63a0:	6b02                	ld	s6,0(sp)
    63a2:	b7f5                	j	638e <malloc+0xe4>
