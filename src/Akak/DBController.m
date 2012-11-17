//
//  DBController.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 20/10/12.
//
//

#import "DBController.h"

@implementation DBController

@synthesize database = _database;

//+ (DBController *)instance
//{
//    static DBController *_instance = nil;
//    
//    @synchronized (self)
//    {
//        if (_instance == nil)
//        {
//            _instance = [[self alloc] init];
//        }
//    }
//    
//    return _instance;
//}

- (id)initWithDbPath: (NSString *)dbPath
{
    self = [super init];
    
    if (self)
    {
        self.database = [FMDatabase databaseWithPath: dbPath];
        [self.database open];
    }
    return self;
}

- (void)dealloc
{
    [self.database close];
}

@end
