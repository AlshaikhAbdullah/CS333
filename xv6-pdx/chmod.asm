
_chmod:     file format elf32-i386


Disassembly of section .text:

00000000 <atoi8>:
#include "user.h"
#include "fs.h"
#include "stat.h"
int
atoi8(const char * s)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
    int n, sign;

    n =0;
   6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while(*s == ' ') s++;
   d:	eb 04                	jmp    13 <atoi8+0x13>
   f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	0f b6 00             	movzbl (%eax),%eax
  19:	3c 20                	cmp    $0x20,%al
  1b:	74 f2                	je     f <atoi8+0xf>
    sign = (*s == '-') ? -1 : 1;
  1d:	8b 45 08             	mov    0x8(%ebp),%eax
  20:	0f b6 00             	movzbl (%eax),%eax
  23:	3c 2d                	cmp    $0x2d,%al
  25:	75 07                	jne    2e <atoi8+0x2e>
  27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  2c:	eb 05                	jmp    33 <atoi8+0x33>
  2e:	b8 01 00 00 00       	mov    $0x1,%eax
  33:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(*s == '+' || *s == '-')
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	0f b6 00             	movzbl (%eax),%eax
  3c:	3c 2b                	cmp    $0x2b,%al
  3e:	74 0a                	je     4a <atoi8+0x4a>
  40:	8b 45 08             	mov    0x8(%ebp),%eax
  43:	0f b6 00             	movzbl (%eax),%eax
  46:	3c 2d                	cmp    $0x2d,%al
  48:	75 27                	jne    71 <atoi8+0x71>
        s++;
  4a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while('0' <= *s && *s <= '9')
  4e:	eb 21                	jmp    71 <atoi8+0x71>
        n = n*8 + *s++ - '0';
  50:	8b 45 fc             	mov    -0x4(%ebp),%eax
  53:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  5a:	8b 45 08             	mov    0x8(%ebp),%eax
  5d:	8d 50 01             	lea    0x1(%eax),%edx
  60:	89 55 08             	mov    %edx,0x8(%ebp)
  63:	0f b6 00             	movzbl (%eax),%eax
  66:	0f be c0             	movsbl %al,%eax
  69:	01 c8                	add    %ecx,%eax
  6b:	83 e8 30             	sub    $0x30,%eax
  6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    n =0;
    while(*s == ' ') s++;
    sign = (*s == '-') ? -1 : 1;
    if(*s == '+' || *s == '-')
        s++;
    while('0' <= *s && *s <= '9')
  71:	8b 45 08             	mov    0x8(%ebp),%eax
  74:	0f b6 00             	movzbl (%eax),%eax
  77:	3c 2f                	cmp    $0x2f,%al
  79:	7e 0a                	jle    85 <atoi8+0x85>
  7b:	8b 45 08             	mov    0x8(%ebp),%eax
  7e:	0f b6 00             	movzbl (%eax),%eax
  81:	3c 39                	cmp    $0x39,%al
  83:	7e cb                	jle    50 <atoi8+0x50>
        n = n*8 + *s++ - '0';
    return sign * n;
  85:	8b 45 f8             	mov    -0x8(%ebp),%eax
  88:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
  8c:	c9                   	leave  
  8d:	c3                   	ret    

0000008e <main>:

int
main(int argc, char * argv[])
{
  8e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  92:	83 e4 f0             	and    $0xfffffff0,%esp
  95:	ff 71 fc             	pushl  -0x4(%ecx)
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	53                   	push   %ebx
  9c:	51                   	push   %ecx
  9d:	89 cb                	mov    %ecx,%ebx
    if(argc != 3)
  9f:	83 3b 03             	cmpl   $0x3,(%ebx)
  a2:	74 17                	je     bb <main+0x2d>
    {
        printf(1,"Incorrect Arguments\n");
  a4:	83 ec 08             	sub    $0x8,%esp
  a7:	68 a2 09 00 00       	push   $0x9a2
  ac:	6a 01                	push   $0x1
  ae:	e8 39 05 00 00       	call   5ec <printf>
  b3:	83 c4 10             	add    $0x10,%esp
        exit();
  b6:	e8 5a 03 00 00       	call   415 <exit>
    }
    chmod(argv[2], atoi8(argv[1]));
  bb:	8b 43 04             	mov    0x4(%ebx),%eax
  be:	83 c0 04             	add    $0x4,%eax
  c1:	8b 00                	mov    (%eax),%eax
  c3:	83 ec 0c             	sub    $0xc,%esp
  c6:	50                   	push   %eax
  c7:	e8 34 ff ff ff       	call   0 <atoi8>
  cc:	83 c4 10             	add    $0x10,%esp
  cf:	89 c2                	mov    %eax,%edx
  d1:	8b 43 04             	mov    0x4(%ebx),%eax
  d4:	83 c0 08             	add    $0x8,%eax
  d7:	8b 00                	mov    (%eax),%eax
  d9:	83 ec 08             	sub    $0x8,%esp
  dc:	52                   	push   %edx
  dd:	50                   	push   %eax
  de:	e8 1a 04 00 00       	call   4fd <chmod>
  e3:	83 c4 10             	add    $0x10,%esp
    exit();
  e6:	e8 2a 03 00 00       	call   415 <exit>

000000eb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	57                   	push   %edi
  ef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f3:	8b 55 10             	mov    0x10(%ebp),%edx
  f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  f9:	89 cb                	mov    %ecx,%ebx
  fb:	89 df                	mov    %ebx,%edi
  fd:	89 d1                	mov    %edx,%ecx
  ff:	fc                   	cld    
 100:	f3 aa                	rep stos %al,%es:(%edi)
 102:	89 ca                	mov    %ecx,%edx
 104:	89 fb                	mov    %edi,%ebx
 106:	89 5d 08             	mov    %ebx,0x8(%ebp)
 109:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 10c:	90                   	nop
 10d:	5b                   	pop    %ebx
 10e:	5f                   	pop    %edi
 10f:	5d                   	pop    %ebp
 110:	c3                   	ret    

00000111 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 111:	55                   	push   %ebp
 112:	89 e5                	mov    %esp,%ebp
 114:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 11d:	90                   	nop
 11e:	8b 45 08             	mov    0x8(%ebp),%eax
 121:	8d 50 01             	lea    0x1(%eax),%edx
 124:	89 55 08             	mov    %edx,0x8(%ebp)
 127:	8b 55 0c             	mov    0xc(%ebp),%edx
 12a:	8d 4a 01             	lea    0x1(%edx),%ecx
 12d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 130:	0f b6 12             	movzbl (%edx),%edx
 133:	88 10                	mov    %dl,(%eax)
 135:	0f b6 00             	movzbl (%eax),%eax
 138:	84 c0                	test   %al,%al
 13a:	75 e2                	jne    11e <strcpy+0xd>
    ;
  return os;
 13c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13f:	c9                   	leave  
 140:	c3                   	ret    

00000141 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 144:	eb 08                	jmp    14e <strcmp+0xd>
    p++, q++;
 146:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	74 10                	je     168 <strcmp+0x27>
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 10             	movzbl (%eax),%edx
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	0f b6 00             	movzbl (%eax),%eax
 164:	38 c2                	cmp    %al,%dl
 166:	74 de                	je     146 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	0f b6 d0             	movzbl %al,%edx
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	0f b6 c0             	movzbl %al,%eax
 17a:	29 c2                	sub    %eax,%edx
 17c:	89 d0                	mov    %edx,%eax
}
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <strlen>:

uint
strlen(char *s)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 186:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 18d:	eb 04                	jmp    193 <strlen+0x13>
 18f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 193:	8b 55 fc             	mov    -0x4(%ebp),%edx
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	01 d0                	add    %edx,%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	84 c0                	test   %al,%al
 1a0:	75 ed                	jne    18f <strlen+0xf>
    ;
  return n;
 1a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a5:	c9                   	leave  
 1a6:	c3                   	ret    

000001a7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a7:	55                   	push   %ebp
 1a8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1aa:	8b 45 10             	mov    0x10(%ebp),%eax
 1ad:	50                   	push   %eax
 1ae:	ff 75 0c             	pushl  0xc(%ebp)
 1b1:	ff 75 08             	pushl  0x8(%ebp)
 1b4:	e8 32 ff ff ff       	call   eb <stosb>
 1b9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1bf:	c9                   	leave  
 1c0:	c3                   	ret    

000001c1 <strchr>:

char*
strchr(const char *s, char c)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1cd:	eb 14                	jmp    1e3 <strchr+0x22>
    if(*s == c)
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1d8:	75 05                	jne    1df <strchr+0x1e>
      return (char*)s;
 1da:	8b 45 08             	mov    0x8(%ebp),%eax
 1dd:	eb 13                	jmp    1f2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	0f b6 00             	movzbl (%eax),%eax
 1e9:	84 c0                	test   %al,%al
 1eb:	75 e2                	jne    1cf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f2:	c9                   	leave  
 1f3:	c3                   	ret    

000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 201:	eb 42                	jmp    245 <gets+0x51>
    cc = read(0, &c, 1);
 203:	83 ec 04             	sub    $0x4,%esp
 206:	6a 01                	push   $0x1
 208:	8d 45 ef             	lea    -0x11(%ebp),%eax
 20b:	50                   	push   %eax
 20c:	6a 00                	push   $0x0
 20e:	e8 1a 02 00 00       	call   42d <read>
 213:	83 c4 10             	add    $0x10,%esp
 216:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 219:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 21d:	7e 33                	jle    252 <gets+0x5e>
      break;
    buf[i++] = c;
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	8d 50 01             	lea    0x1(%eax),%edx
 225:	89 55 f4             	mov    %edx,-0xc(%ebp)
 228:	89 c2                	mov    %eax,%edx
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	01 c2                	add    %eax,%edx
 22f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 233:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 235:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 239:	3c 0a                	cmp    $0xa,%al
 23b:	74 16                	je     253 <gets+0x5f>
 23d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 241:	3c 0d                	cmp    $0xd,%al
 243:	74 0e                	je     253 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 245:	8b 45 f4             	mov    -0xc(%ebp),%eax
 248:	83 c0 01             	add    $0x1,%eax
 24b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 24e:	7c b3                	jl     203 <gets+0xf>
 250:	eb 01                	jmp    253 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 252:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 253:	8b 55 f4             	mov    -0xc(%ebp),%edx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	01 d0                	add    %edx,%eax
 25b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 261:	c9                   	leave  
 262:	c3                   	ret    

00000263 <stat>:

int
stat(char *n, struct stat *st)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 269:	83 ec 08             	sub    $0x8,%esp
 26c:	6a 00                	push   $0x0
 26e:	ff 75 08             	pushl  0x8(%ebp)
 271:	e8 df 01 00 00       	call   455 <open>
 276:	83 c4 10             	add    $0x10,%esp
 279:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 27c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 280:	79 07                	jns    289 <stat+0x26>
    return -1;
 282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 287:	eb 25                	jmp    2ae <stat+0x4b>
  r = fstat(fd, st);
 289:	83 ec 08             	sub    $0x8,%esp
 28c:	ff 75 0c             	pushl  0xc(%ebp)
 28f:	ff 75 f4             	pushl  -0xc(%ebp)
 292:	e8 d6 01 00 00       	call   46d <fstat>
 297:	83 c4 10             	add    $0x10,%esp
 29a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 29d:	83 ec 0c             	sub    $0xc,%esp
 2a0:	ff 75 f4             	pushl  -0xc(%ebp)
 2a3:	e8 95 01 00 00       	call   43d <close>
 2a8:	83 c4 10             	add    $0x10,%esp
  return r;
 2ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <atoi>:

int
atoi(const char *s)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2bd:	eb 04                	jmp    2c3 <atoi+0x13>
 2bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	0f b6 00             	movzbl (%eax),%eax
 2c9:	3c 20                	cmp    $0x20,%al
 2cb:	74 f2                	je     2bf <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	0f b6 00             	movzbl (%eax),%eax
 2d3:	3c 2d                	cmp    $0x2d,%al
 2d5:	75 07                	jne    2de <atoi+0x2e>
 2d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2dc:	eb 05                	jmp    2e3 <atoi+0x33>
 2de:	b8 01 00 00 00       	mov    $0x1,%eax
 2e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
 2e9:	0f b6 00             	movzbl (%eax),%eax
 2ec:	3c 2b                	cmp    $0x2b,%al
 2ee:	74 0a                	je     2fa <atoi+0x4a>
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	0f b6 00             	movzbl (%eax),%eax
 2f6:	3c 2d                	cmp    $0x2d,%al
 2f8:	75 2b                	jne    325 <atoi+0x75>
    s++;
 2fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 2fe:	eb 25                	jmp    325 <atoi+0x75>
    n = n*10 + *s++ - '0';
 300:	8b 55 fc             	mov    -0x4(%ebp),%edx
 303:	89 d0                	mov    %edx,%eax
 305:	c1 e0 02             	shl    $0x2,%eax
 308:	01 d0                	add    %edx,%eax
 30a:	01 c0                	add    %eax,%eax
 30c:	89 c1                	mov    %eax,%ecx
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
  while('0' <= *s && *s <= '9')
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	3c 2f                	cmp    $0x2f,%al
 32d:	7e 0a                	jle    339 <atoi+0x89>
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	3c 39                	cmp    $0x39,%al
 337:	7e c7                	jle    300 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 339:	8b 45 f8             	mov    -0x8(%ebp),%eax
 33c:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 340:	c9                   	leave  
 341:	c3                   	ret    

00000342 <atoo>:

int
atoo(const char *s)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 348:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 34f:	eb 04                	jmp    355 <atoo+0x13>
 351:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	3c 20                	cmp    $0x20,%al
 35d:	74 f2                	je     351 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	3c 2d                	cmp    $0x2d,%al
 367:	75 07                	jne    370 <atoo+0x2e>
 369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 36e:	eb 05                	jmp    375 <atoo+0x33>
 370:	b8 01 00 00 00       	mov    $0x1,%eax
 375:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	0f b6 00             	movzbl (%eax),%eax
 37e:	3c 2b                	cmp    $0x2b,%al
 380:	74 0a                	je     38c <atoo+0x4a>
 382:	8b 45 08             	mov    0x8(%ebp),%eax
 385:	0f b6 00             	movzbl (%eax),%eax
 388:	3c 2d                	cmp    $0x2d,%al
 38a:	75 27                	jne    3b3 <atoo+0x71>
    s++;
 38c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 390:	eb 21                	jmp    3b3 <atoo+0x71>
    n = n*8 + *s++ - '0';
 392:	8b 45 fc             	mov    -0x4(%ebp),%eax
 395:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	8d 50 01             	lea    0x1(%eax),%edx
 3a2:	89 55 08             	mov    %edx,0x8(%ebp)
 3a5:	0f b6 00             	movzbl (%eax),%eax
 3a8:	0f be c0             	movsbl %al,%eax
 3ab:	01 c8                	add    %ecx,%eax
 3ad:	83 e8 30             	sub    $0x30,%eax
 3b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	0f b6 00             	movzbl (%eax),%eax
 3b9:	3c 2f                	cmp    $0x2f,%al
 3bb:	7e 0a                	jle    3c7 <atoo+0x85>
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	3c 37                	cmp    $0x37,%al
 3c5:	7e cb                	jle    392 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3ca:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
 3d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e2:	eb 17                	jmp    3fb <memmove+0x2b>
    *dst++ = *src++;
 3e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3e7:	8d 50 01             	lea    0x1(%eax),%edx
 3ea:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3f0:	8d 4a 01             	lea    0x1(%edx),%ecx
 3f3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3f6:	0f b6 12             	movzbl (%edx),%edx
 3f9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3fb:	8b 45 10             	mov    0x10(%ebp),%eax
 3fe:	8d 50 ff             	lea    -0x1(%eax),%edx
 401:	89 55 10             	mov    %edx,0x10(%ebp)
 404:	85 c0                	test   %eax,%eax
 406:	7f dc                	jg     3e4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 40d:	b8 01 00 00 00       	mov    $0x1,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <exit>:
SYSCALL(exit)
 415:	b8 02 00 00 00       	mov    $0x2,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <wait>:
SYSCALL(wait)
 41d:	b8 03 00 00 00       	mov    $0x3,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <pipe>:
SYSCALL(pipe)
 425:	b8 04 00 00 00       	mov    $0x4,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <read>:
SYSCALL(read)
 42d:	b8 05 00 00 00       	mov    $0x5,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <write>:
SYSCALL(write)
 435:	b8 10 00 00 00       	mov    $0x10,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <close>:
SYSCALL(close)
 43d:	b8 15 00 00 00       	mov    $0x15,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <kill>:
SYSCALL(kill)
 445:	b8 06 00 00 00       	mov    $0x6,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <exec>:
SYSCALL(exec)
 44d:	b8 07 00 00 00       	mov    $0x7,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <open>:
SYSCALL(open)
 455:	b8 0f 00 00 00       	mov    $0xf,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <mknod>:
SYSCALL(mknod)
 45d:	b8 11 00 00 00       	mov    $0x11,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <unlink>:
SYSCALL(unlink)
 465:	b8 12 00 00 00       	mov    $0x12,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <fstat>:
SYSCALL(fstat)
 46d:	b8 08 00 00 00       	mov    $0x8,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <link>:
SYSCALL(link)
 475:	b8 13 00 00 00       	mov    $0x13,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <mkdir>:
SYSCALL(mkdir)
 47d:	b8 14 00 00 00       	mov    $0x14,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <chdir>:
SYSCALL(chdir)
 485:	b8 09 00 00 00       	mov    $0x9,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <dup>:
SYSCALL(dup)
 48d:	b8 0a 00 00 00       	mov    $0xa,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <getpid>:
SYSCALL(getpid)
 495:	b8 0b 00 00 00       	mov    $0xb,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <sbrk>:
SYSCALL(sbrk)
 49d:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <sleep>:
SYSCALL(sleep)
 4a5:	b8 0d 00 00 00       	mov    $0xd,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <uptime>:
SYSCALL(uptime)
 4ad:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <halt>:
SYSCALL(halt)
 4b5:	b8 16 00 00 00       	mov    $0x16,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <date>:
SYSCALL(date)
 4bd:	b8 17 00 00 00       	mov    $0x17,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <getuid>:
SYSCALL(getuid)
 4c5:	b8 18 00 00 00       	mov    $0x18,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <getgid>:
SYSCALL(getgid)
 4cd:	b8 19 00 00 00       	mov    $0x19,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <getppid>:
SYSCALL(getppid)
 4d5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <setuid>:
SYSCALL(setuid)
 4dd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <setgid>:
SYSCALL(setgid)
 4e5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <getprocs>:
SYSCALL(getprocs)
 4ed:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <setpriority>:
SYSCALL(setpriority)
 4f5:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <chmod>:
SYSCALL(chmod)
 4fd:	b8 1f 00 00 00       	mov    $0x1f,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <chown>:
SYSCALL(chown)
 505:	b8 20 00 00 00       	mov    $0x20,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <chgrp>:
SYSCALL(chgrp)
 50d:	b8 21 00 00 00       	mov    $0x21,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 515:	55                   	push   %ebp
 516:	89 e5                	mov    %esp,%ebp
 518:	83 ec 18             	sub    $0x18,%esp
 51b:	8b 45 0c             	mov    0xc(%ebp),%eax
 51e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 521:	83 ec 04             	sub    $0x4,%esp
 524:	6a 01                	push   $0x1
 526:	8d 45 f4             	lea    -0xc(%ebp),%eax
 529:	50                   	push   %eax
 52a:	ff 75 08             	pushl  0x8(%ebp)
 52d:	e8 03 ff ff ff       	call   435 <write>
 532:	83 c4 10             	add    $0x10,%esp
}
 535:	90                   	nop
 536:	c9                   	leave  
 537:	c3                   	ret    

00000538 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	53                   	push   %ebx
 53c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 53f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 546:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 54a:	74 17                	je     563 <printint+0x2b>
 54c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 550:	79 11                	jns    563 <printint+0x2b>
    neg = 1;
 552:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 559:	8b 45 0c             	mov    0xc(%ebp),%eax
 55c:	f7 d8                	neg    %eax
 55e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 561:	eb 06                	jmp    569 <printint+0x31>
  } else {
    x = xx;
 563:	8b 45 0c             	mov    0xc(%ebp),%eax
 566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 570:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 573:	8d 41 01             	lea    0x1(%ecx),%eax
 576:	89 45 f4             	mov    %eax,-0xc(%ebp)
 579:	8b 5d 10             	mov    0x10(%ebp),%ebx
 57c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 57f:	ba 00 00 00 00       	mov    $0x0,%edx
 584:	f7 f3                	div    %ebx
 586:	89 d0                	mov    %edx,%eax
 588:	0f b6 80 4c 0c 00 00 	movzbl 0xc4c(%eax),%eax
 58f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 593:	8b 5d 10             	mov    0x10(%ebp),%ebx
 596:	8b 45 ec             	mov    -0x14(%ebp),%eax
 599:	ba 00 00 00 00       	mov    $0x0,%edx
 59e:	f7 f3                	div    %ebx
 5a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a7:	75 c7                	jne    570 <printint+0x38>
  if(neg)
 5a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ad:	74 2d                	je     5dc <printint+0xa4>
    buf[i++] = '-';
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	8d 50 01             	lea    0x1(%eax),%edx
 5b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5bd:	eb 1d                	jmp    5dc <printint+0xa4>
    putc(fd, buf[i]);
 5bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c5:	01 d0                	add    %edx,%eax
 5c7:	0f b6 00             	movzbl (%eax),%eax
 5ca:	0f be c0             	movsbl %al,%eax
 5cd:	83 ec 08             	sub    $0x8,%esp
 5d0:	50                   	push   %eax
 5d1:	ff 75 08             	pushl  0x8(%ebp)
 5d4:	e8 3c ff ff ff       	call   515 <putc>
 5d9:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5dc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e4:	79 d9                	jns    5bf <printint+0x87>
    putc(fd, buf[i]);
}
 5e6:	90                   	nop
 5e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5ea:	c9                   	leave  
 5eb:	c3                   	ret    

000005ec <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ec:	55                   	push   %ebp
 5ed:	89 e5                	mov    %esp,%ebp
 5ef:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f9:	8d 45 0c             	lea    0xc(%ebp),%eax
 5fc:	83 c0 04             	add    $0x4,%eax
 5ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 602:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 609:	e9 59 01 00 00       	jmp    767 <printf+0x17b>
    c = fmt[i] & 0xff;
 60e:	8b 55 0c             	mov    0xc(%ebp),%edx
 611:	8b 45 f0             	mov    -0x10(%ebp),%eax
 614:	01 d0                	add    %edx,%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	25 ff 00 00 00       	and    $0xff,%eax
 621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 624:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 628:	75 2c                	jne    656 <printf+0x6a>
      if(c == '%'){
 62a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62e:	75 0c                	jne    63c <printf+0x50>
        state = '%';
 630:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 637:	e9 27 01 00 00       	jmp    763 <printf+0x177>
      } else {
        putc(fd, c);
 63c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63f:	0f be c0             	movsbl %al,%eax
 642:	83 ec 08             	sub    $0x8,%esp
 645:	50                   	push   %eax
 646:	ff 75 08             	pushl  0x8(%ebp)
 649:	e8 c7 fe ff ff       	call   515 <putc>
 64e:	83 c4 10             	add    $0x10,%esp
 651:	e9 0d 01 00 00       	jmp    763 <printf+0x177>
      }
    } else if(state == '%'){
 656:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 65a:	0f 85 03 01 00 00    	jne    763 <printf+0x177>
      if(c == 'd'){
 660:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 664:	75 1e                	jne    684 <printf+0x98>
        printint(fd, *ap, 10, 1);
 666:	8b 45 e8             	mov    -0x18(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	6a 01                	push   $0x1
 66d:	6a 0a                	push   $0xa
 66f:	50                   	push   %eax
 670:	ff 75 08             	pushl  0x8(%ebp)
 673:	e8 c0 fe ff ff       	call   538 <printint>
 678:	83 c4 10             	add    $0x10,%esp
        ap++;
 67b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 67f:	e9 d8 00 00 00       	jmp    75c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 684:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 688:	74 06                	je     690 <printf+0xa4>
 68a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 68e:	75 1e                	jne    6ae <printf+0xc2>
        printint(fd, *ap, 16, 0);
 690:	8b 45 e8             	mov    -0x18(%ebp),%eax
 693:	8b 00                	mov    (%eax),%eax
 695:	6a 00                	push   $0x0
 697:	6a 10                	push   $0x10
 699:	50                   	push   %eax
 69a:	ff 75 08             	pushl  0x8(%ebp)
 69d:	e8 96 fe ff ff       	call   538 <printint>
 6a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 6a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a9:	e9 ae 00 00 00       	jmp    75c <printf+0x170>
      } else if(c == 's'){
 6ae:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b2:	75 43                	jne    6f7 <printf+0x10b>
        s = (char*)*ap;
 6b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6bc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c4:	75 25                	jne    6eb <printf+0xff>
          s = "(null)";
 6c6:	c7 45 f4 b7 09 00 00 	movl   $0x9b7,-0xc(%ebp)
        while(*s != 0){
 6cd:	eb 1c                	jmp    6eb <printf+0xff>
          putc(fd, *s);
 6cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d2:	0f b6 00             	movzbl (%eax),%eax
 6d5:	0f be c0             	movsbl %al,%eax
 6d8:	83 ec 08             	sub    $0x8,%esp
 6db:	50                   	push   %eax
 6dc:	ff 75 08             	pushl  0x8(%ebp)
 6df:	e8 31 fe ff ff       	call   515 <putc>
 6e4:	83 c4 10             	add    $0x10,%esp
          s++;
 6e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ee:	0f b6 00             	movzbl (%eax),%eax
 6f1:	84 c0                	test   %al,%al
 6f3:	75 da                	jne    6cf <printf+0xe3>
 6f5:	eb 65                	jmp    75c <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6fb:	75 1d                	jne    71a <printf+0x12e>
        putc(fd, *ap);
 6fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	83 ec 08             	sub    $0x8,%esp
 708:	50                   	push   %eax
 709:	ff 75 08             	pushl  0x8(%ebp)
 70c:	e8 04 fe ff ff       	call   515 <putc>
 711:	83 c4 10             	add    $0x10,%esp
        ap++;
 714:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 718:	eb 42                	jmp    75c <printf+0x170>
      } else if(c == '%'){
 71a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71e:	75 17                	jne    737 <printf+0x14b>
        putc(fd, c);
 720:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 723:	0f be c0             	movsbl %al,%eax
 726:	83 ec 08             	sub    $0x8,%esp
 729:	50                   	push   %eax
 72a:	ff 75 08             	pushl  0x8(%ebp)
 72d:	e8 e3 fd ff ff       	call   515 <putc>
 732:	83 c4 10             	add    $0x10,%esp
 735:	eb 25                	jmp    75c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 737:	83 ec 08             	sub    $0x8,%esp
 73a:	6a 25                	push   $0x25
 73c:	ff 75 08             	pushl  0x8(%ebp)
 73f:	e8 d1 fd ff ff       	call   515 <putc>
 744:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	83 ec 08             	sub    $0x8,%esp
 750:	50                   	push   %eax
 751:	ff 75 08             	pushl  0x8(%ebp)
 754:	e8 bc fd ff ff       	call   515 <putc>
 759:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 75c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 763:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 767:	8b 55 0c             	mov    0xc(%ebp),%edx
 76a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76d:	01 d0                	add    %edx,%eax
 76f:	0f b6 00             	movzbl (%eax),%eax
 772:	84 c0                	test   %al,%al
 774:	0f 85 94 fe ff ff    	jne    60e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 77a:	90                   	nop
 77b:	c9                   	leave  
 77c:	c3                   	ret    

0000077d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77d:	55                   	push   %ebp
 77e:	89 e5                	mov    %esp,%ebp
 780:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	83 e8 08             	sub    $0x8,%eax
 789:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78c:	a1 68 0c 00 00       	mov    0xc68,%eax
 791:	89 45 fc             	mov    %eax,-0x4(%ebp)
 794:	eb 24                	jmp    7ba <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
 799:	8b 00                	mov    (%eax),%eax
 79b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79e:	77 12                	ja     7b2 <free+0x35>
 7a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a6:	77 24                	ja     7cc <free+0x4f>
 7a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ab:	8b 00                	mov    (%eax),%eax
 7ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b0:	77 1a                	ja     7cc <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b5:	8b 00                	mov    (%eax),%eax
 7b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c0:	76 d4                	jbe    796 <free+0x19>
 7c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c5:	8b 00                	mov    (%eax),%eax
 7c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ca:	76 ca                	jbe    796 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cf:	8b 40 04             	mov    0x4(%eax),%eax
 7d2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	01 c2                	add    %eax,%edx
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	39 c2                	cmp    %eax,%edx
 7e5:	75 24                	jne    80b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	8b 50 04             	mov    0x4(%eax),%edx
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	8b 40 04             	mov    0x4(%eax),%eax
 7f5:	01 c2                	add    %eax,%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	8b 10                	mov    (%eax),%edx
 804:	8b 45 f8             	mov    -0x8(%ebp),%eax
 807:	89 10                	mov    %edx,(%eax)
 809:	eb 0a                	jmp    815 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 80b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80e:	8b 10                	mov    (%eax),%edx
 810:	8b 45 f8             	mov    -0x8(%ebp),%eax
 813:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 822:	8b 45 fc             	mov    -0x4(%ebp),%eax
 825:	01 d0                	add    %edx,%eax
 827:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 82a:	75 20                	jne    84c <free+0xcf>
    p->s.size += bp->s.size;
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 50 04             	mov    0x4(%eax),%edx
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	8b 40 04             	mov    0x4(%eax),%eax
 838:	01 c2                	add    %eax,%edx
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 840:	8b 45 f8             	mov    -0x8(%ebp),%eax
 843:	8b 10                	mov    (%eax),%edx
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	89 10                	mov    %edx,(%eax)
 84a:	eb 08                	jmp    854 <free+0xd7>
  } else
    p->s.ptr = bp;
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 852:	89 10                	mov    %edx,(%eax)
  freep = p;
 854:	8b 45 fc             	mov    -0x4(%ebp),%eax
 857:	a3 68 0c 00 00       	mov    %eax,0xc68
}
 85c:	90                   	nop
 85d:	c9                   	leave  
 85e:	c3                   	ret    

0000085f <morecore>:

static Header*
morecore(uint nu)
{
 85f:	55                   	push   %ebp
 860:	89 e5                	mov    %esp,%ebp
 862:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 865:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 86c:	77 07                	ja     875 <morecore+0x16>
    nu = 4096;
 86e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 875:	8b 45 08             	mov    0x8(%ebp),%eax
 878:	c1 e0 03             	shl    $0x3,%eax
 87b:	83 ec 0c             	sub    $0xc,%esp
 87e:	50                   	push   %eax
 87f:	e8 19 fc ff ff       	call   49d <sbrk>
 884:	83 c4 10             	add    $0x10,%esp
 887:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 88a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 88e:	75 07                	jne    897 <morecore+0x38>
    return 0;
 890:	b8 00 00 00 00       	mov    $0x0,%eax
 895:	eb 26                	jmp    8bd <morecore+0x5e>
  hp = (Header*)p;
 897:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	8b 55 08             	mov    0x8(%ebp),%edx
 8a3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a9:	83 c0 08             	add    $0x8,%eax
 8ac:	83 ec 0c             	sub    $0xc,%esp
 8af:	50                   	push   %eax
 8b0:	e8 c8 fe ff ff       	call   77d <free>
 8b5:	83 c4 10             	add    $0x10,%esp
  return freep;
 8b8:	a1 68 0c 00 00       	mov    0xc68,%eax
}
 8bd:	c9                   	leave  
 8be:	c3                   	ret    

000008bf <malloc>:

void*
malloc(uint nbytes)
{
 8bf:	55                   	push   %ebp
 8c0:	89 e5                	mov    %esp,%ebp
 8c2:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c5:	8b 45 08             	mov    0x8(%ebp),%eax
 8c8:	83 c0 07             	add    $0x7,%eax
 8cb:	c1 e8 03             	shr    $0x3,%eax
 8ce:	83 c0 01             	add    $0x1,%eax
 8d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d4:	a1 68 0c 00 00       	mov    0xc68,%eax
 8d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e0:	75 23                	jne    905 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e2:	c7 45 f0 60 0c 00 00 	movl   $0xc60,-0x10(%ebp)
 8e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ec:	a3 68 0c 00 00       	mov    %eax,0xc68
 8f1:	a1 68 0c 00 00       	mov    0xc68,%eax
 8f6:	a3 60 0c 00 00       	mov    %eax,0xc60
    base.s.size = 0;
 8fb:	c7 05 64 0c 00 00 00 	movl   $0x0,0xc64
 902:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 905:	8b 45 f0             	mov    -0x10(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 910:	8b 40 04             	mov    0x4(%eax),%eax
 913:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 916:	72 4d                	jb     965 <malloc+0xa6>
      if(p->s.size == nunits)
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 921:	75 0c                	jne    92f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 10                	mov    (%eax),%edx
 928:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92b:	89 10                	mov    %edx,(%eax)
 92d:	eb 26                	jmp    955 <malloc+0x96>
      else {
        p->s.size -= nunits;
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	8b 40 04             	mov    0x4(%eax),%eax
 935:	2b 45 ec             	sub    -0x14(%ebp),%eax
 938:	89 c2                	mov    %eax,%edx
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	8b 40 04             	mov    0x4(%eax),%eax
 946:	c1 e0 03             	shl    $0x3,%eax
 949:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 952:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 955:	8b 45 f0             	mov    -0x10(%ebp),%eax
 958:	a3 68 0c 00 00       	mov    %eax,0xc68
      return (void*)(p + 1);
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	83 c0 08             	add    $0x8,%eax
 963:	eb 3b                	jmp    9a0 <malloc+0xe1>
    }
    if(p == freep)
 965:	a1 68 0c 00 00       	mov    0xc68,%eax
 96a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 96d:	75 1e                	jne    98d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 96f:	83 ec 0c             	sub    $0xc,%esp
 972:	ff 75 ec             	pushl  -0x14(%ebp)
 975:	e8 e5 fe ff ff       	call   85f <morecore>
 97a:	83 c4 10             	add    $0x10,%esp
 97d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 980:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 984:	75 07                	jne    98d <malloc+0xce>
        return 0;
 986:	b8 00 00 00 00       	mov    $0x0,%eax
 98b:	eb 13                	jmp    9a0 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	89 45 f0             	mov    %eax,-0x10(%ebp)
 993:	8b 45 f4             	mov    -0xc(%ebp),%eax
 996:	8b 00                	mov    (%eax),%eax
 998:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99b:	e9 6d ff ff ff       	jmp    90d <malloc+0x4e>
}
 9a0:	c9                   	leave  
 9a1:	c3                   	ret    
