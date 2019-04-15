//
//  UserStorage.swift
//  FirstCourseFinalTask
//
//  Created by Dev on 24.01.2019.
//  Copyright © 2019 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

class UsersStorage: UsersStorageProtocol {
  private var users: [User]
  private var followers: [(UserProtocol.Identifier, UserProtocol.Identifier)]
  private var currentUserId: UserProtocol.Identifier
  
  /// Инициализатор хранилища. Принимает на вход массив пользователей, массив подписок в
  /// виде кортежей в котором первый элемент это ID, а второй - ID пользователя на которого он
  /// должен быть подписан и ID текущего пользователя.
  /// Инициализация может завершится с ошибкой если пользователя с переданным ID
  /// нет среди пользователей в массиве users.
  required public init?(
    users: [UserInitialData],
    followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)],
    currentUserID: GenericIdentifier<UserProtocol>
    ) {
    if (users.first { $0.id == currentUserID } == nil) {
      return nil
    }
    
    self.currentUserId = currentUserID
    self.followers = followers
    var newUserList = [User]()
    
    
    users.forEach{
      initialUser in
      let followsCount = followers.filter{ $0.0 == initialUser.id }.count
      let followedByCount = followers.filter{ $0.1 == initialUser.id }.count
      
      var currentUserFollowsThisUser = true
      if (followers.first{ $0.0 == currentUserID && $0.1 == initialUser.id } == nil) {
        currentUserFollowsThisUser = false
      }
      
      var currentUserIsFollowedByThisUser = true
      if (followers.first{ $0.1 == currentUserID && $0.0 == initialUser.id } == nil) {
        currentUserIsFollowedByThisUser = false
      }
      
      newUserList.append(
        User(
          id: initialUser.id,
          username: initialUser.username,
          fullName: initialUser.fullName,
          avatarURL: initialUser.avatarURL,
          currentUserFollowsThisUser: currentUserFollowsThisUser,
          currentUserIsFollowedByThisUser: currentUserIsFollowedByThisUser,
          followsCount: followsCount,
          followedByCount: followedByCount
      ))
    }
    
    self.users = newUserList
  }
  
  /// Количество пользователей в хранилище.
  public var count: Int {
    get {
      return users.count
    }
  }
  
  /// Возвращает текущего пользователя.
  ///
  /// - Returns: Текущий пользователь.
  public func currentUser() -> UserProtocol {
    return users.first{ $0.id == currentUserId }!
  }
  
  /// Возвращает пользователя с переданным ID.
  ///
  /// - Parameter userID: ID пользователя которого нужно вернуть.
  /// - Returns: Пользователь если он был найден.
  /// nil если такого пользователя нет в хранилище.
  public func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
    return users.first{ $0.id == userID }
  }
  
  /// Возвращает всех пользователей, содержащих переданную строку.
  ///
  /// - Parameter searchString: Строка для поиска.
  /// - Returns: Массив пользователей. Если не нашлось ни одного пользователя, то пустой массив.
  public func findUsers(by searchString: String) -> [UserProtocol] {
    return users.filter({
      (user: UserProtocol) -> Bool in
      user.username.hasPrefix(searchString) || user.fullName.hasPrefix(searchString)
    })
  }
  
  /// Добавляет текущего пользователя в подписчики.
  ///
  /// - Parameter userIDToFollow: ID пользователя на которого должен подписаться текущий пользователь.
  /// - Returns: true если текущий пользователь стал подписчиком пользователя с переданным ID
  /// или уже являлся им.
  /// false в случае если в хранилище нет пользователя с переданным ID.
  public func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
    if (users.first{ $0.id == userIDToFollow } == nil) {
      return false
    }
    if (followers.first{ $0.0 == currentUserId && $0.1 == userIDToFollow } != nil) {
      return true
    }
    let currentUserIndexOptional = users.firstIndex{ $0.id == currentUserId }
    let userToFollowIndexOptional = users.firstIndex{ $0.id == userIDToFollow }
    guard let currentUserIndex = currentUserIndexOptional else {
      return false
    }
    guard let userToFollowIndex = userToFollowIndexOptional else {
      return false
    }
    users[currentUserIndex].followsCount += 1
    users[userToFollowIndex].followedByCount += 1
    followers.append((currentUserId, userIDToFollow))
    return true
    
  }
  
  /// Удаляет текущего пользователя из подписчиков.
  ///
  /// - Parameter userIDToUnfollow: ID пользователя от которого должен отписаться текущий пользователь.
  /// - Returns: true если текущий пользователь перестал быть подписчиком пользователя с
  /// переданным ID или и так не являлся им.
  /// false в случае если нет пользователя с переданным ID.
  public func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
    if (users.first{ $0.id == userIDToUnfollow } == nil) {
      return false
    }
    let indexInFollowListToUnfollow = followers.firstIndex{ $0.0 == currentUserId && $0.1 == userIDToUnfollow }
    if (indexInFollowListToUnfollow == nil) {
      return true
    }
    let currentUserIndexOptional = users.firstIndex{ $0.id == currentUserId }
    let userToUnfollowIndexOptional = users.firstIndex{ $0.id == userIDToUnfollow }
    guard let currentUserIndex = currentUserIndexOptional else {
      return false
    }
    guard let userToUnfollowIndex = userToUnfollowIndexOptional else {
      return false
    }
    users[currentUserIndex].followsCount -= 1
    users[userToUnfollowIndex].followedByCount -= 1
    followers.remove(at: indexInFollowListToUnfollow!)
    return true
  }
  
  /// Возвращает всех подписчиков пользователя.
  ///
  /// - Parameter userID: ID пользователя подписчиков которого нужно вернуть.
  /// - Returns: Массив пользователей.
  /// Пустой массив если на пользователя никто не подписан.
  /// nil если такого пользователя нет.
  public func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
    if (users.first{ $0.id == userID } == nil) {
      return nil
    }
    return users.filter({
      (user: UserProtocol) -> Bool in
      followers.first{ $0.1 == userID && $0.0 == user.id } != nil
    })
  }
  
  /// Возвращает все подписки пользователя.
  ///
  /// - Parameter userID: ID пользователя подписки которого нужно вернуть.
  /// - Returns: Массив пользователей.
  /// Пустой массив если он ни на кого не подписан.
  /// nil если такого пользователя нет.
  public func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
    if (users.first{ $0.id == userID } == nil) {
      return nil
    }
    return users.filter({
      (user: UserProtocol) -> Bool in
      followers.first{ $0.0 == userID && $0.1 == user.id } != nil
    })
  }
}
