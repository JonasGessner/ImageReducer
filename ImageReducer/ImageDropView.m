//
//  ImageDropView.m
//  ImageReducer
//
//  Created by Jonas Gessner on 21.10.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "ImageDropView.h"

@implementation ImageDropView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    BOOL anyFileValid = NO;
    for (NSString *path in filePaths) {
        if ([[path.pathExtension lowercaseString] isEqualToString:@"png"] || [[path.pathExtension lowercaseString] isEqualToString:@"jpg"]) {
            anyFileValid = YES;
            break;
        }
    }
    
    return (anyFileValid ? NSDragOperationCopy : NSDragOperationNone);
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    BOOL anyFileValid = NO;
    for (NSString *path in filePaths) {
        NSString *extension = [path.pathExtension lowercaseString];
        
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"]) {
            CGFloat scale = (CGFloat)[[[[path.pathComponents.lastObject stringByDeletingPathExtension] componentsSeparatedByString:@"@"] lastObject] integerValue];
            
            if (scale > 1) {
                NSString *scaleString = [NSString stringWithFormat:@"@%ix", (int)scale];
                NSString *naturalFilename = [path stringByDeletingPathExtension];
                naturalFilename = [naturalFilename substringToIndex:naturalFilename.length-scaleString.length];
                
                NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
                CGSize naturalSize = img.size;
                
                for (NSUInteger i = 1; i < scale; i++) {
                    CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
                    
                    NSSize currentSize = (NSSize){(naturalSize.width*(CGFloat)i)/screenScale, (naturalSize.height*(CGFloat)i)/screenScale};
                    NSRect rect = (NSRect){NSZeroPoint, currentSize};
                    
                    NSImage *newImage = [[NSImage alloc] initWithSize:currentSize];
                    
                    [newImage lockFocus];
                    [img drawInRect:rect];
                    [newImage unlockFocus];
                  
                    NSString *newFilename = (i > 1 ? [naturalFilename stringByAppendingFormat:@"@%lux.%@", (unsigned long)i, extension] : [naturalFilename stringByAppendingPathExtension:extension]);
                    
                    CGImageRef newImg = [newImage CGImageForProposedRect:&rect context:nil hints:nil];
                    
                    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:newImg];
                    
                    NSData *data = [rep representationUsingType:([extension isEqualToString:@"png"] ? NSPNGFileType : NSJPEGFileType) properties:@{NSImageCompressionFactor : @(1.0)}];
                    
                    BOOL ok = [data writeToFile:newFilename atomically:YES];
                    
                    if (ok) {
                         anyFileValid = YES;
                    }
                }
            }
        }
    }
    
    return anyFileValid;
}

@end
