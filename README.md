# UnderCore
Download
```
git clone https://github.com/Kriperovich2/UnderCore/
```
Compile the boot loader
```
nasm -f bin boot.asm -o boot.bin
```

Compile the kernel
```
nasm -f bin kernel.asm -o kernel.bin
```

Create a disk image
```
dd if=/dev/zero of=undercore.img bs=512 count=16

dd if=boot.bin of=undercore.img conv=notrunc
dd if=kernel.bin of=undercore.img bs=512 seek=1 conv=notrunc
```
Launch
```
qemu-system-i386 -hda undercore.img
```
