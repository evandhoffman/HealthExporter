platform :ios, '12.0'

target 'HealthExporter' do
  pod 'GoogleSignIn', '~> 7.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
end
