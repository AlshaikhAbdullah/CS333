
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "uproc.h"
#define MAX 32

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 28             	sub    $0x28,%esp
   uint max = MAX;
  14:	c7 45 e0 20 00 00 00 	movl   $0x20,-0x20(%ebp)
   int result;
   int reminder;
   struct uproc* table = malloc (max * sizeof(struct uproc)); 
  1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1e:	89 d0                	mov    %edx,%eax
  20:	01 c0                	add    %eax,%eax
  22:	01 d0                	add    %edx,%eax
  24:	c1 e0 05             	shl    $0x5,%eax
  27:	83 ec 0c             	sub    $0xc,%esp
  2a:	50                   	push   %eax
  2b:	e8 f6 09 00 00       	call   a26 <malloc>
  30:	83 c4 10             	add    $0x10,%esp
  33:	89 45 dc             	mov    %eax,-0x24(%ebp)
   int procforeal = getprocs(max, table); 
  36:	83 ec 08             	sub    $0x8,%esp
  39:	ff 75 dc             	pushl  -0x24(%ebp)
  3c:	ff 75 e0             	pushl  -0x20(%ebp)
  3f:	e8 10 06 00 00       	call   654 <getprocs>
  44:	83 c4 10             	add    $0x10,%esp
  47:	89 45 d8             	mov    %eax,-0x28(%ebp)

   printf(1, "\nMAX = %d\n", max); 
  4a:	83 ec 04             	sub    $0x4,%esp
  4d:	ff 75 e0             	pushl  -0x20(%ebp)
  50:	68 0c 0b 00 00       	push   $0xb0c
  55:	6a 01                	push   $0x1
  57:	e8 f7 06 00 00       	call   753 <printf>
  5c:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
   printf(1, "PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\n");
  5f:	83 ec 08             	sub    $0x8,%esp
  62:	68 18 0b 00 00       	push   $0xb18
  67:	6a 01                	push   $0x1
  69:	e8 e5 06 00 00       	call   753 <printf>
  6e:	83 c4 10             	add    $0x10,%esp
#else
   printf(1, "PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n"); 
#endif

   for(int i = 0; i < procforeal; ++i)
  71:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  78:	e9 c4 01 00 00       	jmp    241 <main+0x241>
   {
      printf(1, "%d\t%s\t%d\t%d\t%d\t", table[i].pid, table[i].name, table[i].uid, table[i].gid, table[i].ppid); 
  7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80:	89 d0                	mov    %edx,%eax
  82:	01 c0                	add    %eax,%eax
  84:	01 d0                	add    %edx,%eax
  86:	c1 e0 05             	shl    $0x5,%eax
  89:	89 c2                	mov    %eax,%edx
  8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8e:	01 d0                	add    %edx,%eax
  90:	8b 70 0c             	mov    0xc(%eax),%esi
  93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  96:	89 d0                	mov    %edx,%eax
  98:	01 c0                	add    %eax,%eax
  9a:	01 d0                	add    %edx,%eax
  9c:	c1 e0 05             	shl    $0x5,%eax
  9f:	89 c2                	mov    %eax,%edx
  a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  a4:	01 d0                	add    %edx,%eax
  a6:	8b 58 08             	mov    0x8(%eax),%ebx
  a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  ac:	89 d0                	mov    %edx,%eax
  ae:	01 c0                	add    %eax,%eax
  b0:	01 d0                	add    %edx,%eax
  b2:	c1 e0 05             	shl    $0x5,%eax
  b5:	89 c2                	mov    %eax,%edx
  b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  ba:	01 d0                	add    %edx,%eax
  bc:	8b 48 04             	mov    0x4(%eax),%ecx
  bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  c2:	89 d0                	mov    %edx,%eax
  c4:	01 c0                	add    %eax,%eax
  c6:	01 d0                	add    %edx,%eax
  c8:	c1 e0 05             	shl    $0x5,%eax
  cb:	89 c2                	mov    %eax,%edx
  cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  d0:	01 d0                	add    %edx,%eax
  d2:	8d 78 3c             	lea    0x3c(%eax),%edi
  d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  d8:	89 d0                	mov    %edx,%eax
  da:	01 c0                	add    %eax,%eax
  dc:	01 d0                	add    %edx,%eax
  de:	c1 e0 05             	shl    $0x5,%eax
  e1:	89 c2                	mov    %eax,%edx
  e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  e6:	01 d0                	add    %edx,%eax
  e8:	8b 00                	mov    (%eax),%eax
  ea:	83 ec 04             	sub    $0x4,%esp
  ed:	56                   	push   %esi
  ee:	53                   	push   %ebx
  ef:	51                   	push   %ecx
  f0:	57                   	push   %edi
  f1:	50                   	push   %eax
  f2:	68 4b 0b 00 00       	push   $0xb4b
  f7:	6a 01                	push   $0x1
  f9:	e8 55 06 00 00       	call   753 <printf>
  fe:	83 c4 20             	add    $0x20,%esp
#ifdef CS333_P3P4
      printf(1,"%d\t",table[i].priority);
 101:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 104:	89 d0                	mov    %edx,%eax
 106:	01 c0                	add    %eax,%eax
 108:	01 d0                	add    %edx,%eax
 10a:	c1 e0 05             	shl    $0x5,%eax
 10d:	89 c2                	mov    %eax,%edx
 10f:	8b 45 dc             	mov    -0x24(%ebp),%eax
 112:	01 d0                	add    %edx,%eax
 114:	8b 40 5c             	mov    0x5c(%eax),%eax
 117:	83 ec 04             	sub    $0x4,%esp
 11a:	50                   	push   %eax
 11b:	68 5b 0b 00 00       	push   $0xb5b
 120:	6a 01                	push   $0x1
 122:	e8 2c 06 00 00       	call   753 <printf>
 127:	83 c4 10             	add    $0x10,%esp
#endif
      result = table[i].elapsed_ticks/1000; 
 12a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 12d:	89 d0                	mov    %edx,%eax
 12f:	01 c0                	add    %eax,%eax
 131:	01 d0                	add    %edx,%eax
 133:	c1 e0 05             	shl    $0x5,%eax
 136:	89 c2                	mov    %eax,%edx
 138:	8b 45 dc             	mov    -0x24(%ebp),%eax
 13b:	01 d0                	add    %edx,%eax
 13d:	8b 40 10             	mov    0x10(%eax),%eax
 140:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 145:	f7 e2                	mul    %edx
 147:	89 d0                	mov    %edx,%eax
 149:	c1 e8 06             	shr    $0x6,%eax
 14c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      reminder = table[i].elapsed_ticks%1000; 
 14f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 152:	89 d0                	mov    %edx,%eax
 154:	01 c0                	add    %eax,%eax
 156:	01 d0                	add    %edx,%eax
 158:	c1 e0 05             	shl    $0x5,%eax
 15b:	89 c2                	mov    %eax,%edx
 15d:	8b 45 dc             	mov    -0x24(%ebp),%eax
 160:	01 d0                	add    %edx,%eax
 162:	8b 48 10             	mov    0x10(%eax),%ecx
 165:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 16a:	89 c8                	mov    %ecx,%eax
 16c:	f7 e2                	mul    %edx
 16e:	89 d0                	mov    %edx,%eax
 170:	c1 e8 06             	shr    $0x6,%eax
 173:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 179:	29 c1                	sub    %eax,%ecx
 17b:	89 c8                	mov    %ecx,%eax
 17d:	89 45 d0             	mov    %eax,-0x30(%ebp)
      printf(1, "%d.%d\t", result,reminder);
 180:	ff 75 d0             	pushl  -0x30(%ebp)
 183:	ff 75 d4             	pushl  -0x2c(%ebp)
 186:	68 5f 0b 00 00       	push   $0xb5f
 18b:	6a 01                	push   $0x1
 18d:	e8 c1 05 00 00       	call   753 <printf>
 192:	83 c4 10             	add    $0x10,%esp
    

      result = table[i].CPU_total_ticks/1000; // find result
 195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 198:	89 d0                	mov    %edx,%eax
 19a:	01 c0                	add    %eax,%eax
 19c:	01 d0                	add    %edx,%eax
 19e:	c1 e0 05             	shl    $0x5,%eax
 1a1:	89 c2                	mov    %eax,%edx
 1a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1a6:	01 d0                	add    %edx,%eax
 1a8:	8b 40 14             	mov    0x14(%eax),%eax
 1ab:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1b0:	f7 e2                	mul    %edx
 1b2:	89 d0                	mov    %edx,%eax
 1b4:	c1 e8 06             	shr    $0x6,%eax
 1b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      reminder = table[i].CPU_total_ticks%1000; // find the reminder 
 1ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1bd:	89 d0                	mov    %edx,%eax
 1bf:	01 c0                	add    %eax,%eax
 1c1:	01 d0                	add    %edx,%eax
 1c3:	c1 e0 05             	shl    $0x5,%eax
 1c6:	89 c2                	mov    %eax,%edx
 1c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1cb:	01 d0                	add    %edx,%eax
 1cd:	8b 48 14             	mov    0x14(%eax),%ecx
 1d0:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1d5:	89 c8                	mov    %ecx,%eax
 1d7:	f7 e2                	mul    %edx
 1d9:	89 d0                	mov    %edx,%eax
 1db:	c1 e8 06             	shr    $0x6,%eax
 1de:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 1e4:	29 c1                	sub    %eax,%ecx
 1e6:	89 c8                	mov    %ecx,%eax
 1e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

      printf(1, "%d.%d\t", result,reminder); 
 1eb:	ff 75 d0             	pushl  -0x30(%ebp)
 1ee:	ff 75 d4             	pushl  -0x2c(%ebp)
 1f1:	68 5f 0b 00 00       	push   $0xb5f
 1f6:	6a 01                	push   $0x1
 1f8:	e8 56 05 00 00       	call   753 <printf>
 1fd:	83 c4 10             	add    $0x10,%esp
    printf(1, "%s\t%d\n", table[i].state, table[i].size); // display state and size
 200:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 203:	89 d0                	mov    %edx,%eax
 205:	01 c0                	add    %eax,%eax
 207:	01 d0                	add    %edx,%eax
 209:	c1 e0 05             	shl    $0x5,%eax
 20c:	89 c2                	mov    %eax,%edx
 20e:	8b 45 dc             	mov    -0x24(%ebp),%eax
 211:	01 d0                	add    %edx,%eax
 213:	8b 48 38             	mov    0x38(%eax),%ecx
 216:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 219:	89 d0                	mov    %edx,%eax
 21b:	01 c0                	add    %eax,%eax
 21d:	01 d0                	add    %edx,%eax
 21f:	c1 e0 05             	shl    $0x5,%eax
 222:	89 c2                	mov    %eax,%edx
 224:	8b 45 dc             	mov    -0x24(%ebp),%eax
 227:	01 d0                	add    %edx,%eax
 229:	83 c0 18             	add    $0x18,%eax
 22c:	51                   	push   %ecx
 22d:	50                   	push   %eax
 22e:	68 66 0b 00 00       	push   $0xb66
 233:	6a 01                	push   $0x1
 235:	e8 19 05 00 00       	call   753 <printf>
 23a:	83 c4 10             	add    $0x10,%esp
   printf(1, "PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSize\n");
#else
   printf(1, "PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n"); 
#endif

   for(int i = 0; i < procforeal; ++i)
 23d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 244:	3b 45 d8             	cmp    -0x28(%ebp),%eax
 247:	0f 8c 30 fe ff ff    	jl     7d <main+0x7d>
      reminder = table[i].CPU_total_ticks%1000; // find the reminder 

      printf(1, "%d.%d\t", result,reminder); 
    printf(1, "%s\t%d\n", table[i].state, table[i].size); // display state and size
   }
   exit();
 24d:	e8 2a 03 00 00       	call   57c <exit>

00000252 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 252:	55                   	push   %ebp
 253:	89 e5                	mov    %esp,%ebp
 255:	57                   	push   %edi
 256:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 257:	8b 4d 08             	mov    0x8(%ebp),%ecx
 25a:	8b 55 10             	mov    0x10(%ebp),%edx
 25d:	8b 45 0c             	mov    0xc(%ebp),%eax
 260:	89 cb                	mov    %ecx,%ebx
 262:	89 df                	mov    %ebx,%edi
 264:	89 d1                	mov    %edx,%ecx
 266:	fc                   	cld    
 267:	f3 aa                	rep stos %al,%es:(%edi)
 269:	89 ca                	mov    %ecx,%edx
 26b:	89 fb                	mov    %edi,%ebx
 26d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 270:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 273:	90                   	nop
 274:	5b                   	pop    %ebx
 275:	5f                   	pop    %edi
 276:	5d                   	pop    %ebp
 277:	c3                   	ret    

00000278 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 278:	55                   	push   %ebp
 279:	89 e5                	mov    %esp,%ebp
 27b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 284:	90                   	nop
 285:	8b 45 08             	mov    0x8(%ebp),%eax
 288:	8d 50 01             	lea    0x1(%eax),%edx
 28b:	89 55 08             	mov    %edx,0x8(%ebp)
 28e:	8b 55 0c             	mov    0xc(%ebp),%edx
 291:	8d 4a 01             	lea    0x1(%edx),%ecx
 294:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 297:	0f b6 12             	movzbl (%edx),%edx
 29a:	88 10                	mov    %dl,(%eax)
 29c:	0f b6 00             	movzbl (%eax),%eax
 29f:	84 c0                	test   %al,%al
 2a1:	75 e2                	jne    285 <strcpy+0xd>
    ;
  return os;
 2a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2ab:	eb 08                	jmp    2b5 <strcmp+0xd>
    p++, q++;
 2ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	84 c0                	test   %al,%al
 2bd:	74 10                	je     2cf <strcmp+0x27>
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	0f b6 10             	movzbl (%eax),%edx
 2c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	38 c2                	cmp    %al,%dl
 2cd:	74 de                	je     2ad <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	0f b6 00             	movzbl (%eax),%eax
 2d5:	0f b6 d0             	movzbl %al,%edx
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	0f b6 c0             	movzbl %al,%eax
 2e1:	29 c2                	sub    %eax,%edx
 2e3:	89 d0                	mov    %edx,%eax
}
 2e5:	5d                   	pop    %ebp
 2e6:	c3                   	ret    

000002e7 <strlen>:

uint
strlen(char *s)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2f4:	eb 04                	jmp    2fa <strlen+0x13>
 2f6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	01 d0                	add    %edx,%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	84 c0                	test   %al,%al
 307:	75 ed                	jne    2f6 <strlen+0xf>
    ;
  return n;
 309:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30c:	c9                   	leave  
 30d:	c3                   	ret    

0000030e <memset>:

void*
memset(void *dst, int c, uint n)
{
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 311:	8b 45 10             	mov    0x10(%ebp),%eax
 314:	50                   	push   %eax
 315:	ff 75 0c             	pushl  0xc(%ebp)
 318:	ff 75 08             	pushl  0x8(%ebp)
 31b:	e8 32 ff ff ff       	call   252 <stosb>
 320:	83 c4 0c             	add    $0xc,%esp
  return dst;
 323:	8b 45 08             	mov    0x8(%ebp),%eax
}
 326:	c9                   	leave  
 327:	c3                   	ret    

00000328 <strchr>:

char*
strchr(const char *s, char c)
{
 328:	55                   	push   %ebp
 329:	89 e5                	mov    %esp,%ebp
 32b:	83 ec 04             	sub    $0x4,%esp
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 334:	eb 14                	jmp    34a <strchr+0x22>
    if(*s == c)
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	3a 45 fc             	cmp    -0x4(%ebp),%al
 33f:	75 05                	jne    346 <strchr+0x1e>
      return (char*)s;
 341:	8b 45 08             	mov    0x8(%ebp),%eax
 344:	eb 13                	jmp    359 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 346:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	0f b6 00             	movzbl (%eax),%eax
 350:	84 c0                	test   %al,%al
 352:	75 e2                	jne    336 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 354:	b8 00 00 00 00       	mov    $0x0,%eax
}
 359:	c9                   	leave  
 35a:	c3                   	ret    

0000035b <gets>:

char*
gets(char *buf, int max)
{
 35b:	55                   	push   %ebp
 35c:	89 e5                	mov    %esp,%ebp
 35e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 368:	eb 42                	jmp    3ac <gets+0x51>
    cc = read(0, &c, 1);
 36a:	83 ec 04             	sub    $0x4,%esp
 36d:	6a 01                	push   $0x1
 36f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 372:	50                   	push   %eax
 373:	6a 00                	push   $0x0
 375:	e8 1a 02 00 00       	call   594 <read>
 37a:	83 c4 10             	add    $0x10,%esp
 37d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 384:	7e 33                	jle    3b9 <gets+0x5e>
      break;
    buf[i++] = c;
 386:	8b 45 f4             	mov    -0xc(%ebp),%eax
 389:	8d 50 01             	lea    0x1(%eax),%edx
 38c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 38f:	89 c2                	mov    %eax,%edx
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	01 c2                	add    %eax,%edx
 396:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 39a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 39c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a0:	3c 0a                	cmp    $0xa,%al
 3a2:	74 16                	je     3ba <gets+0x5f>
 3a4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a8:	3c 0d                	cmp    $0xd,%al
 3aa:	74 0e                	je     3ba <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3af:	83 c0 01             	add    $0x1,%eax
 3b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3b5:	7c b3                	jl     36a <gets+0xf>
 3b7:	eb 01                	jmp    3ba <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3b9:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	01 d0                	add    %edx,%eax
 3c2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c8:	c9                   	leave  
 3c9:	c3                   	ret    

000003ca <stat>:

int
stat(char *n, struct stat *st)
{
 3ca:	55                   	push   %ebp
 3cb:	89 e5                	mov    %esp,%ebp
 3cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d0:	83 ec 08             	sub    $0x8,%esp
 3d3:	6a 00                	push   $0x0
 3d5:	ff 75 08             	pushl  0x8(%ebp)
 3d8:	e8 df 01 00 00       	call   5bc <open>
 3dd:	83 c4 10             	add    $0x10,%esp
 3e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3e7:	79 07                	jns    3f0 <stat+0x26>
    return -1;
 3e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3ee:	eb 25                	jmp    415 <stat+0x4b>
  r = fstat(fd, st);
 3f0:	83 ec 08             	sub    $0x8,%esp
 3f3:	ff 75 0c             	pushl  0xc(%ebp)
 3f6:	ff 75 f4             	pushl  -0xc(%ebp)
 3f9:	e8 d6 01 00 00       	call   5d4 <fstat>
 3fe:	83 c4 10             	add    $0x10,%esp
 401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 404:	83 ec 0c             	sub    $0xc,%esp
 407:	ff 75 f4             	pushl  -0xc(%ebp)
 40a:	e8 95 01 00 00       	call   5a4 <close>
 40f:	83 c4 10             	add    $0x10,%esp
  return r;
 412:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 415:	c9                   	leave  
 416:	c3                   	ret    

00000417 <atoi>:

int
atoi(const char *s)
{
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 41d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 424:	eb 04                	jmp    42a <atoi+0x13>
 426:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	0f b6 00             	movzbl (%eax),%eax
 430:	3c 20                	cmp    $0x20,%al
 432:	74 f2                	je     426 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	0f b6 00             	movzbl (%eax),%eax
 43a:	3c 2d                	cmp    $0x2d,%al
 43c:	75 07                	jne    445 <atoi+0x2e>
 43e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 443:	eb 05                	jmp    44a <atoi+0x33>
 445:	b8 01 00 00 00       	mov    $0x1,%eax
 44a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	0f b6 00             	movzbl (%eax),%eax
 453:	3c 2b                	cmp    $0x2b,%al
 455:	74 0a                	je     461 <atoi+0x4a>
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	0f b6 00             	movzbl (%eax),%eax
 45d:	3c 2d                	cmp    $0x2d,%al
 45f:	75 2b                	jne    48c <atoi+0x75>
    s++;
 461:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 465:	eb 25                	jmp    48c <atoi+0x75>
    n = n*10 + *s++ - '0';
 467:	8b 55 fc             	mov    -0x4(%ebp),%edx
 46a:	89 d0                	mov    %edx,%eax
 46c:	c1 e0 02             	shl    $0x2,%eax
 46f:	01 d0                	add    %edx,%eax
 471:	01 c0                	add    %eax,%eax
 473:	89 c1                	mov    %eax,%ecx
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	8d 50 01             	lea    0x1(%eax),%edx
 47b:	89 55 08             	mov    %edx,0x8(%ebp)
 47e:	0f b6 00             	movzbl (%eax),%eax
 481:	0f be c0             	movsbl %al,%eax
 484:	01 c8                	add    %ecx,%eax
 486:	83 e8 30             	sub    $0x30,%eax
 489:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 48c:	8b 45 08             	mov    0x8(%ebp),%eax
 48f:	0f b6 00             	movzbl (%eax),%eax
 492:	3c 2f                	cmp    $0x2f,%al
 494:	7e 0a                	jle    4a0 <atoi+0x89>
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	0f b6 00             	movzbl (%eax),%eax
 49c:	3c 39                	cmp    $0x39,%al
 49e:	7e c7                	jle    467 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 4a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4a3:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4a7:	c9                   	leave  
 4a8:	c3                   	ret    

000004a9 <atoo>:

int
atoo(const char *s)
{
 4a9:	55                   	push   %ebp
 4aa:	89 e5                	mov    %esp,%ebp
 4ac:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4b6:	eb 04                	jmp    4bc <atoo+0x13>
 4b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	0f b6 00             	movzbl (%eax),%eax
 4c2:	3c 20                	cmp    $0x20,%al
 4c4:	74 f2                	je     4b8 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	3c 2d                	cmp    $0x2d,%al
 4ce:	75 07                	jne    4d7 <atoo+0x2e>
 4d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4d5:	eb 05                	jmp    4dc <atoo+0x33>
 4d7:	b8 01 00 00 00       	mov    $0x1,%eax
 4dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4df:	8b 45 08             	mov    0x8(%ebp),%eax
 4e2:	0f b6 00             	movzbl (%eax),%eax
 4e5:	3c 2b                	cmp    $0x2b,%al
 4e7:	74 0a                	je     4f3 <atoo+0x4a>
 4e9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ec:	0f b6 00             	movzbl (%eax),%eax
 4ef:	3c 2d                	cmp    $0x2d,%al
 4f1:	75 27                	jne    51a <atoo+0x71>
    s++;
 4f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 4f7:	eb 21                	jmp    51a <atoo+0x71>
    n = n*8 + *s++ - '0';
 4f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4fc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	8d 50 01             	lea    0x1(%eax),%edx
 509:	89 55 08             	mov    %edx,0x8(%ebp)
 50c:	0f b6 00             	movzbl (%eax),%eax
 50f:	0f be c0             	movsbl %al,%eax
 512:	01 c8                	add    %ecx,%eax
 514:	83 e8 30             	sub    $0x30,%eax
 517:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
 51d:	0f b6 00             	movzbl (%eax),%eax
 520:	3c 2f                	cmp    $0x2f,%al
 522:	7e 0a                	jle    52e <atoo+0x85>
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	0f b6 00             	movzbl (%eax),%eax
 52a:	3c 37                	cmp    $0x37,%al
 52c:	7e cb                	jle    4f9 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 52e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 531:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 535:	c9                   	leave  
 536:	c3                   	ret    

00000537 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 537:	55                   	push   %ebp
 538:	89 e5                	mov    %esp,%ebp
 53a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 543:	8b 45 0c             	mov    0xc(%ebp),%eax
 546:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 549:	eb 17                	jmp    562 <memmove+0x2b>
    *dst++ = *src++;
 54b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 54e:	8d 50 01             	lea    0x1(%eax),%edx
 551:	89 55 fc             	mov    %edx,-0x4(%ebp)
 554:	8b 55 f8             	mov    -0x8(%ebp),%edx
 557:	8d 4a 01             	lea    0x1(%edx),%ecx
 55a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 55d:	0f b6 12             	movzbl (%edx),%edx
 560:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 562:	8b 45 10             	mov    0x10(%ebp),%eax
 565:	8d 50 ff             	lea    -0x1(%eax),%edx
 568:	89 55 10             	mov    %edx,0x10(%ebp)
 56b:	85 c0                	test   %eax,%eax
 56d:	7f dc                	jg     54b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 572:	c9                   	leave  
 573:	c3                   	ret    

00000574 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 574:	b8 01 00 00 00       	mov    $0x1,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <exit>:
SYSCALL(exit)
 57c:	b8 02 00 00 00       	mov    $0x2,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <wait>:
SYSCALL(wait)
 584:	b8 03 00 00 00       	mov    $0x3,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <pipe>:
SYSCALL(pipe)
 58c:	b8 04 00 00 00       	mov    $0x4,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <read>:
SYSCALL(read)
 594:	b8 05 00 00 00       	mov    $0x5,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <write>:
SYSCALL(write)
 59c:	b8 10 00 00 00       	mov    $0x10,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <close>:
SYSCALL(close)
 5a4:	b8 15 00 00 00       	mov    $0x15,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <kill>:
SYSCALL(kill)
 5ac:	b8 06 00 00 00       	mov    $0x6,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <exec>:
SYSCALL(exec)
 5b4:	b8 07 00 00 00       	mov    $0x7,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <open>:
SYSCALL(open)
 5bc:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <mknod>:
SYSCALL(mknod)
 5c4:	b8 11 00 00 00       	mov    $0x11,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <unlink>:
SYSCALL(unlink)
 5cc:	b8 12 00 00 00       	mov    $0x12,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <fstat>:
SYSCALL(fstat)
 5d4:	b8 08 00 00 00       	mov    $0x8,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <link>:
SYSCALL(link)
 5dc:	b8 13 00 00 00       	mov    $0x13,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <mkdir>:
SYSCALL(mkdir)
 5e4:	b8 14 00 00 00       	mov    $0x14,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <chdir>:
SYSCALL(chdir)
 5ec:	b8 09 00 00 00       	mov    $0x9,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <dup>:
SYSCALL(dup)
 5f4:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <getpid>:
SYSCALL(getpid)
 5fc:	b8 0b 00 00 00       	mov    $0xb,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <sbrk>:
SYSCALL(sbrk)
 604:	b8 0c 00 00 00       	mov    $0xc,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <sleep>:
SYSCALL(sleep)
 60c:	b8 0d 00 00 00       	mov    $0xd,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <uptime>:
SYSCALL(uptime)
 614:	b8 0e 00 00 00       	mov    $0xe,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <halt>:
SYSCALL(halt)
 61c:	b8 16 00 00 00       	mov    $0x16,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <date>:
SYSCALL(date)
 624:	b8 17 00 00 00       	mov    $0x17,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <getuid>:
SYSCALL(getuid)
 62c:	b8 18 00 00 00       	mov    $0x18,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <getgid>:
SYSCALL(getgid)
 634:	b8 19 00 00 00       	mov    $0x19,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <getppid>:
SYSCALL(getppid)
 63c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <setuid>:
SYSCALL(setuid)
 644:	b8 1b 00 00 00       	mov    $0x1b,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <setgid>:
SYSCALL(setgid)
 64c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <getprocs>:
SYSCALL(getprocs)
 654:	b8 1d 00 00 00       	mov    $0x1d,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <setpriority>:
SYSCALL(setpriority)
 65c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <chmod>:
SYSCALL(chmod)
 664:	b8 1f 00 00 00       	mov    $0x1f,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <chown>:
SYSCALL(chown)
 66c:	b8 20 00 00 00       	mov    $0x20,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <chgrp>:
SYSCALL(chgrp)
 674:	b8 21 00 00 00       	mov    $0x21,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 67c:	55                   	push   %ebp
 67d:	89 e5                	mov    %esp,%ebp
 67f:	83 ec 18             	sub    $0x18,%esp
 682:	8b 45 0c             	mov    0xc(%ebp),%eax
 685:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 688:	83 ec 04             	sub    $0x4,%esp
 68b:	6a 01                	push   $0x1
 68d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 690:	50                   	push   %eax
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 03 ff ff ff       	call   59c <write>
 699:	83 c4 10             	add    $0x10,%esp
}
 69c:	90                   	nop
 69d:	c9                   	leave  
 69e:	c3                   	ret    

0000069f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69f:	55                   	push   %ebp
 6a0:	89 e5                	mov    %esp,%ebp
 6a2:	53                   	push   %ebx
 6a3:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b1:	74 17                	je     6ca <printint+0x2b>
 6b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b7:	79 11                	jns    6ca <printint+0x2b>
    neg = 1;
 6b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c3:	f7 d8                	neg    %eax
 6c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c8:	eb 06                	jmp    6d0 <printint+0x31>
  } else {
    x = xx;
 6ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6da:	8d 41 01             	lea    0x1(%ecx),%eax
 6dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e6:	ba 00 00 00 00       	mov    $0x0,%edx
 6eb:	f7 f3                	div    %ebx
 6ed:	89 d0                	mov    %edx,%eax
 6ef:	0f b6 80 e8 0d 00 00 	movzbl 0xde8(%eax),%eax
 6f6:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 700:	ba 00 00 00 00       	mov    $0x0,%edx
 705:	f7 f3                	div    %ebx
 707:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70e:	75 c7                	jne    6d7 <printint+0x38>
  if(neg)
 710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 714:	74 2d                	je     743 <printint+0xa4>
    buf[i++] = '-';
 716:	8b 45 f4             	mov    -0xc(%ebp),%eax
 719:	8d 50 01             	lea    0x1(%eax),%edx
 71c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 724:	eb 1d                	jmp    743 <printint+0xa4>
    putc(fd, buf[i]);
 726:	8d 55 dc             	lea    -0x24(%ebp),%edx
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	01 d0                	add    %edx,%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	83 ec 08             	sub    $0x8,%esp
 737:	50                   	push   %eax
 738:	ff 75 08             	pushl  0x8(%ebp)
 73b:	e8 3c ff ff ff       	call   67c <putc>
 740:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 743:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74b:	79 d9                	jns    726 <printint+0x87>
    putc(fd, buf[i]);
}
 74d:	90                   	nop
 74e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 751:	c9                   	leave  
 752:	c3                   	ret    

00000753 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 753:	55                   	push   %ebp
 754:	89 e5                	mov    %esp,%ebp
 756:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 759:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 760:	8d 45 0c             	lea    0xc(%ebp),%eax
 763:	83 c0 04             	add    $0x4,%eax
 766:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 770:	e9 59 01 00 00       	jmp    8ce <printf+0x17b>
    c = fmt[i] & 0xff;
 775:	8b 55 0c             	mov    0xc(%ebp),%edx
 778:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77b:	01 d0                	add    %edx,%eax
 77d:	0f b6 00             	movzbl (%eax),%eax
 780:	0f be c0             	movsbl %al,%eax
 783:	25 ff 00 00 00       	and    $0xff,%eax
 788:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 78b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78f:	75 2c                	jne    7bd <printf+0x6a>
      if(c == '%'){
 791:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 795:	75 0c                	jne    7a3 <printf+0x50>
        state = '%';
 797:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79e:	e9 27 01 00 00       	jmp    8ca <printf+0x177>
      } else {
        putc(fd, c);
 7a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a6:	0f be c0             	movsbl %al,%eax
 7a9:	83 ec 08             	sub    $0x8,%esp
 7ac:	50                   	push   %eax
 7ad:	ff 75 08             	pushl  0x8(%ebp)
 7b0:	e8 c7 fe ff ff       	call   67c <putc>
 7b5:	83 c4 10             	add    $0x10,%esp
 7b8:	e9 0d 01 00 00       	jmp    8ca <printf+0x177>
      }
    } else if(state == '%'){
 7bd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7c1:	0f 85 03 01 00 00    	jne    8ca <printf+0x177>
      if(c == 'd'){
 7c7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7cb:	75 1e                	jne    7eb <printf+0x98>
        printint(fd, *ap, 10, 1);
 7cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	6a 01                	push   $0x1
 7d4:	6a 0a                	push   $0xa
 7d6:	50                   	push   %eax
 7d7:	ff 75 08             	pushl  0x8(%ebp)
 7da:	e8 c0 fe ff ff       	call   69f <printint>
 7df:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e6:	e9 d8 00 00 00       	jmp    8c3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7eb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ef:	74 06                	je     7f7 <printf+0xa4>
 7f1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f5:	75 1e                	jne    815 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	6a 00                	push   $0x0
 7fe:	6a 10                	push   $0x10
 800:	50                   	push   %eax
 801:	ff 75 08             	pushl  0x8(%ebp)
 804:	e8 96 fe ff ff       	call   69f <printint>
 809:	83 c4 10             	add    $0x10,%esp
        ap++;
 80c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 810:	e9 ae 00 00 00       	jmp    8c3 <printf+0x170>
      } else if(c == 's'){
 815:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 819:	75 43                	jne    85e <printf+0x10b>
        s = (char*)*ap;
 81b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81e:	8b 00                	mov    (%eax),%eax
 820:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 823:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 827:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82b:	75 25                	jne    852 <printf+0xff>
          s = "(null)";
 82d:	c7 45 f4 6d 0b 00 00 	movl   $0xb6d,-0xc(%ebp)
        while(*s != 0){
 834:	eb 1c                	jmp    852 <printf+0xff>
          putc(fd, *s);
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	0f b6 00             	movzbl (%eax),%eax
 83c:	0f be c0             	movsbl %al,%eax
 83f:	83 ec 08             	sub    $0x8,%esp
 842:	50                   	push   %eax
 843:	ff 75 08             	pushl  0x8(%ebp)
 846:	e8 31 fe ff ff       	call   67c <putc>
 84b:	83 c4 10             	add    $0x10,%esp
          s++;
 84e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 852:	8b 45 f4             	mov    -0xc(%ebp),%eax
 855:	0f b6 00             	movzbl (%eax),%eax
 858:	84 c0                	test   %al,%al
 85a:	75 da                	jne    836 <printf+0xe3>
 85c:	eb 65                	jmp    8c3 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 85e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 862:	75 1d                	jne    881 <printf+0x12e>
        putc(fd, *ap);
 864:	8b 45 e8             	mov    -0x18(%ebp),%eax
 867:	8b 00                	mov    (%eax),%eax
 869:	0f be c0             	movsbl %al,%eax
 86c:	83 ec 08             	sub    $0x8,%esp
 86f:	50                   	push   %eax
 870:	ff 75 08             	pushl  0x8(%ebp)
 873:	e8 04 fe ff ff       	call   67c <putc>
 878:	83 c4 10             	add    $0x10,%esp
        ap++;
 87b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87f:	eb 42                	jmp    8c3 <printf+0x170>
      } else if(c == '%'){
 881:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 885:	75 17                	jne    89e <printf+0x14b>
        putc(fd, c);
 887:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 88a:	0f be c0             	movsbl %al,%eax
 88d:	83 ec 08             	sub    $0x8,%esp
 890:	50                   	push   %eax
 891:	ff 75 08             	pushl  0x8(%ebp)
 894:	e8 e3 fd ff ff       	call   67c <putc>
 899:	83 c4 10             	add    $0x10,%esp
 89c:	eb 25                	jmp    8c3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 89e:	83 ec 08             	sub    $0x8,%esp
 8a1:	6a 25                	push   $0x25
 8a3:	ff 75 08             	pushl  0x8(%ebp)
 8a6:	e8 d1 fd ff ff       	call   67c <putc>
 8ab:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b1:	0f be c0             	movsbl %al,%eax
 8b4:	83 ec 08             	sub    $0x8,%esp
 8b7:	50                   	push   %eax
 8b8:	ff 75 08             	pushl  0x8(%ebp)
 8bb:	e8 bc fd ff ff       	call   67c <putc>
 8c0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	01 d0                	add    %edx,%eax
 8d6:	0f b6 00             	movzbl (%eax),%eax
 8d9:	84 c0                	test   %al,%al
 8db:	0f 85 94 fe ff ff    	jne    775 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8e1:	90                   	nop
 8e2:	c9                   	leave  
 8e3:	c3                   	ret    

000008e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e4:	55                   	push   %ebp
 8e5:	89 e5                	mov    %esp,%ebp
 8e7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ea:	8b 45 08             	mov    0x8(%ebp),%eax
 8ed:	83 e8 08             	sub    $0x8,%eax
 8f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f3:	a1 04 0e 00 00       	mov    0xe04,%eax
 8f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8fb:	eb 24                	jmp    921 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 905:	77 12                	ja     919 <free+0x35>
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 90d:	77 24                	ja     933 <free+0x4f>
 90f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 912:	8b 00                	mov    (%eax),%eax
 914:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 917:	77 1a                	ja     933 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 927:	76 d4                	jbe    8fd <free+0x19>
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 931:	76 ca                	jbe    8fd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 933:	8b 45 f8             	mov    -0x8(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 940:	8b 45 f8             	mov    -0x8(%ebp),%eax
 943:	01 c2                	add    %eax,%edx
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	39 c2                	cmp    %eax,%edx
 94c:	75 24                	jne    972 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 94e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 951:	8b 50 04             	mov    0x4(%eax),%edx
 954:	8b 45 fc             	mov    -0x4(%ebp),%eax
 957:	8b 00                	mov    (%eax),%eax
 959:	8b 40 04             	mov    0x4(%eax),%eax
 95c:	01 c2                	add    %eax,%edx
 95e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 961:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 964:	8b 45 fc             	mov    -0x4(%ebp),%eax
 967:	8b 00                	mov    (%eax),%eax
 969:	8b 10                	mov    (%eax),%edx
 96b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96e:	89 10                	mov    %edx,(%eax)
 970:	eb 0a                	jmp    97c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 972:	8b 45 fc             	mov    -0x4(%ebp),%eax
 975:	8b 10                	mov    (%eax),%edx
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 97c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97f:	8b 40 04             	mov    0x4(%eax),%eax
 982:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	01 d0                	add    %edx,%eax
 98e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 991:	75 20                	jne    9b3 <free+0xcf>
    p->s.size += bp->s.size;
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	8b 50 04             	mov    0x4(%eax),%edx
 999:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99c:	8b 40 04             	mov    0x4(%eax),%eax
 99f:	01 c2                	add    %eax,%edx
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9aa:	8b 10                	mov    (%eax),%edx
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	89 10                	mov    %edx,(%eax)
 9b1:	eb 08                	jmp    9bb <free+0xd7>
  } else
    p->s.ptr = bp;
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b9:	89 10                	mov    %edx,(%eax)
  freep = p;
 9bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9be:	a3 04 0e 00 00       	mov    %eax,0xe04
}
 9c3:	90                   	nop
 9c4:	c9                   	leave  
 9c5:	c3                   	ret    

000009c6 <morecore>:

static Header*
morecore(uint nu)
{
 9c6:	55                   	push   %ebp
 9c7:	89 e5                	mov    %esp,%ebp
 9c9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9cc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d3:	77 07                	ja     9dc <morecore+0x16>
    nu = 4096;
 9d5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9dc:	8b 45 08             	mov    0x8(%ebp),%eax
 9df:	c1 e0 03             	shl    $0x3,%eax
 9e2:	83 ec 0c             	sub    $0xc,%esp
 9e5:	50                   	push   %eax
 9e6:	e8 19 fc ff ff       	call   604 <sbrk>
 9eb:	83 c4 10             	add    $0x10,%esp
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9f1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f5:	75 07                	jne    9fe <morecore+0x38>
    return 0;
 9f7:	b8 00 00 00 00       	mov    $0x0,%eax
 9fc:	eb 26                	jmp    a24 <morecore+0x5e>
  hp = (Header*)p;
 9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a07:	8b 55 08             	mov    0x8(%ebp),%edx
 a0a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a10:	83 c0 08             	add    $0x8,%eax
 a13:	83 ec 0c             	sub    $0xc,%esp
 a16:	50                   	push   %eax
 a17:	e8 c8 fe ff ff       	call   8e4 <free>
 a1c:	83 c4 10             	add    $0x10,%esp
  return freep;
 a1f:	a1 04 0e 00 00       	mov    0xe04,%eax
}
 a24:	c9                   	leave  
 a25:	c3                   	ret    

00000a26 <malloc>:

void*
malloc(uint nbytes)
{
 a26:	55                   	push   %ebp
 a27:	89 e5                	mov    %esp,%ebp
 a29:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2c:	8b 45 08             	mov    0x8(%ebp),%eax
 a2f:	83 c0 07             	add    $0x7,%eax
 a32:	c1 e8 03             	shr    $0x3,%eax
 a35:	83 c0 01             	add    $0x1,%eax
 a38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a3b:	a1 04 0e 00 00       	mov    0xe04,%eax
 a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a47:	75 23                	jne    a6c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a49:	c7 45 f0 fc 0d 00 00 	movl   $0xdfc,-0x10(%ebp)
 a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a53:	a3 04 0e 00 00       	mov    %eax,0xe04
 a58:	a1 04 0e 00 00       	mov    0xe04,%eax
 a5d:	a3 fc 0d 00 00       	mov    %eax,0xdfc
    base.s.size = 0;
 a62:	c7 05 00 0e 00 00 00 	movl   $0x0,0xe00
 a69:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6f:	8b 00                	mov    (%eax),%eax
 a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 40 04             	mov    0x4(%eax),%eax
 a7a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a7d:	72 4d                	jb     acc <malloc+0xa6>
      if(p->s.size == nunits)
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	8b 40 04             	mov    0x4(%eax),%eax
 a85:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a88:	75 0c                	jne    a96 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8d:	8b 10                	mov    (%eax),%edx
 a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a92:	89 10                	mov    %edx,(%eax)
 a94:	eb 26                	jmp    abc <malloc+0x96>
      else {
        p->s.size -= nunits;
 a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a99:	8b 40 04             	mov    0x4(%eax),%eax
 a9c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a9f:	89 c2                	mov    %eax,%edx
 aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaa:	8b 40 04             	mov    0x4(%eax),%eax
 aad:	c1 e0 03             	shl    $0x3,%eax
 ab0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abf:	a3 04 0e 00 00       	mov    %eax,0xe04
      return (void*)(p + 1);
 ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac7:	83 c0 08             	add    $0x8,%eax
 aca:	eb 3b                	jmp    b07 <malloc+0xe1>
    }
    if(p == freep)
 acc:	a1 04 0e 00 00       	mov    0xe04,%eax
 ad1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad4:	75 1e                	jne    af4 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ad6:	83 ec 0c             	sub    $0xc,%esp
 ad9:	ff 75 ec             	pushl  -0x14(%ebp)
 adc:	e8 e5 fe ff ff       	call   9c6 <morecore>
 ae1:	83 c4 10             	add    $0x10,%esp
 ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aeb:	75 07                	jne    af4 <malloc+0xce>
        return 0;
 aed:	b8 00 00 00 00       	mov    $0x0,%eax
 af2:	eb 13                	jmp    b07 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afd:	8b 00                	mov    (%eax),%eax
 aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b02:	e9 6d ff ff ff       	jmp    a74 <malloc+0x4e>
}
 b07:	c9                   	leave  
 b08:	c3                   	ret    
