
import UIKit
import PlaygroundSupport
//import AVFoundation
import CoreML
import Vision


@objc(FruitViewController)
//@available(iOS 11.0, *)
public class FruitViewController : UIViewController {
    // Scene images
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBOutlet weak var hillsImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Photo button
    @IBOutlet weak var photoButton: UIButton!
    
    // Label
    @IBOutlet weak var messageLabel: UILabel!
    
    // Game is active
    private var isActive = true
    
    // AVPlayer
//    private var player: AVAudioPlayer!
    
    // Keep track of cancellations for an easter egg
    var numberOfCancellations = 0
    
    // When an intro message is fully played out
    var hasWelcomedUser = false
    
    // View will appear
    public override func viewDidLoad() {
        sunImageView.layer.opacity = 0.0
        eyesImageView.layer.opacity = 0.0
        messageLabel.alpha = 0.0
        photoButton.alpha = 0.0
        hillsImageView.alpha = 0.0
        eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        hideNavigationBar()
    }
    
    // Make nav bar clear (required for image picker)
    public func hideNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    // View did appear
    public override func viewDidAppear(_ animated: Bool) {
        createView()
        super.viewDidAppear(animated)
    }
    
    // Load the sun
    public func createView() {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.sunImageView.layer.opacity = 1.0
            self.eyesImageView.layer.opacity = 1.0
            self.hillsImageView.layer.opacity = 1.0
        })
        
        // Start rotating the sun
        rotateSun()
        
        // Start to welcome user
        startWelcome()
    }
    
    // Start messages
    public func startWelcome() {
//        blinkEyes()
        
        sendMessage(message: "☉ Hello human! I'm the Sun, creator of all tasty fruits on your planet Earth", seconds: 2.0)
        sendMessage(message: "☉ I can tell you about any fruit that you send to me", seconds: 6.0)
        sendMessage(message: "☉ Make sure to find a nearby fruit to begin", seconds: 10.0)
        sendMessage(message: "☉ Then use your metal goggles (camera) to scan a fruit for me", seconds: 14.0)
        
        // Welcome completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + 7.0 + 6.5) {
            self.hasWelcomedUser = true
            self.setupInteractivity()
        }
    }
    
    @IBAction func takePicture() {
        if (!self.hasWelcomedUser) {
            return
        }

        // Important to cast in order to send alerts/segues
        let parentView = self.parent as! UINavigationController
        
        let photoSourcePicker = UIAlertController()

        // Assume camera is available
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .camera)
        }

        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }

        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        
        // Hacky fix to prevent crashing on Playground
        if let popoverController = photoSourcePicker.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: 0, y: view.bounds.size.height, width: view.bounds.size.width, height: 20.0)
            popoverController.permittedArrowDirections = .init(rawValue: 0)
        }

        parentView.present(photoSourcePicker, animated: true)
    }
    
    // Present image picker
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    public func setupInteractivity() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.photoButton.alpha = 1.0
        })
    }
    
    // Say message
    public func sendMessage(message: String, seconds: Double) {
        // Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Fade out
            UIView.animate(withDuration: 0.5, animations: {
                self.messageLabel.alpha = 0.0
            }, completion: { _ in
                // Replace label
                self.messageLabel.text = message

                // Fade in
                UIView.animate(withDuration: 0.5, delay: 0.25, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.messageLabel.alpha = 1.0
                }, completion: { _ in
                    self.playSound()
                })
            })
        }
    }
    
    // TODO: Add sound
    public func playSound() {
    }
    
    // Rotate sun
    public func rotateSun() {
        UIView.animate(withDuration: 6.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.sunImageView.transform = self.sunImageView.transform.rotated(by: CGFloat(Double.pi))
        }) { _ in
            self.isActive ? self.rotateSun() : nil
        }
    }
    
    // Blink the sun's eyes (careful they're hot)
    public func blinkEyes() {
        UIView.animate(withDuration: 0.3, delay: 5.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
        }, completion: { _ in UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { _ in
            self.isActive ? self.blinkEyes() : nil
        })
        })
    }
    
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: Fruit().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                print("Process")
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            self.messageLabel.text = "Failed to load Vision model"
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.messageLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.messageLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.messageLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
//        classificationLabel.text = "Classifying..."
        
        let orientation =
            CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!

        guard let ciImage = CIImage(image: image) else {
            self.messageLabel.text = "Unable to create image from image"
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                self.messageLabel.text = ("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
}

extension FruitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.numberOfCancellations += 1
        
        let phrases = ["☉ No fruit, human? This is the last time I waste my time on Earth",
                       "☉ I always forget how unreliable you humans are",
                       "☉ Cancel on me again and watch what happens to your planet",
                       "☉ Forget it, human, I hear there's life on Mars I can test on",
                       "☉ Look, human, I need your dedication to this experiment",
                       "☉ Send me a photo or I'm leaving to another planet",
                       "☉ Your species was never as smart as the colony on Jupit... Nevermind"]
        let i = Int(arc4random_uniform(UInt32(phrases.count)))

        picker.dismiss(animated: true) {
            if (self.numberOfCancellations > 2) {
                self.sendMessage(message: "You tested my patience human, goodbye!", seconds: 0.0)
                self.quitGame()
            } else {
                self.sendMessage(message: phrases[i], seconds: 0.0)
            }
        }
    }
    
    // Easter egg to end the game
    public func quitGame() {
        self.view.backgroundColor = UIColor.black
        
        isActive = false
        
        UIView.animate(withDuration: 0.5) {
            self.photoButton.alpha = 0.0
            self.eyesImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.sunImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        UIView.animate(withDuration: 1.5, animations: {
            self.hillsImageView.alpha = 0.2
        })
        
        UIView.animate(withDuration: 3.0) {
            self.backgroundImageView.alpha = 0.0
            self.messageLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            self.sendMessage(message: "Brrr...", seconds: 0.0)
        }
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.updateClassifications(for: image)
    }
}


//
// Fruit.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class FruitInput : MLFeatureProvider {
    
    /// Input image as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
    var image: CVPixelBuffer
    
    var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class FruitOutput : MLFeatureProvider {
    
    /// Prediction probabilities as dictionary of strings to doubles
    let labelProbability: [String : Double]
    
    /// Class label of top prediction as string value
    let label: String
    
    var featureNames: Set<String> {
        get {
            return ["labelProbability", "label"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "labelProbability") {
            return try! MLFeatureValue(dictionary: labelProbability as [NSObject : NSNumber])
        }
        if (featureName == "label") {
            return MLFeatureValue(string: label)
        }
        return nil
    }
    
    init(labelProbability: [String : Double], label: String) {
        self.labelProbability = labelProbability
        self.label = label
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class Fruit {
    var model: MLModel
    
    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: Fruit.self)
        let assetPath = bundle.url(forResource: "Fruit", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as FruitInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as FruitOutput
     */
    func prediction(input: FruitInput) throws -> FruitOutput {
        let outFeatures = try model.prediction(from: input)
        let result = FruitOutput(labelProbability: outFeatures.featureValue(for: "labelProbability")!.dictionaryValue as! [String : Double], label: outFeatures.featureValue(for: "label")!.stringValue)
        return result
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - image: Input image as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as FruitOutput
     */
    func prediction(image: CVPixelBuffer) throws -> FruitOutput {
        let input_ = FruitInput(image: image)
        return try self.prediction(input: input_)
    }
}


let storyboard = UIStoryboard(name: "Main", bundle: nil)
let view = storyboard.instantiateViewController(withIdentifier: "MainView") as! FruitViewController
let nav = UINavigationController(rootViewController: view)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = nav

/*:
 Testing one, two three.
 */
