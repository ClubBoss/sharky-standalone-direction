import Flutter
import StoreKit
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var growthChannel: FlutterMethodChannel?
  private var pendingGrowthLink: String?
  private var growthLinkListenerReady = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let launchResult = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return launchResult
    }
    registerPracticeReminders(controller.binaryMessenger)
    registerGrowthBridge(controller.binaryMessenger)
    if let url = launchOptions?[.url] as? URL, url.scheme == "sharky" {
      pendingGrowthLink = url.absoluteString
    }

    let environment = ProcessInfo.processInfo.environment
    let payload = environment["SHARKY_VISUAL_AUDIT_PAYLOAD"]
    let stateId = environment["SHARKY_VISUAL_AUDIT_STATE_ID"]
    guard payload != nil || stateId != nil else { return launchResult }

    let visualAuditChannel = FlutterMethodChannel(
      name: "com.clubboss.sharky/visual_audit_v1",
      binaryMessenger: controller.binaryMessenger
    )
    visualAuditChannel.setMethodCallHandler { call, result in
      guard call.method == "visualAuditPayload" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result([
        "query": payload ?? "",
        "visual_state_id": stateId ?? "",
      ])
    }
    return launchResult
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    guard url.scheme?.lowercased() == "sharky" else {
      return super.application(app, open: url, options: options)
    }
    if growthLinkListenerReady {
      growthChannel?.invokeMethod("openLink", arguments: url.absoluteString)
    } else {
      pendingGrowthLink = url.absoluteString
    }
    return true
  }

  private func registerGrowthBridge(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.clubboss.sharky/growth_v1",
      binaryMessenger: messenger
    )
    growthChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "takeLink":
        self?.growthLinkListenerReady = true
        let link = self?.pendingGrowthLink
        self?.pendingGrowthLink = nil
        result(link)
      case "requestReview":
        if let window = self?.window,
           window.rootViewController?.presentedViewController == nil,
           let scene = window.windowScene,
           scene.activationState == .foregroundActive {
          if #available(iOS 16.0, *) {
            AppStore.requestReview(in: scene)
          } else if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview(in: scene)
          } else {
            SKStoreReviewController.requestReview()
          }
          result(true)
        } else {
          result(false)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private extension AppDelegate {
  static let practiceReminderId = "sharky.practice-reminder"
  static let practiceReminderOptIn = "sharky.practice-reminder.opt-in"

  func registerPracticeReminders(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.clubboss.sharky/practice_reminder_v1",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }
      let defaults = UserDefaults.standard
      let arguments = call.arguments as? [String: Any]
      let schedule = arguments?["schedule"] as? String ?? "none"
      switch call.method {
      case "permissionDenied":
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          let denied = settings.authorizationStatus == .denied ||
            (settings.authorizationStatus == .authorized && settings.alertSetting != .enabled)
          DispatchQueue.main.async { result(denied) }
        }
      case "sync":
        guard defaults.bool(forKey: Self.practiceReminderOptIn) else {
          result(false)
          return
        }
        self.schedulePracticeReminder(schedule, result)
      case "setEnabled":
        guard let enabled = arguments?["enabled"] as? Bool else {
          result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
          return
        }
        if enabled {
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            DispatchQueue.main.async {
              if error != nil {
                result(FlutterError(code: "permission_unavailable", message: nil, details: nil))
              } else if granted {
                self.schedulePracticeReminder(schedule, result)
              } else {
                self.cancelPracticeReminder()
                result(false)
              }
            }
          }
        } else {
          self.cancelPracticeReminder()
          result(false)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func schedulePracticeReminder(_ schedule: String, _ result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      DispatchQueue.main.async {
        guard settings.authorizationStatus == .authorized,
              settings.alertSetting == .enabled else {
          self.cancelPracticeReminder()
          result(false)
          return
        }
        if schedule == "none" {
          center.removePendingNotificationRequests(withIdentifiers: [Self.practiceReminderId])
          UserDefaults.standard.set(true, forKey: Self.practiceReminderOptIn)
          result(true)
          return
        }
        let content = UNMutableNotificationContent()
        content.title = "Sharky Poker"
        content.body = "A short practice whenever you feel ready."
        guard let evening = practiceReminderEvening(
          tomorrow: schedule == "tomorrowEvening",
          now: Date(),
          calendar: .current
        ) else {
          result(FlutterError(code: "schedule_unavailable", message: nil, details: nil))
          return
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: evening, repeats: false)
        guard trigger.nextTriggerDate() != nil else {
          result(FlutterError(code: "schedule_unavailable", message: nil, details: nil))
          return
        }
        center.add(UNNotificationRequest(
          identifier: Self.practiceReminderId,
          content: content,
          trigger: trigger
        )) { error in
          DispatchQueue.main.async {
            if error != nil {
              result(FlutterError(code: "schedule_unavailable", message: nil, details: nil))
              return
            }
            UserDefaults.standard.set(true, forKey: Self.practiceReminderOptIn)
            result(true)
          }
        }
      }
    }
  }

  func cancelPracticeReminder() {
    UserDefaults.standard.removeObject(forKey: Self.practiceReminderOptIn)
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [Self.practiceReminderId])
    center.removeDeliveredNotifications(withIdentifiers: [Self.practiceReminderId])
  }
}

func practiceReminderEvening(tomorrow: Bool, now: Date, calendar: Calendar) -> DateComponents? {
  if !tomorrow { return DateComponents(hour: 18, minute: 0) }
  guard let nextDay = calendar.date(byAdding: .day, value: 1, to: now) else { return nil }
  var evening = calendar.dateComponents([.year, .month, .day], from: nextDay)
  evening.hour = 18
  evening.minute = 0
  return evening
}
