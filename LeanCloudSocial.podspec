Pod::Spec.new do |s|

  s.name         = "LeanCloudSocial"
  s.version      = "0.0.6"
  s.summary      = "LeanCloud iOS Social SDK for mobile backend."
  s.homepage     = "https://leancloud.cn"
  s.license      = { :type => "Commercial", :text => "© Copyright 2015 LeanCloud, Inc. See https://leancloud.cn/terms.html" }
  s.author       = { "LeanCloud" => "support@leancloud.cn" }
  s.documentation_url = "https://leancloud.cn/docs/sns.html"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/leancloud/leancloud-social-ios.git", :tag => s.version.to_s }
  s.source_files = "Classes/*.{h,m}"
  s.public_header_files = "Classes/AVUser+SNS.h", "Classes/AVOSCloudSNS.h"

  s.dependency "AVOSCloud", "~> 3.1"
  s.dependency "AFNetworking", "< 2.6" # 2.6 require iOS 7
end

