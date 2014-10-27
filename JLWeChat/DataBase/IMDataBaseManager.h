//
//  IMDataBaseManager.h
//  JLWeChat
//
//  Created by Lee jimney on 6/14/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMDataBaseManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedManager;
- (void)saveContext;

@end
