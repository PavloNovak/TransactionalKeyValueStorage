//
//  TransactionalKeyValueStorage.swift
//  TransactionalKeyValueStorage
//
//  Created by Pavlo Novak on 2021-06-22.
//

import Foundation

typealias Dictionary = [String: String]
typealias isCommited = Bool

/// Set of comands that transactional key value storage can perform
enum Commands: String, CaseIterable {
    case set
    case get
    case delete
    case count
    case begin
    case commit
    case rollback
}

/// This object represents transactional key value storage.
public class TransactionalKeyValueStorage {
    
    private var transactionsIds: [(UInt, isCommited)] = []
    private var transactionalStorage: [Int: Dictionary] = [-1: [:]]
    
    private var currentTransaction: (UInt, isCommited)? {
        get {
            return transactionsIds.last
        }
        set {
            guard let value = newValue else { return }
            transactionsIds[transactionsIds.count - 1] = value
        }
    }
    
    init() {}
    
    /// Store the value for key
    public func set(_ key: String, _ value: String) {
        
        guard let currentTransactionId = currentTransaction,
              !currentTransactionId.1 else {
            self.transactionalStorage[-1]?.updateValue(value, forKey: key)
            return
        }
        self.transactionalStorage[Int(currentTransactionId.0)]?.updateValue(value, forKey: key)
    }
    
    /// Return the current value for key
    public func get(_ key: String) -> String? {
        
        guard let currentTransactionId = currentTransaction else {
            return self.transactionalStorage[-1]?[key]
        }
        return self.transactionalStorage[Int(currentTransactionId.0)]?[key]
    }
    
    /// Remove the entry for key
    public func delete(_ key: String) {
        guard let currentTransactionId = currentTransaction else {
            self.transactionalStorage[-1]?.removeValue(forKey: key)
            return
        }
        self.transactionalStorage[Int(currentTransactionId.0)]?.removeValue(forKey: key)
    }
    
    /// Return the number of keys that have the given value
    public func count(_ value: String) -> Int {
        return self.transactionalStorage.values
            .map{ $0.values.filter{ $0 == value}}
            .map { $0.count }
            .reduce(0) { $0 + $1 }
    }
    
    /// Start a new transaction
    public func begin() {
        let currentTransactionId = UInt(transactionsIds.count)
        transactionalStorage[transactionsIds.count] = [:]
        
        transactionsIds.append((currentTransactionId, false))
    }
    
    /// Complete ongoing transaction
    public func commit() -> String? {
        guard let currentTransaction = currentTransaction, currentTransaction.1 != true else {
            return "no transaction"
        }
        self.currentTransaction = (currentTransaction.0, true)
        return nil
    }
    
    /// Revert to state prior to BEGIN call
    public func rollback() -> String? {
        guard let currentTransactionId = currentTransaction,
              !currentTransactionId.1 else {
            return "no transaction"
        }
        self.transactionalStorage[Int(currentTransactionId.0)]?.removeAll()
        transactionsIds.removeLast()
        return nil
    }
}
