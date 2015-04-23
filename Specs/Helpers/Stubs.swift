//
//  Stubs.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello


func stub<T: Stubbable>(values: [String : AnyObject]) -> T {
    return T.stub(values)
}

func urlFromValue(_ value: AnyObject? = nil) -> NSURL? {
    if value == nil { return nil }
    else if let url = value as? NSURL {
        return url
    } else if let str = value as? String {
        return NSURL(string: str)
    }
    return nil
}

let stubbedTextRegion: TextRegion = stub([:])

protocol Stubbable: NSObjectProtocol {
    static func stub(values: [String : AnyObject]) -> Self
}

extension User: Stubbable {
    class func stub(values: [String : AnyObject]) -> User {

        let relationship = (values["relationshipPriority"] as? String).map {
            Relationship(stringValue: $0)
        } ?? Relationship.None

        var user =  User(
            id: (values["id"] as? String) ?? "1",
            href: (values["href"] as? String) ?? "href",
            username: (values["username"] as? String) ?? "username",
            name: (values["name"] as? String) ?? "name",
            experimentalFeatures: (values["experimentalFeatures"] as? Bool) ?? false,
            relationshipPriority: relationship
            )
        user.avatar = values["avatar"] as? Asset
        user.identifiableBy = values["identifiableBy"] as? String
        user.postsCount = values["postsCount"] as? Int
        user.followersCount = values["followersCount"] as? String
        user.followingCount = values["followingCount"] as? Int
        user.formattedShortBio = values["formattedShortBio"] as? String
        user.externalLinks = values["externalLinks"] as? String
        user.coverImage = values["coverImage"] as? Asset
        user.backgroundPosition = values["backgroundPosition"] as? String
        // links / nested resources
        if let posts = values["posts"] as? [Post] {
            var postIds = [String]()
            for post in posts {
                postIds.append(post.id)
                ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
            }
            user.addLinkArray("posts", array: postIds)
        }
        if let mostRecentPost = values["mostRecentPost"] as? Post {
            user.addLinkObject("most_recent_post", key: mostRecentPost.id, collection: MappingType.PostsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(mostRecentPost, forKey: mostRecentPost.id, inCollection: MappingType.PostsType.rawValue)
        }
        user.profile = values["profile"] as? Profile
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        return user
    }
}

extension Profile: Stubbable {
    class func stub(values: [String : AnyObject]) -> Profile {
        var profile = Profile(
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            shortBio: (values["shortBio"] as? String) ?? "shortBio",
            externalLinksList: (values["externalLinksList"] as? [String]) ?? ["externalLinksList"],
            email: (values["email"] as? String) ?? "email@example.com",
            confirmedAt: (values["confirmedAt"] as? NSDate) ?? NSDate(),
            isPublic: (values["isPublic"] as? Bool) ?? true,
            hasCommentingEnabled: (values["hasCommentingEnabled"] as? Bool) ?? true,
            hasSharingEnabled: (values["hasSharingEnabled"] as? Bool) ?? true,
            hasRepostingEnabled: (values["hasRepostingEnabled"] as? Bool) ?? true,
            hasAdNotificationsEnabled: (values["hasAdNotificationsEnabled"] as? Bool) ?? true,
            allowsAnalytics: (values["allowsAnalytics"] as? Bool) ?? true,
            postsAdultContent: (values["postsAdultContent"] as? Bool) ?? false,
            viewsAdultContent: (values["viewsAdultContent"] as? Bool) ?? false,
            notifyOfCommentsViaEmail: (values["notifyOfCommentsViaEmail"] as? Bool) ?? true,
            notifyOfInvitationAcceptancesViaEmail: (values["notifyOfInvitationAcceptancesViaEmail"] as? Bool) ?? true,
            notifyOfMentionsViaEmail: (values["notifyOfMentionsViaEmail"] as? Bool) ?? true,
            notifyOfNewFollowersViaEmail: (values["notifyOfNewFollowersViaEmail"] as? Bool) ?? true,
            subscribeToUsersEmailList: (values["subscribeToUsersEmailList"] as? Bool) ?? true
            )
        return profile
    }
}

extension Post: Stubbable {
    class func stub(values: [String : AnyObject]) -> Post {

        var post = Post(
            id: (values["id"] as? String) ?? "666",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            href: (values["href"] as? String) ?? "sample-href",
            token: (values["token"] as? String) ?? "sample-token",
            contentWarning: (values["contentWarning"] as? String) ?? "null",
            allowComments: (values["allowComments"] as? Bool) ?? false,
            summary: (values["summary"] as? [Regionable]) ?? [stubbedTextRegion]
            )

        // optional
        post.content = (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
        post.repostContent = (values["repostContent"] as? [Regionable]) ?? [stubbedTextRegion]
        post.repostId = (values["repostId"] as? String)
        post.repostPath = (values["repostPath"] as? String)
        post.repostViaId = (values["repostViaId"] as? String)
        post.repostViaPath = (values["repostViaPath"] as? String)
        post.viewsCount = values["viewsCount"] as? Int
        post.commentsCount = values["commentsCount"] as? Int
        post.repostsCount = values["repostsCount"] as? Int
        // links / nested resources
        if let author = values["author"] as? User {
            post.addLinkObject("author", key: author.id, collection: MappingType.UsersType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, inCollection: MappingType.UsersType.rawValue)
        }
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
            }
            post.addLinkArray("assets", array: assetIds)
        }
        if let comments = values["comments"] as? [Comment] {
            var commentIds = [String]()
            for comment in comments {
                commentIds.append(comment.id)
                ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
            }
            post.addLinkArray("comments", array: commentIds)
        }
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
        return post
    }

    class func stubWithRegions(values: [String : AnyObject], summary: [Regionable] = [], content: [Regionable] = []) -> Post {
        var mutatedValues = values
        mutatedValues.updateValue(summary, forKey: "summary")
        var post: Post = stub(mutatedValues)
        post.content = content
        return post
    }

}

extension Comment: Stubbable {
    class func stub(values: [String : AnyObject]) -> Comment {

        var comment = Comment(
            id: (values["id"] as? String) ?? "888",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            postId: (values["postId"] as? String) ?? "666",
            content: (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
            )

        // links
        if let author = values["author"] as? User {
            comment.addLinkObject("author", key: author.id, collection: MappingType.UsersType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, inCollection: MappingType.UsersType.rawValue)
        }
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
            }
            comment.addLinkArray("assets", array: assetIds)
        }
        if let parentPost = values["parentPost"] as? Post {
            comment.addLinkObject("parent_post", key: parentPost.id, collection: MappingType.UsersType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(parentPost, forKey: parentPost.id, inCollection: MappingType.PostsType.rawValue)
        }
        ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        return comment
    }
}

extension TextRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> TextRegion {
        return TextRegion(
            content: (values["content"] as? String) ?? "Lorem Ipsum"
        )
    }
}

extension ImageRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> ImageRegion {
        var imageRegion = ImageRegion(alt: (values["alt"] as? String) ?? "imageRegion")
        imageRegion.url = urlFromValue(values["url"])
        if let asset = values["asset"] as? Asset {
            imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
        }
        return imageRegion
    }
}

extension UnknownRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> UnknownRegion {
        return UnknownRegion(name: "no-op")
    }
}

extension Activity: Stubbable {
    class func stub(values: [String : AnyObject]) -> Activity {

        let activityKindString = (values["kind"] as? String) ?? Activity.Kind.FriendPost.rawValue
        let subjectTypeString = (values["subjectType"] as? String) ?? SubjectType.Post.rawValue

        let activity = Activity(
            id: (values["id"] as? String) ?? "1234",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            kind: Activity.Kind(rawValue: activityKindString) ?? Activity.Kind.FriendPost,
            subjectType: SubjectType(rawValue: subjectTypeString) ?? SubjectType.Post
            )

        let defaultSubject = activity.subjectType == SubjectType.User ? User.stub([:]) : Post.stub([:])
        if let user = values["subject"] as? User {
            activity.addLinkObject("subject", key: user.id, collection: MappingType.UsersType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        }
        else if let post = values["subject"] as? Post {
            activity.addLinkObject("subject", key: post.id, collection: MappingType.PostsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
        }
        else if let comment = values["subject"] as? Comment {
            activity.addLinkObject("subject", key: comment.id, collection: MappingType.CommentsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        }
        ElloLinkedStore.sharedInstance.setObject(activity, forKey: activity.id, inCollection: MappingType.ActivitiesType.rawValue)
        return activity
    }
}

extension Asset: Stubbable {
    class func stub(values: [String : AnyObject]) -> Asset {
        var asset = Asset(id:  (values["id"] as? String) ?? "1234")
        asset.optimized = values["optimized"] as? Attachment
        asset.smallScreen = values["smallScreen"] as? Attachment
        asset.ldpi = values["ldpi"] as? Attachment
        asset.mdpi = values["mdpi"] as? Attachment
        asset.hdpi = values["hdpi"] as? Attachment
        asset.xhdpi = values["xhdpi"] as? Attachment
        asset.xxhdpi = values["xxhdpi"] as? Attachment
        asset.original = values["original"] as? Attachment
        asset.large = values["large"] as? Attachment
        asset.regular = values["regular"] as? Attachment
        asset.small = values["small"] as? Attachment
        ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
        return asset
    }
}

extension Attachment: Stubbable {
    class func stub(values: [String : AnyObject]) -> Attachment {
        var attachment = Attachment(url: urlFromValue(values["url"]) ?? NSURL(string: "http://www.google.com")!)
        attachment.height = values["height"] as? Int
        attachment.width = values["width"] as? Int
        attachment.type = values["type"] as? String
        attachment.size = values["size"] as? Int
        return attachment
    }
}

extension Notification: Stubbable {
    class func stub(values: [String : AnyObject]) -> Notification {
        return Notification(activity: (values["activity"] as? Activity) ?? Activity.stub([:]))
    }
}
