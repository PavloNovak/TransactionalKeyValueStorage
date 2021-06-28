# TransactionalKeyValueStorage

https://www.notion.so/Transactional-Key-Value-Store-d72f26aa31e34eef9aa7442507215ce7

TransactionalKeyValueStorage represents transactional key-value storage that can hold nested transactions. Interface does not depend on any third party library.
UI interface to the service is done using SwiftUI.
In order to use a service with UI:
* Run project using Xcode
* Select type of command you want to perform
* Insert key and value separated by whitespace
* Press return on your keyboard
* In case if a command has any return value it will be displayed in an output above the textfield.

## Interface description

### Set of commands in the interface

###### SET
Allows user to set a value by key into current transaction if it was started before OR into base transactional key-value storage.
```swift
public func set(_ key: String, _ value: String)
```

###### GET
Allows user to get a value by key from a current transaction if it was started before OR from the base transactional key-value storage.
```swift
public func get(_ key: String) -> String?
```

###### DELETE
Allows user to delete a key-value pair by key from a current transaction if it was started OR from the base transactional key-value storage.
```swift
public func delete(_ key: String)
```

###### COUNT
Allows user to get number of occurrences of a value from all the transactions in the storage.
```swift
public func count(_ value: String) -> Int
```

###### BEGIN
Allows user to begin(start) new transaction. If no transaction was started or commited before it creates a new parent transaction, otherwise it creates nested transaction in the parent transaction.
```swift
public func begin()
```

###### COMMIT
Allows user to commit a transaction. Returns nil in case of successful commit OR "no transaction" in case if no transaction was started before.
```swift
public func commit() -> String?
```

###### ROLLBACK
Allows user to rollback/destroy a transaction. Returns nil in case if transaction was destroyed or "no transaction" if no transaction was started before.
```swift
public func rollback() -> String?
```

### Tests

Tests are running locally with all the basic scenarios covered.
