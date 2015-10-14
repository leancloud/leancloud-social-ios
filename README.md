# leancloud-social-ios

LeanCloud Social Network 模块是 [LeanCloud](https://leancloud.cn) 开源的一个第三方平台登录、分享组件，目前支持 QQ 空间、新浪微博、微信三个平台，具体使用方法可以参看[文档](https://leancloud.cn/docs/sns.html)。

## 视频演示
请用浏览器打开[视频](http://ac-x3o016bx.clouddn.com/a294809feb0c6a8a.mp4) ，相应的代码见[这里](https://github.com/leancloud/leanchat-ios/blob/master/LeanChat/LeanChat/controllers/entry/CDLoginVC.m#L252-L278)。 

## 如何运行 demo

```
 	cd LeanCloudSocialDemo
 	pod install --verbose (如果本地安装过 AVOSCloud 库，则可以加选项 --no-repo-update，加快速度)
 	open LeanCloudSocialDemo.xcworkspace
```

## 使用方法
具体的使用方法可以参看[文档](https://leancloud.cn/docs/sns.html)。
我们推荐用 pod 方式来安装这一组件	
```
	pod 'LeanCloudSocial'
```

也可参考 [LeanChat](https://github.com/leancloud/leanchat-ios)，这个应用使用了这一组件来实现第三方登录，像上面视频所演示的那样。相应代码见[这里](https://github.com/leancloud/leanchat-ios/blob/master/LeanChat/LeanChat/controllers/entry/CDLoginVC.m#L181-L278)。

## 宝贵意见
如果有任何问题，欢迎提 [issue](https://github.com/leancloud/leancloud-social-ios/issues) ，写上你不明白的地方，看到后会尽快给予帮助。

## 如何贡献
你可以通过提 issue 或者发 pull request 的方式，来贡献代码。开源世界因你我参与而更加美好。


## 项目结构
为了便于测试，我们将 Social Network 模块的代码和 demo 都放在了一起，整个 repo 结构如下：

```
.
├── LeanCloudSocial  <--- LeanCloudSocial 框架代码
├── LeanCloudSocial.podspec  <--- podspec 描述
├── LeanCloudSocialDemo  <--- Demo 项目
│   ├── LeanCloudSocialDemo
│   ├── LeanCloudSocialDemo.xcodeproj
│   ├── LeanCloudSocialDemo.xcworkspace <--- Demo及框架 workspace，这里打开
│   └── Podfile   <--- Demo和框架的 Podfile 
├── LeanCloudSocialTests
└── README.md
```

## 如何编译
### Xcode 编译
在 Xcode 中选择 UniversalFramework Target，设备选为 iOS Device，在 Product 菜单中选择 Archive 即可开始编译。编译完成之后会在当前 build 目录下

```
.
├── LeanCloudSocial.build
│   ├── Release-iphoneos
│   │   └── LeanCloudSocial.build
│   └── Release-iphonesimulator
│       └── LeanCloudSocial.build
└── Release-iphoneuniversal
    └── LeanCloudSocial.framework <------ 这里就是编译出来的 framework
```

### 命令行编译
在项目根目录下执行如下语句，即可开始编译

```
xcodebuild -target UniversalFramework -config Release
```

编译之后的结果文件目录和上面示例一致。

## 其他问题
我要增加其他平台，该怎么做？

我可以使用其他 SDK 来做登录，然后把授权信息绑定到 AVUser 吗？

## 发布日志
发布流程：更改 podspec 版本，打 tag，推送到仓库，执行`pod trunk push LeanCloudSocial.podspec --verbose --allow-warnings --use-libraries`。

0.0.6   
调整目录结构。同时发布动态库，可通过 `pod LeanCloudSocialDynamic` 引入到项目中。

0.0.5	
重构部分函数，使命名更符合 Cocoa 规范

0.0.4	
支持微信 SSO 登录，对 -[AVOSCloudSNS loginWithCallback:toPlatform] 第二个参数传入 AVOSCloudSNSWeiXin 即可。
同时提供 -[AVOSCloudSNS isAppInstalledWithType] 来检测相应的应用有没安装。

0.0.3	
重命名 LCHttpClient 至 AVSNSHttpClient，避免和其它LC的模块冲突

0.0.2	
使用 AFNetworking ~2.0 版本，使得主项目能够和此库共用同一个 AFNetworking 版本。如果主项目使用的是 AFNetworking 1.0，推荐使用 LeanCloudSocial 0.0.1 版本。

0.0.1	
重命名模块后发布

## License
MIT