# leancloud-social-ios

LeanCloud Social Network 模块是 [LeanCloud](https://leancloud.cn) 开源的一个第三方平台登录、分享组件，目前支持 QQ 空间和新浪微博两个平台，具体使用方法可以参看[文档](https://leancloud.cn/docs/sns.html)。



## 如何贡献
你可以通过提 issue 或者发 pull request 的方式，来贡献代码。开源世界因你我参与而更加美好。

## 项目结构
为了便于测试，我们将 Social Network 模块的代码和 demo 都放在了一起，整个 repo 结构如下：

```
.
├── AVOSCloud.framework  <---- 这是依赖的 AVOSCloud.framework，请保持最新
├── LeanCloudSocial    <---- social network 主要代码
├── LeanCloudSocialTests
├── LeanCloudSocialDemo    <---- social network demo 主要代码
│   ├── LeanCloudSocialemo
│   ├── LeanCloudSocialDemo.xcodeproj
│   └── LeanCloudSocialDemoTests
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


## 如何运行 demo
在 LeanCloudSocialDemo 目录下，直接用 xcode 打开 LeanCloudSocialDemo.xcodeproj 工程即可。


## 在我的项目中如何使用这一组件
为了调试方便，我们推荐大家直接把本项目的源代码加入自己工程来使用 Social Network 组件。
具体的使用方法可以参看[文档](https://leancloud.cn/docs/sns.html)。


## 其他问题
我要增加其他平台，该怎么做？

我可以使用其他 SDK 来做登录，然后把授权信息绑定到 AVUser 吗？

## ChangeLog
发布流程：更改 podspec 版本，打 tag，推送到仓库，执行`pod trunk push LeanCloudSocial.podspec --verbose --allow-warnings --use-libraries`。

0.0.4	
支持微信 SSO 登录，对 -[AVOSCloudSNS loginWithCallback:toPlatform] 第二个参数传入 AVOSCloudSNSWeiXin 即可。
同时提供 -[AVOSCloudSNS isAppInstalledWithType] 来检测相应的应用有没安装。

0.0.3	
重命名 LCHttpClient 至 AVSNSHttpClient，避免和其它LC的模块冲突

0.0.2	
使用 AFNetworking ~2.0 版本，使得主项目能够和此库共用同一个 AFNetworking 版本。如果主项目使用的是 AFNetworking 1.0，推荐使用 LeanCloudSocial 0.0.1 版本。

0.0.1	
重命名模块后发布
