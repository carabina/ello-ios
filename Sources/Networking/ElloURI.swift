//
//  ElloURI.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import Keys

public enum ElloURI: String {
    // matching stream or page in app
    case Discover = "discover"
    case DiscoverRandom = "discover/random"
    case DiscoverRelated = "discover/related"
    case Enter = "enter"
    case Friends = "friends"
    case Following = "following"
    case Noise = "noise"
    case Notifications = "notifications(\\/?|\\/\\S+)$"
    case OldStylePost = "notifications/posts\\/[^\\/]+\\/?$"
    case Post = "\\/post\\/[^\\/]+\\/?$"
    case Profile = "\\/?$"
    case ProfileFollowers = "followers\\/?$"
    case ProfileFollowing = "following\\/?$"
    case ProfileLoves = "loves\\/?$"
    case Search = "search\\b\\/?(\\?*.)?"
    case SearchPeople = "search/people"
    case SearchPosts = "search/posts"
    case Settings = "settings"
    // other ello pages
    case Confirm = "confirm"
    case BetaPublicProfiles = "beta-public-profiles"
    case Downloads = "downloads"
    case Exit = "exit"
    case FaceMaker = "facemaker"
    case ForgotMyPassword = "forgot-my-password"
    case FreedomOfSpeech = "freedom-of-speech"
    case Invitations = "invitations"
    case Join = "join"
    case Login = "login"
    case Manifesto = "manifesto"
    case NativeRedirect = "native_redirect"
    case Onboarding = "onboarding"
    case PasswordResetError = "password-reset-error"
    case RandomSearch = "random_searches"
    case RequestInvite = "request-an-invite"
    case RequestInvitation = "request-an-invitation"
    case RequestInvitations = "request_invitations"
    case ResetMyPassword = "reset-my-password"
    case Root = "?$"
    case Subdomain = "\\/\\/.+(?<!(w{3}|staging))\\."
    case Starred = "starred"
    case Unblock = "unblock"
    case WhoMadeThis = "who-made-this"
    case WTF = "(wtf$|wtf\\/.*$)"
    // more specific
    case Email = "(.+)@(.+)\\.([a-z]{2,})"
    case External = "https?:\\/\\/.{3,}"

    public var loadsInWebViewFromWebView: Bool {
        switch self {
        case .Discover, .Email, .Enter, .Friends, .Noise, .Notifications, .Post, .Profile, .Root, .Search, .Settings: return false
        default: return true
        }
    }

    public var shouldLoadInApp: Bool {
        switch self {
        case .BetaPublicProfiles,
             .Confirm,
             .Downloads,
             .Email,
             .External,
             .FaceMaker,
             .ForgotMyPassword,
             .FreedomOfSpeech,
             .Invitations,
             .Manifesto,
             .NativeRedirect,
             .PasswordResetError,
             .RandomSearch,
             .RequestInvitation,
             .RequestInvitations,
             .RequestInvite,
             .ResetMyPassword,
             .Subdomain,
             .Unblock,
             .WhoMadeThis:
            return false
        default:
            return true
        }
    }

    // get the proper domain
    private static var _httpProtocol: String?
    public static var httpProtocol: String {
        get {
            return ElloURI._httpProtocol ?? ElloKeys().httpProtocol()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._httpProtocol = newValue
            }
        }
    }
    private static var _domain: String?
    public static var domain: String {
        get {
        return ElloURI._domain ?? ElloKeys().domain()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._domain = newValue
            }
        }
    }
    public static var baseURL: String { return "\(ElloURI.httpProtocol)://\(ElloURI.domain)" }

    // this is taken directly from app/models/user.rb
    static let usernameRegex = "[\\w\\-]+"
    static let fuzzyDomain: String = "((w{3}\\.)?ello\\.co|ello-staging\\d?\\.herokuapp\\.com)"
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)\\/\(ElloURI.usernameRegex)\\??.*" }

    public static func match(url: String) -> (type: ElloURI, data: String) {
        for type in self.all {
            if let _ = url.rangeOfString(type.regexPattern, options: .RegularExpressionSearch) {
                return (type, type.data(url))
            }
        }
        return (self.External, self.External.data(url))
    }

    private var regexPattern: String {
        switch self {
        case .Email, .External: return rawValue
        case .Notifications: return "\(ElloURI.fuzzyDomain)\\/\(rawValue)"
        case .Post: return "\(ElloURI.userPathRegex)\(rawValue)"
        case .OldStylePost: return "\(rawValue)"
        case .Profile: return "\(ElloURI.userPathRegex)\(rawValue)"
        case .ProfileFollowers, .ProfileFollowing, .ProfileLoves: return "\(ElloURI.userPathRegex)\(rawValue)"
        case .Search: return "\(ElloURI.fuzzyDomain)\\/\(rawValue)"
        case .Subdomain: return "\(rawValue)\(ElloURI.fuzzyDomain)"
        default: return "\(ElloURI.fuzzyDomain)\\/\(rawValue)\\/?$"
        }
    }

    private func data(url: String) -> String {
        switch self {
        case .Notifications:
            let urlArr = url.characters.split { $0 == "/" }.map { String($0) }
            return urlArr.last ?? url
        case .ProfileFollowers, .ProfileFollowing, .ProfileLoves:
            let urlArr = url.characters.split { $0 == "/" }.map { String($0) }.filter {
                switch $0 {
                case "following", "followers", "loves": return false
                default: return true
                }
            }
            let last = urlArr.last ?? url
            let lastArr = last.characters.split { $0 == "?" }.map { String($0) }
            return lastArr.first ?? url
        case .Post, .Profile, .OldStylePost:
            let urlArr = url.characters.split { $0 == "/" }.map { String($0) }
            let last = urlArr.last ?? url
            let lastArr = last.characters.split { $0 == "?" }.map { String($0) }
            return lastArr.first ?? url
        case .Search:
            if let urlComponents = NSURLComponents(string: url),
                queryItems = urlComponents.queryItems,
                terms = (queryItems.filter { $0.name == "terms" }.first?.value)
            {
                return terms
            }
            else {
                return ""
            }
        default: return url
        }
    }

    // Order matters: [MostSpecific, MostGeneric]
    static let all = [
        Email,
        Subdomain,
        Post,
        WTF,
        Root,
        // generic / pages
        BetaPublicProfiles,
        Confirm,
        Discover,
        DiscoverRandom,
        DiscoverRelated,
        Downloads,
        Enter,
        Exit,
        ForgotMyPassword,
        FreedomOfSpeech,
        FaceMaker,
        Friends,
        Following,
        Invitations,
        Join,
        Login,
        Manifesto,
        NativeRedirect,
        Noise,
        OldStylePost,
        Notifications,
        Onboarding,
        PasswordResetError,
        RandomSearch,
        RequestInvite,
        RequestInvitation,
        RequestInvitations,
        ResetMyPassword,
        SearchPeople,
        SearchPosts,
        Search,
        Settings,
        Starred,
        Unblock,
        WhoMadeThis,
        // profile specific
        ProfileFollowing,
        ProfileFollowers,
        ProfileLoves,
        Profile,
        // anything else
        External
    ]
}
