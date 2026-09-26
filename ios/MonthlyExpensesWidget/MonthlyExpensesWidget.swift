import SwiftUI
import WidgetKit

// The home-screen widget (WID-1–WID-6). Its Android twin is
// android/app/src/main/kotlin/com/oasisforge/monthlyexpenses/ExpenseWidgetProvider.kt,
// and both read the same payload: the app writes finished strings, in its own
// language and currency format, and the widget only paints them. Nothing here
// reads the database or works a number out (WID-5, WID-6).

let appGroupId = "group.com.oasisforge.monthlyexpenses"

/// The file the app writes the payload to, in a folder of the App Group
/// container that it keeps out of iCloud and computer backups (BAK-8). The
/// names must match HomeWidgetBridge.swift's.
private let payloadFolder = "WidgetPayload"
private let payloadFile = "payload.json"

/// The payload layout this build understands.
private let supportedVersion = 1

private let accent = Color(red: 0x6C / 255, green: 0x5C / 255, blue: 0xE7 / 255)

struct WidgetPayload: Decodable {
  let version: Int
  let hideAmounts: Bool
  let rtl: Bool
  let title: String
  let labels: [String: String]
  let entries: [PayloadEntry]

  func label(_ name: String) -> String { labels[name] ?? "" }

  static func read() -> WidgetPayload? {
    guard
      let file = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?
        .appendingPathComponent(payloadFolder, isDirectory: true)
        .appendingPathComponent(payloadFile, isDirectory: false),
      let data = try? Data(contentsOf: file),
      let payload = try? JSONDecoder().decode(WidgetPayload.self, from: data),
      payload.version == supportedVersion
    else { return nil }
    return payload
  }
}

struct PayloadEntry: Decodable {
  let from: Double
  let period: String
  let income: String
  let expense: String
  let balance: String

  /// Absent when no overall budget is in force (WID-1).
  let budgetLeft: String?
  let overBudget: Bool?

  var startsAt: Date { Date(timeIntervalSince1970: from / 1000) }
}

struct WidgetTimelineEntry: TimelineEntry {
  let date: Date
  let payload: WidgetPayload?
  let entry: PayloadEntry?
}

/// Turns the days the app sent into a WidgetKit timeline, so the turn of the
/// day reaches the widget without the app being opened (WID-5).
struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> WidgetTimelineEntry {
    WidgetTimelineEntry(date: Date(), payload: nil, entry: nil)
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (WidgetTimelineEntry) -> Void
  ) {
    completion(current())
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<WidgetTimelineEntry>) -> Void
  ) {
    let now = Date()
    let payload = WidgetPayload.read()
    var entries = [current(payload: payload, now: now)]
    for entry in payload?.entries ?? [] where entry.startsAt > now {
      entries.append(
        WidgetTimelineEntry(date: entry.startsAt, payload: payload, entry: entry)
      )
    }
    // .atEnd, so once the last day is reached WidgetKit asks again; by then
    // the app has usually run and sent more.
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  private func current(
    payload: WidgetPayload? = WidgetPayload.read(),
    now: Date = Date()
  ) -> WidgetTimelineEntry {
    let entry = payload?.entries.last { $0.startsAt <= now } ?? payload?.entries.first
    return WidgetTimelineEntry(date: now, payload: payload, entry: entry)
  }
}

struct MonthlyExpensesWidgetView: View {
  @Environment(\.widgetFamily) private var family
  /// The device's direction, as the system hands it to the widget.
  @Environment(\.layoutDirection) private var systemDirection
  let entry: WidgetTimelineEntry

  private var payload: WidgetPayload? { entry.payload }

  /// The app's words come in the app's language, so the app says which way
  /// they run. Before it has sent any, the only line is the catalog's, in the
  /// device's language, so the device's direction stays (WID-6).
  private var direction: LayoutDirection {
    guard let payload else { return systemDirection }
    return payload.rtl ? .rightToLeft : .leftToRight
  }

  /// Nothing to show before the app has ever run, and nothing to show while
  /// app lock hides the amounts — which the app enforces by not sending them
  /// at all (WID-4).
  private var hidden: Bool {
    payload == nil || payload!.hideAmounts || entry.entry == nil
  }

  /// What stands where the amounts would. While app lock hides them the app
  /// sent its own words for that (WID-4). Otherwise there are no amounts
  /// because the app has not run yet, so there are no words from the app
  /// either: this line comes from the extension's Localizable.xcstrings, in
  /// the device's language, as Android's widget_open_the_app does (WID-6).
  private var note: Text {
    if let payload, payload.hideAmounts {
      return Text(payload.label("hidden"))
    }
    return Text("widget_open_the_app")
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(hidden ? (payload?.title ?? "") : entry.entry!.period)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)

      if hidden {
        Spacer(minLength: 0)
        note
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(3)
        Spacer(minLength: 0)
      } else {
        Spacer(minLength: 0)
        amounts(entry.entry!)
        Spacer(minLength: 0)
      }

      buttons
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .environment(\.layoutDirection, direction)
    .widgetBackground()
    // The whole widget is one tap target. On the medium one the Links above
    // take their own taps and this is what is left — the numbers, which open
    // Home. The small one has no Links, so its single target is the Add
    // expense button it draws (WID-3).
    .widgetURL(action(family == .systemSmall ? "add_expense" : "open_home"))
  }

  @ViewBuilder
  private func amounts(_ shown: PayloadEntry) -> some View {
    if family == .systemSmall {
      // The budget left leads when there is one, since that is the number
      // worth glancing at (WID-1).
      let budget = shown.budgetLeft
      VStack(alignment: .leading, spacing: 2) {
        Text(budget == nil ? payload!.label("expense") : payload!.label("budgetLeft"))
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(budget ?? shown.expense)
          .font(.title2.bold())
          .minimumScaleFactor(0.6)
          .foregroundStyle(shown.overBudget == true ? Color.red : Color.primary)
          .lineLimit(1)
      }
    } else {
      HStack(alignment: .top, spacing: 8) {
        figure(payload!.label("income"), shown.income)
        figure(payload!.label("expense"), shown.expense)
        figure(payload!.label("balance"), shown.balance)
        if let budget = shown.budgetLeft {
          figure(
            payload!.label("budgetLeft"),
            budget,
            over: shown.overBudget == true
          )
        }
      }
    }
  }

  private func figure(_ label: String, _ amount: String, over: Bool = false)
    -> some View
  {
    VStack(alignment: .leading, spacing: 1) {
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
      Text(amount)
        .font(.subheadline.bold())
        .minimumScaleFactor(0.6)
        .foregroundStyle(over ? Color.red : Color.primary)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var buttons: some View {
    if family == .systemSmall {
      // A small widget has only one tap target — Link does nothing there —
      // so the whole widget is the Add expense button it draws, and Home is
      // reached from the medium one (WID-3).
      pill(payload?.label("addExpense") ?? "", filled: true)
    } else {
      HStack(spacing: 6) {
        Link(destination: action("add_expense")) {
          pill(payload?.label("addExpense") ?? "", filled: true)
        }
        Link(destination: action("add_income")) {
          pill(payload?.label("addIncome") ?? "", filled: false)
        }
      }
    }
  }

  private func pill(_ title: String, filled: Bool) -> some View {
    Text(title)
      .font(.caption.weight(.medium))
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .padding(.vertical, 7)
      .frame(maxWidth: .infinity)
      .background(filled ? accent : Color.clear, in: Capsule())
      .overlay(
        Capsule().strokeBorder(filled ? Color.clear : accent.opacity(0.5))
      )
      .foregroundStyle(filled ? Color.white : accent)
  }

  private func action(_ name: String) -> URL {
    URL(string: "monthlyexpenses://widget/\(name)")!
  }
}

private extension View {
  /// iOS 17 wants widgets to declare their background; older ones paint it.
  @ViewBuilder
  func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(for: .widget) { Color(uiColor: .systemBackground) }
    } else {
      padding().background(Color(uiColor: .systemBackground))
    }
  }
}

struct MonthlyExpensesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "MonthlyExpensesWidget", provider: Provider()) {
      entry in
      MonthlyExpensesWidgetView(entry: entry)
    }
    // What the widget gallery shows, looked up in this extension's
    // Localizable.xcstrings in the device's language (LANG-2, WID-6): the
    // same words as the Android widget picker.
    .configurationDisplayName(Text("widget_name"))
    .description(Text("widget_description"))
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct MonthlyExpensesWidgetBundle: WidgetBundle {
  var body: some Widget {
    MonthlyExpensesWidget()
  }
}
