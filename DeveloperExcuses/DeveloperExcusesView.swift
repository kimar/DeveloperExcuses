import Foundation
import ScreenSaver
import OnelinerKit

private extension String {
    static let htmlRegex = "<p class=\"subtitle\">(.+)</p>"
}

private extension URL {
    static let websiteUrl = URL(string: "https://icanhazdadjoke.com/")!
}

class DeveloperExcusesView: OnelinerView {
    override func fetchOneline(_ completion: (String) -> Void) {
        guard let data = try? Data(contentsOf: .websiteUrl), let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        guard let regex = try? NSRegularExpression(pattern: .htmlRegex, options: NSRegularExpression.Options(rawValue: 0)) else {
            return
        }
        
        let quotes = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.lengthOfBytes(using: .utf8))).map { result in
            return (string as NSString).substring(with: result.range(at: 1))
        }
        
        completion(quotes.first!)
    }
}
