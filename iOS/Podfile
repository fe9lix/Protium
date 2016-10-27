platform :ios, "9.0"

target "Protium" do
  use_frameworks!
  
  pod "RxSwift", "3.0.0"
  pod "RxCocoa", "3.0.0"
  pod "JASON", "3.0"
  pod "Kingfisher", "3.1.4"

  target "ProtiumTests" do
    inherit! :search_paths
    pod "RxBlocking", "3.0.0"
    pod "RxTest", "3.0.0"
  end

  target "ProtiumUITests" do
    inherit! :search_paths
  end
end
