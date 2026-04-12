//
//  MUClientProtocol.swift
//  iOSMessup
//
//  Created by AI Assistant on 12/4/26.
//

import Foundation

protocol MUClientProtocol {
    func send<ResponseType: Decodable>(_ request: MURequest, as responseType: ResponseType.Type) async throws -> ResponseType
}

extension MUClient: MUClientProtocol {}
