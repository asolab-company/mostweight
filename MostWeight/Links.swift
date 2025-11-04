import Foundation

enum Links {

    static let applink = URL(string: "https://apps.apple.com/app/id6754883924")!
    static let terms = URL(string: "https://docs.google.com/document/d/e/2PACX-1vQredqKEw5z7oyoRtl8nu0Plh0eqp25mmLI6qNXmFQYcvSGsHWduQr1CNNBtDRAWrYsWfVF5dOJtMjj/pub")!
    static let policy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vQredqKEw5z7oyoRtl8nu0Plh0eqp25mmLI6qNXmFQYcvSGsHWduQr1CNNBtDRAWrYsWfVF5dOJtMjj/pub")!

    static var shareMessage: String {
        """
        Track your weight effortless.No goals, no pressure — just clear, simple data.
        Download the app now:  
        \(applink.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, applink] }
}
