#!/bin/bash -v

# 使用这个脚本来创建 LeanCloudSocial 的静态库与动态库
# 动态库最低支持 iOS 8.0

xcodebuild -workspace LeanCloudSocial.xcworkspace -scheme UniversalFramework -configuration Release
