
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int start_time = uptime(); // for ticks
  14:	e8 cc 04 00 00       	call   4e5 <uptime>
  19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int final_time;
  int time_diff;
  int result;
  int reminder;
  int knife = fork(); // to check fork
  1c:	e8 24 04 00 00       	call   445 <fork>
  21:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (knife < 0) // knife value negative
  24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  28:	79 17                	jns    41 <main+0x41>
  {
     printf(1, "error FAIL\n");
  2a:	83 ec 08             	sub    $0x8,%esp
  2d:	68 da 09 00 00       	push   $0x9da
  32:	6a 01                	push   $0x1
  34:	e8 eb 05 00 00       	call   624 <printf>
  39:	83 c4 10             	add    $0x10,%esp
     exit();
  3c:	e8 0c 04 00 00       	call   44d <exit>
  }

  if (knife == 0) // knife is zero
  41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  45:	75 3d                	jne    84 <main+0x84>
  {
     if (argc == 1) 
  47:	83 3b 01             	cmpl   $0x1,(%ebx)
  4a:	75 05                	jne    51 <main+0x51>
        exit();
  4c:	e8 fc 03 00 00       	call   44d <exit>
     ++argv; 
  51:	83 43 04 04          	addl   $0x4,0x4(%ebx)
     if (exec(argv[0], argv)) 
  55:	8b 43 04             	mov    0x4(%ebx),%eax
  58:	8b 00                	mov    (%eax),%eax
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	ff 73 04             	pushl  0x4(%ebx)
  60:	50                   	push   %eax
  61:	e8 1f 04 00 00       	call   485 <exec>
  66:	83 c4 10             	add    $0x10,%esp
  69:	85 c0                	test   %eax,%eax
  6b:	74 17                	je     84 <main+0x84>
     {
        printf(1, "error FAIL\n");
  6d:	83 ec 08             	sub    $0x8,%esp
  70:	68 da 09 00 00       	push   $0x9da
  75:	6a 01                	push   $0x1
  77:	e8 a8 05 00 00       	call   624 <printf>
  7c:	83 c4 10             	add    $0x10,%esp
        exit();
  7f:	e8 c9 03 00 00       	call   44d <exit>
     }
  }
  wait();
  84:	e8 cc 03 00 00       	call   455 <wait>
  final_time = uptime(); // get time
  89:	e8 57 04 00 00       	call   4e5 <uptime>
  8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  time_diff = final_time - start_time; // get the difference 
  91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  94:	2b 45 f4             	sub    -0xc(%ebp),%eax
  97:	89 45 e8             	mov    %eax,-0x18(%ebp)
  result = time_diff/1000; // get the result
  9a:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  9d:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  a2:	89 c8                	mov    %ecx,%eax
  a4:	f7 ea                	imul   %edx
  a6:	c1 fa 06             	sar    $0x6,%edx
  a9:	89 c8                	mov    %ecx,%eax
  ab:	c1 f8 1f             	sar    $0x1f,%eax
  ae:	29 c2                	sub    %eax,%edx
  b0:	89 d0                	mov    %edx,%eax
  b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  reminder = time_diff%1000; // get the reminder
  b5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  b8:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  bd:	89 c8                	mov    %ecx,%eax
  bf:	f7 ea                	imul   %edx
  c1:	c1 fa 06             	sar    $0x6,%edx
  c4:	89 c8                	mov    %ecx,%eax
  c6:	c1 f8 1f             	sar    $0x1f,%eax
  c9:	29 c2                	sub    %eax,%edx
  cb:	89 d0                	mov    %edx,%eax
  cd:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  d3:	29 c1                	sub    %eax,%ecx
  d5:	89 c8                	mov    %ecx,%eax
  d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  if(argv[1] != 0)
  da:	8b 43 04             	mov    0x4(%ebx),%eax
  dd:	83 c0 04             	add    $0x4,%eax
  e0:	8b 00                	mov    (%eax),%eax
  e2:	85 c0                	test   %eax,%eax
  e4:	74 23                	je     109 <main+0x109>
     printf(1, "%s ran in %d.%d seconds.\n", argv[1], result, reminder); // displayin
  e6:	8b 43 04             	mov    0x4(%ebx),%eax
  e9:	83 c0 04             	add    $0x4,%eax
  ec:	8b 00                	mov    (%eax),%eax
  ee:	83 ec 0c             	sub    $0xc,%esp
  f1:	ff 75 e0             	pushl  -0x20(%ebp)
  f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  f7:	50                   	push   %eax
  f8:	68 e6 09 00 00       	push   $0x9e6
  fd:	6a 01                	push   $0x1
  ff:	e8 20 05 00 00       	call   624 <printf>
 104:	83 c4 20             	add    $0x20,%esp
 107:	eb 15                	jmp    11e <main+0x11e>
  else
     printf(1, "ran in %d.%d seconds.\n", result, reminder); 
 109:	ff 75 e0             	pushl  -0x20(%ebp)
 10c:	ff 75 e4             	pushl  -0x1c(%ebp)
 10f:	68 00 0a 00 00       	push   $0xa00
 114:	6a 01                	push   $0x1
 116:	e8 09 05 00 00       	call   624 <printf>
 11b:	83 c4 10             	add    $0x10,%esp
  exit();
 11e:	e8 2a 03 00 00       	call   44d <exit>

00000123 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	57                   	push   %edi
 127:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 128:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12b:	8b 55 10             	mov    0x10(%ebp),%edx
 12e:	8b 45 0c             	mov    0xc(%ebp),%eax
 131:	89 cb                	mov    %ecx,%ebx
 133:	89 df                	mov    %ebx,%edi
 135:	89 d1                	mov    %edx,%ecx
 137:	fc                   	cld    
 138:	f3 aa                	rep stos %al,%es:(%edi)
 13a:	89 ca                	mov    %ecx,%edx
 13c:	89 fb                	mov    %edi,%ebx
 13e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 141:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 144:	90                   	nop
 145:	5b                   	pop    %ebx
 146:	5f                   	pop    %edi
 147:	5d                   	pop    %ebp
 148:	c3                   	ret    

00000149 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 149:	55                   	push   %ebp
 14a:	89 e5                	mov    %esp,%ebp
 14c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 155:	90                   	nop
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	8d 50 01             	lea    0x1(%eax),%edx
 15c:	89 55 08             	mov    %edx,0x8(%ebp)
 15f:	8b 55 0c             	mov    0xc(%ebp),%edx
 162:	8d 4a 01             	lea    0x1(%edx),%ecx
 165:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 168:	0f b6 12             	movzbl (%edx),%edx
 16b:	88 10                	mov    %dl,(%eax)
 16d:	0f b6 00             	movzbl (%eax),%eax
 170:	84 c0                	test   %al,%al
 172:	75 e2                	jne    156 <strcpy+0xd>
    ;
  return os;
 174:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 177:	c9                   	leave  
 178:	c3                   	ret    

00000179 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17c:	eb 08                	jmp    186 <strcmp+0xd>
    p++, q++;
 17e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 182:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	84 c0                	test   %al,%al
 18e:	74 10                	je     1a0 <strcmp+0x27>
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 10             	movzbl (%eax),%edx
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 00             	movzbl (%eax),%eax
 19c:	38 c2                	cmp    %al,%dl
 19e:	74 de                	je     17e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	0f b6 00             	movzbl (%eax),%eax
 1a6:	0f b6 d0             	movzbl %al,%edx
 1a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ac:	0f b6 00             	movzbl (%eax),%eax
 1af:	0f b6 c0             	movzbl %al,%eax
 1b2:	29 c2                	sub    %eax,%edx
 1b4:	89 d0                	mov    %edx,%eax
}
 1b6:	5d                   	pop    %ebp
 1b7:	c3                   	ret    

000001b8 <strlen>:

uint
strlen(char *s)
{
 1b8:	55                   	push   %ebp
 1b9:	89 e5                	mov    %esp,%ebp
 1bb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c5:	eb 04                	jmp    1cb <strlen+0x13>
 1c7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ce:	8b 45 08             	mov    0x8(%ebp),%eax
 1d1:	01 d0                	add    %edx,%eax
 1d3:	0f b6 00             	movzbl (%eax),%eax
 1d6:	84 c0                	test   %al,%al
 1d8:	75 ed                	jne    1c7 <strlen+0xf>
    ;
  return n;
 1da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <memset>:

void*
memset(void *dst, int c, uint n)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1e2:	8b 45 10             	mov    0x10(%ebp),%eax
 1e5:	50                   	push   %eax
 1e6:	ff 75 0c             	pushl  0xc(%ebp)
 1e9:	ff 75 08             	pushl  0x8(%ebp)
 1ec:	e8 32 ff ff ff       	call   123 <stosb>
 1f1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <strchr>:

char*
strchr(const char *s, char c)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 04             	sub    $0x4,%esp
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 205:	eb 14                	jmp    21b <strchr+0x22>
    if(*s == c)
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	0f b6 00             	movzbl (%eax),%eax
 20d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 210:	75 05                	jne    217 <strchr+0x1e>
      return (char*)s;
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	eb 13                	jmp    22a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 217:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	75 e2                	jne    207 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 225:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22a:	c9                   	leave  
 22b:	c3                   	ret    

0000022c <gets>:

char*
gets(char *buf, int max)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 239:	eb 42                	jmp    27d <gets+0x51>
    cc = read(0, &c, 1);
 23b:	83 ec 04             	sub    $0x4,%esp
 23e:	6a 01                	push   $0x1
 240:	8d 45 ef             	lea    -0x11(%ebp),%eax
 243:	50                   	push   %eax
 244:	6a 00                	push   $0x0
 246:	e8 1a 02 00 00       	call   465 <read>
 24b:	83 c4 10             	add    $0x10,%esp
 24e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 255:	7e 33                	jle    28a <gets+0x5e>
      break;
    buf[i++] = c;
 257:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25a:	8d 50 01             	lea    0x1(%eax),%edx
 25d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 260:	89 c2                	mov    %eax,%edx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	01 c2                	add    %eax,%edx
 267:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0a                	cmp    $0xa,%al
 273:	74 16                	je     28b <gets+0x5f>
 275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 279:	3c 0d                	cmp    $0xd,%al
 27b:	74 0e                	je     28b <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	83 c0 01             	add    $0x1,%eax
 283:	3b 45 0c             	cmp    0xc(%ebp),%eax
 286:	7c b3                	jl     23b <gets+0xf>
 288:	eb 01                	jmp    28b <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	01 d0                	add    %edx,%eax
 293:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 296:	8b 45 08             	mov    0x8(%ebp),%eax
}
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <stat>:

int
stat(char *n, struct stat *st)
{
 29b:	55                   	push   %ebp
 29c:	89 e5                	mov    %esp,%ebp
 29e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a1:	83 ec 08             	sub    $0x8,%esp
 2a4:	6a 00                	push   $0x0
 2a6:	ff 75 08             	pushl  0x8(%ebp)
 2a9:	e8 df 01 00 00       	call   48d <open>
 2ae:	83 c4 10             	add    $0x10,%esp
 2b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b8:	79 07                	jns    2c1 <stat+0x26>
    return -1;
 2ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bf:	eb 25                	jmp    2e6 <stat+0x4b>
  r = fstat(fd, st);
 2c1:	83 ec 08             	sub    $0x8,%esp
 2c4:	ff 75 0c             	pushl  0xc(%ebp)
 2c7:	ff 75 f4             	pushl  -0xc(%ebp)
 2ca:	e8 d6 01 00 00       	call   4a5 <fstat>
 2cf:	83 c4 10             	add    $0x10,%esp
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	83 ec 0c             	sub    $0xc,%esp
 2d8:	ff 75 f4             	pushl  -0xc(%ebp)
 2db:	e8 95 01 00 00       	call   475 <close>
 2e0:	83 c4 10             	add    $0x10,%esp
  return r;
 2e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e6:	c9                   	leave  
 2e7:	c3                   	ret    

000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2f5:	eb 04                	jmp    2fb <atoi+0x13>
 2f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	3c 20                	cmp    $0x20,%al
 303:	74 f2                	je     2f7 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	0f b6 00             	movzbl (%eax),%eax
 30b:	3c 2d                	cmp    $0x2d,%al
 30d:	75 07                	jne    316 <atoi+0x2e>
 30f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 314:	eb 05                	jmp    31b <atoi+0x33>
 316:	b8 01 00 00 00       	mov    $0x1,%eax
 31b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	3c 2b                	cmp    $0x2b,%al
 326:	74 0a                	je     332 <atoi+0x4a>
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	0f b6 00             	movzbl (%eax),%eax
 32e:	3c 2d                	cmp    $0x2d,%al
 330:	75 2b                	jne    35d <atoi+0x75>
    s++;
 332:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 336:	eb 25                	jmp    35d <atoi+0x75>
    n = n*10 + *s++ - '0';
 338:	8b 55 fc             	mov    -0x4(%ebp),%edx
 33b:	89 d0                	mov    %edx,%eax
 33d:	c1 e0 02             	shl    $0x2,%eax
 340:	01 d0                	add    %edx,%eax
 342:	01 c0                	add    %eax,%eax
 344:	89 c1                	mov    %eax,%ecx
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 08             	mov    %edx,0x8(%ebp)
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	0f be c0             	movsbl %al,%eax
 355:	01 c8                	add    %ecx,%eax
 357:	83 e8 30             	sub    $0x30,%eax
 35a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	0f b6 00             	movzbl (%eax),%eax
 363:	3c 2f                	cmp    $0x2f,%al
 365:	7e 0a                	jle    371 <atoi+0x89>
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	0f b6 00             	movzbl (%eax),%eax
 36d:	3c 39                	cmp    $0x39,%al
 36f:	7e c7                	jle    338 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 371:	8b 45 f8             	mov    -0x8(%ebp),%eax
 374:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    

0000037a <atoo>:

int
atoo(const char *s)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
 37d:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 380:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 387:	eb 04                	jmp    38d <atoo+0x13>
 389:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	3c 20                	cmp    $0x20,%al
 395:	74 f2                	je     389 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	0f b6 00             	movzbl (%eax),%eax
 39d:	3c 2d                	cmp    $0x2d,%al
 39f:	75 07                	jne    3a8 <atoo+0x2e>
 3a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3a6:	eb 05                	jmp    3ad <atoo+0x33>
 3a8:	b8 01 00 00 00       	mov    $0x1,%eax
 3ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	3c 2b                	cmp    $0x2b,%al
 3b8:	74 0a                	je     3c4 <atoo+0x4a>
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	0f b6 00             	movzbl (%eax),%eax
 3c0:	3c 2d                	cmp    $0x2d,%al
 3c2:	75 27                	jne    3eb <atoo+0x71>
    s++;
 3c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 3c8:	eb 21                	jmp    3eb <atoo+0x71>
    n = n*8 + *s++ - '0';
 3ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3cd:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	8d 50 01             	lea    0x1(%eax),%edx
 3da:	89 55 08             	mov    %edx,0x8(%ebp)
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	0f be c0             	movsbl %al,%eax
 3e3:	01 c8                	add    %ecx,%eax
 3e5:	83 e8 30             	sub    $0x30,%eax
 3e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	0f b6 00             	movzbl (%eax),%eax
 3f1:	3c 2f                	cmp    $0x2f,%al
 3f3:	7e 0a                	jle    3ff <atoo+0x85>
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
 3f8:	0f b6 00             	movzbl (%eax),%eax
 3fb:	3c 37                	cmp    $0x37,%al
 3fd:	7e cb                	jle    3ca <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 402:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 406:	c9                   	leave  
 407:	c3                   	ret    

00000408 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
 411:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 414:	8b 45 0c             	mov    0xc(%ebp),%eax
 417:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 41a:	eb 17                	jmp    433 <memmove+0x2b>
    *dst++ = *src++;
 41c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 41f:	8d 50 01             	lea    0x1(%eax),%edx
 422:	89 55 fc             	mov    %edx,-0x4(%ebp)
 425:	8b 55 f8             	mov    -0x8(%ebp),%edx
 428:	8d 4a 01             	lea    0x1(%edx),%ecx
 42b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 42e:	0f b6 12             	movzbl (%edx),%edx
 431:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 433:	8b 45 10             	mov    0x10(%ebp),%eax
 436:	8d 50 ff             	lea    -0x1(%eax),%edx
 439:	89 55 10             	mov    %edx,0x10(%ebp)
 43c:	85 c0                	test   %eax,%eax
 43e:	7f dc                	jg     41c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 440:	8b 45 08             	mov    0x8(%ebp),%eax
}
 443:	c9                   	leave  
 444:	c3                   	ret    

00000445 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 445:	b8 01 00 00 00       	mov    $0x1,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <exit>:
SYSCALL(exit)
 44d:	b8 02 00 00 00       	mov    $0x2,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <wait>:
SYSCALL(wait)
 455:	b8 03 00 00 00       	mov    $0x3,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <pipe>:
SYSCALL(pipe)
 45d:	b8 04 00 00 00       	mov    $0x4,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <read>:
SYSCALL(read)
 465:	b8 05 00 00 00       	mov    $0x5,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <write>:
SYSCALL(write)
 46d:	b8 10 00 00 00       	mov    $0x10,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <close>:
SYSCALL(close)
 475:	b8 15 00 00 00       	mov    $0x15,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <kill>:
SYSCALL(kill)
 47d:	b8 06 00 00 00       	mov    $0x6,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <exec>:
SYSCALL(exec)
 485:	b8 07 00 00 00       	mov    $0x7,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <open>:
SYSCALL(open)
 48d:	b8 0f 00 00 00       	mov    $0xf,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <mknod>:
SYSCALL(mknod)
 495:	b8 11 00 00 00       	mov    $0x11,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <unlink>:
SYSCALL(unlink)
 49d:	b8 12 00 00 00       	mov    $0x12,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <fstat>:
SYSCALL(fstat)
 4a5:	b8 08 00 00 00       	mov    $0x8,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <link>:
SYSCALL(link)
 4ad:	b8 13 00 00 00       	mov    $0x13,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <mkdir>:
SYSCALL(mkdir)
 4b5:	b8 14 00 00 00       	mov    $0x14,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <chdir>:
SYSCALL(chdir)
 4bd:	b8 09 00 00 00       	mov    $0x9,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <dup>:
SYSCALL(dup)
 4c5:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <getpid>:
SYSCALL(getpid)
 4cd:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <sbrk>:
SYSCALL(sbrk)
 4d5:	b8 0c 00 00 00       	mov    $0xc,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <sleep>:
SYSCALL(sleep)
 4dd:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <uptime>:
SYSCALL(uptime)
 4e5:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <halt>:
SYSCALL(halt)
 4ed:	b8 16 00 00 00       	mov    $0x16,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <date>:
SYSCALL(date)
 4f5:	b8 17 00 00 00       	mov    $0x17,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <getuid>:
SYSCALL(getuid)
 4fd:	b8 18 00 00 00       	mov    $0x18,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <getgid>:
SYSCALL(getgid)
 505:	b8 19 00 00 00       	mov    $0x19,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <getppid>:
SYSCALL(getppid)
 50d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <setuid>:
SYSCALL(setuid)
 515:	b8 1b 00 00 00       	mov    $0x1b,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <setgid>:
SYSCALL(setgid)
 51d:	b8 1c 00 00 00       	mov    $0x1c,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <getprocs>:
SYSCALL(getprocs)
 525:	b8 1d 00 00 00       	mov    $0x1d,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <setpriority>:
SYSCALL(setpriority)
 52d:	b8 1e 00 00 00       	mov    $0x1e,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <chmod>:
SYSCALL(chmod)
 535:	b8 1f 00 00 00       	mov    $0x1f,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    

0000053d <chown>:
SYSCALL(chown)
 53d:	b8 20 00 00 00       	mov    $0x20,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret    

00000545 <chgrp>:
SYSCALL(chgrp)
 545:	b8 21 00 00 00       	mov    $0x21,%eax
 54a:	cd 40                	int    $0x40
 54c:	c3                   	ret    

0000054d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	83 ec 18             	sub    $0x18,%esp
 553:	8b 45 0c             	mov    0xc(%ebp),%eax
 556:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 559:	83 ec 04             	sub    $0x4,%esp
 55c:	6a 01                	push   $0x1
 55e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 561:	50                   	push   %eax
 562:	ff 75 08             	pushl  0x8(%ebp)
 565:	e8 03 ff ff ff       	call   46d <write>
 56a:	83 c4 10             	add    $0x10,%esp
}
 56d:	90                   	nop
 56e:	c9                   	leave  
 56f:	c3                   	ret    

00000570 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	53                   	push   %ebx
 574:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 577:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 57e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 582:	74 17                	je     59b <printint+0x2b>
 584:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 588:	79 11                	jns    59b <printint+0x2b>
    neg = 1;
 58a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 591:	8b 45 0c             	mov    0xc(%ebp),%eax
 594:	f7 d8                	neg    %eax
 596:	89 45 ec             	mov    %eax,-0x14(%ebp)
 599:	eb 06                	jmp    5a1 <printint+0x31>
  } else {
    x = xx;
 59b:	8b 45 0c             	mov    0xc(%ebp),%eax
 59e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5ab:	8d 41 01             	lea    0x1(%ecx),%eax
 5ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b7:	ba 00 00 00 00       	mov    $0x0,%edx
 5bc:	f7 f3                	div    %ebx
 5be:	89 d0                	mov    %edx,%eax
 5c0:	0f b6 80 8c 0c 00 00 	movzbl 0xc8c(%eax),%eax
 5c7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d1:	ba 00 00 00 00       	mov    $0x0,%edx
 5d6:	f7 f3                	div    %ebx
 5d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5df:	75 c7                	jne    5a8 <printint+0x38>
  if(neg)
 5e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e5:	74 2d                	je     614 <printint+0xa4>
    buf[i++] = '-';
 5e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ea:	8d 50 01             	lea    0x1(%eax),%edx
 5ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5f5:	eb 1d                	jmp    614 <printint+0xa4>
    putc(fd, buf[i]);
 5f7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fd:	01 d0                	add    %edx,%eax
 5ff:	0f b6 00             	movzbl (%eax),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	83 ec 08             	sub    $0x8,%esp
 608:	50                   	push   %eax
 609:	ff 75 08             	pushl  0x8(%ebp)
 60c:	e8 3c ff ff ff       	call   54d <putc>
 611:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 614:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 618:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61c:	79 d9                	jns    5f7 <printint+0x87>
    putc(fd, buf[i]);
}
 61e:	90                   	nop
 61f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 622:	c9                   	leave  
 623:	c3                   	ret    

00000624 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 62a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 631:	8d 45 0c             	lea    0xc(%ebp),%eax
 634:	83 c0 04             	add    $0x4,%eax
 637:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 63a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 641:	e9 59 01 00 00       	jmp    79f <printf+0x17b>
    c = fmt[i] & 0xff;
 646:	8b 55 0c             	mov    0xc(%ebp),%edx
 649:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64c:	01 d0                	add    %edx,%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	0f be c0             	movsbl %al,%eax
 654:	25 ff 00 00 00       	and    $0xff,%eax
 659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 65c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 660:	75 2c                	jne    68e <printf+0x6a>
      if(c == '%'){
 662:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 666:	75 0c                	jne    674 <printf+0x50>
        state = '%';
 668:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 66f:	e9 27 01 00 00       	jmp    79b <printf+0x177>
      } else {
        putc(fd, c);
 674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 677:	0f be c0             	movsbl %al,%eax
 67a:	83 ec 08             	sub    $0x8,%esp
 67d:	50                   	push   %eax
 67e:	ff 75 08             	pushl  0x8(%ebp)
 681:	e8 c7 fe ff ff       	call   54d <putc>
 686:	83 c4 10             	add    $0x10,%esp
 689:	e9 0d 01 00 00       	jmp    79b <printf+0x177>
      }
    } else if(state == '%'){
 68e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 692:	0f 85 03 01 00 00    	jne    79b <printf+0x177>
      if(c == 'd'){
 698:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 69c:	75 1e                	jne    6bc <printf+0x98>
        printint(fd, *ap, 10, 1);
 69e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a1:	8b 00                	mov    (%eax),%eax
 6a3:	6a 01                	push   $0x1
 6a5:	6a 0a                	push   $0xa
 6a7:	50                   	push   %eax
 6a8:	ff 75 08             	pushl  0x8(%ebp)
 6ab:	e8 c0 fe ff ff       	call   570 <printint>
 6b0:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b7:	e9 d8 00 00 00       	jmp    794 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6bc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6c0:	74 06                	je     6c8 <printf+0xa4>
 6c2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c6:	75 1e                	jne    6e6 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6cb:	8b 00                	mov    (%eax),%eax
 6cd:	6a 00                	push   $0x0
 6cf:	6a 10                	push   $0x10
 6d1:	50                   	push   %eax
 6d2:	ff 75 08             	pushl  0x8(%ebp)
 6d5:	e8 96 fe ff ff       	call   570 <printint>
 6da:	83 c4 10             	add    $0x10,%esp
        ap++;
 6dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e1:	e9 ae 00 00 00       	jmp    794 <printf+0x170>
      } else if(c == 's'){
 6e6:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ea:	75 43                	jne    72f <printf+0x10b>
        s = (char*)*ap;
 6ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fc:	75 25                	jne    723 <printf+0xff>
          s = "(null)";
 6fe:	c7 45 f4 17 0a 00 00 	movl   $0xa17,-0xc(%ebp)
        while(*s != 0){
 705:	eb 1c                	jmp    723 <printf+0xff>
          putc(fd, *s);
 707:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	83 ec 08             	sub    $0x8,%esp
 713:	50                   	push   %eax
 714:	ff 75 08             	pushl  0x8(%ebp)
 717:	e8 31 fe ff ff       	call   54d <putc>
 71c:	83 c4 10             	add    $0x10,%esp
          s++;
 71f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	0f b6 00             	movzbl (%eax),%eax
 729:	84 c0                	test   %al,%al
 72b:	75 da                	jne    707 <printf+0xe3>
 72d:	eb 65                	jmp    794 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 733:	75 1d                	jne    752 <printf+0x12e>
        putc(fd, *ap);
 735:	8b 45 e8             	mov    -0x18(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	83 ec 08             	sub    $0x8,%esp
 740:	50                   	push   %eax
 741:	ff 75 08             	pushl  0x8(%ebp)
 744:	e8 04 fe ff ff       	call   54d <putc>
 749:	83 c4 10             	add    $0x10,%esp
        ap++;
 74c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 750:	eb 42                	jmp    794 <printf+0x170>
      } else if(c == '%'){
 752:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 756:	75 17                	jne    76f <printf+0x14b>
        putc(fd, c);
 758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	83 ec 08             	sub    $0x8,%esp
 761:	50                   	push   %eax
 762:	ff 75 08             	pushl  0x8(%ebp)
 765:	e8 e3 fd ff ff       	call   54d <putc>
 76a:	83 c4 10             	add    $0x10,%esp
 76d:	eb 25                	jmp    794 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76f:	83 ec 08             	sub    $0x8,%esp
 772:	6a 25                	push   $0x25
 774:	ff 75 08             	pushl  0x8(%ebp)
 777:	e8 d1 fd ff ff       	call   54d <putc>
 77c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 77f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 782:	0f be c0             	movsbl %al,%eax
 785:	83 ec 08             	sub    $0x8,%esp
 788:	50                   	push   %eax
 789:	ff 75 08             	pushl  0x8(%ebp)
 78c:	e8 bc fd ff ff       	call   54d <putc>
 791:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 794:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79f:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	01 d0                	add    %edx,%eax
 7a7:	0f b6 00             	movzbl (%eax),%eax
 7aa:	84 c0                	test   %al,%al
 7ac:	0f 85 94 fe ff ff    	jne    646 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b2:	90                   	nop
 7b3:	c9                   	leave  
 7b4:	c3                   	ret    

000007b5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b5:	55                   	push   %ebp
 7b6:	89 e5                	mov    %esp,%ebp
 7b8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	83 e8 08             	sub    $0x8,%eax
 7c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	a1 a8 0c 00 00       	mov    0xca8,%eax
 7c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cc:	eb 24                	jmp    7f2 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d6:	77 12                	ja     7ea <free+0x35>
 7d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7de:	77 24                	ja     804 <free+0x4f>
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e8:	77 1a                	ja     804 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ed:	8b 00                	mov    (%eax),%eax
 7ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f8:	76 d4                	jbe    7ce <free+0x19>
 7fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 802:	76 ca                	jbe    7ce <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 804:	8b 45 f8             	mov    -0x8(%ebp),%eax
 807:	8b 40 04             	mov    0x4(%eax),%eax
 80a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 811:	8b 45 f8             	mov    -0x8(%ebp),%eax
 814:	01 c2                	add    %eax,%edx
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 00                	mov    (%eax),%eax
 81b:	39 c2                	cmp    %eax,%edx
 81d:	75 24                	jne    843 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	8b 50 04             	mov    0x4(%eax),%edx
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	01 c2                	add    %eax,%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	8b 10                	mov    (%eax),%edx
 83c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83f:	89 10                	mov    %edx,(%eax)
 841:	eb 0a                	jmp    84d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 10                	mov    (%eax),%edx
 848:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	8b 40 04             	mov    0x4(%eax),%eax
 853:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 85a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85d:	01 d0                	add    %edx,%eax
 85f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 862:	75 20                	jne    884 <free+0xcf>
    p->s.size += bp->s.size;
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	8b 50 04             	mov    0x4(%eax),%edx
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	01 c2                	add    %eax,%edx
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 878:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87b:	8b 10                	mov    (%eax),%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	89 10                	mov    %edx,(%eax)
 882:	eb 08                	jmp    88c <free+0xd7>
  } else
    p->s.ptr = bp;
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88a:	89 10                	mov    %edx,(%eax)
  freep = p;
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	a3 a8 0c 00 00       	mov    %eax,0xca8
}
 894:	90                   	nop
 895:	c9                   	leave  
 896:	c3                   	ret    

00000897 <morecore>:

static Header*
morecore(uint nu)
{
 897:	55                   	push   %ebp
 898:	89 e5                	mov    %esp,%ebp
 89a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a4:	77 07                	ja     8ad <morecore+0x16>
    nu = 4096;
 8a6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ad:	8b 45 08             	mov    0x8(%ebp),%eax
 8b0:	c1 e0 03             	shl    $0x3,%eax
 8b3:	83 ec 0c             	sub    $0xc,%esp
 8b6:	50                   	push   %eax
 8b7:	e8 19 fc ff ff       	call   4d5 <sbrk>
 8bc:	83 c4 10             	add    $0x10,%esp
 8bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c6:	75 07                	jne    8cf <morecore+0x38>
    return 0;
 8c8:	b8 00 00 00 00       	mov    $0x0,%eax
 8cd:	eb 26                	jmp    8f5 <morecore+0x5e>
  hp = (Header*)p;
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	8b 55 08             	mov    0x8(%ebp),%edx
 8db:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e1:	83 c0 08             	add    $0x8,%eax
 8e4:	83 ec 0c             	sub    $0xc,%esp
 8e7:	50                   	push   %eax
 8e8:	e8 c8 fe ff ff       	call   7b5 <free>
 8ed:	83 c4 10             	add    $0x10,%esp
  return freep;
 8f0:	a1 a8 0c 00 00       	mov    0xca8,%eax
}
 8f5:	c9                   	leave  
 8f6:	c3                   	ret    

000008f7 <malloc>:

void*
malloc(uint nbytes)
{
 8f7:	55                   	push   %ebp
 8f8:	89 e5                	mov    %esp,%ebp
 8fa:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fd:	8b 45 08             	mov    0x8(%ebp),%eax
 900:	83 c0 07             	add    $0x7,%eax
 903:	c1 e8 03             	shr    $0x3,%eax
 906:	83 c0 01             	add    $0x1,%eax
 909:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 90c:	a1 a8 0c 00 00       	mov    0xca8,%eax
 911:	89 45 f0             	mov    %eax,-0x10(%ebp)
 914:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 918:	75 23                	jne    93d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 91a:	c7 45 f0 a0 0c 00 00 	movl   $0xca0,-0x10(%ebp)
 921:	8b 45 f0             	mov    -0x10(%ebp),%eax
 924:	a3 a8 0c 00 00       	mov    %eax,0xca8
 929:	a1 a8 0c 00 00       	mov    0xca8,%eax
 92e:	a3 a0 0c 00 00       	mov    %eax,0xca0
    base.s.size = 0;
 933:	c7 05 a4 0c 00 00 00 	movl   $0x0,0xca4
 93a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 945:	8b 45 f4             	mov    -0xc(%ebp),%eax
 948:	8b 40 04             	mov    0x4(%eax),%eax
 94b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94e:	72 4d                	jb     99d <malloc+0xa6>
      if(p->s.size == nunits)
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8b 40 04             	mov    0x4(%eax),%eax
 956:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 959:	75 0c                	jne    967 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 95b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95e:	8b 10                	mov    (%eax),%edx
 960:	8b 45 f0             	mov    -0x10(%ebp),%eax
 963:	89 10                	mov    %edx,(%eax)
 965:	eb 26                	jmp    98d <malloc+0x96>
      else {
        p->s.size -= nunits;
 967:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96a:	8b 40 04             	mov    0x4(%eax),%eax
 96d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 970:	89 c2                	mov    %eax,%edx
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 978:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97b:	8b 40 04             	mov    0x4(%eax),%eax
 97e:	c1 e0 03             	shl    $0x3,%eax
 981:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 984:	8b 45 f4             	mov    -0xc(%ebp),%eax
 987:	8b 55 ec             	mov    -0x14(%ebp),%edx
 98a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 98d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 990:	a3 a8 0c 00 00       	mov    %eax,0xca8
      return (void*)(p + 1);
 995:	8b 45 f4             	mov    -0xc(%ebp),%eax
 998:	83 c0 08             	add    $0x8,%eax
 99b:	eb 3b                	jmp    9d8 <malloc+0xe1>
    }
    if(p == freep)
 99d:	a1 a8 0c 00 00       	mov    0xca8,%eax
 9a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9a5:	75 1e                	jne    9c5 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9a7:	83 ec 0c             	sub    $0xc,%esp
 9aa:	ff 75 ec             	pushl  -0x14(%ebp)
 9ad:	e8 e5 fe ff ff       	call   897 <morecore>
 9b2:	83 c4 10             	add    $0x10,%esp
 9b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9bc:	75 07                	jne    9c5 <malloc+0xce>
        return 0;
 9be:	b8 00 00 00 00       	mov    $0x0,%eax
 9c3:	eb 13                	jmp    9d8 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ce:	8b 00                	mov    (%eax),%eax
 9d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9d3:	e9 6d ff ff ff       	jmp    945 <malloc+0x4e>
}
 9d8:	c9                   	leave  
 9d9:	c3                   	ret    
