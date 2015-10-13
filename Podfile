# Uncomment this line to define a global platform for your project

workspace 'LeanCloudSocial.xcworkspace'
platform :ios, '8.0'

xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'

target 'LeanCloudSocialDynamic' do
    xcodeproj 'LeanCloudSocialDynamic/LeanCloudSocialDynamic.xcodeproj'
    pod 'AVOSCloudDynamic', '~> 3.1.4'
    pod 'AFNetworking', '~> 2.0'
end

target 'LeanCloudSocialDemo' do
    xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'
    pod 'LeanCloudSocialDynamic', :path => '.'
end
