import ApplicationServices
import Cocoa
import Foundation

/// Handles Accessibility-driven window operations.
final class SnapService {
    func perform(_ action: SnapAction) {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            print("SnapService: No frontmost application.")
            return
        }
        
        let pid = frontmostApp.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        var windowRef: AnyObject?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        guard result == .success, let window = windowRef else {
            print("SnapService: Could not get focused window (error: \(result.rawValue)).")
            return
        }
        
        guard let screen = NSScreen.main else {
            print("SnapService: Could not get main screen.")
            return
        }
        
        let screenFrame = screen.visibleFrame
        let (x, y, width, height) = calculateFrame(for: action, in: screenFrame)
        
        // Set position
        var position = CGPoint(x: x, y: y)
        let positionValue = AXValueCreate(.cgPoint, &position)!
        AXUIElementSetAttributeValue(window as! AXUIElement, kAXPositionAttribute as CFString, positionValue)
        
        // Set size
        var size = CGSize(width: width, height: height)
        let sizeValue = AXValueCreate(.cgSize, &size)!
        AXUIElementSetAttributeValue(window as! AXUIElement, kAXSizeAttribute as CFString, sizeValue)
        
        print("SnapService: Performed action '\(action.description)'.")
    }
    
    private func calculateFrame(for action: SnapAction, in screenFrame: CGRect) -> (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let x = screenFrame.origin.x
        let y = screenFrame.origin.y
        let width = screenFrame.width
        let height = screenFrame.height
        
        switch action {
        case .leftHalf:
            return (x, y, width / 2, height)
        case .rightHalf:
            return (x + width / 2, y, width / 2, height)
        case .topHalf:
            return (x, y, width, height / 2)
        case .bottomHalf:
            return (x, y + height / 2, width, height / 2)
        case .maximize:
            return (x, y, width, height)
        case .centered:
            let centeredWidth = width * 0.7
            let centeredHeight = height * 0.7
            return (x + (width - centeredWidth) / 2, y + (height - centeredHeight) / 2, centeredWidth, centeredHeight)
        }
    }
}
