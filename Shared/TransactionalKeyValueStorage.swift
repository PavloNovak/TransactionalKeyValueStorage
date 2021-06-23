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

/// This object gives an access to transactional key value storage
public class StorageService {
    
    private var identifierOfParentTransactions: [Int]
    
    private var transactionalStorage: [TransactionalStorage]
    
    private var hasOngoingTransaction: Bool {
        return !transactionalStorage[identifierOfParentTransactions.count].isCommited
    }
    
    init() {
        self.identifierOfParentTransactions = []
        self.transactionalStorage = [TransactionalStorage(transacitonId: UUID().hashValue, isCommited: true)]
    }
    
    /// Store the value for key into current transaction
    public func set(_ key: String, _ value: String) {
        if hasOngoingTransaction {
            transactionalStorage[identifierOfParentTransactions.count].set(key, value)
            return
        }
        transactionalStorage[0].set(key, value)
    }
    
    /// Return the current value for key from current transaction
    public func get(_ key: String) -> String? {
        return transactionalStorage[identifierOfParentTransactions.count].get(key)
    }
    
    /// Remove the entry for key in current transaction
    public func delete(_ key: String) {
        if hasOngoingTransaction {
            transactionalStorage[identifierOfParentTransactions.count].delete(key)
            return
        }
        transactionalStorage[0].delete(key)
    }
    
    /// Return the number of keys that have the given value
    public func count(_ value: String) -> Int {
        transactionalStorage
            .map { $0.count(value) }
            .reduce(0, +)
    }
    
    /// Start a new transaction
    public func begin() {
        if hasOngoingTransaction {
            transactionalStorage[identifierOfParentTransactions.count].begin()
        } else {
            if transactionalStorage.last?.isCommited == true {
                let newTransactionalStorage = TransactionalStorage(transacitonId: UUID().hashValue)
                transactionalStorage.append(newTransactionalStorage)
                identifierOfParentTransactions.append(identifierOfParentTransactions.count + 1)
                return
            }
        }
    }
    
    /// Complete ongoing transaction
    public func commit() -> String? {
        guard hasOngoingTransaction else {
            return "no transaction"
        }
        transactionalStorage[identifierOfParentTransactions.count].commit()
        return nil
    }
    
    /// Revert to state prior to BEGIN call
    public func rollback() -> String? {
        guard hasOngoingTransaction else {
            return "no transaction"
        }
        
        let currentTransaction = transactionalStorage[identifierOfParentTransactions.count]
        if currentTransaction.nestedTransaction == nil, !currentTransaction.isCommited {
            transactionalStorage[identifierOfParentTransactions.count].rollback()
            transactionalStorage.removeLast()
            identifierOfParentTransactions.removeLast()
            return nil
        }
        transactionalStorage[identifierOfParentTransactions.count].rollback()
        
        return nil
    }
}

class TransactionalStorage {
    let transactionId: Int
    private var storage: Dictionary = [:]
    var nestedTransaction: TransactionalStorage?
    
    var isCommited: Bool = false
    
    init(transacitonId: Int, isCommited: Bool = false) {
        self.transactionId = transacitonId
        self.isCommited = isCommited
    }
    
    fileprivate func set(_ key: String, _ value: String) {
        if let nestedTransaction = nestedTransaction, !nestedTransaction.isCommited {
            nestedTransaction.set(key, value)
        } else {
            storage[key] = value
        }
    }
    
    fileprivate func get(_ key: String) -> String? {
        if let nestedTransaction = nestedTransaction, !nestedTransaction.isCommited {
            return nestedTransaction.get(key)
        } else {
            return storage[key]
        }
    }
    
    fileprivate func delete(_ key: String) {
        if let nestedTransaction = nestedTransaction, !nestedTransaction.isCommited {
            nestedTransaction.delete(key)
        } else {
            storage.removeValue(forKey: key)
        }
    }
    
    fileprivate func count(_ value: String) -> Int {
        if let nestedTransaction = nestedTransaction {
            return nestedTransaction.count(value)
        } else {
            return storage.values.filter{ $0 == value }.count
        }
    }
    
    fileprivate func begin() {
        if let nestedTransaction = nestedTransaction {
            nestedTransaction.begin()
        } else {
            nestedTransaction = TransactionalStorage(transacitonId: UUID().hashValue)
        }
    }
    
    fileprivate func commit() {
        if let nestedTransaction = nestedTransaction, !nestedTransaction.isCommited {
            nestedTransaction.commit()
        } else {
            isCommited = true
        }
    }
    
    fileprivate func rollback() {
        if let nestedTransaction = nestedTransaction, !nestedTransaction.isCommited {
            if nestedTransaction.nestedTransaction == nil {
                self.nestedTransaction = nil
                return
            }
            nestedTransaction.rollback()
        }
    }
}

// MARK: - Deprecated v1.0

/// This object represents transactional key value storage without nesting.
/// It allows user to start a new transaction without closing existing one.
@available(*, deprecated, message: "Use StorageService instead")
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
