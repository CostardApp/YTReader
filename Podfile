# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'


target 'YTReader_EXAMPLE' do
  	platform :ios, '12.0'

    pod 'YTReader', :git => 'https://github.com/CostardApp/YTReader.git', :path => '1.0.4'

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
