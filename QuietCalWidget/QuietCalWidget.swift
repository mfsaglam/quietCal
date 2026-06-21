//
//  QuietCalWidget.swift
//  QuietCalWidget
//
//  Created by Fatih Sağlam on 20.06.2026.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Deep links

enum WidgetDeepLink {
    /// Opens the app straight into the Add Meal sheet.
    static let addMeal = URL(string: "quietcal://addMeal")!
}

// MARK: - Timeline entry

struct CalorieEntry: TimelineEntry {
    let date: Date
    let eaten: Int
    let target: Int

    var remaining: Int { target - eaten }
    var isOverTarget: Bool { eaten > target }
    var overBy: Int { max(eaten - target, 0) }
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(eaten) / Double(target), 1.0)
    }

    /// Percent of target consumed, for compact lock-screen layouts.
    var percent: Int { Int((progress * 100).rounded()) }

    /// Compact eaten value for tight lock-screen rings, e.g. "1.2K" / "840".
    var eatenCompact: String {
        eaten >= 1000 ? String(format: "%.1fK", Double(eaten) / 1000) : "\(eaten)"
    }

    static let placeholder = CalorieEntry(date: Date(), eaten: 1240, target: 2000)
}

// MARK: - Timeline provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalorieEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (CalorieEntry) -> Void) {
        completion(context.isPreview ? .placeholder : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalorieEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh just after midnight so "today" rolls over even without an
        // app-triggered reload. The app reloads timelines on every data change.
        let nextMidnight = Calendar.current.nextDate(
            after: entry.date,
            matching: DateComponents(hour: 0, minute: 0, second: 5),
            matchingPolicy: .nextTime
        ) ?? entry.date.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func currentEntry() -> CalorieEntry {
        let stored = AppGroup.sharedDefaults.integer(forKey: AppGroup.targetKey)
        let target = stored > 0 ? stored : AppGroup.defaultTarget
        return CalorieEntry(date: Date(), eaten: Self.eatenToday(), target: target)
    }

    private static func eatenToday() -> Int {
        guard let interval = Calendar.current.dateInterval(of: .day, for: Date()) else { return 0 }
        let start = interval.start
        let end = interval.end
        do {
            let container = try AppGroup.makeModelContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<MealEntity>(
                predicate: #Predicate { $0.createdAt >= start && $0.createdAt < end }
            )
            return try context.fetch(descriptor).reduce(0) { $0 + $1.kcal }
        } catch {
            return 0
        }
    }
}

// MARK: - Ring

private struct WidgetRing: View {
    let progress: Double
    let isOver: Bool
    var lineWidth: CGFloat = 9

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(progress, 0.0001))
                .stroke(
                    isOver ? Color.orange : Color.green,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Small

private struct SmallWidgetView: View {
    let entry: CalorieEntry

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("TODAY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ZStack {
                WidgetRing(progress: entry.progress, isOver: entry.isOverTarget)
                VStack(spacing: 1) {
                    Text(entry.eaten.formatted())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(entry.isOverTarget ? Color.orange : Color.primary)
                    Text("of \(entry.target.formatted())")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }

            Text(entry.isOverTarget
                 ? "+\(entry.overBy.formatted()) over"
                 : "\(entry.remaining.formatted()) kcal left")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Medium

private struct MediumWidgetView: View {
    let entry: CalorieEntry
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                WidgetRing(progress: entry.progress, isOver: entry.isOverTarget, lineWidth: 10)
                VStack(spacing: 2) {
                    Text(entry.eaten.formatted())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(entry.isOverTarget ? Color.orange : Color.primary)
                    Text("of \(entry.target.formatted())")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 110, height: 110)

            VStack(alignment: .leading, spacing: 0) {
                Text(Self.dateLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)

                Text(entry.isOverTarget ? "+\(entry.overBy.formatted())" : entry.remaining.formatted())
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(entry.isOverTarget ? Color.orange : Color.primary)
                    .padding(.top, 2)

                Text(entry.isOverTarget ? "kcal over" : "kcal remaining")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Link(destination: WidgetDeepLink.addMeal) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Log meal")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if renderingMode == .accented {
                            // Tinted home screen: a filled pill collapses to one
                            // flat tint, hiding the label. Use an outline instead.
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.primary.opacity(0.5), lineWidth: 1.5)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary)
                        }
                    }
                    .foregroundStyle(renderingMode == .accented ? Color.primary : Color(.systemBackground))
                }
                .unredacted()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private static var dateLabel: String {
        let date = Date()
        let month = date.formatted(.dateTime.month(.abbreviated)).uppercased()
        let day = date.formatted(.dateTime.day())
        return "TODAY · \(month) \(day)"
    }
}

// MARK: - Lock screen (accessory) families

private struct AccessoryCircularView: View {
    let entry: CalorieEntry

    var body: some View {
        Gauge(value: entry.progress) {
            EmptyView()
        } currentValueLabel: {
            Text(entry.eatenCompact)
                .minimumScaleFactor(0.6)
        }
        .gaugeStyle(.accessoryCircular)
    }
}

private struct AccessoryRectangularView: View {
    let entry: CalorieEntry

    var body: some View {
        HStack(spacing: 12) {
            Gauge(value: entry.progress) {
                EmptyView()
            } currentValueLabel: {
                Text("\(entry.percent)")
                    .minimumScaleFactor(0.6)
            }
            .gaugeStyle(.accessoryCircularCapacity)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isOverTarget
                     ? "+\(entry.overBy.formatted()) over"
                     : "\(entry.remaining.formatted()) left")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("of \(entry.target.formatted()) kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct AccessoryInlineView: View {
    let entry: CalorieEntry

    var body: some View {
        Label(
            entry.isOverTarget
                ? "+\(entry.overBy.formatted()) kcal over"
                : "\(entry.remaining.formatted()) kcal left",
            systemImage: "flame.fill"
        )
    }
}

// MARK: - Entry view

struct QuietCalWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: CalorieEntry

    var body: some View {
        content
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch family {
        case .accessoryCircular, .accessoryRectangular:
            AccessoryWidgetBackground()
        case .accessoryInline:
            EmptyView()
        default:
            Color(.systemBackground)
        }
    }
}

// MARK: - Widget

struct QuietCalWidget: Widget {
    let kind = "QuietCalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuietCalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calories")
        .description("Today's calories at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    QuietCalWidget()
} timeline: {
    CalorieEntry(date: .now, eaten: 1240, target: 2000)
    CalorieEntry(date: .now, eaten: 2180, target: 2000)
}

#Preview("Medium", as: .systemMedium) {
    QuietCalWidget()
} timeline: {
    CalorieEntry(date: .now, eaten: 1240, target: 2000)
    CalorieEntry(date: .now, eaten: 2180, target: 2000)
}

#Preview("Circular", as: .accessoryCircular) {
    QuietCalWidget()
} timeline: {
    CalorieEntry(date: .now, eaten: 1240, target: 2000)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    QuietCalWidget()
} timeline: {
    CalorieEntry(date: .now, eaten: 1240, target: 2000)
}

#Preview("Inline", as: .accessoryInline) {
    QuietCalWidget()
} timeline: {
    CalorieEntry(date: .now, eaten: 1240, target: 2000)
}
