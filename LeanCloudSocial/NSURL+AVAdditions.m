//
//  NSURL+AVAdditions.m
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import "NSURL+AVAdditions.h"

static NSString *const kQuerySeparator  = @"&";
static NSString *const kQueryDivider    = @"=";
static NSString *const kQueryBegin      = @"?";
static NSString *const kFragmentBegin   = @"#";

@implementation NSURL (AVAdditions)

- (NSDictionary*) av_queryDictionary {
    return self.query.av_URLQueryDictionary;
}

- (NSURL*) av_URLByAppendingQueryDictionary:(NSDictionary*) queryDictionary {
    return [self av_URLByAppendingQueryDictionary:queryDictionary withSortedKeys:NO];
}

- (NSURL *)av_URLByAppendingQueryDictionary:(NSDictionary *)queryDictionary
                             withSortedKeys:(BOOL)sortedKeys
{
    NSMutableArray *queries = self.query ? @[self.query].mutableCopy : @[].mutableCopy;
    NSString *dictionaryQuery = [queryDictionary av_URLQueryStringWithSortedKeys:sortedKeys];
    if (dictionaryQuery) {
        [queries addObject:dictionaryQuery];
    }
    NSString *newQuery = [queries componentsJoinedByString:kQuerySeparator];
    
    if (newQuery.length) {
        NSArray *queryComponents = [self.absoluteString componentsSeparatedByString:kQueryBegin];
        if (queryComponents.count) {
            return [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@%@%@%@%@",
                     queryComponents[0],                      // existing url
                     kQueryBegin,
                     newQuery,
                     self.fragment.length ? kFragmentBegin : @"",
                     self.fragment.length ? self.fragment : @""]];
        }
    }
    return self;
}

@end

#pragma mark -

@implementation NSString (AVAdditions)

- (NSDictionary*) av_URLQueryDictionary {
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self componentsSeparatedByString:kQuerySeparator]) {
        NSArray *components = [query componentsSeparatedByString:kQueryDivider];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}

@end

#pragma mark -

@implementation NSDictionary (AVAdditions)

- (NSString *)av_URLQueryString {
    return [self av_URLQueryStringWithSortedKeys:NO];
}

- (NSString*) av_URLQueryStringWithSortedKeys:(BOOL)sortedKeys {
    NSMutableString *queryString = @"".mutableCopy;
    NSArray *keys = sortedKeys ? [self.allKeys sortedArrayUsingSelector:@selector(compare:)] : self.allKeys;
    for (NSString *key in keys) {
        id rawValue = self[key];
        NSString *value = nil;
        // beware of empty or null
        if (!(rawValue == [NSNull null] || ![rawValue description].length)) {
            value = [[self[key] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [queryString appendFormat:@"%@%@%@%@",
         queryString.length ? kQuerySeparator : @"",    // appending?
         [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
         value ? kQueryDivider : @"",
         value ? value : @""];
    }
    return queryString.length ? queryString.copy : nil;
}

@end
