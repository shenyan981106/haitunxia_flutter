git提交规范：
master	    线上生产环境代码，始终保持稳定、可发布状态。	
dev	        测试环境代码，用于功能集成和测试。	
feature/*	功能开发分支，从 dev 拉出，完成后合并回 dev。	
hotfix/*	紧急修复分支，从 master 拉出，完成后同时合并回 master 和 dev


开发流程
1.切换到 dev 分支并同步最新代码
git checkout dev
git pull origin dev

2.从 dev 创建功能分支
git checkout -b feature/你的功能名称
# 例如：git checkout -b feature/user-login

3.本地开发与提交
git add .
git commit -m "feat: 实现用户登录功能"

4.推送功能分支到远程仓库
git push origin feature/你的功能名称



代码说明
1.运行命令：flutter run
2.检查设备：flutter devices
3.打包命令：flutter build apk --release
4.打包-notree：flutter build apk --release --no-tree-shake-icons
5.版本更新：修改根目录pubspec.yaml version: x.x.x
6.组件目录：lib\app\components  
7.鸿蒙打包：E:\flutter_flutter\bin\flutter.bat build hap --release

# git提交规范
1.提交时，使用英文描述，例如："feat: 实现用户登录功能"
2.提交时，使用中文描述，例如："feat: 实现用户登录功能"
主分支：master
开发分支：dev
功能分支：feature/*
紧急修复分支：hotfix/*

# git提交流程
切换到 dev 分支并同步最新代码
git checkout dev
git pull origin dev
git checkout -b feature/你的功能名称
git add .
git commit -m "feat: 实现用户登录功能"
git push origin feature/你的功能名称

# 合并完成后清理分支
git checkout dev
git branch -d feature/user-login
git push origin --delete feature/user-login




Windows 开发完成，打包：
lib + assets + pubspec.yaml
Mac 这边新建干净 flutter 项目（shop_new）
删除新项目自带的 lib、assets
把 Windows 传过来的 lib、assets、pubspec.yaml 覆盖进去
Mac 终端执行
bash
运行
flutter pub get
flutter run
常见报错原因
1.找不到get包
  flutter clean
  rm -rf pubspec.lock .dart_tool
  flutter pub get
  flutter run


  