//
//  FeedViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit

// TODO: P1 1 - Import Parse Swift
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }

    private func queryPosts(completion: (() -> Void)? = nil) {
        // TODO: Pt 1 - Query Posts
        // https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/2%20-%20Finding%20Objects.xcplaygroundpage/Contents.swift#L66
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        // 4. TODO: Pt 2 - Only include results created yesterday onwards
        // 5. TODO: Pt 2 - Limit max number of returned posts

                           
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10) // <- Limit max number of returned posts to 10
        // Find and return posts that meet query criteria (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update the local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }

            // Call the completion handler (regardless of error or success, this will signal the query finished)
            // This is used to tell the pull-to-refresh control to stop refresshing
            completion?()
        }
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    @objc private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        queryPosts { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of \(User.current?.username ?? "current account")?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post.comments
        
        return (comments?.count ?? 0) + 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = post.comments ?? []
        
        // regular PostCell
        if indexPath.row == 0 {
            guard let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell
            else {
                return UITableViewCell()
            }
            postCell.configure(with: posts[indexPath.section])
            return postCell
        } else if indexPath.row <= comments.count {
            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell
            else {
                return UITableViewCell()
            }
              // moved to beginning of function.
              // let post = posts[indexPath.section]
              // let comments = post.comments ?? []
    
            if (comments.count > 0) {
                let comment = comments[indexPath.row-1]
                commentCell.nameLabel.text = comment.user?.username
                commentCell.commentLabel.text = comment.text
            }
            
            return commentCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.section]
        let comments = post.comments ?? []
        
        // Check if the tapped row is the "Add Comment" cell
        if indexPath.row == comments.count + 1 {
            showCommentInputAlert(for: post, at: indexPath.section)
        } else {
            // Handle selection of other cells (if needed)
            print("Selected row: \(indexPath.row) in section: \(indexPath.section)")
        }
    }

    private func showCommentInputAlert(for post: Post, at index: Int) {
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter your comment"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let commentText = alertController.textFields?.first?.text, !commentText.isEmpty else {
                return
            }
            
            self?.saveComment(text: commentText, for: post, at: index)
        }
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func saveComment(text: String, for post: Post, at index: Int) {
        var comment = Comment()
        comment.text = text
        comment.post = post
        comment.user = User.current
        
        comment.save { [weak self] result in
            switch result {
            case .success(let savedComment):
                print("Comment saved successfully: \(savedComment)")
                
                var updatedPost = post
                
                if updatedPost.comments == nil {
                    updatedPost.comments = []
                }
                
                updatedPost.comments?.append(savedComment)
                
                updatedPost.save { [weak self] result in
                    switch result {
                    case .success(let savedPost):
                        print("Post updated with new comment: \(savedPost)")
                        DispatchQueue.main.async {
                            // Update the local posts array
                            self?.posts[index] = savedPost
                            // Reload the specific section
                            self?.tableView.reloadSections(IndexSet(integer: index), with: .automatic)
                        }
                    case .failure(let error):
                        print("Error saving post with comment: \(error)")
                    }
                }
                
            case .failure(let error):
                assertionFailure("Error saving Comment: \(error)")
            }
        }
    }
}

extension FeedViewController: UITableViewDelegate { }
