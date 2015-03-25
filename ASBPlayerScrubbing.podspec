Pod::Spec.new do |s|
  s.name = "ASBPlayerScrubbing"
  s.version = "0.1"
  s.license = 'MIT'
  s.summary = "AVPlayer scrubbing behavior for iOS."
  s.authors = {
    "Philippe Converset" => "pconverset@autresphere.com"
  }
  s.homepage = "https://github.com/autresphere/ASBPlayerScrubbing"
  s.source = {
    :git => "https://github.com/autresphere/ASBPlayerScrubbing.git",
    :tag => "0.1"
  }
  s.platform = :ios, '6.0'
  s.source_files = 'ASBPlayerScrubbing/*.{h,m}'
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'AVFoundation'
  s.requires_arc = true
end