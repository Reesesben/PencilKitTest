//
//  ViewController.swift
//  Simple Drawing
//
//  Created by Ben Erekson on 12/27/21.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    //MARK: - IBOutlets
    @IBOutlet var PencilButton: UIBarButtonItem!
    @IBOutlet var CameraButton: UIBarButtonItem!
    @IBOutlet var canvasView: PKCanvasView!
    
    //MARK: - Properties
    let toolPicker = PKToolPicker()
    
    var drawing = PKDrawing()
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup the canvas View.
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
        
        //Initialize and show the Tool Picker
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //zoom out amount 1 or less
        canvasView.minimumZoomScale = 1
        //zoom in amount 1 or more
        canvasView.maximumZoomScale = 5
        //Set current zoom
        canvasView.zoomScale = 1
    }
    

    //MARK: - Actions
    @IBAction func SaveDrawingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContext(canvasView.bounds.size)
        
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }) { sucess, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let displayError = UIAlertController(title: "Error", message: "Error saving image to photos, please check permissions in privacy settings or else", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "Okay", style: .default)
                        displayError.addAction(okay)
                        self.present(displayError, animated: true, completion: nil)
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
                if sucess {
                    DispatchQueue.main.async {
                        let message = UIAlertController(title: "Success", message: "Image was successfully saved to photo library", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "Okay", style: .default)
                        message.addAction(okay)
                        self.present(message, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func pencilFingerToggle(_ sender: Any) {
        canvasView.drawingPolicy = canvasView.drawingPolicy == .anyInput ? .pencilOnly : .anyInput
        PencilButton.title = canvasView.drawingPolicy == .anyInput ? "Pencil Only" : "Finger and Pencil"
    }
    
    //MARK: - PencilKit Functions
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

