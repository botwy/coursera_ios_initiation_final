//
//  PostStorage.swift
//  FirstCourseFinalTask
//
//  Created by Dev on 24.01.2019.
//  Copyright © 2019 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

public class PostsStorage: PostsStorageProtocol {
  private var posts: [Post]
  private var likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)]
  private var currentUserId: GenericIdentifier<UserProtocol>
  
  /// Инициализатор хранилища. Принимает на вход массив публикаций, массив лайков в виде
  /// кортежей в котором первый - это ID пользователя, поставившего лайк, а второй - ID публикации
  /// на которой должен стоять этот лайк и ID текущего пользователя.
  required public init(
    posts: [PostInitialData],
    likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)],
    currentUserID: GenericIdentifier<UserProtocol>
    ) {
    self.currentUserId = currentUserID
    self.likes = likes
    var newPostList = [Post]()
    
    posts.forEach{
      initialPost in
      let likedByCount = likes.filter{ $0.1 == initialPost.id }.count
      
      var currentUserLikesThisPost = true
      if (likes.first{ $0.0 == currentUserID && $0.1 == initialPost.id } == nil) {
        currentUserLikesThisPost = false
      }
      
      newPostList.append(
        Post(
          id: initialPost.id,
          author: initialPost.author,
          description: initialPost.description,
          imageURL: initialPost.imageURL,
          createdTime: initialPost.createdTime,
          currentUserLikesThisPost: currentUserLikesThisPost,
          likedByCount: likedByCount
      ))
    }
    
    self.posts = newPostList
  }
  
  /// Количество публикаций в хранилище.
  public var count: Int {
    get {
      return self.posts.count
    }
  }
  
  /// Возвращает публикацию с переданным ID.
  ///
  /// - Parameter postID: ID публикации которую нужно вернуть.
  /// - Returns: Публикация если она была найдена.
  /// nil если такой публикации нет в хранилище.
  public func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
    return self.posts.first{ $0.id == postID }
  }
  
  /// Возвращает все публикации пользователя с переданным ID.
  ///
  /// - Parameter authorID: ID пользователя публикации которого нужно вернуть.
  /// - Returns: Массив публикаций.
  /// Пустой массив если пользователь еще ничего не опубликовал.
  public func findPosts(by authorID: GenericIdentifier<UserProtocol>) -> [PostProtocol] {
    return self.posts.filter{ $0.author == authorID }
  }
  
  /// Возвращает все публикации, содержащие переданную строку.
  ///
  /// - Parameter searchString: Строка для поиска.
  /// - Returns: Массив публикаций.
  /// Пустой массив если нет таких публикаций.
  public func findPosts(by searchString: String) -> [PostProtocol] {
    return posts.filter({
      (post: PostProtocol) -> Bool in
      post.description.hasPrefix(searchString)
    })
  }
  
  /// Ставит лайк от текущего пользователя на публикацию с переданным ID.
  ///
  /// - Parameter postID: ID публикации на которую нужно поставить лайк.
  /// - Returns: true если операция выполнена упешно или пользователь уже поставил лайк
  /// на эту публикацию.
  /// false в случае если такой публикации нет.
  public func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
    if (posts.first{ $0.id == postID } == nil) {
      return false
    }
    if (likes.first{ $0.0 == self.currentUserId && $0.1 == postID } != nil) {
      return true
    }
    let postIndexOptional = posts.firstIndex{ $0.id == postID }
    guard let postIndex = postIndexOptional else {
      return false
    }
    posts[postIndex].currentUserLikesThisPost = true
    likes.append((currentUserId, postID))
    return true
    
  }
  
  /// Удаляет лайк текущего пользователя у публикации с переданным ID.
  ///
  /// - Parameter postID: ID публикации у которой нужно удалить лайк.
  /// - Returns: true если операция выполнена успешно или пользователь и так не ставил лайк
  /// на эту публикацию.
  /// false в случае если такой публикации нет.
  public func unlikePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
    if (posts.first{ $0.id == postID } == nil) {
      return false
    }
    let indexInLikeListForUnlike = likes.firstIndex{ $0.0 == currentUserId && $0.1 == postID }
    if (indexInLikeListForUnlike == nil) {
      return true
    }
    let postIndexOptional = posts.firstIndex{ $0.id == postID }
    guard let postIndex = postIndexOptional else {
      return false
    }
    posts[postIndex].currentUserLikesThisPost = false
    likes.remove(at: indexInLikeListForUnlike!)
    return true
  }
  
  /// Возвращает ID пользователей поставивших лайк на публикацию.
  ///
  /// - Parameter postID: ID публикации лайки на которой нужно искать.
  /// - Returns: Массив ID пользователей.
  /// Пустой массив если никто еще не поставил лайк на эту публикацию.
  /// nil если такой публикации нет в хранилище.
  public func usersLikedPost(with postID: GenericIdentifier<PostProtocol>) -> [GenericIdentifier<UserProtocol>]? {
    if (posts.first{ $0.id == postID } == nil) {
      return nil
    }
    return likes.filter{$0.1 == postID}.map{ $0.0 }
  }
}
