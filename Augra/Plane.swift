/*
 Copyright © 2017 Apple Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 SceneKit node wrapper for plane geometry detected in AR.
 */

import Foundation
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var occlusionNode: SCNNode?
    let occlusionPlaneVerticalOffset: Float = -0.01  // The occlusion plane should be placed 1 cm below the actual
    // plane to avoid z-fighting etc.
    var showDebugVisualization = false
    
//    var debugVisualization: PlaneDebugVisualization?
//
//    var focusSquare: FocusSquare?
    
    init(_ anchor: ARPlaneAnchor, _ showDebugVisualization: Bool) {
        self.anchor = anchor
        
        super.init()
        self.showDebugVisualization = showDebugVisualization
        
//        self.showDebugVisualization(showDebugVisualization)
        
        if showDebugVisualization {
            createOcclusionNode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.anchor = anchor
//        debugVisualization?.update(anchor)
        if showDebugVisualization {
            updateOcclusionNode()
        }
    }
    
//    func showDebugVisualization(_ show: Bool) {
//        if show {
//            if debugVisualization == nil {
//                DispatchQueue.global().async {
//                    self.debugVisualization = PlaneDebugVisualization(anchor: self.anchor)
//                    DispatchQueue.main.async {
//                        self.addChildNode(self.debugVisualization!)
//                    }
//                }
//            }
//        } else {
//            debugVisualization?.removeFromParentNode()
//            debugVisualization = nil
//        }
//    }
//
//    func updateOcclusionSetting() {
//        if UserDefaults.standard.bool(for: .useOcclusionPlanes) {
//            if occlusionNode == nil {
//                createOcclusionNode()
//            }
//        } else {
//            occlusionNode?.removeFromParentNode()
//            occlusionNode = nil
//        }
//    }
    
    // MARK: Private
    
    private func createOcclusionNode() {
        // Make the occlusion geometry slightly smaller than the plane.
        let occlusionPlane = SCNPlane(width: CGFloat(anchor.extent.x - 0.05), height: CGFloat(anchor.extent.z - 0.05))
        let material = SCNMaterial()
        material.colorBufferWriteMask = []
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        occlusionPlane.materials = [material]
                
        occlusionNode = SCNNode()
        occlusionNode!.geometry = occlusionPlane
        occlusionNode!.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        occlusionNode!.position = SCNVector3Make(anchor.center.x, occlusionPlaneVerticalOffset, anchor.center.z)
        
        self.addChildNode(occlusionNode!)
        debugBox(modelNode: occlusionNode)
    }
    
    func debugBox(modelNode: SCNNode?, color: UIColor = .green) {
        guard let modelNode = modelNode else { return }
        let boxNode = SCNNode()
        let boundingBoxEnds = modelNode.boundingBox
        
        let boundingBox = SCNBox()
        boundingBox.width = 0.5
        boundingBox.height = 0.1
        boundingBox.length = 0.5
        boxNode.geometry = boundingBox
        
//        boxNode.position = SCNVector3(anchor.center)
        boxNode.position = SCNVector3(0, 0, 0)
        boxNode.geometry?.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.5)
        modelNode.addChildNode(boxNode)
    }
    
    private func updateOcclusionNode() {
        guard let occlusionNode = occlusionNode, let occlusionPlane = occlusionNode.geometry as? SCNPlane else {
            return
        }
        occlusionPlane.width = CGFloat(anchor.extent.x - 0.05)
        occlusionPlane.height = CGFloat(anchor.extent.z - 0.05)
        
        occlusionNode.position = SCNVector3Make(anchor.center.x, occlusionPlaneVerticalOffset, anchor.center.z)
    }
}


