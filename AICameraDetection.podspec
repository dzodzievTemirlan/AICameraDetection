Pod::Spec.new do |spec|

  spec.name         = "AICameraDetection"
  spec.version      = "0.0.5"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
This CocoaPods library helps you detect faces, text or what ever you want with camera on iPhone.
                   DESC

  spec.homepage     = "https://github.com/Dearich/AICameraDetection"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Azizbek Ismailov" => "3@azizbek.ru" }

  spec.ios.deployment_target = "11.1"
  spec.swift_version = "5"

  spec.source        = { :git => "https://github.com/Dearich/AICameraDetection.git", :tag => "#{spec.version}" }
  spec.source_files  = "AICameraDetection/**/*.{h,m,swift}"

end
