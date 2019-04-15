//
//  User.swift
//  FirstCourseFinalTask
//
//  Created by Dev on 24.01.2019.
//  Copyright © 2019 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

struct User: UserProtocol {
  
  var id: UserProtocol.Identifier
  
  var username: String
  
  var fullName: String
  
  var avatarURL: URL?
  
  var currentUserFollowsThisUser: Bool
  
  var currentUserIsFollowedByThisUser: Bool
  
  var followsCount: Int
  
  var followedByCount: Int
  
}
