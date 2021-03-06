//
//  UpdateManager.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 5/12/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdateManager
{
    // MARK: - Static private properties
    
    static private let githubReleaseURL = URL(string: "https://api.github.com/repos/inickt/LazyMan-iOS/releases")!
    
    /**
     Checks for a current version update.
     */
    static func checkUpdate(completion: @escaping ((String) -> ()), userPressed: Bool = false)
    {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        session.dataTask(with: githubReleaseURL) { (data, response, error) in
            guard let data = data else
            {
                return
            }
            
            guard let json = try? JSON(data: data).arrayValue else { return }
            
            guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
            
            for release in json
            {
                if release["prerelease"].boolValue && !SettingsManager.shared.betaUpdates { continue }
                
                guard let releaseVersion = release["tag_name"].string else { continue }
                
                let releaseVersionNumber = String(releaseVersion.suffix(releaseVersion.count - 1)).replacingOccurrences(of: "-beta", with: "")

                if currentVersion.compare(releaseVersionNumber, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
                {
                    DispatchQueue.main.async {
                        completion("\(release["prerelease"].boolValue ? "Beta version " : "Version ")\(releaseVersionNumber) is now avalible. You have \(currentVersion).")
                    }
                    return
                }
            }
            
            if userPressed
            {
                DispatchQueue.main.async {
                    completion("You are on the latest version.")
                }
            }
        }.resume()
    }
}
