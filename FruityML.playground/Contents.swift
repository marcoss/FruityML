import PlaygroundSupport
import UIKit
import AVFoundation
import CoreML
import Vision

@objc(FruitViewController)
//@available(iOS 11.0, *)
public class FruitViewController : UIViewController, UIPopoverPresentationControllerDelegate {
    // Retrieves information about fruits
    private lazy var fruits = Fruits()
    
    /// MLModelSetup
    private lazy var classificationRequest: VNCoreMLRequest = {
        // Load ML model
        do {
            let model = try VNCoreMLModel(for: Fruit().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            sendMessage(message: "Failed to load Vision model", seconds: 0.0)
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    // For uttering fruit names
    private lazy var synth = AVSpeechSynthesizer()
    
    // Scene image views
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBOutlet weak var hillsImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Button to take or select photo
    @IBOutlet weak var photoButton: UIButton!

    // Message label
    @IBOutlet weak var messageLabel: UILabel!
    
    // Scene is active (used to cancel looping animations)
    private var isActive = true
    
    // AVPlayer
//    private var player: AVAudioPlayer!
    
    // Keep track of cancellations for an easter egg
    private var numberOfCancellations = 0
    
    // When an intro message is fully played out
    private var hasWelcomedUser = false
    private var isBlink = false
    
    // TODO: Debug
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    private var collision: UICollisionBehavior!
    
    // Emojis to "blast" the user
    private lazy var fruitLabels = [UILabel]()
    
    // View did load
    public override func viewDidLoad() {
        messageLabel.layer.zPosition = 100
        photoButton.layer.zPosition = 100
    
        // Animate fade-in transition
        sunImageView.layer.opacity = 0.0
        eyesImageView.layer.opacity = 0.0
        messageLabel.alpha = 0.0
        photoButton.alpha = 0.0
        hillsImageView.alpha = 0.0
        
        hideNavigationBar()
        
        super.viewDidLoad()
    }
    
    // View did appear
    public override func viewDidAppear(_ animated: Bool) {
        createView()

//        if let fruit = fruits.getFruit(name: "pineapple") {
//            displayFruit(fruit: fruit)
//        }
        
        print("View did appear")

        super.viewDidAppear(animated)
    }

    // Make nav bar clear (required for image picker)
    private func hideNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    private func displayFruit(fruit: Fruits.Fruit!) {
        animator = UIDynamicAnimator(referenceView: view)
        
        for _ in 1...6 {
            let label = UILabel()
            label.text = fruit.emoji
            label.layer.zPosition = 0
            label.adjustsFontSizeToFitWidth = true
            label.font = UIFont.systemFont(ofSize: 100)
            label.textAlignment = .center
            label.frame = CGRect(x: (self.view.frame.width / 2)-40, y: 200, width: 80, height: 60)
            
            self.view.addSubview(label)
            
            self.fruitLabels.append(label)
        
            let push = UIPushBehavior(items: [label], mode: UIPushBehaviorMode.instantaneous)
            push.pushDirection = randVector()
            
            animator.addBehavior(push)
        }
        
        gravity = UIGravityBehavior(items: self.fruitLabels)
        
        collision = UICollisionBehavior(items: self.fruitLabels)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        animator.addBehavior(gravity)
        
        sendMessage(message: "👍🏽 This looks like a \(fruit.name!)", seconds: 0.0)
        sendMessage(message: "😝 Fun fact: \(fruit.funFact!)", seconds: 3.0)
        sendMessage(message: "👨‍💼 \(fruit.name!) Nutritional Facts:\nCalories: \(fruit.calories!)\nCarbohydrates: \(fruit.carbohydrates!)g\nPotassium: \(fruit.potassium!)mg\nSugar: \(fruit.sugar!)g\nProtein: \(fruit.protein!)g", seconds: 9.0)
        
        // Speak fruit
        let utterance = AVSpeechUtterance(string: fruit.name)
        utterance.rate = 0.45
        synth.speak(utterance)
    }
    
    // Load the sun
    private func createView() {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.sunImageView.layer.opacity = 1.0
            self.eyesImageView.layer.opacity = 1.0
            self.hillsImageView.layer.opacity = 1.0
        })
        
        // Start rotating the sun
        rotateSun()
        
        blinkEyes()
        
        // Start to welcome user
        startWelcome()
    }
    
    private func enableButtons() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.photoButton.alpha = 1.0
        })
    }
    
    // Start messages
    private func startWelcome() {
        sendMessage(message: "☉ Hello human! I'm the Sun, creator of all tasty fruits on your planet Earth", seconds: 2.0)
        sendMessage(message: "☉ I can tell you about any fruit that you send to me", seconds: 6.0)
        sendMessage(message: "☉ Make sure to find a nearby fruit to begin", seconds: 10.0)
        sendMessage(message: "☉ Then use your metal goggles (camera) to scan a fruit for me", seconds: 14.0)
        
        // Welcome completed, enable photo button
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + 7.0 + 6.5) {
            self.hasWelcomedUser = true
            self.enableButtons()
        }
    }
    
    // Take photo action
    @IBAction func takePicture() {
        if (!self.hasWelcomedUser) {
            return
        }
        
        // Remove emojis from view
        for label in fruitLabels {
            label.removeFromSuperview()
            fruitLabels.removeAll()
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
        
        // Important fix to prevent crashing on Playground
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
    // TODO: Debug on iPad
    public func blinkEyes() {
        if (!isBlink) {
            UIView.animate(withDuration: 0.2, delay: 5.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.isBlink = true
                self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
            }, completion: { _ in UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.isBlink = true
                self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in
                self.isBlink = false
                self.isActive ? self.blinkEyes() : nil
            })
            })
        }
    }
    
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
                if let fruit = self.fruits.getFruit(name: classifications.first!.identifier) {
                    self.displayFruit(fruit: fruit)
                }
  
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
            }
        }
    }
    
    /// Classify an image from a model
    private func handleClassification(for image: UIImage) {
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
    
    // Easter egg to end the game
    private func quitGame() {
        view.backgroundColor = UIColor.black
        
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
            self.sendMessage(message: "The Sun has left", seconds: 0.0)
        }
    }
    
    private func randVector() -> CGVector {
        let xRand = randomNumber(inRange: -3...3)
        let yRand = randomNumber(inRange: -3...3)
        
        return CGVector(dx: xRand, dy: yRand)
    }
    
    private func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
}

extension FruitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        numberOfCancellations += 1
        
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
    
    // Image picker received image
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        // Send image to classifier
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        handleClassification(for: image)
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

public final class Fruits {
    private final let fruitDictionary: [String : Fruit]

    public struct Fruit {
        // Name of fruit
        let name: String!
        
        let emoji: String!
        
        // Calories
        let calories: Int!

        // Carbohydrates (grams)
        let carbohydrates: Double!
        
        // Potassium (milligrams)
        let potassium: Double!

        // Sugar (grams)
        let sugar: Double!
        
        // Protein (grams)
        let protein: Double!
        
        // Fun fact about fruit
        let funFact: String!
    }
    
    public init() {
        fruitDictionary = [
            "strawberry" : Fruit(name: "Strawberry", emoji: "🍓", calories: 4, carbohydrates: 0.9, potassium: 18, sugar: 0.6, protein: 0.1, funFact: "There are 200 seeds on an average strawberry."),
            "apple" : Fruit(name: "Apple", emoji: "🍎", calories: 95, carbohydrates: 25, potassium: 195, sugar: 19, protein: 0.5, funFact: "Apple trees take four to five years to produce their first fruit."),
            "avocado" : Fruit(name: "Avocado", emoji: "🥑", calories: 234, carbohydrates: 12, potassium: 708, sugar: 1, protein: 2.9, funFact: "Americans eat 69 million pounds of avocados on Super Bowl Sunday."),
            "banana" : Fruit(name: "Banana", emoji: "🍌", calories: 105, carbohydrates: 27, potassium: 422, sugar: 14, protein: 1.3, funFact: "Bananas float in water."),
            "blackberry" : Fruit(name: "Blackberry", emoji: "⭐️", calories: 62, carbohydrates: 14, potassium: 233, sugar: 7, protein: 2, funFact: "Harvest time for blackberries run between the months of June to August."),
            "blueberry" : Fruit(name: "Blueberry", emoji: "⭐️", calories: 85, carbohydrates: 21, potassium: 114, sugar: 15, protein: 1.1, funFact: "Blueberries are known to improve memory and motor skills."),
            "cherry" : Fruit(name: "Cherry", emoji: "🍒", calories: 77, carbohydrates: 19, potassium: 268, sugar: 13, protein: 1.6, funFact: "Cherries contain natural melatonin which helps with inflammation and stress."),
            "coconut" : Fruit(name: "Coconut", emoji: "🥥", calories: 1405, carbohydrates: 60, potassium: 1413, sugar: 25, protein: 13, funFact: "There are over 1,300 types of coconut, all originate from the Pacific or the Indian Ocean."),
            "corn" : Fruit(name: "Corn", emoji: "🌽", calories: 606, carbohydrates: 123, potassium: 476, sugar: 5, protein: 16, funFact: "One acre of corn removes about 8 tons of carbon dioxide from the air in one growing season."),
            "grapefruit" : Fruit(name: "Grapefruit", emoji: "🍊", calories: 52, carbohydrates: 13, potassium: 166, sugar: 8, protein: 1, funFact: "A single grapefruit tree can produce more than 1,500 pounds of fruit."),
            "grapes" : Fruit(name: "Grapes", emoji: "🍇", calories: 62, carbohydrates: 16, potassium: 176, sugar: 15, protein: 0.6, funFact: "There are more than 8,000 varieties of grape from about 60 species."),
            "kiwi" : Fruit(name: "Kiwi", emoji: "🥝", calories: 42, carbohydrates: 10, potassium: 215, sugar: 6, protein: 0.8, funFact: "Kiwi fruit contains two times more vitamin C than oranges."),
            "lemon" : Fruit(name: "Lemon", emoji: "🍋", calories: 17, carbohydrates: 5, potassium: 80, sugar: 1.5, protein: 0.6, funFact: "The high acidity of lemons make them good cleaning aids."),
            "lime" : Fruit(name: "Lime", emoji: "🍋", calories: 20, carbohydrates: 7, potassium: 68, sugar: 1.1, protein: 0.5, funFact: "Lime is a rich source of dietary fibers but has 4 times less vitamin C than a lemon."),
            "orange" : Fruit(name: "Orange", emoji: "🍊", calories: 45, carbohydrates: 11, potassium: 174, sugar: 9, protein: 1, funFact: "Christopher Columbus brought the first orange seeds to America in 1493."),
            "peach" : Fruit(name: "Peach", emoji: "🍑", calories: 59, carbohydrates: 14, potassium: 285, sugar: 13, protein: 1.4, funFact: "Peaches originate from China, they have been cultivated since at least 79 A.D."),
            "pear" : Fruit(name: "Pear", emoji: "🍐", calories: 102, carbohydrates: 27, potassium: 206, sugar: 17, protein: 0.6, funFact: "Pears are rich source of dietary fibers, vitamins C and K and minerals."),
            "pineapple" : Fruit(name: "Pineapple", emoji: "🍍", calories: 452, carbohydrates: 119, potassium: 986, sugar: 89, protein: 5, funFact: "It takes almost 3 years for a single pineapple to mature."),
            "plum" : Fruit(name: "Plum", emoji: "⭐️", calories: 30, carbohydrates: 8, potassium: 104, sugar: 7, protein: 0.5, funFact: "Plum trees are grown on every continent except Antarctica."),
            "raspberry" : Fruit(name: "Raspberry", emoji: "🍓", calories: 65, carbohydrates: 15, potassium: 186, sugar: 5, protein: 1.5, funFact: "Raspberries are believed to have originated in Turkey."),
            "tomato" : Fruit(name: "Tomato", emoji: "🍅", calories: 22, carbohydrates: 5, potassium: 292, sugar: 3.2, protein: 1, funFact: "The biggest tomato fight in the world happens each year in Buñol, Spain."),
            "watermelon" : Fruit(name: "Watermelon", emoji: "🍉", calories: 85, carbohydrates: 21, potassium: 314, sugar: 17, protein: 1.7, funFact: "Lycopene is a healthy antioxidant that gives watermelon its red color.")
        ]
    }

    public func getFruit(name: String) -> Fruit? {
        if let index = fruitDictionary.index(forKey: name) {
            return fruitDictionary[index].value
        }
        
        return nil
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
