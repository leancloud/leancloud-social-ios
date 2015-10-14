# Uncomment this line to define a global platform for your project

workspace 'LeanCloudSocial.xcworkspace'

xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'

target 'LeanCloudSocial' do
    platform :ios, '6.0'
    
    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'AVOSCloud', '~> 3.1.4'
    pod 'AFNetworking', '~> 2.0'
end

target 'LeanCloudSocialDynamic' do
    platform :ios, '8.0'
    
    xcodeproj 'LeanCloudSocialDynamic/LeanCloudSocialDynamic.xcodeproj'
    pod 'AVOSCloudDynamic', '~> 3.1.4'
    pod 'AFNetworking', '~> 2.0'
end

target 'LeanCloudSocialDemo' do
    platform :ios, '6.0'
    
    xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'
    pod 'LeanCloudSocial', :path => '.'
end
