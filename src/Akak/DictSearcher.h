//
//  DictSearcher.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DictSearcher;

@protocol DictSearcherDelegate
- (void)dictSearcherUpdateProgress:(DictSearcher *)searcher progress:(float)progress;
- (void)dictSearcherUpdateTable:(DictSearcher *)searcher index:(int)index;
@end

@interface DictSearcher : NSObject

- (id) initWithLocale: (NSString*)locale;

+ (int) getLivenshteinDistance: (int)maxDistance src:(NSString*)src dst:(NSString*)dst;
-(void) findStringInDictionary: (NSString*)query resultSet: (NSArray*)resultSet distance: (int)distance;
-(BOOL) isWordCorrect: (NSString*)word resultSet: (NSArray*)resultSet;
-(void)makeHashTableLight: (NSMutableArray*) dictionary;
-(void) hashPopulate: (NSString*)query hash: (int)hash hashStart: (int)hashStart depth: (int)depth;
-(void) populateLight: (NSString*)query queryHash: (int)queryHash;
-(int)makeHash: (NSString*)word;
-(void)saveBackupData;
-(BOOL)loadBackupData;

-(NSString*)getWordDescriptionByIdx: (int)index;

@property (nonatomic) BOOL isIndexReady;
@property (nonatomic) BOOL requestToStopSearch;

@property (nonatomic, strong) NSString *locale;

@property (assign, nonatomic) IBOutlet id <DictSearcherDelegate> delegate;
//@property (assign, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
