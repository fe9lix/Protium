platform :ios, "9.0"

target "Protium" do
  use_frameworks!
  
  pod "RxSwift", "3.0.0-beta.2"
  pod "RxCocoa", "3.0.0-beta.2"
  pod "JASON", "3.0"
  pod "Kingfisher", "3.1.1"

  target "ProtiumTests" do
    inherit! :search_paths
    pod "RxBlocking", "3.0.0-beta.2"
    pod "RxTests", "3.0.0-beta.2"
  end

  target "ProtiumUITests" do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["SWIFT_VERSION"] = "3.0"
      config.build_settings["MACOSX_DEPLOYMENT_TARGET"] = "10.10"
    end
  end
end
