import Cocoa
import UserNotifications

class NotificationApp: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let args = CommandLine.arguments
        
        // Parse command line arguments
        var title = "Terminal"
        var subtitle: String?
        var message: String?
        
        var i = 1
        while i < args.count {
            switch args[i] {
            case "-title":
                if i + 1 < args.count {
                    title = args[i + 1]
                    i += 1
                }
            case "-subtitle":
                if i + 1 < args.count {
                    subtitle = args[i + 1]
                    i += 1
                }
            case "-message":
                if i + 1 < args.count {
                    message = args[i + 1]
                    i += 1
                }
            case "-help":
                printHelp()
                exit(0)
            default:
                break
            }
            i += 1
        }
        
        // If no message provided, read from stdin
        if message == nil && (isatty(STDIN_FILENO) == 0) {
            let inputData = FileHandle.standardInput.readDataToEndOfFile()
            message = String(data: inputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let finalMessage = message, !finalMessage.isEmpty else {
            printHelp()
            exit(1)
        }
        
        // Request notification permissions and send notification
        requestNotificationPermission { [weak self] granted in
            if granted {
                self?.sendNotification(title: title, subtitle: subtitle, message: finalMessage)
            } else {
                print("Notification permission denied")
                exit(1)
            }
        }
    }
    
    private func printHelp() {
        print("""
        cursor-agent-notifier - A simple macOS notification tool
        
        Usage: cursor-agent-notifier [options]
        
        Options:
            -title VALUE     The notification title (default: "Terminal")
            -subtitle VALUE  The notification subtitle
            -message VALUE   The notification message
            -icon PATH       Path to an icon image file
            -help           Show this help message
        
        If no message is provided via -message, the tool will read from stdin.
        """)
    }
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    if let error = error {
                        print("Notification permission denied with error: \(error.localizedDescription)")
                    } else {
                        print("Notification permission denied by user")
                    }
                }
                completion(granted)
            }
        }
    }
    
    private func sendNotification(title: String, subtitle: String?, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending notification: \(error)")
                    exit(1)
                } else {
                    exit(0)
                }
            }
        }
    }
    
    private func getIconURL(from path: String) -> URL? {
        let url = URL(fileURLWithPath: path)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Warning: Icon file not found at path: \(path)")
            return nil
        }
        
        return url
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        exit(0)
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = NotificationApp()
app.delegate = delegate
app.run() 