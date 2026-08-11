// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 BarutSRB — https://github.com/BarutSRB/OmniWM

import Foundation

@MainActor
enum WorkspaceEntryOrdering {
    private struct SortKey {
        let group: Int
        let primary: Int
        let secondary: Int
    }

    static func orderedEntries(
        _ entries: [WindowState],
        topology: LayoutTopology
    ) -> [WindowState] {
        guard topology.hasColumns else { return entries }

        var orderMap: [WindowToken: SortKey] = [:]
        for (columnIndex, column) in topology.columns.enumerated() {
            for (rowIndex, tile) in column.tiles.enumerated() {
                orderMap[tile.token] = SortKey(group: 0, primary: columnIndex, secondary: rowIndex)
            }
        }
        for (offset, entry) in entries.enumerated() where orderMap[entry.token] == nil {
            orderMap[entry.token] = SortKey(group: 2, primary: offset, secondary: 0)
        }

        return entries.sorted { lhs, rhs in
            let lhsKey = orderMap[lhs.token]!
            let rhsKey = orderMap[rhs.token]!

            if lhsKey.group != rhsKey.group { return lhsKey.group < rhsKey.group }
            if lhsKey.primary != rhsKey.primary { return lhsKey.primary < rhsKey.primary }
            return lhsKey.secondary < rhsKey.secondary
        }
    }
}
