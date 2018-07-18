//
//  FireMockDataSource.swift
//  FireMock
//
//  Created by Albert Arroyo on 3/3/18.
//

import UIKit

/// Class to prepare Category Section for Collasped / Expanded
class FireMockCategorySection {
    var title: String
    var mocks: [FireMock.ConfigMock]
    var collapsed: Bool

    init(title: String, mocks: [FireMock.ConfigMock], collapsed: Bool = true) {
        self.title = title
        self.mocks = mocks
        self.collapsed = collapsed
    }
}

/// DataType for FireMock
class FireMockCategoriesDataType {

    var configMockSections: [FireMockCategorySection]

    init(mockSections: [FireMockCategorySection]) {
        self.configMockSections = mockSections
    }

}

extension FireMockCategoriesDataType: FireMockDataType {
    var numberOfSections: Int {
        return configMockSections.count
    }
    func numberOfItems(section: Int) -> Int {
        return configMockSections[section].mocks.count
    }
}





