//
//  MKKeywordRegularParser.m
//  SinaMBlog
//
//  Created by jimneylee on 13-2-18.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "MKKeywordRegularParser.h"
#import "NSStringAdditions.h"

static NSString* atRegular = @"@[^.,:;!?()\\s#@。，：；！？（）]+";
static NSString *sharpRegular = @"#(.*?)#";
static NSString* emojiRegular = @"\\[([\u4e00-\u9fa5|OK|NO]+)\\]";
//http://stackoverflow.com/questions/16710554/c-sharp-regex-parse-to-pull-photos-from-markdown
static NSString* imageRegular = @"!\\[.*?\\]\()\\(.*?\\)";

@implementation MKKeywordRegularParser

+ (NSArray *)keywordRangesOfAtPersonInString:(NSString *)string {
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:atRegular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSMutableArray *rangesArray = [NSMutableArray array];
    __block NSString* keyword = nil;
    __block MKPaserdKeyword* keywordEntity = nil;
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange resultRange = [result range];
                             // range & name
                             keyword = [regex replacementStringForResult:result
                                                                        inString:string
                                                                          offset:0
                                                                        template:@"$0"];
                             if (keyword.length) {
                                 // @someone
                                 keyword = [keyword substringWithRange:NSMakeRange(1, keyword.length-1)];
                                 keywordEntity = [[MKPaserdKeyword alloc] init];
                                 keywordEntity.keyword = keyword;
                                 keywordEntity.range = resultRange;
                                 [rangesArray addObject:keywordEntity];
                             }
                         }];
    return rangesArray;
}

+ (NSArray *)keywordRangesOfSharpSoftwareInString:(NSString *)string {
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:sharpRegular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSMutableArray *rangesArray = [NSMutableArray array];
    __block NSString* keyword = nil;
    __block MKPaserdKeyword* keywordEntity = nil;
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange resultRange = [result range];
                             // range & software
                             keyword = [regex replacementStringForResult:result
                                                                inString:string
                                                                  offset:0
                                                                template:@"$0"];
                             if (keyword.length) {
                                 // #software#
                                 keyword = [keyword substringWithRange:NSMakeRange(1, keyword.length-2)];
                                 keywordEntity = [[MKPaserdKeyword alloc] init];
                                 keywordEntity.keyword = keyword;
                                 keywordEntity.range = resultRange;
                                 [rangesArray addObject:keywordEntity];
                             }
                         }];
    return rangesArray;
}

+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)string trimedString:(NSString **)trimedString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emojiRegular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSMutableArray *rangesArray = [NSMutableArray array];
    __block NSMutableString *mutableString = [string mutableCopy];
    __block NSInteger offset = 0;
    __block NSString* keyword = nil;
    __block MKPaserdKeyword* keywordEntity = nil;
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange resultRange = [result range];
                             resultRange.location += offset;
                             // range & emotion
                             keyword = [regex replacementStringForResult:result
                                                                inString:mutableString
                                                                  offset:offset
                                                                template:@"$0"];
                             keywordEntity = [[MKPaserdKeyword alloc] init];
                             keywordEntity.keyword = keyword;
                             keywordEntity.range = resultRange;
                             [rangesArray addObject:keywordEntity];
                             [mutableString replaceCharactersInRange:resultRange withString:@""];
                             offset -= resultRange.length;
                             
                             *trimedString = mutableString;
                         }];
    return rangesArray;
}

+ (NSArray *)imageUrlsInString:(NSString *)string trimedString:(NSString **)trimedString {
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:imageRegular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSMutableArray *imagesArray = [NSMutableArray array];
    __block NSMutableString *mutableString = [string mutableCopy];
    __block NSInteger offset = 0;
    __block NSString *keyword = nil;
    __block NSString *imageUrl = nil;
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange resultRange = [result range];
                             resultRange.location += offset;
                             // image
                             keyword = [regex replacementStringForResult:result
                                                                inString:mutableString
                                                                  offset:offset
                                                                template:@"$0"];
                             NSRange startRange = [keyword rangeOfString:@"]("];
                             if (startRange.length > 0) {
                                 NSRange range = NSMakeRange(startRange.location + startRange.length,
                                                             keyword.length - (startRange.location + startRange.length + 1));
                                 imageUrl = [keyword substringWithRange:range];
                                 [imagesArray addObject:imageUrl];
                             }
                             
                             [mutableString replaceCharactersInRange:resultRange withString:@""];
                             offset -= resultRange.length;
                             
                             *trimedString = mutableString;
                         }];
    return imagesArray;
}

@end
