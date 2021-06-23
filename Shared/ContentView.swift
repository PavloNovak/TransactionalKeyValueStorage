//
//  ContentView.swift
//  Shared
//
//  Created by Pavlo Novak on 2021-06-22.
//

import SwiftUI

struct ContentView: View {
    
    private var keyValueStorage = StorageService()
    
    @State private var selectedCommand = Commands.set
    @State var output: String = ""
    @State var input: String = ""
    @State var typing = false
    
    var body: some View {
        VStack {
            if !typing {
                if !output.isEmpty {
                    Text("\(output)")
                }
            }
            TextField("", text: $input, onEditingChanged: {
                self.typing = $0
            }, onCommit: {
                if output.last != "\n" {
                    output += "\n"
                }
                proceed(with: $selectedCommand.wrappedValue)
            })
            .frame(width: 300)
            .clipped()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Command", selection: $selectedCommand) {
                ForEach(Commands.allCases, id: \.self) {
                    Text($0.rawValue.uppercased())
                }
            }
            .frame(width: 150)
            .clipped()
        }
    }
    
    private func proceed(with command: Commands) {
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
