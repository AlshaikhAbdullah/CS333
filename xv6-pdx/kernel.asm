
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 90 e6 10 80       	mov    $0x8010e690,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 d2 3b 10 80       	mov    $0x80103bd2,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 e0 a0 10 80       	push   $0x8010a0e0
80100042:	68 a0 e6 10 80       	push   $0x8010e6a0
80100047:	e8 7b 68 00 00       	call   801068c7 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 25 11 80 a4 	movl   $0x801125a4,0x801125b0
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 25 11 80 a4 	movl   $0x801125a4,0x801125b4
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 e6 10 80 	movl   $0x8010e6d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 25 11 80    	mov    0x801125b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 25 11 80 	movl   $0x801125a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 25 11 80       	mov    %eax,0x801125b4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 25 11 80       	mov    $0x801125a4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 a0 e6 10 80       	push   $0x8010e6a0
801000c1:	e8 23 68 00 00       	call   801068e9 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 b4 25 11 80       	mov    0x801125b4,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 a0 e6 10 80       	push   $0x8010e6a0
8010010c:	e8 3f 68 00 00       	call   80106950 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 a0 e6 10 80       	push   $0x8010e6a0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 25 57 00 00       	call   80105851 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 a4 25 11 80 	cmpl   $0x801125a4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 b0 25 11 80       	mov    0x801125b0,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 a0 e6 10 80       	push   $0x8010e6a0
80100188:	e8 c3 67 00 00       	call   80106950 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 a4 25 11 80 	cmpl   $0x801125a4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 e7 a0 10 80       	push   $0x8010a0e7
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 69 2a 00 00       	call   80102c50 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 f8 a0 10 80       	push   $0x8010a0f8
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 28 2a 00 00       	call   80102c50 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 ff a0 10 80       	push   $0x8010a0ff
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 a0 e6 10 80       	push   $0x8010e6a0
80100255:	e8 8f 66 00 00       	call   801068e9 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 b4 25 11 80    	mov    0x801125b4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c a4 25 11 80 	movl   $0x801125a4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 b4 25 11 80       	mov    %eax,0x801125b4

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 b7 57 00 00       	call   80105a75 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 a0 e6 10 80       	push   $0x8010e6a0
801002c9:	e8 82 66 00 00       	call   80106950 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 34 d6 10 80       	mov    0x8010d634,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 00 d6 10 80       	push   $0x8010d600
801003e2:	e8 02 65 00 00       	call   801068e9 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 06 a1 10 80       	push   $0x8010a106
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 0f a1 10 80 	movl   $0x8010a10f,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 00 d6 10 80       	push   $0x8010d600
8010055b:	e8 f0 63 00 00       	call   80106950 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 34 d6 10 80 00 	movl   $0x0,0x8010d634
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 16 a1 10 80       	push   $0x8010a116
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 25 a1 10 80       	push   $0x8010a125
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 db 63 00 00       	call   801069a2 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 27 a1 10 80       	push   $0x8010a127
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 e0 d5 10 80 01 	movl   $0x1,0x8010d5e0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 2b a1 10 80       	push   $0x8010a12b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 0f 65 00 00       	call   80106c0b <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 26 64 00 00       	call   80106b4c <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 e0 d5 10 80       	mov    0x8010d5e0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 ab 7f 00 00       	call   80108766 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 9e 7f 00 00       	call   80108766 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 91 7f 00 00       	call   80108766 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 81 7f 00 00       	call   80108766 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
#ifdef CS333_P3P4
  int doReady =0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int doFree =0;
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int doSleep =0;
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  int doZombie =0;
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
#endif

  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 00 d6 10 80       	push   $0x8010d600
8010082a:	e8 ba 60 00 00       	call   801068e9 <acquire>
8010082f:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100832:	e9 9a 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    switch(c){
80100837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010083a:	83 f8 12             	cmp    $0x12,%eax
8010083d:	74 50                	je     8010088f <consoleintr+0x96>
8010083f:	83 f8 12             	cmp    $0x12,%eax
80100842:	7f 18                	jg     8010085c <consoleintr+0x63>
80100844:	83 f8 08             	cmp    $0x8,%eax
80100847:	0f 84 bd 00 00 00    	je     8010090a <consoleintr+0x111>
8010084d:	83 f8 10             	cmp    $0x10,%eax
80100850:	74 31                	je     80100883 <consoleintr+0x8a>
80100852:	83 f8 06             	cmp    $0x6,%eax
80100855:	74 44                	je     8010089b <consoleintr+0xa2>
80100857:	e9 e3 00 00 00       	jmp    8010093f <consoleintr+0x146>
8010085c:	83 f8 15             	cmp    $0x15,%eax
8010085f:	74 7b                	je     801008dc <consoleintr+0xe3>
80100861:	83 f8 15             	cmp    $0x15,%eax
80100864:	7f 0a                	jg     80100870 <consoleintr+0x77>
80100866:	83 f8 13             	cmp    $0x13,%eax
80100869:	74 3c                	je     801008a7 <consoleintr+0xae>
8010086b:	e9 cf 00 00 00       	jmp    8010093f <consoleintr+0x146>
80100870:	83 f8 1a             	cmp    $0x1a,%eax
80100873:	74 3e                	je     801008b3 <consoleintr+0xba>
80100875:	83 f8 7f             	cmp    $0x7f,%eax
80100878:	0f 84 8c 00 00 00    	je     8010090a <consoleintr+0x111>
8010087e:	e9 bc 00 00 00       	jmp    8010093f <consoleintr+0x146>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100883:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010088a:	e9 42 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
#ifdef CS333_P3P4
    case C('R'):
      doReady =1;
8010088f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80100896:	e9 36 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('F'):
      doFree =1;
8010089b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      break;
801008a2:	e9 2a 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('S'):
        doSleep =1;
801008a7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
        break;
801008ae:	e9 1e 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('Z'):
        doZombie =1;
801008b3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
        break;
801008ba:	e9 12 01 00 00       	jmp    801009d1 <consoleintr+0x1d8>
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008bf:	a1 48 28 11 80       	mov    0x80112848,%eax
801008c4:	83 e8 01             	sub    $0x1,%eax
801008c7:	a3 48 28 11 80       	mov    %eax,0x80112848
        consputc(BACKSPACE);
801008cc:	83 ec 0c             	sub    $0xc,%esp
801008cf:	68 00 01 00 00       	push   $0x100
801008d4:	e8 b9 fe ff ff       	call   80100792 <consputc>
801008d9:	83 c4 10             	add    $0x10,%esp
    case C('Z'):
        doZombie =1;
        break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008dc:	8b 15 48 28 11 80    	mov    0x80112848,%edx
801008e2:	a1 44 28 11 80       	mov    0x80112844,%eax
801008e7:	39 c2                	cmp    %eax,%edx
801008e9:	0f 84 e2 00 00 00    	je     801009d1 <consoleintr+0x1d8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008ef:	a1 48 28 11 80       	mov    0x80112848,%eax
801008f4:	83 e8 01             	sub    $0x1,%eax
801008f7:	83 e0 7f             	and    $0x7f,%eax
801008fa:	0f b6 80 c0 27 11 80 	movzbl -0x7feed840(%eax),%eax
    case C('Z'):
        doZombie =1;
        break;
#endif
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100901:	3c 0a                	cmp    $0xa,%al
80100903:	75 ba                	jne    801008bf <consoleintr+0xc6>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100905:	e9 c7 00 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010090a:	8b 15 48 28 11 80    	mov    0x80112848,%edx
80100910:	a1 44 28 11 80       	mov    0x80112844,%eax
80100915:	39 c2                	cmp    %eax,%edx
80100917:	0f 84 b4 00 00 00    	je     801009d1 <consoleintr+0x1d8>
        input.e--;
8010091d:	a1 48 28 11 80       	mov    0x80112848,%eax
80100922:	83 e8 01             	sub    $0x1,%eax
80100925:	a3 48 28 11 80       	mov    %eax,0x80112848
        consputc(BACKSPACE);
8010092a:	83 ec 0c             	sub    $0xc,%esp
8010092d:	68 00 01 00 00       	push   $0x100
80100932:	e8 5b fe ff ff       	call   80100792 <consputc>
80100937:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010093a:	e9 92 00 00 00       	jmp    801009d1 <consoleintr+0x1d8>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010093f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100943:	0f 84 87 00 00 00    	je     801009d0 <consoleintr+0x1d7>
80100949:	8b 15 48 28 11 80    	mov    0x80112848,%edx
8010094f:	a1 40 28 11 80       	mov    0x80112840,%eax
80100954:	29 c2                	sub    %eax,%edx
80100956:	89 d0                	mov    %edx,%eax
80100958:	83 f8 7f             	cmp    $0x7f,%eax
8010095b:	77 73                	ja     801009d0 <consoleintr+0x1d7>
        c = (c == '\r') ? '\n' : c;
8010095d:	83 7d e0 0d          	cmpl   $0xd,-0x20(%ebp)
80100961:	74 05                	je     80100968 <consoleintr+0x16f>
80100963:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100966:	eb 05                	jmp    8010096d <consoleintr+0x174>
80100968:	b8 0a 00 00 00       	mov    $0xa,%eax
8010096d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100970:	a1 48 28 11 80       	mov    0x80112848,%eax
80100975:	8d 50 01             	lea    0x1(%eax),%edx
80100978:	89 15 48 28 11 80    	mov    %edx,0x80112848
8010097e:	83 e0 7f             	and    $0x7f,%eax
80100981:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100984:	88 90 c0 27 11 80    	mov    %dl,-0x7feed840(%eax)
        consputc(c);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	ff 75 e0             	pushl  -0x20(%ebp)
80100990:	e8 fd fd ff ff       	call   80100792 <consputc>
80100995:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100998:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
8010099c:	74 18                	je     801009b6 <consoleintr+0x1bd>
8010099e:	83 7d e0 04          	cmpl   $0x4,-0x20(%ebp)
801009a2:	74 12                	je     801009b6 <consoleintr+0x1bd>
801009a4:	a1 48 28 11 80       	mov    0x80112848,%eax
801009a9:	8b 15 40 28 11 80    	mov    0x80112840,%edx
801009af:	83 ea 80             	sub    $0xffffff80,%edx
801009b2:	39 d0                	cmp    %edx,%eax
801009b4:	75 1a                	jne    801009d0 <consoleintr+0x1d7>
          input.w = input.e;
801009b6:	a1 48 28 11 80       	mov    0x80112848,%eax
801009bb:	a3 44 28 11 80       	mov    %eax,0x80112844
          wakeup(&input.r);
801009c0:	83 ec 0c             	sub    $0xc,%esp
801009c3:	68 40 28 11 80       	push   $0x80112840
801009c8:	e8 a8 50 00 00       	call   80105a75 <wakeup>
801009cd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009d0:	90                   	nop
  int doSleep =0;
  int doZombie =0;
#endif

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009d1:	8b 45 08             	mov    0x8(%ebp),%eax
801009d4:	ff d0                	call   *%eax
801009d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801009d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801009dd:	0f 89 54 fe ff ff    	jns    80100837 <consoleintr+0x3e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009e3:	83 ec 0c             	sub    $0xc,%esp
801009e6:	68 00 d6 10 80       	push   $0x8010d600
801009eb:	e8 60 5f 00 00       	call   80106950 <release>
801009f0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009f7:	74 05                	je     801009fe <consoleintr+0x205>
    procdump();  // now call procdump() wo. cons.lock held
801009f9:	e8 05 53 00 00       	call   80105d03 <procdump>
  }
#ifdef CS333_P3P4
  if(doReady)
801009fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a02:	74 05                	je     80100a09 <consoleintr+0x210>
      control_r();
80100a04:	e8 57 59 00 00       	call   80106360 <control_r>
  if(doFree)
80100a09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a0d:	74 05                	je     80100a14 <consoleintr+0x21b>
      control_f();
80100a0f:	e8 1f 5a 00 00       	call   80106433 <control_f>
  if(doSleep)
80100a14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a18:	74 05                	je     80100a1f <consoleintr+0x226>
      control_s();
80100a1a:	e8 84 5a 00 00       	call   801064a3 <control_s>
  if(doZombie)
80100a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a23:	74 05                	je     80100a2a <consoleintr+0x231>
      control_z();
80100a25:	e8 01 5b 00 00       	call   8010652b <control_z>
#endif
}
80100a2a:	90                   	nop
80100a2b:	c9                   	leave  
80100a2c:	c3                   	ret    

80100a2d <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a2d:	55                   	push   %ebp
80100a2e:	89 e5                	mov    %esp,%ebp
80100a30:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a33:	83 ec 0c             	sub    $0xc,%esp
80100a36:	ff 75 08             	pushl  0x8(%ebp)
80100a39:	e8 2b 12 00 00       	call   80101c69 <iunlock>
80100a3e:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a41:	8b 45 10             	mov    0x10(%ebp),%eax
80100a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a47:	83 ec 0c             	sub    $0xc,%esp
80100a4a:	68 00 d6 10 80       	push   $0x8010d600
80100a4f:	e8 95 5e 00 00       	call   801068e9 <acquire>
80100a54:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a57:	e9 ac 00 00 00       	jmp    80100b08 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a62:	8b 40 24             	mov    0x24(%eax),%eax
80100a65:	85 c0                	test   %eax,%eax
80100a67:	74 28                	je     80100a91 <consoleread+0x64>
        release(&cons.lock);
80100a69:	83 ec 0c             	sub    $0xc,%esp
80100a6c:	68 00 d6 10 80       	push   $0x8010d600
80100a71:	e8 da 5e 00 00       	call   80106950 <release>
80100a76:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a79:	83 ec 0c             	sub    $0xc,%esp
80100a7c:	ff 75 08             	pushl  0x8(%ebp)
80100a7f:	e8 5f 10 00 00       	call   80101ae3 <ilock>
80100a84:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a8c:	e9 ab 00 00 00       	jmp    80100b3c <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a91:	83 ec 08             	sub    $0x8,%esp
80100a94:	68 00 d6 10 80       	push   $0x8010d600
80100a99:	68 40 28 11 80       	push   $0x80112840
80100a9e:	e8 ae 4d 00 00       	call   80105851 <sleep>
80100aa3:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100aa6:	8b 15 40 28 11 80    	mov    0x80112840,%edx
80100aac:	a1 44 28 11 80       	mov    0x80112844,%eax
80100ab1:	39 c2                	cmp    %eax,%edx
80100ab3:	74 a7                	je     80100a5c <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ab5:	a1 40 28 11 80       	mov    0x80112840,%eax
80100aba:	8d 50 01             	lea    0x1(%eax),%edx
80100abd:	89 15 40 28 11 80    	mov    %edx,0x80112840
80100ac3:	83 e0 7f             	and    $0x7f,%eax
80100ac6:	0f b6 80 c0 27 11 80 	movzbl -0x7feed840(%eax),%eax
80100acd:	0f be c0             	movsbl %al,%eax
80100ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ad3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ad7:	75 17                	jne    80100af0 <consoleread+0xc3>
      if(n < target){
80100ad9:	8b 45 10             	mov    0x10(%ebp),%eax
80100adc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100adf:	73 2f                	jae    80100b10 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ae1:	a1 40 28 11 80       	mov    0x80112840,%eax
80100ae6:	83 e8 01             	sub    $0x1,%eax
80100ae9:	a3 40 28 11 80       	mov    %eax,0x80112840
      }
      break;
80100aee:	eb 20                	jmp    80100b10 <consoleread+0xe3>
    }
    *dst++ = c;
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	8d 50 01             	lea    0x1(%eax),%edx
80100af6:	89 55 0c             	mov    %edx,0xc(%ebp)
80100af9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100afc:	88 10                	mov    %dl,(%eax)
    --n;
80100afe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b02:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b06:	74 0b                	je     80100b13 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b0c:	7f 98                	jg     80100aa6 <consoleread+0x79>
80100b0e:	eb 04                	jmp    80100b14 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b10:	90                   	nop
80100b11:	eb 01                	jmp    80100b14 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b13:	90                   	nop
  }
  release(&cons.lock);
80100b14:	83 ec 0c             	sub    $0xc,%esp
80100b17:	68 00 d6 10 80       	push   $0x8010d600
80100b1c:	e8 2f 5e 00 00       	call   80106950 <release>
80100b21:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b24:	83 ec 0c             	sub    $0xc,%esp
80100b27:	ff 75 08             	pushl  0x8(%ebp)
80100b2a:	e8 b4 0f 00 00       	call   80101ae3 <ilock>
80100b2f:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b32:	8b 45 10             	mov    0x10(%ebp),%eax
80100b35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b38:	29 c2                	sub    %eax,%edx
80100b3a:	89 d0                	mov    %edx,%eax
}
80100b3c:	c9                   	leave  
80100b3d:	c3                   	ret    

80100b3e <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b3e:	55                   	push   %ebp
80100b3f:	89 e5                	mov    %esp,%ebp
80100b41:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b44:	83 ec 0c             	sub    $0xc,%esp
80100b47:	ff 75 08             	pushl  0x8(%ebp)
80100b4a:	e8 1a 11 00 00       	call   80101c69 <iunlock>
80100b4f:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	68 00 d6 10 80       	push   $0x8010d600
80100b5a:	e8 8a 5d 00 00       	call   801068e9 <acquire>
80100b5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b69:	eb 21                	jmp    80100b8c <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b71:	01 d0                	add    %edx,%eax
80100b73:	0f b6 00             	movzbl (%eax),%eax
80100b76:	0f be c0             	movsbl %al,%eax
80100b79:	0f b6 c0             	movzbl %al,%eax
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	50                   	push   %eax
80100b80:	e8 0d fc ff ff       	call   80100792 <consputc>
80100b85:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b92:	7c d7                	jl     80100b6b <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b94:	83 ec 0c             	sub    $0xc,%esp
80100b97:	68 00 d6 10 80       	push   $0x8010d600
80100b9c:	e8 af 5d 00 00       	call   80106950 <release>
80100ba1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ba4:	83 ec 0c             	sub    $0xc,%esp
80100ba7:	ff 75 08             	pushl  0x8(%ebp)
80100baa:	e8 34 0f 00 00       	call   80101ae3 <ilock>
80100baf:	83 c4 10             	add    $0x10,%esp

  return n;
80100bb2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bb5:	c9                   	leave  
80100bb6:	c3                   	ret    

80100bb7 <consoleinit>:

void
consoleinit(void)
{
80100bb7:	55                   	push   %ebp
80100bb8:	89 e5                	mov    %esp,%ebp
80100bba:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bbd:	83 ec 08             	sub    $0x8,%esp
80100bc0:	68 3e a1 10 80       	push   $0x8010a13e
80100bc5:	68 00 d6 10 80       	push   $0x8010d600
80100bca:	e8 f8 5c 00 00       	call   801068c7 <initlock>
80100bcf:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bd2:	c7 05 0c 32 11 80 3e 	movl   $0x80100b3e,0x8011320c
80100bd9:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bdc:	c7 05 08 32 11 80 2d 	movl   $0x80100a2d,0x80113208
80100be3:	0a 10 80 
  cons.locking = 1;
80100be6:	c7 05 34 d6 10 80 01 	movl   $0x1,0x8010d634
80100bed:	00 00 00 

  picenable(IRQ_KBD);
80100bf0:	83 ec 0c             	sub    $0xc,%esp
80100bf3:	6a 01                	push   $0x1
80100bf5:	e8 74 36 00 00       	call   8010426e <picenable>
80100bfa:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100bfd:	83 ec 08             	sub    $0x8,%esp
80100c00:	6a 00                	push   $0x0
80100c02:	6a 01                	push   $0x1
80100c04:	e8 14 22 00 00       	call   80102e1d <ioapicenable>
80100c09:	83 c4 10             	add    $0x10,%esp
}
80100c0c:	90                   	nop
80100c0d:	c9                   	leave  
80100c0e:	c3                   	ret    

80100c0f <exec>:
#include "stat.h"
#endif

int
exec(char *path, char **argv)
{
80100c0f:	55                   	push   %ebp
80100c10:	89 e5                	mov    %esp,%ebp
80100c12:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c18:	e8 73 2c 00 00       	call   80103890 <begin_op>
  if((ip = namei(path)) == 0){
80100c1d:	83 ec 0c             	sub    $0xc,%esp
80100c20:	ff 75 08             	pushl  0x8(%ebp)
80100c23:	e8 c9 1a 00 00       	call   801026f1 <namei>
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c32:	75 0f                	jne    80100c43 <exec+0x34>
    end_op();
80100c34:	e8 e3 2c 00 00       	call   8010391c <end_op>
    return -1;
80100c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c3e:	e9 65 04 00 00       	jmp    801010a8 <exec+0x499>
  }
  ilock(ip);
80100c43:	83 ec 0c             	sub    $0xc,%esp
80100c46:	ff 75 d8             	pushl  -0x28(%ebp)
80100c49:	e8 95 0e 00 00       	call   80101ae3 <ilock>
80100c4e:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c51:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

#ifdef CS333_P5
  struct stat obj;
  int flag = 0;
80100c58:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  stati(ip,&obj);
80100c5f:	83 ec 08             	sub    $0x8,%esp
80100c62:	8d 85 cc fe ff ff    	lea    -0x134(%ebp),%eax
80100c68:	50                   	push   %eax
80100c69:	ff 75 d8             	pushl  -0x28(%ebp)
80100c6c:	e8 c2 13 00 00       	call   80102033 <stati>
80100c71:	83 c4 10             	add    $0x10,%esp
  if(obj.uid == proc->uid)
80100c74:	0f b7 85 e0 fe ff ff 	movzwl -0x120(%ebp),%eax
80100c7b:	0f b7 d0             	movzwl %ax,%edx
80100c7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c84:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80100c8a:	39 c2                	cmp    %eax,%edx
80100c8c:	75 15                	jne    80100ca3 <exec+0x94>
      flag = obj.mode.flags.u_x;
80100c8e:	0f b6 85 e4 fe ff ff 	movzbl -0x11c(%ebp),%eax
80100c95:	c0 e8 06             	shr    $0x6,%al
80100c98:	83 e0 01             	and    $0x1,%eax
80100c9b:	0f b6 c0             	movzbl %al,%eax
80100c9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
80100ca1:	eb 3f                	jmp    80100ce2 <exec+0xd3>
  else if(obj.gid == proc->gid)
80100ca3:	0f b7 85 e2 fe ff ff 	movzwl -0x11e(%ebp),%eax
80100caa:	0f b7 d0             	movzwl %ax,%edx
80100cad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cb3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100cb9:	39 c2                	cmp    %eax,%edx
80100cbb:	75 15                	jne    80100cd2 <exec+0xc3>
      flag = obj.mode.flags.g_x;
80100cbd:	0f b6 85 e4 fe ff ff 	movzbl -0x11c(%ebp),%eax
80100cc4:	c0 e8 03             	shr    $0x3,%al
80100cc7:	83 e0 01             	and    $0x1,%eax
80100cca:	0f b6 c0             	movzbl %al,%eax
80100ccd:	89 45 d0             	mov    %eax,-0x30(%ebp)
80100cd0:	eb 10                	jmp    80100ce2 <exec+0xd3>
  else
      flag = obj.mode.flags.o_x;
80100cd2:	0f b6 85 e4 fe ff ff 	movzbl -0x11c(%ebp),%eax
80100cd9:	83 e0 01             	and    $0x1,%eax
80100cdc:	0f b6 c0             	movzbl %al,%eax
80100cdf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  if(flag == 0)
80100ce2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80100ce6:	0f 84 68 03 00 00    	je     80101054 <exec+0x445>
      goto bad;
#endif
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100cec:	6a 34                	push   $0x34
80100cee:	6a 00                	push   $0x0
80100cf0:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cf6:	50                   	push   %eax
80100cf7:	ff 75 d8             	pushl  -0x28(%ebp)
80100cfa:	e8 a2 13 00 00       	call   801020a1 <readi>
80100cff:	83 c4 10             	add    $0x10,%esp
80100d02:	83 f8 33             	cmp    $0x33,%eax
80100d05:	0f 86 4c 03 00 00    	jbe    80101057 <exec+0x448>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100d0b:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100d11:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d16:	0f 85 3e 03 00 00    	jne    8010105a <exec+0x44b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d1c:	e8 9a 8b 00 00       	call   801098bb <setupkvm>
80100d21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d24:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d28:	0f 84 2f 03 00 00    	je     8010105d <exec+0x44e>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d2e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d35:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d3c:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100d42:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d45:	e9 ab 00 00 00       	jmp    80100df5 <exec+0x1e6>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d4d:	6a 20                	push   $0x20
80100d4f:	50                   	push   %eax
80100d50:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d56:	50                   	push   %eax
80100d57:	ff 75 d8             	pushl  -0x28(%ebp)
80100d5a:	e8 42 13 00 00       	call   801020a1 <readi>
80100d5f:	83 c4 10             	add    $0x10,%esp
80100d62:	83 f8 20             	cmp    $0x20,%eax
80100d65:	0f 85 f5 02 00 00    	jne    80101060 <exec+0x451>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d6b:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d71:	83 f8 01             	cmp    $0x1,%eax
80100d74:	75 71                	jne    80100de7 <exec+0x1d8>
      continue;
    if(ph.memsz < ph.filesz)
80100d76:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d7c:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d82:	39 c2                	cmp    %eax,%edx
80100d84:	0f 82 d9 02 00 00    	jb     80101063 <exec+0x454>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d8a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d90:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d96:	01 d0                	add    %edx,%eax
80100d98:	83 ec 04             	sub    $0x4,%esp
80100d9b:	50                   	push   %eax
80100d9c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d9f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da2:	e8 bb 8e 00 00       	call   80109c62 <allocuvm>
80100da7:	83 c4 10             	add    $0x10,%esp
80100daa:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100db1:	0f 84 af 02 00 00    	je     80101066 <exec+0x457>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100db7:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100dbd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100dc3:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100dc9:	83 ec 0c             	sub    $0xc,%esp
80100dcc:	52                   	push   %edx
80100dcd:	50                   	push   %eax
80100dce:	ff 75 d8             	pushl  -0x28(%ebp)
80100dd1:	51                   	push   %ecx
80100dd2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd5:	e8 b1 8d 00 00       	call   80109b8b <loaduvm>
80100dda:	83 c4 20             	add    $0x20,%esp
80100ddd:	85 c0                	test   %eax,%eax
80100ddf:	0f 88 84 02 00 00    	js     80101069 <exec+0x45a>
80100de5:	eb 01                	jmp    80100de8 <exec+0x1d9>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100de7:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100de8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100def:	83 c0 20             	add    $0x20,%eax
80100df2:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100df5:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100dfc:	0f b7 c0             	movzwl %ax,%eax
80100dff:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e02:	0f 8f 42 ff ff ff    	jg     80100d4a <exec+0x13b>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	ff 75 d8             	pushl  -0x28(%ebp)
80100e0e:	e8 b8 0f 00 00       	call   80101dcb <iunlockput>
80100e13:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e16:	e8 01 2b 00 00       	call   8010391c <end_op>
  ip = 0;
80100e1b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e25:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e35:	05 00 20 00 00       	add    $0x2000,%eax
80100e3a:	83 ec 04             	sub    $0x4,%esp
80100e3d:	50                   	push   %eax
80100e3e:	ff 75 e0             	pushl  -0x20(%ebp)
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 19 8e 00 00       	call   80109c62 <allocuvm>
80100e49:	83 c4 10             	add    $0x10,%esp
80100e4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e4f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e53:	0f 84 13 02 00 00    	je     8010106c <exec+0x45d>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5c:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e61:	83 ec 08             	sub    $0x8,%esp
80100e64:	50                   	push   %eax
80100e65:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e68:	e8 1b 90 00 00       	call   80109e88 <clearpteu>
80100e6d:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e73:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e76:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e7d:	e9 96 00 00 00       	jmp    80100f18 <exec+0x309>
    if(argc >= MAXARG)
80100e82:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e86:	0f 87 e3 01 00 00    	ja     8010106f <exec+0x460>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e99:	01 d0                	add    %edx,%eax
80100e9b:	8b 00                	mov    (%eax),%eax
80100e9d:	83 ec 0c             	sub    $0xc,%esp
80100ea0:	50                   	push   %eax
80100ea1:	e8 f3 5e 00 00       	call   80106d99 <strlen>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	89 c2                	mov    %eax,%edx
80100eab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eae:	29 d0                	sub    %edx,%eax
80100eb0:	83 e8 01             	sub    $0x1,%eax
80100eb3:	83 e0 fc             	and    $0xfffffffc,%eax
80100eb6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec6:	01 d0                	add    %edx,%eax
80100ec8:	8b 00                	mov    (%eax),%eax
80100eca:	83 ec 0c             	sub    $0xc,%esp
80100ecd:	50                   	push   %eax
80100ece:	e8 c6 5e 00 00       	call   80106d99 <strlen>
80100ed3:	83 c4 10             	add    $0x10,%esp
80100ed6:	83 c0 01             	add    $0x1,%eax
80100ed9:	89 c1                	mov    %eax,%ecx
80100edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ede:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee8:	01 d0                	add    %edx,%eax
80100eea:	8b 00                	mov    (%eax),%eax
80100eec:	51                   	push   %ecx
80100eed:	50                   	push   %eax
80100eee:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ef4:	e8 46 91 00 00       	call   8010a03f <copyout>
80100ef9:	83 c4 10             	add    $0x10,%esp
80100efc:	85 c0                	test   %eax,%eax
80100efe:	0f 88 6e 01 00 00    	js     80101072 <exec+0x463>
      goto bad;
    ustack[3+argc] = sp;
80100f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f07:	8d 50 03             	lea    0x3(%eax),%edx
80100f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f0d:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f14:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f25:	01 d0                	add    %edx,%eax
80100f27:	8b 00                	mov    (%eax),%eax
80100f29:	85 c0                	test   %eax,%eax
80100f2b:	0f 85 51 ff ff ff    	jne    80100e82 <exec+0x273>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f34:	83 c0 03             	add    $0x3,%eax
80100f37:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f3e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f42:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f49:	ff ff ff 
  ustack[1] = argc;
80100f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4f:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f58:	83 c0 01             	add    $0x1,%eax
80100f5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f65:	29 d0                	sub    %edx,%eax
80100f67:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f70:	83 c0 04             	add    $0x4,%eax
80100f73:	c1 e0 02             	shl    $0x2,%eax
80100f76:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7c:	83 c0 04             	add    $0x4,%eax
80100f7f:	c1 e0 02             	shl    $0x2,%eax
80100f82:	50                   	push   %eax
80100f83:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f89:	50                   	push   %eax
80100f8a:	ff 75 dc             	pushl  -0x24(%ebp)
80100f8d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f90:	e8 aa 90 00 00       	call   8010a03f <copyout>
80100f95:	83 c4 10             	add    $0x10,%esp
80100f98:	85 c0                	test   %eax,%eax
80100f9a:	0f 88 d5 00 00 00    	js     80101075 <exec+0x466>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fac:	eb 17                	jmp    80100fc5 <exec+0x3b6>
    if(*s == '/')
80100fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb1:	0f b6 00             	movzbl (%eax),%eax
80100fb4:	3c 2f                	cmp    $0x2f,%al
80100fb6:	75 09                	jne    80100fc1 <exec+0x3b2>
      last = s+1;
80100fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbb:	83 c0 01             	add    $0x1,%eax
80100fbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fc1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc8:	0f b6 00             	movzbl (%eax),%eax
80100fcb:	84 c0                	test   %al,%al
80100fcd:	75 df                	jne    80100fae <exec+0x39f>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100fcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fd5:	83 c0 6c             	add    $0x6c,%eax
80100fd8:	83 ec 04             	sub    $0x4,%esp
80100fdb:	6a 10                	push   $0x10
80100fdd:	ff 75 f0             	pushl  -0x10(%ebp)
80100fe0:	50                   	push   %eax
80100fe1:	e8 69 5d 00 00       	call   80106d4f <safestrcpy>
80100fe6:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_p5
  if(stuff.mode.flags.setuid == 1)
      proc->uid = stuff.uid;
#endif
  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100fe9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fef:	8b 40 04             	mov    0x4(%eax),%eax
80100ff2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
80100ff5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ffb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ffe:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101001:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101007:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010100a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
8010100c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101012:	8b 40 18             	mov    0x18(%eax),%eax
80101015:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
8010101b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
8010101e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101024:	8b 40 18             	mov    0x18(%eax),%eax
80101027:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010102a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
8010102d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	50                   	push   %eax
80101037:	e8 66 89 00 00       	call   801099a2 <switchuvm>
8010103c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
8010103f:	83 ec 0c             	sub    $0xc,%esp
80101042:	ff 75 cc             	pushl  -0x34(%ebp)
80101045:	e8 9e 8d 00 00       	call   80109de8 <freevm>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
80101052:	eb 54                	jmp    801010a8 <exec+0x499>
  else if(obj.gid == proc->gid)
      flag = obj.mode.flags.g_x;
  else
      flag = obj.mode.flags.o_x;
  if(flag == 0)
      goto bad;
80101054:	90                   	nop
80101055:	eb 1f                	jmp    80101076 <exec+0x467>
#endif
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101057:	90                   	nop
80101058:	eb 1c                	jmp    80101076 <exec+0x467>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010105a:	90                   	nop
8010105b:	eb 19                	jmp    80101076 <exec+0x467>

  if((pgdir = setupkvm()) == 0)
    goto bad;
8010105d:	90                   	nop
8010105e:	eb 16                	jmp    80101076 <exec+0x467>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101060:	90                   	nop
80101061:	eb 13                	jmp    80101076 <exec+0x467>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101063:	90                   	nop
80101064:	eb 10                	jmp    80101076 <exec+0x467>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101066:	90                   	nop
80101067:	eb 0d                	jmp    80101076 <exec+0x467>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101069:	90                   	nop
8010106a:	eb 0a                	jmp    80101076 <exec+0x467>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010106c:	90                   	nop
8010106d:	eb 07                	jmp    80101076 <exec+0x467>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010106f:	90                   	nop
80101070:	eb 04                	jmp    80101076 <exec+0x467>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101072:	90                   	nop
80101073:	eb 01                	jmp    80101076 <exec+0x467>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101075:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101076:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010107a:	74 0e                	je     8010108a <exec+0x47b>
    freevm(pgdir);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101082:	e8 61 8d 00 00       	call   80109de8 <freevm>
80101087:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010108a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010108e:	74 13                	je     801010a3 <exec+0x494>
    iunlockput(ip);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	ff 75 d8             	pushl  -0x28(%ebp)
80101096:	e8 30 0d 00 00       	call   80101dcb <iunlockput>
8010109b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010109e:	e8 79 28 00 00       	call   8010391c <end_op>
  }
  return -1;
801010a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010a8:	c9                   	leave  
801010a9:	c3                   	ret    

801010aa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010aa:	55                   	push   %ebp
801010ab:	89 e5                	mov    %esp,%ebp
801010ad:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010b0:	83 ec 08             	sub    $0x8,%esp
801010b3:	68 46 a1 10 80       	push   $0x8010a146
801010b8:	68 60 28 11 80       	push   $0x80112860
801010bd:	e8 05 58 00 00       	call   801068c7 <initlock>
801010c2:	83 c4 10             	add    $0x10,%esp
}
801010c5:	90                   	nop
801010c6:	c9                   	leave  
801010c7:	c3                   	ret    

801010c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010c8:	55                   	push   %ebp
801010c9:	89 e5                	mov    %esp,%ebp
801010cb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010ce:	83 ec 0c             	sub    $0xc,%esp
801010d1:	68 60 28 11 80       	push   $0x80112860
801010d6:	e8 0e 58 00 00       	call   801068e9 <acquire>
801010db:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010de:	c7 45 f4 94 28 11 80 	movl   $0x80112894,-0xc(%ebp)
801010e5:	eb 2d                	jmp    80101114 <filealloc+0x4c>
    if(f->ref == 0){
801010e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010ea:	8b 40 04             	mov    0x4(%eax),%eax
801010ed:	85 c0                	test   %eax,%eax
801010ef:	75 1f                	jne    80101110 <filealloc+0x48>
      f->ref = 1;
801010f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010fb:	83 ec 0c             	sub    $0xc,%esp
801010fe:	68 60 28 11 80       	push   $0x80112860
80101103:	e8 48 58 00 00       	call   80106950 <release>
80101108:	83 c4 10             	add    $0x10,%esp
      return f;
8010110b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110e:	eb 23                	jmp    80101133 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101110:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101114:	b8 f4 31 11 80       	mov    $0x801131f4,%eax
80101119:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010111c:	72 c9                	jb     801010e7 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010111e:	83 ec 0c             	sub    $0xc,%esp
80101121:	68 60 28 11 80       	push   $0x80112860
80101126:	e8 25 58 00 00       	call   80106950 <release>
8010112b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010112e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101133:	c9                   	leave  
80101134:	c3                   	ret    

80101135 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101135:	55                   	push   %ebp
80101136:	89 e5                	mov    %esp,%ebp
80101138:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010113b:	83 ec 0c             	sub    $0xc,%esp
8010113e:	68 60 28 11 80       	push   $0x80112860
80101143:	e8 a1 57 00 00       	call   801068e9 <acquire>
80101148:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010114b:	8b 45 08             	mov    0x8(%ebp),%eax
8010114e:	8b 40 04             	mov    0x4(%eax),%eax
80101151:	85 c0                	test   %eax,%eax
80101153:	7f 0d                	jg     80101162 <filedup+0x2d>
    panic("filedup");
80101155:	83 ec 0c             	sub    $0xc,%esp
80101158:	68 4d a1 10 80       	push   $0x8010a14d
8010115d:	e8 04 f4 ff ff       	call   80100566 <panic>
  f->ref++;
80101162:	8b 45 08             	mov    0x8(%ebp),%eax
80101165:	8b 40 04             	mov    0x4(%eax),%eax
80101168:	8d 50 01             	lea    0x1(%eax),%edx
8010116b:	8b 45 08             	mov    0x8(%ebp),%eax
8010116e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	68 60 28 11 80       	push   $0x80112860
80101179:	e8 d2 57 00 00       	call   80106950 <release>
8010117e:	83 c4 10             	add    $0x10,%esp
  return f;
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101184:	c9                   	leave  
80101185:	c3                   	ret    

80101186 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101186:	55                   	push   %ebp
80101187:	89 e5                	mov    %esp,%ebp
80101189:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010118c:	83 ec 0c             	sub    $0xc,%esp
8010118f:	68 60 28 11 80       	push   $0x80112860
80101194:	e8 50 57 00 00       	call   801068e9 <acquire>
80101199:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010119c:	8b 45 08             	mov    0x8(%ebp),%eax
8010119f:	8b 40 04             	mov    0x4(%eax),%eax
801011a2:	85 c0                	test   %eax,%eax
801011a4:	7f 0d                	jg     801011b3 <fileclose+0x2d>
    panic("fileclose");
801011a6:	83 ec 0c             	sub    $0xc,%esp
801011a9:	68 55 a1 10 80       	push   $0x8010a155
801011ae:	e8 b3 f3 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801011b3:	8b 45 08             	mov    0x8(%ebp),%eax
801011b6:	8b 40 04             	mov    0x4(%eax),%eax
801011b9:	8d 50 ff             	lea    -0x1(%eax),%edx
801011bc:	8b 45 08             	mov    0x8(%ebp),%eax
801011bf:	89 50 04             	mov    %edx,0x4(%eax)
801011c2:	8b 45 08             	mov    0x8(%ebp),%eax
801011c5:	8b 40 04             	mov    0x4(%eax),%eax
801011c8:	85 c0                	test   %eax,%eax
801011ca:	7e 15                	jle    801011e1 <fileclose+0x5b>
    release(&ftable.lock);
801011cc:	83 ec 0c             	sub    $0xc,%esp
801011cf:	68 60 28 11 80       	push   $0x80112860
801011d4:	e8 77 57 00 00       	call   80106950 <release>
801011d9:	83 c4 10             	add    $0x10,%esp
801011dc:	e9 8b 00 00 00       	jmp    8010126c <fileclose+0xe6>
    return;
  }
  ff = *f;
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 10                	mov    (%eax),%edx
801011e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011e9:	8b 50 04             	mov    0x4(%eax),%edx
801011ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011ef:	8b 50 08             	mov    0x8(%eax),%edx
801011f2:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011f5:	8b 50 0c             	mov    0xc(%eax),%edx
801011f8:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011fb:	8b 50 10             	mov    0x10(%eax),%edx
801011fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101201:	8b 40 14             	mov    0x14(%eax),%eax
80101204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010121a:	83 ec 0c             	sub    $0xc,%esp
8010121d:	68 60 28 11 80       	push   $0x80112860
80101222:	e8 29 57 00 00       	call   80106950 <release>
80101227:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010122a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010122d:	83 f8 01             	cmp    $0x1,%eax
80101230:	75 19                	jne    8010124b <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101232:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101236:	0f be d0             	movsbl %al,%edx
80101239:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010123c:	83 ec 08             	sub    $0x8,%esp
8010123f:	52                   	push   %edx
80101240:	50                   	push   %eax
80101241:	e8 91 32 00 00       	call   801044d7 <pipeclose>
80101246:	83 c4 10             	add    $0x10,%esp
80101249:	eb 21                	jmp    8010126c <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010124b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010124e:	83 f8 02             	cmp    $0x2,%eax
80101251:	75 19                	jne    8010126c <fileclose+0xe6>
    begin_op();
80101253:	e8 38 26 00 00       	call   80103890 <begin_op>
    iput(ff.ip);
80101258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010125b:	83 ec 0c             	sub    $0xc,%esp
8010125e:	50                   	push   %eax
8010125f:	e8 77 0a 00 00       	call   80101cdb <iput>
80101264:	83 c4 10             	add    $0x10,%esp
    end_op();
80101267:	e8 b0 26 00 00       	call   8010391c <end_op>
  }
}
8010126c:	c9                   	leave  
8010126d:	c3                   	ret    

8010126e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010126e:	55                   	push   %ebp
8010126f:	89 e5                	mov    %esp,%ebp
80101271:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	8b 00                	mov    (%eax),%eax
80101279:	83 f8 02             	cmp    $0x2,%eax
8010127c:	75 40                	jne    801012be <filestat+0x50>
    ilock(f->ip);
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 40 10             	mov    0x10(%eax),%eax
80101284:	83 ec 0c             	sub    $0xc,%esp
80101287:	50                   	push   %eax
80101288:	e8 56 08 00 00       	call   80101ae3 <ilock>
8010128d:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101290:	8b 45 08             	mov    0x8(%ebp),%eax
80101293:	8b 40 10             	mov    0x10(%eax),%eax
80101296:	83 ec 08             	sub    $0x8,%esp
80101299:	ff 75 0c             	pushl  0xc(%ebp)
8010129c:	50                   	push   %eax
8010129d:	e8 91 0d 00 00       	call   80102033 <stati>
801012a2:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	83 ec 0c             	sub    $0xc,%esp
801012ae:	50                   	push   %eax
801012af:	e8 b5 09 00 00       	call   80101c69 <iunlock>
801012b4:	83 c4 10             	add    $0x10,%esp
    return 0;
801012b7:	b8 00 00 00 00       	mov    $0x0,%eax
801012bc:	eb 05                	jmp    801012c3 <filestat+0x55>
  }
  return -1;
801012be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012c3:	c9                   	leave  
801012c4:	c3                   	ret    

801012c5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012c5:	55                   	push   %ebp
801012c6:	89 e5                	mov    %esp,%ebp
801012c8:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012cb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ce:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012d2:	84 c0                	test   %al,%al
801012d4:	75 0a                	jne    801012e0 <fileread+0x1b>
    return -1;
801012d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012db:	e9 9b 00 00 00       	jmp    8010137b <fileread+0xb6>
  if(f->type == FD_PIPE)
801012e0:	8b 45 08             	mov    0x8(%ebp),%eax
801012e3:	8b 00                	mov    (%eax),%eax
801012e5:	83 f8 01             	cmp    $0x1,%eax
801012e8:	75 1a                	jne    80101304 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801012ea:	8b 45 08             	mov    0x8(%ebp),%eax
801012ed:	8b 40 0c             	mov    0xc(%eax),%eax
801012f0:	83 ec 04             	sub    $0x4,%esp
801012f3:	ff 75 10             	pushl  0x10(%ebp)
801012f6:	ff 75 0c             	pushl  0xc(%ebp)
801012f9:	50                   	push   %eax
801012fa:	e8 80 33 00 00       	call   8010467f <piperead>
801012ff:	83 c4 10             	add    $0x10,%esp
80101302:	eb 77                	jmp    8010137b <fileread+0xb6>
  if(f->type == FD_INODE){
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	8b 00                	mov    (%eax),%eax
80101309:	83 f8 02             	cmp    $0x2,%eax
8010130c:	75 60                	jne    8010136e <fileread+0xa9>
    ilock(f->ip);
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 40 10             	mov    0x10(%eax),%eax
80101314:	83 ec 0c             	sub    $0xc,%esp
80101317:	50                   	push   %eax
80101318:	e8 c6 07 00 00       	call   80101ae3 <ilock>
8010131d:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101320:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101323:	8b 45 08             	mov    0x8(%ebp),%eax
80101326:	8b 50 14             	mov    0x14(%eax),%edx
80101329:	8b 45 08             	mov    0x8(%ebp),%eax
8010132c:	8b 40 10             	mov    0x10(%eax),%eax
8010132f:	51                   	push   %ecx
80101330:	52                   	push   %edx
80101331:	ff 75 0c             	pushl  0xc(%ebp)
80101334:	50                   	push   %eax
80101335:	e8 67 0d 00 00       	call   801020a1 <readi>
8010133a:	83 c4 10             	add    $0x10,%esp
8010133d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101340:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101344:	7e 11                	jle    80101357 <fileread+0x92>
      f->off += r;
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 50 14             	mov    0x14(%eax),%edx
8010134c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134f:	01 c2                	add    %eax,%edx
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	8b 40 10             	mov    0x10(%eax),%eax
8010135d:	83 ec 0c             	sub    $0xc,%esp
80101360:	50                   	push   %eax
80101361:	e8 03 09 00 00       	call   80101c69 <iunlock>
80101366:	83 c4 10             	add    $0x10,%esp
    return r;
80101369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136c:	eb 0d                	jmp    8010137b <fileread+0xb6>
  }
  panic("fileread");
8010136e:	83 ec 0c             	sub    $0xc,%esp
80101371:	68 5f a1 10 80       	push   $0x8010a15f
80101376:	e8 eb f1 ff ff       	call   80100566 <panic>
}
8010137b:	c9                   	leave  
8010137c:	c3                   	ret    

8010137d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010137d:	55                   	push   %ebp
8010137e:	89 e5                	mov    %esp,%ebp
80101380:	53                   	push   %ebx
80101381:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101384:	8b 45 08             	mov    0x8(%ebp),%eax
80101387:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010138b:	84 c0                	test   %al,%al
8010138d:	75 0a                	jne    80101399 <filewrite+0x1c>
    return -1;
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	e9 1b 01 00 00       	jmp    801014b4 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 00                	mov    (%eax),%eax
8010139e:	83 f8 01             	cmp    $0x1,%eax
801013a1:	75 1d                	jne    801013c0 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 0c             	mov    0xc(%eax),%eax
801013a9:	83 ec 04             	sub    $0x4,%esp
801013ac:	ff 75 10             	pushl  0x10(%ebp)
801013af:	ff 75 0c             	pushl  0xc(%ebp)
801013b2:	50                   	push   %eax
801013b3:	e8 c9 31 00 00       	call   80104581 <pipewrite>
801013b8:	83 c4 10             	add    $0x10,%esp
801013bb:	e9 f4 00 00 00       	jmp    801014b4 <filewrite+0x137>
  if(f->type == FD_INODE){
801013c0:	8b 45 08             	mov    0x8(%ebp),%eax
801013c3:	8b 00                	mov    (%eax),%eax
801013c5:	83 f8 02             	cmp    $0x2,%eax
801013c8:	0f 85 d9 00 00 00    	jne    801014a7 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013ce:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013dc:	e9 a3 00 00 00       	jmp    80101484 <filewrite+0x107>
      int n1 = n - i;
801013e1:	8b 45 10             	mov    0x10(%ebp),%eax
801013e4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013f0:	7e 06                	jle    801013f8 <filewrite+0x7b>
        n1 = max;
801013f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013f8:	e8 93 24 00 00       	call   80103890 <begin_op>
      ilock(f->ip);
801013fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101400:	8b 40 10             	mov    0x10(%eax),%eax
80101403:	83 ec 0c             	sub    $0xc,%esp
80101406:	50                   	push   %eax
80101407:	e8 d7 06 00 00       	call   80101ae3 <ilock>
8010140c:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010140f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 50 14             	mov    0x14(%eax),%edx
80101418:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010141b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010141e:	01 c3                	add    %eax,%ebx
80101420:	8b 45 08             	mov    0x8(%ebp),%eax
80101423:	8b 40 10             	mov    0x10(%eax),%eax
80101426:	51                   	push   %ecx
80101427:	52                   	push   %edx
80101428:	53                   	push   %ebx
80101429:	50                   	push   %eax
8010142a:	e8 c9 0d 00 00       	call   801021f8 <writei>
8010142f:	83 c4 10             	add    $0x10,%esp
80101432:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101435:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101439:	7e 11                	jle    8010144c <filewrite+0xcf>
        f->off += r;
8010143b:	8b 45 08             	mov    0x8(%ebp),%eax
8010143e:	8b 50 14             	mov    0x14(%eax),%edx
80101441:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101444:	01 c2                	add    %eax,%edx
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010144c:	8b 45 08             	mov    0x8(%ebp),%eax
8010144f:	8b 40 10             	mov    0x10(%eax),%eax
80101452:	83 ec 0c             	sub    $0xc,%esp
80101455:	50                   	push   %eax
80101456:	e8 0e 08 00 00       	call   80101c69 <iunlock>
8010145b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010145e:	e8 b9 24 00 00       	call   8010391c <end_op>

      if(r < 0)
80101463:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101467:	78 29                	js     80101492 <filewrite+0x115>
        break;
      if(r != n1)
80101469:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010146c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010146f:	74 0d                	je     8010147e <filewrite+0x101>
        panic("short filewrite");
80101471:	83 ec 0c             	sub    $0xc,%esp
80101474:	68 68 a1 10 80       	push   $0x8010a168
80101479:	e8 e8 f0 ff ff       	call   80100566 <panic>
      i += r;
8010147e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101481:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101487:	3b 45 10             	cmp    0x10(%ebp),%eax
8010148a:	0f 8c 51 ff ff ff    	jl     801013e1 <filewrite+0x64>
80101490:	eb 01                	jmp    80101493 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101492:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101496:	3b 45 10             	cmp    0x10(%ebp),%eax
80101499:	75 05                	jne    801014a0 <filewrite+0x123>
8010149b:	8b 45 10             	mov    0x10(%ebp),%eax
8010149e:	eb 14                	jmp    801014b4 <filewrite+0x137>
801014a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014a5:	eb 0d                	jmp    801014b4 <filewrite+0x137>
  }
  panic("filewrite");
801014a7:	83 ec 0c             	sub    $0xc,%esp
801014aa:	68 78 a1 10 80       	push   $0x8010a178
801014af:	e8 b2 f0 ff ff       	call   80100566 <panic>
}
801014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014b7:	c9                   	leave  
801014b8:	c3                   	ret    

801014b9 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014b9:	55                   	push   %ebp
801014ba:	89 e5                	mov    %esp,%ebp
801014bc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801014bf:	8b 45 08             	mov    0x8(%ebp),%eax
801014c2:	83 ec 08             	sub    $0x8,%esp
801014c5:	6a 01                	push   $0x1
801014c7:	50                   	push   %eax
801014c8:	e8 e9 ec ff ff       	call   801001b6 <bread>
801014cd:	83 c4 10             	add    $0x10,%esp
801014d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d6:	83 c0 18             	add    $0x18,%eax
801014d9:	83 ec 04             	sub    $0x4,%esp
801014dc:	6a 1c                	push   $0x1c
801014de:	50                   	push   %eax
801014df:	ff 75 0c             	pushl  0xc(%ebp)
801014e2:	e8 24 57 00 00       	call   80106c0b <memmove>
801014e7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014ea:	83 ec 0c             	sub    $0xc,%esp
801014ed:	ff 75 f4             	pushl  -0xc(%ebp)
801014f0:	e8 39 ed ff ff       	call   8010022e <brelse>
801014f5:	83 c4 10             	add    $0x10,%esp
}
801014f8:	90                   	nop
801014f9:	c9                   	leave  
801014fa:	c3                   	ret    

801014fb <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014fb:	55                   	push   %ebp
801014fc:	89 e5                	mov    %esp,%ebp
801014fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101501:	8b 55 0c             	mov    0xc(%ebp),%edx
80101504:	8b 45 08             	mov    0x8(%ebp),%eax
80101507:	83 ec 08             	sub    $0x8,%esp
8010150a:	52                   	push   %edx
8010150b:	50                   	push   %eax
8010150c:	e8 a5 ec ff ff       	call   801001b6 <bread>
80101511:	83 c4 10             	add    $0x10,%esp
80101514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010151a:	83 c0 18             	add    $0x18,%eax
8010151d:	83 ec 04             	sub    $0x4,%esp
80101520:	68 00 02 00 00       	push   $0x200
80101525:	6a 00                	push   $0x0
80101527:	50                   	push   %eax
80101528:	e8 1f 56 00 00       	call   80106b4c <memset>
8010152d:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101530:	83 ec 0c             	sub    $0xc,%esp
80101533:	ff 75 f4             	pushl  -0xc(%ebp)
80101536:	e8 8d 25 00 00       	call   80103ac8 <log_write>
8010153b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010153e:	83 ec 0c             	sub    $0xc,%esp
80101541:	ff 75 f4             	pushl  -0xc(%ebp)
80101544:	e8 e5 ec ff ff       	call   8010022e <brelse>
80101549:	83 c4 10             	add    $0x10,%esp
}
8010154c:	90                   	nop
8010154d:	c9                   	leave  
8010154e:	c3                   	ret    

8010154f <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010154f:	55                   	push   %ebp
80101550:	89 e5                	mov    %esp,%ebp
80101552:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101555:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010155c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101563:	e9 13 01 00 00       	jmp    8010167b <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010156b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101571:	85 c0                	test   %eax,%eax
80101573:	0f 48 c2             	cmovs  %edx,%eax
80101576:	c1 f8 0c             	sar    $0xc,%eax
80101579:	89 c2                	mov    %eax,%edx
8010157b:	a1 78 32 11 80       	mov    0x80113278,%eax
80101580:	01 d0                	add    %edx,%eax
80101582:	83 ec 08             	sub    $0x8,%esp
80101585:	50                   	push   %eax
80101586:	ff 75 08             	pushl  0x8(%ebp)
80101589:	e8 28 ec ff ff       	call   801001b6 <bread>
8010158e:	83 c4 10             	add    $0x10,%esp
80101591:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101594:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010159b:	e9 a6 00 00 00       	jmp    80101646 <balloc+0xf7>
      m = 1 << (bi % 8);
801015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a3:	99                   	cltd   
801015a4:	c1 ea 1d             	shr    $0x1d,%edx
801015a7:	01 d0                	add    %edx,%eax
801015a9:	83 e0 07             	and    $0x7,%eax
801015ac:	29 d0                	sub    %edx,%eax
801015ae:	ba 01 00 00 00       	mov    $0x1,%edx
801015b3:	89 c1                	mov    %eax,%ecx
801015b5:	d3 e2                	shl    %cl,%edx
801015b7:	89 d0                	mov    %edx,%eax
801015b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bf:	8d 50 07             	lea    0x7(%eax),%edx
801015c2:	85 c0                	test   %eax,%eax
801015c4:	0f 48 c2             	cmovs  %edx,%eax
801015c7:	c1 f8 03             	sar    $0x3,%eax
801015ca:	89 c2                	mov    %eax,%edx
801015cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015cf:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015d4:	0f b6 c0             	movzbl %al,%eax
801015d7:	23 45 e8             	and    -0x18(%ebp),%eax
801015da:	85 c0                	test   %eax,%eax
801015dc:	75 64                	jne    80101642 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e1:	8d 50 07             	lea    0x7(%eax),%edx
801015e4:	85 c0                	test   %eax,%eax
801015e6:	0f 48 c2             	cmovs  %edx,%eax
801015e9:	c1 f8 03             	sar    $0x3,%eax
801015ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ef:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015f4:	89 d1                	mov    %edx,%ecx
801015f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015f9:	09 ca                	or     %ecx,%edx
801015fb:	89 d1                	mov    %edx,%ecx
801015fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101600:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101604:	83 ec 0c             	sub    $0xc,%esp
80101607:	ff 75 ec             	pushl  -0x14(%ebp)
8010160a:	e8 b9 24 00 00       	call   80103ac8 <log_write>
8010160f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101612:	83 ec 0c             	sub    $0xc,%esp
80101615:	ff 75 ec             	pushl  -0x14(%ebp)
80101618:	e8 11 ec ff ff       	call   8010022e <brelse>
8010161d:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101626:	01 c2                	add    %eax,%edx
80101628:	8b 45 08             	mov    0x8(%ebp),%eax
8010162b:	83 ec 08             	sub    $0x8,%esp
8010162e:	52                   	push   %edx
8010162f:	50                   	push   %eax
80101630:	e8 c6 fe ff ff       	call   801014fb <bzero>
80101635:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163e:	01 d0                	add    %edx,%eax
80101640:	eb 57                	jmp    80101699 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101642:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101646:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010164d:	7f 17                	jg     80101666 <balloc+0x117>
8010164f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101652:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101655:	01 d0                	add    %edx,%eax
80101657:	89 c2                	mov    %eax,%edx
80101659:	a1 60 32 11 80       	mov    0x80113260,%eax
8010165e:	39 c2                	cmp    %eax,%edx
80101660:	0f 82 3a ff ff ff    	jb     801015a0 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101666:	83 ec 0c             	sub    $0xc,%esp
80101669:	ff 75 ec             	pushl  -0x14(%ebp)
8010166c:	e8 bd eb ff ff       	call   8010022e <brelse>
80101671:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101674:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010167b:	8b 15 60 32 11 80    	mov    0x80113260,%edx
80101681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101684:	39 c2                	cmp    %eax,%edx
80101686:	0f 87 dc fe ff ff    	ja     80101568 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010168c:	83 ec 0c             	sub    $0xc,%esp
8010168f:	68 84 a1 10 80       	push   $0x8010a184
80101694:	e8 cd ee ff ff       	call   80100566 <panic>
}
80101699:	c9                   	leave  
8010169a:	c3                   	ret    

8010169b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010169b:	55                   	push   %ebp
8010169c:	89 e5                	mov    %esp,%ebp
8010169e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801016a1:	83 ec 08             	sub    $0x8,%esp
801016a4:	68 60 32 11 80       	push   $0x80113260
801016a9:	ff 75 08             	pushl  0x8(%ebp)
801016ac:	e8 08 fe ff ff       	call   801014b9 <readsb>
801016b1:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801016b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801016b7:	c1 e8 0c             	shr    $0xc,%eax
801016ba:	89 c2                	mov    %eax,%edx
801016bc:	a1 78 32 11 80       	mov    0x80113278,%eax
801016c1:	01 c2                	add    %eax,%edx
801016c3:	8b 45 08             	mov    0x8(%ebp),%eax
801016c6:	83 ec 08             	sub    $0x8,%esp
801016c9:	52                   	push   %edx
801016ca:	50                   	push   %eax
801016cb:	e8 e6 ea ff ff       	call   801001b6 <bread>
801016d0:	83 c4 10             	add    $0x10,%esp
801016d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801016d9:	25 ff 0f 00 00       	and    $0xfff,%eax
801016de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e4:	99                   	cltd   
801016e5:	c1 ea 1d             	shr    $0x1d,%edx
801016e8:	01 d0                	add    %edx,%eax
801016ea:	83 e0 07             	and    $0x7,%eax
801016ed:	29 d0                	sub    %edx,%eax
801016ef:	ba 01 00 00 00       	mov    $0x1,%edx
801016f4:	89 c1                	mov    %eax,%ecx
801016f6:	d3 e2                	shl    %cl,%edx
801016f8:	89 d0                	mov    %edx,%eax
801016fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101700:	8d 50 07             	lea    0x7(%eax),%edx
80101703:	85 c0                	test   %eax,%eax
80101705:	0f 48 c2             	cmovs  %edx,%eax
80101708:	c1 f8 03             	sar    $0x3,%eax
8010170b:	89 c2                	mov    %eax,%edx
8010170d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101710:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101715:	0f b6 c0             	movzbl %al,%eax
80101718:	23 45 ec             	and    -0x14(%ebp),%eax
8010171b:	85 c0                	test   %eax,%eax
8010171d:	75 0d                	jne    8010172c <bfree+0x91>
    panic("freeing free block");
8010171f:	83 ec 0c             	sub    $0xc,%esp
80101722:	68 9a a1 10 80       	push   $0x8010a19a
80101727:	e8 3a ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
8010172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010172f:	8d 50 07             	lea    0x7(%eax),%edx
80101732:	85 c0                	test   %eax,%eax
80101734:	0f 48 c2             	cmovs  %edx,%eax
80101737:	c1 f8 03             	sar    $0x3,%eax
8010173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010173d:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101742:	89 d1                	mov    %edx,%ecx
80101744:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101747:	f7 d2                	not    %edx
80101749:	21 ca                	and    %ecx,%edx
8010174b:	89 d1                	mov    %edx,%ecx
8010174d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101750:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101754:	83 ec 0c             	sub    $0xc,%esp
80101757:	ff 75 f4             	pushl  -0xc(%ebp)
8010175a:	e8 69 23 00 00       	call   80103ac8 <log_write>
8010175f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101762:	83 ec 0c             	sub    $0xc,%esp
80101765:	ff 75 f4             	pushl  -0xc(%ebp)
80101768:	e8 c1 ea ff ff       	call   8010022e <brelse>
8010176d:	83 c4 10             	add    $0x10,%esp
}
80101770:	90                   	nop
80101771:	c9                   	leave  
80101772:	c3                   	ret    

80101773 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101773:	55                   	push   %ebp
80101774:	89 e5                	mov    %esp,%ebp
80101776:	57                   	push   %edi
80101777:	56                   	push   %esi
80101778:	53                   	push   %ebx
80101779:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
8010177c:	83 ec 08             	sub    $0x8,%esp
8010177f:	68 ad a1 10 80       	push   $0x8010a1ad
80101784:	68 80 32 11 80       	push   $0x80113280
80101789:	e8 39 51 00 00       	call   801068c7 <initlock>
8010178e:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101791:	83 ec 08             	sub    $0x8,%esp
80101794:	68 60 32 11 80       	push   $0x80113260
80101799:	ff 75 08             	pushl  0x8(%ebp)
8010179c:	e8 18 fd ff ff       	call   801014b9 <readsb>
801017a1:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801017a4:	a1 78 32 11 80       	mov    0x80113278,%eax
801017a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801017ac:	8b 3d 74 32 11 80    	mov    0x80113274,%edi
801017b2:	8b 35 70 32 11 80    	mov    0x80113270,%esi
801017b8:	8b 1d 6c 32 11 80    	mov    0x8011326c,%ebx
801017be:	8b 0d 68 32 11 80    	mov    0x80113268,%ecx
801017c4:	8b 15 64 32 11 80    	mov    0x80113264,%edx
801017ca:	a1 60 32 11 80       	mov    0x80113260,%eax
801017cf:	ff 75 e4             	pushl  -0x1c(%ebp)
801017d2:	57                   	push   %edi
801017d3:	56                   	push   %esi
801017d4:	53                   	push   %ebx
801017d5:	51                   	push   %ecx
801017d6:	52                   	push   %edx
801017d7:	50                   	push   %eax
801017d8:	68 b4 a1 10 80       	push   $0x8010a1b4
801017dd:	e8 e4 eb ff ff       	call   801003c6 <cprintf>
801017e2:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801017e5:	90                   	nop
801017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017e9:	5b                   	pop    %ebx
801017ea:	5e                   	pop    %esi
801017eb:	5f                   	pop    %edi
801017ec:	5d                   	pop    %ebp
801017ed:	c3                   	ret    

801017ee <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801017ee:	55                   	push   %ebp
801017ef:	89 e5                	mov    %esp,%ebp
801017f1:	83 ec 28             	sub    $0x28,%esp
801017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801017f7:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017fb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101802:	e9 ba 00 00 00       	jmp    801018c1 <ialloc+0xd3>
    bp = bread(dev, IBLOCK(inum, sb));
80101807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180a:	c1 e8 03             	shr    $0x3,%eax
8010180d:	89 c2                	mov    %eax,%edx
8010180f:	a1 74 32 11 80       	mov    0x80113274,%eax
80101814:	01 d0                	add    %edx,%eax
80101816:	83 ec 08             	sub    $0x8,%esp
80101819:	50                   	push   %eax
8010181a:	ff 75 08             	pushl  0x8(%ebp)
8010181d:	e8 94 e9 ff ff       	call   801001b6 <bread>
80101822:	83 c4 10             	add    $0x10,%esp
80101825:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182b:	8d 50 18             	lea    0x18(%eax),%edx
8010182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101831:	83 e0 07             	and    $0x7,%eax
80101834:	c1 e0 06             	shl    $0x6,%eax
80101837:	01 d0                	add    %edx,%eax
80101839:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010183c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010183f:	0f b7 00             	movzwl (%eax),%eax
80101842:	66 85 c0             	test   %ax,%ax
80101845:	75 68                	jne    801018af <ialloc+0xc1>
      memset(dip, 0, sizeof(*dip));
80101847:	83 ec 04             	sub    $0x4,%esp
8010184a:	6a 40                	push   $0x40
8010184c:	6a 00                	push   $0x0
8010184e:	ff 75 ec             	pushl  -0x14(%ebp)
80101851:	e8 f6 52 00 00       	call   80106b4c <memset>
80101856:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010185c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101860:	66 89 10             	mov    %dx,(%eax)
#ifdef CS333_P5
      dip->uid = DEFAULT_UID;
80101863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101866:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
      dip->gid = DEFAULT_GID;
8010186c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010186f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
      dip->mode.asInt = DEFAULT_MODE;
80101875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101878:	c7 40 0c ed 01 00 00 	movl   $0x1ed,0xc(%eax)
#endif
      log_write(bp);   // mark it allocated on the disk
8010187f:	83 ec 0c             	sub    $0xc,%esp
80101882:	ff 75 f0             	pushl  -0x10(%ebp)
80101885:	e8 3e 22 00 00       	call   80103ac8 <log_write>
8010188a:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010188d:	83 ec 0c             	sub    $0xc,%esp
80101890:	ff 75 f0             	pushl  -0x10(%ebp)
80101893:	e8 96 e9 ff ff       	call   8010022e <brelse>
80101898:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010189b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189e:	83 ec 08             	sub    $0x8,%esp
801018a1:	50                   	push   %eax
801018a2:	ff 75 08             	pushl  0x8(%ebp)
801018a5:	e8 20 01 00 00       	call   801019ca <iget>
801018aa:	83 c4 10             	add    $0x10,%esp
801018ad:	eb 30                	jmp    801018df <ialloc+0xf1>
    }
    brelse(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f0             	pushl  -0x10(%ebp)
801018b5:	e8 74 e9 ff ff       	call   8010022e <brelse>
801018ba:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018c1:	8b 15 68 32 11 80    	mov    0x80113268,%edx
801018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ca:	39 c2                	cmp    %eax,%edx
801018cc:	0f 87 35 ff ff ff    	ja     80101807 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018d2:	83 ec 0c             	sub    $0xc,%esp
801018d5:	68 07 a2 10 80       	push   $0x8010a207
801018da:	e8 87 ec ff ff       	call   80100566 <panic>
}
801018df:	c9                   	leave  
801018e0:	c3                   	ret    

801018e1 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801018e1:	55                   	push   %ebp
801018e2:	89 e5                	mov    %esp,%ebp
801018e4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	8b 40 04             	mov    0x4(%eax),%eax
801018ed:	c1 e8 03             	shr    $0x3,%eax
801018f0:	89 c2                	mov    %eax,%edx
801018f2:	a1 74 32 11 80       	mov    0x80113274,%eax
801018f7:	01 c2                	add    %eax,%edx
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 00                	mov    (%eax),%eax
801018fe:	83 ec 08             	sub    $0x8,%esp
80101901:	52                   	push   %edx
80101902:	50                   	push   %eax
80101903:	e8 ae e8 ff ff       	call   801001b6 <bread>
80101908:	83 c4 10             	add    $0x10,%esp
8010190b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101911:	8d 50 18             	lea    0x18(%eax),%edx
80101914:	8b 45 08             	mov    0x8(%ebp),%eax
80101917:	8b 40 04             	mov    0x4(%eax),%eax
8010191a:	83 e0 07             	and    $0x7,%eax
8010191d:	c1 e0 06             	shl    $0x6,%eax
80101920:	01 d0                	add    %edx,%eax
80101922:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifdef CS333_P5
  dip->uid = ip->uid;
80101925:	8b 45 08             	mov    0x8(%ebp),%eax
80101928:	0f b7 50 18          	movzwl 0x18(%eax),%edx
8010192c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192f:	66 89 50 08          	mov    %dx,0x8(%eax)
  dip->gid = ip->gid;
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
8010193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193d:	66 89 50 0a          	mov    %dx,0xa(%eax)
  dip->mode.asInt = ip->mode.asInt;
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 50 1c             	mov    0x1c(%eax),%edx
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	89 50 0c             	mov    %edx,0xc(%eax)
#endif
  dip->type = ip->type;
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101957:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101964:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101972:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010197d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101980:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101984:	8b 45 08             	mov    0x8(%ebp),%eax
80101987:	8b 50 20             	mov    0x20(%eax),%edx
8010198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198d:	89 50 10             	mov    %edx,0x10(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101990:	8b 45 08             	mov    0x8(%ebp),%eax
80101993:	8d 50 24             	lea    0x24(%eax),%edx
80101996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101999:	83 c0 14             	add    $0x14,%eax
8010199c:	83 ec 04             	sub    $0x4,%esp
8010199f:	6a 2c                	push   $0x2c
801019a1:	52                   	push   %edx
801019a2:	50                   	push   %eax
801019a3:	e8 63 52 00 00       	call   80106c0b <memmove>
801019a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019ab:	83 ec 0c             	sub    $0xc,%esp
801019ae:	ff 75 f4             	pushl  -0xc(%ebp)
801019b1:	e8 12 21 00 00       	call   80103ac8 <log_write>
801019b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019b9:	83 ec 0c             	sub    $0xc,%esp
801019bc:	ff 75 f4             	pushl  -0xc(%ebp)
801019bf:	e8 6a e8 ff ff       	call   8010022e <brelse>
801019c4:	83 c4 10             	add    $0x10,%esp
}
801019c7:	90                   	nop
801019c8:	c9                   	leave  
801019c9:	c3                   	ret    

801019ca <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019ca:	55                   	push   %ebp
801019cb:	89 e5                	mov    %esp,%ebp
801019cd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 80 32 11 80       	push   $0x80113280
801019d8:	e8 0c 4f 00 00       	call   801068e9 <acquire>
801019dd:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019e7:	c7 45 f4 b4 32 11 80 	movl   $0x801132b4,-0xc(%ebp)
801019ee:	eb 5d                	jmp    80101a4d <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f3:	8b 40 08             	mov    0x8(%eax),%eax
801019f6:	85 c0                	test   %eax,%eax
801019f8:	7e 39                	jle    80101a33 <iget+0x69>
801019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fd:	8b 00                	mov    (%eax),%eax
801019ff:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a02:	75 2f                	jne    80101a33 <iget+0x69>
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 40 04             	mov    0x4(%eax),%eax
80101a0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a0d:	75 24                	jne    80101a33 <iget+0x69>
      ip->ref++;
80101a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a12:	8b 40 08             	mov    0x8(%eax),%eax
80101a15:	8d 50 01             	lea    0x1(%eax),%edx
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a1e:	83 ec 0c             	sub    $0xc,%esp
80101a21:	68 80 32 11 80       	push   $0x80113280
80101a26:	e8 25 4f 00 00       	call   80106950 <release>
80101a2b:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a31:	eb 74                	jmp    80101aa7 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a37:	75 10                	jne    80101a49 <iget+0x7f>
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3c:	8b 40 08             	mov    0x8(%eax),%eax
80101a3f:	85 c0                	test   %eax,%eax
80101a41:	75 06                	jne    80101a49 <iget+0x7f>
      empty = ip;
80101a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a46:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a49:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101a4d:	81 7d f4 54 42 11 80 	cmpl   $0x80114254,-0xc(%ebp)
80101a54:	72 9a                	jb     801019f0 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a5a:	75 0d                	jne    80101a69 <iget+0x9f>
    panic("iget: no inodes");
80101a5c:	83 ec 0c             	sub    $0xc,%esp
80101a5f:	68 19 a2 10 80       	push   $0x8010a219
80101a64:	e8 fd ea ff ff       	call   80100566 <panic>

  ip = empty;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a72:	8b 55 08             	mov    0x8(%ebp),%edx
80101a75:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a7d:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a83:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101a94:	83 ec 0c             	sub    $0xc,%esp
80101a97:	68 80 32 11 80       	push   $0x80113280
80101a9c:	e8 af 4e 00 00       	call   80106950 <release>
80101aa1:	83 c4 10             	add    $0x10,%esp

  return ip;
80101aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101aa7:	c9                   	leave  
80101aa8:	c3                   	ret    

80101aa9 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101aa9:	55                   	push   %ebp
80101aaa:	89 e5                	mov    %esp,%ebp
80101aac:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aaf:	83 ec 0c             	sub    $0xc,%esp
80101ab2:	68 80 32 11 80       	push   $0x80113280
80101ab7:	e8 2d 4e 00 00       	call   801068e9 <acquire>
80101abc:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	8b 40 08             	mov    0x8(%eax),%eax
80101ac5:	8d 50 01             	lea    0x1(%eax),%edx
80101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80101acb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ace:	83 ec 0c             	sub    $0xc,%esp
80101ad1:	68 80 32 11 80       	push   $0x80113280
80101ad6:	e8 75 4e 00 00       	call   80106950 <release>
80101adb:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ae1:	c9                   	leave  
80101ae2:	c3                   	ret    

80101ae3 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ae3:	55                   	push   %ebp
80101ae4:	89 e5                	mov    %esp,%ebp
80101ae6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ae9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aed:	74 0a                	je     80101af9 <ilock+0x16>
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	8b 40 08             	mov    0x8(%eax),%eax
80101af5:	85 c0                	test   %eax,%eax
80101af7:	7f 0d                	jg     80101b06 <ilock+0x23>
    panic("ilock");
80101af9:	83 ec 0c             	sub    $0xc,%esp
80101afc:	68 29 a2 10 80       	push   $0x8010a229
80101b01:	e8 60 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b06:	83 ec 0c             	sub    $0xc,%esp
80101b09:	68 80 32 11 80       	push   $0x80113280
80101b0e:	e8 d6 4d 00 00       	call   801068e9 <acquire>
80101b13:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101b16:	eb 13                	jmp    80101b2b <ilock+0x48>
    sleep(ip, &icache.lock);
80101b18:	83 ec 08             	sub    $0x8,%esp
80101b1b:	68 80 32 11 80       	push   $0x80113280
80101b20:	ff 75 08             	pushl  0x8(%ebp)
80101b23:	e8 29 3d 00 00       	call   80105851 <sleep>
80101b28:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b31:	83 e0 01             	and    $0x1,%eax
80101b34:	85 c0                	test   %eax,%eax
80101b36:	75 e0                	jne    80101b18 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b38:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3e:	83 c8 01             	or     $0x1,%eax
80101b41:	89 c2                	mov    %eax,%edx
80101b43:	8b 45 08             	mov    0x8(%ebp),%eax
80101b46:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101b49:	83 ec 0c             	sub    $0xc,%esp
80101b4c:	68 80 32 11 80       	push   $0x80113280
80101b51:	e8 fa 4d 00 00       	call   80106950 <release>
80101b56:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101b5f:	83 e0 02             	and    $0x2,%eax
80101b62:	85 c0                	test   %eax,%eax
80101b64:	0f 85 fc 00 00 00    	jne    80101c66 <ilock+0x183>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 40 04             	mov    0x4(%eax),%eax
80101b70:	c1 e8 03             	shr    $0x3,%eax
80101b73:	89 c2                	mov    %eax,%edx
80101b75:	a1 74 32 11 80       	mov    0x80113274,%eax
80101b7a:	01 c2                	add    %eax,%edx
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 00                	mov    (%eax),%eax
80101b81:	83 ec 08             	sub    $0x8,%esp
80101b84:	52                   	push   %edx
80101b85:	50                   	push   %eax
80101b86:	e8 2b e6 ff ff       	call   801001b6 <bread>
80101b8b:	83 c4 10             	add    $0x10,%esp
80101b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b94:	8d 50 18             	lea    0x18(%eax),%edx
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	8b 40 04             	mov    0x4(%eax),%eax
80101b9d:	83 e0 07             	and    $0x7,%eax
80101ba0:	c1 e0 06             	shl    $0x6,%eax
80101ba3:	01 d0                	add    %edx,%eax
80101ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifdef CS333_P5
    ip->uid = dip->uid;
80101ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bab:	0f b7 50 08          	movzwl 0x8(%eax),%edx
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	66 89 50 18          	mov    %dx,0x18(%eax)
    ip->gid = dip->gid;
80101bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb9:	0f b7 50 0a          	movzwl 0xa(%eax),%edx
80101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc0:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    ip->mode.asInt = dip->mode.asInt;
80101bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc7:	8b 50 0c             	mov    0xc(%eax),%edx
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	89 50 1c             	mov    %edx,0x1c(%eax)
#endif
    ip->type = dip->type;
80101bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd3:	0f b7 10             	movzwl (%eax),%edx
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bee:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf5:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfc:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0a:	8b 50 10             	mov    0x10(%eax),%edx
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	89 50 20             	mov    %edx,0x20(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c16:	8d 50 14             	lea    0x14(%eax),%edx
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	83 c0 24             	add    $0x24,%eax
80101c1f:	83 ec 04             	sub    $0x4,%esp
80101c22:	6a 2c                	push   $0x2c
80101c24:	52                   	push   %edx
80101c25:	50                   	push   %eax
80101c26:	e8 e0 4f 00 00       	call   80106c0b <memmove>
80101c2b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c2e:	83 ec 0c             	sub    $0xc,%esp
80101c31:	ff 75 f4             	pushl  -0xc(%ebp)
80101c34:	e8 f5 e5 ff ff       	call   8010022e <brelse>
80101c39:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c42:	83 c8 02             	or     $0x2,%eax
80101c45:	89 c2                	mov    %eax,%edx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c54:	66 85 c0             	test   %ax,%ax
80101c57:	75 0d                	jne    80101c66 <ilock+0x183>
      panic("ilock: no type");
80101c59:	83 ec 0c             	sub    $0xc,%esp
80101c5c:	68 2f a2 10 80       	push   $0x8010a22f
80101c61:	e8 00 e9 ff ff       	call   80100566 <panic>
  }
}
80101c66:	90                   	nop
80101c67:	c9                   	leave  
80101c68:	c3                   	ret    

80101c69 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c69:	55                   	push   %ebp
80101c6a:	89 e5                	mov    %esp,%ebp
80101c6c:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101c6f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c73:	74 17                	je     80101c8c <iunlock+0x23>
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	8b 40 0c             	mov    0xc(%eax),%eax
80101c7b:	83 e0 01             	and    $0x1,%eax
80101c7e:	85 c0                	test   %eax,%eax
80101c80:	74 0a                	je     80101c8c <iunlock+0x23>
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	8b 40 08             	mov    0x8(%eax),%eax
80101c88:	85 c0                	test   %eax,%eax
80101c8a:	7f 0d                	jg     80101c99 <iunlock+0x30>
    panic("iunlock");
80101c8c:	83 ec 0c             	sub    $0xc,%esp
80101c8f:	68 3e a2 10 80       	push   $0x8010a23e
80101c94:	e8 cd e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c99:	83 ec 0c             	sub    $0xc,%esp
80101c9c:	68 80 32 11 80       	push   $0x80113280
80101ca1:	e8 43 4c 00 00       	call   801068e9 <acquire>
80101ca6:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 40 0c             	mov    0xc(%eax),%eax
80101caf:	83 e0 fe             	and    $0xfffffffe,%eax
80101cb2:	89 c2                	mov    %eax,%edx
80101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb7:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cba:	83 ec 0c             	sub    $0xc,%esp
80101cbd:	ff 75 08             	pushl  0x8(%ebp)
80101cc0:	e8 b0 3d 00 00       	call   80105a75 <wakeup>
80101cc5:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101cc8:	83 ec 0c             	sub    $0xc,%esp
80101ccb:	68 80 32 11 80       	push   $0x80113280
80101cd0:	e8 7b 4c 00 00       	call   80106950 <release>
80101cd5:	83 c4 10             	add    $0x10,%esp
}
80101cd8:	90                   	nop
80101cd9:	c9                   	leave  
80101cda:	c3                   	ret    

80101cdb <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cdb:	55                   	push   %ebp
80101cdc:	89 e5                	mov    %esp,%ebp
80101cde:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ce1:	83 ec 0c             	sub    $0xc,%esp
80101ce4:	68 80 32 11 80       	push   $0x80113280
80101ce9:	e8 fb 4b 00 00       	call   801068e9 <acquire>
80101cee:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf4:	8b 40 08             	mov    0x8(%eax),%eax
80101cf7:	83 f8 01             	cmp    $0x1,%eax
80101cfa:	0f 85 a9 00 00 00    	jne    80101da9 <iput+0xce>
80101d00:	8b 45 08             	mov    0x8(%ebp),%eax
80101d03:	8b 40 0c             	mov    0xc(%eax),%eax
80101d06:	83 e0 02             	and    $0x2,%eax
80101d09:	85 c0                	test   %eax,%eax
80101d0b:	0f 84 98 00 00 00    	je     80101da9 <iput+0xce>
80101d11:	8b 45 08             	mov    0x8(%ebp),%eax
80101d14:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d18:	66 85 c0             	test   %ax,%ax
80101d1b:	0f 85 88 00 00 00    	jne    80101da9 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101d21:	8b 45 08             	mov    0x8(%ebp),%eax
80101d24:	8b 40 0c             	mov    0xc(%eax),%eax
80101d27:	83 e0 01             	and    $0x1,%eax
80101d2a:	85 c0                	test   %eax,%eax
80101d2c:	74 0d                	je     80101d3b <iput+0x60>
      panic("iput busy");
80101d2e:	83 ec 0c             	sub    $0xc,%esp
80101d31:	68 46 a2 10 80       	push   $0x8010a246
80101d36:	e8 2b e8 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3e:	8b 40 0c             	mov    0xc(%eax),%eax
80101d41:	83 c8 01             	or     $0x1,%eax
80101d44:	89 c2                	mov    %eax,%edx
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	68 80 32 11 80       	push   $0x80113280
80101d54:	e8 f7 4b 00 00       	call   80106950 <release>
80101d59:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	ff 75 08             	pushl  0x8(%ebp)
80101d62:	e8 a8 01 00 00       	call   80101f0f <itrunc>
80101d67:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101d73:	83 ec 0c             	sub    $0xc,%esp
80101d76:	ff 75 08             	pushl  0x8(%ebp)
80101d79:	e8 63 fb ff ff       	call   801018e1 <iupdate>
80101d7e:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101d81:	83 ec 0c             	sub    $0xc,%esp
80101d84:	68 80 32 11 80       	push   $0x80113280
80101d89:	e8 5b 4b 00 00       	call   801068e9 <acquire>
80101d8e:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101d9b:	83 ec 0c             	sub    $0xc,%esp
80101d9e:	ff 75 08             	pushl  0x8(%ebp)
80101da1:	e8 cf 3c 00 00       	call   80105a75 <wakeup>
80101da6:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	8b 40 08             	mov    0x8(%eax),%eax
80101daf:	8d 50 ff             	lea    -0x1(%eax),%edx
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101db8:	83 ec 0c             	sub    $0xc,%esp
80101dbb:	68 80 32 11 80       	push   $0x80113280
80101dc0:	e8 8b 4b 00 00       	call   80106950 <release>
80101dc5:	83 c4 10             	add    $0x10,%esp
}
80101dc8:	90                   	nop
80101dc9:	c9                   	leave  
80101dca:	c3                   	ret    

80101dcb <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dcb:	55                   	push   %ebp
80101dcc:	89 e5                	mov    %esp,%ebp
80101dce:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101dd1:	83 ec 0c             	sub    $0xc,%esp
80101dd4:	ff 75 08             	pushl  0x8(%ebp)
80101dd7:	e8 8d fe ff ff       	call   80101c69 <iunlock>
80101ddc:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ddf:	83 ec 0c             	sub    $0xc,%esp
80101de2:	ff 75 08             	pushl  0x8(%ebp)
80101de5:	e8 f1 fe ff ff       	call   80101cdb <iput>
80101dea:	83 c4 10             	add    $0x10,%esp
}
80101ded:	90                   	nop
80101dee:	c9                   	leave  
80101def:	c3                   	ret    

80101df0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	53                   	push   %ebx
80101df4:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101df7:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101dfb:	77 42                	ja     80101e3f <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101e00:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e03:	83 c2 08             	add    $0x8,%edx
80101e06:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e11:	75 24                	jne    80101e37 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	8b 00                	mov    (%eax),%eax
80101e18:	83 ec 0c             	sub    $0xc,%esp
80101e1b:	50                   	push   %eax
80101e1c:	e8 2e f7 ff ff       	call   8010154f <balloc>
80101e21:	83 c4 10             	add    $0x10,%esp
80101e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e27:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e2d:	8d 4a 08             	lea    0x8(%edx),%ecx
80101e30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e33:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    return addr;
80101e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e3a:	e9 cb 00 00 00       	jmp    80101f0a <bmap+0x11a>
  }
  bn -= NDIRECT;
80101e3f:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101e43:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e47:	0f 87 b0 00 00 00    	ja     80101efd <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e5a:	75 1d                	jne    80101e79 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	8b 00                	mov    (%eax),%eax
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	50                   	push   %eax
80101e65:	e8 e5 f6 ff ff       	call   8010154f <balloc>
80101e6a:	83 c4 10             	add    $0x10,%esp
80101e6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e76:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e79:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7c:	8b 00                	mov    (%eax),%eax
80101e7e:	83 ec 08             	sub    $0x8,%esp
80101e81:	ff 75 f4             	pushl  -0xc(%ebp)
80101e84:	50                   	push   %eax
80101e85:	e8 2c e3 ff ff       	call   801001b6 <bread>
80101e8a:	83 c4 10             	add    $0x10,%esp
80101e8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e93:	83 c0 18             	add    $0x18,%eax
80101e96:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea6:	01 d0                	add    %edx,%eax
80101ea8:	8b 00                	mov    (%eax),%eax
80101eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ead:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101eb1:	75 37                	jne    80101eea <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 00                	mov    (%eax),%eax
80101ec8:	83 ec 0c             	sub    $0xc,%esp
80101ecb:	50                   	push   %eax
80101ecc:	e8 7e f6 ff ff       	call   8010154f <balloc>
80101ed1:	83 c4 10             	add    $0x10,%esp
80101ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eda:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101edc:	83 ec 0c             	sub    $0xc,%esp
80101edf:	ff 75 f0             	pushl  -0x10(%ebp)
80101ee2:	e8 e1 1b 00 00       	call   80103ac8 <log_write>
80101ee7:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101eea:	83 ec 0c             	sub    $0xc,%esp
80101eed:	ff 75 f0             	pushl  -0x10(%ebp)
80101ef0:	e8 39 e3 ff ff       	call   8010022e <brelse>
80101ef5:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101efb:	eb 0d                	jmp    80101f0a <bmap+0x11a>
  }

  panic("bmap: out of range");
80101efd:	83 ec 0c             	sub    $0xc,%esp
80101f00:	68 50 a2 10 80       	push   $0x8010a250
80101f05:	e8 5c e6 ff ff       	call   80100566 <panic>
}
80101f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f0d:	c9                   	leave  
80101f0e:	c3                   	ret    

80101f0f <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f0f:	55                   	push   %ebp
80101f10:	89 e5                	mov    %esp,%ebp
80101f12:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f1c:	eb 45                	jmp    80101f63 <itrunc+0x54>
    if(ip->addrs[i]){
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f24:	83 c2 08             	add    $0x8,%edx
80101f27:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f2b:	85 c0                	test   %eax,%eax
80101f2d:	74 30                	je     80101f5f <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f35:	83 c2 08             	add    $0x8,%edx
80101f38:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f3f:	8b 12                	mov    (%edx),%edx
80101f41:	83 ec 08             	sub    $0x8,%esp
80101f44:	50                   	push   %eax
80101f45:	52                   	push   %edx
80101f46:	e8 50 f7 ff ff       	call   8010169b <bfree>
80101f4b:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f54:	83 c2 08             	add    $0x8,%edx
80101f57:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
80101f5e:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f63:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101f67:	7e b5                	jle    80101f1e <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f69:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f6f:	85 c0                	test   %eax,%eax
80101f71:	0f 84 a1 00 00 00    	je     80102018 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 00                	mov    (%eax),%eax
80101f82:	83 ec 08             	sub    $0x8,%esp
80101f85:	52                   	push   %edx
80101f86:	50                   	push   %eax
80101f87:	e8 2a e2 ff ff       	call   801001b6 <bread>
80101f8c:	83 c4 10             	add    $0x10,%esp
80101f8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f95:	83 c0 18             	add    $0x18,%eax
80101f98:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fa2:	eb 3c                	jmp    80101fe0 <itrunc+0xd1>
      if(a[j])
80101fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fa7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fb1:	01 d0                	add    %edx,%eax
80101fb3:	8b 00                	mov    (%eax),%eax
80101fb5:	85 c0                	test   %eax,%eax
80101fb7:	74 23                	je     80101fdc <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fc6:	01 d0                	add    %edx,%eax
80101fc8:	8b 00                	mov    (%eax),%eax
80101fca:	8b 55 08             	mov    0x8(%ebp),%edx
80101fcd:	8b 12                	mov    (%edx),%edx
80101fcf:	83 ec 08             	sub    $0x8,%esp
80101fd2:	50                   	push   %eax
80101fd3:	52                   	push   %edx
80101fd4:	e8 c2 f6 ff ff       	call   8010169b <bfree>
80101fd9:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fdc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	83 f8 7f             	cmp    $0x7f,%eax
80101fe6:	76 bc                	jbe    80101fa4 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fe8:	83 ec 0c             	sub    $0xc,%esp
80101feb:	ff 75 ec             	pushl  -0x14(%ebp)
80101fee:	e8 3b e2 ff ff       	call   8010022e <brelse>
80101ff3:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ffc:	8b 55 08             	mov    0x8(%ebp),%edx
80101fff:	8b 12                	mov    (%edx),%edx
80102001:	83 ec 08             	sub    $0x8,%esp
80102004:	50                   	push   %eax
80102005:	52                   	push   %edx
80102006:	e8 90 f6 ff ff       	call   8010169b <bfree>
8010200b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
8010200e:	8b 45 08             	mov    0x8(%ebp),%eax
80102011:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102018:	8b 45 08             	mov    0x8(%ebp),%eax
8010201b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  iupdate(ip);
80102022:	83 ec 0c             	sub    $0xc,%esp
80102025:	ff 75 08             	pushl  0x8(%ebp)
80102028:	e8 b4 f8 ff ff       	call   801018e1 <iupdate>
8010202d:	83 c4 10             	add    $0x10,%esp
}
80102030:	90                   	nop
80102031:	c9                   	leave  
80102032:	c3                   	ret    

80102033 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
#ifdef CS333_P5
    st->uid = ip->uid;
80102036:	8b 45 08             	mov    0x8(%ebp),%eax
80102039:	0f b7 50 18          	movzwl 0x18(%eax),%edx
8010203d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102040:	66 89 50 14          	mov    %dx,0x14(%eax)
    st->gid = ip->gid;
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
8010204b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204e:	66 89 50 16          	mov    %dx,0x16(%eax)
    st->mode.asInt = ip->mode.asInt;
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	8b 50 1c             	mov    0x1c(%eax),%edx
80102058:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205b:	89 50 18             	mov    %edx,0x18(%eax)
#endif
  st->dev = ip->dev;
8010205e:	8b 45 08             	mov    0x8(%ebp),%eax
80102061:	8b 00                	mov    (%eax),%eax
80102063:	89 c2                	mov    %eax,%edx
80102065:	8b 45 0c             	mov    0xc(%ebp),%eax
80102068:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010206b:	8b 45 08             	mov    0x8(%ebp),%eax
8010206e:	8b 50 04             	mov    0x4(%eax),%edx
80102071:	8b 45 0c             	mov    0xc(%ebp),%eax
80102074:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010207e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102081:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010208b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208e:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102092:	8b 45 08             	mov    0x8(%ebp),%eax
80102095:	8b 50 20             	mov    0x20(%eax),%edx
80102098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010209b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010209e:	90                   	nop
8010209f:	5d                   	pop    %ebp
801020a0:	c3                   	ret    

801020a1 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020a1:	55                   	push   %ebp
801020a2:	89 e5                	mov    %esp,%ebp
801020a4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020a7:	8b 45 08             	mov    0x8(%ebp),%eax
801020aa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020ae:	66 83 f8 03          	cmp    $0x3,%ax
801020b2:	75 5c                	jne    80102110 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020bb:	66 85 c0             	test   %ax,%ax
801020be:	78 20                	js     801020e0 <readi+0x3f>
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020c7:	66 83 f8 09          	cmp    $0x9,%ax
801020cb:	7f 13                	jg     801020e0 <readi+0x3f>
801020cd:	8b 45 08             	mov    0x8(%ebp),%eax
801020d0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d4:	98                   	cwtl   
801020d5:	8b 04 c5 00 32 11 80 	mov    -0x7feece00(,%eax,8),%eax
801020dc:	85 c0                	test   %eax,%eax
801020de:	75 0a                	jne    801020ea <readi+0x49>
      return -1;
801020e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020e5:	e9 0c 01 00 00       	jmp    801021f6 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
801020ea:	8b 45 08             	mov    0x8(%ebp),%eax
801020ed:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f1:	98                   	cwtl   
801020f2:	8b 04 c5 00 32 11 80 	mov    -0x7feece00(,%eax,8),%eax
801020f9:	8b 55 14             	mov    0x14(%ebp),%edx
801020fc:	83 ec 04             	sub    $0x4,%esp
801020ff:	52                   	push   %edx
80102100:	ff 75 0c             	pushl  0xc(%ebp)
80102103:	ff 75 08             	pushl  0x8(%ebp)
80102106:	ff d0                	call   *%eax
80102108:	83 c4 10             	add    $0x10,%esp
8010210b:	e9 e6 00 00 00       	jmp    801021f6 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	8b 40 20             	mov    0x20(%eax),%eax
80102116:	3b 45 10             	cmp    0x10(%ebp),%eax
80102119:	72 0d                	jb     80102128 <readi+0x87>
8010211b:	8b 55 10             	mov    0x10(%ebp),%edx
8010211e:	8b 45 14             	mov    0x14(%ebp),%eax
80102121:	01 d0                	add    %edx,%eax
80102123:	3b 45 10             	cmp    0x10(%ebp),%eax
80102126:	73 0a                	jae    80102132 <readi+0x91>
    return -1;
80102128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010212d:	e9 c4 00 00 00       	jmp    801021f6 <readi+0x155>
  if(off + n > ip->size)
80102132:	8b 55 10             	mov    0x10(%ebp),%edx
80102135:	8b 45 14             	mov    0x14(%ebp),%eax
80102138:	01 c2                	add    %eax,%edx
8010213a:	8b 45 08             	mov    0x8(%ebp),%eax
8010213d:	8b 40 20             	mov    0x20(%eax),%eax
80102140:	39 c2                	cmp    %eax,%edx
80102142:	76 0c                	jbe    80102150 <readi+0xaf>
    n = ip->size - off;
80102144:	8b 45 08             	mov    0x8(%ebp),%eax
80102147:	8b 40 20             	mov    0x20(%eax),%eax
8010214a:	2b 45 10             	sub    0x10(%ebp),%eax
8010214d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102150:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102157:	e9 8b 00 00 00       	jmp    801021e7 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010215c:	8b 45 10             	mov    0x10(%ebp),%eax
8010215f:	c1 e8 09             	shr    $0x9,%eax
80102162:	83 ec 08             	sub    $0x8,%esp
80102165:	50                   	push   %eax
80102166:	ff 75 08             	pushl  0x8(%ebp)
80102169:	e8 82 fc ff ff       	call   80101df0 <bmap>
8010216e:	83 c4 10             	add    $0x10,%esp
80102171:	89 c2                	mov    %eax,%edx
80102173:	8b 45 08             	mov    0x8(%ebp),%eax
80102176:	8b 00                	mov    (%eax),%eax
80102178:	83 ec 08             	sub    $0x8,%esp
8010217b:	52                   	push   %edx
8010217c:	50                   	push   %eax
8010217d:	e8 34 e0 ff ff       	call   801001b6 <bread>
80102182:	83 c4 10             	add    $0x10,%esp
80102185:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102188:	8b 45 10             	mov    0x10(%ebp),%eax
8010218b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102190:	ba 00 02 00 00       	mov    $0x200,%edx
80102195:	29 c2                	sub    %eax,%edx
80102197:	8b 45 14             	mov    0x14(%ebp),%eax
8010219a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010219d:	39 c2                	cmp    %eax,%edx
8010219f:	0f 46 c2             	cmovbe %edx,%eax
801021a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021a8:	8d 50 18             	lea    0x18(%eax),%edx
801021ab:	8b 45 10             	mov    0x10(%ebp),%eax
801021ae:	25 ff 01 00 00       	and    $0x1ff,%eax
801021b3:	01 d0                	add    %edx,%eax
801021b5:	83 ec 04             	sub    $0x4,%esp
801021b8:	ff 75 ec             	pushl  -0x14(%ebp)
801021bb:	50                   	push   %eax
801021bc:	ff 75 0c             	pushl  0xc(%ebp)
801021bf:	e8 47 4a 00 00       	call   80106c0b <memmove>
801021c4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021c7:	83 ec 0c             	sub    $0xc,%esp
801021ca:	ff 75 f0             	pushl  -0x10(%ebp)
801021cd:	e8 5c e0 ff ff       	call   8010022e <brelse>
801021d2:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d8:	01 45 f4             	add    %eax,-0xc(%ebp)
801021db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021de:	01 45 10             	add    %eax,0x10(%ebp)
801021e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021e4:	01 45 0c             	add    %eax,0xc(%ebp)
801021e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ea:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ed:	0f 82 69 ff ff ff    	jb     8010215c <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021f3:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021f6:	c9                   	leave  
801021f7:	c3                   	ret    

801021f8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021f8:	55                   	push   %ebp
801021f9:	89 e5                	mov    %esp,%ebp
801021fb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102201:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102205:	66 83 f8 03          	cmp    $0x3,%ax
80102209:	75 5c                	jne    80102267 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010220b:	8b 45 08             	mov    0x8(%ebp),%eax
8010220e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102212:	66 85 c0             	test   %ax,%ax
80102215:	78 20                	js     80102237 <writei+0x3f>
80102217:	8b 45 08             	mov    0x8(%ebp),%eax
8010221a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010221e:	66 83 f8 09          	cmp    $0x9,%ax
80102222:	7f 13                	jg     80102237 <writei+0x3f>
80102224:	8b 45 08             	mov    0x8(%ebp),%eax
80102227:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010222b:	98                   	cwtl   
8010222c:	8b 04 c5 04 32 11 80 	mov    -0x7feecdfc(,%eax,8),%eax
80102233:	85 c0                	test   %eax,%eax
80102235:	75 0a                	jne    80102241 <writei+0x49>
      return -1;
80102237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010223c:	e9 3d 01 00 00       	jmp    8010237e <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102241:	8b 45 08             	mov    0x8(%ebp),%eax
80102244:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102248:	98                   	cwtl   
80102249:	8b 04 c5 04 32 11 80 	mov    -0x7feecdfc(,%eax,8),%eax
80102250:	8b 55 14             	mov    0x14(%ebp),%edx
80102253:	83 ec 04             	sub    $0x4,%esp
80102256:	52                   	push   %edx
80102257:	ff 75 0c             	pushl  0xc(%ebp)
8010225a:	ff 75 08             	pushl  0x8(%ebp)
8010225d:	ff d0                	call   *%eax
8010225f:	83 c4 10             	add    $0x10,%esp
80102262:	e9 17 01 00 00       	jmp    8010237e <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	8b 40 20             	mov    0x20(%eax),%eax
8010226d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102270:	72 0d                	jb     8010227f <writei+0x87>
80102272:	8b 55 10             	mov    0x10(%ebp),%edx
80102275:	8b 45 14             	mov    0x14(%ebp),%eax
80102278:	01 d0                	add    %edx,%eax
8010227a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010227d:	73 0a                	jae    80102289 <writei+0x91>
    return -1;
8010227f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102284:	e9 f5 00 00 00       	jmp    8010237e <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102289:	8b 55 10             	mov    0x10(%ebp),%edx
8010228c:	8b 45 14             	mov    0x14(%ebp),%eax
8010228f:	01 d0                	add    %edx,%eax
80102291:	3d 00 14 01 00       	cmp    $0x11400,%eax
80102296:	76 0a                	jbe    801022a2 <writei+0xaa>
    return -1;
80102298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010229d:	e9 dc 00 00 00       	jmp    8010237e <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a9:	e9 99 00 00 00       	jmp    80102347 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022ae:	8b 45 10             	mov    0x10(%ebp),%eax
801022b1:	c1 e8 09             	shr    $0x9,%eax
801022b4:	83 ec 08             	sub    $0x8,%esp
801022b7:	50                   	push   %eax
801022b8:	ff 75 08             	pushl  0x8(%ebp)
801022bb:	e8 30 fb ff ff       	call   80101df0 <bmap>
801022c0:	83 c4 10             	add    $0x10,%esp
801022c3:	89 c2                	mov    %eax,%edx
801022c5:	8b 45 08             	mov    0x8(%ebp),%eax
801022c8:	8b 00                	mov    (%eax),%eax
801022ca:	83 ec 08             	sub    $0x8,%esp
801022cd:	52                   	push   %edx
801022ce:	50                   	push   %eax
801022cf:	e8 e2 de ff ff       	call   801001b6 <bread>
801022d4:	83 c4 10             	add    $0x10,%esp
801022d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022da:	8b 45 10             	mov    0x10(%ebp),%eax
801022dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801022e2:	ba 00 02 00 00       	mov    $0x200,%edx
801022e7:	29 c2                	sub    %eax,%edx
801022e9:	8b 45 14             	mov    0x14(%ebp),%eax
801022ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022ef:	39 c2                	cmp    %eax,%edx
801022f1:	0f 46 c2             	cmovbe %edx,%eax
801022f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022fa:	8d 50 18             	lea    0x18(%eax),%edx
801022fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102300:	25 ff 01 00 00       	and    $0x1ff,%eax
80102305:	01 d0                	add    %edx,%eax
80102307:	83 ec 04             	sub    $0x4,%esp
8010230a:	ff 75 ec             	pushl  -0x14(%ebp)
8010230d:	ff 75 0c             	pushl  0xc(%ebp)
80102310:	50                   	push   %eax
80102311:	e8 f5 48 00 00       	call   80106c0b <memmove>
80102316:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102319:	83 ec 0c             	sub    $0xc,%esp
8010231c:	ff 75 f0             	pushl  -0x10(%ebp)
8010231f:	e8 a4 17 00 00       	call   80103ac8 <log_write>
80102324:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102327:	83 ec 0c             	sub    $0xc,%esp
8010232a:	ff 75 f0             	pushl  -0x10(%ebp)
8010232d:	e8 fc de ff ff       	call   8010022e <brelse>
80102332:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102335:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102338:	01 45 f4             	add    %eax,-0xc(%ebp)
8010233b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233e:	01 45 10             	add    %eax,0x10(%ebp)
80102341:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102344:	01 45 0c             	add    %eax,0xc(%ebp)
80102347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010234d:	0f 82 5b ff ff ff    	jb     801022ae <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102353:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102357:	74 22                	je     8010237b <writei+0x183>
80102359:	8b 45 08             	mov    0x8(%ebp),%eax
8010235c:	8b 40 20             	mov    0x20(%eax),%eax
8010235f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102362:	73 17                	jae    8010237b <writei+0x183>
    ip->size = off;
80102364:	8b 45 08             	mov    0x8(%ebp),%eax
80102367:	8b 55 10             	mov    0x10(%ebp),%edx
8010236a:	89 50 20             	mov    %edx,0x20(%eax)
    iupdate(ip);
8010236d:	83 ec 0c             	sub    $0xc,%esp
80102370:	ff 75 08             	pushl  0x8(%ebp)
80102373:	e8 69 f5 ff ff       	call   801018e1 <iupdate>
80102378:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010237b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010237e:	c9                   	leave  
8010237f:	c3                   	ret    

80102380 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102380:	55                   	push   %ebp
80102381:	89 e5                	mov    %esp,%ebp
80102383:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102386:	83 ec 04             	sub    $0x4,%esp
80102389:	6a 0e                	push   $0xe
8010238b:	ff 75 0c             	pushl  0xc(%ebp)
8010238e:	ff 75 08             	pushl  0x8(%ebp)
80102391:	e8 0b 49 00 00       	call   80106ca1 <strncmp>
80102396:	83 c4 10             	add    $0x10,%esp
}
80102399:	c9                   	leave  
8010239a:	c3                   	ret    

8010239b <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010239b:	55                   	push   %ebp
8010239c:	89 e5                	mov    %esp,%ebp
8010239e:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023a8:	66 83 f8 01          	cmp    $0x1,%ax
801023ac:	74 0d                	je     801023bb <dirlookup+0x20>
    panic("dirlookup not DIR");
801023ae:	83 ec 0c             	sub    $0xc,%esp
801023b1:	68 63 a2 10 80       	push   $0x8010a263
801023b6:	e8 ab e1 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023c2:	eb 7b                	jmp    8010243f <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023c4:	6a 10                	push   $0x10
801023c6:	ff 75 f4             	pushl  -0xc(%ebp)
801023c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cc:	50                   	push   %eax
801023cd:	ff 75 08             	pushl  0x8(%ebp)
801023d0:	e8 cc fc ff ff       	call   801020a1 <readi>
801023d5:	83 c4 10             	add    $0x10,%esp
801023d8:	83 f8 10             	cmp    $0x10,%eax
801023db:	74 0d                	je     801023ea <dirlookup+0x4f>
      panic("dirlink read");
801023dd:	83 ec 0c             	sub    $0xc,%esp
801023e0:	68 75 a2 10 80       	push   $0x8010a275
801023e5:	e8 7c e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801023ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ee:	66 85 c0             	test   %ax,%ax
801023f1:	74 47                	je     8010243a <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801023f3:	83 ec 08             	sub    $0x8,%esp
801023f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f9:	83 c0 02             	add    $0x2,%eax
801023fc:	50                   	push   %eax
801023fd:	ff 75 0c             	pushl  0xc(%ebp)
80102400:	e8 7b ff ff ff       	call   80102380 <namecmp>
80102405:	83 c4 10             	add    $0x10,%esp
80102408:	85 c0                	test   %eax,%eax
8010240a:	75 2f                	jne    8010243b <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010240c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102410:	74 08                	je     8010241a <dirlookup+0x7f>
        *poff = off;
80102412:	8b 45 10             	mov    0x10(%ebp),%eax
80102415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102418:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010241a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010241e:	0f b7 c0             	movzwl %ax,%eax
80102421:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	8b 00                	mov    (%eax),%eax
80102429:	83 ec 08             	sub    $0x8,%esp
8010242c:	ff 75 f0             	pushl  -0x10(%ebp)
8010242f:	50                   	push   %eax
80102430:	e8 95 f5 ff ff       	call   801019ca <iget>
80102435:	83 c4 10             	add    $0x10,%esp
80102438:	eb 19                	jmp    80102453 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010243a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010243b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010243f:	8b 45 08             	mov    0x8(%ebp),%eax
80102442:	8b 40 20             	mov    0x20(%eax),%eax
80102445:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102448:	0f 87 76 ff ff ff    	ja     801023c4 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010244e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102453:	c9                   	leave  
80102454:	c3                   	ret    

80102455 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102455:	55                   	push   %ebp
80102456:	89 e5                	mov    %esp,%ebp
80102458:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010245b:	83 ec 04             	sub    $0x4,%esp
8010245e:	6a 00                	push   $0x0
80102460:	ff 75 0c             	pushl  0xc(%ebp)
80102463:	ff 75 08             	pushl  0x8(%ebp)
80102466:	e8 30 ff ff ff       	call   8010239b <dirlookup>
8010246b:	83 c4 10             	add    $0x10,%esp
8010246e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102471:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102475:	74 18                	je     8010248f <dirlink+0x3a>
    iput(ip);
80102477:	83 ec 0c             	sub    $0xc,%esp
8010247a:	ff 75 f0             	pushl  -0x10(%ebp)
8010247d:	e8 59 f8 ff ff       	call   80101cdb <iput>
80102482:	83 c4 10             	add    $0x10,%esp
    return -1;
80102485:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010248a:	e9 9c 00 00 00       	jmp    8010252b <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010248f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102496:	eb 39                	jmp    801024d1 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	6a 10                	push   $0x10
8010249d:	50                   	push   %eax
8010249e:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024a1:	50                   	push   %eax
801024a2:	ff 75 08             	pushl  0x8(%ebp)
801024a5:	e8 f7 fb ff ff       	call   801020a1 <readi>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	83 f8 10             	cmp    $0x10,%eax
801024b0:	74 0d                	je     801024bf <dirlink+0x6a>
      panic("dirlink read");
801024b2:	83 ec 0c             	sub    $0xc,%esp
801024b5:	68 75 a2 10 80       	push   $0x8010a275
801024ba:	e8 a7 e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801024bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024c3:	66 85 c0             	test   %ax,%ax
801024c6:	74 18                	je     801024e0 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cb:	83 c0 10             	add    $0x10,%eax
801024ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024d1:	8b 45 08             	mov    0x8(%ebp),%eax
801024d4:	8b 50 20             	mov    0x20(%eax),%edx
801024d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024da:	39 c2                	cmp    %eax,%edx
801024dc:	77 ba                	ja     80102498 <dirlink+0x43>
801024de:	eb 01                	jmp    801024e1 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024e0:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024e1:	83 ec 04             	sub    $0x4,%esp
801024e4:	6a 0e                	push   $0xe
801024e6:	ff 75 0c             	pushl  0xc(%ebp)
801024e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ec:	83 c0 02             	add    $0x2,%eax
801024ef:	50                   	push   %eax
801024f0:	e8 02 48 00 00       	call   80106cf7 <strncpy>
801024f5:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024f8:	8b 45 10             	mov    0x10(%ebp),%eax
801024fb:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102502:	6a 10                	push   $0x10
80102504:	50                   	push   %eax
80102505:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102508:	50                   	push   %eax
80102509:	ff 75 08             	pushl  0x8(%ebp)
8010250c:	e8 e7 fc ff ff       	call   801021f8 <writei>
80102511:	83 c4 10             	add    $0x10,%esp
80102514:	83 f8 10             	cmp    $0x10,%eax
80102517:	74 0d                	je     80102526 <dirlink+0xd1>
    panic("dirlink");
80102519:	83 ec 0c             	sub    $0xc,%esp
8010251c:	68 82 a2 10 80       	push   $0x8010a282
80102521:	e8 40 e0 ff ff       	call   80100566 <panic>
  
  return 0;
80102526:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010252b:	c9                   	leave  
8010252c:	c3                   	ret    

8010252d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010252d:	55                   	push   %ebp
8010252e:	89 e5                	mov    %esp,%ebp
80102530:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102533:	eb 04                	jmp    80102539 <skipelem+0xc>
    path++;
80102535:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102539:	8b 45 08             	mov    0x8(%ebp),%eax
8010253c:	0f b6 00             	movzbl (%eax),%eax
8010253f:	3c 2f                	cmp    $0x2f,%al
80102541:	74 f2                	je     80102535 <skipelem+0x8>
    path++;
  if(*path == 0)
80102543:	8b 45 08             	mov    0x8(%ebp),%eax
80102546:	0f b6 00             	movzbl (%eax),%eax
80102549:	84 c0                	test   %al,%al
8010254b:	75 07                	jne    80102554 <skipelem+0x27>
    return 0;
8010254d:	b8 00 00 00 00       	mov    $0x0,%eax
80102552:	eb 7b                	jmp    801025cf <skipelem+0xa2>
  s = path;
80102554:	8b 45 08             	mov    0x8(%ebp),%eax
80102557:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010255a:	eb 04                	jmp    80102560 <skipelem+0x33>
    path++;
8010255c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102560:	8b 45 08             	mov    0x8(%ebp),%eax
80102563:	0f b6 00             	movzbl (%eax),%eax
80102566:	3c 2f                	cmp    $0x2f,%al
80102568:	74 0a                	je     80102574 <skipelem+0x47>
8010256a:	8b 45 08             	mov    0x8(%ebp),%eax
8010256d:	0f b6 00             	movzbl (%eax),%eax
80102570:	84 c0                	test   %al,%al
80102572:	75 e8                	jne    8010255c <skipelem+0x2f>
    path++;
  len = path - s;
80102574:	8b 55 08             	mov    0x8(%ebp),%edx
80102577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257a:	29 c2                	sub    %eax,%edx
8010257c:	89 d0                	mov    %edx,%eax
8010257e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102581:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102585:	7e 15                	jle    8010259c <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102587:	83 ec 04             	sub    $0x4,%esp
8010258a:	6a 0e                	push   $0xe
8010258c:	ff 75 f4             	pushl  -0xc(%ebp)
8010258f:	ff 75 0c             	pushl  0xc(%ebp)
80102592:	e8 74 46 00 00       	call   80106c0b <memmove>
80102597:	83 c4 10             	add    $0x10,%esp
8010259a:	eb 26                	jmp    801025c2 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010259c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010259f:	83 ec 04             	sub    $0x4,%esp
801025a2:	50                   	push   %eax
801025a3:	ff 75 f4             	pushl  -0xc(%ebp)
801025a6:	ff 75 0c             	pushl  0xc(%ebp)
801025a9:	e8 5d 46 00 00       	call   80106c0b <memmove>
801025ae:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801025b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b7:	01 d0                	add    %edx,%eax
801025b9:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025bc:	eb 04                	jmp    801025c2 <skipelem+0x95>
    path++;
801025be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025c2:	8b 45 08             	mov    0x8(%ebp),%eax
801025c5:	0f b6 00             	movzbl (%eax),%eax
801025c8:	3c 2f                	cmp    $0x2f,%al
801025ca:	74 f2                	je     801025be <skipelem+0x91>
    path++;
  return path;
801025cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025cf:	c9                   	leave  
801025d0:	c3                   	ret    

801025d1 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025d1:	55                   	push   %ebp
801025d2:	89 e5                	mov    %esp,%ebp
801025d4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025d7:	8b 45 08             	mov    0x8(%ebp),%eax
801025da:	0f b6 00             	movzbl (%eax),%eax
801025dd:	3c 2f                	cmp    $0x2f,%al
801025df:	75 17                	jne    801025f8 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801025e1:	83 ec 08             	sub    $0x8,%esp
801025e4:	6a 01                	push   $0x1
801025e6:	6a 01                	push   $0x1
801025e8:	e8 dd f3 ff ff       	call   801019ca <iget>
801025ed:	83 c4 10             	add    $0x10,%esp
801025f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025f3:	e9 bb 00 00 00       	jmp    801026b3 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801025f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801025fe:	8b 40 68             	mov    0x68(%eax),%eax
80102601:	83 ec 0c             	sub    $0xc,%esp
80102604:	50                   	push   %eax
80102605:	e8 9f f4 ff ff       	call   80101aa9 <idup>
8010260a:	83 c4 10             	add    $0x10,%esp
8010260d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102610:	e9 9e 00 00 00       	jmp    801026b3 <namex+0xe2>
    ilock(ip);
80102615:	83 ec 0c             	sub    $0xc,%esp
80102618:	ff 75 f4             	pushl  -0xc(%ebp)
8010261b:	e8 c3 f4 ff ff       	call   80101ae3 <ilock>
80102620:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102626:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010262a:	66 83 f8 01          	cmp    $0x1,%ax
8010262e:	74 18                	je     80102648 <namex+0x77>
      iunlockput(ip);
80102630:	83 ec 0c             	sub    $0xc,%esp
80102633:	ff 75 f4             	pushl  -0xc(%ebp)
80102636:	e8 90 f7 ff ff       	call   80101dcb <iunlockput>
8010263b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010263e:	b8 00 00 00 00       	mov    $0x0,%eax
80102643:	e9 a7 00 00 00       	jmp    801026ef <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102648:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010264c:	74 20                	je     8010266e <namex+0x9d>
8010264e:	8b 45 08             	mov    0x8(%ebp),%eax
80102651:	0f b6 00             	movzbl (%eax),%eax
80102654:	84 c0                	test   %al,%al
80102656:	75 16                	jne    8010266e <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102658:	83 ec 0c             	sub    $0xc,%esp
8010265b:	ff 75 f4             	pushl  -0xc(%ebp)
8010265e:	e8 06 f6 ff ff       	call   80101c69 <iunlock>
80102663:	83 c4 10             	add    $0x10,%esp
      return ip;
80102666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102669:	e9 81 00 00 00       	jmp    801026ef <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010266e:	83 ec 04             	sub    $0x4,%esp
80102671:	6a 00                	push   $0x0
80102673:	ff 75 10             	pushl  0x10(%ebp)
80102676:	ff 75 f4             	pushl  -0xc(%ebp)
80102679:	e8 1d fd ff ff       	call   8010239b <dirlookup>
8010267e:	83 c4 10             	add    $0x10,%esp
80102681:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102684:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102688:	75 15                	jne    8010269f <namex+0xce>
      iunlockput(ip);
8010268a:	83 ec 0c             	sub    $0xc,%esp
8010268d:	ff 75 f4             	pushl  -0xc(%ebp)
80102690:	e8 36 f7 ff ff       	call   80101dcb <iunlockput>
80102695:	83 c4 10             	add    $0x10,%esp
      return 0;
80102698:	b8 00 00 00 00       	mov    $0x0,%eax
8010269d:	eb 50                	jmp    801026ef <namex+0x11e>
    }
    iunlockput(ip);
8010269f:	83 ec 0c             	sub    $0xc,%esp
801026a2:	ff 75 f4             	pushl  -0xc(%ebp)
801026a5:	e8 21 f7 ff ff       	call   80101dcb <iunlockput>
801026aa:	83 c4 10             	add    $0x10,%esp
    ip = next;
801026ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026b3:	83 ec 08             	sub    $0x8,%esp
801026b6:	ff 75 10             	pushl  0x10(%ebp)
801026b9:	ff 75 08             	pushl  0x8(%ebp)
801026bc:	e8 6c fe ff ff       	call   8010252d <skipelem>
801026c1:	83 c4 10             	add    $0x10,%esp
801026c4:	89 45 08             	mov    %eax,0x8(%ebp)
801026c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026cb:	0f 85 44 ff ff ff    	jne    80102615 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026d5:	74 15                	je     801026ec <namex+0x11b>
    iput(ip);
801026d7:	83 ec 0c             	sub    $0xc,%esp
801026da:	ff 75 f4             	pushl  -0xc(%ebp)
801026dd:	e8 f9 f5 ff ff       	call   80101cdb <iput>
801026e2:	83 c4 10             	add    $0x10,%esp
    return 0;
801026e5:	b8 00 00 00 00       	mov    $0x0,%eax
801026ea:	eb 03                	jmp    801026ef <namex+0x11e>
  }
  return ip;
801026ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026ef:	c9                   	leave  
801026f0:	c3                   	ret    

801026f1 <namei>:

struct inode*
namei(char *path)
{
801026f1:	55                   	push   %ebp
801026f2:	89 e5                	mov    %esp,%ebp
801026f4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026f7:	83 ec 04             	sub    $0x4,%esp
801026fa:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026fd:	50                   	push   %eax
801026fe:	6a 00                	push   $0x0
80102700:	ff 75 08             	pushl  0x8(%ebp)
80102703:	e8 c9 fe ff ff       	call   801025d1 <namex>
80102708:	83 c4 10             	add    $0x10,%esp
}
8010270b:	c9                   	leave  
8010270c:	c3                   	ret    

8010270d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010270d:	55                   	push   %ebp
8010270e:	89 e5                	mov    %esp,%ebp
80102710:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102713:	83 ec 04             	sub    $0x4,%esp
80102716:	ff 75 0c             	pushl  0xc(%ebp)
80102719:	6a 01                	push   $0x1
8010271b:	ff 75 08             	pushl  0x8(%ebp)
8010271e:	e8 ae fe ff ff       	call   801025d1 <namex>
80102723:	83 c4 10             	add    $0x10,%esp
}
80102726:	c9                   	leave  
80102727:	c3                   	ret    

80102728 <chmod>:

#ifdef CS333_P5
int
chmod(char * pathname,int mode)
{
80102728:	55                   	push   %ebp
80102729:	89 e5                	mov    %esp,%ebp
8010272b:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;
    begin_op();
8010272e:	e8 5d 11 00 00       	call   80103890 <begin_op>
    ip = namei(pathname);
80102733:	83 ec 0c             	sub    $0xc,%esp
80102736:	ff 75 08             	pushl  0x8(%ebp)
80102739:	e8 b3 ff ff ff       	call   801026f1 <namei>
8010273e:	83 c4 10             	add    $0x10,%esp
80102741:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0 || (mode > 1023 || mode < 0))
80102744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102748:	74 0f                	je     80102759 <chmod+0x31>
8010274a:	81 7d 0c ff 03 00 00 	cmpl   $0x3ff,0xc(%ebp)
80102751:	7f 06                	jg     80102759 <chmod+0x31>
80102753:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102757:	79 0c                	jns    80102765 <chmod+0x3d>
    {
        end_op();
80102759:	e8 be 11 00 00       	call   8010391c <end_op>
        return -1;
8010275e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102763:	eb 3d                	jmp    801027a2 <chmod+0x7a>
    }
    ilock(ip);
80102765:	83 ec 0c             	sub    $0xc,%esp
80102768:	ff 75 f4             	pushl  -0xc(%ebp)
8010276b:	e8 73 f3 ff ff       	call   80101ae3 <ilock>
80102770:	83 c4 10             	add    $0x10,%esp
    ip->mode.asInt = mode;
80102773:	8b 55 0c             	mov    0xc(%ebp),%edx
80102776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102779:	89 50 1c             	mov    %edx,0x1c(%eax)
    iupdate(ip);
8010277c:	83 ec 0c             	sub    $0xc,%esp
8010277f:	ff 75 f4             	pushl  -0xc(%ebp)
80102782:	e8 5a f1 ff ff       	call   801018e1 <iupdate>
80102787:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
8010278a:	83 ec 0c             	sub    $0xc,%esp
8010278d:	ff 75 f4             	pushl  -0xc(%ebp)
80102790:	e8 d4 f4 ff ff       	call   80101c69 <iunlock>
80102795:	83 c4 10             	add    $0x10,%esp
    end_op();
80102798:	e8 7f 11 00 00       	call   8010391c <end_op>
    return 0;
8010279d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027a2:	c9                   	leave  
801027a3:	c3                   	ret    

801027a4 <chown>:

int
chown(char * pathname,int owner)
{
801027a4:	55                   	push   %ebp
801027a5:	89 e5                	mov    %esp,%ebp
801027a7:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;
    begin_op();
801027aa:	e8 e1 10 00 00       	call   80103890 <begin_op>
    ip = namei(pathname);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	ff 75 08             	pushl  0x8(%ebp)
801027b5:	e8 37 ff ff ff       	call   801026f1 <namei>
801027ba:	83 c4 10             	add    $0x10,%esp
801027bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0 || (owner > 32767 || owner < 0))
801027c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c4:	74 0f                	je     801027d5 <chown+0x31>
801027c6:	81 7d 0c ff 7f 00 00 	cmpl   $0x7fff,0xc(%ebp)
801027cd:	7f 06                	jg     801027d5 <chown+0x31>
801027cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027d3:	79 0c                	jns    801027e1 <chown+0x3d>
    {
        end_op();
801027d5:	e8 42 11 00 00       	call   8010391c <end_op>
        return -1;
801027da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027df:	eb 40                	jmp    80102821 <chown+0x7d>
    }
    ilock(ip);
801027e1:	83 ec 0c             	sub    $0xc,%esp
801027e4:	ff 75 f4             	pushl  -0xc(%ebp)
801027e7:	e8 f7 f2 ff ff       	call   80101ae3 <ilock>
801027ec:	83 c4 10             	add    $0x10,%esp
    ip->uid = owner;
801027ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801027f2:	89 c2                	mov    %eax,%edx
801027f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f7:	66 89 50 18          	mov    %dx,0x18(%eax)
    iupdate(ip);
801027fb:	83 ec 0c             	sub    $0xc,%esp
801027fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102801:	e8 db f0 ff ff       	call   801018e1 <iupdate>
80102806:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
80102809:	83 ec 0c             	sub    $0xc,%esp
8010280c:	ff 75 f4             	pushl  -0xc(%ebp)
8010280f:	e8 55 f4 ff ff       	call   80101c69 <iunlock>
80102814:	83 c4 10             	add    $0x10,%esp
    end_op();
80102817:	e8 00 11 00 00       	call   8010391c <end_op>
    return 0;
8010281c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102821:	c9                   	leave  
80102822:	c3                   	ret    

80102823 <chgrp>:

int
chgrp(char * pathname,int group)
{
80102823:	55                   	push   %ebp
80102824:	89 e5                	mov    %esp,%ebp
80102826:	83 ec 18             	sub    $0x18,%esp
    struct inode * ip;
    begin_op();
80102829:	e8 62 10 00 00       	call   80103890 <begin_op>
    ip = namei(pathname);
8010282e:	83 ec 0c             	sub    $0xc,%esp
80102831:	ff 75 08             	pushl  0x8(%ebp)
80102834:	e8 b8 fe ff ff       	call   801026f1 <namei>
80102839:	83 c4 10             	add    $0x10,%esp
8010283c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0 || (group > 32767 || group < 0))
8010283f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102843:	74 0f                	je     80102854 <chgrp+0x31>
80102845:	81 7d 0c ff 7f 00 00 	cmpl   $0x7fff,0xc(%ebp)
8010284c:	7f 06                	jg     80102854 <chgrp+0x31>
8010284e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102852:	79 0c                	jns    80102860 <chgrp+0x3d>
    {
        end_op();
80102854:	e8 c3 10 00 00       	call   8010391c <end_op>
        return -1;
80102859:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010285e:	eb 40                	jmp    801028a0 <chgrp+0x7d>
    }
    ilock(ip);
80102860:	83 ec 0c             	sub    $0xc,%esp
80102863:	ff 75 f4             	pushl  -0xc(%ebp)
80102866:	e8 78 f2 ff ff       	call   80101ae3 <ilock>
8010286b:	83 c4 10             	add    $0x10,%esp
    ip->gid = group;
8010286e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102871:	89 c2                	mov    %eax,%edx
80102873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102876:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    iupdate(ip);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	ff 75 f4             	pushl  -0xc(%ebp)
80102880:	e8 5c f0 ff ff       	call   801018e1 <iupdate>
80102885:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	ff 75 f4             	pushl  -0xc(%ebp)
8010288e:	e8 d6 f3 ff ff       	call   80101c69 <iunlock>
80102893:	83 c4 10             	add    $0x10,%esp
    end_op();
80102896:	e8 81 10 00 00       	call   8010391c <end_op>
    return 0;
8010289b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028a0:	c9                   	leave  
801028a1:	c3                   	ret    

801028a2 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801028a2:	55                   	push   %ebp
801028a3:	89 e5                	mov    %esp,%ebp
801028a5:	83 ec 14             	sub    $0x14,%esp
801028a8:	8b 45 08             	mov    0x8(%ebp),%eax
801028ab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028af:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028b3:	89 c2                	mov    %eax,%edx
801028b5:	ec                   	in     (%dx),%al
801028b6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801028b9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801028bd:	c9                   	leave  
801028be:	c3                   	ret    

801028bf <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801028bf:	55                   	push   %ebp
801028c0:	89 e5                	mov    %esp,%ebp
801028c2:	57                   	push   %edi
801028c3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801028c4:	8b 55 08             	mov    0x8(%ebp),%edx
801028c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801028ca:	8b 45 10             	mov    0x10(%ebp),%eax
801028cd:	89 cb                	mov    %ecx,%ebx
801028cf:	89 df                	mov    %ebx,%edi
801028d1:	89 c1                	mov    %eax,%ecx
801028d3:	fc                   	cld    
801028d4:	f3 6d                	rep insl (%dx),%es:(%edi)
801028d6:	89 c8                	mov    %ecx,%eax
801028d8:	89 fb                	mov    %edi,%ebx
801028da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801028dd:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801028e0:	90                   	nop
801028e1:	5b                   	pop    %ebx
801028e2:	5f                   	pop    %edi
801028e3:	5d                   	pop    %ebp
801028e4:	c3                   	ret    

801028e5 <outb>:

static inline void
outb(ushort port, uchar data)
{
801028e5:	55                   	push   %ebp
801028e6:	89 e5                	mov    %esp,%ebp
801028e8:	83 ec 08             	sub    $0x8,%esp
801028eb:	8b 55 08             	mov    0x8(%ebp),%edx
801028ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801028f1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801028f5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801028fc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102900:	ee                   	out    %al,(%dx)
}
80102901:	90                   	nop
80102902:	c9                   	leave  
80102903:	c3                   	ret    

80102904 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102904:	55                   	push   %ebp
80102905:	89 e5                	mov    %esp,%ebp
80102907:	56                   	push   %esi
80102908:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102909:	8b 55 08             	mov    0x8(%ebp),%edx
8010290c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010290f:	8b 45 10             	mov    0x10(%ebp),%eax
80102912:	89 cb                	mov    %ecx,%ebx
80102914:	89 de                	mov    %ebx,%esi
80102916:	89 c1                	mov    %eax,%ecx
80102918:	fc                   	cld    
80102919:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010291b:	89 c8                	mov    %ecx,%eax
8010291d:	89 f3                	mov    %esi,%ebx
8010291f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102922:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102925:	90                   	nop
80102926:	5b                   	pop    %ebx
80102927:	5e                   	pop    %esi
80102928:	5d                   	pop    %ebp
80102929:	c3                   	ret    

8010292a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010292a:	55                   	push   %ebp
8010292b:	89 e5                	mov    %esp,%ebp
8010292d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102930:	90                   	nop
80102931:	68 f7 01 00 00       	push   $0x1f7
80102936:	e8 67 ff ff ff       	call   801028a2 <inb>
8010293b:	83 c4 04             	add    $0x4,%esp
8010293e:	0f b6 c0             	movzbl %al,%eax
80102941:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102944:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102947:	25 c0 00 00 00       	and    $0xc0,%eax
8010294c:	83 f8 40             	cmp    $0x40,%eax
8010294f:	75 e0                	jne    80102931 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102951:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102955:	74 11                	je     80102968 <idewait+0x3e>
80102957:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010295a:	83 e0 21             	and    $0x21,%eax
8010295d:	85 c0                	test   %eax,%eax
8010295f:	74 07                	je     80102968 <idewait+0x3e>
    return -1;
80102961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102966:	eb 05                	jmp    8010296d <idewait+0x43>
  return 0;
80102968:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010296d:	c9                   	leave  
8010296e:	c3                   	ret    

8010296f <ideinit>:

void
ideinit(void)
{
8010296f:	55                   	push   %ebp
80102970:	89 e5                	mov    %esp,%ebp
80102972:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102975:	83 ec 08             	sub    $0x8,%esp
80102978:	68 8a a2 10 80       	push   $0x8010a28a
8010297d:	68 40 d6 10 80       	push   $0x8010d640
80102982:	e8 40 3f 00 00       	call   801068c7 <initlock>
80102987:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
8010298a:	83 ec 0c             	sub    $0xc,%esp
8010298d:	6a 0e                	push   $0xe
8010298f:	e8 da 18 00 00       	call   8010426e <picenable>
80102994:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102997:	a1 80 49 11 80       	mov    0x80114980,%eax
8010299c:	83 e8 01             	sub    $0x1,%eax
8010299f:	83 ec 08             	sub    $0x8,%esp
801029a2:	50                   	push   %eax
801029a3:	6a 0e                	push   $0xe
801029a5:	e8 73 04 00 00       	call   80102e1d <ioapicenable>
801029aa:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801029ad:	83 ec 0c             	sub    $0xc,%esp
801029b0:	6a 00                	push   $0x0
801029b2:	e8 73 ff ff ff       	call   8010292a <idewait>
801029b7:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801029ba:	83 ec 08             	sub    $0x8,%esp
801029bd:	68 f0 00 00 00       	push   $0xf0
801029c2:	68 f6 01 00 00       	push   $0x1f6
801029c7:	e8 19 ff ff ff       	call   801028e5 <outb>
801029cc:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801029cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029d6:	eb 24                	jmp    801029fc <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801029d8:	83 ec 0c             	sub    $0xc,%esp
801029db:	68 f7 01 00 00       	push   $0x1f7
801029e0:	e8 bd fe ff ff       	call   801028a2 <inb>
801029e5:	83 c4 10             	add    $0x10,%esp
801029e8:	84 c0                	test   %al,%al
801029ea:	74 0c                	je     801029f8 <ideinit+0x89>
      havedisk1 = 1;
801029ec:	c7 05 78 d6 10 80 01 	movl   $0x1,0x8010d678
801029f3:	00 00 00 
      break;
801029f6:	eb 0d                	jmp    80102a05 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801029f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801029fc:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102a03:	7e d3                	jle    801029d8 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 e0 00 00 00       	push   $0xe0
80102a0d:	68 f6 01 00 00       	push   $0x1f6
80102a12:	e8 ce fe ff ff       	call   801028e5 <outb>
80102a17:	83 c4 10             	add    $0x10,%esp
}
80102a1a:	90                   	nop
80102a1b:	c9                   	leave  
80102a1c:	c3                   	ret    

80102a1d <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102a1d:	55                   	push   %ebp
80102a1e:	89 e5                	mov    %esp,%ebp
80102a20:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102a23:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a27:	75 0d                	jne    80102a36 <idestart+0x19>
    panic("idestart");
80102a29:	83 ec 0c             	sub    $0xc,%esp
80102a2c:	68 8e a2 10 80       	push   $0x8010a28e
80102a31:	e8 30 db ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102a36:	8b 45 08             	mov    0x8(%ebp),%eax
80102a39:	8b 40 08             	mov    0x8(%eax),%eax
80102a3c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
80102a41:	76 0d                	jbe    80102a50 <idestart+0x33>
    panic("incorrect blockno");
80102a43:	83 ec 0c             	sub    $0xc,%esp
80102a46:	68 97 a2 10 80       	push   $0x8010a297
80102a4b:	e8 16 db ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102a50:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102a57:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5a:	8b 50 08             	mov    0x8(%eax),%edx
80102a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a60:	0f af c2             	imul   %edx,%eax
80102a63:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102a66:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102a6a:	7e 0d                	jle    80102a79 <idestart+0x5c>
80102a6c:	83 ec 0c             	sub    $0xc,%esp
80102a6f:	68 8e a2 10 80       	push   $0x8010a28e
80102a74:	e8 ed da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102a79:	83 ec 0c             	sub    $0xc,%esp
80102a7c:	6a 00                	push   $0x0
80102a7e:	e8 a7 fe ff ff       	call   8010292a <idewait>
80102a83:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102a86:	83 ec 08             	sub    $0x8,%esp
80102a89:	6a 00                	push   $0x0
80102a8b:	68 f6 03 00 00       	push   $0x3f6
80102a90:	e8 50 fe ff ff       	call   801028e5 <outb>
80102a95:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9b:	0f b6 c0             	movzbl %al,%eax
80102a9e:	83 ec 08             	sub    $0x8,%esp
80102aa1:	50                   	push   %eax
80102aa2:	68 f2 01 00 00       	push   $0x1f2
80102aa7:	e8 39 fe ff ff       	call   801028e5 <outb>
80102aac:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ab2:	0f b6 c0             	movzbl %al,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	50                   	push   %eax
80102ab9:	68 f3 01 00 00       	push   $0x1f3
80102abe:	e8 22 fe ff ff       	call   801028e5 <outb>
80102ac3:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ac9:	c1 f8 08             	sar    $0x8,%eax
80102acc:	0f b6 c0             	movzbl %al,%eax
80102acf:	83 ec 08             	sub    $0x8,%esp
80102ad2:	50                   	push   %eax
80102ad3:	68 f4 01 00 00       	push   $0x1f4
80102ad8:	e8 08 fe ff ff       	call   801028e5 <outb>
80102add:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ae3:	c1 f8 10             	sar    $0x10,%eax
80102ae6:	0f b6 c0             	movzbl %al,%eax
80102ae9:	83 ec 08             	sub    $0x8,%esp
80102aec:	50                   	push   %eax
80102aed:	68 f5 01 00 00       	push   $0x1f5
80102af2:	e8 ee fd ff ff       	call   801028e5 <outb>
80102af7:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102afa:	8b 45 08             	mov    0x8(%ebp),%eax
80102afd:	8b 40 04             	mov    0x4(%eax),%eax
80102b00:	83 e0 01             	and    $0x1,%eax
80102b03:	c1 e0 04             	shl    $0x4,%eax
80102b06:	89 c2                	mov    %eax,%edx
80102b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b0b:	c1 f8 18             	sar    $0x18,%eax
80102b0e:	83 e0 0f             	and    $0xf,%eax
80102b11:	09 d0                	or     %edx,%eax
80102b13:	83 c8 e0             	or     $0xffffffe0,%eax
80102b16:	0f b6 c0             	movzbl %al,%eax
80102b19:	83 ec 08             	sub    $0x8,%esp
80102b1c:	50                   	push   %eax
80102b1d:	68 f6 01 00 00       	push   $0x1f6
80102b22:	e8 be fd ff ff       	call   801028e5 <outb>
80102b27:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2d:	8b 00                	mov    (%eax),%eax
80102b2f:	83 e0 04             	and    $0x4,%eax
80102b32:	85 c0                	test   %eax,%eax
80102b34:	74 30                	je     80102b66 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102b36:	83 ec 08             	sub    $0x8,%esp
80102b39:	6a 30                	push   $0x30
80102b3b:	68 f7 01 00 00       	push   $0x1f7
80102b40:	e8 a0 fd ff ff       	call   801028e5 <outb>
80102b45:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	83 c0 18             	add    $0x18,%eax
80102b4e:	83 ec 04             	sub    $0x4,%esp
80102b51:	68 80 00 00 00       	push   $0x80
80102b56:	50                   	push   %eax
80102b57:	68 f0 01 00 00       	push   $0x1f0
80102b5c:	e8 a3 fd ff ff       	call   80102904 <outsl>
80102b61:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102b64:	eb 12                	jmp    80102b78 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102b66:	83 ec 08             	sub    $0x8,%esp
80102b69:	6a 20                	push   $0x20
80102b6b:	68 f7 01 00 00       	push   $0x1f7
80102b70:	e8 70 fd ff ff       	call   801028e5 <outb>
80102b75:	83 c4 10             	add    $0x10,%esp
  }
}
80102b78:	90                   	nop
80102b79:	c9                   	leave  
80102b7a:	c3                   	ret    

80102b7b <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102b7b:	55                   	push   %ebp
80102b7c:	89 e5                	mov    %esp,%ebp
80102b7e:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102b81:	83 ec 0c             	sub    $0xc,%esp
80102b84:	68 40 d6 10 80       	push   $0x8010d640
80102b89:	e8 5b 3d 00 00       	call   801068e9 <acquire>
80102b8e:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102b91:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b9d:	75 15                	jne    80102bb4 <ideintr+0x39>
    release(&idelock);
80102b9f:	83 ec 0c             	sub    $0xc,%esp
80102ba2:	68 40 d6 10 80       	push   $0x8010d640
80102ba7:	e8 a4 3d 00 00       	call   80106950 <release>
80102bac:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102baf:	e9 9a 00 00 00       	jmp    80102c4e <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb7:	8b 40 14             	mov    0x14(%eax),%eax
80102bba:	a3 74 d6 10 80       	mov    %eax,0x8010d674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc2:	8b 00                	mov    (%eax),%eax
80102bc4:	83 e0 04             	and    $0x4,%eax
80102bc7:	85 c0                	test   %eax,%eax
80102bc9:	75 2d                	jne    80102bf8 <ideintr+0x7d>
80102bcb:	83 ec 0c             	sub    $0xc,%esp
80102bce:	6a 01                	push   $0x1
80102bd0:	e8 55 fd ff ff       	call   8010292a <idewait>
80102bd5:	83 c4 10             	add    $0x10,%esp
80102bd8:	85 c0                	test   %eax,%eax
80102bda:	78 1c                	js     80102bf8 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdf:	83 c0 18             	add    $0x18,%eax
80102be2:	83 ec 04             	sub    $0x4,%esp
80102be5:	68 80 00 00 00       	push   $0x80
80102bea:	50                   	push   %eax
80102beb:	68 f0 01 00 00       	push   $0x1f0
80102bf0:	e8 ca fc ff ff       	call   801028bf <insl>
80102bf5:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfb:	8b 00                	mov    (%eax),%eax
80102bfd:	83 c8 02             	or     $0x2,%eax
80102c00:	89 c2                	mov    %eax,%edx
80102c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c05:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0a:	8b 00                	mov    (%eax),%eax
80102c0c:	83 e0 fb             	and    $0xfffffffb,%eax
80102c0f:	89 c2                	mov    %eax,%edx
80102c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c14:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102c16:	83 ec 0c             	sub    $0xc,%esp
80102c19:	ff 75 f4             	pushl  -0xc(%ebp)
80102c1c:	e8 54 2e 00 00       	call   80105a75 <wakeup>
80102c21:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102c24:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102c29:	85 c0                	test   %eax,%eax
80102c2b:	74 11                	je     80102c3e <ideintr+0xc3>
    idestart(idequeue);
80102c2d:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102c32:	83 ec 0c             	sub    $0xc,%esp
80102c35:	50                   	push   %eax
80102c36:	e8 e2 fd ff ff       	call   80102a1d <idestart>
80102c3b:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102c3e:	83 ec 0c             	sub    $0xc,%esp
80102c41:	68 40 d6 10 80       	push   $0x8010d640
80102c46:	e8 05 3d 00 00       	call   80106950 <release>
80102c4b:	83 c4 10             	add    $0x10,%esp
}
80102c4e:	c9                   	leave  
80102c4f:	c3                   	ret    

80102c50 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102c50:	55                   	push   %ebp
80102c51:	89 e5                	mov    %esp,%ebp
80102c53:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102c56:	8b 45 08             	mov    0x8(%ebp),%eax
80102c59:	8b 00                	mov    (%eax),%eax
80102c5b:	83 e0 01             	and    $0x1,%eax
80102c5e:	85 c0                	test   %eax,%eax
80102c60:	75 0d                	jne    80102c6f <iderw+0x1f>
    panic("iderw: buf not busy");
80102c62:	83 ec 0c             	sub    $0xc,%esp
80102c65:	68 a9 a2 10 80       	push   $0x8010a2a9
80102c6a:	e8 f7 d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c72:	8b 00                	mov    (%eax),%eax
80102c74:	83 e0 06             	and    $0x6,%eax
80102c77:	83 f8 02             	cmp    $0x2,%eax
80102c7a:	75 0d                	jne    80102c89 <iderw+0x39>
    panic("iderw: nothing to do");
80102c7c:	83 ec 0c             	sub    $0xc,%esp
80102c7f:	68 bd a2 10 80       	push   $0x8010a2bd
80102c84:	e8 dd d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102c89:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8c:	8b 40 04             	mov    0x4(%eax),%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 16                	je     80102ca9 <iderw+0x59>
80102c93:	a1 78 d6 10 80       	mov    0x8010d678,%eax
80102c98:	85 c0                	test   %eax,%eax
80102c9a:	75 0d                	jne    80102ca9 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102c9c:	83 ec 0c             	sub    $0xc,%esp
80102c9f:	68 d2 a2 10 80       	push   $0x8010a2d2
80102ca4:	e8 bd d8 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ca9:	83 ec 0c             	sub    $0xc,%esp
80102cac:	68 40 d6 10 80       	push   $0x8010d640
80102cb1:	e8 33 3c 00 00       	call   801068e9 <acquire>
80102cb6:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102cc3:	c7 45 f4 74 d6 10 80 	movl   $0x8010d674,-0xc(%ebp)
80102cca:	eb 0b                	jmp    80102cd7 <iderw+0x87>
80102ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccf:	8b 00                	mov    (%eax),%eax
80102cd1:	83 c0 14             	add    $0x14,%eax
80102cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cda:	8b 00                	mov    (%eax),%eax
80102cdc:	85 c0                	test   %eax,%eax
80102cde:	75 ec                	jne    80102ccc <iderw+0x7c>
    ;
  *pp = b;
80102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce6:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102ce8:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102ced:	3b 45 08             	cmp    0x8(%ebp),%eax
80102cf0:	75 23                	jne    80102d15 <iderw+0xc5>
    idestart(b);
80102cf2:	83 ec 0c             	sub    $0xc,%esp
80102cf5:	ff 75 08             	pushl  0x8(%ebp)
80102cf8:	e8 20 fd ff ff       	call   80102a1d <idestart>
80102cfd:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d00:	eb 13                	jmp    80102d15 <iderw+0xc5>
    sleep(b, &idelock);
80102d02:	83 ec 08             	sub    $0x8,%esp
80102d05:	68 40 d6 10 80       	push   $0x8010d640
80102d0a:	ff 75 08             	pushl  0x8(%ebp)
80102d0d:	e8 3f 2b 00 00       	call   80105851 <sleep>
80102d12:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d15:	8b 45 08             	mov    0x8(%ebp),%eax
80102d18:	8b 00                	mov    (%eax),%eax
80102d1a:	83 e0 06             	and    $0x6,%eax
80102d1d:	83 f8 02             	cmp    $0x2,%eax
80102d20:	75 e0                	jne    80102d02 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102d22:	83 ec 0c             	sub    $0xc,%esp
80102d25:	68 40 d6 10 80       	push   $0x8010d640
80102d2a:	e8 21 3c 00 00       	call   80106950 <release>
80102d2f:	83 c4 10             	add    $0x10,%esp
}
80102d32:	90                   	nop
80102d33:	c9                   	leave  
80102d34:	c3                   	ret    

80102d35 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102d35:	55                   	push   %ebp
80102d36:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d38:	a1 54 42 11 80       	mov    0x80114254,%eax
80102d3d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d40:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102d42:	a1 54 42 11 80       	mov    0x80114254,%eax
80102d47:	8b 40 10             	mov    0x10(%eax),%eax
}
80102d4a:	5d                   	pop    %ebp
80102d4b:	c3                   	ret    

80102d4c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102d4c:	55                   	push   %ebp
80102d4d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d4f:	a1 54 42 11 80       	mov    0x80114254,%eax
80102d54:	8b 55 08             	mov    0x8(%ebp),%edx
80102d57:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102d59:	a1 54 42 11 80       	mov    0x80114254,%eax
80102d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102d61:	89 50 10             	mov    %edx,0x10(%eax)
}
80102d64:	90                   	nop
80102d65:	5d                   	pop    %ebp
80102d66:	c3                   	ret    

80102d67 <ioapicinit>:

void
ioapicinit(void)
{
80102d67:	55                   	push   %ebp
80102d68:	89 e5                	mov    %esp,%ebp
80102d6a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102d6d:	a1 84 43 11 80       	mov    0x80114384,%eax
80102d72:	85 c0                	test   %eax,%eax
80102d74:	0f 84 a0 00 00 00    	je     80102e1a <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102d7a:	c7 05 54 42 11 80 00 	movl   $0xfec00000,0x80114254
80102d81:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102d84:	6a 01                	push   $0x1
80102d86:	e8 aa ff ff ff       	call   80102d35 <ioapicread>
80102d8b:	83 c4 04             	add    $0x4,%esp
80102d8e:	c1 e8 10             	shr    $0x10,%eax
80102d91:	25 ff 00 00 00       	and    $0xff,%eax
80102d96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102d99:	6a 00                	push   $0x0
80102d9b:	e8 95 ff ff ff       	call   80102d35 <ioapicread>
80102da0:	83 c4 04             	add    $0x4,%esp
80102da3:	c1 e8 18             	shr    $0x18,%eax
80102da6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102da9:	0f b6 05 80 43 11 80 	movzbl 0x80114380,%eax
80102db0:	0f b6 c0             	movzbl %al,%eax
80102db3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102db6:	74 10                	je     80102dc8 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102db8:	83 ec 0c             	sub    $0xc,%esp
80102dbb:	68 f0 a2 10 80       	push   $0x8010a2f0
80102dc0:	e8 01 d6 ff ff       	call   801003c6 <cprintf>
80102dc5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102dcf:	eb 3f                	jmp    80102e10 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dd4:	83 c0 20             	add    $0x20,%eax
80102dd7:	0d 00 00 01 00       	or     $0x10000,%eax
80102ddc:	89 c2                	mov    %eax,%edx
80102dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102de1:	83 c0 08             	add    $0x8,%eax
80102de4:	01 c0                	add    %eax,%eax
80102de6:	83 ec 08             	sub    $0x8,%esp
80102de9:	52                   	push   %edx
80102dea:	50                   	push   %eax
80102deb:	e8 5c ff ff ff       	call   80102d4c <ioapicwrite>
80102df0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102df6:	83 c0 08             	add    $0x8,%eax
80102df9:	01 c0                	add    %eax,%eax
80102dfb:	83 c0 01             	add    $0x1,%eax
80102dfe:	83 ec 08             	sub    $0x8,%esp
80102e01:	6a 00                	push   $0x0
80102e03:	50                   	push   %eax
80102e04:	e8 43 ff ff ff       	call   80102d4c <ioapicwrite>
80102e09:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e13:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102e16:	7e b9                	jle    80102dd1 <ioapicinit+0x6a>
80102e18:	eb 01                	jmp    80102e1b <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102e1a:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102e20:	a1 84 43 11 80       	mov    0x80114384,%eax
80102e25:	85 c0                	test   %eax,%eax
80102e27:	74 39                	je     80102e62 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102e29:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2c:	83 c0 20             	add    $0x20,%eax
80102e2f:	89 c2                	mov    %eax,%edx
80102e31:	8b 45 08             	mov    0x8(%ebp),%eax
80102e34:	83 c0 08             	add    $0x8,%eax
80102e37:	01 c0                	add    %eax,%eax
80102e39:	52                   	push   %edx
80102e3a:	50                   	push   %eax
80102e3b:	e8 0c ff ff ff       	call   80102d4c <ioapicwrite>
80102e40:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e46:	c1 e0 18             	shl    $0x18,%eax
80102e49:	89 c2                	mov    %eax,%edx
80102e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4e:	83 c0 08             	add    $0x8,%eax
80102e51:	01 c0                	add    %eax,%eax
80102e53:	83 c0 01             	add    $0x1,%eax
80102e56:	52                   	push   %edx
80102e57:	50                   	push   %eax
80102e58:	e8 ef fe ff ff       	call   80102d4c <ioapicwrite>
80102e5d:	83 c4 08             	add    $0x8,%esp
80102e60:	eb 01                	jmp    80102e63 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102e62:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102e63:	c9                   	leave  
80102e64:	c3                   	ret    

80102e65 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102e65:	55                   	push   %ebp
80102e66:	89 e5                	mov    %esp,%ebp
80102e68:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6b:	05 00 00 00 80       	add    $0x80000000,%eax
80102e70:	5d                   	pop    %ebp
80102e71:	c3                   	ret    

80102e72 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102e72:	55                   	push   %ebp
80102e73:	89 e5                	mov    %esp,%ebp
80102e75:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102e78:	83 ec 08             	sub    $0x8,%esp
80102e7b:	68 22 a3 10 80       	push   $0x8010a322
80102e80:	68 60 42 11 80       	push   $0x80114260
80102e85:	e8 3d 3a 00 00       	call   801068c7 <initlock>
80102e8a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102e8d:	c7 05 94 42 11 80 00 	movl   $0x0,0x80114294
80102e94:	00 00 00 
  freerange(vstart, vend);
80102e97:	83 ec 08             	sub    $0x8,%esp
80102e9a:	ff 75 0c             	pushl  0xc(%ebp)
80102e9d:	ff 75 08             	pushl  0x8(%ebp)
80102ea0:	e8 2a 00 00 00       	call   80102ecf <freerange>
80102ea5:	83 c4 10             	add    $0x10,%esp
}
80102ea8:	90                   	nop
80102ea9:	c9                   	leave  
80102eaa:	c3                   	ret    

80102eab <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102eab:	55                   	push   %ebp
80102eac:	89 e5                	mov    %esp,%ebp
80102eae:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102eb1:	83 ec 08             	sub    $0x8,%esp
80102eb4:	ff 75 0c             	pushl  0xc(%ebp)
80102eb7:	ff 75 08             	pushl  0x8(%ebp)
80102eba:	e8 10 00 00 00       	call   80102ecf <freerange>
80102ebf:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ec2:	c7 05 94 42 11 80 01 	movl   $0x1,0x80114294
80102ec9:	00 00 00 
}
80102ecc:	90                   	nop
80102ecd:	c9                   	leave  
80102ece:	c3                   	ret    

80102ecf <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ecf:	55                   	push   %ebp
80102ed0:	89 e5                	mov    %esp,%ebp
80102ed2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed8:	05 ff 0f 00 00       	add    $0xfff,%eax
80102edd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ee5:	eb 15                	jmp    80102efc <freerange+0x2d>
    kfree(p);
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	ff 75 f4             	pushl  -0xc(%ebp)
80102eed:	e8 1a 00 00 00       	call   80102f0c <kfree>
80102ef2:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ef5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eff:	05 00 10 00 00       	add    $0x1000,%eax
80102f04:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102f07:	76 de                	jbe    80102ee7 <freerange+0x18>
    kfree(p);
}
80102f09:	90                   	nop
80102f0a:	c9                   	leave  
80102f0b:	c3                   	ret    

80102f0c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102f0c:	55                   	push   %ebp
80102f0d:	89 e5                	mov    %esp,%ebp
80102f0f:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102f12:	8b 45 08             	mov    0x8(%ebp),%eax
80102f15:	25 ff 0f 00 00       	and    $0xfff,%eax
80102f1a:	85 c0                	test   %eax,%eax
80102f1c:	75 1b                	jne    80102f39 <kfree+0x2d>
80102f1e:	81 7d 08 7c 79 11 80 	cmpl   $0x8011797c,0x8(%ebp)
80102f25:	72 12                	jb     80102f39 <kfree+0x2d>
80102f27:	ff 75 08             	pushl  0x8(%ebp)
80102f2a:	e8 36 ff ff ff       	call   80102e65 <v2p>
80102f2f:	83 c4 04             	add    $0x4,%esp
80102f32:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102f37:	76 0d                	jbe    80102f46 <kfree+0x3a>
    panic("kfree");
80102f39:	83 ec 0c             	sub    $0xc,%esp
80102f3c:	68 27 a3 10 80       	push   $0x8010a327
80102f41:	e8 20 d6 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102f46:	83 ec 04             	sub    $0x4,%esp
80102f49:	68 00 10 00 00       	push   $0x1000
80102f4e:	6a 01                	push   $0x1
80102f50:	ff 75 08             	pushl  0x8(%ebp)
80102f53:	e8 f4 3b 00 00       	call   80106b4c <memset>
80102f58:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102f5b:	a1 94 42 11 80       	mov    0x80114294,%eax
80102f60:	85 c0                	test   %eax,%eax
80102f62:	74 10                	je     80102f74 <kfree+0x68>
    acquire(&kmem.lock);
80102f64:	83 ec 0c             	sub    $0xc,%esp
80102f67:	68 60 42 11 80       	push   $0x80114260
80102f6c:	e8 78 39 00 00       	call   801068e9 <acquire>
80102f71:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102f74:	8b 45 08             	mov    0x8(%ebp),%eax
80102f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102f7a:	8b 15 98 42 11 80    	mov    0x80114298,%edx
80102f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f83:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f88:	a3 98 42 11 80       	mov    %eax,0x80114298
  if(kmem.use_lock)
80102f8d:	a1 94 42 11 80       	mov    0x80114294,%eax
80102f92:	85 c0                	test   %eax,%eax
80102f94:	74 10                	je     80102fa6 <kfree+0x9a>
    release(&kmem.lock);
80102f96:	83 ec 0c             	sub    $0xc,%esp
80102f99:	68 60 42 11 80       	push   $0x80114260
80102f9e:	e8 ad 39 00 00       	call   80106950 <release>
80102fa3:	83 c4 10             	add    $0x10,%esp
}
80102fa6:	90                   	nop
80102fa7:	c9                   	leave  
80102fa8:	c3                   	ret    

80102fa9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102fa9:	55                   	push   %ebp
80102faa:	89 e5                	mov    %esp,%ebp
80102fac:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102faf:	a1 94 42 11 80       	mov    0x80114294,%eax
80102fb4:	85 c0                	test   %eax,%eax
80102fb6:	74 10                	je     80102fc8 <kalloc+0x1f>
    acquire(&kmem.lock);
80102fb8:	83 ec 0c             	sub    $0xc,%esp
80102fbb:	68 60 42 11 80       	push   $0x80114260
80102fc0:	e8 24 39 00 00       	call   801068e9 <acquire>
80102fc5:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102fc8:	a1 98 42 11 80       	mov    0x80114298,%eax
80102fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102fd4:	74 0a                	je     80102fe0 <kalloc+0x37>
    kmem.freelist = r->next;
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	8b 00                	mov    (%eax),%eax
80102fdb:	a3 98 42 11 80       	mov    %eax,0x80114298
  if(kmem.use_lock)
80102fe0:	a1 94 42 11 80       	mov    0x80114294,%eax
80102fe5:	85 c0                	test   %eax,%eax
80102fe7:	74 10                	je     80102ff9 <kalloc+0x50>
    release(&kmem.lock);
80102fe9:	83 ec 0c             	sub    $0xc,%esp
80102fec:	68 60 42 11 80       	push   $0x80114260
80102ff1:	e8 5a 39 00 00       	call   80106950 <release>
80102ff6:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ffc:	c9                   	leave  
80102ffd:	c3                   	ret    

80102ffe <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102ffe:	55                   	push   %ebp
80102fff:	89 e5                	mov    %esp,%ebp
80103001:	83 ec 14             	sub    $0x14,%esp
80103004:	8b 45 08             	mov    0x8(%ebp),%eax
80103007:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010300b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010300f:	89 c2                	mov    %eax,%edx
80103011:	ec                   	in     (%dx),%al
80103012:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103015:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103021:	6a 64                	push   $0x64
80103023:	e8 d6 ff ff ff       	call   80102ffe <inb>
80103028:	83 c4 04             	add    $0x4,%esp
8010302b:	0f b6 c0             	movzbl %al,%eax
8010302e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103034:	83 e0 01             	and    $0x1,%eax
80103037:	85 c0                	test   %eax,%eax
80103039:	75 0a                	jne    80103045 <kbdgetc+0x2a>
    return -1;
8010303b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103040:	e9 23 01 00 00       	jmp    80103168 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103045:	6a 60                	push   $0x60
80103047:	e8 b2 ff ff ff       	call   80102ffe <inb>
8010304c:	83 c4 04             	add    $0x4,%esp
8010304f:	0f b6 c0             	movzbl %al,%eax
80103052:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103055:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010305c:	75 17                	jne    80103075 <kbdgetc+0x5a>
    shift |= E0ESC;
8010305e:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103063:	83 c8 40             	or     $0x40,%eax
80103066:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
    return 0;
8010306b:	b8 00 00 00 00       	mov    $0x0,%eax
80103070:	e9 f3 00 00 00       	jmp    80103168 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103075:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103078:	25 80 00 00 00       	and    $0x80,%eax
8010307d:	85 c0                	test   %eax,%eax
8010307f:	74 45                	je     801030c6 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103081:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103086:	83 e0 40             	and    $0x40,%eax
80103089:	85 c0                	test   %eax,%eax
8010308b:	75 08                	jne    80103095 <kbdgetc+0x7a>
8010308d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103090:	83 e0 7f             	and    $0x7f,%eax
80103093:	eb 03                	jmp    80103098 <kbdgetc+0x7d>
80103095:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103098:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010309b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010309e:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030a3:	0f b6 00             	movzbl (%eax),%eax
801030a6:	83 c8 40             	or     $0x40,%eax
801030a9:	0f b6 c0             	movzbl %al,%eax
801030ac:	f7 d0                	not    %eax
801030ae:	89 c2                	mov    %eax,%edx
801030b0:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030b5:	21 d0                	and    %edx,%eax
801030b7:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
    return 0;
801030bc:	b8 00 00 00 00       	mov    $0x0,%eax
801030c1:	e9 a2 00 00 00       	jmp    80103168 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801030c6:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030cb:	83 e0 40             	and    $0x40,%eax
801030ce:	85 c0                	test   %eax,%eax
801030d0:	74 14                	je     801030e6 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801030d2:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801030d9:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030de:	83 e0 bf             	and    $0xffffffbf,%eax
801030e1:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  }

  shift |= shiftcode[data];
801030e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030e9:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030ee:	0f b6 00             	movzbl (%eax),%eax
801030f1:	0f b6 d0             	movzbl %al,%edx
801030f4:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030f9:	09 d0                	or     %edx,%eax
801030fb:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  shift ^= togglecode[data];
80103100:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103103:	05 20 b1 10 80       	add    $0x8010b120,%eax
80103108:	0f b6 00             	movzbl (%eax),%eax
8010310b:	0f b6 d0             	movzbl %al,%edx
8010310e:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103113:	31 d0                	xor    %edx,%eax
80103115:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  c = charcode[shift & (CTL | SHIFT)][data];
8010311a:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
8010311f:	83 e0 03             	and    $0x3,%eax
80103122:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103129:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010312c:	01 d0                	add    %edx,%eax
8010312e:	0f b6 00             	movzbl (%eax),%eax
80103131:	0f b6 c0             	movzbl %al,%eax
80103134:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103137:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
8010313c:	83 e0 08             	and    $0x8,%eax
8010313f:	85 c0                	test   %eax,%eax
80103141:	74 22                	je     80103165 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103143:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103147:	76 0c                	jbe    80103155 <kbdgetc+0x13a>
80103149:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010314d:	77 06                	ja     80103155 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010314f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103153:	eb 10                	jmp    80103165 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103155:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103159:	76 0a                	jbe    80103165 <kbdgetc+0x14a>
8010315b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010315f:	77 04                	ja     80103165 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103161:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103165:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103168:	c9                   	leave  
80103169:	c3                   	ret    

8010316a <kbdintr>:

void
kbdintr(void)
{
8010316a:	55                   	push   %ebp
8010316b:	89 e5                	mov    %esp,%ebp
8010316d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103170:	83 ec 0c             	sub    $0xc,%esp
80103173:	68 1b 30 10 80       	push   $0x8010301b
80103178:	e8 7c d6 ff ff       	call   801007f9 <consoleintr>
8010317d:	83 c4 10             	add    $0x10,%esp
}
80103180:	90                   	nop
80103181:	c9                   	leave  
80103182:	c3                   	ret    

80103183 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103183:	55                   	push   %ebp
80103184:	89 e5                	mov    %esp,%ebp
80103186:	83 ec 14             	sub    $0x14,%esp
80103189:	8b 45 08             	mov    0x8(%ebp),%eax
8010318c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103190:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103194:	89 c2                	mov    %eax,%edx
80103196:	ec                   	in     (%dx),%al
80103197:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010319a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010319e:	c9                   	leave  
8010319f:	c3                   	ret    

801031a0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031a0:	55                   	push   %ebp
801031a1:	89 e5                	mov    %esp,%ebp
801031a3:	83 ec 08             	sub    $0x8,%esp
801031a6:	8b 55 08             	mov    0x8(%ebp),%edx
801031a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ac:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801031b0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801031b3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801031b7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801031bb:	ee                   	out    %al,(%dx)
}
801031bc:	90                   	nop
801031bd:	c9                   	leave  
801031be:	c3                   	ret    

801031bf <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801031bf:	55                   	push   %ebp
801031c0:	89 e5                	mov    %esp,%ebp
801031c2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031c5:	9c                   	pushf  
801031c6:	58                   	pop    %eax
801031c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801031ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801031cd:	c9                   	leave  
801031ce:	c3                   	ret    

801031cf <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801031cf:	55                   	push   %ebp
801031d0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801031d2:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801031d7:	8b 55 08             	mov    0x8(%ebp),%edx
801031da:	c1 e2 02             	shl    $0x2,%edx
801031dd:	01 c2                	add    %eax,%edx
801031df:	8b 45 0c             	mov    0xc(%ebp),%eax
801031e2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801031e4:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801031e9:	83 c0 20             	add    $0x20,%eax
801031ec:	8b 00                	mov    (%eax),%eax
}
801031ee:	90                   	nop
801031ef:	5d                   	pop    %ebp
801031f0:	c3                   	ret    

801031f1 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801031f1:	55                   	push   %ebp
801031f2:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801031f4:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801031f9:	85 c0                	test   %eax,%eax
801031fb:	0f 84 0b 01 00 00    	je     8010330c <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103201:	68 3f 01 00 00       	push   $0x13f
80103206:	6a 3c                	push   $0x3c
80103208:	e8 c2 ff ff ff       	call   801031cf <lapicw>
8010320d:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103210:	6a 0b                	push   $0xb
80103212:	68 f8 00 00 00       	push   $0xf8
80103217:	e8 b3 ff ff ff       	call   801031cf <lapicw>
8010321c:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010321f:	68 20 00 02 00       	push   $0x20020
80103224:	68 c8 00 00 00       	push   $0xc8
80103229:	e8 a1 ff ff ff       	call   801031cf <lapicw>
8010322e:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80103231:	68 40 42 0f 00       	push   $0xf4240
80103236:	68 e0 00 00 00       	push   $0xe0
8010323b:	e8 8f ff ff ff       	call   801031cf <lapicw>
80103240:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103243:	68 00 00 01 00       	push   $0x10000
80103248:	68 d4 00 00 00       	push   $0xd4
8010324d:	e8 7d ff ff ff       	call   801031cf <lapicw>
80103252:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103255:	68 00 00 01 00       	push   $0x10000
8010325a:	68 d8 00 00 00       	push   $0xd8
8010325f:	e8 6b ff ff ff       	call   801031cf <lapicw>
80103264:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103267:	a1 9c 42 11 80       	mov    0x8011429c,%eax
8010326c:	83 c0 30             	add    $0x30,%eax
8010326f:	8b 00                	mov    (%eax),%eax
80103271:	c1 e8 10             	shr    $0x10,%eax
80103274:	0f b6 c0             	movzbl %al,%eax
80103277:	83 f8 03             	cmp    $0x3,%eax
8010327a:	76 12                	jbe    8010328e <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010327c:	68 00 00 01 00       	push   $0x10000
80103281:	68 d0 00 00 00       	push   $0xd0
80103286:	e8 44 ff ff ff       	call   801031cf <lapicw>
8010328b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010328e:	6a 33                	push   $0x33
80103290:	68 dc 00 00 00       	push   $0xdc
80103295:	e8 35 ff ff ff       	call   801031cf <lapicw>
8010329a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010329d:	6a 00                	push   $0x0
8010329f:	68 a0 00 00 00       	push   $0xa0
801032a4:	e8 26 ff ff ff       	call   801031cf <lapicw>
801032a9:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
801032ac:	6a 00                	push   $0x0
801032ae:	68 a0 00 00 00       	push   $0xa0
801032b3:	e8 17 ff ff ff       	call   801031cf <lapicw>
801032b8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801032bb:	6a 00                	push   $0x0
801032bd:	6a 2c                	push   $0x2c
801032bf:	e8 0b ff ff ff       	call   801031cf <lapicw>
801032c4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801032c7:	6a 00                	push   $0x0
801032c9:	68 c4 00 00 00       	push   $0xc4
801032ce:	e8 fc fe ff ff       	call   801031cf <lapicw>
801032d3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801032d6:	68 00 85 08 00       	push   $0x88500
801032db:	68 c0 00 00 00       	push   $0xc0
801032e0:	e8 ea fe ff ff       	call   801031cf <lapicw>
801032e5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801032e8:	90                   	nop
801032e9:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801032ee:	05 00 03 00 00       	add    $0x300,%eax
801032f3:	8b 00                	mov    (%eax),%eax
801032f5:	25 00 10 00 00       	and    $0x1000,%eax
801032fa:	85 c0                	test   %eax,%eax
801032fc:	75 eb                	jne    801032e9 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801032fe:	6a 00                	push   $0x0
80103300:	6a 20                	push   $0x20
80103302:	e8 c8 fe ff ff       	call   801031cf <lapicw>
80103307:	83 c4 08             	add    $0x8,%esp
8010330a:	eb 01                	jmp    8010330d <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010330c:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010330d:	c9                   	leave  
8010330e:	c3                   	ret    

8010330f <cpunum>:

int
cpunum(void)
{
8010330f:	55                   	push   %ebp
80103310:	89 e5                	mov    %esp,%ebp
80103312:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103315:	e8 a5 fe ff ff       	call   801031bf <readeflags>
8010331a:	25 00 02 00 00       	and    $0x200,%eax
8010331f:	85 c0                	test   %eax,%eax
80103321:	74 26                	je     80103349 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103323:	a1 80 d6 10 80       	mov    0x8010d680,%eax
80103328:	8d 50 01             	lea    0x1(%eax),%edx
8010332b:	89 15 80 d6 10 80    	mov    %edx,0x8010d680
80103331:	85 c0                	test   %eax,%eax
80103333:	75 14                	jne    80103349 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103335:	8b 45 04             	mov    0x4(%ebp),%eax
80103338:	83 ec 08             	sub    $0x8,%esp
8010333b:	50                   	push   %eax
8010333c:	68 30 a3 10 80       	push   $0x8010a330
80103341:	e8 80 d0 ff ff       	call   801003c6 <cprintf>
80103346:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103349:	a1 9c 42 11 80       	mov    0x8011429c,%eax
8010334e:	85 c0                	test   %eax,%eax
80103350:	74 0f                	je     80103361 <cpunum+0x52>
    return lapic[ID]>>24;
80103352:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103357:	83 c0 20             	add    $0x20,%eax
8010335a:	8b 00                	mov    (%eax),%eax
8010335c:	c1 e8 18             	shr    $0x18,%eax
8010335f:	eb 05                	jmp    80103366 <cpunum+0x57>
  return 0;
80103361:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103366:	c9                   	leave  
80103367:	c3                   	ret    

80103368 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103368:	55                   	push   %ebp
80103369:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010336b:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103370:	85 c0                	test   %eax,%eax
80103372:	74 0c                	je     80103380 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103374:	6a 00                	push   $0x0
80103376:	6a 2c                	push   $0x2c
80103378:	e8 52 fe ff ff       	call   801031cf <lapicw>
8010337d:	83 c4 08             	add    $0x8,%esp
}
80103380:	90                   	nop
80103381:	c9                   	leave  
80103382:	c3                   	ret    

80103383 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103383:	55                   	push   %ebp
80103384:	89 e5                	mov    %esp,%ebp
}
80103386:	90                   	nop
80103387:	5d                   	pop    %ebp
80103388:	c3                   	ret    

80103389 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103389:	55                   	push   %ebp
8010338a:	89 e5                	mov    %esp,%ebp
8010338c:	83 ec 14             	sub    $0x14,%esp
8010338f:	8b 45 08             	mov    0x8(%ebp),%eax
80103392:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103395:	6a 0f                	push   $0xf
80103397:	6a 70                	push   $0x70
80103399:	e8 02 fe ff ff       	call   801031a0 <outb>
8010339e:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801033a1:	6a 0a                	push   $0xa
801033a3:	6a 71                	push   $0x71
801033a5:	e8 f6 fd ff ff       	call   801031a0 <outb>
801033aa:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801033ad:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801033b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033b7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801033bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801033bf:	83 c0 02             	add    $0x2,%eax
801033c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801033c5:	c1 ea 04             	shr    $0x4,%edx
801033c8:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801033cb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801033cf:	c1 e0 18             	shl    $0x18,%eax
801033d2:	50                   	push   %eax
801033d3:	68 c4 00 00 00       	push   $0xc4
801033d8:	e8 f2 fd ff ff       	call   801031cf <lapicw>
801033dd:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801033e0:	68 00 c5 00 00       	push   $0xc500
801033e5:	68 c0 00 00 00       	push   $0xc0
801033ea:	e8 e0 fd ff ff       	call   801031cf <lapicw>
801033ef:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801033f2:	68 c8 00 00 00       	push   $0xc8
801033f7:	e8 87 ff ff ff       	call   80103383 <microdelay>
801033fc:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801033ff:	68 00 85 00 00       	push   $0x8500
80103404:	68 c0 00 00 00       	push   $0xc0
80103409:	e8 c1 fd ff ff       	call   801031cf <lapicw>
8010340e:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103411:	6a 64                	push   $0x64
80103413:	e8 6b ff ff ff       	call   80103383 <microdelay>
80103418:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010341b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103422:	eb 3d                	jmp    80103461 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103424:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103428:	c1 e0 18             	shl    $0x18,%eax
8010342b:	50                   	push   %eax
8010342c:	68 c4 00 00 00       	push   $0xc4
80103431:	e8 99 fd ff ff       	call   801031cf <lapicw>
80103436:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103439:	8b 45 0c             	mov    0xc(%ebp),%eax
8010343c:	c1 e8 0c             	shr    $0xc,%eax
8010343f:	80 cc 06             	or     $0x6,%ah
80103442:	50                   	push   %eax
80103443:	68 c0 00 00 00       	push   $0xc0
80103448:	e8 82 fd ff ff       	call   801031cf <lapicw>
8010344d:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103450:	68 c8 00 00 00       	push   $0xc8
80103455:	e8 29 ff ff ff       	call   80103383 <microdelay>
8010345a:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010345d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103461:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103465:	7e bd                	jle    80103424 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103467:	90                   	nop
80103468:	c9                   	leave  
80103469:	c3                   	ret    

8010346a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010346a:	55                   	push   %ebp
8010346b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010346d:	8b 45 08             	mov    0x8(%ebp),%eax
80103470:	0f b6 c0             	movzbl %al,%eax
80103473:	50                   	push   %eax
80103474:	6a 70                	push   $0x70
80103476:	e8 25 fd ff ff       	call   801031a0 <outb>
8010347b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010347e:	68 c8 00 00 00       	push   $0xc8
80103483:	e8 fb fe ff ff       	call   80103383 <microdelay>
80103488:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010348b:	6a 71                	push   $0x71
8010348d:	e8 f1 fc ff ff       	call   80103183 <inb>
80103492:	83 c4 04             	add    $0x4,%esp
80103495:	0f b6 c0             	movzbl %al,%eax
}
80103498:	c9                   	leave  
80103499:	c3                   	ret    

8010349a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010349a:	55                   	push   %ebp
8010349b:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010349d:	6a 00                	push   $0x0
8010349f:	e8 c6 ff ff ff       	call   8010346a <cmos_read>
801034a4:	83 c4 04             	add    $0x4,%esp
801034a7:	89 c2                	mov    %eax,%edx
801034a9:	8b 45 08             	mov    0x8(%ebp),%eax
801034ac:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801034ae:	6a 02                	push   $0x2
801034b0:	e8 b5 ff ff ff       	call   8010346a <cmos_read>
801034b5:	83 c4 04             	add    $0x4,%esp
801034b8:	89 c2                	mov    %eax,%edx
801034ba:	8b 45 08             	mov    0x8(%ebp),%eax
801034bd:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801034c0:	6a 04                	push   $0x4
801034c2:	e8 a3 ff ff ff       	call   8010346a <cmos_read>
801034c7:	83 c4 04             	add    $0x4,%esp
801034ca:	89 c2                	mov    %eax,%edx
801034cc:	8b 45 08             	mov    0x8(%ebp),%eax
801034cf:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801034d2:	6a 07                	push   $0x7
801034d4:	e8 91 ff ff ff       	call   8010346a <cmos_read>
801034d9:	83 c4 04             	add    $0x4,%esp
801034dc:	89 c2                	mov    %eax,%edx
801034de:	8b 45 08             	mov    0x8(%ebp),%eax
801034e1:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801034e4:	6a 08                	push   $0x8
801034e6:	e8 7f ff ff ff       	call   8010346a <cmos_read>
801034eb:	83 c4 04             	add    $0x4,%esp
801034ee:	89 c2                	mov    %eax,%edx
801034f0:	8b 45 08             	mov    0x8(%ebp),%eax
801034f3:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801034f6:	6a 09                	push   $0x9
801034f8:	e8 6d ff ff ff       	call   8010346a <cmos_read>
801034fd:	83 c4 04             	add    $0x4,%esp
80103500:	89 c2                	mov    %eax,%edx
80103502:	8b 45 08             	mov    0x8(%ebp),%eax
80103505:	89 50 14             	mov    %edx,0x14(%eax)
}
80103508:	90                   	nop
80103509:	c9                   	leave  
8010350a:	c3                   	ret    

8010350b <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010350b:	55                   	push   %ebp
8010350c:	89 e5                	mov    %esp,%ebp
8010350e:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103511:	6a 0b                	push   $0xb
80103513:	e8 52 ff ff ff       	call   8010346a <cmos_read>
80103518:	83 c4 04             	add    $0x4,%esp
8010351b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010351e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103521:	83 e0 04             	and    $0x4,%eax
80103524:	85 c0                	test   %eax,%eax
80103526:	0f 94 c0             	sete   %al
80103529:	0f b6 c0             	movzbl %al,%eax
8010352c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010352f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103532:	50                   	push   %eax
80103533:	e8 62 ff ff ff       	call   8010349a <fill_rtcdate>
80103538:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010353b:	6a 0a                	push   $0xa
8010353d:	e8 28 ff ff ff       	call   8010346a <cmos_read>
80103542:	83 c4 04             	add    $0x4,%esp
80103545:	25 80 00 00 00       	and    $0x80,%eax
8010354a:	85 c0                	test   %eax,%eax
8010354c:	75 27                	jne    80103575 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010354e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103551:	50                   	push   %eax
80103552:	e8 43 ff ff ff       	call   8010349a <fill_rtcdate>
80103557:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010355a:	83 ec 04             	sub    $0x4,%esp
8010355d:	6a 18                	push   $0x18
8010355f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103562:	50                   	push   %eax
80103563:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103566:	50                   	push   %eax
80103567:	e8 47 36 00 00       	call   80106bb3 <memcmp>
8010356c:	83 c4 10             	add    $0x10,%esp
8010356f:	85 c0                	test   %eax,%eax
80103571:	74 05                	je     80103578 <cmostime+0x6d>
80103573:	eb ba                	jmp    8010352f <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103575:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103576:	eb b7                	jmp    8010352f <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103578:	90                   	nop
  }

  // convert
  if (bcd) {
80103579:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010357d:	0f 84 b4 00 00 00    	je     80103637 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103583:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103586:	c1 e8 04             	shr    $0x4,%eax
80103589:	89 c2                	mov    %eax,%edx
8010358b:	89 d0                	mov    %edx,%eax
8010358d:	c1 e0 02             	shl    $0x2,%eax
80103590:	01 d0                	add    %edx,%eax
80103592:	01 c0                	add    %eax,%eax
80103594:	89 c2                	mov    %eax,%edx
80103596:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103599:	83 e0 0f             	and    $0xf,%eax
8010359c:	01 d0                	add    %edx,%eax
8010359e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801035a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035a4:	c1 e8 04             	shr    $0x4,%eax
801035a7:	89 c2                	mov    %eax,%edx
801035a9:	89 d0                	mov    %edx,%eax
801035ab:	c1 e0 02             	shl    $0x2,%eax
801035ae:	01 d0                	add    %edx,%eax
801035b0:	01 c0                	add    %eax,%eax
801035b2:	89 c2                	mov    %eax,%edx
801035b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035b7:	83 e0 0f             	and    $0xf,%eax
801035ba:	01 d0                	add    %edx,%eax
801035bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801035bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801035c2:	c1 e8 04             	shr    $0x4,%eax
801035c5:	89 c2                	mov    %eax,%edx
801035c7:	89 d0                	mov    %edx,%eax
801035c9:	c1 e0 02             	shl    $0x2,%eax
801035cc:	01 d0                	add    %edx,%eax
801035ce:	01 c0                	add    %eax,%eax
801035d0:	89 c2                	mov    %eax,%edx
801035d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801035d5:	83 e0 0f             	and    $0xf,%eax
801035d8:	01 d0                	add    %edx,%eax
801035da:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801035dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801035e0:	c1 e8 04             	shr    $0x4,%eax
801035e3:	89 c2                	mov    %eax,%edx
801035e5:	89 d0                	mov    %edx,%eax
801035e7:	c1 e0 02             	shl    $0x2,%eax
801035ea:	01 d0                	add    %edx,%eax
801035ec:	01 c0                	add    %eax,%eax
801035ee:	89 c2                	mov    %eax,%edx
801035f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801035f3:	83 e0 0f             	and    $0xf,%eax
801035f6:	01 d0                	add    %edx,%eax
801035f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801035fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801035fe:	c1 e8 04             	shr    $0x4,%eax
80103601:	89 c2                	mov    %eax,%edx
80103603:	89 d0                	mov    %edx,%eax
80103605:	c1 e0 02             	shl    $0x2,%eax
80103608:	01 d0                	add    %edx,%eax
8010360a:	01 c0                	add    %eax,%eax
8010360c:	89 c2                	mov    %eax,%edx
8010360e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103611:	83 e0 0f             	and    $0xf,%eax
80103614:	01 d0                	add    %edx,%eax
80103616:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103619:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010361c:	c1 e8 04             	shr    $0x4,%eax
8010361f:	89 c2                	mov    %eax,%edx
80103621:	89 d0                	mov    %edx,%eax
80103623:	c1 e0 02             	shl    $0x2,%eax
80103626:	01 d0                	add    %edx,%eax
80103628:	01 c0                	add    %eax,%eax
8010362a:	89 c2                	mov    %eax,%edx
8010362c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010362f:	83 e0 0f             	and    $0xf,%eax
80103632:	01 d0                	add    %edx,%eax
80103634:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103637:	8b 45 08             	mov    0x8(%ebp),%eax
8010363a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010363d:	89 10                	mov    %edx,(%eax)
8010363f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103642:	89 50 04             	mov    %edx,0x4(%eax)
80103645:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103648:	89 50 08             	mov    %edx,0x8(%eax)
8010364b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010364e:	89 50 0c             	mov    %edx,0xc(%eax)
80103651:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103654:	89 50 10             	mov    %edx,0x10(%eax)
80103657:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010365a:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010365d:	8b 45 08             	mov    0x8(%ebp),%eax
80103660:	8b 40 14             	mov    0x14(%eax),%eax
80103663:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103669:	8b 45 08             	mov    0x8(%ebp),%eax
8010366c:	89 50 14             	mov    %edx,0x14(%eax)
}
8010366f:	90                   	nop
80103670:	c9                   	leave  
80103671:	c3                   	ret    

80103672 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103672:	55                   	push   %ebp
80103673:	89 e5                	mov    %esp,%ebp
80103675:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103678:	83 ec 08             	sub    $0x8,%esp
8010367b:	68 5c a3 10 80       	push   $0x8010a35c
80103680:	68 a0 42 11 80       	push   $0x801142a0
80103685:	e8 3d 32 00 00       	call   801068c7 <initlock>
8010368a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010368d:	83 ec 08             	sub    $0x8,%esp
80103690:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103693:	50                   	push   %eax
80103694:	ff 75 08             	pushl  0x8(%ebp)
80103697:	e8 1d de ff ff       	call   801014b9 <readsb>
8010369c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010369f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a2:	a3 d4 42 11 80       	mov    %eax,0x801142d4
  log.size = sb.nlog;
801036a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036aa:	a3 d8 42 11 80       	mov    %eax,0x801142d8
  log.dev = dev;
801036af:	8b 45 08             	mov    0x8(%ebp),%eax
801036b2:	a3 e4 42 11 80       	mov    %eax,0x801142e4
  recover_from_log();
801036b7:	e8 b2 01 00 00       	call   8010386e <recover_from_log>
}
801036bc:	90                   	nop
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036cc:	e9 95 00 00 00       	jmp    80103766 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801036d1:	8b 15 d4 42 11 80    	mov    0x801142d4,%edx
801036d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036da:	01 d0                	add    %edx,%eax
801036dc:	83 c0 01             	add    $0x1,%eax
801036df:	89 c2                	mov    %eax,%edx
801036e1:	a1 e4 42 11 80       	mov    0x801142e4,%eax
801036e6:	83 ec 08             	sub    $0x8,%esp
801036e9:	52                   	push   %edx
801036ea:	50                   	push   %eax
801036eb:	e8 c6 ca ff ff       	call   801001b6 <bread>
801036f0:	83 c4 10             	add    $0x10,%esp
801036f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801036f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036f9:	83 c0 10             	add    $0x10,%eax
801036fc:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
80103703:	89 c2                	mov    %eax,%edx
80103705:	a1 e4 42 11 80       	mov    0x801142e4,%eax
8010370a:	83 ec 08             	sub    $0x8,%esp
8010370d:	52                   	push   %edx
8010370e:	50                   	push   %eax
8010370f:	e8 a2 ca ff ff       	call   801001b6 <bread>
80103714:	83 c4 10             	add    $0x10,%esp
80103717:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010371a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010371d:	8d 50 18             	lea    0x18(%eax),%edx
80103720:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103723:	83 c0 18             	add    $0x18,%eax
80103726:	83 ec 04             	sub    $0x4,%esp
80103729:	68 00 02 00 00       	push   $0x200
8010372e:	52                   	push   %edx
8010372f:	50                   	push   %eax
80103730:	e8 d6 34 00 00       	call   80106c0b <memmove>
80103735:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103738:	83 ec 0c             	sub    $0xc,%esp
8010373b:	ff 75 ec             	pushl  -0x14(%ebp)
8010373e:	e8 ac ca ff ff       	call   801001ef <bwrite>
80103743:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103746:	83 ec 0c             	sub    $0xc,%esp
80103749:	ff 75 f0             	pushl  -0x10(%ebp)
8010374c:	e8 dd ca ff ff       	call   8010022e <brelse>
80103751:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103754:	83 ec 0c             	sub    $0xc,%esp
80103757:	ff 75 ec             	pushl  -0x14(%ebp)
8010375a:	e8 cf ca ff ff       	call   8010022e <brelse>
8010375f:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103762:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103766:	a1 e8 42 11 80       	mov    0x801142e8,%eax
8010376b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010376e:	0f 8f 5d ff ff ff    	jg     801036d1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103774:	90                   	nop
80103775:	c9                   	leave  
80103776:	c3                   	ret    

80103777 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103777:	55                   	push   %ebp
80103778:	89 e5                	mov    %esp,%ebp
8010377a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010377d:	a1 d4 42 11 80       	mov    0x801142d4,%eax
80103782:	89 c2                	mov    %eax,%edx
80103784:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103789:	83 ec 08             	sub    $0x8,%esp
8010378c:	52                   	push   %edx
8010378d:	50                   	push   %eax
8010378e:	e8 23 ca ff ff       	call   801001b6 <bread>
80103793:	83 c4 10             	add    $0x10,%esp
80103796:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010379c:	83 c0 18             	add    $0x18,%eax
8010379f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037a5:	8b 00                	mov    (%eax),%eax
801037a7:	a3 e8 42 11 80       	mov    %eax,0x801142e8
  for (i = 0; i < log.lh.n; i++) {
801037ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b3:	eb 1b                	jmp    801037d0 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
801037b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037bb:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801037bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c2:	83 c2 10             	add    $0x10,%edx
801037c5:	89 04 95 ac 42 11 80 	mov    %eax,-0x7feebd54(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801037cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d0:	a1 e8 42 11 80       	mov    0x801142e8,%eax
801037d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037d8:	7f db                	jg     801037b5 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801037da:	83 ec 0c             	sub    $0xc,%esp
801037dd:	ff 75 f0             	pushl  -0x10(%ebp)
801037e0:	e8 49 ca ff ff       	call   8010022e <brelse>
801037e5:	83 c4 10             	add    $0x10,%esp
}
801037e8:	90                   	nop
801037e9:	c9                   	leave  
801037ea:	c3                   	ret    

801037eb <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801037eb:	55                   	push   %ebp
801037ec:	89 e5                	mov    %esp,%ebp
801037ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801037f1:	a1 d4 42 11 80       	mov    0x801142d4,%eax
801037f6:	89 c2                	mov    %eax,%edx
801037f8:	a1 e4 42 11 80       	mov    0x801142e4,%eax
801037fd:	83 ec 08             	sub    $0x8,%esp
80103800:	52                   	push   %edx
80103801:	50                   	push   %eax
80103802:	e8 af c9 ff ff       	call   801001b6 <bread>
80103807:	83 c4 10             	add    $0x10,%esp
8010380a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010380d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103810:	83 c0 18             	add    $0x18,%eax
80103813:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103816:	8b 15 e8 42 11 80    	mov    0x801142e8,%edx
8010381c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010381f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103821:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103828:	eb 1b                	jmp    80103845 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010382a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010382d:	83 c0 10             	add    $0x10,%eax
80103830:	8b 0c 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%ecx
80103837:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010383a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010383d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103841:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103845:	a1 e8 42 11 80       	mov    0x801142e8,%eax
8010384a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010384d:	7f db                	jg     8010382a <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010384f:	83 ec 0c             	sub    $0xc,%esp
80103852:	ff 75 f0             	pushl  -0x10(%ebp)
80103855:	e8 95 c9 ff ff       	call   801001ef <bwrite>
8010385a:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010385d:	83 ec 0c             	sub    $0xc,%esp
80103860:	ff 75 f0             	pushl  -0x10(%ebp)
80103863:	e8 c6 c9 ff ff       	call   8010022e <brelse>
80103868:	83 c4 10             	add    $0x10,%esp
}
8010386b:	90                   	nop
8010386c:	c9                   	leave  
8010386d:	c3                   	ret    

8010386e <recover_from_log>:

static void
recover_from_log(void)
{
8010386e:	55                   	push   %ebp
8010386f:	89 e5                	mov    %esp,%ebp
80103871:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103874:	e8 fe fe ff ff       	call   80103777 <read_head>
  install_trans(); // if committed, copy from log to disk
80103879:	e8 41 fe ff ff       	call   801036bf <install_trans>
  log.lh.n = 0;
8010387e:	c7 05 e8 42 11 80 00 	movl   $0x0,0x801142e8
80103885:	00 00 00 
  write_head(); // clear the log
80103888:	e8 5e ff ff ff       	call   801037eb <write_head>
}
8010388d:	90                   	nop
8010388e:	c9                   	leave  
8010388f:	c3                   	ret    

80103890 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103896:	83 ec 0c             	sub    $0xc,%esp
80103899:	68 a0 42 11 80       	push   $0x801142a0
8010389e:	e8 46 30 00 00       	call   801068e9 <acquire>
801038a3:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801038a6:	a1 e0 42 11 80       	mov    0x801142e0,%eax
801038ab:	85 c0                	test   %eax,%eax
801038ad:	74 17                	je     801038c6 <begin_op+0x36>
      sleep(&log, &log.lock);
801038af:	83 ec 08             	sub    $0x8,%esp
801038b2:	68 a0 42 11 80       	push   $0x801142a0
801038b7:	68 a0 42 11 80       	push   $0x801142a0
801038bc:	e8 90 1f 00 00       	call   80105851 <sleep>
801038c1:	83 c4 10             	add    $0x10,%esp
801038c4:	eb e0                	jmp    801038a6 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801038c6:	8b 0d e8 42 11 80    	mov    0x801142e8,%ecx
801038cc:	a1 dc 42 11 80       	mov    0x801142dc,%eax
801038d1:	8d 50 01             	lea    0x1(%eax),%edx
801038d4:	89 d0                	mov    %edx,%eax
801038d6:	c1 e0 02             	shl    $0x2,%eax
801038d9:	01 d0                	add    %edx,%eax
801038db:	01 c0                	add    %eax,%eax
801038dd:	01 c8                	add    %ecx,%eax
801038df:	83 f8 1e             	cmp    $0x1e,%eax
801038e2:	7e 17                	jle    801038fb <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801038e4:	83 ec 08             	sub    $0x8,%esp
801038e7:	68 a0 42 11 80       	push   $0x801142a0
801038ec:	68 a0 42 11 80       	push   $0x801142a0
801038f1:	e8 5b 1f 00 00       	call   80105851 <sleep>
801038f6:	83 c4 10             	add    $0x10,%esp
801038f9:	eb ab                	jmp    801038a6 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801038fb:	a1 dc 42 11 80       	mov    0x801142dc,%eax
80103900:	83 c0 01             	add    $0x1,%eax
80103903:	a3 dc 42 11 80       	mov    %eax,0x801142dc
      release(&log.lock);
80103908:	83 ec 0c             	sub    $0xc,%esp
8010390b:	68 a0 42 11 80       	push   $0x801142a0
80103910:	e8 3b 30 00 00       	call   80106950 <release>
80103915:	83 c4 10             	add    $0x10,%esp
      break;
80103918:	90                   	nop
    }
  }
}
80103919:	90                   	nop
8010391a:	c9                   	leave  
8010391b:	c3                   	ret    

8010391c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010391c:	55                   	push   %ebp
8010391d:	89 e5                	mov    %esp,%ebp
8010391f:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103929:	83 ec 0c             	sub    $0xc,%esp
8010392c:	68 a0 42 11 80       	push   $0x801142a0
80103931:	e8 b3 2f 00 00       	call   801068e9 <acquire>
80103936:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103939:	a1 dc 42 11 80       	mov    0x801142dc,%eax
8010393e:	83 e8 01             	sub    $0x1,%eax
80103941:	a3 dc 42 11 80       	mov    %eax,0x801142dc
  if(log.committing)
80103946:	a1 e0 42 11 80       	mov    0x801142e0,%eax
8010394b:	85 c0                	test   %eax,%eax
8010394d:	74 0d                	je     8010395c <end_op+0x40>
    panic("log.committing");
8010394f:	83 ec 0c             	sub    $0xc,%esp
80103952:	68 60 a3 10 80       	push   $0x8010a360
80103957:	e8 0a cc ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
8010395c:	a1 dc 42 11 80       	mov    0x801142dc,%eax
80103961:	85 c0                	test   %eax,%eax
80103963:	75 13                	jne    80103978 <end_op+0x5c>
    do_commit = 1;
80103965:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010396c:	c7 05 e0 42 11 80 01 	movl   $0x1,0x801142e0
80103973:	00 00 00 
80103976:	eb 10                	jmp    80103988 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103978:	83 ec 0c             	sub    $0xc,%esp
8010397b:	68 a0 42 11 80       	push   $0x801142a0
80103980:	e8 f0 20 00 00       	call   80105a75 <wakeup>
80103985:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103988:	83 ec 0c             	sub    $0xc,%esp
8010398b:	68 a0 42 11 80       	push   $0x801142a0
80103990:	e8 bb 2f 00 00       	call   80106950 <release>
80103995:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103998:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010399c:	74 3f                	je     801039dd <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010399e:	e8 f5 00 00 00       	call   80103a98 <commit>
    acquire(&log.lock);
801039a3:	83 ec 0c             	sub    $0xc,%esp
801039a6:	68 a0 42 11 80       	push   $0x801142a0
801039ab:	e8 39 2f 00 00       	call   801068e9 <acquire>
801039b0:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801039b3:	c7 05 e0 42 11 80 00 	movl   $0x0,0x801142e0
801039ba:	00 00 00 
    wakeup(&log);
801039bd:	83 ec 0c             	sub    $0xc,%esp
801039c0:	68 a0 42 11 80       	push   $0x801142a0
801039c5:	e8 ab 20 00 00       	call   80105a75 <wakeup>
801039ca:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801039cd:	83 ec 0c             	sub    $0xc,%esp
801039d0:	68 a0 42 11 80       	push   $0x801142a0
801039d5:	e8 76 2f 00 00       	call   80106950 <release>
801039da:	83 c4 10             	add    $0x10,%esp
  }
}
801039dd:	90                   	nop
801039de:	c9                   	leave  
801039df:	c3                   	ret    

801039e0 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801039e0:	55                   	push   %ebp
801039e1:	89 e5                	mov    %esp,%ebp
801039e3:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039ed:	e9 95 00 00 00       	jmp    80103a87 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801039f2:	8b 15 d4 42 11 80    	mov    0x801142d4,%edx
801039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fb:	01 d0                	add    %edx,%eax
801039fd:	83 c0 01             	add    $0x1,%eax
80103a00:	89 c2                	mov    %eax,%edx
80103a02:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103a07:	83 ec 08             	sub    $0x8,%esp
80103a0a:	52                   	push   %edx
80103a0b:	50                   	push   %eax
80103a0c:	e8 a5 c7 ff ff       	call   801001b6 <bread>
80103a11:	83 c4 10             	add    $0x10,%esp
80103a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1a:	83 c0 10             	add    $0x10,%eax
80103a1d:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
80103a24:	89 c2                	mov    %eax,%edx
80103a26:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103a2b:	83 ec 08             	sub    $0x8,%esp
80103a2e:	52                   	push   %edx
80103a2f:	50                   	push   %eax
80103a30:	e8 81 c7 ff ff       	call   801001b6 <bread>
80103a35:	83 c4 10             	add    $0x10,%esp
80103a38:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a3e:	8d 50 18             	lea    0x18(%eax),%edx
80103a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a44:	83 c0 18             	add    $0x18,%eax
80103a47:	83 ec 04             	sub    $0x4,%esp
80103a4a:	68 00 02 00 00       	push   $0x200
80103a4f:	52                   	push   %edx
80103a50:	50                   	push   %eax
80103a51:	e8 b5 31 00 00       	call   80106c0b <memmove>
80103a56:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103a59:	83 ec 0c             	sub    $0xc,%esp
80103a5c:	ff 75 f0             	pushl  -0x10(%ebp)
80103a5f:	e8 8b c7 ff ff       	call   801001ef <bwrite>
80103a64:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103a67:	83 ec 0c             	sub    $0xc,%esp
80103a6a:	ff 75 ec             	pushl  -0x14(%ebp)
80103a6d:	e8 bc c7 ff ff       	call   8010022e <brelse>
80103a72:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103a75:	83 ec 0c             	sub    $0xc,%esp
80103a78:	ff 75 f0             	pushl  -0x10(%ebp)
80103a7b:	e8 ae c7 ff ff       	call   8010022e <brelse>
80103a80:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a87:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103a8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a8f:	0f 8f 5d ff ff ff    	jg     801039f2 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103a95:	90                   	nop
80103a96:	c9                   	leave  
80103a97:	c3                   	ret    

80103a98 <commit>:

static void
commit()
{
80103a98:	55                   	push   %ebp
80103a99:	89 e5                	mov    %esp,%ebp
80103a9b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103a9e:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103aa3:	85 c0                	test   %eax,%eax
80103aa5:	7e 1e                	jle    80103ac5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103aa7:	e8 34 ff ff ff       	call   801039e0 <write_log>
    write_head();    // Write header to disk -- the real commit
80103aac:	e8 3a fd ff ff       	call   801037eb <write_head>
    install_trans(); // Now install writes to home locations
80103ab1:	e8 09 fc ff ff       	call   801036bf <install_trans>
    log.lh.n = 0; 
80103ab6:	c7 05 e8 42 11 80 00 	movl   $0x0,0x801142e8
80103abd:	00 00 00 
    write_head();    // Erase the transaction from the log
80103ac0:	e8 26 fd ff ff       	call   801037eb <write_head>
  }
}
80103ac5:	90                   	nop
80103ac6:	c9                   	leave  
80103ac7:	c3                   	ret    

80103ac8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ac8:	55                   	push   %ebp
80103ac9:	89 e5                	mov    %esp,%ebp
80103acb:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103ace:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103ad3:	83 f8 1d             	cmp    $0x1d,%eax
80103ad6:	7f 12                	jg     80103aea <log_write+0x22>
80103ad8:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103add:	8b 15 d8 42 11 80    	mov    0x801142d8,%edx
80103ae3:	83 ea 01             	sub    $0x1,%edx
80103ae6:	39 d0                	cmp    %edx,%eax
80103ae8:	7c 0d                	jl     80103af7 <log_write+0x2f>
    panic("too big a transaction");
80103aea:	83 ec 0c             	sub    $0xc,%esp
80103aed:	68 6f a3 10 80       	push   $0x8010a36f
80103af2:	e8 6f ca ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103af7:	a1 dc 42 11 80       	mov    0x801142dc,%eax
80103afc:	85 c0                	test   %eax,%eax
80103afe:	7f 0d                	jg     80103b0d <log_write+0x45>
    panic("log_write outside of trans");
80103b00:	83 ec 0c             	sub    $0xc,%esp
80103b03:	68 85 a3 10 80       	push   $0x8010a385
80103b08:	e8 59 ca ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103b0d:	83 ec 0c             	sub    $0xc,%esp
80103b10:	68 a0 42 11 80       	push   $0x801142a0
80103b15:	e8 cf 2d 00 00       	call   801068e9 <acquire>
80103b1a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103b1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b24:	eb 1d                	jmp    80103b43 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b29:	83 c0 10             	add    $0x10,%eax
80103b2c:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
80103b33:	89 c2                	mov    %eax,%edx
80103b35:	8b 45 08             	mov    0x8(%ebp),%eax
80103b38:	8b 40 08             	mov    0x8(%eax),%eax
80103b3b:	39 c2                	cmp    %eax,%edx
80103b3d:	74 10                	je     80103b4f <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b43:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103b48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b4b:	7f d9                	jg     80103b26 <log_write+0x5e>
80103b4d:	eb 01                	jmp    80103b50 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103b4f:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103b50:	8b 45 08             	mov    0x8(%ebp),%eax
80103b53:	8b 40 08             	mov    0x8(%eax),%eax
80103b56:	89 c2                	mov    %eax,%edx
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5b:	83 c0 10             	add    $0x10,%eax
80103b5e:	89 14 85 ac 42 11 80 	mov    %edx,-0x7feebd54(,%eax,4)
  if (i == log.lh.n)
80103b65:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103b6a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b6d:	75 0d                	jne    80103b7c <log_write+0xb4>
    log.lh.n++;
80103b6f:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103b74:	83 c0 01             	add    $0x1,%eax
80103b77:	a3 e8 42 11 80       	mov    %eax,0x801142e8
  b->flags |= B_DIRTY; // prevent eviction
80103b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7f:	8b 00                	mov    (%eax),%eax
80103b81:	83 c8 04             	or     $0x4,%eax
80103b84:	89 c2                	mov    %eax,%edx
80103b86:	8b 45 08             	mov    0x8(%ebp),%eax
80103b89:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	68 a0 42 11 80       	push   $0x801142a0
80103b93:	e8 b8 2d 00 00       	call   80106950 <release>
80103b98:	83 c4 10             	add    $0x10,%esp
}
80103b9b:	90                   	nop
80103b9c:	c9                   	leave  
80103b9d:	c3                   	ret    

80103b9e <v2p>:
80103b9e:	55                   	push   %ebp
80103b9f:	89 e5                	mov    %esp,%ebp
80103ba1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba4:	05 00 00 00 80       	add    $0x80000000,%eax
80103ba9:	5d                   	pop    %ebp
80103baa:	c3                   	ret    

80103bab <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103bab:	55                   	push   %ebp
80103bac:	89 e5                	mov    %esp,%ebp
80103bae:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb1:	05 00 00 00 80       	add    $0x80000000,%eax
80103bb6:	5d                   	pop    %ebp
80103bb7:	c3                   	ret    

80103bb8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103bb8:	55                   	push   %ebp
80103bb9:	89 e5                	mov    %esp,%ebp
80103bbb:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103bbe:	8b 55 08             	mov    0x8(%ebp),%edx
80103bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103bc7:	f0 87 02             	lock xchg %eax,(%edx)
80103bca:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103bd0:	c9                   	leave  
80103bd1:	c3                   	ret    

80103bd2 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103bd2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103bd6:	83 e4 f0             	and    $0xfffffff0,%esp
80103bd9:	ff 71 fc             	pushl  -0x4(%ecx)
80103bdc:	55                   	push   %ebp
80103bdd:	89 e5                	mov    %esp,%ebp
80103bdf:	51                   	push   %ecx
80103be0:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103be3:	83 ec 08             	sub    $0x8,%esp
80103be6:	68 00 00 40 80       	push   $0x80400000
80103beb:	68 7c 79 11 80       	push   $0x8011797c
80103bf0:	e8 7d f2 ff ff       	call   80102e72 <kinit1>
80103bf5:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103bf8:	e8 70 5d 00 00       	call   8010996d <kvmalloc>
  mpinit();        // collect info about this machine
80103bfd:	e8 43 04 00 00       	call   80104045 <mpinit>
  lapicinit();
80103c02:	e8 ea f5 ff ff       	call   801031f1 <lapicinit>
  seginit();       // set up segments
80103c07:	e8 0a 57 00 00       	call   80109316 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103c0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c12:	0f b6 00             	movzbl (%eax),%eax
80103c15:	0f b6 c0             	movzbl %al,%eax
80103c18:	83 ec 08             	sub    $0x8,%esp
80103c1b:	50                   	push   %eax
80103c1c:	68 a0 a3 10 80       	push   $0x8010a3a0
80103c21:	e8 a0 c7 ff ff       	call   801003c6 <cprintf>
80103c26:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103c29:	e8 6d 06 00 00       	call   8010429b <picinit>
  ioapicinit();    // another interrupt controller
80103c2e:	e8 34 f1 ff ff       	call   80102d67 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103c33:	e8 7f cf ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103c38:	e8 35 4a 00 00       	call   80108672 <uartinit>
  pinit();         // process table
80103c3d:	e8 5d 0b 00 00       	call   8010479f <pinit>
  tvinit();        // trap vectors
80103c42:	e8 04 46 00 00       	call   8010824b <tvinit>
  binit();         // buffer cache
80103c47:	e8 e8 c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103c4c:	e8 59 d4 ff ff       	call   801010aa <fileinit>
  ideinit();       // disk
80103c51:	e8 19 ed ff ff       	call   8010296f <ideinit>
  if(!ismp)
80103c56:	a1 84 43 11 80       	mov    0x80114384,%eax
80103c5b:	85 c0                	test   %eax,%eax
80103c5d:	75 05                	jne    80103c64 <main+0x92>
    timerinit();   // uniprocessor timer
80103c5f:	e8 38 45 00 00       	call   8010819c <timerinit>
  startothers();   // start other processors
80103c64:	e8 7f 00 00 00       	call   80103ce8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103c69:	83 ec 08             	sub    $0x8,%esp
80103c6c:	68 00 00 00 8e       	push   $0x8e000000
80103c71:	68 00 00 40 80       	push   $0x80400000
80103c76:	e8 30 f2 ff ff       	call   80102eab <kinit2>
80103c7b:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103c7e:	e8 f2 0c 00 00       	call   80104975 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103c83:	e8 1a 00 00 00       	call   80103ca2 <mpmain>

80103c88 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103c88:	55                   	push   %ebp
80103c89:	89 e5                	mov    %esp,%ebp
80103c8b:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103c8e:	e8 f2 5c 00 00       	call   80109985 <switchkvm>
  seginit();
80103c93:	e8 7e 56 00 00       	call   80109316 <seginit>
  lapicinit();
80103c98:	e8 54 f5 ff ff       	call   801031f1 <lapicinit>
  mpmain();
80103c9d:	e8 00 00 00 00       	call   80103ca2 <mpmain>

80103ca2 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103ca2:	55                   	push   %ebp
80103ca3:	89 e5                	mov    %esp,%ebp
80103ca5:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103ca8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103cae:	0f b6 00             	movzbl (%eax),%eax
80103cb1:	0f b6 c0             	movzbl %al,%eax
80103cb4:	83 ec 08             	sub    $0x8,%esp
80103cb7:	50                   	push   %eax
80103cb8:	68 b7 a3 10 80       	push   $0x8010a3b7
80103cbd:	e8 04 c7 ff ff       	call   801003c6 <cprintf>
80103cc2:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103cc5:	e8 e2 46 00 00       	call   801083ac <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103cca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103cd0:	05 a8 00 00 00       	add    $0xa8,%eax
80103cd5:	83 ec 08             	sub    $0x8,%esp
80103cd8:	6a 01                	push   $0x1
80103cda:	50                   	push   %eax
80103cdb:	e8 d8 fe ff ff       	call   80103bb8 <xchg>
80103ce0:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103ce3:	e8 35 17 00 00       	call   8010541d <scheduler>

80103ce8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103ce8:	55                   	push   %ebp
80103ce9:	89 e5                	mov    %esp,%ebp
80103ceb:	53                   	push   %ebx
80103cec:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103cef:	68 00 70 00 00       	push   $0x7000
80103cf4:	e8 b2 fe ff ff       	call   80103bab <p2v>
80103cf9:	83 c4 04             	add    $0x4,%esp
80103cfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103cff:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103d04:	83 ec 04             	sub    $0x4,%esp
80103d07:	50                   	push   %eax
80103d08:	68 4c d5 10 80       	push   $0x8010d54c
80103d0d:	ff 75 f0             	pushl  -0x10(%ebp)
80103d10:	e8 f6 2e 00 00       	call   80106c0b <memmove>
80103d15:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103d18:	c7 45 f4 a0 43 11 80 	movl   $0x801143a0,-0xc(%ebp)
80103d1f:	e9 90 00 00 00       	jmp    80103db4 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103d24:	e8 e6 f5 ff ff       	call   8010330f <cpunum>
80103d29:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d2f:	05 a0 43 11 80       	add    $0x801143a0,%eax
80103d34:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d37:	74 73                	je     80103dac <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103d39:	e8 6b f2 ff ff       	call   80102fa9 <kalloc>
80103d3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d44:	83 e8 04             	sub    $0x4,%eax
80103d47:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d4a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103d50:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d55:	83 e8 08             	sub    $0x8,%eax
80103d58:	c7 00 88 3c 10 80    	movl   $0x80103c88,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d61:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103d64:	83 ec 0c             	sub    $0xc,%esp
80103d67:	68 00 c0 10 80       	push   $0x8010c000
80103d6c:	e8 2d fe ff ff       	call   80103b9e <v2p>
80103d71:	83 c4 10             	add    $0x10,%esp
80103d74:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	ff 75 f0             	pushl  -0x10(%ebp)
80103d7c:	e8 1d fe ff ff       	call   80103b9e <v2p>
80103d81:	83 c4 10             	add    $0x10,%esp
80103d84:	89 c2                	mov    %eax,%edx
80103d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d89:	0f b6 00             	movzbl (%eax),%eax
80103d8c:	0f b6 c0             	movzbl %al,%eax
80103d8f:	83 ec 08             	sub    $0x8,%esp
80103d92:	52                   	push   %edx
80103d93:	50                   	push   %eax
80103d94:	e8 f0 f5 ff ff       	call   80103389 <lapicstartap>
80103d99:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d9c:	90                   	nop
80103d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103da6:	85 c0                	test   %eax,%eax
80103da8:	74 f3                	je     80103d9d <startothers+0xb5>
80103daa:	eb 01                	jmp    80103dad <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103dac:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103dad:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103db4:	a1 80 49 11 80       	mov    0x80114980,%eax
80103db9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dbf:	05 a0 43 11 80       	add    $0x801143a0,%eax
80103dc4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103dc7:	0f 87 57 ff ff ff    	ja     80103d24 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103dcd:	90                   	nop
80103dce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dd1:	c9                   	leave  
80103dd2:	c3                   	ret    

80103dd3 <p2v>:
80103dd3:	55                   	push   %ebp
80103dd4:	89 e5                	mov    %esp,%ebp
80103dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd9:	05 00 00 00 80       	add    $0x80000000,%eax
80103dde:	5d                   	pop    %ebp
80103ddf:	c3                   	ret    

80103de0 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103de0:	55                   	push   %ebp
80103de1:	89 e5                	mov    %esp,%ebp
80103de3:	83 ec 14             	sub    $0x14,%esp
80103de6:	8b 45 08             	mov    0x8(%ebp),%eax
80103de9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ded:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103df1:	89 c2                	mov    %eax,%edx
80103df3:	ec                   	in     (%dx),%al
80103df4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103df7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103dfb:	c9                   	leave  
80103dfc:	c3                   	ret    

80103dfd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dfd:	55                   	push   %ebp
80103dfe:	89 e5                	mov    %esp,%ebp
80103e00:	83 ec 08             	sub    $0x8,%esp
80103e03:	8b 55 08             	mov    0x8(%ebp),%edx
80103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e09:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e0d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e10:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e14:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e18:	ee                   	out    %al,(%dx)
}
80103e19:	90                   	nop
80103e1a:	c9                   	leave  
80103e1b:	c3                   	ret    

80103e1c <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103e1c:	55                   	push   %ebp
80103e1d:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103e1f:	a1 84 d6 10 80       	mov    0x8010d684,%eax
80103e24:	89 c2                	mov    %eax,%edx
80103e26:	b8 a0 43 11 80       	mov    $0x801143a0,%eax
80103e2b:	29 c2                	sub    %eax,%edx
80103e2d:	89 d0                	mov    %edx,%eax
80103e2f:	c1 f8 02             	sar    $0x2,%eax
80103e32:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103e38:	5d                   	pop    %ebp
80103e39:	c3                   	ret    

80103e3a <sum>:

static uchar
sum(uchar *addr, int len)
{
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
80103e3d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103e40:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103e47:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103e4e:	eb 15                	jmp    80103e65 <sum+0x2b>
    sum += addr[i];
80103e50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e53:	8b 45 08             	mov    0x8(%ebp),%eax
80103e56:	01 d0                	add    %edx,%eax
80103e58:	0f b6 00             	movzbl (%eax),%eax
80103e5b:	0f b6 c0             	movzbl %al,%eax
80103e5e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103e61:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103e68:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103e6b:	7c e3                	jl     80103e50 <sum+0x16>
    sum += addr[i];
  return sum;
80103e6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103e70:	c9                   	leave  
80103e71:	c3                   	ret    

80103e72 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103e72:	55                   	push   %ebp
80103e73:	89 e5                	mov    %esp,%ebp
80103e75:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103e78:	ff 75 08             	pushl  0x8(%ebp)
80103e7b:	e8 53 ff ff ff       	call   80103dd3 <p2v>
80103e80:	83 c4 04             	add    $0x4,%esp
80103e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103e86:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e8c:	01 d0                	add    %edx,%eax
80103e8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e97:	eb 36                	jmp    80103ecf <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103e99:	83 ec 04             	sub    $0x4,%esp
80103e9c:	6a 04                	push   $0x4
80103e9e:	68 c8 a3 10 80       	push   $0x8010a3c8
80103ea3:	ff 75 f4             	pushl  -0xc(%ebp)
80103ea6:	e8 08 2d 00 00       	call   80106bb3 <memcmp>
80103eab:	83 c4 10             	add    $0x10,%esp
80103eae:	85 c0                	test   %eax,%eax
80103eb0:	75 19                	jne    80103ecb <mpsearch1+0x59>
80103eb2:	83 ec 08             	sub    $0x8,%esp
80103eb5:	6a 10                	push   $0x10
80103eb7:	ff 75 f4             	pushl  -0xc(%ebp)
80103eba:	e8 7b ff ff ff       	call   80103e3a <sum>
80103ebf:	83 c4 10             	add    $0x10,%esp
80103ec2:	84 c0                	test   %al,%al
80103ec4:	75 05                	jne    80103ecb <mpsearch1+0x59>
      return (struct mp*)p;
80103ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec9:	eb 11                	jmp    80103edc <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ecb:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ed5:	72 c2                	jb     80103e99 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ed7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103edc:	c9                   	leave  
80103edd:	c3                   	ret    

80103ede <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ede:	55                   	push   %ebp
80103edf:	89 e5                	mov    %esp,%ebp
80103ee1:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ee4:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eee:	83 c0 0f             	add    $0xf,%eax
80103ef1:	0f b6 00             	movzbl (%eax),%eax
80103ef4:	0f b6 c0             	movzbl %al,%eax
80103ef7:	c1 e0 08             	shl    $0x8,%eax
80103efa:	89 c2                	mov    %eax,%edx
80103efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eff:	83 c0 0e             	add    $0xe,%eax
80103f02:	0f b6 00             	movzbl (%eax),%eax
80103f05:	0f b6 c0             	movzbl %al,%eax
80103f08:	09 d0                	or     %edx,%eax
80103f0a:	c1 e0 04             	shl    $0x4,%eax
80103f0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103f10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f14:	74 21                	je     80103f37 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103f16:	83 ec 08             	sub    $0x8,%esp
80103f19:	68 00 04 00 00       	push   $0x400
80103f1e:	ff 75 f0             	pushl  -0x10(%ebp)
80103f21:	e8 4c ff ff ff       	call   80103e72 <mpsearch1>
80103f26:	83 c4 10             	add    $0x10,%esp
80103f29:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f30:	74 51                	je     80103f83 <mpsearch+0xa5>
      return mp;
80103f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f35:	eb 61                	jmp    80103f98 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f3a:	83 c0 14             	add    $0x14,%eax
80103f3d:	0f b6 00             	movzbl (%eax),%eax
80103f40:	0f b6 c0             	movzbl %al,%eax
80103f43:	c1 e0 08             	shl    $0x8,%eax
80103f46:	89 c2                	mov    %eax,%edx
80103f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4b:	83 c0 13             	add    $0x13,%eax
80103f4e:	0f b6 00             	movzbl (%eax),%eax
80103f51:	0f b6 c0             	movzbl %al,%eax
80103f54:	09 d0                	or     %edx,%eax
80103f56:	c1 e0 0a             	shl    $0xa,%eax
80103f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f5f:	2d 00 04 00 00       	sub    $0x400,%eax
80103f64:	83 ec 08             	sub    $0x8,%esp
80103f67:	68 00 04 00 00       	push   $0x400
80103f6c:	50                   	push   %eax
80103f6d:	e8 00 ff ff ff       	call   80103e72 <mpsearch1>
80103f72:	83 c4 10             	add    $0x10,%esp
80103f75:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f7c:	74 05                	je     80103f83 <mpsearch+0xa5>
      return mp;
80103f7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f81:	eb 15                	jmp    80103f98 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103f83:	83 ec 08             	sub    $0x8,%esp
80103f86:	68 00 00 01 00       	push   $0x10000
80103f8b:	68 00 00 0f 00       	push   $0xf0000
80103f90:	e8 dd fe ff ff       	call   80103e72 <mpsearch1>
80103f95:	83 c4 10             	add    $0x10,%esp
}
80103f98:	c9                   	leave  
80103f99:	c3                   	ret    

80103f9a <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103f9a:	55                   	push   %ebp
80103f9b:	89 e5                	mov    %esp,%ebp
80103f9d:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103fa0:	e8 39 ff ff ff       	call   80103ede <mpsearch>
80103fa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fac:	74 0a                	je     80103fb8 <mpconfig+0x1e>
80103fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb1:	8b 40 04             	mov    0x4(%eax),%eax
80103fb4:	85 c0                	test   %eax,%eax
80103fb6:	75 0a                	jne    80103fc2 <mpconfig+0x28>
    return 0;
80103fb8:	b8 00 00 00 00       	mov    $0x0,%eax
80103fbd:	e9 81 00 00 00       	jmp    80104043 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc5:	8b 40 04             	mov    0x4(%eax),%eax
80103fc8:	83 ec 0c             	sub    $0xc,%esp
80103fcb:	50                   	push   %eax
80103fcc:	e8 02 fe ff ff       	call   80103dd3 <p2v>
80103fd1:	83 c4 10             	add    $0x10,%esp
80103fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103fd7:	83 ec 04             	sub    $0x4,%esp
80103fda:	6a 04                	push   $0x4
80103fdc:	68 cd a3 10 80       	push   $0x8010a3cd
80103fe1:	ff 75 f0             	pushl  -0x10(%ebp)
80103fe4:	e8 ca 2b 00 00       	call   80106bb3 <memcmp>
80103fe9:	83 c4 10             	add    $0x10,%esp
80103fec:	85 c0                	test   %eax,%eax
80103fee:	74 07                	je     80103ff7 <mpconfig+0x5d>
    return 0;
80103ff0:	b8 00 00 00 00       	mov    $0x0,%eax
80103ff5:	eb 4c                	jmp    80104043 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ffa:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ffe:	3c 01                	cmp    $0x1,%al
80104000:	74 12                	je     80104014 <mpconfig+0x7a>
80104002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104005:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104009:	3c 04                	cmp    $0x4,%al
8010400b:	74 07                	je     80104014 <mpconfig+0x7a>
    return 0;
8010400d:	b8 00 00 00 00       	mov    $0x0,%eax
80104012:	eb 2f                	jmp    80104043 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104017:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010401b:	0f b7 c0             	movzwl %ax,%eax
8010401e:	83 ec 08             	sub    $0x8,%esp
80104021:	50                   	push   %eax
80104022:	ff 75 f0             	pushl  -0x10(%ebp)
80104025:	e8 10 fe ff ff       	call   80103e3a <sum>
8010402a:	83 c4 10             	add    $0x10,%esp
8010402d:	84 c0                	test   %al,%al
8010402f:	74 07                	je     80104038 <mpconfig+0x9e>
    return 0;
80104031:	b8 00 00 00 00       	mov    $0x0,%eax
80104036:	eb 0b                	jmp    80104043 <mpconfig+0xa9>
  *pmp = mp;
80104038:	8b 45 08             	mov    0x8(%ebp),%eax
8010403b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010403e:	89 10                	mov    %edx,(%eax)
  return conf;
80104040:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104043:	c9                   	leave  
80104044:	c3                   	ret    

80104045 <mpinit>:

void
mpinit(void)
{
80104045:	55                   	push   %ebp
80104046:	89 e5                	mov    %esp,%ebp
80104048:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
8010404b:	c7 05 84 d6 10 80 a0 	movl   $0x801143a0,0x8010d684
80104052:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104055:	83 ec 0c             	sub    $0xc,%esp
80104058:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010405b:	50                   	push   %eax
8010405c:	e8 39 ff ff ff       	call   80103f9a <mpconfig>
80104061:	83 c4 10             	add    $0x10,%esp
80104064:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104067:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010406b:	0f 84 96 01 00 00    	je     80104207 <mpinit+0x1c2>
    return;
  ismp = 1;
80104071:	c7 05 84 43 11 80 01 	movl   $0x1,0x80114384
80104078:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
8010407b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010407e:	8b 40 24             	mov    0x24(%eax),%eax
80104081:	a3 9c 42 11 80       	mov    %eax,0x8011429c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104089:	83 c0 2c             	add    $0x2c,%eax
8010408c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010408f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104092:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104096:	0f b7 d0             	movzwl %ax,%edx
80104099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010409c:	01 d0                	add    %edx,%eax
8010409e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801040a1:	e9 f2 00 00 00       	jmp    80104198 <mpinit+0x153>
    switch(*p){
801040a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a9:	0f b6 00             	movzbl (%eax),%eax
801040ac:	0f b6 c0             	movzbl %al,%eax
801040af:	83 f8 04             	cmp    $0x4,%eax
801040b2:	0f 87 bc 00 00 00    	ja     80104174 <mpinit+0x12f>
801040b8:	8b 04 85 10 a4 10 80 	mov    -0x7fef5bf0(,%eax,4),%eax
801040bf:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801040c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040ca:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040ce:	0f b6 d0             	movzbl %al,%edx
801040d1:	a1 80 49 11 80       	mov    0x80114980,%eax
801040d6:	39 c2                	cmp    %eax,%edx
801040d8:	74 2b                	je     80104105 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801040da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040dd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040e1:	0f b6 d0             	movzbl %al,%edx
801040e4:	a1 80 49 11 80       	mov    0x80114980,%eax
801040e9:	83 ec 04             	sub    $0x4,%esp
801040ec:	52                   	push   %edx
801040ed:	50                   	push   %eax
801040ee:	68 d2 a3 10 80       	push   $0x8010a3d2
801040f3:	e8 ce c2 ff ff       	call   801003c6 <cprintf>
801040f8:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801040fb:	c7 05 84 43 11 80 00 	movl   $0x0,0x80114384
80104102:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104105:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104108:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010410c:	0f b6 c0             	movzbl %al,%eax
8010410f:	83 e0 02             	and    $0x2,%eax
80104112:	85 c0                	test   %eax,%eax
80104114:	74 15                	je     8010412b <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104116:	a1 80 49 11 80       	mov    0x80114980,%eax
8010411b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104121:	05 a0 43 11 80       	add    $0x801143a0,%eax
80104126:	a3 84 d6 10 80       	mov    %eax,0x8010d684
      cpus[ncpu].id = ncpu;
8010412b:	a1 80 49 11 80       	mov    0x80114980,%eax
80104130:	8b 15 80 49 11 80    	mov    0x80114980,%edx
80104136:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010413c:	05 a0 43 11 80       	add    $0x801143a0,%eax
80104141:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104143:	a1 80 49 11 80       	mov    0x80114980,%eax
80104148:	83 c0 01             	add    $0x1,%eax
8010414b:	a3 80 49 11 80       	mov    %eax,0x80114980
      p += sizeof(struct mpproc);
80104150:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104154:	eb 42                	jmp    80104198 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010415c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010415f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104163:	a2 80 43 11 80       	mov    %al,0x80114380
      p += sizeof(struct mpioapic);
80104168:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010416c:	eb 2a                	jmp    80104198 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010416e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104172:	eb 24                	jmp    80104198 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	0f b6 00             	movzbl (%eax),%eax
8010417a:	0f b6 c0             	movzbl %al,%eax
8010417d:	83 ec 08             	sub    $0x8,%esp
80104180:	50                   	push   %eax
80104181:	68 f0 a3 10 80       	push   $0x8010a3f0
80104186:	e8 3b c2 ff ff       	call   801003c6 <cprintf>
8010418b:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010418e:	c7 05 84 43 11 80 00 	movl   $0x0,0x80114384
80104195:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010419e:	0f 82 02 ff ff ff    	jb     801040a6 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801041a4:	a1 84 43 11 80       	mov    0x80114384,%eax
801041a9:	85 c0                	test   %eax,%eax
801041ab:	75 1d                	jne    801041ca <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801041ad:	c7 05 80 49 11 80 01 	movl   $0x1,0x80114980
801041b4:	00 00 00 
    lapic = 0;
801041b7:	c7 05 9c 42 11 80 00 	movl   $0x0,0x8011429c
801041be:	00 00 00 
    ioapicid = 0;
801041c1:	c6 05 80 43 11 80 00 	movb   $0x0,0x80114380
    return;
801041c8:	eb 3e                	jmp    80104208 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801041ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801041cd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801041d1:	84 c0                	test   %al,%al
801041d3:	74 33                	je     80104208 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801041d5:	83 ec 08             	sub    $0x8,%esp
801041d8:	6a 70                	push   $0x70
801041da:	6a 22                	push   $0x22
801041dc:	e8 1c fc ff ff       	call   80103dfd <outb>
801041e1:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801041e4:	83 ec 0c             	sub    $0xc,%esp
801041e7:	6a 23                	push   $0x23
801041e9:	e8 f2 fb ff ff       	call   80103de0 <inb>
801041ee:	83 c4 10             	add    $0x10,%esp
801041f1:	83 c8 01             	or     $0x1,%eax
801041f4:	0f b6 c0             	movzbl %al,%eax
801041f7:	83 ec 08             	sub    $0x8,%esp
801041fa:	50                   	push   %eax
801041fb:	6a 23                	push   $0x23
801041fd:	e8 fb fb ff ff       	call   80103dfd <outb>
80104202:	83 c4 10             	add    $0x10,%esp
80104205:	eb 01                	jmp    80104208 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104207:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104208:	c9                   	leave  
80104209:	c3                   	ret    

8010420a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010420a:	55                   	push   %ebp
8010420b:	89 e5                	mov    %esp,%ebp
8010420d:	83 ec 08             	sub    $0x8,%esp
80104210:	8b 55 08             	mov    0x8(%ebp),%edx
80104213:	8b 45 0c             	mov    0xc(%ebp),%eax
80104216:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010421a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010421d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104221:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104225:	ee                   	out    %al,(%dx)
}
80104226:	90                   	nop
80104227:	c9                   	leave  
80104228:	c3                   	ret    

80104229 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104229:	55                   	push   %ebp
8010422a:	89 e5                	mov    %esp,%ebp
8010422c:	83 ec 04             	sub    $0x4,%esp
8010422f:	8b 45 08             	mov    0x8(%ebp),%eax
80104232:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104236:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010423a:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
80104240:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104244:	0f b6 c0             	movzbl %al,%eax
80104247:	50                   	push   %eax
80104248:	6a 21                	push   $0x21
8010424a:	e8 bb ff ff ff       	call   8010420a <outb>
8010424f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104252:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104256:	66 c1 e8 08          	shr    $0x8,%ax
8010425a:	0f b6 c0             	movzbl %al,%eax
8010425d:	50                   	push   %eax
8010425e:	68 a1 00 00 00       	push   $0xa1
80104263:	e8 a2 ff ff ff       	call   8010420a <outb>
80104268:	83 c4 08             	add    $0x8,%esp
}
8010426b:	90                   	nop
8010426c:	c9                   	leave  
8010426d:	c3                   	ret    

8010426e <picenable>:

void
picenable(int irq)
{
8010426e:	55                   	push   %ebp
8010426f:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	ba 01 00 00 00       	mov    $0x1,%edx
80104279:	89 c1                	mov    %eax,%ecx
8010427b:	d3 e2                	shl    %cl,%edx
8010427d:	89 d0                	mov    %edx,%eax
8010427f:	f7 d0                	not    %eax
80104281:	89 c2                	mov    %eax,%edx
80104283:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
8010428a:	21 d0                	and    %edx,%eax
8010428c:	0f b7 c0             	movzwl %ax,%eax
8010428f:	50                   	push   %eax
80104290:	e8 94 ff ff ff       	call   80104229 <picsetmask>
80104295:	83 c4 04             	add    $0x4,%esp
}
80104298:	90                   	nop
80104299:	c9                   	leave  
8010429a:	c3                   	ret    

8010429b <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010429b:	55                   	push   %ebp
8010429c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010429e:	68 ff 00 00 00       	push   $0xff
801042a3:	6a 21                	push   $0x21
801042a5:	e8 60 ff ff ff       	call   8010420a <outb>
801042aa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801042ad:	68 ff 00 00 00       	push   $0xff
801042b2:	68 a1 00 00 00       	push   $0xa1
801042b7:	e8 4e ff ff ff       	call   8010420a <outb>
801042bc:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801042bf:	6a 11                	push   $0x11
801042c1:	6a 20                	push   $0x20
801042c3:	e8 42 ff ff ff       	call   8010420a <outb>
801042c8:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801042cb:	6a 20                	push   $0x20
801042cd:	6a 21                	push   $0x21
801042cf:	e8 36 ff ff ff       	call   8010420a <outb>
801042d4:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801042d7:	6a 04                	push   $0x4
801042d9:	6a 21                	push   $0x21
801042db:	e8 2a ff ff ff       	call   8010420a <outb>
801042e0:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801042e3:	6a 03                	push   $0x3
801042e5:	6a 21                	push   $0x21
801042e7:	e8 1e ff ff ff       	call   8010420a <outb>
801042ec:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801042ef:	6a 11                	push   $0x11
801042f1:	68 a0 00 00 00       	push   $0xa0
801042f6:	e8 0f ff ff ff       	call   8010420a <outb>
801042fb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801042fe:	6a 28                	push   $0x28
80104300:	68 a1 00 00 00       	push   $0xa1
80104305:	e8 00 ff ff ff       	call   8010420a <outb>
8010430a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010430d:	6a 02                	push   $0x2
8010430f:	68 a1 00 00 00       	push   $0xa1
80104314:	e8 f1 fe ff ff       	call   8010420a <outb>
80104319:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010431c:	6a 03                	push   $0x3
8010431e:	68 a1 00 00 00       	push   $0xa1
80104323:	e8 e2 fe ff ff       	call   8010420a <outb>
80104328:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010432b:	6a 68                	push   $0x68
8010432d:	6a 20                	push   $0x20
8010432f:	e8 d6 fe ff ff       	call   8010420a <outb>
80104334:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104337:	6a 0a                	push   $0xa
80104339:	6a 20                	push   $0x20
8010433b:	e8 ca fe ff ff       	call   8010420a <outb>
80104340:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104343:	6a 68                	push   $0x68
80104345:	68 a0 00 00 00       	push   $0xa0
8010434a:	e8 bb fe ff ff       	call   8010420a <outb>
8010434f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104352:	6a 0a                	push   $0xa
80104354:	68 a0 00 00 00       	push   $0xa0
80104359:	e8 ac fe ff ff       	call   8010420a <outb>
8010435e:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104361:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104368:	66 83 f8 ff          	cmp    $0xffff,%ax
8010436c:	74 13                	je     80104381 <picinit+0xe6>
    picsetmask(irqmask);
8010436e:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104375:	0f b7 c0             	movzwl %ax,%eax
80104378:	50                   	push   %eax
80104379:	e8 ab fe ff ff       	call   80104229 <picsetmask>
8010437e:	83 c4 04             	add    $0x4,%esp
}
80104381:	90                   	nop
80104382:	c9                   	leave  
80104383:	c3                   	ret    

80104384 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104384:	55                   	push   %ebp
80104385:	89 e5                	mov    %esp,%ebp
80104387:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010438a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104391:	8b 45 0c             	mov    0xc(%ebp),%eax
80104394:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010439a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010439d:	8b 10                	mov    (%eax),%edx
8010439f:	8b 45 08             	mov    0x8(%ebp),%eax
801043a2:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801043a4:	e8 1f cd ff ff       	call   801010c8 <filealloc>
801043a9:	89 c2                	mov    %eax,%edx
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	89 10                	mov    %edx,(%eax)
801043b0:	8b 45 08             	mov    0x8(%ebp),%eax
801043b3:	8b 00                	mov    (%eax),%eax
801043b5:	85 c0                	test   %eax,%eax
801043b7:	0f 84 cb 00 00 00    	je     80104488 <pipealloc+0x104>
801043bd:	e8 06 cd ff ff       	call   801010c8 <filealloc>
801043c2:	89 c2                	mov    %eax,%edx
801043c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801043c7:	89 10                	mov    %edx,(%eax)
801043c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801043cc:	8b 00                	mov    (%eax),%eax
801043ce:	85 c0                	test   %eax,%eax
801043d0:	0f 84 b2 00 00 00    	je     80104488 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801043d6:	e8 ce eb ff ff       	call   80102fa9 <kalloc>
801043db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043e2:	0f 84 9f 00 00 00    	je     80104487 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801043f2:	00 00 00 
  p->writeopen = 1;
801043f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801043ff:	00 00 00 
  p->nwrite = 0;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104405:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010440c:	00 00 00 
  p->nread = 0;
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104419:	00 00 00 
  initlock(&p->lock, "pipe");
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	83 ec 08             	sub    $0x8,%esp
80104422:	68 24 a4 10 80       	push   $0x8010a424
80104427:	50                   	push   %eax
80104428:	e8 9a 24 00 00       	call   801068c7 <initlock>
8010442d:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104430:	8b 45 08             	mov    0x8(%ebp),%eax
80104433:	8b 00                	mov    (%eax),%eax
80104435:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010443b:	8b 45 08             	mov    0x8(%ebp),%eax
8010443e:	8b 00                	mov    (%eax),%eax
80104440:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104444:	8b 45 08             	mov    0x8(%ebp),%eax
80104447:	8b 00                	mov    (%eax),%eax
80104449:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010444d:	8b 45 08             	mov    0x8(%ebp),%eax
80104450:	8b 00                	mov    (%eax),%eax
80104452:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104455:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104458:	8b 45 0c             	mov    0xc(%ebp),%eax
8010445b:	8b 00                	mov    (%eax),%eax
8010445d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104463:	8b 45 0c             	mov    0xc(%ebp),%eax
80104466:	8b 00                	mov    (%eax),%eax
80104468:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010446c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010446f:	8b 00                	mov    (%eax),%eax
80104471:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104475:	8b 45 0c             	mov    0xc(%ebp),%eax
80104478:	8b 00                	mov    (%eax),%eax
8010447a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104480:	b8 00 00 00 00       	mov    $0x0,%eax
80104485:	eb 4e                	jmp    801044d5 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104487:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104488:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010448c:	74 0e                	je     8010449c <pipealloc+0x118>
    kfree((char*)p);
8010448e:	83 ec 0c             	sub    $0xc,%esp
80104491:	ff 75 f4             	pushl  -0xc(%ebp)
80104494:	e8 73 ea ff ff       	call   80102f0c <kfree>
80104499:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010449c:	8b 45 08             	mov    0x8(%ebp),%eax
8010449f:	8b 00                	mov    (%eax),%eax
801044a1:	85 c0                	test   %eax,%eax
801044a3:	74 11                	je     801044b6 <pipealloc+0x132>
    fileclose(*f0);
801044a5:	8b 45 08             	mov    0x8(%ebp),%eax
801044a8:	8b 00                	mov    (%eax),%eax
801044aa:	83 ec 0c             	sub    $0xc,%esp
801044ad:	50                   	push   %eax
801044ae:	e8 d3 cc ff ff       	call   80101186 <fileclose>
801044b3:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801044b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801044b9:	8b 00                	mov    (%eax),%eax
801044bb:	85 c0                	test   %eax,%eax
801044bd:	74 11                	je     801044d0 <pipealloc+0x14c>
    fileclose(*f1);
801044bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801044c2:	8b 00                	mov    (%eax),%eax
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	50                   	push   %eax
801044c8:	e8 b9 cc ff ff       	call   80101186 <fileclose>
801044cd:	83 c4 10             	add    $0x10,%esp
  return -1;
801044d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044d5:	c9                   	leave  
801044d6:	c3                   	ret    

801044d7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801044d7:	55                   	push   %ebp
801044d8:	89 e5                	mov    %esp,%ebp
801044da:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801044dd:	8b 45 08             	mov    0x8(%ebp),%eax
801044e0:	83 ec 0c             	sub    $0xc,%esp
801044e3:	50                   	push   %eax
801044e4:	e8 00 24 00 00       	call   801068e9 <acquire>
801044e9:	83 c4 10             	add    $0x10,%esp
  if(writable){
801044ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044f0:	74 23                	je     80104515 <pipeclose+0x3e>
    p->writeopen = 0;
801044f2:	8b 45 08             	mov    0x8(%ebp),%eax
801044f5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801044fc:	00 00 00 
    wakeup(&p->nread);
801044ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104502:	05 34 02 00 00       	add    $0x234,%eax
80104507:	83 ec 0c             	sub    $0xc,%esp
8010450a:	50                   	push   %eax
8010450b:	e8 65 15 00 00       	call   80105a75 <wakeup>
80104510:	83 c4 10             	add    $0x10,%esp
80104513:	eb 21                	jmp    80104536 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104515:	8b 45 08             	mov    0x8(%ebp),%eax
80104518:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010451f:	00 00 00 
    wakeup(&p->nwrite);
80104522:	8b 45 08             	mov    0x8(%ebp),%eax
80104525:	05 38 02 00 00       	add    $0x238,%eax
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	50                   	push   %eax
8010452e:	e8 42 15 00 00       	call   80105a75 <wakeup>
80104533:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104536:	8b 45 08             	mov    0x8(%ebp),%eax
80104539:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010453f:	85 c0                	test   %eax,%eax
80104541:	75 2c                	jne    8010456f <pipeclose+0x98>
80104543:	8b 45 08             	mov    0x8(%ebp),%eax
80104546:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010454c:	85 c0                	test   %eax,%eax
8010454e:	75 1f                	jne    8010456f <pipeclose+0x98>
    release(&p->lock);
80104550:	8b 45 08             	mov    0x8(%ebp),%eax
80104553:	83 ec 0c             	sub    $0xc,%esp
80104556:	50                   	push   %eax
80104557:	e8 f4 23 00 00       	call   80106950 <release>
8010455c:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	ff 75 08             	pushl  0x8(%ebp)
80104565:	e8 a2 e9 ff ff       	call   80102f0c <kfree>
8010456a:	83 c4 10             	add    $0x10,%esp
8010456d:	eb 0f                	jmp    8010457e <pipeclose+0xa7>
  } else
    release(&p->lock);
8010456f:	8b 45 08             	mov    0x8(%ebp),%eax
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	50                   	push   %eax
80104576:	e8 d5 23 00 00       	call   80106950 <release>
8010457b:	83 c4 10             	add    $0x10,%esp
}
8010457e:	90                   	nop
8010457f:	c9                   	leave  
80104580:	c3                   	ret    

80104581 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104581:	55                   	push   %ebp
80104582:	89 e5                	mov    %esp,%ebp
80104584:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104587:	8b 45 08             	mov    0x8(%ebp),%eax
8010458a:	83 ec 0c             	sub    $0xc,%esp
8010458d:	50                   	push   %eax
8010458e:	e8 56 23 00 00       	call   801068e9 <acquire>
80104593:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104596:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010459d:	e9 ad 00 00 00       	jmp    8010464f <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801045a2:	8b 45 08             	mov    0x8(%ebp),%eax
801045a5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801045ab:	85 c0                	test   %eax,%eax
801045ad:	74 0d                	je     801045bc <pipewrite+0x3b>
801045af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b5:	8b 40 24             	mov    0x24(%eax),%eax
801045b8:	85 c0                	test   %eax,%eax
801045ba:	74 19                	je     801045d5 <pipewrite+0x54>
        release(&p->lock);
801045bc:	8b 45 08             	mov    0x8(%ebp),%eax
801045bf:	83 ec 0c             	sub    $0xc,%esp
801045c2:	50                   	push   %eax
801045c3:	e8 88 23 00 00       	call   80106950 <release>
801045c8:	83 c4 10             	add    $0x10,%esp
        return -1;
801045cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d0:	e9 a8 00 00 00       	jmp    8010467d <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801045d5:	8b 45 08             	mov    0x8(%ebp),%eax
801045d8:	05 34 02 00 00       	add    $0x234,%eax
801045dd:	83 ec 0c             	sub    $0xc,%esp
801045e0:	50                   	push   %eax
801045e1:	e8 8f 14 00 00       	call   80105a75 <wakeup>
801045e6:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801045e9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ec:	8b 55 08             	mov    0x8(%ebp),%edx
801045ef:	81 c2 38 02 00 00    	add    $0x238,%edx
801045f5:	83 ec 08             	sub    $0x8,%esp
801045f8:	50                   	push   %eax
801045f9:	52                   	push   %edx
801045fa:	e8 52 12 00 00       	call   80105851 <sleep>
801045ff:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104602:	8b 45 08             	mov    0x8(%ebp),%eax
80104605:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010460b:	8b 45 08             	mov    0x8(%ebp),%eax
8010460e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104614:	05 00 02 00 00       	add    $0x200,%eax
80104619:	39 c2                	cmp    %eax,%edx
8010461b:	74 85                	je     801045a2 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010461d:	8b 45 08             	mov    0x8(%ebp),%eax
80104620:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104626:	8d 48 01             	lea    0x1(%eax),%ecx
80104629:	8b 55 08             	mov    0x8(%ebp),%edx
8010462c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104632:	25 ff 01 00 00       	and    $0x1ff,%eax
80104637:	89 c1                	mov    %eax,%ecx
80104639:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010463f:	01 d0                	add    %edx,%eax
80104641:	0f b6 10             	movzbl (%eax),%edx
80104644:	8b 45 08             	mov    0x8(%ebp),%eax
80104647:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010464b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010464f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104652:	3b 45 10             	cmp    0x10(%ebp),%eax
80104655:	7c ab                	jl     80104602 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104657:	8b 45 08             	mov    0x8(%ebp),%eax
8010465a:	05 34 02 00 00       	add    $0x234,%eax
8010465f:	83 ec 0c             	sub    $0xc,%esp
80104662:	50                   	push   %eax
80104663:	e8 0d 14 00 00       	call   80105a75 <wakeup>
80104668:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010466b:	8b 45 08             	mov    0x8(%ebp),%eax
8010466e:	83 ec 0c             	sub    $0xc,%esp
80104671:	50                   	push   %eax
80104672:	e8 d9 22 00 00       	call   80106950 <release>
80104677:	83 c4 10             	add    $0x10,%esp
  return n;
8010467a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010467d:	c9                   	leave  
8010467e:	c3                   	ret    

8010467f <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010467f:	55                   	push   %ebp
80104680:	89 e5                	mov    %esp,%ebp
80104682:	53                   	push   %ebx
80104683:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104686:	8b 45 08             	mov    0x8(%ebp),%eax
80104689:	83 ec 0c             	sub    $0xc,%esp
8010468c:	50                   	push   %eax
8010468d:	e8 57 22 00 00       	call   801068e9 <acquire>
80104692:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104695:	eb 3f                	jmp    801046d6 <piperead+0x57>
    if(proc->killed){
80104697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469d:	8b 40 24             	mov    0x24(%eax),%eax
801046a0:	85 c0                	test   %eax,%eax
801046a2:	74 19                	je     801046bd <piperead+0x3e>
      release(&p->lock);
801046a4:	8b 45 08             	mov    0x8(%ebp),%eax
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	50                   	push   %eax
801046ab:	e8 a0 22 00 00       	call   80106950 <release>
801046b0:	83 c4 10             	add    $0x10,%esp
      return -1;
801046b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b8:	e9 bf 00 00 00       	jmp    8010477c <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801046bd:	8b 45 08             	mov    0x8(%ebp),%eax
801046c0:	8b 55 08             	mov    0x8(%ebp),%edx
801046c3:	81 c2 34 02 00 00    	add    $0x234,%edx
801046c9:	83 ec 08             	sub    $0x8,%esp
801046cc:	50                   	push   %eax
801046cd:	52                   	push   %edx
801046ce:	e8 7e 11 00 00       	call   80105851 <sleep>
801046d3:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801046d6:	8b 45 08             	mov    0x8(%ebp),%eax
801046d9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801046df:	8b 45 08             	mov    0x8(%ebp),%eax
801046e2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801046e8:	39 c2                	cmp    %eax,%edx
801046ea:	75 0d                	jne    801046f9 <piperead+0x7a>
801046ec:	8b 45 08             	mov    0x8(%ebp),%eax
801046ef:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801046f5:	85 c0                	test   %eax,%eax
801046f7:	75 9e                	jne    80104697 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801046f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104700:	eb 49                	jmp    8010474b <piperead+0xcc>
    if(p->nread == p->nwrite)
80104702:	8b 45 08             	mov    0x8(%ebp),%eax
80104705:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010470b:	8b 45 08             	mov    0x8(%ebp),%eax
8010470e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104714:	39 c2                	cmp    %eax,%edx
80104716:	74 3d                	je     80104755 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104718:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010471e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104721:	8b 45 08             	mov    0x8(%ebp),%eax
80104724:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010472a:	8d 48 01             	lea    0x1(%eax),%ecx
8010472d:	8b 55 08             	mov    0x8(%ebp),%edx
80104730:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104736:	25 ff 01 00 00       	and    $0x1ff,%eax
8010473b:	89 c2                	mov    %eax,%edx
8010473d:	8b 45 08             	mov    0x8(%ebp),%eax
80104740:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104745:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104747:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010474b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104751:	7c af                	jl     80104702 <piperead+0x83>
80104753:	eb 01                	jmp    80104756 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104755:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104756:	8b 45 08             	mov    0x8(%ebp),%eax
80104759:	05 38 02 00 00       	add    $0x238,%eax
8010475e:	83 ec 0c             	sub    $0xc,%esp
80104761:	50                   	push   %eax
80104762:	e8 0e 13 00 00       	call   80105a75 <wakeup>
80104767:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010476a:	8b 45 08             	mov    0x8(%ebp),%eax
8010476d:	83 ec 0c             	sub    $0xc,%esp
80104770:	50                   	push   %eax
80104771:	e8 da 21 00 00       	call   80106950 <release>
80104776:	83 c4 10             	add    $0x10,%esp
  return i;
80104779:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010477c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010477f:	c9                   	leave  
80104780:	c3                   	ret    

80104781 <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
80104781:	55                   	push   %ebp
80104782:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
80104784:	f4                   	hlt    
}
80104785:	90                   	nop
80104786:	5d                   	pop    %ebp
80104787:	c3                   	ret    

80104788 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104788:	55                   	push   %ebp
80104789:	89 e5                	mov    %esp,%ebp
8010478b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010478e:	9c                   	pushf  
8010478f:	58                   	pop    %eax
80104790:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104793:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104796:	c9                   	leave  
80104797:	c3                   	ret    

80104798 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104798:	55                   	push   %ebp
80104799:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010479b:	fb                   	sti    
}
8010479c:	90                   	nop
8010479d:	5d                   	pop    %ebp
8010479e:	c3                   	ret    

8010479f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010479f:	55                   	push   %ebp
801047a0:	89 e5                	mov    %esp,%ebp
801047a2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801047a5:	83 ec 08             	sub    $0x8,%esp
801047a8:	68 2c a4 10 80       	push   $0x8010a42c
801047ad:	68 a0 49 11 80       	push   $0x801149a0
801047b2:	e8 10 21 00 00       	call   801068c7 <initlock>
801047b7:	83 c4 10             	add    $0x10,%esp
}
801047ba:	90                   	nop
801047bb:	c9                   	leave  
801047bc:	c3                   	ret    

801047bd <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801047bd:	55                   	push   %ebp
801047be:	89 e5                	mov    %esp,%ebp
801047c0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801047c3:	83 ec 0c             	sub    $0xc,%esp
801047c6:	68 a0 49 11 80       	push   $0x801149a0
801047cb:	e8 19 21 00 00       	call   801068e9 <acquire>
801047d0:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  int rc;
  p = ptable.pLists.free;
801047d3:	a1 00 71 11 80       	mov    0x80117100,%eax
801047d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p)
801047db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047df:	75 1a                	jne    801047fb <allocproc+0x3e>
      goto found;
  release (&ptable.lock);
801047e1:	83 ec 0c             	sub    $0xc,%esp
801047e4:	68 a0 49 11 80       	push   $0x801149a0
801047e9:	e8 62 21 00 00       	call   80106950 <release>
801047ee:	83 c4 10             	add    $0x10,%esp
  return 0;
801047f1:	b8 00 00 00 00       	mov    $0x0,%eax
801047f6:	e9 78 01 00 00       	jmp    80104973 <allocproc+0x1b6>
  acquire(&ptable.lock);
#ifdef CS333_P3P4
  int rc;
  p = ptable.pLists.free;
  if(p)
      goto found;
801047fb:	90                   	nop
  return 0;
#endif

found:
#ifdef CS333_P3P4
  assertState(p,UNUSED);
801047fc:	83 ec 08             	sub    $0x8,%esp
801047ff:	6a 00                	push   $0x0
80104801:	ff 75 f4             	pushl  -0xc(%ebp)
80104804:	e8 a7 19 00 00       	call   801061b0 <assertState>
80104809:	83 c4 10             	add    $0x10,%esp
  rc = removeFromStateList(&ptable.pLists.free,p);
8010480c:	83 ec 08             	sub    $0x8,%esp
8010480f:	ff 75 f4             	pushl  -0xc(%ebp)
80104812:	68 00 71 11 80       	push   $0x80117100
80104817:	e8 7c 1a 00 00       	call   80106298 <removeFromStateList>
8010481c:	83 c4 10             	add    $0x10,%esp
8010481f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  if(rc == -1)
80104822:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104826:	75 0d                	jne    80104835 <allocproc+0x78>
      panic("Faild To Remove");
80104828:	83 ec 0c             	sub    $0xc,%esp
8010482b:	68 33 a4 10 80       	push   $0x8010a433
80104830:	e8 31 bd ff ff       	call   80100566 <panic>
  p->state = EMBRYO;
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  rc = addToStateListHead(&ptable.pLists.embryo,p,EMBRYO);
8010483f:	83 ec 04             	sub    $0x4,%esp
80104842:	6a 01                	push   $0x1
80104844:	ff 75 f4             	pushl  -0xc(%ebp)
80104847:	68 10 71 11 80       	push   $0x80117110
8010484c:	e8 a9 19 00 00       	call   801061fa <addToStateListHead>
80104851:	83 c4 10             	add    $0x10,%esp
80104854:	89 45 f0             	mov    %eax,-0x10(%ebp)
#else
  p->state =EMBRYO;
#endif
  //p->state = EMBRYO;
  p->pid = nextpid++;
80104857:	a1 04 d0 10 80       	mov    0x8010d004,%eax
8010485c:	8d 50 01             	lea    0x1(%eax),%edx
8010485f:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104865:	89 c2                	mov    %eax,%edx
80104867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486a:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
8010486d:	83 ec 0c             	sub    $0xc,%esp
80104870:	68 a0 49 11 80       	push   $0x801149a0
80104875:	e8 d6 20 00 00       	call   80106950 <release>
8010487a:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010487d:	e8 27 e7 ff ff       	call   80102fa9 <kalloc>
80104882:	89 c2                	mov    %eax,%edx
80104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104887:	89 50 08             	mov    %edx,0x8(%eax)
8010488a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488d:	8b 40 08             	mov    0x8(%eax),%eax
80104890:	85 c0                	test   %eax,%eax
80104892:	75 5c                	jne    801048f0 <allocproc+0x133>
#ifndef CS333_P3P4
    p->state = UNUSED;
    //////////////////////////////
#else
    acquire(&ptable.lock);
80104894:	83 ec 0c             	sub    $0xc,%esp
80104897:	68 a0 49 11 80       	push   $0x801149a0
8010489c:	e8 48 20 00 00       	call   801068e9 <acquire>
801048a1:	83 c4 10             	add    $0x10,%esp
    removeFromStateList(&ptable.pLists.embryo,p);
801048a4:	83 ec 08             	sub    $0x8,%esp
801048a7:	ff 75 f4             	pushl  -0xc(%ebp)
801048aa:	68 10 71 11 80       	push   $0x80117110
801048af:	e8 e4 19 00 00       	call   80106298 <removeFromStateList>
801048b4:	83 c4 10             	add    $0x10,%esp
    p->state = UNUSED;
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    addToStateListHead(&ptable.pLists.free,p,UNUSED);
801048c1:	83 ec 04             	sub    $0x4,%esp
801048c4:	6a 00                	push   $0x0
801048c6:	ff 75 f4             	pushl  -0xc(%ebp)
801048c9:	68 00 71 11 80       	push   $0x80117100
801048ce:	e8 27 19 00 00       	call   801061fa <addToStateListHead>
801048d3:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801048d6:	83 ec 0c             	sub    $0xc,%esp
801048d9:	68 a0 49 11 80       	push   $0x801149a0
801048de:	e8 6d 20 00 00       	call   80106950 <release>
801048e3:	83 c4 10             	add    $0x10,%esp
#endif

    return 0;
801048e6:	b8 00 00 00 00       	mov    $0x0,%eax
801048eb:	e9 83 00 00 00       	jmp    80104973 <allocproc+0x1b6>
  }
  sp = p->kstack + KSTACKSIZE;
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f3:	8b 40 08             	mov    0x8(%eax),%eax
801048f6:	05 00 10 00 00       	add    $0x1000,%eax
801048fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048fe:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104905:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104908:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010490b:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
8010490f:	ba f9 81 10 80       	mov    $0x801081f9,%edx
80104914:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104917:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104919:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104923:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104929:	8b 40 1c             	mov    0x1c(%eax),%eax
8010492c:	83 ec 04             	sub    $0x4,%esp
8010492f:	6a 14                	push   $0x14
80104931:	6a 00                	push   $0x0
80104933:	50                   	push   %eax
80104934:	e8 13 22 00 00       	call   80106b4c <memset>
80104939:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104942:	ba 0b 58 10 80       	mov    $0x8010580b,%edx
80104947:	89 50 10             	mov    %edx,0x10(%eax)

#ifdef CS333_P1
  p->start_ticks = (uint)ticks;
8010494a:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80104950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104953:	89 50 7c             	mov    %edx,0x7c(%eax)
#endif

#ifdef CS333_P2
  p->total_ticks_cpu = 0;
80104956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104959:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104960:	00 00 00 
  p->ticks_in_cpu = 0;
80104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104966:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010496d:	00 00 00 
#endif
  
  return p;
80104970:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104973:	c9                   	leave  
80104974:	c3                   	ret    

80104975 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104975:	55                   	push   %ebp
80104976:	89 e5                	mov    %esp,%ebp
80104978:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  for(int i =0; i<MAX+1;++i)
8010497b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104982:	eb 17                	jmp    8010499b <userinit+0x26>
    ptable.pLists.ready[i] = 0;
80104984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104987:	05 cc 09 00 00       	add    $0x9cc,%eax
8010498c:	c7 04 85 a4 49 11 80 	movl   $0x0,-0x7feeb65c(,%eax,4)
80104993:	00 00 00 00 
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

#ifdef CS333_P3P4
  for(int i =0; i<MAX+1;++i)
80104997:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010499b:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010499f:	7e e3                	jle    80104984 <userinit+0xf>
    ptable.pLists.ready[i] = 0;

    ptable.pLists.free = 0;
801049a1:	c7 05 00 71 11 80 00 	movl   $0x0,0x80117100
801049a8:	00 00 00 
    ptable.pLists.sleep = 0;
801049ab:	c7 05 04 71 11 80 00 	movl   $0x0,0x80117104
801049b2:	00 00 00 
    ptable.pLists.zombie = 0;
801049b5:	c7 05 08 71 11 80 00 	movl   $0x0,0x80117108
801049bc:	00 00 00 
    ptable.pLists.running = 0;
801049bf:	c7 05 0c 71 11 80 00 	movl   $0x0,0x8011710c
801049c6:	00 00 00 
    ptable.pLists.embryo = 0;
801049c9:	c7 05 10 71 11 80 00 	movl   $0x0,0x80117110
801049d0:	00 00 00 

    acquire(&ptable.lock);
801049d3:	83 ec 0c             	sub    $0xc,%esp
801049d6:	68 a0 49 11 80       	push   $0x801149a0
801049db:	e8 09 1f 00 00       	call   801068e9 <acquire>
801049e0:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; ++p){
801049e3:	c7 45 f4 d4 49 11 80 	movl   $0x801149d4,-0xc(%ebp)
801049ea:	eb 36                	jmp    80104a22 <userinit+0xad>
        p->state = UNUSED;
801049ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ef:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        assertState(p,UNUSED);
801049f6:	83 ec 08             	sub    $0x8,%esp
801049f9:	6a 00                	push   $0x0
801049fb:	ff 75 f4             	pushl  -0xc(%ebp)
801049fe:	e8 ad 17 00 00       	call   801061b0 <assertState>
80104a03:	83 c4 10             	add    $0x10,%esp
        addToStateListHead(&ptable.pLists.free,p,UNUSED);
80104a06:	83 ec 04             	sub    $0x4,%esp
80104a09:	6a 00                	push   $0x0
80104a0b:	ff 75 f4             	pushl  -0xc(%ebp)
80104a0e:	68 00 71 11 80       	push   $0x80117100
80104a13:	e8 e2 17 00 00       	call   801061fa <addToStateListHead>
80104a18:	83 c4 10             	add    $0x10,%esp
    ptable.pLists.zombie = 0;
    ptable.pLists.running = 0;
    ptable.pLists.embryo = 0;

    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; ++p){
80104a1b:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104a22:	81 7d f4 d4 70 11 80 	cmpl   $0x801170d4,-0xc(%ebp)
80104a29:	72 c1                	jb     801049ec <userinit+0x77>
        p->state = UNUSED;
        assertState(p,UNUSED);
        addToStateListHead(&ptable.pLists.free,p,UNUSED);
    }
    release(&ptable.lock);
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	68 a0 49 11 80       	push   $0x801149a0
80104a33:	e8 18 1f 00 00       	call   80106950 <release>
80104a38:	83 c4 10             	add    $0x10,%esp
#endif

  
  p = allocproc();
80104a3b:	e8 7d fd ff ff       	call   801047bd <allocproc>
80104a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a46:	a3 88 d6 10 80       	mov    %eax,0x8010d688
  if((p->pgdir = setupkvm()) == 0)
80104a4b:	e8 6b 4e 00 00       	call   801098bb <setupkvm>
80104a50:	89 c2                	mov    %eax,%edx
80104a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a55:	89 50 04             	mov    %edx,0x4(%eax)
80104a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5b:	8b 40 04             	mov    0x4(%eax),%eax
80104a5e:	85 c0                	test   %eax,%eax
80104a60:	75 0d                	jne    80104a6f <userinit+0xfa>
    panic("userinit: out of memory?");
80104a62:	83 ec 0c             	sub    $0xc,%esp
80104a65:	68 43 a4 10 80       	push   $0x8010a443
80104a6a:	e8 f7 ba ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104a6f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a77:	8b 40 04             	mov    0x4(%eax),%eax
80104a7a:	83 ec 04             	sub    $0x4,%esp
80104a7d:	52                   	push   %edx
80104a7e:	68 20 d5 10 80       	push   $0x8010d520
80104a83:	50                   	push   %eax
80104a84:	e8 8c 50 00 00       	call   80109b15 <inituvm>
80104a89:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 40 18             	mov    0x18(%eax),%eax
80104a9b:	83 ec 04             	sub    $0x4,%esp
80104a9e:	6a 4c                	push   $0x4c
80104aa0:	6a 00                	push   $0x0
80104aa2:	50                   	push   %eax
80104aa3:	e8 a4 20 00 00       	call   80106b4c <memset>
80104aa8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	8b 40 18             	mov    0x18(%eax),%eax
80104ab1:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	8b 40 18             	mov    0x18(%eax),%eax
80104abd:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac6:	8b 40 18             	mov    0x18(%eax),%eax
80104ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104acc:	8b 52 18             	mov    0x18(%edx),%edx
80104acf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ad3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	8b 40 18             	mov    0x18(%eax),%eax
80104add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ae0:	8b 52 18             	mov    0x18(%edx),%edx
80104ae3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ae7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aee:	8b 40 18             	mov    0x18(%eax),%eax
80104af1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afb:	8b 40 18             	mov    0x18(%eax),%eax
80104afe:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b08:	8b 40 18             	mov    0x18(%eax),%eax
80104b0b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b15:	83 c0 6c             	add    $0x6c,%eax
80104b18:	83 ec 04             	sub    $0x4,%esp
80104b1b:	6a 10                	push   $0x10
80104b1d:	68 5c a4 10 80       	push   $0x8010a45c
80104b22:	50                   	push   %eax
80104b23:	e8 27 22 00 00       	call   80106d4f <safestrcpy>
80104b28:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104b2b:	83 ec 0c             	sub    $0xc,%esp
80104b2e:	68 65 a4 10 80       	push   $0x8010a465
80104b33:	e8 b9 db ff ff       	call   801026f1 <namei>
80104b38:	83 c4 10             	add    $0x10,%esp
80104b3b:	89 c2                	mov    %eax,%edx
80104b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b40:	89 50 68             	mov    %edx,0x68(%eax)

  //p->state = RUNNABLE;
#ifdef CS333_P2
  p->parent = p;
80104b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b49:	89 50 14             	mov    %edx,0x14(%eax)
  p->uid = UID;
80104b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4f:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104b56:	00 00 00 
  p->gid = GID;
80104b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104b63:	00 00 00 
#endif
#ifdef CS333_P3P4
   // ptable.pLists.ready = p;
    acquire(&ptable.lock);
80104b66:	83 ec 0c             	sub    $0xc,%esp
80104b69:	68 a0 49 11 80       	push   $0x801149a0
80104b6e:	e8 76 1d 00 00       	call   801068e9 <acquire>
80104b73:	83 c4 10             	add    $0x10,%esp
    assertState(p,EMBRYO);
80104b76:	83 ec 08             	sub    $0x8,%esp
80104b79:	6a 01                	push   $0x1
80104b7b:	ff 75 f4             	pushl  -0xc(%ebp)
80104b7e:	e8 2d 16 00 00       	call   801061b0 <assertState>
80104b83:	83 c4 10             	add    $0x10,%esp
    removeFromStateList(&ptable.pLists.embryo,p);
80104b86:	83 ec 08             	sub    $0x8,%esp
80104b89:	ff 75 f4             	pushl  -0xc(%ebp)
80104b8c:	68 10 71 11 80       	push   $0x80117110
80104b91:	e8 02 17 00 00       	call   80106298 <removeFromStateList>
80104b96:	83 c4 10             	add    $0x10,%esp
    p->state = RUNNABLE;
80104b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    p->priority=0;
80104ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba6:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80104bad:	00 00 00 
    addToStateListEnd(&ptable.pLists.ready[p->priority],p);
80104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb3:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80104bb9:	05 cc 09 00 00       	add    $0x9cc,%eax
80104bbe:	c1 e0 02             	shl    $0x2,%eax
80104bc1:	05 a0 49 11 80       	add    $0x801149a0,%eax
80104bc6:	83 c0 04             	add    $0x4,%eax
80104bc9:	83 ec 08             	sub    $0x8,%esp
80104bcc:	ff 75 f4             	pushl  -0xc(%ebp)
80104bcf:	50                   	push   %eax
80104bd0:	e8 59 16 00 00       	call   8010622e <addToStateListEnd>
80104bd5:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80104bd8:	83 ec 0c             	sub    $0xc,%esp
80104bdb:	68 a0 49 11 80       	push   $0x801149a0
80104be0:	e8 6b 1d 00 00       	call   80106950 <release>
80104be5:	83 c4 10             	add    $0x10,%esp
#else
    p->state = RUNNABLE;
#endif
}
80104be8:	90                   	nop
80104be9:	c9                   	leave  
80104bea:	c3                   	ret    

80104beb <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104beb:	55                   	push   %ebp
80104bec:	89 e5                	mov    %esp,%ebp
80104bee:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104bf1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf7:	8b 00                	mov    (%eax),%eax
80104bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104bfc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c00:	7e 31                	jle    80104c33 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104c02:	8b 55 08             	mov    0x8(%ebp),%edx
80104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c08:	01 c2                	add    %eax,%edx
80104c0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c10:	8b 40 04             	mov    0x4(%eax),%eax
80104c13:	83 ec 04             	sub    $0x4,%esp
80104c16:	52                   	push   %edx
80104c17:	ff 75 f4             	pushl  -0xc(%ebp)
80104c1a:	50                   	push   %eax
80104c1b:	e8 42 50 00 00       	call   80109c62 <allocuvm>
80104c20:	83 c4 10             	add    $0x10,%esp
80104c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c2a:	75 3e                	jne    80104c6a <growproc+0x7f>
      return -1;
80104c2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c31:	eb 59                	jmp    80104c8c <growproc+0xa1>
  } else if(n < 0){
80104c33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c37:	79 31                	jns    80104c6a <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104c39:	8b 55 08             	mov    0x8(%ebp),%edx
80104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3f:	01 c2                	add    %eax,%edx
80104c41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c47:	8b 40 04             	mov    0x4(%eax),%eax
80104c4a:	83 ec 04             	sub    $0x4,%esp
80104c4d:	52                   	push   %edx
80104c4e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c51:	50                   	push   %eax
80104c52:	e8 d4 50 00 00       	call   80109d2b <deallocuvm>
80104c57:	83 c4 10             	add    $0x10,%esp
80104c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c61:	75 07                	jne    80104c6a <growproc+0x7f>
      return -1;
80104c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c68:	eb 22                	jmp    80104c8c <growproc+0xa1>
  }
  proc->sz = sz;
80104c6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c73:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104c75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c7b:	83 ec 0c             	sub    $0xc,%esp
80104c7e:	50                   	push   %eax
80104c7f:	e8 1e 4d 00 00       	call   801099a2 <switchuvm>
80104c84:	83 c4 10             	add    $0x10,%esp
  return 0;
80104c87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    

80104c8e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104c8e:	55                   	push   %ebp
80104c8f:	89 e5                	mov    %esp,%ebp
80104c91:	57                   	push   %edi
80104c92:	56                   	push   %esi
80104c93:	53                   	push   %ebx
80104c94:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104c97:	e8 21 fb ff ff       	call   801047bd <allocproc>
80104c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104c9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104ca3:	75 0a                	jne    80104caf <fork+0x21>
    return -1;
80104ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104caa:	e9 22 02 00 00       	jmp    80104ed1 <fork+0x243>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104caf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb5:	8b 10                	mov    (%eax),%edx
80104cb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cbd:	8b 40 04             	mov    0x4(%eax),%eax
80104cc0:	83 ec 08             	sub    $0x8,%esp
80104cc3:	52                   	push   %edx
80104cc4:	50                   	push   %eax
80104cc5:	e8 ff 51 00 00       	call   80109ec9 <copyuvm>
80104cca:	83 c4 10             	add    $0x10,%esp
80104ccd:	89 c2                	mov    %eax,%edx
80104ccf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cd2:	89 50 04             	mov    %edx,0x4(%eax)
80104cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cd8:	8b 40 04             	mov    0x4(%eax),%eax
80104cdb:	85 c0                	test   %eax,%eax
80104cdd:	75 68                	jne    80104d47 <fork+0xb9>
    kfree(np->kstack);
80104cdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ce2:	8b 40 08             	mov    0x8(%eax),%eax
80104ce5:	83 ec 0c             	sub    $0xc,%esp
80104ce8:	50                   	push   %eax
80104ce9:	e8 1e e2 ff ff       	call   80102f0c <kfree>
80104cee:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104cf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cf4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#ifdef CS333_P3P4
    assertState(np,EMBRYO);
80104cfb:	83 ec 08             	sub    $0x8,%esp
80104cfe:	6a 01                	push   $0x1
80104d00:	ff 75 e0             	pushl  -0x20(%ebp)
80104d03:	e8 a8 14 00 00       	call   801061b0 <assertState>
80104d08:	83 c4 10             	add    $0x10,%esp
    removeFromStateList(&ptable.pLists.embryo,np);
80104d0b:	83 ec 08             	sub    $0x8,%esp
80104d0e:	ff 75 e0             	pushl  -0x20(%ebp)
80104d11:	68 10 71 11 80       	push   $0x80117110
80104d16:	e8 7d 15 00 00       	call   80106298 <removeFromStateList>
80104d1b:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80104d1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d21:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    addToStateListHead(&ptable.pLists.free,np,EMBRYO);
80104d28:	83 ec 04             	sub    $0x4,%esp
80104d2b:	6a 01                	push   $0x1
80104d2d:	ff 75 e0             	pushl  -0x20(%ebp)
80104d30:	68 00 71 11 80       	push   $0x80117100
80104d35:	e8 c0 14 00 00       	call   801061fa <addToStateListHead>
80104d3a:	83 c4 10             	add    $0x10,%esp
#else
    np->state = UNUSED;
#endif
    return -1;
80104d3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d42:	e9 8a 01 00 00       	jmp    80104ed1 <fork+0x243>
  }
  np->sz = proc->sz;
80104d47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d4d:	8b 10                	mov    (%eax),%edx
80104d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d52:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104d54:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d5e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d64:	8b 50 18             	mov    0x18(%eax),%edx
80104d67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d6d:	8b 40 18             	mov    0x18(%eax),%eax
80104d70:	89 c3                	mov    %eax,%ebx
80104d72:	b8 13 00 00 00       	mov    $0x13,%eax
80104d77:	89 d7                	mov    %edx,%edi
80104d79:	89 de                	mov    %ebx,%esi
80104d7b:	89 c1                	mov    %eax,%ecx
80104d7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

#ifdef  CS333_P2
  np->uid = np->parent->uid;
80104d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d82:	8b 40 14             	mov    0x14(%eax),%eax
80104d85:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d8e:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  np->gid = np->parent->gid;
80104d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d97:	8b 40 14             	mov    0x14(%eax),%eax
80104d9a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104da3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dac:	8b 40 18             	mov    0x18(%eax),%eax
80104daf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104db6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104dbd:	eb 43                	jmp    80104e02 <fork+0x174>
    if(proc->ofile[i])
80104dbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104dc8:	83 c2 08             	add    $0x8,%edx
80104dcb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104dcf:	85 c0                	test   %eax,%eax
80104dd1:	74 2b                	je     80104dfe <fork+0x170>
      np->ofile[i] = filedup(proc->ofile[i]);
80104dd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ddc:	83 c2 08             	add    $0x8,%edx
80104ddf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104de3:	83 ec 0c             	sub    $0xc,%esp
80104de6:	50                   	push   %eax
80104de7:	e8 49 c3 ff ff       	call   80101135 <filedup>
80104dec:	83 c4 10             	add    $0x10,%esp
80104def:	89 c1                	mov    %eax,%ecx
80104df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104df4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104df7:	83 c2 08             	add    $0x8,%edx
80104dfa:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->gid = np->parent->gid;
#endif
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104dfe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104e02:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104e06:	7e b7                	jle    80104dbf <fork+0x131>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104e08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e0e:	8b 40 68             	mov    0x68(%eax),%eax
80104e11:	83 ec 0c             	sub    $0xc,%esp
80104e14:	50                   	push   %eax
80104e15:	e8 8f cc ff ff       	call   80101aa9 <idup>
80104e1a:	83 c4 10             	add    $0x10,%esp
80104e1d:	89 c2                	mov    %eax,%edx
80104e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e22:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104e25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e2b:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e31:	83 c0 6c             	add    $0x6c,%eax
80104e34:	83 ec 04             	sub    $0x4,%esp
80104e37:	6a 10                	push   $0x10
80104e39:	52                   	push   %edx
80104e3a:	50                   	push   %eax
80104e3b:	e8 0f 1f 00 00       	call   80106d4f <safestrcpy>
80104e40:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e46:	8b 40 10             	mov    0x10(%eax),%eax
80104e49:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	68 a0 49 11 80       	push   $0x801149a0
80104e54:	e8 90 1a 00 00       	call   801068e9 <acquire>
80104e59:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
  assertState(np,EMBRYO);
80104e5c:	83 ec 08             	sub    $0x8,%esp
80104e5f:	6a 01                	push   $0x1
80104e61:	ff 75 e0             	pushl  -0x20(%ebp)
80104e64:	e8 47 13 00 00       	call   801061b0 <assertState>
80104e69:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.embryo,np);
80104e6c:	83 ec 08             	sub    $0x8,%esp
80104e6f:	ff 75 e0             	pushl  -0x20(%ebp)
80104e72:	68 10 71 11 80       	push   $0x80117110
80104e77:	e8 1c 14 00 00       	call   80106298 <removeFromStateList>
80104e7c:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e82:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->priority =0;
80104e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e8c:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80104e93:	00 00 00 
  addToStateListEnd(&ptable.pLists.ready[np->priority],np);
80104e96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e99:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80104e9f:	05 cc 09 00 00       	add    $0x9cc,%eax
80104ea4:	c1 e0 02             	shl    $0x2,%eax
80104ea7:	05 a0 49 11 80       	add    $0x801149a0,%eax
80104eac:	83 c0 04             	add    $0x4,%eax
80104eaf:	83 ec 08             	sub    $0x8,%esp
80104eb2:	ff 75 e0             	pushl  -0x20(%ebp)
80104eb5:	50                   	push   %eax
80104eb6:	e8 73 13 00 00       	call   8010622e <addToStateListEnd>
80104ebb:	83 c4 10             	add    $0x10,%esp
#else
  np->state = RUNNABLE;
#endif
  release(&ptable.lock);
80104ebe:	83 ec 0c             	sub    $0xc,%esp
80104ec1:	68 a0 49 11 80       	push   $0x801149a0
80104ec6:	e8 85 1a 00 00       	call   80106950 <release>
80104ecb:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104ece:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ed4:	5b                   	pop    %ebx
80104ed5:	5e                   	pop    %esi
80104ed6:	5f                   	pop    %edi
80104ed7:	5d                   	pop    %ebp
80104ed8:	c3                   	ret    

80104ed9 <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 18             	sub    $0x18,%esp
    struct proc * p;
    int fd;

    if(proc == initproc)
80104edf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ee6:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80104eeb:	39 c2                	cmp    %eax,%edx
80104eed:	75 0d                	jne    80104efc <exit+0x23>
        panic("Exiting");
80104eef:	83 ec 0c             	sub    $0xc,%esp
80104ef2:	68 67 a4 10 80       	push   $0x8010a467
80104ef7:	e8 6a b6 ff ff       	call   80100566 <panic>
    for(fd =0; fd < NOFILE; fd++){
80104efc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f03:	eb 48                	jmp    80104f4d <exit+0x74>
        if(proc->ofile[fd]){
80104f05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f0e:	83 c2 08             	add    $0x8,%edx
80104f11:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f15:	85 c0                	test   %eax,%eax
80104f17:	74 30                	je     80104f49 <exit+0x70>
            fileclose(proc->ofile[fd]);
80104f19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f22:	83 c2 08             	add    $0x8,%edx
80104f25:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f29:	83 ec 0c             	sub    $0xc,%esp
80104f2c:	50                   	push   %eax
80104f2d:	e8 54 c2 ff ff       	call   80101186 <fileclose>
80104f32:	83 c4 10             	add    $0x10,%esp
                    proc->ofile[fd] = 0;
80104f35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f3e:	83 c2 08             	add    $0x8,%edx
80104f41:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104f48:	00 
    struct proc * p;
    int fd;

    if(proc == initproc)
        panic("Exiting");
    for(fd =0; fd < NOFILE; fd++){
80104f49:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f4d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104f51:	7e b2                	jle    80104f05 <exit+0x2c>
            fileclose(proc->ofile[fd]);
                    proc->ofile[fd] = 0;
        }
    }

        begin_op();
80104f53:	e8 38 e9 ff ff       	call   80103890 <begin_op>
        iput(proc->cwd);
80104f58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f5e:	8b 40 68             	mov    0x68(%eax),%eax
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	50                   	push   %eax
80104f65:	e8 71 cd ff ff       	call   80101cdb <iput>
80104f6a:	83 c4 10             	add    $0x10,%esp
        end_op();
80104f6d:	e8 aa e9 ff ff       	call   8010391c <end_op>
        proc->cwd = 0;
80104f72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f78:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

        acquire(&ptable.lock);
80104f7f:	83 ec 0c             	sub    $0xc,%esp
80104f82:	68 a0 49 11 80       	push   $0x801149a0
80104f87:	e8 5d 19 00 00       	call   801068e9 <acquire>
80104f8c:	83 c4 10             	add    $0x10,%esp
        wakeup1(proc->parent);
80104f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f95:	8b 40 14             	mov    0x14(%eax),%eax
80104f98:	83 ec 0c             	sub    $0xc,%esp
80104f9b:	50                   	push   %eax
80104f9c:	e8 0f 0a 00 00       	call   801059b0 <wakeup1>
80104fa1:	83 c4 10             	add    $0x10,%esp

        p = ptable.pLists.running;
80104fa4:	a1 0c 71 11 80       	mov    0x8011710c,%eax
80104fa9:	89 45 f4             	mov    %eax,-0xc(%ebp)

        while(p){
80104fac:	eb 44                	jmp    80104ff2 <exit+0x119>
            if(p->parent == proc){
80104fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb1:	8b 50 14             	mov    0x14(%eax),%edx
80104fb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fba:	39 c2                	cmp    %eax,%edx
80104fbc:	75 28                	jne    80104fe6 <exit+0x10d>
                p->parent = initproc;
80104fbe:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80104fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc7:	89 50 14             	mov    %edx,0x14(%eax)
                    if(p->state == ZOMBIE)
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd0:	83 f8 05             	cmp    $0x5,%eax
80104fd3:	75 11                	jne    80104fe6 <exit+0x10d>
                        wakeup1(initproc);
80104fd5:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80104fda:	83 ec 0c             	sub    $0xc,%esp
80104fdd:	50                   	push   %eax
80104fde:	e8 cd 09 00 00       	call   801059b0 <wakeup1>
80104fe3:	83 c4 10             	add    $0x10,%esp
                }
                p = p->next;
80104fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
        acquire(&ptable.lock);
        wakeup1(proc->parent);

        p = ptable.pLists.running;

        while(p){
80104ff2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ff6:	75 b6                	jne    80104fae <exit+0xd5>
                    if(p->state == ZOMBIE)
                        wakeup1(initproc);
                }
                p = p->next;
            }
        p = ptable.pLists.sleep;
80104ff8:	a1 04 71 11 80       	mov    0x80117104,%eax
80104ffd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(p){
80105000:	eb 44                	jmp    80105046 <exit+0x16d>
            if(p->parent == proc){
80105002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105005:	8b 50 14             	mov    0x14(%eax),%edx
80105008:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010500e:	39 c2                	cmp    %eax,%edx
80105010:	75 28                	jne    8010503a <exit+0x161>
                p->parent = initproc;
80105012:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80105018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501b:	89 50 14             	mov    %edx,0x14(%eax)
                if(p->state == ZOMBIE)
8010501e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105021:	8b 40 0c             	mov    0xc(%eax),%eax
80105024:	83 f8 05             	cmp    $0x5,%eax
80105027:	75 11                	jne    8010503a <exit+0x161>
                    wakeup1(initproc);
80105029:	a1 88 d6 10 80       	mov    0x8010d688,%eax
8010502e:	83 ec 0c             	sub    $0xc,%esp
80105031:	50                   	push   %eax
80105032:	e8 79 09 00 00       	call   801059b0 <wakeup1>
80105037:	83 c4 10             	add    $0x10,%esp
            }
            p = p->next;
8010503a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105043:	89 45 f4             	mov    %eax,-0xc(%ebp)
                        wakeup1(initproc);
                }
                p = p->next;
            }
        p = ptable.pLists.sleep;
        while(p){
80105046:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010504a:	75 b6                	jne    80105002 <exit+0x129>
                    wakeup1(initproc);
            }
            p = p->next;
        }

    for(int i =0;i < MAX+1; ++i)
8010504c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105053:	eb 62                	jmp    801050b7 <exit+0x1de>
    {
        p = ptable.pLists.ready[i];
80105055:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105058:	05 cc 09 00 00       	add    $0x9cc,%eax
8010505d:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105064:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(p){
80105067:	eb 44                	jmp    801050ad <exit+0x1d4>
            if(p->parent == proc){
80105069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506c:	8b 50 14             	mov    0x14(%eax),%edx
8010506f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105075:	39 c2                	cmp    %eax,%edx
80105077:	75 28                	jne    801050a1 <exit+0x1c8>
                p->parent = initproc;
80105079:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	89 50 14             	mov    %edx,0x14(%eax)
                if(p->state == ZOMBIE)
80105085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105088:	8b 40 0c             	mov    0xc(%eax),%eax
8010508b:	83 f8 05             	cmp    $0x5,%eax
8010508e:	75 11                	jne    801050a1 <exit+0x1c8>
                    wakeup1(initproc);
80105090:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80105095:	83 ec 0c             	sub    $0xc,%esp
80105098:	50                   	push   %eax
80105099:	e8 12 09 00 00       	call   801059b0 <wakeup1>
8010509e:	83 c4 10             	add    $0x10,%esp
            }
            p = p->next;
801050a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801050aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }

    for(int i =0;i < MAX+1; ++i)
    {
        p = ptable.pLists.ready[i];
        while(p){
801050ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050b1:	75 b6                	jne    80105069 <exit+0x190>
                    wakeup1(initproc);
            }
            p = p->next;
        }

    for(int i =0;i < MAX+1; ++i)
801050b3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801050b7:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
801050bb:	7e 98                	jle    80105055 <exit+0x17c>
            }
            p = p->next;
        }
    }

        p = ptable.pLists.zombie;
801050bd:	a1 08 71 11 80       	mov    0x80117108,%eax
801050c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(p){
801050c5:	eb 44                	jmp    8010510b <exit+0x232>
            if(p->parent == proc){
801050c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ca:	8b 50 14             	mov    0x14(%eax),%edx
801050cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d3:	39 c2                	cmp    %eax,%edx
801050d5:	75 28                	jne    801050ff <exit+0x226>
                p->parent = initproc;
801050d7:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
801050dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e0:	89 50 14             	mov    %edx,0x14(%eax)
                if(p->state == ZOMBIE)
801050e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e6:	8b 40 0c             	mov    0xc(%eax),%eax
801050e9:	83 f8 05             	cmp    $0x5,%eax
801050ec:	75 11                	jne    801050ff <exit+0x226>
                    wakeup1(initproc);
801050ee:	a1 88 d6 10 80       	mov    0x8010d688,%eax
801050f3:	83 ec 0c             	sub    $0xc,%esp
801050f6:	50                   	push   %eax
801050f7:	e8 b4 08 00 00       	call   801059b0 <wakeup1>
801050fc:	83 c4 10             	add    $0x10,%esp
            }
            p = p->next;
801050ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105102:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105108:	89 45 f4             	mov    %eax,-0xc(%ebp)
            p = p->next;
        }
    }

        p = ptable.pLists.zombie;
        while(p){
8010510b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010510f:	75 b6                	jne    801050c7 <exit+0x1ee>
                if(p->state == ZOMBIE)
                    wakeup1(initproc);
            }
            p = p->next;
        }
        p = ptable.pLists.embryo;
80105111:	a1 10 71 11 80       	mov    0x80117110,%eax
80105116:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(p){
80105119:	eb 44                	jmp    8010515f <exit+0x286>
            if(p->parent == proc){
8010511b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511e:	8b 50 14             	mov    0x14(%eax),%edx
80105121:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105127:	39 c2                	cmp    %eax,%edx
80105129:	75 28                	jne    80105153 <exit+0x27a>
                p->parent = initproc;
8010512b:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80105131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105134:	89 50 14             	mov    %edx,0x14(%eax)
                if(p->state == ZOMBIE)
80105137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513a:	8b 40 0c             	mov    0xc(%eax),%eax
8010513d:	83 f8 05             	cmp    $0x5,%eax
80105140:	75 11                	jne    80105153 <exit+0x27a>
                    wakeup1(initproc);
80105142:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80105147:	83 ec 0c             	sub    $0xc,%esp
8010514a:	50                   	push   %eax
8010514b:	e8 60 08 00 00       	call   801059b0 <wakeup1>
80105150:	83 c4 10             	add    $0x10,%esp
            }
            p = p->next;
80105153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105156:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010515c:	89 45 f4             	mov    %eax,-0xc(%ebp)
                    wakeup1(initproc);
            }
            p = p->next;
        }
        p = ptable.pLists.embryo;
        while(p){
8010515f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105163:	75 b6                	jne    8010511b <exit+0x242>
                    wakeup1(initproc);
            }
            p = p->next;
        }

        if(removeFromStateList(&ptable.pLists.running,proc) == 0){
80105165:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010516b:	83 ec 08             	sub    $0x8,%esp
8010516e:	50                   	push   %eax
8010516f:	68 0c 71 11 80       	push   $0x8011710c
80105174:	e8 1f 11 00 00       	call   80106298 <removeFromStateList>
80105179:	83 c4 10             	add    $0x10,%esp
8010517c:	85 c0                	test   %eax,%eax
8010517e:	75 38                	jne    801051b8 <exit+0x2df>
            proc->state = ZOMBIE;
80105180:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105186:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
            addToStateListHead(&ptable.pLists.zombie,proc,ZOMBIE);
8010518d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105193:	83 ec 04             	sub    $0x4,%esp
80105196:	6a 05                	push   $0x5
80105198:	50                   	push   %eax
80105199:	68 08 71 11 80       	push   $0x80117108
8010519e:	e8 57 10 00 00       	call   801061fa <addToStateListHead>
801051a3:	83 c4 10             	add    $0x10,%esp
        }
        else
            panic("ERROR!!]n");
        sched();
801051a6:	e8 20 04 00 00       	call   801055cb <sched>
        panic("Exit Zombie");
801051ab:	83 ec 0c             	sub    $0xc,%esp
801051ae:	68 79 a4 10 80       	push   $0x8010a479
801051b3:	e8 ae b3 ff ff       	call   80100566 <panic>
        if(removeFromStateList(&ptable.pLists.running,proc) == 0){
            proc->state = ZOMBIE;
            addToStateListHead(&ptable.pLists.zombie,proc,ZOMBIE);
        }
        else
            panic("ERROR!!]n");
801051b8:	83 ec 0c             	sub    $0xc,%esp
801051bb:	68 6f a4 10 80       	push   $0x8010a46f
801051c0:	e8 a1 b3 ff ff       	call   80100566 <panic>

801051c5 <wait>:
  }
}
#else
int
wait(void)
{
801051c5:	55                   	push   %ebp
801051c6:	89 e5                	mov    %esp,%ebp
801051c8:	83 ec 38             	sub    $0x38,%esp
    struct proc * p_running;
    struct proc * p_sleep;

    int pid, havekids;

    acquire(&ptable.lock);
801051cb:	83 ec 0c             	sub    $0xc,%esp
801051ce:	68 a0 49 11 80       	push   $0x801149a0
801051d3:	e8 11 17 00 00       	call   801068e9 <acquire>
801051d8:	83 c4 10             	add    $0x10,%esp
    for(;;){
        havekids = 0;
801051db:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
        p_zombie = ptable.pLists.zombie;
801051e2:	a1 08 71 11 80       	mov    0x80117108,%eax
801051e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(p_zombie){
801051ea:	e9 f3 00 00 00       	jmp    801052e2 <wait+0x11d>
            if(p_zombie->parent == proc){
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	8b 50 14             	mov    0x14(%eax),%edx
801051f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051fb:	39 c2                	cmp    %eax,%edx
801051fd:	0f 85 d3 00 00 00    	jne    801052d6 <wait+0x111>
                havekids = 1;
80105203:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
                assertState(p_zombie,ZOMBIE);
8010520a:	83 ec 08             	sub    $0x8,%esp
8010520d:	6a 05                	push   $0x5
8010520f:	ff 75 f4             	pushl  -0xc(%ebp)
80105212:	e8 99 0f 00 00       	call   801061b0 <assertState>
80105217:	83 c4 10             	add    $0x10,%esp
                int rc = removeFromStateList(&ptable.pLists.zombie,p_zombie);
8010521a:	83 ec 08             	sub    $0x8,%esp
8010521d:	ff 75 f4             	pushl  -0xc(%ebp)
80105220:	68 08 71 11 80       	push   $0x80117108
80105225:	e8 6e 10 00 00       	call   80106298 <removeFromStateList>
8010522a:	83 c4 10             	add    $0x10,%esp
8010522d:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if(rc == -1)
80105230:	83 7d d8 ff          	cmpl   $0xffffffff,-0x28(%ebp)
80105234:	75 0d                	jne    80105243 <wait+0x7e>
                    panic("ERROR(Not In Zombie)");
80105236:	83 ec 0c             	sub    $0xc,%esp
80105239:	68 85 a4 10 80       	push   $0x8010a485
8010523e:	e8 23 b3 ff ff       	call   80100566 <panic>
                pid = p_zombie->pid;
80105243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105246:	8b 40 10             	mov    0x10(%eax),%eax
80105249:	89 45 d4             	mov    %eax,-0x2c(%ebp)
                kfree(p_zombie->kstack);
8010524c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524f:	8b 40 08             	mov    0x8(%eax),%eax
80105252:	83 ec 0c             	sub    $0xc,%esp
80105255:	50                   	push   %eax
80105256:	e8 b1 dc ff ff       	call   80102f0c <kfree>
8010525b:	83 c4 10             	add    $0x10,%esp
                p_zombie->kstack =0;
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
                freevm(p_zombie->pgdir);
80105268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526b:	8b 40 04             	mov    0x4(%eax),%eax
8010526e:	83 ec 0c             	sub    $0xc,%esp
80105271:	50                   	push   %eax
80105272:	e8 71 4b 00 00       	call   80109de8 <freevm>
80105277:	83 c4 10             	add    $0x10,%esp
                p_zombie->state = UNUSED;
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
                addToStateListHead(&ptable.pLists.free,p_zombie,UNUSED);
80105284:	83 ec 04             	sub    $0x4,%esp
80105287:	6a 00                	push   $0x0
80105289:	ff 75 f4             	pushl  -0xc(%ebp)
8010528c:	68 00 71 11 80       	push   $0x80117100
80105291:	e8 64 0f 00 00       	call   801061fa <addToStateListHead>
80105296:	83 c4 10             	add    $0x10,%esp
                p_zombie->pid =0;
80105299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
                p_zombie->parent =0;
801052a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
                p_zombie->name[0] =0;
801052ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
                p_zombie->killed =0;
801052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
                release(&ptable.lock);
801052be:	83 ec 0c             	sub    $0xc,%esp
801052c1:	68 a0 49 11 80       	push   $0x801149a0
801052c6:	e8 85 16 00 00       	call   80106950 <release>
801052cb:	83 c4 10             	add    $0x10,%esp
                return pid;
801052ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801052d1:	e9 45 01 00 00       	jmp    8010541b <wait+0x256>
            }
            p_zombie = p_zombie->next;
801052d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801052df:	89 45 f4             	mov    %eax,-0xc(%ebp)

    acquire(&ptable.lock);
    for(;;){
        havekids = 0;
        p_zombie = ptable.pLists.zombie;
        while(p_zombie){
801052e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052e6:	0f 85 03 ff ff ff    	jne    801051ef <wait+0x2a>
                return pid;
            }
            p_zombie = p_zombie->next;
        }

        p_embryo = ptable.pLists.embryo;
801052ec:	a1 10 71 11 80       	mov    0x80117110,%eax
801052f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while(p_embryo){
801052f4:	eb 23                	jmp    80105319 <wait+0x154>
            if(p_embryo->parent == proc)
801052f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f9:	8b 50 14             	mov    0x14(%eax),%edx
801052fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105302:	39 c2                	cmp    %eax,%edx
80105304:	75 07                	jne    8010530d <wait+0x148>
                havekids =1;
80105306:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
            p_embryo = p_embryo->next;
8010530d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105310:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105316:	89 45 f0             	mov    %eax,-0x10(%ebp)
            }
            p_zombie = p_zombie->next;
        }

        p_embryo = ptable.pLists.embryo;
        while(p_embryo){
80105319:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010531d:	75 d7                	jne    801052f6 <wait+0x131>
            if(p_embryo->parent == proc)
                havekids =1;
            p_embryo = p_embryo->next;
        }

    for(int i =0;i< MAX+1; ++i)
8010531f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80105326:	eb 41                	jmp    80105369 <wait+0x1a4>
    {
        p_ready = ptable.pLists.ready[i];
80105328:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010532b:	05 cc 09 00 00       	add    $0x9cc,%eax
80105330:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105337:	89 45 ec             	mov    %eax,-0x14(%ebp)
        while(p_ready){
8010533a:	eb 23                	jmp    8010535f <wait+0x19a>
            if(p_ready->parent == proc)
8010533c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010533f:	8b 50 14             	mov    0x14(%eax),%edx
80105342:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105348:	39 c2                	cmp    %eax,%edx
8010534a:	75 07                	jne    80105353 <wait+0x18e>
                havekids =1;
8010534c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
            p_ready = p_ready->next;
80105353:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105356:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010535c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        }

    for(int i =0;i< MAX+1; ++i)
    {
        p_ready = ptable.pLists.ready[i];
        while(p_ready){
8010535f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105363:	75 d7                	jne    8010533c <wait+0x177>
            if(p_embryo->parent == proc)
                havekids =1;
            p_embryo = p_embryo->next;
        }

    for(int i =0;i< MAX+1; ++i)
80105365:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80105369:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
8010536d:	7e b9                	jle    80105328 <wait+0x163>
                havekids =1;
            p_ready = p_ready->next;
        }
    }

        p_running = ptable.pLists.running;
8010536f:	a1 0c 71 11 80       	mov    0x8011710c,%eax
80105374:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while(p_running){
80105377:	eb 23                	jmp    8010539c <wait+0x1d7>
            if(p_running->parent == proc)
80105379:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010537c:	8b 50 14             	mov    0x14(%eax),%edx
8010537f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105385:	39 c2                	cmp    %eax,%edx
80105387:	75 07                	jne    80105390 <wait+0x1cb>
                havekids =1;
80105389:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
            p_running = p_running->next;
80105390:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105393:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105399:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p_ready = p_ready->next;
        }
    }

        p_running = ptable.pLists.running;
        while(p_running){
8010539c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801053a0:	75 d7                	jne    80105379 <wait+0x1b4>
            if(p_running->parent == proc)
                havekids =1;
            p_running = p_running->next;
        }
        p_sleep = ptable.pLists.sleep;
801053a2:	a1 04 71 11 80       	mov    0x80117104,%eax
801053a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while(p_sleep){
801053aa:	eb 23                	jmp    801053cf <wait+0x20a>
            if(p_sleep->parent == proc)
801053ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801053af:	8b 50 14             	mov    0x14(%eax),%edx
801053b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b8:	39 c2                	cmp    %eax,%edx
801053ba:	75 07                	jne    801053c3 <wait+0x1fe>
                havekids =1;
801053bc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
            p_sleep = p_sleep->next;
801053c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801053c6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801053cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if(p_running->parent == proc)
                havekids =1;
            p_running = p_running->next;
        }
        p_sleep = ptable.pLists.sleep;
        while(p_sleep){
801053cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801053d3:	75 d7                	jne    801053ac <wait+0x1e7>
            if(p_sleep->parent == proc)
                havekids =1;
            p_sleep = p_sleep->next;
        }

        if(!havekids || proc->killed){
801053d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801053d9:	74 0d                	je     801053e8 <wait+0x223>
801053db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e1:	8b 40 24             	mov    0x24(%eax),%eax
801053e4:	85 c0                	test   %eax,%eax
801053e6:	74 17                	je     801053ff <wait+0x23a>
            release(&ptable.lock);
801053e8:	83 ec 0c             	sub    $0xc,%esp
801053eb:	68 a0 49 11 80       	push   $0x801149a0
801053f0:	e8 5b 15 00 00       	call   80106950 <release>
801053f5:	83 c4 10             	add    $0x10,%esp
            return -1;
801053f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fd:	eb 1c                	jmp    8010541b <wait+0x256>
        }
        sleep(proc,&ptable.lock);
801053ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105405:	83 ec 08             	sub    $0x8,%esp
80105408:	68 a0 49 11 80       	push   $0x801149a0
8010540d:	50                   	push   %eax
8010540e:	e8 3e 04 00 00       	call   80105851 <sleep>
80105413:	83 c4 10             	add    $0x10,%esp
    }
80105416:	e9 c0 fd ff ff       	jmp    801051db <wait+0x16>

  return 0;  // placeholder
}
8010541b:	c9                   	leave  
8010541c:	c3                   	ret    

8010541d <scheduler>:
}

#else
void
scheduler(void)
{
8010541d:	55                   	push   %ebp
8010541e:	89 e5                	mov    %esp,%ebp
80105420:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105423:	e8 70 f3 ff ff       	call   80104798 <sti>

    idle = 1;  // assume idle unless we schedule a process
80105428:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);  
8010542f:	83 ec 0c             	sub    $0xc,%esp
80105432:	68 a0 49 11 80       	push   $0x801149a0
80105437:	e8 ad 14 00 00       	call   801068e9 <acquire>
8010543c:	83 c4 10             	add    $0x10,%esp
    
    if(ticks >= ptable.PromoteAtTime)
8010543f:	8b 15 14 71 11 80    	mov    0x80117114,%edx
80105445:	a1 20 79 11 80       	mov    0x80117920,%eax
8010544a:	39 c2                	cmp    %eax,%edx
8010544c:	77 61                	ja     801054af <scheduler+0x92>
    {
        for(int i=0; i <MAX+1;++i)
8010544e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105455:	eb 32                	jmp    80105489 <scheduler+0x6c>
        {
            ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80105457:	a1 20 79 11 80       	mov    0x80117920,%eax
8010545c:	05 58 1b 00 00       	add    $0x1b58,%eax
80105461:	a3 14 71 11 80       	mov    %eax,0x80117114
            promoteRunnable(&ptable.pLists.ready[i]);
80105466:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105469:	05 cc 09 00 00       	add    $0x9cc,%eax
8010546e:	c1 e0 02             	shl    $0x2,%eax
80105471:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105476:	83 c0 04             	add    $0x4,%eax
80105479:	83 ec 0c             	sub    $0xc,%esp
8010547c:	50                   	push   %eax
8010547d:	e8 1b 13 00 00       	call   8010679d <promoteRunnable>
80105482:	83 c4 10             	add    $0x10,%esp
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);  
    
    if(ticks >= ptable.PromoteAtTime)
    {
        for(int i=0; i <MAX+1;++i)
80105485:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105489:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010548d:	7e c8                	jle    80105457 <scheduler+0x3a>
        {
            ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
            promoteRunnable(&ptable.pLists.ready[i]);
        }
        promoteSR(&ptable.pLists.sleep);
8010548f:	83 ec 0c             	sub    $0xc,%esp
80105492:	68 04 71 11 80       	push   $0x80117104
80105497:	e8 9a 13 00 00       	call   80106836 <promoteSR>
8010549c:	83 c4 10             	add    $0x10,%esp
        promoteSR(&ptable.pLists.running);
8010549f:	83 ec 0c             	sub    $0xc,%esp
801054a2:	68 0c 71 11 80       	push   $0x8011710c
801054a7:	e8 8a 13 00 00       	call   80106836 <promoteSR>
801054ac:	83 c4 10             	add    $0x10,%esp
    }

    for(int i =0;i<MAX+1;++i)
801054af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801054b6:	e9 dd 00 00 00       	jmp    80105598 <scheduler+0x17b>
    {
        if(ptable.pLists.ready[i])
801054bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054be:	05 cc 09 00 00       	add    $0x9cc,%eax
801054c3:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
801054ca:	85 c0                	test   %eax,%eax
801054cc:	0f 84 c2 00 00 00    	je     80105594 <scheduler+0x177>
        {
            p = ptable.pLists.ready[i];
801054d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054d5:	05 cc 09 00 00       	add    $0x9cc,%eax
801054da:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
801054e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
            assertState(p,RUNNABLE);
801054e4:	83 ec 08             	sub    $0x8,%esp
801054e7:	6a 03                	push   $0x3
801054e9:	ff 75 e8             	pushl  -0x18(%ebp)
801054ec:	e8 bf 0c 00 00       	call   801061b0 <assertState>
801054f1:	83 c4 10             	add    $0x10,%esp
            removeFromStateList(&ptable.pLists.ready[i],p);
801054f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054f7:	05 cc 09 00 00       	add    $0x9cc,%eax
801054fc:	c1 e0 02             	shl    $0x2,%eax
801054ff:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105504:	83 c0 04             	add    $0x4,%eax
80105507:	83 ec 08             	sub    $0x8,%esp
8010550a:	ff 75 e8             	pushl  -0x18(%ebp)
8010550d:	50                   	push   %eax
8010550e:	e8 85 0d 00 00       	call   80106298 <removeFromStateList>
80105513:	83 c4 10             	add    $0x10,%esp


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
          idle = 0;  // not idle this timeslice
80105516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
          proc = p;
8010551d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105520:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
          switchuvm(p);
80105526:	83 ec 0c             	sub    $0xc,%esp
80105529:	ff 75 e8             	pushl  -0x18(%ebp)
8010552c:	e8 71 44 00 00       	call   801099a2 <switchuvm>
80105531:	83 c4 10             	add    $0x10,%esp
          p->state = RUNNING;
80105534:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105537:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          addToStateListHead(&ptable.pLists.running,p,RUNNING);
8010553e:	83 ec 04             	sub    $0x4,%esp
80105541:	6a 04                	push   $0x4
80105543:	ff 75 e8             	pushl  -0x18(%ebp)
80105546:	68 0c 71 11 80       	push   $0x8011710c
8010554b:	e8 aa 0c 00 00       	call   801061fa <addToStateListHead>
80105550:	83 c4 10             	add    $0x10,%esp
          swtch(&cpu->scheduler, proc->context);
80105553:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105559:	8b 40 1c             	mov    0x1c(%eax),%eax
8010555c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105563:	83 c2 04             	add    $0x4,%edx
80105566:	83 ec 08             	sub    $0x8,%esp
80105569:	50                   	push   %eax
8010556a:	52                   	push   %edx
8010556b:	e8 50 18 00 00       	call   80106dc0 <swtch>
80105570:	83 c4 10             	add    $0x10,%esp
          switchkvm();
80105573:	e8 0d 44 00 00       	call   80109985 <switchkvm>


#ifdef CS333_P2
      //to start the time
            p->ticks_in_cpu = ticks;
80105578:	8b 15 20 79 11 80    	mov    0x80117920,%edx
8010557e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105581:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
#endif
      // Process is done running for now.
      // It should have changed its p->state before coming back.
          proc = 0;
80105587:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010558e:	00 00 00 00 
          break;
80105592:	eb 0e                	jmp    801055a2 <scheduler+0x185>
        }
        promoteSR(&ptable.pLists.sleep);
        promoteSR(&ptable.pLists.running);
    }

    for(int i =0;i<MAX+1;++i)
80105594:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105598:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
8010559c:	0f 8e 19 ff ff ff    	jle    801054bb <scheduler+0x9e>
      // It should have changed its p->state before coming back.
          proc = 0;
          break;
        }
    }
    release(&ptable.lock);
801055a2:	83 ec 0c             	sub    $0xc,%esp
801055a5:	68 a0 49 11 80       	push   $0x801149a0
801055aa:	e8 a1 13 00 00       	call   80106950 <release>
801055af:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
801055b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055b6:	0f 84 67 fe ff ff    	je     80105423 <scheduler+0x6>
      sti();
801055bc:	e8 d7 f1 ff ff       	call   80104798 <sti>
      hlt();
801055c1:	e8 bb f1 ff ff       	call   80104781 <hlt>
        }
      }
801055c6:	e9 58 fe ff ff       	jmp    80105423 <scheduler+0x6>

801055cb <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801055cb:	55                   	push   %ebp
801055cc:	89 e5                	mov    %esp,%ebp
801055ce:	53                   	push   %ebx
801055cf:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
801055d2:	83 ec 0c             	sub    $0xc,%esp
801055d5:	68 a0 49 11 80       	push   $0x801149a0
801055da:	e8 3d 14 00 00       	call   80106a1c <holding>
801055df:	83 c4 10             	add    $0x10,%esp
801055e2:	85 c0                	test   %eax,%eax
801055e4:	75 0d                	jne    801055f3 <sched+0x28>
    panic("sched ptable.lock");
801055e6:	83 ec 0c             	sub    $0xc,%esp
801055e9:	68 9a a4 10 80       	push   $0x8010a49a
801055ee:	e8 73 af ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801055f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055f9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055ff:	83 f8 01             	cmp    $0x1,%eax
80105602:	74 0d                	je     80105611 <sched+0x46>
    panic("sched locks");
80105604:	83 ec 0c             	sub    $0xc,%esp
80105607:	68 ac a4 10 80       	push   $0x8010a4ac
8010560c:	e8 55 af ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105617:	8b 40 0c             	mov    0xc(%eax),%eax
8010561a:	83 f8 04             	cmp    $0x4,%eax
8010561d:	75 0d                	jne    8010562c <sched+0x61>
    panic("sched running");
8010561f:	83 ec 0c             	sub    $0xc,%esp
80105622:	68 b8 a4 10 80       	push   $0x8010a4b8
80105627:	e8 3a af ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010562c:	e8 57 f1 ff ff       	call   80104788 <readeflags>
80105631:	25 00 02 00 00       	and    $0x200,%eax
80105636:	85 c0                	test   %eax,%eax
80105638:	74 0d                	je     80105647 <sched+0x7c>
    panic("sched interruptible");
8010563a:	83 ec 0c             	sub    $0xc,%esp
8010563d:	68 c6 a4 10 80       	push   $0x8010a4c6
80105642:	e8 1f af ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105647:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010564d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105653:	89 45 f4             	mov    %eax,-0xc(%ebp)


#ifdef CS333_P2
  //to get total running 
  proc->total_ticks_cpu += ticks - proc->ticks_in_cpu;
80105656:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105663:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80105669:	8b 1d 20 79 11 80    	mov    0x80117920,%ebx
8010566f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105676:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
8010567c:	29 d3                	sub    %edx,%ebx
8010567e:	89 da                	mov    %ebx,%edx
80105680:	01 ca                	add    %ecx,%edx
80105682:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
#endif

  swtch(&proc->context, cpu->scheduler);
80105688:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010568e:	8b 40 04             	mov    0x4(%eax),%eax
80105691:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105698:	83 c2 1c             	add    $0x1c,%edx
8010569b:	83 ec 08             	sub    $0x8,%esp
8010569e:	50                   	push   %eax
8010569f:	52                   	push   %edx
801056a0:	e8 1b 17 00 00       	call   80106dc0 <swtch>
801056a5:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801056a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056b1:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801056b7:	90                   	nop
801056b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056bb:	c9                   	leave  
801056bc:	c3                   	ret    

801056bd <yield>:
*/

// Give up the CPU for one scheduling round.
void
yield(void)
{
801056bd:	55                   	push   %ebp
801056be:	89 e5                	mov    %esp,%ebp
801056c0:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801056c3:	83 ec 0c             	sub    $0xc,%esp
801056c6:	68 a0 49 11 80       	push   $0x801149a0
801056cb:	e8 19 12 00 00       	call   801068e9 <acquire>
801056d0:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
    assertState(proc,RUNNING);
801056d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d9:	83 ec 08             	sub    $0x8,%esp
801056dc:	6a 04                	push   $0x4
801056de:	50                   	push   %eax
801056df:	e8 cc 0a 00 00       	call   801061b0 <assertState>
801056e4:	83 c4 10             	add    $0x10,%esp
    removeFromStateList(&ptable.pLists.running,proc);
801056e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ed:	83 ec 08             	sub    $0x8,%esp
801056f0:	50                   	push   %eax
801056f1:	68 0c 71 11 80       	push   $0x8011710c
801056f6:	e8 9d 0b 00 00       	call   80106298 <removeFromStateList>
801056fb:	83 c4 10             	add    $0x10,%esp
#endif
  proc->state = RUNNABLE;
801056fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105704:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
#ifdef CS333_P3P4
  int subtract = ticks - proc->ticks_in_cpu;
8010570b:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105717:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010571d:	29 c2                	sub    %eax,%edx
8010571f:	89 d0                	mov    %edx,%eax
80105721:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc->budget = proc->budget - subtract;
80105724:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105731:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105737:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010573a:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc->budget <=0)
80105740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105746:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010574c:	85 c0                	test   %eax,%eax
8010574e:	7f 71                	jg     801057c1 <yield+0x104>
  {
      proc->budget = BUDGET;
80105750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105756:	c7 80 98 00 00 00 d0 	movl   $0x7d0,0x98(%eax)
8010575d:	07 00 00 
      if(proc->priority < MAX)
80105760:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105766:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010576c:	83 f8 09             	cmp    $0x9,%eax
8010576f:	7f 1c                	jg     8010578d <yield+0xd0>
          proc->priority+=1;
80105771:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105777:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010577e:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
80105784:	83 c2 01             	add    $0x1,%edx
80105787:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)

      addToStateListEnd(&ptable.pLists.ready[proc->priority],proc);
8010578d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105793:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010579a:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
801057a0:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
801057a6:	c1 e2 02             	shl    $0x2,%edx
801057a9:	81 c2 a0 49 11 80    	add    $0x801149a0,%edx
801057af:	83 c2 04             	add    $0x4,%edx
801057b2:	83 ec 08             	sub    $0x8,%esp
801057b5:	50                   	push   %eax
801057b6:	52                   	push   %edx
801057b7:	e8 72 0a 00 00       	call   8010622e <addToStateListEnd>
801057bc:	83 c4 10             	add    $0x10,%esp
801057bf:	eb 32                	jmp    801057f3 <yield+0x136>
  }
  else
      addToStateListEnd(&ptable.pLists.ready[proc->priority],proc);
801057c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057ce:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
801057d4:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
801057da:	c1 e2 02             	shl    $0x2,%edx
801057dd:	81 c2 a0 49 11 80    	add    $0x801149a0,%edx
801057e3:	83 c2 04             	add    $0x4,%edx
801057e6:	83 ec 08             	sub    $0x8,%esp
801057e9:	50                   	push   %eax
801057ea:	52                   	push   %edx
801057eb:	e8 3e 0a 00 00       	call   8010622e <addToStateListEnd>
801057f0:	83 c4 10             	add    $0x10,%esp

#endif
  sched();
801057f3:	e8 d3 fd ff ff       	call   801055cb <sched>
  release(&ptable.lock);
801057f8:	83 ec 0c             	sub    $0xc,%esp
801057fb:	68 a0 49 11 80       	push   $0x801149a0
80105800:	e8 4b 11 00 00       	call   80106950 <release>
80105805:	83 c4 10             	add    $0x10,%esp
}
80105808:	90                   	nop
80105809:	c9                   	leave  
8010580a:	c3                   	ret    

8010580b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010580b:	55                   	push   %ebp
8010580c:	89 e5                	mov    %esp,%ebp
8010580e:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	68 a0 49 11 80       	push   $0x801149a0
80105819:	e8 32 11 00 00       	call   80106950 <release>
8010581e:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105821:	a1 20 d0 10 80       	mov    0x8010d020,%eax
80105826:	85 c0                	test   %eax,%eax
80105828:	74 24                	je     8010584e <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010582a:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
80105831:	00 00 00 
    iinit(ROOTDEV);
80105834:	83 ec 0c             	sub    $0xc,%esp
80105837:	6a 01                	push   $0x1
80105839:	e8 35 bf ff ff       	call   80101773 <iinit>
8010583e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105841:	83 ec 0c             	sub    $0xc,%esp
80105844:	6a 01                	push   $0x1
80105846:	e8 27 de ff ff       	call   80103672 <initlog>
8010584b:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
8010584e:	90                   	nop
8010584f:	c9                   	leave  
80105850:	c3                   	ret    

80105851 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80105851:	55                   	push   %ebp
80105852:	89 e5                	mov    %esp,%ebp
80105854:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585d:	85 c0                	test   %eax,%eax
8010585f:	75 0d                	jne    8010586e <sleep+0x1d>
    panic("sleep");
80105861:	83 ec 0c             	sub    $0xc,%esp
80105864:	68 da a4 10 80       	push   $0x8010a4da
80105869:	e8 f8 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
8010586e:	81 7d 0c a0 49 11 80 	cmpl   $0x801149a0,0xc(%ebp)
80105875:	74 24                	je     8010589b <sleep+0x4a>
    acquire(&ptable.lock);
80105877:	83 ec 0c             	sub    $0xc,%esp
8010587a:	68 a0 49 11 80       	push   $0x801149a0
8010587f:	e8 65 10 00 00       	call   801068e9 <acquire>
80105884:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80105887:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010588b:	74 0e                	je     8010589b <sleep+0x4a>
8010588d:	83 ec 0c             	sub    $0xc,%esp
80105890:	ff 75 0c             	pushl  0xc(%ebp)
80105893:	e8 b8 10 00 00       	call   80106950 <release>
80105898:	83 c4 10             	add    $0x10,%esp
  }
#ifdef CS333_P3P4
  assertState(proc,RUNNING);
8010589b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a1:	83 ec 08             	sub    $0x8,%esp
801058a4:	6a 04                	push   $0x4
801058a6:	50                   	push   %eax
801058a7:	e8 04 09 00 00       	call   801061b0 <assertState>
801058ac:	83 c4 10             	add    $0x10,%esp
  removeFromStateList(&ptable.pLists.running,proc);
801058af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058b5:	83 ec 08             	sub    $0x8,%esp
801058b8:	50                   	push   %eax
801058b9:	68 0c 71 11 80       	push   $0x8011710c
801058be:	e8 d5 09 00 00       	call   80106298 <removeFromStateList>
801058c3:	83 c4 10             	add    $0x10,%esp
  proc->chan = chan;
801058c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058cc:	8b 55 08             	mov    0x8(%ebp),%edx
801058cf:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  addToStateListHead(&ptable.pLists.sleep,proc,SLEEPING);
801058df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e5:	83 ec 04             	sub    $0x4,%esp
801058e8:	6a 02                	push   $0x2
801058ea:	50                   	push   %eax
801058eb:	68 04 71 11 80       	push   $0x80117104
801058f0:	e8 05 09 00 00       	call   801061fa <addToStateListHead>
801058f5:	83 c4 10             	add    $0x10,%esp
  int subtract = ticks - proc->ticks_in_cpu;
801058f8:	8b 15 20 79 11 80    	mov    0x80117920,%edx
801058fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105904:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010590a:	29 c2                	sub    %eax,%edx
8010590c:	89 d0                	mov    %edx,%eax
8010590e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc->budget -=subtract;
80105911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105917:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010591e:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105924:	2b 55 f4             	sub    -0xc(%ebp),%edx
80105927:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc->budget <= 0&&proc->priority < MAX)
8010592d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105933:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105939:	85 c0                	test   %eax,%eax
8010593b:	7f 31                	jg     8010596e <sleep+0x11d>
8010593d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105943:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105949:	83 f8 09             	cmp    $0x9,%eax
8010594c:	7f 20                	jg     8010596e <sleep+0x11d>
  {
      proc->budget = BUDGET;
8010594e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105954:	c7 80 98 00 00 00 d0 	movl   $0x7d0,0x98(%eax)
8010595b:	07 00 00 
      proc->priority =+1;
8010595e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105964:	c7 80 94 00 00 00 01 	movl   $0x1,0x94(%eax)
8010596b:	00 00 00 

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
#endif
  sched();
8010596e:	e8 58 fc ff ff       	call   801055cb <sched>

  // Tidy up.
  proc->chan = 0;
80105973:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105979:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
80105980:	81 7d 0c a0 49 11 80 	cmpl   $0x801149a0,0xc(%ebp)
80105987:	74 24                	je     801059ad <sleep+0x15c>
    release(&ptable.lock);
80105989:	83 ec 0c             	sub    $0xc,%esp
8010598c:	68 a0 49 11 80       	push   $0x801149a0
80105991:	e8 ba 0f 00 00       	call   80106950 <release>
80105996:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105999:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010599d:	74 0e                	je     801059ad <sleep+0x15c>
8010599f:	83 ec 0c             	sub    $0xc,%esp
801059a2:	ff 75 0c             	pushl  0xc(%ebp)
801059a5:	e8 3f 0f 00 00       	call   801068e9 <acquire>
801059aa:	83 c4 10             	add    $0x10,%esp
  }
}
801059ad:	90                   	nop
801059ae:	c9                   	leave  
801059af:	c3                   	ret    

801059b0 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
801059b0:	55                   	push   %ebp
801059b1:	89 e5                	mov    %esp,%ebp
801059b3:	83 ec 18             	sub    $0x18,%esp

    int rc;
    struct proc * current = ptable.pLists.sleep;
801059b6:	a1 04 71 11 80       	mov    0x80117104,%eax
801059bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct proc * hold;
    while(current){
801059be:	e9 a5 00 00 00       	jmp    80105a68 <wakeup1+0xb8>
        if(current->chan == chan && current ->state ==SLEEPING){
801059c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c6:	8b 40 20             	mov    0x20(%eax),%eax
801059c9:	3b 45 08             	cmp    0x8(%ebp),%eax
801059cc:	0f 85 8a 00 00 00    	jne    80105a5c <wakeup1+0xac>
801059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d5:	8b 40 0c             	mov    0xc(%eax),%eax
801059d8:	83 f8 02             	cmp    $0x2,%eax
801059db:	75 7f                	jne    80105a5c <wakeup1+0xac>
            assertState(current,SLEEPING);
801059dd:	83 ec 08             	sub    $0x8,%esp
801059e0:	6a 02                	push   $0x2
801059e2:	ff 75 f4             	pushl  -0xc(%ebp)
801059e5:	e8 c6 07 00 00       	call   801061b0 <assertState>
801059ea:	83 c4 10             	add    $0x10,%esp
            hold = current->next;
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801059f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

            rc = removeFromStateList(&ptable.pLists.sleep,current);
801059f9:	83 ec 08             	sub    $0x8,%esp
801059fc:	ff 75 f4             	pushl  -0xc(%ebp)
801059ff:	68 04 71 11 80       	push   $0x80117104
80105a04:	e8 8f 08 00 00       	call   80106298 <removeFromStateList>
80105a09:	83 c4 10             	add    $0x10,%esp
80105a0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if(rc == -1)
80105a0f:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105a13:	75 0d                	jne    80105a22 <wakeup1+0x72>
                panic ("Wake Up 1\n");
80105a15:	83 ec 0c             	sub    $0xc,%esp
80105a18:	68 e0 a4 10 80       	push   $0x8010a4e0
80105a1d:	e8 44 ab ff ff       	call   80100566 <panic>
            current ->state = RUNNABLE;
80105a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a25:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
            addToStateListEnd(&ptable.pLists.ready[current->priority],current);
80105a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105a35:	05 cc 09 00 00       	add    $0x9cc,%eax
80105a3a:	c1 e0 02             	shl    $0x2,%eax
80105a3d:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105a42:	83 c0 04             	add    $0x4,%eax
80105a45:	83 ec 08             	sub    $0x8,%esp
80105a48:	ff 75 f4             	pushl  -0xc(%ebp)
80105a4b:	50                   	push   %eax
80105a4c:	e8 dd 07 00 00       	call   8010622e <addToStateListEnd>
80105a51:	83 c4 10             	add    $0x10,%esp
            current = hold;
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a5a:	eb 0c                	jmp    80105a68 <wakeup1+0xb8>
        }
        else
            current = current->next;
80105a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
{

    int rc;
    struct proc * current = ptable.pLists.sleep;
    struct proc * hold;
    while(current){
80105a68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a6c:	0f 85 51 ff ff ff    	jne    801059c3 <wakeup1+0x13>
        }
        else
            current = current->next;
    }
    
}
80105a72:	90                   	nop
80105a73:	c9                   	leave  
80105a74:	c3                   	ret    

80105a75 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105a75:	55                   	push   %ebp
80105a76:	89 e5                	mov    %esp,%ebp
80105a78:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105a7b:	83 ec 0c             	sub    $0xc,%esp
80105a7e:	68 a0 49 11 80       	push   $0x801149a0
80105a83:	e8 61 0e 00 00       	call   801068e9 <acquire>
80105a88:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105a8b:	83 ec 0c             	sub    $0xc,%esp
80105a8e:	ff 75 08             	pushl  0x8(%ebp)
80105a91:	e8 1a ff ff ff       	call   801059b0 <wakeup1>
80105a96:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105a99:	83 ec 0c             	sub    $0xc,%esp
80105a9c:	68 a0 49 11 80       	push   $0x801149a0
80105aa1:	e8 aa 0e 00 00       	call   80106950 <release>
80105aa6:	83 c4 10             	add    $0x10,%esp
}
80105aa9:	90                   	nop
80105aaa:	c9                   	leave  
80105aab:	c3                   	ret    

80105aac <kill>:
}
#else

int
kill(int pid)
{
80105aac:	55                   	push   %ebp
80105aad:	89 e5                	mov    %esp,%ebp
80105aaf:	83 ec 28             	sub    $0x28,%esp
    struct proc * temp_running;
    struct proc * temp_zombie;

    int rc;
    //int success =0;
    acquire(&ptable.lock);
80105ab2:	83 ec 0c             	sub    $0xc,%esp
80105ab5:	68 a0 49 11 80       	push   $0x801149a0
80105aba:	e8 2a 0e 00 00       	call   801068e9 <acquire>
80105abf:	83 c4 10             	add    $0x10,%esp
    temp_sleep = ptable.pLists.sleep;
80105ac2:	a1 04 71 11 80       	mov    0x80117104,%eax
80105ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(temp_sleep){
80105aca:	e9 c8 00 00 00       	jmp    80105b97 <kill+0xeb>
        if(temp_sleep->pid ==pid){
80105acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad2:	8b 50 10             	mov    0x10(%eax),%edx
80105ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad8:	39 c2                	cmp    %eax,%edx
80105ada:	0f 85 ab 00 00 00    	jne    80105b8b <kill+0xdf>
            temp_sleep->killed = 1;
80105ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
            if(temp_sleep->state == SLEEPING){
80105aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aed:	8b 40 0c             	mov    0xc(%eax),%eax
80105af0:	83 f8 02             	cmp    $0x2,%eax
80105af3:	0f 85 92 00 00 00    	jne    80105b8b <kill+0xdf>
                assertState(temp_sleep,SLEEPING);
80105af9:	83 ec 08             	sub    $0x8,%esp
80105afc:	6a 02                	push   $0x2
80105afe:	ff 75 f4             	pushl  -0xc(%ebp)
80105b01:	e8 aa 06 00 00       	call   801061b0 <assertState>
80105b06:	83 c4 10             	add    $0x10,%esp
                rc = removeFromStateList(&ptable.pLists.sleep,temp_sleep);
80105b09:	83 ec 08             	sub    $0x8,%esp
80105b0c:	ff 75 f4             	pushl  -0xc(%ebp)
80105b0f:	68 04 71 11 80       	push   $0x80117104
80105b14:	e8 7f 07 00 00       	call   80106298 <removeFromStateList>
80105b19:	83 c4 10             	add    $0x10,%esp
80105b1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
                if(rc == -1)
80105b1f:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80105b23:	75 0d                	jne    80105b32 <kill+0x86>
                    panic ("Kill\n");
80105b25:	83 ec 0c             	sub    $0xc,%esp
80105b28:	68 eb a4 10 80       	push   $0x8010a4eb
80105b2d:	e8 34 aa ff ff       	call   80100566 <panic>
                temp_sleep->state = RUNNABLE;
80105b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b35:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
                temp_sleep->priority =0;
80105b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3f:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80105b46:	00 00 00 
                addToStateListEnd(&ptable.pLists.ready[temp_sleep->priority],temp_sleep);
80105b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4c:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105b52:	05 cc 09 00 00       	add    $0x9cc,%eax
80105b57:	c1 e0 02             	shl    $0x2,%eax
80105b5a:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105b5f:	83 c0 04             	add    $0x4,%eax
80105b62:	83 ec 08             	sub    $0x8,%esp
80105b65:	ff 75 f4             	pushl  -0xc(%ebp)
80105b68:	50                   	push   %eax
80105b69:	e8 c0 06 00 00       	call   8010622e <addToStateListEnd>
80105b6e:	83 c4 10             	add    $0x10,%esp
                release(&ptable.lock);
80105b71:	83 ec 0c             	sub    $0xc,%esp
80105b74:	68 a0 49 11 80       	push   $0x801149a0
80105b79:	e8 d2 0d 00 00       	call   80106950 <release>
80105b7e:	83 c4 10             	add    $0x10,%esp
                return 0;
80105b81:	b8 00 00 00 00       	mov    $0x0,%eax
80105b86:	e9 76 01 00 00       	jmp    80105d01 <kill+0x255>
            }
        }
        temp_sleep = temp_sleep->next;
80105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b94:	89 45 f4             	mov    %eax,-0xc(%ebp)

    int rc;
    //int success =0;
    acquire(&ptable.lock);
    temp_sleep = ptable.pLists.sleep;
    while(temp_sleep){
80105b97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b9b:	0f 85 2e ff ff ff    	jne    80105acf <kill+0x23>
            }
        }
        temp_sleep = temp_sleep->next;
    }
    //temp_ready= ptable.pLists.ready;
    temp_embryo = ptable.pLists.embryo;
80105ba1:	a1 10 71 11 80       	mov    0x80117110,%eax
80105ba6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    temp_running = ptable.pLists.running;
80105ba9:	a1 0c 71 11 80       	mov    0x8011710c,%eax
80105bae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    temp_zombie = ptable.pLists.zombie;
80105bb1:	a1 08 71 11 80       	mov    0x80117108,%eax
80105bb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
for(int i =0; i<MAX+1;++i)
80105bb9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80105bc0:	eb 5b                	jmp    80105c1d <kill+0x171>
{
    temp_ready = ptable.pLists.ready[i];
80105bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105bc5:	05 cc 09 00 00       	add    $0x9cc,%eax
80105bca:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105bd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(temp_ready){
80105bd4:	eb 3d                	jmp    80105c13 <kill+0x167>
        if(temp_ready->pid == pid){
80105bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd9:	8b 50 10             	mov    0x10(%eax),%edx
80105bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdf:	39 c2                	cmp    %eax,%edx
80105be1:	75 24                	jne    80105c07 <kill+0x15b>
            temp_ready->killed =1;
80105be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
            release(&ptable.lock);
80105bed:	83 ec 0c             	sub    $0xc,%esp
80105bf0:	68 a0 49 11 80       	push   $0x801149a0
80105bf5:	e8 56 0d 00 00       	call   80106950 <release>
80105bfa:	83 c4 10             	add    $0x10,%esp
            return -1;
80105bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c02:	e9 fa 00 00 00       	jmp    80105d01 <kill+0x255>
        }
        temp_ready = temp_ready->next;
80105c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0a:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    temp_zombie = ptable.pLists.zombie;
    
for(int i =0; i<MAX+1;++i)
{
    temp_ready = ptable.pLists.ready[i];
    while(temp_ready){
80105c13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c17:	75 bd                	jne    80105bd6 <kill+0x12a>
    //temp_ready= ptable.pLists.ready;
    temp_embryo = ptable.pLists.embryo;
    temp_running = ptable.pLists.running;
    temp_zombie = ptable.pLists.zombie;
    
for(int i =0; i<MAX+1;++i)
80105c19:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80105c1d:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
80105c21:	7e 9f                	jle    80105bc2 <kill+0x116>
            return -1;
        }
        temp_ready = temp_ready->next;
    }
}
    while(temp_embryo){
80105c23:	eb 3d                	jmp    80105c62 <kill+0x1b6>
        if(temp_embryo->pid == pid){
80105c25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c28:	8b 50 10             	mov    0x10(%eax),%edx
80105c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c2e:	39 c2                	cmp    %eax,%edx
80105c30:	75 24                	jne    80105c56 <kill+0x1aa>
            temp_embryo->killed =1;
80105c32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c35:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
             release(&ptable.lock);
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	68 a0 49 11 80       	push   $0x801149a0
80105c44:	e8 07 0d 00 00       	call   80106950 <release>
80105c49:	83 c4 10             	add    $0x10,%esp
            return -1;
80105c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c51:	e9 ab 00 00 00       	jmp    80105d01 <kill+0x255>
        }
        temp_embryo = temp_embryo->next;
80105c56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c59:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
            return -1;
        }
        temp_ready = temp_ready->next;
    }
}
    while(temp_embryo){
80105c62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c66:	75 bd                	jne    80105c25 <kill+0x179>
             release(&ptable.lock);
            return -1;
        }
        temp_embryo = temp_embryo->next;
    }
    while(temp_running){
80105c68:	eb 3a                	jmp    80105ca4 <kill+0x1f8>
        if(temp_running->pid == pid){
80105c6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c6d:	8b 50 10             	mov    0x10(%eax),%edx
80105c70:	8b 45 08             	mov    0x8(%ebp),%eax
80105c73:	39 c2                	cmp    %eax,%edx
80105c75:	75 21                	jne    80105c98 <kill+0x1ec>
            temp_running->killed = 1;
80105c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c7a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
            release(&ptable.lock);
80105c81:	83 ec 0c             	sub    $0xc,%esp
80105c84:	68 a0 49 11 80       	push   $0x801149a0
80105c89:	e8 c2 0c 00 00       	call   80106950 <release>
80105c8e:	83 c4 10             	add    $0x10,%esp
            return -1;
80105c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c96:	eb 69                	jmp    80105d01 <kill+0x255>
        }
        temp_running = temp_running->next;
80105c98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c9b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ca1:	89 45 e8             	mov    %eax,-0x18(%ebp)
             release(&ptable.lock);
            return -1;
        }
        temp_embryo = temp_embryo->next;
    }
    while(temp_running){
80105ca4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80105ca8:	75 c0                	jne    80105c6a <kill+0x1be>
            release(&ptable.lock);
            return -1;
        }
        temp_running = temp_running->next;
    }
    while(temp_zombie){
80105caa:	eb 3a                	jmp    80105ce6 <kill+0x23a>
        if(temp_zombie->pid == pid){
80105cac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105caf:	8b 50 10             	mov    0x10(%eax),%edx
80105cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb5:	39 c2                	cmp    %eax,%edx
80105cb7:	75 21                	jne    80105cda <kill+0x22e>
            temp_zombie->killed = 1;
80105cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cbc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
            release(&ptable.lock);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	68 a0 49 11 80       	push   $0x801149a0
80105ccb:	e8 80 0c 00 00       	call   80106950 <release>
80105cd0:	83 c4 10             	add    $0x10,%esp
            return -1;
80105cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd8:	eb 27                	jmp    80105d01 <kill+0x255>
        }
        temp_zombie = temp_zombie->next;
80105cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cdd:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ce3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            release(&ptable.lock);
            return -1;
        }
        temp_running = temp_running->next;
    }
    while(temp_zombie){
80105ce6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105cea:	75 c0                	jne    80105cac <kill+0x200>
            release(&ptable.lock);
            return -1;
        }
        temp_zombie = temp_zombie->next;
    }
    release(&ptable.lock);
80105cec:	83 ec 0c             	sub    $0xc,%esp
80105cef:	68 a0 49 11 80       	push   $0x801149a0
80105cf4:	e8 57 0c 00 00       	call   80106950 <release>
80105cf9:	83 c4 10             	add    $0x10,%esp
    return -1;
80105cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d01:	c9                   	leave  
80105d02:	c3                   	ret    

80105d03 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105d03:	55                   	push   %ebp
80105d04:	89 e5                	mov    %esp,%ebp
80105d06:	56                   	push   %esi
80105d07:	53                   	push   %ebx
80105d08:	83 ec 50             	sub    $0x50,%esp
  uint result;
  uint reminder;
  #endif

    #ifdef CS333_P3P4
        cprintf("PID\tName\tUID\tGID\tPPID\tPrio\tElapsed\tCPU\tState\tSIZE\tPCs\n");
80105d0b:	83 ec 0c             	sub    $0xc,%esp
80105d0e:	68 1c a5 10 80       	push   $0x8010a51c
80105d13:	e8 ae a6 ff ff       	call   801003c6 <cprintf>
80105d18:	83 c4 10             	add    $0x10,%esp
    #elif CS333_P2
        cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSIZE\tPCs\n");
    #elif CS333_P1
        cprintf("PID\tState\tName\tElapsed\tPCs\n");
    #endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105d1b:	c7 45 f0 d4 49 11 80 	movl   $0x801149d4,-0x10(%ebp)
80105d22:	e9 e9 01 00 00       	jmp    80105f10 <procdump+0x20d>
    if(p->state == UNUSED)
80105d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2a:	8b 40 0c             	mov    0xc(%eax),%eax
80105d2d:	85 c0                	test   %eax,%eax
80105d2f:	0f 84 d3 01 00 00    	je     80105f08 <procdump+0x205>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d38:	8b 40 0c             	mov    0xc(%eax),%eax
80105d3b:	83 f8 05             	cmp    $0x5,%eax
80105d3e:	77 23                	ja     80105d63 <procdump+0x60>
80105d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d43:	8b 40 0c             	mov    0xc(%eax),%eax
80105d46:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	74 12                	je     80105d63 <procdump+0x60>
      state = states[p->state];
80105d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d54:	8b 40 0c             	mov    0xc(%eax),%eax
80105d57:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d61:	eb 07                	jmp    80105d6a <procdump+0x67>
    else
      state = "???";
80105d63:	c7 45 ec 53 a5 10 80 	movl   $0x8010a553,-0x14(%ebp)
    #ifdef CS333_P2
        result = (ticks - p->start_ticks)/1000;
80105d6a:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d73:	8b 40 7c             	mov    0x7c(%eax),%eax
80105d76:	29 c2                	sub    %eax,%edx
80105d78:	89 d0                	mov    %edx,%eax
80105d7a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105d7f:	f7 e2                	mul    %edx
80105d81:	89 d0                	mov    %edx,%eax
80105d83:	c1 e8 06             	shr    $0x6,%eax
80105d86:	89 45 e8             	mov    %eax,-0x18(%ebp)
        reminder = (ticks - p->start_ticks)%1000;
80105d89:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d92:	8b 40 7c             	mov    0x7c(%eax),%eax
80105d95:	89 d1                	mov    %edx,%ecx
80105d97:	29 c1                	sub    %eax,%ecx
80105d99:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105d9e:	89 c8                	mov    %ecx,%eax
80105da0:	f7 e2                	mul    %edx
80105da2:	89 d0                	mov    %edx,%eax
80105da4:	c1 e8 06             	shr    $0x6,%eax
80105da7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dad:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105db3:	29 c1                	sub    %eax,%ecx
80105db5:	89 c8                	mov    %ecx,%eax
80105db7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("%d\t%s%d\t%d\t%d\t", p->pid,p->name,p->uid,p->gid,p->parent->pid);    
80105dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbd:	8b 40 14             	mov    0x14(%eax),%eax
80105dc0:	8b 58 10             	mov    0x10(%eax),%ebx
80105dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc6:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80105dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcf:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80105dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd8:	8d 70 6c             	lea    0x6c(%eax),%esi
80105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dde:	8b 40 10             	mov    0x10(%eax),%eax
80105de1:	83 ec 08             	sub    $0x8,%esp
80105de4:	53                   	push   %ebx
80105de5:	51                   	push   %ecx
80105de6:	52                   	push   %edx
80105de7:	56                   	push   %esi
80105de8:	50                   	push   %eax
80105de9:	68 57 a5 10 80       	push   $0x8010a557
80105dee:	e8 d3 a5 ff ff       	call   801003c6 <cprintf>
80105df3:	83 c4 20             	add    $0x20,%esp
#ifdef CS333_P3P4
        cprintf("%d\t",p->priority);
80105df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df9:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105dff:	83 ec 08             	sub    $0x8,%esp
80105e02:	50                   	push   %eax
80105e03:	68 66 a5 10 80       	push   $0x8010a566
80105e08:	e8 b9 a5 ff ff       	call   801003c6 <cprintf>
80105e0d:	83 c4 10             	add    $0x10,%esp
#endif
        cprintf("%d.%d\t",result,reminder);
80105e10:	83 ec 04             	sub    $0x4,%esp
80105e13:	ff 75 e4             	pushl  -0x1c(%ebp)
80105e16:	ff 75 e8             	pushl  -0x18(%ebp)
80105e19:	68 6a a5 10 80       	push   $0x8010a56a
80105e1e:	e8 a3 a5 ff ff       	call   801003c6 <cprintf>
80105e23:	83 c4 10             	add    $0x10,%esp
        cprintf("%d\t%s\t%s\t%d.%d\t", p->pid,state, p->name,result,reminder);
    #else 
        cprintf("%d\t%s\t%s", p->pid,state, p->name);
    #endif
#ifdef CS333_P2
        result_cpu= p->total_ticks_cpu/1000;
80105e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e29:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105e2f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105e34:	f7 e2                	mul    %edx
80105e36:	89 d0                	mov    %edx,%eax
80105e38:	c1 e8 06             	shr    $0x6,%eax
80105e3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        reminder_cpu = p->total_ticks_cpu%1000;
80105e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e41:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80105e47:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105e4c:	89 c8                	mov    %ecx,%eax
80105e4e:	f7 e2                	mul    %edx
80105e50:	89 d0                	mov    %edx,%eax
80105e52:	c1 e8 06             	shr    $0x6,%eax
80105e55:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e5b:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105e61:	29 c1                	sub    %eax,%ecx
80105e63:	89 c8                	mov    %ecx,%eax
80105e65:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("%d.%d\t",result_cpu,reminder_cpu);
80105e68:	83 ec 04             	sub    $0x4,%esp
80105e6b:	ff 75 dc             	pushl  -0x24(%ebp)
80105e6e:	ff 75 e0             	pushl  -0x20(%ebp)
80105e71:	68 6a a5 10 80       	push   $0x8010a56a
80105e76:	e8 4b a5 ff ff       	call   801003c6 <cprintf>
80105e7b:	83 c4 10             	add    $0x10,%esp
        cprintf("%s\t%d", state, p->sz);
80105e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e81:	8b 00                	mov    (%eax),%eax
80105e83:	83 ec 04             	sub    $0x4,%esp
80105e86:	50                   	push   %eax
80105e87:	ff 75 ec             	pushl  -0x14(%ebp)
80105e8a:	68 71 a5 10 80       	push   $0x8010a571
80105e8f:	e8 32 a5 ff ff       	call   801003c6 <cprintf>
80105e94:	83 c4 10             	add    $0x10,%esp
#endif
        
    if(p->state == SLEEPING){
80105e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9a:	8b 40 0c             	mov    0xc(%eax),%eax
80105e9d:	83 f8 02             	cmp    $0x2,%eax
80105ea0:	75 54                	jne    80105ef6 <procdump+0x1f3>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea5:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ea8:	8b 40 0c             	mov    0xc(%eax),%eax
80105eab:	83 c0 08             	add    $0x8,%eax
80105eae:	89 c2                	mov    %eax,%edx
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 b4             	lea    -0x4c(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	52                   	push   %edx
80105eb8:	e8 e5 0a 00 00       	call   801069a2 <getcallerpcs>
80105ebd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ec7:	eb 1c                	jmp    80105ee5 <procdump+0x1e2>
        cprintf(" %p", pc[i]);
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
80105ed0:	83 ec 08             	sub    $0x8,%esp
80105ed3:	50                   	push   %eax
80105ed4:	68 77 a5 10 80       	push   $0x8010a577
80105ed9:	e8 e8 a4 ff ff       	call   801003c6 <cprintf>
80105ede:	83 c4 10             	add    $0x10,%esp
        cprintf("%s\t%d", state, p->sz);
#endif
        
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105ee1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ee5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105ee9:	7f 0b                	jg     80105ef6 <procdump+0x1f3>
80105eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eee:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
80105ef2:	85 c0                	test   %eax,%eax
80105ef4:	75 d3                	jne    80105ec9 <procdump+0x1c6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105ef6:	83 ec 0c             	sub    $0xc,%esp
80105ef9:	68 7b a5 10 80       	push   $0x8010a57b
80105efe:	e8 c3 a4 ff ff       	call   801003c6 <cprintf>
80105f03:	83 c4 10             	add    $0x10,%esp
80105f06:	eb 01                	jmp    80105f09 <procdump+0x206>
    #elif CS333_P1
        cprintf("PID\tState\tName\tElapsed\tPCs\n");
    #endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105f08:	90                   	nop
    #elif CS333_P2
        cprintf("PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSIZE\tPCs\n");
    #elif CS333_P1
        cprintf("PID\tState\tName\tElapsed\tPCs\n");
    #endif
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105f09:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105f10:	81 7d f0 d4 70 11 80 	cmpl   $0x801170d4,-0x10(%ebp)
80105f17:	0f 82 0a fe ff ff    	jb     80105d27 <procdump+0x24>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105f1d:	90                   	nop
80105f1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105f21:	5b                   	pop    %ebx
80105f22:	5e                   	pop    %esi
80105f23:	5d                   	pop    %ebp
80105f24:	c3                   	ret    

80105f25 <getprocs>:

#ifdef CS333_P2
int
getprocs(uint max, struct uproc* table) {
80105f25:	55                   	push   %ebp
80105f26:	89 e5                	mov    %esp,%ebp
80105f28:	83 ec 18             	sub    $0x18,%esp
    int count =0;
80105f2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    acquire(&ptable.lock);
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	68 a0 49 11 80       	push   $0x801149a0
80105f3a:	e8 aa 09 00 00       	call   801068e9 <acquire>
80105f3f:	83 c4 10             	add    $0x10,%esp
    
    for(int i =0; i < NPROC && count  < max; ++i){
80105f42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105f49:	e9 3b 02 00 00       	jmp    80106189 <getprocs+0x264>
        if(ptable.proc[i].state == RUNNABLE || ptable.proc[i].state == RUNNING || ptable.proc[i].state == SLEEPING){
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105f57:	05 e0 49 11 80       	add    $0x801149e0,%eax
80105f5c:	8b 00                	mov    (%eax),%eax
80105f5e:	83 f8 03             	cmp    $0x3,%eax
80105f61:	74 2e                	je     80105f91 <getprocs+0x6c>
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105f6c:	05 e0 49 11 80       	add    $0x801149e0,%eax
80105f71:	8b 00                	mov    (%eax),%eax
80105f73:	83 f8 04             	cmp    $0x4,%eax
80105f76:	74 19                	je     80105f91 <getprocs+0x6c>
80105f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7b:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105f81:	05 e0 49 11 80       	add    $0x801149e0,%eax
80105f86:	8b 00                	mov    (%eax),%eax
80105f88:	83 f8 02             	cmp    $0x2,%eax
80105f8b:	0f 85 f4 01 00 00    	jne    80106185 <getprocs+0x260>
            table[count].pid = ptable.proc[i].pid;
80105f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f94:	89 d0                	mov    %edx,%eax
80105f96:	01 c0                	add    %eax,%eax
80105f98:	01 d0                	add    %edx,%eax
80105f9a:	c1 e0 05             	shl    $0x5,%eax
80105f9d:	89 c2                	mov    %eax,%edx
80105f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fa2:	01 c2                	add    %eax,%edx
80105fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa7:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105fad:	05 e4 49 11 80       	add    $0x801149e4,%eax
80105fb2:	8b 00                	mov    (%eax),%eax
80105fb4:	89 02                	mov    %eax,(%edx)
            table[count].uid = ptable.proc[i].uid;
80105fb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fb9:	89 d0                	mov    %edx,%eax
80105fbb:	01 c0                	add    %eax,%eax
80105fbd:	01 d0                	add    %edx,%eax
80105fbf:	c1 e0 05             	shl    $0x5,%eax
80105fc2:	89 c2                	mov    %eax,%edx
80105fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fc7:	01 c2                	add    %eax,%edx
80105fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcc:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105fd2:	05 58 4a 11 80       	add    $0x80114a58,%eax
80105fd7:	8b 00                	mov    (%eax),%eax
80105fd9:	89 42 04             	mov    %eax,0x4(%edx)
            table[count].gid = ptable.proc[i].gid;
80105fdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fdf:	89 d0                	mov    %edx,%eax
80105fe1:	01 c0                	add    %eax,%eax
80105fe3:	01 d0                	add    %edx,%eax
80105fe5:	c1 e0 05             	shl    $0x5,%eax
80105fe8:	89 c2                	mov    %eax,%edx
80105fea:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fed:	01 c2                	add    %eax,%edx
80105fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff2:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80105ff8:	05 54 4a 11 80       	add    $0x80114a54,%eax
80105ffd:	8b 00                	mov    (%eax),%eax
80105fff:	89 42 08             	mov    %eax,0x8(%edx)
            if(ptable.proc[i].parent == 0)
80106002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106005:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
8010600b:	05 e8 49 11 80       	add    $0x801149e8,%eax
80106010:	8b 00                	mov    (%eax),%eax
80106012:	85 c0                	test   %eax,%eax
80106014:	75 28                	jne    8010603e <getprocs+0x119>
                table[count].ppid = ptable.proc[i].pid;
80106016:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106019:	89 d0                	mov    %edx,%eax
8010601b:	01 c0                	add    %eax,%eax
8010601d:	01 d0                	add    %edx,%eax
8010601f:	c1 e0 05             	shl    $0x5,%eax
80106022:	89 c2                	mov    %eax,%edx
80106024:	8b 45 0c             	mov    0xc(%ebp),%eax
80106027:	01 c2                	add    %eax,%edx
80106029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602c:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80106032:	05 e4 49 11 80       	add    $0x801149e4,%eax
80106037:	8b 00                	mov    (%eax),%eax
80106039:	89 42 0c             	mov    %eax,0xc(%edx)
8010603c:	eb 29                	jmp    80106067 <getprocs+0x142>
            else // get the parent to ppid 
                table[count].ppid = ptable.proc[i].parent->pid;
8010603e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106041:	89 d0                	mov    %edx,%eax
80106043:	01 c0                	add    %eax,%eax
80106045:	01 d0                	add    %edx,%eax
80106047:	c1 e0 05             	shl    $0x5,%eax
8010604a:	89 c2                	mov    %eax,%edx
8010604c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010604f:	01 c2                	add    %eax,%edx
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
8010605a:	05 e8 49 11 80       	add    $0x801149e8,%eax
8010605f:	8b 00                	mov    (%eax),%eax
80106061:	8b 40 10             	mov    0x10(%eax),%eax
80106064:	89 42 0c             	mov    %eax,0xc(%edx)

            table[count].elapsed_ticks = ticks - ptable.proc[i].start_ticks;
80106067:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010606a:	89 d0                	mov    %edx,%eax
8010606c:	01 c0                	add    %eax,%eax
8010606e:	01 d0                	add    %edx,%eax
80106070:	c1 e0 05             	shl    $0x5,%eax
80106073:	89 c2                	mov    %eax,%edx
80106075:	8b 45 0c             	mov    0xc(%ebp),%eax
80106078:	01 d0                	add    %edx,%eax
8010607a:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
80106080:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106083:	69 d2 9c 00 00 00    	imul   $0x9c,%edx,%edx
80106089:	81 c2 50 4a 11 80    	add    $0x80114a50,%edx
8010608f:	8b 12                	mov    (%edx),%edx
80106091:	29 d1                	sub    %edx,%ecx
80106093:	89 ca                	mov    %ecx,%edx
80106095:	89 50 10             	mov    %edx,0x10(%eax)
            table[count].CPU_total_ticks = ptable.proc[i].total_ticks_cpu;
80106098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010609b:	89 d0                	mov    %edx,%eax
8010609d:	01 c0                	add    %eax,%eax
8010609f:	01 d0                	add    %edx,%eax
801060a1:	c1 e0 05             	shl    $0x5,%eax
801060a4:	89 c2                	mov    %eax,%edx
801060a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801060a9:	01 c2                	add    %eax,%edx
801060ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ae:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
801060b4:	05 5c 4a 11 80       	add    $0x80114a5c,%eax
801060b9:	8b 00                	mov    (%eax),%eax
801060bb:	89 42 14             	mov    %eax,0x14(%edx)
            safestrcpy(table[count].state,states[ptable.proc[i].state],sizeof(table[count].state));
801060be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c1:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
801060c7:	05 e0 49 11 80       	add    $0x801149e0,%eax
801060cc:	8b 00                	mov    (%eax),%eax
801060ce:	8b 0c 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%ecx
801060d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060d8:	89 d0                	mov    %edx,%eax
801060da:	01 c0                	add    %eax,%eax
801060dc:	01 d0                	add    %edx,%eax
801060de:	c1 e0 05             	shl    $0x5,%eax
801060e1:	89 c2                	mov    %eax,%edx
801060e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060e6:	01 d0                	add    %edx,%eax
801060e8:	83 c0 18             	add    $0x18,%eax
801060eb:	83 ec 04             	sub    $0x4,%esp
801060ee:	6a 20                	push   $0x20
801060f0:	51                   	push   %ecx
801060f1:	50                   	push   %eax
801060f2:	e8 58 0c 00 00       	call   80106d4f <safestrcpy>
801060f7:	83 c4 10             	add    $0x10,%esp
            table[count].size = ptable.proc[i].sz;
801060fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060fd:	89 d0                	mov    %edx,%eax
801060ff:	01 c0                	add    %eax,%eax
80106101:	01 d0                	add    %edx,%eax
80106103:	c1 e0 05             	shl    $0x5,%eax
80106106:	89 c2                	mov    %eax,%edx
80106108:	8b 45 0c             	mov    0xc(%ebp),%eax
8010610b:	01 c2                	add    %eax,%edx
8010610d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106110:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80106116:	05 d4 49 11 80       	add    $0x801149d4,%eax
8010611b:	8b 00                	mov    (%eax),%eax
8010611d:	89 42 38             	mov    %eax,0x38(%edx)
            safestrcpy(table[count].name,ptable.proc[i].name, sizeof(table[count].name));
80106120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106123:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80106129:	05 90 00 00 00       	add    $0x90,%eax
8010612e:	05 a0 49 11 80       	add    $0x801149a0,%eax
80106133:	8d 48 10             	lea    0x10(%eax),%ecx
80106136:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106139:	89 d0                	mov    %edx,%eax
8010613b:	01 c0                	add    %eax,%eax
8010613d:	01 d0                	add    %edx,%eax
8010613f:	c1 e0 05             	shl    $0x5,%eax
80106142:	89 c2                	mov    %eax,%edx
80106144:	8b 45 0c             	mov    0xc(%ebp),%eax
80106147:	01 d0                	add    %edx,%eax
80106149:	83 c0 3c             	add    $0x3c,%eax
8010614c:	83 ec 04             	sub    $0x4,%esp
8010614f:	6a 20                	push   $0x20
80106151:	51                   	push   %ecx
80106152:	50                   	push   %eax
80106153:	e8 f7 0b 00 00       	call   80106d4f <safestrcpy>
80106158:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
            table[count].priority = ptable.proc[i].priority;
8010615b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010615e:	89 d0                	mov    %edx,%eax
80106160:	01 c0                	add    %eax,%eax
80106162:	01 d0                	add    %edx,%eax
80106164:	c1 e0 05             	shl    $0x5,%eax
80106167:	89 c2                	mov    %eax,%edx
80106169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010616c:	01 c2                	add    %eax,%edx
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	69 c0 9c 00 00 00    	imul   $0x9c,%eax,%eax
80106177:	05 68 4a 11 80       	add    $0x80114a68,%eax
8010617c:	8b 00                	mov    (%eax),%eax
8010617e:	89 42 5c             	mov    %eax,0x5c(%edx)
#endif
            count += 1;
80106181:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
int
getprocs(uint max, struct uproc* table) {
    int count =0;
    acquire(&ptable.lock);
    
    for(int i =0; i < NPROC && count  < max; ++i){
80106185:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106189:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010618d:	7f 0c                	jg     8010619b <getprocs+0x276>
8010618f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106192:	3b 45 08             	cmp    0x8(%ebp),%eax
80106195:	0f 82 b3 fd ff ff    	jb     80105f4e <getprocs+0x29>
#endif
            count += 1;

        }
    }
    release(&ptable.lock);
8010619b:	83 ec 0c             	sub    $0xc,%esp
8010619e:	68 a0 49 11 80       	push   $0x801149a0
801061a3:	e8 a8 07 00 00       	call   80106950 <release>
801061a8:	83 c4 10             	add    $0x10,%esp
    return count;
801061ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061ae:	c9                   	leave  
801061af:	c3                   	ret    

801061b0 <assertState>:
#endif
            
#ifdef CS333_P3P4
static void
assertState(struct proc *p,enum procstate state)
{
801061b0:	55                   	push   %ebp
801061b1:	89 e5                	mov    %esp,%ebp
801061b3:	83 ec 08             	sub    $0x8,%esp
    if(p->state != state){
801061b6:	8b 45 08             	mov    0x8(%ebp),%eax
801061b9:	8b 40 0c             	mov    0xc(%eax),%eax
801061bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801061bf:	74 36                	je     801061f7 <assertState+0x47>
        cprintf("currently at %s, need to be in %s\n",states[p->state],states[state]);
801061c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c4:	8b 14 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%edx
801061cb:	8b 45 08             	mov    0x8(%ebp),%eax
801061ce:	8b 40 0c             	mov    0xc(%eax),%eax
801061d1:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801061d8:	83 ec 04             	sub    $0x4,%esp
801061db:	52                   	push   %edx
801061dc:	50                   	push   %eax
801061dd:	68 80 a5 10 80       	push   $0x8010a580
801061e2:	e8 df a1 ff ff       	call   801003c6 <cprintf>
801061e7:	83 c4 10             	add    $0x10,%esp
        panic("There's No Match");
801061ea:	83 ec 0c             	sub    $0xc,%esp
801061ed:	68 a3 a5 10 80       	push   $0x8010a5a3
801061f2:	e8 6f a3 ff ff       	call   80100566 <panic>
    }
    else
        return;
801061f7:	90                   	nop
}
801061f8:	c9                   	leave  
801061f9:	c3                   	ret    

801061fa <addToStateListHead>:


static int
addToStateListHead(struct proc ** sList,struct proc *p,enum procstate state){
801061fa:	55                   	push   %ebp
801061fb:	89 e5                	mov    %esp,%ebp
801061fd:	83 ec 08             	sub    $0x8,%esp
    assertState(p,state);
80106200:	83 ec 08             	sub    $0x8,%esp
80106203:	ff 75 10             	pushl  0x10(%ebp)
80106206:	ff 75 0c             	pushl  0xc(%ebp)
80106209:	e8 a2 ff ff ff       	call   801061b0 <assertState>
8010620e:	83 c4 10             	add    $0x10,%esp
    p->next = *sList;
80106211:	8b 45 08             	mov    0x8(%ebp),%eax
80106214:	8b 10                	mov    (%eax),%edx
80106216:	8b 45 0c             	mov    0xc(%ebp),%eax
80106219:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *sList =p;
8010621f:	8b 45 08             	mov    0x8(%ebp),%eax
80106222:	8b 55 0c             	mov    0xc(%ebp),%edx
80106225:	89 10                	mov    %edx,(%eax)
    return 0;
80106227:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010622c:	c9                   	leave  
8010622d:	c3                   	ret    

8010622e <addToStateListEnd>:

static int
addToStateListEnd(struct proc ** sList,struct proc *p)
{
8010622e:	55                   	push   %ebp
8010622f:	89 e5                	mov    %esp,%ebp
80106231:	83 ec 18             	sub    $0x18,%esp
    struct proc * temp = *sList;
80106234:	8b 45 08             	mov    0x8(%ebp),%eax
80106237:	8b 00                	mov    (%eax),%eax
80106239:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(*sList ==0)
8010623c:	8b 45 08             	mov    0x8(%ebp),%eax
8010623f:	8b 00                	mov    (%eax),%eax
80106241:	85 c0                	test   %eax,%eax
80106243:	75 26                	jne    8010626b <addToStateListEnd+0x3d>
        return addToStateListHead(sList,p,p->state);
80106245:	8b 45 0c             	mov    0xc(%ebp),%eax
80106248:	8b 40 0c             	mov    0xc(%eax),%eax
8010624b:	83 ec 04             	sub    $0x4,%esp
8010624e:	50                   	push   %eax
8010624f:	ff 75 0c             	pushl  0xc(%ebp)
80106252:	ff 75 08             	pushl  0x8(%ebp)
80106255:	e8 a0 ff ff ff       	call   801061fa <addToStateListHead>
8010625a:	83 c4 10             	add    $0x10,%esp
8010625d:	eb 37                	jmp    80106296 <addToStateListEnd+0x68>
    while(temp->next !=0)
        temp = temp->next;
8010625f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106262:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106268:	89 45 f4             	mov    %eax,-0xc(%ebp)
addToStateListEnd(struct proc ** sList,struct proc *p)
{
    struct proc * temp = *sList;
    if(*sList ==0)
        return addToStateListHead(sList,p,p->state);
    while(temp->next !=0)
8010626b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106274:	85 c0                	test   %eax,%eax
80106276:	75 e7                	jne    8010625f <addToStateListEnd+0x31>
        temp = temp->next;
    temp->next = p;
80106278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010627e:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    p->next = 0;
80106284:	8b 45 0c             	mov    0xc(%ebp),%eax
80106287:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010628e:	00 00 00 
    return 0;
80106291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106296:	c9                   	leave  
80106297:	c3                   	ret    

80106298 <removeFromStateList>:



static int
removeFromStateList(struct proc ** sList,struct proc *p)
{
80106298:	55                   	push   %ebp
80106299:	89 e5                	mov    %esp,%ebp
8010629b:	83 ec 10             	sub    $0x10,%esp
    if(p == 0)
8010629e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062a2:	75 0a                	jne    801062ae <removeFromStateList+0x16>
        return -1;
801062a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a9:	e9 b0 00 00 00       	jmp    8010635e <removeFromStateList+0xc6>
    if(*sList == 0)
801062ae:	8b 45 08             	mov    0x8(%ebp),%eax
801062b1:	8b 00                	mov    (%eax),%eax
801062b3:	85 c0                	test   %eax,%eax
801062b5:	75 0a                	jne    801062c1 <removeFromStateList+0x29>
        return -1;
801062b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062bc:	e9 9d 00 00 00       	jmp    8010635e <removeFromStateList+0xc6>
    if(*sList){
801062c1:	8b 45 08             	mov    0x8(%ebp),%eax
801062c4:	8b 00                	mov    (%eax),%eax
801062c6:	85 c0                	test   %eax,%eax
801062c8:	74 32                	je     801062fc <removeFromStateList+0x64>
        struct proc * temp = *sList;
801062ca:	8b 45 08             	mov    0x8(%ebp),%eax
801062cd:	8b 00                	mov    (%eax),%eax
801062cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
        if(p==temp){
801062d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801062d8:	75 22                	jne    801062fc <removeFromStateList+0x64>
            *sList = temp->next;
801062da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801062dd:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801062e3:	8b 45 08             	mov    0x8(%ebp),%eax
801062e6:	89 10                	mov    %edx,(%eax)
            p->next = 0;
801062e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801062eb:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801062f2:	00 00 00 
            return 0;
801062f5:	b8 00 00 00 00       	mov    $0x0,%eax
801062fa:	eb 62                	jmp    8010635e <removeFromStateList+0xc6>
        }
    }
    struct proc * current = *sList;
801062fc:	8b 45 08             	mov    0x8(%ebp),%eax
801062ff:	8b 00                	mov    (%eax),%eax
80106301:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while(current->next){
80106304:	eb 46                	jmp    8010634c <removeFromStateList+0xb4>
        if(current->next ==p){
80106306:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106309:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010630f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80106312:	75 2c                	jne    80106340 <removeFromStateList+0xa8>
            current->next=current->next->next;
80106314:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106317:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010631d:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80106323:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106326:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
            p->next = 0;
8010632c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010632f:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106336:	00 00 00 
            return 0;
80106339:	b8 00 00 00 00       	mov    $0x0,%eax
8010633e:	eb 1e                	jmp    8010635e <removeFromStateList+0xc6>
        }
        current = current->next;
80106340:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106343:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106349:	89 45 fc             	mov    %eax,-0x4(%ebp)
            p->next = 0;
            return 0;
        }
    }
    struct proc * current = *sList;
    while(current->next){
8010634c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010634f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106355:	85 c0                	test   %eax,%eax
80106357:	75 ad                	jne    80106306 <removeFromStateList+0x6e>
            p->next = 0;
            return 0;
        }
        current = current->next;
    }
    return -1;
80106359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010635e:	c9                   	leave  
8010635f:	c3                   	ret    

80106360 <control_r>:


void
control_r(void)
{
80106360:	55                   	push   %ebp
80106361:	89 e5                	mov    %esp,%ebp
80106363:	83 ec 18             	sub    $0x18,%esp
   cprintf("Ready List Processes:\n");
80106366:	83 ec 0c             	sub    $0xc,%esp
80106369:	68 b4 a5 10 80       	push   $0x8010a5b4
8010636e:	e8 53 a0 ff ff       	call   801003c6 <cprintf>
80106373:	83 c4 10             	add    $0x10,%esp
   for(int i =0; i<MAX+1;++i)
80106376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010637d:	e9 a4 00 00 00       	jmp    80106426 <control_r+0xc6>
   {
       struct proc * temp = ptable.pLists.ready[i];
80106382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106385:	05 cc 09 00 00       	add    $0x9cc,%eax
8010638a:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80106391:	89 45 f0             	mov    %eax,-0x10(%ebp)
       cprintf("%d: " ,i);
80106394:	83 ec 08             	sub    $0x8,%esp
80106397:	ff 75 f4             	pushl  -0xc(%ebp)
8010639a:	68 cb a5 10 80       	push   $0x8010a5cb
8010639f:	e8 22 a0 ff ff       	call   801003c6 <cprintf>
801063a4:	83 c4 10             	add    $0x10,%esp
       if (temp == 0)
801063a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ab:	75 6f                	jne    8010641c <control_r+0xbc>
       {
          cprintf("Nothing Here!!!\n");
801063ad:	83 ec 0c             	sub    $0xc,%esp
801063b0:	68 d0 a5 10 80       	push   $0x8010a5d0
801063b5:	e8 0c a0 ff ff       	call   801003c6 <cprintf>
801063ba:	83 c4 10             	add    $0x10,%esp
       }
       while (temp != 0)
801063bd:	eb 5d                	jmp    8010641c <control_r+0xbc>
       {
          if(temp -> next == 0) 
801063bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801063c8:	85 c0                	test   %eax,%eax
801063ca:	75 23                	jne    801063ef <control_r+0x8f>
             cprintf("(%d, %d)\n", temp -> pid,temp->budget);
801063cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cf:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801063d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d8:	8b 40 10             	mov    0x10(%eax),%eax
801063db:	83 ec 04             	sub    $0x4,%esp
801063de:	52                   	push   %edx
801063df:	50                   	push   %eax
801063e0:	68 e1 a5 10 80       	push   $0x8010a5e1
801063e5:	e8 dc 9f ff ff       	call   801003c6 <cprintf>
801063ea:	83 c4 10             	add    $0x10,%esp
801063ed:	eb 21                	jmp    80106410 <control_r+0xb0>
          else{
             cprintf("(%d, %d)->", temp -> pid,temp->budget);
801063ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f2:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
801063f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fb:	8b 40 10             	mov    0x10(%eax),%eax
801063fe:	83 ec 04             	sub    $0x4,%esp
80106401:	52                   	push   %edx
80106402:	50                   	push   %eax
80106403:	68 eb a5 10 80       	push   $0x8010a5eb
80106408:	e8 b9 9f ff ff       	call   801003c6 <cprintf>
8010640d:	83 c4 10             	add    $0x10,%esp
          }
          temp = temp->next;
80106410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106413:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106419:	89 45 f0             	mov    %eax,-0x10(%ebp)
       cprintf("%d: " ,i);
       if (temp == 0)
       {
          cprintf("Nothing Here!!!\n");
       }
       while (temp != 0)
8010641c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106420:	75 9d                	jne    801063bf <control_r+0x5f>

void
control_r(void)
{
   cprintf("Ready List Processes:\n");
   for(int i =0; i<MAX+1;++i)
80106422:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106426:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
8010642a:	0f 8e 52 ff ff ff    	jle    80106382 <control_r+0x22>
             cprintf("(%d, %d)->", temp -> pid,temp->budget);
          }
          temp = temp->next;
       }
   }
   return;
80106430:	90                   	nop
}
80106431:	c9                   	leave  
80106432:	c3                   	ret    

80106433 <control_f>:

void
control_f(void) 
{
80106433:	55                   	push   %ebp
80106434:	89 e5                	mov    %esp,%ebp
80106436:	83 ec 18             	sub    $0x18,%esp
   struct proc * temp = ptable.pLists.free;
80106439:	a1 00 71 11 80       	mov    0x80117100,%eax
8010643e:	89 45 f4             	mov    %eax,-0xc(%ebp)
   int count = 1; 
80106441:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
   cprintf("Free List Size: ");
80106448:	83 ec 0c             	sub    $0xc,%esp
8010644b:	68 f6 a5 10 80       	push   $0x8010a5f6
80106450:	e8 71 9f ff ff       	call   801003c6 <cprintf>
80106455:	83 c4 10             	add    $0x10,%esp
   if (temp == 0) 
80106458:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010645c:	75 22                	jne    80106480 <control_f+0x4d>
   {
      cprintf(" 0 processes\n");
8010645e:	83 ec 0c             	sub    $0xc,%esp
80106461:	68 07 a6 10 80       	push   $0x8010a607
80106466:	e8 5b 9f ff ff       	call   801003c6 <cprintf>
8010646b:	83 c4 10             	add    $0x10,%esp
      return;
8010646e:	eb 31                	jmp    801064a1 <control_f+0x6e>
   }
   while (temp -> next != 0)
   {
      count += 1;
80106470:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      temp = temp->next;
80106474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106477:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010647d:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if (temp == 0) 
   {
      cprintf(" 0 processes\n");
      return;
   }
   while (temp -> next != 0)
80106480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106483:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106489:	85 c0                	test   %eax,%eax
8010648b:	75 e3                	jne    80106470 <control_f+0x3d>
   {
      count += 1;
      temp = temp->next;
   }
   cprintf(" %d processes\n", count);
8010648d:	83 ec 08             	sub    $0x8,%esp
80106490:	ff 75 f0             	pushl  -0x10(%ebp)
80106493:	68 15 a6 10 80       	push   $0x8010a615
80106498:	e8 29 9f ff ff       	call   801003c6 <cprintf>
8010649d:	83 c4 10             	add    $0x10,%esp
   return;
801064a0:	90                   	nop
}
801064a1:	c9                   	leave  
801064a2:	c3                   	ret    

801064a3 <control_s>:

void
control_s(void) 
{
801064a3:	55                   	push   %ebp
801064a4:	89 e5                	mov    %esp,%ebp
801064a6:	83 ec 18             	sub    $0x18,%esp
   struct proc * temp = ptable.pLists.sleep;
801064a9:	a1 04 71 11 80       	mov    0x80117104,%eax
801064ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
   cprintf("Sleep List Processes:\n");
801064b1:	83 ec 0c             	sub    $0xc,%esp
801064b4:	68 24 a6 10 80       	push   $0x8010a624
801064b9:	e8 08 9f ff ff       	call   801003c6 <cprintf>
801064be:	83 c4 10             	add    $0x10,%esp
   if (temp == 0)
801064c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c5:	75 5b                	jne    80106522 <control_s+0x7f>
   {
      cprintf("Nothing Here!!!\n");
801064c7:	83 ec 0c             	sub    $0xc,%esp
801064ca:	68 d0 a5 10 80       	push   $0x8010a5d0
801064cf:	e8 f2 9e ff ff       	call   801003c6 <cprintf>
801064d4:	83 c4 10             	add    $0x10,%esp
      return;
801064d7:	eb 50                	jmp    80106529 <control_s+0x86>
   }
   while (temp != 0)
   {
      if(temp -> next == 0)
801064d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064dc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801064e2:	85 c0                	test   %eax,%eax
801064e4:	75 19                	jne    801064ff <control_s+0x5c>
         cprintf("%d\n", temp -> pid);
801064e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e9:	8b 40 10             	mov    0x10(%eax),%eax
801064ec:	83 ec 08             	sub    $0x8,%esp
801064ef:	50                   	push   %eax
801064f0:	68 3b a6 10 80       	push   $0x8010a63b
801064f5:	e8 cc 9e ff ff       	call   801003c6 <cprintf>
801064fa:	83 c4 10             	add    $0x10,%esp
801064fd:	eb 17                	jmp    80106516 <control_s+0x73>
      else
         cprintf("%d -> ", temp -> pid);
801064ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106502:	8b 40 10             	mov    0x10(%eax),%eax
80106505:	83 ec 08             	sub    $0x8,%esp
80106508:	50                   	push   %eax
80106509:	68 3f a6 10 80       	push   $0x8010a63f
8010650e:	e8 b3 9e ff ff       	call   801003c6 <cprintf>
80106513:	83 c4 10             	add    $0x10,%esp
      temp = temp->next;
80106516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106519:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010651f:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if (temp == 0)
   {
      cprintf("Nothing Here!!!\n");
      return;
   }
   while (temp != 0)
80106522:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106526:	75 b1                	jne    801064d9 <control_s+0x36>
         cprintf("%d\n", temp -> pid);
      else
         cprintf("%d -> ", temp -> pid);
      temp = temp->next;
   }
   return;
80106528:	90                   	nop
}
80106529:	c9                   	leave  
8010652a:	c3                   	ret    

8010652b <control_z>:


void
control_z(void) 
{
8010652b:	55                   	push   %ebp
8010652c:	89 e5                	mov    %esp,%ebp
8010652e:	83 ec 18             	sub    $0x18,%esp
   struct proc * temp = ptable.pLists.zombie;
80106531:	a1 08 71 11 80       	mov    0x80117108,%eax
80106536:	89 45 f4             	mov    %eax,-0xc(%ebp)
   cprintf("Zombie List Processes:\n");
80106539:	83 ec 0c             	sub    $0xc,%esp
8010653c:	68 46 a6 10 80       	push   $0x8010a646
80106541:	e8 80 9e ff ff       	call   801003c6 <cprintf>
80106546:	83 c4 10             	add    $0x10,%esp
   if (temp == 0){
80106549:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010654d:	75 6f                	jne    801065be <control_z+0x93>
      cprintf("Nothing Here!!!\n");
8010654f:	83 ec 0c             	sub    $0xc,%esp
80106552:	68 d0 a5 10 80       	push   $0x8010a5d0
80106557:	e8 6a 9e ff ff       	call   801003c6 <cprintf>
8010655c:	83 c4 10             	add    $0x10,%esp
      return;
8010655f:	eb 64                	jmp    801065c5 <control_z+0x9a>
   }
   while (temp != 0){
      if(temp -> next == 0)
80106561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106564:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010656a:	85 c0                	test   %eax,%eax
8010656c:	75 23                	jne    80106591 <control_z+0x66>
         cprintf("(%d, %d)\n", temp -> pid, temp -> parent -> pid); 
8010656e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106571:	8b 40 14             	mov    0x14(%eax),%eax
80106574:	8b 50 10             	mov    0x10(%eax),%edx
80106577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657a:	8b 40 10             	mov    0x10(%eax),%eax
8010657d:	83 ec 04             	sub    $0x4,%esp
80106580:	52                   	push   %edx
80106581:	50                   	push   %eax
80106582:	68 e1 a5 10 80       	push   $0x8010a5e1
80106587:	e8 3a 9e ff ff       	call   801003c6 <cprintf>
8010658c:	83 c4 10             	add    $0x10,%esp
8010658f:	eb 21                	jmp    801065b2 <control_z+0x87>
      else
         cprintf("(%d, %d)->", temp -> pid, temp -> parent -> pid);
80106591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106594:	8b 40 14             	mov    0x14(%eax),%eax
80106597:	8b 50 10             	mov    0x10(%eax),%edx
8010659a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659d:	8b 40 10             	mov    0x10(%eax),%eax
801065a0:	83 ec 04             	sub    $0x4,%esp
801065a3:	52                   	push   %edx
801065a4:	50                   	push   %eax
801065a5:	68 eb a5 10 80       	push   $0x8010a5eb
801065aa:	e8 17 9e ff ff       	call   801003c6 <cprintf>
801065af:	83 c4 10             	add    $0x10,%esp
      temp = temp->next;
801065b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
   cprintf("Zombie List Processes:\n");
   if (temp == 0){
      cprintf("Nothing Here!!!\n");
      return;
   }
   while (temp != 0){
801065be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c2:	75 9d                	jne    80106561 <control_z+0x36>
         cprintf("(%d, %d)\n", temp -> pid, temp -> parent -> pid); 
      else
         cprintf("(%d, %d)->", temp -> pid, temp -> parent -> pid);
      temp = temp->next;
   }
   return;
801065c4:	90                   	nop
}
801065c5:	c9                   	leave  
801065c6:	c3                   	ret    

801065c7 <travarse>:

#ifdef CS333_P3P4

int
travarse(struct proc * temp,int pid,int priority)
{
801065c7:	55                   	push   %ebp
801065c8:	89 e5                	mov    %esp,%ebp
801065ca:	83 ec 08             	sub    $0x8,%esp
 while(temp!=0)
801065cd:	eb 49                	jmp    80106618 <travarse+0x51>
    {
        if(temp->pid == pid)
801065cf:	8b 45 08             	mov    0x8(%ebp),%eax
801065d2:	8b 50 10             	mov    0x10(%eax),%edx
801065d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801065d8:	39 c2                	cmp    %eax,%edx
801065da:	75 30                	jne    8010660c <travarse+0x45>
        {
            temp->budget = BUDGET;
801065dc:	8b 45 08             	mov    0x8(%ebp),%eax
801065df:	c7 80 98 00 00 00 d0 	movl   $0x7d0,0x98(%eax)
801065e6:	07 00 00 
            temp->priority = priority;
801065e9:	8b 45 08             	mov    0x8(%ebp),%eax
801065ec:	8b 55 10             	mov    0x10(%ebp),%edx
801065ef:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
            release(&ptable.lock);
801065f5:	83 ec 0c             	sub    $0xc,%esp
801065f8:	68 a0 49 11 80       	push   $0x801149a0
801065fd:	e8 4e 03 00 00       	call   80106950 <release>
80106602:	83 c4 10             	add    $0x10,%esp
            return 0;
80106605:	b8 00 00 00 00       	mov    $0x0,%eax
8010660a:	eb 17                	jmp    80106623 <travarse+0x5c>
        }
        temp = temp->next;
8010660c:	8b 45 08             	mov    0x8(%ebp),%eax
8010660f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106615:	89 45 08             	mov    %eax,0x8(%ebp)
#ifdef CS333_P3P4

int
travarse(struct proc * temp,int pid,int priority)
{
 while(temp!=0)
80106618:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010661c:	75 b1                	jne    801065cf <travarse+0x8>
            release(&ptable.lock);
            return 0;
        }
        temp = temp->next;
    }
   return 1; 
8010661e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106623:	c9                   	leave  
80106624:	c3                   	ret    

80106625 <setpriority>:
int
setpriority(int pid, int priority)
{
80106625:	55                   	push   %ebp
80106626:	89 e5                	mov    %esp,%ebp
80106628:	83 ec 18             	sub    $0x18,%esp
    struct proc * temp;
    if(pid > NPROC || pid < 0)
8010662b:	83 7d 08 40          	cmpl   $0x40,0x8(%ebp)
8010662f:	7f 06                	jg     80106637 <setpriority+0x12>
80106631:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106635:	79 0a                	jns    80106641 <setpriority+0x1c>
        return -1;
80106637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663c:	e9 5a 01 00 00       	jmp    8010679b <setpriority+0x176>
    if(priority < 0 || priority > MAX)
80106641:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106645:	78 06                	js     8010664d <setpriority+0x28>
80106647:	83 7d 0c 0a          	cmpl   $0xa,0xc(%ebp)
8010664b:	7e 0a                	jle    80106657 <setpriority+0x32>
        return -1;
8010664d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106652:	e9 44 01 00 00       	jmp    8010679b <setpriority+0x176>
    acquire(&ptable.lock);
80106657:	83 ec 0c             	sub    $0xc,%esp
8010665a:	68 a0 49 11 80       	push   $0x801149a0
8010665f:	e8 85 02 00 00       	call   801068e9 <acquire>
80106664:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < MAX+1; ++i)
80106667:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010666e:	e9 bb 00 00 00       	jmp    8010672e <setpriority+0x109>
    {
        temp = ptable.pLists.ready[i];
80106673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106676:	05 cc 09 00 00       	add    $0x9cc,%eax
8010667b:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80106682:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while(temp !=0)
80106685:	e9 96 00 00 00       	jmp    80106720 <setpriority+0xfb>
        {
            if(temp->pid == pid)
8010668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668d:	8b 50 10             	mov    0x10(%eax),%edx
80106690:	8b 45 08             	mov    0x8(%ebp),%eax
80106693:	39 c2                	cmp    %eax,%edx
80106695:	75 7d                	jne    80106714 <setpriority+0xef>
            {
                removeFromStateList(&ptable.pLists.ready[i],temp);
80106697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010669a:	05 cc 09 00 00       	add    $0x9cc,%eax
8010669f:	c1 e0 02             	shl    $0x2,%eax
801066a2:	05 a0 49 11 80       	add    $0x801149a0,%eax
801066a7:	83 c0 04             	add    $0x4,%eax
801066aa:	83 ec 08             	sub    $0x8,%esp
801066ad:	ff 75 f4             	pushl  -0xc(%ebp)
801066b0:	50                   	push   %eax
801066b1:	e8 e2 fb ff ff       	call   80106298 <removeFromStateList>
801066b6:	83 c4 10             	add    $0x10,%esp
                temp->budget = BUDGET;
801066b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bc:	c7 80 98 00 00 00 d0 	movl   $0x7d0,0x98(%eax)
801066c3:	07 00 00 
                temp->priority = priority;
801066c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801066cc:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
                addToStateListEnd(&ptable.pLists.ready[temp->priority],temp);
801066d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d5:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801066db:	05 cc 09 00 00       	add    $0x9cc,%eax
801066e0:	c1 e0 02             	shl    $0x2,%eax
801066e3:	05 a0 49 11 80       	add    $0x801149a0,%eax
801066e8:	83 c0 04             	add    $0x4,%eax
801066eb:	83 ec 08             	sub    $0x8,%esp
801066ee:	ff 75 f4             	pushl  -0xc(%ebp)
801066f1:	50                   	push   %eax
801066f2:	e8 37 fb ff ff       	call   8010622e <addToStateListEnd>
801066f7:	83 c4 10             	add    $0x10,%esp
                release(&ptable.lock);
801066fa:	83 ec 0c             	sub    $0xc,%esp
801066fd:	68 a0 49 11 80       	push   $0x801149a0
80106702:	e8 49 02 00 00       	call   80106950 <release>
80106707:	83 c4 10             	add    $0x10,%esp
                return 0;
8010670a:	b8 00 00 00 00       	mov    $0x0,%eax
8010670f:	e9 87 00 00 00       	jmp    8010679b <setpriority+0x176>
            }
            temp = temp->next;
80106714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106717:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010671d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        return -1;
    acquire(&ptable.lock);
    for(int i = 0; i < MAX+1; ++i)
    {
        temp = ptable.pLists.ready[i];
        while(temp !=0)
80106720:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106724:	0f 85 60 ff ff ff    	jne    8010668a <setpriority+0x65>
    if(pid > NPROC || pid < 0)
        return -1;
    if(priority < 0 || priority > MAX)
        return -1;
    acquire(&ptable.lock);
    for(int i = 0; i < MAX+1; ++i)
8010672a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010672e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80106732:	0f 8e 3b ff ff ff    	jle    80106673 <setpriority+0x4e>
                return 0;
            }
            temp = temp->next;
        }
    }
    temp = ptable.pLists.running;
80106738:	a1 0c 71 11 80       	mov    0x8011710c,%eax
8010673d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(travarse(temp,pid,priority) == 0)
80106740:	83 ec 04             	sub    $0x4,%esp
80106743:	ff 75 0c             	pushl  0xc(%ebp)
80106746:	ff 75 08             	pushl  0x8(%ebp)
80106749:	ff 75 f4             	pushl  -0xc(%ebp)
8010674c:	e8 76 fe ff ff       	call   801065c7 <travarse>
80106751:	83 c4 10             	add    $0x10,%esp
80106754:	85 c0                	test   %eax,%eax
80106756:	75 07                	jne    8010675f <setpriority+0x13a>
        return 0;
80106758:	b8 00 00 00 00       	mov    $0x0,%eax
8010675d:	eb 3c                	jmp    8010679b <setpriority+0x176>
    temp = ptable.pLists.sleep;
8010675f:	a1 04 71 11 80       	mov    0x80117104,%eax
80106764:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(travarse(temp,pid,priority) == 0)
80106767:	83 ec 04             	sub    $0x4,%esp
8010676a:	ff 75 0c             	pushl  0xc(%ebp)
8010676d:	ff 75 08             	pushl  0x8(%ebp)
80106770:	ff 75 f4             	pushl  -0xc(%ebp)
80106773:	e8 4f fe ff ff       	call   801065c7 <travarse>
80106778:	83 c4 10             	add    $0x10,%esp
8010677b:	85 c0                	test   %eax,%eax
8010677d:	75 07                	jne    80106786 <setpriority+0x161>
        return 0;
8010677f:	b8 00 00 00 00       	mov    $0x0,%eax
80106784:	eb 15                	jmp    8010679b <setpriority+0x176>
   
    release(&ptable.lock);
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	68 a0 49 11 80       	push   $0x801149a0
8010678e:	e8 bd 01 00 00       	call   80106950 <release>
80106793:	83 c4 10             	add    $0x10,%esp
    return 0;
80106796:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010679b:	c9                   	leave  
8010679c:	c3                   	ret    

8010679d <promoteRunnable>:


int
promoteRunnable(struct proc ** sList)
{
8010679d:	55                   	push   %ebp
8010679e:	89 e5                	mov    %esp,%ebp
801067a0:	83 ec 18             	sub    $0x18,%esp
   struct proc * temp;
   temp = *sList;
801067a3:	8b 45 08             	mov    0x8(%ebp),%eax
801067a6:	8b 00                	mov    (%eax),%eax
801067a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if (temp == 0) 
801067ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067af:	75 07                	jne    801067b8 <promoteRunnable+0x1b>
      return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	eb 7c                	jmp    80106834 <promoteRunnable+0x97>
 //  cprintf("TESTING");
   if (temp->priority == 0)
801067b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bb:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801067c1:	85 c0                	test   %eax,%eax
801067c3:	75 64                	jne    80106829 <promoteRunnable+0x8c>
      return 0;
801067c5:	b8 00 00 00 00       	mov    $0x0,%eax
801067ca:	eb 68                	jmp    80106834 <promoteRunnable+0x97>
   while (temp)
   {
      removeFromStateList(sList,temp);
801067cc:	ff 75 f4             	pushl  -0xc(%ebp)
801067cf:	ff 75 08             	pushl  0x8(%ebp)
801067d2:	e8 c1 fa ff ff       	call   80106298 <removeFromStateList>
801067d7:	83 c4 08             	add    $0x8,%esp
      if(temp)
801067da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067de:	74 3d                	je     8010681d <promoteRunnable+0x80>
      {
         temp->priority -=1;
801067e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e3:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801067e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801067ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ef:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
         addToStateListEnd(&ptable.pLists.ready[temp->priority],temp);
801067f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f8:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801067fe:	05 cc 09 00 00       	add    $0x9cc,%eax
80106803:	c1 e0 02             	shl    $0x2,%eax
80106806:	05 a0 49 11 80       	add    $0x801149a0,%eax
8010680b:	83 c0 04             	add    $0x4,%eax
8010680e:	83 ec 08             	sub    $0x8,%esp
80106811:	ff 75 f4             	pushl  -0xc(%ebp)
80106814:	50                   	push   %eax
80106815:	e8 14 fa ff ff       	call   8010622e <addToStateListEnd>
8010681a:	83 c4 10             	add    $0x10,%esp
      }
      temp = temp->next;
8010681d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106820:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106826:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if (temp == 0) 
      return -1;
 //  cprintf("TESTING");
   if (temp->priority == 0)
      return 0;
   while (temp)
80106829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010682d:	75 9d                	jne    801067cc <promoteRunnable+0x2f>
         temp->priority -=1;
         addToStateListEnd(&ptable.pLists.ready[temp->priority],temp);
      }
      temp = temp->next;
   }
   return 0;
8010682f:	b8 00 00 00 00       	mov    $0x0,%eax
}  
80106834:	c9                   	leave  
80106835:	c3                   	ret    

80106836 <promoteSR>:

int
promoteSR(struct proc ** sList)
{
80106836:	55                   	push   %ebp
80106837:	89 e5                	mov    %esp,%ebp
80106839:	83 ec 10             	sub    $0x10,%esp
   struct proc * temp;
   temp = *sList;
8010683c:	8b 45 08             	mov    0x8(%ebp),%eax
8010683f:	8b 00                	mov    (%eax),%eax
80106841:	89 45 fc             	mov    %eax,-0x4(%ebp)
   if (*sList == 0) 
80106844:	8b 45 08             	mov    0x8(%ebp),%eax
80106847:	8b 00                	mov    (%eax),%eax
80106849:	85 c0                	test   %eax,%eax
8010684b:	75 35                	jne    80106882 <promoteSR+0x4c>
      return -1;
8010684d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106852:	eb 39                	jmp    8010688d <promoteSR+0x57>
   while (temp)
   {
      if (temp->priority > 0)
80106854:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106857:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010685d:	85 c0                	test   %eax,%eax
8010685f:	7e 15                	jle    80106876 <promoteSR+0x40>
         temp->priority -= 1;
80106861:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106864:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010686a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010686d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106870:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      temp = temp->next;
80106876:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106879:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010687f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
   struct proc * temp;
   temp = *sList;
   if (*sList == 0) 
      return -1;
   while (temp)
80106882:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106886:	75 cc                	jne    80106854 <promoteSR+0x1e>
   {
      if (temp->priority > 0)
         temp->priority -= 1;
      temp = temp->next;
   }
   return 0;
80106888:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010688d:	c9                   	leave  
8010688e:	c3                   	ret    

8010688f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010688f:	55                   	push   %ebp
80106890:	89 e5                	mov    %esp,%ebp
80106892:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80106895:	9c                   	pushf  
80106896:	58                   	pop    %eax
80106897:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010689a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010689d:	c9                   	leave  
8010689e:	c3                   	ret    

8010689f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010689f:	55                   	push   %ebp
801068a0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801068a2:	fa                   	cli    
}
801068a3:	90                   	nop
801068a4:	5d                   	pop    %ebp
801068a5:	c3                   	ret    

801068a6 <sti>:

static inline void
sti(void)
{
801068a6:	55                   	push   %ebp
801068a7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801068a9:	fb                   	sti    
}
801068aa:	90                   	nop
801068ab:	5d                   	pop    %ebp
801068ac:	c3                   	ret    

801068ad <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801068ad:	55                   	push   %ebp
801068ae:	89 e5                	mov    %esp,%ebp
801068b0:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801068b3:	8b 55 08             	mov    0x8(%ebp),%edx
801068b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801068b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801068bc:	f0 87 02             	lock xchg %eax,(%edx)
801068bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801068c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801068c5:	c9                   	leave  
801068c6:	c3                   	ret    

801068c7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801068c7:	55                   	push   %ebp
801068c8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801068ca:	8b 45 08             	mov    0x8(%ebp),%eax
801068cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801068d0:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801068d3:	8b 45 08             	mov    0x8(%ebp),%eax
801068d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801068dc:	8b 45 08             	mov    0x8(%ebp),%eax
801068df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801068e6:	90                   	nop
801068e7:	5d                   	pop    %ebp
801068e8:	c3                   	ret    

801068e9 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801068e9:	55                   	push   %ebp
801068ea:	89 e5                	mov    %esp,%ebp
801068ec:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801068ef:	e8 52 01 00 00       	call   80106a46 <pushcli>
  if(holding(lk))
801068f4:	8b 45 08             	mov    0x8(%ebp),%eax
801068f7:	83 ec 0c             	sub    $0xc,%esp
801068fa:	50                   	push   %eax
801068fb:	e8 1c 01 00 00       	call   80106a1c <holding>
80106900:	83 c4 10             	add    $0x10,%esp
80106903:	85 c0                	test   %eax,%eax
80106905:	74 0d                	je     80106914 <acquire+0x2b>
    panic("acquire");
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	68 5e a6 10 80       	push   $0x8010a65e
8010690f:	e8 52 9c ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106914:	90                   	nop
80106915:	8b 45 08             	mov    0x8(%ebp),%eax
80106918:	83 ec 08             	sub    $0x8,%esp
8010691b:	6a 01                	push   $0x1
8010691d:	50                   	push   %eax
8010691e:	e8 8a ff ff ff       	call   801068ad <xchg>
80106923:	83 c4 10             	add    $0x10,%esp
80106926:	85 c0                	test   %eax,%eax
80106928:	75 eb                	jne    80106915 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010692a:	8b 45 08             	mov    0x8(%ebp),%eax
8010692d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106934:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106937:	8b 45 08             	mov    0x8(%ebp),%eax
8010693a:	83 c0 0c             	add    $0xc,%eax
8010693d:	83 ec 08             	sub    $0x8,%esp
80106940:	50                   	push   %eax
80106941:	8d 45 08             	lea    0x8(%ebp),%eax
80106944:	50                   	push   %eax
80106945:	e8 58 00 00 00       	call   801069a2 <getcallerpcs>
8010694a:	83 c4 10             	add    $0x10,%esp
}
8010694d:	90                   	nop
8010694e:	c9                   	leave  
8010694f:	c3                   	ret    

80106950 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80106950:	55                   	push   %ebp
80106951:	89 e5                	mov    %esp,%ebp
80106953:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80106956:	83 ec 0c             	sub    $0xc,%esp
80106959:	ff 75 08             	pushl  0x8(%ebp)
8010695c:	e8 bb 00 00 00       	call   80106a1c <holding>
80106961:	83 c4 10             	add    $0x10,%esp
80106964:	85 c0                	test   %eax,%eax
80106966:	75 0d                	jne    80106975 <release+0x25>
    panic("release");
80106968:	83 ec 0c             	sub    $0xc,%esp
8010696b:	68 66 a6 10 80       	push   $0x8010a666
80106970:	e8 f1 9b ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106975:	8b 45 08             	mov    0x8(%ebp),%eax
80106978:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010697f:	8b 45 08             	mov    0x8(%ebp),%eax
80106982:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106989:	8b 45 08             	mov    0x8(%ebp),%eax
8010698c:	83 ec 08             	sub    $0x8,%esp
8010698f:	6a 00                	push   $0x0
80106991:	50                   	push   %eax
80106992:	e8 16 ff ff ff       	call   801068ad <xchg>
80106997:	83 c4 10             	add    $0x10,%esp

  popcli();
8010699a:	e8 ec 00 00 00       	call   80106a8b <popcli>
}
8010699f:	90                   	nop
801069a0:	c9                   	leave  
801069a1:	c3                   	ret    

801069a2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801069a2:	55                   	push   %ebp
801069a3:	89 e5                	mov    %esp,%ebp
801069a5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801069a8:	8b 45 08             	mov    0x8(%ebp),%eax
801069ab:	83 e8 08             	sub    $0x8,%eax
801069ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801069b1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801069b8:	eb 38                	jmp    801069f2 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801069ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801069be:	74 53                	je     80106a13 <getcallerpcs+0x71>
801069c0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801069c7:	76 4a                	jbe    80106a13 <getcallerpcs+0x71>
801069c9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801069cd:	74 44                	je     80106a13 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801069cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801069d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801069d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801069dc:	01 c2                	add    %eax,%edx
801069de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801069e1:	8b 40 04             	mov    0x4(%eax),%eax
801069e4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801069e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801069e9:	8b 00                	mov    (%eax),%eax
801069eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801069ee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801069f2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801069f6:	7e c2                	jle    801069ba <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801069f8:	eb 19                	jmp    80106a13 <getcallerpcs+0x71>
    pcs[i] = 0;
801069fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801069fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106a04:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a07:	01 d0                	add    %edx,%eax
80106a09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106a0f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106a13:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106a17:	7e e1                	jle    801069fa <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106a19:	90                   	nop
80106a1a:	c9                   	leave  
80106a1b:	c3                   	ret    

80106a1c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106a1c:	55                   	push   %ebp
80106a1d:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a22:	8b 00                	mov    (%eax),%eax
80106a24:	85 c0                	test   %eax,%eax
80106a26:	74 17                	je     80106a3f <holding+0x23>
80106a28:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2b:	8b 50 08             	mov    0x8(%eax),%edx
80106a2e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a34:	39 c2                	cmp    %eax,%edx
80106a36:	75 07                	jne    80106a3f <holding+0x23>
80106a38:	b8 01 00 00 00       	mov    $0x1,%eax
80106a3d:	eb 05                	jmp    80106a44 <holding+0x28>
80106a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a44:	5d                   	pop    %ebp
80106a45:	c3                   	ret    

80106a46 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106a46:	55                   	push   %ebp
80106a47:	89 e5                	mov    %esp,%ebp
80106a49:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106a4c:	e8 3e fe ff ff       	call   8010688f <readeflags>
80106a51:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80106a54:	e8 46 fe ff ff       	call   8010689f <cli>
  if(cpu->ncli++ == 0)
80106a59:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106a60:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106a66:	8d 48 01             	lea    0x1(%eax),%ecx
80106a69:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106a6f:	85 c0                	test   %eax,%eax
80106a71:	75 15                	jne    80106a88 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80106a73:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a79:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106a7c:	81 e2 00 02 00 00    	and    $0x200,%edx
80106a82:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106a88:	90                   	nop
80106a89:	c9                   	leave  
80106a8a:	c3                   	ret    

80106a8b <popcli>:

void
popcli(void)
{
80106a8b:	55                   	push   %ebp
80106a8c:	89 e5                	mov    %esp,%ebp
80106a8e:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106a91:	e8 f9 fd ff ff       	call   8010688f <readeflags>
80106a96:	25 00 02 00 00       	and    $0x200,%eax
80106a9b:	85 c0                	test   %eax,%eax
80106a9d:	74 0d                	je     80106aac <popcli+0x21>
    panic("popcli - interruptible");
80106a9f:	83 ec 0c             	sub    $0xc,%esp
80106aa2:	68 6e a6 10 80       	push   $0x8010a66e
80106aa7:	e8 ba 9a ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106aac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ab2:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106ab8:	83 ea 01             	sub    $0x1,%edx
80106abb:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106ac1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106ac7:	85 c0                	test   %eax,%eax
80106ac9:	79 0d                	jns    80106ad8 <popcli+0x4d>
    panic("popcli");
80106acb:	83 ec 0c             	sub    $0xc,%esp
80106ace:	68 85 a6 10 80       	push   $0x8010a685
80106ad3:	e8 8e 9a ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106ad8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ade:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106ae4:	85 c0                	test   %eax,%eax
80106ae6:	75 15                	jne    80106afd <popcli+0x72>
80106ae8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106aee:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106af4:	85 c0                	test   %eax,%eax
80106af6:	74 05                	je     80106afd <popcli+0x72>
    sti();
80106af8:	e8 a9 fd ff ff       	call   801068a6 <sti>
}
80106afd:	90                   	nop
80106afe:	c9                   	leave  
80106aff:	c3                   	ret    

80106b00 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106b00:	55                   	push   %ebp
80106b01:	89 e5                	mov    %esp,%ebp
80106b03:	57                   	push   %edi
80106b04:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106b08:	8b 55 10             	mov    0x10(%ebp),%edx
80106b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b0e:	89 cb                	mov    %ecx,%ebx
80106b10:	89 df                	mov    %ebx,%edi
80106b12:	89 d1                	mov    %edx,%ecx
80106b14:	fc                   	cld    
80106b15:	f3 aa                	rep stos %al,%es:(%edi)
80106b17:	89 ca                	mov    %ecx,%edx
80106b19:	89 fb                	mov    %edi,%ebx
80106b1b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106b1e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106b21:	90                   	nop
80106b22:	5b                   	pop    %ebx
80106b23:	5f                   	pop    %edi
80106b24:	5d                   	pop    %ebp
80106b25:	c3                   	ret    

80106b26 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106b26:	55                   	push   %ebp
80106b27:	89 e5                	mov    %esp,%ebp
80106b29:	57                   	push   %edi
80106b2a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106b2e:	8b 55 10             	mov    0x10(%ebp),%edx
80106b31:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b34:	89 cb                	mov    %ecx,%ebx
80106b36:	89 df                	mov    %ebx,%edi
80106b38:	89 d1                	mov    %edx,%ecx
80106b3a:	fc                   	cld    
80106b3b:	f3 ab                	rep stos %eax,%es:(%edi)
80106b3d:	89 ca                	mov    %ecx,%edx
80106b3f:	89 fb                	mov    %edi,%ebx
80106b41:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106b44:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106b47:	90                   	nop
80106b48:	5b                   	pop    %ebx
80106b49:	5f                   	pop    %edi
80106b4a:	5d                   	pop    %ebp
80106b4b:	c3                   	ret    

80106b4c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106b4c:	55                   	push   %ebp
80106b4d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b52:	83 e0 03             	and    $0x3,%eax
80106b55:	85 c0                	test   %eax,%eax
80106b57:	75 43                	jne    80106b9c <memset+0x50>
80106b59:	8b 45 10             	mov    0x10(%ebp),%eax
80106b5c:	83 e0 03             	and    $0x3,%eax
80106b5f:	85 c0                	test   %eax,%eax
80106b61:	75 39                	jne    80106b9c <memset+0x50>
    c &= 0xFF;
80106b63:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106b6a:	8b 45 10             	mov    0x10(%ebp),%eax
80106b6d:	c1 e8 02             	shr    $0x2,%eax
80106b70:	89 c1                	mov    %eax,%ecx
80106b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b75:	c1 e0 18             	shl    $0x18,%eax
80106b78:	89 c2                	mov    %eax,%edx
80106b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b7d:	c1 e0 10             	shl    $0x10,%eax
80106b80:	09 c2                	or     %eax,%edx
80106b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b85:	c1 e0 08             	shl    $0x8,%eax
80106b88:	09 d0                	or     %edx,%eax
80106b8a:	0b 45 0c             	or     0xc(%ebp),%eax
80106b8d:	51                   	push   %ecx
80106b8e:	50                   	push   %eax
80106b8f:	ff 75 08             	pushl  0x8(%ebp)
80106b92:	e8 8f ff ff ff       	call   80106b26 <stosl>
80106b97:	83 c4 0c             	add    $0xc,%esp
80106b9a:	eb 12                	jmp    80106bae <memset+0x62>
  } else
    stosb(dst, c, n);
80106b9c:	8b 45 10             	mov    0x10(%ebp),%eax
80106b9f:	50                   	push   %eax
80106ba0:	ff 75 0c             	pushl  0xc(%ebp)
80106ba3:	ff 75 08             	pushl  0x8(%ebp)
80106ba6:	e8 55 ff ff ff       	call   80106b00 <stosb>
80106bab:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106bae:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106bb1:	c9                   	leave  
80106bb2:	c3                   	ret    

80106bb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106bb3:	55                   	push   %ebp
80106bb4:	89 e5                	mov    %esp,%ebp
80106bb6:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bc2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106bc5:	eb 30                	jmp    80106bf7 <memcmp+0x44>
    if(*s1 != *s2)
80106bc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bca:	0f b6 10             	movzbl (%eax),%edx
80106bcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106bd0:	0f b6 00             	movzbl (%eax),%eax
80106bd3:	38 c2                	cmp    %al,%dl
80106bd5:	74 18                	je     80106bef <memcmp+0x3c>
      return *s1 - *s2;
80106bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bda:	0f b6 00             	movzbl (%eax),%eax
80106bdd:	0f b6 d0             	movzbl %al,%edx
80106be0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106be3:	0f b6 00             	movzbl (%eax),%eax
80106be6:	0f b6 c0             	movzbl %al,%eax
80106be9:	29 c2                	sub    %eax,%edx
80106beb:	89 d0                	mov    %edx,%eax
80106bed:	eb 1a                	jmp    80106c09 <memcmp+0x56>
    s1++, s2++;
80106bef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106bf3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106bf7:	8b 45 10             	mov    0x10(%ebp),%eax
80106bfa:	8d 50 ff             	lea    -0x1(%eax),%edx
80106bfd:	89 55 10             	mov    %edx,0x10(%ebp)
80106c00:	85 c0                	test   %eax,%eax
80106c02:	75 c3                	jne    80106bc7 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c09:	c9                   	leave  
80106c0a:	c3                   	ret    

80106c0b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106c0b:	55                   	push   %ebp
80106c0c:	89 e5                	mov    %esp,%ebp
80106c0e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c14:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106c17:	8b 45 08             	mov    0x8(%ebp),%eax
80106c1a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106c1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c20:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106c23:	73 54                	jae    80106c79 <memmove+0x6e>
80106c25:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106c28:	8b 45 10             	mov    0x10(%ebp),%eax
80106c2b:	01 d0                	add    %edx,%eax
80106c2d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106c30:	76 47                	jbe    80106c79 <memmove+0x6e>
    s += n;
80106c32:	8b 45 10             	mov    0x10(%ebp),%eax
80106c35:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106c38:	8b 45 10             	mov    0x10(%ebp),%eax
80106c3b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106c3e:	eb 13                	jmp    80106c53 <memmove+0x48>
      *--d = *--s;
80106c40:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106c44:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106c48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c4b:	0f b6 10             	movzbl (%eax),%edx
80106c4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106c51:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106c53:	8b 45 10             	mov    0x10(%ebp),%eax
80106c56:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c59:	89 55 10             	mov    %edx,0x10(%ebp)
80106c5c:	85 c0                	test   %eax,%eax
80106c5e:	75 e0                	jne    80106c40 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106c60:	eb 24                	jmp    80106c86 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106c62:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106c65:	8d 50 01             	lea    0x1(%eax),%edx
80106c68:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106c6b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106c6e:	8d 4a 01             	lea    0x1(%edx),%ecx
80106c71:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106c74:	0f b6 12             	movzbl (%edx),%edx
80106c77:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106c79:	8b 45 10             	mov    0x10(%ebp),%eax
80106c7c:	8d 50 ff             	lea    -0x1(%eax),%edx
80106c7f:	89 55 10             	mov    %edx,0x10(%ebp)
80106c82:	85 c0                	test   %eax,%eax
80106c84:	75 dc                	jne    80106c62 <memmove+0x57>
      *d++ = *s++;

  return dst;
80106c86:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106c89:	c9                   	leave  
80106c8a:	c3                   	ret    

80106c8b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106c8b:	55                   	push   %ebp
80106c8c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106c8e:	ff 75 10             	pushl  0x10(%ebp)
80106c91:	ff 75 0c             	pushl  0xc(%ebp)
80106c94:	ff 75 08             	pushl  0x8(%ebp)
80106c97:	e8 6f ff ff ff       	call   80106c0b <memmove>
80106c9c:	83 c4 0c             	add    $0xc,%esp
}
80106c9f:	c9                   	leave  
80106ca0:	c3                   	ret    

80106ca1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106ca1:	55                   	push   %ebp
80106ca2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106ca4:	eb 0c                	jmp    80106cb2 <strncmp+0x11>
    n--, p++, q++;
80106ca6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106caa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106cae:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106cb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cb6:	74 1a                	je     80106cd2 <strncmp+0x31>
80106cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cbb:	0f b6 00             	movzbl (%eax),%eax
80106cbe:	84 c0                	test   %al,%al
80106cc0:	74 10                	je     80106cd2 <strncmp+0x31>
80106cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc5:	0f b6 10             	movzbl (%eax),%edx
80106cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ccb:	0f b6 00             	movzbl (%eax),%eax
80106cce:	38 c2                	cmp    %al,%dl
80106cd0:	74 d4                	je     80106ca6 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106cd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106cd6:	75 07                	jne    80106cdf <strncmp+0x3e>
    return 0;
80106cd8:	b8 00 00 00 00       	mov    $0x0,%eax
80106cdd:	eb 16                	jmp    80106cf5 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce2:	0f b6 00             	movzbl (%eax),%eax
80106ce5:	0f b6 d0             	movzbl %al,%edx
80106ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ceb:	0f b6 00             	movzbl (%eax),%eax
80106cee:	0f b6 c0             	movzbl %al,%eax
80106cf1:	29 c2                	sub    %eax,%edx
80106cf3:	89 d0                	mov    %edx,%eax
}
80106cf5:	5d                   	pop    %ebp
80106cf6:	c3                   	ret    

80106cf7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106cf7:	55                   	push   %ebp
80106cf8:	89 e5                	mov    %esp,%ebp
80106cfa:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106d00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106d03:	90                   	nop
80106d04:	8b 45 10             	mov    0x10(%ebp),%eax
80106d07:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d0a:	89 55 10             	mov    %edx,0x10(%ebp)
80106d0d:	85 c0                	test   %eax,%eax
80106d0f:	7e 2c                	jle    80106d3d <strncpy+0x46>
80106d11:	8b 45 08             	mov    0x8(%ebp),%eax
80106d14:	8d 50 01             	lea    0x1(%eax),%edx
80106d17:	89 55 08             	mov    %edx,0x8(%ebp)
80106d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d1d:	8d 4a 01             	lea    0x1(%edx),%ecx
80106d20:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106d23:	0f b6 12             	movzbl (%edx),%edx
80106d26:	88 10                	mov    %dl,(%eax)
80106d28:	0f b6 00             	movzbl (%eax),%eax
80106d2b:	84 c0                	test   %al,%al
80106d2d:	75 d5                	jne    80106d04 <strncpy+0xd>
    ;
  while(n-- > 0)
80106d2f:	eb 0c                	jmp    80106d3d <strncpy+0x46>
    *s++ = 0;
80106d31:	8b 45 08             	mov    0x8(%ebp),%eax
80106d34:	8d 50 01             	lea    0x1(%eax),%edx
80106d37:	89 55 08             	mov    %edx,0x8(%ebp)
80106d3a:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106d3d:	8b 45 10             	mov    0x10(%ebp),%eax
80106d40:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d43:	89 55 10             	mov    %edx,0x10(%ebp)
80106d46:	85 c0                	test   %eax,%eax
80106d48:	7f e7                	jg     80106d31 <strncpy+0x3a>
    *s++ = 0;
  return os;
80106d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d4d:	c9                   	leave  
80106d4e:	c3                   	ret    

80106d4f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106d4f:	55                   	push   %ebp
80106d50:	89 e5                	mov    %esp,%ebp
80106d52:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106d55:	8b 45 08             	mov    0x8(%ebp),%eax
80106d58:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106d5f:	7f 05                	jg     80106d66 <safestrcpy+0x17>
    return os;
80106d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d64:	eb 31                	jmp    80106d97 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106d66:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106d6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106d6e:	7e 1e                	jle    80106d8e <safestrcpy+0x3f>
80106d70:	8b 45 08             	mov    0x8(%ebp),%eax
80106d73:	8d 50 01             	lea    0x1(%eax),%edx
80106d76:	89 55 08             	mov    %edx,0x8(%ebp)
80106d79:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d7c:	8d 4a 01             	lea    0x1(%edx),%ecx
80106d7f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106d82:	0f b6 12             	movzbl (%edx),%edx
80106d85:	88 10                	mov    %dl,(%eax)
80106d87:	0f b6 00             	movzbl (%eax),%eax
80106d8a:	84 c0                	test   %al,%al
80106d8c:	75 d8                	jne    80106d66 <safestrcpy+0x17>
    ;
  *s = 0;
80106d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d91:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106d94:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d97:	c9                   	leave  
80106d98:	c3                   	ret    

80106d99 <strlen>:

int
strlen(const char *s)
{
80106d99:	55                   	push   %ebp
80106d9a:	89 e5                	mov    %esp,%ebp
80106d9c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106d9f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106da6:	eb 04                	jmp    80106dac <strlen+0x13>
80106da8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106dac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106daf:	8b 45 08             	mov    0x8(%ebp),%eax
80106db2:	01 d0                	add    %edx,%eax
80106db4:	0f b6 00             	movzbl (%eax),%eax
80106db7:	84 c0                	test   %al,%al
80106db9:	75 ed                	jne    80106da8 <strlen+0xf>
    ;
  return n;
80106dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106dbe:	c9                   	leave  
80106dbf:	c3                   	ret    

80106dc0 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106dc0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106dc4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106dc8:	55                   	push   %ebp
  pushl %ebx
80106dc9:	53                   	push   %ebx
  pushl %esi
80106dca:	56                   	push   %esi
  pushl %edi
80106dcb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106dcc:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106dce:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106dd0:	5f                   	pop    %edi
  popl %esi
80106dd1:	5e                   	pop    %esi
  popl %ebx
80106dd2:	5b                   	pop    %ebx
  popl %ebp
80106dd3:	5d                   	pop    %ebp
  ret
80106dd4:	c3                   	ret    

80106dd5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106dd5:	55                   	push   %ebp
80106dd6:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106dd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dde:	8b 00                	mov    (%eax),%eax
80106de0:	3b 45 08             	cmp    0x8(%ebp),%eax
80106de3:	76 12                	jbe    80106df7 <fetchint+0x22>
80106de5:	8b 45 08             	mov    0x8(%ebp),%eax
80106de8:	8d 50 04             	lea    0x4(%eax),%edx
80106deb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106df1:	8b 00                	mov    (%eax),%eax
80106df3:	39 c2                	cmp    %eax,%edx
80106df5:	76 07                	jbe    80106dfe <fetchint+0x29>
    return -1;
80106df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dfc:	eb 0f                	jmp    80106e0d <fetchint+0x38>
  *ip = *(int*)(addr);
80106dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80106e01:	8b 10                	mov    (%eax),%edx
80106e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e06:	89 10                	mov    %edx,(%eax)
  return 0;
80106e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e0d:	5d                   	pop    %ebp
80106e0e:	c3                   	ret    

80106e0f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106e0f:	55                   	push   %ebp
80106e10:	89 e5                	mov    %esp,%ebp
80106e12:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106e15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e1b:	8b 00                	mov    (%eax),%eax
80106e1d:	3b 45 08             	cmp    0x8(%ebp),%eax
80106e20:	77 07                	ja     80106e29 <fetchstr+0x1a>
    return -1;
80106e22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e27:	eb 46                	jmp    80106e6f <fetchstr+0x60>
  *pp = (char*)addr;
80106e29:	8b 55 08             	mov    0x8(%ebp),%edx
80106e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e2f:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e37:	8b 00                	mov    (%eax),%eax
80106e39:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e3f:	8b 00                	mov    (%eax),%eax
80106e41:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106e44:	eb 1c                	jmp    80106e62 <fetchstr+0x53>
    if(*s == 0)
80106e46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e49:	0f b6 00             	movzbl (%eax),%eax
80106e4c:	84 c0                	test   %al,%al
80106e4e:	75 0e                	jne    80106e5e <fetchstr+0x4f>
      return s - *pp;
80106e50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e53:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e56:	8b 00                	mov    (%eax),%eax
80106e58:	29 c2                	sub    %eax,%edx
80106e5a:	89 d0                	mov    %edx,%eax
80106e5c:	eb 11                	jmp    80106e6f <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106e5e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e65:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106e68:	72 dc                	jb     80106e46 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106e6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106e6f:	c9                   	leave  
80106e70:	c3                   	ret    

80106e71 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106e71:	55                   	push   %ebp
80106e72:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e7a:	8b 40 18             	mov    0x18(%eax),%eax
80106e7d:	8b 40 44             	mov    0x44(%eax),%eax
80106e80:	8b 55 08             	mov    0x8(%ebp),%edx
80106e83:	c1 e2 02             	shl    $0x2,%edx
80106e86:	01 d0                	add    %edx,%eax
80106e88:	83 c0 04             	add    $0x4,%eax
80106e8b:	ff 75 0c             	pushl  0xc(%ebp)
80106e8e:	50                   	push   %eax
80106e8f:	e8 41 ff ff ff       	call   80106dd5 <fetchint>
80106e94:	83 c4 08             	add    $0x8,%esp
}
80106e97:	c9                   	leave  
80106e98:	c3                   	ret    

80106e99 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106e99:	55                   	push   %ebp
80106e9a:	89 e5                	mov    %esp,%ebp
80106e9c:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106e9f:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106ea2:	50                   	push   %eax
80106ea3:	ff 75 08             	pushl  0x8(%ebp)
80106ea6:	e8 c6 ff ff ff       	call   80106e71 <argint>
80106eab:	83 c4 08             	add    $0x8,%esp
80106eae:	85 c0                	test   %eax,%eax
80106eb0:	79 07                	jns    80106eb9 <argptr+0x20>
    return -1;
80106eb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eb7:	eb 3b                	jmp    80106ef4 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106eb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ebf:	8b 00                	mov    (%eax),%eax
80106ec1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ec4:	39 d0                	cmp    %edx,%eax
80106ec6:	76 16                	jbe    80106ede <argptr+0x45>
80106ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ecb:	89 c2                	mov    %eax,%edx
80106ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80106ed0:	01 c2                	add    %eax,%edx
80106ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed8:	8b 00                	mov    (%eax),%eax
80106eda:	39 c2                	cmp    %eax,%edx
80106edc:	76 07                	jbe    80106ee5 <argptr+0x4c>
    return -1;
80106ede:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee3:	eb 0f                	jmp    80106ef4 <argptr+0x5b>
  *pp = (char*)i;
80106ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ee8:	89 c2                	mov    %eax,%edx
80106eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eed:	89 10                	mov    %edx,(%eax)
  return 0;
80106eef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ef4:	c9                   	leave  
80106ef5:	c3                   	ret    

80106ef6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106ef6:	55                   	push   %ebp
80106ef7:	89 e5                	mov    %esp,%ebp
80106ef9:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106efc:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106eff:	50                   	push   %eax
80106f00:	ff 75 08             	pushl  0x8(%ebp)
80106f03:	e8 69 ff ff ff       	call   80106e71 <argint>
80106f08:	83 c4 08             	add    $0x8,%esp
80106f0b:	85 c0                	test   %eax,%eax
80106f0d:	79 07                	jns    80106f16 <argstr+0x20>
    return -1;
80106f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f14:	eb 0f                	jmp    80106f25 <argstr+0x2f>
  return fetchstr(addr, pp);
80106f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f19:	ff 75 0c             	pushl  0xc(%ebp)
80106f1c:	50                   	push   %eax
80106f1d:	e8 ed fe ff ff       	call   80106e0f <fetchstr>
80106f22:	83 c4 08             	add    $0x8,%esp
}
80106f25:	c9                   	leave  
80106f26:	c3                   	ret    

80106f27 <syscall>:

// put data structure for printing out system call invocation information here

void
syscall(void)
{
80106f27:	55                   	push   %ebp
80106f28:	89 e5                	mov    %esp,%ebp
80106f2a:	53                   	push   %ebx
80106f2b:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106f2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f34:	8b 40 18             	mov    0x18(%eax),%eax
80106f37:	8b 40 1c             	mov    0x1c(%eax),%eax
80106f3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106f3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f41:	7e 30                	jle    80106f73 <syscall+0x4c>
80106f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f46:	83 f8 21             	cmp    $0x21,%eax
80106f49:	77 28                	ja     80106f73 <syscall+0x4c>
80106f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f4e:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106f55:	85 c0                	test   %eax,%eax
80106f57:	74 1a                	je     80106f73 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106f59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f5f:	8b 58 18             	mov    0x18(%eax),%ebx
80106f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f65:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106f6c:	ff d0                	call   *%eax
80106f6e:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106f71:	eb 34                	jmp    80106fa7 <syscall+0x80>
    #ifdef  PRINT_SYSCALLS
    cprintf("%s->%d\n", syscallnames[num],proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106f73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f79:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
    #ifdef  PRINT_SYSCALLS
    cprintf("%s->%d\n", syscallnames[num],proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106f82:	8b 40 10             	mov    0x10(%eax),%eax
80106f85:	ff 75 f4             	pushl  -0xc(%ebp)
80106f88:	52                   	push   %edx
80106f89:	50                   	push   %eax
80106f8a:	68 8c a6 10 80       	push   $0x8010a68c
80106f8f:	e8 32 94 ff ff       	call   801003c6 <cprintf>
80106f94:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106f97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f9d:	8b 40 18             	mov    0x18(%eax),%eax
80106fa0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106fa7:	90                   	nop
80106fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106fab:	c9                   	leave  
80106fac:	c3                   	ret    

80106fad <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106fad:	55                   	push   %ebp
80106fae:	89 e5                	mov    %esp,%ebp
80106fb0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106fb3:	83 ec 08             	sub    $0x8,%esp
80106fb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fb9:	50                   	push   %eax
80106fba:	ff 75 08             	pushl  0x8(%ebp)
80106fbd:	e8 af fe ff ff       	call   80106e71 <argint>
80106fc2:	83 c4 10             	add    $0x10,%esp
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	79 07                	jns    80106fd0 <argfd+0x23>
    return -1;
80106fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fce:	eb 50                	jmp    80107020 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fd3:	85 c0                	test   %eax,%eax
80106fd5:	78 21                	js     80106ff8 <argfd+0x4b>
80106fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fda:	83 f8 0f             	cmp    $0xf,%eax
80106fdd:	7f 19                	jg     80106ff8 <argfd+0x4b>
80106fdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fe5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fe8:	83 c2 08             	add    $0x8,%edx
80106feb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ff2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ff6:	75 07                	jne    80106fff <argfd+0x52>
    return -1;
80106ff8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ffd:	eb 21                	jmp    80107020 <argfd+0x73>
  if(pfd)
80106fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80107003:	74 08                	je     8010700d <argfd+0x60>
    *pfd = fd;
80107005:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010700b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010700d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107011:	74 08                	je     8010701b <argfd+0x6e>
    *pf = f;
80107013:	8b 45 10             	mov    0x10(%ebp),%eax
80107016:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107019:	89 10                	mov    %edx,(%eax)
  return 0;
8010701b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107020:	c9                   	leave  
80107021:	c3                   	ret    

80107022 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80107022:	55                   	push   %ebp
80107023:	89 e5                	mov    %esp,%ebp
80107025:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80107028:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010702f:	eb 30                	jmp    80107061 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80107031:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107037:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010703a:	83 c2 08             	add    $0x8,%edx
8010703d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80107041:	85 c0                	test   %eax,%eax
80107043:	75 18                	jne    8010705d <fdalloc+0x3b>
      proc->ofile[fd] = f;
80107045:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010704b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010704e:	8d 4a 08             	lea    0x8(%edx),%ecx
80107051:	8b 55 08             	mov    0x8(%ebp),%edx
80107054:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80107058:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010705b:	eb 0f                	jmp    8010706c <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010705d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107061:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80107065:	7e ca                	jle    80107031 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80107067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010706c:	c9                   	leave  
8010706d:	c3                   	ret    

8010706e <sys_dup>:

int
sys_dup(void)
{
8010706e:	55                   	push   %ebp
8010706f:	89 e5                	mov    %esp,%ebp
80107071:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80107074:	83 ec 04             	sub    $0x4,%esp
80107077:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010707a:	50                   	push   %eax
8010707b:	6a 00                	push   $0x0
8010707d:	6a 00                	push   $0x0
8010707f:	e8 29 ff ff ff       	call   80106fad <argfd>
80107084:	83 c4 10             	add    $0x10,%esp
80107087:	85 c0                	test   %eax,%eax
80107089:	79 07                	jns    80107092 <sys_dup+0x24>
    return -1;
8010708b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107090:	eb 31                	jmp    801070c3 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80107092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107095:	83 ec 0c             	sub    $0xc,%esp
80107098:	50                   	push   %eax
80107099:	e8 84 ff ff ff       	call   80107022 <fdalloc>
8010709e:	83 c4 10             	add    $0x10,%esp
801070a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801070a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070a8:	79 07                	jns    801070b1 <sys_dup+0x43>
    return -1;
801070aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070af:	eb 12                	jmp    801070c3 <sys_dup+0x55>
  filedup(f);
801070b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070b4:	83 ec 0c             	sub    $0xc,%esp
801070b7:	50                   	push   %eax
801070b8:	e8 78 a0 ff ff       	call   80101135 <filedup>
801070bd:	83 c4 10             	add    $0x10,%esp
  return fd;
801070c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070c3:	c9                   	leave  
801070c4:	c3                   	ret    

801070c5 <sys_read>:

int
sys_read(void)
{
801070c5:	55                   	push   %ebp
801070c6:	89 e5                	mov    %esp,%ebp
801070c8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801070cb:	83 ec 04             	sub    $0x4,%esp
801070ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070d1:	50                   	push   %eax
801070d2:	6a 00                	push   $0x0
801070d4:	6a 00                	push   $0x0
801070d6:	e8 d2 fe ff ff       	call   80106fad <argfd>
801070db:	83 c4 10             	add    $0x10,%esp
801070de:	85 c0                	test   %eax,%eax
801070e0:	78 2e                	js     80107110 <sys_read+0x4b>
801070e2:	83 ec 08             	sub    $0x8,%esp
801070e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070e8:	50                   	push   %eax
801070e9:	6a 02                	push   $0x2
801070eb:	e8 81 fd ff ff       	call   80106e71 <argint>
801070f0:	83 c4 10             	add    $0x10,%esp
801070f3:	85 c0                	test   %eax,%eax
801070f5:	78 19                	js     80107110 <sys_read+0x4b>
801070f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070fa:	83 ec 04             	sub    $0x4,%esp
801070fd:	50                   	push   %eax
801070fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107101:	50                   	push   %eax
80107102:	6a 01                	push   $0x1
80107104:	e8 90 fd ff ff       	call   80106e99 <argptr>
80107109:	83 c4 10             	add    $0x10,%esp
8010710c:	85 c0                	test   %eax,%eax
8010710e:	79 07                	jns    80107117 <sys_read+0x52>
    return -1;
80107110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107115:	eb 17                	jmp    8010712e <sys_read+0x69>
  return fileread(f, p, n);
80107117:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010711a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010711d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107120:	83 ec 04             	sub    $0x4,%esp
80107123:	51                   	push   %ecx
80107124:	52                   	push   %edx
80107125:	50                   	push   %eax
80107126:	e8 9a a1 ff ff       	call   801012c5 <fileread>
8010712b:	83 c4 10             	add    $0x10,%esp
}
8010712e:	c9                   	leave  
8010712f:	c3                   	ret    

80107130 <sys_write>:

int
sys_write(void)
{
80107130:	55                   	push   %ebp
80107131:	89 e5                	mov    %esp,%ebp
80107133:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107136:	83 ec 04             	sub    $0x4,%esp
80107139:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010713c:	50                   	push   %eax
8010713d:	6a 00                	push   $0x0
8010713f:	6a 00                	push   $0x0
80107141:	e8 67 fe ff ff       	call   80106fad <argfd>
80107146:	83 c4 10             	add    $0x10,%esp
80107149:	85 c0                	test   %eax,%eax
8010714b:	78 2e                	js     8010717b <sys_write+0x4b>
8010714d:	83 ec 08             	sub    $0x8,%esp
80107150:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107153:	50                   	push   %eax
80107154:	6a 02                	push   $0x2
80107156:	e8 16 fd ff ff       	call   80106e71 <argint>
8010715b:	83 c4 10             	add    $0x10,%esp
8010715e:	85 c0                	test   %eax,%eax
80107160:	78 19                	js     8010717b <sys_write+0x4b>
80107162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107165:	83 ec 04             	sub    $0x4,%esp
80107168:	50                   	push   %eax
80107169:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010716c:	50                   	push   %eax
8010716d:	6a 01                	push   $0x1
8010716f:	e8 25 fd ff ff       	call   80106e99 <argptr>
80107174:	83 c4 10             	add    $0x10,%esp
80107177:	85 c0                	test   %eax,%eax
80107179:	79 07                	jns    80107182 <sys_write+0x52>
    return -1;
8010717b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107180:	eb 17                	jmp    80107199 <sys_write+0x69>
  return filewrite(f, p, n);
80107182:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107185:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718b:	83 ec 04             	sub    $0x4,%esp
8010718e:	51                   	push   %ecx
8010718f:	52                   	push   %edx
80107190:	50                   	push   %eax
80107191:	e8 e7 a1 ff ff       	call   8010137d <filewrite>
80107196:	83 c4 10             	add    $0x10,%esp
}
80107199:	c9                   	leave  
8010719a:	c3                   	ret    

8010719b <sys_close>:

int
sys_close(void)
{
8010719b:	55                   	push   %ebp
8010719c:	89 e5                	mov    %esp,%ebp
8010719e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801071a1:	83 ec 04             	sub    $0x4,%esp
801071a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071a7:	50                   	push   %eax
801071a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071ab:	50                   	push   %eax
801071ac:	6a 00                	push   $0x0
801071ae:	e8 fa fd ff ff       	call   80106fad <argfd>
801071b3:	83 c4 10             	add    $0x10,%esp
801071b6:	85 c0                	test   %eax,%eax
801071b8:	79 07                	jns    801071c1 <sys_close+0x26>
    return -1;
801071ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071bf:	eb 28                	jmp    801071e9 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801071c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071ca:	83 c2 08             	add    $0x8,%edx
801071cd:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071d4:	00 
  fileclose(f);
801071d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071d8:	83 ec 0c             	sub    $0xc,%esp
801071db:	50                   	push   %eax
801071dc:	e8 a5 9f ff ff       	call   80101186 <fileclose>
801071e1:	83 c4 10             	add    $0x10,%esp
  return 0;
801071e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071e9:	c9                   	leave  
801071ea:	c3                   	ret    

801071eb <sys_fstat>:

int
sys_fstat(void)
{
801071eb:	55                   	push   %ebp
801071ec:	89 e5                	mov    %esp,%ebp
801071ee:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801071f1:	83 ec 04             	sub    $0x4,%esp
801071f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071f7:	50                   	push   %eax
801071f8:	6a 00                	push   $0x0
801071fa:	6a 00                	push   $0x0
801071fc:	e8 ac fd ff ff       	call   80106fad <argfd>
80107201:	83 c4 10             	add    $0x10,%esp
80107204:	85 c0                	test   %eax,%eax
80107206:	78 17                	js     8010721f <sys_fstat+0x34>
80107208:	83 ec 04             	sub    $0x4,%esp
8010720b:	6a 1c                	push   $0x1c
8010720d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107210:	50                   	push   %eax
80107211:	6a 01                	push   $0x1
80107213:	e8 81 fc ff ff       	call   80106e99 <argptr>
80107218:	83 c4 10             	add    $0x10,%esp
8010721b:	85 c0                	test   %eax,%eax
8010721d:	79 07                	jns    80107226 <sys_fstat+0x3b>
    return -1;
8010721f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107224:	eb 13                	jmp    80107239 <sys_fstat+0x4e>
  return filestat(f, st);
80107226:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722c:	83 ec 08             	sub    $0x8,%esp
8010722f:	52                   	push   %edx
80107230:	50                   	push   %eax
80107231:	e8 38 a0 ff ff       	call   8010126e <filestat>
80107236:	83 c4 10             	add    $0x10,%esp
}
80107239:	c9                   	leave  
8010723a:	c3                   	ret    

8010723b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010723b:	55                   	push   %ebp
8010723c:	89 e5                	mov    %esp,%ebp
8010723e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80107241:	83 ec 08             	sub    $0x8,%esp
80107244:	8d 45 d8             	lea    -0x28(%ebp),%eax
80107247:	50                   	push   %eax
80107248:	6a 00                	push   $0x0
8010724a:	e8 a7 fc ff ff       	call   80106ef6 <argstr>
8010724f:	83 c4 10             	add    $0x10,%esp
80107252:	85 c0                	test   %eax,%eax
80107254:	78 15                	js     8010726b <sys_link+0x30>
80107256:	83 ec 08             	sub    $0x8,%esp
80107259:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010725c:	50                   	push   %eax
8010725d:	6a 01                	push   $0x1
8010725f:	e8 92 fc ff ff       	call   80106ef6 <argstr>
80107264:	83 c4 10             	add    $0x10,%esp
80107267:	85 c0                	test   %eax,%eax
80107269:	79 0a                	jns    80107275 <sys_link+0x3a>
    return -1;
8010726b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107270:	e9 68 01 00 00       	jmp    801073dd <sys_link+0x1a2>

  begin_op();
80107275:	e8 16 c6 ff ff       	call   80103890 <begin_op>
  if((ip = namei(old)) == 0){
8010727a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010727d:	83 ec 0c             	sub    $0xc,%esp
80107280:	50                   	push   %eax
80107281:	e8 6b b4 ff ff       	call   801026f1 <namei>
80107286:	83 c4 10             	add    $0x10,%esp
80107289:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010728c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107290:	75 0f                	jne    801072a1 <sys_link+0x66>
    end_op();
80107292:	e8 85 c6 ff ff       	call   8010391c <end_op>
    return -1;
80107297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010729c:	e9 3c 01 00 00       	jmp    801073dd <sys_link+0x1a2>
  }

  ilock(ip);
801072a1:	83 ec 0c             	sub    $0xc,%esp
801072a4:	ff 75 f4             	pushl  -0xc(%ebp)
801072a7:	e8 37 a8 ff ff       	call   80101ae3 <ilock>
801072ac:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801072af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801072b6:	66 83 f8 01          	cmp    $0x1,%ax
801072ba:	75 1d                	jne    801072d9 <sys_link+0x9e>
    iunlockput(ip);
801072bc:	83 ec 0c             	sub    $0xc,%esp
801072bf:	ff 75 f4             	pushl  -0xc(%ebp)
801072c2:	e8 04 ab ff ff       	call   80101dcb <iunlockput>
801072c7:	83 c4 10             	add    $0x10,%esp
    end_op();
801072ca:	e8 4d c6 ff ff       	call   8010391c <end_op>
    return -1;
801072cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072d4:	e9 04 01 00 00       	jmp    801073dd <sys_link+0x1a2>
  }

  ip->nlink++;
801072d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072dc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801072e0:	83 c0 01             	add    $0x1,%eax
801072e3:	89 c2                	mov    %eax,%edx
801072e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801072ec:	83 ec 0c             	sub    $0xc,%esp
801072ef:	ff 75 f4             	pushl  -0xc(%ebp)
801072f2:	e8 ea a5 ff ff       	call   801018e1 <iupdate>
801072f7:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801072fa:	83 ec 0c             	sub    $0xc,%esp
801072fd:	ff 75 f4             	pushl  -0xc(%ebp)
80107300:	e8 64 a9 ff ff       	call   80101c69 <iunlock>
80107305:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80107308:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010730b:	83 ec 08             	sub    $0x8,%esp
8010730e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80107311:	52                   	push   %edx
80107312:	50                   	push   %eax
80107313:	e8 f5 b3 ff ff       	call   8010270d <nameiparent>
80107318:	83 c4 10             	add    $0x10,%esp
8010731b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010731e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107322:	74 71                	je     80107395 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80107324:	83 ec 0c             	sub    $0xc,%esp
80107327:	ff 75 f0             	pushl  -0x10(%ebp)
8010732a:	e8 b4 a7 ff ff       	call   80101ae3 <ilock>
8010732f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80107332:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107335:	8b 10                	mov    (%eax),%edx
80107337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733a:	8b 00                	mov    (%eax),%eax
8010733c:	39 c2                	cmp    %eax,%edx
8010733e:	75 1d                	jne    8010735d <sys_link+0x122>
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	8b 40 04             	mov    0x4(%eax),%eax
80107346:	83 ec 04             	sub    $0x4,%esp
80107349:	50                   	push   %eax
8010734a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010734d:	50                   	push   %eax
8010734e:	ff 75 f0             	pushl  -0x10(%ebp)
80107351:	e8 ff b0 ff ff       	call   80102455 <dirlink>
80107356:	83 c4 10             	add    $0x10,%esp
80107359:	85 c0                	test   %eax,%eax
8010735b:	79 10                	jns    8010736d <sys_link+0x132>
    iunlockput(dp);
8010735d:	83 ec 0c             	sub    $0xc,%esp
80107360:	ff 75 f0             	pushl  -0x10(%ebp)
80107363:	e8 63 aa ff ff       	call   80101dcb <iunlockput>
80107368:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010736b:	eb 29                	jmp    80107396 <sys_link+0x15b>
  }
  iunlockput(dp);
8010736d:	83 ec 0c             	sub    $0xc,%esp
80107370:	ff 75 f0             	pushl  -0x10(%ebp)
80107373:	e8 53 aa ff ff       	call   80101dcb <iunlockput>
80107378:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010737b:	83 ec 0c             	sub    $0xc,%esp
8010737e:	ff 75 f4             	pushl  -0xc(%ebp)
80107381:	e8 55 a9 ff ff       	call   80101cdb <iput>
80107386:	83 c4 10             	add    $0x10,%esp

  end_op();
80107389:	e8 8e c5 ff ff       	call   8010391c <end_op>

  return 0;
8010738e:	b8 00 00 00 00       	mov    $0x0,%eax
80107393:	eb 48                	jmp    801073dd <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80107395:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80107396:	83 ec 0c             	sub    $0xc,%esp
80107399:	ff 75 f4             	pushl  -0xc(%ebp)
8010739c:	e8 42 a7 ff ff       	call   80101ae3 <ilock>
801073a1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801073a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801073ab:	83 e8 01             	sub    $0x1,%eax
801073ae:	89 c2                	mov    %eax,%edx
801073b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801073b7:	83 ec 0c             	sub    $0xc,%esp
801073ba:	ff 75 f4             	pushl  -0xc(%ebp)
801073bd:	e8 1f a5 ff ff       	call   801018e1 <iupdate>
801073c2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801073c5:	83 ec 0c             	sub    $0xc,%esp
801073c8:	ff 75 f4             	pushl  -0xc(%ebp)
801073cb:	e8 fb a9 ff ff       	call   80101dcb <iunlockput>
801073d0:	83 c4 10             	add    $0x10,%esp
  end_op();
801073d3:	e8 44 c5 ff ff       	call   8010391c <end_op>
  return -1;
801073d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073dd:	c9                   	leave  
801073de:	c3                   	ret    

801073df <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801073df:	55                   	push   %ebp
801073e0:	89 e5                	mov    %esp,%ebp
801073e2:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801073e5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801073ec:	eb 40                	jmp    8010742e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801073ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f1:	6a 10                	push   $0x10
801073f3:	50                   	push   %eax
801073f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801073f7:	50                   	push   %eax
801073f8:	ff 75 08             	pushl  0x8(%ebp)
801073fb:	e8 a1 ac ff ff       	call   801020a1 <readi>
80107400:	83 c4 10             	add    $0x10,%esp
80107403:	83 f8 10             	cmp    $0x10,%eax
80107406:	74 0d                	je     80107415 <isdirempty+0x36>
      panic("isdirempty: readi");
80107408:	83 ec 0c             	sub    $0xc,%esp
8010740b:	68 a8 a6 10 80       	push   $0x8010a6a8
80107410:	e8 51 91 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80107415:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80107419:	66 85 c0             	test   %ax,%ax
8010741c:	74 07                	je     80107425 <isdirempty+0x46>
      return 0;
8010741e:	b8 00 00 00 00       	mov    $0x0,%eax
80107423:	eb 1b                	jmp    80107440 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	83 c0 10             	add    $0x10,%eax
8010742b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010742e:	8b 45 08             	mov    0x8(%ebp),%eax
80107431:	8b 50 20             	mov    0x20(%eax),%edx
80107434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107437:	39 c2                	cmp    %eax,%edx
80107439:	77 b3                	ja     801073ee <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010743b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80107440:	c9                   	leave  
80107441:	c3                   	ret    

80107442 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80107442:	55                   	push   %ebp
80107443:	89 e5                	mov    %esp,%ebp
80107445:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80107448:	83 ec 08             	sub    $0x8,%esp
8010744b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010744e:	50                   	push   %eax
8010744f:	6a 00                	push   $0x0
80107451:	e8 a0 fa ff ff       	call   80106ef6 <argstr>
80107456:	83 c4 10             	add    $0x10,%esp
80107459:	85 c0                	test   %eax,%eax
8010745b:	79 0a                	jns    80107467 <sys_unlink+0x25>
    return -1;
8010745d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107462:	e9 bc 01 00 00       	jmp    80107623 <sys_unlink+0x1e1>

  begin_op();
80107467:	e8 24 c4 ff ff       	call   80103890 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010746c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010746f:	83 ec 08             	sub    $0x8,%esp
80107472:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80107475:	52                   	push   %edx
80107476:	50                   	push   %eax
80107477:	e8 91 b2 ff ff       	call   8010270d <nameiparent>
8010747c:	83 c4 10             	add    $0x10,%esp
8010747f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107482:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107486:	75 0f                	jne    80107497 <sys_unlink+0x55>
    end_op();
80107488:	e8 8f c4 ff ff       	call   8010391c <end_op>
    return -1;
8010748d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107492:	e9 8c 01 00 00       	jmp    80107623 <sys_unlink+0x1e1>
  }

  ilock(dp);
80107497:	83 ec 0c             	sub    $0xc,%esp
8010749a:	ff 75 f4             	pushl  -0xc(%ebp)
8010749d:	e8 41 a6 ff ff       	call   80101ae3 <ilock>
801074a2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801074a5:	83 ec 08             	sub    $0x8,%esp
801074a8:	68 ba a6 10 80       	push   $0x8010a6ba
801074ad:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801074b0:	50                   	push   %eax
801074b1:	e8 ca ae ff ff       	call   80102380 <namecmp>
801074b6:	83 c4 10             	add    $0x10,%esp
801074b9:	85 c0                	test   %eax,%eax
801074bb:	0f 84 4a 01 00 00    	je     8010760b <sys_unlink+0x1c9>
801074c1:	83 ec 08             	sub    $0x8,%esp
801074c4:	68 bc a6 10 80       	push   $0x8010a6bc
801074c9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801074cc:	50                   	push   %eax
801074cd:	e8 ae ae ff ff       	call   80102380 <namecmp>
801074d2:	83 c4 10             	add    $0x10,%esp
801074d5:	85 c0                	test   %eax,%eax
801074d7:	0f 84 2e 01 00 00    	je     8010760b <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801074dd:	83 ec 04             	sub    $0x4,%esp
801074e0:	8d 45 c8             	lea    -0x38(%ebp),%eax
801074e3:	50                   	push   %eax
801074e4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801074e7:	50                   	push   %eax
801074e8:	ff 75 f4             	pushl  -0xc(%ebp)
801074eb:	e8 ab ae ff ff       	call   8010239b <dirlookup>
801074f0:	83 c4 10             	add    $0x10,%esp
801074f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801074f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801074fa:	0f 84 0a 01 00 00    	je     8010760a <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80107500:	83 ec 0c             	sub    $0xc,%esp
80107503:	ff 75 f0             	pushl  -0x10(%ebp)
80107506:	e8 d8 a5 ff ff       	call   80101ae3 <ilock>
8010750b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010750e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107511:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107515:	66 85 c0             	test   %ax,%ax
80107518:	7f 0d                	jg     80107527 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010751a:	83 ec 0c             	sub    $0xc,%esp
8010751d:	68 bf a6 10 80       	push   $0x8010a6bf
80107522:	e8 3f 90 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80107527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010752a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010752e:	66 83 f8 01          	cmp    $0x1,%ax
80107532:	75 25                	jne    80107559 <sys_unlink+0x117>
80107534:	83 ec 0c             	sub    $0xc,%esp
80107537:	ff 75 f0             	pushl  -0x10(%ebp)
8010753a:	e8 a0 fe ff ff       	call   801073df <isdirempty>
8010753f:	83 c4 10             	add    $0x10,%esp
80107542:	85 c0                	test   %eax,%eax
80107544:	75 13                	jne    80107559 <sys_unlink+0x117>
    iunlockput(ip);
80107546:	83 ec 0c             	sub    $0xc,%esp
80107549:	ff 75 f0             	pushl  -0x10(%ebp)
8010754c:	e8 7a a8 ff ff       	call   80101dcb <iunlockput>
80107551:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107554:	e9 b2 00 00 00       	jmp    8010760b <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80107559:	83 ec 04             	sub    $0x4,%esp
8010755c:	6a 10                	push   $0x10
8010755e:	6a 00                	push   $0x0
80107560:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107563:	50                   	push   %eax
80107564:	e8 e3 f5 ff ff       	call   80106b4c <memset>
80107569:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010756c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010756f:	6a 10                	push   $0x10
80107571:	50                   	push   %eax
80107572:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107575:	50                   	push   %eax
80107576:	ff 75 f4             	pushl  -0xc(%ebp)
80107579:	e8 7a ac ff ff       	call   801021f8 <writei>
8010757e:	83 c4 10             	add    $0x10,%esp
80107581:	83 f8 10             	cmp    $0x10,%eax
80107584:	74 0d                	je     80107593 <sys_unlink+0x151>
    panic("unlink: writei");
80107586:	83 ec 0c             	sub    $0xc,%esp
80107589:	68 d1 a6 10 80       	push   $0x8010a6d1
8010758e:	e8 d3 8f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80107593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107596:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010759a:	66 83 f8 01          	cmp    $0x1,%ax
8010759e:	75 21                	jne    801075c1 <sys_unlink+0x17f>
    dp->nlink--;
801075a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801075a7:	83 e8 01             	sub    $0x1,%eax
801075aa:	89 c2                	mov    %eax,%edx
801075ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075af:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801075b3:	83 ec 0c             	sub    $0xc,%esp
801075b6:	ff 75 f4             	pushl  -0xc(%ebp)
801075b9:	e8 23 a3 ff ff       	call   801018e1 <iupdate>
801075be:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801075c1:	83 ec 0c             	sub    $0xc,%esp
801075c4:	ff 75 f4             	pushl  -0xc(%ebp)
801075c7:	e8 ff a7 ff ff       	call   80101dcb <iunlockput>
801075cc:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801075cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075d2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801075d6:	83 e8 01             	sub    $0x1,%eax
801075d9:	89 c2                	mov    %eax,%edx
801075db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075de:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801075e2:	83 ec 0c             	sub    $0xc,%esp
801075e5:	ff 75 f0             	pushl  -0x10(%ebp)
801075e8:	e8 f4 a2 ff ff       	call   801018e1 <iupdate>
801075ed:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801075f0:	83 ec 0c             	sub    $0xc,%esp
801075f3:	ff 75 f0             	pushl  -0x10(%ebp)
801075f6:	e8 d0 a7 ff ff       	call   80101dcb <iunlockput>
801075fb:	83 c4 10             	add    $0x10,%esp

  end_op();
801075fe:	e8 19 c3 ff ff       	call   8010391c <end_op>

  return 0;
80107603:	b8 00 00 00 00       	mov    $0x0,%eax
80107608:	eb 19                	jmp    80107623 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010760a:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010760b:	83 ec 0c             	sub    $0xc,%esp
8010760e:	ff 75 f4             	pushl  -0xc(%ebp)
80107611:	e8 b5 a7 ff ff       	call   80101dcb <iunlockput>
80107616:	83 c4 10             	add    $0x10,%esp
  end_op();
80107619:	e8 fe c2 ff ff       	call   8010391c <end_op>
  return -1;
8010761e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107623:	c9                   	leave  
80107624:	c3                   	ret    

80107625 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80107625:	55                   	push   %ebp
80107626:	89 e5                	mov    %esp,%ebp
80107628:	83 ec 38             	sub    $0x38,%esp
8010762b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010762e:	8b 55 10             	mov    0x10(%ebp),%edx
80107631:	8b 45 14             	mov    0x14(%ebp),%eax
80107634:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80107638:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010763c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80107640:	83 ec 08             	sub    $0x8,%esp
80107643:	8d 45 de             	lea    -0x22(%ebp),%eax
80107646:	50                   	push   %eax
80107647:	ff 75 08             	pushl  0x8(%ebp)
8010764a:	e8 be b0 ff ff       	call   8010270d <nameiparent>
8010764f:	83 c4 10             	add    $0x10,%esp
80107652:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107659:	75 0a                	jne    80107665 <create+0x40>
    return 0;
8010765b:	b8 00 00 00 00       	mov    $0x0,%eax
80107660:	e9 90 01 00 00       	jmp    801077f5 <create+0x1d0>
  ilock(dp);
80107665:	83 ec 0c             	sub    $0xc,%esp
80107668:	ff 75 f4             	pushl  -0xc(%ebp)
8010766b:	e8 73 a4 ff ff       	call   80101ae3 <ilock>
80107670:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80107673:	83 ec 04             	sub    $0x4,%esp
80107676:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107679:	50                   	push   %eax
8010767a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010767d:	50                   	push   %eax
8010767e:	ff 75 f4             	pushl  -0xc(%ebp)
80107681:	e8 15 ad ff ff       	call   8010239b <dirlookup>
80107686:	83 c4 10             	add    $0x10,%esp
80107689:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010768c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107690:	74 50                	je     801076e2 <create+0xbd>
    iunlockput(dp);
80107692:	83 ec 0c             	sub    $0xc,%esp
80107695:	ff 75 f4             	pushl  -0xc(%ebp)
80107698:	e8 2e a7 ff ff       	call   80101dcb <iunlockput>
8010769d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801076a0:	83 ec 0c             	sub    $0xc,%esp
801076a3:	ff 75 f0             	pushl  -0x10(%ebp)
801076a6:	e8 38 a4 ff ff       	call   80101ae3 <ilock>
801076ab:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801076ae:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801076b3:	75 15                	jne    801076ca <create+0xa5>
801076b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801076bc:	66 83 f8 02          	cmp    $0x2,%ax
801076c0:	75 08                	jne    801076ca <create+0xa5>
      return ip;
801076c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076c5:	e9 2b 01 00 00       	jmp    801077f5 <create+0x1d0>
    iunlockput(ip);
801076ca:	83 ec 0c             	sub    $0xc,%esp
801076cd:	ff 75 f0             	pushl  -0x10(%ebp)
801076d0:	e8 f6 a6 ff ff       	call   80101dcb <iunlockput>
801076d5:	83 c4 10             	add    $0x10,%esp
    return 0;
801076d8:	b8 00 00 00 00       	mov    $0x0,%eax
801076dd:	e9 13 01 00 00       	jmp    801077f5 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801076e2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801076e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e9:	8b 00                	mov    (%eax),%eax
801076eb:	83 ec 08             	sub    $0x8,%esp
801076ee:	52                   	push   %edx
801076ef:	50                   	push   %eax
801076f0:	e8 f9 a0 ff ff       	call   801017ee <ialloc>
801076f5:	83 c4 10             	add    $0x10,%esp
801076f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076ff:	75 0d                	jne    8010770e <create+0xe9>
    panic("create: ialloc");
80107701:	83 ec 0c             	sub    $0xc,%esp
80107704:	68 e0 a6 10 80       	push   $0x8010a6e0
80107709:	e8 58 8e ff ff       	call   80100566 <panic>

  ilock(ip);
8010770e:	83 ec 0c             	sub    $0xc,%esp
80107711:	ff 75 f0             	pushl  -0x10(%ebp)
80107714:	e8 ca a3 ff ff       	call   80101ae3 <ilock>
80107719:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010771c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010771f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80107723:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80107727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010772a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010772e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80107732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107735:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010773b:	83 ec 0c             	sub    $0xc,%esp
8010773e:	ff 75 f0             	pushl  -0x10(%ebp)
80107741:	e8 9b a1 ff ff       	call   801018e1 <iupdate>
80107746:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80107749:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010774e:	75 6a                	jne    801077ba <create+0x195>
    dp->nlink++;  // for ".."
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107757:	83 c0 01             	add    $0x1,%eax
8010775a:	89 c2                	mov    %eax,%edx
8010775c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775f:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107763:	83 ec 0c             	sub    $0xc,%esp
80107766:	ff 75 f4             	pushl  -0xc(%ebp)
80107769:	e8 73 a1 ff ff       	call   801018e1 <iupdate>
8010776e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80107771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107774:	8b 40 04             	mov    0x4(%eax),%eax
80107777:	83 ec 04             	sub    $0x4,%esp
8010777a:	50                   	push   %eax
8010777b:	68 ba a6 10 80       	push   $0x8010a6ba
80107780:	ff 75 f0             	pushl  -0x10(%ebp)
80107783:	e8 cd ac ff ff       	call   80102455 <dirlink>
80107788:	83 c4 10             	add    $0x10,%esp
8010778b:	85 c0                	test   %eax,%eax
8010778d:	78 1e                	js     801077ad <create+0x188>
8010778f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107792:	8b 40 04             	mov    0x4(%eax),%eax
80107795:	83 ec 04             	sub    $0x4,%esp
80107798:	50                   	push   %eax
80107799:	68 bc a6 10 80       	push   $0x8010a6bc
8010779e:	ff 75 f0             	pushl  -0x10(%ebp)
801077a1:	e8 af ac ff ff       	call   80102455 <dirlink>
801077a6:	83 c4 10             	add    $0x10,%esp
801077a9:	85 c0                	test   %eax,%eax
801077ab:	79 0d                	jns    801077ba <create+0x195>
      panic("create dots");
801077ad:	83 ec 0c             	sub    $0xc,%esp
801077b0:	68 ef a6 10 80       	push   $0x8010a6ef
801077b5:	e8 ac 8d ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801077ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077bd:	8b 40 04             	mov    0x4(%eax),%eax
801077c0:	83 ec 04             	sub    $0x4,%esp
801077c3:	50                   	push   %eax
801077c4:	8d 45 de             	lea    -0x22(%ebp),%eax
801077c7:	50                   	push   %eax
801077c8:	ff 75 f4             	pushl  -0xc(%ebp)
801077cb:	e8 85 ac ff ff       	call   80102455 <dirlink>
801077d0:	83 c4 10             	add    $0x10,%esp
801077d3:	85 c0                	test   %eax,%eax
801077d5:	79 0d                	jns    801077e4 <create+0x1bf>
    panic("create: dirlink");
801077d7:	83 ec 0c             	sub    $0xc,%esp
801077da:	68 fb a6 10 80       	push   $0x8010a6fb
801077df:	e8 82 8d ff ff       	call   80100566 <panic>

  iunlockput(dp);
801077e4:	83 ec 0c             	sub    $0xc,%esp
801077e7:	ff 75 f4             	pushl  -0xc(%ebp)
801077ea:	e8 dc a5 ff ff       	call   80101dcb <iunlockput>
801077ef:	83 c4 10             	add    $0x10,%esp

  return ip;
801077f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801077f5:	c9                   	leave  
801077f6:	c3                   	ret    

801077f7 <sys_open>:

int
sys_open(void)
{
801077f7:	55                   	push   %ebp
801077f8:	89 e5                	mov    %esp,%ebp
801077fa:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801077fd:	83 ec 08             	sub    $0x8,%esp
80107800:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107803:	50                   	push   %eax
80107804:	6a 00                	push   $0x0
80107806:	e8 eb f6 ff ff       	call   80106ef6 <argstr>
8010780b:	83 c4 10             	add    $0x10,%esp
8010780e:	85 c0                	test   %eax,%eax
80107810:	78 15                	js     80107827 <sys_open+0x30>
80107812:	83 ec 08             	sub    $0x8,%esp
80107815:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107818:	50                   	push   %eax
80107819:	6a 01                	push   $0x1
8010781b:	e8 51 f6 ff ff       	call   80106e71 <argint>
80107820:	83 c4 10             	add    $0x10,%esp
80107823:	85 c0                	test   %eax,%eax
80107825:	79 0a                	jns    80107831 <sys_open+0x3a>
    return -1;
80107827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010782c:	e9 61 01 00 00       	jmp    80107992 <sys_open+0x19b>

  begin_op();
80107831:	e8 5a c0 ff ff       	call   80103890 <begin_op>

  if(omode & O_CREATE){
80107836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107839:	25 00 02 00 00       	and    $0x200,%eax
8010783e:	85 c0                	test   %eax,%eax
80107840:	74 2a                	je     8010786c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80107842:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107845:	6a 00                	push   $0x0
80107847:	6a 00                	push   $0x0
80107849:	6a 02                	push   $0x2
8010784b:	50                   	push   %eax
8010784c:	e8 d4 fd ff ff       	call   80107625 <create>
80107851:	83 c4 10             	add    $0x10,%esp
80107854:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80107857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010785b:	75 75                	jne    801078d2 <sys_open+0xdb>
      end_op();
8010785d:	e8 ba c0 ff ff       	call   8010391c <end_op>
      return -1;
80107862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107867:	e9 26 01 00 00       	jmp    80107992 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010786c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010786f:	83 ec 0c             	sub    $0xc,%esp
80107872:	50                   	push   %eax
80107873:	e8 79 ae ff ff       	call   801026f1 <namei>
80107878:	83 c4 10             	add    $0x10,%esp
8010787b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010787e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107882:	75 0f                	jne    80107893 <sys_open+0x9c>
      end_op();
80107884:	e8 93 c0 ff ff       	call   8010391c <end_op>
      return -1;
80107889:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010788e:	e9 ff 00 00 00       	jmp    80107992 <sys_open+0x19b>
    }
    ilock(ip);
80107893:	83 ec 0c             	sub    $0xc,%esp
80107896:	ff 75 f4             	pushl  -0xc(%ebp)
80107899:	e8 45 a2 ff ff       	call   80101ae3 <ilock>
8010789e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801078a8:	66 83 f8 01          	cmp    $0x1,%ax
801078ac:	75 24                	jne    801078d2 <sys_open+0xdb>
801078ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078b1:	85 c0                	test   %eax,%eax
801078b3:	74 1d                	je     801078d2 <sys_open+0xdb>
      iunlockput(ip);
801078b5:	83 ec 0c             	sub    $0xc,%esp
801078b8:	ff 75 f4             	pushl  -0xc(%ebp)
801078bb:	e8 0b a5 ff ff       	call   80101dcb <iunlockput>
801078c0:	83 c4 10             	add    $0x10,%esp
      end_op();
801078c3:	e8 54 c0 ff ff       	call   8010391c <end_op>
      return -1;
801078c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078cd:	e9 c0 00 00 00       	jmp    80107992 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801078d2:	e8 f1 97 ff ff       	call   801010c8 <filealloc>
801078d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078de:	74 17                	je     801078f7 <sys_open+0x100>
801078e0:	83 ec 0c             	sub    $0xc,%esp
801078e3:	ff 75 f0             	pushl  -0x10(%ebp)
801078e6:	e8 37 f7 ff ff       	call   80107022 <fdalloc>
801078eb:	83 c4 10             	add    $0x10,%esp
801078ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078f5:	79 2e                	jns    80107925 <sys_open+0x12e>
    if(f)
801078f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078fb:	74 0e                	je     8010790b <sys_open+0x114>
      fileclose(f);
801078fd:	83 ec 0c             	sub    $0xc,%esp
80107900:	ff 75 f0             	pushl  -0x10(%ebp)
80107903:	e8 7e 98 ff ff       	call   80101186 <fileclose>
80107908:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010790b:	83 ec 0c             	sub    $0xc,%esp
8010790e:	ff 75 f4             	pushl  -0xc(%ebp)
80107911:	e8 b5 a4 ff ff       	call   80101dcb <iunlockput>
80107916:	83 c4 10             	add    $0x10,%esp
    end_op();
80107919:	e8 fe bf ff ff       	call   8010391c <end_op>
    return -1;
8010791e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107923:	eb 6d                	jmp    80107992 <sys_open+0x19b>
  }
  iunlock(ip);
80107925:	83 ec 0c             	sub    $0xc,%esp
80107928:	ff 75 f4             	pushl  -0xc(%ebp)
8010792b:	e8 39 a3 ff ff       	call   80101c69 <iunlock>
80107930:	83 c4 10             	add    $0x10,%esp
  end_op();
80107933:	e8 e4 bf ff ff       	call   8010391c <end_op>

  f->type = FD_INODE;
80107938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010793b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80107941:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107944:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107947:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010794a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010794d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80107954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107957:	83 e0 01             	and    $0x1,%eax
8010795a:	85 c0                	test   %eax,%eax
8010795c:	0f 94 c0             	sete   %al
8010795f:	89 c2                	mov    %eax,%edx
80107961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107964:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010796a:	83 e0 01             	and    $0x1,%eax
8010796d:	85 c0                	test   %eax,%eax
8010796f:	75 0a                	jne    8010797b <sys_open+0x184>
80107971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107974:	83 e0 02             	and    $0x2,%eax
80107977:	85 c0                	test   %eax,%eax
80107979:	74 07                	je     80107982 <sys_open+0x18b>
8010797b:	b8 01 00 00 00       	mov    $0x1,%eax
80107980:	eb 05                	jmp    80107987 <sys_open+0x190>
80107982:	b8 00 00 00 00       	mov    $0x0,%eax
80107987:	89 c2                	mov    %eax,%edx
80107989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010798c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010798f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107992:	c9                   	leave  
80107993:	c3                   	ret    

80107994 <sys_mkdir>:

int
sys_mkdir(void)
{
80107994:	55                   	push   %ebp
80107995:	89 e5                	mov    %esp,%ebp
80107997:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010799a:	e8 f1 be ff ff       	call   80103890 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010799f:	83 ec 08             	sub    $0x8,%esp
801079a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801079a5:	50                   	push   %eax
801079a6:	6a 00                	push   $0x0
801079a8:	e8 49 f5 ff ff       	call   80106ef6 <argstr>
801079ad:	83 c4 10             	add    $0x10,%esp
801079b0:	85 c0                	test   %eax,%eax
801079b2:	78 1b                	js     801079cf <sys_mkdir+0x3b>
801079b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079b7:	6a 00                	push   $0x0
801079b9:	6a 00                	push   $0x0
801079bb:	6a 01                	push   $0x1
801079bd:	50                   	push   %eax
801079be:	e8 62 fc ff ff       	call   80107625 <create>
801079c3:	83 c4 10             	add    $0x10,%esp
801079c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079cd:	75 0c                	jne    801079db <sys_mkdir+0x47>
    end_op();
801079cf:	e8 48 bf ff ff       	call   8010391c <end_op>
    return -1;
801079d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079d9:	eb 18                	jmp    801079f3 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801079db:	83 ec 0c             	sub    $0xc,%esp
801079de:	ff 75 f4             	pushl  -0xc(%ebp)
801079e1:	e8 e5 a3 ff ff       	call   80101dcb <iunlockput>
801079e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801079e9:	e8 2e bf ff ff       	call   8010391c <end_op>
  return 0;
801079ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079f3:	c9                   	leave  
801079f4:	c3                   	ret    

801079f5 <sys_mknod>:

int
sys_mknod(void)
{
801079f5:	55                   	push   %ebp
801079f6:	89 e5                	mov    %esp,%ebp
801079f8:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801079fb:	e8 90 be ff ff       	call   80103890 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80107a00:	83 ec 08             	sub    $0x8,%esp
80107a03:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107a06:	50                   	push   %eax
80107a07:	6a 00                	push   $0x0
80107a09:	e8 e8 f4 ff ff       	call   80106ef6 <argstr>
80107a0e:	83 c4 10             	add    $0x10,%esp
80107a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a18:	78 4f                	js     80107a69 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107a1a:	83 ec 08             	sub    $0x8,%esp
80107a1d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107a20:	50                   	push   %eax
80107a21:	6a 01                	push   $0x1
80107a23:	e8 49 f4 ff ff       	call   80106e71 <argint>
80107a28:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107a2b:	85 c0                	test   %eax,%eax
80107a2d:	78 3a                	js     80107a69 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107a2f:	83 ec 08             	sub    $0x8,%esp
80107a32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107a35:	50                   	push   %eax
80107a36:	6a 02                	push   $0x2
80107a38:	e8 34 f4 ff ff       	call   80106e71 <argint>
80107a3d:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80107a40:	85 c0                	test   %eax,%eax
80107a42:	78 25                	js     80107a69 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80107a44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a47:	0f bf c8             	movswl %ax,%ecx
80107a4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a4d:	0f bf d0             	movswl %ax,%edx
80107a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107a53:	51                   	push   %ecx
80107a54:	52                   	push   %edx
80107a55:	6a 03                	push   $0x3
80107a57:	50                   	push   %eax
80107a58:	e8 c8 fb ff ff       	call   80107625 <create>
80107a5d:	83 c4 10             	add    $0x10,%esp
80107a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a67:	75 0c                	jne    80107a75 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107a69:	e8 ae be ff ff       	call   8010391c <end_op>
    return -1;
80107a6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a73:	eb 18                	jmp    80107a8d <sys_mknod+0x98>
  }
  iunlockput(ip);
80107a75:	83 ec 0c             	sub    $0xc,%esp
80107a78:	ff 75 f0             	pushl  -0x10(%ebp)
80107a7b:	e8 4b a3 ff ff       	call   80101dcb <iunlockput>
80107a80:	83 c4 10             	add    $0x10,%esp
  end_op();
80107a83:	e8 94 be ff ff       	call   8010391c <end_op>
  return 0;
80107a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a8d:	c9                   	leave  
80107a8e:	c3                   	ret    

80107a8f <sys_chdir>:

int
sys_chdir(void)
{
80107a8f:	55                   	push   %ebp
80107a90:	89 e5                	mov    %esp,%ebp
80107a92:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107a95:	e8 f6 bd ff ff       	call   80103890 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107a9a:	83 ec 08             	sub    $0x8,%esp
80107a9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107aa0:	50                   	push   %eax
80107aa1:	6a 00                	push   $0x0
80107aa3:	e8 4e f4 ff ff       	call   80106ef6 <argstr>
80107aa8:	83 c4 10             	add    $0x10,%esp
80107aab:	85 c0                	test   %eax,%eax
80107aad:	78 18                	js     80107ac7 <sys_chdir+0x38>
80107aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab2:	83 ec 0c             	sub    $0xc,%esp
80107ab5:	50                   	push   %eax
80107ab6:	e8 36 ac ff ff       	call   801026f1 <namei>
80107abb:	83 c4 10             	add    $0x10,%esp
80107abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ac1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ac5:	75 0c                	jne    80107ad3 <sys_chdir+0x44>
    end_op();
80107ac7:	e8 50 be ff ff       	call   8010391c <end_op>
    return -1;
80107acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ad1:	eb 6e                	jmp    80107b41 <sys_chdir+0xb2>
  }
  ilock(ip);
80107ad3:	83 ec 0c             	sub    $0xc,%esp
80107ad6:	ff 75 f4             	pushl  -0xc(%ebp)
80107ad9:	e8 05 a0 ff ff       	call   80101ae3 <ilock>
80107ade:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107ae8:	66 83 f8 01          	cmp    $0x1,%ax
80107aec:	74 1a                	je     80107b08 <sys_chdir+0x79>
    iunlockput(ip);
80107aee:	83 ec 0c             	sub    $0xc,%esp
80107af1:	ff 75 f4             	pushl  -0xc(%ebp)
80107af4:	e8 d2 a2 ff ff       	call   80101dcb <iunlockput>
80107af9:	83 c4 10             	add    $0x10,%esp
    end_op();
80107afc:	e8 1b be ff ff       	call   8010391c <end_op>
    return -1;
80107b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b06:	eb 39                	jmp    80107b41 <sys_chdir+0xb2>
  }
  iunlock(ip);
80107b08:	83 ec 0c             	sub    $0xc,%esp
80107b0b:	ff 75 f4             	pushl  -0xc(%ebp)
80107b0e:	e8 56 a1 ff ff       	call   80101c69 <iunlock>
80107b13:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107b16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b1c:	8b 40 68             	mov    0x68(%eax),%eax
80107b1f:	83 ec 0c             	sub    $0xc,%esp
80107b22:	50                   	push   %eax
80107b23:	e8 b3 a1 ff ff       	call   80101cdb <iput>
80107b28:	83 c4 10             	add    $0x10,%esp
  end_op();
80107b2b:	e8 ec bd ff ff       	call   8010391c <end_op>
  proc->cwd = ip;
80107b30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107b39:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b41:	c9                   	leave  
80107b42:	c3                   	ret    

80107b43 <sys_exec>:

int
sys_exec(void)
{
80107b43:	55                   	push   %ebp
80107b44:	89 e5                	mov    %esp,%ebp
80107b46:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107b4c:	83 ec 08             	sub    $0x8,%esp
80107b4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107b52:	50                   	push   %eax
80107b53:	6a 00                	push   $0x0
80107b55:	e8 9c f3 ff ff       	call   80106ef6 <argstr>
80107b5a:	83 c4 10             	add    $0x10,%esp
80107b5d:	85 c0                	test   %eax,%eax
80107b5f:	78 18                	js     80107b79 <sys_exec+0x36>
80107b61:	83 ec 08             	sub    $0x8,%esp
80107b64:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107b6a:	50                   	push   %eax
80107b6b:	6a 01                	push   $0x1
80107b6d:	e8 ff f2 ff ff       	call   80106e71 <argint>
80107b72:	83 c4 10             	add    $0x10,%esp
80107b75:	85 c0                	test   %eax,%eax
80107b77:	79 0a                	jns    80107b83 <sys_exec+0x40>
    return -1;
80107b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b7e:	e9 c6 00 00 00       	jmp    80107c49 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107b83:	83 ec 04             	sub    $0x4,%esp
80107b86:	68 80 00 00 00       	push   $0x80
80107b8b:	6a 00                	push   $0x0
80107b8d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107b93:	50                   	push   %eax
80107b94:	e8 b3 ef ff ff       	call   80106b4c <memset>
80107b99:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107b9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba6:	83 f8 1f             	cmp    $0x1f,%eax
80107ba9:	76 0a                	jbe    80107bb5 <sys_exec+0x72>
      return -1;
80107bab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bb0:	e9 94 00 00 00       	jmp    80107c49 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	c1 e0 02             	shl    $0x2,%eax
80107bbb:	89 c2                	mov    %eax,%edx
80107bbd:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107bc3:	01 c2                	add    %eax,%edx
80107bc5:	83 ec 08             	sub    $0x8,%esp
80107bc8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107bce:	50                   	push   %eax
80107bcf:	52                   	push   %edx
80107bd0:	e8 00 f2 ff ff       	call   80106dd5 <fetchint>
80107bd5:	83 c4 10             	add    $0x10,%esp
80107bd8:	85 c0                	test   %eax,%eax
80107bda:	79 07                	jns    80107be3 <sys_exec+0xa0>
      return -1;
80107bdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107be1:	eb 66                	jmp    80107c49 <sys_exec+0x106>
    if(uarg == 0){
80107be3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107be9:	85 c0                	test   %eax,%eax
80107beb:	75 27                	jne    80107c14 <sys_exec+0xd1>
      argv[i] = 0;
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107bf7:	00 00 00 00 
      break;
80107bfb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bff:	83 ec 08             	sub    $0x8,%esp
80107c02:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107c08:	52                   	push   %edx
80107c09:	50                   	push   %eax
80107c0a:	e8 00 90 ff ff       	call   80100c0f <exec>
80107c0f:	83 c4 10             	add    $0x10,%esp
80107c12:	eb 35                	jmp    80107c49 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107c14:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c1d:	c1 e2 02             	shl    $0x2,%edx
80107c20:	01 c2                	add    %eax,%edx
80107c22:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107c28:	83 ec 08             	sub    $0x8,%esp
80107c2b:	52                   	push   %edx
80107c2c:	50                   	push   %eax
80107c2d:	e8 dd f1 ff ff       	call   80106e0f <fetchstr>
80107c32:	83 c4 10             	add    $0x10,%esp
80107c35:	85 c0                	test   %eax,%eax
80107c37:	79 07                	jns    80107c40 <sys_exec+0xfd>
      return -1;
80107c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c3e:	eb 09                	jmp    80107c49 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107c40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107c44:	e9 5a ff ff ff       	jmp    80107ba3 <sys_exec+0x60>
  return exec(path, argv);
}
80107c49:	c9                   	leave  
80107c4a:	c3                   	ret    

80107c4b <sys_pipe>:

int
sys_pipe(void)
{
80107c4b:	55                   	push   %ebp
80107c4c:	89 e5                	mov    %esp,%ebp
80107c4e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107c51:	83 ec 04             	sub    $0x4,%esp
80107c54:	6a 08                	push   $0x8
80107c56:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107c59:	50                   	push   %eax
80107c5a:	6a 00                	push   $0x0
80107c5c:	e8 38 f2 ff ff       	call   80106e99 <argptr>
80107c61:	83 c4 10             	add    $0x10,%esp
80107c64:	85 c0                	test   %eax,%eax
80107c66:	79 0a                	jns    80107c72 <sys_pipe+0x27>
    return -1;
80107c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c6d:	e9 af 00 00 00       	jmp    80107d21 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107c72:	83 ec 08             	sub    $0x8,%esp
80107c75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107c78:	50                   	push   %eax
80107c79:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107c7c:	50                   	push   %eax
80107c7d:	e8 02 c7 ff ff       	call   80104384 <pipealloc>
80107c82:	83 c4 10             	add    $0x10,%esp
80107c85:	85 c0                	test   %eax,%eax
80107c87:	79 0a                	jns    80107c93 <sys_pipe+0x48>
    return -1;
80107c89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c8e:	e9 8e 00 00 00       	jmp    80107d21 <sys_pipe+0xd6>
  fd0 = -1;
80107c93:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c9d:	83 ec 0c             	sub    $0xc,%esp
80107ca0:	50                   	push   %eax
80107ca1:	e8 7c f3 ff ff       	call   80107022 <fdalloc>
80107ca6:	83 c4 10             	add    $0x10,%esp
80107ca9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cb0:	78 18                	js     80107cca <sys_pipe+0x7f>
80107cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107cb5:	83 ec 0c             	sub    $0xc,%esp
80107cb8:	50                   	push   %eax
80107cb9:	e8 64 f3 ff ff       	call   80107022 <fdalloc>
80107cbe:	83 c4 10             	add    $0x10,%esp
80107cc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cc8:	79 3f                	jns    80107d09 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107cca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cce:	78 14                	js     80107ce4 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107cd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cd9:	83 c2 08             	add    $0x8,%edx
80107cdc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107ce3:	00 
    fileclose(rf);
80107ce4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ce7:	83 ec 0c             	sub    $0xc,%esp
80107cea:	50                   	push   %eax
80107ceb:	e8 96 94 ff ff       	call   80101186 <fileclose>
80107cf0:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107cf6:	83 ec 0c             	sub    $0xc,%esp
80107cf9:	50                   	push   %eax
80107cfa:	e8 87 94 ff ff       	call   80101186 <fileclose>
80107cff:	83 c4 10             	add    $0x10,%esp
    return -1;
80107d02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d07:	eb 18                	jmp    80107d21 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d0f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d14:	8d 50 04             	lea    0x4(%eax),%edx
80107d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1a:	89 02                	mov    %eax,(%edx)
  return 0;
80107d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d21:	c9                   	leave  
80107d22:	c3                   	ret    

80107d23 <sys_chmod>:

#ifdef CS333_P5
int 
sys_chmod(void)
{
80107d23:	55                   	push   %ebp
80107d24:	89 e5                	mov    %esp,%ebp
80107d26:	83 ec 18             	sub    $0x18,%esp
    int number;
    char * str;

    if(argstr(0, &str) < 0)
80107d29:	83 ec 08             	sub    $0x8,%esp
80107d2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d2f:	50                   	push   %eax
80107d30:	6a 00                	push   $0x0
80107d32:	e8 bf f1 ff ff       	call   80106ef6 <argstr>
80107d37:	83 c4 10             	add    $0x10,%esp
80107d3a:	85 c0                	test   %eax,%eax
80107d3c:	79 07                	jns    80107d45 <sys_chmod+0x22>
        return -1;
80107d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d43:	eb 2f                	jmp    80107d74 <sys_chmod+0x51>
    if(argint(1,&number) <0)
80107d45:	83 ec 08             	sub    $0x8,%esp
80107d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107d4b:	50                   	push   %eax
80107d4c:	6a 01                	push   $0x1
80107d4e:	e8 1e f1 ff ff       	call   80106e71 <argint>
80107d53:	83 c4 10             	add    $0x10,%esp
80107d56:	85 c0                	test   %eax,%eax
80107d58:	79 07                	jns    80107d61 <sys_chmod+0x3e>
        return -1;
80107d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5f:	eb 13                	jmp    80107d74 <sys_chmod+0x51>
    return chmod(str,number);
80107d61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d67:	83 ec 08             	sub    $0x8,%esp
80107d6a:	52                   	push   %edx
80107d6b:	50                   	push   %eax
80107d6c:	e8 b7 a9 ff ff       	call   80102728 <chmod>
80107d71:	83 c4 10             	add    $0x10,%esp
}
80107d74:	c9                   	leave  
80107d75:	c3                   	ret    

80107d76 <sys_chown>:

int
sys_chown(void)
{
80107d76:	55                   	push   %ebp
80107d77:	89 e5                	mov    %esp,%ebp
80107d79:	83 ec 18             	sub    $0x18,%esp
    int number;
    char * str;
    if(argstr(0,&str) <0)
80107d7c:	83 ec 08             	sub    $0x8,%esp
80107d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107d82:	50                   	push   %eax
80107d83:	6a 00                	push   $0x0
80107d85:	e8 6c f1 ff ff       	call   80106ef6 <argstr>
80107d8a:	83 c4 10             	add    $0x10,%esp
80107d8d:	85 c0                	test   %eax,%eax
80107d8f:	79 07                	jns    80107d98 <sys_chown+0x22>
        return -1;
80107d91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d96:	eb 2f                	jmp    80107dc7 <sys_chown+0x51>
    if(argint(1,&number) <0)
80107d98:	83 ec 08             	sub    $0x8,%esp
80107d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107d9e:	50                   	push   %eax
80107d9f:	6a 01                	push   $0x1
80107da1:	e8 cb f0 ff ff       	call   80106e71 <argint>
80107da6:	83 c4 10             	add    $0x10,%esp
80107da9:	85 c0                	test   %eax,%eax
80107dab:	79 07                	jns    80107db4 <sys_chown+0x3e>
        return -1;
80107dad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107db2:	eb 13                	jmp    80107dc7 <sys_chown+0x51>
    return chown(str,number);
80107db4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dba:	83 ec 08             	sub    $0x8,%esp
80107dbd:	52                   	push   %edx
80107dbe:	50                   	push   %eax
80107dbf:	e8 e0 a9 ff ff       	call   801027a4 <chown>
80107dc4:	83 c4 10             	add    $0x10,%esp
}
80107dc7:	c9                   	leave  
80107dc8:	c3                   	ret    

80107dc9 <sys_chgrp>:
int
sys_chgrp(void)
{
80107dc9:	55                   	push   %ebp
80107dca:	89 e5                	mov    %esp,%ebp
80107dcc:	83 ec 18             	sub    $0x18,%esp
    int number;
    char * str;
    if(argstr(0,&str) <0)
80107dcf:	83 ec 08             	sub    $0x8,%esp
80107dd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107dd5:	50                   	push   %eax
80107dd6:	6a 00                	push   $0x0
80107dd8:	e8 19 f1 ff ff       	call   80106ef6 <argstr>
80107ddd:	83 c4 10             	add    $0x10,%esp
80107de0:	85 c0                	test   %eax,%eax
80107de2:	79 07                	jns    80107deb <sys_chgrp+0x22>
        return -1;
80107de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107de9:	eb 2f                	jmp    80107e1a <sys_chgrp+0x51>
    if(argint(1,&number) <0)
80107deb:	83 ec 08             	sub    $0x8,%esp
80107dee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107df1:	50                   	push   %eax
80107df2:	6a 01                	push   $0x1
80107df4:	e8 78 f0 ff ff       	call   80106e71 <argint>
80107df9:	83 c4 10             	add    $0x10,%esp
80107dfc:	85 c0                	test   %eax,%eax
80107dfe:	79 07                	jns    80107e07 <sys_chgrp+0x3e>
        return -1;
80107e00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e05:	eb 13                	jmp    80107e1a <sys_chgrp+0x51>
    return chgrp(str,number);
80107e07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0d:	83 ec 08             	sub    $0x8,%esp
80107e10:	52                   	push   %edx
80107e11:	50                   	push   %eax
80107e12:	e8 0c aa ff ff       	call   80102823 <chgrp>
80107e17:	83 c4 10             	add    $0x10,%esp
}
80107e1a:	c9                   	leave  
80107e1b:	c3                   	ret    

80107e1c <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107e1c:	55                   	push   %ebp
80107e1d:	89 e5                	mov    %esp,%ebp
80107e1f:	83 ec 08             	sub    $0x8,%esp
80107e22:	8b 55 08             	mov    0x8(%ebp),%edx
80107e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e28:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107e2c:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107e30:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107e34:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107e38:	66 ef                	out    %ax,(%dx)
}
80107e3a:	90                   	nop
80107e3b:	c9                   	leave  
80107e3c:	c3                   	ret    

80107e3d <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107e3d:	55                   	push   %ebp
80107e3e:	89 e5                	mov    %esp,%ebp
80107e40:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107e43:	e8 46 ce ff ff       	call   80104c8e <fork>
}
80107e48:	c9                   	leave  
80107e49:	c3                   	ret    

80107e4a <sys_exit>:

int
sys_exit(void)
{
80107e4a:	55                   	push   %ebp
80107e4b:	89 e5                	mov    %esp,%ebp
80107e4d:	83 ec 08             	sub    $0x8,%esp
  exit();
80107e50:	e8 84 d0 ff ff       	call   80104ed9 <exit>
  return 0;  // not reached
80107e55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e5a:	c9                   	leave  
80107e5b:	c3                   	ret    

80107e5c <sys_wait>:

int
sys_wait(void)
{
80107e5c:	55                   	push   %ebp
80107e5d:	89 e5                	mov    %esp,%ebp
80107e5f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107e62:	e8 5e d3 ff ff       	call   801051c5 <wait>
}
80107e67:	c9                   	leave  
80107e68:	c3                   	ret    

80107e69 <sys_kill>:

int
sys_kill(void)
{
80107e69:	55                   	push   %ebp
80107e6a:	89 e5                	mov    %esp,%ebp
80107e6c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107e6f:	83 ec 08             	sub    $0x8,%esp
80107e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107e75:	50                   	push   %eax
80107e76:	6a 00                	push   $0x0
80107e78:	e8 f4 ef ff ff       	call   80106e71 <argint>
80107e7d:	83 c4 10             	add    $0x10,%esp
80107e80:	85 c0                	test   %eax,%eax
80107e82:	79 07                	jns    80107e8b <sys_kill+0x22>
    return -1;
80107e84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e89:	eb 0f                	jmp    80107e9a <sys_kill+0x31>
  return kill(pid);
80107e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8e:	83 ec 0c             	sub    $0xc,%esp
80107e91:	50                   	push   %eax
80107e92:	e8 15 dc ff ff       	call   80105aac <kill>
80107e97:	83 c4 10             	add    $0x10,%esp
}
80107e9a:	c9                   	leave  
80107e9b:	c3                   	ret    

80107e9c <sys_getpid>:

int
sys_getpid(void)
{
80107e9c:	55                   	push   %ebp
80107e9d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ea5:	8b 40 10             	mov    0x10(%eax),%eax
}
80107ea8:	5d                   	pop    %ebp
80107ea9:	c3                   	ret    

80107eaa <sys_sbrk>:

int
sys_sbrk(void)
{
80107eaa:	55                   	push   %ebp
80107eab:	89 e5                	mov    %esp,%ebp
80107ead:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107eb0:	83 ec 08             	sub    $0x8,%esp
80107eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107eb6:	50                   	push   %eax
80107eb7:	6a 00                	push   $0x0
80107eb9:	e8 b3 ef ff ff       	call   80106e71 <argint>
80107ebe:	83 c4 10             	add    $0x10,%esp
80107ec1:	85 c0                	test   %eax,%eax
80107ec3:	79 07                	jns    80107ecc <sys_sbrk+0x22>
    return -1;
80107ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eca:	eb 28                	jmp    80107ef4 <sys_sbrk+0x4a>
  addr = proc->sz;
80107ecc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ed2:	8b 00                	mov    (%eax),%eax
80107ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eda:	83 ec 0c             	sub    $0xc,%esp
80107edd:	50                   	push   %eax
80107ede:	e8 08 cd ff ff       	call   80104beb <growproc>
80107ee3:	83 c4 10             	add    $0x10,%esp
80107ee6:	85 c0                	test   %eax,%eax
80107ee8:	79 07                	jns    80107ef1 <sys_sbrk+0x47>
    return -1;
80107eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eef:	eb 03                	jmp    80107ef4 <sys_sbrk+0x4a>
  return addr;
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107ef4:	c9                   	leave  
80107ef5:	c3                   	ret    

80107ef6 <sys_sleep>:

int
sys_sleep(void)
{
80107ef6:	55                   	push   %ebp
80107ef7:	89 e5                	mov    %esp,%ebp
80107ef9:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107efc:	83 ec 08             	sub    $0x8,%esp
80107eff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f02:	50                   	push   %eax
80107f03:	6a 00                	push   $0x0
80107f05:	e8 67 ef ff ff       	call   80106e71 <argint>
80107f0a:	83 c4 10             	add    $0x10,%esp
80107f0d:	85 c0                	test   %eax,%eax
80107f0f:	79 07                	jns    80107f18 <sys_sleep+0x22>
    return -1;
80107f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f16:	eb 44                	jmp    80107f5c <sys_sleep+0x66>
  ticks0 = ticks;
80107f18:	a1 20 79 11 80       	mov    0x80117920,%eax
80107f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107f20:	eb 26                	jmp    80107f48 <sys_sleep+0x52>
    if(proc->killed){
80107f22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f28:	8b 40 24             	mov    0x24(%eax),%eax
80107f2b:	85 c0                	test   %eax,%eax
80107f2d:	74 07                	je     80107f36 <sys_sleep+0x40>
      return -1;
80107f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f34:	eb 26                	jmp    80107f5c <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107f36:	83 ec 08             	sub    $0x8,%esp
80107f39:	6a 00                	push   $0x0
80107f3b:	68 20 79 11 80       	push   $0x80117920
80107f40:	e8 0c d9 ff ff       	call   80105851 <sleep>
80107f45:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107f48:	a1 20 79 11 80       	mov    0x80117920,%eax
80107f4d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f50:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107f53:	39 d0                	cmp    %edx,%eax
80107f55:	72 cb                	jb     80107f22 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107f57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f5c:	c9                   	leave  
80107f5d:	c3                   	ret    

80107f5e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
80107f5e:	55                   	push   %ebp
80107f5f:	89 e5                	mov    %esp,%ebp
80107f61:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
80107f64:	a1 20 79 11 80       	mov    0x80117920,%eax
80107f69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80107f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107f6f:	c9                   	leave  
80107f70:	c3                   	ret    

80107f71 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107f71:	55                   	push   %ebp
80107f72:	89 e5                	mov    %esp,%ebp
80107f74:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107f77:	83 ec 0c             	sub    $0xc,%esp
80107f7a:	68 0b a7 10 80       	push   $0x8010a70b
80107f7f:	e8 42 84 ff ff       	call   801003c6 <cprintf>
80107f84:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107f87:	83 ec 08             	sub    $0x8,%esp
80107f8a:	68 00 20 00 00       	push   $0x2000
80107f8f:	68 04 06 00 00       	push   $0x604
80107f94:	e8 83 fe ff ff       	call   80107e1c <outw>
80107f99:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fa1:	c9                   	leave  
80107fa2:	c3                   	ret    

80107fa3 <sys_date>:
#ifdef CS333_P1
int
sys_date(void){
80107fa3:	55                   	push   %ebp
80107fa4:	89 e5                	mov    %esp,%ebp
80107fa6:	83 ec 18             	sub    $0x18,%esp
    struct rtcdate *d;
    if(argptr(0,(void*)&d,sizeof(struct rtcdate))<0)
80107fa9:	83 ec 04             	sub    $0x4,%esp
80107fac:	6a 18                	push   $0x18
80107fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107fb1:	50                   	push   %eax
80107fb2:	6a 00                	push   $0x0
80107fb4:	e8 e0 ee ff ff       	call   80106e99 <argptr>
80107fb9:	83 c4 10             	add    $0x10,%esp
80107fbc:	85 c0                	test   %eax,%eax
80107fbe:	79 07                	jns    80107fc7 <sys_date+0x24>
        return -1;
80107fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fc5:	eb 14                	jmp    80107fdb <sys_date+0x38>
    cmostime(d);
80107fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fca:	83 ec 0c             	sub    $0xc,%esp
80107fcd:	50                   	push   %eax
80107fce:	e8 38 b5 ff ff       	call   8010350b <cmostime>
80107fd3:	83 c4 10             	add    $0x10,%esp
        return 0;
80107fd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fdb:	c9                   	leave  
80107fdc:	c3                   	ret    

80107fdd <sys_getuid>:
#endif

#ifdef  CS333_P2
uint
sys_getuid(void){
80107fdd:	55                   	push   %ebp
80107fde:	89 e5                	mov    %esp,%ebp
        return proc->uid;
80107fe0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107fe6:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80107fec:	5d                   	pop    %ebp
80107fed:	c3                   	ret    

80107fee <sys_getgid>:
uint
sys_getgid(void)
{
80107fee:	55                   	push   %ebp
80107fef:	89 e5                	mov    %esp,%ebp
        return proc->gid;
80107ff1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ff7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80107ffd:	5d                   	pop    %ebp
80107ffe:	c3                   	ret    

80107fff <sys_getppid>:
uint
sys_getppid(void){
80107fff:	55                   	push   %ebp
80108000:	89 e5                	mov    %esp,%ebp
    if(proc->parent == 0)
80108002:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108008:	8b 40 14             	mov    0x14(%eax),%eax
8010800b:	85 c0                	test   %eax,%eax
8010800d:	75 0b                	jne    8010801a <sys_getppid+0x1b>
        return proc->pid;
8010800f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108015:	8b 40 10             	mov    0x10(%eax),%eax
80108018:	eb 0c                	jmp    80108026 <sys_getppid+0x27>

    return proc->parent->pid;
8010801a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108020:	8b 40 14             	mov    0x14(%eax),%eax
80108023:	8b 40 10             	mov    0x10(%eax),%eax
}
80108026:	5d                   	pop    %ebp
80108027:	c3                   	ret    

80108028 <sys_setuid>:

int 
sys_setuid(void){
80108028:	55                   	push   %ebp
80108029:	89 e5                	mov    %esp,%ebp
8010802b:	83 ec 18             	sub    $0x18,%esp
    int uid;
    if(argint(0,&uid) < 0){
8010802e:	83 ec 08             	sub    $0x8,%esp
80108031:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108034:	50                   	push   %eax
80108035:	6a 00                	push   $0x0
80108037:	e8 35 ee ff ff       	call   80106e71 <argint>
8010803c:	83 c4 10             	add    $0x10,%esp
8010803f:	85 c0                	test   %eax,%eax
80108041:	79 07                	jns    8010804a <sys_setuid+0x22>
        return -1; // return fali
80108043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108048:	eb 2c                	jmp    80108076 <sys_setuid+0x4e>
    }
    if(uid < 0 || uid > 32767)//check if in range 
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	85 c0                	test   %eax,%eax
8010804f:	78 0a                	js     8010805b <sys_setuid+0x33>
80108051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108054:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108059:	7e 07                	jle    80108062 <sys_setuid+0x3a>
        return -1;
8010805b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108060:	eb 14                	jmp    80108076 <sys_setuid+0x4e>
        proc->uid = uid;
80108062:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108068:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010806b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        return 0; // return success 
80108071:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108076:	c9                   	leave  
80108077:	c3                   	ret    

80108078 <sys_setgid>:
int sys_setgid(void){
80108078:	55                   	push   %ebp
80108079:	89 e5                	mov    %esp,%ebp
8010807b:	83 ec 18             	sub    $0x18,%esp
    int gid;
    if(argint(0,&gid)  < 0){
8010807e:	83 ec 08             	sub    $0x8,%esp
80108081:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108084:	50                   	push   %eax
80108085:	6a 00                	push   $0x0
80108087:	e8 e5 ed ff ff       	call   80106e71 <argint>
8010808c:	83 c4 10             	add    $0x10,%esp
8010808f:	85 c0                	test   %eax,%eax
80108091:	79 07                	jns    8010809a <sys_setgid+0x22>
       return -1; // return fail
80108093:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108098:	eb 2c                	jmp    801080c6 <sys_setgid+0x4e>
    }
    if(gid < 0 || gid > 32767) // check if in range 
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	85 c0                	test   %eax,%eax
8010809f:	78 0a                	js     801080ab <sys_setgid+0x33>
801080a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a4:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801080a9:	7e 07                	jle    801080b2 <sys_setgid+0x3a>
         return -1; // return fail 
801080ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080b0:	eb 14                	jmp    801080c6 <sys_setgid+0x4e>
    proc->gid = gid;
801080b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801080b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080bb:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0; // success 
801080c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080c6:	c9                   	leave  
801080c7:	c3                   	ret    

801080c8 <sys_getprocs>:

int getprocs(uint, struct uproc *);
int
sys_getprocs(void){
801080c8:	55                   	push   %ebp
801080c9:	89 e5                	mov    %esp,%ebp
801080cb:	83 ec 18             	sub    $0x18,%esp

    int max;
    struct uproc * table;

        if(argint (0, &max) < 0)
801080ce:	83 ec 08             	sub    $0x8,%esp
801080d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801080d4:	50                   	push   %eax
801080d5:	6a 00                	push   $0x0
801080d7:	e8 95 ed ff ff       	call   80106e71 <argint>
801080dc:	83 c4 10             	add    $0x10,%esp
801080df:	85 c0                	test   %eax,%eax
801080e1:	79 07                	jns    801080ea <sys_getprocs+0x22>
            return -1;
801080e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080e8:	eb 3e                	jmp    80108128 <sys_getprocs+0x60>
        if(argptr(1, (void*) & table, sizeof( struct uproc) * max) <0)
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	89 c2                	mov    %eax,%edx
801080ef:	89 d0                	mov    %edx,%eax
801080f1:	01 c0                	add    %eax,%eax
801080f3:	01 d0                	add    %edx,%eax
801080f5:	c1 e0 05             	shl    $0x5,%eax
801080f8:	83 ec 04             	sub    $0x4,%esp
801080fb:	50                   	push   %eax
801080fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801080ff:	50                   	push   %eax
80108100:	6a 01                	push   $0x1
80108102:	e8 92 ed ff ff       	call   80106e99 <argptr>
80108107:	83 c4 10             	add    $0x10,%esp
8010810a:	85 c0                	test   %eax,%eax
8010810c:	79 07                	jns    80108115 <sys_getprocs+0x4d>
            return -1;
8010810e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108113:	eb 13                	jmp    80108128 <sys_getprocs+0x60>

        return getprocs(max, table);
80108115:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108118:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010811b:	83 ec 08             	sub    $0x8,%esp
8010811e:	50                   	push   %eax
8010811f:	52                   	push   %edx
80108120:	e8 00 de ff ff       	call   80105f25 <getprocs>
80108125:	83 c4 10             	add    $0x10,%esp
}
80108128:	c9                   	leave  
80108129:	c3                   	ret    

8010812a <sys_setpriority>:
#endif

#ifdef CS333_P3P4 //4
int
sys_setpriority(void)
{
8010812a:	55                   	push   %ebp
8010812b:	89 e5                	mov    %esp,%ebp
8010812d:	83 ec 18             	sub    $0x18,%esp
    int pid;
    int priority;
    
    if(argint(0,&pid) < 0)
80108130:	83 ec 08             	sub    $0x8,%esp
80108133:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108136:	50                   	push   %eax
80108137:	6a 00                	push   $0x0
80108139:	e8 33 ed ff ff       	call   80106e71 <argint>
8010813e:	83 c4 10             	add    $0x10,%esp
80108141:	85 c0                	test   %eax,%eax
80108143:	79 07                	jns    8010814c <sys_setpriority+0x22>
        return -1;
80108145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010814a:	eb 2f                	jmp    8010817b <sys_setpriority+0x51>
    if(argint (1,&priority) <0)
8010814c:	83 ec 08             	sub    $0x8,%esp
8010814f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108152:	50                   	push   %eax
80108153:	6a 01                	push   $0x1
80108155:	e8 17 ed ff ff       	call   80106e71 <argint>
8010815a:	83 c4 10             	add    $0x10,%esp
8010815d:	85 c0                	test   %eax,%eax
8010815f:	79 07                	jns    80108168 <sys_setpriority+0x3e>
        return -1;
80108161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108166:	eb 13                	jmp    8010817b <sys_setpriority+0x51>
    return setpriority(pid,priority);
80108168:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010816b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816e:	83 ec 08             	sub    $0x8,%esp
80108171:	52                   	push   %edx
80108172:	50                   	push   %eax
80108173:	e8 ad e4 ff ff       	call   80106625 <setpriority>
80108178:	83 c4 10             	add    $0x10,%esp
}
8010817b:	c9                   	leave  
8010817c:	c3                   	ret    

8010817d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010817d:	55                   	push   %ebp
8010817e:	89 e5                	mov    %esp,%ebp
80108180:	83 ec 08             	sub    $0x8,%esp
80108183:	8b 55 08             	mov    0x8(%ebp),%edx
80108186:	8b 45 0c             	mov    0xc(%ebp),%eax
80108189:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010818d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108190:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108194:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108198:	ee                   	out    %al,(%dx)
}
80108199:	90                   	nop
8010819a:	c9                   	leave  
8010819b:	c3                   	ret    

8010819c <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010819c:	55                   	push   %ebp
8010819d:	89 e5                	mov    %esp,%ebp
8010819f:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801081a2:	6a 34                	push   $0x34
801081a4:	6a 43                	push   $0x43
801081a6:	e8 d2 ff ff ff       	call   8010817d <outb>
801081ab:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
801081ae:	68 a9 00 00 00       	push   $0xa9
801081b3:	6a 40                	push   $0x40
801081b5:	e8 c3 ff ff ff       	call   8010817d <outb>
801081ba:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
801081bd:	6a 04                	push   $0x4
801081bf:	6a 40                	push   $0x40
801081c1:	e8 b7 ff ff ff       	call   8010817d <outb>
801081c6:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801081c9:	83 ec 0c             	sub    $0xc,%esp
801081cc:	6a 00                	push   $0x0
801081ce:	e8 9b c0 ff ff       	call   8010426e <picenable>
801081d3:	83 c4 10             	add    $0x10,%esp
}
801081d6:	90                   	nop
801081d7:	c9                   	leave  
801081d8:	c3                   	ret    

801081d9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801081d9:	1e                   	push   %ds
  pushl %es
801081da:	06                   	push   %es
  pushl %fs
801081db:	0f a0                	push   %fs
  pushl %gs
801081dd:	0f a8                	push   %gs
  pushal
801081df:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801081e0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801081e4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801081e6:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801081e8:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801081ec:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801081ee:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801081f0:	54                   	push   %esp
  call trap
801081f1:	e8 ce 01 00 00       	call   801083c4 <trap>
  addl $4, %esp
801081f6:	83 c4 04             	add    $0x4,%esp

801081f9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801081f9:	61                   	popa   
  popl %gs
801081fa:	0f a9                	pop    %gs
  popl %fs
801081fc:	0f a1                	pop    %fs
  popl %es
801081fe:	07                   	pop    %es
  popl %ds
801081ff:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80108200:	83 c4 08             	add    $0x8,%esp
  iret
80108203:	cf                   	iret   

80108204 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80108204:	55                   	push   %ebp
80108205:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108207:	8b 45 08             	mov    0x8(%ebp),%eax
8010820a:	f0 ff 00             	lock incl (%eax)
}
8010820d:	90                   	nop
8010820e:	5d                   	pop    %ebp
8010820f:	c3                   	ret    

80108210 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80108210:	55                   	push   %ebp
80108211:	89 e5                	mov    %esp,%ebp
80108213:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108216:	8b 45 0c             	mov    0xc(%ebp),%eax
80108219:	83 e8 01             	sub    $0x1,%eax
8010821c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108220:	8b 45 08             	mov    0x8(%ebp),%eax
80108223:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108227:	8b 45 08             	mov    0x8(%ebp),%eax
8010822a:	c1 e8 10             	shr    $0x10,%eax
8010822d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80108231:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108234:	0f 01 18             	lidtl  (%eax)
}
80108237:	90                   	nop
80108238:	c9                   	leave  
80108239:	c3                   	ret    

8010823a <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010823a:	55                   	push   %ebp
8010823b:	89 e5                	mov    %esp,%ebp
8010823d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80108240:	0f 20 d0             	mov    %cr2,%eax
80108243:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80108246:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108249:	c9                   	leave  
8010824a:	c3                   	ret    

8010824b <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
8010824b:	55                   	push   %ebp
8010824c:	89 e5                	mov    %esp,%ebp
8010824e:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
80108251:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108258:	e9 c3 00 00 00       	jmp    80108320 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010825d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108260:	8b 04 85 c8 d0 10 80 	mov    -0x7fef2f38(,%eax,4),%eax
80108267:	89 c2                	mov    %eax,%edx
80108269:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010826c:	66 89 14 c5 20 71 11 	mov    %dx,-0x7fee8ee0(,%eax,8)
80108273:	80 
80108274:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108277:	66 c7 04 c5 22 71 11 	movw   $0x8,-0x7fee8ede(,%eax,8)
8010827e:	80 08 00 
80108281:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108284:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
8010828b:	80 
8010828c:	83 e2 e0             	and    $0xffffffe0,%edx
8010828f:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
80108296:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108299:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801082a0:	80 
801082a1:	83 e2 1f             	and    $0x1f,%edx
801082a4:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
801082ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082ae:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
801082b5:	80 
801082b6:	83 e2 f0             	and    $0xfffffff0,%edx
801082b9:	83 ca 0e             	or     $0xe,%edx
801082bc:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
801082c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082c6:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
801082cd:	80 
801082ce:	83 e2 ef             	and    $0xffffffef,%edx
801082d1:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
801082d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082db:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
801082e2:	80 
801082e3:	83 e2 9f             	and    $0xffffff9f,%edx
801082e6:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
801082ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082f0:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
801082f7:	80 
801082f8:	83 ca 80             	or     $0xffffff80,%edx
801082fb:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108302:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108305:	8b 04 85 c8 d0 10 80 	mov    -0x7fef2f38(,%eax,4),%eax
8010830c:	c1 e8 10             	shr    $0x10,%eax
8010830f:	89 c2                	mov    %eax,%edx
80108311:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108314:	66 89 14 c5 26 71 11 	mov    %dx,-0x7fee8eda(,%eax,8)
8010831b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010831c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80108320:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108327:	0f 8e 30 ff ff ff    	jle    8010825d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010832d:	a1 c8 d1 10 80       	mov    0x8010d1c8,%eax
80108332:	66 a3 20 73 11 80    	mov    %ax,0x80117320
80108338:	66 c7 05 22 73 11 80 	movw   $0x8,0x80117322
8010833f:	08 00 
80108341:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
80108348:	83 e0 e0             	and    $0xffffffe0,%eax
8010834b:	a2 24 73 11 80       	mov    %al,0x80117324
80108350:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
80108357:	83 e0 1f             	and    $0x1f,%eax
8010835a:	a2 24 73 11 80       	mov    %al,0x80117324
8010835f:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
80108366:	83 c8 0f             	or     $0xf,%eax
80108369:	a2 25 73 11 80       	mov    %al,0x80117325
8010836e:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
80108375:	83 e0 ef             	and    $0xffffffef,%eax
80108378:	a2 25 73 11 80       	mov    %al,0x80117325
8010837d:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
80108384:	83 c8 60             	or     $0x60,%eax
80108387:	a2 25 73 11 80       	mov    %al,0x80117325
8010838c:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
80108393:	83 c8 80             	or     $0xffffff80,%eax
80108396:	a2 25 73 11 80       	mov    %al,0x80117325
8010839b:	a1 c8 d1 10 80       	mov    0x8010d1c8,%eax
801083a0:	c1 e8 10             	shr    $0x10,%eax
801083a3:	66 a3 26 73 11 80    	mov    %ax,0x80117326
  
}
801083a9:	90                   	nop
801083aa:	c9                   	leave  
801083ab:	c3                   	ret    

801083ac <idtinit>:

void
idtinit(void)
{
801083ac:	55                   	push   %ebp
801083ad:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801083af:	68 00 08 00 00       	push   $0x800
801083b4:	68 20 71 11 80       	push   $0x80117120
801083b9:	e8 52 fe ff ff       	call   80108210 <lidt>
801083be:	83 c4 08             	add    $0x8,%esp
}
801083c1:	90                   	nop
801083c2:	c9                   	leave  
801083c3:	c3                   	ret    

801083c4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801083c4:	55                   	push   %ebp
801083c5:	89 e5                	mov    %esp,%ebp
801083c7:	57                   	push   %edi
801083c8:	56                   	push   %esi
801083c9:	53                   	push   %ebx
801083ca:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801083cd:	8b 45 08             	mov    0x8(%ebp),%eax
801083d0:	8b 40 30             	mov    0x30(%eax),%eax
801083d3:	83 f8 40             	cmp    $0x40,%eax
801083d6:	75 3e                	jne    80108416 <trap+0x52>
    if(proc->killed)
801083d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083de:	8b 40 24             	mov    0x24(%eax),%eax
801083e1:	85 c0                	test   %eax,%eax
801083e3:	74 05                	je     801083ea <trap+0x26>
      exit();
801083e5:	e8 ef ca ff ff       	call   80104ed9 <exit>
    proc->tf = tf;
801083ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801083f0:	8b 55 08             	mov    0x8(%ebp),%edx
801083f3:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801083f6:	e8 2c eb ff ff       	call   80106f27 <syscall>
    if(proc->killed)
801083fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108401:	8b 40 24             	mov    0x24(%eax),%eax
80108404:	85 c0                	test   %eax,%eax
80108406:	0f 84 21 02 00 00    	je     8010862d <trap+0x269>
      exit();
8010840c:	e8 c8 ca ff ff       	call   80104ed9 <exit>
    return;
80108411:	e9 17 02 00 00       	jmp    8010862d <trap+0x269>
  }

  switch(tf->trapno){
80108416:	8b 45 08             	mov    0x8(%ebp),%eax
80108419:	8b 40 30             	mov    0x30(%eax),%eax
8010841c:	83 e8 20             	sub    $0x20,%eax
8010841f:	83 f8 1f             	cmp    $0x1f,%eax
80108422:	0f 87 a3 00 00 00    	ja     801084cb <trap+0x107>
80108428:	8b 04 85 c0 a7 10 80 	mov    -0x7fef5840(,%eax,4),%eax
8010842f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80108431:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108437:	0f b6 00             	movzbl (%eax),%eax
8010843a:	84 c0                	test   %al,%al
8010843c:	75 20                	jne    8010845e <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010843e:	83 ec 0c             	sub    $0xc,%esp
80108441:	68 20 79 11 80       	push   $0x80117920
80108446:	e8 b9 fd ff ff       	call   80108204 <atom_inc>
8010844b:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
8010844e:	83 ec 0c             	sub    $0xc,%esp
80108451:	68 20 79 11 80       	push   $0x80117920
80108456:	e8 1a d6 ff ff       	call   80105a75 <wakeup>
8010845b:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010845e:	e8 05 af ff ff       	call   80103368 <lapiceoi>
    break;
80108463:	e9 1c 01 00 00       	jmp    80108584 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80108468:	e8 0e a7 ff ff       	call   80102b7b <ideintr>
    lapiceoi();
8010846d:	e8 f6 ae ff ff       	call   80103368 <lapiceoi>
    break;
80108472:	e9 0d 01 00 00       	jmp    80108584 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80108477:	e8 ee ac ff ff       	call   8010316a <kbdintr>
    lapiceoi();
8010847c:	e8 e7 ae ff ff       	call   80103368 <lapiceoi>
    break;
80108481:	e9 fe 00 00 00       	jmp    80108584 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80108486:	e8 83 03 00 00       	call   8010880e <uartintr>
    lapiceoi();
8010848b:	e8 d8 ae ff ff       	call   80103368 <lapiceoi>
    break;
80108490:	e9 ef 00 00 00       	jmp    80108584 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80108495:	8b 45 08             	mov    0x8(%ebp),%eax
80108498:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010849b:	8b 45 08             	mov    0x8(%ebp),%eax
8010849e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801084a2:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801084a5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084ab:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801084ae:	0f b6 c0             	movzbl %al,%eax
801084b1:	51                   	push   %ecx
801084b2:	52                   	push   %edx
801084b3:	50                   	push   %eax
801084b4:	68 20 a7 10 80       	push   $0x8010a720
801084b9:	e8 08 7f ff ff       	call   801003c6 <cprintf>
801084be:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801084c1:	e8 a2 ae ff ff       	call   80103368 <lapiceoi>
    break;
801084c6:	e9 b9 00 00 00       	jmp    80108584 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801084cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801084d1:	85 c0                	test   %eax,%eax
801084d3:	74 11                	je     801084e6 <trap+0x122>
801084d5:	8b 45 08             	mov    0x8(%ebp),%eax
801084d8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801084dc:	0f b7 c0             	movzwl %ax,%eax
801084df:	83 e0 03             	and    $0x3,%eax
801084e2:	85 c0                	test   %eax,%eax
801084e4:	75 40                	jne    80108526 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801084e6:	e8 4f fd ff ff       	call   8010823a <rcr2>
801084eb:	89 c3                	mov    %eax,%ebx
801084ed:	8b 45 08             	mov    0x8(%ebp),%eax
801084f0:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801084f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084f9:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801084fc:	0f b6 d0             	movzbl %al,%edx
801084ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108502:	8b 40 30             	mov    0x30(%eax),%eax
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	53                   	push   %ebx
80108509:	51                   	push   %ecx
8010850a:	52                   	push   %edx
8010850b:	50                   	push   %eax
8010850c:	68 44 a7 10 80       	push   $0x8010a744
80108511:	e8 b0 7e ff ff       	call   801003c6 <cprintf>
80108516:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80108519:	83 ec 0c             	sub    $0xc,%esp
8010851c:	68 76 a7 10 80       	push   $0x8010a776
80108521:	e8 40 80 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108526:	e8 0f fd ff ff       	call   8010823a <rcr2>
8010852b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010852e:	8b 45 08             	mov    0x8(%ebp),%eax
80108531:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108534:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010853a:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010853d:	0f b6 d8             	movzbl %al,%ebx
80108540:	8b 45 08             	mov    0x8(%ebp),%eax
80108543:	8b 48 34             	mov    0x34(%eax),%ecx
80108546:	8b 45 08             	mov    0x8(%ebp),%eax
80108549:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010854c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108552:	8d 78 6c             	lea    0x6c(%eax),%edi
80108555:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010855b:	8b 40 10             	mov    0x10(%eax),%eax
8010855e:	ff 75 e4             	pushl  -0x1c(%ebp)
80108561:	56                   	push   %esi
80108562:	53                   	push   %ebx
80108563:	51                   	push   %ecx
80108564:	52                   	push   %edx
80108565:	57                   	push   %edi
80108566:	50                   	push   %eax
80108567:	68 7c a7 10 80       	push   $0x8010a77c
8010856c:	e8 55 7e ff ff       	call   801003c6 <cprintf>
80108571:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80108574:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010857a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80108581:	eb 01                	jmp    80108584 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80108583:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80108584:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010858a:	85 c0                	test   %eax,%eax
8010858c:	74 24                	je     801085b2 <trap+0x1ee>
8010858e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108594:	8b 40 24             	mov    0x24(%eax),%eax
80108597:	85 c0                	test   %eax,%eax
80108599:	74 17                	je     801085b2 <trap+0x1ee>
8010859b:	8b 45 08             	mov    0x8(%ebp),%eax
8010859e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801085a2:	0f b7 c0             	movzwl %ax,%eax
801085a5:	83 e0 03             	and    $0x3,%eax
801085a8:	83 f8 03             	cmp    $0x3,%eax
801085ab:	75 05                	jne    801085b2 <trap+0x1ee>
    exit();
801085ad:	e8 27 c9 ff ff       	call   80104ed9 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801085b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085b8:	85 c0                	test   %eax,%eax
801085ba:	74 41                	je     801085fd <trap+0x239>
801085bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801085c2:	8b 40 0c             	mov    0xc(%eax),%eax
801085c5:	83 f8 04             	cmp    $0x4,%eax
801085c8:	75 33                	jne    801085fd <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801085ca:	8b 45 08             	mov    0x8(%ebp),%eax
801085cd:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
801085d0:	83 f8 20             	cmp    $0x20,%eax
801085d3:	75 28                	jne    801085fd <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
801085d5:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
801085db:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801085e0:	89 c8                	mov    %ecx,%eax
801085e2:	f7 e2                	mul    %edx
801085e4:	c1 ea 03             	shr    $0x3,%edx
801085e7:	89 d0                	mov    %edx,%eax
801085e9:	c1 e0 02             	shl    $0x2,%eax
801085ec:	01 d0                	add    %edx,%eax
801085ee:	01 c0                	add    %eax,%eax
801085f0:	29 c1                	sub    %eax,%ecx
801085f2:	89 ca                	mov    %ecx,%edx
801085f4:	85 d2                	test   %edx,%edx
801085f6:	75 05                	jne    801085fd <trap+0x239>
    yield();
801085f8:	e8 c0 d0 ff ff       	call   801056bd <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801085fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108603:	85 c0                	test   %eax,%eax
80108605:	74 27                	je     8010862e <trap+0x26a>
80108607:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010860d:	8b 40 24             	mov    0x24(%eax),%eax
80108610:	85 c0                	test   %eax,%eax
80108612:	74 1a                	je     8010862e <trap+0x26a>
80108614:	8b 45 08             	mov    0x8(%ebp),%eax
80108617:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010861b:	0f b7 c0             	movzwl %ax,%eax
8010861e:	83 e0 03             	and    $0x3,%eax
80108621:	83 f8 03             	cmp    $0x3,%eax
80108624:	75 08                	jne    8010862e <trap+0x26a>
    exit();
80108626:	e8 ae c8 ff ff       	call   80104ed9 <exit>
8010862b:	eb 01                	jmp    8010862e <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010862d:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010862e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108631:	5b                   	pop    %ebx
80108632:	5e                   	pop    %esi
80108633:	5f                   	pop    %edi
80108634:	5d                   	pop    %ebp
80108635:	c3                   	ret    

80108636 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108636:	55                   	push   %ebp
80108637:	89 e5                	mov    %esp,%ebp
80108639:	83 ec 14             	sub    $0x14,%esp
8010863c:	8b 45 08             	mov    0x8(%ebp),%eax
8010863f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108643:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108647:	89 c2                	mov    %eax,%edx
80108649:	ec                   	in     (%dx),%al
8010864a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010864d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108651:	c9                   	leave  
80108652:	c3                   	ret    

80108653 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80108653:	55                   	push   %ebp
80108654:	89 e5                	mov    %esp,%ebp
80108656:	83 ec 08             	sub    $0x8,%esp
80108659:	8b 55 08             	mov    0x8(%ebp),%edx
8010865c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010865f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108663:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108666:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010866a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010866e:	ee                   	out    %al,(%dx)
}
8010866f:	90                   	nop
80108670:	c9                   	leave  
80108671:	c3                   	ret    

80108672 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80108672:	55                   	push   %ebp
80108673:	89 e5                	mov    %esp,%ebp
80108675:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80108678:	6a 00                	push   $0x0
8010867a:	68 fa 03 00 00       	push   $0x3fa
8010867f:	e8 cf ff ff ff       	call   80108653 <outb>
80108684:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108687:	68 80 00 00 00       	push   $0x80
8010868c:	68 fb 03 00 00       	push   $0x3fb
80108691:	e8 bd ff ff ff       	call   80108653 <outb>
80108696:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108699:	6a 0c                	push   $0xc
8010869b:	68 f8 03 00 00       	push   $0x3f8
801086a0:	e8 ae ff ff ff       	call   80108653 <outb>
801086a5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801086a8:	6a 00                	push   $0x0
801086aa:	68 f9 03 00 00       	push   $0x3f9
801086af:	e8 9f ff ff ff       	call   80108653 <outb>
801086b4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801086b7:	6a 03                	push   $0x3
801086b9:	68 fb 03 00 00       	push   $0x3fb
801086be:	e8 90 ff ff ff       	call   80108653 <outb>
801086c3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801086c6:	6a 00                	push   $0x0
801086c8:	68 fc 03 00 00       	push   $0x3fc
801086cd:	e8 81 ff ff ff       	call   80108653 <outb>
801086d2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801086d5:	6a 01                	push   $0x1
801086d7:	68 f9 03 00 00       	push   $0x3f9
801086dc:	e8 72 ff ff ff       	call   80108653 <outb>
801086e1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801086e4:	68 fd 03 00 00       	push   $0x3fd
801086e9:	e8 48 ff ff ff       	call   80108636 <inb>
801086ee:	83 c4 04             	add    $0x4,%esp
801086f1:	3c ff                	cmp    $0xff,%al
801086f3:	74 6e                	je     80108763 <uartinit+0xf1>
    return;
  uart = 1;
801086f5:	c7 05 8c d6 10 80 01 	movl   $0x1,0x8010d68c
801086fc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801086ff:	68 fa 03 00 00       	push   $0x3fa
80108704:	e8 2d ff ff ff       	call   80108636 <inb>
80108709:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010870c:	68 f8 03 00 00       	push   $0x3f8
80108711:	e8 20 ff ff ff       	call   80108636 <inb>
80108716:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108719:	83 ec 0c             	sub    $0xc,%esp
8010871c:	6a 04                	push   $0x4
8010871e:	e8 4b bb ff ff       	call   8010426e <picenable>
80108723:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108726:	83 ec 08             	sub    $0x8,%esp
80108729:	6a 00                	push   $0x0
8010872b:	6a 04                	push   $0x4
8010872d:	e8 eb a6 ff ff       	call   80102e1d <ioapicenable>
80108732:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108735:	c7 45 f4 40 a8 10 80 	movl   $0x8010a840,-0xc(%ebp)
8010873c:	eb 19                	jmp    80108757 <uartinit+0xe5>
    uartputc(*p);
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	0f b6 00             	movzbl (%eax),%eax
80108744:	0f be c0             	movsbl %al,%eax
80108747:	83 ec 0c             	sub    $0xc,%esp
8010874a:	50                   	push   %eax
8010874b:	e8 16 00 00 00       	call   80108766 <uartputc>
80108750:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108753:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875a:	0f b6 00             	movzbl (%eax),%eax
8010875d:	84 c0                	test   %al,%al
8010875f:	75 dd                	jne    8010873e <uartinit+0xcc>
80108761:	eb 01                	jmp    80108764 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80108763:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80108764:	c9                   	leave  
80108765:	c3                   	ret    

80108766 <uartputc>:

void
uartputc(int c)
{
80108766:	55                   	push   %ebp
80108767:	89 e5                	mov    %esp,%ebp
80108769:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010876c:	a1 8c d6 10 80       	mov    0x8010d68c,%eax
80108771:	85 c0                	test   %eax,%eax
80108773:	74 53                	je     801087c8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80108775:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010877c:	eb 11                	jmp    8010878f <uartputc+0x29>
    microdelay(10);
8010877e:	83 ec 0c             	sub    $0xc,%esp
80108781:	6a 0a                	push   $0xa
80108783:	e8 fb ab ff ff       	call   80103383 <microdelay>
80108788:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010878b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010878f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108793:	7f 1a                	jg     801087af <uartputc+0x49>
80108795:	83 ec 0c             	sub    $0xc,%esp
80108798:	68 fd 03 00 00       	push   $0x3fd
8010879d:	e8 94 fe ff ff       	call   80108636 <inb>
801087a2:	83 c4 10             	add    $0x10,%esp
801087a5:	0f b6 c0             	movzbl %al,%eax
801087a8:	83 e0 20             	and    $0x20,%eax
801087ab:	85 c0                	test   %eax,%eax
801087ad:	74 cf                	je     8010877e <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801087af:	8b 45 08             	mov    0x8(%ebp),%eax
801087b2:	0f b6 c0             	movzbl %al,%eax
801087b5:	83 ec 08             	sub    $0x8,%esp
801087b8:	50                   	push   %eax
801087b9:	68 f8 03 00 00       	push   $0x3f8
801087be:	e8 90 fe ff ff       	call   80108653 <outb>
801087c3:	83 c4 10             	add    $0x10,%esp
801087c6:	eb 01                	jmp    801087c9 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801087c8:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801087c9:	c9                   	leave  
801087ca:	c3                   	ret    

801087cb <uartgetc>:

static int
uartgetc(void)
{
801087cb:	55                   	push   %ebp
801087cc:	89 e5                	mov    %esp,%ebp
  if(!uart)
801087ce:	a1 8c d6 10 80       	mov    0x8010d68c,%eax
801087d3:	85 c0                	test   %eax,%eax
801087d5:	75 07                	jne    801087de <uartgetc+0x13>
    return -1;
801087d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087dc:	eb 2e                	jmp    8010880c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801087de:	68 fd 03 00 00       	push   $0x3fd
801087e3:	e8 4e fe ff ff       	call   80108636 <inb>
801087e8:	83 c4 04             	add    $0x4,%esp
801087eb:	0f b6 c0             	movzbl %al,%eax
801087ee:	83 e0 01             	and    $0x1,%eax
801087f1:	85 c0                	test   %eax,%eax
801087f3:	75 07                	jne    801087fc <uartgetc+0x31>
    return -1;
801087f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087fa:	eb 10                	jmp    8010880c <uartgetc+0x41>
  return inb(COM1+0);
801087fc:	68 f8 03 00 00       	push   $0x3f8
80108801:	e8 30 fe ff ff       	call   80108636 <inb>
80108806:	83 c4 04             	add    $0x4,%esp
80108809:	0f b6 c0             	movzbl %al,%eax
}
8010880c:	c9                   	leave  
8010880d:	c3                   	ret    

8010880e <uartintr>:

void
uartintr(void)
{
8010880e:	55                   	push   %ebp
8010880f:	89 e5                	mov    %esp,%ebp
80108811:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108814:	83 ec 0c             	sub    $0xc,%esp
80108817:	68 cb 87 10 80       	push   $0x801087cb
8010881c:	e8 d8 7f ff ff       	call   801007f9 <consoleintr>
80108821:	83 c4 10             	add    $0x10,%esp
}
80108824:	90                   	nop
80108825:	c9                   	leave  
80108826:	c3                   	ret    

80108827 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108827:	6a 00                	push   $0x0
  pushl $0
80108829:	6a 00                	push   $0x0
  jmp alltraps
8010882b:	e9 a9 f9 ff ff       	jmp    801081d9 <alltraps>

80108830 <vector1>:
.globl vector1
vector1:
  pushl $0
80108830:	6a 00                	push   $0x0
  pushl $1
80108832:	6a 01                	push   $0x1
  jmp alltraps
80108834:	e9 a0 f9 ff ff       	jmp    801081d9 <alltraps>

80108839 <vector2>:
.globl vector2
vector2:
  pushl $0
80108839:	6a 00                	push   $0x0
  pushl $2
8010883b:	6a 02                	push   $0x2
  jmp alltraps
8010883d:	e9 97 f9 ff ff       	jmp    801081d9 <alltraps>

80108842 <vector3>:
.globl vector3
vector3:
  pushl $0
80108842:	6a 00                	push   $0x0
  pushl $3
80108844:	6a 03                	push   $0x3
  jmp alltraps
80108846:	e9 8e f9 ff ff       	jmp    801081d9 <alltraps>

8010884b <vector4>:
.globl vector4
vector4:
  pushl $0
8010884b:	6a 00                	push   $0x0
  pushl $4
8010884d:	6a 04                	push   $0x4
  jmp alltraps
8010884f:	e9 85 f9 ff ff       	jmp    801081d9 <alltraps>

80108854 <vector5>:
.globl vector5
vector5:
  pushl $0
80108854:	6a 00                	push   $0x0
  pushl $5
80108856:	6a 05                	push   $0x5
  jmp alltraps
80108858:	e9 7c f9 ff ff       	jmp    801081d9 <alltraps>

8010885d <vector6>:
.globl vector6
vector6:
  pushl $0
8010885d:	6a 00                	push   $0x0
  pushl $6
8010885f:	6a 06                	push   $0x6
  jmp alltraps
80108861:	e9 73 f9 ff ff       	jmp    801081d9 <alltraps>

80108866 <vector7>:
.globl vector7
vector7:
  pushl $0
80108866:	6a 00                	push   $0x0
  pushl $7
80108868:	6a 07                	push   $0x7
  jmp alltraps
8010886a:	e9 6a f9 ff ff       	jmp    801081d9 <alltraps>

8010886f <vector8>:
.globl vector8
vector8:
  pushl $8
8010886f:	6a 08                	push   $0x8
  jmp alltraps
80108871:	e9 63 f9 ff ff       	jmp    801081d9 <alltraps>

80108876 <vector9>:
.globl vector9
vector9:
  pushl $0
80108876:	6a 00                	push   $0x0
  pushl $9
80108878:	6a 09                	push   $0x9
  jmp alltraps
8010887a:	e9 5a f9 ff ff       	jmp    801081d9 <alltraps>

8010887f <vector10>:
.globl vector10
vector10:
  pushl $10
8010887f:	6a 0a                	push   $0xa
  jmp alltraps
80108881:	e9 53 f9 ff ff       	jmp    801081d9 <alltraps>

80108886 <vector11>:
.globl vector11
vector11:
  pushl $11
80108886:	6a 0b                	push   $0xb
  jmp alltraps
80108888:	e9 4c f9 ff ff       	jmp    801081d9 <alltraps>

8010888d <vector12>:
.globl vector12
vector12:
  pushl $12
8010888d:	6a 0c                	push   $0xc
  jmp alltraps
8010888f:	e9 45 f9 ff ff       	jmp    801081d9 <alltraps>

80108894 <vector13>:
.globl vector13
vector13:
  pushl $13
80108894:	6a 0d                	push   $0xd
  jmp alltraps
80108896:	e9 3e f9 ff ff       	jmp    801081d9 <alltraps>

8010889b <vector14>:
.globl vector14
vector14:
  pushl $14
8010889b:	6a 0e                	push   $0xe
  jmp alltraps
8010889d:	e9 37 f9 ff ff       	jmp    801081d9 <alltraps>

801088a2 <vector15>:
.globl vector15
vector15:
  pushl $0
801088a2:	6a 00                	push   $0x0
  pushl $15
801088a4:	6a 0f                	push   $0xf
  jmp alltraps
801088a6:	e9 2e f9 ff ff       	jmp    801081d9 <alltraps>

801088ab <vector16>:
.globl vector16
vector16:
  pushl $0
801088ab:	6a 00                	push   $0x0
  pushl $16
801088ad:	6a 10                	push   $0x10
  jmp alltraps
801088af:	e9 25 f9 ff ff       	jmp    801081d9 <alltraps>

801088b4 <vector17>:
.globl vector17
vector17:
  pushl $17
801088b4:	6a 11                	push   $0x11
  jmp alltraps
801088b6:	e9 1e f9 ff ff       	jmp    801081d9 <alltraps>

801088bb <vector18>:
.globl vector18
vector18:
  pushl $0
801088bb:	6a 00                	push   $0x0
  pushl $18
801088bd:	6a 12                	push   $0x12
  jmp alltraps
801088bf:	e9 15 f9 ff ff       	jmp    801081d9 <alltraps>

801088c4 <vector19>:
.globl vector19
vector19:
  pushl $0
801088c4:	6a 00                	push   $0x0
  pushl $19
801088c6:	6a 13                	push   $0x13
  jmp alltraps
801088c8:	e9 0c f9 ff ff       	jmp    801081d9 <alltraps>

801088cd <vector20>:
.globl vector20
vector20:
  pushl $0
801088cd:	6a 00                	push   $0x0
  pushl $20
801088cf:	6a 14                	push   $0x14
  jmp alltraps
801088d1:	e9 03 f9 ff ff       	jmp    801081d9 <alltraps>

801088d6 <vector21>:
.globl vector21
vector21:
  pushl $0
801088d6:	6a 00                	push   $0x0
  pushl $21
801088d8:	6a 15                	push   $0x15
  jmp alltraps
801088da:	e9 fa f8 ff ff       	jmp    801081d9 <alltraps>

801088df <vector22>:
.globl vector22
vector22:
  pushl $0
801088df:	6a 00                	push   $0x0
  pushl $22
801088e1:	6a 16                	push   $0x16
  jmp alltraps
801088e3:	e9 f1 f8 ff ff       	jmp    801081d9 <alltraps>

801088e8 <vector23>:
.globl vector23
vector23:
  pushl $0
801088e8:	6a 00                	push   $0x0
  pushl $23
801088ea:	6a 17                	push   $0x17
  jmp alltraps
801088ec:	e9 e8 f8 ff ff       	jmp    801081d9 <alltraps>

801088f1 <vector24>:
.globl vector24
vector24:
  pushl $0
801088f1:	6a 00                	push   $0x0
  pushl $24
801088f3:	6a 18                	push   $0x18
  jmp alltraps
801088f5:	e9 df f8 ff ff       	jmp    801081d9 <alltraps>

801088fa <vector25>:
.globl vector25
vector25:
  pushl $0
801088fa:	6a 00                	push   $0x0
  pushl $25
801088fc:	6a 19                	push   $0x19
  jmp alltraps
801088fe:	e9 d6 f8 ff ff       	jmp    801081d9 <alltraps>

80108903 <vector26>:
.globl vector26
vector26:
  pushl $0
80108903:	6a 00                	push   $0x0
  pushl $26
80108905:	6a 1a                	push   $0x1a
  jmp alltraps
80108907:	e9 cd f8 ff ff       	jmp    801081d9 <alltraps>

8010890c <vector27>:
.globl vector27
vector27:
  pushl $0
8010890c:	6a 00                	push   $0x0
  pushl $27
8010890e:	6a 1b                	push   $0x1b
  jmp alltraps
80108910:	e9 c4 f8 ff ff       	jmp    801081d9 <alltraps>

80108915 <vector28>:
.globl vector28
vector28:
  pushl $0
80108915:	6a 00                	push   $0x0
  pushl $28
80108917:	6a 1c                	push   $0x1c
  jmp alltraps
80108919:	e9 bb f8 ff ff       	jmp    801081d9 <alltraps>

8010891e <vector29>:
.globl vector29
vector29:
  pushl $0
8010891e:	6a 00                	push   $0x0
  pushl $29
80108920:	6a 1d                	push   $0x1d
  jmp alltraps
80108922:	e9 b2 f8 ff ff       	jmp    801081d9 <alltraps>

80108927 <vector30>:
.globl vector30
vector30:
  pushl $0
80108927:	6a 00                	push   $0x0
  pushl $30
80108929:	6a 1e                	push   $0x1e
  jmp alltraps
8010892b:	e9 a9 f8 ff ff       	jmp    801081d9 <alltraps>

80108930 <vector31>:
.globl vector31
vector31:
  pushl $0
80108930:	6a 00                	push   $0x0
  pushl $31
80108932:	6a 1f                	push   $0x1f
  jmp alltraps
80108934:	e9 a0 f8 ff ff       	jmp    801081d9 <alltraps>

80108939 <vector32>:
.globl vector32
vector32:
  pushl $0
80108939:	6a 00                	push   $0x0
  pushl $32
8010893b:	6a 20                	push   $0x20
  jmp alltraps
8010893d:	e9 97 f8 ff ff       	jmp    801081d9 <alltraps>

80108942 <vector33>:
.globl vector33
vector33:
  pushl $0
80108942:	6a 00                	push   $0x0
  pushl $33
80108944:	6a 21                	push   $0x21
  jmp alltraps
80108946:	e9 8e f8 ff ff       	jmp    801081d9 <alltraps>

8010894b <vector34>:
.globl vector34
vector34:
  pushl $0
8010894b:	6a 00                	push   $0x0
  pushl $34
8010894d:	6a 22                	push   $0x22
  jmp alltraps
8010894f:	e9 85 f8 ff ff       	jmp    801081d9 <alltraps>

80108954 <vector35>:
.globl vector35
vector35:
  pushl $0
80108954:	6a 00                	push   $0x0
  pushl $35
80108956:	6a 23                	push   $0x23
  jmp alltraps
80108958:	e9 7c f8 ff ff       	jmp    801081d9 <alltraps>

8010895d <vector36>:
.globl vector36
vector36:
  pushl $0
8010895d:	6a 00                	push   $0x0
  pushl $36
8010895f:	6a 24                	push   $0x24
  jmp alltraps
80108961:	e9 73 f8 ff ff       	jmp    801081d9 <alltraps>

80108966 <vector37>:
.globl vector37
vector37:
  pushl $0
80108966:	6a 00                	push   $0x0
  pushl $37
80108968:	6a 25                	push   $0x25
  jmp alltraps
8010896a:	e9 6a f8 ff ff       	jmp    801081d9 <alltraps>

8010896f <vector38>:
.globl vector38
vector38:
  pushl $0
8010896f:	6a 00                	push   $0x0
  pushl $38
80108971:	6a 26                	push   $0x26
  jmp alltraps
80108973:	e9 61 f8 ff ff       	jmp    801081d9 <alltraps>

80108978 <vector39>:
.globl vector39
vector39:
  pushl $0
80108978:	6a 00                	push   $0x0
  pushl $39
8010897a:	6a 27                	push   $0x27
  jmp alltraps
8010897c:	e9 58 f8 ff ff       	jmp    801081d9 <alltraps>

80108981 <vector40>:
.globl vector40
vector40:
  pushl $0
80108981:	6a 00                	push   $0x0
  pushl $40
80108983:	6a 28                	push   $0x28
  jmp alltraps
80108985:	e9 4f f8 ff ff       	jmp    801081d9 <alltraps>

8010898a <vector41>:
.globl vector41
vector41:
  pushl $0
8010898a:	6a 00                	push   $0x0
  pushl $41
8010898c:	6a 29                	push   $0x29
  jmp alltraps
8010898e:	e9 46 f8 ff ff       	jmp    801081d9 <alltraps>

80108993 <vector42>:
.globl vector42
vector42:
  pushl $0
80108993:	6a 00                	push   $0x0
  pushl $42
80108995:	6a 2a                	push   $0x2a
  jmp alltraps
80108997:	e9 3d f8 ff ff       	jmp    801081d9 <alltraps>

8010899c <vector43>:
.globl vector43
vector43:
  pushl $0
8010899c:	6a 00                	push   $0x0
  pushl $43
8010899e:	6a 2b                	push   $0x2b
  jmp alltraps
801089a0:	e9 34 f8 ff ff       	jmp    801081d9 <alltraps>

801089a5 <vector44>:
.globl vector44
vector44:
  pushl $0
801089a5:	6a 00                	push   $0x0
  pushl $44
801089a7:	6a 2c                	push   $0x2c
  jmp alltraps
801089a9:	e9 2b f8 ff ff       	jmp    801081d9 <alltraps>

801089ae <vector45>:
.globl vector45
vector45:
  pushl $0
801089ae:	6a 00                	push   $0x0
  pushl $45
801089b0:	6a 2d                	push   $0x2d
  jmp alltraps
801089b2:	e9 22 f8 ff ff       	jmp    801081d9 <alltraps>

801089b7 <vector46>:
.globl vector46
vector46:
  pushl $0
801089b7:	6a 00                	push   $0x0
  pushl $46
801089b9:	6a 2e                	push   $0x2e
  jmp alltraps
801089bb:	e9 19 f8 ff ff       	jmp    801081d9 <alltraps>

801089c0 <vector47>:
.globl vector47
vector47:
  pushl $0
801089c0:	6a 00                	push   $0x0
  pushl $47
801089c2:	6a 2f                	push   $0x2f
  jmp alltraps
801089c4:	e9 10 f8 ff ff       	jmp    801081d9 <alltraps>

801089c9 <vector48>:
.globl vector48
vector48:
  pushl $0
801089c9:	6a 00                	push   $0x0
  pushl $48
801089cb:	6a 30                	push   $0x30
  jmp alltraps
801089cd:	e9 07 f8 ff ff       	jmp    801081d9 <alltraps>

801089d2 <vector49>:
.globl vector49
vector49:
  pushl $0
801089d2:	6a 00                	push   $0x0
  pushl $49
801089d4:	6a 31                	push   $0x31
  jmp alltraps
801089d6:	e9 fe f7 ff ff       	jmp    801081d9 <alltraps>

801089db <vector50>:
.globl vector50
vector50:
  pushl $0
801089db:	6a 00                	push   $0x0
  pushl $50
801089dd:	6a 32                	push   $0x32
  jmp alltraps
801089df:	e9 f5 f7 ff ff       	jmp    801081d9 <alltraps>

801089e4 <vector51>:
.globl vector51
vector51:
  pushl $0
801089e4:	6a 00                	push   $0x0
  pushl $51
801089e6:	6a 33                	push   $0x33
  jmp alltraps
801089e8:	e9 ec f7 ff ff       	jmp    801081d9 <alltraps>

801089ed <vector52>:
.globl vector52
vector52:
  pushl $0
801089ed:	6a 00                	push   $0x0
  pushl $52
801089ef:	6a 34                	push   $0x34
  jmp alltraps
801089f1:	e9 e3 f7 ff ff       	jmp    801081d9 <alltraps>

801089f6 <vector53>:
.globl vector53
vector53:
  pushl $0
801089f6:	6a 00                	push   $0x0
  pushl $53
801089f8:	6a 35                	push   $0x35
  jmp alltraps
801089fa:	e9 da f7 ff ff       	jmp    801081d9 <alltraps>

801089ff <vector54>:
.globl vector54
vector54:
  pushl $0
801089ff:	6a 00                	push   $0x0
  pushl $54
80108a01:	6a 36                	push   $0x36
  jmp alltraps
80108a03:	e9 d1 f7 ff ff       	jmp    801081d9 <alltraps>

80108a08 <vector55>:
.globl vector55
vector55:
  pushl $0
80108a08:	6a 00                	push   $0x0
  pushl $55
80108a0a:	6a 37                	push   $0x37
  jmp alltraps
80108a0c:	e9 c8 f7 ff ff       	jmp    801081d9 <alltraps>

80108a11 <vector56>:
.globl vector56
vector56:
  pushl $0
80108a11:	6a 00                	push   $0x0
  pushl $56
80108a13:	6a 38                	push   $0x38
  jmp alltraps
80108a15:	e9 bf f7 ff ff       	jmp    801081d9 <alltraps>

80108a1a <vector57>:
.globl vector57
vector57:
  pushl $0
80108a1a:	6a 00                	push   $0x0
  pushl $57
80108a1c:	6a 39                	push   $0x39
  jmp alltraps
80108a1e:	e9 b6 f7 ff ff       	jmp    801081d9 <alltraps>

80108a23 <vector58>:
.globl vector58
vector58:
  pushl $0
80108a23:	6a 00                	push   $0x0
  pushl $58
80108a25:	6a 3a                	push   $0x3a
  jmp alltraps
80108a27:	e9 ad f7 ff ff       	jmp    801081d9 <alltraps>

80108a2c <vector59>:
.globl vector59
vector59:
  pushl $0
80108a2c:	6a 00                	push   $0x0
  pushl $59
80108a2e:	6a 3b                	push   $0x3b
  jmp alltraps
80108a30:	e9 a4 f7 ff ff       	jmp    801081d9 <alltraps>

80108a35 <vector60>:
.globl vector60
vector60:
  pushl $0
80108a35:	6a 00                	push   $0x0
  pushl $60
80108a37:	6a 3c                	push   $0x3c
  jmp alltraps
80108a39:	e9 9b f7 ff ff       	jmp    801081d9 <alltraps>

80108a3e <vector61>:
.globl vector61
vector61:
  pushl $0
80108a3e:	6a 00                	push   $0x0
  pushl $61
80108a40:	6a 3d                	push   $0x3d
  jmp alltraps
80108a42:	e9 92 f7 ff ff       	jmp    801081d9 <alltraps>

80108a47 <vector62>:
.globl vector62
vector62:
  pushl $0
80108a47:	6a 00                	push   $0x0
  pushl $62
80108a49:	6a 3e                	push   $0x3e
  jmp alltraps
80108a4b:	e9 89 f7 ff ff       	jmp    801081d9 <alltraps>

80108a50 <vector63>:
.globl vector63
vector63:
  pushl $0
80108a50:	6a 00                	push   $0x0
  pushl $63
80108a52:	6a 3f                	push   $0x3f
  jmp alltraps
80108a54:	e9 80 f7 ff ff       	jmp    801081d9 <alltraps>

80108a59 <vector64>:
.globl vector64
vector64:
  pushl $0
80108a59:	6a 00                	push   $0x0
  pushl $64
80108a5b:	6a 40                	push   $0x40
  jmp alltraps
80108a5d:	e9 77 f7 ff ff       	jmp    801081d9 <alltraps>

80108a62 <vector65>:
.globl vector65
vector65:
  pushl $0
80108a62:	6a 00                	push   $0x0
  pushl $65
80108a64:	6a 41                	push   $0x41
  jmp alltraps
80108a66:	e9 6e f7 ff ff       	jmp    801081d9 <alltraps>

80108a6b <vector66>:
.globl vector66
vector66:
  pushl $0
80108a6b:	6a 00                	push   $0x0
  pushl $66
80108a6d:	6a 42                	push   $0x42
  jmp alltraps
80108a6f:	e9 65 f7 ff ff       	jmp    801081d9 <alltraps>

80108a74 <vector67>:
.globl vector67
vector67:
  pushl $0
80108a74:	6a 00                	push   $0x0
  pushl $67
80108a76:	6a 43                	push   $0x43
  jmp alltraps
80108a78:	e9 5c f7 ff ff       	jmp    801081d9 <alltraps>

80108a7d <vector68>:
.globl vector68
vector68:
  pushl $0
80108a7d:	6a 00                	push   $0x0
  pushl $68
80108a7f:	6a 44                	push   $0x44
  jmp alltraps
80108a81:	e9 53 f7 ff ff       	jmp    801081d9 <alltraps>

80108a86 <vector69>:
.globl vector69
vector69:
  pushl $0
80108a86:	6a 00                	push   $0x0
  pushl $69
80108a88:	6a 45                	push   $0x45
  jmp alltraps
80108a8a:	e9 4a f7 ff ff       	jmp    801081d9 <alltraps>

80108a8f <vector70>:
.globl vector70
vector70:
  pushl $0
80108a8f:	6a 00                	push   $0x0
  pushl $70
80108a91:	6a 46                	push   $0x46
  jmp alltraps
80108a93:	e9 41 f7 ff ff       	jmp    801081d9 <alltraps>

80108a98 <vector71>:
.globl vector71
vector71:
  pushl $0
80108a98:	6a 00                	push   $0x0
  pushl $71
80108a9a:	6a 47                	push   $0x47
  jmp alltraps
80108a9c:	e9 38 f7 ff ff       	jmp    801081d9 <alltraps>

80108aa1 <vector72>:
.globl vector72
vector72:
  pushl $0
80108aa1:	6a 00                	push   $0x0
  pushl $72
80108aa3:	6a 48                	push   $0x48
  jmp alltraps
80108aa5:	e9 2f f7 ff ff       	jmp    801081d9 <alltraps>

80108aaa <vector73>:
.globl vector73
vector73:
  pushl $0
80108aaa:	6a 00                	push   $0x0
  pushl $73
80108aac:	6a 49                	push   $0x49
  jmp alltraps
80108aae:	e9 26 f7 ff ff       	jmp    801081d9 <alltraps>

80108ab3 <vector74>:
.globl vector74
vector74:
  pushl $0
80108ab3:	6a 00                	push   $0x0
  pushl $74
80108ab5:	6a 4a                	push   $0x4a
  jmp alltraps
80108ab7:	e9 1d f7 ff ff       	jmp    801081d9 <alltraps>

80108abc <vector75>:
.globl vector75
vector75:
  pushl $0
80108abc:	6a 00                	push   $0x0
  pushl $75
80108abe:	6a 4b                	push   $0x4b
  jmp alltraps
80108ac0:	e9 14 f7 ff ff       	jmp    801081d9 <alltraps>

80108ac5 <vector76>:
.globl vector76
vector76:
  pushl $0
80108ac5:	6a 00                	push   $0x0
  pushl $76
80108ac7:	6a 4c                	push   $0x4c
  jmp alltraps
80108ac9:	e9 0b f7 ff ff       	jmp    801081d9 <alltraps>

80108ace <vector77>:
.globl vector77
vector77:
  pushl $0
80108ace:	6a 00                	push   $0x0
  pushl $77
80108ad0:	6a 4d                	push   $0x4d
  jmp alltraps
80108ad2:	e9 02 f7 ff ff       	jmp    801081d9 <alltraps>

80108ad7 <vector78>:
.globl vector78
vector78:
  pushl $0
80108ad7:	6a 00                	push   $0x0
  pushl $78
80108ad9:	6a 4e                	push   $0x4e
  jmp alltraps
80108adb:	e9 f9 f6 ff ff       	jmp    801081d9 <alltraps>

80108ae0 <vector79>:
.globl vector79
vector79:
  pushl $0
80108ae0:	6a 00                	push   $0x0
  pushl $79
80108ae2:	6a 4f                	push   $0x4f
  jmp alltraps
80108ae4:	e9 f0 f6 ff ff       	jmp    801081d9 <alltraps>

80108ae9 <vector80>:
.globl vector80
vector80:
  pushl $0
80108ae9:	6a 00                	push   $0x0
  pushl $80
80108aeb:	6a 50                	push   $0x50
  jmp alltraps
80108aed:	e9 e7 f6 ff ff       	jmp    801081d9 <alltraps>

80108af2 <vector81>:
.globl vector81
vector81:
  pushl $0
80108af2:	6a 00                	push   $0x0
  pushl $81
80108af4:	6a 51                	push   $0x51
  jmp alltraps
80108af6:	e9 de f6 ff ff       	jmp    801081d9 <alltraps>

80108afb <vector82>:
.globl vector82
vector82:
  pushl $0
80108afb:	6a 00                	push   $0x0
  pushl $82
80108afd:	6a 52                	push   $0x52
  jmp alltraps
80108aff:	e9 d5 f6 ff ff       	jmp    801081d9 <alltraps>

80108b04 <vector83>:
.globl vector83
vector83:
  pushl $0
80108b04:	6a 00                	push   $0x0
  pushl $83
80108b06:	6a 53                	push   $0x53
  jmp alltraps
80108b08:	e9 cc f6 ff ff       	jmp    801081d9 <alltraps>

80108b0d <vector84>:
.globl vector84
vector84:
  pushl $0
80108b0d:	6a 00                	push   $0x0
  pushl $84
80108b0f:	6a 54                	push   $0x54
  jmp alltraps
80108b11:	e9 c3 f6 ff ff       	jmp    801081d9 <alltraps>

80108b16 <vector85>:
.globl vector85
vector85:
  pushl $0
80108b16:	6a 00                	push   $0x0
  pushl $85
80108b18:	6a 55                	push   $0x55
  jmp alltraps
80108b1a:	e9 ba f6 ff ff       	jmp    801081d9 <alltraps>

80108b1f <vector86>:
.globl vector86
vector86:
  pushl $0
80108b1f:	6a 00                	push   $0x0
  pushl $86
80108b21:	6a 56                	push   $0x56
  jmp alltraps
80108b23:	e9 b1 f6 ff ff       	jmp    801081d9 <alltraps>

80108b28 <vector87>:
.globl vector87
vector87:
  pushl $0
80108b28:	6a 00                	push   $0x0
  pushl $87
80108b2a:	6a 57                	push   $0x57
  jmp alltraps
80108b2c:	e9 a8 f6 ff ff       	jmp    801081d9 <alltraps>

80108b31 <vector88>:
.globl vector88
vector88:
  pushl $0
80108b31:	6a 00                	push   $0x0
  pushl $88
80108b33:	6a 58                	push   $0x58
  jmp alltraps
80108b35:	e9 9f f6 ff ff       	jmp    801081d9 <alltraps>

80108b3a <vector89>:
.globl vector89
vector89:
  pushl $0
80108b3a:	6a 00                	push   $0x0
  pushl $89
80108b3c:	6a 59                	push   $0x59
  jmp alltraps
80108b3e:	e9 96 f6 ff ff       	jmp    801081d9 <alltraps>

80108b43 <vector90>:
.globl vector90
vector90:
  pushl $0
80108b43:	6a 00                	push   $0x0
  pushl $90
80108b45:	6a 5a                	push   $0x5a
  jmp alltraps
80108b47:	e9 8d f6 ff ff       	jmp    801081d9 <alltraps>

80108b4c <vector91>:
.globl vector91
vector91:
  pushl $0
80108b4c:	6a 00                	push   $0x0
  pushl $91
80108b4e:	6a 5b                	push   $0x5b
  jmp alltraps
80108b50:	e9 84 f6 ff ff       	jmp    801081d9 <alltraps>

80108b55 <vector92>:
.globl vector92
vector92:
  pushl $0
80108b55:	6a 00                	push   $0x0
  pushl $92
80108b57:	6a 5c                	push   $0x5c
  jmp alltraps
80108b59:	e9 7b f6 ff ff       	jmp    801081d9 <alltraps>

80108b5e <vector93>:
.globl vector93
vector93:
  pushl $0
80108b5e:	6a 00                	push   $0x0
  pushl $93
80108b60:	6a 5d                	push   $0x5d
  jmp alltraps
80108b62:	e9 72 f6 ff ff       	jmp    801081d9 <alltraps>

80108b67 <vector94>:
.globl vector94
vector94:
  pushl $0
80108b67:	6a 00                	push   $0x0
  pushl $94
80108b69:	6a 5e                	push   $0x5e
  jmp alltraps
80108b6b:	e9 69 f6 ff ff       	jmp    801081d9 <alltraps>

80108b70 <vector95>:
.globl vector95
vector95:
  pushl $0
80108b70:	6a 00                	push   $0x0
  pushl $95
80108b72:	6a 5f                	push   $0x5f
  jmp alltraps
80108b74:	e9 60 f6 ff ff       	jmp    801081d9 <alltraps>

80108b79 <vector96>:
.globl vector96
vector96:
  pushl $0
80108b79:	6a 00                	push   $0x0
  pushl $96
80108b7b:	6a 60                	push   $0x60
  jmp alltraps
80108b7d:	e9 57 f6 ff ff       	jmp    801081d9 <alltraps>

80108b82 <vector97>:
.globl vector97
vector97:
  pushl $0
80108b82:	6a 00                	push   $0x0
  pushl $97
80108b84:	6a 61                	push   $0x61
  jmp alltraps
80108b86:	e9 4e f6 ff ff       	jmp    801081d9 <alltraps>

80108b8b <vector98>:
.globl vector98
vector98:
  pushl $0
80108b8b:	6a 00                	push   $0x0
  pushl $98
80108b8d:	6a 62                	push   $0x62
  jmp alltraps
80108b8f:	e9 45 f6 ff ff       	jmp    801081d9 <alltraps>

80108b94 <vector99>:
.globl vector99
vector99:
  pushl $0
80108b94:	6a 00                	push   $0x0
  pushl $99
80108b96:	6a 63                	push   $0x63
  jmp alltraps
80108b98:	e9 3c f6 ff ff       	jmp    801081d9 <alltraps>

80108b9d <vector100>:
.globl vector100
vector100:
  pushl $0
80108b9d:	6a 00                	push   $0x0
  pushl $100
80108b9f:	6a 64                	push   $0x64
  jmp alltraps
80108ba1:	e9 33 f6 ff ff       	jmp    801081d9 <alltraps>

80108ba6 <vector101>:
.globl vector101
vector101:
  pushl $0
80108ba6:	6a 00                	push   $0x0
  pushl $101
80108ba8:	6a 65                	push   $0x65
  jmp alltraps
80108baa:	e9 2a f6 ff ff       	jmp    801081d9 <alltraps>

80108baf <vector102>:
.globl vector102
vector102:
  pushl $0
80108baf:	6a 00                	push   $0x0
  pushl $102
80108bb1:	6a 66                	push   $0x66
  jmp alltraps
80108bb3:	e9 21 f6 ff ff       	jmp    801081d9 <alltraps>

80108bb8 <vector103>:
.globl vector103
vector103:
  pushl $0
80108bb8:	6a 00                	push   $0x0
  pushl $103
80108bba:	6a 67                	push   $0x67
  jmp alltraps
80108bbc:	e9 18 f6 ff ff       	jmp    801081d9 <alltraps>

80108bc1 <vector104>:
.globl vector104
vector104:
  pushl $0
80108bc1:	6a 00                	push   $0x0
  pushl $104
80108bc3:	6a 68                	push   $0x68
  jmp alltraps
80108bc5:	e9 0f f6 ff ff       	jmp    801081d9 <alltraps>

80108bca <vector105>:
.globl vector105
vector105:
  pushl $0
80108bca:	6a 00                	push   $0x0
  pushl $105
80108bcc:	6a 69                	push   $0x69
  jmp alltraps
80108bce:	e9 06 f6 ff ff       	jmp    801081d9 <alltraps>

80108bd3 <vector106>:
.globl vector106
vector106:
  pushl $0
80108bd3:	6a 00                	push   $0x0
  pushl $106
80108bd5:	6a 6a                	push   $0x6a
  jmp alltraps
80108bd7:	e9 fd f5 ff ff       	jmp    801081d9 <alltraps>

80108bdc <vector107>:
.globl vector107
vector107:
  pushl $0
80108bdc:	6a 00                	push   $0x0
  pushl $107
80108bde:	6a 6b                	push   $0x6b
  jmp alltraps
80108be0:	e9 f4 f5 ff ff       	jmp    801081d9 <alltraps>

80108be5 <vector108>:
.globl vector108
vector108:
  pushl $0
80108be5:	6a 00                	push   $0x0
  pushl $108
80108be7:	6a 6c                	push   $0x6c
  jmp alltraps
80108be9:	e9 eb f5 ff ff       	jmp    801081d9 <alltraps>

80108bee <vector109>:
.globl vector109
vector109:
  pushl $0
80108bee:	6a 00                	push   $0x0
  pushl $109
80108bf0:	6a 6d                	push   $0x6d
  jmp alltraps
80108bf2:	e9 e2 f5 ff ff       	jmp    801081d9 <alltraps>

80108bf7 <vector110>:
.globl vector110
vector110:
  pushl $0
80108bf7:	6a 00                	push   $0x0
  pushl $110
80108bf9:	6a 6e                	push   $0x6e
  jmp alltraps
80108bfb:	e9 d9 f5 ff ff       	jmp    801081d9 <alltraps>

80108c00 <vector111>:
.globl vector111
vector111:
  pushl $0
80108c00:	6a 00                	push   $0x0
  pushl $111
80108c02:	6a 6f                	push   $0x6f
  jmp alltraps
80108c04:	e9 d0 f5 ff ff       	jmp    801081d9 <alltraps>

80108c09 <vector112>:
.globl vector112
vector112:
  pushl $0
80108c09:	6a 00                	push   $0x0
  pushl $112
80108c0b:	6a 70                	push   $0x70
  jmp alltraps
80108c0d:	e9 c7 f5 ff ff       	jmp    801081d9 <alltraps>

80108c12 <vector113>:
.globl vector113
vector113:
  pushl $0
80108c12:	6a 00                	push   $0x0
  pushl $113
80108c14:	6a 71                	push   $0x71
  jmp alltraps
80108c16:	e9 be f5 ff ff       	jmp    801081d9 <alltraps>

80108c1b <vector114>:
.globl vector114
vector114:
  pushl $0
80108c1b:	6a 00                	push   $0x0
  pushl $114
80108c1d:	6a 72                	push   $0x72
  jmp alltraps
80108c1f:	e9 b5 f5 ff ff       	jmp    801081d9 <alltraps>

80108c24 <vector115>:
.globl vector115
vector115:
  pushl $0
80108c24:	6a 00                	push   $0x0
  pushl $115
80108c26:	6a 73                	push   $0x73
  jmp alltraps
80108c28:	e9 ac f5 ff ff       	jmp    801081d9 <alltraps>

80108c2d <vector116>:
.globl vector116
vector116:
  pushl $0
80108c2d:	6a 00                	push   $0x0
  pushl $116
80108c2f:	6a 74                	push   $0x74
  jmp alltraps
80108c31:	e9 a3 f5 ff ff       	jmp    801081d9 <alltraps>

80108c36 <vector117>:
.globl vector117
vector117:
  pushl $0
80108c36:	6a 00                	push   $0x0
  pushl $117
80108c38:	6a 75                	push   $0x75
  jmp alltraps
80108c3a:	e9 9a f5 ff ff       	jmp    801081d9 <alltraps>

80108c3f <vector118>:
.globl vector118
vector118:
  pushl $0
80108c3f:	6a 00                	push   $0x0
  pushl $118
80108c41:	6a 76                	push   $0x76
  jmp alltraps
80108c43:	e9 91 f5 ff ff       	jmp    801081d9 <alltraps>

80108c48 <vector119>:
.globl vector119
vector119:
  pushl $0
80108c48:	6a 00                	push   $0x0
  pushl $119
80108c4a:	6a 77                	push   $0x77
  jmp alltraps
80108c4c:	e9 88 f5 ff ff       	jmp    801081d9 <alltraps>

80108c51 <vector120>:
.globl vector120
vector120:
  pushl $0
80108c51:	6a 00                	push   $0x0
  pushl $120
80108c53:	6a 78                	push   $0x78
  jmp alltraps
80108c55:	e9 7f f5 ff ff       	jmp    801081d9 <alltraps>

80108c5a <vector121>:
.globl vector121
vector121:
  pushl $0
80108c5a:	6a 00                	push   $0x0
  pushl $121
80108c5c:	6a 79                	push   $0x79
  jmp alltraps
80108c5e:	e9 76 f5 ff ff       	jmp    801081d9 <alltraps>

80108c63 <vector122>:
.globl vector122
vector122:
  pushl $0
80108c63:	6a 00                	push   $0x0
  pushl $122
80108c65:	6a 7a                	push   $0x7a
  jmp alltraps
80108c67:	e9 6d f5 ff ff       	jmp    801081d9 <alltraps>

80108c6c <vector123>:
.globl vector123
vector123:
  pushl $0
80108c6c:	6a 00                	push   $0x0
  pushl $123
80108c6e:	6a 7b                	push   $0x7b
  jmp alltraps
80108c70:	e9 64 f5 ff ff       	jmp    801081d9 <alltraps>

80108c75 <vector124>:
.globl vector124
vector124:
  pushl $0
80108c75:	6a 00                	push   $0x0
  pushl $124
80108c77:	6a 7c                	push   $0x7c
  jmp alltraps
80108c79:	e9 5b f5 ff ff       	jmp    801081d9 <alltraps>

80108c7e <vector125>:
.globl vector125
vector125:
  pushl $0
80108c7e:	6a 00                	push   $0x0
  pushl $125
80108c80:	6a 7d                	push   $0x7d
  jmp alltraps
80108c82:	e9 52 f5 ff ff       	jmp    801081d9 <alltraps>

80108c87 <vector126>:
.globl vector126
vector126:
  pushl $0
80108c87:	6a 00                	push   $0x0
  pushl $126
80108c89:	6a 7e                	push   $0x7e
  jmp alltraps
80108c8b:	e9 49 f5 ff ff       	jmp    801081d9 <alltraps>

80108c90 <vector127>:
.globl vector127
vector127:
  pushl $0
80108c90:	6a 00                	push   $0x0
  pushl $127
80108c92:	6a 7f                	push   $0x7f
  jmp alltraps
80108c94:	e9 40 f5 ff ff       	jmp    801081d9 <alltraps>

80108c99 <vector128>:
.globl vector128
vector128:
  pushl $0
80108c99:	6a 00                	push   $0x0
  pushl $128
80108c9b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108ca0:	e9 34 f5 ff ff       	jmp    801081d9 <alltraps>

80108ca5 <vector129>:
.globl vector129
vector129:
  pushl $0
80108ca5:	6a 00                	push   $0x0
  pushl $129
80108ca7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108cac:	e9 28 f5 ff ff       	jmp    801081d9 <alltraps>

80108cb1 <vector130>:
.globl vector130
vector130:
  pushl $0
80108cb1:	6a 00                	push   $0x0
  pushl $130
80108cb3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108cb8:	e9 1c f5 ff ff       	jmp    801081d9 <alltraps>

80108cbd <vector131>:
.globl vector131
vector131:
  pushl $0
80108cbd:	6a 00                	push   $0x0
  pushl $131
80108cbf:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108cc4:	e9 10 f5 ff ff       	jmp    801081d9 <alltraps>

80108cc9 <vector132>:
.globl vector132
vector132:
  pushl $0
80108cc9:	6a 00                	push   $0x0
  pushl $132
80108ccb:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108cd0:	e9 04 f5 ff ff       	jmp    801081d9 <alltraps>

80108cd5 <vector133>:
.globl vector133
vector133:
  pushl $0
80108cd5:	6a 00                	push   $0x0
  pushl $133
80108cd7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108cdc:	e9 f8 f4 ff ff       	jmp    801081d9 <alltraps>

80108ce1 <vector134>:
.globl vector134
vector134:
  pushl $0
80108ce1:	6a 00                	push   $0x0
  pushl $134
80108ce3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108ce8:	e9 ec f4 ff ff       	jmp    801081d9 <alltraps>

80108ced <vector135>:
.globl vector135
vector135:
  pushl $0
80108ced:	6a 00                	push   $0x0
  pushl $135
80108cef:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108cf4:	e9 e0 f4 ff ff       	jmp    801081d9 <alltraps>

80108cf9 <vector136>:
.globl vector136
vector136:
  pushl $0
80108cf9:	6a 00                	push   $0x0
  pushl $136
80108cfb:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108d00:	e9 d4 f4 ff ff       	jmp    801081d9 <alltraps>

80108d05 <vector137>:
.globl vector137
vector137:
  pushl $0
80108d05:	6a 00                	push   $0x0
  pushl $137
80108d07:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108d0c:	e9 c8 f4 ff ff       	jmp    801081d9 <alltraps>

80108d11 <vector138>:
.globl vector138
vector138:
  pushl $0
80108d11:	6a 00                	push   $0x0
  pushl $138
80108d13:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108d18:	e9 bc f4 ff ff       	jmp    801081d9 <alltraps>

80108d1d <vector139>:
.globl vector139
vector139:
  pushl $0
80108d1d:	6a 00                	push   $0x0
  pushl $139
80108d1f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108d24:	e9 b0 f4 ff ff       	jmp    801081d9 <alltraps>

80108d29 <vector140>:
.globl vector140
vector140:
  pushl $0
80108d29:	6a 00                	push   $0x0
  pushl $140
80108d2b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108d30:	e9 a4 f4 ff ff       	jmp    801081d9 <alltraps>

80108d35 <vector141>:
.globl vector141
vector141:
  pushl $0
80108d35:	6a 00                	push   $0x0
  pushl $141
80108d37:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108d3c:	e9 98 f4 ff ff       	jmp    801081d9 <alltraps>

80108d41 <vector142>:
.globl vector142
vector142:
  pushl $0
80108d41:	6a 00                	push   $0x0
  pushl $142
80108d43:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108d48:	e9 8c f4 ff ff       	jmp    801081d9 <alltraps>

80108d4d <vector143>:
.globl vector143
vector143:
  pushl $0
80108d4d:	6a 00                	push   $0x0
  pushl $143
80108d4f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108d54:	e9 80 f4 ff ff       	jmp    801081d9 <alltraps>

80108d59 <vector144>:
.globl vector144
vector144:
  pushl $0
80108d59:	6a 00                	push   $0x0
  pushl $144
80108d5b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108d60:	e9 74 f4 ff ff       	jmp    801081d9 <alltraps>

80108d65 <vector145>:
.globl vector145
vector145:
  pushl $0
80108d65:	6a 00                	push   $0x0
  pushl $145
80108d67:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108d6c:	e9 68 f4 ff ff       	jmp    801081d9 <alltraps>

80108d71 <vector146>:
.globl vector146
vector146:
  pushl $0
80108d71:	6a 00                	push   $0x0
  pushl $146
80108d73:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108d78:	e9 5c f4 ff ff       	jmp    801081d9 <alltraps>

80108d7d <vector147>:
.globl vector147
vector147:
  pushl $0
80108d7d:	6a 00                	push   $0x0
  pushl $147
80108d7f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108d84:	e9 50 f4 ff ff       	jmp    801081d9 <alltraps>

80108d89 <vector148>:
.globl vector148
vector148:
  pushl $0
80108d89:	6a 00                	push   $0x0
  pushl $148
80108d8b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108d90:	e9 44 f4 ff ff       	jmp    801081d9 <alltraps>

80108d95 <vector149>:
.globl vector149
vector149:
  pushl $0
80108d95:	6a 00                	push   $0x0
  pushl $149
80108d97:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108d9c:	e9 38 f4 ff ff       	jmp    801081d9 <alltraps>

80108da1 <vector150>:
.globl vector150
vector150:
  pushl $0
80108da1:	6a 00                	push   $0x0
  pushl $150
80108da3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108da8:	e9 2c f4 ff ff       	jmp    801081d9 <alltraps>

80108dad <vector151>:
.globl vector151
vector151:
  pushl $0
80108dad:	6a 00                	push   $0x0
  pushl $151
80108daf:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108db4:	e9 20 f4 ff ff       	jmp    801081d9 <alltraps>

80108db9 <vector152>:
.globl vector152
vector152:
  pushl $0
80108db9:	6a 00                	push   $0x0
  pushl $152
80108dbb:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108dc0:	e9 14 f4 ff ff       	jmp    801081d9 <alltraps>

80108dc5 <vector153>:
.globl vector153
vector153:
  pushl $0
80108dc5:	6a 00                	push   $0x0
  pushl $153
80108dc7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108dcc:	e9 08 f4 ff ff       	jmp    801081d9 <alltraps>

80108dd1 <vector154>:
.globl vector154
vector154:
  pushl $0
80108dd1:	6a 00                	push   $0x0
  pushl $154
80108dd3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108dd8:	e9 fc f3 ff ff       	jmp    801081d9 <alltraps>

80108ddd <vector155>:
.globl vector155
vector155:
  pushl $0
80108ddd:	6a 00                	push   $0x0
  pushl $155
80108ddf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108de4:	e9 f0 f3 ff ff       	jmp    801081d9 <alltraps>

80108de9 <vector156>:
.globl vector156
vector156:
  pushl $0
80108de9:	6a 00                	push   $0x0
  pushl $156
80108deb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108df0:	e9 e4 f3 ff ff       	jmp    801081d9 <alltraps>

80108df5 <vector157>:
.globl vector157
vector157:
  pushl $0
80108df5:	6a 00                	push   $0x0
  pushl $157
80108df7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108dfc:	e9 d8 f3 ff ff       	jmp    801081d9 <alltraps>

80108e01 <vector158>:
.globl vector158
vector158:
  pushl $0
80108e01:	6a 00                	push   $0x0
  pushl $158
80108e03:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108e08:	e9 cc f3 ff ff       	jmp    801081d9 <alltraps>

80108e0d <vector159>:
.globl vector159
vector159:
  pushl $0
80108e0d:	6a 00                	push   $0x0
  pushl $159
80108e0f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108e14:	e9 c0 f3 ff ff       	jmp    801081d9 <alltraps>

80108e19 <vector160>:
.globl vector160
vector160:
  pushl $0
80108e19:	6a 00                	push   $0x0
  pushl $160
80108e1b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108e20:	e9 b4 f3 ff ff       	jmp    801081d9 <alltraps>

80108e25 <vector161>:
.globl vector161
vector161:
  pushl $0
80108e25:	6a 00                	push   $0x0
  pushl $161
80108e27:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108e2c:	e9 a8 f3 ff ff       	jmp    801081d9 <alltraps>

80108e31 <vector162>:
.globl vector162
vector162:
  pushl $0
80108e31:	6a 00                	push   $0x0
  pushl $162
80108e33:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108e38:	e9 9c f3 ff ff       	jmp    801081d9 <alltraps>

80108e3d <vector163>:
.globl vector163
vector163:
  pushl $0
80108e3d:	6a 00                	push   $0x0
  pushl $163
80108e3f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108e44:	e9 90 f3 ff ff       	jmp    801081d9 <alltraps>

80108e49 <vector164>:
.globl vector164
vector164:
  pushl $0
80108e49:	6a 00                	push   $0x0
  pushl $164
80108e4b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108e50:	e9 84 f3 ff ff       	jmp    801081d9 <alltraps>

80108e55 <vector165>:
.globl vector165
vector165:
  pushl $0
80108e55:	6a 00                	push   $0x0
  pushl $165
80108e57:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108e5c:	e9 78 f3 ff ff       	jmp    801081d9 <alltraps>

80108e61 <vector166>:
.globl vector166
vector166:
  pushl $0
80108e61:	6a 00                	push   $0x0
  pushl $166
80108e63:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108e68:	e9 6c f3 ff ff       	jmp    801081d9 <alltraps>

80108e6d <vector167>:
.globl vector167
vector167:
  pushl $0
80108e6d:	6a 00                	push   $0x0
  pushl $167
80108e6f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108e74:	e9 60 f3 ff ff       	jmp    801081d9 <alltraps>

80108e79 <vector168>:
.globl vector168
vector168:
  pushl $0
80108e79:	6a 00                	push   $0x0
  pushl $168
80108e7b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108e80:	e9 54 f3 ff ff       	jmp    801081d9 <alltraps>

80108e85 <vector169>:
.globl vector169
vector169:
  pushl $0
80108e85:	6a 00                	push   $0x0
  pushl $169
80108e87:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108e8c:	e9 48 f3 ff ff       	jmp    801081d9 <alltraps>

80108e91 <vector170>:
.globl vector170
vector170:
  pushl $0
80108e91:	6a 00                	push   $0x0
  pushl $170
80108e93:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108e98:	e9 3c f3 ff ff       	jmp    801081d9 <alltraps>

80108e9d <vector171>:
.globl vector171
vector171:
  pushl $0
80108e9d:	6a 00                	push   $0x0
  pushl $171
80108e9f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108ea4:	e9 30 f3 ff ff       	jmp    801081d9 <alltraps>

80108ea9 <vector172>:
.globl vector172
vector172:
  pushl $0
80108ea9:	6a 00                	push   $0x0
  pushl $172
80108eab:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108eb0:	e9 24 f3 ff ff       	jmp    801081d9 <alltraps>

80108eb5 <vector173>:
.globl vector173
vector173:
  pushl $0
80108eb5:	6a 00                	push   $0x0
  pushl $173
80108eb7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108ebc:	e9 18 f3 ff ff       	jmp    801081d9 <alltraps>

80108ec1 <vector174>:
.globl vector174
vector174:
  pushl $0
80108ec1:	6a 00                	push   $0x0
  pushl $174
80108ec3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108ec8:	e9 0c f3 ff ff       	jmp    801081d9 <alltraps>

80108ecd <vector175>:
.globl vector175
vector175:
  pushl $0
80108ecd:	6a 00                	push   $0x0
  pushl $175
80108ecf:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108ed4:	e9 00 f3 ff ff       	jmp    801081d9 <alltraps>

80108ed9 <vector176>:
.globl vector176
vector176:
  pushl $0
80108ed9:	6a 00                	push   $0x0
  pushl $176
80108edb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108ee0:	e9 f4 f2 ff ff       	jmp    801081d9 <alltraps>

80108ee5 <vector177>:
.globl vector177
vector177:
  pushl $0
80108ee5:	6a 00                	push   $0x0
  pushl $177
80108ee7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108eec:	e9 e8 f2 ff ff       	jmp    801081d9 <alltraps>

80108ef1 <vector178>:
.globl vector178
vector178:
  pushl $0
80108ef1:	6a 00                	push   $0x0
  pushl $178
80108ef3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108ef8:	e9 dc f2 ff ff       	jmp    801081d9 <alltraps>

80108efd <vector179>:
.globl vector179
vector179:
  pushl $0
80108efd:	6a 00                	push   $0x0
  pushl $179
80108eff:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108f04:	e9 d0 f2 ff ff       	jmp    801081d9 <alltraps>

80108f09 <vector180>:
.globl vector180
vector180:
  pushl $0
80108f09:	6a 00                	push   $0x0
  pushl $180
80108f0b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108f10:	e9 c4 f2 ff ff       	jmp    801081d9 <alltraps>

80108f15 <vector181>:
.globl vector181
vector181:
  pushl $0
80108f15:	6a 00                	push   $0x0
  pushl $181
80108f17:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108f1c:	e9 b8 f2 ff ff       	jmp    801081d9 <alltraps>

80108f21 <vector182>:
.globl vector182
vector182:
  pushl $0
80108f21:	6a 00                	push   $0x0
  pushl $182
80108f23:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108f28:	e9 ac f2 ff ff       	jmp    801081d9 <alltraps>

80108f2d <vector183>:
.globl vector183
vector183:
  pushl $0
80108f2d:	6a 00                	push   $0x0
  pushl $183
80108f2f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108f34:	e9 a0 f2 ff ff       	jmp    801081d9 <alltraps>

80108f39 <vector184>:
.globl vector184
vector184:
  pushl $0
80108f39:	6a 00                	push   $0x0
  pushl $184
80108f3b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108f40:	e9 94 f2 ff ff       	jmp    801081d9 <alltraps>

80108f45 <vector185>:
.globl vector185
vector185:
  pushl $0
80108f45:	6a 00                	push   $0x0
  pushl $185
80108f47:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108f4c:	e9 88 f2 ff ff       	jmp    801081d9 <alltraps>

80108f51 <vector186>:
.globl vector186
vector186:
  pushl $0
80108f51:	6a 00                	push   $0x0
  pushl $186
80108f53:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108f58:	e9 7c f2 ff ff       	jmp    801081d9 <alltraps>

80108f5d <vector187>:
.globl vector187
vector187:
  pushl $0
80108f5d:	6a 00                	push   $0x0
  pushl $187
80108f5f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108f64:	e9 70 f2 ff ff       	jmp    801081d9 <alltraps>

80108f69 <vector188>:
.globl vector188
vector188:
  pushl $0
80108f69:	6a 00                	push   $0x0
  pushl $188
80108f6b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108f70:	e9 64 f2 ff ff       	jmp    801081d9 <alltraps>

80108f75 <vector189>:
.globl vector189
vector189:
  pushl $0
80108f75:	6a 00                	push   $0x0
  pushl $189
80108f77:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108f7c:	e9 58 f2 ff ff       	jmp    801081d9 <alltraps>

80108f81 <vector190>:
.globl vector190
vector190:
  pushl $0
80108f81:	6a 00                	push   $0x0
  pushl $190
80108f83:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108f88:	e9 4c f2 ff ff       	jmp    801081d9 <alltraps>

80108f8d <vector191>:
.globl vector191
vector191:
  pushl $0
80108f8d:	6a 00                	push   $0x0
  pushl $191
80108f8f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108f94:	e9 40 f2 ff ff       	jmp    801081d9 <alltraps>

80108f99 <vector192>:
.globl vector192
vector192:
  pushl $0
80108f99:	6a 00                	push   $0x0
  pushl $192
80108f9b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108fa0:	e9 34 f2 ff ff       	jmp    801081d9 <alltraps>

80108fa5 <vector193>:
.globl vector193
vector193:
  pushl $0
80108fa5:	6a 00                	push   $0x0
  pushl $193
80108fa7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108fac:	e9 28 f2 ff ff       	jmp    801081d9 <alltraps>

80108fb1 <vector194>:
.globl vector194
vector194:
  pushl $0
80108fb1:	6a 00                	push   $0x0
  pushl $194
80108fb3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108fb8:	e9 1c f2 ff ff       	jmp    801081d9 <alltraps>

80108fbd <vector195>:
.globl vector195
vector195:
  pushl $0
80108fbd:	6a 00                	push   $0x0
  pushl $195
80108fbf:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108fc4:	e9 10 f2 ff ff       	jmp    801081d9 <alltraps>

80108fc9 <vector196>:
.globl vector196
vector196:
  pushl $0
80108fc9:	6a 00                	push   $0x0
  pushl $196
80108fcb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108fd0:	e9 04 f2 ff ff       	jmp    801081d9 <alltraps>

80108fd5 <vector197>:
.globl vector197
vector197:
  pushl $0
80108fd5:	6a 00                	push   $0x0
  pushl $197
80108fd7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108fdc:	e9 f8 f1 ff ff       	jmp    801081d9 <alltraps>

80108fe1 <vector198>:
.globl vector198
vector198:
  pushl $0
80108fe1:	6a 00                	push   $0x0
  pushl $198
80108fe3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108fe8:	e9 ec f1 ff ff       	jmp    801081d9 <alltraps>

80108fed <vector199>:
.globl vector199
vector199:
  pushl $0
80108fed:	6a 00                	push   $0x0
  pushl $199
80108fef:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108ff4:	e9 e0 f1 ff ff       	jmp    801081d9 <alltraps>

80108ff9 <vector200>:
.globl vector200
vector200:
  pushl $0
80108ff9:	6a 00                	push   $0x0
  pushl $200
80108ffb:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80109000:	e9 d4 f1 ff ff       	jmp    801081d9 <alltraps>

80109005 <vector201>:
.globl vector201
vector201:
  pushl $0
80109005:	6a 00                	push   $0x0
  pushl $201
80109007:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010900c:	e9 c8 f1 ff ff       	jmp    801081d9 <alltraps>

80109011 <vector202>:
.globl vector202
vector202:
  pushl $0
80109011:	6a 00                	push   $0x0
  pushl $202
80109013:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80109018:	e9 bc f1 ff ff       	jmp    801081d9 <alltraps>

8010901d <vector203>:
.globl vector203
vector203:
  pushl $0
8010901d:	6a 00                	push   $0x0
  pushl $203
8010901f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80109024:	e9 b0 f1 ff ff       	jmp    801081d9 <alltraps>

80109029 <vector204>:
.globl vector204
vector204:
  pushl $0
80109029:	6a 00                	push   $0x0
  pushl $204
8010902b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80109030:	e9 a4 f1 ff ff       	jmp    801081d9 <alltraps>

80109035 <vector205>:
.globl vector205
vector205:
  pushl $0
80109035:	6a 00                	push   $0x0
  pushl $205
80109037:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010903c:	e9 98 f1 ff ff       	jmp    801081d9 <alltraps>

80109041 <vector206>:
.globl vector206
vector206:
  pushl $0
80109041:	6a 00                	push   $0x0
  pushl $206
80109043:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80109048:	e9 8c f1 ff ff       	jmp    801081d9 <alltraps>

8010904d <vector207>:
.globl vector207
vector207:
  pushl $0
8010904d:	6a 00                	push   $0x0
  pushl $207
8010904f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80109054:	e9 80 f1 ff ff       	jmp    801081d9 <alltraps>

80109059 <vector208>:
.globl vector208
vector208:
  pushl $0
80109059:	6a 00                	push   $0x0
  pushl $208
8010905b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80109060:	e9 74 f1 ff ff       	jmp    801081d9 <alltraps>

80109065 <vector209>:
.globl vector209
vector209:
  pushl $0
80109065:	6a 00                	push   $0x0
  pushl $209
80109067:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010906c:	e9 68 f1 ff ff       	jmp    801081d9 <alltraps>

80109071 <vector210>:
.globl vector210
vector210:
  pushl $0
80109071:	6a 00                	push   $0x0
  pushl $210
80109073:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80109078:	e9 5c f1 ff ff       	jmp    801081d9 <alltraps>

8010907d <vector211>:
.globl vector211
vector211:
  pushl $0
8010907d:	6a 00                	push   $0x0
  pushl $211
8010907f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80109084:	e9 50 f1 ff ff       	jmp    801081d9 <alltraps>

80109089 <vector212>:
.globl vector212
vector212:
  pushl $0
80109089:	6a 00                	push   $0x0
  pushl $212
8010908b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80109090:	e9 44 f1 ff ff       	jmp    801081d9 <alltraps>

80109095 <vector213>:
.globl vector213
vector213:
  pushl $0
80109095:	6a 00                	push   $0x0
  pushl $213
80109097:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010909c:	e9 38 f1 ff ff       	jmp    801081d9 <alltraps>

801090a1 <vector214>:
.globl vector214
vector214:
  pushl $0
801090a1:	6a 00                	push   $0x0
  pushl $214
801090a3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801090a8:	e9 2c f1 ff ff       	jmp    801081d9 <alltraps>

801090ad <vector215>:
.globl vector215
vector215:
  pushl $0
801090ad:	6a 00                	push   $0x0
  pushl $215
801090af:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801090b4:	e9 20 f1 ff ff       	jmp    801081d9 <alltraps>

801090b9 <vector216>:
.globl vector216
vector216:
  pushl $0
801090b9:	6a 00                	push   $0x0
  pushl $216
801090bb:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801090c0:	e9 14 f1 ff ff       	jmp    801081d9 <alltraps>

801090c5 <vector217>:
.globl vector217
vector217:
  pushl $0
801090c5:	6a 00                	push   $0x0
  pushl $217
801090c7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801090cc:	e9 08 f1 ff ff       	jmp    801081d9 <alltraps>

801090d1 <vector218>:
.globl vector218
vector218:
  pushl $0
801090d1:	6a 00                	push   $0x0
  pushl $218
801090d3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801090d8:	e9 fc f0 ff ff       	jmp    801081d9 <alltraps>

801090dd <vector219>:
.globl vector219
vector219:
  pushl $0
801090dd:	6a 00                	push   $0x0
  pushl $219
801090df:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801090e4:	e9 f0 f0 ff ff       	jmp    801081d9 <alltraps>

801090e9 <vector220>:
.globl vector220
vector220:
  pushl $0
801090e9:	6a 00                	push   $0x0
  pushl $220
801090eb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801090f0:	e9 e4 f0 ff ff       	jmp    801081d9 <alltraps>

801090f5 <vector221>:
.globl vector221
vector221:
  pushl $0
801090f5:	6a 00                	push   $0x0
  pushl $221
801090f7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801090fc:	e9 d8 f0 ff ff       	jmp    801081d9 <alltraps>

80109101 <vector222>:
.globl vector222
vector222:
  pushl $0
80109101:	6a 00                	push   $0x0
  pushl $222
80109103:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80109108:	e9 cc f0 ff ff       	jmp    801081d9 <alltraps>

8010910d <vector223>:
.globl vector223
vector223:
  pushl $0
8010910d:	6a 00                	push   $0x0
  pushl $223
8010910f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80109114:	e9 c0 f0 ff ff       	jmp    801081d9 <alltraps>

80109119 <vector224>:
.globl vector224
vector224:
  pushl $0
80109119:	6a 00                	push   $0x0
  pushl $224
8010911b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80109120:	e9 b4 f0 ff ff       	jmp    801081d9 <alltraps>

80109125 <vector225>:
.globl vector225
vector225:
  pushl $0
80109125:	6a 00                	push   $0x0
  pushl $225
80109127:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010912c:	e9 a8 f0 ff ff       	jmp    801081d9 <alltraps>

80109131 <vector226>:
.globl vector226
vector226:
  pushl $0
80109131:	6a 00                	push   $0x0
  pushl $226
80109133:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80109138:	e9 9c f0 ff ff       	jmp    801081d9 <alltraps>

8010913d <vector227>:
.globl vector227
vector227:
  pushl $0
8010913d:	6a 00                	push   $0x0
  pushl $227
8010913f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80109144:	e9 90 f0 ff ff       	jmp    801081d9 <alltraps>

80109149 <vector228>:
.globl vector228
vector228:
  pushl $0
80109149:	6a 00                	push   $0x0
  pushl $228
8010914b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80109150:	e9 84 f0 ff ff       	jmp    801081d9 <alltraps>

80109155 <vector229>:
.globl vector229
vector229:
  pushl $0
80109155:	6a 00                	push   $0x0
  pushl $229
80109157:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010915c:	e9 78 f0 ff ff       	jmp    801081d9 <alltraps>

80109161 <vector230>:
.globl vector230
vector230:
  pushl $0
80109161:	6a 00                	push   $0x0
  pushl $230
80109163:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80109168:	e9 6c f0 ff ff       	jmp    801081d9 <alltraps>

8010916d <vector231>:
.globl vector231
vector231:
  pushl $0
8010916d:	6a 00                	push   $0x0
  pushl $231
8010916f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80109174:	e9 60 f0 ff ff       	jmp    801081d9 <alltraps>

80109179 <vector232>:
.globl vector232
vector232:
  pushl $0
80109179:	6a 00                	push   $0x0
  pushl $232
8010917b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80109180:	e9 54 f0 ff ff       	jmp    801081d9 <alltraps>

80109185 <vector233>:
.globl vector233
vector233:
  pushl $0
80109185:	6a 00                	push   $0x0
  pushl $233
80109187:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010918c:	e9 48 f0 ff ff       	jmp    801081d9 <alltraps>

80109191 <vector234>:
.globl vector234
vector234:
  pushl $0
80109191:	6a 00                	push   $0x0
  pushl $234
80109193:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80109198:	e9 3c f0 ff ff       	jmp    801081d9 <alltraps>

8010919d <vector235>:
.globl vector235
vector235:
  pushl $0
8010919d:	6a 00                	push   $0x0
  pushl $235
8010919f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801091a4:	e9 30 f0 ff ff       	jmp    801081d9 <alltraps>

801091a9 <vector236>:
.globl vector236
vector236:
  pushl $0
801091a9:	6a 00                	push   $0x0
  pushl $236
801091ab:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801091b0:	e9 24 f0 ff ff       	jmp    801081d9 <alltraps>

801091b5 <vector237>:
.globl vector237
vector237:
  pushl $0
801091b5:	6a 00                	push   $0x0
  pushl $237
801091b7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801091bc:	e9 18 f0 ff ff       	jmp    801081d9 <alltraps>

801091c1 <vector238>:
.globl vector238
vector238:
  pushl $0
801091c1:	6a 00                	push   $0x0
  pushl $238
801091c3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801091c8:	e9 0c f0 ff ff       	jmp    801081d9 <alltraps>

801091cd <vector239>:
.globl vector239
vector239:
  pushl $0
801091cd:	6a 00                	push   $0x0
  pushl $239
801091cf:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801091d4:	e9 00 f0 ff ff       	jmp    801081d9 <alltraps>

801091d9 <vector240>:
.globl vector240
vector240:
  pushl $0
801091d9:	6a 00                	push   $0x0
  pushl $240
801091db:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801091e0:	e9 f4 ef ff ff       	jmp    801081d9 <alltraps>

801091e5 <vector241>:
.globl vector241
vector241:
  pushl $0
801091e5:	6a 00                	push   $0x0
  pushl $241
801091e7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801091ec:	e9 e8 ef ff ff       	jmp    801081d9 <alltraps>

801091f1 <vector242>:
.globl vector242
vector242:
  pushl $0
801091f1:	6a 00                	push   $0x0
  pushl $242
801091f3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801091f8:	e9 dc ef ff ff       	jmp    801081d9 <alltraps>

801091fd <vector243>:
.globl vector243
vector243:
  pushl $0
801091fd:	6a 00                	push   $0x0
  pushl $243
801091ff:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80109204:	e9 d0 ef ff ff       	jmp    801081d9 <alltraps>

80109209 <vector244>:
.globl vector244
vector244:
  pushl $0
80109209:	6a 00                	push   $0x0
  pushl $244
8010920b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80109210:	e9 c4 ef ff ff       	jmp    801081d9 <alltraps>

80109215 <vector245>:
.globl vector245
vector245:
  pushl $0
80109215:	6a 00                	push   $0x0
  pushl $245
80109217:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010921c:	e9 b8 ef ff ff       	jmp    801081d9 <alltraps>

80109221 <vector246>:
.globl vector246
vector246:
  pushl $0
80109221:	6a 00                	push   $0x0
  pushl $246
80109223:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109228:	e9 ac ef ff ff       	jmp    801081d9 <alltraps>

8010922d <vector247>:
.globl vector247
vector247:
  pushl $0
8010922d:	6a 00                	push   $0x0
  pushl $247
8010922f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80109234:	e9 a0 ef ff ff       	jmp    801081d9 <alltraps>

80109239 <vector248>:
.globl vector248
vector248:
  pushl $0
80109239:	6a 00                	push   $0x0
  pushl $248
8010923b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80109240:	e9 94 ef ff ff       	jmp    801081d9 <alltraps>

80109245 <vector249>:
.globl vector249
vector249:
  pushl $0
80109245:	6a 00                	push   $0x0
  pushl $249
80109247:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010924c:	e9 88 ef ff ff       	jmp    801081d9 <alltraps>

80109251 <vector250>:
.globl vector250
vector250:
  pushl $0
80109251:	6a 00                	push   $0x0
  pushl $250
80109253:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80109258:	e9 7c ef ff ff       	jmp    801081d9 <alltraps>

8010925d <vector251>:
.globl vector251
vector251:
  pushl $0
8010925d:	6a 00                	push   $0x0
  pushl $251
8010925f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80109264:	e9 70 ef ff ff       	jmp    801081d9 <alltraps>

80109269 <vector252>:
.globl vector252
vector252:
  pushl $0
80109269:	6a 00                	push   $0x0
  pushl $252
8010926b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80109270:	e9 64 ef ff ff       	jmp    801081d9 <alltraps>

80109275 <vector253>:
.globl vector253
vector253:
  pushl $0
80109275:	6a 00                	push   $0x0
  pushl $253
80109277:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010927c:	e9 58 ef ff ff       	jmp    801081d9 <alltraps>

80109281 <vector254>:
.globl vector254
vector254:
  pushl $0
80109281:	6a 00                	push   $0x0
  pushl $254
80109283:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80109288:	e9 4c ef ff ff       	jmp    801081d9 <alltraps>

8010928d <vector255>:
.globl vector255
vector255:
  pushl $0
8010928d:	6a 00                	push   $0x0
  pushl $255
8010928f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80109294:	e9 40 ef ff ff       	jmp    801081d9 <alltraps>

80109299 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80109299:	55                   	push   %ebp
8010929a:	89 e5                	mov    %esp,%ebp
8010929c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010929f:	8b 45 0c             	mov    0xc(%ebp),%eax
801092a2:	83 e8 01             	sub    $0x1,%eax
801092a5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801092a9:	8b 45 08             	mov    0x8(%ebp),%eax
801092ac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801092b0:	8b 45 08             	mov    0x8(%ebp),%eax
801092b3:	c1 e8 10             	shr    $0x10,%eax
801092b6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801092ba:	8d 45 fa             	lea    -0x6(%ebp),%eax
801092bd:	0f 01 10             	lgdtl  (%eax)
}
801092c0:	90                   	nop
801092c1:	c9                   	leave  
801092c2:	c3                   	ret    

801092c3 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801092c3:	55                   	push   %ebp
801092c4:	89 e5                	mov    %esp,%ebp
801092c6:	83 ec 04             	sub    $0x4,%esp
801092c9:	8b 45 08             	mov    0x8(%ebp),%eax
801092cc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801092d0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801092d4:	0f 00 d8             	ltr    %ax
}
801092d7:	90                   	nop
801092d8:	c9                   	leave  
801092d9:	c3                   	ret    

801092da <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801092da:	55                   	push   %ebp
801092db:	89 e5                	mov    %esp,%ebp
801092dd:	83 ec 04             	sub    $0x4,%esp
801092e0:	8b 45 08             	mov    0x8(%ebp),%eax
801092e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801092e7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801092eb:	8e e8                	mov    %eax,%gs
}
801092ed:	90                   	nop
801092ee:	c9                   	leave  
801092ef:	c3                   	ret    

801092f0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801092f0:	55                   	push   %ebp
801092f1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801092f3:	8b 45 08             	mov    0x8(%ebp),%eax
801092f6:	0f 22 d8             	mov    %eax,%cr3
}
801092f9:	90                   	nop
801092fa:	5d                   	pop    %ebp
801092fb:	c3                   	ret    

801092fc <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801092fc:	55                   	push   %ebp
801092fd:	89 e5                	mov    %esp,%ebp
801092ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109302:	05 00 00 00 80       	add    $0x80000000,%eax
80109307:	5d                   	pop    %ebp
80109308:	c3                   	ret    

80109309 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80109309:	55                   	push   %ebp
8010930a:	89 e5                	mov    %esp,%ebp
8010930c:	8b 45 08             	mov    0x8(%ebp),%eax
8010930f:	05 00 00 00 80       	add    $0x80000000,%eax
80109314:	5d                   	pop    %ebp
80109315:	c3                   	ret    

80109316 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109316:	55                   	push   %ebp
80109317:	89 e5                	mov    %esp,%ebp
80109319:	53                   	push   %ebx
8010931a:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010931d:	e8 ed 9f ff ff       	call   8010330f <cpunum>
80109322:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109328:	05 a0 43 11 80       	add    $0x801143a0,%eax
8010932d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80109330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109333:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80109339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80109342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109345:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80109349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109350:	83 e2 f0             	and    $0xfffffff0,%edx
80109353:	83 ca 0a             	or     $0xa,%edx
80109356:	88 50 7d             	mov    %dl,0x7d(%eax)
80109359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010935c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80109360:	83 ca 10             	or     $0x10,%edx
80109363:	88 50 7d             	mov    %dl,0x7d(%eax)
80109366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109369:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010936d:	83 e2 9f             	and    $0xffffff9f,%edx
80109370:	88 50 7d             	mov    %dl,0x7d(%eax)
80109373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109376:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010937a:	83 ca 80             	or     $0xffffff80,%edx
8010937d:	88 50 7d             	mov    %dl,0x7d(%eax)
80109380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109383:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109387:	83 ca 0f             	or     $0xf,%edx
8010938a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010938d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109390:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109394:	83 e2 ef             	and    $0xffffffef,%edx
80109397:	88 50 7e             	mov    %dl,0x7e(%eax)
8010939a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801093a1:	83 e2 df             	and    $0xffffffdf,%edx
801093a4:	88 50 7e             	mov    %dl,0x7e(%eax)
801093a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801093ae:	83 ca 40             	or     $0x40,%edx
801093b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801093b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801093bb:	83 ca 80             	or     $0xffffff80,%edx
801093be:	88 50 7e             	mov    %dl,0x7e(%eax)
801093c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c4:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801093c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093cb:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801093d2:	ff ff 
801093d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d7:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801093de:	00 00 
801093e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e3:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801093ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ed:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801093f4:	83 e2 f0             	and    $0xfffffff0,%edx
801093f7:	83 ca 02             	or     $0x2,%edx
801093fa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109403:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010940a:	83 ca 10             	or     $0x10,%edx
8010940d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109416:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010941d:	83 e2 9f             	and    $0xffffff9f,%edx
80109420:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109429:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109430:	83 ca 80             	or     $0xffffff80,%edx
80109433:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109443:	83 ca 0f             	or     $0xf,%edx
80109446:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010944c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010944f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109456:	83 e2 ef             	and    $0xffffffef,%edx
80109459:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010945f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109462:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80109469:	83 e2 df             	and    $0xffffffdf,%edx
8010946c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109475:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010947c:	83 ca 40             	or     $0x40,%edx
8010947f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109488:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010948f:	83 ca 80             	or     $0xffffff80,%edx
80109492:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80109498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801094a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a5:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801094ac:	ff ff 
801094ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b1:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801094b8:	00 00 
801094ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bd:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801094c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801094ce:	83 e2 f0             	and    $0xfffffff0,%edx
801094d1:	83 ca 0a             	or     $0xa,%edx
801094d4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801094da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094dd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801094e4:	83 ca 10             	or     $0x10,%edx
801094e7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801094ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801094f7:	83 ca 60             	or     $0x60,%edx
801094fa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109503:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010950a:	83 ca 80             	or     $0xffffff80,%edx
8010950d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109516:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010951d:	83 ca 0f             	or     $0xf,%edx
80109520:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109529:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109530:	83 e2 ef             	and    $0xffffffef,%edx
80109533:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109543:	83 e2 df             	and    $0xffffffdf,%edx
80109546:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010954c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109556:	83 ca 40             	or     $0x40,%edx
80109559:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010955f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109562:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80109569:	83 ca 80             	or     $0xffffff80,%edx
8010956c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109575:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010957c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957f:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80109586:	ff ff 
80109588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958b:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80109592:	00 00 
80109594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109597:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010959e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801095a8:	83 e2 f0             	and    $0xfffffff0,%edx
801095ab:	83 ca 02             	or     $0x2,%edx
801095ae:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801095be:	83 ca 10             	or     $0x10,%edx
801095c1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801095c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ca:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801095d1:	83 ca 60             	or     $0x60,%edx
801095d4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801095da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095dd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801095e4:	83 ca 80             	or     $0xffffff80,%edx
801095e7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801095ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801095f7:	83 ca 0f             	or     $0xf,%edx
801095fa:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109603:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010960a:	83 e2 ef             	and    $0xffffffef,%edx
8010960d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109616:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010961d:	83 e2 df             	and    $0xffffffdf,%edx
80109620:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109629:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109630:	83 ca 40             	or     $0x40,%edx
80109633:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109643:	83 ca 80             	or     $0xffffff80,%edx
80109646:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010964c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964f:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80109656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109659:	05 b4 00 00 00       	add    $0xb4,%eax
8010965e:	89 c3                	mov    %eax,%ebx
80109660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109663:	05 b4 00 00 00       	add    $0xb4,%eax
80109668:	c1 e8 10             	shr    $0x10,%eax
8010966b:	89 c2                	mov    %eax,%edx
8010966d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109670:	05 b4 00 00 00       	add    $0xb4,%eax
80109675:	c1 e8 18             	shr    $0x18,%eax
80109678:	89 c1                	mov    %eax,%ecx
8010967a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967d:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80109684:	00 00 
80109686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109689:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80109690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109693:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80109699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801096a3:	83 e2 f0             	and    $0xfffffff0,%edx
801096a6:	83 ca 02             	or     $0x2,%edx
801096a9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801096af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801096b9:	83 ca 10             	or     $0x10,%edx
801096bc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801096c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801096cc:	83 e2 9f             	and    $0xffffff9f,%edx
801096cf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801096d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801096df:	83 ca 80             	or     $0xffffff80,%edx
801096e2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801096e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096eb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801096f2:	83 e2 f0             	and    $0xfffffff0,%edx
801096f5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801096fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109705:	83 e2 ef             	and    $0xffffffef,%edx
80109708:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010970e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109711:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109718:	83 e2 df             	and    $0xffffffdf,%edx
8010971b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109724:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010972b:	83 ca 40             	or     $0x40,%edx
8010972e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109737:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010973e:	83 ca 80             	or     $0xffffff80,%edx
80109741:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974a:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80109750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109753:	83 c0 70             	add    $0x70,%eax
80109756:	83 ec 08             	sub    $0x8,%esp
80109759:	6a 38                	push   $0x38
8010975b:	50                   	push   %eax
8010975c:	e8 38 fb ff ff       	call   80109299 <lgdt>
80109761:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80109764:	83 ec 0c             	sub    $0xc,%esp
80109767:	6a 18                	push   $0x18
80109769:	e8 6c fb ff ff       	call   801092da <loadgs>
8010976e:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80109771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109774:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010977a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80109781:	00 00 00 00 
}
80109785:	90                   	nop
80109786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109789:	c9                   	leave  
8010978a:	c3                   	ret    

8010978b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010978b:	55                   	push   %ebp
8010978c:	89 e5                	mov    %esp,%ebp
8010978e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80109791:	8b 45 0c             	mov    0xc(%ebp),%eax
80109794:	c1 e8 16             	shr    $0x16,%eax
80109797:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010979e:	8b 45 08             	mov    0x8(%ebp),%eax
801097a1:	01 d0                	add    %edx,%eax
801097a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801097a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a9:	8b 00                	mov    (%eax),%eax
801097ab:	83 e0 01             	and    $0x1,%eax
801097ae:	85 c0                	test   %eax,%eax
801097b0:	74 18                	je     801097ca <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801097b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b5:	8b 00                	mov    (%eax),%eax
801097b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801097bc:	50                   	push   %eax
801097bd:	e8 47 fb ff ff       	call   80109309 <p2v>
801097c2:	83 c4 04             	add    $0x4,%esp
801097c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801097c8:	eb 48                	jmp    80109812 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801097ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801097ce:	74 0e                	je     801097de <walkpgdir+0x53>
801097d0:	e8 d4 97 ff ff       	call   80102fa9 <kalloc>
801097d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801097d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801097dc:	75 07                	jne    801097e5 <walkpgdir+0x5a>
      return 0;
801097de:	b8 00 00 00 00       	mov    $0x0,%eax
801097e3:	eb 44                	jmp    80109829 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801097e5:	83 ec 04             	sub    $0x4,%esp
801097e8:	68 00 10 00 00       	push   $0x1000
801097ed:	6a 00                	push   $0x0
801097ef:	ff 75 f4             	pushl  -0xc(%ebp)
801097f2:	e8 55 d3 ff ff       	call   80106b4c <memset>
801097f7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801097fa:	83 ec 0c             	sub    $0xc,%esp
801097fd:	ff 75 f4             	pushl  -0xc(%ebp)
80109800:	e8 f7 fa ff ff       	call   801092fc <v2p>
80109805:	83 c4 10             	add    $0x10,%esp
80109808:	83 c8 07             	or     $0x7,%eax
8010980b:	89 c2                	mov    %eax,%edx
8010980d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109810:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109812:	8b 45 0c             	mov    0xc(%ebp),%eax
80109815:	c1 e8 0c             	shr    $0xc,%eax
80109818:	25 ff 03 00 00       	and    $0x3ff,%eax
8010981d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109827:	01 d0                	add    %edx,%eax
}
80109829:	c9                   	leave  
8010982a:	c3                   	ret    

8010982b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010982b:	55                   	push   %ebp
8010982c:	89 e5                	mov    %esp,%ebp
8010982e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109831:	8b 45 0c             	mov    0xc(%ebp),%eax
80109834:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109839:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010983c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010983f:	8b 45 10             	mov    0x10(%ebp),%eax
80109842:	01 d0                	add    %edx,%eax
80109844:	83 e8 01             	sub    $0x1,%eax
80109847:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010984c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010984f:	83 ec 04             	sub    $0x4,%esp
80109852:	6a 01                	push   $0x1
80109854:	ff 75 f4             	pushl  -0xc(%ebp)
80109857:	ff 75 08             	pushl  0x8(%ebp)
8010985a:	e8 2c ff ff ff       	call   8010978b <walkpgdir>
8010985f:	83 c4 10             	add    $0x10,%esp
80109862:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109865:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109869:	75 07                	jne    80109872 <mappages+0x47>
      return -1;
8010986b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109870:	eb 47                	jmp    801098b9 <mappages+0x8e>
    if(*pte & PTE_P)
80109872:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109875:	8b 00                	mov    (%eax),%eax
80109877:	83 e0 01             	and    $0x1,%eax
8010987a:	85 c0                	test   %eax,%eax
8010987c:	74 0d                	je     8010988b <mappages+0x60>
      panic("remap");
8010987e:	83 ec 0c             	sub    $0xc,%esp
80109881:	68 48 a8 10 80       	push   $0x8010a848
80109886:	e8 db 6c ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
8010988b:	8b 45 18             	mov    0x18(%ebp),%eax
8010988e:	0b 45 14             	or     0x14(%ebp),%eax
80109891:	83 c8 01             	or     $0x1,%eax
80109894:	89 c2                	mov    %eax,%edx
80109896:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109899:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010989b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801098a1:	74 10                	je     801098b3 <mappages+0x88>
      break;
    a += PGSIZE;
801098a3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801098aa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801098b1:	eb 9c                	jmp    8010984f <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801098b3:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801098b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801098b9:	c9                   	leave  
801098ba:	c3                   	ret    

801098bb <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801098bb:	55                   	push   %ebp
801098bc:	89 e5                	mov    %esp,%ebp
801098be:	53                   	push   %ebx
801098bf:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801098c2:	e8 e2 96 ff ff       	call   80102fa9 <kalloc>
801098c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801098ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801098ce:	75 0a                	jne    801098da <setupkvm+0x1f>
    return 0;
801098d0:	b8 00 00 00 00       	mov    $0x0,%eax
801098d5:	e9 8e 00 00 00       	jmp    80109968 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801098da:	83 ec 04             	sub    $0x4,%esp
801098dd:	68 00 10 00 00       	push   $0x1000
801098e2:	6a 00                	push   $0x0
801098e4:	ff 75 f0             	pushl  -0x10(%ebp)
801098e7:	e8 60 d2 ff ff       	call   80106b4c <memset>
801098ec:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801098ef:	83 ec 0c             	sub    $0xc,%esp
801098f2:	68 00 00 00 0e       	push   $0xe000000
801098f7:	e8 0d fa ff ff       	call   80109309 <p2v>
801098fc:	83 c4 10             	add    $0x10,%esp
801098ff:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109904:	76 0d                	jbe    80109913 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109906:	83 ec 0c             	sub    $0xc,%esp
80109909:	68 4e a8 10 80       	push   $0x8010a84e
8010990e:	e8 53 6c ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109913:	c7 45 f4 e0 d4 10 80 	movl   $0x8010d4e0,-0xc(%ebp)
8010991a:	eb 40                	jmp    8010995c <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010991c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010991f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109925:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992b:	8b 58 08             	mov    0x8(%eax),%ebx
8010992e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109931:	8b 40 04             	mov    0x4(%eax),%eax
80109934:	29 c3                	sub    %eax,%ebx
80109936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109939:	8b 00                	mov    (%eax),%eax
8010993b:	83 ec 0c             	sub    $0xc,%esp
8010993e:	51                   	push   %ecx
8010993f:	52                   	push   %edx
80109940:	53                   	push   %ebx
80109941:	50                   	push   %eax
80109942:	ff 75 f0             	pushl  -0x10(%ebp)
80109945:	e8 e1 fe ff ff       	call   8010982b <mappages>
8010994a:	83 c4 20             	add    $0x20,%esp
8010994d:	85 c0                	test   %eax,%eax
8010994f:	79 07                	jns    80109958 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109951:	b8 00 00 00 00       	mov    $0x0,%eax
80109956:	eb 10                	jmp    80109968 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109958:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010995c:	81 7d f4 20 d5 10 80 	cmpl   $0x8010d520,-0xc(%ebp)
80109963:	72 b7                	jb     8010991c <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109965:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010996b:	c9                   	leave  
8010996c:	c3                   	ret    

8010996d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010996d:	55                   	push   %ebp
8010996e:	89 e5                	mov    %esp,%ebp
80109970:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109973:	e8 43 ff ff ff       	call   801098bb <setupkvm>
80109978:	a3 78 79 11 80       	mov    %eax,0x80117978
  switchkvm();
8010997d:	e8 03 00 00 00       	call   80109985 <switchkvm>
}
80109982:	90                   	nop
80109983:	c9                   	leave  
80109984:	c3                   	ret    

80109985 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109985:	55                   	push   %ebp
80109986:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80109988:	a1 78 79 11 80       	mov    0x80117978,%eax
8010998d:	50                   	push   %eax
8010998e:	e8 69 f9 ff ff       	call   801092fc <v2p>
80109993:	83 c4 04             	add    $0x4,%esp
80109996:	50                   	push   %eax
80109997:	e8 54 f9 ff ff       	call   801092f0 <lcr3>
8010999c:	83 c4 04             	add    $0x4,%esp
}
8010999f:	90                   	nop
801099a0:	c9                   	leave  
801099a1:	c3                   	ret    

801099a2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801099a2:	55                   	push   %ebp
801099a3:	89 e5                	mov    %esp,%ebp
801099a5:	56                   	push   %esi
801099a6:	53                   	push   %ebx
  pushcli();
801099a7:	e8 9a d0 ff ff       	call   80106a46 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801099ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801099b2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801099b9:	83 c2 08             	add    $0x8,%edx
801099bc:	89 d6                	mov    %edx,%esi
801099be:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801099c5:	83 c2 08             	add    $0x8,%edx
801099c8:	c1 ea 10             	shr    $0x10,%edx
801099cb:	89 d3                	mov    %edx,%ebx
801099cd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801099d4:	83 c2 08             	add    $0x8,%edx
801099d7:	c1 ea 18             	shr    $0x18,%edx
801099da:	89 d1                	mov    %edx,%ecx
801099dc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801099e3:	67 00 
801099e5:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801099ec:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801099f2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801099f9:	83 e2 f0             	and    $0xfffffff0,%edx
801099fc:	83 ca 09             	or     $0x9,%edx
801099ff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109a05:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109a0c:	83 ca 10             	or     $0x10,%edx
80109a0f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109a15:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109a1c:	83 e2 9f             	and    $0xffffff9f,%edx
80109a1f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109a25:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109a2c:	83 ca 80             	or     $0xffffff80,%edx
80109a2f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109a35:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109a3c:	83 e2 f0             	and    $0xfffffff0,%edx
80109a3f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109a45:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109a4c:	83 e2 ef             	and    $0xffffffef,%edx
80109a4f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109a55:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109a5c:	83 e2 df             	and    $0xffffffdf,%edx
80109a5f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109a65:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109a6c:	83 ca 40             	or     $0x40,%edx
80109a6f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109a75:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109a7c:	83 e2 7f             	and    $0x7f,%edx
80109a7f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109a85:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80109a8b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109a91:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109a98:	83 e2 ef             	and    $0xffffffef,%edx
80109a9b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109aa1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109aa7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109aad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109ab3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109aba:	8b 52 08             	mov    0x8(%edx),%edx
80109abd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109ac3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109ac6:	83 ec 0c             	sub    $0xc,%esp
80109ac9:	6a 30                	push   $0x30
80109acb:	e8 f3 f7 ff ff       	call   801092c3 <ltr>
80109ad0:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad6:	8b 40 04             	mov    0x4(%eax),%eax
80109ad9:	85 c0                	test   %eax,%eax
80109adb:	75 0d                	jne    80109aea <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80109add:	83 ec 0c             	sub    $0xc,%esp
80109ae0:	68 5f a8 10 80       	push   $0x8010a85f
80109ae5:	e8 7c 6a ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80109aea:	8b 45 08             	mov    0x8(%ebp),%eax
80109aed:	8b 40 04             	mov    0x4(%eax),%eax
80109af0:	83 ec 0c             	sub    $0xc,%esp
80109af3:	50                   	push   %eax
80109af4:	e8 03 f8 ff ff       	call   801092fc <v2p>
80109af9:	83 c4 10             	add    $0x10,%esp
80109afc:	83 ec 0c             	sub    $0xc,%esp
80109aff:	50                   	push   %eax
80109b00:	e8 eb f7 ff ff       	call   801092f0 <lcr3>
80109b05:	83 c4 10             	add    $0x10,%esp
  popcli();
80109b08:	e8 7e cf ff ff       	call   80106a8b <popcli>
}
80109b0d:	90                   	nop
80109b0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109b11:	5b                   	pop    %ebx
80109b12:	5e                   	pop    %esi
80109b13:	5d                   	pop    %ebp
80109b14:	c3                   	ret    

80109b15 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109b15:	55                   	push   %ebp
80109b16:	89 e5                	mov    %esp,%ebp
80109b18:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80109b1b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109b22:	76 0d                	jbe    80109b31 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109b24:	83 ec 0c             	sub    $0xc,%esp
80109b27:	68 73 a8 10 80       	push   $0x8010a873
80109b2c:	e8 35 6a ff ff       	call   80100566 <panic>
  mem = kalloc();
80109b31:	e8 73 94 ff ff       	call   80102fa9 <kalloc>
80109b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80109b39:	83 ec 04             	sub    $0x4,%esp
80109b3c:	68 00 10 00 00       	push   $0x1000
80109b41:	6a 00                	push   $0x0
80109b43:	ff 75 f4             	pushl  -0xc(%ebp)
80109b46:	e8 01 d0 ff ff       	call   80106b4c <memset>
80109b4b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109b4e:	83 ec 0c             	sub    $0xc,%esp
80109b51:	ff 75 f4             	pushl  -0xc(%ebp)
80109b54:	e8 a3 f7 ff ff       	call   801092fc <v2p>
80109b59:	83 c4 10             	add    $0x10,%esp
80109b5c:	83 ec 0c             	sub    $0xc,%esp
80109b5f:	6a 06                	push   $0x6
80109b61:	50                   	push   %eax
80109b62:	68 00 10 00 00       	push   $0x1000
80109b67:	6a 00                	push   $0x0
80109b69:	ff 75 08             	pushl  0x8(%ebp)
80109b6c:	e8 ba fc ff ff       	call   8010982b <mappages>
80109b71:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80109b74:	83 ec 04             	sub    $0x4,%esp
80109b77:	ff 75 10             	pushl  0x10(%ebp)
80109b7a:	ff 75 0c             	pushl  0xc(%ebp)
80109b7d:	ff 75 f4             	pushl  -0xc(%ebp)
80109b80:	e8 86 d0 ff ff       	call   80106c0b <memmove>
80109b85:	83 c4 10             	add    $0x10,%esp
}
80109b88:	90                   	nop
80109b89:	c9                   	leave  
80109b8a:	c3                   	ret    

80109b8b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80109b8b:	55                   	push   %ebp
80109b8c:	89 e5                	mov    %esp,%ebp
80109b8e:	53                   	push   %ebx
80109b8f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80109b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b95:	25 ff 0f 00 00       	and    $0xfff,%eax
80109b9a:	85 c0                	test   %eax,%eax
80109b9c:	74 0d                	je     80109bab <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80109b9e:	83 ec 0c             	sub    $0xc,%esp
80109ba1:	68 90 a8 10 80       	push   $0x8010a890
80109ba6:	e8 bb 69 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80109bab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109bb2:	e9 95 00 00 00       	jmp    80109c4c <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80109bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbd:	01 d0                	add    %edx,%eax
80109bbf:	83 ec 04             	sub    $0x4,%esp
80109bc2:	6a 00                	push   $0x0
80109bc4:	50                   	push   %eax
80109bc5:	ff 75 08             	pushl  0x8(%ebp)
80109bc8:	e8 be fb ff ff       	call   8010978b <walkpgdir>
80109bcd:	83 c4 10             	add    $0x10,%esp
80109bd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109bd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109bd7:	75 0d                	jne    80109be6 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109bd9:	83 ec 0c             	sub    $0xc,%esp
80109bdc:	68 b3 a8 10 80       	push   $0x8010a8b3
80109be1:	e8 80 69 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109be6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109be9:	8b 00                	mov    (%eax),%eax
80109beb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109bf3:	8b 45 18             	mov    0x18(%ebp),%eax
80109bf6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109bf9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109bfe:	77 0b                	ja     80109c0b <loaduvm+0x80>
      n = sz - i;
80109c00:	8b 45 18             	mov    0x18(%ebp),%eax
80109c03:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109c09:	eb 07                	jmp    80109c12 <loaduvm+0x87>
    else
      n = PGSIZE;
80109c0b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109c12:	8b 55 14             	mov    0x14(%ebp),%edx
80109c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c18:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109c1b:	83 ec 0c             	sub    $0xc,%esp
80109c1e:	ff 75 e8             	pushl  -0x18(%ebp)
80109c21:	e8 e3 f6 ff ff       	call   80109309 <p2v>
80109c26:	83 c4 10             	add    $0x10,%esp
80109c29:	ff 75 f0             	pushl  -0x10(%ebp)
80109c2c:	53                   	push   %ebx
80109c2d:	50                   	push   %eax
80109c2e:	ff 75 10             	pushl  0x10(%ebp)
80109c31:	e8 6b 84 ff ff       	call   801020a1 <readi>
80109c36:	83 c4 10             	add    $0x10,%esp
80109c39:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109c3c:	74 07                	je     80109c45 <loaduvm+0xba>
      return -1;
80109c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109c43:	eb 18                	jmp    80109c5d <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109c45:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c4f:	3b 45 18             	cmp    0x18(%ebp),%eax
80109c52:	0f 82 5f ff ff ff    	jb     80109bb7 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109c58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c60:	c9                   	leave  
80109c61:	c3                   	ret    

80109c62 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109c62:	55                   	push   %ebp
80109c63:	89 e5                	mov    %esp,%ebp
80109c65:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109c68:	8b 45 10             	mov    0x10(%ebp),%eax
80109c6b:	85 c0                	test   %eax,%eax
80109c6d:	79 0a                	jns    80109c79 <allocuvm+0x17>
    return 0;
80109c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80109c74:	e9 b0 00 00 00       	jmp    80109d29 <allocuvm+0xc7>
  if(newsz < oldsz)
80109c79:	8b 45 10             	mov    0x10(%ebp),%eax
80109c7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109c7f:	73 08                	jae    80109c89 <allocuvm+0x27>
    return oldsz;
80109c81:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c84:	e9 a0 00 00 00       	jmp    80109d29 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c8c:	05 ff 0f 00 00       	add    $0xfff,%eax
80109c91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109c99:	eb 7f                	jmp    80109d1a <allocuvm+0xb8>
    mem = kalloc();
80109c9b:	e8 09 93 ff ff       	call   80102fa9 <kalloc>
80109ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109ca3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109ca7:	75 2b                	jne    80109cd4 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109ca9:	83 ec 0c             	sub    $0xc,%esp
80109cac:	68 d1 a8 10 80       	push   $0x8010a8d1
80109cb1:	e8 10 67 ff ff       	call   801003c6 <cprintf>
80109cb6:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109cb9:	83 ec 04             	sub    $0x4,%esp
80109cbc:	ff 75 0c             	pushl  0xc(%ebp)
80109cbf:	ff 75 10             	pushl  0x10(%ebp)
80109cc2:	ff 75 08             	pushl  0x8(%ebp)
80109cc5:	e8 61 00 00 00       	call   80109d2b <deallocuvm>
80109cca:	83 c4 10             	add    $0x10,%esp
      return 0;
80109ccd:	b8 00 00 00 00       	mov    $0x0,%eax
80109cd2:	eb 55                	jmp    80109d29 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109cd4:	83 ec 04             	sub    $0x4,%esp
80109cd7:	68 00 10 00 00       	push   $0x1000
80109cdc:	6a 00                	push   $0x0
80109cde:	ff 75 f0             	pushl  -0x10(%ebp)
80109ce1:	e8 66 ce ff ff       	call   80106b4c <memset>
80109ce6:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109ce9:	83 ec 0c             	sub    $0xc,%esp
80109cec:	ff 75 f0             	pushl  -0x10(%ebp)
80109cef:	e8 08 f6 ff ff       	call   801092fc <v2p>
80109cf4:	83 c4 10             	add    $0x10,%esp
80109cf7:	89 c2                	mov    %eax,%edx
80109cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfc:	83 ec 0c             	sub    $0xc,%esp
80109cff:	6a 06                	push   $0x6
80109d01:	52                   	push   %edx
80109d02:	68 00 10 00 00       	push   $0x1000
80109d07:	50                   	push   %eax
80109d08:	ff 75 08             	pushl  0x8(%ebp)
80109d0b:	e8 1b fb ff ff       	call   8010982b <mappages>
80109d10:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109d13:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d1d:	3b 45 10             	cmp    0x10(%ebp),%eax
80109d20:	0f 82 75 ff ff ff    	jb     80109c9b <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109d26:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109d29:	c9                   	leave  
80109d2a:	c3                   	ret    

80109d2b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109d2b:	55                   	push   %ebp
80109d2c:	89 e5                	mov    %esp,%ebp
80109d2e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109d31:	8b 45 10             	mov    0x10(%ebp),%eax
80109d34:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109d37:	72 08                	jb     80109d41 <deallocuvm+0x16>
    return oldsz;
80109d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d3c:	e9 a5 00 00 00       	jmp    80109de6 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109d41:	8b 45 10             	mov    0x10(%ebp),%eax
80109d44:	05 ff 0f 00 00       	add    $0xfff,%eax
80109d49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109d51:	e9 81 00 00 00       	jmp    80109dd7 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d59:	83 ec 04             	sub    $0x4,%esp
80109d5c:	6a 00                	push   $0x0
80109d5e:	50                   	push   %eax
80109d5f:	ff 75 08             	pushl  0x8(%ebp)
80109d62:	e8 24 fa ff ff       	call   8010978b <walkpgdir>
80109d67:	83 c4 10             	add    $0x10,%esp
80109d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109d6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109d71:	75 09                	jne    80109d7c <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109d73:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109d7a:	eb 54                	jmp    80109dd0 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d7f:	8b 00                	mov    (%eax),%eax
80109d81:	83 e0 01             	and    $0x1,%eax
80109d84:	85 c0                	test   %eax,%eax
80109d86:	74 48                	je     80109dd0 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8b:	8b 00                	mov    (%eax),%eax
80109d8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d92:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109d95:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d99:	75 0d                	jne    80109da8 <deallocuvm+0x7d>
        panic("kfree");
80109d9b:	83 ec 0c             	sub    $0xc,%esp
80109d9e:	68 e9 a8 10 80       	push   $0x8010a8e9
80109da3:	e8 be 67 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109da8:	83 ec 0c             	sub    $0xc,%esp
80109dab:	ff 75 ec             	pushl  -0x14(%ebp)
80109dae:	e8 56 f5 ff ff       	call   80109309 <p2v>
80109db3:	83 c4 10             	add    $0x10,%esp
80109db6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	ff 75 e8             	pushl  -0x18(%ebp)
80109dbf:	e8 48 91 ff ff       	call   80102f0c <kfree>
80109dc4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109dd0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109ddd:	0f 82 73 ff ff ff    	jb     80109d56 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109de3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109de6:	c9                   	leave  
80109de7:	c3                   	ret    

80109de8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109de8:	55                   	push   %ebp
80109de9:	89 e5                	mov    %esp,%ebp
80109deb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109dee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109df2:	75 0d                	jne    80109e01 <freevm+0x19>
    panic("freevm: no pgdir");
80109df4:	83 ec 0c             	sub    $0xc,%esp
80109df7:	68 ef a8 10 80       	push   $0x8010a8ef
80109dfc:	e8 65 67 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109e01:	83 ec 04             	sub    $0x4,%esp
80109e04:	6a 00                	push   $0x0
80109e06:	68 00 00 00 80       	push   $0x80000000
80109e0b:	ff 75 08             	pushl  0x8(%ebp)
80109e0e:	e8 18 ff ff ff       	call   80109d2b <deallocuvm>
80109e13:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109e16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109e1d:	eb 4f                	jmp    80109e6e <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109e29:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2c:	01 d0                	add    %edx,%eax
80109e2e:	8b 00                	mov    (%eax),%eax
80109e30:	83 e0 01             	and    $0x1,%eax
80109e33:	85 c0                	test   %eax,%eax
80109e35:	74 33                	je     80109e6a <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109e41:	8b 45 08             	mov    0x8(%ebp),%eax
80109e44:	01 d0                	add    %edx,%eax
80109e46:	8b 00                	mov    (%eax),%eax
80109e48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e4d:	83 ec 0c             	sub    $0xc,%esp
80109e50:	50                   	push   %eax
80109e51:	e8 b3 f4 ff ff       	call   80109309 <p2v>
80109e56:	83 c4 10             	add    $0x10,%esp
80109e59:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109e5c:	83 ec 0c             	sub    $0xc,%esp
80109e5f:	ff 75 f0             	pushl  -0x10(%ebp)
80109e62:	e8 a5 90 ff ff       	call   80102f0c <kfree>
80109e67:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109e6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109e6e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109e75:	76 a8                	jbe    80109e1f <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109e77:	83 ec 0c             	sub    $0xc,%esp
80109e7a:	ff 75 08             	pushl  0x8(%ebp)
80109e7d:	e8 8a 90 ff ff       	call   80102f0c <kfree>
80109e82:	83 c4 10             	add    $0x10,%esp
}
80109e85:	90                   	nop
80109e86:	c9                   	leave  
80109e87:	c3                   	ret    

80109e88 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109e88:	55                   	push   %ebp
80109e89:	89 e5                	mov    %esp,%ebp
80109e8b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109e8e:	83 ec 04             	sub    $0x4,%esp
80109e91:	6a 00                	push   $0x0
80109e93:	ff 75 0c             	pushl  0xc(%ebp)
80109e96:	ff 75 08             	pushl  0x8(%ebp)
80109e99:	e8 ed f8 ff ff       	call   8010978b <walkpgdir>
80109e9e:	83 c4 10             	add    $0x10,%esp
80109ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109ea4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109ea8:	75 0d                	jne    80109eb7 <clearpteu+0x2f>
    panic("clearpteu");
80109eaa:	83 ec 0c             	sub    $0xc,%esp
80109ead:	68 00 a9 10 80       	push   $0x8010a900
80109eb2:	e8 af 66 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eba:	8b 00                	mov    (%eax),%eax
80109ebc:	83 e0 fb             	and    $0xfffffffb,%eax
80109ebf:	89 c2                	mov    %eax,%edx
80109ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec4:	89 10                	mov    %edx,(%eax)
}
80109ec6:	90                   	nop
80109ec7:	c9                   	leave  
80109ec8:	c3                   	ret    

80109ec9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109ec9:	55                   	push   %ebp
80109eca:	89 e5                	mov    %esp,%ebp
80109ecc:	53                   	push   %ebx
80109ecd:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109ed0:	e8 e6 f9 ff ff       	call   801098bb <setupkvm>
80109ed5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109ed8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109edc:	75 0a                	jne    80109ee8 <copyuvm+0x1f>
    return 0;
80109ede:	b8 00 00 00 00       	mov    $0x0,%eax
80109ee3:	e9 f8 00 00 00       	jmp    80109fe0 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109ee8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109eef:	e9 c4 00 00 00       	jmp    80109fb8 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef7:	83 ec 04             	sub    $0x4,%esp
80109efa:	6a 00                	push   $0x0
80109efc:	50                   	push   %eax
80109efd:	ff 75 08             	pushl  0x8(%ebp)
80109f00:	e8 86 f8 ff ff       	call   8010978b <walkpgdir>
80109f05:	83 c4 10             	add    $0x10,%esp
80109f08:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109f0b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109f0f:	75 0d                	jne    80109f1e <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109f11:	83 ec 0c             	sub    $0xc,%esp
80109f14:	68 0a a9 10 80       	push   $0x8010a90a
80109f19:	e8 48 66 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f21:	8b 00                	mov    (%eax),%eax
80109f23:	83 e0 01             	and    $0x1,%eax
80109f26:	85 c0                	test   %eax,%eax
80109f28:	75 0d                	jne    80109f37 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109f2a:	83 ec 0c             	sub    $0xc,%esp
80109f2d:	68 24 a9 10 80       	push   $0x8010a924
80109f32:	e8 2f 66 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f3a:	8b 00                	mov    (%eax),%eax
80109f3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f41:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f47:	8b 00                	mov    (%eax),%eax
80109f49:	25 ff 0f 00 00       	and    $0xfff,%eax
80109f4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109f51:	e8 53 90 ff ff       	call   80102fa9 <kalloc>
80109f56:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109f59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109f5d:	74 6a                	je     80109fc9 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109f5f:	83 ec 0c             	sub    $0xc,%esp
80109f62:	ff 75 e8             	pushl  -0x18(%ebp)
80109f65:	e8 9f f3 ff ff       	call   80109309 <p2v>
80109f6a:	83 c4 10             	add    $0x10,%esp
80109f6d:	83 ec 04             	sub    $0x4,%esp
80109f70:	68 00 10 00 00       	push   $0x1000
80109f75:	50                   	push   %eax
80109f76:	ff 75 e0             	pushl  -0x20(%ebp)
80109f79:	e8 8d cc ff ff       	call   80106c0b <memmove>
80109f7e:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109f81:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109f84:	83 ec 0c             	sub    $0xc,%esp
80109f87:	ff 75 e0             	pushl  -0x20(%ebp)
80109f8a:	e8 6d f3 ff ff       	call   801092fc <v2p>
80109f8f:	83 c4 10             	add    $0x10,%esp
80109f92:	89 c2                	mov    %eax,%edx
80109f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f97:	83 ec 0c             	sub    $0xc,%esp
80109f9a:	53                   	push   %ebx
80109f9b:	52                   	push   %edx
80109f9c:	68 00 10 00 00       	push   $0x1000
80109fa1:	50                   	push   %eax
80109fa2:	ff 75 f0             	pushl  -0x10(%ebp)
80109fa5:	e8 81 f8 ff ff       	call   8010982b <mappages>
80109faa:	83 c4 20             	add    $0x20,%esp
80109fad:	85 c0                	test   %eax,%eax
80109faf:	78 1b                	js     80109fcc <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109fb1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109fbe:	0f 82 30 ff ff ff    	jb     80109ef4 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fc7:	eb 17                	jmp    80109fe0 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109fc9:	90                   	nop
80109fca:	eb 01                	jmp    80109fcd <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109fcc:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109fcd:	83 ec 0c             	sub    $0xc,%esp
80109fd0:	ff 75 f0             	pushl  -0x10(%ebp)
80109fd3:	e8 10 fe ff ff       	call   80109de8 <freevm>
80109fd8:	83 c4 10             	add    $0x10,%esp
  return 0;
80109fdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fe3:	c9                   	leave  
80109fe4:	c3                   	ret    

80109fe5 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109fe5:	55                   	push   %ebp
80109fe6:	89 e5                	mov    %esp,%ebp
80109fe8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109feb:	83 ec 04             	sub    $0x4,%esp
80109fee:	6a 00                	push   $0x0
80109ff0:	ff 75 0c             	pushl  0xc(%ebp)
80109ff3:	ff 75 08             	pushl  0x8(%ebp)
80109ff6:	e8 90 f7 ff ff       	call   8010978b <walkpgdir>
80109ffb:	83 c4 10             	add    $0x10,%esp
80109ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a001:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a004:	8b 00                	mov    (%eax),%eax
8010a006:	83 e0 01             	and    $0x1,%eax
8010a009:	85 c0                	test   %eax,%eax
8010a00b:	75 07                	jne    8010a014 <uva2ka+0x2f>
    return 0;
8010a00d:	b8 00 00 00 00       	mov    $0x0,%eax
8010a012:	eb 29                	jmp    8010a03d <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a014:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a017:	8b 00                	mov    (%eax),%eax
8010a019:	83 e0 04             	and    $0x4,%eax
8010a01c:	85 c0                	test   %eax,%eax
8010a01e:	75 07                	jne    8010a027 <uva2ka+0x42>
    return 0;
8010a020:	b8 00 00 00 00       	mov    $0x0,%eax
8010a025:	eb 16                	jmp    8010a03d <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a02a:	8b 00                	mov    (%eax),%eax
8010a02c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a031:	83 ec 0c             	sub    $0xc,%esp
8010a034:	50                   	push   %eax
8010a035:	e8 cf f2 ff ff       	call   80109309 <p2v>
8010a03a:	83 c4 10             	add    $0x10,%esp
}
8010a03d:	c9                   	leave  
8010a03e:	c3                   	ret    

8010a03f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a03f:	55                   	push   %ebp
8010a040:	89 e5                	mov    %esp,%ebp
8010a042:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a045:	8b 45 10             	mov    0x10(%ebp),%eax
8010a048:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a04b:	eb 7f                	jmp    8010a0cc <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a04d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a050:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a055:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a058:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a05b:	83 ec 08             	sub    $0x8,%esp
8010a05e:	50                   	push   %eax
8010a05f:	ff 75 08             	pushl  0x8(%ebp)
8010a062:	e8 7e ff ff ff       	call   80109fe5 <uva2ka>
8010a067:	83 c4 10             	add    $0x10,%esp
8010a06a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a06d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a071:	75 07                	jne    8010a07a <copyout+0x3b>
      return -1;
8010a073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a078:	eb 61                	jmp    8010a0db <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a07a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a07d:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a080:	05 00 10 00 00       	add    $0x1000,%eax
8010a085:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a08b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a08e:	76 06                	jbe    8010a096 <copyout+0x57>
      n = len;
8010a090:	8b 45 14             	mov    0x14(%ebp),%eax
8010a093:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a096:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a099:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a09c:	89 c2                	mov    %eax,%edx
8010a09e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0a1:	01 d0                	add    %edx,%eax
8010a0a3:	83 ec 04             	sub    $0x4,%esp
8010a0a6:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0a9:	ff 75 f4             	pushl  -0xc(%ebp)
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 59 cb ff ff       	call   80106c0b <memmove>
8010a0b2:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a0b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a0bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0be:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a0c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0c4:	05 00 10 00 00       	add    $0x1000,%eax
8010a0c9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a0cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a0d0:	0f 85 77 ff ff ff    	jne    8010a04d <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a0d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a0db:	c9                   	leave  
8010a0dc:	c3                   	ret    
