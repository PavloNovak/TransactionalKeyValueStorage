//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Pavlo Novak on 2021-06-22.
//

import XCTest

class Tests_iOS: XCTestCase {

    func testSetAndGetValue() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        let expectedResult = "123"

        // Act
        storage.set("foo", "123")

        // Assert
        XCTAssertEqual(storage.get("foo"), expectedResult)
    }
    
    func testSetAndDeleteValue() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        storage.set("foo", "123")
        
        // Act
        storage.delete("foo")
        
        // Assert
        XCTAssertNil(storage.get("foo"))
    }
    
    func testCountOfOccurences() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        storage.set("foo", "123")
        storage.set("bar", "456")
        storage.set("baz", "123")
        
        let firstExpectedResult = 2
        let secondExpectedResult = 1
        
        // Act
        let firstResult = storage.count("123")
        let secondResult = storage.count("456")
        
        // Assert
        XCTAssertEqual(firstResult, firstExpectedResult)
        XCTAssertEqual(secondResult, secondExpectedResult)
    }
    
    func testCommitTransaction() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        let commitExpectedResponse: String? = nil
        let rollbackExpectedResponse: String? = "no transaction"
        let getFooExpectedResult = "456"
        
        // Act
        
        storage.begin()
        storage.set("foo", "456")
        
        let commitResponse = storage.commit()
        let rollbackResponse = storage.rollback()
        let getFooResult = storage.get("foo")
        
        // Assert
        XCTAssertEqual(commitResponse, commitExpectedResponse)
        XCTAssertEqual(rollbackResponse, rollbackExpectedResponse)
        XCTAssertEqual(getFooResult, getFooExpectedResult)
    }
    
    func testRollbackTransaction() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        let getFooExpectedResult = "456"
        let getBarExpectedResult = "def"
        let getFooAfterRollbackExpectedResult = "123"
        let getBarAfterRollbackExpectedResult = "abc"
        let commitExpectedResponse = "no transaction"
        
        // Act
        
        storage.set("foo", "123")
        storage.set("bar", "abc")
        storage.begin()
        storage.set("foo", "456")
        
        let getFooResult = storage.get("foo")
        
        storage.set("bar", "def")
        let getBarResult = storage.get("bar")

        let rollbackResult = storage.rollback()
        
        let getFooAfterRollbackresult = storage.get("foo")
        let getBarAfterRollbackResult = storage.get("bar")
        let commitResult = storage.commit()
        
        // Assert
        XCTAssertEqual(getFooResult, getFooExpectedResult)
        XCTAssertEqual(getBarResult, getBarExpectedResult)
        XCTAssertNil(rollbackResult)
        XCTAssertEqual(getFooAfterRollbackresult, getFooAfterRollbackExpectedResult)
        XCTAssertEqual(getBarAfterRollbackResult, getBarAfterRollbackExpectedResult)
        XCTAssertEqual(commitResult, commitExpectedResponse)
    }
    
    func testNestedTransactions() {
        // Arrange
        var storage = TransactionalKeyValueStorage()
        let firstGetFooExpectedResult = "789"
        let secondGetFooExpectedResult = "456"
        let thirdGetFooExpectedResult = "123"
        
        // Act
        storage.set("foo", "123")
        storage.begin()
        storage.set("foo", "456")
        storage.begin()
        storage.set("foo", "789")
        let firstGetFooResult = storage.get("foo")
        let firstRollBackResult = storage.rollback()
        let secondGetFooResult = storage.get("foo")
        let secondRollBackResult = storage.rollback()
        let thirdGetFooResult = storage.get("foo")
        
        // Assert
        XCTAssertEqual(firstGetFooResult, firstGetFooExpectedResult)
        XCTAssertNil(firstRollBackResult)
        XCTAssertEqual(secondGetFooResult, secondGetFooExpectedResult)
        XCTAssertNil(secondRollBackResult)
        XCTAssertEqual(thirdGetFooResult, thirdGetFooExpectedResult)
    }
}
