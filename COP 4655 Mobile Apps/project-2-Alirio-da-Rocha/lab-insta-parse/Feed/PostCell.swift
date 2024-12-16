


import UIKit
import Alamofire
import AlamofireImage
import ParseSwift

import CoreLocation
class PostCell: UITableViewCell {
    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    
    private var imageDataRequest: DataRequest?
    
    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell

        // Username
        if let user = post.user {
            print("Post user objectId: \(user.objectId ?? "nil")")
            print("Post user username: \(user.username ?? "nil")")
            
            // Attempt to fetch the user
            user.fetch { [weak self] result in
                switch result {
                case .success(let fetchedUser):
                    print("Fetched user objectId: \(fetchedUser.objectId ?? "nil")")
                    print("Fetched user username: \(fetchedUser.username ?? "nil")")
                    DispatchQueue.main.async {
                        self?.usernameLabel.text = fetchedUser.username
                    }
                case .failure(let error):
                    print("❌ Error fetching user: \(error.localizedDescription)")
                    // Fallback to the cached username
                    DispatchQueue.main.async {
                        self?.usernameLabel.text = user.username ?? "Unknown User"
                    }
                }
            }
        } else {
            print("No user associated with this post")
            usernameLabel.text = "Unknown User"
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {

            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
        
        // Location - Reverse Geocoding
        if let location = post.location {
            let geoCoder = CLGeocoder()
            let locationObject = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            geoCoder.reverseGeocodeLocation(locationObject) { [weak self] placemarks, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error in reverse geocoding: \(error.localizedDescription)")
                        self?.locationLabel.text = "Location not found"
                        return
                    }
                    
                    if let placemark = placemarks?.first {
                        if let city = placemark.locality {
                            self?.locationLabel.text = city
                        } else {
                            self?.locationLabel.text = "City not found"
                        }
                    }
                }
            }
        } else {
            locationLabel.text = "No location"
        }
        
        // TODO: Pt 2 - Show/hide blur view

        // Get the current user.
        if let currentUser = User.current,

            // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,

            // Get the date the given post was created.
           let postCreatedDate = post.createdAt,

            // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {

            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            blurView.isHidden = abs(diffHours) < 24
        } else {

            // Default to blur if we can't get or compute the date's above for some reason.
            blurView.isHidden = false
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image view image.
        postImageView.image = nil
        
        // Cancel image request.
        imageDataRequest?.cancel()
        

    }
}
