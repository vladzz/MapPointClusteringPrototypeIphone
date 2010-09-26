//
//  AssetClusterAnnotation.m
//  MapClusteringPrototypeiPhone
//
//  Created by Vlado Grancaric on 2/07/10.
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

#import "AssetClusterAnnotation.h"


@implementation AssetClusterAnnotation

@synthesize clusterer,annotations, centerLongitude, centerLatitude, mapView;

- (id)initWithAnnotationClusterer:(AnnotationClusterer*) clusterManager {
  
  if ((self = [super init])) {
    // Custom initialization
    annotations = [NSMutableArray new];
    self.clusterer = clusterManager;
    self.mapView = clusterManager.mapView;
    centerLatitude = 0.0f;
    centerLongitude = 0.0f;
    
  }
  
  return self;
  
}

- (CLLocationCoordinate2D)coordinate {
  CLLocationCoordinate2D theCoordinate;
  theCoordinate.latitude = self.centerLatitude;
  theCoordinate.longitude = self.centerLongitude;
  return theCoordinate; 
}

- (NSString*) title {
  return [NSString stringWithFormat:@"Number of Markers: %i", [annotations count]]; 
}
-(void) addAnnotation: (id <MKAnnotation>) annotation {
  if(centerLatitude == 0.0 && centerLongitude == 0.0) {
    centerLatitude = annotation.coordinate.latitude;
    centerLongitude = annotation.coordinate.longitude;
  }
  
  [annotations addObject:annotation];
}

-(BOOL) removeAnnotation:(id <MKAnnotation>) annotation {
  for(id <MKAnnotation> anno in annotations) {
    if([annotation isEqual:anno]) {
      if([[mapView annotations] containsObject:annotation]) {
        [mapView removeAnnotation:annotation];
        
        return YES;
      }
      
      [annotations removeObject:annotation];
      return YES;
    }
  }
  return NO;
}

-(int) totalMarkers {
  return [annotations count];
}

- (void)dealloc
{
  [annotations release];
  [super dealloc];
}

@end
