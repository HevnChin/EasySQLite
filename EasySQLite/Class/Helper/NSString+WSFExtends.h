//
//  WSFString.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WSFExtends)
- (NSString *)firstCharLower;
- (NSString *)firstCharUpper;
-(NSString *)stringReplaceString:(NSString *)replaceString withString:(NSString *)string;
@end

@interface NSMutableString (NSMutableStringCustomExtend)
-(NSMutableString*)appendStrings:(NSString*)aString;
-(NSMutableString *)appendStringBlank:(NSString *)string;
@end
