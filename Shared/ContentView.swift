//
//  ContentView.swift
//  Shared
//
//  Created by Pavlo Novak on 2021-06-22.
//

import SwiftUI

struct ContentView: View {
    
    private var keyValueStorage = StorageService()
    
    @State private var selectedCommand = StorageService.Commands.set
    @State private var output: String = ""
    @State private var input: String = ""
    @State private var isTyping = false
    
    var body: some View {
        VStack {
            if !isTyping {
                if !output.isEmpty {
                    Text("\(output)")
                }
            }
            TextField("", text: $input, onEditingChanged: {
                self.isTyping = $0
            }, onCommit: {
                if output.last != "\n" {
                    output += "\n"
                }
                proceed(with: $selectedCommand.wrappedValue)
            })
            .frame(width: 300)
            .clipped()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("", selection: $selectedCommand) {
                ForEach(StorageService.Commands.allCases, id: \.self) {
                    Text($0.rawValue.uppercased())
                }
            }
            .frame(width: 150)
            .clipped()
        }
    }
    
    private func proceed(with command: StorageService.Commands) {
        switch command {
        case .set:
            let dividedOutput = input.split(separator: " ")
            guard dividedOutput.count == 2 else { return }
            let firstValue = String(dividedOutput[0])
            let secondValue = String(dividedOutput[1])
            keyValueStorage.set(firstValue, secondValue)
        case .get:
            output += keyValueStorage.get(input) ?? "key not set"
        case .delete:
            keyValueStorage.delete(input)
        case .count:
            output += String(keyValueStorage.count(input))
        case .begin:
            keyValueStorage.begin()
        case .commit:
            output += keyValueStorage.commit() ?? ""
        case .rollback:
            output += keyValueStorage.rollback() ?? ""
        }
        self.input = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
