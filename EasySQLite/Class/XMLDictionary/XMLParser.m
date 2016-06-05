//
//  XMLParser.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/4.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "XMLParser.h"
@interface XMLParser()<NSXMLParserDelegate>

@end

@implementation XMLParser
static XMLParser *sharedInstance = nil;
// Use just one parser instance at any time
+(XMLParser *) sharedInstance
{
    if(!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
// Parser returns the tree root. You may have to go down one node to the real results
- (TreeNode *) parse: (NSXMLParser *) parser
{
    stack = [NSMutableArray array];
    TreeNode *root = [TreeNode treeNode];
    root.parent = nil;
    root.leafvalue = nil;
    root.children = [NSMutableArray array];
    [stack addObject:root];
    [parser setDelegate:self];
    [parser parse];
    
    // pop down to real root
    TreeNode *realroot = [[root children] lastObject];
    root.children = nil;
    root.parent = nil;
    root.leafvalue = nil;
    root.key = nil;
    realroot.parent = nil;
    return realroot;
}
- (TreeNode *) parseXMLFromPath: (NSString *) path{
    TreeNode *results;
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        results = [self parse:parser];
        return results;
    }
}
- (TreeNode *)parseXMLFromURL: (NSURL *) url
{
    TreeNode *results;
    @autoreleasepool {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        results = [self parse:parser];
        return results;
    }
}
- (TreeNode *)parseXMLFromData: (NSData *) data
{
    TreeNode *results;
    @autoreleasepool {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        results = [self parse:parser];
        return results;
    }

}
// Descend to a new element

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)
namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) elementName = qName;
    TreeNode *leaf = [TreeNode treeNode];
    leaf.attributeDict = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    
    leaf.parent = [stack lastObject];
    [(NSMutableArray *)[[stack lastObject] children] addObject:leaf];
    leaf.key = [NSString stringWithString:elementName];
    leaf.leafvalue = nil;
    leaf.children = [NSMutableArray array];
    [stack addObject:leaf];
}
// Pop after finishing element

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [stack removeLastObject];
}
// Reached a leaf

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (![[stack lastObject] leafvalue])
    {
        [[stack lastObject] setLeafvalue:[NSString stringWithString:string]];
        return;
    }
    [[stack lastObject] setLeafvalue:[NSString stringWithFormat:@"%@%@", [[stack lastObject] leafvalue], string]];
}
@end
