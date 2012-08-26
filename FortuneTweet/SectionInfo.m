
/*
     File: SectionInfo.m
 Abstract: A section info object maintains information about a section:
 * Whether the section is open
 * The header view for the section
 * The model objects for the section -- in this case, the dictionary containing the quotations for a single play
 * The height of each row in the section
 
  Version: 2.0
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "SectionInfo.h"
// #import "SectionHeaderView.h"
// #import "Play.h"


@implementation SectionInfo

// @synthesize open, rowHeights, play, headerView;
@synthesize open=_open;
@synthesize rowHeights=_rowHeights;
// @synthesize play=_play;
// @synthesize headerView=_headerView;

- init {
	
	self = [super init];
	if (self) {
		_rowHeights = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSUInteger)countOfRowHeights {
	return [_rowHeights count];
}

- (id)objectInRowHeightsAtIndex:(NSUInteger)idx {
	return [_rowHeights objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx {
	[_rowHeights insertObject:anObject atIndex:idx];
}

- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes {
	[_rowHeights insertObjects:rowHeightArray atIndexes:indexes];
}

- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx {
	[_rowHeights removeObjectAtIndex:idx];
}

- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes {
	[_rowHeights removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject {
	[_rowHeights replaceObjectAtIndex:idx withObject:anObject];
}

- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray {
	[_rowHeights replaceObjectsAtIndexes:indexes withObjects:rowHeightArray];
}




@end
