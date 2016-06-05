//
//  NSObject+WSFExtends.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "NSObject+WSFExtends.h"
#import <objc/runtime.h>
#import "NSString+WSFExtends.h"

@implementation NSObject (WSFExtends)
#pragma mark -
#pragma mark - LifeCyle
+(instancetype)allocInit{
    id __autoreleasing obj = [[self alloc] init];
    return obj;
}
+(id)dataWithDictionary:(NSDictionary *)dict{
    Class class = [self class];
    NSObject *obj = [[class alloc] init];
    if(nil == dict || ![dict isKindOfClass:[NSDictionary class]] || [dict count]<=0){
        return obj;
    }
    return [obj setPropertys:dict];
}

#pragma mark -
#pragma mark - Json
NSString * JSONValueFromObj(id obj){
    NSString *jsonString = @"";
    if(nil == obj){
        return jsonString;
    }
    
    if([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]){
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&parseError];
        if(nil == jsonData){
            return jsonString;
        }
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        jsonString = [NSString stringWithFormat:@"%@",obj];
    }
    return jsonString;
}

#pragma mark -
#pragma mark - ValueForKey
- (BOOL)setValue:(id)value forProperty:(NSString *)property{
    @try{
        [self setValue:value forKeyPath:property];
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}
-(id)valueForProperty:(NSString *)key{
    id ret = [self valueForProperty:key className:nil];
    return ret;
}
-(id)valueForProperty:(NSString *)key className:(NSString *)className{
    id ret = nil;
    @try{
        ret = [self valueForKeyPath:key];
    } @catch (NSException *exception) {
        if(nil != className && [className isKindOfClass:[NSString class]] && className.length>0){
            Class class  = NSClassFromString(className);
            if(class){
                ret = [[class alloc] init];
            }
        }else{
            ret = @"";
        }
    } @finally {
        return ret;
    }
}
#pragma mark -
#pragma mark - CustomValueForKey
-(id)objectValueForKey:(NSString *)key{
    id obj = [self valueForProperty:key];
    return obj;
}

-(id)valueStringForProperty:(NSString *)key{
    id ret = [self valueForProperty:key className:NSStringFromClass([NSString class])];
    return ret;
}
-(id)valueArrayForProperty:(NSString *)key{
    id ret = [self valueForProperty:key className:NSStringFromClass([NSArray class])];
    return ret;
}
-(id)valueNumberForProperty:(NSString *)key{
    id ret = [self valueForProperty:key className:NSStringFromClass([NSNumber class])];
    return ret;
}
-(id)valueDictionaryForProperty:(NSString *)key{
    id ret = [self valueForProperty:key className:NSStringFromClass([NSDictionary class])];
    return ret;
}


#pragma mark -
#pragma mark - Propertys
+(NSString *)getPropertyTableType:(NSString *)type{
    NSString * typeHead = [[type componentsSeparatedByString:@","] firstObject];
    /*
     /////
     INTEGER: contains
     INT
     INTEGER
     
     /////
     TEXT: contains
     
     CHARACTER(20)
     VARCHAR(255)
     NVARCHAR(100)
     TEXT
     CLOB
     
     /////  BLOB
     
     /////
     REAL : contains
     REAL
     DOUBLE
     FLOAT
     REAL
     
     /////
     NUMERIC: contains
     
     NUMERIC
     DECIMAL(10,5)
     BOOLEAN
     NUMERIC
     */
    //普通类型
    NSString *typeString = @"";
    if(typeHead.length==2){
        NSDictionary * propertyDictionary= @{ @"Td": @"Real", @"Tf": @"Real", @"Ts": @"Integer", @"Ti": @"Integer",/*int*/ @"Tl": @"Integer",  @"Tc": @"Integer", @"TB": @"Numeric", @"Tq": @"Integer", @"TD": @"REAL",  @"TL": @"Integer", @"TQ": @"Integer", @"TC": @"Integer", @"TS": @"Integer",@"TI":@"Integer"};
    typeString = [propertyDictionary objectForKey:typeHead];
    }else{
        NSString *type = [[typeHead stringReplaceString:@"T@\"" withString:@""] stringReplaceString:@"\"" withString:@""];
        
        Class class = NSClassFromString(type);
        if(NULL != class){
            if([type isEqualToString:NSStringFromClass([NSString class])]){
                typeString = @"Text";
            }else if([type isEqualToString:NSStringFromClass([NSNumber class])]){
                typeString = @"Real";
            }else{
                typeString = type;
            }
        }
    }
    return typeString;
}
+ (NSDictionary*)getPropertyTableMapList{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    objc_property_t *property_t = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = property_t[i];
        const char * name = property_getName (property);//get the property name
        const char * attributes = property_getAttributes (property);//get the type of property
        
        NSString *propertyName = [NSString stringWithCString:name  encoding:NSUTF8StringEncoding];
        NSString *propertyType = [NSString stringWithCString:attributes  encoding:NSUTF8StringEncoding];
        [dict setObject:[self getPropertyTableType:propertyType] forKey:propertyName];
    }
    free(property_t);
    return dict;
}


+(NSDictionary *)getPropertyType:(NSString *)type{
    NSString * typeHead = [[type componentsSeparatedByString:@","] firstObject];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    //普通类型
    if(typeHead.length==2){
        NSDictionary * propertyDictionary= @{ @"Td": @"double", @"Tf": @"float", @"Ts": @"short", @"Ti": @"NSInteger",/*int*/ @"Tl": @"long",  @"Tc": @"char",/*BOOL*/
                                              @"TB": @"bool", @"Tq": @"long long", @"TD": @"long double",  @"TL": @"unsigned long", @"TQ": @"unsigned long long", @"TC": @"unsigned char",
                                              @"TS": @"unsigned short",@"TI":@"unsigned integer"};
        NSString *type = [propertyDictionary objectForKey:typeHead];
        [dict setValue:@(0) forKey:type];
    }else{
        NSString *type = [[typeHead stringReplaceString:@"T@\"" withString:@""] stringReplaceString:@"\"" withString:@""];
        
        Class class = NSClassFromString(type);
        if(NULL != class){
            [dict setValue:[class allocInit] forKey:type];
        }
    }
    return dict;
}
+(NSArray *)getPropertyList{
   return [[self getPropertyMapList] allKeys];
}
+ (NSDictionary*)getPropertyMapList{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    unsigned int count = 0;
    objc_property_t *property_t = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = property_t[i];
        const char * name = property_getName (property);//get the property name
        const char * attributes = property_getAttributes (property);//get the type of property
        
        NSString *propertyName = [NSString stringWithCString:name  encoding:NSUTF8StringEncoding];
        NSString *propertyType = [NSString stringWithCString:attributes  encoding:NSUTF8StringEncoding];
        NSDictionary *propertyTypeDict = [self getPropertyType:propertyType];
        
        [dict setObject:propertyTypeDict forKey:propertyName];
    }
    free(property_t);
    return dict;
}

- (SEL)getGetSelectorWithName:(NSString*)name{
    return NSSelectorFromString(name);
}
- (SEL)getSetSelectorWithName:(NSString*)name{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:",[name firstCharUpper]]);
}
-(id)setPropertys:(NSDictionary*)dict {
    NSDictionary *dictMapList = [[self class] getPropertyMapList];
    
    NSEnumerator *keyEnumor = [dict keyEnumerator];
    NSString *properyName;
    while (nil != (properyName = [keyEnumor nextObject]))
    {
        NSDictionary *pType = [dictMapList objectForKey:properyName];
        
        SEL selector = [self getSetSelectorWithName:properyName];
        if ([self respondsToSelector:selector])
        {
            [self setValue:[[pType allValues] firstObject] forProperty:properyName];
            
            id attributeValue = [dict objectValueForKey:properyName];
            if(![[NSNull null] isEqual:attributeValue]){
                [self setValue:attributeValue forProperty:properyName];
            }
        }
    }
    return self;
}
@end