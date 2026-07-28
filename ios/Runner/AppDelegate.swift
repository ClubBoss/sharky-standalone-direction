import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller = window?.rootViewController as! FlutterViewController
    let visualAuditChannel = FlutterMethodChannel(
      name: "com.clubboss.sharky/visual_audit_v1",
      binaryMessenger: controller.binaryMessenger
    )
    visualAuditChannel.setMethodCallHandler { call, result in
      guard call.method == "visualAuditPayload" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let environment = ProcessInfo.processInfo.environment
      let payload = environment["SHARKY_VISUAL_AUDIT_PAYLOAD"] ?? ""
      let stateId = environment["SHARKY_VISUAL_AUDIT_STATE_ID"] ?? ""
      result([
        "query": payload,
        "visual_state_id": stateId,
      ])
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
