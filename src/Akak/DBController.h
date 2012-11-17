//
//  DBController.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 20/10/12.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBController : NSObject

- (id)initWithDbPath: (NSString *)dbPath;

@property (nonatomic, strong) FMDatabase *database;

@end
