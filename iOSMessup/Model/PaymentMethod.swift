//
//  PaymentMethod.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import Foundation


enum PaymentMethod: String, CaseIterable, Hashable {
    case cash = "Cash"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case paypal = "Paypal"
    case other = "Other"
}
