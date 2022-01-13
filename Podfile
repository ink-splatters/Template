install! 'cocoapods',
         :generate_multiple_pod_projects => true,
         :incremental_installation => true,
         :preserve_pod_file_structure => true

install! 'cocoapods', :disable_input_output_paths => true

use_frameworks!

target 'Template macOS' do
  platform :osx, '10.15'
  pod 'Forge', :git => 'https://github.com/Hi-Rez/Forge'
  pod 'Satin', :git => 'https://github.com/Hi-Rez/Satin'
  pod 'Youi', :git => 'https://github.com/Hi-Rez/Youi'
end


target 'Template iOS' do
  platform :ios, '14.0'
  pod 'Forge', :git => 'https://github.com/Hi-Rez/Forge'
  pod 'Satin', :git => 'https://github.com/Hi-Rez/Satin'
  pod 'Youi', :git => 'https://github.com/Hi-Rez/Youi'
end

target 'Template tvOS' do
  platform :tvos, '13.0'
  pod 'Forge', :git => 'https://github.com/Hi-Rez/Forge'
  pod 'Satin', :git => 'https://github.com/Hi-Rez/Satin'
end
