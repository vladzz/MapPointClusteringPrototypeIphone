//
//  AssetController.m
//  MapClusteringPrototypeiPhone
//
//  Created by Vlado Grancaric on 1/07/10.
//  Copyright 2010 VLADZZ
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <MapKit/MapKit.h>
#import "MapClusteringPrototypeiPhoneAppDelegate.h"
#import "AssetController.h"
#import "AssetAnnotation.h"

@implementation AssetController
+ (NSMutableArray *) getAssetsByCoordinateRegion: (NSValue*) region {
  
	MKCoordinateRegion currentRegion;
	[region getValue:&currentRegion];  
  
	NSMutableArray *assetItems = [[[NSMutableArray alloc] init] autorelease];    
	
	float westLon = currentRegion.center.longitude - currentRegion.span.longitudeDelta;
	float southLat = currentRegion.center.latitude - currentRegion.span.latitudeDelta;	

	for(int i=0; i < 400; i++) {
		AssetAnnotation *anno = [[AssetAnnotation alloc] init];		
		[anno setTitle:[NSString stringWithFormat:@"Pin %i",i]];
		[anno setLatitude:southLat + (currentRegion.span.latitudeDelta/50.0f)*(arc4random()%100)];
		[anno setLongitude:westLon + (currentRegion.span.longitudeDelta/50.0f)*(arc4random()%100)];		
		[assetItems addObject:anno];
		[anno release];		
	}

	return assetItems;
}

@end
