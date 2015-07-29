Pod::Spec.new do |s|

  s.name         = "LeanCloudSocial"
  s.version      = "0.0.1"
  s.summary      = "LeanCloud iOS Social SDK for mobile backend."
  s.homepage     = "https://leancloud.cn"
  s.license        = { :type => "Commercial", :text => "© Copyright 2015 LeanCloud, Inc. See https://leancloud.cn/terms.html" }
  s.author             = { "LeanCloud" => "support@leancloud.cn" }
  s.documentation_url = "https://leancloud.cn/docs/sns.html"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/leancloud/leancloud-social-ios.git", :tag => s.version.to_s }
  s.source_files  = "LeanCloudSocial/**/*.{h,m}"
  s.public_header_files = "LeanCloudSocial/**/*.h"
  s.dependency "AVOSCloud", "~> 3.1"
  s.dependency "AFNetworking", "~> 2.0"
end

