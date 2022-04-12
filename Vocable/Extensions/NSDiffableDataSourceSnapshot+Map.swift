//
//  NSDiffableDataSourceSnapshot+Map.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/12/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    func mapItemIdentifier<NewIdentifierType: Hashable>(_ transform: (ItemIdentifierType) -> NewIdentifierType) -> NSDiffableDataSourceSnapshot<SectionIdentifierType, NewIdentifierType> {
        var updatedSnapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, NewIdentifierType>()

        updatedSnapshot.appendSections(sectionIdentifiers)

        for sectionId in sectionIdentifiers {
            let categoryItems = itemIdentifiers(inSection: sectionId).map(transform)

            updatedSnapshot.appendItems(categoryItems, toSection: sectionId)
        }

        return updatedSnapshot
    }
}
