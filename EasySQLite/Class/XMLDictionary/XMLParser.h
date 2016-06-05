//
//  XMLParser.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/4.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreFoundation/CoreFoundation.h>
#import "TreeNode.h"
@interface XMLParser : NSObject
{
    NSMutableArray      *stack;
}
+ (XMLParser *) sharedInstance;
- (TreeNode *) parseXMLFromPath: (NSString *) path;
- (TreeNode *) parseXMLFromURL: (NSURL *) url;
- (TreeNode *) parseXMLFromData: (NSData*) data;
@end
