////
//// Fruit.swift
////
//// This file was automatically generated and should not be edited.
////
//
//import CoreML
//
//
///// Model Prediction Input Type
//@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
//class FruitInput : MLFeatureProvider {
//
//    /// Input image as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
//    var image: CVPixelBuffer
//    
//    var featureNames: Set<String> {
//        get {
//            return ["image"]
//        }
//    }
//    
//    func featureValue(for featureName: String) -> MLFeatureValue? {
//        if (featureName == "image") {
//            return MLFeatureValue(pixelBuffer: image)
//        }
//        return nil
//    }
//    
//    init(image: CVPixelBuffer) {
//        self.image = image
//    }
//}
//
//
///// Model Prediction Output Type
//@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
//class FruitOutput : MLFeatureProvider {
//
//    /// Prediction probabilities as dictionary of strings to doubles
//    let labelProbability: [String : Double]
//
//    /// Class label of top prediction as string value
//    let label: String
//    
//    var featureNames: Set<String> {
//        get {
//            return ["labelProbability", "label"]
//        }
//    }
//    
//    func featureValue(for featureName: String) -> MLFeatureValue? {
//        if (featureName == "labelProbability") {
//            return try! MLFeatureValue(dictionary: labelProbability as [NSObject : NSNumber])
//        }
//        if (featureName == "label") {
//            return MLFeatureValue(string: label)
//        }
//        return nil
//    }
//    
//    init(labelProbability: [String : Double], label: String) {
//        self.labelProbability = labelProbability
//        self.label = label
//    }
//}
//
//
///// Class for model loading and prediction
//@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
//class Fruit {
//    var model: MLModel
//
//    /**
//        Construct a model with explicit path to mlmodel file
//        - parameters:
//           - url: the file url of the model
//           - throws: an NSError object that describes the problem
//    */
//    init(contentsOf url: URL) throws {
//        self.model = try MLModel(contentsOf: url)
//    }
//
//    /// Construct a model that automatically loads the model from the app's bundle
//    convenience init() {
//        let bundle = Bundle(for: Fruit.self)
//        let assetPath = bundle.url(forResource: "Fruit", withExtension:"mlmodelc")
//        try! self.init(contentsOf: assetPath!)
//    }
//
//    /**
//        Make a prediction using the structured interface
//        - parameters:
//           - input: the input to the prediction as FruitInput
//        - throws: an NSError object that describes the problem
//        - returns: the result of the prediction as FruitOutput
//    */
//    func prediction(input: FruitInput) throws -> FruitOutput {
//        let outFeatures = try model.prediction(from: input)
//        let result = FruitOutput(labelProbability: outFeatures.featureValue(for: "labelProbability")!.dictionaryValue as! [String : Double], label: outFeatures.featureValue(for: "label")!.stringValue)
//        return result
//    }
//
//    /**
//        Make a prediction using the convenience interface
//        - parameters:
//            - image: Input image as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
//        - throws: an NSError object that describes the problem
//        - returns: the result of the prediction as FruitOutput
//    */
//    func prediction(image: CVPixelBuffer) throws -> FruitOutput {
//        let input_ = FruitInput(image: image)
//        return try self.prediction(input: input_)
//    }
//}

