//: A UIKit based Playground for presenting user interface
  
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
        sayMessage(message: "☉ Hello human subject! I'm the Sun, creator of all tasty fruits on your planet Earth", seconds: 2.0)
        sayMessage(message: "☉ I can tell you all about any fruit that you send to me", seconds: 7.0)
        sayMessage(message: "☉ Make sure to find a nearby fruit on Earth to begin", seconds: 14.0)
        sayMessage(message: "☉ Then use your metal goggles (camera) to send me a fruit to explore", seconds: 20.0)
        
        print("...")
        // Welcome completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + 7.0 + 14.0) {
            print("Welcome")
            self.hasWelcomedUser = true
            self.setupInteractivity()
        }
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
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    // Rotate sun
    public func rotateSun() {
        UIView.animate(withDuration: 6.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.sunImageView.transform = self.sunImageView.transform.rotated(by: CGFloat(Double.pi))
        }) { completed in
            self.rotateSun()
        }
    }
}

let storyboard = UIStoryboard(name: "Main", bundle: nil)
let view = storyboard.instantiateViewController(withIdentifier: "MainView") as! FruitViewController

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view
