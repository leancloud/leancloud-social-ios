# Uncomment this line to define a global platform for your project

workspace 'LeanCloudSocial.xcworkspace'

xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'

target 'LeanCloudSocial' do
    platform :ios, '7.0'

    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'AVOSCloud', '~> 3.1'
end

target 'LeanCloudSocialTests' do
    platform :ios, '7.0'
    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'LeanCloudSocial', :path => '.'
    pod 'Expecta', '~> 1.0.0'
end

target 'LeanCloudSocialDynamic' do
    platform :ios, '8.0'

    xcodeproj 'LeanCloudSocial/LeanCloudSocial.xcodeproj'
    pod 'AVOSCloudDynamic', '~> 3.1'
end

target 'LeanCloudSocialDemo' do
    platform :ios, '7.0'

    xcodeproj 'LeanCloudSocialDemo/LeanCloudSocialDemo.xcodeproj'
    pod 'LeanCloudSocial', :path => '.'
end
