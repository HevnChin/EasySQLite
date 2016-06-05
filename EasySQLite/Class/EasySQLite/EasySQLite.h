//
//  EasySQLite.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "WSFTable.h"
#import <sqlite3.h>
#import "NSString+WSFExtends.h"
#import "NSObject+WSFExtends.h"

typedef void(^callBackBlock)(NSError *error);

@interface EasySQLite : NSObject
///1. First set the DB file name
+(id)setDBName:(NSString *)dbName;

///2. Obtain an instance of the singleton
+(id)sharedInstance;

#pragma mark -
#pragma mark - Methods
///you should use any SQL
-(void)submitSQL:(NSString *)sql callBackBlock:(callBackBlock)callBack;
///Create Table For Table Model
-(void)createTable:(WSFTable *)table callBackBlock:(callBackBlock)callBack;

- (void)getDataListOfTable:(NSString*)tableName sql:(NSString *)sql success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error;
- (void)getDataListOfTable:(NSString*)tableName sql:(NSString *)sqlString modelClass:(Class)class success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error;
#pragma mark -
#pragma mark - Methods
-(void)getDataListByTable:(NSString*)tableName className:(Class )class wherePropertyDictionary:(NSDictionary *)propertyDictionary
success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error;

///replaceOrInsert
-(void)replaceOrInsertTableName:(NSString*)tableName data:(NSObject *)tableObj callBackBlock:(callBackBlock)callBack;
///delete
-(void)deleteDataForTable:(NSString*)tableName wherePropertyDictionary:(NSDictionary *)propertyDictionary callBackBlock:(callBackBlock)callBack;
@end
