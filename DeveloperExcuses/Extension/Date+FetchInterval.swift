//
//  NSDate+FetchInterval.swift
//  OnelinerKit
//
//  Created by Marcus Kida on 17.12.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import Foundation

extension Date {
    func isFetchDue(since: Date) -> Bool {
        return timeIntervalSinceReferenceDate > since.timeIntervalSinceReferenceDate + .minimumFetchInterval
    }
}
