// import Flutter
// import UIKit
// import GoogleMaps


// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
//        let keys = NSDictionary(contentsOfFile: path),
//        let apiKey = keys["GOOGLE_MAPS_API_KEY"] as? String {
//         // GMSServices.provideAPIKey(apiKey)
//         GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")

//     } else {
//         print("⚠️ Google Maps API key not found in Keys.plist")
//         GMSServices.provideAPIKey("MY_GOOGLE_MAPS_API_KEY")
//     }
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }


import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API key from Keys.plist (secure approach)
    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
       let keys = NSDictionary(contentsOfFile: path),
       let apiKey = keys["GOOGLE_MAPS_API_KEY"] as? String {
        GMSServices.provideAPIKey(apiKey)
        print("Google Maps API key loaded from Keys.plist")
    } else {
        print("Google Maps API key not found in Keys.plist")
      
        GMSServices.provideAPIKey("YOUR_FALLBACK_KEY_HERE")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}