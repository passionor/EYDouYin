EYDouYin 该项目主体框架是模仿抖音框架实现   
=======================   

## 首页
### 首页左滑 三方（GKNavigationBarViewController）实现
## 关注
## 消息
## 个人
### 个人中心 与 Swift 语言、Flutter 语言、React Native 语言的混合开发
   
# 项目如何使用？
   
## 第一步: clone 项目
   
方式一: (SSH)   
```git clone git@github.com:lieryang/EYDouYin.git```   
方式二: (HTTPS)    
```git clone https://github.com/lieryang/EYDouYin.git```   

## 第二步: 重新生成 my_flutter 模块(本来不需要的,目前没有找到解决方案)   

### 1.保存 EYDouYin/my_flutter/main.dart 的源文件

### 2.重新生成 my_flutter 模块   
```cd EYDouYin```   
```flutter create -t module my_flutter```   
注意!!! 是重新生成 Flutter 支持的模块 不是通过flutter 指令生成项目  ~~flutter create my_flutter~~   
   
### 3.将第一步保存的 main.dart文件 覆盖掉 EYDouYin/my_flutter/main.dart 文件   
注意是覆盖   
   
## 第三步: 安装工程需要的三方库(OC、Swift、Flutter 支持、React Native 支持)   
   
```cd ios```   
```pod install```   

# 项目框架结构
  
## GKNavigationBarViewController （版本:2.3.3 地址： https://github.com/QuintGao/GKNavigationBarViewController）
  ![image](https://github.com/lieryang/EYDouYin/blob/master/image/GKNavigationBarViewController.png)
  
  
  
# 踩过的坑
## 1.集成 FFmpeg
本项目中使用的 FFmpeg 版本为 4.0.3 版本。  

FFmpeg （地址：https://github.com/FFmpeg/FFmpeg  编译脚本地址: https://github.com/kewlbear/FFmpeg-iOS-build-script 注意对应的版本） 是跨平台的音视频处理技术，所有的（基本上）音视频的高级处理都会使用到，但是直接使用 FFmpeg 来处理视频操作过于复杂！
所以很多的三方框架，都是在 FFmpeg 的基础上封装了一层，最著名的要数 bilibili 的 ijkplayer 了 (地址:  ```https://github.com/bilibili/ijkplayer``` ) 
很多的三方框架就是基于bilibili 中的脚本生成的 IJKMediaFramework.framework 进行技术代码实现!   
  
1. 通过脚本生成需要的文件（FFmpeg-iOS文件夹）   

2. 添加需要的头文件（放入FFmpeg-iOS文件夹）   

   1 config.h   
   2 ffmpeg.h   
   3 ffmpeg.c   
   4 cmdutils.h   
   5 cmdutils.c   
   6 ffmpeg_opt.c   
   7 ffmpeg_filter.c   
   8 ffmpeg_hw.c   
   9 ffmpeg_videotoolbox.c   
   这 9 个文件: 部分需要修改头文件引用和源代码实现    
   
3. 项目 -> Build Setting -> Search Paths -> Header Search Paths   添加  ```$(PROJECT_DIR)/EYDouYin/Class/Main/Tool/FFmpeg-iOS/include```    

   项目 -> Build Setting -> Search Paths -> Library Search Paths   添加  ```$(PROJECT_DIR)/EYDouYin/Class/Main/Tool/FFmpeg-iOS/lib```   
   
  具体请看博客:  未完待续......
