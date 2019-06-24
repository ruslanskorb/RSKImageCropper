Pod::Spec.new do |s|
  s.name          = 'RSKImageCropper'
  s.version       = '2.2.2'
  s.summary       = 'This is a fork of library ruslanskorb/RSKImageCropper, it\'s exist cause in original cropper buttons not enough styled. An image cropper for iOS like in the Contacts app with support for landscape orientation.'
  s.homepage      = 'https://github.com/ruslanskorb/RSKImageCropper'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.authors       = { 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source        = { :git => 'https://github.com/trivetechnology/RSKImageCropper.git', :tag => s.version.to_s }
  s.platform      = :ios, '6.0'
  s.module_map    = 'RSKImageCropper/RSKImageCropper.modulemap'
  s.source_files  = 'RSKImageCropper/*.{h,m}'
  s.resources     = 'RSKImageCropper/RSKImageCropperStrings.bundle'
  s.frameworks    = 'QuartzCore', 'UIKit'
  s.requires_arc  = true
end
