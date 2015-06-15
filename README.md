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

## 核心概念
### LCFeedbackReply
FeedbackReply 代表了反馈系统中间，用户或者开发者的每一次回复。不同的类型可以通过 ReplyType 属性来指定。FeedbackReply 内部主要记录有如下信息：

* content，反馈的文本内容
* replyType，类型标识，表明是用户提交的，还是开发者回复的
* attachment，反馈对应的附件信息

### LCFeedbackThread
代表了用户与开发者的整个交流过程，与用户一一对应。一个用户只有一个 FeedbackThread，一个 FeedbackThread 内含有多个 FeedbackReply。FeedbackThread 内部主要记录有如下信息：

* contact，用户联系方式
* content，用户第一次反馈的文本
* status，当前状态：open 还是 close
* remarks，预留字段，开发者可以用来标记的一些其他信息


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
### 我要增加其他平台，该怎么做？

### 我可以使用其他 SDK 来做登录，然后把授权信息绑定到 AVUser 吗？
