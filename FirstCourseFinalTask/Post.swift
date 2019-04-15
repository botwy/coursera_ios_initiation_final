//
//  Post.swift
//  FirstCourseFinalTask
//
//  Created by Dev on 24.01.2019.
//  Copyright © 2019 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

public struct Post: PostProtocol {
  
  /// Идентификатор публикации
  public var id: PostProtocol.Identifier
  
  /// Идентификатор автора публикации
  public var author: GenericIdentifier<UserProtocol>
  
  /// Описание публикации
  public var description: String
  
  /// Ссылка на изображение
  public var imageURL: URL
  
  /// Дата создания публикации
  public var createdTime: Date
  
  /// Свойство, отображающее ставил ли текущий пользователь лайк на эту публикацию
  public var currentUserLikesThisPost: Bool
  
  /// Количество лайков на этой публикации
  public var likedByCount: Int
}
