//
//  PharmacyCalloutView.h
//  Pods
//
//  Created by Roman Bolshakov on 2014/03/01.
//
//

#import <UIKit/UIKit.h>
#import "YandexMapKit.h"
#import "Pharmacy.h"

@interface PharmacyCalloutView : UIView<YMKCalloutContentView>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *commerceVisitButton;
@property (weak, nonatomic) IBOutlet UIButton *promoVisitButton;
@property (weak, nonatomic) IBOutlet UIButton *pharmacyCircleButton;

@property (strong, nonatomic) Pharmacy* pharmacy;
@end
