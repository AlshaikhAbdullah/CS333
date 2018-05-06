
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#ifdef CS333_P5
void print_mode(struct stat * st);
#endif
char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	83 ec 0c             	sub    $0xc,%esp
   a:	ff 75 08             	pushl  0x8(%ebp)
   d:	e8 a5 06 00 00       	call   6b7 <strlen>
  12:	83 c4 10             	add    $0x10,%esp
  15:	89 c2                	mov    %eax,%edx
  17:	8b 45 08             	mov    0x8(%ebp),%eax
  1a:	01 d0                	add    %edx,%eax
  1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1f:	eb 04                	jmp    25 <fmtname+0x25>
  21:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  28:	3b 45 08             	cmp    0x8(%ebp),%eax
  2b:	72 0a                	jb     37 <fmtname+0x37>
  2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  30:	0f b6 00             	movzbl (%eax),%eax
  33:	3c 2f                	cmp    $0x2f,%al
  35:	75 ea                	jne    21 <fmtname+0x21>
    ;
  p++;
  37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3b:	83 ec 0c             	sub    $0xc,%esp
  3e:	ff 75 f4             	pushl  -0xc(%ebp)
  41:	e8 71 06 00 00       	call   6b7 <strlen>
  46:	83 c4 10             	add    $0x10,%esp
  49:	83 f8 0d             	cmp    $0xd,%eax
  4c:	76 05                	jbe    53 <fmtname+0x53>
    return p;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	eb 60                	jmp    b3 <fmtname+0xb3>
  memmove(buf, p, strlen(p));
  53:	83 ec 0c             	sub    $0xc,%esp
  56:	ff 75 f4             	pushl  -0xc(%ebp)
  59:	e8 59 06 00 00       	call   6b7 <strlen>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	83 ec 04             	sub    $0x4,%esp
  64:	50                   	push   %eax
  65:	ff 75 f4             	pushl  -0xc(%ebp)
  68:	68 54 12 00 00       	push   $0x1254
  6d:	e8 95 08 00 00       	call   907 <memmove>
  72:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  75:	83 ec 0c             	sub    $0xc,%esp
  78:	ff 75 f4             	pushl  -0xc(%ebp)
  7b:	e8 37 06 00 00       	call   6b7 <strlen>
  80:	83 c4 10             	add    $0x10,%esp
  83:	ba 0e 00 00 00       	mov    $0xe,%edx
  88:	89 d3                	mov    %edx,%ebx
  8a:	29 c3                	sub    %eax,%ebx
  8c:	83 ec 0c             	sub    $0xc,%esp
  8f:	ff 75 f4             	pushl  -0xc(%ebp)
  92:	e8 20 06 00 00       	call   6b7 <strlen>
  97:	83 c4 10             	add    $0x10,%esp
  9a:	05 54 12 00 00       	add    $0x1254,%eax
  9f:	83 ec 04             	sub    $0x4,%esp
  a2:	53                   	push   %ebx
  a3:	6a 20                	push   $0x20
  a5:	50                   	push   %eax
  a6:	e8 33 06 00 00       	call   6de <memset>
  ab:	83 c4 10             	add    $0x10,%esp
  return buf;
  ae:	b8 54 12 00 00       	mov    $0x1254,%eax
}
  b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <ls>:

void
ls(char *path)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	56                   	push   %esi
  bd:	53                   	push   %ebx
  be:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  c4:	83 ec 08             	sub    $0x8,%esp
  c7:	6a 00                	push   $0x0
  c9:	ff 75 08             	pushl  0x8(%ebp)
  cc:	e8 bb 08 00 00       	call   98c <open>
  d1:	83 c4 10             	add    $0x10,%esp
  d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  db:	79 1a                	jns    f7 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	ff 75 08             	pushl  0x8(%ebp)
  e3:	68 dc 0e 00 00       	push   $0xedc
  e8:	6a 02                	push   $0x2
  ea:	e8 34 0a 00 00       	call   b23 <printf>
  ef:	83 c4 10             	add    $0x10,%esp
    return;
  f2:	e9 33 02 00 00       	jmp    32a <ls+0x272>
  }
  
  if(fstat(fd, &st) < 0){
  f7:	83 ec 08             	sub    $0x8,%esp
  fa:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 100:	50                   	push   %eax
 101:	ff 75 e4             	pushl  -0x1c(%ebp)
 104:	e8 9b 08 00 00       	call   9a4 <fstat>
 109:	83 c4 10             	add    $0x10,%esp
 10c:	85 c0                	test   %eax,%eax
 10e:	79 28                	jns    138 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 110:	83 ec 04             	sub    $0x4,%esp
 113:	ff 75 08             	pushl  0x8(%ebp)
 116:	68 f0 0e 00 00       	push   $0xef0
 11b:	6a 02                	push   $0x2
 11d:	e8 01 0a 00 00       	call   b23 <printf>
 122:	83 c4 10             	add    $0x10,%esp
    close(fd);
 125:	83 ec 0c             	sub    $0xc,%esp
 128:	ff 75 e4             	pushl  -0x1c(%ebp)
 12b:	e8 44 08 00 00       	call   974 <close>
 130:	83 c4 10             	add    $0x10,%esp
    return;
 133:	e9 f2 01 00 00       	jmp    32a <ls+0x272>
  }
  
  switch(st.type){
 138:	0f b7 85 b4 fd ff ff 	movzwl -0x24c(%ebp),%eax
 13f:	98                   	cwtl   
 140:	83 f8 01             	cmp    $0x1,%eax
 143:	74 70                	je     1b5 <ls+0xfd>
 145:	83 f8 02             	cmp    $0x2,%eax
 148:	0f 85 ce 01 00 00    	jne    31c <ls+0x264>
  case T_FILE:
#ifdef CS333_P5
      print_mode(&st);
 14e:	83 ec 0c             	sub    $0xc,%esp
 151:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 157:	50                   	push   %eax
 158:	e8 4b 02 00 00       	call   3a8 <print_mode>
 15d:	83 c4 10             	add    $0x10,%esp
      printf(1," %s %d\t%d\t%d\t%d\n", fmtname(path),st.uid,st.gid,st.ino,st.size);
 160:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
 166:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
 16c:	8b bd bc fd ff ff    	mov    -0x244(%ebp),%edi
 172:	0f b7 85 ca fd ff ff 	movzwl -0x236(%ebp),%eax
 179:	0f b7 f0             	movzwl %ax,%esi
 17c:	0f b7 85 c8 fd ff ff 	movzwl -0x238(%ebp),%eax
 183:	0f b7 d8             	movzwl %ax,%ebx
 186:	83 ec 0c             	sub    $0xc,%esp
 189:	ff 75 08             	pushl  0x8(%ebp)
 18c:	e8 6f fe ff ff       	call   0 <fmtname>
 191:	83 c4 10             	add    $0x10,%esp
 194:	83 ec 04             	sub    $0x4,%esp
 197:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
 19d:	57                   	push   %edi
 19e:	56                   	push   %esi
 19f:	53                   	push   %ebx
 1a0:	50                   	push   %eax
 1a1:	68 04 0f 00 00       	push   $0xf04
 1a6:	6a 01                	push   $0x1
 1a8:	e8 76 09 00 00       	call   b23 <printf>
 1ad:	83 c4 20             	add    $0x20,%esp
#else
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
#endif
    break;
 1b0:	e9 67 01 00 00       	jmp    31c <ls+0x264>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1b5:	83 ec 0c             	sub    $0xc,%esp
 1b8:	ff 75 08             	pushl  0x8(%ebp)
 1bb:	e8 f7 04 00 00       	call   6b7 <strlen>
 1c0:	83 c4 10             	add    $0x10,%esp
 1c3:	83 c0 10             	add    $0x10,%eax
 1c6:	3d 00 02 00 00       	cmp    $0x200,%eax
 1cb:	76 17                	jbe    1e4 <ls+0x12c>
      printf(1, "ls: path too long\n");
 1cd:	83 ec 08             	sub    $0x8,%esp
 1d0:	68 15 0f 00 00       	push   $0xf15
 1d5:	6a 01                	push   $0x1
 1d7:	e8 47 09 00 00       	call   b23 <printf>
 1dc:	83 c4 10             	add    $0x10,%esp
      break;
 1df:	e9 38 01 00 00       	jmp    31c <ls+0x264>
    }
    strcpy(buf, path);
 1e4:	83 ec 08             	sub    $0x8,%esp
 1e7:	ff 75 08             	pushl  0x8(%ebp)
 1ea:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1f0:	50                   	push   %eax
 1f1:	e8 52 04 00 00       	call   648 <strcpy>
 1f6:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1f9:	83 ec 0c             	sub    $0xc,%esp
 1fc:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 202:	50                   	push   %eax
 203:	e8 af 04 00 00       	call   6b7 <strlen>
 208:	83 c4 10             	add    $0x10,%esp
 20b:	89 c2                	mov    %eax,%edx
 20d:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 213:	01 d0                	add    %edx,%eax
 215:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 218:	8b 45 e0             	mov    -0x20(%ebp),%eax
 21b:	8d 50 01             	lea    0x1(%eax),%edx
 21e:	89 55 e0             	mov    %edx,-0x20(%ebp)
 221:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 224:	e9 d2 00 00 00       	jmp    2fb <ls+0x243>
      if(de.inum == 0)
 229:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 230:	66 85 c0             	test   %ax,%ax
 233:	75 05                	jne    23a <ls+0x182>
        continue;
 235:	e9 c1 00 00 00       	jmp    2fb <ls+0x243>
      memmove(p, de.name, DIRSIZ);
 23a:	83 ec 04             	sub    $0x4,%esp
 23d:	6a 0e                	push   $0xe
 23f:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 245:	83 c0 02             	add    $0x2,%eax
 248:	50                   	push   %eax
 249:	ff 75 e0             	pushl  -0x20(%ebp)
 24c:	e8 b6 06 00 00       	call   907 <memmove>
 251:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 254:	8b 45 e0             	mov    -0x20(%ebp),%eax
 257:	83 c0 0e             	add    $0xe,%eax
 25a:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 25d:	83 ec 08             	sub    $0x8,%esp
 260:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 266:	50                   	push   %eax
 267:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 26d:	50                   	push   %eax
 26e:	e8 27 05 00 00       	call   79a <stat>
 273:	83 c4 10             	add    $0x10,%esp
 276:	85 c0                	test   %eax,%eax
 278:	79 1b                	jns    295 <ls+0x1dd>
        printf(1, "ls: cannot stat %s\n", buf);
 27a:	83 ec 04             	sub    $0x4,%esp
 27d:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 283:	50                   	push   %eax
 284:	68 f0 0e 00 00       	push   $0xef0
 289:	6a 01                	push   $0x1
 28b:	e8 93 08 00 00       	call   b23 <printf>
 290:	83 c4 10             	add    $0x10,%esp
        continue;
 293:	eb 66                	jmp    2fb <ls+0x243>
      }
#ifdef CS333_P5
      print_mode(&st);
 295:	83 ec 0c             	sub    $0xc,%esp
 298:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
 29e:	50                   	push   %eax
 29f:	e8 04 01 00 00       	call   3a8 <print_mode>
 2a4:	83 c4 10             	add    $0x10,%esp
      printf(1," %s %d\t%d\t%d\t%d\n",fmtname(buf),st.uid,st.gid,st.ino,st.size);
 2a7:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
 2ad:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
 2b3:	8b bd bc fd ff ff    	mov    -0x244(%ebp),%edi
 2b9:	0f b7 85 ca fd ff ff 	movzwl -0x236(%ebp),%eax
 2c0:	0f b7 f0             	movzwl %ax,%esi
 2c3:	0f b7 85 c8 fd ff ff 	movzwl -0x238(%ebp),%eax
 2ca:	0f b7 d8             	movzwl %ax,%ebx
 2cd:	83 ec 0c             	sub    $0xc,%esp
 2d0:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 2d6:	50                   	push   %eax
 2d7:	e8 24 fd ff ff       	call   0 <fmtname>
 2dc:	83 c4 10             	add    $0x10,%esp
 2df:	83 ec 04             	sub    $0x4,%esp
 2e2:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
 2e8:	57                   	push   %edi
 2e9:	56                   	push   %esi
 2ea:	53                   	push   %ebx
 2eb:	50                   	push   %eax
 2ec:	68 04 0f 00 00       	push   $0xf04
 2f1:	6a 01                	push   $0x1
 2f3:	e8 2b 08 00 00       	call   b23 <printf>
 2f8:	83 c4 20             	add    $0x20,%esp
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2fb:	83 ec 04             	sub    $0x4,%esp
 2fe:	6a 10                	push   $0x10
 300:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 306:	50                   	push   %eax
 307:	ff 75 e4             	pushl  -0x1c(%ebp)
 30a:	e8 55 06 00 00       	call   964 <read>
 30f:	83 c4 10             	add    $0x10,%esp
 312:	83 f8 10             	cmp    $0x10,%eax
 315:	0f 84 0e ff ff ff    	je     229 <ls+0x171>
      printf(1," %s %d\t%d\t%d\t%d\n",fmtname(buf),st.uid,st.gid,st.ino,st.size);
#else
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
#endif
    }
    break;
 31b:	90                   	nop
  }
  close(fd);
 31c:	83 ec 0c             	sub    $0xc,%esp
 31f:	ff 75 e4             	pushl  -0x1c(%ebp)
 322:	e8 4d 06 00 00       	call   974 <close>
 327:	83 c4 10             	add    $0x10,%esp
}
 32a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32d:	5b                   	pop    %ebx
 32e:	5e                   	pop    %esi
 32f:	5f                   	pop    %edi
 330:	5d                   	pop    %ebp
 331:	c3                   	ret    

00000332 <main>:

int
main(int argc, char *argv[])
{
 332:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 336:	83 e4 f0             	and    $0xfffffff0,%esp
 339:	ff 71 fc             	pushl  -0x4(%ecx)
 33c:	55                   	push   %ebp
 33d:	89 e5                	mov    %esp,%ebp
 33f:	53                   	push   %ebx
 340:	51                   	push   %ecx
 341:	83 ec 10             	sub    $0x10,%esp
 344:	89 cb                	mov    %ecx,%ebx
  int i;
#ifdef CS333_P5
  printf(1,"mode\t\tname\tuid\tgid\tinode\tsize\n");
 346:	83 ec 08             	sub    $0x8,%esp
 349:	68 28 0f 00 00       	push   $0xf28
 34e:	6a 01                	push   $0x1
 350:	e8 ce 07 00 00       	call   b23 <printf>
 355:	83 c4 10             	add    $0x10,%esp
#endif
  if(argc < 2){
 358:	83 3b 01             	cmpl   $0x1,(%ebx)
 35b:	7f 15                	jg     372 <main+0x40>
    ls(".");
 35d:	83 ec 0c             	sub    $0xc,%esp
 360:	68 47 0f 00 00       	push   $0xf47
 365:	e8 4e fd ff ff       	call   b8 <ls>
 36a:	83 c4 10             	add    $0x10,%esp
    exit();
 36d:	e8 da 05 00 00       	call   94c <exit>
  }
  for(i=1; i<argc; i++)
 372:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 379:	eb 21                	jmp    39c <main+0x6a>
    ls(argv[i]);
 37b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 385:	8b 43 04             	mov    0x4(%ebx),%eax
 388:	01 d0                	add    %edx,%eax
 38a:	8b 00                	mov    (%eax),%eax
 38c:	83 ec 0c             	sub    $0xc,%esp
 38f:	50                   	push   %eax
 390:	e8 23 fd ff ff       	call   b8 <ls>
 395:	83 c4 10             	add    $0x10,%esp
#endif
  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 398:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 39c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39f:	3b 03                	cmp    (%ebx),%eax
 3a1:	7c d8                	jl     37b <main+0x49>
    ls(argv[i]);
  exit();
 3a3:	e8 a4 05 00 00       	call   94c <exit>

000003a8 <print_mode>:
}

#ifdef CS333_P5
void
print_mode(struct stat *  st)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 08             	sub    $0x8,%esp
    switch (st->type)
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	0f b7 00             	movzwl (%eax),%eax
 3b4:	98                   	cwtl   
 3b5:	83 f8 02             	cmp    $0x2,%eax
 3b8:	74 1e                	je     3d8 <print_mode+0x30>
 3ba:	83 f8 03             	cmp    $0x3,%eax
 3bd:	74 2d                	je     3ec <print_mode+0x44>
 3bf:	83 f8 01             	cmp    $0x1,%eax
 3c2:	75 3c                	jne    400 <print_mode+0x58>
    {
        case T_DIR: printf(1,"d"); break;
 3c4:	83 ec 08             	sub    $0x8,%esp
 3c7:	68 49 0f 00 00       	push   $0xf49
 3cc:	6a 01                	push   $0x1
 3ce:	e8 50 07 00 00       	call   b23 <printf>
 3d3:	83 c4 10             	add    $0x10,%esp
 3d6:	eb 3a                	jmp    412 <print_mode+0x6a>
        case T_FILE: printf(1,"-"); break;
 3d8:	83 ec 08             	sub    $0x8,%esp
 3db:	68 4b 0f 00 00       	push   $0xf4b
 3e0:	6a 01                	push   $0x1
 3e2:	e8 3c 07 00 00       	call   b23 <printf>
 3e7:	83 c4 10             	add    $0x10,%esp
 3ea:	eb 26                	jmp    412 <print_mode+0x6a>
        case T_DEV: printf(1,"c"); break;
 3ec:	83 ec 08             	sub    $0x8,%esp
 3ef:	68 4d 0f 00 00       	push   $0xf4d
 3f4:	6a 01                	push   $0x1
 3f6:	e8 28 07 00 00       	call   b23 <printf>
 3fb:	83 c4 10             	add    $0x10,%esp
 3fe:	eb 12                	jmp    412 <print_mode+0x6a>
        default: printf(1,"?");
 400:	83 ec 08             	sub    $0x8,%esp
 403:	68 4f 0f 00 00       	push   $0xf4f
 408:	6a 01                	push   $0x1
 40a:	e8 14 07 00 00       	call   b23 <printf>
 40f:	83 c4 10             	add    $0x10,%esp
    }

    if(st->mode.flags.u_r)
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	0f b6 40 19          	movzbl 0x19(%eax),%eax
 419:	83 e0 01             	and    $0x1,%eax
 41c:	84 c0                	test   %al,%al
 41e:	74 14                	je     434 <print_mode+0x8c>
        printf(1,"r");
 420:	83 ec 08             	sub    $0x8,%esp
 423:	68 51 0f 00 00       	push   $0xf51
 428:	6a 01                	push   $0x1
 42a:	e8 f4 06 00 00       	call   b23 <printf>
 42f:	83 c4 10             	add    $0x10,%esp
 432:	eb 12                	jmp    446 <print_mode+0x9e>
    else
        printf(1,"-");
 434:	83 ec 08             	sub    $0x8,%esp
 437:	68 4b 0f 00 00       	push   $0xf4b
 43c:	6a 01                	push   $0x1
 43e:	e8 e0 06 00 00       	call   b23 <printf>
 443:	83 c4 10             	add    $0x10,%esp

    if(st->mode.flags.u_w)
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 44d:	83 e0 80             	and    $0xffffff80,%eax
 450:	84 c0                	test   %al,%al
 452:	74 14                	je     468 <print_mode+0xc0>
        printf(1,"w");
 454:	83 ec 08             	sub    $0x8,%esp
 457:	68 53 0f 00 00       	push   $0xf53
 45c:	6a 01                	push   $0x1
 45e:	e8 c0 06 00 00       	call   b23 <printf>
 463:	83 c4 10             	add    $0x10,%esp
 466:	eb 12                	jmp    47a <print_mode+0xd2>
    else
        printf(1,"-");
 468:	83 ec 08             	sub    $0x8,%esp
 46b:	68 4b 0f 00 00       	push   $0xf4b
 470:	6a 01                	push   $0x1
 472:	e8 ac 06 00 00       	call   b23 <printf>
 477:	83 c4 10             	add    $0x10,%esp

    if((st->mode.flags.u_x) & (st->mode.flags.setuid))
 47a:	8b 45 08             	mov    0x8(%ebp),%eax
 47d:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 481:	c0 e8 06             	shr    $0x6,%al
 484:	83 e0 01             	and    $0x1,%eax
 487:	0f b6 d0             	movzbl %al,%edx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	0f b6 40 19          	movzbl 0x19(%eax),%eax
 491:	d0 e8                	shr    %al
 493:	83 e0 01             	and    $0x1,%eax
 496:	0f b6 c0             	movzbl %al,%eax
 499:	21 d0                	and    %edx,%eax
 49b:	85 c0                	test   %eax,%eax
 49d:	74 14                	je     4b3 <print_mode+0x10b>
        printf(1,"S");
 49f:	83 ec 08             	sub    $0x8,%esp
 4a2:	68 55 0f 00 00       	push   $0xf55
 4a7:	6a 01                	push   $0x1
 4a9:	e8 75 06 00 00       	call   b23 <printf>
 4ae:	83 c4 10             	add    $0x10,%esp
 4b1:	eb 34                	jmp    4e7 <print_mode+0x13f>
    else if(st->mode.flags.u_x)
 4b3:	8b 45 08             	mov    0x8(%ebp),%eax
 4b6:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 4ba:	83 e0 40             	and    $0x40,%eax
 4bd:	84 c0                	test   %al,%al
 4bf:	74 14                	je     4d5 <print_mode+0x12d>
        printf(1,"x");
 4c1:	83 ec 08             	sub    $0x8,%esp
 4c4:	68 57 0f 00 00       	push   $0xf57
 4c9:	6a 01                	push   $0x1
 4cb:	e8 53 06 00 00       	call   b23 <printf>
 4d0:	83 c4 10             	add    $0x10,%esp
 4d3:	eb 12                	jmp    4e7 <print_mode+0x13f>
    else
        printf(1,"-");
 4d5:	83 ec 08             	sub    $0x8,%esp
 4d8:	68 4b 0f 00 00       	push   $0xf4b
 4dd:	6a 01                	push   $0x1
 4df:	e8 3f 06 00 00       	call   b23 <printf>
 4e4:	83 c4 10             	add    $0x10,%esp

    if(st->mode.flags.g_r)
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 4ee:	83 e0 20             	and    $0x20,%eax
 4f1:	84 c0                	test   %al,%al
 4f3:	74 14                	je     509 <print_mode+0x161>
        printf(1,"r");
 4f5:	83 ec 08             	sub    $0x8,%esp
 4f8:	68 51 0f 00 00       	push   $0xf51
 4fd:	6a 01                	push   $0x1
 4ff:	e8 1f 06 00 00       	call   b23 <printf>
 504:	83 c4 10             	add    $0x10,%esp
 507:	eb 12                	jmp    51b <print_mode+0x173>
    else
        printf(1,"-");
 509:	83 ec 08             	sub    $0x8,%esp
 50c:	68 4b 0f 00 00       	push   $0xf4b
 511:	6a 01                	push   $0x1
 513:	e8 0b 06 00 00       	call   b23 <printf>
 518:	83 c4 10             	add    $0x10,%esp

    if(st->mode.flags.g_w)
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 522:	83 e0 10             	and    $0x10,%eax
 525:	84 c0                	test   %al,%al
 527:	74 14                	je     53d <print_mode+0x195>
        printf(1,"w");
 529:	83 ec 08             	sub    $0x8,%esp
 52c:	68 53 0f 00 00       	push   $0xf53
 531:	6a 01                	push   $0x1
 533:	e8 eb 05 00 00       	call   b23 <printf>
 538:	83 c4 10             	add    $0x10,%esp
 53b:	eb 12                	jmp    54f <print_mode+0x1a7>
    else
        printf(1,"-");
 53d:	83 ec 08             	sub    $0x8,%esp
 540:	68 4b 0f 00 00       	push   $0xf4b
 545:	6a 01                	push   $0x1
 547:	e8 d7 05 00 00       	call   b23 <printf>
 54c:	83 c4 10             	add    $0x10,%esp

    if(st->mode.flags.g_x)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 556:	83 e0 08             	and    $0x8,%eax
 559:	84 c0                	test   %al,%al
 55b:	74 14                	je     571 <print_mode+0x1c9>
        printf(1,"x");
 55d:	83 ec 08             	sub    $0x8,%esp
 560:	68 57 0f 00 00       	push   $0xf57
 565:	6a 01                	push   $0x1
 567:	e8 b7 05 00 00       	call   b23 <printf>
 56c:	83 c4 10             	add    $0x10,%esp
 56f:	eb 12                	jmp    583 <print_mode+0x1db>
    else
        printf(1,"-");
 571:	83 ec 08             	sub    $0x8,%esp
 574:	68 4b 0f 00 00       	push   $0xf4b
 579:	6a 01                	push   $0x1
 57b:	e8 a3 05 00 00       	call   b23 <printf>
 580:	83 c4 10             	add    $0x10,%esp
    if (st->mode.flags.o_r)
 583:	8b 45 08             	mov    0x8(%ebp),%eax
 586:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 58a:	83 e0 04             	and    $0x4,%eax
 58d:	84 c0                	test   %al,%al
 58f:	74 14                	je     5a5 <print_mode+0x1fd>
        printf(1, "r");
 591:	83 ec 08             	sub    $0x8,%esp
 594:	68 51 0f 00 00       	push   $0xf51
 599:	6a 01                	push   $0x1
 59b:	e8 83 05 00 00       	call   b23 <printf>
 5a0:	83 c4 10             	add    $0x10,%esp
 5a3:	eb 12                	jmp    5b7 <print_mode+0x20f>
    else
        printf(1, "-");
 5a5:	83 ec 08             	sub    $0x8,%esp
 5a8:	68 4b 0f 00 00       	push   $0xf4b
 5ad:	6a 01                	push   $0x1
 5af:	e8 6f 05 00 00       	call   b23 <printf>
 5b4:	83 c4 10             	add    $0x10,%esp

    if (st->mode.flags.o_w)
 5b7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ba:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 5be:	83 e0 02             	and    $0x2,%eax
 5c1:	84 c0                	test   %al,%al
 5c3:	74 14                	je     5d9 <print_mode+0x231>
        printf(1, "w");
 5c5:	83 ec 08             	sub    $0x8,%esp
 5c8:	68 53 0f 00 00       	push   $0xf53
 5cd:	6a 01                	push   $0x1
 5cf:	e8 4f 05 00 00       	call   b23 <printf>
 5d4:	83 c4 10             	add    $0x10,%esp
 5d7:	eb 12                	jmp    5eb <print_mode+0x243>
    else
        printf(1, "-");
 5d9:	83 ec 08             	sub    $0x8,%esp
 5dc:	68 4b 0f 00 00       	push   $0xf4b
 5e1:	6a 01                	push   $0x1
 5e3:	e8 3b 05 00 00       	call   b23 <printf>
 5e8:	83 c4 10             	add    $0x10,%esp
    if (st->mode.flags.o_x)
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	0f b6 40 18          	movzbl 0x18(%eax),%eax
 5f2:	83 e0 01             	and    $0x1,%eax
 5f5:	84 c0                	test   %al,%al
 5f7:	74 14                	je     60d <print_mode+0x265>
        printf(1, "x");
 5f9:	83 ec 08             	sub    $0x8,%esp
 5fc:	68 57 0f 00 00       	push   $0xf57
 601:	6a 01                	push   $0x1
 603:	e8 1b 05 00 00       	call   b23 <printf>
 608:	83 c4 10             	add    $0x10,%esp
    else
        printf(1, "-");

  return;
 60b:	eb 13                	jmp    620 <print_mode+0x278>
    else
        printf(1, "-");
    if (st->mode.flags.o_x)
        printf(1, "x");
    else
        printf(1, "-");
 60d:	83 ec 08             	sub    $0x8,%esp
 610:	68 4b 0f 00 00       	push   $0xf4b
 615:	6a 01                	push   $0x1
 617:	e8 07 05 00 00       	call   b23 <printf>
 61c:	83 c4 10             	add    $0x10,%esp

  return;
 61f:	90                   	nop
}
 620:	c9                   	leave  
 621:	c3                   	ret    

00000622 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 622:	55                   	push   %ebp
 623:	89 e5                	mov    %esp,%ebp
 625:	57                   	push   %edi
 626:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 627:	8b 4d 08             	mov    0x8(%ebp),%ecx
 62a:	8b 55 10             	mov    0x10(%ebp),%edx
 62d:	8b 45 0c             	mov    0xc(%ebp),%eax
 630:	89 cb                	mov    %ecx,%ebx
 632:	89 df                	mov    %ebx,%edi
 634:	89 d1                	mov    %edx,%ecx
 636:	fc                   	cld    
 637:	f3 aa                	rep stos %al,%es:(%edi)
 639:	89 ca                	mov    %ecx,%edx
 63b:	89 fb                	mov    %edi,%ebx
 63d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 640:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 643:	90                   	nop
 644:	5b                   	pop    %ebx
 645:	5f                   	pop    %edi
 646:	5d                   	pop    %ebp
 647:	c3                   	ret    

00000648 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 648:	55                   	push   %ebp
 649:	89 e5                	mov    %esp,%ebp
 64b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 64e:	8b 45 08             	mov    0x8(%ebp),%eax
 651:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 654:	90                   	nop
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	8d 50 01             	lea    0x1(%eax),%edx
 65b:	89 55 08             	mov    %edx,0x8(%ebp)
 65e:	8b 55 0c             	mov    0xc(%ebp),%edx
 661:	8d 4a 01             	lea    0x1(%edx),%ecx
 664:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 667:	0f b6 12             	movzbl (%edx),%edx
 66a:	88 10                	mov    %dl,(%eax)
 66c:	0f b6 00             	movzbl (%eax),%eax
 66f:	84 c0                	test   %al,%al
 671:	75 e2                	jne    655 <strcpy+0xd>
    ;
  return os;
 673:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 676:	c9                   	leave  
 677:	c3                   	ret    

00000678 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 67b:	eb 08                	jmp    685 <strcmp+0xd>
    p++, q++;
 67d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 681:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	0f b6 00             	movzbl (%eax),%eax
 68b:	84 c0                	test   %al,%al
 68d:	74 10                	je     69f <strcmp+0x27>
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	0f b6 10             	movzbl (%eax),%edx
 695:	8b 45 0c             	mov    0xc(%ebp),%eax
 698:	0f b6 00             	movzbl (%eax),%eax
 69b:	38 c2                	cmp    %al,%dl
 69d:	74 de                	je     67d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	0f b6 00             	movzbl (%eax),%eax
 6a5:	0f b6 d0             	movzbl %al,%edx
 6a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ab:	0f b6 00             	movzbl (%eax),%eax
 6ae:	0f b6 c0             	movzbl %al,%eax
 6b1:	29 c2                	sub    %eax,%edx
 6b3:	89 d0                	mov    %edx,%eax
}
 6b5:	5d                   	pop    %ebp
 6b6:	c3                   	ret    

000006b7 <strlen>:

uint
strlen(char *s)
{
 6b7:	55                   	push   %ebp
 6b8:	89 e5                	mov    %esp,%ebp
 6ba:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 6bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 6c4:	eb 04                	jmp    6ca <strlen+0x13>
 6c6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
 6d0:	01 d0                	add    %edx,%eax
 6d2:	0f b6 00             	movzbl (%eax),%eax
 6d5:	84 c0                	test   %al,%al
 6d7:	75 ed                	jne    6c6 <strlen+0xf>
    ;
  return n;
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6dc:	c9                   	leave  
 6dd:	c3                   	ret    

000006de <memset>:

void*
memset(void *dst, int c, uint n)
{
 6de:	55                   	push   %ebp
 6df:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 6e1:	8b 45 10             	mov    0x10(%ebp),%eax
 6e4:	50                   	push   %eax
 6e5:	ff 75 0c             	pushl  0xc(%ebp)
 6e8:	ff 75 08             	pushl  0x8(%ebp)
 6eb:	e8 32 ff ff ff       	call   622 <stosb>
 6f0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 6f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6f6:	c9                   	leave  
 6f7:	c3                   	ret    

000006f8 <strchr>:

char*
strchr(const char *s, char c)
{
 6f8:	55                   	push   %ebp
 6f9:	89 e5                	mov    %esp,%ebp
 6fb:	83 ec 04             	sub    $0x4,%esp
 6fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 701:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 704:	eb 14                	jmp    71a <strchr+0x22>
    if(*s == c)
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	0f b6 00             	movzbl (%eax),%eax
 70c:	3a 45 fc             	cmp    -0x4(%ebp),%al
 70f:	75 05                	jne    716 <strchr+0x1e>
      return (char*)s;
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	eb 13                	jmp    729 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 716:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 71a:	8b 45 08             	mov    0x8(%ebp),%eax
 71d:	0f b6 00             	movzbl (%eax),%eax
 720:	84 c0                	test   %al,%al
 722:	75 e2                	jne    706 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 724:	b8 00 00 00 00       	mov    $0x0,%eax
}
 729:	c9                   	leave  
 72a:	c3                   	ret    

0000072b <gets>:

char*
gets(char *buf, int max)
{
 72b:	55                   	push   %ebp
 72c:	89 e5                	mov    %esp,%ebp
 72e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 738:	eb 42                	jmp    77c <gets+0x51>
    cc = read(0, &c, 1);
 73a:	83 ec 04             	sub    $0x4,%esp
 73d:	6a 01                	push   $0x1
 73f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 742:	50                   	push   %eax
 743:	6a 00                	push   $0x0
 745:	e8 1a 02 00 00       	call   964 <read>
 74a:	83 c4 10             	add    $0x10,%esp
 74d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 750:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 754:	7e 33                	jle    789 <gets+0x5e>
      break;
    buf[i++] = c;
 756:	8b 45 f4             	mov    -0xc(%ebp),%eax
 759:	8d 50 01             	lea    0x1(%eax),%edx
 75c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 75f:	89 c2                	mov    %eax,%edx
 761:	8b 45 08             	mov    0x8(%ebp),%eax
 764:	01 c2                	add    %eax,%edx
 766:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 76a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 76c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 770:	3c 0a                	cmp    $0xa,%al
 772:	74 16                	je     78a <gets+0x5f>
 774:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 778:	3c 0d                	cmp    $0xd,%al
 77a:	74 0e                	je     78a <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 77c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77f:	83 c0 01             	add    $0x1,%eax
 782:	3b 45 0c             	cmp    0xc(%ebp),%eax
 785:	7c b3                	jl     73a <gets+0xf>
 787:	eb 01                	jmp    78a <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 789:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 78a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 78d:	8b 45 08             	mov    0x8(%ebp),%eax
 790:	01 d0                	add    %edx,%eax
 792:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 795:	8b 45 08             	mov    0x8(%ebp),%eax
}
 798:	c9                   	leave  
 799:	c3                   	ret    

0000079a <stat>:

int
stat(char *n, struct stat *st)
{
 79a:	55                   	push   %ebp
 79b:	89 e5                	mov    %esp,%ebp
 79d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7a0:	83 ec 08             	sub    $0x8,%esp
 7a3:	6a 00                	push   $0x0
 7a5:	ff 75 08             	pushl  0x8(%ebp)
 7a8:	e8 df 01 00 00       	call   98c <open>
 7ad:	83 c4 10             	add    $0x10,%esp
 7b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 7b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b7:	79 07                	jns    7c0 <stat+0x26>
    return -1;
 7b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7be:	eb 25                	jmp    7e5 <stat+0x4b>
  r = fstat(fd, st);
 7c0:	83 ec 08             	sub    $0x8,%esp
 7c3:	ff 75 0c             	pushl  0xc(%ebp)
 7c6:	ff 75 f4             	pushl  -0xc(%ebp)
 7c9:	e8 d6 01 00 00       	call   9a4 <fstat>
 7ce:	83 c4 10             	add    $0x10,%esp
 7d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7d4:	83 ec 0c             	sub    $0xc,%esp
 7d7:	ff 75 f4             	pushl  -0xc(%ebp)
 7da:	e8 95 01 00 00       	call   974 <close>
 7df:	83 c4 10             	add    $0x10,%esp
  return r;
 7e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7e5:	c9                   	leave  
 7e6:	c3                   	ret    

000007e7 <atoi>:

int
atoi(const char *s)
{
 7e7:	55                   	push   %ebp
 7e8:	89 e5                	mov    %esp,%ebp
 7ea:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 7ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 7f4:	eb 04                	jmp    7fa <atoi+0x13>
 7f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7fa:	8b 45 08             	mov    0x8(%ebp),%eax
 7fd:	0f b6 00             	movzbl (%eax),%eax
 800:	3c 20                	cmp    $0x20,%al
 802:	74 f2                	je     7f6 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 804:	8b 45 08             	mov    0x8(%ebp),%eax
 807:	0f b6 00             	movzbl (%eax),%eax
 80a:	3c 2d                	cmp    $0x2d,%al
 80c:	75 07                	jne    815 <atoi+0x2e>
 80e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 813:	eb 05                	jmp    81a <atoi+0x33>
 815:	b8 01 00 00 00       	mov    $0x1,%eax
 81a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 81d:	8b 45 08             	mov    0x8(%ebp),%eax
 820:	0f b6 00             	movzbl (%eax),%eax
 823:	3c 2b                	cmp    $0x2b,%al
 825:	74 0a                	je     831 <atoi+0x4a>
 827:	8b 45 08             	mov    0x8(%ebp),%eax
 82a:	0f b6 00             	movzbl (%eax),%eax
 82d:	3c 2d                	cmp    $0x2d,%al
 82f:	75 2b                	jne    85c <atoi+0x75>
    s++;
 831:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 835:	eb 25                	jmp    85c <atoi+0x75>
    n = n*10 + *s++ - '0';
 837:	8b 55 fc             	mov    -0x4(%ebp),%edx
 83a:	89 d0                	mov    %edx,%eax
 83c:	c1 e0 02             	shl    $0x2,%eax
 83f:	01 d0                	add    %edx,%eax
 841:	01 c0                	add    %eax,%eax
 843:	89 c1                	mov    %eax,%ecx
 845:	8b 45 08             	mov    0x8(%ebp),%eax
 848:	8d 50 01             	lea    0x1(%eax),%edx
 84b:	89 55 08             	mov    %edx,0x8(%ebp)
 84e:	0f b6 00             	movzbl (%eax),%eax
 851:	0f be c0             	movsbl %al,%eax
 854:	01 c8                	add    %ecx,%eax
 856:	83 e8 30             	sub    $0x30,%eax
 859:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 85c:	8b 45 08             	mov    0x8(%ebp),%eax
 85f:	0f b6 00             	movzbl (%eax),%eax
 862:	3c 2f                	cmp    $0x2f,%al
 864:	7e 0a                	jle    870 <atoi+0x89>
 866:	8b 45 08             	mov    0x8(%ebp),%eax
 869:	0f b6 00             	movzbl (%eax),%eax
 86c:	3c 39                	cmp    $0x39,%al
 86e:	7e c7                	jle    837 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 877:	c9                   	leave  
 878:	c3                   	ret    

00000879 <atoo>:

int
atoo(const char *s)
{
 879:	55                   	push   %ebp
 87a:	89 e5                	mov    %esp,%ebp
 87c:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 87f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 886:	eb 04                	jmp    88c <atoo+0x13>
 888:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 88c:	8b 45 08             	mov    0x8(%ebp),%eax
 88f:	0f b6 00             	movzbl (%eax),%eax
 892:	3c 20                	cmp    $0x20,%al
 894:	74 f2                	je     888 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 896:	8b 45 08             	mov    0x8(%ebp),%eax
 899:	0f b6 00             	movzbl (%eax),%eax
 89c:	3c 2d                	cmp    $0x2d,%al
 89e:	75 07                	jne    8a7 <atoo+0x2e>
 8a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8a5:	eb 05                	jmp    8ac <atoo+0x33>
 8a7:	b8 01 00 00 00       	mov    $0x1,%eax
 8ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	0f b6 00             	movzbl (%eax),%eax
 8b5:	3c 2b                	cmp    $0x2b,%al
 8b7:	74 0a                	je     8c3 <atoo+0x4a>
 8b9:	8b 45 08             	mov    0x8(%ebp),%eax
 8bc:	0f b6 00             	movzbl (%eax),%eax
 8bf:	3c 2d                	cmp    $0x2d,%al
 8c1:	75 27                	jne    8ea <atoo+0x71>
    s++;
 8c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 8c7:	eb 21                	jmp    8ea <atoo+0x71>
    n = n*8 + *s++ - '0';
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	8d 50 01             	lea    0x1(%eax),%edx
 8d9:	89 55 08             	mov    %edx,0x8(%ebp)
 8dc:	0f b6 00             	movzbl (%eax),%eax
 8df:	0f be c0             	movsbl %al,%eax
 8e2:	01 c8                	add    %ecx,%eax
 8e4:	83 e8 30             	sub    $0x30,%eax
 8e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 8ea:	8b 45 08             	mov    0x8(%ebp),%eax
 8ed:	0f b6 00             	movzbl (%eax),%eax
 8f0:	3c 2f                	cmp    $0x2f,%al
 8f2:	7e 0a                	jle    8fe <atoo+0x85>
 8f4:	8b 45 08             	mov    0x8(%ebp),%eax
 8f7:	0f b6 00             	movzbl (%eax),%eax
 8fa:	3c 37                	cmp    $0x37,%al
 8fc:	7e cb                	jle    8c9 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 8fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 901:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 905:	c9                   	leave  
 906:	c3                   	ret    

00000907 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 907:	55                   	push   %ebp
 908:	89 e5                	mov    %esp,%ebp
 90a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 90d:	8b 45 08             	mov    0x8(%ebp),%eax
 910:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 913:	8b 45 0c             	mov    0xc(%ebp),%eax
 916:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 919:	eb 17                	jmp    932 <memmove+0x2b>
    *dst++ = *src++;
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8d 50 01             	lea    0x1(%eax),%edx
 921:	89 55 fc             	mov    %edx,-0x4(%ebp)
 924:	8b 55 f8             	mov    -0x8(%ebp),%edx
 927:	8d 4a 01             	lea    0x1(%edx),%ecx
 92a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 92d:	0f b6 12             	movzbl (%edx),%edx
 930:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 932:	8b 45 10             	mov    0x10(%ebp),%eax
 935:	8d 50 ff             	lea    -0x1(%eax),%edx
 938:	89 55 10             	mov    %edx,0x10(%ebp)
 93b:	85 c0                	test   %eax,%eax
 93d:	7f dc                	jg     91b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 93f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 942:	c9                   	leave  
 943:	c3                   	ret    

00000944 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 944:	b8 01 00 00 00       	mov    $0x1,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <exit>:
SYSCALL(exit)
 94c:	b8 02 00 00 00       	mov    $0x2,%eax
 951:	cd 40                	int    $0x40
 953:	c3                   	ret    

00000954 <wait>:
SYSCALL(wait)
 954:	b8 03 00 00 00       	mov    $0x3,%eax
 959:	cd 40                	int    $0x40
 95b:	c3                   	ret    

0000095c <pipe>:
SYSCALL(pipe)
 95c:	b8 04 00 00 00       	mov    $0x4,%eax
 961:	cd 40                	int    $0x40
 963:	c3                   	ret    

00000964 <read>:
SYSCALL(read)
 964:	b8 05 00 00 00       	mov    $0x5,%eax
 969:	cd 40                	int    $0x40
 96b:	c3                   	ret    

0000096c <write>:
SYSCALL(write)
 96c:	b8 10 00 00 00       	mov    $0x10,%eax
 971:	cd 40                	int    $0x40
 973:	c3                   	ret    

00000974 <close>:
SYSCALL(close)
 974:	b8 15 00 00 00       	mov    $0x15,%eax
 979:	cd 40                	int    $0x40
 97b:	c3                   	ret    

0000097c <kill>:
SYSCALL(kill)
 97c:	b8 06 00 00 00       	mov    $0x6,%eax
 981:	cd 40                	int    $0x40
 983:	c3                   	ret    

00000984 <exec>:
SYSCALL(exec)
 984:	b8 07 00 00 00       	mov    $0x7,%eax
 989:	cd 40                	int    $0x40
 98b:	c3                   	ret    

0000098c <open>:
SYSCALL(open)
 98c:	b8 0f 00 00 00       	mov    $0xf,%eax
 991:	cd 40                	int    $0x40
 993:	c3                   	ret    

00000994 <mknod>:
SYSCALL(mknod)
 994:	b8 11 00 00 00       	mov    $0x11,%eax
 999:	cd 40                	int    $0x40
 99b:	c3                   	ret    

0000099c <unlink>:
SYSCALL(unlink)
 99c:	b8 12 00 00 00       	mov    $0x12,%eax
 9a1:	cd 40                	int    $0x40
 9a3:	c3                   	ret    

000009a4 <fstat>:
SYSCALL(fstat)
 9a4:	b8 08 00 00 00       	mov    $0x8,%eax
 9a9:	cd 40                	int    $0x40
 9ab:	c3                   	ret    

000009ac <link>:
SYSCALL(link)
 9ac:	b8 13 00 00 00       	mov    $0x13,%eax
 9b1:	cd 40                	int    $0x40
 9b3:	c3                   	ret    

000009b4 <mkdir>:
SYSCALL(mkdir)
 9b4:	b8 14 00 00 00       	mov    $0x14,%eax
 9b9:	cd 40                	int    $0x40
 9bb:	c3                   	ret    

000009bc <chdir>:
SYSCALL(chdir)
 9bc:	b8 09 00 00 00       	mov    $0x9,%eax
 9c1:	cd 40                	int    $0x40
 9c3:	c3                   	ret    

000009c4 <dup>:
SYSCALL(dup)
 9c4:	b8 0a 00 00 00       	mov    $0xa,%eax
 9c9:	cd 40                	int    $0x40
 9cb:	c3                   	ret    

000009cc <getpid>:
SYSCALL(getpid)
 9cc:	b8 0b 00 00 00       	mov    $0xb,%eax
 9d1:	cd 40                	int    $0x40
 9d3:	c3                   	ret    

000009d4 <sbrk>:
SYSCALL(sbrk)
 9d4:	b8 0c 00 00 00       	mov    $0xc,%eax
 9d9:	cd 40                	int    $0x40
 9db:	c3                   	ret    

000009dc <sleep>:
SYSCALL(sleep)
 9dc:	b8 0d 00 00 00       	mov    $0xd,%eax
 9e1:	cd 40                	int    $0x40
 9e3:	c3                   	ret    

000009e4 <uptime>:
SYSCALL(uptime)
 9e4:	b8 0e 00 00 00       	mov    $0xe,%eax
 9e9:	cd 40                	int    $0x40
 9eb:	c3                   	ret    

000009ec <halt>:
SYSCALL(halt)
 9ec:	b8 16 00 00 00       	mov    $0x16,%eax
 9f1:	cd 40                	int    $0x40
 9f3:	c3                   	ret    

000009f4 <date>:
SYSCALL(date)
 9f4:	b8 17 00 00 00       	mov    $0x17,%eax
 9f9:	cd 40                	int    $0x40
 9fb:	c3                   	ret    

000009fc <getuid>:
SYSCALL(getuid)
 9fc:	b8 18 00 00 00       	mov    $0x18,%eax
 a01:	cd 40                	int    $0x40
 a03:	c3                   	ret    

00000a04 <getgid>:
SYSCALL(getgid)
 a04:	b8 19 00 00 00       	mov    $0x19,%eax
 a09:	cd 40                	int    $0x40
 a0b:	c3                   	ret    

00000a0c <getppid>:
SYSCALL(getppid)
 a0c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a11:	cd 40                	int    $0x40
 a13:	c3                   	ret    

00000a14 <setuid>:
SYSCALL(setuid)
 a14:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a19:	cd 40                	int    $0x40
 a1b:	c3                   	ret    

00000a1c <setgid>:
SYSCALL(setgid)
 a1c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 a21:	cd 40                	int    $0x40
 a23:	c3                   	ret    

00000a24 <getprocs>:
SYSCALL(getprocs)
 a24:	b8 1d 00 00 00       	mov    $0x1d,%eax
 a29:	cd 40                	int    $0x40
 a2b:	c3                   	ret    

00000a2c <setpriority>:
SYSCALL(setpriority)
 a2c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 a31:	cd 40                	int    $0x40
 a33:	c3                   	ret    

00000a34 <chmod>:
SYSCALL(chmod)
 a34:	b8 1f 00 00 00       	mov    $0x1f,%eax
 a39:	cd 40                	int    $0x40
 a3b:	c3                   	ret    

00000a3c <chown>:
SYSCALL(chown)
 a3c:	b8 20 00 00 00       	mov    $0x20,%eax
 a41:	cd 40                	int    $0x40
 a43:	c3                   	ret    

00000a44 <chgrp>:
SYSCALL(chgrp)
 a44:	b8 21 00 00 00       	mov    $0x21,%eax
 a49:	cd 40                	int    $0x40
 a4b:	c3                   	ret    

00000a4c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 a4c:	55                   	push   %ebp
 a4d:	89 e5                	mov    %esp,%ebp
 a4f:	83 ec 18             	sub    $0x18,%esp
 a52:	8b 45 0c             	mov    0xc(%ebp),%eax
 a55:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 a58:	83 ec 04             	sub    $0x4,%esp
 a5b:	6a 01                	push   $0x1
 a5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a60:	50                   	push   %eax
 a61:	ff 75 08             	pushl  0x8(%ebp)
 a64:	e8 03 ff ff ff       	call   96c <write>
 a69:	83 c4 10             	add    $0x10,%esp
}
 a6c:	90                   	nop
 a6d:	c9                   	leave  
 a6e:	c3                   	ret    

00000a6f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a6f:	55                   	push   %ebp
 a70:	89 e5                	mov    %esp,%ebp
 a72:	53                   	push   %ebx
 a73:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a76:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a7d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a81:	74 17                	je     a9a <printint+0x2b>
 a83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a87:	79 11                	jns    a9a <printint+0x2b>
    neg = 1;
 a89:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a90:	8b 45 0c             	mov    0xc(%ebp),%eax
 a93:	f7 d8                	neg    %eax
 a95:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a98:	eb 06                	jmp    aa0 <printint+0x31>
  } else {
    x = xx;
 a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
 a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 aa7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 aaa:	8d 41 01             	lea    0x1(%ecx),%eax
 aad:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
 ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ab6:	ba 00 00 00 00       	mov    $0x0,%edx
 abb:	f7 f3                	div    %ebx
 abd:	89 d0                	mov    %edx,%eax
 abf:	0f b6 80 40 12 00 00 	movzbl 0x1240(%eax),%eax
 ac6:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
 acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ad0:	ba 00 00 00 00       	mov    $0x0,%edx
 ad5:	f7 f3                	div    %ebx
 ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 ada:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 ade:	75 c7                	jne    aa7 <printint+0x38>
  if(neg)
 ae0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ae4:	74 2d                	je     b13 <printint+0xa4>
    buf[i++] = '-';
 ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae9:	8d 50 01             	lea    0x1(%eax),%edx
 aec:	89 55 f4             	mov    %edx,-0xc(%ebp)
 aef:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 af4:	eb 1d                	jmp    b13 <printint+0xa4>
    putc(fd, buf[i]);
 af6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afc:	01 d0                	add    %edx,%eax
 afe:	0f b6 00             	movzbl (%eax),%eax
 b01:	0f be c0             	movsbl %al,%eax
 b04:	83 ec 08             	sub    $0x8,%esp
 b07:	50                   	push   %eax
 b08:	ff 75 08             	pushl  0x8(%ebp)
 b0b:	e8 3c ff ff ff       	call   a4c <putc>
 b10:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 b13:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 b17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b1b:	79 d9                	jns    af6 <printint+0x87>
    putc(fd, buf[i]);
}
 b1d:	90                   	nop
 b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 b21:	c9                   	leave  
 b22:	c3                   	ret    

00000b23 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 b23:	55                   	push   %ebp
 b24:	89 e5                	mov    %esp,%ebp
 b26:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 b29:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 b30:	8d 45 0c             	lea    0xc(%ebp),%eax
 b33:	83 c0 04             	add    $0x4,%eax
 b36:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 b39:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 b40:	e9 59 01 00 00       	jmp    c9e <printf+0x17b>
    c = fmt[i] & 0xff;
 b45:	8b 55 0c             	mov    0xc(%ebp),%edx
 b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b4b:	01 d0                	add    %edx,%eax
 b4d:	0f b6 00             	movzbl (%eax),%eax
 b50:	0f be c0             	movsbl %al,%eax
 b53:	25 ff 00 00 00       	and    $0xff,%eax
 b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b5f:	75 2c                	jne    b8d <printf+0x6a>
      if(c == '%'){
 b61:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b65:	75 0c                	jne    b73 <printf+0x50>
        state = '%';
 b67:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b6e:	e9 27 01 00 00       	jmp    c9a <printf+0x177>
      } else {
        putc(fd, c);
 b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b76:	0f be c0             	movsbl %al,%eax
 b79:	83 ec 08             	sub    $0x8,%esp
 b7c:	50                   	push   %eax
 b7d:	ff 75 08             	pushl  0x8(%ebp)
 b80:	e8 c7 fe ff ff       	call   a4c <putc>
 b85:	83 c4 10             	add    $0x10,%esp
 b88:	e9 0d 01 00 00       	jmp    c9a <printf+0x177>
      }
    } else if(state == '%'){
 b8d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b91:	0f 85 03 01 00 00    	jne    c9a <printf+0x177>
      if(c == 'd'){
 b97:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b9b:	75 1e                	jne    bbb <printf+0x98>
        printint(fd, *ap, 10, 1);
 b9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ba0:	8b 00                	mov    (%eax),%eax
 ba2:	6a 01                	push   $0x1
 ba4:	6a 0a                	push   $0xa
 ba6:	50                   	push   %eax
 ba7:	ff 75 08             	pushl  0x8(%ebp)
 baa:	e8 c0 fe ff ff       	call   a6f <printint>
 baf:	83 c4 10             	add    $0x10,%esp
        ap++;
 bb2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bb6:	e9 d8 00 00 00       	jmp    c93 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 bbb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 bbf:	74 06                	je     bc7 <printf+0xa4>
 bc1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 bc5:	75 1e                	jne    be5 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 bc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bca:	8b 00                	mov    (%eax),%eax
 bcc:	6a 00                	push   $0x0
 bce:	6a 10                	push   $0x10
 bd0:	50                   	push   %eax
 bd1:	ff 75 08             	pushl  0x8(%ebp)
 bd4:	e8 96 fe ff ff       	call   a6f <printint>
 bd9:	83 c4 10             	add    $0x10,%esp
        ap++;
 bdc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 be0:	e9 ae 00 00 00       	jmp    c93 <printf+0x170>
      } else if(c == 's'){
 be5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 be9:	75 43                	jne    c2e <printf+0x10b>
        s = (char*)*ap;
 beb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bee:	8b 00                	mov    (%eax),%eax
 bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 bf3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bfb:	75 25                	jne    c22 <printf+0xff>
          s = "(null)";
 bfd:	c7 45 f4 59 0f 00 00 	movl   $0xf59,-0xc(%ebp)
        while(*s != 0){
 c04:	eb 1c                	jmp    c22 <printf+0xff>
          putc(fd, *s);
 c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c09:	0f b6 00             	movzbl (%eax),%eax
 c0c:	0f be c0             	movsbl %al,%eax
 c0f:	83 ec 08             	sub    $0x8,%esp
 c12:	50                   	push   %eax
 c13:	ff 75 08             	pushl  0x8(%ebp)
 c16:	e8 31 fe ff ff       	call   a4c <putc>
 c1b:	83 c4 10             	add    $0x10,%esp
          s++;
 c1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c25:	0f b6 00             	movzbl (%eax),%eax
 c28:	84 c0                	test   %al,%al
 c2a:	75 da                	jne    c06 <printf+0xe3>
 c2c:	eb 65                	jmp    c93 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c2e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 c32:	75 1d                	jne    c51 <printf+0x12e>
        putc(fd, *ap);
 c34:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c37:	8b 00                	mov    (%eax),%eax
 c39:	0f be c0             	movsbl %al,%eax
 c3c:	83 ec 08             	sub    $0x8,%esp
 c3f:	50                   	push   %eax
 c40:	ff 75 08             	pushl  0x8(%ebp)
 c43:	e8 04 fe ff ff       	call   a4c <putc>
 c48:	83 c4 10             	add    $0x10,%esp
        ap++;
 c4b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c4f:	eb 42                	jmp    c93 <printf+0x170>
      } else if(c == '%'){
 c51:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c55:	75 17                	jne    c6e <printf+0x14b>
        putc(fd, c);
 c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c5a:	0f be c0             	movsbl %al,%eax
 c5d:	83 ec 08             	sub    $0x8,%esp
 c60:	50                   	push   %eax
 c61:	ff 75 08             	pushl  0x8(%ebp)
 c64:	e8 e3 fd ff ff       	call   a4c <putc>
 c69:	83 c4 10             	add    $0x10,%esp
 c6c:	eb 25                	jmp    c93 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c6e:	83 ec 08             	sub    $0x8,%esp
 c71:	6a 25                	push   $0x25
 c73:	ff 75 08             	pushl  0x8(%ebp)
 c76:	e8 d1 fd ff ff       	call   a4c <putc>
 c7b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c81:	0f be c0             	movsbl %al,%eax
 c84:	83 ec 08             	sub    $0x8,%esp
 c87:	50                   	push   %eax
 c88:	ff 75 08             	pushl  0x8(%ebp)
 c8b:	e8 bc fd ff ff       	call   a4c <putc>
 c90:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 c93:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c9a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
 ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca4:	01 d0                	add    %edx,%eax
 ca6:	0f b6 00             	movzbl (%eax),%eax
 ca9:	84 c0                	test   %al,%al
 cab:	0f 85 94 fe ff ff    	jne    b45 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 cb1:	90                   	nop
 cb2:	c9                   	leave  
 cb3:	c3                   	ret    

00000cb4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cb4:	55                   	push   %ebp
 cb5:	89 e5                	mov    %esp,%ebp
 cb7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cba:	8b 45 08             	mov    0x8(%ebp),%eax
 cbd:	83 e8 08             	sub    $0x8,%eax
 cc0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cc3:	a1 6c 12 00 00       	mov    0x126c,%eax
 cc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ccb:	eb 24                	jmp    cf1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd0:	8b 00                	mov    (%eax),%eax
 cd2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cd5:	77 12                	ja     ce9 <free+0x35>
 cd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cda:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cdd:	77 24                	ja     d03 <free+0x4f>
 cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce2:	8b 00                	mov    (%eax),%eax
 ce4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ce7:	77 1a                	ja     d03 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cec:	8b 00                	mov    (%eax),%eax
 cee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 cf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cf4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cf7:	76 d4                	jbe    ccd <free+0x19>
 cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cfc:	8b 00                	mov    (%eax),%eax
 cfe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d01:	76 ca                	jbe    ccd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 d03:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d06:	8b 40 04             	mov    0x4(%eax),%eax
 d09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d10:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d13:	01 c2                	add    %eax,%edx
 d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d18:	8b 00                	mov    (%eax),%eax
 d1a:	39 c2                	cmp    %eax,%edx
 d1c:	75 24                	jne    d42 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 d1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d21:	8b 50 04             	mov    0x4(%eax),%edx
 d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d27:	8b 00                	mov    (%eax),%eax
 d29:	8b 40 04             	mov    0x4(%eax),%eax
 d2c:	01 c2                	add    %eax,%edx
 d2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d31:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 d34:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d37:	8b 00                	mov    (%eax),%eax
 d39:	8b 10                	mov    (%eax),%edx
 d3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d3e:	89 10                	mov    %edx,(%eax)
 d40:	eb 0a                	jmp    d4c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 d42:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d45:	8b 10                	mov    (%eax),%edx
 d47:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d4a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d4f:	8b 40 04             	mov    0x4(%eax),%eax
 d52:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d5c:	01 d0                	add    %edx,%eax
 d5e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d61:	75 20                	jne    d83 <free+0xcf>
    p->s.size += bp->s.size;
 d63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d66:	8b 50 04             	mov    0x4(%eax),%edx
 d69:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d6c:	8b 40 04             	mov    0x4(%eax),%eax
 d6f:	01 c2                	add    %eax,%edx
 d71:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d74:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d77:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d7a:	8b 10                	mov    (%eax),%edx
 d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d7f:	89 10                	mov    %edx,(%eax)
 d81:	eb 08                	jmp    d8b <free+0xd7>
  } else
    p->s.ptr = bp;
 d83:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d86:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d89:	89 10                	mov    %edx,(%eax)
  freep = p;
 d8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d8e:	a3 6c 12 00 00       	mov    %eax,0x126c
}
 d93:	90                   	nop
 d94:	c9                   	leave  
 d95:	c3                   	ret    

00000d96 <morecore>:

static Header*
morecore(uint nu)
{
 d96:	55                   	push   %ebp
 d97:	89 e5                	mov    %esp,%ebp
 d99:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d9c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 da3:	77 07                	ja     dac <morecore+0x16>
    nu = 4096;
 da5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 dac:	8b 45 08             	mov    0x8(%ebp),%eax
 daf:	c1 e0 03             	shl    $0x3,%eax
 db2:	83 ec 0c             	sub    $0xc,%esp
 db5:	50                   	push   %eax
 db6:	e8 19 fc ff ff       	call   9d4 <sbrk>
 dbb:	83 c4 10             	add    $0x10,%esp
 dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 dc1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 dc5:	75 07                	jne    dce <morecore+0x38>
    return 0;
 dc7:	b8 00 00 00 00       	mov    $0x0,%eax
 dcc:	eb 26                	jmp    df4 <morecore+0x5e>
  hp = (Header*)p;
 dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dd7:	8b 55 08             	mov    0x8(%ebp),%edx
 dda:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 de0:	83 c0 08             	add    $0x8,%eax
 de3:	83 ec 0c             	sub    $0xc,%esp
 de6:	50                   	push   %eax
 de7:	e8 c8 fe ff ff       	call   cb4 <free>
 dec:	83 c4 10             	add    $0x10,%esp
  return freep;
 def:	a1 6c 12 00 00       	mov    0x126c,%eax
}
 df4:	c9                   	leave  
 df5:	c3                   	ret    

00000df6 <malloc>:

void*
malloc(uint nbytes)
{
 df6:	55                   	push   %ebp
 df7:	89 e5                	mov    %esp,%ebp
 df9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 dfc:	8b 45 08             	mov    0x8(%ebp),%eax
 dff:	83 c0 07             	add    $0x7,%eax
 e02:	c1 e8 03             	shr    $0x3,%eax
 e05:	83 c0 01             	add    $0x1,%eax
 e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 e0b:	a1 6c 12 00 00       	mov    0x126c,%eax
 e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 e17:	75 23                	jne    e3c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 e19:	c7 45 f0 64 12 00 00 	movl   $0x1264,-0x10(%ebp)
 e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e23:	a3 6c 12 00 00       	mov    %eax,0x126c
 e28:	a1 6c 12 00 00       	mov    0x126c,%eax
 e2d:	a3 64 12 00 00       	mov    %eax,0x1264
    base.s.size = 0;
 e32:	c7 05 68 12 00 00 00 	movl   $0x0,0x1268
 e39:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e3f:	8b 00                	mov    (%eax),%eax
 e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e47:	8b 40 04             	mov    0x4(%eax),%eax
 e4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e4d:	72 4d                	jb     e9c <malloc+0xa6>
      if(p->s.size == nunits)
 e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e52:	8b 40 04             	mov    0x4(%eax),%eax
 e55:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e58:	75 0c                	jne    e66 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e5d:	8b 10                	mov    (%eax),%edx
 e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e62:	89 10                	mov    %edx,(%eax)
 e64:	eb 26                	jmp    e8c <malloc+0x96>
      else {
        p->s.size -= nunits;
 e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e69:	8b 40 04             	mov    0x4(%eax),%eax
 e6c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e6f:	89 c2                	mov    %eax,%edx
 e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e74:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e7a:	8b 40 04             	mov    0x4(%eax),%eax
 e7d:	c1 e0 03             	shl    $0x3,%eax
 e80:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e86:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e89:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e8f:	a3 6c 12 00 00       	mov    %eax,0x126c
      return (void*)(p + 1);
 e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e97:	83 c0 08             	add    $0x8,%eax
 e9a:	eb 3b                	jmp    ed7 <malloc+0xe1>
    }
    if(p == freep)
 e9c:	a1 6c 12 00 00       	mov    0x126c,%eax
 ea1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ea4:	75 1e                	jne    ec4 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ea6:	83 ec 0c             	sub    $0xc,%esp
 ea9:	ff 75 ec             	pushl  -0x14(%ebp)
 eac:	e8 e5 fe ff ff       	call   d96 <morecore>
 eb1:	83 c4 10             	add    $0x10,%esp
 eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 eb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ebb:	75 07                	jne    ec4 <malloc+0xce>
        return 0;
 ebd:	b8 00 00 00 00       	mov    $0x0,%eax
 ec2:	eb 13                	jmp    ed7 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ec7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ecd:	8b 00                	mov    (%eax),%eax
 ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ed2:	e9 6d ff ff ff       	jmp    e44 <malloc+0x4e>
}
 ed7:	c9                   	leave  
 ed8:	c3                   	ret    
