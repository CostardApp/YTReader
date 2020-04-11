Pod::Spec.new do |s|
  spec.name          = "YTReader"
  spec.version       = "1.0.4"
  spec.summary       = "Youtube API reader easy-to-use in Swift."
  spec.description   = "YTReader is a Youtube API reader easy-to-use in Swift."
  spec.homepage      = "https://github.com/CostardApp/"
  spec.license       = "MIT"
  spec.author        = { "Brian Costard" => "brian.costard@gmail.com" }
  spec.platform      = :ios, "12.0"
  spec.swift_version = "5.1"
  spec.source        = {
    :git => "https://github.com/CostardApp/YTReader.git",
    :tag => "1.0.4"
  }
  spec.source_files        = "YTReader/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  s.public_header_files = "YTReader/**/*.h"
end
