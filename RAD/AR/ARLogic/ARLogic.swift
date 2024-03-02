//
//  ARLogic.swift
//  RAD
//
//  Created by Linar Zinatullin on 02/03/24.
//

import SwiftUI

@Observable
class ARLogic {
    
    
    var currentSelectedTool: Tool = .none
    var currentActiveMode: Mode = .none
    var selectedColor: Color = .black
    var modelSelected: Model?
    
    
    var isModifying: Bool = false
    
}

enum Tool{
    case shape
    case brush
    case camera
    case none
    
}

enum Mode {
    case drawing
    case erasing
    case none
}
