
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	35e58593          	addi	a1,a1,862 # 1370 <malloc+0xfe>
      1a:	8532                	mv	a0,a2
      1c:	00001097          	auipc	ra,0x1
      20:	e44080e7          	jalr	-444(ra) # e60 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	bf4080e7          	jalr	-1036(ra) # c1e <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c36080e7          	jalr	-970(ra) # c6c <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a0053b          	negw	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0);
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	32058593          	addi	a1,a1,800 # 1380 <malloc+0x10e>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	11e080e7          	jalr	286(ra) # 1188 <fprintf>
  exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	dcc080e7          	jalr	-564(ra) # e40 <exit>

000000000000007c <fork1>:
}

int
fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	db4080e7          	jalr	-588(ra) # e38 <fork>
  if(pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
    panic("fork");
  return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
    panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	2ee50513          	addi	a0,a0,750 # 1388 <malloc+0x116>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	1800                	addi	s0,sp,48
  if(cmd == 0)
      b2:	c115                	beqz	a0,d6 <runcmd+0x2c>
      b4:	ec26                	sd	s1,24(sp)
      b6:	84aa                	mv	s1,a0
  switch(cmd->type){
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e363          	bltu	a5,a4,e2 <runcmd+0x38>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	3c270713          	addi	a4,a4,962 # 1488 <malloc+0x216>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
      d6:	ec26                	sd	s1,24(sp)
    exit(1);
      d8:	4505                	li	a0,1
      da:	00001097          	auipc	ra,0x1
      de:	d66080e7          	jalr	-666(ra) # e40 <exit>
    panic("runcmd");
      e2:	00001517          	auipc	a0,0x1
      e6:	2ae50513          	addi	a0,a0,686 # 1390 <malloc+0x11e>
      ea:	00000097          	auipc	ra,0x0
      ee:	f6c080e7          	jalr	-148(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
      f2:	6508                	ld	a0,8(a0)
      f4:	c515                	beqz	a0,120 <runcmd+0x76>
    exec(ecmd->argv[0], ecmd->argv);
      f6:	00848593          	addi	a1,s1,8
      fa:	00001097          	auipc	ra,0x1
      fe:	d7e080e7          	jalr	-642(ra) # e78 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     102:	6490                	ld	a2,8(s1)
     104:	00001597          	auipc	a1,0x1
     108:	29458593          	addi	a1,a1,660 # 1398 <malloc+0x126>
     10c:	4509                	li	a0,2
     10e:	00001097          	auipc	ra,0x1
     112:	07a080e7          	jalr	122(ra) # 1188 <fprintf>
  exit(0);
     116:	4501                	li	a0,0
     118:	00001097          	auipc	ra,0x1
     11c:	d28080e7          	jalr	-728(ra) # e40 <exit>
      exit(1);
     120:	4505                	li	a0,1
     122:	00001097          	auipc	ra,0x1
     126:	d1e080e7          	jalr	-738(ra) # e40 <exit>
    close(rcmd->fd);
     12a:	5148                	lw	a0,36(a0)
     12c:	00001097          	auipc	ra,0x1
     130:	d3c080e7          	jalr	-708(ra) # e68 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     134:	508c                	lw	a1,32(s1)
     136:	6888                	ld	a0,16(s1)
     138:	00001097          	auipc	ra,0x1
     13c:	d48080e7          	jalr	-696(ra) # e80 <open>
     140:	00054763          	bltz	a0,14e <runcmd+0xa4>
    runcmd(rcmd->cmd);
     144:	6488                	ld	a0,8(s1)
     146:	00000097          	auipc	ra,0x0
     14a:	f64080e7          	jalr	-156(ra) # aa <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     14e:	6890                	ld	a2,16(s1)
     150:	00001597          	auipc	a1,0x1
     154:	25858593          	addi	a1,a1,600 # 13a8 <malloc+0x136>
     158:	4509                	li	a0,2
     15a:	00001097          	auipc	ra,0x1
     15e:	02e080e7          	jalr	46(ra) # 1188 <fprintf>
      exit(1);
     162:	4505                	li	a0,1
     164:	00001097          	auipc	ra,0x1
     168:	cdc080e7          	jalr	-804(ra) # e40 <exit>
    if(fork1() == 0)
     16c:	00000097          	auipc	ra,0x0
     170:	f10080e7          	jalr	-240(ra) # 7c <fork1>
     174:	e511                	bnez	a0,180 <runcmd+0xd6>
      runcmd(lcmd->left);
     176:	6488                	ld	a0,8(s1)
     178:	00000097          	auipc	ra,0x0
     17c:	f32080e7          	jalr	-206(ra) # aa <runcmd>
    wait(0);
     180:	4501                	li	a0,0
     182:	00001097          	auipc	ra,0x1
     186:	cc6080e7          	jalr	-826(ra) # e48 <wait>
    runcmd(lcmd->right);
     18a:	6888                	ld	a0,16(s1)
     18c:	00000097          	auipc	ra,0x0
     190:	f1e080e7          	jalr	-226(ra) # aa <runcmd>
    if(pipe(p) < 0)
     194:	fd840513          	addi	a0,s0,-40
     198:	00001097          	auipc	ra,0x1
     19c:	cb8080e7          	jalr	-840(ra) # e50 <pipe>
     1a0:	04054363          	bltz	a0,1e6 <runcmd+0x13c>
    if(fork1() == 0){
     1a4:	00000097          	auipc	ra,0x0
     1a8:	ed8080e7          	jalr	-296(ra) # 7c <fork1>
     1ac:	e529                	bnez	a0,1f6 <runcmd+0x14c>
      close(1);
     1ae:	4505                	li	a0,1
     1b0:	00001097          	auipc	ra,0x1
     1b4:	cb8080e7          	jalr	-840(ra) # e68 <close>
      dup(p[1]);
     1b8:	fdc42503          	lw	a0,-36(s0)
     1bc:	00001097          	auipc	ra,0x1
     1c0:	cfc080e7          	jalr	-772(ra) # eb8 <dup>
      close(p[0]);
     1c4:	fd842503          	lw	a0,-40(s0)
     1c8:	00001097          	auipc	ra,0x1
     1cc:	ca0080e7          	jalr	-864(ra) # e68 <close>
      close(p[1]);
     1d0:	fdc42503          	lw	a0,-36(s0)
     1d4:	00001097          	auipc	ra,0x1
     1d8:	c94080e7          	jalr	-876(ra) # e68 <close>
      runcmd(pcmd->left);
     1dc:	6488                	ld	a0,8(s1)
     1de:	00000097          	auipc	ra,0x0
     1e2:	ecc080e7          	jalr	-308(ra) # aa <runcmd>
      panic("pipe");
     1e6:	00001517          	auipc	a0,0x1
     1ea:	1d250513          	addi	a0,a0,466 # 13b8 <malloc+0x146>
     1ee:	00000097          	auipc	ra,0x0
     1f2:	e68080e7          	jalr	-408(ra) # 56 <panic>
    if(fork1() == 0){
     1f6:	00000097          	auipc	ra,0x0
     1fa:	e86080e7          	jalr	-378(ra) # 7c <fork1>
     1fe:	ed05                	bnez	a0,236 <runcmd+0x18c>
      close(0);
     200:	00001097          	auipc	ra,0x1
     204:	c68080e7          	jalr	-920(ra) # e68 <close>
      dup(p[0]);
     208:	fd842503          	lw	a0,-40(s0)
     20c:	00001097          	auipc	ra,0x1
     210:	cac080e7          	jalr	-852(ra) # eb8 <dup>
      close(p[0]);
     214:	fd842503          	lw	a0,-40(s0)
     218:	00001097          	auipc	ra,0x1
     21c:	c50080e7          	jalr	-944(ra) # e68 <close>
      close(p[1]);
     220:	fdc42503          	lw	a0,-36(s0)
     224:	00001097          	auipc	ra,0x1
     228:	c44080e7          	jalr	-956(ra) # e68 <close>
      runcmd(pcmd->right);
     22c:	6888                	ld	a0,16(s1)
     22e:	00000097          	auipc	ra,0x0
     232:	e7c080e7          	jalr	-388(ra) # aa <runcmd>
    close(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c2e080e7          	jalr	-978(ra) # e68 <close>
    close(p[1]);
     242:	fdc42503          	lw	a0,-36(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c22080e7          	jalr	-990(ra) # e68 <close>
    wait(0);
     24e:	4501                	li	a0,0
     250:	00001097          	auipc	ra,0x1
     254:	bf8080e7          	jalr	-1032(ra) # e48 <wait>
    wait(0);
     258:	4501                	li	a0,0
     25a:	00001097          	auipc	ra,0x1
     25e:	bee080e7          	jalr	-1042(ra) # e48 <wait>
    break;
     262:	bd55                	j	116 <runcmd+0x6c>
    if(fork1() == 0)
     264:	00000097          	auipc	ra,0x0
     268:	e18080e7          	jalr	-488(ra) # 7c <fork1>
     26c:	ea0515e3          	bnez	a0,116 <runcmd+0x6c>
      runcmd(bcmd->cmd);
     270:	6488                	ld	a0,8(s1)
     272:	00000097          	auipc	ra,0x0
     276:	e38080e7          	jalr	-456(ra) # aa <runcmd>

000000000000027a <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     27a:	1101                	addi	sp,sp,-32
     27c:	ec06                	sd	ra,24(sp)
     27e:	e822                	sd	s0,16(sp)
     280:	e426                	sd	s1,8(sp)
     282:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     284:	0a800513          	li	a0,168
     288:	00001097          	auipc	ra,0x1
     28c:	fea080e7          	jalr	-22(ra) # 1272 <malloc>
     290:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     292:	0a800613          	li	a2,168
     296:	4581                	li	a1,0
     298:	00001097          	auipc	ra,0x1
     29c:	986080e7          	jalr	-1658(ra) # c1e <memset>
  cmd->type = EXEC;
     2a0:	4785                	li	a5,1
     2a2:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2a4:	8526                	mv	a0,s1
     2a6:	60e2                	ld	ra,24(sp)
     2a8:	6442                	ld	s0,16(sp)
     2aa:	64a2                	ld	s1,8(sp)
     2ac:	6105                	addi	sp,sp,32
     2ae:	8082                	ret

00000000000002b0 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2b0:	7139                	addi	sp,sp,-64
     2b2:	fc06                	sd	ra,56(sp)
     2b4:	f822                	sd	s0,48(sp)
     2b6:	f426                	sd	s1,40(sp)
     2b8:	f04a                	sd	s2,32(sp)
     2ba:	ec4e                	sd	s3,24(sp)
     2bc:	e852                	sd	s4,16(sp)
     2be:	e456                	sd	s5,8(sp)
     2c0:	e05a                	sd	s6,0(sp)
     2c2:	0080                	addi	s0,sp,64
     2c4:	8b2a                	mv	s6,a0
     2c6:	8aae                	mv	s5,a1
     2c8:	8a32                	mv	s4,a2
     2ca:	89b6                	mv	s3,a3
     2cc:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ce:	02800513          	li	a0,40
     2d2:	00001097          	auipc	ra,0x1
     2d6:	fa0080e7          	jalr	-96(ra) # 1272 <malloc>
     2da:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2dc:	02800613          	li	a2,40
     2e0:	4581                	li	a1,0
     2e2:	00001097          	auipc	ra,0x1
     2e6:	93c080e7          	jalr	-1732(ra) # c1e <memset>
  cmd->type = REDIR;
     2ea:	4789                	li	a5,2
     2ec:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2ee:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     2f2:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     2f6:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     2fa:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     2fe:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     302:	8526                	mv	a0,s1
     304:	70e2                	ld	ra,56(sp)
     306:	7442                	ld	s0,48(sp)
     308:	74a2                	ld	s1,40(sp)
     30a:	7902                	ld	s2,32(sp)
     30c:	69e2                	ld	s3,24(sp)
     30e:	6a42                	ld	s4,16(sp)
     310:	6aa2                	ld	s5,8(sp)
     312:	6b02                	ld	s6,0(sp)
     314:	6121                	addi	sp,sp,64
     316:	8082                	ret

0000000000000318 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     318:	7179                	addi	sp,sp,-48
     31a:	f406                	sd	ra,40(sp)
     31c:	f022                	sd	s0,32(sp)
     31e:	ec26                	sd	s1,24(sp)
     320:	e84a                	sd	s2,16(sp)
     322:	e44e                	sd	s3,8(sp)
     324:	1800                	addi	s0,sp,48
     326:	89aa                	mv	s3,a0
     328:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     32a:	4561                	li	a0,24
     32c:	00001097          	auipc	ra,0x1
     330:	f46080e7          	jalr	-186(ra) # 1272 <malloc>
     334:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     336:	4661                	li	a2,24
     338:	4581                	li	a1,0
     33a:	00001097          	auipc	ra,0x1
     33e:	8e4080e7          	jalr	-1820(ra) # c1e <memset>
  cmd->type = PIPE;
     342:	478d                	li	a5,3
     344:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     346:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     34a:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     34e:	8526                	mv	a0,s1
     350:	70a2                	ld	ra,40(sp)
     352:	7402                	ld	s0,32(sp)
     354:	64e2                	ld	s1,24(sp)
     356:	6942                	ld	s2,16(sp)
     358:	69a2                	ld	s3,8(sp)
     35a:	6145                	addi	sp,sp,48
     35c:	8082                	ret

000000000000035e <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     35e:	7179                	addi	sp,sp,-48
     360:	f406                	sd	ra,40(sp)
     362:	f022                	sd	s0,32(sp)
     364:	ec26                	sd	s1,24(sp)
     366:	e84a                	sd	s2,16(sp)
     368:	e44e                	sd	s3,8(sp)
     36a:	1800                	addi	s0,sp,48
     36c:	89aa                	mv	s3,a0
     36e:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     370:	4561                	li	a0,24
     372:	00001097          	auipc	ra,0x1
     376:	f00080e7          	jalr	-256(ra) # 1272 <malloc>
     37a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     37c:	4661                	li	a2,24
     37e:	4581                	li	a1,0
     380:	00001097          	auipc	ra,0x1
     384:	89e080e7          	jalr	-1890(ra) # c1e <memset>
  cmd->type = LIST;
     388:	4791                	li	a5,4
     38a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     38c:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     390:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     394:	8526                	mv	a0,s1
     396:	70a2                	ld	ra,40(sp)
     398:	7402                	ld	s0,32(sp)
     39a:	64e2                	ld	s1,24(sp)
     39c:	6942                	ld	s2,16(sp)
     39e:	69a2                	ld	s3,8(sp)
     3a0:	6145                	addi	sp,sp,48
     3a2:	8082                	ret

00000000000003a4 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3a4:	1101                	addi	sp,sp,-32
     3a6:	ec06                	sd	ra,24(sp)
     3a8:	e822                	sd	s0,16(sp)
     3aa:	e426                	sd	s1,8(sp)
     3ac:	e04a                	sd	s2,0(sp)
     3ae:	1000                	addi	s0,sp,32
     3b0:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3b2:	4541                	li	a0,16
     3b4:	00001097          	auipc	ra,0x1
     3b8:	ebe080e7          	jalr	-322(ra) # 1272 <malloc>
     3bc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3be:	4641                	li	a2,16
     3c0:	4581                	li	a1,0
     3c2:	00001097          	auipc	ra,0x1
     3c6:	85c080e7          	jalr	-1956(ra) # c1e <memset>
  cmd->type = BACK;
     3ca:	4795                	li	a5,5
     3cc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3ce:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3d2:	8526                	mv	a0,s1
     3d4:	60e2                	ld	ra,24(sp)
     3d6:	6442                	ld	s0,16(sp)
     3d8:	64a2                	ld	s1,8(sp)
     3da:	6902                	ld	s2,0(sp)
     3dc:	6105                	addi	sp,sp,32
     3de:	8082                	ret

00000000000003e0 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3e0:	7139                	addi	sp,sp,-64
     3e2:	fc06                	sd	ra,56(sp)
     3e4:	f822                	sd	s0,48(sp)
     3e6:	f426                	sd	s1,40(sp)
     3e8:	f04a                	sd	s2,32(sp)
     3ea:	ec4e                	sd	s3,24(sp)
     3ec:	e852                	sd	s4,16(sp)
     3ee:	e456                	sd	s5,8(sp)
     3f0:	e05a                	sd	s6,0(sp)
     3f2:	0080                	addi	s0,sp,64
     3f4:	8a2a                	mv	s4,a0
     3f6:	892e                	mv	s2,a1
     3f8:	8ab2                	mv	s5,a2
     3fa:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     3fc:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     3fe:	00002997          	auipc	s3,0x2
     402:	c0a98993          	addi	s3,s3,-1014 # 2008 <whitespace>
     406:	00b4fe63          	bgeu	s1,a1,422 <gettoken+0x42>
     40a:	0004c583          	lbu	a1,0(s1)
     40e:	854e                	mv	a0,s3
     410:	00001097          	auipc	ra,0x1
     414:	834080e7          	jalr	-1996(ra) # c44 <strchr>
     418:	c509                	beqz	a0,422 <gettoken+0x42>
    s++;
     41a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     41c:	fe9917e3          	bne	s2,s1,40a <gettoken+0x2a>
     420:	84ca                	mv	s1,s2
  if(q)
     422:	000a8463          	beqz	s5,42a <gettoken+0x4a>
    *q = s;
     426:	009ab023          	sd	s1,0(s5)
  ret = *s;
     42a:	0004c783          	lbu	a5,0(s1)
     42e:	00078a9b          	sext.w	s5,a5
  switch(*s){
     432:	03c00713          	li	a4,60
     436:	06f76663          	bltu	a4,a5,4a2 <gettoken+0xc2>
     43a:	03a00713          	li	a4,58
     43e:	00f76e63          	bltu	a4,a5,45a <gettoken+0x7a>
     442:	cf89                	beqz	a5,45c <gettoken+0x7c>
     444:	02600713          	li	a4,38
     448:	00e78963          	beq	a5,a4,45a <gettoken+0x7a>
     44c:	fd87879b          	addiw	a5,a5,-40
     450:	0ff7f793          	zext.b	a5,a5
     454:	4705                	li	a4,1
     456:	06f76d63          	bltu	a4,a5,4d0 <gettoken+0xf0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     45a:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     45c:	000b0463          	beqz	s6,464 <gettoken+0x84>
    *eq = s;
     460:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     464:	00002997          	auipc	s3,0x2
     468:	ba498993          	addi	s3,s3,-1116 # 2008 <whitespace>
     46c:	0124fe63          	bgeu	s1,s2,488 <gettoken+0xa8>
     470:	0004c583          	lbu	a1,0(s1)
     474:	854e                	mv	a0,s3
     476:	00000097          	auipc	ra,0x0
     47a:	7ce080e7          	jalr	1998(ra) # c44 <strchr>
     47e:	c509                	beqz	a0,488 <gettoken+0xa8>
    s++;
     480:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     482:	fe9917e3          	bne	s2,s1,470 <gettoken+0x90>
     486:	84ca                	mv	s1,s2
  *ps = s;
     488:	009a3023          	sd	s1,0(s4)
  return ret;
}
     48c:	8556                	mv	a0,s5
     48e:	70e2                	ld	ra,56(sp)
     490:	7442                	ld	s0,48(sp)
     492:	74a2                	ld	s1,40(sp)
     494:	7902                	ld	s2,32(sp)
     496:	69e2                	ld	s3,24(sp)
     498:	6a42                	ld	s4,16(sp)
     49a:	6aa2                	ld	s5,8(sp)
     49c:	6b02                	ld	s6,0(sp)
     49e:	6121                	addi	sp,sp,64
     4a0:	8082                	ret
  switch(*s){
     4a2:	03e00713          	li	a4,62
     4a6:	02e79163          	bne	a5,a4,4c8 <gettoken+0xe8>
    s++;
     4aa:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4ae:	0014c703          	lbu	a4,1(s1)
     4b2:	03e00793          	li	a5,62
      s++;
     4b6:	0489                	addi	s1,s1,2
      ret = '+';
     4b8:	02b00a93          	li	s5,43
    if(*s == '>'){
     4bc:	faf700e3          	beq	a4,a5,45c <gettoken+0x7c>
    s++;
     4c0:	84b6                	mv	s1,a3
  ret = *s;
     4c2:	03e00a93          	li	s5,62
     4c6:	bf59                	j	45c <gettoken+0x7c>
  switch(*s){
     4c8:	07c00713          	li	a4,124
     4cc:	f8e787e3          	beq	a5,a4,45a <gettoken+0x7a>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4d0:	00002997          	auipc	s3,0x2
     4d4:	b3898993          	addi	s3,s3,-1224 # 2008 <whitespace>
     4d8:	00002a97          	auipc	s5,0x2
     4dc:	b28a8a93          	addi	s5,s5,-1240 # 2000 <symbols>
     4e0:	0524f163          	bgeu	s1,s2,522 <gettoken+0x142>
     4e4:	0004c583          	lbu	a1,0(s1)
     4e8:	854e                	mv	a0,s3
     4ea:	00000097          	auipc	ra,0x0
     4ee:	75a080e7          	jalr	1882(ra) # c44 <strchr>
     4f2:	e50d                	bnez	a0,51c <gettoken+0x13c>
     4f4:	0004c583          	lbu	a1,0(s1)
     4f8:	8556                	mv	a0,s5
     4fa:	00000097          	auipc	ra,0x0
     4fe:	74a080e7          	jalr	1866(ra) # c44 <strchr>
     502:	e911                	bnez	a0,516 <gettoken+0x136>
      s++;
     504:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     506:	fc991fe3          	bne	s2,s1,4e4 <gettoken+0x104>
  if(eq)
     50a:	84ca                	mv	s1,s2
    ret = 'a';
     50c:	06100a93          	li	s5,97
  if(eq)
     510:	f40b18e3          	bnez	s6,460 <gettoken+0x80>
     514:	bf95                	j	488 <gettoken+0xa8>
    ret = 'a';
     516:	06100a93          	li	s5,97
     51a:	b789                	j	45c <gettoken+0x7c>
     51c:	06100a93          	li	s5,97
     520:	bf35                	j	45c <gettoken+0x7c>
     522:	06100a93          	li	s5,97
  if(eq)
     526:	f20b1de3          	bnez	s6,460 <gettoken+0x80>
     52a:	bfb9                	j	488 <gettoken+0xa8>

000000000000052c <peek>:

int
peek(char **ps, char *es, char *toks)
{
     52c:	7139                	addi	sp,sp,-64
     52e:	fc06                	sd	ra,56(sp)
     530:	f822                	sd	s0,48(sp)
     532:	f426                	sd	s1,40(sp)
     534:	f04a                	sd	s2,32(sp)
     536:	ec4e                	sd	s3,24(sp)
     538:	e852                	sd	s4,16(sp)
     53a:	e456                	sd	s5,8(sp)
     53c:	0080                	addi	s0,sp,64
     53e:	8a2a                	mv	s4,a0
     540:	892e                	mv	s2,a1
     542:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     544:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     546:	00002997          	auipc	s3,0x2
     54a:	ac298993          	addi	s3,s3,-1342 # 2008 <whitespace>
     54e:	00b4fe63          	bgeu	s1,a1,56a <peek+0x3e>
     552:	0004c583          	lbu	a1,0(s1)
     556:	854e                	mv	a0,s3
     558:	00000097          	auipc	ra,0x0
     55c:	6ec080e7          	jalr	1772(ra) # c44 <strchr>
     560:	c509                	beqz	a0,56a <peek+0x3e>
    s++;
     562:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     564:	fe9917e3          	bne	s2,s1,552 <peek+0x26>
     568:	84ca                	mv	s1,s2
  *ps = s;
     56a:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     56e:	0004c583          	lbu	a1,0(s1)
     572:	4501                	li	a0,0
     574:	e991                	bnez	a1,588 <peek+0x5c>
}
     576:	70e2                	ld	ra,56(sp)
     578:	7442                	ld	s0,48(sp)
     57a:	74a2                	ld	s1,40(sp)
     57c:	7902                	ld	s2,32(sp)
     57e:	69e2                	ld	s3,24(sp)
     580:	6a42                	ld	s4,16(sp)
     582:	6aa2                	ld	s5,8(sp)
     584:	6121                	addi	sp,sp,64
     586:	8082                	ret
  return *s && strchr(toks, *s);
     588:	8556                	mv	a0,s5
     58a:	00000097          	auipc	ra,0x0
     58e:	6ba080e7          	jalr	1722(ra) # c44 <strchr>
     592:	00a03533          	snez	a0,a0
     596:	b7c5                	j	576 <peek+0x4a>

0000000000000598 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     598:	7159                	addi	sp,sp,-112
     59a:	f486                	sd	ra,104(sp)
     59c:	f0a2                	sd	s0,96(sp)
     59e:	eca6                	sd	s1,88(sp)
     5a0:	e8ca                	sd	s2,80(sp)
     5a2:	e4ce                	sd	s3,72(sp)
     5a4:	e0d2                	sd	s4,64(sp)
     5a6:	fc56                	sd	s5,56(sp)
     5a8:	f85a                	sd	s6,48(sp)
     5aa:	f45e                	sd	s7,40(sp)
     5ac:	f062                	sd	s8,32(sp)
     5ae:	ec66                	sd	s9,24(sp)
     5b0:	1880                	addi	s0,sp,112
     5b2:	8a2a                	mv	s4,a0
     5b4:	89ae                	mv	s3,a1
     5b6:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5b8:	00001b17          	auipc	s6,0x1
     5bc:	e28b0b13          	addi	s6,s6,-472 # 13e0 <malloc+0x16e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5c0:	f9040c93          	addi	s9,s0,-112
     5c4:	f9840c13          	addi	s8,s0,-104
     5c8:	06100b93          	li	s7,97
  while(peek(ps, es, "<>")){
     5cc:	a02d                	j	5f6 <parseredirs+0x5e>
      panic("missing file for redirection");
     5ce:	00001517          	auipc	a0,0x1
     5d2:	df250513          	addi	a0,a0,-526 # 13c0 <malloc+0x14e>
     5d6:	00000097          	auipc	ra,0x0
     5da:	a80080e7          	jalr	-1408(ra) # 56 <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5de:	4701                	li	a4,0
     5e0:	4681                	li	a3,0
     5e2:	f9043603          	ld	a2,-112(s0)
     5e6:	f9843583          	ld	a1,-104(s0)
     5ea:	8552                	mv	a0,s4
     5ec:	00000097          	auipc	ra,0x0
     5f0:	cc4080e7          	jalr	-828(ra) # 2b0 <redircmd>
     5f4:	8a2a                	mv	s4,a0
    switch(tok){
     5f6:	03c00a93          	li	s5,60
  while(peek(ps, es, "<>")){
     5fa:	865a                	mv	a2,s6
     5fc:	85ca                	mv	a1,s2
     5fe:	854e                	mv	a0,s3
     600:	00000097          	auipc	ra,0x0
     604:	f2c080e7          	jalr	-212(ra) # 52c <peek>
     608:	c935                	beqz	a0,67c <parseredirs+0xe4>
    tok = gettoken(ps, es, 0, 0);
     60a:	4681                	li	a3,0
     60c:	4601                	li	a2,0
     60e:	85ca                	mv	a1,s2
     610:	854e                	mv	a0,s3
     612:	00000097          	auipc	ra,0x0
     616:	dce080e7          	jalr	-562(ra) # 3e0 <gettoken>
     61a:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     61c:	86e6                	mv	a3,s9
     61e:	8662                	mv	a2,s8
     620:	85ca                	mv	a1,s2
     622:	854e                	mv	a0,s3
     624:	00000097          	auipc	ra,0x0
     628:	dbc080e7          	jalr	-580(ra) # 3e0 <gettoken>
     62c:	fb7511e3          	bne	a0,s7,5ce <parseredirs+0x36>
    switch(tok){
     630:	fb5487e3          	beq	s1,s5,5de <parseredirs+0x46>
     634:	03e00793          	li	a5,62
     638:	02f48463          	beq	s1,a5,660 <parseredirs+0xc8>
     63c:	02b00793          	li	a5,43
     640:	faf49de3          	bne	s1,a5,5fa <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     644:	4705                	li	a4,1
     646:	20100693          	li	a3,513
     64a:	f9043603          	ld	a2,-112(s0)
     64e:	f9843583          	ld	a1,-104(s0)
     652:	8552                	mv	a0,s4
     654:	00000097          	auipc	ra,0x0
     658:	c5c080e7          	jalr	-932(ra) # 2b0 <redircmd>
     65c:	8a2a                	mv	s4,a0
      break;
     65e:	bf61                	j	5f6 <parseredirs+0x5e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     660:	4705                	li	a4,1
     662:	60100693          	li	a3,1537
     666:	f9043603          	ld	a2,-112(s0)
     66a:	f9843583          	ld	a1,-104(s0)
     66e:	8552                	mv	a0,s4
     670:	00000097          	auipc	ra,0x0
     674:	c40080e7          	jalr	-960(ra) # 2b0 <redircmd>
     678:	8a2a                	mv	s4,a0
      break;
     67a:	bfb5                	j	5f6 <parseredirs+0x5e>
    }
  }
  return cmd;
}
     67c:	8552                	mv	a0,s4
     67e:	70a6                	ld	ra,104(sp)
     680:	7406                	ld	s0,96(sp)
     682:	64e6                	ld	s1,88(sp)
     684:	6946                	ld	s2,80(sp)
     686:	69a6                	ld	s3,72(sp)
     688:	6a06                	ld	s4,64(sp)
     68a:	7ae2                	ld	s5,56(sp)
     68c:	7b42                	ld	s6,48(sp)
     68e:	7ba2                	ld	s7,40(sp)
     690:	7c02                	ld	s8,32(sp)
     692:	6ce2                	ld	s9,24(sp)
     694:	6165                	addi	sp,sp,112
     696:	8082                	ret

0000000000000698 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     698:	7119                	addi	sp,sp,-128
     69a:	fc86                	sd	ra,120(sp)
     69c:	f8a2                	sd	s0,112(sp)
     69e:	f4a6                	sd	s1,104(sp)
     6a0:	e8d2                	sd	s4,80(sp)
     6a2:	e4d6                	sd	s5,72(sp)
     6a4:	0100                	addi	s0,sp,128
     6a6:	8a2a                	mv	s4,a0
     6a8:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6aa:	00001617          	auipc	a2,0x1
     6ae:	d3e60613          	addi	a2,a2,-706 # 13e8 <malloc+0x176>
     6b2:	00000097          	auipc	ra,0x0
     6b6:	e7a080e7          	jalr	-390(ra) # 52c <peek>
     6ba:	e521                	bnez	a0,702 <parseexec+0x6a>
     6bc:	f0ca                	sd	s2,96(sp)
     6be:	ecce                	sd	s3,88(sp)
     6c0:	e0da                	sd	s6,64(sp)
     6c2:	fc5e                	sd	s7,56(sp)
     6c4:	f862                	sd	s8,48(sp)
     6c6:	f466                	sd	s9,40(sp)
     6c8:	f06a                	sd	s10,32(sp)
     6ca:	ec6e                	sd	s11,24(sp)
     6cc:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6ce:	00000097          	auipc	ra,0x0
     6d2:	bac080e7          	jalr	-1108(ra) # 27a <execcmd>
     6d6:	8daa                	mv	s11,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6d8:	8656                	mv	a2,s5
     6da:	85d2                	mv	a1,s4
     6dc:	00000097          	auipc	ra,0x0
     6e0:	ebc080e7          	jalr	-324(ra) # 598 <parseredirs>
     6e4:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6e6:	008d8913          	addi	s2,s11,8
     6ea:	00001b17          	auipc	s6,0x1
     6ee:	d1eb0b13          	addi	s6,s6,-738 # 1408 <malloc+0x196>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     6f2:	f8040c13          	addi	s8,s0,-128
     6f6:	f8840b93          	addi	s7,s0,-120
      break;
    if(tok != 'a')
     6fa:	06100d13          	li	s10,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6fe:	4ca9                	li	s9,10
  while(!peek(ps, es, "|)&;")){
     700:	a081                	j	740 <parseexec+0xa8>
    return parseblock(ps, es);
     702:	85d6                	mv	a1,s5
     704:	8552                	mv	a0,s4
     706:	00000097          	auipc	ra,0x0
     70a:	1bc080e7          	jalr	444(ra) # 8c2 <parseblock>
     70e:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     710:	8526                	mv	a0,s1
     712:	70e6                	ld	ra,120(sp)
     714:	7446                	ld	s0,112(sp)
     716:	74a6                	ld	s1,104(sp)
     718:	6a46                	ld	s4,80(sp)
     71a:	6aa6                	ld	s5,72(sp)
     71c:	6109                	addi	sp,sp,128
     71e:	8082                	ret
      panic("syntax");
     720:	00001517          	auipc	a0,0x1
     724:	cd050513          	addi	a0,a0,-816 # 13f0 <malloc+0x17e>
     728:	00000097          	auipc	ra,0x0
     72c:	92e080e7          	jalr	-1746(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     730:	8656                	mv	a2,s5
     732:	85d2                	mv	a1,s4
     734:	8526                	mv	a0,s1
     736:	00000097          	auipc	ra,0x0
     73a:	e62080e7          	jalr	-414(ra) # 598 <parseredirs>
     73e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     740:	865a                	mv	a2,s6
     742:	85d6                	mv	a1,s5
     744:	8552                	mv	a0,s4
     746:	00000097          	auipc	ra,0x0
     74a:	de6080e7          	jalr	-538(ra) # 52c <peek>
     74e:	e121                	bnez	a0,78e <parseexec+0xf6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     750:	86e2                	mv	a3,s8
     752:	865e                	mv	a2,s7
     754:	85d6                	mv	a1,s5
     756:	8552                	mv	a0,s4
     758:	00000097          	auipc	ra,0x0
     75c:	c88080e7          	jalr	-888(ra) # 3e0 <gettoken>
     760:	c51d                	beqz	a0,78e <parseexec+0xf6>
    if(tok != 'a')
     762:	fba51fe3          	bne	a0,s10,720 <parseexec+0x88>
    cmd->argv[argc] = q;
     766:	f8843783          	ld	a5,-120(s0)
     76a:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     76e:	f8043783          	ld	a5,-128(s0)
     772:	04f93823          	sd	a5,80(s2)
    argc++;
     776:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     778:	0921                	addi	s2,s2,8
     77a:	fb999be3          	bne	s3,s9,730 <parseexec+0x98>
      panic("too many args");
     77e:	00001517          	auipc	a0,0x1
     782:	c7a50513          	addi	a0,a0,-902 # 13f8 <malloc+0x186>
     786:	00000097          	auipc	ra,0x0
     78a:	8d0080e7          	jalr	-1840(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     78e:	098e                	slli	s3,s3,0x3
     790:	9dce                	add	s11,s11,s3
     792:	000db423          	sd	zero,8(s11)
  cmd->eargv[argc] = 0;
     796:	040dbc23          	sd	zero,88(s11)
     79a:	7906                	ld	s2,96(sp)
     79c:	69e6                	ld	s3,88(sp)
     79e:	6b06                	ld	s6,64(sp)
     7a0:	7be2                	ld	s7,56(sp)
     7a2:	7c42                	ld	s8,48(sp)
     7a4:	7ca2                	ld	s9,40(sp)
     7a6:	7d02                	ld	s10,32(sp)
     7a8:	6de2                	ld	s11,24(sp)
  return ret;
     7aa:	b79d                	j	710 <parseexec+0x78>

00000000000007ac <parsepipe>:
{
     7ac:	7179                	addi	sp,sp,-48
     7ae:	f406                	sd	ra,40(sp)
     7b0:	f022                	sd	s0,32(sp)
     7b2:	ec26                	sd	s1,24(sp)
     7b4:	e84a                	sd	s2,16(sp)
     7b6:	e44e                	sd	s3,8(sp)
     7b8:	1800                	addi	s0,sp,48
     7ba:	892a                	mv	s2,a0
     7bc:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7be:	00000097          	auipc	ra,0x0
     7c2:	eda080e7          	jalr	-294(ra) # 698 <parseexec>
     7c6:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7c8:	00001617          	auipc	a2,0x1
     7cc:	c4860613          	addi	a2,a2,-952 # 1410 <malloc+0x19e>
     7d0:	85ce                	mv	a1,s3
     7d2:	854a                	mv	a0,s2
     7d4:	00000097          	auipc	ra,0x0
     7d8:	d58080e7          	jalr	-680(ra) # 52c <peek>
     7dc:	e909                	bnez	a0,7ee <parsepipe+0x42>
}
     7de:	8526                	mv	a0,s1
     7e0:	70a2                	ld	ra,40(sp)
     7e2:	7402                	ld	s0,32(sp)
     7e4:	64e2                	ld	s1,24(sp)
     7e6:	6942                	ld	s2,16(sp)
     7e8:	69a2                	ld	s3,8(sp)
     7ea:	6145                	addi	sp,sp,48
     7ec:	8082                	ret
    gettoken(ps, es, 0, 0);
     7ee:	4681                	li	a3,0
     7f0:	4601                	li	a2,0
     7f2:	85ce                	mv	a1,s3
     7f4:	854a                	mv	a0,s2
     7f6:	00000097          	auipc	ra,0x0
     7fa:	bea080e7          	jalr	-1046(ra) # 3e0 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7fe:	85ce                	mv	a1,s3
     800:	854a                	mv	a0,s2
     802:	00000097          	auipc	ra,0x0
     806:	faa080e7          	jalr	-86(ra) # 7ac <parsepipe>
     80a:	85aa                	mv	a1,a0
     80c:	8526                	mv	a0,s1
     80e:	00000097          	auipc	ra,0x0
     812:	b0a080e7          	jalr	-1270(ra) # 318 <pipecmd>
     816:	84aa                	mv	s1,a0
  return cmd;
     818:	b7d9                	j	7de <parsepipe+0x32>

000000000000081a <parseline>:
{
     81a:	7179                	addi	sp,sp,-48
     81c:	f406                	sd	ra,40(sp)
     81e:	f022                	sd	s0,32(sp)
     820:	ec26                	sd	s1,24(sp)
     822:	e84a                	sd	s2,16(sp)
     824:	e44e                	sd	s3,8(sp)
     826:	e052                	sd	s4,0(sp)
     828:	1800                	addi	s0,sp,48
     82a:	892a                	mv	s2,a0
     82c:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     82e:	00000097          	auipc	ra,0x0
     832:	f7e080e7          	jalr	-130(ra) # 7ac <parsepipe>
     836:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     838:	00001a17          	auipc	s4,0x1
     83c:	be0a0a13          	addi	s4,s4,-1056 # 1418 <malloc+0x1a6>
     840:	a839                	j	85e <parseline+0x44>
    gettoken(ps, es, 0, 0);
     842:	4681                	li	a3,0
     844:	4601                	li	a2,0
     846:	85ce                	mv	a1,s3
     848:	854a                	mv	a0,s2
     84a:	00000097          	auipc	ra,0x0
     84e:	b96080e7          	jalr	-1130(ra) # 3e0 <gettoken>
    cmd = backcmd(cmd);
     852:	8526                	mv	a0,s1
     854:	00000097          	auipc	ra,0x0
     858:	b50080e7          	jalr	-1200(ra) # 3a4 <backcmd>
     85c:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     85e:	8652                	mv	a2,s4
     860:	85ce                	mv	a1,s3
     862:	854a                	mv	a0,s2
     864:	00000097          	auipc	ra,0x0
     868:	cc8080e7          	jalr	-824(ra) # 52c <peek>
     86c:	f979                	bnez	a0,842 <parseline+0x28>
  if(peek(ps, es, ";")){
     86e:	00001617          	auipc	a2,0x1
     872:	bb260613          	addi	a2,a2,-1102 # 1420 <malloc+0x1ae>
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00000097          	auipc	ra,0x0
     87e:	cb2080e7          	jalr	-846(ra) # 52c <peek>
     882:	e911                	bnez	a0,896 <parseline+0x7c>
}
     884:	8526                	mv	a0,s1
     886:	70a2                	ld	ra,40(sp)
     888:	7402                	ld	s0,32(sp)
     88a:	64e2                	ld	s1,24(sp)
     88c:	6942                	ld	s2,16(sp)
     88e:	69a2                	ld	s3,8(sp)
     890:	6a02                	ld	s4,0(sp)
     892:	6145                	addi	sp,sp,48
     894:	8082                	ret
    gettoken(ps, es, 0, 0);
     896:	4681                	li	a3,0
     898:	4601                	li	a2,0
     89a:	85ce                	mv	a1,s3
     89c:	854a                	mv	a0,s2
     89e:	00000097          	auipc	ra,0x0
     8a2:	b42080e7          	jalr	-1214(ra) # 3e0 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8a6:	85ce                	mv	a1,s3
     8a8:	854a                	mv	a0,s2
     8aa:	00000097          	auipc	ra,0x0
     8ae:	f70080e7          	jalr	-144(ra) # 81a <parseline>
     8b2:	85aa                	mv	a1,a0
     8b4:	8526                	mv	a0,s1
     8b6:	00000097          	auipc	ra,0x0
     8ba:	aa8080e7          	jalr	-1368(ra) # 35e <listcmd>
     8be:	84aa                	mv	s1,a0
  return cmd;
     8c0:	b7d1                	j	884 <parseline+0x6a>

00000000000008c2 <parseblock>:
{
     8c2:	7179                	addi	sp,sp,-48
     8c4:	f406                	sd	ra,40(sp)
     8c6:	f022                	sd	s0,32(sp)
     8c8:	ec26                	sd	s1,24(sp)
     8ca:	e84a                	sd	s2,16(sp)
     8cc:	e44e                	sd	s3,8(sp)
     8ce:	1800                	addi	s0,sp,48
     8d0:	84aa                	mv	s1,a0
     8d2:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8d4:	00001617          	auipc	a2,0x1
     8d8:	b1460613          	addi	a2,a2,-1260 # 13e8 <malloc+0x176>
     8dc:	00000097          	auipc	ra,0x0
     8e0:	c50080e7          	jalr	-944(ra) # 52c <peek>
     8e4:	c12d                	beqz	a0,946 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8e6:	4681                	li	a3,0
     8e8:	4601                	li	a2,0
     8ea:	85ca                	mv	a1,s2
     8ec:	8526                	mv	a0,s1
     8ee:	00000097          	auipc	ra,0x0
     8f2:	af2080e7          	jalr	-1294(ra) # 3e0 <gettoken>
  cmd = parseline(ps, es);
     8f6:	85ca                	mv	a1,s2
     8f8:	8526                	mv	a0,s1
     8fa:	00000097          	auipc	ra,0x0
     8fe:	f20080e7          	jalr	-224(ra) # 81a <parseline>
     902:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     904:	00001617          	auipc	a2,0x1
     908:	b3460613          	addi	a2,a2,-1228 # 1438 <malloc+0x1c6>
     90c:	85ca                	mv	a1,s2
     90e:	8526                	mv	a0,s1
     910:	00000097          	auipc	ra,0x0
     914:	c1c080e7          	jalr	-996(ra) # 52c <peek>
     918:	cd1d                	beqz	a0,956 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     91a:	4681                	li	a3,0
     91c:	4601                	li	a2,0
     91e:	85ca                	mv	a1,s2
     920:	8526                	mv	a0,s1
     922:	00000097          	auipc	ra,0x0
     926:	abe080e7          	jalr	-1346(ra) # 3e0 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     92a:	864a                	mv	a2,s2
     92c:	85a6                	mv	a1,s1
     92e:	854e                	mv	a0,s3
     930:	00000097          	auipc	ra,0x0
     934:	c68080e7          	jalr	-920(ra) # 598 <parseredirs>
}
     938:	70a2                	ld	ra,40(sp)
     93a:	7402                	ld	s0,32(sp)
     93c:	64e2                	ld	s1,24(sp)
     93e:	6942                	ld	s2,16(sp)
     940:	69a2                	ld	s3,8(sp)
     942:	6145                	addi	sp,sp,48
     944:	8082                	ret
    panic("parseblock");
     946:	00001517          	auipc	a0,0x1
     94a:	ae250513          	addi	a0,a0,-1310 # 1428 <malloc+0x1b6>
     94e:	fffff097          	auipc	ra,0xfffff
     952:	708080e7          	jalr	1800(ra) # 56 <panic>
    panic("syntax - missing )");
     956:	00001517          	auipc	a0,0x1
     95a:	aea50513          	addi	a0,a0,-1302 # 1440 <malloc+0x1ce>
     95e:	fffff097          	auipc	ra,0xfffff
     962:	6f8080e7          	jalr	1784(ra) # 56 <panic>

0000000000000966 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     966:	1101                	addi	sp,sp,-32
     968:	ec06                	sd	ra,24(sp)
     96a:	e822                	sd	s0,16(sp)
     96c:	e426                	sd	s1,8(sp)
     96e:	1000                	addi	s0,sp,32
     970:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     972:	c521                	beqz	a0,9ba <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     974:	4118                	lw	a4,0(a0)
     976:	4795                	li	a5,5
     978:	04e7e163          	bltu	a5,a4,9ba <nulterminate+0x54>
     97c:	00056783          	lwu	a5,0(a0)
     980:	078a                	slli	a5,a5,0x2
     982:	00001717          	auipc	a4,0x1
     986:	b1e70713          	addi	a4,a4,-1250 # 14a0 <malloc+0x22e>
     98a:	97ba                	add	a5,a5,a4
     98c:	439c                	lw	a5,0(a5)
     98e:	97ba                	add	a5,a5,a4
     990:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     992:	651c                	ld	a5,8(a0)
     994:	c39d                	beqz	a5,9ba <nulterminate+0x54>
     996:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     99a:	67b8                	ld	a4,72(a5)
     99c:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     9a0:	07a1                	addi	a5,a5,8
     9a2:	ff87b703          	ld	a4,-8(a5)
     9a6:	fb75                	bnez	a4,99a <nulterminate+0x34>
     9a8:	a809                	j	9ba <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     9aa:	6508                	ld	a0,8(a0)
     9ac:	00000097          	auipc	ra,0x0
     9b0:	fba080e7          	jalr	-70(ra) # 966 <nulterminate>
    *rcmd->efile = 0;
     9b4:	6c9c                	ld	a5,24(s1)
     9b6:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9ba:	8526                	mv	a0,s1
     9bc:	60e2                	ld	ra,24(sp)
     9be:	6442                	ld	s0,16(sp)
     9c0:	64a2                	ld	s1,8(sp)
     9c2:	6105                	addi	sp,sp,32
     9c4:	8082                	ret
    nulterminate(pcmd->left);
     9c6:	6508                	ld	a0,8(a0)
     9c8:	00000097          	auipc	ra,0x0
     9cc:	f9e080e7          	jalr	-98(ra) # 966 <nulterminate>
    nulterminate(pcmd->right);
     9d0:	6888                	ld	a0,16(s1)
     9d2:	00000097          	auipc	ra,0x0
     9d6:	f94080e7          	jalr	-108(ra) # 966 <nulterminate>
    break;
     9da:	b7c5                	j	9ba <nulterminate+0x54>
    nulterminate(lcmd->left);
     9dc:	6508                	ld	a0,8(a0)
     9de:	00000097          	auipc	ra,0x0
     9e2:	f88080e7          	jalr	-120(ra) # 966 <nulterminate>
    nulterminate(lcmd->right);
     9e6:	6888                	ld	a0,16(s1)
     9e8:	00000097          	auipc	ra,0x0
     9ec:	f7e080e7          	jalr	-130(ra) # 966 <nulterminate>
    break;
     9f0:	b7e9                	j	9ba <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9f2:	6508                	ld	a0,8(a0)
     9f4:	00000097          	auipc	ra,0x0
     9f8:	f72080e7          	jalr	-142(ra) # 966 <nulterminate>
    break;
     9fc:	bf7d                	j	9ba <nulterminate+0x54>

00000000000009fe <parsecmd>:
{
     9fe:	7139                	addi	sp,sp,-64
     a00:	fc06                	sd	ra,56(sp)
     a02:	f822                	sd	s0,48(sp)
     a04:	f426                	sd	s1,40(sp)
     a06:	f04a                	sd	s2,32(sp)
     a08:	ec4e                	sd	s3,24(sp)
     a0a:	0080                	addi	s0,sp,64
     a0c:	fca43423          	sd	a0,-56(s0)
  es = s + strlen(s);
     a10:	84aa                	mv	s1,a0
     a12:	00000097          	auipc	ra,0x0
     a16:	1de080e7          	jalr	478(ra) # bf0 <strlen>
     a1a:	1502                	slli	a0,a0,0x20
     a1c:	9101                	srli	a0,a0,0x20
     a1e:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a20:	fc840993          	addi	s3,s0,-56
     a24:	85a6                	mv	a1,s1
     a26:	854e                	mv	a0,s3
     a28:	00000097          	auipc	ra,0x0
     a2c:	df2080e7          	jalr	-526(ra) # 81a <parseline>
     a30:	892a                	mv	s2,a0
  peek(&s, es, "");
     a32:	00001617          	auipc	a2,0x1
     a36:	94660613          	addi	a2,a2,-1722 # 1378 <malloc+0x106>
     a3a:	85a6                	mv	a1,s1
     a3c:	854e                	mv	a0,s3
     a3e:	00000097          	auipc	ra,0x0
     a42:	aee080e7          	jalr	-1298(ra) # 52c <peek>
  if(s != es){
     a46:	fc843603          	ld	a2,-56(s0)
     a4a:	00961f63          	bne	a2,s1,a68 <parsecmd+0x6a>
  nulterminate(cmd);
     a4e:	854a                	mv	a0,s2
     a50:	00000097          	auipc	ra,0x0
     a54:	f16080e7          	jalr	-234(ra) # 966 <nulterminate>
}
     a58:	854a                	mv	a0,s2
     a5a:	70e2                	ld	ra,56(sp)
     a5c:	7442                	ld	s0,48(sp)
     a5e:	74a2                	ld	s1,40(sp)
     a60:	7902                	ld	s2,32(sp)
     a62:	69e2                	ld	s3,24(sp)
     a64:	6121                	addi	sp,sp,64
     a66:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a68:	00001597          	auipc	a1,0x1
     a6c:	9f058593          	addi	a1,a1,-1552 # 1458 <malloc+0x1e6>
     a70:	4509                	li	a0,2
     a72:	00000097          	auipc	ra,0x0
     a76:	716080e7          	jalr	1814(ra) # 1188 <fprintf>
    panic("syntax");
     a7a:	00001517          	auipc	a0,0x1
     a7e:	97650513          	addi	a0,a0,-1674 # 13f0 <malloc+0x17e>
     a82:	fffff097          	auipc	ra,0xfffff
     a86:	5d4080e7          	jalr	1492(ra) # 56 <panic>

0000000000000a8a <main>:
{
     a8a:	7139                	addi	sp,sp,-64
     a8c:	fc06                	sd	ra,56(sp)
     a8e:	f822                	sd	s0,48(sp)
     a90:	f426                	sd	s1,40(sp)
     a92:	f04a                	sd	s2,32(sp)
     a94:	ec4e                	sd	s3,24(sp)
     a96:	e852                	sd	s4,16(sp)
     a98:	e456                	sd	s5,8(sp)
     a9a:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     a9c:	4489                	li	s1,2
     a9e:	00001917          	auipc	s2,0x1
     aa2:	9ca90913          	addi	s2,s2,-1590 # 1468 <malloc+0x1f6>
     aa6:	85a6                	mv	a1,s1
     aa8:	854a                	mv	a0,s2
     aaa:	00000097          	auipc	ra,0x0
     aae:	3d6080e7          	jalr	982(ra) # e80 <open>
     ab2:	00054863          	bltz	a0,ac2 <main+0x38>
    if(fd >= 3){
     ab6:	fea4d8e3          	bge	s1,a0,aa6 <main+0x1c>
      close(fd);
     aba:	00000097          	auipc	ra,0x0
     abe:	3ae080e7          	jalr	942(ra) # e68 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ac2:	00001497          	auipc	s1,0x1
     ac6:	55e48493          	addi	s1,s1,1374 # 2020 <buf.0>
     aca:	06400913          	li	s2,100
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ace:	06300993          	li	s3,99
     ad2:	02000a13          	li	s4,32
     ad6:	a819                	j	aec <main+0x62>
    if(fork1() == 0)
     ad8:	fffff097          	auipc	ra,0xfffff
     adc:	5a4080e7          	jalr	1444(ra) # 7c <fork1>
     ae0:	c151                	beqz	a0,b64 <main+0xda>
    wait(0);
     ae2:	4501                	li	a0,0
     ae4:	00000097          	auipc	ra,0x0
     ae8:	364080e7          	jalr	868(ra) # e48 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     aec:	85ca                	mv	a1,s2
     aee:	8526                	mv	a0,s1
     af0:	fffff097          	auipc	ra,0xfffff
     af4:	510080e7          	jalr	1296(ra) # 0 <getcmd>
     af8:	08054263          	bltz	a0,b7c <main+0xf2>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     afc:	0004c783          	lbu	a5,0(s1)
     b00:	fd379ce3          	bne	a5,s3,ad8 <main+0x4e>
     b04:	0014c783          	lbu	a5,1(s1)
     b08:	fd2798e3          	bne	a5,s2,ad8 <main+0x4e>
     b0c:	0024c783          	lbu	a5,2(s1)
     b10:	fd4794e3          	bne	a5,s4,ad8 <main+0x4e>
      buf[strlen(buf)-1] = 0;  // chop \n
     b14:	00001a97          	auipc	s5,0x1
     b18:	50ca8a93          	addi	s5,s5,1292 # 2020 <buf.0>
     b1c:	8556                	mv	a0,s5
     b1e:	00000097          	auipc	ra,0x0
     b22:	0d2080e7          	jalr	210(ra) # bf0 <strlen>
     b26:	fff5079b          	addiw	a5,a0,-1
     b2a:	1782                	slli	a5,a5,0x20
     b2c:	9381                	srli	a5,a5,0x20
     b2e:	9abe                	add	s5,s5,a5
     b30:	000a8023          	sb	zero,0(s5)
      if(chdir(buf+3) < 0)
     b34:	00001517          	auipc	a0,0x1
     b38:	4ef50513          	addi	a0,a0,1263 # 2023 <buf.0+0x3>
     b3c:	00000097          	auipc	ra,0x0
     b40:	374080e7          	jalr	884(ra) # eb0 <chdir>
     b44:	fa0554e3          	bgez	a0,aec <main+0x62>
        fprintf(2, "cannot cd %s\n", buf+3);
     b48:	00001617          	auipc	a2,0x1
     b4c:	4db60613          	addi	a2,a2,1243 # 2023 <buf.0+0x3>
     b50:	00001597          	auipc	a1,0x1
     b54:	92058593          	addi	a1,a1,-1760 # 1470 <malloc+0x1fe>
     b58:	4509                	li	a0,2
     b5a:	00000097          	auipc	ra,0x0
     b5e:	62e080e7          	jalr	1582(ra) # 1188 <fprintf>
     b62:	b769                	j	aec <main+0x62>
      runcmd(parsecmd(buf));
     b64:	00001517          	auipc	a0,0x1
     b68:	4bc50513          	addi	a0,a0,1212 # 2020 <buf.0>
     b6c:	00000097          	auipc	ra,0x0
     b70:	e92080e7          	jalr	-366(ra) # 9fe <parsecmd>
     b74:	fffff097          	auipc	ra,0xfffff
     b78:	536080e7          	jalr	1334(ra) # aa <runcmd>
  exit(0);
     b7c:	4501                	li	a0,0
     b7e:	00000097          	auipc	ra,0x0
     b82:	2c2080e7          	jalr	706(ra) # e40 <exit>

0000000000000b86 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     b86:	1141                	addi	sp,sp,-16
     b88:	e406                	sd	ra,8(sp)
     b8a:	e022                	sd	s0,0(sp)
     b8c:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b8e:	00000097          	auipc	ra,0x0
     b92:	efc080e7          	jalr	-260(ra) # a8a <main>
  exit(0);
     b96:	4501                	li	a0,0
     b98:	00000097          	auipc	ra,0x0
     b9c:	2a8080e7          	jalr	680(ra) # e40 <exit>

0000000000000ba0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     ba0:	1141                	addi	sp,sp,-16
     ba2:	e406                	sd	ra,8(sp)
     ba4:	e022                	sd	s0,0(sp)
     ba6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     ba8:	87aa                	mv	a5,a0
     baa:	0585                	addi	a1,a1,1
     bac:	0785                	addi	a5,a5,1
     bae:	fff5c703          	lbu	a4,-1(a1)
     bb2:	fee78fa3          	sb	a4,-1(a5)
     bb6:	fb75                	bnez	a4,baa <strcpy+0xa>
    ;
  return os;
}
     bb8:	60a2                	ld	ra,8(sp)
     bba:	6402                	ld	s0,0(sp)
     bbc:	0141                	addi	sp,sp,16
     bbe:	8082                	ret

0000000000000bc0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bc0:	1141                	addi	sp,sp,-16
     bc2:	e406                	sd	ra,8(sp)
     bc4:	e022                	sd	s0,0(sp)
     bc6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bc8:	00054783          	lbu	a5,0(a0)
     bcc:	cb91                	beqz	a5,be0 <strcmp+0x20>
     bce:	0005c703          	lbu	a4,0(a1)
     bd2:	00f71763          	bne	a4,a5,be0 <strcmp+0x20>
    p++, q++;
     bd6:	0505                	addi	a0,a0,1
     bd8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bda:	00054783          	lbu	a5,0(a0)
     bde:	fbe5                	bnez	a5,bce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     be0:	0005c503          	lbu	a0,0(a1)
}
     be4:	40a7853b          	subw	a0,a5,a0
     be8:	60a2                	ld	ra,8(sp)
     bea:	6402                	ld	s0,0(sp)
     bec:	0141                	addi	sp,sp,16
     bee:	8082                	ret

0000000000000bf0 <strlen>:

uint
strlen(const char *s)
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e406                	sd	ra,8(sp)
     bf4:	e022                	sd	s0,0(sp)
     bf6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     bf8:	00054783          	lbu	a5,0(a0)
     bfc:	cf99                	beqz	a5,c1a <strlen+0x2a>
     bfe:	0505                	addi	a0,a0,1
     c00:	87aa                	mv	a5,a0
     c02:	86be                	mv	a3,a5
     c04:	0785                	addi	a5,a5,1
     c06:	fff7c703          	lbu	a4,-1(a5)
     c0a:	ff65                	bnez	a4,c02 <strlen+0x12>
     c0c:	40a6853b          	subw	a0,a3,a0
     c10:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c12:	60a2                	ld	ra,8(sp)
     c14:	6402                	ld	s0,0(sp)
     c16:	0141                	addi	sp,sp,16
     c18:	8082                	ret
  for(n = 0; s[n]; n++)
     c1a:	4501                	li	a0,0
     c1c:	bfdd                	j	c12 <strlen+0x22>

0000000000000c1e <memset>:

void*
memset(void *dst, int c, uint n)
{
     c1e:	1141                	addi	sp,sp,-16
     c20:	e406                	sd	ra,8(sp)
     c22:	e022                	sd	s0,0(sp)
     c24:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c26:	ca19                	beqz	a2,c3c <memset+0x1e>
     c28:	87aa                	mv	a5,a0
     c2a:	1602                	slli	a2,a2,0x20
     c2c:	9201                	srli	a2,a2,0x20
     c2e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c32:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c36:	0785                	addi	a5,a5,1
     c38:	fee79de3          	bne	a5,a4,c32 <memset+0x14>
  }
  return dst;
}
     c3c:	60a2                	ld	ra,8(sp)
     c3e:	6402                	ld	s0,0(sp)
     c40:	0141                	addi	sp,sp,16
     c42:	8082                	ret

0000000000000c44 <strchr>:

char*
strchr(const char *s, char c)
{
     c44:	1141                	addi	sp,sp,-16
     c46:	e406                	sd	ra,8(sp)
     c48:	e022                	sd	s0,0(sp)
     c4a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c4c:	00054783          	lbu	a5,0(a0)
     c50:	cf81                	beqz	a5,c68 <strchr+0x24>
    if(*s == c)
     c52:	00f58763          	beq	a1,a5,c60 <strchr+0x1c>
  for(; *s; s++)
     c56:	0505                	addi	a0,a0,1
     c58:	00054783          	lbu	a5,0(a0)
     c5c:	fbfd                	bnez	a5,c52 <strchr+0xe>
      return (char*)s;
  return 0;
     c5e:	4501                	li	a0,0
}
     c60:	60a2                	ld	ra,8(sp)
     c62:	6402                	ld	s0,0(sp)
     c64:	0141                	addi	sp,sp,16
     c66:	8082                	ret
  return 0;
     c68:	4501                	li	a0,0
     c6a:	bfdd                	j	c60 <strchr+0x1c>

0000000000000c6c <gets>:

char*
gets(char *buf, int max)
{
     c6c:	7159                	addi	sp,sp,-112
     c6e:	f486                	sd	ra,104(sp)
     c70:	f0a2                	sd	s0,96(sp)
     c72:	eca6                	sd	s1,88(sp)
     c74:	e8ca                	sd	s2,80(sp)
     c76:	e4ce                	sd	s3,72(sp)
     c78:	e0d2                	sd	s4,64(sp)
     c7a:	fc56                	sd	s5,56(sp)
     c7c:	f85a                	sd	s6,48(sp)
     c7e:	f45e                	sd	s7,40(sp)
     c80:	f062                	sd	s8,32(sp)
     c82:	ec66                	sd	s9,24(sp)
     c84:	e86a                	sd	s10,16(sp)
     c86:	1880                	addi	s0,sp,112
     c88:	8caa                	mv	s9,a0
     c8a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c8c:	892a                	mv	s2,a0
     c8e:	4481                	li	s1,0
    cc = read(0, &c, 1);
     c90:	f9f40b13          	addi	s6,s0,-97
     c94:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c96:	4ba9                	li	s7,10
     c98:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
     c9a:	8d26                	mv	s10,s1
     c9c:	0014899b          	addiw	s3,s1,1
     ca0:	84ce                	mv	s1,s3
     ca2:	0349d763          	bge	s3,s4,cd0 <gets+0x64>
    cc = read(0, &c, 1);
     ca6:	8656                	mv	a2,s5
     ca8:	85da                	mv	a1,s6
     caa:	4501                	li	a0,0
     cac:	00000097          	auipc	ra,0x0
     cb0:	1ac080e7          	jalr	428(ra) # e58 <read>
    if(cc < 1)
     cb4:	00a05e63          	blez	a0,cd0 <gets+0x64>
    buf[i++] = c;
     cb8:	f9f44783          	lbu	a5,-97(s0)
     cbc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cc0:	01778763          	beq	a5,s7,cce <gets+0x62>
     cc4:	0905                	addi	s2,s2,1
     cc6:	fd879ae3          	bne	a5,s8,c9a <gets+0x2e>
    buf[i++] = c;
     cca:	8d4e                	mv	s10,s3
     ccc:	a011                	j	cd0 <gets+0x64>
     cce:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
     cd0:	9d66                	add	s10,s10,s9
     cd2:	000d0023          	sb	zero,0(s10)
  return buf;
}
     cd6:	8566                	mv	a0,s9
     cd8:	70a6                	ld	ra,104(sp)
     cda:	7406                	ld	s0,96(sp)
     cdc:	64e6                	ld	s1,88(sp)
     cde:	6946                	ld	s2,80(sp)
     ce0:	69a6                	ld	s3,72(sp)
     ce2:	6a06                	ld	s4,64(sp)
     ce4:	7ae2                	ld	s5,56(sp)
     ce6:	7b42                	ld	s6,48(sp)
     ce8:	7ba2                	ld	s7,40(sp)
     cea:	7c02                	ld	s8,32(sp)
     cec:	6ce2                	ld	s9,24(sp)
     cee:	6d42                	ld	s10,16(sp)
     cf0:	6165                	addi	sp,sp,112
     cf2:	8082                	ret

0000000000000cf4 <stat>:

int
stat(const char *n, struct stat *st)
{
     cf4:	1101                	addi	sp,sp,-32
     cf6:	ec06                	sd	ra,24(sp)
     cf8:	e822                	sd	s0,16(sp)
     cfa:	e04a                	sd	s2,0(sp)
     cfc:	1000                	addi	s0,sp,32
     cfe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d00:	4581                	li	a1,0
     d02:	00000097          	auipc	ra,0x0
     d06:	17e080e7          	jalr	382(ra) # e80 <open>
  if(fd < 0)
     d0a:	02054663          	bltz	a0,d36 <stat+0x42>
     d0e:	e426                	sd	s1,8(sp)
     d10:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d12:	85ca                	mv	a1,s2
     d14:	00000097          	auipc	ra,0x0
     d18:	184080e7          	jalr	388(ra) # e98 <fstat>
     d1c:	892a                	mv	s2,a0
  close(fd);
     d1e:	8526                	mv	a0,s1
     d20:	00000097          	auipc	ra,0x0
     d24:	148080e7          	jalr	328(ra) # e68 <close>
  return r;
     d28:	64a2                	ld	s1,8(sp)
}
     d2a:	854a                	mv	a0,s2
     d2c:	60e2                	ld	ra,24(sp)
     d2e:	6442                	ld	s0,16(sp)
     d30:	6902                	ld	s2,0(sp)
     d32:	6105                	addi	sp,sp,32
     d34:	8082                	ret
    return -1;
     d36:	597d                	li	s2,-1
     d38:	bfcd                	j	d2a <stat+0x36>

0000000000000d3a <atoi>:

int
atoi(const char *s)
{
     d3a:	1141                	addi	sp,sp,-16
     d3c:	e406                	sd	ra,8(sp)
     d3e:	e022                	sd	s0,0(sp)
     d40:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d42:	00054683          	lbu	a3,0(a0)
     d46:	fd06879b          	addiw	a5,a3,-48
     d4a:	0ff7f793          	zext.b	a5,a5
     d4e:	4625                	li	a2,9
     d50:	02f66963          	bltu	a2,a5,d82 <atoi+0x48>
     d54:	872a                	mv	a4,a0
  n = 0;
     d56:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d58:	0705                	addi	a4,a4,1
     d5a:	0025179b          	slliw	a5,a0,0x2
     d5e:	9fa9                	addw	a5,a5,a0
     d60:	0017979b          	slliw	a5,a5,0x1
     d64:	9fb5                	addw	a5,a5,a3
     d66:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d6a:	00074683          	lbu	a3,0(a4)
     d6e:	fd06879b          	addiw	a5,a3,-48
     d72:	0ff7f793          	zext.b	a5,a5
     d76:	fef671e3          	bgeu	a2,a5,d58 <atoi+0x1e>
  return n;
}
     d7a:	60a2                	ld	ra,8(sp)
     d7c:	6402                	ld	s0,0(sp)
     d7e:	0141                	addi	sp,sp,16
     d80:	8082                	ret
  n = 0;
     d82:	4501                	li	a0,0
     d84:	bfdd                	j	d7a <atoi+0x40>

0000000000000d86 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d86:	1141                	addi	sp,sp,-16
     d88:	e406                	sd	ra,8(sp)
     d8a:	e022                	sd	s0,0(sp)
     d8c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d8e:	02b57563          	bgeu	a0,a1,db8 <memmove+0x32>
    while(n-- > 0)
     d92:	00c05f63          	blez	a2,db0 <memmove+0x2a>
     d96:	1602                	slli	a2,a2,0x20
     d98:	9201                	srli	a2,a2,0x20
     d9a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d9e:	872a                	mv	a4,a0
      *dst++ = *src++;
     da0:	0585                	addi	a1,a1,1
     da2:	0705                	addi	a4,a4,1
     da4:	fff5c683          	lbu	a3,-1(a1)
     da8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dac:	fee79ae3          	bne	a5,a4,da0 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     db0:	60a2                	ld	ra,8(sp)
     db2:	6402                	ld	s0,0(sp)
     db4:	0141                	addi	sp,sp,16
     db6:	8082                	ret
    dst += n;
     db8:	00c50733          	add	a4,a0,a2
    src += n;
     dbc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dbe:	fec059e3          	blez	a2,db0 <memmove+0x2a>
     dc2:	fff6079b          	addiw	a5,a2,-1
     dc6:	1782                	slli	a5,a5,0x20
     dc8:	9381                	srli	a5,a5,0x20
     dca:	fff7c793          	not	a5,a5
     dce:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dd0:	15fd                	addi	a1,a1,-1
     dd2:	177d                	addi	a4,a4,-1
     dd4:	0005c683          	lbu	a3,0(a1)
     dd8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     ddc:	fef71ae3          	bne	a4,a5,dd0 <memmove+0x4a>
     de0:	bfc1                	j	db0 <memmove+0x2a>

0000000000000de2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     de2:	1141                	addi	sp,sp,-16
     de4:	e406                	sd	ra,8(sp)
     de6:	e022                	sd	s0,0(sp)
     de8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dea:	ca0d                	beqz	a2,e1c <memcmp+0x3a>
     dec:	fff6069b          	addiw	a3,a2,-1
     df0:	1682                	slli	a3,a3,0x20
     df2:	9281                	srli	a3,a3,0x20
     df4:	0685                	addi	a3,a3,1
     df6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     df8:	00054783          	lbu	a5,0(a0)
     dfc:	0005c703          	lbu	a4,0(a1)
     e00:	00e79863          	bne	a5,a4,e10 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
     e04:	0505                	addi	a0,a0,1
    p2++;
     e06:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e08:	fed518e3          	bne	a0,a3,df8 <memcmp+0x16>
  }
  return 0;
     e0c:	4501                	li	a0,0
     e0e:	a019                	j	e14 <memcmp+0x32>
      return *p1 - *p2;
     e10:	40e7853b          	subw	a0,a5,a4
}
     e14:	60a2                	ld	ra,8(sp)
     e16:	6402                	ld	s0,0(sp)
     e18:	0141                	addi	sp,sp,16
     e1a:	8082                	ret
  return 0;
     e1c:	4501                	li	a0,0
     e1e:	bfdd                	j	e14 <memcmp+0x32>

0000000000000e20 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e20:	1141                	addi	sp,sp,-16
     e22:	e406                	sd	ra,8(sp)
     e24:	e022                	sd	s0,0(sp)
     e26:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e28:	00000097          	auipc	ra,0x0
     e2c:	f5e080e7          	jalr	-162(ra) # d86 <memmove>
}
     e30:	60a2                	ld	ra,8(sp)
     e32:	6402                	ld	s0,0(sp)
     e34:	0141                	addi	sp,sp,16
     e36:	8082                	ret

0000000000000e38 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e38:	4885                	li	a7,1
 ecall
     e3a:	00000073          	ecall
 ret
     e3e:	8082                	ret

0000000000000e40 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e40:	4889                	li	a7,2
 ecall
     e42:	00000073          	ecall
 ret
     e46:	8082                	ret

0000000000000e48 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e48:	488d                	li	a7,3
 ecall
     e4a:	00000073          	ecall
 ret
     e4e:	8082                	ret

0000000000000e50 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e50:	4891                	li	a7,4
 ecall
     e52:	00000073          	ecall
 ret
     e56:	8082                	ret

0000000000000e58 <read>:
.global read
read:
 li a7, SYS_read
     e58:	4895                	li	a7,5
 ecall
     e5a:	00000073          	ecall
 ret
     e5e:	8082                	ret

0000000000000e60 <write>:
.global write
write:
 li a7, SYS_write
     e60:	48c1                	li	a7,16
 ecall
     e62:	00000073          	ecall
 ret
     e66:	8082                	ret

0000000000000e68 <close>:
.global close
close:
 li a7, SYS_close
     e68:	48d5                	li	a7,21
 ecall
     e6a:	00000073          	ecall
 ret
     e6e:	8082                	ret

0000000000000e70 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e70:	4899                	li	a7,6
 ecall
     e72:	00000073          	ecall
 ret
     e76:	8082                	ret

0000000000000e78 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e78:	489d                	li	a7,7
 ecall
     e7a:	00000073          	ecall
 ret
     e7e:	8082                	ret

0000000000000e80 <open>:
.global open
open:
 li a7, SYS_open
     e80:	48bd                	li	a7,15
 ecall
     e82:	00000073          	ecall
 ret
     e86:	8082                	ret

0000000000000e88 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e88:	48c5                	li	a7,17
 ecall
     e8a:	00000073          	ecall
 ret
     e8e:	8082                	ret

0000000000000e90 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e90:	48c9                	li	a7,18
 ecall
     e92:	00000073          	ecall
 ret
     e96:	8082                	ret

0000000000000e98 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e98:	48a1                	li	a7,8
 ecall
     e9a:	00000073          	ecall
 ret
     e9e:	8082                	ret

0000000000000ea0 <link>:
.global link
link:
 li a7, SYS_link
     ea0:	48cd                	li	a7,19
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ea8:	48d1                	li	a7,20
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     eb0:	48a5                	li	a7,9
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <dup>:
.global dup
dup:
 li a7, SYS_dup
     eb8:	48a9                	li	a7,10
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ec0:	48ad                	li	a7,11
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ec8:	48b1                	li	a7,12
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ed0:	48b5                	li	a7,13
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ed8:	48b9                	li	a7,14
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     ee0:	48d9                	li	a7,22
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
     ee8:	48dd                	li	a7,23
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
     ef0:	48e1                	li	a7,24
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
     ef8:	48e5                	li	a7,25
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f00:	1101                	addi	sp,sp,-32
     f02:	ec06                	sd	ra,24(sp)
     f04:	e822                	sd	s0,16(sp)
     f06:	1000                	addi	s0,sp,32
     f08:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f0c:	4605                	li	a2,1
     f0e:	fef40593          	addi	a1,s0,-17
     f12:	00000097          	auipc	ra,0x0
     f16:	f4e080e7          	jalr	-178(ra) # e60 <write>
}
     f1a:	60e2                	ld	ra,24(sp)
     f1c:	6442                	ld	s0,16(sp)
     f1e:	6105                	addi	sp,sp,32
     f20:	8082                	ret

0000000000000f22 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f22:	7139                	addi	sp,sp,-64
     f24:	fc06                	sd	ra,56(sp)
     f26:	f822                	sd	s0,48(sp)
     f28:	f426                	sd	s1,40(sp)
     f2a:	f04a                	sd	s2,32(sp)
     f2c:	ec4e                	sd	s3,24(sp)
     f2e:	0080                	addi	s0,sp,64
     f30:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f32:	c299                	beqz	a3,f38 <printint+0x16>
     f34:	0805c063          	bltz	a1,fb4 <printint+0x92>
  neg = 0;
     f38:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     f3a:	fc040313          	addi	t1,s0,-64
  neg = 0;
     f3e:	869a                	mv	a3,t1
  i = 0;
     f40:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     f42:	00000817          	auipc	a6,0x0
     f46:	5ce80813          	addi	a6,a6,1486 # 1510 <digits>
     f4a:	88be                	mv	a7,a5
     f4c:	0017851b          	addiw	a0,a5,1
     f50:	87aa                	mv	a5,a0
     f52:	02c5f73b          	remuw	a4,a1,a2
     f56:	1702                	slli	a4,a4,0x20
     f58:	9301                	srli	a4,a4,0x20
     f5a:	9742                	add	a4,a4,a6
     f5c:	00074703          	lbu	a4,0(a4)
     f60:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     f64:	872e                	mv	a4,a1
     f66:	02c5d5bb          	divuw	a1,a1,a2
     f6a:	0685                	addi	a3,a3,1
     f6c:	fcc77fe3          	bgeu	a4,a2,f4a <printint+0x28>
  if(neg)
     f70:	000e0c63          	beqz	t3,f88 <printint+0x66>
    buf[i++] = '-';
     f74:	fd050793          	addi	a5,a0,-48
     f78:	00878533          	add	a0,a5,s0
     f7c:	02d00793          	li	a5,45
     f80:	fef50823          	sb	a5,-16(a0)
     f84:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
     f88:	fff7899b          	addiw	s3,a5,-1
     f8c:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
     f90:	fff4c583          	lbu	a1,-1(s1)
     f94:	854a                	mv	a0,s2
     f96:	00000097          	auipc	ra,0x0
     f9a:	f6a080e7          	jalr	-150(ra) # f00 <putc>
  while(--i >= 0)
     f9e:	39fd                	addiw	s3,s3,-1
     fa0:	14fd                	addi	s1,s1,-1
     fa2:	fe09d7e3          	bgez	s3,f90 <printint+0x6e>
}
     fa6:	70e2                	ld	ra,56(sp)
     fa8:	7442                	ld	s0,48(sp)
     faa:	74a2                	ld	s1,40(sp)
     fac:	7902                	ld	s2,32(sp)
     fae:	69e2                	ld	s3,24(sp)
     fb0:	6121                	addi	sp,sp,64
     fb2:	8082                	ret
    x = -xx;
     fb4:	40b005bb          	negw	a1,a1
    neg = 1;
     fb8:	4e05                	li	t3,1
    x = -xx;
     fba:	b741                	j	f3a <printint+0x18>

0000000000000fbc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fbc:	715d                	addi	sp,sp,-80
     fbe:	e486                	sd	ra,72(sp)
     fc0:	e0a2                	sd	s0,64(sp)
     fc2:	f84a                	sd	s2,48(sp)
     fc4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fc6:	0005c903          	lbu	s2,0(a1)
     fca:	1a090a63          	beqz	s2,117e <vprintf+0x1c2>
     fce:	fc26                	sd	s1,56(sp)
     fd0:	f44e                	sd	s3,40(sp)
     fd2:	f052                	sd	s4,32(sp)
     fd4:	ec56                	sd	s5,24(sp)
     fd6:	e85a                	sd	s6,16(sp)
     fd8:	e45e                	sd	s7,8(sp)
     fda:	8aaa                	mv	s5,a0
     fdc:	8bb2                	mv	s7,a2
     fde:	00158493          	addi	s1,a1,1
  state = 0;
     fe2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fe4:	02500a13          	li	s4,37
     fe8:	4b55                	li	s6,21
     fea:	a839                	j	1008 <vprintf+0x4c>
        putc(fd, c);
     fec:	85ca                	mv	a1,s2
     fee:	8556                	mv	a0,s5
     ff0:	00000097          	auipc	ra,0x0
     ff4:	f10080e7          	jalr	-240(ra) # f00 <putc>
     ff8:	a019                	j	ffe <vprintf+0x42>
    } else if(state == '%'){
     ffa:	01498d63          	beq	s3,s4,1014 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
     ffe:	0485                	addi	s1,s1,1
    1000:	fff4c903          	lbu	s2,-1(s1)
    1004:	16090763          	beqz	s2,1172 <vprintf+0x1b6>
    if(state == 0){
    1008:	fe0999e3          	bnez	s3,ffa <vprintf+0x3e>
      if(c == '%'){
    100c:	ff4910e3          	bne	s2,s4,fec <vprintf+0x30>
        state = '%';
    1010:	89d2                	mv	s3,s4
    1012:	b7f5                	j	ffe <vprintf+0x42>
      if(c == 'd'){
    1014:	13490463          	beq	s2,s4,113c <vprintf+0x180>
    1018:	f9d9079b          	addiw	a5,s2,-99
    101c:	0ff7f793          	zext.b	a5,a5
    1020:	12fb6763          	bltu	s6,a5,114e <vprintf+0x192>
    1024:	f9d9079b          	addiw	a5,s2,-99
    1028:	0ff7f713          	zext.b	a4,a5
    102c:	12eb6163          	bltu	s6,a4,114e <vprintf+0x192>
    1030:	00271793          	slli	a5,a4,0x2
    1034:	00000717          	auipc	a4,0x0
    1038:	48470713          	addi	a4,a4,1156 # 14b8 <malloc+0x246>
    103c:	97ba                	add	a5,a5,a4
    103e:	439c                	lw	a5,0(a5)
    1040:	97ba                	add	a5,a5,a4
    1042:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    1044:	008b8913          	addi	s2,s7,8
    1048:	4685                	li	a3,1
    104a:	4629                	li	a2,10
    104c:	000ba583          	lw	a1,0(s7)
    1050:	8556                	mv	a0,s5
    1052:	00000097          	auipc	ra,0x0
    1056:	ed0080e7          	jalr	-304(ra) # f22 <printint>
    105a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    105c:	4981                	li	s3,0
    105e:	b745                	j	ffe <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1060:	008b8913          	addi	s2,s7,8
    1064:	4681                	li	a3,0
    1066:	4629                	li	a2,10
    1068:	000ba583          	lw	a1,0(s7)
    106c:	8556                	mv	a0,s5
    106e:	00000097          	auipc	ra,0x0
    1072:	eb4080e7          	jalr	-332(ra) # f22 <printint>
    1076:	8bca                	mv	s7,s2
      state = 0;
    1078:	4981                	li	s3,0
    107a:	b751                	j	ffe <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    107c:	008b8913          	addi	s2,s7,8
    1080:	4681                	li	a3,0
    1082:	4641                	li	a2,16
    1084:	000ba583          	lw	a1,0(s7)
    1088:	8556                	mv	a0,s5
    108a:	00000097          	auipc	ra,0x0
    108e:	e98080e7          	jalr	-360(ra) # f22 <printint>
    1092:	8bca                	mv	s7,s2
      state = 0;
    1094:	4981                	li	s3,0
    1096:	b7a5                	j	ffe <vprintf+0x42>
    1098:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    109a:	008b8c13          	addi	s8,s7,8
    109e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    10a2:	03000593          	li	a1,48
    10a6:	8556                	mv	a0,s5
    10a8:	00000097          	auipc	ra,0x0
    10ac:	e58080e7          	jalr	-424(ra) # f00 <putc>
  putc(fd, 'x');
    10b0:	07800593          	li	a1,120
    10b4:	8556                	mv	a0,s5
    10b6:	00000097          	auipc	ra,0x0
    10ba:	e4a080e7          	jalr	-438(ra) # f00 <putc>
    10be:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10c0:	00000b97          	auipc	s7,0x0
    10c4:	450b8b93          	addi	s7,s7,1104 # 1510 <digits>
    10c8:	03c9d793          	srli	a5,s3,0x3c
    10cc:	97de                	add	a5,a5,s7
    10ce:	0007c583          	lbu	a1,0(a5)
    10d2:	8556                	mv	a0,s5
    10d4:	00000097          	auipc	ra,0x0
    10d8:	e2c080e7          	jalr	-468(ra) # f00 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10dc:	0992                	slli	s3,s3,0x4
    10de:	397d                	addiw	s2,s2,-1
    10e0:	fe0914e3          	bnez	s2,10c8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    10e4:	8be2                	mv	s7,s8
      state = 0;
    10e6:	4981                	li	s3,0
    10e8:	6c02                	ld	s8,0(sp)
    10ea:	bf11                	j	ffe <vprintf+0x42>
        s = va_arg(ap, char*);
    10ec:	008b8993          	addi	s3,s7,8
    10f0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    10f4:	02090163          	beqz	s2,1116 <vprintf+0x15a>
        while(*s != 0){
    10f8:	00094583          	lbu	a1,0(s2)
    10fc:	c9a5                	beqz	a1,116c <vprintf+0x1b0>
          putc(fd, *s);
    10fe:	8556                	mv	a0,s5
    1100:	00000097          	auipc	ra,0x0
    1104:	e00080e7          	jalr	-512(ra) # f00 <putc>
          s++;
    1108:	0905                	addi	s2,s2,1
        while(*s != 0){
    110a:	00094583          	lbu	a1,0(s2)
    110e:	f9e5                	bnez	a1,10fe <vprintf+0x142>
        s = va_arg(ap, char*);
    1110:	8bce                	mv	s7,s3
      state = 0;
    1112:	4981                	li	s3,0
    1114:	b5ed                	j	ffe <vprintf+0x42>
          s = "(null)";
    1116:	00000917          	auipc	s2,0x0
    111a:	36a90913          	addi	s2,s2,874 # 1480 <malloc+0x20e>
        while(*s != 0){
    111e:	02800593          	li	a1,40
    1122:	bff1                	j	10fe <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    1124:	008b8913          	addi	s2,s7,8
    1128:	000bc583          	lbu	a1,0(s7)
    112c:	8556                	mv	a0,s5
    112e:	00000097          	auipc	ra,0x0
    1132:	dd2080e7          	jalr	-558(ra) # f00 <putc>
    1136:	8bca                	mv	s7,s2
      state = 0;
    1138:	4981                	li	s3,0
    113a:	b5d1                	j	ffe <vprintf+0x42>
        putc(fd, c);
    113c:	02500593          	li	a1,37
    1140:	8556                	mv	a0,s5
    1142:	00000097          	auipc	ra,0x0
    1146:	dbe080e7          	jalr	-578(ra) # f00 <putc>
      state = 0;
    114a:	4981                	li	s3,0
    114c:	bd4d                	j	ffe <vprintf+0x42>
        putc(fd, '%');
    114e:	02500593          	li	a1,37
    1152:	8556                	mv	a0,s5
    1154:	00000097          	auipc	ra,0x0
    1158:	dac080e7          	jalr	-596(ra) # f00 <putc>
        putc(fd, c);
    115c:	85ca                	mv	a1,s2
    115e:	8556                	mv	a0,s5
    1160:	00000097          	auipc	ra,0x0
    1164:	da0080e7          	jalr	-608(ra) # f00 <putc>
      state = 0;
    1168:	4981                	li	s3,0
    116a:	bd51                	j	ffe <vprintf+0x42>
        s = va_arg(ap, char*);
    116c:	8bce                	mv	s7,s3
      state = 0;
    116e:	4981                	li	s3,0
    1170:	b579                	j	ffe <vprintf+0x42>
    1172:	74e2                	ld	s1,56(sp)
    1174:	79a2                	ld	s3,40(sp)
    1176:	7a02                	ld	s4,32(sp)
    1178:	6ae2                	ld	s5,24(sp)
    117a:	6b42                	ld	s6,16(sp)
    117c:	6ba2                	ld	s7,8(sp)
    }
  }
}
    117e:	60a6                	ld	ra,72(sp)
    1180:	6406                	ld	s0,64(sp)
    1182:	7942                	ld	s2,48(sp)
    1184:	6161                	addi	sp,sp,80
    1186:	8082                	ret

0000000000001188 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1188:	715d                	addi	sp,sp,-80
    118a:	ec06                	sd	ra,24(sp)
    118c:	e822                	sd	s0,16(sp)
    118e:	1000                	addi	s0,sp,32
    1190:	e010                	sd	a2,0(s0)
    1192:	e414                	sd	a3,8(s0)
    1194:	e818                	sd	a4,16(s0)
    1196:	ec1c                	sd	a5,24(s0)
    1198:	03043023          	sd	a6,32(s0)
    119c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11a0:	8622                	mv	a2,s0
    11a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11a6:	00000097          	auipc	ra,0x0
    11aa:	e16080e7          	jalr	-490(ra) # fbc <vprintf>
}
    11ae:	60e2                	ld	ra,24(sp)
    11b0:	6442                	ld	s0,16(sp)
    11b2:	6161                	addi	sp,sp,80
    11b4:	8082                	ret

00000000000011b6 <printf>:

void
printf(const char *fmt, ...)
{
    11b6:	711d                	addi	sp,sp,-96
    11b8:	ec06                	sd	ra,24(sp)
    11ba:	e822                	sd	s0,16(sp)
    11bc:	1000                	addi	s0,sp,32
    11be:	e40c                	sd	a1,8(s0)
    11c0:	e810                	sd	a2,16(s0)
    11c2:	ec14                	sd	a3,24(s0)
    11c4:	f018                	sd	a4,32(s0)
    11c6:	f41c                	sd	a5,40(s0)
    11c8:	03043823          	sd	a6,48(s0)
    11cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11d0:	00840613          	addi	a2,s0,8
    11d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11d8:	85aa                	mv	a1,a0
    11da:	4505                	li	a0,1
    11dc:	00000097          	auipc	ra,0x0
    11e0:	de0080e7          	jalr	-544(ra) # fbc <vprintf>
}
    11e4:	60e2                	ld	ra,24(sp)
    11e6:	6442                	ld	s0,16(sp)
    11e8:	6125                	addi	sp,sp,96
    11ea:	8082                	ret

00000000000011ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11ec:	1141                	addi	sp,sp,-16
    11ee:	e406                	sd	ra,8(sp)
    11f0:	e022                	sd	s0,0(sp)
    11f2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11f4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11f8:	00001797          	auipc	a5,0x1
    11fc:	e187b783          	ld	a5,-488(a5) # 2010 <freep>
    1200:	a02d                	j	122a <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1202:	4618                	lw	a4,8(a2)
    1204:	9f2d                	addw	a4,a4,a1
    1206:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    120a:	6398                	ld	a4,0(a5)
    120c:	6310                	ld	a2,0(a4)
    120e:	a83d                	j	124c <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1210:	ff852703          	lw	a4,-8(a0)
    1214:	9f31                	addw	a4,a4,a2
    1216:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1218:	ff053683          	ld	a3,-16(a0)
    121c:	a091                	j	1260 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    121e:	6398                	ld	a4,0(a5)
    1220:	00e7e463          	bltu	a5,a4,1228 <free+0x3c>
    1224:	00e6ea63          	bltu	a3,a4,1238 <free+0x4c>
{
    1228:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    122a:	fed7fae3          	bgeu	a5,a3,121e <free+0x32>
    122e:	6398                	ld	a4,0(a5)
    1230:	00e6e463          	bltu	a3,a4,1238 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1234:	fee7eae3          	bltu	a5,a4,1228 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
    1238:	ff852583          	lw	a1,-8(a0)
    123c:	6390                	ld	a2,0(a5)
    123e:	02059813          	slli	a6,a1,0x20
    1242:	01c85713          	srli	a4,a6,0x1c
    1246:	9736                	add	a4,a4,a3
    1248:	fae60de3          	beq	a2,a4,1202 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
    124c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1250:	4790                	lw	a2,8(a5)
    1252:	02061593          	slli	a1,a2,0x20
    1256:	01c5d713          	srli	a4,a1,0x1c
    125a:	973e                	add	a4,a4,a5
    125c:	fae68ae3          	beq	a3,a4,1210 <free+0x24>
    p->s.ptr = bp->s.ptr;
    1260:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1262:	00001717          	auipc	a4,0x1
    1266:	daf73723          	sd	a5,-594(a4) # 2010 <freep>
}
    126a:	60a2                	ld	ra,8(sp)
    126c:	6402                	ld	s0,0(sp)
    126e:	0141                	addi	sp,sp,16
    1270:	8082                	ret

0000000000001272 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1272:	7139                	addi	sp,sp,-64
    1274:	fc06                	sd	ra,56(sp)
    1276:	f822                	sd	s0,48(sp)
    1278:	f04a                	sd	s2,32(sp)
    127a:	ec4e                	sd	s3,24(sp)
    127c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    127e:	02051993          	slli	s3,a0,0x20
    1282:	0209d993          	srli	s3,s3,0x20
    1286:	09bd                	addi	s3,s3,15
    1288:	0049d993          	srli	s3,s3,0x4
    128c:	2985                	addiw	s3,s3,1
    128e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    1290:	00001517          	auipc	a0,0x1
    1294:	d8053503          	ld	a0,-640(a0) # 2010 <freep>
    1298:	c905                	beqz	a0,12c8 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    129a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    129c:	4798                	lw	a4,8(a5)
    129e:	09377a63          	bgeu	a4,s3,1332 <malloc+0xc0>
    12a2:	f426                	sd	s1,40(sp)
    12a4:	e852                	sd	s4,16(sp)
    12a6:	e456                	sd	s5,8(sp)
    12a8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    12aa:	8a4e                	mv	s4,s3
    12ac:	6705                	lui	a4,0x1
    12ae:	00e9f363          	bgeu	s3,a4,12b4 <malloc+0x42>
    12b2:	6a05                	lui	s4,0x1
    12b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12bc:	00001497          	auipc	s1,0x1
    12c0:	d5448493          	addi	s1,s1,-684 # 2010 <freep>
  if(p == (char*)-1)
    12c4:	5afd                	li	s5,-1
    12c6:	a089                	j	1308 <malloc+0x96>
    12c8:	f426                	sd	s1,40(sp)
    12ca:	e852                	sd	s4,16(sp)
    12cc:	e456                	sd	s5,8(sp)
    12ce:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12d0:	00001797          	auipc	a5,0x1
    12d4:	db878793          	addi	a5,a5,-584 # 2088 <base>
    12d8:	00001717          	auipc	a4,0x1
    12dc:	d2f73c23          	sd	a5,-712(a4) # 2010 <freep>
    12e0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12e2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12e6:	b7d1                	j	12aa <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    12e8:	6398                	ld	a4,0(a5)
    12ea:	e118                	sd	a4,0(a0)
    12ec:	a8b9                	j	134a <malloc+0xd8>
  hp->s.size = nu;
    12ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12f2:	0541                	addi	a0,a0,16
    12f4:	00000097          	auipc	ra,0x0
    12f8:	ef8080e7          	jalr	-264(ra) # 11ec <free>
  return freep;
    12fc:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    12fe:	c135                	beqz	a0,1362 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1300:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1302:	4798                	lw	a4,8(a5)
    1304:	03277363          	bgeu	a4,s2,132a <malloc+0xb8>
    if(p == freep)
    1308:	6098                	ld	a4,0(s1)
    130a:	853e                	mv	a0,a5
    130c:	fef71ae3          	bne	a4,a5,1300 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1310:	8552                	mv	a0,s4
    1312:	00000097          	auipc	ra,0x0
    1316:	bb6080e7          	jalr	-1098(ra) # ec8 <sbrk>
  if(p == (char*)-1)
    131a:	fd551ae3          	bne	a0,s5,12ee <malloc+0x7c>
        return 0;
    131e:	4501                	li	a0,0
    1320:	74a2                	ld	s1,40(sp)
    1322:	6a42                	ld	s4,16(sp)
    1324:	6aa2                	ld	s5,8(sp)
    1326:	6b02                	ld	s6,0(sp)
    1328:	a03d                	j	1356 <malloc+0xe4>
    132a:	74a2                	ld	s1,40(sp)
    132c:	6a42                	ld	s4,16(sp)
    132e:	6aa2                	ld	s5,8(sp)
    1330:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1332:	fae90be3          	beq	s2,a4,12e8 <malloc+0x76>
        p->s.size -= nunits;
    1336:	4137073b          	subw	a4,a4,s3
    133a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    133c:	02071693          	slli	a3,a4,0x20
    1340:	01c6d713          	srli	a4,a3,0x1c
    1344:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1346:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    134a:	00001717          	auipc	a4,0x1
    134e:	cca73323          	sd	a0,-826(a4) # 2010 <freep>
      return (void*)(p + 1);
    1352:	01078513          	addi	a0,a5,16
  }
}
    1356:	70e2                	ld	ra,56(sp)
    1358:	7442                	ld	s0,48(sp)
    135a:	7902                	ld	s2,32(sp)
    135c:	69e2                	ld	s3,24(sp)
    135e:	6121                	addi	sp,sp,64
    1360:	8082                	ret
    1362:	74a2                	ld	s1,40(sp)
    1364:	6a42                	ld	s4,16(sp)
    1366:	6aa2                	ld	s5,8(sp)
    1368:	6b02                	ld	s6,0(sp)
    136a:	b7f5                	j	1356 <malloc+0xe4>
