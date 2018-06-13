//
//  ABITests.swift
//  ABITests
//
//  Created by Josh Pyles on 6/13/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Bitski
import Web3
import BigInt

class ABITests: XCTestCase {
    
    /// From Solidity's documentation examples
    func testExampleOne() {
        let uint = UInt32(69)
        let bool = true
        let signature = "0xcdcd77c0"
        do {
            let encoded = try ABI.encodeParameters([.uint(uint), .bool(bool)])
            let result = signature + encoded.replacingOccurrences(of: "0x", with: "")
            let expected = "0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
            XCTAssertEqual(result, expected, "Encoded values should match")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// From Solidity's documentation examples
    func testExampleTwo() {
        let bytes = [
            Data("abc".utf8),
            Data("def".utf8)
        ]
        let signature = "0xfce353f6"
        do {
            let encoded = try ABI.encodeParameters([.fixedArray(bytes, elementType: .bytes(length: 3), length: 2)])
            let result = signature + encoded.replacingOccurrences(of: "0x", with: "")
            let expected = "0xfce353f661626300000000000000000000000000000000000000000000000000000000006465660000000000000000000000000000000000000000000000000000000000"
            XCTAssertEqual(result, expected, "Encoded values should match")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// From Solidity's documentation examples
    func testExampleThree() {
        let data = Data("dave".utf8)
        let bool = true
        let array = [BigInt(1), BigInt(2), BigInt(3)]
        let signature = "0xa5643bf2"
        do {
            let encoded = try ABI.encodeParameters(types: [.bytes(length: nil), .bool, .array(type: .uint, length: nil)], values: [data, bool, array])
            let result = signature + encoded.replacingOccurrences(of: "0x", with: "")
            let expected = "0xa5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
            XCTAssertEqual(result, expected, "Encoded values should match")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEncodeSingle() {
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000001"
        let number = BigUInt(1)
        do {
            let encodedWrapped = try ABI.encodeParameter(.uint(number))
            XCTAssertEqual(encodedWrapped, expected)
            
            let encoded = try ABI.encodeParameter(type: .uint, value: number)
            XCTAssertEqual(encoded, expected)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeSingle() {
        let encoded = "0x0000000000000000000000000000000000000000000000000000000000000001"
        do {
            let decoded = try ABI.decodeParameter(type: .uint, from: encoded)
            XCTAssertEqual(decoded as? BigUInt, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAddressArray() {
        do {
            let array = [
                try EthereumAddress(hex: "0xD11Aa575f9C6f30bEDF392872726b2B157C83131", eip55: false),
                try EthereumAddress(hex: "0x9F2c4Ea0506EeAb4e4Dc634C1e1F4Be71D0d7531", eip55: false)
            ]
            let test = try ABI.encodeParameters([.array(array)])
            let expected = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000d11aa575f9c6f30bedf392872726b2b157c831310000000000000000000000009f2c4ea0506eeab4e4dc634c1e1f4be71d0d7531"
            XCTAssertEqual(test, expected, "Array of addresses should be encoded correctly")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEncodeArray() {
        do {
            let array1 = ["abc", "def", "ghi", "jkl", "mno"]
            let test1 = try ABI.encodeParameters([.array(array1)])
            let expected1 = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000036162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000364656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003676869000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036a6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036d6e6f0000000000000000000000000000000000000000000000000000000000"
            
            XCTAssertEqual(test1, expected1, "Dynamic array of dynamic elements should be correctly encoded")
            
            let test2 = try ABI.encodeParameters([.fixedArray(array1)])
            let expected2 = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000036162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000364656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003676869000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036a6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036d6e6f0000000000000000000000000000000000000000000000000000000000"
            
            XCTAssertEqual(test2, expected2, "Fixed array should be correctly encoded")
            
            let array2 = [true, false, true, false]
            let test3 = try ABI.encodeParameters([.array(array2)])
            let expected3 = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000"
            
            XCTAssertEqual(test3, expected3, "Boolean array should be correctly encoded")
            
            let array3 = [BigInt(1), BigInt(-1), BigInt(2), BigInt(-2)]
            let test4 = try ABI.encodeParameters([.array(array3)])
            let expected4 = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000002fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
            
            XCTAssertEqual(test4, expected4, "Dynamic array of static elements should be correctly encoded")
            
            let array4: [[UInt32]] = [[1,2,3], [4,5,6]]
            let test5 = try ABI.encodeParameters([.array(array4)])
            let expected5 = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
            
            XCTAssertEqual(test5, expected5, "Nested array should be correctly encoded")
            
            let test6 = try ABI.encodeParameters([.fixedArray(array4, elementType: .array(type: .uint32, length: nil), length: 2)])
            let expected6 = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
            
            XCTAssertEqual(test6, expected6, "Fixed array of dynamic array should be correctly encoded")
            
            let test7 = try ABI.encodeParameters([.fixedArray(array4, elementType: .array(type: .uint64, length: 3), length: 2)])
            let expected7 = "0x000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
            
            XCTAssertEqual(test7, expected7, "Fixed array of fixed array should be correctly encoded")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEncodeTuple() {
        let expected = """
        0x\
        0000000000000000000000000000000000000000000000000000000000000020\
        0000000000000000000000000000000000000000000000000000000000000040\
        0000000000000000000000000000000000000000000000000000000000000008\
        000000000000000000000000000000000000000000000000000000000000000b\
        68656c6c6f20776f726c64000000000000000000000000000000000000000000
        """
        do {
            let encoded = try ABI.encodeParameters([.tuple(.string("hello world"), .uint(BigUInt(8)))])
            XCTAssertEqual(encoded, expected, "Tuple should be properly encoded")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testDecodeArray() {
        let test1 = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000036162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000364656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003676869000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036a6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036d6e6f0000000000000000000000000000000000000000000000000000000000"
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .string, length: nil)], from: test1).first as? [String], ["abc", "def", "ghi", "jkl", "mno"], "Dynamic array should be decoded")
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .string, length: 5)], from: test1).first as? [String], ["abc", "def", "ghi", "jkl", "mno"], "Fixed array of dynamic type should be decoded")
        
        let test3 = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000002fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .int256, length: nil)], from: test3).first as? [BigInt], [BigInt(1), BigInt(-1), BigInt(2), BigInt(-2)], "Dynamic array of static elements should be decoded")
        
        let test4 = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .array(type: .uint32, length: nil), length: nil)], from: test4).first as? [[UInt32]],[[1,2,3], [4,5,6]], "Nested array should be decoded")
        
        let test5 = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .array(type: .uint32, length: nil), length: 2)], from: test5).first as? [[UInt32]],[[1,2,3], [4,5,6]], "Nested array should be decoded")
        
        let test6 = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
        
        XCTAssertEqual(try ABI.decodeParameters(types: [.array(type: .array(type: .uint32, length: 3), length: 2)], from: test6).first as? [[UInt32]],[[1,2,3], [4,5,6]], "Nested array should be decoded")
    }
    
    func testDecoderOne() {
        do {
            let example2 = "00000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
            let decoded = try ABI.decodeParameters(types: [.uint32, .bool], from: example2)
            XCTAssertEqual(decoded.first as? UInt32, 69, "The first value should be 69")
            XCTAssertEqual(decoded[1] as? Bool, true, "The second value should be true")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecoderTwo() {
        let example3 = "0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        do {
            let decodedValues = try ABI.decodeParameters(types: [.string, .bool, .array(type: .uint256, length: nil)], from: example3)
            XCTAssertEqual(decodedValues.count, 3, "3 values should be decoded")
            XCTAssertEqual(decodedValues[0] as? String, "dave", "The first value should be dave")
            XCTAssertEqual(decodedValues[1] as? Bool, true, "The second value should be false")
            XCTAssertEqual(decodedValues[2] as? [BigUInt], [1, 2, 3])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecoderBytes() {
        let bytes = Data("Hi!".utf8)
        do {
            let encoded = try ABI.encodeParameters([.bytes(bytes)])
            let decoded = try ABI.decodeParameters(types: [.bytes(length: nil)], from: encoded)
            XCTAssertEqual(decoded[0] as? Data, bytes)
            
            let encodedFixed = try ABI.encodeParameters([.fixedBytes(bytes)])
            let decodedFixed = try ABI.decodeParameters(types: [.bytes(length: UInt(bytes.count))], from: encodedFixed)
            XCTAssertEqual(decodedFixed[0] as? Data, bytes)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodingTuple() {
        let encoded = """
            0000000000000000000000000000000000000000000000000000000000000020\
            0000000000000000000000000000000000000000000000000000000000000040\
            0000000000000000000000000000000000000000000000000000000000000008\
            000000000000000000000000000000000000000000000000000000000000000b\
            68656c6c6f20776f726c64000000000000000000000000000000000000000000
            """
        do {
            let decoded = try ABI.decodeParameters(types: [.tuple([.string, .int])], from: encoded)
            let tupleValue = decoded.first as? [Any]
            XCTAssertEqual(tupleValue?.count, 2, "Decoded tuple should have 2 elements")
            XCTAssertEqual(tupleValue?.first as? String, "hello world", "String value should be decoded correctly")
            XCTAssertEqual(tupleValue?[1] as? BigInt, 8, "Int value should be decoded correctly")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
