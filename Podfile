# Uncomment this line to define a global platform for your project

workspace 'LeanCloudSocial.xcworkspace'

xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'

target 'LeanCloudSocial' do
    platform :ios, '7.0'

    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'AVOSCloud'
end

target 'LeanCloudSocialTests' do
    platform :ios, '7.0'
    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'LeanCloudSocial', :path => '.'
    pod 'Expecta'
end

target 'LeanCloudSocialDemo' do
    platform :ios, '7.0'

    xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'
    pod 'LeanCloudSocial', :path => '.'
    pod 'AFNetworking', '~> 2.6.3'
end
