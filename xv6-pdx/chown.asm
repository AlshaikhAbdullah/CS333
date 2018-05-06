
_chown:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"


int
main (int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	89 cb                	mov    %ecx,%ebx
   if (argc != 3)
  11:	83 3b 03             	cmpl   $0x3,(%ebx)
  14:	74 17                	je     2d <main+0x2d>
   {
      printf(1, "Incorrect Arguments\n");
  16:	83 ec 08             	sub    $0x8,%esp
  19:	68 14 09 00 00       	push   $0x914
  1e:	6a 01                	push   $0x1
  20:	e8 39 05 00 00       	call   55e <printf>
  25:	83 c4 10             	add    $0x10,%esp
      exit();
  28:	e8 5a 03 00 00       	call   387 <exit>
   }
   chown(argv[2], atoi(argv[1]));
  2d:	8b 43 04             	mov    0x4(%ebx),%eax
  30:	83 c0 04             	add    $0x4,%eax
  33:	8b 00                	mov    (%eax),%eax
  35:	83 ec 0c             	sub    $0xc,%esp
  38:	50                   	push   %eax
  39:	e8 e4 01 00 00       	call   222 <atoi>
  3e:	83 c4 10             	add    $0x10,%esp
  41:	89 c2                	mov    %eax,%edx
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	83 c0 08             	add    $0x8,%eax
  49:	8b 00                	mov    (%eax),%eax
  4b:	83 ec 08             	sub    $0x8,%esp
  4e:	52                   	push   %edx
  4f:	50                   	push   %eax
  50:	e8 22 04 00 00       	call   477 <chown>
  55:	83 c4 10             	add    $0x10,%esp
   exit();
  58:	e8 2a 03 00 00       	call   387 <exit>

0000005d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  5d:	55                   	push   %ebp
  5e:	89 e5                	mov    %esp,%ebp
  60:	57                   	push   %edi
  61:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  65:	8b 55 10             	mov    0x10(%ebp),%edx
  68:	8b 45 0c             	mov    0xc(%ebp),%eax
  6b:	89 cb                	mov    %ecx,%ebx
  6d:	89 df                	mov    %ebx,%edi
  6f:	89 d1                	mov    %edx,%ecx
  71:	fc                   	cld    
  72:	f3 aa                	rep stos %al,%es:(%edi)
  74:	89 ca                	mov    %ecx,%edx
  76:	89 fb                	mov    %edi,%ebx
  78:	89 5d 08             	mov    %ebx,0x8(%ebp)
  7b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  7e:	90                   	nop
  7f:	5b                   	pop    %ebx
  80:	5f                   	pop    %edi
  81:	5d                   	pop    %ebp
  82:	c3                   	ret    

00000083 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  83:	55                   	push   %ebp
  84:	89 e5                	mov    %esp,%ebp
  86:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  89:	8b 45 08             	mov    0x8(%ebp),%eax
  8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  8f:	90                   	nop
  90:	8b 45 08             	mov    0x8(%ebp),%eax
  93:	8d 50 01             	lea    0x1(%eax),%edx
  96:	89 55 08             	mov    %edx,0x8(%ebp)
  99:	8b 55 0c             	mov    0xc(%ebp),%edx
  9c:	8d 4a 01             	lea    0x1(%edx),%ecx
  9f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  a2:	0f b6 12             	movzbl (%edx),%edx
  a5:	88 10                	mov    %dl,(%eax)
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	84 c0                	test   %al,%al
  ac:	75 e2                	jne    90 <strcpy+0xd>
    ;
  return os;
  ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b1:	c9                   	leave  
  b2:	c3                   	ret    

000000b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b3:	55                   	push   %ebp
  b4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  b6:	eb 08                	jmp    c0 <strcmp+0xd>
    p++, q++;
  b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	0f b6 00             	movzbl (%eax),%eax
  c6:	84 c0                	test   %al,%al
  c8:	74 10                	je     da <strcmp+0x27>
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	0f b6 10             	movzbl (%eax),%edx
  d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  d3:	0f b6 00             	movzbl (%eax),%eax
  d6:	38 c2                	cmp    %al,%dl
  d8:	74 de                	je     b8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	0f b6 00             	movzbl (%eax),%eax
  e0:	0f b6 d0             	movzbl %al,%edx
  e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	0f b6 c0             	movzbl %al,%eax
  ec:	29 c2                	sub    %eax,%edx
  ee:	89 d0                	mov    %edx,%eax
}
  f0:	5d                   	pop    %ebp
  f1:	c3                   	ret    

000000f2 <strlen>:

uint
strlen(char *s)
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  f5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ff:	eb 04                	jmp    105 <strlen+0x13>
 101:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 105:	8b 55 fc             	mov    -0x4(%ebp),%edx
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	01 d0                	add    %edx,%eax
 10d:	0f b6 00             	movzbl (%eax),%eax
 110:	84 c0                	test   %al,%al
 112:	75 ed                	jne    101 <strlen+0xf>
    ;
  return n;
 114:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 117:	c9                   	leave  
 118:	c3                   	ret    

00000119 <memset>:

void*
memset(void *dst, int c, uint n)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 11c:	8b 45 10             	mov    0x10(%ebp),%eax
 11f:	50                   	push   %eax
 120:	ff 75 0c             	pushl  0xc(%ebp)
 123:	ff 75 08             	pushl  0x8(%ebp)
 126:	e8 32 ff ff ff       	call   5d <stosb>
 12b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 12e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 131:	c9                   	leave  
 132:	c3                   	ret    

00000133 <strchr>:

char*
strchr(const char *s, char c)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	83 ec 04             	sub    $0x4,%esp
 139:	8b 45 0c             	mov    0xc(%ebp),%eax
 13c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 13f:	eb 14                	jmp    155 <strchr+0x22>
    if(*s == c)
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	0f b6 00             	movzbl (%eax),%eax
 147:	3a 45 fc             	cmp    -0x4(%ebp),%al
 14a:	75 05                	jne    151 <strchr+0x1e>
      return (char*)s;
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
 14f:	eb 13                	jmp    164 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 151:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 15f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 164:	c9                   	leave  
 165:	c3                   	ret    

00000166 <gets>:

char*
gets(char *buf, int max)
{
 166:	55                   	push   %ebp
 167:	89 e5                	mov    %esp,%ebp
 169:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 173:	eb 42                	jmp    1b7 <gets+0x51>
    cc = read(0, &c, 1);
 175:	83 ec 04             	sub    $0x4,%esp
 178:	6a 01                	push   $0x1
 17a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 17d:	50                   	push   %eax
 17e:	6a 00                	push   $0x0
 180:	e8 1a 02 00 00       	call   39f <read>
 185:	83 c4 10             	add    $0x10,%esp
 188:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 18b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 18f:	7e 33                	jle    1c4 <gets+0x5e>
      break;
    buf[i++] = c;
 191:	8b 45 f4             	mov    -0xc(%ebp),%eax
 194:	8d 50 01             	lea    0x1(%eax),%edx
 197:	89 55 f4             	mov    %edx,-0xc(%ebp)
 19a:	89 c2                	mov    %eax,%edx
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	01 c2                	add    %eax,%edx
 1a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ab:	3c 0a                	cmp    $0xa,%al
 1ad:	74 16                	je     1c5 <gets+0x5f>
 1af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1b3:	3c 0d                	cmp    $0xd,%al
 1b5:	74 0e                	je     1c5 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ba:	83 c0 01             	add    $0x1,%eax
 1bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1c0:	7c b3                	jl     175 <gets+0xf>
 1c2:	eb 01                	jmp    1c5 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1c4:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	01 d0                	add    %edx,%eax
 1cd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d3:	c9                   	leave  
 1d4:	c3                   	ret    

000001d5 <stat>:

int
stat(char *n, struct stat *st)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1db:	83 ec 08             	sub    $0x8,%esp
 1de:	6a 00                	push   $0x0
 1e0:	ff 75 08             	pushl  0x8(%ebp)
 1e3:	e8 df 01 00 00       	call   3c7 <open>
 1e8:	83 c4 10             	add    $0x10,%esp
 1eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1f2:	79 07                	jns    1fb <stat+0x26>
    return -1;
 1f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f9:	eb 25                	jmp    220 <stat+0x4b>
  r = fstat(fd, st);
 1fb:	83 ec 08             	sub    $0x8,%esp
 1fe:	ff 75 0c             	pushl  0xc(%ebp)
 201:	ff 75 f4             	pushl  -0xc(%ebp)
 204:	e8 d6 01 00 00       	call   3df <fstat>
 209:	83 c4 10             	add    $0x10,%esp
 20c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 20f:	83 ec 0c             	sub    $0xc,%esp
 212:	ff 75 f4             	pushl  -0xc(%ebp)
 215:	e8 95 01 00 00       	call   3af <close>
 21a:	83 c4 10             	add    $0x10,%esp
  return r;
 21d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 220:	c9                   	leave  
 221:	c3                   	ret    

00000222 <atoi>:

int
atoi(const char *s)
{
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
 225:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 22f:	eb 04                	jmp    235 <atoi+0x13>
 231:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	0f b6 00             	movzbl (%eax),%eax
 23b:	3c 20                	cmp    $0x20,%al
 23d:	74 f2                	je     231 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	0f b6 00             	movzbl (%eax),%eax
 245:	3c 2d                	cmp    $0x2d,%al
 247:	75 07                	jne    250 <atoi+0x2e>
 249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 24e:	eb 05                	jmp    255 <atoi+0x33>
 250:	b8 01 00 00 00       	mov    $0x1,%eax
 255:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	3c 2b                	cmp    $0x2b,%al
 260:	74 0a                	je     26c <atoi+0x4a>
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	0f b6 00             	movzbl (%eax),%eax
 268:	3c 2d                	cmp    $0x2d,%al
 26a:	75 2b                	jne    297 <atoi+0x75>
    s++;
 26c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 270:	eb 25                	jmp    297 <atoi+0x75>
    n = n*10 + *s++ - '0';
 272:	8b 55 fc             	mov    -0x4(%ebp),%edx
 275:	89 d0                	mov    %edx,%eax
 277:	c1 e0 02             	shl    $0x2,%eax
 27a:	01 d0                	add    %edx,%eax
 27c:	01 c0                	add    %eax,%eax
 27e:	89 c1                	mov    %eax,%ecx
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	8d 50 01             	lea    0x1(%eax),%edx
 286:	89 55 08             	mov    %edx,0x8(%ebp)
 289:	0f b6 00             	movzbl (%eax),%eax
 28c:	0f be c0             	movsbl %al,%eax
 28f:	01 c8                	add    %ecx,%eax
 291:	83 e8 30             	sub    $0x30,%eax
 294:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	0f b6 00             	movzbl (%eax),%eax
 29d:	3c 2f                	cmp    $0x2f,%al
 29f:	7e 0a                	jle    2ab <atoi+0x89>
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	0f b6 00             	movzbl (%eax),%eax
 2a7:	3c 39                	cmp    $0x39,%al
 2a9:	7e c7                	jle    272 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 2ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2ae:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 2b2:	c9                   	leave  
 2b3:	c3                   	ret    

000002b4 <atoo>:

int
atoo(const char *s)
{
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2c1:	eb 04                	jmp    2c7 <atoo+0x13>
 2c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	0f b6 00             	movzbl (%eax),%eax
 2cd:	3c 20                	cmp    $0x20,%al
 2cf:	74 f2                	je     2c3 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	0f b6 00             	movzbl (%eax),%eax
 2d7:	3c 2d                	cmp    $0x2d,%al
 2d9:	75 07                	jne    2e2 <atoo+0x2e>
 2db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2e0:	eb 05                	jmp    2e7 <atoo+0x33>
 2e2:	b8 01 00 00 00       	mov    $0x1,%eax
 2e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	0f b6 00             	movzbl (%eax),%eax
 2f0:	3c 2b                	cmp    $0x2b,%al
 2f2:	74 0a                	je     2fe <atoo+0x4a>
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	0f b6 00             	movzbl (%eax),%eax
 2fa:	3c 2d                	cmp    $0x2d,%al
 2fc:	75 27                	jne    325 <atoo+0x71>
    s++;
 2fe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 302:	eb 21                	jmp    325 <atoo+0x71>
    n = n*8 + *s++ - '0';
 304:	8b 45 fc             	mov    -0x4(%ebp),%eax
 307:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 30e:	8b 45 08             	mov    0x8(%ebp),%eax
 311:	8d 50 01             	lea    0x1(%eax),%edx
 314:	89 55 08             	mov    %edx,0x8(%ebp)
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	0f be c0             	movsbl %al,%eax
 31d:	01 c8                	add    %ecx,%eax
 31f:	83 e8 30             	sub    $0x30,%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	3c 2f                	cmp    $0x2f,%al
 32d:	7e 0a                	jle    339 <atoo+0x85>
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	3c 37                	cmp    $0x37,%al
 337:	7e cb                	jle    304 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 339:	8b 45 f8             	mov    -0x8(%ebp),%eax
 33c:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 340:	c9                   	leave  
 341:	c3                   	ret    

00000342 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34e:	8b 45 0c             	mov    0xc(%ebp),%eax
 351:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 354:	eb 17                	jmp    36d <memmove+0x2b>
    *dst++ = *src++;
 356:	8b 45 fc             	mov    -0x4(%ebp),%eax
 359:	8d 50 01             	lea    0x1(%eax),%edx
 35c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 35f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 362:	8d 4a 01             	lea    0x1(%edx),%ecx
 365:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 368:	0f b6 12             	movzbl (%edx),%edx
 36b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36d:	8b 45 10             	mov    0x10(%ebp),%eax
 370:	8d 50 ff             	lea    -0x1(%eax),%edx
 373:	89 55 10             	mov    %edx,0x10(%ebp)
 376:	85 c0                	test   %eax,%eax
 378:	7f dc                	jg     356 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37f:	b8 01 00 00 00       	mov    $0x1,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <exit>:
SYSCALL(exit)
 387:	b8 02 00 00 00       	mov    $0x2,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <wait>:
SYSCALL(wait)
 38f:	b8 03 00 00 00       	mov    $0x3,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <pipe>:
SYSCALL(pipe)
 397:	b8 04 00 00 00       	mov    $0x4,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <read>:
SYSCALL(read)
 39f:	b8 05 00 00 00       	mov    $0x5,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <write>:
SYSCALL(write)
 3a7:	b8 10 00 00 00       	mov    $0x10,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <close>:
SYSCALL(close)
 3af:	b8 15 00 00 00       	mov    $0x15,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <kill>:
SYSCALL(kill)
 3b7:	b8 06 00 00 00       	mov    $0x6,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <exec>:
SYSCALL(exec)
 3bf:	b8 07 00 00 00       	mov    $0x7,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <open>:
SYSCALL(open)
 3c7:	b8 0f 00 00 00       	mov    $0xf,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <mknod>:
SYSCALL(mknod)
 3cf:	b8 11 00 00 00       	mov    $0x11,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <unlink>:
SYSCALL(unlink)
 3d7:	b8 12 00 00 00       	mov    $0x12,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <fstat>:
SYSCALL(fstat)
 3df:	b8 08 00 00 00       	mov    $0x8,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <link>:
SYSCALL(link)
 3e7:	b8 13 00 00 00       	mov    $0x13,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <mkdir>:
SYSCALL(mkdir)
 3ef:	b8 14 00 00 00       	mov    $0x14,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <chdir>:
SYSCALL(chdir)
 3f7:	b8 09 00 00 00       	mov    $0x9,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <dup>:
SYSCALL(dup)
 3ff:	b8 0a 00 00 00       	mov    $0xa,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <getpid>:
SYSCALL(getpid)
 407:	b8 0b 00 00 00       	mov    $0xb,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <sbrk>:
SYSCALL(sbrk)
 40f:	b8 0c 00 00 00       	mov    $0xc,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <sleep>:
SYSCALL(sleep)
 417:	b8 0d 00 00 00       	mov    $0xd,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <uptime>:
SYSCALL(uptime)
 41f:	b8 0e 00 00 00       	mov    $0xe,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <halt>:
SYSCALL(halt)
 427:	b8 16 00 00 00       	mov    $0x16,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <date>:
SYSCALL(date)
 42f:	b8 17 00 00 00       	mov    $0x17,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <getuid>:
SYSCALL(getuid)
 437:	b8 18 00 00 00       	mov    $0x18,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <getgid>:
SYSCALL(getgid)
 43f:	b8 19 00 00 00       	mov    $0x19,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <getppid>:
SYSCALL(getppid)
 447:	b8 1a 00 00 00       	mov    $0x1a,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <setuid>:
SYSCALL(setuid)
 44f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <setgid>:
SYSCALL(setgid)
 457:	b8 1c 00 00 00       	mov    $0x1c,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <getprocs>:
SYSCALL(getprocs)
 45f:	b8 1d 00 00 00       	mov    $0x1d,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <setpriority>:
SYSCALL(setpriority)
 467:	b8 1e 00 00 00       	mov    $0x1e,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <chmod>:
SYSCALL(chmod)
 46f:	b8 1f 00 00 00       	mov    $0x1f,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <chown>:
SYSCALL(chown)
 477:	b8 20 00 00 00       	mov    $0x20,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <chgrp>:
SYSCALL(chgrp)
 47f:	b8 21 00 00 00       	mov    $0x21,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 487:	55                   	push   %ebp
 488:	89 e5                	mov    %esp,%ebp
 48a:	83 ec 18             	sub    $0x18,%esp
 48d:	8b 45 0c             	mov    0xc(%ebp),%eax
 490:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 493:	83 ec 04             	sub    $0x4,%esp
 496:	6a 01                	push   $0x1
 498:	8d 45 f4             	lea    -0xc(%ebp),%eax
 49b:	50                   	push   %eax
 49c:	ff 75 08             	pushl  0x8(%ebp)
 49f:	e8 03 ff ff ff       	call   3a7 <write>
 4a4:	83 c4 10             	add    $0x10,%esp
}
 4a7:	90                   	nop
 4a8:	c9                   	leave  
 4a9:	c3                   	ret    

000004aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4aa:	55                   	push   %ebp
 4ab:	89 e5                	mov    %esp,%ebp
 4ad:	53                   	push   %ebx
 4ae:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4bc:	74 17                	je     4d5 <printint+0x2b>
 4be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4c2:	79 11                	jns    4d5 <printint+0x2b>
    neg = 1;
 4c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ce:	f7 d8                	neg    %eax
 4d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d3:	eb 06                	jmp    4db <printint+0x31>
  } else {
    x = xx;
 4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4e2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4e5:	8d 41 01             	lea    0x1(%ecx),%eax
 4e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f1:	ba 00 00 00 00       	mov    $0x0,%edx
 4f6:	f7 f3                	div    %ebx
 4f8:	89 d0                	mov    %edx,%eax
 4fa:	0f b6 80 9c 0b 00 00 	movzbl 0xb9c(%eax),%eax
 501:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 505:	8b 5d 10             	mov    0x10(%ebp),%ebx
 508:	8b 45 ec             	mov    -0x14(%ebp),%eax
 50b:	ba 00 00 00 00       	mov    $0x0,%edx
 510:	f7 f3                	div    %ebx
 512:	89 45 ec             	mov    %eax,-0x14(%ebp)
 515:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 519:	75 c7                	jne    4e2 <printint+0x38>
  if(neg)
 51b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 51f:	74 2d                	je     54e <printint+0xa4>
    buf[i++] = '-';
 521:	8b 45 f4             	mov    -0xc(%ebp),%eax
 524:	8d 50 01             	lea    0x1(%eax),%edx
 527:	89 55 f4             	mov    %edx,-0xc(%ebp)
 52a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 52f:	eb 1d                	jmp    54e <printint+0xa4>
    putc(fd, buf[i]);
 531:	8d 55 dc             	lea    -0x24(%ebp),%edx
 534:	8b 45 f4             	mov    -0xc(%ebp),%eax
 537:	01 d0                	add    %edx,%eax
 539:	0f b6 00             	movzbl (%eax),%eax
 53c:	0f be c0             	movsbl %al,%eax
 53f:	83 ec 08             	sub    $0x8,%esp
 542:	50                   	push   %eax
 543:	ff 75 08             	pushl  0x8(%ebp)
 546:	e8 3c ff ff ff       	call   487 <putc>
 54b:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 54e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 556:	79 d9                	jns    531 <printint+0x87>
    putc(fd, buf[i]);
}
 558:	90                   	nop
 559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 55c:	c9                   	leave  
 55d:	c3                   	ret    

0000055e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 55e:	55                   	push   %ebp
 55f:	89 e5                	mov    %esp,%ebp
 561:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 564:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 56b:	8d 45 0c             	lea    0xc(%ebp),%eax
 56e:	83 c0 04             	add    $0x4,%eax
 571:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 574:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 57b:	e9 59 01 00 00       	jmp    6d9 <printf+0x17b>
    c = fmt[i] & 0xff;
 580:	8b 55 0c             	mov    0xc(%ebp),%edx
 583:	8b 45 f0             	mov    -0x10(%ebp),%eax
 586:	01 d0                	add    %edx,%eax
 588:	0f b6 00             	movzbl (%eax),%eax
 58b:	0f be c0             	movsbl %al,%eax
 58e:	25 ff 00 00 00       	and    $0xff,%eax
 593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 596:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 59a:	75 2c                	jne    5c8 <printf+0x6a>
      if(c == '%'){
 59c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a0:	75 0c                	jne    5ae <printf+0x50>
        state = '%';
 5a2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5a9:	e9 27 01 00 00       	jmp    6d5 <printf+0x177>
      } else {
        putc(fd, c);
 5ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	83 ec 08             	sub    $0x8,%esp
 5b7:	50                   	push   %eax
 5b8:	ff 75 08             	pushl  0x8(%ebp)
 5bb:	e8 c7 fe ff ff       	call   487 <putc>
 5c0:	83 c4 10             	add    $0x10,%esp
 5c3:	e9 0d 01 00 00       	jmp    6d5 <printf+0x177>
      }
    } else if(state == '%'){
 5c8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5cc:	0f 85 03 01 00 00    	jne    6d5 <printf+0x177>
      if(c == 'd'){
 5d2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5d6:	75 1e                	jne    5f6 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5db:	8b 00                	mov    (%eax),%eax
 5dd:	6a 01                	push   $0x1
 5df:	6a 0a                	push   $0xa
 5e1:	50                   	push   %eax
 5e2:	ff 75 08             	pushl  0x8(%ebp)
 5e5:	e8 c0 fe ff ff       	call   4aa <printint>
 5ea:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f1:	e9 d8 00 00 00       	jmp    6ce <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5f6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5fa:	74 06                	je     602 <printf+0xa4>
 5fc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 600:	75 1e                	jne    620 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 602:	8b 45 e8             	mov    -0x18(%ebp),%eax
 605:	8b 00                	mov    (%eax),%eax
 607:	6a 00                	push   $0x0
 609:	6a 10                	push   $0x10
 60b:	50                   	push   %eax
 60c:	ff 75 08             	pushl  0x8(%ebp)
 60f:	e8 96 fe ff ff       	call   4aa <printint>
 614:	83 c4 10             	add    $0x10,%esp
        ap++;
 617:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61b:	e9 ae 00 00 00       	jmp    6ce <printf+0x170>
      } else if(c == 's'){
 620:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 624:	75 43                	jne    669 <printf+0x10b>
        s = (char*)*ap;
 626:	8b 45 e8             	mov    -0x18(%ebp),%eax
 629:	8b 00                	mov    (%eax),%eax
 62b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 62e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 632:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 636:	75 25                	jne    65d <printf+0xff>
          s = "(null)";
 638:	c7 45 f4 29 09 00 00 	movl   $0x929,-0xc(%ebp)
        while(*s != 0){
 63f:	eb 1c                	jmp    65d <printf+0xff>
          putc(fd, *s);
 641:	8b 45 f4             	mov    -0xc(%ebp),%eax
 644:	0f b6 00             	movzbl (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	83 ec 08             	sub    $0x8,%esp
 64d:	50                   	push   %eax
 64e:	ff 75 08             	pushl  0x8(%ebp)
 651:	e8 31 fe ff ff       	call   487 <putc>
 656:	83 c4 10             	add    $0x10,%esp
          s++;
 659:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 65d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 660:	0f b6 00             	movzbl (%eax),%eax
 663:	84 c0                	test   %al,%al
 665:	75 da                	jne    641 <printf+0xe3>
 667:	eb 65                	jmp    6ce <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 669:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 66d:	75 1d                	jne    68c <printf+0x12e>
        putc(fd, *ap);
 66f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	0f be c0             	movsbl %al,%eax
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	50                   	push   %eax
 67b:	ff 75 08             	pushl  0x8(%ebp)
 67e:	e8 04 fe ff ff       	call   487 <putc>
 683:	83 c4 10             	add    $0x10,%esp
        ap++;
 686:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68a:	eb 42                	jmp    6ce <printf+0x170>
      } else if(c == '%'){
 68c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 690:	75 17                	jne    6a9 <printf+0x14b>
        putc(fd, c);
 692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 695:	0f be c0             	movsbl %al,%eax
 698:	83 ec 08             	sub    $0x8,%esp
 69b:	50                   	push   %eax
 69c:	ff 75 08             	pushl  0x8(%ebp)
 69f:	e8 e3 fd ff ff       	call   487 <putc>
 6a4:	83 c4 10             	add    $0x10,%esp
 6a7:	eb 25                	jmp    6ce <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a9:	83 ec 08             	sub    $0x8,%esp
 6ac:	6a 25                	push   $0x25
 6ae:	ff 75 08             	pushl  0x8(%ebp)
 6b1:	e8 d1 fd ff ff       	call   487 <putc>
 6b6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6bc:	0f be c0             	movsbl %al,%eax
 6bf:	83 ec 08             	sub    $0x8,%esp
 6c2:	50                   	push   %eax
 6c3:	ff 75 08             	pushl  0x8(%ebp)
 6c6:	e8 bc fd ff ff       	call   487 <putc>
 6cb:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 6dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6df:	01 d0                	add    %edx,%eax
 6e1:	0f b6 00             	movzbl (%eax),%eax
 6e4:	84 c0                	test   %al,%al
 6e6:	0f 85 94 fe ff ff    	jne    580 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6ec:	90                   	nop
 6ed:	c9                   	leave  
 6ee:	c3                   	ret    

000006ef <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ef:	55                   	push   %ebp
 6f0:	89 e5                	mov    %esp,%ebp
 6f2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	83 e8 08             	sub    $0x8,%eax
 6fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fe:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 703:	89 45 fc             	mov    %eax,-0x4(%ebp)
 706:	eb 24                	jmp    72c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 710:	77 12                	ja     724 <free+0x35>
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 718:	77 24                	ja     73e <free+0x4f>
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	8b 00                	mov    (%eax),%eax
 71f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 722:	77 1a                	ja     73e <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	89 45 fc             	mov    %eax,-0x4(%ebp)
 72c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 732:	76 d4                	jbe    708 <free+0x19>
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 73c:	76 ca                	jbe    708 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 73e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 741:	8b 40 04             	mov    0x4(%eax),%eax
 744:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	01 c2                	add    %eax,%edx
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 00                	mov    (%eax),%eax
 755:	39 c2                	cmp    %eax,%edx
 757:	75 24                	jne    77d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	8b 50 04             	mov    0x4(%eax),%edx
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	8b 00                	mov    (%eax),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	01 c2                	add    %eax,%edx
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	8b 00                	mov    (%eax),%eax
 774:	8b 10                	mov    (%eax),%edx
 776:	8b 45 f8             	mov    -0x8(%ebp),%eax
 779:	89 10                	mov    %edx,(%eax)
 77b:	eb 0a                	jmp    787 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	8b 10                	mov    (%eax),%edx
 782:	8b 45 f8             	mov    -0x8(%ebp),%eax
 785:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	01 d0                	add    %edx,%eax
 799:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 79c:	75 20                	jne    7be <free+0xcf>
    p->s.size += bp->s.size;
 79e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a1:	8b 50 04             	mov    0x4(%eax),%edx
 7a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	01 c2                	add    %eax,%edx
 7ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7af:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b5:	8b 10                	mov    (%eax),%edx
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	89 10                	mov    %edx,(%eax)
 7bc:	eb 08                	jmp    7c6 <free+0xd7>
  } else
    p->s.ptr = bp;
 7be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7c4:	89 10                	mov    %edx,(%eax)
  freep = p;
 7c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c9:	a3 b8 0b 00 00       	mov    %eax,0xbb8
}
 7ce:	90                   	nop
 7cf:	c9                   	leave  
 7d0:	c3                   	ret    

000007d1 <morecore>:

static Header*
morecore(uint nu)
{
 7d1:	55                   	push   %ebp
 7d2:	89 e5                	mov    %esp,%ebp
 7d4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7d7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7de:	77 07                	ja     7e7 <morecore+0x16>
    nu = 4096;
 7e0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	c1 e0 03             	shl    $0x3,%eax
 7ed:	83 ec 0c             	sub    $0xc,%esp
 7f0:	50                   	push   %eax
 7f1:	e8 19 fc ff ff       	call   40f <sbrk>
 7f6:	83 c4 10             	add    $0x10,%esp
 7f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 800:	75 07                	jne    809 <morecore+0x38>
    return 0;
 802:	b8 00 00 00 00       	mov    $0x0,%eax
 807:	eb 26                	jmp    82f <morecore+0x5e>
  hp = (Header*)p;
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 80f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 812:	8b 55 08             	mov    0x8(%ebp),%edx
 815:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	83 c0 08             	add    $0x8,%eax
 81e:	83 ec 0c             	sub    $0xc,%esp
 821:	50                   	push   %eax
 822:	e8 c8 fe ff ff       	call   6ef <free>
 827:	83 c4 10             	add    $0x10,%esp
  return freep;
 82a:	a1 b8 0b 00 00       	mov    0xbb8,%eax
}
 82f:	c9                   	leave  
 830:	c3                   	ret    

00000831 <malloc>:

void*
malloc(uint nbytes)
{
 831:	55                   	push   %ebp
 832:	89 e5                	mov    %esp,%ebp
 834:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 837:	8b 45 08             	mov    0x8(%ebp),%eax
 83a:	83 c0 07             	add    $0x7,%eax
 83d:	c1 e8 03             	shr    $0x3,%eax
 840:	83 c0 01             	add    $0x1,%eax
 843:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 846:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 84b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 84e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 852:	75 23                	jne    877 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 854:	c7 45 f0 b0 0b 00 00 	movl   $0xbb0,-0x10(%ebp)
 85b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85e:	a3 b8 0b 00 00       	mov    %eax,0xbb8
 863:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 868:	a3 b0 0b 00 00       	mov    %eax,0xbb0
    base.s.size = 0;
 86d:	c7 05 b4 0b 00 00 00 	movl   $0x0,0xbb4
 874:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 877:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87a:	8b 00                	mov    (%eax),%eax
 87c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 888:	72 4d                	jb     8d7 <malloc+0xa6>
      if(p->s.size == nunits)
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	8b 40 04             	mov    0x4(%eax),%eax
 890:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 893:	75 0c                	jne    8a1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 895:	8b 45 f4             	mov    -0xc(%ebp),%eax
 898:	8b 10                	mov    (%eax),%edx
 89a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89d:	89 10                	mov    %edx,(%eax)
 89f:	eb 26                	jmp    8c7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a4:	8b 40 04             	mov    0x4(%eax),%eax
 8a7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8aa:	89 c2                	mov    %eax,%edx
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b5:	8b 40 04             	mov    0x4(%eax),%eax
 8b8:	c1 e0 03             	shl    $0x3,%eax
 8bb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8c4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ca:	a3 b8 0b 00 00       	mov    %eax,0xbb8
      return (void*)(p + 1);
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	83 c0 08             	add    $0x8,%eax
 8d5:	eb 3b                	jmp    912 <malloc+0xe1>
    }
    if(p == freep)
 8d7:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 8dc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8df:	75 1e                	jne    8ff <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8e1:	83 ec 0c             	sub    $0xc,%esp
 8e4:	ff 75 ec             	pushl  -0x14(%ebp)
 8e7:	e8 e5 fe ff ff       	call   7d1 <morecore>
 8ec:	83 c4 10             	add    $0x10,%esp
 8ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8f6:	75 07                	jne    8ff <malloc+0xce>
        return 0;
 8f8:	b8 00 00 00 00       	mov    $0x0,%eax
 8fd:	eb 13                	jmp    912 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 902:	89 45 f0             	mov    %eax,-0x10(%ebp)
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 90d:	e9 6d ff ff ff       	jmp    87f <malloc+0x4e>
}
 912:	c9                   	leave  
 913:	c3                   	ret    
