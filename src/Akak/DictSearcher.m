//
//  DictSearcher.m
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictSearcher.h"
#import "DictIndex.h"
#import "Resources.h"
#import "DictEntry.h"
#import "DBController.h"
#import "FMResultSet.h"

@interface DictSearcher()

@property (strong, nonatomic) NSString *alphabet;
@property (nonatomic) int *alphabetMap;
@property (nonatomic) int **hashTableLight;
@property (nonatomic) int *hashCountTable;
@property (nonatomic) int hashTableCount;
@property (nonatomic) int wordsCount;
@property (nonatomic) int distance;
@property (assign, nonatomic) NSMutableArray *dictionary;
@property (assign, nonatomic) NSArray *resultSet;

@property (strong, nonatomic) DBController* db;
@property (strong, nonatomic) FMResultSet *resultTable;

//@property (nonatomic, strong) NSMutableDictionary *dictEntry;
//@property (nonatomic, strong) NSMutableDictionary *dictIndex;

-(int)getCharPosition: (unichar)ch;
-(void)loadIndexData;
-(void)loadDictionaryData;

-(int *)makeAlphabetMap;

@end

@implementation DictSearcher

#define HASH_SIZE 16
#define MAX_DISTANCE 3
#define MAX_ELEMENTS_WITH_MAX_DISTANCE 200

@synthesize alphabet = _alphabet;
@synthesize alphabetMap = _alphabetMap;
@synthesize isIndexReady = _isIndexReady;
@synthesize dictionary = _dictionary;
@synthesize hashTableLight = _hashTableLight;
@synthesize hashCountTable = _hashCountTable;
@synthesize hashTableCount = _hashTableCount;
@synthesize delegate = _delegate;
@synthesize wordsCount = _wordsCount;
//@synthesize managedObjectContext = _managedObjectContext;
@synthesize resultSet = _resultSet;
@synthesize distance = _distance;
@synthesize requestToStopSearch = _requestToStopSearch;
//@synthesize dictEntry = _dictEntry;
//@synthesize dictIndex = _dictIndex;
@synthesize locale = _locale;
@synthesize db = _db;
@synthesize resultTable = _resultTable;

- (id) initWithLocale: (NSString*)locale
{
    if ( self = [super init] )
    {
        _locale = locale;
        
        NSString *dbFile = nil;
        
        if ([self.locale isEqualToString:APP_LOCALE_RU])
        {
            _alphabet = ALPHABET_RU;
            dbFile = [[NSBundle mainBundle] pathForResource:@"ModelRU" ofType:@"sqlite"];
            //dbFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"ModelRU.sqlite"];
        }
        else
        {
            _alphabet = ALPHABET_EN;
            dbFile = [[NSBundle mainBundle] pathForResource:@"ModelEN" ofType:@"sqlite"];

            //dbFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"ModelEN.sqlite"];
        }
        
        _db = [[DBController alloc] initWithDbPath: dbFile];
        _alphabetMap = [self makeAlphabetMap];
        
//        NSLog (@"DictEntry count: %u", self.dictEntry.count);
//        NSLog (@"DictIndex count: %u", self.dictIndex.count);

    }
    return self;
}

-(NSString*)alphabet
{
    if (_alphabet == nil)
    {
        _alphabet = ALPHABET_RU;
    }
    return _alphabet;
}

//- (NSMutableDictionary*)dictEntry
//{
//    if (_dictEntry == nil)
//    {
//#if DO_BACKUP == 0
//        
//        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *dictEntryFile = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory, self.locale, @"dictEntry.bin"];
//        
//        _dictEntry = [[NSMutableDictionary alloc] initWithContentsOfFile: dictEntryFile];
//#else
//        _dictEntry = [[NSMutableDictionary alloc] init];
//#endif
//    }
//    return _dictEntry;
//}
//
//- (NSMutableDictionary*)dictIndex
//{
//    if (_dictIndex == nil)
//    {
//#if DO_BACKUP == 0
//        
//        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *dictIndexFile = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory, self.locale, @"dictIndex.bin"];
//        
//        _dictIndex = [[NSMutableDictionary alloc] initWithContentsOfFile: dictIndexFile];
//#else
//        _dictIndex = [[NSMutableDictionary alloc] init];
//#endif
//    }
//    return _dictIndex;
//}

-(int)getCharPosition: (unichar)ch
{
    return 0;
}

-(int*)hashCountTable
{
    if (_hashCountTable == nil)
    {
        _hashCountTable = (int*)malloc((1 << HASH_SIZE) * sizeof(int));
        memset(_hashCountTable, 0, (1 << HASH_SIZE) * sizeof(int));
    }
    return _hashCountTable;
}

-(int*)alphabetMap
{
    if (_alphabetMap == nil)
    {
        _alphabetMap = [self makeAlphabetMap];
    }
    return _alphabetMap;
}

-(int**)hashTableLight
{
    if (_hashTableLight == nil)
    {
        _hashTableLight = (int**)malloc((1 << HASH_SIZE) * sizeof(int*));
        memset(_hashTableLight, 0, (1 << HASH_SIZE) * sizeof(int*));
    }
    return _hashTableLight;
}

-(BOOL) isWordCorrect: (NSString*)word resultSet: (NSArray*)resultSet
{    
    self.resultSet = resultSet;
    self.distance = 0;
    
    int stringHash = [self makeHash: word];
    [self populateLight: word queryHash:stringHash];
    
    if ([[resultSet objectAtIndex:0] count] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSString*)getWordDescriptionByIdx: (int)index
{
    NSString *result = NO_SUCH_WORD_IN_DICT;
//    NSError *error = nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %d", index];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DictEntry" 
//                                              inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    if (error != nil)
//    {
//        NSLog(@"DictEntity Fetch error: %@", error);
//    }
    
    self.resultTable = [self.db.database executeQuery:[NSString stringWithFormat: @"select ZVALUE from ZDICTENTRY where ZID=%d", index]];
    
    while ([self.resultTable next])
    {
        result = [self.resultTable stringForColumn:@"ZVALUE"];
        break;
    }
    
    [self.resultTable close];

    //result = [self.dictEntry objectForKey: [NSString stringWithFormat:@"%d", index]];
    
//    if (result == nil)
//    {
//        result = NO_SUCH_WORD_IN_DICT;
//    }
    
//    for (DictEntry *dictEntity in fetchedObjects)
//    {
//        result = dictEntity.value;
//        break;
//    }    

    return result;
}

-(void) findStringInDictionary: (NSString*)query resultSet: (NSArray*)resultSet distance:(int)distance
{
    [self.delegate dictSearcherUpdateProgress:self progress:0.0];
    
    self.resultSet = resultSet;
    self.distance = distance;
    self.requestToStopSearch = NO;
    
    int stringHash = [self makeHash: query];
    
    [self populateLight: query queryHash:stringHash];
    [self.delegate dictSearcherUpdateProgress:self progress:0.0];

    if (distance > 0)
    {
        [self hashPopulate: query hash:stringHash hashStart:0 depth:self.distance-1];
    }
    [self.delegate dictSearcherUpdateProgress:self progress:1.0];
}

-(void) hashPopulate: (NSString*)query hash: (int)hash hashStart: (int)hashStart depth: (int)depth
{
    for (int i = hashStart; i < HASH_SIZE; ++i)
    {   
        int queryHash = hash ^ (1 << i);
        [self populateLight:query queryHash:queryHash];
        
        if (depth > 0)
        {
            [self hashPopulate: query hash:queryHash hashStart:i+1 depth:depth-1];
        }
        
        if (self.requestToStopSearch == YES)
        {
            return;
        }
    }
}

-(void) populateLight: (NSString*)query queryHash: (int)queryHash
{       
    int *hashBucket = self.hashTableLight[queryHash];
    
    if (hashBucket == nil)
    {
        return;
    }
    
    for (int dictionaryIndex=0; dictionaryIndex<self.hashCountTable[queryHash]; dictionaryIndex++)
    {            
        NSString *word = [self.dictionary objectAtIndex:hashBucket[dictionaryIndex]];
        
        int currDistance = [DictSearcher getLivenshteinDistance:self.distance src:query dst:word];
        
        if (currDistance == MAX_DISTANCE && [[self.resultSet objectAtIndex: currDistance] count] >= MAX_ELEMENTS_WITH_MAX_DISTANCE)
        {
            continue;
        }
        
        if (currDistance <= self.distance)
        {
            [[self.resultSet objectAtIndex: currDistance] addObject:[NSString stringWithFormat:@"%@ %d", word, hashBucket[dictionaryIndex]]];
            
            [[self.resultSet objectAtIndex:currDistance] sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            [self.delegate dictSearcherUpdateTable: self index:currDistance];                
        }
        
        if (self.requestToStopSearch == YES)
        {
            return;
        }
    }
}

-(void)makeHashTableLight: (NSMutableArray*) dictionary
{
    if (self.isIndexReady == YES)
    {
        return;
    }
    
    [self.delegate dictSearcherUpdateProgress:self progress:0.0];
    int counter = 0;
    float totalSize = dictionary.count * 2.0;
    _dictionary = dictionary;
        
    if ([self loadBackupData] == NO)
    {
        int *hashCountTableDup = (int*)malloc((1 << HASH_SIZE) * sizeof(int));
        memset(hashCountTableDup, 0, (1 << HASH_SIZE) * sizeof(int));

        for (NSString *word in dictionary)
        {   
            if (counter % 1000 == 0)
            {
                [self.delegate dictSearcherUpdateProgress:self progress:(counter/totalSize)];
            }
            counter++;
        
            int hash = [self makeHash: word];        
            self.hashCountTable[hash]++;        
        }
        
        counter = dictionary.count;
        [self.delegate dictSearcherUpdateProgress:self progress:(counter/totalSize)];
        
        self.hashTableCount = 0;
        
        memcpy(hashCountTableDup, self.hashCountTable, (1 << HASH_SIZE) * sizeof(int));
        
        for (int i = 0; i < dictionary.count; ++i)
        {        
            int hash = [self makeHash: [dictionary objectAtIndex:i]];
            
            if (self.hashTableLight[hash] == 0)
            {
                self.hashTableCount++;
                int capacity = self.hashCountTable[hash];
                
                self.hashTableLight[hash] = (int*)malloc(capacity * sizeof(int));
                memset(self.hashTableLight[hash], 0, capacity * sizeof(int));
            }
            
            self.hashTableLight[hash][--self.hashCountTable[hash]] = i;
            
            if (counter % 1000 == 0)
            {
                [self.delegate dictSearcherUpdateProgress:self progress:counter/totalSize];
            }
            counter++;
        }
        
        free(self.hashCountTable);
        _hashCountTable = hashCountTableDup;
        
        //[self saveBackupData];
    }        
    
    [self.delegate dictSearcherUpdateProgress:self progress:1.0];

    self.isIndexReady = YES;
}

-(void)saveToDB: (int) key data:(NSData*)data
{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    DictIndex *dictIndex = [NSEntityDescription
//                            insertNewObjectForEntityForName:@"DictIndex" 
//                            inManagedObjectContext:context];
//    dictIndex.id = [NSNumber numberWithInt: key];
//    dictIndex.data = data;
//    
//    NSError *error = nil;
//    if (![context save:&error])
//    {
//        NSLog(@"Error while saving to db: %@", [error localizedDescription]);
//    }
    
    //[self.dictIndex setObject: data forKey:[NSString stringWithFormat:@"%d", key]];
}

-(void)packData: (NSData*)data
{
    
}

-(void)parseAndSaveDict
{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"full_dict_ru" ofType:@"txt"];
    NSArray *fullDict = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] 
                                    componentsSeparatedByString:@"\r"];
//    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (error != nil)
    {
        NSLog(@"Error: %@", error);
    }
    
    NSLog(@"Full dict contains: %d records", fullDict.count);
    NSLog(@"Size of first record: %d", [[fullDict objectAtIndex:0] length]);
    BOOL newWordStarted = NO;
    int wordIdx = 0;
    int counter = 0;
    NSMutableString *description = nil;
    
    for (NSString *fullEntry in fullDict)
    {        
        if (fullEntry.length > 0 && [fullEntry characterAtIndex:0] != ' ')
        {
            if (newWordStarted == YES)
            {
                //finish word
                //[self.dictEntry setObject: description forKey: [NSString stringWithFormat:@"%d", wordIdx]];

//                DictEntry *dictEntity = [NSEntityDescription
//                                         insertNewObjectForEntityForName:@"DictEntry" 
//                                         inManagedObjectContext:context];
//                dictEntity.id = [NSNumber numberWithInt: wordIdx];
//                dictEntity.value = description;
//                
//                NSError *error = nil;
//                if (![context save:&error])
//                {
//                    NSLog(@"Error while saving word to db: %@", [error localizedDescription]);
//                }
                
                counter++;
                
                newWordStarted = NO;
                description = nil;
            }
            wordIdx = -1;
            for (NSString *word in self.dictionary)
            {
                wordIdx++;

                if (word.length == fullEntry.length && [word isEqualToString:fullEntry])
                {
                    newWordStarted = YES;
                    description = [[NSMutableString alloc] init];
                    break;
                }
                else
                {
                    newWordStarted = NO;
                }
            }
        }
        else
        {
            if (newWordStarted == NO)
            {
                continue;
            }
            else
            {
                //collect description
                [description appendString:@"\n"];
                [description appendString:fullEntry];
                [description appendString:@"\n"];
            }
        }
    }
    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *dictEntryFile = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory, self.locale, @"dictEntry.bin"];
//    
//    [self.dictEntry writeToFile:dictEntryFile atomically: YES];
//    
    NSLog(@"Total %d local dict entries saved", counter);
}

-(void)saveBackupData
{
#if DO_BACKUP == 0
    return;
#endif
    
    NSData * data = [NSData dataWithBytes:self.hashCountTable length:(1 << HASH_SIZE)*sizeof(int)];    
    [self saveToDB: 0 data:data];
    
    for (int i=0; i<(1 << HASH_SIZE); i++)
    {
        int size = self.hashCountTable[i];
        
        if (size != 0)
        {
            NSData *subData = [NSData dataWithBytes:self.hashTableLight[i] length:size*sizeof(int)];
            [self saveToDB: i+1 data:subData];
        }
    }
    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *dictIndexFile = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory, self.locale, @"dictIndex.bin"];
//    [[NSFileManager defaultManager] createFileAtPath:dictIndexFile contents:nil attributes:nil];
//    
//    [self.dictIndex writeToFile:dictIndexFile atomically: YES];
//    
//#if RU_LANG == 1
//    
//    if ([self.locale isEqualToString: APP_LOCALE_RU])
//    {
//        [self parseAndSaveDict];
//    }
//#endif
    
    NSLog(@"Backup created");
}

-(void)loadIndexData
{
//    NSError *error = nil;
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %d", 0];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DictIndex" 
//                                              inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
//    NSData *data = [self.dictIndex objectForKey:[NSString stringWithFormat:@"%d", 0]];
//    [data getBytes:self.hashCountTable];
//    for (DictIndex *dictIndex in fetchedObjects)
//    {
//        [dictIndex.data getBytes:self.hashCountTable];
//        break;
//    }
    
    self.resultTable = [self.db.database executeQuery:[NSString stringWithFormat: @"select ZDATA, ZID from ZDICTINDEX where ZID=%d", 0]];
    
    while ([self.resultTable next])
    {
        NSData *data = [self.resultTable dataForColumn:@"ZDATA"];
        [data getBytes:self.hashCountTable];
        break;
    }
    
    [self.resultTable close];
    
    int counter = 0;
    
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id > %d", 0];
//    [fetchRequest setEntity:entity];
//    
//    fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    //self.dbTable = [self.db ExecuteQuery:[NSString stringWithFormat: @"select ZDATA, ZID from ZDICTINDEX where ZID>%d", 0]];
    int totalSize = 0;//self.dbTable.rows.count; //self.dictIndex.count;// fetchedObjects.count;
    
    self.resultTable = [self.db.database executeQuery:[NSString stringWithFormat: @"select ZDATA, ZID from ZDICTINDEX where ZID>%d", 0]];

    while ([self.resultTable next])
    {
        totalSize ++;
        
        NSData *data = [self.resultTable dataForColumn:@"ZDATA"];
        
        int i = [self.resultTable intForColumn:@"ZID"] - 1;
        int size = self.hashCountTable[i];
        
        self.hashTableLight[i] = (int*)malloc(size * sizeof(int));
        memset(self.hashTableLight[i], 0, size * sizeof(int));
        
        [data getBytes:self.hashTableLight[i]];
        
        [self.delegate dictSearcherUpdateProgress:self progress:(counter/totalSize)];
        counter++;
    }
    
    [self.resultTable close];
    

//    for (NSArray* row in self.dbTable.rows)
//    {
//        NSData *data = row[0];
//        [data getBytes:self.hashCountTable];
//    
//        int i = [row[1] intValue] - 1;
//        int size = self.hashCountTable[i];
//        
//        self.hashTableLight[i] = (int*)malloc(size * sizeof(int));
//        memset(self.hashTableLight[i], 0, size * sizeof(int));
//        
//        //data = [self.dictIndex objectForKey:key];
//        [data getBytes:self.hashTableLight[i]];
//        
//        [self.delegate dictSearcherUpdateProgress:self progress:(counter/totalSize)];
//        counter++;
//    }
}

-(void)loadDictionaryData
{
//    NSError *error = nil;
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id >= %d", 0];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DictEntry" 
//                                              inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    if (error != nil)
//    {
//        NSLog(@"DictEntity Fetch error: %@", error);
//    }
    
    int counter = 0;
    
    self.resultTable = [self.db.database executeQuery:[NSString stringWithFormat: @"select ZVALUE, ZID from ZDICTENTRY where ZID>=%d", 0]];
    
    while ([self.resultTable next])
    {
        [self.dictionary addObject: [self.resultTable stringForColumn:@"ZVALUE"]];
        counter++;
    }
    
    [self.resultTable close];
    
//    self.dbTable = [self.db ExecuteQuery:[NSString stringWithFormat: @"select ZVALUE, ZID from ZDICTENTRY where ZID>=%d", 0]];
//    
//    for (NSArray* row in self.dbTable.rows)
//    {
//        [self.dictionary addObject: row[0]];
//        counter++;
//    }
    
//    for (NSString *key in self.dictEntry.keyEnumerator)
//    {
//        [self.dictionary addObject: [self.dictEntry objectForKey:key]];
//        counter++;
//    }
    
//    for (DictEntry *dictEntity in fetchedObjects)
//    {
//        [self.dictionary addObject:dictEntity.value];
//        counter++;
//    }
    NSLog(@"%d DictEntities read", counter);
}

-(BOOL)loadBackupData
{
#if DO_BACKUP == 1
    return NO;
#endif
    NSDate *startTime = [NSDate date];

    [self loadIndexData];
    //[self loadDictionaryData];
    
    NSDate *endTime = [NSDate date];
    NSLog(@"Database load time: %f", [endTime timeIntervalSinceDate:startTime]);
    
    return YES;
}

-(int)makeHash: (NSString*)word
{
    int result = 0;
    NSString *src = [[word lowercaseString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *alphabet = [[self.alphabet lowercaseString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    for (int i=0; i<word.length; ++i)
    {
        unichar srcChar = [src characterAtIndex:i];
        
        for (int j=0; j<alphabet.length; j++)
        {
            if (srcChar == [alphabet characterAtIndex:j])
            {
                int group = self.alphabetMap[j];                
                result |= 1 << group;
            }
        }
    }
    
    return result;
}

-(int *)makeAlphabetMap
{
    if (_alphabetMap != nil)
    {
        return _alphabetMap;
    }
    
    double sourceAspect = (double) self.alphabet.length / HASH_SIZE;
    double aspect = sourceAspect;
    int *result = (int*)malloc(self.alphabet.length * sizeof(int));
    
    memset(result, 0, self.alphabet.length * sizeof(int));
    
    int *map = (int*)malloc(HASH_SIZE * sizeof(int));
    memset(map, 0, HASH_SIZE * sizeof(int));
    
    for (int i = 0; i < HASH_SIZE; ++i)
    {
        int step = (int) round(aspect);
        double diff = aspect - step;
        map[i] = step;
        aspect = sourceAspect + diff;
    }
    
    int resultIndex = 0;
    
    for (int i = 0; i < HASH_SIZE; ++i)
    {
        for (int j = 0; j < map[i]; ++j)
        {
            if (resultIndex < self.alphabet.length)
            {
                result[resultIndex++] = i;
            }
        }
    }
        
    free(map);
    
    return result;
}

- (void) dealloc
{
    for (int i=0; i<(1 << HASH_SIZE); i++)
    {
        free(self.hashTableLight[i]);
    }

    free(self.hashTableLight);
    free(self.hashCountTable);
    free(self.alphabetMap);
}

+ (int) getLivenshteinDistance: (int)maxDistance src:(NSString*)src dst:(NSString*)dst;
{
    int srcSize = [src length];
    int dstSize = [dst length];

    src = [[src lowercaseString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    dst = [[dst lowercaseString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
	if (srcSize > dstSize)
	{
		NSString *tmp = src;
		int tmpSize = srcSize;
		src = dst;
		dst = tmp;
        
		srcSize = dstSize;
		dstSize = tmpSize;
	}
    
	if (maxDistance < 0)
	{
		maxDistance = dstSize;
	}
    
	if (dstSize - srcSize > maxDistance)
	{
		return maxDistance + 1;
	}
    
	int newSize = srcSize + 1;
    
	int *currentRow = (int*)malloc(newSize * sizeof(int));
	int *previousRow = (int*)malloc(newSize * sizeof(int));
    
	memset(currentRow, 0, newSize * sizeof(int));
	memset(previousRow, 0, newSize * sizeof(int));
    
	int i = 0;
	int j = 0;
	int dist = 0;
    
	for (i=0; i<=srcSize; i++)
	{
		previousRow[i] = i;
	}
    
	for (i=1; i<=dstSize; i++)
	{
		unichar ch = [dst characterAtIndex:(i - 1)];
        //NSLog(@"Dst char : %c", ch);
        
		currentRow[0] = i;
        
		int from = MAX((i - maxDistance - 1), 1);
		int to = MIN((i + maxDistance + 1), srcSize);
        
		for (j=from; j<=to; j++)
		{
			int cost = [src characterAtIndex:(j - 1)] == ch ? 0 : 1;
			currentRow[j] = MIN((MIN((currentRow[j - 1] + 1), (previousRow[j] + 1))), (previousRow[j - 1] + cost));
		}
        
		int *tmpRow = currentRow;
		currentRow = previousRow;
		previousRow = tmpRow;
	}
    
	dist = previousRow[srcSize];
    
	free(currentRow);
	free(previousRow);
    
	return dist;
}

@end
