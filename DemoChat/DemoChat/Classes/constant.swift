//
//  constant.swift
//  DemoChat
//
//  Created by Niraj Kumar on 12/21/16.
//  Copyright © 2016 Niraj. All rights reserved.
//

import Foundation
import SocketIO

class constant: NSObject {
    static let sh = constant()
    let socket = SocketIOClient(socketURL: URL(string: "http://192.168.1.108:3000")!, config: [.log(true), .forcePolling(true)])
    var allUsers:[String] = []
}
