//
//  NSURL+AVAdditions.h
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import <Foundation/Foundation.h>

@interface NSURL (AVAdditions)
/**
 *  @return URL's query component as keys/values
 *  Returns nil for an empty query
 */
- (NSDictionary*) av_queryDictionary;

/**
 *  @return URL with keys values appending to query string
 *  @param queryDictionary Query keys/values
 *  @param sortedKeys Sorted the keys alphabetically?
 *  @warning If keys overlap in receiver and query dictionary,
 *  behaviour is undefined.
 */
- (NSURL*) av_URLByAppendingQueryDictionary:(NSDictionary*) queryDictionary
                             withSortedKeys:(BOOL) sortedKeys;

/** As above, but `sortedKeys=NO` */
- (NSURL*) av_URLByAppendingQueryDictionary:(NSDictionary*) queryDictionary;

@end

#pragma mark -

@interface NSString (AVAdditions)

/**
 *  @return If the receiver is a valid URL query component, returns
 *  components as key/value pairs. If couldn't split into *any* pairs,
 *  returns nil.
 */
- (NSDictionary*) av_URLQueryDictionary;

@end

#pragma mark -

@interface NSDictionary (AVAdditions)

/**
 *  @return URL query string component created from the keys and values in
 *  the dictionary. Returns nil for an empty dictionary.
 *  @param sortedKeys Sorted the keys alphabetically?
 *  @see cavetas from the main `NSURL` category as well.
 */
- (NSString*) av_URLQueryStringWithSortedKeys:(BOOL) sortedKeys;

/** As above, but `sortedKeys=NO` */
- (NSString*) av_URLQueryString;

@end
