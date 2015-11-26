/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Contacts
import CoreLocation

struct CoffeeShop {

    // MARK: 属性

    let name: String
    let phone: String
    let details: String
    let openTime: NSDate
    let closeTime: NSDate
    let yelpWebsite: String
    let rating: CoffeeRating
    let priceGuide: PriceGuide
    let location: CLLocationCoordinate2D

    var addressDictionary: [String : String] {
        return [CNPostalAddressStreetKey : name]
    }

    var isOpenNow: Bool {
        return isOpenAtTime(NSDate())
    }

    static var timeZone = NSTimeZone(abbreviation: "PST")!

    // MARK: 构造器

    init?(dictionary: [String : AnyObject]) {

        guard let
            name = dictionary["name"] as? String,
            phone = dictionary["phone"] as? String,
            yelpWebsite = dictionary["yelpWebsite"] as? String,
            priceGuideRaw = dictionary["priceGuide"] as? Int,
            priceGuide = PriceGuide(rawValue: priceGuideRaw),
            details = dictionary["details"] as? String,
            ratingRaw = dictionary["rating"] as? Int,
            latitude = dictionary["latitude"] as? Double,
            longitude = dictionary["longitude"] as? Double,
            openTime = dictionary["openTime"] as? NSDate,
            closeTime = dictionary["closeTime"] as? NSDate else {
                return nil
        }

        self.name = name
        self.phone = phone
        self.yelpWebsite = yelpWebsite
        self.priceGuide = priceGuide
        self.details = details
        self.rating = CoffeeRating(value: ratingRaw)

        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        self.openTime = openTime
        self.closeTime = closeTime
    }

    // MARK: 静态方法

    static func allCoffeeShops() -> [CoffeeShop] {
        guard let
            path = NSBundle.mainBundle().pathForResource("sanfrancisco_coffeeshops", ofType: "plist"),
            array = NSArray(contentsOfFile: path) as? [[String : AnyObject]] else {
                return [CoffeeShop]()
        }

        let shops = array.flatMap { CoffeeShop(dictionary: $0) }.sort { $0.name < $1.name }
        let location2D = shops.first!.location
        let location = CLLocation(latitude: location2D.latitude, longitude: location2D.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            if let placemark = placemark?.first, timeZone = placemark.timeZone {
                self.timeZone = timeZone
            }
        }
        return shops
    }

    // MARK: 实例方法

    func isOpenAtTime(date: NSDate) -> Bool {
        
        let calendar = NSCalendar.currentCalendar()
        let nowComponents = calendar.componentsInTimeZone(CoffeeShop.timeZone, fromDate: date)

        let openTimeComponents = calendar.components([.Hour, .Minute], fromDate: openTime)
        let closeTimeComponents = calendar.components([.Hour, .Minute], fromDate: closeTime)

        let earlierCondition1 = (nowComponents.hour < openTimeComponents.hour)
        let earlierCondition2 = (nowComponents.hour == openTimeComponents.hour) &&
            (nowComponents.minute < openTimeComponents.minute)
        let isEarlier = (earlierCondition1 || earlierCondition2)

        let laterCondition1 = (nowComponents.hour > closeTimeComponents.hour)
        let laterCondition2 = (nowComponents.hour == closeTimeComponents.hour) &&
            (nowComponents.minute > closeTimeComponents.minute)
        let isLater = (laterCondition1 || laterCondition2)

        return !(isEarlier || isLater)
    }
}

extension CoffeeShop: CustomStringConvertible {
    var description: String {
        return "\(name) : \(details)"
    }
}

enum PriceGuide: Int {
    case Unknown
    case Low
    case Medium
    case High
}

enum CoffeeRating {

    case Unknown
    case Rating(Int)

    var value: Int {
        switch self {
        case .Unknown:
            return 0
        case .Rating(let value):
            return value
        }
    }

    init(value: Int) {
        self = (value > 0 && value <= 5) ? .Rating(value) : .Unknown
    }
}
