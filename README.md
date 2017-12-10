# MIPS16 CPU：计算机组成原理大实验


## CPU结构和性能

cpu的主要参数有：5级流水，一个时钟内完成内存读写, 使用了两块ROM，rom2用作显存映射。25MHz主频。


## 扩展

虽然我们cpu性能比较挫，但是我们扩展做的还算比较全～ \(￣y▽￣\)~\*

    * VGA
    * ps2键盘
    * 支持INT指令的软中断
    * 硬中断
    * flash自启动
    * 使用ThinPad播放自己的PPT


## 代码结构

有关cpu主逻辑和中断的所有代码请看cpu/文件夹

flash自启动以及PPT的加载模块请看flash/文件夹

我们还提供了一个将PNG图片自动转换为flash烧写格式的脚本，请移步misc/文件夹

VGA和字体的支持请看vga/和font/,另外需要注意，想要字体库和vga显示正常工作，需要手动配置ISE中的ip_core

我们修改了kernel代码，并且加入了2条新指令, kernel的汇编代码以及修改过的二进制文件见kernel/

ps2键盘相关代码在keyboard/下

## 贡献

感谢[@AtlantixJJ](https://github.com/AtlantixJJ), 这家伙完成了vga，ps2, flash自启动和从flash中加载PPT并显示
（是的！几乎所有的扩展); 另外感谢[@ZHANGChongzhiu](https://github.com/ZHANGChongzhiu), 将我们从繁重的报告中
解救出来; 最后！感谢伟大的我自己，在充分的享受了写码5分钟编译半小时的快感后, 写完了“浩如烟海”的cpu主逻辑，
还极富创造性的加了两个蹩脚的中断。并且, 在经历了这一切之后我们都还活着! 真是感谢上帝!

祝学弟学妹们cpu都跑的飞快，扩展6的飞起，游戏直逼吃鸡, 组队遇上美女，老学姐就只能帮你们到这里啦:D。

![奋战三星期，造台计算机](image/奋战三星期造台计算机.png)


