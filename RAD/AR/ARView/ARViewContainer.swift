//
//  ARViewContainer.swift
//  RAD
//
//  Created by Linar Zinatullin on 02/03/24.
//

import SwiftUI
import RealityKit
import ARKit



struct ARViewContainer: UIViewRepresentable {
    
    @Environment(ARLogic.self) private var arLogic
    
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.arView = arView
        context.coordinator.configureGestureRecognizer()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // Enable people occlusion if available
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        } else if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
            config.frameSemantics.insert(.personSegmentation)
        }
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            arLogic.hasLidar = false
            //
            //            // Enable automatic occlusion of virtual content by the mesh
            //            arView.environment.sceneUnderstanding.options.insert(.occlusion)
        } else {
            arLogic.hasLidar = true
        }
        
        
        arView.session.run(config)
        arView.renderOptions = .disableGroundingShadows
            
           
//        arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
//        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Subscribe for Event update every frame
        context.coordinator.setupSubscriptions()
        
        return arView
    }
    
    
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        
        
        switch arLogic.currentActiveMode {
            
        case .drawing where context.coordinator.drawState != .drawing:
            context.coordinator.drawState = .drawing
        case .shaping where context.coordinator.drawState != .shaping:
            context.coordinator.drawState = .shaping
            //            context.coordinator.selectedModel = arLogic.selectedModel
        case .erasing where context.coordinator.drawState != .erasing:
            context.coordinator.drawState = .erasing
        case .none:
            context.coordinator.drawState = .none
        default:
            break
        }
        
        if UIColor(arLogic.selectedColor) != context.coordinator.selectedColor{
            context.coordinator.selectedColor = UIColor(arLogic.selectedColor)
        }
        
        if arLogic.makingPhoto {
            context.coordinator.captureARViewFrame{ capturedImage in
                if let photo = capturedImage {
                    arLogic.images.append(photo)
                    
                }
            }
            arLogic.makingPhoto = false
        }
        
        
        // Update the AR view
        if let selectedModel = arLogic.selectedModel {
            
            let model = Model(modelName: selectedModel.modelName, shapeType: selectedModel.shapeType)
            
            print("DEBUG: adding model to scene - \(model.modelName)")
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.name = "Shape"
            
            if let modelEntity = model.modelEntity {
                
                anchorEntity.addChild(modelEntity)
                uiView.installGestures([.translation, .rotation, .scale], for: modelEntity)
            }
            
            uiView.scene.addAnchor(anchorEntity)
            DispatchQueue.main.async {
                self.arLogic.selectedModel = nil
            }
        }
        
    }
}

