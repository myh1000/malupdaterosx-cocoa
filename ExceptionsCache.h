//
//  ExceptionsCache.h
//  MAL Updater OS X
//
//  Created by Tail Red on 2/1/15.
//
//

#import <Foundation/Foundation.h>

@interface ExceptionsCache : NSObject
//+(void)addtoExceptions:(NSString *)detectedtitle correcttitle:(NSString *)title aniid:(NSString *)showid threshold:(int)threshold offset:(int)offset;
+(void)addtoExceptions:(NSString *)detectedtitle correcttitle:(NSString *)title aniid:(NSString *)showid threshold:(int)threshold offset:(int)offset ismanga:(NSNumber *)ismanga;
+(void)checkandRemovefromCache:(NSString *)detectedtitle;
+(void)addtoCache:(NSString *)title showid:(NSString *)showid actualtitle:(NSString *) atitle totalepisodes:(int)totalepisodes;
+(void)addtoCache:(NSString *)title showid:(NSString *)showid actualtitle:(NSString *) atitle totalepisodes:(int)totalepisodes ismanga:(NSNumber *)ismanga;
@end
