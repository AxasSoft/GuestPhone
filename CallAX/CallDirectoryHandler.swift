//
//  CallDirectoryHandler.swift
//  CallAX
//
//  Created by Сергей Майбродский on 25.03.2020.
//  Copyright © 2020 axas. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        addAllIdentificationPhoneNumbers(to: context)

        context.completeRequest()
    }

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {

        guard let fileUrl = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.AXAS.PhoneCheck")?
                .appendingPathComponent("contacts") else { return }

            guard let reader = LineReader(path: fileUrl.path) else { return }
            for line in reader {
                print(line)
                autoreleasepool {
                    // read number
                    let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // split name and number
                    let components = line.components(separatedBy: ",")
                    
                    // number to int64
                    guard let phone = Int64(components[0]) else { return }
                    let name = components[1]
                    // add number for identification
                    context.addIdentificationEntry(withNextSequentialPhoneNumber: phone, label: name)
                }
            }
        }
    

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {

    }

}




class LineReader {
    let path: String
    
    fileprivate let file: UnsafeMutablePointer<FILE>!
    
    init?(path: String) {
        self.path = path
        
        file = fopen(path, "r")
        
        guard file != nil else { return nil }
        
    }
    
    var nextLine: String? {
        var line:UnsafeMutablePointer<CChar>? = nil
        var linecap:Int = 0
        defer { free(line) }
        return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
    }
    
    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    func  makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine
        }
    }
}

