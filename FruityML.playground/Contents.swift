//#-hidden-code
  
import UIKit
import PlaygroundSupport
import AVFoundation

@objc(FruitViewController)
public class FruitViewController : UIViewController {
    // Scene images
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBOutlet weak var hillsImageView: UIImageView!
    
    // Photo button
    @IBOutlet weak var photoButton: UIButton!
    
    // Label
    @IBOutlet weak var messageLabel: UILabel!
    
    // AVPlayer
    private var player: AVAudioPlayer!
    
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
        blinkEyes()
        
        sayMessage(message: "☉ Hello human! I'm the Sun, creator of all tasty fruits on your planet Earth", seconds: 2.0)
        sayMessage(message: "☉ I can tell you about any fruit that you send to me", seconds: 6.0)
        sayMessage(message: "☉ Make sure to find a nearby fruit on Earth to begin", seconds: 10.0)
        sayMessage(message: "☉ Then use your metal goggles (camera) to send me a fruit to explore", seconds: 16.0)
        
        // Welcome completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + 7.0 + 9.0) {
            print("Welcome")
            self.hasWelcomedUser = true
            self.setupInteractivity()
        }
    }
    
    @IBAction func takePicture() {
        print("Picture did touch")
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    public func setupInteractivity() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.photoButton.alpha = 1.0
        })
    }
    
    // Say message
    public func sayMessage(message: String, seconds: Double) {
        // Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Fade out
            UIView.animate(withDuration: 0.5, animations: {
                self.messageLabel.alpha = 0.0
            }, completion: { finished in
                // Replace label
                self.messageLabel.text = message
                
                
                
                // Fade in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    
                    // create a sound ID, in this case its the tweet sound.
                    
                    
                    self.messageLabel.alpha = 1.0
                }, completion: { finished in
                    self.playSound()
                })
            })
        }
    }
    
    public func playSound() {
        guard let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Rotate sun
    public func rotateSun() {
        UIView.animate(withDuration: 6.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.sunImageView.transform = self.sunImageView.transform.rotated(by: CGFloat(Double.pi))
        }) { done in
            self.rotateSun()
        }
    }
    
    // Blink the sun's eyes (careful they're hot)
    public func blinkEyes() {
        UIView.animate(withDuration: 0.3, delay: 5.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
        }, completion: { done in UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.eyesImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { done in
            self.blinkEyes()
        })
        })
    }
}

extension FruitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        imageView.image = image
//        updateClassifications(for: image)
    }
}
//#-end-hidden-code

let storyboard = UIStoryboard(name: "Main", bundle: nil)
let view = storyboard.instantiateViewController(withIdentifier: "MainView") as! FruitViewController

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view

/*:
 Testing one, two three.
 */
