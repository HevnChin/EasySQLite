//
//  WSFString.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "NSObject+WSFExtends.h"

@implementation NSString (WSFExtends)
- (NSString *)firstCharLower
{
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].lowercaseString];
    if (self.length >= 2) [string appendString:[self substringFromIndex:1]];
    return string;
}

- (NSString *)firstCharUpper
{
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].uppercaseString];
    if (self.length >= 2) [string appendString:[self substringFromIndex:1]];
    return string;
}
-(NSString *)stringReplaceString:(NSString *)replaceString withString:(NSString *)string{
    NSString * strCopy = [self copy];
    
    NSMutableString * str = [NSMutableString stringWithString:strCopy];
    [str replaceOccurrencesOfString:replaceString withString:string options:NSCaseInsensitiveSearch range:(NSRange){0,str.length}];
    return str;
}
@end

@implementation NSMutableString(NSMutableStringCustomExtend)
-(NSMutableString*)appendStrings:(NSString*)aString{
    [self appendString:aString];
    return self;
}
-(NSMutableString *)appendStringBlank:(NSString *)string{
    return [[self appendStrings:string] appendStrings:@" "];
}
@end
