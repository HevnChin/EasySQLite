//
//  NSObject+WSFExtends.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WSFExtends)
#pragma mark -
#pragma mark - LifeCyle
+(id)dataWithDictionary:(NSDictionary *)dict;

#pragma mark -
#pragma mark - Json
NSString * JSONValueFromObj(id obj);

#pragma mark -
#pragma mark - setValueForKey
- (BOOL)setValue:(id)value forProperty:(NSString *)property;
-(id)valueForProperty:(NSString *)key;
-(id)valueForProperty:(NSString *)key className:(NSString *)className;
#pragma mark -
#pragma mark - CustomValueForKey
-(id)objectValueForKey:(NSString *)key;
-(id)valueStringForProperty:(NSString *)key;
-(id)valueArrayForProperty:(NSString *)key;
-(id)valueNumberForProperty:(NSString *)key;
-(id)valueDictionaryForProperty:(NSString *)key;
///View only the field name
+(NSArray *)getPropertyList;
///Is easy to see the fields and types
+ (NSDictionary*)getPropertyTableMapList;
@end